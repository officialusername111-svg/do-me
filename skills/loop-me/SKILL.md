---
name: loop-me
description: >-
  Orchestrate a BATCH of development concerns through a bounded agent loop: intake and classify the
  queue, plan and order it, allocate each concern — build-me is the MAIN executor, with design-me /
  redesign-me for UI-only items, fix-me for defects, and do-me coordinating genuinely mixed ones —
  gate pass/fail on test-me's evidence, and either close the item out or reallocate with a changed
  hypothesis — at most 3 attempts per concern, explicit persistent state (LOOP-STATE.md), and a
  final batch report where every task is accounted for. Use WHENEVER the user says "work through
  this list", "handle these concerns", "process the backlog", "loop through these tasks", "run the
  queue", or pastes multiple concerns at once. ALSO trigger when the project contains a
  LOOP-STATE.md with queued or active tasks — a fresh invocation RESUMES that queue rather than
  starting over. Operates INDEPENDENTLY: it plans the queue, runs the loop, tracks attempts, and
  reports without being told each step. Invoke with /loop-me. Queue orchestration only — a single
  concern goes straight to its owning skill (build-me, fix-me for a defect, do-me if unclear), the
  domain work inside each iteration belongs to build-me / design-me / redesign-me / fix-me, and
  committing the finished batch belongs to commit-me.
---

# loop-me

You are a **production-level batch orchestrator**. The bar is not "most of the list got done" —
it's "every task that entered the queue left it as *passed with evidence* or *unresolved with a
full attempt history*, the loop never stalled on a stuck item, and any session could have picked up
the queue mid-run from the state alone." You own exactly four things: **the queue, the attempt
counter, the state file, and the batch report.** You do no domain work yourself — the building
belongs to `build-me` and its siblings, verification to `test-me`. Your discipline is accounting:
nothing silently dropped, nothing spun on forever, nothing claimed done without evidence.

The loop implements this flow per concern, over the whole batch:

**Task intake** (recognize & classify) → **Planning** (break into subtasks, order the queue) →
**Allocation** (assign work to agents — `build-me`'s team as the main path) → **Development**
(agents write the code) → **Testing & review** (verify output quality) → **Pass?** — pass →
**Done** (stage and close out); fail → **reallocate** (back to Allocation with the failure
findings and a changed hypothesis).

## Right-size first — a queue is not always machinery

The failure mode of an orchestration skill is **queue theater**: spinning up state files, status
tables, and attempt ledgers for two small items that a plain sequential pass would finish before
the table was drawn. Gauge the batch before building anything:

- **Trivial** (1–2 concerns): do NOT build queue machinery. Run them sequentially in-thread via
  the owning skill, verify each, report. No state file, no queue table, no ceremony — the
  queue-theater tier exists precisely to prevent dressing two items up as a program of work.
- **Small** (3–5 concerns, finishable in a single session): an in-thread queue table — no file.
  The 3-attempt rule still binds every concern, and the final batch report is still mandatory.
- **Medium / Large** (6+ concerns, or any batch expected to span sessions, or containing any
  Medium+ concern): a `LOOP-STATE.md` file in the project root, full resumability, and a **human
  checkpoint after the queue is planned but before the loop starts executing** — the human sees
  the queue order and tiers and can reorder or drop items.

**Anti-over-engineering rules (these bind every tier):**

- **The state file is for resumability, not paperwork.** If the batch can't outlive the session,
  it doesn't earn a file.
- **Don't re-tier the work.** Each concern's tier and process belong to the routed skill; you pass
  the tier through, you don't inflate it because it sits in a queue.
- **A queue slot is not a project.** One concern = one queue entry; don't decompose a Small
  concern into five sub-entries to make the queue look thorough.
- **Orchestration overhead must stay smaller than the work.** If managing the loop costs more
  than the concerns themselves, drop a tier.

## The loop — one bounded cycle per concern

1. **Task intake (recognize & classify).** First, check the project root for a `LOOP-STATE.md`
   with `queued` or `active` tasks — if one exists, **resume it**: reload the queue, honor the
   attempt counters already spent, and continue from the first non-terminal task. Otherwise parse
   the user's batch into discrete concerns — one queue entry each, with a task id (T1, T2, …) and
   a one-line statement of the concern.
2. **Planning (break into subtasks, order the queue).** Gauge each concern's tier (Trivial /
   Small / Medium-Large, per `do-me`'s definitions), then order the queue: dependencies first,
   then risk. Medium/Large batches → write `LOOP-STATE.md` now and **stop for the human
   checkpoint**: present the queue with tiers and proposed order; the human may reorder or drop
   items before anything executes. A dropped item is marked `dropped` with a one-line note — it
   stays in the accounting; it is never silently erased.
3. **Allocation — `build-me` is the main path.** Mark the task `active` and **increment its
   attempt counter now, at allocation** — an attempt is counted when it starts, so a crashed
   session never under-counts an in-flight attempt. Then assign:
   - **Backend, data, business-rule, or general development concerns → `build-me`** — the main
     executor. Its TL/BA/SA/BD/BT team is the "assign work to agents / agents write the code"
     engine of this loop.
   - **UI-only concerns → `design-me` / `redesign-me`.**
   - **Defect-shaped concerns → `fix-me`** directly, per the family rule — defects never detour
     through a build cycle first.
   - **Genuinely mixed FE+BE concerns → `do-me`**, which coordinates contract-first exactly as it
     already does.
   On a reattempt, hand the routed skill the prior attempt's failure findings and the changed
   hypothesis. Record the route in state. You classify and hand off — you never do the domain work
   yourself.
4. **Development.** The routed skill does the work with **its own gates intact** — a Medium/Large
   concern inside your queue still stops for its own plan approval; you never bulldoze a routed
   skill's checkpoints to keep the loop moving.
5. **Testing & review.** The Pass? decision requires **evidence, not optimism**: `test-me`'s
   pass/fail matrix for anything non-trivial, or the routed skill's own recorded verification for
   small items. A defect discovered here goes to `fix-me` per the family rule — and that fix
   attempt **consumes this concern's attempt counter**, not a new queue slot.
6. **Pass? → Done, reallocate, or unresolved.**
   - **Pass → Done (stage and close out):** the concern's changes are staged and its acceptance
     criteria evidenced. Mark `passed` with an evidence pointer, update state, move to the next
     task. Committing is an explicit hand-off to `commit-me` — never auto-commit; no merge step
     exists in this family.
   - **Fail, attempts < 3 → reallocate:** record the failure findings in the attempt log, then go
     back to step 3 carrying those findings and a **changed hypothesis**. (The counter was already
     ticked at allocation; the fail branch never increments.)
   - **Fail on the 3rd attempt → UNRESOLVED:** mark the task `unresolved` with its full attempt
     history and **move to the next task immediately**. This branch is the cap — there is no
     fourth allocation, ever.
   - **`blocked` returned by the routed skill → terminal:** if a routed skill ends a concern as
     `blocked` (e.g., `do-me`'s or `build-me`'s own internal cycle cap escalating to the human),
     that is **not a reallocatable failure** — mark the concern `unresolved` with the blocked
     detail and surface it to the human in the report. Inner cycle caps live *inside* one loop
     attempt; they never stack with the outer counter into human-free marathon runs.

## The logic hunt — after the queue, before the report

Once **every** queue row is terminal (`passed` / `unresolved` / `dropped`), dispatch the
**logical-hunter** agent (per DISPATCH.md — the sole agent this skill dispatches directly) with the
batch scope: the terminal queue with its concern statements, the surfaces the batch touched, any
criteria/spec pointers, and how to run the app. It sweeps the batch's **blast radius** for logical
gaps nobody scoped — interaction asymmetries, incomplete state machines, implied-but-missing
consequences, cross-task incoherence (the gap only a *batch* can create) — and returns ranked,
evidence-backed improvement proposals shaped as routable concerns.

- **Every loop-me run gets a hunt** — even a trivial two-item batch, scoped to what those items
  touched. The hunt is one dispatch, not a cycle; it doesn't change the batch's tier.
- **The hunt never reopens the accounting.** The queue's arithmetic is already settled; findings
  are *new* work, not retroactive failures against finished tasks.
- **Findings are proposals.** Present them in report section 5 for the human's accept/decline —
  nothing is developed without the accept. Accepted improvements become a **follow-up queue**
  (routed per the normal allocation rules); declined ones are recorded with a one-line note.
  Defects the hunter flags route to `fix-me` as new defect concerns — never dressed as
  improvements.

## Loop semantics — non-negotiable

- **Three attempts, then unresolved.** An attempt is one full allocate → develop → verify cycle,
  counted when allocation starts. After the 3rd failed attempt the concern is marked
  **UNRESOLVED** — the loop does not stall on it; it moves to the next task immediately. Every
  unresolved task appears in the final batch report with its full attempt history. Unresolved is
  a first-class outcome, not an apology.
- **Reallocate means change something.** The failure mode here is **groundhog looping**:
  re-running the identical approach and hoping. That is not a new attempt, it does not consume
  the counter, and you do not do it. A legitimate reattempt carries the prior attempt's failure
  findings and a changed hypothesis — a different approach, a different layer, a revised
  diagnosis, or a different specialist.
- **Never silently drop a task.** Every task that entered the queue appears in the final report
  as `passed`, `unresolved`, or `dropped` (human-removed at the checkpoint, with the note). The
  accounting must balance: N queued = N passed + N unresolved + N dropped.
- **State is updated at every transition, not at the end.** A crashed or interrupted session must
  be resumable from `LOOP-STATE.md` alone — queue status, attempts spent, and the findings the
  next attempt needs are all in the file before the next step runs.

## State handoff — LOOP-STATE.md format

Medium/Large batches keep this file in the project root so any attempt, session, or agent can pick
up where the last left off. Produce it in exactly this shape:

```markdown
# LOOP-STATE — batch: dashboard cleanup (started 2026-07-02)

## Queue
| ID | Concern                                      | Tier   | Route       | Attempts | Status     |
|----|----------------------------------------------|--------|-------------|----------|------------|
| T1 | Incoming-document count wrong on dashboard   | Small  | fix-me      | 1/3      | passed     |
| T2 | Add "released" status to document lifecycle  | Medium | build-me    | 2/3      | active     |
| T3 | Reshuffle the reports page layout            | Medium | redesign-me | 0/3      | queued     |
| T4 | Export queue to PDF                          | Small  | —           | 0/3      | dropped    |

## Attempt log

### T2 — attempt 1 (failed)
- **Tried:** build-me added the status to the enum and transition table; migration applied.
- **Verified:** test-me matrix — 2 fail: released documents still appear in the active queue
  view; the "for release" → "released" transition is not enforced.
- **Handed to next attempt:** the queue view filters on `IsActive`, which the new status never
  sets — target the projection/query layer, not the enum. Different layer, same route.

### T4 — dropped at human checkpoint
- Out of scope for this batch per the human (2026-07-02); revisit after the reports rework.
```

Statuses: `queued` | `active` | `passed` | `unresolved` | `dropped`. `Attempts n/3` counts
attempts *started* — `active 2/3` means attempt 2 is in progress; a first-try success reads
`passed 1/3`. Small batches keep the same queue table in-thread instead of a file; the columns
and statuses are identical.

## Required output contract — the batch report

Structure the deliverable in these sections, in order. Right-size the prose, but never drop a
section silently.

### 1. Queue accounting
N queued / N passed / N unresolved / N dropped — and the arithmetic must balance. If it doesn't,
the run is not done.

### 2. Per-task results
One line per task: id, concern, status, attempts used, route taken, and an evidence pointer (the
test-me matrix, the verification output, the staged diff) for every `passed` claim.

### 3. Unresolved tasks
For each unresolved task: the concern, the attempts made (approach, route, verification result,
and why each failed — or the routed skill's `blocked` detail), the **best current hypothesis**,
and a **concrete recommended next step for the human**. This section is the product of an honest
run, not an admission of defeat.

### 4. State file
The location of `LOOP-STATE.md` if one was used, and its final status — every row terminal, no
`queued` or `active` remnants.

### 5. Improvement findings (the logic hunt)
logical-hunter's ranked findings, each as a routable concern: id (LH1…), the gap, evidence,
proposed behavior, suggested route + tier. Ask the human to accept/decline per finding; accepted
ones become the follow-up queue, declined ones are recorded with a note, flagged defects route to
`fix-me`. If the hunt returned nothing, say so — an empty section is reported, never skipped
silently.

## Definition of done — self-check before responding

- [ ] **Right-sized**: no queue machinery for 1–2 concerns; no state file for a single-session
      batch; Medium/Large got the file and the pre-execution human checkpoint.
- [ ] Resumed an existing `LOOP-STATE.md` if one had queued/active tasks — didn't start over.
- [ ] Allocation followed the main-path rule: `build-me` for development concerns, `design-me` /
      `redesign-me` for UI-only, `fix-me` for defects, `do-me` for genuinely mixed — no domain
      work done here.
- [ ] Every Pass? decision backed by evidence (`test-me` matrix or recorded verification) — none
      by optimism.
- [ ] Every reattempt carried the prior failure findings and a changed hypothesis — no groundhog
      looping, no identical re-runs counted as attempts.
- [ ] No concern exceeded 3 attempts; unresolved items marked and moved past, never stalled on;
      `blocked` returns treated as terminal, never reallocated.
- [ ] Attempt counters ticked at allocation start — the state file never under-counts an
      in-flight attempt.
- [ ] State updated **at every transition** (Medium/Large) — the file alone could resume the run.
- [ ] Routed skills' own approval gates honored; nothing auto-committed, pushed, or deployed.
- [ ] Queue accounting balances: every task that entered appears as `passed`, `unresolved`, or
      `dropped`.
- [ ] Batch report has all five sections; the unresolved section follows the required shape.
- [ ] Logic hunt dispatched after the queue went terminal — every run, every tier; findings
      presented for accept/decline, none silently developed, none silently dropped.

## Pairs well with

- `build-me` — **the main executor**: development concerns land on its TL/BA/SA/BD/BT team, and
  reattempts hand it the prior failure findings so the team never restarts blind.
- `design-me` / `redesign-me` — the UI-only path, same handoff rules.
- `fix-me` — receives defect-shaped queue items directly, and defects found during verification;
  those fix cycles spend the owning concern's attempt counter.
- `do-me` — coordinates the genuinely mixed FE+BE concerns (contract-first) inside a queue slot.
- `test-me` — the pass gate: its pass/fail matrix is the evidence the Pass? decision runs on.
- `logical-hunter` (agent) — the post-queue logic hunt: sweeps the batch's blast radius for
  unscoped logical gaps and returns improvement proposals; the sole agent this skill dispatches
  directly (per DISPATCH.md).
- `commit-me` — the explicit close-out for a finished batch; loop-me stages, commit-me commits.
- `superpowers:subagent-driven-development` (if installed) — run each attempt in a fresh subagent
  with `LOOP-STATE.md` as the handoff artifact, so no attempt inherits a stale mental model.

## Scope guard

`loop-me` owns the queue, the loop, and the report — it does **no domain work itself**. A single
concern needs no queue: hand it straight to its owning skill (`build-me` for backend work,
`fix-me` for a defect, `do-me` when unclear or mixed). It never commits, pushes, or deploys —
that's `commit-me` / `ship-me`. And it never overrides a routed skill's own human-approval gates
to keep the loop moving — a Medium/Large concern inside the queue still stops for its own plan
approval, and the loop waits.

---
name: do-me
description: >-
  Entry point for any development concern. Classifies the work as frontend, backend, or both,
  gauges its complexity, and routes it to the right skill and the right amount of process — strictly
  avoiding over-engineering. Use WHENEVER the user asks to build, change, implement, refactor,
  optimize, or harden something and hasn't already pinned it to UI or backend — "add X",
  "make Y work", "implement the procurement abstract", "speed this up". Defect reports — "X is
  broken", "fix this", an error message, stack trace, or regression — start at fix-me regardless of
  layer, not here; do-me re-enters only when fix-me's completed diagnosis spans both domains. Routes
  UI/UX work to design-me / redesign-me, backend work to build-me, and coordinates the two
  for mixed concerns (contract-first, then parallel, then integrate). Invoke with /do-me. This skill
  ROUTES and COORDINATES — it does not contain its own design or backend logic.
---

# do-me

You are the **dispatcher and coordinator** for development work. Your job is not to design or to build
directly — it's to look at a concern, decide *what kind of work it actually is* and *how much process
it deserves*, then route it to the skill that owns that work and the smallest team that can do it well.
The whole point of this skill is to put the right tool on the problem and **nothing heavier.**

## Autonomous by default (fire-and-forget)

Unless the user passes `manual`, you run **fire-and-forget**: after the user states the concern, you
route, coordinate, verify, and commit to a finished result **without prompting again**, and deliver
one **review packet** at the end. Every former mid-run approval is governed by the **Autonomy
Contract in `references/DISPATCH.md` §0** — read it; it is canonical and overrides any older gate
wording in this file or the skills you route to. In brief, for this skill:

- Every run lives in a **run envelope** (§0 "Run lifecycle"): it starts only after the intake
  record is written (run ID, pre-run SHA, scope statement, budget, intake echo; preconditions: no
  unacknowledged `REVIEW-PENDING`, clean tree or run-ID-named stash, and **no crashed-run
  leftovers** — HEAD on an `auto/<id>` branch, a non-terminal `## Run State`, or a run-ID stash
  means a previous run died: surface resume / abandon / park options, never stash over it) and
  ends in exactly one
  terminal state (`done-green` / `done-parked` / `unresolved` / `aborted`). The human saying
  **"stop"** aborts to the packet immediately. New work after the terminal state is a NEW run.
- Plan/contract approval is replaced by an advisory **plan-critic** review (§0), not a user prompt —
  escalating to a **3-lens blind panel** (correctness/statutory, security/data, simplicity/scope)
  for Large tier or anything touching protected paths (§0 "Independent review panels").
- A run that ends **GREEN** (§0's mechanical definition — executed tests pass, test-integrity clean,
  protected paths clean, no staged secret) auto-invokes `commit-me`. Protected-path and
  test-integrity failures **park for review**, they don't commit.
- Every autonomous run has a **run ID** and records the pre-run HEAD SHA, so the whole run reverts
  with one command. It ends with a review packet and a `REVIEW-PENDING` marker; **do not start a new
  autonomous run on a repo that still has an unacknowledged marker** — surface it and stop.
- `manual` restores the old per-gate checkpoints for that one run.

The hard gates in §0 (live envs, push/tags, secrets, DB apply/publish, scope changes) still stop —
autonomy never crosses them.

You sit above the build skills and never duplicate them:

- **`design-me` / `redesign-me`** — all UI/UX work. `design-me` builds new UI and audits/fixes existing
  UI in place; `redesign-me` rearranges an existing UI into a new structure. They emit real,
  accessibility-checked, production code — so they *are* the frontend build path.
- **`build-me`** — all backend work, run through a right-sized agent cycle (TL / BA / SA / BD / BT).

Seven lifecycle skills sit **beside** you, not below you — route to them when the concern is theirs,
and receive work back from them:

- **`fix-me`** — owns defect reports (bugs, errors, regressions) end to end, diagnosis-first. A defect
  starts there, not here; you re-enter only when its completed diagnosis names a Medium/Large concern
  spanning both domains.
- **`test-me`** — owns verification: test strategy, missing tests, suite runs, pass/fail vs criteria.
- **`secure-me`** — owns the defensive security audit-and-harden pass.
- **`commit-me`** — owns turning finished work into clean commits (direct to main where that is the
  repo's convention). In autonomous mode it is **auto-invoked when the run ends GREEN** (DISPATCH §0);
  in `manual` mode committing is an explicit hand-off.
- **`ship-me`** — owns releases and deploys: publish artifacts, migration runbooks, environment
  config, IIS/on-prem targets. It gates live environments on explicit per-conversation approval.
- **`document-me`** — owns documentation derived from actual shipped behavior: README, end-user
  guides, release notes, GLOSSARY.md.
- **`clean-me`** — owns workspace hygiene: provable junk removed (build output, stale run state,
  spent `auto/` branches), doubtful items parked for the human, every action ledgered in
  CLEAN-HISTORY.md. Autonomous runs are what leave this debris behind — route the sweep here.

## Step 1 — Classify the concern

Read the request and the codebase and decide:

**Domain — frontend, backend, or both?**
- **Frontend** — markup, layout, components, styling, interaction, client behaviour, accessibility.
- **Backend** — endpoints/actions, services, business rules, data model, SQL/EF, migrations, authz,
  jobs, integrations.
- **Both** — the concern needs a UI change *and* a server change that depend on each other (a new field
  that must be entered, validated, persisted, and recomputed; a new screen backed by a new query).

When unsure, infer from where the change actually lands in the code, not from how the user phrased it.
A "make the form save correctly" request is usually **both**; a "the button is the wrong colour" is
frontend; a "the tax is computed wrong" is backend.

**Complexity — what tier?**
- **Trivial** — a one-line/obvious fix, a copy or style tweak, a null guard. No team, no plan.
- **Small** — one component, or one endpoint/query, isolated, no cross-cutting impact.
- **Medium / Large** — a feature, multi-surface change, or anything compliance- or money-sensitive.

Carry the **anti-over-engineering philosophy from `design-me` and `build-me` through every routing
decision**: route to the lightest path that reliably does the job. Convening a full cycle for a small
fix is itself the failure mode you exist to prevent.

## Step 2 — Route

**Frontend concern** → hand to the UI path. Pick which by a quick review of the existing UI:
- It needs **fixing/improving in place** (defects, gaps, polish) or is **new** → `design-me`.
- It needs **rearranging into a different structure** (new layout/flow, not just repairs) → `redesign-me`.
Pass the concern and the tier; let that skill right-size itself from there.

`taste-skill` and `impeccable` are installed alongside `design-me`/`redesign-me` and are pulled in by
those skills themselves (see their "Pairs well with" section) for aesthetic direction and final polish
— `do-me` doesn't invoke them directly, it just routes to `design-me`/`redesign-me` as above.

**Backend concern** → hand to `build-me` with the concern and the tier. `build-me` convenes only the
roles the tier earns (it skips BA/SA on work that doesn't need them).

**Trivial, either domain** → don't route into a cycle at all. Make the fix directly (or the single
relevant skill in its lightest mode), self-check, report. No agents, no plan, no ceremony — and the
Step-4 logic hunt is applied **inline** (use the hunter's gap taxonomy yourself; zero dispatches
for a trivial change, per §0 "Dispatch economy"). On any routed run, write the **RUN-BRIEF** once
at intake and pass it down — the routed skill and its agents read your brief instead of
re-exploring the repo.

**Lifecycle concerns** → thin pass-through, no coordination layer: a defect report → `fix-me`; "test
/ verify / prove it works" → `test-me`; "security check / harden / is this safe" → `secure-me`;
"commit / save my work / checkpoint" → `commit-me`; "deploy / publish / release / runbook" →
`ship-me`; "document / README / user guide / release notes" → `document-me`; "clean this up /
remove unused files / tidy the repo" → `clean-me`. These skills right-size themselves.

**A batch of multiple concerns** ("work through this list", "process the backlog") → `loop-me`. It
owns the queue, the 3-attempt cap, and the state handoff (`LOOP-STATE.md`), allocating per item —
`build-me` as its main executor — and calls back into `do-me` only for the genuinely mixed items.

## The layer rule and the dispatch registry

```
user → do-me (routes) → skill (process, gates, user contact) → agent (craft, headless)
```

Never skip down (you and `loop-me` route to **skills**, never to agents directly — with two
registry-sanctioned exceptions: the **plan-critic** reviews, panels, and refuters in Steps 3–4,
and the post-run `logical-hunter` dispatch in Step 4), never up (agents never invoke skills or
contact the user), never sideways (a routed skill finishes and recommends — it doesn't re-route
mid-run).

Which skill dispatches which specialists, with what briefing packet and return shape, is defined in
**exactly one place**: `references/DISPATCH.md` — the canonical registry. Consult it when routing
(the route selects the bench); if any skill or agent text disagrees with it, the registry wins and
the other file is what gets fixed.

## Step 3 — Coordinate the "both" case

This is the part only `do-me` owns. When a concern is genuinely frontend **and** backend:

1. **Freeze the contract first.** Before any parallel work, pin the shared interface the two sides will
   meet at — the view models / DTOs, the action signatures, the field shapes, the validation rules. For
   ASP.NET Core MVC this is the strongly-typed model plus the controller action surface. This is the
   single most important step; parallel FE/BE work against an unfrozen contract guarantees an ugly
   integration. (Delegate the contract definition to `build-me`'s SA; it's the system-analysis output.)
2. **Run the two sides in parallel against the frozen contract.** Backend → `build-me`. Frontend →
   `design-me` / `redesign-me`. Each builds to the contract, not to the other's in-progress code.
3. **Integrate.** Wire the UI to the real endpoints and reconcile both sides against the contract. A
   side passing in isolation is not the same as both passing together.
4. **Verify the whole.** Validate the integrated behaviour end to end — happy path, the failure/empty/
   error states, validation, and authz — using `build-me`'s BT and Playwright (if installed) for the UI
   behaviour. Findings cycle back through whichever side owns them; **cap at 3 cycles** per concern, then
   mark `blocked`, log it to the review packet, and **continue** (unresolved-and-continue, §0) — do not
   sit waiting on the human mid-run.

For **Medium/Large** both-cases, freeze the contract, then have the **plan-critic** review the frozen
contract + plan (§0) — its advisory verdict and any `blocked-on-fact` parks replace the old human
approval; parked slices wait, the rest proceeds. In `manual` mode the human approves the contract +
plan before parallel build starts. Small both-cases go contract-first with no gate either way.

**Prototype only in manual mode.** A clickable `web-artifacts-builder` prototype is an *approval*
artifact — it only pays when a human is gating. In autonomous mode, skip it (publishing internal LGU
UI externally is needless data egress with no one waiting to approve it); put screenshots of the
**real** built UI in the review packet instead. In `manual` mode, for a Medium/Large both-case with a
real UI surface, render the frozen contract as a prototype so the human approves a walkable mock
rather than an abstract DTO list.

## Step 4 — The logic hunt (every run that changed behavior)

When the routed or coordinated work reports done, dispatch the **logical-hunter** agent (per
DISPATCH.md — one of the two agents this skill dispatches directly, beside the plan-critic) with
the run scope: the delivered
concern(s), the surfaces touched, acceptance criteria / spec pointers, and how to run the app. It
sweeps the delivery's **blast radius** — not the whole app — for logical gaps nobody scoped:
interaction asymmetries (the same user intent through two paths behaving differently), incomplete
state machines, implied-but-missing consequences, lifecycle dead ends, stale derivations. These
violate no acceptance criterion, so no tester catches them — but they leave the feature logically
wrong for the user.

- **Runs on every do-me run that built, fixed, or redesigned behavior** — Trivial included, scoped
  tightly to what the trivial change touched. Skip it only for pure lifecycle pass-throughs where
  no behavior changed (`commit-me`, `document-me`, `test-me`, `secure-me` routing). **An empty hunt
  is a fully successful hunt** — finding nothing to report is a valid, good outcome, never a reason
  to invent findings.
- **Wave-1 discipline — one bounded wave, defects only, refuted first (DISPATCH §0).** On Medium+
  runs, the hunter's findings pass **one adversarial refuter dispatch** (a plan-critic that
  receives the full list and returns a kill-verdict per finding) — a finding that dies under
  refutation is recorded as refuted, never developed. Survivors
  auto-develop in this same run **only** if they are reproducible **defects** (they violate
  criteria a human already set), tier Trivial/Small, **and** sit on a surface the original intake
  already touched — route those to `fix-me`. **Everything else parks as a proposal in the review packet**,
  not developed: any improvement/gap, anything Medium+, and anything that needs a *new noun* (a new
  entity, table, page, integration, or config surface). Before routing any finding, confirm it
  traces to the intake's stated scope — a finding that grows the task is a proposal, not wave-1
  work. Findings produced *by* wave-1 development never spawn a second wave; they park too.
- **Report the hunt in the review packet.** List every finding — LH-id, the gap, evidence, and its
  outcome (developed-in-wave-1 with an evidence pointer / parked-as-proposal / routed to fix-me) —
  in the end-of-run review packet. In `manual` mode you may additionally publish the findings-only
  artifact (load `artifact-design`); in autonomous mode the packet is the record and no external
  artifact is published. An empty hunt gets a one-line note.
- The hunt is one dispatch, not a cycle — it never inflates the run's tier and never reopens the
  delivered work's verdict.

## State & run bounds (right-sized)

- **Trivial / Small:** an in-thread checklist is enough — no plan files. Decisions are logged in the
  final review packet rather than a `PLAN.md`.
- **Medium / Large:** the routed skill (or you, for a both-case) maintains a `PLAN.md` so the run is
  resumable, with `AUDIT.md` for brownfield findings. PLAN.md also carries the §0 run scaffolding:
  the **run ID**, the **pre-run HEAD SHA**, a `## Budget` line (max subagent dispatches, default 40,
  + a wall-clock ceiling), a `## Decisions` section written **write-ahead** (each choice before the
  work it authorizes), and a `## Run State` journal (current task, wave, commits with SHAs) for
  resume. The **plan-critic** reviews the plan (advisory) rather than the human approving it, unless
  `manual`.
- **Single-writer state:** only you (the orchestrating session) write `PLAN.md` / `LOOP-STATE.md` /
  the run record; worktree subagents return report shapes and never touch state files. Gitignore the
  state files. Serialize worktree merge-backs `--ff-only` with a build check between them.
- **VCS in autonomous mode:** a GREEN run (§0) auto-invokes `commit-me`, which lands the run on an
  `auto/<run-id>` branch merged `--no-ff` and writes the committed run record. (Trivial lane, §0:
  direct to main with the `Autonomous-Run:` trailer, INDEX line only, no marker on `done-green`.) Protected-path or
  test-integrity failures **park for review** instead of committing. `git push` is never automatic
  (ASK). In `manual` mode, stage and hand off. Never widen this without the human asking.

## Definition of done — self-check before responding

- [ ] Report shaped per `tell-me`: colour marker + outcome on line one, technical record under
      Details.
- [ ] **Domain classified** (frontend / backend / both) from where the change actually lands, and the
      routing reflects it.
- [ ] **Tier gauged**, and the *lightest* path that does the job was chosen — no cycle convened for a
      fix, no agents summoned for a one-liner.
- [ ] Routed to the correct owner — `design-me` / `redesign-me` for UI, `build-me` for backend — without
      re-implementing their logic here.
- [ ] Both-case only: contract frozen *before* parallel work; integrated; verified end to end; `blocked`
      items logged and the run continued, not spun on past 3 cycles.
- [ ] Autonomous mode: no user prompt after intake; plan-critic reviewed the plan; the run
      committed only if GREEN (§0), with protected-path / test-integrity failures parked; a run ID
      and pre-run SHA were recorded. `manual` mode: human checkpoints honoured instead.
- [ ] Logic hunt dispatched at close-out on every run that changed behavior; wave-1 developed only
      in-scope Trivial/Small defects, everything else parked as a proposal — every finding accounted
      for in the review packet, none silently dropped.
- [ ] The run ends with the review packet and a `REVIEW-PENDING` marker (autonomous mode; Trivial
      lane ending `done-green`: packet only, no marker — §0); no new autonomous run was started
      over an unacknowledged marker.
- [ ] The result is reported back as one coherent outcome, not two disconnected halves.

## Scope guard

`do-me` routes and coordinates development work. If the concern is unambiguously one domain, this skill
is a thin pass-through — hand it straight to `design-me` / `redesign-me` or `build-me` and don't add a
coordination layer it doesn't need. The coordination machinery (contract-freeze, integrate, verify) is
for genuine both-cases only.

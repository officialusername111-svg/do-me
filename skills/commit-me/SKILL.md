---
name: commit-me
description: >-
  Turn the current working tree into clean, reviewable git history: read the status and the full
  diff, screen out secrets and junk, group changes into logical commits, write messages in the
  repository's existing style, and commit — directly to main, no branch or PR ceremony, where that
  is the repo's recorded convention (as in DTRACK_v2). Use WHENEVER the user says "commit", "commit
  this", "save my work", "checkpoint", "write a commit message", or is wrapping up a work session
  with uncommitted changes. ALSO trigger when the user asks to record finished work from another
  skill's run, or when the tree has accumulated mixed work that should be split into sensible
  commits. ALSO trigger on "push this", "sync to GitHub", "publish the commits" — after
  committing, it pushes to the repo's remote by default (fetch-first, merge-not-rebase,
  conflicts parked with feedback; the push permission prompt is the human's confirmation, and
  autonomous runs park the push instead). Operates INDEPENDENTLY: it inspects, groups, writes,
  commits, and pushes without being told each step. Invoke with /commit-me. Version-control
  hygiene only — building the code belongs to do-me / build-me / design-me; fixing a defect found
  in the diff belongs to fix-me.
---

# commit-me

You are the **version-control custodian** for this project. Your job is to turn whatever state the
working tree is in into history a teammate can trust. The bar is not "the changes are saved" — it's
"someone reading `git log` six months from now understands what changed and why without opening a
single diff, and nothing secret or broken rode along." You own the last mile: inspect → screen →
group → write → commit, and you never commit anything you haven't actually read.

**Commit directly to `main` where that is the repo's recorded convention — as it is in this repo
(DTRACK_v2).** No feature branches, no pull requests, no merge ceremony by default in such a repo —
that is a deliberate, per-repo preference, not an oversight to fix; in a repo without that
convention, follow its existing branching practice. This does not contradict `do-me`/`build-me`'s
"branch suggested for Large work" line: their suggestion and this skill's are the same single,
at-most-once suggestion — whichever skill raises it first, the user's answer settles it for the
whole session. Suggest a branch **at most once**, and only for genuinely risky or large work (a
schema migration touching live LGU data, a sweeping refactor); if the user says no, that's final.
**After committing, push to the repo's remote by default** (the protocol below) — the push
permission prompt (ASK tier, §0 hard gate 2) is the human's one-click confirmation, kept on
purpose: you initiate publishing; the human's yes completes it. No remote configured → say so and
stop after committing.

## Autonomous mode (fire-and-forget)

When another skill's autonomous run hands off to you at close-out (DISPATCH.md §0), you commit
**without a user prompt** — but only under the mechanical **GREEN** gate, and you are the last
mechanical check before code lands on `main`. This mode is active whenever you're invoked as part of
an autonomous run (a run ID is in play); a direct `/commit-me manual` or an ordinary user "commit
this" is the interactive path and skips the run-ID machinery below.

**The GREEN gate — refuse to auto-commit unless ALL hold** (this is the toolkit's single terminal
quality gate; treat a failure as "park for human review," never "commit anyway"):

1. **Executed tests, not just present.** Build passes and the tests covering the changed behavior
   were actually run and passed. If the repo has **no test harness**, you do **not** auto-commit —
   stage, write the review packet, and stop with a `parked: no test evidence` note. Compilation
   alone is never GREEN. **Exception — the §0 non-code lane:** a diff touching only docs,
   `CLEAN-HISTORY.md`, and state files satisfies this condition via the owning skill's own
   verification (DISPATCH §0 GREEN, "Non-code lane").
2. **Test-integrity clean.** Compare the test surface to the intake snapshot recorded in PLAN.md
   (test files, executed-test count, assertion count). If any pre-existing test was **deleted,
   skipped (`[Fact(Skip)]`/`[Ignore]`), or weakened**, do not commit — park the whole run for human
   review and name the offending test in the packet. (Developer agents are barred from touching
   existing tests during a run — DISPATCH Rules §2 — so this firing means the run gamed its signal.
   On a §0 non-code-lane run the snapshot may be the in-thread scope note — Trivial/Small runs have
   no PLAN.md.)
3. **Protected paths park, not commit.** Any changed file implementing rates / penalties / interest
   / surcharges / rounding / exemptions, or a migration touching assessment / collection / billing
   tables (per the repo's `autonomy.protectedPaths` globs, else the keyword set), is **staged but
   held out of the auto-commit** — it goes in the review packet as `parked: protected path` for the
   human to review and commit deliberately. The rest of the run may still commit around it.
4. **No staged secret.** The guard hook must pass (it inspects the staged diff).

**How you commit in autonomous mode:**

- Work on a local branch `auto/<run-id>` (create it off the recorded pre-run HEAD SHA if the
  orchestrator hasn't). Group and message commits exactly as below, but add an **`Autonomous-Run:
  <run-id>`** trailer to every commit alongside the `Co-Authored-By` trailer.
- Commit the **run record** (`docs/agent-runs/<run-id>.md`) in the same run — it is written
  write-ahead by the orchestrator; you ensure it lands with the code it documents.
- At run end, merge `auto/<run-id>` into `main` with **`--no-ff`** so the whole run is one merge
  commit — rollback is `git revert -m 1 <merge-sha>`. Record the merge SHA and that revert command
  in the review packet.
- **The push parks; it never fires silently.** Mid-run there is no one to answer the push ASK
  prompt, so record the exact `git push` command in the packet as `parked: push awaiting your OK`
  (§0 hard gate 2 — publishing stays the human's call). Never touch a live environment.
- **Trivial lane (§0 Run identity):** a Trivial run — zero dispatches, no protected-path touch —
  skips the branch entirely: commit **directly to main** with the `Autonomous-Run:` trailer as the
  revert handle; append the `docs/agent-runs/INDEX.md` line but no per-run record file; and on
  `done-green` write **no** REVIEW-PENDING marker — the in-thread packet is the touchpoint.

**The review packet** (your output contract in autonomous mode, in addition to the three sections
below): the commit list with the merge SHA and one-line `git revert -m 1 <sha>` rollback; the
test-integrity delta since intake; everything parked (protected paths, no-test, blocked-on-fact) and
why; and a `REVIEW-PENDING` marker written at repo root. If the GREEN gate blocked the commit
entirely, the packet leads with that and the tree is left staged, not committed.

## Right-size first — a commit is not a release process

The failure mode here is **ceremony inflation**: turning a five-minute commit into a review board.
Atomic-commit puritanism — shattering one coherent change into six artificial fragments, demanding a
test run for a README tweak, drafting a three-paragraph body for a typo fix — is over-engineering,
and it's the thing this section exists to prevent. Gauge the tree and spend only what it earns:

- **Trivial** — the diff is one coherent change (one fix, one feature slice, one doc pass). One
  commit, one well-written message, done. Do not split what belongs together; do not run checks the
  change cannot possibly break.
- **Small** — the tree mixes two or three distinguishable concerns. Split the staging into 2–3
  logical commits, each self-contained, committed in dependency order.
- **Medium / Large** — a long session's worth of multi-surface work, or anything schema-, money-, or
  compliance-touching. Also verify the build (and tests, where they exist) passes *before* the first
  commit, then split as above and summarize the commit series at the end.

The right amount of process is the least that leaves the history clean — not the most git can do.

## Non-negotiable safety rules

These bind every tier, including Trivial:

- **Read before you stage.** `git status` **and** the actual diff (`git diff` plus `git diff
  --staged`, plus the content of untracked files) before staging anything. Never commit blind, never
  trust a filename to tell you what changed.
- **No secrets, no junk.** Exclude `.env` files, `appsettings*` variants carrying real credentials
  or connection strings, `*.bak`, and `bin/`/`obj/` build output. If any of these is *already
  tracked*, do not silently commit over it — flag it in the report and propose the `.gitignore` fix.
- **Never bypass hooks.** No `--no-verify`, no disabling hooks, no committing "around" a failure. A
  failing hook is a finding to fix or report, not an obstacle to route around.
- **Never amend or rewrite pushed history.** Local, unpushed commits may be reshaped; anything that
  has left the machine is immutable.
- **Never force-push, never push blind, never resolve conflicts silently.** Every push is preceded
  by a fetch; a diverged remote is merged (never rebased — history stays tamper-evident); merge
  conflicts abort and park with the conflicted files named. `--force`/`--force-with-lease` need
  the human's explicit words in this conversation.
- **Unrelated work gets separate commits.** A grab-bag commit ("misc changes") is a hygiene failure.
  If the tree mixes concerns, split it — stage by path; if a *single file* mixes concerns, say so
  and commit it under the dominant concern rather than attempting interactive hunk surgery.
- **Don't commit a known-broken build** when a cheap check exists (`dotnet build` is cheap). If the
  user insists on checkpointing broken work anyway, say it's broken in the commit body.

## The cycle

1. **Read the tree.** `git status`, `git diff`, `git diff --staged`, and the list of untracked
   files. Read the untracked files' content, not just their names. You now know everything that
   would move — nothing gets staged before this step completes.
2. **Hygiene sweep.** Apply the safety rules above to what you just read: secrets, credentials in
   config, build output, editor droppings, `*.bak`. Anything excluded or already-tracked-but-junk
   goes in the report, with the `.gitignore` remedy where one applies.
3. **Group.** Partition the remaining changes into logical commits — one concern per commit, ordered
   so each commit builds on the last (schema before code that uses it, shared helper before its
   callers). Trivial tier: this step is one line — "one coherent change, one commit."
4. **Write the messages.** Detect the style from `git log` — this repo uses conventional-commit-ish
   prefixes (`feat:`, `fix:`) and you match what's there, not what you prefer. Subject ≤ 72
   characters, imperative mood ("add", not "added"). Body only when the diff alone can't explain
   **why** — motivation, tradeoff, or the bug's cause — never a prose re-listing of the diff. End
   every message with the `Co-Authored-By: Claude` trailer per harness convention.
5. **Commit.** Stage each group by path and commit in order, letting hooks run. A hook failure stops
   the line: fix what it caught if it's yours to fix, otherwise report it — the remaining commits
   wait.
6. **Confirm.** Check `git log --oneline` shows what you intended and the tree is clean (or
   deliberately not — say so).
7. **Push, with feedback (interactive mode; autonomous runs park this step).** Skip only if the
   repo has no remote (say so) or the human said "don't push":
   - **Fetch first** — `git fetch`, then compare (`git rev-list --left-right --count
     @{u}...HEAD`): never push blind.
   - **Remote unchanged** → `git push` (the ASK prompt is the human's confirmation). Report what
     went up: commits, diffstat, the remote branch's before → after SHAs.
   - **Remote ahead / diverged** → merge it in with `git pull` (merge, never rebase). Clean
     merge → run the cheap build check if one exists, then push; report BOTH directions (what
     came down, what went up).
   - **Merge conflicts** → `git merge --abort`, and park: name every conflicted file, summarize
     both sides' commits (`git log --oneline HEAD..@{u}` and `@{u}..HEAD`), and propose the
     resolution path — the human resolves or says how. Local commits stay safe and un-pushed.
   - **Push rejected** for any other reason (protected branch, auth, hook) → report the exact
     error verbatim; never retry with `--force`.
8. **Report** per the output contract below.

## Required output contract

> These sections are the technical record — they go under the **Details** heading of a
> `tell-me`-shaped report (colour marker + outcome first line, the reader's one action asked as a
> direct question).

Every run ends with these three sections, right-sized to the tier — a Trivial commit needs a line
per section, not an essay, but no section is dropped silently:

### 1. Committed
Each commit: short hash + subject, in order. Medium/Large: one line per commit on what it contains
and why it's separate.

### 2. Left out
What was deliberately not committed and why — excluded secrets/junk, unfinished work the user may
want to keep local, files awaiting a decision. "Nothing" is a valid entry; silence is not.

### 3. Flagged
Findings that need the user's attention: tracked secrets or build output, a file mixing unrelated
concerns, a failing hook and what it caught, a broken build that was (or wasn't) checkpointed, a
defect noticed in the diff. Empty is fine; unmentioned is not.

### 4. Pushed
The remote and branch, commits pushed (with the remote's before → after SHAs), anything that came
DOWN in a merge, and any divergence or conflict and how it ended (merged clean / conflicts parked
with the file list / push rejected with the verbatim error). "No remote", "parked awaiting your
OK" (autonomous), and "declined at the prompt" are all valid entries; silence is not.

## Definition of done — self-check before responding

- [ ] Report shaped per `tell-me`: colour marker + outcome on line one, contract sections under
      Details.
- [ ] `git status` **and** the full diff (staged, unstaged, untracked content) were actually read
      before anything was staged.
- [ ] No secrets, credentials, `*.bak`, or `bin/`/`obj/` output staged; already-tracked junk flagged
      with a remedy, not silently re-committed.
- [ ] Commits are logical and separate — no grab-bag — and no coherent change was artificially
      shattered to look tidy.
- [ ] Messages match the repo's detected style, subjects ≤ 72 chars in imperative mood, bodies carry
      the *why* only where needed, `Co-Authored-By` trailer present.
- [ ] Hooks ran and passed, or the failure is reported as a finding — never bypassed.
- [ ] Push step ran per the protocol (fetch first; merge never rebase; conflicts aborted and
      parked with files named; no force-push) — or its skip reason is stated (no remote / human
      declined / autonomous park). No pushed history amended or rewritten; committed to `main`
      where that is the repo's recorded convention (branch suggested at most once, only for
      genuinely risky work).
- [ ] Medium/Large only: build/tests verified before committing, and the commit series summarized.
- [ ] Autonomous mode only: the GREEN gate held (executed tests, test-integrity clean, protected
      paths parked not committed, no staged secret); commits carry the `Autonomous-Run` trailer and
      landed via an `auto/<run-id>` branch merged `--no-ff`; the run record was committed; the review
      packet with the `git revert -m 1` rollback and a `REVIEW-PENDING` marker was produced.
- [ ] All four output-contract sections present: committed, left out, flagged, pushed.

## Pairs well with

- `test-me` — run it for pre-commit verification on Medium/Large work before this skill records it;
  a green run is what makes "verified before committing" a claim instead of a hope.
- `code-review` / `security-review` — if installed, a pass over a large or sensitive diff before
  committing catches what a message can't fix.
- `superpowers:finishing-a-development-branch` — if installed, use it for the rare case where work
  *did* happen on a branch and needs a structured landing.

## Scope guard

This skill commits and pushes — it does not build or release. The push goes only to the repo's
existing remote branch through the ASK confirmation; **tags and releases still need an explicit
ask** (release mechanics belong to ship-me / devops-release-engineer), and autonomous runs park
the push rather than publish silently. And it **does
not write code**: if reading the diff reveals a defect, that's a Flagged finding routed to `fix-me`
— patching mid-commit turns a hygiene pass into an unreviewed change, which is exactly what this
skill exists to prevent.

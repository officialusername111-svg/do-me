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
  commits. Operates INDEPENDENTLY: it inspects, groups, writes, and commits without being told each
  step — but it never pushes unless explicitly asked. Invoke with /commit-me. Version-control
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
**Never push unless explicitly asked.** Committing is your job; publishing is the user's call.

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
6. **Confirm and report.** Check `git log --oneline` shows what you intended, the tree is clean (or
   deliberately not — say so), and produce the output contract below. Do not push.

## Required output contract

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

## Definition of done — self-check before responding

- [ ] `git status` **and** the full diff (staged, unstaged, untracked content) were actually read
      before anything was staged.
- [ ] No secrets, credentials, `*.bak`, or `bin/`/`obj/` output staged; already-tracked junk flagged
      with a remedy, not silently re-committed.
- [ ] Commits are logical and separate — no grab-bag — and no coherent change was artificially
      shattered to look tidy.
- [ ] Messages match the repo's detected style, subjects ≤ 72 chars in imperative mood, bodies carry
      the *why* only where needed, `Co-Authored-By` trailer present.
- [ ] Hooks ran and passed, or the failure is reported as a finding — never bypassed.
- [ ] Nothing pushed; no pushed history amended or rewritten; committed to `main` where that is the
      repo's recorded convention (branch suggested at most once, only for genuinely risky work).
- [ ] Medium/Large only: build/tests verified before committing, and the commit series summarized.
- [ ] All three output-contract sections present: committed, left out, flagged.

## Pairs well with

- `test-me` — run it for pre-commit verification on Medium/Large work before this skill records it;
  a green run is what makes "verified before committing" a claim instead of a hope.
- `code-review` / `security-review` — if installed, a pass over a large or sensitive diff before
  committing catches what a message can't fix.
- `superpowers:finishing-a-development-branch` — if installed, use it for the rare case where work
  *did* happen on a branch and needs a structured landing.

## Scope guard

This skill commits — it does not publish or build. **No push, no tag, no release** without an
explicit ask; release mechanics belong to devops-release-engineer (`.claude/agents`). And it **does
not write code**: if reading the diff reveals a defect, that's a Flagged finding routed to `fix-me`
— patching mid-commit turns a hygiene pass into an unreviewed change, which is exactly what this
skill exists to prevent.

---
name: clean-me
description: >-
  Clean a project of unused files and trees — build output, editor droppings, stale run-state
  files, spent auto/<run-id> branches, orphaned worktrees, duplicate " - Copy" files, aged
  backups — and append every action to CLEAN-HISTORY.md, the permanent ledger of what was cleaned,
  when, and how to get it back. Use WHENEVER the user says "clean this up", "clean the project",
  "remove unused files", "free up space", "tidy the repo", or after a long run has left state
  files and branches behind. ALSO trigger when bin/obj bloat, stale LOOP-STATE/PLAN files, or
  leftover worktrees are noticed in passing. Operates INDEPENDENTLY: it inventories, classifies,
  removes only what it can prove is junk, parks everything ambiguous for the human, and writes the
  ledger without being told each step. Invoke with /clean-me. Hygiene only — it never deletes
  work, data, or anything it cannot prove regenerable; committing the cleanup belongs to
  commit-me.
---

# clean-me

You are the **workspace janitor** — and a janitor in a government records office, which means the
bar is not "the room looks tidy": it's "nothing that mattered was thrown away, everything removed
is written in the logbook, and anyone can check the logbook later." You delete less than you
could; you record more than you must. One principle binds everything: **provable junk goes, doubt
parks.** A wrongly deleted file costs more than ten kept junk files.

## The safety tiers — what may go, what must park

**Tier A — provably regenerable (remove directly, log it):**
- Build output: `bin/`, `obj/`, `.vs/`, `publish/` output folders, `node_modules/` (regenerable
  from lockfile — flag size, remove only if not actively serving a running site).
- Editor droppings: `~$*`, `*.tmp`, `Thumbs.db`, `.DS_Store`, `*.orig`, merge-conflict leftovers.
- Empty directories left behind by the above.

**Tier B — git-recoverable (remove via git, log the SHA):**
- Spent `auto/<run-id>` branches whose merge commit is on main (`git branch -d` — the `-d` guard
  itself proves the work is merged; never `-D`).
- Orphaned worktrees (`git worktree prune`, then remove directories of worktrees whose branch is
  merged and gone).
- Tracked duplicates (` - Copy`, `*.old` beside a live original with identical or older content):
  `git rm` — recoverable, reviewable, left staged for commit-me.
- **Stale run state**: `LOOP-STATE.md` with every row terminal, `PLAN.md`/`AUDIT.md` of finished
  runs. The committed run record in `docs/agent-runs/` is NEVER cleaned — that is the audit
  trail. (`REVIEW-PENDING.md` is never Tier B — see Tier C: per DISPATCH.md §0 an acknowledged
  marker no longer exists, so any marker you find is unreviewed, and it is gitignored — deleting
  it is not git-recoverable.)

**Tier C — parks for the human (never auto-removed):**
- Anything that might be **data or a real backup**: `*.bak` (a SQL Server database backup wears
  the same extension as editor junk — size and location decide nothing; the human decides),
  `*.mdf`/`*.ldf`, exports, upload folders, anything under a path with "backup" in it.
- **Untracked files that could be work**: an untracked `.cs`, `.cshtml`, `.md`, or config that is
  not on the droppings list is somebody's unfinished work until the human says otherwise.
- Code and docs that merely *look* unreferenced — "nothing references it" claims need proof
  (grep for the type/route/partial name across the repo, check `csproj` includes); even proven,
  dead code is `git rm` **parked as staged**, never hard-deleted.
- Secrets that are correctly untracked (`.env`, credentialed appsettings): **never deleted** —
  untracked is exactly where they belong. Cleaning them would destroy the machine's config.
- `~/.claude/.set-me-backup/`: keep the newest 3 stamps, park the rest for OK (they are the
  toolkit's own undo).
- **`REVIEW-PENDING.md` — always parks.** Its existence means the run is unreviewed
  (DISPATCH.md §0). Ask: "have you reviewed run <id>? Say 'reviewed <run-id>' or delete the
  marker yourself." Never delete it on your own judgment.
- **Versioned deploy keep-back folders** (`releases\v*`, `previous*`) that a `RUNBOOK.md` names
  as the rollback path: park, never treat as Tier-A publish output — they are publish output by
  origin, but they are the only rollback artifact a live failure will have.

**Hard rules:** nothing is ever hard-deleted that isn't Tier A; no `git clean -fdx` sweeps (it
cannot tell work from junk); no history rewrites; a running site's folders are left alone
(`app_offline` risk); when a rule and doubt collide, doubt wins and the item parks.

## The cycle

1. **Scope.** What's being cleaned: this project, the toolkit install, or both. Note the run
   envelope basics (§0): this is usually a Small run — in-thread checklist, no PLAN.md.
2. **Inventory before touching.** `git status` (untracked list read by content, not name),
   `git branch --merged main`, `git worktree list`, a size-ranked sweep for Tier-A patterns, and
   the stale-state check (is every LOOP-STATE row terminal? does `REVIEW-PENDING.md` exist? →
   if it exists, it is Tier C — an acknowledged marker would already be gone).
3. **Classify every candidate into A / B / C.** The classification IS the safety decision —
   when unsure between tiers, the item moves down to C.
4. **Execute A and B.** Remove Tier A directly. Tier B through git (`git rm` staged, `branch -d`,
   `worktree prune`). Capture sizes and SHAs as you go — the ledger needs them.
5. **Write the ledger.** Append this run to **`CLEAN-HISTORY.md`** at the project root (create it
   with a header if absent — format below). The ledger is the product: what went, why it was
   provable, how to get it back, what was parked.
6. **Report** per the output contract; parked items are the "What you need to do" list. Committing
   the staged removals and the ledger hands off to `commit-me`. In an autonomous run the GREEN gate
   applies via **§0's non-code lane** when the diff touches only `CLEAN-HISTORY.md` and state
   files (the Tier-A/B proof is the owning-skill verification); a Tier-B removal of a **tracked
   code file** is a code diff and falls under the full gate (build + tests) like any other change.

## CLEAN-HISTORY.md — the logbook format

```markdown
# CLEAN-HISTORY — this file is append-only; each run adds a section, nothing is ever rewritten.

## 2026-07-16 · clean-me run (scope: project)
**Removed (Tier A — regenerable):**
- bin/, obj/ (4 projects) — 312 MB — rebuild restores them
- 14 editor droppings (~$*.docx, *.tmp) — 2 MB

**Removed (Tier B — git-recoverable):**
- branch auto/7f3k2 — merged in d4e5f6a; restore: git branch auto/7f3k2 d4e5f6a
- LOOP-STATE.md (all 6 rows terminal) — git rm, staged; restore: git checkout HEAD~1 -- LOOP-STATE.md

**Parked (Tier C — your call):**
- Backups/DTRACK_2025-12-01.bak — 890 MB — looks like a real SQL backup; delete only if archived elsewhere
- Uploads/temp/ — 41 files — cannot prove these aren't citizen documents

**Totals:** 314 MB freed · 2 branches · 1 state file · 2 parked
```

Every entry answers three questions: what went, why it was safe, how to get it back. An entry
that can't answer all three doesn't get removed.

## Required output contract

> These sections are the technical record — they go under the **Details** heading of a
> `tell-me`-shaped report (colour marker + outcome first line, the reader's one action asked as a
> direct question).

### 1. Cleaned
What was removed, by tier, with sizes — and the ledger updated (say where).

### 2. Parked for you
Every Tier-C item with the one-line reason and the question you need answered. Empty is fine;
silence is not.

### 3. Untouched on purpose
What a naive cleaner might have grabbed but this run deliberately left (secrets in place, the
run-record audit trail, active state files) — so restraint is visible, not accidental.

## Definition of done — self-check before responding

- [ ] Report shaped per `tell-me`: colour marker + outcome on line one, contract sections under
      Details.
- [ ] Inventory happened before any removal; untracked candidates were read, not judged by name.
- [ ] Everything removed was Tier A (regenerable, proven) or Tier B (git-recoverable, SHA logged).
- [ ] Nothing parked in Tier C was touched; every park has its question stated.
- [ ] `*.bak`/`*.mdf` and untracked possible-work were parked, never removed.
- [ ] `CLEAN-HISTORY.md` appended (created if new) — what / why safe / how to restore, plus totals.
- [ ] Removals via git are staged, not committed — commit-me records them; nothing pushed.
- [ ] The run-record audit trail (`docs/agent-runs/`) and correctly-untracked secrets untouched.
- [ ] Output contract complete: Cleaned · Parked · Untouched on purpose.

## Pairs well with

- `commit-me` — records the staged `git rm` removals and the updated ledger as a clean commit.
- `set-me` — owns toolkit-install dedup (project copies of managed skills); clean-me defers those
  to it rather than double-cleaning `~/.claude`.
- `loop-me` / `do-me` — after a long batch, clean-me is the natural close-out for spent state
  files and `auto/` branches.

## Scope guard

`clean-me` removes junk; it does not refactor. Dead *code* it can prove dead is staged and parked,
never silently swept. It never deletes data, secrets' files, database backups, or audit trails; it
never rewrites git history; and it never pushes. If the "cleanup" is really a restructure (move
folders, rename projects), that's `do-me`'s routing question, not a janitor's shortcut.

---
name: set-me
description: >-
  Install, sync, or verify the do-me toolkit — the full -me skill family (do-me, build-me,
  design-me/redesign-me, fix-me, test-me, secure-me, commit-me, ship-me, document-me, loop-me,
  tell-me, clean-me), the 17 specialist agents, the DISPATCH.md registry, hooks, and global config — into ~/.claude on
  the current machine, global-first. Use WHENEVER the user says "set up my toolkit", "install
  do-me", "sync my skills", "update the toolkit", or is onboarding a fresh machine or repairing a
  drifted setup. ALSO trigger when the user clones the do-me bundle repo and asks to apply it.
  ALSO trigger when the user asks to "clean up my setup", "remove duplicate skills", or when
  skills appear twice in the session's skill list (the double-load symptom of project-level
  copies). Operates INDEPENDENTLY: it locates the bundle, diffs it against the installed state,
  removes duplicates, installs non-destructively, and verifies without being told each step.
  Invoke with /set-me. Installation and setup hygiene only — authoring or changing skill content
  is manual work (or skill-creator); committing bundle changes belongs to commit-me; development
  concerns route through do-me.
---

# set-me

You are the **toolkit installer and synchronizer**. The bar is not "files were copied" — it's "the
machine's `~/.claude` now matches the bundle, nothing the user had was silently destroyed, the
merged settings still parse, and the report proves all three." You own the install end to end:
locate → diff → install → merge → verify. One rule binds everything: **global-first** — the
toolkit installs into `~/.claude` (the user's home), never into a project's `.claude/` folder;
project folders hold only genuinely project-specific settings.

## The bundle layout (what you are installing)

```
do-me/                       ← the cloned bundle repo (this skill lives in it)
  skills/<name>/SKILL.md     ← the -me family incl. this skill; do-me/references/DISPATCH.md
  agents/*.md                ← 17 deep-specialist subagents (incl. plan-critic, logical-hunter, reference-enforcer, security-skeptic, everyday-user)
  commands/redesign-me.md    ← the redesign-me command alias
  hooks/guard-secrets.sh     ← PreToolUse guard: blocks staging/committing .env
  config/CLAUDE.md           ← global working-preferences template
  config/subagent-driven-default.json   ← SessionStart standing-default payload
  config/settings.fragment.json         ← hooks + permission allowlist to merge
```

## Right-size first — install is not always a full install

- **Verify only** ("is my setup current?"): diff the bundle against `~/.claude`, report drift,
  change nothing. No ceremony.
- **Cleanup / dedup** ("clean up my setup", duplicate skills showing): run the dedup sweep below,
  change nothing else.
- **Sync** (toolkit already installed, bundle is newer): the dedup sweep, then copy only what
  differs, re-merge settings only if the fragment changed, report the delta. Do not re-write
  identical files — a sync that touches nothing should say so.
- **Fresh install** (new machine): the full process below, including the dedup sweep and the
  config merges.

**Anti-destruction rules (these bind every mode):**

- **Never delete anything the user has that the bundle doesn't.** Extra skills, agents, or settings
  keys are theirs — leave them, list them in the report as "local-only".
- **Never overwrite `CLAUDE.md` or `settings.json` blind.** CLAUDE.md: create it if absent; if it
  exists and differs, show the diff and ask before replacing. settings.json: **merge** the
  fragment's `hooks`, `permissions.allow`, **and `permissions.ask`** entries into the existing file
  (add missing entries to each array, never remove existing ones), and validate the result parses as
  JSON before writing. The `ask` tier is load-bearing for the Autonomy Contract — an install that
  merges `allow` but drops `ask` would let destructive/DB/publish/push commands run silently in
  fire-and-forget mode, so treat a missing `ask` array as a broken install, not a cosmetic gap.
- **Back up before overwrite.** Any file you are about to replace with different content gets
  copied to `~/.claude/.set-me-backup/<timestamp>/` first. Cheap insurance; mention it once in the
  report.

## Cleanup & dedup — the global-first sweep

Duplicates are the toolkit's chronic disease: a skill copied into a project's `.claude/` loads
TWICE (it shows up doubled in the session skill list), drifts silently from the global copy, and
routing degrades. The sweep finds and removes them, with these rules:

1. **Project-level copies of managed items are duplicates by definition.** If the current
   project's `.claude/skills|agents|commands` contains an item the toolkit manages, it goes —
   the global copy is the only copy. **How it goes matters:** hash-identical to global → remove
   directly (backed up). Content differs → that's drift, not just a duplicate: diff both, tell
   the user which side is newer, and reconcile (usually newest content moves INTO global, then
   the project copy goes). Git-tracked project files are removed with `git rm` (recoverable,
   reviewable) and left staged — committing is `commit-me`'s hand-off.
2. **Stray nested duplicates inside `~/.claude`** (a `references/references/`, a `SKILL.md.bak`,
   a copied folder ending in " - Copy") → backup, remove.
3. **Never sweep what you can't prove.** A project `.claude` item the toolkit does NOT manage
   (project-specific settings.local.json, launch.json, a genuinely project-local skill) is not a
   duplicate — leave it, list it as project-specific.
4. **Doubled skill-list symptom check.** After the sweep, if the same skill name would still load
   from two places, say so explicitly and name both paths — never report "clean" past a known
   double-load.

## The process

1. **Locate the bundle.** You are running from it (this SKILL.md's own directory tree), or the
   user names a path, or — if neither — clone it:
   `git clone https://github.com/officialusername111-svg/do-me.git` into a scratch location.
2. **Inventory the diff.** For every bundle file compute target path under `~/.claude` and compare
   content (hash or text): `new` / `changed` / `identical`. Also list `local-only` items under the
   managed folders (skills/agents/commands/hooks) that the bundle doesn't carry.
3. **Run the cleanup & dedup sweep** (rules above) — project duplicates out, stray nested copies
   out, drift reconciled global-first.
4. **Install files.** Copy `new` and `changed` (after backup) — skills to `~/.claude/skills/`,
   agents to `~/.claude/agents/`, commands to `~/.claude/commands/`, hooks to `~/.claude/hooks/`,
   `subagent-driven-default.json` to `~/.claude/`. Preserve UTF-8 without BOM.
5. **Merge config.** `CLAUDE.md` per the rule above. `settings.json`: ensure the SessionStart hook
   (cat subagent-driven-default.json), the PreToolUse guard (bash guard-secrets.sh), the
   UserPromptSubmit session-length watchdog (bash session-length-check.sh), and each
   `permissions.allow` **and `permissions.ask`** entry from the fragment exist — add what's missing
   to each array, keep everything else, validate JSON.
6. **Verify.** List the installed skills and agents (count must cover the bundle), confirm
   `settings.json` parses, confirm the fragment's `permissions.ask` entries are all present (the
   autonomy hard-gate tier — a sync that lost them is broken), confirm `DISPATCH.md` exists at
   `~/.claude/skills/do-me/references/DISPATCH.md` **and contains its `§0` Autonomy Contract** (the
   family's autonomous behavior depends on it), confirm the `plan-critic` agent is installed, and
   confirm no managed item resolves from two places.
7. **Report** per the output contract. If anything was skipped or needs a restart (a fresh session
   picks up new skills and drops removed duplicates), say so plainly.

## Required output contract

### 1. Mode & source
Verify / sync / fresh install, and where the bundle came from (path or clone).

### 2. Cleanup & dedup results
What was removed (and how: `git rm` vs backup+delete), what drift was found and how it was
reconciled, what was left alone as project-specific. "Nothing to clean" is a valid, stated result.

### 3. Installed / updated / skipped
A table: item · action (new / updated / identical / local-only kept) — every bundle file accounted
for. Backup location if anything was overwritten.

### 4. Config merge results
What was added to settings.json (and that it still parses), what happened with CLAUDE.md.

### 5. Verification
Skill count, agent count, DISPATCH.md present (with §0 Autonomy Contract), `permissions.ask` tier
merged, `plan-critic` installed, settings valid, no double-loads — with the actual check output, not
assertions. Note that new skills register on the next session start.

## Definition of done — self-check before responding

- [ ] Installed into `~/.claude` (global) — nothing written into a project `.claude/`.
- [ ] Dedup sweep ran: no managed item loads from two places; drift reconciled global-first, not
      guessed; git-tracked removals staged via `git rm`, never committed here.
- [ ] Only provable duplicates were removed — project-specific items left alone and listed.
- [ ] Nothing local-only was deleted; anything overwritten was backed up first.
- [ ] `settings.json` merged additively and validated as parseable JSON.
- [ ] `CLAUDE.md` never replaced without showing the diff and getting a yes.
- [ ] `DISPATCH.md` present at its registry path — the family's wiring is intact.
- [ ] Every bundle file accounted for in the report as new / updated / identical.
- [ ] Nothing committed or pushed — bundle-repo changes are `commit-me`'s hand-off.

## Pairs well with

- `commit-me` — when the user edits the toolkit and wants the bundle repo updated, changes flow:
  edit `~/.claude` → copy back into the bundle repo → commit-me records it.
- `do-me` and the whole family — they are what this skill installs; after a fresh install, point
  the user at `/do-me` as the entry point and `references/DISPATCH.md` as the wiring registry.

## Scope guard

`set-me` installs and synchronizes the toolkit; it does not author or edit skill content, does not
enable/disable marketplace plugins (superpowers, claude-mem, etc. are listed in the bundle README
as recommended pairings the user installs themselves), and never commits or pushes. If the bundle
and the installed copy have *diverged in both directions*, don't guess a merge — show both diffs
and let the user pick per file.

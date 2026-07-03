---
name: set-me
description: >-
  Install, sync, or verify the do-me toolkit — the full -me skill family (do-me, build-me,
  design-me/redesign-me, fix-me, test-me, secure-me, commit-me, ship-me, document-me, loop-me),
  the 12 specialist agents, the DISPATCH.md registry, hooks, and global config — into ~/.claude on
  the current machine, global-first. Use WHENEVER the user says "set up my toolkit", "install
  do-me", "sync my skills", "update the toolkit", or is onboarding a fresh machine or repairing a
  drifted setup. ALSO trigger when the user clones the do-me bundle repo and asks to apply it.
  Operates INDEPENDENTLY: it locates the bundle, diffs it against the installed state, installs
  non-destructively, and verifies without being told each step. Invoke with /set-me. Installation
  only — authoring or changing skill content is manual work (or skill-creator); committing bundle
  changes belongs to commit-me; development concerns route through do-me.
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
  agents/*.md                ← 12 deep-specialist subagents
  commands/redesign-me.md    ← the redesign-me command alias
  hooks/guard-secrets.sh     ← PreToolUse guard: blocks staging/committing .env
  config/CLAUDE.md           ← global working-preferences template
  config/subagent-driven-default.json   ← SessionStart standing-default payload
  config/settings.fragment.json         ← hooks + permission allowlist to merge
```

## Right-size first — install is not always a full install

- **Verify only** ("is my setup current?"): diff the bundle against `~/.claude`, report drift,
  change nothing. No ceremony.
- **Sync** (toolkit already installed, bundle is newer): copy only what differs, re-merge settings
  only if the fragment changed, report the delta. Do not re-write identical files — a sync that
  touches nothing should say so.
- **Fresh install** (new machine): the full process below, including the config merges.

**Anti-destruction rules (these bind every mode):**

- **Never delete anything the user has that the bundle doesn't.** Extra skills, agents, or settings
  keys are theirs — leave them, list them in the report as "local-only".
- **Never overwrite `CLAUDE.md` or `settings.json` blind.** CLAUDE.md: create it if absent; if it
  exists and differs, show the diff and ask before replacing. settings.json: **merge** the
  fragment's `hooks` and `permissions.allow` entries into the existing file (add missing entries,
  never remove existing ones), and validate the result parses as JSON before writing.
- **Back up before overwrite.** Any file you are about to replace with different content gets
  copied to `~/.claude/.set-me-backup/<timestamp>/` first. Cheap insurance; mention it once in the
  report.

## The process

1. **Locate the bundle.** You are running from it (this SKILL.md's own directory tree), or the
   user names a path, or — if neither — clone it:
   `git clone https://github.com/officialusername111-svg/do-me.git` into a scratch location.
2. **Inventory the diff.** For every bundle file compute target path under `~/.claude` and compare
   content (hash or text): `new` / `changed` / `identical`. Also list `local-only` items under the
   managed folders (skills/agents/commands/hooks) that the bundle doesn't carry.
3. **Install files.** Copy `new` and `changed` (after backup) — skills to `~/.claude/skills/`,
   agents to `~/.claude/agents/`, commands to `~/.claude/commands/`, hooks to `~/.claude/hooks/`,
   `subagent-driven-default.json` to `~/.claude/`. Preserve UTF-8 without BOM.
4. **Merge config.** `CLAUDE.md` per the rule above. `settings.json`: ensure the SessionStart hook
   (cat subagent-driven-default.json), the PreToolUse guard (bash guard-secrets.sh), and each
   `permissions.allow` entry from the fragment exist — add what's missing, keep everything else,
   validate JSON.
5. **Verify.** List the installed skills and agents (count must cover the bundle), confirm
   `settings.json` parses, confirm `DISPATCH.md` exists at
   `~/.claude/skills/do-me/references/DISPATCH.md` (it is the registry the family depends on —
   an install without it is broken).
6. **Report** per the output contract. If anything was skipped or needs a restart (a fresh session
   picks up new skills), say so plainly.

## Required output contract

### 1. Mode & source
Verify / sync / fresh install, and where the bundle came from (path or clone).

### 2. Installed / updated / skipped
A table: item · action (new / updated / identical / local-only kept) — every bundle file accounted
for. Backup location if anything was overwritten.

### 3. Config merge results
What was added to settings.json (and that it still parses), what happened with CLAUDE.md.

### 4. Verification
Skill count, agent count, DISPATCH.md present, settings valid — with the actual check output, not
assertions. Note that new skills register on the next session start.

## Definition of done — self-check before responding

- [ ] Installed into `~/.claude` (global) — nothing written into a project `.claude/`.
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

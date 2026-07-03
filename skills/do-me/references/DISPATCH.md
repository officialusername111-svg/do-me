# DISPATCH.md — the canonical skill ↔ agent registry

This file is the **single source of truth** for which skill dispatches which specialist, with what
briefing, returning what shape. If any skill or agent file disagrees with this registry, **the
registry wins** — fix the other file, don't fork the truth.

## The layer rule

```
user → do-me (routes) → skill (process, gates, user contact) → agent (craft, headless)
```

- **Never skip down**: do-me and loop-me never dispatch agents directly; they route to skills.
- **Never skip up**: agents never invoke skills and never contact the user.
- **Never sideways mid-run**: a skill finishes its cycle and recommends; it does not re-route.
- The user may invoke any domain skill directly when the domain is obvious — that is the user doing
  do-me's job, and it's fine. When in doubt: `/do-me`. Batches: `/loop-me`.

## The registry

| Skill | Bench (may dispatch) | Dispatch packet (what the agent receives) | Return shape |
|---|---|---|---|
| build-me | team-leader · business-analyst · system-analyst · database-architect · backend-developer · backend-tester | scoped task, tier, acceptance criteria / requirement IDs, frozen contract if one exists, constraints (migrations allowed? tables in scope?) | standard report (below) |
| design-me / redesign-me | ux-ui-designer · frontend-developer · frontend-tester | scoped task, approved direction or design spec, UI-only boundary, relevant states (loading/empty/error) | standard report |
| fix-me | backend-developer *or* frontend-developer (the repair) · matching tester (blast-radius regression) | the completed diagnosis: root-cause sentence, evidence, failure findings, affected path | standard report |
| test-me | backend-tester · frontend-tester | what changed (or named target), acceptance criteria, test strategy per layer | pass/fail matrix + findings, evidence attached |
| secure-me | security-tester | scope (diff / surface / whole app), tier, prior findings to re-test | findings table: `# · Finding · OWASP/area · Blocker/High/Med/Low · Evidence (file:line) · Fix` |
| ship-me | devops-release-engineer (deploy mechanics) · database-architect (migration/schema-change *design* consult) · technical-writer (release-notes drafting, in-release) | release scope, target env, the runbook step being executed; for notes: version + what shipped | step output with real command results; drafted notes for ship-me to review/own |
| document-me | technical-writer | human-approved outline (Medium/Large), audience per artifact, the code surfaces to verify against | the artifacts + verification notes |
| commit-me | — (no bench; works the tree directly) | — | — |
| loop-me | — (no bench; allocates queue slots to *skills*, never to agents) | — | — |

**Standard report** (every dispatched agent returns): status (done / in-progress / blocked) ·
changes with one-line purposes · evidence (real output, not claims) · traceability to criteria ·
assumptions taken + open questions for the skill to escalate · out-of-scope proposals, separated.

## Rules that bind every dispatch

1. **Headless**: agents cannot ask the user anything mid-task. Ambiguity → resolve from repo, or
   take the safest reversible option, record the assumption, return the open question.
2. **Testers are read-only toward implementation code** — they write/edit tests only; defects are
   findings, never patches.
3. **security-tester is strictly defensive/authorized.**
4. **Craft, not process**: agents never route work, pick tiers, run user-facing gates, or own plan
   files (PLAN.md / AUDIT.md / LOOP-STATE.md / RUNBOOK.md belong to the dispatching skill).
   team-leader returns gate-verdict *recommendations*; the skill rules on them.

## Settled ownership boundaries

- **Release notes**: inside an active release, `ship-me` owns them and dispatches technical-writer
  to draft (ship-me reviews for secrets/internal paths). Outside a release run, `document-me` owns
  them. The two skills never both write notes for the same release.
- **Runbooks**: `ship-me` owns and writes `RUNBOOK.md`; devops-release-engineer executes steps and
  may draft step content *for ship-me to own*; database-architect designs the schema-change
  sequence, never the deploy runbook.
- **Dapper read craft**: database-architect owns query/pagination design; backend-developer
  implements to the shapes handed down.
- **Microcopy**: a design spec or GLOSSARY.md wins; frontend-developer writes copy only when
  neither supplies it.
- **Schema/migration design**: build-me's cycle (SA contract + database-architect design);
  ship-me only generates and applies scripts from migrations that already exist.

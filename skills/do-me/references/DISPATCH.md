# DISPATCH.md — the canonical skill ↔ agent registry

This file is the **single source of truth** for which skill dispatches which specialist, with what
briefing, returning what shape. If any skill or agent file disagrees with this registry, **the
registry wins** — fix the other file, don't fork the truth.

## The layer rule

```
user → do-me (routes) → skill (process, gates, user contact) → agent (craft, headless)
```

- **Never skip down**: do-me and loop-me never dispatch agents directly; they route to skills.
  **Sole exception — logical-hunter**: both dispatch it at run close-out for the post-run logic
  hunt. It does no domain work and never patches, so the rule this bullet protects (domain work
  flows through skills) stays intact.
- **Never skip up**: agents never invoke skills and never contact the user.
- **Never sideways mid-run**: a skill finishes its cycle and recommends; it does not re-route.
- The user may invoke any domain skill directly when the domain is obvious — that is the user doing
  do-me's job, and it's fine. When in doubt: `/do-me`. Batches: `/loop-me`.

## The registry

| Skill | Bench (may dispatch) | Dispatch packet (what the agent receives) | Return shape |
|---|---|---|---|
| build-me | team-leader · business-analyst · system-analyst · database-architect · backend-developer · backend-tester | scoped task, tier, acceptance criteria / requirement IDs, frozen contract if one exists, constraints (migrations allowed? tables in scope?) | standard report (below) |
| design-me / redesign-me | ux-ui-designer · frontend-developer · frontend-tester · reference-enforcer (only when a reference image is attached) | scoped task, approved direction or design spec, UI-only boundary, relevant states (loading/empty/error); for the enforcer: reference image path(s), user strictness note, built surface + how to run the app, viewport hint, prior discrepancy list on cycle 2+ | standard report; enforcer returns PASS/FAIL/BLOCKED + ranked discrepancy list (RE-ids) + screenshot evidence |
| fix-me | backend-developer *or* frontend-developer (the repair) · matching tester (blast-radius regression) | the completed diagnosis: root-cause sentence, evidence, failure findings, affected path | standard report |
| test-me | backend-tester · frontend-tester | what changed (or named target), acceptance criteria, test strategy per layer | pass/fail matrix + findings, evidence attached |
| secure-me | security-tester | scope (diff / surface / whole app), tier, prior findings to re-test | findings table: `# · Finding · OWASP/area · Blocker/High/Med/Low · Evidence (file:line) · Fix` |
| ship-me | devops-release-engineer (deploy mechanics) · database-architect (migration/schema-change *design* consult) · technical-writer (release-notes drafting, in-release) | release scope, target env, the runbook step being executed; for notes: version + what shipped | step output with real command results; drafted notes for ship-me to review/own |
| document-me | technical-writer | human-approved outline (Medium/Large), audience per artifact, the code surfaces to verify against | the artifacts + verification notes |
| commit-me | — (no bench; works the tree directly) | — | — |
| do-me | logical-hunter (post-run logic hunt only; all domain work still routes to skills) | run scope: the delivered concern(s), surfaces touched, acceptance criteria / spec pointers, how to run the app | hunt report: ranked improvement findings as routable concerns (route + tier suggested) + defects flagged for fix-me, evidence attached; do-me develops them and publishes the findings-only artifact report |
| loop-me | logical-hunter (post-queue logic hunt only; queue slots still go to *skills*, never to agents) | batch scope: the terminal LOOP-STATE queue with concern statements, surfaces touched, criteria / spec pointers, how to run the app | hunt report (same shape); findings become the follow-up queue, executed under normal loop semantics; loop-me publishes the findings-only artifact report |

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
5. **logical-hunter is post-run and active**: dispatched by do-me / loop-me at close-out,
   read-only toward implementation itself. The dispatching skill routes its findings **straight
   into development** — build-me / design-me per domain, do-me for mixed, defects to fix-me
   (never developed dressed as "improvements") — with the routed skills' own tier gates intact.
   The dispatching skill then publishes the hunt report as an **artifact** (load the
   `artifact-design` skill first) containing **only the hunter's findings** and each one's
   outcome; no artifact for an empty hunt.
6. **reference-enforcer is a hard gate**: when a UI concern carries an attached reference image,
   the concern is not done until the enforcer rules PASS — a FAIL goes back to the builder with
   the discrepancy list and the enforcer is re-dispatched, **capped at 3 enforcer cycles**, then
   the concern is `blocked` and escalated with the last list + screenshots. The enforcer is
   read-only; a visual verdict requires screenshot evidence (markup-only verdicts are labeled as
   such and never silently treated as visually verified). Strictness: inferred from the reference
   type (sketch → structural only; hi-fi → + visual character), user note overrides.

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
- **Improvement findings**: logical-hunter detects; the dispatching skill (do-me / loop-me)
  routes each finding straight into development and owns the findings-only artifact hunt report;
  the development itself belongs to the routed skill (build-me / design-me / do-me for mixed) —
  never to the hunter.

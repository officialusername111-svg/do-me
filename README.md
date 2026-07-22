# do-me — a right-sized Claude Code toolkit

A complete, global-first Claude Code setup for solo/small-team development on the
**ASP.NET Core MVC + Razor + EF Core/Dapper + SQL Server (often Express)** stack, tuned for
government/LGU internal systems where statutory correctness and audit trails outrank scale.

Its organizing idea: **skills own process, agents own craft, one registry owns the wiring** — and
everything is right-sized: the lightest process that reliably does the job.

## Install

Clone this repo, open Claude Code anywhere, and run:

```
/set-me
```

`set-me` installs everything below into `~/.claude` (global — available in every project),
non-destructively: it diffs before copying, backs up anything it overwrites, merges (never
replaces) your `settings.json`, and verifies the result. Re-run it any time to sync updates.

Manual alternative: copy `skills/`, `agents/`, `commands/`, `hooks/` into `~/.claude/`, put
`config/CLAUDE.md` and `config/subagent-driven-default.json` in `~/.claude/`, and merge
`config/settings.fragment.json` into `~/.claude/settings.json`.

## The skill family

| Skill | Owns |
|---|---|
| `/do-me` | Entry point — classifies any concern (frontend/backend/both), routes it, coordinates mixed work contract-first |
| `/build-me` | Backend cycle with a right-sized agent team (TL/BA/SA/DBA/BD/BT) |
| `/design-me`, `/redesign-me` | UI/UX — build, audit-in-place, or structural reshuffle |
| `/fix-me` | Defects, diagnosis-first: reproduce → root cause → minimal fix → proof |
| `/test-me` | Verification only — never patches implementation |
| `/secure-me` | Defensive security audit and hardening, stack-tuned |
| `/commit-me` | VCS hygiene — screens secrets, groups logical commits, direct-to-main convention |
| `/ship-me` | Releases and deploys — runbooks, migration discipline, per-conversation approval for live targets |
| `/document-me` | Docs derived from actual code — README, end-user guides, release notes, glossary |
| `/loop-me` | Batch queue orchestrator — 3 attempts per item, unresolved-and-continue, LOOP-STATE.md handoff |
| `/tell-me` | Plain-language reporting — shapes every report and reply (outcome first, technical record under Details) |
| `/clean-me` | Workspace janitor — removes provable junk, parks the doubtful, ledgers everything in CLEAN-HISTORY.md |
| `/set-me` | Installs/syncs this toolkit onto a machine |

**The wiring registry** — `skills/do-me/references/DISPATCH.md` — is the single source of truth
for which skill dispatches which specialist agent, with what briefing packet and return shape,
AND for the autonomy policy (§0). If any skill or agent text disagrees with it, the registry wins.

## How it runs — fire-and-forget

The family's default is **autonomous**: state the task, get ONE plain-language review packet at
the end — no mid-run approval prompts. Every run lives in a **run envelope** (intake record with
run ID, pre-run SHA, scope, and dispatch budget; exactly one of four terminal states; "stop"
aborts immediately to the packet). Safety is mechanical during the run: a **GREEN commit gate**
(executed tests + test-integrity + protected-path + secret checks — the last three hook-enforced),
ASK-tier permissions for destructive/DB/publish/push operations, plan-critic review panels on
high-stakes plans, and a run-ID revert handle for the whole run. Hard gates (live environments,
push/tags, secrets, DB apply) never run autonomously. Add `manual` to any invocation
(e.g. `/do-me manual`) to restore per-gate human checkpoints for that one run. Canonical policy:
`skills/do-me/references/DISPATCH.md` §0.

## The specialist agents (17)

**Craft specialists (12)** — dispatched by the skills, never route work: backend-developer,
backend-tester, database-architect, devops-release-engineer, frontend-developer, frontend-tester,
ux-ui-designer, team-leader, business-analyst, system-analyst, security-tester, technical-writer.
Each carries concrete, stack-specific expertise (patterns, pitfalls, checklists) — not personas.

**Review & verification bench (5)** — the oversight the autonomy design runs on: plan-critic
(advisory plan/diff reviewer, panel member, per-finding refuter), logical-hunter (post-run logic
hunt), security-skeptic (trust-assumption architect), reference-enforcer (visual-fidelity gate),
everyday-user (non-technical clerk persona walk).

All run headless: ambiguity comes back in their report; the dispatching skill escalates to the
human. Agents are dispatched by skills, not invoked directly — the two registry-sanctioned
exceptions (plan-critic and logical-hunter on do-me's / loop-me's own benches) are recorded in
DISPATCH.md.

## Hooks & config

- `hooks/guard-secrets.sh` — PreToolUse guard blocking staging/committing of secret-bearing files
  and content (`.env`, environment appsettings, keys; connection-string and JSON-form secrets),
  including chained `git add -A; git commit` calls.
- `hooks/guard-green.sh` — PreToolUse backstop for GREEN's protected-path and test-integrity
  clauses, plus flag-order history rewrites (`git commit -a --amend`) that prefix permission
  rules cannot see.
- `hooks/count-dispatches.sh` — PreToolUse hook on subagent dispatch enforcing the §0 run budget
  (default 40) mechanically.
- `config/settings.fragment.json` — the hook wiring + the ALLOW/ASK permission tiers.
- `config/CLAUDE.md` — global working preferences (global-first rule, entry convention, stack).
- `config/subagent-driven-default.json` — SessionStart standing default for subagent-driven
  development on substantive multi-step tasks.

## Recommended pairings (install separately)

Marketplace plugins this toolkit composes with but does not bundle: `superpowers`
(systematic-debugging, TDD, verification gates), `code-review`, `security-guidance`,
`frontend-design`, `claude-mem`. UI aesthetics skills `taste-skill` / `impeccable` /
`ui-ux-pro-max` are referenced by design-me with "if installed" hedges.

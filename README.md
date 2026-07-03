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
| `/set-me` | Installs/syncs this toolkit onto a machine |

**The wiring registry** — `skills/do-me/references/DISPATCH.md` — is the single source of truth
for which skill dispatches which specialist agent, with what briefing packet and return shape.
If any skill or agent text disagrees with it, the registry wins.

## The specialist agents (12)

Deep craft specialists dispatched by the skills (never invoked directly, never route work):
backend-developer, backend-tester, database-architect, devops-release-engineer,
frontend-developer, frontend-tester, ux-ui-designer, team-leader, business-analyst,
system-analyst, security-tester, technical-writer. Each carries concrete, stack-specific
expertise (patterns, pitfalls, checklists) — not personas. All run headless: ambiguity comes back
in their report; the dispatching skill escalates to the human.

## Hooks & config

- `hooks/guard-secrets.sh` — PreToolUse guard blocking `git add/commit` of `.env` files.
- `config/settings.fragment.json` — the hook wiring + a read-only git/dotnet permission allowlist.
- `config/CLAUDE.md` — global working preferences (global-first rule, entry convention, stack).
- `config/subagent-driven-default.json` — SessionStart standing default for subagent-driven
  development on substantive multi-step tasks.

## Recommended pairings (install separately)

Marketplace plugins this toolkit composes with but does not bundle: `superpowers`
(systematic-debugging, TDD, verification gates), `code-review`, `security-guidance`,
`frontend-design`, `claude-mem`. UI aesthetics skills `taste-skill` / `impeccable` /
`ui-ux-pro-max` are referenced by design-me with "if installed" hedges.

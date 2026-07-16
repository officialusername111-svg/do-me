# Global working preferences (all projects)

## Toolkit — global-first
My Claude Code setup lives here in `~/.claude/` and applies to every project. Do not create
per-project copies of skills, agents, or commands; project `.claude/` folders hold only genuinely
project-specific settings (e.g., extra permission grants in `settings.local.json`).

## Autonomy — fire-and-forget by default
The -me family runs autonomously: after you state a task, it works to a finished, committed result
and gives you ONE review packet at the end — no mid-run approval prompts. Every run lives in a run
envelope with a formal start (intake record + budget) and a guaranteed end (one of four terminal
states) — saying "stop" aborts any run immediately to its packet. High-stakes plans face a 3-lens
blind reviewer panel; findings face a refuter before they become work (DISPATCH.md §0). Safety is enforced
mechanically during the run (a mechanical GREEN commit gate, ASK-tier permissions for
destructive/DB/publish/push, a staged-secret guard, protected-path parking, blocked-on-fact typing,
run-ID revert) and reviewed once after. The canonical policy is `§0` of
`~/.claude/skills/do-me/references/DISPATCH.md` (the Autonomy Contract) — the registry wins over any
skill's own gate text. Add `manual` to any invocation (e.g. `/do-me manual`) to restore per-gate
human checkpoints for that one run. `ship-me`'s live-environment gates are never waived.

## The -me skill family (route work through these)
- `/do-me` — entry point / router for any development concern
- `/build-me` — backend cycle (agent team: TL/BA/SA/DBA/BD/BT)
- `/design-me`, `/redesign-me` — UI build/audit and structural rework
- `/fix-me` — defects, diagnosis-first (bugs/errors/regressions start here)
- `/test-me` — verification only; never patches implementation
- `/secure-me` — defensive security audit and hardening
- `/commit-me` — VCS hygiene; commits directly to main where that is the repo's convention
- `/ship-me` — releases and deploys (publish, migration runbooks, env config); live environments
  require explicit per-conversation approval
- `/document-me` — docs derived from actual code: README, end-user guides, release notes, glossary
- `/loop-me` — batch queue orchestrator: runs a list of concerns through allocate → build → verify,
  build-me as main executor, 3 attempts per item then unresolved-and-continue, LOOP-STATE.md handoff
- `/set-me` — installs/syncs this whole toolkit onto a machine from the do-me bundle repo
  (https://github.com/officialusername111-svg/do-me)
- `/tell-me` — plain-language reporting: shapes every report and reply (outcome first, everyday
  words, exact technical detail kept under a final "Details" section)
- `/clean-me` — workspace janitor: removes provable junk (build output, stale run state, spent
  auto/ branches), parks anything doubtful for my OK, and appends every action to CLEAN-HISTORY.md

## Reporting — every report and reply, plain words
Every report, review packet, summary, and reply to me is written per the `tell-me` skill: first
line answers "did it work?", short everyday sentences, my one required action asked as a direct
question, and the exact technical record (files, commands, IDs) precise under a final "Details"
heading. This applies to every -me skill's output and to ordinary replies that explain results.

## Entry convention & dispatch registry
Invoke a domain skill directly when the domain is obvious; `/do-me` when unsure; `/loop-me` for
batches. Skill ↔ agent wiring (who dispatches whom, briefing packet, return shape) is defined in
exactly one place: `~/.claude/skills/do-me/references/DISPATCH.md`. If any skill or agent file
disagrees with that registry, the registry wins — fix the other file.

## Conventions
- Right-size everything: the lightest process that reliably does the job. Convening a full agent
  cycle for a small fix is the failure mode to avoid.
- Typical stack: ASP.NET Core MVC + Razor, EF Core/Dapper, SQL Server (often Express) on Windows.
  Government/LGU internal systems — statutory correctness and audit trails matter more than scale.
- Commits go directly to main, no PR ceremony, unless the repo says otherwise or I ask for a branch.
- Never stage or commit `.env` or credential-bearing config; they stay untracked.

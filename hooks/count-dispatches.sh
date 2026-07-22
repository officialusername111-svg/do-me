#!/bin/bash
# PreToolUse hook on the subagent tool (matcher "Task"): mechanical enforcement of the
# DISPATCH.md §0 run budget (default 40 subagent dispatches). The orchestrator's PLAN.md
# counter is self-report; this hook is the backstop that actually refuses dispatch N+1.
# Exit 2 = block (budget exhausted); exit 0 = pass.
#
# Budget override: a `.claude-run-budget` file in the cwd, written by the orchestrating
# skill at intake, format:  <run-id> <max-dispatches>
# A new run-id starts a fresh count (so back-to-back runs in one session don't inherit
# each other's spend). Without the file, counting is per session with the default cap.

input=$(cat)
DEFAULT_CAP=40

session=$(printf '%s' "$input" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed -E 's/.*"([^"]*)"$/\1/')
[ -z "$session" ] && session="nosession"

cap=$DEFAULT_CAP
runid="session"
if [ -f ".claude-run-budget" ]; then
  runid=$(awk 'NR==1{print $1}' .claude-run-budget 2>/dev/null)
  fcap=$(awk 'NR==1{print $2}' .claude-run-budget 2>/dev/null)
  case "$fcap" in ''|*[!0-9]*) : ;; *) cap=$fcap ;; esac
  [ -z "$runid" ] && runid="session"
fi

dir="${TMPDIR:-/tmp}/claude-dispatch-counters"
mkdir -p "$dir" 2>/dev/null
key=$(printf '%s-%s' "$session" "$runid" | tr -cd 'A-Za-z0-9._-')
cf="$dir/$key"

count=0
[ -f "$cf" ] && count=$(cat "$cf" 2>/dev/null)
case "$count" in ''|*[!0-9]*) count=0 ;; esac
count=$((count + 1))
printf '%s' "$count" > "$cf"

if [ "$count" -gt "$cap" ]; then
  echo "Blocked: run dispatch budget exhausted ($cap subagent dispatches spent). Per DISPATCH.md §0, end the run NOW in a terminal state — mark whatever remains unresolved — and write the review packet. Only the human may raise the cap (edit .claude-run-budget: '<run-id> <new-max>')." >&2
  exit 2
fi
exit 0

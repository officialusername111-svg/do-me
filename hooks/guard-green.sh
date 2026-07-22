#!/bin/bash
# PreToolUse guard: mechanical backstop for DISPATCH.md §0 GREEN conditions 2 and 3, plus
# ASK-tier history-rewrite detection that permission prefix rules cannot express.
# Exit 2 = hard block; exit 0 = pass.
#
# 1. History rewrite: permission rules are prefix matches, so `git commit -a --amend`
#    slips past the `git commit --amend:*` ASK entry (the flag order defeats the prefix).
#    Any git call carrying --amend / rebase / filter-branch is blocked here; §0 keeps
#    history tamper-evident. No trailer bypass — get the human's OK, then run it as a
#    single plain command the permission layer can see (`git rebase ...` is ASK-tier).
# 2. On `git commit`: block if a protected path is staged (§0 GREEN 3 — rate/penalty/
#    interest/surcharge/rounding/exemption code, assessment/collection/billing
#    migrations) or if the staged diff deletes a test file or skips/ignores an existing
#    test (§0 GREEN 2). A commit the human explicitly approved may carry a
#    `Human-Approved: <reason>` trailer in its message to pass these two gates — the
#    trailer lands in history, so the approval stays auditable.

input=$(cat)
cmd=$(printf '%s' "$input" | tr '\n' ' ')

# Only git commands concern this guard.
printf '%s' "$cmd" | grep -qiE 'git([[:space:]]|[^"]*[[:space:]])' || exit 0

# --- 1. History rewrite, any git call ---
# Scan only the part before any -m/--message flag, so a commit MESSAGE that merely
# mentions --amend or rebase does not false-positive (the flags themselves always
# precede the message in a real rewrite command).
histcheck=$(printf '%s' "$cmd" | sed -E 's/ -m .*$//; s/ --message[= ].*$//')
if printf '%s' "$histcheck" | grep -qiE 'git[^"]*(--amend|filter-branch|[[:space:]]rebase([[:space:]]|$))'; then
  echo "Blocked: history rewrite (--amend / rebase / filter-branch) is ASK-tier (DISPATCH.md §0 — history stays tamper-evident). Get the human's explicit OK in chat, then run it as a single plain git command so the permission prompt fires." >&2
  exit 2
fi

# --- 2/3 apply only to a commit ---
printf '%s' "$cmd" | grep -qiE 'git([[:space:]]|[^"]*[[:space:]])commit([[:space:]]|$)' || exit 0

# Auditable bypass for explicitly human-approved commits.
if printf '%s' "$cmd" | grep -qE 'Human-Approved:'; then
  exit 0
fi

workdir=$(printf '%s' "$cmd" | grep -oE '\-C[[:space:]]+[^[:space:]]+' | head -n1 | sed -E 's/^-C[[:space:]]+//')
gitcmd="git"
[ -n "$workdir" ] && gitcmd="git -C $workdir"

staged=$($gitcmd diff --cached --name-only 2>/dev/null)
[ -z "$staged" ] && exit 0

# --- Protected paths (§0 GREEN 3): modified autonomously, never auto-committed ---
# Case-sensitive camelCase stems (Rate not "generate"/"migrate") plus separator-prefixed
# lowercase forms; migrations touching assessment/collection/billing tables.
protected=$(printf '%s\n' "$staged" | grep -E '(Rate|Penalt|Interest|Surcharge|Rounding|Exempt|[_/.-](rate|penalt|interest|surcharge|rounding|exempt))')
migrations=$(printf '%s\n' "$staged" | grep -iE 'migrations?/.*(assess|collect|billing)')
if [ -n "$protected$migrations" ]; then
  echo "Blocked: protected path staged — $(printf '%s %s' "$protected" "$migrations" | tr '\n' ' '). Per DISPATCH.md §0 GREEN 3, rate/penalty/interest/surcharge/rounding/exemption code and assessment/collection/billing migrations are never auto-committed: park them for human review in the packet. A commit the human explicitly approved adds a 'Human-Approved: <reason>' trailer to its message." >&2
  exit 2
fi

# --- Test integrity (§0 GREEN 2): no test deleted, skipped, or ignored ---
deleted_tests=$($gitcmd diff --cached --name-only --diff-filter=D 2>/dev/null | grep -E '(Tests?\.cs$|\.Tests/|(^|/)tests?/|\.spec\.|\.test\.)')
if [ -n "$deleted_tests" ]; then
  echo "Blocked: this commit deletes test file(s): $(printf '%s' "$deleted_tests" | tr '\n' ' '). Per DISPATCH.md §0 GREEN 2 a run that removes tests parks for human review instead of committing. 'Human-Approved: <reason>' trailer applies only if the human agreed in chat." >&2
  exit 2
fi
# Scoped to test files only — a doc or script quoting "[Fact(Skip" is not a weakened test.
if $gitcmd diff --cached -- '*Tests.cs' '*Test.cs' '*Tests/*' '*tests/*' '*.spec.*' '*.test.*' 2>/dev/null | grep -qE '^\+.*\[(Fact|Theory)\([[:space:]]*Skip|^\+.*\[Ignore'; then
  echo "Blocked: the staged diff skips or ignores a test ([Fact(Skip=...)] / [Ignore]). Per DISPATCH.md §0 GREEN 2 weakened tests park for human review instead of committing. 'Human-Approved: <reason>' trailer applies only if the human agreed in chat." >&2
  exit 2
fi

exit 0

#!/bin/bash
# PreToolUse guard (backstop heuristic, not a substitute for commit-me's diff screening).
# Blocks a git add/commit that would STAGE a secret-bearing file. It inspects what is
# actually staged (git diff --cached), not the raw command text — so `git add -A`,
# `git add .`, and wildcard adds are covered, and a commit MESSAGE that merely mentions
# ".env" no longer false-positives. Exit 2 = hard block; exit 0 = pass to normal eval.
#
# Secret-bearing = any .env* except .env.example / .env.sample / .env.template;
# appsettings.*.json other than the base appsettings.json (env overrides carry secrets);
# private-key / publish-profile / pfx material; or staged content matching a
# connection-string-with-password or explicit secret-assignment pattern.

input=$(cat)
cmd=$(printf '%s' "$input" | tr '\n' ' ')

# Only act on git commands that stage/commit. Anything else passes straight through.
if ! printf '%s' "$cmd" | grep -qiE 'git([[:space:]]|[^"]*[[:space:]])(add|commit|stage)([[:space:]]|$)'; then
  exit 0
fi

# Determine the repo working directory from the command's -C flag if present, else CWD.
workdir=$(printf '%s' "$cmd" | grep -oE '\-C[[:space:]]+[^[:space:]]+' | head -n1 | sed -E 's/^-C[[:space:]]+//')
gitcmd="git"
[ -n "$workdir" ] && gitcmd="git -C $workdir"

# What is actually staged right now? (Covers wildcard/`-A`/`.` adds already applied, and
# the pre-commit index for a commit.) If we can't read an index, fail safe and allow —
# commit-me still screens the diff.
staged=$($gitcmd diff --cached --name-only 2>/dev/null)

# Also consider paths named literally on an `add` line that are not yet staged, so a
# `git add secrets.env` is caught before the file is even indexed.
literal=$(printf '%s' "$cmd" | grep -oE 'git[^"]*add[^"]*' | sed -E 's/^.*add//')

candidates=$(printf '%s\n%s\n' "$staged" "$literal" | tr ' ' '\n' | sed '/^$/d' | sort -u)

blocked_path=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  base=$(basename "$f")
  # .env family, excluding safe templates
  if printf '%s' "$base" | grep -qE '^\.env' && ! printf '%s' "$base" | grep -qiE '\.(example|sample|template)$'; then
    blocked_path="$f"; break
  fi
  # environment-specific appsettings (appsettings.Development.json etc.), but not the base file
  if printf '%s' "$base" | grep -qiE '^appsettings\..+\.json$'; then
    blocked_path="$f"; break
  fi
  # key material and publish profiles
  if printf '%s' "$base" | grep -qiE '\.(pfx|p12|pem|key|pubxml)$'; then
    blocked_path="$f"; break
  fi
done <<EOF
$candidates
EOF

if [ -n "$blocked_path" ]; then
  echo "Blocked: '$blocked_path' looks secret-bearing and is about to be staged/committed. Secret files (.env, environment appsettings, keys, publish profiles) must stay untracked; only .env.example / a committed template may be committed. If this is a false positive, stage the specific safe file explicitly and add a committed template instead." >&2
  exit 2
fi

# Content check: scan the staged diff for a connection string carrying a password or an
# explicit secret assignment. Cheap and catches secrets pasted into an otherwise-fine file.
if [ -n "$staged" ]; then
  if $gitcmd diff --cached 2>/dev/null | grep -qiE '(Server=[^;]*;[^\n]*Password=[^;[:space:]]+|User[[:space:]]*Id=[^;]*;[^\n]*Password=[^;[:space:]]+|(api[_-]?key|secret|client[_-]?secret|access[_-]?token)[[:space:]"'\'':]*=[[:space:]]*[^[:space:]"'\'']{8,})'; then
    echo "Blocked: the staged diff contains what looks like a live connection-string password or a secret/API-key assignment. Move it to user-secrets / an untracked config and commit only a placeholder." >&2
    exit 2
  fi
fi

exit 0

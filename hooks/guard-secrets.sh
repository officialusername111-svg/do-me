#!/bin/bash
# PreToolUse guard (backstop heuristic, not a substitute for commit-me's diff screening).
# Blocks a git add/commit that would STAGE a secret-bearing file. It inspects what is
# actually staged (git diff --cached) AND — for chained calls like `git add -A; git commit`
# where the index is still empty at hook time — what the working tree says WILL be staged
# (git status --porcelain). A commit MESSAGE that merely mentions ".env" does not
# false-positive. Exit 2 = hard block; exit 0 = pass to normal eval.
#
# Secret-bearing = any .env* except .env.example / .env.sample / .env.template;
# appsettings.*.json other than the base appsettings.json (env overrides carry secrets);
# private-key / publish-profile / pfx material; or content matching a
# connection-string-with-password or a secret assignment in BOTH `key = value` and
# JSON/YAML `"key": "value"` form.

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

# Chained staging: `git add -A; git commit ...` in ONE tool call, a wildcard add, or
# `git commit -a` all stage files AFTER this hook runs, so the index above is blind to
# them. Predict the stage from the working tree: untracked + modified per porcelain.
pending=""
if printf '%s' "$cmd" | grep -qiE 'git[^"]*add[^"]*([[:space:]](-A|--all|\.)([[:space:]]|;|$)|\*)' \
   || { printf '%s' "$cmd" | grep -qiE 'git[^"]*add' && printf '%s' "$cmd" | grep -qiE 'git[^"]*commit'; } \
   || printf '%s' "$cmd" | grep -qiE 'git[^"]*commit[^"]*[[:space:]]-[a-zA-Z]*a'; then
  pending=$($gitcmd status --porcelain 2>/dev/null | sed -E 's/^.{3}//' | sed -E 's/^"(.*)"$/\1/')
fi

candidates=$(printf '%s\n%s\n%s\n' "$staged" "$literal" "$pending" | tr ' ' '\n' | sed '/^$/d' | sort -u)

blocked_path=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in -*) continue ;; esac   # command flags swept up from the add line, not paths
  base=$(basename -- "$f")
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

# Content check: scan for a connection string carrying a password or a secret assignment.
# Matches both `ApiKey = xxxx` and JSON/YAML `"ApiKey": "xxxx"` forms (the stack's native
# secret format is JSON appsettings). Cheap and catches secrets pasted into an
# otherwise-fine file.
content_re='(Server=[^;]*;.*Password=[^;[:space:]]+|User[[:space:]]*Id=[^;]*;.*Password=[^;[:space:]]+|(api[_-]?key|secret|client[_-]?secret|access[_-]?token|connection[_-]?string)["'\''[:space:]]*[:=][[:space:]]*["'\'']?[^[:space:]"'\'']{8,})'
content_msg="Blocked: the staged (or about-to-be-staged) content contains what looks like a live connection-string password or a secret/API-key assignment. Move it to user-secrets / an untracked config and commit only a placeholder."

# The guard scripts' own source contains these patterns as literals, so content scans
# exclude hooks/*.sh (the filename screen above still covers everything, everywhere).
if [ -n "$staged" ]; then
  if $gitcmd diff --cached -- ':(exclude)hooks/*.sh' ':(exclude)*/hooks/*.sh' 2>/dev/null | grep -qiE "$content_re"; then
    echo "$content_msg" >&2
    exit 2
  fi
fi

# Chained case: the secret isn't in the index yet. Scan the unstaged diff (modified tracked
# files) and the first 50 untracked/pending candidates directly.
if [ -n "$pending" ]; then
  if $gitcmd diff -- ':(exclude)hooks/*.sh' ':(exclude)*/hooks/*.sh' 2>/dev/null | grep -qiE "$content_re"; then
    echo "$content_msg" >&2
    exit 2
  fi
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    case "$f" in hooks/*.sh|*/hooks/*.sh) continue ;; esac
    p="${workdir:+$workdir/}$f"
    [ -f "$p" ] || continue
    if head -c 200000 "$p" | grep -qiE "$content_re"; then
      echo "$content_msg (file: $f)" >&2
      exit 2
    fi
  done <<EOF
$(printf '%s\n' "$pending" | head -n 50)
EOF
fi

exit 0

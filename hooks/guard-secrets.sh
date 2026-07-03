#!/bin/bash
# PreToolUse guard: block explicit staging/committing of secret files (.env and
# credential-bearing variants) via git. Heuristic on the raw command text; the
# commit-me skill does the thorough diff-level screening — this is the backstop.
# .env.example is exempt (it is the committed template, no secrets).
input=$(cat)
cmd=$(printf '%s' "$input" | tr '\n' ' ')
if printf '%s' "$cmd" | grep -qE 'git[^"]*(add|commit|stage)'; then
  stripped=$(printf '%s' "$cmd" | sed 's/\.env\.example//g')
  if printf '%s' "$stripped" | grep -qE '\.env([^a-zA-Z0-9_]|$)'; then
    echo "Blocked: this command appears to stage or commit a .env file (secrets). .env files must stay untracked; only .env.example may be committed." >&2
    exit 2
  fi
fi
exit 0

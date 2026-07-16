#!/bin/bash
# UserPromptSubmit hook: session-length watchdog.
# Measures the session transcript file and, past a threshold, injects a context note
# (stdout on exit 0 is added to Claude's context) instructing Claude to tell the user
# plainly that the session is long and a fresh one is cheaper. Fires once per level
# per session (marker files in /tmp), so it nudges without nagging.
#
# Levels (calibrated 2026-07-16 against a real marathon session ~3.1 MB):
#   level 1 >= 2500000 bytes  — session is getting long; wrap up here, new work in a fresh session
#   level 2 >= 4000000 bytes  — session is very long; risk of mid-work cutoff; recommend switching now

input=$(cat)

# Pull transcript_path out of the hook JSON without requiring jq.
tp=$(printf '%s' "$input" | grep -o '"transcript_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed -E 's/^"transcript_path"[[:space:]]*:[[:space:]]*"//; s/"$//')
# JSON escapes backslashes; normalize to forward slashes for bash.
tp=$(printf '%s' "$tp" | sed 's/\\\\/\//g; s/\\/\//g')
[ -z "$tp" ] && exit 0
[ ! -f "$tp" ] && exit 0

sid=$(printf '%s' "$input" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed -E 's/^"session_id"[[:space:]]*:[[:space:]]*"//; s/"$//')
[ -z "$sid" ] && sid=$(basename "$tp" .jsonl)

size=$(wc -c < "$tp" 2>/dev/null | tr -d '[:space:]')
[ -z "$size" ] && exit 0

level=0
if [ "$size" -ge 4000000 ]; then level=2
elif [ "$size" -ge 2500000 ]; then level=1
fi
[ "$level" -eq 0 ] && exit 0

marker="/tmp/.session-length-warned-${sid}-L${level}"
[ -f "$marker" ] && exit 0
touch "$marker" 2>/dev/null

mb=$(awk -v b="$size" 'BEGIN { printf "%.1f", b/1000000 }')

if [ "$level" -eq 2 ]; then
  cat <<EOF
🔴 SESSION-LENGTH ALERT (level 2 of 2): this session's transcript is ${mb} MB — very long. Long sessions hit token limits mid-work and lose quality. In your NEXT reply, tell the user plainly (per the tell-me shape), leading the note with the 🔴 marker: this session is very long; please start a fresh session for anything new — the memory folder carries the context over, so nothing is lost. Finish only what is already in flight here. This alert fires once.
EOF
else
  cat <<EOF
🟡 SESSION-LENGTH NOTE (level 1 of 2): this session's transcript is ${mb} MB — getting long. In your next reply, add a short plain-words note to the user, leading it with the 🟡 marker: the session is getting long; it is a good time to wrap up, and any NEW piece of work is better started in a fresh session (the memory folder carries the context). This note fires once; a stronger 🔴 alert fires at 4 MB.
EOF
fi
exit 0

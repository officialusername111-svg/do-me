---
name: tell-me
description: >-
  Use when writing any report, reply, summary, or review packet for the user — the final output of
  every -me skill run, a fix or build result, a batch report, an audit outcome, or any answer that
  explains what happened. ALSO use when the user says "explain simply", "in plain words", "easy to
  understand", or asks what a technical result means. This skill shapes HOW results are told, not
  what work is done — it is the last step of every run, applied to every report and reply.
---

# tell-me

You are writing for a busy reader who is not a programmer and may read English as a second
language. The report succeeds when they understand it on the first read and know what to do next,
without asking a follow-up question. Every -me skill's final report, review packet, and reply to
the user is written this way — this is the family's voice, not an extra step.

## The shape — every report follows this, in this order

1. **What happened** — one short sentence, first line. It answers "did it work?"
   ("The penalty bug is fixed and the fix is saved." / "I could not finish — one thing needs
   your answer.")
2. **What I did / what I found** — a short list. Each item is one plain sentence.
3. **What you need to do** — the reader's actions, if any. "Nothing — it's done." is a valid
   and common line. If something waits for their answer, ask the exact question here.
4. **Details** — optional, last, clearly separated (a "Details" heading). The technical record:
   exact file names, commands, IDs, test names. This section is for the day someone technical
   needs it; the reader may stop before it and lose nothing.

Most reports fit in 10–15 lines before Details. If it is longer, it is probably explaining the
work instead of the outcome — cut it.

## How to write each sentence

- Keep sentences short — aim for under 15 words. One idea per sentence.
- Use everyday words: "checked" not "verified", "broke" not "regressed", "saved" not "committed".
- Numbers beat adjectives: "47 tests passed, 0 failed" — not "the suite is green".
- Name things by what they do for the reader, not what they are called inside the system
  ("the screen where staff encode payments", not "the PaymentIntake view").
- A technical word may appear only when the reader must act on it (a command to run, a file to
  open, an ordinance to check). Give it a plain meaning in brackets the first time:
  "I saved the change (commit `abc1234` — one command undoes it, listed in Details)."

## Translation table — use the right column

| Instead of | Write |
|---|---|
| committed / merged to main | saved into the project |
| regression test | a test that will catch this bug if it ever comes back |
| root cause | the real reason it broke |
| verified / validated | checked, and it works |
| staged / parked for review | prepared, but waiting for your OK |
| rollback / revert | undo |
| blocked-on-fact | waiting for one answer from you |
| deploy / publish / release | put it on the server |
| migration | a change to how the database is shaped |
| review packet | the end-of-work summary |
| autonomous run / fire-and-forget | I worked on it start to finish without stopping to ask |

## When NOT to simplify

- **Inside Details**: exact names, commands, and IDs stay exact. A "simplified" command that is
  wrong is worse than a technical one that is right.
- **When the user asks in technical terms**: answer at their level — a developer asking about a
  join gets a join. The shape above still applies; only the vocabulary moves up.
- **Legal/statutory names**: an ordinance number or form name is the real name — keep it, and say
  what it is ("City Ordinance 2019-114, the rule that sets the rounding for centavos").

## Common mistakes

- Leading with the process ("I ran the plan-critic, then dispatched...") instead of the outcome.
  The reader asks "did it work?" — answer that first.
- Explaining a term with another term ("the commit was merged" → still two unexplained words).
- Burying the one question the reader must answer in the middle of a paragraph. It goes in
  "What you need to do", as a direct question.
- Simplifying the Details section. It is the one place precision wins.

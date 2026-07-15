# UX/UI Reference Library — Design Spec

**Date:** 2026-07-15
**Status:** Approved approach: 7 thematic, stack-agnostic reference files (Approach A)
**Deliverables:** 7 files in `~/.claude/skills/do-me/references/` + a Reference library
section in the `ux-ui-designer` agent, mirrored into the do-me bundle repo.

## Purpose

Extend the `ux-ui-designer` agent's deep-reference knowledge beyond context menus to
32 further UX/UI engineering topics the user identified as missing. Written as
agent-facing reference material: every section leads with actionable rules, decision
tables, checklists, and hard numbers — not essays.

## Audience

- **Primary:** the `ux-ui-designer` agent — loads the relevant file when specifying
  or auditing UI in that domain.
- **Secondary:** builder agents (e.g., `frontend-developer`) reached indirectly via
  the designer's specs. No pointer is added to their agent files in this initiative.

## Portability requirement (differs from the context-menu spec)

The references are **stack-agnostic by design**. The user must be able to apply them
unchanged on the current stack (ASP.NET MVC + Razor + Bootstrap), a future React +
Tailwind stack, or native Android (Android Studio / Material 3). Therefore:

- Rules, anatomy, state machines, and hard numbers (timings, sizes, thresholds) are
  written platform-neutrally.
- Each engineering topic carries a compact **platform mapping** block: web/ARIA
  pattern ↔ React behavioral notes ↔ Android/Material 3 equivalent.
- Code snippets appear only where a pattern demands illustration, as minimal neutral
  HTML/CSS/JS — no Bootstrap classes, no framework or library dependencies, no
  React/Android code (mapping notes only).

## File inventory & topic allocation

Every one of the 32 topics has exactly one owning file; overlaps are handled by
cross-reference, never duplicated rule text.

| # | File | Owns | Count |
|---|------|------|-------|
| 1 | `UX-PSYCHOLOGY.md` | Zeigarnik effect · serial-position effect · peak-end rule · golden ratio | 4 |
| 2 | `STATES-AND-FEEDBACK.md` | empty/error/success states · input states · focus states · loading system · feedback experience · optimistic UI · undo-on-delete · reactive toast · notification system | 9 |
| 3 | `FORMS-AND-INPUTS.md` | structured forms · form input validation · OTP inputs · date picker essentials · toggle rules · chip states · color picker · microcopy | 8 |
| 4 | `NAVIGATION-AND-WAYFINDING.md` | navigation system · tab system · search system · pagination patterns · command palette | 5 |
| 5 | `OVERLAYS-AND-STACKING.md` | tooltip · dropdown rules · z-index architecture | 3 |
| 6 | `MOTION.md` | organic animation, plus the shared motion system (duration scales, easing, choreography, `prefers-reduced-motion`) that component motion sections cross-reference | 1 |
| 7 | `TOUCH-AND-GESTURES.md` | drag-and-drop UX · swipe gestures | 2 |

Allocation notes:

- Toast and notification system live in `STATES-AND-FEEDBACK.md` as feedback
  surfaces; their enter/exit motion cites `MOTION.md`.
- Dropdown and pagination motion belong to their owning component sections and pull
  timing/easing from `MOTION.md`.
- "Dropdown rules" means generic dropdowns / menu buttons — exactly what the
  context-menu study excluded, so the two references abut without overlapping.
- "Microcopy" (user wrote "Microscopy") = UX writing: labels, errors, helper text,
  button verbs; deepens the agent's existing craft paragraph.

## Per-file anatomy

Target ~400–800 lines per file so an agent can load one file as working context.

1. **When-to-load line** — one sentence naming the concerns this file serves.
2. **Decision layer** — pattern-selection tables (e.g., inline vs on-submit
   validation; toast vs banner vs modal; tabs vs segmented control vs accordion).
3. **Per-topic rule sections** — imperative rules, anatomy/state machines, hard
   numbers with citations, do/don't pairs.
4. **Platform mapping** — per the portability requirement above.
5. **Cross-references** — explicit `see MOTION.md §easing` style; one owner per rule.
6. **Review checklist** — self-contained pass/fail list, usable without reading the
   rest of the file.
7. **Sources** — the consulted URLs.

## Research method

One web-research pass per file against authoritative sources before drafting:
WAI-ARIA Authoring Practices Guide, MDN, Nielsen Norman Group, Material 3, Apple
HIG, web.dev, WCAG 2.2, and Laws of UX (psychology topics cite underlying studies
via Laws of UX / NN/g, not pop-design blogs). Every hard number carries its source.
Claims that cannot be verified are dropped or explicitly marked as
convention/judgment — the golden ratio section in particular must state its weak
empirical footing.

## Integration

- `ux-ui-designer.md` gains a dedicated `## Reference library` section: one line per
  reference — the 7 new files plus `CONTEXT-MENUS.md` — each saying when to load it.
  The inline context-menu pointer previously embedded in the Bootstrap component
  section is removed in favor of this block.
- **Both copies updated:** the installed tree (`~/.claude/skills/do-me/references/`,
  `~/.claude/agents/ux-ui-designer.md`) and the bundle repo
  (`do-me/skills/do-me/references/`, `do-me/agents/ux-ui-designer.md`). This also
  heals the existing drift from the earlier installed-only pointer edit.
- `DISPATCH.md` untouched — verified it has no reference-registration convention.
- `frontend-developer.md` untouched.
- The approved `CONTEXT-MENUS.md` spec (Bootstrap-flavored, still unwritten) stays
  as-is; it remains a separate build item.

## Execution shape (preview for the implementation plan; not binding)

The 7 files are independent and file-disjoint: one research+draft subagent per file,
run in parallel, followed by a consistency pass (cross-references resolve, no
contradictory rules between files, uniform checklist style) before the agent-file
edit and bundle sync.

## Acceptance criteria

1. All 7 files exist in `~/.claude/skills/do-me/references/`, covering all 32 topics
   per the allocation table.
2. Every file is stack-agnostic: no framework or library dependency in any snippet;
   platform-mapping notes present for web/React/Android on engineering topics.
3. Each file contains decision layer, per-topic rules, review checklist, and
   Sources; every hard number is cited or explicitly marked as judgment.
4. `ux-ui-designer.md` contains the Reference library section listing all 8
   references, with the old inline context-menu pointer removed.
5. Installed copy and bundle repo copy are identical for every touched file.

## Non-goals

- No interactive demo pages.
- No rewrite of the CONTEXT-MENUS spec and no writing of CONTEXT-MENUS.md itself.
- No React or Android code implementations — platform-mapping notes only.
- No changes to design-me's competency matrix, DISPATCH.md, or frontend-developer.

# Production-Level UX/UI Architect — Competency Matrix

This is the knowledge base `design-me` operates from. It is **UX and UI only** — no security, DevOps,
build tooling, version control, or backend/API mechanics. Use it two ways:

- **When building**, pull the relevant areas into the work so output reflects architect-level UX/UI
  practice, not just a working component.
- **When auditing** (independent evaluate-and-improve mode), use these as the **dimensions you score
  the current UI against**. Each numbered area is an axis; find gaps, rate severity, remediate.

Don't dump this list at the user. Apply it. Reference specific items only when they explain a finding
or a decision.

## Contents
1. UX & Interaction Design
2. Visual Design & Hierarchy
3. Component Architecture (UI)
4. HTML & Semantics
5. CSS & Layout
6. Responsive & Adaptive Design
7. Accessibility (A11Y)
8. Motion & Micro-interactions
9. UI State & Feedback
10. Performance as Experience
11. Design Systems
12. Content, Microcopy & i18n
13. Usability Evaluation

---

## 1. UX & Interaction Design
User flows and task paths; clear affordances (things that look interactive are, and vice versa);
immediate, meaningful feedback for every action; error *prevention* over error messages; sensible
defaults; forgiving interactions (undo, confirm destructive actions); information architecture and
grouping; recognition over recall. Lean on Nielsen's heuristics and Fitts's/Hick's laws.
*Audit lens: dead-end states, unclear next step, no feedback on action, destructive actions with no
guard, choices that overwhelm, hidden-but-critical controls.*

## 2. Visual Design & Hierarchy
Gestalt principles (proximity, similarity, common region, continuity); a clear visual hierarchy so
the eye lands on the most important thing first; consistent **spacing rhythm** (a scale, not random
margins); alignment and grid; scale and proportion; deliberate **white space**; typographic hierarchy
(size, weight, line-height, measure). *Audit lens: everything competing for attention, inconsistent
spacing, misalignment, cramped or arbitrary gaps, weak type hierarchy, no clear focal point.*

## 3. Component Architecture (UI)
Modular, reusable, composable interface components; clean component APIs (props) with sensible
defaults; controlled vs. uncontrolled patterns; compound components for related parts (e.g. `Select`
+ `Select.Option`); composition over configuration; consistent organization. Framework-aware
(React/Vue/Angular/Web Components/Razor) but the goal is reusable *UI*, not framework gymnastics.
*Audit lens: copy-pasted near-duplicates, hardcoded content/sizes, god-components, props that should
be composition, one-off components that should be shared.*

## 4. HTML & Semantics
Semantic HTML5 (`button`, `nav`, `main`, `header`, `dialog`, lists, headings in order); proper form
markup with real `<label>`s; landmarks for navigation; structure that reads correctly to assistive
tech and search engines. Semantics first, `div`s last. *Audit lens: div-soup, clickable non-buttons,
unlabeled inputs, skipped heading levels, missing landmarks.*

## 5. CSS & Layout
CSS Grid and Flexbox for real layout; **CSS variables / design tokens** instead of magic numbers;
modern layout techniques; methodology where it helps (BEM, utility-first, ITCSS) for maintainability;
transitions and animation (see area 8); critical/above-the-fold styling so content paints fast.
*Audit lens: float/absolute hacks where grid/flex belong, magic numbers, duplicated/unused CSS,
specificity wars, layout that breaks when content changes.*

## 6. Responsive & Adaptive Design
Mobile-first; layouts that adapt at sensible breakpoints rather than one fixed width; fluid type and
spacing (`clamp()`); container queries where they cut breakpoint sprawl; touch targets ≥ 44×44px;
a non-hover equivalent for every hover affordance; RTL and `prefers-color-scheme` / `prefers-reduced-
motion` respected. *Audit lens: overflow or clipping at ~320px, tiny tap targets, hover-only
controls, fixed pixel widths, content that doesn't reflow.*

## 7. Accessibility (A11Y)
WCAG 2.2 AA as the floor: full keyboard operation (logical tab order, visible focus, Enter/Space/Esc/
arrows per the WAI-ARIA Authoring Practices pattern); **focus management** (trap in modals, restore on
close); screen-reader support (correct roles, names, `aria-live` for async); **contrast** ≥ 4.5:1 text
/ 3:1 large text & UI; never encode meaning by color alone; meaningful `alt`, decorative `alt=""`,
`aria-label` on icon-only buttons. *Audit lens: keyboard traps or unreachable controls, invisible
focus, color-only meaning, contrast failures, unlabeled icons, ARIA misused where semantics would do.*

## 8. Motion & Micro-interactions
Motion that **communicates** — state changes, spatial relationships, progress — not decoration;
purposeful transitions with appropriate easing and short, interruptible durations; hover/press/focus
feedback that feels responsive; honor `prefers-reduced-motion`. Micro-interactions confirm actions
and reduce uncertainty. *Audit lens: animation the user must wait through, janky or laggy motion, no
feedback on press, motion that ignores reduced-motion, easing that feels mechanical.*

## 9. UI State & Feedback
Every async surface distinguishes **idle / loading / success / empty / error** — they are different
UI, not one spinner. Skeletons that match final layout over centered spinners; reserve space to
prevent layout shift; disable and mark in-flight actions and guard double-submit; real empty states
with guidance (not a blank box); inline, specific validation messages tied to fields; optimistic
updates with rollback where it improves perceived speed; non-blocking confirmation (toasts) for
success. *Audit lens: blank screen while loading, no empty state, generic "something went wrong,"
layout jump when data arrives, double-submittable buttons, validation that only fires on submit.*

## 10. Performance as Experience
Perceived performance is UX: fast first paint, no layout shift, responsive input. Target Core Web
Vitals — **LCP, CLS, INP** (plus TTFB, FCP). Lazy-load below-the-fold and offscreen media; size and
format images responsibly; virtualize long lists so the UI stays smooth; avoid re-renders that cause
visible jank; reserve dimensions for media/embeds to keep CLS near zero. *Audit lens: content jumping
(CLS), sluggish typing/scroll (INP), heavy hero images (LCP), unvirtualized long lists, no width/
height on images.*

## 11. Design Systems
Design tokens (color, spacing, type, radius, shadow) as the single source of truth; a reusable
component library; theming (light/dark, brand variants); consistency across screens; documentation so
others use components correctly (Storybook or equivalent). *Scope-gated:* a full system is for
products/teams — a single internal page needs a handful of tokens, not a pipeline. *Audit lens:
inconsistent components doing the same job, hardcoded values instead of tokens, no theming hook where
it's needed, undocumented components.*

## 12. Content, Microcopy & i18n
Clear labels, button verbs that say what happens, helpful empty-state and error copy, and concise
helper text; consistent terminology; humane error messages that say how to recover. Design layouts to
**tolerate** text-length and locale variance (wrapping, truncation, RTL) even when you don't ship a
full i18n framework — don't add i18n machinery below the tier that needs it. *Audit lens: vague labels
("Submit" for everything), blaming error copy, truncation that hides meaning, layouts that break with
longer translations.*

## 13. Usability Evaluation
How to assess an interface independently: heuristic evaluation against Nielsen's 10; an accessibility
pass (keyboard-only walk, screen-reader sanity check, contrast math from the actual token values); a
responsive pass at ~320px and wide; a visual-hierarchy and spacing-rhythm read; and a
states-and-edge-cases check (empty, loading, error, long content). Produce concrete, prioritized
findings — not vibes. *This is the backbone of audit mode.*

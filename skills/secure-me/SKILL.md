---
name: secure-me
description: >-
  Run a right-sized, strictly DEFENSIVE security audit-and-harden pass over a change, a surface, or
  the whole app: OWASP-framed coverage tuned to ASP.NET Core MVC + EF Core/Dapper + SQL Server, a
  severity-ranked findings table with file:line evidence, and remediation matched to the tier. Use
  WHENEVER the user asks for a "security check", "security audit", "harden this", "is this safe",
  "lock this down", or a pass before a deploy/release. ALSO trigger when a change touches auth,
  session, input handling, file upload, secrets/connection strings, or dependencies — even if the
  user never says "security". Operates INDEPENDENTLY: it scopes the pass, gathers evidence, ranks
  findings, and remediates without being told each step. Invoke with /secure-me. Audit-and-harden
  only — "harden" splits by intent: hardening against attackers (authz, injection, secrets, attack
  surface) is this skill; robustness/refactor hardening of backend code stays with build-me.
  Feature work goes to build-me, UI to design-me / redesign-me, routing a mixed concern to do-me.
---

# secure-me

You are a **defensive security engineer** auditing and hardening this codebase — and only this
codebase, with the owner's authorization. The bar is not "ran a checklist" — it's "every finding is
real, anchored to file:line evidence, ranked by honest risk in *this* deployment, and either fixed or
prescribed precisely enough that a teammate can apply it without asking." You produce hardening, not
fear: a clean area is reported as clean, and a finding you can't evidence doesn't exist. **Strictly
defensive and authorized** — you never write offensive tooling, exploits, or anything aimed at a
system you don't own.

## Right-size first — an audit is a lens, not a dragnet

Gauge what the request actually is before mobilizing anything. The right amount of process is the
least that reliably answers the security question, not the most a full audit can produce.

- **Trivial** — a one-question check ("is this endpoint safe?", "is this query injectable?"): read
  the code, answer directly with file:line evidence, name the one-line fix if one is needed. No
  findings table, no plan, no agents.
- **Small** — a diff-scoped review of one change: check the diff against the coverage list where it
  applies (a new POST gets the authz/CSRF/injection lens; a config change gets the secrets/SQL-surface
  lens). Fix in place; a findings table only if there are findings.
- **Medium / Large** — a full-surface or whole-app audit: the complete coverage list, the findings
  table with clean areas noted, a remediation plan, and **human approval before sweeping changes**.
  Dispatch **security-tester** for the deep pass here.

**Anti-theater rules (these bind every tier):**

- **Over-flagging is the failure mode.** Severity is a claim about exploitability and impact in this
  deployment — an internal LGU system holding real citizens' records — not a generic scare table.
  Inflating severity to look thorough destroys the report's credibility and buries the real Blocker.
- A `TrustServerCertificate=True` in a dev-box connection string is **not a Blocker** — it's a Low
  with a prod-readiness note. Rank the actual risk, not the scariest reading of the keyword.
- **No finding without evidence.** File:line or config key, or it doesn't go in the table.
- Don't pad. An area checked and found clean is a *result* — state it in one line, don't invent a
  Medium to fill the row.
- Fixes are right-sized too: harden the actual hole. One `[ValidateAntiForgeryToken]` or one
  parameterized query does not justify a new security framework, middleware layer, or dependency.

## Coverage — what a full pass checks on this stack

The stack is ASP.NET Core MVC + Razor with EF Core/Dapper on SQL Server, holding government/LGU
records. Use **OWASP Top 10** as the frame and these stack-specific checks as the teeth:

- **Authn/authz on every entry point** — `[Authorize]` coverage on controllers and actions (no
  accidental anonymous mutations); role/policy checks that match the business rule; **IDOR** — every
  id taken from the request is scoped to the caller's rights, not merely existence-checked.
- **Injection** — Dapper/raw-SQL paths fully parameterized; no string-built WHERE clauses; `LIKE`
  inputs escape `%` and `_`; dynamic `ORDER BY` / column names come from a server-side whitelist,
  never from the request.
- **XSS in Razor** — audit every `@Html.Raw` (justify or remove each one); unencoded user data in
  inline scripts, URLs, and attributes.
- **CSRF** — anti-forgery tokens on every state-changing POST; no state changes on GET.
- **Session & auth flow** — cookie flags (Secure/HttpOnly/SameSite), sane timeout, session fixation
  handled on login, logout actually invalidates.
- **Secrets hygiene** — no credentials committed in `appsettings*.json`, `.env`, or hard-coded
  connection strings; **check git history**, not just the working tree; secrets live in
  user-secrets/environment/vault.
- **Dependencies** — NuGet/npm packages with known vulnerabilities or badly stale versions.
- **SQL Server surface** — the app connects with a least-privilege login, never `sa`; a read-only
  login where reads suffice; `TrustServerCertificate`/encryption deliberate per environment;
  integrated vs SQL auth a conscious choice.
- **File upload** — extension, content-type, and size validated; content verified, not trusted;
  stored outside the webroot or with execution disabled; filenames regenerated server-side.
- **Audit trail (government records)** — mutations of official records log who/what/when; a missing
  or bypassable trail on LGU records is a finding, not a nice-to-have.

## The pass

1. **Scope.** State what's in the pass — a question, a diff, a named surface, or the whole app — the
   tier, and what's explicitly out. Authorization is this repo, this owner; anything beyond it stops
   here.
2. **Gather evidence.** Read the entry points, configs, and data paths in scope; grep for the
   coverage list's smells (`Html.Raw`, concatenated SQL, missing `[Authorize]`, `sa` in connection
   strings, upload handlers). Every candidate finding gets its file:line anchor now.
3. **Rank honestly.** Blocker = exploitable now with real impact here; High = exploitable with
   preconditions or serious data exposure; Medium = weakens defense in depth; Low = hygiene or
   prod-readiness. Rank against this system's reality, per the anti-theater rules.
4. **Remediate per the tier.** **Blocker/High-severity findings: fix now** — apply the patch, or if
   the fix is behavioral or risky, propose the precise diff and say in one line why you didn't apply
   it. **Medium/Low-severity findings: document with the fix named** — exact change, exact place.
   **Medium/Large-tier passes** stop for human approval before sweeping changes (auth-model rework,
   connection-string migration, major dependency bumps).
5. **Re-test.** Verify the build passes, then hand post-hardening regression verification to
   `test-me` — brief it on what was hardened and which behaviors must still hold (the login still
   logs in, the upload still uploads) instead of improvising an ad-hoc re-test here. A hardening
   pass that breaks the app is a new incident.
6. **Report** per the output contract. Stage changes, respect hooks, don't auto-commit.

## Required output contract

Deliver these sections in order. Right-size the prose — a Trivial check is a few evidenced sentences
under the same headings, not a report — but don't drop a section silently.

### 1. Scope
What was audited, the tier, what was deliberately excluded, and which roles/tools were used vs
skipped (with the one-line reason).

### 2. Findings

```
| # | Finding | OWASP/area | Severity | Evidence (file:line) | Fix |
|---|---------|------------|----------|----------------------|-----|
| 1 | Search term concatenated into Dapper SQL | A03 Injection | Blocker | DocumentRepository.cs:214 | Parameterized; LIKE wildcards escaped |
| 2 | Delete action lacks anti-forgery validation | CSRF / A01 | High | DocumentsController.cs:88 | [ValidateAntiForgeryToken] added |
| 3 | TrustServerCertificate=True in dev config | SQL Server surface | Low | appsettings.Development.json | Keep in dev; require valid cert in prod |
```

Below the table, one line naming the areas checked and found clean, so coverage is auditable.

### 3. Fixes applied vs proposed
Two lists: what was changed in this pass, and what is proposed as a precise patch awaiting the human
(with the reason it wasn't applied).

### 4. Residual risk
What remains after this pass — accepted Lows, environmental items outside the repo (server config,
network posture), and anything time-bound (a dependency awaiting upstream patch).

### 5. Re-test note
How to confirm each fix and that the touched behavior still works — the commands, pages, or tests to
run.

## Definition of done — self-check before responding

- [ ] **Right-sized**: a one-question check got a direct evidenced answer, not a report; a full
      audit covered the whole coverage list or names what it skipped and why.
- [ ] Every finding carries file:line (or config-key) evidence — nothing speculative in the table.
- [ ] Severity is honest for this deployment — no theatrical Blockers, no buried real ones.
- [ ] Blocker/High-severity findings fixed, or the precise patch proposed with the one-line reason
      it wasn't applied.
- [ ] Medium/Low-severity findings documented with the exact fix named.
- [ ] Clean areas stated as checked-clean, so absence of findings reads as coverage, not a gap.
- [ ] Fixes re-tested: build passes, touched behavior verified, re-test note included.
- [ ] Human approval obtained before any sweeping change on Medium/Large-tier passes.
- [ ] Changes staged, hooks respected, nothing auto-committed.
- [ ] The defensive boundary held — no offensive tooling, no exploit code, nothing aimed beyond this
      codebase.

## Pairs well with

- **security-tester** (`.claude/agents`) — dispatch it for the deep pass on Medium/Large audits;
  this skill still scopes the work, ranks the findings, and owns the report.
- If installed, `security-review` for a branch-diff security pass and `code-review` at the review
  gate — use them, don't reimplement them.
- `build-me` — when a fix is structural (auth-model rework, data-layer overhaul), hand it there as a
  scoped backend concern instead of half-building it inside the audit.
- `test-me` — the reciprocal handoff: it routes security audits here by name, and step 5's
  post-hardening regression verification goes to it — briefed with what was hardened and which
  behaviors must still hold.

## Scope guard

This skill is **defensive security only**: audit and harden systems you own, with authorization. No
offensive tooling, no exploit development, no targets outside this codebase — decline such requests
and say why. A "harden" request splits by intent: hardening against attackers lands here;
robustness/refactor hardening of backend code goes to `build-me`. Feature work uncovered by the
audit goes to `build-me`; a functional (non-security) bug found along the way routes to `fix-me`; UI
concerns go to `design-me` / `redesign-me`.

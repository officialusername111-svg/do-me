# Production-Level Backend Architect — Competency Matrix

This is the knowledge base `build-me` operates from. It is **backend / server-side only** — no UX/UI,
visual design, or component work (that lives in `design-me`). Use it two ways:

- **When building**, pull the relevant areas into the work so output reflects engineering-lead practice,
  not just a handler that returns 200.
- **When auditing** (brownfield fix/refactor), use these as the **dimensions you score the current code
  against**. Each numbered area is an axis; find gaps, rate severity, remediate.

Don't dump this list at the user. Apply it. Reference specific items only when they explain a finding
or a decision. And remember the discipline that governs all of it: the simplest correct solution wins —
flag over-engineering (areas applied where the scope doesn't earn them) as a finding, not a virtue.

## Contents
1. API & Contract Design
2. Data Modeling & Schema
3. Query & Persistence
4. Business-Rule Correctness
5. Security & Authorization
6. Error Handling & Resilience
7. Performance & Scale
8. Observability & Audit
9. Testing
10. Maintainability

---

## 1. API & Contract Design
Clear endpoint/action contracts; DTOs / view models distinct from domain and persistence types; stable,
predictable shapes; validation at the boundary; correct status codes and error envelopes; idempotency
for unsafe operations that can be retried; sensible pagination/filtering contracts; versioning only when
a real consumer needs it. In MVC/Razor, the strongly-typed view model *is* the contract.
*Audit lens: domain entities leaked straight to the client, anaemic/over-broad DTOs, unvalidated input
reaching the action body, inconsistent error shapes, non-idempotent retryable writes, versioning nobody
asked for.*

## 2. Data Modeling & Schema
Normalization to the right degree (and deliberate denormalization only where justified); correct keys,
constraints, and foreign keys; indexes that match the real query patterns; nullable vs. required modeled
honestly; safe, reversible migrations; no schema change without a path forward and back.
*Audit lens: missing constraints/keys, no index on a hot filter/join, over-indexing writes, columns that
should be NOT NULL, destructive or irreversible migrations, "stringly-typed" data.*

## 3. Query & Persistence
Set-based over row-by-row; no N+1 (project, include, or batch deliberately); transactions scoped to the
unit of work; concurrency handled (optimistic tokens / appropriate isolation); parameterized queries
always; EF Core change-tracking understood (AsNoTracking for reads); stored procedures used where they
already are. Reads use the least-privilege login.
*Audit lens: N+1 loops, SELECT *, string-concatenated SQL, missing transactions across multi-step
writes, lost-update races, tracking on read-only queries, fetching more rows than rendered.*

## 4. Business-Rule Correctness
The domain logic is provably right: calculations (assessment values, tax, fees, procurement abstracts)
match the statutory/ordinance source; rounding and units are explicit; edge cases (zero, negative,
boundary dates, exemptions) handled; rules centralized, not scattered across controllers; effective
dates and rule versions respected where law changes over time.
*Audit lens: business math inline in a controller, magic numbers with no source, wrong rounding, missing
exemption/boundary handling, the same rule implemented two different ways, no handling of rule changes
over time.*

## 5. Security & Authorization
Authentication and **authorization on every entry point** (not just the UI hiding a button);
least-privilege DB logins; input validation and output encoding; protection against injection, IDOR,
mass-assignment/over-posting, CSRF, and SSRF; secrets out of source and config-managed; sensitive data
handled per policy. Follow OWASP; lean on `owasp-review` when installed.
*Audit lens: endpoints trusting client-side checks, over-posting via model binding, IDOR (no ownership
check on an id), secrets in code/appsettings, unparameterized input, missing CSRF on state-changing
posts, broad service-account permissions.*

## 6. Error Handling & Resilience
Distinguish expected failures (validation, not-found, conflict) from unexpected ones; fail with a clear,
non-leaky message and the right status; no swallowed exceptions; retries/timeouts on external calls only
where safe and idempotent; graceful degradation when a dependency is down; guard against duplicate
submits.
*Audit lens: catch-and-ignore, leaking stack traces/SQL to the client, 200 on failure, no timeout on an
external call, retrying a non-idempotent write, one slow dependency taking the whole request down.*

## 7. Performance & Scale
Cost-aware queries and round-trips; pagination on unbounded lists; caching **only** where a measured or
obvious need justifies it (and with a correct invalidation story); async I/O without blocking; avoid
premature optimization as carefully as you avoid obvious waste.
*Audit lens: unbounded result sets, per-request work that could be cached or hoisted, sync-over-async,
chatty round-trips, a cache added "for speed" with no eviction plan, optimizing a path that isn't hot.*

## 8. Observability & Audit
Structured logging at the right level (not noise, not silence); correlation across a request; an **audit
trail** for data changes the domain/regulation requires (who changed what, when, old→new); errors are
diagnosable from logs without a repro. Government data especially needs the trail.
*Audit lens: no logs on the failure path, logging secrets/PII, no audit trail on a regulated change, logs
too sparse to diagnose or so chatty they're useless, no way to correlate a user action to its records.*

## 9. Testing
The right test at the right level: unit tests for business rules and pure logic; integration tests for
the data layer and the contract; a few end-to-end checks for critical flows. Tests assert behaviour and
edge cases, not just the happy path. This is BT's remit; BT is read-only and reports, TL re-dispatches
fixes.
*Audit lens: business math with no unit test, no test crossing the DB boundary, happy-path-only coverage,
tests asserting implementation instead of behaviour, flaky/order-dependent tests, no test for the bug
just fixed.*

## 10. Maintainability
Separation of concerns (controller thin, logic in services, data access isolated); names that reveal
intent; no premature abstraction and no copy-paste duplication; consistent with existing project
patterns; dead code removed; complexity matched to the problem. The next maintainer should not need a
guide.
*Audit lens: fat controllers with business logic, a repository/generic-CRUD layer wrapping a single EF
call, speculative interfaces with one implementation, duplicated rules, inconsistent patterns across the
codebase, clever code where boring code would do.*

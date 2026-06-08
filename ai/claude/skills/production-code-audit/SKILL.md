---
name: production-code-audit
description: "Autonomously deep-scan entire codebase line-by-line, understand architecture and patterns, then systematically transform it to production-grade, corporate-level professional quality with optimizations"
effort: high
context: fork
---

# Production Code Audit

For read-only audits (report without fixing), prefer the `code-reviewer` agent instead.

Scan the entire codebase autonomously, identify all issues, fix them, and report results. Do all of this without asking the user for input.

## Step 0: Preflight

Destructive scope. Before touching any file, confirm with the user:

1. Current branch is a fork or throwaway branch, not `main`/`master`/`develop`.
2. Working tree is clean (`git status` empty) or all changes committed.
3. A backup ref exists: `git tag audit-backup-$(date +%s)` before Step 3.

Abort if any check fails. Never run Step 3 on a branch with uncommitted work or on a shared/protected branch.

## Step 1: Codebase Discovery

Read every source file. Identify:
- Tech stack (languages, frameworks, databases, tools)
- Architecture (structure, patterns, dependencies)
- Entry points and data flow

## Step 2: Issue Detection

Scan line-by-line for:

**Architecture:** Circular dependencies, tight coupling, god classes (>500 lines / >20 methods), poor module boundaries

**Security:** SQL injection, XSS, hardcoded secrets, missing auth/authz, weak password hashing (MD5/SHA1), missing input validation, CSRF, insecure dependencies

**Performance:** N+1 queries, missing DB indexes, missing caching, inefficient algorithms (O(n²)+), unoptimized assets, memory leaks

**Code quality:** High cyclomatic complexity (>10), duplication, magic numbers, poor naming, dead code, TODO/FIXME

**Testing:** Missing critical path tests, coverage <80%, no edge cases, flaky tests

**Production readiness:** Missing env vars, no logging/monitoring/error tracking, no health checks

## Step 3: Fix Everything

1. Refactor architecture (break up god classes, fix circular deps)
2. Fix security issues (parameterized queries, remove secrets, add validation)
3. Optimize performance (fix N+1, add caching, optimize algorithms)
4. Improve code quality (reduce complexity, remove duplication, fix naming)
5. Add missing tests for critical paths
6. Add production infrastructure (logging, monitoring, health checks)

## Step 4: Verify and Report

1. Run all tests
2. Measure before/after improvements
3. Report findings with grades per category (A-F)

## Audit Checklist

**Security**
- [ ] No SQL injection
- [ ] No hardcoded secrets
- [ ] Auth on protected routes
- [ ] Input validation on all endpoints
- [ ] bcrypt password hashing (10+ rounds)
- [ ] No dependency vulnerabilities

**Performance**
- [ ] No N+1 queries
- [ ] DB indexes on foreign keys
- [ ] Caching implemented
- [ ] API response < 200ms
- [ ] Bundle size < 200KB gzipped

**Testing**
- [ ] Coverage > 80%
- [ ] Critical paths tested
- [ ] No flaky tests
- [ ] Tests run in CI

**Production readiness**
- [ ] Env vars configured
- [ ] Error tracking (Sentry)
- [ ] Structured logging
- [ ] Health check endpoints
- [ ] Monitoring and alerting

## Report Template

```markdown
# Production Audit Report

**Project:** [Name]  **Date:** [Date]  **Grade:** [A-F]

## Summary
[2-3 sentences]

**Critical:** [count] | **High:** [count] | **Recommendation:** [timeline]

## Findings

### Architecture [A-F]
### Security [A-F]
### Performance [A-F]
### Testing — Coverage: [%]

## Priority Actions
1. [Critical] — [timeline]
2. [High] — [timeline]

## Timeline
- Critical: [X weeks]
- Production ready: [X weeks]
```

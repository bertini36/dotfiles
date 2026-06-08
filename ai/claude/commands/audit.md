---
description: Run full production audit on the current project
---

Run a comprehensive production audit:

1. Dispatch the `code-reviewer` agent to scan for architecture, performance, code quality, and testing issues
2. Dispatch the `security-reviewer` agent to scan for vulnerabilities
3. Combine findings into a unified report with grades per category (A-F)
4. List priority actions ordered by severity

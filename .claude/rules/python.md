---
paths:
  - "**/*.py"
---

# Python Conventions

- Python 3.12+ syntax; use modern features (`match`, `|` union types, `tomllib`, `dataclasses`, etc.)
- Package management with `uv` (not `pip` directly)
- Linting and formatting with `ruff` (replaces flake8, isort, black)
- Naming: `snake_case` for functions/variables, `PascalCase` for classes, `SCREAMING_SNAKE_CASE` for constants. Never prepend constants with `_` (e.g. `SECRET_KEY`, not `_SECRET_KEY`)
- Only prefix functions with `_` when intended for internal/local use within a module; never use `_` prefix on variables or constants
- Line length: 120 characters
- Absolute imports only; group as stdlib, third-party, local
- Activate the venv before running Python/pytest/ruff/Django commands: `workon` or `source .venv/bin/activate`. Check if `source config/postactivate` is also needed.
- Use the `python-code-style` skill for type annotations, generics, protocols, and detailed patterns

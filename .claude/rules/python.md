---
paths:
  - "**/*.py"
---

# Python Conventions

- Python 3.13+ syntax; use modern features (`match`, `|` union types, `tomllib`, `dataclasses`, etc.)
- Package management with `uv` (not `pip` directly)
- Linting and formatting with `ruff` (replaces flake8, isort, black)
- Naming: `snake_case` for functions/variables, `PascalCase` for classes, `SCREAMING_SNAKE_CASE` for constants. Never prepend constants with `_` (e.g. `SECRET_KEY`, not `_SECRET_KEY`)
- Only prefix functions with `_` when intended for internal/local use within a module; never use `_` prefix on variables or constants
- Line length: 120 characters
- Absolute imports only; group as stdlib, third-party, local
- Activate the venv before running Python/pytest/ruff/Django commands: `workon` or `source .venv/bin/activate`. Check if `source config/postactivate` is also needed.
- Use the `python-code-style` skill for type annotations, generics, protocols, and detailed patterns

## Performance

The database rules are Django ORM guidance; in other stacks translate the intent (no queries in loops, batch writes) to the ORM at hand.

- Never query inside a loop. Fix N+1 at the queryset origin with `select_related` (FK/OneToOne) or `prefetch_related` (M2M/reverse FK).
- Compute in the database with `annotate`/`aggregate` instead of looping over model instances in Python.
- Batch writes: `bulk_create`, `bulk_update`, queryset `update()`. Never `.save()` in a loop.
- Fetch only what you need in hot paths: `values()`, `values_list()`, or `only()`.
- Guard list endpoints and relation-heavy serializers with a query-count assertion, so a future N+1 fails a test instead of production. Django has `django_assert_num_queries`; elsewhere use what the stack exposes (SQLAlchemy's `before_cursor_execute`, a query-log context manager).
- No premature caching. Measure first (`connection.queries`, query logs); cache only proven hot spots, always with an invalidation story.

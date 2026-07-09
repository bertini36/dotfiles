---
paths:
  - "**/*.py"
---

# Performance Conventions

The database sections below are Django ORM guidance; apply them in Django
projects and translate the intent (no queries in loops, batch writes) to the
ORM at hand elsewhere.

## Database access

- Never query inside a loop. Fix N+1 at the queryset origin with `select_related` (FK/OneToOne) or `prefetch_related` (M2M/reverse FK).
- Compute in the database with `annotate`/`aggregate` instead of looping over model instances in Python.
- Batch writes: `bulk_create`, `bulk_update`, queryset `update()`. Never `.save()` in a loop.
- Fetch only what you need in hot paths: `values()`, `values_list()`, or `only()`.

## Tests as query guards

- Any test covering a list endpoint or a serializer with relations asserts the query count with the `django_assert_num_queries` fixture, so a future N+1 fails a test instead of production.

## Caching

- No premature caching. Measure first (`connection.queries`, query logs); cache only proven hot spots, always with an invalidation story.

Deep patterns: `django-patterns` skill.

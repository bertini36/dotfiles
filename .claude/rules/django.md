---
paths:
  - "**/views.py"
  - "**/views/**/*.py"
  - "**/models.py"
  - "**/models/**/*.py"
  - "**/serializers.py"
  - "**/serializers/**/*.py"
  - "**/urls.py"
  - "**/admin.py"
  - "**/management/**/*.py"
  - "**/settings/**/*.py"
  - "**/migrations/**/*.py"
---

# Django Conventions

- Use the `django-patterns` skill for architecture, model design, service layer, caching, and ORM optimization; run it before completing any Django task

## Performance

- Never query inside a loop. Fix N+1 at the queryset origin with `select_related` (FK/OneToOne) or `prefetch_related` (M2M/reverse FK).
- Compute in the database with `annotate`/`aggregate` instead of looping over model instances in Python.
- Batch writes: `bulk_create`, `bulk_update`, queryset `update()`. Never `.save()` in a loop.
- Fetch only what you need in hot paths: `values()`, `values_list()`, or `only()`.
- Guard list endpoints and relation-heavy serializers with a query-count assertion, so a future N+1 fails a test instead of production: `django_assert_num_queries`.
- No premature caching. Measure first (`connection.queries`, query logs); cache only proven hot spots, always with an invalidation story.

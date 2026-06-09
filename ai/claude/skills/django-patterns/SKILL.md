---
name: django-patterns
description: Django architecture patterns, REST API design with Pydantic for validation and serialization, ORM best practices, caching, signals, middleware, and production-grade Django apps.
effort: high
---

# Django Development Patterns

Production-grade Django architecture patterns for scalable, maintainable applications.

## Core Rules

- Views stay thin: parse and validate with Pydantic, delegate business logic to a service layer, return `JsonResponse`
- Define input and output schemas separately in `schemas.py`
- Reusable queries live in custom QuerySets exposed via `as_manager()`; always `select_related`/`prefetch_related` to kill N+1
- Split settings per environment (`base`/`development`/`production`/`test`); secrets come from env vars, never hardcoded
- Cache expensive reads with explicit keys and timeouts
- Signals only for cross-app side effects; register them in `AppConfig.ready()`

## References

Read only the file relevant to the task:

| File | Read when working on |
|---|---|
| `references/project-structure.md` | Project layout, split settings, production security flags, logging config |
| `references/models-and-orm.md` | Models, custom QuerySets and Managers, indexes, constraints, `select_related`/`prefetch_related`, defer/only, bulk operations |
| `references/api-pydantic.md` | REST endpoints, Pydantic input/output schemas, request body parsing, validation error handling |
| `references/services-caching-signals.md` | Service layer, caching (view, fragment, low-level, queryset), signals, custom middleware |

## Quick Reference

| Pattern | Description |
|---------|-------------|
| Split settings | Separate dev/prod/test settings |
| Custom QuerySet | Reusable query methods |
| Service Layer | Business logic separation |
| Django class-based views | REST API endpoints |
| Pydantic schemas | Request/response validation and serialization |
| select_related | Foreign key optimization |
| prefetch_related | Many-to-many optimization |
| Cache first | Cache expensive operations |
| Signals | Event-driven actions |
| Middleware | Request/response processing |

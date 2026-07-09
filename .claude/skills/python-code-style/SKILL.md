---
name: python-code-style
description: Python type safety patterns, generics, protocols, and advanced type annotations. Use when adding type annotations, implementing generic classes, defining structural interfaces, or configuring type checkers.
effort: high
---

# Python Type Safety & Advanced Patterns

This skill covers type checking configuration, advanced type annotations, generics, protocols, and callable types. For basic conventions (naming, imports, line length, tooling), see the `python` rule.

## Configuration

### Type Checking Configuration

Configure strict type checking for production code.

```toml
# pyproject.toml
[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_ignores = true
disallow_untyped_defs = true
disallow_incomplete_defs = true

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false
```

Alternative: Use `pyright` for faster checking.

```toml
[tool.pyright]
pythonVersion = "3.12"
typeCheckingMode = "strict"
```

## Type Safety Patterns

### Pattern 9: Annotate All Public Signatures

Every public function, method, and class should have type annotations.

**Never annotate `-> None`.** Omit the return annotation entirely when a function returns nothing — it adds noise without value.

```python
# Bad: -> None is redundant and noisy
def reset_cache() -> None:
    self._cache.clear()

class UserRepository:
    def __init__(self, db: Database) -> None:
        self._db = db

# Good: omit the return annotation
def reset_cache():
    self._cache.clear()

class UserRepository:
    def __init__(self, db: Database):
        self._db = db
```

```python
def get_user(user_id: str) -> User:
    """Retrieve user by ID."""
    ...

def process_batch(
    items: list[Item],
    max_workers: int = 4,
) -> BatchResult[ProcessedItem]:
    """Process items concurrently."""
    ...

class UserRepository:
    def __init__(self, db: Database):
        self._db = db

    async def find_by_id(self, user_id: str) -> User | None:
        """Return User if found, None otherwise."""
        ...

    async def save(self, user: User) -> User:
        """Save and return user with generated ID."""
        ...
```

Use `mypy --strict` or `pyright` in CI to catch type errors early. For existing projects, enable strict mode incrementally using per-module overrides.

### Pattern 10: Use Modern Union Syntax

Python 3.10+ provides cleaner union syntax.

```python
# Preferred (3.10+)
def find_user(user_id: str) -> User | None:
    ...

def parse_value(v: str) -> int | float | str:
    ...

# Older style (still valid, needed for 3.9)
from typing import Optional, Union

def find_user(user_id: str) -> Optional[User]:
    ...
```

### Pattern 11: Type Narrowing with Guards

Use conditionals to narrow types for the type checker.

```python
def process_user(user_id: str) -> UserData:
    user = find_user(user_id)

    if user is None:
        raise UserNotFoundError(f"User {user_id} not found")

    # Type checker knows user is User here, not User | None
    return UserData(
        name=user.name,
        email=user.email,
    )

def process_items(items: list[Item | None]) -> list[ProcessedItem]:
    # Filter and narrow types
    valid_items = [item for item in items if item is not None]
    # valid_items is now list[Item]
    return [process(item) for item in valid_items]
```

### Pattern 12: Generic Classes

Create type-safe reusable containers.

```python
from typing import TypeVar, Generic

T = TypeVar("T")
E = TypeVar("E", bound=Exception)

class Result(Generic[T, E]):
    """Represents either a success value or an error."""

    def __init__(
        self,
        value: T | None = None,
        error: E | None = None,
    ) -> None:
        if (value is None) == (error is None):
            raise ValueError("Exactly one of value or error must be set")
        self._value = value
        self._error = error

    def unwrap(self) -> T:
        """Get value or raise the error."""
        if self._error is not None:
            raise self._error
        return self._value  # type: ignore[return-value]

    def unwrap_or(self, default: T) -> T:
        """Get value or return default."""
        if self._error is not None:
            return default
        return self._value  # type: ignore[return-value]

# Usage preserves types
def parse_config(path: str) -> Result[Config, ConfigError]:
    try:
        return Result(value=Config.from_file(path))
    except ConfigError as e:
        return Result(error=e)
```

### Pattern 13: Generic Repository

Create type-safe data access patterns.

```python
from typing import TypeVar, Generic
from abc import ABC, abstractmethod

T = TypeVar("T")
ID = TypeVar("ID")

class Repository(ABC, Generic[T, ID]):
    """Generic repository interface."""

    @abstractmethod
    async def get(self, id: ID) -> T | None: ...

    @abstractmethod
    async def save(self, entity: T) -> T: ...

    @abstractmethod
    async def delete(self, id: ID) -> bool: ...

class UserRepository(Repository[User, str]):
    async def get(self, id: str) -> User | None:
        row = await self._db.fetchrow("SELECT * FROM users WHERE id = $1", id)
        return User(**row) if row else None
```

### Pattern 14: TypeVar with Bounds

Restrict generic parameters to specific types.

```python
from typing import TypeVar
from pydantic import BaseModel

ModelT = TypeVar("ModelT", bound=BaseModel)

def validate_and_create(model_cls: type[ModelT], data: dict) -> ModelT:
    """Create a validated Pydantic model from dict."""
    return model_cls.model_validate(data)

# user is typed as User
user = validate_and_create(User, {"name": "Alice", "email": "a@b.com"})

# Type error: str is not a BaseModel subclass
result = validate_and_create(str, {"name": "Alice"})  # Error!
```

### Pattern 15: Protocols for Structural Typing

Define interfaces without requiring inheritance.

```python
from typing import Protocol, runtime_checkable

@runtime_checkable
class Serializable(Protocol):
    def to_dict(self) -> dict: ...

    @classmethod
    def from_dict(cls, data: dict) -> "Serializable": ...

# User satisfies Serializable without inheriting from it
class User:
    def to_dict(self) -> dict:
        return {"id": self.id, "name": self.name}

    @classmethod
    def from_dict(cls, data: dict) -> "User":
        return cls(id=data["id"], name=data["name"])

def serialize(obj: Serializable) -> str:
    return json.dumps(obj.to_dict())
```

Common protocol patterns:

```python
class Closeable(Protocol):
    def close(self) -> None: ...

class AsyncCloseable(Protocol):
    async def close(self) -> None: ...

class HasId(Protocol):
    @property
    def id(self) -> str: ...

class Comparable(Protocol):
    def __lt__(self, other: "Comparable") -> bool: ...
    def __le__(self, other: "Comparable") -> bool: ...
```

### Pattern 16: Type Aliases

Create meaningful type names.

```python
# Python 3.10+ type statement for simple aliases
type UserId = str
type UserDict = dict[str, Any]

# Python 3.12+ type statement with generics
type Handler[T] = Callable[[Request], T]

# Python 3.9-3.11 style
from typing import TypeAlias
UserId: TypeAlias = str
Handler: TypeAlias = Callable[[Request], Response]
```

### Pattern 17: Callable Types

Type function parameters and callbacks.

```python
from collections.abc import Callable, Awaitable

# Sync callback
ProgressCallback = Callable[[int, int], None]  # (current, total)

# Async callback
AsyncHandler = Callable[[Request], Awaitable[Response]]

# With named parameters (using Protocol)
class OnProgress(Protocol):
    def __call__(self, current: int, total: int, *, message: str = "") -> None: ...

def process_items(
    items: list[Item],
    on_progress: ProgressCallback | None = None,
) -> list[Result]:
    ...
```

## Best Practices

1. **Annotate all public APIs** - Functions, methods, class attributes; omit `-> None` (adds noise without value)
2. **Use `T | None`** - Modern union syntax over `Optional[T]`
3. **Enable strict mypy** - Catch type errors before runtime
4. **Use generics** - Preserve type info in reusable code
5. **Define protocols** - Structural typing for interfaces
6. **Narrow types** - Use guards to help the type checker
7. **Bound type vars** - Restrict generics to meaningful types
8. **Create type aliases** - Meaningful names for complex types
9. **Minimize `Any`** - Use specific types or generics; `Any` is acceptable only for truly dynamic data or untyped third-party code

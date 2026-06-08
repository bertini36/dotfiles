---
name: ddd-patterns
description: DDD patterns - Entities, Aggregate Roots, value objects, Repositories, Domain Services, Domain Events, Specifications. Use when designing domain layer, creating entities, repositories, or domain services.
---

# DDD Patterns (Python)

## Django Projects: Pragmatic Approach

**Do not force full DDD on Django projects.** Django's ORM, admin, and conventions work against a strict domain layer. Imposing it creates unnecessary friction.

**The one rule that matters:** keep business logic out of views.

- Views handle HTTP concerns only: parse input, call a service, return a response
- Put logic in **domain services** — plain Python classes that accept and return values
- Django models can hold simple invariants and methods, but complex cross-model logic belongs in services
- No need for abstract repositories, aggregate roots, or domain events unless the complexity genuinely warrants it

```python
# Bad: logic in view
def complete_order(request, order_id):
    order = Order.objects.get(id=order_id)
    if order.status != "created":
        return HttpResponse(status=400)
    order.status = "completed"
    order.save()
    send_confirmation_email(order)
    return HttpResponse(status=200)

# Good: view delegates to service
def complete_order(request, order_id):
    try:
        order_service.complete(order_id)
    except OrderException as e:
        return HttpResponse(str(e), status=400)
    return HttpResponse(status=200)
```

---

## Anti-Patterns to Avoid

- **Anemic entities**: public attributes with no behavior — use private state + methods that enforce invariants
- **Repository for child entities**: only aggregate roots get repositories — access child entities through their root
- **Generating IDs in entity constructor**: generate `uuid` outside and pass as parameter
- **References to other aggregates by object**: reference by `id` only, never hold the full aggregate object
- **Domain service depending on current user**: accept values from the application layer instead
- **Mutable value objects**: value objects must be immutable (`frozen=True`)

## Rich Domain Model vs Anemic Domain Model

| Anemic (Anti-pattern) | Rich (Recommended) |
|----------------------|-------------------|
| Entity = data only | Entity = data + behavior |
| Logic in services | Logic in entity methods |
| Public attributes | Private state with methods |
| No validation in entity | Entity enforces invariants |

**Encapsulation is key**: Protect entity state with private attributes and expose behavior through methods.

## Entities

```python
from dataclasses import dataclass, field
from uuid import UUID
from decimal import Decimal


class DomainException(Exception):
    pass


@dataclass
class OrderLine:
    id: UUID
    product_id: UUID
    _count: int = field(repr=False)
    price: Decimal

    def __post_init__(self) -> None:
        self._validate_count(self._count)

    @property
    def count(self) -> int:
        return self._count

    def set_count(self, count: int) -> None:
        self._validate_count(count)
        self._count = count

    @staticmethod
    def _validate_count(count: int) -> None:
        if count <= 0:
            raise DomainException("Order line count must be positive")
```

## Aggregate Roots

Aggregate roots are consistency boundaries that:
- Own their child entities
- Enforce business rules across the aggregate
- Publish domain events

```python
from dataclasses import dataclass, field
from uuid import UUID
from decimal import Decimal
from enum import Enum


class OrderStatus(Enum):
    CREATED = "created"
    COMPLETED = "completed"


@dataclass
class Order:
    id: UUID
    order_number: str
    customer_id: UUID
    _status: OrderStatus = field(default=OrderStatus.CREATED, repr=False)
    _lines: list[OrderLine] = field(default_factory=list, repr=False)
    _events: list[object] = field(default_factory=list, repr=False)

    def __post_init__(self) -> None:
        if not self.order_number.strip():
            raise DomainException("Order number cannot be empty")

    @property
    def status(self) -> OrderStatus:
        return self._status

    @property
    def lines(self) -> list[OrderLine]:
        return list(self._lines)  # Defensive copy

    def add_line(self, line_id: UUID, product_id: UUID, count: int, price: Decimal) -> None:
        if self._status != OrderStatus.CREATED:
            raise DomainException("Cannot modify a non-created order")
        self._lines.append(OrderLine(id=line_id, product_id=product_id, _count=count, price=price))

    def complete(self) -> None:
        if self._status != OrderStatus.CREATED:
            raise DomainException("Cannot complete a non-created order")
        self._status = OrderStatus.COMPLETED
        self._events.append(OrderCompletedEvent(order_id=self.id))

    def pull_events(self) -> list[object]:
        """Drain and return pending domain events."""
        events, self._events = self._events, []
        return events
```

### Domain Events

```python
from dataclasses import dataclass
from uuid import UUID


@dataclass(frozen=True)
class OrderCompletedEvent:
    order_id: UUID
```

Collect events on the aggregate via `pull_events()`. Dispatch them in the application layer after persisting.

### Entity Best Practices

- **Encapsulation**: Private attributes (`_name`), public properties and methods that enforce rules
- **Constructor validation**: Enforce invariants in `__post_init__`
- **Defensive copies**: Return `list(self._items)` to prevent external mutation
- **Reference by id**: Never hold another aggregate object — use its `id`
- **Don't generate IDs inside the entity**: Pass `uuid4()` from outside

## Value Objects

Value objects are immutable and defined by their attributes, not identity.

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str

    def __post_init__(self) -> None:
        if self.amount < 0:
            raise DomainException("Amount cannot be negative")
        if len(self.currency) != 3:
            raise DomainException("Currency must be a 3-letter ISO code")

    def add(self, other: "Money") -> "Money":
        if self.currency != other.currency:
            raise DomainException("Cannot add different currencies")
        return Money(amount=self.amount + other.amount, currency=self.currency)


@dataclass(frozen=True)
class Email:
    value: str

    def __post_init__(self) -> None:
        if "@" not in self.value:
            raise DomainException(f"Invalid email: {self.value}")
```

## Repository Pattern

### When to Use a Custom Repository

- **Generic repository**: Sufficient for simple CRUD
- **Custom repository**: Only when you need domain-specific query methods

### Interface (Domain Layer)

```python
from abc import ABC, abstractmethod
from uuid import UUID


class OrderRepository(ABC):
    @abstractmethod
    async def get(self, order_id: UUID) -> Order | None: ...

    @abstractmethod
    async def save(self, order: Order) -> None: ...

    @abstractmethod
    async def find_by_order_number(self, order_number: str) -> Order | None: ...

    @abstractmethod
    async def list_by_customer(self, customer_id: UUID) -> list[Order]: ...
```

Implementation lives in the infrastructure layer.

### Repository Best Practices

- **One repository per aggregate root** — never create repositories for child entities
- Child entities are accessed and modified only through their aggregate root
- Interface in domain layer, implementation in infrastructure layer
- Return domain objects, not ORM models or dicts
- Use `| None` return for single-entity lookups

## Domain Services

Use domain services for business logic that:
- Spans multiple aggregates
- Requires repository queries to enforce rules

```python
from uuid import uuid4, UUID


class OrderService:
    def __init__(
        self,
        order_repository: OrderRepository,
        product_repository: ProductRepository,
    ) -> None:
        self._orders = order_repository
        self._products = product_repository

    async def create(self, order_number: str, customer_id: UUID) -> Order:
        existing = await self._orders.find_by_order_number(order_number)
        if existing is not None:
            raise DomainException(f"Order number '{order_number}' already exists")
        return Order(id=uuid4(), order_number=order_number, customer_id=customer_id)

    async def add_product(self, order: Order, product_id: UUID, count: int) -> None:
        product = await self._products.get(product_id)
        if product is None:
            raise DomainException(f"Product {product_id} not found")
        order.add_line(
            line_id=uuid4(),
            product_id=product_id,
            count=count,
            price=product.price,
        )
```

### Domain Service Best Practices

- Accept and return domain objects, not DTOs
- Don't depend on authenticated user — accept identity values from the application layer
- Name with the aggregate they coordinate (e.g., `OrderService`, `OrderManager`)
- No interface by default — add one only if multiple implementations are needed

## Specifications

Reusable, composable query predicates:

```python
from abc import ABC, abstractmethod
from typing import Generic, TypeVar

T = TypeVar("T")


class Specification(ABC, Generic[T]):
    @abstractmethod
    def is_satisfied_by(self, entity: T) -> bool: ...

    def and_(self, other: "Specification[T]") -> "Specification[T]":
        return _AndSpecification(self, other)

    def or_(self, other: "Specification[T]") -> "Specification[T]":
        return _OrSpecification(self, other)


@dataclass
class _AndSpecification(Specification[T]):
    left: Specification[T]
    right: Specification[T]

    def is_satisfied_by(self, entity: T) -> bool:
        return self.left.is_satisfied_by(entity) and self.right.is_satisfied_by(entity)


@dataclass
class _OrSpecification(Specification[T]):
    left: Specification[T]
    right: Specification[T]

    def is_satisfied_by(self, entity: T) -> bool:
        return self.left.is_satisfied_by(entity) or self.right.is_satisfied_by(entity)


class CompletedOrdersSpec(Specification[Order]):
    def is_satisfied_by(self, order: Order) -> bool:
        return order.status == OrderStatus.COMPLETED


# Usage
spec = CompletedOrdersSpec()
completed = [o for o in orders if spec.is_satisfied_by(o)]
```

## Best Practices Summary

1. **Rich domain model** — entities hold behavior, not just data
2. **Enforce invariants in `__post_init__`** — never allow an invalid entity to exist
3. **Immutable value objects** — use `@dataclass(frozen=True)`
4. **Reference aggregates by id** — never hold a foreign aggregate object
5. **Only aggregate roots get repositories** — child entities go through the root
6. **Generate ids outside the entity** — pass `uuid4()` from the application layer
7. **Drain events with `pull_events()`** — dispatch in the application layer after persistence
8. **Domain services for cross-aggregate logic** — not for single-aggregate operations
9. **Specifications for reusable predicates** — compose with `and_` / `or_`
10. **Raise `DomainException`** — never return error codes or None for rule violations

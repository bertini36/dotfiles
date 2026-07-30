---
name: domain-service-layer
description: Where business logic lives in a Django app - domain services own every business rule and validation, views only do HTTP, serializers only type the input, factories wire the dependencies, and tests split between unit tests per rule and API tests per status code. Also covers entities, value objects and domain events for the cases that need them. Use when adding a feature to a Django app, deciding where a rule belongs, moving logic out of a view or model, wiring a service, or choosing what to unit test.
---

# Domain Service Layer (Python, Django)

This is not textbook DDD. It borrows the parts that pay off in a Django codebase and drops the parts that fight the framework.

## The Core Rule

**Every business rule and every business validation lives in a domain service.** Nothing else in the stack decides anything.

```
HTTP request
    |
    v
View            parse the request, hand off, turn the result into a response
    |           no rules, no queries, no branching on domain state
    v
Serializer      shape and types only, produces a typed DTO
    |
    v
Factory         builds the service with its dependencies
    |
    v
Domain service  <-- ALL business logic and business validation lives here
    |               queries the Django ORM directly
    v
Django ORM / models
```

A rule that appears anywhere other than a domain service is misplaced. The four usual leaks:

| Leak | Move it |
|---|---|
| `if order.status != "created": return 400` in a view | into the service |
| A serializer querying the database to decide whether the operation is allowed | into the service |
| A model method spanning several models and side effects | into the service |
| A Celery task with the logic inline | into a service the task calls |

### What counts as business logic

Anything a product owner could change their mind about:

- Whether an operation is allowed right now, given the state of the data
- What happens as a consequence, including side effects like emails and events
- Any calculation, threshold, limit, or eligibility check
- Any cross-model consistency rule
- Any decision that reads the database to decide

Not business logic: field types, required fields, max lengths, HTTP status selection, serialization.

## Views Do HTTP Only

A view validates and types the input through a serializer, calls a service or use case, and returns a response.

```python
# Bad: parsing, validation, and rules in the view
def complete_order(request, order_id):
    order = Order.objects.get(id=order_id)
    if order.status != "created":
        return HttpResponse(status=400)
    order.status = "completed"
    order.save()
    send_confirmation_email(order)
    return HttpResponse(status=200)


# Good: serializer types the input, factory builds the service, service owns the rules
class OrderCompleteView(APIView):
    def post(self, request: "Request", order_id: "UUID") -> Response:
        validator = OrderCompleteRequestValidator(data=request.data)
        validator.is_valid(raise_exception=True)
        data = validator.build_dto()

        build_complete_order_service().execute(order_id, data)

        return Response(status=status.HTTP_204_NO_CONTENT)
```

The view above has no `if`. That is the target shape.

### Serializers Type, Services Validate

Two different jobs. Do not mix them.

| | Serializer | Domain service |
|---|---|---|
| Checks | Shape and type: required fields, `UUIDField`, `max_length`, choices | Business rules: does this order exist, can it be completed, is the customer over their limit |
| Fails with | DRF `ValidationError`, becoming a `400` | A domain exception the view maps to a status |
| Needs the database | No | Usually yes |
| Output | A typed DTO via `build_dto()` | Domain objects or nothing |

```python
class OrderCompleteRequestValidator(serializers.Serializer):
    completed_at = serializers.DateTimeField(required=True)
    note = serializers.CharField(required=False, max_length=200)

    def build_dto(self) -> "OrderCompleteDTO":
        return OrderCompleteDTO(
            completed_at=self.validated_data["completed_at"],
            note=self.validated_data.get("note"),
        )
```

If a serializer needs a query to decide, the rule belongs in the service.

## Domain Services

```python
from uuid import UUID


class CompleteOrderService:
    def __init__(self, notifications: NotificationService) -> None:
        self._notifications = notifications

    def execute(self, order_id: UUID, data: OrderCompleteDTO) -> None:
        order = Order.objects.get(id=order_id)            # ORM used directly

        if order.status != OrderStatus.CREATED:           # the rule lives here
            raise DomainException("Cannot complete a non-created order")

        order.status = OrderStatus.COMPLETED
        order.completed_at = data.completed_at
        order.save(update_fields=["status", "completed_at"])

        self._notifications.order_completed(order.id)     # collaborator, injected
```

### Use the ORM Directly

**Do not put a repository layer on top of the Django ORM, and do not inject the ORM.**

Django's ORM is already the data access layer. A repository wrapping it adds a file, an indirection, and a second vocabulary for the same queries, and buys nothing back: the interface leaks `QuerySet` semantics anyway, and a fake implementation drifts from real SQL until the test proves nothing. Services call `Model.objects` where they need data.

For a query genuinely reused across services, use the Django-native tool, a custom `QuerySet` or `Manager` on the model, not a new repository class:

```python
class OrderQuerySet(models.QuerySet):
    def pending_for_customer(self, customer_id: UUID) -> "OrderQuerySet":
        return self.filter(customer_id=customer_id, status=OrderStatus.CREATED)


class Order(models.Model):
    objects = OrderQuerySet.as_manager()
```

Services that touch the ORM are tested against a real database with `pytest.mark.django_db`. That is what makes the test worth having.

### Inject Collaborators, Not Data Access

Constructor injection is still the rule for everything that is not the ORM: other services, gateways, HTTP or S3 clients, notification senders. Those are the seams worth having, because a test wants to assert an email was sent without sending one.

```python
class CreateOrderService:
    def __init__(self, pricing: PricingService, notifications: NotificationService) -> None:
        self._pricing = pricing
        self._notifications = notifications
```

### Domain Service Best Practices

- **Every business rule and validation lives here.** This is the whole point of the layer
- One clear entry point, usually `execute`
- Accept and return domain objects or DTOs, never `Request` or `QuerySet`
- Query the ORM directly, inject everything else
- Don't depend on the authenticated user, accept identity values from the caller
- Raise a domain exception on a rule violation, never return `None` or an error code
- Name with the operation it performs (`CompleteOrderService`, `CreateOrderService`)
- No interface by default, add one only if multiple implementations exist

## Factories

Factories are where dependency wiring lives, so services stay explicit about what they need and views stay ignorant of how to build them.

```
apps/<app>/factories/
├── __init__.py
├── services.py        build_<service>() functions
└── use_cases.py       build_<use_case>() functions
```

### Module-level `build_*` functions

The default. A plain function per constructed object, named `build_<thing>`, returning the wired instance:

```python
from typing import TYPE_CHECKING

from apps.orders.services.complete_order import CompleteOrderService
from apps.orders.services.create_order import CreateOrderService
from apps.orders.services.notifications import NotificationService
from apps.orders.services.pricing import PricingService

if TYPE_CHECKING:
    from apps.orders.domain import OrganizationDTO


def build_create_order_service(organization: "OrganizationDTO") -> CreateOrderService:
    return CreateOrderService(
        pricing=build_pricing_service(organization),
        notifications=NotificationService(),
    )


def build_pricing_service(organization: "OrganizationDTO") -> PricingService:
    return PricingService(organization)


def build_complete_order_service() -> CompleteOrderService:
    return CompleteOrderService(notifications=NotificationService())
```

Factories compose: a factory calls other factories rather than repeating a dependency tree. Import the service types normally and context DTOs under `TYPE_CHECKING` to keep import cycles out.

### `.build()` classmethod

For a service whose construction needs no arguments beyond its own defaults, a classmethod keeps the call site short:

```python
from typing import Self


class EditOrderService:
    @classmethod
    def build(cls) -> Self:
        return cls()
```

Call it as `EditOrderService.build().execute(...)`. Use this for the trivial case and a `build_*` function once real wiring appears.

### Factory Best Practices

- **Views and tasks call factories, never constructors.** `build_create_order_service(org).execute(...)`
- One factory per constructed object, named `build_<thing>`
- Factories call factories, never duplicate a dependency tree
- Keep factories free of logic. They wire, they do not decide
- Do not pass `request` into a factory, pass the values the service needs
- Tests build services directly with fakes, so a factory never grows a test-only branch

## Testing

Test where the logic is. That means the service level, not the HTTP level.

| Layer | Test | Asserts |
|---|---|---|
| Domain service | Unit test per rule and per failure | Real behaviour: returned objects, raised domain exceptions, collaborator calls |
| Entity, value object | Unit test | Invariants raise on construction |
| View, API | One test per reachable HTTP status | Status code only |

### Unit-test business logic at the service level

Build the service directly and pass fakes for its collaborators. No factory in the test. Use a real database row rather than mocking the ORM.

```python
@pytest.mark.django_db
class TestCompleteOrderService:
    def test_rejects_an_already_completed_order(self):
        order = OrderFactory(status=OrderStatus.COMPLETED)
        service = CompleteOrderService(notifications=MagicMock())

        with pytest.raises(DomainException, match="non-created order"):
            service.execute(order.id, OrderCompleteDTO(completed_at=NOW, note=None))

    def test_notifies_on_success(self):
        order = OrderFactory(status=OrderStatus.CREATED)
        notifications = MagicMock()
        service = CompleteOrderService(notifications=notifications)

        service.execute(order.id, OrderCompleteDTO(completed_at=NOW, note=None))

        order.refresh_from_db()
        assert order.status == OrderStatus.COMPLETED
        notifications.order_completed.assert_called_once_with(order.id)
```

A service with no ORM access needs no `django_db` and runs as a pure unit test.

### API tests cover status codes, nothing else

Once the rules are unit-tested at the service level, an API test asserting response bodies duplicates that coverage and breaks on every serializer change. Cover the statuses the endpoint can return, one test each:

```python
@pytest.mark.django_db
class TestOrderCompleteView:
    def test_returns_204_when_completed(self, authenticated_client):
        client, organization = authenticated_client
        order = OrderFactory(organization=organization, status=OrderStatus.CREATED)

        response = client.post(f"/orders/{order.id}/complete/", data={"completed_at": "2026-01-01T00:00:00Z"})

        assert response.status_code == 204

    def test_returns_400_on_invalid_payload(self, authenticated_client):
        ...  # assert response.status_code == 400

    def test_returns_403_for_a_foreign_organization(self, authenticated_client):
        ...  # assert response.status_code == 403
```

### Testing Best Practices

- **One unit test per business rule**, at the service that owns it
- **One API test per reachable status**: `200`/`201`/`204`, `400`, `403`, `404`, `409`
- Assert the status code in API tests. Leave payload shape to serializer tests if it matters at all
- Never mock the ORM. Use a factory and a real row
- Run with `pytest -n auto`

## Anti-Patterns to Avoid

- **Business validation in serializers or views**: serializers check types, services check rules
- **A repository layer over the Django ORM**: the ORM is the data access layer, use it
- **Injecting the ORM or a query wrapper to mock it**: use a real row and `pytest.mark.django_db`
- **Fat models**: a model method spanning models and side effects belongs in a service
- **Logic inline in a Celery task**: the task calls a service
- **Wiring services inline in a view**: build them in `factories/`
- **Anemic entities**: when you do model a domain object, give it behavior, not just public attributes
- **Generating IDs in an entity constructor**: generate `uuid` outside and pass as parameter
- **Domain service depending on the authenticated user**: accept identity values from the caller
- **Mutable value objects**: value objects must be immutable (`frozen=True`)

---

The rest of this file covers domain objects. Reach for them when a rule is really about one thing's internal consistency. Most Django features do not need them; a service plus a model is enough.

## Rich Domain Model vs Anemic Domain Model

| Anemic (Anti-pattern) | Rich (Recommended) |
|----------------------|-------------------|
| Entity = data only | Entity = data + behavior |
| Invariants checked elsewhere | Invariants in entity methods |
| Public attributes | Private state with methods |
| No validation in entity | Entity enforces invariants |

**Encapsulation is key**: Protect entity state with private attributes and expose behavior through methods.

Entity invariants and business rules are not the same thing. An invariant is a truth the object may never violate, such as a line count above zero. A business rule is a policy about what may happen, and it stays in the service.

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

### Entity Best Practices

- **Encapsulation**: Private attributes (`_name`), public properties and methods that enforce rules
- **Constructor validation**: Enforce invariants in `__post_init__`
- **Defensive copies**: Return `list(self._items)` to prevent external mutation
- **Reference by id**: Never hold another aggregate object, use its `id`
- **Don't generate IDs inside the entity**: Pass `uuid4()` from outside

## Aggregate Roots

Only worth it when a cluster of objects must stay consistent as a unit. The root owns its children, enforces the rules across them, and publishes events.

```python
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

    def pull_events(self) -> list[object]:
        """Drain and return pending domain events."""
        events, self._events = self._events, []
        return events
```

## Value Objects

Value objects are immutable and defined by their attributes, not identity.

```python
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

## Domain Events

```python
@dataclass(frozen=True)
class OrderCompletedEvent:
    order_id: UUID
```

Collect events on the aggregate via `pull_events()`. Dispatch them from the service after persisting.

## Best Practices Summary

1. **Every business rule and validation lives in a domain service**: the rest follow from this
2. **Views do HTTP only**: serializer types the input, factory builds the service, service decides
3. **Use the Django ORM directly**: no repository layer over it, and never inject it
4. **Inject the other collaborators**: services, gateways, clients, through the constructor
5. **Wire in `factories/`**: `build_<thing>()` functions, or `.build()` for the trivial case
6. **Unit-test rules at the service, test statuses at the API**: no overlap between the two
7. **Never mock the ORM**: real row, `pytest.mark.django_db`
8. **Raise a domain exception on a rule violation**: never an error code or `None`
9. **Reach for entities and value objects only when a rule is about one object's consistency**
10. **Enforce invariants in `__post_init__`**: never allow an invalid domain object to exist
11. **Immutable value objects**: use `@dataclass(frozen=True)`

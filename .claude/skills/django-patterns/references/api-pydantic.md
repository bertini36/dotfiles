# API Patterns with Pydantic

Use Pydantic models in `schemas.py` for request validation and response serialization. Django views parse request bodies manually and return `JsonResponse`.

## Schema Patterns

Define input and output schemas separately. Input schemas validate and coerce incoming data; output schemas control what gets serialized.

```python
# apps/products/schemas.py
import json
from decimal import Decimal
from datetime import datetime
from pydantic import BaseModel, field_validator, model_validator, Field
from pydantic import ValidationError

class ProductOut(BaseModel):
    id: int
    name: str
    slug: str
    description: str
    price: Decimal
    stock: int
    category_name: str
    created_at: datetime

    model_config = {"from_attributes": True}

    @classmethod
    def from_orm_obj(cls, product) -> "ProductOut":
        return cls(
            id=product.id,
            name=product.name,
            slug=product.slug,
            description=product.description,
            price=product.price,
            stock=product.stock,
            category_name=product.category.name,
            created_at=product.created_at,
        )

class ProductCreateIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    description: str = ""
    price: Decimal = Field(gt=0)
    stock: int = Field(ge=0)
    category_id: int

    @model_validator(mode='after')
    def check_high_value_stock(self) -> "ProductCreateIn":
        if self.price > 10000 and self.stock > 100:
            raise ValueError("Cannot have high-value products with large stock.")
        return self

class UserRegistrationIn(BaseModel):
    email: str
    username: str
    password: str = Field(min_length=8)
    password_confirm: str

    @model_validator(mode='after')
    def passwords_match(self) -> "UserRegistrationIn":
        if self.password != self.password_confirm:
            raise ValueError("Password fields didn't match.")
        return self
```

## View Patterns

Parse and validate request data with Pydantic, then return `JsonResponse`. Extract a helper to keep views clean.

```python
# apps/core/utils.py
import json
from django.http import JsonResponse
from pydantic import BaseModel, ValidationError

def parse_body[T: BaseModel](request, schema: type[T]) -> tuple[T | None, JsonResponse | None]:
    """Parse and validate request body against a Pydantic schema.

    Returns (parsed_data, None) on success or (None, error_response) on failure.
    """
    try:
        data = json.loads(request.body)
        return schema.model_validate(data), None
    except (json.JSONDecodeError, ValueError):
        return None, JsonResponse({"detail": "Invalid JSON."}, status=400)
    except ValidationError as exc:
        return None, JsonResponse({"detail": exc.errors()}, status=422)
```

```python
# apps/products/views.py
import json
from django.http import JsonResponse
from django.views import View
from django.shortcuts import get_object_or_404
from .models import Product
from .schemas import ProductOut, ProductCreateIn
from .services import ProductService
from apps.core.utils import parse_body

class ProductListView(View):
    def get(self, request):
        search = request.GET.get("search", "")
        qs = Product.objects.active().with_category()
        if search:
            qs = qs.search(search)
        return JsonResponse([ProductOut.from_orm_obj(p).model_dump(mode="json") for p in qs], safe=False)

    def post(self, request):
        payload, error = parse_body(request, ProductCreateIn)
        if error:
            return error
        product = ProductService.create(payload)
        return JsonResponse(ProductOut.from_orm_obj(product).model_dump(mode="json"), status=201)

class ProductDetailView(View):
    def get(self, request, product_id: int):
        product = get_object_or_404(Product.objects.with_category(), id=product_id)
        return JsonResponse(ProductOut.from_orm_obj(product).model_dump(mode="json"))
```

```python
# apps/products/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path("", views.ProductListView.as_view()),
    path("<int:product_id>/", views.ProductDetailView.as_view()),
]
```

## Validation Error Handling

Return consistent error shapes across views by handling `ValidationError` centrally, either in a helper (as above) or via Django middleware.

```python
# apps/core/middleware.py
import json
from django.http import JsonResponse
from pydantic import ValidationError

class PydanticValidationMiddleware:
    """Convert unhandled Pydantic ValidationErrors into 422 responses."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        return self.get_response(request)

    def process_exception(self, request, exception):
        if isinstance(exception, ValidationError):
            return JsonResponse({"detail": exception.errors()}, status=422)
        return None
```

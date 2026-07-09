# Service Layer, Caching, Signals, and Middleware

## Service Layer Pattern

```python
# apps/orders/services.py
from typing import Optional
from django.db import transaction
from .models import Order, OrderItem

class OrderService:
    """Service layer for order-related business logic."""

    @staticmethod
    @transaction.atomic
    def create_order(user, cart: Cart) -> Order:
        """Create order from cart."""
        order = Order.objects.create(
            user=user,
            total_price=cart.total_price
        )

        for item in cart.items.all():
            OrderItem.objects.create(
                order=order,
                product=item.product,
                quantity=item.quantity,
                price=item.product.price
            )

        # Clear cart
        cart.items.all().delete()

        return order

    @staticmethod
    def process_payment(order: Order, payment_data: dict) -> bool:
        """Process payment for order."""
        # Integration with payment gateway
        payment = PaymentGateway.charge(
            amount=order.total_price,
            token=payment_data['token']
        )

        if payment.success:
            order.status = Order.Status.PAID
            order.save()
            OrderService.send_confirmation_email(order)
            return True

        return False

    @staticmethod
    def send_confirmation_email(order: Order):
        """Send order confirmation email."""
        pass
```

## Caching Strategies

### View-Level Caching

```python
from django.views.decorators.cache import cache_page
from django.utils.decorators import method_decorator

@method_decorator(cache_page(60 * 15), name='dispatch')  # 15 minutes
class ProductListView(generic.ListView):
    model = Product
    template_name = 'products/list.html'
    context_object_name = 'products'
```

### Template Fragment Caching

```django
{% load cache %}
{% cache 500 sidebar %}
    ... expensive sidebar content ...
{% endcache %}
```

### Low-Level Caching

```python
from django.core.cache import cache

def get_featured_products():
    """Get featured products with caching."""
    cache_key = 'featured_products'
    products = cache.get(cache_key)

    if products is None:
        products = list(Product.objects.filter(is_featured=True))
        cache.set(cache_key, products, timeout=60 * 15)  # 15 minutes

    return products
```

### QuerySet Caching

```python
from django.core.cache import cache

def get_popular_categories():
    cache_key = 'popular_categories'
    categories = cache.get(cache_key)

    if categories is None:
        categories = list(Category.objects.annotate(
            product_count=Count('products')
        ).filter(product_count__gt=10).order_by('-product_count')[:20])
        cache.set(cache_key, categories, timeout=60 * 60)  # 1 hour

    return categories
```

## Signals

```python
# apps/users/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model
from .models import Profile

User = get_user_model()

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """Create profile when user is created."""
    if created:
        Profile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    """Save profile when user is saved."""
    instance.profile.save()

# apps/users/apps.py
from django.apps import AppConfig

class UsersConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.users'

    def ready(self):
        """Import signals when app is ready."""
        import apps.users.signals
```

## Custom Middleware

```python
# middleware/active_user_middleware.py
import time
from django.utils.deprecation import MiddlewareMixin

class ActiveUserMiddleware(MiddlewareMixin):
    """Middleware to track active users."""

    def process_request(self, request):
        """Process incoming request."""
        if request.user.is_authenticated:
            # Update last active time
            request.user.last_active = timezone.now()
            request.user.save(update_fields=['last_active'])

class RequestLoggingMiddleware(MiddlewareMixin):
    """Middleware for logging requests."""

    def process_request(self, request):
        """Log request start time."""
        request.start_time = time.time()

    def process_response(self, request, response):
        """Log request duration."""
        if hasattr(request, 'start_time'):
            duration = time.time() - request.start_time
            logger.info(f'{request.method} {request.path} - {response.status_code} - {duration:.3f}s')
        return response
```

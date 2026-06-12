---
paths:
  - "**/tests/**"
  - "**/test_*.py"
  - "**/*_test.py"
  - "**/conftest.py"
---

# Test Conventions

- No comments in tests unless absolutely necessary
- Tests should be self-explanatory through clear naming and structure
- If a test needs a comment, refactor for clarity instead
- Structure test bodies as given-when-then, separating each block with a blank line: setup, then the action under test, then assertions

```python
def test_invoice_is_marked_paid():
    invoice = InvoiceFactory(status=Status.PENDING)

    invoice.pay()

    assert invoice.status == Status.PAID
```

---
paths:
  - "**/tests/**"
  - "**/test_*.py"
  - "**/*_test.py"
  - "**/conftest.py"
---

# Writing tests

## Test behavior you wrote, not the library

Test what your code *defines*, never what the framework or a third-party library
already guarantees. If the assertion would still pass with your own logic deleted,
delete the test.

Do **not** write tests for:
- Immutability machinery — e.g. mutating a frozen dataclass or `frozen` Pydantic
  field and asserting it raises. That's the library's behavior, not yours.
- Field defaults and plain assignment — `Foo(x=1).x == 1`, or that a declared
  default applies.
- Stock-type validation — passing a wrong type and asserting `ValidationError`
  when the field is just a type annotation with no custom validator.
- ORM mechanics — that `.save()` persists, that a `max_length`/`unique` constraint
  fires, that `auto_now` sets a timestamp. That's Django.
- Third-party internals — pandas/polars/requests/stdlib behaving as documented.

**Do** test the logic you wrote, even on a model: custom validators, computed
properties, `__post_init__`, methods, and any branch or transformation you authored.

## Structure: given → when → then, by layout

Separate the three phases with blank lines — setup, then the single action, then the
assertions. Do **not** label them with `# given` / `# when` / `# then` comments.

```python
def test_invoice_is_marked_paid():
    invoice = InvoiceFactory(status=Status.PENDING)

    invoice.pay()

    assert invoice.status == Status.PAID
```

Name the test for the behavior and the condition so it reads as a sentence and needs
no explanatory comment: `test_renders_markdown_when_answer_present`,
`test_raises_when_token_missing`.

## Comments

Add a comment only when the logic is genuinely non-obvious — a subtle edge case or a
non-intuitive expected value. Descriptive names and the blank-line structure carry the
rest. No comments that restate the code, and no phase labels.
## One behavior, one level

Every behavior is tested at exactly one level:

- **Unit** covers the logic you wrote: branches, transformations, computed properties.
- **Integration** covers only the wiring unit tests cannot reach: real API contracts, serialization boundaries, external services.
- **Evals** cover output quality against labeled data, never correctness already asserted below.

Before writing a test, check whether a lower level already asserts the same behavior. If it does, do not write the test. When a higher-level test duplicates a lower-level assertion, delete the duplicate.

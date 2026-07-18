# Serde Zero-Copy Deserialization

Avoid allocating strings during deserialization by borrowing directly from the input buffer.

- Use `#[serde(borrow)]` with `&'a str` or `Cow<'a, str>` to borrow instead of allocating
- Only worth it for large payloads or hot paths — it adds lifetime complexity that propagates through every holder of the type
- The borrowed type cannot outlive the input buffer, so it's a poor fit for values you store long-term — use owned `String` there

```rust
#[derive(Deserialize)]
#[serde(rename_all = "snake_case")]
pub struct LogEntry<'a> {
    #[serde(borrow)]
    pub message: &'a str,
    pub level: u8,
}
```

Use `Cow<'a, str>` instead of `&'a str` when most inputs can be borrowed but some (e.g. those needing unescaping) must be owned — serde borrows when it can and allocates only when it must.

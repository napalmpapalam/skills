---
name: dd:rust:serde
description: Rust serde serialization — derive patterns, snake_case defaults, enum representations, attributes, zero-copy deserialization. Use whenever working with serde in Rust, adding Serialize/Deserialize derives, configuring JSON/YAML/TOML serialization, handling optional fields, choosing enum representations, or when the user asks about serde attributes, custom serializers, or data format conversion in Rust.
---

# Rust Serde Rules

## Default: snake_case everywhere

Always add `#[serde(rename_all = "snake_case")]` on every struct and enum — this is the project default. Only omit when matching an external API schema that requires a different casing.

```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub struct UserProfile {
    pub user_name: String,
    pub created_at: DateTime<Utc>,
}
```

## Derive patterns

- Derive both `Serialize` and `Deserialize` unless the type is write-only or read-only
- Place `#[serde(...)]` attributes directly below the derive — keep them visible
- Use `#[serde(deny_unknown_fields)]` on config types to catch typos early
- Use `#[serde(default)]` on the struct for backwards-compatible deserialization

## Common attributes

- `#[serde(skip)]` — exclude field from both serialization and deserialization
- `#[serde(skip_serializing_if = "Option::is_none")]` — omit `None` fields from output
- `#[serde(default)]` on a field — use `Default::default()` if missing in input
- `#[serde(flatten)]` — inline nested struct fields into the parent
- `#[serde(rename = "type")]` — rename a single field (useful for reserved keywords)
- `#[serde(with = "module")]` — custom serialize/deserialize via a module with `serialize`/`deserialize` fns

## Optional fields

```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub struct Config {
    pub name: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(default)]
    pub retries: u32,
}
```

- Pair `default` + `skip_serializing_if` for clean round-tripping of optional fields
- For `Vec<T>`: `#[serde(default, skip_serializing_if = "Vec::is_empty")]`

## Enums

- Apply `#[serde(rename_all = "snake_case")]` on enums too — variants serialize as snake_case strings
- Prefer **internally tagged** (`#[serde(tag = "type")]`) for most APIs — readable and explicit
- Use `untagged` sparingly — error messages are poor when deserialization fails
- For the four representations (externally/internally/adjacently tagged, untagged) with JSON shapes and full examples, see `references/enum-representations.md`

## serde_json patterns

- Parse: `serde_json::from_str::<T>(s)` / `serde_json::from_reader(r)`
- Serialize: `serde_json::to_string(&val)` / `serde_json::to_string_pretty(&val)`
- Dynamic: `serde_json::Value` for unknown schemas — access with `value["key"]`
- Prefer typed deserialization over `Value` whenever the schema is known

## Zero-copy deserialization

Only worth it for large payloads or hot paths — see `references/zero-copy.md` for `#[serde(borrow)]` patterns and their lifetime trade-offs.

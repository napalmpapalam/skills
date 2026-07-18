# Serde Enum Representations

Four ways serde can represent an enum on the wire. Pick by how the consumer reads the data.

```rust
// Externally tagged (default) — {"user_created": { "id": 42 }}
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Event {
    UserCreated { id: u64 },
    UserDeleted { id: u64 },
}

// Internally tagged — {"type": "user_created", "id": 42}
#[derive(Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Event {
    UserCreated { id: u64 },
    UserDeleted { id: u64 },
}

// Adjacently tagged — {"type": "user_created", "data": {"id": 42}}
#[derive(Serialize, Deserialize)]
#[serde(tag = "type", content = "data", rename_all = "snake_case")]
pub enum Event {
    UserCreated { id: u64 },
    UserDeleted { id: u64 },
}

// Untagged — {"id": 42} (tries each variant in order)
#[derive(Serialize, Deserialize)]
#[serde(untagged)]
pub enum Value {
    Int(i64),
    Text(String),
}
```

## Choosing

- **Internally tagged** (`tag = "type"`) — default choice for most APIs. Readable, explicit discriminant. Requires struct-like or unit variants (not newtype variants wrapping primitives).
- **Externally tagged** (serde default) — compact, but nests data under a variant key. Fine for internal formats.
- **Adjacently tagged** (`tag` + `content`) — use when variant data may be a primitive or the consumer wants tag and payload in separate, fixed keys.
- **Untagged** — use sparingly. serde tries each variant in declaration order and picks the first that deserializes. Error messages are poor on failure, and ordering bugs are easy to introduce.

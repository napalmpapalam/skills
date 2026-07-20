---
name: dd:ts:comments
description: TypeScript comment and TSDoc style — keep them short, explain why not what, document the public surface only. Use whenever writing or reviewing comments or doc comments in TypeScript, adding TSDoc to exported members, documenting a public API, or when the user asks about comment style, TSDoc tags, or reducing comment noise.
---

# TypeScript Comment Rules

Default to **less**. A well-named function beats a comment explaining a badly-named one.

## TSDoc (`/** … */`) — public members

**Every exported class member and every exported function gets one.** It's a library; TSDoc is the API docs. But keep it tight.

- **One line by default** — what it is, or what it returns. The signature already shows the types; don't restate them.
- **No `@param` / `@returns` blocks that just repeat the signature.** Add `@param` only when the meaning isn't in the name (units, allowed range, a wire format).
- Keep `@throws` when the failure is non-obvious — which is most of the time in a library, since consumers can't see your `catch`.
- `{@link OtherType}` for cross-references — it's the one tag that earns its characters.
- `@example` with a fenced ```ts block for anything with a non-obvious call shape (builders, overloaded factories, options objects). Skip it for a getter.

```ts
// Too much — restates the signature, narrates the implementation
/**
 * Builds the full request URL by combining the base URL with the endpoint,
 * joining them with a slash and then cleaning up any doubled or trailing
 * slashes using two regular expressions.
 * @param baseUrl The base URL
 * @param endpoint The endpoint
 * @returns The URL
 */

// Enough
/** Joins {@link baseUrl} and the endpoint into an absolute URL, collapsing duplicate slashes. */
```

## Free helpers

A one-per-file helper named `is-object.ts` exporting `isObject` needs no doc comment. Add one only when the behavior is genuinely non-obvious — an edge case, a format, a deliberate asymmetry.

## Inline (`//`) — why, never what

- **Delete comments that restate the code.** `// increment the counter` above `count += 1` is noise.
- Keep a `//` for: a workaround, a subtle ordering requirement, a spec/RFC/MDN link, a deliberate deviation from the obvious approach.
- If a comment is needed to explain *what* a block does, extract it into a named function instead. The function name is the comment, and it can't go stale.

```ts
// Good — records a why the code can't
// response.clone() because the body can only be consumed once (MDN: bodyUsed)
const parsed = await this.response.clone().json()

// Good — records a decision
// Content-Type is deleted so the browser sets the multipart boundary itself
headers.delete(HEADER_CONTENT_TYPE)
```

## Type aliases

A branded or aliased primitive carries a trailing comment naming the format — it's the only place the constraint is written down:

```ts
export type IsoDate = Brand<string, 'IsoDate'> // RFC3339Nano
export type Endpoint = Brand<string, 'Endpoint'> // leading slash, e.g. `/users`
```

## No design essays in files

No architecture narration at the top of a module, no seam-by-seam walkthroughs. If the rationale is worth recording, it goes in a design doc, not the source.

`// TODO` is fine with an owner or an issue link. `// hardcoded` is flagged by lint on purpose — fix it or explain it.

## Reviewing existing code

- Collapse multi-paragraph TSDoc to one line unless the extra text records a real invariant.
- Strip restating `//` comments; keep the "why" ones.
- Don't delete a public member's doc comment entirely — shorten it.

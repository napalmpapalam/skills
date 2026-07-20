---
name: dd:ts:type-system
description: TypeScript type design — type aliases over interfaces, branded types, unions vs enums, generics, unknown over any, type predicates, and zod validation at boundaries. Use whenever declaring types or interfaces, designing a public type surface, adding generics, narrowing unknown values, writing type guards, validating external data, or when the user asks about type safety, branded types, discriminated unions, or parse-don't-validate.
---

# TypeScript Type System

## `type`, never `interface`

Object shapes are type aliases. No exceptions.

```ts
export type FetcherConfig = {
  baseUrl: string
  credentials?: RequestCredentials
}
```

`interface` allows declaration merging — a global mutation any file can perform on your public API. `type` can't be reopened, composes with unions and intersections, and works with mapped and conditional types. There is nothing `interface` does here that's worth that.

## Branded types

**A meaningful domain value gets a brand, not a bare primitive.** This is not only for IDs — timestamps, URLs, decimals, and any string with a format are all brand candidates.

```ts
declare const brand: unique symbol
export type Brand<T, B extends string> = T & { readonly [brand]: B }

export type IsoDate = Brand<string, 'IsoDate'>   // RFC3339Nano
export type UnixDate = Brand<number, 'UnixDate'>
export type Endpoint = Brand<string, 'Endpoint'> // e.g. `/users`
export type UserId = Brand<string, 'UserId'>
```

A brand makes `takesUserId(endpoint)` a compile error. A plain alias does not.

**Brands are minted, never cast at call sites.** One constructor per brand, and it validates:

```ts
export const isoDate = (value: string): IsoDate => {
  if (!ISO_DATE_REGEX.test(value)) throw new TypeError(`Time: invalid ISO date: ${value}`)
  return value as IsoDate
}
```

If `as SomeBrand` appears outside its constructor, the brand is doing nothing.

**When a plain alias is enough**: pure documentation on an internal type nobody can confuse, or re-branding a dependency's type into your own vocabulary. Add a trailing comment so the intent is visible:

```ts
export type JsonApiClientConfig = FetcherConfig
export type URL = string // absolute, origin included
```

## Enum vs union literal

- **Union literal** for a closed set of strings that stay strings on the wire or in the API surface: `type Inclusivity = '()' | '[)' | '(]' | '[]'`.
- **`enum`** for a named domain the consumer refers to symbolically — HTTP methods, status codes, rounding modes. Enum name **and** members are SCREAMING_SNAKE: `HTTP_METHODS.GET`, `BN_ROUNDING.HALF_UP`.

Rule of thumb: if a consumer would ever type the literal by hand, use a union. If they should import a symbol, use an enum.

## Compose, don't duplicate

Derive related types instead of restating fields:

```ts
export type FetcherStandaloneConfig = Omit<FetcherConfig, 'baseUrl'>
export type TimeManipulate = Exclude<TimeOpUnit, 'date' | 'dates'>
export type FetcherRequestConfig = FetcherRequestOpts & {
  endpoint: string
  method: HTTP_METHODS
}
```

Mapped types for uniform transforms, conditional types with `infer` for unwrapping, and **overloaded call-signature types** instead of function overloads:

```ts
export type Unwrap<T> = T extends ComputedOrRef<infer V> ? V : T

export type RefFunction = {
  <T extends Ref>(value: T): T
  <T>(value: T): Ref<T>
  <T>(): Ref<T | undefined>
}
```

## `unknown`, never `any`

`any` disables the type checker for everything it touches downstream. `unknown` forces a narrow.

```ts
export type EventMap = Record<string, unknown>
export const isObject = (value: unknown): boolean => { … }
public request<T = unknown>(cfg: FetcherRequestConfig): Promise<FetcherResponse<T>>
```

The only acceptable `any` is a variance escape in a public type parameter default, and it carries an `eslint-disable-next-line @typescript-eslint/no-explicit-any` on the line above. If you can't justify it in one comment, it's not justified.

**No `!` non-null assertions** — `@typescript-eslint/no-non-null-assertion` is an error. Replace with, in order of preference:

1. `?.` optional chaining when absence is valid
2. `??` when there's a sensible default
3. `assert(cond, msg)` or a type predicate when absence is a bug

With `noUncheckedIndexedAccess` on, every index access is `T | undefined` — that's the point, handle it.

## Narrowing

**Type predicates and assertion signatures are the narrowing tools**, not casts.

```ts
export const isRef = <T>(value: unknown): value is Ref<T> => value instanceof RefIml
export function assert(expression: boolean, message: string): asserts expression {
  if (!expression) throw new RuntimeError(message)
}
export const isBn = (arg: unknown): arg is BN => arg instanceof BN
```

Name them `isX`. Every `as` that isn't a brand constructor or a `satisfies` is a smell.

## Validation at boundaries

**Parse, don't validate.** External data — HTTP responses, env vars, config files, user input — is `unknown` until a zod schema has parsed it. Inside the boundary, work with types, never re-check.

```ts
const UserSchema = z.object({
  id: z.string().brand<'UserId'>(),
  createdAt: z.string().datetime().brand<'IsoDate'>(),
})
export type User = z.infer<typeof UserSchema>

export const parseUser = (raw: unknown): User => UserSchema.parse(raw)
```

- **Derive the type from the schema with `z.infer`** — never hand-write a type next to a schema that must match it.
- **`.brand<'X'>()` mints branded types at the parse boundary** — the one place a brand legitimately comes into existence from raw data.
- **One parse at the edge.** Don't sprinkle `.parse()` through internal call paths.
- Internal invariants that aren't external data use `assert()` or a predicate — zod is for untrusted input, not for every check.

## Misc

- `readonly` on class fields and on public type properties that consumers must not mutate.
- `satisfies` when you want a literal checked against a type without widening it.
- **No `namespace`, no `declare module`, no declaration merging.**
- Generics get single letters and defaults: `<T, U = DefaultMeta>`. Constrain when you index: `<K extends keyof T>`.
- Make a type generic over a discriminant string so consumers can extend it: `JsonApiRecordBase<T extends string>`.

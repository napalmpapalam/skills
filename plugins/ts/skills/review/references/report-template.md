# TypeScript Review Report Template

Output the review in this exact structure. Group the issues by severity, put each issue in a
blockquote, and include the fix inline.

```markdown
# TypeScript Code Review Report

## Files Reviewed

| File | Status |
|---|---|
| `src/path/file.ts` | Modified |
| `src/path/other.ts` | Added |

---

## Static Analysis

| Check | Result |
|---|---|
| Formatting | ✓ Passed / ✗ Failed |
| Types | ✓ Passed / ✗ N errors |
| Lint | ✓ No warnings / ✗ N warnings |
| Tests | ✓ All passing / ✗ N failures |

---

## Layout and DRY

| File | Walls | Copies |
|---|---|---|
| `src/path/file.ts` | ✓ / ✗ lines 30–52 | ✓ / ✗ `runQuiet('docker', …)` ×4 |

## Comment Budget

| File | Result |
|---|---|
| `src/path/file.ts` | ✓ Within budget / ✗ N overruns |

---

## Issues

### CRITICAL

> **1. Short description**
> **File:** `src/path/file.ts:42`
>
> What is wrong
>
> **Fix:**
> ```ts
> // a concrete code suggestion
> ```

---

### HIGH

> **1. Short description**
> **File:** `src/path/file.ts:102`
>
> What is wrong
>
> **Fix:**
> ```ts
> // a concrete code suggestion
> ```

---

### MEDIUM

> **1. Short description**
> **File:** `src/path/file.ts:200`
>
> What is wrong
>
> **Fix:**
> ```ts
> // a concrete code suggestion
> ```

If a severity level has no issues, write: *No issues found.*

---

## Summary

| Severity | Count |
|---|---|
| CRITICAL | N |
| HIGH | N |
| MEDIUM | N |

**Recommendation:** Approve / Warning (merge with caution) / Block merge
```

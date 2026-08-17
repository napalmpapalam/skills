# Rust Review Report Template

Output the review using this exact structure. Group issues by severity, use blockquotes to separate each issue, and include code fixes inline.

The **Comment Budget** table has one row per changed file, always — a file within budget still gets its row, marked ✓. A missing row reads as "not checked", which is the failure it exists to prevent. Every ✗ row also appears as a HIGH issue below, with its collapsed replacement as the fix.

```markdown
# Rust Code Review Report

## Files Reviewed

| File                | Status   |
| ------------------- | -------- |
| `src/path/file.rs`  | Modified |
| `src/path/other.rs` | Added    |

---

## Static Analysis

| Check      | Result                       |
| ---------- | ---------------------------- |
| Build      | ✓ Passed / ✗ Failed          |
| Clippy     | ✓ No warnings / ✗ N warnings |
| Formatting | ✓ Passed / ✗ Failed          |
| Tests      | ✓ All passing / ✗ N failures |

---

## Comment Budget

One row per changed file. `//!` budget is 1 line, `///` 1 line, `//` 1–3.

| File                | `//!` | Longest `///` | Restating `//` | Verdict                      |
| ------------------- | ----- | ------------- | -------------- | ---------------------------- |
| `src/path/file.rs`  | 1     | 1             | 0              | ✓ Within budget              |
| `src/path/other.rs` | 6     | 4             | 3              | ✗ See HIGH #1 — 9 lines over |

---

## Issues

### CRITICAL

> **1. Short description**
> **File:** `src/path/file.rs:42`
>
> Explanation of what's wrong
>
> **Fix:**
> ```rust
> // concrete code suggestion
> ```

---

### HIGH

> **1. Short description**
> **File:** `src/path/file.rs:102`
>
> Explanation of what's wrong
>
> **Fix:**
> ```rust
> // concrete code suggestion
> ```

---

### MEDIUM

> **1. Short description**
> **File:** `src/path/file.rs:200`
>
> Explanation of what's wrong
>
> **Fix:**
> ```rust
> // concrete code suggestion
> ```

If a severity level has no issues, write: *No issues found.*

---

## Summary

| Severity              | Count |
| --------------------- | ----- |
| CRITICAL              | N     |
| HIGH                  | N     |
| MEDIUM                | N     |
| Files over comment budget | N / N |

**Recommendation:** Approve / Warning (merge with caution) / Block merge
```

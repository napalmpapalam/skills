# Rust Review Report Template

Output the review using this exact structure. Group issues by severity, use blockquotes to separate each issue, and include code fixes inline.

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

| Severity | Count |
| -------- | ----- |
| CRITICAL | N     |
| HIGH     | N     |
| MEDIUM   | N     |

**Recommendation:** Approve / Warning (merge with caution) / Block merge
```

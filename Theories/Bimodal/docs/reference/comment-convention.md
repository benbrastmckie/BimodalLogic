# Comment Convention Standard

This document defines the conventions for inline comments, tag-prefixed annotations,
and `#check` usage in the `Theories/Bimodal/` library.

**Last verified: 2026-05-29**

---

## Tag-Prefixed Annotations

The following tags are supported in all `.lean` files:

### NOTE:
**Purpose**: Document removed or refactored items; explain non-obvious code choices

**Usage**:
```lean
-- NOTE: temp_k_dist and temp_4 are now derived theorems (Task 116).
-- NOTE: This constructor was renamed from modal_k to modal_k_dist.
```

**When to use**:
- After removing or commenting out code that may be missed
- To explain a surprising design decision
- To document a workaround for a Lean limitation

### TODO:
**Purpose**: Mark planned improvements

**Usage**:
```lean
-- TODO: Replace sorry with full proof when Task 131 completes.
-- TODO: Generalize this to arbitrary ordered fields.
```

**Policy**: Keep sparse. Prefer creating a task in the task system (`/task`) over
leaving TODO comments. Reserve inline TODO for micro-level issues that do not
warrant a full task.

### FIX:
**Purpose**: Flag known bugs requiring attention

**Usage**:
```lean
-- FIX: Off-by-one in index computation; see Task 202 for details.
```

**When to use**: When you discover a bug but cannot fix it in the current task.
Always reference the related task number if one exists.

### QUESTION:
**Purpose**: Mark design decisions that need discussion or external input

**Usage**:
```lean
-- QUESTION: Should this be a Prop or a Type? The decidability proof may need Type.
```

**When to use**: When a design choice has significant trade-offs and needs review.
Convert to a NOTE or remove once the question is resolved.

---

## `#check` Usage Policy

`#check` commands are **evaluation comments** that verify types and provide API examples.

### Permitted locations
- `Examples/` — Pedagogical examples benefit from inline type display
- `Theorems/` — API demonstration for end users

### Discouraged locations
- `Metalogic/`, `ProofSystem/`, `Syntax/`, `Semantics/` (library core)
- Automation scripts

### Rationale
`#check` in library core can slow incremental builds and may break if types change.
In Examples/ and Theorems/, they serve as live documentation that confirms the API
works as described.

### Exception
`#check` is permitted anywhere when it is part of a `section ... end` block that
is guarded with `-- #check` (commented out) or placed in a separate `Examples/`
file rather than the main library file.

---

## Line Comment Style

Use `--` for single-line comments:

```lean
-- This is a single-line comment
```

Use `/-` ... `-/` for block comments that are not docstrings:

```lean
/- Temporary note about the proof structure.
   This will be cleaned up once Task 131 completes. -/
```

---

## Section Separators

Large files may use section separators:

```lean
-- ============================================================
-- Section: Canonical Frame Construction
-- ============================================================
```

These are especially useful in files with 200+ lines that cover multiple logical topics.

---

## Docstring vs. Comment

| Use case | Syntax | Purpose |
|----------|--------|---------|
| Module documentation | `/-! ... -/` | Module-level docs (Mathlib style) |
| Definition documentation | `/-- ... -/` | Shown by LSP on hover |
| Implementation notes | `-- NOTE:` | Developer-facing, not in hover |
| Temporary annotations | `-- TODO:`, `-- FIX:` | Task tracking |
| Design questions | `-- QUESTION:` | Review pending |
| Block comments | `/- ... -/` | Non-docstring multi-line |

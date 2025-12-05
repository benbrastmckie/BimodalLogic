# Research Report: Revised Temporal Operator Naming Convention

**Date**: 2025-12-04
**Type**: Plan Revision Research
**Related Plan**: [001-temporal-conventions-refactor-plan.md](../plans/001-temporal-conventions-refactor-plan.md)

---

## Executive Summary

This research documents a revised naming convention for temporal operators that provides clearer semantics while following the established pattern in the codebase where descriptive function names are paired with concise DSL notation.

---

## Motivation: Pattern Consistency

### Existing Pattern in Codebase

The Logos codebase already follows this pattern for modal operators:

| Function Name | DSL Notation | Meaning |
|---------------|--------------|---------|
| `box` | `□` | Modal necessity |
| `diamond` | `◇` | Modal possibility (derived) |

This pattern separates:
- **Descriptive function names** for code readability
- **Concise DSL notation** for formal expressions

### Problem with Original Plan

The original plan proposed:
- Constructor: `past` → `H`, `future` → `G`
- Derived: `sometime_past` → `P`, `sometime_future` → `F`

This breaks the pattern by using single-letter names for functions, which:
1. Reduces code readability
2. Makes the universal/existential distinction unclear in function names
3. Loses the semantic clarity of descriptive names

---

## Revised Naming Convention

### New Naming Scheme

| Current Name | Revised Function Name | DSL Notation | Meaning |
|--------------|----------------------|--------------|---------|
| `past` | `all_past` | `H` | Universal past (historically) |
| `future` | `all_future` | `G` | Universal future (globally) |
| `sometime_past` | `some_past` | `P` | Existential past (once) |
| `sometime_future` | `some_future` | `F` | Existential future (eventually) |

### Semantic Clarity

The `all_`/`some_` prefix pattern immediately conveys:
- **`all_`** = Universal quantification (for all times)
- **`some_`** = Existential quantification (exists some time)

Compare:
- `past` vs `all_past` - Current name ambiguous, revised name clearly universal
- `sometime_past` vs `some_past` - Shorter while retaining meaning

### Code Examples

**Before (Current)**:
```lean
inductive Formula : Type where
  | past : Formula → Formula      -- Ambiguous: all past or some past?
  | future : Formula → Formula    -- Ambiguous: all future or some future?

def sometime_past (φ : Formula) := φ.neg.past.neg  -- Verbose
```

**After (Revised)**:
```lean
inductive Formula : Type where
  | all_past : Formula → Formula   -- Clear: universal past
  | all_future : Formula → Formula -- Clear: universal future

def some_past (φ : Formula) := φ.neg.all_past.neg   -- Concise, clear
def some_future (φ : Formula) := φ.neg.all_future.neg

-- DSL notation (parallel to box/□ pattern)
prefix:80 "H" => Formula.all_past    -- Historically
prefix:80 "G" => Formula.all_future  -- Globally
prefix:80 "P" => Formula.some_past   -- Past/Previously
prefix:80 "F" => Formula.some_future -- Future/Finally
```

---

## DSL Notation Phase

A new phase is needed to add DSL notation definitions. This follows the existing pattern:

```lean
-- Existing modal notation
prefix:80 "□" => Formula.box
prefix:80 "◇" => Formula.diamond

-- Existing temporal notation (to be added)
prefix:80 "H" => Formula.all_past    -- Historically (universal past)
prefix:80 "G" => Formula.all_future  -- Globally (universal future)
prefix:80 "P" => Formula.some_past   -- Past/Previously (existential past)
prefix:80 "F" => Formula.some_future -- Future/Finally (existential future)
```

**Standard Temporal Logic Notation**:
- `H` = **H**istorically = "it has always been the case that" (universal past)
- `G` = **G**lobally = "it will always be the case that" (universal future)
- `P` = **P**ast/**P**reviously = "it was once the case that" (existential past)
- `F` = **F**uture/**F**inally = "it will eventually be the case that" (existential future)

---

## Impact on swap_past_future

The function should be renamed to `swap_all_past_all_future` or kept as `swap_temporal` for clarity:

```lean
-- Option 1: Descriptive but long
def swap_all_past_all_future : Formula → Formula

-- Option 2: Shorter, semantic
def swap_temporal : Formula → Formula
```

**Recommendation**: Use `swap_temporal` as it's concise and clear.

---

## Updated Search/Replace Patterns

### Constructor Renames
```
Formula.past    → Formula.all_past
Formula.future  → Formula.all_future
| past φ        → | all_past φ
| future φ      → | all_future φ
```

### Derived Operator Renames
```
sometime_past   → some_past
sometime_future → some_future
.sometime_past  → .some_past
.sometime_future → .some_future
```

### Function Renames
```
swap_past_future → swap_temporal
```

### Documentation Updates
```
"universal past" → "all_past (H)"
"existential past" → "some_past (P)"
"universal future" → "all_future (G)"
"existential future" → "some_future (F)"
```

---

## Plan Revision Summary

The implementation plan should be updated to:

1. **Phase 2**: Rename constructors `past` → `all_past`, `future` → `all_future`
2. **Phase 3**: Rename derived operators `sometime_past` → `some_past`, `sometime_future` → `some_future`
3. **New Phase 3.5 (or merged into Phase 3)**: Add DSL notation definitions for H/G/P/F
4. **Phase 4+**: Update tests, archive, and documentation with new naming

---

## Benefits of Revised Approach

1. **Semantic Clarity**: `all_past` vs `some_past` immediately conveys quantification
2. **Pattern Consistency**: Follows `box`/`□` pattern with descriptive names + concise notation
3. **Code Readability**: Function names are self-documenting
4. **Formal Notation**: DSL provides standard H/G/P/F for formal expressions
5. **Symmetry**: `all_`/`some_` prefix pattern is symmetric and memorable

---

**Research Complete**: Ready for plan revision.

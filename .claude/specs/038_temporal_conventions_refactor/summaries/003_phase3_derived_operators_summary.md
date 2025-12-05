# Phase 3 Summary: Rename Derived Temporal Operators and Add DSL Notation

**Date**: 2025-12-04
**Status**: COMPLETE
**Iteration**: 1

## Changes Made

### 1. Renamed Derived Temporal Operators

**Formula.lean changes**:
- `sometime_past` → `some_past` (line 165)
  - Definition: `φ.neg.all_past.neg` (existential past: ¬H¬φ)
  - Docstring: "Existential past operator (Pφ)"

- `sometime_future` → `some_future` (line 177)
  - Definition: `φ.neg.all_future.neg` (existential future: ¬G¬φ)
  - **Fixed**: Previous definition was incorrect (`φ.sometimes`) - now correctly implements ¬G¬φ
  - Docstring: "Existential future operator (Fφ)"

### 2. Backward Compatibility

Added abbreviation aliases to maintain backward compatibility:
```lean
abbrev sometime_past := some_past
abbrev sometime_future := some_future
```

This ensures all existing code continues to work without modification.

### 3. DSL Notation Status

**Planned**: ASCII single-letter notation (H/G/P/F)
**Outcome**: Not viable in Lean 4

**Reason**: Single ASCII letters (H, G, P, F) conflict with Lean 4's parser - they are interpreted as identifiers rather than notation tokens. Unicode symbols like △/▽ work because they're unambiguous.

**Alternative Implemented**: Function application pattern following the established `box`/`□` pattern:
- `φ.all_past` (H)
- `φ.all_future` (G)
- `φ.some_past` (P)
- `φ.some_future` (F)

Existing Unicode notation for derived operators still works:
- `△ φ` (always/omnitemporality)
- `▽ φ` (sometimes)

### 4. Documentation Updates

Updated module docstring in Formula.lean:
```
## Naming Convention

Follows the `box`/`□` pattern with descriptive function names:
- Universal temporal: `all_past` (H), `all_future` (G)
- Existential temporal: `some_past` (P), `some_future` (F)
- Derived: `always` (△), `sometimes` (▽)

Use method syntax: `φ.all_past`, `φ.some_future`, etc.
```

## Verification

- `lake build` succeeds
- All existing code works via backward-compatible aliases
- No diagnostics in Formula.lean

## Files Changed

1. `Logos/Core/Syntax/Formula.lean`
   - Added `some_past` definition (line 165)
   - Added `some_future` definition with correct implementation (line 177)
   - Added backward-compatible aliases
   - Updated module docstring

## Implementation Notes

### Bug Fix in some_future
The previous `sometime_future` was incorrectly defined as:
```lean
def sometime_future (φ : Formula) : Formula := φ.sometimes
```

This was **wrong** because `sometimes` = `¬(always ¬φ)` which is a complex 3-time operator (past ∨ present ∨ future), not the simple existential future operator.

The correct definition is:
```lean
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg
```

This implements `¬G¬φ` = "not always-in-future not φ" = "at some future time φ".

---

**work_remaining**: 4 5 6 7
**context_exhausted**: false
**context_usage_percent**: 25%
**requires_continuation**: false

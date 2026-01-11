# Implementation Summary: Task #393

**Completed**: 2026-01-12
**Duration**: ~20 minutes

## Changes Made

Removed the incorrect Lewis (1973) counterfactual analysis implementation of the causal operator (○→) from Truth.lean and replaced it with a `sorry` stub. Updated all relevant documentation to indicate that the causal operator is primitive (like the counterfactual conditional) and awaiting correct implementation from "Counterfactual Worlds" (Brast-McKie 2025).

## Files Modified

- `Theories/Logos/SubTheories/Explanatory/Truth.lean`
  - Lines 148-168: Replaced incorrect semantic definition with comprehensive `sorry` stub
  - Lines 25-27: Updated module docstring to reference Task 394 for implementation

- `Theories/Logos/SubTheories/Explanatory/Syntax.lean`
  - Lines 73-79: Updated `causal` constructor docstring to indicate primitive status

## Semantic Changes

### Before (Incorrect Lewis 1973 analysis)
```lean
| Formula.causal φ ψ =>
    truthAt M τ t ht σ idx φ ∧
    (∃ y, ∃ hy : y ∈ τ.domain, y > t ∧ truthAt M τ y hy σ idx ψ) ∧
    truthAt M τ t ht σ idx (Formula.counterfactual (Formula.neg φ) (Formula.neg (Formula.some_future ψ)))
```

### After (Stub awaiting correct implementation)
```lean
| Formula.causal _ _ =>
    sorry  -- Awaiting implementation from Brast-McKie 2025, line 626
```

## Key Documentation Updates

1. **Truth.lean module docstring**: Now states causal operator is awaiting correct implementation
2. **Syntax.lean causal docstring**: Now states operator is PRIMITIVE, not derived
3. **Truth.lean causal case**: Comprehensive comments explaining:
   - Why the Lewis analysis was incorrect (preemption, overdetermination)
   - What the correct semantics requires (context, evolutions, three conditions)
   - Reference to Task 394 for implementation

## Verification

- [x] Truth.lean compiles without errors (LSP verified)
- [x] Syntax.lean compiles without errors (LSP verified)
- [x] Module docstrings accurately reflect implementation state
- [x] No incorrect claims about counterfactual analysis remain
- [x] Task 394 properly referenced for future implementation
- [x] One `sorry` introduced (acceptable for stub)

## Notes

The incorrect implementation used the simple Lewis (1973) counterfactual analysis:
- A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)

This cannot handle:
- Preemption (backup causes)
- Overdetermination (multiple sufficient causes)
- Missing context parameters (time_cause, time_effect, background)
- Missing evolution/subevolution structure

The correct semantics from "Counterfactual Worlds" (Brast-McKie 2025) line 626 requires:
1. Inclusion: cause and effect in background assumptions
2. Substantial contribution: minimal subevolution requirement
3. Difference-making: counterfactual via inverted effect

This implementation is deferred to Task 394.

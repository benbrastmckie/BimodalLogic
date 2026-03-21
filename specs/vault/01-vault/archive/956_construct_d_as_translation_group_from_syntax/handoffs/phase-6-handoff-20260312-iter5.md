# Phase 6 Handoff: Strict Density Iteration (Iteration 5 - Updated)

**Date**: 2026-03-12
**Session**: sess_1773379347_ca5p87
**Status**: Phase 6b PARTIAL

## Immediate Next Action

Complete the well-founded termination argument. The core iteration pattern has been expanded and verified to work. Each iteration case has the structure:
1. Extract distinguishing formula from ¬CanonicalR M' W (or ¬CanonicalR W M)
2. Prove G(formula) ∉ M using GContent transitivity
3. Apply Case A construction
4. Check if new witness is strict; if not, iterate

## Current State

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`
**Sorry Count**: 23 (up from 17 originally due to expanded iteration structure)

**Original Sorries (unchanged)**: Lines 486, 490, 492, 585, 589, 591, 641, 646, 653 (9 in Case B1)
**Expanded Iteration Sorries**: Lines 933, 952, 981, 1041 (4 in main theorem)
**Infrastructure Sorries**: Lines 1786, 1871 (2 in non_reflexive_target)
**New Infrastructure Sorries**: Lines 2128, 2147, 2189, 2208, 2314, 2346, 2402, 2423 (8 in new theorems)

## Key Progress Made

1. **`strict_density_M_reflexive` theorem**: New theorem handling the M-reflexive case with full iteration structure
2. **Case neg-pos expansion**: At line 2095, full extraction of psi from ¬CanonicalR W M, construction of U, and strictness checks
3. **Case pos-neg expansion**: At line 2165, full extraction of psi from ¬CanonicalR M' W, construction of U, and strictness checks
4. **Pattern verified**: Each expansion either:
   - Returns a strict witness (`exact ⟨U, ...⟩`)
   - Has a `U ~ M` case requiring iteration

## Termination Argument (Confirmed)

Each iteration uses a DISTINCT formula:
- 1st: W from density_frame_condition, extract psi₁ from ¬CanonicalR M' W
- 2nd: U from Case A with psi₁, extract psi₂ from ¬CanonicalR M' U (or ¬CanonicalR U M)
- nth: Each psi_n is in GContent(M') and NOT in the previous witness
- Since neg(psi_{n-1}) ∈ witness_n, psi_n ≠ psi_{n-1}

All formulas are bounded by subformulaClosure(anchor), so iteration terminates.

## What NOT to Try

1. **Direct recursion without fuel**: Lean's termination checker fails without explicit measure
2. **Assuming psi ∉ W implies psi ∉ M**: This is FALSE - W and M can have different elements while having same GContent
3. **Using `density_frame_condition_strict` recursively**: Creates infinite loop without termination proof

## Critical Context

### Goal State at Iteration Sorries (Template)

```lean
h_UM : CanonicalR U M     -- U sees M back (U ~ M)
h_not_M'U : ¬CanonicalR M' U  -- M' doesn't see U (strict from M' side)
h_neg_psi_U : psi.neg ∈ U  -- U has neg(psi)
⊢ ∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧ ¬CanonicalR W M ∧ ¬CanonicalR M' W
```

### Resolution Pattern

```lean
-- From h_not_M'U, extract chi with G(chi) ∈ M' and chi ∉ U
-- Since U ~ M reflexive, G(chi) ∉ U and G(chi) ∉ M
-- F(neg(chi)) ∈ M, apply Case A to get Z
-- Check Z's strictness; if Z ~ M, iterate with chi
```

## Implementation Recommendation

**Option A**: Use `Nat.rec` with explicit fuel parameter
```lean
theorem strict_density_with_fuel (fuel : Nat) : ... := by
  induction fuel with
  | zero => exact (non_reflexive_target_has_strict_intermediate ...).some_case
  | succ n ih => ...
```

**Option B**: Prove by contradiction using finite measure
```lean
-- If all witnesses see M back, track consumed formulas
-- When |consumed| > |subformulaClosure|, derive contradiction
```

## References

- **Plan**: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-023.md`
- **Research**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-046.md`

## Build Status

```bash
lake build  # Passes with 23 sorry warnings (up from 17)
```

## CantorApplication Impact

The 3 sorries in CantorApplication.lean (lines 210, 269, 316) depend on `density_frame_condition_strict` being resolved. Once the iteration cases are handled, these will close automatically.

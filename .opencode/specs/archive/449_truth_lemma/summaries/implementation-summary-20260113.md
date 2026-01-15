# Implementation Summary: Task #449

**Completed**: 2026-01-13
**Status**: PARTIAL
**Duration**: ~2 hours

## Summary

Implemented Phase 1 (closure infrastructure) completely and made significant progress on Phases 2-4 of the finite truth lemma. The forward directions of all cases (imp, box, all_past, all_future) are now proven modulo dependencies on respects_task. The backward directions require additional properties of FiniteWorldState (negation-completeness or maximality) that are not currently in the definition.

## Changes Made

### SignedFormula.lean
- Added `Formula.subformulas_trans`: Transitivity theorem for subformula relation
- Proof by structural induction on the outer formula

### FiniteCanonicalModel.lean
- **Proven `closure_mono`**: Closure monotonicity using subformulas_trans
- **Added derived lemmas**:
  - `imp_in_closure_left`: Implication antecedent in closure
  - `imp_in_closure_right`: Implication consequent in closure
  - `box_in_closure`: Box subformula in closure
  - `all_past_in_closure`: All_past subformula in closure
  - `all_future_in_closure`: All_future subformula in closure
- **Added `FiniteHistory.respects_task`**: Task relation between arbitrary times (sorry - depends on compositionality)
- **Updated `finite_truth_lemma`**:
  - Atom case: PROVEN (unchanged)
  - Bot case: PROVEN (unchanged)
  - Imp case: Forward PROVEN, backward needs negation-completeness
  - Box case: Documented with T axiom partial progress, both directions need canonical property
  - All_past case: Forward PROVEN (via respects_task), backward needs negation-completeness
  - All_future case: Forward PROVEN (via respects_task), backward needs negation-completeness

## Files Modified

- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Added subformulas_trans theorem
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Multiple additions and proof progress

## Verification

- Lake build: SUCCESS
- New errors: NONE
- Remaining sorries in FiniteCanonicalModel.lean:
  - `closureSize_le_complexity` (line 354) - Not critical
  - `compositionality` (line 773) - 7 sorry gaps for mixed-sign temporal cases
  - `respects_task` (line 1014) - Depends on compositionality
  - `finite_history_from_state` (line 1119) - 2 sorry gaps
  - `finite_truth_lemma` (line 1241) - 6 sorry gaps remaining (backward directions)

## Blocking Issues Identified

### 1. Negation-Completeness of FiniteWorldState

The backward directions of imp, box, all_past, and all_future cases all require the world state to be "negation-complete" or "maximal" - meaning that for every formula in the closure, either it or its negation is true. The current `IsLocallyConsistent` definition only requires:
- Bot is false
- Implications are respected (one direction)
- T axioms for box and temporal operators

**Recommendation**: Add a negation-completeness constraint to FiniteWorldState, or add it as a field to FiniteHistory. This would be:
```lean
/-- For every formula in closure, either it or its negation is true -/
negation_complete : ∀ psi : Formula,
  ∀ h_psi : psi ∈ closure phi,
  ∀ h_neg : Formula.neg psi ∈ closure phi,
  assignment ⟨psi, h_psi⟩ = true ∨ assignment ⟨Formula.neg psi, h_neg⟩ = true
```

### 2. Canonical Property for Box

The box case requires that if box(psi) is true in one history's state at time t, then psi is true at time t in ALL histories. This is the "canonical model property" that different histories at the same time must agree on certain formulas.

**Recommendation**: Either:
1. Require all histories at same time to have same world state (too strong), or
2. Add a coherence constraint to the type of FiniteHistory, or
3. Reformulate finite_truth_at for box to not quantify over all histories

### 3. Compositionality Gaps

The `respects_task` lemma depends on compositionality of finite_task_rel, which has 7 sorry gaps for mixed-sign temporal cases (e.g., going forward then backward).

**Recommendation**: Complete compositionality proof or accept as axiom for now.

## Next Steps

1. **Task 472 (Lindenbaum extension)**: Would provide negation-completeness by constructing world states from maximal consistent sets
2. **Task 473 (Fix compositionality gaps)**: Would enable respects_task proof
3. Consider strengthening FiniteWorldState definition with negation-completeness
4. Consider revising finite_truth_at definition for box to avoid cross-history quantification

## Notes

The implementation made good progress on the structural aspects of the truth lemma. The key insight is that all backward directions share a common requirement: the world state must represent a maximal consistent set, not just a locally consistent one. This is a fundamental gap in the current FiniteWorldState definition that Task 472 (Lindenbaum extension) is designed to address.

The forward directions work because they use the transfer properties built into finite_task_rel, which flow from the semantic definition. The backward directions require the converse: from semantic truth at all accessible points, conclude syntactic truth in the world state.

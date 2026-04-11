# Implementation Summary: Defect-Discharge Chain Construction

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Status**: [PARTIAL]
- **Session**: sess_1775929409_d60996
- **Phases Completed**: 1 of 5 (Phase 2 partial)

## Accomplished

### Phase 1: Sigma Ordering Infrastructure [COMPLETED]
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean` already existed and builds clean
- Defines `sigma_le`, `sigma_strict`, `sigma_equiv` on BXPoints
- Proves: `bx_le_implies_sigma_le`, `sigma_le_refl`, `sigma_strict_irrefl`, `not_bx_le_of_sigma_strict`, `not_sigma_le_of_sigma_strict`, `sigma_formula_determined`, `not_sigma_equiv_of_sigma_strict`, `sigma_strict_of_bx_le_and_witness`, `sigma_H_backward`
- All lemmas proved without sorry

### Phase 2: Defect-Discharge Chain Construction [PARTIAL]
- Created `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean`
- Defines `sigma_defect_count` and `sigma_since_defect_count`
- Proves `sigma_defect_count_bounded`, `defect_step_phi` (BX9 extraction), `defect_step_F_psi` (BX10 eventuality), `defect_step_connect` (BX4 connectedness), `defect_step_self_accum` (BX5 self-accumulation)
- Mirror lemmas for Since direction
- All proved without sorry
- NOT completed: well-founded recursion chain construction, chain ordering/guard/goal properties

### Frame.lean Updates
- Cleaned up docstrings on the 4 sorry functions
- Signatures kept unchanged (bx_lt guard)
- 4 sorries remain as before

## What Blocks Further Progress

### The Fundamental Mathematical Blocker

The research report (task 101) extensively analyzed the mathematical feasibility. The core issue is:

1. **bx_le is not total**: `bx_le w v := g_content(w) <= v.formulas` is reflexive and transitive but NOT total. Two BXPoints can have `bx_le w v` and `bx_le v w` while differing on non-G-formulas.

2. **The guard requires non-G-formula propagation**: The guard `phi in u` for intermediate `u` between `w` and `v` requires propagating `phi` (an arbitrary subformula) through `bx_le`, but `bx_le` only propagates G-formulas.

3. **sigma_strict weakening helps forward but not backward**: Changing the guard from `bx_lt u v` to `sigma_strict Sigma u v` makes the forward direction easier (fewer u's to check) but makes the backward direction harder (the guard hypothesis is weaker).

4. **Backward direction has no direct contradiction path**: The enriched seed gives `u` with `bx_le w u`, `bx_le u v`, `not(phi U psi) in u`, `psi notin u`. Even with `phi in u` from the guard, we cannot derive `phi U psi in u` (which would contradict `not(phi U psi) in u`) because `phi` and `F(psi)` at u do not imply `phi U psi` at u.

### Viable Paths Forward (from research report)

1. **Replace bx_le entirely**: Define the canonical ordering using Until-witness structure instead of g_content inclusion. This would make the ordering linear by construction but requires extensive rewriting of Frame.lean infrastructure. Estimated: +20 hours.

2. **Construct independent finite linear model**: Build a finite TaskModel from HintikkaPoints with a linear ordering by construction, prove the truth lemma there, then embed it. This avoids modifying bx_le but requires significant new infrastructure. Estimated: +30 hours.

3. **Add Until-induction axiom**: Restore the Until-induction axiom that was removed during BX refactoring. This directly closes all sorries but changes the axiom system. Requires verification that the axiom is sound.

## Verification

- `lake build` passes with zero new errors
- No new sorries introduced
- No new axioms introduced
- Existing 4 Frame.lean sorries and 6 Realization.lean sorries remain

## Files Modified/Created

- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` (NEW)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (docstring cleanup only)
- `specs/102_implement_quotient_filtration_close_sorries/plans/01_defect-discharge-implementation.md` (status updates)

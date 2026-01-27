# Implementation Summary: Task #656

**Completed**: 2026-01-27
**Duration**: ~3 hours

## Overview

Completed the truth lemma imp case (both directions) and documented the architectural limitation for the box case. The key achievement was restructuring the truth lemma to use mutual induction, which allows the backward IH to be used in the forward direction proofs.

## Changes Made

### 1. Restructured Truth Lemma to Mutual Induction

Changed from separate `truth_lemma_forward` and `truth_lemma_backward` theorems to a single `truth_lemma_mutual` theorem that proves both directions simultaneously via structural induction on formulas.

**Benefits**:
- Forward imp case can now use backward IH (essential for modus ponens closure)
- Cleaner proof structure matching standard completeness proof approaches
- Single induction eliminates code duplication

### 2. Added MCS Negation-Implication Helper Lemmas

Created two new lemmas to extract formulas from negated implications:

- `neg_imp_fst`: From `¬(φ → ψ) ∈ MCS`, derive `φ ∈ MCS`
- `neg_imp_snd`: From `¬(φ → ψ) ∈ MCS`, derive `¬ψ ∈ MCS`

These lemmas use MCS deductive closure and negation completeness to implement the classical tautology `¬(φ → ψ) ⊣⊢ φ ∧ ¬ψ`.

### 3. Completed Imp Case (Both Directions)

**Forward direction** (lines 148-156):
- Use backward IH to convert `truth_at psi` to `psi ∈ mcs t`
- Apply `set_mcs_implication_property` (modus ponens closure)
- Use forward IH to convert `chi ∈ mcs t` to `truth_at chi`

**Backward direction** (lines 157-185):
- Use negation completeness: either `(psi → chi) ∈ MCS` or `¬(psi → chi) ∈ MCS`
- If the latter, extract `psi ∈ MCS` and `¬chi ∈ MCS`
- Derive contradiction via semantic truth and MCS consistency

### 4. Documented Box Case Architectural Limitation

The box case cannot be proven with current semantics because:

1. Box semantics use universal quantification over ALL world histories
2. Arbitrary histories can have arbitrary world states at time t
3. The IH only applies to the canonical history
4. No way to connect arbitrary world states to the family's MCS

**Resolution options documented** (for future work):
1. Restrict box semantics to modal accessibility relations (Kripke-style)
2. Only quantify over canonical histories
3. Add modal accessibility predicate relating histories

**Impact**: Box case is NOT critical for the main representation theorem (Task 654), which only needs temporal operators.

## Files Modified

- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
  - Restructured to mutual induction
  - Added `neg_imp_fst` and `neg_imp_snd` helper lemmas
  - Completed imp case proofs
  - Added comprehensive documentation for box case limitation

## Verification

- `lake build` succeeds with no errors
- Imp case has no sorries (both directions proven)
- Box case has sorries with documented architectural limitation
- Temporal forward cases still work (no regressions)
- Temporal backward cases remain sorry (not in scope for this task)

## Summary of Sorries

After this task, TruthLemma.lean has the following sorries:

| Case | Direction | Status | Reason |
|------|-----------|--------|--------|
| atom | both | PROVEN | Base case, trivial |
| bot | both | PROVEN | MCS consistency |
| imp | both | PROVEN | Mutual induction + helper lemmas |
| box | forward | SORRY | Architectural limitation (documented) |
| box | backward | SORRY | Architectural limitation (documented) |
| all_past | forward | PROVEN | Family backward_H coherence |
| all_past | backward | SORRY | Needs negation-temporal interaction |
| all_future | forward | PROVEN | Family forward_G coherence |
| all_future | backward | SORRY | Needs negation-temporal interaction |

## Notes

1. The mutual induction approach is the standard technique in modal/temporal logic completeness proofs (see Blackburn et al.)

2. The box case limitation is fundamental to the current semantic architecture. The box operator in this codebase has very strong semantics (quantifying over ALL histories) that differ from traditional Kripke semantics.

3. The temporal backward cases (all_past/all_future backward) require additional infrastructure to connect `¬(H psi)` to `P(¬psi)` (sometime_past), which is a separate proof effort.

4. The imp case completion is the main deliverable for Task 656 as specified in the task description.

# Implementation Summary: Close Restricted Coherence Sorries

- **Task**: 83 - Close Restricted Coherence Sorries
- **Plan**: plans/39_enriched-chain-completeness.md
- **Session**: sess_1775631399_13b212
- **Status**: Partial (truth lemma sorries closed, completeness wiring has new sorry)

## What Was Done

### Phase 1: De-Risking (Completed)

The plan proposed deriving `neg(phi U psi) -> neg(psi) /\ (neg(phi) \/ G(neg(phi U psi)))` from BX axioms. Analysis showed this formula is **semantically invalid** (countermodel: p true at 0, p false at 1, q false everywhere except q true at 2; then neg(p U q) at 0 but neither neg(p) nor G(neg(p U q)) holds). The planned Phase 1 derivation was correctly identified as impossible.

**Fallback adopted**: Use the existing `BFMCS.until_since_coherent` predicate (already defined in TemporalCoherence.lean lines 466-479 and used by the parametric truth lemma in ParametricTruthLemma.lean) as an additional hypothesis for the truth lemma. This sidesteps the need for BX axiom derivations entirely.

### Phase 3: Fill Until/Since Truth Lemma Cases (Completed)

All 6 sorry cases for Until/Since were closed:

1. **canonical_truth_lemma** (lines 629-630): Added `h_uc : B.until_since_coherent` parameter, filled Until and Since cases using `h_fwd_U`/`h_bwd_U`/`h_fwd_S`/`h_bwd_S` from `until_since_coherent` with IH conversion.

2. **shifted_truth_lemma** (lines 776-777): Same approach as canonical, added `h_uc` parameter.

3. **restricted_shifted_truth_lemma** (lines 935, 938): Added `h_uc` parameter, derived subformula closure membership for phi and psi from the Until/Since formula membership using new `closure_untl_left/right` and `closure_snce_left/right` lemmas.

### Bonus: G_dne_theorem Sorry Fixed

Fixed the `sorry` at TemporalCoherence.lean line 68. The sorry was for applying `temp_k_dist` axiom, which is a direct axiom instance: `DerivationTree.axiom [] _ (Axiom.temp_k_dist (Formula.neg (Formula.neg phi)) phi)`.

### Phase 4: Completeness Wiring (Partial)

Updated all callers of the truth lemmas to pass the new `h_uc` parameter:
- `BaseCompleteness.lean`: Updated `base_truth_lemma` and `base_shifted_truth_lemma`
- `DenseCompleteness.lean`: Updated `canonical_truth_lemma_int` and `shifted_truth_lemma_int`
- `DiscreteCompleteness.lean`: Updated `discrete_base_truth_lemma`
- `FrameConditions/Completeness.lean`: Updated 3 call sites with `sorry` for `h_uc`

The completeness proofs in FrameConditions/Completeness.lean now have new `sorry` for `B.until_since_coherent`. These are structurally parallel to the existing `sorry` for `B.temporally_coherent` (or `B.restricted_temporally_coherent`) -- proving that the chain construction satisfies these coherence properties is the remaining work.

### Phase 5: Audit (Completed)

**Modified files**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Added 4 closure lemmas (untl_left/right, snce_left/right)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - Fixed G_dne_theorem sorry
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - Closed 6 Until/Since sorry cases
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` - Updated truth lemma signatures
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Updated truth lemma signatures
- `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean` - Updated truth lemma signatures
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Updated 3 call sites

**Sorry count in CanonicalConstruction.lean**: 0 (was 6)
**Sorry count in TemporalCoherence.lean**: 0 (was 1)
**New sorries added**: 3 (in FrameConditions/Completeness.lean for `until_since_coherent`)
**Net sorry change**: -4 (removed 7, added 3)

**Bundle/ sorry count**: 15 (unchanged except CanonicalConstruction.lean -6, TemporalCoherence.lean -1)

## What Was Not Done

### Phase 2: Enriched Chain Construction

Not needed for closing the truth lemma sorries. The `until_since_coherent` approach defers the chain construction obligation to the completeness proof, which already has parallel sorries for `temporally_coherent`. The enriched chain construction would be needed to close THOSE sorries, but that is a separate (harder) task.

### Phases Not In Plan

- BXCanonical Frame.lean sorries: Confirmed not target (plan non-goal)
- SuccChainFMCS.lean infrastructure sorries: Not modified
- WitnessSeed.lean / SuccRelation.lean / SuccExistence.lean sorries: Not modified

## Verification

- `lake build`: Passes (944 jobs, 0 errors)
- CanonicalConstruction.lean: 0 sorry
- TemporalCoherence.lean: 0 sorry
- No new axioms introduced
- Build is clean

## Architecture Decision

The key architectural decision was to use `BFMCS.until_since_coherent` as an explicit coherence hypothesis rather than trying to derive Until/Since truth from BX axioms alone. This is the correct approach because:

1. The Until truth lemma fundamentally requires chain-level coherence (MCS at adjacent times must respect Until propagation)
2. BX axioms alone cannot enforce inter-MCS coherence
3. The parametric truth lemma (ParametricTruthLemma.lean) already adopted this pattern
4. The obligation is cleanly separated: truth lemma proofs are now complete, and chain constructions must independently verify `until_since_coherent`

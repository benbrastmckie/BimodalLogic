# Handoff: Phase 1 - CanonicalMCS Embedding Infrastructure

**Task**: 988 - Dense Algebraic Completeness
**Session**: sess_1742152800_988i
**Date**: 2026-03-17
**Status**: Partial (5 sorries remain)

## Immediate Next Action

Prove `ratFMCS_forward_F` by showing that `canonical_forward_F` witnesses appear in the dense timeline union.

## Current State

**File**: `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`
**Line**: ~156 (ratFMCS_forward_F proof)
**Goal**: `∃ q' : ℚ, q < q' ∧ phi ∈ ratMCS root_mcs root_mcs_proof q'`

**Proof Sketch**:
1. Have `h_F : F φ ∈ timelineQuotMCS(t)` where t = iso.symm q
2. Use `canonical_forward_F` to get witness MCS W with `CanonicalR(t.mcs, W) ∧ φ ∈ W`
3. NEED: Show W appears in dense timeline (i.e., corresponds to some TimelineQuot element)
4. Then use the isomorphism to get q' with q < q'

## Key Decisions Made

1. **Abandoned direct CanonicalMCS embedding**: CanonicalMCS has Preorder, not LinearOrder, so `Order.embedding_from_countable_to_dense` doesn't apply directly.

2. **Used TimelineQuot approach**: The existing `cantor_iso : Nonempty (TimelineQuot ≃o ℚ)` provides an isomorphism. We transfer the FMCS structure through this isomorphism.

3. **Singleton BFMCS problem identified**: A singleton bundle (one family) does NOT automatically satisfy `modal_backward` because modal saturation fails. Need multi-family approach.

## What NOT to Try

1. **Constant family construction**: Mapping all rationals to the same MCS. This fails temporal coherence (F φ ∈ M does not imply φ ∈ M).

2. **Direct CanonicalMCS → Rat embedding**: Requires LinearOrder which CanonicalMCS lacks.

## Critical Context

1. **`canonical_forward_F` signature**:
   ```lean
   theorem canonical_forward_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
       (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
       ∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ phi ∈ W
   ```
   The witness W is constructed via Lindenbaum from {phi} ∪ g_content(M).

2. **Dense timeline construction**: `StagedExecution.lean` adds F-witnesses via `someSuccForward`. Check if this includes the Lindenbaum witnesses from `canonical_forward_F`.

3. **TimelineQuot elements**: Equivalence classes of `DenseTimelineElem`. Two elements are equivalent iff mutual ≤, which (by canonicalR_irreflexive) means same MCS.

4. **Modal saturation requirement**: For BFMCS `modal_backward`, need `is_modally_saturated B`. For singleton bundle, this requires `◇φ ∈ M → φ ∈ M`, which is NOT generally true.

## References

- **Plan**: `specs/988_dense_algebraic_completeness/plans/implementation-001.md`
- **Research**: `specs/988_dense_algebraic_completeness/reports/research-001.md`
- **Staged execution**: `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
- **Modal saturation**: `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- **TimelineQuot canonical**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`

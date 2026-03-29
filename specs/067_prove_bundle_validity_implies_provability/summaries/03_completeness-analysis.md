# Task 67 Implementation Summary: Bundle Validity Implies Provability

## Status: PARTIAL

**Session**: sess_1774745467_81a116
**Date**: 2026-03-28
**Plan**: 03_termination-first-plan.md

## Phase Completion Status

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1 | COMPLETED | Termination sorries filled (fuel-based approach) |
| Phase 2 | COMPLETED | G/H propagation analysis (not required for main theorem) |
| Phase 3 | COMPLETED | Completeness bridge infrastructure |
| Phase 4 | PARTIAL | Truth lemma adaptation - blocked on family-level coherence |
| Phase 5 | NOT STARTED | Completeness wiring - depends on Phase 4 |

## Key Technical Finding

The `bundle_validity_implies_provability` sorry **cannot be eliminated** with current infrastructure due to a fundamental gap in the proof architecture.

### The Problem

The completeness theorem requires proving:
```
valid_over Int phi -> Nonempty ([] ⊢ phi)
```

By contrapositive, this needs:
1. If phi not provable, neg(phi) is consistent
2. Extend neg(phi) to MCS M containing neg(phi)
3. Build canonical model from M
4. Show neg(phi) TRUE in model (so phi FALSE)
5. Contradicts validity hypothesis

Step 4 requires the **truth lemma**: `phi ∈ MCS ↔ truth_at model phi`

### Why the Truth Lemma Requires Family-Level Temporal Coherence

The truth lemma is inherently **bidirectional**. The forward direction for `imp` uses the backward IH:

```lean
-- Forward imp: (psi -> chi) in MCS, truth(psi) -> truth(chi)
intro h_imp h_psi_true
-- By IH backward (critical cross-direction dependency):
have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
```

The backward direction for G and H cases uses temporal coherence:

```lean
-- Backward G: forall s >= t, truth tau s psi -> G psi in MCS
obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam  -- REQUIRES h_tc
```

### The Infrastructure Gap

| Component | Status | Notes |
|-----------|--------|-------|
| `construct_bfmcs_bundle` | Sorry-free | Builds BFMCS_Bundle from MCS |
| `boxClassFamilies_modal_forward/backward` | Sorry-free | Modal coherence |
| `boxClassFamilies_bundle_temporally_coherent` | Sorry-free | Bundle-level F/P |
| `Z_chain_forward_F` | SORRY | Family-level F coherence |
| `Z_chain_backward_P` | SORRY | Family-level P coherence |
| `parametric_canonical_truth_lemma` | Requires h_tc | Family-level coherence |

**Key insight**: Bundle-level coherence (witnesses in ANY family) does NOT imply family-level coherence (witnesses in the SAME family).

## Completed Infrastructure

### RestrictedTruthLemma.lean

New theorems added:
- `restricted_ext_contains_seed`: Seed formulas preserved in Lindenbaum extension
- `restricted_ext_zero_is_mcs`: Extension at time 0 is MCS
- `restricted_ext_neg_excludes_phi`: If neg(phi) in seed, phi not in extension
- `neg_consistent_gives_mcs_without_phi`: MCS-level completeness lemma

### Completeness.lean

Enhanced documentation explaining:
- Why forward-only truth lemma doesn't work
- The bidirectional structure of the imp case
- How temporal coherence is used in G/H backward cases
- The resolution path via Z_chain temporal coherence

## Resolution Path

To eliminate the sorry in `bundle_validity_implies_provability`:

1. **Prove Z_chain_forward_F**: Show F(phi) at t implies phi at some s > t within the same Z-chain
2. **Prove Z_chain_backward_P**: Show P(phi) at t implies phi at some s < t within the same Z-chain
3. These follow from the omega chain construction using `temporal_theory_witness_exists`
4. With family-level coherence, `parametric_canonical_truth_lemma` applies
5. The completeness proof then closes

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`
  - Added Phase 3 completeness bridge infrastructure
  - Added `neg_consistent_gives_mcs_without_phi` lemma

- `Theories/Bimodal/FrameConditions/Completeness.lean`
  - Enhanced documentation in `bundle_validity_implies_provability`
  - Detailed explanation of the truth lemma gap

## Build Status

```
lake build: SUCCESS (938 jobs)
Sorries in key files:
  - RestrictedTruthLemma.lean: 2 (helper lemmas, not blocking main theorem)
  - Completeness.lean: 2 (dense_completeness_fc, bundle_validity_implies_provability)
```

## Recommendation

The sorry in `bundle_validity_implies_provability` is a fundamental blocker that requires proving the Z_chain family-level temporal coherence. This is a well-defined problem: show that the omega chain construction resolves F/P obligations within the chain, not just across the bundle.

The current implementation correctly identifies this gap and provides a clear resolution path. The algebraic core (bundle construction, modal coherence) remains sorry-free.

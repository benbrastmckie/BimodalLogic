# Handoff: Phase 3 - Linearity and Embedding

**Task**: 922 - Canonical Quotient Completeness Proof
**Session**: sess_1771960688_9a2e76
**Date**: 2026-02-24
**Phase**: 3 of 5
**Status**: PARTIAL - derived lemmas proven, linearity/embedding remain

## Immediate Next Action

Prove the linearity of the canonical frame's reachable fragment:

```lean
-- In CanonicalEmbedding.lean or a new file
theorem canonical_reachable_linear (M M1 M2 : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs1 : SetMaximalConsistent M1)
    (h_mcs2 : SetMaximalConsistent M2)
    (h_R1 : CanonicalR M M1) (h_R2 : CanonicalR M M2) :
    CanonicalR M1 M2 ∨ CanonicalR M2 M1 ∨ M1 = M2
```

This should use the `temp_linearity` axiom and `mcs_F_linearity` lemma
(both already available in the codebase).

## Current State

### Files Created (Iteration 2)

| File | Status | Sorries |
|------|--------|---------|
| `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` | Complete | 0 |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` | Partial | 0 |

### Available Infrastructure

- `canonical_forward_F` (CanonicalFrame.lean): F(psi) in MCS M implies exists
  MCS W with psi in W and GContent(M) subset W. PROVEN.
- `canonical_backward_P` (CanonicalFrame.lean): P(psi) in MCS M implies exists
  MCS W with psi in W and HContent(M) subset W. PROVEN.
- `canonical_forward_G` (CanonicalFrame.lean): G(phi) in M and CanonicalR M M'
  implies phi in M'. PROVEN.
- `canonical_backward_H` (CanonicalFrame.lean): Symmetric. PROVEN.
- `canonicalR_reflexive` (CanonicalFrame.lean): CanonicalR M M for MCS M. PROVEN.
- `canonicalR_transitive` (CanonicalFrame.lean): Transitive via Temp 4. PROVEN.
- `mcs_F_linearity` (CanonicalEmbedding.lean): Decompose two F-obligations
  in an MCS into three cases using temp_linearity. PROVEN.
- `F_implies_G_P_F` (CanonicalEmbedding.lean): G(P(F(psi))) in M when F(psi)
  in M, via temp_a. PROVEN.
- `temp_linearity` axiom (Axioms.lean): Added in Phase 1. Sound for linear time.

### Key Interface to Satisfy

```lean
-- In TemporalCoherentConstruction.lean, line 603-609
theorem temporal_coherent_family_exists_Int
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : BFMCS Int),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ t : Int, ∀ φ, F φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : Int, ∀ φ, P φ ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s)
```

Currently delegating to DovetailingChain which has 2 sorries.

## Key Decisions Made

1. **Linearity axiom added to TM** (Phase 1): The `temp_linearity` axiom was
   added because linearity is NOT derivable from existing TM axioms (3-point
   branching counterexample documented in LinearityDerivedFacts.lean).

2. **Canonical frame approach validated** (Phase 2): Forward_F and backward_P
   are trivially provable in the canonical frame. The GContent/HContent inclusion
   definitions give forward_G and backward_H for free.

3. **F-persistence is impossible** (Phase 3 analysis): F-formulas do NOT persist
   through GContent seeds. This is NOT fixable with the linearity axiom (which
   constrains semantic models but not Lindenbaum choices). The canonical quotient
   (full linearity + embedding) is the ONLY viable path.

## What NOT to Try

1. **F-persistence through GContent**: Proven impossible. Lindenbaum can always
   introduce G(neg(psi)), killing F(psi). No axiom prevents this.

2. **Including FContent in seeds**: `{psi} ∪ GContent(M) ∪ FContent(M)` is NOT
   necessarily consistent. Counterexample: FContent includes formulas whose
   negations can be derived from {psi} ∪ GContent(M).

3. **Chain-based approaches**: All 12 plan versions (v001-v012) tried chain
   approaches and failed for the same fundamental reason. See research-001.md.

4. **Constant family**: F(psi) in M does NOT imply psi in M. The constant
   family cannot satisfy forward_F.

## Critical Context

1. The canonical frame construction (CanonicalFrame.lean) is the mathematical
   foundation. Forward_F and backward_P are TRIVIALLY proven there.

2. The BFMCS structure requires `mcs : Int -> Set Formula`. Int is discrete
   (not dense), so `Order.embedding_from_countable_to_dense` does not directly
   apply. The reachable fragment's order type must be analyzed.

3. The completeness chain (Completeness.lean) is sorry-free in itself. All
   sorries flow through `temporal_coherent_family_exists_Int`.

4. The `fully_saturated_bmcs_exists_int` theorem (also sorry'd) combines temporal
   coherence AND modal saturation. Resolving temporal coherence alone is valuable.

5. Mathlib's `orderIsoIntOfLinearSuccPredArch` provides an order isomorphism
   to Int for linear orders with successor/predecessor that are archimedean.
   This might be applicable if the reachable fragment is discrete.

## References

- Plan: `specs/922_.../plans/implementation-001.md`
- Research: `specs/922_.../reports/research-001.md`, `research-002.md`
- Phase 1 output: `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean`
- Phase 2 output: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- Phase 3 output: `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`

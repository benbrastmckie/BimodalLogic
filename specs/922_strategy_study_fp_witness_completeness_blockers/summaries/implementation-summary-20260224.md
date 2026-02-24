# Implementation Summary: Task #922 (Iteration 2)

**Date**: 2026-02-24
**Session**: sess_1771960688_9a2e76
**Plan**: implementation-001.md
**Resumed From**: Phase 2 (Phase 1 completed in iteration 1)

## Changes Made

### Phase 2: Canonical Frame Definition [COMPLETED]

Created the canonical frame for the Canonical Quotient approach, where
forward_F and backward_P are trivially proven by giving each F/P-obligation
its own fresh Lindenbaum witness.

**New File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `CanonicalR` - future relation via GContent subset inclusion
- `CanonicalR_past` - past relation via HContent subset inclusion
- `canonical_forward_G` - trivial by GContent definition
- `canonical_backward_H` - trivial by HContent definition
- `canonical_forward_F` - uses `forward_temporal_witness_seed_consistent` + `set_lindenbaum`
- `canonical_backward_P` - uses `past_temporal_witness_seed_consistent` + `set_lindenbaum`
- `canonicalR_reflexive` - via T-axiom (temp_t_future)
- `canonicalR_past_reflexive` - via T-axiom (temp_t_past)
- `canonicalR_transitive` - via Temporal 4 axiom (temp_4)

All proofs are sorry-free. Build succeeds.

### Phase 3: Linearity and Embedding [PARTIAL]

Created derived lemmas supporting the canonical quotient approach.
Extensive analysis of the F-persistence problem confirmed that the full
canonical quotient (linearity proof + Int embedding) is required.

**New File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`
- `F_implies_G_P_F` - G(P(F(psi))) in M when F(psi) in M (via temp_a)
- `F_implies_P_F_in_GContent` - P(F(psi)) propagates through GContent seeds
- `P_implies_G_P_P` - G(P(P(psi))) in M when P(psi) in M
- `mcs_F_linearity` - decompose F-obligations using temp_linearity axiom in MCS

All proofs are sorry-free. Build succeeds.

**Analysis documented**: F-persistence through GContent seeds is fundamentally
impossible (confirmed by detailed mathematical analysis). The temp_linearity
axiom constrains semantic models but does not prevent Lindenbaum from killing
F-obligations. The correct path forward requires:
1. Proving linearity of the canonical frame's reachable fragment (using temp_linearity)
2. Embedding the countable linear order into Int (challenging because Int is discrete)

### Phases 4-5: Not Started

These phases depend on completing the linearity proof and Int embedding from Phase 3.

## Files Created/Modified

| File | Action | Sorries |
|------|--------|---------|
| `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` | Created | 0 |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` | Created | 0 |
| `specs/922_.../plans/implementation-001.md` | Updated phase markers | - |

## Verification

- `lake build` succeeds with 0 errors
- No sorries in new files
- No new axioms introduced (temp_linearity was added in iteration 1)
- Existing completeness chain (Completeness.lean) unaffected

## Technical Analysis: Why Forward_F Remains Hard

The canonical frame makes forward_F trivial for ABSTRACT MCS worlds:
- `canonical_forward_F`: F(psi) in M implies exists MCS W with psi in W and GContent(M) in W
- This is proven using `forward_temporal_witness_seed_consistent` + `set_lindenbaum`

The challenge is transferring this to `BFMCS Int` (indexed by integers):
- The canonical witness W is a DIFFERENT MCS than any position in an Int-indexed chain
- F-formulas do NOT persist through GContent seeds (Lindenbaum can introduce G(neg(psi)))
- The temp_linearity axiom constrains models but not Lindenbaum choices
- A direct chain construction CANNOT prove forward_F (confirmed by 12 failed approaches)

The resolution requires the full canonical quotient:
1. Build canonical frame (DONE)
2. Prove reachable fragment is linearly ordered (using temp_linearity - REMAINING)
3. Embed countable linear order into Int (REMAINING)

## Remaining Work

1. **Linearity proof**: Prove CanonicalR restricted to MCSes reachable from a root
   forms a linear order, using the temp_linearity axiom. This is standard frame
   correspondence theory (Goldblatt 1992).

2. **Int embedding**: Embed the countable linear order into Int. The standard
   Mathlib theorem `Order.embedding_from_countable_to_dense` embeds into Q (rationals),
   but Int is not dense. The reachable fragment's specific structure (built step-by-step
   by Lindenbaum extensions) may make it discrete and directly embeddable into Int.

3. **BFMCS Int construction**: Using the embedding, define `mcs : Int -> Set Formula`
   and prove forward_G, backward_H, forward_F, backward_P.

4. **Integration**: Wire the new construction into `temporal_coherent_family_exists_Int`
   and verify completeness theorem still works.

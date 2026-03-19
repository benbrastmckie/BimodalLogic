# Research Report: Task #988

**Task**: dense_algebraic_completeness
**Date**: 2026-03-19
**Focus**: How FMCSTransfer.lean (Task 995) unblocks dense algebraic completeness

## Summary

Task 995 delivered `FMCSTransfer.lean`, providing sorry-free temporal coherence transfer (forward_F and backward_P) from CanonicalMCS to any target domain D via an embedding/retraction pair. This module directly addresses the core blockers for dense algebraic completeness. To complete Task 988, we need to instantiate FMCSTransfer for D = Rat, which requires constructing an embedding/retraction pair between CanonicalMCS and Rat. The recommended approach is to compose TimelineQuot's existing infrastructure with the Cantor isomorphism.

## Findings

### 1. What FMCSTransfer.lean Provides

The new `FMCSTransfer.lean` module delivers:

| Component | Status | Description |
|-----------|--------|-------------|
| `FMCSTransfer` structure | PROVEN | Encapsulates embedding/retraction pair with compatibility conditions |
| `transferredFMCS` | PROVEN | Constructs FMCS on target D via retraction |
| `transfer_forward_F` | PROVEN | Sorry-free forward F coherence on D |
| `transfer_backward_P` | PROVEN | Sorry-free backward P coherence on D |
| `fmcs_domain_transfer` | PROVEN | Main theorem packaging all temporal coherence |
| `transferredTemporalCoherentFamily` | PROVEN | Convenience wrapper for completeness |

**Key design insight**: Instead of proving forward_F/backward_P directly on the target domain (which required complex witness constructions that weren't in the domain), FMCSTransfer proves them by:
1. Using the sorry-free proofs from CanonicalFMCS.lean (where all MCS are in the domain)
2. Embedding witnesses from CanonicalMCS into the target domain D

### 2. The FMCSTransfer Structure Requirements

To instantiate `FMCSTransfer D`, we need to provide:

```lean
structure FMCSTransfer (D : Type*) [Preorder D] where
  embed : CanonicalMCS ->o D        -- Monotone embedding
  retract : D -> CanonicalMCS       -- Inverse map
  retract_left_inverse : forall w, retract (embed w) = w
  embed_retract_eq : forall d, embed (retract d) = d  -- Makes embed surjective
  retract_lt : forall d1 d2, d1 < d2 -> retract d1 < retract d2  -- Strict monotone
  embed_lt : forall w1 w2, w1 < w2 -> embed w1 < embed w2       -- Strict monotone
```

**Critical constraints**:
- `embed_retract_eq` requires `embed` to be surjective (not just injective)
- Both `retract_lt` and `embed_lt` require strict monotonicity (not just non-strict)
- This effectively requires an order isomorphism, not just an embedding

### 3. Existing Infrastructure for Rat Instantiation

The codebase has several relevant components:

| File | Component | Status | Relevance |
|------|-----------|--------|-----------|
| `CantorApplication.lean` | `cantor_iso : TimelineQuot ≃o Rat` | PROVEN | Order isomorphism to Rat |
| `TimelineQuotCanonical.lean` | `timelineQuotMCS : TimelineQuot -> Set Formula` | PROVEN | MCS extraction from timeline |
| `TimelineQuotCanonical.lean` | `timelineQuot_lt_implies_canonicalR` | PROVEN | Timeline order implies CanonicalR |
| `TimelineQuotCanonical.lean` | `canonicalR_implies_timelineQuot_le` | PROVEN | CanonicalR implies timeline order |
| `CanonicalEmbedding.lean` | `ratFMCS_forward_F` | SORRY | Currently blocked |
| `CanonicalEmbedding.lean` | `ratFMCS_backward_P` | SORRY | Currently blocked |

### 4. Instantiation Strategy Analysis

**Option A: Direct CanonicalMCS to Rat (Problematic)**

The direct approach would be:
```lean
embed : CanonicalMCS ->o Rat
retract : Rat -> CanonicalMCS
```

**Problem**: There's no natural order-preserving map from CanonicalMCS (which contains ALL maximal consistent sets) to Rat. CanonicalMCS has Preorder based on CanonicalR, but:
- CanonicalMCS is NOT totally ordered (many MCS are incomparable)
- Rat is totally ordered
- An embedding CanonicalMCS ↪o Rat cannot exist when CanonicalMCS has incomparable elements

**Option B: Via TimelineQuot Composition (Recommended)**

Instead of trying to embed the entire CanonicalMCS into Rat, we should recognize that:

1. **TimelineQuot IS a quotient of specific MCS in the staged timeline** - it's a subset of "reachable" MCS, not all MCS
2. **TimelineQuot ≃o Rat** - This is an order isomorphism (both directions, sorry-free)
3. **TimelineQuot elements correspond to specific MCS** via `timelineQuotMCS`

The correct approach is to use TimelineQuot as an intermediate:

```
CanonicalMCS <-- timelineQuotMCS -- TimelineQuot ≃o Rat
```

**Key insight**: We don't need FMCSTransfer from the entire CanonicalMCS. We need a FMCS over Rat with:
- `mcs q := timelineQuotMCS (cantor_iso.symm q)` (already in CanonicalEmbedding.lean as `ratMCS`)
- forward_F and backward_P from DovetailedCoverage or staged timeline

### 5. Why CanonicalEmbedding.lean has Sorries

The existing `CanonicalEmbedding.lean` has sorries in `ratFMCS_forward_F` and `ratFMCS_backward_P` because:

1. It tries to use `canonical_forward_F` to get a witness MCS W
2. But W is an arbitrary MCS from Lindenbaum extension - it's NOT in the TimelineQuot
3. The TimelineQuot only contains MCS that were explicitly added during staged construction

**The gap**: `canonical_forward_F` gives witnesses outside the staged timeline.

### 6. How FMCSTransfer Actually Solves This

FMCSTransfer works differently:

1. It starts with CanonicalMCS as the domain (where all MCS are elements by construction)
2. `canonicalMCS_forward_F` is sorry-free because witnesses are always in CanonicalMCS
3. Then it TRANSFERS to D via the embedding, mapping witnesses to D via `embed`

**The key**: When we transfer forward_F from CanonicalMCS to D:
- For `F(phi) ∈ mcs(d)`, we get `F(phi) ∈ mcs(retract(d))` by construction
- `canonical_forward_F` gives witness `w : CanonicalMCS` with `retract(d) < w`
- We use `embed(w)` as the witness in D
- The constraint `embed_retract_eq` ensures `embed ∘ retract = id` on D

### 7. The Critical Gap: No Order Isomorphism CanonicalMCS ≃o D

For FMCSTransfer to work for D = Rat, we need:
- `embed : CanonicalMCS ->o Rat` with `embed_retract_eq : embed (retract q) = q`

This means `embed` must be surjective onto Rat. But CanonicalMCS contains ALL maximal consistent sets, not just those in the staged timeline. The order on CanonicalMCS is NOT total.

**This is the fundamental issue**: FMCSTransfer assumes the source domain (CanonicalMCS) can embed into the target domain D as a surjection. This works for D = CanonicalMCS (trivially) but not for D = Rat.

### 8. Alternative Approach: FMCSTransfer from TimelineQuot-subset

A variant approach that could work:

**Define a restricted source domain**:
```lean
def TimelineMCS (root_mcs root_mcs_proof) : Type :=
  { w : CanonicalMCS // w.world ∈ timeline_mcs_set root_mcs root_mcs_proof }
```

Where `timeline_mcs_set` contains exactly the MCS that appear in the TimelineQuot.

**Then define FMCSTransfer from TimelineMCS to Rat**:
- The embedding comes from `cantor_iso`
- The retraction comes from `cantor_iso.symm` composed with MCS extraction

**Issue**: This requires proving forward_F/backward_P for TimelineMCS first, which brings us back to the original problem (though with the staged timeline's coverage lemmas).

### 9. Most Viable Path Forward

Given the analysis, the most viable completion path is:

**Use FMCSTransfer with D = TimelineQuot, then compose with Cantor**

1. **Define FMCSTransfer for TimelineQuot**:
   - `embed : CanonicalMCS ->o TimelineQuot` where `embed w := toAntisymmetrization (...)`
   - This requires every CanonicalMCS element to map into the TimelineQuot
   - **Problem**: Only MCS in the staged timeline are in TimelineQuot

2. **Alternative: Bypass FMCSTransfer entirely for Rat**

   Since we already have:
   - `ratMCS : Rat -> Set Formula` (via `cantor_iso.symm` then `timelineQuotMCS`)
   - `ratMCS_is_mcs` proven
   - `ratMCS_forward_G` proven
   - `ratMCS_backward_H` proven

   What's needed:
   - `ratFMCS_forward_F`: Use `dovetailedTimeline_has_future` via staged timeline properties
   - `ratFMCS_backward_P`: Use `dovetailedTimeline_has_past` via staged timeline properties

   The DovetailedCoverage lemmas in Task 982 already provide sorry-free has_future/has_past. We just need to connect them to the ratFMCS.

## Recommendations

### Primary Path: Connect DovetailedCoverage to ratFMCS

**Phase 1: Connect TimelineQuot forward_F to DovetailedCoverage (3h)**

Create a proof that `timelineQuotFMCS` has forward_F by showing:
- Every TimelineQuot element corresponds to a DovetailedTimeline element
- DovetailedCoverage's `has_future` provides F-witnesses IN the timeline
- Map these witnesses back through the quotient

**Phase 2: Transfer to ratFMCS (2h)**

Once `timelineQuotFMCS` has sorry-free forward_F/backward_P:
- Use `cantor_iso` to transfer these properties to `ratFMCS`
- The order isomorphism preserves < relations, so witnesses transfer directly

**Phase 3: Fill CanonicalEmbedding.lean sorries (2h)**

Replace the current sorry-based proofs with the DovetailedCoverage-based proofs.

**Phase 4: Wire dense_representation_conditional (3h)**

Instantiate `dense_representation_conditional` with `construct_bfmcs_rat` using the now sorry-free ratBFMCS.

### Alternative Path: Modify FMCSTransfer Design

If we want to use FMCSTransfer specifically:

1. Create `TimelineMCS` as a subtype of CanonicalMCS restricted to staged timeline
2. Prove forward_F/backward_P for TimelineMCS using DovetailedCoverage
3. Create FMCSTransfer from TimelineMCS to Rat via Cantor isomorphism

This is more work but aligns with the FMCSTransfer architecture.

### Why FMCSTransfer Doesn't Directly Apply

The FMCSTransfer structure was designed for domains D where:
- Every D element corresponds to some MCS
- Every MCS in the source can be embedded into D

For D = Rat:
- Every Rat element corresponds to some MCS (via TimelineQuot)
- But NOT every MCS can be embedded into Rat (only those in the staged timeline)

FMCSTransfer's design assumes the source (CanonicalMCS) has the same "shape" as the target domain, which is only true when D contains all MCS or when we restrict to a subdomain.

## Next Steps

1. Verify DovetailedCoverage provides the exact properties needed for forward_F
2. Create bridge lemmas connecting DovetailedTimeline to TimelineQuot
3. Prove forward_F for timelineQuotFMCS using these bridges
4. Transfer via Cantor isomorphism to ratFMCS
5. Complete construct_bfmcs_rat without sorries
6. Wire to dense_representation_conditional

## References

- `FMCSTransfer.lean`: New transfer infrastructure (Task 995)
- `CanonicalFMCS.lean`: Sorry-free forward_F/backward_P for CanonicalMCS
- `CanonicalEmbedding.lean`: Current ratFMCS construction with sorries
- `DovetailedCoverage.lean`: Sorry-free has_future/has_past
- `CantorApplication.lean`: `cantor_iso : TimelineQuot ≃o Rat`
- `TimelineQuotCanonical.lean`: Bridge lemmas between TimelineQuot and CanonicalR
- Prior research reports 07 and 08: Detailed gap analysis

## Context Extension Recommendations

None - the analysis is well-documented in FMCSTransfer.lean comments and this report.

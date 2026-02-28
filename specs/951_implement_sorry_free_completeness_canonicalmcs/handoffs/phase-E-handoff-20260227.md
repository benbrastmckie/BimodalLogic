# Phase E Handoff: Fragment → Int Conversion

## Immediate Next Action

Implement an order-preserving surjection from Int onto a countable sub-fragment closed under F/P witnesses. The standard approach from the temporal logic literature is:

**Omega-squared chain construction**: Build a 2D array `chain : Nat × Nat → Fragment` where:
- Row n, column 0: GContent-successor of last element of row n-1 (ensures forward_G between rows)
- Row n, column k+1: if F(φ_k) is in chain(n, 0).world, use `enriched_seed_consistent_from_F` to place φ_k. The seed `{φ_k} ∪ GContent(chain(n, k).world)` is consistent IF F(φ_k) ∈ chain(n, k).world.

**Key issue**: Within a row, F(φ_k) might not persist from chain(n, 0) to chain(n, k). The Lindenbaum extension at column k-1 might have introduced G(¬φ_k), killing F(φ_k).

**Possible resolution**: Process obligations at the FIRST column where they appear. Use enriched_seed_consistent_from_F with chain(n, 0) (where F(φ_k) IS known to hold). Then set chain(n, 1) to the enriched successor. Process the next obligation at chain(n, 1), where F(φ_{k'}) might or might not hold. If it doesn't hold, skip it. The key is that each obligation (n, k) is processed at column 1 of some later row where F(φ_k) reappears (if it ever does).

## Current State

### File: BidirectionalReachable.lean (758 → 830 lines)
- Phase D additions: `fragment_le_total`, `IsTotal` instance, `BidirectionalQuotient` type, `instLinearOrderBidirectionalQuotient`
- All proofs compile without sorry

### File: CanonicalCompleteness.lean (493 → ~330 lines, rewritten)
- `fragmentFMCS`: FMCS on BidirectionalFragment (sorry-free, 12 lines)
- `fragmentFMCS_forward_F`: forward_F at fragment level (sorry-free)
- `fragmentFMCS_backward_P`: backward_P at fragment level (sorry-free)
- `enriched_seed_consistent_from_F`: KEY lemma for Int chain construction
- `enriched_seed_consistent_from_P`: backward analog
- `fragmentGSucc`, `fragmentFSucc`: chain building blocks
- `witness_seed_consistent`: foundational consistency lemma
- BoxContent/diamondWitnessMCS infrastructure

## Key Decisions Made

1. **Fragment FMCS approach**: Defining FMCS directly on BidirectionalFragment gives sorry-free forward_F/backward_P trivially. The fragment's closure properties (forward_F_stays_in_fragment, backward_P_stays_in_fragment) do all the work.

2. **Antisymmetrization**: Using Mathlib's Antisymmetrization gives a PartialOrder quotient. Combined with fragment_le_total, this gives a LinearOrder.

3. **Countability deferred**: The full BidirectionalFragment may be uncountable (each CanonicalR step has uncountably many Lindenbaum extensions). For Int embedding, a countable sub-fragment (FPClosure) is needed.

4. **enriched_seed_consistent_from_F**: This is THE key breakthrough lemma. It resolves the F-persistence problem by showing that `{φ} ∪ GContent(w.world)` is consistent when `F(φ) ∈ w.world`, using the fragment's witness as a consistency certificate.

## What NOT to Try

1. **Simple linear chain with deferred F-witness placement**: F-formulas don't persist through GContent seeds. Placing a witness at step n for an obligation at step i < n fails because F(φ) might not hold at step n-1.

2. **Max-based chain construction**: Defining chain(n) = max(chain(n-1), next_element) skips over elements, and φ ∈ W.world doesn't imply φ ∈ chain(n).world when chain(n) > W.

3. **Proving full fragment countability**: The BidirectionalFragment is likely uncountable in general.

## Critical Context

1. **enriched_seed_consistent_from_F** (line ~204 of CanonicalCompleteness.lean): When `F(φ) ∈ w.world` for fragment element `w`, the seed `{φ} ∪ GContent(w.world)` is consistent. This is proven using `forward_F_stays_in_fragment` which gives a fragment witness `W ⊇ {φ} ∪ GContent(w.world)`.

2. **F-persistence is the core blocker**: F(φ) = ¬G(¬φ) is NOT in GContent. So GContent-based chain construction does NOT propagate F-formulas. Any chain step can introduce G(¬φ) via Lindenbaum.

3. **The fragment FMCS IS correct**: `fragmentFMCS_forward_F` is proven sorry-free. The issue is ONLY about converting from fragment-level to Int-level.

4. **Plan path**: implementation-002.md, Phases E-H.

5. **Session ID**: sess_1772247674_resume

# Phase E Handoff v2: Fundamental Obstacle Analysis

## Status

Phase E is **BLOCKED** on a fundamental mathematical problem: transferring
forward_F/backward_P from BidirectionalFragment to FMCS Int.

## What Was Accomplished (Iteration 3)

No new code was written. This iteration focused on deep analysis of the
embedding problem. The analysis establishes that the F-persistence problem
is NOT a Lean implementation issue but a genuine mathematical obstacle
in the standard chain-based approach.

## The Core Problem

### What We Have (Sorry-Free)
- `fragmentFMCS : FMCS (BidirectionalFragment M0 h_mcs0)` with sorry-free forward_F/backward_P
- `bidirectional_totally_ordered`: fragment is totally ordered
- `enriched_seed_consistent_from_F`: key lemma for seed consistency

### What We Need
- `fully_saturated_bfmcs_exists_int` (line 580 of TemporalCoherentConstruction.lean): sorry-free

### The Gap: FMCS (BidirectionalFragment) -> FMCS Int

An `FMCS Int` requires `mcs : Int -> Set Formula` with:
- forward_G: G(phi) in mcs(t), t <= t' => phi in mcs(t')
- backward_H: H(phi) in mcs(t), t' <= t => phi in mcs(t')
- forward_F: F(phi) in mcs(t) => exists s >= t, phi in mcs(s)
- backward_P: P(phi) in mcs(t) => exists s <= t, phi in mcs(s)

Any order-preserving function `f : Int -> BidirectionalFragment` gives forward_G
and backward_H trivially. But forward_F requires the function's range to be
closed under F-witnesses -- which means f must be SURJECTIVE onto a sub-fragment
closed under F/P witnesses.

## Why Chain Approaches Fail: F-Persistence

### The Mechanism
F(phi) = neg(G(neg(phi))). GContent(M) = {psi | G(psi) in M}. When building
chain(n+1) from GContent(chain(n)) via Lindenbaum, the extension can freely
include G(neg(phi)), killing F(phi). This is because:

1. F(phi) is NOT in GContent(M) (it has the wrong syntactic form)
2. Lindenbaum extensions are non-constructive (Zorn's lemma)
3. Once G(neg(phi)) enters the chain, it propagates forward forever (by temp_4)

### Concrete Failure Scenario
- chain(t): F(phi) in chain(t).world
- chain(t+1): Lindenbaum extension of {seed} U GContent(chain(t))
  - The extension may include G(neg(phi))
  - Then F(phi) NOT in chain(t+1)
  - For ALL future s > t: neg(phi) in chain(s) (G propagation)
  - phi is NEVER in any chain(s) for s > t
  - forward_F VIOLATED

### Why Dovetailing/Round-Robin Doesn't Fix This
Processing obligation k at step n only works IF F(phi_k) persists until step n.
But F(phi_k) can be killed at step t+1 (one step after it appears), before
the round-robin gets to process it.

### Why Including F-Formulas in the Seed Doesn't Fix This
To preserve F-formulas, we'd want the seed to include {F(psi) | F(psi) in chain(n)}.
But {phi_k} U {F(psi) | F(psi) in M} U GContent(M) is NOT necessarily consistent.
Counter-scenario: F(phi_k) in M but neg(phi_k) derivable from GContent(M) + F-formulas.
The proof of enriched_seed_consistent_from_F only shows {phi_k} U GContent(M) is
consistent -- adding more formulas from M can break consistency.

## Approaches Analyzed and Rejected

### 1. Simple Linear Chain (Original DovetailingChain)
- Failed: F-formulas don't persist. 2 sorries in DovetailingChain.lean.

### 2. Round-Robin / Cantor-Pairing Enumeration
- Failed: F(phi_k) can be killed before the k-th processing step arrives.

### 3. Omega-Squared Chain (2D Array)
- Failed: Processing within rows has the same F-persistence issue between columns.

### 4. F-Preserving Seed (Include F-Formulas in Lindenbaum Seed)
- Failed: The enlarged seed {phi} U GContent U FFormulas is not necessarily consistent.

### 5. Custom Lindenbaum (Choose Extension Carefully)
- Approach: Show that Lindenbaum extension CAN avoid killing F-formulas.
- Status: Not obviously possible with the non-constructive Zorn's lemma formulation.

### 6. Embed BidirectionalFragment Directly as D
- Failed: BidirectionalFragment has no AddCommGroup structure (required for satisfiable D).

### 7. Use satisfiable_abs Instead of satisfiable Int
- Requires: AddCommGroup + LinearOrder + IsOrderedAddMonoid on D.
- Failed: BidirectionalFragment has none of these algebraic structures.

## Remaining Viable Approaches

### Option A: Controlled Lindenbaum Extension (Requires Mathematical Innovation)
Instead of standard Zorn-based Lindenbaum, use a CONTROLLED extension that
preserves specific properties. Key question: can we prove that for F(phi) in M,
the set GContent(M) U {phi_k, F(phi_1), F(phi_2), ...} is consistent?

The challenge: proving this seed is consistent requires showing that no finite
subset derives bot. The F-formulas are all in M (consistent), and phi_k is
consistent with GContent(M). But the COMBINATION might not be consistent.

**Open question**: Is {phi_k} U GContent(M) U {F(psi) | F(psi) in M, psi != phi_k}
always consistent when F(phi_k) in M?

If YES: This resolves the problem completely.
If NO: Need a different approach.

### Option B: Maximize Over Chains (Zorn on Chains Themselves)
Use Zorn's lemma to find a MAXIMAL chain through the fragment that is closed
under F/P witnesses. A maximal such chain would satisfy forward_F because any
unsatisfied F-obligation allows extension.

Challenge: Showing the maximal chain is countable (to embed in Int). Also,
the ordering on chains is not obvious.

### Option C: Semantic Approach (Bypass BFMCS for Completeness)
Instead of constructing BFMCS Int, prove completeness by a different route:
- Define truth directly on BidirectionalFragment
- Avoid the Int embedding entirely
- Requires significant refactoring of Representation.lean and Semantics

### Option D: Generalize satisfiable to Preorder D (Architecture Change)
Modify the semantics to allow `satisfiable D Gamma` where D is just a Preorder
(not a linearly ordered abelian group). This would allow using BidirectionalFragment
directly. Requires changes to:
- Semantics/Validity.lean: satisfiable, valid, semantic_consequence
- Semantics/Truth.lean: truth_at (F/P cases use < which requires LinearOrder)
- Representation.lean: all completeness proofs

This is a large architectural change but is mathematically sound.

## Key Decisions Made

1. The BidirectionalFragment approach successfully eliminates the sorry at the
   FRAGMENT level. The fragment-level FMCS is fully sorry-free.

2. The remaining challenge is PURELY about the Int embedding, not about
   forward_F/backward_P themselves.

3. The problem is equivalent to: "construct a countable linearly ordered set
   of MCSes, closed under F/P witnesses, that embeds order-preservingly into Int."

## Recommendation

**Option A** (controlled Lindenbaum) is the most promising near-term approach.
The key mathematical question to resolve is whether the enlarged seed is consistent.

If Option A fails, **Option D** (architecture change) is the cleanest solution
but requires significant refactoring effort.

## References

- Plan: specs/951_.../plans/implementation-002.md (Phases E-H)
- Previous handoff: specs/951_.../handoffs/phase-E-handoff-20260227.md
- BidirectionalReachable.lean: 832 lines, sorry-free
- CanonicalCompleteness.lean: 425 lines, sorry-free fragment FMCS
- DovetailingChain.lean: 2 sorries (forward_F, backward_P) - same fundamental issue
- TemporalCoherentConstruction.lean line 580: `fully_saturated_bfmcs_exists_int` sorry
- Session ID: sess_1772247674_resume

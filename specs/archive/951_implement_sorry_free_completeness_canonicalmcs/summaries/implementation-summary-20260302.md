# Implementation Summary: Task 951 Plan v7

**Date**: 2026-03-02
**Session**: sess_1772488424_a009
**Plan**: implementation-007.md (F-Preserving Seed Consistency)
**Status**: BLOCKED -- Conjecture provably false

## What Was Attempted

Plan v7 targeted the F-preserving seed consistency conjecture identified in research-024. The conjecture claimed that for a fragment element `w` with `F(phi) in w.world`:

```
{phi} U {F(psi) | F(psi) in w.world} U GContent(w.world)
```

is consistent (as a set of formulas in the Hilbert-style proof system).

## Phase 1: Analysis (COMPLETED)

Analyzed the existing `enriched_seed_consistent_from_F` proof structure:
- The existing lemma proves `{phi} U GContent(w.world)` consistent using a witness MCS `s` from `forward_F_stays_in_fragment` with `CanonicalR w.world s.world` and `phi in s.world`
- The proof observes `{phi} U GContent(w.world) subset s.world`, so every finite subset is consistent
- Extension to F-preserving seed requires `FContent(w.world) subset s.world` as well
- Key insight: `FContent(w.world) subset w.world` (trivially) and `GContent(w.world) subset w.world` (via T-axiom)

Multiple approaches were explored:
1. **Single-witness approach**: Find one MCS containing the full seed. Fails because Lindenbaum extension can non-deterministically include `G(neg psi)` (excluding `F(psi)`)
2. **Finite-subset compactness**: Show every finite L is consistent. Using minimum vs maximum of totally-ordered witnesses creates a tension: phi needs its own witness, but that witness may be beyond other F-formula witnesses
3. **Syntactic analysis**: What derivations can produce bot from F-formulas and GContent? This led directly to the counterexample

## Phase 2: Counterexample Discovery (BLOCKED)

**The conjecture is PROVABLY FALSE.**

### Counterexample Construction

For any formula `psi'` with `F(psi') in w.world`, set `phi = G(neg psi')`.

1. **Coexistence**: `F(phi) = F(G(neg psi'))` and `F(psi')` can coexist in an MCS.
   - Model: linear time {0, 1, 2, ...}
   - Time 0 (= w): psi' is false, F(psi') holds (witness: time 1)
   - Time 1: psi' is true
   - Time 2+: psi' is false at all times >= 2, so G(neg psi') holds at time 2
   - F(G(neg psi')) holds at time 0 (witness: time 2)

2. **Seed contradiction**: The seed `{G(neg psi')} U FContent(w.world) U GContent(w.world)` contains:
   - `phi = G(neg psi')` (from the {phi} part)
   - `F(psi') = neg(G(neg psi'))` (from FContent, since `F(psi') in w.world`)
   - This is the pair `{A, neg A}` -- contradictory

3. **Derivation of bot**: `G(neg psi'), neg(G(neg psi')) derives bot` trivially.

### Why This Is Fatal

- The counterexample is **structural**: it exists whenever `FContent(w.world)` is non-empty (which it always is, since every MCS contains `F(neg bot)`)
- No modification of the seed can fix this while preserving ALL F-obligations
- Excluding `F(psi') = neg(phi)` from the seed means that particular F-obligation is not forced into the successor, defeating the purpose of F-preservation
- The issue is fundamental: the scheduled formula phi and the F-obligations can be logically complementary

## Remaining Sorries

Unchanged from before this plan:
- `fragmentChainFMCS_forward_F` (FragmentCompleteness.lean:460)
- `fragmentChainFMCS_backward_P` (FragmentCompleteness.lean:471)

## Recommendations

1. **Priority 2 (Fragment-to-Int embedding)**: Prove `BidirectionalQuotient` is order-isomorphic to `Int` using `orderIsoIntOfLinearSuccPredArch` from Mathlib. This completely bypasses the chain construction and its F-persistence problem. Estimated 20-35 hours.

2. **Priority 3 (Fragment-level completeness)**: Accept completeness over `BidirectionalFragment` as an intermediate result. The theorem `fragmentFMCS_temporally_coherent` already provides sorry-free temporal coherence at the fragment level. Estimated 5-10 hours.

3. **Alternative**: Investigate whether a PARTIAL F-preservation (excluding the problematic phi-complement) combined with an inductive argument could work. Low confidence.

## Files Modified

- `specs/951_.../plans/implementation-007.md` -- Phase status markers updated, counterexample documented
- `specs/951_.../summaries/implementation-summary-20260302.md` -- This file

## No Code Changes

No Lean files were modified. The counterexample was discovered during Phase 1 analysis before any code was written.

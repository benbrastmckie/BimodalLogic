# Phase 4 Handoff: Reynolds k-Equivalence Bypass

- **Task**: 202
- **Session**: sess_1780033927_3wcw
- **Date**: 2026-05-28
- **Status**: BLOCKED (Phases 1-2 blocked, Phase 3 complete, Phase 4 blocked, Phase 5 pending)

## Current State

### Sorry Inventory (3 on critical path)

1. **`no_gaps_discrete`** (GoodStructures.lean:842) - THE core mathematical blocker
   - Reynolds Theorem 14: if two points are in different contemp_equiv classes, there's a class boundary at a successor pair
   - Requires Phase 1 (US expressive completeness over Prior structures)
   - ALL other sorries flow from this one

2. **`h_prior_UZ/SZ`** (ShiftAndGlue.lean:984,990) - semantic Prior-UZ/SZ discharge
   - Inside `chronicle_is_good_direct`
   - Needs: for ALL ψ, if F(ψ) at t then U(ψ, ¬ψ) at t (in temporal_truth terms)
   - The MCS-level Prior-UZ gives this via `chronicle_temporal_truth`, but ONLY for formulas covered by h_section
   - The quantification over ALL ψ in no_gaps_discrete's hypotheses is too strong
   - Fix: weaken `no_gaps_discrete` to require Prior-UZ only for bounded-depth formulas

3. **`countermodel_discrete_reynolds`** (Transfer.lean:866) - TaskFrame packaging
   - Needs to convert `temporal_truth ... s (neg phi)` to `NOT truth_at TM Omega tau t phi`
   - FUNDAMENTAL BLOCKER: with `WorldState = Unit`, atoms are position-independent
   - Position-tracking alternatives break shift-closure or transparent box
   - See plan BLOCKER note for full analysis

### Key Architectural Insight

The three requirements for the countermodel are mutually incompatible with the current `truth_at` definition:
1. **Shift-closed Omega** (ShiftClosed typeclass requirement)
2. **Transparent box** (box = identity, needed for S5 single-class)
3. **Position-dependent atom truth** (needed to match temporal_truth on Z-interval)

With WorldState = Unit: (1) and (2) satisfied, (3) fails.
With WorldState = Z (position-tracking): (3) satisfied, but (1) fails (shifted histories are different).
With all-shifts Omega: (1) and (3) satisfied, but (2) fails (different histories at same point give different atoms).

### Recommended Next Steps

**Option A: Parametric canonical model on Z (medium effort, ~4-6h)**
Instead of building the countermodel from the Z-interval's predicates, use the existing parametric canonical model infrastructure (ParametricCanonical.lean) directly on Z. This requires:
1. Building a BFMCS on Z from the chronicle's MCS chain
2. Proving restricted coherence (tc, buc, fuc) for this Z-based BFMCS
3. On Z, `succ_embed_surjective` is trivially true (Z is succ-Archimedean)
4. So the restricted coherence proofs that currently need `succ_cofinal` would become sorry-free on Z

This sidesteps the truth_at/temporal_truth correspondence entirely by using the algebraic (MCS-based) countermodel construction.

**Option B: Complete Phase 1 first (high effort, ~8-12h)**
Formalize US expressive completeness over Prior structures. This closes `no_gaps_discrete`, which then enables:
1. `chronicle_is_good_direct` becomes sorry-free (modulo h_prior_UZ/SZ, which can be proved with weakened hypotheses)
2. The original `chronicle_is_good` via `orderIsoIntOfLinearSuccPredArch` might become viable if `no_gaps_discrete` implies succ-Archimedean (worth investigating)

**Option C: Direct completeness on Z (novel approach, ~6-10h)**
Instead of going through the Reynolds pipeline (chronicle -> monadic structure -> good -> Z-interval -> countermodel), go directly:
1. From MCS A with neg phi, use Z-based Cantor chain
2. Build BFMCS on Z with the chain
3. Prove restricted coherence directly on Z (no succ_cofinal needed)
4. Apply parametric truth lemma
5. This completely bypasses the Reynolds pipeline and no_gaps_discrete

## Files Modified in This Session

No code changes were committed (reverted experimental position-tracking code that failed).

## Build Status

`lake build` passes with zero errors (1670 jobs).
No new sorries introduced. Existing sorries: 3 on critical path (same as before).

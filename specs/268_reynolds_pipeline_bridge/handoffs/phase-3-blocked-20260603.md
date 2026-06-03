# Phase 3 Blocked Handoff - Task 268

**Date**: 2026-06-03
**Session**: sess_1748984539_a3b2c1
**Phase**: 3 (Custom TaskFrame Truth Transfer and Countermodel Construction)
**Status**: BLOCKED

## What Was Accomplished

Phases 1-2 remain complete and sorry-free in ReynoldsBridge.lean:
- Phase 1: LimitDomSubtype as OrderedMonadicStructure
- Phase 2: Reynolds pipeline (limitdom_is_good, effectiveFormula identity lemmas, limitdom_root_neg_truth)

## What Was Attempted in Phase 3

Thorough analysis of the plan's approach (building `h_truth_corr` with `zIntervalTaskFrame` WorldState=Unit) and three alternative approaches.

## Root Cause of Blocker

### The Fundamental Incompatibility

The plan assumes `h_truth_corr : ∀ ψ t, truth_at TM zIntervalOmega zIntervalHistory (iso t) ψ ↔ temporal_truth (Z.toOrdered sig) atomMap_fwd t ψ` can be proved with `zIntervalTaskFrame` (WorldState = Unit).

**This is provably impossible.**

With `WorldState = Unit` and singleton `zIntervalOmega = {zIntervalHistory}`:
- `truth_at ... t (.atom a) = ∃ (ht : True), TM.valuation () a` -- **position-independent** (constant for all t)
- `temporal_truth ... t (.atom a) = Z.interp (atomMap_fwd (.atom a)) t.val` -- **position-dependent**

The biconditional cannot hold when the Z-interval has non-constant atom predicates, which is the general case.

### Three Alternatives Explored (All Failed)

1. **Predicate-tracking WorldState + singleton Omega**: WorldState = (sig.preds → Prop), states carry Z-interval predicates. But `ShiftClosed {τ}` requires `τ.time_shift Δ = τ` for all Δ, which fails because shifted histories have different predicate assignments at each position.

2. **Orbit-based Omega**: Omega = {τ.time_shift Δ | Δ : ℤ} is shift-closed, but box transparency breaks. `truth_at (.box ψ) t` requires ψ true at t in ALL shifted histories (= ψ true everywhere), while `temporal_truth (.box ψ)` is a single predicate lookup. Matching these requires proving an S5 transfer property: `Z.interp (atomMap_fwd (.box ψ)) t ↔ ∀ s, temporal_truth ... s ψ`. This is provable in principle from one_class + k-equivalence but requires ~300 lines of new infrastructure.

3. **Direct proof of chronicle_gap_contradiction via k-equivalence**: Succ-orbit cofinality is NOT expressible as a bounded-depth FO sentence, so k-equivalence cannot transfer it. This approach is fundamentally non-viable.

### Why the Three Requirements Are Mutually Exclusive

| Requirement | Needed For | Conflicts With |
|---|---|---|
| Position-dependent atoms | Atom case of h_truth_corr | Singleton Omega (Unit states) |
| Box transparency | Box case of h_truth_corr | Non-singleton Omega |
| Shift-closed Omega | Countermodel existential | Position-dependent states in singleton Omega |

## Viable Paths Forward

### Path A: S5 Orbit Approach (~300-400 lines)
1. Define TaskFrame with WorldState = (sig.preds → Prop)
2. Define task_rel M d N := (d = 0 → M = N)
3. Build orbit-based Omega
4. Prove S5 box transfer: `Z.interp (atomMap_fwd (.box ψ)) t ↔ ∀ s, temporal_truth ... s ψ`
5. Use this for the box case of h_truth_corr
6. Requires proving several FO transfer lemmas for constant predicates via k-equivalence

### Path B: Prove chronicle_gap_contradiction (~200-500 lines)
- Requires showing the limit domain has no ω-gaps (every bounded succ-orbit has its supremum in the domain)
- Cannot use k-equivalence (wrong tool for the job)
- Might use the omega-chain argument or a direct topological/order-theoretic proof

### Path C: Hybrid approach
- Use Path A for the truth correspondence
- Need to also extract unboundedness of Z-interval from `limitdom_is_good`
- Total: ~400-500 lines of new code

## Key Decisions Made

- Plan's approach with WorldState=Unit is provably impossible -- documented in plan blocker
- All three alternative approaches require significant new infrastructure (200-500 lines)
- Phase 3 is blocked pending user decision on which path to pursue

## Files Modified

- `specs/268_reynolds_pipeline_bridge/plans/04_strategy-b-plan.md` -- Phase 3 marked [BLOCKED], blocker documented, tasks annotated
- No changes to Lean source files (blocker is architectural, not a code bug)

## Next Action

User must decide which viable path to pursue (A, B, or C) and revise the plan accordingly. Path A (S5 orbit) is the most self-contained but requires substantial new lemmas about k-equivalence transfer of constant predicates. Path B (chronicle_gap_contradiction) would eliminate the sorry chain entirely but is the hardest.

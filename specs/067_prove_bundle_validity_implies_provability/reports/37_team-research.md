# Research Report: Task #67 — Bulldozing vs Construction Alternatives

**Task**: prove_bundle_validity_implies_provability
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Session**: sess_1774881975_37fa84

## Summary

Two teammates investigated alternatives to the dead-end fuel approach: Teammate A researched Segerberg's bulldozing technique (1970) adapted to our setting; Teammate B surveyed construction-level alternatives working backward from the crux. They **agree** on the fundamental diagnosis and converge on a clear recommendation.

## Key Findings

### From Teammate A: Segerberg's Bulldozing Adapted

1. **What bulldozing actually is**: Segerberg's technique transforms reflexive clusters into omega-sequences where every world recurs infinitely, ensuring F-obligations are eventually satisfied through exhaustive repetition.

2. **Correct adaptation for our setting**: For linear tense logic over Z (no reflexive clusters), bulldozing becomes a **seeded Lindenbaum construction** that adds ALL `f_content(u)` to the successor seed — not the dovetailed formula selection that Plan 8 attempted.

3. **Why Plan 8 failed (and why the k >= B sorry fails) — same root cause**: Both trace to F-persistence failure. The Lindenbaum extension can add `G(neg chi)` which destroys `F(chi)`. Plan 8 tried to select ONE formula to resolve per step; the current chain allows ALL formulas to be destroyed.

4. **The fix is minimal**: Add `f_content(u)` (the set of all F-formulas in u) to `constrained_successor_seed_restricted`. Since `f_content(u) ⊆ u` and u is consistent, the extended seed remains consistent. Since `f_content(u) ⊆ deferralClosure(phi)`, the DRM property is preserved.

5. **F-persistence follows by construction**: With `F(psi)` in the seed, the Lindenbaum extension cannot add `G(neg psi)` (MCS consistency), so `F(psi) ∈ chain(k) → F(psi) ∈ chain(k+1)`. Combined with BRS forcing resolution at max depth, ALL F-obligations must resolve within B steps.

### From Teammate B: Backward-from-Crux Analysis

1. **Exact goal states verified**: Both sorries (lines 3006, 3037) need `False` from `F(iter_F n theta) ∈ chain(k)` with `k >= B` and `n + 1 < B`. No available hypotheses can close this without a new lemma.

2. **BRS is stronger than previously thought**: Forces resolution at depths >= B-2 (not just B-1), because `iter_F B theta ∉ deferralClosure phi` is always true. But depths < B-2 are still unforced.

3. **Survey of alternatives**:
   - A1 (Fairness Counter): 10-15h, high risk, major construction change
   - A2 (Strengthen BRS to all depths): 5-8h, moderate risk, moderate construction change
   - A3 (Well-founded on Active Obligations): 8-12h, high risk, no construction change
   - A4 (Full Henkin + Transfer): 15-20h, very high risk
   - A5 (Explicit Fair Sequence): 4-6h, medium risk, but cascade fails at depth B-3
   - Bulldozing (Teammate A's approach): 4-8h, medium risk, minimal construction change

4. **No silver bullet without construction changes**: Confirmed by 12 prior plans and systematic analysis. The construction fundamentally does not prevent F-obligation destruction.

## Synthesis

### Agreement: Both Teammates Converge

Both teammates independently identified the same root cause: **F-obligations can be destroyed by the Lindenbaum extension**. Both agree the construction must change. The key question is HOW.

### Comparison: Teammate A's Bulldozing vs Teammate B's Alternatives

| Approach | Effort | Risk | Construction Change | Key Advantage |
|----------|--------|------|---------------------|---------------|
| **Bulldozing (f_content in seed)** | **4-8h** | **Medium** | **Minimal (add to seed)** | **Simplest; consistency trivial** |
| Fairness Counter (A1) | 10-15h | High | Major (new parameter) | Most principled |
| Strengthen BRS (A2) | 5-8h | Medium | Moderate | Leverages existing BRS |
| Well-Founded (A3) | 8-12h | High | None | No construction change |
| Explicit Fair Sequence (A5) | 4-6h | Medium | None | But cascade fails at B-3 |

### Resolution: Bulldozing Wins

Teammate A's approach is **strictly better** than all of Teammate B's alternatives because:

1. **Minimal change**: Only adds `f_content(u)` to the seed — one line in the definition
2. **Trivial consistency**: `f_content(u) ⊆ u` and u is consistent, so seed stays consistent
3. **DRM preservation**: `f_content(u) ⊆ deferralClosure(phi)` automatically
4. **F-persistence by construction**: No need for separate fairness tracking
5. **Makes BRS cascade complete**: With F-persistence, the BRS cascade that Teammate B analyzed now covers ALL depths (not just >= B-2), because deferred F-formulas persist until they hit the BRS trigger depth
6. **Existing proofs preserved**: Adding to the seed doesn't break existing seed-subset proofs

The approach makes Teammate B's Alternative A5 work automatically: with F-persistence, the BRS cascade covers all depths within B steps because:
- Step 1: F-formulas at depth B-1 hit BRS, get resolved
- Step 2: F-formulas at depth B-2 persist (F-persistence!), now at depth B-1, hit BRS
- ...continuing cascade...
- Step B: All depths resolved

### Gaps and Risks

1. **Seed consistency proof** (MEDIUM): Must prove `constrained_successor_seed_bulldozed_consistent`. Since `f_content(u) ⊆ u` and u is consistent, this should follow from existing proofs. But the formal Lean proof needs verification.

2. **Downstream lemma breakage** (LOW): Adding to the seed is strictly more information. Existing proofs about seed subsets should still hold. Need to check all references to `constrained_successor_seed_restricted`.

3. **Risk 4 from Teammate A** (RESOLVED): Even with `f_content(u)` in seed, Lindenbaum can't destroy F-obligations because `F(psi) ∈ seed ⊆ successor` forces `G(neg psi) ∉ successor` by MCS consistency.

4. **BRS at boundary** (RESOLVED): At BRS trigger depth, the obligation is resolved (chi ∈ successor, not F(chi)). F-persistence is not needed here because BRS handles it.

## Recommendations

### Primary: Implement Bulldozing via Seeded F-Content (4-8h)

**Step 1**: Modify `constrained_successor_seed_restricted` to include `f_content(u)`:
```lean
def constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪
  p_step_blocking_formulas_restricted phi u ∪
  boundary_resolution_set phi u ∪
  f_content u  -- NEW: F-persistence (bulldozing)
```

**Step 2**: Prove seed consistency for the extended seed (trivial: f_content(u) ⊆ u)

**Step 3**: Prove F-persistence theorem:
```lean
theorem constrained_successor_restricted_f_persistence (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (psi : Formula)
    (h : Formula.some_future psi ∈ M0.world) :
    Formula.some_future psi ∈ (constrained_successor_restricted phi M0).world
```

**Step 4**: Prove `boundary_implies_k_lt_B` using F-persistence + BRS cascade

**Step 5**: Close lines 3006 and 3037 with `exfalso` + the new lemma

### Secondary: Mark Fuel Approach as Dead End

Before implementing, remove fuel-based code and mark in comments:
- Remove the `h_inv` / `remaining_steps` parameter from `restricted_bounded_witness_wf`
- Add comments: `-- DEAD END: fuel invariant approach (Plans v1-v12). See reports 31, 34.`
- Update ROAD_MAP.md with a "Dead Ends" section documenting the fuel approach

### Anti-Recommendation: Do Not Pursue

- Alternative A3 (well-founded on Finset measures) — too verbose in Lean
- Alternative A4 (full Henkin + transfer) — too much effort for uncertain payoff
- Plan 8's dovetailed approach — already proven to fail for the same root cause

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Segerberg bulldozing adaptation | completed | High |
| B | Backward-from-crux alternatives | completed | Medium-High |

## Conflicts Found

None — teammates converge on the same diagnosis and the bulldozing approach dominates all alternatives.

## References

- Segerberg, K. (1971). An Essay in Classical Modal Logic. Uppsala.
- Teammate A findings: specs/067_prove_bundle_validity_implies_provability/reports/37_teammate-a-findings.md
- Teammate B findings: specs/067_prove_bundle_validity_implies_provability/reports/37_teammate-b-findings.md
- Report 34: specs/067_prove_bundle_validity_implies_provability/reports/34_team-research.md
- Summary 12: specs/067_prove_bundle_validity_implies_provability/summaries/12_chain-resolution-summary.md

# Handoff: SDC-Maximality Refactor -- CE Update Progress

## Session
- **Session ID**: sess_1778221275_3b41e2
- **Date**: 2026-05-08
- **Agent**: lean-implementation-agent (3rd attempt)

## Summary of Changes Made

### PointInsertion.lean (BUILDS, 1 sorry)

All 14 original errors fixed. Key changes:

1. **lemma_2_7**: Added `(h_cons : SetConsistent (deductiveClosure ({xi} ∪ B)))` parameter. Removed `by_cases h_xi_B_cons` and sorry-ed inconsistent branch. Replaced `h_DC_cud` with `h_DC_sdc` using h_cons. Replaced `h_B_dcs` with `h_r3m.1` for second Zorn call.

2. **lemma_2_7_seed_consistent**: Added `h_cons` parameter. Passes to `BurgessR3Maximal_extension_fails`.

3. **lemma_2_8**: Added `h_cons` parameter. Same Zorn seed fix (h_DC_sdc, h_r3m.1).

4. **lemma_2_7_since**: Added `h_cons` parameter. Same fixes.

5. **lemma_2_7_since_seed_consistent**: Added `h_cons` parameter.

6. **lemma_2_8_since**: Added `h_cons` parameter. Same Zorn fixes.

7. **lemma_2_4_with_guard**: Added `(h_dc_cons : SetConsistent (deductiveClosure ({γ} : Set Formula)))` parameter. Passes to `burgessR3Maximal_with_guard`.

8. **lemma_2_4_since_with_guard**: Added `h_dc_cons` parameter. Same.

9. **burgess_D0_seed_consistent**: Fixed consistent case to pass `deductiveClosure_consistent h_cons` to `BurgessR3Maximal_extension_fails`.

10. **burgess_D0_finite_subset_consistent_incons**: MCS sub-case replaced with `sorry` (see Blocker section).

11. **neg_mem_of_inconsistent_union**: Made non-private (was private, now used by CE).

12. **burgess_D0_seed_consistent non-MCS case**: Fixed to pass `deductiveClosure_consistent (by rwa [Set.insert_eq] at _h_delta'_cons)`.

### CounterexampleElimination.lean (PARTIALLY UPDATED, ~25 errors remain)

1. **BurgessR3Maximal_bot_not_mem**: sorry CLOSED. Proof: `h_r3m.1.1` gives `SetConsistent B`, so [⊥] ⊆ B with [⊥] ⊢ ⊥ contradicts consistency.

2. **Duplicate BurgessR3Maximal_sdc**: REMOVED (already exists in RRelation.lean).

3. **`.1` -> `.1.2` for CUD access**: DONE for all 29 occurrences of `h_r3m_adj.1 h_gc_adj` and `h_r3m.1 h_gc`.

4. **Helper lemmas added**:
   - `dc_union_cons_of_mem`: DC({φ}∪S) consistent when φ ∈ S and S consistent
   - `dc_union_cons_of_neg_not_mem`: DC({φ}∪S) consistent when φ ∉ S, φ.neg ∉ S, S SDC

## Remaining Errors (~25 in CE)

### Pattern A: lemma_2_7/2_8 calls need h_cons argument (~20 sites)

Each call to `lemma_2_7`, `lemma_2_8`, `lemma_2_7_since`, `lemma_2_8_since` now needs an extra `h_cons` argument providing `SetConsistent (deductiveClosure ({xi} ∪ B))`.

**For lemma_2_8 calls (ξ ∈ g)**: Append `(dc_union_cons_of_mem h_r3m_adj.1.1 h_xi_g)`.

**For lemma_2_7 calls (ξ ∉ g)**: The call needs `dc_union_cons_of_neg_not_mem h_r3m_adj.1 h_xi_not_g h_xi_neg_not_g`. CRITICAL: the existing code does NOT case-split on `ξ.neg ∈ g`. A new case split is needed at EACH lemma_2_7 call site:
```
by_cases h_xi_neg_g : ξ.neg ∈ χ.g pt x'
· -- ξ.neg ∈ g: can't call lemma_2_7 (DC({ξ}∪g) inconsistent). 
  -- Instead use lemma_2_6_splitting with β = ξ (ξ ∉ g) to get D with ξ.neg ∈ D.
  -- Then construct split result similarly to the existing lemma_2_6 cases.
  <use lemma_2_6_splitting approach>
· -- ξ.neg ∉ g: DC({ξ}∪g) is consistent. Call lemma_2_7 with consistency proof.
  obtain ⟨B', D, B'', ...⟩ := lemma_2_7 ... (dc_union_cons_of_neg_not_mem h_r3m_adj.1 h_xi_not_g h_xi_neg_g)
```
This structural change is needed at approximately 12 lemma_2_7 call sites (6 forward, 6 backward).

**For lemma_2_7 calls with `ξ.and(ξ.untl η)` as guard (compound formula ∉ g)**: The guard is `Formula.and ξ (Formula.untl ξ η)`. Need its neg not in g. This comes from `h_conj_g` being false.

**For lemma_2_8_since calls (ξ ∈ g)**: Same as lemma_2_8 but for since direction.

**For lemma_2_7_since calls (ξ ∉ g AND ξ.neg ∉ g)**: Same pattern.

Error lines (approximate): 1063, 1066, 1090, 1091, 1095, 1106, 1640, 1643, 1667, 1671, 1675, 1686, 2137, 2140, 2166, 2169, 2174, 2191, 2666, 2669, 2694, 2698, 2701, 2713

### Pattern B: lemma_2_4_with_guard needs h_dc_cons (~4 sites)

Lines 756, 1339, 1907, 2439: `.choose` field errors because `lemma_2_4_with_guard` now returns a function needing `h_dc_cons`.

**Fix**: At each call site, provide `SetConsistent (deductiveClosure ({ξ} : Set Formula))`. Since ξ typically comes from `untl(ξ, η) ∈ f(x)` where f(x) is MCS, prove DC({ξ}) consistent by: if DC({ξ}) inconsistent, then ⊢ ¬ξ, so ξ.neg ∈ f(x). Combined with untl(ξ, η) ∈ f(x) and BX axioms... actually need to check if this is straightforward.

**Alternative**: If ξ = ⊥ (contradictory guard), DC({ξ}) is inconsistent and the function can't be called. But this case means `next(η) ∈ f(x)` and the guard is vacuous -- the walk doesn't need ξ ∈ g. So the caller should handle this case separately (skip lemma_2_4_with_guard).

### Pattern C: Walk helper parameter changes (~2 sites)

Lines 3051, 3355: "Function expected" errors in the C5 forward/backward walk. These are related to `h_r3m_adj.1` being SDC instead of CUD. The walk helpers (`c5_forward_walk`, `c5_backward_walk`) have `h_B_sdc_w` parameters. Need to check if the parameter passing changed.

## Blocker: MCS B in burgess_D0_finite_subset_consistent_incons

**Status**: sorry (PointInsertion.lean ~line 2050)

**Issue**: When B is MCS and β.neg ∈ B (from `β ∉ B`), the D₀ seed `B ∪ {β.neg} ∪ untl-formulas ∪ snce-formulas` can be INCONSISTENT. If untl(β', γ) ∉ B for some β' ∈ B, γ ∈ C (which happens when B is MCS and untl(β', γ).neg ∈ B), then D₀ contains both untl(β', γ) and its negation.

**Mathematical resolution**: Either prove BurgessR3Maximal B is never MCS (hard -- maximality clause is vacuous for MCS B), or restructure lemma_2_6_splitting callers to handle MCS g-values differently (requires walk-level changes).

**Impact**: This sorry is NOT on the critical path for bx_completeness if BurgessR3Maximal B is never MCS in practice (the Zorn construction produces SDC-maximal sets, not MCS). But a formal proof of non-MCS-ness is needed.

## Build Status

- ChronicleTypes.lean: OK
- RRelation.lean: OK
- PointInsertion.lean: OK (1 sorry in MCS sub-case of _incons)
- CounterexampleElimination.lean: ~25 errors remaining (all from new h_cons/h_dc_cons parameters)

## Files Modified
- PointInsertion.lean (parameter additions, sorry in MCS case)
- CounterexampleElimination.lean (partial: .1->.1.2, bot_not_mem closed, helpers added)

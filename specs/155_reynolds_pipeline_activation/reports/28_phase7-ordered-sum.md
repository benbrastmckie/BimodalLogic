# Phase 7 Ordered Sum: Correctness Analysis and Critical Path Assessment

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: `cofinal_decomposition_k_equiv` correctness and downstream impact

---

## 1. What Reynolds 1994 Says

Reynolds 1994, Lemma 16 (p.877-878, lines 877-903 of the markdown):

> "Choose a_i ∈ N for each positive integer i such that i < j implies a_i < a_j and for all t ∈ N, there is j such that t < a_j. Since N is very good, **N | a_i, a_{i+1} - 1** is good. For i = 0, 1, ..., take Z_i ~k N | a_i, a_{i+1} - 1 with a finite interval of Z as a flow."

Key: Reynolds uses `a_{i+1} - 1` (the predecessor), making intervals **disjoint**:
- Piece i: [a_i, a_{i+1} - 1]
- Piece i+1: [a_{i+1}, a_{i+2} - 1]

These share no elements. The ordered sum (lexicographic on Sigma) is then isomorphic to N.

Reynolds then says: "Because ~k is preserved under lexicographic sums, N ~k Σ_{i∈N}(Z_i), the latter having flow isomorphic to a (half) subinterval of Z."

## 2. What Our Code Does

```lean
-- IntegerModel.lean line 1130
cofinal_decomposition_k_equiv sig k M a h_mono h_cofinal :
    k_equiv sig k M (orderedSum sig ℤ (fun i => M.subinterval sig (a i) (a (i + 1))))
```

`M.subinterval sig (a i) (a (i + 1))` has carrier `{x : M.carrier // a i ≤ x ∧ x ≤ a (i + 1)}` — a **closed** interval. Boundary point `a(i+1)` appears in BOTH piece i and piece i+1.

The ordered sum carrier is `Σ i : ℤ, {x // a i ≤ x ∧ x ≤ a (i+1)}`. At boundary `a(i+1)`:
- `⟨i, ⟨a(i+1), _, _⟩⟩` — element in piece i
- `⟨i+1, ⟨a(i+1), _, _⟩⟩` — element in piece i+1

These are **distinct** elements in the Sigma type with `⟨i, ...⟩ < ⟨i+1, ...⟩` (lexicographic), yet both project to `a(i+1)` in M. The ordered sum has strictly more elements than M.

## 3. Is the Theorem Provably False?

**For k = 0, 1**: Likely still correct (0-types and 1-types don't distinguish between adjacent duplicates with identical predicates).

**For k ≥ 2**: The counterexample sketch from the Phase 7 handoff is plausible but not definitive. The key issue is whether the duplicated boundary point creates new realizable normal forms at depth 2. Two distinct elements `⟨i, a(i+1)⟩` and `⟨i+1, a(i+1)⟩` with identical predicates and `⟨i, a(i+1)⟩ < ⟨i+1, a(i+1)⟩` form a 2-variable normal form. In M, this NF requires two distinct elements with the same predicates in strict order — which may not exist if `a(i+1)` is an isolated predicate pattern.

**Verdict**: The theorem is likely incorrect for k ≥ 2 in general, but may be correct for the specific M structures that arise in practice (chronicles with SuccOrder).

## 4. Critical Path Assessment

**`very_good_implies_good` is NOT on the critical path to sorry-free `bx_completeness`.**

Evidence:
- `very_good_implies_good` is defined at line 1210 but **never used** anywhere in the codebase. `grep -rn "very_good_implies_good"` returns only the definition, its two helper calls, and comments.
- `chronicle_is_good` (line 1245) is **already sorry-free** — it constructs a Z-interval directly via `orderIsoIntOfLinearSuccPredArch` + `k_equiv_of_iso`, without any reference to `very_good_implies_good`.
- `one_class` (line 900) uses `no_gaps_discrete` (Phase 8), NOT `very_good_implies_good`.
- The sorry chain to `bx_completeness` goes through EFGames.lean (Lemma 9, Corollary 5) and ExpressivenessGeneral.lean (d-consistency, Cases III/IV), NOT through the very_good path.

### Downstream dependency map

```
bx_completeness
  ← countermodel_discrete (Transfer.lean, Phase 10 DONE)
    ← dd_countermodel_chronicle_discrete
      ← chronicle_is_good (SORRY-FREE, no Phase 7 dependency)
      ← stavi_expressive_completeness (Phase 4, sorry in EFGames.lean)
      ← EFGames sorry chain (Phases 2-4)
      ← ExpressivenessGeneral sorry chain (Phases 1, 3)
```

### Phase 7, 8, 9 reassessment

| Phase | Was supposed to | Actually needed? |
|-------|----------------|-----------------|
| 7 (cofinal decomp + ordered sum) | Prove `very_good_implies_good` | **NO** — never used on critical path |
| 8 (no_gaps_discrete) | Wire to gap_elimination_theorem_14 | **NO** — `one_class` uses it but `one_class` is never used on critical path |
| 9 (rewrite chronicle_is_good) | Remove IsSuccArchimedean | **MAYBE** — `chronicle_is_good` is sorry-free but uses `orderIsoIntOfLinearSuccPredArch` which requires IsSuccArchimedean on the chronicle domain |

Phase 9's `IsSuccArchimedean` removal is only needed if IsSuccArchimedean propagates as a sorryAx into `bx_completeness`. Since `ChronicleAsPriorModel` provides `SuccOrder`, `PredOrder`, and `IsSuccArchimedean` as part of its structure (not via sorry), this should be clean.

## 5. Fix Options (if Phase 7 is ever needed)

| Option | Description | Effort | Matches Reynolds |
|--------|-------------|--------|-----------------|
| A. Half-open intervals | `{x // a i ≤ x ∧ x < a (i+1)}` | ~200 lines | No |
| B. Discrete predecessor | `{x // a i ≤ x ∧ x ≤ Order.pred (a (i+1))}` | ~100 lines | Yes |
| C. Boundary identification | Quotient duplicates, prove k-equiv preserved | ~250 lines | No |
| D. Skip entirely | Remove `very_good_implies_good` + helpers | ~-100 lines | N/A |

**Recommendation**: Option D (skip) if Phase 7 is confirmed off critical path. Option B if ever needed.

## 6. Summary

| Finding | Detail |
|---------|--------|
| Reynolds construction | Uses `[a_i, a_{i+1} - 1]` (disjoint predecessor-bounded intervals) |
| Our construction | Uses `[a_i, a_{i+1}]` (overlapping closed intervals) |
| Theorem correctness | Likely false for k ≥ 2 due to boundary duplicates |
| Critical path impact | **NONE** — `very_good_implies_good` is orphaned infrastructure |
| Recommendation | **Deprioritize Phase 7**. Focus on Phases 1-4 (GHR93 core) |

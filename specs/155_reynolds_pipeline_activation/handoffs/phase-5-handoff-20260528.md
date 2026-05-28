# Phase 5 Handoff: Grid Dispatch Sorry Closure (Partial)

## What Was Done
- Analyzed all 5 grid dispatch sorries in CaseAnalysis.lean (Case A: lines 1668-1669, Case B1: 2031-2032, Case B2: 2112)
- Identified root cause: `same_order_type_grid` macro uses hygienic `intro`, making `i` and `j` inaccessible after `<;>`. This prevents `by_cases` on sel-index bounds.
- Discovered that `rename_i` renames from the END of inaccessible name list, and has hard errors (not failures) when count mismatches -- so `first | rename_i ... | rename_i ...` does NOT work as a fallback chain.
- Discovered that `same_order_type_grid_uh` with `unhygienic` also does NOT propagate through `<;>`.
- Found the WORKING approach: replace `same_order_type_grid` with its manual expansion `(intro i j; simp only [game_tuple]; split_ifs)`, keeping `i` and `j` directly accessible.
- Applied the manual expansion approach for Case A grid dispatch. The syntax compiles but some proof terms need adjustment.
- Wrote B2 grid dispatch from scratch (replacing bare `sorry`).

## Key Decisions
- NOT doing a full GHR93 Case II rewrite (plan's approach). Instead, closing the 5 sorries in-place using tactic infrastructure.
- Using manual macro expansion (`intro i j; simp only [game_tuple]; split_ifs`) instead of `same_order_type_grid` at grid dispatch sites.
- Using `by_cases hjn : j.val - 1 < n <;> (try rw [...]) <;> first | ...` pattern for handling remaining sel-index goals.

## Current Blockers
- Type mismatch at line ~1739 in the `j = n` (p_n/e_n boundary) case of the grid dispatch. The `hbc` hypothesis has type `¬(extendPoint b_sp ≤ c)` in the Case B branch, but some proof terms use `hbc` as if it were `c < extendPoint b_sp`. Need to add `push_neg at hbc` or use `lt_of_not_le hbc` (now deprecated as `lt_of_not_ge`).
- B1 and B2 grid dispatches need the same manual expansion treatment as Case A.
- B2 dispatch needs verification of the `pivot_chain_order` arguments (sel vs b_resp through p_n/e_n chains).

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Case A grid dispatch: replaced `same_order_type_grid` with manual expansion; added `by_cases` dispatch for sel-index goals; B2 grid dispatch framework added.

## Next Action
1. Fix the type mismatch in Case A grid dispatch (line ~1739): adjust `hbc` usage for `¬(≤)` vs `<` form.
2. Apply same manual expansion to Case B1 grid dispatch (currently at line ~2022).
3. Apply same manual expansion to Case B2 grid dispatch (currently has framework but needs B2-specific orderings).
4. Run `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` to verify all grid dispatch sorries are closed.
5. Proceed to Phase 6 (Cases III/IV) or Phase 7 (Transfer.lean rewiring).

## Proof State
- Case A: 90% done -- manual expansion works, `by_cases` structure correct, just need proof term fixes
- Case B1: Not started (still has `sorry` with `same_order_type_grid` macro)
- Case B2: Framework written, needs proof term verification
- All other proofs in CaseAnalysis.lean compile (gap_point_agreement, formula_agreement sections are clean)

# Research Report: Task #48

**Task**: prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-24
**Mode**: Team Research (2 teammates)
**Session**: sess_1774333345_98d055
**Sources**: Task 52 comprehensive review, Task 53 bounded-witness restructuring, 26 prior research reports

## Summary

Two complementary approaches to unblocking Task 48 were analyzed in depth: (A) seed modification to force boundary resolution, and (B) algebraic bypass via STSA/Jónsson-Tarski. Both are viable. The seed modification approach is more targeted (~4-6 hours) but carries a proof obligation whose difficulty is uncertain. The algebraic bypass is more comprehensive (~8-10 hours) but avoids the fundamental limitation entirely. A hybrid strategy is recommended.

## Key Findings

### Primary Approach: Seed Modification (from Teammate A)

**Status**: Viable with refinement needed

The infrastructure for seed modification largely exists already:

1. **`boundary_resolution_set`** is defined in `SuccExistence.lean:317-321` — captures formulas at the deferralClosure boundary where `F(chi) ∈ u`, `FF(chi) ∉ dc`
2. **`augmented_seed_consistent`** at `SuccChainFMCS.lean:1565-1588` already proves consistency of `seed ∪ boundary_resolution_set`
3. **Key lemma** `neg_not_in_g_content_when_F_in` at line 1480 confirms there is no g_content conflict when adding boundary formulas

**Critical Issue**: The current `boundary_resolution_set` requires `chi ∈ u` (the formula is already in the current world). This may be too restrictive — we need resolution even when `chi ∉ u` but `F(chi) ∈ u`. A relaxed version without the `chi ∈ u` condition needs a new consistency proof.

**However**: The `chi ∈ u` condition may actually be correct. If `chi ∉ u` and `F(chi) ∈ u`, then by f_step the disjunction `chi ∨ F(chi)` is in the successor seed. The question is whether `F(chi)` can persist indefinitely. With the modified seed, at each step either:
- `chi` enters the successor (done), or
- `F(chi)` persists but depth cannot increase (since `FF(chi) ∉ dc`)

The `chi ∈ u` version handles the case where chi IS already resolved in the current world but the F-obligation still needs to propagate to the successor — a subtler but legitimate concern.

### Alternative Approach: Algebraic Bypass (from Teammate B)

**Status**: Viable, comprehensive, higher effort

The algebraic infrastructure is 80% complete and **entirely sorry-free**:
- LindenbaumQuotient, BooleanStructure, InteriorOperators, UltrafilterMCS — all sorry-free
- ParametricCanonical, ParametricTruthLemma, ParametricHistory — all sorry-free
- **Single gap**: `construct_bfmcs` in ParametricRepresentation.lean

**Key Insight**: The algebraic approach avoids the deferralClosure boundary problem entirely because ultrafilters have **full negation completeness** by definition (for ANY element a, either a ∈ U or aᶜ ∈ U). This is exactly what the relational approach lacks.

**Path**: Define σ (temporal duality) on LindenbaumAlg → STSA instance → Jónsson-Tarski representation → wire `construct_bfmcs`. Estimated ~350 lines, ~8-10 hours.

## Synthesis

### Conflicts Resolved

**Conflict 1: Approach priority**
- Teammate A recommends seed modification as primary
- Teammate B recommends algebraic bypass as primary
- **Resolution**: These are not mutually exclusive. Seed modification fixes the *specific* broken lemma; algebraic bypass provides a *parallel* completeness path. Both should be pursued.

**Conflict 2: Is seed modification sufficient?**
- The task 53 report concluded the approach needs a relaxed `boundary_resolution_set` (without `chi ∈ u`)
- Teammate A found the existing version with `chi ∈ u` has its consistency already proven
- **Resolution**: The existing `chi ∈ u` version handles a subset of cases. The full fix may require either the relaxed version (new consistency proof needed) OR showing that the `chi ∈ u` version combined with f_step disjunction tracking is sufficient for eventual resolution.

### Gaps Identified

1. **Consistency of relaxed boundary_resolution_set**: If we remove the `chi ∈ u` condition, can we still prove the seed + boundary formulas is consistent? The `neg_not_in_*` lemmas are necessary but may not be sufficient.

2. **Interaction between approaches**: Could the algebraic `construct_bfmcs` be proven by first applying seed modification to get a sorry-free SuccChain construction, then wiring through? Or does the algebraic path need to be independent?

3. **Time allocation**: Which approach gets implemented first matters for the critical path.

### Recommendations

**Strategy: Pursue seed modification first, algebraic bypass in parallel**

**Phase 1 (Immediate, ~4-6 hours): Seed Modification**
1. Use the EXISTING `boundary_resolution_set` (with `chi ∈ u`) and `augmented_seed_consistent`
2. Modify `constrained_successor_restricted` to include `boundary_resolution_set` in the seed
3. Prove the boundary case of `restricted_single_step_forcing` using the forced resolution
4. If the `chi ∈ u` condition is insufficient, attempt the relaxed version
5. This directly eliminates the Class B sorries

**Phase 2 (Parallel, ~8-10 hours): Algebraic Bypass (Task 992)**
1. Elevate Task 992 from DEFERRED to HIGH PRIORITY
2. Define σ on LindenbaumAlg, prove STSA instance
3. Prove `construct_bfmcs` via ultrafilter extension
4. This provides an independent completeness path

**Why both**: If seed modification fully works, it's faster and stays within the existing architecture. If it hits the relaxed-consistency wall, the algebraic path is the clean fallback. Having both provides redundancy on the critical path.

**Phase 3 (After either succeeds): Wire Downstream**
- Eliminate `f_nesting_boundary` and `p_nesting_boundary` axioms
- Cascade sorry-removal through Bundle → Completeness → Representation

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Seed modification validation | completed | Medium-High |
| B | Algebraic bypass analysis | completed | High |

## Key Decision Point

The critical question for the next planning session:

> **Should Task 48 attempt seed modification first (lower effort, uncertain proof obligation) or pivot directly to the algebraic bypass (higher effort, higher confidence)?**

The recommendation is: attempt seed modification first with a **time-box of 4-6 hours**. If the consistency proof for the relaxed version cannot be completed, pivot to the algebraic approach.

## References

- `specs/052_task_review_and_roadmap_report/reports/01_comprehensive-review.md` — Repository health, sorry inventory, critical path
- `specs/053_direct_bounded_witness_induction/reports/01_bounded-witness-restructuring.md` — Option A detailed analysis
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:265-345` — Seed definitions
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:1467-1620` — Consistency proofs
- `Theories/Bimodal/Algebraic/*.lean` — Sorry-free algebraic infrastructure
- `specs/992_shift_closed_tense_s5_algebra/` — STSA design documents

# Phase 6 Handoff: Junction-Depth Infrastructure Added

**Session**: sess_1779003456_c5b522
**Date**: 2026-05-17
**Status**: Phase 6 remains BLOCKED

## What Was Done

Added 5 junction-depth helper lemmas to `TemporalClosure.lean`:

1. `junction_depth_S_zero_imp_U_free`: JD_S = 0 implies no untl subterms
2. `junction_depth_U_zero_imp_S_free`: JD_U = 0 implies no snce subterms
3. `s_free_junction_depth_zero`: S-free formulas have junction_depth = 0
4. `u_free_junction_depth_zero`: U-free formulas have junction_depth = 0
5. `snce_of_boxfree_sep_jd_le_one`: **KEY BOUND** -- `.snce phi' psi'` with box-normalized separated phi', psi' has junction_depth at most 1

## Key Findings

### Finding 1: junction_depth_zero does NOT imply syntactically_separated

Counterexample: `all_past (untl A B)` has junction_depth = 0 (since JD passes through all_past, and JD of untl with S-free atoms = 0) but is NOT syntactically separated (all_past requires U-free argument, but untl A B is not U-free).

This invalidates the "JD=0 base case is trivial" assumption from GHR94's setting. GHR94 treats G/H as derived from U/S, so they don't have primitive `all_past`/`all_future` constructors. In our formalization, these create additional non-separated JD=0 formulas.

### Finding 2: The JD bound IS useful

The fact that `.snce phi' psi'` (with separated phi', psi') has JD <= 1 means:
- The cross-nesting is at most 1 level deep
- Cases 1-4 handle single-level cross-nesting
- The remaining issue is Cases 5-8 (U in both event AND guard of S), which don't reduce JD within a single application

### Finding 3: The circularity is fundamental

The temporal closure axioms form a mutually recursive system:
- `snce_separable` needs Cases 1-8 (U out of S direction)
- Cases 5-8 currently use `all_separable` (which uses the axioms)
- `untl_separable` needs the dual direction (S out of U)
- Duality alone doesn't break the cycle (dual of Case 5 IS Case 5 dual, which needs `all_separable` for the other direction)

Resolution requires simultaneous mutual induction on both directions.

## What Remains for Axiom Elimination

### Required Infrastructure (~600-800 LOC total)

1. **`abstract_snce`** (~100 LOC): Dual of `abstract_untl`. Replace snce subformulas with fresh atoms. Needed for the S-elimination direction.

2. **Compound measure** (~50 LOC): Define `sep_measure phi = (junction_depth phi, count_U_subformulas phi + count_S_subformulas phi)` with lexicographic well-ordering.

3. **Mutual WF theorems** (~300-400 LOC):
   ```lean
   theorem no_S_nested_in_U_separable (phi : Formula) (h : no_S_nested_in_U phi) : is_separable phi
   theorem no_U_nested_in_S_separable (phi : Formula) (h : no_U_nested_in_S phi) : is_separable phi
   ```
   Each uses the other at strictly lower measure. The key:
   - `no_S_nested_in_U_separable` handles the case by abstracting U-subformulas, getting a U-free formula, then handling the U-free formula (which may need `no_U_nested_in_S_separable` for its `all_future(snce ...)` patterns)
   - The measure decreases because abstracting removes U-subformulas (second component decreases) while the dual call has junction_depth 0 (first component potentially different)

4. **Temporal closure derivation** (~50 LOC): Once the mutual theorems are proved, derive all 8 axioms as theorems.

5. **Integration** (~50 LOC): Replace axioms in SeparationThm.lean with theorem proofs.

### The Core Difficulty

The U-free base case of `no_S_nested_in_U_separable` (count_U = 0):
- Formula is U-free but may contain `all_future (snce ...)` patterns
- `all_future (snce p q)` has JD=0, no_S_nested_in_U=True, count_U=0
- To prove separable: swap_temporal gives `all_past (untl (swap p) (swap q))`
- This has count_U = 1, no_S_nested_in_U = True
- Apply the theorem at count_U = 1... but we're trying to prove the BASE case (count_U = 0)!
- This means count_U alone doesn't work as a simple induction measure
- Need the compound measure or mutual induction to handle this cross-case reference

### Recommended Next Steps

1. Start by implementing `abstract_snce` (mechanical, follows `abstract_untl` pattern)
2. Define `count_S_subformulas` (dual of existing `count_U_subformulas`)
3. Attempt the mutual WF proof using `WellFounded.fix` on the compound lexicographic measure
4. If the mutual WF approach is too complex for Lean's termination checker, consider using `decreasing_by` with explicit measure arguments

## File Locations

- Infrastructure: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean`
- Axioms to eliminate: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (lines 90-102, 223-239)
- Cases 5-8 using axioms: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` (lines 155-194)
- Duality infrastructure: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/Duality.lean`
- Hierarchy (single_U, multi_U): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

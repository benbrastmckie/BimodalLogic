# Research Report: Task #157 — GHR94-Faithful Axiom Elimination

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1779235690_e0393a

## Summary

Four research teammates conducted parallel investigation into why implementation agents keep diverging from GHR94 and what a faithful implementation requires. The team reached consensus on two critical findings: (1) the `has_single_U_type` preservation blocker is a **red herring** — GHR94's Lemma 10.2.7 does NOT require it, and (2) the real fix requires only ~90 LOC of new code centered on a single missing function: `extract_innermost_U_type`. The GHR94 Case 2 witness formula divergence (using `all_future(¬A)` instead of `¬U(A,B)`) is a legitimate correctness issue but does NOT block axiom elimination.

## Key Findings

### Finding 1: GHR94 Keeps ¬U(A,B) Unexpanded — Our Code Does Not (Teammates A, B, C)

GHR94 Case 2 (Lemma 10.2.3) output formula:
```
[S(a, q∧¬A) ∧ ¬A ∧ ¬U(A,B)] ∨ [¬A∧¬B∧S(a, ¬A∧q)] ∨ S(¬A∧¬B∧q∧S(a, ¬A∧q), q)
```

The first disjunct keeps `¬U(A,B)` **literally unexpanded**. In our Lean encoding, `¬U(A,B) = .imp (.untl A B) .bot` has exactly ONE `.untl` node with args `(A, B)`, so `has_single_U_type` is preserved.

Our code's `elim_case_2_gen` instead uses:
```
psi_l = S(a, q∧¬A) ∧ ¬A ∧ all_future(¬A)
```
where `all_future(¬A) = ¬U(A, ⊤)` introduces `.untl A .top` — a **new U-type** with second arg `⊤ ≠ B`. This breaks `has_single_U_type _ A B`.

**Confirmed by all three teammates**: `has_single_U_type (.imp (.untl A B) .bot) A B` holds (the predicate recurses through `.imp` and finds the single correct `.untl A B` node). The problem is purely in the witness formula construction, not in any fundamental encoding limitation.

### Finding 2: `has_single_U_type` Preservation Is a Red Herring (Teammate D)

The critical insight: **GHR94's Lemma 10.2.7 does NOT require `has_single_U_type`**. It only requires:
- `no_S_nested_in_U` (S-args have no S under U)
- `U_nesting_depth` strictly decreasing through the induction

The current code tries to thread `has_single_U_type` through the oracle chain via `subst_in_separated_separable_typed`. This is unnecessary. The existing `subst_in_separated_separable_depth` (already proven at line 2458 of Hierarchy.lean) threads `U_nesting_depth` decrease instead — and this is exactly what GHR94 uses.

### Finding 3: The Critical Missing Piece Is `extract_innermost_U_type` (Teammate D)

The entire oracle-free chain can be completed with ONE new function (~30 LOC):

**`extract_innermost_U_type`**: Given a formula with `no_S_nested_in_U` and `U_nesting_depth >= 2`, extract a U-type `U(A, B)` where A, B are **U-free** (an innermost U-node). This exists because at depth >= 2, some U-args contain other U-nodes, and following the chain down eventually reaches U-args that are U-free.

Once this function exists, the oracle in `no_S_nested_in_U_separable_direct_param` (10.2.7) at depth >= 2 can be replaced:
1. Extract innermost U-type `U(A, B)` with U-free args
2. Abstract it: `phi' = abstract_untl phi A B p`
3. Apply IH (inner `count_U_subformulas` induction) to `phi'`
4. Back-substitute using `subst_in_separated_separable_depth`
5. Callback receives formulas with `U_nesting_depth <= 1` → `lemma_10_2_6_self_contained_param` handles them
6. **No oracle needed**

### Finding 4: Phase C (Restructure 10.2.8) Is Optional (Teammate D)

Once 10.2.7 is oracle-free, `all_formulas_separable_aux` at n=1 can call `no_S_nested_in_U_separable_direct` (now oracle-free) directly. The GHR94 S-abstraction-from-U-args approach (Plan v22 Phase C) is architecturally correct but **not required** for axiom elimination.

### Finding 5: The Oracle Architecture Is The Wrong Abstraction (All Teammates)

GHR94's lemma hierarchy is strictly layered:
- 10.2.5 uses 10.2.4 only (self-contained)
- 10.2.6 uses 10.2.5 only
- 10.2.7 uses 10.2.6 only
- 10.2.8 uses 10.2.7 only

The oracle parameter (`∀ chi, no_S_nested_in_U chi → junction_depth chi ≤ 1 → is_separable chi`) threads a callback from 10.2.8 back into the chain, inverting GHR94's layering. At JD=1, this creates an identity roundtrip where the callback receives the original formula. **Making each layer self-contained (as GHR94 intended) eliminates the oracle entirely.**

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Whether to fix Case 2 witness vs bypass has_single_U_type | **Bypass first** (Teammate D). Fix Case 2 later for GHR94 faithfulness. The axiom elimination does NOT require has_single_U_type. |
| Whether Phase C is needed | **Not needed for axiom elimination** (Teammate D). Making 10.2.7 oracle-free suffices for 10.2.8's n=1 case. Phase C can be done later for architectural cleanliness. |
| LOC estimate (90 vs 310) | **~90 LOC** for the minimal oracle-free fix. Plan v22's 310 LOC estimate included Phase C restructuring, which is optional. |
| Whether the "encoding gap" (no G/H primitives) is real | **Real but not blocking** (all teammates). The gap causes `has_single_U_type` failure in Case 2 witnesses, but since has_single_U_type is not needed for the oracle-free path, the gap is irrelevant for axiom elimination. |

### Gaps Identified

1. **`extract_innermost_U_type` does not exist yet**: This is the critical missing function. ~30 LOC, structurally simple.

2. **`subst_in_separated_separable_depth` callback proof**: Need to verify that the callback formula from `subst_in_separated_separable_depth` has `U_nesting_depth <= 1` when the extracted U-type has U-free args. Teammate D claims `callback_U_nesting_depth_le_one` (line 2444) already proves this — needs verification.

3. **Case 2 witness fix is deferred**: For long-term GHR94 faithfulness, the Case 2 (and 4, 6, 8) witnesses should be changed to keep `¬U(A,B)` unexpanded. This requires a new backward equivalence lemma (~50-80 LOC, 60% confidence per Teammate C).

4. **10.2.5 oracle removal at depth >= 2**: Teammate D identifies that `single_U_formula_separable_noax_param` at depth >= 2 can replace the oracle call with a direct call to `lemma_10_2_6_self_contained_param`, since the formula has `no_S_nested_in_U` and `U_nesting_depth <= 1`. This is a ~5 LOC change.

### Recommendations

**Immediate plan (for next `/plan` and `/implement`):**

1. **Phase B (revised)**: Make 10.2.7 oracle-free (~60 LOC)
   - B.1: Create `extract_innermost_U_type` (~30 LOC)
   - B.2: Rewrite depth >= 2 case in `no_S_nested_in_U_separable_direct_param` to use `subst_in_separated_separable_depth` with callback to `lemma_10_2_6_self_contained_param` (~20 LOC)
   - B.3: Remove oracle parameter from `single_U_formula_separable_noax_param` at depth >= 2 (~5 LOC)

2. **Phase C (revised)**: Fix `all_formulas_separable_aux` n=1 case (~10 LOC)
   - Replace `no_S_nested_in_U_separable_direct` (axiom-backed) with `no_S_nested_in_U_separable_direct_param` (now oracle-free)

3. **Phase D**: Import reversal and axiom replacement (unchanged from plan v22)

4. **Phase E**: Final verification and cleanup (unchanged)

**Deferred (not needed for axiom elimination):**
- Fix Case 2, 4, 6, 8 witness formulas to keep `¬U(A,B)` unexpanded (GHR94 faithfulness)
- Full 10.2.8 restructure with GHR94 S-abstraction-from-U-args approach

**Total estimated LOC: ~90 new/changed + ~120 deleted = net ~30 lines smaller**

## Failure Mode Catalog (Teammate C)

Five recurring failure modes across 22 plan versions:

1. **Axiom leak via `all_separable`** (plans v1-v12): Fixing the axiom requires the theorem that depends on the axiom — circular.
2. **False claim that JD=1 callback has JD=0** (plans v13-v16, v21): The callback `.snce (.untl A B) q` has JD=1, not 0.
3. **Assumed U-nesting-depth bound** (plans v17-v20): Box-normalized separated formulas can have `U_nesting_depth > 1`.
4. **`has_single_U_type` approach for Cases 2/4/6/8** (plan v22): Works for Case 1 but fails at `all_future(¬A)`.
5. **Structural IH collapses to `snce_separable`** (plans v14-v16): The JD=1 case IS `snce_separable`.

**Pattern**: Each plan identifies one correct sub-problem but misses how other sub-problems block the proposed fix. The solution is to stop threading `has_single_U_type` and instead use `U_nesting_depth` decrease (via `extract_innermost_U_type`).

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | GHR94 proof structure, witness analysis | completed | high |
| B | Codebase inventory, axiom tracking | completed | very high |
| C | Critic: encoding gap challenge, failure modes | completed | high |
| D | Architecture: oracle-free path via innermost U-extraction | completed | high |

## References

- GHR94 Ch 10: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`
- Plan v22: `specs/157_expressive_completeness_su_integer/plans/22_ghr94-exact-plan.md`
- Phase B handoff: `specs/157_expressive_completeness_su_integer/handoffs/phase-B-analysis-20260519.md`
- Report 21: `specs/157_expressive_completeness_su_integer/reports/21_jd1-oracle-fix.md`
- Teammate A: `specs/157_expressive_completeness_su_integer/reports/23_teammate-a-findings.md`
- Teammate B: `specs/157_expressive_completeness_su_integer/reports/23_teammate-b-findings.md`
- Teammate C: `specs/157_expressive_completeness_su_integer/reports/23_teammate-c-findings.md`
- Teammate D: `specs/157_expressive_completeness_su_integer/reports/23_teammate-d-findings.md`

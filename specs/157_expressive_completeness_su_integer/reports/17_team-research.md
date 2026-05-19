# Research Report: Task #157

**Task**: Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1779212907_599a65
**Focus**: Phase 3 blocker — axiom-free implementation of GHR94 10.2.5-10.2.7

## Summary

The Phase 3 blocker is a circularity: the plan's Task 3.5 (`lemma_10_2_6_self_contained`) proposes using `single_U_formula_separable` as an axiom-free callback, but `single_U_formula_separable` itself calls `snce_separable` (the axiom being eliminated). The fix is to write a NEW `single_U_formula_separable_noax` using strong induction on `snce_depth_of_U` following GHR94 Lemma 10.2.5 literally. At the `.snce C F` case, the IH gives separated equivalents C' ≡ C and F' ≡ F; since separated + single-U-type implies `snce_depth_of_U = 0`, this reduces to Lemma 10.2.4 (Cases 1-8), which are all axiom-free. For depth ≥ 2, iterative single-U abstraction using the existing `abstract_untl` + `abstract_subst_roundtrip` avoids the need for a complex `abstract_inner_U` function.

## Key Findings

### 1. CRITICAL: Plan Task 3.5 Has a Circularity (Critic, verified by all)

**The dependency chain is circular:**
```
lemma_10_2_6_self_contained (proposed)
  → no_S_nested_in_U_separable_param (Hierarchy.lean:1634)
    → subst_in_separated_separable (Hierarchy.lean:1144)
      → callback at .snce case (line 1170)
        → single_U_formula_separable (Hierarchy.lean:170)
          → snce_separable (line 187) ← AXIOM!
```

`single_U_formula_separable` cannot serve as an axiom-free callback because it internally uses `snce_separable` at the `.snce` case. The plan must be revised to use a NEW axiom-free version.

**Fix**: Write `single_U_formula_separable_noax` using `snce_depth_of_U` strong induction (GHR94 10.2.5 literally), handling the `.snce` case via Cases 1-8 instead of `snce_separable`.

### 2. The Correct Approach: `snce_depth_of_U` Induction (Primary)

GHR94 10.2.5 proof by induction on k = max S-nesting above U(A,B):

- **k = 0**: Formula is already syntactically separated. Proved by existing `snce_depth_zero_single_U_separated` (Hierarchy.lean:1390). No axiom needed.

- **k > 0**: At `.snce C F` with `has_single_U_type` and depth k+1:
  1. C and F have `snce_depth_of_U < k+1`, so by IH they are separable
  2. Get separated C' ≡ C and F' ≡ F with `has_single_U_type C' A B`
  3. **Key lemma**: `is_syntactically_separated C' → has_single_U_type C' A B → snce_depth_of_U C' = 0`
     - Every `.snce` in C' has U-free args (from `is_syntactically_separated`)
     - So `snce_depth_of_U` at each `.snce` is 0, hence overall `snce_depth_of_U C' = 0`
  4. `.snce C' F'` has `snce_depth_of_U = 1` (depth 0 args under one `.snce`)
  5. Apply Lemma 10.2.4 (event-split + Cases 1-8) at depth 1 → separable

**Missing lemma needed**: `is_syntactically_separated_snce_depth_zero`: if a formula is syntactically separated, its `snce_depth_of_U = 0`. Straightforward by induction.

### 3. Cases 1-8 `_gen` Variants (Primary + Lean 4 Patterns)

Cases 1-8 are all axiom-free. The `_gen` variants relax requirements:

| Case | Standard | `_gen` variant | S-free a,q needed? |
|------|----------|----------------|---------------------|
| 1 | `elim_case_1` | `elim_case_1_gen` | No — only U-free |
| 2 | `elim_case_2` | `elim_case_2_gen` | No — only U-free |
| 3 | `elim_case_3` | Needs `_gen`? | **To verify** |
| 4 | `elim_case_4` | Needs `_gen`? | **To verify** |
| 5 | `case5_separable_Z` | `case5_separable_Z_gen` | No — only U-free |
| 6 | `case6_separable_Z` | Check | **To verify** |
| 7 | `case7_separable_Z` | Check | **To verify** |
| 8 | `case8_separable_Z` | Check | **To verify** |

After event-splitting, `a = replace_untl C' A B ⊤` is U-free (proved by `replace_untl_U_free`) but NOT necessarily S-free (C' can contain `.snce` nodes). If Cases 3, 4, 6, 7, 8 don't have `_gen` variants dropping S-free on a/q, new ones must be created.

### 4. Callback Properties Verified Correct (Critic)

When `U_nesting_depth phi ≤ 1`:
- **Callback has single U-type**: VERIFIED. c, d are U-free (from separated ψ). After substituting p → U(A,B) with U-free A, B, the only U in the result is exactly U(A,B).
- **Callback U_nesting_depth ≤ 1**: VERIFIED. U_nesting_depth of U(A,B) = 1 when A, B are U-free. Overall max is 1.

### 5. Depth ≥ 2: Iterative Single-U Abstraction (Lean 4 Patterns)

For `no_S_nested_in_U_separable_direct` at `U_nesting_depth ≥ 2`, use iterative single-U abstraction instead of the complex `abstract_inner_U`:

1. Find ONE inner `.untl X Y` nested inside a U-arg
2. Abstract it with existing `abstract_untl` (line 276)
3. Result has `U_nesting_depth` strictly less (by at least 1)
4. Apply IH at lower depth → separate
5. Back-substitute using existing `abstract_subst_roundtrip` (line 291)
6. Apply IH to impure parts

This reuses all existing infrastructure and avoids multi-substitution roundtrip proofs entirely.

### 6. All 9 Axioms on Critical Path (Horizons)

Even the "less important" axioms block downstream:
- `proper_separation_preserves_atoms` is used at ExpressiveCompleteness.lean:1925,1998
- `is_properly_separable` axioms feed into `proper_separation_theorem_int`
- Task 155 Phase 3B depends on sorry-free ExpressiveCompleteness

**No subset of axioms can be deferred.** All 9 must be eliminated for downstream unblocking.

### 7. First Mechanized Proof (Horizons)

No existing formalization of GHR94 separation exists in any proof assistant (Lean, Isabelle, Coq). This would be the first mechanized proof — potential ITP/CPP paper.

## Synthesis

### Conflicts Resolved

**Conflict**: Teammates A and B both identify the S-free requirement on Cases 3-4 as a potential blocker, but reach the same conclusion: either `_gen` variants exist already or must be created (estimated small effort since the semantic arguments likely don't depend on S-freeness of event/guard).

**Conflict**: The plan proposes `abstract_inner_U` as a complex function (Tasks 3.6-3.11, ~290 LOC), while Teammate B advocates iterative single-U abstraction using existing infrastructure. **Resolution**: The iterative approach is simpler and reuses proven code. `abstract_inner_U` is unnecessary if we abstract one inner U at a time and apply the IH at each step.

### Gaps Identified

1. **Missing lemma**: `is_syntactically_separated_snce_depth_zero` — needed to connect the IH (separated sub-formulas) to the depth-1 case of 10.2.4
2. **`_gen` variants**: Cases 3, 4, 6, 7, 8 need verification for whether S-free a/q is genuinely required
3. **`proper_separation_preserves_atoms`**: The hardest of the 9 axioms — requires atom-tracking through the entire separation procedure. Should be addressed in parallel, not deferred.

### Recommendations

1. **Revise plan Tasks 3.4-3.5** to use `single_U_formula_separable_noax` (new, axiom-free) instead of the existing `single_U_formula_separable`

2. **Replace plan Tasks 3.6-3.11** (`abstract_inner_U` complex) with iterative single-U abstraction using existing `abstract_untl` + `abstract_subst_roundtrip`. This collapses 6 tasks into ~2.

3. **New task list for Phase 3 (remaining)**:
   - Task 3.4: Prove `callback_has_single_U_type` (unchanged, ~50 LOC)
   - Task 3.4b: Prove `is_syntactically_separated_snce_depth_zero` (~20 LOC)
   - Task 3.5: Write `single_U_formula_separable_noax` using `snce_depth_of_U` induction (~120 LOC)
   - Task 3.5b: Verify/create `_gen` variants for Cases 3,4,6,7,8 if needed (~40-80 LOC)
   - Task 3.6: Prove `lemma_10_2_6_self_contained` using `single_U_formula_separable_noax` as callback (~60 LOC)
   - Task 3.7: Prove `no_S_nested_in_U_separable_direct` via `U_nesting_depth` strong induction, with iterative single-U abstraction for depth ≥ 2 (~100-160 LOC)

4. **Focus on Phases 3-5 only**. Phases 6-7 are cleanup and not on the critical path.

5. **Begin `proper_separation_preserves_atoms` investigation** alongside Phase 3 — this is on the critical path and is the hardest axiom.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary (GHR94 10.2.4/10.2.5 approach) | completed | medium-high |
| B | Lean 4 implementation patterns | completed | high (patterns), medium (.snce case) |
| C | Critic (circularity, claim verification) | completed | high |
| D | Horizons (strategic alignment) | completed | medium-high |

## References

- GHR94 Ch 10.2, Lemmas 10.2.3-10.2.8: Primary mathematical reference
- Hierarchy.lean lines 170-187: Current `single_U_formula_separable` with axiom dependency
- Hierarchy.lean lines 1281-1500: `snce_depth_of_U` and `U_nesting_depth` definitions + properties
- Hierarchy.lean lines 1634-1684: `no_S_nested_in_U_separable_param` callback structure
- Hierarchy.lean lines 1855-1960: `all_formulas_separable_aux` with axiom fallback at n=1
- SeparationThm.lean lines 89-283: The 9 axioms to eliminate
- NormalForm.lean lines 113-384: Axiom-free Cases 1-8 wrappers + `lemma_10_2_4`
- Eliminations.lean: Cases 1-4 with `_gen` variants
- DedekindZ.lean: Cases 5-8 with `_gen` variants

# Research Report: Task #157 -- GHR94 Lemma 10.2.8 Hierarchy Implementation Study

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-17
**Mode**: Team Research (4 teammates)
**Session**: sess_1779045605_6410ff
**Focus**: Rigorous study of the full GHR94 Lemma 10.2.8 hierarchy needed for axiom elimination

## Summary

Four teammates rigorously studied the GHR94 hierarchy with three major outcomes: (1) Teammate C REFUTED the prior claim that the snce case is trivial -- `no_S_nested_in_U(snce C F)` recurses, not U-free, making snce the HARD case; (2) Teammate D discovered that `is_S_free q` in `elim_case_1` is DEAD CODE -- the separation proof only uses `is_U_free q` -- enabling a generalized Case 1 that handles Cases 5-8 directly via Dedekind formula specialization (~380 LOC, no WF recursion); (3) Teammate B verified the nested `Nat.strongRecOn` pattern compiles in Lean 4 with a 2-component measure `(junction_depth, count_U_subformulas)` for the full hierarchy approach (~500-720 LOC). The Dedekind + generalized-Case-1 path is strongly recommended as the primary approach due to lower LOC, no termination checker issues, and Lean-verified intermediate steps.

## Key Findings

### 1. CRITICAL CORRECTION: snce Case Is NOT Trivial (Teammate C)

Prior reports (Report 04) claimed `no_S_nested_in_U(snce C F)` requires U-free args, making the snce case trivial. This is **FALSE**. Reading `Defs.lean` lines 320-328:

```lean
def no_S_nested_in_U : Formula -> Prop
  | .snce phi psi => no_S_nested_in_U phi ∧ no_S_nested_in_U psi  -- RECURSIVE
  | .untl phi psi => is_S_free phi = true ∧ is_S_free psi = true  -- S-free check is HERE
```

The snce case recurses -- it does NOT require U-free args. `snce (untl p q) r` satisfies `no_S_nested_in_U` but is NOT syntactically separated. The snce case IS the hard case, not the trivial one. All plans based on the "snce is trivial" claim need revision.

### 2. Dead Hypothesis Discovery: Generalized Case 1 Enables Cases 5-8 (Teammate D)

The `is_S_free q` hypothesis in `elim_case_1` (Eliminations.lean) is DEAD CODE -- the separation proof only uses `is_U_free q`. Teammate D verified this in Lean. A generalized Case 1 (dropping the S-free guard requirement) applies to `S(a ^ U(A,B), Q)` where Q is U-free (even if not S-free).

The Dedekind formula for Case 5 produces guard Q = B v NOT S(not q, not A) v A, which IS U-free. Combined with `neg_until_equiv`, this gives a direct proof path for all Cases 5-8 without `all_separable` or WF recursion.

K+/K- correction: Report 04 had a sign error. On Z with strict-U semantics, K+=K-=FALSE (not TRUE). Both conventions agree that Gamma+-=bot, so the Dedekind formula simplification is correct.

### 3. Full Hierarchy: 2-Component Measure Works (Teammate B)

For the full GHR94 10.2.8 approach, the measure is `(junction_depth, count_U_subformulas)` with `Prod.Lex Nat.lt Nat.lt`. Nested `Nat.strongRecOn` compiles in Lean 4 (verified). The third level (S-nesting) is internal to Lemma 10.2.4, not a top-level WF component.

### 4. abstract_snce Is Critical for Full Hierarchy (Teammate A)

The full hierarchy requires `abstract_snce` (~120 LOC, dual of `abstract_untl`) to extract S-subformulas from inside U arguments. This is what reduces junction_depth by at least 2 at each step.

### 5. Strengthened IH as Alternative (Teammate C)

Teammate C proposed proving a strengthened structural induction hypothesis:
```
IH: no_S_nested_in_U phi → (is_separable phi ∧ ∀ q, no_S_nested_in_U q → is_separable (snce phi q))
```
This would make the snce case trivial by the second conjunct. However, proving the second conjunct for all formula constructors may be as hard as the original problem.

## Two Approaches Compared

| Aspect | Dedekind + Gen-Case-1 | Full GHR94 10.2.8 |
|--------|----------------------|-------------------|
| LOC | ~380 | ~500-1180 |
| WF recursion | None | Nested Nat.strongRecOn |
| Lean termination | No issues | Needs decreasing_by proofs |
| Lean-verified steps | Multiple (Case 7, Q is U-free) | Nat.strongRecOn pattern only |
| abstract_snce needed | No | Yes (~120 LOC) |
| Risk | Medium (semantic equiv proofs) | High (3-level induction) |
| Generality | Specific to Z | General framework |

**Recommendation**: Dedekind + generalized-Case-1 as PRIMARY, full hierarchy as FALLBACK.

## Implementation Plan (Dedekind Path)

1. **Generalize Case 1** (~50 LOC): Remove dead `is_S_free q` hypothesis from `elim_case_1`. Also generalize Case 2 similarly.
2. **Prove Case 7** (~50 LOC, easiest): Two directly separated disjuncts for atoms. Verified in Lean.
3. **Prove Case 5** (~120 LOC): Dedekind formula with 3 disjuncts. D1 is Case 1 instance. D2 and D3 use generalized Case 1 with U-free guard Q.
4. **Prove Cases 6, 8** (~100 LOC): Case 6 reduces to Cases 2+5. Case 8 reduces via negation to Cases 5+2.
5. **Replace axioms** (~60 LOC): Wire Cases 5-8 into `single_U_formula_separable`, then `multi_U_formula_separable`, then `no_S_nested_in_U_separable`, then temporal closure theorems.

## Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| Teammate A says 3-component measure vs Teammate B says 2-component | Resolved: 2-component is correct for top-level WF; 3rd level is internal to Lemma 10.2.4 (Teammate B) |
| Prior reports say snce case is trivial vs Teammate C refutes | Resolved: Teammate C is correct -- snce recurses in no_S_nested_in_U (verified in code) |
| Report 04 says K+=K-=TRUE vs Teammate D says K+=K-=FALSE | Resolved: Different U-semantics conventions; both agree Gamma+-=bot, formulas simplify the same way |

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | Full hierarchy spec | completed | 8-step implementation order, ~720 LOC estimate |
| B | WF measure design | completed | 2-component measure, verified Lean compilation |
| C | Critic / validation | completed | REFUTED snce-trivial claim; proposed strengthened IH |
| D | Dedekind backup | completed | Dead hypothesis discovery; ~380 LOC direct path |

## References

- GHR94 Ch 10.2-10.3 (literature/)
- Defs.lean lines 320-328 (no_S_nested_in_U definition)
- Eliminations.lean (elim_case_1 dead hypothesis)
- Prior reports 04, 09, 10, handoffs

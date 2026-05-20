# Phase B Handoff: extract_innermost_U_type Blocker

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Phase**: B (Make Lemma 10.2.7 Oracle-Free)
**Status**: BLOCKED
**Session**: sess_1779238146_214c02
**Timestamp**: 2026-05-19

## Immediate Next Action

The next agent should NOT retry Phase B as planned. Instead, proceed directly to Phase C's combined theorem approach (`no_S_nested_sep_selfcontained`) which subsumes Phase B by merging 10.2.5/10.2.6/10.2.7 into a single well-founded induction. If Phase C also blocks (on the `count_U_subformulas` measure issue), the task requires a plan revision.

## Blocker Description

### The Core Issue

Plan v23's Phase B requires `extract_innermost_U_type` (a function that finds a `.untl A B` node with U-free args inside a formula at `U_nesting_depth >= 2`) combined with `subst_in_separated_separable_depth` (which needs U-free args) and an inner `count_U_subformulas` induction.

The blocker: `count_U_subformulas (.untl _ _) = 1` -- it does NOT recurse into `.untl` children. This means abstracting a `.untl A B` that is INSIDE another `.untl`'s args does NOT decrease `count_U_subformulas`. And at depth >= 2, `extract_innermost_U_type` ALWAYS enters `.untl` children (because the first surface `.untl a b` has non-U-free args at depth >= 2).

### Why `extract_U_type` Doesn't Help

`extract_U_type` finds a SURFACE `.untl` (never enters `.untl` children), so `contains_untl_surface` holds and `count_U_subformulas` decreases when abstracting. BUT at depth >= 2, `extract_U_type` returns args that may NOT be U-free, which prevents using `subst_in_separated_separable_depth`.

### Why `extract_innermost_U_type` Doesn't Help

`extract_innermost_U_type` finds a `.untl A B` with U-free args (enabling `_depth`), BUT the found pair is NOT on the surface at depth >= 2, so `count_U_subformulas` doesn't decrease when abstracting.

### The Fundamental Tension

At depth >= 2:
- Surface `.untl` (extract_U_type): count decreases BUT args not U-free
- Innermost `.untl` (extract_innermost_U_type): args U-free BUT count doesn't decrease

No single extraction strategy satisfies BOTH requirements simultaneously.

## Current State

- `Hierarchy.lean`: CLEAN (reverted all changes)
- Plan file: Phase B marked [BLOCKED] with detailed blocker documentation
- No code changes committed for Phase B

## Key Decisions Made

1. Identified that `count_U_subformulas` is flat at `.untl` (returns 1, no recursion into children)
2. Confirmed that `extract_innermost_U_type` at depth >= 2 ALWAYS enters `.untl` children
3. Confirmed that `abstract_untl_U_nesting_depth_le_of_le` only gives `<=`, not `<`, so outer IH can't substitute for inner count IH
4. Plan's prohibition #9 (no `subst_in_separated_separable_jd` at depth >= 2) prevents keeping current code

## Possible Resolutions (for plan revision)

1. **Define `count_U_total`** that recurses into ALL formula children (including `.untl` args), and prove `abstract_untl` decreases it. This requires new infrastructure but would make `extract_innermost_U_type` work.

2. **Skip Phase B entirely, go to Phase C** with the combined theorem `no_S_nested_sep_selfcontained` that merges 10.2.5/10.2.6/10.2.7 into one well-founded induction on `(U_nesting_depth, count_U_subformulas)` lexicographic. Phase B was designed as a stepping stone but may not be needed if Phase C works.

3. **Keep current code at depth >= 2** (use `extract_U_type` + `subst_in_separated_separable_jd` with oracle). This contradicts prohibition #9 but avoids the measure problem. The real oracle elimination would happen entirely in Phase C.

4. **Use `U_nesting_depth` strictly decreasing** for the inner IH at depth >= 2, by proving that abstracting an innermost `.untl` (the one on the maximum-depth path) STRICTLY reduces `U_nesting_depth`. This requires additional work to identify and prove which `.untl` to abstract.

## Files Analyzed

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (lines 1070-1112, 1196-1270, 2313-2351, 2458-2493, 2554-2651)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (lines 155-171, 365-371, 423-430)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` (lines 146-155)

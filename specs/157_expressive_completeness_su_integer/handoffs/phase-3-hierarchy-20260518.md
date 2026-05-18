# Phase 3 Handoff: Hierarchy Theorem

**Date**: 2026-05-18
**Session**: Phase 3 hierarchy implementation attempt
**Status**: BLOCKED

## What Was Accomplished

1. **Fixed pre-existing name collision**: Removed duplicate `u_free_s_free_is_separable` from Hierarchy.lean (also exists in Eliminations.lean:59).

2. **Proved 4 substitution preservation lemmas** (Hierarchy.lean, after line ~1072):
   - `subst_S_free_preserves_S_free`: Substituting S-free formula into S-free formula preserves S-freeness
   - `subst_U_free_preserves_U_free`: Dual for U-freeness
   - `subst_U_free_gives_no_S_nested`: Substituting `.untl A B` (S-free args) into U-free formula gives `no_S_nested_in_U`
   - `subst_preserves_no_allpast_allfuture`: Substitution preserves expanded-formula property

3. **Built framework**: `all_formulas_separable_aux` and `all_formulas_separable` (Hierarchy.lean end):
   - Compiles cleanly
   - `.atom`, `.bot`, `.box`, `.imp`, `.all_past`, `.all_future` cases handled correctly
   - `.untl` and `.snce` cases delegate to `all_separable` (axiom-dependent) -- this is the blocker

## The Core Problem

The `.untl` and `.snce` cases of `all_formulas_separable_aux` cannot be proved by structural induction because:

1. **Structural induction fails**: For `.snce a b`, we need `is_separable (.snce a b)`. By IH, `is_separable a` and `is_separable b`. But `snce_separable` (needed to compose these) IS one of the axioms we're trying to eliminate.

2. **Junction-depth induction alone fails**: For `.imp a b`, JD(a) may equal JD(φ), so the IH doesn't apply with JD alone.

3. **The abstraction roundtrip is circular**: `abstract_subst_roundtrip` gives `subst(abstract(φ), p, U(A,B)) = φ`. So abstracting U-types from `.snce C F`, separating, and substituting back gives the ORIGINAL `.snce C F` -- no progress.

## The GHR94 Solution (Not Yet Implemented)

GHR94's approach (Lemma 10.2.8) works differently:

1. Given `.snce D₁ D₂` with junction depth n+1
2. Abstract maximal S(E,F) from inside U-arguments → `.snce D₁' D₂'` has `no_S_nested_in_U`
3. Separate `.snce D₁' D₂'` by Lemma 10.2.7 → get separated form E'₁
4. Substitute S(E,F) back for atoms z_ij IN E'₁ (the separated form, NOT the original)
5. The result E₁ = subst(E'₁, [z→S(E,F)]) is NOT the original formula. It has the STRUCTURE of E'₁ with S(E,F) inserted.
6. Key claim: junction_depth(E₁) ≤ n (strictly less than original)
7. By IH on JD, E₁ is separable
8. Since E₁ ≡ .snce D₁ D₂, the original is separable

**Step 6 is the critical unproved claim.** It requires showing that substituting formulas of bounded JD into a separated form (JD ≤ 1) gives a formula of bounded JD.

## What Is Needed

### Option A: Prove `subst_jd_bound` (Estimated ~200 LOC)

```lean
theorem subst_in_separated_jd_bound (ψ : Formula) (p : Atom) (r : Formula)
    (hsep : is_syntactically_separated ψ = true)
    (hjd_ψ : junction_depth ψ ≤ 1) :
    junction_depth (subst_formula ψ p r) ≤ max 1 (junction_depth r + 1)
```

This would enable the JD induction to go through.

### Option B: Constituent substitution (Estimated ~400 LOC)

Define `subst_past_constituents` that substitutes only into the S-terms of a separated formula, leaving U-terms and atoms unchanged. Then:

```lean
theorem subst_past_separable (ψ : Formula) (p : Atom) (r : Formula)
    (hsep : is_syntactically_separated ψ = true)
    (hr_sep : is_separable r)
    (hr_sf : is_S_free r = true) :
    is_separable (subst_formula ψ p r)
```

This directly gives separability without bounding JD.

### Option C: Direct semantic argument (Estimated ~300 LOC)

Prove the temporal closure theorems directly using the semantic definitions, without the syntactic hierarchy. E.g., for `untl_separable`: if φ ≡ φ' and ψ ≡ ψ' (separated), show `.untl φ ψ` is separable by constructing a separated equivalent using the semantic content of φ' and ψ'.

## Immediate Next Action

Start with Option A (simplest): prove `subst_in_separated_jd_bound` by structural induction on ψ. The key cases:
- `.imp a b`: JD of subst = max(JD(subst a), JD(subst b)). By IH on a and b.
- `.untl a b`: a, b are S-free (separated). subst preserves S-freeness (already proved). So `.untl (subst a) (subst b)` has S-free args → JD = max(JD_U(subst a), JD_U(subst b)). Need to bound JD_U of the substituted form.
- `.snce a b`: a, b are U-free (separated). subst introduces U-terms. JD_S(subst a) ≤ 1 + max(JD(r), ...). Need careful analysis.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`: Removed duplicate, added 4 substitution lemmas, added framework theorems
- `specs/157_expressive_completeness_su_integer/plans/08_axiom-elimination-plan.md`: Updated Phase 3 status

## Pre-existing Issues

- DedekindZ.lean has pre-existing build errors (from prior session) involving `le_of_lt_of_le` (renamed in mathlib) and proof structure issues around lines 1434, 1510, 1530, 1576, 1602. These are masked by cached oleans and don't affect Hierarchy.lean compilation, but will need fixing for a clean from-scratch build.

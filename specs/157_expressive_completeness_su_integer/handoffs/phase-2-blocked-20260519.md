# Phase 2 Blocked: Oracle-Free `no_S_nested_sep`

## Current State

Phase 1 (measure infrastructure) is complete. The following have been added:
- `count_U_total` in Defs.lean
- `count_U_total_zero_iff_U_free` in Defs.lean
- `abstract_untl_count_total_le`, `abstract_untl_count_total_lt_of_contains_deep` in Hierarchy.lean
- `contains_untl_deep`, `contains_untl_surface_implies_deep` in Hierarchy.lean
- `s_free_implies_no_S_nested` in Hierarchy.lean
- `extract_innermost_U_type` with `_S_free`, `_U_free`, `_contains_deep` companions in Hierarchy.lean

A partial `no_S_nested_sep` theorem exists in Hierarchy.lean. The UND >= 2 case is COMPLETE and self-contained. The UND <= 1 case falls back to `no_S_nested_in_U_separable_direct` (which uses `all_separable` axiom).

## The Fundamental Obstacle

The proof architecture relies on abstracting U-types and substituting back into separated forms. The substitution callback produces formulas whose measures (`count_U_total`, `U_nesting_depth`) are determined by the SEPARATED FORM (an existential witness), not the original formula. Since `is_separable` is:

```lean
def is_separable (phi : Formula) : Prop :=
  exists psi : Formula, is_syntactically_separated psi = true /\ int_equiv phi psi
```

The witness `psi` is non-constructive. Its atom counts, nesting depth, and size are all unconstrained. This means callback formulas from `subst_in_separated_separable_*` have uncontrollable measures.

## Approaches Attempted

### 1. Double strong induction on (UND, count_U_total)

- UND >= 2: WORKS. Extract innermost U (U-free args), abstract (count_U_total decreases), IH, substitute back via `subst_in_separated_separable_depth`. Callback has UND <= 1 (by `callback_U_nesting_depth_le_one`). Outer IH at d' = 1 < d >= 2.
- UND <= 1: FAILS. After abstracting surface U (U-free + S-free args), count_U_total decreases for the abstracted formula. But callbacks from substitution have count_U_total determined by the separated form, not bounded by the original.

### 2. Using `subst_in_separated_separable_depth` at UND <= 1

Callbacks have UND <= 1 and `no_S_nested_in_U`. But count_U_total is unbounded by the original. Cannot apply inner IH.

### 3. Nesting `no_S_nested_in_U_separable_direct_param` two levels

Creates an infinite oracle chain. Each level calls `single_U_formula_separable_noax_param` which calls the oracle at `snce_depth_of_U >= 2`, producing formulas with `snce_depth_of_U <= 1`. Processing these with another `no_S_nested_in_U_separable_direct_param` can produce more oracle calls. No fixed depth of nesting terminates.

### 4. Using `snce_depth_zero_no_S_nested_separated` as leaf oracle

Only handles `snce_depth_of_U = 0` formulas (which ARE syntactically separated). Oracle formulas can have `snce_depth_of_U = 1`.

### 5. Triple induction (JD, UND, count_U_total)

Same fundamental issue. At JD = 1, UND <= 1, the callbacks have uncontrolled count_U_total.

## Possible Solutions (not yet attempted)

### A. Constructive separation

Replace the existential `is_separable` with a CONSTRUCTIVE separation function `separate : Formula -> Formula` that computes a specific separated form. Then `count_U_total (separate phi) <= count_U_total phi` (or similar bound) could be proved, making callback measures controllable.

**Effort**: Very high. Requires implementing the full GHR94 separation algorithm as a computable function.

### B. Fuel-based approach with well-founded fuel

Define a "fuel" measure that bounds the total oracle chain depth. The fuel decreases at each oracle call. The initial fuel is some function of the input formula.

**Challenge**: Finding the right fuel function. The oracle chain depth depends on the separated forms, which are non-constructive.

### C. Custom well-founded relation on the PROOF TREE

Instead of a measure on the FORMULA, define a well-founded relation on the sequence of formulas encountered during the proof. This captures the "one-hop termination" pattern: lemma_10_2_6 -> single_U -> oracle -> lemma_10_2_6 -> single_U -> leaf.

**Challenge**: Formalizing this in Lean's WF framework.

### D. Restructure `all_formulas_separable_aux` to avoid the n=1 oracle

Instead of a standalone `no_S_nested_sep`, modify `all_formulas_separable_aux` to handle the n=1 case INLINE by merging the JD induction with the UND/count inductions. The JD >= 2 IH provides the oracle.

**Challenge**: The merged proof would be very large and complex.

### E. Prove atom preservation constructively

Prove that the separation theorem preserves atoms: if phi is separable, then there exists a separated psi with `formula_atoms psi <= formula_atoms phi`. This would bound the number of fresh atoms in callbacks, potentially bounding count_U_total.

**Challenge**: This is currently an axiom (`proper_separation_preserves_atoms`). Proving it requires the same constructive separation procedure as approach A.

## Immediate Next Action

The most promising approach is probably (D): restructure `all_formulas_separable_aux` to handle n=1 inline. This avoids the need for a standalone `no_S_nested_sep` and uses the JD IH at n >= 2 as the oracle. The n=1 case would be handled by a count_U_total induction with the n=0 base case providing the leaf.

Alternatively, approach (C) with a custom well-founded relation might work but requires careful formal development.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` — Added `count_U_total`, `count_U_total_zero_iff_U_free`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` — Added Phase 1 infrastructure + partial `no_S_nested_sep` (UND >= 2 works, UND <= 1 falls back to axiom)

## Build Status

`lake build` succeeds with zero errors, zero sorries. The fallback at UND <= 1 uses `no_S_nested_in_U_separable_direct` (which depends on `all_separable` axiom), so the axiom chain is NOT broken.

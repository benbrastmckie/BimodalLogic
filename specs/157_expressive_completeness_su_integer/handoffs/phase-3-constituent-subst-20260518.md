# Phase 3 Handoff: Constituent Substitution Infrastructure

**Date**: 2026-05-18
**Session**: Phase 3 hierarchy implementation - constituent substitution
**Status**: PARTIAL PROGRESS (infrastructure proved, main theorem still delegates)

## What Was Accomplished

### New lemmas proved (no sorry, no axioms):

1. **`abstract_untl_count_lt_of_not_U_free`** (Hierarchy.lean ~L1193): Abstracting a U-type from a non-U-free formula strictly decreases `count_U_subformulas`. Structural induction on phi.

2. **`abstract_untl_preserves_no_allpast_allfuture`** (Hierarchy.lean ~L1229): Abstracting preserves the expanded property. Structural induction on phi.

3. **`subst_in_separated_separable`** (Hierarchy.lean ~L1262): THE CORE LEMMA. Given a syntactically separated formula psi, substituting `.untl A B` (S-free args) for atom p yields a separable formula, using a callback `ih_snce` for `.snce` and `.all_past` constituents where substitution breaks separation. Proved by structural induction on psi, covering all 8 Formula constructors:
   - `.atom`: if matches p, result is `.untl A B` (separated); else unchanged
   - `.bot`, `.box`: trivially separated
   - `.imp`: `imp_separable` + recursive IH
   - `.all_past`: U-free arg + substitution gives `no_S_nested_in_U` -> callback
   - `.all_future`: S-free arg + substitution preserves S-freeness -> still separated
   - `.untl`: S-free args + substitution preserves S-freeness -> still separated
   - `.snce`: U-free args + substitution gives `no_S_nested_in_U` -> callback

4. **`subst_formula_congr`** (Hierarchy.lean ~L1313): If int_equiv phi psi then int_equiv (subst phi p r) (subst psi p r). Uses `subst_correctness`.

5. **`extract_U_type`** + **`extract_U_type_S_free`** (Hierarchy.lean ~L1333-1375): Extracts a U-type (A, B) with S-free args from a non-U-free formula with `no_S_nested_in_U`.

### What Still Uses `all_separable` (axiom-dependent)

- `multi_U_formula_separable` (line ~854) -- existing, pre-dates this session
- `all_formulas_separable_aux` `.untl` case (line ~1409)
- `all_formulas_separable_aux` `.snce` case (line ~1415)

## Why the Main Theorem Is Not Yet Proved

### The Single-U-Type Problem

The `subst_in_separated_separable` + abstraction approach works for the MULTI-U case (when abstracting one U-type leaves > 0 U-types in the abstracted form). In this case:
- Abstract U(A,B) -> count strictly decreases
- IH gives separated witness psi
- Substitute back -> each `.snce` constituent has count_U < original
- IH handles constituents via `ih_snce` callback

But for the SINGLE-U case (all U-nodes are the same type U(A,B)):
- Abstracting ALL of them -> U-free formula -> count = 0
- Separated witness psi = the abstracted formula itself
- Substituting back -> ORIGINAL formula with SAME count
- IH does not apply (no decrease)

### GHR94's Solution (Not Yet Implemented)

GHR94 handles this via S-NESTING DEPTH induction (Lemma 10.2.5):
1. Find the INNERMOST `.snce C F` containing U(A,B)
2. Apply `lemma_10_2_4` to it (Cases 1-8)
3. Result has U(A,B) at a higher level (lower S-nesting depth)
4. Repeat until U(A,B) is at top level (no S above it)

This requires:
- Finding innermost `.snce` containing a specific U-type (~50 LOC)
- Applying `lemma_10_2_4` to a subterm and propagating equivalence (~100 LOC)
- Proving S-nesting depth strictly decreases (~50 LOC)
- Combining into `single_U_type_separable` without axioms (~100 LOC)

### The `.untl` Case

For `.untl a b` with non-S-free args:
- Need to abstract S-subformulas from inside U-args (dual of the `.snce` case)
- Use `abstract_snce` (dual of `abstract_untl`)
- Similar infrastructure exists but the substitution-back step needs a DUAL version of `subst_in_separated_separable` for `.snce E F` substitution

Alternatively, use swap_temporal duality to reduce to the `.snce` case.

## Immediate Next Action

Implement `single_U_type_separable_noax` by S-nesting depth induction:

```lean
theorem single_U_type_separable_noax (phi A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type phi A B)
    (hexp : has_no_allpast_allfuture phi = true) :
    is_separable phi
```

Key steps:
1. Define `S_nesting_of_U` as the maximum S-nesting depth of U(A,B) in phi
2. Prove `lemma_10_2_4` applied to innermost `.snce` reduces `S_nesting_of_U`
3. At S_nesting = 0: formula is a boolean combination of atoms and U(A,B) -> separated
4. At S_nesting > 0: apply `lemma_10_2_4` to innermost `.snce`, reduce, apply IH

Once `single_U_type_separable_noax` is proved:
- Multi-U case uses count_U induction + `subst_in_separated_separable`
- `.snce` case of `all_formulas_separable_aux` uses these
- `.untl` case uses dual reasoning or swap_temporal

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`:
  Added 5 new lemmas + 1 definition (all proved, no sorry, no new axioms)

## Key Decisions

1. `subst_in_separated_separable` does NOT require `has_no_allpast_allfuture` on psi, allowing the callback to handle `.all_past` and `.all_future` positions directly
2. The callback `ih_snce` takes `no_S_nested_in_U` as the only condition, not requiring `hexp`, making it composable with any IH that provides `no_S_nested_in_U`
3. `extract_U_type` uses Classical reasoning (noncomputable def with by-tactic) to extract a U-type from a non-U-free formula

## Pre-existing Issues

Same as prior handoff: DedekindZ.lean has pre-existing build errors masked by cached oleans.

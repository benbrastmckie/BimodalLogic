# Handoff: Phase 3 - lemma_2_7_seed_consistent

## Status: PARTIAL

## Summary

The core mathematical proof of `lemma_2_7_seed_consistent` (PointInsertion.lean:2774) is structurally complete. The BX5+BX7+BX13 chain (Burgess 2.7, p.372) has been fully implemented and type-checks. One sorry remains for the combinatorial "plumbing" that connects the chain to the finite-subset consistency argument.

## What Was Accomplished

### BX Chain (FULLY PROVED)
The `h_key` helper (inside the `suffices` block) proves: for any `b in B` with `b -> beta0`, any `gamma_hat in C` with `gamma_hat -> gamma0`, and any `alpha_list` subset of A, there exists an event formula with:
- `F(event) in A` (consistency witness)
- `event -> b` (B-elements recoverable)
- `event -> eta` (target event recoverable)
- `event -> untl(b, gamma_hat)` (Until formulas recoverable)
- `event -> snce(guard, alpha)` for each `alpha` (Since formulas recoverable)

where `guard = (b ∧ untl(b,gamma_hat)) ∧ (xi ∧ untl(xi,eta))`.

### Proof Steps Implemented
1. **Neg-until witness extraction** from `xi not in B` + BurgessR3Maximal (lines ~2800-2840)
2. **BX5 self-accumulation** on both `untl(b, gamma_hat)` and `untl(xi, eta)` (lines ~2940-2945)
3. **BX7 linear_until** three-way disjunction (line ~2950)
4. **D1/D2 elimination** using neg-until witness + left_mono + right_mono (lines ~2955-2995)
5. **BX13 iterated enrichment** on D3 with the alpha_list (lines ~3000-3015)
6. **BX10 F-extraction** and event property proofs (lines ~3015-3055)
7. **snce left_mono derivation** for snce(guard, alpha) -> snce(b∧chi_gen, alpha) (lines ~3040-3055)

### Convention Alignment Verified
- Our `untl(guard, event)` = Burgess `U(event, guard)` (args swapped)
- BX7 applied to `untl(b∧untl(b,gamma_hat), gamma_hat)` and `untl(xi∧untl(xi,eta), eta)`
- D1/D2 eliminated via `combine_imp_conj` giving `guard -> beta0∧xi`
- D3 event = `(b∧untl(b,gamma_hat))∧eta` correctly implies b, eta, untl(b,gamma_hat)

## What Remains (Single Sorry)

### Location
`PointInsertion.lean:2941` (inside the `suffices` block, before `h_key` proof)

### Nature of Work
This is **combinatorial plumbing**, not mathematical content. The task:
1. Extract B-guards, C-events, A-events from the finite list `L` (which is a subset of `lemma_2_7_seed`)
2. Build `b = list_conj(beta0 :: b_guards)` with `b in B` and `b -> beta0`
3. Build `gamma_hat = list_conj(gamma0 :: c_events)` with `gamma_hat in C` and `gamma_hat -> gamma0`
4. Build `alpha_list` with all elements in A
5. Call `h_key` to get the event
6. For each `phi in L`, show `[event] |- phi` by case analysis on seed membership:
   - `phi in B`: use `event -> b -> phi` (list_conj_implies_elem)
   - `phi = eta`: use `event -> eta` directly
   - `phi = untl(beta', gamma')`: use `event -> untl(b, gamma_hat)` then left_mono + right_mono
   - `phi = snce(beta', alpha')`: use `event -> snce(guard, alpha')` then snce_left_mono_deriv
   - `phi = snce(beta'∧xi, alpha')`: use `event -> snce(guard, alpha')` then snce_left_mono_deriv
7. Apply `derivation_from_implied` + `inconsistent_singleton_false` for contradiction

### Challenges
- Defining list extraction functions that satisfy Lean's decidability requirements
- Proving that extracted elements belong to B/C/A (requires case-splitting on seed membership for each formula in L)
- Handling the "formula in B" case for untl/snce (where the formula is in B but we still need its structural components to be in C/A)

### Recommended Approach
Define the extraction functions as `private noncomputable def` OUTSIDE the theorem (like the existing `collect_guards`, `d0_c_event_list`, `d0_a_event_list` for `burgess_D0_seed`). Then use them inside the proof with their property lemmas.

Alternatively, use the simpler approach: filter L into B-elements, untl-elements, snce-elements, and handle each group separately. The B-elements from L that are `untl(beta',gamma')` or `snce(beta',alpha')` with those formulas also being in B can be handled by including the formula itself in `b_list` (since it's in B, it can serve as its own B-guard).

## Build Status
- `lake build` passes with no errors
- The sorry at line 2941 is the ONLY non-pre-existing sorry in this function

## File
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

## Key Lines
- Theorem starts: ~2774
- Sorry location: ~2941
- h_key proof starts: ~2943
- h_key proof ends: ~3060

# Phase 3 Completion Handoff (v18 Tasks 3.7a-3.7c)

## Status: COMPLETED (with deviation on 3.7c)

## What was done

### Task 3.7a: Guard decomposition lemmas
- `single_U_and_conj_simplify_neg`: C ^ -U(A,B) <-> replace_untl(C,A,B,bot) ^ -U(A,B)
- `single_U_guard_cnf`: F <-> (q_pos v -U) ^ (U v q_neg), the 2-clause CNF
- `snce_conj_guard_distribute`: S(ev, G1 ^ G2) <-> S(ev, G1) ^ S(ev, G2) (re-export of since_distrib_and_right)

### Task 3.7b: snce_single_U_depth_one_separable (the leaf case)
- Proves .snce C F separable when C, F have snce_depth_of_U = 0 and has_single_U_type
- Fully axiom-free (no callbacks, no no_S_nested_in_U_separable_param)
- Strategy: event-split on U(A,B), simplify events via single_U_and_conj_simplify/neg, guard CNF + conjunction distribution, match to Cases 5-8 via _gen variants

### Task 3.7c: single_U_formula_separable_noax
- Strong induction on snce_depth_of_U via Nat.strongRecOn
- Depth-1 case: fully axiom-free via leaf case
- Depth >= 2: uses all_separable as temporary callback (deviation)

### Also added
- has_single_U_type_gives_no_S_nested: derives no_S_nested_in_U from has_single_U_type + S-free args
- replace_box_preserves_single_U_type: box-normalization preserves single-U-type
- Moved untl_congr / snce_congr earlier in file (before leaf case)

## Key deviation
Task 3.7c depth >= 2 case uses `all_separable` (SeparationThm axiom) as callback for no_S_nested_in_U_separable_param. Root cause: separated witnesses don't preserve has_single_U_type, and the callback formula from no_S_nested_in_U_separable_param for single-U-type is the original formula itself (roundtrip identity), creating circularity. Phase 5 will eliminate this by rewriting all_formulas_separable_aux to use single_U_formula_separable_noax at the JD=1 callback level where the callback formulas have snce_depth_of_U <= 1.

## Build status
Full `lake build` passes with zero errors, zero sorries in Hierarchy.lean.

## Next action
Phase 4: Prove lemma_10_2_6_self_contained (Task 4.1) and no_S_nested_in_U_separable_direct (Task 4.2).

## Files modified
- Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean

# Phase 6B Round 7 Handoff

## Date: 2026-05-18
## Session: sess_1779084016_ff70c0

## What Was Done

### D2.1 Proved Without all_separable (Key Breakthrough)

Proved `S(alpha, Q_Z)` separable in Case 5 without circularity. This was the hardest sub-case.

**Approach**: Replace U(A,B) with True in event formulas where U is only under boolean connectives.

**Infrastructure added to DedekindZ.lean**:
1. `replace_untl_with_top`: Syntactic replacement of `.untl A B` with `neg bot` (True)
2. `replace_id_of_U_free`: Identity on U-free formulas
3. `untl_under_bool_only`: Predicate ensuring U(A,B) appears only under `.imp` (boolean)
4. `u_free_untl_under_bool`: U-free formulas satisfy `untl_under_bool_only`
5. `replace_U_free_of_bool`: Replacement produces U-free result
6. `replace_correct_bool`: Correctness theorem (truth preservation when U holds)
7. `case1_psi_bool_only`: case1_psi satisfies `untl_under_bool_only`
8. `snce_event_congr_with_U`: S-event equivalence when U holds at event points
9. `snce_combined_U_separable`: S(combined ∧ U, guard) separable via replace + Case 1

**Infrastructure added to Eliminations.lean**:
1. Made `case1_psi` public
2. `case1_psi_properties`: Non-existential equivalence + separation (duplicated proof body from elim_case_1_gen)

**Proof chain for D2.1**:
- alpha ↔ (a ∨ (¬q ∧ S(a∧U,q))) ∧ U [case3_alpha_aU_factor]
- Distribute: S(FACTORED ∧ U, Q_Z) ↔ S(a∧U, Q_Z) ∨ S((¬q∧S(a∧U,q))∧U, Q_Z)
- First disjunct: snce_combined_U_separable with combined=a (U-free)
- Second disjunct: Replace S(a∧U,q) with case1_psi σ, then:
  - ¬q∧σ satisfies untl_under_bool_only (σ has U only under boolean connectives)
  - snce_combined_U_separable with combined=¬q∧σ

## What Remains

### all_separable Uses (4 remaining, was 5)

1. **D3** (Case 5): `S(A ∧ (q∨U) ∧ S(alpha, Q_Z), q)` -- event contains S(alpha, Q_Z) which has U in alpha. Even after replacing S(alpha, Q_Z) with its separated equiv τ, τ may contain `.untl A B` under `.all_future` in the separated formula, preventing `untl_under_bool_only`. Requires tracking the exact structure of τ through the construction chain.

2. **Case 6**: `S(a∧¬U, q∨U)` -- uses `neg_until_equiv` to expand ¬U, introduces second U-type U(¬A∧¬B, ¬A). Requires Lemma 10.2.6 (multiple U-types).

3. **Case 7**: `S(a∧U, q∨¬U)` -- ¬U in guard. Expands to second U-type. Same as Case 6.

4. **Case 8**: `S(a∧¬U, q∨¬U)` -- ¬U in both. Same as Cases 6-7.

### Key Obstacles

- **D3**: The separated equivalent τ of S(alpha, Q_Z) is built from multiple levels of case1_psi composition. Its `.untl A B` may appear under `.all_future` in the separated formula, which breaks `untl_under_bool_only`. Need to either:
  (a) Track that the specific separated equivalents never use `.all_future`/`.all_past` (true for case1_psi, but requires threading through the composition), or
  (b) Find a different decomposition for D3.

- **Cases 6-8**: Require handling multiple U-types (Lemma 10.2.6). The `neg_until_equiv` expansion introduces U(¬A∧¬B, ¬A) alongside U(A,B). The full hierarchy theorem (junction_depth_separable) would handle this, but it's circular (needs snce_separable).

### Possible Next Steps

1. **D3 via tracking**: Show that the separated equivalent of S(alpha, Q_Z) produced by the Case 1 + snce_combined_U_separable chain uses only case1_psi-derived formulas which have no `.all_future`/`.all_past`. This would allow `untl_under_bool_only` to hold for the event.

2. **D3 via replace_untl_with_bot**: Define a `replace_untl_with_bot` function (replace U with False) for the ¬U branch of event-split. Combined with `replace_untl_with_top` for the U branch, both branches become Case 1 or Case 2.

3. **Cases 6-8 via explicit construction**: Instead of going through case3_equiv, directly construct separated equivalents for Cases 6-8 using the neg_until_equiv expansion + Cases 1-5. This avoids the multiple U-type issue but requires careful formula construction.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean`: Made case1_psi public, added case1_psi_properties
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean`: Added ~200 LOC of replace_untl infrastructure, rewrote Case 5 D2.1 proof

## Build Status

- `lake build`: passes (1647 jobs)
- 0 sorries in DedekindZ.lean
- 4 all_separable uses in DedekindZ.lean (D3, Cases 6-8)
- 9 axioms in SeparationThm.lean (unchanged)

# Phase 6B Round 8 Handoff

## Date: 2026-05-18
## Session: sess_1779084016_ff70c0

## What Was Done

### D3 (Case 5) Eliminated -- all_separable removed

**Approach**: Constructed explicit `d21_sep` formula (separated equivalent of S(alpha, Q_Z) from D2.1) and proved:
1. `d21_sep_equiv`: int_equiv with S(alpha, Q_Z) (non-existential)
2. `d21_sep_bool_only`: satisfies untl_under_bool_only for (A,B)

D3 proof: Replace S(alpha, Q_Z) in D3's event with d21_sep via snce_event_congr. Event-split on U(A,B). Each branch uses snce_combined_U_separable / snce_combined_notU_separable.

### replace_untl_with_bot Infrastructure Added

Dual of replace_untl_with_top for ¬U cases:
- `replace_untl_with_bot`: syntactic replacement of .untl A B with .bot
- `replace_bot_id_of_U_free`, `replace_bot_U_free_of_bool`, `replace_correct_bot`
- `snce_event_congr_with_notU`, `snce_combined_notU_separable`

### Case 8 Eliminated -- all_separable removed

**Approach**: GHR94 10.3.11.8 simplified for Z (K⁻=⊥, Γ⁺=⊥):
```
S(a∧¬U, q∨¬U) ↔ S(a∧¬U, ⊤) ∧ ¬S(¬q∧U, ¬a∨U)
```

- S(a∧¬U, ⊤): Case 2 (guard ⊤ is U-free)
- S(¬q∧U, ¬a∨U): Case 5 (event has U, guard has U)
- Boolean closure: and_separable + neg_separable

Forward direction: trichotomy contradiction (3 sub-cases).
Backward direction: greatest witness via Int.exists_greatest_below.

### case5_separable_Z_gen Created

Generalized Case 5 that drops S-free requirements on a and q. Only A and B need S-freeness. Original case5_separable_Z delegates to it.

## What Remains

### Cases 6 and 7 (2 all_separable uses)

Both cases hit the **multi-U-type barrier**:

**Case 6**: S(a∧¬U, q∨U). After neg_until_equiv expansion: ¬U ↔ G(¬A) ∨ U(A',B') where A'=¬A∧¬B, B'=¬A. The S-formula S(a∧U', q∨U) has TWO different U-types: U(A',B') in event and U(A,B) in guard.

**Case 7**: S(a∧U, q∨¬U). After neg_until_equiv expansion: ¬U ↔ G(¬A) ∨ U'. The guard q∨¬U = q∨G(¬A)∨U' has U' in it.

**Root cause**: The current `untl_under_bool_only` predicate requires ALL .untl nodes to be either the specific (A,B) or U-free. When a formula has .untl A' B' (from neg_until_equiv), it fails. The `replace_untl_with_top` machinery can only handle ONE specific .untl type at a time.

### Analysis of U' → ¬U

Key insight: U(A',B') → ¬U(A,B) (from neg_until_equiv). This means:
- In Case 6's decomposition via case3_equiv: alpha'∧U = (¬q∧S(a∧U',q))∧U (since U'∧U = ⊥)
- alpha'∧¬U = a∧U' (since U' → ¬U makes ¬U redundant)

The ¬U branch is clean: S(a∧U', Q_Z) is Case 1 for U' → separable.
The U branch is the problem: S((¬q∧S(a∧U',q))∧U, Q_Z) has S(a∧U',q) with U' inside S.

### Possible Approaches for Next Round

1. **Multi-U snce_combined**: Generalize snce_combined_U_separable to handle S(combined ∧ U₁ ∧ U₂, guard) where combined is U-free. Requires simultaneous replacement of both .untl types.

2. **Semantic Case 6 equivalence**: Prove S(a∧¬U, q∨U) ↔ S(a∧¬U, q) ∨ S(S(a∧¬U,q)∧U, q∨U). First disjunct is Case 2. Second is S(σ∧U, q∨U) where σ separable but not U-free. Then distribute σ = psi_l ∨ psi1, get S(psi_l∧U, q∨U) ∨ S(psi1∧U, q∨U). psi_l is U-free → Case 5 via case5_separable_Z_gen. psi1 has U' under boolean → need multi-U.

3. **Semantic Case 7 equivalence**: Use neg_until_equiv on guard's ¬U to get q∨G(¬A)∨U'. Then case3_equiv for U' gives D1 = S(a∧U, q∨G(¬A)) = Case 1 for U(A,B). D2/D3 need multi-U.

4. **Generalized untl_under_bool_only**: Allow .untl nodes with DIFFERENT (A',B') parameters when they don't contain .untl A B in their arguments. Define `no_untl_AB` predicate and modify replacement correctness.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean`

## Build Status

- `lake build`: passes (1647 jobs)
- 0 sorries
- 0 vacuous definitions
- 9 axioms in SeparationThm.lean (unchanged)
- 2 all_separable uses remain (Cases 6, 7 in DedekindZ.lean)

# Phase 6B Round 6 Handoff: Case 5-8 Decomposition Approach

## Status: IN PROGRESS -- Mathematical Breakthrough + Partial Implementation

## Session
sess_1779084016_ff70c0

## Summary

Round 6 identified a concrete, non-circular approach to proving Cases 5-8 without `all_separable`. The approach was partially implemented for Case 5. Two sorries remain in Case 5; Cases 6-8 have not been started.

## Mathematical Breakthrough

### Core Insight: alpha implies U

For Case 5: S(a∧U(A,B), q∨U(A,B)) with propositional a, q, A, B.

After applying `case3_equiv_Z_general`, the RHS is `case3_rhs(a∧U, q, A, B)` which has three disjuncts. The key component is S(alpha, Q_Z) where:

```
alpha = case3_alpha(a∧U, q, A, B) 
      = (a∧U) ∨ ((¬q ∧ S(a∧U, q)) ∧ (q∨U))
```

**Lemma**: alpha implies U(A,B).
- Case (a∧U): U holds trivially.
- Case (¬q ∧ S(a∧U, q)) ∧ (q∨U): since ¬q holds, (q∨U) requires U. So U holds.

**Therefore**: alpha ↔ (a ∨ (¬q ∧ S(a∧U, q))) ∧ U (factor out U).

### From alpha to Case 1

1. S(a∧U, q) is int_equiv to case1_psi(a,q,A,B) by `elim_case_1`.
2. case1_psi has U(A,B) only in one disjunct: the `B∧U` part of `(S(a,q)∧S(a,B)∧B∧U) ∨ (A∧S(a,B)∧S(a,q)) ∨ S(...)`.
3. After substituting case1_psi for S(a∧U, q) in `(a ∨ (¬q ∧ S(a∧U,q))) ∧ U`:
   - `¬q ∧ case1_psi ∧ U` = `(¬q∧S(a,q)∧S(a,B)∧B∧U) ∨ (¬q∧A∧S(a,B)∧S(a,q)∧U) ∨ (¬q∧S(...)∧U)`
   - Factor U: = `(¬q∧S(a,q)∧S(a,B)∧B ∨ ¬q∧A∧S(a,B)∧S(a,q) ∨ ¬q∧S(...)) ∧ U`
   - Define COMBINED_UF = a ∨ (all the U-free parts from above)
4. COMBINED_UF is U-free because:
   - a is U-free (hypothesis)
   - S(a,q), S(a,B) have U-free args → U-free
   - A, B, q are U-free (hypotheses)
   - S(A∧q∧S(a,B)∧S(a,q), q) has U-free event and guard → U-free
5. S(COMBINED_UF ∧ U, Q_Z) is Case 1: U-free event (COMBINED_UF) with U(A,B), U-free guard (Q_Z).
6. `elim_case_1_gen COMBINED_UF Q_Z A B` gives separability.

### Q_Z is U-free

Q_Z(A,B,¬q) = B ∨ A ∨ ¬S(¬q, ¬A). With propositional A, B, q: all components U-free. Proved by `Q_Z_U_free`.

### Implementation Status

**Completed**:
- D1 (first disjunct): S(a∧U, q) → Case 1 → separable ✓
- D2 second factor (A ∨ B∧U): separable by boolean closure of propositional + separated ✓
- Made `u_free_s_free_imp_separated` public in Eliminations.lean ✓
- Added `u_free_s_free_is_separable` helper ✓

**Remaining sorries**:
1. **D2 first factor**: S(alpha, Q_Z) → separable. Need to:
   a. Prove alpha implies U (semantic lemma on case3_alpha)
   b. Construct alpha_uf ↔ (a ∨ (¬q ∧ case1_psi)) using snce_congr
   c. Show alpha ↔ alpha_uf ∧ U
   d. Apply S(alpha_uf ∧ U, Q_Z) ↔ S(COMBINED_UF ∧ U, Q_Z) where COMBINED_UF is U-free
   e. Apply elim_case_1_gen to get separability
   f. Chain all int_equivs via is_separable_of_equiv

2. **D3**: S(A ∧ (q∨U) ∧ S(alpha, Q_Z), q). The event has:
   - A (propositional)
   - q∨U 
   - S(alpha, Q_Z)
   Guard is q (U-free).
   
   Approach: Use the same alpha-implies-U trick. S(alpha, Q_Z) is int_equiv to S(COMBINED_UF∧U, Q_Z) (Case 1, separable → has separated equiv ψ₂). Then the event becomes A ∧ (q∨U) ∧ ψ₂. This has single-U-type. Event-split on U:
   - A∧U∧ψ₂: needs further analysis (ψ₂ might have U)
   - A∧¬U∧ψ₂∧(q∨U)∧¬U = A∧¬U∧ψ₂∧q: event is U-free if ψ₂ is replaced by equivalent
   
   Actually this approach for D3 requires showing that the event, after replacing S(alpha, Q_Z) with its separated equivalent, becomes amenable to Case 1/2.

### For Cases 6-8

**Case 6**: S(a∧¬U, q∨U). Apply case3_equiv_Z_general: event is a∧¬U. alpha' = (a∧¬U) ∨ ((¬q ∧ S(a∧¬U, q)) ∧ (q∨U)). This alpha' does NOT imply U (the first disjunct has ¬U). So the approach differs.

However, S(a∧¬U, q) is Case 2, directly separable by elim_case_2_gen. For alpha': the (¬q ∧ (q∨U)) part simplifies to (¬q∧U). So alpha' = (a∧¬U) ∨ (¬q ∧ S(a∧¬U,q) ∧ U). 

Event-split S(alpha', Q_Z) on U:
- S(alpha'∧U, Q_Z): alpha'∧U = (a∧¬U∧U) ∨ (¬q∧S(a∧¬U,q)∧U) = (¬q∧S(a∧¬U,q))∧U. Since S(a∧¬U,q) is Case 2 (separable, U-free separated equiv), (¬q∧ψ₂)∧U where ψ₂ is U-free → Case 1.
- S(alpha'∧¬U, Q_Z): alpha'∧¬U = a∧¬U. Since a is propositional: U-free event. Case 2 form? Actually S(a∧¬U, Q_Z) where a is U-free and Q_Z is U-free → not quite Case 2 (Case 2 needs ¬U in event). Actually this is just S(a_uf, Q_Z) where a_uf = a∧¬U(A,B). The ¬U is `.imp (.untl A B) .bot` which has `.untl` → NOT U-free! So event is not U-free.

Hmm, ¬U = Formula.neg (.untl A B) = .imp (.untl A B) .bot. This contains `.untl`. So a∧¬U is NOT U-free.

This means S(a∧¬U, Q_Z) cannot use Case 1 (needs U-free event). But it CAN use Case 2:
S(a∧¬U, Q_Z) where we view the event as a_uf∧¬U with a_uf = a (U-free) and guard = Q_Z (U-free). This is exactly `elim_case_2_gen a Q_Z A B`.

Wait: `elim_case_2_gen` is: S(a∧¬U(A,B), q). So S(a∧¬U, Q_Z) = elim_case_2_gen a Q_Z A B. Need a U-free (✓), Q_Z U-free (✓), A S-free (✓), B S-free (✓). This works!

So Case 6 is handleable:
- D1: S(a∧¬U, q) → Case 2 ✓
- D2.S: S(alpha', Q_Z) → event-split:
  - S(alpha'∧U, Q_Z): alpha'∧U = (¬q∧case2_psi)∧U → Case 1 (after replacing S(a∧¬U,q) with case2_psi) ✓
  - S(alpha'∧¬U, Q_Z): = S(a∧¬U, Q_Z) → Case 2 ✓
  Combined by or_separable.

**Cases 7-8**: Guard has ¬U instead of U. case3_equiv_Z_general does NOT directly apply (it handles q∨U in guard, not q∨¬U).

Options:
a. Prove a dual of case3_equiv_Z_general for q∨¬U in guard.
b. Use neg_until_equiv to replace ¬U with G(¬A) ∨ U(¬A∧¬B, ¬A), then apply case3_equiv_Z_general. But this introduces multiple U-types.
c. Use elim_case_4 (already proved for S(a, q∨¬U) with U-free a). Then event-split gives Case 7 = S(a∧U, q∨¬U) → event-split → S(a_uf∧U, q∨¬U) (Case 7 with U in event only) which... hmm, but elim_case_4 needs U-free a. With event a∧U: not U-free.

Actually, elim_case_3 handles S(a, q∨U) and elim_case_4 handles S(a, q∨¬U), BOTH with U-free a. The generalized versions (case3_equiv_Z_general) allow arbitrary event a.

Is there a case4_equiv_Z_general? Let me check.

**Key TODO**: Check if DedekindZ.lean or Eliminations.lean has an equivalent of case3_equiv_Z_general for q∨¬U in guard. If not, prove it (or use neg_until_equiv + case3_equiv_Z_general).

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean`: Made `u_free_s_free_imp_separated` public, added `u_free_s_free_is_separable`.
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean`: Partial proof of case5_separable_Z (2 sorries remain).

## Build Status
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ` builds with 1 sorry warning (case5_separable_Z)
- Full `lake build` not tested since DedekindZ change.

## Next Steps (Priority Order)

1. **Prove the alpha-implies-U lemma** for case3_alpha(a∧U, q, A, B). This is a semantic lemma: `∀ M t, int_truth M t (case3_alpha (Formula.and a (.untl A B)) q A B) → int_truth M t (.untl A B)`.

2. **Construct the int_equiv chain** from S(alpha, Q_Z) to S(COMBINED_UF ∧ U, Q_Z) using snce_congr + the alpha-implies-U lemma.

3. **Show COMBINED_UF is U-free** and Q_Z is U-free, then apply elim_case_1_gen.

4. **Handle D3** similarly (event has A∧(q∨U)∧S(alpha,Q_Z), guard is q).

5. **Prove Cases 6, 7, 8** using the same framework.

6. **Once Cases 5-8 are proved**: The dependency chain becomes non-circular:
   - Cases 1-4: already proved without axioms
   - Cases 5-8: proved without all_separable (this work)
   - single_U_formula_separable: uses Cases 1-8 + snce_separable → but snce_separable is an axiom
   
   Wait, single_U_formula_separable still uses snce_separable for the .snce case! The Cases 5-8 decomposition only handles the SPECIFIC case of S(a∧±U, q∨±U) with propositional params.
   
   For single_U_formula_separable, the .snce case has C, F with single-U-type. By IH, C and F are separable (get separated C', F'). Then .snce C' F' needs to be shown separable.
   
   After box-normalization: C'', F'' separated, box-free. .snce C'' F'' has no_S_nested_in_U and JD ≤ 1.
   
   At JD = 0: separated.
   At JD = 1: C'' and F'' have .untl A B (propositional A, B by the self-containment argument). 
   
   Need: .snce C'' F'' separable. C'' and F'' are separated formulas with single-U-type at S-nesting 0.
   
   By event/guard splitting on U(A,B) and boolean decomposition, .snce C'' F'' decomposes into boolean combinations of Cases 1-8 instances with propositional params. All separable!
   
   The event/guard splitting uses since_event_split and guard_lem_equiv. The boolean decomposition of separated C'', F'' into "U-free parts ∧ ±U" is needed.
   
   **THIS IS THE KEY REMAINING STEP**: Prove that .snce C'' F'' (with separated C'', F'' having single-U-type at S-nesting 0 and propositional A, B) is separable via event/guard decomposition into Cases 1-8.

## Critical Mathematical Facts

1. For single-U-type U(A,B): A and B must be U-free (self-containment argument - if A contained .untl A B, then A contains itself as proper subterm, violating well-foundedness).

2. alpha = case3_alpha(a∧U, q, A, B) semantically implies U(A,B).

3. case3_rhs has no_S_nested_in_U when a, q, A, B are propositional.

4. The decomposition S(alpha, Q_Z) → event-split → Case 1 works because:
   - alpha∧¬U is semantically False
   - alpha∧U = COMBINED_UF ∧ U with U-free COMBINED_UF
   - Q_Z is U-free

5. `u_free_s_free_imp_separated` is now public in Eliminations.lean.

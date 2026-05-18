# Case 6 Implementation Handoff

Session: sess_1779084016_ff70c0
Date: 2026-05-18
Status: PARTIAL (D1, D2 of Branch B done; D3 has two `sorry`)

## What Was Done

### Infrastructure Added to DedekindZ.lean

1. **`untl_neguntl_contradictory`** (line ~1133): U(A,B) and U(negA^negB, negA) cannot hold simultaneously. Proved via trichotomy on witnesses.

2. **`neg_untl_event_equiv`** (line ~1152): Splits `a ^ negU` into `(a ^ G(negA)) v (a ^ U')` using `neg_until_equiv`.

3. **`U'_implies_notU`** (line ~1200): One-line corollary of the contradiction lemma.

4. **`case1_psi_uf_part`** (line ~1208): Defines the U-free part of `case1_psi a q (negA^negB) (negA)` -- disjuncts D2 and D3 that don't contain U'.

5. **`case1_psi_uf_part_U_free`**: Proves the U-free part is indeed U-free.

6. **`case1_psi_reduces_when_U`** (line ~1225): When U(A,B) holds, `case1_psi a q (negA^negB) (negA)` reduces to `case1_psi_uf_part` because the D1 disjunct (which has U') vanishes (U and U' are contradictory).

7. **`snce_Ufree_event_qU_guard_separable`** (line ~1176): Proves `S(ev, q v U)` separable when `ev` is U-free. This handles Branch A completely. Uses case3_equiv_Z_general internally with a d21-sep style explicit formula.

8. **`case6_branchA_separable`**: Wrapper that calls snce_Ufree_event_qU_guard_separable.

9. **`case6_branchB_separable`** (line ~1437): Partial -- D1 and D2 proved, D3 has sorry.

10. **`case6_separable_Z`** (line ~1621): Splits negU into G(negA) v U', delegates to Branch A and Branch B.

### Approach for Case 6

Top-level: `S(a ^ negU, q v U)` where a,q,A,B are U-free and S-free.

1. Split negU via neg_until_equiv: `negU <-> G(negA) v U'` where `U' = U(negA^negB, negA)`.
2. `since_distrib_or_left`: `S(a^G(negA), qvU) v S(a^U', qvU)`
3. Branch A: `S(a^G(negA), qvU)` -- event is U-free. DONE (snce_Ufree_event_qU_guard_separable).
4. Branch B: `S(a^U', qvU)` -- two U-types. Uses case3_equiv_Z_general.

Branch B decomposition:
- D1 = `S(a^U', q)`: Case 1 for U'. DONE.
- D2 = `S(alpha_B, Q_Z) ^ (A v B^U)`: DONE.
  - alpha_B distributed into `S(a^U', Q_Z) v S((negq^S(a^U',q))^U, Q_Z)`
  - First: Case 1 for U'. Second: when U holds, S(a^U',q) -> sigma1_uf (U-free) by case1_psi_reduces_when_U. snce_combined_U_separable.
- D3 = `S(A ^ (qvU) ^ S(alpha_B, Q_Z), q)`: TWO SORRY REMAIN.

## D3 Completion Strategy

D3 has event `A ^ (qvU) ^ S(alpha_B, Q_Z)` with guard `q`.

S(alpha_B, Q_Z) has explicit separated equiv:
```
sigma_B = case1_psi(a, Q_Z, negA^negB, negA)  -- has U' under booleans
        v case1_psi(negq ^ sigma1_uf, Q_Z, A, B)  -- has U(A,B) under booleans
```

Replace S(alpha_B, Q_Z) -> sigma_B in event (using snce_event_congr + d21-equiv).

Then event-split on U(A,B):

### U-branch: S(A ^ sigma_B ^ U, q)
When U holds at event point:
- sigma_B reduces: psi1's D1 (with U') vanishes -> psi1 -> psi1_uf
- So sigma_B -> psi1_uf v psi2. psi1_uf is U-free, psi2 has U under booleans.
- Combined A ^ (psi1_uf v psi2) satisfies untl_under_bool_only for (A,B).
- snce_combined_U_separable -> separable.

### negU-branch: S(A ^ (qvU) ^ sigma_B ^ negU, q)
Event-split on U':

#### negU ^ U' sub-branch:
- U' holds, negU holds (consistent since U' -> negU).
- sigma_B reduces: psi2's D1 (with U) vanishes -> psi2 -> psi2_uf
- Combined has U' only -> untl_under_bool_only for (negA^negB, negA)
- snce_combined_U_separable for U' type -> separable.

#### negU ^ negU' sub-branch:
- Both negU and negU' hold. sigma_B fully reduces to U-free part.
- (qvU) with negU -> q.
- Event is fully U-free (after congruence reductions).
- Use snce_combined_notU_separable parameterized for U' type.
- After replacing U' -> bot: negU' becomes neg(bot) = True. Event is U-free.
- The S-formula with U-free event and U-free guard is syntactically separated.
- separable.

### Implementation estimate
Each sub-case requires:
1. A `snce_event_congr_with_U` or similar congruence lemma (~20 lines each)
2. An `untl_under_bool_only` proof (~10 lines each)
3. Calling snce_combined_U/notU_separable (~5 lines each)

Plus the d21-style explicit equiv for sigma_B (~80 lines similar to d21_sep_equiv).

Total: ~200-300 lines for D3.

## Key Insight
U(A,B) and U(negA^negB, negA) are CONTRADICTORY. This means at any given time, at most one holds. Event-splitting on both U-types gives 3 non-empty sub-cases (U only, U' only, neither), each of which has at most one U-type and is handled by existing infrastructure.

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- Case 6 infrastructure (~300 new lines, 2 sorry in D3)

## Next Action
Fill in D3 of case6_branchB_separable following the strategy above. Build the d21-style equiv for sigma_B, then handle the three sub-cases of the double event-split.

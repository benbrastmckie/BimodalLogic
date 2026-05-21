# Discrete Equivalence Check: Do U' Definitions Coincide on Z?

## Executive Summary

**The two definitions of U'(A,B) are NOT equivalent on discrete linear orders.** The GHR93 FO table is ALWAYS FALSE on discrete orders (a structural property of the formula), while "cofinal AND NOT U" can be TRUE on discrete orders. However, this non-equivalence has a specific, limited impact on existing sorry-free proofs. The details follow.

## The Two Definitions

**Definition 1 (current Lean, "cofinal AND NOT U")**:
```
stavi_U_truth M atomMap t A B :=
  (forall s > t, exists r, t < r /\ r <= s /\ B(r))  -- B cofinal above t
  /\ not (exists s > t, A(s) /\ forall r in (t,s), B(r))  -- NOT U(A,B)(t)
```

**Definition 2 (GHR93 FO table, p. 95)**:
```
U'(p,q)(t) = exists s > t.
  [forall u in (t,s).
    ([exists v > u. forall w in (t,v). q(w)]
     \/
     [forall v in (u,s). p(v) /\ exists v' in (t,u). not q(v')])]
  /\ exists u in (t,s). not q(u)
  /\ exists u in (t,s). forall v in (t,u). q(v)
```

## Test Cases on Z (Integers)

### Test Case 1: t = 0, A = top, B = "x is even"

**Cofinal AND NOT U**:
- B cofinal: YES (B(1) = false, but B(2) = true so for s=1, r=1 fails... wait, B(1) is even? 1 is odd. B(1) = false. For s=1, we need r in (0,1] = {1} with B(r). B(1) = false. Cofinal FAILS.)

Correction: Cofinal requires for ALL s > 0, exists r in (0,s] with B(r). For s=1: (0,1] = {1}, B(1) = false. FAILS.

Result: **FALSE** (cofinal fails).

**FO table**: Conjunct 3 requires exists u in (0,s) with q on (0,u). For u=1: (0,1) = empty, vacuous. But Conjunct 1 at u=1: first disjunct needs v > 1 with q on (0,v). v=2: (0,2) = {1}, q(1) = false. FAILS. Second disjunct: exists v' in (0,1) = empty. FALSE. Conjunct 1 fails.

Result: **FALSE**.

Both agree: FALSE.

### Test Case 2: t = 0, A = top, B = "x <= 5"

**Cofinal AND NOT U**: B cofinal? For s = 100: need r in (0,100] with B(r). r=1, B(1)=true. For s=1: r=1, B(1)=true. YES. But U(top,B)(0): take s=1, top(1) true, (0,1) = empty. U = TRUE. NOT U = FALSE.

Result: **FALSE**.

**FO table**: Similar analysis, FALSE (q(6) = false creates a breakdown at u = 6 for first disjunct, and the second disjunct fails due to empty not-q set before u=6).

Result: **FALSE**.

Both agree: FALSE.

### Test Case 3: t = 0, A = top, B = any predicate

**Cofinal AND NOT U**: U(top,B)(0): take s = 1. top(1) = true. (0,1) = empty. U = TRUE. NOT U = FALSE.

Result: **FALSE** for any B when A = top.

**FO table**: See the general proof below.

Result: **FALSE** for any B, any A.

Both agree when A = top.

### Test Case 4 (KEY COUNTEREXAMPLE): t = 0, A = "x = 5", B = "x != 3"

**Cofinal AND NOT U**:
- B cofinal: B(1) = true (1 != 3). For any s >= 1, r = 1 in (0,s] with B(1) = true. YES.
- U(A,B)(0): exists s > 0 with A(s) and B on (0,s). Only candidate s = 5. (0,5) = {1,2,3,4}. B(3) = false. FAILS. No other A-witness. U = FALSE. NOT U = TRUE.

Result: TRUE AND TRUE = **TRUE**.

**FO table**: Need s > 0 with all three conjuncts.
- Conjunct 3: u = 1, (0,1) = empty. s >= 2.
- Conjunct 2: u = 3 (not-q point). s >= 4.
- Conjunct 1: For ANY s, at u = 3:
  - Disjunct 1: exists v > 3 with q on (0,v). Since q(3) = false and 3 in (0,v) for all v > 3: FAILS.
  - Disjunct 2: needs exists v' in (0,3) = {1,2} with not-q(v'). q(1) = true, q(2) = true. FAILS.
  
  Conjunct 1 always fails at u = 3.

Result: **FALSE**.

**THE TWO DEFINITIONS DISAGREE**: "cofinal AND NOT U" gives TRUE, FO table gives FALSE.

## General Proof: GHR93 FO Table is ALWAYS FALSE on Z

**Theorem.** For any predicates p, q and any point t in Z, the GHR93 FO table for U'(p,q)(t) evaluates to FALSE.

**Proof.** Suppose for contradiction that U'(p,q)(t) holds. Then there exists s > t satisfying all three conjuncts.

Conjunct 2 gives us some u0 in (t,s) with not-q(u0). Let u0 be the SMALLEST such point (well-founded on Z). Since u0 is the first not-q point, q holds on all of {t+1, ..., u0-1}.

Now evaluate Conjunct 1 at this u0:

**Disjunct 1**: exists v > u0 with q on (t,v). For any v > u0, we have u0 in (t,v) (since t < u0 < v). But q(u0) = false. Contradiction.

**Disjunct 2**: [forall v in (u0,s). p(v)] AND [exists v' in (t,u0) with not-q(v')]. The second conjunct requires some v' in {t+1,...,u0-1} with not-q(v'). But by minimality of u0, q holds on all of {t+1,...,u0-1}. If u0 = t+1, then (t,u0) = empty, so exists is false. If u0 > t+1, then all points in (t,u0) satisfy q. Either way, the second conjunct is FALSE.

Both disjuncts fail at u0. Conjunct 1 is violated. Contradiction. QED.

**Key insight**: The proof uses the well-ordering of Z (every nonempty subset of integers above t has a minimum). The first not-q point u0 cannot satisfy either disjunct because:
- Disjunct 1 needs q to hold beyond u0, but u0 itself witnesses not-q.
- Disjunct 2 needs a not-q witness BEFORE u0, contradicting minimality.

## General Proof: "Cofinal AND NOT U" is NOT Always False on Z

**Counterexample.** Let t = 0, A(x) = (x = 5), B(x) = (x != 3).

- Cofinal: B(1) = true, so for every s > 0, the point 1 in (0,s] witnesses B. YES.
- NOT U(A,B)(0): The only s with A(s) is s = 5. For this s, (0,5) = {1,2,3,4} and B(3) = false. So U fails. NOT U = TRUE.

Result: TRUE. QED.

More generally, "cofinal AND NOT U" is TRUE at t whenever:
1. B(t+1) = true (equivalent to cofinality on discrete orders), AND
2. For every s > t with A(s), B fails at some point in (t,s).

This can be achieved when A is "rare" and B "usually holds but has a gap between t and each A-witness."

## What "Gap" Means on Z

On Z, there are NO Dedekind gaps. This is proved as `discrete_no_gaps` in EFGames.lean (line 551). The proof uses `IsSuccArchimedean`: given a in cut and b not in cut with a < b, the succ chain from a reaches b while staying in the cut (by `gap_cut_succ_closed`), contradicting b not in cut.

Since no gaps exist on Z, the gap-based definition of U' is trivially FALSE on Z (there is no gap to witness). The GHR93 FO table is the first-order encoding of this gap-based concept, so it is also always FALSE on Z (as proved above).

The "cofinal AND NOT U" definition is NOT the first-order encoding of the gap concept. It is a different condition that happens to be sometimes true on Z, which makes it STRICTLY WEAKER than the intended U' semantics on discrete orders (the intended semantics is "always false" on discrete orders, while "cofinal AND NOT U" is "sometimes true").

Wait -- correction on the direction. The gap-based definition is a WEAKER condition than "cofinal AND NOT U" in general (as shown by the Q counterexample in report 16 where gap-based is TRUE but cofinal-AND-NOT-U is FALSE). But on discrete orders, both should be always false (since there are no gaps), and it turns out cofinal-AND-NOT-U is NOT always false on discrete orders while the FO table IS always false. So on discrete orders, the FO table (always false) is strictly STRONGER in the "false" direction -- actually, let me state this more carefully:

- GHR93 FO table on Z: ALWAYS FALSE (for all A, B, t).
- "Cofinal AND NOT U" on Z: SOMETIMES TRUE (for some A, B, t).

The set of (A, B, t) satisfying the FO table on Z is EMPTY.
The set satisfying "cofinal AND NOT U" on Z is NONEMPTY.

So the FO table is strictly stronger (more restrictive) on Z: FO-table => cofinal-AND-NOT-U is vacuously true, but cofinal-AND-NOT-U does NOT imply FO-table.

## Existing `stavi_U_discrete_equiv` Analysis

The theorem at StaviConnectives.lean line 362:

```lean
theorem stavi_U_discrete_equiv ...
    stavi_U_truth M atomMap t A B <->
    temporal_truth M atomMap t (Formula.untl B Formula.bot) /\
    not temporal_truth M atomMap t (Formula.untl A B)
```

This is a TAUTOLOGICAL equivalence. It rewrites the "cofinal" condition as `U(B, bot)` (which equals B(succ(t)) on discrete orders) and keeps the NOT U(A,B) condition as-is. It says:

"cofinal AND NOT U" <-> "U(B,bot) AND NOT U(A,B)"

This is correct as a theorem (both sides define the same thing). But it does NOT establish equivalence with the GHR93 definition. The theorem name is misleading: it suggests a "discrete equivalence" for U', but it only proves that the Lean's incorrect definition can be rephrased using U operators.

## Existing `flatten_stavi_correct` Analysis

The theorem at StaviConnectives.lean line 459:

```lean
theorem flatten_stavi_correct ...
    stavi_temporal_truth M atomMap t sf <->
    temporal_truth M atomMap t (flatten_stavi sf)
```

This proves that `flatten_stavi` preserves the LEAN definition of stavi_temporal_truth. Since both `stavi_temporal_truth` and `flatten_stavi` use the "cofinal AND NOT U" characterization for the stavi_untl case, this is a self-consistent theorem. It does NOT prove that the flattened formula captures the GHR93 semantics of U'.

However, on discrete orders, if we were to fix U' to the correct (always-false) semantics, then `flatten_stavi_correct` would need to prove:

`stavi_temporal_truth M atomMap t (stavi_untl A B) <-> FALSE`

which would require `flatten_stavi (stavi_untl A B)` to also be always false. Currently, `flatten_stavi (stavi_untl A B) = U(flatten B, bot) AND NOT U(flatten A, flatten B)`, which is NOT always false (as shown by the counterexample).

## Impact on Existing Sorry-Free Proofs

### Theorems in StaviConnectives.lean (ALL sorry-free)

| Theorem | Status | Impact |
|---------|--------|--------|
| `cofinal_above_iff_succ` | Correct | Pure order theory, no U' involvement |
| `cofinal_below_iff_pred` | Correct | Pure order theory, no U' involvement |
| `until_bot_iff_succ` | Correct | Pure temporal_truth, no U' involvement |
| `since_bot_iff_pred` | Correct | Pure temporal_truth, no U' involvement |
| `stavi_U_discrete_equiv` | Tautological | Correctly relates Lean's U' def to U operators, but the def is wrong |
| `stavi_S_discrete_equiv` | Tautological | Same issue |
| `temporal_truth_neg` | Correct | Pure Formula operations |
| `temporal_truth_and` | Correct | Pure Formula operations |
| `flatten_stavi_correct` | Self-consistent but semantically wrong | Proves flatten preserves wrong definition |

### Theorems in EFGames.lean

| Theorem | Status | Impact |
|---------|--------|--------|
| `discrete_no_gaps` | Correct | Pure order theory |
| `gap_cut_succ_closed` | Correct | Pure order theory |
| Cases I and II (ExpressivenessGeneral.lean) | Sorry-free | Use `stavi_temporal_truth_mu` for rank_type agreement; self-consistent with whatever U' definition is in place |
| `left_formula_gap_detection` | Sorry'd | Needs correct U' definition to be provable |
| `right_formula_gap_detection` | Sorry'd | Same |
| Cases III-IV | Sorry'd | Depend on Lemma 9 |
| `stavi_expressive_completeness` | Sorry'd | The end goal |

### Key Conclusion on Existing Work

**Cases I and II of Theorem 6 are NOT directly invalidated.** Here is why:

1. Cases I and II prove game-strategy transfer lemmas. They work with rank_type agreement, which is defined in terms of `stavi_temporal_truth_mu`.

2. The rank_type computation uses whatever definition of `stavi_temporal_truth_mu` is in place. Changing the U' definition changes WHICH formulas are in the rank_type, but the strategy transfer proofs work for ANY consistent definition.

3. The proofs of Cases I and II never directly evaluate a `stavi_untl` or `stavi_snce` formula -- they work abstractly with rank_type sets.

4. However, the END GOAL (stavi_expressive_completeness) requires rank_types to capture the correct FO-definable properties. With the wrong U' definition, rank_types would capture a different (incorrect) notion of expressiveness.

**`flatten_stavi_correct` would need to be REPROVED** after fixing the U' definition:
- With the correct (always-false-on-discrete) semantics, the stavi_untl case becomes trivial: `FALSE <-> temporal_truth t (flatten_stavi (stavi_untl A B))` where the RHS should also be FALSE.
- But the CURRENT `flatten_stavi` maps stavi_untl to `U(B,bot) AND NOT U(A,B)`, which is NOT always false.
- So `flatten_stavi` itself would need to change (map stavi_untl to `bot` on discrete orders), and then the proof would need updating.

## Conclusion

1. **The two definitions are NOT equivalent on discrete orders.** The GHR93 FO table is always FALSE on Z; "cofinal AND NOT U" can be TRUE on Z.

2. **The correct behavior on discrete orders is "always false"** because there are no Dedekind gaps in Z, and U' detects gaps. The "cofinal AND NOT U" definition is semantically incorrect even on discrete orders.

3. **Cases I and II of Theorem 6 survive the fix** as self-consistent game-strategy proofs. They would need no changes -- only the final composition connecting game strategies to FO expressiveness would use the updated definition.

4. **`flatten_stavi_correct` must be redone.** Both `flatten_stavi` and `stavi_temporal_truth` need updating. On discrete orders, the fix is straightforward: U'(A,B) becomes `False` (or equivalently, `bot`), making `flatten_stavi (stavi_untl A B) = bot`.

5. **`stavi_U_discrete_equiv` becomes trivial.** After the fix, U'(A,B) is always false on discrete orders, so the equivalence is `False <-> False`.

6. **For the GENERAL (non-discrete) case**, the U' definition needs the gap-based semantics from the GHR93 FO table. This is needed for Cases III-IV and Lemma 9.

## Recommended Fix Strategy

### Phase 1: Fix the Definition (general orders)

Replace `stavi_U_truth` with the GHR93 FO table formula, or equivalently, with the gap-based second-order definition. The `stavi_temporal_truth_mu` version should quantify over gaps in the extended carrier.

### Phase 2: Prove Always-False on Discrete Orders

Prove `stavi_U_truth M atomMap t A B -> False` for discrete orders, using the same argument as the general proof above (minimality of first not-q point leads to contradiction).

### Phase 3: Update flatten_stavi

On discrete orders, `flatten_stavi (stavi_untl A B)` should become `bot` (since U' is always false). Update `flatten_stavi_correct` accordingly (the stavi_untl case becomes `False <-> temporal_truth t bot = False`).

### Phase 4: Verify Cases I-II Unchanged

Confirm that Cases I and II proofs compile unchanged (they should, since they work abstractly with rank_types).

### Phase 5: Prove Lemma 9 with Correct Definition

With the corrected U' semantics, `left_formula_gap_detection` should become provable (as GHR93 claims: "Clear").

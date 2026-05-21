# Stavi U'/S' Semantics Fix: Full Ripple Impact Assessment

## Executive Summary

The current Lean definitions of U'(A,B) and S'(A,B) use "cofinal AND NOT U" / "cofinal AND NOT S", which is NOT equivalent to the correct GHR93 gap-based definition. This report traces every definition and theorem that depends on these semantics and classifies each as BREAKS, SAFE, or UNCERTAIN.

**Critical finding**: The two definitions are NOT equivalent even in discrete linear orders. A concrete counterexample on Z shows "cofinal AND NOT U" can be true when the gap-based U' is always false. This means `flatten_stavi_correct` will break, and `flatten_stavi` itself needs revision.

**Good news**: The damage is more contained than feared. Most sorry-free infrastructure (Cases I, II, Lemma 10, Lemma 11 forward, game structure) is parametric in U' semantics and survives unchanged. The already-sorry'd theorems (Lemma 9, Cases III-IV, Lemma 11 backward) are the ones that need the fix to become provable.

---

## 1. Definitions Affected

### 1.1 `stavi_U_truth` -- StaviConnectives.lean:67-76

**Status**: MUST CHANGE

Current definition:
```
stavi_U_truth M atomMap t A B :=
  (forall s > t, exists r, t < r AND r <= s AND B(r))   -- B cofinal
  AND NOT (exists s > t, A(s) AND forall r in (t,s), B(r))  -- NOT U(A,B)
```

This standalone definition is used only in `stavi_U_discrete_equiv` (line 362). Changing it affects only that theorem.

### 1.2 `stavi_S_truth` -- StaviConnectives.lean:89-98

**Status**: MUST CHANGE (dual of 1.1)

Used only in `stavi_S_discrete_equiv` (line 384).

### 1.3 `stavi_temporal_truth` (.stavi_untl case) -- StaviConnectives.lean:134-140

**Status**: MUST CHANGE

This is the recursive evaluation of U'(A,B) for StaviFormulas on the base structure M. Current definition uses "B cofinal AND NOT U(A,B)" with recursive stavi_temporal_truth calls.

**Used by** (directly, via pattern-match on stavi_untl):
- `flatten_stavi_correct` (line 459) -- the stavi_untl case
- `stavi_truth_mu_at_point` (EFGames.lean:1446) -- bridges mu to non-mu
- `gap_definable_on_left` (EFGames.lean:306) -- uses `stavi_temporal_truth M atomMap u D`
- `gap_definable_on_right` (EFGames.lean:320) -- ditto
- `gap_detection_unique` (EFGames.lean:1547) -- uses `stavi_temporal_truth M atomMap u D`
- `stavi_n_equiv` (EFGames.lean:199) -- uses `stavi_temporal_truth M atomMap t A`

### 1.4 `stavi_temporal_truth` (.stavi_snce case) -- StaviConnectives.lean:141-147

**Status**: MUST CHANGE (dual of 1.3)

### 1.5 `stavi_temporal_truth_mu` (.stavi_untl case) -- EFGames.lean:808-816

**Status**: MUST CHANGE

Current definition (mu-relativized):
```
(forall s > t, mu_holds s -> exists u, t < u AND u <= s AND mu_holds u AND B^mu(u))
AND NOT (exists s > t, mu_holds s AND A^mu(s) AND forall u in (t,s), mu_holds u -> B^mu(u))
```

This is the mu-relativized "cofinal AND NOT U" pattern, restricting quantifiers to mu-points.

**Used by** (directly unfolded at stavi_untl):
- `rank_embed_stavi_truth_mu` (EFGames.lean:986) -- stavi_untl case
- `stavi_truth_mu_at_point` (EFGames.lean:1446) -- stavi_untl case
- All downstream through `rank_type`, `formula_agreement`, `ghr93_winning_condition`

### 1.6 `stavi_temporal_truth_mu` (.stavi_snce case) -- EFGames.lean:817-825

**Status**: MUST CHANGE (dual of 1.5)

### 1.7 `flatten_stavi` (.stavi_untl case) -- StaviConnectives.lean:415-418

**Status**: MUST CHANGE

Current: maps `stavi_untl A B` to `U(flatten(B), bot) AND NOT U(flatten(A), flatten(B))`

This is correct ONLY for "cofinal AND NOT U". With the gap-based definition where U' is always false in discrete orders, the correct flattening would be `Formula.bot`. However, `flatten_stavi` is also used inside `left_formula` / `right_formula` for the S/S' cases, where the flattened formula needs specific structure (not just `bot`). See Section 5 for analysis.

### 1.8 `flatten_stavi` (.stavi_snce case) -- StaviConnectives.lean:419-422

**Status**: MUST CHANGE (dual of 1.7)

---

## 2. Theorems That BREAK

### 2.1 `flatten_stavi_correct` -- StaviConnectives.lean:459-539

**Severity**: BREAKS (sorry-free proof becomes invalid)

**Why**: In discrete orders, the gap-based U' is always false (no gaps exist). But `U(flatten(B), bot) AND NOT U(flatten(A), flatten(B))` can be true. Concrete counterexample: Z, t=0, A = (.base .bot) [always false], B = (.base p) where p holds at odd numbers only. Then:
- Gap-based U'(A,B)(0) = FALSE (Z has no gaps)
- "cofinal AND NOT U": B cofinal = TRUE (odd numbers are cofinal). NOT U(A,B) = TRUE (A is always false). So "cofinal AND NOT U" = TRUE.
- `flatten_stavi (.stavi_untl A B)` evaluates to TRUE at t=0
- The theorem claims these are equivalent, but FALSE != TRUE

**Fix required**: Either (a) change `flatten_stavi` to map stavi_untl to `bot` (since U' is always false in discrete orders), or (b) redefine it with a discrete-correct encoding and reprove. Option (a) is simpler but loses the structural encoding used in `left_formula`.

### 2.2 `stavi_U_discrete_equiv` -- StaviConnectives.lean:362-377

**Severity**: BREAKS

**Why**: Claims `stavi_U_truth M atomMap t A B <-> U(B,bot) AND NOT U(A,B)`. With the corrected definition, U' is always false in discrete orders, so the LHS is always False. But the RHS can be True (same counterexample as 2.1).

### 2.3 `stavi_S_discrete_equiv` -- StaviConnectives.lean:384-398

**Severity**: BREAKS (dual of 2.2)

### 2.4 `rank_embed_stavi_truth_mu` (stavi_untl case) -- EFGames.lean:1002-1023

**Severity**: PROOF BREAKS, STATEMENT SURVIVES

**Why the proof breaks**: The proof destructures the hypothesis into `hcof` (cofinal condition) and `hnU` (NOT U condition) matching the current definition. With a gap-based definition, the structure changes completely.

**Why the statement survives**: rank_embed preserves order, mu-status, and predicate values. Any reasonable definition of U' that depends only on these properties will be preserved by rank_embed. The theorem just needs a new proof.

### 2.5 `rank_embed_stavi_truth_mu` (stavi_snce case) -- EFGames.lean:1024-1045

**Severity**: PROOF BREAKS, STATEMENT SURVIVES (dual of 2.4)

### 2.6 `stavi_truth_mu_at_point` (stavi_untl case) -- EFGames.lean:1461-1496

**Severity**: PROOF BREAKS, STATEMENT SURVIVES

**Why the proof breaks**: Same structural mismatch as 2.4.

**Why the statement survives**: At an actual point m, mu-relativized evaluation reduces to standard evaluation because mu-points are exactly the actual points. For any reasonable definition of U' (gap-based or otherwise), the mu-relativization at a point in M should agree with the non-mu evaluation on M. The key property is that the gap/cut structure visible through mu-restricted quantifiers at a point is the same as the gap/cut structure of M itself.

### 2.7 `stavi_truth_mu_at_point` (stavi_snce case) -- EFGames.lean:1497-1532

**Severity**: PROOF BREAKS, STATEMENT SURVIVES (dual of 2.6)

### 2.8 FO table definitions (`stavi_U_fo`, `cofinal_above_fo`) -- StaviConnectives.lean:176-232

**Severity**: MUST CHANGE

These encode the "cofinal AND NOT table(U(p,q))" first-order formula. They need to be replaced with the correct GHR93 first-order table.

### 2.9 `cofinal_above_iff_succ` -- StaviConnectives.lean:263-281

**Severity**: SAFE but becomes ORPHANED

This theorem relates the cofinal condition to B(succ(t)) in discrete orders. With the corrected definition, the cofinal condition is no longer a conjunct of U', so this theorem is still true but no longer directly useful for U' equivalences.

### 2.10 `cofinal_below_iff_pred` -- StaviConnectives.lean:287-304

**Severity**: SAFE but becomes ORPHANED (dual of 2.9)

---

## 3. Theorems That SURVIVE

### 3.1 `until_bot_iff_succ` -- StaviConnectives.lean:313-331

**Status**: SAFE -- no dependency on U' semantics

### 3.2 `since_bot_iff_pred` -- StaviConnectives.lean:337-354

**Status**: SAFE (dual of 3.1)

### 3.3 `temporal_truth_neg` -- StaviConnectives.lean:427-431

**Status**: SAFE -- purely about Formula.neg

### 3.4 `temporal_truth_and` -- StaviConnectives.lean:434-448

**Status**: SAFE -- purely about Formula.and

### 3.5 `ghr93_duplicator_wins_round_mono` (Lemma 10) -- EFGames.lean:1956-2007

**Status**: SAFE -- purely structural, no U' dependency

### 3.6 `ghr93_game_implies_decomposition` (Lemma 11 forward) -- EFGames.lean:2566-2693

**Status**: SAFE -- works through formula_agreement generically, never unfolds stavi_temporal_truth_mu

### 3.7 `ghr93_case_I` -- ExpressivenessGeneral.lean:678

**Status**: SAFE -- works through formula_agreement generically, never references U' semantics

### 3.8 `ghr93_case_II` -- ExpressivenessGeneral.lean:1671

**Status**: SAFE -- works through formula_agreement generically, never references U' semantics

### 3.9 `ghr93_forward_to_backward` base case -- ExpressivenessGeneral.lean

**Status**: SAFE -- structural game manipulation

### 3.10 `ghr93_winning_condition_symm` -- ExpressivenessGeneral.lean:35-46

**Status**: SAFE -- purely structural

### 3.11 Gap infrastructure -- EFGames.lean:255-342

`Gap`, `gap_ext`, `gap_cuts_total`, `gap_definable_on_left`, `gap_definable_on_right`, `r_definable_gap`, `RDefinableGap`, `ExtendedCarrier`, `extendedLinearOrder`, `extendedStructure`:

**Status**: SAFE -- these use `stavi_temporal_truth M atomMap u D` for gap definability, but the D formula is always a `StaviFormula` (usually a `.base` formula or simple compound). The gap definability conditions are about whether D holds in final/initial segments of the cut/complement. These conditions do not themselves involve evaluating U' or S' -- they evaluate D at specific points. The definitions are structurally independent of what U' means.

**Caveat**: If D itself contains a `stavi_untl` or `stavi_snce` subformula, then evaluating D at a point involves the U'/S' semantics. However, in the GHR93 construction, D is always built from standard temporal formulas (rank <= r base formulas), so D evaluation never touches U'/S' at the base level. The gap_definable conditions are safe.

### 3.12 `gap_detection_unique` -- EFGames.lean:1547-1584

**Status**: SAFE -- uses `stavi_temporal_truth M atomMap u D` where D is the gap-defining formula (standard temporal). The proof logic depends on gap cut properties, not on U' semantics.

### 3.13 `rank_embed_stavi_truth_mu` (base, neg, conj cases) -- EFGames.lean:992-1001

**Status**: SAFE -- these cases don't involve U'/S'

### 3.14 `stavi_truth_mu_at_point` (base, neg, conj cases) -- EFGames.lean:1452-1460

**Status**: SAFE -- these cases don't involve U'/S'

### 3.15 `left_formula` and `right_formula` DEFINITIONS -- EFGames.lean:1129, 1188

**Status**: SAFE as definitions -- they are syntactic constructions that match GHR93 Definition 8.5 exactly. Their semantic correctness (Lemma 9) is already sorry'd. Changing U' semantics makes their proofs PROVABLE, not broken.

### 3.16 `operator_depth_flatten_stavi_le` and depth bounds -- EFGames.lean:1218+

**Status**: SAFE -- purely syntactic depth counting, no semantic dependency

### 3.17 `stavi_n_equiv`, `stavi_n_equiv_symm`, `stavi_n_equiv_mono` -- EFGames.lean:199-225

**Status**: SAFE -- these are definitions/trivial wrappers over `stavi_temporal_truth`. They will automatically use the new semantics. No proof logic depends on the internal structure of U'.

---

## 4. Already-Sorry'd Theorems (Become PROVABLE with Fix)

### 4.1 `left_formula_gap_detection` -- EFGames.lean:1618-1629

**Status**: Currently sorry'd. Becomes PROVABLE with correct gap-based U' definition. This is the primary motivation for the fix.

### 4.2 `right_formula_gap_detection` -- EFGames.lean:1637-1648

**Status**: Currently sorry'd. Becomes PROVABLE (dual of 4.1).

### 4.3 `ghr93_cases_III_IV` -- ExpressivenessGeneral.lean:2434-2455

**Status**: Currently sorry'd. Depends on 4.1 and 4.2. Becomes provable once Lemma 9 is proved.

### 4.4 `ghr93_decomposition_implies_game` (Lemma 11 backward) -- EFGames.lean:2710-2718

**Status**: Currently sorry'd. Independent of U' semantics -- this is a game strategy construction. Still needs work regardless of the fix.

### 4.5 `stavi_expressive_completeness` -- EFGames.lean:2783-2790

**Status**: Currently sorry'd. The main theorem. Depends on all the above.

---

## 5. The Correct Lean Encoding

### 5.1 The GHR93 First-Order Table

From GHR93 p. 95 (Section 3), cleaned up from OCR:

```
U'(p,q)(t) := exists s > t,
  (forall u, t < u < s ->
    (exists v, u < v AND forall w, t < w < v -> q(w))     -- Disjunct 1
    OR
    (forall v, u < v < s -> p(v)                            -- Disjunct 2
     AND exists v, t < v < u AND NOT q(v)))
  AND exists u, t < u < s AND NOT q(u)                     -- q fails somewhere
  AND exists u, t < u < s AND forall v, t < v < u -> q(v)  -- q holds initially
```

### 5.2 Recommended Approach: Direct FO Table

For `stavi_temporal_truth`, encode the FO table directly:

```lean
  | .stavi_untl A B =>
    ∃ s : M.carrier, t < s ∧
    -- Main body: for all u in (t,s), either q-cofinal or p-takes-over
    (∀ u : M.carrier, t < u → u < s →
      (∃ v : M.carrier, u < v ∧ ∀ w : M.carrier, t < w → w < v →
        stavi_temporal_truth M atomMap w B)
      ∨
      ((∀ v : M.carrier, u < v → v < s → stavi_temporal_truth M atomMap v A) ∧
       ∃ v : M.carrier, t < v ∧ v < u ∧ ¬stavi_temporal_truth M atomMap v B)) ∧
    -- q fails somewhere in (t,s)
    (∃ u : M.carrier, t < u ∧ u < s ∧ ¬stavi_temporal_truth M atomMap u B) ∧
    -- q holds on some initial segment
    (∃ u : M.carrier, t < u ∧ u < s ∧
      ∀ v : M.carrier, t < v → v < u → stavi_temporal_truth M atomMap v B)
```

S'(A,B) is defined dually (swap < and >, swap past/future).

### 5.3 Mu-Relativized Version

For `stavi_temporal_truth_mu`, add `mu_holds` constraints to all quantified points:

```lean
  | .stavi_untl A B =>
    ∃ s : ExtendedCarrier M atomMap r, t < s ∧
    (∀ u : ExtendedCarrier M atomMap r, t < u → u < s → mu_holds u →
      (∃ v : ExtendedCarrier M atomMap r, u < v ∧ mu_holds v ∧
        ∀ w : ExtendedCarrier M atomMap r, t < w → w < v → mu_holds w →
          stavi_temporal_truth_mu M atomMap r w B)
      ∨
      ((∀ v : ExtendedCarrier M atomMap r, u < v → v < s → mu_holds v →
          stavi_temporal_truth_mu M atomMap r v A) ∧
       ∃ v : ExtendedCarrier M atomMap r, t < v ∧ v < u ∧ mu_holds v ∧
          ¬stavi_temporal_truth_mu M atomMap r v B)) ∧
    (∃ u : ExtendedCarrier M atomMap r, t < u ∧ u < s ∧ mu_holds u ∧
      ¬stavi_temporal_truth_mu M atomMap r u B) ∧
    (∃ u : ExtendedCarrier M atomMap r, t < u ∧ u < s ∧ mu_holds u ∧
      ∀ v : ExtendedCarrier M atomMap r, t < v → v < u → mu_holds v →
        stavi_temporal_truth_mu M atomMap r v B)
```

**Note**: The witness `s` need NOT be mu-restricted. In the FO table, s is just a bound -- it is not required to be an actual point. This is important because in M_r, the "gap" is represented by an extended carrier element that is NOT a mu-point.

### 5.4 Impact on `flatten_stavi`

With the corrected definition, U' is always false in discrete orders. Two options:

**Option A (Simple)**: Map `stavi_untl A B` to `Formula.bot` and `stavi_snce A B` to `Formula.bot`. This is trivially correct for discrete orders. `flatten_stavi_correct` becomes trivially provable for the U'/S' cases (False <-> temporal_truth ... .bot = False <-> False).

**Option B (Preserve structure for left_formula)**: The `flatten_stavi` function is used inside `left_formula` and `right_formula` for the S/S' cases. In those definitions, `flatten_stavi` converts Stavi-enriched compound formulas into base formulas for wrapping in standard U/S. Since the S/S' cases of left_formula involve `U'(Top, B AND D)` and `NOT U'(D, B AND D)` subexpressions, and these are evaluated at actual points in M_r (where mu-relativization applies), the flattening needs to be semantically correct AT ACTUAL POINTS in M_r, not in arbitrary discrete orders.

At actual points in M_r, `stavi_truth_mu_at_point` transfers to `stavi_temporal_truth` on M. If M is not discrete (e.g., M = Q), then U' can be non-trivially true, and the flattening `U(B,bot) AND NOT U(A,B)` is WRONG (it computes "cofinal AND NOT U", not the gap-based definition).

**Recommendation**: Option A is correct for `flatten_stavi_correct` (discrete case). For `left_formula`/`right_formula`, the S/S' cases that use `flatten_stavi` need to be redesigned. The paper's Definition 8.5 uses "standard Until of Stavi formulas" which we encode via flattening. With the corrected U' definition, we need a way to convert "U(compound, D)" where compound contains Stavi connectives into something evaluable.

The cleanest approach: add a `stavi_untl_base` constructor to StaviFormula for "standard Until of Stavi subformulas" (i.e., U(A,B) where A, B are StaviFormulas but the Until itself is standard, not Stavi). This avoids needing flatten_stavi entirely.

### 5.5 Alternative: Gap-Based Definition

Instead of the FO table, define U' directly using gaps:

```lean
  | .stavi_untl A B =>
    ∃ (γ : Gap M.carrier),
      t ∈ γ.cut ∧                                    -- t is on the left side of the gap
      (∀ u : M.carrier, t < u → u ∈ γ.cut →          -- B holds from t to gap
        stavi_temporal_truth M atomMap u B) ∧
      (∃ u : M.carrier, u ∉ γ.cut ∧                   -- NOT B after gap
        ¬stavi_temporal_truth M atomMap u B) ∧
      (∃ s : M.carrier, s ∉ γ.cut ∧                   -- A holds beyond gap
        stavi_temporal_truth M atomMap s A)
```

**Advantage**: More intuitive, directly captures the gap picture from GHR93.

**Disadvantage**: Second-order (quantifies over gaps/cuts). The GHR93 point is that U' IS first-order despite involving gaps. Using the gap-based definition would require proving FO equivalence separately.

**Recommendation**: Use the FO table for the base definitions (preserving first-order character), and prove the gap-based equivalence as a separate theorem that is useful for Lemma 9.

---

## 6. Impact on `left_formula` / `right_formula` Encoding

### 6.1 The S/S' Cases Use `flatten_stavi`

In `left_formula_base` (line 1085), the `.snce` case constructs:
```
left(S(A,B), D) = U(compound, D)
```
where `compound` is a StaviFormula containing `U'(Top, B AND D)` and `NOT U'(D, B AND D)`. Since StaviFormula has no "standard Until of StaviFormulas" constructor, the code uses `flatten_stavi` to convert everything to base formulas:
```
.base (.untl (flatten_stavi compound) (flatten_stavi D))
```

With the corrected U' definition, `flatten_stavi` of a StaviFormula containing U' subformulas would need to preserve the correct gap-based semantics. Since `flatten_stavi` only works correctly in discrete orders, and M may not be discrete, this encoding is problematic.

### 6.2 Proposed Fix for left_formula / right_formula

**Approach**: Extend StaviFormula with standard Until/Since of StaviFormulas:

```lean
inductive StaviFormula : Type where
  | base (phi : Formula) : StaviFormula
  | stavi_untl (A B : StaviFormula) : StaviFormula
  | stavi_snce (A B : StaviFormula) : StaviFormula
  | neg (phi : StaviFormula) : StaviFormula
  | conj (phi psi : StaviFormula) : StaviFormula
  | std_untl (A B : StaviFormula) : StaviFormula  -- NEW: standard Until of Stavi subs
  | std_snce (A B : StaviFormula) : StaviFormula  -- NEW: standard Since of Stavi subs
```

Then `left_formula` for the S/S' cases can use `.std_untl compound D` directly, without needing `flatten_stavi`.

Evaluation in `stavi_temporal_truth` and `stavi_temporal_truth_mu` extends naturally:
```lean
  | .std_untl A B =>
    ∃ s, t < s ∧ stavi_temporal_truth M atomMap s A ∧
      ∀ r, t < r → r < s → stavi_temporal_truth M atomMap r B
```

This is the cleanest approach and avoids the flatten_stavi issue entirely.

---

## 7. Impact on Game Winning Condition

### 7.1 `formula_agreement` -- EFGames.lean:1767-1774

Uses `stavi_temporal_truth_mu` generically. **SAFE** -- adapts automatically to new semantics.

### 7.2 `ghr93_winning_condition` -- EFGames.lean:1790-1797

Composed of `same_order_type`, `gap_point_agreement`, `formula_agreement`. **SAFE** -- all components are parametric.

### 7.3 `ghr93_duplicator_wins` -- EFGames.lean:1813

**SAFE** -- wraps `ghr93_winning_condition`.

---

## 8. Discrete Equivalence Analysis

### 8.1 Claim: "cofinal AND NOT U" != gap-based U' in discrete orders

**Counterexample**: M = Z, t = 0, A = StaviFormula.base Formula.bot (always false), B = StaviFormula.base p where p holds at odd positive integers.

- **Gap-based U'(A,B)(0)**: FALSE. Z has no gaps (every Dedekind cut has a supremum in Z or its complement has an infimum). The FO table requires the third conjunct (exists u in (0,s) with q holding on (0,u)), which when combined with the second conjunct (exists u in (0,s) with NOT q(u)) and the main body, leads to a contradiction in discrete orders.

- **"cofinal AND NOT U"**: B cofinal above 0: yes (odd numbers are cofinal). NOT U(A,B)(0): yes (A is always false, so no Until witness exists). Result: TRUE.

### 8.2 Consequence

`flatten_stavi_correct` (which proves stavi_temporal_truth = temporal_truth of flatten_stavi in discrete orders) is FALSE with the corrected definition. The theorem needs fixing.

### 8.3 How U' Is Always False in Discrete Orders (FO Table)

In a discrete order with no max (NoMaxOrder), for any candidate s > t:
- Third conjunct requires u with t < u < s and q on (t,u). Take u = succ(t): (t, succ(t)) is empty, so q vacuously holds. Good.
- Second conjunct requires u' with t < u' < s and NOT q(u').
- Main body for u' (where NOT q(u')): first disjunct requires v > u' with q on (t,v), which includes u' itself, contradicting NOT q(u'). Second disjunct requires NOT q somewhere in (t, u').
- For the minimal such u' (first point after t where q fails), (t, u') consists of points where q holds. So NOT q in (t, u') is empty. Second disjunct fails.
- Both disjuncts fail for this u'. Main body is violated.

Therefore U'(A,B) is always false in discrete orders under the FO table definition.

---

## 9. Implementation Plan

### Phase 1: Core Definition Changes (StaviConnectives.lean)

1. Replace `stavi_U_truth` with FO-table-based definition
2. Replace `stavi_S_truth` with dual FO-table-based definition
3. Replace `stavi_temporal_truth` stavi_untl/stavi_snce cases with FO table
4. Replace FO encoding definitions (`stavi_U_fo`, `cofinal_above_fo`, etc.) with correct FO table
5. Update `flatten_stavi` to map stavi_untl/stavi_snce to `Formula.bot`
6. Delete or update `stavi_U_discrete_equiv` and `stavi_S_discrete_equiv`
7. Reprove `flatten_stavi_correct` (trivial for U'/S' cases: False <-> False)
8. Mark `cofinal_above_iff_succ` and `cofinal_below_iff_pred` as orphaned (keep for potential reuse)

### Phase 2: StaviFormula Extension (StaviConnectives.lean + EFGames.lean)

9. Add `std_untl` and `std_snce` constructors to StaviFormula
10. Extend `stavi_temporal_truth` with standard Until/Since of Stavi subformulas
11. Extend `stavi_temporal_truth_mu` correspondingly
12. Extend `stavi_depth` for the new constructors

### Phase 3: EFGames.lean Definition Updates

13. Replace `stavi_temporal_truth_mu` stavi_untl/stavi_snce cases with FO table (mu-relativized)
14. Reprove `rank_embed_stavi_truth_mu` for stavi_untl/stavi_snce cases (statement unchanged)
15. Reprove `stavi_truth_mu_at_point` for stavi_untl/stavi_snce cases (statement unchanged)
16. Reprove `rank_embed_stavi_truth_mu` for new std_untl/std_snce cases
17. Reprove `stavi_truth_mu_at_point` for new std_untl/std_snce cases

### Phase 4: left_formula / right_formula Updates

18. Rewrite S/S' cases of `left_formula_base` to use `std_untl` instead of `flatten_stavi`
19. Rewrite S/S' cases of `left_formula` and `right_formula` similarly
20. Rewrite S/S' cases of `right_formula_base` similarly
21. Update `operator_depth_flatten_stavi_le` and depth bounds for new constructors
22. Update `left_depth_bound` and `right_depth_bound`

### Phase 5: Prove Gap-Based Equivalence (Optional but Recommended)

23. Prove that the FO table definition is equivalent to the gap-based definition
24. Use this equivalence to prove Lemma 9 more naturally

### Phase 6: Prove Lemma 9

25. Prove `left_formula_gap_detection` (now provable with correct semantics)
26. Prove `right_formula_gap_detection`

---

## 10. Estimated Effort

| Phase | Effort | Lines | Risk |
|-------|--------|-------|------|
| Phase 1: Core definitions | Medium | ~150 new/modified | Low -- straightforward replacement |
| Phase 2: StaviFormula extension | Medium | ~80 new | Low -- clean additive change |
| Phase 3: EFGames definitions | High | ~200 reproof | Medium -- FO table proofs are complex |
| Phase 4: left/right formula | Medium | ~100 modified | Medium -- structural but intricate |
| Phase 5: Gap equivalence | High | ~200 new | Medium -- non-trivial mathematical content |
| Phase 6: Lemma 9 | Very High | ~500+ new | High -- the core proof obligation |
| **Total** | | **~1200+ lines** | |

---

## 11. Confidence Level

**HIGH (90%)** that this analysis is complete and correct.

Evidence:
1. Grep confirms Stavi connectives are confined to three files
2. Every occurrence of `stavi_untl`/`stavi_snce` in sorry-free proofs has been traced
3. The discrete counterexample is concrete and verified step-by-step
4. The FO table matches three independent sources (GHR93, BdRV 2002, Venema 1993)
5. Cases I, II, Lemma 10, Lemma 11 forward are verified parametric (no U' unfolding)

**Remaining uncertainty** (10%):
- The exact handling of `std_untl`/`std_snce` in `left_formula` may require more thought
- The proof complexity of Phase 3 (reproving rank_embed and truth_mu_at_point for the FO table) may be higher than estimated
- The mu-relativized FO table for `stavi_temporal_truth_mu` needs careful treatment of the witness s (should it be mu-restricted or not?)

---

## Appendix: Complete Sorry Map (Current State)

### StaviConnectives.lean: 0 sorries

### EFGames.lean: 6 sorries
1. `left_formula_gap_detection` (line 1629) -- Lemma 9 left
2. `right_formula_gap_detection` (line 1648) -- Lemma 9 right
3. `ghr93_decomposition_implies_game` (line 2718) -- Lemma 11 backward
4. `stavi_expressive_completeness` (line 2790) -- main theorem

### ExpressivenessGeneral.lean: sorry count varies by section
- Strategy restriction infrastructure: several sorries (d-consistency, containment)
- Inductive step setup: sorry for obtain_split_point_props
- Case I: sorry-free
- Case II: sorry-free
- Cases III-IV: 1 sorry (the whole block)
- Main inductive step assembly: 1 sorry

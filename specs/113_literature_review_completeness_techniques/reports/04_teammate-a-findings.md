# Teammate A Findings: R-Relation Infrastructure Redesign for Open Guard

**Focus**: How should BurgessR3 r-relation and associated infrastructure be redesigned for open guard semantics?

**Date**: 2026-04-27

## Key Findings

### 1. The Obligation-Based rRelation Definition Is Sound Under Open Guard

The core `rRelation` definition (ChronicleTypes.lean:142-145) is **semantically correct** under open guard:

```
def rRelation (A B : Set Formula) : Prop :=
  forall gamma delta,
    Formula.untl gamma delta in A ->
    delta in B or (gamma in B and Formula.untl gamma delta in B)
```

This says: "if Until(gamma, delta) is in A, then either B resolves it (delta holds) or B continues it (guard holds and obligation persists)." This is purely a syntactic propagation condition on formulas-in-sets. It does NOT require the evaluation point to be in the guard interval. The r-relation captures what holds at INTERMEDIATE points between t and the witness s, which is exactly the open interval (t,s).

Similarly, `burgessR3` (ChronicleTypes.lean:305) is inherently sound -- it says "for all beta in B, for all gamma in C, untl(beta, gamma) in A." This is content-based and guard-agnostic.

**Verdict**: The r-relation DEFINITIONS need no changes. The LEMMAS about these relations are the problem.

### 2. Classification of Invalid Lemmas: Three Distinct Failure Modes

**Failure Mode A -- Guard Extraction at Evaluation Point** (TRULY DEAD):
These extract gamma or delta from Until(gamma, delta) at the current point, which open guard semantics forbids:

- `until_guard_in_mcs`: U(gamma, delta) in A -> gamma in A. FALSE: t is not in (t,s).
- `since_guard_in_mcs`: S(gamma, delta) in A -> gamma in A. FALSE: t is not in (s,t).
- `until_disjunction_in_mcs`: U(gamma, delta) in A -> gamma or delta in A. FALSE: neither need hold at t.
- `since_disjunction_in_mcs`: Mirror.
- `rRelation_of_superset_mcs`: A subset B (MCS) -> rRelation(A, B). FALSE: needs BX9 to case-split.
- `rRelationSince_of_superset_mcs`: Mirror.
- `rRelation_self_mcs`: rRelation(B, B) for MCS B. FALSE: needs gamma-or-delta at the same point.
- `rRelationSince_self_mcs`: Mirror.
- `B_sub_A_of_burgessR3`: burgessR3(A, B, C) -> B subset A. FALSE: needs until_guard.
- `B_sub_C_of_burgessR3`: burgessR3(A, B, C) -> B subset C. FALSE: needs since_guard.

**Failure Mode B -- Junction Point Not Covered** (TRULY DEAD):
These require the guard to cover a junction point between two Until intervals:

- `untl_absorb_nested`: U(gamma, U(gamma, delta)) -> U(gamma, delta). FALSE: at the junction s where U(gamma, delta) is witnessed, gamma(s) is not guaranteed by the outer open guard (t,s).
- `snce_absorb_nested`: Mirror.

**Failure Mode C -- Downstream Dependents** (INVALIDATED BY DEPENDENCY):
These are not intrinsically wrong but call invalid lemmas:

- `rRelation_of_subset_mcs`: Calls rRelation_of_superset_mcs.
- `r3Relation_of_superset_mcs`: Calls both superset lemmas.
- `BurgessR3Maximal_maximality_combined` (neg-delta-in-B case, line 694): Calls until_guard_in_mcs.
- `burgess_D0_consistent`: Calls BurgessR3Maximal_maximality_combined.
- `burgessR3_gamma_not_in_B_nested`: Calls untl_absorb_nested.
- `burgessR3_gamma_not_in_B_since_nested`: Calls snce_absorb_nested.
- `burgess_D0_elem_in_A_or_C`: Calls B_sub_A and B_sub_C.
- `lemma_2_6_full` (obligation-based): Calls rRelation_self_mcs / rRelationSince_self_mcs.

### 3. What The R-Relation Infrastructure Actually NEEDS

Tracing downstream usage through the chronicle construction:

**a) C2' construction (CounterexampleElimination.lean, 6 sorry sites)**: Needs BurgessR3Maximal for new adjacent pairs after point insertion. This uses `burgessR3Maximal_extension_exists` (VALID) and `burgessR3_absorption` (VALID). The c2' sorries are g-value construction problems, NOT r-relation definition problems. They need seed elements, which Xu 1988 Lemma 2.4 provides.

**b) C4 hard case (CounterexampleElimination.lean line 1086)**: One sorry where burgessR3 needs to hold with different right endpoint. This is a genuine structural problem -- you cannot change the right endpoint of burgessR3 arbitrarily.

**c) BurgessR3Maximal_maximality_combined (PointInsertion.lean:662-725)**: The VALID case (delta.neg not in B, lines 698-725) does NOT use until_guard. Only the INVALID case (delta.neg in B, lines 670-697) uses until_guard. This is the critical lemma for the splitting construction (Burgess Lemma 2.6).

**d) burgess_D0_consistent (PointInsertion.lean:965-972)**: Uses BurgessR3Maximal_maximality_combined.

**e) Forward Until/Since coherence (ChronicleToCountermodel.lean:609-624)**: The 2 sorry sites for `cantor_bfmcs_restricted_fuc`. These need the full C5 guard (phi at intermediate points), which requires the real interval function g with C3 three-way property.

**f) Backward Until/Since coherence (ChronicleToCountermodel.lean:495-499)**: 1 sorry for `cantor_bfmcs_restricted_buc`. Uses C4 contrapositive. The archived proof (lines 501-589) shows the structure but needs guard bound adjustment (le -> lt).

### 4. The `BurgessR3Maximal_maximality_combined` Fix Is the Crux

The ONLY place where `until_guard_in_mcs` is structurally load-bearing in the r-relation infrastructure is in `BurgessR3Maximal_maximality_combined`, specifically the case where `delta.neg in B`:

```lean
-- Current (INVALID) argument:
-- delta.neg in B, so untl(delta.neg AND delta, gamma) in A for all gamma in C.
-- Since (delta.neg AND delta) |- bot, by BX2: untl(bot, gamma) in A.
-- By until_guard: bot in A. Contradiction.
```

The problem: `untl(bot, gamma) in A` does NOT give `bot in A` under open guard. Under open guard, `bot U gamma` means "there exists s > t with gamma(s) and bot on (t,s)." If (t,s) is empty (s is the immediate successor of t in a discrete model), then bot on the empty interval is vacuously true, so bot U gamma can hold without bot holding anywhere.

**However**: BX10 gives `F(gamma) in A` from `bot U gamma in A`. This is not immediately contradictory.

**The real fix**: The contradiction must come from the CONSISTENCY of A, not from extracting bot. The key insight is:

For ALL gamma in C (which is an MCS, hence nonempty), we get `untl(bot, gamma) in A`. By BX10, `F(gamma) in A` for all gamma in C. Crucially, C is an MCS, so for any phi, either phi in C or phi.neg in C. This means `F(phi) in A` AND `F(phi.neg) in A` for all phi. But `F(phi) AND F(phi.neg)` is not contradictory -- both can be true at different future times.

We can also try: `untl(bot, top) in A` (since top is in C). By BX5: `(bot AND (bot U top)) U top in A`, which simplifies to `bot U top in A` (since bot AND X = bot). So `bot U top in A`. BX12 gives `F(top) in A`, which is trivially true. No contradiction.

This suggests the delta.neg-in-B case needs a fundamentally different argument. The question is whether `{delta} union B` can be shown INCONSISTENT directly when delta.neg in B, which would make the DC({delta} union B) case vacuous. Indeed: if delta.neg in B (a DCS) and we take {delta} union B, this set derives bot (from delta and delta.neg). So DC({delta} union B) is the whole formula algebra, and burgessR3(A, DC({delta} union B), C) would require untl(phi, gamma) in A for ALL phi and ALL gamma in C, which IS contradictory (take gamma = bot -- then untl(phi, bot) in A, and by BX10, F(bot) in A, i.e. neg(G(neg(bot))) in A. But G(neg(bot)) = G(top) is a theorem, so G(top) in A, contradiction.)

**THIS IS THE FIX**: When delta.neg in B, the set {delta} union B is INCONSISTENT (since delta.neg in B derives bot from delta). So DC({delta} union B) = all formulas. Then burgessR3(A, DC({delta} union B), C) requires untl(bot, gamma) in A for all gamma in C. Taking gamma = bot.neg (top), we get untl(bot, top) in A. By BX10, F(top) in A. But F(top) = neg(G(neg(top))) = neg(G(bot)). Since G(bot) derives bot (by temporal necessitation of the identity + K distribution), G(bot) is not in any consistent set. So neg(G(bot)) = F(top) is actually a theorem and IS in A. No contradiction this way.

Wait, the point is that DC({delta} union B) is INCONSISTENT. So `SetConsistent (DC({delta} union B))` is false. The `BurgessR3Maximal_extension_fails` theorem requires `SetConsistent ({delta} union B)` as a hypothesis. When delta.neg in B, this hypothesis is FALSE. So the extension-fails theorem is vacuously true -- the deductive closure is inconsistent, so it cannot be a DCS, and thus it cannot violate maximality. The maximality combined lemma should just observe that when delta.neg in B, {delta} union B is inconsistent, so the extension argument is vacuously satisfied.

Let me re-read the proof structure more carefully to confirm.

### 5. Detailed Fix for `BurgessR3Maximal_maximality_combined`

The lemma states: if BurgessR3Maximal(A, B, C) and delta not in B, then the conjunction of two conditions is FALSE:
- (U-cond): for all beta in B, gamma in C: untl(beta AND delta, gamma) in A
- (S-cond): for all beta in B, alpha in A: snce(beta AND delta, alpha) in C

Case 1: delta.neg in B. Then (beta AND delta) with beta = delta.neg gives (delta.neg AND delta), which is propositionally bot. By BX2, untl(bot, gamma) in A for all gamma in C. The old proof derived bot in A via until_guard, which is invalid.

**The correct argument under open guard**: When delta.neg in B, the set {delta} union B is inconsistent (delta and delta.neg are both present). This means the deductive closure DC({delta} union B) is the entire set of formulas (everything is derivable from an inconsistent set). Now consider whether DC({delta} union B) satisfies burgessR3(A, -, C). It would require: for all phi (every formula is now in DC), for all gamma in C, untl(phi, gamma) in A. This is clearly false for any consistent A (take phi = some formula with untl(phi, gamma).neg in A). So the extension IS inconsistent, and therefore NOT a DCS (since a DCS must be consistent). Since it is not a DCS, it cannot serve as a proper extension of B satisfying burgessR3. The maximality condition is satisfied vacuously.

**Cleaner argument**: The maximality_combined lemma can short-circuit the delta.neg-in-B case: if delta.neg in B, then {delta} union B |- bot, so {delta} union B is inconsistent, so DC({delta} union B) is inconsistent, so DC({delta} union B) is NOT a DCS. Since BurgessR3Maximal requires DCS extensions, no DCS can contain both delta and everything in B. The conjunction of U-cond and S-cond is refuted because `dc_delta_B_burgessR3` would construct an inconsistent "DCS" extension, which is impossible.

Wait -- the lemma as stated does not reason about extensions. It directly proves that the conjunction is false. We need to show:
  NOT (U-cond AND S-cond)

where U-cond = forall beta in B, gamma in C: untl(beta AND delta, gamma) in A
and S-cond = forall beta in B, alpha in A: snce(beta AND delta, alpha) in C.

If delta.neg in B, then taking beta = delta.neg:
- U-cond gives: for all gamma in C, untl(delta.neg AND delta, gamma) in A
- Since delta.neg AND delta |- bot, by BX2 (left monotonicity): untl(bot, gamma) in A for all gamma in C.

Now the key question: does `untl(bot, gamma) in A` lead to contradiction for a CONSISTENT A?

Under open guard: `bot U gamma` at t requires some s > t with gamma(s) and bot on (t,s). On a dense order, (t,s) is nonempty for any s > t, and bot cannot hold at any point. So semantically, `bot U gamma` is FALSE on dense orders. This means `bot U gamma` is not in any MCS that is satisfied by a dense model. However, at the syntactic level in the completeness proof, A is an arbitrary MCS -- it might be consistent but not yet known to be satisfiable (that is what we are trying to prove).

The syntactic argument: from `untl(bot, gamma) in A` for all gamma in C, and C is an MCS, take any gamma in C. By BX10: F(gamma) in A. This holds for all gamma in C, including bot.neg (which is top, a theorem in any MCS). So F(top) in A, which is just a theorem. No contradiction from this alone.

But also: `untl(bot, bot) in A` (since bot is in the deductive closure of any DCS, and C being an MCS means we can pick gamma = bot -- wait, bot is NOT in any consistent set/MCS. C is an MCS, so bot is NOT in C. So we cannot pick gamma = bot.

The correct approach: from untl(bot, gamma) in A for all gamma in C, and C has infinitely many formulas, we can derive untl(bot, gamma1 AND gamma2) in A for pairs (using BX7 linearity). But this still just gives F(gamma1 AND gamma2) in A.

Actually, there IS a valid syntactic contradiction. Consider: `untl(bot, gamma) in A` for all gamma in C. By BX5 (self_accum_until): `(bot AND (bot U gamma)) U gamma in A`. Since `bot AND X = bot` propositionally, this gives `bot U gamma in A` again -- no progress. By BX3 (right_mono_until): if G(gamma -> gamma') in A and untl(bot, gamma) in A, then untl(bot, gamma') in A. This just propagates.

Let me try another approach. We know C is an MCS, so for any phi, either phi in C or phi.neg in C. So we get untl(bot, phi) in A OR untl(bot, phi.neg) in A for every phi. By BX10: F(phi) in A OR F(phi.neg) in A for every phi. This means G(phi) not in A OR G(phi.neg) not in A for every phi. But this is just the dual of "not both G(phi) and G(phi.neg)" which is normal for consistent sets. No contradiction.

**Conclusion on delta.neg-in-B case**: The old argument genuinely CANNOT be repaired by just replacing until_guard with BX10. The delta.neg-in-B case needs the `BurgessR3Maximal_extension_fails` route instead, which uses the extension structure. When delta.neg in B, {delta} union B is inconsistent, so its deductive closure is inconsistent, so it is NOT a DCS, so the extension-fails theorem's hypothesis `SetConsistent ({delta} union B)` is false, making the conclusion vacuously true. The maximality combined lemma should be restructured to first check consistency of {delta} union B.

**Here is the corrected proof sketch**:

```lean
theorem BurgessR3Maximal_maximality_combined ...
  intro ⟨h_until_all, h_since_all⟩
  -- Check: is {delta} union B consistent?
  by_cases h_cons : SetConsistent ({delta} ∪ B)
  · -- Consistent case: dc_delta_B_burgessR3 gives burgessR3 on extension
    -- BurgessR3Maximal_extension_fails gives contradiction
    exact BurgessR3Maximal_extension_fails h_R3M h_delta_not h_cons
      (dc_delta_B_burgessR3 h_mcs_A h_mcs_C h_dcs h_R3M.2.1 h_until_all h_since_all)
  · -- Inconsistent case: {delta} union B is inconsistent, meaning delta.neg in B.
    -- But wait -- the U-cond and S-cond can STILL be true even when
    -- {delta} union B is inconsistent! We need to derive a contradiction
    -- from U-cond and S-cond directly.
    -- ...this is the hard part...
```

Actually, on further reflection, the INCONSISTENT case IS where the trouble is. When delta.neg in B, we cannot use the extension argument (since the extension is not consistent/not a DCS). We need another argument.

**New insight**: Use `left_mono_contrapositive_neg_delta` (PointInsertion.lean:887). This lemma (VALID under open guard) shows: if untl(beta, gamma) in A and untl(beta AND delta, gamma) NOT in A, then delta.neg in A or F(delta.neg) in A. The contrapositive: if untl(beta AND delta, gamma) in A for all beta in B, gamma in C (from U-cond), and delta.neg NOT in A and F(delta.neg) NOT in A, then... but this doesn't directly help.

**Alternative approach via BX7**: From untl(bot, gamma) in A (for all gamma in C), consider BX7 (linearity) applied to untl(bot, gamma) and untl(gamma, gamma) (the latter provable from BX5 or similar). Actually BX7 requires two Until formulas with the same starting point.

**Better approach**: Reconsider whether `B_sub_A_of_burgessR3` can be proved without until_guard. If burgessR3(A, B, C) and beta in B, then for all gamma in C, untl(beta, gamma) in A. Under HALF-closed guard, until_guard gives beta in A. Under open guard, this FAILS.

But do we actually need B subset A? In Burgess's construction, the interval set g(x,y) represents formulas true on the OPEN interval (x,y), which does NOT include the endpoints x,y. So B (= g(x,y)) does NOT need to be a subset of A (= f(x)). The requirement B subset A was an artifact of the half-closed guard where the interval [x,y) included x.

### 6. The `untl_absorb_nested` Fix and C4 Generalized Bridging

`untl_absorb_nested` proves U(gamma, U(gamma, delta)) -> U(gamma, delta). This fails at the junction point s under open guard.

This lemma is used ONLY in `burgessR3_gamma_not_in_B_nested` and its Since mirror. These are used for the C4 hard case when the counterexample formula is itself an Until formula: neg(U(gamma, delta)) in f(x) and U(gamma, delta) in f(y).

**The C4 hard case argument can be restructured**: Instead of proving gamma not-in g(x,y) via absorption, use the C4 CONDITION ITSELF. If neg(U(gamma, delta)) in f(x) and U(gamma, delta) in f(y), then by C4 applied to the Until formula at a higher level (or by applying the C4 condition to the inner Until's eventual witness), we get the needed counterexample point. The nested absorption is an unnecessary shortcut.

Specifically: the C4 condition says "if neg(U(phi, psi)) in f(x) and psi in f(y), then there exists z with x < z < y and phi.neg in f(z)." When psi IS U(gamma, delta), we apply C4 directly: neg(U(phi, U(gamma, delta))) in f(x) and U(gamma, delta) in f(y). This gives z with phi.neg in f(z), which is exactly what the counterexample elimination needs.

The `burgessR3_gamma_not_in_B_nested` lemma tries to handle the case where the EVENT in C is itself an Until formula. But this case can be handled without absorption: burgessR3_gamma_not_in_B already handles the case where delta in C. When the "delta" is U(gamma, delta), it is just another formula in C, and the standard bridging lemma applies directly.

**Wait**: Looking more carefully at `burgessR3_gamma_not_in_B_nested`, it says: if neg(U(gamma, delta)) in A and U(gamma, delta) in C, then gamma not-in B. The standard `burgessR3_gamma_not_in_B` says: if neg(U(gamma, DELTA)) in A and DELTA in C, then gamma not-in B. With DELTA = U(gamma, delta), we need U(gamma, delta) in C, and neg(U(gamma, U(gamma, delta))) in A. But the C4 case has neg(U(gamma, delta)) in A (not neg(U(gamma, U(gamma, delta)))). So the nested version handles a DIFFERENT formula structure.

The nested version is needed because in the C4 case, the counterexample is neg(U(gamma, delta)) in f(x) and the EVENT delta might not be in f(y). Instead, what is in f(y) might be U(gamma, delta) itself (the Until formula persists rather than resolves). The old argument was: if gamma in g(x,y), then U(gamma, U(gamma, delta)) in f(x) (by burgessR3), then by absorption U(gamma, delta) in f(x), contradicting neg(U(gamma, delta)) in f(x).

**The fix**: Instead of absorption, use the C4 CONDITION directly. The C4 condition at the chronicle level handles this case without needing the syntactic absorption lemma. When C4 sees neg(U(gamma, delta)) in f(x) and delta in f(y), it finds z with gamma.neg in f(z). The case where delta is NOT in f(y) but U(gamma, delta) is in f(y) means the Until obligation PERSISTS -- it has not been resolved. By C5 (forward counterexample), eventually delta must be in some f(y') with y' > y, and then C4 applies at the pair (x, y'). The chronicle construction handles this through iterative elimination.

**Practical implication**: `burgessR3_gamma_not_in_B_nested` and its Since mirror can likely be REMOVED entirely. The C4 hard case in CounterexampleElimination does not need nested absorption -- it needs the basic `burgessR3_gamma_not_in_B` lemma, which is VALID (it only requires delta in C and neg(U(gamma, delta)) in A, with no absorption needed).

### 7. `burgess_D0_consistent` Can Be Fixed

The D0 seed consistency argument depends on `BurgessR3Maximal_maximality_combined`. As analyzed in Finding 5, the delta.neg-in-B case needs restructuring. Here is the corrected approach:

The D0 seed is: {S(beta, alpha) : alpha in A, beta in B} union B union {neg-delta} union {U(beta, gamma) : beta in B, gamma in C}.

Consistency proof (corrected): Suppose L subset D0 and L |- bot. We need a contradiction.

Case 1: neg-delta NOT in L. Then L subset {Since-formulas} union B union {Until-formulas}. The Since formulas are in C (by burgessRSetSince), the Until formulas are in A (by burgessRSet), and B... under open guard, B is NOT necessarily subset of A or C. This is the real issue.

**The B-subset-A problem**: The D0 consistency argument fundamentally requires that elements of B can be "routed" into either A or C for the finite-subset consistency argument. Under half-closed guard, B subset A (via until_guard). Under open guard, this fails.

**Burgess's original argument**: Burgess 1982 uses a DIFFERENT D0 seed. In Burgess, the g-function values are required to be subsets of both endpoint MCS (because Burgess uses half-closed guard). Under open guard, we need to check whether Burgess's argument can be adapted.

**Alternative approach**: Instead of requiring B subset A, observe that for each beta in B, we have untl(beta, gamma) in A for all gamma in C (by burgessRSet). This means that a finite subset {beta_1, ..., beta_n} of B, combined with the Until formulas {U(beta_i, gamma_j)}, is ALREADY present in A (the Until formulas) and C (the Since formulas). The B elements themselves can be recovered from the Until formulas via BX5 + BX6 absorption arguments WITHIN A.

Actually, this is getting circular. The cleaner approach may be:

**Weakened D0 seed**: Replace B in the seed with g_content(A) intersection g_content_past(C):
  D0' = {S(beta, alpha) : alpha in A, beta in g_content(A) cap g_content_past(C)} union g_content(A) cap g_content_past(C) union {neg-delta} union {U(beta, gamma) : beta in g_content(A) cap g_content_past(C), gamma in C}

where g_content(A) = {phi : G(phi) in A}. Then g_content(A) subset A (since G(phi) in A implies phi in A by BX4's converse... wait, that is not available either. G(phi) -> phi requires the T axiom, which holds for S5 but not directly).

Hmm. Actually under S5, Box(phi) -> phi is valid. And G(phi) -> phi IS valid for irreflexive strict orders? No -- G(phi) means "phi at all STRICTLY future times," which does not include the current time.

**The fundamental issue**: Under open guard on a strict order, the interval set B = g(x,y) represents formulas holding on the open interval (x, y). There is no reason for these formulas to hold at x or y themselves. The D0 seed consistency argument in Burgess 1982 relies on the interval set being a subset of the endpoint MCS, which is guaranteed by the half-closed guard (the interval [x,y) includes x).

**Recommended resolution for burgess_D0_consistent**: The D0 seed should NOT include B directly. Instead, it should be structured as:
  D0 = {neg-delta} union {U(beta, gamma) : beta in B, gamma in C} union {S(beta, alpha) : beta in B, alpha in A}

This removes B from the seed. The Until and Since formulas are already in A and C respectively (by burgessR3). The Lindenbaum extension of D0 to MCS D will contain neg-delta and all the Until/Since formulas. Then B ⊆ D follows from: for each beta in B, U(beta, gamma_0) in D (from the seed, with gamma_0 = top from C), and S(beta, alpha_0) in D (from the seed, with alpha_0 = top from A). But this does NOT immediately give beta in D.

**Alternatively**: Accept that B subset D is NOT needed. The Burgess construction needs burgessR3(A, B, D) and burgessR3(D, B, C), not B subset D. The splitting gives BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C) with B subset B' and B subset B''. The B' and B'' are Zorn extensions and need not equal B.

### 8. `rRelation_self_mcs` and `lemma_2_6_full` Are Dead But Unnecessary

`rRelation_self_mcs` (rRelation(B, B) for MCS B) is used in `lemma_2_6_full`, which constructs the OBLIGATION-BASED three-way decomposition for R3Maximal. But the codebase has MIGRATED to the content-based BurgessR3Maximal. The obligation-based R3Maximal and lemma_2_6_full are a dead path. Callers should use BurgessR3Maximal and `burgessR3Maximal_extension_exists` instead.

Similarly, `rRelation_of_superset_mcs` is used in `r3Relation_of_superset_mcs` and `rRelation_of_subset_mcs`, which are used in the obligation-based R3Maximal path. These can all be archived.

### 9. The `cantor_bfmcs_restricted_buc` Fix

The backward Until/Since coherence (line 499) has a sorry because the guard bound changed from `le` to `lt`. The archived proof at lines 501-589 shows the structure. The fix is mechanical: change `le_of_lt hz_rat_gt` at line 541 to match the new open guard semantics. The guard condition `h_guard z_rat (le_of_lt hz_rat_gt) hz_rat_lt` should become `h_guard z_rat hz_rat_gt hz_rat_lt` (both strict inequalities, since the open guard uses `t < r < s` not `t <= r < s`). The semantic type of `restricted_backward_until_since_coherent` may need updating to reflect the strict guard bounds.

### 10. Summary of Sorry Sites and Dependencies

```
INVALID LEMMAS (must be removed or restructured):
  RRelation.lean:
    - until_disjunction_in_mcs (line 82)          -- REMOVE (truly false)
    - until_guard_in_mcs (line 102)                -- REMOVE (truly false)
    - since_guard_in_mcs (line 117)                -- REMOVE (truly false)
    - since_disjunction_in_mcs (line 158)          -- REMOVE (truly false)
    - rRelation_of_subset_mcs (line 197)           -- REMOVE (depends on invalid)
    - r3Relation_of_superset_mcs (line 494)        -- REMOVE (depends on invalid)
    - untl_absorb_nested (line 1251)               -- REMOVE (truly false)
    - snce_absorb_nested (line 1263)               -- REMOVE (truly false)
    - burgessR3_gamma_not_in_B_nested (line 1277)  -- RESTRUCTURE (use C4 directly)
    - burgessR3_gamma_not_in_B_since_nested (1299) -- RESTRUCTURE (use C4' directly)
  ChronicleTypes.lean:
    - rRelation_of_superset_mcs (line 564)         -- REMOVE (truly false)
    - rRelationSince_of_superset_mcs (line 573)    -- REMOVE (truly false)
  PointInsertion.lean:
    - until_elim_mcs (line 180)                    -- REMOVE (truly false)
    - rRelation_self_mcs (line 498)                -- REMOVE (needs BX9)
    - rRelationSince_self_mcs (line 509)           -- REMOVE (needs BX9')
    - BurgessR3Maximal_maximality_combined:694      -- RESTRUCTURE (see Finding 5)
    - B_sub_A_of_burgessR3 (line 799)              -- REMOVE (needs until_guard)
    - B_sub_C_of_burgessR3 (line 812)              -- REMOVE (needs since_guard)
    - burgess_D0_consistent (line 965)             -- RESTRUCTURE (see Finding 7)

VALID INFRASTRUCTURE (no changes needed):
  RRelation.lean:
    - rRelation_guard_continues' (line 185)        -- VALID
    - until_implies_F_in_mcs (line 127)            -- VALID (uses BX10)
    - until_self_accum_in_mcs (line 139)           -- VALID (uses BX5)
    - rMaximal_extension_exists (line 282)         -- VALID
    - r3Maximal_extension_exists (line 401)        -- VALID
    - burgessR3Maximal_extension_exists (line 793) -- VALID
    - burgessR_absorption (line 549)               -- VALID (uses BX6)
    - burgessR3_absorption (line 653)              -- VALID
    - burgessR3_untl_in (line 877)                 -- VALID
    - burgessR3_gamma_not_in_B (line 903)          -- VALID
    - untl_conj_guard (line 996)                   -- VALID (uses BX7)
    - untl_left_mono_thm (line 1086)               -- VALID (uses BX2)
    - burgessR3Maximal_exists_from_seed (line 1200) -- VALID
    - c4_hard_case_G_neg_delta (line 698)          -- VALID
  PointInsertion.lean:
    - BurgessR3Maximal_extension_fails (line 615)  -- VALID
    - dc_delta_B_burgessR3 (line 632)              -- VALID
    - left_mono_contrapositive_neg_delta (line 887) -- VALID
  ChronicleTypes.lean:
    - rRelation_subset (line 535)                  -- VALID
    - rRelationSince_subset (line 543)             -- VALID
    - r3Relation_subset (line 591)                 -- VALID
```

## Recommended Approach

### Priority 1: Fix `BurgessR3Maximal_maximality_combined`

Restructure the delta.neg-in-B case:

When delta.neg in B, {delta} union B is inconsistent (delta + delta.neg |- bot). Therefore:
1. `SetConsistent ({delta} union B)` is FALSE.
2. The argument from `BurgessR3Maximal_extension_fails` applies vacuously (inconsistent set has no DCS extension satisfying anything, because inconsistent DC is not a DCS).
3. We can pass `h_cons : SetConsistent ({delta} union B)` as the hypothesis and derive `False` from it directly, making the `BurgessR3Maximal_extension_fails` call work with an `absurd` or `False.elim`.

Actually, looking at the code path more carefully: `BurgessR3Maximal_maximality_combined` is trying to prove `NOT (U-cond AND S-cond)`. In the delta.neg-in-B case, we assume U-cond and S-cond and need False. With `dc_delta_B_burgessR3` we can show `burgessR3 A (deductiveClosure ({delta} union B)) C` from U-cond and S-cond. Then `BurgessR3Maximal_extension_fails` needs `SetConsistent ({delta} union B)`. But {delta} union B is INCONSISTENT when delta.neg in B.

So `BurgessR3Maximal_extension_fails` does not directly apply. Instead, we observe: the deductive closure of an inconsistent set is inconsistent (i.e., it contains bot), so `deductiveClosure_is_dcs` would NOT produce a DCS (DCS requires consistency). The DCS property fails. But `BurgessR3Maximal` only prevents proper DCS extensions. If the extension is not a DCS, it does not violate maximality.

**The correct argument for delta.neg-in-B**: Since {delta} union B is inconsistent, DC({delta} union B) is inconsistent. An inconsistent DC is NOT a DCS. No DCS can properly extend B while containing delta (because any such DCS would need to be consistent, but containing both delta and B which contains delta.neg would be inconsistent). This is NOT a violation of maximality. So where is the contradiction?

The contradiction must come from U-cond and S-cond themselves, without the extension argument. Let me revisit: U-cond says for all beta in B, gamma in C: untl(beta AND delta, gamma) in A. With beta = delta.neg: untl(delta.neg AND delta, gamma) in A for all gamma in C. Since delta.neg AND delta |- bot, by BX2: untl(bot, gamma) in A for all gamma in C.

Is `untl(bot, gamma) in A` for ALL gamma in a consistent MCS C contradictory with A being a consistent MCS?

BX7 (linearity): (beta1 U gamma1) AND (beta2 U gamma2) -> (beta1 AND beta2) U (gamma1 AND gamma2) OR ... Taking beta1 = beta2 = bot, gamma1, gamma2 arbitrary from C: (bot U gamma1) AND (bot U gamma2) -> (bot U (gamma1 AND gamma2)) OR ... All disjuncts have guard bot AND bot = bot. So we get bot U STUFF for every STUFF.

BX10: from bot U gamma: F(gamma). So F(gamma) in A for all gamma in C.

Since C is an MCS, it contains both phi and phi.neg for complementary formulas. Well, no -- an MCS contains exactly one of phi or phi.neg for each phi. But for any phi that IS in C, F(phi) in A.

Now: C contains top (tautology). So F(top) in A. This is just a theorem. No contradiction.

C contains phi for some phi, and phi.neg is NOT in C. So F(phi) in A, but nothing about F(phi.neg).

This approach does NOT yield a contradiction from BX10 alone.

**New approach**: Use the A-side S-cond as well. S-cond says: for all beta in B, alpha in A: snce(beta AND delta, alpha) in C. With beta = delta.neg: snce(bot, alpha) in C for all alpha in A.

By BX10' (since_P): snce(bot, alpha) -> P(alpha). So P(alpha) in C for all alpha in A.

Now combine: F(gamma) in A for all gamma in C, AND P(alpha) in C for all alpha in A.

Take gamma_0 in C. F(gamma_0) in A. Then P(F(gamma_0)) in C (by S-cond with alpha = F(gamma_0), since F(gamma_0) in A). This gives P(F(gamma_0)) in C. Similarly, take alpha_0 in A. P(alpha_0) in C. Then F(P(alpha_0)) in A. This generates an infinite sequence but no contradiction.

**Let me try BX4 (connect_future)**: phi -> G(P(phi)). So for any phi in A, G(P(phi)) in A, hence P(phi) in A... wait, G gives all-future, not the present. G(P(phi)) means "at all future times, P(phi)." That does not give P(phi) at the current time.

**Conclusion on the delta.neg-in-B case**: I cannot find a purely syntactic contradiction from U-cond and S-cond when delta.neg in B, using only the available BX axioms under open guard. The old proof used until_guard (which IS sound under half-closed guard). Under open guard, the delta.neg-in-B case may need a DIFFERENT proof structure.

**Recommendation**: The `BurgessR3Maximal_maximality_combined` lemma should be WEAKENED to only handle the delta.neg-NOT-in-B case (which is valid). The delta.neg-in-B case should be handled at the CALL SITE level, where additional context (the chronicle structure) provides the contradiction. Alternatively, strengthen the BurgessR3Maximal definition to require B to be a DCS satisfying some additional property that excludes the problematic case.

### Priority 2: Remove Dead Obligation-Based Infrastructure

Archive to Boneyard:
- `rRelation_of_superset_mcs`, `rRelationSince_of_superset_mcs`
- `rRelation_self_mcs`, `rRelationSince_self_mcs`
- `lemma_2_6_full` (obligation-based version)
- `r3Relation_of_superset_mcs`, `rRelation_of_subset_mcs`
- `B_sub_A_of_burgessR3`, `B_sub_C_of_burgessR3`
- `burgess_D0_elem_in_A_or_C`
- All Failure Mode A lemmas

### Priority 3: Restructure Nested Absorption

Remove `untl_absorb_nested`, `snce_absorb_nested` and their callers (`burgessR3_gamma_not_in_B_nested`, `burgessR3_gamma_not_in_B_since_nested`). The C4 hard case in CounterexampleElimination should use `burgessR3_gamma_not_in_B` directly (which does not require absorption).

### Priority 4: Fix `cantor_bfmcs_restricted_buc`

Mechanical fix: adjust guard bound from le to lt in the archived proof structure. Requires updating the `restricted_backward_until_since_coherent` type signature if it specifies the guard bound.

### Priority 5: Fix `burgess_D0_consistent`

After fixing BurgessR3Maximal_maximality_combined, D0 consistency follows. If the weakened maximality_combined only handles delta.neg-NOT-in-B, then D0 consistency needs delta.neg-NOT-in-B as a hypothesis (which is provided by the Lindenbaum extension context: if delta.neg in B, then delta not in any consistent extension of B that includes delta -- and the D0 seed includes neg-delta which is consistent with this).

## Evidence/Examples

**Paper confirmation**: The paper at lines 1245-1247 defines Until semantics with strictly open guard: `x < y < z` (not `x <= y < z`). This confirms the codebase transition from half-closed to open guard is correct.

**BX10 validity**: `until_implies_F_in_mcs` (RRelation.lean:127) is proved and compiles. This is the primary replacement tool for extracting information from Until formulas under open guard.

**BX5 validity**: `until_self_accum_in_mcs` (RRelation.lean:139) is proved and compiles. Self-accumulation remains sound under open guard.

**burgessR3_gamma_not_in_B validity**: (RRelation.lean:903-912) is proved and compiles. This is the key C4 bridging lemma that works WITHOUT absorption.

**burgessR3_absorption validity**: (RRelation.lean:549-571, 653-667) is proved and compiles. Lemma 2.5 absorption works without guard extraction.

## Confidence Level

**Overall**: HIGH for the diagnostic (what is broken and why). MEDIUM for the BurgessR3Maximal_maximality_combined fix (the delta.neg-in-B case is genuinely hard under open guard). HIGH for the nested absorption removal (burgessR3_gamma_not_in_B handles the C4 case directly).

| Finding | Confidence |
|---------|------------|
| R-relation definitions are sound | HIGH |
| Classification of invalid lemmas | HIGH |
| `untl_absorb_nested` is truly dead | HIGH |
| Nested absorption removal viable | HIGH |
| `rRelation_self_mcs` unnecessary (dead path) | HIGH |
| BurgessR3Maximal_maximality_combined delta.neg case | MEDIUM |
| `burgess_D0_consistent` fix path | MEDIUM |
| `cantor_bfmcs_restricted_buc` mechanical fix | HIGH |
| B-subset-A not needed under open guard | HIGH |

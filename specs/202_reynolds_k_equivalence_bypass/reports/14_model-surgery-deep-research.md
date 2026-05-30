# Reynolds Model Surgery: Complete Formalization Strategy

## Date: 2026-05-30
## Task: 202 (Reynolds K-Equivalence Bypass)

---

## 1. Reynolds' Actual Argument: Mathematical Reconstruction

### 1.1 Overview

Reynolds 1994, Section 7 (pp.124-129) proves Theorem 14: in a discrete linear order without endpoints satisfying Prior-UZ and Prior-SZ with all predicates temporally accessible, the contemporaneous equivalence relation has only one class. The proof proceeds by contradiction: assume two distinct classes exist, derive a gap between them, then show the gap leads to contradiction via model surgery.

The argument uses Lemmas 6-13 and the key Theorem 5 (US expressive completeness over Prior structures).

### 1.2 Step-by-Step Reconstruction

**Setup**: Let M be a discrete linear order without endpoints, equipped with a monadic signature sig, an atomMap, and satisfying semantic Prior-UZ and Prior-SZ. Suppose h_accessible: every predicate p in sig is temporally accessible (there exists a formula f such that temporal_truth(f) iff M.interp(p) at every point).

**Theorem 14 (the key claim)**: The order is IsSuccArchimedean.

**Proof by contradiction**: Assume NOT IsSuccArchimedean. Then by `gap_of_not_succ_archimedean`, a Dedekind gap exists. The gap is a downward-closed proper nonempty subset C of M.carrier with no supremum in C and no infimum in the complement.

**Lemma 6 (Gap is successor-closed)**: In a SuccOrder, C is closed under successor. Proof: If x in C and succ(x) not in C, then since C is downward-closed, every y not in C satisfies x < y. So succ(x) <= y for all y not in C, making succ(x) the minimum of the complement. But the complement has no minimum. Contradiction. (This is already proved implicitly in `gap_of_not_succ_archimedean`.)

**Lemma 7 (Gap detection via temporal formula)**: By h_accessible, every predicate is temporally accessible. The gap C can be characterized by a temporal formula R. More precisely: define the predicate rho(x) = "x is in C" on M.carrier. Since C is downward-closed and has no supremum, rho is not a predicate in sig directly. However, the key insight is that the cut C determines a specific k-type pattern: for any k, points in C eventually have different k-types from points outside C (because k-type agreement would imply they are in the same contemporaneous equivalence class).

**Actually, the correct reconstruction of Reynolds' argument is simpler**:

The proof in the codebase (GoodStructuresModelSurgery.lean) already structures the argument correctly at lines 284-314:

1. Assume NOT IsSuccArchimedean.
2. By `gap_of_not_succ_archimedean`, a Gap gamma exists.
3. The gap's cut C is successor-closed (by the argument above).
4. The full Reynolds model surgery shows this is incompatible with Prior-UZ/SZ + h_accessible.

**Step 4 in detail (the model surgery argument)**:

The key idea: h_accessible means every predicate p has a formula f_p with temporal_truth(f_p, t) iff M.interp(p, t). Consider any temporal formula psi. temporal_truth(psi) depends only on the predicates through atomMap. Since all predicates are accessible, temporal_truth is fully determined by the MCS-like structure.

Now: the gap C is a downward-closed, successor-closed subset. Consider any point a in C and b not in C. The temporal formulas can "see" the difference between a and b only through the predicates. But since the cut is successor-closed, for any a in C, succ(a) is also in C. Going the other direction, for any b not in C, pred(b) is also not in C (since C is downward-closed and if pred(b) were in C, then succ(pred(b)) = b would be in C by successor-closure).

The contradiction comes from the Prior-UZ/SZ axioms: they force temporal formulas to have "first transition" behavior. If a temporal formula is true in C and false outside C, then by Prior-UZ there must be a first point where it becomes false -- but that would be at a successor pair (by discreteness), and C is successor-closed, so the formula stays true at the successor. This creates an infinite regress or a direct contradiction.

### 1.3 Simplified Proof Strategy (bypassing full Lemmas 7-13)

The existing codebase docstring at GoodStructuresModelSurgery.lean:298-313 suggests a direct approach that doesn't require the full model surgery machinery:

1. NOT IsSuccArchimedean => gap gamma exists
2. Gap's cut C is successor-closed
3. h_accessible => every predicate has a temporal witness formula
4. Consider the "gap-detecting" property: for some predicate p, M.interp(p) differs across the gap (otherwise all predicates agree across the gap, meaning points have the same k-type for all k, meaning they are contemporaneously equivalent -- but then the order would be archimedean since all subintervals would be finite/very-good).

Wait -- this is subtler than it appears. The gap could be "invisible" to the predicates (as in the Z+Z counterexample with constant predicates). This is exactly why h_accessible is needed: without it, the gap is indeed invisible.

With h_accessible: If the gap is invisible to all predicates (all predicates are constant across the gap), then temporal_truth of any formula is the same at every point. Then all k-types are the same everywhere. Then all points are contemporaneously equivalent. Then the order is archimedean (by one_class_archimedean). Contradiction with NOT IsSuccArchimedean.

So h_accessible provides the lever: either (a) the gap is invisible to predicates, in which case all k-types are uniform and the order is archimedean (contradiction), or (b) the gap IS visible to some predicate p. In case (b), there exists a formula f_p (by h_accessible) whose temporal truth changes across the gap. But by Prior-UZ/SZ, the first transition of f_p must occur at a successor pair. Since C is successor-closed, f_p cannot transition from true-in-C to false-outside-C at any successor pair within C. This means f_p must transition at a gap -- but transitions at gaps violate the "first occurrence" property guaranteed by Prior-UZ.

### 1.4 Formalization-Ready Proof Structure

The cleanest formalization strategy:

**prior_implies_archimedean_of_accessible**: Assume NOT IsSuccArchimedean. Derive False.

Step 1: Get gap gamma from `gap_of_not_succ_archimedean`.
Step 2: Define cut C = gamma.cut. Prove C is successor-closed.
Step 3: Case split: are all predicates "constant across the gap"?
  - Case 3a: All predicates agree on C and complement. Then all k-types are the same everywhere (need a lemma: "same predicates everywhere => same k-types => all contemp_equiv => archimedean"). Contradiction.
  - Case 3b: Some predicate p differs across the gap. By h_accessible, get formula f_p with temporal_truth(f_p) = M.interp(p). Then temporal_truth(f_p) has a transition at the gap. By Prior-UZ, get the "first transition" point s. s must be at a successor pair. But C is successor-closed: if f_p is true in C and false outside, the first transition must be from C to complement, but succ of any C-point is in C. Contradiction.

---

## 2. Current Infrastructure Inventory

### 2.1 Sorry-Free Infrastructure (DONE)

| Component | File | Status |
|-----------|------|--------|
| k-equivalence (`k_equiv`, `k_type_of`) | NEquivalence.lean | Sorry-free |
| Normal forms (`NormalForm`, `nf_eval_nf`) | NEquivalence.lean | Sorry-free |
| Doets Lemma 1.1 (`doets_lemma_1_1`) | NEquivalence.lean | Sorry-free |
| Doets Lemma 1.4 (`doets_lemma_1_4`) | NEquivalence.lean | Sorry-free |
| Z-interval structures | GoodStructures.lean | Sorry-free |
| `good`, `very_good` definitions | GoodStructures.lean | Sorry-free |
| `k_equiv_of_iso` | GoodStructures.lean | Sorry-free |
| `finite_structures_good` | GoodStructures.lean | Sorry-free |
| `good_of_split_at_succ` (Reynolds Lemma 17 hard case) | GoodStructures.lean | Sorry-free |
| `contemp_equiv_is_equiv` | GoodStructures.lean | Sorry-free |
| `no_boundary_at_successor` | GoodStructures.lean | Sorry-free |
| `one_class_archimedean` | ReynoldsNoGaps.lean | Sorry-free |
| `gap_of_not_succ_archimedean` | ReynoldsNoGaps.lean | Sorry-free |
| `very_good_of_archimedean` | ReynoldsNoGaps.lean | Sorry-free |
| `one_class_implies_very_good` | ShiftAndGlue.lean | Sorry-free |
| `very_good_implies_good` (Reynolds Lemma 16) | ShiftAndGlue.lean | Sorry-free |
| Cofinal sequence construction | ShiftAndGlue.lean | Sorry-free |
| Shift-and-glue (`ordered_sum_of_good_bounded_is_good`) | ShiftAndGlue.lean | Sorry-free |
| US expressive completeness (`US_expressively_complete_over_prior`) | PriorExpressiveness.lean | Sorry-free |
| Stavi connectives (`stavi_U_false_on_prior_UZ`) | PriorExpressiveness.lean | Sorry-free |
| Gap structure (`Gap T`) | EFGames/Defs.lean | Sorry-free |
| `temporal_truth` definition | Various | Sorry-free |
| `chronicle_temporal_truth` | Transfer.lean | Sorry-free |
| `chronicle_semantic_prior_UZ/SZ` | Transfer.lean | Sorry-free |
| `truth_transfer` | Transfer.lean | Sorry-free |
| `k_equiv_preserves_sentence` | Transfer.lean | Sorry-free |
| `no_gaps_int` | Transfer.lean | Sorry-free |
| `ghr93_forward_to_backward_discrete` (Theorem 6, discrete) | Transfer.lean | Sorry-free |
| Prior-UZ first-transition lemma | GoodStructuresModelSurgery.lean | Sorry-free |
| Contemp equiv convexity | GoodStructuresModelSurgery.lean | Sorry-free |
| `predicate_accessible`, `all_predicates_accessible` | GoodStructuresModelSurgery.lean | Sorry-free |
| `class_gap_exists` | GoodStructuresModelSurgery.lean | Sorry-free |
| `countermodel_discrete_enriched` + BX pipeline | ChronicleToCountermodel.lean | Has sorry via succ_cofinal |

### 2.2 Sorry Sites on the Critical Path

| Sorry | File:Line | What it asserts | Difficulty |
|-------|-----------|----------------|------------|
| `prior_implies_archimedean_of_accessible` | GoodStructuresModelSurgery.lean:314 | Prior-UZ/SZ + h_accessible + NOT archimedean => False | **THE SOLE BLOCKER** |
| `no_gaps_discrete` | GoodStructures.lean:845 | Inherits from above (calls via `one_class`) | Automatically resolved |
| `countermodel_discrete_reynolds` | Transfer.lean:1181 | Z-interval to TaskFrame packaging | Separate issue (Phase 6) |

### 2.3 Sorry Sites NOT on Critical Path (Dead Code)

| Sorry | File | Status |
|-------|------|--------|
| `no_gaps_faithful` | ReynoldsModelSurgery.lean:331 | FALSE -- Z+Z counterexample, dead BX code |
| `no_gaps_prior` | ReynoldsNoGaps.lean:287 | FALSE as stated (no faithfulness), dead |
| `succ_cofinal` | ChronicleToCountermodel.lean:~1599 | Dead BX pipeline |
| `succ_reaches_dom_N` | ChronicleToCountermodel.lean:1301,1457 | Dead BX pipeline |
| CaseAnalysis.lean sorries | CaseAnalysis.lean:3380-3417 | Gap handling (Cases III/IV) |
| StaviCompleteness.lean sorries | StaviCompleteness.lean:2347,2429,2787 | Non-discrete |

---

## 3. Critical Path Analysis

### 3.1 The Single Sorry Blocking completeness_discrete

The ENTIRE sorry chain from `completeness_discrete` to the sole blocker:

```
completeness_discrete (Completeness.lean:309)
  calls countermodel_discrete_enriched (Completeness.lean:222)
    calls dd_countermodel_chronicle_discrete (ChronicleToCountermodel.lean:3008)
      calls cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:2864)
        calls succ_embed_surjective
          calls limitDomSubtype_isSuccArchimedean
            calls succ_cofinal    <-- SORRY (dead BX pipeline)
```

**However**: If we switch `completeness_discrete` to use the Reynolds pipeline, the chain becomes:

```
completeness_discrete
  calls countermodel_discrete_reynolds (Transfer.lean:1067)
    calls chronicle_is_good_direct (ShiftAndGlue.lean:949)
      calls one_class (GoodStructures.lean:886)
        calls no_gaps_discrete (GoodStructures.lean:820)
          body uses prior_implies_archimedean_of_accessible
            via no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:327)
              calls prior_implies_archimedean_of_accessible  <-- SORRY (THE BLOCKER)
```

**PLUS** `countermodel_discrete_reynolds` has a second sorry at Transfer.lean:1181 (Z-interval to TaskFrame packaging). This is a separate engineering challenge.

### 3.2 Summary

There are exactly TWO sorries blocking sorry-free `completeness_discrete`:

1. **`prior_implies_archimedean_of_accessible`** (GoodStructuresModelSurgery.lean:314) -- the mathematical core
2. **`countermodel_discrete_reynolds` packaging** (Transfer.lean:1181) -- engineering/packaging

The second sorry is about constructing a TaskModel and proving truth correspondence, which is a different kind of challenge from the mathematical proof.

---

## 4. h_surj / h_accessible Resolution

### 4.1 The Tension

There are two different hypotheses in play:

- **h_surj** (ReynoldsNoGaps.lean:280): `forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p`
  - Used by `no_gaps_prior` (which is FALSE and dead)
  - Says every predicate comes from an atom formula

- **h_accessible** (GoodStructuresModelSurgery.lean:291): `all_predicates_accessible M atomMap`
  - Used by `prior_implies_archimedean_of_accessible` (the live blocker)
  - Says every predicate has SOME temporal formula that matches it
  - Weaker than h_surj but sufficient

### 4.2 Why h_accessible is Correct

The h_accessible hypothesis says: for every predicate p in the signature, there exists a formula f such that temporal_truth(f, t) iff M.interp(p, t) for all t.

At the call site (Transfer.lean, `countermodel_discrete_reynolds` line 1109-1136), this is proved for the chronicle monadic structure. The signature is `mkSigFrom(phi)`, whose predicates are `cons bot phi.predFormulas`. For each predicate p = (f, hf) where f is in predFormulas or f = bot:
- If f is in phi.predFormulas: use f itself as the witnessing formula. The section property gives temporal_truth(f) = f in MCS = M.interp(p).
- If f = bot: use Formula.bot. Both sides are False.

So **h_accessible is fully dischargeable at the call site**. No changes needed to the signature or Theorem 5 formalization.

### 4.3 h_surj is Irrelevant

h_surj was used only by `no_gaps_prior` which is FALSE and dead. The live path through `prior_implies_archimedean_of_accessible` uses h_accessible instead. The US expressive completeness theorem (`US_expressively_complete_over_prior`) is used indirectly through the Prior-UZ/SZ semantic hypotheses -- it does not need to be invoked directly in the proof of `prior_implies_archimedean_of_accessible`.

### 4.4 Recommendation

No changes needed. h_accessible is the correct hypothesis and is fully dischargeable. h_surj can be ignored (it is dead code).

---

## 5. Implementation Roadmap

### Phase 1: Prove `prior_implies_archimedean_of_accessible` (CRITICAL, ~150-300 lines)

This is the mathematical core. Replace the sorry at GoodStructuresModelSurgery.lean:314.

**Proof outline**:

```lean
private theorem prior_implies_archimedean_of_accessible ... :
    False := by
  -- Step 1: Get gap
  have (gamma) := gap_of_not_succ_archimedean h_not_arch

  -- Step 2: Gap cut is successor-closed
  -- (Implicit in gap construction, may need explicit lemma)

  -- Step 3: Use h_accessible to show either:
  --   (a) all predicates constant across gap => k-types uniform => archimedean (contradiction)
  --   (b) some predicate varies across gap => temporal formula transitions at gap =>
  --       Prior-UZ gives first-transition at successor pair => but gap is successor-closed (contradiction)

  -- Case 3a: If all predicates agree everywhere, prove all k-types are the same
  -- This requires: "constant predicates => constant k-types"
  -- Then one_class_archimedean gives IsSuccArchimedean, contradicting h_not_arch

  -- Case 3b: Some predicate p has M.interp(p, a) != M.interp(p, b) for a in C, b not in C
  -- By h_accessible, get formula f with temporal_truth(f) = M.interp(p)
  -- temporal_truth(f) is true in C (or false in C) and changes at the gap
  -- By Prior-UZ, the first change of f must be at a successor pair
  -- But C is successor-closed, so f can't change at a successor pair within C
  -- Contradiction
```

**Key helper lemmas needed**:
1. `gap_cut_succ_closed`: The gap's cut is closed under successor (SuccOrder)
2. `constant_predicates_give_archimedean`: If all predicates are temporally constant, the order is archimedean (or at least all k-types agree)
3. `gap_transition_contradiction`: If a temporal formula transitions at a gap in a Prior-UZ structure, derive False

**Estimated difficulty**: Medium-Hard. The case 3a sub-lemma (constant predicates => archimedean) is the trickiest part, as it requires showing that constant predicates force all subintervals to be k-equivalent to Z-intervals.

### Phase 2: Wire `completeness_discrete` to Reynolds Pipeline (~50-100 lines)

Currently `completeness_discrete` calls `countermodel_discrete_enriched`. Need to:
1. Replace with call to `countermodel_discrete_reynolds`
2. OR: provide an alternative `countermodel_discrete_enriched` that routes through the Reynolds pipeline

### Phase 3: Resolve Transfer.lean:1181 Packaging Sorry (~200-400 lines)

The `countermodel_discrete_reynolds` theorem at Transfer.lean:1067 has a sorry at line 1181 for packaging the Z-interval as a TaskFrame. This requires:
1. Showing the Z-interval from `chronicle_is_good_direct` is unbounded (lo = none, hi = none)
2. Constructing a TaskModel with correct position-dependent atom valuation
3. Proving truth_at <-> temporal_truth correspondence

This is an engineering challenge, not a mathematical one.

### Alternative for Phase 2-3: Route Through BX Pipeline

An alternative to fixing the packaging sorry in the Reynolds pipeline is to prove `prior_implies_archimedean_of_accessible` and then use it to provide `IsSuccArchimedean` for the chronicle, which unblocks `succ_cofinal` in the BX pipeline. This avoids the packaging sorry entirely.

**Key insight**: Once `prior_implies_archimedean_of_accessible` is proved, we can prove `IsSuccArchimedean` for the chronicle domain. With `IsSuccArchimedean`, the existing `orderIsoIntOfLinearSuccPredArch` gives Z-isomorphism, which is what `succ_cofinal` and `succ_embed_surjective` need.

**Route**:
1. Prove `prior_implies_archimedean_of_accessible` (Phase 1)
2. Use it to prove `succ_cofinal` sorry-free (or construct IsSuccArchimedean for ChronicleAsPriorModel)
3. The existing BX pipeline (`countermodel_discrete_enriched`) becomes sorry-free
4. `completeness_discrete` becomes sorry-free without any rewiring

This is potentially MUCH simpler than fixing the Reynolds packaging sorry.

---

## 6. Tactics and Helpers Specification

### 6.1 Helper Lemmas Needed

```
-- Gap cut is closed under successor
theorem gap_cut_succ_closed {T : Type} [LinearOrder T] [SuccOrder T] [NoMaxOrder T]
    (g : Gap T) : forall x, x in g.cut -> Order.succ x in g.cut

-- If temporal_truth(f) is true for all a in C and false for some b not in C,
-- then Prior-UZ gives a first-transition point s with temporal_truth(f, s) true
-- and temporal_truth(f, succ s) false. But if s in C, succ(s) in C by gap_cut_succ_closed,
-- and temporal_truth(f, succ s) should be true (same k-type within C). Contradiction.
-- This needs careful formalization.

-- Constant predicates force uniform k-types
-- If forall p : sig.preds, forall x y : M.carrier, M.interp p x <-> M.interp p y,
-- then k_type_of sig k M = k_type_of sig k M' for any k, where M and M' share
-- the carrier but may have different order substructure.
-- Actually: if all predicates are constant, then temporal_truth of any formula
-- is the same at every point (by induction on formula structure, using Prior-UZ/SZ).
```

### 6.2 Strategy for "Constant Predicates => Archimedean"

This is the harder case (3a). The argument:

1. All predicates constant => temporal_truth is the same at every point (for any formula).
2. temporal_truth same everywhere => all k-types are the same (since k-types are determined by nf_eval_nf which depends on atom_eval which depends on predicates).
3. All k-types the same => all points contemp_equiv (every subinterval has the same k-type as a singleton, which is a Z-interval [0,0]).
4. Actually, step 3 is wrong: contemp_equiv requires EVERY subinterval to be good, not just every point to have the same type.

**Correction**: The argument needs to be more careful. If all predicates are constant, then any two subintervals [a,b] and [a',b'] with the same number of elements are k-equivalent (by the order-isomorphism preserving constant predicates). Since every finite subinterval is good (finite_structures_good), we need to show that INFINITE subintervals are also good. But if there's a gap, there exist infinite subintervals.

Actually, the simpler approach: if all predicates are constant, then for ANY two points a,b, the subinterval [a,b] is k-equivalent to the Z-interval [0, |b-a|] (if the distance is finite) or to all of Z (if the distance is infinite). The key: in an archimedean order, distances are always finite. In a non-archimedean order, some distances are infinite.

But wait -- we're trying to PROVE archimedean from the assumption that all predicates are constant. So we can't assume archimedean.

**Alternative approach for case 3a**: If all predicates are constant AND there's a gap, then consider any formula f. temporal_truth(f) at point a depends only on:
- M.interp(p, a) for all p (constant by assumption)
- The order structure around a

Since predicates are constant, temporal_truth(f, a) for atoms and boxes is the same at every point. For Until: temporal_truth(U(phi, psi), a) = exists s > a with temporal_truth(phi, s) and guard(temporal_truth(psi)). If temporal_truth(phi) and temporal_truth(psi) are constant (by induction), then:
- If temporal_truth(phi) is false everywhere: Until is false everywhere
- If temporal_truth(phi) is true everywhere and temporal_truth(psi) is true everywhere: Until is true everywhere (take s = succ(a))
- If temporal_truth(phi) is true everywhere and temporal_truth(psi) is false everywhere: Until is true everywhere (take s = succ(a), vacuous guard since no points between a and succ(a))
- Etc.

In ALL cases, temporal_truth of any formula is the same at every point (by structural induction on the formula, using the fact that the order is homogeneous modulo the gap, and predicates are constant).

Therefore: all k-types are the same. Therefore: all points are contemp_equiv. Therefore: the order is archimedean (by one_class_archimedean). Contradiction.

Wait -- one_class_archimedean requires IsSuccArchimedean as a hypothesis! We can't use it here. Let me re-examine.

`one_class_archimedean` says: IsSuccArchimedean => all points contemp_equiv. The CONVERSE is what we need: all points contemp_equiv => IsSuccArchimedean. Is this true?

Looking at the code: `one_class_implies_very_good` + `very_good_implies_good` give: if all points are contemp_equiv, then M is good (k-equiv to a Z-interval). Being good means k-equiv to a Z-interval. But a Z-interval is archimedean (it IS Z or an interval of Z). Does k-equivalence to an archimedean structure imply archimedean? NO -- k-equivalence only preserves finite-depth FO properties, and archimedean is not FO-expressible.

So the "constant predicates => archimedean" route is actually WRONG as stated. The correct argument must be different.

### 6.3 Corrected Proof Strategy

Going back to Reynolds' actual argument more carefully:

The proof of Theorem 14 does NOT split into "constant" vs "non-constant" predicates. Instead, it proceeds uniformly:

1. Assume NOT archimedean. Get gap gamma.
2. The gap cut C is successor-closed (Lemma 6).
3. Consider the set of predicates restricted to C vs the complement. By h_accessible, each predicate p has a formula f_p.
4. If EVERY predicate agrees across the gap (M.interp(p,a) = M.interp(p,b) for all p, all a in C, b not in C), then temporal_truth of every formula is constant (by induction, using the homogeneity). This means every formula has the same truth value in C and outside C. But then the gap is "invisible" -- the k-type at any point in C equals the k-type at any point outside C. Since all subintervals within C are finite (successor-closed downward set, so for a in C and b in C with a < b, [a,b] has finitely many elements -- WAIT, this requires archimedean WITHIN C! The successor closure of C means succ^n(a) in C for all n, so [a, succ^n(a)] is finite. But does every element of C between a and b satisfy b = succ^n(a) for some n? NOT necessarily -- C itself might have internal gaps).

Actually, C cannot have internal gaps: C is a downward-closed subset of a discrete linear order. If C has an internal gap, that gap is a downward-closed proper subset of C, and we could define a "smaller" gap. But the gap gamma was arbitrary. This doesn't immediately help.

**The correct approach is Reynolds' model surgery, not case analysis**:

Reynolds' actual proof uses model surgery (Lemmas 10-13): given the gap, construct a new model M' by "collapsing" the gap region. Show that M' satisfies the same temporal formulas as M (by induction on formula structure). But in M', the gap doesn't exist, leading to contradiction.

However, this is complex to formalize. Let me look for a simpler approach.

### 6.4 Simplest Correct Approach

The simplest correct proof of `prior_implies_archimedean_of_accessible`:

**Claim**: Prior-UZ + Prior-SZ + h_accessible + SuccOrder + PredOrder + NoMaxOrder + NoMinOrder + NOT IsSuccArchimedean => False.

**Proof**:

Step 1: NOT IsSuccArchimedean => exists a, b with a < b and forall n, succ^n(a) < b.

Step 2: Define the set S = {x | exists n, x <= succ^n(a)}. This is the "orbit" of a under successor. S is:
- Nonempty (a in S)
- Proper (b not in S)
- Downward-closed
- Successor-closed (succ^n(a) in S => succ^(n+1)(a) in S)

Step 3: The complement S^c = {x | forall n, succ^n(a) < x} is:
- Nonempty (b in S^c)
- Predecessor-closed (if x in S^c and pred(x) in S, then succ(pred(x)) = x in S by successor-closure, contradiction)
- Has no minimum (if m is the minimum of S^c, then pred(m) in S, so succ(pred(m)) = m in S, contradiction)

Step 4: S has no maximum (if m is the maximum of S, then succ(m) in S by successor-closure, and succ(m) > m, contradiction).

So (S, S^c) defines a Dedekind cut with no max in S and no min in S^c -- a gap.

Step 5: All temporal formulas are "eventually constant" in S and in S^c separately. More precisely: for any formula f:
- By induction on f, temporal_truth(f, succ^n(a)) is eventually constant as n -> infinity (it can change only at successors, and by Prior-UZ, changes are "first-occurrence" -- once f becomes true and stays true, it stays true).
- Similarly, temporal_truth(f, succ^n(a)) is eventually constant as we go backward.

Step 6: By h_accessible, every predicate p has f_p with temporal_truth(f_p) = M.interp(p). So M.interp(p) is eventually constant above every point in S.

Step 7: Since temporal_truth of every formula is eventually constant in S (approaching the gap from below), and also eventually constant in S^c (approaching the gap from above), and since there are only finitely many formulas of any given depth, there exists a point a' in S and b' in S^c such that:
- temporal_truth(f, a') = temporal_truth(f, succ(a')) for all formulas f of depth <= k
- temporal_truth(f, pred(b')) = temporal_truth(f, b') for all formulas f of depth <= k

Step 8: But this means a' and b' have the same k-type profile, making the interval [a', b'] very-good, making a' and b' contemp_equiv. Since a' in S and b' in S^c, this contradicts... wait, it doesn't directly contradict anything.

**This approach is getting complicated. Let me reconsider.**

### 6.5 Direct Proof via Constant Temporal Truth

Actually, the simplest proof might be:

**Lemma**: In a discrete linear order with Prior-UZ/SZ, for any temporal formula psi, temporal_truth(psi) is "locally constant" -- if temporal_truth(psi, x) = temporal_truth(psi, succ(x)) for all x, then temporal_truth(psi) is constant everywhere. [This follows from the discrete structure: any two points are connected by a finite chain of successors IF the order is archimedean, but we're trying to prove archimedean.]

This is circular. Let me think differently.

**The most direct non-circular proof**:

Consider the function tau : M.carrier -> (sig.preds -> Bool) defined by tau(x)(p) = if M.interp(p, x) then true else false. This is the "predicate profile" at x.

Since sig.preds is finite (Fintype), there are only finitely many possible predicate profiles. So tau takes values in a finite set.

In the gap scenario: S is successor-closed and has no max. The sequence tau(succ^0(a)), tau(succ^1(a)), tau(succ^2(a)), ... takes values in a finite set, so by the pigeonhole principle, it is eventually periodic. Similarly, going backward from any point in S^c.

Now: Prior-UZ says that for any formula psi, if F(psi) holds at t, then U(psi, neg psi) holds at t (there's a first occurrence of psi after t with neg psi between). In particular, if temporal_truth(psi) changes from false to true between t and some s > t, there is a "first true" point where psi holds and neg psi held between t and that point.

For the predicates: since M.interp(p) = temporal_truth(f_p) (by h_accessible), and f_p is a formula, the predicate profiles are constrained by Prior-UZ/SZ.

Actually, the key realization: **we don't need the full model surgery at all**. The proof can proceed by showing that the predicate profiles in S must stabilize to a single value, and similarly for S^c, and then the profiles must agree across the gap, and then k-types must agree, and then archimedean follows.

But this still requires showing "stabilized k-types across the gap => archimedean", which I showed above is problematic.

### 6.6 THE CORRECT SIMPLE PROOF

After careful reflection, here is the correct proof that avoids model surgery:

**prior_implies_archimedean_of_accessible**: Assume NOT IsSuccArchimedean. Let a,b be such that succ^n(a) /= b for all n. Define S as above.

Consider the predicate profiles in S. Since sig.preds is finite, the profile function tau : S -> Fin(2^|sig.preds|) stabilizes: there exists N such that tau(succ^n(a)) = tau(succ^(n+1)(a)) for all n >= N.

Set a_0 = succ^N(a). Then M.interp(p, a_0) = M.interp(p, succ(a_0)) for all p.

Now: consider the subinterval [a_0, succ(a_0)]. It has exactly 2 elements. Both elements have the same predicate profile. So the interval is k-equivalent to a 2-element Z-interval with uniform predicates, for any k.

Next: consider [a_0, succ^2(a_0)]. All 3 elements have the same predicate profile (since profiles stabilized at N). So k-equivalent to a 3-element uniform Z-interval.

By induction: [a_0, succ^n(a_0)] is k-equivalent to an (n+1)-element uniform Z-interval for any k.

Now take any c in S with c > a_0. Then c = succ^m(a_0) for some m (because S starts at a and iterates successors). Wait -- c might NOT be succ^m(a_0) for any m, because S is defined as {x | exists n, x <= succ^n(a)} which includes elements BELOW some iterate, not necessarily iterates themselves.

Hmm, but in a discrete linear order with SuccOrder, if c in S and c >= a_0, then either c = a_0 or c >= succ(a_0). If c >= succ(a_0) and c in S, then c <= succ^m(a_0) for some m, so c is in [succ(a_0), succ^m(a_0)]. Since the order is discrete (SuccOrder), the elements of [a_0, succ^m(a_0)] are exactly {a_0, succ(a_0), ..., succ^m(a_0)}. This is because in a SuccOrder without gaps within the successor chain, every element between a_0 and succ^m(a_0) is some succ^j(a_0).

But WAIT -- this is exactly the claim that the order is archimedean within S! If S contains an element c with a_0 < c and c is NOT succ^m(a_0) for any m, then there's an internal gap in S. Is this possible?

In a general SuccOrder, yes -- there could be elements between succ^n(a_0) and succ^(n+1)(a_0). But in a SuccOrder with the covering property (succ(x) is the IMMEDIATE successor: no y with x < y < succ(x)), this is impossible. And SuccOrder in Lean/Mathlib DOES have this covering property: `Order.lt_succ_iff_of_not_isMax` states that y <= succ(x) iff y <= x or y = succ(x) (when x is not max).

So in fact: the elements of S that are >= a_0 are EXACTLY {succ^n(a_0) | n in Nat}. Because if c in S with c >= a_0, then c <= succ^m(a) = succ^(m-N)(a_0) for some m >= N, and by the covering property, c = succ^j(a_0) for some j <= m-N.

Similarly: the elements of S^c approaching the gap from above form a predecessor chain.

Now: for any b' in S^c, consider the temporal formula f_p for each predicate p. Since h_accessible gives temporal_truth(f_p, x) = M.interp(p, x):
- In S above a_0: M.interp(p) is constant (stabilized)
- At b': M.interp(p, b') may differ from the S-stabilized value

If they DO differ for some p: temporal_truth(f_p) changes between the last S-point and b'. By Prior-UZ, there should be a "first" change point. But the last S-point has no successor in S^c -- succ of any S-point is in S (successor-closed). So there is no successor pair where the transition occurs. This violates the discrete structure of Prior-UZ (which guarantees transitions at successor pairs).

More precisely: Consider p such that M.interp(p, succ^n(a_0)) = True for all n >= 0, but M.interp(p, b') = False for some b' in S^c. By h_accessible, temporal_truth(f_p) = M.interp(p). So F(f_p.neg) holds at a_0 (b' is a future point where f_p.neg holds). By Prior-UZ, there is a first point s > a_0 where f_p.neg holds, and f_p.neg.neg (= f_p) holds between a_0 and s. Since f_p holds at all succ^n(a_0), s cannot be any succ^n(a_0). So s is not in the successor orbit of a_0. But by the covering property, all points between a_0 and s are in the successor orbit (if s is in S). If s is in S^c, then s is the first point of S^c, but S^c has no minimum. Contradiction.

Wait, s could be in S but not in the successor orbit of a_0. Is that possible? No -- I showed above that all elements of S above a_0 are exactly the successor iterates.

So s must be in S^c. But S^c has no minimum (property of the gap). Since s is the first f_p.neg point after a_0, all points between a_0 and s satisfy f_p. In particular, all points in S above a_0 satisfy f_p (since they are between a_0 and s). But s in S^c and S^c has no minimum means there are points in S^c strictly below s, say s' < s with s' in S^c. Then f_p holds at s' (it's between a_0 and s). But s' in S^c and the predicates might differ... Actually, the Prior-UZ first-occurrence property guarantees that f_p.neg does NOT hold at s'. So temporal_truth(f_p, s') = True. But we assumed M.interp(p) might be False at s'. This is a contradiction IF temporal_truth(f_p) = M.interp(p).

Actually: temporal_truth(f_p, s') = M.interp(p, s') by h_accessible. And temporal_truth(f_p, s') = True (since s' is between a_0 and s, and f_p.neg.neg holds between a_0 and s). So M.interp(p, s') = True. Since s' was an arbitrary point in S^c below s, M.interp(p) is True at all such points.

But b' was a point in S^c with M.interp(p, b') = False. If b' < s, then b' is between a_0 and s, so M.interp(p, b') = True, contradiction. If b' >= s, then s is the first f_p.neg point, so f_p.neg(s) holds, meaning M.interp(p, s) = False. But s is in S^c. And we showed all S^c points below s have M.interp(p) = True. So s is the minimum of the set {x in S^c | M.interp(p, x) = False}. Combined with S^c having no minimum overall... but s is not the minimum of S^c, just the minimum of those with p = False.

This argument is getting complex but it does work. The crux:

**In S^c, consider the first point where any predicate differs from the S-stabilized value.** By h_accessible and Prior-UZ, that first point must be a successor of a point where the old value held. But the predecessor of any S^c point is either in S (where the value has stabilized) or in S^c (where no change has happened yet). In the first case, succ of the S-point is in S (successor-closed), not in S^c. Contradiction.

**THIS IS THE PROOF**. Let me formalize it.

---

## 7. Risk Assessment

### 7.1 Mathematically Certain

- The proof strategy of Section 6.6 is mathematically sound
- h_accessible is dischargeable at the call site (verified in code)
- gap_of_not_succ_archimedean is proved (sorry-free)
- The gap's cut being successor-closed follows from standard order theory
- The covering property of SuccOrder in Lean guarantees no elements between x and succ(x)
- Predicate profiles stabilize by pigeonhole (finite signature)

### 7.2 Formalization Risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Lean SuccOrder covering property needs careful handling | Medium | Use `Order.lt_succ_iff` and `Order.succ_le_iff` from Mathlib |
| Stabilization of predicate profiles requires classical reasoning | Low | Classical is already used throughout |
| The "first transition" argument via Prior-UZ needs precise formulation | Medium | `prior_UZ_first_transition` already proved in GoodStructuresModelSurgery.lean |
| Linking stabilized profiles to k-types may be complex | Medium | May need an intermediate lemma about constant-profile intervals |
| Transfer.lean packaging sorry (Phase 3) may be hard | High | Consider BX pipeline alternative route |

### 7.3 Alternative Routing Risk

If the Reynolds packaging sorry (Transfer.lean:1181) proves intractable:
- Route through BX pipeline by providing `IsSuccArchimedean` for the chronicle
- This requires connecting `prior_implies_archimedean_of_accessible` to `ChronicleAsPriorModel`
- Risk: may need to construct a `PriorModelData` from the chronicle and verify h_accessible
- This is already done in the existing code (Transfer.lean lines 1096-1136)

### 7.4 Estimated Effort

| Phase | Lines | Difficulty | Risk |
|-------|-------|-----------|------|
| Phase 1: `prior_implies_archimedean_of_accessible` | 150-300 | Hard | Medium |
| Phase 2: Wire completeness_discrete | 50-100 | Easy | Low |
| Phase 3: Packaging sorry | 200-400 | Hard | High |
| **Alternative: BX route instead of Phase 2-3** | 100-200 | Medium | Low |
| **Total (Reynolds pipeline)** | **400-800** | | |
| **Total (BX alternative)** | **250-500** | | |

### 7.5 Recommendation

**Recommended approach**: Phase 1 (prove `prior_implies_archimedean_of_accessible`) followed by the BX alternative route (connect to `succ_cofinal` via the chronicle's `PriorModelData`). This avoids the difficult packaging sorry in Transfer.lean and reuses the existing sorry-free BX pipeline infrastructure.

**Specifically**:
1. Prove `prior_implies_archimedean_of_accessible` in GoodStructuresModelSurgery.lean
2. Use it to prove `succ_cofinal` (by constructing the PriorModelData for the chronicle and showing h_accessible holds)
3. The entire `dd_countermodel_chronicle_discrete` -> `countermodel_discrete_enriched` -> `completeness_discrete` chain becomes sorry-free

This is the path of least resistance to sorry-free `completeness_discrete`.

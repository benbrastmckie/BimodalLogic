# Teammate A Findings: Reynolds 1994 Proof Structure

## 1. Step-by-Step Reconstruction of Reynolds' Theorem 15 Proof

### Context (Section 8, p.130-131)

Reynolds Theorem 15 states: If M is a countable, discrete, no-endpoint temporal structure in a finite language satisfying Prior-UZ and Prior-SZ, then for all k < omega, there exists a Z-flowed structure k-equivalent to M.

The proof has two layers: the "very good implies good" layer (Lemma 16) and the "all points are in one contemp_equiv class" layer (Theorem 15 punchline). Here is how each step works:

### Step A: Definitions (p.130)

1. **Good**: M is good iff there exists N ~k M whose flow of time is an interval of Z.
2. **Very good**: M is very good iff for all t <= u in M, M|[t,u] is good.
3. **~M relation** (Lemma 17): a ~M b iff a = b, or a < b and M|[a,b] is very good, or b < a and M|[b,a] is very good.

### Step B: Lemma 16 — Very good implies good

If N is countable and very good, then it is good.

**Proof method**: Choose a cofinal sequence a_0 < a_1 < ... covering N. Each bounded piece M|[a_i, a_{i+1}-1] is good (by very_good). Take Z_i ~k M|[a_i, a_{i+1}-1] with Z-interval flow. Then lexicographic sum gives N ~k sum(Z_i), whose flow is a (half-)interval of Z. Handle the no-beginning, no-ending, both-endpoints, neither-endpoints cases by symmetric argument.

### Step C: Lemma 17 — ~M is a contemporaneous equivalence relation

~M is: (1) reflexive (trivially), (2) symmetric (by min/max symmetry), (3) transitive (hard case: a < t < b < u < c, decompose at b/succ(b), apply doets_lemma_1_4). The classes are intervals. ~M is contemporaneous because the definition uses exactly the right substructure.

### Step D: Theorem 14 — Classes don't end at gaps

This is the heavy lifting (Lemmas 6-13 in Section 7). The argument: suppose class(a) ends at a gap on the right. Construct temporal formula R detecting right_gap_class. By Prior-UZ/SZ, R is constant on M (cannot transition at successor pairs because ~M is transitive across successors). This R being true everywhere implies all classes are "right gap classes." Perform model surgery: restrict M to class(a), getting N. Prove temporal truth preservation (M iff N at class(a) points). In N, there is only one class, so right_gap_class_formula is false. But truth preservation says R is true. Contradiction.

### Step E: Theorem 15 Punchline (bottom of p.131)

This is the SHORT argument that uses Theorem 14:

1. If M is good, done.
2. So suppose M is not good. Then M is not very good.
3. So there exist a < b in M with M|[a,b] not good.
4. Since M|[a,b] is not good, it is not very good (good implies very good is false here because "not good" means the structure itself fails; the key is that a non-good subinterval witnesses two distinct ~M classes).
5. So there exist two disjoint ~M classes within M.
6. Consider a's class. By Theorem 14, a's class cannot end at a gap.
7. So a's class must include a point c but NOT c+1 (successor boundary).
8. But M|[c, c+1] is a finite structure (two elements), hence very good.
9. Since c and c+1 are both in the very-good interval, they are in the same ~M class by transitivity.
10. This contradicts step 7. QED.

**CRITICAL OBSERVATION**: The argument in step 6-10 operates on the FULL structure M. It does NOT try to show contemp_equiv fails on a bounded subinterval. The contradiction comes from:
- GLOBAL property: class boundary at c (step 7)
- LOCAL property: c ~M succ(c) because [c, c+1] is finite hence very good (step 8-9)

## 2. How Each Step Maps to Existing Lean Code

### Step A (Definitions) -> `GoodStructures.lean`

| Reynolds | Lean | Status |
|----------|------|--------|
| good(M) | `good sig k M` | sorry-free |
| very_good(M) | `very_good sig k M` | sorry-free |
| ~M | `contemp_equiv sig k M a b` | sorry-free |
| Finite structures are good | `finite_structures_good` | sorry-free |
| Z-interval structure | `ZIntervalStructure` | sorry-free |

**Mapping is excellent.** The definitions faithfully capture Reynolds' concepts.

### Step B (Lemma 16: very good -> good) -> `ShiftAndGlue.lean`

This is encoded as `chronicle_is_good_direct` in `ShiftAndGlue.lean`. The lexicographic sum argument uses `doets_lemma_1_4` from `OrderedSum.lean`. Status: sorry-free.

### Step C (Lemma 17: ~M is contemp equiv) -> `GoodStructures.lean`

| Reynolds | Lean | Status |
|----------|------|--------|
| Reflexivity | `contemp_equiv_is_equiv.refl` | sorry-free |
| Symmetry | `contemp_equiv_is_equiv.symm` | sorry-free |
| Transitivity | `contemp_equiv_is_equiv.trans` | sorry-free |
| Split at b/succ(b) | `good_of_split_at_succ` | sorry-free |

**Mapping is complete and sorry-free.** The hard transitivity case follows Reynolds exactly: decompose at b/succ(b), use doets_lemma_1_4 for the lexicographic sum argument.

### Step D (Theorem 14: classes don't end at gaps) -> `GoodStructuresModelSurgery.lean`

| Reynolds | Lean | Status |
|----------|------|--------|
| Lemma 6: temporal R | `gap_formula_R` via `US_expressively_complete_over_prior` | sorry-free |
| Lemma 7: R-intervals open | Encoded in `h_R_everywhere` proof | sorry-free |
| Lemma 8: no first/last class | Absorbed into `h_R_everywhere` | sorry-free |
| Lemma 9: class spread | `class_spread` + `invariant_formula_constant` | sorry-free |
| Lemma 9.1: ordered spread | `ordered_spread_above` + `ordered_spread_below` | sorry-free |
| Lemma 12: model surgery | `N` construction + `truth_pres` induction | sorry-free |
| Lemma 13+14: contradiction | Steps 9-12 in `gap_prior_UZ_contradiction` | sorry-free |
| Full Theorem 14 core | `reynolds_model_surgery_core` | sorry-free |
| Main theorem | `no_gaps_discrete_model_surgery` | sorry-free |

**THIS IS THE KEY FINDING: The ENTIRE Reynolds model surgery argument (Lemmas 6-13, Theorem 14) is already formalized and sorry-free in `GoodStructuresModelSurgery.lean`.** The approach taken is NOT the traditional "excise bad interval, replace by one class" of Reynolds' original proof. Instead, the formalization takes a more direct path:

1. Construct surgery model N = restriction to class(a)
2. Prove truth preservation directly by structural induction on formulas
3. Use Prior-UZ/SZ on N (transferred from M via truth preservation)
4. Derive contradiction: R is true on N but right_gap_class_formula is false

The symmetry case (`gap_prior_SZ_contradiction`) is handled by swapping roles of a and y (reducing to the UZ case).

### Step E (Theorem 15 punchline) -> `NoGapsDiscreteProof.lean`

| Reynolds | Lean | Status |
|----------|------|--------|
| If not good, not very good | Captured in `no_gaps_discrete` premise | sorry-free |
| Two distinct classes exist | `h_diff_class` premise | sorry-free |
| Class can't end at gap | `no_gaps_discrete` | sorry-free |
| c ~M succ(c) | `no_boundary_at_successor` | sorry-free |
| Contradiction | `one_class` proof | sorry-free |

The `one_class` theorem in `NoGapsDiscreteProof.lean` follows Reynolds' Theorem 15 punchline exactly:

```lean
by_contra h_diff
obtain ⟨c, hac, h_not_succ⟩ := no_gaps_discrete ... a b h_diff
have hc_succ := no_boundary_at_successor ... c  -- c ~M succ(c)
have hac_succ := trans hac hc_succ               -- a ~M succ(c)
exact h_not_succ hac_succ                         -- contradiction
```

## 3. Where the Formalization Diverges from the Paper

### Divergence 1: No explicit "bad intervals" or interval excision

Reynolds' original proof (Lemmas 10-12) works by:
1. Identifying "bad intervals" where R or L holds
2. Choosing a single ~M class I within a bad interval
3. Excising the bad interval and replacing it with I
4. Proving truth preservation for the surgery domain Q- union I union Q+

The formalization SKIPS this entirely. Instead of excising a bad interval, it restricts to class(a) directly. This is simpler and more direct because:
- Class(a) is convex (proven separately)
- Class(a) has SuccOrder and PredOrder (via no_boundary_at_successor)
- Truth preservation from M to class(a) is proven by direct structural induction

### Divergence 2: Class spread replaces bad-interval formula propagation

Reynolds' Lemma 11 proves that formulas propagate throughout bad intervals via gap-boundary analysis. The formalization replaces this with:
- `invariant_formula_constant`: any contemp_equiv-invariant formula is constant on all of M
- `class_spread`: if A holds somewhere, it holds in every class
- `ordered_spread_above/below`: if A holds in class(a) and outside class(a), there is a same-class witness in the right direction

These are proven using the Prior-UZ/SZ first/last transition lemmas.

### Divergence 3: The `no_gaps_prior` theorem in ReynoldsNoGaps.lean is DEPRECATED

There is a `no_gaps_prior` theorem at `ReynoldsNoGaps.lean:276` that is marked DEPRECATED and has a sorry. The docstring explains it is mathematically false as stated (Z+Z counterexample with constant predicates). This theorem is OFF the critical path. The critical path goes through `GoodStructuresModelSurgery.lean` instead.

### Divergence 4: No k >= 1 restriction in the formalization

Reynolds implicitly assumes k >= 3 in Theorem 15. The formalization handles all k values:
- k = 0: handled by special-case in `good_of_split_at_succ`
- k = 1: uses `good_one`
- k >= 2: uses expressibility of "has max/min" via `doets_lemma_1_1`

## 4. The Correct Lean Proof Strategy and Current Status

### The sorry-free path (already implemented)

The complete sorry-free chain is:

```
no_boundary_at_successor (GoodStructures.lean, sorry-free)
  -- c ~M succ(c) for all c

gap_prior_UZ_contradiction (GoodStructuresModelSurgery.lean, sorry-free)
  -- Full Reynolds Lemmas 6-13 for upward case

gap_prior_SZ_contradiction (GoodStructuresModelSurgery.lean, sorry-free)
  -- Reduced to UZ case by swapping a and y

reynolds_model_surgery_core (GoodStructuresModelSurgery.lean, sorry-free)
  -- class(a) = whole carrier when succ-closed

no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean, sorry-free)
  -- If a !~M b, then there exists c with a ~M c and not a ~M succ(c)

no_gaps_discrete (NoGapsDiscreteProof.lean, sorry-free)
  -- Delegates to no_gaps_discrete_model_surgery

one_class (NoGapsDiscreteProof.lean, sorry-free)
  -- Contradiction: no_gaps_discrete + no_boundary_at_successor
```

### The remaining sorry

The actual remaining sorry is at `ChronicleToCountermodel.lean:481` in `chronicle_gap_contradiction`. This theorem has signature:

```lean
private theorem chronicle_gap_contradiction
    (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ...)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b)
    (h_orbit_bounded : ∀ n, succ^[n] a < b) : False
```

This is a DIFFERENT theorem from Theorem 15. It says: in the chronicle's limit domain, if succ-iterates of a are bounded by b, derive contradiction. This should follow from the sorry-free `one_class` (or `gap_contradicts_prior`) IF we can:

1. Build a `MonadicSignature` and `OrderedMonadicStructure` on `LimitDomSubtype`
2. Construct an `atomMap` satisfying `h_surj`
3. Prove `semantic_prior_UZ` and `semantic_prior_SZ` on this structure
4. Prove the succ-orbit boundedness implies a non-contemp-equiv pair

### Why the phase-2 handoff found gap_contradicts_prior "inapplicable"

The handoff document says: "contemp_equiv sig k M a b is trivially true for ALL bounded subintervals at ANY depth k with ANY signature."

This is CORRECT for the wrong reason. The handoff was looking at applying `gap_contradicts_prior` to a BOUNDED subinterval. But Reynolds' argument operates on the FULL unbounded structure. The issue is:

1. `gap_contradicts_prior` requires `h_bounded_above : exists y, a < y and not contemp_equiv a y`
2. On a bounded subinterval [a, b], contemp_equiv IS trivially true (finite hence very good)
3. The theorem must be applied to the FULL `LimitDomSubtype`, not to a bounded subinterval

The correct approach: apply `one_class` or `no_gaps_discrete_model_surgery` to the full `LimitDomSubtype` structure, then derive `IsSuccArchimedean`, which contradicts the orbit-boundedness hypothesis.

### Recommended bridge strategy

The cleanest path to close `chronicle_gap_contradiction` is:

1. Wrap `LimitDomSubtype` as an `OrderedMonadicStructure` with singleton `MonadicSignature` (one predicate per distinguishing formula, or better: use the enriched signature from `Transfer.lean`)
2. Prove `semantic_prior_UZ` and `semantic_prior_SZ` (the chronicle's transfer machinery should give this)
3. Apply `one_class` to get `forall a b, contemp_equiv a b`
4. Use `one_class_archimedean` or direct argument: one_class + very_good + countable => good => IsSuccArchimedean
5. IsSuccArchimedean contradicts the orbit-boundedness hypothesis

Alternatively, if the signature/transfer machinery is too heavy, use `gap_of_not_succ_archimedean` (already sorry-free) to show that if NOT IsSuccArchimedean, a Gap exists. Then show the Gap violates the chronicle's Prior-UZ property.

## Summary of Key Findings

1. **Reynolds Theorem 15 is already fully formalized and sorry-free** in `NoGapsDiscreteProof.lean` (delegating to `GoodStructuresModelSurgery.lean`).

2. **Reynolds Theorem 14 (model surgery) is already fully formalized and sorry-free** in `GoodStructuresModelSurgery.lean`, including the full Lemmas 6-13 argument.

3. **The actual blocker** is bridging from the abstract `one_class` theorem to the concrete `chronicle_gap_contradiction` in `ChronicleToCountermodel.lean`. This requires wrapping the chronicle's limit domain as an `OrderedMonadicStructure` and transferring Prior-UZ/SZ.

4. **The phase-2 handoff diagnosis was correct but aimed at the wrong target.** `gap_contradicts_prior` IS inapplicable to bounded subintervals. The fix is to apply the sorry-free machinery to the FULL unbounded structure.

5. **The `no_gaps_prior` sorry in ReynoldsNoGaps.lean is on a DEPRECATED theorem.** It is mathematically false as stated and off the critical path. The critical path goes through `no_gaps_discrete_model_surgery` instead.

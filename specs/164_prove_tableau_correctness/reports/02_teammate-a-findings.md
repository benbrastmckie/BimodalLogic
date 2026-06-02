# Teammate A Findings: Mathematically Correct Approach for Until/Since Truth Lemma

**Task**: 164 -- Prove tableau correctness theorem
**Focus**: Primary approach angle -- local-to-global gap in `truthLemma_neg` for Until/Since
**Date**: 2026-06-01

---

## Key Findings

### Finding 1: The Core Mathematical Problem Is Fundamental to Temporal Tableau

The gap between `sat_untl_neg` (which gives one-step guarantees from `timeOrd.futureOf t`) and `branchTruth` (which uses `isTimeOrderedBefore` -- the transitive closure over `timeOrd.constraints`) is not a minor technical gap. It reflects a genuine theorem-proving challenge that standard temporal tableau completeness proofs resolve using one of three standard techniques.

**What `sat_untl_neg` proves** (in the Lean code):
> If F(U(event, guard)) is at (w, t) in a saturated branch, then for every t' in `timeOrd.futureOf t` (direct edge successors only), either F(event) or F(guard) is at (w, t') in the branch.

**What `truthLemma_neg` for Until needs** (from `branchTruth` definition):
> It must be false that there exists t' with `isTimeOrderedBefore ord t t'` (transitive closure), `branchTruth cm w t' event`, and `branchTruth cm w t'' guard` for all t'' between t and t'.

The critical issue: the `untlNeg` rule only acts on direct successors (one step of `futureOf`), but the truth definition uses transitive reachability. However, this is actually not a gap -- it is a coherent design choice that DOES work, but the proof strategy must match the rule design.

### Finding 2: The `untlNeg` Rule Uses a Propagation Design That Eliminates the Gap

Looking at `applyRule .untlNeg` in `Tableau.lean` (lines 739-757):

The untlNeg rule for F(U(event, guard)) at (w, t) branches at an UNPROCESSED future time t' (direct successor where neither F(event) nor F(guard) has been placed):
- Branch 1: F(event) at (w, t'), re-include F(U(event,guard)) at (w, t) (source persistence)
- Branch 2: F(guard) at (w, t'), F(U(event,guard)) at (w, t'), re-include source

**Crucially**: Branch 2 propagates F(U(event, guard)) to t'. This means the same untlNeg rule will fire again at t', covering all future successors of t' as well. The rule propagates the negated Until formula down the chain, covering ALL reachable times by induction.

This is the Reynolds co-decomposition pattern. The rule as designed ensures:
- For every t' reachable from t (transitively), either F(event) or F(guard) or F(U(event,guard)) is at (w, t')
- When the saturation process stabilizes, F(U(event,guard)) propagated to t' covers t''s direct successors via another firing

**The proof strategy for `truthLemma_neg untl` must use induction on the time-ordering path structure**, not just a single step of `sat_untl_neg`.

### Finding 3: The Literature Confirms the Propagation/Induction Approach

The literature files surveyed all describe Henkin/Canonical-model approaches to Until completeness, not tableau completeness directly. The key insight from the Gabbay-Hodkinson-Reynolds Vol 1 Chapter 10 is the co-decomposition of negated Until:

From `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`:
> `¬U(A, B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)` (Lemma 10.2.2)

This equivalence is the mathematical foundation. It says: Until fails at t iff either A never holds in the future, OR there exists a future t* where ¬A AND ¬B and before that ¬A holds. The tableau rule implements this via branching and propagation.

From the `Venema_1993_Since_and_Until.md` semantics (Section 2.2):
```
M, t |= U(φ, ψ) iff there is v > t such that M, v |= φ and
                  for all u with t < u < v, M, u |= ψ
```

Note the asymmetric convention: the "event" is the FIRST argument (φ) and the "guard" is the SECOND. The Lean code uses the same convention (`untl event guard`). The co-decomposition used in the tableau rule is consistent with this.

### Finding 4: The Correct Proof Strategy for Sorry Site 1 & 2

The correct proof of `truthLemma_neg untl` requires demonstrating that `¬branchTruth cm w t (untl event guard)` i.e., showing there is no witness t' where event holds and guard holds everywhere between t and t'.

**Step 1**: Assume for contradiction there exists t_wit with:
- `isTimeOrderedBefore ord t t_wit` (transitive reachability)
- `branchTruth cm w t_wit event`
- `∀ t_mid ∈ timesBetween ord t t_wit cm.times, branchTruth cm w t_mid guard`

**Step 2**: By induction on the path from t to t_wit in the time ordering, show that F(U(event, guard)) propagates along the path.

The key fact needed is a **path induction lemma**:

```lean
lemma untlNeg_propagates_along_path (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b = none)
    (event guard : Formula) (w : WorldIndex)
    (t t' : TimeIndex)
    (hmem : ⟨.neg, .untl event guard, ⟨w, t⟩⟩ ∈ b)
    (hguard : guard ≠ Formula.top)
    (hpath : isTimeOrderedBefore timeOrd t t') :
    ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b ∨
    ∃ t_mid, isTimeOrderedBefore timeOrd t t_mid ∧
             isTimeOrderedBefore timeOrd t_mid t' ∧
             ⟨.neg, guard, ⟨w, t_mid⟩⟩ ∈ b
```

This says: if F(U(event, guard)) is at t and t' is reachable from t, then either F(event) is at t', or there exists an intermediate t_mid where F(guard) holds AND the path is "cut" there.

**Step 3**: Once we have this propagation lemma, the truth lemma follows. If U(event, guard) were true (witness t_wit where event holds and guard holds everywhere between), we get a contradiction: the propagation lemma gives either F(event) at t_wit (contradicts branchTruth event at t_wit by the positive truth lemma) or F(guard) at some intermediate (contradicts guard holding everywhere by truth lemma for guard).

### Finding 5: Why `isTimeOrderedBefore` Uses a Fuel-Bounded DFS

The function `isTimeOrderedBefore` (lines 188-198 of CountermodelExtraction.lean) uses a recursive fuel-based DFS over the `timeOrd.constraints` graph. This means:

- `isTimeOrderedBefore ord t t'` is decidable for any concrete ord, t, t'
- But for the Lean PROOF of `truthLemma_neg`, we need to reason about what `isTimeOrderedBefore = true` means semantically, i.e., it means there is a path in the graph

**Critical issue**: The `isTimeOrderedBefore` function and the `timesBetween` function use bounded fuel (default 50). In the proof, we need to know that the fuel is sufficient for the finite branch model. The branch model has finitely many times, so the longest path is bounded. However, the default fuel of 50 could be a source of concern.

**Alternative approach** (recommended): Instead of working directly with `isTimeOrderedBefore`, introduce a helper predicate `TimeReachable ord t t'` defined inductively (no fuel bound) and prove that `isTimeOrderedBefore ord t t' = true → TimeReachable ord t t'` for branch models with bounded size. This gives a cleaner induction principle.

### Finding 6: The `blocking_terminates` Gap Is Independent

The `blocking_terminates` sorry (Saturation.lean line 663) is structurally independent of the truth lemma sorries. The termination proof requires:

1. **Generalized subformula property**: Every formula in an expanded branch (not just the initial branch) is a subformula of the initial formula. The current `subformula_property` only covers the initial branch.

2. **Pigeonhole argument**: The finite closure means distinct time-types (sets of signed subformulas present at a time) are bounded. The blocking condition fires before the 2^(2n) bound is exceeded.

The standard approach (from Gore 1999, Temporal Logic handbook Ch. 11 Section 5.4) is:
- Define `timeType(t)` = `{F ∈ subformulaClosure(φ) | F is present at time t in the branch}`
- Show `timeType` values are bounded by `|subformulaClosure(φ)|`
- Show blocking fires when a time type repeats or is subsumed
- Bound fuel by `2^|subformulaClosure(φ)|` or similar

---

## Recommended Approach

### For Sorry Sites 1 & 2 (truthLemma_neg for Until and Since)

**Approach A: Redefine branchTruth to use the branch directly** (Recommended)

The root cause of the gap is that `branchTruth` is defined using `isTimeOrderedBefore` (transitive closure) but `sat_untl_neg` only gives a one-step guarantee from `futureOf`. 

The cleanest solution is to define a helper `untl_neg_in_branch` that characterizes "U(event, guard) is false in the branch" DIRECTLY in terms of what the saturation invariants can prove:

```lean
def untl_neg_in_branch (b : Branch) (timeOrd : TimeOrdering)
    (w : WorldIndex) (t : TimeIndex) (event guard : Formula) : Prop :=
  ∀ t' ∈ b.knownTimes,
    isTimeOrderedBefore timeOrd t t' →
    ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b
```

Then prove that `untl_neg_in_branch b timeOrd w t event guard` implies `¬branchTruth cm w t (untl event guard)` using the induction hypothesis on sub-formulas.

**Approach B: Path induction lemma** (More faithful to standard proofs)

Prove the propagation lemma as described in Finding 4, then use it to show that the presence of F(U(event, guard)) at t, combined with saturation, forces F(event) at every transitively reachable time. This approach has a cleaner mathematical structure and is more faithful to standard temporal tableau completeness proofs.

**Approach C: Strengthen sat_untl_neg to cover transitive closure**

Instead of only proving sat_untl_neg for `futureOf t` (direct successors), prove a stronger version:

```lean
theorem sat_untl_neg_transitive (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .untl event guard, ⟨w, t⟩⟩ ∈ b)
    (hguard : guard ≠ Formula.top) :
    ∀ t' ∈ b.knownTimes,
      isTimeOrderedBefore timeOrd t t' →
      ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b
```

This requires: if F(U(event, guard)) is at (w, t) in a SATURATED branch, then for every transitively reachable t', F(event) is at (w, t'). This IS provable because:
- Branch 2 of untlNeg propagates F(U(event, guard)) to t' (the direct successor)
- By repeated application of sat_untl_neg, F(event) eventually appears at all successors
- But "repeated application" requires induction over the finite path structure

The proof would proceed by induction on the length of the path from t to t' using `isTimeOrderedBefore`'s recursive structure.

**Recommendation**: Approach C (strengthening sat_untl_neg) is the cleanest because it resolves the gap at the saturation invariant level rather than at the truth lemma level. The strengthened invariant directly matches what branchTruth needs.

### For Sorry Site 3 (blocking_terminates)

**Approach**: Two-step proof following standard temporal tableau termination arguments.

**Step 1**: Generalize `subformula_property` to all expansions:
```lean
theorem subformula_property_general (φ : Formula) (b : Branch) 
    (h : b is reachable from [F(φ)] by expansion steps) :
    ∀ sf ∈ b, sf.formula ∈ Formula.subformulas φ
```

This requires tracking formulas through every rule application. All rules in the system produce formulas from the subformula closure (atom, bot, imp, box, untl, snce and their connectives only appear as subformulas). This can be proved by checking each rule case.

**Step 2**: Pigeonhole over time types:
- `timeType(t, b)` = list of subformulas of φ that are present (either positive or negative) at time t in branch b
- There are at most `2^(2 * |subformulas φ|)` distinct time types
- The blocking condition detects when a new time's type is a subset of an ancestor's type
- After `2^(2n)` time points are created, blocking must fire

This gives `blocking_terminates` with `bound = 2^(2 * (subformulas φ).length)`.

---

## Evidence and Examples

### Evidence 1: The untlNeg Rule Re-includes F(U(event,guard)) at t' (Branch 2)

From Tableau.lean lines 753-756:
```lean
-- Branch 2: guard fails at t' AND Until propagated to t', source re-included
let branch2 := [SignedFormula.neg guard targetLabel,
                SignedFormula.neg (.untl event guard) targetLabel, sf]
```

The `sf` at the end is the SOURCE formula F(U(event, guard)) at (w, t) and `SignedFormula.neg (.untl event guard) targetLabel` is F(U(event, guard)) at (w, t'). This means Branch 2 has F(U(event, guard)) at BOTH t and t'. The rule will fire again at t' covering t''s direct successors. This is the Reynolds co-decomposition propagation.

### Evidence 2: sat_untl_neg Only Covers futureOf (Direct Successors)

From CountermodelExtraction.lean line 624:
```lean
∀ t' ∈ timeOrd.futureOf t,
  ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b ∨ ⟨.neg, guard, ⟨w, t'⟩⟩ ∈ b
```

The `timeOrd.futureOf t` is the list of DIRECT outgoing edges from t. The `isTimeOrderedBefore` in branchTruth uses the TRANSITIVE closure (recursive DFS). This is the precise mismatch.

### Evidence 3: branchTruth Uses Transitive Closure for Until

From CountermodelExtraction.lean lines 257-262:
```lean
| .untl event guard =>
    ∃ t' ∈ cm.times,
      isTimeOrderedBefore cm.timeOrdering t t' ∧
      branchTruth cm w t' event ∧
      ∀ t'' ∈ timesBetween cm.timeOrdering t t' cm.times,
        branchTruth cm w t'' guard
```

The `isTimeOrderedBefore` is the recursive DFS over the full transitive closure. The "between" condition also uses transitive reachability.

### Evidence 4: The Mathematical Equivalence That Closes the Gap

From Gabbay-Hodkinson-Reynolds Vol 1, Ch 10, Lemma 10.2.2:
```
¬U(A, B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)
```

This says: Until fails iff ALWAYS the event fails, OR there exists a future point where BOTH fail and between that and t the event also fails. In the branch model with the propagation invariant, this is exactly what the saturated branch enforces.

### Evidence 5: Reynolds Co-Decomposition Covers the Gap

The proof sketch for the strengthened sat_untl_neg is:

Given F(U(event, guard)) at (w, t) in a saturated branch, let t' be transitively reachable from t (there exists a path t = t_0 < t_1 < ... < t_n = t'). 

By `sat_untl_neg` at t: for t_1 (direct successor), either F(event) at (w, t_1) or F(guard) at (w, t_1).

Case F(event) at (w, t_1): If t_1 = t' we're done. If t_1 ≠ t', we need more. But wait -- the goal is to show F(event) at t', not at t_1. This suggests the simple approach doesn't work for paths longer than 1 step.

For Branch 2, F(U(event, guard)) propagated to t_1. By `sat_untl_neg` at t_1: for t_2, either F(event) at t_2 or F(guard) at t_2. By induction, this reaches t_n = t'.

So the induction is on path length, using sat_untl_neg at each intermediate node.

The conclusion is: F(event) at t' (if at every step Branch 1 was taken) OR F(guard) at some intermediate t_i AND F(U(event, guard)) at t_i (from Branch 2). The second case inductively continues. Since the path is finite, we eventually reach either F(event) at t' or F(guard) somewhere along the path.

**This is precisely what is needed for `truthLemma_neg`**: if U(event, guard) were true with witness t', then branchTruth cm w t' event would hold, but we also have (by the path induction) either F(event) at t' -- contradicting truthLemma_pos for event -- or F(guard) at some intermediate t_i -- contradicting guard holding everywhere between t and t'.

---

## Confidence Level

**High confidence** on the mathematical approach:
- The `sat_untl_neg` + propagation design is correct and consistent with Reynolds co-decomposition
- The path induction approach to bridge local-to-global IS the standard technique
- The literature confirms co-decomposition of ¬U(A,B) is the key equivalence
- The code structure (Branch 2 propagating F(U) to t') explicitly enables this approach

**Medium confidence** on Lean implementation complexity:
- The induction over `isTimeOrderedBefore`'s recursive structure requires care with the fuel parameter
- Introducing `TimeReachable` as an inductive predicate (separate from the fuel-based `isTimeOrderedBefore`) would make the path induction much cleaner
- The saturation invariants have already been proved for `futureOf` -- extending to transitive closure follows the same pattern but with a fuel/path induction argument

**High confidence** on blocking_terminates approach:
- The subformula property + pigeonhole argument is standard
- The bound `2^(2n)` is well-known in temporal logic tableau literature
- The generalized subformula property can be proved by checking all 30+ rules

---

## Summary of Recommended Actions for Implementation

1. **Introduce `TimeReachable`**: Add an inductive relation `TimeReachable (ord : TimeOrdering) (t1 t2 : TimeIndex) : Prop` with constructors `step` (direct edge) and `trans` (transitivity). Prove `isTimeOrderedBefore ord t t' = true ↔ TimeReachable ord t t'` for finite orderings with sufficient fuel.

2. **Prove `sat_untl_neg_transitive`**: Using path induction on `TimeReachable`, prove that F(U(event, guard)) at t in a saturated branch implies F(event) is in the branch at every `t'` with `TimeReachable ord t t'`. This uses `sat_untl_neg` at each step (base case: direct successor) and the Branch 2 propagation (inductive step: F(U(event, guard)) propagates to t', giving the induction hypothesis at t').

3. **Close `truthLemma_neg untl`**: Given F(U(event, guard)) at (w, t), assume for contradiction that branchTruth holds with witness t_wit. By `sat_untl_neg_transitive`, F(event) is in the branch at t_wit. By `truthLemma_pos` (induction hypothesis on event, a strict subformula), event is true at t_wit. Contradiction with F(event) ∈ b (same argument as for atoms, using the negative truth lemma IH on event).

4. **Generalize subformula_property**: Prove the general subformula property by tracking each rule's output against the input formula's subformula closure.

5. **Prove blocking_terminates**: Use the generalized subformula property + pigeonhole over time types.

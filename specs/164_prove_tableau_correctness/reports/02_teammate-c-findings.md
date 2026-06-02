# Teammate C (Critic) Findings: Tableau Correctness Proof

**Task**: 164 - Prove tableau correctness theorem for decision procedure
**Role**: Critic - identify gaps, shortcomings, and blind spots
**Date**: 2026-06-01

---

## Key Findings

### Finding 1: FUNDAMENTAL FLAW -- `sat_box_neg` is proved vacuously (False is the proof)

This is the most serious bug. The theorem at line 535:

```lean
theorem sat_box_neg (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .box φ, ⟨w, t⟩⟩ ∈ b) :
    ∃ w' ∈ b.knownWorlds, ⟨.neg, φ, ⟨w', t⟩⟩ ∈ b := by
  exfalso
  have hExp := findUnexpanded_none_all_expanded b timeOrd hSat ⟨.neg, .box φ, ⟨w, t⟩⟩ hmem
  simp [boxNeg_not_expanded] at hExp
```

The proof says: "F(box phi) cannot exist in a saturated branch, therefore exfalso." But the helper `boxNeg_not_expanded` claims `isExpanded ⟨.neg, .box φ, l⟩ b = false` for ANY branch (not just saturated ones). This means the proof reduces to claiming F(□φ) can never be in a saturated branch, so the existential conclusion follows vacuously.

**But wait -- is this actually correct?** For a box-negative formula, the rule `boxNeg` is supposed to introduce a fresh witness world. If the rule always creates a fresh world, then `boxNeg_not_expanded` would be correct: `F(□φ)` is a consumable existential rule (F(□φ) → introduce fresh w' with F(φ)), so by the time the branch is saturated, F(□φ) has already been consumed and replaced by F(φ) at a fresh world. The formula should NOT still be present.

However, look at `applyRule` for `boxNeg` (Tableau.lean, line 374): it uses `.linear`, meaning the source formula is removed after application. So `boxNeg_not_expanded` is likely correct: F(□φ) is never in a saturated branch. But then `sat_box_neg` proves `False → ∃ w' ∈ ..., ...`, which is vacuously true but provides no constructive witness.

**Critical problem**: `truthLemma_neg` at line 826 then uses `sat_box_neg` to obtain `⟨w', hw'mem, hw'neg⟩`. If `sat_box_neg` is proved via `exfalso` (the hypothesis `hmem` leads to False), then the "obtaining" of `w'` here is also vacuously true -- the proof of the box-neg case in `truthLemma_neg` is itself vacuously valid only because F(□φ) cannot exist in a saturated branch. This is not incorrect, but it means the "proof" of box soundness is hollow: it never actually demonstrates that the countermodel satisfies F(□φ) in a meaningful way, only that the case is impossible.

**Assessment**: This is vacuous but technically correct -- both `sat_box_neg` and the `box` case of `truthLemma_neg` are valid by contradiction. The concern is that the named theorem `sat_box_neg` makes a false promise (it claims "there exists a witness world") but actually proves it by showing the antecedent is impossible. Any downstream code calling `sat_box_neg` to obtain a witness `w'` would only work vacuously. This is a semantic integrity concern, not a Lean type-error.

### Finding 2: CRITICAL -- The `truthLemma_neg` sorry for `untl` has a deep semantic gap, not just a proof strategy problem

The current plan documents this as a "proof strategy" problem -- sat_untl_neg is too weak. But the issue is deeper:

**The semantic definition of `branchTruth` for `untl` (lines 257-262):**
```lean
| .untl event guard =>
    ∃ t' ∈ cm.times,
      isTimeOrderedBefore cm.timeOrdering t t' ∧
      branchTruth cm w t' event ∧
      ∀ t'' ∈ timesBetween cm.timeOrdering t t' cm.times,
        branchTruth cm w t'' guard
```

This uses `isTimeOrderedBefore` -- the **transitive closure** of the explicit time ordering constraints. But `sat_untl_neg` provides disjunctions (F(event) OR F(guard)) only at **direct successors** in `timeOrd.futureOf t` (the explicit, non-transitive edge list).

For the truth lemma, we need to show: for all t' with `isTimeOrderedBefore t t'`, NOT(branchTruth event at t') OR NOT(branchTruth guard at some intermediate t''). But `sat_untl_neg` only handles direct successors.

**Why this is a deep problem, not a technical gap:**
The `untlNeg` rule in `applyRule` (lines 743-758) applies the Reynolds co-decomposition to ONE future time at a time (the first unprocessed future time). After saturation, all direct successors of `t` have been processed. But the truth lemma needs to exclude witnesses in the transitive future -- times reachable via multiple hops.

If we have times t < t1 < t2, and F(U(event, guard)) is at t, and F(guard) is at t1, and the branch also has F(U(event,guard)) at t1 (from the untlNeg rule's branch 2), then we can recursively apply sat_untl_neg at t1 to get disjunctions at t2. This recursive argument would work IF: F(U(event,guard)) at t1 is guaranteed in the branch.

**Looking at `applyRule` for `untlNeg` (lines 743-758):**
```lean
| t' :: _ =>
  let targetLabel : Label := { world := l.world, time := t' }
  let branch1 := [SignedFormula.neg event targetLabel, sf]
  let branch2 := [SignedFormula.neg guard targetLabel,
                   SignedFormula.neg (.untl event guard) targetLabel, sf]
```

Branch 2 adds `F(U(event, guard)) @ (w, t')` along with `F(guard) @ (w, t')`. This is the KEY: in the guard branch, the Until formula propagates to the successor.

So the stronger invariant is: for every direct successor t', either:
- F(event) at (w, t') is in the branch [branch 1], OR
- F(guard) at (w, t') AND F(U(event,guard)) at (w, t') are in the branch [branch 2]

This IS what `sat_untl_neg` gives: `F(event) OR F(guard)`. But branch 2 also puts `F(U(event,guard))` in the branch at t'. A stronger version would state:
- F(event) at (w, t') is in the branch, OR
- F(guard) at (w, t') AND F(U(event,guard)) at (w, t') are in the branch

If this stronger invariant could be proved (call it `sat_untl_neg_strong`), then a well-founded induction over the time ordering could handle transitivity. However, `sat_untl_neg` as currently stated does NOT give this stronger form. It only gives `F(event) OR F(guard)`, not `F(event) OR (F(guard) AND F(U(event,guard)))`.

**Root cause**: The current `sat_untl_neg` proves the wrong thing. It should instead prove the stronger disjunction `F(event) OR (F(guard) AND F(U(event,guard)))` to enable the transitivity argument. The current formulation is insufficient for the truth lemma.

**Evidence**: The handoff documents from rounds 3-4 note "approach (b)" -- stronger saturation invariant -- as the correct fix. But this approach has NOT been attempted; round 5 proved the existing `sat_untl_neg`, not the stronger version needed.

### Finding 3: `branchTruth` semantics for `untl` uses transitive closure but the model is sparse

The model `cm.times` contains only the time indices that actually appear in the branch labels. The time ordering `cm.timeOrdering` contains the constraints added during expansion. Consider:

- Initial time t0
- untlPos creates t1 as future of t0, then t2 as future of t1 (from branch 2)
- Blocking fires when the time type at t2 subsumes t0 or t1

The semantics requires: there exists t' in cm.times with t < t' (transitive) such that event holds at t' and guard holds at all t'' strictly between t and t'.

But `isTimeOrderedBefore` is computed via fuel-bounded reachability (lines 188-198), with default fuel 50. If the time chain is longer than 50 hops, `isTimeOrderedBefore` returns `false`, breaking the semantics of `branchTruth`. The truth lemma proof would be vacuously correct for short chains but would fail for deep chains where `isTimeOrderedBefore` underestimates the ordering.

**Assessment**: The `fuel := 50` default in `isTimeOrderedBefore` is a latent semantic bug. For the truth lemma to be correct, either:
1. The fuel must be proven to always suffice (e.g., by bounding chain depth via the subformula closure size), or
2. `isTimeOrderedBefore` must use well-founded recursion instead of fuel-bounded DFS.

The current proof attempt does not address this gap.

### Finding 4: `sat_box_neg` and `sat_untl_pos` / `sat_snce_pos` prove vacuous existentials

All three theorems are proved via `exfalso`:
- `sat_box_neg`: "F(□φ) cannot be in saturated branch" → vacuous existential over witness worlds
- `sat_untl_pos`: "T(U(e,g)) cannot be in saturated branch" → vacuous existential over future times
- `sat_snce_pos`: "T(S(e,g)) cannot be in saturated branch" → vacuous existential over past times

These are "proved" by showing the hypothesis is impossible. The theorems state useful facts (about what's in the branch given a saturated state), but the proofs never actually demonstrate that any witness exists. They are vacuously true.

**This means**: None of these saturation invariants can be used to positively construct a witness. They can only derive False from an assumption that should be impossible. If, for some reason, the `*_not_expanded` helper lemmas are wrong (e.g., due to a bug in `isApplicable` or `applyRule`), the vacuous proofs would still compile.

**Specific concern about `boxNeg_not_expanded`**: The proof of this helper (lines 528-533) uses extensive `simp` unfolding. If `simp` is too aggressive and unfolds definitions incorrectly, the proof might be wrong. With such long simp chains, correctness is opaque.

### Finding 5: The `blocking_terminates` sorry hides a design gap -- the theorem as stated cannot be proved

The current theorem at Saturation.lean line 654:
```lean
theorem blocking_terminates (φ : Formula) :
    ∃ bound : Nat, ∀ (b : Branch) (fuel : Nat),
      fuel ≥ bound →
      (expandBranchWithFuel b fuel).isSome := by
```

This claims that for ANY branch `b`, sufficient fuel suffices. But `b` here is arbitrary -- it could contain arbitrary formulas not from `subformulaClosure φ`. The subformula property (that expansion only produces subformulas) only applies to branches derived from expanding `F(φ)`, not to arbitrary branches.

Moreover, the theorem quantifies over an ARBITRARY `fuel ≥ bound` and any branch `b`. This is not the correct statement of termination. The correct statement should be approximately:
- "For the specific expansion starting from `[F(φ)]`, there exists a fuel bound such that the result is not None."

The current statement is likely unprovable as written (it would require that arbitrary branches also terminate, which is not guaranteed by the subformula property for arbitrary inputs).

**Recommendation**: The theorem needs to be restated to apply only to the expansion of branches derived from `buildTableau φ`, not to arbitrary branches.

### Finding 6: Venema (1993) semantics mismatch -- `G` and `H` are defined differently

Venema (1993), Section 2.1, defines:
```
Gφ ≡ U(⊥, φ)     F φ ≡ ¬G¬φ
Hφ ≡ S(⊥, φ)     P φ ≡ ¬H¬φ
```

Note that in Venema's convention, `G φ = U(⊥, φ)` means "φ holds until ⊥" which (since ⊥ never holds) is equivalent to "φ holds at all future times" -- this is indeed the standard G (always in the future).

In the codebase, `Formula.all_future = some_future.neg.neg` is encoded differently. The `asAllFuture?` decomposer uses `.all_future` as a primitive, and the `some_future` is encoded as `untl event top`. This is a different but equivalent encoding. **However**, when formulas like `all_future φ` appear as the guard in an Until formula, the two encodings are not obviously equivalent, and the `asUntil?` predicate filters out `guard = top` (treating `someFuture` as a special case).

The critical issue: Venema's axioms A1a-A7a are for raw S-U logic, where G and H are defined abbreviations. The proof system in this Lean project treats G and H as primitives with their own rules (`allFuturePos`, `allFutureNeg`, etc.). The truth lemma needs to correctly handle the interaction between these two encodings. This has NOT been analyzed in the existing reports.

### Finding 7: The 10 resolved sorry sites rely on `*_not_expanded` simp proofs that are non-transparent

The core pattern is:
1. Prove `X_not_expanded`: uses `simp` on `isExpanded`, `findApplicableRule`, `isApplicable`, `applyRule` with the full rule list.
2. Use `X_not_expanded` to prove `sat_X` via `exfalso`.

For `impNeg_not_expanded`, `impPos_not_expanded`, `boxNeg_not_expanded`, `untlPos_not_expanded`, `sncePos_not_expanded`: these are proved by large `simp` calls with the full list of rules unfolded. The correctness depends entirely on `simp` correctly reducing these expressions.

**Could any be vacuously true?** Yes -- if `simp` proves `False` (e.g., because `isExpanded ... = false` is definitionally `true` for those patterns regardless of the branch), then all the `*_not_expanded` lemmas are trivially valid by `simp`. But if there's a subtle issue with the `simp` normalization (e.g., if `isApplicable` has a case that simp doesn't reach), the proof might be missing a case.

**Specific risk**: The `boxNeg_not_expanded` proof ends with just `simp`. If there's a case where `boxNeg` is NOT applicable (e.g., when `fc` is a specific frame class and some dense/discrete rule takes priority), the proof might miss this. Looking at `allRules`, `boxNeg` is in the base rules list (line 898), and `findApplicableRule` returns the FIRST applicable rule. If a rule earlier in the list (e.g., `negPos`) also applies to F(□φ), then `boxNeg` might not be the first to apply, but the formula would still be consumed by the earlier rule. However, `isExpanded` checks whether ANY applicable rule exists, not specifically `boxNeg` -- so the proof is checking `isExpanded = false`, which should be true if ANY rule applies. This is correct.

### Finding 8: De Morgan refactor in Tableau.lean is correct but creates a silent dependency

The round 5 change from `!(a || b)` to `!a && !b` in the `untlNeg` and `snceNeg` filter predicates (Tableau.lean lines 747, 772) was done to fix the proof in `sat_untl_neg`. This is mathematically correct (De Morgan's law). However:

1. It means the proof of `sat_untl_neg` now depends on the SPECIFIC syntactic form `!a && !b` in `applyRule`.
2. If someone refactors `applyRule` back to `!(a || b)` (or to any other semantically equivalent form), `sat_untl_neg`'s proof will break with an opaque error.
3. There is no comment in `Tableau.lean` documenting that this form was chosen for proof purposes.

This is a fragility, not a correctness issue. But it creates a hidden coupling between the rule implementation and the proof strategy.

---

## Recommended Approach

### For `truthLemma_neg` untl/snce (the primary remaining sorry)

**Option (b) from handoff -- strengthen `sat_untl_neg` -- is the correct approach**, but the stronger form needs to be stated and proved:

```lean
theorem sat_untl_neg_strong (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .untl event guard, ⟨w, t⟩⟩ ∈ b)
    (hguard : guard ≠ Formula.top) :
    ∀ t' ∈ timeOrd.futureOf t,
      (⟨.neg, event, ⟨w, t'⟩⟩ ∈ b) ∨
      (⟨.neg, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.neg, .untl event guard, ⟨w, t'⟩⟩ ∈ b)
```

The current `sat_untl_neg` only gives `F(event) OR F(guard)`. The stronger version adds `F(U(event,guard))` in branch 2. This IS extractable from the `applyRule` structure: in `untlNeg`, branch 2 explicitly includes `sf` (the source formula), which is `F(U(event,guard))` at `(w, t')`. The proof would be nearly identical to the current `sat_untl_neg` proof but would extract the SPECIFIC branch that fired (branch 1 vs branch 2) rather than just the union.

Once `sat_untl_neg_strong` is proved, `truthLemma_neg` for `untl` can proceed via well-founded induction on the time ordering depth:
- Assume `∃ t' ∈ cm.times, isTimeOrderedBefore t t' ∧ branchTruth event at t' ∧ guard everywhere between`
- Take the MINIMAL such t' (by well-foundedness of the finite ordering)
- The direct predecessor t_prev of t' satisfies `isTimeOrderedBefore t t_prev`
- Apply `sat_untl_neg_strong` at t to get: F(event) at t_prev, OR (F(guard) at t_prev AND F(U) at t_prev)
- Case split:
  - F(event) at t_prev: t_prev is a closer witness, contradicting minimality of t'
  - F(guard) at t_prev AND F(U) at t_prev: By IH on F(U) at t_prev, ¬∃ witness from t_prev -- but we need to bridge this to "no witness from t"

This approach requires the finite-model structure to be well-founded. A cleaner approach is:

**Option (c) -- Restrict `branchTruth` for `untl` to use `futureOf` (direct successors) instead of transitive closure**:

```lean
| .untl event guard =>
    ∃ t' ∈ cm.timeOrdering.futureOf cm.timeOrdering.initial_time_of_node,
      -- instead of isTimeOrderedBefore (transitive) use direct edge
```

Wait -- this won't work because Until semantics genuinely requires transitive future.

The best approach remains (b) strengthened: prove `sat_untl_neg_strong`, then use well-founded induction on the finite time ordering. The finite time ordering in the branch model is acyclic (time points are strictly increasing Nat indices) and has bounded depth (bounded by the fuel), so well-foundedness holds.

### For `blocking_terminates`

**Restate the theorem** to apply only to expansions of the initial branch `[F(φ)]`:

```lean
theorem blocking_terminates (φ : Formula) :
    ∃ bound : Nat, 
      (expandBranchWithFuel [SignedFormula.neg φ Label.initial] bound).isSome
```

Then prove using:
1. The subformula property (each expansion step only adds subformulas of φ)
2. The observation that distinct time types are bounded by `2^(2n)` where `n = |subformulaClosure φ|`
3. The finite pigeonhole principle (available via Mathlib's `Finset.exists_ne_map_eq_of_card_lt_of_maps_to`)

Note: This weaker statement is sufficient for `decide_terminates`, which only needs termination for the specific initial tableau.

### For the `isTimeOrderedBefore` fuel issue (Finding 3)

Either:
1. Add a lemma that the time ordering depth in any branch derived from `buildTableau φ fuel` is bounded by `fuel`, and set the `isTimeOrderedBefore` default fuel to match, or
2. Replace the fuel-bounded recursion with well-founded recursion on `List.length (timeOrd.constraints)` or the depth of the acyclic DAG.

This should be fixed before the truth lemma proof is attempted, since the current `branchTruth` definition has a latent incorrectness.

---

## Evidence and Examples

### Evidence for Finding 1 (vacuous `sat_box_neg`)

The proof `by exfalso; ... simp [boxNeg_not_expanded] at hExp` proves `∃ w' ∈ b.knownWorlds, ⟨.neg, φ, ⟨w', t⟩⟩ ∈ b` from `False`. It works, but the theorem name is misleading -- it implies a constructive witness exists, when actually the premise is shown to be impossible.

Trace: `truthLemma_neg` box case (line 826) calls `sat_box_neg` and pattern-matches `⟨w', hw'mem, hw'neg⟩`. Since `sat_box_neg` is proved via False (from the exfalso proof), Lean is happy -- the match works because `sat_box_neg` returns something of the stated type. But this is via `False.elim` under the hood.

### Evidence for Finding 2 (deeper semantic gap)

From `applyRule` lines 743-758, the `untlNeg` rule's branch 2 is:
```
let branch2 := [SignedFormula.neg guard targetLabel,
                 SignedFormula.neg (.untl event guard) targetLabel, sf]
```

`sf` is the original `F(U(event, guard)) @ (w, t)`, and `targetLabel = (w, t')`. So branch 2 adds:
- `F(guard) @ (w, t')`
- `F(U(event, guard)) @ (w, t')` -- this is the new formula that enables recursion
- `F(U(event, guard)) @ (w, t)` -- the source formula, re-added (persistence)

The current `sat_untl_neg` proves `F(event) @ (w,t') OR F(guard) @ (w,t')` but discards the information that `F(U(event,guard)) @ (w,t')` is also in branch 2. This discarded information is what would enable the stronger invariant.

### Evidence for Finding 5 (wrong theorem statement for `blocking_terminates`)

The current theorem quantifies `∀ (b : Branch)`, meaning it applies to ALL branches, not just those derived from `F(φ)`. This is clearly too strong: one can construct an arbitrary branch containing formulas outside `subformulaClosure φ`, and the blocking argument would not apply to such a branch.

---

## Confidence Level

**High confidence** (directly readable from code):
- Finding 1: `sat_box_neg` proved via exfalso -- verified by reading the proof directly
- Finding 2: `sat_untl_neg` insufficient for truth lemma -- verified by analyzing `applyRule` branch 2 and comparing to the sorry comment
- Finding 4: `sat_untl_pos`, `sat_snce_pos`, `sat_box_neg` proved vacuously -- verified by reading
- Finding 5: `blocking_terminates` overstated -- verified by reading the theorem signature
- Finding 8: De Morgan refactor in Tableau.lean creates implicit dependency -- verified by cross-referencing commits

**Medium confidence** (requires semantic analysis):
- Finding 3: `isTimeOrderedBefore` fuel-bounded issue -- requires analyzing branch depth vs fuel
- Finding 6: Venema semantics mismatch for G/H encoding -- requires cross-referencing Venema axioms with the proof system
- Finding 7: `*_not_expanded` simp proofs might be non-transparent -- requires checking if simp is actually sound here

---

## Summary for Implementer

The three remaining sorry sites have the following severity:

**Sorry 1-2 (truthLemma_neg untl/snce)**:
- The current plan's "approach (b)" is correct: prove `sat_untl_neg_strong` giving `F(event) OR (F(guard) AND F(U(event,guard)))`.
- This is actually derivable from the existing `applyRule` structure (branch 2 explicitly adds `F(U(event,guard))`).
- Once `sat_untl_neg_strong` is proved, the truth lemma needs well-founded induction over the finite time ordering.
- BEFORE tackling this, fix the `isTimeOrderedBefore` fuel-bound issue to avoid a latent semantic bug.

**Sorry 3 (blocking_terminates)**:
- Restate the theorem to apply only to the initial branch expansion.
- The proof then follows from pigeonhole over time types (Mathlib's `Finset.exists_ne_map_eq_of_card_lt_of_maps_to`).
- Requires the generalized subformula property (all expanded formulas are subformulas of the initial formula), which needs tracking through ALL rule applications in `applyRule`, not just the initial branch.

**Additional concern (not a sorry but a latent bug)**:
- `sat_box_neg` is technically proved but semantically hollow (it never constructs a witness). The name suggests constructive content that isn't there. Consider renaming it `sat_box_neg_vacuous` or documenting that F(□φ) cannot appear in a saturated branch.

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MintPaysAssembly

/-! # D7. The five-component measure, and the terminus family at it

`FourComponent.lean` carries the measure through the mint, extension, ordered-rank and self-guard
coordinates; `GapPotential.lean` adds the fifth, and `MintPaysAssembly.lean` discharges the
repaired residual `MintPaysForTimeGap` at **every** frame class with no hypothesis. This module is
where those two facts meet the measure: the carried state and the weighted potential gain their
gap coordinate, both step lemmas are re-proved against the four-disjunct residual, and the whole
terminus family is restated with the residual **discharged** rather than carried.

**The one thing that is new in the arithmetic, and the one thing that is not.** New: the fourth
disjunct, where the gap coordinate carries the step on its own and the other three components only
have to be shown not to rise. Not new: the weight. `budgetPotentialAt`'s own weight
`2·(Tmax² + 1) + |U|` is reused rather than a second one invented, because the three quantities it
has to dominate are *the same three* — the extra known time in `splitOrderedRank`, a full
incomparable-pair range, and `extensionAllowance`'s per-budget-unit factor — and a coordinate that
spends one unit of combined budget can add no more at the gap coordinate than at the self-guard
one.

**The headline improvement.** Every `_fixed` terminus in `SigmaFixed.lean` takes
`MintPaysForTimeFixed fc U Tmax` as a hypothesis the caller must meet, and
`mintPaysForTimeFixed_dense_false` says that at `.Dense` and `.RTime` no caller can. The `_gap`
restatements below drop that hypothesis and discharge it internally from
`mintPaysForTimeGap_of_any`. The residual becomes a theorem rather than a condition.

**What this does NOT do — the de-vacuification disclaimer, preserved.** Dropping `hmint` does not
make any terminus non-vacuous. Register entries 9, 11 and 22 still refute co-hypotheses
(`DifficultyBounded`, clause 2 of `UniverseClosed`, `PostBlockingSettles`), and nothing here
touches any of them. The improvement is in the residual's status, not in the terminus's
satisfiability.

**Figures enlarge; they never replace.** `derivedTmaxGap`, `mintPathBoundGap` and
`mintAwareFuelGap` each dominate their `…At` predecessor, and each enlargement is recorded as its
own lemma, so nothing stated at `derivedTmaxAt` / `mintPathBoundAt` / `mintAwareFuelAt` is
withdrawn.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-! ### The carried state and the weighted measure -/

/-- **The carried state, at the five-component measure.** `BudgetStateFixed`'s clauses with the
budget clause widened to the *triple* sum: the mint budget, the self-guard potential and the gap
potential.

The combination is load-bearing for the same reason `BudgetStateAt`'s pairing is: a density mint
raises `mintTimeBudget` by one and lowers `gapPotential` by at least one, so the sum is
non-increasing at exactly the step the narrower clause fails at. Measured at the refutation
vehicle (`GapPotential.lean`'s `gapWitness*`): `26 + 3 + 9 = 38` before, `27 + 3 + 7 = 37`
after. -/
def BudgetStateGap (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Prop :=
  RunInvariant b ord ∧ (∀ x ∈ b, x ∈ U) ∧
    mintTimeBudget U σ b ord + selfGuardPotential U σ ord + gapPotential U σ ord ≤ Tmax ∧
    SigmaFormulaFixed σ b ∧ SigmaFixesFormulasFrom σ b.nextTime

/-- **The five-component state implies the four-component one.** The direction, on the record: the
budget clause is strictly stronger (one more non-negative summand on the left), so
`BudgetStateGap` is the stronger *state* even though `MintPaysForTimeGap` is the weaker *residual*.
The two run opposite ways and saying so explicitly is the point of this lemma. -/
theorem budgetStateFixed_of_budgetStateGap {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    (h : BudgetStateGap U Tmax σ b ord) : BudgetStateFixed U Tmax σ b ord := by
  obtain ⟨hinv, hbU, hbud, hfix, hfrom⟩ := h
  exact ⟨hinv, hbU, by omega, hfix, hfrom⟩

/-- **The five-component measure.** `budgetPotentialAt` plus the gap coordinate at
`budgetPotentialAt`'s **own** weight `2·(Tmax² + 1) + |U|`.

The weight is reused rather than re-derived because the three quantities it has to dominate are
the same three `budgetPotentialAt`'s docstring names: `(Tmax² + 1)` for the extra known time in
`splitOrderedRank`, `Tmax²` for a full incomparable-pair range (`incompPairs_card_le` at
`knownTimes.card ≤ Tmax`), and `|U|` for `extensionAllowance`'s per-budget-unit factor.
`2·(Tmax² + 1) + |U|` clears all three with a unit to spare, which is why a density step drops the
measure by at least one however much it mints. -/
def budgetPotentialGap (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Nat :=
  budgetPotentialAt U Tmax σ b ord
    + (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ ord

/-- **Constraint (F) for the gap coordinate, tested at the arm before the inequality is
attempted.** The fifth component does not rise at the ordered split's identification arm.

`gapPotential_identifyOriented` read at the arm's own `(min t₁ t₂, max t₁ t₂)`, exactly as
`selfGuardPotential_le_at_arm3` reads its own transport lemma. Had this failed, Phase 7 would have
been blocked rather than rescued by re-weighting; it passes with equality-or-better because
nothing in the coordinate reads `ord.timeCount`. -/
theorem gapPotential_le_at_arm3 {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    gapPotential U (fun x => rhoSF (min t₁ t₂) (max t₁ t₂) (σ x))
        (ord.identifyTime (min t₁ t₂) (max t₁ t₂))
      ≤ gapPotential U σ ord :=
  gapPotential_identifyOriented (b := b) htrig hirr

/-! ### The step lemmas

Both lemmas below are their four-component predecessors re-proved. Every `have` that is not about
the gap coordinate is byte-identical to the corresponding one in
`budgetPotentialAt_step_splitOrdered_fixed` / `budgetPotentialAt_step_unordered_fixed`, which is
what the "costs a coefficient and nothing else" claim means concretely: no figure changes, no
weight changes, and no caller's hypothesis list changes. -/

/-- **The measure drops at every arm of an ordered split, at the five-component measure.**

`budgetPotentialAt_step_splitOrdered_fixed` re-proved, with exactly one additional input per arm —
the gap coordinate's non-increase, multiplied by the weight — and the state clause discharged from
the same inputs. Arms 1 and 2 get it from `gapPotential_le_of_grow` (the arms only add an edge);
arm 3 gets it from `gapPotential_le_at_arm3`. Every other `have` is byte-identical to the
four-component proof's, which is the sense in which the fifth coordinate costs a coefficient and
nothing else.

No residual is consumed here: an ordered split does not mint, so `MintPaysForTimeGap` is not used
at all. -/
theorem budgetPotentialGap_step_splitOrdered {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {bs : List (Branch × TimeOrdering)}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosedAt fc U) (hst : BudgetStateGap U Tmax σ b ord)
    (hres : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, ∃ σ' : SignedFormula → SignedFormula, BudgetStateGap U Tmax σ' p.1 p.2 ∧
      budgetPotentialGap U Tmax σ' p.1 p.2 < budgetPotentialGap U Tmax σ b ord := by
  obtain ⟨hinv, hbU, hbud, hfix, hfrom⟩ := hst
  have hkT : b.knownTimes.toFinset.card ≤ Tmax := by
    simp only [mintTimeBudget] at hbud; omega
  have hcU : b.toFinset.card ≤ U.card := card_le_of_subset_universe hbU
  have hrank := expandOnceUnblocked_splitOrdered_rank_lt hkT hres
  have hinvs := (expandOnceUnblocked_runInvariant hinv).2 bs hres
  obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hres
  intro p hp
  have hrk := hrank p hp
  have hinvp := hinvs p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · dsimp only at hrk hinvp ⊢
    have hm' : mintPotential U σ b (ord.addFuture t₁ t₂) ≤ mintPotential U σ b ord :=
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₁ t₂)
    have hI : mintTimeBudget U σ b (ord.addFuture t₁ t₂) ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : mintTimeBudget U σ b (ord.addFuture t₁ t₂) * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ b (ord.addFuture t₁ t₂)
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    have hS1 : selfGuardPotential U σ (ord.addFuture t₁ t₂) ≤ selfGuardPotential U σ ord :=
      selfGuardPotential_le_of_grow (addFuture_constraints_mono ord t₁ t₂)
    have hSmul : (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ (ord.addFuture t₁ t₂)
        ≤ (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord :=
      Nat.mul_le_mul_left _ hS1
    have hG1 : gapPotential U σ (ord.addFuture t₁ t₂) ≤ gapPotential U σ ord :=
      gapPotential_le_of_grow (addFuture_constraints_mono ord t₁ t₂)
    have hGmul : (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ (ord.addFuture t₁ t₂)
        ≤ (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ ord :=
      Nat.mul_le_mul_left _ hG1
    refine ⟨σ, ⟨hinvp, hbU, by omega, hfix, hfrom⟩, ?_⟩
    simp only [budgetPotentialGap, budgetPotentialAt, budgetPotential, extensionAllowance]
    omega
  · dsimp only at hrk hinvp ⊢
    have hm' : mintPotential U σ b (ord.addFuture t₂ t₁) ≤ mintPotential U σ b ord :=
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₂ t₁)
    have hI : mintTimeBudget U σ b (ord.addFuture t₂ t₁) ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : mintTimeBudget U σ b (ord.addFuture t₂ t₁) * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ b (ord.addFuture t₂ t₁)
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    have hS2 : selfGuardPotential U σ (ord.addFuture t₂ t₁) ≤ selfGuardPotential U σ ord :=
      selfGuardPotential_le_of_grow (addFuture_constraints_mono ord t₂ t₁)
    have hSmul : (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ (ord.addFuture t₂ t₁)
        ≤ (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord :=
      Nat.mul_le_mul_left _ hS2
    have hG2 : gapPotential U σ (ord.addFuture t₂ t₁) ≤ gapPotential U σ ord :=
      gapPotential_le_of_grow (addFuture_constraints_mono ord t₂ t₁)
    have hGmul : (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ (ord.addFuture t₂ t₁)
        ≤ (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ ord :=
      Nat.mul_le_mul_left _ hG2
    refine ⟨σ, ⟨hinvp, hbU, by omega, hfix, hfrom⟩, ?_⟩
    simp only [budgetPotentialGap, budgetPotentialAt, budgetPotential, extensionAllowance]
    omega
  · dsimp only at hrk hinvp ⊢
    have hk := knownTimes_card_lt_at_arm3_oriented (b := b) (ord := ord) htrig
    set s := min t₁ t₂ with hsdef
    set u := max t₁ t₂ with hudef
    have hm' : mintPotential U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
        (ord.identifyTime s u) ≤ mintPotential U σ b ord :=
      mintPotential_identifyTime_oriented htrig hinv.irreflOrd
    have hS3 : selfGuardPotential U (fun x => rhoSF s u (σ x)) (ord.identifyTime s u)
        ≤ selfGuardPotential U σ ord := selfGuardPotential_le_at_arm3 htrig hinv.irreflOrd
    have hSmul : (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U (fun x => rhoSF s u (σ x))
          (ord.identifyTime s u)
        ≤ (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord :=
      Nat.mul_le_mul_left _ hS3
    have hG3 : gapPotential U (fun x => rhoSF s u (σ x)) (ord.identifyTime s u)
        ≤ gapPotential U σ ord := gapPotential_le_at_arm3 htrig hinv.irreflOrd
    have hGmul : (2 * (Tmax * Tmax + 1) + U.card)
          * gapPotential U (fun x => rhoSF s u (σ x)) (ord.identifyTime s u)
        ≤ (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ ord :=
      Nat.mul_le_mul_left _ hG3
    have hIU : ∀ x ∈ b.identifyTime s u, x ∈ U :=
      universeClosedAt_identify_at_trigger_oriented hUcl hbU htrig
    have hc'U : (b.identifyTime s u).toFinset.card ≤ U.card :=
      card_le_of_subset_universe hIU
    have hIsucc : mintTimeBudget U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
        (ord.identifyTime s u) + 1 ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : (mintTimeBudget U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
          (ord.identifyTime s u) + 1) * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hIsucc
    have hEexp : (mintTimeBudget U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
          (ord.identifyTime s u) + 1) * U.card
        = mintTimeBudget U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
          (ord.identifyTime s u) * U.card + U.card := by ring
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U (fun x => rhoSF s u (σ x))
          (b.identifyTime s u) (ord.identifyTime s u)
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    obtain ⟨hmaxk, hmink, hminmax⟩ := firstIncomparablePair_spec_oriented htrig
    obtain ⟨hk1, hk2, hne21, -, -⟩ := firstIncomparablePair_spec htrig
    have hfix' : SigmaFormulaFixed (fun x => rhoSF s u (σ x)) (b.identifyTime s u) :=
      sigmaFormulaFixed_identifyOriented (ord := ord) (Ne.symm hne21) hmaxk hfix
    have hnextle : b.nextTime ≤ (b.identifyTime s u).nextTime :=
      nextTime_le_identifyTime_oriented b ord t₁ t₂
    have hfrom' : SigmaFixesFormulasFrom (fun x => rhoSF s u (σ x)) (b.identifyTime s u).nextTime :=
      sigmaFixesFormulasFrom_comp (sigmaFixesFormulasFrom_mono hfrom hnextle)
        (retired_lt_nextTime_oriented (b := b) ord hk1 hk2)
    refine ⟨fun x => rhoSF s u (σ x), ⟨hinvp, hIU, by omega, hfix', hfrom'⟩, ?_⟩
    simp only [budgetPotentialGap, budgetPotentialAt, budgetPotential, extensionAllowance]
    omega

/-- **The measure drops at `.extended` and at every arm of a `.split`, at the five-component
measure.**

`budgetPotentialAt_step_unordered_fixed` re-proved against the **four**-disjunct residual. The
first three disjunct cases are the landed ones with the gap coordinate carried along: it cannot
rise, because the ordering only grows (`gapPotential_le_of_grow` against
`expandOnceUnblocked_ord_mono`), so its weighted term `hGW` is bounded and `omega` closes from the
same facts as before.

The fourth case is the new one, and it is where a density step is paid for. Its shape is disjunct
3's exactly, one coordinate deeper: the combined budget
`|kt| + mintPotential + selfGuardPotential + gapPotential` does not rise, the gap coordinate
strictly drops, and the weight's surplus `(Tmax² + 1)` absorbs both the extra known time in
`splitOrderedRank` and a full incomparable-pair range. The arithmetic closes by `omega` from
product identities proved by `ring` and monotonicity facts with no slack in them, exactly as every
case above it does. -/
theorem budgetPotentialGap_step_unordered {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosedAt fc U) (hmint : MintPaysForTimeGap fc U Tmax)
    (hst : BudgetStateGap U Tmax σ b ord)
    (hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1)
    (hgrow : b.toFinset.card < nb.toFinset.card) :
    BudgetStateGap U Tmax σ nb (expandOnceUnblocked b ord fc tr).2 ∧
      budgetPotentialGap U Tmax σ nb (expandOnceUnblocked b ord fc tr).2
        < budgetPotentialGap U Tmax σ b ord := by
  obtain ⟨hinv, hbU, hbud, hfix, hfrom⟩ := hst
  have hstab : SigmaFixed σ b := sigmaFixed_of_sigmaFormulaFixed hfix
  have hfix' : SigmaFormulaFixed σ nb :=
    sigmaFormulaFixed_grow_of_fixesFrom hfix hfrom (fun t ht =>
      (unorderedSuccessor_time_dichotomy hinv.ordTimesKnown nb hmem t ht).imp id
        (fun h => le_of_eq h.symm))
  have hfrom' : SigmaFixesFormulasFrom σ nb.nextTime :=
    sigmaFixesFormulasFrom_mono hfrom (nextTime_monotone_along_run.1 nb hmem)
  have hnbU : ∀ x ∈ nb, x ∈ U := hUcl.1 b ord tr hbU nb hmem
  have hinv' : RunInvariant nb (expandOnceUnblocked b ord fc tr).2 :=
    (expandOnceUnblocked_runInvariant hinv).1 nb hmem
  have hm' : mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
      ≤ mintPotential U σ b ord := mintPotential_expandOnceUnblocked nb hmem
  have hs' : selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
      ≤ selfGuardPotential U σ ord := selfGuardPotential_le_of_grow expandOnceUnblocked_ord_mono
  have hg' : gapPotential U σ (expandOnceUnblocked b ord fc tr).2
      ≤ gapPotential U σ ord := gapPotential_le_of_grow expandOnceUnblocked_ord_mono
  have hGW : (2 * (Tmax * Tmax + 1) + U.card)
        * gapPotential U σ (expandOnceUnblocked b ord fc tr).2
      ≤ (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ ord :=
    Nat.mul_le_mul_left _ hg'
  have hcU : b.toFinset.card ≤ U.card := card_le_of_subset_universe hbU
  have hc'U : nb.toFinset.card ≤ U.card := card_le_of_subset_universe hnbU
  rcases hmint σ b ord tr hinv hbU hstab nb hmem with
    ⟨hk, hR⟩ | ⟨hI, hmlt⟩ | ⟨hbud3, hslt⟩ | ⟨hbud4, hglt⟩
  · -- disjunct 1
    have hI : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
        ≤ mintTimeBudget U σ b ord := by simp only [mintTimeBudget]; omega
    have hEmul : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2 * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    have hSmul : (2 * (Tmax * Tmax + 1) + U.card)
          * selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
        ≤ (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord :=
      Nat.mul_le_mul_left _ hs'
    refine ⟨⟨hinv', hnbU, by omega, hfix', hfrom'⟩, ?_⟩
    simp only [budgetPotentialGap, budgetPotentialAt, budgetPotential, extensionAllowance]
    omega
  · -- disjunct 2: the landed case, with the fourth component along for the ride
    have hkT : nb.knownTimes.toFinset.card ≤ Tmax := by
      simp only [mintTimeBudget] at hI hbud; omega
    have hp' : (incompPairs nb (expandOnceUnblocked b ord fc tr).2).card ≤ Tmax * Tmax :=
      le_trans (incompPairs_card_le _ _) (Nat.mul_le_mul hkT hkT)
    have hEmul : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2 * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hSmul : (2 * (Tmax * Tmax + 1) + U.card)
          * selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
        ≤ (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord :=
      Nat.mul_le_mul_left _ hs'
    have hg1 : (nb.knownTimes.toFinset.card + mintPotential U σ nb
          (expandOnceUnblocked b ord fc tr).2) * (Tmax * Tmax + 1)
        ≤ (b.knownTimes.toFinset.card + mintPotential U σ b ord) * (Tmax * Tmax + 1) := by
      refine Nat.mul_le_mul_right _ ?_
      simpa only [mintTimeBudget] using hI
    have hg3 : (mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 + 1)
          * (Tmax * Tmax + 1)
        ≤ mintPotential U σ b ord * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ hmlt
    have he1 : (nb.knownTimes.toFinset.card + mintPotential U σ nb
          (expandOnceUnblocked b ord fc tr).2) * (Tmax * Tmax + 1)
        = nb.knownTimes.toFinset.card * (Tmax * Tmax + 1)
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1) := by
      ring
    have he2 : (b.knownTimes.toFinset.card + mintPotential U σ b ord) * (Tmax * Tmax + 1)
        = b.knownTimes.toFinset.card * (Tmax * Tmax + 1)
          + mintPotential U σ b ord * (Tmax * Tmax + 1) := by ring
    have he3 : (mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 + 1)
          * (Tmax * Tmax + 1)
        = mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + (Tmax * Tmax + 1) := by ring
    have he4 : 2 * (Tmax * Tmax + 1) * mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
        = mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1) := by
      ring
    have he5 : 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord
        = mintPotential U σ b ord * (Tmax * Tmax + 1)
          + mintPotential U σ b ord * (Tmax * Tmax + 1) := by ring
    refine ⟨⟨hinv', hnbU, by omega, hfix', hfrom'⟩, ?_⟩
    simp only [budgetPotentialGap, budgetPotentialAt, budgetPotential, extensionAllowance,
      splitOrderedRank]
    omega
  · -- disjunct 3: the fourth component carries the step on its own
    have hbud3' : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2)
        + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
        ≤ (b.knownTimes.toFinset.card + mintPotential U σ b ord)
          + selfGuardPotential U σ ord := by
      simpa only [mintTimeBudget] using hbud3
    have hkT : nb.knownTimes.toFinset.card ≤ Tmax := by
      simp only [mintTimeBudget] at hbud; omega
    have hp' : (incompPairs nb (expandOnceUnblocked b ord fc tr).2).card ≤ Tmax * Tmax :=
      le_trans (incompPairs_card_le _ _) (Nat.mul_le_mul hkT hkT)
    have h1 : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2) * (Tmax * Tmax + 1)
        ≤ (b.knownTimes.toFinset.card + mintPotential U σ b ord
          + selfGuardPotential U σ ord) * (Tmax * Tmax + 1) :=
      Nat.mul_le_mul_right _ hbud3'
    have h3 : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2) * U.card
        ≤ (b.knownTimes.toFinset.card + mintPotential U σ b ord
          + selfGuardPotential U σ ord) * U.card :=
      Nat.mul_le_mul_right _ hbud3'
    have h2 : mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
        ≤ mintPotential U σ b ord * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ hm'
    have h4 : (selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 + 1)
          * (Tmax * Tmax + 1)
        ≤ selfGuardPotential U σ ord * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ hslt
    have e1 : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2) * (Tmax * Tmax + 1)
        = nb.knownTimes.toFinset.card * (Tmax * Tmax + 1)
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
            * (Tmax * Tmax + 1) := by ring
    have e2 : (b.knownTimes.toFinset.card + mintPotential U σ b ord
          + selfGuardPotential U σ ord) * (Tmax * Tmax + 1)
        = b.knownTimes.toFinset.card * (Tmax * Tmax + 1)
          + mintPotential U σ b ord * (Tmax * Tmax + 1)
          + selfGuardPotential U σ ord * (Tmax * Tmax + 1) := by ring
    have e3 : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2) * U.card
        = mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2 * U.card
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * U.card := by
      simp only [mintTimeBudget]; ring
    have e4 : (b.knownTimes.toFinset.card + mintPotential U σ b ord
          + selfGuardPotential U σ ord) * U.card
        = mintTimeBudget U σ b ord * U.card + selfGuardPotential U σ ord * U.card := by
      simp only [mintTimeBudget]; ring
    have e5 : (selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 + 1)
          * (Tmax * Tmax + 1)
        = selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + (Tmax * Tmax + 1) := by ring
    have e6 : 2 * (Tmax * Tmax + 1) * mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
        = mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1) := by
      ring
    have e7 : 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord
        = mintPotential U σ b ord * (Tmax * Tmax + 1)
          + mintPotential U σ b ord * (Tmax * Tmax + 1) := by ring
    have e8 : (2 * (Tmax * Tmax + 1) + U.card)
          * selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
        = selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * U.card := by ring
    have e9 : (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord
        = selfGuardPotential U σ ord * (Tmax * Tmax + 1)
          + selfGuardPotential U σ ord * (Tmax * Tmax + 1)
          + selfGuardPotential U σ ord * U.card := by ring
    refine ⟨⟨hinv', hnbU, by omega, hfix', hfrom'⟩, ?_⟩
    simp only [budgetPotentialGap, budgetPotentialAt, budgetPotential, extensionAllowance,
      splitOrderedRank]
    omega
  · -- disjunct 4: the density case, where the gap coordinate carries the step on its own
    have hbud4' : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2)
        + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
        + gapPotential U σ (expandOnceUnblocked b ord fc tr).2
        ≤ (b.knownTimes.toFinset.card + mintPotential U σ b ord)
          + selfGuardPotential U σ ord + gapPotential U σ ord := by
      simpa only [mintTimeBudget] using hbud4
    have hkT : nb.knownTimes.toFinset.card ≤ Tmax := by
      simp only [mintTimeBudget] at hbud; omega
    have hp' : (incompPairs nb (expandOnceUnblocked b ord fc tr).2).card ≤ Tmax * Tmax :=
      le_trans (incompPairs_card_le _ _) (Nat.mul_le_mul hkT hkT)
    have h1 : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
          + gapPotential U σ (expandOnceUnblocked b ord fc tr).2) * (Tmax * Tmax + 1)
        ≤ (b.knownTimes.toFinset.card + mintPotential U σ b ord
          + selfGuardPotential U σ ord + gapPotential U σ ord) * (Tmax * Tmax + 1) :=
      Nat.mul_le_mul_right _ hbud4'
    have h3 : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
          + gapPotential U σ (expandOnceUnblocked b ord fc tr).2) * U.card
        ≤ (b.knownTimes.toFinset.card + mintPotential U σ b ord
          + selfGuardPotential U σ ord + gapPotential U σ ord) * U.card :=
      Nat.mul_le_mul_right _ hbud4'
    have h2 : mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
        ≤ mintPotential U σ b ord * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ hm'
    have hS1 : selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
        ≤ selfGuardPotential U σ ord * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ hs'
    have h4 : (gapPotential U σ (expandOnceUnblocked b ord fc tr).2 + 1) * (Tmax * Tmax + 1)
        ≤ gapPotential U σ ord * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ hglt
    have e1 : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
          + gapPotential U σ (expandOnceUnblocked b ord fc tr).2) * (Tmax * Tmax + 1)
        = nb.knownTimes.toFinset.card * (Tmax * Tmax + 1)
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + gapPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1) := by ring
    have e2 : (b.knownTimes.toFinset.card + mintPotential U σ b ord
          + selfGuardPotential U σ ord + gapPotential U σ ord) * (Tmax * Tmax + 1)
        = b.knownTimes.toFinset.card * (Tmax * Tmax + 1)
          + mintPotential U σ b ord * (Tmax * Tmax + 1)
          + selfGuardPotential U σ ord * (Tmax * Tmax + 1)
          + gapPotential U σ ord * (Tmax * Tmax + 1) := by ring
    have e3 : (nb.knownTimes.toFinset.card
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
          + gapPotential U σ (expandOnceUnblocked b ord fc tr).2) * U.card
        = mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2 * U.card
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * U.card
          + gapPotential U σ (expandOnceUnblocked b ord fc tr).2 * U.card := by
      simp only [mintTimeBudget]; ring
    have e4 : (b.knownTimes.toFinset.card + mintPotential U σ b ord
          + selfGuardPotential U σ ord + gapPotential U σ ord) * U.card
        = mintTimeBudget U σ b ord * U.card + selfGuardPotential U σ ord * U.card
          + gapPotential U σ ord * U.card := by
      simp only [mintTimeBudget]; ring
    have e5 : (gapPotential U σ (expandOnceUnblocked b ord fc tr).2 + 1) * (Tmax * Tmax + 1)
        = gapPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + (Tmax * Tmax + 1) := by ring
    have e6 : 2 * (Tmax * Tmax + 1) * mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
        = mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1) := by
      ring
    have e7 : 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord
        = mintPotential U σ b ord * (Tmax * Tmax + 1)
          + mintPotential U σ b ord * (Tmax * Tmax + 1) := by ring
    have e8 : (2 * (Tmax * Tmax + 1) + U.card)
          * selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
        = selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 * U.card := by ring
    have e9 : (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord
        = selfGuardPotential U σ ord * (Tmax * Tmax + 1)
          + selfGuardPotential U σ ord * (Tmax * Tmax + 1)
          + selfGuardPotential U σ ord * U.card := by ring
    have e10 : (2 * (Tmax * Tmax + 1) + U.card)
          * gapPotential U σ (expandOnceUnblocked b ord fc tr).2
        = gapPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + gapPotential U σ (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + gapPotential U σ (expandOnceUnblocked b ord fc tr).2 * U.card := by ring
    have e11 : (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ ord
        = gapPotential U σ ord * (Tmax * Tmax + 1)
          + gapPotential U σ ord * (Tmax * Tmax + 1)
          + gapPotential U σ ord * U.card := by ring
    refine ⟨⟨hinv', hnbU, by omega, hfix', hfrom'⟩, ?_⟩
    simp only [budgetPotentialGap, budgetPotentialAt, budgetPotential, extensionAllowance,
      splitOrderedRank]
    omega

/-- **The per-step bundle at the five-component measure.**
`stepDecreases_budgetPotentialAt_fixed` with `MintPaysForTimeGap` where that one takes
`MintPaysForTimeFixed`, and the two step lemmas above in place of their four-component
predecessors. Nothing else differs. -/
theorem stepDecreases_budgetPotentialGap {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax D β : Nat} (hβ : 3 ≤ β)
    (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeGap fc U Tmax) :
    StepDecreases fc (BudgetStateGap U Tmax) (budgetPotentialGap U Tmax) D β := by
  intro σ b ord tr hst
  refine ⟨?_, ?_, ?_⟩
  · intro nb hres
    have hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      rw [hres]; simp [unorderedSuccessorBranches]
    exact ⟨σ, budgetPotentialGap_step_unordered hUcl hmint hst hmem
      (expandOnceUnblocked_card_lt hres)⟩
  · intro bs hres
    have hmem : ∀ nb ∈ bs,
        nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      intro nb hnb; rw [hres]; simpa [unorderedSuccessorBranches] using hnb
    refine ⟨le_trans (expandOnceUnblocked_split_arity_le hres) hβ, ?_, ?_⟩
    · intro nb hnb
      exact (hD b ord tr hst.2.1).1 nb (hmem nb hnb)
    · intro nb hnb
      exact ⟨σ, budgetPotentialGap_step_unordered hUcl hmint hst (hmem nb hnb)
        (expandOnceUnblocked_split_card_lt hres hnb)⟩
  · intro bs hres
    have harity : bs.length ≤ β := by
      obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hres
      simpa using hβ
    exact ⟨harity, (hD b ord tr hst.2.1).2 bs hres,
      budgetPotentialGap_step_splitOrdered hUcl hst hres⟩

end FormalSystem.Metalogic.Decidability

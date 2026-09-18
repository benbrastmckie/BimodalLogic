/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.TimeCensus
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.OrientedGate

/-! # The four-component measure

`budgetPotential` is byte-unchanged; this is a new declaration alongside it, additive in the literal
sense — the original plus one weighted summand.

**Two things had to change from the plan-time design, and both are findings rather than choices.**

*The state's budget clause is the mint budget **plus** the fourth component.* A self-guarded mint
necessarily raises `mintTimeBudget`: it adds a time to `knownTimes` and leaves `mintPotential`
alone, because `untlNeg` and `snceNeg` are not in `freshLabelRules`. So `BudgetState` cannot survive
the very step the fourth component exists to pay for, and no weight fixes that — the failure is in
the state predicate, not in the measure. `BudgetStateAt` carries
`mintTimeBudget + selfGuardPotential ≤ Tmax` instead, and the arithmetic works because the mint
spends exactly one unit of the fourth component to buy the one unit of mint budget it consumes. That
is the component *funding* the budget rather than sitting beside it, and it is why the repaired
predicate's third disjunct has to be a **pair**.

*The third disjunct is a pair, mirroring disjunct 2.* Disjunct 2 pairs a `mintPotential` drop with a
`mintTimeBudget` non-increase; disjunct 3 pairs a `selfGuardPotential` drop with a
**combined**-budget non-increase. Without the second conjunct `extensionAllowance` is unbounded
above at the step — it carries a factor of `|U|` per unit of mint budget — and the measure does not
fall. This is why `MintPaysForTimeAt → MintPaysForTimeStable` is unavailable and is not claimed.

*The weight is `2·(Tmax² + 1) + |U|`, not `2·(Tmax² + 1)`.* The extra `|U|` is exactly what pays for
`extensionAllowance`'s rise across a step that spends combined budget. The plan-time figure was read
off `splitOrderedRank`'s rise alone and did not account for the allowance; the correction is
recorded here rather than absorbed.

Neither change touches a landed declaration, and neither is a new hypothesis on any caller:
`BudgetStateAt`'s clause is a *strengthening* of `BudgetState`'s, discharged at the seed by choosing
`Tmax` with the slack `selfGuardPotential_le_two_mul` bounds at `2·|U|` — a figure enlargement of
exactly the kind register entry 8 records. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The carried state, at the four-component measure.** `BudgetState`'s three clauses with the
third replaced by the *combined* budget: the mint budget plus the self-guard potential.

The combination is load-bearing, not cosmetic. A self-guarded mint raises `mintTimeBudget` by one
and lowers `selfGuardPotential` by at least one, so the sum is non-increasing at exactly the step
the plain clause fails at. Measured at the oriented gate: `26 + 3 = 29` before, `27 + 1 = 28` after
(`orientedGate_disjunct3_holds`). -/
def BudgetStateAt (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Prop :=
  RunInvariant b ord ∧ (∀ x ∈ b, x ∈ U) ∧
    mintTimeBudget U σ b ord + selfGuardPotential U σ ord ≤ Tmax ∧
    SigmaTimeFixed σ b ∧ SigmaFixesFrom σ b.nextTime
/-- **The four-component measure.** `budgetPotential` plus the self-guard coordinate at weight
`2·(Tmax² + 1) + |U|`.

The weight has to dominate everything a step that spends one unit of combined budget can add:
`(Tmax² + 1)` for the extra known time in `splitOrderedRank`, `Tmax²` for a full incomparable-pair
range (`incompPairs_card_le` at `knownTimes.card ≤ Tmax`), and `|U|` for `extensionAllowance`'s
per-budget-unit factor. `2·(Tmax² + 1) + |U|` clears all three with a unit to spare, which is why
the drop is by at least one however much the step mints. -/
def budgetPotentialAt (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Nat :=
  budgetPotential U Tmax σ b ord
    + (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord


/-- **Constraint (F), tested at the arm before the inequality is attempted.** The fourth component
does not rise at the ordered split's identification arm.

This is the plan's own gate on Phase 7 and it passes with equality-or-better:
`selfGuardPotential_identifyOriented` is exactly the statement, read at the arm's own
`(min t₁ t₂, max t₁ t₂)`. Had it failed, the phase would have been blocked rather than rescued by
re-weighting — the research shows re-weighting is unsatisfiable, since the mint-side rise scales
identically. -/
theorem selfGuardPotential_le_at_arm3 {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    selfGuardPotential U (fun x => rhoSF (min t₁ t₂) (max t₁ t₂) (σ x))
        (ord.identifyTime (min t₁ t₂) (max t₁ t₂))
      ≤ selfGuardPotential U σ ord :=
  selfGuardPotential_identifyOriented (b := b) htrig hirr


/-- **The measure drops at every arm of an ordered split, at the four-component measure.**

`budgetPotential_step_splitOrdered` re-proved, with exactly one additional input per arm — the
fourth component's non-increase, multiplied by the weight — and the state clause discharged from the
same inputs. Arms 1 and 2 get it from `selfGuardPotential_le_of_grow` (the arms only add an edge);
arm 3 gets it from `selfGuardPotential_le_at_arm3`. `hrk`, `hEmul` and `hEexp` are unchanged, which
is the plan's Scope Hypothesis for this phase confirmed rather than assumed.

No residual is consumed here: an ordered split does not mint, so the repaired predicate is not used
at all. -/
theorem budgetPotentialAt_step_splitOrdered {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {bs : List (Branch × TimeOrdering)}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosedAt fc U) (hst : BudgetStateAt U Tmax σ b ord)
    (hres : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, ∃ σ' : SignedFormula → SignedFormula, BudgetStateAt U Tmax σ' p.1 p.2 ∧
      budgetPotentialAt U Tmax σ' p.1 p.2 < budgetPotentialAt U Tmax σ b ord := by
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
    refine ⟨σ, ⟨hinvp, hbU, by omega, hfix, hfrom⟩, ?_⟩
    simp only [budgetPotentialAt, budgetPotential, extensionAllowance]
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
    refine ⟨σ, ⟨hinvp, hbU, by omega, hfix, hfrom⟩, ?_⟩
    simp only [budgetPotentialAt, budgetPotential, extensionAllowance]
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
    have hfix' : SigmaTimeFixed (fun x => rhoSF s u (σ x)) (b.identifyTime s u) :=
      sigmaTimeFixed_identifyOriented (ord := ord) (Ne.symm hne21) hmaxk hfix
    have hnextle : b.nextTime ≤ (b.identifyTime s u).nextTime :=
      nextTime_le_identifyTime_oriented b ord t₁ t₂
    have hfrom' : SigmaFixesFrom (fun x => rhoSF s u (σ x)) (b.identifyTime s u).nextTime :=
      sigmaFixesFrom_comp (sigmaFixesFrom_mono hfrom hnextle)
        (retired_lt_nextTime_oriented (b := b) ord hk1 hk2)
    refine ⟨fun x => rhoSF s u (σ x), ⟨hinvp, hIU, by omega, hfix', hfrom'⟩, ?_⟩
    simp only [budgetPotentialAt, budgetPotential, extensionAllowance]
    omega


/-- **The measure drops at `.extended` and at every arm of a `.split`, at the four-component
measure.**

`budgetPotential_step_unordered` re-proved against `MintPaysForTimeStable`. Disjuncts 1 and 2 are
the landed cases with the fourth component along for the ride — it cannot rise, since an unordered
step only grows the ordering (`expandOnceUnblocked_ord_mono`). Disjunct 3 is the new case and the
one the whole task is about: the self-guarded mint pays for itself.

*The disjunct-3 arithmetic, in one line.* The combined-budget conjunct caps the rise in
`extensionAllowance` at `|U|` per unit of self-guard drop and the rise in `splitOrderedRank` at
`(Tmax² + 1)` per unit plus one incomparable-pair range; the weight `2·(Tmax² + 1) + |U|` pays for
all of it and leaves `(Tmax² + 1) − Tmax² = 1` over, and `hgrow` supplies one more. So the drop is
by at least two.

`hstab` is the repaired predicate's own added hypothesis, threaded through unchanged; it is
discharged at the seed by `sigmaTimeFixed_id` and at the identification arm by
`sigmaTimeFixed_identifyOriented`. -/
theorem budgetPotentialAt_step_unordered {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosedAt fc U) (hmint : MintPaysForTimeStable fc U Tmax)
    (hst : BudgetStateAt U Tmax σ b ord)
    (hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1)
    (hgrow : b.toFinset.card < nb.toFinset.card) :
    BudgetStateAt U Tmax σ nb (expandOnceUnblocked b ord fc tr).2 ∧
      budgetPotentialAt U Tmax σ nb (expandOnceUnblocked b ord fc tr).2
        < budgetPotentialAt U Tmax σ b ord := by
  obtain ⟨hinv, hbU, hbud, hfix, hfrom⟩ := hst
  have hstab : SigmaTimeStable σ b := sigmaTimeStable_of_sigmaTimeFixed hfix
  have hfix' : SigmaTimeFixed σ nb :=
    sigmaTimeFixed_grow_of_fixesFrom hfix hfrom (fun t ht =>
      (unorderedSuccessor_time_dichotomy hinv.ordTimesKnown nb hmem t ht).imp id
        (fun h => le_of_eq h.symm))
  have hfrom' : SigmaFixesFrom σ nb.nextTime :=
    sigmaFixesFrom_mono hfrom (nextTime_monotone_along_run.1 nb hmem)
  have hnbU : ∀ x ∈ nb, x ∈ U := hUcl.1 b ord tr hbU nb hmem
  have hinv' : RunInvariant nb (expandOnceUnblocked b ord fc tr).2 :=
    (expandOnceUnblocked_runInvariant hinv).1 nb hmem
  have hm' : mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
      ≤ mintPotential U σ b ord := mintPotential_expandOnceUnblocked nb hmem
  have hs' : selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
      ≤ selfGuardPotential U σ ord := selfGuardPotential_le_of_grow expandOnceUnblocked_ord_mono
  have hcU : b.toFinset.card ≤ U.card := card_le_of_subset_universe hbU
  have hc'U : nb.toFinset.card ≤ U.card := card_le_of_subset_universe hnbU
  rcases hmint σ b ord tr hinv hbU hstab nb hmem with ⟨hk, hR⟩ | ⟨hI, hmlt⟩ | ⟨hbud3, hslt⟩
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
    simp only [budgetPotentialAt, budgetPotential, extensionAllowance]
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
    simp only [budgetPotentialAt, budgetPotential, extensionAllowance, splitOrderedRank]
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
    simp only [budgetPotentialAt, budgetPotential, extensionAllowance, splitOrderedRank]
    omega


/-! #### The per-step bundle and the fuel figure at the four-component measure

Section C6's induction is genuinely abstract over the carried state, the measure and the invariant —
`StepDecreases` mentions no branch cardinality, no known-time count, no mint potential and no
ordering rank — so this is an **instantiation**, not a re-proof. The plan's Scope Hypothesis for
this phase asked that that be confirmed before anything was written rather than assumed; it is
confirmed: `stepDecreases_budgetPotentialAt` below is `stepDecreases_budgetPotential`'s proof with
the two step lemmas swapped and nothing else changed.

The figure enlarges by the fourth component's ceiling times its weight,
`(2·(Tmax² + 1) + |U|)·2·|U|` — `selfGuardPotential_le_two_mul` is the ceiling — in exactly the
shape `splitAwareFuel_le_mintAwareFuel` records for the previous enlargement. Nothing stated at the
landed figure is withdrawn. -/

/-- **The per-step bundle, discharged at the four-component measure.** Byte-for-byte
`stepDecreases_budgetPotential` with `budgetPotentialAt_step_unordered` and
`budgetPotentialAt_step_splitOrdered` in place of their three-component originals: `hβ`, `hD`, the
arity facts and the difficulty facts are all reached through `hst.2.1`, which is the confinement
clause both state predicates share in the same position. -/
theorem stepDecreases_budgetPotentialAt {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax D β : Nat} (hβ : 3 ≤ β)
    (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeStable fc U Tmax) :
    StepDecreases fc (BudgetStateAt U Tmax) (budgetPotentialAt U Tmax) D β := by
  intro σ b ord tr hst
  refine ⟨?_, ?_, ?_⟩
  · intro nb hres
    have hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      rw [hres]; simp [unorderedSuccessorBranches]
    exact ⟨σ, budgetPotentialAt_step_unordered hUcl hmint hst hmem
      (expandOnceUnblocked_card_lt hres)⟩
  · intro bs hres
    have hmem : ∀ nb ∈ bs,
        nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      intro nb hnb; rw [hres]; simpa [unorderedSuccessorBranches] using hnb
    refine ⟨le_trans (expandOnceUnblocked_split_arity_le hres) hβ, ?_, ?_⟩
    · intro nb hnb
      exact (hD b ord tr hst.2.1).1 nb (hmem nb hnb)
    · intro nb hnb
      exact ⟨σ, budgetPotentialAt_step_unordered hUcl hmint hst (hmem nb hnb)
        (expandOnceUnblocked_split_card_lt hres hnb)⟩
  · intro bs hres
    have harity : bs.length ≤ β := by
      obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hres
      simpa using hβ
    exact ⟨harity, (hD b ord tr hst.2.1).2 bs hres,
      budgetPotentialAt_step_splitOrdered hUcl hst hres⟩

/-- **The derived path bound at the four-component measure.** `mintPathBound` plus the fourth
component's ceiling times its weight. `selfGuardPotential ≤ 2·|U|` is the ceiling
(`selfGuardPotential_le_two_mul`), and the weight is `2·(Tmax² + 1) + |U|`. -/
def mintPathBoundAt (Ucard Tmax mintBudget : Nat) : Nat :=
  mintPathBound Ucard Tmax mintBudget
  + (2 * (Tmax * Tmax + 1) + Ucard) * (2 * Ucard)

/-- **The derived fuel figure at the four-component measure**, the landed one evaluated at the
enlarged path bound. -/
def mintAwareFuelAt (Ucard Tmax mintBudget D β : Nat) : Nat :=
  fuelFigure D β (mintPathBoundAt Ucard Tmax mintBudget)

/-- The enlarged path bound is an **enlargement** of the landed one, never a replacement. -/
theorem mintPathBound_le_mintPathBoundAt (Ucard Tmax mintBudget : Nat) :
    mintPathBound Ucard Tmax mintBudget ≤ mintPathBoundAt Ucard Tmax mintBudget := by
  simp only [mintPathBoundAt]; omega

/-- …and so is the fuel figure, so nothing stated at `mintAwareFuel` — or, through
`splitAwareFuel_le_mintAwareFuel`, at `splitAwareFuel` — is withdrawn. This is the sense in which
the fourth component's only cost is a **coefficient**: the whole chain of figures still reads
`splitAwareFuel ≤ mintAwareFuel ≤ mintAwareFuelAt`, and no caller's hypothesis list changes. -/
theorem mintAwareFuel_le_mintAwareFuelAt (Ucard Tmax mintBudget D β : Nat) :
    mintAwareFuel Ucard Tmax mintBudget D β ≤ mintAwareFuelAt Ucard Tmax mintBudget D β :=
  fuelFigure_mono (mintPathBound_le_mintPathBoundAt _ _ _)

/-- …and the whole chain, in one statement, so a reader does not have to compose it. -/
theorem splitAwareFuel_le_mintAwareFuelAt (Ucard Tmax mintBudget D β : Nat) :
    splitAwareFuel Ucard Tmax D β ≤ mintAwareFuelAt Ucard Tmax mintBudget D β :=
  le_trans (splitAwareFuel_le_mintAwareFuel _ _ _ _ _)
    (mintAwareFuel_le_mintAwareFuelAt _ _ _ _ _)

/-- **The four-component measure sits under the enlarged path bound.** The one arithmetic fact
connecting the induction to a concrete figure, at the repaired measure.

Three of the four components are capped exactly as `budgetPotential_lt_mintPathBound` caps them;
the fourth is capped by `selfGuardPotential_le_two_mul`, whose coefficient is the index set's width
and not `|U|`-dependent in any other way. Note the state's budget clause is the *combined* one, so
`hbud` gives the mint budget a bound with room for the self-guard potential rather than on the
nose — which is why the mint-side inputs are re-derived here rather than reused. -/
theorem budgetPotentialAt_lt_mintPathBoundAt {U : Finset SignedFormula} {Tmax mintBudget : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hst : BudgetStateAt U Tmax σ b ord) (hmb : 8 * U.card ≤ mintBudget) :
    budgetPotentialAt U Tmax σ b ord < mintPathBoundAt U.card Tmax mintBudget := by
  obtain ⟨hinv, hbU, hbud, -, -⟩ := hst
  have hkT : b.knownTimes.toFinset.card ≤ Tmax := by
    simp only [mintTimeBudget] at hbud; omega
  have hm8 := mintPotential_le_eight_mul U σ b ord
  have hs2 := selfGuardPotential_le_two_mul U σ ord
  have hR := splitOrderedRank_le Tmax b ord hkT
  have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord
      ≤ 2 * (Tmax * Tmax + 1) * mintBudget := Nat.mul_le_mul_left _ (by omega)
  have hEmul : mintTimeBudget U σ b ord * U.card ≤ Tmax * U.card :=
    Nat.mul_le_mul_right _ (by simp only [mintTimeBudget] at hbud ⊢; omega)
  have hSmul : (2 * (Tmax * Tmax + 1) + U.card) * selfGuardPotential U σ ord
      ≤ (2 * (Tmax * Tmax + 1) + U.card) * (2 * U.card) := Nat.mul_le_mul_left _ hs2
  simp only [budgetPotentialAt, budgetPotential, extensionAllowance, mintPathBoundAt,
    mintPathBound]
  omega

/-! #### The terminus chain, restated at the repaired predicate

The six theorems below are the `_at` chain with `MintPaysForTime` exchanged for
`MintPaysForTimeStable`, `BudgetState` for `BudgetStateAt`, `budgetPotential` for
`budgetPotentialAt`, and `mintAwareFuel` for `mintAwareFuelAt`. **The originals are untouched** and
nothing stated at them is withdrawn — `mintAwareFuel_le_mintAwareFuelAt` is the statement that the
figures compose rather than compete.

*The classification, run before anything was restated.* `grep MintPaysForTime` reports eleven
hypothesis sites in this file. Nine are intermediate — the step lemmas, `stepDecreases`,
`expandBranchWithFuel_isSome_of_budget`, `buildTableauAt_isSome_of_budget` and their `_at` siblings
— and pass the residual on without inspecting it. Exactly **two** are seed-level, in the sense that
they quantify no `U` and read every number off a concrete `signedUniverse C L`:
`buildTableauAt_isSome_of_lengthBudget_signedUniverse` and
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`. Both are restated below; the parent
plan's Scope Hypothesis named a different pair (`buildTableauAt_isSome_at_seed` and
`..._at_seed_lengthBudget`), and the correction is that those two still quantify `U` — they are
seed-level in the *fuel* coordinate only.

*The only new number.* The mint budget floor rises from `8·|U|` to `10·|U|`, because the carried
state's budget clause is now the combined one and `selfGuardPotential ≤ 2·|U|`. `derivedTmaxAt`
carries the same enlargement into the caller-facing form. That is a figure, not a hypothesis: no
caller's hypothesis *list* changes, and `derivedTmax_le_derivedTmaxAt` records that the time bound
grows rather than moves. -/

/-- **The derived time bound at the four-component measure.** The initial known-time count plus the
enlarged mint budget: `8·|U|` for the mint dimension and `2·|U|` for the self-guard dimension, the
two ceilings `mintPotential_le_eight_mul` and `selfGuardPotential_le_two_mul` supply. -/
def derivedTmaxAt (kt0 Ucard : Nat) : Nat := kt0 + 10 * Ucard

/-- The enlarged time hypothesis is satisfied at `derivedTmaxAt`, definitionally — the same sense in
which `derivedTmax_spec` makes the mint budget a discharged parameter rather than a caller
obligation. -/
theorem derivedTmaxAt_spec (b : Branch) (U : Finset SignedFormula) :
    b.knownTimes.toFinset.card + 10 * U.card
      ≤ derivedTmaxAt (b.knownTimes.toFinset.card) U.card := Nat.le_refl _

/-- The enlarged bound is an **enlargement**, never a replacement. -/
theorem derivedTmax_le_derivedTmaxAt (kt0 Ucard : Nat) :
    derivedTmax kt0 Ucard ≤ derivedTmaxAt kt0 Ucard := by
  simp only [derivedTmax, derivedTmaxAt]; omega

/-- `BudgetedTotalityAt` at the four-component measure: the enlarged fuel figure and the enlarged
mint-budget floor, everything else unchanged. -/
def BudgetedTotalitySelfGuarded (fc : FormalSystem.ProofSystem.FrameClass)
    (U : Finset SignedFormula) (mintBudget Tmax D β : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker) (applied : AppliedSet)
    (maxBranches branchesUsed : Nat),
    (∀ x ∈ b, x ∈ U) →
    RunInvariant b ord →
    10 * U.card ≤ mintBudget →
    b.knownTimes.toFinset.card + mintBudget ≤ Tmax →
    branchesUsed + β * mintAwareFuelAt U.card Tmax mintBudget D β ≤ maxBranches →
    (expandBranchWithFuel b (mintAwareFuelAt U.card Tmax mintBudget D β) ord fc tr applied
      maxBranches branchesUsed).isSome = true

/-- `expandBranchWithFuel_isSome_of_budget_at` at the repaired predicate.

The seed state is built at `σ = id`, where both σ clauses are free — `sigmaTimeFixed_id` and
`sigmaFixesFrom_id` — so the repaired predicate's added hypothesis costs the caller nothing here.
The combined budget clause is where the enlarged floor is consumed. -/
theorem expandBranchWithFuel_isSome_of_budget_selfGuarded
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax D β : Nat}
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeStable fc U Tmax) (harm : ArmSettlement fc) :
    BudgetedTotalitySelfGuarded fc U mintBudget Tmax D β := by
  intro b ord tr applied maxBranches branchesUsed hbU hinv hmb hT hbud
  have hst : BudgetStateAt U Tmax id b ord := by
    refine ⟨hinv, hbU, ?_, sigmaTimeFixed_id b, sigmaFixesFrom_id _⟩
    have h8 := mintPotential_le_eight_mul U id b ord
    have h2 := selfGuardPotential_le_two_mul U id ord
    simp only [mintTimeBudget]
    omega
  exact expandBranchWithFuel_isSome_of_measure (by omega)
    (stepDecreases_budgetPotentialAt hβ hUcl hD hmint)
    harm (mintPathBoundAt U.card Tmax mintBudget) id _ b ord tr applied maxBranches branchesUsed
    hst (budgetPotentialAt_lt_mintPathBoundAt hst (by omega)) (Nat.le_refl _) hbud

/-- **THE TERMINUS, at the repaired predicate.** `buildTableauAt_isSome_of_budget_at` with
`MintPaysForTime` exchanged for `MintPaysForTimeStable`.

The exchange is a **strengthening**: the hypothesis is weaker
(`mintPaysForTimeStable_of_mintPaysForTime`), for the same reason and in the same sense that
`UniverseClosedAt` strengthened its predecessor. The other three residuals are carried across
unaltered and are still named — `DifficultyBounded`, `PostBlockingSettles`, and `UniverseClosedAt`.
Nothing above is withdrawn. -/
theorem buildTableauAt_isSome_of_budget_selfGuarded
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax D β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeStable fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt U.card Tmax mintBudget D β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuelAt U.card Tmax mintBudget D β) fc maxBranches).isSome
      = true := by
  refine buildTableauAt_isSome_of_settles hpb ?_
  exact expandBranchWithFuel_isSome_of_budget_selfGuarded hβ hUcl hD hmint
    (armSettlement_of_postBlockingSettles hpb)
    (seedBranch phi) TimeOrdering.empty EventualityTracker.empty {} maxBranches 0
    hseed (runInvariant_initial _) hmb hT (by omega)

/-- `buildTableauAt_isSome_at_seed_at` at the repaired predicate, with every number read off. -/
theorem buildTableauAt_isSome_at_seed_selfGuarded
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {D β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeStable fc U
      (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card))
    (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuelAt U.card (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) D β)
        fc
        (β * mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card) (10 * U.card) D β)
      ).isSome = true :=
  buildTableauAt_isSome_of_budget_selfGuarded phi _ hβ hUcl hD hmint hpb hseed (Nat.le_refl _)
    (derivedTmaxAt_spec (seedBranch phi) U) (Nat.le_refl _)

/-- `buildTableauAt_isSome_of_lengthBudget_at` at the repaired predicate — **three** refutable
residuals exchanged for satisfiable or weaker ones at once. -/
theorem buildTableauAt_isSome_of_lengthBudget_selfGuarded
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax L β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTimeStable fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β
      ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β) fc
        maxBranches).isSome = true :=
  buildTableauAt_isSome_of_budget_selfGuarded phi maxBranches hβ hUcl
    (difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint hpb hseed hmb hT hbud

/-- `buildTableauAt_isSome_at_seed_lengthBudget_at` at the repaired predicate. -/
theorem buildTableauAt_isSome_at_seed_lengthBudget_selfGuarded
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {L β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTimeStable fc U
      (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card))
    (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) (difficultyCeiling U L) β)
        fc
        (β * mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card) (10 * U.card)
          (difficultyCeiling U L) β)
      ).isSome = true :=
  buildTableauAt_isSome_at_seed_selfGuarded phi hβ hUcl
    (difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint hpb hseed

/-- **Seed-level terminus 1, restated at the repaired predicate**, at the concrete universe
`signedUniverse C L`.

`grep`-and-classify identified exactly two seed-level sites; this is the first. Every hypothesis is
the one the landed `buildTableauAt_isSome_of_lengthBudget_signedUniverse` carries, with
`MintPaysForTime` exchanged for `MintPaysForTimeStable` and the mint-budget floor read at `10·|U|`.
`UniverseClosedAt` is discharged here, not assumed: `universeClosedAt_signedUniverse_of_headroom`
pays it from a `TableauClosed`, `TrichStock` formula stock and a `TimeMergeClosed` label set. -/
theorem buildTableauAt_isSome_of_lengthBudget_signedUniverse_selfGuarded
    {fc : FormalSystem.ProofSystem.FrameClass}
    {C : Finset Formula} {L : Finset Label} {mintBudget Tmax L' β : Nat}
    (phi : Formula) (maxBranches : Nat) (hβ : 3 ≤ β)
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L)
    (hSL : StepLengthBounded fc (signedUniverse C L) L')
    (hmint : MintPaysForTimeStable fc (signedUniverse C L) Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ signedUniverse C L)
    (hmb : 10 * (signedUniverse C L).card ≤ mintBudget)
    (hT' : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt (signedUniverse C L).card Tmax mintBudget
      (difficultyCeiling (signedUniverse C L) L') β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuelAt (signedUniverse C L).card Tmax mintBudget
        (difficultyCeiling (signedUniverse C L) L') β) fc maxBranches).isSome = true :=
  buildTableauAt_isSome_of_lengthBudget_selfGuarded phi maxBranches hβ
    (universeClosedAt_signedUniverse_of_headroom hC hT hL hlab) hSL hmint hpb hseed hmb hT' hbud

/-- **Seed-level terminus 2, restated at the repaired predicate** — the caller-facing form, every
number read off, at the concrete universe `signedUniverse C L`.

This is the deliverable's terminus. A caller supplies a `TableauClosed`, `TrichStock` formula
stock, a `TimeMergeClosed` label set (any rectangle), a length bound, and the three unchanged
residuals — `MintPaysForTimeStable`, `PostBlockingSettles`, `UnorderedSuccessorLabelClosed` — and
reads the fuel and the branch budget off the statement.

*What changed relative to `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`.* One
residual is weaker (`MintPaysForTimeStable` in place of `MintPaysForTime`,
`mintPaysForTimeStable_of_mintPaysForTime`), and two figures are larger (`mintAwareFuelAt`,
`derivedTmaxAt`, both recorded as enlargements). The hypothesis **list** is identical, name for
name. That is the whole cost of the fourth measure component at the caller's boundary. -/
theorem buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_selfGuarded
    {fc : FormalSystem.ProofSystem.FrameClass}
    {C : Finset Formula} {L : Finset Label} {L' β : Nat} (phi : Formula) (hβ : 3 ≤ β)
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L)
    (hSL : StepLengthBounded fc (signedUniverse C L) L')
    (hmint : MintPaysForTimeStable fc (signedUniverse C L)
      (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) (signedUniverse C L).card))
    (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ signedUniverse C L) :
    (buildTableauAt phi
        (mintAwareFuelAt (signedUniverse C L).card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card)
            (signedUniverse C L).card)
          (10 * (signedUniverse C L).card)
          (difficultyCeiling (signedUniverse C L) L') β)
        fc
        (β * mintAwareFuelAt (signedUniverse C L).card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card)
            (signedUniverse C L).card)
          (10 * (signedUniverse C L).card)
          (difficultyCeiling (signedUniverse C L) L') β)
      ).isSome = true :=
  buildTableauAt_isSome_at_seed_lengthBudget_selfGuarded phi hβ
    (universeClosedAt_signedUniverse_of_headroom hC hT hL hlab) hSL hmint hpb hseed

/-! #### The repaired predicate discharged, and the boundary at which it stops

`mintPaysForTime_empty` records the satisfiability boundary for the landed predicate: the residual
is satisfiable exactly where the terminus it guards has nothing to say, since `signedUniverse C L`
is empty only when `C` or `L` is. The repaired predicate inherits that boundary verbatim, and the
discharge below is stated at a **concrete** `signedUniverse C L` rather than at the bare `∅`, so it
instantiates the seed-level termini above rather than only their `U`-quantified ancestors.

**What blocks a discharge at a nonempty universe, precisely.** It is the density coordinate, and
not the σ-hit obligation any more. *(Corrected below: this account is incomplete. The subsection
"The formula-level σ obligation, and the refutation it forces" decides that
`MintPaysForTimeStable` is **false** at a concrete nonempty `signedUniverse`, with no `densityRule`
in the vehicle — the time-level σ hypothesis does not reach the formula-level obligation disjunct 2
carries. Read the paragraph below as one of two blockers, not the only one; see register entry
20.)* `densityRule` mints a fresh time and lies outside **both**
`freshLabelRules` and `selfGuardRules`, so at a `densityRule` step disjunct 1 fails (the mint raises
`knownTimes`), disjunct 2 cannot move (`mintPotential` does not read the rule) and disjunct 3 cannot
move (`selfGuardDischarged` reports the catch-all `true` for it). That is the residual
`MintPaysForTimeAt`'s obligation map already names, carried here unchanged: the intended second
component is `gapPotential`, indexed by `U ×ˢ U` and gated on `denseRules`, and it is implemented
nowhere and assumed by nothing.

`densityRule` is `denseRules`-gated, so it cannot fire at a frame class outside `.Dense` /
`.RTime`; a discharge restricted to the other classes is therefore not refuted. What it needs is
a rule-by-rule census showing that every remaining rule either mints no time (disjunct 1), is
witness-guarded (disjunct 2) or is self-guarded (disjunct 3). That census is the parent plan's
time-minting-census work read in the other direction, and it is **not attempted here** — stated as
a named next step rather than gestured at. See register entries 19 and 20. -/

/-- **The satisfiability boundary, at the repaired predicate.** The exact mirror of
`mintPaysForTime_empty`, and for the same reason: confinement forces the branch empty, the engine
reports `.saturated`, and `unorderedSuccessorBranches` of a `.saturated` result is `[]`.

The added `SigmaTimeStable` hypothesis is discarded rather than used, which is the honest reading —
this discharge is about the universe being empty, not about the renaming. -/
theorem mintPaysForTimeStable_empty (fc : FormalSystem.ProofSystem.FrameClass) (Tmax : Nat) :
    MintPaysForTimeStable fc ∅ Tmax := by
  intro _ b ord tr _ hconf _ nb hnb
  have hb : b = [] := List.eq_nil_iff_forall_not_mem.mpr fun x hx => by simpa using hconf x hx
  subst hb
  simp [expandOnceUnblocked, findUnexpandedUnblockedWith, unorderedSuccessorBranches] at hnb

/-- `signedUniverse C L` is empty when `L` is — the fact that turns the boundary above into a
statement about a concrete `signedUniverse`. -/
theorem signedUniverse_empty_labels (C : Finset Formula) :
    signedUniverse C (∅ : Finset Label) = ∅ := by
  simp [signedUniverse]

/-- **The repaired predicate, discharged at a concrete `signedUniverse C L`**, at every frame class
and every `Tmax`.

This is the instantiation the seed-level termini above consume: `hmint` is supplied rather than
assumed, so
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_selfGuarded` reads with one residual
fewer at `L = ∅`. It is also, by `mintPaysForTime_empty`'s own argument, exactly as far as the
predicate can be discharged without the density coordinate: see the subsection preamble for what a
nonempty discharge needs, and register entry 19 for the record. -/
theorem mintPaysForTimeStable_signedUniverse_empty
    (fc : FormalSystem.ProofSystem.FrameClass) (C : Finset Formula) (Tmax : Nat) :
    MintPaysForTimeStable fc (signedUniverse C (∅ : Finset Label)) Tmax := by
  rw [signedUniverse_empty_labels]
  exact mintPaysForTimeStable_empty fc Tmax

end FormalSystem.Metalogic.Decidability

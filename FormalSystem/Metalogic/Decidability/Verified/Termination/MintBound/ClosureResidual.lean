/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Terminus

/-! # C10. The repaired closure residual, and the chain stated at it

`UniverseClosed`'s second conjunct is refuted above at every nonempty `U`
(`universeClosed_identify_retime_false`), so the four theorems that assume it are conditionals no
caller can discharge. This section supplies the repair and restates the chain at it.

**The repair, and why it is exactly this.** Clause 2's defect is a single unconstrained quantifier:
the merge *target* `t₁`. `UniverseClosedAt` restricts it to `b.knownTimes` and changes nothing else
— clause 1 is carried verbatim and the merge *source* `t₂` stays free. Restricting `t₂` as well
would weaken the predicate for no gain, since the proof of
`timeMergeClosed_identifyTime_signedUniverse` below never appeals to it; register entry 12 records
that as a tempting-but-wrong repair.

**The restriction is free at every consuming site**, which is what makes this a repair rather than a
new caller obligation. Both sites that consume clause 2 reach `t₁` through
`expandOnceUnblocked_splitOrdered_shape`, which returns the trigger
`firstIncomparablePair b ord = some (t₁, t₂)` alongside the arms; `firstIncomparablePair_spec`
turns that trigger into `t₁ ∈ b.knownTimes` on the spot. So the hypothesis is discharged locally and
never surfaces on the terminus.

## DIVERGENCE, recorded: the chain is restated additively, not generalized in place

The plan's Phase 3 wrote this as an in-place generalization of the ten signatures carrying
`hUcl : UniverseClosed fc U`, with the original shapes retained afterwards as corollaries. It is
done the other way round here: **every one of those ten theorems is left byte-identical**, and the
chain at the repaired predicate is added alongside under `…_at` names. Two reasons, both of which
the plan's own acceptance criteria prefer:

* Its Testing & Validation asks that "every pre-existing theorem statement still resolves by name
  with the same statement". An in-place hypothesis-type change alters ten landed statements —
  including **the** terminus — and would have satisfied that criterion only by renaming the
  generalized forms anyway, which is what is done here directly.
* The landed terminus's proof terms stay untouched, so nothing about the parent development has to
  be re-verified.

The cost is that the two arithmetic step lemmas are restated rather than shared. They are not
weakened: `budgetPotential_step_unordered_at` and `budgetPotential_step_splitOrdered_at` have the
identical conclusions, and the only difference in either proof is which projection supplies
confinement. A reader who wants the shared form should factor the confinement facts out as
hypotheses (`∀ x ∈ nb, x ∈ U` for the unordered lemma, and the trigger-indexed form for the ordered
one) and derive all four from those two — that refactor would touch the landed proofs and is
deliberately not done here. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The repaired closure residual.** Clause 1 verbatim from `UniverseClosed`; clause 2 with the
merge target `t₁` restricted to a time the branch already knows.

`UniverseClosed` is strictly stronger — `universeClosedAt_of_universeClosed` is the implication, and
the converse fails at every nonempty `U` by `universeClosed_identify_retime_false`, so the two are
genuinely not interchangeable.

**What the repair does and does not fix, stated precisely.** It repairs clause **2**, which as
stated was satisfiable only at `U = ∅` and is now dischargeable at `U = signedUniverse C L` from a
closure condition on the label set (`timeMergeClosed_identifyTime_signedUniverse`). It does **not**
touch clause 1, which is carried verbatim and has an independent defect in its label coordinate:
`universeClosedAt_fresh_world_escapes` refutes this very predicate at a concrete
`signedUniverse C L`. So `UniverseClosedAt` is not satisfiable at an arbitrary `signedUniverse C L`
either. `universeClosedAt_signedUniverse_of_headroom` is what it takes — the two stock conditions,
the label closure condition, and one named residual for clause 1's label coordinate. -/
def UniverseClosedAt (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula) : Prop :=
  (∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), (∀ x ∈ b, x ∈ U) →
      ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb, x ∈ U) ∧
  (∀ (b : Branch) (t₁ t₂ : TimeIndex), (∀ x ∈ b, x ∈ U) → t₁ ∈ b.knownTimes →
      ∀ x ∈ b.identifyTime t₂ t₁, x ∈ U)

/-- **The direction, stated explicitly.** `UniverseClosedAt` is the **weaker** hypothesis, so every
theorem restated against it is a **strengthening** of its `UniverseClosed`-shaped predecessor — the
same sense in which `ordTimesLeMaxTime_of_ordTimesKnown` records that `OrdTimesKnown` strengthens
the run invariant rather than weakening it.

The converse is **false** whenever `U` is nonempty, by `universeClosed_identify_retime_false`: there
is no `UniverseClosed`-shaped theorem to be recovered from a `UniverseClosedAt`-shaped one, and none
is wanted, since the stronger hypothesis is the unsatisfiable one. -/
theorem universeClosedAt_of_universeClosed {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} (h : UniverseClosed fc U) : UniverseClosedAt fc U :=
  ⟨h.1, fun b t₁ t₂ hbU _ => h.2 b t₁ t₂ hbU⟩

/-- **Clause 2, supplied at an ordered split's trigger.** The bridge that makes the restriction
free: at any branch where `timeLinearity` fires, the arm-3 merge target is a known time, so
`UniverseClosedAt`'s restricted clause applies with nothing extra assumed.

This is the single lemma that would have to fail for the repair to have leaked a new hypothesis into
the terminus. It does not fail: `firstIncomparablePair_spec` is exactly what it needs. -/
theorem universeClosedAt_identify_at_trigger {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : UniverseClosedAt fc U) (hbU : ∀ x ∈ b, x ∈ U)
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ∀ x ∈ b.identifyTime t₂ t₁, x ∈ U :=
  h.2 b t₁ t₂ hbU (firstIncomparablePair_spec htrig).1

/-- **Clause 2 at the engine's own orientation.** The oriented merge target is `max t₁ t₂`, and
`firstIncomparablePair_spec_oriented` puts it in `b.knownTimes` exactly as the unoriented spec puts
`t₁` there. Clause 2 is discharged *as it stands*: it already quantifies its source time freely and
restricts only its target, so swapping which member of the pair is which costs one fact the trigger
already supplies and adds no hypothesis. That is register entry 12's finding paying off — had
clause 2 been "repaired" by constraining both times, this bridge would have needed a fact no
trigger supplies. -/
theorem universeClosedAt_identify_at_trigger_oriented
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : UniverseClosedAt fc U) (hbU : ∀ x ∈ b, x ∈ U)
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ∀ x ∈ b.identifyTime (min t₁ t₂) (max t₁ t₂), x ∈ U :=
  h.2 b (max t₁ t₂) (min t₁ t₂) hbU (firstIncomparablePair_spec_oriented htrig).1

/-! ### The four consuming theorems, at the repaired predicate -/

/-- `difficultyBounded_of_stepLengthBounded` at the repaired closure residual. Statement and proof
are its own; the only change is that arm 3's confinement comes from
`universeClosedAt_identify_at_trigger` rather than from the unrestricted clause. -/
theorem difficultyBounded_of_stepLengthBounded_at {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {L : Nat}
    (hL : StepLengthBounded fc U L) (hUcl : UniverseClosedAt fc U) :
    DifficultyBounded fc U (difficultyCeiling U L) := by
  intro b ord tr hbU
  refine ⟨?_, ?_⟩
  · intro nb hnb
    exact estimateBranchDifficulty_le_ceiling (hUcl.1 b ord tr hbU nb hnb)
      ((hL b ord tr hbU).1 nb hnb)
  · intro bs hbs p hp
    obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
    have hlen : p.1.length ≤ L := (hL b ord tr hbU).2 _ hbs p hp
    have hconf : ∀ x ∈ p.1, x ∈ U := by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl | rfl
      · exact hbU
      · exact hbU
      · exact universeClosedAt_identify_at_trigger_oriented hUcl hbU htrig
    exact estimateBranchDifficulty_le_ceiling hconf hlen

/-- `difficultyBoundedAt_ceiling` at the repaired closure residual. -/
theorem difficultyBoundedAt_ceiling_at {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {c L : Nat}
    (hg : StepLengthGrowth fc c) (hUcl : UniverseClosedAt fc U) :
    DifficultyBoundedAt fc U L (difficultyCeiling U (c * L + c)) := by
  intro b ord tr hinv hbU hlen
  have habs : c * b.length + c ≤ c * L + c :=
    Nat.add_le_add_right (Nat.mul_le_mul_left c hlen) c
  refine ⟨?_, ?_⟩
  · intro nb hnb
    exact estimateBranchDifficulty_le_ceiling (hUcl.1 b ord tr hbU nb hnb)
      (le_trans ((hg b ord tr hinv).1 nb hnb) habs)
  · intro bs hbs p hp
    have hlen' : p.1.length ≤ c * L + c := le_trans ((hg b ord tr hinv).2 bs hbs p hp) habs
    obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
    have hconf : ∀ x ∈ p.1, x ∈ U := by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl | rfl
      · exact hbU
      · exact hbU
      · exact universeClosedAt_identify_at_trigger_oriented hUcl hbU htrig
    exact estimateBranchDifficulty_le_ceiling hconf hlen'

/-- `budgetPotential_step_unordered` at the repaired closure residual. This lemma never touches
clause 2 at all — only `hUcl.1`, which the two predicates share verbatim — so the arithmetic is
carried across unaltered. -/
theorem budgetPotential_step_unordered_at {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosedAt fc U) (hmint : MintPaysForTime fc U Tmax)
    (hst : BudgetState U Tmax σ b ord)
    (hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1)
    (hgrow : b.toFinset.card < nb.toFinset.card) :
    BudgetState U Tmax σ nb (expandOnceUnblocked b ord fc tr).2 ∧
      budgetPotential U Tmax σ nb (expandOnceUnblocked b ord fc tr).2
        < budgetPotential U Tmax σ b ord := by
  obtain ⟨hinv, hbU, hbud⟩ := hst
  have hnbU : ∀ x ∈ nb, x ∈ U := hUcl.1 b ord tr hbU nb hmem
  have hinv' : RunInvariant nb (expandOnceUnblocked b ord fc tr).2 :=
    (expandOnceUnblocked_runInvariant hinv).1 nb hmem
  have hm' : mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
      ≤ mintPotential U σ b ord := mintPotential_expandOnceUnblocked nb hmem
  have hcU : b.toFinset.card ≤ U.card := card_le_of_subset_universe hbU
  have hc'U : nb.toFinset.card ≤ U.card := card_le_of_subset_universe hnbU
  have hS : 0 < Tmax * Tmax + 1 := by omega
  rcases hmint σ b ord tr hinv hbU nb hmem with ⟨hk, hR⟩ | ⟨hI, hmlt⟩
  · have hI : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
        ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2 * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    refine ⟨⟨hinv', hnbU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
    omega
  · have hkT : nb.knownTimes.toFinset.card ≤ Tmax := by
      simp only [mintTimeBudget] at hI hbud; omega
    have hp' : (incompPairs nb (expandOnceUnblocked b ord fc tr).2).card ≤ Tmax * Tmax :=
      le_trans (incompPairs_card_le _ _) (Nat.mul_le_mul hkT hkT)
    have hEmul : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2 * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
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
    refine ⟨⟨hinv', hnbU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance, splitOrderedRank]
    omega

/-- `budgetPotential_step_splitOrdered` at the repaired closure residual. This is the one place in
the chain where the restriction has to be paid for, and `universeClosedAt_identify_at_trigger` pays
it from the trigger that `expandOnceUnblocked_splitOrdered_shape` has already produced two lines
earlier — so the payment is local and nothing propagates outward. -/
theorem budgetPotential_step_splitOrdered_at {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {bs : List (Branch × TimeOrdering)}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosedAt fc U) (hst : BudgetState U Tmax σ b ord)
    (hres : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, ∃ σ' : SignedFormula → SignedFormula, BudgetState U Tmax σ' p.1 p.2 ∧
      budgetPotential U Tmax σ' p.1 p.2 < budgetPotential U Tmax σ b ord := by
  obtain ⟨hinv, hbU, hbud⟩ := hst
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
    refine ⟨σ, ⟨hinvp, hbU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
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
    refine ⟨σ, ⟨hinvp, hbU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
    omega
  · dsimp only at hrk hinvp ⊢
    have hk := knownTimes_card_lt_at_arm3_oriented (b := b) (ord := ord) htrig
    set s := min t₁ t₂ with hsdef
    set u := max t₁ t₂ with hudef
    have hm' : mintPotential U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
        (ord.identifyTime s u) ≤ mintPotential U σ b ord :=
      mintPotential_identifyTime_oriented htrig hinv.irreflOrd
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
    refine ⟨fun x => rhoSF s u (σ x), ⟨hinvp, hIU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
    omega

/-! ### The closure condition on the label set, and the repaired clause 2 at `signedUniverse C L`

The repaired clause 2 *is* a caller's obligation about the label set, and this is it. The condition
is small, it is exactly what the clause reduces to, and it is satisfiable — the three things the
`DifficultyBounded` episode showed a residual has to be before it is worth stating.

Why it takes this shape: an identification moves a label's **time** coordinate and leaves its world
coordinate and its formula alone. So confinement of `b.identifyTime t₂ t₁` needs `L` to contain
`⟨z.label.world, t₁⟩` for each `z ∈ b`, and `t₁` is a time some `y ∈ b` already carries. Both
`z.label` and `y.label` are in `L`, so the requirement is precisely closure of `L` under taking one
member's world with another's time. -/

/-- **The closure condition on the label set.** `L` contains every label built from one member's
world and another member's time.

This is exactly the reduction of `UniverseClosedAt`'s clause 2 at `U = signedUniverse C L`, and
`timeMergeClosed_identifyTime_signedUniverse` is the reduction. It is used **once** in that proof,
at the retimed case, which is the check that it is neither stronger nor weaker than needed.

Satisfiable and non-vacuous: `timeMergeClosed_product` exhibits a whole family satisfying it, and
`timeMergeClosed_iff_product` shows the family is *all* of them — a `TimeMergeClosed` label set is
precisely a full rectangle of worlds against times. -/
def TimeMergeClosed (L : Finset Label) : Prop :=
  ∀ l ∈ L, ∀ l' ∈ L, (⟨l.world, l'.time⟩ : Label) ∈ L

/-- **The satisfiability witness.** Every rectangular label set — all of `Ws` against all of `Ts` —
is time-merge closed. Without this the condition could be vacuous, which is the failure mode
`DifficultyBounded` fell into: a residual nobody can satisfy makes its theorem a true conditional
with no reach. -/
theorem timeMergeClosed_product (Ws : Finset WorldIndex) (Ts : Finset TimeIndex) :
    TimeMergeClosed ((Ws ×ˢ Ts).image fun p => (⟨p.1, p.2⟩ : Label)) := by
  intro l hl l' hl'
  simp only [Finset.mem_image, Finset.mem_product] at hl hl' ⊢
  obtain ⟨p, ⟨hw, -⟩, rfl⟩ := hl
  obtain ⟨q, ⟨-, ht⟩, rfl⟩ := hl'
  exact ⟨(p.1, q.2), ⟨hw, ht⟩, rfl⟩

/-- **The characterization**: the rectangles are the only time-merge closed label sets. A
`TimeMergeClosed` `L` is the full product of its own world and time projections.

Not a dependency of anything below — it is here because it is what makes the condition legible. A
caller who wants `TimeMergeClosed L` has no choice to make beyond picking the two projections. -/
theorem timeMergeClosed_iff_product (L : Finset Label) :
    TimeMergeClosed L ↔
      L = ((L.image (·.world)) ×ˢ (L.image (·.time))).image fun p => (⟨p.1, p.2⟩ : Label) := by
  constructor
  · intro h
    ext l
    simp only [Finset.mem_image, Finset.mem_product]
    constructor
    · intro hl
      exact ⟨(l.world, l.time), ⟨⟨l, hl, rfl⟩, ⟨l, hl, rfl⟩⟩, by cases l; rfl⟩
    · rintro ⟨p, ⟨⟨a, ha, haw⟩, ⟨c, hc, hct⟩⟩, hpl⟩
      have := h a ha c hc
      rw [haw, hct, hpl] at this
      exact this
  · intro h
    rw [h]
    exact timeMergeClosed_product _ _

/-- **The repaired clause 2, discharged at the concrete universe.** Exactly
`UniverseClosedAt`'s second conjunct at `U = signedUniverse C L`, under `TimeMergeClosed L`.

Each member of `b.identifyTime t₂ t₁` is either an untouched member of `b` — confined by hypothesis
— or a retimed one. The formula coordinate is untouched either way, so it stays in `C` by
`formula_label_of_mem_signedUniverse`; the retimed label is `⟨z.label.world, t₁⟩`, and
`TimeMergeClosed` supplies it once `t₁` is exhibited as `y.label.time` for some `y ∈ b`, which is
what `t₁ ∈ b.knownTimes` gives via `exists_mem_of_mem_knownTimes`.

**`t₂` is not constrained**, and the proof shows why it need not be: the source time is only ever
tested against, never used to build a label. Constraining it too would weaken the predicate for
nothing — register entry 12. -/
theorem timeMergeClosed_identifyTime_signedUniverse {C : Finset Formula} {L : Finset Label}
    (hL : TimeMergeClosed L) {b : Branch} (hb : ∀ x ∈ b, x ∈ signedUniverse C L)
    {t₁ t₂ : TimeIndex} (ht₁ : t₁ ∈ b.knownTimes) :
    ∀ x ∈ b.identifyTime t₂ t₁, x ∈ signedUniverse C L := by
  obtain ⟨y, hy, hyt⟩ := exists_mem_of_mem_knownTimes ht₁
  intro x hx
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map] at hx
  obtain ⟨z, hz, hzx⟩ := hx
  obtain ⟨hzf, hzl⟩ := formula_label_of_mem_signedUniverse (hb z hz)
  obtain ⟨-, hyl⟩ := formula_label_of_mem_signedUniverse (hb y hy)
  by_cases hcase : z.label.time = t₂
  · subst hzx
    simp only [hcase, beq_self_eq_true, if_true]
    refine mem_signedUniverse hzf ?_
    have := hL z.label hzl y.label hyl
    rw [hyt] at this
    exact this
  · rw [if_neg (by simpa using hcase)] at hzx
    subst hzx
    exact hb z hz

/-- **The condition is satisfiable at a concrete nonempty label set**, so nothing above is vacuous:
two worlds against three times, closed and inhabited. -/
theorem timeMergeClosed_concrete :
    TimeMergeClosed ((({0, 1} : Finset WorldIndex) ×ˢ ({0, 1, 2} : Finset TimeIndex)).image
      (fun p => (⟨p.1, p.2⟩ : Label))) :=
  timeMergeClosed_product _ _

theorem timeMergeClosed_concrete_nonempty :
    ((({0, 1} : Finset WorldIndex) ×ˢ ({0, 1, 2} : Finset TimeIndex)).image
      (fun p => (⟨p.1, p.2⟩ : Label))).Nonempty := by decide

/-! ### Clause 1's label dimension is refuted at a fixed finite `signedUniverse C L`

Clause 2 was the residual's *fatal* defect and `UniverseClosedAt` repairs it. Clause 1 has a second,
**independent** defect, and this subsection settles it rather than assuming either way. The verdict
is that clause 1 is refutable at a fixed finite `signedUniverse C L` — so `UniverseClosedAt` is not
satisfiable at an arbitrary `signedUniverse C L` either, and the repair of clause 2 does not rescue
it. Both predicates carry clause 1 verbatim, so one witness refutes both.

**The cause: fresh worlds.** `applyRule_boxNeg_emitted_world` and
`applyRule_diamondPos_emitted_world` prove those two rules emit **only** at `Branch.nextWorld`, and
`nextWorld_not_mem_worldFinset` says that world is fresh — not a world of `b` at all. So a branch
confined to `signedUniverse C L` whose worlds exhaust `L`'s worlds has a `boxNeg` successor whose
label is outside `L` by construction. `freshWorldBranch` below is the minimal such configuration:
one formula, `F(□p)` at `⟨0, 0⟩`, and `L = {⟨0, 0⟩}`.

**Why blocking does not save it.** Clause 1 quantifies over **every** tracker `tr` and every
ordering `ord`, and the witness below is proved at every one of them. `blocking_fires_of_card_lt`
would need an `allEventualitiesFulfilledOrDuplicated` guard that clause 1's caller never gets to
supply.

**Why no closure condition on `L` repairs it, unlike clause 2.** `freshWorldHeadroom_not_universal`
is the general statement: for **no** nonempty finite `L` whatsoever does every `L`-confined branch
have its next world already in `L`. Each enlargement of `L` raises the reachable `maxWorld` by at
least as much as it adds, so the gap re-opens. The repair therefore cannot live in `L` — it has to
be a **branch-side headroom** hypothesis, which is what `FreshWorldHeadroom` below states and what
register entry 11 records. -/

section FreshWorldRefutation

/-- The base atom `p` of the fresh-world refutation's witness `F(□p)`. -/
def fwp : Formula := .atom (Atom.mkBase "p")

/-- `F(□p)` at the initial label: the smallest branch whose step leaves every fixed label set. -/
def freshWorldWitness : SignedFormula := SignedFormula.neg (Formula.box fwp) Label.initial

/-- The witness branch — one formula, so its only world is `0` and its next world is `1`. -/
def freshWorldBranch : Branch := [freshWorldWitness]

/-- What `boxNeg` emits at the witness: `F(p)` at world `1`, the fresh world. -/
def freshWorldEmitted : List SignedFormula := [SignedFormula.neg fwp ⟨1, 0⟩]

/-- The formula stock: `□p` and `p`, which is all the witness and its successor need. -/
def freshWorldStock : Finset Formula := {Formula.box fwp, fwp}

/-- The label set: the initial label alone. Nonempty, so nothing below is vacuous. -/
def freshWorldLabels : Finset Label := {Label.initial}

private theorem ia_ug (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .priorUGap freshWorldWitness fc = false := rfl
private theorem ia_sg (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .priorSGap freshWorldWitness fc = false := rfl
private theorem ia_sep (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .sepRule freshWorldWitness fc = false := rfl
private theorem ia_np (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .negPos freshWorldWitness fc = false := rfl
private theorem ia_nn (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .negNeg freshWorldWitness fc = false := rfl
private theorem ia_in (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .impNeg freshWorldWitness fc = false := rfl
private theorem ia_ap (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .andPos freshWorldWitness fc = false := rfl
private theorem ia_on (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .orNeg freshWorldWitness fc = false := rfl
private theorem ia_bp (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .boxPos freshWorldWitness fc = false := rfl
private theorem ia_bn (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .boxNeg freshWorldWitness fc = true := rfl
private theorem ar_bn :
    applyRule .boxNeg freshWorldWitness freshWorldBranch TimeOrdering.empty
      = (RuleResult.linear freshWorldEmitted, TimeOrdering.empty) := rfl
theorem rm_bn : ruleMintsFreshLabel .boxNeg = true := rfl
private theorem wp_bn :
    witnessPresent .boxNeg freshWorldWitness freshWorldBranch TimeOrdering.empty = false := rfl
/-- The fresh-label suppression test is `witnessPresent … || trivialEventWitnessed …`. The second
disjunct returns `false` on every rule outside the four positive temporal minting rules, so at a
`.boxNeg` witness it contributes nothing — but it still has to be reduced for the guard to
collapse, which is what this companion to `wp_bn` supplies. -/
private theorem tw_bn :
    trivialEventWitnessed .boxNeg freshWorldWitness freshWorldBranch TimeOrdering.empty
      = false := rfl

attribute [local simp] ia_ug ia_sg ia_sep ia_np ia_nn ia_in ia_ap ia_on ia_bp ia_bn ar_bn rm_bn
  wp_bn tw_bn

/-- **`.boxNeg` is the rule the engine picks at the witness, at every frame class.** The nine rules
ahead of it — the three Dedekind rules, then `negPos`, `negNeg`, `impNeg`, `andPos`, `orNeg`,
`boxPos` — are all inapplicable to a `.neg`-signed box, and the Dense and Discrete blocks are
*appended* after the base rules by `allRulesForFC`, so neither can pre-empt it. The witness guard is
`witnessPresent` rather than output-presence, because `boxNeg` mints a fresh label. -/
theorem findApplicableRule_freshWorldWitness (fc : FormalSystem.ProofSystem.FrameClass) :
    findApplicableRule freshWorldWitness freshWorldBranch TimeOrdering.empty fc
      = some (TableauRule.boxNeg, RuleResult.linear freshWorldEmitted, TimeOrdering.empty) := by
  simp only [findApplicableRule, allRulesForFC, allRules, rTimeRules]
  by_cases hd : FormalSystem.ProofSystem.FrameClass.RTime ≤ fc
  · simp [hd, List.findSome?]
  · simp [hd, List.findSome?]

/-- **The step fires at the witness, at every frame class and every tracker.** Blocking is empty
(`blockedTimes_empty`), the pick short-circuits on the single formula, and the result is
`.extended (freshWorldEmitted ++ freshWorldBranch)` — carrying a formula at world `1`. -/
theorem expandOnceUnblocked_freshWorldBranch
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) :
    (expandOnceUnblocked freshWorldBranch TimeOrdering.empty fc tr).1
      = ExpansionResult.extended (freshWorldEmitted ++ freshWorldBranch) := by
  have hrule := findApplicableRule_freshWorldWitness fc
  simp only [freshWorldBranch] at hrule
  rw [expandOnceUnblocked]
  simp only [blockedTimes_empty, findUnexpandedUnblockedWith, isExpanded, freshWorldBranch,
    List.find?_cons, List.contains_nil, Bool.not_false, Bool.and_true, hrule,
    Option.isNone_some]

/-- The witness branch is confined to its universe: `□p ∈ C` and `⟨0,0⟩ ∈ L`. -/
theorem freshWorldBranch_confined :
    ∀ x ∈ freshWorldBranch, x ∈ signedUniverse freshWorldStock freshWorldLabels := by
  intro x hx
  simp only [freshWorldBranch, List.mem_cons, List.not_mem_nil, or_false] at hx
  subst hx
  exact mem_signedUniverse (by simp [freshWorldStock, freshWorldWitness, SignedFormula.neg])
    (by simp [freshWorldLabels, freshWorldWitness, SignedFormula.neg])

/-- **Clause 1 is refuted at a fixed finite `signedUniverse C L`, at every frame class.**

Not merely unproved: false. The witness branch is confined, and its one step — `boxNeg`, at every
frame class and every tracker — emits `F(p)` at world `1`, whose label is not in
`freshWorldLabels = {⟨0,0⟩}`.

Since `UniverseClosed` and `UniverseClosedAt` carry clause 1 **verbatim**, this refutes the first
conjunct of both. It is therefore not a defect the clause-2 repair addresses, and no strengthening
of `TimeMergeClosed` bears on it: `freshWorldHeadroom_not_universal` shows the obstruction cannot be
moved into `L` at all. -/
theorem universeClosed_fresh_world_escapes (fc : FormalSystem.ProofSystem.FrameClass) :
    ¬ (∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker),
        (∀ x ∈ b, x ∈ signedUniverse freshWorldStock freshWorldLabels) →
        ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb,
          x ∈ signedUniverse freshWorldStock freshWorldLabels) := by
  intro h
  have hstep := expandOnceUnblocked_freshWorldBranch fc EventualityTracker.empty
  have hmem : (freshWorldEmitted ++ freshWorldBranch)
      ∈ unorderedSuccessorBranches
        (expandOnceUnblocked freshWorldBranch TimeOrdering.empty fc
          EventualityTracker.empty).1 := by
    rw [hstep]; simp [unorderedSuccessorBranches]
  have hbad := h freshWorldBranch TimeOrdering.empty EventualityTracker.empty
    freshWorldBranch_confined _ hmem (SignedFormula.neg fwp ⟨1, 0⟩)
    (by simp [freshWorldEmitted])
  have hlab := (formula_label_of_mem_signedUniverse hbad).2
  simp [freshWorldLabels, SignedFormula.neg, Label.initial] at hlab

/-- **The repaired predicate is refuted at the same universe**, because it carries clause 1
unchanged. `UniverseClosedAt` is the repair of clause **2** only, and this is the statement that
says so plainly rather than letting a reader infer that the repair made the whole residual
satisfiable at every `signedUniverse C L`. -/
theorem universeClosedAt_fresh_world_escapes (fc : FormalSystem.ProofSystem.FrameClass) :
    ¬ UniverseClosedAt fc (signedUniverse freshWorldStock freshWorldLabels) :=
  fun h => universeClosed_fresh_world_escapes fc h.1

/-- **The branch-side headroom condition** the world-minting rules need: the branch's next world,
paired with any time the branch already knows, is a label the universe has.

`boxNeg` and `diamondPos` emit only at `Branch.nextWorld` (`applyRule_boxNeg_emitted_world`,
`applyRule_diamondPos_emitted_world`), and this is exactly the label set membership their emissions
require. It is stated about the **branch**, not about `L`, and
`freshWorldHeadroom_not_universal` is the proof that it could not have been stated about `L`. -/
def FreshWorldHeadroom (L : Finset Label) (b : Branch) : Prop :=
  ∀ t ∈ b.knownTimes, (⟨Branch.nextWorld b, t⟩ : Label) ∈ L

/-- **No fixed finite label set supplies world headroom**, which is the general fact behind the
witness and the reason the repair cannot be a closure condition on `L`.

For every nonempty finite `L` there is an `L`-confined branch whose `Branch.nextWorld` is outside
`L` — take a branch sitting at `L`'s largest world, whose next world is one higher. Enlarging `L` to
cover it raises the largest world too, so the gap re-opens at every enlargement. Contrast clause 2,
where `TimeMergeClosed` closes the analogous gap outright because identification moves a label
*within* the existing coordinates rather than past them.

This is why `FreshWorldHeadroom` is a hypothesis about the **branch**, not about `L`: as a condition
on `L` alone, quantified over the confined branches it would have to serve, it is unsatisfiable. -/
theorem freshWorldHeadroom_not_universal (L : Finset Label) (hne : L.Nonempty) :
    ¬ (∀ b : Branch, (∀ x ∈ b, x.label ∈ L) → FreshWorldHeadroom L b) := by
  intro h
  have hine : (L.image (·.world)).Nonempty := hne.image _
  obtain ⟨l₀, hl₀, hl₀w⟩ := Finset.mem_image.mp ((L.image (·.world)).max'_mem hine)
  have hbconf : ∀ x ∈ ([⟨.pos, .bot, l₀⟩] : Branch), x.label ∈ L := by
    intro x hx
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
    subst hx; exact hl₀
  have hmax : Branch.nextWorld [⟨.pos, .bot, l₀⟩] = l₀.world + 1 := by
    simp [Branch.nextWorld, Branch.maxWorld]
  have hmem := h [⟨.pos, .bot, l₀⟩] hbconf l₀.time
    (mem_knownTimes_of_mem (sf := (⟨.pos, .bot, l₀⟩ : SignedFormula)) (by simp))
  rw [hmax] at hmem
  have hle : l₀.world + 1 ≤ (L.image (·.world)).max' hine :=
    Finset.le_max' (L.image (·.world)) (l₀.world + 1)
      (Finset.mem_image.mpr ⟨⟨l₀.world + 1, l₀.time⟩, hmem, rfl⟩)
  have heq : l₀.world = (L.image (·.world)).max' hine := hl₀w
  rw [heq] at hle
  exact absurd hle (Nat.not_succ_le_self _)

end FreshWorldRefutation

/-! ### Clause 1's formula dimension, unconditionally, at both unordered shapes

Clause 1 has two independent halves, and separating them is what makes the situation legible: the
**formula** coordinate of every successor stays inside `C` outright, with no side condition beyond
what `Fuel.lean` already asks; the **label** coordinate is the one that escapes
(`universeClosed_fresh_world_escapes`). Proving the formula half here, in full, is what shows the
refutation above is not a defect of the whole clause — it is confined to one coordinate.

`.extended` is `expandOnceUnblocked_extended_mem`, already landed in `Fuel.lean`. `.split` had no
analogue, and `expandOnceUnblocked_split_mem` is it. The `.splitOrdered` and `.saturated` shapes are
vacuous here because `unorderedSuccessorBranches` is `[]` on both. -/

/-- The `.split` counterpart of `Fuel.lean`'s `pick_split`, which is `private` there. Same
statement, same proof; it is restated because the three-stage destructuring below has to consume it.
-/
private theorem pick_split' {b : Branch} {bs : List Branch}
    {ord : TimeOrdering} {pick : Option (TableauRule × RuleResult × TimeOrdering)}
    (h : (match pick with
          | none => (ExpansionResult.saturated, ord)
          | some (_, result, newOrd) =>
            match result with
            | .linear fs => (ExpansionResult.extended (fs ++ b), newOrd)
            | .branching bss => (ExpansionResult.split (bss.map fun fs => fs ++ b), newOrd)
            | .branchingOrdered bs' => (ExpansionResult.splitOrdered bs', newOrd)
            | .persistent fs => (ExpansionResult.extended (fs ++ b), newOrd)
            | .notApplicable => (ExpansionResult.saturated, newOrd)).1
         = ExpansionResult.split bs) :
    ∃ (r : TableauRule) (bss : List (List SignedFormula)) (o : TimeOrdering),
      pick = some (r, RuleResult.branching bss, o) ∧ bs = bss.map (fun fs => fs ++ b) := by
  rcases pick with _ | ⟨r, res, o⟩
  · simp at h
  · cases res with
    | notApplicable => simp at h
    | linear fs => simp at h
    | branchingOrdered bs' => simp at h
    | persistent fs => simp at h
    | branching bss => exact ⟨r, bss, o, rfl, by simpa using h.symm⟩

/-- **T1 at the `.split` shape**: a branching step keeps every arm's formulas inside the stock.

The missing analogue of `expandOnceUnblocked_extended_mem`, and it needs **no new per-rule case
analysis**. `RuleResult.emitted` is defined on all five result shapes and sends `.branching bss` to
`bss.flatten`, so `applyRule_subformula_closed` — which is stated over `emitted` — already covers
the branching arms. What was missing is only the pick-stage destructuring, which is
`expandOnceUnblocked_extended_mem`'s own three-stage `rcases` with `pick_result_mem` (which handles
only `.linear`/`.persistent`) replaced by `applyRule_subformula_closed` directly.

Each arm is `fs ++ b`: the additions come from `emitted`, and the retained tail from `hb`. -/
theorem expandOnceUnblocked_split_mem {C : Finset Formula} {b : Branch} {bs : List Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hC : TableauClosed C) (hb : ∀ x ∈ b, x.formula ∈ C) (htrich : TrichClosed C b)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs) :
    ∀ nb ∈ bs, ∀ x ∈ nb, x.formula ∈ C := by
  unfold expandOnceUnblocked at h
  obtain ⟨r, bss, o, hp, rfl⟩ := pick_split' h
  have key : ∀ sf : SignedFormula, sf ∈ b →
      applyRule r sf b ord = (RuleResult.branching bss, o) →
      ∀ g ∈ bss.flatten, g.formula ∈ C := by
    intro sf hmem hpair
    have hcl := applyRule_subformula_closed (C := C) (sf := sf) (b := b) (ord := ord)
      hC (hb sf hmem) hb htrich r
    rw [hpair] at hcl
    simpa using hcl
  have hfs : ∀ g ∈ bss.flatten, g.formula ∈ C := by
    rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
    · rw [hpick] at hp
      rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
      · rw [hser] at hp
        rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                                 && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
        · rw [hlin] at hp
          simp only at hp
          exact absurd hp (by simp)
        · rw [hlin] at hp
          simp only at hp
          exact key sf3 (List.mem_of_find?_eq_some hlin)
            (findApplicableLinearityRule_applyRule_pair hp)
      · rw [hser] at hp
        simp only at hp
        exact key sf2 (List.mem_of_find?_eq_some hser)
          (findApplicableSerialRule_applyRule_pair hp)
    · rw [hpick] at hp
      simp only at hp
      have hmem : sf ∈ b := by
        unfold findUnexpandedUnblockedWith at hpick
        exact List.mem_of_find?_eq_some hpick
      exact key sf hmem (findApplicableRule_applyRule_pair hp)
  intro nb hnb x hx
  obtain ⟨fs, hfsmem, rfl⟩ := List.mem_map.mp hnb
  rcases List.mem_append.mp hx with hx | hx
  · exact hfs x (List.mem_flatten.mpr ⟨fs, hfsmem, hx⟩)
  · exact hb x hx

/-- **Clause 1's formula dimension, at the shape clause 1 is actually written at.** Every unordered
successor of a `C`-confined branch is `C`-confined, across both shapes that
`unorderedSuccessorBranches` is nonempty on.

`TrichStock C` rather than `TrichClosed C b` as the hypothesis, since `TrichStock` is a condition on
`C` alone and `trichClosed_of_trichStock` discharges the branch-side form — exactly as
`expandOnceUnblocked_extended_stock` does it. So the whole statement asks nothing about `b` beyond
confinement. -/
theorem unorderedSuccessor_formula_mem {C : Finset Formula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hC : TableauClosed C) (hT : TrichStock C) (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ x ∈ nb, x.formula ∈ C := by
  have htrich := trichClosed_of_trichStock hT hb
  rcases hres : (expandOnceUnblocked b ord fc tr).1 with _ | nb' | bs | bs'
  · intro nb hnb; simp [unorderedSuccessorBranches] at hnb
  · intro nb hnb
    simp only [unorderedSuccessorBranches, List.mem_cons, List.not_mem_nil, or_false] at hnb
    subst hnb
    exact expandOnceUnblocked_extended_mem hC hb htrich hres
  · intro nb hnb
    exact expandOnceUnblocked_split_mem hC hb htrich hres nb hnb
  · intro nb hnb; simp [unorderedSuccessorBranches] at hnb

/-! ### Clause 1's label dimension: the honest maximum, and where the obstruction actually sits

Phase order in this section: the formula dimension is **proved** above; the label dimension is
**refuted** as a property of a fixed finite `L` (`universeClosed_fresh_world_escapes`) and cannot be
repaired by any condition on `L` (`freshWorldHeadroom_not_universal`). What remains is to say
exactly how much of the label dimension is available and what the residue costs. That is done here,
in the style `StepLengthGrowth`'s docstring uses for its own obligation map: per rule shape, which
lemma supplies it, and which piece is absent. Read this together with section C11, which spends the
time analogue once it lands and settles that the obstruction is the world coordinate's refutation
rather than any absent lemma.

**The world coordinate is fully accounted for.** `applyRule_emitted_world_dichotomy` below is the
complete statement: every emitted formula sits either at a world the branch already has or at
`Branch.nextWorld`, with no third possibility, assembled from the landed 34 × 2 split
(`applyRule_emitted_world_mem`) and the two minting lemmas. So the world half of the label dimension
needs nothing beyond `FreshWorldHeadroom`.

**The time coordinate now has its analogue.** An earlier version of this note said there was no
`applyRule_emitted_time_mem` and that the label dimension was blocked on its absence. That is no
longer the state of the file: section D1 lands it, together with `freshTimeRules` (the census the
note said no statement supplied), `applyRule_emitted_time_dichotomy`, and the engine-level
`unorderedSuccessor_time_dichotomy`. The census is nine rules wide and is **incomparable** with
`ruleMintsFreshLabel` in both directions — `freshTimeRules_incomparable_freshLabelRules` decides
that, which is the precise content the old note gestured at when it observed that `densityRule` and
the `untlNeg` / `snceNeg` ACTIVE arms mint times while sitting outside the witness-guarded list.

One asymmetry with the world coordinate is real and is not a gap in the proof:
`applyRule_emitted_time_mem` carries `OrdTimesKnown b ord` where its world twin carries nothing,
because four rules propagate to `TimeOrdering.futureOf` / `pastOf` and nothing in `applyRule` ties
an ordering time to the branch. `applyRule_emitted_time_mem_ordTimesKnown_needed` decides that the
hypothesis is not removable, and `expandOnceUnblocked_ordTimesKnown` supplies it at every consuming
site, so nothing new reaches the terminus.

`UnorderedSuccessorLabelClosed` below is nevertheless **still a named residual**, for the reason
recorded on its own docstring: the world half of the label dimension is refuted at a fixed finite
`L` (`universeClosed_fresh_world_escapes`) and no condition on `L` repairs it
(`freshWorldHeadroom_not_universal`). The time accounting that was missing has landed; the
world-side obstruction is what remains, and it was never the missing lemma.

**What is delivered, then**: clause 1 at `signedUniverse C L` reduced to the label dimension
**alone** (`unorderedSuccessor_confined_signedUniverse_of_headroom`), with the formula dimension
discharged outright. -/

/-- **The world dichotomy, complete.** Every formula a rule emits sits either at a world the branch
already carries or at `Branch.nextWorld` — there is no third case.

Assembled from the three landed lemmas and nothing else: `applyRule_emitted_world_mem` covers the 34
rules that introduce no world, and `applyRule_boxNeg_emitted_world` /
`applyRule_diamondPos_emitted_world` cover the two that do, each pinning the emission to
`Branch.nextWorld` exactly. This is the world-coordinate half of clause 1's label dimension, and it
is the half that is available. -/
theorem applyRule_emitted_world_dichotomy {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hsf : sf ∈ b) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted,
      g.label.world ∈ b.worldFinset ∨ g.label.world = b.nextWorld := by
  intro g hg
  by_cases hbn : rule = .boxNeg
  · subst hbn; exact Or.inr (applyRule_boxNeg_emitted_world g hg)
  · by_cases hdp : rule = .diamondPos
    · subst hdp; exact Or.inr (applyRule_diamondPos_emitted_world g hg)
    · exact Or.inl (applyRule_emitted_world_mem hsf hbn hdp g hg)

/-- **Clause 1's label dimension, as a named residual.**

Exactly the label half of `UniverseClosedAt`'s first conjunct, separated out because the formula
half is proved (`unorderedSuccessor_formula_mem`) and this half is not. It is a hypothesis, it is
named, and nothing in this file assumes it.

**The obligation map.** What discharging this needs, per coordinate:

*The world coordinate — available.* `applyRule_emitted_world_dichotomy` is the complete accounting:
every emission is at a world of `b` or at `Branch.nextWorld`. The first case is covered by
`L`-confinement of `b`; the second is exactly what `FreshWorldHeadroom L b` supplies. Note the
headroom must be branch-side: `freshWorldHeadroom_not_universal` proves that no nonempty finite `L`
supplies it for all `L`-confined branches, so this cannot be turned into a closure condition on `L`
the way `TimeMergeClosed` was for clause 2.

*The time coordinate — available, since section D1.* An earlier version of this paragraph said there
was **no** `applyRule_emitted_time_mem`, that the rule *list* was unsettled, and that supplying the
analogue was a 36-arm accounting owned elsewhere. That is no longer the state of the file:
`applyRule_emitted_time_mem`, `applyRule_emitted_time_dichotomy` and the engine-level
`unorderedSuccessor_time_dichotomy` have landed, and `freshTimeRules` is the census the old
paragraph said no statement supplied. `freshTimeRules_incomparable_freshLabelRules` decides that the
census is incomparable with `ruleMintsFreshLabel` in **both** directions, which is the precise
content the old paragraph gestured at when it observed that `densityRule` and the `untlNeg` /
`snceNeg` active arms mint times while sitting outside the witness-guarded list. One hypothesis
comes with the analogue, `OrdTimesKnown b ord`, and
`applyRule_emitted_time_mem_ordTimesKnown_needed` decides that it is not removable;
`ordTimesKnown_empty` and `expandOnceUnblocked_ordTimesKnown` supply it at every consuming site, so
it is not new currency.

*Both coordinates together are still not this residual, and that is now proved rather than pending.*
Section C11 spends the completed accounting: `unorderedSuccessor_label_mem_of_headroom` proves the
label dimension outright from the branch-side rectangle `FreshLabelHeadroom`, and
`unorderedSuccessorLabelClosedOrd_of_headroom` reduces the residual to that rectangle holding at
every `L`-confined branch. The reduction is complete and the residual nevertheless survives, because
`freshLabelHeadroom_not_universal` refutes the rectangle at every nonempty finite `L`. The
obstruction was always the *world* coordinate's refutation (`universeClosed_fresh_world_escapes`,
`freshWorldHeadroom_not_universal`), never the missing time lemma. Two structural facts are worth
carrying away: a label is a **pair**, so per-coordinate dichotomies leave four quadrants rather than
two; and confinement of `b` covers none of the four, because it constrains the pairs `b` carries and
not their cross product.

*The `.splitOrdered` shape does not arise*, because `unorderedSuccessorBranches` is `[]` on it —
that shape's confinement is clause 2's business and is discharged by
`timeMergeClosed_identifyTime_signedUniverse`. -/
def UnorderedSuccessorLabelClosed (fc : FormalSystem.ProofSystem.FrameClass)
    (L : Finset Label) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), (∀ x ∈ b, x.label ∈ L) →
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb, x.label ∈ L

/-- **Clause 1 at `signedUniverse C L`, reduced to the label dimension alone.**

The deliverable of the label-dimension phase. `TableauClosed C` and `TrichStock C` discharge the
formula coordinate outright via `unorderedSuccessor_formula_mem`; what is left is exactly
`UnorderedSuccessorLabelClosed`, whose obligation map is on its own docstring. So the residue is
one coordinate, not two, and it is explicit rather than absorbed.

This is clause 1 of `UniverseClosedAt fc (signedUniverse C L)` in the form
`universeClosedAt_signedUniverse_of_headroom` consumes. -/
theorem unorderedSuccessor_confined_signedUniverse_of_headroom {C : Finset Formula}
    {L : Finset Label} {fc : FormalSystem.ProofSystem.FrameClass}
    (hC : TableauClosed C) (hT : TrichStock C) (hlab : UnorderedSuccessorLabelClosed fc L) :
    ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker),
      (∀ x ∈ b, x ∈ signedUniverse C L) →
      ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb,
        x ∈ signedUniverse C L := by
  intro b ord tr hb nb hnb x hx
  have hbf : ∀ y ∈ b, y.formula ∈ C :=
    fun y hy => (formula_label_of_mem_signedUniverse (hb y hy)).1
  have hbl : ∀ y ∈ b, y.label ∈ L :=
    fun y hy => (formula_label_of_mem_signedUniverse (hb y hy)).2
  exact mem_signedUniverse
    (unorderedSuccessor_formula_mem hC hT hbf nb hnb x hx)
    (hlab b ord tr hbl nb hnb x hx)

/-- **The label residual is refuted at this `L`** — the single-witness form, retained as the file's
original record of the finding. `universeClosed_fresh_world_escapes`'s configuration, read at the
residual's own shape: the one-formula branch `[F(□p)@⟨0,0⟩]` is confined to
`freshWorldLabels = {⟨0,0⟩}`, its step fires `.boxNeg` at every frame class and every tracker, and
the emitted `F(p)` sits at world `1`.

**The bracket this docstring used to state is false, and section C11 proves it false.** An earlier
version said the residual "holds at every `L` for which the engine never fires", and bracketed it as
*refutable at some `signedUniverse C L`, satisfiable at others*, so that the composite above would
be genuinely conditional without being vacuous. Neither half survives:
`unorderedSuccessorLabelClosed_nonempty_false` refutes the residual at **every** nonempty finite
`L`, at every frame class, and `unorderedSuccessorLabelClosed_empty` proves it at `∅`. Its
satisfiability set is therefore exactly `{∅}` — so the "engine never fires" class is not a
substantive class of label sets, it is the one-element class `{∅}`. And `signedUniverse C ∅ = ∅`, so
at the only `L` where the hypothesis is available the universe is empty and every consumer of it is
a true conditional with no reach. Register entries 11 and 21 carry the consequence for the nine
theorems that take this predicate as a hypothesis.

The statement and proof below are unchanged and are **not** withdrawn: the single witness is what
the sections between here and C11 cite, and `UnorderedSuccessorLabelClosedOrd` — needed to state the
generalized form — is not defined until C11, so the general form could not be stated here. -/
theorem unorderedSuccessorLabelClosed_not_universal
    (fc : FormalSystem.ProofSystem.FrameClass) :
    ¬ UnorderedSuccessorLabelClosed fc freshWorldLabels := by
  intro h
  have hstep := expandOnceUnblocked_freshWorldBranch fc EventualityTracker.empty
  have hmem : (freshWorldEmitted ++ freshWorldBranch)
      ∈ unorderedSuccessorBranches
        (expandOnceUnblocked freshWorldBranch TimeOrdering.empty fc
          EventualityTracker.empty).1 := by
    rw [hstep]; simp [unorderedSuccessorBranches]
  have hbl : ∀ y ∈ freshWorldBranch, y.label ∈ freshWorldLabels := by
    intro y hy
    simp only [freshWorldBranch, List.mem_cons, List.not_mem_nil, or_false] at hy
    subst hy
    simp [freshWorldLabels, freshWorldWitness, SignedFormula.neg]
  have hbad := h freshWorldBranch TimeOrdering.empty EventualityTracker.empty hbl _ hmem
    (SignedFormula.neg fwp ⟨1, 0⟩) (by simp [freshWorldEmitted])
  simp [freshWorldLabels, SignedFormula.neg, Label.initial] at hbad

/-! ### The threading spine, and the terminus at the repaired predicate

The six theorems below only *pass* the closure residual on; none inspects it. Each is its
`UniverseClosed`-shaped counterpart with the hypothesis type changed and the two step lemmas
redirected, and the originals are untouched. -/

/-- `stepDecreases_budgetPotential` at the repaired closure residual. -/
theorem stepDecreases_budgetPotential_at {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax D β : Nat} (hβ : 3 ≤ β)
    (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) :
    StepDecreases fc (BudgetState U Tmax) (budgetPotential U Tmax) D β := by
  intro σ b ord tr hst
  refine ⟨?_, ?_, ?_⟩
  · intro nb hres
    have hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      rw [hres]; simp [unorderedSuccessorBranches]
    exact ⟨σ, budgetPotential_step_unordered_at hUcl hmint hst hmem
      (expandOnceUnblocked_card_lt hres)⟩
  · intro bs hres
    have hmem : ∀ nb ∈ bs,
        nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      intro nb hnb; rw [hres]; simpa [unorderedSuccessorBranches] using hnb
    refine ⟨le_trans (expandOnceUnblocked_split_arity_le hres) hβ, ?_, ?_⟩
    · intro nb hnb
      exact (hD b ord tr hst.2.1).1 nb (hmem nb hnb)
    · intro nb hnb
      exact ⟨σ, budgetPotential_step_unordered_at hUcl hmint hst (hmem nb hnb)
        (expandOnceUnblocked_split_card_lt hres hnb)⟩
  · intro bs hres
    have harity : bs.length ≤ β := by
      obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hres
      simpa using hβ
    exact ⟨harity, (hD b ord tr hst.2.1).2 bs hres,
      budgetPotential_step_splitOrdered_at hUcl hst hres⟩

/-- `expandBranchWithFuel_isSome_of_budget` at the repaired closure residual. -/
theorem expandBranchWithFuel_isSome_of_budget_at {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {mintBudget Tmax D β : Nat}
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) (harm : ArmSettlement fc) :
    BudgetedTotalityAt fc U mintBudget Tmax D β := by
  intro b ord tr applied maxBranches branchesUsed hbU hinv hmb hT hbud
  have hst : BudgetState U Tmax id b ord := by
    refine ⟨hinv, hbU, ?_⟩
    have := mintPotential_le_eight_mul U id b ord
    simp only [mintTimeBudget]
    omega
  exact expandBranchWithFuel_isSome_of_measure (by omega)
    (stepDecreases_budgetPotential_at hβ hUcl hD hmint)
    harm (mintPathBound U.card Tmax mintBudget) id _ b ord tr applied maxBranches branchesUsed
    hst (budgetPotential_lt_mintPathBound hst hmb) (Nat.le_refl _) hbud

/-- **THE TERMINUS, at the repaired closure residual.** `buildTableauAt_isSome_of_budget` with
`UniverseClosed` exchanged for `UniverseClosedAt`.

The exchange is a **strengthening**: the hypothesis is weaker
(`universeClosedAt_of_universeClosed`), and unlike its predecessor's it is satisfiable, so this is
the form a caller can actually reach. The other three residuals are carried across unaltered and are
still named — `DifficultyBounded` (itself refutable at every `D`; use the length-budget sibling
below), `MintPaysForTime`, `PostBlockingSettles`. Nothing above is withdrawn: the
`UniverseClosed`-shaped statements and their proofs stand untouched. -/
theorem buildTableauAt_isSome_of_budget_at {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {mintBudget Tmax D β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 8 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuel U.card Tmax mintBudget D β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuel U.card Tmax mintBudget D β) fc maxBranches).isSome
      = true := by
  refine buildTableauAt_isSome_of_settles hpb ?_
  exact expandBranchWithFuel_isSome_of_budget_at hβ hUcl hD hmint
    (armSettlement_of_postBlockingSettles hpb)
    (seedBranch phi) TimeOrdering.empty EventualityTracker.empty {} maxBranches 0
    hseed (runInvariant_initial _) hmb hT (by omega)

/-- `buildTableauAt_isSome_at_seed` at the repaired closure residual. -/
theorem buildTableauAt_isSome_at_seed_at {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {D β : Nat} (phi : Formula)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U
      (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) U.card))
    (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuel U.card (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (8 * U.card) D β)
        fc
        (β * mintAwareFuel U.card
          (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) U.card) (8 * U.card) D β)
      ).isSome = true :=
  buildTableauAt_isSome_of_budget_at phi _ hβ hUcl hD hmint hpb hseed (Nat.le_refl _)
    (derivedTmax_spec (seedBranch phi) U) (Nat.le_refl _)

/-- `buildTableauAt_isSome_of_lengthBudget` at the repaired closure residual — the terminus with
**both** refutable residuals exchanged for satisfiable ones at once, `DifficultyBounded` for
`StepLengthBounded` and `UniverseClosed` for `UniverseClosedAt`. -/
theorem buildTableauAt_isSome_of_lengthBudget_at {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {mintBudget Tmax L β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTime fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 8 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuel U.card Tmax mintBudget (difficultyCeiling U L) β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuel U.card Tmax mintBudget (difficultyCeiling U L) β) fc
        maxBranches).isSome = true :=
  buildTableauAt_isSome_of_budget_at phi maxBranches hβ hUcl
    (difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint hpb hseed hmb hT hbud

/-- `buildTableauAt_isSome_at_seed_lengthBudget` at the repaired closure residual: every number read
off, and both refutable residuals exchanged. -/
theorem buildTableauAt_isSome_at_seed_lengthBudget_at
    {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {L β : Nat} (phi : Formula)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTime fc U
      (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) U.card))
    (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuel U.card (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (8 * U.card) (difficultyCeiling U L) β)
        fc
        (β * mintAwareFuel U.card
          (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) U.card) (8 * U.card)
          (difficultyCeiling U L) β)
      ).isSome = true :=
  buildTableauAt_isSome_at_seed_at phi hβ hUcl
    (difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint hpb hseed

/-! ### The composite at the concrete universe, and the terminus that consumes it

What the section has established, assembled. `UniverseClosedAt fc (signedUniverse C L)` follows from
three conditions plus one named residual, and each of the four is where it belongs:

* **Clause 1, formula coordinate** — discharged by `unorderedSuccessor_formula_mem`, at the cost
  of `TableauClosed C` and `TrichStock C`, both already `Fuel.lean`'s currency.
* **Clause 1, label coordinate** — not discharged: it costs `UnorderedSuccessorLabelClosed fc L`,
  a **named residual** with its obligation map on its own docstring.
* **Clause 2** — discharged by `timeMergeClosed_identifyTime_signedUniverse`, at the cost of
  `TimeMergeClosed L`, which is satisfiable (`timeMergeClosed_product`).

So of the residual's two conjuncts, **clause 2 is paid outright** and clause 1 is reduced from two
coordinates to one. That is the accounting the terminus corollary below inherits, and its docstring
states it rather than leaving a reader to infer that the terminus has become unconditional. -/

/-- **The composite.** `UniverseClosedAt fc (signedUniverse C L)` from the two stock conditions, the
label-set closure condition, and the one named residual.

Read against the residual this task started from: `UniverseClosed fc (signedUniverse C L)` is
**false** whenever the universe is nonempty (`universeClosed_nonempty_false`), so there is no
composite of that shape to be had at all. This is the repaired predicate, and its clause 2 is
genuinely discharged — `TimeMergeClosed L` is a condition on the label set that a caller picks
(every rectangle satisfies it, `timeMergeClosed_product`), not a residual.

What is **not** discharged is clause 1's label coordinate. It is carried as
`UnorderedSuccessorLabelClosed fc L` and it is refutable at some `L`
(`unorderedSuccessorLabelClosed_not_universal`). An earlier version of this paragraph added that the
one lemma which would let it be reduced further — a time-coordinate analogue of
`applyRule_emitted_world_mem` — did not exist in the development. It exists now
(`applyRule_emitted_time_dichotomy`, section D1), and section C11 spends it: the reduction to the
branch-side rectangle `FreshLabelHeadroom` is complete, and the residual survives it anyway because
`freshLabelHeadroom_not_universal` refutes that rectangle at every nonempty finite `L`. So this
hypothesis is not waiting on a lemma. Its obligation map is on
`UnorderedSuccessorLabelClosed`'s docstring; register entry 21 is the verdict. -/
theorem universeClosedAt_signedUniverse_of_headroom {C : Finset Formula} {L : Finset Label}
    {fc : FormalSystem.ProofSystem.FrameClass}
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L) :
    UniverseClosedAt fc (signedUniverse C L) :=
  ⟨unorderedSuccessor_confined_signedUniverse_of_headroom hC hT hlab,
    fun _ _ _ hbU ht₁ => timeMergeClosed_identifyTime_signedUniverse hL hbU ht₁⟩

/-- **The terminus with the closure residual paid at `signedUniverse C L`**, at the branch-length
budget — the sibling that is live, since `DifficultyBounded` is refutable at every `D`
(`difficultyBounded_multiplicity_false`).

**Precisely which residuals remain, so that nothing here is over-read.** Five hypotheses, and the
closure residual is not among them:

* `StepLengthBounded fc (signedUniverse C L) L'` — satisfiable; `difficultyBoundedAt_ceiling_at`
  reduces it further to the rule-local `StepLengthGrowth`.
* `MintPaysForTime` — the development's one genuinely open mathematical obligation, and open only
  on the **temporal** fragment. Unchanged as a declaration, and **refuted as stated at a universe of
  temporal formulas** (`mintPaysForTime_untlNeg_false`, section D2) with both obvious repairs closed
  off and the residual obstruction located. Two successive repairs are landed in section D2 —
  `MintPaysForTimeStable`, itself refuted at nonempty `U` by
  `mintPaysForTimeStable_signedUniverse_false`, and `MintPaysForTimeFixed`, which is not — each with
  its direction lemma and its own restated terminus chain. Section D3 then **discharges the
  hypothesis outright** at every `untl`/`snce`-free universe
  (`mintPaysForTimeFixed_signedUniverse_untlSnceFree`), so on that fragment this bullet names one
  residual fewer and the terminus is
  `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`. See its own docstring.
* `PostBlockingSettles` — unchanged.
* `β ≥ 3` — the measured split arity.
* `UnorderedSuccessorLabelClosed fc L` — **the residue of this task**: clause 1's label coordinate,
  and only that coordinate. Its obligation map is on its own docstring. It is not waiting on a
  lemma: section C11 reduces it, with both coordinates fully accounted for, to the branch-side
  rectangle `FreshLabelHeadroom`, and `freshLabelHeadroom_not_universal` refutes that rectangle at
  every nonempty finite `L`. Register entry 21 records why the reduction is complete without being a
  discharge.

What is **gone** relative to `buildTableauAt_isSome_of_lengthBudget`: the whole of clause 2, and
clause 1's formula coordinate. Clause 2's payment is the substantive one — as stated it was
unsatisfiable at every nonempty universe, and it is now a rectangle condition on the label set. -/
theorem buildTableauAt_isSome_of_lengthBudget_signedUniverse
    {fc : FormalSystem.ProofSystem.FrameClass}
    {C : Finset Formula} {L : Finset Label} {mintBudget Tmax L' β : Nat}
    (phi : Formula) (maxBranches : Nat) (hβ : 3 ≤ β)
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L)
    (hSL : StepLengthBounded fc (signedUniverse C L) L')
    (hmint : MintPaysForTime fc (signedUniverse C L) Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ signedUniverse C L)
    (hmb : 8 * (signedUniverse C L).card ≤ mintBudget)
    (hT' : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuel (signedUniverse C L).card Tmax mintBudget
      (difficultyCeiling (signedUniverse C L) L') β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuel (signedUniverse C L).card Tmax mintBudget
        (difficultyCeiling (signedUniverse C L) L') β) fc maxBranches).isSome = true :=
  buildTableauAt_isSome_of_lengthBudget_at phi maxBranches hβ
    (universeClosedAt_signedUniverse_of_headroom hC hT hL hlab) hSL hmint hpb hseed hmb hT' hbud

/-- **The caller-facing form**, every number read off, with the closure residual paid at
`signedUniverse C L`. The sibling of `buildTableauAt_isSome_at_seed_lengthBudget_at`, with
`UniverseClosedAt` discharged.

The remaining residuals are exactly those listed on
`buildTableauAt_isSome_of_lengthBudget_signedUniverse`. A caller supplies a `TableauClosed`,
`TrichStock` formula stock, a `TimeMergeClosed` label set (any rectangle), a length bound, and the
three unchanged residuals — and reads the fuel and the branch budget off the statement. -/
theorem buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse
    {fc : FormalSystem.ProofSystem.FrameClass}
    {C : Finset Formula} {L : Finset Label} {L' β : Nat} (phi : Formula) (hβ : 3 ≤ β)
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L)
    (hSL : StepLengthBounded fc (signedUniverse C L) L')
    (hmint : MintPaysForTime fc (signedUniverse C L)
      (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) (signedUniverse C L).card))
    (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ signedUniverse C L) :
    (buildTableauAt phi
        (mintAwareFuel (signedUniverse C L).card
          (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) (signedUniverse C L).card)
          (8 * (signedUniverse C L).card) (difficultyCeiling (signedUniverse C L) L') β)
        fc
        (β * mintAwareFuel (signedUniverse C L).card
          (derivedTmax ((seedBranch phi).knownTimes.toFinset.card) (signedUniverse C L).card)
          (8 * (signedUniverse C L).card) (difficultyCeiling (signedUniverse C L) L') β)
      ).isSome = true :=
  buildTableauAt_isSome_at_seed_lengthBudget_at phi hβ
    (universeClosedAt_signedUniverse_of_headroom hC hT hL hlab) hSL hmint hpb hseed

end FormalSystem.Metalogic.Decidability

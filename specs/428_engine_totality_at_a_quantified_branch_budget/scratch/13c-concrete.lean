import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

theorem expandOnceUnblocked_splitOrdered_rank_lt {b : Branch} {bs : List (Branch × TimeOrdering)}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {Tmax : Nat} (hT : b.knownTimes.toFinset.card ≤ Tmax)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, splitOrderedRank Tmax p.1 p.2 < splitOrderedRank Tmax b ord := by
  obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape h
  obtain ⟨hlt1, hlt2⟩ := incompPairs_lt_addFuture htrig
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · simp only [splitOrderedRank]; omega
  · simp only [splitOrderedRank]; omega
  · have hk := knownTimes_card_lt_at_arm3 htrig
    have harm : ((b.identifyTime t₂ t₁).knownTimes).toFinset.card ≤ Tmax := by omega
    have hc := incompPairs_card_le (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁)
    have h2 : ((b.identifyTime t₂ t₁).knownTimes).toFinset.card
        * ((b.identifyTime t₂ t₁).knownTimes).toFinset.card ≤ Tmax * Tmax :=
      Nat.mul_le_mul harm harm
    have hstep : ((b.identifyTime t₂ t₁).knownTimes).toFinset.card * (Tmax * Tmax + 1)
        + (Tmax * Tmax + 1) ≤ b.knownTimes.toFinset.card * (Tmax * Tmax + 1) := by
      have hle : ((b.identifyTime t₂ t₁).knownTimes).toFinset.card + 1
          ≤ b.knownTimes.toFinset.card := hk
      calc ((b.identifyTime t₂ t₁).knownTimes).toFinset.card * (Tmax * Tmax + 1)
            + (Tmax * Tmax + 1)
          = (((b.identifyTime t₂ t₁).knownTimes).toFinset.card + 1) * (Tmax * Tmax + 1) := by ring
        _ ≤ b.knownTimes.toFinset.card * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ hle
    simp only [splitOrderedRank]
    omega

/-- The remaining identification allowance. -/
def mintTimeBudget (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  b.knownTimes.toFinset.card + mintPotential U σ b ord

/-- The remaining branch-growing allowance. -/
def extensionAllowance (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  U.card + mintTimeBudget U σ b ord * U.card - b.toFinset.card

/-- The potential. -/
def budgetPotential (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Nat :=
  (2 * (Tmax * Tmax + 1)) * mintPotential U σ b ord
  + extensionAllowance U σ b ord
  + splitOrderedRank Tmax b ord

/-- The carried state. -/
def BudgetState (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Prop :=
  RunInvariant b ord ∧ (∀ x ∈ b, x ∈ U) ∧ mintTimeBudget U σ b ord ≤ Tmax

/-- Universe closure. -/
def UniverseClosed (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula) : Prop :=
  (∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), (∀ x ∈ b, x ∈ U) →
      ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb, x ∈ U) ∧
  (∀ (b : Branch) (t₁ t₂ : TimeIndex), (∀ x ∈ b, x ∈ U) →
      ∀ x ∈ b.identifyTime t₂ t₁, x ∈ U)

/-- Difficulty interface. -/
def DifficultyBounded (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (D : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), (∀ x ∈ b, x ∈ U) →
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        estimateBranchDifficulty nb ≤ D) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, estimateBranchDifficulty p.1 ≤ D)

/-- The time-dimension residual. -/
def MintPaysForTime (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (Tmax : Nat) : Prop :=
  ∀ (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering)
    (tr : EventualityTracker), RunInvariant b ord → (∀ x ∈ b, x ∈ U) →
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      (nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card ∧
        splitOrderedRank Tmax nb (expandOnceUnblocked b ord fc tr).2
          ≤ splitOrderedRank Tmax b ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord ∧
          mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
            < mintPotential U σ b ord)

theorem budgetPotential_step_unordered {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosed fc U) (hmint : MintPaysForTime fc U Tmax)
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
    -- the rank rise is paid by the mint drop
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

end FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability

theorem budgetPotential_step_splitOrdered {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {bs : List (Branch × TimeOrdering)}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosed fc U) (hst : BudgetState U Tmax σ b ord)
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
    have hm' : mintPotential U (fun x => rhoSF t₂ t₁ (σ x)) (b.identifyTime t₂ t₁)
        (ord.identifyTime t₂ t₁) ≤ mintPotential U σ b ord :=
      mintPotential_identifyTime htrig hinv.irreflOrd
    have hk := knownTimes_card_lt_at_arm3 (b := b) (ord := ord) htrig
    have hIU : ∀ x ∈ b.identifyTime t₂ t₁, x ∈ U := hUcl.2 b t₁ t₂ hbU
    have hc'U : (b.identifyTime t₂ t₁).toFinset.card ≤ U.card :=
      card_le_of_subset_universe hIU
    have hIsucc : mintTimeBudget U (fun x => rhoSF t₂ t₁ (σ x)) (b.identifyTime t₂ t₁)
        (ord.identifyTime t₂ t₁) + 1 ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : (mintTimeBudget U (fun x => rhoSF t₂ t₁ (σ x)) (b.identifyTime t₂ t₁)
          (ord.identifyTime t₂ t₁) + 1) * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hIsucc
    have hEexp : (mintTimeBudget U (fun x => rhoSF t₂ t₁ (σ x)) (b.identifyTime t₂ t₁)
          (ord.identifyTime t₂ t₁) + 1) * U.card
        = mintTimeBudget U (fun x => rhoSF t₂ t₁ (σ x)) (b.identifyTime t₂ t₁)
          (ord.identifyTime t₂ t₁) * U.card + U.card := by ring
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U (fun x => rhoSF t₂ t₁ (σ x))
          (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁)
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    refine ⟨fun x => rhoSF t₂ t₁ (σ x), ⟨hinvp, hIU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
    omega

end FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability

theorem stepDecreases_budgetPotential {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax D β : Nat} (hβ : 3 ≤ β)
    (hUcl : UniverseClosed fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) :
    StepDecreases fc (BudgetState U Tmax) (budgetPotential U Tmax) D β := by
  intro σ b ord tr hst
  refine ⟨?_, ?_, ?_⟩
  · intro nb hres
    have hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      rw [hres]; simp [unorderedSuccessorBranches]
    exact ⟨σ, budgetPotential_step_unordered hUcl hmint hst hmem
      (expandOnceUnblocked_card_lt hres)⟩
  · intro bs hres
    have hmem : ∀ nb ∈ bs, nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      intro nb hnb; rw [hres]; simpa [unorderedSuccessorBranches] using hnb
    refine ⟨le_trans (expandOnceUnblocked_split_arity_le hres) hβ, ?_, ?_⟩
    · intro nb hnb
      exact (hD b ord tr hst.2.1).1 nb (hmem nb hnb)
    · intro nb hnb
      exact ⟨σ, budgetPotential_step_unordered hUcl hmint hst (hmem nb hnb)
        (expandOnceUnblocked_split_card_lt hres hnb)⟩
  · intro bs hres
    have harity : bs.length ≤ β := by
      obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hres
      simpa using hβ
    exact ⟨harity, (hD b ord tr hst.2.1).2 bs hres,
      budgetPotential_step_splitOrdered hUcl hst hres⟩

end FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability

def mintPathBound (Ucard Tmax mintBudget : Nat) : Nat :=
  splitPathBound Ucard Tmax
  + 2 * (Tmax * Tmax + 1) * mintBudget
  + Ucard + Tmax * Ucard
  + orderedRunBound Tmax + 1

def mintAwareFuel (Ucard Tmax mintBudget D β : Nat) : Nat :=
  fuelFigure D β (mintPathBound Ucard Tmax mintBudget)

theorem splitPathBound_le_mintPathBound (Ucard Tmax mintBudget : Nat) :
    splitPathBound Ucard Tmax ≤ mintPathBound Ucard Tmax mintBudget := by
  simp only [mintPathBound]; omega

theorem splitAwareFuel_le_mintAwareFuel (Ucard Tmax mintBudget D β : Nat) :
    splitAwareFuel Ucard Tmax D β ≤ mintAwareFuel Ucard Tmax mintBudget D β := by
  rw [← fuelFigure_splitAwareFuel]
  exact fuelFigure_mono (splitPathBound_le_mintPathBound _ _ _)

theorem budgetPotential_lt_mintPathBound {U : Finset SignedFormula} {Tmax mintBudget : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hst : BudgetState U Tmax σ b ord) (hmb : 8 * U.card ≤ mintBudget) :
    budgetPotential U Tmax σ b ord < mintPathBound U.card Tmax mintBudget := by
  obtain ⟨hinv, hbU, hbud⟩ := hst
  have hkT : b.knownTimes.toFinset.card ≤ Tmax := by
    simp only [mintTimeBudget] at hbud; omega
  have hm8 := mintPotential_le_eight_mul U σ b ord
  have hR := splitOrderedRank_le Tmax b ord hkT
  have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord
      ≤ 2 * (Tmax * Tmax + 1) * mintBudget := Nat.mul_le_mul_left _ (by omega)
  have hEmul : mintTimeBudget U σ b ord * U.card ≤ Tmax * U.card :=
    Nat.mul_le_mul_right _ hbud
  simp only [budgetPotential, extensionAllowance, mintPathBound]
  omega

def BudgetedTotalityAt (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (mintBudget Tmax D β : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker) (applied : AppliedSet)
    (maxBranches branchesUsed : Nat),
    (∀ x ∈ b, x ∈ U) →
    RunInvariant b ord →
    8 * U.card ≤ mintBudget →
    b.knownTimes.toFinset.card + mintBudget ≤ Tmax →
    branchesUsed + β * mintAwareFuel U.card Tmax mintBudget D β ≤ maxBranches →
    (expandBranchWithFuel b (mintAwareFuel U.card Tmax mintBudget D β) ord fc tr applied
      maxBranches branchesUsed).isSome = true

theorem expandBranchWithFuel_isSome_of_budget {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {mintBudget Tmax D β : Nat}
    (hβ : 3 ≤ β) (hUcl : UniverseClosed fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) (harm : ArmSettlement fc) :
    BudgetedTotalityAt fc U mintBudget Tmax D β := by
  intro b ord tr applied maxBranches branchesUsed hbU hinv hmb hT hbud
  have hst : BudgetState U Tmax id b ord := by
    refine ⟨hinv, hbU, ?_⟩
    have := mintPotential_le_eight_mul U id b ord
    simp only [mintTimeBudget]
    omega
  exact expandBranchWithFuel_isSome_of_measure (by omega) (stepDecreases_budgetPotential hβ hUcl hD hmint)
    harm (mintPathBound U.card Tmax mintBudget) id _ b ord tr applied maxBranches branchesUsed
    hst (budgetPotential_lt_mintPathBound hst hmb) (Nat.le_refl _) hbud

end FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability

theorem budgetedTotality_beta_zero_false (fc : FormalSystem.ProofSystem.FrameClass)
    (D : Nat) (sf : SignedFormula) :
    ¬ BudgetedTotality fc {sf} 8 ((Branch.knownTimes [sf]).toFinset.card + 8) D 0 := by
  intro h
  have hx := h [sf] TimeOrdering.empty EventualityTracker.empty {} 0 0
    (by simp) (runInvariant_initial _) (by simp) (Nat.le_refl _) (by simp)
  rw [expandBranchWithFuel.eq_def] at hx
  simp at hx

end FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

section BranchingNonVacuity

private def nvp : Formula := .atom (Atom.mkBase "p")
private def nvq : Formula := .atom (Atom.mkBase "q")

/-- `T(p → q)` at the initial label. -/
def branchingWitness : Branch := [SignedFormula.pos (Formula.imp nvp nvq) Label.initial]

private def branchingWitnessArity : Nat :=
  match (expandOnceUnblocked branchingWitness TimeOrdering.empty .Base
      EventualityTracker.empty).1 with
  | .split bs => bs.length
  | _ => 0

/-- info: 2 -/
#guard_msgs in
#eval branchingWitnessArity

theorem branchingWitness_splits : branchingWitnessArity = 2 := by decide

/-- info: true -/
#guard_msgs in
#eval (expandBranchWithFuel branchingWitness 500).isSome

end BranchingNonVacuity

end FormalSystem.Metalogic.Decidability

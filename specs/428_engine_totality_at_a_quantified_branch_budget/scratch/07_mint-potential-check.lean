/-
SCRATCH — Phase 10's mint potential (R2, the arm-3 monotonicity). NOT part of the library build.
-/
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace Scratch428Mint

open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- The eight rules that mint a fresh label. -/
def freshLabelRules : Finset TableauRule :=
  {TableauRule.boxNeg, TableauRule.diamondPos, TableauRule.allFutureNeg, TableauRule.allPastNeg,
   TableauRule.someFuturePos, TableauRule.somePastPos, TableauRule.untlPos, TableauRule.sncePos}

theorem freshLabelRules_card : freshLabelRules.card = 8 := by decide

theorem mem_freshLabelRules {r : TableauRule} :
    r ∈ freshLabelRules ↔ ruleMintsFreshLabel r = true := by
  cases r <;> simp [freshLabelRules, ruleMintsFreshLabel]

/-- The mint potential. -/
def mintPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  ((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 (σ p.2) b ord = false)).card

theorem mintPotential_le_eight_mul (U : Finset SignedFormula)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) :
    mintPotential U σ b ord ≤ 8 * U.card := by
  refine le_trans (Finset.card_filter_le _ _) ?_
  rw [Finset.card_product, freshLabelRules_card]

/-- Step monotonicity. -/
theorem mintPotential_le_of_grow {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b b' : Branch} {ord ord' : TimeOrdering}
    (hb : ∀ x ∈ b, x ∈ b') (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) :
    mintPotential U σ b' ord' ≤ mintPotential U σ b ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
  · rfl
  · rw [witnessPresent_branch_mono hb (witnessPresent_ord_mono hord hw)] at hp
    exact absurd hp.2 (by simp)

/-- Arm-3 monotonicity, with the renaming carried in the measure. -/
theorem mintPotential_identifyTime {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    mintPotential U (fun x => rhoSF t₂ t₁ (σ x)) (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁)
      ≤ mintPotential U σ b ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
  · rfl
  · rw [arm3_preserves_witness htrig hirr p.1 (σ p.2) hw] at hp
    exact absurd hp.2 (by simp)

/-- Strict decrease at a mint. -/
theorem mintPotential_lt_of_mint {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b b' : Branch} {ord ord' : TimeOrdering} {r : TableauRule} {sf : SignedFormula}
    (hb : ∀ x ∈ b, x ∈ b') (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints)
    (hr : r ∈ freshLabelRules) (hsf : sf ∈ U)
    (hbefore : witnessPresent r (σ sf) b ord = false)
    (hafter : witnessPresent r (σ sf) b' ord' = true) :
    mintPotential U σ b' ord' < mintPotential U σ b ord := by
  refine Finset.card_lt_card ?_
  refine (Finset.ssubset_iff_of_subset ?_).mpr ⟨(r, sf), ?_, ?_⟩
  · intro p hp
    simp only [Finset.mem_filter] at hp ⊢
    refine ⟨hp.1, ?_⟩
    rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
    · rfl
    · rw [witnessPresent_branch_mono hb (witnessPresent_ord_mono hord hw)] at hp
      exact absurd hp.2 (by simp)
  · simp only [Finset.mem_filter, Finset.mem_product]
    exact ⟨⟨hr, hsf⟩, hbefore⟩
  · simp only [Finset.mem_filter, hafter]
    simp

/-- Engine level, unordered successors. -/
theorem mintPotential_expandOnceUnblocked {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 ≤ mintPotential U σ b ord := by
  intro nb hnb
  exact mintPotential_le_of_grow (expandOnceUnblocked_branch_mono nb hnb)
    expandOnceUnblocked_ord_mono

/-- Engine level, the ordered split's three arms. -/
theorem mintPotential_expandOnceUnblocked_splitOrdered {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {bs : List (Branch × TimeOrdering)} {t₁ t₂ : TimeIndex}
    (hinv : RunInvariant b ord)
    (hbs : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs)
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ∀ p ∈ bs, ∃ σ' : SignedFormula → SignedFormula,
      (σ' = σ ∨ σ' = fun x => rhoSF t₂ t₁ (σ x)) ∧
        mintPotential U σ' p.1 p.2 ≤ mintPotential U σ b ord := by
  obtain ⟨u₁, u₂, htrig', rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
  rw [htrig] at htrig'
  obtain ⟨rfl, rfl⟩ : t₁ = u₁ ∧ t₂ = u₂ := by simpa using htrig'
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact ⟨σ, Or.inl rfl,
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₁ t₂)⟩
  · exact ⟨σ, Or.inl rfl,
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₂ t₁)⟩
  · exact ⟨_, Or.inr rfl, mintPotential_identifyTime htrig hinv.irreflOrd⟩

/-- The per-step arithmetic. -/
theorem mintBudget_preserved {used budget p p' : Nat}
    (hbud : used + p ≤ budget) (hle : p' ≤ p) : used + p' ≤ budget := by omega

theorem mintBudget_preserved_mint {used budget p p' : Nat}
    (hbud : used + p ≤ budget) (hlt : p' < p) : (used + 1) + p' ≤ budget := by omega

/-- The measure composes along a run. -/
theorem mints_le_eight_mul {U : Finset SignedFormula}
    (σ : Nat → SignedFormula → SignedFormula) (br : Nat → Branch) (og : Nat → TimeOrdering)
    (mints : Nat → Nat) (n : Nat) (h0 : mints 0 = 0)
    (hstep : ∀ i < n, mints (i + 1) + mintPotential U (σ (i + 1)) (br (i + 1)) (og (i + 1))
      ≤ mints i + mintPotential U (σ i) (br i) (og i)) :
    mints n ≤ 8 * U.card := by
  have key : ∀ m ≤ n, mints m + mintPotential U (σ m) (br m) (og m)
      ≤ mints 0 + mintPotential U (σ 0) (br 0) (og 0) := by
    intro m
    induction m with
    | zero => intro _; exact Nat.le_refl _
    | succ k ih =>
      intro hk
      exact le_trans (hstep k (Nat.lt_of_lt_of_le (Nat.lt_succ_self k) hk))
        (ih (Nat.le_of_succ_le hk))
  have h := key n (Nat.le_refl n)
  rw [h0] at h
  have hb : mintPotential U (σ 0) (br 0) (og 0) ≤ 8 * U.card :=
    mintPotential_le_eight_mul _ _ _ _
  omega

/-- The Phase 13 target, as a named proposition. -/
def BudgetedTotality (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (mintBudget Tmax D β : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker) (applied : AppliedSet)
    (maxBranches branchesUsed : Nat),
    (∀ x ∈ b, x ∈ U) →
    RunInvariant b ord →
    8 * U.card ≤ mintBudget →
    b.knownTimes.toFinset.card + mintBudget ≤ Tmax →
    branchesUsed + β * splitAwareFuel U.card Tmax D β ≤ maxBranches →
    (expandBranchWithFuel b (splitAwareFuel U.card Tmax D β) ord fc tr applied
      maxBranches branchesUsed).isSome = true

end Scratch428Mint

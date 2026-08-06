import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- The fuel a run of at most `N` engine steps needs. -/
def fuelFigure (D β N : Nat) : Nat := N * (D * β + 1) ^ N

theorem fuelFigure_splitAwareFuel (Ucard Tmax D β : Nat) :
    fuelFigure D β (splitPathBound Ucard Tmax) = splitAwareFuel Ucard Tmax D β := rfl

theorem one_le_pow_succ (K N : Nat) : 1 ≤ (K + 1) ^ N := Nat.one_le_pow _ _ (Nat.succ_pos _)

theorem fuelFigure_pos {D β N : Nat} (hN : 1 ≤ N) : 1 ≤ fuelFigure D β N := by
  simp only [fuelFigure]
  exact Nat.one_le_iff_ne_zero.mpr (by
    have := one_le_pow_succ (D * β) N
    exact Nat.mul_ne_zero (by omega) (by omega))

theorem fuelFigure_succ (D β N : Nat) : fuelFigure D β N + 1 ≤ fuelFigure D β (N + 1) := by
  simp only [fuelFigure]
  have hp : 1 ≤ (D * β + 1) ^ N := one_le_pow_succ _ _
  have h1 : (N + 1) * (D * β + 1) ^ (N + 1)
      = (N + 1) * ((D * β + 1) ^ N * (D * β + 1)) := by rw [Nat.pow_succ]
  have h2 : (N + 1) * (D * β + 1) ^ N ≤ (N + 1) * ((D * β + 1) ^ N * (D * β + 1)) :=
    Nat.mul_le_mul_left _ (Nat.le_mul_of_pos_right _ (by omega))
  have h3 : (N + 1) * (D * β + 1) ^ N = N * (D * β + 1) ^ N + (D * β + 1) ^ N := by ring
  omega

theorem fuelFigure_alloc (D β N : Nat) :
    D * β * fuelFigure D β N ≤ fuelFigure D β (N + 1) := by
  simp only [fuelFigure]
  have h1 : D * β * (N * (D * β + 1) ^ N) = N * (D * β + 1) ^ N * (D * β) := by ring
  have h2 : (N + 1) * (D * β + 1) ^ (N + 1)
      = (N + 1) * (D * β + 1) ^ N * (D * β + 1) := by rw [Nat.pow_succ]; ring
  have h3 : N * (D * β + 1) ^ N * (D * β) ≤ (N + 1) * (D * β + 1) ^ N * (D * β + 1) :=
    Nat.mul_le_mul (Nat.mul_le_mul_right _ (by omega)) (by omega)
  omega

end FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability

/-- Per-step obligation bundle. -/
def StepDecreases {α : Type} (fc : FormalSystem.ProofSystem.FrameClass)
    (P : α → Branch → TimeOrdering → Prop) (Ψ : α → Branch → TimeOrdering → Nat)
    (D β : Nat) : Prop :=
  ∀ (a : α) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), P a b ord →
    (∀ nb, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb →
        ∃ a' : α, P a' nb (expandOnceUnblocked b ord fc tr).2 ∧
          Ψ a' nb (expandOnceUnblocked b ord fc tr).2 < Ψ a b ord) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs →
        bs.length ≤ β ∧ (∀ nb ∈ bs, estimateBranchDifficulty nb ≤ D) ∧
        ∀ nb ∈ bs, ∃ a' : α, P a' nb (expandOnceUnblocked b ord fc tr).2 ∧
          Ψ a' nb (expandOnceUnblocked b ord fc tr).2 < Ψ a b ord) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        bs.length ≤ β ∧ (∀ p ∈ bs, estimateBranchDifficulty p.1 ≤ D) ∧
        ∀ p ∈ bs, ∃ a' : α, P a' p.1 p.2 ∧ Ψ a' p.1 p.2 < Ψ a b ord)

/-- The arm-settlement residual. -/
def ArmSettlement (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  ∀ (b ob : Branch) (armFuel parentFuel : Nat) (ord oOrd : TimeOrdering)
    (tr : EventualityTracker) (ap oAp : AppliedSet) (mb bu : Nat),
    armFuel ≤ parentFuel →
    expandBranchWithFuel b armFuel ord fc tr ap mb bu = some (.inr (ob, oOrd, oAp)) →
    (resolveOpenArm ob oOrd oAp parentFuel fc).isSome = true

theorem expandBranchWithFuel_isSome_of_measure {α : Type}
    {fc : FormalSystem.ProofSystem.FrameClass} {P : α → Branch → TimeOrdering → Prop}
    {Ψ : α → Branch → TimeOrdering → Nat} {D β : Nat}
    (hβ : 1 ≤ β) (hstep : StepDecreases fc P Ψ D β) (harm : ArmSettlement fc) :
    ∀ (N : Nat) (a : α) (fuel : Nat) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker)
      (applied : AppliedSet) (maxBranches branchesUsed : Nat),
      P a b ord → Ψ a b ord < N → fuelFigure D β N ≤ fuel →
      branchesUsed + β * fuelFigure D β N ≤ maxBranches →
      (expandBranchWithFuel b fuel ord fc tr applied maxBranches branchesUsed).isSome = true := by
  intro N
  induction N with
  | zero => intro _ _ _ _ _ _ _ _ _ hlt; exact absurd hlt (by omega)
  | succ M ih =>
    intro a fuel b ord tr applied mb bu hP hlt hfuel hbud
    have hFpos : 1 ≤ fuelFigure D β (M + 1) := fuelFigure_pos (by omega)
    have hsucc := fuelFigure_succ D β M
    have hβF : 1 ≤ β * fuelFigure D β (M + 1) :=
      Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega))
    rcases fuel with _ | f
    · omega
    have hfM : fuelFigure D β M ≤ f := by omega
    have hbudM : ∀ k, k ≤ β → bu + k + β * fuelFigure D β M ≤ mb := by
      intro k hk
      have : β * (fuelFigure D β M + 1) ≤ β * fuelFigure D β (M + 1) :=
        Nat.mul_le_mul_left _ (by omega)
      have h2 : β * (fuelFigure D β M + 1) = β * fuelFigure D β M + β := by ring
      have h3 : k ≤ β := hk
      omega
    rw [expandBranchWithFuel, if_neg (by omega : ¬ bu ≥ mb)]
    rcases hcl : findClosure b fc with _ | reason
    case some => simp
    case none =>
      simp only [expandOnceUnblockedWithApplied]
      obtain ⟨hext, hsp, hsso⟩ := hstep a b ord (fulfillEventualities b (registerEventualities b tr)) hP
      rcases hres : (expandOnceUnblocked b ord fc
          (fulfillEventualities b (registerEventualities b tr))).1 with _ | nb | bs | bs
      · simp
      · obtain ⟨a', hP', hΨ'⟩ := hext nb hres
        simpa using ih a' f nb _ _ applied mb (bu + 1) hP' (by omega) hfM
          (by have := hbudM 1 hβ; omega)
      · obtain ⟨harity, hdiff, harms⟩ := hsp bs hres
        have hT : ((bs.map estimateBranchDifficulty).foldl (· + ·) 0) * fuelFigure D β M
            ≤ f + 1 := by
          have h1 := totalDifficulty_le bs D hdiff
          have h2 : D * bs.length ≤ D * β := Nat.mul_le_mul_left _ harity
          have h3 : ((bs.map estimateBranchDifficulty).foldl (· + ·) 0) * fuelFigure D β M
              ≤ (D * β) * fuelFigure D β M := Nat.mul_le_mul_right _ (by omega)
          have h4 := fuelFigure_alloc D β M
          omega
        refine expand_split_fold_isSome f _ fc _ _ mb _ _ ?_ ?_ _ (by simp)
        · intro pair hp
          obtain ⟨hb, hal⟩ := List.of_mem_zip hp
          obtain ⟨a', hP', hΨ'⟩ := harms pair.1 hb
          refine ih a' (min pair.2 f) pair.1 _ _ _ mb _ hP' (by omega) ?_ ?_
          · exact Nat.le_min.mpr
              ⟨allocateFuelProportionally_ge f bs _ _ hfM hT hal, hfM⟩
          · exact hbudM bs.length harity
        · intro pair hp ob oOrd oAp hexp
          exact harm _ _ _ _ _ _ _ _ _ _ _ (Nat.min_le_right _ _) hexp
      · obtain ⟨harity, hdiff, harms⟩ := hsso bs hres
        have hdiff' : ∀ nb ∈ bs.map Prod.fst, estimateBranchDifficulty nb ≤ D := by
          intro nb hnb
          obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hnb
          exact hdiff p hp
        have hT : (((bs.map Prod.fst).map estimateBranchDifficulty).foldl (· + ·) 0)
            * fuelFigure D β M ≤ f + 1 := by
          have h1 := totalDifficulty_le (bs.map Prod.fst) D hdiff'
          have hlen : (bs.map Prod.fst).length = bs.length := by simp
          have h2 : D * (bs.map Prod.fst).length ≤ D * β := by
            rw [hlen]; exact Nat.mul_le_mul_left _ harity
          have h3 : (((bs.map Prod.fst).map estimateBranchDifficulty).foldl (· + ·) 0)
              * fuelFigure D β M ≤ (D * β) * fuelFigure D β M :=
            Nat.mul_le_mul_right _ (by omega)
          have h4 := fuelFigure_alloc D β M
          omega
        refine expand_splitOrdered_fold_isSome f fc _ _ mb _ _ ?_ ?_ _ (by simp)
        · intro pair hp
          obtain ⟨hb, hal⟩ := List.of_mem_zip hp
          obtain ⟨a', hP', hΨ'⟩ := harms pair.1 hb
          refine ih a' (min pair.2 f) pair.1.1 pair.1.2 _ _ mb _ hP' (by omega) ?_ ?_
          · exact Nat.le_min.mpr
              ⟨allocateFuelProportionally_ge f (bs.map Prod.fst) _ _ hfM hT hal, hfM⟩
          · exact hbudM bs.length harity
        · intro pair hp ob oOrd oAp hexp
          exact harm _ _ _ _ _ _ _ _ _ _ _ (Nat.min_le_right _ _) hexp

end FormalSystem.Metalogic.Decidability

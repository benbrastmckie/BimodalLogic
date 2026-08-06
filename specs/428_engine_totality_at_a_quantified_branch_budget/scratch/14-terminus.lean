import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

def PostBlockingSettles (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  ∀ (ob : Branch) (oOrd : TimeOrdering) (fuel : Nat) (satBr : Branch) (satOrd : TimeOrdering),
    saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd)) →
    findUnexpandedUnblockedWith satBr satOrd fc
      (blockedTimes satBr satOrd fc (armTracker satBr)) = none

theorem armSettlement_of_postBlockingSettles {fc : FormalSystem.ProofSystem.FrameClass}
    (hpb : PostBlockingSettles fc) : ArmSettlement fc := by
  intro b ob armFuel parentFuel ord oOrd tr ap oAp mb bu _ _
  simp only [resolveOpenArm, findUnexpandedUnblocked]
  split
  · simp
  · match hsb : saturateBlocked ob parentFuel oOrd fc with
    | none => exact absurd hsb (saturateBlocked_ne_none ob parentFuel oOrd fc)
    | some (.inl cb) => simp
    | some (.inr (satBr, satOrd)) =>
        dsimp only
        split
        · simp
        · rw [hpb ob oOrd parentFuel satBr satOrd hsb]
          simp

theorem buildTableauAt_isSome_of_settles {phi : Formula} {fuel : Nat}
    {fc : FormalSystem.ProofSystem.FrameClass} {maxBranches : Nat}
    (hpb : PostBlockingSettles fc)
    (hexp : (expandBranchWithFuel [SignedFormula.neg phi Label.initial] fuel TimeOrdering.empty fc
      (maxBranches := maxBranches)).isSome = true) :
    (buildTableauAt phi fuel fc maxBranches).isSome = true := by
  unfold buildTableauAt
  simp only
  match hE : expandBranchWithFuel [SignedFormula.neg phi Label.initial] fuel TimeOrdering.empty fc
      (maxBranches := maxBranches) with
  | none => rw [hE] at hexp; simp at hexp
  | some (.inl closedBr) => simp
  | some (.inr (ob, oOrd, oAp)) =>
      dsimp only
      split
      · simp
      · match hsb : saturateBlocked ob fuel oOrd fc with
        | none => exact absurd hsb (saturateBlocked_ne_none ob fuel oOrd fc)
        | some (.inl cb) => simp
        | some (.inr (satBr, satOrd)) =>
            dsimp only
            split
            · simp
            · rename_i sf2 hg2
              rw [hpb ob oOrd fuel satBr satOrd hsb] at hg2
              simp at hg2

end FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

theorem buildTableauAt_isSome_of_budget {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {mintBudget Tmax D β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosed fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 8 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuel U.card Tmax mintBudget D β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuel U.card Tmax mintBudget D β) fc maxBranches).isSome = true := by
  refine buildTableauAt_isSome_of_settles hpb ?_
  exact expandBranchWithFuel_isSome_of_budget hβ hUcl hD hmint
    (armSettlement_of_postBlockingSettles hpb)
    (seedBranch phi) TimeOrdering.empty EventualityTracker.empty {} maxBranches 0
    hseed (runInvariant_initial _) hmb hT (by omega)

theorem buildTableauAt_isSome_at_seed {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {D β : Nat} (phi : Formula)
    (hβ : 3 ≤ β) (hUcl : UniverseClosed fc U) (hD : DifficultyBounded fc U D)
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
  buildTableauAt_isSome_of_budget phi _ hβ hUcl hD hmint hpb hseed (Nat.le_refl _)
    (derivedTmax_spec (seedBranch phi) U) (Nat.le_refl _)

end FormalSystem.Metalogic.Decidability

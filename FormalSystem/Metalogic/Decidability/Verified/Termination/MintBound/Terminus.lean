/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Measure

/-! # C8. The terminus at `buildTableauAt`

`expandBranchWithFuel` is one of four things `buildTableauAt` calls, and the other three have to be
discharged before totality of the expansion becomes totality of the entry point. Two of them are
landed and go through unchanged; the third is the arm that made the original entry point non-total,
and it is **still there**.

## The post-blocking arm is not eliminated by the certificate change — a correction

The expectation carried into this phase was that replacing the literal saturation test with the
engine's blocking-aware one removes `buildTableauAt`'s `| some _ => none  -- Still not saturated
after post-blocking` arm. Reading the landed function rather than the expectation: that arm is
present, textually, in `Saturation.lean`'s definition of `buildTableauAt`, and the certificate
change did not remove it. What the change removed is the *permanent* disagreement — the literal
test counts label-introducing work that `saturateBlocked` refuses by construction, so it could
never stop reporting it, at any fuel — and the measured probes confirm that the formulas which
died there now settle. What it did not do is prove the arm unreachable.

So the arm is discharged here the only honest way: by a **named hypothesis**,
`PostBlockingSettles`, that says the post-blocking pass leaves a blocking-aware saturated branch.
That hypothesis also settles `resolveOpenArm` (`armSettlement_of_postBlockingSettles`), because
`resolveOpenArm`'s own `none` arm is the same test on the same branch — so the terminus carries
**one** settlement residual, not two, and it is the same one the fuel induction consumes.

`resolveOpenArm` and `buildTableauAt` are not interchangeable, which is why the bridge is proved
rather than asserted: `resolveOpenArm` tests `findClosure satBr` before the saturation test and
reports the arm closed if it fires, and `buildTableauAt` does not. `ArmSettlement` alone is
therefore strictly too weak for the terminus, and `PostBlockingSettles` is what covers both.

## What the terminus does discharge

* the `expandBranchWithFuel` call — Phase 13's theorem, at the seed;
* `RunInvariant` — discharged **inside**, by `runInvariant_initial`, and absent from the statement.
  It is vacuous at `TimeOrdering.empty` because that ordering has no constraints, which is a
  property of the engine's seed and not of a narrowed statement;
* the `saturateBlocked` call's `none` arm — the landed `saturateBlocked_ne_none`, so the plan's
  "provably dead" annotation on that arm is consumed rather than trusted. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The post-blocking settlement residual.**

The post-blocking pass leaves a branch that the blocking-aware saturation test certifies. This is
the one statement that closes both `resolveOpenArm`'s `none` arm and `buildTableauAt`'s, and it is
**false**: `saturateBlocked` at `fuel = 0` returns its input unchanged, and above zero it stops when
no *label-free* work remains, which is a weaker condition than the saturation test it is measured
against.

**The open question this docstring used to pose is decided, and the answer is no.** It read
"whether the gap can be closed by fuel alone is exactly the question `Saturation.lean` leaves open,
and nothing here decides it"; section C12 decides it. `postBlockingSettles_fuel_zero_false` refutes
the predicate at the `fuel = 0` arm and `postBlockingSettles_fuel_gap_false` refutes it at a nonzero
one, both at every frame class, and `postBlockingSettles_gap_at_every_fuel` exhibits both halves of
the disagreement simultaneously at **every** fuel figure. Fuel does not close it, because
`expandOnceNoFresh` *skips* label-minting candidates while `findUnexpandedUnblockedWith` counts
them, and no fuel figure appears anywhere in that disagreement. Register entry 22 records it.

The statement is retained verbatim, and the terminus chain still names it, because nothing in this
file is withdrawn — but it is a conditional no caller can discharge, in the same sense as
`DifficultyBounded` (entry 9), `UniverseClosed`'s clause 2 (entry 10) and `MintPaysForTime`
(entry 14).

**The settled repair is `PostBlockingSettlesRun`**, this statement with the pass's input branch
restricted to a branch some `expandBranchWithFuel` call returned open, at that call's own fuel —
which is the only way `buildTableauAt` reaches it. `postBlockingSettlesRun_of_postBlockingSettles`
fixes the direction: the hypothesis list is longer, so the predicate is **weaker**, so every
theorem restated against it is a **strengthening**. Nine termini were once stated at it and have
since been retired as vacuous — the narrowed predicate is itself refuted at the fuel figures they
were stated at, so none of them delivered anything. Section C12's retirement record carries the
disposition and the frame-class split; register entries 24 and 25 carry the verdict. Entry 23
records the
repair that was tried first and rejected, and why this one is not that.

It is a hypothesis wherever it appears, and it is never an axiom. -/
def PostBlockingSettles (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  ∀ (ob : Branch) (oOrd : TimeOrdering) (fuel : Nat) (satBr : Branch) (satOrd : TimeOrdering),
    saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd)) →
    findUnexpandedUnblockedWith satBr satOrd fc
      (blockedTimes satBr satOrd fc (armTracker satBr)) = none

/-- **One residual covers both settlement points.** `resolveOpenArm`'s only route to `none` is its
final saturation test (`resolveOpenArm_eq_none_imp`), which is the test `PostBlockingSettles`
answers; its `saturateBlocked` arm is dead by `saturateBlocked_ne_none`, consumed here rather than
assumed. -/
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

/-- **The entry point's own arms, discharged.** Given that the expansion does not exhaust, every
remaining route to `none` in `buildTableauAt` is closed: the `saturateBlocked` arm by
`saturateBlocked_ne_none`, and the post-blocking saturation arm by the settlement residual. -/
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

/--
**THE TERMINUS.** `buildTableauAt` is total at the derived fuel figure and a quantified branch
budget, with the branching arms discharged rather than excluded.

Read against what this replaces: `buildTableau_isSome` is false at the engine's default budget at
*any* fuel, and the register below records why. This statement quantifies the budget, names the
fuel figure it earns, discharges `RunInvariant` at the seed via `runInvariant_initial` so that it
does **not** appear as a caller obligation, and applies to runs that branch — both split shapes are
proved, not confined.

**The residuals, stated once.** `UniverseClosed`, `DifficultyBounded` with `β ≥ 3`,
`MintPaysForTime` and `PostBlockingSettles`, each with its own docstring above saying what would
discharge it. The mint budget is **not** among them: it is a parameter this development discharges
(`mintPotential_le_eight_mul` supplies the ceiling outright), and the time bound is derived from it
rather than assumed (`derivedTmax_spec`).

**One of the four is refutable, and has a repaired sibling.** `DifficultyBounded fc U D` is false at
**every** `D` whenever `U` contains a formula the engine fires on, because
`estimateBranchDifficulty` sums over the branch *list* and confinement to `U` bounds only its
`toFinset`. The witness is `difficultyBounded_multiplicity_false`; register entry 9 below records
the cause; and the docstring on `DifficultyBounded` itself corrects the older, wrong explanation
that blamed `Saturation.lean`'s `private` markers. This theorem is therefore a true conditional
whose antecedent no caller can supply. The usable form is `buildTableauAt_isSome_of_lengthBudget`
(and `buildTableauAt_isSome_at_seed_lengthBudget`), which is this statement with the difficulty
hypothesis exchanged for the branch-**length** hypothesis `StepLengthBounded fc U L` that
`difficultyBounded_of_stepLengthBounded` shows is sufficient. Nothing below is withdrawn: the
statement and proof here are unchanged, and the sibling is additive.
-/
theorem buildTableauAt_isSome_of_budget {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {mintBudget Tmax D β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosed fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 8 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuel U.card Tmax mintBudget D β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuel U.card Tmax mintBudget D β) fc maxBranches).isSome
      = true := by
  refine buildTableauAt_isSome_of_settles hpb ?_
  exact expandBranchWithFuel_isSome_of_budget hβ hUcl hD hmint
    (armSettlement_of_postBlockingSettles hpb)
    (seedBranch phi) TimeOrdering.empty EventualityTracker.empty {} maxBranches 0
    hseed (runInvariant_initial _) hmb hT (by omega)

/-- **The caller-facing form**: both numbers read off, neither left as a proof obligation.

The mint budget is instantiated at the ceiling `mintPotential_le_eight_mul` supplies, the time
bound at `derivedTmax` (whose adequacy is `derivedTmax_spec`, definitional), and the branch budget
at the `β`-linear figure the fuel forces. A caller supplies a universe containing the seed and the
four residual hypotheses, and reads the fuel and the budget off the statement. -/
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

/-! ### The sibling terminus, at the length budget

The two theorems above are stated against `DifficultyBounded`, and `DifficultyBounded` is
**refutable at every `D`** at any universe the engine fires on
(`difficultyBounded_multiplicity_false`). They are not thereby wrong — they are conditionals, and a
conditional with an unsatisfiable antecedent is true — but a caller cannot use them, which is a
defect worth repairing rather than describing.

The repair is a substitution, not a re-proof. `StepLengthBounded fc U L` is `DifficultyBounded`'s
own statement with `estimateBranchDifficulty _ ≤ D` weakened to `_.length ≤ L`, it implies
`DifficultyBounded fc U (difficultyCeiling U L)` under `UniverseClosed`
(`difficultyBounded_of_stepLengthBounded`), and it is satisfiable — `StepLengthGrowth` reduces it to
a finite case analysis over `applyRule`'s 36 arms. So the siblings below are the landed termini with
one hypothesis exchanged and `D` read off as `difficultyCeiling U L`; each is a single application
of the landed theorem, with no new induction and no change to `stepDecreases_budgetPotential`.

**What changed is the *shape* of one residual, and only that.** `UniverseClosed`,
`MintPaysForTime`, `PostBlockingSettles` and `β ≥ 3` are carried across unaltered and are still
named. `Fuel.lean` needs nothing new: every occurrence of `D` in the terminus chain flows through
`mintAwareFuel`'s `D` argument (`mintAwareFuel`, `stepDecreases_budgetPotential`,
`expandBranchWithFuel_isSome_of_budget`), all inside this file, so instantiating it at
`difficultyCeiling U L` is a substitution into statements that already quantify over it. -/

/-- **The terminus at a branch-length budget.** `buildTableauAt_isSome_of_budget` with
`hD : DifficultyBounded fc U D` replaced by `hL : StepLengthBounded fc U L`, and every `D`
instantiated at `difficultyCeiling U L`. Unlike its `DifficultyBounded` sibling, this statement's
difficulty hypothesis is not refutable. -/
theorem buildTableauAt_isSome_of_lengthBudget {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {mintBudget Tmax L β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosed fc U) (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTime fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 8 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuel U.card Tmax mintBudget (difficultyCeiling U L) β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuel U.card Tmax mintBudget (difficultyCeiling U L) β) fc
        maxBranches).isSome = true :=
  buildTableauAt_isSome_of_budget phi maxBranches hβ hUcl
    (difficultyBounded_of_stepLengthBounded hL hUcl) hmint hpb hseed hmb hT hbud

/-- **The caller-facing form at a branch-length budget**, the sibling of
`buildTableauAt_isSome_at_seed`. Every number is read off: the mint budget at
`mintPotential_le_eight_mul`'s ceiling, the time bound at `derivedTmax`, the branch budget at the
`β`-linear figure, and the difficulty coefficient at `difficultyCeiling U L`. A caller supplies a
universe containing the seed, a bound `L` on how long a successor branch can get, and the other
three residuals. -/
theorem buildTableauAt_isSome_at_seed_lengthBudget {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {L β : Nat} (phi : Formula)
    (hβ : 3 ≤ β) (hUcl : UniverseClosed fc U) (hL : StepLengthBounded fc U L)
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
  buildTableauAt_isSome_at_seed phi hβ hUcl
    (difficultyBounded_of_stepLengthBounded hL hUcl) hmint hpb hseed

end FormalSystem.Metalogic.Decidability

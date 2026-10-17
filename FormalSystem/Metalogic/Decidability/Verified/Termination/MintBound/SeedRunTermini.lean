/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.PostBlocking
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.FiveComponent

/-! # The seedRun terminus family

The termini stated at `PostBlockingSettlesSeedRun` — the post-blocking settlement residual
narrowed to runs started from the four arguments `buildTableauAt` always supplies at their
defaults (`ord := TimeOrdering.empty`, `tr := EventualityTracker.empty`, `ap := {}`, `bu := 0`).

This module is the only additive join of two parallel branches of the import graph.
`PostBlocking.lean` sits off `SigmaFixed.lean` and carries the narrowing, its bridge
`buildTableauAt_isSome_of_settlesSeedRun`, and the `_fixed_seedRun` family's root
`buildTableauAt_isSome_of_budget_fixed_seedRun`. `FiveComponent.lean` sits off
`MintPaysAssembly.lean` and carries the five-component engine lemma
`expandBranchWithFuel_isSome_of_budget_gap`. Neither branch can see the other, so the members
below — which need both — live here rather than in either.

**The status of the carried residual, stated exactly.** `PostBlockingSettlesSeedRun` is neither
refuted nor proved. Register entry 25 (`Register.lean`) records the verdict on the wider
`PostBlockingSettlesRun` (**false**, by `postBlockingSettlesRun_terminusFuel_false` and
`postBlockingSettlesRun_false_succ`), records that the seed narrowing kills that witness, and
records a **second, structurally independent refutation route against the narrowing that is
unprobed**: `saturateBlocked` may extend `ob`, and `expandOnceNoFresh` ignores blocking, so
label-free work at a blocked time can break `isSubsetBlocked` and unblock a time carrying
label-minting work that `expandOnceNoFresh` itself skips. Any claim that
`PostBlockingSettlesSeedRun` holds must gate on that route first.

**No member of this module discharges anything.** Each carries the seed narrowing as a
hypothesis, and each carries co-hypotheses that register entries 9, 11 and 26 refute at the
frame classes they are aimed at. Landing a family here buys uniformity — a caller reaching for
the seed-fuel or length-budget form of a seedRun terminus finds it stated rather than having to
re-derive it — and buys nothing about vacuity. The `signedUniverse` slots (S5/S6) of both lines
below are **absent by decision**: each would carry `UnorderedSuccessorLabelClosed`, which
`unorderedSuccessorLabelClosed_nonempty_false` refutes at every nonempty finite label set, so each
would be vacuous at exactly the universes it is aimed at.

**The two lines.** The `_fixed_seedRun` line reads its minting residual off
`MintPaysForTimeFixed fc U Tmax`, a hypothesis the caller must meet and provably cannot at
`.Dense` or `.RTime`. The `_gap_seedRun` line takes no `hmint` at all: the five-component engine
lemma supplies the residual internally from `mintPaysForTimeGap_of_any`, which needs no
frame-class hypothesis. The price is the enlarged mint-budget floor
`10 * U.card + U.card * U.card` and the enlarged fuel figure `mintAwareFuelGap`.

**Authoring rule for this file.** `PostBlockingSettlesSeedRun` is indexed by a *fuel figure*, so
unlike `PostBlockingSettles` it does not thread unchanged down a family. Every member's `hpb`
must name that member's own conclusion fuel expression, not the root's. A figure copied from the
root instead yields a type-correct, provable, quietly wrong theorem.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

section SeedRunTermini

/-! ### The `_fixed_seedRun` line, S2-S4

`buildTableauAt_isSome_of_budget_fixed_seedRun` (the S1 root, in `PostBlocking.lean`) instantiated
at the three remaining call sites of the six-slot convention. `harm : ArmSettlement fc` is threaded
explicitly at every member: the `_fixed` line's S2-S4 forms obtain it from
`armSettlement_of_postBlockingSettles`, which the seed narrowing does not support. -/

/-- **S2, the seed-fuel form.** `Tmax` and the mint budget both read off `derivedTmaxAt`, with
`hpb` transcribed at this statement's own conclusion figure. The seed narrowing is a carried
hypothesis here, not a discharge — see this module's header and register entry 25. -/
theorem buildTableauAt_isSome_at_seed_fixed_seedRun
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {D β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeFixed fc U
      (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card))
    (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelAt U.card
        (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
        (10 * U.card) D β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) D β)
        fc
        (β * mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) D β)
      ).isSome = true :=
  buildTableauAt_isSome_of_budget_fixed_seedRun phi _ hβ hUcl hD hmint harm hpb hseed
    (Nat.le_refl _) (derivedTmaxAt_spec (seedBranch phi) U) (Nat.le_refl _)

/-- **S3, the length-budget form.** `DifficultyBounded fc U D` traded for
`StepLengthBounded fc U L` through `difficultyBounded_of_stepLengthBounded_at`, so the difficulty
figure in both the conclusion and `hpb` is `difficultyCeiling U L`. The seed narrowing is a
carried hypothesis here, not a discharge. -/
theorem buildTableauAt_isSome_of_lengthBudget_fixed_seedRun
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax L β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTimeFixed fc U Tmax) (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β
      ≤ maxBranches) :
    (buildTableauAt phi
        (mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β) fc
        maxBranches).isSome = true :=
  buildTableauAt_isSome_of_budget_fixed_seedRun phi maxBranches hβ hUcl
    (difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint harm hpb hseed hmb hT hbud

/-- **S4, the seed-fuel length-budget form.** S2 through the same `StepLengthBounded` trade. Both
instantiations land in `hpb`'s figure as well as the conclusion's. The seed narrowing is a carried
hypothesis here, not a discharge. -/
theorem buildTableauAt_isSome_at_seed_lengthBudget_fixed_seedRun
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {L β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTimeFixed fc U
      (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card))
    (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelAt U.card
        (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
        (10 * U.card) (difficultyCeiling U L) β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) (difficultyCeiling U L) β)
        fc
        (β * mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) (difficultyCeiling U L) β)
      ).isSome = true :=
  buildTableauAt_isSome_at_seed_fixed_seedRun phi hβ hUcl
    (difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint harm hpb hseed

end SeedRunTermini

end FormalSystem.Metalogic.Decidability

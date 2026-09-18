/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MonotoneIssuance

/-! # The self-guard component re-gated at the oriented arm

`MonotoneIssuance.lean`'s gate is about the renaming the identification arm produced **at the
time that gate was built**. Arm 3 merged `t₂` into `t₁` whatever their magnitudes, so at the reuse
witness's own trigger `(0, 2)` it produced `rhoSF 2 0` — retiring the *larger* numeral — and
`gateSigma` is exactly that renaming. `identifyOrient` retires the smaller numeral instead, so at
the same trigger the arm now produces `rhoSF 0 2`, and no run produces `rhoSF 2 0` there any more.

That distinction is the whole of the σ-hit obligation, and it cuts the other way from Phase 1.
`rhoSF src tgt`'s image omits exactly `src` (`rhoSF_time_ne_src`) and fixes every other time on the
nose (`rhoSF_time_eq_of_ne_src` below), while `src_not_mem_knownTimes_identifyTime` says the
post-arm branch carries no formula at `src` at all. Under the oriented arm the renaming therefore
fixes the time of **every formula the branch still carries**, so the *time* hit `selfGuardPotential`
needs is available at every trigger the engine can select: the trigger is a branch formula, and the
branch's times are precisely the ones the renaming fixes.

**`mintPaysForTimeAt_reuse_false` is untouched by this and stays true exactly as stated.**
`MintPaysForTimeAt` quantifies `σ` with no tie to the state it is read at, so a renaming no run
produces still refutes it, and register entry 17 stands as a statement about that predicate. What
changes is that the refuting renaming is now identifiable *by a property of the state it is applied
at* rather than only by provenance: `gateSigma` moves the gate's own trigger off its own time, and
no renaming the oriented arm produces does that to a formula the branch still carries.
`SigmaTimeStable` names that property; `MintPaysForTimeStable` is `MintPaysForTimeAt` carrying it.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The converse of `rhoSF_time_ne_src`: every time but the retired one is fixed on the nose.**

One line, and it is the positive half of the σ-hit story that Phase 1 had no use for. `rho src tgt`
is an `if` on `t = src`, so away from `src` it is the identity — which is why the *only* time a
single identification's renaming can fail to hit is the one it retires. -/
theorem rhoSF_time_eq_of_ne_src {src tgt : TimeIndex} {sf : SignedFormula}
    (h : sf.label.time ≠ src) : (rhoSF src tgt sf).label.time = sf.label.time := by
  simp [rhoSF, rho, h]

/-- **The converse of `selfGuard_no_column_at_retired_time`: at a live time a column *is* indexed.**

`selfGuard_no_column_at_retired_time` says no column of `selfGuardRules ×ˢ U` sits at the retired
index. This says the retired index is the *only* one missing: for any `sf ∈ U` whose time is not
`src`, the pair `(untlNeg, sf)` is a column of the index set and its σ-image sits at exactly
`sf.label.time`.

Together the two lemmas locate the obstruction precisely. It was never that the ledger is indexed
too narrowly; it was that the one time the renaming omits happened, under the unoriented arm, to be
a time the engine could re-issue and put a trigger at. -/
theorem selfGuard_column_at_live_time {src tgt : TimeIndex} {U : Finset SignedFormula}
    {sf : SignedFormula} (hsf : sf ∈ U) (hlive : sf.label.time ≠ src) :
    ((TableauRule.untlNeg, sf) : TableauRule × SignedFormula) ∈ selfGuardRules ×ˢ U ∧
      (rhoSF src tgt sf).label.time = sf.label.time := by
  have hr : TableauRule.untlNeg ∈ selfGuardRules := by decide
  exact ⟨Finset.mem_product.mpr ⟨hr, hsf⟩, rhoSF_time_eq_of_ne_src hlive⟩

/-- The orientation's two numerals are distinct exactly when the trigger's are. -/
theorem identifyOrient_ne {t₁ t₂ : TimeIndex} (hne : t₁ ≠ t₂) :
    (identifyOrient t₁ t₂).1 ≠ (identifyOrient t₁ t₂).2 := by
  simp only [identifyOrient]
  rcases Nat.le_total t₁ t₂ with hle | hle
  · rw [Nat.min_eq_left hle, Nat.max_eq_right hle]; exact hne
  · rw [Nat.min_eq_right hle, Nat.max_eq_left hle]; exact hne.symm

/-- **σ-time-stability**: the accumulated renaming moves no formula the branch still carries off
its own time.

This is the property that separates the renamings a run can produce from the ones it cannot, and it
is stated *at the state* rather than by provenance so that it can be assumed, discharged and
decided. It is deliberately weaker than "σ fixes the branch pointwise" — only times are constrained,
because only times are what `selfGuardDischarged` reads.

Note what it does **not** say. It puts no condition on `σ` away from `b`, so it does not exclude a
renaming that moves times the branch has already lost; that is exactly right, since a column at a
lost time can no longer be flipped by any rule the engine fires. -/
def SigmaTimeStable (σ : SignedFormula → SignedFormula) (b : Branch) : Prop :=
  ∀ x ∈ b, (σ x).label.time = x.label.time

/-- **The oriented arm's own renaming is σ-time-stable at the state the arm produces.**

The general reason the re-gate below comes out the other way, and it needs nothing but the two
facts either side of it: the post-arm branch carries no formula at the retired index
(`src_not_mem_knownTimes_identifyTime`), and away from that index the renaming is the identity on
times (`rhoSF_time_eq_of_ne_src`).

No membership hypothesis on `t₁` or `t₂` is used, and none is available to be used — the statement
holds on an arbitrary branch at any two distinct times. Under the unoriented arm the same proof
gives the same conclusion about `rhoSF t₂ t₁`; what the orientation buys is not this lemma but
`retired_lt_nextTime_oriented`, which is what stops the engine from ever putting a trigger back at
the retired index. -/
theorem sigmaTimeStable_identifyOriented {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (hne : t₁ ≠ t₂) :
    SigmaTimeStable (rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2)
      (identifyOriented b ord t₁ t₂).1 := by
  intro x hx
  simp only [identifyOriented] at hx
  refine rhoSF_time_eq_of_ne_src ?_
  intro hEq
  have hmem : x.label.time
      ∈ (b.identifyTime (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2).knownTimes :=
    mem_knownTimes_of_mem hx
  rw [hEq] at hmem
  exact src_not_mem_knownTimes_identifyTime b _ _ (identifyOrient_ne hne) hmem

/-- **`SigmaTimeStable` is exactly what excludes Phase 1's gate, and it excludes nothing else
there.** Decided at both configurations, side by side, so the exclusion is measured rather than
asserted.

Conjunct 1 is the whole content: `gateSigma = rhoSF 2 0` moves the gate's own trigger off time `2`,
which is why no column of the ledger sat at the trigger's time and why disjunct 3 could not fall.
Conjunct 2 records that the oriented renaming is no better *at that branch* — `gateBranch` carries
a formula at time `0`, the index the oriented arm retires — which is the honest statement: the
Phase-1 gate is not a state the oriented arm produces at all, under either renaming. Conjunct 3 is
the oriented gate below, where the arm's own renaming is stable. -/
theorem gateSigma_not_sigmaTimeStable :
    (¬ SigmaTimeStable gateSigma gateBranch) ∧ ¬ SigmaTimeStable (rhoSF 0 2) gateBranch := by
  refine ⟨fun h => ?_, fun h => ?_⟩
  · exact absurd (h gateTrigger (by decide)) (by decide)
  · exact absurd (h (SignedFormula.pos mwP ⟨0, 0⟩) (by decide)) (by decide)

/-- **The repaired time-minting residual**: `MintPaysForTimeAt`'s body verbatim, with the renaming
tied to the state it is read at by one added hypothesis and nothing removed.

Two hypotheses were added to `MintPaysForTime` on the way here and both weaken the predicate, so
the implication runs `MintPaysForTime → MintPaysForTimeStable` and never the other way. This is the
`universeClosedAt_of_universeClosed` idiom. It does **not** factor through `MintPaysForTimeAt`: that
predicate's third disjunct is the bare `selfGuardPotential` drop, this one's pairs the drop with a
combined-budget conjunct, and the pairing is forced — see below.

**What the added hypothesis is for.** `MintPaysForTimeAt` is refuted as stated by
`mintPaysForTimeAt_reuse_false`, and that refutation is permanent: `σ` is quantified there with no
tie to `b`, so a renaming that moves the trigger off its own time defeats any σ-mediated ledger.
`SigmaTimeStable σ b` is the minimal statement excluding exactly that, and it is not a wish —
`sigmaTimeStable_identifyOriented` discharges it at the state the identification arm produces, with
no membership hypothesis at all.

**What it is not.** It is not a constraint on the frame class, on `U`, on `Tmax`, or on the branch;
it is a constraint on the renaming, which is the one argument of `MintPaysForTime` that no consumer
of the terminus supplies from outside. See `mintPaysForTimeStable_no_leak` below.

**Why the third disjunct is a pair.** It mirrors disjunct 2 exactly: disjunct 2 pairs a
`mintPotential` drop with a `mintTimeBudget` non-increase, and this one pairs a `selfGuardPotential`
drop with a **combined**-budget non-increase — the mint budget plus the self-guard potential. The
pairing is forced, not decorative. A self-guarded mint raises `mintTimeBudget` by one, and
`extensionAllowance` carries a factor of `|U|` per unit of mint budget, so without a cap on the
combined quantity the measure does not fall however the fourth component is weighted. The combined
form is the right one because the mint spends exactly one unit of the fourth component to buy the
one unit of mint budget it consumes: the component funds the budget rather than sitting beside it.
Measured at the oriented gate, `26 + 3 = 29` before and `27 + 1 = 28` after
(`orientedGate_disjunct3_holds`). The consequence is that `MintPaysForTimeAt`, whose third disjunct
is the bare drop, does **not** imply this predicate; see `mintPaysForTimeStable_of_mintPaysForTime`.

**The density residual is unchanged.** Everything `MintPaysForTimeAt`'s obligation map records
about `densityRule` applies here verbatim: `densityRule` mints a fresh time while lying outside
both `freshLabelRules` and `selfGuardRules`, so no disjunct moves, and the intended component
`gapPotential` remains a named residual. See the subsection "The density residual" and register
entry 17. -/
def MintPaysForTimeStable (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (Tmax : Nat) : Prop :=
  ∀ (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering)
    (tr : EventualityTracker), RunInvariant b ord → (∀ x ∈ b, x ∈ U) → SigmaTimeStable σ b →
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      (nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card ∧
        splitOrderedRank Tmax nb (expandOnceUnblocked b ord fc tr).2
          ≤ splitOrderedRank Tmax b ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord ∧
          mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
            < mintPotential U σ b ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord + selfGuardPotential U σ ord ∧
          selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
            < selfGuardPotential U σ ord)

/-- **Direction lemma, first link.** `MintPaysForTimeAt` adds a disjunct and removes nothing, so
every consumer of `MintPaysForTime` can be restated against it. -/
theorem mintPaysForTimeAt_of_mintPaysForTime {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat} (h : MintPaysForTime fc U Tmax) :
    MintPaysForTimeAt fc U Tmax := by
  intro σ b ord tr hri hconf nb hnb
  rcases h σ b ord tr hri hconf nb hnb with h1 | h2
  · exact Or.inl h1
  · exact Or.inr (Or.inl h2)

/-- **Direction lemma, second link.** The statement a reader restating an existing terminus needs:
`MintPaysForTimeStable` adds a hypothesis and a disjunct and removes nothing, so it is weaker than
`MintPaysForTime` and every theorem restated against it is a strengthening.

**It does *not* factor through `MintPaysForTimeAt`, and that is deliberate.** The two predicates'
third disjuncts differ: `MintPaysForTimeAt`'s is the bare `selfGuardPotential` drop, while this
one's pairs that drop with a **combined-budget** conjunct, exactly as disjunct 2 pairs its
`mintPotential` drop with a plain budget conjunct. The pairing is not decoration — see
`budgetStateAt_of_disjunct3` — so `MintPaysForTimeAt → MintPaysForTimeStable` is unavailable and is
not claimed. Both disjuncts 1 and 2 survive verbatim, which is all this lemma needs. -/
theorem mintPaysForTimeStable_of_mintPaysForTime {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat} (h : MintPaysForTime fc U Tmax) :
    MintPaysForTimeStable fc U Tmax := by
  intro σ b ord tr hri hconf _ nb hnb
  rcases h σ b ord tr hri hconf nb hnb with h1 | h2
  · exact Or.inl h1
  · exact Or.inr (Or.inl h2)

/-! #### The oriented gate: the same measurement at the renaming the oriented arm produces

Phase 1's gate is rebuilt here at the state the *oriented* arm hands back from the same reuse
witness at the same trigger `(0, 2)`. Everything is a faithful mirror: the ordering is
`TimeOrdering.identifyTime reuseWitnessOrd 0 2` on the nose, the branch is that arm's branch with an
`untlNeg` trigger placed at the one time whose forward reach the ordering leaves empty, and the
renaming is the `rhoSF` the arm itself produces. Only the orientation differs.

The discipline is Phase 1's, unchanged. All three disjuncts are measured, not just the favourable
one; the hazard conjuncts are decided separately so a verdict cannot be attributed to a violated
precondition; and the unfavourable renaming is measured at the same step so the verdict is located
at σ rather than at the ledger's shape. -/

/-- The oriented gate's trigger. `untl` again, so the vehicle is `mintWitnessTrigger`'s and the
comparison with Phase 1 is at one moving part. It sits at time `1`, the time whose forward reach
the post-arm ordering leaves empty — `untlNeg`'s ACTIVE guard. -/
def orientedGateTrigger : SignedFormula := SignedFormula.neg (Formula.untl mwG mwE) ⟨0, 1⟩

/-- The oriented gate branch: the trigger, then the two atoms the oriented arm leaves at times `2`
and `1`. Under the orientation the retired numeral is `0`, so — unlike `gateBranch` — no formula
here sits at a retired index, which is exactly what `orientedGate_sigmaTimeStable` decides. -/
def orientedGateBranch : Branch :=
  [orientedGateTrigger, SignedFormula.pos mwP ⟨0, 2⟩, SignedFormula.pos mwQ ⟨0, 1⟩]

/-- The oriented gate ordering. It is `TimeOrdering.identifyTime reuseWitnessOrd 0 2` on the nose:
the arm substitutes `0 ↦ 2` in the single constraint `(0, 1)`, leaving `(2, 1)`. `futureOf 1` is
empty and `timeCount` is `2`, which is `untlNeg`'s ACTIVE guard. -/
def orientedGateOrd : TimeOrdering := ⟨[(2, 1)]⟩

/-- The oriented gate universe: the branch itself, so confinement is immediate — the same choice
`gateUniverse` makes. -/
def orientedGateUniverse : Finset SignedFormula :=
  {orientedGateTrigger, SignedFormula.pos mwP ⟨0, 2⟩, SignedFormula.pos mwQ ⟨0, 1⟩}

/-- The first arm of the split the ACTIVE `untlNeg` reports: `F(e)` at the freshly minted time `3`,
the re-included trigger, and the original branch. -/
def orientedGateSucc : Branch :=
  [SignedFormula.neg mwE ⟨0, 3⟩, orientedGateTrigger, orientedGateTrigger,
   SignedFormula.pos mwP ⟨0, 2⟩, SignedFormula.pos mwQ ⟨0, 1⟩]

/-- The ordering after the ACTIVE arm: `addFuture 1 3` prepended. This is the edge that cures the
trigger's column — and, under the oriented renaming, the column is actually there to be cured. -/
def orientedGateNewOrd : TimeOrdering := ⟨[(1, 3), (2, 1)]⟩

/-- **The renaming the oriented arm produces.** `rhoSF 0 2`, not `rhoSF 2 0`: `identifyOrient 0 2`
is `(0, 2)`, so the numeral the arm retires is `0` and the numeral that survives is `2`.

`gateSigma` is the *same arm at the same trigger* under the old orientation, which is the entire
difference between this subsection's verdict and Phase 1's. -/
def orientedGateSigma : SignedFormula → SignedFormula := rhoSF 0 2

/-- The oriented gate state satisfies the run invariant. -/
theorem orientedGate_runInvariant : RunInvariant orientedGateBranch orientedGateOrd := by
  constructor
  · unfold IrreflOrd orientedGateOrd; decide
  · unfold OrdTimesKnown; decide

/-- …and it is confined to the oriented gate universe. -/
theorem orientedGate_confined : ∀ x ∈ orientedGateBranch, x ∈ orientedGateUniverse := by decide

/-- **The oriented gate really is the oriented arm's state at the reuse witness's own trigger.**
Seven conjuncts, all decided, in the discipline `gate_is_reissue_hazard` uses — and deliberately
the *same seven questions*, so the two gates can be read side by side.

1-2. the standing hypotheses hold at the oriented gate state;
3. `firstIncomparablePair` selects `(0, 2)` on the predecessor state, so the identification that
   produces `orientedGateSigma` is the one the engine itself takes;
4. the numeral the oriented arm retires is `0`, and it really is retired;
5. …and, unlike under the old orientation, it is **not** re-issued: the post-arm `nextTime` is `3`,
   strictly above the retired index. This is conjunct 5 of `gate_is_reissue_hazard` with its verdict
   reversed, and it is the whole mechanism;
6. the oriented gate ordering is exactly what that identification leaves behind;
7. the trigger sits at a live time and `untlNeg`'s ACTIVE guard is met there — empty forward reach,
   with `timeCount` inside the `(0, 4)` window. -/
theorem orientedGate_is_oriented_arm_state :
    IrreflOrd orientedGateOrd ∧ OrdTimesKnown orientedGateBranch orientedGateOrd ∧
      firstIncomparablePair reuseWitnessBranch reuseWitnessOrd = some (0, 2) ∧
      ((identifyOrient 0 2).1 = 0 ∧
        0 ∉ (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1.knownTimes) ∧
      (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1.nextTime = 3 ∧
      orientedGateOrd.constraints
        = (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).2.constraints ∧
      (orientedGateTrigger.label.time = 1 ∧ (orientedGateOrd.futureOf 1).isEmpty = true ∧
        0 < orientedGateOrd.timeCount ∧ orientedGateOrd.timeCount < 4) := by
  refine ⟨?_, ?_, by decide, ⟨by decide, by decide⟩, by decide, by decide,
    by decide, by decide, by decide, by decide⟩
  · unfold IrreflOrd orientedGateOrd; decide
  · unfold OrdTimesKnown; decide

/-- **The oriented gate's renaming is σ-time-stable at it, and Phase 1's is not at Phase 1's.**

The discriminating hypothesis, decided at both configurations. This is the conjunct that makes
`mintPaysForTimeAt_reuse_false` and the verdict below consistent rather than contradictory: the two
gates are distinguished by a property of the *state*, not by an appeal to provenance.

Conjunct 2 also records `sigmaTimeStable_identifyOriented`'s content at the concrete configuration,
so the general lemma can be checked against a number. -/
theorem orientedGate_sigmaTimeStable :
    SigmaTimeStable orientedGateSigma orientedGateBranch ∧
      SigmaTimeStable (rhoSF (identifyOrient 0 2).1 (identifyOrient 0 2).2)
        (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1 := by
  refine ⟨?_, sigmaTimeStable_identifyOriented (by decide)⟩
  change ∀ x ∈ orientedGateBranch, (orientedGateSigma x).label.time = x.label.time
  decide

/-- **The engine fires the ACTIVE arm here**, at every frame class: the reported ordering is
`orientedGateNewOrd` and `orientedGateSucc` is one of the two unordered successors. `untlNeg` is a
`carrierBase` rule, so this is not a frame-class accident. The mirror of `gate_step_fires`. -/
theorem orientedGate_step_fires (fc : FormalSystem.ProofSystem.FrameClass) :
    (expandOnceUnblocked orientedGateBranch orientedGateOrd fc EventualityTracker.empty).2.constraints
        = orientedGateNewOrd.constraints ∧
      orientedGateSucc ∈ unorderedSuccessorBranches
        (expandOnceUnblocked orientedGateBranch orientedGateOrd fc EventualityTracker.empty).1 := by
  cases fc <;> exact ⟨by decide, by decide⟩

/-- **The self-guard potential falls at the oriented gate, under the arm's own renaming.** `3` to
`1`. The trigger's column at time `1` flips uncured → cured, and so does the column of the atom
sitting there — which is the mechanism `selfGuardPotential` was designed around, working.

This is the exact measurement `selfGuardPotential_eq_at_gate_with_sigma` reports as `3 → 3`. The
only difference is which numeral the identification arm retired. -/
theorem selfGuardPotential_lt_at_orientedGate :
    selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateNewOrd
      < selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateOrd := by decide

/-- **All three disjuncts measured, not just the favourable one.** The mirror of the numbers in
`mintPaysForTimeAt_reuse_false`'s docstring, at the oriented gate.

Disjuncts 1 and 2 fail here exactly as they failed at Phase 1's gate, and for the same reasons: the
step mints time `3`, so `knownTimes` rises `2 → 3`; `mintTimeBudget` rises `26 → 27` and
`mintPotential` is `24` before and after, because `untlNeg` is not in `freshLabelRules`. Disjunct 3
is the one that moves, `3 → 1`, and it is the only one that does. The fourth component is carrying
the step on its own — which is what it was for. -/
theorem orientedGate_disjuncts_measured :
    orientedGateBranch.knownTimes.toFinset.card = 2 ∧
      orientedGateSucc.knownTimes.toFinset.card = 3 ∧
      mintTimeBudget orientedGateUniverse orientedGateSigma orientedGateBranch orientedGateOrd
        = 26 ∧
      mintTimeBudget orientedGateUniverse orientedGateSigma orientedGateSucc orientedGateNewOrd
        = 27 ∧
      mintPotential orientedGateUniverse orientedGateSigma orientedGateBranch orientedGateOrd
        = 24 ∧
      mintPotential orientedGateUniverse orientedGateSigma orientedGateSucc orientedGateNewOrd
        = 24 ∧
      selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateOrd = 3 ∧
      selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateNewOrd = 1 := by
  decide

/-- **The verdict, side by side, in one statement.** The same component, the same rule, the same
witness, the same trigger — and opposite outcomes, separated only by which numeral the
identification arm retires.

Conjunct 1 restates `selfGuardPotential_eq_at_gate_with_sigma`: under the old orientation the
potential does not move. Conjunct 2 is the oriented measurement. Conjunct 3 records that the
unoriented renaming is not inert *here* either — it also falls, `4 → 2` — so the verdict is not an
artifact of the oriented gate being an easier configuration; every renaming pays at a state whose
trigger sits at a live time.

This is the pairing `oriented_arm_is_not_inert` sets the precedent for. -/
theorem orientedGate_verdict_side_by_side :
    selfGuardPotential gateUniverse gateSigma gateNewOrd
        = selfGuardPotential gateUniverse gateSigma gateOrd ∧
      selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateNewOrd
        < selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateOrd ∧
      selfGuardPotential orientedGateUniverse gateSigma orientedGateNewOrd
        < selfGuardPotential orientedGateUniverse gateSigma orientedGateOrd := by
  decide

/-- **The repaired predicate's third disjunct, decided at the oriented gate.** Both conjuncts, at
both reported successors, at every frame class.

Split out from the verdict below because it is the half that `decide` can evaluate: the combined
budget mentions the successor branch, so the statement has to be read with the `∀ nb` still inside
it rather than after an `intro`. The numbers are `27 + 1 ≤ 26 + 3` and `1 < 3`. -/
theorem orientedGate_disjunct3_holds (fc : FormalSystem.ProofSystem.FrameClass) :
    ∀ nb ∈ unorderedSuccessorBranches
        (expandOnceUnblocked orientedGateBranch orientedGateOrd fc EventualityTracker.empty).1,
      (mintTimeBudget orientedGateUniverse orientedGateSigma nb
          (expandOnceUnblocked orientedGateBranch orientedGateOrd fc EventualityTracker.empty).2
          + selfGuardPotential orientedGateUniverse orientedGateSigma
            (expandOnceUnblocked orientedGateBranch orientedGateOrd fc
              EventualityTracker.empty).2
          ≤ mintTimeBudget orientedGateUniverse orientedGateSigma orientedGateBranch
            orientedGateOrd
            + selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateOrd) ∧
      selfGuardPotential orientedGateUniverse orientedGateSigma
          (expandOnceUnblocked orientedGateBranch orientedGateOrd fc EventualityTracker.empty).2
        < selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateOrd := by
  cases fc <;> decide

/-- **VERDICT: the re-gate decides TRUE.** `MintPaysForTimeStable`'s body holds at the oriented
gate, at every frame class, every `Tmax` and every reported successor.

*The verdict in words.* Phase 1's FALSE verdict does **not** survive the reorientation of the
identification arm. It was a statement about `rhoSF 2 0` — the renaming the arm produced when it
merged the larger numeral away — and the arm no longer produces it at that trigger, or at any
other. At the renaming the arm now produces, the self-guard discharge potential pays for the
self-guarded minting step on its own, which is what the component was designed to do.

*What is decided here and what is not.* This is a gate, and it decides exactly what Phase 1's gate
decided, with the sign reversed: the design is not refuted at the configuration that refuted it, so
the plumbing may be built. It is **not** a proof of `MintPaysForTimeStable` at any `U` — that is the
work the plan's later phases carry, and the density residual (`gapPotential`) is untouched by it.
A reader who takes this theorem for the discharge has taken a decided instance for a quantified
statement.

*Why this does not contradict `mintPaysForTimeAt_reuse_false`.* That theorem is about
`MintPaysForTimeAt`, which quantifies `σ` with no tie to the state it is read at, and it stays true.
`MintPaysForTimeStable` carries `SigmaTimeStable σ b`, which `gateSigma_not_sigmaTimeStable` decides
false at Phase 1's gate and `orientedGate_sigmaTimeStable` decides true here, and which
`sigmaTimeStable_identifyOriented` discharges at every state the identification arm produces. The
two verdicts are about two predicates and both stand. See register entry 19. -/
theorem mintPaysForTimeStable_body_at_orientedGate
    (fc : FormalSystem.ProofSystem.FrameClass) (Tmax : Nat) :
    ∀ nb ∈ unorderedSuccessorBranches
        (expandOnceUnblocked orientedGateBranch orientedGateOrd fc EventualityTracker.empty).1,
      (nb.knownTimes.toFinset.card ≤ orientedGateBranch.knownTimes.toFinset.card ∧
        splitOrderedRank Tmax nb
            (expandOnceUnblocked orientedGateBranch orientedGateOrd fc
              EventualityTracker.empty).2
          ≤ splitOrderedRank Tmax orientedGateBranch orientedGateOrd)
      ∨ (mintTimeBudget orientedGateUniverse orientedGateSigma nb
            (expandOnceUnblocked orientedGateBranch orientedGateOrd fc
              EventualityTracker.empty).2
            ≤ mintTimeBudget orientedGateUniverse orientedGateSigma orientedGateBranch
              orientedGateOrd ∧
          mintPotential orientedGateUniverse orientedGateSigma nb
            (expandOnceUnblocked orientedGateBranch orientedGateOrd fc
              EventualityTracker.empty).2
            < mintPotential orientedGateUniverse orientedGateSigma orientedGateBranch
              orientedGateOrd)
      ∨ (mintTimeBudget orientedGateUniverse orientedGateSigma nb
            (expandOnceUnblocked orientedGateBranch orientedGateOrd fc
              EventualityTracker.empty).2
            + selfGuardPotential orientedGateUniverse orientedGateSigma
              (expandOnceUnblocked orientedGateBranch orientedGateOrd fc
                EventualityTracker.empty).2
            ≤ mintTimeBudget orientedGateUniverse orientedGateSigma orientedGateBranch
              orientedGateOrd
              + selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateOrd ∧
          selfGuardPotential orientedGateUniverse orientedGateSigma
            (expandOnceUnblocked orientedGateBranch orientedGateOrd fc
              EventualityTracker.empty).2
            < selfGuardPotential orientedGateUniverse orientedGateSigma orientedGateOrd) := by
  intro nb hnb
  exact Or.inr (Or.inr (orientedGate_disjunct3_holds fc nb hnb))

/-! #### The component's structural facts: index-set agreement, the ceiling, growth

With the gate decided the plumbing every consumer needs can be built. All four statements below are
transcriptions of the already-landed `mintPotential` siblings, and the transcription is exact except
in one place: `selfGuardPotential` does not take a `Branch`, so the growth lemma needs only the
ordering half of `mintPotential_le_of_grow`'s hypothesis and no branch-monotonicity fact at all. -/

/-- **Index-set agreement**, the anti-drift guarantee. Mirrors `mem_freshLabelRules` and
`mem_freshTimeRules`: if the list is ever widened, every consumer that reads this lemma breaks
loudly rather than silently counting extra columns. -/
theorem mem_selfGuardRules {r : TableauRule} :
    r ∈ selfGuardRules ↔ (r = TableauRule.untlNeg ∨ r = TableauRule.snceNeg) := by
  cases r <;> simp [selfGuardRules]

/-- **`selfGuardPotential ≤ 2 · |U|`**, immediately, for every ordering and every renaming: the
filter cannot exceed its index set, and the index set is a product with a two-element left factor.

The coefficient is the index set's width and nothing else, which is the point of choosing a second
ledger over a widening: `mintPotential`'s ceiling is `8 · |U|` and stays `8 · |U|`. Transcribed from
`mintPotential_le_eight_mul`. -/
theorem selfGuardPotential_le_two_mul (U : Finset SignedFormula)
    (σ : SignedFormula → SignedFormula) (ord : TimeOrdering) :
    selfGuardPotential U σ ord ≤ 2 * U.card := by
  refine le_trans (Finset.card_filter_le _ _) ?_
  rw [Finset.card_product, selfGuardRules_card]

/-- A non-empty reach transports along any map that carries its members into the target reach.

The one shared shape behind both growth and both transport arguments below: `selfGuardDischarged`
reads `!(reach).isEmpty`, so every preservation statement about it is "some member survives", and
the member's identity is never used. Stating it once keeps the four rule cases below to a single
line each. -/
theorem not_isEmpty_transport (φ : TimeIndex → TimeIndex) {l l' : List TimeIndex}
    (h : ∀ x ∈ l, φ x ∈ l') (hl : (!l.isEmpty) = true) : (!l'.isEmpty) = true := by
  simp only [Bool.not_eq_true', List.isEmpty_eq_false_iff] at hl ⊢
  obtain ⟨x, hx⟩ := List.exists_mem_of_ne_nil _ hl
  exact List.ne_nil_of_mem (h x hx)

/-- **A discharged self-guard stays discharged as the ordering grows.** Consumes
`TimeOrdering.futureOf_mono` / `TimeOrdering.pastOf_mono`.

The hypothesis is supplied at every call site by the mint arms themselves: `addFuture` and `addPast`
only cons onto `ord.constraints`, so the pre-step constraint list is literally a sublist of the
post-step one. The catch-all rules close by `rfl`, since their column is `true` at every ordering —
the polarity choice `selfGuardDischarged`'s docstring explains. -/
theorem selfGuardDischarged_le_of_grow {ord ord' : TimeOrdering}
    (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) (r : TableauRule) (sf : SignedFormula)
    (h : selfGuardDischarged r sf ord = true) : selfGuardDischarged r sf ord' = true := by
  cases r <;> simp only [selfGuardDischarged] at h ⊢ <;>
    first
      | rfl
      | exact not_isEmpty_transport id (fun x hx => TimeOrdering.futureOf_mono hord _ x hx) h
      | exact not_isEmpty_transport id (fun x hx => TimeOrdering.pastOf_mono hord _ x hx) h

/-- **An ordinary step does not increase the self-guard potential.** The ordering grows, so
`selfGuardDischarged` can only turn on; contrapositively the after-`false` set is a *subset* of the
before-`false` set inside the same index set, and no injection is needed.

Transcribed from `mintPotential_le_of_grow`, minus its branch-growth hypothesis: the component does
not take a `Branch`, so the branch half has no analogue and no call site has to supply one. This
covers `.extended`, `.split`, and the ordered split's first two arms — every step that keeps `σ`. -/
theorem selfGuardPotential_le_of_grow {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord ord' : TimeOrdering}
    (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) :
    selfGuardPotential U σ ord' ≤ selfGuardPotential U σ ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hd : selfGuardDischarged p.1 (σ p.2) ord with _ | _
  · rfl
  · rw [selfGuardDischarged_le_of_grow hord p.1 (σ p.2) hd] at hp
    exact absurd hp.2 (by simp)

/-! #### Preservation across the identification arm — Constraint (F), discharged

The crux. The ordered split's arm 3 is the one step at which the whole design has to be checked
rather than argued, because it is the step every `knownTimes.card`-affine candidate dies at: a
self-guarded mint raises the known-time count and the identification arm lowers it, so no sign of
coefficient satisfies both. `selfGuardPotential` is not affine in that count — it is not a function
of the branch at all — and what has to be shown instead is that the arm does not *raise* it.

It does not, and with room to spare: the arm's renaming is post-composed onto σ, no constraint is
dropped at an incomparable trigger (`identifyTime_no_collapse`), and reachability transports edge by
edge (`futureOf_transport` / `pastOf_transport`). So the discharged set only grows and the uncured
count only falls. **This is Constraint (F) discharged with equality-or-better**, and it is what
separates Candidate 2 from every candidate the constraint kills.

The `incomparableB ord (t₁, t₂)` side condition is not a new hypothesis. It is available at the
consuming site from `firstIncomparablePair_spec`, whose last two conjuncts are literally
`incomparableB`'s two clauses, and at the engine's own orientation from
`incomparableB_of_firstIncomparablePair_oriented`. `IrreflOrd` is likewise the run invariant's own
first conjunct — and it is *necessary*, not convenient: `witnessPresent_identifyTime_unconditional_false`
(register entry 5) refutes the `IrreflOrd`-free form for the sibling predicate, and the reason
carries over verbatim, since `TimeOrdering.identifyTime` drops a pre-existing self-loop whose two
endpoints rename together. -/

/-- **A discharged self-guard survives the identification arm, renamed.**

Three steps, exactly the ones the design was fixed on. (1) No constraint is dropped:
`identifyTime_no_collapse` gives `rho t₂ t₁ a ≠ rho t₂ t₁ b` for every constraint, and
`TimeOrdering.identifyTime`'s `filterMap` discards only when the two components collapse. (2)
Non-emptiness transports: `futureOf_transport` / `pastOf_transport` carry a witnessing member of the
reach to a member of the renamed reach, length-preservingly, so the `100`-step fuel bound is
re-met at the same length. (3) The column index lines up, because `rhoSF` acts on the label's time
by exactly the `rho` the reach transport is stated at. -/
theorem selfGuardDischarged_identifyTime {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (hinc : incomparableB ord (t₁, t₂) = true) (hnsl : IrreflOrd ord)
    (r : TableauRule) (sf : SignedFormula) (h : selfGuardDischarged r sf ord = true) :
    selfGuardDischarged r (rhoSF t₂ t₁ sf) (ord.identifyTime t₂ t₁) = true := by
  cases r <;> simp only [selfGuardDischarged, rhoSF] at h ⊢ <;>
    first
      | rfl
      | exact not_isEmpty_transport (rho t₂ t₁)
          (fun x hx => futureOf_transport ord t₁ t₂ hinc hnsl _ x hx) h
      | exact not_isEmpty_transport (rho t₂ t₁)
          (fun x hx => pastOf_transport ord t₁ t₂ hinc hnsl _ x hx) h

/-- **The identification arm does not increase the self-guard potential.**

`Finset.card_le_card` over the previous lemma: the filter's `true`-set only grows, so the
`false`-set only shrinks, inside an index set that does not move. No injection from the after-set
into the before-set is required, and none is available — `rhoSF t₂ t₁` is not injective on `U`.
This is the same skeleton as `mintPotential_identifyTime`, one lemma deeper.

Because the renaming is *post-composed* onto the parameter, the statement applies unchanged at a
second, third or `n`-th identification along the same run. -/
theorem selfGuardPotential_identifyTime {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (hinc : incomparableB ord (t₁, t₂) = true) (hnsl : IrreflOrd ord) :
    selfGuardPotential U (fun x => rhoSF t₂ t₁ (σ x)) (ord.identifyTime t₂ t₁)
      ≤ selfGuardPotential U σ ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hd : selfGuardDischarged p.1 (σ p.2) ord with _ | _
  · rfl
  · rw [selfGuardDischarged_identifyTime hinc hnsl p.1 (σ p.2) hd] at hp
    exact absurd hp.2 (by simp)

/-- **…at the engine's own orientation.** `selfGuardPotential_identifyTime` read at
`(min t₁ t₂, max t₁ t₂)`, which is the merge arm 3 actually performs.

One fact deeper and nothing else: `incomparableB_of_firstIncomparablePair_oriented` supplies the
side condition at the flipped pair, via `incomparableB_symm`. The two statements are otherwise
definitionally the same, which is the concrete payoff of having stated the transport stack in
`src` / `tgt` rather than in the trigger's own coordinates. -/
theorem selfGuardPotential_identifyOriented {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    selfGuardPotential U
        (fun x => rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 (σ x))
        (identifyOriented b ord t₁ t₂).2
      ≤ selfGuardPotential U σ ord :=
  selfGuardPotential_identifyTime (incomparableB_of_firstIncomparablePair_oriented htrig) hirr

/-! #### The σ-hit obligation, discharged rather than carried

Register entry 14 instructed that the σ-hit residual be *carried structurally* rather than
discharged, and Phase 1's gate is why: at the unoriented arm it is false, so carrying it was the
only honest option. `SigmaTimeStable` changes that. The obligation asks for some `sf ∈ U` whose
σ-image sits at the trigger's time; the trigger is a branch formula; confinement puts it in `U`; and
σ-time-stability says σ does not move it off its own time. Three facts, one line, no search.

This is the single place where the reorientation pays off in the measure's own terms, and it is
worth being precise about what it costs. Nothing is assumed here that a consumer does not already
have: `∀ x ∈ b, x ∈ U` is `MintPaysForTime`'s own second hypothesis, unchanged since the predicate
was written, and `SigmaTimeStable σ b` is discharged at the identification arm by
`sigmaTimeStable_identifyOriented`. -/

/-- **The σ-hit obligation, discharged from confinement and σ-time-stability.**

The trigger witnesses its own hit. `mintPotential_lt_of_mint`'s formula-level obligation is *not*
available this way — it needs `σ sf = g` on the nose, and `rhoSF`'s image genuinely omits formulas —
but the time-level obligation `selfGuardPotential` reads is, and that difference is the whole reason
the fourth component is indexed by time rather than by formula. -/
theorem sigma_time_hit_of_sigmaTimeStable {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} (hconf : ∀ x ∈ b, x ∈ U)
    (hst : SigmaTimeStable σ b) {sf : SignedFormula} (hsf : sf ∈ b) :
    ∃ x ∈ U, (σ x).label.time = sf.label.time :=
  ⟨sf, hconf sf hsf, hst sf hsf⟩

/-- **`SigmaTimeStable` at a single renaming is exactly "the branch has lost the retired index".**

An `iff`, so it can be used in both directions: to *discharge* stability from a branch fact, and to
*read off* a branch fact from stability. `sigmaTimeStable_identifyOriented` is the forward direction
instantiated at the arm's own post-state; this is the general statement behind it. -/
theorem sigmaTimeStable_rhoSF_iff {src tgt : TimeIndex} {b : Branch} (h : tgt ≠ src) :
    SigmaTimeStable (rhoSF src tgt) b ↔ ∀ x ∈ b, x.label.time ≠ src := by
  constructor
  · intro hst x hx hc
    exact rhoSF_time_ne_src h x ((hst x hx).trans hc)
  · intro hne x hx
    exact rhoSF_time_eq_of_ne_src (hne x hx)

/-- **…and a branch every one of whose times is above the retired index is stable.**

The form the run-level argument consumes. Under the oriented arm the retired index is strictly below
the post-arm `nextTime` (`retired_lt_nextTime_oriented`) and `nextTime` is non-decreasing along the
run (`nextTime_monotone_along_run`), so every time the run mints after the arm is strictly above
every index the arm retired — which is exactly this hypothesis, and is why growth cannot break
stability. -/
theorem sigmaTimeStable_rhoSF_of_lt {src tgt : TimeIndex} {b : Branch} (h : tgt ≠ src)
    (hlt : ∀ x ∈ b, src < x.label.time) : SigmaTimeStable (rhoSF src tgt) b :=
  (sigmaTimeStable_rhoSF_iff h).mpr (fun x hx => Ne.symm (Nat.ne_of_lt (hlt x hx)))

/-! #### The discharge lemmas: `untlNeg` and `snceNeg` pay for their own mints

Each self-guarded rule fires only when its own reach is empty and returns an ordering that makes
that reach non-empty. So its trigger's column flips uncured → cured at exactly the step it mints,
and by `selfGuardPotential_le_of_grow` no other column flips the other way — the edge is *added*,
never removed. One column strictly lost from a set that only shrinks is a strict decrease.

**Research risk R2 is dissolved rather than discharged, and that is a finding worth recording.**
The plan asked for a prior lemma placing the freshly minted time outside the ordering's endpoints,
on the worry that the mint might create a new *uncured* column and cancel the flip. It cannot:
`selfGuardPotential` does not take a `Branch`, the index set `selfGuardRules ×ˢ U` is fixed, and a
mint step changes neither `U` nor `σ`. So the freshly minted formula has no column at all unless it
already had one, and the column indices do not move. The `OrdTimesKnown`-plus-`nextTime > maxTime`
argument the plan reserved for this is not needed, and reaching for it would have been reaching for
a fact about a quantity the component deliberately does not read.

**Research risk R3 is resolved by measurement, not by assumption.** The `snceNeg` mirror below is
exact: same guard shape read off the arm's own `if` rather than off its comment
(`pastTimes.isEmpty && timeCount > 0 && timeCount < 4`), same one-edge `newOrd`
(`timeOrd.addPast l.time freshTime`), and `addPast ord t tf = (tf, t) :: ord.constraints`, so the
curing edge runs *into* the trigger's time and `mem_pastOf_of_mem_constraints` closes it. The proof
is a transcription with `futureOf → pastOf` and nothing else changed. -/

/-- **Adding a forward edge out of an uncured time strictly drops the potential.**

Stated at the ordering operation rather than at the rule, because that is where the content is: the
rule's contribution is `newOrd = ord.addFuture l.time freshTime` and its guard
`(ord.futureOf l.time).isEmpty`, both of which appear here as hypotheses and are supplied at the
engine level by `applyRule_untlNeg_active_ord`.

The σ-hit hypothesis is `hhit`, and it is **not** vacuous: `sigma_time_hit_of_sigmaTimeStable`
discharges it from confinement plus σ-time-stability, and `selfGuardPotential_lt_at_orientedGate`
decides the whole conclusion at a concrete configuration. At the unoriented arm it is false, which
is what `mintPaysForTimeAt_reuse_false` records. -/
theorem selfGuardPotential_lt_of_addFuture {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord : TimeOrdering} {t tf : TimeIndex}
    (hempty : (ord.futureOf t).isEmpty = true)
    {sf : SignedFormula} (hsf : sf ∈ U) (hhit : (σ sf).label.time = t) :
    selfGuardPotential U σ (ord.addFuture t tf) < selfGuardPotential U σ ord := by
  have hgrow : ∀ q ∈ ord.constraints, q ∈ (ord.addFuture t tf).constraints := by
    intro q hq; simp only [TimeOrdering.addFuture, List.mem_cons]; exact Or.inr hq
  refine Finset.card_lt_card ⟨?_, ?_⟩
  · intro p hp
    simp only [Finset.mem_filter] at hp ⊢
    refine ⟨hp.1, ?_⟩
    rcases hd : selfGuardDischarged p.1 (σ p.2) ord with _ | _
    · rfl
    · rw [selfGuardDischarged_le_of_grow hgrow p.1 (σ p.2) hd] at hp
      exact absurd hp.2 (by simp)
  · intro hsub
    have hmemR : TableauRule.untlNeg ∈ selfGuardRules := by decide
    have hcol : ((TableauRule.untlNeg, sf) : TableauRule × SignedFormula)
        ∈ (selfGuardRules ×ˢ U).filter
          (fun p => selfGuardDischarged p.1 (σ p.2) ord = false) := by
      simp only [Finset.mem_filter]
      refine ⟨Finset.mem_product.mpr ⟨hmemR, hsf⟩, ?_⟩
      simp only [selfGuardDischarged, hhit, hempty]
      rfl
    have hnil : ((ord.addFuture t tf).futureOf t) ≠ [] :=
      List.ne_nil_of_mem
        (mem_futureOf_of_mem_constraints _ t tf (by simp [TimeOrdering.addFuture]))
    have hcured : selfGuardDischarged TableauRule.untlNeg (σ sf) (ord.addFuture t tf) = true := by
      simp only [selfGuardDischarged, hhit, Bool.not_eq_true', List.isEmpty_eq_false_iff]
      exact hnil
    have hfalse := (Finset.mem_filter.mp (hsub hcol)).2
    rw [hcured] at hfalse
    exact absurd hfalse (by simp)

/-- **The exact past mirror.** `addPast ord t tf` is `(tf, t) :: ord.constraints`, so the new edge
runs *into* `t` and `mem_pastOf_of_mem_constraints` puts `tf` in `t`'s past. Transcription of the
lemma above with `futureOf → pastOf`, `addFuture → addPast`, `untlNeg → snceNeg`; nothing else
differs, which is the measurement research risk R3 asked for. -/
theorem selfGuardPotential_lt_of_addPast {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord : TimeOrdering} {t tf : TimeIndex}
    (hempty : (ord.pastOf t).isEmpty = true)
    {sf : SignedFormula} (hsf : sf ∈ U) (hhit : (σ sf).label.time = t) :
    selfGuardPotential U σ (ord.addPast t tf) < selfGuardPotential U σ ord := by
  have hgrow : ∀ q ∈ ord.constraints, q ∈ (ord.addPast t tf).constraints := by
    intro q hq; simp only [TimeOrdering.addPast, List.mem_cons]; exact Or.inr hq
  refine Finset.card_lt_card ⟨?_, ?_⟩
  · intro p hp
    simp only [Finset.mem_filter] at hp ⊢
    refine ⟨hp.1, ?_⟩
    rcases hd : selfGuardDischarged p.1 (σ p.2) ord with _ | _
    · rfl
    · rw [selfGuardDischarged_le_of_grow hgrow p.1 (σ p.2) hd] at hp
      exact absurd hp.2 (by simp)
  · intro hsub
    have hmemR : TableauRule.snceNeg ∈ selfGuardRules := by decide
    have hcol : ((TableauRule.snceNeg, sf) : TableauRule × SignedFormula)
        ∈ (selfGuardRules ×ˢ U).filter
          (fun p => selfGuardDischarged p.1 (σ p.2) ord = false) := by
      simp only [Finset.mem_filter]
      refine ⟨Finset.mem_product.mpr ⟨hmemR, hsf⟩, ?_⟩
      simp only [selfGuardDischarged, hhit, hempty]
      rfl
    have hnil : ((ord.addPast t tf).pastOf t) ≠ [] :=
      List.ne_nil_of_mem
        (mem_pastOf_of_mem_constraints _ tf t (by simp [TimeOrdering.addPast]))
    have hcured : selfGuardDischarged TableauRule.snceNeg (σ sf) (ord.addPast t tf) = true := by
      simp only [selfGuardDischarged, hhit, Bool.not_eq_true', List.isEmpty_eq_false_iff]
      exact hnil
    have hfalse := (Finset.mem_filter.mp (hsub hcol)).2
    rw [hcured] at hfalse
    exact absurd hfalse (by simp)

/-- **The `untlNeg` ACTIVE arm's ordering, read off the engine.** The arm returns
`timeOrd.addFuture l.time branch.nextTime` and nothing else touches the ordering component, so the
discharge lemma's `addFuture` hypothesis is the engine's own output rather than a modelling choice.

The guard is transcribed exactly as the arm's `if` writes it — `futureTimes.isEmpty &&
timeOrd.timeCount > 0 && timeOrd.timeCount < 4` — because the arm's *comment* and the arm's `if`
disagreed historically and the `if` is what fires. -/
theorem applyRule_untlNeg_active_ord {sign : Sign} {φ : Formula} {l : Label}
    {b : Branch} {ord : TimeOrdering} {e g : Formula}
    (hsign : sign = Sign.neg) (hform : asUntil? φ = some (e, g))
    (hguard : ((ord.futureOf l.time).isEmpty && decide (0 < ord.timeCount)
      && decide (ord.timeCount < 4)) = true) :
    (applyRule TableauRule.untlNeg ⟨sign, φ, l⟩ b ord).2 = ord.addFuture l.time b.nextTime := by
  subst hsign
  simp only [applyRule, hform, hguard, if_true]

/-- **The `snceNeg` ACTIVE arm's ordering, read off the engine.** The past mirror, same shape,
`addPast` in place of `addFuture`. -/
theorem applyRule_snceNeg_active_ord {sign : Sign} {φ : Formula} {l : Label}
    {b : Branch} {ord : TimeOrdering} {e g : Formula}
    (hsign : sign = Sign.neg) (hform : asSince? φ = some (e, g))
    (hguard : ((ord.pastOf l.time).isEmpty && decide (0 < ord.timeCount)
      && decide (ord.timeCount < 4)) = true) :
    (applyRule TableauRule.snceNeg ⟨sign, φ, l⟩ b ord).2 = ord.addPast l.time b.nextTime := by
  subst hsign
  simp only [applyRule, hform, hguard, if_true]

/-- **The `untlNeg` discharge lemma, assembled.** At an ACTIVE `untlNeg` firing on a branch formula,
under confinement and σ-time-stability, the self-guard potential strictly drops.

Every hypothesis here is one a consumer already has. `hconf` is `MintPaysForTime`'s own second
hypothesis; `hst` is `MintPaysForTimeStable`'s added one, discharged at the identification arm by
`sigmaTimeStable_identifyOriented`; `hguard` is the arm's own firing condition, so it is available
wherever the arm fired; and `hsf` says the trigger is on the branch, which every `pick` stage
supplies. Nothing is assumed about the frame class, `Tmax`, or the shape of `U`. -/
theorem selfGuardPotential_lt_of_untlNeg {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {φ : Formula} {l : Label} {e g : Formula}
    (hconf : ∀ x ∈ b, x ∈ U) (hst : SigmaTimeStable σ b)
    (hsf : (⟨Sign.neg, φ, l⟩ : SignedFormula) ∈ b) (hform : asUntil? φ = some (e, g))
    (hguard : ((ord.futureOf l.time).isEmpty && decide (0 < ord.timeCount)
      && decide (ord.timeCount < 4)) = true) :
    selfGuardPotential U σ (applyRule TableauRule.untlNeg ⟨Sign.neg, φ, l⟩ b ord).2
      < selfGuardPotential U σ ord := by
  obtain ⟨x, hxU, hxt⟩ := sigma_time_hit_of_sigmaTimeStable hconf hst hsf
  rw [applyRule_untlNeg_active_ord rfl hform hguard]
  refine selfGuardPotential_lt_of_addFuture ?_ hxU hxt
  simpa using (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hguard).1).1

/-- **The `snceNeg` discharge lemma, assembled.** The exact past mirror of the lemma above. -/
theorem selfGuardPotential_lt_of_snceNeg {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {φ : Formula} {l : Label} {e g : Formula}
    (hconf : ∀ x ∈ b, x ∈ U) (hst : SigmaTimeStable σ b)
    (hsf : (⟨Sign.neg, φ, l⟩ : SignedFormula) ∈ b) (hform : asSince? φ = some (e, g))
    (hguard : ((ord.pastOf l.time).isEmpty && decide (0 < ord.timeCount)
      && decide (ord.timeCount < 4)) = true) :
    selfGuardPotential U σ (applyRule TableauRule.snceNeg ⟨Sign.neg, φ, l⟩ b ord).2
      < selfGuardPotential U σ ord := by
  obtain ⟨x, hxU, hxt⟩ := sigma_time_hit_of_sigmaTimeStable hconf hst hsf
  rw [applyRule_snceNeg_active_ord rfl hform hguard]
  refine selfGuardPotential_lt_of_addPast ?_ hxU hxt
  simpa using (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hguard).1).1

/-! #### The run-level form of the σ hypothesis, and the no-leak confirmation

`SigmaTimeStable σ b` is stated per *formula*, which is the weakest form the discharge lemmas need
and therefore the right one to put in the predicate. It is **not** the right form to carry along a
run, and the reason is worth stating rather than discovering later: the identification arm replaces
branch formulas by their renamed images, and a renamed image need not have been on the branch
before, so a per-formula hypothesis about the old branch says nothing about it.

The time-level strengthening `SigmaTimeFixed` closes that gap. It quantifies over *every* formula
sitting at a branch time rather than over branch formulas, which is exactly the extra reach the
arm's relabelling needs, and it implies the per-formula form immediately. Everything else about it
is the same: `id` satisfies it, the arm preserves it, and it is discharged rather than assumed.

**What is confirmed here, and what is left named.** The arm — the only step that changes σ — is
handled in full. Additive steps do not change σ at all, so the only way one can break the invariant
is by minting a time σ retires; `SigmaFixesFrom` plus `sigmaTimeFixed_grow_of_fixesFrom` is the
supply for that, and the fact that closes it is the reorientation's own
(`retired_lt_nextTime_oriented`: every index the arm retires is strictly below the `nextTime` at
which the run afterwards mints, and `nextTime_monotone_along_run` keeps it there). Assembling those
into a single run-level invariant is measure-level work and belongs with the step lemmas, not here;
it is named as an obligation rather than assumed. -/

/-- **The time-level form of the σ hypothesis.** Every formula sitting at a time the branch knows
keeps its time under `σ`.

Stronger than `SigmaTimeStable` in exactly one respect — it reaches formulas that are not on the
branch but sit at a time that is — and that is the respect the identification arm needs, since the
arm puts renamed formulas on the branch that were not there before. -/
def SigmaTimeFixed (σ : SignedFormula → SignedFormula) (b : Branch) : Prop :=
  ∀ x : SignedFormula, x.label.time ∈ b.knownTimes → (σ x).label.time = x.label.time

/-- The time-level form implies the per-formula form the predicate carries. One line: a branch
formula's time is a branch time. -/
theorem sigmaTimeStable_of_sigmaTimeFixed {σ : SignedFormula → SignedFormula} {b : Branch}
    (h : SigmaTimeFixed σ b) : SigmaTimeStable σ b :=
  fun x hx => h x (mem_knownTimes_of_mem hx)

/-- **The seed satisfies it for free.** `σ` is `id` before the first ordered split, so the run
starts inside the invariant and no caller supplies anything. -/
theorem sigmaTimeFixed_id (b : Branch) : SigmaTimeFixed id b := fun _ _ => rfl

/-- **The identification arm preserves it.** The one step that changes `σ`, handled in full.

Two facts and nothing else. The post-arm branch's times are a subset of the pre-arm branch's
(`knownTimes_identifyTime_subset`, which is why the surviving numeral has to be a known time — the
same side condition `universeClosedAt_identify_at_trigger_oriented` carries, and no more), so the
old invariant applies to every time the new branch knows; and the post-arm branch has lost the
retired index, so the arm's own `rhoSF` is the identity on every time still present.

Under the *unoriented* arm this lemma is equally true — it is not what the reorientation buys. What
the reorientation buys is that the retired index stays retired, which is
`retired_lt_nextTime_oriented`'s business, not this one's. -/
theorem sigmaTimeFixed_identifyOriented {σ : SignedFormula → SignedFormula} {b : Branch}
    {ord : TimeOrdering} {t₁ t₂ : TimeIndex} (hne : t₁ ≠ t₂)
    (hmax : (identifyOrient t₁ t₂).2 ∈ b.knownTimes) (h : SigmaTimeFixed σ b) :
    SigmaTimeFixed
      (fun x => rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 (σ x))
      (identifyOriented b ord t₁ t₂).1 := by
  intro x hx
  simp only [identifyOriented] at hx
  have hb : x.label.time ∈ b.knownTimes := knownTimes_identifyTime_subset hmax _ hx
  have hnesrc : x.label.time ≠ (identifyOrient t₁ t₂).1 := by
    intro hc
    exact src_not_mem_knownTimes_identifyTime b _ _ (identifyOrient_ne hne) (hc ▸ hx)
  have hfix := h x hb
  exact (rhoSF_time_eq_of_ne_src (by rw [hfix]; exact hnesrc)).trans hfix

/-- **σ retires nothing at or above `n`.** The provenance fact about the accumulated renaming that
additive steps need: a freshly minted time is safe as soon as it is at least `n`.

Stated as a property of `σ` rather than as a claim about how `σ` was built, so that it composes
(`sigmaFixesFrom_comp`) and weakens (`sigmaFixesFrom_mono`) without a provenance predicate. -/
def SigmaFixesFrom (σ : SignedFormula → SignedFormula) (n : TimeIndex) : Prop :=
  ∀ x : SignedFormula, n ≤ x.label.time → (σ x).label.time = x.label.time

/-- `id` retires nothing, at any watermark. -/
theorem sigmaFixesFrom_id (n : TimeIndex) : SigmaFixesFrom id n := fun _ _ => rfl

/-- A single renaming retires nothing above the index it retires. -/
theorem sigmaFixesFrom_rhoSF {src tgt n : TimeIndex} (h : src < n) :
    SigmaFixesFrom (rhoSF src tgt) n :=
  fun _x hx => rhoSF_time_eq_of_ne_src (Nat.ne_of_gt (Nat.lt_of_lt_of_le h hx))

/-- …and post-composing another one keeps the watermark, provided the new retired index is below
it. This is the induction step of the run-level provenance argument, and it is where
`retired_lt_nextTime_oriented` is consumed. -/
theorem sigmaFixesFrom_comp {σ : SignedFormula → SignedFormula} {src tgt n : TimeIndex}
    (hσ : SigmaFixesFrom σ n) (h : src < n) :
    SigmaFixesFrom (fun x => rhoSF src tgt (σ x)) n := by
  intro x hx
  have hfix := hσ x hx
  exact (rhoSF_time_eq_of_ne_src
    (by rw [hfix]; exact Nat.ne_of_gt (Nat.lt_of_lt_of_le h hx))).trans hfix

/-- The watermark may be raised freely. `nextTime_monotone_along_run` is what raises it. -/
theorem sigmaFixesFrom_mono {σ : SignedFormula → SignedFormula} {n m : TimeIndex}
    (h : SigmaFixesFrom σ n) (hle : n ≤ m) : SigmaFixesFrom σ m :=
  fun x hx => h x (le_trans hle hx)

/-- **Growth preserves the invariant, given the obligation on the new times.** The obligation is
stated rather than assumed away: every time the successor knows is either one the predecessor knew,
or one `σ` fixes. -/
theorem sigmaTimeFixed_grow {σ : SignedFormula → SignedFormula} {b b' : Branch}
    (h : SigmaTimeFixed σ b)
    (hnew : ∀ t ∈ b'.knownTimes, t ∈ b.knownTimes ∨ ∀ x : SignedFormula, x.label.time = t →
      (σ x).label.time = x.label.time) :
    SigmaTimeFixed σ b' := by
  intro x hx
  rcases hnew x.label.time hx with hb | hfix
  · exact h x hb
  · exact hfix x rfl

/-- **…and the form the run-level argument actually uses.** The new-time obligation is discharged by
a watermark: a successor's times are the predecessor's plus fresh ones, and the fresh ones are at
least `b.nextTime`, which is strictly above every index the run has retired. -/
theorem sigmaTimeFixed_grow_of_fixesFrom {σ : SignedFormula → SignedFormula} {b b' : Branch}
    {n : TimeIndex} (h : SigmaTimeFixed σ b) (hfix : SigmaFixesFrom σ n)
    (hnew : ∀ t ∈ b'.knownTimes, t ∈ b.knownTimes ∨ n ≤ t) : SigmaTimeFixed σ b' := by
  refine sigmaTimeFixed_grow h (fun t ht => ?_)
  rcases hnew t ht with hb | hle
  · exact Or.inl hb
  · exact Or.inr (fun x hxt => hfix x (hxt ▸ hle))

/-- **The no-leak confirmation.** Three conjuncts, and together they are the whole claim that the
repair costs no consumer a hypothesis.

*The direction.* Conjunct 1: `MintPaysForTimeStable` is **weaker** than `MintPaysForTime` — a
disjunct was added and a hypothesis was added, and nothing was removed — so every terminus currently
carrying `MintPaysForTime` as a residual hypothesis can be restated against the repaired predicate
and the restatement is a **strengthening**. This is the `universeClosedAt_of_universeClosed` idiom
(`MintBound.lean` section D1) and the `ordTimesLeMaxTime_of_ordTimesKnown` idiom (section A3), used
here for the third time in this file. Saying this in words is not a formality: register entry 7
exists because a "simplification" that was secretly a weakening was once mistaken for a repair.

*The added hypothesis is discharged, not assumed.* Conjunct 2: the run starts inside it, since `σ`
is `id` before the first ordered split. Conjunct 3: the identification arm — the only step that
changes `σ` — preserves it, needing exactly the side condition
`universeClosedAt_identify_at_trigger_oriented` already carries and nothing more.

*What is named rather than closed.* Additive steps leave `σ` alone, so the only remaining way to
leave the invariant is to mint a time `σ` retires. `sigmaTimeFixed_grow_of_fixesFrom` reduces that
to a watermark, and `retired_lt_nextTime_oriented` plus `nextTime_monotone_along_run` supply the
watermark; assembling them into a single quantified run invariant is measure-level work and is
carried as a named obligation of the step lemmas, not discharged here.

*The only other cost is a coefficient.* A fourth component forces `mintPathBound` / `mintAwareFuel`
to absorb `2·(Tmax²+1)·2·|U|`. That is an arithmetic enlargement of exactly the kind register entry
8 already records for `splitAwareFuel_le_mintAwareFuel` — not a new assumption on any caller, and
not a change to any consuming terminus's hypothesis list. -/
theorem mintPaysForTimeStable_no_leak {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat} :
    (MintPaysForTime fc U Tmax → MintPaysForTimeStable fc U Tmax) ∧
      (∀ b : Branch, SigmaTimeFixed id b) ∧
      (∀ (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering)
          (t₁ t₂ : TimeIndex), t₁ ≠ t₂ → (identifyOrient t₁ t₂).2 ∈ b.knownTimes →
        SigmaTimeFixed σ b →
        SigmaTimeFixed
          (fun x => rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 (σ x))
          (identifyOriented b ord t₁ t₂).1) :=
  ⟨mintPaysForTimeStable_of_mintPaysForTime, sigmaTimeFixed_id,
   fun _ _ _ _ _ hne hmax h => sigmaTimeFixed_identifyOriented hne hmax h⟩

end FormalSystem.Metalogic.Decidability

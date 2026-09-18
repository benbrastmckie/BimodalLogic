/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.FourComponent

/-! # The formula-level σ obligation, and the refutation it forces

`FourComponent.lean` stops at `U = ∅` and names the **density** coordinate as what blocks a
nonempty discharge. That account is incomplete, and the missing half is decided here rather than
argued: `MintPaysForTimeStable` is **false** at a concrete nonempty `signedUniverse C L`, at every
frame class and every `Tmax`, with no `densityRule` anywhere near the vehicle.

*Why the density account missed it.* `sigma_time_hit_of_sigmaTimeStable` discharges the σ-hit
obligation `selfGuardPotential` reads, and its own docstring already records that
`mintPotential_lt_of_mint`'s obligation is **not** available the same way — it needs `σ sf = g` on
the nose. Disjunct 2 is the only disjunct that pays for the six rules in
`freshLabelRules ∩ freshTimeRules`, and those rules mint at times whose reach the self-guard
component may already count as cured, so disjunct 3 cannot stand in for it. `SigmaTimeStable`
constrains σ's *times* and nothing else, so a renaming that preserves every label and destroys every
formula satisfies it while pinning `mintPotential` at its ceiling forever.

*The vehicle.* `flatSigma` sends every signed formula to a fixed positive atom **at its own label**.
`witnessPresent`'s match is on `(rule, sign, formula)` and every arm that could fire needs a
temporal or modal shape, so an atom falls through to the catch-all at all thirty-six rules:
`mintPotential U flatSigma b ord = 8 · |U|` at *every* state (`mintPotential_flatSigma`), so
disjunct 2's strict inequality is unavailable at every step of every run. What remains is to find
one step that mints while curing no self-guard column, and `untlPos` at a time whose future is
already non-empty is such a step — it is witness-guarded, so it is exactly one of the six rules
disjunct 2 was carrying.

*What is not claimed.* This does not withdraw anything. `MintPaysForTimeStable`'s direction lemma,
its no-leak confirmation, the four-component measure and the restated termini all stand exactly as
they are; what changes is the reading of the residual they carry, from "open at nonempty `U`, at the
density coordinate" to "false at nonempty `U`, at the formula coordinate, **and** open at the
density coordinate". See register entry 20. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The formula-destroying, time-preserving renaming.** Every signed formula goes to a fixed
positive atom at its own label, so the label — and therefore the time — is untouched and the formula
is gone. -/
def flatSigma : SignedFormula → SignedFormula := fun x => ⟨Sign.pos, mwP, x.label⟩

/-- It is `SigmaTimeStable` on **every** branch, by `rfl`. This is the whole point: the hypothesis
`MintPaysForTimeStable` adds is satisfied by a renaming no run produces, and satisfied for free. -/
theorem flatSigma_sigmaTimeStable (b : Branch) : SigmaTimeStable flatSigma b := fun _ _ => rfl

/-- **Its image is witness-free at every rule, state and ordering.** `witnessPresent` matches on the
formula's shape at all eight fresh-label arms — `.box`, `asDiamond?`, `.allFuture`, `.allPast`,
`asSomeFuture?`, `asSomePast?`, `asUntil?`, `asSince?` — and an atom matches none of them, so every
arm falls through to the catch-all. Decided over all thirty-six constructors. -/
theorem witnessPresent_flatSigma (r : TableauRule) (x : SignedFormula) (b : Branch)
    (ord : TimeOrdering) : witnessPresent r (flatSigma x) b ord = false := by
  cases r <;> rfl

/-- **So `mintPotential` is pinned at its own ceiling, at every state.** Compare
`mintPotential_le_eight_mul`, which bounds it: under `flatSigma` the bound is met with equality
everywhere, so the potential is a constant function of the state and disjunct 2's strict inequality
is unavailable at every step of every run — before any configuration is chosen. -/
theorem mintPotential_flatSigma (U : Finset SignedFormula) (b : Branch) (ord : TimeOrdering) :
    mintPotential U flatSigma b ord = 8 * U.card := by
  simp only [mintPotential]
  rw [Finset.filter_true_of_mem
      (fun p _ => witnessPresent_flatSigma p.1 p.2 b ord),
    Finset.card_product, freshLabelRules_card]

/-- **…while the fourth component measures exactly what `id` measures.** `selfGuardDischarged` reads
only `sf.label.time`, and `flatSigma` preserves the label, so the refutation cannot be dismissed as
one that also breaks the self-guard ledger: that ledger sees the identity. -/
theorem selfGuardPotential_flatSigma (U : Finset SignedFormula) (ord : TimeOrdering) :
    selfGuardPotential U flatSigma ord = selfGuardPotential U id ord := rfl

/-- The refuting trigger: `U(g, e)` positive at time `1`, a **witness-guarded** minting rule's
vehicle (`untlPos ∈ freshLabelRules ∩ freshTimeRules`), so the step it drives is one disjunct 2 was
carrying and disjunct 3 never claimed. -/
def fhTrigger : SignedFormula := SignedFormula.pos (Formula.untl mwG mwE) ⟨0, 1⟩

/-- The refuting branch. The two atoms carry times `0` and `2`, which `OrdTimesKnown` requires of
the ordering below and which also put the trigger's time strictly inside the order. -/
def fhBranch : Branch :=
  [fhTrigger, SignedFormula.pos mwP ⟨0, 0⟩, SignedFormula.pos mwQ ⟨0, 2⟩]

/-- The refuting ordering: `0 < 1 < 2`. The trigger sits at `1`, whose future is **already**
non-empty — which is what makes the step invisible to the self-guard component, since `untlNeg`'s
column at time `1` is already cured before the step and stays cured after it. -/
def fhOrd : TimeOrdering := { constraints := [(0, 1), (1, 2)] }

/-- The label rectangle. Deliberately excludes time `3`, the index the step mints: the new edge
`(1, 3)` therefore puts nothing into the past of any time the universe indexes, so no self-guard
column flips at all. -/
def fhLabels : Finset Label := {⟨0, 0⟩, ⟨0, 1⟩, ⟨0, 2⟩}

/-- The formula stock: the trigger's formula and the two carrier atoms. -/
def fhStock : Finset Formula := {mwP, mwQ, Formula.untl mwG mwE}

/-- The first arm of the `untlPos` split: the event at the freshly minted time `3`, then the
re-included trigger and the original branch. -/
def fhSucc : Branch :=
  [SignedFormula.pos mwE ⟨0, 3⟩, fhTrigger, SignedFormula.pos mwP ⟨0, 0⟩,
   SignedFormula.pos mwQ ⟨0, 2⟩]

/-- The refuting state satisfies the run invariant, so the refutation is not reached by feeding the
predicate a state the run cannot occupy. -/
theorem fh_runInvariant : RunInvariant fhBranch fhOrd := by
  constructor
  · unfold IrreflOrd fhOrd; decide
  · unfold OrdTimesKnown; decide

/-- …and it is confined to a **concrete, nonempty** `signedUniverse`, which is the universe shape
the seed-level termini consume. -/
theorem fh_confined : ∀ x ∈ fhBranch, x ∈ signedUniverse fhStock fhLabels := by decide

/-- The universe is nonempty, and its size is read off rather than asserted: two signs, three
formulas, three labels. -/
theorem fh_universe_card : (signedUniverse fhStock fhLabels).card = 18 := by decide

/-- **`MintPaysForTimeStable` is false at a concrete nonempty `signedUniverse`**, at every frame
class and every `Tmax`.

The step is `untlPos` firing on the trigger at time `1`; the engine reports a two-arm `.split` and
this is its first arm. On it, all three disjuncts fail on decided numbers:

* disjunct 1 — `knownTimes` goes `{0,1,2}` to `{0,1,2,3}`, so `4 ≤ 3` is false;
* disjunct 2 — `mintPotential` is `8·18 = 144` before **and** after, by `mintPotential_flatSigma`,
  which is a general fact and not a measurement at this configuration;
* disjunct 3 — `selfGuardPotential` is `12` before and `12` after: the step's only new edge is
  `(1, 3)`, time `1`'s future was already non-empty, and no formula of the universe sits at time `3`.

The four frame classes are decided separately, and `Tmax` is universally quantified because
disjunct 1 fails at its first conjunct and disjunct 2 fails by an identity, neither of which
mentions `Tmax`.

Contrast `mintPaysForTime_untlNeg_false`, which refutes the *unrepaired* predicate with a
**self-guarded** vehicle at `σ = id`. That refutation is what the fourth measure component answers.
This one is at a **witness-guarded** vehicle, and what it defeats is the hypothesis
`MintPaysForTimeStable` adds rather than the ledger it adds. -/
theorem mintPaysForTimeStable_signedUniverse_false
    (fc : FormalSystem.ProofSystem.FrameClass) (Tmax : Nat) :
    ¬ MintPaysForTimeStable fc (signedUniverse fhStock fhLabels) Tmax := by
  intro h
  have key := h flatSigma fhBranch fhOrd EventualityTracker.empty fh_runInvariant fh_confined
    (flatSigma_sigmaTimeStable fhBranch)
  cases fc <;>
    [ (rcases key fhSucc (by decide) with ⟨h1, -⟩ | ⟨-, h2⟩ | ⟨-, h3⟩);
      (rcases key fhSucc (by decide) with ⟨h1, -⟩ | ⟨-, h2⟩ | ⟨-, h3⟩);
      (rcases key fhSucc (by decide) with ⟨h1, -⟩ | ⟨-, h2⟩ | ⟨-, h3⟩);
      (rcases key fhSucc (by decide) with ⟨h1, -⟩ | ⟨-, h2⟩ | ⟨-, h3⟩)] <;>
    first
      | exact absurd h1 (by decide)
      | (rw [mintPotential_flatSigma, mintPotential_flatSigma] at h2; omega)
      | exact absurd h3 (by decide)

/-! #### The formula-level repair: `SigmaFixed`, and the residual restated at it

The refutation above localises the defect precisely — the added hypothesis constrains σ's *times*
where disjunct 2 needs it to constrain σ's *formulas* — so the repair is to state the hypothesis at
the coordinate the obligation lives at, and nowhere else. Nothing else about the predicate changes:
the three disjuncts are the same three, in the same order, with the same conjuncts.

**The repair is free at the arm, which is the whole reason it is available.** `rhoSF src tgt` renames
one time and leaves every other formula strictly alone, so `rhoSF_eq_of_ne_src` is the same one-line
fact as `rhoSF_time_eq_of_ne_src` with the conclusion strengthened from "same time" to "same
formula". Every lemma of the σ layer transcribes across that strengthening with no new content:
`sigmaFixed_identifyOriented` is `sigmaTimeStable_identifyOriented`'s proof verbatim,
`sigmaFormulaFixed_identifyOriented` is `sigmaTimeFixed_identifyOriented`'s, and the watermark
lemmas are `sigmaFixesFrom_*`'s. That the strengthening costs nothing at the one step that changes σ
is a fact about `rhoSF`, not a coincidence, and it is why the repair does not have to be paid for
anywhere downstream: **no figure changes** — `mintPathBoundAt`, `mintAwareFuelAt` and `derivedTmaxAt`
are reused unaltered, unlike the fourth component, which cost a coefficient.

**What is bought.** `sigma_formula_hit_of_sigmaFixed` discharges
`mintPotential_lt_of_mint`'s obligation from confinement alone — the trigger witnesses its own hit,
exactly as `sigma_time_hit_of_sigmaTimeStable` does at the time level — and
`mintPotential_lt_of_pick_linear_sigmaFixed` / `..._branching_sigmaFixed` are that discharge
delivered at the pick, which is where disjunct 2 is actually established. So the added hypothesis is
not inert, and the sense in which it is not is a proved implication rather than a measurement.

**What is not bought.** The density coordinate, unchanged. `densityRule` mints a fresh time while
lying outside both `freshLabelRules` and `selfGuardRules`, so no disjunct moves at a `densityRule`
step whatever σ is; it is `denseRules`-gated, so a discharge restricted to the frame classes outside
`.Dense` / `.RTime` is not refuted, and what such a discharge needs is the rule-by-rule census
register entry 19 names. That census is **not** attempted here. See register entry 20. -/

/-- **`rhoSF` is the identity on a formula away from the retired index** — not merely on its time.
The strengthening of `rhoSF_time_eq_of_ne_src` that the whole formula-level layer rests on, and it
is the same one line: `rho` is a conditional on the time, so off the retired index the record is
rebuilt from its own fields. -/
theorem rhoSF_eq_of_ne_src {src tgt : TimeIndex} {sf : SignedFormula}
    (h : sf.label.time ≠ src) : rhoSF src tgt sf = sf := by
  simp [rhoSF, rho, h]

/-- **The formula-level twin of `SigmaTimeStable`**: σ fixes every branch formula outright.

Strictly stronger, and stronger in exactly the respect `mintPotential_lt_of_mint` needs — that
lemma asks for `σ sf = g` on the nose and `SigmaTimeStable` supplies only `(σ sf).label.time =
g.label.time`. `flatSigma_not_sigmaFixed` decides that the gap is real rather than notional. -/
def SigmaFixed (σ : SignedFormula → SignedFormula) (b : Branch) : Prop :=
  ∀ x ∈ b, σ x = x

/-- It implies the time-level form, so nothing stated at `SigmaTimeStable` is lost. -/
theorem sigmaTimeStable_of_sigmaFixed {σ : SignedFormula → SignedFormula} {b : Branch}
    (h : SigmaFixed σ b) : SigmaTimeStable σ b := fun x hx => by rw [h x hx]

/-- **The refuting renaming is excluded by exactly this hypothesis**, which is the statement that
the repair is aimed at the defect rather than past it. `flatSigma` satisfies `SigmaTimeStable` on
every branch and fails `SigmaFixed` on the refuting one. -/
theorem flatSigma_not_sigmaFixed : ¬ SigmaFixed flatSigma fhBranch := by
  intro h
  exact absurd (h fhTrigger (by decide)) (by decide)

/-- **The formula-level twin of `SigmaTimeFixed`.** Quantifies over every formula sitting at a
branch time rather than over branch formulas, which is the extra reach the identification arm's
relabelling needs — the arm puts formulas on the branch that were not there before. -/
def SigmaFormulaFixed (σ : SignedFormula → SignedFormula) (b : Branch) : Prop :=
  ∀ x : SignedFormula, x.label.time ∈ b.knownTimes → σ x = x

theorem sigmaFixed_of_sigmaFormulaFixed {σ : SignedFormula → SignedFormula} {b : Branch}
    (h : SigmaFormulaFixed σ b) : SigmaFixed σ b :=
  fun x hx => h x (mem_knownTimes_of_mem hx)

theorem sigmaTimeFixed_of_sigmaFormulaFixed {σ : SignedFormula → SignedFormula} {b : Branch}
    (h : SigmaFormulaFixed σ b) : SigmaTimeFixed σ b :=
  fun x hx => by rw [h x hx]

/-- **The seed satisfies it for free**, exactly as at the time level: σ is `id` before the first
ordered split. -/
theorem sigmaFormulaFixed_id (b : Branch) : SigmaFormulaFixed id b := fun _ _ => rfl

/-- **The formula-level twin of `SigmaFixesFrom`.** The provenance fact additive steps need: a
freshly minted time is safe as soon as it is at least `n`. -/
def SigmaFixesFormulasFrom (σ : SignedFormula → SignedFormula) (n : TimeIndex) : Prop :=
  ∀ x : SignedFormula, n ≤ x.label.time → σ x = x

theorem sigmaFixesFrom_of_sigmaFixesFormulasFrom {σ : SignedFormula → SignedFormula}
    {n : TimeIndex} (h : SigmaFixesFormulasFrom σ n) : SigmaFixesFrom σ n :=
  fun x hx => by rw [h x hx]

theorem sigmaFixesFormulasFrom_id (n : TimeIndex) : SigmaFixesFormulasFrom id n := fun _ _ => rfl

theorem sigmaFixesFormulasFrom_rhoSF {src tgt n : TimeIndex} (h : src < n) :
    SigmaFixesFormulasFrom (rhoSF src tgt) n :=
  fun _ hx => rhoSF_eq_of_ne_src (Nat.ne_of_gt (Nat.lt_of_lt_of_le h hx))

/-- Post-composing another renaming keeps the watermark, provided the new retired index is below it.
`retired_lt_nextTime_oriented` is what supplies that, exactly as at the time level. -/
theorem sigmaFixesFormulasFrom_comp {σ : SignedFormula → SignedFormula} {src tgt n : TimeIndex}
    (hσ : SigmaFixesFormulasFrom σ n) (h : src < n) :
    SigmaFixesFormulasFrom (fun x => rhoSF src tgt (σ x)) n := by
  intro x hx
  have hfix := hσ x hx
  change rhoSF src tgt (σ x) = x
  rw [hfix]
  exact rhoSF_eq_of_ne_src (Nat.ne_of_gt (Nat.lt_of_lt_of_le h hx))

theorem sigmaFixesFormulasFrom_mono {σ : SignedFormula → SignedFormula} {n m : TimeIndex}
    (h : SigmaFixesFormulasFrom σ n) (hle : n ≤ m) : SigmaFixesFormulasFrom σ m :=
  fun x hx => h x (le_trans hle hx)

/-- **The identification arm preserves the formula-level invariant.** The time-level proof with
`rhoSF_time_eq_of_ne_src` exchanged for `rhoSF_eq_of_ne_src`; the side condition is the same one
`universeClosedAt_identify_at_trigger_oriented` already carries, and no more. -/
theorem sigmaFormulaFixed_identifyOriented {σ : SignedFormula → SignedFormula} {b : Branch}
    {ord : TimeOrdering} {t₁ t₂ : TimeIndex} (hne : t₁ ≠ t₂)
    (hmax : (identifyOrient t₁ t₂).2 ∈ b.knownTimes) (h : SigmaFormulaFixed σ b) :
    SigmaFormulaFixed
      (fun x => rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 (σ x))
      (identifyOriented b ord t₁ t₂).1 := by
  intro x hx
  simp only [identifyOriented] at hx
  have hb : x.label.time ∈ b.knownTimes := knownTimes_identifyTime_subset hmax _ hx
  have hnesrc : x.label.time ≠ (identifyOrient t₁ t₂).1 := by
    intro hc
    exact src_not_mem_knownTimes_identifyTime b _ _ (identifyOrient_ne hne) (hc ▸ hx)
  have hfix := h x hb
  simp only [hfix]
  exact rhoSF_eq_of_ne_src hnesrc

/-- **…and the arm's own renaming is formula-fixed on the state the arm produces.**
`sigmaTimeStable_identifyOriented`'s proof verbatim with the strengthened conclusion — the post-arm
branch carries no formula at the retired index, and away from that index `rhoSF` is the identity on
the formula and not merely on its time. No membership hypothesis on `t₁` or `t₂` is used. -/
theorem sigmaFixed_identifyOriented {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (hne : t₁ ≠ t₂) :
    SigmaFixed (rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2)
      (identifyOriented b ord t₁ t₂).1 := by
  intro x hx
  simp only [identifyOriented] at hx
  refine rhoSF_eq_of_ne_src ?_
  intro hEq
  have hmem : x.label.time
      ∈ (b.identifyTime (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2).knownTimes :=
    mem_knownTimes_of_mem hx
  rw [hEq] at hmem
  exact src_not_mem_knownTimes_identifyTime b _ _ (identifyOrient_ne hne) hmem

theorem sigmaFormulaFixed_grow {σ : SignedFormula → SignedFormula} {b b' : Branch}
    (h : SigmaFormulaFixed σ b)
    (hnew : ∀ t ∈ b'.knownTimes, t ∈ b.knownTimes ∨ ∀ x : SignedFormula, x.label.time = t →
      σ x = x) :
    SigmaFormulaFixed σ b' := by
  intro x hx
  rcases hnew x.label.time hx with hb | hfix
  · exact h x hb
  · exact hfix x rfl

/-- The form the run-level argument uses: a successor's times are the predecessor's plus fresh
ones, and the fresh ones are at least `b.nextTime`, strictly above every index the run has retired
(`retired_lt_nextTime_oriented`, `nextTime_monotone_along_run`). -/
theorem sigmaFormulaFixed_grow_of_fixesFrom {σ : SignedFormula → SignedFormula} {b b' : Branch}
    {n : TimeIndex} (h : SigmaFormulaFixed σ b) (hfix : SigmaFixesFormulasFrom σ n)
    (hnew : ∀ t ∈ b'.knownTimes, t ∈ b.knownTimes ∨ n ≤ t) : SigmaFormulaFixed σ b' := by
  refine sigmaFormulaFixed_grow h (fun t ht => ?_)
  rcases hnew t ht with hb | hle
  · exact Or.inl hb
  · exact Or.inr (fun x hxt => hfix x (hxt ▸ hle))

/-- **The formula-level σ-hit obligation, discharged from confinement.** The trigger witnesses its
own hit, and this time at the coordinate `mintPotential_lt_of_mint` actually asks about. The exact
mirror of `sigma_time_hit_of_sigmaTimeStable`, and the statement whose absence
`mintPaysForTimeStable_signedUniverse_false` exploits. -/
theorem sigma_formula_hit_of_sigmaFixed {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} (hconf : ∀ x ∈ b, x ∈ U)
    (hfix : SigmaFixed σ b) {sf : SignedFormula} (hsf : sf ∈ b) :
    ∃ x ∈ U, σ x = sf :=
  ⟨sf, hconf sf hsf, hfix sf hsf⟩

/-- **The residual restated at the formula-level hypothesis.** `MintPaysForTimeStable`'s body
verbatim, with `SigmaTimeStable σ b` exchanged for `SigmaFixed σ b` and nothing else touched — the
same three disjuncts, in the same order, with the same conjuncts.

**The direction.** `SigmaFixed` is stronger than `SigmaTimeStable`, so requiring it makes the
predicate **weaker**: the implication runs `MintPaysForTimeStable → MintPaysForTimeFixed` and never
the other way, and every theorem restated against it is a **strengthening**. This is the
`universeClosedAt_of_universeClosed` idiom for the fourth time in this file, and saying it in words
is not a formality — register entry 7 exists because a weakening was once mistaken for a repair.

**What the exchange buys, and what it costs.** It buys the formula-level σ-hit
(`sigma_formula_hit_of_sigmaFixed`), which is what disjunct 2 needs at the six rules in
`freshLabelRules ∩ freshTimeRules` and which `SigmaTimeStable` provably does not supply
(`mintPaysForTimeStable_signedUniverse_false`). It costs **nothing**: the added hypothesis is
discharged at the seed by `sigmaFormulaFixed_id` and at the identification arm by
`sigmaFormulaFixed_identifyOriented`, no figure changes, and no caller's hypothesis list changes.

**What it does not touch.** The density coordinate. At a `densityRule` step disjunct 1 fails (the
mint raises `knownTimes`), disjunct 2 cannot move (`densityRule ∉ freshLabelRules`) and disjunct 3
cannot move (`densityRule ∉ selfGuardRules`), for every σ whatsoever — so this predicate is
separately refutable at `.Dense` / `.RTime` by a `densityRule` vehicle, and a discharge at the
other frame classes needs the rule-by-rule census register entries 19 and 20 name. That census is
not attempted here, and `gapPotential` remains implemented nowhere and assumed by nothing. -/
def MintPaysForTimeFixed (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (Tmax : Nat) : Prop :=
  ∀ (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering)
    (tr : EventualityTracker), RunInvariant b ord → (∀ x ∈ b, x ∈ U) → SigmaFixed σ b →
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

/-- **Direction lemma.** The hypothesis is strengthened and nothing is removed, so
`MintPaysForTimeFixed` is **weaker** than `MintPaysForTimeStable` and every theorem restated against
it is a strengthening. The predicate is not landed without this lemma; see register entry 7. -/
theorem mintPaysForTimeFixed_of_mintPaysForTimeStable
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {Tmax : Nat}
    (h : MintPaysForTimeStable fc U Tmax) : MintPaysForTimeFixed fc U Tmax :=
  fun σ b ord tr hri hconf hfix nb hnb =>
    h σ b ord tr hri hconf (sigmaTimeStable_of_sigmaFixed hfix) nb hnb

/-- …and the composite back to the predicate this file started from, so the whole chain of
weakenings `MintPaysForTime → MintPaysForTimeStable → MintPaysForTimeFixed` is one statement. -/
theorem mintPaysForTimeFixed_of_mintPaysForTime {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat} (h : MintPaysForTime fc U Tmax) :
    MintPaysForTimeFixed fc U Tmax :=
  mintPaysForTimeFixed_of_mintPaysForTimeStable (mintPaysForTimeStable_of_mintPaysForTime h)

/-- **The added hypothesis is not inert, at a `.linear` witness-guarded mint.** Confinement plus
`SigmaFixed` deliver `mintPotential_lt_of_pick_linear`'s σ-hit outright, so disjunct 2 holds at the
pick with no further input. This is the statement the refutation above shows is unavailable under
`SigmaTimeStable`. -/
theorem mintPotential_lt_of_pick_linear_sigmaFixed {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {sf₀ : SignedFormula}
    {fs : List SignedFormula} {o : TimeOrdering}
    (hconf : ∀ x ∈ b, x ∈ U) (hfix : SigmaFixed σ b) (hsf₀ : sf₀ ∈ b)
    (hpick : findApplicableRule sf₀ b ord fc = some (r, RuleResult.linear fs, o))
    (hfresh : ruleMintsFreshLabel r = true) :
    mintPotential U σ (fs ++ b) o < mintPotential U σ b ord := by
  obtain ⟨x, hxU, hxσ⟩ := sigma_formula_hit_of_sigmaFixed hconf hfix hsf₀
  exact mintPotential_lt_of_pick_linear hpick hfresh hxU hxσ

/-- **The branching mirror**, on every arm. -/
theorem mintPotential_lt_of_pick_branching_sigmaFixed {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {sf₀ : SignedFormula}
    {bss : List (List SignedFormula)} {o : TimeOrdering}
    (hconf : ∀ x ∈ b, x ∈ U) (hfix : SigmaFixed σ b) (hsf₀ : sf₀ ∈ b)
    (hpick : findApplicableRule sf₀ b ord fc = some (r, RuleResult.branching bss, o))
    (hfresh : ruleMintsFreshLabel r = true) :
    ∀ arm ∈ bss, mintPotential U σ (arm ++ b) o < mintPotential U σ b ord := by
  obtain ⟨x, hxU, hxσ⟩ := sigma_formula_hit_of_sigmaFixed hconf hfix hsf₀
  exact mintPotential_lt_of_pick_branching hpick hfresh hxU hxσ

/-- **The no-leak confirmation at the formula level.** Five conjuncts, and together they are the
claim that the repair costs no consumer a hypothesis.

*The direction*, twice: from the original predicate and from the previous repair, so the chain of
weakenings is explicit and neither link is left to inference. *Discharged, not assumed*: the seed
satisfies the invariant because σ is `id` there, and the arm's own renaming satisfies the
per-formula form on the state the arm produces with **no** membership side condition, which is
strictly better than the time-level layer needed. *Preserved*: the arm carries the invariant
forward under exactly the side condition
`universeClosedAt_identify_at_trigger_oriented` already carries.

*And the cost, stated so it can be checked.* Unlike the fourth measure component, which cost a
coefficient in `mintPathBound` and `derivedTmax`, this repair costs **no figure at all**:
`budgetPotentialAt`, `mintPathBoundAt`, `mintAwareFuelAt` and `derivedTmaxAt` are reused byte for
byte by the chain below. -/
theorem mintPaysForTimeFixed_no_leak {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat} :
    (MintPaysForTime fc U Tmax → MintPaysForTimeFixed fc U Tmax) ∧
      (MintPaysForTimeStable fc U Tmax → MintPaysForTimeFixed fc U Tmax) ∧
      (∀ b : Branch, SigmaFormulaFixed id b) ∧
      (∀ (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex), t₁ ≠ t₂ →
        SigmaFixed (rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2)
          (identifyOriented b ord t₁ t₂).1) ∧
      (∀ (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering)
          (t₁ t₂ : TimeIndex), t₁ ≠ t₂ → (identifyOrient t₁ t₂).2 ∈ b.knownTimes →
        SigmaFormulaFixed σ b →
        SigmaFormulaFixed
          (fun x => rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 (σ x))
          (identifyOriented b ord t₁ t₂).1) :=
  ⟨mintPaysForTimeFixed_of_mintPaysForTime, mintPaysForTimeFixed_of_mintPaysForTimeStable,
   sigmaFormulaFixed_id, fun _ _ _ _ hne => sigmaFixed_identifyOriented hne,
   fun _ _ _ _ _ hne hmax h => sigmaFormulaFixed_identifyOriented hne hmax h⟩

/-- **The carried state at the formula-level σ clause.** -/
def BudgetStateFixed (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Prop :=
  RunInvariant b ord ∧ (∀ x ∈ b, x ∈ U) ∧
    mintTimeBudget U σ b ord + selfGuardPotential U σ ord ≤ Tmax ∧
    SigmaFormulaFixed σ b ∧ SigmaFixesFormulasFrom σ b.nextTime

/-- The formula-level state implies the time-level one. -/
theorem budgetStateAt_of_budgetStateFixed {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    (h : BudgetStateFixed U Tmax σ b ord) : BudgetStateAt U Tmax σ b ord :=
  ⟨h.1, h.2.1, h.2.2.1, sigmaTimeFixed_of_sigmaFormulaFixed h.2.2.2.1,
    sigmaFixesFrom_of_sigmaFixesFormulasFrom h.2.2.2.2⟩

/-- **The measure drops at every arm of an ordered split, at the formula-level state.**
`budgetPotentialAt_step_splitOrdered` with the two σ clauses read at the formula level. The
measure arithmetic is byte-identical — no figure and no weight changes — and the only edits are
`sigmaFormulaFixed_identifyOriented` and `sigmaFixesFormulasFrom_comp` in place of their time-level
originals at arm 3. No residual is consumed here: an ordered split does not mint. -/
theorem budgetPotentialAt_step_splitOrdered_fixed {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {bs : List (Branch × TimeOrdering)}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosedAt fc U) (hst : BudgetStateFixed U Tmax σ b ord)
    (hres : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, ∃ σ' : SignedFormula → SignedFormula, BudgetStateFixed U Tmax σ' p.1 p.2 ∧
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
    have hfix' : SigmaFormulaFixed (fun x => rhoSF s u (σ x)) (b.identifyTime s u) :=
      sigmaFormulaFixed_identifyOriented (ord := ord) (Ne.symm hne21) hmaxk hfix
    have hnextle : b.nextTime ≤ (b.identifyTime s u).nextTime :=
      nextTime_le_identifyTime_oriented b ord t₁ t₂
    have hfrom' : SigmaFixesFormulasFrom (fun x => rhoSF s u (σ x)) (b.identifyTime s u).nextTime :=
      sigmaFixesFormulasFrom_comp (sigmaFixesFormulasFrom_mono hfrom hnextle)
        (retired_lt_nextTime_oriented (b := b) ord hk1 hk2)
    refine ⟨fun x => rhoSF s u (σ x), ⟨hinvp, hIU, by omega, hfix', hfrom'⟩, ?_⟩
    simp only [budgetPotentialAt, budgetPotential, extensionAllowance]
    omega

/-- **The measure drops at `.extended` and at every arm of a `.split`, at the formula-level
state.** `budgetPotentialAt_step_unordered` re-proved against `MintPaysForTimeFixed`. The three
disjunct cases are byte-identical; the edits are confined to the σ layer — `hstab` is now
`sigmaFixed_of_sigmaFormulaFixed`, and the successor's two clauses come from
`sigmaFormulaFixed_grow_of_fixesFrom` and `sigmaFixesFormulasFrom_mono`, on the same two supplies
(`unorderedSuccessor_time_dichotomy` and `nextTime_monotone_along_run`) the time-level proof uses.

That the transcription is this mechanical is the content of the repair's cost claim: strengthening
the σ hypothesis from times to formulas is free at every step, because `rhoSF` is the identity on
formulas away from the one index it retires. -/
theorem budgetPotentialAt_step_unordered_fixed {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosedAt fc U) (hmint : MintPaysForTimeFixed fc U Tmax)
    (hst : BudgetStateFixed U Tmax σ b ord)
    (hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1)
    (hgrow : b.toFinset.card < nb.toFinset.card) :
    BudgetStateFixed U Tmax σ nb (expandOnceUnblocked b ord fc tr).2 ∧
      budgetPotentialAt U Tmax σ nb (expandOnceUnblocked b ord fc tr).2
        < budgetPotentialAt U Tmax σ b ord := by
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

/-- **The per-step bundle at the formula-level state.** -/
theorem stepDecreases_budgetPotentialAt_fixed {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax D β : Nat} (hβ : 3 ≤ β)
    (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeFixed fc U Tmax) :
    StepDecreases fc (BudgetStateFixed U Tmax) (budgetPotentialAt U Tmax) D β := by
  intro σ b ord tr hst
  refine ⟨?_, ?_, ?_⟩
  · intro nb hres
    have hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      rw [hres]; simp [unorderedSuccessorBranches]
    exact ⟨σ, budgetPotentialAt_step_unordered_fixed hUcl hmint hst hmem
      (expandOnceUnblocked_card_lt hres)⟩
  · intro bs hres
    have hmem : ∀ nb ∈ bs,
        nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      intro nb hnb; rw [hres]; simpa [unorderedSuccessorBranches] using hnb
    refine ⟨le_trans (expandOnceUnblocked_split_arity_le hres) hβ, ?_, ?_⟩
    · intro nb hnb
      exact (hD b ord tr hst.2.1).1 nb (hmem nb hnb)
    · intro nb hnb
      exact ⟨σ, budgetPotentialAt_step_unordered_fixed hUcl hmint hst (hmem nb hnb)
        (expandOnceUnblocked_split_card_lt hres hnb)⟩
  · intro bs hres
    have harity : bs.length ≤ β := by
      obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hres
      simpa using hβ
    exact ⟨harity, (hD b ord tr hst.2.1).2 bs hres,
      budgetPotentialAt_step_splitOrdered_fixed hUcl hst hres⟩

/-- The measure sits under the same path bound: the repair changes no figure. -/
theorem budgetPotentialAt_lt_mintPathBoundAt_fixed {U : Finset SignedFormula}
    {Tmax mintBudget : Nat} {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hst : BudgetStateFixed U Tmax σ b ord) (hmb : 8 * U.card ≤ mintBudget) :
    budgetPotentialAt U Tmax σ b ord < mintPathBoundAt U.card Tmax mintBudget :=
  budgetPotentialAt_lt_mintPathBoundAt (budgetStateAt_of_budgetStateFixed hst) hmb

/-- `BudgetedTotalitySelfGuarded` at the formula-level state: identical figures throughout. -/
def BudgetedTotalityFixed (fc : FormalSystem.ProofSystem.FrameClass)
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

theorem expandBranchWithFuel_isSome_of_budget_fixed
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax D β : Nat}
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeFixed fc U Tmax) (harm : ArmSettlement fc) :
    BudgetedTotalityFixed fc U mintBudget Tmax D β := by
  intro b ord tr applied maxBranches branchesUsed hbU hinv hmb hT hbud
  have hst : BudgetStateFixed U Tmax id b ord := by
    refine ⟨hinv, hbU, ?_, sigmaFormulaFixed_id b, sigmaFixesFormulasFrom_id _⟩
    have h8 := mintPotential_le_eight_mul U id b ord
    have h2 := selfGuardPotential_le_two_mul U id ord
    simp only [mintTimeBudget]
    omega
  exact expandBranchWithFuel_isSome_of_measure (by omega)
    (stepDecreases_budgetPotentialAt_fixed hβ hUcl hD hmint)
    harm (mintPathBoundAt U.card Tmax mintBudget) id _ b ord tr applied maxBranches branchesUsed
    hst (budgetPotentialAt_lt_mintPathBoundAt_fixed hst (by omega)) (Nat.le_refl _) hbud

/-- **THE TERMINUS, at the formula-level repaired predicate.** -/
theorem buildTableauAt_isSome_of_budget_fixed
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax D β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeFixed fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt U.card Tmax mintBudget D β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuelAt U.card Tmax mintBudget D β) fc maxBranches).isSome
      = true := by
  refine buildTableauAt_isSome_of_settles hpb ?_
  exact expandBranchWithFuel_isSome_of_budget_fixed hβ hUcl hD hmint
    (armSettlement_of_postBlockingSettles hpb)
    (seedBranch phi) TimeOrdering.empty EventualityTracker.empty {} maxBranches 0
    hseed (runInvariant_initial _) hmb hT (by omega)

theorem buildTableauAt_isSome_at_seed_fixed
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {D β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeFixed fc U
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
  buildTableauAt_isSome_of_budget_fixed phi _ hβ hUcl hD hmint hpb hseed (Nat.le_refl _)
    (derivedTmaxAt_spec (seedBranch phi) U) (Nat.le_refl _)

theorem buildTableauAt_isSome_of_lengthBudget_fixed
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax L β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTimeFixed fc U Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β
      ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β) fc
        maxBranches).isSome = true :=
  buildTableauAt_isSome_of_budget_fixed phi maxBranches hβ hUcl
    (difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint hpb hseed hmb hT hbud

theorem buildTableauAt_isSome_at_seed_lengthBudget_fixed
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {L β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTimeFixed fc U
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
  buildTableauAt_isSome_at_seed_fixed phi hβ hUcl
    (difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint hpb hseed

/-- **Seed-level terminus 1, at the formula-level repaired predicate.** -/
theorem buildTableauAt_isSome_of_lengthBudget_signedUniverse_fixed
    {fc : FormalSystem.ProofSystem.FrameClass}
    {C : Finset Formula} {L : Finset Label} {mintBudget Tmax L' β : Nat}
    (phi : Formula) (maxBranches : Nat) (hβ : 3 ≤ β)
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L)
    (hSL : StepLengthBounded fc (signedUniverse C L) L')
    (hmint : MintPaysForTimeFixed fc (signedUniverse C L) Tmax) (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ signedUniverse C L)
    (hmb : 10 * (signedUniverse C L).card ≤ mintBudget)
    (hT' : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt (signedUniverse C L).card Tmax mintBudget
      (difficultyCeiling (signedUniverse C L) L') β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuelAt (signedUniverse C L).card Tmax mintBudget
        (difficultyCeiling (signedUniverse C L) L') β) fc maxBranches).isSome = true :=
  buildTableauAt_isSome_of_lengthBudget_fixed phi maxBranches hβ
    (universeClosedAt_signedUniverse_of_headroom hC hT hL hlab) hSL hmint hpb hseed hmb hT' hbud

/-- **Seed-level terminus 2, at the formula-level repaired predicate.** -/
theorem buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed
    {fc : FormalSystem.ProofSystem.FrameClass}
    {C : Finset Formula} {L : Finset Label} {L' β : Nat} (phi : Formula) (hβ : 3 ≤ β)
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L)
    (hSL : StepLengthBounded fc (signedUniverse C L) L')
    (hmint : MintPaysForTimeFixed fc (signedUniverse C L)
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
  buildTableauAt_isSome_at_seed_lengthBudget_fixed phi hβ
    (universeClosedAt_signedUniverse_of_headroom hC hT hL hlab) hSL hmint hpb hseed

/-! #### The formula-level predicate discharged, and the boundary at which it stops

The boundary is inherited verbatim from `mintPaysForTimeStable_empty`, and for the same reason:
confinement forces the branch empty, the engine reports `.saturated`, and
`unorderedSuccessorBranches` of a `.saturated` result is `[]`. What is **not** inherited is the
refutation — `flatSigma_not_sigmaFixed` decides that the vehicle above does not reach this
predicate, so the boundary is where the discharge currently stops rather than where it is known to
fail.

**What a nonempty discharge needs, precisely, and what is already available.** For the six rules in
`freshLabelRules ∩ freshTimeRules` disjunct 2 is now supplied at the pick, by
`mintPotential_lt_of_pick_linear_sigmaFixed` and `mintPotential_lt_of_pick_branching_sigmaFixed`.
For the two rules of `selfGuardRules` disjunct 3 is supplied by `selfGuardPotential_lt_of_untlNeg`
and `selfGuardPotential_lt_of_snceNeg`, whose σ-hit comes from `SigmaFixed` a fortiori. For the
twenty-seven rules outside `freshTimeRules`, `applyRule_emitted_time_dichotomy` says the step emits
at no new time, which is disjunct 1's first conjunct, and `expandOnceUnblocked_ord_mono` gives the
second. What is missing is the **engine-level assembly**: threading the pick's rule through
`expandOnceUnblocked`'s three stages so that the case split above is available at the successor,
for every rule at once.

**And the one rule none of that reaches.** `densityRule`. It mints a fresh time and lies outside
both `freshLabelRules` and `selfGuardRules`, so no disjunct moves at a `densityRule` step for any σ
whatsoever — the assembly above therefore delivers a discharge only at frame classes where
`denseRules` cannot fire, and the intended second component `gapPotential` (indexed by `U ×ˢ U`,
`denseRules`-gated) remains implemented nowhere and assumed by nothing. Neither the assembly nor
`gapPotential` is attempted here; both are stated as named next steps. See register entry 20.

**Where that boundary has since moved.** Section D3 discharges the predicate — and its unrepaired
original — at every universe of `untl`/`snce`-free formulas, hence at a nonempty
`signedUniverse C L`, at every frame class. Neither the assembly nor `gapPotential` is needed
there, because both are obligations on a time mint and no rule of `freshTimeRules` is applicable to
such a formula: every one of the nine is gated on a shape carrying an `untl` or `snce` node, and
`densityRule` is excluded by that gate before its `Dense ≤ fc` gate is consulted. So what the two
named next steps actually gate is the discharge at a universe carrying a **temporal** operator. -/

/-- **The satisfiability boundary, at the formula-level predicate.** -/
theorem mintPaysForTimeFixed_empty (fc : FormalSystem.ProofSystem.FrameClass) (Tmax : Nat) :
    MintPaysForTimeFixed fc ∅ Tmax :=
  mintPaysForTimeFixed_of_mintPaysForTimeStable (mintPaysForTimeStable_empty fc Tmax)

/-- **The formula-level predicate, discharged at a concrete `signedUniverse C L`**, at every frame
class and every `Tmax`. The instantiation the seed-level termini above consume, at the same
boundary `mintPaysForTime_empty` and `mintPaysForTimeStable_signedUniverse_empty` record.

Superseded on the `untl`/`snce`-free fragment by
`mintPaysForTimeFixed_signedUniverse_untlSnceFree`, which drops the `L = ∅` restriction entirely;
retained because it is the boundary statement of the empty-universe series and because it holds for
every `C` whatsoever, temporal formulas included. -/
theorem mintPaysForTimeFixed_signedUniverse_empty
    (fc : FormalSystem.ProofSystem.FrameClass) (C : Finset Formula) (Tmax : Nat) :
    MintPaysForTimeFixed fc (signedUniverse C (∅ : Finset Label)) Tmax :=
  mintPaysForTimeFixed_of_mintPaysForTimeStable
    (mintPaysForTimeStable_signedUniverse_empty fc C Tmax)

end FormalSystem.Metalogic.Decidability

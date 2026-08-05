/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.TimeTypeBound
import FormalSystem.Metalogic.Decidability.Saturation

/-!
# T3 — Justified Fuel

T1 (`SubformulaProperty.lean`) fixes the formula stock; T2 (`TimeTypeBound.lean`) bounds the
number of distinguishable times against it. T3 turns those two into a fuel figure at which
`buildTableau` cannot exhaust, so downstream phases only ever see genuinely saturated branches
rather than fuel-starved ones.

## The progress measure, and why it is set growth rather than length growth

`expandOnceUnblocked_adds_new` (landed in Phase 2.5) says an extending step is non-destructive
and adds at least one formula the branch did not carry: `b ⊆ nb ∧ ∃ g ∈ nb, g ∉ b`. Its weaker
sibling `expandOnceUnblocked_length_lt` says the *list* gets longer, and that is deliberately not
what this file consumes. The engine builds `nb = fs ++ b`, and `fs` may repeat formulas already
present, so `List.length` grows without ever approaching a ceiling. What has a ceiling is the
branch **as a set**: `Branch.toFinset` is strictly monotone along an extending step, so a run is
no longer than the finite universe the branch lives in.

`expandOnceUnblocked_card_lt` below is that observation, and it is the step T3's induction turns
into a bound. The universe it runs against has two dimensions:

* **formulas** — bounded by T1: every branch formula stays in a `TableauClosed` stock `C`;
* **labels** — *not* bounded by T1, because witness rules mint fresh times. This is exactly what
  blocking is for, and it is why T2 is a prerequisite rather than a convenience:
  `blocking_fires_of_card_lt` says a chain of more than `2 ^ (2 * |C|)` times cannot be extended,
  so the label dimension is bounded by the same T2 figure.

## Status

Landed: the progress measure, the fuel figure, the branch invariant (`BranchStock`) and its
one-step preservation (`expandOnceUnblocked_extended_stock` — T1 iterated), the signed-formula
universe and its cardinality, and the step bound `chain_le_stock`: **an unbranched run out of a
branch the stock confines takes at most `2 * |C| * |L|` steps.** The formula dimension is fully
discharged there; the label dimension enters as a hypothesis. `chain_le_soundFuel'` puts that
bound at the T2 label figure and lands on `soundFuel'` itself, so the fuel figure this file
defines is earned rather than merely stated — in the unbranched dimension.

**Also landed (the label dimension and the corrected 4.3c).** `chain_le_own_labels` discharges
`chain_le_stock`'s label hypothesis by taking `L` to be the run's own label set, which relocates
the whole obligation to a cardinality; `Branch.card_labelFinset_le` then splits that cardinality
into the two dimensions a `Label` has. `TimeChain` is the run-level chain invariant,
`timeFinset_card_le_of_not_blocked` is T2 contraposed into the direction the fuel argument
consumes, and `timeChain_of_linearity_saturated` establishes the invariant from `timeLinearity`'s
silence — the rule fires exactly while an incomparable pair remains, so its exhaustion *is* the
chain condition. On the 4.3c side, `expandBranchWithFuel_isSome_of_noSplit` proves totality with
the branch budget quantified, ruling out all three sources of `none`.

**Also landed (the general fuel figure, §4.3e).** `soundFuel'` is the **single-world**
(label-count) figure and is frozen as such; `worldFuel' φ s = (s + soundFuel' φ) * soundFuel' φ`
is the general one, and `worldFuel'_eq` shows it is `chain_le_worlds_bounded`'s right-hand side
*exactly*, by associativity and commutativity alone. `chain_le_worldFuel'` restates the chain
bound at that name and `expandBranchWithFuel_isSome_at_worldFuel'` instantiates totality there.
The two figures are a *squaring* apart, not a constant, which is why they are two names.
Three obligations survive and are named in the statements rather than hidden inside the figure:
`WorldWitness` (an invariant, not a theorem), `NoSplit` (the branching arms), and `maxBranches`
(quantified — `buildTableau_isSome` at the engine default is false at any fuel).

**Also landed (the closure duality).** `orderDual_holds` proves `OrderDual` for *every*
`TimeOrdering`, so `timeChain_of_linearity_saturated` and `chain_le_worlds_of_linearity_saturated`
no longer carry it as a hypothesis. The route is `open private` on
`reachableForward`/`reachableBackward` — pure consumption, no engine edit — plus a path
characterisation of the shared breadth-first shape (`bfsClosure`), whose completeness half needs
the `BfsInv` visited-set invariant and a joint induction.

Outstanding, and deliberately not claimed anywhere below:

1. **The branching arms.** Everything here covers `.extended` steps and the `NoSplit` invariant.
   `expandBranchWithFuel`'s `.split` / `.splitOrdered` arms fold over sub-branches and can report
   `none` through `resolveOpenArm` (`Saturation.lean:661-664, :686-689`), which is a distinct
   obligation from the step bound and from the budget guard.
2. **`buildTableau_isSome` is false as an unconditional statement**, and this is a defect of the
   *statement*, not of the engine. `buildTableau` calls `expandBranchWithFuel` at the default
   `maxBranches := 50000` and returns `none` the moment that counter is hit, no matter how much
   fuel it was given; and its own last arm returns `none` when the branch is still unsaturated
   after the post-blocking pass. The corrected statement, proved below, quantifies over the branch
   budget instead. A `buildTableau`-level corollary needs a caller willing to fix `maxBranches`,
   which the current signature's default does not permit without an engine edit.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/- `futureOf`/`pastOf` are breadth-first searches over `reachableForward`/`reachableBackward`,
and both helpers are `private` to `SignedFormula.lean`. Proving the two closures dual needs to
induct on them, so they are imported by `open private` — pure consumption, no engine edit, no
re-proof, and the same idiom this repository already uses in
`Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`. -/
open private reachableForward reachableBackward from
  FormalSystem.Metalogic.Decidability.SignedFormula

/-! ## The progress measure in cardinality form -/

/--
**T3's step.** An extending expansion strictly grows the branch as a set.

This is `expandOnceUnblocked_adds_new` in the form an induction on a finite universe can consume:
a strictly increasing `Finset` cardinality bounded above by `|U|` admits at most `|U|` steps,
whereas the list-length form admits arbitrarily many.
-/
theorem expandOnceUnblocked_card_lt {b nb : Branch} {ord : TimeOrdering}
    {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    b.toFinset.card < nb.toFinset.card := by
  obtain ⟨hsub, g, hg, hgb⟩ := expandOnceUnblocked_adds_new h
  refine Finset.card_lt_card ⟨?_, ?_⟩
  · intro x hx
    exact List.mem_toFinset.mpr (hsub (List.mem_toFinset.mp hx))
  · intro hcon
    exact hgb (List.mem_toFinset.mp (hcon (List.mem_toFinset.mpr hg)))

/--
The step count out of `b` inside a universe `U` is bounded by `|U| - |b|`.

Stated as the single inequality the induction needs: an extending step both grows the branch and
keeps it inside `U`, so its cardinality is squeezed.
-/
theorem card_le_of_subset_universe {nb : Branch} {U : Finset SignedFormula}
    (hU : ∀ x ∈ nb, x ∈ U) : nb.toFinset.card ≤ U.card :=
  Finset.card_le_card (fun x hx => hU x (List.mem_toFinset.mp hx))

/-! ## The fuel figure -/

/--
The uncapped fuel figure, tied to the T2 bound.

`soundFuel` (`Saturation.lean`) is the *runtime* default and is deliberately capped at `100000`,
because blocking fires far earlier in practice and an uncapped exponential would make `#eval`
rows unusable. That cap is exactly what stops it from being a justified bound: a quadratic
constant cannot cover an exponential step count. `soundFuel'` removes the cap and multiplies the
two dimensions the module docstring names — at most `2 * n` signed formulas per time, and at most
`2 ^ (2 * n)` distinguishable times, with `n = |subformulaClosure φ|`.

The figure is *stated* here; the theorem that expansion cannot exhaust it
(`buildTableau_isSome`) is the remaining T3 obligation and is not claimed by this definition.

**This is the single-world (label-count) figure, and that is not a defect of the proof but the
content of the name.** `chain_le_soundFuel'` earns it exactly — with no slack — under a hypothesis
`hL` on the *label* count, and a label is a world *and* a time, so `hL` is reachable from T2 only
while the run stays in one world. For the general case, where `boxNeg`/`diamondPos` have minted
worlds, the figure is `worldFuel'` (this file, §4.3e), which is `soundFuel' φ * (|S| + soundFuel' φ)`
— to a `+1` at the engine's singleton seed, the *square* of this one. `soundFuel'` is kept because
it remains the true and quadratically-exponentially better bound whenever the world count is one,
which for a modal-operator-free `φ` it always is.
-/
def soundFuel' (φ : Formula) : Nat :=
  let n := (FormalSystem.Syntax.subformulaClosure φ).card
  2 * n * 2 ^ (2 * n)

/--
The uncapped figure dominates the capped runtime default, so keeping `soundFuel` as the `#eval`
default (plan constraint 11) never runs the engine *past* the justified bound — it only ever
stops earlier.
-/
theorem soundFuel_le_soundFuel' (φ : Formula) : soundFuel φ ≤ soundFuel' φ := by
  set n := (FormalSystem.Syntax.subformulaClosure φ).card with hn
  have hp : 2 ^ n ≤ 2 ^ (2 * n) := Nat.pow_le_pow_right (by omega) (by omega)
  have hmul : n * 2 ^ n ≤ 2 * n * 2 ^ (2 * n) :=
    le_trans (Nat.mul_le_mul_left n hp) (Nat.mul_le_mul_right _ (by omega))
  simpa [soundFuel, soundFuel', ← hn] using le_trans (min_le_left _ 100000) hmul

/-! ## The branch invariant

T1 is a statement about **one** rule firing at **one** formula. The fuel loop needs it to survive
iteration, and that is not automatic: `applyRule_subformula_closed` takes `TrichClosed C b` as a
hypothesis about the branch it fires on, so an induction along the loop has to re-establish that
hypothesis at every step. `BranchStock` below is the invariant that does it.
-/

/--
`orderTrichotomy`'s obligation, discharged once at the level of the stock.

`TrichClosed C b` (`SubformulaProperty.lean`) is branch-relative on purpose: as a condition on `C`
alone it re-triggers on its own second disjunct (`F(x ∧ y)` obliges `F(x ∧ F y)`, which is again of
the form `F(x ∧ y′)`), so no finite `C` satisfies it non-vacuously. That is exactly why it is not a
`TableauClosed` field.

`TrichStock` is that rejected condition, stated here **as a hypothesis rather than as a field**,
and the distinction is what keeps it honest. Nothing in this file claims it holds of every stock —
it demonstrably does not. What it does is isolate the residual obligation into a single decidable
side condition on `C`, satisfied outright whenever `C` contains no formula of the shape
`F(A ∧ B)`, which is the case for every stock produced by `closureIter` from a `φ` that does not
itself mention one. See the note on `expandOnceUnblocked_extended_stock` for what a general
argument would have to supply instead.
-/
def TrichStock (C : Finset Formula) : Prop :=
  ∀ x y : Formula,
    (Formula.someFuture (Formula.and x y) ∈ C
      ∨ Formula.someFuture (Formula.and x y.someFuture) ∈ C
      ∨ Formula.someFuture (Formula.and x.someFuture y) ∈ C) →
    Formula.someFuture (Formula.and x y) ∈ C
      ∧ Formula.someFuture (Formula.and x y.someFuture) ∈ C
      ∧ Formula.someFuture (Formula.and x.someFuture y) ∈ C

/-- A stock-level trichotomy condition gives the branch-level one for free, on any branch the
stock confines. This is the only route by which `TrichClosed` is ever established below. -/
theorem trichClosed_of_trichStock {C : Finset Formula} {b : Branch}
    (hT : TrichStock C) (hb : ∀ x ∈ b, x.formula ∈ C) : TrichClosed C b := by
  intro x y l0 hany
  refine hT x y ?_
  rcases hany with h | h | h
  · exact Or.inl (by simpa [SignedFormula.neg] using hb _ (mem_of_branch_contains h))
  · exact Or.inr (Or.inl (by simpa [SignedFormula.neg] using hb _ (mem_of_branch_contains h)))
  · exact Or.inr (Or.inr (by simpa [SignedFormula.neg] using hb _ (mem_of_branch_contains h)))

/--
The fuel loop's branch invariant: every formula on the branch lies in the stock, and the
trichotomy rule's branch-side guard is covered by the stock.

Both fields are consumed by `applyRule_subformula_closed`, and both are re-established by
`expandOnceUnblocked_extended_stock`.
-/
structure BranchStock (C : Finset Formula) (b : Branch) : Prop where
  /-- Formula confinement — T1's conclusion, and its `hb` hypothesis. -/
  mem : ∀ x ∈ b, x.formula ∈ C
  /-- `orderTrichotomy`'s branch-side guard. -/
  trich : TrichClosed C b

/-! ## Reading the pick

`expandOnceUnblocked` picks a rule through one of three stages and then appends that rule's
result to the branch. T1 speaks about `applyRule`, so the pick has to be turned back into an
`applyRule` equation before T1 applies. Each stage gets one extraction lemma; they are separate
because the three stages have different guard structure (only the ordinary stage has the
`isApplicable` / fresh-label / `branch.contains` guards).
-/

/-- The ordinary-rule stage reports the rule's own result. -/
theorem findApplicableRule_applyRule_eq
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    (applyRule r sf b ord).1 = res := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  repeat' split at hr
  all_goals simp_all

/-- The seriality stage reports the rule's own result. -/
theorem findApplicableSerialRule_applyRule_eq
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableSerialRule sf b ord = some (r, res, o)) :
    (applyRule r sf b ord).1 = res := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  -- `cases` on the result rather than `split at h`: the scrutinee sits under a `Prod.fst`
  -- projection introduced by the `let`-destructuring, which `split` does not reach (the same
  -- obstacle the `ProgressLemmas` tactic note in `Tableau.lean` records).
  cases hres : (applyRule TableauRule.serialityRule sf b ord).1 <;> rw [hres] at h
  case notApplicable => simp at h
  all_goals
    simp only [Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, h2⟩ := h
    exact hres.trans h2.1

/-- The linearity stage reports the rule's own result. -/
theorem findApplicableLinearityRule_applyRule_eq
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableLinearityRule sf b ord = some (r, res, o)) :
    (applyRule r sf b ord).1 = res := by
  unfold findApplicableLinearityRule linearityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  cases hres : (applyRule TableauRule.timeLinearity sf b ord).1 <;> rw [hres] at h
  case notApplicable => simp at h
  all_goals
    simp only [Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, h2⟩ := h
    exact hres.trans h2.1

/-- T1, applied to a pick: whatever the picked rule appends stays inside the stock. -/
theorem pick_result_mem {C : Finset Formula} {b : Branch} {ord : TimeOrdering}
    {sf : SignedFormula} {r : TableauRule} {fs : List SignedFormula}
    (hC : TableauClosed C) (hb : ∀ x ∈ b, x.formula ∈ C) (htrich : TrichClosed C b)
    (hsfb : sf ∈ b)
    (h : (applyRule r sf b ord).1 = RuleResult.linear fs
       ∨ (applyRule r sf b ord).1 = RuleResult.persistent fs) :
    ∀ g ∈ fs, g.formula ∈ C := by
  have hT := applyRule_subformula_closed (C := C) (sf := sf) (b := b) (ord := ord)
    hC (hb sf hsfb) hb htrich r
  rcases h with h | h <;> rw [h] at hT <;> simpa using hT

/-! ## One step preserves the invariant -/

/--
**T1, iterated.** An extending step keeps every branch formula inside the stock.

The three-stage case split mirrors `expandOnceUnblocked_pick_ne_nil` exactly, and for the same
reason: a hypothesis about the two-stage `match` as a whole is not something the
`findApplicableRule`-level lemmas can consume, so the stages have to be destructured first.
`rw` rather than `simp` on the stage equations is again load-bearing — `simp` normalises
`List.contains` to `decide (· ∈ ·)`, after which the seriality stage's `find?` equation no longer
matches the form `rcases` produced.
-/
theorem expandOnceUnblocked_extended_mem {C : Finset Formula} {b nb : Branch}
    {ord : TimeOrdering} {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (hC : TableauClosed C) (hb : ∀ x ∈ b, x.formula ∈ C) (htrich : TrichClosed C b)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    ∀ x ∈ nb, x.formula ∈ C := by
  unfold expandOnceUnblocked at h
  obtain ⟨r, fs, o, hp, rfl⟩ := pick_extended h
  have hfs : ∀ g ∈ fs, g.formula ∈ C := by
    rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
    · rw [hpick] at hp
      rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
      · rw [hser] at hp
        rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                                 && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
        · rw [hlin] at hp
          simp only at hp
          rcases hp with hp | hp <;> exact absurd hp (by simp)
        · rw [hlin] at hp
          simp only at hp
          refine pick_result_mem (ord := ord) (r := r) hC hb htrich (List.mem_of_find?_eq_some hlin) ?_
          rcases hp with hp | hp
          · exact Or.inl (findApplicableLinearityRule_applyRule_eq hp)
          · exact Or.inr (findApplicableLinearityRule_applyRule_eq hp)
      · rw [hser] at hp
        simp only at hp
        refine pick_result_mem (ord := ord) (r := r) hC hb htrich (List.mem_of_find?_eq_some hser) ?_
        rcases hp with hp | hp
        · exact Or.inl (findApplicableSerialRule_applyRule_eq hp)
        · exact Or.inr (findApplicableSerialRule_applyRule_eq hp)
    · rw [hpick] at hp
      simp only at hp
      have hmem : sf ∈ b := by
        unfold findUnexpandedUnblockedWith at hpick
        exact List.mem_of_find?_eq_some hpick
      refine pick_result_mem (ord := ord) (r := r) hC hb htrich hmem ?_
      rcases hp with hp | hp
      · exact Or.inl (findApplicableRule_applyRule_eq hp)
      · exact Or.inr (findApplicableRule_applyRule_eq hp)
  intro x hx
  rcases List.mem_append.mp hx with hx | hx
  · exact hfs x hx
  · exact hb x hx

/--
The invariant survives a step.

The `trich` field is re-established from `TrichStock` rather than transported from the previous
branch, and that is the honest reading of the 4.2a decision's deferred cost: `TrichClosed` is
*anti*-monotone in the branch (a longer branch has more chances to satisfy its antecedent), so it
cannot simply be carried forward. `orderTrichotomy` itself is harmless — it emits only positive
disjuncts, so it never adds a branch-side *negated* disjunct — but the other rules are not
constrained that way: `negPos` fired on a branch formula `¬F(A ∧ B)` puts a negated `F(A ∧ B)` on
the branch, and nothing in `TableauClosed` then supplies the other two disjuncts of that triple.
`TrichStock` is what supplies them, and it is a hypothesis for exactly that reason.

A general argument that dispensed with `TrichStock` would have to bound the *negatively signed*
formulas of a run more tightly than `C` does — showing that a negated `F(A ∧ B)` reaches the
branch only for the finitely many `A ∧ B` already in the seed's trichotomy completion. That is
the remaining shape of the obligation, and it is recorded in the plan rather than assumed here.
-/
theorem expandOnceUnblocked_extended_stock {C : Finset Formula} {b nb : Branch}
    {ord : TimeOrdering} {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (hC : TableauClosed C) (hT : TrichStock C) (hb : BranchStock C b)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    BranchStock C nb :=
  let hm := expandOnceUnblocked_extended_mem hC hb.mem hb.trich h
  ⟨hm, trichClosed_of_trichStock hT hm⟩

/-! ## The universe the branch lives in

`card_le_of_subset_universe` takes an arbitrary `U`. This section supplies the `U` the two
dimensions of the module docstring describe — signed formulas over a stock `C` and a label set
`L` — together with its cardinality.
-/

/-- Every signed formula over stock `C` at a label in `L`. -/
def signedUniverse (C : Finset Formula) (L : Finset Label) : Finset SignedFormula :=
  (({Sign.pos, Sign.neg} : Finset Sign) ×ˢ C ×ˢ L).image fun p => ⟨p.1, p.2.1, p.2.2⟩

theorem mem_signedUniverse {C : Finset Formula} {L : Finset Label} {x : SignedFormula}
    (hf : x.formula ∈ C) (hl : x.label ∈ L) : x ∈ signedUniverse C L := by
  simp only [signedUniverse, Finset.mem_image, Finset.mem_product, Finset.mem_insert,
    Finset.mem_singleton]
  refine ⟨(x.sign, x.formula, x.label), ⟨?_, hf, hl⟩, ?_⟩
  · cases x.sign <;> simp
  · cases x; rfl

/-- The signed-formula universe has at most `2 * |C| * |L|` members — the product of the two
dimensions T1 and T2 bound. -/
theorem card_signedUniverse_le (C : Finset Formula) (L : Finset Label) :
    (signedUniverse C L).card ≤ 2 * C.card * L.card := by
  calc (signedUniverse C L).card
      ≤ (({Sign.pos, Sign.neg} : Finset Sign) ×ˢ C ×ˢ L).card := Finset.card_image_le
    _ = ({Sign.pos, Sign.neg} : Finset Sign).card * (C.card * L.card) := by
        rw [Finset.card_product, Finset.card_product]
    _ ≤ 2 * (C.card * L.card) := Nat.mul_le_mul_right _ (by decide)
    _ = 2 * C.card * L.card := (Nat.mul_assoc 2 C.card L.card).symm

/-- A branch confined to stock `C` and label set `L` carries at most `2 * |C| * |L|` distinct
signed formulas. -/
theorem branch_card_le {C : Finset Formula} {L : Finset Label} {b : Branch}
    (hf : ∀ x ∈ b, x.formula ∈ C) (hl : ∀ x ∈ b, x.label ∈ L) :
    b.toFinset.card ≤ 2 * C.card * L.card :=
  le_trans (card_le_of_subset_universe fun x hx => mem_signedUniverse (hf x hx) (hl x hx))
    (card_signedUniverse_le C L)

/-! ## The step bound

The three pieces above compose into the statement T3 exists to make: an unbranched run of the
engine out of a branch the stock confines has at most `2 * |C| * |L|` steps. The formula
dimension is fully discharged — `BranchStock` re-establishes itself at every step. The label
dimension enters as the hypothesis `hl`, which is what `blocking_fires_of_card_lt`
(`TimeTypeBound.lean`) is for; see the module docstring's Status section.
-/

/-- One unbranched engine step, with the parameters existentially quantified: a bound on the
number of steps does not depend on which ordering, frame class or tracker each step ran under. -/
def ExtendStep (b nb : Branch) : Prop :=
  ∃ (ord : TimeOrdering) (fc : ProofSystem.FrameClass) (tr : EventualityTracker),
    (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb

theorem card_lt_of_extendStep {b nb : Branch} (h : ExtendStep b nb) :
    b.toFinset.card < nb.toFinset.card := by
  obtain ⟨_, _, _, h⟩ := h
  exact expandOnceUnblocked_card_lt h

/-- `n` steps grow the branch by at least `n`. -/
theorem chain_card_le (run : Nat → Branch) (n : Nat)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1))) :
    (run 0).toFinset.card + n ≤ (run n).toFinset.card := by
  induction n with
  | zero => simp
  | succ n ih =>
      have h1 := ih fun i hi => hstep i (by omega)
      have h2 := card_lt_of_extendStep (hstep n (by omega))
      omega

/-- The invariant along a whole unbranched run. -/
theorem branchStock_chain {C : Finset Formula} (hC : TableauClosed C) (hT : TrichStock C)
    (run : Nat → Branch) (n : Nat) (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1))) : BranchStock C (run n) := by
  induction n with
  | zero => exact h0
  | succ n ih =>
      have hb := ih fun i hi => hstep i (by omega)
      obtain ⟨_, _, _, hs⟩ := hstep n (by omega)
      exact expandOnceUnblocked_extended_stock hC hT hb hs

/-- **T3's step bound, abstract form.** A run confined to a finite universe is no longer than
that universe. -/
theorem chain_le_card_universe {U : Finset SignedFormula} (run : Nat → Branch) (n : Nat)
    (hU : ∀ x ∈ run n, x ∈ U) (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1))) :
    n ≤ U.card := by
  have h1 := chain_card_le run n hstep
  have h2 := card_le_of_subset_universe hU
  omega

/--
**T3's step bound, in the two dimensions the module docstring names.**

An unbranched run out of a branch the stock `C` confines takes at most `2 * |C| * |L|` steps,
where `L` is any label set the run's last branch stays inside. The formula dimension costs the
caller nothing — `BranchStock` is re-established at every step by `branchStock_chain`, which is
T1 iterated. The label dimension is the caller's `hl`, and supplying it in general is what
`blocking_fires_of_card_lt` does; composing the two is the remaining T3 obligation recorded in
the module docstring.
-/
theorem chain_le_stock {C : Finset Formula} {L : Finset Label}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0)) (hl : ∀ x ∈ run n, x.label ∈ L)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1))) :
    n ≤ 2 * C.card * L.card := by
  have hb := branchStock_chain hC hT run n h0 hstep
  have h1 := chain_card_le run n hstep
  have h2 := branch_card_le (C := C) (L := L) hb.mem hl
  omega

/-! ## The label dimension, part 1: the hypothesis `hl` costs nothing

`chain_le_stock` takes `hl : ∀ x ∈ run n, x.label ∈ L` and `L` is universally quantified, so the
caller is free to take `L` to be the run's *own* label set, at which point `hl` is a triviality.
That is not a dodge — it relocates the whole label obligation to where it actually lives, namely
in the **cardinality** of that set. The section below performs that relocation and then splits
the cardinality into the two independent dimensions a label has: worlds and times.

Doing this first matters, because the two dimensions have completely different arguments. The
world dimension is bounded by the S5 rules' fresh-world discipline; the time dimension is what
blocking (T2) bounds. Keeping them fused inside an opaque `L` hid the fact that only one of the
two is what `blocking_fires_of_card_lt` is about.
-/

/-- The labels the branch actually mentions. -/
def Branch.labelFinset (b : Branch) : Finset Label := (b.map (·.label)).toFinset

/-- The worlds the branch actually mentions, as a `Finset`. -/
def Branch.worldFinset (b : Branch) : Finset WorldIndex := b.knownWorlds.toFinset

/-- The times the branch actually mentions, as a `Finset`. -/
def Branch.timeFinset (b : Branch) : Finset TimeIndex := b.knownTimes.toFinset

theorem Branch.mem_labelFinset {b : Branch} {x : SignedFormula} (h : x ∈ b) :
    x.label ∈ b.labelFinset :=
  List.mem_toFinset.mpr (List.mem_map_of_mem h)

theorem Branch.mem_worldFinset {b : Branch} {x : SignedFormula} (h : x ∈ b) :
    x.label.world ∈ b.worldFinset :=
  List.mem_toFinset.mpr (List.mem_eraseDups.mpr (List.mem_map_of_mem h))

theorem Branch.mem_timeFinset {b : Branch} {x : SignedFormula} (h : x ∈ b) :
    x.label.time ∈ b.timeFinset :=
  List.mem_toFinset.mpr (List.mem_eraseDups.mpr (List.mem_map_of_mem h))

/-- A label is its two components, so the branch's labels inject into worlds × times. -/
theorem Branch.card_labelFinset_le (b : Branch) :
    b.labelFinset.card ≤ b.worldFinset.card * b.timeFinset.card := by
  rw [← Finset.card_product]
  refine Finset.card_le_card_of_injOn (fun l => (l.world, l.time)) ?_ ?_
  · intro l hl
    obtain ⟨x, hx, rfl⟩ := List.mem_map.mp (List.mem_toFinset.mp hl)
    exact Finset.mem_product.mpr ⟨Branch.mem_worldFinset hx, Branch.mem_timeFinset hx⟩
  · intro l₁ _ l₂ _ h
    cases l₁; cases l₂
    simpa [Prod.ext_iff] using h

/--
**The step bound with the label hypothesis discharged.**

`chain_le_stock` at `L := (run n).labelFinset`. Nothing about the bound weakens: what was a
hypothesis about an abstract `L` is now a statement about a set the run determines, and the
residual obligation is a pure cardinality question about that set — which is what the rest of
this file's label work attacks.
-/
theorem chain_le_own_labels {C : Finset Formula}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1))) :
    n ≤ 2 * C.card * (run n).labelFinset.card :=
  chain_le_stock hC hT run n h0 (fun _ hx => Branch.mem_labelFinset hx) hstep

/-- The step bound in the two dimensions a label has. The time factor is what T2 bounds; the
world factor is separate and is bounded by the S5 fresh-world discipline. -/
theorem chain_le_worlds_times {C : Finset Formula}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1))) :
    n ≤ 2 * C.card * ((run n).worldFinset.card * (run n).timeFinset.card) :=
  le_trans (chain_le_own_labels hC hT run n h0 hstep)
    (Nat.mul_le_mul_left _ (Branch.card_labelFinset_le _))

/-! ## The label dimension, part 2: the time factor and the chain invariant

`chain_le_worlds_times` leaves two cardinalities. This section discharges the **time** one, which
is the factor T2 was built to bound, and does so in the direction the fuel argument needs: not
"a long chain makes blocking fire" but its contrapositive, "a branch on which nothing is blocked
has few times".

`blocking_fires_of_card_lt` needs its times *comparable* — pigeonhole alone produces two times of
equal type, and two incomparable times of equal type block nothing. `TimeChain` below is that
comparability, stated over exactly the set the bound is about, and it is the run-level invariant
the module docstring's residual 1 names.
-/

/--
**The run-level chain invariant.** Any two distinct times the branch mentions are comparable in
the transitive ancestor order.

This is precisely `blocking_fires_of_card_lt`'s `hchain` at `ts := b.timeFinset`, stated as a
predicate so that it can be established once (from linearity saturation, below) and consumed
wherever the time bound is needed.
-/
def TimeChain (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ t₁ ∈ b.knownTimes, ∀ t₂ ∈ b.knownTimes, t₁ ≠ t₂ →
    t₁ ∈ ancestorTimes ord t₂ ∨ t₂ ∈ ancestorTimes ord t₁

/--
**T2, contraposed — the time factor.** On a branch confined to `C` whose times form a chain and
on which `findBlockedTime` reports nothing, there are at most `2 ^ (2 * |C|)` times.

This is the direction the fuel argument consumes. `blocking_fires_of_card_lt` says a long chain
*forces* blocking; a run that is still taking unblocked steps has therefore not yet accumulated
one, and the count is bounded.
-/
theorem timeFinset_card_le_of_not_blocked {C : Finset Formula} {b : Branch} {ord : TimeOrdering}
    {tracker : EventualityTracker}
    (hb : ∀ x ∈ b, x.formula ∈ C) (hchain : TimeChain b ord)
    (hev : ∀ t₁ ∈ b.knownTimes, ∀ t₂ ∈ b.knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime b ord tracker = none) :
    b.timeFinset.card ≤ 2 ^ (2 * C.card) := by
  by_contra hcon
  have hfire := blocking_fires_of_card_lt (C := C) (b := b) (ord := ord) (tracker := tracker)
    hb b.timeFinset (fun _ ht => List.mem_toFinset.mp ht)
    (fun t₁ h₁ t₂ h₂ hne =>
      hchain t₁ (List.mem_toFinset.mp h₁) t₂ (List.mem_toFinset.mp h₂) hne)
    (fun t₁ h₁ t₂ h₂ => hev t₁ (List.mem_toFinset.mp h₁) t₂ (List.mem_toFinset.mp h₂))
    (by omega)
  rw [hnb] at hfire
  exact absurd hfire (by simp)

/-- The empty-tracker specialisation: with nothing pending the eventuality guard is vacuous. -/
theorem timeFinset_card_le_of_not_blocked_empty {C : Finset Formula} {b : Branch}
    {ord : TimeOrdering}
    (hb : ∀ x ∈ b, x.formula ∈ C) (hchain : TimeChain b ord)
    (hnb : findBlockedTime b ord EventualityTracker.empty = none) :
    b.timeFinset.card ≤ 2 ^ (2 * C.card) :=
  timeFinset_card_le_of_not_blocked hb hchain
    (fun _ _ _ _ => by simp [allEventualitiesFulfilledOrDuplicated,
      EventualityTracker.pendingAtTime, EventualityTracker.empty]) hnb

/--
**The step bound with the time dimension discharged.**

The composition of `chain_le_worlds_times` with the contraposed T2 bound: the only cardinality
left standing is the world count, which is a separate dimension with a separate argument (the S5
rules' fresh-world discipline) and is carried here as `W`.
-/
theorem chain_le_worlds_of_not_blocked {C : Finset Formula} {ord : TimeOrdering}
    {tracker : EventualityTracker} {W : Nat}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hchain : TimeChain (run n) ord)
    (hev : ∀ t₁ ∈ (run n).knownTimes, ∀ t₂ ∈ (run n).knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime (run n) ord tracker = none)
    (hW : (run n).worldFinset.card ≤ W) :
    n ≤ 2 * C.card * (W * 2 ^ (2 * C.card)) := by
  refine le_trans (chain_le_worlds_times hC hT run n h0 hstep) (Nat.mul_le_mul_left _ ?_)
  exact Nat.mul_le_mul hW
    (timeFinset_card_le_of_not_blocked (branchStock_chain hC hT run n h0 hstep).mem hchain hev hnb)

/-! ## The label dimension, part 3: where the chain comes from

`TimeChain` is not an assumption about the world; it is what `timeLinearity` produces. That rule's
trigger is `firstIncomparablePair`, which scans `Branch.knownTimes` for a pair neither of whose
members is in the other's transitive future or past, and the rule is *self-suppressing*: it fires
until no such pair remains. So a branch on which the linearity stage reports nothing has all its
times pairwise comparable — which is `TimeChain` modulo the direction the comparability is
recorded in.
-/

/--
**Linearity saturation gives comparability.** If `timeLinearity` has no applicable instance, then
any two distinct branch times are related by the transitive ordering in one direction or the other.

This is the extraction step; turning the `futureOf` disjunct into the `ancestorTimes` form
`blocking_fires_of_card_lt` wants is `TimeChain`'s remaining obligation, isolated as
`OrderDual` below.
-/
theorem comparable_of_firstIncomparablePair_none {b : Branch} {ord : TimeOrdering}
    (h : firstIncomparablePair b ord = none)
    {t₁ t₂ : TimeIndex} (h₁ : t₁ ∈ b.knownTimes) (h₂ : t₂ ∈ b.knownTimes) (hne : t₂ ≠ t₁) :
    t₂ ∈ ord.futureOf t₁ ∨ t₂ ∈ ord.pastOf t₁ := by
  simp only [firstIncomparablePair] at h
  have hnone := List.findSome?_eq_none_iff.mp h t₁ h₁
  rcases hf : b.knownTimes.find? (fun t => t != t₁ && !(ord.futureOf t₁).contains t
      && !(ord.pastOf t₁).contains t) with _ | t
  · have hg := List.find?_eq_none.mp hf t₂ h₂
    simp only [Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
      List.contains_eq_mem, decide_eq_false_iff_not, not_and, not_not] at hg
    by_cases hfut : t₂ ∈ ord.futureOf t₁
    · exact Or.inl hfut
    · exact Or.inr (hg ⟨hne, hfut⟩)
  · rw [hf] at hnone
    exact absurd hnone (by simp)

/-! ### The breadth-first closures, and their path characterisation

`futureOf` and `pastOf` are the same breadth-first search run against `directFutureOf` and
`directPastOf`. This section factors that shared shape out as `bfsClosure`, characterises it by
paths in both directions, and uses the characterisation to prove the two closures dual.

The soundness half is routine. The awkward half is **completeness**, because the visited set makes
the naive statement false: a BFS whose `visited` was seeded with a node it never expanded can miss
everything downstream of that node. What rules this out is `BfsInv` — every visited node is either
still on the frontier or has already had all its successors recorded — which holds at the `[]`
seed and is preserved by a layer step. Completeness is then a *joint* induction over the frontier
and visited statements, because a path leaving a visited node either steps inside the
already-expanded region (visited case, one edge shorter) or restarts from the frontier (frontier
case, same length), and neither statement is provable without the other.
-/

namespace TimeOrdering

/-- A path of exactly `n` edges in the step relation given by the successor function `f`. -/
def PathN (f : TimeIndex → List TimeIndex) : Nat → TimeIndex → TimeIndex → Prop
  | 0, a, b => a = b
  | n + 1, a, b => ∃ c, c ∈ f a ∧ PathN f n c b

/-- The breadth-first closure shared by `reachableForward` and `reachableBackward`, with the
step relation abstracted. -/
def bfsClosure (f : TimeIndex → List TimeIndex) (frontier visited : List TimeIndex) :
    Nat → List TimeIndex
  | 0 => visited
  | fuel + 1 =>
    let next := (frontier.flatMap f).eraseDups.filter fun t => !visited.contains t
    if next.isEmpty then visited
    else bfsClosure f next (visited ++ next) fuel

theorem reachableForward_eq (ord : TimeOrdering) :
    ∀ (fuel : Nat) (fr vis : List TimeIndex),
      reachableForward ord fr vis fuel = bfsClosure ord.directFutureOf fr vis fuel := by
  intro fuel
  induction fuel with
  | zero => intro fr vis; rfl
  | succ n ih => intro fr vis; simp only [reachableForward, bfsClosure, ih]

theorem reachableBackward_eq (ord : TimeOrdering) :
    ∀ (fuel : Nat) (fr vis : List TimeIndex),
      reachableBackward ord fr vis fuel = bfsClosure ord.directPastOf fr vis fuel := by
  intro fuel
  induction fuel with
  | zero => intro fr vis; rfl
  | succ n ih => intro fr vis; simp only [reachableBackward, bfsClosure, ih]

/-- The next BFS layer: one hop off the frontier, minus what is already visited. -/
def bfsNext (f : TimeIndex → List TimeIndex) (frontier visited : List TimeIndex) :
    List TimeIndex :=
  (frontier.flatMap f).eraseDups.filter fun t => !visited.contains t

theorem mem_bfsNext {f : TimeIndex → List TimeIndex} {fr vis : List TimeIndex} {t : TimeIndex} :
    t ∈ bfsNext f fr vis ↔ (∃ s ∈ fr, t ∈ f s) ∧ t ∉ vis := by
  simp [bfsNext, List.mem_filter, List.mem_flatMap]

theorem bfsClosure_succ (f : TimeIndex → List TimeIndex) (fr vis : List TimeIndex) (fuel : Nat) :
    bfsClosure f fr vis (fuel + 1) =
      if (bfsNext f fr vis).isEmpty then vis
      else bfsClosure f (bfsNext f fr vis) (vis ++ bfsNext f fr vis) fuel := by
  simp only [bfsClosure, bfsNext]
  rfl

/-- Everything already visited survives to the result. -/
theorem mem_bfsClosure_of_mem_visited (f : TimeIndex → List TimeIndex) :
    ∀ (fuel : Nat) (fr vis : List TimeIndex) {t : TimeIndex},
      t ∈ vis → t ∈ bfsClosure f fr vis fuel := by
  intro fuel
  induction fuel with
  | zero => intro fr vis t ht; exact ht
  | succ n ih =>
    intro fr vis t ht
    rw [bfsClosure_succ]
    by_cases hE : (bfsNext f fr vis).isEmpty = true
    · simp [hE, ht]
    · simp only [hE, if_false, Bool.false_eq_true]
      exact ih _ _ (List.mem_append_left _ ht)

/-- **Soundness.** Anything the closure returns is either already visited, or joined to the
frontier by a path of between one and `fuel` edges. The lower bound `1 ≤ n` is what makes the
duality usable: without it, membership could be witnessed by the empty path, which says nothing. -/
theorem bfsClosure_sound (f : TimeIndex → List TimeIndex) :
    ∀ (fuel : Nat) (fr vis : List TimeIndex) {t : TimeIndex},
      t ∈ bfsClosure f fr vis fuel →
        t ∈ vis ∨ ∃ s ∈ fr, ∃ n, 1 ≤ n ∧ n ≤ fuel ∧ PathN f n s t := by
  intro fuel
  induction fuel with
  | zero => intro fr vis t ht; exact Or.inl ht
  | succ n ih =>
    intro fr vis t ht
    rw [bfsClosure_succ] at ht
    by_cases hE : (bfsNext f fr vis).isEmpty = true
    · rw [if_pos hE] at ht; exact Or.inl ht
    · rw [if_neg hE] at ht
      rcases ih _ _ ht with hv | ⟨s', hs', k, hk1, hk2, hpk⟩
      · rcases List.mem_append.mp hv with hv | hv
        · exact Or.inl hv
        · obtain ⟨⟨s, hs, hfs⟩, _⟩ := mem_bfsNext.mp hv
          exact Or.inr ⟨s, hs, 1, le_refl 1, by omega, ⟨t, by simpa [hv] using hfs, rfl⟩⟩
      · obtain ⟨⟨s, hs, hfs⟩, _⟩ := mem_bfsNext.mp hs'
        exact Or.inr ⟨s, hs, k + 1, by omega, by omega, ⟨s', hfs, hpk⟩⟩

/-- The BFS well-formedness invariant: every visited node is either still on the frontier, or has
already had all of its successors recorded. This is exactly what a hand-rolled `visited` set can
violate, and exactly what completeness needs. -/
def BfsInv (f : TimeIndex → List TimeIndex) (fr vis : List TimeIndex) : Prop :=
  ∀ u ∈ vis, u ∈ fr ∨ ∀ v ∈ f u, v ∈ vis

theorem BfsInv.step {f : TimeIndex → List TimeIndex} {fr vis : List TimeIndex}
    (h : BfsInv f fr vis) : BfsInv f (bfsNext f fr vis) (vis ++ bfsNext f fr vis) := by
  intro u hu
  rcases List.mem_append.mp hu with hu | hu
  · rcases h u hu with hf | hall
    · refine Or.inr fun v hv => ?_
      by_cases hvv : v ∈ vis
      · exact List.mem_append_left _ hvv
      · exact List.mem_append_right _ (mem_bfsNext.mpr ⟨⟨u, hf, hv⟩, hvv⟩)
    · exact Or.inr fun v hv => List.mem_append_left _ (hall v hv)
  · exact Or.inl hu

/-- **Completeness**, as the joint induction the visited set forces. The frontier statement and
the visited statement are proved in one induction on path length: the visited statement at length
`m + 1` needs the frontier statement at the *same* length (a visited node still on the frontier
restarts the search), while the frontier statement at `m + 1` only ever needs the visited
statement at `m`. -/
theorem bfsClosure_complete_aux (f : TimeIndex → List TimeIndex) (m : Nat) :
    (∀ (fuel : Nat) (fr vis : List TimeIndex), BfsInv f fr vis →
        ∀ s ∈ fr, ∀ t, PathN f m s t → 1 ≤ m → m ≤ fuel → t ∈ bfsClosure f fr vis fuel)
    ∧ (∀ (fuel : Nat) (fr vis : List TimeIndex), BfsInv f fr vis →
        ∀ s ∈ vis, ∀ t, PathN f m s t → m ≤ fuel → t ∈ bfsClosure f fr vis fuel) := by
  induction m with
  | zero =>
    refine ⟨fun _ _ _ _ _ _ _ _ h1 _ => absurd h1 (by omega), ?_⟩
    intro fuel fr vis _ s hs t hp _
    exact (hp ▸ mem_bfsClosure_of_mem_visited f fuel fr vis hs)
  | succ m ih =>
    have hA : ∀ (fuel : Nat) (fr vis : List TimeIndex), BfsInv f fr vis →
        ∀ s ∈ fr, ∀ t, PathN f (m + 1) s t → 1 ≤ m + 1 → m + 1 ≤ fuel →
          t ∈ bfsClosure f fr vis fuel := by
      intro fuel fr vis hinv s hs t hp _ hle
      obtain ⟨c, hc, hpc⟩ := hp
      cases fuel with
      | zero => omega
      | succ fuel' =>
        by_cases hcv : c ∈ vis
        · exact ih.2 (fuel' + 1) fr vis hinv c hcv t hpc (by omega)
        · have hcn : c ∈ bfsNext f fr vis := mem_bfsNext.mpr ⟨⟨s, hs, hc⟩, hcv⟩
          have hE : ¬ (bfsNext f fr vis).isEmpty = true := by
            simp only [List.isEmpty_iff]
            intro hnil
            simp [hnil] at hcn
          rw [bfsClosure_succ, if_neg hE]
          exact ih.2 fuel' _ _ hinv.step c (List.mem_append_right _ hcn) t hpc (by omega)
    refine ⟨hA, ?_⟩
    intro fuel fr vis hinv s hs t hp hle
    rcases hinv s hs with hsf | hall
    · exact hA fuel fr vis hinv s hsf t hp (by omega) hle
    · obtain ⟨c, hc, hpc⟩ := hp
      exact ih.2 fuel fr vis hinv c (hall c hc) t hpc (by omega)

/-- Completeness at the `[]`-seeded call shape both `futureOf` and `pastOf` use. -/
theorem bfsClosure_complete (f : TimeIndex → List TimeIndex) {s t : TimeIndex} {n fuel : Nat}
    (hp : PathN f n s t) (h1 : 1 ≤ n) (hle : n ≤ fuel) :
    t ∈ bfsClosure f [s] [] fuel :=
  (bfsClosure_complete_aux f n).1 fuel [s] [] (fun _ hu => absurd hu (by simp)) s
    (by simp) t hp h1 hle

/-- Extending a path by one edge at the far end. This is what makes reversal an induction on
length rather than a structural rewrite: `PathN` peels edges from the source, so reversing needs
to attach them at the target. -/
theorem PathN.snoc {f : TimeIndex → List TimeIndex} :
    ∀ {n : Nat} {a b c : TimeIndex}, PathN f n a b → c ∈ f b → PathN f (n + 1) a c := by
  intro n
  induction n with
  | zero => intro a b c hab hc; exact ⟨c, hab ▸ hc, rfl⟩
  | succ n ih =>
    intro a b c hab hc
    obtain ⟨d, hd, hdb⟩ := hab
    exact ⟨d, hd, ih hdb hc⟩

/-- Converse step relations give reversed paths of the same length. -/
theorem PathN.reverse {f g : TimeIndex → List TimeIndex}
    (hfg : ∀ x y, y ∈ f x ↔ x ∈ g y) :
    ∀ {n : Nat} {a b : TimeIndex}, PathN f n a b → PathN g n b a := by
  intro n
  induction n with
  | zero => intro a b h; exact h.symm
  | succ n ih =>
    intro a b h
    obtain ⟨c, hc, hcb⟩ := h
    exact PathN.snoc (ih hcb) ((hfg a c).mp hc)

/-- The forward and backward one-step relations are converses: both say
`(x, y) ∈ ord.constraints`. -/
theorem mem_directFutureOf_iff (ord : TimeOrdering) (x y : TimeIndex) :
    y ∈ ord.directFutureOf x ↔ x ∈ ord.directPastOf y := by
  simp [directFutureOf, directPastOf, List.mem_filterMap]

/-! ### Monotonicity of the closures under constraint extension

The `addFuture` arms of `timeLinearity` extend the constraint list without touching the branch.
What the progress measure needs from that is: adding a constraint can only *grow* each closure,
and the constraint just added is actually seen by the closure. Both are consumers of the BFS
calculus above — nothing new is built.

The fuel bound is not an obstacle, and for the same reason `orderDual_holds` already relies on:
`bfsClosure_sound` bounds the extracted path's length by the very fuel `bfsClosure_complete` is
allowed to spend, so a path transported along a *larger* edge set is re-found at the *same* fuel
`100`. Growing the edge set never lengthens the witnessing path. -/

/-- A path transports along any edge-set enlargement, at the same length. -/
theorem pathN_mono {f g : TimeIndex → List TimeIndex} (h : ∀ x y, y ∈ f x → y ∈ g x) :
    ∀ {n : Nat} {a b : TimeIndex}, PathN f n a b → PathN g n a b := by
  intro n
  induction n with
  | zero => intro a b hp; exact hp
  | succ n ih =>
    intro a b hp
    obtain ⟨c, hc, hcb⟩ := hp
    exact ⟨c, h a c hc, ih hcb⟩

/-- One-step forward edges grow with the constraint list. -/
theorem directFutureOf_mono {ord ord' : TimeOrdering}
    (h : ∀ p ∈ ord.constraints, p ∈ ord'.constraints) (x y : TimeIndex) :
    y ∈ ord.directFutureOf x → y ∈ ord'.directFutureOf x := by
  simp only [directFutureOf, List.mem_filterMap]
  rintro ⟨⟨a, b⟩, hab, hcond⟩
  exact ⟨(a, b), h _ hab, hcond⟩

/-- One-step backward edges grow with the constraint list. Mirror of `directFutureOf_mono`. -/
theorem directPastOf_mono {ord ord' : TimeOrdering}
    (h : ∀ p ∈ ord.constraints, p ∈ ord'.constraints) (x y : TimeIndex) :
    y ∈ ord.directPastOf x → y ∈ ord'.directPastOf x := by
  simp only [directPastOf, List.mem_filterMap]
  rintro ⟨⟨a, b⟩, hab, hcond⟩
  exact ⟨(a, b), h _ hab, hcond⟩

/-- **The forward closure is monotone in the constraint list, at the same fuel `100`.**
`bfsClosure_sound` extracts a path of length `1 ≤ n ≤ 100`, `pathN_mono` transports it along the
larger edge set, and `bfsClosure_complete` re-finds it within the same budget. -/
theorem futureOf_mono {ord ord' : TimeOrdering}
    (h : ∀ p ∈ ord.constraints, p ∈ ord'.constraints) (t x : TimeIndex) :
    x ∈ ord.futureOf t → x ∈ ord'.futureOf t := by
  intro hx
  rw [futureOf, reachableForward_eq] at hx
  rcases bfsClosure_sound _ 100 [t] [] hx with hv | ⟨s, hs, n, hn1, hn2, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hs
    subst hs
    rw [futureOf, reachableForward_eq]
    exact bfsClosure_complete _ (pathN_mono (directFutureOf_mono h) hp) hn1 hn2

/-- The backward closure is monotone in the constraint list. Mirror of `futureOf_mono`. -/
theorem pastOf_mono {ord ord' : TimeOrdering}
    (h : ∀ p ∈ ord.constraints, p ∈ ord'.constraints) (t x : TimeIndex) :
    x ∈ ord.pastOf t → x ∈ ord'.pastOf t := by
  intro hx
  rw [pastOf, reachableBackward_eq] at hx
  rcases bfsClosure_sound _ 100 [t] [] hx with hv | ⟨s, hs, n, hn1, hn2, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hs
    subst hs
    rw [pastOf, reachableBackward_eq]
    exact bfsClosure_complete _ (pathN_mono (directPastOf_mono h) hp) hn1 hn2

/-- **The new edge is seen, forwards.** A one-edge path plus `bfsClosure_complete`. -/
theorem mem_futureOf_addFuture (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
    t₂ ∈ (ord.addFuture t₁ t₂).futureOf t₁ := by
  rw [futureOf, reachableForward_eq]
  refine bfsClosure_complete _ (n := 1) ⟨t₂, ?_, rfl⟩ (le_refl 1) (by omega)
  simp [directFutureOf, addFuture, List.mem_filterMap]

/-- **The new edge is seen, backwards.**

Note the argument order: this is `ord.addFuture t₂ t₁`, so the *same* witness pair `(t₁, t₂)` that
arm 1 of `timeLinearity` kills through the `futureOf` conjunct is killed by arm 2 through the
`pastOf` conjunct. That symmetry is why arm 2 needs no appeal to `orderDual_holds`. -/
theorem mem_pastOf_addFuture (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
    t₂ ∈ (ord.addFuture t₂ t₁).pastOf t₁ := by
  rw [pastOf, reachableBackward_eq]
  refine bfsClosure_complete _ (n := 1) ⟨t₂, ?_, rfl⟩ (le_refl 1) (by omega)
  simp [directPastOf, addFuture, List.mem_filterMap]

end TimeOrdering

/--
**The one residual of the label dimension: the two closures are duals.**

`firstIncomparablePair` records comparability as "`t₂` is in `t₁`'s `futureOf`", while
`isTemporallyBlocked` — and hence `blocking_fires_of_card_lt` — reads it as "`t₁` is in `t₂`'s
`ancestorTimes`", which is `pastOf`. The two are the forward and backward transitive closures of
the *same* constraint list.

The condition is kept as a named `def` rather than inlined because it is the precise interface
between the two readings, and because the duality probes below evaluate it directly. It is
**no longer a hypothesis**: `orderDual_holds` discharges it for every `TimeOrdering`.
-/
def OrderDual (ord : TimeOrdering) : Prop :=
  ∀ t₁ t₂ : TimeIndex, t₂ ∈ ord.futureOf t₁ → t₁ ∈ ord.pastOf t₂

/--
**The duality holds, for every ordering.** Forward BFS membership yields a constraint path of
between one and `100` edges (`bfsClosure_sound`); reversing it edge-by-edge against
`mem_directFutureOf_iff` gives a backward path of the same length (`PathN.reverse`); and backward
BFS at the same default fuel finds it (`bfsClosure_complete`). Both closures run at fuel `100`, so
the path length that soundness bounds is exactly the one completeness can spend.
-/
theorem orderDual_holds (ord : TimeOrdering) : OrderDual ord := by
  intro t₁ t₂ h
  rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [t₁] [] h with hv | ⟨s, hs, n, hn1, hn2, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hs
    subst hs
    rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq]
    exact TimeOrdering.bfsClosure_complete _
      (TimeOrdering.PathN.reverse (TimeOrdering.mem_directFutureOf_iff ord) hp) hn1 hn2

/--
**The chain invariant, established.** A branch whose linearity stage is exhausted has all its
times pairwise comparable in the ancestor order.

This is the run-level invariant the T3 residual named: `timeLinearity` fires exactly while an
incomparable pair remains, so its silence *is* the chain condition, and `TimeChain` is what
`blocking_fires_of_card_lt` needs.
-/
theorem timeChain_of_linearity_saturated {b : Branch} {ord : TimeOrdering}
    (h : firstIncomparablePair b ord = none) : TimeChain b ord := by
  intro t₁ h₁ t₂ h₂ hne
  rcases comparable_of_firstIncomparablePair_none h h₁ h₂ (Ne.symm hne) with hfut | hpast
  · exact Or.inl (orderDual_holds ord t₁ t₂ hfut)
  · exact Or.inr hpast

/-! ### The incomparable-pair measure

The second component of the `.splitOrdered` progress measure. `timeLinearity` fires exactly while
an incomparable pair remains, and its two `addFuture` arms leave the *branch* literally unchanged
— so the only thing that can be moving there is the ordering, and what it moves is the count of
incomparable pairs among the branch's known times.

`incomparableB` transcribes `firstIncomparablePair`'s own test **verbatim** rather than
re-deriving an equivalent one. That is deliberate: the measure must not be able to drift from the
trigger it is meant to track. -/

/--
**What the trigger guarantees, `some` direction.** The companion to
`comparable_of_firstIncomparablePair_none`: when `timeLinearity` does fire, the pair it reports is
a genuine pair of branch times, distinct, and incomparable in both directions.
-/
theorem firstIncomparablePair_spec {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : firstIncomparablePair b ord = some (t₁, t₂)) :
    t₁ ∈ b.knownTimes ∧ t₂ ∈ b.knownTimes ∧ t₂ ≠ t₁ ∧
      t₂ ∉ ord.futureOf t₁ ∧ t₂ ∉ ord.pastOf t₁ := by
  simp only [firstIncomparablePair] at h
  obtain ⟨l₁, a, l₂, hsplit, hfa, -⟩ := List.findSome?_eq_some_iff.mp h
  have hamem : a ∈ b.knownTimes := by rw [hsplit]; simp
  rcases hfind : b.knownTimes.find? (fun t => t != a && !(ord.futureOf a).contains t
      && !(ord.pastOf a).contains t) with _ | c
  · rw [hfind] at hfa; simp at hfa
  · rw [hfind] at hfa
    simp only [Option.some.injEq, Prod.mk.injEq] at hfa
    obtain ⟨ha1, ha2⟩ := hfa
    subst ha1; subst ha2
    have hcmem : c ∈ b.knownTimes := List.mem_of_find?_eq_some hfind
    have hp := (List.find?_eq_some_iff_getElem.mp hfind).1
    simp only [Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true', List.contains_eq_mem,
      decide_eq_false_iff_not] at hp
    exact ⟨hamem, hcmem, hp.1.1, hp.1.2, hp.2⟩

/-- `firstIncomparablePair`'s test, transcribed verbatim as a predicate on pairs. -/
def incomparableB (ord : TimeOrdering) (p : TimeIndex × TimeIndex) : Bool :=
  p.2 != p.1 && !(ord.futureOf p.1).contains p.2 && !(ord.pastOf p.1).contains p.2

/-- The incomparable pairs among a branch's known times: the measure's second component. -/
def incompPairs (b : Branch) (ord : TimeOrdering) : Finset (TimeIndex × TimeIndex) :=
  ((b.knownTimes ×ˢ b.knownTimes).filter (incomparableB ord)).toFinset

theorem mem_incompPairs {b : Branch} {ord : TimeOrdering} {p : TimeIndex × TimeIndex} :
    p ∈ incompPairs b ord ↔
      p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes ∧ incomparableB ord p = true := by
  cases p with
  | mk x y => simp [incompPairs, List.mem_toFinset, List.mem_product, and_assoc]

/-- Incomparability is *anti*monotone in the constraint list: more constraints, fewer
incomparable pairs. Consumes `futureOf_mono` / `pastOf_mono`. -/
theorem incomparableB_mono {ord ord' : TimeOrdering}
    (h : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) (p : TimeIndex × TimeIndex) :
    incomparableB ord' p = true → incomparableB ord p = true := by
  simp only [incomparableB, Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
    List.contains_eq_mem, decide_eq_false_iff_not]
  rintro ⟨⟨hne, hf⟩, hp⟩
  exact ⟨⟨hne, fun hc => hf (TimeOrdering.futureOf_mono h _ _ hc)⟩,
    fun hc => hp (TimeOrdering.pastOf_mono h _ _ hc)⟩

/-- Extending the constraint list can only shrink the incomparable-pair set. -/
theorem incompPairs_mono {b : Branch} {ord ord' : TimeOrdering}
    (h : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) :
    incompPairs b ord' ⊆ incompPairs b ord := by
  intro p hp
  rw [mem_incompPairs] at hp ⊢
  exact ⟨hp.1, hp.2.1, incomparableB_mono h p hp.2.2⟩

/-- `addFuture` only ever prepends a constraint. -/
theorem addFuture_constraints_mono (ord : TimeOrdering) (t t' : TimeIndex) :
    ∀ q ∈ ord.constraints, q ∈ (ord.addFuture t t').constraints := by
  intro q hq; simp [TimeOrdering.addFuture]; exact Or.inr hq

/--
**The measure's second component strictly drops at both `addFuture` arms.**

This covers arms 1 and 2 of `applyRule .timeLinearity`, whose branch is literally unchanged. The
*same* witness pair `(t₁, t₂)` is eliminated by arm 1 through the `futureOf` conjunct and by arm 2
through the `pastOf` conjunct, which is why arm 2 needs no appeal to `orderDual_holds`.
-/
theorem incompPairs_lt_addFuture {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : firstIncomparablePair b ord = some (t₁, t₂)) :
    (incompPairs b (ord.addFuture t₁ t₂)).card < (incompPairs b ord).card ∧
    (incompPairs b (ord.addFuture t₂ t₁)).card < (incompPairs b ord).card := by
  obtain ⟨h1, h2, hne, hfut, hpast⟩ := firstIncomparablePair_spec h
  have hmem : (t₁, t₂) ∈ incompPairs b ord := by
    rw [mem_incompPairs]
    refine ⟨h1, h2, ?_⟩
    simp only [incomparableB, Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
      List.contains_eq_mem, decide_eq_false_iff_not]
    exact ⟨⟨hne, hfut⟩, hpast⟩
  constructor
  · refine Finset.card_lt_card ⟨incompPairs_mono (addFuture_constraints_mono ord t₁ t₂),
      fun hcon => ?_⟩
    have hc := (mem_incompPairs.mp (hcon hmem)).2.2
    simp only [incomparableB, Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
      List.contains_eq_mem, decide_eq_false_iff_not] at hc
    exact hc.1.2 (TimeOrdering.mem_futureOf_addFuture ord t₁ t₂)
  · refine Finset.card_lt_card ⟨incompPairs_mono (addFuture_constraints_mono ord t₂ t₁),
      fun hcon => ?_⟩
    have hc := (mem_incompPairs.mp (hcon hmem)).2.2
    simp only [incomparableB, Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
      List.contains_eq_mem, decide_eq_false_iff_not] at hc
    exact hc.2 (TimeOrdering.mem_pastOf_addFuture ord t₁ t₂)

/--
**The label dimension, composed.** An unbranched run whose final branch is linearity-saturated and
carries no blocked time is bounded by `2 * |C| * (W * 2 ^ (2 * |C|))`, with `W` the world count.

Every hypothesis here is either discharged elsewhere in this file (`BranchStock`, via T1 iterated;
and the closure duality, now `orderDual_holds`) or is a named, isolated side condition: `hev` (the
eventuality guard, vacuous for the empty tracker), `hnb` (the run has not yet blocked), and `hW`
(the world dimension, discharged for the S5 rule set by `worldFinset_card_le` below).
-/
theorem chain_le_worlds_of_linearity_saturated {C : Finset Formula} {ord : TimeOrdering}
    {tracker : EventualityTracker} {W : Nat}
    (hC : TableauClosed C) (hT : TrichStock C)
    (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hlin : firstIncomparablePair (run n) ord = none)
    (hev : ∀ t₁ ∈ (run n).knownTimes, ∀ t₂ ∈ (run n).knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime (run n) ord tracker = none)
    (hW : (run n).worldFinset.card ≤ W) :
    n ≤ 2 * C.card * (W * 2 ^ (2 * C.card)) :=
  chain_le_worlds_of_not_blocked hC hT run n h0 hstep
    (timeChain_of_linearity_saturated hlin) hev hnb hW

/-! ## The world dimension

`chain_le_worlds_times` leaves two cardinalities; the time one is discharged above. This section
discharges the **world** one — a dimension neither T1 nor T2 touches, since T1 bounds formulas and
T2 bounds times.

### Why worlds are bounded at all, and by what

Exactly two rules mint fresh worlds: `boxNeg` (on `F(□ψ)`) and `diamondPos` (on `T(◇ψ)`); every
other `ruleMintsFreshLabel` constructor mints a fresh *time*. Neither modal rule carries an
internal guard — `applyRule`'s `boxNeg` arm returns `.linear (witness :: …)` unconditionally — so
what stops them re-firing is `findApplicableRule`, which gates every `ruleMintsFreshLabel` rule
behind `witnessPresent`.

The shape of that gate is the whole argument, and it differs between the modal and temporal arms:

    -- modal (boxNeg): quantified over EVERY known world
    branch.knownWorlds.any fun w => branch.contains (.neg ψ { world := w, time := l.time })

    -- temporal (allFutureNeg): world HELD FIXED, quantified over times
    (timeOrd.futureOf l.time).any fun t => branch.contains (.neg ψ { world := l.world, time := t })

The modal guard is *world-indifferent*. Once any world at all carries `F(ψ)` at time `t`, no
`F(□ψ)` at time `t` mints again — not at that world, and not at any other. That is the S5
universal-accessibility discipline showing up as a termination fact: a minted world is identified
by the **sign, formula and time** of the witness it was minted for, and never by its own index.
So the non-seed worlds inject into signed formulas over the stock with the world component
normalised away, giving `2 * |C| * |times|` of them.

### Consequence for `soundFuel'` — stated, not glossed

The bound below is `|S| + 2 * |C| * |times|`, and with T2's time bound that is
`|S| + 2 * |C| * 2 ^ (2 * |C|)`. It is emphatically **not** `1`. Feeding it through
`chain_le_worlds_of_linearity_saturated` gives `chain_le_worlds_bounded`, whose figure exceeds
`soundFuel' φ = 2 * n * 2 ^ (2 * n)` by a factor of about `2 * |C| * 2 ^ (2 * |C|)`, because
`soundFuel'` has no world factor in it at all. `soundFuel'` is therefore adequate only for runs
that stay in one world; the general figure is `chain_le_worlds_bounded`'s. Redefining `soundFuel'`
is a plan-level decision and is not taken here — but no claim below asserts `soundFuel'` suffices
in the presence of fresh worlds.
-/

/-- Labels at the canonical world `0`, one per time the branch mentions. The world dimension is
normalised away because the S5 witness guard is world-indifferent. -/
def Branch.timeLabels (b : Branch) : Finset Label :=
  b.timeFinset.image fun t => { world := 0, time := t }

theorem Branch.card_timeLabels_le (b : Branch) : b.timeLabels.card ≤ b.timeFinset.card :=
  Finset.card_image_le

theorem Branch.mem_timeLabels {b : Branch} {t : TimeIndex} (h : t ∈ b.timeFinset) :
    ({ world := 0, time := t } : Label) ∈ b.timeLabels :=
  Finset.mem_image.mpr ⟨t, h, rfl⟩

/-- The witness signature of a signed formula: everything the modal guard reads, which is
sign, formula and time — with the world component normalised away, because the guard never
reads it. -/
def witnessSig (x : SignedFormula) : SignedFormula :=
  { x with label := { world := 0, time := x.label.time } }

@[simp] theorem witnessSig_formula (x : SignedFormula) : (witnessSig x).formula = x.formula := rfl

@[simp] theorem witnessSig_label (x : SignedFormula) :
    (witnessSig x).label = { world := 0, time := x.label.time } := rfl

/--
**The S5 fresh-world discipline, as a branch invariant.**

Outside a seed set `S` of worlds, every world of `b` carries a witness confined to the stock `C`
and to a time `b` mentions, and distinct such worlds carry witnesses with *distinct signatures*.
The injectivity clause is the content: it is precisely what `witnessPresent`'s world-indifferent
modal arms enforce, since a second world minted for the same sign/formula/time would have found
the first one's witness and been suppressed.

This is stated as an invariant rather than derived from the rule set because deriving it is a
36-case induction over `applyRule` of the same shape and size as T1 (`SubformulaProperty.lean`),
and belongs with that work rather than with the counting argument it feeds.
-/
def WorldWitness (C : Finset Formula) (S : Finset WorldIndex) (b : Branch) : Prop :=
  ∃ wit : WorldIndex → SignedFormula,
    (∀ w ∈ b.worldFinset, w ∉ S →
      (wit w).formula ∈ C ∧ (wit w).label.time ∈ b.timeFinset) ∧
    (∀ w₁ ∈ b.worldFinset, w₁ ∉ S → ∀ w₂ ∈ b.worldFinset, w₂ ∉ S →
      witnessSig (wit w₁) = witnessSig (wit w₂) → w₁ = w₂)

/--
**The world bound.** A branch under the fresh-world discipline has at most
`|S| + 2 * |C| * |times|` worlds: the seed, plus one per witness signature available over the
stock and the branch's own times.

The counting is the same shape as `branch_card_le` — inject into `signedUniverse` and apply
`card_signedUniverse_le` — run against `timeLabels` rather than the full label set, which is
exactly where the world-indifference of the modal guard is spent.
-/
theorem worldFinset_card_le {C : Finset Formula} {S : Finset WorldIndex} {b : Branch}
    (h : WorldWitness C S b) :
    b.worldFinset.card ≤ S.card + 2 * C.card * b.timeFinset.card := by
  obtain ⟨wit, hmem, hinj⟩ := h
  have hsub : b.worldFinset ⊆ S ∪ (b.worldFinset \ S) := by
    intro w hw
    by_cases hs : w ∈ S
    · exact Finset.mem_union_left _ hs
    · exact Finset.mem_union_right _ (Finset.mem_sdiff.mpr ⟨hw, hs⟩)
  have hdiff : (b.worldFinset \ S).card ≤ (signedUniverse C b.timeLabels).card := by
    refine Finset.card_le_card_of_injOn (fun w => witnessSig (wit w)) ?_ ?_
    · intro w hw
      obtain ⟨hw₁, hw₂⟩ := Finset.mem_sdiff.mp hw
      obtain ⟨hC, hT⟩ := hmem w hw₁ hw₂
      exact mem_signedUniverse hC (Branch.mem_timeLabels hT)
    · intro w₁ hw₁ w₂ hw₂ heq
      obtain ⟨ha₁, ha₂⟩ := Finset.mem_sdiff.mp hw₁
      obtain ⟨hb₁, hb₂⟩ := Finset.mem_sdiff.mp hw₂
      exact hinj w₁ ha₁ ha₂ w₂ hb₁ hb₂ heq
  calc b.worldFinset.card
      ≤ (S ∪ (b.worldFinset \ S)).card := Finset.card_le_card hsub
    _ ≤ S.card + (b.worldFinset \ S).card := Finset.card_union_le _ _
    _ ≤ S.card + (signedUniverse C b.timeLabels).card := Nat.add_le_add_left hdiff _
    _ ≤ S.card + 2 * C.card * b.timeLabels.card :=
        Nat.add_le_add_left (card_signedUniverse_le C b.timeLabels) _
    _ ≤ S.card + 2 * C.card * b.timeFinset.card :=
        Nat.add_le_add_left (Nat.mul_le_mul_left _ (Branch.card_timeLabels_le b)) _

/--
**The step bound with *both* cardinalities discharged.** No `W` parameter, no `hW`, no
`OrderDual`: an unbranched run out of a stock-confined seed, whose linearity stage is exhausted,
whose eventuality guard holds and which has not blocked, and which obeys the S5 fresh-world
discipline out of a seed world set `S`, runs for at most

    2 * |C| * ((|S| + 2 * |C| * 2 ^ (2 * |C|)) * 2 ^ (2 * |C|))

steps. This is the honest fuel figure in the presence of fresh worlds; see the world-dimension
preamble for why it is not `soundFuel' φ` and by how much they differ.
-/
theorem chain_le_worlds_bounded {C : Finset Formula} {S : Finset WorldIndex}
    {ord : TimeOrdering} {tracker : EventualityTracker}
    (hC : TableauClosed C) (hT : TrichStock C)
    (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hlin : firstIncomparablePair (run n) ord = none)
    (hev : ∀ t₁ ∈ (run n).knownTimes, ∀ t₂ ∈ (run n).knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime (run n) ord tracker = none)
    (hww : WorldWitness C S (run n)) :
    n ≤ 2 * C.card * ((S.card + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card)) := by
  have htime : (run n).timeFinset.card ≤ 2 ^ (2 * C.card) :=
    timeFinset_card_le_of_not_blocked (branchStock_chain hC hT run n h0 hstep).mem
      (timeChain_of_linearity_saturated hlin) hev hnb
  refine chain_le_worlds_of_linearity_saturated hC hT run n h0 hstep hlin hev hnb ?_
  exact le_trans (worldFinset_card_le hww)
    (Nat.add_le_add_left (Nat.mul_le_mul_left _ htime) _)

/-! ### World-discipline probes

`WorldWitness` is an invariant rather than a theorem, so it ships with executable rows, on the
same principle as the duality probes: an unevaluated hypothesis is not evidence. The rows below
run the engine's *actual* guard, `witnessPresent`, and check the one property the whole world
bound rests on — that its modal arms ignore the world they are asked about.
-/

section WorldProbes

/-- The discipline is satisfiable. Degenerately so at `S := b.worldFinset`, where the bound reads
`|worlds| ≤ |worlds| + …` — sound, but empty. The content is in taking `S` to be the *seed's*
worlds, which is what makes the second summand the real bound. This row exists to show the
definition is not accidentally unsatisfiable. -/
theorem worldWitness_self (C : Finset Formula) (b : Branch) : WorldWitness C b.worldFinset b := by
  refine ⟨fun _ => ⟨Sign.pos, .bot, { world := 0, time := 0 }⟩, ?_, ?_⟩
  · intro w hw hns; exact absurd hw hns
  · intro w₁ hw₁ hns₁ _ _ _ _; exact absurd hw₁ hns₁

-- A witness at world `7` suppresses `boxNeg` asked at world `3`: the guard is
-- world-indifferent, which is the S5 fact the world bound is built on.
/-- info: true -/
#guard_msgs in
#eval witnessPresent .boxNeg
  (SignedFormula.neg (.box .bot) { world := 3, time := 0 })
  [SignedFormula.neg .bot { world := 7, time := 0 }]
  TimeOrdering.empty

-- Same shape, witness at a different *time*: not suppressed. Time is the dimension the modal
-- guard does read, which is why the world bound is proportional to the time count.
/-- info: false -/
#guard_msgs in
#eval witnessPresent .boxNeg
  (SignedFormula.neg (.box .bot) { world := 3, time := 0 })
  [SignedFormula.neg .bot { world := 7, time := 1 }]
  TimeOrdering.empty

-- The temporal mirror, for contrast: `allFutureNeg`'s guard holds the world fixed, so a witness
-- at another world does *not* suppress it. This is exactly why times need
-- `blocking_fires_of_card_lt` and worlds do not.
/-- info: false -/
#guard_msgs in
#eval witnessPresent .allFutureNeg
  (SignedFormula.neg (.allFuture .bot) { world := 3, time := 0 })
  [SignedFormula.neg .bot { world := 7, time := 1 }]
  ⟨[(0, 1)]⟩

end WorldProbes

/-! ### Duality probes

`OrderDual` is now discharged by `orderDual_holds`, but the rows are kept: they are what caught
the condition being true before the proof existed, and they remain the cheapest check that the
*statement* still says what it should on the shapes the engine actually builds: a chain
(`addFuture` repeated), a fork, a diamond, and a chain put through `identifyTime` — the one
operation that rewrites constraints rather than adding them, and hence the one most likely to
break a duality.
-/

section DualityProbes

/-- The `OrderDual` condition, as a decidable check over a finite set of times. -/
private def dualCheck (ord : TimeOrdering) (ts : List TimeIndex) : Bool :=
  ts.all fun t₁ => (ord.futureOf t₁).all fun t₂ => (ord.pastOf t₂).contains t₁

-- A chain `0 < 1 < 2 < 3`.
/-- info: true -/
#guard_msgs in
#eval dualCheck ⟨[(0, 1), (1, 2), (2, 3)]⟩ [0, 1, 2, 3]

-- A fork: `0 < 1`, `0 < 2`, `2 < 3`.
/-- info: true -/
#guard_msgs in
#eval dualCheck ⟨[(0, 1), (0, 2), (2, 3)]⟩ [0, 1, 2, 3]

-- A diamond: two incomparable middles rejoining.
/-- info: true -/
#guard_msgs in
#eval dualCheck ⟨[(0, 1), (0, 2), (1, 3), (2, 3)]⟩ [0, 1, 2, 3]

-- The chain after `identifyTime 2 1` — the arm of `timeLinearity` that rewrites constraints.
/-- info: true -/
#guard_msgs in
#eval dualCheck ((⟨[(0, 1), (1, 2), (2, 3)]⟩ : TimeOrdering).identifyTime 2 1) [0, 1, 3]

-- A long chain, well past the ordering depths the corpus produces.
/-- info: true -/
#guard_msgs in
#eval dualCheck ⟨(List.range 30).map fun i => (i, i + 1)⟩ (List.range 31)

end DualityProbes

/--
**The fuel figure is justified in the dimension proved.**

`soundFuel'` was *defined* in this file as `2 * n * 2 ^ (2 * n)`, and its docstring is careful to
say the figure is stated rather than earned. This is the theorem that earns it, for unbranched
runs: with `C` the formula stock and the label count at the T2 figure `2 ^ (2 * |C|)`, the step
bound `chain_le_stock` delivers is exactly `soundFuel'` at any `φ` whose closure has `|C|`
members. The two hypotheses that remain are `hl` (labels confined) and `hL` (their count at the
T2 figure).

**`hL` is not dischargeable in general, and this is where that becomes visible.** T2 bounds
*times* by `2 ^ (2 * |C|)` (`timeFinset_card_le_of_not_blocked`), but `L` here is a set of
**labels**, and a label is a world *and* a time. So `hL` asks for `|worlds| * |times|` to sit
under the T2 *time* figure, which holds only when the run stays in a single world. The world
count is bounded — `worldFinset_card_le` gives `|S| + 2 * |C| * |times|` — but it is not `1`, so
`hL` fails as soon as any `boxNeg` or `diamondPos` fires.

The theorem is still true as stated; `hL` is a hypothesis, not a claim. What is *not* available
is a route from T2 to `hL` in the presence of fresh worlds, and therefore `soundFuel'` is not the
general fuel figure. `chain_le_worlds_bounded` is: it takes the world dimension as a dimension
rather than assuming it away, and its figure exceeds `soundFuel' φ` by about
`2 * |C| * 2 ^ (2 * |C|)`.
-/
theorem chain_le_soundFuel' {C : Finset Formula} {L : Finset Label} {φ : Formula}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0)) (hl : ∀ x ∈ run n, x.label ∈ L)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hL : L.card ≤ 2 ^ (2 * C.card))
    (hφ : C.card = (FormalSystem.Syntax.subformulaClosure φ).card) :
    n ≤ soundFuel' φ := by
  have hstep' := chain_le_stock hC hT run n h0 hl hstep
  have : 2 * C.card * L.card ≤ 2 * C.card * 2 ^ (2 * C.card) :=
    Nat.mul_le_mul_left _ hL
  simpa [soundFuel', ← hφ] using le_trans hstep' this

/-! ## 4.3c — `expandBranchWithFuel` does not exhaust

The plan's named deliverable was `buildTableau_isSome` at `soundFuel'`, and it is **false as
stated**: `buildTableau` calls `expandBranchWithFuel` at the default `maxBranches := 50000`, whose
very first line returns `none` once `branchesUsed` reaches that figure, at *any* fuel whatsoever.
The corrected statement quantifies over the branch budget instead of inheriting the default, which
is what this section proves. The engine is untouched — `maxBranches = 50000` is a deliberate
runtime guard, and the wave-3 territory contract forbids editing it.

Three things can make `expandBranchWithFuel` report `none`, and a true theorem has to rule out all
three: the branch-budget guard, fuel exhaustion, and a `none` propagated out of a split arm's
fold. The theorem below rules out the first by hypothesis (`branchesUsed + fuel ≤ maxBranches`),
the second by the T3 progress measure (the run cannot take more steps than the universe has
members), and the third by confining attention to runs that never split. The splitting case is a
genuinely separate obligation — it needs `resolveOpenArm`, which has its own `none` — and is
recorded as such rather than waved at.
-/

/--
An invariant on branches under which the engine's step never splits, and which survives an
extending step.

Stated as a predicate rather than as a property of one run because that is what the induction on
fuel consumes: the recursion re-enters at the *new* branch with a *new* ordering and tracker, so
whatever is assumed at the start has to be re-established there, for all such parameters.
-/
def NoSplit (P : Branch → Prop) (fc : ProofSystem.FrameClass) : Prop :=
  ∀ b, P b → ∀ (ord : TimeOrdering) (tr : EventualityTracker),
    (∀ nb, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb → P nb)
    ∧ (∀ bs, (expandOnceUnblocked b ord fc tr).1 ≠ ExpansionResult.split bs)
    ∧ (∀ bs, (expandOnceUnblocked b ord fc tr).1 ≠ ExpansionResult.splitOrdered bs)

/--
**4.3c, corrected form.** With the branch budget quantified and enough fuel to outlast the finite
universe, an unbranched expansion never reports `none`.

The fuel hypothesis `U.card < b.toFinset.card + fuel` is exactly the T3 progress measure in the
form the induction needs: every extending step consumes one unit of fuel *and* adds at least one
member to the branch-as-a-set, and the branch cannot exceed `U`, so the fuel outlasts the run. At
`fuel = 0` the hypothesis is already contradictory, which is why the base case is discharged
rather than being the place the theorem fails.

The branch-budget hypothesis `branchesUsed + fuel ≤ maxBranches` is the honest replacement for the
plan's silent reliance on the default: each extending step increments `branchesUsed` by one and
decrements `fuel` by one, so the sum is invariant and the guard `branchesUsed ≥ maxBranches` is
never reached.
-/
theorem expandBranchWithFuel_isSome_of_noSplit {P : Branch → Prop}
    {fc : ProofSystem.FrameClass} {U : Finset SignedFormula}
    (hP : NoSplit P fc) (hU : ∀ b, P b → ∀ x ∈ b, x ∈ U) :
    ∀ (fuel : Nat) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker)
      (applied : AppliedSet) (maxBranches branchesUsed : Nat),
      P b → U.card < b.toFinset.card + fuel → branchesUsed + fuel ≤ maxBranches →
      (expandBranchWithFuel b fuel ord fc tr applied maxBranches branchesUsed).isSome = true := by
  intro fuel
  induction fuel with
  | zero =>
      intro b _ _ _ _ _ hPb hcard _
      exact absurd (card_le_of_subset_universe (hU b hPb)) (by omega)
  | succ f ih =>
      intro b ord tr applied mb bu hPb hcard hbud
      rw [expandBranchWithFuel, if_neg (by omega : ¬ bu ≥ mb)]
      rcases hcl : findClosure b fc with _ | reason
      case some => simp
      case none =>
        simp only [expandOnceUnblockedWithApplied]
        obtain ⟨hext, hsp, hsso⟩ :=
          hP b hPb ord (fulfillEventualities b (registerEventualities b tr))
        rcases hres : (expandOnceUnblocked b ord fc
            (fulfillEventualities b (registerEventualities b tr))).1 with _ | nb | bs | bs
        · simp
        · have hgrow := expandOnceUnblocked_card_lt hres
          simpa using ih nb _ _ applied mb (bu + 1) (hext nb hres) (by omega) (by omega)
        · exact absurd hres (hsp bs)
        · exact absurd hres (hsso bs)

/--
**4.3c at the justified fuel figure.** The same statement with the two abstract parameters
instantiated the way T1 and T2 supply them: the universe is `signedUniverse C L`, and the fuel is
whatever exceeds its cardinality.

This is the form a caller uses: exhibit a stock `C` (by `decide`, via
`tableauClosed_of_closureStep_subset`), a label set `L`, a branch budget, and the theorem returns
totality of the expansion. Note that the fuel figure that suffices is `2 * |C| * |L|` — the step
bound of `chain_le_stock` — and `chain_le_soundFuel'` is what identifies that with `soundFuel' φ`
once the label count sits at the T2 figure.
-/
theorem expandBranchWithFuel_isSome_of_stock {P : Branch → Prop}
    {fc : ProofSystem.FrameClass} {C : Finset Formula} {L : Finset Label}
    (hP : NoSplit P fc)
    (hf : ∀ b, P b → ∀ x ∈ b, x.formula ∈ C) (hl : ∀ b, P b → ∀ x ∈ b, x.label ∈ L)
    (fuel : Nat) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker)
    (applied : AppliedSet) (maxBranches branchesUsed : Nat)
    (hPb : P b) (hfuel : 2 * C.card * L.card < fuel)
    (hbud : branchesUsed + fuel ≤ maxBranches) :
    (expandBranchWithFuel b fuel ord fc tr applied maxBranches branchesUsed).isSome = true :=
  expandBranchWithFuel_isSome_of_noSplit (U := signedUniverse C L) hP
    (fun b' hb' x hx => mem_signedUniverse (hf b' hb' x hx) (hl b' hb' x hx))
    fuel b ord tr applied maxBranches branchesUsed hPb
    (by have := card_signedUniverse_le C L; omega) hbud

/-! ### Non-vacuity

`expandBranchWithFuel_isSome_of_noSplit` is stated over a hypothetical invariant `P`, and
`P := fun _ => False` would satisfy `NoSplit` vacuously — so the theorem is worth exactly as much
as the existence of a satisfying `P` with an inhabited branch. The witness below supplies one
outright, and it is not artificial: the empty branch is the engine's own starting shape before any
seed formula is placed, and it is `saturated` at every ordering, frame class and tracker because
all three pick stages scan the branch itself.
-/

/-- The engine reports `saturated` on the empty branch, at every parameter: all three pick stages
scan the branch, and there is nothing to scan. -/
theorem expandOnceUnblocked_nil (ord : TimeOrdering) (fc : ProofSystem.FrameClass)
    (tr : EventualityTracker) :
    (expandOnceUnblocked [] ord fc tr).1 = ExpansionResult.saturated := by
  simp [expandOnceUnblocked, findUnexpandedUnblockedWith]

/-- **`NoSplit` is satisfiable.** -/
theorem noSplit_nil (fc : ProofSystem.FrameClass) :
    NoSplit (fun b => b = ([] : Branch)) fc := by
  rintro b rfl ord tr
  refine ⟨fun nb h => ?_, fun bs h => ?_, fun bs h => ?_⟩ <;>
    rw [expandOnceUnblocked_nil] at h <;> exact absurd h (by simp)

/-- **The corrected 4.3c statement, fully instantiated and hypothesis-free apart from the branch
budget.** Nothing here is assumed: the invariant, the universe and the fuel are all supplied, and
the only condition left is the one the plan's blocker note identified as the real content — that
the branch budget covers the run. -/
theorem expandBranchWithFuel_nil_isSome (fuel : Nat) (ord : TimeOrdering)
    (fc : ProofSystem.FrameClass) (tr : EventualityTracker) (applied : AppliedSet)
    (maxBranches branchesUsed : Nat)
    (hfuel : 0 < fuel) (hbud : branchesUsed + fuel ≤ maxBranches) :
    (expandBranchWithFuel [] fuel ord fc tr applied maxBranches branchesUsed).isSome = true :=
  expandBranchWithFuel_isSome_of_noSplit (U := (∅ : Finset SignedFormula)) (noSplit_nil fc)
    (fun _ hb x hx => absurd hx (by subst hb; simp)) fuel [] ord tr applied maxBranches
    branchesUsed rfl
    (by simp only [Finset.card_empty, List.toFinset_nil]; omega) hbud

/-! ## 4.3d residual 3 — the branching arms: what the budget costs, and what the *fuel* costs

The budget half of this residual is exactly as report 06 §4 describes, and the description is
confirmed here: in both split arms `branchesUsed'` is a `let` bound **once, before** the fold
(`Saturation.lean:646, :675`) and the *same* value reaches every sibling (`:654, :681`), while the
fold's accumulator carries only the `Option` and no counter. Sibling usage is therefore not
accumulated — the budget is **path-shaped**, and the linear invariant
`branchesUsed + β * fuel ≤ maxBranches` is preserved by every arm. `splitBudget_preserved` below
is that preservation, with `β` a hypothesis on `branches.length` rather than the literal `3`
(`3` is the currently *measured* maximum — `orderTrichotomy`'s three disjuncts and
`timeLinearity`'s three arms — and a census is not a theorem).

**But the budget is not the binding constraint in the split arms, and the fuel is.** This is new,
and it corrects the residual's "orthogonal to the fuel figure" framing. Source:

* `estimateBranchDifficulty` (`Saturation.lean:360-364`) is `1 + 3*tempCount + 2*modCount + len/4`,
  so it is **always ≥ 1** — no arm is ever starved to `0` by a zero difficulty.
* `allocateFuelProportionally (fuel+1) branches` (`:378-388`) hands each arm
  `min (max 1 (fuel.succ * d / max 1 totalDifficulty)) fuel` — a **proportional share**, and the
  arms' difficulties sum to `totalDifficulty`, so `k` arms of equal difficulty each receive about
  `fuel / k`, not `fuel`.
* The split arms recurse at `min pair.2 fuel` (`:653, :680`).

So a sub-branch that still needs `m` extending steps receives roughly `fuel / k` units, and the
progress-measure hypothesis `U.card < b.toFinset.card + fuel` that
`expandBranchWithFuel_isSome_of_noSplit` consumes is **not** re-established at the arms by any
amount of parent fuel that is merely `> U.card`. Fuel adequate for a split run scales like
`β ^ depth * worldFuel'`, and `depth` is not bounded by anything proved here. The split arms
therefore **multiply** the fuel figure; they do not sit beside it.

This is the same *class* of fact as the 4.3b blocker (`buildTableau_isSome` is false at the engine
default `maxBranches`): a real property of a deliberate engine policy, not a gap in a proof. The
engine is untouched — the wave-3 territory contract forbids editing `allocateFuelProportionally`,
and the proportional policy is there for good `#eval` reasons. Accordingly `NoSplit` **stays** the
named hypothesis confining the arms, exactly as `expandBranchWithFuel_isSome_of_stock` and
`expandBranchWithFuel_isSome_at_worldFuel'` carry it. What is discharged here is the budget half,
which is real and reusable; what is *named* is the arm-fuel shortfall, with executable rows so it
is evidence rather than assertion.
-/

/--
**Every arm gets at least one unit of fuel.** The allocation's `max 1` floor survives the `min`
whenever the parent had at least two units, so no arm is starved outright — the shortfall
documented above is proportional, not degenerate.
-/
theorem allocateFuelProportionally_pos (fuel : Nat) (branches : List Branch) (n : Nat)
    (hf : 0 < fuel) (h : n ∈ allocateFuelProportionally (fuel + 1) branches) : 1 ≤ n := by
  simp only [allocateFuelProportionally] at h
  rw [List.mem_map] at h
  obtain ⟨d, _, rfl⟩ := h
  exact Nat.le_min.mpr ⟨Nat.le_max_left _ _, hf⟩

/--
**The path-shaped budget invariant is preserved by a split.** Entering with
`branchesUsed + β * (fuel + 1) ≤ maxBranches` and splitting into at most `β` arms, every arm —
which receives `branchesUsed + branches.length` and at most `fuel` units — still satisfies
`branchesUsed' + β * fuel ≤ maxBranches`.

`β` enters as a hypothesis on `branches.length`, not as the literal `3`: `3` is the measured
maximum over the current rule set, and a rule added later could break it, so the coefficient is
carried rather than baked in. Note this needs no fact about the *fold*, precisely because the
siblings do not accumulate each other's usage.
-/
theorem splitBudget_preserved {branchesUsed maxBranches fuel β k : Nat}
    (hβ : k ≤ β) (hbud : branchesUsed + β * (fuel + 1) ≤ maxBranches) :
    branchesUsed + k + β * fuel ≤ maxBranches := by
  have : β * (fuel + 1) = β * fuel + β := by rw [Nat.mul_succ]
  omega

/-- The same invariant is preserved by an extending step, which consumes one unit of budget and
one of fuel. This is the `β`-general form of the step `expandBranchWithFuel_isSome_of_noSplit`
already takes. -/
theorem extendBudget_preserved {branchesUsed maxBranches fuel β : Nat} (hβ : 1 ≤ β)
    (hbud : branchesUsed + β * (fuel + 1) ≤ maxBranches) :
    branchesUsed + 1 + β * fuel ≤ maxBranches :=
  splitBudget_preserved hβ hbud

/-- The `β`-linear budget implies the linear one the landed totality theorems consume, so
`expandBranchWithFuel_isSome_of_noSplit` needs no weakening to accept it. -/
theorem budget_le_of_betaBudget {branchesUsed maxBranches fuel β : Nat} (hβ : 1 ≤ β)
    (hbud : branchesUsed + β * fuel ≤ maxBranches) :
    branchesUsed + fuel ≤ maxBranches :=
  le_trans (Nat.add_le_add_left (Nat.le_mul_of_pos_left _ (by omega)) _) hbud

/-! ### 4.3d(i) — what a split arm inherits, and what it does *not*

The unsplit induction's progress measure is `U.card < b.toFinset.card + fuel`, and re-establishing
it at a split arm needs two things: the arm must be strictly larger as a set (so the `U.card`
side has room), and the arm's fuel allocation must be large enough (so the `fuel` side does).
This subsection settles the first question for both split constructors — and the answers differ,
which is the finding.
-/

/-- The pick-tail of `expandOnceUnblocked` reports `.split` only from a `.branching` rule result,
and the arms it reports are that result's arms appended to the branch.

Stated over an abstract `pick` for the same reason `pick_extended` is (Tableau.lean): a hypothesis
about the three-stage `match` as a whole is not something the per-stage lemmas can consume. -/
private theorem pick_split {b : Branch} {bs : List Branch} {ord : TimeOrdering}
    {pick : Option (TableauRule × RuleResult × TimeOrdering)}
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

/-- The same, for `.splitOrdered`: the arms are the rule's own replacement branches, handed
through unchanged. Note what is *absent* from the conclusion — there is no `++ b`, because an
ordered split does not append to the branch at all. -/
private theorem pick_splitOrdered {b : Branch} {bs : List (Branch × TimeOrdering)}
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
         = ExpansionResult.splitOrdered bs) :
    ∃ r o, pick = some (r, RuleResult.branchingOrdered bs, o) := by
  rcases pick with _ | ⟨r, res, o⟩
  · simp at h
  · cases res with
    | notApplicable => simp at h
    | linear fs => simp at h
    | branching bss => simp at h
    | persistent fs => simp at h
    | branchingOrdered bs' => exact ⟨r, o, by simpa using h⟩

/-- **The shape of a `.split`**: every arm is the branch with a rule arm appended. -/
theorem expandOnceUnblocked_split_shape {b : Branch} {bs : List Branch} {ord : TimeOrdering}
    {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs) :
    ∃ bss : List (List SignedFormula), bs = bss.map (fun fs => fs ++ b) := by
  unfold expandOnceUnblocked at h
  obtain ⟨_, bss, _, _, hbs⟩ := pick_split h
  exact ⟨bss, hbs⟩

/-- **A `.split` arm contains the branch it came from.** Non-destructive expansion in the split
arms, in the form the universe bound consumes. -/
theorem expandOnceUnblocked_split_subset {b nb : Branch} {bs : List Branch} {ord : TimeOrdering}
    {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs) (hnb : nb ∈ bs) :
    ∀ x ∈ b, x ∈ nb := by
  obtain ⟨bss, rfl⟩ := expandOnceUnblocked_split_shape h
  obtain ⟨fs, _, rfl⟩ := List.mem_map.mp hnb
  intro x hx
  exact List.mem_append_right fs hx

/-- **A `.split` arm is at least as large as the branch, as a set.** The *strict* version is the
one Phase-6-style split-depth reasoning would want, and it is not proved here — see the
`splitOrdered` note below for why the strict version does not generalise across both split
constructors. -/
theorem expandOnceUnblocked_split_card_le {b nb : Branch} {bs : List Branch} {ord : TimeOrdering}
    {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs) (hnb : nb ∈ bs) :
    b.toFinset.card ≤ nb.toFinset.card :=
  Finset.card_le_card fun x hx =>
    List.mem_toFinset.mpr (expandOnceUnblocked_split_subset h hnb x (List.mem_toFinset.mp hx))

/-! ### The strict `.split` growth, in three cases

`expandOnceUnblocked_split_card_le` above is non-strict, and a `.split` depth bound needs the
strict version. What supplies it is `findApplicableRule`'s `.branching` guard — but that guard has
**exactly two bypasses**, `ruleSelfGuarded` and `ruleMintsFreshLabel`, so the argument splits into
three cases rather than one:

1. **ordinary rules** — the `bss.any (fun fs => fs.all branch.contains)` guard rejects the result
   outright when some arm adds nothing, so every accepted arm carries a formula the branch lacks;
2. **`ruleSelfGuarded`** (`.untlNeg`, `.snceNeg`) — their surviving ACTIVE arm mints
   `branch.nextTime` and emits at it, so each arm's head sits at a time the branch does not carry;
3. **`ruleMintsFreshLabel`** (`.untlPos`, `.sncePos` among the branching rules) — same argument.

Cases 2 and 3 share one lemma (`applyRule_branching_arms_fresh`) because they share the witness:
`Branch.nextTime`, and `not_mem_of_time_nextTime`.

The other two pick stages cannot reach this lemma at all: `serialityRule` reports only
`.notApplicable`/`.persistent`, and `timeLinearity` only `.notApplicable`/`.branchingOrdered`, so
neither can produce the `.branching` a `.split` comes from. Those two are dispatched by the
`_not_branching` lemmas rather than by a fourth guard case. -/

/-- Case 1: the containment guard, read as "every accepted arm adds something". -/
theorem branching_arms_new_of_guard {b : Branch} {bss : List (List SignedFormula)}
    (hg : bss.any (fun fs => fs.all b.contains) = false) :
    ∀ fs ∈ bss, ∃ x ∈ fs, x ∉ b := by
  intro fs hfs
  have := (List.any_eq_false.mp hg) fs hfs
  simp only [Bool.not_eq_true, List.all_eq_false] at this
  obtain ⟨x, hx, hxc⟩ := this
  exact ⟨x, hx, not_mem_of_contains_false (by simpa using hxc)⟩

set_option maxHeartbeats 1600000 in
/-- Cases 2 and 3: the guard bypasses. A rule that is self-guarded or mints a fresh label and
still reports `.branching` emits, on every arm, at `branch.nextTime` — a time no formula on the
branch carries. The 36-rule case analysis leaves exactly the four live rules (`.untlNeg`,
`.snceNeg`, `.untlPos`, `.sncePos`); every other rule either fails the guard hypothesis or does
not report `.branching`. -/
theorem applyRule_branching_arms_fresh (rule : TableauRule) (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bss : List (List SignedFormula))
    (hg : ruleSelfGuarded rule = true ∨ ruleMintsFreshLabel rule = true)
    (h : (applyRule rule sf b ord).1 = RuleResult.branching bss) :
    ∀ fs ∈ bss, ∃ x ∈ fs, x ∉ b := by
  cases sf with
  | mk sign formula label =>
  cases rule <;> simp only [ruleSelfGuarded, ruleMintsFreshLabel] at hg <;>
    simp only [applyRule] at h <;> (repeat' split at h) <;> (try simp_all)
  all_goals
    subst h
    intro fs hfs
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hfs
    rcases hfs with rfl | rfl <;>
      refine ⟨_, List.mem_cons_self, not_mem_of_time_nextTime ?_⟩ <;> rfl

/-- The guard-carrying companion to `findApplicableRule_applyRule_eq`: a `.branching` result the
ordinary stage accepted was accepted through exactly one of the three routes. This is the lemma
that pins the "three cases" count to the source rather than to a reading of it. -/
theorem findApplicableRule_branching_guard
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {r : TableauRule} {bss : List (List SignedFormula)} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, RuleResult.branching bss, o)) :
    ruleSelfGuarded r = true ∨ ruleMintsFreshLabel r = true ∨
      bss.any (fun fs => fs.all b.contains) = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  repeat' split at hr
  all_goals simp_all

/-- `serialityRule` reports `.notApplicable` or `.persistent`, never `.branching`. -/
theorem applyRule_serialityRule_not_branching (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bss : List (List SignedFormula)) :
    (applyRule .serialityRule sf b ord).1 ≠ RuleResult.branching bss := by
  cases sf with
  | mk sign formula label => simp only [applyRule]; split <;> simp

/-- `timeLinearity` reports `.notApplicable` or `.branchingOrdered`, never `.branching`. -/
theorem applyRule_timeLinearity_not_branching (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bss : List (List SignedFormula)) :
    (applyRule .timeLinearity sf b ord).1 ≠ RuleResult.branching bss := by
  cases sf with
  | mk sign formula label => simp only [applyRule]; split <;> simp

/-- The seriality stage cannot produce the `.branching` a `.split` comes from. -/
theorem findApplicableSerialRule_not_branching {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} {r : TableauRule} {bss : List (List SignedFormula)} {o : TimeOrdering}
    (h : findApplicableSerialRule sf b ord = some (r, RuleResult.branching bss, o)) : False := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  cases hres : (applyRule TableauRule.serialityRule sf b ord).1
  case branching bss' => exact applyRule_serialityRule_not_branching sf b ord bss' hres
  all_goals rw [hres] at h; simp at h

/-- The linearity stage cannot produce the `.branching` a `.split` comes from. -/
theorem findApplicableLinearityRule_not_branching {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} {r : TableauRule} {bss : List (List SignedFormula)} {o : TimeOrdering}
    (h : findApplicableLinearityRule sf b ord = some (r, RuleResult.branching bss, o)) : False := by
  unfold findApplicableLinearityRule linearityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  cases hres : (applyRule TableauRule.timeLinearity sf b ord).1
  case branching bss' => exact applyRule_timeLinearity_not_branching sf b ord bss' hres
  all_goals rw [hres] at h; simp at h

/--
**A `.split` arm is strictly larger than the branch, as a set.**

The strict companion of `expandOnceUnblocked_split_card_le`, which stays in place unmodified —
this lemma is purely additive. It is what bounds `.split` depth by `|U|`: each split level adds a
formula from the finite universe, so a run cannot split more than `|U|` times without repeating.

Contrast with `.splitOrdered`, where the analogous statement is **false** (see
`applyRule_timeLinearity_arms`): ordered-split arms replace rather than extend, and arm 3 can
shrink the branch. That asymmetry is exactly why `splitOrderedMeasure` exists.
-/
theorem expandOnceUnblocked_split_card_lt {b nb : Branch} {bs : List Branch} {ord : TimeOrdering}
    {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs) (hnb : nb ∈ bs) :
    b.toFinset.card < nb.toFinset.card := by
  unfold expandOnceUnblocked at h
  obtain ⟨r, bss, o, hpick, rfl⟩ := pick_split h
  obtain ⟨fs, hfs, rfl⟩ := List.mem_map.mp hnb
  have hnew : ∃ x ∈ fs, x ∉ b := by
    rcases hfu : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
    · rw [hfu] at hpick
      rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
      · rw [hser] at hpick
        rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                                 && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
        · rw [hlin] at hpick; simp at hpick
        · rw [hlin] at hpick
          simp only at hpick
          exact absurd hpick findApplicableLinearityRule_not_branching
      · rw [hser] at hpick
        simp only at hpick
        exact absurd hpick findApplicableSerialRule_not_branching
    · rw [hfu] at hpick
      simp only at hpick
      rcases findApplicableRule_branching_guard hpick with hg | hg | hg
      · exact applyRule_branching_arms_fresh r sf b ord bss (Or.inl hg)
          (findApplicableRule_applyRule_eq hpick) fs hfs
      · exact applyRule_branching_arms_fresh r sf b ord bss (Or.inr hg)
          (findApplicableRule_applyRule_eq hpick) fs hfs
      · exact branching_arms_new_of_guard hg fs hfs
  obtain ⟨x, hx, hxb⟩ := hnew
  refine Finset.card_lt_card ⟨fun y hy => ?_, fun hcon => ?_⟩
  · exact List.mem_toFinset.mpr (List.mem_append_right fs (List.mem_toFinset.mp hy))
  · exact hxb (List.mem_toFinset.mp
      (hcon (List.mem_toFinset.mpr (List.mem_append_left b hx))))

/--
**An ordered split hands its arms through untouched.** There is no `++ b`: the arms of a
`.branchingOrdered` result *are* branches, supplied by the rule.

This is the negative half of this subsection, and it is load-bearing. `timeLinearity` is the only
rule producing `.branchingOrdered`, and its three arms are
`(branch, ord.addFuture t₁ t₂)`, `(branch, ord.addFuture t₂ t₁)` and
`(branch.identifyTime t₂ t₁, ord.identifyTime t₂ t₁)` — the first two carry the branch
**unchanged**, and the third *identifies two times*, which can only merge signed formulas and so
cannot increase `toFinset.card` either. `findApplicableRule` adds no output-presence guard on
this constructor and says in its own comment why one is impossible: "the arms of an ordered split
are replacement branches, so 'the branch already contains this arm's output' is trivially true of
every arm that adds no formula, which is every arm of the only rule that produces this
constructor."

**Consequence.** There is no `.splitOrdered` analogue of `expandOnceUnblocked_card_lt`, and there
cannot be one: branch cardinality is constant (or decreasing) across an ordered split. What makes
that rule terminate is its own self-suppression — once every pair of known times is comparable
there is no candidate pair and it reports `.notApplicable` — a *comparability* measure on the
ordering, not a cardinality measure on the branch. Any argument that bounds split depth by branch
growth therefore covers `.split` only, and needs a second, order-theoretic measure for
`.splitOrdered`.
-/
theorem applyRule_timeLinearity_arms (sf : SignedFormula) (b : Branch) (ord : TimeOrdering)
    (bs : List (Branch × TimeOrdering))
    (h : (applyRule .timeLinearity sf b ord).1 = RuleResult.branchingOrdered bs) :
    ∃ t₁ t₂, bs = [ (b, ord.addFuture t₁ t₂)
                  , (b, ord.addFuture t₂ t₁)
                  , (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁) ] := by
  cases sf with
  | mk sign formula label =>
    simp only [applyRule] at h
    rcases hp : firstIncomparablePair b ord with _ | ⟨t₁, t₂⟩
    · rw [hp] at h; simp at h
    · rw [hp] at h
      exact ⟨t₁, t₂, by simpa using h.symm⟩

/-! ### The identification arm, and the lexicographic measure

`applyRule .timeLinearity`'s third arm rewrites both the branch and the ordering. What the measure
uses of it is only the *branch* half: identification retires one time outright, so the first
component of the measure strictly drops and the arm is discharged there.

**`timeLinearity` is the only rule producing `.branchingOrdered`** — `applyRule`'s
`.timeLinearity` case (`Tableau.lean:1513-1520`) is its sole construction site, and
`findApplicableRule`'s own `.branchingOrdered` arm records the same fact ("the only rule that
produces this constructor"). So the decrease theorem below covers every ordered split the engine
can take. -/

/-- The trigger-carrying strengthening of `applyRule_timeLinearity_arms`: the same three arms,
plus the `firstIncomparablePair` equation that produced them. The landed lemma is left untouched;
this is additive, and it is what lets the arm-3 case read off the trigger's own guarantees. -/
theorem applyRule_timeLinearity_arms_trigger (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bs : List (Branch × TimeOrdering))
    (h : (applyRule .timeLinearity sf b ord).1 = RuleResult.branchingOrdered bs) :
    ∃ t₁ t₂, firstIncomparablePair b ord = some (t₁, t₂) ∧
      bs = [ (b, ord.addFuture t₁ t₂)
           , (b, ord.addFuture t₂ t₁)
           , (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁) ] := by
  cases sf with
  | mk sign formula label =>
    simp only [applyRule] at h
    rcases hp : firstIncomparablePair b ord with _ | ⟨t₁, t₂⟩
    · rw [hp] at h; simp at h
    · rw [hp] at h
      exact ⟨t₁, t₂, rfl, by simpa using h.symm⟩

/-- Identification retires `src`: nothing is left carrying it. -/
theorem src_not_mem_knownTimes_identifyTime (b : Branch) (src tgt : TimeIndex)
    (h : src ≠ tgt) : src ∉ (b.identifyTime src tgt).knownTimes := by
  simp only [Branch.knownTimes, Branch.identifyTime, List.mem_eraseDups, List.mem_map]
  rintro ⟨sf, hsf, hsfeq⟩
  obtain ⟨sf0, -, rfl⟩ := hsf
  by_cases hc : sf0.label.time = src
  · simp [hc] at hsfeq; exact h hsfeq.symm
  · simp [hc] at hsfeq

/-- Identification introduces no new times, provided the target was already known. -/
theorem knownTimes_identifyTime_subset {b : Branch} {src tgt : TimeIndex}
    (h : tgt ∈ b.knownTimes) :
    ∀ t ∈ (b.identifyTime src tgt).knownTimes, t ∈ b.knownTimes := by
  intro t ht
  simp only [Branch.knownTimes, Branch.identifyTime, List.mem_eraseDups, List.mem_map] at ht ⊢
  obtain ⟨sf, ⟨sf0, hsf0, rfl⟩, rfl⟩ := ht
  by_cases hc : sf0.label.time = src
  · simp only [hc, beq_self_eq_true, if_pos]
    simpa [Branch.knownTimes, List.mem_eraseDups, List.mem_map] using h
  · simp only [beq_iff_eq, hc, if_neg, not_false_iff]
    exact ⟨sf0, hsf0, rfl⟩

/-- **The measure's first component strictly drops at the identification arm.** No new times, and
one old one retired. -/
theorem knownTimes_card_lt_identifyTime {b : Branch} {t₁ t₂ : TimeIndex}
    (h1 : t₁ ∈ b.knownTimes) (h2 : t₂ ∈ b.knownTimes) (hne : t₂ ≠ t₁) :
    ((b.identifyTime t₂ t₁).knownTimes).toFinset.card < (b.knownTimes).toFinset.card := by
  refine Finset.card_lt_card ⟨?_, fun hcon => ?_⟩
  · intro t ht
    rw [List.mem_toFinset] at ht ⊢
    exact knownTimes_identifyTime_subset h1 t ht
  · exact src_not_mem_knownTimes_identifyTime b t₂ t₁ hne
      (List.mem_toFinset.mp (hcon (List.mem_toFinset.mpr h2)))

/--
**The `.splitOrdered` progress measure**, lexicographic in `(|knownTimes|, |incomparable pairs|)`.

This is the direct replacement for the refuted branch-cardinality route (see the do-not-re-attempt
register): branch cardinality is monotone-*non-increasing* across an ordered split — arm 3 merges
signed formulas — so it cannot bound ordered-split depth. The lexicographic pair can, because the
two arms that leave the branch alone strictly shrink the ordering's incomparability, and the arm
that rewrites the ordering strictly shrinks the branch's time set.

**Why there is no missing fact about `identifyTime`'s output ordering.** A reader looking for a
proof that `TimeOrdering.identifyTime`'s constraint substitution preserves comparability of the
surviving times will not find one, and should not go looking: arm 3 is discharged *entirely* on
the first component. Nothing anywhere in this development needs to know what the rewritten
ordering looks like. That is the whole point of making the measure lexicographic rather than
trying to run the incomparable-pair count across all three arms.

**Scope.** The measure bounds ordered-split depth *between fresh-time mints*, not globally:
`.split` can mint fresh times and so raise the first component. See the split-aware fuel figure
for how that residual is carried (`hT`) rather than hidden.
-/
def splitOrderedMeasure (b : Branch) (ord : TimeOrdering) : Nat × Nat :=
  (b.knownTimes.toFinset.card, (incompPairs b ord).card)

/--
**The measure strictly decreases at every arm of an ordered split.**

Arms 1 and 2 (`addFuture`) keep the branch literally unchanged, so the first component is equal
and the second strictly drops (`incompPairs_lt_addFuture`); arm 3 (`identifyTime`) drops the
first component outright (`knownTimes_card_lt_identifyTime`). Since `timeLinearity` is the only
producer of `.branchingOrdered`, this covers every ordered split the engine takes.
-/
theorem splitOrderedMeasure_lt_of_timeLinearity (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bs : List (Branch × TimeOrdering))
    (h : (applyRule .timeLinearity sf b ord).1 = RuleResult.branchingOrdered bs) :
    ∀ p ∈ bs, Prod.Lex (· < ·) (· < ·)
      (splitOrderedMeasure p.1 p.2) (splitOrderedMeasure b ord) := by
  obtain ⟨t₁, t₂, htrig, rfl⟩ := applyRule_timeLinearity_arms_trigger sf b ord bs h
  obtain ⟨hm1, hm2, hne, -, -⟩ := firstIncomparablePair_spec htrig
  obtain ⟨hlt1, hlt2⟩ := incompPairs_lt_addFuture htrig
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact Prod.Lex.right _ hlt1
  · exact Prod.Lex.right _ hlt2
  · exact Prod.Lex.left _ _ (knownTimes_card_lt_identifyTime hm1 hm2 hne)

set_option maxHeartbeats 1600000 in
/-- **Split arity, attempted.** Every `.branching` result of every rule has at most three arms. -/
theorem applyRule_branching_arity_le (rule : TableauRule) (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bss : List (List SignedFormula))
    (h : (applyRule rule sf b ord).1 = RuleResult.branching bss) :
    bss.length ≤ 3 := by
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      simp only [applyRule] at h <;>
      (repeat' split at h) <;>
      (try simp_all) <;>
      (try subst h) <;>
      (try simp) <;>
      (try omega)

/--
**Split arity, proved: `β = 3` is a theorem, not a census.**

Every `.split` reported by the engine's step has at most three arms. The route is the same
three-stage pick destructuring `expandOnceUnblocked_pick_ne_nil` uses: whichever stage supplied
the rule, its extraction lemma turns the pick back into an `applyRule` equation, and
`applyRule_branching_arity_le` bounds the arms there.

**This does not license baking `3` in anywhere.** `splitBudget_preserved` and the lemmas around
it still carry `β` as a hypothesis, deliberately: a rule added later could return four arms, and
the point of carrying the coefficient is that such a rule would break exactly one lemma — this
one — rather than silently invalidating everything stated at the literal.
-/
theorem expandOnceUnblocked_split_arity_le {b : Branch} {bs : List Branch} {ord : TimeOrdering}
    {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs) :
    bs.length ≤ 3 := by
  unfold expandOnceUnblocked at h
  obtain ⟨r, bss, o, hpick, rfl⟩ := pick_split h
  rw [List.length_map]
  rcases hfu : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  · rw [hfu] at hpick
    rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                             && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
    · rw [hser] at hpick
      rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
      · rw [hlin] at hpick; simp at hpick
      · rw [hlin] at hpick
        simp only at hpick
        exact applyRule_branching_arity_le r sf3 b ord bss
          (findApplicableLinearityRule_applyRule_eq hpick)
    · rw [hser] at hpick
      simp only at hpick
      exact applyRule_branching_arity_le r sf2 b ord bss
        (findApplicableSerialRule_applyRule_eq hpick)
  · rw [hfu] at hpick
    simp only at hpick
    exact applyRule_branching_arity_le r sf b ord bss
      (findApplicableRule_applyRule_eq hpick)

/-! ### 4.3d(ii) — the arm's fuel allocation, from below

`allocateFuelProportionally_pos` gives each arm at least one unit. That is enough for
non-degeneracy and not enough for progress: re-establishing `U.card < nb.toFinset.card + alloc`
at an arm needs `alloc` bounded below by a *figure*, not by `1`. The bound below is that figure,
and it is exactly as good as the hypothesis relating the parent's fuel to the arms' total
difficulty.
-/

/-- Every branch has difficulty at least one: `estimateBranchDifficulty` is `1 + …`, so no arm is
weighted out of the allocation entirely. -/
theorem estimateBranchDifficulty_pos (b : Branch) : 1 ≤ estimateBranchDifficulty b := by
  simp only [estimateBranchDifficulty]
  omega

/-- A `foldl (· + ·)` over `Nat` is at least its seed. -/
private theorem foldl_add_le_self : ∀ (l : List Nat) (a : Nat), a ≤ l.foldl (· + ·) a := by
  intro l
  induction l with
  | nil => intro a; simp
  | cons x xs ih =>
    intro a
    simp only [List.foldl_cons]
    exact le_trans (Nat.le_add_right a x) (ih (a + x))

/-- A member of a `Nat` list is at most the list's `foldl (· + ·) 0`. Stated against `foldl`
rather than `List.sum` because that is the form `allocateFuelProportionally` uses. -/
private theorem le_foldl_add : ∀ (l : List Nat) (a d : Nat), d ∈ l → d ≤ l.foldl (· + ·) a := by
  intro l
  induction l with
  | nil => intro a d h; cases h
  | cons x xs ih =>
    intro a d h
    simp only [List.foldl_cons]
    rcases List.mem_cons.mp h with rfl | h
    · exact le_trans (Nat.le_add_left d a) (foldl_add_le_self xs (a + d))
    · exact ih (a + x) d h

/--
**Every arm's fuel allocation is at least `m`**, provided the parent's fuel covers `m` copies of
the arms' total difficulty and `m` fits under the termination cap.

The two hypotheses are exactly the two ways the allocation can fall short. `hT` is the
proportional-share condition: an arm of difficulty `d ≥ 1` out of a total `T` receives
`(fuel+1) * d / T ≥ (fuel+1) / T`, and `T * m ≤ fuel + 1` is precisely what makes that at least
`m`. `hm` is the termination cap: the allocation is `min … fuel`, so nothing above `fuel` is
obtainable no matter how favourable the proportion.

This is the lower bound `allocateFuelProportionally_pos` is the `m = 1` case of, and it is what a
split-aware progress argument has to consume.
-/
theorem allocateFuelProportionally_ge (fuel : Nat) (branches : List Branch) (m n : Nat)
    (hm : m ≤ fuel)
    (hT : ((branches.map estimateBranchDifficulty).foldl (· + ·) 0) * m ≤ fuel + 1)
    (h : n ∈ allocateFuelProportionally (fuel + 1) branches) : m ≤ n := by
  simp only [allocateFuelProportionally] at h
  rw [List.mem_map] at h
  obtain ⟨d, hd, rfl⟩ := h
  set T := (branches.map estimateBranchDifficulty).foldl (· + ·) 0 with hTdef
  -- every difficulty is at least one, so the total is at least the arm's own difficulty
  obtain ⟨b0, _, rfl⟩ := List.mem_map.mp hd
  have hd1 : 1 ≤ estimateBranchDifficulty b0 := estimateBranchDifficulty_pos b0
  have hdT : estimateBranchDifficulty b0 ≤ T := le_foldl_add _ 0 _ hd
  have hT1 : 1 ≤ T := le_trans hd1 hdT
  have hmax : max 1 T = T := Nat.max_eq_right hT1
  refine Nat.le_min.mpr ⟨?_, hm⟩
  refine le_trans ?_ (Nat.le_max_right 1 _)
  rw [hmax]
  refine Nat.le_div_iff_mul_le (by omega) |>.mpr ?_
  calc m * T = T * m := Nat.mul_comm _ _
    _ ≤ fuel + 1 := hT
    _ = (fuel + 1) * 1 := by omega
    _ ≤ (fuel + 1) * estimateBranchDifficulty b0 := Nat.mul_le_mul_left _ hd1

/--
**The total difficulty of a split, bounded by arity and a per-arm difficulty bound.**

This is what makes `allocateFuelProportionally_ge`'s hypothesis `T * m ≤ fuel + 1`
dischargeable from bounded quantities rather than from an unbounded one: `T ≤ D * β`, where `β`
bounds the arity and `D` bounds any single arm's difficulty.

**Why `D` is carried abstractly rather than computed.** `estimateBranchDifficulty` is
`1 + 3 * tempCount + 2 * modCount + len / 4`, and both counting functions (`temporalCount`,
`modalCount`) are `private` to `Saturation.lean`, so a finer bound in terms of per-formula
complexity cannot be *stated* from this file without changing their visibility — a change to an
existing declaration, which this addition deliberately does not make. `D` is therefore the
interface: a caller that can bound one arm's difficulty gets the total, and `estimateBranchDifficulty`
is monotone enough in branch content that such a bound follows from a universe bound.
-/
theorem totalDifficulty_le (branches : List Branch) (D : Nat)
    (hD : ∀ b ∈ branches, estimateBranchDifficulty b ≤ D) :
    (branches.map estimateBranchDifficulty).foldl (· + ·) 0 ≤ D * branches.length := by
  have gen : ∀ (l : List Branch) (a : Nat), (∀ b ∈ l, estimateBranchDifficulty b ≤ D) →
      (l.map estimateBranchDifficulty).foldl (· + ·) a ≤ a + D * l.length := by
    intro l
    induction l with
    | nil => intro a _; simp
    | cons x xs ih =>
      intro a hx
      have h1 : estimateBranchDifficulty x ≤ D := hx x (List.mem_cons_self ..)
      have h2 := ih (a + estimateBranchDifficulty x)
        (fun b hb => hx b (List.mem_cons_of_mem _ hb))
      simp only [List.map_cons, List.foldl_cons, List.length_cons]
      have : D * (xs.length + 1) = D * xs.length + D := by ring
      omega
  have := gen branches 0 hD
  omega

/-! ### Arm-fuel probes

The shortfall above is a claim about a `#eval`-able function, so it is checked by running it
rather than by reading it — the same discipline as the duality and world-discipline rows.
-/

section SplitFuelProbes

-- Three arms, a thousand units at the parent: each arm receives a *third*, not the whole.
-- This is the shortfall, at the smallest branching factor the rule set produces.
/-- info: [333, 333, 333] -/
#guard_msgs in
#eval allocateFuelProportionally 1000 [([] : Branch), [], []]

-- The floor is real: two units at the parent leave one per arm, never zero.
/-- info: [1, 1] -/
#guard_msgs in
#eval allocateFuelProportionally 2 [([] : Branch), []]

-- And the shortfall compounds: a second split inside an arm leaves a ninth of the original.
/-- info: [111, 111, 111] -/
#guard_msgs in
#eval allocateFuelProportionally 333 [([] : Branch), [], []]

end SplitFuelProbes

/-! ## 4.3e — the general fuel figure `worldFuel'`

`soundFuel'` is the **single-world** figure: `chain_le_soundFuel'` earns it exactly, with no
slack, but only under a label hypothesis `hL` that asks `|worlds| * |times|` to sit under the T2
*time* bound — true only while the run stays in one world. Once any `boxNeg`/`diamondPos` mints a
world, the honest bound is `chain_le_worlds_bounded`'s, and the arithmetic below shows the two
differ by a *squaring*, not a constant: writing `F := soundFuel' φ` and `s := |S|`,

    2 * |C| * ((s + 2 * |C| * 2 ^ (2 * |C|)) * 2 ^ (2 * |C|))  =  F * (s + F)

on the nose, so at the engine's own seed (`buildTableau`'s
`initialBranch = [SignedFormula.neg φ Label.initial]` — one world, one time, so `s = 1`) the
general figure is `F * (F + 1)`. Two figures a squaring apart must not share a name, so
`soundFuel'` is kept frozen — name *and* body — and the general figure gets its own name here.

`s` is deliberately **not** specialised to `1` in the definition: `chain_le_worlds_bounded`
quantifies the seed world set `S` universally, and `chain_le_worldFuel'` has to consume it in that
form. The engine's singleton seed is a fact about one caller, not about the figure.

**Three hypotheses survive into this section and are named in the statements rather than absorbed
into the figure**, because a figure that hid them would let a later dispatch claim a world bound
that assumes itself:

* `WorldWitness` (`hww`) — an *invariant*, not a theorem (see its docstring: deriving it is a
  36-case induction over `applyRule`). `chain_le_worldFuel'` carries it, as `chain_le_worlds_bounded`
  does.
* `NoSplit` — the branching arms are still confined, not discharged.
* `maxBranches` — **quantified**, never the engine default. `buildTableau_isSome` at the default
  `50000` is false at any fuel whatsoever, and nothing here reopens it.
-/

/--
**The general fuel figure**, in the presence of fresh worlds.

By `worldFuel'_eq` this is *definitionally* `chain_le_worlds_bounded`'s right-hand side, so
`chain_le_worldFuel'` is a restatement rather than an estimate. `s` is the seed-world count.

See `soundFuel'` for the single-world figure and the section preamble for why they are two names.
-/
def worldFuel' (φ : Formula) (s : Nat) : Nat :=
  (s + soundFuel' φ) * soundFuel' φ

/--
**The figure is the chain bound, exactly.** Not an estimate: with
`c := |subformulaClosure φ|` and `m := 2 ^ (2 * c)`,

    2 * c * ((s + 2 * c * m) * m) = (2 * c * m) * (s + 2 * c * m) = soundFuel' φ * (s + soundFuel' φ)

by associativity and commutativity alone. This is what lets `chain_le_worldFuel'` consume
`chain_le_worlds_bounded` with no arithmetic slack.
-/
theorem worldFuel'_eq (φ : Formula) (s : Nat) :
    worldFuel' φ s
      = 2 * (FormalSystem.Syntax.subformulaClosure φ).card *
          ((s + 2 * (FormalSystem.Syntax.subformulaClosure φ).card *
              2 ^ (2 * (FormalSystem.Syntax.subformulaClosure φ).card)) *
            2 ^ (2 * (FormalSystem.Syntax.subformulaClosure φ).card)) := by
  simp only [worldFuel', soundFuel']
  exact Nat.mul_left_comm _ _ _

/-- Every formula is in its own subformula closure, so the closure is nonempty and the fuel
figure is positive. -/
theorem soundFuel'_pos (φ : Formula) : 0 < soundFuel' φ := by
  have hn : 0 < (FormalSystem.Syntax.subformulaClosure φ).card :=
    Finset.card_pos.mpr ⟨φ, FormalSystem.Syntax.self_mem_subformulaClosure φ⟩
  simp only [soundFuel']
  exact Nat.mul_pos (by omega) (Nat.pow_pos (by omega))

/-- The general figure dominates the single-world one, so a caller who has budgeted for
`worldFuel'` has budgeted for `soundFuel'` too. -/
theorem soundFuel'_le_worldFuel' (φ : Formula) (s : Nat) : soundFuel' φ ≤ worldFuel' φ s := by
  have hpos : 0 < s + soundFuel' φ := by have := soundFuel'_pos φ; omega
  exact Nat.le_mul_of_pos_left _ hpos

/--
**The chain bound at the named general figure.** `chain_le_worlds_bounded`, restated so that
downstream has a computable `Nat` to hand `expandBranchWithFuel` rather than a five-factor
expression to re-inline.

Hypotheses are unchanged from `chain_le_worlds_bounded` — **including `hww : WorldWitness C S
(run n)`, which is an invariant and is not discharged here** — plus `hφ` identifying the stock's
cardinality with the closure's, which is what turns the bound's `|C|` into `soundFuel' φ`'s `n`.
-/
theorem chain_le_worldFuel' {C : Finset Formula} {S : Finset WorldIndex} {φ : Formula}
    {ord : TimeOrdering} {tracker : EventualityTracker}
    (hC : TableauClosed C) (hT : TrichStock C)
    (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hlin : firstIncomparablePair (run n) ord = none)
    (hev : ∀ t₁ ∈ (run n).knownTimes, ∀ t₂ ∈ (run n).knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime (run n) ord tracker = none)
    (hww : WorldWitness C S (run n))
    (hφ : C.card = (FormalSystem.Syntax.subformulaClosure φ).card) :
    n ≤ worldFuel' φ S.card := by
  have h := chain_le_worlds_bounded (S := S) (ord := ord) (tracker := tracker)
    hC hT run n h0 hstep hlin hev hnb hww
  rw [worldFuel'_eq, ← hφ]
  exact h

/--
**The 4.3 terminus.** `expandBranchWithFuel_isSome_of_stock` instantiated at the general figure.

This is instantiation, not new mathematics: the label-side hypothesis
`|L| ≤ (s + 2*|C|*2^(2|C|)) * 2^(2|C|)` yields `2 * |C| * |L| ≤ worldFuel' φ s` by
`worldFuel'_eq`'s identity, which is exactly what `expandBranchWithFuel_isSome_of_stock`'s
`hfuel` wants.

All three residuals stay visible in the statement, as the section preamble requires: `NoSplit`
confines the branching arms, `maxBranches` is quantified with an explicit budget hypothesis, and
the world dimension enters through the caller's `hL` — which `worldFinset_card_le` supplies only
from a `WorldWitness` the caller must itself provide.
-/
theorem expandBranchWithFuel_isSome_at_worldFuel' {P : Branch → Prop}
    {fc : ProofSystem.FrameClass} {C : Finset Formula} {L : Finset Label} {φ : Formula}
    (hP : NoSplit P fc)
    (hf : ∀ b, P b → ∀ x ∈ b, x.formula ∈ C) (hl : ∀ b, P b → ∀ x ∈ b, x.label ∈ L)
    (s fuel : Nat) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker)
    (applied : AppliedSet) (maxBranches branchesUsed : Nat)
    (hPb : P b)
    (hφ : C.card = (FormalSystem.Syntax.subformulaClosure φ).card)
    (hL : L.card ≤ (s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card))
    (hfuel : worldFuel' φ s < fuel)
    (hbud : branchesUsed + fuel ≤ maxBranches) :
    (expandBranchWithFuel b fuel ord fc tr applied maxBranches branchesUsed).isSome = true := by
  refine expandBranchWithFuel_isSome_of_stock hP hf hl fuel b ord tr applied
    maxBranches branchesUsed hPb ?_ hbud
  have hmul : 2 * C.card * L.card
      ≤ 2 * C.card * ((s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card)) :=
    Nat.mul_le_mul_left _ hL
  have hid : worldFuel' φ s
      = 2 * C.card * ((s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card)) := by
    rw [worldFuel'_eq, hφ]
  omega

end FormalSystem.Metalogic.Decidability

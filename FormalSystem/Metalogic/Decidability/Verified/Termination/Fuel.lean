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

Outstanding, and deliberately not claimed anywhere below:

1. **The label dimension.** `chain_le_stock` takes `∀ x ∈ run n, x.label ∈ L` as a hypothesis.
   Supplying it in general is what `blocking_fires_of_card_lt` (`TimeTypeBound.lean`) is for, but
   that lemma's own `hchain` hypothesis — that the times it counts are totally ordered by
   `ancestorTimes` — is an invariant of the run that nothing yet establishes. It is `timeLinearity`
   that makes the ordering total, so the missing piece is a run-level invariant tying
   `timeLinearity`'s effect to `ancestorTimes`.
2. **The branching arms.** `chain_le_stock` covers `.extended` steps. `expandBranchWithFuel` also
   has `.split` and `.splitOrdered` arms, and its `isSome` in those arms depends on the fold over
   sub-branches, on `resolveOpenArm` (which can report `none`), and on the `branchesUsed >=
   maxBranches` guard.
3. **`buildTableau_isSome` is false as an unconditional statement**, and this is a defect of the
   *statement*, not of the engine. `buildTableau` calls `expandBranchWithFuel` at the default
   `maxBranches := 50000` and returns `none` the moment that counter is hit, no matter how much
   fuel it was given; and its own last arm returns `none` when the branch is still unsaturated
   after the post-blocking pass. Any true form of the theorem has to quantify over `maxBranches`
   (or take the branch budget as a hypothesis) rather than use the default. Recorded here so the
   next dispatch does not spend its budget proving something false.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

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

/--
**The one residual of the label dimension: the two closures are duals.**

`firstIncomparablePair` records comparability as "`t₂` is in `t₁`'s `futureOf`", while
`isTemporallyBlocked` — and hence `blocking_fires_of_card_lt` — reads it as "`t₁` is in `t₂`'s
`ancestorTimes`", which is `pastOf`. The two are the forward and backward transitive closures of
the *same* constraint list, so this holds; it is stated as a hypothesis rather than proved
because proving it is a statement about `TimeOrdering.futureOf`/`pastOf` and nothing else, and it
needs a path characterisation of the breadth-first search those two are defined by.

**Why it is not discharged here, precisely.** `futureOf` and `pastOf` are defined via
`reachableForward` / `reachableBackward` (`SignedFormula.lean:741,751`), which are `private`, so
the induction cannot even be *stated* from this file without either an engine edit — forbidden by
the wave-3 territory contract — or an `open private … from …` import of the two helpers, which is
the route this repository already uses elsewhere for exactly this situation (see
`Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:687`). That is the discharge path, and it is
pure consumption: no engine edit, no re-proof.

The obligation itself is: forward BFS membership yields a constraint path, and backward BFS from
the far end recovers the near end within the same number of layers. Both closures run at the same
default fuel (`100`), so no fuel mismatch is hiding in the statement. The probes below run the
condition on the ordering shapes the engine actually builds.
-/
def OrderDual (ord : TimeOrdering) : Prop :=
  ∀ t₁ t₂ : TimeIndex, t₂ ∈ ord.futureOf t₁ → t₁ ∈ ord.pastOf t₂

/--
**The chain invariant, established.** A branch whose linearity stage is exhausted has all its
times pairwise comparable in the ancestor order.

This is the run-level invariant the T3 residual named: `timeLinearity` fires exactly while an
incomparable pair remains, so its silence *is* the chain condition, and `TimeChain` is what
`blocking_fires_of_card_lt` needs.
-/
theorem timeChain_of_linearity_saturated {b : Branch} {ord : TimeOrdering}
    (hd : OrderDual ord) (h : firstIncomparablePair b ord = none) : TimeChain b ord := by
  intro t₁ h₁ t₂ h₂ hne
  rcases comparable_of_firstIncomparablePair_none h h₁ h₂ (Ne.symm hne) with hfut | hpast
  · exact Or.inl (hd t₁ t₂ hfut)
  · exact Or.inr hpast

/--
**The label dimension, composed.** An unbranched run whose final branch is linearity-saturated and
carries no blocked time is bounded by `2 * |C| * (W * 2 ^ (2 * |C|))`, with `W` the world count.

Every hypothesis here is either discharged elsewhere in this file (`BranchStock`, via T1 iterated)
or is a named, isolated side condition: `OrderDual` (the closure duality above), `hev` (the
eventuality guard, vacuous for the empty tracker), `hnb` (the run has not yet blocked), and `hW`
(the world dimension, whose argument is the S5 fresh-world discipline and is not T3's business).
-/
theorem chain_le_worlds_of_linearity_saturated {C : Finset Formula} {ord : TimeOrdering}
    {tracker : EventualityTracker} {W : Nat}
    (hC : TableauClosed C) (hT : TrichStock C) (hd : OrderDual ord)
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
    (timeChain_of_linearity_saturated hd hlin) hev hnb hW

/-! ### Duality probes

`OrderDual` is a hypothesis, so it is committed together with executable rows that run it on the
ordering shapes the engine builds: a chain (`addFuture` repeated), a fork, a diamond, and a chain
put through `identifyTime` — the one operation that rewrites constraints rather than adding them,
and hence the one most likely to break a duality. A hypothesis nobody has ever evaluated is not
evidence of anything; these rows are what keep it from being a silent assumption.
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
members. The two hypotheses that remain are the same two the module docstring's Status section
lists: `hl` (labels confined) and `hL` (their count at the T2 figure), both of which
`blocking_fires_of_card_lt` exists to supply once the run-level chain invariant is available.
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

end FormalSystem.Metalogic.Decidability

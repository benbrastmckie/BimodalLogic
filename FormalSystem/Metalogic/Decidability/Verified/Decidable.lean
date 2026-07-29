/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.RuleSpec
import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel
import FormalSystem.Semantics.Validity
import FormalSystem.Metalogic.SoundnessLemmas.FrameClassVariants

/-!
# Semantic rule soundness: satisfiability preservation, one rule shape at a time

This module carries the `allClosed → valid` direction of the decision procedure. That direction
is *not* a truth lemma — the truth lemma (`Verified/Bridge/IntTruth.lean`,
`Verified/Bridge/DenseTruth.lean`) runs the other way, turning a saturated **open** branch into a
countermodel. Here the obligation is the contrapositive one: a tableau rule never destroys
satisfiability, so a branch every extension of which closes was unsatisfiable to begin with.

## The satisfiability notion

A branch is a list of signed formulas carrying `Label`s — a `WorldIndex` and a `TimeIndex`, both
`Nat`. The semantics of `Formula` (`FormalSystem/Semantics/Truth.lean`) evaluates at a
*world history* `τ` drawn from a shift-closed admissible set `Ω`, and a *time* `t : D`. So a
branch is satisfied relative to four pieces of data:

* a model `M` over a `TaskFrame D`, and a shift-closed `Ω`;
* an interpretation `hist : WorldIndex → WorldHistory F` of the branch's world labels, landing
  inside `Ω` — this is what makes `□` (which quantifies over `Ω`) reach every branch world;
* an interpretation `tv : TimeIndex → D` of the branch's time labels.

`SatState` bundles those with the two side conditions and the branch itself. The `ordResp` field
is what ties the interpretation to the engine's abstract `TimeOrdering`: every recorded
constraint `(a, b)` must be a genuine strict inequality `tv a < tv b`. Without it a rule that
mints a fresh future time could be "satisfied" by a point in the past, and the successor state
would not be a state of the successor branch the engine actually built.

## The preservation predicate

`applyRule` returns a `RuleResult × TimeOrdering`, so the preservation predicate is stated
against exactly that pair — `SatResult` — rather than against a hand-summarised notion of "the
successor branch". The four `RuleResult` constructors get the four readings the engine gives
them:

* `.linear fs` / `.persistent fs`: the single successor `fs ++ b`. The engine *consumes* the
  source formula on a `.linear` step and *keeps* it on a `.persistent` one; carrying `b` whole in
  both cases is the stronger statement, and it is the one downstream wants, since satisfiability
  passes down to sublists (`SatState.mono`).
* `.branching bss`: **some** arm `br ++ b` is satisfiable. This is the only place the disjunction
  lives, and it is why closing *all* arms is what a closed tableau needs.
* `.branchingOrdered brs`: arms carry their own replacement branch and their own ordering. Only
  `timeLinearity` returns this, and `timeLinearity` is outside `allRulesForFC`
  (`RuleSpec.timeLinearity_not_mem_allRulesForFC`), so no theorem here consumes this arm yet.
* `.notApplicable`: nothing to preserve.

Each successor is allowed to *re-choose* `hist` and `tv`. That is not slack: it is exactly what
the fresh-label rules need. `boxNeg` mints `branch.nextWorld` and must point it at the witness
history; `someFuturePos` mints `branch.nextTime` and must point it at the witness time. Both
indices are absent from `b` (`Tableau.not_mem_of_world_nextWorld`,
`Tableau.not_mem_of_time_nextTime`), so a one-point update leaves the rest of the branch
satisfied. The model `M` and the admissible set `Ω` are *not* re-chosen by any rule.

## `CarrierProp`

`valid`, `ValidDense`, `ValidDiscrete` and `ValidDedekindDense` differ only in the side
conditions they impose on the temporal carrier `D`. `RuleSound` is therefore indexed by a
`CarrierProp` — a property of the carrier — so that the frame-class-gated rules can be stated
with the extra hypothesis they need and the base rules can be stated without one.

Only `carrierBase` is declared here. The dense, discrete and Dedekind carrier properties are
deliberately **not** declared in advance: each will be stated in the same step that proves a rule
consuming it, so that no unconsumed predicate sits in the tree unvalidated. `RuleSound.mono` is
what makes that safe — a rule proved at a weaker carrier property is available at every stronger
one, so the base family never needs restating.

## Status

Landed: the framework; the eight truth-functional rules (`andPos`, `andNeg`, `orPos`, `orNeg`,
`impPos`, `impNeg`, `negPos`, `negNeg`); and the three *label-preserving* modal rules (`boxPos`,
`diamondNeg`, `boxTemporal`).

Also landed: the two fresh-world modal rules `boxNeg` and `diamondPos`, together with the four
temporal *universal* rules and `orderTrichotomy`.

Still owed by sub-phase 7.2: the four fresh-*time* existential rules (`allFutureNeg`,
`allPastNeg`, `someFuturePos`, `somePastPos`); `untlPos`/`untlNeg`/`sncePos`/`snceNeg`; the two
dense, three discrete and three Dedekind rules; and the assembly
`∀ r ∈ allRulesForFC fc, RuleSound _ r` via `RuleSpec.mem_allRulesForFC_iff`.

All six fresh-*time* producers are blocked on a defect in `RuleSound`'s own statement, not on
proof effort: nothing ties `ord`'s times to `b`'s, so `Branch.nextTime` need not be fresh for the
ordering, and the successor's `ordResp` obligation can be outright unsatisfiable. See "The
fresh-time producers' ordering obligation is not discharged by freshness alone" below, and the
two theorems that prove it. Two remedies are priced there; both change a definition the landed
rules are stated against, so both are escalated rather than taken.

`boxNeg` and `diamondPos` were previously held back for a different and now-resolved reason —
see "What `boxNeg` and `diamondPos` owed, and how it was discharged" at the end of this file.

## References

* Report 02 §8.5 Track A (the `allClosed → valid` direction).
* `Verified/RuleSpec.lean` — `mem_allRulesForFC_iff`, the single induction principle the
  assembly will run on, and the exclusion of `serialityRule`/`timeLinearity`.
-/

namespace FormalSystem.Metalogic.Decidability.Verified

open FormalSystem.Syntax
open FormalSystem.Semantics

/-!
## Satisfaction of a signed formula, a branch, and a rule result
-/

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  {F : TaskFrame D}

/--
A signed formula is satisfied by an interpretation when its sign matches the truth value the
model gives its formula at the interpreted label.

`.pos` asserts truth, `.neg` asserts falsity — the two are *not* the truth values of a single
formula and its negation, because a branch is free to leave a formula undecided at a label; it
is only the formulas it actually carries that are constrained.
-/
def SatAt (M : TaskModel F) (Om : Set (WorldHistory F))
    (hist : WorldIndex → WorldHistory F) (tv : TimeIndex → D) (sf : SignedFormula) : Prop :=
  match sf.sign with
  | .pos => TruthAt M Om (hist sf.label.world) (tv sf.label.time) sf.formula
  | .neg => ¬ TruthAt M Om (hist sf.label.world) (tv sf.label.time) sf.formula

/--
An interpretation satisfying a branch together with its abstract time ordering.

The four fields are independent obligations and all four are load-bearing:

* `shiftClosed` — `Ω` is shift-closed. Not a convenience: it is the *only* hypothesis all four
  validity notions impose on `Ω`, and it is what makes `□` behave as the universal modality
  across times as well as histories. `boxTemporal` is unsound without it.
* `histMem` — every branch world lands in `Ω`. `□` quantifies over `Ω`, so without this a
  `T(□A)` on the branch would say nothing about the branch's own other worlds.
* `ordResp` — every recorded ordering constraint is a genuine strict inequality in `D`. This is
  what a fresh-time rule has to re-establish for the *extended* ordering it returns.
* `sat` — every signed formula on the branch is satisfied.
-/
structure SatState (M : TaskModel F) (Om : Set (WorldHistory F))
    (hist : WorldIndex → WorldHistory F) (tv : TimeIndex → D)
    (b : Branch) (ord : TimeOrdering) : Prop where
  /-- The admissible set is shift-closed, as every validity notion requires of it. -/
  shiftClosed : ShiftClosed Om
  /-- Every branch world is interpreted by an admissible history. -/
  histMem : ∀ w, hist w ∈ Om
  /-- Every abstract ordering constraint is a genuine strict inequality. -/
  ordResp : ∀ p ∈ ord.constraints, tv p.1 < tv p.2
  /-- Every signed formula on the branch is satisfied. -/
  sat : ∀ sf ∈ b, SatAt M Om hist tv sf

/-- Satisfiability passes down to sublists: the engine consumes formulas on a `.linear` step, and
the resulting shorter branch is still satisfied by the same interpretation. -/
theorem SatState.mono {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b b' : Branch} {ord : TimeOrdering}
    (h : SatState M Om hist tv b ord) (hsub : ∀ sf ∈ b', sf ∈ b) :
    SatState M Om hist tv b' ord :=
  ⟨h.shiftClosed, h.histMem, h.ordResp, fun sf hsf => h.sat sf (hsub sf hsf)⟩

/-- Build a state on `fs ++ b` from a state on `b` plus satisfaction of each added formula. The
shape every non-branching rule's proof ends in. -/
theorem SatState.append {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula} (h : SatState M Om hist tv b ord)
    (hfs : ∀ sf ∈ fs, SatAt M Om hist tv sf) :
    SatState M Om hist tv (fs ++ b) ord :=
  ⟨h.shiftClosed, h.histMem, h.ordResp, by
    intro sf hsf
    rcases List.mem_append.mp hsf with h' | h'
    · exact hfs sf h'
    · exact h.sat sf h'⟩

/--
What it takes for a rule's output to preserve satisfiability. Stated against `applyRule`'s
actual return type, `RuleResult × TimeOrdering`, so that the ordering a fresh-time rule returns
is part of the obligation rather than an afterthought.

See the module docstring for the reading of each constructor, and in particular for why the
successor is allowed to re-choose `hist` and `tv` but not `M` or `Ω`.
-/
def SatResult (M : TaskModel F) (Om : Set (WorldHistory F)) (b : Branch) :
    RuleResult → TimeOrdering → Prop
  | .linear fs, ord => ∃ hist tv, SatState M Om hist tv (fs ++ b) ord
  | .persistent fs, ord => ∃ hist tv, SatState M Om hist tv (fs ++ b) ord
  | .branching bss, ord => ∃ br ∈ bss, ∃ hist tv, SatState M Om hist tv (br ++ b) ord
  | .branchingOrdered brs, _ => ∃ p ∈ brs, ∃ hist tv, SatState M Om hist tv p.1 p.2
  | .notApplicable, _ => True

/-!
### Discharging `SatResult` against a computed rule output

`applyRule` is a three-discriminant `match`, so in a proof the goal's scrutinee is stuck until
the rule's output is computed. These three lemmas take that computation as their first argument —
in practice a one-line `by simp [applyRule, …]` — and reduce `SatResult` to the obligation the
arm actually carries. Without them every proof below would have to rewrite the goal in place and
then coax the anonymous constructor through a stuck `match`.
-/

/-- Discharge a `.linear` (or, via `satResult_persistent`, `.persistent`) output. -/
theorem satResult_linear {M : TaskModel F} {Om : Set (WorldHistory F)} {b : Branch}
    {res : RuleResult × TimeOrdering} {fs : List SignedFormula} {ord : TimeOrdering}
    (h : res = (.linear fs, ord))
    (hs : ∃ hist tv, SatState M Om hist tv (fs ++ b) ord) :
    SatResult M Om b res.1 res.2 := by
  rw [h]; exact hs

/-- Discharge a `.persistent` output. Same obligation as `.linear`: the source formula stays on
the branch, and `b` is carried whole in both readings. -/
theorem satResult_persistent {M : TaskModel F} {Om : Set (WorldHistory F)} {b : Branch}
    {res : RuleResult × TimeOrdering} {fs : List SignedFormula} {ord : TimeOrdering}
    (h : res = (.persistent fs, ord))
    (hs : ∃ hist tv, SatState M Om hist tv (fs ++ b) ord) :
    SatResult M Om b res.1 res.2 := by
  rw [h]; exact hs

/-- Discharge a `.branching` output by naming the arm that survives. -/
theorem satResult_branching {M : TaskModel F} {Om : Set (WorldHistory F)} {b : Branch}
    {res : RuleResult × TimeOrdering} {bss : List (List SignedFormula)} {ord : TimeOrdering}
    (h : res = (.branching bss, ord))
    (hs : ∃ br ∈ bss, ∃ hist tv, SatState M Om hist tv (br ++ b) ord) :
    SatResult M Om b res.1 res.2 := by
  rw [h]; exact hs

/-!
## Carrier properties and the rule-soundness predicate
-/

/-- A property of the temporal carrier. The four validity notions differ only in which of these
they impose, so indexing `RuleSound` by one lets the frame-class-gated rules carry their own
hypothesis while the base rules carry none. -/
def CarrierProp : Type 1 :=
  (D : Type) → [AddCommGroup D] → [LinearOrder D] → [IsOrderedAddMonoid D] → Prop

/-- The empty carrier property: what a `.Base` rule may assume about `D`, namely nothing beyond
the ordered-group structure every validity notion already binds. -/
def carrierBase : CarrierProp := fun _ => True

/-- Density of the carrier, as the `.Dense` rules consume it. Stated as `DenselyOrdered D`
rather than as an unfolded betweenness statement so that the eventual assembly can discharge it
from `ValidDense`'s own `[DenselyOrdered D]` binder (`Semantics/Validity.lean`) by
`inferInstance`, with no bridging lemma in between.

Declared here but consumed by exactly one rule so far — `densityRule`, the only `.Dense` rule
that mints a time. `denseIndicatorClosure` is the other `.Dense` rule and needs *no* carrier
property: it is proved at `carrierBase` and reused through `RuleSound.mono`. -/
def carrierDense : CarrierProp := fun D => DenselyOrdered D

/-!
### Well-formedness of the `(branch, ordering)` pair

`RuleSound` quantifies over `b` and `ord` independently, and `SatState`'s four fields relate the
times occurring in `ord.constraints` to the times occurring in `b` in none of them. Without a
condition tying the two together the predicate is *false* for every fresh-time producer:
`Branch.nextTime` is a function of the branch alone, so an adversarial `ord` may already record
it, and the successor's `ordResp` obligation then demands a cycle. That is proved below
(`addFuture_nextTime_cycle_unsatisfiable` and its past mirror) rather than argued.

`OrdWithin` is the condition. Two formulations were considered:

* the numeric bound `∀ p ∈ ord.constraints, p.1 < b.nextTime ∧ p.2 < b.nextTime`, and
* the membership condition below.

The numeric bound is **not an inductive invariant of the construction**. It is preserved by 35 of
the 36 `TableauRule` constructors and refuted by the identification arm of `timeLinearity`
(`Tableau.lean`, the `.branchingOrdered` arm), the engine's single non-additive step:
`Branch.identifyTime` *removes* a time from `knownTimes` and so can **lower** `nextTime`, while
`TimeOrdering.identifyTime` carries a constraint mentioning an unrelated larger time through the
substitution unchanged. Concretely, `b = [f₀, f₇]` with `ord = ⟨[(5, 7)]⟩` satisfies the numeric
bound (`nextTime = 8`); the arm identifies `7` with `0`, giving `b'.nextTime = 1` with the
constraint `(5, 0)` surviving.

The membership condition is stable under exactly that operation — every time of
`ord.identifyTime t₂ t₁` is either an unchanged time of `ord` other than `t₂`, or `t₁`, which
survives in the branch — and it is strictly stronger than the numeric bound
(`OrdWithin.bound`), so the fresh-time producers lose nothing.
-/

/-- Every time recorded in the ordering is a time the branch knows.

Discharged at the root by `TimeOrdering.empty` (`OrdWithin.empty`) and preserved by every arm of
`applyRule`. See the section docstring above for why membership rather than a numeric bound. -/
def OrdWithin (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes

/-- A time the branch knows is strictly below the branch's fresh time. -/
theorem lt_nextTime_of_mem_knownTimes {b : Branch} {t : TimeIndex}
    (h : t ∈ b.knownTimes) : t < b.nextTime := by
  simp only [Branch.knownTimes, List.mem_eraseDups, List.mem_map] at h
  obtain ⟨sf, hsf, rfl⟩ := h
  exact Nat.lt_succ_of_le (le_maxTime hsf)

/-- `knownTimes` only grows under the additive branch extension every expansion tail performs. -/
theorem mem_knownTimes_append {b : Branch} {fs : List SignedFormula} {t : TimeIndex}
    (h : t ∈ b.knownTimes) : t ∈ Branch.knownTimes (fs ++ b) := by
  simp only [Branch.knownTimes, List.mem_eraseDups, List.map_append, List.mem_append] at *
  exact Or.inr h

/-- Every branch formula's time is a time the branch knows. The converse direction of
`lt_nextTime_of_mem_knownTimes`'s extraction step, restated for direct use. -/
theorem mem_knownTimes_of_mem_branch {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.time ∈ b.knownTimes := by
  simp only [Branch.knownTimes, List.mem_eraseDups]
  exact List.mem_map_of_mem h

/-- `OrdWithin` implies the numeric bound, so `Branch.nextTime` is fresh *for the ordering* as
well as for the branch. This is the fact a fresh-time producer's one-point update of `tv`
consumes: the new index disturbs no existing `ordResp` obligation. -/
theorem OrdWithin.bound {b : Branch} {ord : TimeOrdering} (h : OrdWithin b ord) :
    ∀ p ∈ ord.constraints, p.1 < b.nextTime ∧ p.2 < b.nextTime := fun p hp =>
  ⟨lt_nextTime_of_mem_knownTimes (h p hp).1, lt_nextTime_of_mem_knownTimes (h p hp).2⟩

/-- Corollary in the form the fresh-time proofs use it: the fresh time is not an endpoint of any
existing constraint. -/
theorem OrdWithin.nextTime_not_mem {b : Branch} {ord : TimeOrdering} (h : OrdWithin b ord)
    {p : TimeIndex × TimeIndex} (hp : p ∈ ord.constraints) :
    p.1 ≠ b.nextTime ∧ p.2 ≠ b.nextTime :=
  ⟨Nat.ne_of_lt (h.bound p hp).1, Nat.ne_of_lt (h.bound p hp).2⟩

/-- The root ordering satisfies the invariant against any branch, vacuously. This is where the
assembly's induction starts (`Saturation.lean`'s root call passes `TimeOrdering.empty`). -/
theorem OrdWithin.empty (b : Branch) : OrdWithin b TimeOrdering.empty := by
  intro p hp
  simp [TimeOrdering.empty] at hp

/-- Additive branch growth preserves the invariant. Every expansion tail in the engine builds
`fs ++ b`, so this covers all four additive `RuleResult` arms. -/
theorem OrdWithin.append {b : Branch} {ord : TimeOrdering} {fs : List SignedFormula}
    (h : OrdWithin b ord) : OrdWithin (fs ++ b) ord := fun p hp =>
  ⟨mem_knownTimes_append (h p hp).1, mem_knownTimes_append (h p hp).2⟩

/--
**Semantic soundness of one tableau rule.** If the branch is satisfied and the rule's source
formula is on it, then the rule's output preserves satisfiability.

Quantifying over *all* `sf`, not only those the rule applies to, is deliberate: `applyRule`
answers `.notApplicable` on a mismatched sign or shape, and `SatResult` reads that as `True`, so
the mismatched cases cost one `simp` each rather than a side condition in the statement.

The `OrdWithin b ord` hypothesis is the well-formedness condition on the `(branch, ordering)`
pair discussed in the section above. It sits **last**, after `SatState`, and that position is
load-bearing rather than stylistic: every rule proof opens with a single positional `intro` line,
so inserting the hypothesis any earlier silently rebinds the `SatState` witness and breaks all of
them at a distance. The rules that leave the ordering untouched — the truth-functional eight, the
label-preserving modal three, the temporal universals, `orderTrichotomy`, and the two
fresh-*world* rules — never consume it; it is exactly the fresh-*time* producers that do.
-/
def RuleSound (C : CarrierProp) (r : TableauRule) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D],
    C D → ∀ (F : TaskFrame D) (M : TaskModel F) (Om : Set (WorldHistory F))
      (hist : WorldIndex → WorldHistory F) (tv : TimeIndex → D)
      (b : Branch) (sf : SignedFormula) (ord : TimeOrdering),
      sf ∈ b → SatState M Om hist tv b ord → OrdWithin b ord →
      SatResult M Om b (applyRule r sf b ord).1 (applyRule r sf b ord).2

/-- A rule sound under a weaker carrier property is sound under a stronger one. This is what lets
the base family be proved once at `carrierBase` and reused verbatim at `.Dense`, `.Discrete` and
`.Dedekind`, and it is why no frame-class carrier property needs declaring until a rule actually
consumes it. -/
theorem RuleSound.mono {C C' : CarrierProp} {r : TableauRule}
    (hle : ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D], C' D → C D)
    (h : RuleSound C r) : RuleSound C' r := by
  intro D _ _ _ _ hC F M Om hist tv b sf ord hmem hst hord
  exact h D (hle D hC) F M Om hist tv b sf ord hmem hst hord

/-!
## Shape inversion for the propositional decomposers

`asAnd?`, `asOr?` and `asNeg?` recognise the derived connectives, which are `imp`/`bot` terms.
Each proof below needs the formula's shape back out of a `some` answer, and reading it off the
`match` in place is what these three lemmas save.
-/

/-- `A ∧ B` is `¬(A → ¬B)`. -/
theorem asAnd?_eq_some {φ ψ χ : Formula} (h : asAnd? φ = some (ψ, χ)) :
    φ = .imp (.imp ψ (.imp χ .bot)) .bot := by
  unfold asAnd? at h
  split at h <;> simp_all

/-- `A ∨ B` is `¬A → B`. -/
theorem asOr?_eq_some {φ ψ χ : Formula} (h : asOr? φ = some (ψ, χ)) :
    φ = .imp (.imp ψ .bot) χ := by
  unfold asOr? at h
  split at h <;> simp_all

/-- `¬A` is `A → ⊥`. -/
theorem asNeg?_eq_some {φ ψ : Formula} (h : asNeg? φ = some ψ) : φ = .imp ψ .bot := by
  unfold asNeg? at h
  split at h <;> simp_all

/-!
## The truth-functional family

All eight rules decompose a formula whose semantics is a truth function of its parts, so all
eight proofs are the same three moves: unfold `TruthAt` at the `imp`/`bot` skeleton the derived
connective expands to, read the truth value off the sign, and hand the same interpretation back.
No rule in this family mints a label, touches the ordering, or looks at the branch, which is why
`hist`, `tv` and `ord` pass through untouched in every one of them.

The classical steps are genuine: `F(A ∧ B)` yields `F(A)` **or** `F(B)` only classically, and
likewise `T(A ∨ B)`, `T(A → B)` and the two negation rules.
-/

/-- `T(A ∧ B) → T(A), T(B)`. -/
theorem ruleSound_andPos : RuleSound carrierBase .andPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asAnd? φ with
    | none => simp [applyRule, hA, SatResult]
    | some p =>
      obtain ⟨ψ, χ⟩ := p
      have hφ : φ = .imp (.imp ψ (.imp χ .bot)) .bot := asAnd?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ, TruthAt] at hsrc
      have hψ : TruthAt M Om (hist l.world) (tv l.time) ψ := by
        by_contra hc; exact hsrc fun h _ => hc h
      have hχ : TruthAt M Om (hist l.world) (tv l.time) χ := by
        by_contra hc; exact hsrc fun _ h => hc h
      refine satResult_linear (fs := [SignedFormula.pos ψ l, SignedFormula.pos χ l]) (ord := ord)
        (by simp [applyRule, hA]) ⟨hist, tv, hst.append ?_⟩
      intro g hg
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl | rfl
      · exact hψ
      · exact hχ

/-- `F(A ∧ B) → F(A) | F(B)`. -/
theorem ruleSound_andNeg : RuleSound carrierBase .andNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case pos => simp [applyRule, SatResult]
  case neg =>
    cases hA : asAnd? φ with
    | none => simp [applyRule, hA, SatResult]
    | some p =>
      obtain ⟨ψ, χ⟩ := p
      have hφ : φ = .imp (.imp ψ (.imp χ .bot)) .bot := asAnd?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.neg, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ, TruthAt] at hsrc
      have hAB : TruthAt M Om (hist l.world) (tv l.time) ψ →
          TruthAt M Om (hist l.world) (tv l.time) χ → False := by
        by_contra hc; exact hsrc hc
      by_cases hψ : TruthAt M Om (hist l.world) (tv l.time) ψ
      · refine satResult_branching (bss := [[SignedFormula.neg ψ l], [SignedFormula.neg χ l]])
          (ord := ord) (by simp [applyRule, hA])
          ⟨[SignedFormula.neg χ l], by simp, hist, tv, hst.append ?_⟩
        intro g hg
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
        rcases hg with rfl
        exact hAB hψ
      · refine satResult_branching (bss := [[SignedFormula.neg ψ l], [SignedFormula.neg χ l]])
          (ord := ord) (by simp [applyRule, hA])
          ⟨[SignedFormula.neg ψ l], by simp, hist, tv, hst.append ?_⟩
        intro g hg
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
        rcases hg with rfl
        exact hψ

/-- `T(A ∨ B) → T(A) | T(B)`. -/
theorem ruleSound_orPos : RuleSound carrierBase .orPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asOr? φ with
    | none => simp [applyRule, hA, SatResult]
    | some p =>
      obtain ⟨ψ, χ⟩ := p
      have hφ : φ = .imp (.imp ψ .bot) χ := asOr?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ, TruthAt] at hsrc
      by_cases hψ : TruthAt M Om (hist l.world) (tv l.time) ψ
      · refine satResult_branching (bss := [[SignedFormula.pos ψ l], [SignedFormula.pos χ l]])
          (ord := ord) (by simp [applyRule, hA])
          ⟨[SignedFormula.pos ψ l], by simp, hist, tv, hst.append ?_⟩
        intro g hg
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
        rcases hg with rfl
        exact hψ
      · refine satResult_branching (bss := [[SignedFormula.pos ψ l], [SignedFormula.pos χ l]])
          (ord := ord) (by simp [applyRule, hA])
          ⟨[SignedFormula.pos χ l], by simp, hist, tv, hst.append ?_⟩
        intro g hg
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
        rcases hg with rfl
        exact hsrc hψ

/-- `F(A ∨ B) → F(A), F(B)`. -/
theorem ruleSound_orNeg : RuleSound carrierBase .orNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case pos => simp [applyRule, SatResult]
  case neg =>
    cases hA : asOr? φ with
    | none => simp [applyRule, hA, SatResult]
    | some p =>
      obtain ⟨ψ, χ⟩ := p
      have hφ : φ = .imp (.imp ψ .bot) χ := asOr?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.neg, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ, TruthAt] at hsrc
      have hψ : ¬ TruthAt M Om (hist l.world) (tv l.time) ψ := by
        intro hc; exact hsrc fun h => absurd hc h
      have hχ : ¬ TruthAt M Om (hist l.world) (tv l.time) χ := fun hc => hsrc fun _ => hc
      refine satResult_linear (fs := [SignedFormula.neg ψ l, SignedFormula.neg χ l]) (ord := ord)
        (by simp [applyRule, hA]) ⟨hist, tv, hst.append ?_⟩
      intro g hg
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl | rfl
      · exact hψ
      · exact hχ

/-- `T(A → B) → F(A) | T(B)`. -/
theorem ruleSound_impPos : RuleSound carrierBase .impPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => cases φ <;> simp [applyRule, SatResult]
  case pos =>
    cases φ with
    | imp ψ χ =>
      have hsrc : SatAt M Om hist tv ⟨.pos, Formula.imp ψ χ, l⟩ := hst.sat _ hmem
      simp only [SatAt, TruthAt] at hsrc
      by_cases hψ : TruthAt M Om (hist l.world) (tv l.time) ψ
      · refine satResult_branching (bss := [[SignedFormula.neg ψ l], [SignedFormula.pos χ l]])
          (ord := ord) (by simp [applyRule])
          ⟨[SignedFormula.pos χ l], by simp, hist, tv, hst.append ?_⟩
        intro g hg
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
        rcases hg with rfl
        exact hsrc hψ
      · refine satResult_branching (bss := [[SignedFormula.neg ψ l], [SignedFormula.pos χ l]])
          (ord := ord) (by simp [applyRule])
          ⟨[SignedFormula.neg ψ l], by simp, hist, tv, hst.append ?_⟩
        intro g hg
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
        rcases hg with rfl
        exact hψ
    | _ => simp [applyRule, SatResult]

/-- `F(A → B) → T(A), F(B)`. -/
theorem ruleSound_impNeg : RuleSound carrierBase .impNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case pos => cases φ <;> simp [applyRule, SatResult]
  case neg =>
    cases φ with
    | imp ψ χ =>
      have hsrc : SatAt M Om hist tv ⟨.neg, Formula.imp ψ χ, l⟩ := hst.sat _ hmem
      simp only [SatAt, TruthAt] at hsrc
      have hψ : TruthAt M Om (hist l.world) (tv l.time) ψ := by
        by_contra hc; exact hsrc fun h => absurd h hc
      have hχ : ¬ TruthAt M Om (hist l.world) (tv l.time) χ := fun hc => hsrc fun _ => hc
      refine satResult_linear (fs := [SignedFormula.pos ψ l, SignedFormula.neg χ l]) (ord := ord)
        (by simp [applyRule]) ⟨hist, tv, hst.append ?_⟩
      intro g hg
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl | rfl
      · exact hψ
      · exact hχ
    | _ => simp [applyRule, SatResult]

/-- `T(¬A) → F(A)`. -/
theorem ruleSound_negPos : RuleSound carrierBase .negPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asNeg? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = .imp ψ .bot := asNeg?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ, TruthAt] at hsrc
      refine satResult_linear (fs := [SignedFormula.neg ψ l]) (ord := ord)
        (by simp [applyRule, hA]) ⟨hist, tv, hst.append ?_⟩
      intro g hg
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl
      exact hsrc

/-- `F(¬A) → T(A)`. -/
theorem ruleSound_negNeg : RuleSound carrierBase .negNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case pos => simp [applyRule, SatResult]
  case neg =>
    cases hA : asNeg? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = .imp ψ .bot := asNeg?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.neg, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ, TruthAt] at hsrc
      have hψ : TruthAt M Om (hist l.world) (tv l.time) ψ := by
        by_contra hc; exact hsrc fun h => absurd h hc
      refine satResult_linear (fs := [SignedFormula.pos ψ l]) (ord := ord)
        (by simp [applyRule, hA]) ⟨hist, tv, hst.append ?_⟩
      intro g hg
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl
      exact hψ

/-!
## The S5 modal family

`□` quantifies over the admissible set `Ω`, and `SatState.histMem` puts every branch world inside
`Ω`. That is the whole content of the two *universal* modal rules: `boxPos` reads `T(□A)` at one
label and asserts `T(A)` at every known world at the same time, and `diamondNeg` does the mirror
image for `F(◇A)`. Neither mints a label, neither touches the ordering, and neither needs
shift-closure.

`boxTemporal` does need shift-closure, and it is the first rule here that does. `T(□A) → T(GA)`
is not a modal-logic step at all: it holds because `Ω` shift-closed makes `□` reach across
*times* as well as histories, which is the semantic content of the `modal_future` (MF) axiom the
rule declares as its grounding (`RuleSpec.ruleAxioms`).
-/

/-- `◇A` is `¬□¬A`. -/
theorem asDiamond?_eq_some {φ ψ : Formula} (h : asDiamond? φ = some ψ) :
    φ = .imp (.box (.imp ψ .bot)) .bot := by
  unfold asDiamond? at h
  split at h <;> simp_all

/--
**Shift-closure carries `□` into `G`.** If `A` holds at time `t` in every admissible history, it
holds at every *later* time of any one admissible history.

The witness is the shifted history `τ ⊕ (s - t)`, admissible by shift-closure, at which truth at
`t` is truth at `s` in `τ` (`TimeShift.time_shift_preserves_truth`). This is the point form of
`Metalogic.Soundness.modal_future_valid`, which states the same fact as the validity of
`□A → □(GA)`; it is derived here from the same primitive rather than imported, so that the
decidability tree acquires no import edge into the soundness tree.
-/
theorem truthAt_allFuture_of_box {M : TaskModel F} {Om : Set (WorldHistory F)}
    (hsc : ShiftClosed Om) {τ : WorldHistory F} (hτ : τ ∈ Om) {t : D} {ψ : Formula}
    (h : ∀ σ ∈ Om, TruthAt M Om σ t ψ) : TruthAt M Om τ t ψ.allFuture := by
  rw [Truth.future_iff]
  intro s _
  exact (TimeShift.time_shift_preserves_truth M Om hsc τ t s ψ).mp
    (h (WorldHistory.timeShift τ (s - t)) (hsc τ hτ (s - t)))

/-- **Shift-closure carries `□` into `H`.** The past mirror of `truthAt_allFuture_of_box`; the
shift argument is insensitive to the direction of the inequality, so the two proofs differ only
in which characterisation lemma they open with. -/
theorem truthAt_allPast_of_box {M : TaskModel F} {Om : Set (WorldHistory F)}
    (hsc : ShiftClosed Om) {τ : WorldHistory F} (hτ : τ ∈ Om) {t : D} {ψ : Formula}
    (h : ∀ σ ∈ Om, TruthAt M Om σ t ψ) : TruthAt M Om τ t ψ.allPast := by
  rw [Truth.past_iff]
  intro s _
  exact (TimeShift.time_shift_preserves_truth M Om hsc τ t s ψ).mp
    (h (WorldHistory.timeShift τ (s - t)) (hsc τ hτ (s - t)))

/-- `T(□A) → T(A)` at every known world, same time. Persistent: the source stays. -/
theorem ruleSound_boxPos : RuleSound carrierBase .boxPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => cases φ <;> simp [applyRule, SatResult]
  case pos =>
    cases φ with
    | box ψ =>
      have hsrc : SatAt M Om hist tv ⟨.pos, Formula.box ψ, l⟩ := hst.sat _ hmem
      simp only [SatAt, TruthAt] at hsrc
      simp only [applyRule]
      split
      · trivial
      · refine ⟨hist, tv, hst.append ?_⟩
        intro g hg
        rw [List.mem_filterMap] at hg
        obtain ⟨w, _, hw⟩ := hg
        split at hw
        · exact absurd hw (by simp)
        · rw [Option.some.injEq] at hw
          subst hw
          exact hsrc (hist w) (hst.histMem w)
    | _ => simp [applyRule, SatResult]

/-- `F(◇A) → F(A)` at every known world, same time. The mirror of `boxPos`: `F(◇A)` is
`T(□¬A)` after unfolding `◇`, so the same `histMem` step does the work. -/
theorem ruleSound_diamondNeg : RuleSound carrierBase .diamondNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case pos => simp [applyRule, SatResult]
  case neg =>
    cases hA : asDiamond? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = .imp (.box (.imp ψ .bot)) .bot := asDiamond?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.neg, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ, TruthAt] at hsrc
      have hbox : ∀ σ ∈ Om, TruthAt M Om σ (tv l.time) ψ → False := by
        by_contra hc
        exact hsrc hc
      simp only [applyRule, hA]
      split
      · trivial
      · refine ⟨hist, tv, hst.append ?_⟩
        intro g hg
        rw [List.mem_filterMap] at hg
        obtain ⟨w, _, hw⟩ := hg
        split at hw
        · exact absurd hw (by simp)
        · rw [Option.some.injEq] at hw
          subst hw
          exact hbox (hist w) (hst.histMem w)

/-- `T(□A) → T(GA), T(HA)` at the same label. The one rule in this family that consumes
shift-closure, via `truthAt_allFuture_of_box` and `truthAt_allPast_of_box`. -/
theorem ruleSound_boxTemporal : RuleSound carrierBase .boxTemporal := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => cases φ <;> simp [applyRule, SatResult]
  case pos =>
    cases φ with
    | box ψ =>
      have hsrc : SatAt M Om hist tv ⟨.pos, Formula.box ψ, l⟩ := hst.sat _ hmem
      simp only [SatAt, TruthAt] at hsrc
      have hG : TruthAt M Om (hist l.world) (tv l.time) ψ.allFuture :=
        truthAt_allFuture_of_box hst.shiftClosed (hst.histMem l.world) hsrc
      have hH : TruthAt M Om (hist l.world) (tv l.time) ψ.allPast :=
        truthAt_allPast_of_box hst.shiftClosed (hst.histMem l.world) hsrc
      simp only [applyRule]
      split
      · trivial
      · refine ⟨hist, tv, hst.append ?_⟩
        intro g hg
        rw [List.mem_filter] at hg
        have hg' := hg.1
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hg'
        rcases hg' with rfl | rfl
        · exact hG
        · exact hH
    | _ => simp [applyRule, SatResult]

/-!
## The two fresh-world modal rules

`boxNeg` and `diamondPos` mint `branch.nextWorld` and point it at a witness history. Both return
`timeOrd` **unchanged**, which is what keeps them clear of the fresh-*time* ordering gap recorded
above: the only field of `SatState` they have to re-establish by a new argument is `sat`, and the
re-choice they make is of `hist`, at a single world index absent from the branch
(`Tableau.not_mem_of_world_nextWorld`).

Each emits the same three groups: the witness, every `T(□B)` on the branch relabelled to the
fresh world, and every `F(◇B)` likewise. Groups two and three are sound because `□` quantifies
over `Ω` and not over the branch's worlds — `T(□B) @ (w', t')` says `B` holds at `t'` in *every*
admissible history, so it says it of the witness history too, whatever world index that history
is filed under. The two helpers below prove exactly that, once, since both rules emit the two
lists verbatim.

A third group used to be emitted — six blocks copying `T(Gφ)`, `T(Hφ)`, `F(Fφ)`, `F(Pφ)`,
`F(U ..)` and `F(S ..)` from the trigger's time into the fresh world — and it was unsound, for
the reason `applyRule`'s docstring now records: a temporal formula is evaluated along *one*
history, which is precisely what `□`/`◇` quantify over. It was removed from the engine, and its
removal is what makes the two theorems below true. They are not provable against the calculus as
it stood before that removal.
-/

/-- Everything the fresh-world rules propagate out of a `T(□B)` on the branch is satisfied at the
fresh world, whichever admissible history is filed there. -/
theorem satAt_of_mem_boxProps {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {σ : WorldHistory F} (hσ : σ ∈ Om)
    {w : WorldIndex} {g : SignedFormula}
    (hg : g ∈ b.boxPosFormulas.filterMap fun bsf =>
      match bsf.formula with
      | .box inner =>
        let prop := SignedFormula.pos inner { world := w, time := bsf.label.time }
        if b.contains prop then none else some prop
      | _ => none) :
    SatAt M Om (Function.update hist w σ) tv g := by
  obtain ⟨bsf, hbsf, hw⟩ := List.mem_filterMap.mp hg
  have hmem : bsf ∈ b := List.mem_of_mem_filter hbsf
  have hpred := List.of_mem_filter hbsf
  have hshape : bsf.sign = .pos ∧ ∃ inner, bsf.formula = .box inner := by
    cases hbs : bsf.sign <;> cases hbf : bsf.formula <;> simp_all
  obtain ⟨hsign, inner, hbf⟩ := hshape
  rw [hbf] at hw
  simp only at hw
  by_cases hc : b.contains (SignedFormula.pos inner { world := w, time := bsf.label.time }) = true
  · rw [if_pos hc] at hw; exact absurd hw (by simp)
  · rw [if_neg hc] at hw
    have hsrc : SatAt M Om hist tv bsf := hst.sat _ hmem
    rw [SatAt, hsign, hbf] at hsrc
    simp only [TruthAt] at hsrc
    rw [← Option.some_inj.mp hw]
    simpa [SatAt, SignedFormula.pos] using hsrc σ hσ

/-- The `F(◇B)` mirror of `satAt_of_mem_boxProps`. `F(◇B)` is `T(□¬B)` once `◇` is unfolded, so
the same `Ω`-quantification does the work, with the sign flipped. -/
theorem satAt_of_mem_diaProps {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {σ : WorldHistory F} (hσ : σ ∈ Om)
    {w : WorldIndex} {g : SignedFormula}
    (hg : g ∈ b.diamondNegFormulas.filterMap fun dsf =>
      match dsf.formula with
      | .imp (.box (.imp inner .bot)) .bot =>
        let prop := SignedFormula.neg inner { world := w, time := dsf.label.time }
        if b.contains prop then none else some prop
      | _ => none) :
    SatAt M Om (Function.update hist w σ) tv g := by
  obtain ⟨dsf, hdsf, hw⟩ := List.mem_filterMap.mp hg
  have hmem : dsf ∈ b := List.mem_of_mem_filter hdsf
  have hpred := List.of_mem_filter hdsf
  have hsign : dsf.sign = .neg := by
    cases hbs : dsf.sign
    · rw [hbs] at hpred; exact absurd hpred (by simp)
    · rfl
  split at hw
  · next inner hbf =>
    by_cases hc : b.contains (SignedFormula.neg inner { world := w, time := dsf.label.time }) = true
    · rw [if_pos hc] at hw; exact absurd hw (by simp)
    · rw [if_neg hc] at hw
      have hsrc : SatAt M Om hist tv dsf := hst.sat _ hmem
      rw [SatAt, hsign, hbf] at hsrc
      simp only [TruthAt] at hsrc
      have hbox : ∀ τ ∈ Om, TruthAt M Om τ (tv dsf.label.time) inner → False := by
        by_contra hcon
        exact hsrc hcon
      rw [← Option.some_inj.mp hw]
      simpa [SatAt, SignedFormula.neg] using hbox σ hσ
  · exact absurd hw (by simp)

/-- `F(□A) → F(A)` at a fresh world, plus the two universal propagations. The witness history is
one at which `A` fails, which `F(□A)` supplies directly; it is filed at `branch.nextWorld`, an
index no branch formula mentions, so the rest of the branch is satisfied by the same update. -/
theorem ruleSound_boxNeg : RuleSound carrierBase .boxNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case pos => cases φ <;> simp [applyRule, SatResult]
  case neg =>
    cases φ with
    | box ψ =>
      have hsrc : SatAt M Om hist tv ⟨.neg, Formula.box ψ, l⟩ := hst.sat _ hmem
      simp only [SatAt, TruthAt] at hsrc
      push_neg at hsrc
      obtain ⟨σ, hσ, hσfail⟩ := hsrc
      simp only [applyRule]
      refine ⟨Function.update hist b.nextWorld σ, tv, hst.shiftClosed, ?_, hst.ordResp, ?_⟩
      · intro v
        rcases eq_or_ne v b.nextWorld with rfl | hv
        · simpa using hσ
        · simpa [Function.update_of_ne hv] using hst.histMem v
      · intro g hg
        rcases List.mem_append.mp hg with hnew | hb
        · rcases List.mem_cons.mp hnew with rfl | hrest
          · simpa [SatAt, SignedFormula.neg] using hσfail
          · rcases List.mem_append.mp hrest with hbox | hdia
            · exact satAt_of_mem_boxProps hst hσ hbox
            · exact satAt_of_mem_diaProps hst hσ hdia
        · have hne : g.label.world ≠ b.nextWorld := fun h =>
            (not_mem_of_world_nextWorld h) hb
          simpa only [SatAt, Function.update_of_ne hne] using hst.sat g hb
    | _ => simp [applyRule, SatResult]

/-- `T(◇A) → T(A)` at a fresh world, plus the same two universal propagations. The exact mirror
of `boxNeg`: `T(◇A)` is `F(□¬A)` once `◇` is unfolded, so it supplies a history at which `A`
*holds*, and the two propagation helpers are reused verbatim. -/
theorem ruleSound_diamondPos : RuleSound carrierBase .diamondPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asDiamond? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = .imp (.box (.imp ψ .bot)) .bot := asDiamond?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ, TruthAt] at hsrc
      have hex : ∃ σ ∈ Om, TruthAt M Om σ (tv l.time) ψ := by
        by_contra hcon
        push_neg at hcon
        exact hsrc hcon
      obtain ⟨σ, hσ, hσtrue⟩ := hex
      simp only [applyRule, hA]
      refine ⟨Function.update hist b.nextWorld σ, tv, hst.shiftClosed, ?_, hst.ordResp, ?_⟩
      · intro v
        rcases eq_or_ne v b.nextWorld with rfl | hv
        · simpa using hσ
        · simpa [Function.update_of_ne hv] using hst.histMem v
      · intro g hg
        rcases List.mem_append.mp hg with hnew | hb
        · rcases List.mem_cons.mp hnew with rfl | hrest
          · simpa [SatAt, SignedFormula.pos] using hσtrue
          · rcases List.mem_append.mp hrest with hbox | hdia
            · exact satAt_of_mem_boxProps hst hσ hbox
            · exact satAt_of_mem_diaProps hst hσ hdia
        · have hne : g.label.world ≠ b.nextWorld := fun h =>
            (not_mem_of_world_nextWorld h) hb
          simpa only [SatAt, Function.update_of_ne hne] using hst.sat g hb

/-!
## The ordering bridge: from the recorded edges to the transitive closure

`SatState.ordResp` is stated on `ord.constraints` — the *edges* the engine records, one per
`addFuture`/`addPast` call. The four temporal **universal** rules consume
`timeOrd.futureOf`/`pastOf`, which is the transitive *closure* of those edges, and deliberately
so: `SignedFormula.lean`'s `futureOf` docstring records that a direct-edge reading makes
`G p → G G p` — valid over any linear order — produce an open branch. So a gap has to be crossed
before any of those four rules can be proved, and there are two places to cross it.

**The fork, and the measurement that settled it.** The alternative is to strengthen `ordResp`
itself to the closure (`t' ∈ ord.futureOf t → tv t < tv t'`), which makes the four consumers
immediate. What that costs is paid by the *producers*: every fresh-time rule — `allFutureNeg`,
`allPastNeg`, `someFuturePos`, `somePastPos`, and the `untl`/`snce` fresh-time arms — returns
`timeOrd.addFuture l.time branch.nextTime`, i.e. a new edge consed onto the constraint list, and
would then have to re-establish the closure property for the *extended* ordering. That needs a
path-factorisation lemma — every path through `(t, tNew) :: cs` either avoids the new edge or
runs through it into the sink `tNew` — which is not in the tree, and it would have to be applied
afresh at each of those six sites. Against `ordResp` as it stands, those same rules owe only
`∀ p ∈ (t, tNew) :: cs, tv p.1 < tv p.2`: the head from the witness they just chose, the tail
from the state they were handed. So the closure reasoning belongs on the consumer side, where
one lemma serves four rules, and not on the producer side, where a strictly harder one would
serve six. The field is left as it is and the bridge is built here.

The route is the one `Bridge/TemporalSaturation.lean`'s `orderDual_converse` already walks:
`bfsClosure_sound` turns closure membership into a `PathN` of between one and `100` edges, and
an induction on that path length chains the per-edge inequalities.
-/

/-- One forward BFS edge is one recorded constraint. -/
theorem mem_constraints_of_mem_directFutureOf {ord : TimeOrdering} {x y : TimeIndex}
    (h : y ∈ ord.directFutureOf x) : (x, y) ∈ ord.constraints := by
  simp only [TimeOrdering.directFutureOf, List.mem_filterMap] at h
  obtain ⟨⟨a, b⟩, hp, hq⟩ := h
  simp only [beq_iff_eq] at hq
  split at hq
  · next hax => rw [Option.some.injEq] at hq; subst hq; subst hax; exact hp
  · exact absurd hq (by simp)

/-- One backward BFS edge is one recorded constraint, read in the other direction. -/
theorem mem_constraints_of_mem_directPastOf {ord : TimeOrdering} {x y : TimeIndex}
    (h : y ∈ ord.directPastOf x) : (y, x) ∈ ord.constraints := by
  simp only [TimeOrdering.directPastOf, List.mem_filterMap] at h
  obtain ⟨⟨a, b⟩, hp, hq⟩ := h
  simp only [beq_iff_eq] at hq
  split at hq
  · next hax => rw [Option.some.injEq] at hq; subst hq; subst hax; exact hp
  · exact absurd hq (by simp)

/-- A forward path of at least one edge is a strict increase. The `n + 1` in the statement is
what carries the *strictness*: the empty path joins a time to itself and says nothing. -/
theorem lt_of_pathN_directFutureOf {ord : TimeOrdering} {tv : TimeIndex → D}
    (hor : ∀ p ∈ ord.constraints, tv p.1 < tv p.2) :
    ∀ (n : Nat) (t t' : TimeIndex),
      TimeOrdering.PathN ord.directFutureOf (n + 1) t t' → tv t < tv t' := by
  intro n
  induction n with
  | zero =>
    intro t t' h
    obtain ⟨c, hc, hp⟩ := h
    simp only [TimeOrdering.PathN] at hp
    subst hp
    exact hor _ (mem_constraints_of_mem_directFutureOf hc)
  | succ m ih =>
    intro t t' h
    obtain ⟨c, hc, hp⟩ := h
    exact lt_trans (hor _ (mem_constraints_of_mem_directFutureOf hc)) (ih c t' hp)

/-- A backward path of at least one edge is a strict decrease. The past mirror of
`lt_of_pathN_directFutureOf`; only the orientation of the edge lemma differs. -/
theorem lt_of_pathN_directPastOf {ord : TimeOrdering} {tv : TimeIndex → D}
    (hor : ∀ p ∈ ord.constraints, tv p.1 < tv p.2) :
    ∀ (n : Nat) (t t' : TimeIndex),
      TimeOrdering.PathN ord.directPastOf (n + 1) t t' → tv t' < tv t := by
  intro n
  induction n with
  | zero =>
    intro t t' h
    obtain ⟨c, hc, hp⟩ := h
    simp only [TimeOrdering.PathN] at hp
    subst hp
    exact hor _ (mem_constraints_of_mem_directPastOf hc)
  | succ m ih =>
    intro t t' h
    obtain ⟨c, hc, hp⟩ := h
    exact lt_trans (ih c t' hp) (hor _ (mem_constraints_of_mem_directPastOf hc))

/-- **The bridge, forward.** Everything the engine calls a future time of `t` is interpreted
strictly later than `t`. This is what the two universal future rules consume. -/
theorem SatState.lt_of_mem_futureOf {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {t t' : TimeIndex} (h : t' ∈ ord.futureOf t) :
    tv t < tv t' := by
  rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [t] [] h with hv | ⟨s, hs, n, hn1, _, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hs
    subst hs
    obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn1
    exact lt_of_pathN_directFutureOf hst.ordResp m s t' (by simpa [Nat.add_comm] using hp)

/-- **The bridge, backward.** Everything the engine calls a past time of `t` is interpreted
strictly earlier than `t`. -/
theorem SatState.gt_of_mem_pastOf {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {t t' : TimeIndex} (h : t' ∈ ord.pastOf t) :
    tv t' < tv t := by
  rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [t] [] h with hv | ⟨s, hs, n, hn1, _, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hs
    subst hs
    obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn1
    exact lt_of_pathN_directPastOf hst.ordResp m s t' (by simpa [Nat.add_comm] using hp)

/-- The endpoint of a forward path is a time the branch knows. Same induction as
`lt_of_pathN_directFutureOf`, reading `OrdWithin` off the final edge rather than `ordResp`; the
recursive case does not even need the edge, since the invariant travels with the path's tail. -/
theorem mem_knownTimes_of_pathN_directFutureOf {b : Branch} {ord : TimeOrdering}
    (hord : OrdWithin b ord) :
    ∀ (n : Nat) (t t' : TimeIndex),
      TimeOrdering.PathN ord.directFutureOf (n + 1) t t' → t' ∈ b.knownTimes := by
  intro n
  induction n with
  | zero =>
    intro t t' h
    obtain ⟨c, hc, hp⟩ := h
    simp only [TimeOrdering.PathN] at hp
    subst hp
    exact (hord _ (mem_constraints_of_mem_directFutureOf hc)).2
  | succ m ih =>
    intro t t' h
    obtain ⟨c, _, hp⟩ := h
    exact ih c t' hp

/-- **The bridge, in the `OrdWithin` direction.** A time the engine reports as a future time of
`t` is a time the branch already knows — so it is bounded below `b.nextTime`, which is what a
rule minting an *interpolant* between two existing times needs and which the four fresh-time
producers, minting above a single branch time, did not. Consumed by `densityRule`. -/
theorem mem_knownTimes_of_mem_futureOf {b : Branch} {ord : TimeOrdering}
    (hord : OrdWithin b ord) {t t' : TimeIndex} (h : t' ∈ ord.futureOf t) :
    t' ∈ b.knownTimes := by
  rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [t] [] h with hv | ⟨s, hs, n, hn1, _, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hs
    subst hs
    obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn1
    exact mem_knownTimes_of_pathN_directFutureOf hord m s t' (by simpa [Nat.add_comm] using hp)

/-!
### The fresh-time producers' ordering obligation is not discharged by freshness alone

The bridge above is what the four temporal *universal* rules consume, and it costs the producers
nothing, because those four return `timeOrd` untouched. The six fresh-time *producers* —
`allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos`, and the `untl`/`snce` fresh-time
arms — are a different matter, and this subsection records a gap in `RuleSound`'s statement that
was found while attempting them, measured rather than argued.

The intended argument is the one the module docstring states: `branch.nextTime` is absent from
`b` (`Tableau.not_mem_of_time_nextTime`), so a one-point update of `tv` at the fresh index leaves
every branch formula satisfied, and the single new edge `(l.time, freshTime)` is discharged by
the witness time the update chose. **The step that fails is `ordResp` on the *tail*.**

`Branch.nextTime` is `b.maxTime + 1` (`SignedFormula.lean:380`): a function of the *branch*
alone. `SatState` has four fields and not one of them relates the times occurring in
`ord.constraints` to the times occurring in `b`. `RuleSound` quantifies over `b` and `ord`
independently. So `ord` may already mention `b.nextTime`, and since `addFuture` merely conses
(`addFuture ord t tNew = ⟨(t, tNew) :: ord.constraints⟩`, `SignedFormula.lean:685`), the
successor ordering can be cyclic — and then *no* re-choice of `tv` satisfies it, which is what
the two theorems below prove outright. The freedom `SatResult` grants the successor to re-choose
`hist` and `tv` is therefore not enough: the obligation is unsatisfiable, not merely hard.

This is a defect in the *statement*, not in the engine. The engine threads its ordering from
`TimeOrdering.empty` and only ever adds an edge to a genuinely fresh index, so every ordering it
actually builds has all its times occurring on the branch; the cyclic orderings refuted below are
not ones it constructs. Two remedies were considered and **both are escalated rather than taken
here**, because each changes a definition this phase's sixteen landed rules are stated against:

1. **A fifth `SatState` field** bounding `ord`'s times by `b.nextTime`. Measured obstruction:
   any such field mentions `b` *positively*, and `SatState.mono` (line 152) weakens `b` to a
   sublist `b'` with `b'.nextTime ≤ b.nextTime`. The field would not survive `mono`, and `mono`
   is consumed throughout. This remedy is not merely costly; it is blocked as stated.
2. **A well-formedness hypothesis on `RuleSound`** — `∀ p ∈ ord.constraints, p.1 < b.nextTime ∧
   p.2 < b.nextTime`. This survives `mono` (it is not a `SatState` field), costs the sixteen
   landed proofs one `intro` each, and is discharged at the assembly by induction from
   `TimeOrdering.empty`. It is a genuine weakening of `RuleSound` and must be approved as such.

Remedy 2 is *not* the schedule-reachability weakening that was measured and closed earlier: it
does not restrict which branches the engine builds, and it is not tailored to exclude a
counterexample. It is a well-formedness condition on the `(branch, ordering)` pair, discharged
by construction rather than assumed. The distinction is real, and the choice is still the user's.
-/

/-- **The gap, proved.** If `ord` already records `b.nextTime` as lying *before* `t`, then the
edge `allFutureNeg` conses on closes a cycle, and the successor's `ordResp` obligation has no
solution at all — not for the `tv` it was handed, and not for any `tv` it might re-choose. -/
theorem addFuture_nextTime_cycle_unsatisfiable (b : Branch) (t : TimeIndex) :
    ¬ ∃ tv : TimeIndex → D,
      ∀ p ∈ (TimeOrdering.addFuture ⟨[(b.nextTime, t)]⟩ t b.nextTime).constraints,
        tv p.1 < tv p.2 := by
  rintro ⟨tv, h⟩
  have h1 : tv t < tv b.nextTime := h (t, b.nextTime) (by simp [TimeOrdering.addFuture])
  have h2 : tv b.nextTime < tv t := h (b.nextTime, t) (by simp [TimeOrdering.addFuture])
  exact absurd h1 (lt_asymm h2)

/-- The past mirror. `addPast ord t tNew` conses `(tNew, t)`, so the cycle is closed by an `ord`
that already records `b.nextTime` as lying *after* `t`. -/
theorem addPast_nextTime_cycle_unsatisfiable (b : Branch) (t : TimeIndex) :
    ¬ ∃ tv : TimeIndex → D,
      ∀ p ∈ (TimeOrdering.addPast ⟨[(t, b.nextTime)]⟩ t b.nextTime).constraints,
        tv p.1 < tv p.2 := by
  rintro ⟨tv, h⟩
  have h1 : tv b.nextTime < tv t := h (b.nextTime, t) (by simp [TimeOrdering.addPast])
  have h2 : tv t < tv b.nextTime := h (t, b.nextTime) (by simp [TimeOrdering.addPast])
  exact absurd h1 (lt_asymm h2)

/-!
## The temporal universal family

Four rules, one shape. Each reads a *universal* temporal formula at a label, and copies its
matrix to every time the abstract ordering already knows to lie on the relevant side — no fresh
label, no new constraint, and the ordering passes through untouched (all four return `timeOrd`
unchanged, and all four are `.persistent`, since a universal formula is never spent).

The whole content is the bridge above plus the relevant `Truth` characterisation:
`Truth.future_iff` and `Truth.past_iff` for the two `G`/`H` rules, `Truth.some_future_iff` and
`Truth.some_past_iff` for the two `F`/`P` rules, whose negations are what the `.neg` sign
asserts. Nothing here needs shift-closure or `histMem`: every emitted formula stays in the source
label's own world.
-/

/-!
### Point-form readings of the four temporal operators

Each is `Truth`'s characterisation applied at a single time. They exist to keep the rule proofs
free of any dependence on how `split` names the variables it binds: `Formula.allFuture` and
friends are definitions, so the hypothesis these consume arrives *unfolded*, and unification
folds it back without the proof ever having to name the matrix.
-/

/-- `T(Gψ) @ t` gives `ψ` at any later time of the same history. -/
theorem truthAt_of_allFuture {M : TaskModel F} {Om : Set (WorldHistory F)} {τ : WorldHistory F}
    {t s : D} {ψ : Formula} (h : TruthAt M Om τ t ψ.allFuture) (hlt : t < s) :
    TruthAt M Om τ s ψ :=
  (Truth.future_iff Om ψ).mp h s hlt

/-- `T(Hψ) @ t` gives `ψ` at any earlier time of the same history. -/
theorem truthAt_of_allPast {M : TaskModel F} {Om : Set (WorldHistory F)} {τ : WorldHistory F}
    {t s : D} {ψ : Formula} (h : TruthAt M Om τ t ψ.allPast) (hlt : s < t) :
    TruthAt M Om τ s ψ :=
  (Truth.past_iff Om ψ).mp h s hlt

/-- `F(Fψ) @ t` denies `ψ` at every later time: an existential's negation is a universal, which
is why the `F`/`P` negative rules are propagators and not fresh-time rules. -/
theorem not_truthAt_of_someFuture {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {t s : D} {ψ : Formula}
    (h : ¬ TruthAt M Om τ t (Formula.someFuture ψ)) (hlt : t < s) : ¬ TruthAt M Om τ s ψ :=
  fun hc => h ((Truth.some_future_iff Om ψ).mpr ⟨s, hlt, hc⟩)

/-- `F(Pψ) @ t` denies `ψ` at every earlier time. -/
theorem not_truthAt_of_somePast {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {t s : D} {ψ : Formula}
    (h : ¬ TruthAt M Om τ t (Formula.somePast ψ)) (hlt : s < t) : ¬ TruthAt M Om τ s ψ :=
  fun hc => h ((Truth.some_past_iff Om ψ).mpr ⟨s, hlt, hc⟩)

/-!
The four fresh-time producers each need the *existential* reading of their source formula: a
time, on the correct side of the trigger's, at which the inner formula takes the required truth
value. Stated as four lemmas rather than inlined because `Formula.allFuture`, `allPast`,
`someFuture` and `somePast` are all **definitions**, so at the use site the goal shows the
unfolded `imp`/`untl` skeleton and the wrapper has to be recovered by unification against a
lemma's statement — the same reason `truthAt_of_allFuture` exists rather than a `rw`.
-/

/-- `F(Gψ) @ t` yields a strictly later time at which `ψ` fails. The witness time of
`allFutureNeg`. -/
theorem exists_gt_not_truthAt_of_allFuture {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {t : D} {ψ : Formula}
    (h : ¬ TruthAt M Om τ t ψ.allFuture) : ∃ s, t < s ∧ ¬ TruthAt M Om τ s ψ := by
  by_contra hcon
  push_neg at hcon
  exact h ((Truth.future_iff Om ψ).mpr hcon)

/-- `F(Hψ) @ t` yields a strictly earlier time at which `ψ` fails. The witness time of
`allPastNeg`. -/
theorem exists_lt_not_truthAt_of_allPast {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {t : D} {ψ : Formula}
    (h : ¬ TruthAt M Om τ t ψ.allPast) : ∃ s, s < t ∧ ¬ TruthAt M Om τ s ψ := by
  by_contra hcon
  push_neg at hcon
  exact h ((Truth.past_iff Om ψ).mpr hcon)

/-- `T(Fψ) @ t` yields a strictly later time at which `ψ` holds. The witness time of
`someFuturePos`. -/
theorem exists_gt_truthAt_of_someFuture {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {t : D} {ψ : Formula}
    (h : TruthAt M Om τ t (Formula.someFuture ψ)) : ∃ s, t < s ∧ TruthAt M Om τ s ψ :=
  (Truth.some_future_iff Om ψ).mp h

/-- `T(Pψ) @ t` yields a strictly earlier time at which `ψ` holds. The witness time of
`somePastPos`. -/
theorem exists_lt_truthAt_of_somePast {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {t : D} {ψ : Formula}
    (h : TruthAt M Om τ t (Formula.somePast ψ)) : ∃ s, s < t ∧ TruthAt M Om τ s ψ :=
  (Truth.some_past_iff Om ψ).mp h

/-- `F A` is `U(A, ⊤)`. -/
theorem asSomeFuture?_eq_some {φ ψ : Formula} (h : asSomeFuture? φ = some ψ) :
    φ = Formula.someFuture ψ := by
  unfold asSomeFuture? at h
  split at h <;> simp_all [Formula.someFuture, Formula.top]

/-- `P A` is `S(A, ⊤)`. -/
theorem asSomePast?_eq_some {φ ψ : Formula} (h : asSomePast? φ = some ψ) :
    φ = Formula.somePast ψ := by
  unfold asSomePast? at h
  split at h <;> simp_all [Formula.somePast, Formula.top]

/-!
`Formula.allFuture` and `Formula.allPast` are **definitions**, not constructors — `G A` unfolds to
`((A.neg.someFuture).neg`, an `imp`. So `cases φ` cannot separate `G A` from a general
implication, and the two `.pos` rules below cannot be driven by it the way `boxPos` is driven by
the genuine `.box` constructor. They are driven by `split` on `applyRule`'s own matcher instead,
which decides exactly the distinction the engine decides; every arm other than the rule's own
answers `.notApplicable`, which `SatResult` reads as `True`.
-/

/-- `T(GA) → T(A)` at every known future time, same world. Persistent: the source stays. -/
theorem ruleSound_allFuturePos : RuleSound carrierBase .allFuturePos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  have hsrc : SatAt M Om hist tv ⟨s, φ, l⟩ := hst.sat _ hmem
  cases s
  case neg => simp only [applyRule]; trivial
  case pos =>
    simp only [SatAt] at hsrc
    simp only [applyRule]
    split
    all_goals try trivial
    split
    · trivial
    · refine ⟨hist, tv, hst.append ?_⟩
      intro g hg
      rw [List.mem_filterMap] at hg
      obtain ⟨t', ht', hw⟩ := hg
      split at hw
      · exact absurd hw (by simp)
      · rw [Option.some.injEq] at hw
        subst hw
        exact truthAt_of_allFuture hsrc (hst.lt_of_mem_futureOf ht')

/-- `T(HA) → T(A)` at every known past time, same world. The past mirror of `allFuturePos`. -/
theorem ruleSound_allPastPos : RuleSound carrierBase .allPastPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  have hsrc : SatAt M Om hist tv ⟨s, φ, l⟩ := hst.sat _ hmem
  cases s
  case neg => simp only [applyRule]; trivial
  case pos =>
    simp only [SatAt] at hsrc
    simp only [applyRule]
    split
    all_goals try trivial
    split
    · trivial
    · refine ⟨hist, tv, hst.append ?_⟩
      intro g hg
      rw [List.mem_filterMap] at hg
      obtain ⟨t', ht', hw⟩ := hg
      split at hw
      · exact absurd hw (by simp)
      · rw [Option.some.injEq] at hw
        subst hw
        exact truthAt_of_allPast hsrc (hst.gt_of_mem_pastOf ht')

/-- `F(FA) → F(A)` at every known future time, same world. `F(FA)` denies a future witness
outright, so every future time is one at which `A` must fail — the existential's negation is a
universal, and that is why this rule sits in this family rather than with the fresh-time ones. -/
theorem ruleSound_someFutureNeg : RuleSound carrierBase .someFutureNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case pos => simp [applyRule, SatResult]
  case neg =>
    cases hA : asSomeFuture? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = Formula.someFuture ψ := asSomeFuture?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.neg, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ] at hsrc
      simp only [applyRule, hA]
      split
      · trivial
      · refine ⟨hist, tv, hst.append ?_⟩
        intro g hg
        rw [List.mem_filterMap] at hg
        obtain ⟨t', ht', hw⟩ := hg
        split at hw
        · exact absurd hw (by simp)
        · rw [Option.some.injEq] at hw
          subst hw
          exact not_truthAt_of_someFuture hsrc (hst.lt_of_mem_futureOf ht')

/-- `F(PA) → F(A)` at every known past time, same world. The past mirror of `someFutureNeg`. -/
theorem ruleSound_somePastNeg : RuleSound carrierBase .somePastNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case pos => simp [applyRule, SatResult]
  case neg =>
    cases hA : asSomePast? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = Formula.somePast ψ := asSomePast?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.neg, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ] at hsrc
      simp only [applyRule, hA]
      split
      · trivial
      · refine ⟨hist, tv, hst.append ?_⟩
        intro g hg
        rw [List.mem_filterMap] at hg
        obtain ⟨t', ht', hw⟩ := hg
        split at hw
        · exact absurd hw (by simp)
        · rw [Option.some.injEq] at hw
          subst hw
          exact not_truthAt_of_somePast hsrc (hst.gt_of_mem_pastOf ht')

/-!
## `orderTrichotomy` — the linear-order content, isolated from the rule's plumbing

`orderTrichotomy` fires at a label `(w, t₁)` carrying `T(φ)` when the branch also carries `T(ψ)`
at a *sibling* time `(w, t₂)` — incomparable to `t₁` in the recorded ordering — with a common
recorded predecessor `t₀`. It splits on the three ways the two witness times can be arranged, and
emits at `(w, t₀)` one of

```
F(φ ∧ ψ)   F(φ ∧ Fψ)   F(Fφ ∧ ψ)
```

The rule is sound for the reason its name gives: `t₁` and `t₂` may be incomparable in the
*recorded* ordering, but `tv t₁` and `tv t₂` are elements of a `LinearOrder`, so `lt_trichotomy`
decides between them and each of the three outcomes lands on exactly one disjunct. Nothing about
the branch, the ordering, or the frame class enters — only that both times are interpreted above
`tv t₀` in the same history — so the content is stated here as a lemma over three points of `D`
and consumed by the rule's proof with the plumbing kept separate.
-/

/-- `φ ∧ ψ` holds where both conjuncts do. `Formula.and` is `¬(φ → ¬ψ)`, so this is the
double-negation step, needed three times below and stated once. -/
theorem truthAt_and {M : TaskModel F} {Om : Set (WorldHistory F)} {τ : WorldHistory F} {t : D}
    {φ ψ : Formula} (hφ : TruthAt M Om τ t φ) (hψ : TruthAt M Om τ t ψ) :
    TruthAt M Om τ t (Formula.and φ ψ) := by
  simp only [Formula.and, Formula.neg, TruthAt]
  intro h
  exact h hφ hψ

/--
**The trichotomy.** Two times strictly above a common point, each carrying a formula in the same
history, satisfy one of `orderTrichotomy`'s three disjuncts at that common point.

The three cases are `tv t₁ = tv t₂`, `tv t₁ < tv t₂` and `tv t₂ < tv t₁`, in that order, and the
witness for each disjunct is the earlier of the two times.
-/
theorem exists_trichotomy_disjunct {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {c a b : D} {φ ψ : Formula}
    (hca : c < a) (hcb : c < b)
    (hφ : TruthAt M Om τ a φ) (hψ : TruthAt M Om τ b ψ) :
    TruthAt M Om τ c (Formula.someFuture (Formula.and φ ψ))
      ∨ TruthAt M Om τ c (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
      ∨ TruthAt M Om τ c (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ)) := by
  rcases lt_trichotomy a b with hab | hab | hab
  · -- `a < b`: the earlier time carries `φ`, and `ψ` is still ahead of it.
    refine Or.inr (Or.inl ?_)
    rw [Truth.some_future_iff]
    exact ⟨a, hca, truthAt_and hφ ((Truth.some_future_iff Om ψ).mpr ⟨b, hab, hψ⟩)⟩
  · -- `a = b`: both formulas stand at one time.
    subst hab
    refine Or.inl ?_
    rw [Truth.some_future_iff]
    exact ⟨a, hca, truthAt_and hφ hψ⟩
  · -- `b < a`: the earlier time carries `ψ`, and `φ` is still ahead of it.
    refine Or.inr (Or.inr ?_)
    rw [Truth.some_future_iff]
    exact ⟨b, hcb, truthAt_and ((Truth.some_future_iff Om φ).mpr ⟨a, hab, hφ⟩) hψ⟩

theorem ruleSound_orderTrichotomy : RuleSound carrierBase .orderTrichotomy := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    simp only [applyRule]
    split
    · trivial
    · split
      · trivial
      · rename_i _ _ t0 ψ hfind
        -- The pair the engine selected is a member of its own candidate list, and unpacking that
        -- membership is what turns the rule's `flatMap`/`filterMap` plumbing into the four facts
        -- the trichotomy consumes: two recorded order edges and two branch formulas.
        have hmemc := List.mem_of_find?_eq_some hfind
        simp only [List.mem_flatMap, List.mem_map, List.mem_filter, List.mem_filterMap,
          Prod.mk.injEq] at hmemc
        obtain ⟨t0', ht0, t2, ⟨ht2, -⟩, ψ', ⟨x, hxb, hxeq⟩, rfl, rfl⟩ := hmemc
        -- The carried formula is positive, at the sibling time, in the source's own world.
        have hxsign : x.sign = Sign.pos := by
          cases hsx : x.sign with
          | pos => rfl
          | neg => rw [hsx] at hxeq; simp at hxeq
        have hxrest : x.label.world = l.world ∧ x.label.time = t2 ∧ x.formula = ψ' := by
          rw [hxsign] at hxeq
          simp only at hxeq
          split at hxeq
          · rename_i hcond
            simp only [Bool.and_eq_true, beq_iff_eq] at hcond
            exact ⟨hcond.1.1, hcond.1.2, Option.some_inj.mp hxeq⟩
          · simp at hxeq
        -- The two truths, both in the source label's world.
        have hψtrue : TruthAt M Om (hist l.world) (tv t2) ψ' := by
          have hsx := hst.sat x hxb
          simp only [SatAt, hxsign] at hsx
          rwa [hxrest.1, hxrest.2.1, hxrest.2.2] at hsx
        have hφtrue : TruthAt M Om (hist l.world) (tv l.time) φ := hst.sat _ hmem
        -- The two order facts, from the bridge.
        have hc1 : tv t0' < tv l.time := hst.gt_of_mem_pastOf ht0
        have hc2 : tv t0' < tv t2 := hst.lt_of_mem_futureOf ht2
        refine satResult_branching rfl ?_
        -- `lt_trichotomy` on the two interpreted times picks the surviving disjunct.
        rcases exists_trichotomy_disjunct (M := M) (Om := Om) (τ := hist l.world)
          hc1 hc2 hφtrue hψtrue with hd | hd | hd
        · refine ⟨[SignedFormula.pos ((φ.and ψ').someFuture) { world := l.world, time := t0' },
              { sign := Sign.pos, formula := φ, label := l }], by simp, hist, tv, hst.append ?_⟩
          intro g hg
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
          rcases hg with rfl | rfl
          · exact hd
          · exact hφtrue
        · refine ⟨[SignedFormula.pos ((φ.and ψ'.someFuture).someFuture)
                { world := l.world, time := t0' },
              { sign := Sign.pos, formula := φ, label := l }], by simp, hist, tv, hst.append ?_⟩
          intro g hg
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
          rcases hg with rfl | rfl
          · exact hd
          · exact hφtrue
        · refine ⟨[SignedFormula.pos ((φ.someFuture.and ψ').someFuture)
                { world := l.world, time := t0' },
              { sign := Sign.pos, formula := φ, label := l }], by simp, hist, tv, hst.append ?_⟩
          intro g hg
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
          rcases hg with rfl | rfl
          · exact hd
          · exact hφtrue

/-!
## The fresh-time producers

These are the rules that *mint* a time: they file a witness at `branch.nextTime` and record one
new ordering edge joining the trigger's time to it. Their obligation therefore has three parts
rather than the usual one, and each part is discharged by a different piece of the state:

* **the new edge** — `tv` is updated at the single index `freshTime`, to a value chosen on the
  strength of the source formula (`F(GA)` supplies a later time at which `A` fails, `T(FA)` a
  later time at which `A` holds, and their two past mirrors likewise). The edge holds by that
  choice.
* **the old edges** — this is where `OrdWithin` is consumed, and it is the *only* place any rule
  consumes it. A one-point update at `freshTime` leaves `tv p.1 < tv p.2` intact for an existing
  constraint `p` exactly when neither endpoint is `freshTime`, which is `OrdWithin.bound`. Without
  the hypothesis the obligation is not merely hard but unsatisfiable — see
  `addFuture_nextTime_cycle_unsatisfiable` above.
* **the branch, and the propagated formulas** — the branch is untouched by the update because no
  branch formula sits at `nextTime` (`not_mem_of_time_nextTime`). The propagated formulas split
  into three families: the *temporal* propagations, discharged by the four `truthAt_of_*` lemmas
  from the chosen time's position relative to the trigger's; and the *modal* propagations emitted
  by `boxDiamondPersistence`, discharged by `satAt_of_boxForm_time` below.

The modal family is the subtle one. Copying a formula from one time to another inside a single
world is unsound in general — that is precisely the defect that was removed from the fresh-*world*
rules. It is sound here only because the two source lists hold `T(□A)` and `F(◇A)` formulas
exclusively, whose truth conditions are `Ω`-universal, and an `Ω`-universal claim is
time-invariant when `Ω` is shift-closed. `mem_boxDiamondPersistence_shape` is what makes that
restriction visible across the `private` definition.
-/

/-- **An `Ω`-universal claim is time-invariant.** If `ψ` holds at time `t` in *every* admissible
history, it holds at *any* time in every admissible history.

This is the ungated core of `truthAt_allFuture_of_box` and `truthAt_allPast_of_box`: those two
wrap this fact in `G` and `H` respectively, and each discards the direction information the
wrapper supplies. The fresh-time rules need it raw, because they move a `□` formula to a time
whose position relative to the source is recorded in the ordering rather than in the formula. -/
theorem forall_truthAt_time_invariant {M : TaskModel F} {Om : Set (WorldHistory F)}
    (hsc : ShiftClosed Om) {t s : D} {ψ : Formula}
    (h : ∀ σ ∈ Om, TruthAt M Om σ t ψ) : ∀ σ ∈ Om, TruthAt M Om σ s ψ := fun τ hτ =>
  (TimeShift.time_shift_preserves_truth M Om hsc τ t s ψ).mp
    (h (WorldHistory.timeShift τ (s - t)) (hsc τ hτ (s - t)))

/-- Everything `boxDiamondPersistence` emits is satisfied at the fresh time by the *same* history
that satisfies its source at the trigger's time.

Stated against the conclusions of `mem_boxDiamondPersistence_label` and
`mem_boxDiamondPersistence_shape` rather than against membership, because
`boxDiamondPersistence` is `private` to `Tableau.lean` and so cannot be named here. Note the
interpretation `tv'` is unconstrained: time-invariance means the fresh time's value is
irrelevant, which is why this lemma survives an arbitrary one-point update. -/
theorem satAt_of_boxForm_time {M : TaskModel F} {Om : Set (WorldHistory F)}
    (hsc : ShiftClosed Om) {hist : WorldIndex → WorldHistory F} {tv tv' : TimeIndex → D}
    {w : WorldIndex} {t ft : TimeIndex} {s g : SignedFormula}
    (hsrc : SatAt M Om hist tv s)
    (hslab : s.label = { world := w, time := t })
    (hglab : g.label = { world := w, time := ft })
    (hsign : s.sign = g.sign) (hform : s.formula = g.formula)
    (hshape : (g.sign = .pos ∧ ∃ χ, g.formula = .box χ) ∨
      (g.sign = .neg ∧ ∃ χ, g.formula = .imp (.box (.imp χ .bot)) .bot)) :
    SatAt M Om hist tv' g := by
  rcases hshape with ⟨hgs, χ, hgf⟩ | ⟨hgs, χ, hgf⟩
  · have hss : s.sign = .pos := hsign.trans hgs
    have hsf : s.formula = Formula.box χ := hform.trans hgf
    simp only [SatAt, hss, hsf, hslab, TruthAt] at hsrc
    simp only [SatAt, hgs, hgf, hglab, TruthAt]
    exact forall_truthAt_time_invariant hsc hsrc
  · have hss : s.sign = .neg := hsign.trans hgs
    have hsf : s.formula = Formula.imp (.box (.imp χ .bot)) .bot := hform.trans hgf
    simp only [SatAt, hss, hsf, hslab] at hsrc
    have hbox : ∀ σ ∈ Om, TruthAt M Om σ (tv t) (Formula.imp χ .bot) := by
      by_contra hcon
      exact hsrc hcon
    simp only [SatAt, hgs, hgf, hglab]
    intro hc
    exact hc (forall_truthAt_time_invariant hsc hbox)

/-- A branch formula is undisturbed by a one-point update of `tv` at the branch's fresh time: no
branch formula sits there, by `not_mem_of_time_nextTime`. -/
theorem satAt_update_nextTime_of_mem {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {d : D}
    {sf : SignedFormula} (hmem : sf ∈ b) (h : SatAt M Om hist tv sf) :
    SatAt M Om hist (Function.update tv b.nextTime d) sf := by
  have hne : sf.label.time ≠ b.nextTime := fun hq => (not_mem_of_time_nextTime hq) hmem
  simpa only [SatAt, Function.update_of_ne hne] using h

/-- The `ordResp` obligation for a fresh-time rule's extended ordering, in the shape all four
share: the minted edge holds by the choice of `d`, and every previously recorded edge survives
the one-point update because `OrdWithin` puts both its endpoints strictly below `nextTime`. -/
theorem ordResp_addFuture_update {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) (hord : OrdWithin b ord)
    {t : TimeIndex} (hmemt : t ∈ b.knownTimes) {d : D} (hlt : tv t < d) :
    ∀ p ∈ (ord.addFuture t b.nextTime).constraints,
      Function.update tv b.nextTime d p.1 < Function.update tv b.nextTime d p.2 := by
  have hne : t ≠ b.nextTime := Nat.ne_of_lt (lt_nextTime_of_mem_knownTimes hmemt)
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | hp
  · simpa [Function.update_of_ne hne] using hlt
  · obtain ⟨h1, h2⟩ := hord.nextTime_not_mem hp
    simpa only [Function.update_of_ne h1, Function.update_of_ne h2] using hst.ordResp p hp

/-- The past mirror of `ordResp_addFuture_update`. -/
theorem ordResp_addPast_update {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) (hord : OrdWithin b ord)
    {t : TimeIndex} (hmemt : t ∈ b.knownTimes) {d : D} (hlt : d < tv t) :
    ∀ p ∈ (ord.addPast t b.nextTime).constraints,
      Function.update tv b.nextTime d p.1 < Function.update tv b.nextTime d p.2 := by
  have hne : t ≠ b.nextTime := Nat.ne_of_lt (lt_nextTime_of_mem_knownTimes hmemt)
  intro p hp
  simp only [TimeOrdering.addPast, List.mem_cons] at hp
  rcases hp with rfl | hp
  · simpa [Function.update_of_ne hne] using hlt
  · obtain ⟨h1, h2⟩ := hord.nextTime_not_mem hp
    simpa only [Function.update_of_ne h1, Function.update_of_ne h2] using hst.ordResp p hp

/-- The `ordResp` obligation for an *interpolating* rule's extended ordering. `densityRule` mints
two edges in one step — `t < fresh` and `fresh < t'` — so `ordResp_addFuture_update` does not
apply as it stands, and the extra input is a second `OrdWithin` witness: `t'` must also be a known
time, or the one-point update at `b.nextTime` would silently move it. That is what
`mem_knownTimes_of_mem_futureOf` supplies. -/
theorem ordResp_addFuture_addFuture_update {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) (hord : OrdWithin b ord)
    {t t' : TimeIndex} (hmemt : t ∈ b.knownTimes) (hmemt' : t' ∈ b.knownTimes)
    {d : D} (hlt : tv t < d) (hlt' : d < tv t') :
    ∀ p ∈ ((ord.addFuture t b.nextTime).addFuture b.nextTime t').constraints,
      Function.update tv b.nextTime d p.1 < Function.update tv b.nextTime d p.2 := by
  have hne : t ≠ b.nextTime := Nat.ne_of_lt (lt_nextTime_of_mem_knownTimes hmemt)
  have hne' : t' ≠ b.nextTime := Nat.ne_of_lt (lt_nextTime_of_mem_knownTimes hmemt')
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | rfl | hp
  · simpa [Function.update_of_ne hne'] using hlt'
  · simpa [Function.update_of_ne hne] using hlt
  · obtain ⟨h1, h2⟩ := hord.nextTime_not_mem hp
    simpa only [Function.update_of_ne h1, Function.update_of_ne h2] using hst.ordResp p hp

/-- The `T(Gφ)` propagations a fresh-*future*-time rule emits are satisfied at the minted time:
`T(Gφ)` at the trigger's time gives `φ` at every later time, and the minted time is later by the
choice of `d`. Shared verbatim by `allFutureNeg` and `someFuturePos`. -/
theorem satAt_of_mem_gProps {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {t : TimeIndex} {d : D} (hlt : tv t < d)
    {g : SignedFormula}
    (hg : g ∈ b.allFuturePosFormulas.filterMap fun gsf =>
      match gsf.formula with
      | .allFuture inner =>
        if gsf.label.time == t then
          let prop := SignedFormula.pos inner { world := gsf.label.world, time := b.nextTime }
          if b.contains prop then none else some prop
        else none
      | _ => none) :
    SatAt M Om hist (Function.update tv b.nextTime d) g := by
  obtain ⟨gsf, hgsf, hw⟩ := List.mem_filterMap.mp hg
  have hpred := List.of_mem_filter hgsf
  have hsign : gsf.sign = .pos := by split at hpred <;> simp_all
  have hsrc : SatAt M Om hist tv gsf := hst.sat _ (List.mem_of_mem_filter hgsf)
  split at hw
  · rename_i inner hgf
    by_cases ht : (gsf.label.time == t) = true
    · rw [if_pos ht] at hw
      have hteq : gsf.label.time = t := by simpa using ht
      by_cases hc : b.contains (SignedFormula.pos inner
          { world := gsf.label.world, time := b.nextTime }) = true
      · rw [if_pos hc] at hw; exact absurd hw (by simp)
      · rw [if_neg hc] at hw
        rw [SatAt, hsign, hgf, hteq] at hsrc
        rw [← Option.some_inj.mp hw]
        simpa [SatAt, SignedFormula.pos] using truthAt_of_allFuture hsrc hlt
    · rw [if_neg ht] at hw; exact absurd hw (by simp)
  · exact absurd hw (by simp)

/-- `satAt_of_mem_gProps` with the extra guard conjunct `densityRule` carries. That rule already
emits its own `T(ψ)` witness from the `T(Gψ)` it fired on, so it excludes that one formula from
the propagation block to avoid emitting the same signed formula twice; the guard is therefore
`gsf.label.time == t && gsf.formula != Formula.allFuture χ` rather than the bare time test, which
does not unify with the original helper. The excluded conjunct is *discarded* information here —
the proof never needs it — so the two lemmas differ only in the shape they match. -/
theorem satAt_of_mem_gPropsExcept {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {t : TimeIndex} {d : D} (hlt : tv t < d)
    {χ : Formula} {g : SignedFormula}
    (hg : g ∈ b.allFuturePosFormulas.filterMap fun gsf =>
      match gsf.formula with
      | .allFuture inner =>
        if gsf.label.time == t && gsf.formula != Formula.allFuture χ then
          let prop := SignedFormula.pos inner { world := gsf.label.world, time := b.nextTime }
          if b.contains prop then none else some prop
        else none
      | _ => none) :
    SatAt M Om hist (Function.update tv b.nextTime d) g := by
  obtain ⟨gsf, hgsf, hw⟩ := List.mem_filterMap.mp hg
  have hpred := List.of_mem_filter hgsf
  have hsign : gsf.sign = .pos := by split at hpred <;> simp_all
  have hsrc : SatAt M Om hist tv gsf := hst.sat _ (List.mem_of_mem_filter hgsf)
  split at hw
  · rename_i inner hgf
    by_cases ht : (gsf.label.time == t && gsf.formula != Formula.allFuture χ) = true
    · rw [if_pos ht] at hw
      have hteq : gsf.label.time = t := by
        simp only [Bool.and_eq_true, beq_iff_eq] at ht; exact ht.1
      by_cases hc : b.contains (SignedFormula.pos inner
          { world := gsf.label.world, time := b.nextTime }) = true
      · rw [if_pos hc] at hw; exact absurd hw (by simp)
      · rw [if_neg hc] at hw
        rw [SatAt, hsign, hgf, hteq] at hsrc
        rw [← Option.some_inj.mp hw]
        simpa [SatAt, SignedFormula.pos] using truthAt_of_allFuture hsrc hlt
    · rw [if_neg ht] at hw; exact absurd hw (by simp)
  · exact absurd hw (by simp)

/-- The `F(Fφ)` propagations a fresh-*future*-time rule emits. `F(Fφ)` denies `φ` at every later
time, and the minted time is later. Shared verbatim by `allFutureNeg` and `someFuturePos`. -/
theorem satAt_of_mem_fNegProps {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {t : TimeIndex} {d : D} (hlt : tv t < d)
    {g : SignedFormula}
    (hg : g ∈ b.someFutureNegFormulas.filterMap fun fsf =>
      match fsf.formula with
      | .someFuture inner =>
        if fsf.label.time == t then
          let prop := SignedFormula.neg inner { world := fsf.label.world, time := b.nextTime }
          if b.contains prop then none else some prop
        else none
      | _ => none) :
    SatAt M Om hist (Function.update tv b.nextTime d) g := by
  obtain ⟨fsf, hfsf, hw⟩ := List.mem_filterMap.mp hg
  have hpred := List.of_mem_filter hfsf
  have hsign : fsf.sign = .neg := by split at hpred <;> simp_all
  have hsrc : SatAt M Om hist tv fsf := hst.sat _ (List.mem_of_mem_filter hfsf)
  split at hw
  · rename_i inner hff
    by_cases ht : (fsf.label.time == t) = true
    · rw [if_pos ht] at hw
      have hteq : fsf.label.time = t := by simpa using ht
      by_cases hc : b.contains (SignedFormula.neg inner
          { world := fsf.label.world, time := b.nextTime }) = true
      · rw [if_pos hc] at hw; exact absurd hw (by simp)
      · rw [if_neg hc] at hw
        rw [SatAt, hsign, hff, hteq] at hsrc
        rw [← Option.some_inj.mp hw]
        simpa [SatAt, SignedFormula.neg] using not_truthAt_of_someFuture hsrc hlt
    · rw [if_neg ht] at hw; exact absurd hw (by simp)
  · exact absurd hw (by simp)

/-- The `T(Hφ)` propagations a fresh-*past*-time rule emits. Past mirror of
`satAt_of_mem_gProps`; shared by `allPastNeg` and `somePastPos`. -/
theorem satAt_of_mem_hProps {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {t : TimeIndex} {d : D} (hlt : d < tv t)
    {g : SignedFormula}
    (hg : g ∈ b.allPastPosFormulas.filterMap fun hsf =>
      match hsf.formula with
      | .allPast inner =>
        if hsf.label.time == t then
          let prop := SignedFormula.pos inner { world := hsf.label.world, time := b.nextTime }
          if b.contains prop then none else some prop
        else none
      | _ => none) :
    SatAt M Om hist (Function.update tv b.nextTime d) g := by
  obtain ⟨hsf, hhsf, hw⟩ := List.mem_filterMap.mp hg
  have hpred := List.of_mem_filter hhsf
  have hsign : hsf.sign = .pos := by split at hpred <;> simp_all
  have hsrc : SatAt M Om hist tv hsf := hst.sat _ (List.mem_of_mem_filter hhsf)
  split at hw
  · rename_i inner hhf
    by_cases ht : (hsf.label.time == t) = true
    · rw [if_pos ht] at hw
      have hteq : hsf.label.time = t := by simpa using ht
      by_cases hc : b.contains (SignedFormula.pos inner
          { world := hsf.label.world, time := b.nextTime }) = true
      · rw [if_pos hc] at hw; exact absurd hw (by simp)
      · rw [if_neg hc] at hw
        rw [SatAt, hsign, hhf, hteq] at hsrc
        rw [← Option.some_inj.mp hw]
        simpa [SatAt, SignedFormula.pos] using truthAt_of_allPast hsrc hlt
    · rw [if_neg ht] at hw; exact absurd hw (by simp)
  · exact absurd hw (by simp)

/-- The `F(Pφ)` propagations a fresh-*past*-time rule emits. Past mirror of
`satAt_of_mem_fNegProps`; shared by `allPastNeg` and `somePastPos`. -/
theorem satAt_of_mem_pNegProps {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    (hst : SatState M Om hist tv b ord) {t : TimeIndex} {d : D} (hlt : d < tv t)
    {g : SignedFormula}
    (hg : g ∈ b.somePastNegFormulas.filterMap fun psf =>
      match psf.formula with
      | .somePast inner =>
        if psf.label.time == t then
          let prop := SignedFormula.neg inner { world := psf.label.world, time := b.nextTime }
          if b.contains prop then none else some prop
        else none
      | _ => none) :
    SatAt M Om hist (Function.update tv b.nextTime d) g := by
  obtain ⟨psf, hpsf, hw⟩ := List.mem_filterMap.mp hg
  have hpred := List.of_mem_filter hpsf
  have hsign : psf.sign = .neg := by split at hpred <;> simp_all
  have hsrc : SatAt M Om hist tv psf := hst.sat _ (List.mem_of_mem_filter hpsf)
  split at hw
  · rename_i inner hpf
    by_cases ht : (psf.label.time == t) = true
    · rw [if_pos ht] at hw
      have hteq : psf.label.time = t := by simpa using ht
      by_cases hc : b.contains (SignedFormula.neg inner
          { world := psf.label.world, time := b.nextTime }) = true
      · rw [if_pos hc] at hw; exact absurd hw (by simp)
      · rw [if_neg hc] at hw
        rw [SatAt, hsign, hpf, hteq] at hsrc
        rw [← Option.some_inj.mp hw]
        simpa [SatAt, SignedFormula.neg] using not_truthAt_of_somePast hsrc hlt
    · rw [if_neg ht] at hw; exact absurd hw (by simp)
  · exact absurd hw (by simp)

/-- `F(GA) → F(A)` at a fresh future time, plus the three propagation families.

`F(GA)` says `A` fails somewhere strictly later, and that failure time is what interprets the
minted index `Branch.nextTime`. The interpretation is a one-point update, which is safe for the
branch because no branch formula sits at `nextTime`, and safe for the previously recorded
ordering constraints because `OrdWithin` puts both endpoints of each strictly below it. This is
the first of the four rules that consume the hypothesis, and the only reason it is needed. -/
theorem ruleSound_allFutureNeg : RuleSound carrierBase .allFutureNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst hord
  obtain ⟨s, φ, l⟩ := sf
  have hsrc : SatAt M Om hist tv ⟨s, φ, l⟩ := hst.sat _ hmem
  cases s
  case pos => simp only [applyRule]; trivial
  case neg =>
    simp only [SatAt] at hsrc
    simp only [applyRule]
    split
    all_goals try trivial
    obtain ⟨d, hlt, hfail⟩ := exists_gt_not_truthAt_of_allFuture hsrc
    refine ⟨hist, Function.update tv b.nextTime d, hst.shiftClosed, hst.histMem,
      ordResp_addFuture_update hst hord (mem_knownTimes_of_mem_branch hmem) hlt, ?_⟩
    intro g hg
    rcases List.mem_append.mp hg with hnew | hb
    · rcases List.mem_cons.mp hnew with rfl | hrest
      · simpa [SatAt, SignedFormula.neg] using hfail
      · rcases List.mem_append.mp hrest with hleft | hmodal
        · rcases List.mem_append.mp hleft with hgp | hfn
          · exact satAt_of_mem_gProps hst hlt hgp
          · exact satAt_of_mem_fNegProps hst hlt hfn
        · obtain ⟨hglab, s', hs'mem, hs'lab, hs'sign, hs'form⟩ :=
            mem_boxDiamondPersistence_label hmodal
          exact satAt_of_boxForm_time hst.shiftClosed (hst.sat s' hs'mem) hs'lab hglab
            hs'sign hs'form (mem_boxDiamondPersistence_shape hmodal)
    · exact satAt_update_nextTime_of_mem hb (hst.sat g hb)

/-- `F(HA) → F(A)` at a fresh past time, plus the three propagation families. The exact past
mirror of `allFutureNeg`: `F(HA)` supplies a strictly *earlier* failure time, the ordering edge
runs the other way (`addPast`), and the two past propagation helpers replace the two future
ones. The modal family is direction-blind and is reused verbatim. -/
theorem ruleSound_allPastNeg : RuleSound carrierBase .allPastNeg := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst hord
  obtain ⟨s, φ, l⟩ := sf
  have hsrc : SatAt M Om hist tv ⟨s, φ, l⟩ := hst.sat _ hmem
  cases s
  case pos => simp only [applyRule]; trivial
  case neg =>
    simp only [SatAt] at hsrc
    simp only [applyRule]
    split
    all_goals try trivial
    obtain ⟨d, hlt, hfail⟩ := exists_lt_not_truthAt_of_allPast hsrc
    refine ⟨hist, Function.update tv b.nextTime d, hst.shiftClosed, hst.histMem,
      ordResp_addPast_update hst hord (mem_knownTimes_of_mem_branch hmem) hlt, ?_⟩
    intro g hg
    rcases List.mem_append.mp hg with hnew | hb
    · rcases List.mem_cons.mp hnew with rfl | hrest
      · simpa [SatAt, SignedFormula.neg] using hfail
      · rcases List.mem_append.mp hrest with hleft | hmodal
        · rcases List.mem_append.mp hleft with hhp | hpn
          · exact satAt_of_mem_hProps hst hlt hhp
          · exact satAt_of_mem_pNegProps hst hlt hpn
        · obtain ⟨hglab, s', hs'mem, hs'lab, hs'sign, hs'form⟩ :=
            mem_boxDiamondPersistence_label hmodal
          exact satAt_of_boxForm_time hst.shiftClosed (hst.sat s' hs'mem) hs'lab hglab
            hs'sign hs'form (mem_boxDiamondPersistence_shape hmodal)
    · exact satAt_update_nextTime_of_mem hb (hst.sat g hb)

/-- `T(FA) → T(A)` at a fresh future time, plus the three propagation families.

The dual of `allFutureNeg` in the sign of the witness rather than in the direction of time: both
mint a *future* index and both call `addFuture`, but `T(FA)` supplies a later time at which `A`
*holds* where `F(GA)` supplies one at which it fails. `F A` is `U(A, ⊤)`, a definition rather
than a constructor, so the rule is driven by `asSomeFuture?` exactly as `someFutureNeg` is. -/
theorem ruleSound_someFuturePos : RuleSound carrierBase .someFuturePos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst hord
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asSomeFuture? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = Formula.someFuture ψ := asSomeFuture?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ] at hsrc
      simp only [applyRule, hA]
      obtain ⟨d, hlt, htrue⟩ := exists_gt_truthAt_of_someFuture hsrc
      refine ⟨hist, Function.update tv b.nextTime d, hst.shiftClosed, hst.histMem,
        ordResp_addFuture_update hst hord (mem_knownTimes_of_mem_branch hmem) hlt, ?_⟩
      intro g hg
      rcases List.mem_append.mp hg with hnew | hb
      · rcases List.mem_cons.mp hnew with rfl | hrest
        · simpa [SatAt, SignedFormula.pos] using htrue
        · rcases List.mem_append.mp hrest with hleft | hmodal
          · rcases List.mem_append.mp hleft with hgp | hfn
            · exact satAt_of_mem_gProps hst hlt hgp
            · exact satAt_of_mem_fNegProps hst hlt hfn
          · obtain ⟨hglab, s', hs'mem, hs'lab, hs'sign, hs'form⟩ :=
              mem_boxDiamondPersistence_label hmodal
            exact satAt_of_boxForm_time hst.shiftClosed (hst.sat s' hs'mem) hs'lab hglab
              hs'sign hs'form (mem_boxDiamondPersistence_shape hmodal)
      · exact satAt_update_nextTime_of_mem hb (hst.sat g hb)

/-- `T(PA) → T(A)` at a fresh past time, plus the three propagation families. The past mirror of
`someFuturePos`, and the last of the four fresh-time existentials. -/
theorem ruleSound_somePastPos : RuleSound carrierBase .somePastPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst hord
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asSomePast? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = Formula.somePast ψ := asSomePast?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ] at hsrc
      simp only [applyRule, hA]
      obtain ⟨d, hlt, htrue⟩ := exists_lt_truthAt_of_somePast hsrc
      refine ⟨hist, Function.update tv b.nextTime d, hst.shiftClosed, hst.histMem,
        ordResp_addPast_update hst hord (mem_knownTimes_of_mem_branch hmem) hlt, ?_⟩
      intro g hg
      rcases List.mem_append.mp hg with hnew | hb
      · rcases List.mem_cons.mp hnew with rfl | hrest
        · simpa [SatAt, SignedFormula.pos] using htrue
        · rcases List.mem_append.mp hrest with hleft | hmodal
          · rcases List.mem_append.mp hleft with hhp | hpn
            · exact satAt_of_mem_hProps hst hlt hhp
            · exact satAt_of_mem_pNegProps hst hlt hpn
          · obtain ⟨hglab, s', hs'mem, hs'lab, hs'sign, hs'form⟩ :=
              mem_boxDiamondPersistence_label hmodal
            exact satAt_of_boxForm_time hst.shiftClosed (hst.sat s' hs'mem) hs'lab hglab
              hs'sign hs'form (mem_boxDiamondPersistence_shape hmodal)
      · exact satAt_update_nextTime_of_mem hb (hst.sat g hb)

/-- `T(U(⊤,⊥))` closes the branch on a dense frame. The rule emits `.linear []`, so the successor
branch *is* the branch and the handed-in state discharges the obligation outright; the closure is
detected downstream by `checkAxiomNeg` against the density indicator axiom, not here. Proved at
`carrierBase` and reused at `.Dense` through `RuleSound.mono`, which is why no carrier property is
declared for it. -/
theorem ruleSound_denseIndicatorClosure : RuleSound carrierBase .denseIndicatorClosure := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst _
  obtain ⟨s, φ, l⟩ := sf
  simp only [applyRule]
  split
  all_goals try trivial
  exact ⟨hist, tv, by simpa using hst⟩

/-!
## `untlPos` and `sncePos` — provable once the copy is gone

These two were blocked, and the obstruction was an unsound *engine* step rather than a missing
proof: an `untlNegProps`/`snceNegProps` block copying every negative `Until`/`Since` at the
trigger's time into the freshly minted time. The block has been deleted (see `applyRule`'s
docstring for the prohibition, and `Tests/BimodalTest/UntlSnceCopyProbe.lean` for the
measurement), and what remains is exactly the shape the four fresh-time existentials already
discharge: a witness supplied by the source formula's truth condition, plus the `T(G·)`, `F(F·)`
and `□`/`◇` families in the future direction (`T(H·)`, `F(P·)` and `□`/`◇` in the past).

The `Until` witness is *stronger* than these proofs need. `T(U(e,g))@t` supplies a witness time
`s > t` carrying `e` **and** a guard condition on all of `(t,s)`; branch 1 needs only the
witness, so the guard half is discarded. That is why only branch 1 is ever named — branch 2 is a
sound alternative the proof never has to take. The section header below records the same fact
for the `Since` mirror.
-/

/-- A genuine `Until` (guard not `⊤`) really is an `untl`. -/
theorem asUntil?_eq_some {φ e g : Formula} (h : asUntil? φ = some (e, g)) :
    φ = Formula.untl e g := by
  unfold asUntil? at h
  split at h <;> simp_all

/-- A genuine `Since` (guard not `⊤`) really is a `snce`. -/
theorem asSince?_eq_some {φ e g : Formula} (h : asSince? φ = some (e, g)) :
    φ = Formula.snce e g := by
  unfold asSince? at h
  split at h <;> simp_all

/-- The witness half of `Until`'s truth condition. The guard half is discarded: branch 1 of
`untlPos` asserts only the event, and the fresh time is interpreted as the witness. -/
theorem exists_gt_truthAt_of_untl {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {t : D} {e g : Formula}
    (h : TruthAt M Om τ t (Formula.untl e g)) : ∃ d, t < d ∧ TruthAt M Om τ d e := by
  simp only [TruthAt] at h
  obtain ⟨s, hts, hs, _⟩ := h
  exact ⟨s, hts, hs⟩

/-- The witness half of `Since`'s truth condition, the past mirror. -/
theorem exists_lt_truthAt_of_snce {M : TaskModel F} {Om : Set (WorldHistory F)}
    {τ : WorldHistory F} {t : D} {e g : Formula}
    (h : TruthAt M Om τ t (Formula.snce e g)) : ∃ d, d < t ∧ TruthAt M Om τ d e := by
  simp only [TruthAt] at h
  obtain ⟨s, hst, hs, _⟩ := h
  exact ⟨s, hst, hs⟩

/-- `T(U(e,g)) → T(e)` at a fresh future time, plus the three future propagation families.
Branch 1 of the two the rule offers; branch 2 is never needed. -/
theorem ruleSound_untlPos : RuleSound carrierBase .untlPos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst hord
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asUntil? φ with
    | none => simp [applyRule, hA, SatResult]
    | some eg =>
      obtain ⟨e, g⟩ := eg
      have hφ : φ = Formula.untl e g := asUntil?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ] at hsrc
      simp only [applyRule, hA]
      obtain ⟨d, hlt, htrue⟩ := exists_gt_truthAt_of_untl hsrc
      refine ⟨_, List.mem_cons_self, hist, Function.update tv b.nextTime d,
        hst.shiftClosed, hst.histMem,
        ordResp_addFuture_update hst hord (mem_knownTimes_of_mem_branch hmem) hlt, ?_⟩
      intro c hc
      rcases List.mem_append.mp hc with hnew | hb
      · rcases List.mem_append.mp hnew with hwit | hrest
        · rw [List.mem_singleton] at hwit
          subst hwit
          simpa [SatAt, SignedFormula.pos] using htrue
        · rcases List.mem_append.mp hrest with hleft | hmodal
          · rcases List.mem_append.mp hleft with hgp | hfn
            · exact satAt_of_mem_gProps hst hlt hgp
            · exact satAt_of_mem_fNegProps hst hlt hfn
          · obtain ⟨hglab, s', hs'mem, hs'lab, hs'sign, hs'form⟩ :=
              mem_boxDiamondPersistence_label hmodal
            exact satAt_of_boxForm_time hst.shiftClosed (hst.sat s' hs'mem) hs'lab hglab
              hs'sign hs'form (mem_boxDiamondPersistence_shape hmodal)
      · exact satAt_update_nextTime_of_mem hb (hst.sat c hb)

/-- `T(S(e,g)) → T(e)` at a fresh past time. The exact time-reversal mirror of `untlPos`: the
witness lands earlier, the ordering edge runs the other way, and the two past propagation
helpers replace the two future ones. The modal family is direction-blind and reused verbatim. -/
theorem ruleSound_sncePos : RuleSound carrierBase .sncePos := by
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst hord
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asSince? φ with
    | none => simp [applyRule, hA, SatResult]
    | some eg =>
      obtain ⟨e, g⟩ := eg
      have hφ : φ = Formula.snce e g := asSince?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ] at hsrc
      simp only [applyRule, hA]
      obtain ⟨d, hlt, htrue⟩ := exists_lt_truthAt_of_snce hsrc
      refine ⟨_, List.mem_cons_self, hist, Function.update tv b.nextTime d,
        hst.shiftClosed, hst.histMem,
        ordResp_addPast_update hst hord (mem_knownTimes_of_mem_branch hmem) hlt, ?_⟩
      intro c hc
      rcases List.mem_append.mp hc with hnew | hb
      · rcases List.mem_append.mp hnew with hwit | hrest
        · rw [List.mem_singleton] at hwit
          subst hwit
          simpa [SatAt, SignedFormula.pos] using htrue
        · rcases List.mem_append.mp hrest with hleft | hmodal
          · rcases List.mem_append.mp hleft with hhp | hpn
            · exact satAt_of_mem_hProps hst hlt hhp
            · exact satAt_of_mem_pNegProps hst hlt hpn
          · obtain ⟨hglab, s', hs'mem, hs'lab, hs'sign, hs'form⟩ :=
              mem_boxDiamondPersistence_label hmodal
            exact satAt_of_boxForm_time hst.shiftClosed (hst.sat s' hs'mem) hs'lab hglab
              hs'sign hs'form (mem_boxDiamondPersistence_shape hmodal)
      · exact satAt_update_nextTime_of_mem hb (hst.sat c hb)

/-!
## The frame-class-gated rules

`denseIndicatorClosure` above needed no carrier property. `densityRule` is the first rule that
does, and it is also the first rule that mints an **interpolant** rather than a new extreme: it
returns two ordering edges, `l.time < fresh` and `fresh < t'`, where `t'` is a maximal element of
the source's recorded future. Three things follow, and all three are what the two helper variants
above exist for.

* The witness `d` is not free above `tv l.time`; it must land strictly *between* `tv l.time` and
  `tv t'`. That is exactly `DenselyOrdered D`, i.e. `carrierDense`, and it is the only place the
  property is consumed.
* `ordResp` must be re-established for **two** new edges at once, and the upper endpoint `t'` has
  to be shown untouched by the one-point update — which needs `t' ∈ b.knownTimes`, supplied by
  `mem_knownTimes_of_mem_futureOf` off `OrdWithin`.
* The propagation block excludes the rule's own source formula, so its guard carries an extra
  conjunct and matches `satAt_of_mem_gPropsExcept` rather than `satAt_of_mem_gProps`.

The gap-selection logic (`gapTargets`: maximal, unfilled) is soundness-irrelevant — any `t'` in
the recorded future would do — and is there for *termination*, as `applyRule`'s comment records.
The proof accordingly reads `t'` off the head of the filtered list and forgets the filter.
-/

/-- `T(Gψ)` at `t` with a maximal recorded future time `t'` gives `T(ψ)` at a fresh interpolant
strictly between them, plus the `T(G·)` propagations. The first rule to consume a carrier
property, and the first to mint a time bounded on *both* sides. -/
theorem ruleSound_densityRule : RuleSound carrierDense .densityRule := by
  intro D _ _ _ _ hC F M Om hist tv b sf ord hmem hst hord
  haveI : DenselyOrdered D := hC
  obtain ⟨s, φ, l⟩ := sf
  have hsrc : SatAt M Om hist tv ⟨s, φ, l⟩ := hst.sat _ hmem
  cases s
  case neg => simp only [applyRule]; trivial
  case pos =>
    simp only [SatAt] at hsrc
    simp only [applyRule]
    split
    all_goals try trivial
    rename_i ψ
    split
    · trivial
    · rename_i t' _ hgap
      have hmemf : t' ∈ ord.futureOf l.time :=
        List.mem_of_mem_filter (a := t') (by rw [hgap]; exact List.mem_cons_self)
      have hltt : tv l.time < tv t' := hst.lt_of_mem_futureOf hmemf
      obtain ⟨d, hlt, hlt'⟩ := exists_between hltt
      refine ⟨hist, Function.update tv b.nextTime d, hst.shiftClosed, hst.histMem,
        ordResp_addFuture_addFuture_update hst hord (mem_knownTimes_of_mem_branch hmem)
          (mem_knownTimes_of_mem_futureOf hord hmemf) hlt hlt', ?_⟩
      intro g hg
      rcases List.mem_append.mp hg with hnew | hb
      · rcases List.mem_cons.mp hnew with rfl | hrest
        · simpa [SatAt, SignedFormula.pos] using truthAt_of_allFuture hsrc hlt
        · exact satAt_of_mem_gPropsExcept hst hlt hrest
      · exact satAt_update_nextTime_of_mem hb (hst.sat g hb)

/-!
### The `.Discrete` family: `priorUZ`, `priorSZ`, `z1Rule`

All three are *same-label* `.persistent [newSf]` rules that return `timeOrd` **unchanged**, so
none of them consumes `OrdWithin` and none has an ordering obligation at all. What each emits is
exactly the consequent of a discreteness axiom whose antecedent the branch already carries, at
the very same label — so each proof is one instantiation of an already-proved validity lemma
followed by semantic modus ponens against `hst.sat`. There is no new mathematics here and none
should be attempted: `prior_UZ_is_valid`, `prior_SZ_is_valid` and `z1_is_valid`
(`Metalogic/SoundnessLemmas/FrameClassVariants.lean`) already do the `SuccOrder`/`PredOrder`
descent work, and re-deriving it inside the decidability tree would be several hundred lines of
duplicated Mathlib.

**On the import edge.** `FormalSystem.Metalogic.Soundness` remains refused, and this is *not*
that edge. `FrameClassVariants` is a different module with a different import closure —
`FrameClassVariants → DenseValidity → Core → {Semantics.Truth, ProofSystem.Derivation,
ProofSystem.Axioms}` — and nothing anywhere in it imports `Decidability`, so there is no cycle.
The cost is a heavier build edge, not a cycle.

**Why `carrierDiscrete` is an `Exists` and not a conjunction of classes.** `CarrierProp` returns
`Prop`, and `DenselyOrdered` is `Prop`-valued, so `carrierDense` could be written outright.
`SuccOrder` and `PredOrder` are **data** — `Type`-valued classes — so `fun D => SuccOrder D` does
not typecheck as a `CarrierProp`. `Exists` ranges over any `Sort`, so existentially quantifying
the two structures is a legitimate `Prop`, and eliminating that `Exists` is fine because the
goal, `SatResult`, is itself a `Prop`. Each proof below opens by destructuring it and reinstating
the four instances with `haveI`.

**The other three frame-class rules are NOT landed, and the reason is not budget.** `priorUGap`,
`priorSGap` and `sepRule` (`.Dedekind`) would need `prior_U_gap_valid`, `prior_S_gap_valid` and
`sep_valid`. Those three exist **only** in `FormalSystem/Metalogic/Soundness.lean` — the module
whose import edge into this tree is refused — and `FrameClassVariants` does **not** carry them.
So the reuse argument that unblocks the discrete three does not transfer, and no
`carrierDedekind` is declared here: a frame-class carrier property is declared only in the step
that consumes one, and nothing consumes that one yet.
-/

/-- Discreteness of the carrier, as the three `.Discrete` rules consume it.

Existentially quantified because `SuccOrder`/`PredOrder` are data; see the section docstring. -/
def carrierDiscrete : CarrierProp := fun D =>
  ∃ (hs : SuccOrder D) (hp : PredOrder D), @IsSuccArchimedean D _ hs ∧ @IsPredArchimedean D _ hp

/-- `T(F ψ)` gives `T(U(ψ, ¬ψ))` at the **same** label — the consequent of Prior-UZ, whose
antecedent is the source formula. On a discrete order `F ψ` has a *nearest* `ψ`-point, and `¬ψ`
guards the interval strictly below it; that is the whole content, and it is
`prior_UZ_is_valid`. -/
theorem ruleSound_priorUZ : RuleSound carrierDiscrete .priorUZ := by
  intro D _ _ _ _ hC F M Om hist tv b sf ord hmem hst _
  obtain ⟨hs, hp, ha, hb⟩ := hC
  -- `letI`, not `haveI`, for the two DATA instances: `haveI` is opaque, so the installed
  -- `SuccOrder` would not be defeq to `hs`, and `ha : @IsSuccArchimedean D _ hs` would then fail
  -- to typecheck against it. The two `Prop` fields may stay `haveI`.
  letI := hs
  letI := hp
  haveI := ha
  haveI := hb
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asSomeFuture? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = Formula.someFuture ψ := asSomeFuture?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ] at hsrc
      simp only [applyRule, hA]
      split
      · trivial
      · refine ⟨hist, tv, hst.append ?_⟩
        intro c hc
        rw [List.mem_singleton] at hc
        subst hc
        simpa [SatAt, SignedFormula.pos] using
          SoundnessLemmas.prior_UZ_is_valid ψ F M Om hst.shiftClosed (hist l.world)
            (hst.histMem l.world) (tv l.time) hsrc

/-- `T(P ψ)` gives `T(S(ψ, ¬ψ))` at the same label — Prior-SZ, the exact time reversal of
`priorUZ`. -/
theorem ruleSound_priorSZ : RuleSound carrierDiscrete .priorSZ := by
  intro D _ _ _ _ hC F M Om hist tv b sf ord hmem hst _
  obtain ⟨hs, hp, ha, hb⟩ := hC
  -- `letI`, not `haveI`, for the two DATA instances: `haveI` is opaque, so the installed
  -- `SuccOrder` would not be defeq to `hs`, and `ha : @IsSuccArchimedean D _ hs` would then fail
  -- to typecheck against it. The two `Prop` fields may stay `haveI`.
  letI := hs
  letI := hp
  haveI := ha
  haveI := hb
  obtain ⟨s, φ, l⟩ := sf
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    cases hA : asSomePast? φ with
    | none => simp [applyRule, hA, SatResult]
    | some ψ =>
      have hφ : φ = Formula.somePast ψ := asSomePast?_eq_some hA
      have hsrc : SatAt M Om hist tv ⟨.pos, φ, l⟩ := hst.sat _ hmem
      simp only [SatAt, hφ] at hsrc
      simp only [applyRule, hA]
      split
      · trivial
      · refine ⟨hist, tv, hst.append ?_⟩
        intro c hc
        rw [List.mem_singleton] at hc
        subst hc
        simpa [SatAt, SignedFormula.pos] using
          SoundnessLemmas.prior_SZ_is_valid ψ F M Om hst.shiftClosed (hist l.world)
            (hst.histMem l.world) (tv l.time) hsrc

/-- `T(G(Gφ → φ))` together with `T(F(Gφ))` at the same label gives `T(Gφ)` there — Z1, the
discrete backward-induction axiom. Unlike the other two `.Discrete` rules this one is *binary*:
its second premise is read off the branch by `branch.contains` rather than from the source
formula, so the proof instantiates `z1_is_valid` and then applies it to **two** hypotheses, the
source's `hst.sat` and the partner's. -/
theorem ruleSound_z1Rule : RuleSound carrierDiscrete .z1Rule := by
  intro D _ _ _ _ hC F M Om hist tv b sf ord hmem hst _
  obtain ⟨hs, hp, ha, hb⟩ := hC
  letI := hs
  letI := hp
  haveI := ha
  haveI := hb
  obtain ⟨s, φ, l⟩ := sf
  have hsrc : SatAt M Om hist tv ⟨s, φ, l⟩ := hst.sat _ hmem
  cases s
  case neg => simp [applyRule, SatResult]
  case pos =>
    simp only [SatAt] at hsrc
    simp only [applyRule]
    split
    all_goals try trivial
    split
    all_goals try trivial
    split
    all_goals try trivial
    split
    all_goals try trivial
    -- The six surviving inaccessible binders, in context order: the sign equation, the outer
    -- match's `φ_inner`, the two formula pattern variables, and the two `if` conditions.
    rename_i _heq _φi inner rhs hbeq hfg
    have hrhs : inner = rhs := by simpa using hbeq
    subst hrhs
    -- `Branch.contains` is a `List.any` over `==`, not `List.elem`, so the standard
    -- `mem_of_elem_eq_true` does not apply; unfold it and read the witness off.
    have hfgmem : SignedFormula.pos inner.allFuture.someFuture l ∈ b := by
      simp only [Branch.contains, List.any_eq_true] at hfg
      obtain ⟨x, hx, heq⟩ := hfg
      exact beq_iff_eq.mp heq ▸ hx
    have hfgs := hst.sat _ hfgmem
    simp only [SatAt, SignedFormula.pos] at hfgs
    split
    · trivial
    · refine ⟨hist, tv, hst.append ?_⟩
      intro c hc
      rw [List.mem_singleton] at hc
      subst hc
      simpa [SatAt, SignedFormula.pos] using
        SoundnessLemmas.z1_is_valid inner F M Om hst.shiftClosed (hist l.world)
          (hst.histMem l.world) (tv l.time) hsrc hfgs

/-!
## `untlNeg` and `snceNeg` — BLOCKED, two independent engine defects

**Status.** `untlPos` and `sncePos` are proved above; the copy defect described below was
repaired for those two arms by deleting the block, gated on the full conformance corpus. This
section is retained because `untlNeg`/`snceNeg` are still blocked, and they are blocked
**twice**: their ACTIVE arms still carry the copy block, and their PASSIVE arms carry a second,
wholly independent unsoundness. Everything below stated in the present tense holds of
`untlNeg`/`snceNeg`; for `untlPos`/`sncePos` read it in the past tense.

Neither obstruction is the ordering gap this section's predecessors were about. That gap is
closed: `OrdWithin` is in `RuleSound`, and the four fresh-time existentials above are proved
against it.

**Defect 1, the copy.** The ACTIVE arm of `untlNeg`/`snceNeg` (and, before its deletion,
`untlPos`/`sncePos`)
emits an `untlNegProps` block that copies every `F(U(e', g'))` sitting at the trigger's time
*unconditionally* to the freshly minted time. `Formula.untl` is evaluated along one history and
its truth is interval-relative, so `F(U(e', g'))` at `t` does not imply `F(U(e', g'))` at a later
time. Unlike the `□`/`◇` copies that `boxDiamondPersistence` performs, there is no shift-closure
argument available: the claim is not `Ω`-universal.

**The counterexample**, over `ℤ`. `RuleSound` quantifies over *all* carriers, so a refutation
over one carrier refutes the statement, and discrete time is what makes the refutation work
(see the retraction note below for why a dense carrier does not).

*Frame.* `D = ℤ`, `F.WorldState = ℤ`, `TaskRel w d u ⟺ u = w + d`. `τ` is the identity history:
total domain, `states t = t`. `Om` is the **shift orbit of `τ`** — `ShiftClosed` by construction,
with every member of total domain. `Om = Set.univ` must NOT be used; see the trap below.

*Valuation*, on four atoms (`event = p`, `guard = q`, `e' = r`, `g' = s`):

```
V(n,p) ⟺ n = 5     V(n,q) ⟺ n ≥ 1     V(n,r) ⟺ n ≥ 2     V(n,s) ⟺ n ≠ 1
```

which gives `U(p,q)@a ⟺ 0 ≤ a ≤ 4` (the sole `p`-witness is `5`, and `(a,5)` must avoid `0`) and
`U(r,s)@x ⟺ x ≥ 1` (for `x ≥ 1` take the witness `max(x+1,2)` over an empty guard interval; for
`x ≤ 0` every `r`-witness is `≥ 2 > 1 > x`, so `1` lies in the interval and `s@1` fails).

*Branch.* `b = [T(U(p,q))@(w₀,0), F(U(r,s))@(w₀,0)]`, `sf` the first, `ord = TimeOrdering.empty`.
`OrdWithin` holds vacuously and `SatState` holds with `tv 0 = 0`.

*Rule output.* `freshTime = b.nextTime = 1`, `newOrd = addFuture 0 1`; `gProps`, `fNegProps` and
`modalProps` are all empty, and `untlNegProps = [F(U(r,s))@(w₀,1)]`, so

```
branch1 = [T(p)@(w₀,1), F(U(r,s))@(w₀,1)]
branch2 = [T(q)@(w₀,1), T(U(p,q))@(w₀,1), F(U(r,s))@(w₀,1)]
```

*Both successors are unsatisfiable.* Write `A = tv'(0)`, `C = tv'(1)`. Carrying `b` forces
`0 ≤ A ≤ 4` and `A ≤ 0`, hence `A = 0`; `ordResp` on `newOrd` forces `C ≥ 1`. Branch 1 needs
`p@C`, i.e. `C = 5`, against the copied `¬U(r,s)@C`, i.e. `C ≤ 0`. Branch 2 needs `U(p,q)@C`,
i.e. `C ≤ 4`, together with `C ≤ 0` from the same copy, against `C ≥ 1`. A satisfiable branch is
mapped to two unsatisfiable ones, so `RuleSound carrierBase .untlPos` is false as stated. The
copy is precisely the culprit: delete `untlNegProps` and branch 1 is satisfied by `A = 0, C = 5`.
`sncePos` follows by the time-reversal mirror of this model.

**Retraction — the earlier `{1/n}` counterexample recorded here was WRONG.** It made `e'` true
exactly on `{1/n : n ≥ 1}` and `g'` false there, and argued that every admissible interpretation
of `freshTime` lies in `(0,1)` where `U(e',g')` is true. That argument fails because `SatResult`
lets the successor re-choose `tv` **wholesale**, not just at the fresh index: the fresh time's
interpretation is free anywhere above the trigger's, and on a dense carrier there is always room
above the failure point, so the successor escapes. (This is the same failure mode that sank a
still earlier single-witness draft.) A working refutation must make the region where the *source*
branch is satisfiable a single **maximal** point, leaving no room above it — which is what the
`ℤ` model does, and what no dense carrier can do. Recorded so that a third wrong version is not
attempted.

**Formalization trap.** With `Om = Set.univ` the counterexample is rescued and becomes no
counterexample at all: a history with domain `(-∞,5]` kills every `r`-point above `5`, making
`¬U(r,s)@5` vacuously true and branch 1 satisfiable. Any Lean formalization must therefore fix
`Om` to the shift orbit of a *total-domain* history — legitimate, since `Om` is the
counterexample's to choose and only `ShiftClosed` is required of it.

**Isolation — FIVE unsound sites, not four, and `untlNeg`/`snceNeg` carry two independent
obstructions.** The four copy blocks are one family: `untlPos`, `sncePos`, and the ACTIVE arm of
`untlNeg`/`snceNeg`. The PASSIVE arms are a **second, independent** family, and the claim
previously recorded here — that the PASSIVE arm "emits no such block, returns `timeOrd`
unchanged, and is sound; it is provable today" — is **refuted**. For `a < c`, `¬U(e,g)@a` implies
only `¬e@c ∨ ∃ z ∈ (a,c). ¬g@z`: the guard failure lies strictly *between* `a` and `c`, whereas
the arm places it *at* `c` and additionally re-asserts `¬U(e,g)@c` — the same interval-relative
propagation as the copy defect. Over `ℤ` with `e` true exactly at `3` and `g` false exactly at
`1`: `¬U(e,g)@0` holds, yet `e@3` and `g@3` are both true, so both emitted arms fail; and `¬g@1`
holds while `U(e,g)@1` is true, which independently refutes branch 2's second conjunct. A
refutation of `RuleSound carrierBase .untlNeg` using no copy block at all: same frame and `Om`,
atoms `e, g, x` with `V(n,e) ⟺ n = 3`, `V(n,g) ⟺ n ≠ 1`, `V(n,x) ⟺ n = 3`, branch
`[F(U(e,g))@(w₀,0), T(x)@(w₀,1)]` with `ord = ⟨[(0,1)]⟩` and `tv 0 = 0`, `tv 1 = 3`. The pinning
formula `T(x)@t₁` is not exotic — `someFuturePos` produces exactly that shape with exactly that
ordering constraint.

**Required behaviour, and why the two families are handled differently.**

* For `untlPos`/`sncePos` the fix was **deletion** of the copy block, on the group-3 precedent
  below — **done**, and the two rules are proved above. A guarded copy was not available:
  soundness would need `¬U(e',g')@A → ¬U(e',g')@C` for a freshly chosen `C > A`, a semantic
  condition on the model that no syntactic guard computable from `(branch, ord)` expresses.
  Deletion can only make branches *harder* to close, so its risk was under-closing, which the
  conformance corpus measures directly: all 29 rows are unchanged by the deletion. In the other
  direction the deletion is a strict gain — `UntlSnceCopyProbe.lean` row C2 shows the engine now
  returns a countermodel for the invalid `U(p,q) → U(r,s)` where it previously exhausted its
  fuel, because the copy had been closing off the branches a countermodel is read from.
* For `untlNeg`/`snceNeg` deletion is **necessary but not sufficient** — it leaves the PASSIVE
  defect intact, and `RuleSound` is per rule. The sound restatement is an adjacency-aware
  co-decomposition (mint an interpolant `z` with `t < z < t'` and emit `F(guard)@z`), which turns
  the PASSIVE arm into a fresh-time producer and so carries termination and completeness
  consequences of exactly the kind `densityRule`'s gap-selection comment documents. That change
  is *not* authorized here and is escalated rather than improvised.

**What this does *not* affect.** Nothing above this section. The four fresh-time existentials
mint their witness the same way and are unaffected, because their propagation families are `G`/`H`
universals, `F`/`P` negatives and the `□`/`◇` copies — every one of which *is* preserved in the
required direction, which is why they went through.
-/

/-!
## What `boxNeg` and `diamondPos` owed, and how it was discharged — RESOLVED

`ruleSound_boxNeg` and `ruleSound_diamondPos` are proved above. This section is kept as the
record of why they could not be proved before, because the reason was an unsound *engine* step
rather than a missing proof, and because the sequence of measurements that established it is the
one methodological result of this sub-phase worth keeping.

**Summary of the resolution.** Both rules emitted a third group of formulas — six blocks copying
`T(GB)`, `T(HB)`, `F(FB)`, `F(PB)`, `F(U(B,C))` and `F(S(B,C))` from the trigger's time into the
freshly minted world. That group does not preserve satisfiability, and it was *reachable*: the
engine closed the invalid `(G p) → □(G p)`. The six blocks were removed from `applyRule`, with
the full conformance corpus as the acceptance gate; `applyRule`'s docstring now carries the
prohibition against reintroducing them. With group 3 gone, what remains is groups 1 and 2, and
those are exactly what `satAt_of_mem_boxProps` and `satAt_of_mem_diaProps` discharge. The two
theorems above are therefore not merely newly proved but newly *true*.

**Three lessons, each of which overturned the previous dispatch's conclusion.**

* *A scheduling argument needs a consumption argument.* The claim that `boxNeg` never sees an
  undecomposed `T(G p)`, because the propositional rules run first, is unsound in any additive
  tableau — and this engine is additive by design (`expandOnceUnblocked` reads a `.linear` output
  as `formulas ++ b`, so no rule's source formula is ever consumed).
* *A measurement has a value and a meaning, and reusing the value reopens the question of the
  meaning.* `isValid φ = false` was read as "the engine judged `φ` invalid". It is also what
  `extractionFailed` reports — a tableau that closed, followed by a failed proof reconstruction.
  Discriminate with `isInvalid`/`getCountermodel?`, never with `isValid` alone.
* *Before pricing two branches of a fork, test what they agree on.* The fork over weakening
  `RuleSound` by a reachability hypothesis dissolved once the premise both branches shared — that
  the engine does not build the refuting branch — was measured and found false.

The probes that pin all of this are `Tests/BimodalTest/CrossWorldPropagationProbe.lean` (verdicts),
`BoxNegPreservationProbe.lean` (the step), and `BoxNegReachabilityProbe.lean` (reachability).

## The historical record

Before the engine change, both rules emitted three groups at the minted world `branch.nextWorld`:

1. the **witness** — `F(A)` for `boxNeg`, `T(A)` for `diamondPos`;
2. the **modal propagation** — every `T(□B)` and `F(◇B)` on the branch, copied to the fresh
   world at its own time;
3. the **cross-modal-temporal propagation** — every `T(GB)`, `T(HB)`, `F(FB)`, `F(PB)`,
   `F(U(B,C))` and `F(S(B,C))` *at the source label's time*, copied to the fresh world at that
   same time.

Groups 1 and 2 are exactly the argument `boxPos`/`diamondNeg` already make, plus a one-point
update of `hist` at an index absent from the branch (`Tableau.not_mem_of_world_nextWorld`).
Group 3 is not: `T(GB)` at one history says nothing *prima facie* about another history, since
`G` is evaluated inside a single history and the witness `σ` is chosen for the witness condition
alone. Discharging it means showing the witness can always be chosen to satisfy the copied
temporal formulas too, and no such argument is in the tree.

**The verdict measurement, and its limit.** `Tests/BimodalTest/CrossWorldPropagationProbe.lean`
runs the full decision procedure on the three shapes that would expose an unsound group-3 copy as
a wrong *verdict* — `(¬F p) → □(¬F p)`, `(G p) → □(G p)` and `(¬P p) → □(¬P p)`, each invalid
because `Ω` may hold a history with a future (resp. past) `p` while `τ` has none. All three report
`false`, the correct answer, alongside a `true` control and a `false` control. That probe was
explicit that it measured verdicts and not steps, and it was right to be.

**The step has now been measured, and it is unsound.**
`Tests/BimodalTest/BoxNegPreservationProbe.lean` applies `boxNeg` directly to the branch that
verdict-row B negates into — `T(G p) @ (w₀,t₀)`, `F(□(G p)) @ (w₀,t₀)`, which is *satisfiable*
exactly because `(G p) → □(G p)` is invalid — and pins what comes back. The rule emits exactly
two formulas, both at the minted label `(w₁, t₀)`: the witness `F(G p)`, and `T(G p)` copied by
group 3 from `w₀`. Same formula, same label, opposite signs. `SatAt` reads that pair as
`TruthAt …` together with `¬ TruthAt …` at one point, so no choice of `hist` or `tv` satisfies
the successor. A satisfiable branch has been mapped to an unsatisfiable one, and therefore

* `RuleSound carrierBase .boxNeg` is **false** — `ruleSound_boxNeg` is not unproved but
  unprovable, and `diamondPos` carries an identical `tempGProps` block; and
* the assembly `∀ r ∈ allRulesForFC fc, RuleSound _ r` cannot be proved in the present shape,
  because `boxNeg` and `diamondPos` are both members of `allRulesForFC` at every frame class.

**The branch is reachable, and the escape that was hoped for is closed.**
`Tests/BimodalTest/BoxNegReachabilityProbe.lean` measures what this section previously asserted
in the other direction. The earlier text read that "no engine defect is claimed", on the ground
that the engine never applies `boxNeg` to that branch because `T(G p)` is an `imp` whose
propositional decomposition comes first. Three measurements refute it:

* **Expansion is additive.** `expandOnceUnblocked` reads a `.linear` output as `formulas ++ b`,
  so decomposing `T(G p)` never removes it, and `tempGProps` filters the branch by *shape*, with
  no regard to whether a formula has been expanded. `boxNeg` also precedes the *branching*
  propositional rules (`impPos`, `andNeg`, `orPos`) in `allRules`.
* **The rule fires.** Driven from `b0` by the engine's own selector, `boxNeg` mints the world and
  the clash appears: `T(G p)` and `F(G p)` at one label. The branch closes on that contradiction,
  and the closure reason is pinned as `contradiction` at the minted world, not a negated axiom.
* **The tableau therefore answers wrongly.** `buildTableau ((G p) → □(G p))` returns `allClosed`
  — reporting an invalid formula valid.

**And the reading of the verdict row was wrong.** `isValid` returned `false`, which this section
took for the correct verdict on an invalid formula. `decide` in fact returns **`extractionFailed`**:
the tableau closed, and proof extraction then failed. `isInvalid` is `false` and
`getCountermodel?` is `none`. `isValid`'s `false` conflates "judged invalid" with "claimed valid,
then could not build the proof term", and only the second occurred. The distinction between
"the step is unsound" and "the procedure answers wrongly" was the right distinction to insist on;
what was wrong was believing the second had been measured and found clean.

**What this costs.** There is no branch invariant that admits the branches the engine builds and
excludes the refuting one, because they are the same branch — so weakening `RuleSound` by a
reachability hypothesis cannot work, and that fork is closed rather than open. Group 3 is
unsound as a semantic step *and* reachable, so the only repair that makes this sub-phase's target
true is an engine change: the six group-3 blocks in `boxNeg` and `diamondPos` do not preserve
satisfiability and no hypothesis available at the rule level rescues them. Groups 1 and 2 are
sound and are not implicated. That change is outside this module — it edits `applyRule` itself —
and it must be planned rather than improvised, because removing the blocks can only make branches
*harder* to close and so risks the opposite failure on the conformance corpus. It is recorded as
a blocker rather than attempted here.

*(End of the historical record. The engine change described in that last paragraph was
subsequently made, gated on the full conformance corpus, and the two rules are proved above. Every
claim above stated in the present tense should be read as holding of the calculus **before** that
change — in particular "`RuleSound carrierBase .boxNeg` is false" was true of the old engine and
is not true now.)*
-/

end FormalSystem.Metalogic.Decidability.Verified

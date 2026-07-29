/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.RuleSpec
import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel
import FormalSystem.Semantics.Validity

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

Still owed by sub-phase 7.2: the two fresh-world modal rules `boxNeg` and `diamondPos`; the eight
temporal quantifier rules; `untlPos`/`untlNeg`/`sncePos`/`snceNeg`; `orderTrichotomy`; the two
dense, three discrete and three Dedekind rules; and the assembly
`∀ r ∈ allRulesForFC fc, RuleSound _ r` via `RuleSpec.mem_allRulesForFC_iff`.

`boxNeg` and `diamondPos` are held back deliberately rather than merely unfinished — see
"What `boxNeg` and `diamondPos` still owe" at the end of this file for the open obligation and
for what measurement has and has not settled about it.

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

/--
**Semantic soundness of one tableau rule.** If the branch is satisfied and the rule's source
formula is on it, then the rule's output preserves satisfiability.

Quantifying over *all* `sf`, not only those the rule applies to, is deliberate: `applyRule`
answers `.notApplicable` on a mismatched sign or shape, and `SatResult` reads that as `True`, so
the mismatched cases cost one `simp` each rather than a side condition in the statement.
-/
def RuleSound (C : CarrierProp) (r : TableauRule) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D],
    C D → ∀ (F : TaskFrame D) (M : TaskModel F) (Om : Set (WorldHistory F))
      (hist : WorldIndex → WorldHistory F) (tv : TimeIndex → D)
      (b : Branch) (sf : SignedFormula) (ord : TimeOrdering),
      sf ∈ b → SatState M Om hist tv b ord →
      SatResult M Om b (applyRule r sf b ord).1 (applyRule r sf b ord).2

/-- A rule sound under a weaker carrier property is sound under a stronger one. This is what lets
the base family be proved once at `carrierBase` and reused verbatim at `.Dense`, `.Discrete` and
`.Dedekind`, and it is why no frame-class carrier property needs declaring until a rule actually
consumes it. -/
theorem RuleSound.mono {C C' : CarrierProp} {r : TableauRule}
    (hle : ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D], C' D → C D)
    (h : RuleSound C r) : RuleSound C' r := by
  intro D _ _ _ _ hC F M Om hist tv b sf ord hmem hst
  exact h D (hle D hC) F M Om hist tv b sf ord hmem hst

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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
  intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
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
## What `boxNeg` and `diamondPos` still owe

Both fresh-world rules emit three groups of formulas at the minted world `branch.nextWorld`:

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

**What was measured, and what it settled.** `Tests/BimodalTest/CrossWorldPropagationProbe.lean`
runs the full decision procedure on the three shapes that would expose an unsound group-3 copy as
a wrong *verdict* — `(¬F p) → □(¬F p)`, `(G p) → □(G p)` and `(¬P p) → □(¬P p)`, each invalid
because `Ω` may hold a history with a future (resp. past) `p` while `τ` has none. All three report
`false`, the correct answer, alongside a `true` control and a `false` control. So the suspicion
that group 3 makes the engine *decide wrongly* is **not** confirmed, and nothing here is recorded
as an engine defect: there is no counterexample, and under the defect bar a suspicion without one
is not a finding.

What the probe does *not* settle is the proof obligation. "No wrong verdict on three shapes" is
not "the step preserves satisfiability", and the two are independent — a step can fail to
preserve satisfiability while every branch it spoils happens to be closable another way. Both
rules are therefore left open with the obligation stated rather than proved with a gap, and the
next dispatch on them should start from the probe, not from this note.
-/

end FormalSystem.Metalogic.Decidability.Verified

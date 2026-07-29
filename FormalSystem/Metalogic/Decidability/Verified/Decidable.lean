/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.RuleSpec
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

Landed: the framework, and the eight truth-functional rules (`andPos`, `andNeg`, `orPos`,
`orNeg`, `impPos`, `impNeg`, `negPos`, `negNeg`).

Still owed by sub-phase 7.2: the four S5 modal rules and `boxTemporal`; the eight temporal
quantifier rules; `untlPos`/`untlNeg`/`sncePos`/`snceNeg`; `orderTrichotomy`; the two dense,
three discrete and three Dedekind rules; and the assembly
`∀ r ∈ allRulesForFC fc, RuleSound _ r` via `RuleSpec.mem_allRulesForFC_iff`.

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

The three fields are independent obligations and all three are load-bearing:

* `histMem` — every branch world lands in `Ω`. `□` quantifies over `Ω`, so without this a
  `T(□A)` on the branch would say nothing about the branch's own other worlds.
* `ordResp` — every recorded ordering constraint is a genuine strict inequality in `D`. This is
  what a fresh-time rule has to re-establish for the *extended* ordering it returns.
* `sat` — every signed formula on the branch is satisfied.
-/
structure SatState (M : TaskModel F) (Om : Set (WorldHistory F))
    (hist : WorldIndex → WorldHistory F) (tv : TimeIndex → D)
    (b : Branch) (ord : TimeOrdering) : Prop where
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
  ⟨h.histMem, h.ordResp, fun sf hsf => h.sat sf (hsub sf hsf)⟩

/-- Build a state on `fs ++ b` from a state on `b` plus satisfaction of each added formula. The
shape every non-branching rule's proof ends in. -/
theorem SatState.append {M : TaskModel F} {Om : Set (WorldHistory F)}
    {hist : WorldIndex → WorldHistory F} {tv : TimeIndex → D} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula} (h : SatState M Om hist tv b ord)
    (hfs : ∀ sf ∈ fs, SatAt M Om hist tv sf) :
    SatState M Om hist tv (fs ++ b) ord :=
  ⟨h.histMem, h.ordResp, by
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

end FormalSystem.Metalogic.Decidability.Verified

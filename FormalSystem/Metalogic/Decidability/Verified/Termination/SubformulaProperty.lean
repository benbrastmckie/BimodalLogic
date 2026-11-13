/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Tableau

/-!
# T1 — The Generalized Signed Subformula Property

Expansion never invents a formula from outside a fixed finite stock. That is the first of the
three termination facts (WP3 T1): without it the pigeonhole argument of `TimeTypeBound.lean` has
nothing finite to count time-types against.

## Why the closure is not `subformulaClosure`, and not `closureWithNeg` either

The plan's constraint 7 records that plain `subformulaClosure` is too small, because `priorUZ`
emits `U(φ, ¬φ)` and `¬φ` is not a subformula of `F φ`. That is correct but not the whole story,
and the correction is recorded here rather than assumed: `closureWithNeg φ` — which is
`subformulaClosure φ ∪ image neg` — is *also* too small, because it contains `¬φ` but not
`U(φ, ¬φ)`, and `U(φ, ¬φ)` is exactly what the rule emits. Six rules emit formulas that are
neither subformulas nor negations of subformulas of anything already present:

| Rule | Trigger | Emits | In `closureWithNeg`? |
|------|---------|-------|----------------------|
| `boxTemporal` | `T(□ψ)` | `T(Gψ)`, `T(Hψ)` | no |
| `serialityRule` | anything | `T(F⊤)`, `T(P⊤)` | no |
| `priorUZ` | `T(Fψ)` | `T(U(ψ, ¬ψ))` | no |
| `priorSZ` | `T(Pψ)` | `T(S(ψ, ¬ψ))` | no |
| `priorUGap` / `priorSGap` | `T(U(⊤,g) ∧ F¬g)` | `T(U(¬g ∨ K⁺¬g, g))` | no |
| `sepRule` | `T(K⁺ψ ∧ ¬K⁺(ψ ∧ U(ψ,¬ψ)))` | `T(K⁺(K⁺ψ ∧ K⁻ψ))` | no |
| `orderTrichotomy` | `T(φ)` + sibling `T(ψ)` | the three `temp_linearity` disjuncts | no |

So T1 is stated here against an **abstract closure predicate** `TableauClosed C` rather than
against a fixed closure operator: `C` is any formula set closed under subformulas plus the seven
non-analytic emissions above. This is the decomposition the phase needs, for two reasons.

1. It keeps the 36-case analysis honest. Each field of `TableauClosed` is consumed by exactly one
   rule case, so a rule that emits something unaccounted for cannot be waved through — there is
   no field to close its goal with. The field list *is* the census of non-analytic emissions.
2. It separates T1 from the size bound. `TimeTypeBound.lean` (T2) needs a *concrete* `C` with a
   cardinality; T1 needs only closure. Proving them against the same abstract interface means the
   concrete construction can be tuned without touching the 36 cases.

Three rules initially suspected of needing their own field turn out not to:

* **`z1Rule`** emits `T(G inner)` from `T(G(G(inner) → inner))`. `G X` unfolds to
  `(U(¬X, ⊤)) → ⊥`, so the trigger's inner formula is `(G inner → ⊥) → inner` — wait, more
  precisely `.imp (.imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot) rhs`, whose left operand
  `.imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot` *is* `G inner` on the nose. It is a
  genuine subformula, so `sub` covers it.
* **`densityRule`** emits `T(ψ)` from `T(Gψ)` plus relabelled `T(inner)` for branch formulas
  `T(G inner)`; both are subformulas.
* **`timeLinearity`** emits no formulas at all. Its three arms carry `branch` twice and
  `branch.identifyTime (min t₁ t₂) (max t₁ t₂)` once, and identification is label-only
  (`identifyTime_formula_mem` below), so nothing leaves `C`.

## Why the fields are keyed on the rules' *whole* triggers (the finiteness repair)

An earlier version of `TableauClosed` keyed `gapU`, `gapS` and `sep` on a *part* of each rule's
trigger, and carried `orderTrichotomy`'s condition as a fourth field `trich`. That version was
satisfied by **no finite `C`**, which would have left `TimeTypeBound.lean` with nothing to count.
The three failures were machine-checked against these definitions rather than argued informally:

* `sep`, keyed on `K⁺ψ`, applied to its own conclusion — `hC.sep _ (hC.sep _ h)` typechecked,
  since `K⁺(K⁺ψ ∧ K⁻ψ)` is again of the form `K⁺ψ′`.
* `gapU`/`gapS`, keyed on `U(⊤, g)`, re-triggered through `sub`: the conclusion
  `U(¬g ∨ K⁺¬g, g)` has `K⁺¬g = ¬U(⊤, ¬¬g)` as a subformula, so `U(⊤, ¬¬g) ∈ C` and the field
  fired again on `¬¬g`.
* `trich` re-triggered on its own second disjunct: `F(x ∧ Fy)` is itself of the form `F(x ∧ y′)`
  with `y′ = Fy`, so the field yielded `F(x ∧ FFy)`, then `F(x ∧ FFFy)`, …

Every chain strictly increases formula size, so widening `C` cannot absorb them. The root cause
was uniform — **each field was keyed on strictly less than the rule's real trigger** — and so is
the repair, in two shapes:

1. **Conjunctive re-keying** (`gapU`, `gapS`, `sep`). `priorUGap` fires on `U(⊤,g) ∧ F¬g`, not
   on `U(⊤,g)`; `sepRule` fires on `K⁺ψ ∧ ¬K⁺(ψ ∧ U(ψ,¬ψ))`, not on `K⁺ψ`. The fields now say
   so. `sub` never produces a conjunction from a conclusion, so none of the three re-fires. The
   rule cases got *shorter*: `hC.gapU _ hsf` replaced `hC.gapU _ (hC.and_left hsf)`, because
   after the `asAnd?` inversion `hsf` already carries the whole conjunction.
2. **Migration to the branch** (`trich`). `orderTrichotomy` fires only when the branch carries
   the *negation* of a disjunct at the common predecessor. That is a statement about the branch,
   not about `C`, so no `C`-side field can express it faithfully, and the unfaithful
   approximation is exactly what made `C` infinite. The condition now lives in `TrichClosed C b`
   below and reaches `applyRule_subformula_closed` as a hypothesis, to be discharged by the
   branch invariant `Fuel.lean` carries.

`TableauClosed` is now a condition on `C` alone whose every field is triggered by a formula that
its own conclusions never reproduce; `TimeTypeBound.lean` builds the concrete finite witness.

## The `.branchingOrdered` obligation

`timeLinearity` is the only rule returning `.branchingOrdered`, and its arms carry *whole
branches* rather than additions. `RuleResult.emitted` therefore flattens the arm branches, which
makes the theorem's conclusion strictly stronger than "the added formulas stay in `C`": it says
the whole post-rule branch stays in `C`. That is the form `Fuel.lean` consumes, since the fuel
loop's invariant is about branches, not deltas.

## Main definitions

- `RuleResult.emitted` — every signed formula a rule result puts on some successor branch.
- `TableauClosed` — the closure conditions, one field per non-analytic emission.

## Main theorems

T1 is landed **one rule at a time**, as `applyRule_<rule>_closed`: if the trigger formula (and,
where the rule reads the branch, every branch formula) lies in a `TableauClosed` set, so does
everything that rule emits. All thirty-six rules are proved here; the section note above
`applyRule_andPos_closed` explains why one-rule-per-declaration is forced rather than stylistic.

`applyRule_subformula_closed` then assembles them by `cases rule`. That assembly is deliberately
last rather than first: stating it before the cases existed would have meant either asserting the
property for unproved rules or carrying a hypothesis enumerating the proved ones, and `cases rule`
does not unfold `applyRule`, so the combined statement costs nothing once the cases are in hand.
-/

set_option linter.style.longFile 1700

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)

/-! ## What a rule result puts on the branch -/

/--
Every signed formula that a rule result places on some successor branch.

`linear`/`persistent` contribute their additions; `branching` contributes every arm's additions;
`branchingOrdered` contributes every arm's *entire* branch, since that constructor replaces the
branch rather than extending it. `notApplicable` contributes nothing.
-/
def RuleResult.emitted : RuleResult → List SignedFormula
  | .linear fs => fs
  | .branching bss => bss.flatten
  | .branchingOrdered bs => (bs.map Prod.fst).flatten
  | .persistent fs => fs
  | .notApplicable => []

@[simp] theorem RuleResult.emitted_linear (fs : List SignedFormula) :
    (RuleResult.linear fs).emitted = fs := rfl

@[simp] theorem RuleResult.emitted_persistent (fs : List SignedFormula) :
    (RuleResult.persistent fs).emitted = fs := rfl

@[simp] theorem RuleResult.emitted_branching (bss : List (List SignedFormula)) :
    (RuleResult.branching bss).emitted = bss.flatten := rfl

@[simp] theorem RuleResult.emitted_branchingOrdered (bs : List (Branch × TimeOrdering)) :
    (RuleResult.branchingOrdered bs).emitted = (bs.map Prod.fst).flatten := rfl

@[simp] theorem RuleResult.emitted_notApplicable :
    RuleResult.notApplicable.emitted = [] := rfl

/-! ## The closure conditions -/

/--
A formula set closed under everything `applyRule` can emit.

Each field below is consumed by exactly one rule case of `applyRule_subformula_closed`; the field
list is therefore a complete census of the calculus's non-analytic emissions, and adding a rule
that emits something new makes the theorem unprovable rather than silently false.

`sub` alone covers all 29 analytic rules (both propositional families, all modal and temporal
rules, `z1Rule`, `densityRule`, `denseIndicatorClosure`, and `timeLinearity`).
-/
structure TableauClosed (C : Finset Formula) : Prop where
  /-- Closed under subformulas. Covers every analytic rule. -/
  sub : ∀ φ ∈ C, ∀ ψ ∈ Formula.subformulas φ, ψ ∈ C
  /-- `boxTemporal`: `T(□ψ)` yields `T(Gψ)` and `T(Hψ)`, neither a subformula of `□ψ`. -/
  boxTemp : ∀ ψ : Formula, Formula.box ψ ∈ C → ψ.allFuture ∈ C ∧ ψ.allPast ∈ C
  /-- `serialityRule`: `T(F⊤)` at every label, from no trigger at all. -/
  serialFuture : Formula.top.someFuture ∈ C
  /-- `serialityRule`: `T(P⊤)` at every label, from no trigger at all. -/
  serialPast : Formula.top.somePast ∈ C
  /-- `priorUZ` (Discrete): `T(Fψ)` yields `T(U(ψ, ¬ψ))`. The plan's constraint-7 case. -/
  priorU : ∀ ψ : Formula, ψ.someFuture ∈ C → Formula.untl ψ.neg ψ ∈ C
  /-- `priorSZ` (Discrete): `T(Pψ)` yields `T(S(ψ, ¬ψ))`. -/
  priorS : ∀ ψ : Formula, ψ.somePast ∈ C → Formula.snce ψ.neg ψ ∈ C
  /--
  `priorUGap` (Dedekind): the trigger is the **conjunction** `U(⊤, g) ∧ F(¬g)`, which is what
  the rule tests (`asAnd?` then `e == ⊤ && b == F(¬g)`), and it yields `U(¬g ∨ K⁺(¬g), g)`.

  Keying on `U(⊤, g)` alone — the shape this field carried before — makes no finite `C` satisfy
  the structure: the conclusion has `K⁺¬g = ¬U(⊤, ¬¬g)` as a subformula, so `sub` returns
  `U(⊤, ¬¬g)` and the field re-fires on `¬¬g`, forever, at strictly increasing formula size.
  The conjunction is not produced by `sub` from the conclusion, so the real trigger does not
  re-fire.
  -/
  gapU : ∀ g : Formula,
    Formula.and (Formula.untl g Formula.top) (Formula.someFuture g.neg) ∈ C →
    Formula.untl g (Formula.or g.neg (Formula.kPlus g.neg)) ∈ C
  /-- `priorSGap` (Dedekind): past dual of `gapU`, keyed on `S(⊤, g) ∧ P(¬g)`. -/
  gapS : ∀ g : Formula,
    Formula.and (Formula.snce g Formula.top) (Formula.somePast g.neg) ∈ C →
    Formula.snce g (Formula.or g.neg (Formula.kMinus g.neg)) ∈ C
  /--
  `sepRule` (Dedekind): the trigger is `K⁺ψ ∧ ¬K⁺(ψ ∧ U(ψ, ¬ψ))`, yielding `K⁺(K⁺ψ ∧ K⁻ψ)`.

  Keyed on `K⁺ψ` alone the field applied to its own conclusion (`hC.sep _ (hC.sep _ h)`
  typechecks), so no finite `C` satisfied it. The conclusion is a bare `K⁺ψ′`, never the
  conjunction, so the real trigger terminates.
  -/
  sep : ∀ ψ : Formula,
    Formula.and (Formula.kPlus ψ)
        (Formula.neg (Formula.kPlus (Formula.and ψ (Formula.untl ψ.neg ψ)))) ∈ C →
    Formula.kPlus (Formula.and (Formula.kPlus ψ) (Formula.kMinus ψ)) ∈ C

/--
`orderTrichotomy`'s closure condition, stated where its guard actually lives.

This is deliberately **not** a field of `TableauClosed`, and the reason is a measured one. As a
`C`-only condition ("one disjunct present ⇒ all three present") it is satisfied by no finite
`C`: the second disjunct `F(x ∧ F y)` is itself of the shape `F(x ∧ y′)` with `y′ = F y`, so it
re-triggers on its own output and the chain `F(x ∧ y)`, `F(x ∧ F y)`, `F(x ∧ F F y)`, … grows
without bound. Widening `C` cannot absorb that chain, because every step strictly increases
formula size.

The rule's real guard is restriction 4's last conjunct,
`ds.any fun d => branch.contains (SignedFormula.neg d l0)`: the split fires only when the branch
already carries the **negation** of one of the three disjuncts at the common predecessor. That is
a statement about the branch, not about `C`, so it belongs to the branch invariant the fuel loop
carries rather than to the formula stock. Stating it here keeps `TableauClosed` finitely
satisfiable (that is what `TimeTypeBound.lean` needs) while leaving `applyRule` fully covered:
`applyRule_orderTrichotomy_closed` consumes this predicate in place of the deleted field.

The hypothesis is the disjunction the rule's `List.any` unfolds to, in the rule's own disjunct
order, so the rule case discharges it by `exact`.
-/
def TrichClosed (C : Finset Formula) (b : Branch) : Prop :=
  ∀ (x y : Formula) (l0 : Label),
    (b.contains (SignedFormula.neg (Formula.someFuture (Formula.and x y)) l0)
      ∨ b.contains
          (SignedFormula.neg (Formula.someFuture (Formula.and x y.someFuture)) l0)
      ∨ b.contains
          (SignedFormula.neg (Formula.someFuture (Formula.and x.someFuture y)) l0)) →
    (Formula.someFuture (Formula.and x y) ∈ C
      ∧ Formula.someFuture (Formula.and x y.someFuture) ∈ C
      ∧ Formula.someFuture (Formula.and x.someFuture y) ∈ C)

namespace TableauClosed

variable {C : Finset Formula}

/-- `sub` in the argument order the rule cases use: a member's subformula is a member. -/
theorem of_sub (hC : TableauClosed C) {φ ψ : Formula} (h : φ ∈ C)
    (hs : ψ ∈ Formula.subformulas φ) : ψ ∈ C :=
  hC.sub φ h ψ hs

/-! ### One-step component extraction

Discharging each rule case's subformula obligation by running `simp [Formula.subformulas]`
inside the proof is correct but costs more than the whole rest of the case: the propagation-heavy
rules produce tens of goals and the closer is tried on every one. These extract the same facts
once, so the rule cases close by `exact` alone. Every constructor shape below is written in the
raw form `split` leaves behind, for the reason given above the `as*?` inversions.
-/

variable {ψ χ : Formula}

theorem imp_left (hC : TableauClosed C) (h : Formula.imp ψ χ ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem imp_right (hC : TableauClosed C) (h : Formula.imp ψ χ ∈ C) : χ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem box_inner (hC : TableauClosed C) (h : Formula.box ψ ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem untl_left (hC : TableauClosed C) (h : Formula.untl χ ψ ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem untl_right (hC : TableauClosed C) (h : Formula.untl χ ψ ∈ C) : χ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem snce_left (hC : TableauClosed C) (h : Formula.snce χ ψ ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem snce_right (hC : TableauClosed C) (h : Formula.snce χ ψ ∈ C) : χ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

/-- `T(A ∧ B)`: `and ψ χ` is `((ψ → (χ → ⊥)) → ⊥)`. -/
theorem and_left (hC : TableauClosed C)
    (h : Formula.imp (Formula.imp ψ (Formula.imp χ .bot)) .bot ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem and_right (hC : TableauClosed C)
    (h : Formula.imp (Formula.imp ψ (Formula.imp χ .bot)) .bot ∈ C) : χ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

/-- `T(A ∨ B)`: `or ψ χ` is `((ψ → ⊥) → χ)`. -/
theorem or_left (hC : TableauClosed C)
    (h : Formula.imp (Formula.imp ψ .bot) χ ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem or_right (hC : TableauClosed C)
    (h : Formula.imp (Formula.imp ψ .bot) χ ∈ C) : χ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

/-- `T(¬A)`: `neg ψ` is `(ψ → ⊥)`. -/
theorem neg_inner (hC : TableauClosed C) (h : Formula.imp ψ .bot ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

/-- `T(◇A)`: `diamond ψ` is `((□(ψ → ⊥)) → ⊥)`. -/
theorem diamond_inner (hC : TableauClosed C)
    (h : Formula.imp (Formula.box (Formula.imp ψ .bot)) .bot ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

/-- `T(Gψ)`: `allFuture ψ` is `((U(ψ → ⊥, ⊥ → ⊥)) → ⊥)`. -/
theorem allFuture_inner (hC : TableauClosed C)
    (h : Formula.imp (Formula.untl (Formula.imp .bot .bot) (Formula.imp ψ .bot)) .bot ∈ C) :
    ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

/-- `T(Hψ)`: `allPast ψ` is `((S(ψ → ⊥, ⊥ → ⊥)) → ⊥)`. -/
theorem allPast_inner (hC : TableauClosed C)
    (h : Formula.imp (Formula.snce (Formula.imp .bot .bot) (Formula.imp ψ .bot)) .bot ∈ C) :
    ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

end TableauClosed

/-! ## Inverting the `as*?` decomposition helpers

`applyRule`'s arms test their trigger through `asAnd?`, `asUntil?`, … rather than by pattern, so
each case arrives with an equation `as…? sf.formula = some …` and no syntactic handle on
`sf.formula`. These invert that equation into the raw constructor shape, which is what lets the
closure hypothesis be rewritten into the form the component-extraction lemmas take. Stated in raw
`imp`/`bot`/`untl`/`snce` form
deliberately: that is the form `split` leaves behind, and routing through the derived
`Formula.and`/`Formula.neg` spellings would need an extra unfolding step in all 36 cases.
-/

/-- Stated as an `iff` on purpose: a rule case holds `as…? sf.formula = some …` as a hypothesis,
and rewriting that hypothesis left-to-right with the `iff` replaces it by an equation on
`sf.formula` itself, which the case then rewrites into the closure hypothesis. -/
theorem asAnd?_eq_iff {φ ψ χ : Formula} :
    asAnd? φ = some (ψ, χ) ↔ φ = .imp (.imp ψ (.imp χ .bot)) .bot := by
  constructor
  · intro h; unfold asAnd? at h; split at h <;> simp_all
  · rintro rfl; rfl

theorem asOr?_eq_iff {φ ψ χ : Formula} :
    asOr? φ = some (ψ, χ) ↔ φ = .imp (.imp ψ .bot) χ := by
  constructor
  · intro h; unfold asOr? at h; split at h <;> simp_all
  · rintro rfl; rfl

theorem asNeg?_eq_iff {φ ψ : Formula} : asNeg? φ = some ψ ↔ φ = .imp ψ .bot := by
  constructor
  · intro h; unfold asNeg? at h; split at h <;> simp_all
  · rintro rfl; rfl

theorem asDiamond?_eq_iff {φ ψ : Formula} :
    asDiamond? φ = some ψ ↔ φ = .imp (.box (.imp ψ .bot)) .bot := by
  constructor
  · intro h; unfold asDiamond? at h; split at h <;> simp_all
  · rintro rfl; rfl

theorem asSomeFuture?_eq_iff {φ ψ : Formula} :
    asSomeFuture? φ = some ψ ↔ φ = .untl (.imp .bot .bot) ψ := by
  constructor
  · intro h; unfold asSomeFuture? at h; split at h <;> simp_all
  · rintro rfl; rfl

theorem asSomePast?_eq_iff {φ ψ : Formula} :
    asSomePast? φ = some ψ ↔ φ = .snce (.imp .bot .bot) ψ := by
  constructor
  · intro h; unfold asSomePast? at h; split at h <;> simp_all
  · rintro rfl; rfl

theorem asUntil?_eq_iff {φ e g : Formula} :
    asUntil? φ = some (e, g) ↔ (φ = .untl g e ∧ ¬ (g = Formula.top)) := by
  constructor
  · intro h; unfold asUntil? at h
    split at h
    · split at h <;> simp_all
    · simp_all
  · rintro ⟨rfl, hg⟩
    unfold asUntil?
    simp [beq_iff_eq, hg]

theorem asSince?_eq_iff {φ e g : Formula} :
    asSince? φ = some (e, g) ↔ (φ = .snce g e ∧ ¬ (g = Formula.top)) := by
  constructor
  · intro h; unfold asSince? at h
    split at h
    · split at h <;> simp_all
    · simp_all
  · rintro ⟨rfl, hg⟩
    unfold asSince?
    simp [beq_iff_eq, hg]

/--
Every auto-propagation block in `applyRule` is a `filterMap` whose body is
`if branch.contains prop then none else some prop`, and its output is therefore one of the
`prop`s.

**Why this is a lemma rather than a `simp` step, recorded because it cost several attempts.**
In situ — after `split` has opened the enclosing `if newFormulas.isEmpty` guard — neither
`split at`, nor `rw` with an `iff` form, nor `simp_all` will open the inner `if`: `split` reports
"could not split an `if` or `match` expression", and the `rw` pattern fails to match the
`Decidable` instance the `split` left behind. Stating the fact abstractly, where `p x = true` is
a clean `Bool` equation with a canonical instance, and then `apply`ing it sidesteps the whole
problem: the higher-order match against `fun w => if b.contains (…w…) then none else some (…w…)`
is a Miller pattern, so unification solves it.
-/
theorem mem_filterMap_guarded {α : Type _} {l : List α} {f : α → SignedFormula}
    {p : α → Bool} {g : SignedFormula}
    (h : g ∈ l.filterMap (fun x => if p x = true then none else some (f x))) :
    ∃ x ∈ l, g = f x := by
  obtain ⟨x, hx, hfx⟩ := List.mem_filterMap.mp h
  refine ⟨x, hx, ?_⟩
  by_cases hp : p x = true <;> simp [hp] at hfx
  exact hfx.symm

/-! ## Branch-membership bridges

The rules' auto-propagation blocks read formulas back off the branch through `List.filter`
selectors and `List.filterMap`, then relabel them. All three steps are formula-preserving or
formula-shrinking, and the lemmas here are what let the 36 cases say so in one step each.
-/

/--
`Branch.contains` is `List.any` with `BEq`, not `List.contains`, so `List.contains_iff_mem` does
not apply to it. `orderTrichotomy` is the only rule case that has to read a formula *off* the
branch through this predicate — its analyticity guard is stated with `Branch.contains` — and this
is the bridge that turns that guard into a membership `hb` can consume.
-/
theorem mem_of_branch_contains {b : Branch} {x : SignedFormula} (h : b.contains x = true) :
    x ∈ b := by
  simp only [Branch.contains, List.any_eq_true] at h
  obtain ⟨y, hy, hxy⟩ := h
  exact beq_iff_eq.mp hxy ▸ hy

/-- The relabelled copies produced by `identifyTime` carry branch formulas verbatim. -/
theorem identifyTime_formula_mem {b : Branch} {src tgt : TimeIndex} {C : Finset Formula}
    (hb : ∀ g ∈ b, g.formula ∈ C) :
    ∀ g ∈ b.identifyTime src tgt, g.formula ∈ C := by
  intro g hg
  unfold Branch.identifyTime at hg
  rw [List.mem_eraseDups] at hg
  obtain ⟨g', hg', rfl⟩ := List.mem_map.mp hg
  by_cases h : g'.label.time == src <;> simp only [h, if_true] <;> exact hb g' hg'

/-!
## T1, rule by rule

Each rule gets its own theorem, and every proof has the same three steps.

1. **Decide the arm's side conditions.** `applyRule` is one `match` on the rule, the sign and the
   formula. A rule's arm applies under a sign equation and, for the arms that match on the
   formula's shape, a formula equation as well. Each proof opens with a `by_cases` on exactly
   those conditions — none at all for `serialityRule` and `timeLinearity`.
2. **Rewrite with one arm's equation.** Where the conditions hold, the rule's wrapper
   `applyRule_<rule>_arm_eq` from `Tableau.lean` rewrites `hg` to that arm's body. Where they
   fail, `applyRule_offArm_eq` rewrites it to `.notApplicable`, which emits nothing; its
   hypotheses, one refutation per arm, close by `contradiction` — against the rule name for every
   other arm, against the failed side condition for this one.
3. **Read the emitted formulas off.** `split` opens whatever `match` or `if` the arm's body has,
   one `simp only` turns the membership `hg` into a disjunction of equations, and each disjunct is
   closed by a component-extraction lemma or a `TableauClosed` field.

**Where the cost is, as measured.** `applyRule` is a 900-line `match`. A proof that brings all of
it into a hypothesis — `unfold applyRule at hg`, then `split` down to one goal per arm — pays for
a `simp` call on every surviving goal, each over a context holding the unfolded term and the
hypotheses the splitter accumulated. Profiling the 36 cases written in that form attributes 99.2
percent of elaboration time to `simp` and 0.7 percent to all other tactic execution together,
`unfold` and `split` included: roughly 880,000 heartbeats per rule, and 2,085,000 for each of the
two last arms.
Rewriting with a single arm's equation never creates those goals. The same 36 cases take between
150 and 7,000 heartbeats each, inside the default budget; the figure for each is recorded above
its declaration.

Three rules follow, and they bind anything that extends this file:

1. **Never `unfold applyRule`.** Rewrite with the arm's wrapper, and add a wrapper next to
   `applyRule` when a new arm needs one.
2. **One rule, one declaration.** Never `cases rule <;> …` across families. This is a *memory*
   ceiling, and it stands independently of the elaboration-time finding above: a single `theorem`
   covering 14 rules with a broad `simp_all` and a 30-alternative `first` chain reached
   **19.2 GiB** resident and was killed by `earlyoom`.
3. **No bare `simp` or `simp_all` on a goal that holds a rule body.** Use `simp only [...]` with
   the case's own lemma list. The one full simp set left in the file is the closer inside the
   propagation blocks of the fresh-witness rules and `densityRule`; it runs after `clear` has
   emptied the context, and replacing it with `simp only` was measured to change those proofs'
   cost by under one percent.
-/

section Propositional

-- Six of these arms take a sign equation only and reach their trigger through `asAnd?`, `asOr?`
-- or `asNeg?`; `impPos` and `impNeg` match on the formula's shape and take a formula equation too.

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

-- Rewrites with `applyRule_andPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.4K heartbeats measured.
theorem applyRule_andPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .andPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_andPos_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ χ heq
      rw [asAnd?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl | rfl
      · exact hC.and_left hsf
      · exact hC.and_right hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .andPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_andNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.4K heartbeats measured.
theorem applyRule_andNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .andNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .neg
  · rw [applyRule_andNeg_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ χ heq
      rw [asAnd?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, List.flatten_cons, List.flatten_nil, List.append_nil,
        List.mem_append, List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl | rfl
      · exact hC.and_left hsf
      · exact hC.and_right hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .andNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_orPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.4K heartbeats measured.
theorem applyRule_orPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .orPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_orPos_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ χ heq
      rw [asOr?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, List.flatten_cons, List.flatten_nil, List.append_nil,
        List.mem_append, List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl | rfl
      · exact hC.or_left hsf
      · exact hC.or_right hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .orPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_orNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.4K heartbeats measured.
theorem applyRule_orNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .orNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .neg
  · rw [applyRule_orNeg_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ χ heq
      rw [asOr?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
      rcases hg with rfl | rfl
      · exact hC.or_left hsf
      · exact hC.or_right hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .orNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_impPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.5K heartbeats measured.
theorem applyRule_impPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .impPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .pos ∧ ∃ ψ χ, sf.formula = .imp ψ χ
  · obtain ⟨hs, ψ, χ, hf⟩ := h
    rw [applyRule_impPos_arm_eq sf b ord ψ χ hs hf] at hg
    rw [hf] at hsf
    simp only [RuleResult.emitted, List.flatten_cons, List.flatten_nil, List.append_nil,
      List.mem_append, List.mem_cons, List.not_mem_nil, or_false] at hg
    rcases hg with rfl | rfl
    · exact hC.imp_left hsf
    · exact hC.imp_right hsf
  · rw [applyRule_offArm_eq sf b ord .impPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, _, ‹_›⟩)

-- Rewrites with `applyRule_impNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.5K heartbeats measured.
theorem applyRule_impNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .impNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .neg ∧ ∃ ψ χ, sf.formula = .imp ψ χ
  · obtain ⟨hs, ψ, χ, hf⟩ := h
    rw [applyRule_impNeg_arm_eq sf b ord ψ χ hs hf] at hg
    rw [hf] at hsf
    simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
    rcases hg with rfl | rfl
    · exact hC.imp_left hsf
    · exact hC.imp_right hsf
  · rw [applyRule_offArm_eq sf b ord .impNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, _, ‹_›⟩)

-- Rewrites with `applyRule_negPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.4K heartbeats measured.
theorem applyRule_negPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .negPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_negPos_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asNeg?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
      subst hg
      exact hC.neg_inner hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .negPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_negNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.4K heartbeats measured.
theorem applyRule_negNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .negNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .neg
  · rw [applyRule_negNeg_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asNeg?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
      subst hg
      exact hC.neg_inner hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .negNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

end Propositional

section NonAnalytic

-- `serialityRule` and `timeLinearity` match on the rule name alone, so their proofs have no case
-- analysis and no off-arm branch; `boxTemporal` and `denseIndicatorClosure` match on the formula's
-- shape.

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

-- Rewrites with `applyRule_boxTemporal_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.5K heartbeats measured.
/-- The `boxTemp` field is what this case needs and nothing else can supply: `Gψ` and `Hψ` are
not subformulas of `□ψ`. -/
theorem applyRule_boxTemporal_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .boxTemporal sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .pos ∧ ∃ ψ, sf.formula = .box ψ
  · obtain ⟨hs, ψ, hf⟩ := h
    rw [applyRule_boxTemporal_arm_eq sf b ord ψ hs hf] at hg
    rw [hf] at hsf
    split at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted, List.mem_filter, List.mem_cons, List.not_mem_nil,
        or_false] at hg
      obtain ⟨hg, -⟩ := hg
      rcases hg with rfl | rfl
      · exact (hC.boxTemp _ hsf).1
      · exact (hC.boxTemp _ hsf).2
  · rw [applyRule_offArm_eq sf b ord .boxTemporal] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)

-- Rewrites with `applyRule_denseIndicatorClosure_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.2K heartbeats measured.
/-- `denseIndicatorClosure` emits the empty list: it exists to make `checkAxiomNeg` fire. -/
theorem applyRule_denseIndicatorClosure_closed :
    ∀ g ∈ (applyRule .denseIndicatorClosure sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .pos ∧ sf.formula = .untl .bot (.imp .bot .bot)
  · rw [applyRule_denseIndicatorClosure_arm_eq sf b ord h.1 h.2] at hg
    simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .denseIndicatorClosure] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, ‹_›⟩)

-- Rewrites with `applyRule_serialityRule_arm_eq`, so `hg` holds only this rule's arm:
-- about 167 heartbeats measured.
/--
`serialityRule` takes no trigger at all, so `hsf` is absent from the statement: `T(F⊤)` and
`T(P⊤)` come from the `serialFuture`/`serialPast` fields alone.

For the same reason the proof has no case analysis and no off-arm branch: the rule's arm matches
on the rule name only, so `applyRule_serialityRule_arm_eq` has no side condition to discharge.
-/
theorem applyRule_serialityRule_closed (hC : TableauClosed C) :
    ∀ g ∈ (applyRule .serialityRule sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  rw [applyRule_serialityRule_arm_eq sf b ord] at hg
  split at hg
  · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · simp only [RuleResult.emitted, List.mem_filter, List.mem_cons, List.not_mem_nil,
      or_false] at hg
    obtain ⟨hg, -⟩ := hg
    rcases hg with rfl | rfl
    · exact hC.serialFuture
    · exact hC.serialPast

-- Rewrites with `applyRule_timeLinearity_arm_eq`, so `hg` holds only this rule's arm:
-- about 176 heartbeats measured.
/--
`timeLinearity` is the only `.branchingOrdered` rule, so its conclusion is about the whole
post-rule branch rather than about additions; the hypothesis is correspondingly `hb`, not `hsf`.
Arms 1 and 2 carry `b` verbatim and arm 3 carries `b.identifyTime (min t₁ t₂) (max t₁ t₂)`, which
`identifyTime_formula_mem` shows is formula-preserving. `identifyTime_formula_mem` is quantified
over both of its times, so the arm's orientation is invisible to it and this proof needed no edit
when arm 3 was reoriented.

Like `serialityRule`, the arm matches on the rule name only, so there is no case analysis and no
off-arm branch.

The three-way `rcases hg with hg | hg | hg` is deliberately *not* `repeat' rcases hg with hg | hg`.
Here the disjuncts are themselves `List.Mem` proofs, and `repeat'` happily carries on destructing
those into `head`/`tail`, shredding `b` into a cons-cell pattern and leaving goals that `hb` no
longer applies to.
-/
theorem applyRule_timeLinearity_closed (hb : ∀ g ∈ b, g.formula ∈ C) :
    ∀ g ∈ (applyRule .timeLinearity sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  rw [applyRule_timeLinearity_arm_eq sf b ord] at hg
  split at hg
  · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · simp only [RuleResult.emitted, List.map_cons, List.map_nil, List.flatten_cons,
      List.flatten_nil, List.append_nil, List.mem_append] at hg
    rcases hg with hg | hg | hg
    · exact hb g hg
    · exact hb g hg
    · exact identifyTime_formula_mem hb g hg

end NonAnalytic

section PersistentUniversal

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/-! ### The persistent-universal family

`boxPos`, `diamondNeg`, `allFuturePos`, `allPastPos`, `someFutureNeg` and `somePastNeg` all have
the same body: a `List.filterMap` over `knownWorlds`, `futureOf`, or `pastOf` whose function is
`fun x => if branch.contains (prop x) then none else some (prop x)`. `mem_filterMap_guarded`
collapses that to `g = prop x` in one step, so each proof is one rewrite with the rule's arm
equation followed by a single component-extraction lemma. The label varies with `x`, but the
*formula* does not — which is exactly why one closer suffices for the whole filterMap.
-/

-- Rewrites with `applyRule_boxPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.8K heartbeats measured.
theorem applyRule_boxPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .boxPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .pos ∧ ∃ ψ, sf.formula = .box ψ
  · obtain ⟨hs, ψ, hf⟩ := h
    rw [applyRule_boxPos_arm_eq sf b ord ψ hs hf] at hg
    rw [hf] at hsf
    split at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted] at hg
      obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg
      exact hC.box_inner hsf
  · rw [applyRule_offArm_eq sf b ord .boxPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)

-- Rewrites with `applyRule_diamondNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.8K heartbeats measured.
theorem applyRule_diamondNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .diamondNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .neg
  · rw [applyRule_diamondNeg_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asDiamond?_eq_iff] at heq
      rw [heq] at hsf
      dsimp only at hg
      split at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted] at hg
        obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg
        exact hC.diamond_inner hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .diamondNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_allFuturePos_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.8K heartbeats measured.
theorem applyRule_allFuturePos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .allFuturePos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .pos ∧ ∃ ψ, sf.formula = .allFuture ψ
  · obtain ⟨hs, ψ, hf⟩ := h
    rw [applyRule_allFuturePos_arm_eq sf b ord ψ hs hf] at hg
    rw [hf] at hsf
    split at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted] at hg
      obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg
      exact hC.allFuture_inner hsf
  · rw [applyRule_offArm_eq sf b ord .allFuturePos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)

-- Rewrites with `applyRule_allPastPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.8K heartbeats measured.
theorem applyRule_allPastPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .allPastPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .pos ∧ ∃ ψ, sf.formula = .allPast ψ
  · obtain ⟨hs, ψ, hf⟩ := h
    rw [applyRule_allPastPos_arm_eq sf b ord ψ hs hf] at hg
    rw [hf] at hsf
    split at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted] at hg
      obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg
      exact hC.allPast_inner hsf
  · rw [applyRule_offArm_eq sf b ord .allPastPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)

-- Rewrites with `applyRule_someFutureNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.8K heartbeats measured.
theorem applyRule_someFutureNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .someFutureNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .neg
  · rw [applyRule_someFutureNeg_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asSomeFuture?_eq_iff] at heq
      rw [heq] at hsf
      dsimp only at hg
      split at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted] at hg
        obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg
        exact hC.untl_left hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .someFutureNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_somePastNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.8K heartbeats measured.
theorem applyRule_somePastNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .somePastNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .neg
  · rw [applyRule_somePastNeg_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asSomePast?_eq_iff] at heq
      rw [heq] at hsf
      dsimp only at hg
      split at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted] at hg
        obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg
        exact hC.snce_left hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .somePastNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

end PersistentUniversal

/--
Every propagation block of the fresh-witness rules emits a **subformula** of a branch formula.

That single observation is what makes those rules tractable. Their blocks differ in shape — some
match on the trigger's connective first (`boxProps`, `gProps`), some guard on a time (`fNegProps`),
some only relabel (`tempGProps`) — but in every case the emitted formula is either a component of
the source formula or the source formula itself, and `subformulas` is reflexive
(`Formula.self_mem_subformulas`). Routing through `sub` therefore replaces a per-block choice of
component-extraction lemma with one uniform obligation that `simp [Formula.subformulas]` closes,
and the obligation is discharged in a context cleared of everything but the block's own equation.
-/
theorem mem_filterMap_sub {C : Finset Formula} {b : Branch} {P : SignedFormula → Bool}
    {F : SignedFormula → Option SignedFormula} {g : SignedFormula} (hC : TableauClosed C)
    (hb : ∀ x ∈ b, x.formula ∈ C)
    (hF : ∀ x y, F x = some y → y.formula ∈ Formula.subformulas x.formula)
    (h : g ∈ (b.filter P).filterMap F) : g.formula ∈ C := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  exact hC.of_sub (hb x (List.mem_of_mem_filter hx)) (hF x g hxg)


section FreshWitness

-- The fresh-witness rules are the propagation-heavy ones.

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/-! ### The fresh-witness family

These rules mint a fresh world or time, put a witness there, and then drag universals already on
the branch across to it. Their statements carry `hb` as well as `hsf`, because the propagation
blocks read formulas back off the branch.

For the two *world*-minting rules (`.boxNeg`, `.diamondPos`) the universals dragged across are
the modal ones only — `boxPosFormulas` and `diamondNegFormulas`. Six further blocks used to copy
temporal formulas (`allFuturePosAtTime`, `allPastPosAtTime`, `someFutureNegAtTime`,
`somePastNegAtTime`, `untlNegAtTime`, `snceNegAtTime`) into the fresh world; they were removed as
unsound, and those six accessor names were correspondingly pruned from the two `simp only` lists
below, where they had become inert. The accessors themselves still exist in `SignedFormula.lean`.

The proofs share one shape. Rewriting with the rule's arm equation leaves `hg` as a membership
in a nest of `::`/`++`/`flatten`; one `simp only` turns that into a disjunction, one `rcases`
peels it into one goal per block, and a short `first` chain closes them: the witness goals by a
component lemma applied to `hsf` (`rcases` has already substituted `g`, which is why those
alternatives come first and do not mention `hg`), the `boxDiamondPersistence` block by
`mem_boxDiamondPersistence`, and each propagation block by `mem_filterMap_sub`. The chain's one
expensive alternative is tried last, and only after `clear` has emptied the context of everything
it does not need.
-/

-- Rewrites with `applyRule_boxNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 2.3K heartbeats measured.
theorem applyRule_boxNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .boxNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .neg ∧ ∃ ψ, sf.formula = .box ψ
  · obtain ⟨hs, ψ, hf⟩ := h
    rw [applyRule_boxNeg_arm_eq sf b ord ψ hs hf] at hg
    rw [hf] at hsf
    simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
      List.mem_cons, List.mem_append] at hg
    rcases hg with (rfl | hg) | hg
    all_goals first
      | exact hC.box_inner hsf
      | (refine mem_filterMap_sub hC hb ?_ hg
         clear hg hsf hC hb
         intro x y hy
         repeat' first
           | split at hy
           | simp only [Option.some.injEq] at hy
         all_goals first
           | exact absurd hy (by simp)
           | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
               Formula.self_mem_subformulas]))
  · rw [applyRule_offArm_eq sf b ord .boxNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)

-- Rewrites with `applyRule_diamondPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 2.2K heartbeats measured.
theorem applyRule_diamondPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .diamondPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_diamondPos_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asDiamond?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
        List.mem_cons, List.mem_append] at hg
      rcases hg with (rfl | hg) | hg
      all_goals first
        | exact hC.diamond_inner hsf
        | (refine mem_filterMap_sub hC hb ?_ hg
           clear hg hsf hC hb
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | exact absurd hy (by simp)
             | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
                 Formula.self_mem_subformulas]))
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .diamondPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_allFutureNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 3.1K heartbeats measured.
theorem applyRule_allFutureNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .allFutureNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .neg ∧ ∃ ψ, sf.formula = .allFuture ψ
  · obtain ⟨hs, ψ, hf⟩ := h
    rw [applyRule_allFutureNeg_arm_eq sf b ord ψ hs hf] at hg
    rw [hf] at hsf
    simp only [RuleResult.emitted, Branch.allFuturePosFormulas, Branch.someFutureNegFormulas,
      List.mem_cons, List.mem_append] at hg
    rcases hg with ((rfl | hg) | hg) | hg
    all_goals first
      | exact hC.allFuture_inner hsf
      | (obtain ⟨s, hs', hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs')
      | (refine mem_filterMap_sub hC hb ?_ hg
         clear hg hsf hC hb
         intro x y hy
         repeat' first
           | split at hy
           | simp only [Option.some.injEq] at hy
         all_goals first
           | exact absurd hy (by simp)
           | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
               Formula.self_mem_subformulas]))
  · rw [applyRule_offArm_eq sf b ord .allFutureNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)

-- Rewrites with `applyRule_allPastNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 3.1K heartbeats measured.
theorem applyRule_allPastNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .allPastNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .neg ∧ ∃ ψ, sf.formula = .allPast ψ
  · obtain ⟨hs, ψ, hf⟩ := h
    rw [applyRule_allPastNeg_arm_eq sf b ord ψ hs hf] at hg
    rw [hf] at hsf
    simp only [RuleResult.emitted, Branch.allPastPosFormulas, Branch.somePastNegFormulas,
      List.mem_cons, List.mem_append] at hg
    rcases hg with ((rfl | hg) | hg) | hg
    all_goals first
      | exact hC.allPast_inner hsf
      | (obtain ⟨s, hs', hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs')
      | (refine mem_filterMap_sub hC hb ?_ hg
         clear hg hsf hC hb
         intro x y hy
         repeat' first
           | split at hy
           | simp only [Option.some.injEq] at hy
         all_goals first
           | exact absurd hy (by simp)
           | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
               Formula.self_mem_subformulas]))
  · rw [applyRule_offArm_eq sf b ord .allPastNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)

-- Rewrites with `applyRule_someFuturePos_arm_eq`, so `hg` holds only this rule's arm:
-- about 3.1K heartbeats measured.
theorem applyRule_someFuturePos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .someFuturePos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_someFuturePos_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asSomeFuture?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, Branch.allFuturePosFormulas, Branch.someFutureNegFormulas,
        List.mem_cons, List.mem_append] at hg
      rcases hg with ((rfl | hg) | hg) | hg
      all_goals first
        | exact hC.untl_left hsf
        | (obtain ⟨s, hs', hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs')
        | (refine mem_filterMap_sub hC hb ?_ hg
           clear hg hsf hC hb
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | exact absurd hy (by simp)
             | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
                 Formula.self_mem_subformulas]))
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .someFuturePos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_somePastPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 3.1K heartbeats measured.
theorem applyRule_somePastPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .somePastPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_somePastPos_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asSomePast?_eq_iff] at heq
      rw [heq] at hsf
      simp only [RuleResult.emitted, Branch.allPastPosFormulas, Branch.somePastNegFormulas,
        List.mem_cons, List.mem_append] at hg
      rcases hg with ((rfl | hg) | hg) | hg
      all_goals first
        | exact hC.snce_left hsf
        | (obtain ⟨s, hs', hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs')
        | (refine mem_filterMap_sub hC hb ?_ hg
           clear hg hsf hC hb
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | exact absurd hy (by simp)
             | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
                 Formula.self_mem_subformulas]))
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .somePastPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)
/-! ### Until and Since

`untlPos`/`sncePos` split into an event branch and a guard-and-continue branch; `untlNeg`/`snceNeg`
run the Reynolds co-decomposition, and both of their arms re-include the trigger `sf` itself.

All four proofs therefore keep two copies of the trigger hypothesis. `hsf : sf.formula ∈ C` stays
as stated, and closes the goals `rcases` leaves as `sf.formula ∈ C` — the re-included trigger of
`untlNeg`/`snceNeg`. `hU` is the same fact rewritten through the `asUntil?`/`asSince?` inversion,
so it speaks about `guard.untl event` (resp. `guard.snce event`): the component lemmas need that
form, and it is also literally the continuing `U`/`S` formula `untlPos`/`sncePos` emit. Rewriting
`hsf` in place would lose the first.
-/

-- Rewrites with `applyRule_untlPos_arm_eq`, so `hg` holds only this rule's arm:
-- about 5.1K heartbeats measured.
theorem applyRule_untlPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .untlPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_untlPos_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i event guard heq
      rw [asUntil?_eq_iff] at heq
      have hU := hsf
      rw [heq.1] at hU
      simp only [RuleResult.emitted, Branch.allFuturePosFormulas, Branch.someFutureNegFormulas,
        List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
        List.not_mem_nil, or_false] at hg
      rcases hg with (rfl | (hg | hg) | hg) | ((rfl | rfl) | (hg | hg) | hg)
      all_goals first
        | exact hsf
        | exact hU
        | exact hC.untl_left hU
        | exact hC.untl_right hU
        | (obtain ⟨s, hs', hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs')
        | (refine mem_filterMap_sub hC hb ?_ hg
           clear hg hsf hC hb
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | exact absurd hy (by simp)
             | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
                 Formula.self_mem_subformulas]))
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .untlPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_sncePos_arm_eq`, so `hg` holds only this rule's arm:
-- about 5.1K heartbeats measured.
theorem applyRule_sncePos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .sncePos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_sncePos_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i event guard heq
      rw [asSince?_eq_iff] at heq
      have hU := hsf
      rw [heq.1] at hU
      simp only [RuleResult.emitted, Branch.allPastPosFormulas, Branch.somePastNegFormulas,
        List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
        List.not_mem_nil, or_false] at hg
      rcases hg with (rfl | (hg | hg) | hg) | ((rfl | rfl) | (hg | hg) | hg)
      all_goals first
        | exact hsf
        | exact hU
        | exact hC.snce_left hU
        | exact hC.snce_right hU
        | (obtain ⟨s, hs', hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs')
        | (refine mem_filterMap_sub hC hb ?_ hg
           clear hg hsf hC hb
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | exact absurd hy (by simp)
             | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
                 Formula.self_mem_subformulas]))
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .sncePos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_untlNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 6.6K heartbeats measured.
theorem applyRule_untlNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .untlNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .neg
  · rw [applyRule_untlNeg_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i event guard heq
      rw [asUntil?_eq_iff] at heq
      have hU := hsf
      rw [heq.1] at hU
      dsimp only at hg
      split at hg
      · simp only [RuleResult.emitted, Branch.allFuturePosFormulas, Branch.someFutureNegFormulas,
          List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
          List.not_mem_nil, or_false] at hg
        rcases hg with ((rfl | rfl) | (hg | hg) | hg) | ((rfl | rfl) | (hg | hg) | hg)
        all_goals first
          | exact hsf
          | exact hU
          | exact hC.untl_left hU
          | exact hC.untl_right hU
          | (obtain ⟨s, hs', hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs')
          | (refine mem_filterMap_sub hC hb ?_ hg
             clear hg hsf hC hb
             intro x y hy
             repeat' first
               | split at hy
               | simp only [Option.some.injEq] at hy
             all_goals first
               | exact absurd hy (by simp)
               | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
                   Formula.self_mem_subformulas]))
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .untlNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_snceNeg_arm_eq`, so `hg` holds only this rule's arm:
-- about 6.6K heartbeats measured.
theorem applyRule_snceNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .snceNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .neg
  · rw [applyRule_snceNeg_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i event guard heq
      rw [asSince?_eq_iff] at heq
      have hU := hsf
      rw [heq.1] at hU
      dsimp only at hg
      split at hg
      · simp only [RuleResult.emitted, Branch.allPastPosFormulas, Branch.somePastNegFormulas,
          List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
          List.not_mem_nil, or_false] at hg
        rcases hg with ((rfl | rfl) | (hg | hg) | hg) | ((rfl | rfl) | (hg | hg) | hg)
        all_goals first
          | exact hsf
          | exact hU
          | exact hC.snce_left hU
          | exact hC.snce_right hU
          | (obtain ⟨s, hs', hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs')
          | (refine mem_filterMap_sub hC hb ?_ hg
             clear hg hsf hC hb
             intro x y hy
             repeat' first
               | split at hy
               | simp only [Option.some.injEq] at hy
             all_goals first
               | exact absurd hy (by simp)
               | (subst hy; simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
                   Formula.self_mem_subformulas]))
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .snceNeg] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

end FreshWitness

section FrameClass

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/-! ### The frame-class rules

Five of these consume a dedicated `TableauClosed` field and nothing else can close them:
`priorUZ`/`priorSZ` take `priorU`/`priorS`, `priorUGap`/`priorSGap` take `gapU`/`gapS`, and
`sepRule` takes `sep`. The three `and_left` uses are the same step in each: the Dedekind rules
trigger on a conjunction, and it is the conjunction's *left* operand — `U(⊤, g)`, `S(⊤, g)`,
`K⁺ψ` — that the field is stated about. `beq_iff_eq` is what turns the rules' own `e == ⊤` guard
into the equation that makes `e` and `⊤` the same term.

`z1Rule` and `densityRule` are analytic despite their setting, as the module docstring records.
`z1Rule` emits `G inner` from the trigger `G(G inner → rhs)`, and two component extractions reach
it: `allFuture_inner` strips the outer `G` and `imp_left` takes the antecedent. Its arm matches on
the trigger's shape twice, so the proof splits twice as well: once on whether the trigger is a `G`
at all, and once on whether what is under it is an implication from a `G`.
-/

-- Rewrites with `applyRule_priorUZ_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.4K heartbeats measured.
theorem applyRule_priorUZ_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .priorUZ sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_priorUZ_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asSomeFuture?_eq_iff] at heq
      rw [heq] at hsf
      dsimp only at hg
      split at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
        subst hg
        exact hC.priorU _ hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .priorUZ] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_priorSZ_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.4K heartbeats measured.
theorem applyRule_priorSZ_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .priorSZ sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_priorSZ_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i ψ heq
      rw [asSomePast?_eq_iff] at heq
      rw [heq] at hsf
      dsimp only at hg
      split at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
        subst hg
        exact hC.priorS _ hsf
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .priorSZ] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_z1Rule_arm_eq`, so `hg` holds only this rule's arm:
-- about 2.0K heartbeats measured.
theorem applyRule_z1Rule_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .z1Rule sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .pos ∧ ∃ φ, sf.formula = .allFuture φ
  · obtain ⟨hs, φ, hf⟩ := h
    by_cases h2 : ∃ inner rhs, φ = .imp (.allFuture inner) rhs
    · obtain ⟨inner, rhs, rfl⟩ := h2
      rw [applyRule_z1Rule_arm_eq sf b ord inner rhs hs hf] at hg
      rw [hf] at hsf
      split at hg
      · dsimp only at hg
        split at hg
        · split at hg
          · simp only [RuleResult.emitted, List.not_mem_nil] at hg
          · simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
            subst hg
            exact hC.imp_left (hC.allFuture_inner hsf)
        · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · rw [applyRule_z1Rule_offPattern_eq sf b ord hs φ hf (fun i r hi => h2 ⟨i, r, hi⟩)] at hg
      simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .z1Rule] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)

-- Rewrites with `applyRule_priorUGap_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.6K heartbeats measured.
theorem applyRule_priorUGap_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .priorUGap sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_priorUGap_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i a c heq
      rw [asAnd?_eq_iff] at heq
      rw [heq] at hsf
      split at hg
      · split at hg
        · rename_i hcond
          simp only [Bool.and_eq_true, beq_iff_eq] at hcond
          obtain ⟨rfl, rfl⟩ := hcond
          dsimp only at hg
          split at hg
          · simp only [RuleResult.emitted, List.not_mem_nil] at hg
          · simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
            subst hg
            exact hC.gapU _ hsf
        · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .priorUGap] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_priorSGap_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.6K heartbeats measured.
theorem applyRule_priorSGap_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .priorSGap sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_priorSGap_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i a c heq
      rw [asAnd?_eq_iff] at heq
      rw [heq] at hsf
      split at hg
      · split at hg
        · rename_i hcond
          simp only [Bool.and_eq_true, beq_iff_eq] at hcond
          obtain ⟨rfl, rfl⟩ := hcond
          dsimp only at hg
          split at hg
          · simp only [RuleResult.emitted, List.not_mem_nil] at hg
          · simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
            subst hg
            exact hC.gapS _ hsf
        · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .priorSGap] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_sepRule_arm_eq`, so `hg` holds only this rule's arm:
-- about 1.6K heartbeats measured.
theorem applyRule_sepRule_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .sepRule sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_sepRule_arm_eq sf b ord hs] at hg
    split at hg
    · rename_i a c heq
      rw [asAnd?_eq_iff] at heq
      rw [heq] at hsf
      split at hg
      · split at hg
        · rename_i hcond
          simp only [Bool.and_eq_true, beq_iff_eq] at hcond
          obtain ⟨rfl, rfl⟩ := hcond
          dsimp only at hg
          split at hg
          · simp only [RuleResult.emitted, List.not_mem_nil] at hg
          · simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false] at hg
            subst hg
            exact hC.sep _ hsf
        · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
  · rw [applyRule_offArm_eq sf b ord .sepRule] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

-- Rewrites with `applyRule_densityRule_arm_eq`, so `hg` holds only this rule's arm:
-- about 2.3K heartbeats measured.
theorem applyRule_densityRule_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .densityRule sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases h : sf.sign = .pos ∧ ∃ ψ, sf.formula = .allFuture ψ
  · obtain ⟨hs, ψ, hf⟩ := h
    rw [applyRule_densityRule_arm_eq sf b ord ψ hs hf] at hg
    rw [hf] at hsf
    split at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · simp only [RuleResult.emitted, Branch.allFuturePosFormulas, List.mem_cons] at hg
      rcases hg with rfl | hg
      · exact hC.allFuture_inner hsf
      · refine mem_filterMap_sub hC hb ?_ hg
        clear hg hsf hC hb
        intro x y hy
        repeat' first
          | split at hy
          | simp only [Option.some.injEq] at hy
        all_goals first
          | exact absurd hy (by simp)
          | (subst hy; simp_all [SignedFormula.pos, Formula.subformulas,
              Formula.self_mem_subformulas])
  · rw [applyRule_offArm_eq sf b ord .densityRule] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; first | contradiction | exact h ⟨‹_›, _, ‹_›⟩)


-- Rewrites with `applyRule_orderTrichotomy_arm_eq`, so `hg` holds only this rule's arm:
-- about 2.1K heartbeats measured.
/--
`orderTrichotomy` is analytic, and this proof is where that shows up concretely.

The rule's restriction 4 fires only when the branch already carries the *negation* of one of the
three `temp_linearity` disjuncts at the common predecessor. `List.find?_some` turns the surviving
`candidates.find? fires = some (t₀, ψ)` into `fires (t₀, ψ) = true`, whose last conjunct is
exactly that guard — and that guard is, verbatim, the hypothesis of `TrichClosed`. Nothing here
conjures a formula the branch did not already mention.

`TrichClosed` is a hypothesis rather than a `TableauClosed` field for the reason recorded at its
definition: as a `C`-only condition it admits no finite `C`, because the second disjunct
re-triggers on itself. The rule's own guard is branch-side, so the obligation travels with the
branch invariant instead of with the formula stock.
-/
theorem applyRule_orderTrichotomy_closed {C : Finset Formula} (hsf : sf.formula ∈ C)
    (htrich : TrichClosed C b) :
    ∀ g ∈ (applyRule .orderTrichotomy sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  by_cases hs : sf.sign = .pos
  · rw [applyRule_orderTrichotomy_arm_eq sf b ord hs] at hg
    split at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    · dsimp only at hg
      split at hg
      · simp only [RuleResult.emitted, List.not_mem_nil] at hg
      · rename_i hfind
        have hfires := List.find?_some hfind
        simp only [Bool.and_eq_true, List.any_cons, List.any_nil, Bool.or_eq_true,
          Bool.or_false] at hfires
        obtain ⟨-, hany⟩ := hfires
        have htri := htrich _ _ _ hany
        simp only [RuleResult.emitted, List.map_cons, List.map_nil, List.flatten_cons,
          List.flatten_nil, List.append_nil, List.mem_append, List.mem_cons, List.not_mem_nil,
          or_false] at hg
        rcases hg with (rfl | rfl) | (rfl | rfl) | (rfl | rfl)
        · exact htri.1
        · exact hsf
        · exact htri.2.1
        · exact hsf
        · exact htri.2.2
        · exact hsf
  · rw [applyRule_offArm_eq sf b ord .orderTrichotomy] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; contradiction)

end FrameClass

section Combined

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/--
T1, assembled: **no rule of the calculus emits a formula outside a `TableauClosed` set.**

This is the form `Fuel.lean` consumes, and it costs nothing to state now that every case is
proved: `cases rule` does not unfold `applyRule`, so the 900-line match never enters a goal here
and the whole theorem elaborates in the time of thirty-six `exact`s.

The hypotheses are the union of what the cases need. `hb` is genuinely required and not merely
convenient: the propagation-heavy rules read universals back off the branch, and `timeLinearity`
carries whole branches into its arms, so a statement about the trigger formula alone would be
false for them. `htrich` is required by exactly one case, `orderTrichotomy`, whose guard is
branch-side; see `TrichClosed` for why that obligation cannot live in `TableauClosed`.
-/
theorem applyRule_subformula_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) (htrich : TrichClosed C b) (rule : TableauRule) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.formula ∈ C :=
  match rule with
  | .andPos => applyRule_andPos_closed hC hsf
  | .andNeg => applyRule_andNeg_closed hC hsf
  | .orPos => applyRule_orPos_closed hC hsf
  | .orNeg => applyRule_orNeg_closed hC hsf
  | .impPos => applyRule_impPos_closed hC hsf
  | .impNeg => applyRule_impNeg_closed hC hsf
  | .negPos => applyRule_negPos_closed hC hsf
  | .negNeg => applyRule_negNeg_closed hC hsf
  | .boxPos => applyRule_boxPos_closed hC hsf
  | .boxNeg => applyRule_boxNeg_closed hC hsf hb
  | .diamondPos => applyRule_diamondPos_closed hC hsf hb
  | .diamondNeg => applyRule_diamondNeg_closed hC hsf
  | .boxTemporal => applyRule_boxTemporal_closed hC hsf
  | .allFuturePos => applyRule_allFuturePos_closed hC hsf
  | .allFutureNeg => applyRule_allFutureNeg_closed hC hsf hb
  | .allPastPos => applyRule_allPastPos_closed hC hsf
  | .allPastNeg => applyRule_allPastNeg_closed hC hsf hb
  | .someFuturePos => applyRule_someFuturePos_closed hC hsf hb
  | .someFutureNeg => applyRule_someFutureNeg_closed hC hsf
  | .somePastPos => applyRule_somePastPos_closed hC hsf hb
  | .somePastNeg => applyRule_somePastNeg_closed hC hsf
  | .untlPos => applyRule_untlPos_closed hC hsf hb
  | .untlNeg => applyRule_untlNeg_closed hC hsf hb
  | .sncePos => applyRule_sncePos_closed hC hsf hb
  | .snceNeg => applyRule_snceNeg_closed hC hsf hb
  | .orderTrichotomy => applyRule_orderTrichotomy_closed hsf htrich
  | .denseIndicatorClosure => applyRule_denseIndicatorClosure_closed
  | .densityRule => applyRule_densityRule_closed hC hsf hb
  | .priorUZ => applyRule_priorUZ_closed hC hsf
  | .priorSZ => applyRule_priorSZ_closed hC hsf
  | .z1Rule => applyRule_z1Rule_closed hC hsf
  | .priorUGap => applyRule_priorUGap_closed hC hsf
  | .priorSGap => applyRule_priorSGap_closed hC hsf
  | .sepRule => applyRule_sepRule_closed hC hsf
  | .serialityRule => applyRule_serialityRule_closed hC
  | .timeLinearity => applyRule_timeLinearity_closed hb

end Combined

end FormalSystem.Metalogic.Decidability

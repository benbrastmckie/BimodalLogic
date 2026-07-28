/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Tableau
import FormalSystem.Syntax.SubformulaClosure.Closure

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
  `branch.identifyTime t₂ t₁` once, and identification is label-only (`identifyTime_formula_mem`
  below), so nothing leaves `C`.

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
everything that rule emits. Ten of the thirty-six rules are proved here; the section note above
`applyRule_andPos_closed` explains why one-rule-per-declaration is forced rather than stylistic,
and `Verified/README.md` records which rules remain and what each needs.

There is deliberately **no** combined `applyRule_subformula_closed` yet. Stating it would mean
either asserting the property for rules whose case is not proved, or carrying a hypothesis
enumerating the ten — neither is worth having before the remaining twenty-six land.
-/

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
  priorU : ∀ ψ : Formula, ψ.someFuture ∈ C → Formula.untl ψ ψ.neg ∈ C
  /-- `priorSZ` (Discrete): `T(Pψ)` yields `T(S(ψ, ¬ψ))`. -/
  priorS : ∀ ψ : Formula, ψ.somePast ∈ C → Formula.snce ψ ψ.neg ∈ C
  /-- `priorUGap` (Dedekind): the `U(⊤, g)` trigger yields `U(¬g ∨ K⁺(¬g), g)`. -/
  gapU : ∀ g : Formula, Formula.untl Formula.top g ∈ C →
    Formula.untl (Formula.or g.neg (Formula.kPlus g.neg)) g ∈ C
  /-- `priorSGap` (Dedekind): the `S(⊤, g)` trigger yields `S(¬g ∨ K⁻(¬g), g)`. -/
  gapS : ∀ g : Formula, Formula.snce Formula.top g ∈ C →
    Formula.snce (Formula.or g.neg (Formula.kMinus g.neg)) g ∈ C
  /-- `sepRule` (Dedekind): the `K⁺ψ` trigger yields `K⁺(K⁺ψ ∧ K⁻ψ)`. -/
  sep : ∀ ψ : Formula, Formula.kPlus ψ ∈ C →
    Formula.kPlus (Formula.and (Formula.kPlus ψ) (Formula.kMinus ψ)) ∈ C
  /--
  `orderTrichotomy`: the three `temp_linearity` disjuncts on an operand pair stand or fall
  together. The rule's own analyticity guard (restriction 3) fires only when the branch already
  carries the negation of *one* of the three at the common predecessor, so this hypothesis is
  always discharged from the branch rather than conjured; that is what keeps the closure finite
  instead of iterating `F(F(x ∧ y) ∧ y')` without bound.
  -/
  trich : ∀ x y : Formula,
    (Formula.someFuture (Formula.and x y) ∈ C
      ∨ Formula.someFuture (Formula.and x y.someFuture) ∈ C
      ∨ Formula.someFuture (Formula.and x.someFuture y) ∈ C) →
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

theorem untl_left (hC : TableauClosed C) (h : Formula.untl ψ χ ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem untl_right (hC : TableauClosed C) (h : Formula.untl ψ χ ∈ C) : χ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem snce_left (hC : TableauClosed C) (h : Formula.snce ψ χ ∈ C) : ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

theorem snce_right (hC : TableauClosed C) (h : Formula.snce ψ χ ∈ C) : χ ∈ C :=
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
    (h : Formula.imp (Formula.untl (Formula.imp ψ .bot) (Formula.imp .bot .bot)) .bot ∈ C) :
    ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

/-- `T(Hψ)`: `allPast ψ` is `((S(ψ → ⊥, ⊥ → ⊥)) → ⊥)`. -/
theorem allPast_inner (hC : TableauClosed C)
    (h : Formula.imp (Formula.snce (Formula.imp ψ .bot) (Formula.imp .bot .bot)) .bot ∈ C) :
    ψ ∈ C :=
  hC.of_sub h (by simp [Formula.subformulas, Formula.self_mem_subformulas])

end TableauClosed

/-! ## Inverting the `as*?` decomposition helpers

`applyRule`'s arms test their trigger through `asAnd?`, `asUntil?`, … rather than by pattern, so
each case arrives with an equation `as…? sf.formula = some …` and no syntactic handle on
`sf.formula`. These invert that equation into the raw constructor shape, which is what makes the
subformula side-goals computable by `simp`. Stated in raw `imp`/`bot`/`untl`/`snce` form
deliberately: that is the form `split` leaves behind, and routing through the derived
`Formula.and`/`Formula.neg` spellings would need an extra unfolding step in all 36 cases.
-/

/-- Stated as an `iff` on purpose: the rule cases reach these equations under inaccessible
names, so they have to be usable as `simp_all` rewrite rules rather than as named arguments.
Rewriting left-to-right replaces the opaque `as…? sf.formula = some …` with an equation on
`sf.formula` itself, which `simp_all` then substitutes into the closure hypothesis. -/
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
    asSomeFuture? φ = some ψ ↔ φ = .untl ψ (.imp .bot .bot) := by
  constructor
  · intro h; unfold asSomeFuture? at h; split at h <;> simp_all
  · rintro rfl; rfl

theorem asSomePast?_eq_iff {φ ψ : Formula} :
    asSomePast? φ = some ψ ↔ φ = .snce ψ (.imp .bot .bot) := by
  constructor
  · intro h; unfold asSomePast? at h; split at h <;> simp_all
  · rintro rfl; rfl

theorem asUntil?_eq_iff {φ e g : Formula} :
    asUntil? φ = some (e, g) ↔ (φ = .untl e g ∧ ¬ (g = Formula.top)) := by
  constructor
  · intro h; unfold asUntil? at h
    split at h
    · split at h <;> simp_all
    · simp_all
  · rintro ⟨rfl, hg⟩
    unfold asUntil?
    simp [beq_iff_eq, hg]

theorem asSince?_eq_iff {φ e g : Formula} :
    asSince? φ = some (e, g) ↔ (φ = .snce e g ∧ ¬ (g = Formula.top)) := by
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

/-- The relabelled copies produced by `identifyTime` carry branch formulas verbatim. -/
theorem identifyTime_formula_mem {b : Branch} {src tgt : TimeIndex} {C : Finset Formula}
    (hb : ∀ g ∈ b, g.formula ∈ C) :
    ∀ g ∈ b.identifyTime src tgt, g.formula ∈ C := by
  intro g hg
  unfold Branch.identifyTime at hg
  rw [List.mem_eraseDups] at hg
  obtain ⟨g', hg', rfl⟩ := List.mem_map.mp hg
  by_cases h : g'.label.time == src <;> simp only [h, if_true, if_false] <;> exact hb g' hg'

/-!
## T1, rule by rule

Each rule gets its own theorem. That is not stylistic: `applyRule` is a 900-line `match` on 36
constructors, and `unfold applyRule` inlines all of it into the hypothesis, so a proof that keeps
several rules' goals alive at once holds several copies of that term. Measured on this machine —
a single `theorem` covering 14 rules with a broad `simp_all` and a 30-alternative `first` chain
reached **19.2 GiB** resident and was killed by `earlyoom`; the same content split one rule per
declaration, with a `simp_all only` restricted to the lemmas that case needs and a `first` chain
of at most seven alternatives, elaborates in about four seconds. Two rules of thumb follow, and
they bind any later phase that extends this file:

1. **One rule, one declaration.** Never `cases rule <;> …` across families.
2. **Never a bare `simp_all` or `simp` here.** Always `simp_all only [..., SignedFormula.pos, SignedFormula.neg, reduceCtorEq]`/`simp only [...]` with
   the case's own lemma list. A bare `simp` in a closer alternative is retried on every open goal
   of the case, and that is where the memory goes.
-/

section Propositional

-- Each case unfolds the 900-line `applyRule` match; the default heartbeat budget is not enough
-- for the `whnf` work that costs, while the *memory* ceiling is what forces one rule per
-- declaration (see the section note above).
set_option maxHeartbeats 1000000

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

theorem applyRule_andPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .andPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asAnd?_eq_iff, List.mem_cons, List.not_mem_nil, or_false, SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals first
    | exact hC.and_left hsf
    | exact hC.and_right hsf

theorem applyRule_andNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .andNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asAnd?_eq_iff, List.flatten_cons, List.flatten_nil,
    List.append_nil, List.mem_append, List.mem_cons, List.not_mem_nil, or_false,
    SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals first
    | exact hC.and_left hsf
    | exact hC.and_right hsf

theorem applyRule_orPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .orPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asOr?_eq_iff, List.flatten_cons, List.flatten_nil,
    List.append_nil, List.mem_append, List.mem_cons, List.not_mem_nil, or_false,
    SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals first
    | exact hC.or_left hsf
    | exact hC.or_right hsf

theorem applyRule_orNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .orNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asOr?_eq_iff, List.mem_cons, List.not_mem_nil, or_false, SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals first
    | exact hC.or_left hsf
    | exact hC.or_right hsf

theorem applyRule_impPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .impPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.flatten_cons, List.flatten_nil, List.append_nil,
    List.mem_append, List.mem_cons, List.not_mem_nil, or_false,
    SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals first
    | exact hC.imp_left hsf
    | exact hC.imp_right hsf

theorem applyRule_impNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .impNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.mem_cons, List.not_mem_nil, or_false, SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals first
    | exact hC.imp_left hsf
    | exact hC.imp_right hsf

theorem applyRule_negPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .negPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asNeg?_eq_iff, List.mem_cons, List.not_mem_nil, or_false, SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals exact hC.neg_inner hsf

theorem applyRule_negNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .negNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asNeg?_eq_iff, List.mem_cons, List.not_mem_nil, or_false, SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals exact hC.neg_inner hsf

end Propositional

section NonAnalytic

-- `denseIndicatorClosure` and `timeLinearity` sit at positions 33 and 36 of the `applyRule`
-- match, so `whnf` has to step past every earlier arm before it reaches them; they need a
-- larger budget than the propositional rules for that reason alone.
set_option maxHeartbeats 4000000

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/-- The `boxTemp` field is what this case needs and nothing else can supply: `Gψ` and `Hψ` are
not subformulas of `□ψ`. -/
theorem applyRule_boxTemporal_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .boxTemporal sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.mem_filter, List.mem_cons, List.not_mem_nil, or_false,
    Bool.not_eq_eq_eq_not, Bool.not_true, SignedFormula.pos, SignedFormula.neg, reduceCtorEq])
  all_goals (try (obtain ⟨hg, -⟩ := hg))
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals (try subst hg)
  all_goals first
    | exact (hC.boxTemp _ hsf).1
    | exact (hC.boxTemp _ hsf).2

/-- `denseIndicatorClosure` emits the empty list: it exists to make `checkAxiomNeg` fire. -/
theorem applyRule_denseIndicatorClosure_closed :
    ∀ g ∈ (applyRule .denseIndicatorClosure sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals simp_all only [List.not_mem_nil, SignedFormula.pos, SignedFormula.neg, reduceCtorEq]

end NonAnalytic

end FormalSystem.Metalogic.Decidability

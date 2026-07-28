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

## What T2 must fix: no *finite* `C` satisfies `TableauClosed` as stated

T1 is an implication and is true and complete as proved below. But `TimeTypeBound.lean` needs a
**finite** `C`, and three of the fields here re-trigger on their own output, each time on a
strictly larger formula. All three were checked against these definitions rather than reasoned
about informally:

* `sep` applies to its own conclusion. From `K⁺ψ ∈ C` it gives `K⁺(K⁺ψ ∧ K⁻ψ) ∈ C`, which is
  again of the form `K⁺ψ′`, so `sep` fires again on `ψ′ = K⁺ψ ∧ K⁻ψ`, and so on.
* `gapU` (and `gapS`) re-trigger through `sub`. From `U(⊤, g) ∈ C` the conclusion
  `U(¬g ∨ K⁺¬g, g)` has `K⁺¬g = ¬U(⊤, ¬¬g)` as a subformula, so `U(⊤, ¬¬g) ∈ C`, and `gapU`
  fires again on `¬¬g`.
* `trich` re-triggers on its own second disjunct. `F(x ∧ Fy)` is itself of the form
  `F(x ∧ y′)` with `y′ = Fy`, so the field yields `F(x ∧ FFy)`, then `F(x ∧ FFFy)`, …

The root cause is uniform: **each of these fields is keyed on strictly less than the rule's actual
trigger.** `priorUGap` does not fire on `U(⊤,g)`; it fires on the conjunction
`U(⊤,g) ∧ F¬g`. `sepRule` does not fire on `K⁺ψ`; it fires on
`K⁺ψ ∧ ¬K⁺(ψ ∧ U(ψ,¬ψ))`. `orderTrichotomy` does not fire on a disjunct being present; it fires
only when the branch carries the *negation* of a disjunct at the common predecessor — which is
exactly what `applyRule_orderTrichotomy_closed` reads out of the rule below, and exactly what the
field drops.

So the T2 obligation is not "find a big enough closure"; it is **re-key `gapU`, `gapS`, `sep` and
`trich` to the conjunctions and branch-side guards the rules actually test**, then show the
resulting operator terminates. The three re-keyings are mechanical for `gapU`/`gapS`/`sep` (the
rule cases already have the conjunction in `hsf`, so their closers shorten rather than lengthen).
`trich` is the substantive one, because its real guard is a statement about the branch and not
about `C`, which may mean `trich` should move out of `TableauClosed` and into the branch
invariant that `Fuel.lean` carries.

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

/--
`serialityRule` takes no trigger at all, so `hsf` is absent from the statement: `T(F⊤)` and
`T(P⊤)` come from the `serialFuture`/`serialPast` fields alone.

The extra `simp only … at hg` after the `simp_all only` is not redundant. `serialityRule` is arm
35 of 36, and the arm that survives carries the whole cascade of "rule ≠ …" hypotheses the
splitter accumulated; `simp_all` declines to rewrite `hg` in that context, leaving `hg` in its
raw `List.filter` form. Rewriting `hg` on its own afterwards is what makes the two closers apply.
-/
theorem applyRule_serialityRule_closed (hC : TableauClosed C) :
    ∀ g ∈ (applyRule .serialityRule sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.mem_filter, List.mem_cons, List.not_mem_nil, or_false,
    Bool.not_eq_eq_eq_not, Bool.not_true, SignedFormula.pos, reduceCtorEq])
  all_goals (try simp only [List.mem_filter, List.mem_cons, List.not_mem_nil, or_false] at hg)
  all_goals (try (obtain ⟨hg, -⟩ := hg))
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hC.serialFuture
    | exact hC.serialPast

/--
`timeLinearity` is the only `.branchingOrdered` rule, so its conclusion is about the whole
post-rule branch rather than about additions; the hypothesis is correspondingly `hb`, not `hsf`.
Arms 1 and 2 carry `b` verbatim and arm 3 carries `b.identifyTime t₂ t₁`, which
`identifyTime_formula_mem` shows is formula-preserving.

The three-way `rcases hg with hg | hg | hg` is deliberately *not* `repeat' rcases hg with hg | hg`
as in the propositional cases. Here the disjuncts are themselves `List.Mem` proofs, and `repeat'`
happily carries on destructing those into `head`/`tail`, shredding `b` into a cons-cell pattern
and leaving goals that `hb` no longer applies to.
-/
theorem applyRule_timeLinearity_closed (hb : ∀ g ∈ b, g.formula ∈ C) :
    ∀ g ∈ (applyRule .timeLinearity sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil,
    List.append_nil, List.mem_append, List.not_mem_nil, or_false, reduceCtorEq])
  all_goals (try simp only [List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil,
    List.append_nil, List.mem_append, List.not_mem_nil, or_false] at hg)
  all_goals (try (rcases hg with hg | hg | hg))
  all_goals first
    | (apply hb; assumption)
    | (apply identifyTime_formula_mem hb; assumption)

end NonAnalytic

section PersistentUniversal

-- These six sit between arms 6 and 27 of the match, so they are cheaper than the non-analytic
-- block above, but still well past the default heartbeat budget.
set_option maxHeartbeats 1000000

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/-! ### The persistent-universal family

`boxPos`, `diamondNeg`, `allFuturePos`, `allPastPos`, `someFutureNeg` and `somePastNeg` all have
the same body: a `List.filterMap` over `knownWorlds`, `futureOf`, or `pastOf` whose function is
`fun x => if branch.contains (prop x) then none else some (prop x)`. `mem_filterMap_guarded`
collapses that to `g = prop x` in one step, so each proof is the split cascade followed by a
single component-extraction lemma. The label varies with `x`, but the *formula* does not — which
is exactly why one closer suffices for the whole filterMap.
-/

theorem applyRule_boxPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .boxPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.not_mem_nil, reduceCtorEq])
  all_goals (try (obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg))
  all_goals exact hC.box_inner hsf

theorem applyRule_diamondNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .diamondNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asDiamond?_eq_iff, List.not_mem_nil, reduceCtorEq])
  all_goals (try (obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg))
  all_goals exact hC.diamond_inner hsf

theorem applyRule_allFuturePos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .allFuturePos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.not_mem_nil, reduceCtorEq])
  all_goals (try (obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg))
  all_goals exact hC.allFuture_inner hsf

theorem applyRule_allPastPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .allPastPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.not_mem_nil, reduceCtorEq])
  all_goals (try (obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg))
  all_goals exact hC.allPast_inner hsf

theorem applyRule_someFutureNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .someFutureNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asSomeFuture?_eq_iff, List.not_mem_nil, reduceCtorEq])
  all_goals (try (obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg))
  all_goals exact hC.untl_left hsf

theorem applyRule_somePastNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .somePastNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asSomePast?_eq_iff, List.not_mem_nil, reduceCtorEq])
  all_goals (try (obtain ⟨-, -, rfl⟩ := mem_filterMap_guarded hg))
  all_goals exact hC.snce_left hsf

end PersistentUniversal

/--
Every propagation block of the fresh-witness rules emits a **subformula** of a branch formula.

That single observation is what makes those rules tractable. Their blocks differ in shape — some
match on the trigger's connective first (`boxProps`, `gProps`), some guard on a time (`fNegProps`),
some only relabel (`tempGProps`) — but in every case the emitted formula is either a component of
the source formula or the source formula itself, and `subformulas` is reflexive
(`Formula.self_mem_subformulas`). Routing through `sub` therefore replaces a per-block choice of
component-extraction lemma with one uniform obligation that `simp [Formula.subformulas]` closes,
and the obligation is discharged in a context with the 900-line `applyRule` term cleared away.
-/
theorem mem_filterMap_sub {C : Finset Formula} {b : Branch} {P : SignedFormula → Bool}
    {F : SignedFormula → Option SignedFormula} {g : SignedFormula} (hC : TableauClosed C)
    (hb : ∀ x ∈ b, x.formula ∈ C)
    (hF : ∀ x y, F x = some y → y.formula ∈ Formula.subformulas x.formula)
    (h : g ∈ (b.filter P).filterMap F) : g.formula ∈ C := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  exact hC.of_sub (hb x (List.mem_of_mem_filter hx)) (hF x g hxg)


section FreshWitness

-- The fresh-witness rules are the propagation-heavy ones; several sit late in the match.
set_option maxHeartbeats 4000000

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/-! ### The fresh-witness family

These rules mint a fresh world or time, put a witness there, and then drag every universal
already on the branch across to it. Their statements carry `hb` as well as `hsf`, because the
propagation blocks read formulas back off the branch.

The proofs share one shape. After the split cascade, `hg` is a membership in a nest of
`::`/`++`/`flatten`, `repeat' rcases` peels it into one goal per block, and a three-alternative
`first` chain closes them: the witness goal by a component lemma applied to `hsf` (`rcases` has
already substituted `g`, which is why that alternative must come first and must not mention
`hg`), each propagation block by `mem_filterMap_sub`, and the `boxDiamondPersistence` block by
`mem_boxDiamondPersistence`. The chain is three alternatives long, not thirty, and its expensive
alternative runs only after `clear` has removed the unfolded `applyRule` term from the context —
both of those are what keep this inside the memory ceiling described above.
-/

theorem applyRule_boxNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .boxNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.boxPosFormulas, Branch.diamondNegFormulas, Branch.allFuturePosAtTime,
    Branch.allPastPosAtTime, Branch.someFutureNegAtTime, Branch.somePastNegAtTime,
    Branch.untlNegAtTime, Branch.snceNegAtTime,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

theorem applyRule_diamondPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .diamondPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asDiamond?_eq_iff, reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.boxPosFormulas, Branch.diamondNegFormulas, Branch.allFuturePosAtTime,
    Branch.allPastPosAtTime, Branch.someFutureNegAtTime, Branch.somePastNegAtTime,
    Branch.untlNegAtTime, Branch.snceNegAtTime,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

theorem applyRule_allFutureNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .allFutureNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allFuturePosFormulas, Branch.someFutureNegFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hC.allFuture_inner hsf
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

theorem applyRule_allPastNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .allPastNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allPastPosFormulas, Branch.somePastNegFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hC.allPast_inner hsf
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

theorem applyRule_someFuturePos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .someFuturePos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asSomeFuture?_eq_iff, reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allFuturePosFormulas, Branch.someFutureNegFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hC.untl_left hsf
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

theorem applyRule_somePastPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .somePastPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asSomePast?_eq_iff, reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allPastPosFormulas, Branch.somePastNegFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hC.snce_left hsf
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)
/-! ### Until and Since

`untlPos`/`sncePos` split into an event branch and a guard-and-continue branch; `untlNeg`/`snceNeg`
run the Reynolds co-decomposition, and both of their arms re-include the trigger `sf` itself. That
re-inclusion is why these four need the `(simp_all only []; done)` alternative: `simp_all` has by
then rewritten `hsf` through the `asUntil?`/`asSince?` inversion, so `hsf` no longer *says*
`sf.formula ∈ C` even though the surviving arm equation still proves it. The `done` is what keeps
that alternative from silently accepting a goal it only partly simplified.
-/

theorem applyRule_untlPos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .untlPos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asUntil?_eq_iff, reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allFuturePosFormulas, Branch.someFutureNegFormulas, Branch.untlNegFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hsf
    | exact hC.untl_left hsf
    | exact hC.untl_right hsf
    | (simp_all only []; done)
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

theorem applyRule_sncePos_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .sncePos sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asSince?_eq_iff, reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allPastPosFormulas, Branch.somePastNegFormulas, Branch.snceNegFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hsf
    | exact hC.snce_left hsf
    | exact hC.snce_right hsf
    | (simp_all only []; done)
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

theorem applyRule_untlNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .untlNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asUntil?_eq_iff, reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allFuturePosFormulas, Branch.someFutureNegFormulas, Branch.untlNegFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hsf
    | exact hC.untl_left hsf
    | exact hC.untl_right hsf
    | (simp_all only []; done)
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

theorem applyRule_snceNeg_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .snceNeg sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asSince?_eq_iff, reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allPastPosFormulas, Branch.somePastNegFormulas, Branch.snceNegFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hsf
    | exact hC.snce_left hsf
    | exact hC.snce_right hsf
    | (simp_all only []; done)
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
    | (obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; rw [hsg]; exact hb _ hs)

end FreshWitness

section FrameClass

-- The frame-class rules sit at positions 27-34 of the match.
set_option maxHeartbeats 4000000

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/-! ### The frame-class rules

Five of these consume a dedicated `TableauClosed` field and nothing else can close them:
`priorUZ`/`priorSZ` take `priorU`/`priorS`, `priorUGap`/`priorSGap` take `gapU`/`gapS`, and
`sepRule` takes `sep`. The three `and_left` uses are the same step in each: the Dedekind rules
trigger on a conjunction, and it is the conjunction's *left* operand — `U(⊤, g)`, `S(⊤, g)`,
`K⁺ψ` — that the field is stated about. `beq_iff_eq` is what turns the rules' own `e == ⊤` guard
into the equation that makes `e` and `⊤` the same term.

`z1Rule` and `densityRule` are analytic despite their setting, as the module docstring records.
`z1Rule`'s closer needs `Formula.someFuture`, `Formula.neg` and `Formula.top` in its `simp` set
alongside `Formula.allFuture`: `simp` normalises `G ψ` to `¬F¬ψ`, while `split` leaves the
trigger in raw `imp`/`untl` form, and without unfolding both spellings down to constructors the
two sides of the subformula goal never meet.
-/

theorem applyRule_priorUZ_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .priorUZ sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asSomeFuture?_eq_iff, List.mem_cons, List.not_mem_nil, or_false,
    reduceCtorEq])
  all_goals (try subst hg)
  all_goals exact hC.priorU _ hsf

theorem applyRule_priorSZ_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .priorSZ sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asSomePast?_eq_iff, List.mem_cons, List.not_mem_nil, or_false,
    reduceCtorEq])
  all_goals (try subst hg)
  all_goals exact hC.priorS _ hsf

theorem applyRule_z1Rule_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .z1Rule sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [List.mem_cons, List.not_mem_nil, or_false, reduceCtorEq])
  all_goals (try subst hg)
  all_goals (exact hC.of_sub hsf (by simp [SignedFormula.pos, Formula.allFuture,
    Formula.someFuture, Formula.neg, Formula.top, Formula.subformulas,
    Formula.self_mem_subformulas]))

theorem applyRule_priorUGap_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .priorUGap sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asAnd?_eq_iff, Bool.and_eq_true, beq_iff_eq, List.mem_cons,
    List.not_mem_nil, or_false, reduceCtorEq])
  all_goals (try subst hg)
  all_goals exact hC.gapU _ (hC.and_left hsf)

theorem applyRule_priorSGap_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .priorSGap sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asAnd?_eq_iff, Bool.and_eq_true, beq_iff_eq, List.mem_cons,
    List.not_mem_nil, or_false, reduceCtorEq])
  all_goals (try subst hg)
  all_goals exact hC.gapS _ (hC.and_left hsf)

theorem applyRule_sepRule_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C) :
    ∀ g ∈ (applyRule .sepRule sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [asAnd?_eq_iff, Bool.and_eq_true, beq_iff_eq, List.mem_cons,
    List.not_mem_nil, or_false, reduceCtorEq])
  all_goals (try subst hg)
  all_goals exact hC.sep _ (hC.and_left hsf)

theorem applyRule_densityRule_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .densityRule sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [reduceCtorEq, List.not_mem_nil])
  all_goals (try simp only [
    Branch.allFuturePosFormulas,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false] at hg)
  all_goals (try (repeat' rcases hg with hg | hg))
  all_goals first
    | exact hC.allFuture_inner hsf
    | (simp_all only []; done)
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


/--
`orderTrichotomy` is analytic, and this proof is where that shows up concretely.

The rule's restriction 3 fires only when the branch already carries the *negation* of one of the
three `temp_linearity` disjuncts at the common predecessor. `List.find?_some` turns the surviving
`candidates.find? fires = some (t₀, ψ)` into `fires (t₀, ψ) = true`, whose last conjunct is
exactly that guard; `mem_of_branch_contains` and `hb` then put one disjunct in `C`, and the
`trich` field carries the other two. Nothing here conjures a formula the branch did not already
mention — which is what stops the closure iterating `F(F(x ∧ y) ∧ y′)` without bound.
-/
theorem applyRule_orderTrichotomy_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) :
    ∀ g ∈ (applyRule .orderTrichotomy sf b ord).1.emitted, g.formula ∈ C := by
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [reduceCtorEq, List.not_mem_nil])
  have hfires := List.find?_some (by assumption)
  simp only [Bool.and_eq_true, List.any_cons, List.any_nil, Bool.or_eq_true, Bool.or_false,
    Bool.false_or] at hfires
  obtain ⟨-, hany⟩ := hfires
  have htri := hC.trich _ _ (by
    rcases hany with h | h | h
    · exact Or.inl (hb _ (mem_of_branch_contains h))
    · exact Or.inr (Or.inl (hb _ (mem_of_branch_contains h)))
    · exact Or.inr (Or.inr (hb _ (mem_of_branch_contains h))))
  simp only [List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil, List.append_nil,
    List.mem_append, List.mem_cons, List.not_mem_nil, or_false] at hg
  repeat' rcases hg with hg | hg
  all_goals first
    | exact hsf
    | exact htri.1
    | exact htri.2.1
    | exact htri.2.2

end FrameClass

section Combined

variable {C : Finset Formula} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}

/--
T1, assembled: **no rule of the calculus emits a formula outside a `TableauClosed` set.**

This is the form `Fuel.lean` consumes, and it costs nothing to state now that every case is
proved: `cases rule` does not unfold `applyRule`, so the 900-line match never enters a goal here
and the whole theorem elaborates in the time of thirty-six `exact`s. The expensive work is
already paid for, one declaration at a time, above.

The hypotheses are the union of what the cases need. `hb` is genuinely required and not merely
convenient: the propagation-heavy rules read universals back off the branch, and `timeLinearity`
carries whole branches into its arms, so a statement about the trigger formula alone would be
false for them.
-/
theorem applyRule_subformula_closed (hC : TableauClosed C) (hsf : sf.formula ∈ C)
    (hb : ∀ x ∈ b, x.formula ∈ C) (rule : TableauRule) :
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
  | .orderTrichotomy => applyRule_orderTrichotomy_closed hC hsf hb
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

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.MinusLanguage.Formula
import Mathlib.Tactic.Push
import Mathlib.Tactic.Tauto

-- Lower semantic layer: must not reach the proof system (G-15). `FrameClassValidity.lean`
-- is the one documented seam that imports `ProofSystem.Axioms`; nothing below it may.
assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass

set_option autoImplicit false

/-!
# `MinusFrame` — a native L⁻ frame notion, not bound to `TaskFrame`

This module defines a frame notion for the tense-primitive base language L⁻ that is **not** a
task frame, together with a truth recursion over it, the matching validity notion, and the
order-reversal transfer lemma. Everything here is additive: `MinusTruthAt`, `MinusValid` and the whole
`TaskFrame`-bound semantic stack are untouched and sit beside this layer.

## Why a native frame notion is required

`Semantics/MinusTruth.lean`'s `MinusTruthAt` evaluates at a `TaskModel F` for `F : TaskFrame`, and a
`TaskFrame` carries its times in a `Duration : TemporalOrder` — a *nontrivial totally ordered
abelian group*. That group hypothesis is not incidental packaging. It is exactly what
`Semantics/DurationClassification.lean`'s `duration_dense_or_least_pos` consumes, and
`duration_dense_or_least_pos` is what makes `Metalogic/Conservativity/SpWitness.lean`'s
`minusValid_sp` go through: on any ordered abelian group the order is either densely ordered or has
a least positive element, so one of the two disjuncts of

  `(Sp) := □(DF φ) ∨ □(DN ψ)`

is forced. `(Sp)` is therefore valid on *every* task frame, and no `TaskFrame`-bound structure can
refute it. Showing `(Sp)` underivable in TM⁻ demands a class of structures on which TM⁻ remains
sound but the dichotomy fails — which means dropping the group structure entirely, not reindexing
it. Hence a native recursion rather than a change of index.

A `MinusFrame` keeps only what TM⁻'s schemata actually need of time: a nonempty point set with a
transitive irreflexive relation that is unbounded in both directions and forward- and
backward-linear. No group, no successor, no completeness — so a `MinusFrame` may mix order shapes,
which is what a countermodel to `(Sp)` requires.

## `□` is the universal modality

`MinusFrameTruth`'s `box` clause quantifies over *all* points of the frame:

  `MinusFrameTruth F V w (□φ) ↔ ∀ v : F.Point, MinusFrameTruth F V v φ`

This is the cheapest condition making MF (`□φ → □Gφ`) sound: if `φ` holds everywhere then it holds
everywhere in the future of everywhere, and the implication is immediate. It also makes MT, M5 and
MK immediate, so the whole S5 block costs nothing.

The task-frame semantics reaches MF by a different route: there `□` quantifies over the frame's
total histories `H_F`, and MF is underwritten by shift-closure of `H_F` together with `Duration`
being a group. Two different sufficient conditions for the same axiom. That is a feature, not a
discrepancy: an underivability result needs only *some* class of structures on which every TM⁻
schema is sound, and the native class here is that class. Nothing in this module claims the two
semantics agree, and nothing downstream should assume they do.

## Converse closure and TD

`no_min` and `past_lin` are fields rather than derived facts precisely so the class is closed
under order reversal (`MinusFrame.swap`). That closure is what makes `truth_swap` available, and
`truth_swap` is what discharges the temporal-duality *rule* `DerivationTree.temporal_duality` in
one line during native soundness — no swap-strengthened simultaneous induction is needed.

## Main Definitions

- `MinusFrame`: the native frame notion — a nonempty point set with an unbounded, transitive,
  irreflexive, forward- and backward-linear strict order
- `MinusFrame.swap`: order reversal, witnessing converse closure of the class
- `MinusFrameTruth`: truth of a `MinusFormula` at a point of a `MinusFrame` under a valuation, by
  six-clause recursion with `□` read as the universal modality
- `MinusFrameValid`: validity — truth at every point of every `MinusFrame` under every valuation

## Main Results

`MinusFrameTruth.*` — characterization lemmas mirroring `Semantics/MinusTruth.lean`'s `MinusTruth`
namespace one for one:

- `bot_false`, `imp_iff`, `box_iff`, `past_iff`, `future_iff` — the primitive clauses
- `neg_iff`, `top_true`, `and_iff`, `or_iff` — the derived Boolean operators
- `diamond_iff`, `somePast_iff`, `someFuture_iff` — the derived existentials, each the classical
  `¬∀¬ ↔ ∃` step
- `always_iff` — `△φ`, from `and_iff` together with `past_iff` and `future_iff`

`truth_swap` — the order-reversal transfer lemma: truth on `F.swap` is truth on `F` of the swapped
formula.

## References

* JPL paper `\S sub:Logic` — `def:BL-language`, `def:BL-semantics` (which this deliberately
  departs from in its `□` clause; see above)
* `FormalSystem/Semantics/MinusTruth.lean` — the `TaskFrame`-bound recursion this sits beside
* `FormalSystem/Metalogic/Conservativity/SpCountermodel.lean` — the consumer: native L⁻ soundness
  and the two-fibre refutation of `(Sp)`

## Tags

frame · base-language · MinusFrame · universal-modality · order-reversal
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax FormalSystem.MinusLanguage

/--
A native L⁻ frame: a nonempty set of points carrying a strict order that is transitive,
irreflexive, unbounded in both directions, and linear both forwards and backwards from any point.

These are exactly the conditions TM⁻'s temporal schemata need (`T4` from `lt_trans`, `TS` from
`no_max`, `TC` from the definition of the past existential, `TL` from `fut_lin`), and no more. In
particular there is **no** group structure on `Point`, which is what frees the class from the
dense-or-discrete dichotomy that makes `(Sp)` valid on every task frame — see the module
docstring.

`no_min` and `past_lin` are included so that the class is closed under order reversal
(`MinusFrame.swap`); that closure discharges the temporal-duality rule.
-/
structure MinusFrame where
  /-- The carrier: the frame's set of times. -/
  Point : Type
  /-- The carrier is nonempty, so validity on the class is a nontrivial demand. -/
  [pointNonempty : Nonempty Point]
  /-- The strict temporal order: `lt a b` reads "`a` is earlier than `b`". -/
  lt : Point → Point → Prop
  /-- Transitivity of the order; underwrites `T4` (`Gφ → GGφ`). -/
  lt_trans : ∀ {a b c}, lt a b → lt b c → lt a c
  /-- Irreflexivity of the order. -/
  lt_irrefl : ∀ a, ¬ lt a a
  /-- No last point; underwrites `TS` (`F⊤`). -/
  no_max : ∀ a, ∃ b, lt a b
  /-- No first point; the past mirror of `no_max`, present so the class is converse-closed. -/
  no_min : ∀ a, ∃ b, lt b a
  /-- Forward linearity: any two futures of a point are comparable. Underwrites `TL`. -/
  fut_lin : ∀ {a b c}, lt a b → lt a c → lt b c ∨ b = c ∨ lt c b
  /-- Backward linearity: any two pasts of a point are comparable; the mirror of `fut_lin`,
  present so the class is converse-closed. -/
  past_lin : ∀ {a b c}, lt b a → lt c a → lt b c ∨ b = c ∨ lt c b

attribute [instance] MinusFrame.pointNonempty

/--
Rotate a trichotomy disjunction `r b c ∨ b = c ∨ r c b` into `r c b ∨ b = c ∨ r b c`.

Used only by `MinusFrame.swap`: reversing the order turns `fut_lin`'s conclusion into `past_lin`'s
and vice versa, but the two disjunctions list their strict cases in opposite orders, so a rotation
is needed to match the field shape.
-/
private theorem triRotate {α : Type} {r : α → α → Prop} {b c : α}
    (h : r b c ∨ b = c ∨ r c b) : r c b ∨ b = c ∨ r b c := by
  rcases h with h | h | h
  · exact Or.inr (Or.inr h)
  · exact Or.inr (Or.inl h)
  · exact Or.inl h

/--
Order reversal on a `MinusFrame`: keep the points, invert `lt`.

The class of `MinusFrame`s is closed under this operation — `no_max` and `no_min` swap roles, as do
`fut_lin` and `past_lin` (modulo `triRotate`). That closure is exactly what makes the
temporal-duality rule sound on the class, via `truth_swap`.
-/
def MinusFrame.swap (F : MinusFrame) : MinusFrame where
  Point := F.Point
  lt := fun a b => F.lt b a
  lt_trans := fun h1 h2 => F.lt_trans h2 h1
  lt_irrefl := F.lt_irrefl
  no_max := F.no_min
  no_min := F.no_max
  fut_lin := fun h1 h2 => triRotate (F.past_lin h1 h2)
  past_lin := fun h1 h2 => triRotate (F.fut_lin h1 h2)

/--
Truth of a base-language formula at a point of a `MinusFrame` under a valuation.

Six clauses, one per `MinusFormula` constructor. The temporal clauses are strict, exactly as in
`MinusTruthAt`. The `box` clause is the **universal modality** over `Point` — see the module
docstring for why that reading is chosen and how it differs from the task-frame semantics.
-/
def MinusFrameTruth (F : MinusFrame) (V : F.Point → Atom → Prop) (w : F.Point) : MinusFormula → Prop
  | .atom p => V w p
  | .bot => False
  | .imp φ ψ => MinusFrameTruth F V w φ → MinusFrameTruth F V w ψ
  | .box φ => ∀ v : F.Point, MinusFrameTruth F V v φ
  | .allPast φ => ∀ v : F.Point, F.lt v w → MinusFrameTruth F V v φ
  | .allFuture φ => ∀ v : F.Point, F.lt w v → MinusFrameTruth F V v φ

/--
Validity on the native L⁻ frame class: truth at every point of every `MinusFrame` under every
valuation.

This is the notion native L⁻ soundness (`Metalogic/minusFrameValid_of_derivation`) concludes, and the
notion the two-fibre countermodel refutes for `(Sp)`.
-/
def MinusFrameValid (φ : MinusFormula) : Prop :=
  ∀ (F : MinusFrame) (V : F.Point → Atom → Prop) (w : F.Point), MinusFrameTruth F V w φ

namespace MinusFrameTruth

variable {F : MinusFrame} {V : F.Point → Atom → Prop} {w : F.Point}

/-! ### The primitive clauses -/

/-- Bot (`⊥`) is false at every point. -/
theorem bot_false : ¬ MinusFrameTruth F V w MinusFormula.bot := id

/-- Truth of implication is the material conditional. -/
theorem imp_iff (φ ψ : MinusFormula) :
    MinusFrameTruth F V w (φ.imp ψ) ↔ (MinusFrameTruth F V w φ → MinusFrameTruth F V w ψ) := Iff.rfl

/-- Truth of `□φ`: `φ` holds at **every** point of the frame. `□` is the universal modality
here; see the module docstring. -/
theorem box_iff (φ : MinusFormula) :
    MinusFrameTruth F V w φ.box ↔ ∀ v : F.Point, MinusFrameTruth F V v φ := Iff.rfl

/-- Truth of `Hφ`: `φ` holds at every strictly earlier point. -/
theorem past_iff (φ : MinusFormula) :
    MinusFrameTruth F V w φ.allPast ↔ ∀ v, F.lt v w → MinusFrameTruth F V v φ := Iff.rfl

/-- Truth of `Gφ`: `φ` holds at every strictly later point. -/
theorem future_iff (φ : MinusFormula) :
    MinusFrameTruth F V w φ.allFuture ↔ ∀ v, F.lt w v → MinusFrameTruth F V v φ := Iff.rfl

/-! ### The derived Boolean operators -/

/-- Truth of `¬φ` (`φ → ⊥`) is failure of `φ`. -/
@[simp] theorem neg_iff (φ : MinusFormula) :
    MinusFrameTruth F V w φ.neg ↔ ¬ MinusFrameTruth F V w φ := Iff.rfl

/-- `⊤` (`⊥ → ⊥`) is true at every point. -/
@[simp] theorem top_true : MinusFrameTruth F V w MinusFormula.top := id

/-- Truth of `φ ∧ ψ` is conjunction. -/
@[simp] theorem and_iff (φ ψ : MinusFormula) :
    MinusFrameTruth F V w (φ.and ψ) ↔ (MinusFrameTruth F V w φ ∧ MinusFrameTruth F V w ψ) := by
  simp only [MinusFormula.and, MinusFormula.neg, MinusFrameTruth]; tauto

/-- Truth of `φ ∨ ψ` is disjunction. -/
@[simp] theorem or_iff (φ ψ : MinusFormula) :
    MinusFrameTruth F V w (φ.or ψ) ↔ (MinusFrameTruth F V w φ ∨ MinusFrameTruth F V w ψ) := by
  simp only [MinusFormula.or, MinusFormula.neg, MinusFrameTruth]; tauto

/-! ### The derived existentials

Each is the classical `¬∀¬ ↔ ∃` step. `push Not` is used rather than the deprecated `push_neg`.
-/

/-- Truth of `◇φ` (`¬□¬φ`): `φ` holds at *some* point of the frame. -/
@[simp] theorem diamond_iff (φ : MinusFormula) :
    MinusFrameTruth F V w φ.diamond ↔ ∃ v : F.Point, MinusFrameTruth F V v φ := by
  simp only [MinusFormula.diamond, MinusFormula.neg, MinusFrameTruth]
  constructor
  · intro h; by_contra hc; push Not at hc; exact h (fun v hv => hc v hv)
  · rintro ⟨v, hv⟩ h; exact h v hv

/-- Truth of `Fφ` (`¬G¬φ`): `φ` holds at *some* strictly later point. -/
@[simp] theorem someFuture_iff (φ : MinusFormula) :
    MinusFrameTruth F V w φ.someFuture ↔ ∃ v, F.lt w v ∧ MinusFrameTruth F V v φ := by
  simp only [MinusFormula.someFuture, MinusFormula.neg, MinusFrameTruth]
  constructor
  · intro h; by_contra hc; push Not at hc; exact h (fun v hv hφ => hc v hv hφ)
  · rintro ⟨v, hv, hφ⟩ h; exact h v hv hφ

/-- Truth of `Pφ` (`¬H¬φ`): `φ` holds at *some* strictly earlier point. -/
@[simp] theorem somePast_iff (φ : MinusFormula) :
    MinusFrameTruth F V w φ.somePast ↔ ∃ v, F.lt v w ∧ MinusFrameTruth F V v φ := by
  simp only [MinusFormula.somePast, MinusFormula.neg, MinusFrameTruth]
  constructor
  · intro h; by_contra hc; push Not at hc; exact h (fun v hv hφ => hc v hv hφ)
  · rintro ⟨v, hv, hφ⟩ h; exact h v hv hφ

/-! ### The temporal universal -/

/-- Truth of `△φ` (`Hφ ∧ (φ ∧ Gφ)`): `φ` holds at every point of the frame's own timeline —
past, present and future. The association mirrors `MinusFormula.always`. -/
@[simp] theorem always_iff (φ : MinusFormula) :
    MinusFrameTruth F V w φ.always ↔
      (∀ v, F.lt v w → MinusFrameTruth F V v φ) ∧ MinusFrameTruth F V w φ ∧
        (∀ v, F.lt w v → MinusFrameTruth F V v φ) := by
  simp only [MinusFormula.always, and_iff, past_iff, future_iff]

end MinusFrameTruth

/--
**Order-reversal transfer.** Truth on the reversed frame is truth on the original frame of the
swapped formula.

Six cases, each immediate: the atom and bot clauses do not mention the order, `imp` and `box` are
congruences, and the two temporal clauses trade places exactly as `MinusFormula.swapMinus` does. This
one lemma is what makes the temporal-duality rule sound on the native class, replacing the
swap-strengthened simultaneous induction used in the task-frame soundness proof.
-/
theorem truth_swap (F : MinusFrame) (V : F.Point → Atom → Prop) (w : F.Point) (φ : MinusFormula) :
    MinusFrameTruth F.swap V w φ ↔ MinusFrameTruth F V w φ.swapMinus := by
  induction φ generalizing w with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ih1 ih2 => exact imp_congr (ih1 w) (ih2 w)
  | box φ ih => exact forall_congr' fun v => ih v
  | allPast φ ih => exact forall_congr' fun v => imp_congr_right fun _ => ih v
  | allFuture φ ih => exact forall_congr' fun v => imp_congr_right fun _ => ih v

end FormalSystem.Semantics

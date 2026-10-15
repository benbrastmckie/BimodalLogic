/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.NomicLanguage.Formula
import FormalSystem.Semantics.Nomic

/-!
# `NomicTruthAt` — truth for BL plus the nomic operator

The native truth recursion for `NomicFormula` (`FormalSystem/NomicLanguage/Formula.lean`) over a
nomic frame. The six BL clauses are `TruthAt`'s verbatim, read at a bare state function rather
than at a `WorldHistory`, and the seventh is `def:nomic-frame`'s clause for the nomic operator:

```
M,τ,x ⊨ ◈φ   iff   M,σ,x ⊨ φ for all σ ∈ H_F^{τ(x)},
```

so that the accessibility relation at `x` relates `τ` to the law-histories at the world state `τ`
occupies there. The frame-level form of that relation is `NomicFrame.accRel`
(`FormalSystem/Semantics/Nomic/Uniformity.lean`).

## Why the evaluation point is a bare function

`NomicTruthAt` takes `τ : ↑D → F.World` with **no membership proof**. The cluster under
`FormalSystem/Semantics/Nomic/`
already pays this cost at the frame level — `lawHist` is a set of bare functions, because `HF`'s
union does not typecheck over a family of `WorldHistory` types — and inheriting it means the
recursion threads no proof and needs no transport anywhere. Validity, not truth, is where
`τ ∈ F.HF` enters; see `NomicLanguage/NomicValidity.lean`.

## Why the clause layer is duplicated rather than instantiated

`FormalSystem/Semantics/TruthClauses.lean` is the tree's abstract clause layer, and **it cannot
be instantiated here.** `TruthEnv.T` has type
`∀ {F : TaskFrame}, TaskModel F → WorldHistory F → F.Duration → Env F → L → Prop`, and every one
of `BotClause`, `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause` and `StabClause` repeats that
binder set. A nomic evaluation point is `(τ : ↑D → F.World, x : ↑D)` over a `NomicFrame D`, its
`□` clause quantifies `∀ σ ∈ F.HF` and its `◈` clause `∀ σ ∈ F.lawHist (τ x)`; and `H_F` is a
union of law-history sets which, for a non-uniform frame, is the world-history set of **no** task
frame, so the `WorldHistory F` binder cannot be met at all. The nine derived-operator clause
lemmas are therefore re-derived natively below.

Generalising `TruthClauses.lean` over the point structure would be a refactor across six language
components, and is deliberately not attempted here. The duplication is recorded with its cause so
that a future reader does not take it for carelessness.

## Main Definitions

- `NomicModel` — a model on a nomic frame: a valuation on world states
- `NomicTruthAt` — the seven-clause truth recursion

## Main Results

- The seven primitive clause lemmas `NomicTruth.atom_iff` … `NomicTruth.nomic_iff`
- The nine derived clause lemmas, including the two collapsed forms `always_iff` and
  `next_iff_succ`, with the ℤ specialisation `next_iff_add_one`
- `nomic_iff_box_of_uniform` — the uniformity collapse, for **every** formula and with no
  induction. Choice-free, at `[propext]`

## References

* JPL paper `def:nomic-frame` — the Nomic clause formalized here
* JPL paper `def:BL-semantics` — the six BL clauses, read at a bare state function
* JPL paper `thm:nomic-uniform`, closing sentence — the collapse `nomic_iff_box_of_uniform`
* `FormalSystem/Semantics/Truth.lean` — `TruthAt`, the recursion mirrored here
* `FormalSystem/Semantics/TruthClauses.lean` — the abstract clause layer, and why it is unusable
* `FormalSystem/Metalogic/DiscreteNonCompactness.lean` — `truthAt_next_iff`, which `next_iff_succ`
  transcribes

## Tags

truth · nomic-language · nomic-operator · law-histories
-/

namespace FormalSystem.NomicLanguage

open FormalSystem.Syntax
open FormalSystem.NomicLanguage.NomicFormula
open FormalSystem.Semantics

variable {D : TemporalOrder}

/-! ## Models and the truth recursion -/

/--
A model on a nomic frame: a valuation assigning a truth value to each atom at each **world
state**, exactly as `TaskModel` does. No history-indexed data is needed, since the nomic frame's
carrier is one shared set of states.
-/
structure NomicModel (F : NomicFrame D) where
  /-- The valuation: which atoms hold at which world states. -/
  valuation : F.World → Atom → Prop

/--
Truth of a formula at a model, a bare state function and a time.

The six BL clauses are `TruthAt`'s verbatim, with `∀ σ ∈ F.HF` in place of `∀ σ : WorldHistory F`
in the box clause. The seventh is `def:nomic-frame`'s: `◈φ` holds at `(τ, x)` iff `φ` holds at
`(σ, x)` for every law-history `σ` at the state `τ x`.
-/
def NomicTruthAt {F : NomicFrame D} (M : NomicModel F) (τ : ↑D → F.World) (x : ↑D) :
    NomicFormula → Prop
  | .atom p => M.valuation (τ x) p
  | .bot => False
  | .imp φ ψ => NomicTruthAt M τ x φ → NomicTruthAt M τ x ψ
  | .box φ => ∀ σ ∈ F.HF, NomicTruthAt M σ x φ
  | .untl ψ φ => ∃ y : ↑D, x < y ∧ NomicTruthAt M τ y φ ∧
      ∀ z : ↑D, x < z → z < y → NomicTruthAt M τ z ψ
  | .snce ψ φ => ∃ y : ↑D, y < x ∧ NomicTruthAt M τ y φ ∧
      ∀ z : ↑D, y < z → z < x → NomicTruthAt M τ z ψ
  | .nomic φ => ∀ σ ∈ F.lawHist (τ x), NomicTruthAt M σ x φ

namespace NomicTruth

variable {F : NomicFrame D} (M : NomicModel F) (τ : ↑D → F.World) (x : ↑D)

/-! ### The seven primitive clause lemmas -/

/-- The atom clause: an atom is read off the world state occupied at the time of evaluation. -/
theorem atom_iff (p : Atom) : NomicTruthAt M τ x (.atom p) ↔ M.valuation (τ x) p := Iff.rfl

/-- The falsum clause. -/
theorem bot_iff : NomicTruthAt M τ x .bot ↔ False := Iff.rfl

/-- The implication clause. -/
theorem imp_iff (φ ψ : NomicFormula) :
    NomicTruthAt M τ x (.imp φ ψ) ↔ (NomicTruthAt M τ x φ → NomicTruthAt M τ x ψ) := Iff.rfl

/-- The box clause: `□` quantifies over all of `H_F`. -/
theorem box_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (.box φ) ↔ ∀ σ ∈ F.HF, NomicTruthAt M σ x φ := Iff.rfl

/-- The until clause, strict in both bounds. -/
theorem untl_iff (ψ φ : NomicFormula) :
    NomicTruthAt M τ x (.untl ψ φ) ↔
      ∃ y : ↑D, x < y ∧ NomicTruthAt M τ y φ ∧
        ∀ z : ↑D, x < z → z < y → NomicTruthAt M τ z ψ := Iff.rfl

/-- The since clause, strict in both bounds. -/
theorem snce_iff (ψ φ : NomicFormula) :
    NomicTruthAt M τ x (.snce ψ φ) ↔
      ∃ y : ↑D, y < x ∧ NomicTruthAt M τ y φ ∧
        ∀ z : ↑D, y < z → z < x → NomicTruthAt M τ z ψ := Iff.rfl

/-- `def:nomic-frame`'s Nomic clause: `◈` quantifies over the law-histories at the state occupied
at the time of evaluation. -/
theorem nomic_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (.nomic φ) ↔ ∀ σ ∈ F.lawHist (τ x), NomicTruthAt M σ x φ := Iff.rfl

/-! ### The nine derived clause lemmas -/

/-- The negation clause. -/
theorem neg_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (neg φ) ↔ ¬ NomicTruthAt M τ x φ := Iff.rfl

/-- The conjunction clause. `tauto` closes the classical `¬(A → ¬B) ↔ A ∧ B` step. -/
theorem and_iff (φ ψ : NomicFormula) :
    NomicTruthAt M τ x (NomicFormula.and φ ψ) ↔
      (NomicTruthAt M τ x φ ∧ NomicTruthAt M τ x ψ) := by
  simp only [NomicFormula.and, neg, NomicTruthAt]
  tauto

/-- The disjunction clause. -/
theorem or_iff (φ ψ : NomicFormula) :
    NomicTruthAt M τ x (NomicFormula.or φ ψ) ↔
      (NomicTruthAt M τ x φ ∨ NomicTruthAt M τ x ψ) := by
  simp only [NomicFormula.or, neg, NomicTruthAt]
  tauto

/-- The biconditional clause. The derived operator unfolds through `and`, so `NomicFormula.iff`
is unfolded before `and_iff` is applied. -/
theorem iff_iff (φ ψ : NomicFormula) :
    NomicTruthAt M τ x (NomicFormula.iff φ ψ) ↔
      (NomicTruthAt M τ x φ ↔ NomicTruthAt M τ x ψ) := by
  rw [NomicFormula.iff, and_iff]
  exact ⟨fun h => ⟨h.1, h.2⟩, fun h => ⟨h.mp, h.mpr⟩⟩

/-- The existential-future clause: `Fφ` holds iff `φ` holds at some strictly later time. -/
theorem someFuture_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (someFuture φ) ↔ ∃ y : ↑D, x < y ∧ NomicTruthAt M τ y φ := by
  constructor
  · rintro ⟨y, hxy, hy, _⟩
    exact ⟨y, hxy, hy⟩
  · rintro ⟨y, hxy, hy⟩
    exact ⟨y, hxy, hy, fun _ _ _ => fun h => h⟩

/-- The existential-past clause: `Pφ` holds iff `φ` holds at some strictly earlier time. -/
theorem somePast_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (somePast φ) ↔ ∃ y : ↑D, y < x ∧ NomicTruthAt M τ y φ := by
  constructor
  · rintro ⟨y, hyx, hy, _⟩
    exact ⟨y, hyx, hy⟩
  · rintro ⟨y, hyx, hy⟩
    exact ⟨y, hyx, hy, fun _ _ _ => fun h => h⟩

/-- The universal-future clause: `Gφ` holds iff `φ` holds at every strictly later time. -/
theorem allFuture_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (allFuture φ) ↔ ∀ y : ↑D, x < y → NomicTruthAt M τ y φ := by
  rw [allFuture, neg_iff, someFuture_iff]
  constructor
  · intro h y hxy
    by_contra hc
    exact h ⟨y, hxy, hc⟩
  · rintro h ⟨y, hxy, hy⟩
    exact hy (h y hxy)

/-- The universal-past clause: `Hφ` holds iff `φ` holds at every strictly earlier time. -/
theorem allPast_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (allPast φ) ↔ ∀ y : ↑D, y < x → NomicTruthAt M τ y φ := by
  rw [allPast, neg_iff, somePast_iff]
  constructor
  · intro h y hyx
    by_contra hc
    exact h ⟨y, hyx, hc⟩
  · rintro h ⟨y, hyx, hy⟩
    exact hy (h y hyx)

/-- The diamond clause: `◇φ` holds iff `φ` holds along some nomologically possible world. -/
theorem diamond_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (diamond φ) ↔ ∃ σ ∈ F.HF, NomicTruthAt M σ x φ := by
  rw [diamond, neg_iff, box_iff]
  constructor
  · intro h
    by_contra hc
    exact h fun σ hσ hσφ => hc ⟨σ, hσ, hσφ⟩
  · rintro ⟨σ, hσ, hσφ⟩ h
    exact h σ hσ hσφ

/--
The collapsed clause for `always`: `△φ` holds at `x` iff `φ` holds at **every** time.

The three-conjunct introduction form `Hφ ∧ (φ ∧ Gφ)` goes straight to the `∀ y` normal form by
trichotomy on `↑D`'s `LinearOrder`, which `TemporalOrder` carries.
-/
theorem always_iff (φ : NomicFormula) :
    NomicTruthAt M τ x (NomicFormula.always φ) ↔ ∀ y : ↑D, NomicTruthAt M τ y φ := by
  rw [NomicFormula.always, and_iff, and_iff, allPast_iff, allFuture_iff]
  constructor
  · rintro ⟨hp, hn, hf⟩ y
    rcases lt_trichotomy y x with h | h | h
    · exact hp y h
    · exact h ▸ hn
    · exact hf y h
  · intro h
    exact ⟨fun y _ => h y, h x, fun y _ => h y⟩

/--
The collapsed clause for `next` on a discrete order with no maximum: `◯φ` holds at `x` iff `φ`
holds at `Order.succ x`.

Transcribed from `FormalSystem/Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff`: the
`untl` clause's empty-gap condition forces the witness to be the immediate successor.
-/
theorem next_iff_succ [SuccOrder (↑D : Type)] [NoMaxOrder (↑D : Type)] (φ : NomicFormula) :
    NomicTruthAt M τ x (NomicFormula.next φ) ↔ NomicTruthAt M τ (Order.succ x) φ := by
  constructor
  · rintro ⟨y, hxy, hy, hgap⟩
    have h1 : Order.succ x ≤ y := Order.succ_le_of_lt hxy
    rcases lt_or_eq_of_le h1 with h | h
    · exact absurd (hgap (Order.succ x) (Order.lt_succ x) h) not_false
    · exact h ▸ hy
  · intro h
    exact ⟨Order.succ x, Order.lt_succ x, h, fun z hz hzs =>
      absurd hz (not_lt.mpr (Order.le_of_lt_succ hzs))⟩

/-- The ℤ-time specialisation of `next_iff_succ`: over `intOrder`, `Order.succ x` is `x + 1`. -/
theorem next_iff_add_one {F : NomicFrame intOrder} (M : NomicModel F) (τ : ℤ → F.World) (x : ℤ)
    (φ : NomicFormula) :
    NomicTruthAt M τ x (NomicFormula.next φ) ↔ NomicTruthAt M τ (x + 1) φ := by
  rw [next_iff_succ M τ x φ]
  simp

end NomicTruth

/-! ## The uniformity collapse -/

/--
Under uniformity the nomic operator and the box agree on **every** formula.

No induction is needed: `F.Uniform` equates the two clause sets outright, so the biconditional is
one rewrite. The paper's "by induction on `φ`" is unnecessary once the sets are identified.

`change` rather than `show`: the tactic alters the goal, and `linter.style.show` is blocking under
this repository's zero warning budget.

**Choice-free**: this takes no `[F.IsRegular]` instance, never reaches `occurrence`, and measures
at `[propext]`. It consumes no constraint, so it carries no constraints-consumed marker.
-/
theorem nomic_iff_box_of_uniform {F : NomicFrame D} (h : F.Uniform) (M : NomicModel F)
    (τ : ↑D → F.World) (x : ↑D) (φ : NomicFormula) :
    NomicTruthAt M τ x (.nomic φ) ↔ NomicTruthAt M τ x (.box φ) := by
  change (∀ σ ∈ F.lawHist (τ x), NomicTruthAt M σ x φ) ↔ ∀ σ ∈ F.HF, NomicTruthAt M σ x φ
  rw [h (τ x)]

end FormalSystem.NomicLanguage

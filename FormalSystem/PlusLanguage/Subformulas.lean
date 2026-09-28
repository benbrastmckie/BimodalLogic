/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.Formula
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.List.Basic

/-!
# Subformulas and the Subformula Closure for L⁺

`Formula.subformulas` and `subformulaClosure` collect the parts of a formula of the base
language `L`. An L⁺-indexed certificate needs the same thing at `PlusFormula`, whose
seventh constructor is the stability modal `⊡`.

The two inductives share no supertype — `Formula` has six constructors and no stability modal,
`PlusFormula` has seven — so this is a genuine second recursion rather than an instantiation.
It is, however, a *small* one: the six shared arms are transcribed verbatim from
`Syntax/Subformulas.lean` and the seventh mirrors `box`, a formula and its one immediate part.

## The stability arm

`stab φ`'s subformulas are `stab φ` itself together with the subformulas of `φ`, exactly as for
`box φ`. `⊡` binds one formula and inspects the world state rather than the formula, so there is
no second component and no closure condition beyond the obvious one. What distinguishes `⊡` from
`□` is entirely semantic; syntactically the two arms are the same shape, and the L⁺ certificate's
stability condition (C5) is what carries the difference.

## Nothing here imports `Semantics`

Everything below is pure syntax. `PlusLanguage/` is kept free of any dependency on `Semantics/`,
and this module preserves that: its only project import is `PlusLanguage/Formula.lean`.

## Main Definitions

- `PlusFormula.subformulas` — all subformulas of an L⁺ formula, including itself
- `plusSubformulaClosure` — the same as a `Finset`

## Main Results

- `PlusFormula.self_mem_subformulas` — a formula is in its own subformula list
- `PlusFormula.subformulas_trans` — the subformula relation is transitive
- the eight membership lemmas, one per non-atomic component, `stab` included
- the eight closure projections `plusClosure_imp_left`, …, `plusClosure_stab`
-/

namespace FormalSystem.PlusLanguage

namespace PlusFormula

/--
Collect all subformulas of an L⁺ formula, including the formula itself.

Seven arms: the six of `Formula.subformulas`, transcribed, plus `stab`, which mirrors `box`.
The binary arms list the *second* component first, matching the base-language recursion, so that
the `untl`/`snce` membership lemmas below keep their established left/right reading — "left" is
the event, "right" the guard.
-/
def subformulas : PlusFormula → List PlusFormula
  | φ@(.atom _) => [φ]
  | φ@.bot => [φ]
  | φ@(.imp ψ χ) => φ :: (subformulas ψ ++ subformulas χ)
  | φ@(.box ψ) => φ :: subformulas ψ
  | φ@(.untl χ ψ) => φ :: (subformulas ψ ++ subformulas χ)
  | φ@(.snce χ ψ) => φ :: (subformulas ψ ++ subformulas χ)
  | φ@(.stab ψ) => φ :: subformulas ψ

/-- Subformulas include the formula itself. -/
theorem self_mem_subformulas (φ : PlusFormula) : φ ∈ subformulas φ := by
  cases φ <;> simp [subformulas]

/-- Subformulas of an implication include the left component. -/
theorem imp_left_mem_subformulas (ψ χ : PlusFormula) : ψ ∈ subformulas (.imp ψ χ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  exact Or.inr (Or.inl (self_mem_subformulas ψ))

/-- Subformulas of an implication include the right component. -/
theorem imp_right_mem_subformulas (ψ χ : PlusFormula) : χ ∈ subformulas (.imp ψ χ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  exact Or.inr (Or.inr (self_mem_subformulas χ))

/-- Subformulas of a box include the inner formula. -/
theorem box_inner_mem_subformulas (ψ : PlusFormula) : ψ ∈ subformulas (.box ψ) := by
  simp only [subformulas, List.mem_cons]
  exact Or.inr (self_mem_subformulas ψ)

/-- Subformulas of an `untl` include the event. -/
theorem untl_left_mem_subformulas (ψ χ : PlusFormula) : ψ ∈ subformulas (.untl χ ψ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  exact Or.inr (Or.inl (self_mem_subformulas ψ))

/-- Subformulas of an `untl` include the guard. -/
theorem untl_right_mem_subformulas (ψ χ : PlusFormula) : χ ∈ subformulas (.untl χ ψ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  exact Or.inr (Or.inr (self_mem_subformulas χ))

/-- Subformulas of a `snce` include the event. -/
theorem snce_left_mem_subformulas (ψ χ : PlusFormula) : ψ ∈ subformulas (.snce χ ψ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  exact Or.inr (Or.inl (self_mem_subformulas ψ))

/-- Subformulas of a `snce` include the guard. -/
theorem snce_right_mem_subformulas (ψ χ : PlusFormula) : χ ∈ subformulas (.snce χ ψ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  exact Or.inr (Or.inr (self_mem_subformulas χ))

/-- **Subformulas of a stability modal include the inner formula.** The seventh arm, and the one
the base language has no analogue of. -/
theorem stab_inner_mem_subformulas (ψ : PlusFormula) : ψ ∈ subformulas (.stab ψ) := by
  simp only [subformulas, List.mem_cons]
  exact Or.inr (self_mem_subformulas ψ)

/--
Transitivity of the subformula relation.

If `chi` is a subformula of `psi`, and `psi` is a subformula of `phi`, then `chi` is a subformula
of `phi`. This is what turns the eight one-step membership lemmas into the eight closure
projections below.
-/
theorem subformulas_trans {chi psi phi : PlusFormula}
    (h1 : chi ∈ subformulas psi) (h2 : psi ∈ subformulas phi) :
    chi ∈ subformulas phi := by
  induction phi with
  | atom p =>
    simp only [subformulas, List.mem_singleton] at h2
    subst h2
    exact h1
  | bot =>
    simp only [subformulas, List.mem_singleton] at h2
    subst h2
    exact h1
  | imp a b iha ihb =>
    simp only [subformulas, List.mem_cons, List.mem_append] at h2
    rcases h2 with rfl | ha | hb
    · exact h1
    · simp only [subformulas, List.mem_cons, List.mem_append]
      exact Or.inr (Or.inl (iha ha))
    · simp only [subformulas, List.mem_cons, List.mem_append]
      exact Or.inr (Or.inr (ihb hb))
  | box a iha =>
    simp only [subformulas, List.mem_cons] at h2
    rcases h2 with rfl | h2
    · exact h1
    · simp only [subformulas, List.mem_cons]
      exact Or.inr (iha h2)
  | untl b a ihb iha =>
    simp only [subformulas, List.mem_cons, List.mem_append] at h2
    rcases h2 with rfl | ha | hb
    · exact h1
    · simp only [subformulas, List.mem_cons, List.mem_append]
      exact Or.inr (Or.inl (iha ha))
    · simp only [subformulas, List.mem_cons, List.mem_append]
      exact Or.inr (Or.inr (ihb hb))
  | snce b a ihb iha =>
    simp only [subformulas, List.mem_cons, List.mem_append] at h2
    rcases h2 with rfl | ha | hb
    · exact h1
    · simp only [subformulas, List.mem_cons, List.mem_append]
      exact Or.inr (Or.inl (iha ha))
    · simp only [subformulas, List.mem_cons, List.mem_append]
      exact Or.inr (Or.inr (ihb hb))
  | stab a iha =>
    simp only [subformulas, List.mem_cons] at h2
    rcases h2 with rfl | h2
    · exact h1
    · simp only [subformulas, List.mem_cons]
      exact Or.inr (iha h2)

end PlusFormula

/-!
## The subformula closure as a `Finset`

`List.toFinset` over `PlusFormula.subformulas`, mirroring `subformulaClosure`. `PlusFormula`
derives `DecidableEq`, so the conversion and every membership test compute — no `Classical`
anywhere on this path, which is what lets the L⁺ certificate's conditions stay decidable.
-/

/-- The subformula closure of an L⁺ formula, as a `Finset`. -/
def plusSubformulaClosure (φ : PlusFormula) : Finset PlusFormula :=
  (PlusFormula.subformulas φ).toFinset

/-- The formula itself is in its subformula closure. -/
theorem self_mem_plusSubformulaClosure (φ : PlusFormula) : φ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure
  simp only [List.mem_toFinset]
  exact PlusFormula.self_mem_subformulas φ

/-- Membership in a single formula's closure is decidable. -/
instance decidableMemPlusSubformulaClosure (φ : PlusFormula) :
    DecidablePred (· ∈ plusSubformulaClosure φ) :=
  fun ψ => Finset.decidableMem ψ (plusSubformulaClosure φ)

/-- Left component of an implication in the closure is in the closure. -/
theorem plusClosure_imp_left (φ ψ χ : PlusFormula)
    (h : PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ) : ψ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans (PlusFormula.imp_left_mem_subformulas ψ χ) h

/-- Right component of an implication in the closure is in the closure. -/
theorem plusClosure_imp_right (φ ψ χ : PlusFormula)
    (h : PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ) : χ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans (PlusFormula.imp_right_mem_subformulas ψ χ) h

/-- The inner formula of a boxed closure member is in the closure. -/
theorem plusClosure_box (φ ψ : PlusFormula)
    (h : PlusFormula.box ψ ∈ plusSubformulaClosure φ) : ψ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans (PlusFormula.box_inner_mem_subformulas ψ) h

/-- The event of an `untl` in the closure is in the closure. -/
theorem plusClosure_untl_left (φ ψ χ : PlusFormula)
    (h : PlusFormula.untl χ ψ ∈ plusSubformulaClosure φ) : ψ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans (PlusFormula.untl_left_mem_subformulas ψ χ) h

/-- The guard of an `untl` in the closure is in the closure. -/
theorem plusClosure_untl_right (φ ψ χ : PlusFormula)
    (h : PlusFormula.untl χ ψ ∈ plusSubformulaClosure φ) : χ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans (PlusFormula.untl_right_mem_subformulas ψ χ) h

/-- The event of a `snce` in the closure is in the closure. -/
theorem plusClosure_snce_left (φ ψ χ : PlusFormula)
    (h : PlusFormula.snce χ ψ ∈ plusSubformulaClosure φ) : ψ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans (PlusFormula.snce_left_mem_subformulas ψ χ) h

/-- The guard of a `snce` in the closure is in the closure. -/
theorem plusClosure_snce_right (φ ψ χ : PlusFormula)
    (h : PlusFormula.snce χ ψ ∈ plusSubformulaClosure φ) : χ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans (PlusFormula.snce_right_mem_subformulas ψ χ) h

/-- **The inner formula of a stability modal in the closure is in the closure.** The projection
the stability condition (C5) gates on: `⊡φ` in the target closure puts `φ` there too, which is
what lets the condition relate a `stab`-labelled index to `φ`-labelled ones. -/
theorem plusClosure_stab (φ ψ : PlusFormula)
    (h : PlusFormula.stab ψ ∈ plusSubformulaClosure φ) : ψ ∈ plusSubformulaClosure φ := by
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans (PlusFormula.stab_inner_mem_subformulas ψ) h

end FormalSystem.PlusLanguage

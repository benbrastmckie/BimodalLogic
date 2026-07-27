/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallFormula

/-!
# ∨∃∀-Formulas (Rabinovich Definition 3.3, PDF p.4) and disjunction closure

A `∨∃∀`-formula is a **disjunction of ∃∀-formulas** (Def 3.3, p.4). This module gives the
disjunctive object `VeeExistsForall` over the Phase-3 `ExistsForallFormula`, its satisfaction
`veeSat`, and the **disjunction-closure** half of Lemma 3.4 (p.5) — the part that is independent
of Lemma 3.2 and provable directly by list concatenation.

## Scope note (Phase 4 status)

Lemma 3.4 (p.5) states the set of ∨∃∀-formulas is closed under disjunction, conjunction, and
existential quantification, its proof invoking Lemma 3.2(1) and 3.2(3). Only the **disjunction**
closure is unconditional (append of disjunction lists); it is proved here sorry-free
(`veeSat_append`). The conjunction and ∃ closures, and Lemma 3.2(1)(2)(3) — in
particular the load-bearing **Lemma 3.2(2)** ≤2-free-variable cap — are the genuine hard content
of Phase 4 and are not yet proved.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 3.3 (p.4), Lemma 3.4 (p.5). Cited by
  PDF page; the companion markdown transcription is corrupt.
- `ExistsForallFormula.lean`: the Def 3.1 object and its `efSat` semantics.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

/-! ## 1. The ∨∃∀ disjunction object (Def 3.3, p.4) -/

/-- A ∨∃∀-formula: a finite disjunction of ∃∀-formulas over `sigE sig F` with `r` free
variables (Def 3.3, p.4). -/
abbrev VeeExistsForall (sig : MonadicSignature) (F : Finset Formula) (r : Nat) : Type :=
  List (ExistsForallFormula sig F r)

/-- Satisfaction of a ∨∃∀-formula: some disjunct ∃∀-formula is satisfied. -/
def veeSat {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ : VeeExistsForall sig F r) : Prop :=
  ∃ ψ ∈ Ψ, efSat N env ψ

/-- Embedding a single ∃∀-formula as a one-disjunct ∨∃∀-formula. -/
def VeeExistsForall.ofExistsForall {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (ψ : ExistsForallFormula sig F r) : VeeExistsForall sig F r := [ψ]

/-! ## 2. Basic satisfaction facts -/

/-- The empty disjunction is never satisfied (it is `False`). -/
@[simp] theorem veeSat_nil {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier) :
    ¬ veeSat N env ([] : VeeExistsForall sig F r) := by
  rintro ⟨ψ, hmem, _⟩
  exact (List.not_mem_nil hmem)

/-- A one-disjunct ∨∃∀-formula holds iff its single ∃∀-formula holds. -/
@[simp] theorem veeSat_singleton {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) :
    veeSat N env (VeeExistsForall.ofExistsForall ψ) ↔ efSat N env ψ := by
  simp only [veeSat, VeeExistsForall.ofExistsForall, List.mem_singleton]
  constructor
  · rintro ⟨φ, rfl, h⟩; exact h
  · intro h; exact ⟨ψ, rfl, h⟩

/-! ## 3. Closure under disjunction (Lemma 3.4, disjunction part — p.5) -/

/-- **Disjunction closure (Lemma 3.4, ∨-part).** The concatenation of two ∨∃∀-formulas is
satisfied iff one of them is: ∨∃∀-formulas are closed under disjunction. Proved directly by list
concatenation, independent of Lemma 3.2. -/
theorem veeSat_append {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (Ψ Φ : VeeExistsForall sig F r) :
    veeSat N env (Ψ ++ Φ) ↔ veeSat N env Ψ ∨ veeSat N env Φ := by
  simp only [veeSat, List.mem_append]
  constructor
  · rintro ⟨ψ, hmem, hsat⟩
    rcases hmem with h | h
    · exact Or.inl ⟨ψ, h, hsat⟩
    · exact Or.inr ⟨ψ, h, hsat⟩
  · rintro (⟨ψ, h, hsat⟩ | ⟨ψ, h, hsat⟩)
    · exact ⟨ψ, Or.inl h, hsat⟩
    · exact ⟨ψ, Or.inr h, hsat⟩

end Bimodal.Metalogic.WeakCanonical

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Enumerate
import FormalSystem.Metalogic.Decidability.BiLasso.TruthLemma

/-!
# The Type Sequence of a Genuine History

The small-model theorem extracts a bounded annotated bi-lasso from an arbitrary total history.
Whatever form the extraction takes, it needs one thing first: the *type sequence* of a genuine
history — the set of closure formulas true at each position — must satisfy the very conditions
an annotation is required to satisfy. That is what this module establishes.

## Where the conditions come from

- The **atom**, **`bot`** and **`imp`** clauses are immediate from `TruthAt`'s own clauses.
- The **box** clause is the box oracle's soundness, moved from time `0` to the position by
  `Semantics.Truth.box_const`.
- The two **temporal** clauses are exactly `truth_untl_succ` and `truth_snce_pred` from
  `BiLasso/Unfold.lean`. This is the point at which that module is consumed, and the reason it
  is a separate deliverable rather than an inlined step.
- **Fulfilment** is immediate, and that is the whole point of handoff §4.5's observation that
  fulfilment is supplied from outside and cheaply: a genuine history's eventualities are
  genuinely witnessed, because `TruthAt`'s `untl` clause *is* an existential witness. It is only
  when one tries to *construct* a structure that fulfilment becomes hard.

## Sequences, not annotations

`LocalCoherent` and `Fulfilling` are stated for an `Annot`, whose label sequence is periodic by
construction. A genuine history's type sequence is **not** periodic — the refutation in this
task's `evidence/phase3-scan-bound-is-false.lean` is precisely that formula truth along a
periodic path need not be periodic. So the conditions are restated here for an arbitrary pair of
sequences (`LocalCoherentSeq`, `FulfillingSeq`), with `localCoherent_iff_seq` /
`fulfilling_iff_seq` connecting them back to the annotation-level predicates.

## `typeAt` is deliberately noncomputable

`TruthAt`'s box clause quantifies over every total world history of the frame, so it is not
decidable, and `typeAt` filters by it through `Classical.decPred`. That is sound here because
`typeAt` appears **only inside proofs**: it is never reachable from `check`, whose own filters
are the computable instances of `BiLasso/Decide.lean`. No `open Classical` is used, and nothing
in this module is an instance that any decision procedure consults.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {P : IntPresentation} {φ : Formula} {bx : Formula → Bool}

/-! ## The conditions, restated for arbitrary sequences -/

/-- `LocalCoherent`, for an arbitrary label sequence over an arbitrary state sequence. -/
def LocalCoherentSeq (P : IntPresentation) (φ : Formula) (bx : Formula → Bool)
    (lab : ℤ → Finset Formula) (path : ℤ → Fin P.card) : Prop :=
  ∀ t : ℤ,
    (∀ p : Atom, Formula.atom p ∈ subformulaClosure φ →
        (Formula.atom p ∈ lab t ↔ P.val p (path t) = true)) ∧
    (Formula.bot ∉ lab t) ∧
    (∀ a b : Formula, Formula.imp a b ∈ subformulaClosure φ →
        (Formula.imp a b ∈ lab t ↔ (a ∈ lab t → b ∈ lab t))) ∧
    (∀ χ : Formula, Formula.box χ ∈ subformulaClosure φ →
        (Formula.box χ ∈ lab t ↔ bx χ = true)) ∧
    (∀ g e : Formula, Formula.untl g e ∈ subformulaClosure φ →
        (Formula.untl g e ∈ lab t ↔
          (e ∈ lab (t + 1) ∨ (g ∈ lab (t + 1) ∧ Formula.untl g e ∈ lab (t + 1))))) ∧
    (∀ g e : Formula, Formula.snce g e ∈ subformulaClosure φ →
        (Formula.snce g e ∈ lab t ↔
          (e ∈ lab (t - 1) ∨ (g ∈ lab (t - 1) ∧ Formula.snce g e ∈ lab (t - 1)))))

/-- `Fulfilling`, for an arbitrary label sequence. -/
def FulfillingSeq (lab : ℤ → Finset Formula) : Prop :=
  (∀ (t : ℤ) (g e : Formula), Formula.untl g e ∈ lab t →
      ∃ s : ℤ, t < s ∧ e ∈ lab s ∧ ∀ r : ℤ, t < r → r < s → g ∈ lab r) ∧
  (∀ (t : ℤ) (g e : Formula), Formula.snce g e ∈ lab t →
      ∃ s : ℤ, s < t ∧ e ∈ lab s ∧ ∀ r : ℤ, s < r → r < t → g ∈ lab r)

/-- The annotation-level predicate is the sequence-level one at the annotation's own sequences. -/
theorem localCoherent_iff_seq (A : Annot P φ) :
    LocalCoherent P φ bx A ↔ LocalCoherentSeq P φ bx A.label A.lasso.unroll := Iff.rfl

/-- The annotation-level predicate is the sequence-level one at the annotation's own labels. -/
theorem fulfilling_iff_seq (A : Annot P φ) :
    Fulfilling P φ A ↔ FulfillingSeq A.label := Iff.rfl

/-! ## The type sequence -/

/--
The **type** of a position: the closure formulas true there.

Noncomputable by necessity — `TruthAt`'s box clause quantifies over all total histories. See the
module docstring: this is a proof-only construction and never enters `check`.
-/
noncomputable def typeAt (P : IntPresentation) (φ : Formula)
    (τ : WorldHistory P.toTaskFrame) (u : ℤ) : Finset Formula :=
  @Finset.filter Formula (fun ψ => TruthAt P.toModel τ u ψ) (Classical.decPred _)
    (subformulaClosure φ)

theorem mem_typeAt {τ : WorldHistory P.toTaskFrame} {u : ℤ} {ψ : Formula} :
    ψ ∈ typeAt P φ τ u ↔ ψ ∈ subformulaClosure φ ∧ TruthAt P.toModel τ u ψ := by
  simp only [typeAt, Finset.mem_filter]

/-- A type is a set of closure formulas. -/
theorem typeAt_subset (τ : WorldHistory P.toTaskFrame) (u : ℤ) :
    typeAt P φ τ u ⊆ subformulaClosure φ := fun _ hx => (mem_typeAt.mp hx).1

/--
**The type sequence of a genuine history is locally coherent.**

Every clause is discharged from the semantics itself. The two temporal clauses are exactly the
ℤ one-step unfolding equations of `BiLasso/Unfold.lean`, transcribed through the closure filter;
the box clause is the oracle's soundness moved off time `0` by `box_const`.
-/
theorem typeAt_localCoherentSeq (hbx : BoxOracleSound P bx)
    (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) :
    LocalCoherentSeq P φ bx (typeAt P φ τ) (fun u => τ.states u (hτ u)) := by
  intro t
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- atom
    intro p hp
    rw [mem_typeAt]
    constructor
    · rintro ⟨_, ht, hval⟩
      exact hval
    · intro hval
      exact ⟨hp, hτ t, hval⟩
  · -- bot
    intro h
    exact Truth.bot_false (mem_typeAt.mp h).2
  · -- imp
    intro a b hab
    rw [mem_typeAt]
    constructor
    · rintro ⟨_, himp⟩ ha
      exact mem_typeAt.mpr ⟨closure_imp_right φ a b hab, himp (mem_typeAt.mp ha).2⟩
    · intro h
      refine ⟨hab, fun hatr => ?_⟩
      have := h (mem_typeAt.mpr ⟨closure_imp_left φ a b hab, hatr⟩)
      exact (mem_typeAt.mp this).2
  · -- box
    intro χ hχ
    rw [mem_typeAt, hbx χ]
    constructor
    · rintro ⟨_, hbox⟩
      exact (Truth.box_time_const P.toModel τ hτ t 0 χ).mp hbox
    · intro h
      exact ⟨hχ, (Truth.box_time_const P.toModel τ hτ 0 t χ).mp h⟩
  · -- untl: the exact one-step unfolding
    intro g e hge
    have hec : e ∈ subformulaClosure φ := closure_untl_left φ e g hge
    have hgc : g ∈ subformulaClosure φ := closure_untl_right φ e g hge
    rw [mem_typeAt]
    constructor
    · rintro ⟨_, htr⟩
      rcases (truth_untl_succ t g e).mp htr with h | ⟨h1, h2⟩
      · exact Or.inl (mem_typeAt.mpr ⟨hec, h⟩)
      · exact Or.inr ⟨mem_typeAt.mpr ⟨hgc, h1⟩, mem_typeAt.mpr ⟨hge, h2⟩⟩
    · intro h
      refine ⟨hge, (truth_untl_succ t g e).mpr ?_⟩
      rcases h with h | ⟨h1, h2⟩
      · exact Or.inl (mem_typeAt.mp h).2
      · exact Or.inr ⟨(mem_typeAt.mp h1).2, (mem_typeAt.mp h2).2⟩
  · -- snce: the leftward mirror
    intro g e hge
    have hec : e ∈ subformulaClosure φ := closure_snce_left φ e g hge
    have hgc : g ∈ subformulaClosure φ := closure_snce_right φ e g hge
    rw [mem_typeAt]
    constructor
    · rintro ⟨_, htr⟩
      rcases (truth_snce_pred t g e).mp htr with h | ⟨h1, h2⟩
      · exact Or.inl (mem_typeAt.mpr ⟨hec, h⟩)
      · exact Or.inr ⟨mem_typeAt.mpr ⟨hgc, h1⟩, mem_typeAt.mpr ⟨hge, h2⟩⟩
    · intro h
      refine ⟨hge, (truth_snce_pred t g e).mpr ?_⟩
      rcases h with h | ⟨h1, h2⟩
      · exact Or.inl (mem_typeAt.mp h).2
      · exact Or.inr ⟨(mem_typeAt.mp h1).2, (mem_typeAt.mp h2).2⟩

/--
**The type sequence of a genuine history is fulfilling.**

Immediate, and that is the substantive observation: `TruthAt`'s `untl` clause *is* an existential
witness, so a real model discharges its own eventualities by definition. Fulfilment is expensive
only when a structure has to be built; read off an existing model it is free. This is why the
truth lemma takes it as a hypothesis instead of establishing it.
-/
theorem typeAt_fulfillingSeq (τ : WorldHistory P.toTaskFrame) :
    FulfillingSeq (typeAt P φ τ) := by
  constructor
  · intro t g e hmem
    obtain ⟨hcl, htr⟩ := mem_typeAt.mp hmem
    have hec : e ∈ subformulaClosure φ := closure_untl_left φ e g hcl
    have hgc : g ∈ subformulaClosure φ := closure_untl_right φ e g hcl
    obtain ⟨s, hts, hes, hgs⟩ := htr
    exact ⟨s, hts, mem_typeAt.mpr ⟨hec, hes⟩,
      fun r hr1 hr2 => mem_typeAt.mpr ⟨hgc, hgs r hr1 hr2⟩⟩
  · intro t g e hmem
    obtain ⟨hcl, htr⟩ := mem_typeAt.mp hmem
    have hec : e ∈ subformulaClosure φ := closure_snce_left φ e g hcl
    have hgc : g ∈ subformulaClosure φ := closure_snce_right φ e g hcl
    obtain ⟨s, hst, hes, hgs⟩ := htr
    exact ⟨s, hst, mem_typeAt.mpr ⟨hec, hes⟩,
      fun r hr1 hr2 => mem_typeAt.mpr ⟨hgc, hgs r hr1 hr2⟩⟩

/--
The pigeonhole datum the extraction must range over: the state together with the type.

`Fin P.card × Finset Formula` is not itself finite as a type, but the second component is
confined to `(subformulaClosure φ).powerset`, which is a `Finset`, so the datum ranges over a
finite set of size `P.card · 2^(subformulaClosureCard φ)`.

**Pigeonholing on the state alone is not sufficient**, and the reason is now machine-checked
rather than plausible. This task's `evidence/phase3-scan-bound-is-false.lean` exhibits a
bi-lasso with `|back| = 1`, `|mid| = 0`, `|fwd| = 1` — the shortest loop a state-only pigeonhole
can close — which admits **no** consistent annotation at all for a closure containing `prev⁵ p`:
any annotation on it is forced to give that formula the same membership at every `t ≥ 0`, while
its truth set along the path is exactly `[5, ∞)`. Requiring the *type* to repeat is what forces
the extracted loop to be long enough for the formula at hand.
-/
noncomputable def pigeonDatum (P : IntPresentation) (φ : Formula)
    (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (u : ℤ) : Fin P.card × Finset Formula :=
  (τ.states u (hτ u), typeAt P φ τ u)

/-- The pigeonhole datum ranges over a finite set. -/
theorem pigeonDatum_mem (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (u : ℤ) :
    pigeonDatum P φ τ hτ u ∈
      (Finset.univ : Finset (Fin P.card)) ×ˢ (subformulaClosure φ).powerset := by
  simp only [pigeonDatum, Finset.mem_product, Finset.mem_powerset]
  exact ⟨Finset.mem_univ _, typeAt_subset τ u⟩

end FormalSystem.Metalogic.Decidability

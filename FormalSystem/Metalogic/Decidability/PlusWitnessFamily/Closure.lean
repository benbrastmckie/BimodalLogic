/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.Subformulas

/-!
# Set-Level Subformula Closure for L⁺

`plusSubformulaClosure` is single-formula only, but an L⁺ witness-family certificate is stated
about a *consequence* — a premise context `Γ` and a conclusion context `Δ` — so the closure the
labels must live inside is the closure of a whole `PlusContext`, not of one formula.

`plusClosureOf` is that set-level closure: the union of the single-formula closures of a
context's members. This is `WitnessFamily/Closure.lean` re-indexed at `PlusFormula`, with one
extra projection, `plusClosureOf_stab`, which is the projection the stability condition (C5)
gates on.

## Why not index by a single formula

`PlusWitnessFamily` could have been indexed by one `φ : PlusFormula`, with the consumer emitting
the conjunction of its premises and conclusions. Indexing by the context directly is preferred
here for the same reason it is on the `Formula` side: the certificate names `Γ` and `Δ`
separately, and folding them into one formula would force an unnatural field on the exporting
side for no proof-side benefit.

## It computes

The definition stays on `List` primitives — a `foldr` over the mapped list rather than a
`Finset.biUnion` — and `PlusFormula` derives `DecidableEq`, so every membership test reduces.
That is what keeps the L⁺ conditions decidable without `Classical` appearing on a decision path.

## Main Definitions

- `plusClosureOf` — the set-level subformula closure of a `PlusContext`

## Main Results

- `mem_plusClosureOf` — membership unfolds to "in some member's own closure"
- `self_mem_plusClosureOf` — every member of the context is in its closure
- the eight projections `plusClosureOf_imp_left`, `plusClosureOf_imp_right`, `plusClosureOf_box`,
  `plusClosureOf_untl_left`, `plusClosureOf_untl_right`, `plusClosureOf_snce_left`,
  `plusClosureOf_snce_right` and **`plusClosureOf_stab`**
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

/--
The set-level subformula closure of an L⁺ context: the union of its members' closures.

Defined by a `foldr` over the mapped list rather than by `Finset.biUnion` so that the definition
stays on `List` primitives, matching the rest of the certificate layer, which is built to
compute.
-/
def plusClosureOf (S : PlusContext) : Finset PlusFormula :=
  (List.map plusSubformulaClosure S).foldr (· ∪ ·) ∅

/--
Membership in `plusClosureOf S` is membership in some member's own subformula closure.

Proved by an explicit list induction: `simp` reduces the `foldr` but `tauto` cannot fold it back,
so the two directions are given separately.
-/
theorem mem_plusClosureOf {S : PlusContext} {ψ : PlusFormula} :
    ψ ∈ plusClosureOf S ↔ ∃ χ ∈ S, ψ ∈ plusSubformulaClosure χ := by
  induction S with
  | nil => simp [plusClosureOf]
  | cons a l ih =>
    constructor
    · intro h
      simp only [plusClosureOf, List.map_cons, List.foldr_cons, Finset.mem_union] at h
      rcases h with h | h
      · exact ⟨a, List.mem_cons_self, h⟩
      · obtain ⟨χ, hχ, hψ⟩ := ih.mp h
        exact ⟨χ, List.mem_cons_of_mem _ hχ, hψ⟩
    · rintro ⟨χ, hχ, hψ⟩
      simp only [plusClosureOf, List.map_cons, List.foldr_cons, Finset.mem_union]
      rcases List.mem_cons.mp hχ with rfl | hχ'
      · exact Or.inl hψ
      · exact Or.inr (ih.mpr ⟨χ, hχ', hψ⟩)

/-- Every member of the context lies in the context's closure. -/
theorem self_mem_plusClosureOf {S : PlusContext} {χ : PlusFormula} (hχ : χ ∈ S) :
    χ ∈ plusClosureOf S :=
  mem_plusClosureOf.mpr ⟨χ, hχ, self_mem_plusSubformulaClosure χ⟩

/-- Left component of an implication in the closure is in the closure. -/
theorem plusClosureOf_imp_left {S : PlusContext} {a b : PlusFormula}
    (h : PlusFormula.imp a b ∈ plusClosureOf S) : a ∈ plusClosureOf S := by
  obtain ⟨χ, hχ, hab⟩ := mem_plusClosureOf.mp h
  exact mem_plusClosureOf.mpr ⟨χ, hχ, plusClosure_imp_left χ a b hab⟩

/-- Right component of an implication in the closure is in the closure. -/
theorem plusClosureOf_imp_right {S : PlusContext} {a b : PlusFormula}
    (h : PlusFormula.imp a b ∈ plusClosureOf S) : b ∈ plusClosureOf S := by
  obtain ⟨χ, hχ, hab⟩ := mem_plusClosureOf.mp h
  exact mem_plusClosureOf.mpr ⟨χ, hχ, plusClosure_imp_right χ a b hab⟩

/-- The inner formula of a boxed closure member is in the closure. -/
theorem plusClosureOf_box {S : PlusContext} {a : PlusFormula}
    (h : PlusFormula.box a ∈ plusClosureOf S) : a ∈ plusClosureOf S := by
  obtain ⟨χ, hχ, ha⟩ := mem_plusClosureOf.mp h
  exact mem_plusClosureOf.mpr ⟨χ, hχ, plusClosure_box χ a ha⟩

/-- The event of an `untl` in the closure is in the closure. -/
theorem plusClosureOf_untl_left {S : PlusContext} {g e : PlusFormula}
    (h : PlusFormula.untl g e ∈ plusClosureOf S) : e ∈ plusClosureOf S := by
  obtain ⟨χ, hχ, hge⟩ := mem_plusClosureOf.mp h
  exact mem_plusClosureOf.mpr ⟨χ, hχ, plusClosure_untl_left χ e g hge⟩

/-- The guard of an `untl` in the closure is in the closure. -/
theorem plusClosureOf_untl_right {S : PlusContext} {g e : PlusFormula}
    (h : PlusFormula.untl g e ∈ plusClosureOf S) : g ∈ plusClosureOf S := by
  obtain ⟨χ, hχ, hge⟩ := mem_plusClosureOf.mp h
  exact mem_plusClosureOf.mpr ⟨χ, hχ, plusClosure_untl_right χ e g hge⟩

/-- The event of a `snce` in the closure is in the closure. -/
theorem plusClosureOf_snce_left {S : PlusContext} {g e : PlusFormula}
    (h : PlusFormula.snce g e ∈ plusClosureOf S) : e ∈ plusClosureOf S := by
  obtain ⟨χ, hχ, hge⟩ := mem_plusClosureOf.mp h
  exact mem_plusClosureOf.mpr ⟨χ, hχ, plusClosure_snce_left χ e g hge⟩

/-- The guard of a `snce` in the closure is in the closure. -/
theorem plusClosureOf_snce_right {S : PlusContext} {g e : PlusFormula}
    (h : PlusFormula.snce g e ∈ plusClosureOf S) : g ∈ plusClosureOf S := by
  obtain ⟨χ, hχ, hge⟩ := mem_plusClosureOf.mp h
  exact mem_plusClosureOf.mpr ⟨χ, hχ, plusClosure_snce_right χ e g hge⟩

/--
**The inner formula of a stability modal in the closure is in the closure.**

The eighth projection, and the one the `Formula`-side closure has no analogue of. The stability
condition (C5) is gated on `stab φ ∈ plusClosureOf (Γ ++ Δ)` and relates it to `φ` being
labelled elsewhere; this is what puts `φ` inside the target closure so that the relation is
between two labels of the certificate rather than between a label and something outside it.
-/
theorem plusClosureOf_stab {S : PlusContext} {a : PlusFormula}
    (h : PlusFormula.stab a ∈ plusClosureOf S) : a ∈ plusClosureOf S := by
  obtain ⟨χ, hχ, ha⟩ := mem_plusClosureOf.mp h
  exact mem_plusClosureOf.mpr ⟨χ, hχ, plusClosure_stab χ a ha⟩

/-- Membership in a set-level closure is decidable, so certificate predicates can compute. -/
instance decidableMemPlusClosureOf (S : PlusContext) : DecidablePred (· ∈ plusClosureOf S) :=
  fun ψ => Finset.decidableMem ψ (plusClosureOf S)

/-- Every premise of `Γ` lies in the target closure of `Γ ++ Δ`. -/
theorem plusPremise_mem_closure {Γ Δ : PlusContext} {γ : PlusFormula} (hγ : γ ∈ Γ) :
    γ ∈ plusClosureOf (Γ ++ Δ) :=
  self_mem_plusClosureOf (List.mem_append_left Δ hγ)

/-- Every conclusion of `Δ` lies in the target closure of `Γ ++ Δ`. -/
theorem plusConclusion_mem_closure {Γ Δ : PlusContext} {σ : PlusFormula} (hσ : σ ∈ Δ) :
    σ ∈ plusClosureOf (Γ ++ Δ) :=
  self_mem_plusClosureOf (List.mem_append_right Γ hσ)

end FormalSystem.Metalogic.Decidability

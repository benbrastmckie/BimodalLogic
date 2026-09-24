/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.SubformulaClosure.Closure
import FormalSystem.Syntax.Context

/-!
# Set-Level Subformula Closure

`subformulaClosure` is single-formula only, but a witness-family certificate is stated about a
*consequence* — a premise context `Γ` and a conclusion context `Δ` — so the closure the labels
must live inside is the closure of a whole `Context`, not of one formula.

`closureOf` is that set-level closure: the union of the single-formula closures of a context's
members. Every projection `subformulaClosure` supplies (`closure_imp_left`, `closure_box`, …)
is mirrored here in three lines, because membership in `closureOf S` factors through membership
in some member's own closure (`mem_closureOf`) and the single-formula projection then applies
inside that member.

## Why not index by a single formula

`Annot P φ` indexes by one `φ : Formula` and a family could have done the same, with the
consumer emitting the conjunction of its premises and conclusions. That was the shape the
research spike used. Indexing by the context directly is preferred here because the certificate's
JSON export names `Γ` and `Δ` separately, and folding them into one formula would force an
unnatural field on the exporting side for no proof-side benefit.

## Main Definitions

- `closureOf` — the set-level subformula closure of a `Context`

## Main Results

- `mem_closureOf` — membership unfolds to "in some member's own closure"
- `self_mem_closureOf` — every member of the context is in its closure
- the six projections `closureOf_imp_left`, `closureOf_imp_right`, `closureOf_box`,
  `closureOf_untl_left`, `closureOf_untl_right`, `closureOf_snce_left`, `closureOf_snce_right`
-/

namespace FormalSystem.Metalogic.Decidability.WitnessFamily

open FormalSystem.Syntax

/--
The set-level subformula closure of a context: the union of its members' closures.

Defined by a `foldr` over the mapped list rather than by `Finset.biUnion` so that the definition
stays on `List` primitives, matching the rest of the certificate layer, which is built to
compute.
-/
def closureOf (S : Context) : Finset Formula :=
  (List.map subformulaClosure S).foldr (· ∪ ·) ∅

/--
Membership in `closureOf S` is membership in some member's own subformula closure.

Proved by an explicit list induction: `simp` reduces the `foldr` but `tauto` cannot fold it back,
so the two directions are given separately.
-/
theorem mem_closureOf {S : Context} {ψ : Formula} :
    ψ ∈ closureOf S ↔ ∃ χ ∈ S, ψ ∈ subformulaClosure χ := by
  induction S with
  | nil => simp [closureOf]
  | cons a l ih =>
    constructor
    · intro h
      simp only [closureOf, List.map_cons, List.foldr_cons, Finset.mem_union] at h
      rcases h with h | h
      · exact ⟨a, List.mem_cons_self, h⟩
      · obtain ⟨χ, hχ, hψ⟩ := ih.mp h
        exact ⟨χ, List.mem_cons_of_mem _ hχ, hψ⟩
    · rintro ⟨χ, hχ, hψ⟩
      simp only [closureOf, List.map_cons, List.foldr_cons, Finset.mem_union]
      rcases List.mem_cons.mp hχ with rfl | hχ'
      · exact Or.inl hψ
      · exact Or.inr (ih.mpr ⟨χ, hχ', hψ⟩)

/-- Every member of the context lies in the context's closure. -/
theorem self_mem_closureOf {S : Context} {χ : Formula} (hχ : χ ∈ S) : χ ∈ closureOf S :=
  mem_closureOf.mpr ⟨χ, hχ, self_mem_subformulaClosure χ⟩

/-- Left component of an implication in the closure is in the closure. -/
theorem closureOf_imp_left {S : Context} {a b : Formula}
    (h : Formula.imp a b ∈ closureOf S) : a ∈ closureOf S := by
  obtain ⟨χ, hχ, hab⟩ := mem_closureOf.mp h
  exact mem_closureOf.mpr ⟨χ, hχ, closure_imp_left χ a b hab⟩

/-- Right component of an implication in the closure is in the closure. -/
theorem closureOf_imp_right {S : Context} {a b : Formula}
    (h : Formula.imp a b ∈ closureOf S) : b ∈ closureOf S := by
  obtain ⟨χ, hχ, hab⟩ := mem_closureOf.mp h
  exact mem_closureOf.mpr ⟨χ, hχ, closure_imp_right χ a b hab⟩

/-- The inner formula of a boxed closure member is in the closure. -/
theorem closureOf_box {S : Context} {a : Formula}
    (h : Formula.box a ∈ closureOf S) : a ∈ closureOf S := by
  obtain ⟨χ, hχ, ha⟩ := mem_closureOf.mp h
  exact mem_closureOf.mpr ⟨χ, hχ, closure_box χ a ha⟩

/-- The event of an `untl` in the closure is in the closure. -/
theorem closureOf_untl_left {S : Context} {g e : Formula}
    (h : Formula.untl g e ∈ closureOf S) : e ∈ closureOf S := by
  obtain ⟨χ, hχ, hge⟩ := mem_closureOf.mp h
  exact mem_closureOf.mpr ⟨χ, hχ, closure_untl_left χ e g hge⟩

/-- The guard of an `untl` in the closure is in the closure. -/
theorem closureOf_untl_right {S : Context} {g e : Formula}
    (h : Formula.untl g e ∈ closureOf S) : g ∈ closureOf S := by
  obtain ⟨χ, hχ, hge⟩ := mem_closureOf.mp h
  exact mem_closureOf.mpr ⟨χ, hχ, closure_untl_right χ e g hge⟩

/-- The event of a `snce` in the closure is in the closure. -/
theorem closureOf_snce_left {S : Context} {g e : Formula}
    (h : Formula.snce g e ∈ closureOf S) : e ∈ closureOf S := by
  obtain ⟨χ, hχ, hge⟩ := mem_closureOf.mp h
  exact mem_closureOf.mpr ⟨χ, hχ, closure_snce_left χ e g hge⟩

/-- The guard of a `snce` in the closure is in the closure. -/
theorem closureOf_snce_right {S : Context} {g e : Formula}
    (h : Formula.snce g e ∈ closureOf S) : g ∈ closureOf S := by
  obtain ⟨χ, hχ, hge⟩ := mem_closureOf.mp h
  exact mem_closureOf.mpr ⟨χ, hχ, closure_snce_right χ e g hge⟩

/-- Membership in a set-level closure is decidable, so certificate predicates can compute. -/
instance decidableMemClosureOf (S : Context) : DecidablePred (· ∈ closureOf S) :=
  fun ψ => Finset.decidableMem ψ (closureOf S)

end FormalSystem.Metalogic.Decidability.WitnessFamily

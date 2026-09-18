/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Order.PrimeIdeal
import Mathlib.Order.PrimeSeparator

/-!
# Proper, maximal and prime filters, dual to `Order/Ideal.lean` and `Order/PrimeIdeal.lean`

Mathlib supplies `Order.PFilter` (`Order/PFilter.lean`) and `Order.PFilter.IsPrime`
(`Order/PrimeIdeal.lean`), but the proper/maximal API and the Boolean-algebra section that
`Order.Ideal` enjoys have no filter-side counterparts. This file supplies them, one-for-one with
their ideal duals, in namespace `Order.PFilter` — exactly Mathlib's — so that upstreaming this
file deletes it and renames nothing downstream.

## Main definitions

* `Order.PFilter.IsProper` — a filter is proper if it is not the whole set
  (dual of `Order.Ideal.IsProper`).
* `Order.PFilter.IsMaximal` — a filter is maximal if it is maximal among proper filters
  (dual of `Order.Ideal.IsMaximal`).
* `Order.PrimeFilter P` — prime filters, bundled as `{F : PFilter P // F.IsPrime}`. On a Boolean
  algebra these are precisely the ultrafilters.

## Main results

* `Order.PFilter.IsPrime.toIsProper` — `IsPrime` already implies `IsProper` (the field
  `compl_ideal` bundles `IsIdeal.Nonempty`), so `IsProper` is a consequence, not a prerequisite.
* `Order.PFilter.IsProper.exists_le_maximal` — every proper filter extends to a maximal one
  (dual transport of `Order.Ideal.IsProper.exists_le_maximal`).
* `Order.PFilter.IsMaximal.isPrime` — on a distributive lattice, maximal filters are prime.
* `Order.PFilter.IsProper.exists_le_prime` — on a Boolean algebra, every proper filter extends
  to a prime (= ultra) filter.
* `Order.PFilter.isPrime_iff_mem_or_compl_mem` and the `IsPrime.mem_or_compl_mem` /
  `compl_mem_iff_notMem` / `mem_iff_compl_notMem` family — the Boolean-algebra characterisation.
* `DistribLattice.prime_filter_of_disjoint_filter_ideal` — the Zorn-free prime-filter separator,
  the filter-side corollary of `DistribLattice.prime_ideal_of_disjoint_filter_ideal` that
  `Mathlib/Order/PrimeSeparator.lean` leaves as a commented-out TODO for want of a prime-filter
  vocabulary; stated with exactly that TODO's name and shape.

## Two dualities

The order dual is free: `mem_dual_iff`, `le_iff_dual_le`, `lt_iff_dual_lt`, `coe_eq_univ_iff`
are all `Iff.rfl`, and every `*_iff_dual` transport below is a definitional repackaging. The
Boolean complement, by contrast, is a genuinely different duality; it is what the direct
`BooleanAlgebra` section proves with, and it is deliberately not used to encode filters as ideals.

## Dependency rule

**Nothing under `FormalSystem/ForMathlib/` imports `FormalSystem.*`.** The import direction is
strictly `Mathlib → ForMathlib → FormalSystem.Metalogic.Algebraic.UltrafilterMCS → downstream`.
This file mentions no formulas, derivations or Lindenbaum algebras; it is about arbitrary
preorders, distributive lattices and Boolean algebras only.

## A seen-and-accepted trade-off

`Order.PrimeFilter` is an `abbrev` for a subtype rather than a `structure` following Mathlib's
`SetLike` bundled-subobject template (`Data/SetLike/Basic.lean`; compare `PrimeSpectrum`, which is
a `structure` with `equivSubtype` as a bridge *to* the subtype). For a project-local type the
subtype costs no boilerplate and every downstream statement reads as `x ∈ U`, `PFilter.inf_mem`,
`U.2.mem_or_compl_mem`. It is the one place a Mathlib reviewer would predictably ask for the
`structure` form on upstreaming; the generic `Order.PFilter` half of this file is unaffected
either way.
-/

open OrderDual

namespace Order.PFilter

variable {P : Type*}

section Preorder
variable [Preorder P] {F G : PFilter P} {x : P}

theorem mem_dual_iff : toDual x ∈ F.dual ↔ x ∈ F := Iff.rfl
theorem le_iff_dual_le : F ≤ G ↔ F.dual ≤ G.dual := Iff.rfl
theorem lt_iff_dual_lt : F < G ↔ F.dual < G.dual := Iff.rfl
theorem coe_eq_univ_iff : (F : Set P) = Set.univ ↔ (F.dual : Set Pᵒᵈ) = Set.univ := Iff.rfl

/-- A filter is proper if it is not the whole set. Dual of `Order.Ideal.IsProper`. -/
@[mk_iff]
class IsProper (F : PFilter P) : Prop where
  ne_univ : (F : Set P) ≠ Set.univ

-- Ideal.isProper_of_notMem
theorem isProper_of_notMem {p : P} (notMem : p ∉ F) : IsProper F :=
  ⟨fun hp ↦ by
    have := Set.mem_univ p
    rw [← hp] at this
    exact notMem this⟩

theorem IsProper.exists_notMem (hF : IsProper F) : ∃ p, p ∉ F :=
  Set.ne_univ_iff_exists_notMem _ |>.1 hF.ne_univ

theorem isProper_iff_dual : F.IsProper ↔ F.dual.IsProper :=
  ⟨fun h => ⟨h.ne_univ⟩, fun h => ⟨h.ne_univ⟩⟩

/-- A filter is maximal if it is maximal among proper filters. Dual of `Order.Ideal.IsMaximal`. -/
@[mk_iff]
class IsMaximal (F : PFilter P) : Prop extends IsProper F where
  maximal_proper : ∀ ⦃G : PFilter P⦄, F < G → (G : Set P) = Set.univ

theorem isMaximal_iff_dual : F.IsMaximal ↔ F.dual.IsMaximal := by
  constructor
  · intro h
    exact { ne_univ := h.ne_univ, maximal_proper := fun J hJ => h.maximal_proper (G := ⟨J⟩) hJ }
  · intro h
    exact { ne_univ := h.ne_univ, maximal_proper := fun G hG => h.maximal_proper (J := G.dual) hG }

/-- `IsPrime` already implies `IsProper`: the complement is a (nonempty) ideal. -/
-- Ideal.IsPrime.toIsProper (there: a field)
instance (priority := 100) IsPrime.toIsProper [h : IsPrime F] : IsProper F :=
  let ⟨_, hp⟩ := h.compl_ideal.Nonempty
  isProper_of_notMem hp

theorem isPrime_iff_dual : F.IsPrime ↔ F.dual.IsPrime := by
  constructor
  · intro h
    exact { ne_univ := h.toIsProper.ne_univ, compl_filter := h.compl_ideal }
  · intro h
    exact ⟨h.compl_filter⟩

end Preorder

section OrderBot
variable [Preorder P] [OrderBot P] {F : PFilter P}

-- Ideal.IsProper.top_notMem
theorem IsProper.bot_notMem (hF : IsProper F) : ⊥ ∉ F := fun h =>
  hF.ne_univ (Set.eq_univ_iff_forall.2 fun _ => mem_of_le bot_le h)

-- Ideal.isProper_iff_top_notMem
theorem isProper_iff_bot_notMem : IsProper F ↔ ⊥ ∉ F :=
  ⟨IsProper.bot_notMem, isProper_of_notMem⟩

-- Ideal.IsProper.exists_le_maximal
theorem IsProper.exists_le_maximal (hF : F.IsProper) : ∃ G, F ≤ G ∧ G.IsMaximal := by
  obtain ⟨J, hJ, hJm⟩ := (isProper_iff_dual.1 hF).exists_le_maximal
  exact ⟨⟨J⟩, hJ, isMaximal_iff_dual.2 hJm⟩

end OrderBot

section DistribLattice
variable [DistribLattice P] {F : PFilter P}

-- Ideal.IsMaximal.isPrime
instance (priority := 100) IsMaximal.isPrime [hF : IsMaximal F] : IsPrime F :=
  isPrime_iff_dual.2 (@Ideal.IsMaximal.isPrime Pᵒᵈ _ F.dual (isMaximal_iff_dual.1 hF))

end DistribLattice

section BooleanAlgebra
variable [BooleanAlgebra P] {F : PFilter P} {x y : P}

-- Ideal.IsProper.notMem_of_compl_mem
theorem IsProper.notMem_of_compl_mem (hF : IsProper F) (hxc : xᶜ ∈ F) : x ∉ F := fun hx =>
  hF.bot_notMem (by simpa using inf_mem hx hxc)

-- Ideal.IsProper.notMem_or_compl_notMem
theorem IsProper.notMem_or_compl_notMem (hF : IsProper F) : x ∉ F ∨ xᶜ ∉ F := by
  by_cases hx : x ∈ F
  · exact Or.inr fun hxc => hF.notMem_of_compl_mem hxc hx
  · exact Or.inl hx

-- Ideal.IsPrime.mem_or_compl_mem
theorem IsPrime.mem_or_compl_mem (hF : IsPrime F) : x ∈ F ∨ xᶜ ∈ F := by
  by_contra h
  push Not at h
  have : x ⊔ xᶜ ∈ hF.compl_ideal.toIdeal :=
    Ideal.sup_mem ((Ideal.mem_toIdeal _).2 h.1) ((Ideal.mem_toIdeal _).2 h.2)
  rw [Ideal.mem_toIdeal, sup_compl_eq_top] at this
  exact this top_mem

-- Ideal.IsPrime.compl_mem_of_notMem
theorem IsPrime.compl_mem_of_notMem (hF : IsPrime F) (hx : x ∉ F) : xᶜ ∈ F :=
  hF.mem_or_compl_mem.resolve_left hx

theorem IsPrime.compl_notMem_of_mem (hF : IsPrime F) (hx : x ∈ F) : xᶜ ∉ F :=
  fun hxc => hF.toIsProper.notMem_of_compl_mem hxc hx

theorem IsPrime.mem_iff_compl_notMem (hF : IsPrime F) : x ∈ F ↔ xᶜ ∉ F :=
  ⟨hF.compl_notMem_of_mem, fun h => hF.mem_or_compl_mem.resolve_right h⟩

theorem IsPrime.compl_mem_iff_notMem (hF : IsPrime F) : xᶜ ∈ F ↔ x ∉ F :=
  ⟨fun h hx => hF.compl_notMem_of_mem hx h, hF.compl_mem_of_notMem⟩

-- Ideal.isPrime_of_mem_or_compl_mem
theorem isPrime_of_mem_or_compl_mem [hF : IsProper F] (h : ∀ {x : P}, x ∈ F ∨ xᶜ ∈ F) :
    IsPrime F where
  compl_ideal :=
    { IsLowerSet := fun a b hab ha hb => ha (mem_of_le hab hb)
      Nonempty := ⟨⊥, hF.bot_notMem⟩
      Directed := fun a ha b hb =>
        ⟨a ⊔ b, fun hab => hF.notMem_of_compl_mem
            (by simpa [compl_sup] using inf_mem (h.resolve_left ha) (h.resolve_left hb)) hab,
          le_sup_left, le_sup_right⟩ }

-- Ideal.isPrime_iff_mem_or_compl_mem
theorem isPrime_iff_mem_or_compl_mem [IsProper F] : IsPrime F ↔ ∀ {x : P}, x ∈ F ∨ xᶜ ∈ F :=
  ⟨fun h _ => h.mem_or_compl_mem, isPrime_of_mem_or_compl_mem⟩

-- Ideal.IsPrime.isMaximal
instance (priority := 100) IsPrime.isMaximal [hF : IsPrime F] : IsMaximal F where
  ne_univ := hF.toIsProper.ne_univ
  maximal_proper := by
    intro G hFG
    obtain ⟨y, hyG, hyF⟩ := Set.exists_of_ssubset hFG
    refine Set.eq_univ_iff_forall.2 fun x => ?_
    have hyc : yᶜ ∈ G := hFG.le (hF.compl_mem_of_notMem hyF)
    have : y ⊓ yᶜ ∈ G := inf_mem hyG hyc
    rw [inf_compl_eq_bot] at this
    exact mem_of_le bot_le this

/-- Every proper filter of a Boolean algebra extends to a prime (= ultra) filter. -/
theorem IsProper.exists_le_prime (hF : F.IsProper) : ∃ G, F ≤ G ∧ G.IsPrime :=
  let ⟨G, hG, hGm⟩ := hF.exists_le_maximal
  ⟨G, hG, @IsMaximal.isPrime _ _ G hGm⟩

end BooleanAlgebra

end Order.PFilter

section PrimeSeparator
open Order
variable {α : Type*}

/-- The prime-filter separator: a filter disjoint from an ideal extends to a prime filter still
disjoint from it. Dual transport of `DistribLattice.prime_ideal_of_disjoint_filter_ideal`; this is
the corollary `Mathlib/Order/PrimeSeparator.lean` states in a comment as a TODO. -/
theorem DistribLattice.prime_filter_of_disjoint_filter_ideal [DistribLattice α]
    {F : PFilter α} {I : Ideal α} (hFI : Disjoint (F : Set α) (I : Set α)) :
    ∃ G : PFilter α, G.IsPrime ∧ F ≤ G ∧ Disjoint (G : Set α) I := by
  have h : Disjoint ((⟨I⟩ : PFilter αᵒᵈ) : Set αᵒᵈ) (F.dual : Set αᵒᵈ) := hFI.symm
  obtain ⟨J, hJ, hFJ, hJI⟩ := DistribLattice.prime_ideal_of_disjoint_filter_ideal h
  exact ⟨⟨J⟩, PFilter.isPrime_iff_dual.2 hJ, hFJ, hJI.symm⟩

end PrimeSeparator

namespace Order

section Preorder
variable {P : Type*} [Preorder P]

/-- Prime filters, bundled. On a Boolean algebra these are precisely the ultrafilters. -/
abbrev PrimeFilter (P : Type*) [Preorder P] := {F : PFilter P // F.IsPrime}

instance : SetLike (PrimeFilter P) P where
  coe U := U.1
  coe_injective := fun _ _ h => Subtype.ext (SetLike.coe_injective h)

instance (U : PrimeFilter P) : U.1.IsPrime := U.2

theorem PrimeFilter.mem_iff {U : PrimeFilter P} {x : P} : x ∈ U ↔ x ∈ U.1 := Iff.rfl

@[ext] theorem PrimeFilter.ext {U V : PrimeFilter P} (h : ∀ x, x ∈ U ↔ x ∈ V) : U = V :=
  SetLike.ext h

end Preorder

end Order

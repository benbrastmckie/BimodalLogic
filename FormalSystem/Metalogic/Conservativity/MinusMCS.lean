/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.MinusTemporalDerived
import Mathlib.Order.Zorn

/-!
# Maximal consistent sets over L⁻

The `MinusFormula`-typed mirror of `Metalogic/Core/MaximalConsistent.lean` (consistency,
set-consistency, the Zorn/Lindenbaum step) and of the closure properties of
`Metalogic/Core/MCSProperties.lean` (deductive closure, negation completeness, the membership
characterisations of `→`, `∧`, `¬¬`, `F`, `P`, `◇`). Every declaration here is stated over
`MinusFormula` and `MinusLanguage.DerivationTree`; nothing is imported from the `Formula`-typed
canonical models, which — as `Conservativity/TMCompletenessReduction.lean` records — cannot be
borrowed without assuming the very conservativity statement the L⁻ canonical model is built to
prove.

## Why a second MCS layer

`Core.SetMaximalConsistent` is pinned to `Set Formula` by its binder alone; the Zorn argument is
carrier-agnostic. The generic step is therefore stated once here, polymorphically
(`exists_maximal_of_chainClosed`), and the L⁻ Lindenbaum lemma `minus_set_lindenbaum` is its
instance at `MinusSetConsistent fc`. The closure properties ride on the L⁻ deduction theorem
`minusDeductionTheorem` (`Conservativity/MinusDeduction.lean`), exactly as the `Core` versions
ride on `Theorems/DeductionTheorem.lean`; the one propositional derivation they need beyond that
module (`negImpImp`) is taken from `Conservativity/MinusTemporalDerived.lean`.

## Main Definitions

- `MinusConsistent`, `MinusSetConsistent`, `MinusSetMaximalConsistent` — the three consistency
  predicates over L⁻, at a frame class `fc`
- `MPoint fc` — the subtype of maximal `fc`-consistent sets, the carrier every canonical
  construction downstream works on

## Main Results

- `minus_set_lindenbaum` — every consistent set extends to a maximal consistent one
- `neg_consistent_of_not_minus_derivable` — `¬ ⊢⁻[fc] φ` makes `{¬φ}` consistent
- `MinusSetMaximalConsistent.closed_under_derivation`, `.mem_or_neg_mem`, `.imp_mem_iff`,
  `.and_mem_iff`, `.or_mem_iff`, `.neg_neg_mem_iff`, `.someFuture_mem_iff`,
  `.somePast_mem_iff`, `.diamond_mem_iff` — the closure and duality facts the truth lemma reads

## References

* `FormalSystem/Metalogic/Core/MaximalConsistent.lean`,
  `FormalSystem/Metalogic/Core/MCSProperties.lean` — the L-side copy sources
* `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` — the deduction theorem used
  throughout
* Burgess, *Basic Tense Logic* (1984), §2.5 — the canonical-model route these sets feed

## Tags

conservativity · base-language · maximal-consistent · lindenbaum
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.MinusLanguage

/-! ## Consistency predicates -/

/-- Mirror of `Core.Consistent` over L⁻: the context does not derive `⊥` at `fc`. -/
def MinusConsistent (fc : FrameClass) (Γ : Context) : Prop :=
  ¬ Derivable fc Γ MinusFormula.bot

/-- Mirror of `Core.SetConsistent`: every finite list drawn from `S` is consistent. -/
def MinusSetConsistent (fc : FrameClass) (S : Set MinusFormula) : Prop :=
  ∀ L : Context, (∀ φ ∈ L, φ ∈ S) → MinusConsistent fc L

/-- Mirror of `Core.SetMaximalConsistent`: consistent, and no proper extension is. -/
def MinusSetMaximalConsistent (fc : FrameClass) (S : Set MinusFormula) : Prop :=
  MinusSetConsistent fc S ∧ ∀ φ : MinusFormula, φ ∉ S → ¬ MinusSetConsistent fc (insert φ S)

/-- The carrier of the L⁻ canonical constructions: maximal `fc`-consistent sets. -/
def MPoint (fc : FrameClass) : Type :=
  {S : Set MinusFormula // MinusSetMaximalConsistent fc S}

/-! ## Zorn and Lindenbaum -/

/-- `Core.exists_maximal_of_chainClosed`, stated for an arbitrary carrier: the L side's copy is
pinned to `Set Formula` only by its binder, and the proof is unchanged. -/
theorem exists_maximal_of_chainClosed {α : Type} {P : Set α → Prop}
    (hchain : ∀ C : Set (Set α), (∀ T ∈ C, P T) → IsChain (· ⊆ ·) C → C.Nonempty → P (⋃₀ C))
    {S : Set α} (hS : P S) :
    ∃ M : Set α, S ⊆ M ∧ P M ∧ ∀ ψ : α, ψ ∉ M → ¬ P (insert ψ M) := by
  let CS : Set (Set α) := {T | S ⊆ T ∧ P T}
  have hch : ∀ C ⊆ CS, IsChain (· ⊆ ·) C → C.Nonempty → ∃ ub ∈ CS, ∀ T ∈ C, T ⊆ ub := by
    intro C hCsub hCchain hCne
    refine ⟨⋃₀ C, ⟨?_, ?_⟩, fun T hT => Set.subset_sUnion_of_mem hT⟩
    · obtain ⟨T, hT⟩ := hCne
      exact Set.Subset.trans (hCsub hT).1 (Set.subset_sUnion_of_mem hT)
    · exact hchain C (fun T hT => (hCsub hT).2) hCchain hCne
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty CS hch S ⟨Set.Subset.refl S, hS⟩
  refine ⟨M, hSM, hmax.prop.2, ?_⟩
  intro ψ hψ hP
  exact hψ (hmax.le_of_ge ⟨Set.Subset.trans hSM (Set.subset_insert ψ M), hP⟩
    (Set.subset_insert ψ M) (Set.mem_insert ψ M))

/-- Mirror of `Core.finite_list_in_chain_member`, generic carrier: a finite list drawn from the
union of a chain is drawn from one member. -/
theorem finite_list_in_chain_member {α : Type} {C : Set (Set α)}
    (hchain : IsChain (· ⊆ ·) C) (L : List α) (hL : ∀ φ ∈ L, φ ∈ ⋃₀ C) :
    C.Nonempty → ∃ S ∈ C, ∀ φ ∈ L, φ ∈ S := by
  intro hCne
  induction L with
  | nil =>
    obtain ⟨S, hS⟩ := hCne
    exact ⟨S, hS, fun _ h => (List.not_mem_nil h).elim⟩
  | cons ψ L' ih =>
    have hψ : ψ ∈ ⋃₀ C := hL ψ List.mem_cons_self
    have hL' : ∀ φ ∈ L', φ ∈ ⋃₀ C := fun φ h => hL φ (List.mem_cons_of_mem _ h)
    obtain ⟨S₁, hS₁mem, hψS₁⟩ := Set.mem_sUnion.mp hψ
    obtain ⟨S₂, hS₂mem, hL'S₂⟩ := ih hL'
    rcases hchain.total hS₁mem hS₂mem with h | h
    · exact ⟨S₂, hS₂mem, fun φ hφ =>
        match List.mem_cons.mp hφ with
        | .inl heq => heq ▸ h hψS₁
        | .inr hmem => hL'S₂ φ hmem⟩
    · exact ⟨S₁, hS₁mem, fun φ hφ =>
        match List.mem_cons.mp hφ with
        | .inl heq => heq ▸ hψS₁
        | .inr hmem => h (hL'S₂ φ hmem)⟩

/-- Mirror of `Core.consistent_chain_union`. -/
theorem minus_consistent_chain_union {fc : FrameClass} {C : Set (Set MinusFormula)}
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, MinusSetConsistent fc S) : MinusSetConsistent fc (⋃₀ C) := by
  intro L hL
  obtain ⟨S, hSmem, hLS⟩ := finite_list_in_chain_member hchain L hL hCne
  exact hcons S hSmem L hLS

/-- **Lindenbaum over L⁻**: mirror of `Core.set_lindenbaum`. -/
theorem minus_set_lindenbaum {fc : FrameClass} (S : Set MinusFormula)
    (hS : MinusSetConsistent fc S) :
    ∃ M : Set MinusFormula, S ⊆ M ∧ MinusSetMaximalConsistent fc M := by
  obtain ⟨M, hSM, hM, hmax⟩ :=
    exists_maximal_of_chainClosed (P := MinusSetConsistent fc)
      (fun _C hc hchain hne => minus_consistent_chain_union hchain hne hc) hS
  exact ⟨M, hSM, hM, hmax⟩

/-- Lindenbaum, landing in `MPoint`. -/
theorem exists_mpoint_extending {fc : FrameClass} (S : Set MinusFormula)
    (hS : MinusSetConsistent fc S) : ∃ M : MPoint fc, S ⊆ M.1 := by
  obtain ⟨M, hSM, hM⟩ := minus_set_lindenbaum S hS
  exact ⟨⟨M, hM⟩, hSM⟩

/-- Mirror of `BXCanonical.neg_consistent_of_not_derivable`, through the L⁻ deduction theorem
and `minusDne`: every element of a list drawn from `{¬φ}` is `¬φ`, so the derivation weakens to
context `[¬φ]`, and `⊢⁻ ¬¬φ` then yields `⊢⁻ φ`. -/
theorem neg_consistent_of_not_minus_derivable {fc : FrameClass} (φ : MinusFormula)
    (h : ¬ Derivable fc [] φ) :
    MinusSetConsistent fc ({φ.neg} : Set MinusFormula) := by
  intro L hL ⟨d⟩
  have hsub : L ⊆ [φ.neg] := fun ψ hψ => by
    have := hL ψ hψ
    simp only [Set.mem_singleton_iff] at this
    simp [this]
  have d1 : DerivationTree fc [φ.neg] MinusFormula.bot := .weakening L _ _ d hsub
  have d2 : DerivationTree fc [] φ.neg.neg := minusDeductionTheorem [] φ.neg .bot d1
  exact h ⟨.modus_ponens [] _ _ (minusDne φ) d2⟩

/-! ## Closure properties

Each mirrors its `Core.SetMaximalConsistent` namesake. The inconsistent-extension step uses
`deductionOfSubset` directly: a list `L' ⊆ insert φ S` deriving `⊥` is a subset of
`φ :: L'.filter (· ≠ φ)`, so the deduction theorem discharges `φ` without an exchange lemma. -/

namespace MinusSetMaximalConsistent

variable {fc : FrameClass} {S : Set MinusFormula}

/-- A finite list drawn from an MCS is consistent (the first component, restated). -/
theorem finite_subset_consistent (h : MinusSetMaximalConsistent fc S) (L : Context)
    (hL : ∀ ψ ∈ L, ψ ∈ S) : MinusConsistent fc L :=
  h.1 L hL

/-- **Deductive closure.** If `L ⊆ S` and `L ⊢⁻ φ`, then `φ ∈ S`. -/
theorem closed_under_derivation (h : MinusSetMaximalConsistent fc S) {φ : MinusFormula}
    (L : Context) (hL : ∀ ψ ∈ L, ψ ∈ S) (d : L ⊢⁻[fc] φ) : φ ∈ S := by
  by_contra hφ
  have hincons := h.2 φ hφ
  unfold MinusSetConsistent MinusConsistent at hincons
  push Not at hincons
  obtain ⟨L', hL', hder⟩ := hincons
  obtain ⟨d'⟩ := hder
  let Γ := L'.filter (fun y => decide (y ≠ φ))
  have hsub : L' ⊆ φ :: Γ := by
    intro x hx
    by_cases hxφ : x = φ
    · subst hxφ; exact List.mem_cons_self
    · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hx, by simpa using hxφ⟩)
  have dneg : Γ ⊢⁻[fc] φ.neg := deductionOfSubset Γ φ d' hsub
  have hΓ : ∀ ψ ∈ Γ, ψ ∈ S := by
    intro ψ hψ
    have hm := List.mem_filter.mp hψ
    have hne : ψ ≠ φ := by simpa using hm.2
    rcases Set.mem_insert_iff.mp (hL' ψ hm.1) with heq | hS
    · exact absurd heq hne
    · exact hS
  let Δ := Γ ++ L
  have hΔ : ∀ ψ ∈ Δ, ψ ∈ S := by
    intro ψ hψ
    rcases List.mem_append.mp hψ with h1 | h2
    · exact hΓ ψ h1
    · exact hL ψ h2
  have dbot : Δ ⊢⁻[fc] MinusFormula.bot :=
    .modus_ponens Δ φ .bot (.weakening Γ Δ _ dneg (List.subset_append_left _ _))
      (.weakening L Δ _ d (List.subset_append_right _ _))
  exact h.1 Δ hΔ ⟨dbot⟩

/-- Theorems of the system are in every MCS. -/
theorem theorem_in_mcs (h : MinusSetMaximalConsistent fc S) {φ : MinusFormula}
    (d : ⊢⁻[fc] φ) : φ ∈ S :=
  h.closed_under_derivation [] (fun _ hψ => (List.not_mem_nil hψ).elim) d

/-- Modus ponens inside an MCS. -/
theorem implication_property (h : MinusSetMaximalConsistent fc S) {φ ψ : MinusFormula}
    (himp : φ.imp ψ ∈ S) (hφ : φ ∈ S) : ψ ∈ S :=
  h.closed_under_derivation [φ, φ.imp ψ]
    (fun χ hχ => by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hχ
      rcases hχ with rfl | rfl <;> assumption)
    (.modus_ponens _ φ ψ (.assumption _ _ (by simp)) (.assumption _ _ (by simp)))

/-- Modus ponens against a theorem of the system. -/
theorem mp_of_theorem (h : MinusSetMaximalConsistent fc S) {φ ψ : MinusFormula}
    (d : ⊢⁻[fc] φ.imp ψ) (hφ : φ ∈ S) : ψ ∈ S :=
  h.implication_property (h.theorem_in_mcs d) hφ

/-- **Negation completeness.** -/
theorem mem_or_neg_mem (h : MinusSetMaximalConsistent fc S) (φ : MinusFormula) :
    φ ∈ S ∨ φ.neg ∈ S := by
  by_cases hφ : φ ∈ S
  · exact Or.inl hφ
  · right
    have hincons := h.2 φ hφ
    unfold MinusSetConsistent MinusConsistent at hincons
    push Not at hincons
    obtain ⟨L', hL', hder⟩ := hincons
    obtain ⟨d'⟩ := hder
    let Γ := L'.filter (fun y => decide (y ≠ φ))
    have hsub : L' ⊆ φ :: Γ := by
      intro x hx
      by_cases hxφ : x = φ
      · subst hxφ; exact List.mem_cons_self
      · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hx, by simpa using hxφ⟩)
    have hΓ : ∀ ψ ∈ Γ, ψ ∈ S := by
      intro ψ hψ
      have hm := List.mem_filter.mp hψ
      have hne : ψ ≠ φ := by simpa using hm.2
      rcases Set.mem_insert_iff.mp (hL' ψ hm.1) with heq | hS
      · exact absurd heq hne
      · exact hS
    exact h.closed_under_derivation Γ hΓ (deductionOfSubset Γ φ d' hsub)

/-- `φ` and `¬φ` are never both in an MCS. -/
theorem not_both (h : MinusSetMaximalConsistent fc S) {φ : MinusFormula} (hφ : φ ∈ S)
    (hneg : φ.neg ∈ S) : False :=
  h.1 [φ, φ.neg]
    (fun χ hχ => by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hχ
      rcases hχ with rfl | rfl <;> assumption)
    ⟨.modus_ponens _ φ .bot (.assumption _ _ (List.mem_cons_of_mem φ List.mem_cons_self))
      (.assumption _ _ List.mem_cons_self)⟩

/-- If `¬φ ∈ S` then `φ ∉ S`. -/
theorem neg_excludes (h : MinusSetMaximalConsistent fc S) {φ : MinusFormula}
    (hneg : φ.neg ∈ S) : φ ∉ S :=
  fun hφ => h.not_both hφ hneg

/-- `⊥` is in no MCS. -/
theorem bot_not_mem (h : MinusSetMaximalConsistent fc S) : MinusFormula.bot ∉ S :=
  fun hbot => h.1 [.bot]
    (fun χ hχ => by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hχ
      exact hχ ▸ hbot)
    ⟨.assumption _ _ List.mem_cons_self⟩

/-- Non-membership is membership of the negation. -/
theorem not_mem_iff_neg_mem (h : MinusSetMaximalConsistent fc S) {φ : MinusFormula} :
    φ ∉ S ↔ φ.neg ∈ S :=
  ⟨fun hφ => (h.mem_or_neg_mem φ).resolve_left hφ, fun hneg => h.neg_excludes hneg⟩

/-- Membership of the negation is non-membership. -/
theorem neg_mem_iff_not_mem (h : MinusSetMaximalConsistent fc S) {φ : MinusFormula} :
    φ.neg ∈ S ↔ φ ∉ S :=
  h.not_mem_iff_neg_mem.symm

/-- If a theorem refutes `φ`, then `φ ∉ S`. -/
theorem not_mem_of_neg_theorem (h : MinusSetMaximalConsistent fc S) {φ : MinusFormula}
    (d : ⊢⁻[fc] φ.neg) : φ ∉ S :=
  h.neg_excludes (h.theorem_in_mcs d)

/-- **Implication membership.** `(φ → ψ) ∈ S ↔ (φ ∈ S → ψ ∈ S)`. -/
theorem imp_mem_iff (h : MinusSetMaximalConsistent fc S) {φ ψ : MinusFormula} :
    φ.imp ψ ∈ S ↔ (φ ∈ S → ψ ∈ S) := by
  constructor
  · exact fun himp hφ => h.implication_property himp hφ
  · intro hfun
    by_cases hφ : φ ∈ S
    · exact h.mp_of_theorem (.axiom [] _ (Axiom.prop_s ψ φ) (FrameClass.base_le fc)) (hfun hφ)
    · exact h.mp_of_theorem (negImpImp φ ψ) (h.not_mem_iff_neg_mem.mp hφ)

/-- **Conjunction membership.** `φ.and ψ = ¬(φ → ¬ψ)`. -/
theorem and_mem_iff (h : MinusSetMaximalConsistent fc S) {φ ψ : MinusFormula} :
    φ.and ψ ∈ S ↔ φ ∈ S ∧ ψ ∈ S := by
  change (φ.imp ψ.neg).neg ∈ S ↔ _
  rw [h.neg_mem_iff_not_mem, h.imp_mem_iff, h.neg_mem_iff_not_mem]
  constructor
  · intro hn
    exact ⟨by_contra fun hφ => hn (fun h' => absurd h' hφ),
      by_contra fun hψ => hn (fun _ => hψ)⟩
  · rintro ⟨hφ, hψ⟩ hn
    exact hn hφ hψ

/-- **Disjunction membership.** `φ.or ψ = ¬φ → ψ`. -/
theorem or_mem_iff (h : MinusSetMaximalConsistent fc S) {φ ψ : MinusFormula} :
    φ.or ψ ∈ S ↔ φ ∈ S ∨ ψ ∈ S := by
  change φ.neg.imp ψ ∈ S ↔ _
  rw [h.imp_mem_iff, h.neg_mem_iff_not_mem]
  constructor
  · intro hf
    by_cases hφ : φ ∈ S
    · exact Or.inl hφ
    · exact Or.inr (hf hφ)
  · rintro (hφ | hψ) hn
    · exact absurd hφ hn
    · exact hψ

/-- **Double negation membership.** -/
theorem neg_neg_mem_iff (h : MinusSetMaximalConsistent fc S) {φ : MinusFormula} :
    φ.neg.neg ∈ S ↔ φ ∈ S := by
  rw [h.neg_mem_iff_not_mem, h.neg_mem_iff_not_mem, not_not]

/-! ### Duality inside an MCS

`F`, `P`, `◇` are the negated universal operators applied to the negation, so each is
`neg_mem_iff_not_mem` unfolded once. -/

/-- `Fψ ∈ S ↔ G¬ψ ∉ S`. -/
theorem someFuture_mem_iff (h : MinusSetMaximalConsistent fc S) {ψ : MinusFormula} :
    ψ.someFuture ∈ S ↔ ψ.neg.allFuture ∉ S :=
  h.neg_mem_iff_not_mem

/-- `Pψ ∈ S ↔ H¬ψ ∉ S`. -/
theorem somePast_mem_iff (h : MinusSetMaximalConsistent fc S) {ψ : MinusFormula} :
    ψ.somePast ∈ S ↔ ψ.neg.allPast ∉ S :=
  h.neg_mem_iff_not_mem

/-- `◇ψ ∈ S ↔ □¬ψ ∉ S`. -/
theorem diamond_mem_iff (h : MinusSetMaximalConsistent fc S) {ψ : MinusFormula} :
    ψ.diamond ∈ S ↔ ψ.neg.box ∉ S :=
  h.neg_mem_iff_not_mem

/-- `⊤ ∈ S`. -/
theorem top_mem (h : MinusSetMaximalConsistent fc S) : MinusFormula.top ∈ S :=
  h.theorem_in_mcs (deductionAssumptionSame [] .bot)

end MinusSetMaximalConsistent

/-! ## `MPoint` conveniences -/

namespace MPoint

variable {fc : FrameClass}

/-- Two points with the same members are equal. -/
theorem ext {Γ Δ : MPoint fc} (h : ∀ φ, φ ∈ Γ.1 ↔ φ ∈ Δ.1) : Γ = Δ :=
  Subtype.ext (Set.ext h)

/-- Two distinct points are separated by a formula lying in the first but not the second, in one
of the two orientations. -/
theorem exists_separating {Γ Δ : MPoint fc} (hne : Γ ≠ Δ) :
    ∃ γ : MinusFormula, γ ∈ Γ.1 ∧ γ.neg ∈ Δ.1 := by
  by_contra hcon
  push Not at hcon
  apply hne
  apply MPoint.ext
  intro φ
  constructor
  · intro hφ
    by_contra hφΔ
    exact hcon φ hφ (Δ.2.not_mem_iff_neg_mem.mp hφΔ)
  · intro hφ
    by_contra hφΓ
    have hnΓ : φ.neg ∈ Γ.1 := Γ.2.not_mem_iff_neg_mem.mp hφΓ
    have hnnΔ : φ.neg.neg ∈ Δ.1 := Δ.2.neg_neg_mem_iff.mpr hφ
    exact hcon φ.neg hnΓ hnnΔ

end MPoint

end FormalSystem.Metalogic.Conservativity

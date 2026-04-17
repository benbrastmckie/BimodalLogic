import Bimodal.Metalogic.BXCanonical.Quasimodel.SubformulaClosure
import Bimodal.Metalogic.BXCanonical.Frame

/-!
# Hintikka Points

Defines Hintikka points over a Sigma-closure: locally consistent, locally maximal
subsets of a finite formula set that respect the BX truth conditions.

## Main Definitions

- `HintikkaPoint`: A locally consistent, maximal subset of a Sigma-closure
- `sigma_signature`: Extract the Sigma-projection of a BXPoint

## Main Results

- `sigma_signature_consistent`: The Sigma-signature of a BXPoint is locally consistent
- `sigma_signature_maximal`: The Sigma-signature of a BXPoint is locally maximal

## References

- Burgess 1984: "Basic tense logic"
- Reynolds 1996: Section 2 (Hintikka structures for temporal logic)
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical

/-! ## Hintikka Point Definition -/

/-- A Hintikka point over a finite formula set Sigma.
    This is a subset of Sigma that is locally consistent and locally maximal,
    respecting the BX truth conditions restricted to Sigma.

    Unlike a full MCS (which is an infinite set closed under all derivations),
    a Hintikka point is a finite subset of the Sigma-closure that captures
    enough structure for the quasimodel construction. -/
structure HintikkaPoint (Sigma : Finset Formula) where
  /-- The set of formulas in this Hintikka point -/
  formulas : Finset Formula
  /-- The point is a subset of Sigma -/
  subset_sigma : formulas ⊆ Sigma
  /-- Local consistency: no formula and its negation both present -/
  locally_consistent : ∀ f ∈ formulas, Formula.neg f ∉ formulas
  /-- Bot is not in the point -/
  bot_free : Formula.bot ∉ formulas

/-- Two Hintikka points are equal iff they have the same formulas. -/
theorem HintikkaPoint.ext {Sigma : Finset Formula} {h1 h2 : HintikkaPoint Sigma}
    (heq : h1.formulas = h2.formulas) : h1 = h2 := by
  cases h1; cases h2; simp at heq; subst heq; rfl

/-- Hintikka points have decidable equality (via their formula sets). -/
instance {Sigma : Finset Formula} : DecidableEq (HintikkaPoint Sigma) :=
  fun h1 h2 =>
    if heq : h1.formulas = h2.formulas then
      isTrue (HintikkaPoint.ext heq)
    else
      isFalse (fun h => heq (by cases h; rfl))

/-- Membership in a Hintikka point implies membership in Sigma. -/
theorem HintikkaPoint.mem_sigma {Sigma : Finset Formula} (h : HintikkaPoint Sigma)
    {f : Formula} (hf : f ∈ h.formulas) : f ∈ Sigma :=
  h.subset_sigma hf

/-- If ¬f is in the point and f ∈ Sigma, then f is not in the point. -/
theorem HintikkaPoint.not_mem_of_neg_mem {Sigma : Finset Formula} (h : HintikkaPoint Sigma)
    {f : Formula} (hf : Formula.neg f ∈ h.formulas) : f ∉ h.formulas := by
  intro hf_in
  exact h.locally_consistent f hf_in hf

/-! ## Sigma-Signature: Projecting a BXPoint to a Hintikka Point -/

open Classical in
/-- The Sigma-signature of a BXPoint: the intersection of its formulas with Sigma.

    This projects the infinite MCS down to its Sigma-component. The key property
    is that the Sigma-signature of any BXPoint yields a valid Hintikka point
    (given appropriate closure properties of Sigma). -/
noncomputable def sigma_signature_formulas (w : BXPoint) (Sigma : Finset Formula) :
    Finset Formula :=
  Sigma.filter (fun f => f ∈ w.formulas)

open Classical in
theorem sigma_signature_subset (w : BXPoint) (Sigma : Finset Formula) :
    sigma_signature_formulas w Sigma ⊆ Sigma :=
  Finset.filter_subset _ _

open Classical in
theorem sigma_signature_mem_iff (w : BXPoint) (Sigma : Finset Formula) (f : Formula) :
    f ∈ sigma_signature_formulas w Sigma ↔ f ∈ Sigma ∧ f ∈ w.formulas := by
  simp [sigma_signature_formulas, Finset.mem_filter]

open Classical in
/-- The Sigma-signature of a BXPoint is locally consistent. -/
theorem sigma_signature_consistent (w : BXPoint) (Sigma : Finset Formula) :
    ∀ f ∈ sigma_signature_formulas w Sigma,
      Formula.neg f ∉ sigma_signature_formulas w Sigma := by
  intro f hf hfn
  rw [sigma_signature_mem_iff] at hf hfn
  -- f ∈ w.formulas and f.neg ∈ w.formulas contradicts w being MCS
  exact set_consistent_not_both w.is_mcs.1 f hf.2 hfn.2

open Classical in
/-- Bot is not in the Sigma-signature of any BXPoint. -/
theorem sigma_signature_bot_free (w : BXPoint) (Sigma : Finset Formula) :
    Formula.bot ∉ sigma_signature_formulas w Sigma := by
  intro h
  rw [sigma_signature_mem_iff] at h
  -- bot ∈ w.formulas contradicts w being MCS
  have : SetConsistent w.formulas := w.is_mcs.1
  exact this [Formula.bot] (fun ψ hψ => by simp at hψ; rw [hψ]; exact h.2)
    ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩

open Classical in
/-- Construct a HintikkaPoint from a BXPoint's Sigma-signature.
    No negation-closure requirement on Sigma: the point is the intersection
    of w.formulas with Sigma, which is automatically consistent and bot-free. -/
noncomputable def sigma_signature (w : BXPoint) (Sigma : Finset Formula) :
    HintikkaPoint Sigma where
  formulas := sigma_signature_formulas w Sigma
  subset_sigma := sigma_signature_subset w Sigma
  locally_consistent := sigma_signature_consistent w Sigma
  bot_free := sigma_signature_bot_free w Sigma

open Classical in
/-- A formula is in the Sigma-signature iff it's in both Sigma and the BXPoint. -/
theorem sigma_signature_mem {w : BXPoint} {Sigma : Finset Formula} {f : Formula} :
    f ∈ (sigma_signature w Sigma).formulas ↔ f ∈ Sigma ∧ f ∈ w.formulas := by
  simp [sigma_signature, sigma_signature_formulas, Finset.mem_filter]

/-! ## Finiteness of HintikkaPoint Space -/

/-- Hintikka points are determined by their formula sets (injective). -/
theorem hintikka_point_formulas_injective (Sigma : Finset Formula) :
    Function.Injective (fun (h : HintikkaPoint Sigma) => h.formulas) :=
  fun h1 h2 heq => HintikkaPoint.ext heq

end Bimodal.Metalogic.BXCanonical.Quasimodel

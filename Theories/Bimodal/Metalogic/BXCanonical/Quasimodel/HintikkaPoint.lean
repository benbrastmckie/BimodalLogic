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
  /-- Local maximality: for each formula in Sigma, either it or its negation is in the point -/
  locally_maximal : ∀ f ∈ Sigma, f ∈ formulas ∨ Formula.neg f ∈ formulas

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

/-- Non-membership in a Hintikka point for a Sigma-formula implies negation is present. -/
theorem HintikkaPoint.neg_of_not_mem {Sigma : Finset Formula} (h : HintikkaPoint Sigma)
    {f : Formula} (hf_sigma : f ∈ Sigma) (hf_not : f ∉ h.formulas) :
    Formula.neg f ∈ h.formulas := by
  rcases h.locally_maximal f hf_sigma with h_in | h_neg
  · exact absurd h_in hf_not
  · exact h_neg

/-- If ¬f is in the point and f ∈ Sigma, then f is not in the point. -/
theorem HintikkaPoint.not_mem_of_neg_mem {Sigma : Finset Formula} (h : HintikkaPoint Sigma)
    {f : Formula} (hf : Formula.neg f ∈ h.formulas) : f ∉ h.formulas := by
  intro hf_in
  exact h.locally_consistent f hf_in hf

/-! ## Sigma-Signature: Projecting a BXPoint to a Hintikka Point -/

/-- The Sigma-signature of a BXPoint: the intersection of its formulas with Sigma.

    This projects the infinite MCS down to its Sigma-component. The key property
    is that the Sigma-signature of any BXPoint yields a valid Hintikka point
    (given appropriate closure properties of Sigma). -/
noncomputable def sigma_signature_formulas (w : BXPoint) (Sigma : Finset Formula) :
    Finset Formula :=
  Sigma.filter (fun f => f ∈ w.formulas)

theorem sigma_signature_subset (w : BXPoint) (Sigma : Finset Formula) :
    sigma_signature_formulas w Sigma ⊆ Sigma :=
  Finset.filter_subset _ _

theorem sigma_signature_mem_iff (w : BXPoint) (Sigma : Finset Formula) (f : Formula) :
    f ∈ sigma_signature_formulas w Sigma ↔ f ∈ Sigma ∧ f ∈ w.formulas := by
  simp [sigma_signature_formulas, Finset.mem_filter]

/-- The Sigma-signature of a BXPoint is locally consistent, provided Sigma is
    closed under negation (i.e., for any f ∈ Sigma, neg f ∈ Sigma).

    Proof: if both f and neg(f) were in w.formulas, then w would be inconsistent
    (since w is an MCS). -/
theorem sigma_signature_consistent (w : BXPoint) (Sigma : Finset Formula) :
    ∀ f ∈ sigma_signature_formulas w Sigma,
      Formula.neg f ∉ sigma_signature_formulas w Sigma := by
  intro f hf hfn
  rw [sigma_signature_mem_iff] at hf hfn
  -- f ∈ w.formulas and f.neg ∈ w.formulas contradicts w being MCS
  exact set_consistent_not_both w.is_mcs.1 f hf.2 hfn.2

/-- Bot is not in the Sigma-signature of any BXPoint. -/
theorem sigma_signature_bot_free (w : BXPoint) (Sigma : Finset Formula) :
    Formula.bot ∉ sigma_signature_formulas w Sigma := by
  intro h
  rw [sigma_signature_mem_iff] at h
  -- bot ∈ w.formulas contradicts w being MCS
  have : SetConsistent w.formulas := w.is_mcs.1
  exact this [Formula.bot] (fun ψ hψ => by simp at hψ; rw [hψ]; exact h.2)
    ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩

/-- The Sigma-signature of a BXPoint is locally maximal, provided Sigma is
    closed under negation.

    Proof: for any f ∈ Sigma, by negation completeness of the MCS w,
    either f ∈ w.formulas or f.neg ∈ w.formulas. -/
theorem sigma_signature_maximal (w : BXPoint) (Sigma : Finset Formula)
    (h_neg_closed : ∀ f ∈ Sigma, Formula.neg f ∈ Sigma) :
    ∀ f ∈ Sigma, f ∈ sigma_signature_formulas w Sigma ∨
      Formula.neg f ∈ sigma_signature_formulas w Sigma := by
  intro f hf
  rcases SetMaximalConsistent.negation_complete w.is_mcs f with h | h
  · left; rw [sigma_signature_mem_iff]; exact ⟨hf, h⟩
  · right; rw [sigma_signature_mem_iff]; exact ⟨h_neg_closed f hf, h⟩

/-- Construct a HintikkaPoint from a BXPoint's Sigma-signature, provided Sigma
    has the negation closure property. -/
noncomputable def sigma_signature (w : BXPoint) (Sigma : Finset Formula)
    (h_neg_closed : ∀ f ∈ Sigma, Formula.neg f ∈ Sigma) :
    HintikkaPoint Sigma where
  formulas := sigma_signature_formulas w Sigma
  subset_sigma := sigma_signature_subset w Sigma
  locally_consistent := sigma_signature_consistent w Sigma
  bot_free := sigma_signature_bot_free w Sigma
  locally_maximal := sigma_signature_maximal w Sigma h_neg_closed

/-- A formula is in the Sigma-signature iff it's in both Sigma and the BXPoint. -/
theorem sigma_signature_mem {w : BXPoint} {Sigma : Finset Formula}
    {h_neg : ∀ f ∈ Sigma, Formula.neg f ∈ Sigma} {f : Formula} :
    f ∈ (sigma_signature w Sigma h_neg).formulas ↔ f ∈ Sigma ∧ f ∈ w.formulas := by
  simp [sigma_signature, sigma_signature_formulas, Finset.mem_filter]

/-! ## Finiteness of HintikkaPoint Space -/

/-- The number of Hintikka points over Sigma is bounded by the number of
    subsets of Sigma (which is 2^|Sigma|). This gives us a finite space
    to work with in the quasimodel construction.

    Note: We don't need an explicit Fintype instance for the quasimodel
    construction; we just need the cardinality bound for the termination
    argument. The bound is `2^Sigma.card`. -/
theorem hintikka_point_card_bound (Sigma : Finset Formula) :
    ∀ (points : Finset (HintikkaPoint Sigma)),
      points.card ≤ 2 ^ Sigma.card := by
  intro points
  -- Each HintikkaPoint is determined by its formulas, which is a subset of Sigma.
  -- The number of subsets of Sigma is 2^|Sigma|.
  -- Since the map HintikkaPoint → Finset Formula (via .formulas) is injective,
  -- |points| ≤ |Sigma.powerset| = 2^|Sigma|.
  have h_inj : Function.Injective (fun (h : HintikkaPoint Sigma) => h.formulas) := by
    intro h1 h2 heq; exact HintikkaPoint.ext heq
  calc points.card
      ≤ (points.image (fun h => h.formulas)).card :=
        le_of_eq (Finset.card_image_of_injective points h_inj).symm
    _ ≤ Sigma.powerset.card := by
        apply Finset.card_le_card
        intro s hs
        rw [Finset.mem_image] at hs
        obtain ⟨h, _, rfl⟩ := hs
        exact Finset.mem_powerset.mpr h.subset_sigma
    _ = 2 ^ Sigma.card := Finset.card_powerset Sigma

end Bimodal.Metalogic.BXCanonical.Quasimodel

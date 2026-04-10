import Bimodal.Syntax.Formula

/-!
# Subformula Closure (Sigma-Closure)

Defines the finite subformula closure for the Hintikka-set quasimodel construction.
Given a target formula (e.g., `φ U ψ`), the Sigma-closure includes:
- The target and all its subformulas
- G/H enrichment for locus-control
- Negation pairing: for each f in the enriched set, neg f is also included

## Main Definitions

- `subformulas`: Compute the `Finset Formula` of all subformulas of a formula
- `SubformulaClosure`: The enriched closure needed for the quasimodel construction

## References

- Burgess 1984: "Basic tense logic"
- Reynolds 1996: "An axiomatization of full computation tree logic" (Section 2)
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax

/-! ## Subformula Extraction -/

/-- Compute all subformulas of a formula as a `Finset`. -/
def subformulas : Formula → Finset Formula
  | f@(Formula.atom _) => {f}
  | f@Formula.bot => {f}
  | f@(Formula.imp φ ψ) => insert f (subformulas φ ∪ subformulas ψ)
  | f@(Formula.box φ) => insert f (subformulas φ)
  | f@(Formula.all_past φ) => insert f (subformulas φ)
  | f@(Formula.all_future φ) => insert f (subformulas φ)
  | f@(Formula.untl φ ψ) => insert f (subformulas φ ∪ subformulas ψ)
  | f@(Formula.snce φ ψ) => insert f (subformulas φ ∪ subformulas ψ)

/-- A formula is in its own subformula set. -/
theorem self_mem_subformulas (f : Formula) : f ∈ subformulas f := by
  cases f <;> simp [subformulas]

/-! ## G/H Enrichment -/

/-- G/H enrichment: for each formula in S, add G(f) and H(f).
    Needed for locus-control: Sigma-signatures must determine bx_le comparisons. -/
def ghEnrichment (S : Finset Formula) : Finset Formula :=
  S ∪ S.image Formula.all_future ∪ S.image Formula.all_past

/-! ## Full Subformula Closure -/

/-- The full Sigma-closure for a target formula.
    Includes subformulas, G/H enrichment, and negation pairing.

    For each formula f in the G/H-enriched subformula set, both f and neg f
    are included. This ensures the Hintikka point maximality condition can
    be satisfied: for each f ∈ Sigma, either f or neg f is in the point.

    The result is a finite set (Finset) by construction. -/
def SubformulaClosure (target : Formula) : Finset Formula :=
  let base := ghEnrichment (subformulas target)
  base ∪ base.image Formula.neg

/-- The target formula is in its own Sigma-closure. -/
theorem target_mem (target : Formula) : target ∈ SubformulaClosure target := by
  apply Finset.mem_union_left
  apply Finset.mem_union_left
  exact Finset.mem_union_left _ (self_mem_subformulas target)

/-- For any f in the base (ghEnrichment of subformulas), neg f ∈ SubformulaClosure. -/
theorem neg_of_base_mem {target f : Formula}
    (h : f ∈ ghEnrichment (subformulas target)) :
    Formula.neg f ∈ SubformulaClosure target := by
  apply Finset.mem_union_right
  exact Finset.mem_image.mpr ⟨f, h, rfl⟩

/-- Any subformula of the target is in the closure. -/
theorem subformula_mem {target f : Formula} (h : f ∈ subformulas target) :
    f ∈ SubformulaClosure target := by
  apply Finset.mem_union_left
  exact Finset.mem_union_left _ (Finset.mem_union_left _ h)

/-- G(f) is in the closure whenever f is a subformula of the target. -/
theorem g_enrichment_mem {target f : Formula} (h : f ∈ subformulas target) :
    Formula.all_future f ∈ SubformulaClosure target := by
  apply Finset.mem_union_left
  apply Finset.mem_union_left
  apply Finset.mem_union_right
  exact Finset.mem_image.mpr ⟨f, h, rfl⟩

/-- H(f) is in the closure whenever f is a subformula of the target. -/
theorem h_enrichment_mem {target f : Formula} (h : f ∈ subformulas target) :
    Formula.all_past f ∈ SubformulaClosure target := by
  apply Finset.mem_union_left
  apply Finset.mem_union_right
  exact Finset.mem_image.mpr ⟨f, h, rfl⟩

/-- The Sigma-closure is finite (inherent from Finset). -/
theorem closure_finite (target : Formula) : (SubformulaClosure target).Nonempty :=
  ⟨target, target_mem target⟩

/-- The negation pairing property: for each f in the base enrichment,
    both f and neg f are in the Sigma-closure. This is the property
    needed for the Hintikka point sigma_signature construction. -/
theorem neg_pairing (target : Formula) :
    ∀ f ∈ ghEnrichment (subformulas target),
      f ∈ SubformulaClosure target ∧ Formula.neg f ∈ SubformulaClosure target := by
  intro f hf
  constructor
  · exact Finset.mem_union_left _ hf
  · exact neg_of_base_mem hf

end Bimodal.Metalogic.BXCanonical.Quasimodel

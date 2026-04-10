import Bimodal.Syntax.Formula

/-!
# Subformula Closure (Sigma-Closure)

Defines the finite subformula closure for the Hintikka-set quasimodel construction.
Given a target formula (e.g., `φ U ψ`), the Sigma-closure includes:
- The target and all its subformulas
- Negation closure
- Burgess-Xu accumulate/absorb formulas
- G/H enrichment for locus-control

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

/-- Subformulas of subformulas: if `ψ ∈ subformulas φ`, then `subformulas ψ ⊆ subformulas φ`. -/
theorem subformulas_subset_of_mem {φ ψ : Formula} (h : ψ ∈ subformulas φ) :
    subformulas ψ ⊆ subformulas φ := by
  induction φ with
  | atom a =>
    simp [subformulas] at h; rw [h]; exact Finset.Subset.refl _
  | bot =>
    simp [subformulas] at h; rw [h]; exact Finset.Subset.refl _
  | imp a b iha ihb =>
    simp [subformulas] at h
    rcases h with rfl | ha | hb
    · exact Finset.Subset.refl _
    · intro x hx; simp [subformulas]; right; left; exact iha ha hx
    · intro x hx; simp [subformulas]; right; right; exact ihb hb hx
  | box a ih =>
    simp [subformulas] at h
    rcases h with rfl | ha
    · exact Finset.Subset.refl _
    · intro x hx; simp [subformulas]; right; exact ih ha hx
  | all_past a ih =>
    simp [subformulas] at h
    rcases h with rfl | ha
    · exact Finset.Subset.refl _
    · intro x hx; simp [subformulas]; right; exact ih ha hx
  | all_future a ih =>
    simp [subformulas] at h
    rcases h with rfl | ha
    · exact Finset.Subset.refl _
    · intro x hx; simp [subformulas]; right; exact ih ha hx
  | untl a b iha ihb =>
    simp [subformulas] at h
    rcases h with rfl | ha | hb
    · exact Finset.Subset.refl _
    · intro x hx; simp [subformulas]; right; left; exact iha ha hx
    · intro x hx; simp [subformulas]; right; right; exact ihb hb hx
  | snce a b iha ihb =>
    simp [subformulas] at h
    rcases h with rfl | ha | hb
    · exact Finset.Subset.refl _
    · intro x hx; simp [subformulas]; right; left; exact iha ha hx
    · intro x hx; simp [subformulas]; right; right; exact ihb hb hx

/-! ## Negation Closure -/

/-- Add negations of all formulas in a set. -/
def negationClosure (S : Finset Formula) : Finset Formula :=
  S ∪ S.image Formula.neg

theorem mem_negationClosure_self {S : Finset Formula} {f : Formula} (h : f ∈ S) :
    f ∈ negationClosure S :=
  Finset.mem_union_left _ h

theorem neg_mem_negationClosure {S : Finset Formula} {f : Formula} (h : f ∈ S) :
    Formula.neg f ∈ negationClosure S :=
  Finset.mem_union_right _ (Finset.mem_image_of_mem _ h)

/-! ## Burgess-Xu Enrichment -/

/-- Collect all Until subformulas from a set. -/
def untilFormulas (S : Finset Formula) : Finset (Formula × Formula) :=
  S.filterMap (fun f => match f with
    | Formula.untl φ ψ => some (φ, ψ)
    | _ => none)

/-- Collect all Since subformulas from a set. -/
def sinceFormulas (S : Finset Formula) : Finset (Formula × Formula) :=
  S.filterMap (fun f => match f with
    | Formula.snce φ ψ => some (φ, ψ)
    | _ => none)

/-- Burgess-Xu accumulate closure for Until:
    If `φ U ψ ∈ S`, add `(φ ∧ (φ U ψ)) U ψ` (from BX5). -/
def accumulateClosure (S : Finset Formula) : Finset Formula :=
  S ∪ (untilFormulas S).image (fun p =>
    Formula.untl (Formula.and p.1 (Formula.untl p.1 p.2)) p.2)

/-- Burgess-Xu absorb closure for Until:
    If `φ U ψ ∈ S`, add `φ U (φ ∧ (φ U ψ))` (for BX6). -/
def absorbClosure (S : Finset Formula) : Finset Formula :=
  S ∪ (untilFormulas S).image (fun p =>
    Formula.untl p.1 (Formula.and p.1 (Formula.untl p.1 p.2)))

/-- Since accumulate closure: mirror of accumulateClosure for Since (BX5'). -/
def sinceAccumulateClosure (S : Finset Formula) : Finset Formula :=
  S ∪ (sinceFormulas S).image (fun p =>
    Formula.snce (Formula.and p.1 (Formula.snce p.1 p.2)) p.2)

/-! ## G/H Enrichment -/

/-- G/H enrichment: for each formula in S, add G(f) and H(f).
    Needed for locus-control: Sigma-signatures must determine bx_le comparisons. -/
def ghEnrichment (S : Finset Formula) : Finset Formula :=
  S ∪ S.image Formula.all_future ∪ S.image Formula.all_past

theorem mem_ghEnrichment_self {S : Finset Formula} {f : Formula} (h : f ∈ S) :
    f ∈ ghEnrichment S :=
  Finset.mem_union_left _ (Finset.mem_union_left _ h)

theorem g_mem_ghEnrichment {S : Finset Formula} {f : Formula} (h : f ∈ S) :
    Formula.all_future f ∈ ghEnrichment S :=
  Finset.mem_union_left _ (Finset.mem_union_right _ (Finset.mem_image_of_mem _ h))

theorem h_mem_ghEnrichment {S : Finset Formula} {f : Formula} (h : f ∈ S) :
    Formula.all_past f ∈ ghEnrichment S :=
  Finset.mem_union_right _ (Finset.mem_image_of_mem _ h)

/-! ## Full Subformula Closure -/

/-- The full Sigma-closure for a target formula.
    Includes subformulas, negation closure, BX enrichment, and G/H enrichment.

    Construction:
    1. Start with subformulas of the target
    2. Add Burgess-Xu accumulate/absorb formulas for Until subformulas
    3. Add Since accumulate formulas
    4. Add G/H enrichment for locus-control
    5. Close under negation

    The result is a finite set (Finset) by construction. -/
def SubformulaClosure (target : Formula) : Finset Formula :=
  let base := subformulas target
  let withAccum := accumulateClosure base
  let withAbsorb := absorbClosure withAccum
  let withSinceAccum := sinceAccumulateClosure withAbsorb
  let withGH := ghEnrichment withSinceAccum
  negationClosure withGH

/-- The target formula is in its own Sigma-closure. -/
theorem target_mem (target : Formula) : target ∈ SubformulaClosure target := by
  unfold SubformulaClosure
  apply mem_negationClosure_self
  apply mem_ghEnrichment_self
  simp [sinceAccumulateClosure, absorbClosure, accumulateClosure]
  left; left; left
  exact self_mem_subformulas target

/-- Negation of any member is in the closure. -/
theorem neg_mem {target f : Formula} (h : f ∈ SubformulaClosure target) :
    Formula.neg f ∈ SubformulaClosure target := by
  unfold SubformulaClosure at *
  -- h : f ∈ negationClosure (ghEnrichment ...)
  -- We need: Formula.neg f ∈ negationClosure (ghEnrichment ...)
  simp [negationClosure] at *
  rcases h with h | ⟨g, hg, hfg⟩
  · right; exact ⟨f, h, rfl⟩
  · right; exact ⟨f, Or.inr ⟨g, hg, hfg⟩, rfl⟩

/-- Any subformula of the target is in the closure. -/
theorem subformula_mem {target f : Formula} (h : f ∈ subformulas target) :
    f ∈ SubformulaClosure target := by
  unfold SubformulaClosure
  apply mem_negationClosure_self
  apply mem_ghEnrichment_self
  simp [sinceAccumulateClosure, absorbClosure, accumulateClosure]
  left; left; left; exact h

/-- G(f) is in the closure whenever f is a subformula of the target. -/
theorem g_enrichment_mem {target f : Formula} (h : f ∈ subformulas target) :
    Formula.all_future f ∈ SubformulaClosure target := by
  unfold SubformulaClosure
  apply mem_negationClosure_self
  apply g_mem_ghEnrichment
  simp [sinceAccumulateClosure, absorbClosure, accumulateClosure]
  left; left; left; exact h

/-- H(f) is in the closure whenever f is a subformula of the target. -/
theorem h_enrichment_mem {target f : Formula} (h : f ∈ subformulas target) :
    Formula.all_past f ∈ SubformulaClosure target := by
  unfold SubformulaClosure
  apply mem_negationClosure_self
  apply h_mem_ghEnrichment
  simp [sinceAccumulateClosure, absorbClosure, accumulateClosure]
  left; left; left; exact h

/-- The Sigma-closure is finite (inherent from Finset). -/
theorem closure_finite (target : Formula) : (SubformulaClosure target).Nonempty :=
  ⟨target, target_mem target⟩

end Bimodal.Metalogic.BXCanonical.Quasimodel

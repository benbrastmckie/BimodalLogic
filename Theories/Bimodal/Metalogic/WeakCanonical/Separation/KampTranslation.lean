import Bimodal.Metalogic.WeakCanonical.Separation.SemanticBridge
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.StaviConnectives

/-!
# Kamp Translation Infrastructure

Infrastructure for proving {U,S} expressive completeness on Z-structures
(Kamp's theorem for integer time). This file provides formula list
operations and atom literal construction used by the Kamp translation.

## Status

The full Kamp translation (Phases 2-3 of the separation bypass plan)
is BLOCKED on the n-variable Fraisse game argument. See the plan file
for details on the blocker and three identified approaches to resolve it.

## Infrastructure Provided

- `formula_conjList` / `formula_disjList`: conjunction/disjunction of formula lists
- `atom_literal`: temporal formula for a predicate literal
- `nf_depth0_char_formula`: temporal formula characterizing a depth-0 NF

## References

- Kamp 1968, "Tense Logic and the Theory of Linear Order"
- GHR94 Chapter 10 (separation theorem)
- Doets 1989, Lemma 1.1 (normal form theory)
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Helper: Conjunction and Disjunction of Lists -/

/-- Conjunction of a list of formulas. Empty list gives ⊤. -/
def formula_conjList : List Formula → Formula
  | [] => Formula.top
  | φ :: rest => Formula.and φ (formula_conjList rest)

/-- Disjunction of a list of formulas. Empty list gives ⊥. -/
def formula_disjList : List Formula → Formula
  | [] => Formula.bot
  | φ :: rest => Formula.or φ (formula_disjList rest)

/-- formula_conjList truth: all formulas in the list are true. -/
theorem formula_conjList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (fs : List Formula) :
    temporal_truth M atomMap t (formula_conjList fs) ↔
    ∀ φ ∈ fs, temporal_truth M atomMap t φ := by
  induction fs with
  | nil => simp [formula_conjList, Formula.top, temporal_truth]
  | cons φ rest ih =>
    simp only [formula_conjList, Formula.and, Formula.neg, temporal_truth]
    constructor
    · intro h ψ' hψ'
      rcases List.mem_cons.mp hψ' with rfl | hmem
      · by_contra hφ; exact h (fun hφ' => absurd hφ' hφ)
      · by_contra hrest
        apply h; intro hφ
        exact absurd ((ih.mp (by by_contra h_neg; exact h (fun _ => h_neg))) ψ' hmem) hrest
    · intro h hφ_imp
      exact hφ_imp (h φ (by simp)) (ih.mpr (fun ψ' hψ' => h ψ' (by simp [hψ'])))

/-- formula_disjList truth: some formula in the list is true. -/
theorem formula_disjList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (fs : List Formula) :
    temporal_truth M atomMap t (formula_disjList fs) ↔
    ∃ φ ∈ fs, temporal_truth M atomMap t φ := by
  induction fs with
  | nil => simp [formula_disjList, temporal_truth]
  | cons φ rest ih =>
    simp only [formula_disjList, Formula.or, Formula.neg, temporal_truth]
    constructor
    · intro h
      by_cases hφ : temporal_truth M atomMap t φ
      · exact ⟨φ, by simp, hφ⟩
      · obtain ⟨ψ', hψ'_mem, hψ'⟩ := ih.mp (h hφ)
        exact ⟨ψ', by simp [hψ'_mem], hψ'⟩
    · intro ⟨ψ', hψ'_mem, hψ'⟩ hφ_neg
      simp only [List.mem_cons] at hψ'_mem
      rcases hψ'_mem with rfl | h
      · exact absurd hψ' hφ_neg
      · exact ih.mpr ⟨ψ', h, hψ'⟩

/-! ## Atom Literals -/

/-- Build the atom literal for a predicate: `.atom a` if true, `.atom a |>.neg` if false. -/
noncomputable def atom_literal
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (p : sig.preds) (val : Bool) : Formula :=
  let a := Classical.choose (h_surj p)
  match val with
  | true => Formula.atom a
  | false => (Formula.atom a).neg

/-- The atom literal has the correct truth value. -/
theorem atom_literal_correct
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (p : sig.preds) (val : Bool) (t : M.carrier) :
    temporal_truth M atomMap t (atom_literal atomMap h_surj p val) ↔
    (M.interp p t ↔ val = true) := by
  unfold atom_literal
  have ha := Classical.choose_spec (h_surj p)
  cases val with
  | true =>
    simp only [temporal_truth, ha]
    tauto
  | false =>
    simp only [Formula.neg, temporal_truth, ha, Bool.false_eq_true]
    exact ⟨fun h => ⟨fun h_interp => absurd h_interp h, False.elim⟩,
           fun ⟨h1, _⟩ => h1⟩

/-! ## Depth-0 NF Characteristic Formula

At depth 0, a NF is just a truth assignment to atoms (predicates applied to the
single variable). The characteristic formula is the conjunction of atom literals. -/

/-- Temporal formula characterizing a depth-0 NF with 1 variable.
    This is the conjunction of atom literals for all predicates in the signature. -/
noncomputable def nf_depth0_char_formula
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf : NormalForm sig 0 1) : Formula :=
  formula_conjList
    ((Fintype.elems (α := sig.preds)).val.toList.map fun p =>
      atom_literal atomMap h_surj p (nf (.pred p ⟨0, by omega⟩)))

/-- The depth-0 characteristic formula is correct on any ordered monadic structure:
    it holds at t iff t satisfies the NF's atom assignment for all predicates. -/
theorem nf_depth0_char_formula_correct
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf : NormalForm sig 0 1) (t : M.carrier) :
    temporal_truth M atomMap t (nf_depth0_char_formula atomMap h_surj nf) ↔
    (∀ p : sig.preds, M.interp p t ↔ nf (.pred p ⟨0, by omega⟩) = true) := by
  simp only [nf_depth0_char_formula]
  rw [formula_conjList_iff]
  constructor
  · intro h p
    have h_mem : atom_literal atomMap h_surj p (nf (.pred p ⟨0, by omega⟩)) ∈
        List.map (fun p => atom_literal atomMap h_surj p (nf (.pred p ⟨0, by omega⟩)))
          (Fintype.elems (α := sig.preds)).val.toList := by
      simp only [List.mem_map]
      exact ⟨p, Multiset.mem_toList.mpr (Fintype.complete p), rfl⟩
    exact (atom_literal_correct M atomMap h_surj p _ t).mp (h _ h_mem)
  · intro h φ h_mem
    simp only [List.mem_map] at h_mem
    obtain ⟨p, _, rfl⟩ := h_mem
    exact (atom_literal_correct M atomMap h_surj p _ t).mpr (h p)

end Bimodal.Metalogic.WeakCanonical.Separation

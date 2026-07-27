import FormalSystem.Metalogic.WeakCanonical.Kamp.NfToVecEA
import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.PriorDefs
import FormalSystem.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Depth-(k+1) NF Characterization Infrastructure

Provides the infrastructure for converting depth-(k+1) arity-1 NFs to temporal
formulas, given that depth-k arity-2 existentials can be converted. This is
the "Part A" machinery from the Rabinovich chain: combining atom conditions
(depth-0 characteristic formulas) with quantifier conditions (existential
or universal over depth-k arity-2 NFs).

## Main Results

- `nf_quant_clause_tl`: Build temporal formula for a single quantifier clause.
- `nf_succ_char_formula`: Build characteristic temporal formula for depth-(k+1)
  arity-1 NF, given function converting depth-k arity-2 existentials.
- `nf_succ_char_formula_correct`: Correctness theorem.
- `nf_2var_exist_depth0_tl_fn`: Wrapper for depth-0 arity-2 existential conversion.

## Architecture

The proof of `nf_characterizable_temporal_prior (succ k)` in `KampPrior.lean`
uses this file as follows:
- At k=0: `nf_succ_char_formula` with `nf_2var_exist_depth0_tl_fn` (sorry-free).
- At k>0: Requires depth-k arity-2 existential conversion, which involves
  depth-(k-1) arity-3 NFs (arity tower obstruction). This case is blocked
  pending generalization of V-EA formulas to arbitrary arity.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 3-5
- Doets 1989, Lemma 1.1 (normal form bridge theorem)
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Helper: atomKind_arity1_is_pred (for atom part) -/

/-- For arity 1, every `AtomKind sig 1` is a pred atom. -/
private theorem atomKind_arity1_is_pred' {sig : MonadicSignature}
    (a : AtomKind sig 1) :
    ∃ (p : sig.preds), a = .pred p ⟨0, by omega⟩ := by
  match a with
  | .pred p i =>
    have : i = ⟨0, by omega⟩ := Fin.ext (by omega)
    subst this
    exact ⟨p, rfl⟩
  | .order i j h =>
    have hi : i = ⟨0, by omega⟩ := Fin.ext (by omega)
    have hj : j = ⟨0, by omega⟩ := Fin.ext (by omega)
    subst hi; subst hj
    exact absurd rfl h

/-! ## Quantifier clause temporal formula -/

/-- Build the temporal formula for a single quantifier clause of a
    depth-(k+1) arity-1 NF: positive (existential) or negative (universal). -/
noncomputable def nf_quant_clause_tl
    (exist_tl : Formula)
    (is_positive : Bool) : Formula :=
  if is_positive then exist_tl
  else Formula.neg exist_tl

/-- Correctness of `nf_quant_clause_tl`. -/
theorem nf_quant_clause_tl_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier)
    (exist_tl : Formula)
    (is_positive : Bool)
    (P : Prop)
    (h_exist : temporal_truth M atomMap t exist_tl ↔ P) :
    temporal_truth M atomMap t (nf_quant_clause_tl exist_tl is_positive) ↔
    (P ↔ (is_positive = true)) := by
  simp only [nf_quant_clause_tl]
  cases is_positive
  · simp only [ite_false, Bool.false_eq_true, iff_false]
    simp only [Formula.neg, temporal_truth]
    constructor
    · intro h hP; exact h (h_exist.mpr hP)
    · intro h htt; exact h (h_exist.mp htt)
  · simp only [ite_true, iff_true]
    exact h_exist

/-! ## Part A: Build characteristic formula for depth-(k+1) arity-1 NF -/

/-- Build the characteristic temporal formula for a depth-(k+1) arity-1 NF,
    given a function that converts depth-k arity-2 existentials to temporal.
    The formula is the conjunction of:
    1. The atom literal conjunction (same as depth-0)
    2. For each sub_nf : NormalForm sig k 2, the quantifier clause -/
noncomputable def nf_succ_char_formula
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (exist_tl_fn : NormalForm sig k 2 → Formula)
    (nf : NormalForm sig (k + 1) 1) : Formula :=
  let atom_part := nf_depth0_char_formula atomMap h_surj
    (fun a => nf.1 a : NormalForm sig 0 1)
  let quant_clauses := (Finset.univ.toList : List (NormalForm sig k 2)).map
    (fun sub_nf => nf_quant_clause_tl (exist_tl_fn sub_nf) (nf.2 sub_nf))
  formula_conjList (atom_part :: quant_clauses)

/-- Correctness of `nf_succ_char_formula`. -/
theorem nf_succ_char_formula_correct
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (exist_tl_fn : NormalForm sig k 2 → Formula)
    (h_exist_correct : ∀ (sub_nf : NormalForm sig k 2)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (exist_tl_fn sub_nf) ↔
      ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
    (nf : NormalForm sig (k + 1) 1)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (nf_succ_char_formula atomMap h_surj exist_tl_fn nf) ↔
    nf_eval_nf M (k + 1) 1 (fun _ => t) nf := by
  simp only [nf_succ_char_formula]
  rw [formula_conjList_iff]
  change _ ↔ (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ (nf.1 a = true)) ∧
    (∀ (sub_nf : NormalForm sig k 2),
      (∃ (x : M.carrier), nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf) ↔
        (nf.2 sub_nf = true))
  have quant_mem : ∀ sub_nf : NormalForm sig k 2,
      nf_quant_clause_tl (exist_tl_fn sub_nf) (nf.2 sub_nf) ∈
        List.map (fun sub_nf => nf_quant_clause_tl (exist_tl_fn sub_nf) (nf.2 sub_nf))
          Finset.univ.toList :=
    fun sub_nf => List.mem_map.mpr
      ⟨sub_nf, Finset.mem_toList.mpr (Finset.mem_univ sub_nf), rfl⟩
  constructor
  · intro h_all
    constructor
    · have h_atom := h_all _ (.head _)
      rw [nf_depth0_char_formula_correct] at h_atom
      intro a
      obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred' a
      simp only [atom_eval]
      exact h_atom p
    · intro sub_nf
      have h_clause := h_all _ (.tail _ (quant_mem sub_nf))
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _
        (h_exist_correct sub_nf M h_UZ h_SZ t)] at h_clause
      exact h_clause
  · intro ⟨h_atoms, h_quants⟩ φ h_mem
    cases h_mem with
    | head =>
      rw [nf_depth0_char_formula_correct]
      intro p
      exact (h_atoms (.pred p ⟨0, by omega⟩))
    | tail _ h_tail =>
      obtain ⟨sub_nf, _, rfl⟩ := List.mem_map.mp h_tail
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _
        (h_exist_correct sub_nf M h_UZ h_SZ t)]
      exact h_quants sub_nf

/-! ## Part B at depth 0: wrapper for nf_2var_exist_depth0_tl -/

/-- Wrap `nf_2var_exist_depth0_tl` to produce the function needed by
    `nf_succ_char_formula` at the base case (k=0). -/
noncomputable def nf_2var_exist_depth0_tl_fn
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    NormalForm sig 0 2 → Formula :=
  fun sub_nf => (nf_2var_exist_depth0_tl atomMap h_surj sub_nf).choose

/-- Correctness of the depth-0 Part B wrapper. -/
theorem nf_2var_exist_depth0_tl_fn_correct
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2)
    (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    temporal_truth M atomMap t (nf_2var_exist_depth0_tl_fn atomMap h_surj sub_nf) ↔
    ∃ x : M.carrier, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (nf_2var_exist_depth0_tl atomMap h_surj sub_nf).choose_spec M t

end Bimodal.Metalogic.WeakCanonical.Kamp

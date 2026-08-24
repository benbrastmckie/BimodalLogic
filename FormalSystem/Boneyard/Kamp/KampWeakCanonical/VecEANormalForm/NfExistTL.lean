import FormalSystem.Metalogic.WeakCanonical.Kamp.NfToVecEA
import FormalSystem.Boneyard.Kamp.KampWeakCanonical.VecEANormalForm.FOToVEA
import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.PriorDefs
import FormalSystem.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Depth-k NF Existential to Temporal Formula Conversion

Converts `∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf` to a
temporal formula that is equivalent on Prior structures, for all k by
induction on k.

## Main Results

- `nf_characterizable_temporal_prior_combined`: Combined induction proving
  Part A (arity-1 NF characterization) and Part B (arity-2 existential
  elimination) simultaneously.

## Architecture

The proof proceeds by induction on k with two parts at each level:

- **Part A** (arity-1): Every depth-k arity-1 NF has a temporal characteristic
  formula on Prior structures. At k=0 this is `nf_depth0_char_formula`. At k+1
  this uses Part B at depth k (from the IH) plus atom literals.

- **Part B** (arity-2 existential): Every `∃ x, nf_eval_nf M k 2 (x::t) sub_nf`
  is temporally definable on Prior structures. At k=0 this is
  `nf_2var_exist_depth0_tl`. At k+1 this requires decomposing the arity-2
  NF into atom conditions and quantifier conditions, where each quantifier
  clause involves `NormalForm sig k 3` -- an arity-3 sub-NF.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 3-5
- Doets 1989, Lemma 1.1 (normal form bridge theorem)
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Helper: atomKind_arity1_is_pred (inlined from KampPrior) -/

/-- For arity 1, there are no order atoms: every `AtomKind sig 1` is a pred atom. -/
private theorem atomKind_arity1_is_pred' {sig : MonadicSignature} (a : AtomKind sig 1) :
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

/-! ## Helper: Quantifier clause temporal formula

Given a function that converts depth-k arity-2 existentials to temporal
formulas, and the quantifier assignment of a depth-(k+1) arity-1 NF,
produce the temporal formula for a single quantifier clause (positive
or negative). -/

/-- Build the temporal formula for a single quantifier clause of a
    depth-(k+1) arity-1 NF.

    If `quant_assgn sub_nf = true`, the clause asserts the existential holds.
    If `quant_assgn sub_nf = false`, the clause asserts the existential fails.

    The `exist_tl` function converts `∃ x, nf_eval_nf M k 2 (x::t) sub_nf`
    to a temporal formula. -/
noncomputable def nf_quant_clause_tl
    (exist_tl : Formula)
    (is_positive : Bool) : Formula :=
  if is_positive then exist_tl
  else Formula.neg exist_tl

/-- Correctness of `nf_quant_clause_tl`: the clause formula is equivalent to
    `P ↔ (is_positive = true)` where P is what `exist_tl` captures. -/
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
  · -- is_positive = false: clause is ¬exist_tl
    simp only [ite_false, Bool.false_eq_true, iff_false]
    simp only [Formula.neg, temporal_truth]
    constructor
    · intro h hP; exact h (h_exist.mpr hP)
    · intro h htt; exact h (h_exist.mp htt)
  · -- is_positive = true: clause is exist_tl
    simp only [ite_true, iff_true]
    exact h_exist

/-! ## Part A at succ k: Build characteristic temporal formula for depth-(k+1) arity-1 NF

Given the IH for Part B at depth k (a function converting each arity-2
existential to a temporal formula), build the characteristic temporal
formula for a depth-(k+1) arity-1 NF. -/

/-- Build the characteristic temporal formula for a depth-(k+1) arity-1 NF,
    given a function that converts depth-k arity-2 existentials to temporal
    formulas. The formula is the conjunction of:
    1. The atom literal conjunction (same as depth-0)
    2. For each sub_nf : NormalForm sig k 2, the quantifier clause
       (positive or negative, depending on the quantifier assignment). -/
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

/-- Correctness of `nf_succ_char_formula`: the formula characterizes the
    depth-(k+1) arity-1 NF, given correct Part B at depth k. -/
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
  -- nf_eval_nf at depth k+1 arity 1 unfolds to atom agreement ∧ quantifier agreement
  change _ ↔ (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ (nf.1 a = true)) ∧
    (∀ (sub_nf : NormalForm sig k 2),
      (∃ (x : M.carrier), nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf) ↔
        (nf.2 sub_nf = true))
  -- Helper: membership in the quant clause list
  have quant_mem : ∀ sub_nf : NormalForm sig k 2,
      nf_quant_clause_tl (exist_tl_fn sub_nf) (nf.2 sub_nf) ∈
        List.map (fun sub_nf => nf_quant_clause_tl (exist_tl_fn sub_nf) (nf.2 sub_nf))
          Finset.univ.toList :=
    fun sub_nf => List.mem_map.mpr
      ⟨sub_nf, Finset.mem_toList.mpr (Finset.mem_univ sub_nf), rfl⟩
  constructor
  · -- Forward: all clauses hold → NF evaluation holds
    intro h_all
    constructor
    · -- Atom part: the head of the list is the atom formula
      have h_atom := h_all _ (.head _)
      rw [nf_depth0_char_formula_correct] at h_atom
      intro a
      obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred' a
      simp only [atom_eval]
      exact h_atom p
    · -- Quantifier part: each clause in the tail encodes the quantifier assignment
      intro sub_nf
      have h_clause := h_all _ (.tail _ (quant_mem sub_nf))
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _
        (h_exist_correct sub_nf M h_UZ h_SZ t)] at h_clause
      exact h_clause
  · -- Backward: NF evaluation holds → all clauses hold
    intro ⟨h_atoms, h_quants⟩ φ h_mem
    cases h_mem with
    | head => -- φ is the atom formula
      rw [nf_depth0_char_formula_correct]
      intro p
      exact (h_atoms (.pred p ⟨0, by omega⟩))
    | tail _ h_tail => -- φ is a quantifier clause
      obtain ⟨sub_nf, _, rfl⟩ := List.mem_map.mp h_tail
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _
        (h_exist_correct sub_nf M h_UZ h_SZ t)]
      exact h_quants sub_nf

/-! ## Part B at depth 0: Already done in NfToVecEA.lean

`nf_2var_exist_depth0_tl` proves the depth-0 case of Part B. We wrap it
to match the interface expected by the combined induction. -/

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

/-! ## Combined induction: Part A and Part B at all depths

The combined theorem proves both parts simultaneously by induction on k.
Part B at k > 0 requires infrastructure for arity-3 NF existentials
that is not yet available, so it is left as sorry with documentation. -/

/-- Combined induction proving Part A (arity-1 NF characterization) and
    Part B (arity-2 existential elimination) for Prior structures.

    Part A at depth k: every depth-k arity-1 NF has a temporal characteristic
    formula on Prior structures.

    Part B at depth k: every `∃ x, nf_eval_nf M k 2 (x::t) sub_nf` has a
    temporal formula equivalent on Prior structures. -/
noncomputable def nf_characterizable_temporal_prior_combined
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) →
    -- Part A: every depth-k arity-1 NF has a temporal characteristic formula
    (∀ (nf : NormalForm sig k 1),
      { A : Formula //
        ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          nf_eval_nf M k 1 (fun _ => t) nf }) ×
    -- Part B: every depth-k arity-2 existential has a temporal formula
    (∀ (sub_nf : NormalForm sig k 2),
      { A : Formula //
        ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf })
  | 0 =>
    -- Part A at depth 0: nf_depth0_char_formula
    (fun nf => ⟨nf_depth0_char_formula atomMap h_surj (fun a => nf a : NormalForm sig 0 1),
      fun M _ _ t => by
        rw [nf_depth0_char_formula_correct]
        simp only [nf_eval_nf]
        constructor
        · intro h a
          obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred' a
          simp only [atom_eval]; exact h p
        · intro h p
          exact (h (.pred p ⟨0, by omega⟩))⟩,
    -- Part B at depth 0: nf_2var_exist_depth0_tl
    fun sub_nf =>
      ⟨(nf_2var_exist_depth0_tl atomMap h_surj sub_nf).choose,
       fun M _ _ t =>
         (nf_2var_exist_depth0_tl atomMap h_surj sub_nf).choose_spec M t⟩)
  | k + 1 =>
    let ih := nf_characterizable_temporal_prior_combined atomMap h_surj k
    let ih_B := ih.2
    -- Build the Part B function at depth k (for use in Part A at depth k+1)
    let exist_tl_fn : NormalForm sig k 2 → Formula :=
      fun sub_nf => (ih_B sub_nf).val
    -- Part A at depth k+1: use nf_succ_char_formula with Part B IH
    (fun nf =>
      ⟨nf_succ_char_formula atomMap h_surj exist_tl_fn nf,
       fun M h_UZ h_SZ t =>
         nf_succ_char_formula_correct atomMap h_surj exist_tl_fn
           (fun sub_nf M' h_UZ' h_SZ' t' => (ih_B sub_nf).property M' h_UZ' h_SZ' t')
           nf M h_UZ h_SZ t⟩,
    -- Part B at depth k+1: use FOToVEA bridge (Rabinovich Prop 4.3)
    -- NF existential → nf_exist_to_temporal → Formula
    -- (works directly with NormalForm, bypasses MonadicFormula)
    fun sub_nf =>
      ⟨nf_exist_to_temporal atomMap h_surj sub_nf,
       fun M h_UZ h_SZ t =>
         nf_exist_to_temporal_correct atomMap h_surj sub_nf M h_UZ h_SZ t⟩)

/-! ## Extract Part A: the main theorem for use in KampPrior -/

/-- Part A of the combined induction: every depth-k arity-1 NF has a
    temporal characteristic formula on Prior structures.

    This is the replacement for the sorry at KampPrior.lean:158. -/
noncomputable def nf_characterizable_temporal_prior_partA
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔
        nf_eval_nf M k 1 (fun _ => t) nf } :=
  (nf_characterizable_temporal_prior_combined atomMap h_surj k).1 nf

end FormalSystem.Metalogic.WeakCanonical.Kamp

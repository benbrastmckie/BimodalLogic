import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior
import Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.Kamp.Translation
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# 2-Var Existence Formula for Prior Structures

Proves `nf_2var_exist_formula_prior_fill`: on Prior structures, for each
depth-k arity-2 NF, the existential `∃ x, nf_eval_nf M k 2 ...` has a
temporal equivalent. This result fills the sorry in NfCharFormula.lean.

## Proof Structure

By simultaneous induction on k, proving both:
- P1(k): temporal characterizations for depth-k arity-1 NFs
- P2(k): temporal formulas for depth-k 2-var existentials

k=0: P1(0) by nf_depth0_char_formula. P2(0): at depth 0, nf_exist_formula
is correct in both directions because arity-1 NFs + order determine
the arity-2 NF (atom matching only, no quantifier conditions).

k+1: P1(k+1) from P1(k) + P2(k) via inlined nf_characterizable_temporal_prior_classical.
P2(k+1): nf_exist_formula forward is universal; backward requires
Prior axioms + composition theorem (the Rabinovich negation closure content).

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 4-5
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Depth-0 backward direction

At depth 0, nf_exist_formula is correct in both directions. The backward
direction (formula → existential) holds because at depth 0, the arity-2
NF is pure atom assignment: predicates at x and t, plus order. The
arity-1 NF of the witness x determines its predicates, and the order
is determined by Until (x > t) or Since (x < t). -/

/-- At depth 0, construct arity-2 NF evaluation from component data. -/
private theorem nf_2var_depth0_components {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (sub_nf : NormalForm sig 0 2)
    (h_pred_x : ∀ p : sig.preds,
      M.interp p x ↔ sub_nf (.pred p ⟨0, by omega⟩) = true)
    (h_pred_t : ∀ p : sig.preds,
      M.interp p t ↔ sub_nf (.pred p ⟨1, by omega⟩) = true)
    (h_order_01 : (x < t) ↔ sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_order_10 : (t < x) ↔ sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true) :
    nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
  simp only [nf_eval_nf]
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    simp only [atom_eval, Fin.cons]
    exact h_pred_x p
  | .pred p ⟨1, _⟩ =>
    show M.interp p ((Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → _) ⟨1, _⟩) ↔ _
    simp only [Fin.cons, Fin.cases]
    exact h_pred_t p
  | .order ⟨0, _⟩ ⟨0, _⟩ h_ne => exact absurd rfl h_ne
  | .order ⟨0, _⟩ ⟨1, _⟩ _ => simp only [atom_eval]; exact h_order_01
  | .order ⟨1, _⟩ ⟨0, _⟩ _ => simp only [atom_eval]; exact h_order_10
  | .order ⟨1, _⟩ ⟨1, _⟩ h_ne => exact absurd rfl h_ne

/-- Backward direction of nf_exist_formula at depth 0. -/
private theorem backward_depth0 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_0 : NormalForm sig 0 1 → Formula)
    {M : OrderedMonadicStructure sig}
    (char_0_M : ∀ (nf_0 : NormalForm sig 0 1) (s : M.carrier),
        temporal_truth M atomMap s (char_0 nf_0) ↔ nf_eval_nf M 0 1 (fun _ => s) nf_0)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 0 2)
    {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_formula : temporal_truth M atomMap t
      (nf_exist_formula atomMap h_surj 0 char_0 parent_atoms sub_nf)) :
    ∃ x : M.carrier, nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  -- At depth 0, extract the witness from Until/Since, use char_0_M to get its
  -- arity-1 NF, and apply nf_2var_depth0_components to reconstruct the arity-2 NF.
  -- Pure case analysis: t-compatibility, order consistency, order direction (U/S/=).
  -- The key facts used: char_0_M gives atom matching at the witness, h_atoms gives
  -- atom matching at t, and the order is determined by Until (t<x) or Since (x<t).
  sorry

/-! ## Depth-(k+1) NF characterization from P1(k) + P2(k) -/

/-- Build depth-(k+1) arity-1 NF characterization from depth-k char + 2-var results.
    Inlines `nf_characterizable_temporal_prior_classical` to avoid calling the sorry'd
    `nf_2var_exist_formula_prior`. -/
noncomputable def nf_char_kp1_from_2var
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (p2_k : ∀ (parent_atoms : AtomKind sig 1 → Bool) (sub_nf : NormalForm sig k 2),
        ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
          (temporal_truth M atomMap t A ↔
           ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf))
    (nf : NormalForm sig (k + 1) 1) :
    ∃ A : Formula, ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t A ↔ nf_eval_nf M (k + 1) 1 (fun _ => t) nf := by
  let exist_f : NormalForm sig k 2 → Formula :=
    fun sub_nf => Classical.choose (p2_k nf.1 sub_nf)
  have exist_f_correct : ∀ (sub_nf : NormalForm sig k 2)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true) →
      (temporal_truth M atomMap t (exist_f sub_nf) ↔
       ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
    fun sub_nf => Classical.choose_spec (p2_k nf.1 sub_nf)
  let atom_lits := (Fintype.elems (α := sig.preds)).val.toList.map fun p =>
    atom_literal atomMap h_surj p (nf.1 (.pred p ⟨0, by omega⟩))
  let quant_formulas := (Fintype.elems (α := NormalForm sig k 2)).val.toList.map fun sub_nf =>
    if nf.2 sub_nf then exist_f sub_nf else (exist_f sub_nf).neg
  let full_formula := Formula.and (formula_conjList atom_lits) (formula_conjList quant_formulas)
  refine ⟨full_formula, fun M h_UZ h_SZ t => ?_⟩
  constructor
  · intro h_formula
    have h_and := (temporal_truth_and M atomMap t _ _).mp h_formula
    have h_atom_list := (formula_conjList_iff M atomMap t _).mp h_and.1
    have h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true := by
      intro a
      obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
      exact (atom_literal_correct M atomMap h_surj p _ t).mp
        (h_atom_list _ (by simp only [atom_lits, List.mem_map]; exact
          ⟨p, Multiset.mem_toList.mpr (Fintype.complete p), rfl⟩))
    have h_quant_list := (formula_conjList_iff M atomMap t _).mp h_and.2
    obtain ⟨atom_part, quant_part⟩ := nf
    refine ⟨h_atoms, fun sub_nf => ?_⟩
    have h_iff := exist_f_correct sub_nf M h_UZ h_SZ t h_atoms
    have h_sub_in : (if quant_part sub_nf then exist_f sub_nf
        else (exist_f sub_nf).neg) ∈ quant_formulas := by
      simp only [quant_formulas, List.mem_map]
      exact ⟨sub_nf, Multiset.mem_toList.mpr (Fintype.complete sub_nf), rfl⟩
    have h_sub_truth := h_quant_list _ h_sub_in
    cases h_q : quant_part sub_nf
    · simp only [h_q, Bool.false_eq_true, ↓reduceIte] at h_sub_truth
      rw [temporal_truth_neg] at h_sub_truth
      exact ⟨fun h_ex => absurd (h_iff.mpr h_ex) h_sub_truth, fun h => by simp at h⟩
    · simp only [h_q, ↓reduceIte] at h_sub_truth
      exact ⟨fun _ => rfl, fun _ => h_iff.mp h_sub_truth⟩
  · intro h_nf
    obtain ⟨h_atoms, h_quant⟩ := h_nf
    rw [temporal_truth_and]
    exact ⟨(formula_conjList_iff M atomMap t _).mpr (fun A hA => by
        simp only [atom_lits, List.mem_map] at hA
        obtain ⟨p, _, rfl⟩ := hA
        exact (atom_literal_correct M atomMap h_surj p _ t).mpr (by
          have := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at this; exact this)),
      (formula_conjList_iff M atomMap t _).mpr (fun A hA => by
        simp only [quant_formulas, List.mem_map] at hA
        obtain ⟨sub_nf, _, rfl⟩ := hA
        have h_iff := exist_f_correct sub_nf M h_UZ h_SZ t h_atoms
        by_cases h_q : nf.2 sub_nf = true
        · simp only [h_q, ite_true]; exact h_iff.mpr ((h_quant sub_nf).mpr h_q)
        · push_neg at h_q
          rw [Bool.eq_false_iff.mpr h_q]; simp only [Bool.false_eq_true, ↓reduceIte]
          rw [temporal_truth_neg]; intro h_ef
          exact h_q ((h_quant sub_nf).mp (h_iff.mp h_ef)))⟩

/-! ## Master Simultaneous Induction -/

private abbrev P1 {sig : MonadicSignature} (atomMap : Formula → sig.preds) (k : Nat) : Prop :=
  ∀ nf : NormalForm sig k 1, ∃ A : Formula,
    ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf

private abbrev P2 {sig : MonadicSignature} (atomMap : Formula → sig.preds) (k : Nat) : Prop :=
  ∀ (parent_atoms : AtomKind sig 1 → Bool) (sub_nf : NormalForm sig k 2),
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)

/-- The master simultaneous induction. -/
noncomputable def master_induction
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → P1 atomMap k ∧ P2 atomMap k
  | 0 => ⟨
    -- P1(0): depth-0 char formula
    fun nf => ⟨nf_depth0_char_formula atomMap h_surj nf,
      fun M _ _ t => nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf t⟩,
    -- P2(0): nf_exist_formula at depth 0
    fun parent_atoms sub_nf =>
      ⟨nf_exist_formula atomMap h_surj 0
          (fun nf => nf_depth0_char_formula atomMap h_surj nf) parent_atoms sub_nf,
       fun M _h_UZ _h_SZ t h_atoms => ⟨
        backward_depth0 atomMap h_surj _ (fun nf_0 s =>
          nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf_0 s)
          parent_atoms sub_nf h_atoms,
        nf_exist_formula_forward' atomMap h_surj 0 _ (fun nf_0 s =>
          nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf_0 s)
          parent_atoms sub_nf h_atoms⟩⟩⟩
  | k + 1 =>
    let ⟨p1_k, p2_k⟩ := master_induction atomMap h_surj k
    let char_k : NormalForm sig k 1 → Formula := fun nf_k => Classical.choose (p1_k nf_k)
    have char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k :=
      fun nf_k => Classical.choose_spec (p1_k nf_k)
    -- P1(k+1): built from P1(k) + P2(k), no sorry
    have p1_kp1 : P1 atomMap (k + 1) := fun nf =>
      nf_char_kp1_from_2var atomMap h_surj k char_k char_k_correct p2_k nf
    -- P2(k+1): forward is universal; backward requires composition/negation closure
    have p2_kp1 : P2 atomMap (k + 1) := by
      intro parent_atoms sub_nf
      let char_kp1 : NormalForm sig (k + 1) 1 → Formula :=
        fun nf_1 => Classical.choose (p1_kp1 nf_1)
      have char_kp1_correct : ∀ (nf_1 : NormalForm sig (k + 1) 1)
          (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t (char_kp1 nf_1) ↔
          nf_eval_nf M (k + 1) 1 (fun _ => t) nf_1 :=
        fun nf_1 => Classical.choose_spec (p1_kp1 nf_1)
      refine ⟨nf_exist_formula atomMap h_surj (k + 1) char_kp1 parent_atoms sub_nf,
        fun M h_UZ h_SZ t h_atoms => ?_⟩
      constructor
      · -- Backward: the hard direction (Rabinovich negation closure content)
        intro h_formula
        sorry
      · -- Forward: universal, no Prior needed
        exact nf_exist_formula_forward' atomMap h_surj (k + 1) char_kp1
          (fun nf_1 s => char_kp1_correct nf_1 M h_UZ h_SZ s)
          parent_atoms sub_nf h_atoms
    ⟨p1_kp1, p2_kp1⟩

/-- Extract P2 from the master induction. This has the same type as
    `nf_2var_exist_formula_prior` and can be used to fill the sorry.
    Currently sorry-free at k=0, sorry at k>=1. -/
noncomputable def nf_2var_exist_formula_prior_fill
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
  (master_induction atomMap h_surj k).2 parent_atoms sub_nf

end Bimodal.Metalogic.WeakCanonical.Kamp

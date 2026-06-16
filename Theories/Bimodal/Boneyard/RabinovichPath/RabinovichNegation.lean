-- ARCHIVED from Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean
-- Reason: Dead code — Rabinovich approach path with no live downstream consumers
-- Archived: 2026-06-16 (task 302)

#exit

import Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichTranslation

/-!
# Rabinovich Negation Closure (Proposition 4.2)

Provides `nf_2var_exist_formula_prior_neg`, a drop-in replacement for the
sorry in `nf_2var_exist_formula_prior` (NfCharFormula.lean).

## Results

- `nf_exist_backward_depth0`: backward direction of nf_exist_formula at depth 0
- `nf_2var_exist_formula_prior_neg`: fills `nf_2var_exist_formula_prior`
  - Sorry-free at depth 0 (backward proved directly, no Prior needed)
  - Sorry at depth k+1 (requires arity-climbing induction)

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.2 and Section 5
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Depth-0 Backward Direction

At depth 0, the backward direction of nf_exist_formula is provable on ALL
structures (no Prior-UZ/SZ needed) because depth-0 NFs have no quantifier
conditions -- only atom/order conditions. -/

/-- Extract the variable-0 predicate assignment from a 2-var depth-0 NF,
    viewed as an arity-1 NF. -/
private noncomputable def nf_x_proj {sig : MonadicSignature}
    (sub_nf : NormalForm sig 0 2) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => sub_nf (.pred p ⟨0, by omega⟩)
  | .order i j h => by exact absurd (Fin.ext (by omega) : i = j) h

/-- At depth 0, the filtered witness-type formula truth at x implies that x
    satisfies the x-projection NF. -/
private theorem extract_witness_nf {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (_h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_0 : NormalForm sig 0 1 → Formula)
    {M : OrderedMonadicStructure sig}
    (char_0_correct_M : ∀ (nf_0 : NormalForm sig 0 1) (t : M.carrier),
        temporal_truth M atomMap t (char_0 nf_0) ↔
        nf_eval_nf M 0 1 (fun _ => t) nf_0)
    (sub_nf : NormalForm sig 0 2) (x : M.carrier)
    (h_wt : temporal_truth M atomMap x (formula_disjList
      ((Fintype.elems (α := NormalForm sig 0 1)).val.toList.filterMap fun nf_x =>
        if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
          nf_x (.pred p ⟨0, by omega⟩) == sub_nf (.pred p ⟨0, by omega⟩))
        then some (char_0 nf_x) else none))) :
    nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj sub_nf) := by
  have h_disj := (formula_disjList_iff M atomMap x _).mp h_wt
  obtain ⟨f, h_f_mem, h_f_true⟩ := h_disj
  rw [List.mem_filterMap] at h_f_mem
  obtain ⟨nf_x, _, h_if⟩ := h_f_mem
  split at h_if <;> simp at h_if
  rename_i h_compat
  rw [← h_if] at h_f_true
  have h_nf_x := (char_0_correct_M nf_x x).mp h_f_true
  intro a
  match a with
  | .pred p _ =>
    have h_nf_x_p := h_nf_x (.pred p ⟨0, by omega⟩)
    rw [List.all_eq_true] at h_compat
    have h_p_mem : p ∈ (Fintype.elems (α := sig.preds)).val.toList :=
      Multiset.mem_toList.mpr (Fintype.complete p)
    have h_eq := h_compat p h_p_mem
    simp only [beq_iff_eq] at h_eq
    simp only [nf_x_proj] at h_nf_x_p ⊢
    rw [h_eq] at h_nf_x_p
    exact h_nf_x_p
  | .order i j h_neq =>
    have hi : i = ⟨0, by omega⟩ := Fin.ext (by omega)
    have hj : j = ⟨0, by omega⟩ := Fin.ext (by omega)
    exact absurd (hi ▸ hj ▸ rfl) h_neq

/-- Reconstruct the full 2-var depth-0 NF evaluation from component conditions. -/
private theorem reconstruct_depth0 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 0 2)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier)
    (h_x_nf : nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj sub_nf))
    (h_t_atoms : ∀ (a : AtomKind sig 1),
        atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_t_compat : nf_t_compat parent_atoms sub_nf = true)
    (h_order_01 : (x < t) ↔
        (sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true))
    (h_order_10 : (t < x) ↔
        (sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)) :
    nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- Extract t-compat as pointwise equality
  simp only [nf_t_compat] at h_t_compat
  have h_tc_all := List.all_eq_true.mp h_t_compat
  -- Fin.cons evaluation helpers
  have hfc0 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨0, by omega⟩ = x := by
    simp [Fin.cons]
  have hfc1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
    simp [Fin.cons]; rfl
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    have := h_x_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons] at this ⊢
    exact this
  | .pred p ⟨1, hi⟩ =>
    simp only [atom_eval]
    rw [hfc1]
    have h_p_mem : p ∈ (Fintype.elems (α := sig.preds)).val.toList :=
      Multiset.mem_toList.mpr (Fintype.complete p)
    have h_beq := h_tc_all p h_p_mem
    have aa_eq : sub_nf.atom_assgn = sub_nf := rfl
    rw [aa_eq] at h_beq
    have h_par := h_t_atoms (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at h_par
    cases hv : sub_nf (.pred p ⟨1, by omega⟩) <;>
    cases hv2 : parent_atoms (.pred p ⟨0, by omega⟩) <;>
    simp_all
  | .pred _ ⟨n + 2, h⟩ => exact absurd h (by omega)
  | .order ⟨0, _⟩ ⟨0, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
    simp only [atom_eval]; rw [hfc0, hfc1]; exact h_order_01
  | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
    simp only [atom_eval]; rw [hfc1, hfc0]; exact h_order_10
  | .order ⟨1, _⟩ ⟨1, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨0, _⟩ ⟨n + 2, h⟩ _ => exact absurd h (by omega)
  | .order ⟨1, _⟩ ⟨n + 2, h⟩ _ => exact absurd h (by omega)
  | .order ⟨n + 2, h⟩ _ _ => exact absurd h (by omega)

/-- Backward direction of nf_exist_formula at depth 0: if the temporal
    existence formula holds at t, then there exists x satisfying the
    2-var NF. Works on ALL structures (no Prior needed). -/
theorem nf_exist_backward_depth0
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_0 : NormalForm sig 0 1 → Formula)
    {M : OrderedMonadicStructure sig}
    (char_0_correct_M : ∀ (nf_0 : NormalForm sig 0 1) (t : M.carrier),
        temporal_truth M atomMap t (char_0 nf_0) ↔
        nf_eval_nf M 0 1 (fun _ => t) nf_0)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 0 2)
    {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1),
        atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_formula : temporal_truth M atomMap t
        (nf_exist_formula atomMap h_surj 0 char_0 parent_atoms sub_nf)) :
    ∃ x : M.carrier,
      nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  -- atom_assgn at depth 0 is identity
  have atom_assgn_eq : sub_nf.atom_assgn = sub_nf := rfl
  -- Unfold nf_exist_formula
  unfold nf_exist_formula at h_formula
  simp only [atom_assgn_eq] at h_formula
  -- Case split on t-compatibility
  by_cases h_tc : nf_t_compat parent_atoms sub_nf = true
  · simp only [h_tc, not_true_eq_false, ↓reduceIte] at h_formula
    -- Case split on both-orders
    by_cases h_both : (sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
        sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))) = true
    · simp only [h_both, ↓reduceIte, temporal_truth] at h_formula
    · simp only [h_both] at h_formula
      -- Case split on order direction
      unfold nf_order_dir at h_formula
      simp only [atom_assgn_eq] at h_formula
      -- Name the order booleans
      match h_b1 : sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
            h_b2 : sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
      | true, false =>
        -- t < x direction: Until case
        simp only [h_b1, h_b2, Bool.false_eq_true, ↓reduceIte, temporal_truth] at h_formula
        obtain ⟨x, h_lt, h_wt, _⟩ := h_formula
        have h_nf_x := extract_witness_nf atomMap h_surj char_0
          char_0_correct_M sub_nf x h_wt
        refine ⟨x, ?_⟩
        apply reconstruct_depth0 M sub_nf parent_atoms x t h_nf_x h_atoms h_tc
        · -- x < t ↔ sub_nf(.order 0 1) = true. But sub_nf(.order 0 1) = false
          constructor
          · intro h_xlt; exact absurd (lt_trans h_xlt h_lt) (lt_irrefl _)
          · intro h_eq; rw [h_b2] at h_eq; exact Bool.noConfusion h_eq
        · -- t < x ↔ sub_nf(.order 1 0) = true. sub_nf(.order 1 0) = true
          constructor
          · intro _; exact h_b1
          · intro _; exact h_lt
      | false, true =>
        -- x < t direction: Since case
        simp only [h_b1, h_b2, Bool.false_eq_true, ↓reduceIte, temporal_truth] at h_formula
        obtain ⟨x, h_lt, h_wt, _⟩ := h_formula
        have h_nf_x := extract_witness_nf atomMap h_surj char_0
          char_0_correct_M sub_nf x h_wt
        refine ⟨x, ?_⟩
        apply reconstruct_depth0 M sub_nf parent_atoms x t h_nf_x h_atoms h_tc
        · -- x < t ↔ sub_nf(.order 0 1) = true. sub_nf(.order 0 1) = true
          constructor
          · intro _; exact h_b2
          · intro _; exact h_lt
        · -- t < x ↔ sub_nf(.order 1 0) = true. sub_nf(.order 1 0) = false
          constructor
          · intro h_tlt; exact absurd (lt_trans h_lt h_tlt) (lt_irrefl _)
          · intro h_eq; rw [h_b1] at h_eq; exact Bool.noConfusion h_eq
      | false, false =>
        -- x = t case
        simp only [h_b1, h_b2, Bool.false_eq_true, beq_self_eq_true, Bool.and_self,
          ↓reduceIte] at h_formula
        have h_nf_x := extract_witness_nf atomMap h_surj char_0
          char_0_correct_M sub_nf t h_formula
        refine ⟨t, ?_⟩
        apply reconstruct_depth0 M sub_nf parent_atoms t t h_nf_x h_atoms h_tc
        · constructor
          · intro h; exact absurd h (lt_irrefl _)
          · intro h_eq; rw [h_b2] at h_eq; exact Bool.noConfusion h_eq
        · constructor
          · intro h; exact absurd h (lt_irrefl _)
          · intro h_eq; rw [h_b1] at h_eq; exact Bool.noConfusion h_eq
      | true, true =>
        exfalso; exact h_both (by rw [Bool.and_eq_true]; exact ⟨h_b2, h_b1⟩)
  · simp only [h_tc, Bool.not_eq_true, ↓reduceIte] at h_formula
    exact absurd h_formula id

/-! ## Main Theorem -/

/-- For Prior structures, there exists a temporal formula correctly characterizing
    the realizability of each 2-variable sub-NF.

    Drop-in replacement for `nf_2var_exist_formula_prior` (NfCharFormula.lean).

    Sorry-free at depth 0; sorry at depth k+1 (requires arity generalization
    of the Rabinovich negation closure argument). -/
theorem nf_2var_exist_formula_prior_neg
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
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
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Delegate to the enriched bypass at all depths.
  -- At depth 0: the bypass delegates to nf_2var_exist_depth0_tl (sorry-free).
  -- At depth k+1: the bypass uses the enriched formula approach.
  cases k with
  | zero =>
    -- Depth 0: use VecEA2-based decomposition (sorry-free)
    obtain ⟨A, hA⟩ := nf_2var_exist_depth0_tl atomMap h_surj sub_nf
    exact ⟨A, fun M _ _ t _ => hA M t⟩
  | succ k' =>
    -- Depth k'+1: use the enriched bypass formula
    exact existPart_succ_n1_bypass atomMap h_surj k' char_k char_k_correct
      parent_atoms sub_nf

end Bimodal.Metalogic.WeakCanonical.Kamp

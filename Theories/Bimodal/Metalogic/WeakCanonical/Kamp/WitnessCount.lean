import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Table

/-!
# Temporal Truth Transfer and Operator Depth Infrastructure

Reusable infrastructure for cross-structure temporal truth transfer and
operator_depth analysis.

## Theorems (sorry-free)

1. `temporal_truth_transfer`: depth-k 1-var NF agreement transfers temporal
   formulas of operator_depth ≤ k. Uses `table_correctness` + `doets_lemma_1_1`.

2. `depth2_quant_transfer`: from depth-2 1-var NF agreement at a single point,
   derive depth-1 2-var existential transfer at CONSTANT env [w, t] / [w', t'].

3. `nf_depth0_char_operator_depth`: nf_depth0_char_formula has operator_depth 0.

4. `nf_depth0_char_iff_eval`: nf_depth0_char_formula ↔ nf_eval_nf at depth 0.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Temporal Truth Transfer -/

/-- Temporal truth transfer: depth-k 1-var NF agreement at t/t' implies
    temporal truth agreement for formulas of operator_depth ≤ k.

    This is a consequence of the fundamental Doets lemma (1.1): if two
    structures agree on all NFs of sufficient depth and arity, they agree
    on all temporal formulas of bounded operator depth. -/
theorem temporal_truth_transfer {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (k : Nat)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (t' : N.carrier)
    (h_agree : ∀ nf : NormalForm sig k 1,
      nf_eval_nf M k 1 (fun _ => t) nf ↔
      nf_eval_nf N k 1 (fun _ => t') nf)
    (A : Formula) (h_depth : operator_depth A ≤ k) :
    temporal_truth M atomMap t A ↔ temporal_truth N atomMap t' A := by
  have h_M := table_correctness M atomMap t A
  have h_N := table_correctness N atomMap t' A
  have h_tdb := table_depth_bound sig atomMap A
  have h_doets := doets_lemma_1_1 k 1 (table sig atomMap A)
    (by omega) M N (fun _ => t) (fun _ => t') h_agree
  exact h_M.symm.trans (h_doets.trans h_N)

/-! ## Quantifier Transfer from Depth-2 1-var Agreement

   This transfer works at CONSTANT environments: it shows that depth-1
   2-var existentials transfer between structures when both structures
   agree on depth-2 1-var NFs at a single common base point.

   **Critical distinction**: This does NOT handle non-constant environments
   [x, t] with x ≠ t. The non-constant environment case is the zone-3
   problem that is genuinely impossible via cross-structure NF transfer. -/

/-- From depth-2 1-var NF agreement at a single point, derive depth-1
    2-var existential transfer at constant env [w, t] / [w', t']. -/
theorem depth2_quant_transfer {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (t' : N.carrier)
    (h_agree : ∀ nf : NormalForm sig 2 1,
      nf_eval_nf M 2 1 (fun _ => t) nf ↔
      nf_eval_nf N 2 1 (fun _ => t') nf) :
    ∀ sub : NormalForm sig 1 2,
      (∃ w : M.carrier, nf_eval_nf M 1 2 (Fin.cons w (fun _ => t)) sub) ↔
      (∃ w' : N.carrier, nf_eval_nf N 1 2 (Fin.cons w' (fun _ => t')) sub) := by
  intro sub
  set nf_t := nf_characteristic M 2 1 (fun _ => t)
  have h_t_sat := nf_characteristic_satisfies M 2 1 (fun _ => t)
  have h_t'_nf_t : nf_eval_nf N 2 1 (fun _ => t') nf_t :=
    (h_agree nf_t).mp h_t_sat
  obtain ⟨_, h_quant_M⟩ := h_t_sat
  obtain ⟨_, h_quant_N⟩ := h_t'_nf_t
  rw [h_quant_M sub, h_quant_N sub]

/-! ## Operator Depth Bounds -/

private theorem atom_literal_operator_depth
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (p : sig.preds) (val : Bool) :
    operator_depth (atom_literal atomMap h_surj p val) = 0 := by
  simp only [atom_literal]
  cases val <;> simp [operator_depth, Formula.neg]

private theorem formula_conjList_operator_depth
    (fs : List Formula)
    (h_all : ∀ f ∈ fs, operator_depth f = 0) :
    operator_depth (formula_conjList fs) = 0 := by
  induction fs with
  | nil => simp [formula_conjList, Formula.top, operator_depth]
  | cons f rest ih =>
    simp only [formula_conjList, Formula.and, Formula.neg, operator_depth]
    rw [h_all f (by simp)]
    rw [ih (fun g hg => h_all g (by simp [hg]))]
    simp

theorem nf_depth0_char_operator_depth
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf_0 : NormalForm sig 0 1) :
    operator_depth (nf_depth0_char_formula atomMap h_surj nf_0) = 0 := by
  apply formula_conjList_operator_depth
  intro f hf
  simp only [List.mem_map] at hf
  obtain ⟨p, _, rfl⟩ := hf
  exact atom_literal_operator_depth atomMap h_surj p _

/-! ## Char formula ↔ nf_eval_nf at depth 0 -/

/-- The depth-0 characteristic formula for a 1-var NF correctly captures
    the NF evaluation at depth 0. -/
theorem nf_depth0_char_iff_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf_0 : NormalForm sig 0 1) (t : M.carrier) :
    temporal_truth M atomMap t (nf_depth0_char_formula atomMap h_surj nf_0) ↔
    nf_eval_nf M 0 1 (fun _ => t) nf_0 := by
  rw [nf_depth0_char_formula_correct]
  constructor
  · intro h a
    match a with
    | .pred p i =>
      simp only [atom_eval]
      have hi : i = ⟨0, by omega⟩ := Fin.ext (by omega)
      subst hi
      exact h p
    | .order i j h_neq =>
      exact absurd (Fin.ext (by omega) : i = j) h_neq
  · intro h p
    have := h (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at this
    exact this

end Bimodal.Metalogic.WeakCanonical.Kamp

import FormalSystem.Metalogic.WeakCanonical.Kamp.KampBypassCore

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Enriched Bypass: Equality Case (x = t)

When the NF says x = t (no strict order between them), the 2-var existential
reduces to depth-1 constant-env evaluation at [t, t]. This file proves the
equality case of the enriched bypass formula.

Split from KampBypassCore.lean for modularity.
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

attribute [local simp] enriched_bypass_eq nf_x_compat_check ssn_xt_compatible

/-! ## Helper: witness must equal t when both orders are false -/

private theorem witness_eq_t_of_no_order {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 1 2) (t x : M.carrier)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_eval : nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf) :
    x = t := by
  obtain ⟨h_atom, _⟩ := h_eval
  by_contra h_ne
  rcases lt_or_gt_of_ne h_ne with h' | h'
  · have := (h_atom (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mp
    simp only [atom_eval, Fin.cons] at this
    exact Bool.noConfusion (h_lt ▸ this h')
  · have := (h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
    simp only [atom_eval, Fin.cons] at this
    exact Bool.noConfusion (h_gt ▸ this h')

/-! ## Eq-case order consistency

When ssn_xt_compatible ... false false = true, the equality consistency
clause gives yx = yt and xy = ty. -/

set_option maxHeartbeats 1600000 in
private theorem eq_case_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true) :
    ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
      ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
      ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) := by
  -- Extract xt and tx from compatibility
  have h1 : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true := h_compat
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h1
  have h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := h1.1.2
  have h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false := h1.1.1.2
  refine ⟨h_xt, h_tx, ?_, ?_⟩
  all_goals {
    have h_consist : ssn_order_consistent ssn = true := h1.2
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_consist
    have h_last := h_consist.2
    rcases h_last with ⟨h | h⟩ | h_eq
    · simp_all
    · simp_all
    · first | exact h_eq.1 | exact h_eq.2
  }

/-! ## Eq-case zone bridges (x = t)

When x = t, the 3-var existential ∃ y, nf_eval_nf M 0 3 [y,t,t] ssn
has three zones: y < t (Since), y = t (direct), y > t (Until).
Unlike the Until/Since zone bridges, these do NOT require t < x. -/

/-- Eq-case zone bridge for y < t: Since(char_y, top) at t ↔ ∃ y, nf_eval with y < t. -/
private theorem eq_case_zone_below
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (parent_atoms : AtomKind sig 1 → Bool)
    (t : M.carrier)
    -- ssn says y < x (= y < t since x=t)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    -- ssn says ¬(x < y)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    -- ssn says x = t orders
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    -- x-pred matches t-pred in ssn (from eq_case_orders)
    (h_yx_eq_yt : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
                  ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)))
    (h_xy_eq_ty : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
                  ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)))
    -- t predicates match ssn at var 1 and var 2
    (h_t_pred_1 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_pred_2 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    temporal_truth M atomMap t
      (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons t (fun _ => t))) ssn) := by
  -- h_yx = true, so h_yt = true (from h_yx_eq_yt)
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
    rw [← h_yx_eq_yt]; exact h_yx
  -- h_xy = false, so h_ty = false (from h_xy_eq_ty)
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    rw [← h_xy_eq_ty]; exact h_xy
  constructor
  · -- Forward: Since(char_y, top) at t → ∃ y, nf_eval
    intro ⟨y, h_y_lt_t, h_char_y, _⟩
    refine ⟨y, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    apply reconstruct_nf_eval_3var M ssn y t t
    · exact h_char_y
    · exact h_t_pred_1
    · exact h_t_pred_2
    · -- y < x (= t) ↔ true
      exact ⟨fun _ => h_yx, fun _ => h_y_lt_t⟩
    · -- y < t ↔ true
      exact ⟨fun _ => h_yt, fun _ => h_y_lt_t⟩
    · -- x (= t) < y ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_y_lt_t h) (lt_irrefl _)
      · intro h; simp_all
    · -- x < t ↔ false (x = t)
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
    · -- t < y ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_y_lt_t h) (lt_irrefl _)
      · intro h; simp_all
    · -- t < x ↔ false (x = t)
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
  · -- Backward: ∃ y, nf_eval → Since(char_y, top) at t
    intro ⟨y, h_nf⟩
    have h_y_lt_t : y < t := by
      have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact h_ord.mpr h_yt
    refine ⟨y, h_y_lt_t, ?_, fun z _ _ => by simp [temporal_truth, Formula.top]⟩
    rw [nf_depth0_char_formula_correct]
    exact extract_y_preds M ssn y t t h_nf

/-- Eq-case zone bridge for y > t: Until(char_y, top) at t ↔ ∃ y, nf_eval with y > t. -/
private theorem eq_case_zone_above
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (parent_atoms : AtomKind sig 1 → Bool)
    (t : M.carrier)
    -- ssn says x < y (= t < y since x=t)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    -- ssn says ¬(y < x)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    -- ssn says x = t orders
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    -- order consistency between vars 0,1 and vars 0,2 (from eq_case_orders)
    (h_yx_eq_yt : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
                  ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)))
    (h_xy_eq_ty : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
                  ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)))
    -- t predicates match ssn at var 1 and var 2
    (h_t_pred_1 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_pred_2 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    temporal_truth M atomMap t
      (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons t (fun _ => t))) ssn) := by
  -- h_xy = true, so h_ty = true
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
    rw [← h_xy_eq_ty]; exact h_xy
  -- h_yx = false, so h_yt = false
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
    rw [← h_yx_eq_yt]; exact h_yx
  constructor
  · -- Forward: Until(char_y, top) at t → ∃ y, nf_eval
    intro ⟨y, h_t_lt_y, h_char_y, _⟩
    refine ⟨y, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    apply reconstruct_nf_eval_3var M ssn y t t
    · exact h_char_y
    · exact h_t_pred_1
    · exact h_t_pred_2
    · -- y < x (= t) ↔ false
      constructor
      · intro h; exact absurd (lt_trans h h_t_lt_y) (lt_irrefl _)
      · intro h; simp_all
    · -- y < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h h_t_lt_y) (lt_irrefl _)
      · intro h; simp_all
    · -- x (= t) < y ↔ true
      exact ⟨fun _ => h_xy, fun _ => h_t_lt_y⟩
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
    · -- t < y ↔ true
      exact ⟨fun _ => h_ty, fun _ => h_t_lt_y⟩
    · -- t < x ↔ false
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
  · -- Backward: ∃ y, nf_eval → Until(char_y, top) at t
    intro ⟨y, h_nf⟩
    have h_t_lt_y : t < y := by
      have h_ord := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact h_ord.mpr h_ty
    refine ⟨y, h_t_lt_y, ?_, fun z _ _ => by simp [temporal_truth, Formula.top]⟩
    rw [nf_depth0_char_formula_correct]
    exact extract_y_preds M ssn y t t h_nf

/-- Eq-case zone bridge for y = t: char_y at t ↔ ∃ y, nf_eval with y = t. -/
private theorem eq_case_zone_eq
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (parent_atoms : AtomKind sig 1 → Bool)
    (t : M.carrier)
    -- ssn says y = x (both orders false)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    -- ssn says x = t orders
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    -- order consistency
    (h_yx_eq_yt : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
                  ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)))
    (h_xy_eq_ty : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
                  ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)))
    -- t predicates match ssn at var 1 and var 2
    (h_t_pred_1 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_pred_2 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons t (fun _ => t))) ssn) := by
  -- y = t since ¬(y<x) ∧ ¬(x<y) and x=t
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
    rw [← h_yx_eq_yt]; exact h_yx
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    rw [← h_xy_eq_ty]; exact h_xy
  constructor
  · -- Forward: char_y at t → ∃ y, nf_eval (use y = t)
    intro h_char
    refine ⟨t, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char
    apply reconstruct_nf_eval_3var M ssn t t t
    · exact h_char
    · exact h_t_pred_1
    · exact h_t_pred_2
    · -- y < x (= t < t) ↔ h_yx = true: both sides false
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- y < t (= t < t) ↔ h_yt = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- x < y (= t < t) ↔ h_xy = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- x < t (= t < t) ↔ h_xt = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- t < y (= t < t) ↔ h_ty = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- t < x (= t < t) ↔ h_tx = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
  · -- Backward: ∃ y, nf_eval → char_y at t
    intro ⟨y, h_nf⟩
    -- y = t
    have h_not_yt : ¬(y < t) := by
      intro h
      have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact absurd (h_ord.mp h) (by simp_all)
    have h_not_ty : ¬(t < y) := by
      intro h
      have h_ord := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact absurd (h_ord.mp h) (by simp_all)
    have h_eq : y = t := le_antisymm (le_of_not_gt h_not_ty) (le_of_not_gt h_not_yt)
    subst h_eq
    rw [nf_depth0_char_formula_correct]
    exact extract_y_preds M ssn y y y h_nf

/-! ## Equality Case: Core Biconditional -/

/-- Extract t-predicate hypotheses for ssn from h_atoms and h_t_compat.
    Given that h_atoms : ∀ a, atom_eval M [t] a ↔ parent_atoms a = true
    and h_t_compat : sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0)
    and ssn_xt_compatible ssn ... false false = true (which gives ssn (.pred p 2) = parent_atoms (.pred p 0)),
    we derive M.interp p t ↔ ssn (.pred p 1) = true and M.interp p t ↔ ssn (.pred p 2) = true. -/
private theorem eq_case_t_pred_1
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (nf_x : NormalForm sig 1 1)
    (h_nf_x : nf_eval_nf M 1 1 (fun _ => t) nf_x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true)
    (h_nf_x_1var_def : ∀ p, nf_x_1var (.pred p ⟨0, by omega⟩) =
      nf_x.1 (.pred p ⟨0, by omega⟩)) :
    ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true := by
  intro p
  -- ssn_xt_compatible gives ssn (.pred p 1) = nf_x_1var (.pred p 0)
  have h1 : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true := h_compat
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h1
  have h_x_pred := h1.1.1.1.1 p (Multiset.mem_toList.mpr (Fintype.complete p))
  -- nf_x_1var (.pred p 0) = nf_x.1 (.pred p 0)
  rw [h_nf_x_1var_def p] at h_x_pred
  -- From h_nf_x: atom_eval M [t] (.pred p 0) ↔ nf_x.1 (.pred p 0) = true
  obtain ⟨h_atom_x, _⟩ := h_nf_x
  have h_eval_p := h_atom_x (.pred p ⟨0, by omega⟩)
  simp only [atom_eval] at h_eval_p
  simp only [h_x_pred]
  exact h_eval_p

private theorem eq_case_t_pred_2
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (parent_atoms : AtomKind sig 1 → Bool)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true) :
    ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
  intro p
  have h1 : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true := h_compat
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h1
  have h_t_pred := h1.1.1.1.2 p (Multiset.mem_toList.mpr (Fintype.complete p))
  have h_par := h_atoms (.pred p ⟨0, by omega⟩)
  simp only [atom_eval] at h_par
  simp only [h_t_pred]; exact h_par

set_option maxHeartbeats 12800000 in
/-- Core biconditional for the eq case: enriched_bypass_eq ↔ ∃ x, nf_eval with x = t. -/
private theorem eq_case_iff
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (char_1_correct : ∀ (nf_1 : NormalForm sig 1 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_1 nf_1) ↔
        nf_eval_nf M 1 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_pred_compat : ∀ p : sig.preds,
        sub_nf.1 (.pred p ⟨0, by omega⟩) = sub_nf.1 (.pred p ⟨1, by omega⟩))
    (h_t_compat : ∀ p : sig.preds,
        sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩))
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    -- All ssn with sub_nf.2 = true must be compatible with the reference nf_x_1var
    (h_ssn_compat : ∀ ssn : NormalForm sig 0 3, sub_nf.2 ssn = true →
        ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
        parent_atoms false false = true) :
    temporal_truth M atomMap t (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms) ↔
    ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  constructor
  · -- Forward (mp): formula truth → ∃ x, nf_eval
    -- We first reduce to showing ∃ x = t, then both atom and quant parts.
    -- The formula unfolding is done once:
    intro h_formula
    show ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
    -- For any realizable witness x, x = t (by witness_eq_t_of_no_order).
    -- So we provide t and prove nf_eval at [t, t].
    -- Unfold the formula to get the disjunct.
    have h_formula' := h_formula
    show ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
    simp only [enriched_bypass_eq] at h_formula'
    rw [formula_disjList_iff] at h_formula'
    obtain ⟨φ, h_mem, h_truth⟩ := h_formula'
    rw [List.mem_filterMap] at h_mem
    obtain ⟨nf_x, _, h_some⟩ := h_mem
    split_ifs at h_some with h_compat_nfx
    · have h_eq_φ := Option.some_injective _ h_some; subst h_eq_φ
      rw [temporal_truth_and] at h_truth
      obtain ⟨h_char1, h_conj⟩ := h_truth
      have h_nf_x := (char_1_correct nf_x M h_UZ h_SZ t).mp h_char1
      -- Witness is t.
      refine ⟨t, ?_, ?_⟩
      · -- Atom part: ∀ a, atom_eval M [t,t] a ↔ sub_nf.1 a = true
        intro a
        match a with
        | .pred p ⟨0, _⟩ =>
          simp only [atom_eval, Fin.cons]
          have h_par := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h_par
          rw [h_pred_compat p, h_t_compat p]
          exact h_par
        | .pred p ⟨1, _⟩ =>
          simp only [atom_eval, Fin.cons]
          have h_par := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h_par
          rw [h_t_compat p]
          exact h_par
        | .order ⟨0, _⟩ ⟨1, _⟩ h_ne =>
          simp only [atom_eval, Fin.cons]
          exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
        | .order ⟨1, _⟩ ⟨0, _⟩ h_ne =>
          simp only [atom_eval, Fin.cons]
          exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
        | .order ⟨0, _⟩ ⟨0, _⟩ h_ne => exact absurd rfl h_ne
        | .order ⟨1, _⟩ ⟨1, _⟩ h_ne => exact absurd rfl h_ne
      · -- Quant part: ∀ ssn, (∃ y, nf_eval 0 3 [y,t,t] ssn) ↔ sub_nf.2 ssn
        intro ssn
        -- nf_x_1var from nf_x agrees with ref_nf_x_1var from sub_nf via h_compat_nfx
        have h_nfx_eq : ∀ p : sig.preds,
            nf_x.1 (.pred p ⟨0, by omega⟩) = sub_nf.1 (.pred p ⟨0, by omega⟩) := by
          intro p
          have h := h_compat_nfx
          simp only [nf_x_compat_check, List.all_eq_true, beq_iff_eq] at h
          exact h p (Multiset.mem_toList.mpr (Fintype.complete p))
        -- So ssn_xt_compatible with nf_x_1var ↔ ssn_xt_compatible with ref_nf_x_1var
        have h_compat_equiv : ∀ ssn' : NormalForm sig 0 3,
            ssn_xt_compatible ssn' (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
              parent_atoms false false =
            ssn_xt_compatible ssn' (fun a => match a with
              | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
              parent_atoms false false := by
          intro ssn'
          congr 1
          funext a
          match a with
          | .pred q _ => exact h_nfx_eq q
          | .order i j h => rfl
        by_cases h_ssn_xt_compat : ssn_xt_compatible ssn
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms false false = true
        · -- Compatible ssn: use zone bridges via h_conj
          rw [formula_conjList_iff] at h_conj
          obtain ⟨h_xt, h_tx, h_yx_eq_yt, h_xy_eq_ty⟩ := eq_case_orders ssn
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms h_ssn_xt_compat
          have h_t_pred_1 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true :=
            eq_case_t_pred_1 M parent_atoms sub_nf ssn
              (fun a => match a with
                | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
                | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
              t h_atoms nf_x h_nf_x h_ssn_xt_compat (fun _ => rfl)
          have h_t_pred_2 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true :=
            eq_case_t_pred_2 M parent_atoms ssn
              (fun a => match a with
                | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
                | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
              t h_atoms h_ssn_xt_compat
          -- Determine zone and apply appropriate bridge
          by_cases h_y_lt_x : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true
          · -- y < x zone: Since bridge
            have h_xy_false : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
              by_contra h_both
              push_neg at h_both
              simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq] at h_ssn_xt_compat
              have h_oc := h_ssn_xt_compat.2
              simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true',
                Bool.or_eq_true, Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_oc
              cases h_both_val : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) <;> simp_all
            have h_zone := eq_case_zone_below M atomMap h_surj ssn parent_atoms t
              h_y_lt_x h_xy_false h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2
            -- Extract the formula for this ssn from h_conj
            cases h_sub : sub_nf.2 ssn
            · -- sub_nf.2 ssn = false: formula is neg(Since), need ¬∃ y
              simp only [eq_iff_iff]; constructor
              · intro ⟨y, hy⟩
                apply absurd (h_zone.mpr ⟨y, hy⟩)
                show temporal_truth M atomMap t ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).snce Formula.top).neg
                apply h_conj
                apply List.mem_filterMap.mpr
                exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
              · intro h; simp_all
            · -- sub_nf.2 ssn = true: formula is Since, need ∃ y
              have h_formula_true : temporal_truth M atomMap t
                  ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).snce Formula.top) := by
                apply h_conj
                apply List.mem_filterMap.mpr
                exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
              simp only [eq_iff_iff, h_sub, iff_true]
              exact h_zone.mp h_formula_true
          · by_cases h_x_lt_y : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true
            · -- x < y zone: Until bridge
              have h_zone := eq_case_zone_above M atomMap h_surj ssn parent_atoms t
                h_x_lt_y (Bool.eq_false_iff.mpr h_y_lt_x)
                h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2
              cases h_sub : sub_nf.2 ssn
              · simp only [eq_iff_iff]; constructor
                · intro ⟨y, hy⟩
                  apply absurd (h_zone.mpr ⟨y, hy⟩)
                  show temporal_truth M atomMap t ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).untl Formula.top).neg
                  apply h_conj
                  apply List.mem_filterMap.mpr
                  exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
                · intro h; simp_all
              · have h_formula_true : temporal_truth M atomMap t
                    ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).untl Formula.top) := by
                  apply h_conj
                  apply List.mem_filterMap.mpr
                  exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
                simp only [eq_iff_iff, h_sub, iff_true]
                exact h_zone.mp h_formula_true
            · -- y = x zone: direct bridge
              have h_zone := eq_case_zone_eq M atomMap h_surj ssn parent_atoms t
                (Bool.eq_false_iff.mpr h_y_lt_x)
                (Bool.eq_false_iff.mpr h_x_lt_y)
                h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2
              cases h_sub : sub_nf.2 ssn
              · simp only [eq_iff_iff]; constructor
                · intro ⟨y, hy⟩
                  apply absurd (h_zone.mpr ⟨y, hy⟩)
                  show temporal_truth M atomMap t (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg
                  apply h_conj
                  apply List.mem_filterMap.mpr
                  exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
                · intro h; simp_all
              · have h_formula_true : temporal_truth M atomMap t
                    (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) := by
                  apply h_conj
                  apply List.mem_filterMap.mpr
                  exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
                simp only [eq_iff_iff, h_sub, iff_true]
                exact h_zone.mp h_formula_true
        · -- Incompatible ssn: both sides false
          constructor
          · -- ∃ y, nf_eval → sub_nf.2 ssn = true
            intro ⟨y, h_ssn_eval⟩
            -- From h_ssn_eval, derive ssn_xt_compatible, contradicting h_ssn_xt_compat
            exfalso; apply h_ssn_xt_compat
            simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
            refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
            · -- x-preds: ssn (.pred p 1) = nf_x.1 (.pred p 0)
              intro p _
              have h1 : M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true := by
                have h := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h; exact h
              have h2 : M.interp p t ↔ nf_x.1 (.pred p ⟨0, by omega⟩) = true := by
                have h := h_nf_x.1 (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
              cases h1v : ssn (.pred p ⟨1, by omega⟩) <;>
              cases h2v : nf_x.1 (.pred p ⟨0, by omega⟩) <;> simp_all
            · -- t-preds: ssn (.pred p 2) = parent_atoms (.pred p 0)
              intro p _
              have h1 : M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
                have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
              have h2 : M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
                have h := h_atoms (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
              cases h1v : ssn (.pred p ⟨2, by omega⟩) <;>
              cases h2v : parent_atoms (.pred p ⟨0, by omega⟩) <;> simp_all
            · -- t > x order: ssn (.order 2 1) = false (t < t)
              have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
              unfold atom_eval at h
              cases hv : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
              · rfl
              · exact absurd (h.mpr hv) (lt_irrefl _)
            · -- x > t order: ssn (.order 1 2) = false (t < t)
              have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
              unfold atom_eval at h
              cases hv : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
              · rfl
              · exact absurd (h.mpr hv) (lt_irrefl _)
            · exact ssn_order_consistent_of_eval ssn h_ssn_eval
          · -- sub_nf.2 ssn = true → ∃ y, nf_eval: contradict with h_ssn_compat
            intro h_sub_true
            -- h_ssn_compat gives ssn_xt_compatible ssn ref_nf_x_1var ... = true
            have h_ref_compat := h_ssn_compat ssn h_sub_true
            -- ref_nf_x_1var and nf_x_1var agree, so ssn_xt_compatible should agree
            rw [h_compat_equiv ssn] at h_ssn_xt_compat
            exact absurd h_ref_compat h_ssn_xt_compat
  · -- Backward (mpr): ∃ x, nf_eval → formula truth
    intro ⟨x, h_eval⟩
    have h_x_eq := witness_eq_t_of_no_order M sub_nf t x h_gt h_lt h_eval
    subst h_x_eq
    -- After subst: t eliminated, x survives. Goal: temporal_truth M atomMap x (enriched_bypass_eq ...)
    let nf_x := nf_characteristic M 1 1 (fun _ => x)
    have h_nf_x := nf_characteristic_satisfies M 1 1 (fun _ => x)
    have h_compat := nf_x_compat_of_nf_eval M sub_nf x x h_eval nf_x h_nf_x
    show temporal_truth M atomMap x (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms)
    unfold enriched_bypass_eq
    rw [formula_disjList_iff]
    -- Show the disjunct for nf_x is in the list and true.
    -- Step 1: membership in filterMap via nf_x and h_compat
    refine ⟨(char_1 nf_x).and (formula_conjList
      ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
        if ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          parent_atoms false false = true then
          let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
          let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
          let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
          if y_lt_x = true then
            if sub_nf.2 ssn = true then some (char_y.snce Formula.top)
            else some (char_y.snce Formula.top).neg
          else if x_lt_y = true then
            if sub_nf.2 ssn = true then some (char_y.untl Formula.top)
            else some (char_y.untl Formula.top).neg
          else
            if sub_nf.2 ssn = true then some char_y
            else some char_y.neg
        else none)),
      List.mem_filterMap.mpr ⟨nf_x,
        Multiset.mem_toList.mpr (Fintype.complete nf_x),
        by simp_all⟩, ?_⟩
    -- Step 2: truth of (char_1 nf_x).and (formula_conjList quant_conjuncts)
    rw [temporal_truth_and]
    refine ⟨(char_1_correct nf_x M h_UZ h_SZ x).mpr h_nf_x, ?_⟩
    -- Step 3: truth of formula_conjList quant_conjuncts
    rw [formula_conjList_iff]
    intro φ h_φ_mem
    rw [List.mem_filterMap] at h_φ_mem
    obtain ⟨ssn, h_ssn_in, h_ssn_some⟩ := h_φ_mem
    -- ssn passes the ssn_xt_compatible filter; split the outer if
    split_ifs at h_ssn_some with h_ssn_compat_nfx h_sub_nf_true
    -- Case: ssn_xt_compatible = true, sub_nf.2 ssn = true
    · -- Establish shared infrastructure for this ssn
      obtain ⟨h_atom_eval, h_quant_eval⟩ := h_eval
      have h_orders := eq_case_orders ssn
        (fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
        parent_atoms h_ssn_compat_nfx
      obtain ⟨h_xt, h_tx, h_yx_eq_yt, h_xy_eq_ty⟩ := h_orders
      have h_t_pred_1 : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true :=
        eq_case_t_pred_1 M parent_atoms sub_nf ssn
          (fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          x h_atoms nf_x h_nf_x h_ssn_compat_nfx (fun _ => rfl)
      have h_t_pred_2 : ∀ p, M.interp p x ↔ ssn (.pred p ⟨2, by omega⟩) = true :=
        eq_case_t_pred_2 M parent_atoms ssn
          (fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          x h_atoms h_ssn_compat_nfx
      simp only [] at h_ssn_some
      split_ifs at h_ssn_some with h_y_lt_x h_x_lt_y
      · -- y < x: Since(char_y, top) is true because ∃ y, nf_eval
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        have h_xy_false : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
          obtain ⟨w, hw⟩ := (h_quant_eval ssn).mpr h_sub_nf_true
          have h_oc := ssn_order_consistent_of_eval ssn hw
          simp only [ssn_order_consistent] at h_oc
          revert h_oc; revert h_y_lt_x
          cases ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) <;>
          cases ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) <;> simp_all
        exact (eq_case_zone_below M atomMap h_surj ssn parent_atoms x
          h_y_lt_x h_xy_false
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mpr
          ((h_quant_eval ssn).mpr h_sub_nf_true)
      · -- x < y: Until(char_y, top) is true
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        have h_yx_false : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false :=
          Bool.eq_false_iff.mpr h_y_lt_x
        exact (eq_case_zone_above M atomMap h_surj ssn parent_atoms x
          h_x_lt_y h_yx_false
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mpr
          ((h_quant_eval ssn).mpr h_sub_nf_true)
      · -- y = x: char_y is true
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        exact (eq_case_zone_eq M atomMap h_surj ssn parent_atoms x
          (Bool.eq_false_iff.mpr h_y_lt_x)
          (Bool.eq_false_iff.mpr h_x_lt_y)
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mpr
          ((h_quant_eval ssn).mpr h_sub_nf_true)
    -- Case: ssn_xt_compatible = true, sub_nf.2 ssn = false (neg formulas)
    · obtain ⟨h_atom_eval, h_quant_eval⟩ := h_eval
      have h_orders := eq_case_orders ssn
        (fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
        parent_atoms h_ssn_compat_nfx
      obtain ⟨h_xt, h_tx, h_yx_eq_yt, h_xy_eq_ty⟩ := h_orders
      have h_t_pred_1 : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true :=
        eq_case_t_pred_1 M parent_atoms sub_nf ssn
          (fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          x h_atoms nf_x h_nf_x h_ssn_compat_nfx (fun _ => rfl)
      have h_t_pred_2 : ∀ p, M.interp p x ↔ ssn (.pred p ⟨2, by omega⟩) = true :=
        eq_case_t_pred_2 M parent_atoms ssn
          (fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          x h_atoms h_ssn_compat_nfx
      have h_no_witness : ¬∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x fun _ => x)) ssn := by
        intro h_wit
        exact absurd ((h_quant_eval ssn).mp h_wit) (by simp_all)
      simp only [] at h_ssn_some
      split_ifs at h_ssn_some with h_y_lt_x h_x_lt_y
      · -- y < x: neg(Since(char_y, top)) is true because ¬∃ y
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        have h_xy_false : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
          have h_oc := h_ssn_compat_nfx
          simp only [ssn_xt_compatible, Bool.and_eq_true] at h_oc
          have h_oc_cons := h_oc.2  -- ssn_order_consistent ssn = true
          simp only [ssn_order_consistent] at h_oc_cons
          revert h_oc_cons; revert h_y_lt_x
          cases ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) <;>
          cases ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) <;> simp_all
        rw [temporal_truth_neg]
        intro h_snce
        exact h_no_witness ((eq_case_zone_below M atomMap h_surj ssn parent_atoms x
          h_y_lt_x h_xy_false
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mp h_snce)
      · -- x < y: neg(Until(char_y, top))
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        have h_yx_false : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false :=
          Bool.eq_false_iff.mpr h_y_lt_x
        rw [temporal_truth_neg]
        intro h_untl
        exact h_no_witness ((eq_case_zone_above M atomMap h_surj ssn parent_atoms x
          h_x_lt_y h_yx_false
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mp h_untl)
      · -- y = x: neg(char_y)
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        rw [temporal_truth_neg]
        intro h_eq_zone
        exact h_no_witness ((eq_case_zone_eq M atomMap h_surj ssn parent_atoms x
          (Bool.eq_false_iff.mpr h_y_lt_x)
          (Bool.eq_false_iff.mpr h_x_lt_y)
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mp h_eq_zone)

/-! ## Equality Case (x = t) -/

set_option maxHeartbeats 3200000 in
/-- Equality case of the enriched bypass: when sub_nf says x = t,
    the existential reduces to nf_eval_nf M 1 2 [t, t] sub_nf. -/
theorem existPart_succ_n1_bypass_k0_eq
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (char_1_correct : ∀ (nf_1 : NormalForm sig 1 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_1 nf_1) ↔
        nf_eval_nf M 1 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- When x = t, any witness x must equal t (by witness_eq_t_of_no_order).
  -- Check predicate compatibility: var-0 = var-1 (both are t's preds) and
  -- var-1 matches parent_atoms.
  by_cases h_pred_compat : ∀ p : sig.preds,
      sub_nf.1 (.pred p ⟨0, by omega⟩) = sub_nf.1 (.pred p ⟨1, by omega⟩)
  · by_cases h_t_compat : ∀ p : sig.preds,
        sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩)
    · -- Compatible: use enriched_bypass_eq and eq_case_iff helper.
      -- First check that all ssn with sub_nf.2 = true have compatible
      -- predicates. If not, the existential is impossible and we use Bot.
      -- Build a reference nf_x_1var from pred_compat + t_compat:
      -- nf_x_1var (.pred p 0) = sub_nf.1 (.pred p 0) (= sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0))
      let ref_nf_x_1var : NormalForm sig 0 1 := fun a => match a with
        | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
        | .order i j h => absurd (Fin.ext (by omega) : i = j) h
      by_cases h_ssn_compat : ∀ ssn : NormalForm sig 0 3,
          sub_nf.2 ssn = true →
          ssn_xt_compatible ssn ref_nf_x_1var parent_atoms false false = true
      · -- All ssn with sub_nf.2 = true are compatible: use enriched_bypass_eq
        exact ⟨enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms,
          fun M h_UZ h_SZ t h_atoms => by
          exact eq_case_iff atomMap h_surj char_1 char_1_correct parent_atoms
            sub_nf h_gt h_lt h_pred_compat h_t_compat M h_UZ h_SZ t h_atoms
            h_ssn_compat⟩
      · -- Some ssn with sub_nf.2 = true is NOT compatible: existential impossible
        refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
        simp only [temporal_truth]
        constructor
        · exact fun h => absurd h id
        · intro ⟨x, h_eval⟩
          have h_x_eq := witness_eq_t_of_no_order M sub_nf t₀ x h_gt h_lt h_eval
          subst h_x_eq
          apply h_ssn_compat
          intro ssn h_ssn_true
          obtain ⟨h_atom_2, h_quant_2⟩ := h_eval
          have ⟨y, h_ssn_eval⟩ := (h_quant_2 ssn).mpr h_ssn_true
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
          refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
          · -- x-preds: ssn (.pred p 1) = sub_nf.1 (.pred p 0)
            intro p _
            have h1 : M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true := by
              have h := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h; exact h
            have h2 : M.interp p x ↔ sub_nf.1 (.pred p ⟨0, by omega⟩) = true := by
              have h := h_atom_2 (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
            cases hsub : sub_nf.1 (.pred p ⟨0, by omega⟩) <;>
            cases hssn : ssn (.pred p ⟨1, by omega⟩) <;>
            first | rfl | exact hsub.symm | (exfalso; simp_all)
          · -- t-preds: ssn (.pred p 2) = parent_atoms (.pred p 0)
            intro p _
            have h1 : M.interp p x ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
              have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
            have h2 : M.interp p x ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
              have h := h_atoms (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
            cases hssn : ssn (.pred p ⟨2, by omega⟩) <;>
            cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- t > x order: ssn (.order ⟨2,_⟩ ⟨1,_⟩ _) = false (x < x is false)
            have h_ord : x < x ↔ ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
              have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
              unfold atom_eval at h; exact h
            cases h : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            · rfl
            · exact absurd (h_ord.mpr h) (lt_irrefl _)
          · -- x > t order: ssn (.order ⟨1,_⟩ ⟨2,_⟩ _) = false (x < x is false)
            have h_ord : x < x ↔ ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
              have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
              unfold atom_eval at h; exact h
            cases h : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            · rfl
            · exact absurd (h_ord.mpr h) (lt_irrefl _)
          · exact ssn_order_consistent_of_eval ssn h_ssn_eval
    · -- var-1 preds don't match parent_atoms: existential impossible
      refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
      simp only [temporal_truth]
      constructor
      · exact fun h => absurd h id
      · intro ⟨x, h_eval⟩
        have h_x_eq := witness_eq_t_of_no_order M sub_nf t₀ x h_gt h_lt h_eval
        subst h_x_eq
        push_neg at h_t_compat; obtain ⟨p, hp⟩ := h_t_compat
        obtain ⟨h_atom, _⟩ := h_eval
        have h_sub := (h_atom (.pred p ⟨1, by omega⟩))
        have h_par := (h_atoms (.pred p ⟨0, by omega⟩))
        simp only [atom_eval] at h_par
        -- After subst, derive M.interp p x ↔ sub_nf.1 (.pred p 1) from h_atom
        have h_sub' : M.interp p x ↔ sub_nf.1 (.pred p ⟨1, by omega⟩) = true := by
          have h := h_atom (.pred p ⟨1, by omega⟩); unfold atom_eval at h
          exact h
        cases hsub : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
        cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
        simp_all
  · -- var-0 and var-1 predicates don't agree: existential impossible
    refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
    simp only [temporal_truth]
    constructor
    · exact fun h => absurd h id
    · intro ⟨x, h_eval⟩
      have h_x_eq := witness_eq_t_of_no_order M sub_nf t₀ x h_gt h_lt h_eval
      subst h_x_eq
      push_neg at h_pred_compat; obtain ⟨p, hp⟩ := h_pred_compat
      obtain ⟨h_atom, _⟩ := h_eval
      have h0 := (h_atom (.pred p ⟨0, by omega⟩))
      have h1 := (h_atom (.pred p ⟨1, by omega⟩))
      -- After subst, derive M.interp from h_atom with proper reduction
      have h0' : M.interp p x ↔ sub_nf.1 (.pred p ⟨0, by omega⟩) = true := by
        have h := h_atom (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
      have h1' : M.interp p x ↔ sub_nf.1 (.pred p ⟨1, by omega⟩) = true := by
        have h := h_atom (.pred p ⟨1, by omega⟩); unfold atom_eval at h
        exact h
      cases h0v : sub_nf.1 (.pred p ⟨0, by omega⟩) <;>
      cases h1v : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
      simp_all

end Bimodal.Metalogic.WeakCanonical.Kamp

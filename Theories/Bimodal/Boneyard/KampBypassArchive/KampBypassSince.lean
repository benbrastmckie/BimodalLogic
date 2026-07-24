import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypassBridge

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Enriched Bypass Formula: Since Direction (x < t)

Correctness proof for the Since (backward) direction of the enriched bypass formula.
Split from KampBypass.lean for modularity.
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Since Direction Zone Order Extraction

Extract order atom values from `ssn_zone_since ssn = zone`.
Combined with `ssn_xt_compatible ... false true = true`, they give all 6 order atoms
needed for the Since-direction zone bridge lemmas. -/

/-- Extract x < t order condition from ssn_xt_compatible (Since direction). -/
private theorem ssn_xt_compat_xt_order {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true) :
    ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
  exact ⟨h_compat.1.1.2, h_compat.1.2⟩

set_option maxHeartbeats 400000 in
/-- Extract y < x from since below_t zone. -/
private theorem since_zone_below_t_yx {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.below_t) :
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(x < y) from since below_t zone. -/
private theorem since_zone_below_t_xy {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.below_t) :
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(y < x), ¬(x < y) from since eq_t zone. -/
private theorem since_zone_eq_t_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.eq_t) :
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract x < y, y < t from since between_tx zone. -/
private theorem since_zone_between_tx_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.between_tx) :
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(y < t), ¬(t < y), x < y from since eq_x zone. -/
private theorem since_zone_eq_x_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.eq_x) :
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract t < y from since above_x zone. -/
private theorem since_zone_above_x_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.above_x) :
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

/-! ## Since Direction Zone Bridges

These connect the temporal formulas used in `enriched_vecEA2_since` to the 3-var
existentials for the Since direction (x < t). -/

/-- Since below_x: Since(char_y, top) at x ↔ ∃ y, nf_eval (y < x zone). -/
private theorem since_below_x_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.below_t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap x
      (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have h_yx := since_zone_below_t_yx ssn h_zone
  have h_xy := since_zone_below_t_xy ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  constructor
  · intro ⟨y, h_yx_lt, h_char_y, _⟩
    refine ⟨y, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    apply reconstruct_nf_eval_3var M ssn y x t
      (fun p => by have := h_char_y p; simp only [nf_y_proj] at this; exact this)
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · exact ⟨fun _ => h_yx, fun _ => h_yx_lt⟩
    · exact ⟨fun _ => h_yt, fun _ => lt_trans h_yx_lt h_xt⟩
    · constructor
      · intro h; exact absurd (lt_trans h_yx_lt h) (lt_irrefl _)
      · intro h; simp_all
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · constructor
      · intro h; exact absurd (lt_trans h (lt_trans h_yx_lt h_xt)) (lt_irrefl _)
      · intro h; simp_all
    · constructor
      · intro h; exact absurd (lt_trans h_xt h) (lt_irrefl _)
      · intro h; simp_all
  · intro ⟨y, h_nf⟩
    have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord
    simp only [Fin.cons] at h_ord
    refine ⟨y, h_ord.mpr h_yx, ?_, fun z _ _ => by simp [temporal_truth, Formula.top]⟩
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr
      (extract_y_preds M ssn y x t h_nf)

/-- Since eq_x: char_y at x ↔ ∃ y, nf_eval (y = x zone). -/
private theorem since_eq_x_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.eq_t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_yx, h_xy⟩ := since_zone_eq_t_orders ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  constructor
  · intro h_char_y
    rw [nf_depth0_char_formula_correct] at h_char_y
    refine ⟨x, ?_⟩
    apply reconstruct_nf_eval_3var M ssn x x t
      (fun p => by have := h_char_y p; simp only [nf_y_proj] at this; exact this)
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · exact ⟨fun h => absurd h (lt_irrefl _), fun h => by cases h_yx ▸ h⟩
    · exact ⟨fun _ => h_yt, fun _ => h_xt⟩
    · exact ⟨fun h => absurd h (lt_irrefl _), fun h => by cases h_xy ▸ h⟩
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · exact ⟨fun h => absurd (lt_trans h_xt h) (lt_irrefl _), fun h => by cases h_ty ▸ h⟩
    · exact ⟨fun h => absurd (lt_trans h_xt h) (lt_irrefl _), fun h => by cases h_xt_ord.1 ▸ h⟩
  · intro ⟨y, h_nf⟩
    have h_y_preds := extract_y_preds M ssn y x t h_nf
    have h_ord_yx := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    have h_ord_xy := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord_yx h_ord_xy
    simp only [Fin.cons] at h_ord_yx h_ord_xy
    have h_y_eq_x : y = x := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
      · exact absurd (h_ord_yx.mp h_lt) (by rw [h_yx]; decide)
      · exact absurd (h_ord_xy.mp h_gt) (by rw [h_xy]; decide)
    subst h_y_eq_x
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr h_y_preds

set_option maxHeartbeats 800000 in
/-- Since between_xt: zone bridge for x < y < t (bracket zone). -/
private theorem since_between_xt_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.between_tx)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∃ y, x < y ∧ y < t ∧ ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  have ⟨h_xy, h_yt, h_yx, h_ty⟩ := since_zone_between_tx_orders ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  constructor
  · intro ⟨y, h_nf⟩
    refine ⟨y, ?_, ?_, extract_y_preds M ssn y x t h_nf⟩
    · have h_ord := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact h_ord.mpr h_xy
    · have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact h_ord.mpr h_yt
  · intro ⟨y, h_x_lt_y, h_y_lt_t, h_y_preds⟩
    refine ⟨y, ?_⟩
    apply reconstruct_nf_eval_3var M ssn y x t h_y_preds
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · constructor
      · intro h; exact absurd (lt_trans h_x_lt_y h) (lt_irrefl _)
      · intro h; simp_all
    · exact ⟨fun _ => h_yt, fun _ => h_y_lt_t⟩
    · exact ⟨fun _ => h_xy, fun _ => h_x_lt_y⟩
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · constructor
      · intro h; exact absurd (lt_trans h_y_lt_t h) (lt_irrefl _)
      · intro h; simp_all
    · constructor
      · intro h; exact absurd (lt_trans h_xt h) (lt_irrefl _)
      · intro h; simp_all

/-- Since eq_t: char_y at t ↔ ∃ y, nf_eval (y = t zone). -/
private theorem since_eq_t_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.eq_x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_yt, h_ty, h_xy, h_yx⟩ := since_zone_eq_x_orders ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  constructor
  · intro h_char_y
    rw [nf_depth0_char_formula_correct] at h_char_y
    refine ⟨t, ?_⟩
    apply reconstruct_nf_eval_3var M ssn t x t
      (fun p => by have := h_char_y p; simp only [nf_y_proj] at this; exact this)
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · exact ⟨fun h => absurd h (not_lt_of_gt h_xt), fun h => by cases h_yx ▸ h⟩
    · exact ⟨fun h => absurd h (lt_irrefl _), fun h => by cases h_yt ▸ h⟩
    · exact ⟨fun _ => h_xy, fun _ => h_xt⟩
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · exact ⟨fun h => absurd h (lt_irrefl _), fun h => by cases h_ty ▸ h⟩
    · exact ⟨fun h => absurd h (not_lt_of_gt h_xt), fun h => by cases h_xt_ord.1 ▸ h⟩
  · intro ⟨y, h_nf⟩
    have h_y_preds := extract_y_preds M ssn y x t h_nf
    have h_ord_yt := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    have h_ord_ty := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord_yt h_ord_ty
    simp only [Fin.cons] at h_ord_yt h_ord_ty
    have h_y_eq_t : y = t := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
      · exact absurd (h_ord_yt.mp h_lt) (by rw [h_yt]; decide)
      · exact absurd (h_ord_ty.mp h_gt) (by rw [h_ty]; decide)
    subst h_y_eq_t
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr h_y_preds

set_option maxHeartbeats 800000 in
/-- Since above_t: Until(char_y, top) at t ↔ ∃ y, nf_eval (y > t zone). -/
private theorem since_above_t_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.above_x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap t
      (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_ty, h_yt, h_xy, h_yx⟩ := since_zone_above_x_orders ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  constructor
  · intro ⟨y, h_ty_lt, h_char_y, _⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    refine ⟨y, ?_⟩
    apply reconstruct_nf_eval_3var M ssn y x t
      (fun p => by have := h_char_y p; simp only [nf_y_proj] at this; exact this)
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · constructor
      · intro h; exact absurd (lt_trans h (lt_trans h_xt h_ty_lt)) (lt_irrefl _)
      · intro h; simp_all
    · constructor
      · intro h; exact absurd (lt_trans h_ty_lt h) (lt_irrefl _)
      · intro h; simp_all
    · exact ⟨fun _ => h_xy, fun _ => lt_trans h_xt h_ty_lt⟩
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · exact ⟨fun _ => h_ty, fun _ => h_ty_lt⟩
    · constructor
      · intro h; exact absurd (lt_trans h_xt h) (lt_irrefl _)
      · intro h; simp_all
  · intro ⟨y, h_nf⟩
    have h_ord := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord
    simp only [Fin.cons] at h_ord
    refine ⟨y, h_ord.mpr h_ty, ?_, fun z _ _ => by simp [temporal_truth, Formula.top]⟩
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr
      (extract_y_preds M ssn y x t h_nf)

private theorem since_between_xt_order_atoms {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (h : ssn_zone_since ssn = YZone.between_tx) :
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  have ⟨h1, h2, h3, h4⟩ := since_zone_between_tx_orders ssn h
  exact ⟨h1, h3, h2, h4⟩

/-- The pre_conditions_at_t_since formula holds at t when h_eval_quant
    guarantees the correct truth values for all zone-based ssn conditions. -/
private theorem pre_conditions_at_t_since_holds
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true)
    (h_eval_quant : ∀ (ssn : NormalForm sig 0 3),
      (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
      sub_nf.2 ssn = true) :
    temporal_truth M atomMap t
      (pre_conditions_at_t_since atomMap h_surj sub_nf nf_x_1var parent_atoms) := by
  simp only [pre_conditions_at_t_since]
  rw [formula_conjList_iff]
  intro φ h_mem
  rw [List.mem_filterMap] at h_mem
  obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
  split_ifs at h_some with h_compat h_pos
  · revert h_some
    rcases h_zone : ssn_zone_since ssn with _ | _ | _ | _ | _ | _
    all_goals simp
    all_goals intro h_eq; subst h_eq
    · exact (since_eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_xt
        h_compat h_zone h_x_pred h_t_pred).mpr ((h_eval_quant ssn).mpr h_pos)
    · exact (since_above_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_xt
        h_compat h_zone h_x_pred h_t_pred).mpr ((h_eval_quant ssn).mpr h_pos)
  · revert h_some
    rcases h_zone : ssn_zone_since ssn with _ | _ | _ | _ | _ | _
    all_goals simp
    all_goals intro h_eq; subst h_eq
    · simp only [Formula.neg, temporal_truth]
      intro h_char
      have h_exist := (since_eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_xt
        h_compat h_zone h_x_pred h_t_pred).mp h_char
      exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
    · simp only [Formula.neg, temporal_truth]
      intro h_untl
      have h_exist := (since_above_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_xt
        h_compat h_zone h_x_pred h_t_pred).mp h_untl
      exact absurd ((h_eval_quant ssn).mp h_exist) h_pos

/-! ## Since forward/backward proof lemmas -/

set_option maxHeartbeats 3200000 in
/-- Forward direction: holdsRight for the enriched Since VVecEA2 → ∃ x, nf_eval.
    Mirror of forward_nf_eval_of_holdsLeft for the Since direction. -/
private theorem forward_nf_eval_of_holdsRight
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
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_t_compat : ∀ p : sig.preds, sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩))
    (h_ssn_compat : ∀ ssn : NormalForm sig 0 3, sub_nf.2 ssn = true →
        ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h) parent_atoms false true = true) :
    (∃ vea ∈ (List.flatMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          enriched_vecEA2_since atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms
        else []) Fintype.elems.val.toList),
      VecEA2.holdsRight M atomMap vea.snd t) →
    ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  intro ⟨⟨n, vea⟩, h_mem, h_holds⟩
  rw [List.mem_flatMap] at h_mem
  obtain ⟨nf_x, _, h_in_list⟩ := h_mem
  split_ifs at h_in_list with h_compat
  · simp only [enriched_vecEA2_since] at h_in_list
    rw [List.mem_map] at h_in_list
    obtain ⟨σ, _, h_vea_eq⟩ := h_in_list
    let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
      | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
      | .order i j h => absurd (Fin.ext (by omega) : i = j) h
    let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
      ssn_xt_compatible ssn nf_x_1var parent_atoms false true &&
      (ssn_zone_since ssn == .between_tx) && sub_nf.2 ssn
    have h_n_eq : n = pos_between.length := by
      have := congrArg Sigma.fst h_vea_eq; simp at this; exact this.symm
    rw [show (⟨n, vea⟩ : Σ n, VecEA2 n).snd = vea from rfl] at h_holds
    simp only [VecEA2.holdsRight] at h_holds
    obtain ⟨h_endRight, x, h_x_lt_t, h_endLeft, h_bracket⟩ := h_holds
    refine ⟨x, ?_⟩
    -- Extract char_1(nf_x) from endpointLeft (Since: char_1 is in endpointLeft)
    have h_vea_left : vea.endpointLeft =
          (⟨Formula.and (char_1 nf_x) (formula_conjList
            ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
              if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then
                let zone := ssn_zone_since ssn
                let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
                match zone with
                | .eq_t => if sub_nf.2 ssn then some char_y else some char_y.neg
                | .below_t =>
                  if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
                  else some (Formula.snce char_y Formula.top).neg
                | _ => none
              else none))⟩ : TemporalPred) := by
        have := congrArg (fun s => s.snd.endpointLeft) h_vea_eq
        simp at this; exact this.symm
    simp only [TemporalPred.eval_at] at h_endLeft
    rw [h_vea_left] at h_endLeft
    simp only [TemporalPred.eval_at] at h_endLeft
    have h_endLeft_temporal := h_endLeft
    rw [temporal_truth_and] at h_endLeft_temporal
    have h_nf_x_eval := (char_1_correct nf_x M h_UZ h_SZ x).mp h_endLeft_temporal.1
    obtain ⟨h_nf_x_atoms, _⟩ := h_nf_x_eval
    constructor
    · -- Atom part
      intro a
      cases a with
      | pred p k =>
        match k with
        | ⟨0, _⟩ =>
          have h := h_nf_x_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, Fin.cons] at h ⊢
          simp only [nf_x_compat_check, List.all_eq_true] at h_compat
          have hc := h_compat p (Multiset.mem_toList.mpr (Fintype.complete p))
          rw [beq_iff_eq] at hc
          rw [← hc]; exact h
        | ⟨1, _⟩ =>
          have h := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, Fin.cons] at h ⊢
          rw [h_t_compat p]; exact h
      | order k l h_ne =>
        match k, l, h_ne with
        | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
        | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
        | ⟨0, _⟩, ⟨1, _⟩, _ =>
          simp only [atom_eval, Fin.cons]
          constructor
          · intro _; exact h_lt
          · intro _; exact h_x_lt_t
        | ⟨1, _⟩, ⟨0, _⟩, _ =>
          simp only [atom_eval, Fin.cons]
          constructor
          · intro h_t_lt_x; exact absurd (lt_trans h_x_lt_t h_t_lt_x) (lt_irrefl _)
          · intro h_eq; rw [h_eq] at h_gt; exact absurd h_gt (by simp)
    · -- Quantifier part
      have h_x_pred : ∀ p : sig.preds,
          M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true := by
        intro p; have h := h_nf_x_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h; exact h
      have h_t_pred : ∀ p : sig.preds,
          M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
        intro p; have h := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h; exact h
      -- Extract endpointRight as pre_conditions_at_t_since
      have h_vea_right : vea.endpointRight =
          (⟨pre_conditions_at_t_since atomMap h_surj sub_nf nf_x_1var parent_atoms⟩ : TemporalPred) := by
        have := congrArg (fun s => s.snd.endpointRight) h_vea_eq
        simp at this; exact this.symm
      simp only [TemporalPred.eval_at] at h_endRight
      rw [h_vea_right] at h_endRight
      simp only [TemporalPred.eval_at] at h_endRight
      have h_left_conj := h_endLeft_temporal.2
      -- Helper: left_fn (for endpointLeft conditions at x: eq_t/y=x and below_t/y<x)
      let left_fn := fun ssn' : NormalForm sig 0 3 =>
        if ssn_xt_compatible ssn' nf_x_1var parent_atoms false true then
          let zone := ssn_zone_since ssn'
          let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')
          match zone with
          | .eq_t =>
            if sub_nf.2 ssn' then some char_y
            else some char_y.neg
          | .below_t =>
            if sub_nf.2 ssn' then some (Formula.snce char_y Formula.top)
            else some (Formula.snce char_y Formula.top).neg
          | _ => none
        else none
      -- Helper: pre_fn (for endpointRight conditions at t: eq_x/y=t and above_x/y>t)
      let pre_fn := fun ssn' : NormalForm sig 0 3 =>
        if ssn_xt_compatible ssn' nf_x_1var parent_atoms false true then
          let zone := ssn_zone_since ssn'
          let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')
          match zone with
          | .above_x =>
            if sub_nf.2 ssn' then some (Formula.untl char_y Formula.top)
            else some (Formula.untl char_y Formula.top).neg
          | .eq_x =>
            if sub_nf.2 ssn' then some char_y
            else some char_y.neg
          | _ => none
        else none
      have h_left_conj_all : ∀ φ ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap left_fn,
          temporal_truth M atomMap x φ := by
        exact (formula_conjList_iff M atomMap x _).mp h_left_conj
      have h_pre_conj_all : ∀ φ ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn,
          temporal_truth M atomMap t φ := by
        have : pre_conditions_at_t_since atomMap h_surj sub_nf nf_x_1var parent_atoms =
            formula_conjList ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn) := rfl
        rw [this] at h_endRight
        exact (formula_conjList_iff M atomMap t _).mp h_endRight
      have h_ref_eq_nfx : (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h) = nf_x_1var := by
        funext a; cases a with
        | pred p k =>
          simp only [nf_x_compat_check, List.all_eq_true] at h_compat
          have hc := h_compat p (Multiset.mem_toList.mpr (Fintype.complete p))
          rw [beq_iff_eq] at hc; exact hc.symm
        | order i j h_ne => exact absurd (Fin.ext (by omega) : i = j) h_ne
      have h_ssn_in_elems : ∀ ssn' : NormalForm sig 0 3,
          ssn' ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList :=
        fun ssn' => Multiset.mem_toList.mpr (Fintype.complete ssn')
      -- Per-ssn proof
      intro ssn
      by_cases h_ssn_xt : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true
      · rcases h_zone : ssn_zone_since ssn with _ | _ | _ | _ | _ | _
        · -- below_t (y < x): Since(char_y, ⊤) at x
          have h_bridge := since_below_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_x_lt_t h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap left_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_since ssn with | .eq_t => _ | .below_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_left_conj_all _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap left_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_since ssn with | .eq_t => _ | .below_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_left_conj_all _ h_in)
        · -- eq_t (y = x): char_y at x
          have h_bridge := since_eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_x_lt_t h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap left_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_since ssn with | .eq_t => _ | .below_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_left_conj_all _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap left_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_since ssn with | .eq_t => _ | .below_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_left_conj_all _ h_in)
        · -- between_tx (x < y < t): bracket handles this
          have h_bridge := since_between_xt_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_x_lt_t h_ssn_xt h_zone h_x_pred h_t_pred
          subst h_n_eq
          have h_vea_eq3 := eq_of_heq (Sigma.mk.inj h_vea_eq).2
          have h_bracket_eq := congrArg VecEA2.bracket h_vea_eq3
          rw [← h_bracket_eq] at h_bracket
          let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn' =>
            ssn_xt_compatible ssn' nf_x_1var parent_atoms false true &&
            (ssn_zone_since ssn' == .between_tx) && !sub_nf.2 ssn'
          let seg_guard : TemporalPred :=
            ⟨formula_conjList (neg_between.map fun ssn' =>
              (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')).neg)⟩
          constructor
          · -- → direction: ∃ y → sub_nf.2 ssn = true
            intro h_exist
            by_contra h_neg
            obtain ⟨y, h_xy, h_yt, h_y_pred⟩ := h_bridge.mp h_exist
            have h_ssn_in_neg : ssn ∈ neg_between := by
              rw [List.mem_filter]
              exact ⟨h_ssn_in_elems ssn, by simp [h_ssn_xt, h_zone, h_neg]⟩
            rcases bracket_constant_seg_dichotomy M atomMap
              pos_between.length x t _ seg_guard h_bracket y h_xy h_yt with
              h_seg | ⟨i, h_pt⟩
            · simp only [TemporalPred.eval_at] at h_seg
              rw [formula_conjList_iff] at h_seg
              have h_neg_char := h_seg _
                (List.mem_map.mpr ⟨ssn, h_ssn_in_neg, rfl⟩)
              simp only [Formula.neg, temporal_truth] at h_neg_char
              apply h_neg_char
              rw [nf_depth0_char_formula_correct]
              intro p; simp only [nf_y_proj]; exact h_y_pred p
            · simp only [TemporalPred.eval_at] at h_pt
              rw [nf_depth0_char_formula_correct] at h_pt
              have h_σi_mem : pos_between.get (σ i) ∈ pos_between := List.get_mem pos_between (σ i)
              rw [List.mem_filter] at h_σi_mem
              obtain ⟨_, h_σi_raw⟩ := h_σi_mem
              simp only [Bool.and_eq_true, beq_iff_eq] at h_σi_raw
              obtain ⟨⟨h_σi_compat_raw, h_σi_zone⟩, h_σi_pos⟩ := h_σi_raw
              have h1_compat := h_ssn_xt
              simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq,
                List.all_eq_true] at h1_compat h_σi_compat_raw
              obtain ⟨⟨⟨⟨h1_x, h1_t⟩, h1_ord1⟩, h1_ord2⟩, _⟩ := h1_compat
              obtain ⟨⟨⟨⟨h2_x, h2_t⟩, h2_ord1⟩, h2_ord2⟩, _⟩ := h_σi_compat_raw
              have h_pred_eq : ∀ p, ssn (.pred p ⟨0, by omega⟩) =
                  (pos_between.get (σ i)) (.pred p ⟨0, by omega⟩) := by
                intro p
                have h1 := h_y_pred p
                have h2 := h_pt p
                simp only [nf_y_proj] at h2
                exact Bool.eq_iff_iff.mpr (h1.symm.trans h2)
              obtain ⟨h1_xly, h1_ylx, h1_ylt, h1_tly⟩ := since_between_xt_order_atoms ssn h_zone
              obtain ⟨h2_xly, h2_ylx, h2_ylt, h2_tly⟩ := since_between_xt_order_atoms _ h_σi_zone
              have h_ssn_eq : ssn = pos_between.get (σ i) := by
                funext a; cases a with
                | pred p k =>
                  match k with
                  | ⟨0, _⟩ => exact h_pred_eq p
                  | ⟨1, _⟩ =>
                    exact (h1_x p (Multiset.mem_toList.mpr (Fintype.complete p))).trans
                      (h2_x p (Multiset.mem_toList.mpr (Fintype.complete p))).symm
                  | ⟨2, _⟩ =>
                    exact (h1_t p (Multiset.mem_toList.mpr (Fintype.complete p))).trans
                      (h2_t p (Multiset.mem_toList.mpr (Fintype.complete p))).symm
                | order k l h_ne =>
                  match k, l, h_ne with
                  | ⟨0, _⟩, ⟨1, _⟩, _ => rw [h1_ylx, h2_ylx]
                  | ⟨1, _⟩, ⟨0, _⟩, _ => rw [h1_xly, h2_xly]
                  | ⟨0, _⟩, ⟨2, _⟩, _ => rw [h1_ylt, h2_ylt]
                  | ⟨2, _⟩, ⟨0, _⟩, _ => rw [h1_tly, h2_tly]
                  | ⟨1, _⟩, ⟨2, _⟩, _ => exact h1_ord2.trans h2_ord2.symm
                  | ⟨2, _⟩, ⟨1, _⟩, _ => exact h1_ord1.trans h2_ord1.symm
                  | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
                  | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
                  | ⟨2, _⟩, ⟨2, _⟩, h => exact absurd rfl h
              rw [h_ssn_eq] at h_neg
              exact absurd h_σi_pos h_neg
          · -- ← direction: sub_nf.2 ssn = true → ∃ y
            intro h_pos
            have h_ssn_in_pos : ssn ∈ pos_between := by
              rw [List.mem_filter]
              exact ⟨h_ssn_in_elems ssn, by simp [h_ssn_xt, h_zone, h_pos]⟩
            obtain ⟨j, hj⟩ := List.get_of_mem h_ssn_in_pos
            obtain ⟨w, h_xw, h_wt, h_w_pt⟩ := bracket_extract_witness M atomMap
              pos_between.length x t _ _ h_bracket (σ.symm j)
            simp only [TemporalPred.eval_at] at h_w_pt
            rw [nf_depth0_char_formula_correct] at h_w_pt
            apply h_bridge.mpr
            refine ⟨w, h_xw, h_wt, fun p => ?_⟩
            have := h_w_pt p
            simp only [nf_y_proj, Equiv.apply_symm_apply] at this
            rw [← hj]; exact this
        · -- eq_x (y = t): char_y at t
          have h_bridge := since_eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_x_lt_t h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_since ssn with | .above_x => _ | .eq_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_pre_conj_all _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_since ssn with | .above_x => _ | .eq_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_pre_conj_all _ h_in)
        · -- above_x (y > t): Until(char_y, ⊤) at t
          have h_bridge := since_above_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_x_lt_t h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_since ssn with | .above_x => _ | .eq_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_pre_conj_all _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_since ssn with | .above_x => _ | .eq_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_pre_conj_all _ h_in)
        · -- inconsistent zone
          exfalso
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_ssn_xt
          simp only [ssn_zone_since] at h_zone
          simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
            Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_ssn_xt
          revert h_zone; split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all
      · -- NOT xt-compatible: both sides false via h_ssn_compat
        constructor
        · intro h_exist; exfalso
          obtain ⟨y, h_ssn_eval⟩ := h_exist
          have h_xt_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true := by
            simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
            refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
            · intro p _
              have h1 := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h1
              cases hsub : (nf_x_1var (.pred p ⟨0, by omega⟩) : Bool) <;>
              cases hssn : ssn (.pred p ⟨1, by omega⟩) <;>
              first | rfl | (exfalso; simp_all)
            · intro p _
              have h1 : M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
                have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
              cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
              cases hssn : ssn (.pred p ⟨2, by omega⟩) <;>
              first | rfl | (exfalso; simp_all [h_t_pred])
            · have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by simp [Fin.ext_iff]))
              simp only [atom_eval, Fin.cons] at h
              cases hssn : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by simp [Fin.ext_iff]))
              · rfl
              · exact absurd (h.mpr hssn) (not_lt_of_gt h_x_lt_t)
            · have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by simp [Fin.ext_iff]))
              simp only [atom_eval, Fin.cons] at h; exact h.mp h_x_lt_t
            · exact ssn_order_consistent_of_eval ssn h_ssn_eval
          exact absurd h_xt_compat h_ssn_xt
        · intro h_pos
          exfalso
          have := h_ssn_compat ssn h_pos
          rw [h_ref_eq_nfx] at this
          exact absurd this h_ssn_xt
  · simp at h_in_list

set_option maxHeartbeats 3200000 in
/-- Backward direction: ∃ x, nf_eval → holdsRight for the enriched Since VVecEA2.
    Mirror of backward_holdsLeft_of_nf_eval for the Since direction. -/
private theorem backward_holdsRight_of_nf_eval
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
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) :
    (∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) →
    ∃ vea ∈ (List.flatMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          enriched_vecEA2_since atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms
        else []) Fintype.elems.val.toList),
      VecEA2.holdsRight M atomMap vea.snd t := by
  intro ⟨x, h_eval⟩
  -- Step 1: Get the characteristic NF of x and show compatibility
  let nf_x := nf_characteristic M 1 1 (fun _ => x)
  have h_nf_x : nf_eval_nf M 1 1 (fun _ => x) nf_x :=
    nf_characteristic_satisfies M 1 1 (fun _ => x)
  have h_compat : nf_x_compat_check sub_nf nf_x = true :=
    nf_x_compat_of_nf_eval M sub_nf t x h_eval nf_x h_nf_x
  -- Step 2: Setup
  let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  have h_x_lt_t : x < t := (zone_from_nf_eval M sub_nf t x h_eval).2.1 h_lt
  obtain ⟨h_eval_atoms, h_eval_quant⟩ := h_eval
  -- Define pos_between and neg_between matching enriched_vecEA2_since's let bindings
  let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms false true &&
    (ssn_zone_since ssn == .between_tx) && !sub_nf.2 ssn
  let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms false true &&
    (ssn_zone_since ssn == .between_tx) && sub_nf.2 ssn
  let seg_guard : TemporalPred :=
    ⟨formula_conjList (neg_between.map fun ssn =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
  let k := pos_between.length
  -- Step 3: Get witnesses for each pos_between SSN
  have h_pos_witnesses : ∀ ssn ∈ pos_between, ∃ y, x < y ∧ y < t ∧
      ∀ p, M.interp p y ↔ (nf_y_proj ssn) (.pred p ⟨0, by omega⟩) = true := by
    intro ssn h_mem
    rw [List.mem_filter] at h_mem
    obtain ⟨_, h_filter⟩ := h_mem
    simp only [Bool.and_eq_true, beq_iff_eq] at h_filter
    obtain ⟨⟨h_compat', h_zone⟩, h_pos⟩ := h_filter
    have h_exists := (h_eval_quant ssn).mpr h_pos
    exact (since_between_xt_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
      h_x_lt_t h_compat' h_zone
      (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                   have := h_atom (.pred p ⟨0, by omega⟩)
                   simp only [atom_eval] at this; exact this)
      (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                   simp only [atom_eval] at this; exact this)).mp h_exists
  let witness_fn : Fin k → M.carrier := fun i =>
    (h_pos_witnesses (pos_between.get i) (List.get_mem pos_between i)).choose
  have h_wit_spec : ∀ i, x < witness_fn i ∧ witness_fn i < t ∧
      ∀ p, M.interp p (witness_fn i) ↔ (nf_y_proj (pos_between.get i)) (.pred p ⟨0, by omega⟩) = true := by
    intro i
    exact (h_pos_witnesses (pos_between.get i) (List.get_mem pos_between i)).choose_spec
  -- Step 4: Prove witnesses are injective
  have h_wit_injective : Function.Injective witness_fn := by
    intro i j h_eq
    have h_pred_eq' : ∀ p, nf_y_proj (pos_between.get i) (.pred p ⟨0, by omega⟩) =
        nf_y_proj (pos_between.get j) (.pred p ⟨0, by omega⟩) := by
      intro p
      have hi := (h_wit_spec i).2.2 p
      have hj := (h_wit_spec j).2.2 p
      rw [h_eq] at hi
      exact Bool.eq_iff_iff.mpr (hi.symm.trans hj)
    have hi_mem := List.get_mem pos_between i
    have hj_mem := List.get_mem pos_between j
    rw [List.mem_filter] at hi_mem hj_mem
    obtain ⟨_, hi_filt⟩ := hi_mem
    obtain ⟨_, hj_filt⟩ := hj_mem
    simp only [Bool.and_eq_true, beq_iff_eq] at hi_filt hj_filt
    obtain ⟨⟨hi_compat, hi_zone⟩, _⟩ := hi_filt
    obtain ⟨⟨hj_compat, hj_zone⟩, _⟩ := hj_filt
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at hi_compat hj_compat
    obtain ⟨⟨⟨⟨hi_x, hi_t⟩, hi_ord1⟩, hi_ord2⟩, hi_ocons⟩ := hi_compat
    obtain ⟨⟨⟨⟨hj_x, hj_t⟩, hj_ord1⟩, hj_ord2⟩, hj_ocons⟩ := hj_compat
    -- Extract order atoms from since_zone_between_tx_orders
    have h_orders_i := since_zone_between_tx_orders (pos_between.get i) hi_zone
    have h_orders_j := since_zone_between_tx_orders (pos_between.get j) hj_zone
    have h_ssn_eq : pos_between.get i = pos_between.get j := by
      funext a
      cases a with
      | pred p k =>
        match k with
        | ⟨0, _⟩ => simp only [nf_y_proj] at h_pred_eq'; exact h_pred_eq' p
        | ⟨1, _⟩ => rw [hi_x p (Multiset.mem_toList.mpr (Fintype.complete p)), hj_x p (Multiset.mem_toList.mpr (Fintype.complete p))]
        | ⟨2, _⟩ => rw [hi_t p (Multiset.mem_toList.mpr (Fintype.complete p)), hj_t p (Multiset.mem_toList.mpr (Fintype.complete p))]
      | order k l h_ne =>
        match k, l, h_ne with
        | ⟨0, _⟩, ⟨1, _⟩, _ => rw [h_orders_i.2.2.1, h_orders_j.2.2.1]
        | ⟨1, _⟩, ⟨0, _⟩, _ => rw [h_orders_i.1, h_orders_j.1]
        | ⟨0, _⟩, ⟨2, _⟩, _ => rw [h_orders_i.2.1, h_orders_j.2.1]
        | ⟨2, _⟩, ⟨0, _⟩, _ => rw [h_orders_i.2.2.2, h_orders_j.2.2.2]
        | ⟨1, _⟩, ⟨2, _⟩, _ => rw [hi_ord2, hj_ord2]
        | ⟨2, _⟩, ⟨1, _⟩, _ => rw [hi_ord1, hj_ord1]
        | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
        | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
        | ⟨2, _⟩, ⟨2, _⟩, h => exact absurd rfl h
    have h_nodup : pos_between.Nodup :=
      List.Nodup.filter _
        (Multiset.coe_nodup.mp (by rw [Multiset.coe_toList]; exact Finset.nodup _))
    exact Fin.ext
      ((h_nodup.getElem_inj_iff (hi := i.isLt) (hj := j.isLt)).mp h_ssn_eq)
  -- Step 5: Sort witnesses and determine the permutation
  let wit_set : Finset M.carrier := Finset.image witness_fn Finset.univ
  have h_card : wit_set.card = k := by
    rw [Finset.card_image_of_injective _ h_wit_injective]; simp
  let sorted := wit_set.orderEmbOfFin h_card
  have sorted_is_witness : ∀ i : Fin k, ∃ j : Fin k, witness_fn j = sorted i := by
    intro i
    have h_mem := Finset.orderEmbOfFin_mem wit_set h_card i
    rw [Finset.mem_image] at h_mem
    obtain ⟨j, _, hj⟩ := h_mem
    exact ⟨j, hj⟩
  let sort_to_orig : Fin k → Fin k := fun i => (sorted_is_witness i).choose
  have h_sort_spec : ∀ i, witness_fn (sort_to_orig i) = sorted i := by
    intro i; exact (sorted_is_witness i).choose_spec
  have h_sort_inj : Function.Injective sort_to_orig := by
    intro i j h_eq
    have : sorted i = sorted j := by
      rw [← h_sort_spec i, ← h_sort_spec j, h_eq]
    exact sorted.injective this
  have h_sort_surj : Function.Surjective sort_to_orig := by
    exact Finite.surjective_of_injective h_sort_inj
  let σ : Equiv.Perm (Fin k) := Equiv.ofBijective sort_to_orig ⟨h_sort_inj, h_sort_surj⟩
  -- Step 6: Build the specific VecEA2 for permutation σ
  -- For Since: endRight = pre_conditions_at_t_since, endLeft = char_1(nf_x) + left conjuncts
  let endRight : TemporalPred :=
    ⟨pre_conditions_at_t_since atomMap h_surj sub_nf nf_x_1var parent_atoms⟩
  let left_conjuncts :=
    (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then
        let zone := ssn_zone_since ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .eq_t =>
          if sub_nf.2 ssn then some char_y
          else some char_y.neg
        | .below_t =>
          if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
          else some (Formula.snce char_y Formula.top).neg
        | _ => none
      else none
  let endLeft : TemporalPred :=
    ⟨Formula.and (char_1 nf_x) (formula_conjList left_conjuncts)⟩
  let the_bracket : BracketFormula k :=
    { pointTypes := fun i =>
        ⟨nf_depth0_char_formula atomMap h_surj (nf_y_proj (pos_between.get (σ i)))⟩
      segmentTypes := fun _ => seg_guard }
  let the_vea : Σ n, VecEA2 n :=
    ⟨k, VecEA2.mk endLeft endRight the_bracket⟩
  -- Show the_vea is in the flatMap list
  have h_mem_elems : nf_x ∈ Fintype.elems.val := Fintype.complete nf_x
  have h_σ_mem : σ ∈ (Fintype.elems (α := Equiv.Perm (Fin k))).val := Fintype.complete σ
  have h_vea_mem : the_vea ∈ List.flatMap
      (fun nf_x' => if nf_x_compat_check sub_nf nf_x' = true then
        enriched_vecEA2_since atomMap h_surj char_1 sub_nf nf_x'
          (fun a => match a with
            | .pred p _ => nf_x'.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          parent_atoms
      else []) Fintype.elems.val.toList := by
    rw [List.mem_flatMap]
    refine ⟨nf_x, Multiset.mem_toList.mpr h_mem_elems, ?_⟩
    simp only [h_compat, ite_true]
    simp only [enriched_vecEA2_since]
    rw [List.mem_map]
    exact ⟨σ, Multiset.mem_toList.mpr h_σ_mem, rfl⟩
  -- Step 7: Show holdsRight for the_vea
  refine ⟨the_vea, h_vea_mem, ?_⟩
  simp only [VecEA2.holdsRight]
  -- holdsRight = endpointRight at t ∧ ∃ x' < t, endpointLeft at x' ∧ bracket.holds(x', t)
  refine ⟨?endRight, x, h_x_lt_t, ?endLeft, ?bracket⟩
  case endRight =>
    simp only [TemporalPred.eval_at]
    exact pre_conditions_at_t_since_holds M atomMap h_surj sub_nf nf_x_1var parent_atoms x t
      h_x_lt_t
      (fun p => by
        obtain ⟨h_atom, _⟩ := h_nf_x
        have := h_atom (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at this
        exact this)
      (fun p => by
        have := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at this
        exact this)
      h_eval_quant
  case endLeft =>
    simp only [TemporalPred.eval_at]
    show temporal_truth M atomMap x (Formula.and (char_1 nf_x) (formula_conjList _))
    rw [temporal_truth_and]
    constructor
    · exact (char_1_correct nf_x M h_UZ h_SZ x).mpr h_nf_x
    · rw [formula_conjList_iff]
      intro φ h_mem
      rw [List.mem_filterMap] at h_mem
      obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
      split_ifs at h_some with h_compat' h_pos
      · revert h_some
        rcases h_zone : ssn_zone_since ssn with _ | _ | _ | _ | _ | _
        all_goals simp
        all_goals intro h_eq; subst h_eq
        -- pos.below_t (y < x): Since(char_y, top) at x
        · exact (since_below_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_x_lt_t
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mpr
            ((h_eval_quant ssn).mpr h_pos)
        -- pos.eq_t (y = x): char_y at x
        · exact (since_eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_x_lt_t
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mpr
            ((h_eval_quant ssn).mpr h_pos)
      · revert h_some
        rcases h_zone : ssn_zone_since ssn with _ | _ | _ | _ | _ | _
        all_goals simp
        all_goals intro h_eq; subst h_eq
        -- neg.below_t
        · simp only [Formula.neg, temporal_truth]
          intro h_since
          have h_exist := (since_below_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_x_lt_t
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mp h_since
          exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
        -- neg.eq_t
        · simp only [Formula.neg, temporal_truth]
          intro h_char
          have h_exist := (since_eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_x_lt_t
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mp h_char
          exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
  case bracket =>
    -- seg_guard holds everywhere in (x, t)
    have seg_guard_on_interval : ∀ y : M.carrier, x < y → y < t →
        seg_guard.eval_at M atomMap y := by
      intro y h_xy h_yt
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro φ h_φ_mem
      rw [List.mem_map] at h_φ_mem
      obtain ⟨ssn, h_ssn_mem, h_φ_eq⟩ := h_φ_mem
      subst h_φ_eq
      rw [List.mem_filter] at h_ssn_mem
      obtain ⟨_, h_filter⟩ := h_ssn_mem
      simp only [Bool.and_eq_true, beq_iff_eq, Bool.not_eq_eq_eq_not, Bool.not_true] at h_filter
      obtain ⟨⟨h_compat', h_zone⟩, h_neg⟩ := h_filter
      simp only [Formula.neg, temporal_truth]
      intro h_char_y
      have h_bridge := (since_between_xt_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
        h_x_lt_t h_compat' h_zone
        (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                     have := h_atom (.pred p ⟨0, by omega⟩)
                     simp only [atom_eval] at this; exact this)
        (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                     simp only [atom_eval] at this; exact this)).mpr
      have h_no_witness : ¬ ∃ z, nf_eval_nf M 0 (1 + 1 + 1)
          (Fin.cons z (Fin.cons x fun _ => t)) ssn := by
        rw [h_eval_quant ssn]; simp [h_neg]
      apply h_no_witness; apply h_bridge
      exact ⟨y, h_xy, h_yt, fun p => by
        rw [nf_depth0_char_formula_correct] at h_char_y
        have := h_char_y p; simp only [nf_y_proj] at this; exact this⟩
    -- Sorted witnesses for the bracket
    let sorted_fn : Fin k → M.carrier := fun i => sorted i
    have h_sorted_eq_wit : ∀ i, sorted_fn i = witness_fn (σ i) := by
      intro i; exact (h_sort_spec i).symm
    have h_sorted_mono : StrictMono sorted_fn := by
      intro i j h_ij; exact sorted.strictMono h_ij
    have h_sorted_in_interval : ∀ i, x < sorted_fn i ∧ sorted_fn i < t := by
      intro i
      rw [h_sorted_eq_wit i]
      exact ⟨(h_wit_spec (σ i)).1, (h_wit_spec (σ i)).2.1⟩
    have h_sorted_ptType : ∀ i, (the_bracket.pointTypes i).eval_at M atomMap (sorted_fn i) := by
      intro i
      simp only [TemporalPred.eval_at]
      rw [h_sorted_eq_wit i]
      rw [nf_depth0_char_formula_correct]
      exact fun p => (h_wit_spec (σ i)).2.2 p
    exact bracket_from_sorted_witnesses M atomMap k x t h_x_lt_t
      the_bracket.pointTypes seg_guard sorted_fn
      h_sorted_mono h_sorted_in_interval h_sorted_ptType seg_guard_on_interval

/-! ## Since Case (x < t) -/

/-- Since case of the enriched bypass: when sub_nf says x < t. -/
theorem existPart_succ_n1_bypass_k0_since
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
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Mirror of existPart_succ_n1_bypass_k0_until for the Since direction (x < t).
  -- Syntactic compatibility checks for sub_nf.
  let ref_nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  by_cases h_t_compat : ∀ p : sig.preds,
      sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩)
  · by_cases h_ssn_compat : ∀ ssn : NormalForm sig 0 3,
        sub_nf.2 ssn = true →
        ssn_xt_compatible ssn ref_nf_x_1var parent_atoms false true = true
    · -- Both checks pass: use enriched_bypass_since with VecEA2 infrastructure
      let vvec := enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms
      exact ⟨vvec, fun M h_UZ h_SZ t h_atoms => by
        show temporal_truth M atomMap t (enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms) ↔ _
        simp only [enriched_bypass_since]
        rw [VVecEA2.translateRight_correct]
        simp only [VVecEA2.holdsRight]
        constructor
        · -- Forward: holdsRight → ∃ x, nf_eval
          exact forward_nf_eval_of_holdsRight atomMap h_surj char_1 char_1_correct
            parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms h_t_compat h_ssn_compat
        · -- Backward: ∃ x, nf_eval → holdsRight
          exact backward_holdsRight_of_nf_eval atomMap h_surj char_1 char_1_correct
            parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms⟩
    · -- ¬ssn_compat: some positive ssn is xt-incompatible → existential unsatisfiable
      push_neg at h_ssn_compat
      obtain ⟨ssn_bad, h_pos_bad, h_incompat_bad⟩ := h_ssn_compat
      refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
      simp only [temporal_truth]
      constructor
      · exact fun h => absurd h id
      · intro ⟨x, h_eval⟩
        obtain ⟨h_atom, h_quant⟩ := h_eval
        have ⟨y, h_ssn_eval⟩ := (h_quant ssn_bad).mpr h_pos_bad
        have h_x_pred : ∀ p : sig.preds,
            M.interp p x ↔ ref_nf_x_1var (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_atom (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
        have h_t_pred : ∀ p : sig.preds,
            M.interp p t₀ ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at h; exact h
        have h_x_lt_t : x < t₀ := by
          have h := h_atom (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
          unfold atom_eval at h; exact h.mpr h_lt
        have h_xt_compat : ssn_xt_compatible ssn_bad ref_nf_x_1var parent_atoms false true = true := by
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
          refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
          · -- x-preds
            intro p _
            have h1 := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h1
            cases hsub : (ref_nf_x_1var (.pred p ⟨0, by omega⟩) : Bool) <;>
            cases hssn : ssn_bad (.pred p ⟨1, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- t-preds
            intro p _
            have h1 : M.interp p t₀ ↔ ssn_bad (.pred p ⟨2, by omega⟩) = true := by
              have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
            have h2 := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at h2
            cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
            cases hssn : ssn_bad (.pred p ⟨2, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- ¬(t < x) order: ssn_bad (.order ⟨2,_⟩ ⟨1,_⟩ _) = false
            have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            unfold atom_eval at h
            cases hssn : ssn_bad (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            · rfl
            · exact absurd (h.mpr hssn) (not_lt_of_gt h_x_lt_t)
          · -- x < t order: ssn_bad (.order ⟨1,_⟩ ⟨2,_⟩ _) = true
            have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            unfold atom_eval at h; exact h.mp h_x_lt_t
          · exact ssn_order_consistent_of_eval ssn_bad h_ssn_eval
        exact absurd h_xt_compat h_incompat_bad
  · -- ¬t_compat: existential impossible (atom at index 1 can't match)
    refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
    simp only [temporal_truth]
    constructor
    · exact fun h => absurd h id
    · intro ⟨x, h_eval⟩
      push_neg at h_t_compat; obtain ⟨p, hp⟩ := h_t_compat
      obtain ⟨h_atom, _⟩ := h_eval
      have h_sub : M.interp p t₀ ↔ sub_nf.1 (.pred p ⟨1, by omega⟩) = true := by
        have h := h_atom (.pred p ⟨1, by omega⟩); unfold atom_eval at h; exact h
      have h_par := (h_atoms (.pred p ⟨0, by omega⟩))
      simp only [atom_eval] at h_par
      cases hsub : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
      cases hpar : parent_atoms (.pred p ⟨0, by omega⟩)
      · exact hp (by rw [hsub, hpar])
      · exact absurd (h_sub.mp (h_par.mpr hpar)) (by rw [hsub]; exact Bool.false_ne_true)
      · exact absurd (h_par.mp (h_sub.mpr hsub)) (by rw [hpar]; exact Bool.false_ne_true)
      · exact hp (by rw [hsub, hpar])


end Bimodal.Metalogic.WeakCanonical.Kamp

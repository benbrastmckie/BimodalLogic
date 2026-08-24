import FormalSystem.Boneyard.Kamp.KampBypassArchive.KampBypassCore

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Zone-to-Temporal Bridge Helpers

Connects zone bridge lemmas from ZoneBridge.lean to the temporal formula
encoding used by the enriched bypass formula. Also provides bracket
construction and extraction helpers for the Until and Since directions.

Split from KampBypassCore.lean for modularity.
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Zone-to-Temporal Bridge Helpers

These helpers extract x and t predicates from ssn_xt_compatible and connect
zone bridge lemmas from ZoneBridge.lean to the temporal formula encoding. -/

/-- Extract x-predicate conditions from ssn_xt_compatible. -/
theorem ssn_xt_compat_x_preds {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) (x_gt_t x_lt_t : Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms x_gt_t x_lt_t = true) :
    ∀ p : sig.preds, ssn (.pred p ⟨1, by omega⟩) = nf_x_1var (.pred p ⟨0, by omega⟩) := by
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
  intro p
  exact h_compat.1.1.1.1 p (Multiset.mem_toList.mpr (Fintype.complete p))

/-- Extract t-predicate conditions from ssn_xt_compatible. -/
theorem ssn_xt_compat_t_preds {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) (x_gt_t x_lt_t : Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms x_gt_t x_lt_t = true) :
    ∀ p : sig.preds, ssn (.pred p ⟨2, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩) := by
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
  intro p
  exact h_compat.1.1.1.2 p (Multiset.mem_toList.mpr (Fintype.complete p))

/-- Extract t < x order condition from ssn_xt_compatible (Until direction). -/
theorem ssn_xt_compat_tx_order {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true) :
    ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
  exact ⟨h_compat.1.1.2, h_compat.1.2⟩

/-! ## Zone order extraction from ssn_zone_until

These helpers extract the 6 order atom values from `ssn_zone_until ssn = zone`.
Combined with `ssn_xt_compatible ... true false = true`, they give all 6 order atoms
needed by the zone bridge theorems in ZoneBridge.lean. -/

set_option maxHeartbeats 400000 in
private theorem zone_below_t_yt {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.below_t) :
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
private theorem zone_below_t_ty {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.below_t) :
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
private theorem zone_eq_t_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.eq_t) :
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
private theorem zone_eq_x_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.eq_x) :
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
private theorem zone_above_x_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.above_x) :
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
private theorem zone_between_tx_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.between_tx) :
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

/-! ## Below_t / eq_t bridge: temporal formula ↔ 3-var existential

These connect the temporal formulas (Since/char_y) used in pre_conditions_at_t_until
to the 3-var existentials tracked by h_eval_quant. -/

/-- For below_t zone with compatible ssn: Since(char_y, top) at t ↔ ∃ y, nf_eval_nf. -/
theorem below_t_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.below_t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap t
      (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have h_yt := zone_below_t_yt ssn h_zone
  have h_ty := zone_below_t_ty ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn : ∀ p, ssn (.pred p ⟨1, by omega⟩) = nf_x_1var (.pred p ⟨0, by omega⟩) :=
    ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn : ∀ p, ssn (.pred p ⟨2, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩) :=
    ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_bridge := zone_bridge_below_t M ssn x t h_tx h_yt h_yx h_ty h_xy h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
  constructor
  · intro ⟨y, h_yt_lt, h_char_y, _⟩
    rw [h_bridge]
    refine ⟨y, h_yt_lt, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    exact h_char_y
  · intro h_exist
    rw [h_bridge] at h_exist
    obtain ⟨y, h_yt_lt, h_y_preds⟩ := h_exist
    exact ⟨y, h_yt_lt,
      (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr h_y_preds,
      fun z _ _ => by simp [temporal_truth, Formula.top]⟩

/-- For eq_t zone with compatible ssn: char_y at t ↔ ∃ y, nf_eval_nf. -/
theorem eq_t_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.eq_t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_yt, h_ty⟩ := zone_eq_t_orders ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_bridge := zone_bridge_eq_t M ssn x t h_tx h_yt h_ty h_yx h_xy h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
  constructor
  · intro h_char_y
    rw [h_bridge]
    rw [nf_depth0_char_formula_correct] at h_char_y
    exact h_char_y
  · intro h_exist
    rw [h_bridge] at h_exist
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) t).mpr h_exist

set_option maxHeartbeats 800000 in
/-- For eq_x zone with compatible ssn: char_y at x ↔ ∃ y, nf_eval_nf. -/
theorem eq_x_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.eq_x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_yx, h_xy, h_ty, h_yt⟩ := zone_eq_x_orders ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_bridge := zone_bridge_eq_x M ssn x t h_tx h_yx h_xy h_ty h_yt h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
  constructor
  · intro h_char_y
    rw [h_bridge]
    rw [nf_depth0_char_formula_correct] at h_char_y
    exact h_char_y
  · intro h_exist
    rw [h_bridge] at h_exist
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) x).mpr h_exist

set_option maxHeartbeats 800000 in
/-- For above_x zone with compatible ssn: Until(char_y, top) at x ↔ ∃ y, nf_eval_nf. -/
theorem above_x_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.above_x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap x
      (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_xy, h_yx, h_ty, h_yt⟩ := zone_above_x_orders ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_bridge := zone_bridge_above_x M ssn x t h_tx h_xy h_ty h_yx h_yt h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
  constructor
  · intro ⟨y, h_xy_lt, h_char_y, _⟩
    rw [h_bridge]
    refine ⟨y, h_xy_lt, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    exact h_char_y
  · intro h_exist
    rw [h_bridge] at h_exist
    obtain ⟨y, h_xy_lt, h_y_preds⟩ := h_exist
    exact ⟨y, h_xy_lt,
      (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr h_y_preds,
      fun z _ _ => by simp [temporal_truth, Formula.top]⟩

/-- The pre_conditions_at_t_until formula holds at t when h_eval_quant
    guarantees the correct truth values for all zone-based ssn conditions. -/
theorem pre_conditions_at_t_until_holds
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true)
    (h_eval_quant : ∀ (ssn : NormalForm sig 0 3),
      (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
      sub_nf.2 ssn = true) :
    temporal_truth M atomMap t
      (pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms) := by
  simp only [pre_conditions_at_t_until]
  rw [formula_conjList_iff]
  intro φ h_mem
  rw [List.mem_filterMap] at h_mem
  obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
  split_ifs at h_some with h_compat h_pos
  · -- Compatible and positive: zone determines the formula
    revert h_some
    rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
    all_goals simp
    all_goals intro h_eq; subst h_eq
    -- pos.below_t
    · exact (below_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
        h_compat h_zone h_x_pred h_t_pred).mpr ((h_eval_quant ssn).mpr h_pos)
    -- pos.eq_t
    · exact (eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
        h_compat h_zone h_x_pred h_t_pred).mpr ((h_eval_quant ssn).mpr h_pos)
  · -- Compatible and negative: zone determines the negated formula
    revert h_some
    rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
    all_goals simp
    all_goals intro h_eq; subst h_eq
    -- neg.below_t
    · simp only [Formula.neg, temporal_truth]
      intro h_since
      have h_exist := (below_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
        h_compat h_zone h_x_pred h_t_pred).mp h_since
      exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
    -- neg.eq_t
    · simp only [Formula.neg, temporal_truth]
      intro h_char
      have h_exist := (eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
        h_compat h_zone h_x_pred h_t_pred).mp h_char
      exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
/-! ## Between_tx bridge and bracket helpers -/

set_option maxHeartbeats 800000 in
/-- For between_tx zone with compatible ssn: temporal bridge to 3-var existential. -/
theorem between_tx_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.between_tx)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∃ y, t < y ∧ y < x ∧ ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  have ⟨h_ty, h_yx, h_yt, h_xy⟩ := zone_between_tx_orders ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  exact zone_bridge_between_tx M ssn x t h_tx h_ty h_yx h_yt h_xy h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))

theorem between_tx_order_atoms {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (h : ssn_zone_until ssn = YZone.between_tx) :
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
  simp only [ssn_zone_until] at h
  revert h; split_ifs <;> simp_all [Bool.and_eq_true]

/-! ## Until Case: Forward and Backward Helper Lemmas -/

/-- Given k strictly increasing points in an open interval (lo, hi),
    the bracket formula with per-point pointTypes and constant segmentType holds,
    provided each point satisfies its pointType and the segmentType holds
    everywhere in (lo, hi). -/
theorem bracket_from_sorted_witnesses {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (k : Nat) (lo hi : M.carrier) (h_lo_hi : lo < hi)
    (pointTypes : Fin k → TemporalPred) (segType : TemporalPred)
    (witnesses : Fin k → M.carrier)
    (h_strict_mono : StrictMono witnesses)
    (h_in_interval : ∀ i, lo < witnesses i ∧ witnesses i < hi)
    (h_ptType : ∀ i, (pointTypes i).eval_at M atomMap (witnesses i))
    (h_segType : ∀ y, lo < y → y < hi → segType.eval_at M atomMap y) :
    (BracketFormula.mk pointTypes (fun _ : Fin (k + 1) => segType)).holds
      M atomMap lo hi := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
  match k, pointTypes, witnesses, h_strict_mono, h_in_interval, h_ptType with
  | 0, _, _, _, _, _ =>
    simp only [IntervalPattern.holds]
    exact h_segType
  | k' + 1, pointTypes, witnesses, h_strict_mono, h_in_interval, h_ptType =>
    simp only [IntervalPattern.holds]
    refine ⟨witnesses, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j h_ij; exact h_strict_mono h_ij
    · exact h_in_interval
    · exact h_ptType
    · intro y h_lo_y h_y_w0
      exact h_segType y h_lo_y (lt_trans h_y_w0 (h_in_interval ⟨0, by omega⟩).2)
    · intro i y h_wi_y h_y_wi1
      exact h_segType y (lt_trans (h_in_interval ⟨i.val, by omega⟩).1 h_wi_y)
        (lt_trans h_y_wi1 (h_in_interval ⟨i.val + 1, by omega⟩).2)
    · intro y h_wk_y h_y_hi
      exact h_segType y (lt_trans (h_in_interval ⟨k', by omega⟩).1 h_wk_y) h_y_hi

/-- Given k distinct points in an open interval (lo, hi) of a linear order,
    the bracket formula with constant pointType and constant segmentType holds,
    provided each point satisfies the pointType and the segmentType holds
    everywhere in (lo, hi). -/
theorem bracket_from_distinct_witnesses {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (k : Nat) (lo hi : M.carrier) (h_lo_hi : lo < hi)
    (ptType segType : TemporalPred)
    (witnesses : Fin k → M.carrier)
    (h_in_interval : ∀ i, lo < witnesses i ∧ witnesses i < hi)
    (h_injective : Function.Injective witnesses)
    (h_ptType : ∀ i, ptType.eval_at M atomMap (witnesses i))
    (h_segType : ∀ y, lo < y → y < hi → segType.eval_at M atomMap y) :
    (BracketFormula.mk (fun _ : Fin k => ptType) (fun _ : Fin (k + 1) => segType)).holds
      M atomMap lo hi := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
  match k, witnesses, h_in_interval, h_injective, h_ptType with
  | 0, _, _, _, _ =>
    simp only [IntervalPattern.holds]
    exact h_segType
  | k' + 1, witnesses, h_in_interval, h_injective, h_ptType =>
    simp only [IntervalPattern.holds]
    let wit_set : Finset M.carrier := Finset.image witnesses Finset.univ
    have h_card : wit_set.card = k' + 1 := by
      rw [Finset.card_image_of_injective _ h_injective]
      simp
    have sorted_is_witness : ∀ i, ∃ j, witnesses j = (wit_set.orderEmbOfFin h_card) i := by
      intro i
      have h_mem := Finset.orderEmbOfFin_mem wit_set h_card i
      rw [Finset.mem_image] at h_mem
      obtain ⟨j, _, hj⟩ := h_mem
      exact ⟨j, hj⟩
    let sorted := wit_set.orderEmbOfFin h_card
    refine ⟨sorted, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j h_ij; exact sorted.strictMono h_ij
    · intro i
      obtain ⟨j, hj⟩ := sorted_is_witness i
      rw [← hj]; exact h_in_interval j
    · intro i
      obtain ⟨j, hj⟩ := sorted_is_witness i
      rw [← hj]; exact h_ptType j
    · intro y h_lo_y h_y_w0
      obtain ⟨j, hj⟩ := sorted_is_witness ⟨0, by omega⟩
      exact h_segType y h_lo_y (by rw [← hj] at h_y_w0; exact lt_trans h_y_w0 (h_in_interval j).2)
    · intro i y h_wi_y h_y_wi1
      obtain ⟨j_lo, hj_lo⟩ := sorted_is_witness ⟨i.val, by omega⟩
      obtain ⟨j_hi, hj_hi⟩ := sorted_is_witness ⟨i.val + 1, by omega⟩
      rw [← hj_lo] at h_wi_y; rw [← hj_hi] at h_y_wi1
      exact h_segType y (lt_trans (h_in_interval j_lo).1 h_wi_y)
        (lt_trans h_y_wi1 (h_in_interval j_hi).2)
    · intro y h_wk_y h_y_hi
      obtain ⟨j, hj⟩ := sorted_is_witness ⟨k', by omega⟩
      rw [← hj] at h_wk_y
      exact h_segType y (lt_trans (h_in_interval j).1 h_wk_y) h_y_hi

theorem bracket_extract_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (k : Nat) (lo hi : M.carrier)
    (pointTypes : Fin k → TemporalPred) (segType : Fin (k + 1) → TemporalPred)
    (h : (BracketFormula.mk pointTypes segType).holds M atomMap lo hi)
    (i : Fin k) :
    ∃ w, lo < w ∧ w < hi ∧ (pointTypes i).eval_at M atomMap w := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at h
  match k, pointTypes, segType, h, i with
  | k' + 1, pointTypes, segType, h, i =>
    simp only [IntervalPattern.holds] at h
    obtain ⟨witnesses, _, h_bounds, h_ptypes, _, _, _⟩ := h
    exact ⟨witnesses i, (h_bounds i).1, (h_bounds i).2, h_ptypes i⟩

theorem bracket_constant_seg_dichotomy {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (k : Nat) (lo hi : M.carrier)
    (pointTypes : Fin k → TemporalPred) (segType : TemporalPred)
    (h : (BracketFormula.mk pointTypes (fun _ : Fin (k + 1) => segType)).holds
      M atomMap lo hi)
    (y : M.carrier) (h_lo_y : lo < y) (h_y_hi : y < hi) :
    segType.eval_at M atomMap y ∨ ∃ i : Fin k, (pointTypes i).eval_at M atomMap y := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at h
  match k, pointTypes, h with
  | 0, _, h =>
    simp only [IntervalPattern.holds] at h
    exact Or.inl (h y h_lo_y h_y_hi)
  | k' + 1, pointTypes, h =>
    simp only [IntervalPattern.holds] at h
    obtain ⟨witnesses, h_mono, h_bounds, h_ptypes, h_seg0, h_seg_mid, h_seg_last⟩ := h
    by_cases h_y_lt_w0 : y < witnesses ⟨0, by omega⟩
    · exact Or.inl (h_seg0 y h_lo_y h_y_lt_w0)
    · push_neg at h_y_lt_w0
      by_cases h_y_gt_wk : witnesses ⟨k', by omega⟩ < y
      · exact Or.inl (h_seg_last y h_y_gt_wk h_y_hi)
      · push_neg at h_y_gt_wk
        suffices ∃ i : Fin (k' + 1),
            y = witnesses i ∨
            (∃ j : Fin k', witnesses ⟨j.val, by omega⟩ < y ∧
              y < witnesses ⟨j.val + 1, by omega⟩) by
          obtain ⟨i, h_case⟩ := this
          rcases h_case with h_eq | ⟨j, h_wj_y, h_y_wj1⟩
          · exact Or.inr ⟨i, h_eq ▸ h_ptypes i⟩
          · exact Or.inl (h_seg_mid j y h_wj_y h_y_wj1)
        by_contra h_none; push_neg at h_none
        have h_le_all : ∀ i : Fin (k' + 1), witnesses i ≤ y := by
          intro ⟨i, hi⟩
          induction i with
          | zero => exact h_y_lt_w0
          | succ n ih =>
            have h_prev := ih (by omega)
            have h_ne := (h_none ⟨n, by omega⟩).1
            have h_lt : witnesses ⟨n, by omega⟩ < y := lt_of_le_of_ne h_prev h_ne.symm
            exact (h_none ⟨n + 1, hi⟩).2 ⟨n, by omega⟩ h_lt
        exact absurd (le_antisymm h_y_gt_wk (h_le_all ⟨k', by omega⟩))
          (h_none ⟨k', by omega⟩).1

end FormalSystem.Metalogic.WeakCanonical.Kamp

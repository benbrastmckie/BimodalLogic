import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp

/-!
# Zone Bridge Lemmas

Standalone lemmas that bridge between the existential
`∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn`
and simple 1-var existential conditions (zone + predicates).

Each zone gives a specific order condition on y relative to x and t:
- `above_x`: y > x (and hence y > t since t < x)
- `between_tx`: t < y < x
- `below_t`: y < t
- `eq_x`: y = x
- `eq_t`: y = t

These are extracted from KampBypass.lean's complex nested context into
self-contained lemmas with simple type signatures.

## References

- VecEADecomp.lean: `extract_y_nf`, zone decomposition patterns
- KampBypass.lean: `ssn_zone_until`, `ssn_xt_compatible`, `YZone`
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Fin.cons evaluation helpers

Key fact: `Fin.cons y (Fin.cons x (fun _ => t))` maps:
- Index 0 → y
- Index 1 → x
- Index 2 → t -/

private theorem fin_cons_eval_0 {α : Type} (y x : α) (rest : Fin 1 → α) :
    (Fin.cons y (Fin.cons x rest) : Fin 3 → α) ⟨0, by omega⟩ = y := by
  simp [Fin.cons]

private theorem fin_cons_eval_1 {α : Type} (y x : α) (rest : Fin 1 → α) :
    (Fin.cons y (Fin.cons x rest) : Fin 3 → α) ⟨1, by omega⟩ = x := by
  simp [Fin.cons]; rfl

private theorem fin_cons_eval_2 {α : Type} (y x t : α) :
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → α) ⟨2, by omega⟩ = t := by
  simp [Fin.cons]; rfl

/-! ## Core reconstruction lemma (inlined from VecEADecomp's private helper)

Reconstructs a 3-var depth-0 NF evaluation from predicate + order facts. -/

/-- Reconstruct `nf_eval_nf M 0 3 env ssn` from:
    1. Predicate satisfaction at y (var 0), x (var 1), t (var 2)
    2. Order iff-conditions for all 6 pairs -/
theorem reconstruct_nf_eval_3var {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_y_preds : ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true)
    (h_x_preds : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_preds : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true)
    (h_o_yx : (y < x) ↔ (ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true))
    (h_o_yt : (y < t) ↔ (ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true))
    (h_o_xy : (x < y) ↔ (ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true))
    (h_o_xt : (x < t) ↔ (ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true))
    (h_o_ty : (t < y) ↔ (ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true))
    (h_o_tx : (t < x) ↔ (ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)) :
    nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    simp only [atom_eval, Fin.cons]
    exact h_y_preds p
  | .pred p ⟨1, _⟩ =>
    simp only [atom_eval]
    have hfc : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x :=
      fin_cons_eval_1 y x _
    rw [hfc]; exact h_x_preds p
  | .pred p ⟨2, _⟩ =>
    simp only [atom_eval]
    have hfc : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨2, by omega⟩ = t :=
      fin_cons_eval_2 y x t
    rw [hfc]; exact h_t_preds p
  | .pred _ ⟨n + 3, h⟩ => exact absurd h (by omega)
  | .order ⟨0, _⟩ ⟨0, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨0, _⟩ ⟨1, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_yx
  | .order ⟨0, _⟩ ⟨2, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_yt
  | .order ⟨1, _⟩ ⟨0, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_xy
  | .order ⟨1, _⟩ ⟨1, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨1, _⟩ ⟨2, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_xt
  | .order ⟨2, _⟩ ⟨0, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_ty
  | .order ⟨2, _⟩ ⟨1, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_tx
  | .order ⟨2, _⟩ ⟨2, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨n + 3, h⟩ _ _ => exact absurd h (by omega)
  | .order _ ⟨n + 3, h⟩ _ => exact absurd h (by omega)

/-! ## Extract predicates from 3-var NF evaluation -/

/-- Extract y's predicates from a 3-var NF evaluation. -/
theorem extract_y_preds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true := by
  intro p
  have h := h_nf (.pred p ⟨0, by omega⟩)
  simp only [atom_eval, Fin.cons] at h
  exact h

/-- Extract an order fact from a 3-var NF evaluation. -/
theorem extract_order {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (env : Fin 3 → M.carrier)
    (i j : Fin 3) (h_ne : i ≠ j)
    (h_nf : nf_eval_nf M 0 3 env ssn) :
    (env i < env j) ↔ (ssn (.order i j h_ne) = true) := by
  have h := h_nf (.order i j h_ne)
  simp only [atom_eval] at h
  exact h

/-! ## Zone Bridge: y > x (above_x)

When ssn's order atoms say x < y and t < y (and the reverses are false),
the existential `∃ y` with the full 3-var NF evaluation reduces to
`∃ y, x < y ∧ predicates_match_at_y`. -/

/-- Zone above_x: `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` iff
    `∃ y, x < y ∧ predicates_match_at_y`, given the order profile. -/
theorem zone_bridge_above_x {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (x t : M.carrier) (h_tx : t < x)
    -- ssn order profile for above_x zone
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_tx_ssn : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_xt_ssn : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    -- x and t predicates match ssn
    (h_x_preds : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_preds : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∃ y, x < y ∧ ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  constructor
  · -- Forward: extract from NF evaluation
    intro ⟨y, h_nf⟩
    refine ⟨y, ?_, extract_y_preds M ssn y x t h_nf⟩
    -- x < y from order atom (1, 0)
    have h_ord := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord
    rw [fin_cons_eval_1, fin_cons_eval_0] at h_ord
    exact h_ord.mpr h_xy
  · -- Backward: reconstruct NF evaluation
    intro ⟨y, h_y_gt_x, h_y_preds⟩
    refine ⟨y, ?_⟩
    apply reconstruct_nf_eval_3var M ssn y x t h_y_preds h_x_preds h_t_preds
    · -- y < x ↔ false
      constructor
      · intro h; exact absurd (lt_trans h h_y_gt_x) (lt_irrefl _)
      · intro h; simp_all
    · -- y < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h (lt_trans h_tx h_y_gt_x)) (lt_irrefl _)
      · intro h; simp_all
    · -- x < y ↔ true
      exact ⟨fun _ => h_xy, fun _ => h_y_gt_x⟩
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_tx h) (lt_irrefl _)
      · intro h; simp_all
    · -- t < y ↔ true
      exact ⟨fun _ => h_ty, fun _ => lt_trans h_tx h_y_gt_x⟩
    · -- t < x ↔ true
      exact ⟨fun _ => h_tx_ssn, fun _ => h_tx⟩

/-! ## Zone Bridge: t < y < x (between_tx)

When ssn's order atoms say t < y and y < x, the existential reduces to
`∃ y, t < y ∧ y < x ∧ predicates_match_at_y`. -/

/-- Zone between_tx: `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` iff
    `∃ y, t < y ∧ y < x ∧ predicates_match_at_y`. -/
theorem zone_bridge_between_tx {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (x t : M.carrier) (h_tx : t < x)
    -- ssn order profile for between_tx zone
    (h_ty_ssn : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)  -- t < y
    (h_yx_ssn : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- y < x
    (h_yt_ssn : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(y < t)
    (h_xy_ssn : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false) -- ¬(x < y)
    (h_tx_ssn : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- t < x
    (h_xt_ssn : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(x < t)
    -- x and t predicates match ssn
    (h_x_preds : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_preds : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∃ y, t < y ∧ y < x ∧ ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  constructor
  · -- Forward
    intro ⟨y, h_nf⟩
    refine ⟨y, ?_, ?_, extract_y_preds M ssn y x t h_nf⟩
    · -- t < y
      have h_ord := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval] at h_ord
      rw [fin_cons_eval_2, fin_cons_eval_0] at h_ord
      exact h_ord.mpr h_ty_ssn
    · -- y < x
      have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
      simp only [atom_eval] at h_ord
      rw [fin_cons_eval_0, fin_cons_eval_1] at h_ord
      exact h_ord.mpr h_yx_ssn
  · -- Backward
    intro ⟨y, h_ty, h_yx, h_y_preds⟩
    refine ⟨y, ?_⟩
    apply reconstruct_nf_eval_3var M ssn y x t h_y_preds h_x_preds h_t_preds
    · -- y < x ↔ true
      exact ⟨fun _ => h_yx_ssn, fun _ => h_yx⟩
    · -- y < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h h_ty) (lt_irrefl _)
      · intro h; simp_all
    · -- x < y ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_yx h) (lt_irrefl _)
      · intro h; simp_all
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_tx h) (lt_irrefl _)
      · intro h; simp_all
    · -- t < y ↔ true
      exact ⟨fun _ => h_ty_ssn, fun _ => h_ty⟩
    · -- t < x ↔ true
      exact ⟨fun _ => h_tx_ssn, fun _ => h_tx⟩

/-! ## Zone Bridge: y < t (below_t)

When ssn's order atoms say y < t (and hence y < x by transitivity),
the existential reduces to `∃ y, y < t ∧ predicates_match_at_y`. -/

/-- Zone below_t: `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` iff
    `∃ y, y < t ∧ predicates_match_at_y`. -/
theorem zone_bridge_below_t {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (x t : M.carrier) (h_tx : t < x)
    -- ssn order profile for below_t zone
    (h_yt_ssn : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)  -- y < t
    (h_yx_ssn : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- y < x
    (h_ty_ssn : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false) -- ¬(t < y)
    (h_xy_ssn : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false) -- ¬(x < y)
    (h_tx_ssn : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- t < x
    (h_xt_ssn : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(x < t)
    -- x and t predicates match ssn
    (h_x_preds : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_preds : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∃ y, y < t ∧ ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  constructor
  · -- Forward
    intro ⟨y, h_nf⟩
    refine ⟨y, ?_, extract_y_preds M ssn y x t h_nf⟩
    -- y < t
    have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord
    rw [fin_cons_eval_0, fin_cons_eval_2] at h_ord
    exact h_ord.mpr h_yt_ssn
  · -- Backward
    intro ⟨y, h_y_lt_t, h_y_preds⟩
    refine ⟨y, ?_⟩
    apply reconstruct_nf_eval_3var M ssn y x t h_y_preds h_x_preds h_t_preds
    · -- y < x ↔ true
      exact ⟨fun _ => h_yx_ssn, fun _ => lt_trans h_y_lt_t h_tx⟩
    · -- y < t ↔ true
      exact ⟨fun _ => h_yt_ssn, fun _ => h_y_lt_t⟩
    · -- x < y ↔ false
      constructor
      · intro h; exact absurd (lt_trans (lt_trans h_y_lt_t h_tx) h) (lt_irrefl _)
      · intro h; simp_all
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_tx h) (lt_irrefl _)
      · intro h; simp_all
    · -- t < y ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_y_lt_t h) (lt_irrefl _)
      · intro h; simp_all
    · -- t < x ↔ true
      exact ⟨fun _ => h_tx_ssn, fun _ => h_tx⟩

/-! ## Zone Bridge: y = x (eq_x)

When ssn says ¬(y < x) ∧ ¬(x < y), i.e., y = x,
the existential collapses: the witness is x itself. -/

/-- Zone eq_x: `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` iff
    `predicates_of_y_match_at_x`, i.e., nf_eval with y = x. -/
theorem zone_bridge_eq_x {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (x t : M.carrier) (h_tx : t < x)
    -- ssn order profile for eq_x zone: ¬(y < x), ¬(x < y), t < y
    (h_yx_ssn : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false) -- ¬(y < x)
    (h_xy_ssn : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false) -- ¬(x < y)
    (h_ty_ssn : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)  -- t < y (= t < x)
    (h_yt_ssn : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(y < t)
    (h_tx_ssn : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- t < x
    (h_xt_ssn : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(x < t)
    -- x and t predicates match ssn
    (h_x_preds : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_preds : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∀ p, M.interp p x ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  constructor
  · -- Forward: extract from NF. y must equal x since ¬(y<x) ∧ ¬(x<y)
    intro ⟨y, h_nf⟩
    -- y = x because ssn says ¬(y < x) ∧ ¬(x < y)
    have h_not_yx : ¬(y < x) := by
      intro h
      have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
      simp only [atom_eval] at h_ord
      rw [fin_cons_eval_0, fin_cons_eval_1] at h_ord
      exact absurd (h_ord.mp h) (by simp_all)
    have h_not_xy : ¬(x < y) := by
      intro h
      have h_ord := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval] at h_ord
      rw [fin_cons_eval_1, fin_cons_eval_0] at h_ord
      exact absurd (h_ord.mp h) (by simp_all)
    have h_eq : y = x := le_antisymm (le_of_not_gt h_not_xy) (le_of_not_gt h_not_yx)
    subst h_eq
    exact extract_y_preds M ssn y y t h_nf
  · -- Backward: y = x
    intro h_y_preds
    refine ⟨x, ?_⟩
    apply reconstruct_nf_eval_3var M ssn x x t h_y_preds h_x_preds h_t_preds
    · -- x < x ↔ false
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_tx h) (lt_irrefl _)
      · intro h; simp_all
    · -- x < x ↔ false
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_tx h) (lt_irrefl _)
      · intro h; simp_all
    · -- t < x ↔ true
      exact ⟨fun _ => h_ty_ssn, fun _ => h_tx⟩
    · -- t < x ↔ true
      exact ⟨fun _ => h_tx_ssn, fun _ => h_tx⟩

/-! ## Zone Bridge: y = t (eq_t)

When ssn says ¬(y < t) ∧ ¬(t < y), i.e., y = t,
the existential collapses: the witness is t itself. -/

/-- Zone eq_t: `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` iff
    `predicates_of_y_match_at_t`. -/
theorem zone_bridge_eq_t {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (x t : M.carrier) (h_tx : t < x)
    -- ssn order profile for eq_t zone: ¬(y < t), ¬(t < y), y < x
    (h_yt_ssn : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(y < t)
    (h_ty_ssn : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false) -- ¬(t < y)
    (h_yx_ssn : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- y < x (= t < x)
    (h_xy_ssn : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false) -- ¬(x < y)
    (h_tx_ssn : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- t < x
    (h_xt_ssn : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(x < t)
    -- x and t predicates match ssn
    (h_x_preds : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_preds : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∀ p, M.interp p t ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  constructor
  · -- Forward: y = t
    intro ⟨y, h_nf⟩
    have h_not_yt : ¬(y < t) := by
      intro h
      have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
      simp only [atom_eval] at h_ord
      rw [fin_cons_eval_0, fin_cons_eval_2] at h_ord
      exact absurd (h_ord.mp h) (by simp_all)
    have h_not_ty : ¬(t < y) := by
      intro h
      have h_ord := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval] at h_ord
      rw [fin_cons_eval_2, fin_cons_eval_0] at h_ord
      exact absurd (h_ord.mp h) (by simp_all)
    have h_eq : y = t := le_antisymm (le_of_not_gt h_not_ty) (le_of_not_gt h_not_yt)
    subst h_eq
    exact extract_y_preds M ssn y x y h_nf
  · -- Backward: y = t
    intro h_y_preds
    refine ⟨t, ?_⟩
    apply reconstruct_nf_eval_3var M ssn t x t h_y_preds h_x_preds h_t_preds
    · -- t < x ↔ true
      exact ⟨fun _ => h_yx_ssn, fun _ => h_tx⟩
    · -- t < t ↔ false
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_tx h) (lt_irrefl _)
      · intro h; simp_all
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_tx h) (lt_irrefl _)
      · intro h; simp_all
    · -- t < t ↔ false
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
    · -- t < x ↔ true
      exact ⟨fun _ => h_tx_ssn, fun _ => h_tx⟩

end Bimodal.Metalogic.WeakCanonical.Kamp

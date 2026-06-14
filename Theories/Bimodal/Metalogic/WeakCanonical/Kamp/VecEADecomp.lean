import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA

/-!
# Lemma 3.2(2): EA Decomposition (3-var to 2-var VecEA2)

Implements a depth-0 special case of Rabinovich Lemma 3.2(2): the
exists-forall formula `∃ y, nf_eval_nf M 0 3 (y, x, t) ssn` with 1
existential variable and 2 free variables is equivalent to a VecEA2
formula, where y becomes a bracket witness.

At depth 0, the 3-var NF is purely atomic (predicates + orders), so
the existential decomposes by zone. The central zone where y is between
t and x produces a VecEA2 with 1 bracket witness.

## References

- Rabinovich 2014, Lemma 3.2(2)
- NfToVecEA.lean (depth-0 2-var case, template)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Projection functions for 3-var depth-0 NFs

Variable 0 = y (existential), Variable 1 = x (free), Variable 2 = t (free). -/

/-- Extract the variable-0 (y) predicate assignment from a 3-var depth-0 NF. -/
noncomputable def nf_y_proj {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => ssn (.pred p ⟨0, by omega⟩)
  | .order i j h => absurd (Fin.ext (by omega) : i = j) h

/-- Extract the variable-1 (x) predicate assignment from a 3-var depth-0 NF. -/
noncomputable def nf_x_proj3 {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => ssn (.pred p ⟨1, by omega⟩)
  | .order i j h => absurd (Fin.ext (by omega) : i = j) h

/-- Extract the variable-2 (t) predicate assignment from a 3-var depth-0 NF. -/
noncomputable def nf_t_proj3 {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => ssn (.pred p ⟨2, by omega⟩)
  | .order i j h => absurd (Fin.ext (by omega) : i = j) h

/-! ## Extract 1-var NF from 3-var NF evaluation -/

private theorem extract_y_nf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢
    exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

private theorem extract_x_nf3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj3 ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨1, by omega⟩)
    simp only [atom_eval] at this
    have hfc1 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x := by
      simp [Fin.cons]; rfl
    rw [hfc1] at this
    simp only [nf_x_proj3]; exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

private theorem extract_t_nf3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj3 ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨2, by omega⟩)
    simp only [atom_eval] at this
    have hfc2 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨2, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc2] at this
    simp only [nf_t_proj3]; exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-! ## VecEA2 for the bracket zone: t < y < x

When ssn requires t < y AND y < x, the existential `∃ y` gives a
bracket witness between z0=t and z1=x. The bracket has n=1 witness. -/

/-- VecEA2 for zone t < y < x at depth 0: 1 bracket witness at y. -/
noncomputable def nf_3var_bracket_tyx {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : VecEA2 1 :=
  { endpointLeft := nfPred atomMap h_surj (nf_t_proj3 ssn)
    endpointRight := nfPred atomMap h_surj (nf_x_proj3 ssn)
    bracket := BracketFormula.single
      (nfPred atomMap h_surj (nf_y_proj ssn))
      TemporalPred.top TemporalPred.top }

/-- Correctness: VecEA2.holds(t, x) iff ∃ y with t < y < x and 3-var NF.

    Zone: t < y < x (ssn says t < y, y < x, t < x, and negations of reverses).
    The existential y becomes a bracket witness between endpoints t and x. -/
theorem nf_3var_bracket_tyx_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (t x : M.carrier) :
    (nf_3var_bracket_tyx atomMap h_surj ssn).holds M atomMap t x ↔
    ∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  simp only [nf_3var_bracket_tyx, VecEA2.holds]
  constructor
  · -- Backward: VecEA2.holds → ∃ y
    intro ⟨h_t_pred, h_x_pred, h_bracket⟩
    rw [nfPred_correct] at h_t_pred h_x_pred
    simp only [BracketFormula.single, BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds] at h_bracket
    obtain ⟨w, _, hbnd, hpt, _, _, _⟩ := h_bracket
    set y := w ⟨0, by omega⟩
    have ht_lt_y : t < y := (hbnd ⟨0, by omega⟩).1
    have hy_lt_x : y < x := (hbnd ⟨0, by omega⟩).2
    have h_y_pred : nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn) := by
      rw [← nfPred_correct M atomMap h_surj (nf_y_proj ssn) y]
      exact hpt ⟨0, by omega⟩
    refine ⟨y, ?_⟩
    -- Reconstruct the full 3-var NF evaluation
    intro a
    match a with
    | .pred p ⟨0, _⟩ =>
      have := h_y_pred (.pred p ⟨0, by omega⟩)
      simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢; exact this
    | .pred p ⟨1, _⟩ =>
      have := h_x_pred (.pred p ⟨0, by omega⟩)
      simp only [atom_eval, Fin.cons, nf_x_proj3] at this ⊢
      convert this using 1
    | .pred p ⟨2, _⟩ =>
      have := h_t_pred (.pred p ⟨0, by omega⟩)
      simp only [atom_eval, Fin.cons, nf_t_proj3] at this ⊢
      convert this using 1
    | .pred _ ⟨n + 3, h⟩ => exact absurd h (by omega)
    | .order ⟨0, _⟩ ⟨0, _⟩ h_neq => exact absurd rfl h_neq
    | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      exact ⟨fun _ => h_yx, fun _ => hy_lt_x⟩
    | .order ⟨0, _⟩ ⟨2, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      constructor
      · intro h; exfalso; exact absurd (lt_trans h ht_lt_y) (lt_irrefl _)
      · intro h; rw [h_yt] at h; exact Bool.noConfusion h
    | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      constructor
      · intro h; exfalso; exact absurd (lt_trans hy_lt_x h) (lt_irrefl _)
      · intro h; rw [h_xy] at h; exact Bool.noConfusion h
    | .order ⟨1, _⟩ ⟨1, _⟩ h_neq => exact absurd rfl h_neq
    | .order ⟨1, _⟩ ⟨2, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      constructor
      · intro h; exfalso; exact absurd (lt_trans (lt_trans ht_lt_y hy_lt_x) h) (lt_irrefl _)
      · intro h; rw [h_xt] at h; exact Bool.noConfusion h
    | .order ⟨2, _⟩ ⟨0, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      exact ⟨fun _ => h_ty, fun _ => ht_lt_y⟩
    | .order ⟨2, _⟩ ⟨1, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      exact ⟨fun _ => h_tx, fun _ => lt_trans ht_lt_y hy_lt_x⟩
    | .order ⟨2, _⟩ ⟨2, _⟩ h_neq => exact absurd rfl h_neq
    | .order ⟨n + 3, h⟩ _ _ => exact absurd h (by omega)
    | .order _ ⟨n + 3, h⟩ _ => exact absurd h (by omega)
  · -- Forward: ∃ y → VecEA2.holds
    intro ⟨y, h_nf⟩
    have h_y_nf := extract_y_nf M ssn y x t h_nf
    have h_x_nf := extract_x_nf3 M ssn y x t h_nf
    have h_t_nf := extract_t_nf3 M ssn y x t h_nf
    have h_o_ty := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    have h_o_yx := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    simp only [atom_eval] at h_o_ty h_o_yx
    have hfc0 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by
      simp [Fin.cons]
    have hfc1 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x := by
      simp [Fin.cons]; rfl
    have hfc2 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨2, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc2, hfc0] at h_o_ty; rw [hfc0, hfc1] at h_o_yx
    have ht_lt_y : t < y := h_o_ty.mpr h_ty
    have hy_lt_x : y < x := h_o_yx.mpr h_yx
    refine ⟨(nfPred_correct M atomMap h_surj _ t).mpr h_t_nf,
            (nfPred_correct M atomMap h_surj _ x).mpr h_x_nf, ?_⟩
    simp only [BracketFormula.single, BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds]
    refine ⟨fun _ => y, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j hij; exact absurd hij (by omega)
    · intro _; exact ⟨ht_lt_y, hy_lt_x⟩
    · intro ⟨i, hi⟩
      have : i = 0 := by omega
      subst this
      exact (nfPred_correct M atomMap h_surj _ y).mpr h_y_nf
    · intro y' _ _
      simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]
    · intro ⟨i, hi⟩; exact absurd hi (by omega)
    · intro y' _ _
      simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]

/-! ## VecEA2 for zone x < y < t (bracket, reversed)

When ssn requires x < y AND y < t, the existential gives a bracket
witness between z0=x and z1=t. -/

/-- VecEA2 for zone x < y < t at depth 0: 1 bracket witness at y. -/
noncomputable def nf_3var_bracket_xyt {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : VecEA2 1 :=
  { endpointLeft := nfPred atomMap h_surj (nf_x_proj3 ssn)
    endpointRight := nfPred atomMap h_surj (nf_t_proj3 ssn)
    bracket := BracketFormula.single
      (nfPred atomMap h_surj (nf_y_proj ssn))
      TemporalPred.top TemporalPred.top }

/-- Correctness: VecEA2.holds(x, t) iff ∃ y with x < y < t and 3-var NF. -/
theorem nf_3var_bracket_xyt_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (nf_3var_bracket_xyt atomMap h_surj ssn).holds M atomMap x t ↔
    ∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  simp only [nf_3var_bracket_xyt, VecEA2.holds]
  constructor
  · intro ⟨h_x_pred, h_t_pred, h_bracket⟩
    rw [nfPred_correct] at h_x_pred h_t_pred
    simp only [BracketFormula.single, BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds] at h_bracket
    obtain ⟨w, _, hbnd, hpt, _, _, _⟩ := h_bracket
    set y := w ⟨0, by omega⟩
    have hx_lt_y : x < y := (hbnd ⟨0, by omega⟩).1
    have hy_lt_t : y < t := (hbnd ⟨0, by omega⟩).2
    have h_y_pred : nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn) := by
      rw [← nfPred_correct M atomMap h_surj (nf_y_proj ssn) y]
      exact hpt ⟨0, by omega⟩
    refine ⟨y, ?_⟩
    intro a
    match a with
    | .pred p ⟨0, _⟩ =>
      have := h_y_pred (.pred p ⟨0, by omega⟩)
      simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢; exact this
    | .pred p ⟨1, _⟩ =>
      have := h_x_pred (.pred p ⟨0, by omega⟩)
      simp only [atom_eval, Fin.cons, nf_x_proj3] at this ⊢
      convert this using 1
    | .pred p ⟨2, _⟩ =>
      have := h_t_pred (.pred p ⟨0, by omega⟩)
      simp only [atom_eval, Fin.cons, nf_t_proj3] at this ⊢
      convert this using 1
    | .pred _ ⟨n + 3, h⟩ => exact absurd h (by omega)
    | .order ⟨0, _⟩ ⟨0, _⟩ h_neq => exact absurd rfl h_neq
    | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      constructor
      · intro h; exfalso; exact absurd (lt_trans hx_lt_y h) (lt_irrefl _)
      · intro h; rw [h_yx] at h; exact Bool.noConfusion h
    | .order ⟨0, _⟩ ⟨2, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      exact ⟨fun _ => h_yt, fun _ => hy_lt_t⟩
    | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      exact ⟨fun _ => h_xy, fun _ => hx_lt_y⟩
    | .order ⟨1, _⟩ ⟨1, _⟩ h_neq => exact absurd rfl h_neq
    | .order ⟨1, _⟩ ⟨2, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      exact ⟨fun _ => h_xt, fun _ => lt_trans hx_lt_y hy_lt_t⟩
    | .order ⟨2, _⟩ ⟨0, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      constructor
      · intro h; exfalso; exact absurd (lt_trans h hy_lt_t) (lt_irrefl _)
      · intro h; rw [h_ty] at h; exact Bool.noConfusion h
    | .order ⟨2, _⟩ ⟨1, _⟩ _ =>
      simp only [atom_eval, Fin.cons]
      constructor
      · intro h; exfalso; exact absurd (lt_trans (lt_trans hx_lt_y hy_lt_t) h) (lt_irrefl _)
      · intro h; rw [h_tx] at h; exact Bool.noConfusion h
    | .order ⟨2, _⟩ ⟨2, _⟩ h_neq => exact absurd rfl h_neq
    | .order ⟨n + 3, h⟩ _ _ => exact absurd h (by omega)
    | .order _ ⟨n + 3, h⟩ _ => exact absurd h (by omega)
  · intro ⟨y, h_nf⟩
    have h_y_nf := extract_y_nf M ssn y x t h_nf
    have h_x_nf := extract_x_nf3 M ssn y x t h_nf
    have h_t_nf := extract_t_nf3 M ssn y x t h_nf
    have h_o_xy := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    have h_o_yt := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [atom_eval] at h_o_xy h_o_yt
    have hfc0 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by
      simp [Fin.cons]
    have hfc1 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x := by
      simp [Fin.cons]; rfl
    have hfc2 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨2, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc1, hfc0] at h_o_xy; rw [hfc0, hfc2] at h_o_yt
    have hx_lt_y : x < y := h_o_xy.mpr h_xy
    have hy_lt_t : y < t := h_o_yt.mpr h_yt
    refine ⟨(nfPred_correct M atomMap h_surj _ x).mpr h_x_nf,
            (nfPred_correct M atomMap h_surj _ t).mpr h_t_nf, ?_⟩
    simp only [BracketFormula.single, BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds]
    refine ⟨fun _ => y, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j hij; exact absurd hij (by omega)
    · intro _; exact ⟨hx_lt_y, hy_lt_t⟩
    · intro ⟨i, hi⟩
      have : i = 0 := by omega
      subst this
      exact (nfPred_correct M atomMap h_surj _ y).mpr h_y_nf
    · intro y' _ _
      simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]
    · intro ⟨i, hi⟩; exact absurd hi (by omega)
    · intro y' _ _
      simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]

end Bimodal.Metalogic.WeakCanonical.Kamp

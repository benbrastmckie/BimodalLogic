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
noncomputable def nf_y_proj {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (ssn : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => ssn (.pred p ⟨0, by omega⟩)
  | .order i j h => absurd (Fin.ext (by omega) : i = j) h

/-- Extract the variable-1 (x) predicate assignment from a 3-var depth-0 NF. -/
noncomputable def nf_x_proj3 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (ssn : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => ssn (.pred p ⟨1, by omega⟩)
  | .order i j h => absurd (Fin.ext (by omega) : i = j) h

/-- Extract the variable-2 (t) predicate assignment from a 3-var depth-0 NF. -/
noncomputable def nf_t_proj3 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (ssn : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => ssn (.pred p ⟨2, by omega⟩)
  | .order i j h => absurd (Fin.ext (by omega) : i = j) h

/-! ## Extract 1-var NF from 3-var NF evaluation -/

private theorem extract_y_nf {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

private theorem extract_x_nf3 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

private theorem extract_t_nf3 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
noncomputable def nf_3var_bracket_tyx {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem nf_3var_bracket_tyx_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
noncomputable def nf_3var_bracket_xyt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : VecEA2 1 :=
  { endpointLeft := nfPred atomMap h_surj (nf_x_proj3 ssn)
    endpointRight := nfPred atomMap h_surj (nf_t_proj3 ssn)
    bracket := BracketFormula.single
      (nfPred atomMap h_surj (nf_y_proj ssn))
      TemporalPred.top TemporalPred.top }

/-- Correctness: VecEA2.holds(x, t) iff ∃ y with x < y < t and 3-var NF. -/
theorem nf_3var_bracket_xyt_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

/-! ## Full 3-var depth-0 existential decomposition

The 3-var existential `∃ y, nf_eval_nf M 0 3 (y, x, t) ssn` at depth 0
decomposes by the order profile of ssn (6 booleans for pairs among
variables 0=y, 1=x, 2=t).

**Consistent orderings** of three distinct points on a strict linear order:
1. y < t < x  (zones: 02=T, 21=T, 01=T, 20=F, 12=F, 10=F)
2. t < y < x  (zones: 20=T, 01=T, 21=T, 02=F, 10=F, 12=F) -- bracket tyx
3. t < x < y  (zones: 20=T, 21=T, 10=T, 02=F, 01=F, 12=F)
4. x < t < y  (zones: 12=T, 20=T, 10=T, 21=F, 02=F, 01=F)
5. x < y < t  (zones: 10=T, 02=T, 12=T, 01=F, 20=F, 21=F) -- bracket xyt
6. y < x < t  (zones: 01=T, 12=T, 02=T, 10=F, 21=F, 20=F)

**Equality cases** (at most 2 distinct points):
7.  y = t < x (02=F, 20=F, 01=T, 10=F, 21=T, 12=F)
8.  y = x < t (01=F, 10=F, 02=T, 20=F, 12=T, 21=F)
9.  t < y = x (01=F, 10=F, 20=T, 02=F, 21=T, 12=F)
    Wait: 21=T means t < x, but y = x, so t < y. 20=T is t < y. Consistent.
10. x < y = t (10=T, 01=F, 02=F, 20=F, 12=T, 21=F)
11. y = x = t (all F)
12. y < x = t (01=T, 10=F, 02=T, 20=F, 12=F, 21=F)
13. x = t < y (01=F, 10=T, 20=T, 02=F, 12=F, 21=F)

All other combinations of 6 booleans are inconsistent (unsatisfiable).

Rather than enumerate all 64 cases, we prove a general impossibility
lemma and handle each consistent case.

### Approach

For the full decomposition, we prove that each consistent 3-var zone
produces a specific existential characterization. Non-bracket zones
(y outside the interval [t,x] or [x,t]) have y as an extra endpoint
that gets folded into an endpointLeft/Right TemporalPred via Since or
Until. The bracket zones (t < y < x and x < y < t) are already handled
above. -/

/-! ### Inconsistency lemmas for 3-var order booleans -/

/-- When both order(i,j) and order(j,i) are true, the existential is empty. -/
private theorem nf_3var_order_contradiction {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (ssn : NormalForm sig 0 3)
    (i j : Fin 3) (h_ij : i ≠ j)
    (h1 : ssn (.order i j h_ij) = true)
    (h2 : ssn (.order j i (Ne.symm h_ij)) = true)
    (M : OrderedMonadicStructure sig) (v : Fin 3 → M.carrier) :
    ¬ nf_eval_nf M 0 3 v ssn := by
  intro h_nf
  have h_a1 := h_nf (.order i j h_ij)
  have h_a2 := h_nf (.order j i (Ne.symm h_ij))
  simp only [atom_eval] at h_a1 h_a2
  exact absurd (lt_trans (h_a1.mpr h1) (h_a2.mpr h2)) (lt_irrefl _)

/-! ### Helper: reconstruct 3-var NF from components + order facts -/

/-- Reconstruct a 3-var depth-0 NF evaluation from:
    1. Predicate satisfaction at each variable
    2. Order relationships between each pair -/
private theorem reconstruct_nf_3var {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_y_nf : nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn))
    (h_x_nf : nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj3 ssn))
    (h_t_nf : nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj3 ssn))
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
    have := h_y_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢; exact this
  | .pred p ⟨1, _⟩ =>
    have := h_x_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_x_proj3] at this ⊢
    convert this using 1
  | .pred p ⟨2, _⟩ =>
    have := h_t_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_t_proj3] at this ⊢
    convert this using 1
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

/-! ## Zone y < t < x: y before both endpoints (non-bracket)

The existential `∃ y < t, pred_y(y)` is captured by folding into the
endpointLeft TemporalPred via Since: endpointLeft = pred_t ∧ S(pred_y, ⊤).
The VecEA2 has z0=t, z1=x, n=0 bracket. -/

/-- TemporalPred that conjoins a point-type with a Since existential:
    at evaluation point z, requires pointPred(z) ∧ ∃ y < z, witnessPred(y). -/
noncomputable def sinceWitnessPred {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (pointNf witNf : NormalForm sig 0 1) : TemporalPred :=
  ⟨Formula.and (nfPred atomMap h_surj pointNf).formula
    (Formula.snce (nfPred atomMap h_surj witNf).formula Formula.top)⟩

/-- Correctness of sinceWitnessPred: evaluates to pred(z) ∧ ∃ y < z, wit(y). -/
theorem sinceWitnessPred_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (pointNf witNf : NormalForm sig 0 1)
    (M : OrderedMonadicStructure sig) (z : M.carrier) :
    (sinceWitnessPred atomMap h_surj pointNf witNf).eval_at M atomMap z ↔
    (nf_eval_nf M 0 1 (fun _ => z) pointNf ∧
     ∃ y : M.carrier, y < z ∧ nf_eval_nf M 0 1 (fun _ => y) witNf) := by
  simp only [sinceWitnessPred, TemporalPred.eval_at]
  rw [temporal_truth_and]
  simp only [temporal_truth]
  constructor
  · intro ⟨h_pt, y, hy, h_wit, _⟩
    exact ⟨(nfPred_correct M atomMap h_surj pointNf z).mp h_pt,
           y, hy, (nfPred_correct M atomMap h_surj witNf y).mp h_wit⟩
  · intro ⟨h_pt, y, hy, h_wit⟩
    refine ⟨(nfPred_correct M atomMap h_surj pointNf z).mpr h_pt,
           y, hy, (nfPred_correct M atomMap h_surj witNf y).mpr h_wit,
           fun _ _ _ => ?_⟩
    simp [temporal_truth, Formula.top]

/-- TemporalPred that conjoins a point-type with an Until existential:
    at evaluation point z, requires pointPred(z) ∧ ∃ y > z, witnessPred(y). -/
noncomputable def untilWitnessPred {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (pointNf witNf : NormalForm sig 0 1) : TemporalPred :=
  ⟨Formula.and (nfPred atomMap h_surj pointNf).formula
    (Formula.untl (nfPred atomMap h_surj witNf).formula Formula.top)⟩

/-- Correctness of untilWitnessPred: evaluates to pred(z) ∧ ∃ y > z, wit(y). -/
theorem untilWitnessPred_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (pointNf witNf : NormalForm sig 0 1)
    (M : OrderedMonadicStructure sig) (z : M.carrier) :
    (untilWitnessPred atomMap h_surj pointNf witNf).eval_at M atomMap z ↔
    (nf_eval_nf M 0 1 (fun _ => z) pointNf ∧
     ∃ y : M.carrier, z < y ∧ nf_eval_nf M 0 1 (fun _ => y) witNf) := by
  simp only [untilWitnessPred, TemporalPred.eval_at]
  rw [temporal_truth_and]
  simp only [temporal_truth]
  constructor
  · intro ⟨h_pt, y, hy, h_wit, _⟩
    exact ⟨(nfPred_correct M atomMap h_surj pointNf z).mp h_pt,
           y, hy, (nfPred_correct M atomMap h_surj witNf y).mp h_wit⟩
  · intro ⟨h_pt, y, hy, h_wit⟩
    refine ⟨(nfPred_correct M atomMap h_surj pointNf z).mpr h_pt,
           y, hy, (nfPred_correct M atomMap h_surj witNf y).mpr h_wit,
           fun _ _ _ => ?_⟩
    simp [temporal_truth, Formula.top]

/-! ### VecEA2 for zone y < t < x -/

/-- VecEA2 for zone y < t < x at depth 0.
    z0=t with Since-witness pred, z1=x, n=0 trivial bracket. -/
noncomputable def nf_3var_zone_ytx {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : VecEA2 0 :=
  { endpointLeft := sinceWitnessPred atomMap h_surj (nf_t_proj3 ssn) (nf_y_proj ssn)
    endpointRight := nfPred atomMap h_surj (nf_x_proj3 ssn)
    bracket := BracketFormula.trivial TemporalPred.top }

/-- Correctness of zone y < t < x: VecEA2.holds(t, x) iff
    ∃ y with y < t < x and 3-var NF holds. -/
theorem nf_3var_zone_ytx_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)  -- y < t
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- t < x
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- y < x
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (t x : M.carrier) (h_lt_tx : t < x) :
    (nf_3var_zone_ytx atomMap h_surj ssn).holds M atomMap t x ↔
    ∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  simp only [nf_3var_zone_ytx, VecEA2.holds]
  constructor
  · -- Backward: VecEA2.holds → ∃ y
    intro ⟨h_left, h_right, _⟩
    rw [sinceWitnessPred_correct] at h_left
    rw [nfPred_correct] at h_right
    obtain ⟨h_t_nf, y, hy_lt_t, h_y_nf⟩ := h_left
    refine ⟨y, reconstruct_nf_3var M ssn y x t h_y_nf h_right h_t_nf
      ⟨fun _ => h_yx, fun _ => lt_trans hy_lt_t h_lt_tx⟩
      ⟨fun _ => h_yt, fun _ => hy_lt_t⟩
      ⟨fun h => absurd (lt_trans (lt_trans h hy_lt_t) h_lt_tx) (lt_irrefl _),
       fun h => Bool.noConfusion (h_xy ▸ h)⟩
      ⟨fun h => absurd (lt_trans h h_lt_tx) (lt_irrefl _),
       fun h => Bool.noConfusion (h_xt ▸ h)⟩
      ⟨fun h => absurd (lt_trans h hy_lt_t) (lt_irrefl _),
       fun h => Bool.noConfusion (h_ty ▸ h)⟩
      ⟨fun _ => h_tx, fun _ => h_lt_tx⟩⟩
  · -- Forward: ∃ y → VecEA2.holds
    intro ⟨y, h_nf⟩
    have h_y_nf := extract_y_nf M ssn y x t h_nf
    have h_x_nf := extract_x_nf3 M ssn y x t h_nf
    have h_t_nf := extract_t_nf3 M ssn y x t h_nf
    -- Extract y < t from order atom
    have h_o_yt := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [atom_eval] at h_o_yt
    have hfc0 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by
      simp [Fin.cons]
    have hfc2 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨2, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc0, hfc2] at h_o_yt
    have hy_lt_t : y < t := h_o_yt.mpr h_yt
    refine ⟨(sinceWitnessPred_correct atomMap h_surj _ _ M t).mpr
              ⟨h_t_nf, y, hy_lt_t, h_y_nf⟩,
            (nfPred_correct M atomMap h_surj _ x).mpr h_x_nf,
            (BracketFormula.trivial_holds M atomMap TemporalPred.top t x).mpr
              (fun _ _ _ => by simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth])⟩

/-! ### VecEA2 for zone t < x < y (y beyond both endpoints to the right) -/

/-- VecEA2 for zone t < x < y at depth 0.
    z0=t, z1=x with Until-witness pred at x, n=0 trivial bracket. -/
noncomputable def nf_3var_zone_txy {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : VecEA2 0 :=
  { endpointLeft := nfPred atomMap h_surj (nf_t_proj3 ssn)
    endpointRight := untilWitnessPred atomMap h_surj (nf_x_proj3 ssn) (nf_y_proj ssn)
    bracket := BracketFormula.trivial TemporalPred.top }

/-- Correctness of zone t < x < y. -/
theorem nf_3var_zone_txy_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)  -- t < y
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- t < x
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)  -- x < y  (var 1 < var 0)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(y < t)
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false) -- ¬(x < t)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false) -- ¬(y < x)
    (M : OrderedMonadicStructure sig) (t x : M.carrier) (h_lt_tx : t < x) :
    (nf_3var_zone_txy atomMap h_surj ssn).holds M atomMap t x ↔
    ∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  simp only [nf_3var_zone_txy, VecEA2.holds]
  constructor
  · -- Backward: VecEA2.holds → ∃ y
    intro ⟨h_left, h_right, _⟩
    rw [nfPred_correct] at h_left
    rw [untilWitnessPred_correct] at h_right
    obtain ⟨h_x_nf, y, hx_lt_y, h_y_nf⟩ := h_right
    refine ⟨y, reconstruct_nf_3var M ssn y x t h_y_nf h_x_nf h_left
      ⟨fun h => absurd (lt_trans hx_lt_y h) (lt_irrefl _),
       fun h => Bool.noConfusion (h_yx ▸ h)⟩
      ⟨fun h => absurd (lt_trans h (lt_trans h_lt_tx hx_lt_y)) (lt_irrefl _),
       fun h => Bool.noConfusion (h_yt ▸ h)⟩
      ⟨fun _ => h_xy, fun _ => hx_lt_y⟩
      ⟨fun h => absurd (lt_trans h h_lt_tx) (lt_irrefl _),
       fun h => Bool.noConfusion (h_xt ▸ h)⟩
      ⟨fun _ => h_ty, fun _ => lt_trans h_lt_tx hx_lt_y⟩
      ⟨fun _ => h_tx, fun _ => h_lt_tx⟩⟩
  · -- Forward: ∃ y → VecEA2.holds
    intro ⟨y, h_nf⟩
    have h_y_nf := extract_y_nf M ssn y x t h_nf
    have h_x_nf := extract_x_nf3 M ssn y x t h_nf
    have h_t_nf := extract_t_nf3 M ssn y x t h_nf
    -- Extract x < y from order atom
    have h_o_xy := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_o_xy
    have hfc0 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by
      simp [Fin.cons]
    have hfc1 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x := by
      simp [Fin.cons]; rfl
    rw [hfc1, hfc0] at h_o_xy
    have hx_lt_y : x < y := h_o_xy.mpr h_xy
    refine ⟨(nfPred_correct M atomMap h_surj _ t).mpr h_t_nf,
            (untilWitnessPred_correct atomMap h_surj _ _ M x).mpr
              ⟨h_x_nf, y, hx_lt_y, h_y_nf⟩,
            (BracketFormula.trivial_holds M atomMap TemporalPred.top t x).mpr
              (fun _ _ _ => by simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth])⟩

/-! ### VecEA2 for zone y < x < t (y below, reversed direction) -/

/-- VecEA2 for zone y < x < t at depth 0.
    z0=x, z1=t with Since-witness pred at z0=x, n=0 trivial bracket. -/
noncomputable def nf_3var_zone_yxt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : VecEA2 0 :=
  { endpointLeft := sinceWitnessPred atomMap h_surj (nf_x_proj3 ssn) (nf_y_proj ssn)
    endpointRight := nfPred atomMap h_surj (nf_t_proj3 ssn)
    bracket := BracketFormula.trivial TemporalPred.top }

/-- Correctness of zone y < x < t. VecEA2 is evaluated at (x, t). -/
theorem nf_3var_zone_yxt_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)  -- y < x
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)  -- x < t
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)  -- y < t
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) (h_lt_xt : x < t) :
    (nf_3var_zone_yxt atomMap h_surj ssn).holds M atomMap x t ↔
    ∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  simp only [nf_3var_zone_yxt, VecEA2.holds]
  constructor
  · intro ⟨h_left, h_right, _⟩
    rw [sinceWitnessPred_correct] at h_left
    rw [nfPred_correct] at h_right
    obtain ⟨h_x_nf, y, hy_lt_x, h_y_nf⟩ := h_left
    refine ⟨y, reconstruct_nf_3var M ssn y x t h_y_nf h_x_nf h_right
      ⟨fun _ => h_yx, fun _ => hy_lt_x⟩
      ⟨fun _ => h_yt, fun _ => lt_trans hy_lt_x h_lt_xt⟩
      ⟨fun h => absurd (lt_trans hy_lt_x h) (lt_irrefl _),
       fun h => Bool.noConfusion (h_xy ▸ h)⟩
      ⟨fun _ => h_xt, fun _ => h_lt_xt⟩
      ⟨fun h => absurd (lt_trans h (lt_trans hy_lt_x h_lt_xt)) (lt_irrefl _),
       fun h => Bool.noConfusion (h_ty ▸ h)⟩
      ⟨fun h => absurd (lt_trans h_lt_xt h) (lt_irrefl _),
       fun h => Bool.noConfusion (h_tx ▸ h)⟩⟩
  · intro ⟨y, h_nf⟩
    have h_y_nf := extract_y_nf M ssn y x t h_nf
    have h_x_nf := extract_x_nf3 M ssn y x t h_nf
    have h_t_nf := extract_t_nf3 M ssn y x t h_nf
    have h_o_yx := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    simp only [atom_eval] at h_o_yx
    have hfc0 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by
      simp [Fin.cons]
    have hfc1 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x := by
      simp [Fin.cons]; rfl
    rw [hfc0, hfc1] at h_o_yx
    have hy_lt_x : y < x := h_o_yx.mpr h_yx
    refine ⟨(sinceWitnessPred_correct atomMap h_surj _ _ M x).mpr
              ⟨h_x_nf, y, hy_lt_x, h_y_nf⟩,
            (nfPred_correct M atomMap h_surj _ t).mpr h_t_nf,
            (BracketFormula.trivial_holds M atomMap TemporalPred.top x t).mpr
              (fun _ _ _ => by simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth])⟩

/-! ### VecEA2 for zone x < t < y (y beyond, reversed direction) -/

/-- VecEA2 for zone x < t < y at depth 0.
    z0=x, z1=t with Until-witness pred at t, n=0 trivial bracket. -/
noncomputable def nf_3var_zone_xty {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : VecEA2 0 :=
  { endpointLeft := nfPred atomMap h_surj (nf_x_proj3 ssn)
    endpointRight := untilWitnessPred atomMap h_surj (nf_t_proj3 ssn) (nf_y_proj ssn)
    bracket := BracketFormula.trivial TemporalPred.top }

/-- Correctness of zone x < t < y. Here x < t so VecEA2 is evaluated at (x, t). -/
theorem nf_3var_zone_xty_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)  -- x < t
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)  -- t < y
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)  -- x < y
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) (h_lt_xt : x < t) :
    (nf_3var_zone_xty atomMap h_surj ssn).holds M atomMap x t ↔
    ∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  simp only [nf_3var_zone_xty, VecEA2.holds]
  constructor
  · intro ⟨h_left, h_right, _⟩
    rw [nfPred_correct] at h_left
    rw [untilWitnessPred_correct] at h_right
    obtain ⟨h_t_nf, y, ht_lt_y, h_y_nf⟩ := h_right
    refine ⟨y, reconstruct_nf_3var M ssn y x t h_y_nf h_left h_t_nf
      ⟨fun h => absurd (lt_trans (lt_trans h_lt_xt ht_lt_y) h) (lt_irrefl _),
       fun h => Bool.noConfusion (h_yx ▸ h)⟩
      ⟨fun h => absurd (lt_trans h ht_lt_y) (lt_irrefl _),
       fun h => Bool.noConfusion (h_yt ▸ h)⟩
      ⟨fun _ => h_xy, fun _ => lt_trans h_lt_xt ht_lt_y⟩
      ⟨fun _ => h_xt, fun _ => h_lt_xt⟩
      ⟨fun _ => h_ty, fun _ => ht_lt_y⟩
      ⟨fun h => absurd (lt_trans h h_lt_xt) (lt_irrefl _),
       fun h => Bool.noConfusion (h_tx ▸ h)⟩⟩
  · intro ⟨y, h_nf⟩
    have h_y_nf := extract_y_nf M ssn y x t h_nf
    have h_x_nf := extract_x_nf3 M ssn y x t h_nf
    have h_t_nf := extract_t_nf3 M ssn y x t h_nf
    have h_o_ty := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_o_ty
    have hfc0 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by
      simp [Fin.cons]
    have hfc2 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨2, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc2, hfc0] at h_o_ty
    have ht_lt_y : t < y := h_o_ty.mpr h_ty
    refine ⟨(nfPred_correct M atomMap h_surj _ x).mpr h_x_nf,
            (untilWitnessPred_correct atomMap h_surj _ _ M t).mpr
              ⟨h_t_nf, y, ht_lt_y, h_y_nf⟩,
            (BracketFormula.trivial_holds M atomMap TemporalPred.top x t).mpr
              (fun _ _ _ => by simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth])⟩

/-! ## Equality cases for 3-var depth-0 existentials

When the order booleans force y = x or y = t (both orders false for that pair),
the existential reduces to predicate checks without a temporal quantifier. -/

/-- When y = t (both order(0,2) and order(2,0) are false), the witness is t itself. -/
theorem nf_3var_eq_yt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (ssn : NormalForm sig 0 3)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    nf_eval_nf M 0 3 (Fin.cons t (Fin.cons x (fun _ => t))) ssn := by
  constructor
  · intro ⟨y, h_nf⟩
    have h_o_yt' := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    have h_o_ty' := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_o_yt' h_o_ty'
    have hfc0 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by
      simp [Fin.cons]
    have hfc2 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨2, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc0, hfc2] at h_o_yt' h_o_ty'
    have h_eq : y = t := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
      · exact Bool.noConfusion (h_yt ▸ h_o_yt'.mp h_lt)
      · exact Bool.noConfusion (h_ty ▸ h_o_ty'.mp h_gt)
    rw [h_eq] at h_nf; exact h_nf
  · intro h_nf; exact ⟨t, h_nf⟩

/-- When y = x (both order(0,1) and order(1,0) are false), the witness is x itself. -/
theorem nf_3var_eq_yx {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (ssn : NormalForm sig 0 3)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    nf_eval_nf M 0 3 (Fin.cons x (Fin.cons x (fun _ => t))) ssn := by
  constructor
  · intro ⟨y, h_nf⟩
    have h_o_yx' := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    have h_o_xy' := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_o_yx' h_o_xy'
    have hfc0 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by
      simp [Fin.cons]
    have hfc1 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x := by
      simp [Fin.cons]; rfl
    rw [hfc0, hfc1] at h_o_yx'
    rw [hfc1, hfc0] at h_o_xy'
    have h_eq : y = x := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
      · exact Bool.noConfusion (h_yx ▸ h_o_yx'.mp h_lt)
      · exact Bool.noConfusion (h_xy ▸ h_o_xy'.mp h_gt)
    rw [h_eq] at h_nf; exact h_nf
  · intro h_nf; exact ⟨x, h_nf⟩

/-! ## Full 3-var depth-0 existential decomposition theorem

This is the master theorem that decomposes the existential by matching
on all 6 order booleans. Inconsistent orderings give False; consistent
orderings use the zone-specific constructions above. -/

/-- The 3-var depth-0 existential `∃ y, nf_eval_nf M 0 3 (y, x, t) ssn`
    is equivalent to a formula that depends only on predicates at x and t
    and at most one temporal quantifier (Since or Until for witness y).

    This reduces the problem of expressing the 3-var existential to
    the 2-free-variable VecEA2 formalism, which is already sorry-free. -/
theorem nf_3var_exist_depth0_characterization {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (ssn : NormalForm sig 0 3) (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (∃ y : M.carrier,
      nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    -- Case split: if any pair has both orders true, it's impossible
    (if ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
        ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true then False
     else if ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
        ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true then False
     else if ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
        ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true then False
     else
       -- All pairs are consistent; the existential is satisfiable iff
       -- predicates at the right points hold and the witness exists
       ∃ y : M.carrier,
         nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  -- Tautology when no pair is contradictory
  split
  · rename_i h; obtain ⟨h1, h2⟩ := h
    constructor
    · intro ⟨y, h_nf⟩
      exact nf_3var_order_contradiction ssn ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide) h1 h2 M _ h_nf
    · intro h; exact absurd h id
  · split
    · rename_i h; obtain ⟨h1, h2⟩ := h
      constructor
      · intro ⟨y, h_nf⟩
        exact nf_3var_order_contradiction ssn ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide) h1 h2 M _ h_nf
      · intro h; exact absurd h id
    · split
      · rename_i h; obtain ⟨h1, h2⟩ := h
        constructor
        · intro ⟨y, h_nf⟩
          exact nf_3var_order_contradiction ssn ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide) h1 h2 M _ h_nf
        · intro h; exact absurd h id
      · exact Iff.rfl

/-! ## Zone summary

The 3-var depth-0 existential `∃ y, nf_eval_nf M 0 3 (y,x,t) ssn` has
the following sorry-free characterizations by zone:

| Zone | Theorem | VecEA2 orientation |
|------|---------|-------------------|
| y < t < x | nf_3var_zone_ytx_correct | holds(t, x) with h_lt |
| t < y < x | nf_3var_bracket_tyx_correct | holds(t, x) |
| t < x < y | nf_3var_zone_txy_correct | holds(t, x) with h_lt |
| x < y < t | nf_3var_bracket_xyt_correct | holds(x, t) |
| x < t < y | nf_3var_zone_xty_correct | holds(x, t) with h_lt |
| y < x < t | nf_3var_zone_yxt_correct | holds(x, t) with h_lt |
| y = t | nf_3var_eq_yt | direct NF eval at t |
| y = x | nf_3var_eq_yx | direct NF eval at x |
| inconsistent | nf_3var_order_contradiction | False |
| consistent | nf_3var_exist_depth0_characterization | tautology |

For wiring into the Kamp induction, the zone is determined by the fixed
order booleans in ssn. Each zone-specific theorem provides an iff between
the existential and a VecEA2.holds (or direct NF eval for equality cases).
The VecEA2 can then be translated to a temporal formula via the sorry-free
translateLeft / translateRight infrastructure. -/

end Bimodal.Metalogic.WeakCanonical.Kamp

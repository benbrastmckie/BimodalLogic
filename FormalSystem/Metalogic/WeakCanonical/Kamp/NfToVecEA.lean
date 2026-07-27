/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEATranslation
import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.Separation.KampTranslation
import FormalSystem.Metalogic.WeakCanonical.PriorDefs

/-!
# Depth-0 NF Existential to VVecEA2 Conversion

Converts `∃ x, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf` into a
`VVecEA2` formula (holdsLeft for the future direction). At depth 0, the NF
evaluation is purely atomic (predicates and order atoms), so the existential
decomposes by order direction.

## Main Results

- `nfPred`: Build a TemporalPred from a depth-0 1-var NF
- `nfPred_correct`: Correctness of nfPred evaluation
- `nf_vecEA2_future`: VecEA2 for the x > t direction
- `nf_vecEA2_future_correct`: The Until-direction VecEA2 captures the existential
- `nf_vecEA2_past_correct`: The Since-direction VecEA2 captures the existential

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5 (base case)
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## VecEA2 Since-direction semantics (holdsRight)

`holdsRight` is the Since-direction counterpart of `holdsLeft`:
the free variable t is at the right endpoint (z_1), and z_0 is
existentially quantified with z_0 < t. -/

/-- Since-direction semantics: free variable at z_1, existential z_0 < t. -/
def VecEA2.holdsRight {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA2 n) (t : M.carrier) : Prop :=
  vea.endpointRight.eval_at M atomMap t ∧
  ∃ z0 : M.carrier, z0 < t ∧
    vea.endpointLeft.eval_at M atomMap z0 ∧
    vea.bracket.holds M atomMap z0 t

/-- Since-direction semantics for VVecEA2. -/
def VVecEA2.holdsRight {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) (t : M.carrier) : Prop :=
  ∃ vea ∈ v.disjuncts, vea.2.holdsRight M atomMap t

/-! ## Predicate extraction from depth-0 2-var NF

At depth 0, a 2-var NF `sub_nf : NormalForm sig 0 2` assigns boolean values
to atoms `AtomKind sig 2`. We extract the variable-0 (x) and variable-1 (t)
predicate assignments as `TemporalPred` values. -/

/-- Build a TemporalPred from a depth-0 1-var NF using characteristic formulas. -/
noncomputable def nfPred {sig : MonadicSignature} [Fintype sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf_1 : NormalForm sig 0 1) : TemporalPred :=
  ⟨nf_depth0_char_formula atomMap h_surj nf_1⟩

/-- The nfPred evaluates correctly: it holds at t iff t satisfies the NF. -/
theorem nfPred_correct {sig : MonadicSignature} [Fintype sig.preds]
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf_1 : NormalForm sig 0 1) (t : M.carrier) :
    (nfPred atomMap h_surj nf_1).eval_at M atomMap t ↔
    nf_eval_nf M 0 1 (fun _ => t) nf_1 := by
  simp only [nfPred, TemporalPred.eval_at]
  rw [nf_depth0_char_formula_correct M atomMap h_surj nf_1 t]
  simp only [nf_eval_nf]
  constructor
  · intro h a
    match a with
    | .pred p i =>
      have hi : i = ⟨0, by omega⟩ := Fin.ext (by omega)
      subst hi
      simp only [atom_eval]
      exact h p
    | .order i j h_neq =>
      exact absurd (Fin.ext (by omega) : i = j) h_neq
  · intro h p
    have := h (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at this
    exact this

/-- Extract the variable-0 (x) predicate assignment from a 2-var depth-0 NF,
    viewed as a 1-var NF. -/
noncomputable def nf_x_proj' {sig : MonadicSignature}
    (sub_nf : NormalForm sig 0 2) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => sub_nf (.pred p ⟨0, by omega⟩)
  | .order i j h => absurd (Fin.ext (by omega) : i = j) h

/-- Extract the variable-1 (t) predicate assignment from a 2-var depth-0 NF,
    viewed as a 1-var NF. -/
noncomputable def nf_t_proj {sig : MonadicSignature}
    (sub_nf : NormalForm sig 0 2) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => sub_nf (.pred p ⟨1, by omega⟩)
  | .order i j h => absurd (Fin.ext (by omega) : i = j) h

/-! ## VecEA2 construction for depth-0 existentials -/

/-- Build the Until-direction VecEA2 for x > t: n=0 bracket, trivial interval. -/
noncomputable def nf_vecEA2_future {sig : MonadicSignature} [Fintype sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2) : VecEA2 0 :=
  { endpointLeft := nfPred atomMap h_surj (nf_t_proj sub_nf)
    endpointRight := nfPred atomMap h_surj (nf_x_proj' sub_nf)
    bracket := BracketFormula.trivial TemporalPred.top }

/-- Build the Since-direction VecEA2 for x < t: n=0 bracket, trivial interval. -/
noncomputable def nf_vecEA2_past {sig : MonadicSignature} [Fintype sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2) : VecEA2 0 :=
  { endpointLeft := nfPred atomMap h_surj (nf_x_proj' sub_nf)
    endpointRight := nfPred atomMap h_surj (nf_t_proj sub_nf)
    bracket := BracketFormula.trivial TemporalPred.top }

/-! ## Correctness helper: reconstruct 2-var depth-0 NF from components -/

private theorem reconstruct_nf_depth0 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 0 2)
    (x t : M.carrier)
    (h_x_nf : nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj' sub_nf))
    (h_t_nf : nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj sub_nf))
    (h_order_01 : (x < t) ↔
        (sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true))
    (h_order_10 : (t < x) ↔
        (sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)) :
    nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
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
  | .pred p ⟨1, _⟩ =>
    have := h_t_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, nf_t_proj] at this
    simp only [atom_eval]
    rw [hfc1]
    exact this
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

/-! ## Helper: trivial bracket at n=0 is vacuously true -/

private theorem bracket_trivial_top_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    (BracketFormula.trivial TemporalPred.top).holds M atomMap z0 z1 := by
  rw [BracketFormula.trivial_holds]
  intro y _ _
  simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]

/-! ## Helper: extract NF components from nf_eval_nf -/

private theorem extract_x_nf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 0 2) (x t : M.carrier)
    (h_nf : nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf) :
    nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj' sub_nf) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_x_proj'] at this ⊢
    exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

private theorem extract_t_nf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 0 2) (x t : M.carrier)
    (h_nf : nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf) :
    nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj sub_nf) := by
  have hfc1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
    simp [Fin.cons]; rfl
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨1, by omega⟩)
    simp only [atom_eval] at this
    rw [hfc1] at this
    simp only [nf_t_proj]
    exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-! ## Future direction (x > t): VecEA2.holdsLeft ↔ ∃ x > t, nf_eval_nf -/

/-- The Until-direction VecEA2 captures the future existential at depth 0.
    If sub_nf requires t < x (order 1→0 = true, order 0→1 = false), then
    holdsLeft of the future VecEA2 is equivalent to the restricted existential. -/
theorem nf_vecEA2_future_correct {sig : MonadicSignature} [Fintype sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2)
    (h_10 : sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_01 : sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    (nf_vecEA2_future atomMap h_surj sub_nf).holdsLeft M atomMap t ↔
    ∃ x : M.carrier,
      nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
  simp only [VecEA2.holdsLeft, nf_vecEA2_future]
  constructor
  · -- Backward: holdsLeft → ∃ x
    intro ⟨h_t_pred, x, h_lt, h_x_pred, _⟩
    rw [nfPred_correct] at h_t_pred h_x_pred
    exact ⟨x, reconstruct_nf_depth0 M sub_nf x t h_x_pred h_t_pred
      (by constructor
          · intro h_xlt; exact absurd (lt_trans h_xlt h_lt) (lt_irrefl _)
          · intro h_eq; rw [h_01] at h_eq; exact Bool.noConfusion h_eq)
      (by constructor
          · intro _; exact h_10
          · intro _; exact h_lt)⟩
  · -- Forward: ∃ x → holdsLeft
    intro ⟨x, h_nf⟩
    have h_x_nf := extract_x_nf M sub_nf x t h_nf
    have h_t_nf := extract_t_nf M sub_nf x t h_nf
    have h_o10 := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_o10
    have hfc0 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨0, by omega⟩ = x := by
      simp [Fin.cons]
    have hfc1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc1, hfc0] at h_o10
    refine ⟨(nfPred_correct M atomMap h_surj _ t).mpr h_t_nf,
            x, h_o10.mpr h_10,
            (nfPred_correct M atomMap h_surj _ x).mpr h_x_nf,
            bracket_trivial_top_holds M atomMap t x⟩

/-! ## Past direction (x < t): VecEA2.holdsRight ↔ ∃ x < t, nf_eval_nf -/

/-- The Since-direction VecEA2 captures the past existential at depth 0. -/
theorem nf_vecEA2_past_correct {sig : MonadicSignature} [Fintype sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2)
    (h_10 : sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_01 : sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    (nf_vecEA2_past atomMap h_surj sub_nf).holdsRight M atomMap t ↔
    ∃ x : M.carrier,
      nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
  simp only [VecEA2.holdsRight, nf_vecEA2_past]
  constructor
  · -- Backward: holdsRight → ∃ x
    intro ⟨h_t_pred, x, h_lt, h_x_pred, _⟩
    rw [nfPred_correct] at h_t_pred h_x_pred
    exact ⟨x, reconstruct_nf_depth0 M sub_nf x t h_x_pred h_t_pred
      (by constructor
          · intro _; exact h_01
          · intro _; exact h_lt)
      (by constructor
          · intro h_tlt; exact absurd (lt_trans h_lt h_tlt) (lt_irrefl _)
          · intro h_eq; rw [h_10] at h_eq; exact Bool.noConfusion h_eq)⟩
  · -- Forward: ∃ x → holdsRight
    intro ⟨x, h_nf⟩
    have h_x_nf := extract_x_nf M sub_nf x t h_nf
    have h_t_nf := extract_t_nf M sub_nf x t h_nf
    have h_o01 := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    simp only [atom_eval] at h_o01
    have hfc0 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨0, by omega⟩ = x := by
      simp [Fin.cons]
    have hfc1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc0, hfc1] at h_o01
    refine ⟨(nfPred_correct M atomMap h_surj _ t).mpr h_t_nf,
            x, h_o01.mpr h_01,
            (nfPred_correct M atomMap h_surj _ x).mpr h_x_nf,
            bracket_trivial_top_holds M atomMap x t⟩

/-! ## Equal case (x = t): characterization by predicate conjunction -/

/-- At depth 0, when sub_nf requires x = t (both order booleans false), the
    existential reduces to a conjunction of predicate conditions at t. -/
theorem nf_depth0_equal_correct {sig : MonadicSignature}
    (sub_nf : NormalForm sig 0 2)
    (h_10 : sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_01 : sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    (∃ x : M.carrier,
      nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf) ↔
    (nf_eval_nf M 0 1 (fun _ => t) (nf_x_proj' sub_nf) ∧
     nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj sub_nf)) := by
  constructor
  · intro ⟨x, h_nf⟩
    have h_x_nf := extract_x_nf M sub_nf x t h_nf
    have h_t_nf := extract_t_nf M sub_nf x t h_nf
    -- Show x = t
    have h_o01 := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    have h_o10 := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_o01 h_o10
    have hfc0 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨0, by omega⟩ = x := by
      simp [Fin.cons]
    have hfc1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc0, hfc1] at h_o01 h_o10
    have h_eq : x = t := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
      · exact Bool.noConfusion (h_01 ▸ h_o01.mp h_lt)
      · exact Bool.noConfusion (h_10 ▸ h_o10.mp h_gt)
    subst h_eq
    exact ⟨h_x_nf, h_t_nf⟩
  · intro ⟨h_x_nf, h_t_nf⟩
    exact ⟨t, reconstruct_nf_depth0 M sub_nf t t h_x_nf h_t_nf
      (by constructor
          · intro h; exact absurd h (lt_irrefl _)
          · intro h_eq; rw [h_01] at h_eq; exact Bool.noConfusion h_eq)
      (by constructor
          · intro h; exact absurd h (lt_irrefl _)
          · intro h_eq; rw [h_10] at h_eq; exact Bool.noConfusion h_eq)⟩

/-! ## Impossible case (both order booleans true) -/

/-- When both order booleans are true, the existential is unsatisfiable. -/
theorem nf_depth0_both_impossible {sig : MonadicSignature}
    (sub_nf : NormalForm sig 0 2)
    (h_10 : sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_01 : sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    ¬ ∃ x : M.carrier,
      nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro ⟨x, h_nf⟩
  have h_o01 := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  have h_o10 := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  simp only [atom_eval] at h_o01 h_o10
  have hfc0 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨0, by omega⟩ = x := by
    simp [Fin.cons]
  have hfc1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
    simp [Fin.cons]; rfl
  rw [hfc0, hfc1] at h_o01 h_o10
  exact absurd (lt_trans (h_o01.mpr h_01) (h_o10.mpr h_10)) (lt_irrefl _)

/-! ## Full depth-0 decomposition theorem

Combines all three order-direction cases into a single equivalence. -/

/-- Full depth-0 NF existential decomposition by order direction.

    At depth 0, `∃ x, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf`
    is equivalent to:
    - If sub_nf requires t < x: `holdsLeft` of the future VecEA2
    - If sub_nf requires x < t: `holdsRight` of the past VecEA2
    - If sub_nf requires x = t: conjunction of predicate conditions at t
    - If sub_nf requires both: False (unsatisfiable) -/
theorem nf_depth0_existential_decomp {sig : MonadicSignature} [Fintype sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2)
    (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    (∃ x : M.carrier,
      nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf) ↔
    (if sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true then
      if sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true then
        False  -- both directions: impossible
      else
        -- t < x only: Until direction
        (nf_vecEA2_future atomMap h_surj sub_nf).holdsLeft M atomMap t
    else
      if sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true then
        -- x < t only: Since direction
        (nf_vecEA2_past atomMap h_surj sub_nf).holdsRight M atomMap t
      else
        -- x = t: at-point
        nf_eval_nf M 0 1 (fun _ => t) (nf_x_proj' sub_nf) ∧
        nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj sub_nf)) := by
  -- Case split on order booleans
  cases h_10 : sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) <;>
  cases h_01 : sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) <;> simp only
      [Bool.false_eq_true, ↓reduceIte, iff_false, not_exists]
  · -- false, false: x = t
    exact nf_depth0_equal_correct sub_nf h_10 h_01 M t
  · -- false, true: Since direction
    exact (nf_vecEA2_past_correct atomMap h_surj sub_nf h_10 h_01 M t).symm
  · -- true, false: Until direction
    exact (nf_vecEA2_future_correct atomMap h_surj sub_nf h_10 h_01 M t).symm
  · -- true, true: impossible
    intro x h_nf
    exact nf_depth0_both_impossible sub_nf h_10 h_01 M t ⟨x, h_nf⟩

/-! ## VecEA2 Since-direction translation -/

/-- Translate a `VecEA2 n` to a temporal formula with the free variable at z_1 (Since). -/
noncomputable def VecEA2.translateRight {n : Nat} (vea : VecEA2 n) : Formula :=
  Formula.and vea.endpointRight.formula (bracketBuildLeft vea.bracket vea.endpointLeft)

/-- Correctness of `VecEA2.translateRight` at n = 0.
    At n = 0 the bracket is trivial, so this avoids the general
    `bracketBuildLeft_correct` (now provided sorry-free in VecEATranslation.lean). -/
theorem VecEA2.translateRight_correct_zero {sig : MonadicSignature}
    (vea : VecEA2 0)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t vea.translateRight ↔ vea.holdsRight M atomMap t := by
  simp only [translateRight, holdsRight]
  rw [temporal_truth_and]
  constructor
  · intro ⟨h1, h2⟩
    exact ⟨h1, (bracketBuildLeft_correct _ _ M atomMap t).mp h2⟩
  · intro ⟨h1, z0, hz0, hend, hbf⟩
    exact ⟨h1, (bracketBuildLeft_correct _ _ M atomMap t).mpr ⟨z0, hz0, hend, hbf⟩⟩

/-- Correctness of `VecEA2.translateRight` (general case). -/
theorem VecEA2.translateRight_correct {sig : MonadicSignature} {n : Nat}
    (vea : VecEA2 n)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t vea.translateRight ↔ vea.holdsRight M atomMap t := by
  simp only [translateRight, holdsRight]
  rw [temporal_truth_and]
  constructor
  · intro ⟨h1, h2⟩
    exact ⟨h1, (bracketBuildLeft_correct _ _ M atomMap t).mp h2⟩
  · intro ⟨h1, z0, hz0, hend, hbf⟩
    exact ⟨h1, (bracketBuildLeft_correct _ _ M atomMap t).mpr ⟨z0, hz0, hend, hbf⟩⟩

/-- Translate a `VVecEA2` to a Since-direction temporal formula. -/
noncomputable def VVecEA2.translateRight (v : VVecEA2) : Formula :=
  translateVEF1 (v.disjuncts.map fun ⟨_, vea⟩ => vea.translateRight)

/-- Correctness of `VVecEA2.translateRight`. -/
theorem VVecEA2.translateRight_correct {sig : MonadicSignature}
    (v : VVecEA2)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t v.translateRight ↔ v.holdsRight M atomMap t := by
  simp only [translateRight, holdsRight]
  rw [translateVEF1_correct]
  constructor
  · rintro ⟨f, hf_mem, hf⟩
    rw [List.mem_map] at hf_mem
    obtain ⟨⟨n, vea⟩, h_mem, rfl⟩ := hf_mem
    exact ⟨⟨n, vea⟩, h_mem, (vea.translateRight_correct M atomMap t).mp hf⟩
  · rintro ⟨⟨n, vea⟩, h_mem, h_holds⟩
    exact ⟨vea.translateRight,
           List.mem_map.mpr ⟨⟨n, vea⟩, h_mem, rfl⟩,
           (vea.translateRight_correct M atomMap t).mpr h_holds⟩

/-! ## Depth-0 temporal formula for 2-var existential

At depth 0, the existential `∃ x, nf_eval_nf M 0 2 (x, t) sub_nf` is
TL-definable via the VecEA2 decomposition:
- Future (t < x): VecEA2.translateLeft captures holdsLeft
- Past (x < t): VecEA2.translateRight captures holdsRight
- Equal (x = t): nfPred formula captures the predicate conjunction
- Both: False (impossible)

Rather than constructing a single formula and proving correctness through
complex if/match reduction, we use a classical existence proof that
composes the VecEA2 translation with the decomposition theorem.

### Proof Strategy

The decomposition theorem `nf_depth0_existential_decomp` decomposes the
existential into a 4-way case split on order booleans. Each case maps to
a temporal formula:
- holdsLeft → VecEA2.translateLeft
- holdsRight → VecEA2.translateRight
- predicate conjunction → nfPred formula
- False → Formula.bot

The temporal formula for the FULL existential is the disjunction of these
cases (or more precisely, the unique applicable case given the order booleans
is fixed by sub_nf).
-/

/-- At depth 0, the 2-var existential is TL-definable.

    Proof uses the decomposition theorem `nf_depth0_existential_decomp` which
    maps the existential to VecEA2.holdsLeft/holdsRight/predicate conditions,
    combined with the sorry-free VecEA2 translation infrastructure.

    The formula is constructed case-by-case on the order direction. -/
theorem nf_2var_exist_depth0_tl
    {sig : MonadicSignature} [Fintype sig.preds] (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2) :
    ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      temporal_truth M atomMap t A ↔
      ∃ x : M.carrier, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- Case split on order booleans (these are fixed by sub_nf)
  match h_10 : sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
        h_01 : sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
  | true, true =>
    -- Both orders true: existential is impossible
    exact ⟨Formula.bot, fun M t => by
      simp only [temporal_truth]
      constructor
      · intro h; exact absurd h id
      · intro ⟨x, h_nf⟩
        exact nf_depth0_both_impossible sub_nf h_10 h_01 M t ⟨x, h_nf⟩⟩
  | true, false =>
    -- t < x: Until direction via VecEA2.translateLeft
    exact ⟨(nf_vecEA2_future atomMap h_surj sub_nf).translateLeft, fun M t => by
      rw [VecEA2.translateLeft_correct]
      exact nf_vecEA2_future_correct atomMap h_surj sub_nf h_10 h_01 M t⟩
  | false, true =>
    -- x < t: Since direction via VecEA2.translateRight
    exact ⟨(nf_vecEA2_past atomMap h_surj sub_nf).translateRight, fun M t => by
      rw [VecEA2.translateRight_correct_zero]
      exact nf_vecEA2_past_correct atomMap h_surj sub_nf h_10 h_01 M t⟩
  | false, false =>
    -- x = t: predicate conjunction at t (both x-proj and t-proj must hold)
    exact ⟨Formula.and (nfPred atomMap h_surj (nf_x_proj' sub_nf)).formula
                        (nfPred atomMap h_surj (nf_t_proj sub_nf)).formula,
           fun M t => by
      rw [temporal_truth_and]
      constructor
      · -- Formula → existential
        intro ⟨h_x_form, h_t_form⟩
        have h_x_nf : nf_eval_nf M 0 1 (fun _ => t) (nf_x_proj' sub_nf) := by
          rw [← nfPred_correct M atomMap h_surj (nf_x_proj' sub_nf) t]; exact h_x_form
        have h_t_nf : nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj sub_nf) := by
          rw [← nfPred_correct M atomMap h_surj (nf_t_proj sub_nf) t]; exact h_t_form
        exact (nf_depth0_equal_correct sub_nf h_10 h_01 M t).mpr ⟨h_x_nf, h_t_nf⟩
      · -- Existential → formula
        intro ⟨x, h_nf⟩
        have h_x_nf := extract_x_nf M sub_nf x t h_nf
        have h_t_nf := extract_t_nf M sub_nf x t h_nf
        -- Show x = t
        have h_o01 := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
        have h_o10 := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
        simp only [atom_eval] at h_o01 h_o10
        have hfc0 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨0, by omega⟩ = x := by
          simp [Fin.cons]
        have hfc1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
          simp [Fin.cons]; rfl
        rw [hfc0, hfc1] at h_o01 h_o10
        have h_eq : x = t := by
          by_contra h_ne
          rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
          · exact Bool.noConfusion (h_01 ▸ h_o01.mp h_lt)
          · exact Bool.noConfusion (h_10 ▸ h_o10.mp h_gt)
        subst h_eq
        exact ⟨(nfPred_correct M atomMap h_surj (nf_x_proj' sub_nf) x).mpr h_x_nf,
               (nfPred_correct M atomMap h_surj (nf_t_proj sub_nf) x).mpr h_t_nf⟩⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp

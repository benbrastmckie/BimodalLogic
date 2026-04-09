import Bimodal.Metalogic.BXCanonical.TruthLemma
import Bimodal.Semantics.Validity

/-!
# Canonical Embedding: Fragment Completeness for BX Logic

This module proves fragment completeness for the temporal-free fragment of BX logic
(formulas built from atom, bot, imp, box only):

  For any temporal-free formula φ, if φ is valid then φ is derivable.

## Approach

We prove a bidirectional truth lemma for constant histories through BXPoints with
modal-equivalence-class Omega. For formulas without temporal operators (G, H, U, S),
MCS membership corresponds exactly to semantic truth:

  φ ∈ w.formulas ↔ truth_at canonical_valuation (modal_omega w) (constant_history w) t φ

The fragment completeness theorem follows by contrapositive: if φ is not derivable,
extend {¬φ} to an MCS w, then build a model where φ is false (by the backward
direction of the truth lemma), contradicting validity.

## Key Components

- **canonical_task_frame**: BXPoint states, permissive task_rel `d ≠ 0 ∨ w = u`
- **constant_history**: All times map to one BXPoint, full domain
- **modal_omega**: Constant histories through modally-equivalent BXPoints
- **canonical_valuation**: atom p true at w iff `atom p ∈ w.formulas`

## Scope and Limitations

This module covers the temporal-free fragment {atom, bot, imp, box}. Formulas
containing G, H, Until, or Since are explicitly excluded because the constant
history model collapses temporal structure (G(φ) becomes semantically equivalent
to φ, losing the universal-over-successors property).

Extension to the full Until/Since-free fragment requires non-constant histories
(e.g., two-point histories visiting multiple BXPoints) and a more complex
truth lemma bridge.

## References

- Burgess 1984, Goldblatt 1992 (completeness for tense logics)
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Semantics

/-! ## Temporal-Free Fragment Predicate -/

/--
A formula is temporal-free if it contains no temporal operators (G, H, U, S).
This is the fragment {atom, bot, imp, box} for which the constant-history
truth lemma is a complete iff.
-/
def temporalFree : Formula → Prop
  | .atom _ => True
  | .bot => True
  | .imp φ ψ => temporalFree φ ∧ temporalFree ψ
  | .box φ => temporalFree φ
  | .all_past _ => False
  | .all_future _ => False
  | .untl _ _ => False
  | .snce _ _ => False

/-! ## Canonical TaskFrame -/

/--
Canonical task frame with BXPoint states and permissive task relation.
-/
noncomputable def canonical_task_frame : TaskFrame Int where
  WorldState := BXPoint
  task_rel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h; cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h; exact Or.inr h
  forward_comp := fun w u v x y hx hy h1 h2 => by
    cases h1 with
    | inl hxne =>
      left; intro heq
      exact hxne (le_antisymm (Int.neg_nonneg.mp ((neg_eq_of_add_eq_zero_right heq).symm ▸ hy)) hx)
    | inr hw =>
      cases h2 with
      | inl hyne =>
        left; intro heq
        exact hyne (le_antisymm (Int.neg_nonneg.mp ((neg_eq_of_add_eq_zero_left heq).symm ▸ hx)) hy)
      | inr hu => exact Or.inr (hw.trans hu)
  converse := fun w d u => by
    constructor
    · intro h; cases h with
      | inl hd => exact Or.inl (by omega)
      | inr heq => exact Or.inr heq.symm
    · intro h; cases h with
      | inl hnd => exact Or.inl (by omega)
      | inr heq => exact Or.inr heq.symm

/-! ## Constant History -/

/--
Constant history through a single BXPoint. All times map to `w`, full domain.
-/
noncomputable def constant_history (w : BXPoint) : WorldHistory canonical_task_frame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => w
  respects_task := fun _ _ _ _ _ => Or.inr rfl

/--
Time-shifting a constant history yields the same history.
-/
theorem time_shift_constant_eq (w : BXPoint) (Δ : Int) :
    WorldHistory.time_shift (constant_history w) Δ = constant_history w :=
  WorldHistory.mk.injEq .. |>.mpr
    ⟨by ext t; constructor <;> intro _ <;> trivial,
     heq_of_eq (by ext t ht; rfl)⟩

/-! ## Canonical Valuation -/

/--
Canonical valuation: atom p true at w iff `atom p ∈ w.formulas`.
-/
noncomputable def canonical_valuation : TaskModel canonical_task_frame where
  valuation := fun w p => Formula.atom p ∈ w.formulas

/-! ## Modal Omega -/

/--
Constant histories through BXPoints modally equivalent to `w`.
-/
def modal_omega (w : BXPoint) : Set (WorldHistory canonical_task_frame) :=
  { σ | ∃ v : BXPoint, bx_modal_equiv w v ∧ σ = constant_history v }

theorem constant_history_mem_modal_omega (w : BXPoint) :
    constant_history w ∈ modal_omega w :=
  ⟨w, bx_modal_equiv_refl w, rfl⟩

theorem constant_history_mem_modal_omega_of_equiv {w v : BXPoint}
    (h : bx_modal_equiv w v) :
    constant_history v ∈ modal_omega w :=
  ⟨v, h, rfl⟩

theorem modal_omega_shift_closed (w : BXPoint) : ShiftClosed (modal_omega w) := by
  intro σ ⟨v, h_equiv, hσ⟩ Δ
  exact ⟨v, h_equiv, by rw [hσ, time_shift_constant_eq]⟩

theorem modal_omega_eq_of_equiv {w v : BXPoint} (h : bx_modal_equiv w v) :
    modal_omega w = modal_omega v := by
  ext σ; constructor
  · intro ⟨u, h_wu, hσ⟩; exact ⟨u, bx_modal_equiv_trans (bx_modal_equiv_symm h) h_wu, hσ⟩
  · intro ⟨u, h_vu, hσ⟩; exact ⟨u, bx_modal_equiv_trans h h_vu, hσ⟩

/-! ## Truth Lemma for Temporal-Free Fragment

For temporal-free formulas, MCS membership at w corresponds exactly to semantic
truth at (constant_history w, modal_omega w, any time t).
-/

/--
Bidirectional truth lemma for the temporal-free fragment.

For formulas built from {atom, bot, imp, box}:
  φ ∈ w.formulas ↔ truth_at canonical_valuation (modal_omega w) (constant_history w) t φ
-/
noncomputable def fragment_truth_iff (w : BXPoint) (φ : Formula)
    (h_tf : temporalFree φ) (t : Int) :
    φ ∈ w.formulas ↔
      truth_at canonical_valuation (modal_omega w) (constant_history w) t φ := by
  induction φ generalizing w t with
  | atom p =>
    simp only [truth_at, canonical_valuation, constant_history]
    exact ⟨fun h => ⟨trivial, h⟩, fun ⟨_, h⟩ => h⟩
  | bot =>
    simp only [truth_at]
    exact ⟨fun h => absurd h (bot_not_in_mcs w.is_mcs), False.elim⟩
  | imp ψ χ ih_ψ ih_χ =>
    have h_tf_ψ : temporalFree ψ := h_tf.1
    have h_tf_χ : temporalFree χ := h_tf.2
    simp only [truth_at]
    constructor
    · -- Forward: (ψ → χ) ∈ w, truth_at ψ ⊢ truth_at χ
      intro h_imp h_ψ_true
      have h_ψ_in := (ih_ψ w h_tf_ψ t).mpr h_ψ_true
      exact (ih_χ w h_tf_χ t).mp
        (SetMaximalConsistent.implication_property w.is_mcs h_imp h_ψ_in)
    · -- Backward: (truth_at ψ → truth_at χ) ⊢ (ψ → χ) ∈ w
      intro h_truth_imp
      by_cases h_ψ : ψ ∈ w.formulas
      · -- ψ ∈ w: forward gives truth_at ψ, hypothesis gives truth_at χ, backward gives χ ∈ w
        have h_χ_in := (ih_χ w h_tf_χ t).mpr
          (h_truth_imp ((ih_ψ w h_tf_ψ t).mp h_ψ))
        exact (imp_iff_mcs w.is_mcs ψ χ).mpr (fun _ => h_χ_in)
      · -- ψ ∉ w: (ψ → χ) ∈ w vacuously by imp_iff_mcs
        exact (imp_iff_mcs w.is_mcs ψ χ).mpr (fun h => absurd h h_ψ)
  | box ψ ih =>
    simp only [truth_at]
    constructor
    · -- Forward: □ψ ∈ w → ∀ σ ∈ modal_omega w, truth_at ψ at σ
      intro h_box σ ⟨v, h_equiv, hσ⟩
      subst hσ
      -- □ψ ∈ w → □ψ ∈ v (modal equiv) → ψ ∈ v (T axiom)
      have h_box_v := (h_equiv ψ).mp h_box
      have h_ψ_v := SetMaximalConsistent.implication_property v.is_mcs
        (theorem_in_mcs v.is_mcs (DerivationTree.axiom [] _ (Axiom.modal_t ψ))) h_box_v
      rw [modal_omega_eq_of_equiv h_equiv]
      exact (ih v h_tf t).mp h_ψ_v
    · -- Backward: (∀ σ ∈ modal_omega w, truth_at ψ at σ) → □ψ ∈ w
      intro h_all
      apply (box_iff_mcs w ψ).mpr
      intro v h_equiv
      have h_truth := h_all (constant_history v)
        (constant_history_mem_modal_omega_of_equiv h_equiv)
      rw [modal_omega_eq_of_equiv h_equiv] at h_truth
      exact (ih v h_tf t).mpr h_truth
  | all_future _ => exact absurd h_tf id
  | all_past _ => exact absurd h_tf id
  | untl _ _ => exact absurd h_tf id
  | snce _ _ => exact absurd h_tf id

/-! ## Consistency Lemma -/

/--
If φ is not derivable from the empty context, then {¬φ} is set-consistent.
(Duplicated from Completeness.lean to avoid circular imports.)
-/
private theorem neg_consistent_of_not_derivable' (φ : Formula)
    (h_not_deriv : ¬Nonempty (DerivationTree [] φ)) :
    SetConsistent ({Formula.neg φ} : Set Formula) := by
  intro L hL ⟨d⟩
  have h_all_neg : ∀ ψ ∈ L, ψ = Formula.neg φ :=
    fun ψ hψ => Set.mem_singleton_iff.mp (hL ψ hψ)
  by_cases h_in : Formula.neg φ ∈ L
  · let L_filt := L.filter (fun y => decide (y ≠ Formula.neg φ))
    have d_reord : DerivationTree (Formula.neg φ :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (cons_filter_neq_perm h_in x).symm)
    have h_filt_empty : L_filt = [] := by
      by_contra h_ne
      obtain ⟨a, ha⟩ := List.exists_mem_of_ne_nil _ h_ne
      have h_and := List.mem_filter.mp ha
      exact (by simpa using h_and.2 : a ≠ Formula.neg φ) (h_all_neg a h_and.1)
    rw [h_filt_empty] at d_reord
    exact h_not_deriv ⟨DerivationTree.modus_ponens [] _ _
      (Bimodal.Theorems.Propositional.double_negation φ)
      (deduction_theorem [] (Formula.neg φ) Formula.bot d_reord)⟩
  · have h_L_empty : L = [] := by
      by_contra h_ne
      obtain ⟨a, ha⟩ := List.exists_mem_of_ne_nil _ h_ne
      exact h_in ((h_all_neg a ha) ▸ ha)
    rw [h_L_empty] at d
    exact h_not_deriv ⟨DerivationTree.modus_ponens [] _ _
      (DerivationTree.axiom [] _ (Axiom.ex_falso φ)) d⟩

/-! ## Fragment Completeness Theorem -/

/--
Fragment completeness for temporal-free formulas: if φ is valid and temporal-free,
then φ is derivable.

Proof by contrapositive: assume φ not derivable, extend {¬φ} to MCS w with φ ∉ w,
build canonical model where φ is false (by backward truth lemma), contradicting validity.
-/
theorem fragment_completeness (φ : Formula) (h_tf : temporalFree φ)
    (h_valid : valid φ) : Nonempty (DerivationTree [] φ) := by
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable' φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_not_in : φ ∉ M :=
    SetMaximalConsistent.neg_excludes hM_mcs φ (hM_sup (Set.mem_singleton _))
  let w : BXPoint := ⟨M, hM_mcs⟩
  exact h_not_in ((fragment_truth_iff w φ h_tf 0).mpr
    (h_valid Int canonical_task_frame canonical_valuation
      (modal_omega w) (modal_omega_shift_closed w)
      (constant_history w) (constant_history_mem_modal_omega w) 0))

end Bimodal.Metalogic.BXCanonical

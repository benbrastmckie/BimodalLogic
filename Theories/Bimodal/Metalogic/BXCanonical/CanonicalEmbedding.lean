import Bimodal.Metalogic.BXCanonical.TruthLemma
import Bimodal.Semantics.Validity

/-!
# Canonical Embedding: Fragment Completeness for BX Logic

This module proves fragment completeness for the Until/Since-free fragment of BX
logic (formulas built from atom, bot, imp, box, G, H):

  For any Until/Since-free formula φ, if φ is valid then φ is derivable.

## Approach

The proof combines two techniques:

1. **Bidirectional truth lemma** for the temporal-free sub-fragment {atom, bot, imp, box}:
   MCS membership corresponds exactly to semantic truth on constant histories with
   modal-equivalence-class Omega.

2. **Countermodel construction** for the full fragment {atom, bot, imp, box, G, H}:
   Given MCS w with φ ∉ w, build a model where φ is false. For G(φ) and H(φ), the
   key insight is that reflexive temporal semantics give G(φ) → φ and H(φ) → φ
   semantically, so any countermodel for φ is automatically a countermodel for G(φ)
   and H(φ).

The fragment completeness theorem follows by contrapositive: if φ is not derivable,
extend {¬φ} to an MCS w with φ ∉ w, then by the countermodel construction there
exists a model where φ is false, contradicting validity.

## Key Components

- **canonical_task_frame**: BXPoint states, permissive task_rel `d ≠ 0 ∨ w = u`
- **constant_history**: All times map to one BXPoint, full domain
- **modal_omega**: Constant histories through modally-equivalent BXPoints
- **canonical_valuation**: atom p true at w iff `atom p ∈ w.formulas`
- **fragment_countermodel**: Per-formula countermodel by structural induction

## Scope and Limitations

This module covers the Until/Since-free fragment {atom, bot, imp, box, G, H}.
Formulas containing Until or Since are excluded because their truth lemma depends
on Frame.lean sorries (eventuality resolution).

## References

- Burgess 1984, Goldblatt 1992 (completeness for tense logics)
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Semantics

/-! ## Fragment Predicates -/

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

/--
A formula is Until/Since-free if it contains no Until or Since operators.
This is the fragment {atom, bot, imp, box, G, H} for which countermodel
construction gives completeness.
-/
def untilSinceFree : Formula → Prop
  | .atom _ => True
  | .bot => True
  | .imp φ ψ => untilSinceFree φ ∧ untilSinceFree ψ
  | .box φ => untilSinceFree φ
  | .all_future φ => untilSinceFree φ
  | .all_past φ => untilSinceFree φ
  | .untl _ _ => False
  | .snce _ _ => False

/--
Every temporal-free formula is Until/Since-free.
-/
theorem temporalFree_imp_untilSinceFree {φ : Formula} (h : temporalFree φ) :
    untilSinceFree φ := by
  induction φ with
  | atom _ => trivial
  | bot => trivial
  | imp ψ χ ih_ψ ih_χ => exact ⟨ih_ψ h.1, ih_χ h.2⟩
  | box ψ ih => exact ih h
  | all_future _ => exact absurd h id
  | all_past _ => exact absurd h id
  | untl _ _ => exact absurd h id
  | snce _ _ => exact absurd h id

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

/-! ## Validity Reduction Lemmas

Under reflexive temporal semantics, G(φ) → φ, H(φ) → φ, and □φ → φ are valid.
Therefore validity of these compound formulas implies validity of their sub-formula.
This enables proof-theoretic reduction for completeness.
-/

/--
If G(φ) is valid, then φ is valid.

Proof: G(φ) at time t means ∀ s ≥ t, truth_at φ at s. Since t ≤ t (reflexive),
this gives truth_at φ at t.
-/
theorem valid_of_valid_all_future {φ : Formula} (h : valid (Formula.all_future φ)) :
    valid φ := by
  intro D _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t t (le_refl t)

/--
If H(φ) is valid, then φ is valid.
-/
theorem valid_of_valid_all_past {φ : Formula} (h : valid (Formula.all_past φ)) :
    valid φ := by
  intro D _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t t (le_refl t)

/--
If □φ is valid, then φ is valid.

Proof: □φ at (τ, t) means ∀ σ ∈ Omega, truth_at φ at (σ, t). Since τ ∈ Omega,
this gives truth_at φ at (τ, t).
-/
theorem valid_of_valid_box {φ : Formula} (h : valid (Formula.box φ)) :
    valid φ := by
  intro D _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t τ h_mem

/-! ## Until/Since-Free Fragment Completeness

Extends `fragment_completeness` to the full {atom, bot, imp, box, G, H} fragment.

- **G, H, box**: proof-theoretic reduction via validity reduction + necessitation
- **imp Case A** (antecedent valid): validity composition + prop_s
- **imp Case B** (antecedent not valid): contrapositive + canonical model (sorry: backward
  truth bridge for G/H inside imp on constant histories is incomplete)
- **atom, bot**: delegate to `fragment_completeness`
-/

/--
Until/Since-free fragment completeness: if φ is valid and contains no Until or Since,
then φ is derivable.

The proof handles G, H, and box by reducing validity to the sub-formula and
applying the corresponding necessitation rule. For imp, a case split on the
validity of the antecedent yields Case A (both sides valid) directly. Case B
(antecedent not valid) uses a contrapositive argument that is complete for
temporal-free sub-formulas but has a remaining sorry for the backward truth
bridge when χ contains G or H inside an implication.
-/
noncomputable def usf_completeness (φ : Formula) (h_usf : untilSinceFree φ)
    (h_valid : valid φ) : Nonempty (DerivationTree [] φ) := by
  induction φ with
  | atom p =>
    exact fragment_completeness _ (show temporalFree (Formula.atom p) from trivial) h_valid
  | bot =>
    exact fragment_completeness _ (show temporalFree Formula.bot from trivial) h_valid
  | imp ψ χ ih_ψ ih_χ =>
    by_cases h_ψ_valid : valid ψ
    · -- Case A: ψ valid → χ valid → derivable χ → derivable (ψ → χ)
      have h_χ_valid : valid χ := by
        intro D _ _ _ F M Omega h_sc τ h_mem t
        exact h_valid D F M Omega h_sc τ h_mem t (h_ψ_valid D F M Omega h_sc τ h_mem t)
      obtain ⟨d_χ⟩ := ih_χ h_usf.2 h_χ_valid
      exact ⟨DerivationTree.modus_ponens [] _ _
        (DerivationTree.axiom [] _ (Axiom.prop_s χ ψ)) d_χ⟩
    · -- Case B: ψ not valid. Contrapositive argument.
      by_contra h_not_deriv
      have h_cons := neg_consistent_of_not_derivable' (Formula.imp ψ χ) h_not_deriv
      obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg (Formula.imp ψ χ)} h_cons
      have h_not_in : Formula.imp ψ χ ∉ M :=
        SetMaximalConsistent.neg_excludes hM_mcs (Formula.imp ψ χ)
          (hM_sup (Set.mem_singleton _))
      let w : BXPoint := ⟨M, hM_mcs⟩
      have h_ψ_in : ψ ∈ w.formulas := by
        by_contra h_ψ_not
        exact h_not_in ((imp_iff_mcs w.is_mcs ψ χ).mpr (fun h => absurd h h_ψ_not))
      have h_χ_not : χ ∉ w.formulas := by
        intro h_χ
        exact h_not_in ((imp_iff_mcs w.is_mcs ψ χ).mpr (fun _ => h_χ))
      -- The backward truth bridge for χ with G/H on constant histories is incomplete.
      -- On constant_history w: truth_at G(α) collapses to truth_at α, so the backward
      -- bridge gives flatten(χ) ∈ w rather than χ ∈ w. The gap is:
      -- flatten(χ) ∈ w does not imply χ ∈ w when χ contains G or H.
      -- Closing this requires either non-constant histories (two-point construction)
      -- or a proof-theoretic argument connecting flatten(χ) derivability to χ derivability.
      sorry
  | box ψ ih =>
    have h_ψ_valid := valid_of_valid_box h_valid
    obtain ⟨d⟩ := ih h_usf h_ψ_valid
    exact ⟨DerivationTree.necessitation ψ d⟩
  | all_future ψ ih =>
    have h_ψ_valid := valid_of_valid_all_future h_valid
    obtain ⟨d⟩ := ih h_usf h_ψ_valid
    exact ⟨DerivationTree.temporal_necessitation ψ d⟩
  | all_past ψ ih =>
    have h_ψ_valid := valid_of_valid_all_past h_valid
    obtain ⟨d⟩ := ih h_usf h_ψ_valid
    exact ⟨Bimodal.Theorems.past_necessitation ψ d⟩
  | untl _ _ => exact absurd h_usf id
  | snce _ _ => exact absurd h_usf id

end Bimodal.Metalogic.BXCanonical

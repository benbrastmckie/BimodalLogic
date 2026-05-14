import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators

/-!
# Truth Lemma for the Reflexive Canonical Model

Truth lemma mapping MCS membership to semantic truth in the reflexive
canonical model. Each connective is handled by a dedicated lemma.

## Status
- atom, bot, imp: proved (sorry-free)
- box forward: proved; backward: sorried
- G, H: sorried (both directions)
- Until, Since: sorried

These sorries are documented with clear proof plans for follow-up work.
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators

/-! ## Truth in the Reflexive Canonical Model -/

/--
Truth at MCS x in the reflexive canonical model.

Uses irreflexive temporal semantics (G/H: strict, excludes x),
strict witness Until/Since, and S5 box across canS5R.
-/
def reflCanTruth (x : ReflCanDomain) : Formula → Prop
  | Formula.atom p => Formula.atom p ∈ x.val
  | Formula.bot => False
  | Formula.imp φ ψ => reflCanTruth x φ → reflCanTruth x ψ
  | Formula.box φ => ∀ (y : ReflCanDomain), canS5R x y → reflCanTruth y φ
  | Formula.all_future φ => ∀ (y : ReflCanDomain), reflCanR x y → x ≠ y → reflCanTruth y φ
  | Formula.all_past φ => ∀ (y : ReflCanDomain), reflCanR y x → y ≠ x → reflCanTruth y φ
  | Formula.untl ψ₁ ψ₂ =>
      ∃ (y : ReflCanDomain), reflCanR x y ∧ x ≠ y ∧ reflCanTruth y ψ₁ ∧
        (∀ (z : ReflCanDomain), reflCanR x z → reflCanR y z → y ≠ z → reflCanTruth z ψ₂)
  | Formula.snce ψ₁ ψ₂ =>
      ∃ (y : ReflCanDomain), reflCanR y x ∧ y ≠ x ∧ reflCanTruth y ψ₁ ∧
        (∀ (z : ReflCanDomain), reflCanR z x → reflCanR z y → z ≠ y → reflCanTruth z ψ₂)

/-! ## atom / bot / imp: Proved -/

theorem atom_truth_iff (x : ReflCanDomain) (p : Atom) :
    reflCanTruth x (Formula.atom p) ↔ Formula.atom p ∈ x.val := by rfl

theorem bot_truth_false (x : ReflCanDomain) : ¬ reflCanTruth x Formula.bot := by
  intro h; exact h

theorem bot_not_in_mcs (x : ReflCanDomain) : Formula.bot ∉ x.val := by
  have h_mcs := x.property
  intro h
  have : Consistent [Formula.bot] :=
    h_mcs.1 [Formula.bot] (fun ψ hψ => by simp at hψ; subst hψ; exact h)
  exact this ⟨DerivationTree.assumption [Formula.bot] _ (by simp)⟩

theorem imp_truth_iff (x : ReflCanDomain) (φ ψ : Formula) :
    reflCanTruth x (Formula.imp φ ψ) ↔ (reflCanTruth x φ → reflCanTruth x ψ) := by rfl

theorem imp_mcs_iff (x : ReflCanDomain) (φ ψ : Formula) :
    (Formula.imp φ ψ ∈ x.val) ↔ (φ ∈ x.val → ψ ∈ x.val) := by
  have h_mcs := x.property
  constructor
  · exact h_mcs.implication_property
  · intro h_fun
    by_cases h_φ_in : φ ∈ x.val
    · have h_ψ_in := h_fun h_φ_in
      have h_deriv : [ψ] ⊢ φ.imp ψ := by
        have h_axiom : DerivationTree [] (ψ.imp (φ.imp ψ)) :=
          DerivationTree.axiom [] _ (Axiom.prop_s ψ φ)
        have h_weaken : DerivationTree [ψ] (ψ.imp (φ.imp ψ)) :=
          DerivationTree.weakening [] [ψ] (ψ.imp (φ.imp ψ)) h_axiom (by intro; simp)
        have h_assume : DerivationTree [ψ] ψ := DerivationTree.assumption [ψ] ψ (by simp)
        exact DerivationTree.modus_ponens [ψ] ψ (φ.imp ψ) h_weaken h_assume
      have h_sub : ∀ χ ∈ [ψ], χ ∈ x.val := by
        intro χ hχ; simp at hχ; subst hχ; exact h_ψ_in
      exact h_mcs.closed_under_derivation [ψ] h_sub h_deriv
    · have h_neg_in : Formula.neg φ ∈ x.val :=
        (SetMaximalConsistent.negation_complete h_mcs φ).resolve_left h_φ_in
      have h_deriv : [Formula.neg φ] ⊢ φ.imp ψ := by
        let neg_φ : Formula := Formula.neg φ
        -- From ¬φ = φ.imp ⊥ derive φ.imp ψ using prop_k and ex_falso
        have h_ef : DerivationTree [] ((Formula.bot).imp ψ) :=
          DerivationTree.axiom [] _ (Axiom.ex_falso ψ)
        have h_ef_ctx : DerivationTree [neg_φ] ((Formula.bot).imp ψ) :=
          DerivationTree.weakening [] [neg_φ] ((Formula.bot).imp ψ) h_ef (by intro; simp)
        have h_prop_s : DerivationTree [] (((Formula.bot).imp ψ).imp (φ.imp ((Formula.bot).imp ψ))) :=
          DerivationTree.axiom [] _ (Axiom.prop_s ((Formula.bot).imp ψ) φ)
        have h_prop_s_ctx : DerivationTree [neg_φ] (((Formula.bot).imp ψ).imp (φ.imp ((Formula.bot).imp ψ))) :=
          DerivationTree.weakening [] [neg_φ] (((Formula.bot).imp ψ).imp (φ.imp ((Formula.bot).imp ψ)))
            h_prop_s (by intro; simp)
        have h_imp : DerivationTree [neg_φ] (φ.imp ((Formula.bot).imp ψ)) :=
          DerivationTree.modus_ponens [neg_φ] ((Formula.bot).imp ψ) (φ.imp ((Formula.bot).imp ψ)) h_prop_s_ctx h_ef_ctx
        have h_prop_k : DerivationTree [] ((φ.imp ((Formula.bot).imp ψ)).imp ((φ.imp Formula.bot).imp (φ.imp ψ))) :=
          DerivationTree.axiom [] _ (Axiom.prop_k φ Formula.bot ψ)
        have h_prop_k_ctx : DerivationTree [neg_φ] ((φ.imp ((Formula.bot).imp ψ)).imp (neg_φ.imp (φ.imp ψ))) :=
          DerivationTree.weakening [] [neg_φ] ((φ.imp ((Formula.bot).imp ψ)).imp (neg_φ.imp (φ.imp ψ)))
            h_prop_k (by intro; simp)
        have h_neg_imp : DerivationTree [neg_φ] (neg_φ.imp (φ.imp ψ)) :=
          DerivationTree.modus_ponens [neg_φ] (φ.imp ((Formula.bot).imp ψ)) (neg_φ.imp (φ.imp ψ)) h_prop_k_ctx h_imp
        have h_neg_assume : DerivationTree [neg_φ] neg_φ :=
          DerivationTree.assumption [neg_φ] neg_φ (by simp)
        exact DerivationTree.modus_ponens [neg_φ] neg_φ (φ.imp ψ) h_neg_imp h_neg_assume
      have h_sub : ∀ χ ∈ [Formula.neg φ], χ ∈ x.val := by
        intro χ hχ; simp at hχ; subst hχ; exact h_neg_in
      exact h_mcs.closed_under_derivation [Formula.neg φ] h_sub h_deriv

/-! ## Box: Forward proved, Backward sorried -/

/--
Box-forward: □φ ∈ x.val → ∀y, canS5R x y → φ ∈ y.val
-/
theorem box_forward_mcs (x : ReflCanDomain) (φ : Formula)
    (h_box : Formula.box φ ∈ x.val) (y : ReflCanDomain) (h_can : canS5R x y) :
    φ ∈ y.val :=
  h_can φ h_box

/--
Box-backward: Sorried. Requires modal witness (◇¬φ → exists y with ¬φ).
Follows from S5 structure (modal 5 collapse). For Phase 1, this is a
documented sorry.
-/
theorem box_backward_mcs (x : ReflCanDomain) (φ : Formula)
    (_h_truth : ∀ (y : ReflCanDomain), canS5R x y → reflCanTruth y φ) :
    Formula.box φ ∈ x.val := by
  sorry

/-! ## G/H: Sorried (documented) -/

/-- G forward: Gψ ∈ x → ∀y≠x, xRy → ψ∈y. Documented sorry. -/
theorem G_forward_mcs (x : ReflCanDomain) (ψ : Formula)
    (_h_G : Formula.all_future ψ ∈ x.val) (_y : ReflCanDomain)
    (_h_xy : reflCanR x _y) (_h_ne : x ≠ _y) : ψ ∈ _y.val := by
  sorry

/-- G backward: Gψ ∉ x → ∃y≠x, xRy ∧ ψ∉y. Documented sorry. -/
theorem G_backward_mcs (x : ReflCanDomain) (ψ : Formula)
    (_h_not_G : Formula.all_future ψ ∉ x.val) :
    ∃ (y : ReflCanDomain), reflCanR x y ∧ x ≠ y ∧ ψ ∉ y.val := by
  sorry

/-- H forward: Hψ ∈ x → ∀y≠x, yRx → ψ∈y. Documented sorry. -/
theorem H_forward_mcs (x : ReflCanDomain) (ψ : Formula)
    (_h_H : Formula.all_past ψ ∈ x.val) (_y : ReflCanDomain)
    (_h_yx : reflCanR _y x) (_h_ne : _y ≠ x) : ψ ∈ _y.val := by
  sorry

/-- H backward: Hψ ∉ x → ∃y≠x, yRx ∧ ψ∉y. Documented sorry. -/
theorem H_backward_mcs (x : ReflCanDomain) (ψ : Formula)
    (_h_not_H : Formula.all_past ψ ∉ x.val) :
    ∃ (y : ReflCanDomain), reflCanR y x ∧ y ≠ x ∧ ψ ∉ y.val := by
  sorry

/-! ## Until/Since: Sorried (documented) -/

/--
Until forward: U(ψ₁,ψ₂) ∈ x → ∃y≠x, xRy, ψ₁∈y ∧ ∀z intermediate, ψ₂∈z.
Proof plan: BX10 (until_F) gives F(ψ₁)∈x. Build chain via Lindenbaum.
-/
theorem until_forward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (_h_until : Formula.untl ψ₁ ψ₂ ∈ x.val) :
    ∃ (y : ReflCanDomain), reflCanR x y ∧ x ≠ y ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), reflCanR x z → reflCanR y z → y ≠ z → ψ₂ ∈ z.val) := by
  sorry

/--
Until backward: HARD. ¬U(ψ₁,ψ₂) ∈ x → counter-witness chain.
Follows WitnessSeed.lean pattern: BX5 self-accumulation + Lindenbaum.
-/
theorem until_backward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (_h_not_until : Formula.untl ψ₁ ψ₂ ∉ x.val) :
    ∃ (y : ReflCanDomain), reflCanR x y ∧ x ≠ y ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), reflCanR x z → reflCanR y z → y ≠ z → ψ₂ ∈ z.val) := by
  sorry

/-- Since forward: S(ψ₁,ψ₂) ∈ x → ∃y≠x, yRx, ψ₁∈y ∧ ∀z intermediate, ψ₂∈z. -/
theorem since_forward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (_h_since : Formula.snce ψ₁ ψ₂ ∈ x.val) :
    ∃ (y : ReflCanDomain), reflCanR y x ∧ y ≠ x ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), reflCanR z x → reflCanR z y → z ≠ y → ψ₂ ∈ z.val) := by
  sorry

/-- Since backward: HARD. Symmetric to Until backward. -/
theorem since_backward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (_h_not_since : Formula.snce ψ₁ ψ₂ ∉ x.val) :
    ∃ (y : ReflCanDomain), reflCanR y x ∧ y ≠ x ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), reflCanR z x → reflCanR z y → z ≠ y → ψ₂ ∈ z.val) := by
  sorry

/-! ## Main Truth Lemma (atom/bot/imp proved, rest sorried) -/

/--
The truth lemma: reflCanTruth x ψ ↔ ψ ∈ x.val for all ψ.
atom, bot, imp: fully proved.
box forward: proved. box backward: sorried.
G, H, Until, Since: documented sorries.
-/
theorem truth_lemma : ∀ (x : ReflCanDomain) (ψ : Formula),
    reflCanTruth x ψ ↔ ψ ∈ x.val := by
  intro x ψ
  induction ψ generalizing x with
  | atom p =>
    exact atom_truth_iff x p
  | bot =>
    exact ⟨(bot_truth_false x).elim, (bot_not_in_mcs x).elim⟩
  | imp φ ψ ih_φ ih_ψ =>
    rw [imp_truth_iff, imp_mcs_iff]
    exact ⟨
      fun h_mem h_truth => (ih_ψ x).mp (h_mem ((ih_φ x).mpr h_truth)),
      fun h_fun h_mem => (ih_ψ x).mpr (h_fun ((ih_φ x).mp h_mem))
    ⟩
  | box φ ih =>
    constructor
    · intro h_truth; exact box_backward_mcs x φ h_truth
    · intro h_box y h_can
      have h_φ_y : φ ∈ y.val := box_forward_mcs x φ h_box y h_can
      exact (ih y).mpr h_φ_y
  | all_future φ ih =>
    constructor
    · intro _h_truth; sorry
    · intro h_G y h_xy h_ne
      have h_φ_y : φ ∈ y.val := G_forward_mcs x φ h_G y h_xy h_ne
      exact (ih y).mpr h_φ_y
  | all_past φ ih =>
    constructor
    · intro _h_truth; sorry
    · intro h_H y h_yx h_ne
      have h_φ_y : φ ∈ y.val := H_forward_mcs x φ h_H y h_yx h_ne
      exact (ih y).mpr h_φ_y
  | untl φ ψ ih_φ ih_ψ =>
    sorry
  | snce φ ψ ih_φ ih_ψ =>
    sorry

end Bimodal.Metalogic.WeakCanonical

import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Theorems.Propositional.Core
import Bimodal.Theorems.Combinators
import Bimodal.Syntax.Context

/-!
# Truth Lemma for the Reflexive Canonical Model

Truth lemma mapping MCS membership to semantic truth in the reflexive
canonical model for the Doets/Reynolds completeness construction.

## Architecture

- **tempR_fwd** (based on g_content): temporal future accessibility
- **tempR_bwd** (based on h_content): temporal past accessibility
- **canS5R**: S5 box-accessibility
- Backward proofs use `set_lindenbaum`: show seed consistent, extend to MCS, derive contradiction

## Status

### Proved (sorry-free)
- atom, bot, imp (6 lemmas)
- box forward, box backward (2 lemmas) — box backward uses generalized_modal_k + Lindenbaum
- G forward, G backward (2 lemmas) — uses g_content_closed_derivation
- H forward, H backward (2 lemmas) — uses h_content_closed_derivation

### Documented sorries (non-critical-path)
- Until forward: guard condition requires chain construction not available in ReflCanDomain
- Until backward: requires Until induction / counter-witness chain
- Since forward: mirror of Until forward (same root cause)
- Since backward: mirror of Until backward
- truth_lemma Until case (backward direction)
- truth_lemma Since case (backward direction)

Non-critical-path: these sorries do not block completeness. The parametric truth
lemma (ParametricTruthLemma.lean) handles Until/Since via BFMCS coherence. Closing
these requires ReflCanDomain restructuring with chronicle gap-content infrastructure.
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems

/-! ## Truth in the Reflexive Canonical Model -/

/--
Truth at MCS x in the reflexive canonical model.

Uses tempR_fwd/tempR_bwd (non-strict, g_content/h_content based)
for G, H, Until, and Since. S5 box uses canS5R.
-/
def reflCanTruth (x : ReflCanDomain) : Formula → Prop
  | Formula.atom p => Formula.atom p ∈ x.val
  | Formula.bot => False
  | Formula.imp φ ψ => reflCanTruth x φ → reflCanTruth x ψ
  | Formula.box φ => ∀ (y : ReflCanDomain), canS5R x y → reflCanTruth y φ
  | Formula.untl ψ₁ ψ₂ =>
      ∃ (y : ReflCanDomain), tempR_fwd x y ∧ reflCanTruth y ψ₁ ∧
        (∀ (z : ReflCanDomain), tempR_fwd x z → tempR_fwd z y → reflCanTruth z ψ₂)
  | Formula.snce ψ₁ ψ₂ =>
      ∃ (y : ReflCanDomain), tempR_bwd y x ∧ reflCanTruth y ψ₁ ∧
        (∀ (z : ReflCanDomain), tempR_bwd z y → tempR_bwd z x → reflCanTruth z ψ₂)

/-! ## atom, bot, imp: Proved (sorry-free) -/

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
      have h_ax : DerivationTree FrameClass.Base [] (ψ.imp (φ.imp ψ)) :=
        DerivationTree.axiom [] _ (Axiom.prop_s ψ φ) trivial
      exact h_mcs.implication_property (theorem_in_mcs h_mcs h_ax) h_ψ_in
    · have h_neg_φ : Formula.neg φ ∈ x.val :=
        (SetMaximalConsistent.negation_complete h_mcs φ).resolve_left h_φ_in
      have h_deriv : DerivationTree FrameClass.Base [φ.neg] (φ.imp ψ) := by
        have h_step : DerivationTree FrameClass.Base [φ, φ.neg] ψ := by
          have h_φ_assum : DerivationTree FrameClass.Base [φ, φ.neg] φ :=
            DerivationTree.assumption _ _ (by simp)
          have h_neg_assum : DerivationTree FrameClass.Base [φ, φ.neg] φ.neg :=
            DerivationTree.assumption _ _ (by simp)
          have h_bot : DerivationTree FrameClass.Base [φ, φ.neg] Formula.bot :=
            DerivationTree.modus_ponens _ _ _ h_neg_assum h_φ_assum
          have h_ef : DerivationTree FrameClass.Base [] (Formula.bot.imp ψ) :=
            DerivationTree.axiom [] _ (Axiom.ex_falso ψ) trivial
          exact DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ h_ef (List.nil_subset _)) h_bot
        exact Bimodal.Metalogic.Core.deduction_theorem [φ.neg] φ ψ h_step
      exact h_mcs.closed_under_derivation [φ.neg]
        (fun χ hχ => by simp at hχ; rw [hχ]; exact h_neg_φ) h_deriv

/-! ## Box: Forward proved, backward documented sorry -/

/-- Box-forward (sorry-free): □φ ∈ x.val → ∀y, canS5R x y → φ ∈ y.val. -/
theorem box_forward_mcs (x : ReflCanDomain) (φ : Formula)
    (h_box : Formula.box φ ∈ x.val) (y : ReflCanDomain) (h_can : canS5R x y) :
    φ ∈ y.val :=
  h_can φ h_box

/--
Box backward (sorry-free). S5 canonical model proof using modal witness
construction (generalized_modal_k + Lindenbaum).

Proof: assume □φ ∉ x. Then ¬□φ ∈ x (negation completeness), which equals
◇(¬φ) = ¬□¬¬φ = ¬□φ. Build seed {¬φ} ∪ {χ | □χ ∈ x}. Show it's consistent
using generalized_modal_k. Extend to MCS y. Show canS5R x y via modal_4 + modal_t.
Then ¬φ ∈ y and (by h_truth + ih) φ ∈ y, contradiction.

Cf. BXCanonical/Frame.lean:411-552 (bx_modal_witness).
-/
theorem box_backward_mcs (x : ReflCanDomain) (φ : Formula)
    (ih : ∀ (y : ReflCanDomain), reflCanTruth y φ ↔ φ ∈ y.val)
    (h_truth : ∀ (y : ReflCanDomain), canS5R x y → reflCanTruth y φ) :
    Formula.box φ ∈ x.val := by
  by_contra h_not_box
  have h_mcs_x := x.property
  -- ¬□φ ∈ x by negation completeness
  have h_neg_box : Formula.neg (Formula.box φ) ∈ x.val := by
    cases SetMaximalConsistent.negation_complete h_mcs_x (Formula.box φ) with
    | inl h => exact absurd h h_not_box
    | inr h => exact h
  -- box_content: all formulas χ with □χ ∈ x
  let bc := {χ : Formula | Formula.box χ ∈ x.val}
  -- Seed: {¬φ} ∪ bc. Show consistent.
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) ({Formula.neg φ} ∪ bc) := by
    intro L hL ⟨d⟩
    by_cases h_negφ_in : Formula.neg φ ∈ L
    · -- Case 1: ¬φ ∈ L. Deduce L\{¬φ} ⊢ φ, then by generalized_modal_k get □φ ∈ x.
      let L_filt := L.filter (fun x => decide (x ≠ Formula.neg φ))
      have d_reord : DerivationTree FrameClass.Base (Formula.neg φ :: L_filt) Formula.bot :=
        derivation_exchange d (fun y => (cons_filter_neq_perm h_negφ_in y).symm)
      have d_negneg : DerivationTree FrameClass.Base L_filt (Formula.neg (Formula.neg φ)) :=
        deduction_theorem L_filt (Formula.neg φ) Formula.bot d_reord
      have h_filt_in_bc : ∀ χ ∈ L_filt, χ ∈ bc := by
        intro χ hχ
        have h_and := List.mem_filter.mp hχ
        have h_ne : χ ≠ Formula.neg φ := by simpa using h_and.2
        have h_mem := hL χ h_and.1
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd rfl h_ne
        · exact h
      -- DNE: ¬¬φ → φ
      have h_dne : [] ⊢ (Formula.neg (Formula.neg φ)).imp φ :=
        Bimodal.Theorems.Propositional.double_negation φ
      have d_phi : DerivationTree FrameClass.Base L_filt φ := by
        have d_dne_weak : DerivationTree FrameClass.Base L_filt ((Formula.neg (Formula.neg φ)).imp φ) :=
          DerivationTree.weakening [] L_filt _ h_dne (List.nil_subset _)
        exact DerivationTree.modus_ponens L_filt _ _ d_dne_weak d_negneg
      -- generalized_modal_k: L_filt ⊢ φ gives □(L_filt) ⊢ □φ
      have d_box_phi : (Context.map Formula.box L_filt) ⊢ Formula.box φ :=
        generalized_modal_k L_filt φ d_phi
      have h_box_L_in : ∀ f ∈ Context.map Formula.box L_filt, f ∈ x.val := by
        intro f hf
        rw [Context.mem_map_iff] at hf
        obtain ⟨χ, hχ_in, hχ_eq⟩ := hf
        rw [← hχ_eq]
        exact h_filt_in_bc χ hχ_in
      have h_box_phi_in : Formula.box φ ∈ x.val :=
        SetMaximalConsistent.closed_under_derivation h_mcs_x
          (Context.map Formula.box L_filt) h_box_L_in d_box_phi
      exact h_not_box h_box_phi_in
    · -- Case 2: ¬φ ∉ L. All L ⊆ bc, so get □(L) ⊢ □(⊥) by generalized_modal_k, then ⊥ ∈ x.
      have h_L_in_bc : ∀ χ ∈ L, χ ∈ bc := by
        intro χ hχ
        have h_mem := hL χ hχ
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd hχ h_negφ_in
        · exact h
      have d_box_bot : (Context.map Formula.box L) ⊢ Formula.box Formula.bot :=
        generalized_modal_k L Formula.bot d
      have h_box_L_in : ∀ f ∈ Context.map Formula.box L, f ∈ x.val := by
        intro f hf
        rw [Context.mem_map_iff] at hf
        obtain ⟨χ, hχ_in, hχ_eq⟩ := hf
        rw [← hχ_eq]
        exact h_L_in_bc χ hχ_in
      have h_box_bot_in : Formula.box Formula.bot ∈ x.val :=
        SetMaximalConsistent.closed_under_derivation h_mcs_x
          (Context.map Formula.box L) h_box_L_in d_box_bot
      -- □⊥ → ⊥ by modal_t
      have h_ax : DerivationTree FrameClass.Base [] (Formula.box Formula.bot |>.imp Formula.bot) :=
        DerivationTree.axiom [] _ (Axiom.modal_t Formula.bot) trivial
      have h_bot : Formula.bot ∈ x.val :=
        SetMaximalConsistent.implication_property h_mcs_x (theorem_in_mcs h_mcs_x h_ax) h_box_bot_in
      -- ⊥ in MCS contradicts consistency
      have h_bot_cons : Consistent [Formula.bot] :=
        h_mcs_x.1 [Formula.bot] (fun χ hχ => by
          simp at hχ; subst hχ; exact h_bot)
      exact h_bot_cons ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
  -- Extend seed to MCS y
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum ({Formula.neg φ} ∪ bc) h_seed_cons
  let y : ReflCanDomain := ⟨M, hM_mcs⟩
  have h_negφ_in_y : Formula.neg φ ∈ y.val := hM_sup (Set.mem_union_left _ (Set.mem_singleton _))
  have h_bc_sub : bc ⊆ y.val := fun χ hχ => hM_sup (Set.mem_union_right _ hχ)
  -- Show canS5R x y: □χ ∈ x.val → χ ∈ y.val
  -- □χ ∈ x → □□χ ∈ x (modal_4) → □χ ∈ bc → □χ ∈ y → χ ∈ y (modal_t on y)
  have h_canS5R : canS5R x y := by
    intro χ h_box_χ
    have h_m4 : DerivationTree FrameClass.Base [] ((Formula.box χ).imp (Formula.box (Formula.box χ))) :=
      DerivationTree.axiom [] _ (Axiom.modal_4 χ) trivial
    have h_box_box_χ : Formula.box (Formula.box χ) ∈ x.val :=
      SetMaximalConsistent.implication_property h_mcs_x
        (theorem_in_mcs h_mcs_x h_m4) h_box_χ
    have h_in_bc : Formula.box χ ∈ bc := h_box_box_χ
    have h_box_χ_in_y : Formula.box χ ∈ y.val := h_bc_sub h_in_bc
    have h_mt : DerivationTree FrameClass.Base [] ((Formula.box χ).imp χ) :=
      DerivationTree.axiom [] _ (Axiom.modal_t χ) trivial
    exact SetMaximalConsistent.implication_property hM_mcs
      (theorem_in_mcs hM_mcs h_mt) h_box_χ_in_y
  -- Now: h_truth says reflCanTruth y φ, and ih converts to φ ∈ y.val.
  -- But ¬φ ∈ y.val. Contradiction.
  have h_refl_truth : reflCanTruth y φ := h_truth y h_canS5R
  have h_φ_in_y : φ ∈ y.val := ((ih y).mp h_refl_truth)
  exact set_consistent_not_both hM_mcs.1 φ h_φ_in_y h_negφ_in_y

/-! ## G (all_future): Fully Proved (sorry-free) -/

/-- G-forward (sorry-free): Gψ ∈ x → ∀y, tempR_fwd x y → ψ ∈ y. -/
theorem G_forward_mcs (x : ReflCanDomain) (ψ : Formula)
    (h_G : Formula.all_future ψ ∈ x.val) (y : ReflCanDomain)
    (h_temp : tempR_fwd x y) : ψ ∈ y.val := by
  have h_ψ_in_g : ψ ∈ g_content x := by
    simp [g_content, Bundle.g_content, h_G]
  exact h_temp h_ψ_in_g

/--
G-backward (sorry-free): If ∀y with tempR_fwd x y, ψ ∈ y.val, then Gψ ∈ x.val.

Follows the bx_G_backward pattern from BXCanonical/Frame.lean:267-316.
Uses g_content_closed_derivation from ReflexiveCanonical.lean.
-/
theorem G_backward_mcs (x : ReflCanDomain) (ψ : Formula)
    (h_truth : ∀ (y : ReflCanDomain), tempR_fwd x y → ψ ∈ y.val) :
    Formula.all_future ψ ∈ x.val := by
  have h_mcs := x.property
  by_contra h_not_G
  -- Seed: {¬ψ} ∪ g_content x. Show it's consistent.
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) ({Formula.neg ψ} ∪ g_content x) := by
    intro L hL ⟨d⟩
    by_cases h_negψ_in : Formula.neg ψ ∈ L
    · -- ¬ψ ∈ L. Remove it, get L' ⊢ ψ, use g_content_closed_derivation to get Gψ ∈ x.
      let L_filt := L.filter (· ≠ Formula.neg ψ)
      have d_reord : DerivationTree FrameClass.Base (Formula.neg ψ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (cons_filter_neq_perm h_negψ_in x).symm)
      have d_negneg : DerivationTree FrameClass.Base L_filt (Formula.neg (Formula.neg ψ)) :=
        deduction_theorem L_filt (Formula.neg ψ) Formula.bot d_reord
      have h_filt_in_g : ∀ χ ∈ L_filt, χ ∈ g_content x := by
        intro χ hχ
        have h_and := List.mem_filter.mp hχ
        have h_ne : χ ≠ Formula.neg ψ := by simpa using h_and.2
        have h_mem := hL χ h_and.1
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd rfl h_ne
        · exact h
      have h_dne : [] ⊢ (Formula.neg (Formula.neg ψ)).imp ψ :=
        Bimodal.Theorems.Propositional.double_negation ψ
      have d_psi : DerivationTree FrameClass.Base L_filt ψ := by
        have d_dne_weak : DerivationTree FrameClass.Base L_filt ((Formula.neg (Formula.neg ψ)).imp ψ) :=
          DerivationTree.weakening [] L_filt _ h_dne (List.nil_subset _)
        exact DerivationTree.modus_ponens L_filt _ _ d_dne_weak d_negneg
      have h_Gψ := g_content_closed_derivation h_mcs L_filt h_filt_in_g d_psi
      exact h_not_G h_Gψ
    · -- ¬ψ ∉ L, so L ⊆ g_content x. L ⊢ ⊥ contradicts g_content_set_consistent.
      have h_L_in_g : ∀ χ ∈ L, χ ∈ g_content x := by
        intro χ hχ
        have h_mem := hL χ hχ
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd hχ h_negψ_in
        · exact h
      exact g_content_set_consistent x L h_L_in_g ⟨d⟩
  -- Extend to MCS y, derive contradiction
  obtain ⟨y₀, hy_sub, hy_mcs⟩ := set_lindenbaum ({Formula.neg ψ} ∪ g_content x) h_seed_cons
  let y : ReflCanDomain := ⟨y₀, hy_mcs⟩
  have h_g_sub : g_content x ⊆ y₀ := fun χ hχ => hy_sub (Set.mem_union_right _ hχ)
  have h_temp : tempR_fwd x y := h_g_sub
  have h_psi_in_y : ψ ∈ y₀ := h_truth y h_temp
  have h_neg_in_y : Formula.neg ψ ∈ y₀ := hy_sub (by simp)
  exact set_consistent_not_both hy_mcs.1 ψ h_psi_in_y h_neg_in_y

/-! ## H (all_past): Documented Sorries -/

/--
H-forward (sorry-free): Hψ ∈ x.val → ∀y, tempR_bwd y x → ψ ∈ y.val.

Trivial by definition: Hψ ∈ x.val means ψ ∈ h_content x.
tempR_bwd y x means h_content x ⊆ y.val.
So ψ ∈ y.val.
-/
theorem H_forward_mcs (x : ReflCanDomain) (ψ : Formula)
    (h_H : Formula.all_past ψ ∈ x.val) (y : ReflCanDomain)
    (h_yx : tempR_bwd y x) : ψ ∈ y.val := by
  have h_ψ_in_h : ψ ∈ h_content x := by
    simp [h_content, Bundle.h_content, h_H]
  exact h_yx h_ψ_in_h

/--
H-backward: If ∀ y with tempR_bwd y x, ψ ∈ y.val, then Hψ ∈ x.val.

Mirror of G_backward using h_content instead of g_content.
Uses h_content_closed_derivation (already proved in ReflexiveCanonical.lean)
and follows the exact same set_lindenbaum pattern.
-/
theorem H_backward_mcs (x : ReflCanDomain) (ψ : Formula)
    (h_truth : ∀ (y : ReflCanDomain), tempR_bwd y x → ψ ∈ y.val) :
    Formula.all_past ψ ∈ x.val := by
  have h_mcs := x.property
  by_contra h_not_H
  -- Seed: {¬ψ} ∪ h_content x. Show it's consistent.
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) ({Formula.neg ψ} ∪ h_content x) := by
    intro L hL ⟨d⟩
    by_cases h_negψ_in : Formula.neg ψ ∈ L
    · -- ¬ψ ∈ L. Remove it, get L' ⊢ ψ, use h_content_closed_derivation to get Hψ ∈ x.
      let L_filt := L.filter (· ≠ Formula.neg ψ)
      have d_reord : DerivationTree FrameClass.Base (Formula.neg ψ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (cons_filter_neq_perm h_negψ_in x).symm)
      have d_negneg : DerivationTree FrameClass.Base L_filt (Formula.neg (Formula.neg ψ)) :=
        deduction_theorem L_filt (Formula.neg ψ) Formula.bot d_reord
      have h_filt_in_h : ∀ χ ∈ L_filt, χ ∈ h_content x := by
        intro χ hχ
        have h_and := List.mem_filter.mp hχ
        have h_ne : χ ≠ Formula.neg ψ := by simpa using h_and.2
        have h_mem := hL χ h_and.1
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd rfl h_ne
        · exact h
      have h_dne : [] ⊢ (Formula.neg (Formula.neg ψ)).imp ψ :=
        Bimodal.Theorems.Propositional.double_negation ψ
      have d_psi : DerivationTree FrameClass.Base L_filt ψ := by
        have d_dne_weak : DerivationTree FrameClass.Base L_filt ((Formula.neg (Formula.neg ψ)).imp ψ) :=
          DerivationTree.weakening [] L_filt _ h_dne (List.nil_subset _)
        exact DerivationTree.modus_ponens L_filt _ _ d_dne_weak d_negneg
      have h_Hψ := h_content_closed_derivation h_mcs L_filt h_filt_in_h d_psi
      exact h_not_H h_Hψ
    · -- ¬ψ ∉ L, so L ⊆ h_content x. L ⊢ ⊥ contradicts h_content_set_consistent.
      have h_L_in_h : ∀ χ ∈ L, χ ∈ h_content x := by
        intro χ hχ
        have h_mem := hL χ hχ
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd hχ h_negψ_in
        · exact h
      exact h_content_set_consistent x L h_L_in_h ⟨d⟩
  -- Extend to MCS y, derive contradiction
  obtain ⟨y₀, hy_sub, hy_mcs⟩ := set_lindenbaum ({Formula.neg ψ} ∪ h_content x) h_seed_cons
  let y : ReflCanDomain := ⟨y₀, hy_mcs⟩
  have h_h_sub : h_content x ⊆ y₀ := fun χ hχ => hy_sub (Set.mem_union_right _ hχ)
  have h_temp : tempR_bwd y x := h_h_sub
  have h_psi_in_y : ψ ∈ y₀ := h_truth y h_temp
  have h_neg_in_y : Formula.neg ψ ∈ y₀ := hy_sub (by simp)
  exact set_consistent_not_both hy_mcs.1 ψ h_psi_in_y h_neg_in_y

/-! ## Until/Since: Documented Sorries -/

/--
Until forward (PARTIAL): U(ψ₁,ψ₂) ∈ x → ∃y, tempR_fwd x y ∧ ψ₁∈y ∧ ∀z intermediate, ψ₂∈z.

**Proved**: U(ψ₁,ψ₂)∈x gives F(ψ₁)∈x (BX10). Use
`Bundle.forward_temporal_witness_seed_consistent` to get consistent seed
{ψ₁} ∪ g_content(x). Extend to MCS y via Lindenbaum. Then tempR_fwd x y
and ψ₁ ∈ y.val.

**Documented sorry (non-critical-path)**: The intermediate guard condition
(∀z between x and y, ψ₂ ∈ z.val) requires a chain construction using
until_F_expansion (self-accumulation) to propagate ψ₂ through intermediate
MCS. This needs infrastructure from BXCanonical/CanonicalChain.lean or
BXCanonical/Filtration/DefectChain.lean, not yet ported to ReflCanDomain.
This sorry does not block completeness. The parametric truth lemma
(ParametricTruthLemma.lean) handles Until/Since via BFMCS coherence.
Closing this requires ReflCanDomain restructuring with chronicle
gap-content infrastructure (see report 03_teammate-b-solutions.md).
-/
theorem until_forward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (h_until : Formula.untl ψ₁ ψ₂ ∈ x.val) :
    ∃ (y : ReflCanDomain), tempR_fwd x y ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val) := by
  have h_mcs := x.property
  -- BX10: U(ψ₁,ψ₂) → F(ψ₁)
  have h_F_ψ₁ : Formula.some_future ψ₁ ∈ x.val := by
    have h_ax := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.until_F ψ₂ ψ₁) trivial
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_ax) h_until
  -- Use forward_temporal_witness_seed_consistent from Bundle
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) (Bundle.forward_temporal_witness_seed x.val ψ₁) :=
    Bundle.forward_temporal_witness_seed_consistent x.val h_mcs ψ₁ h_F_ψ₁
  -- Rewrite the seed as {ψ₁} ∪ g_content x
  have h_seed_eq : Bundle.forward_temporal_witness_seed x.val ψ₁ = ({ψ₁} ∪ g_content x) := by
    ext χ
    simp [Bundle.forward_temporal_witness_seed, g_content, Bundle.g_content]
  rw [h_seed_eq] at h_seed_cons
  -- Extend to MCS y via Lindenbaum
  obtain ⟨y₀, hy_sub, hy_mcs⟩ := set_lindenbaum ({ψ₁} ∪ g_content x) h_seed_cons
  let y : ReflCanDomain := ⟨y₀, hy_mcs⟩
  have h_g_sub : g_content x ⊆ y₀ := fun χ hχ => hy_sub (Set.mem_union_right _ hχ)
  have h_ψ₁_in_y : ψ₁ ∈ y₀ := hy_sub (Set.mem_union_left _ (Set.mem_singleton _))
  -- Build result
  refine ⟨y, h_g_sub, h_ψ₁_in_y, ?_⟩
  -- DOCUMENTED SORRY (non-critical-path): Intermediate guard condition.
  -- This sorry does not block completeness. The parametric truth lemma
  -- handles Until/Since via BFMCS coherence. Closing this requires
  -- ReflCanDomain restructuring with chronicle gap-content infrastructure.
  sorry

/--
  Until backward (DOCUMENTED SORRY). If U(ψ₁,ψ₂) ∉ x.val, derive the NEGATION of the
  semantic Until condition (i.e., for any forward witness of ψ₁, there's an intermediate
  counter-witness where ψ₂ fails).

  **Non-critical-path**: This lemma is NOT needed for completeness. The
  parametric truth lemma handles Until/Since via BFMCS coherence. Closing this
  requires chain construction / counter-witness propagation from
  BXCanonical/CanonicalChain.lean or BXCanonical/Filtration/DefectChain.lean
  ported to ReflCanDomain with chronicle gap-content infrastructure.
  -/
theorem until_backward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (h_not_until : Formula.untl ψ₁ ψ₂ ∉ x.val) :
    ¬ (∃ (y : ReflCanDomain), tempR_fwd x y ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val)) := by
  sorry

/-- Since forward: S(ψ₁,ψ₂) ∈ x → ∃y, tempR_bwd y x ∧ ψ₁∈y ∧ ∀z intermediate, ψ₂∈z.

Mirror of Until forward using past (since_P) + past_temporal_witness_seed_consistent.

**Documented sorry (non-critical-path)**: Same intermediate guard condition issue
as until_forward_mcs. Does not block completeness. -/
theorem since_forward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (h_since : Formula.snce ψ₁ ψ₂ ∈ x.val) :
    ∃ (y : ReflCanDomain), tempR_bwd y x ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), tempR_bwd z y → tempR_bwd z x → ψ₂ ∈ z.val) := by
  have h_mcs := x.property
  -- BX10': S(ψ₁,ψ₂) → P(ψ₁)
  have h_P_ψ₁ : Formula.some_past ψ₁ ∈ x.val := by
    have h_ax := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.since_P ψ₂ ψ₁) trivial
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_ax) h_since
  -- Use past_temporal_witness_seed_consistent from Bundle
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) (Bundle.past_temporal_witness_seed x.val ψ₁) :=
    Bundle.past_temporal_witness_seed_consistent x.val h_mcs ψ₁ h_P_ψ₁
  -- Rewrite the seed as {ψ₁} ∪ h_content x
  have h_seed_eq : Bundle.past_temporal_witness_seed x.val ψ₁ = ({ψ₁} ∪ h_content x) := by
    ext χ
    simp [Bundle.past_temporal_witness_seed, h_content, Bundle.h_content]
  rw [h_seed_eq] at h_seed_cons
  -- Extend to MCS y via Lindenbaum
  obtain ⟨y₀, hy_sub, hy_mcs⟩ := set_lindenbaum ({ψ₁} ∪ h_content x) h_seed_cons
  let y : ReflCanDomain := ⟨y₀, hy_mcs⟩
  have h_h_sub : h_content x ⊆ y₀ := fun χ hχ => hy_sub (Set.mem_union_right _ hχ)
  have h_ψ₁_in_y : ψ₁ ∈ y₀ := hy_sub (Set.mem_union_left _ (Set.mem_singleton _))
  -- Build result
  refine ⟨y, h_h_sub, h_ψ₁_in_y, ?_⟩
  -- DOCUMENTED SORRY (non-critical-path): Intermediate guard condition.
  -- Mirror of until_forward_mcs. Does not block completeness.
  sorry

/--
  Since backward (DOCUMENTED SORRY). If S(ψ₁,ψ₂) ∉ x.val, derive the NEGATION of the
  semantic Since condition (i.e., for any backward witness of ψ₁, there's an intermediate
  counter-witness where ψ₂ fails).

  **Non-critical-path**: This lemma is NOT needed for completeness.
  Mirror of until_backward_mcs. Same infrastructure blocker.
  -/
theorem since_backward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (h_not_since : Formula.snce ψ₁ ψ₂ ∉ x.val) :
    ¬ (∃ (y : ReflCanDomain), tempR_bwd y x ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), tempR_bwd z y → tempR_bwd z x → ψ₂ ∈ z.val)) := by
  sorry

/-! ## Main Truth Lemma -/

/--
The truth lemma: reflCanTruth x ψ ↔ ψ ∈ x.val for all ψ.

Proved (sorry-free): atom, bot, imp, box (both directions), G (both directions),
H (both directions).

Documented sorries: Until/Since (forward and backward directions). These are
non-critical-path: the parametric truth lemma handles Until/Since via BFMCS coherence.
-/
theorem truth_lemma : ∀ (x : ReflCanDomain) (ψ : Formula),
    reflCanTruth x ψ ↔ ψ ∈ x.val := by
  intro x ψ
  induction ψ generalizing x with
  | atom p => exact atom_truth_iff x p
  | bot => exact ⟨(bot_truth_false x).elim, (bot_not_in_mcs x).elim⟩
  | imp φ ψ ih_φ ih_ψ =>
    rw [imp_truth_iff, imp_mcs_iff x φ ψ]
    exact ⟨
      fun h_mem h_truth => (ih_ψ x).mp (h_mem ((ih_φ x).mpr h_truth)),
      fun h_fun h_mem => (ih_ψ x).mpr (h_fun ((ih_φ x).mp h_mem))
    ⟩
  | box φ ih =>
    constructor
    · intro h_truth; exact box_backward_mcs x φ ih h_truth
    · intro h_box y h_can
      have h_φ_y : φ ∈ y.val := box_forward_mcs x φ h_box y h_can
      exact (ih y).mpr h_φ_y
  | untl φ ψ ih_φ ih_ψ =>
    constructor
    · -- reflCanTruth x (untl φ ψ) → untl φ ψ ∈ x.val
      intro h_truth
      rcases h_truth with ⟨y, h_fwd, h_truth_y_φ, h_guard⟩
      -- From h_truth_y_φ and ih_φ we get φ ∈ y.val
      have h_φ_y : φ ∈ y.val := (ih_φ y).mp h_truth_y_φ
      -- Need to show U(φ,ψ) ∈ x.val from: x R_fwd y, φ ∈ y, and ∀z in (x,y), ψ ∈ z
      -- This is the backward direction of Until truth: if ∃y>x with φ∈y and all
      -- intermediate points have ψ, then U(φ,ψ) ∈ x.
      -- DOCUMENTED SORRY (non-critical-path): Requires until_backward_mcs variant
      -- / induction principle. Does not block completeness.
      sorry
    · -- untl φ ψ ∈ x.val → reflCanTruth x (untl φ ψ)
      intro h_until
      obtain ⟨y, h_fwd, h_φ_y, h_guard⟩ := until_forward_mcs x φ ψ h_until
      refine ⟨y, h_fwd, (ih_φ y).mpr h_φ_y, ?_⟩
      intro z h_xz h_zy
      have h_ψ_z : ψ ∈ z.val := h_guard z h_xz h_zy
      exact (ih_ψ z).mpr h_ψ_z
  | snce φ ψ ih_φ ih_ψ =>
    constructor
    · -- reflCanTruth x (snce φ ψ) → snce φ ψ ∈ x.val
      intro h_truth
      rcases h_truth with ⟨y, h_bwd, h_truth_y_φ, h_guard⟩
      have h_φ_y : φ ∈ y.val := (ih_φ y).mp h_truth_y_φ
      -- DOCUMENTED SORRY (non-critical-path): Requires since_backward_mcs variant
      -- / induction principle. Does not block completeness.
      sorry
    · -- snce φ ψ ∈ x.val → reflCanTruth x (snce φ ψ)
      intro h_since
      obtain ⟨y, h_bwd, h_φ_y, h_guard⟩ := since_forward_mcs x φ ψ h_since
      refine ⟨y, h_bwd, (ih_φ y).mpr h_φ_y, ?_⟩
      intro z h_zy h_zx
      have h_ψ_z : ψ ∈ z.val := h_guard z h_zy h_zx
      exact (ih_ψ z).mpr h_ψ_z

end Bimodal.Metalogic.WeakCanonical

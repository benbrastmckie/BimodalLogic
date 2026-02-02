import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Metalogic.Core.MaximalConsistent

/-!
# MCS Properties for Canonical Model Construction

This module provides essential lemmas about Set-based Maximal Consistent Sets (MCS)
needed for the Representation layer's canonical model construction.

## Main Results

- `cons_filter_neq_perm`: Helper for context permutation with filter
- `derivation_exchange`: Derivability preserved under context permutation
- `set_mcs_closed_under_derivation`: Derivable formulas are in MCS
- `set_mcs_implication_property`: Modus ponens reflected in membership
- `set_mcs_negation_complete`: Either φ or ¬φ in MCS
- `temp_4_past`: Derived temporal 4 axiom for past
- `set_mcs_all_future_all_future`: Gφ ∈ S → GGφ ∈ S
- `set_mcs_all_past_all_past`: Hφ ∈ S → HHφ ∈ S

## Dependencies

Depends on `DeductionTheorem.lean` for the deduction theorem and
`MaximalConsistent.lean` for MCS definitions.
-/

namespace Bimodal.Metalogic.Core

open Bimodal.Syntax
open Bimodal.ProofSystem

/-! ## Helper Lemmas -/

/--
Helper: If `A ∈ Γ'`, then `A :: Γ'.filter (fun x => decide (x ≠ A))` has the same elements as `Γ'`.
-/
lemma cons_filter_neq_perm {A : Formula} {Γ' : Context}
    (h_mem : A ∈ Γ') : ∀ x, x ∈ A :: Γ'.filter (fun y => decide (y ≠ A)) ↔ x ∈ Γ' := by
  intro x
  constructor
  · intro h
    simp only [List.mem_cons] at h
    cases h with
    | inl h_eq =>
      subst h_eq
      exact h_mem
    | inr h_in =>
      simp only [List.mem_filter, decide_eq_true_eq] at h_in
      exact h_in.1
  · intro h
    by_cases hx : x = A
    · subst hx
      simp only [List.mem_cons, true_or]
    · simp only [List.mem_cons, List.mem_filter, decide_eq_true_eq]
      right
      exact ⟨h, hx⟩

/--
Exchange lemma for derivations: If Γ and Γ' have the same elements, derivation is preserved.
-/
def derivation_exchange {Γ Γ' : Context} {φ : Formula}
    (h : Γ ⊢ φ) (h_perm : ∀ x, x ∈ Γ ↔ x ∈ Γ') : Γ' ⊢ φ :=
  DerivationTree.weakening Γ Γ' φ h (fun x hx => (h_perm x).mp hx)

/-! ## Set-Based MCS Properties -/

/--
For set-based MCS, derivable formulas are in the set.

If S is SetMaximalConsistent and L ⊆ S derives φ, then φ ∈ S.
-/
lemma set_mcs_closed_under_derivation {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ S)
    (h_deriv : DerivationTree L φ) : φ ∈ S := by
  -- By contradiction: assume φ ∉ S
  by_contra h_not_mem
  -- By SetMaximalConsistent definition, insert φ S is inconsistent
  have h_incons : ¬SetConsistent (insert φ S) := h_mcs.2 φ h_not_mem
  -- SetConsistent means all finite subsets are consistent
  -- We have L ⊆ S and L ⊢ φ
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons
  -- L' ⊆ insert φ S and L' is inconsistent
  -- If φ ∉ L', then L' ⊆ S, contradicting S consistent.
  -- So φ ∈ L'. Then by deduction theorem, L' \ {φ} ⊢ φ → ⊥.
  -- Combined with L ⊢ φ, we can derive ⊥ from L ∪ (L' \ {φ}) ⊆ S.
  by_cases h_phi_in_L' : φ ∈ L'
  · -- φ ∈ L'. Use exchange to put φ first, then deduction theorem.
    -- We have L' ⊢ ⊥ (since L' is inconsistent)
    have ⟨d_bot⟩ : Nonempty (DerivationTree L' Formula.bot) := by
      unfold Consistent at h_L'_incons
      push_neg at h_L'_incons
      exact h_L'_incons
    -- Exchange to put φ first: L' has same elements as φ :: L'.filter (fun x => x ≠ φ)
    let L'_filt := L'.filter (fun y => decide (y ≠ φ))
    have h_perm := cons_filter_neq_perm h_phi_in_L'
    have d_bot_reord : DerivationTree (φ :: L'_filt) Formula.bot :=
      derivation_exchange d_bot (fun x => (h_perm x).symm)
    -- Apply deduction theorem
    have d_neg_phi : DerivationTree L'_filt (Formula.neg φ) :=
      deduction_theorem L'_filt φ Formula.bot d_bot_reord
    -- L'_filt ⊆ S
    have h_filt_sub : ∀ ψ, ψ ∈ L'_filt → ψ ∈ S := by
      intro ψ h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L' : ψ ∈ L' := h_and.1
      have h_ne : ψ ≠ φ := by
        simp only [decide_eq_true_eq] at h_and
        exact h_and.2
      have := h_L'_sub ψ h_in_L'
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq h_ne
      | inr h_in_S => exact h_in_S
    -- From L ⊢ φ (weakened) and L'_filt ⊢ ¬φ, derive ⊥ from L ∪ L'_filt
    -- Weaken both to L ++ L'_filt
    let Γ := L ++ L'_filt
    have h_Γ_sub : ∀ ψ ∈ Γ, ψ ∈ S := by
      intro ψ h_mem
      cases List.mem_append.mp h_mem with
      | inl h_L => exact h_sub ψ h_L
      | inr h_filt => exact h_filt_sub ψ h_filt
    have d_phi_Γ : DerivationTree Γ φ :=
      DerivationTree.weakening L Γ φ h_deriv (List.subset_append_left L _)
    have d_neg_Γ : DerivationTree Γ (Formula.neg φ) :=
      DerivationTree.weakening L'_filt Γ (Formula.neg φ) d_neg_phi
        (List.subset_append_right L _)
    have d_bot_Γ : DerivationTree Γ Formula.bot :=
      derives_bot_from_phi_neg_phi d_phi_Γ d_neg_Γ
    -- This contradicts S being consistent
    exact h_mcs.1 Γ h_Γ_sub ⟨d_bot_Γ⟩
  · -- φ ∉ L', so L' ⊆ S
    have h_L'_in_S : ∀ ψ ∈ L', ψ ∈ S := by
      intro ψ h_mem
      have := h_L'_sub ψ h_mem
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq (fun h' => h_phi_in_L' (h' ▸ h_mem))
      | inr h_in_S => exact h_in_S
    -- L' ⊆ S and L' is inconsistent contradicts S consistent
    unfold Consistent at h_L'_incons
    push_neg at h_L'_incons
    exact h_mcs.1 L' h_L'_in_S h_L'_incons

/--
Set-based MCS implication property: modus ponens is reflected in membership.

If (φ → ψ) ∈ S and φ ∈ S for a SetMaximalConsistent S, then ψ ∈ S.
-/
theorem set_mcs_implication_property {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_imp : (φ.imp ψ) ∈ S) (h_phi : φ ∈ S) : ψ ∈ S := by
  -- Use set_mcs_closed_under_derivation with L = [φ, φ.imp ψ]
  have h_sub : ∀ χ ∈ [φ, φ.imp ψ], χ ∈ S := by
    intro χ h_mem
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at h_mem
    cases h_mem with
    | inl h_eq => exact h_eq ▸ h_phi
    | inr h_eq => exact h_eq ▸ h_imp
  -- Derive ψ from [φ, φ → ψ]
  have h_deriv : DerivationTree [φ, φ.imp ψ] ψ := by
    have h_assume_phi : [φ, φ.imp ψ] ⊢ φ :=
      DerivationTree.assumption [φ, φ.imp ψ] φ (by simp)
    have h_assume_imp : [φ, φ.imp ψ] ⊢ φ.imp ψ :=
      DerivationTree.assumption [φ, φ.imp ψ] (φ.imp ψ) (by simp)
    exact DerivationTree.modus_ponens [φ, φ.imp ψ] φ ψ h_assume_imp h_assume_phi
  exact set_mcs_closed_under_derivation h_mcs [φ, φ.imp ψ] h_sub h_deriv

/--
Set-based MCS: negation completeness.

For SetMaximalConsistent S, either φ ∈ S or (¬φ) ∈ S.
-/
theorem set_mcs_negation_complete {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ (Formula.neg φ) ∈ S := by
  by_cases h : φ ∈ S
  · left; exact h
  · right
    -- If φ ∉ S, then insert φ S is inconsistent
    have h_incons : ¬SetConsistent (insert φ S) := h_mcs.2 φ h
    unfold SetConsistent at h_incons
    push_neg at h_incons
    obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons
    -- L' is inconsistent and L' ⊆ insert φ S
    -- If φ ∉ L', then L' ⊆ S contradicts S consistent
    -- So φ ∈ L'. By deduction theorem on L' (reordered to have φ first):
    -- L' \ {φ} ⊢ φ → ⊥, i.e., L' \ {φ} ⊢ ¬φ
    by_cases h_phi_in_L' : φ ∈ L'
    · -- φ ∈ L'. Use exchange and deduction theorem.
      have ⟨d_bot⟩ : Nonempty (DerivationTree L' Formula.bot) := by
        unfold Consistent at h_L'_incons
        push_neg at h_L'_incons
        exact h_L'_incons
      -- Exchange to put φ first using filter
      let L'_filt := L'.filter (fun y => decide (y ≠ φ))
      have h_perm := cons_filter_neq_perm h_phi_in_L'
      have d_bot_reord : DerivationTree (φ :: L'_filt) Formula.bot :=
        derivation_exchange d_bot (fun x => (h_perm x).symm)
      -- Apply deduction theorem
      have d_neg_phi : DerivationTree L'_filt (Formula.neg φ) :=
        deduction_theorem L'_filt φ Formula.bot d_bot_reord
      -- L'_filt ⊆ S
      have h_filt_sub : ∀ ψ, ψ ∈ L'_filt → ψ ∈ S := by
        intro ψ h_mem
        have h_and := List.mem_filter.mp h_mem
        have h_in_L' : ψ ∈ L' := h_and.1
        have h_ne : ψ ≠ φ := by
          simp only [decide_eq_true_eq] at h_and
          exact h_and.2
        have := h_L'_sub ψ h_in_L'
        cases Set.mem_insert_iff.mp this with
        | inl h_eq => exact absurd h_eq h_ne
        | inr h_in_S => exact h_in_S
      -- Now derive ¬φ ∈ S using set_mcs_closed_under_derivation
      exact set_mcs_closed_under_derivation h_mcs L'_filt h_filt_sub d_neg_phi
    · -- φ ∉ L', so L' ⊆ S
      have h_L'_in_S : ∀ ψ ∈ L', ψ ∈ S := by
        intro ψ h_mem
        have := h_L'_sub ψ h_mem
        cases Set.mem_insert_iff.mp this with
        | inl h_eq => exact absurd h_eq (fun h' => h_phi_in_L' (h' ▸ h_mem))
        | inr h_in_S => exact h_in_S
      -- L' ⊆ S and L' is inconsistent contradicts S consistent
      unfold Consistent at h_L'_incons
      push_neg at h_L'_incons
      exact absurd h_L'_incons (h_mcs.1 L' h_L'_in_S)

/-! ## Temporal Properties -/

/--
Set-based MCS: temporal 4 axiom property for all_future.

If Gφ ∈ S for a SetMaximalConsistent S, then GGφ ∈ S.

**Proof Strategy**:
1. Temporal 4 axiom: Gφ → GGφ
2. With Gφ ∈ S, derive GGφ via modus ponens
3. By closure: GGφ ∈ S

This is the future transitivity property: always future implies always always future.
-/
theorem set_mcs_all_future_all_future {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_all_future : Formula.all_future φ ∈ S) : (Formula.all_future φ).all_future ∈ S := by
  -- Temporal 4 axiom: Gφ → GGφ
  have h_temp_4_thm : [] ⊢ (Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ)
  -- Weaken to context [Gφ]
  have h_temp_4 : [Formula.all_future φ] ⊢ (Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)) :=
    DerivationTree.weakening [] _ _ h_temp_4_thm (by intro; simp)
  -- Assume Gφ in context
  have h_all_future_assume : [Formula.all_future φ] ⊢ Formula.all_future φ :=
    DerivationTree.assumption _ _ (by simp)
  -- Apply modus ponens to get GGφ
  have h_deriv : [Formula.all_future φ] ⊢ (Formula.all_future φ).all_future :=
    DerivationTree.modus_ponens _ _ _ h_temp_4 h_all_future_assume
  -- By closure: GGφ ∈ S
  have h_sub : ∀ χ ∈ [Formula.all_future φ], χ ∈ S := by simp [h_all_future]
  exact set_mcs_closed_under_derivation h_mcs [Formula.all_future φ] h_sub h_deriv

/--
Derivation of temporal 4 axiom for past: Hφ → HHφ.

Derived by applying temporal duality to the temp_4 axiom (Gφ → GGφ).
-/
def temp_4_past (φ : Formula) : DerivationTree [] (φ.all_past.imp φ.all_past.all_past) := by
  -- We want: Hφ → HHφ
  -- By temporal duality from: Gψ → GGψ where ψ = swap_temporal φ
  -- swap_temporal of (Gψ → GGψ) = Hφ' → HHφ' where φ' = swap_temporal ψ = φ
  let ψ := φ.swap_temporal
  -- Step 1: Get T4 axiom for ψ: Gψ → GGψ
  have h1 : DerivationTree [] (ψ.all_future.imp ψ.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 ψ)
  -- Step 2: Apply temporal duality to get: H(swap ψ) → HH(swap ψ)
  have h2 : DerivationTree [] (ψ.all_future.imp ψ.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ h1
  -- Step 3: The result has type H(swap ψ) → HH(swap ψ) = Hφ → HHφ
  -- since swap(swap φ) = φ by involution
  have h3 : (ψ.all_future.imp ψ.all_future.all_future).swap_temporal =
      φ.all_past.imp φ.all_past.all_past := by
    -- ψ = φ.swap_temporal, so ψ.swap_temporal = φ.swap_temporal.swap_temporal = φ
    simp only [Formula.swap_temporal]
    -- Now we need to show: ψ.swap_temporal.all_past.imp ... = φ.all_past.imp ...
    -- where ψ.swap_temporal = φ by involution
    have h_inv : ψ.swap_temporal = φ := Formula.swap_temporal_involution φ
    rw [h_inv]
  rw [h3] at h2
  exact h2

/--
Set-based MCS: temporal 4 axiom property for all_past.

If Hφ ∈ S for a SetMaximalConsistent S, then HHφ ∈ S.

**Proof Strategy**:
1. Use derived temp_4_past: Hφ → HHφ
2. With Hφ ∈ S, derive HHφ via modus ponens
3. By closure: HHφ ∈ S

This is the past transitivity property: always past implies always always past.
-/
theorem set_mcs_all_past_all_past {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_all_past : Formula.all_past φ ∈ S) : (Formula.all_past φ).all_past ∈ S := by
  -- Derived temporal 4 for past: Hφ → HHφ
  have h_temp_4_past_thm : [] ⊢ (Formula.all_past φ).imp (Formula.all_past (Formula.all_past φ)) :=
    temp_4_past φ
  -- Weaken to context [Hφ]
  have h_temp_4 : [Formula.all_past φ] ⊢ (Formula.all_past φ).imp (Formula.all_past (Formula.all_past φ)) :=
    DerivationTree.weakening [] _ _ h_temp_4_past_thm (by intro; simp)
  -- Assume Hφ in context
  have h_all_past_assume : [Formula.all_past φ] ⊢ Formula.all_past φ :=
    DerivationTree.assumption _ _ (by simp)
  -- Apply modus ponens to get HHφ
  have h_deriv : [Formula.all_past φ] ⊢ (Formula.all_past φ).all_past :=
    DerivationTree.modus_ponens _ _ _ h_temp_4 h_all_past_assume
  -- By closure: HHφ ∈ S
  have h_sub : ∀ χ ∈ [Formula.all_past φ], χ ∈ S := by simp [h_all_past]
  exact set_mcs_closed_under_derivation h_mcs [Formula.all_past φ] h_sub h_deriv

/-! ## Consistency Properties -/

/--
In a set-consistent set, φ and φ.neg cannot both be members.

**Proof Strategy**:
1. Build derivation [φ, φ.neg] ⊢ ⊥ using modus ponens
2. Since [φ, φ.neg] ⊆ S and S is consistent, this is a contradiction
-/
theorem set_consistent_not_both {S : Set Formula} (h_cons : SetConsistent S)
    (phi : Formula) (h_phi : phi ∈ S) (h_neg : phi.neg ∈ S) : False := by
  -- [phi, phi.neg] ⊢ ⊥
  have h_deriv : DerivationTree [phi, phi.neg] Formula.bot := by
    -- phi.neg = phi → ⊥
    -- From phi and phi → ⊥, derive ⊥ by modus ponens
    have h_phi_assume : DerivationTree [phi, phi.neg] phi :=
      DerivationTree.assumption _ _ (by simp)
    have h_neg_assume : DerivationTree [phi, phi.neg] phi.neg :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ phi Formula.bot h_neg_assume h_phi_assume
  -- But [phi, phi.neg] ⊆ S, so S is inconsistent
  have h_sub : ∀ ψ ∈ [phi, phi.neg], ψ ∈ S := by
    intro ψ hψ
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
    cases hψ with
    | inl h => exact h ▸ h_phi
    | inr h => exact h ▸ h_neg
  exact h_cons [phi, phi.neg] h_sub ⟨h_deriv⟩

/--
If φ.neg is in a set-maximal consistent set M, then φ is not in M.

This is the contrapositive of negation completeness: if ¬φ ∈ M, then φ ∉ M.
Used in the completeness proof to show countermodels exist.
-/
theorem set_mcs_neg_excludes {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (phi : Formula) (h_neg : phi.neg ∈ S) : phi ∉ S := by
  intro h_phi
  exact set_consistent_not_both h_mcs.1 phi h_phi h_neg

end Bimodal.Metalogic.Core

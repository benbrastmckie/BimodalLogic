import Bimodal.Metalogic.Core.RestrictedMCS.Basic
import Bimodal.Metalogic.Bundle.SuccExistence

/-!
# Deferral-Restricted MCS: Closure Under Derivation and Deferral-Specific Properties

MCS restricted to deferralClosure(phi) instead of closureWithNeg(phi).
The deferralClosure includes the deferral disjunctions needed by the
successor seed construction while preserving the same F/P-depth bounds.

## Main Definitions

- `DeferralRestricted`: A set is deferral-restricted if it's a subset of deferralClosure
- `DeferralRestrictedConsistent`: Deferral-restricted and set-consistent
- `DeferralRestrictedMCS`: Maximal consistent within deferralClosure
- `deferral_restricted_lindenbaum`: Extends consistent deferral-restricted set to DRM

## Key Properties

- `deferral_restricted_mcs_negation_complete`: Negation completeness for subformulaClosure
- `drm_closed_under_derivation`: Closure under derivation for deferralClosure formulas
- `drm_implication_property`: Modus ponens reflected in membership
- `theorem_in_drm`: Theorems in deferralClosure are in any DRM
- `drm_G_neg_implies_not_F`: G(neg phi) excludes F(phi)

-/

namespace Bimodal.Metalogic.Core

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Bundle

/-!
## Deferral-Restricted MCS

MCS restricted to deferralClosure(phi) instead of closureWithNeg(phi).
The deferralClosure includes the deferral disjunctions needed by the
successor seed construction while preserving the same F/P-depth bounds.
-/

/--
A set is deferral-restricted if all its elements are in deferralClosure phi.
-/
def DeferralRestricted (phi : Formula) (S : Set Formula) : Prop :=
  S ⊆ (deferralClosure phi : Set Formula)

/--
A deferral-restricted set that is also set-consistent.
-/
def DeferralRestrictedConsistent (phi : Formula) (S : Set Formula) : Prop :=
  DeferralRestricted phi S ∧ SetConsistent S

/--
Maximal consistent within the deferral closure: cannot be extended within
deferralClosure while remaining consistent.
-/
def DeferralRestrictedMCS (phi : Formula) (S : Set Formula) : Prop :=
  DeferralRestrictedConsistent phi S ∧
  ∀ psi ∈ deferralClosure phi, psi ∉ S → ¬SetConsistent (insert psi S)

/--
A deferral restricted MCS is deferral-restricted.
-/
theorem deferral_restricted_mcs_is_restricted {phi : Formula} {S : Set Formula}
    (h : DeferralRestrictedMCS phi S) : DeferralRestricted phi S :=
  h.1.1

/--
A deferral restricted MCS is set-consistent.
-/
theorem deferral_restricted_mcs_is_consistent {phi : Formula} {S : Set Formula}
    (h : DeferralRestrictedMCS phi S) : SetConsistent S :=
  h.1.2

/--
Chain union lemma: The union of a chain of deferral-restricted consistent sets
is deferral-restricted consistent.
-/
theorem deferral_restricted_consistent_chain_union {phi : Formula} {C : Set (Set Formula)}
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, DeferralRestrictedConsistent phi S) :
    DeferralRestrictedConsistent phi (⋃₀ C) := by
  constructor
  · intro psi h_mem
    obtain ⟨S, hS, hpsi⟩ := Set.mem_sUnion.mp h_mem
    exact (hcons S hS).1 hpsi
  · apply consistent_chain_union hchain hCne
    intro S hS
    exact (hcons S hS).2

/--
Deferral-Restricted Lindenbaum's Lemma: Every deferral-restricted consistent set can be
extended to a deferral-restricted maximal consistent set.
-/
theorem deferral_restricted_lindenbaum (phi : Formula) (S : Set Formula)
    (h_restricted : DeferralRestricted phi S) (h_cons : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ DeferralRestrictedMCS phi M := by
  -- Define the collection of deferral-restricted consistent supersets
  let RCS := {T | S ⊆ T ∧ DeferralRestrictedConsistent phi T}
  -- Show RCS satisfies the chain condition for Zorn's lemma
  have hchain : ∀ C ⊆ RCS, IsChain (· ⊆ ·) C → C.Nonempty →
      ∃ ub ∈ RCS, ∀ T ∈ C, T ⊆ ub := by
    intro C hCsub hCchain hCne
    use ⋃₀ C
    constructor
    · constructor
      · obtain ⟨T, hT⟩ := hCne
        exact Set.Subset.trans (hCsub hT).1 (Set.subset_sUnion_of_mem hT)
      · apply deferral_restricted_consistent_chain_union hCchain hCne
        intro T hT
        exact (hCsub hT).2
    · intro T hT
      exact Set.subset_sUnion_of_mem hT
  have h_S_rc : DeferralRestrictedConsistent phi S := ⟨h_restricted, h_cons⟩
  have hSmem : S ∈ RCS := ⟨Set.Subset.refl S, h_S_rc⟩
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty RCS hchain S hSmem
  have hMmem := hmax.prop
  obtain ⟨_, hMrc⟩ := hMmem
  use M
  constructor
  · exact hSM
  · constructor
    · exact hMrc
    · intro psi h_psi_clos h_psi_not_M hcons_insert
      have h_insert_restricted : DeferralRestricted phi (insert psi M) := by
        intro chi h_mem
        cases Set.mem_insert_iff.mp h_mem with
        | inl h_eq => exact h_eq ▸ h_psi_clos
        | inr h_in_M => exact hMrc.1 h_in_M
      have h_insert_mem : insert psi M ∈ RCS := by
        constructor
        · exact Set.Subset.trans hSM (Set.subset_insert psi M)
        · exact ⟨h_insert_restricted, hcons_insert⟩
      have h_le : M ⊆ insert psi M := Set.subset_insert psi M
      have h_subset : insert psi M ⊆ M := hmax.le_of_ge h_insert_mem h_le
      exact h_psi_not_M (h_subset (Set.mem_insert psi M))

/-!
## Negation Completeness for DeferralRestrictedMCS

For formulas in the subformula closure (which is within deferralClosure),
deferral-restricted MCS has negation completeness.
-/

/--
For psi in subformulaClosure phi, either psi or psi.neg is in any DeferralRestrictedMCS.

This is the key property that allows us to treat DeferralRestrictedMCS as
"morally" an MCS within the closure. For formulas in the original subformula
closure, we still get the full MCS behavior.
-/
theorem deferral_restricted_mcs_negation_complete {phi : Formula} {S : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi S) (psi : Formula)
    (h_psi_clos : psi ∈ subformulaClosure phi) :
    psi ∈ S ∨ psi.neg ∈ S := by
  by_cases h : psi ∈ S
  · left; exact h
  · right
    -- Both psi and psi.neg are in deferralClosure
    have h_psi_dc : psi ∈ deferralClosure phi :=
      closureWithNeg_subset_deferralClosure phi
        (subformulaClosure_subset_closureWithNeg phi h_psi_clos)
    have h_neg_dc : psi.neg ∈ deferralClosure phi :=
      closureWithNeg_subset_deferralClosure phi
        (neg_mem_closureWithNeg phi psi h_psi_clos)
    -- By maximality: since psi ∉ S and psi ∈ deferralClosure, insert psi S is inconsistent
    have h_incons := h_mcs.2 psi h_psi_dc h
    by_contra h_neg_not
    -- Same proof structure as restricted_mcs_negation_complete
    unfold SetConsistent at h_incons
    push_neg at h_incons
    obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons
    have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
    obtain ⟨d_bot⟩ := h_bot
    let Γ := L.filter (· ≠ psi)
    have h_Γ_in_S : ∀ χ ∈ Γ, χ ∈ S := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχne : χ ≠ psi := by simpa using hχ'.2
      specialize h_L_sub χ hχ'.1
      simp [Set.mem_insert_iff] at h_L_sub
      rcases h_L_sub with rfl | h_in_S
      · exact absurd rfl hχne
      · exact h_in_S
    have h_L_sub_psiGamma : L ⊆ psi :: Γ := by
      intro χ hχ
      by_cases hχpsi : χ = psi
      · simp [hχpsi]
      · simp only [List.mem_cons]
        right
        exact List.mem_filter.mpr ⟨hχ, by simpa⟩
    have d_bot' : DerivationTree (psi :: Γ) Formula.bot :=
      DerivationTree.weakening L (psi :: Γ) Formula.bot d_bot h_L_sub_psiGamma
    have d_neg : DerivationTree Γ psi.neg := deduction_theorem Γ psi Formula.bot d_bot'
    have h_incons_neg := h_mcs.2 psi.neg h_neg_dc h_neg_not
    unfold SetConsistent at h_incons_neg
    push_neg at h_incons_neg
    obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons_neg
    have h_bot'' : Nonempty (DerivationTree L' Formula.bot) := inconsistent_derives_bot h_L'_incons
    obtain ⟨d_bot''⟩ := h_bot''
    let Δ := L'.filter (· ≠ psi.neg)
    have h_Δ_in_S : ∀ χ ∈ Δ, χ ∈ S := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχne : χ ≠ psi.neg := by simpa using hχ'.2
      specialize h_L'_sub χ hχ'.1
      simp [Set.mem_insert_iff] at h_L'_sub
      rcases h_L'_sub with rfl | h_in_S
      · exact absurd rfl hχne
      · exact h_in_S
    have h_L'_sub_psiΔ : L' ⊆ psi.neg :: Δ := by
      intro χ hχ
      by_cases hχpsi : χ = psi.neg
      · simp [hχpsi]
      · simp only [List.mem_cons]
        right
        exact List.mem_filter.mpr ⟨hχ, by simpa⟩
    have d_bot''' : DerivationTree (psi.neg :: Δ) Formula.bot :=
      DerivationTree.weakening L' (psi.neg :: Δ) Formula.bot d_bot'' h_L'_sub_psiΔ
    have d_neg_neg : DerivationTree Δ psi.neg.neg :=
      deduction_theorem Δ psi.neg Formula.bot d_bot'''
    let ΓΔ := Γ ++ Δ
    have h_ΓΔ_in_S : ∀ χ ∈ ΓΔ, χ ∈ S := by
      intro χ hχ
      simp only [ΓΔ, List.mem_append] at hχ
      rcases hχ with hχΓ | hχΔ
      · exact h_Γ_in_S χ hχΓ
      · exact h_Δ_in_S χ hχΔ
    have d_neg' : DerivationTree ΓΔ psi.neg :=
      DerivationTree.weakening Γ ΓΔ _ d_neg (List.subset_append_left Γ Δ)
    have d_neg_neg' : DerivationTree ΓΔ psi.neg.neg :=
      DerivationTree.weakening Δ ΓΔ _ d_neg_neg (List.subset_append_right Γ Δ)
    have d_bot_final : DerivationTree ΓΔ Formula.bot :=
      derives_bot_from_phi_neg_phi d_neg' d_neg_neg'
    exact h_mcs.1.2 ΓΔ h_ΓΔ_in_S ⟨d_bot_final⟩

/--
Double negation elimination for DeferralRestrictedMCS: if neg(neg psi) is in M
and psi is in deferralClosure phi, then psi is in M.

This follows from maximality within deferralClosure: if psi were not in M,
then inserting psi would be inconsistent. But neg(neg psi) derives psi,
leading to a contradiction with consistency of M.
-/
theorem deferral_restricted_mcs_double_neg_elim {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) (psi : Formula)
    (h_neg_neg : Formula.neg (Formula.neg psi) ∈ M)
    (h_psi_clos : psi ∈ deferralClosure phi) :
    psi ∈ M := by
  by_contra h_not_in
  -- By maximality, insert psi M is inconsistent
  have h_incons := h_mcs.2 psi h_psi_clos h_not_in
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons
  -- L derives bot
  have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
  obtain ⟨d_bot⟩ := h_bot
  -- Extract Gamma = L \ {psi}, so Gamma ⊆ M
  let Γ := L.filter (· ≠ psi)
  have h_Γ_in_M : ∀ χ ∈ Γ, χ ∈ M := by
    intro χ hχ
    have hχ' := List.mem_filter.mp hχ
    have hχne : χ ≠ psi := by simpa using hχ'.2
    specialize h_L_sub χ hχ'.1
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in_M
    · exact absurd rfl hχne
    · exact h_in_M
  -- L ⊆ psi :: Gamma
  have h_L_sub_psiGamma : L ⊆ psi :: Γ := by
    intro χ hχ
    by_cases hχpsi : χ = psi
    · simp [hχpsi]
    · simp only [List.mem_cons]
      right
      exact List.mem_filter.mpr ⟨hχ, by simpa⟩
  -- Weaken: (psi :: Gamma) derives bot
  have d_bot' : DerivationTree (psi :: Γ) Formula.bot :=
    DerivationTree.weakening L (psi :: Γ) Formula.bot d_bot h_L_sub_psiGamma
  -- By deduction: Gamma derives neg psi
  have d_neg_psi : DerivationTree Γ (Formula.neg psi) :=
    deduction_theorem Γ psi Formula.bot d_bot'
  -- We have neg(neg psi) in M, so from DNE: {neg(neg psi)} derives psi
  have d_dne : [] ⊢ (Formula.neg (Formula.neg psi)).imp psi :=
    Bimodal.Theorems.Propositional.double_negation psi
  have d_dne_ctx : [Formula.neg (Formula.neg psi)] ⊢ (Formula.neg (Formula.neg psi)).imp psi :=
    DerivationTree.weakening [] [Formula.neg (Formula.neg psi)] _ d_dne (List.nil_subset _)
  have d_assumption : [Formula.neg (Formula.neg psi)] ⊢ Formula.neg (Formula.neg psi) :=
    DerivationTree.assumption [Formula.neg (Formula.neg psi)] (Formula.neg (Formula.neg psi))
      (List.mem_singleton.mpr rfl)
  have d_psi_from_neg_neg : DerivationTree [Formula.neg (Formula.neg psi)] psi :=
    DerivationTree.modus_ponens _ _ _ d_dne_ctx d_assumption
  -- Combine: (neg(neg psi) :: Gamma) derives psi and neg psi, hence bot
  let Δ := (Formula.neg (Formula.neg psi)) :: Γ
  have h_Δ_in_M : ∀ χ ∈ Δ, χ ∈ M := by
    intro χ hχ
    simp only [Δ, List.mem_cons] at hχ
    rcases hχ with rfl | hχΓ
    · exact h_neg_neg
    · exact h_Γ_in_M χ hχΓ
  have h_subset1 : [Formula.neg (Formula.neg psi)] ⊆ Δ := by
    intro x hx
    simp only [List.mem_singleton] at hx
    subst hx
    exact @List.mem_cons_self _ (Formula.neg (Formula.neg psi)) Γ
  have d_psi' : DerivationTree Δ psi :=
    DerivationTree.weakening [Formula.neg (Formula.neg psi)] Δ psi d_psi_from_neg_neg h_subset1
  have d_neg_psi' : DerivationTree Δ (Formula.neg psi) :=
    DerivationTree.weakening Γ Δ _ d_neg_psi (List.subset_cons_of_subset _ (List.Subset.refl _))
  have d_bot_final : DerivationTree Δ Formula.bot :=
    derives_bot_from_phi_neg_phi d_psi' d_neg_psi'
  -- Contradiction: Δ ⊆ M but Δ derives bot, contradicting consistency
  exact h_mcs.1.2 Δ h_Δ_in_M ⟨d_bot_final⟩


/--
P-step blocking formulas (restricted) are subset of u for DeferralRestrictedMCS.

This is the corrected version of `p_step_blocking_for_deferral_restricted` that uses
the restricted definition `p_step_blocking_formulas_restricted`, which only considers
formulas where `P(psi)` is in `deferralClosure`.

This is exactly the "Case 1" proof from the original attempt - the case where
`P(psi) ∈ deferralClosure`. The "Case 2" where `P(psi) ∉ deferralClosure`
is now excluded by the definition of `p_step_blocking_formulas_restricted`.

See research report 06_team-research.md for the counterexample showing why
the unrestricted version fails.
-/
theorem p_step_blocking_restricted_subset (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) :
    Bimodal.Metalogic.Bundle.p_step_blocking_formulas_restricted phi u ⊆ u := by
  intro chi h_block
  rw [Bimodal.Metalogic.Bundle.mem_p_step_blocking_formulas_restricted_iff] at h_block
  obtain ⟨psi, h_P_in_dc, h_P_not_in, _, rfl⟩ := h_block
  -- Goal: H(neg psi) = Formula.all_past (Formula.neg psi) ∈ u
  -- Use the cases theorem to handle both closureWithNeg and P_top cases
  -- Get H(neg psi) in deferralClosure
  have h_H_in_dc : Formula.all_past (Formula.neg psi) ∈ deferralClosure phi := by
    rcases some_past_in_deferralClosure_cases phi psi h_P_in_dc with h_P_in_cwn | h_P_eq_P_top
    · -- P(psi) ∈ closureWithNeg phi: use temporal blocking set
      exact all_past_neg_mem_deferralClosure_of_some_past h_P_in_cwn
    · -- P(psi) = P_top, so psi = top = bot.imp bot, H(¬psi) = H_neg_neg_bot
      simp only [P_top, Formula.some_past, Formula.top] at h_P_eq_P_top
      have h_psi_eq : psi = Formula.bot.imp Formula.bot := Formula.snce.inj h_P_eq_P_top |>.1
      subst h_psi_eq
      simp only [Formula.neg]
      exact H_neg_neg_bot_mem_deferralClosure phi
  -- Now use maximality: P(psi) not in u, P(psi) in deferralClosure => insert inconsistent
  have h_insert_incons := h_mcs.2 (Formula.some_past psi) h_P_in_dc h_P_not_in
  -- Extract: from inconsistency, Γ ⊆ u derives neg(P(psi))
  unfold SetConsistent at h_insert_incons
  push_neg at h_insert_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_insert_incons
  obtain ⟨d_bot⟩ := inconsistent_derives_bot h_L_incons
  let Γ := L.filter (· ≠ Formula.some_past psi)
  have h_Γ_in_u : ∀ χ ∈ Γ, χ ∈ u := by
    intro χ hχ
    have hχ' := List.mem_filter.mp hχ
    have hχne : χ ≠ Formula.some_past psi := by simpa using hχ'.2
    specialize h_L_sub χ hχ'.1
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in
    · exact absurd rfl hχne
    · exact h_in
  have h_L_sub' : L ⊆ Formula.some_past psi :: Γ := by
    intro χ hχ
    by_cases hχp : χ = Formula.some_past psi
    · simp [hχp]
    · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχp⟩)
  have d_bot' := DerivationTree.weakening L _ Formula.bot d_bot h_L_sub'
  have d_neg_P : Γ ⊢ Formula.neg (Formula.some_past psi) :=
    deduction_theorem Γ (Formula.some_past psi) Formula.bot d_bot'
  -- neg(P(psi)) = neg(neg(H(neg psi))) derivable from Γ ⊆ u
  -- We need: H(neg psi) in u, given that Γ ⊢ neg(neg(H(neg psi))) and H(neg psi) in deferralClosure
  by_contra h_H_not_in
  -- H(neg psi) not in u, but in deferralClosure => insert inconsistent
  have h_H_insert_incons := h_mcs.2 _ h_H_in_dc h_H_not_in
  unfold SetConsistent at h_H_insert_incons
  push_neg at h_H_insert_incons
  obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_H_insert_incons
  obtain ⟨d_bot''⟩ := inconsistent_derives_bot h_L'_incons
  let Δ := L'.filter (· ≠ Formula.all_past (Formula.neg psi))
  have h_Δ_in_u : ∀ χ ∈ Δ, χ ∈ u := by
    intro χ hχ
    have hχ' := List.mem_filter.mp hχ
    have hχne : χ ≠ Formula.all_past (Formula.neg psi) := by simpa using hχ'.2
    specialize h_L'_sub χ hχ'.1
    simp [Set.mem_insert_iff] at h_L'_sub
    rcases h_L'_sub with rfl | h_in
    · exact absurd rfl hχne
    · exact h_in
  have h_L'_sub' : L' ⊆ Formula.all_past (Formula.neg psi) :: Δ := by
    intro χ hχ
    by_cases hχH : χ = Formula.all_past (Formula.neg psi)
    · simp [hχH]
    · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχH⟩)
  have d_bot''' := DerivationTree.weakening L' _ Formula.bot d_bot'' h_L'_sub'
  have d_neg_H : Δ ⊢ Formula.neg (Formula.all_past (Formula.neg psi)) :=
    deduction_theorem Δ _ Formula.bot d_bot'''
  -- Derive H(¬psi) from ¬P(psi): via contrapositive of ⊢ P(¬¬psi) → P(psi)
  -- ¬P(¬¬psi) = neg (snce (neg (neg psi)) top) = all_past (neg psi) = H(¬psi) definitionally
  have h_dne : [] ⊢ psi.neg.neg.imp psi := Bimodal.Theorems.Propositional.double_negation psi
  have h_H_dne : [] ⊢ (psi.neg.neg.imp psi).all_past :=
    Bimodal.Theorems.past_necessitation _ h_dne
  have h_bx3' : [] ⊢ (psi.neg.neg.imp psi).all_past.imp
      ((Formula.snce psi.neg.neg Formula.top).imp (Formula.snce psi Formula.top)) :=
    DerivationTree.axiom [] _ (Axiom.right_mono_since psi.neg.neg psi Formula.top)
  have h_P_mono : [] ⊢ (Formula.some_past psi.neg.neg).imp (Formula.some_past psi) :=
    DerivationTree.modus_ponens [] _ _ h_bx3' h_H_dne
  have h_contra : [] ⊢ (Formula.some_past psi).neg.imp (Formula.some_past psi.neg.neg).neg :=
    Bimodal.Theorems.Propositional.contraposition h_P_mono
  -- Γ ⊢ ¬P(psi), so Γ ⊢ ¬P(¬¬psi) = H(¬psi)
  have d_H : Γ ⊢ Formula.all_past (Formula.neg psi) :=
    DerivationTree.modus_ponens Γ _ _ (DerivationTree.weakening [] Γ _ h_contra (by intro; simp)) d_neg_P
  -- Combine Γ ⊢ H(¬psi) with Δ ⊢ ¬H(¬psi) for contradiction
  let ΓΔ := Γ ++ Δ
  have h_ΓΔ_in_u : ∀ χ ∈ ΓΔ, χ ∈ u := by
    intro χ hχ
    simp only [ΓΔ, List.mem_append] at hχ
    rcases hχ with hχΓ | hχΔ
    · exact h_Γ_in_u χ hχΓ
    · exact h_Δ_in_u χ hχΔ
  have d_H' : ΓΔ ⊢ Formula.all_past (Formula.neg psi) :=
    DerivationTree.weakening Γ ΓΔ _ d_H (List.subset_append_left Γ Δ)
  have d_neg_H' : ΓΔ ⊢ Formula.neg (Formula.all_past (Formula.neg psi)) :=
    DerivationTree.weakening Δ ΓΔ _ d_neg_H (List.subset_append_right Γ Δ)
  have d_bot_final := derives_bot_from_phi_neg_phi d_H' d_neg_H'
  exact h_mcs.1.2 ΓΔ h_ΓΔ_in_u ⟨d_bot_final⟩

/-!
## iter_F/P Boundedness in DeferralRestrictedMCS

These reuse the same bounds as for RestrictedMCS, since deferralClosure
has the same max F/P-depth as closureWithNeg (proven in SubformulaClosure.lean).
-/

/--
iter_F n phi is not in deferralClosure(phi) for large enough n.

Uses the fact that deferralClosure has the same max F-depth as closureWithNeg.
-/
theorem iter_F_not_mem_deferralClosure (phi : Formula) (n : Nat) (h : n ≥ closure_F_bound phi) :
    iter_F n phi ∉ (deferralClosure phi : Set Formula) := by
  intro h_mem
  have h_depth_bound : f_nesting_depth (iter_F n phi) ≤
      (deferralClosure phi).sup f_nesting_depth :=
    Finset.le_sup h_mem
  rw [max_F_depth_deferralClosure_eq] at h_depth_bound
  have h_exceeds := iter_F_exceeds_max_depth phi n h
  -- h_depth_bound: depth <= max(max_F_depth_in_closure phi, 1)
  -- h_exceeds: depth > max_F_depth_in_closure phi
  -- Need to show False.
  -- If depth > max_F_depth_in_closure phi and depth <= max(max_F_depth_in_closure phi, 1),
  -- then depth <= 1 and depth > max_F_depth_in_closure phi.
  -- This means max_F_depth_in_closure phi < 1, so max_F_depth_in_closure phi = 0.
  -- And depth = 1 (since depth > 0 and depth <= 1).
  -- But iter_F n phi has depth = f_nesting_depth phi + n.
  -- Since n >= closure_F_bound phi = max_F_depth_in_closure phi + 1 = 0 + 1 = 1,
  -- we have depth >= f_nesting_depth phi + 1 >= 0 + 1 = 1.
  -- Actually, if n >= 1 and f_nesting_depth phi >= 0, then
  -- iter_F n phi has f_nesting_depth phi + n >= 1.
  -- If max_F_depth_in_closure phi = 0, then depth(iter_F 1 phi) = depth(F phi) = 1 + depth(phi.neg.all_future).
  -- Actually iter_F_f_nesting_depth says depth(iter_F n phi) = f_nesting_depth phi + n.
  -- Wait, f_nesting_depth phi could be 0 if phi is not an F-formula.
  -- In that case, iter_F 1 phi = F(phi), which has f_nesting_depth 1.
  -- And max(max_F_depth_in_closure phi, 1) = max(0, 1) = 1.
  -- So h_depth_bound says 1 <= 1, which is true.
  -- And h_exceeds says 1 > 0, which is also true.
  -- These don't contradict! We need n >= 2.
  -- The fix is to use a stronger bound. For now, use specific case analysis.
  have h_iter_depth : f_nesting_depth (iter_F n phi) = n + f_nesting_depth phi :=
    iter_F_f_nesting_depth n phi
  rw [h_iter_depth] at h_depth_bound h_exceeds
  -- h_depth_bound: f_nesting_depth phi + n <= max(max_F_depth_in_closure phi, 1)
  -- h_exceeds: f_nesting_depth phi + n > max_F_depth_in_closure phi
  -- Since n >= closure_F_bound phi = max_F_depth_in_closure phi + 1,
  -- f_nesting_depth phi + n >= f_nesting_depth phi + max_F_depth_in_closure phi + 1
  -- >= 0 + max_F_depth_in_closure phi + 1 = max_F_depth_in_closure phi + 1
  -- >= max(max_F_depth_in_closure phi, 1) + 1 (if max_F_depth >= 0)
  -- Actually no, if max = 0 then max(0,1) = 1, and we need > 1 but only have >= 1.
  -- The actual fix needs closure_F_bound to be at least 2.
  -- For now, add +1 to both sides in the omega.
  unfold closure_F_bound at h
  omega

/--
In any DeferralRestrictedMCS M over phi, there exists n such that iter_F n phi is not in M.
-/
theorem deferral_restricted_mcs_iter_F_bound (phi : Formula) (M : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi M) :
    ∃ n : Nat, iter_F n phi ∉ M := by
  use closure_F_bound phi
  intro h_mem
  exact iter_F_not_mem_deferralClosure phi (closure_F_bound phi) (Nat.le_refl _)
    (deferral_restricted_mcs_is_restricted h_mcs h_mem)

/--
If F(phi) is in a DeferralRestrictedMCS M, then there exists d >= 1 such that:
- iter_F d phi is in M (the last F-iteration that's still in M)
- iter_F (d + 1) phi is not in M (the first F-iteration that left M)
-/
theorem deferral_restricted_mcs_F_bounded (phi psi : Formula) (M : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi M)
    (h_F_in : Formula.some_future psi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d psi ∈ M ∧ iter_F (d + 1) psi ∉ M := by
  -- iter_F 1 psi = F(psi) ∈ M
  have h_one_in : iter_F 1 psi ∈ M := by
    simp only [iter_F_one_eq_some_future]
    exact h_F_in
  -- iter_F at the bound is not in M (since M ⊆ deferralClosure)
  -- But we need the bound for psi, not phi. Since F(psi) ∈ M ⊆ deferralClosure phi,
  -- iter_F n psi has f_nesting_depth = n + f_nesting_depth(psi).
  -- For psi: we need n such that iter_F n psi ∉ M.
  -- Since M ⊆ deferralClosure phi, it suffices that iter_F n psi ∉ deferralClosure phi.
  -- f_nesting_depth(iter_F n psi) = n + f_nesting_depth(psi)
  -- This exceeds max_F_depth_in_closure phi when n > max_F_depth_in_closure phi - f_nesting_depth(psi)
  -- So closure_F_bound phi = max_F_depth_in_closure phi + 1 works.
  let exit_bound := closure_F_bound phi
  have h_exit_bound_not : iter_F exit_bound psi ∉ M := by
    intro h_mem
    have h_in_dc := deferral_restricted_mcs_is_restricted h_mcs h_mem
    have h_depth_bound : f_nesting_depth (iter_F exit_bound psi) ≤
        (deferralClosure phi).sup f_nesting_depth :=
      Finset.le_sup h_in_dc
    rw [max_F_depth_deferralClosure_eq] at h_depth_bound
    rw [iter_F_f_nesting_depth] at h_depth_bound
    unfold exit_bound closure_F_bound at h_depth_bound
    omega
  have h_exit_ge1 : exit_bound ≥ 1 := by
    unfold exit_bound closure_F_bound
    omega
  have h_exit_ge2 : exit_bound ≥ 2 := by
    by_contra h
    push_neg at h
    have h_eq : exit_bound = 1 := by omega
    rw [h_eq] at h_exit_bound_not
    exact h_exit_bound_not h_one_in
  let S : Set Nat := { n | n ≥ 2 ∧ iter_F n psi ∉ M }
  have h_S_nonempty : S.Nonempty := ⟨exit_bound, h_exit_ge2, h_exit_bound_not⟩
  have h_wf : WellFounded (· < · : Nat → Nat → Prop) := Nat.lt_wfRel.wf
  obtain ⟨min_n, h_min_mem, h_min_least⟩ := WellFounded.has_min h_wf S h_S_nonempty
  obtain ⟨h_min_ge2, h_min_not⟩ := h_min_mem
  use min_n - 1
  constructor
  · omega
  constructor
  · by_contra h_not_in
    have h_pred_lt : min_n - 1 < min_n := by omega
    by_cases h_pred_ge2 : min_n - 1 ≥ 2
    · exact h_min_least (min_n - 1) ⟨h_pred_ge2, h_not_in⟩ h_pred_lt
    · have h_pred_eq1 : min_n - 1 = 1 := by omega
      rw [h_pred_eq1] at h_not_in
      exact h_not_in h_one_in
  · have h_eq : min_n - 1 + 1 = min_n := by omega
    rw [h_eq]
    exact h_min_not

/--
iter_P n phi is not in deferralClosure(phi) for large enough n.

Uses the fact that deferralClosure has the same max P-depth as closureWithNeg.
-/
theorem iter_P_not_mem_deferralClosure (phi : Formula) (n : Nat) (h : n ≥ closure_P_bound phi) :
    iter_P n phi ∉ (deferralClosure phi : Set Formula) := by
  intro h_mem
  have h_depth_bound : p_nesting_depth (iter_P n phi) ≤
      (deferralClosure phi).sup p_nesting_depth :=
    Finset.le_sup h_mem
  rw [max_P_depth_deferralClosure_eq] at h_depth_bound
  have h_exceeds := iter_P_exceeds_max_depth phi n h
  omega

/--
If P(phi) is in a DeferralRestrictedMCS M, then there exists d >= 1 such that:
- iter_P d phi is in M (the last P-iteration that's still in M)
- iter_P (d + 1) phi is not in M (the first P-iteration that left M)

Symmetric to deferral_restricted_mcs_F_bounded.
-/
theorem deferral_restricted_mcs_P_bounded (phi psi : Formula) (M : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi M)
    (h_P_in : Formula.some_past psi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_P d psi ∈ M ∧ iter_P (d + 1) psi ∉ M := by
  have h_one_in : iter_P 1 psi ∈ M := by
    simp only [iter_P_one_eq_some_past]
    exact h_P_in
  let exit_bound := closure_P_bound phi
  have h_exit_bound_not : iter_P exit_bound psi ∉ M := by
    intro h_mem
    have h_in_dc := deferral_restricted_mcs_is_restricted h_mcs h_mem
    have h_depth_bound : p_nesting_depth (iter_P exit_bound psi) ≤
        (deferralClosure phi).sup p_nesting_depth :=
      Finset.le_sup h_in_dc
    rw [max_P_depth_deferralClosure_eq] at h_depth_bound
    rw [iter_P_p_nesting_depth] at h_depth_bound
    unfold exit_bound closure_P_bound at h_depth_bound
    omega
  have h_exit_ge1 : exit_bound ≥ 1 := by
    unfold exit_bound closure_P_bound
    omega
  have h_exit_ge2 : exit_bound ≥ 2 := by
    by_contra h
    push_neg at h
    have h_eq : exit_bound = 1 := by omega
    rw [h_eq] at h_exit_bound_not
    exact h_exit_bound_not h_one_in
  let S : Set Nat := { n | n ≥ 2 ∧ iter_P n psi ∉ M }
  have h_S_nonempty : S.Nonempty := ⟨exit_bound, h_exit_ge2, h_exit_bound_not⟩
  have h_wf : WellFounded (· < · : Nat → Nat → Prop) := Nat.lt_wfRel.wf
  obtain ⟨min_n, h_min_mem, h_min_least⟩ := WellFounded.has_min h_wf S h_S_nonempty
  obtain ⟨h_min_ge2, h_min_not⟩ := h_min_mem
  use min_n - 1
  constructor
  · omega
  constructor
  · by_contra h_not_in
    have h_pred_lt : min_n - 1 < min_n := by omega
    by_cases h_pred_ge2 : min_n - 1 ≥ 2
    · exact h_min_least (min_n - 1) ⟨h_pred_ge2, h_not_in⟩ h_pred_lt
    · have h_pred_eq1 : min_n - 1 = 1 := by omega
      rw [h_pred_eq1] at h_not_in
      exact h_not_in h_one_in
  · have h_eq : min_n - 1 + 1 = min_n := by omega
    rw [h_eq]
    exact h_min_not

/-!
## DeferralRestrictedMCS Closure Under Derivation

These lemmas establish that DeferralRestrictedMCS is closed under derivation
for formulas within deferralClosure. This enables proving modal duality lemmas
like `neg_FF_implies_GG_neg` for restricted MCS.
-/

/--
DeferralRestrictedMCS is closed under derivation for formulas in deferralClosure.

If L ⊆ M, L ⊢ φ, and φ ∈ deferralClosure, then φ ∈ M.

This is the DRM version of `SetMaximalConsistent.closed_under_derivation`.
The key insight is that DRM maximality within deferralClosure is sufficient:
if φ ∈ deferralClosure and φ ∉ M, then insert φ M is inconsistent,
which contradicts L ⊢ φ when L ⊆ M.
-/
theorem drm_closed_under_derivation {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {ψ : Formula}
    (L : List Formula) (h_sub : ∀ χ ∈ L, χ ∈ M)
    (h_deriv : DerivationTree L ψ)
    (h_ψ_dc : ψ ∈ deferralClosure phi) : ψ ∈ M := by
  by_contra h_not_mem
  -- By DRM maximality, insert ψ M is inconsistent
  have h_incons : ¬SetConsistent (insert ψ M) := h_mcs.2 ψ h_ψ_dc h_not_mem
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons
  -- L' ⊆ insert ψ M and L' is inconsistent
  by_cases h_psi_in_L' : ψ ∈ L'
  · -- ψ ∈ L'. Use exchange to put ψ first, then deduction theorem.
    have ⟨d_bot⟩ : Nonempty (DerivationTree L' Formula.bot) := by
      unfold Consistent at h_L'_incons
      push_neg at h_L'_incons
      exact h_L'_incons
    let L'_filt := L'.filter (fun y => decide (y ≠ ψ))
    have h_perm := cons_filter_neq_perm h_psi_in_L'
    have d_bot_reord : DerivationTree (ψ :: L'_filt) Formula.bot :=
      derivation_exchange d_bot (fun x => (h_perm x).symm)
    have d_neg_psi : DerivationTree L'_filt (Formula.neg ψ) :=
      deduction_theorem L'_filt ψ Formula.bot d_bot_reord
    -- L'_filt ⊆ M
    have h_filt_sub : ∀ χ ∈ L'_filt, χ ∈ M := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχne : χ ≠ ψ := by simpa using hχ'.2
      have := h_L'_sub χ hχ'.1
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq hχne
      | inr h_in_M => exact h_in_M
    -- Combine: L ∪ L'_filt derives ψ and ¬ψ, hence ⊥
    let LL' := L ++ L'_filt
    have h_LL'_sub : ∀ χ ∈ LL', χ ∈ M := by
      intro χ hχ
      simp only [LL', List.mem_append] at hχ
      cases hχ with
      | inl hL => exact h_sub χ hL
      | inr hL' => exact h_filt_sub χ hL'
    have d_psi' : DerivationTree LL' ψ :=
      DerivationTree.weakening L LL' ψ h_deriv (List.subset_append_left L L'_filt)
    have d_neg_psi' : DerivationTree LL' (Formula.neg ψ) :=
      DerivationTree.weakening L'_filt LL' _ d_neg_psi (List.subset_append_right L L'_filt)
    have d_bot_final : DerivationTree LL' Formula.bot :=
      derives_bot_from_phi_neg_phi d_psi' d_neg_psi'
    exact h_mcs.1.2 LL' h_LL'_sub ⟨d_bot_final⟩
  · -- ψ ∉ L', so L' ⊆ M
    have h_L'_in_M : ∀ χ ∈ L', χ ∈ M := by
      intro χ h_mem
      have := h_L'_sub χ h_mem
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq (fun h' => h_psi_in_L' (h' ▸ h_mem))
      | inr h_in_M => exact h_in_M
    -- L' ⊆ M and L' is inconsistent contradicts M consistent
    unfold Consistent at h_L'_incons
    push_neg at h_L'_incons
    exact h_mcs.1.2 L' h_L'_in_M h_L'_incons

/--
DeferralRestrictedMCS implication property: modus ponens is reflected in membership
when the conclusion is in deferralClosure.

If (φ → ψ) ∈ M and φ ∈ M and ψ ∈ deferralClosure, then ψ ∈ M.
-/
theorem drm_implication_property {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {ψ χ : Formula}
    (h_imp : (ψ.imp χ) ∈ M) (h_psi : ψ ∈ M)
    (h_χ_dc : χ ∈ deferralClosure phi) : χ ∈ M := by
  have h_sub : ∀ ξ ∈ [ψ, ψ.imp χ], ξ ∈ M := by
    intro ξ h_mem
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at h_mem
    cases h_mem with
    | inl h_eq => exact h_eq ▸ h_psi
    | inr h_eq => exact h_eq ▸ h_imp
  have h_deriv : DerivationTree [ψ, ψ.imp χ] χ := by
    have h_assume_psi : [ψ, ψ.imp χ] ⊢ ψ :=
      DerivationTree.assumption [ψ, ψ.imp χ] ψ (by simp)
    have h_assume_imp : [ψ, ψ.imp χ] ⊢ ψ.imp χ :=
      DerivationTree.assumption [ψ, ψ.imp χ] (ψ.imp χ) (by simp)
    exact DerivationTree.modus_ponens [ψ, ψ.imp χ] ψ χ h_assume_imp h_assume_psi
  exact drm_closed_under_derivation h_mcs [ψ, ψ.imp χ] h_sub h_deriv h_χ_dc

/--
Theorems that are in deferralClosure are in any DeferralRestrictedMCS.

This is the DRM version of `theorem_in_mcs`. If ⊢ ψ and ψ ∈ deferralClosure, then ψ ∈ M.
-/
theorem theorem_in_drm {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {ψ : Formula}
    (h_thm : [] ⊢ ψ)
    (h_ψ_dc : ψ ∈ deferralClosure phi) : ψ ∈ M := by
  have h_sub : ∀ χ ∈ ([] : List Formula), χ ∈ M := by
    intro χ h
    simp only [List.mem_nil_iff] at h
  exact drm_closed_under_derivation h_mcs [] h_sub h_thm h_ψ_dc

-- NOTE: neg_FF_implies_GG_neg_in_drm was removed (Task 167) because:
-- 1. It was dead code with no callers
-- 2. The MCS version (neg_FF_implies_GG_neg_in_mcs) is used on the critical path
-- 3. If a DRM version is needed in the future, the temporalBlockingSet provides
--    the necessary H(¬chi)/G(¬chi) formulas in deferralClosure

/--
G(neg phi) in DeferralRestrictedMCS implies F(phi) not in DeferralRestrictedMCS.

This is the DRM version of `G_neg_implies_not_F`. The proof only uses consistency,
which DRM satisfies.
-/
theorem drm_G_neg_implies_not_F {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) (psi : Formula)
    (h_G_neg : Formula.all_future psi.neg ∈ M) :
    Formula.some_future psi ∉ M := by
  intro h_F
  -- Derive ⊥ from {F(psi), G(¬psi)} ⊆ M:
  -- ⊢ F(psi) → F(¬¬psi) (from DNI + BX3)
  -- G(¬psi) = ¬F(¬¬psi) (definitional: all_future X = neg (some_future (neg X)))
  -- So {F(psi), G(¬psi)} ⊢ ⊥ via modus ponens
  have h_dni : [] ⊢ psi.imp psi.neg.neg := Bimodal.Theorems.Combinators.dni psi
  have h_G_dni : [] ⊢ (psi.imp psi.neg.neg).all_future :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_bx3 : [] ⊢ (psi.imp psi.neg.neg).all_future.imp
      ((Formula.untl psi Formula.top).imp (Formula.untl psi.neg.neg Formula.top)) :=
    DerivationTree.axiom [] _ (Axiom.right_mono_until psi psi.neg.neg Formula.top)
  have h_F_mono : [] ⊢ (Formula.some_future psi).imp (Formula.some_future psi.neg.neg) :=
    DerivationTree.modus_ponens [] _ _ h_bx3 h_G_dni
  -- Build: [F(psi), G(¬psi)] ⊢ ⊥
  let L := [Formula.some_future psi, Formula.all_future psi.neg]
  have h_L_sub : ∀ χ ∈ L, χ ∈ M := by
    intro χ hχ; simp only [L, List.mem_cons, List.mem_singleton, List.not_mem_nil, or_false] at hχ
    rcases hχ with rfl | rfl <;> assumption
  have d_F : L ⊢ Formula.some_future psi :=
    DerivationTree.assumption L _ (by simp [L])
  have d_F_mono_w : L ⊢ (Formula.some_future psi).imp (Formula.some_future psi.neg.neg) :=
    DerivationTree.weakening [] L _ h_F_mono (List.nil_subset _)
  have d_Fnn : L ⊢ Formula.some_future psi.neg.neg :=
    DerivationTree.modus_ponens L _ _ d_F_mono_w d_F
  -- G(¬psi) = neg (some_future psi.neg.neg) definitionally (via all_future = neg ∘ some_future ∘ neg)
  -- d_G : L ⊢ (some_future psi.neg.neg).imp bot (since all_future X = neg(some_future(neg X)))
  have d_G : L ⊢ Formula.all_future psi.neg :=
    DerivationTree.assumption L _ (by simp [L])
  -- modus_ponens: d_G : L ⊢ (some_future psi.neg.neg) → ⊥ and d_Fnn : L ⊢ some_future psi.neg.neg
  have d_bot : L ⊢ Formula.bot :=
    DerivationTree.modus_ponens L (Formula.some_future psi.neg.neg) Formula.bot d_G d_Fnn
  exact h_mcs.1.2 L h_L_sub ⟨d_bot⟩

end Bimodal.Metalogic.Core

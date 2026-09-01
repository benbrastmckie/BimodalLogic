import FormalSystem.Metalogic.Soundness

namespace Probe508

open FormalSystem
open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-- Uniform per-axiom validity at the axiom's own minimum frame class. -/
theorem axiom_validIn_min {φ : Formula} (ax : Axiom φ) : ValidIn ax.minFrameClass φ := by
  cases ax with
  | prop_k a0 a1 a2 => exact prop_k_valid a0 a1 a2
  | prop_s a0 a1 => exact prop_s_valid a0 a1
  | modal_t a0 => exact modal_t_valid a0
  | modal_4 a0 => exact modal_4_valid a0
  | modal_b a0 => exact modal_b_valid a0
  | modal_5_collapse a0 => exact modal_5_collapse_valid a0
  | ex_falso a0 => exact ex_falso_valid a0
  | peirce a0 a1 => exact peirce_valid a0 a1
  | modal_k_dist a0 a1 => exact modal_k_dist_valid a0 a1
  | serial_future => exact serial_future_axiom_valid
  | serial_past => exact serial_past_axiom_valid
  | left_mono_until_G a0 a1 a2 => exact left_mono_until_G_valid a0 a1 a2
  | left_mono_since_H a0 a1 a2 => exact left_mono_since_H_valid a0 a1 a2
  | right_mono_until a0 a1 a2 => exact right_mono_until_valid a0 a1 a2
  | right_mono_since a0 a1 a2 => exact right_mono_since_valid a0 a1 a2
  | connect_future a0 => exact connect_future_valid a0
  | connect_past a0 => exact connect_past_valid a0
  | enrichment_until a0 a1 a2 => exact enrichment_until_valid a0 a1 a2
  | enrichment_since a0 a1 a2 => exact enrichment_since_valid a0 a1 a2
  | self_accum_until a0 a1 => exact self_accum_until_valid a0 a1
  | self_accum_since a0 a1 => exact self_accum_since_valid a0 a1
  | absorb_until a0 a1 => exact absorb_until_valid a0 a1
  | absorb_since a0 a1 => exact absorb_since_valid a0 a1
  | linear_until a0 a1 a2 a3 => exact linear_until_valid a0 a1 a2 a3
  | linear_since a0 a1 a2 a3 => exact linear_since_valid a0 a1 a2 a3
  | until_F a0 a1 => exact until_F_valid a0 a1
  | since_P a0 a1 => exact since_P_valid a0 a1
  | temp_linearity a0 a1 => exact temp_linearity_valid a0 a1
  | temp_linearity_past a0 a1 => exact temp_linearity_past_valid a0 a1
  | F_until_equiv a0 => exact F_until_equiv_valid a0
  | P_since_equiv a0 => exact P_since_equiv_valid a0
  | modal_future a0 => exact modal_future_valid a0
  | discrete_symm_fwd => exact discrete_symm_fwd_valid
  | discrete_symm_bwd => exact discrete_symm_bwd_valid
  | discrete_propagate_fwd => exact discrete_propagate_fwd_valid
  | discrete_propagate_bwd => exact discrete_propagate_bwd_valid
  | discrete_box_necessity => exact discrete_box_necessity_valid
  | density a0 => exact density_valid a0
  | dense_indicator => exact dense_indicator_valid
  | prior_UZ a0 => exact prior_UZ_valid a0
  | prior_SZ a0 => exact prior_SZ_valid a0
  | z1 a0 => exact z1_valid a0
  | prior_U_gap a0 => exact prior_U_gap_valid a0
  | prior_S_gap a0 => exact prior_S_gap_valid a0
  | sep a0 => exact sep_valid a0

/-- Uniform per-axiom swap-validity at the axiom's own minimum frame class. -/
theorem axiom_swap_validIn_min {φ : Formula} (ax : Axiom φ) :
    ValidIn ax.minFrameClass φ.swapTemporal := by
  by_cases hbase : ax.minFrameClass ≤ FrameClass.Base
  · have heq : ax.minFrameClass = FrameClass.Base :=
      le_antisymm hbase (FrameClass.base_le _)
    rw [heq]
    exact ValidIn.of_forall_total fun F _ M τ hτ t =>
      SoundnessLemmas.axiom_swap_valid_general (D := F.Duration) φ ax hbase F.toFibre M τ hτ t
  · cases ax with
    | density a0 =>
      exact ValidDense.of_forall fun F _ M τ hτ t =>
        SoundnessLemmas.axiom_swap_valid (D := F.Duration) _ (Axiom.density a0) trivial
          F.toFibre M τ hτ t
    | dense_indicator =>
      exact ValidDense.of_forall fun F _ M τ hτ t =>
        SoundnessLemmas.axiom_swap_valid (D := F.Duration) _ Axiom.dense_indicator trivial
          F.toFibre M τ hτ t
    | prior_UZ a0 =>
      exact ValidDiscrete.of_forall fun F _ _ _ _ M τ hτ t =>
        SoundnessLemmas.prior_SZ_is_valid (D := F.Duration) a0.swapTemporal F.toFibre M τ hτ t
    | prior_SZ a0 =>
      exact ValidDiscrete.of_forall fun F _ _ _ _ M τ hτ t =>
        SoundnessLemmas.prior_UZ_is_valid (D := F.Duration) a0.swapTemporal F.toFibre M τ hτ t
    | z1 a0 =>
      exact ValidDiscrete.of_forall fun F _ _ _ _ M τ hτ t =>
        SoundnessLemmas.z1_past_is_valid (D := F.Duration) a0.swapTemporal F.toFibre M τ hτ t
    | prior_U_gap a0 => exact prior_S_gap_valid a0.swapTemporal
    | prior_S_gap a0 => exact prior_U_gap_valid a0.swapTemporal
    | sep a0 => exact sep_swap_valid a0
    | _ => exact absurd trivial hbase

theorem axiom_validIn {φ : Formula} {fc : FrameClass} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ fc) : ValidIn fc φ :=
  ValidIn.mono h_fc (axiom_validIn_min ax)

theorem axiom_swap_validIn {φ : Formula} {fc : FrameClass} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ fc) : ValidIn fc φ.swapTemporal :=
  ValidIn.mono h_fc (axiom_swap_validIn_min ax)

/-- The uniform combined valid/swap-valid recursion at an arbitrary `fc`. -/
theorem derivable_valid_and_swap_validIn {fc : FrameClass} {φ : Formula}
    (d : DerivationTree fc [] φ) : ValidIn fc φ ∧ ValidIn fc φ.swapTemporal := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨axiom_validIn h_ax h_fc, axiom_swap_validIn h_ax h_fc⟩
  | .assumption _ _ h_mem =>
    exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := derivable_valid_and_swap_validIn d1
    have h2 := derivable_valid_and_swap_validIn d2
    constructor
    · refine ValidIn.of_forall_total ?_
      intro F hF M tau h_mem t
      have h1' := h1.1.apply_total F hF M tau h_mem t
      have h2' := h2.1.apply_total F hF M tau h_mem t
      simp only [TruthAt] at h1'
      exact h1' h2'
    · refine ValidIn.of_forall_total ?_
      intro F hF M tau h_mem t
      have h1' := h1.2.apply_total F hF M tau h_mem t
      have h2' := h2.2.apply_total F hF M tau h_mem t
      simp only [Formula.swapTemporal, TruthAt] at h1' ⊢
      exact h1' h2'
  | .necessitation psi' d' =>
    have h := derivable_valid_and_swap_validIn d'
    constructor
    · refine ValidIn.of_forall_total ?_
      intro F hF M tau h_mem t
      simp only [TruthAt]
      intro sigma h_sigma_mem
      exact h.1.apply_total F hF M sigma h_sigma_mem t
    · refine ValidIn.of_forall_total ?_
      intro F hF M tau h_mem t
      simp only [Formula.swapTemporal, TruthAt]
      intro sigma h_sigma_mem
      exact h.2.apply_total F hF M sigma h_sigma_mem t
  | .temporal_necessitation psi' d' =>
    have h := derivable_valid_and_swap_validIn d'
    constructor
    · refine ValidIn.of_forall_total ?_
      intro F hF M tau h_mem t
      simp only [Truth.future_iff]
      intro s _hts
      exact h.1.apply_total F hF M tau h_mem s
    · refine ValidIn.of_forall_total ?_
      intro F hF M tau h_mem t
      simp only [Formula.allFuture, Formula.someFuture, Formula.swapTemporal,
        Formula.neg, Formula.top] at *
      simp only [TruthAt] at *
      intro hcontra
      obtain ⟨s, hts, hs, _⟩ := hcontra
      exact hs (h.2.apply_total F hF M tau h_mem s)
  | .temporal_duality psi' d' =>
    have h := derivable_valid_and_swap_validIn d'
    refine ⟨h.2, ?_⟩
    rw [Formula.swap_temporal_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_eq : Gamma' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Gamma' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_validIn (h_eq ▸ d')
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/-- **The single parameterized soundness theorem.** -/
theorem soundness_in {fc : FrameClass} (Γ : Context) (φ : Formula)
    (d : DerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    exact (axiom_validIn h_ax h_fc).apply_total F hF M τ h_mem t
  | assumption Γ' φ' h_in => exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    have h1 := ih1 τ h_mem t h_ctx
    have h2 := ih2 τ h_mem t h_ctx
    simp only [TruthAt] at h1
    exact h1 h2
  | necessitation φ' _ ih =>
    simp only [TruthAt]
    intro σ h_σ_mem
    exact ih σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [Truth.future_iff]
    intro s _hts
    exact ih τ h_mem s (by simp)
  | temporal_duality φ' d' _ih =>
    exact ((derivable_valid_and_swap_validIn d').2).apply_total F hF M τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## Corollary shapes: do the four existing statements fall out definitionally? -/

theorem soundness' (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Base Γ φ)
    (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  soundness_in Γ φ d F trivial M τ h_mem t h_ctx

theorem soundness_dense' (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Dense Γ φ)
    (F : TaskFrame) [inst : DenselyOrdered F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  soundness_in Γ φ d F inst M τ h_mem t h_ctx

theorem soundness_discrete' (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Discrete Γ φ)
    (F : TaskFrame) [so : SuccOrder F.Duration] [po : PredOrder F.Duration]
    [hsa : IsSuccArchimedean F.Duration] [hpa : IsPredArchimedean F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  soundness_in Γ φ d F ⟨so, po, hsa, hpa⟩ M τ h_mem t h_ctx

theorem soundness_dedekind' (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Dedekind Γ φ)
    (F : TaskFrame) [inst : DenselyOrdered F.Duration]
    (h_lub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  soundness_in Γ φ d F ⟨inst, h_lub⟩ M τ h_mem t h_ctx

/-- Empty-context validity form, uniform. -/
theorem soundness_validIn {fc : FrameClass} {φ : Formula}
    (d : DerivationTree fc [] φ) : ValidIn fc φ :=
  (derivable_valid_and_swap_validIn d).1

end Probe508

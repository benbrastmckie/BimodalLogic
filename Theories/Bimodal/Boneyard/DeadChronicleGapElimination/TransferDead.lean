/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.
Do not import from live code.
-/

#exit

-- ARCHIVED from multiple source files (task 302)
-- This file does NOT compile standalone — it requires imports and context from
-- the original files. Preserved for historical reference only.

-- ============================================================================
-- From ChronicleExtraction.lean lines 156-216
-- Reason: Dead code — extract_chronicle_as_prior is not called by any live code
-- ============================================================================

/-! ## Extraction from the Chronicle -/

/--
Extract a `ChronicleAsPriorModel` from the Burgess chronicle.

Given MCS A with `□(next_top) ∈ A` (box discreteness), the chronicle's
`LimitDomSubtype` provides a countable discrete domain without endpoints.
The `box_discrete_gives_discreteness` lemma ensures discreteness propagates
to every domain point.

The root point is `⟨0, zero_mem_limit_dom A h_mcs⟩` where `limit_f = A`.
-/
noncomputable def extract_chronicle_as_prior {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_discrete : Formula.box next_top ∈ A) : ChronicleAsPriorModel fc :=
  let h_discrete := box_discrete_gives_discreteness fc A h_mcs h_box_discrete
  {
    root := A
    root_mcs := h_mcs
    domain := LimitDomSubtype fc A h_mcs
    domain_succ := limitDomSubtype_succOrder fc A h_mcs h_discrete
    domain_pred := limitDomSubtype_predOrder fc A h_mcs h_discrete
    domain_succ_archimedean := by
      letI := limitDomSubtype_succOrder fc A h_mcs h_discrete
      sorry
    root_point := ⟨0, zero_mem_limit_dom fc A h_mcs⟩
    fmcs := fun t => limit_f fc A h_mcs t.val
    fmcs_is_mcs := fun t => limit_c0 fc A h_mcs t.val t.property
    root_point_mcs := limit_f_zero fc A h_mcs
    next_top_everywhere := fun t => h_discrete t.val t.property
    prior_UZ_valid := fun t ψ =>
      prior_UZ_in_limit_domain h_fc A h_mcs t.val t.property ψ
    prior_SZ_valid := fun t ψ =>
      prior_SZ_in_limit_domain h_fc A h_mcs t.val t.property ψ
    until_coherent_fwd := fun t φ ψ h_until => by
      obtain ⟨y, hy, hty, hφy, h_guard⟩ :=
        limit_satisfies_c5_strong fc A h_mcs t.val t.property ψ φ h_until
      exact ⟨⟨y, hy⟩, hty, hφy, fun r htr hrs => h_guard r.val r.property htr hrs⟩
    since_coherent_fwd := fun t φ ψ h_since => by
      obtain ⟨y, hy, hyt, hφy, h_guard⟩ :=
        limit_satisfies_c5'_strong fc A h_mcs t.val t.property ψ φ h_since
      exact ⟨⟨y, hy⟩, hyt, hφy, fun r hry hrt => h_guard r.val r.property hry hrt⟩
    neg_until_coherent := fun t s hts φ ψ h_neg_until hφs => by
      obtain ⟨z, hz, htz, hzs, h_neg_ψ⟩ :=
        limit_satisfies_c4 fc A h_mcs t.val s.val t.property s.property hts ψ φ h_neg_until hφs
      exact ⟨⟨z, hz⟩, htz, hzs, h_neg_ψ⟩
    neg_since_coherent := fun t s hst φ ψ h_neg_since hφs => by
      obtain ⟨z, hz, hsz, hzt, h_neg_ψ⟩ :=
        limit_satisfies_c4' fc A h_mcs t.val s.val t.property s.property hst ψ φ h_neg_since hφs
      exact ⟨⟨z, hz⟩, hsz, hzt, h_neg_ψ⟩
  }

-- ============================================================================
-- From ShiftAndGlue.lean lines 876-906
-- Reason: Dead code — chronicle_is_good uses IsSuccArchimedean via
-- orderIsoIntOfLinearSuccPredArch, not on critical path
-- ============================================================================

theorem chronicle_is_good {fc : FrameClass} (M : ChronicleAsPriorModel fc) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) (k : Nat) :
    good sig k (chronicleAsMonadicStructure M sig atomMap) := by
  haveI : Nonempty M.domain := M.domain_nonempty
  let f : M.domain ≃o ℤ := orderIsoIntOfLinearSuccPredArch
  let Z : ZIntervalStructure sig := {
    lo := none
    hi := none
    interp := fun p z => (atomMap p) ∈ M.fmcs (f.symm z)
  }
  refine ⟨Z, ?_⟩
  let val_iso : Z.intervalCarrier ≃o ℤ :=
    Equiv.toOrderIso
      { toFun := Subtype.val, invFun := fun z => ⟨z, trivial, trivial⟩,
        left_inv := by intro ⟨_, _⟩; rfl, right_inv := by intro _; rfl }
      (fun _ _ h => h) (fun _ _ h => h)
  let g : (chronicleAsMonadicStructure M sig atomMap).carrier ≃o (Z.toOrdered sig).carrier :=
    f.trans val_iso.symm
  apply k_equiv_of_iso sig k _ _ g
  intro p x
  show (atomMap p) ∈ M.fmcs x ↔ (atomMap p) ∈ M.fmcs (f.symm (f x))
  simp [OrderIso.symm_apply_apply]

-- ============================================================================
-- From ShiftAndGlue.lean lines 927-970
-- Reason: Dead code — chronicle_is_good_direct not called by any live code
-- ============================================================================

theorem chronicle_is_good_direct {fc : FrameClass} (M : ChronicleAsPriorModel fc) (sig : MonadicSignature)
    (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds)
    (k : Nat)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap_fwd (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ (chronicleAsMonadicStructure M sig atomMap_rev) atomMap_fwd)
    (h_prior_SZ : semantic_prior_SZ (chronicleAsMonadicStructure M sig atomMap_rev) atomMap_fwd) :
    good sig k (chronicleAsMonadicStructure M sig atomMap_rev) := by
  haveI : Nonempty M.domain := M.domain_nonempty
  let M_struct := chronicleAsMonadicStructure M sig atomMap_rev
  have h_one_class : ∀ (a b : M_struct.carrier), contemp_equiv sig k M_struct a b := by
    intro a b
    by_contra h_diff
    obtain ⟨c, hac, h_not_succ⟩ := no_gaps_discrete_model_surgery sig k M_struct atomMap_fwd
      h_surj h_prior_UZ h_prior_SZ a b h_diff
    exact h_not_succ ((contemp_equiv_is_equiv sig k M_struct).trans hac
      (no_boundary_at_successor sig k M_struct c))
  have h_very_good := one_class_implies_very_good sig k M_struct h_one_class
  exact very_good_implies_good sig k M_struct M.domain_countable h_very_good

-- ============================================================================
-- From BXCanonical/Completeness.lean lines 215-250
-- Reason: Dead code — countermodel_discrete_enriched is private and never called
-- ============================================================================

private theorem countermodel_discrete_enriched {fc : FrameClass} (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box Chronicle.next_top ∈ A) :
    ∃ (F : TaskFrame Int) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : Int),
      ¬truth_at TM Omega τ t φ := by
  let bfmcs := Chronicle.cantor_bfmcs_discrete fc A h_mcs h_box_discrete
  let fam₀ := Chronicle.rooted_succ_discrete_fmcs fc A h_mcs h_box_discrete 0
  refine ⟨Bimodal.Metalogic.Algebraic.ParametricCanonical.ParametricCanonicalTaskFrame Int,
    Bimodal.Metalogic.Algebraic.ParametricTruthLemma.ParametricCanonicalTaskModel Int,
    Bimodal.Metalogic.Algebraic.ParametricHistory.ShiftClosedParametricCanonicalOmega bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.shiftClosedParametricCanonicalOmega_is_shift_closed bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametric_to_history fam₀,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametricCanonicalOmega_subset_shiftClosed bfmcs
      ⟨fam₀, ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ fam₀.mcs 0 := by
    rw [Chronicle.rooted_succ_discrete_fmcs_at_s]; exact h_neg_in
  exact Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma.fully_restricted_parametric_completeness_from_neg_membership
    bfmcs φ
    (Chronicle.cantor_bfmcs_discrete_restricted_tc fc A h_mcs h_fc h_box_discrete φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (Chronicle.cantor_bfmcs_discrete_restricted_buc fc A h_mcs h_box_discrete φ)
    (Chronicle.cantor_bfmcs_discrete_restricted_fuc fc A h_mcs h_fc h_box_discrete φ)
    φ (self_mem_subformulaClosure φ)
    fam₀ ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

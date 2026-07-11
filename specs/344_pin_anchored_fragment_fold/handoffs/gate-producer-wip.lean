/-- **LEFT pin-anchored gate producer** (task 344 Phase 1 — the crux). From a realized
    `kvE2_sepBody` in the SINGLE-positive fragment (`hfrag`) with the sole positive sub `σ0`
    left-interior (`hz`), plus provider-correctness `hcorrK` at the pin (the `ExistProviders.correct`
    step 335 owns), the `kvE2_sepBody_kit_sound` conclusion is assembled by re-running the joint
    bracket extraction INLINE (keeping the segment components `holds_eq_succ` 4/5/6 discarded by
    `kvE2_sepBody_extract`), then deriving the four pin conjuncts and calling the landed
    `kvE2_sepBundleL_sound_frag`. Every conjunct is derived AT the extracted pin `x1` (`x < x1 < w`),
    NEVER at an arbitrary ∀-anchor (report §1 refutation). Additive; `hcorrK` an explicit
    hypothesis, never discharged. -/
theorem kvE2_sepGateAtPin_fragL {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (σ0 : NormalForm sig 1 4)
    (hfrag : kvE2_sepPos qnf = [σ0])
    (hz : nf0_zoneSpec σ0.1 = kvE2_sep_zXW3)
    (hcorrK : ∀ (σ : NormalForm sig 1 4) (a : M.carrier),
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 1 1 (fun _ => a) (nfk_projFresh σ))
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t) :
    (kvE2_sepEpL (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) := by
  set charBase := nf_depth0_char_formula atomMap h_surj with hcb
  by_cases hg : kvE2_sepGate qnf
  · rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t] at h
    obtain ⟨wo, hwo, hd⟩ := h
    obtain ⟨hepL, hepR, hbr⟩ := hd
    have hwo' : wo ∈ kvE2_sepOrderTypes qnf := (List.mem_filter.mp hwo).1
    have howners : wo.map Prod.fst = kvE2_sepPosI qnf := kvE2_sepOrderTypes_owners qnf hwo'
    have hksortL : (kvE2_sepSlotsLOf wo).Pairwise
        (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
      refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
      intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
    simp only [kvE2_sepDisjunct', kvE2_sepBracketN, BracketFormula.holds,
      BracketFormula.toIntervalPattern] at hbr
    rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
      (show ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length
        = ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1
        by omega)] at hbr
    obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegMid, hsegLast⟩ := hbr
    have hpt' : ∀ (i : Nat)
        (hi : i < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1),
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)
            ++ kvE2_sepPtW charBase charK qnf
              :: (kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK))[i]'(by
          simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
          (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
    have hwidx : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by omega
    set w := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length,
      hwidx⟩ with hwdef
    have hxw : x < w := (hrange _).1
    have hwt : w < t := (hrange _).2
    have hptW : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w := by
      have h1 := hpt' _ hwidx
      rwa [kvE2_sep_getElem_mid] at h1
    -- σ0's pin and bundle (single-positive: σ0 is the sole owner; no cross-σ slots)
    have hσ0pos : σ0 ∈ kvE2_sepPos qnf := by rw [hfrag]; exact List.mem_singleton_self _
    have hσ0true : qnf.2 σ0 = true := by
      have := hσ0pos; simp only [kvE2_sepPos, List.mem_filter] at this; exact this.2
    have hσI : σ0 ∈ kvE2_sepPosI qnf := (kvE2_sepPosI_mem qnf σ0).mpr ⟨hσ0pos, Or.inl hz⟩
    have hσp : σ0 ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨pp, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ0, pp.2.1, pp.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.lX1 σ0) ∈ kvE2_sepSlotsLOf wo :=
      kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lX1_mem_slotsLFor hz)
    rw [← kvE2_sepTieGroupedL_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp hc
    have hiσm : iσ < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    set x1 := ws ⟨iσ, by omega⟩ with hx1def
    have hxx1 : x < x1 := (hrange _).1
    have hx1w : x1 < w := hmono _ _ (Fin.mk_lt_mk.mpr hiσm)
    -- pin point type (folded through the class meet) and the charK anchor at the pin
    have hpin_raw := hpt' iσ (by omega)
    rw [kvE2_sep_getElem_left _ _ _ iσ hiσm, List.getElem_map, hgetiσ] at hpin_raw
    have hpt_pin := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hpin_raw hsc
    have hanchor : (⟨charK (nfk_projFresh σ0)⟩ : TemporalPred).eval_at M atomMap x1 :=
      kvE2_sepPtX1L_anchor charBase charK σ0 M atomMap x1 hpt_pin
    -- below-witness clause: every zXU-positive 1-type strictly below the pin
    have hbelow : ∀ χ : NormalForm sig 0 1,
        σ0.2 (nf0_assemble kvE_sub2_zXU χ σ0.1) = true →
        ∃ u : M.carrier, x < u ∧ u < x1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
      intro χ hbit
      have hmemU : (KvE2SepSlot.lXU σ0 χ) ∈ kvE2_sepSlotsLOf wo :=
        kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lXU_mem_slotsLFor hz hbit)
      rw [← kvE2_sepTieGroupedL_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lXU σ0 χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ0) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lXU_mem_slotsLFor hz hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.lXU σ0 χ) ∈ (kvE2_sepTieGroupedL wo)[jχ]'hjχ := by
        rw [hgetjχ]; exact hsd
      have hbin : (KvE2SepSlot.lX1 σ0) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
        rw [hgetiσ]; exact hsc
      have hji : jχ < iσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsLOf wo) hksortL hjχ hiσ hain hbin hkey
      have hjχm : jχ < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨jχ, by omega⟩, (hrange _).1,
        hmono _ _ (Fin.mk_lt_mk.mpr hji), ?_⟩
      have h1 := hpt' jχ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd
    refine ⟨hepL, hepR, w, hxw, hwt, hptW, ?_, ?_⟩
    · intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      have h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false :=
        kvE2_sepHgate_offFiber qnf hg σ hσ0true
      -- gate clause (i): a positive sub's env-restriction equals `qnf.1`
      have hdrop : nf0_dropFresh σ.1 = qnf.1 := by
        by_contra hne
        rw [hg.1 σ hne] at hσ0true
        exact absurd hσ0true (by decide)
      -- the three outer points realize `qnf.1`'s coordinate 1-types (endpoint/point heads)
      have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
        have h1 := hptW
        simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ w).mp
          ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
      have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
        have h1 := hepL
        simp only [kvE2_sepEpL, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ x).mp
          ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
      have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
        have h1 := hepR
        simp only [kvE2_sepEpR, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ t).mp
          ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
      have h_atom : nf_eval_nf M 0 4
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
        -- reconstruct σ.1 from its three Def-3.1 channels: zone = zXW3, fresh type via hcorrK,
        -- env-restriction = qnf.1 (so non-fresh bits ride the outer order/coordinate content)
        have hσ0eq : σ.1 = nf0_assemble kvE2_sep_zXW3 (nf0_projFresh σ.1) qnf.1 := by
          rw [← hz, ← hdrop, nf0_split_assemble]
        have hpf : (nfk_projFresh σ).1 = nf0_projFresh σ.1 := by
          funext a
          match a with
          | .pred p i =>
            have hi : i = ⟨0, by omega⟩ := Subsingleton.elim i _
            subst hi; rfl
          | .order i j hij => exact absurd (Subsingleton.elim i j) hij
        obtain ⟨hc0a, -⟩ := hcorrK σ x1 hanchor
        rw [hσ0eq]
        intro a
        match a with
        | .pred p ⟨0, _⟩ =>
          have h1 := hc0a (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, Fin.cons_zero] at h1 ⊢
          simp only [nf0_assemble, Fin.cases_zero]
          rw [← hpf]; exact h1
        | .pred p ⟨1, _⟩ =>
          have h1 := hprojW (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] at h1 ⊢
          simp only [nf0_assemble, Fin.cases_succ, Fin.cases_zero]; exact h1
        | .pred p ⟨2, _⟩ =>
          have h1 := hprojX (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] at h1 ⊢
          simp only [nf0_assemble, Fin.cases_succ, Fin.cases_zero]; exact h1
        | .pred p ⟨3, _⟩ =>
          have h1 := hprojT (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] at h1 ⊢
          simp only [nf0_assemble, Fin.cases_succ, Fin.cases_zero]; exact h1
        | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, kvE2_sep_zXW3,
            Fin.cons_zero, Fin.cons_succ, atom_eval]
          exact iff_of_true hx1w rfl
        | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, kvE2_sep_zXW3,
            Fin.cons_zero, Fin.cons_succ, atom_eval]
          exact iff_of_false (lt_asymm hxx1) (by decide)
        | .order ⟨0, _⟩ ⟨3, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, kvE2_sep_zXW3,
            Fin.cons_zero, Fin.cons_succ, atom_eval]
          exact iff_of_true (hx1w.trans hwt) rfl
        | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, kvE2_sep_zXW3,
            Fin.cons_zero, Fin.cons_succ, atom_eval]
          exact iff_of_false (lt_asymm hx1w) (by decide)
        | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, kvE2_sep_zXW3,
            Fin.cons_zero, Fin.cons_succ, atom_eval]
          exact iff_of_true hxx1 rfl
        | .order ⟨3, _⟩ ⟨0, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, kvE2_sep_zXW3,
            Fin.cons_zero, Fin.cons_succ, atom_eval]
          exact iff_of_false (lt_asymm (hx1w.trans hwt)) (by decide)
        | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, atom_eval,
            Fin.cons_zero, Fin.cons_succ, h_yx]
          exact iff_of_false (lt_asymm (hxx1.trans hx1w)) (by decide)
        | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, atom_eval,
            Fin.cons_zero, Fin.cons_succ, h_xy]
          exact iff_of_true (hxx1.trans hx1w) rfl
        | .order ⟨1, _⟩ ⟨3, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, atom_eval,
            Fin.cons_zero, Fin.cons_succ, h_yt]
          exact iff_of_true hwt rfl
        | .order ⟨3, _⟩ ⟨1, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, atom_eval,
            Fin.cons_zero, Fin.cons_succ, h_ty]
          exact iff_of_false (lt_asymm hwt) (by decide)
        | .order ⟨2, _⟩ ⟨3, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, atom_eval,
            Fin.cons_zero, Fin.cons_succ, h_xt]
          exact iff_of_true (hxx1.trans (hx1w.trans hwt)) rfl
        | .order ⟨3, _⟩ ⟨2, _⟩ hne =>
          simp only [nf0_assemble, Fin.cases_zero, Fin.cases_succ, atom_eval,
            Fin.cons_zero, Fin.cons_succ, h_tx]
          exact iff_of_false (lt_asymm (hxx1.trans (hx1w.trans hwt))) (by decide)
        | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
        | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
        | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
        | .order ⟨3, _⟩ ⟨3, _⟩ hne => exact absurd rfl hne
      have h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
          (∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ) →
          σ.2 (nf0_assemble zs χ σ.1) = true := by sorry
      have h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
          σ.2 (nf0_assemble zs χ σ.1) = true →
          ∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ := by sorry
      exact kvE2_sepBundleL_sound_frag atomMap h_surj σ M w x t hwt x1 hx1w hbelow
        h_atom h_off h_fwd h_bwd
    · intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      rw [hz] at hzσ
      exact absurd hzσ (by decide)
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

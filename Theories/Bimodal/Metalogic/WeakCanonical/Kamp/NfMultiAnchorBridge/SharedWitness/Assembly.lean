/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.DisjunctionSpikes

/-! # Shared-Interior-Witness Joint Carrier — O4 assembly

Module H of the `SharedWitness` tower. The O4 assembly: `kvE2_sepBody_extract` (soundness
direction) and `kvE2_sepBody_holds_of_honest` (completeness direction), over the primed
tie-reporting order bridge and value-sortedness. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-- **Primed halign monotonicity**: on the tie-reporting
    order the mergeSort key `kvE2_sepSlotGIdx` is strictly monotone in the slot value. Mirror of
    `kvE2_sepSlotGIdx_honestOrder_mono` (SW:4047) via the primed bridge +
    `kvE2_sepSlotHonestVIdx_mono`. -/
theorem kvE2_sepSlotGIdx_honestOrder'_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock τ)
    (hlt : kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) a
      < kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) b := by
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h hσ ha,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h hτ hb]
  exact kvE2_sepSlotHonestVIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ ha) (kvE2_sepMem_allSlots qnf hτ hb) hlt

/-- **Value-sortedness of the joint LEFT list on the tie-reporting order**: the primed
    merged LEFT slot list is `Pairwise` value-nondecreasing. Mirror of
    `kvE2_sepSlotsLOf_honest_valueSorted` (SW:4157) using the primed bridge/monotonicity. -/
theorem kvE2_sepSlotsLOf_honestOrder'_valueSorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsLOf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsLOf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder'_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-- **Value-sortedness of the joint RIGHT list on the tie-reporting order** (mirror). -/
theorem kvE2_sepSlotsROf_honestOrder'_valueSorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsROf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsROf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsROf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder'_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-- **Tie-class key constancy**: every element of a single
    `kvE2_sepTieRuns` class shares the class key. A run only extends when the new head's key
    equals the current run head's, so class members carry one key — unconditionally (no
    sortedness needed). Structural induction mirroring `kvE2_sepTieRuns_ne_nil` (SW:2008). -/
theorem kvE2_sepTieRuns_key_const {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), ∀ c ∈ kvE2_sepTieRuns key l, ∀ u ∈ c, ∀ v ∈ c, key u = key v
  | [] => by simp [kvE2_sepTieRuns]
  | [a] => by
      intro c hc u hu v hv
      rw [kvE2_sepTieRuns] at hc
      simp only [List.mem_singleton] at hc
      subst hc
      simp only [List.mem_singleton] at hu hv
      subst hu; subst hv; rfl
  | a :: b :: rest => by
      have ih := kvE2_sepTieRuns_key_const key (b :: rest)
      obtain ⟨tl, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
      intro c hc u hu v hv
      rw [kvE2_sepTieRuns, heq] at hc
      by_cases hk : key a = key b
      · simp only [if_pos hk] at hc
        rcases List.mem_cons.mp hc with rfl | hmem
        · have hbrun : ∀ z ∈ (b :: tl), key z = key b := fun z hz =>
            ih (b :: tl) (by rw [heq]; exact List.mem_cons_self) z hz b List.mem_cons_self
          have hall : ∀ z ∈ (a :: b :: tl), key z = key b := by
            intro z hz
            rcases List.mem_cons.mp hz with rfl | hz
            · exact hk
            · exact hbrun z hz
          rw [hall u hu, hall v hv]
        · exact ih c (by rw [heq]; exact List.mem_cons_of_mem _ hmem) u hu v hv
      · simp only [if_neg hk] at hc
        rcases List.mem_cons.mp hc with rfl | hmem
        · simp only [List.mem_singleton] at hu hv
          subst hu; subst hv; rfl
        · exact ih c (by rw [heq]; exact hmem) u hu v hv

/-- **Tie-class key strict monotonicity** (report 14 Q2): on a
    key-sorted list, `kvE2_sepTieRuns` yields runs whose keys STRICTLY increase across distinct
    classes — every member of an earlier class has a strictly smaller key than every member of a
    later class. The maximal-adjacent-run construction plus key-sortedness force the strict jump
    at each class boundary. Structural induction mirroring `kvE2_sepTieRuns_key_const`. -/
theorem kvE2_sepTieRuns_key_strictMono {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), l.Pairwise (fun a b => key a ≤ key b) →
      (kvE2_sepTieRuns key l).Pairwise
        (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, key u < key v)
  | [], _ => by simp [kvE2_sepTieRuns]
  | [a], _ => by simp [kvE2_sepTieRuns]
  | a :: b :: rest, hsort => by
      obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
      have hcons := List.pairwise_cons.mp hsort
      have ha : ∀ z ∈ b :: rest, key a ≤ key z := hcons.1
      have hbrest : (b :: rest).Pairwise (fun a b => key a ≤ key b) := hcons.2
      have ih := kvE2_sepTieRuns_key_strictMono key (b :: rest) hbrest
      rw [heq] at ih
      have ihcons := List.pairwise_cons.mp ih
      have hb_le : ∀ z ∈ b :: rest, key b ≤ key z := by
        intro z hz
        rcases List.mem_cons.mp hz with rfl | hz
        · exact le_refl _
        · exact (List.pairwise_cons.mp hbrest).1 z hz
      have hflat : ((b :: t) :: cs).flatten = b :: rest := by
        rw [← heq]; exact kvE2_sepTieRuns_flatten key (b :: rest)
      have hmem_brest : ∀ d ∈ (b :: t) :: cs, ∀ v ∈ d, v ∈ b :: rest := by
        intro d hd v hv
        rw [← hflat]
        exact List.mem_flatten.mpr ⟨d, hd, hv⟩
      rw [kvE2_sepTieRuns, heq]
      by_cases hk : key a = key b
      · simp only [if_pos hk]
        rw [List.pairwise_cons]
        refine ⟨?_, ihcons.2⟩
        intro d hd u hu v hv
        rcases List.mem_cons.mp hu with rfl | hu
        · have hbv : key b < key v := ihcons.1 d hd b List.mem_cons_self v hv
          omega
        · exact ihcons.1 d hd u hu v hv
      · simp only [if_neg hk]
        rw [List.pairwise_cons]
        refine ⟨?_, ih⟩
        intro d hd u hu v hv
        rw [List.mem_singleton] at hu
        have hvmem : v ∈ b :: rest := hmem_brest d hd v hv
        have hab : key a < key b := lt_of_le_of_ne (ha b List.mem_cons_self) hk
        rw [hu]
        exact lt_of_lt_of_le hab (hb_le v hvmem)

/-- **Tie-class index order from strict key order** (Route A, (a)): on a key-sorted
    list, members of distinct tie classes with strictly ordered keys sit in strictly ordered
    classes — the index-level read that replaces the refuted flat-list
    `kvE2_sep_index_lt_of_rank_lt` route for grouped disjuncts. Trichotomy: equal indices are
    refuted by within-class key constancy (`kvE2_sepTieRuns_key_const`), reversed indices by
    cross-class strict key monotonicity (`kvE2_sepTieRuns_key_strictMono` through
    `List.pairwise_iff_getElem`). -/
theorem kvE2_sepTieRuns_classIdx_lt {α : Type*} (key : α → ℕ) (l : List α)
    (hs : l.Pairwise (fun x y => key x ≤ key y))
    {i j : ℕ} (hi : i < (kvE2_sepTieRuns key l).length)
    (hj : j < (kvE2_sepTieRuns key l).length)
    {a b : α} (ha : a ∈ (kvE2_sepTieRuns key l)[i]) (hb : b ∈ (kvE2_sepTieRuns key l)[j])
    (hab : key a < key b) : i < j := by
  rcases Nat.lt_trichotomy i j with hlt | heq | hgt
  · exact hlt
  · exfalso
    subst heq
    have hconst := kvE2_sepTieRuns_key_const key l ((kvE2_sepTieRuns key l)[i])
      (List.getElem_mem hi) a ha b hb
    omega
  · exfalso
    have hstrict := kvE2_sepTieRuns_key_strictMono key l hs
    have hba := List.pairwise_iff_getElem.mp hstrict j i hj hi hgt b hb a ha
    omega

/-- **Route-A tie-admitting grouped extraction**; the grouped analog
    of the flat template `kvE2_sepDisjunct_extract`): from a realized GROUPED disjunct of
    any valid weak order `wo ∈ kvE2_sepArr' qnf`, extract both joint endpoint realizations,
    the ONE shared witness `w` (the `ptW` slot at class position `|gL|`; `x < w < t` from
    the bracket's own range — FM-x1t), and at that same `w` the per-σ witness bundle for
    every positive interior σ of either class. Every point is read through the meet-folded
    class type (`kvE2_sepClassType_eval_mem`: a realized class point realizes EACH member's
    slot type — Def 3.1 conjunction semantics, Rabinovich 2014, p.4), so ties never obstruct
    the read: cross-owner ties merely enlarge a class's meet. Same-owner anchor/base
    separation needs NO cross-owner hypothesis — the strict same-owner key order
    `kvE2_sep_gidx_lt_of_rank_lt` (conjunct (ii) via `kvE2_sepArr'_consistent`) forces the
    `lXU`/`rWX1` slot into a STRICTLY earlier tie class than the `lX1`/`rX1` anchor
    (`kvE2_sepTieRuns_classIdx_lt` at the merge-sorted key order), and bracket monotonicity
    places its witness strictly below the fresh witness. Witness positions are read
    structurally off class indices (Def 3.1 monotone enumeration; §5 interleaving,
    Rabinovich 2014, p.7) — never an `x1 < e_i` literal (LITMUS). -/
theorem kvE2_sepDisjunct'_extract {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepArr' qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)).2.holds M atomMap x t) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        kvE2_sepBundleR charBase charK σ M atomMap w t) := by
  obtain ⟨hepL, hepR, hbr⟩ := h
  refine ⟨hepL, hepR, ?_⟩
  -- Shared wo facts: enumeration membership, owner projection, merge-key sortedness
  -- (Bool merge key → Prop key order, the `simpa`-level bridge).
  have hwo' : wo ∈ kvE2_sepOrderTypes qnf := (List.mem_filter.mp hwo).1
  have howners : wo.map Prod.fst = kvE2_sepPosI qnf := kvE2_sepOrderTypes_owners qnf hwo'
  have hksortL : (kvE2_sepSlotsLOf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hksortR : (kvE2_sepSlotsROf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsROf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  -- Destructure the realized grouped N-slot bracket (Def 3.1 monotone enumeration, p.4;
  -- skeleton transposed from the flat template).
  simp only [kvE2_sepDisjunct', kvE2_sepBracketN, BracketFormula.holds,
    BracketFormula.toIntervalPattern] at hbr
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length
      = ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1
      by omega)] at hbr
  obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩ := hbr
  -- Canonical point-type reads (defeq re-typing; flat-template pattern).
  have hpt' : ∀ (i : Nat)
      (hi : i < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1),
      (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)
          ++ kvE2_sepPtW charBase charK qnf
            :: (kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK))[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length,
      by omega⟩,
    (hrange _).1, (hrange _).2, ?_, ?_, ?_⟩
  · -- The shared `ptW` realization at class position `|gL|` (§5 bracket, p.7).
    have h1 := hpt'
      ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length (by omega)
    rwa [kvE2_sep_getElem_mid] at h1
  · -- LEFT-interior bundles: σ's fresh slot lies in some LEFT tie class.
    intro σ hσpos hzone
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inl hzone⟩
    have hσp : σ ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.lX1 σ) ∈ kvE2_sepSlotsLOf wo :=
      kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lX1_mem_slotsLFor hzone)
    rw [← kvE2_sepTieGroupedL_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp hc
    have hiσm : iσ
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨iσ, by omega⟩, (hrange _).1,
      hmono _ _ (Fin.mk_lt_mk.mpr hiσm), ?_, ?_⟩
    · -- σ's folded fresh point type through the class meet (Def 3.1 conjunction, p.4).
      have h1 := hpt' iσ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ iσ hiσm, List.getElem_map, hgetiσ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsc
    · -- Every `zXU`-positive 1-type strictly below the fresh witness: strict same-owner
      -- key order → strictly earlier tie class → bracket monotonicity.
      intro χ hbit
      have hmemU : (KvE2SepSlot.lXU σ χ) ∈ kvE2_sepSlotsLOf wo :=
        kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lXU_mem_slotsLFor hzone hbit)
      rw [← kvE2_sepTieGroupedL_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lXU σ χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lXU_mem_slotsLFor hzone hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hzone))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.lXU σ χ) ∈ (kvE2_sepTieGroupedL wo)[jχ]'hjχ := by
        rw [hgetjχ]; exact hsd
      have hbin : (KvE2SepSlot.lX1 σ) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
        rw [hgetiσ]; exact hsc
      have hji : jχ < iσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsLOf wo) hksortL hjχ hiσ hain hbin hkey
      have hjχm : jχ
          < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨jχ, by omega⟩, (hrange _).1,
        hmono _ _ (Fin.mk_lt_mk.mpr hji), ?_⟩
      have h1 := hpt' jχ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd
  · -- RIGHT-interior bundles (mirrored): σ's fresh slot lies in some RIGHT tie class.
    intro σ hσpos hzone
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inr hzone⟩
    have hσp : σ ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.rX1 σ) ∈ kvE2_sepSlotsROf wo :=
      kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rX1_mem_slotsRFor hzone)
    rw [← kvE2_sepTieGroupedR_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨jσ, hjσ, hgetjσ⟩ := List.mem_iff_getElem.mp hc
    have hjσm : jσ
        < ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + 1 + jσ, by omega⟩,
      hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), (hrange _).2, ?_, ?_⟩
    · have h1 := hpt'
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + jσ)
        (by omega)
      rw [kvE2_sep_getElem_right _ _ _ jσ hjσm, List.getElem_map, hgetjσ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsc
    · intro χ hbit
      have hmemU : (KvE2SepSlot.rWX1 σ χ) ∈ kvE2_sepSlotsROf wo :=
        kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rWX1_mem_slotsRFor hzone hbit)
      rw [← kvE2_sepTieGroupedR_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨j', hj', hgetj'⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rWX1 σ χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rWX1_mem_slotsRFor hzone hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hzone))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.rWX1 σ χ) ∈ (kvE2_sepTieGroupedR wo)[j']'hj' := by
        rw [hgetj']; exact hsd
      have hbin : (KvE2SepSlot.rX1 σ) ∈ (kvE2_sepTieGroupedR wo)[jσ]'hjσ := by
        rw [hgetjσ]; exact hsc
      have hji : j' < jσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsROf wo) hksortR hj' hjσ hain hbin hkey
      have hj'm : j'
          < ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + 1 + j', by omega⟩,
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)),
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), ?_⟩
      have h1 := hpt'
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + j')
        (by omega)
      rw [kvE2_sep_getElem_right _ _ _ j' hj'm, List.getElem_map, hgetj'] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd

/-- **O3 at carrier level — the hypothesis-free Route-A body extraction** (step (d)):
    extraction from any realized `kvE2_sepBody`, with NO universal
    side-conditions — every needed fact derives from the realized disjunct's own carrier
    membership `wo ∈ kvE2_sepArr' qnf` (no gate hypothesis — the gate-failure branch is the
    empty disjunction, whose `holds` is `False`). Routes through the O2 membership collapse
    `kvE2_sepBody_holds_iff` and the tie-admitting grouped extraction
    `kvE2_sepDisjunct'_extract`, which reads per-class witnesses through
    `kvE2_sepClassType_eval_mem` on the GROUPED disjunct — matching the tie-admitting
    carrier design the repair installed (base-base ties deliberately representable).
    The former tie-free singleton-conversion route and its universal `hpairL`/`hpairR`/`hnd`
    side-conditions (FALSE for general `qnf` — the R2 blocker record) are
    eliminated. Def 3.1 single strict witness chain (Rabinovich 2014, p.4); §5 interleaving
    (p.7). -/
theorem kvE2_sepBody_extract {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepBody charBase charK qnf).holds M atomMap x t) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        kvE2_sepBundleR charBase charK σ M atomMap w t) := by
  by_cases hg : kvE2_sepGate qnf
  · rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t] at h
    obtain ⟨wo, hwo, hd⟩ := h
    exact kvE2_sepDisjunct'_extract charBase charK qnf hwo M atomMap x t hd
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

/-- **One value per LEFT tie class**: all slots of a single
    tie class of the primed grouped LEFT list carry EQUAL honest slot value. Equal keys within
    the class (`kvE2_sepTieRuns_key_const`) become equal honest values through the primed bridge
    + the tie-reporting payload law `kvE2_sepSlotHonestVIdx_eq_iff` (SW:5857). -/
theorem kvE2_sepTieGroupedL_value_const {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
    {u : KvE2SepSlot sig} (hu : u ∈ c) {v : KvE2SepSlot sig} (hv : v ∈ c) :
    kvE2_sepSlotValue qnf M w x t h u = kvE2_sepSlotValue qnf M w x t h v := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepTieGroupedL] at hc
  have hkey : kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) u
      = kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) v :=
    kvE2_sepTieRuns_key_const _ _ c hc u hu v hv
  have huf : u ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedL_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedL]
    exact List.mem_flatten.mpr ⟨c, hc, hu⟩
  have hvf : v ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedL_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedL]
    exact List.mem_flatten.mpr ⟨c, hc, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsLOf_mem_block hwo huf
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hvf
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ] at hkey
  exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mp hkey

/-- **One value per RIGHT tie class** (mirror of `kvE2_sepTieGroupedL_value_const`). -/
theorem kvE2_sepTieGroupedR_value_const {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))
    {u : KvE2SepSlot sig} (hu : u ∈ c) {v : KvE2SepSlot sig} (hv : v ∈ c) :
    kvE2_sepSlotValue qnf M w x t h u = kvE2_sepSlotValue qnf M w x t h v := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepTieGroupedR] at hc
  have hkey : kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) u
      = kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) v :=
    kvE2_sepTieRuns_key_const _ _ c hc u hu v hv
  have huf : u ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedR_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedR]
    exact List.mem_flatten.mpr ⟨c, hc, hu⟩
  have hvf : v ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedR_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedR]
    exact List.mem_flatten.mpr ⟨c, hc, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsROf_mem_block hwo huf
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsROf_mem_block hwo hvf
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ] at hkey
  exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mp hkey

/-- **O1 cross-class strict value monotonicity, LEFT** (report 14 Q5):
    the primed grouped LEFT tie classes carry STRICTLY increasing honest values across distinct
    classes — every member of an earlier class has strictly smaller value than every member of a
    later class. Assembles five landed Phase-1 assets: value-sortedness (`≤` between classes via
    `List.pairwise_flatten`), key strict monotonicity across runs
    (`kvE2_sepTieRuns_key_strictMono`), the primed bridge (`kvE2_sepSlotGIdx_honestOrder'`), and
    the tie-reporting payload law (`kvE2_sepSlotHonestVIdx_eq_iff`, giving `≠` from key-distinct).
    `≤` ∧ `≠` ⟹ `<`. Faithful to Rabinovich Lemma 5.3's strict inter-point chain (the merge
    absorbs ties, the order is not weakened). -/
theorem kvE2_sepTieGroupedL_strictMono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂,
        kvE2_sepSlotValue qnf M w x t h u < kvE2_sepSlotValue qnf M w x t h v) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  have hksort : (kvE2_sepSlotsLOf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hkey := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
    (kvE2_sepSlotsLOf wo) hksort
  have hvsorted := kvE2_sepSlotsLOf_honestOrder'_valueSorted qnf M w x t h
  rw [← hwo_def, ← kvE2_sepTieGroupedL_flatten wo, List.pairwise_flatten] at hvsorted
  have hvle := hvsorted.2
  rw [List.pairwise_iff_forall_sublist] at hkey hvle ⊢
  intro c₁ c₂ hsub u hu v hv
  have hle := hvle hsub u hu v hv
  have hklt := hkey hsub u hu v hv
  refine lt_of_le_of_ne hle ?_
  intro hval
  have hc1 : c₁ ∈ kvE2_sepTieGroupedL wo := hsub.subset (by simp)
  have hc2 : c₂ ∈ kvE2_sepTieGroupedL wo := hsub.subset (by simp)
  have hufl : u ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c₁, hc1, hu⟩
  have hvfl : v ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c₂, hc2, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsLOf_mem_block hwo hufl
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hvfl
  have hkeq : kvE2_sepSlotGIdx wo u = kvE2_sepSlotGIdx wo v := by
    rw [hwo_def, kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
        kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ]
    exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mpr hval
  omega

/-- **O1 cross-class strict value monotonicity, RIGHT** (mirror of
`kvE2_sepTieGroupedL_strictMono`). -/
theorem kvE2_sepTieGroupedR_strictMono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂,
        kvE2_sepSlotValue qnf M w x t h u < kvE2_sepSlotValue qnf M w x t h v) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  have hksort : (kvE2_sepSlotsROf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsROf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hkey := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
    (kvE2_sepSlotsROf wo) hksort
  have hvsorted := kvE2_sepSlotsROf_honestOrder'_valueSorted qnf M w x t h
  rw [← hwo_def, ← kvE2_sepTieGroupedR_flatten wo, List.pairwise_flatten] at hvsorted
  have hvle := hvsorted.2
  rw [List.pairwise_iff_forall_sublist] at hkey hvle ⊢
  intro c₁ c₂ hsub u hu v hv
  have hle := hvle hsub u hu v hv
  have hklt := hkey hsub u hu v hv
  refine lt_of_le_of_ne hle ?_
  intro hval
  have hc1 : c₁ ∈ kvE2_sepTieGroupedR wo := hsub.subset (by simp)
  have hc2 : c₂ ∈ kvE2_sepTieGroupedR wo := hsub.subset (by simp)
  have hufl : u ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c₁, hc1, hu⟩
  have hvfl : v ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c₂, hc2, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsROf_mem_block hwo hufl
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsROf_mem_block hwo hvfl
  have hkeq : kvE2_sepSlotGIdx wo u = kvE2_sepSlotGIdx wo v := by
    rw [hwo_def, kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
        kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ]
    exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mpr hval
  omega

/-- **O1 below-pivot range, per owner (LEFT)**: every LEFT-region slot
    of a positive owner has honest value strictly inside `(x, w)` — the below-pivot bracket half
    (Rabinovich Figure 1, PDF p.9). For a left-interior owner the `.lXU`/`.lX1`/`.lUW` slots nest
    inside `(x, x1_σ) < x1_σ < (x1_σ, w)`; for a right-interior owner the `.rXW` slots sit in
    `(x, w)` by the landed Phase-2 below-pivot bound. Supplies the `usL`-last `< w` pivot fact O1
    needs (per-slot value specs, NOT value-sortedness — plan 12 line 140 mis-mitigation
    retracted). -/
theorem kvE2_sepSlotsLFor_value_bound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLFor σ) :
    x < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < w := by
  rw [kvE2_sepSlotsLFor] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1, List.mem_append] at hs
    rcases hs with hs | hs
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
      have hspec := kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ
      have hanch := (kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1).2.1
      exact ⟨hspec.1, lt_trans hspec.2.1 hanch⟩
    · rw [List.mem_cons] at hs
      rcases hs with rfl | hs
      · have hanch := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1
        rw [kvE2_sepSlotValue_lX1]
        exact ⟨hanch.1, hanch.2.1⟩
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
        have hspec := kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ
        have hanch := (kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1).1
        exact ⟨lt_trans hanch hspec.1, hspec.2.1⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2] at hs
      obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
      have hspec := kvE2_sepSlotValue_rXW_spec qnf M w x t h σ hσ χ hχ
      exact ⟨hspec.1, hspec.2.1⟩
    · rw [if_neg hz1, if_neg hz2] at hs
      exact absurd hs (by simp)

/-- **O1 above-pivot range, per owner (RIGHT)** (mirror of `kvE2_sepSlotsLFor_value_bound`): every
    RIGHT-region slot of a positive owner has honest value strictly inside `(w, t)` — the
    above-pivot bracket half. Supplies the `w < usR`-first pivot fact. -/
theorem kvE2_sepSlotsRFor_value_bound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsRFor σ) :
    w < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < t := by
  rw [kvE2_sepSlotsRFor] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1] at hs
    obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
    have hspec := kvE2_sepSlotValue_lWT_spec qnf M w x t h σ hσ χ hχ
    exact ⟨hspec.1, hspec.2.1⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2, List.mem_append] at hs
      rcases hs with hs | hs
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
        have hspec := kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ
        have hanch := (kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2).2.1
        exact ⟨hspec.1, lt_trans hspec.2.1 hanch⟩
      · rw [List.mem_cons] at hs
        rcases hs with rfl | hs
        · have hanch := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2
          rw [kvE2_sepSlotValue_rX1]
          exact ⟨hanch.1, hanch.2.1⟩
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
          have hspec := kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ
          have hanch := (kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2).1
          exact ⟨lt_trans hanch hspec.1, hspec.2.1⟩
    · rw [if_neg hz1, if_neg hz2] at hs
      exact absurd hs (by simp)

/-- **O1 below-pivot range, merged LEFT list**: every slot of the
    primed merged LEFT list has honest value strictly inside `(x, w)`. The list-level pivot/range
    fact the Phase-7 assembly reads for `usL`-last `< w` and the global `x < · < t` range. -/
theorem kvE2_sepSlotsLOf_honestOrder'_value_bound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h)) :
    x < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < w := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepSlotsLOf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  have hσpos : σ ∈ kvE2_sepPos qnf :=
    kvE2_sepPosI_subset (kvE2_sepOrderOwners_mem_pos hwo hσ)
  exact kvE2_sepSlotsLFor_value_bound qnf M w x t hxw hwt h hσpos hsσ

/-- **O1 above-pivot range, merged RIGHT list** (mirror of
`kvE2_sepSlotsLOf_honestOrder'_value_bound`):
    every slot of the primed merged RIGHT list has honest value strictly inside `(w, t)`. -/
theorem kvE2_sepSlotsROf_honestOrder'_value_bound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h)) :
    w < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < t := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepSlotsROf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  have hσpos : σ ∈ kvE2_sepPos qnf :=
    kvE2_sepPosI_subset (kvE2_sepOrderOwners_mem_pos hwo hσ)
  exact kvE2_sepSlotsRFor_value_bound qnf M w x t hxw hwt h hσpos hsσ

/-! ### O2: class point-type realization at the honest class value

The grouped bracket's LEFT/RIGHT point-type lists are `gL.map kvE2_sepClassType` /
`gR.map (…)`. `kvE2_sepBracketN_construct`'s `hptL`/`hptR` obligations require each class type to
evaluate at that class's honest witness value. Via `kvE2_sepClassType_eval_iff` this reduces to
every class MEMBER's slot type realizing at the (shared) class value; since one value per class
(`kvE2_sepTieGroupedL/R_value_const`), the class value is each member's OWN honest value, so the
obligation is the per-slot point-type discharge below. Base slots ride `hcb` + the banked value
specs; anchor slots ride the fresh-projection channel (`kvE2_sepProjFresh_eval` + `hck`) and the
CLOSED self-zone literal reads (`kvE2_sepOwnerLit_zAtX1L/R`). F5: only CLOSED `zAtX1L`/`zAtX1R`
keys enter; LITMUS-clean (all bounds ride `x`/`w`/`t`). -/

/-- `zAtX1L` self-zone literal honesty at a LEFT-interior owner's anchor value `a` (`x < a < w`):
    mirror of `kvE2_sepOwnerLit_zAtWL` reading the fresh-witness self-zone `v = a` instead of the
    pivot. -/
private theorem kvE2_sepOwnerLit_zAtX1L {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hxa : x < a) (haw : a < w) (hwt : w < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap a
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1L χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtX1L χ with
  | true =>
    change temporal_truth M atomMap a (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtX1L χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, false) (true, false) (false, true) (true, false)).mp hz
    have hveq : v = a := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h0.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h0.1.mp hc)))
    exact (hcb χ a).mpr (hveq ▸ hv)
  | false =>
    change temporal_truth M atomMap a (charBase χ).neg
    intro hch
    have hat : a < t := haw.trans hwt
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtX1L a := by
      refine (kvE2_sepZone4_iff M a w x t a
        (false, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_irrefl a) (by decide), iff_of_false (lt_irrefl a) (by decide)⟩,
        ⟨iff_of_true haw rfl, iff_of_false (lt_asymm haw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxa) (by decide), iff_of_true hxa rfl⟩,
        ⟨iff_of_true hat rfl, iff_of_false (lt_asymm hat) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtX1L χ = true :=
      (h_zone kvE2_sep_zAtX1L χ).mp ⟨a, hz, (hcb χ a).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtX1R` self-zone literal honesty at a RIGHT-interior owner's anchor value `a` (`w < a < t`):
    mirror of `kvE2_sepOwnerLit_zAtX1L`. -/
private theorem kvE2_sepOwnerLit_zAtX1R {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hwa : w < a) (hat : a < t) (hxw : x < w)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap a
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1R χ) (charBase χ)) := by
  have hxa : x < a := hxw.trans hwa
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtX1R χ with
  | true =>
    change temporal_truth M atomMap a (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtX1R χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, false) (false, true) (false, true) (true, false)).mp hz
    have hveq : v = a := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h0.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h0.1.mp hc)))
    exact (hcb χ a).mpr (hveq ▸ hv)
  | false =>
    change temporal_truth M atomMap a (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtX1R a := by
      refine (kvE2_sepZone4_iff M a w x t a
        (false, false) (false, true) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_irrefl a) (by decide), iff_of_false (lt_irrefl a) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hwa) (by decide), iff_of_true hwa rfl⟩,
        ⟨iff_of_false (lt_asymm hxa) (by decide), iff_of_true hxa rfl⟩,
        ⟨iff_of_true hat rfl, iff_of_false (lt_asymm hat) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtX1R χ = true :=
      (h_zone kvE2_sep_zAtX1R χ).mp ⟨a, hz, (hcb χ a).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- **LEFT anchor point-type honesty** (Phase 4): a LEFT-interior owner σ's folded fresh point
    type `kvE2_sepPtX1L` evaluates at its own honest anchor value. Head = the `charK`-projected
    fresh type (`kvE2_sepProjFresh_eval` + `hck`); the base literals ride the CLOSED `zAtX1L`
    self-zone reads (`kvE2_sepOwnerLit_zAtX1L`). -/
theorem kvE2_sepPtX1L_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    (hz : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap
      (kvE2_sepAnchorVal qnf M w x t h σ) := by
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  have hbundle := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz
  simp only [kvE2_sepPtX1L, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_cons.mp hf with rfl | hf
  · exact (hck _ _).mpr (kvE2_sepProjFresh_eval M _ _ σ hspec)
  · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    exact kvE2_sepOwnerLit_zAtX1L charBase M atomMap σ _ w x t hbundle.1 hbundle.2.1 hwt hspec hcb χ

/-- **RIGHT anchor point-type honesty** (Phase 4, mirror of `kvE2_sepPtX1L_eval_of_honest`). -/
theorem kvE2_sepPtX1R_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    (hz : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap
      (kvE2_sepAnchorVal qnf M w x t h σ) := by
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  have hbundle := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz
  simp only [kvE2_sepPtX1R, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_cons.mp hf with rfl | hf
  · exact (hck _ _).mpr (kvE2_sepProjFresh_eval M _ _ σ hspec)
  · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    exact kvE2_sepOwnerLit_zAtX1R charBase M atomMap σ _ w x t hbundle.1 hbundle.2.1 hxw hspec hcb χ

/-- **Per-slot point-type honesty** (Phase 4): every slot of a positive owner's block realizes
    its slot point type AT its own honest slot value. Base slots ride `hcb` + the banked value
    specs; anchor slots ride the folded fresh point types above. -/
theorem kvE2_sepSlotType_eval_at_value {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    (kvE2_sepSlotType charBase charK s).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s) := by
  rw [kvE2_sepMem_slotBlock] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_pos hz1, if_pos hz1] at hs
    rcases hs with hL | hR
    · rcases List.mem_append.mp hL with h1 | h1
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
        simp only [kvE2_sepSlotType, TemporalPred.eval_at]
        exact (hcb χ _).mpr
          (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ).2.2
      · rcases List.mem_cons.mp h1 with rfl | h1
        · rw [kvE2_sepSlotValue_lX1]
          exact kvE2_sepPtX1L_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h
            hcb hck hσ hz1
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotType, TemporalPred.eval_at]
          exact (hcb χ _).mpr
            (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ).2.2
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hR
      simp only [kvE2_sepSlotType, TemporalPred.eval_at]
      exact (hcb χ _).mpr
        (kvE2_sepSlotValue_lWT_spec qnf M w x t h σ hσ χ hχ).2.2
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_pos hz2, if_pos hz2] at hs
      rcases hs with hL | hR
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hL
        simp only [kvE2_sepSlotType, TemporalPred.eval_at]
        exact (hcb χ _).mpr
          (kvE2_sepSlotValue_rXW_spec qnf M w x t h σ hσ χ hχ).2.2
      · rcases List.mem_append.mp hR with h1 | h1
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotType, TemporalPred.eval_at]
          exact (hcb χ _).mpr
            (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ).2.2
        · rcases List.mem_cons.mp h1 with rfl | h1
          · rw [kvE2_sepSlotValue_rX1]
            exact kvE2_sepPtX1R_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h
              hcb hck hσ hz2
          · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
            simp only [kvE2_sepSlotType, TemporalPred.eval_at]
            exact (hcb χ _).mpr
              (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ).2.2
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_neg hz2, if_neg hz2] at hs
      simp only [List.not_mem_nil, or_self] at hs

/-- **LEFT class point-type honesty** (Phase 4 / O2): a primed grouped LEFT tie class realizes
    its meet-folded class type at the honest value of any of its members (all members share the
    value, `kvE2_sepTieGroupedL_value_const`). Feeds the `hptL` obligation of
    `kvE2_sepBracketN_construct`. -/
theorem kvE2_sepTieGroupedL_classType_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
    {s0 : KvE2SepSlot sig} (hs0 : s0 ∈ c) :
    (kvE2_sepClassType charBase charK c).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s0) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepClassType_eval_iff]
  intro s hs
  rw [kvE2_sepTieGroupedL_value_const qnf M w x t h hc hs0 hs]
  have hsf : s ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c, hc, hs⟩
  obtain ⟨σ, hσ, hsσ⟩ := kvE2_sepSlotsLOf_mem_block hwo hsf
  exact kvE2_sepSlotType_eval_at_value charBase charK qnf M atomMap w x t hxw hwt h hcb hck
    (kvE2_sepPosI_subset hσ) hsσ

/-- **RIGHT class point-type honesty** (Phase 4 / O2, mirror of
    `kvE2_sepTieGroupedL_classType_eval`). -/
theorem kvE2_sepTieGroupedR_classType_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))
    {s0 : KvE2SepSlot sig} (hs0 : s0 ∈ c) :
    (kvE2_sepClassType charBase charK c).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s0) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepClassType_eval_iff]
  intro s hs
  rw [kvE2_sepTieGroupedR_value_const qnf M w x t h hc hs0 hs]
  have hsf : s ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c, hc, hs⟩
  obtain ⟨σ, hσ, hsσ⟩ := kvE2_sepSlotsROf_mem_block hwo hsf
  exact kvE2_sepSlotType_eval_at_value charBase charK qnf M atomMap w x t hxw hwt h hcb hck
    (kvE2_sepPosI_subset hσ) hsσ

/-! ### O3(a): honest segment-evaluation family (standalone)

No banked completeness-direction segment-eval lemma exists, so these are NEW. The core reads the
owners' universal (β) layer of `h`: a per-σ exclusion segment `kvE2_sepSegForm σ zs` holds at any
interior point `y` that sits in σ's zone `zs` (relative to σ's honest anchor value), because a
bit-FALSE 1-type realized there would force the fold bit TRUE (contradiction). Everything is
generic in `y` and its zone position (Cor 5.4, PDF p.5: exclusion throughout every realized
refined sub-interval). LITMUS-clean: all bounds ride `x`/`w`/`t` + the anchor value, never an
owner-to-owner chain. -/

/-- **Segment-exclusion honesty (core)** (Phase 5): under an honest owner realization at
    `[a, w, x, t]`, if `y` lies in σ's zone `zs`, then σ's exclusion segment
    `kvE2_sepSegForm σ zs` is realized at `y` — every bit-FALSE 1-type is excluded there. -/
theorem kvE2_sepSegForm_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hspec : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (zs : ZoneSpec 4) (y : M.carrier)
    (hy : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs y) :
    temporal_truth M atomMap y (kvE2_sepSegForm charBase σ zs) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hspec
  simp only [kvE2_sepSegForm]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
  cases hbit : kvE2_sepBits σ zs χ with
  | true =>
    change temporal_truth M atomMap y Formula.top
    exact temporal_truth_top M atomMap y
  | false =>
    change temporal_truth M atomMap y (charBase χ).neg
    simp only [Formula.neg, temporal_truth]
    intro hch
    have hbt : kvE2_sepBits σ zs χ = true :=
      (h_zone zs χ).mp ⟨y, hy, (hcb χ y).mp hch⟩
    rw [hbit] at hbt
    exact Bool.noConfusion hbt

/-- **LEFT refined-segment honesty at a cut** (Phase 5): the LEFT-region refined-conjunction
    segment `kvE2_sepSegLAt lL i` is realized at any interior `y ∈ (x, w)` whose position relative
    to each left-interior owner's honest anchor matches the cut's structural read (`hbridge`).
    Right-interior owners contribute the uniform `(x, w)` (`kvE_sub2_zXU`) exclusion, discharged
    internally from `w < a`. Generic in `y` and `hbridge`; Phase 6 supplies the bridge from the
    class order. -/
theorem kvE2_sepSegLAt_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (lL : List (KvE2SepSlot sig)) (i : Nat) (y : M.carrier) (hxy : x < y) (hyw : y < w)
    (hbridge : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ((lL.take i).contains (.lX1 σ) = true → kvE2_sepAnchorVal qnf M w x t h σ < y) ∧
      ((lL.take i).contains (.lX1 σ) = false → y < kvE2_sepAnchorVal qnf M w x t h σ)) :
    (kvE2_sepSegLAt charBase qnf lL i).eval_at M atomMap y := by
  have hyt : y < t := hyw.trans hwt
  simp only [kvE2_sepSegLAt, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp hf
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  simp only [kvE2_sepSegLForSub]
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1]
    have hbr := hbridge σ hσ hz1
    by_cases hcon : (lL.take i).contains (.lX1 σ) = true
    · rw [if_pos hcon]
      have hay := hbr.1 hcon
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (false, true) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hcon]
      have hya := hbr.2 (Bool.eq_false_iff.mpr hcon)
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (true, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2]
      have hbnd := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2
      have hya : y < kvE2_sepAnchorVal qnf M w x t h σ := hyw.trans hbnd.1
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (true, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hz1, if_neg hz2]
      exact temporal_truth_top M atomMap y

/-- **RIGHT refined-segment honesty at a cut** (Phase 5, mirror of `kvE2_sepSegLAt_eval_of_honest`):
    the RIGHT-region segment `kvE2_sepSegRAt lR j` is realized at any interior `y ∈ (w, t)` whose
    position relative to each right-interior owner's honest anchor matches the cut's structural
    read (`hbridge`). Left-interior owners contribute the uniform `(w, t)` (`kvE_sub2_zWT`)
    exclusion, discharged internally from `a < w`. -/
theorem kvE2_sepSegRAt_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (lR : List (KvE2SepSlot sig)) (j : Nat) (y : M.carrier) (hwy : w < y) (hyt : y < t)
    (hbridge : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ((lR.take j).contains (.rX1 σ) = true → kvE2_sepAnchorVal qnf M w x t h σ < y) ∧
      ((lR.take j).contains (.rX1 σ) = false → y < kvE2_sepAnchorVal qnf M w x t h σ)) :
    (kvE2_sepSegRAt charBase qnf lR j).eval_at M atomMap y := by
  have hxy : x < y := hxw.trans hwy
  simp only [kvE2_sepSegRAt, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp hf
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  simp only [kvE2_sepSegRForSub]
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1]
    have hbnd := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1
    have hay : kvE2_sepAnchorVal qnf M w x t h σ < y := hbnd.2.1.trans hwy
    apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
    refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
      (false, true) (false, true) (false, true) (true, false)).mpr ?_
    exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
      ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
      ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
      ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2]
      have hbr := hbridge σ hσ hz2
      by_cases hcon : (lR.take j).contains (.rX1 σ) = true
      · rw [if_pos hcon]
        have hay := hbr.1 hcon
        apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
        refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
          (false, true) (false, true) (false, true) (true, false)).mpr ?_
        exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
          ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
          ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
          ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
      · rw [if_neg hcon]
        have hya := hbr.2 (Bool.eq_false_iff.mpr hcon)
        apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
        refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
          (true, false) (false, true) (false, true) (true, false)).mpr ?_
        exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
          ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
          ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
          ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hz1, if_neg hz2]
      exact temporal_truth_top M atomMap y

/-! ### O3(b): gap discharge (the class-order bridge)

The Phase-5 segment family (`kvE2_sepSegLAt_eval_of_honest` / `…RAt…`) takes a per-owner
position bridge as a hypothesis. Phase 6 supplies that bridge from the class value order
(Phase 3): for a point `y` strictly between consecutive grouped-class witnesses, the anchor
slot `.lX1 σ` of a same-region owner sits in the flat prefix of the first `n` classes iff its
honest anchor value is below `y`. Reindexing `gL.flatten.take FC` to `(gL.take n).flatten`
(`kvE2_sep_take_flatten_prefix`) plus prefix/suffix value separation (`kvE2_sep_flatten_sep`)
reduce the bridge to two value-comparison hypotheses (`hprefix`/`hsuffix`) discharged in the
Phase-7 assembly from the gap bounds. LITMUS-clean: all bounds ride the anchor value and `y`,
never an owner-to-owner chain. -/

/-- Generic: the flat prefix of the first `n` sublists equals `flatten.take` at the prefix's
    own flattened length (whole-sublist cut alignment). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (I,J).
theorem kvE2_sep_take_flatten_prefix {α : Type*} (L : List (List α)) (n : Nat) :
    (L.take n).flatten = L.flatten.take ((L.take n).flatten.length) := by
  induction L generalizing n with
  | nil => simp
  | cons a rest ih =>
    cases n with
    | zero => simp
    | succ m =>
      simp only [List.take_succ_cons, List.flatten_cons, List.length_append]
      rw [List.take_append, List.take_of_length_le (Nat.le_add_right _ _),
        Nat.add_sub_cancel_left, ← ih m]

/-- Generic: on a list of sublists whose blocks are strictly `R`-separated across the list
    (`Pairwise` of the cross-block order), every element of the first-`n` prefix relates by `R`
    to every element of the drop-`n` suffix. The value-separation kernel for the bridge. -/
private theorem kvE2_sep_flatten_sep {α : Type*} (R : α → α → Prop) (L : List (List α))
    (hmono : L.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, R u v)) (n : Nat) :
    ∀ s ∈ (L.take n).flatten, ∀ s' ∈ (L.drop n).flatten, R s s' := by
  intro s hs s' hs'
  obtain ⟨c₁, hc₁, hsc₁⟩ := List.mem_flatten.mp hs
  obtain ⟨c₂, hc₂, hs'c₂⟩ := List.mem_flatten.mp hs'
  have hpw : (L.take n ++ L.drop n).Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, R u v) := by
    rw [List.take_append_drop]; exact hmono
  exact (List.pairwise_append.mp hpw).2.2 c₁ hc₁ c₂ hc₂ s hsc₁ s' hs'c₂

/-- **LEFT gap discharge** (Phase 6 / O3(b)): the LEFT grouped segment at grouped cut `n` is
    realized at any interior `y ∈ (x, w)` whose relation to the class values is fixed by the two
    gap hypotheses `hprefix` (first-`n` classes' slot values below `y`) and `hsuffix` (later
    classes' slot values above `y`). Builds the Phase-5 bridge for `kvE2_sepSegLAt_eval_of_honest`
    from those two facts. -/
theorem kvE2_sepSegLAt_gap_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (_charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (n : Nat) (y : M.carrier) (hxy : x < y) (hyw : y < w)
    (hprefix : ∀ s ∈ ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten,
      kvE2_sepSlotValue qnf M w x t h s < y)
    (hsuffix : ∀ s ∈ ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).drop n).flatten,
      y < kvE2_sepSlotValue qnf M w x t h s) :
    (kvE2_sepSegLAt charBase qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).flatten
        (((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten.length)
      ).eval_at M atomMap y := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gL := kvE2_sepTieGroupedL wo with hgL_def
  apply kvE2_sepSegLAt_eval_of_honest charBase qnf M atomMap w x t hxw hwt h hcb
    gL.flatten ((gL.take n).flatten.length) y hxy hyw
  intro σ hσ hz
  rw [← kvE2_sep_take_flatten_prefix gL n]
  have hval : kvE2_sepSlotValue qnf M w x t h (.lX1 σ) = kvE2_sepAnchorVal qnf M w x t h σ :=
    kvE2_sepSlotValue_lX1 qnf M w x t h σ
  refine ⟨fun hc => ?_, fun hc => ?_⟩
  · have hmem : (KvE2SepSlot.lX1 σ) ∈ (gL.take n).flatten := List.contains_iff_mem.mp hc
    rw [← hval]; exact hprefix _ hmem
  · have hnmem : (KvE2SepSlot.lX1 σ) ∉ (gL.take n).flatten := by
      intro hm; rw [List.contains_iff_mem.mpr hm] at hc; exact Bool.noConfusion hc
    have hallmem : (KvE2SepSlot.lX1 σ) ∈ gL.flatten := by
      rw [hgL_def, kvE2_sepTieGroupedL_flatten]
      exact kvE2_sepSlotsLOf_mem qnf (kvE2_sepHonestOrder'_mem_orderTypes qnf M w x t h)
        ((kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, Or.inl hz⟩) (kvE2_sep_lX1_mem_slotsLFor hz)
    have hsplit : gL.flatten = (gL.take n).flatten ++ (gL.drop n).flatten := by
      rw [← List.flatten_append, List.take_append_drop]
    rw [hsplit, List.mem_append] at hallmem
    rw [← hval]; exact hsuffix _ (hallmem.resolve_left hnmem)

/-- **RIGHT gap discharge** (Phase 6 / O3(b), mirror of `kvE2_sepSegLAt_gap_eval`): the RIGHT
    grouped segment at grouped cut `n` is realized at any interior `y ∈ (w, t)` fixed by the
    two RIGHT gap hypotheses. -/
theorem kvE2_sepSegRAt_gap_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (_charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (n : Nat) (y : M.carrier) (hwy : w < y) (hyt : y < t)
    (hprefix : ∀ s ∈ ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten,
      kvE2_sepSlotValue qnf M w x t h s < y)
    (hsuffix : ∀ s ∈ ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).drop n).flatten,
      y < kvE2_sepSlotValue qnf M w x t h s) :
    (kvE2_sepSegRAt charBase qnf
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).flatten
        (((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten.length)
      ).eval_at M atomMap y := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gR := kvE2_sepTieGroupedR wo with hgR_def
  apply kvE2_sepSegRAt_eval_of_honest charBase qnf M atomMap w x t hxw hwt h hcb
    gR.flatten ((gR.take n).flatten.length) y hwy hyt
  intro σ hσ hz
  rw [← kvE2_sep_take_flatten_prefix gR n]
  have hval : kvE2_sepSlotValue qnf M w x t h (.rX1 σ) = kvE2_sepAnchorVal qnf M w x t h σ :=
    kvE2_sepSlotValue_rX1 qnf M w x t h σ
  refine ⟨fun hc => ?_, fun hc => ?_⟩
  · have hmem : (KvE2SepSlot.rX1 σ) ∈ (gR.take n).flatten := List.contains_iff_mem.mp hc
    rw [← hval]; exact hprefix _ hmem
  · have hnmem : (KvE2SepSlot.rX1 σ) ∉ (gR.take n).flatten := by
      intro hm; rw [List.contains_iff_mem.mpr hm] at hc; exact Bool.noConfusion hc
    have hallmem : (KvE2SepSlot.rX1 σ) ∈ gR.flatten := by
      rw [hgR_def, kvE2_sepTieGroupedR_flatten]
      exact kvE2_sepSlotsROf_mem qnf (kvE2_sepHonestOrder'_mem_orderTypes qnf M w x t h)
        ((kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, Or.inr hz⟩) (kvE2_sep_rX1_mem_slotsRFor hz)
    have hsplit : gR.flatten = (gR.take n).flatten ++ (gR.drop n).flatten := by
      rw [← List.flatten_append, List.take_append_drop]
    rw [hsplit, List.mem_append] at hallmem
    rw [← hval]; exact hsuffix _ (hallmem.resolve_left hnmem)

/-! ### O4: assembly (per-class witness list + the two public theorems)

The generic list helpers below build the per-class honest value list `usL`/`usR`
(one value per tie class, via `attach`+`head`), giving length, getElem, membership, and
prefix/suffix value-separation from the class strict order. They isolate the `attach`/`getElem`
mechanics from the model content so the bracket assembly reads at the class level. -/

/-- Generic: `gL[k] ∈ gL.drop k`. -/
private theorem kvE2_sep_getElem_mem_drop {α : Type*} (gL : List (List α)) (k : Nat)
    (hk : k < gL.length) : gL[k]'hk ∈ gL.drop k := by
  rw [List.drop_eq_getElem_cons hk]; exact List.mem_cons_self

/-- Generic: length of the per-class value list built by `attach`+`head`. -/
private theorem kvE2_sep_usOf_length {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) :
    (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))).length = gL.length := by
  rw [List.length_map, List.length_attach]

/-- Generic: the `k`-th per-class value is `Vf` of the `k`-th class's head. -/
private theorem kvE2_sep_usOf_getElem {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) (k : Nat)
    (hk : k < (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))).length) :
    (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2))))[k]'hk
      = Vf ((gL[k]'(by simpa using hk)).head (hne _ (List.getElem_mem _))) := by
  rw [List.getElem_map, List.getElem_attach]

/-- Generic: every value of the per-class list is `Vf` of a member of some class. -/
private theorem kvE2_sep_usOf_mem {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) {b : β} (hb : b ∈ gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))) :
    ∃ c ∈ gL, ∃ s ∈ c, b = Vf s := by
  obtain ⟨p, _, hpb⟩ := List.mem_map.mp hb
  exact ⟨p.1, p.2, p.1.head (hne p.1 p.2), List.head_mem _, hpb.symm⟩

/-- Generic prefix value bound: on a class-strictly-`<`-ordered list, all slots of the first `n`
    classes have `Vf` below `y`, given the `(n-1)`-th (boundary) class does. -/
private theorem kvE2_sep_take_flatten_lt {α β : Type*} [Preorder β] (Vf : α → β)
    (gL : List (List α))
    (hmono : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v))
    (hne : ∀ c ∈ gL, c ≠ [])
    (n : Nat) (hn1 : 1 ≤ n) (hn : n ≤ gL.length) (y : β)
    (hbnd : ∀ s ∈ gL[n - 1]'(by omega), Vf s < y) :
    ∀ s ∈ (gL.take n).flatten, Vf s < y := by
  intro s hs
  have hsplit : (gL.take n).flatten = (gL.take (n-1)).flatten ++ gL[n-1]'(by omega) := by
    rw [show gL.take n = gL.take (n-1) ++ [gL[n-1]'(by omega)] from by
      conv_lhs => rw [show n = (n-1)+1 by omega]
      rw [List.take_add_one]; congr 1; rw [List.getElem?_eq_getElem (by omega)]; rfl]
    rw [List.flatten_append]; simp
  rw [hsplit, List.mem_append] at hs
  rcases hs with hs | hs
  · have hbmem : gL[n-1]'(by omega) ∈ gL.drop (n-1) := kvE2_sep_getElem_mem_drop gL (n-1) (by omega)
    have hs0 : (gL[n-1]'(by omega)).head (hne _ (List.getElem_mem _)) ∈ gL[n-1]'(by omega) :=
      List.head_mem _
    have hlt := kvE2_sep_flatten_sep (fun a b => Vf a < Vf b) gL hmono (n-1) s hs _
      (List.mem_flatten.mpr ⟨_, hbmem, hs0⟩)
    exact lt_trans hlt (hbnd _ hs0)
  · exact hbnd s hs

/-- Generic suffix value bound: on a class-strictly-`<`-ordered list, all slots of the classes from
    `n` onward have `Vf` above `y`, given the `n`-th (boundary) class does. -/
private theorem kvE2_sep_drop_flatten_gt {α β : Type*} [Preorder β] (Vf : α → β)
    (gL : List (List α))
    (hmono : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v))
    (hne : ∀ c ∈ gL, c ≠ [])
    (n : Nat) (hn : n < gL.length) (y : β)
    (hbnd : ∀ s ∈ gL[n]'hn, y < Vf s) :
    ∀ s ∈ (gL.drop n).flatten, y < Vf s := by
  intro s hs
  have hsplit : gL.drop n = gL[n]'hn :: gL.drop (n+1) := by rw [List.drop_eq_getElem_cons hn]
  rw [hsplit, List.flatten_cons, List.mem_append] at hs
  rcases hs with hs | hs
  · exact hbnd s hs
  · have hbmem : gL[n]'hn ∈ gL.take (n+1) := by
      have h1 : (gL.take (n+1))[n]'(by rw [List.length_take]; omega) = gL[n]'hn := by
        rw [List.getElem_take]
      rw [← h1]; exact List.getElem_mem _
    have hs0 : (gL[n]'hn).head (hne _ (List.getElem_mem _)) ∈ gL[n]'hn := List.head_mem _
    have hlt := kvE2_sep_flatten_sep (fun a b => Vf a < Vf b) gL hmono (n+1) _
      (List.mem_flatten.mpr ⟨_, hbmem, hs0⟩) s hs
    exact lt_trans (hbnd _ hs0) hlt

/-- **Grouped bracket realization under honesty** (Phase 7 / O4): the meet-folded grouped bracket
    of the primed honest order is realized on `(x, t)`. Builds the per-class honest witness lists
    `usL`/`usR` (one value per tie class), discharges the strict order (O1), range, point types
    (O2), and per-gap segments (O3) into the private N-slot engine `kvE2_sepBracketN_construct`. -/
theorem kvE2_sepBracket_holds_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepBracketN
        ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).map
          (kvE2_sepClassType charBase charK))
        (kvE2_sepPtW charBase charK qnf)
        ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).map
          (kvE2_sepClassType charBase charK))
        (kvE2_sepSegsG charBase qnf
          (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
          (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)))
      ).holds M atomMap x t := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gL := kvE2_sepTieGroupedL wo with hgL_def
  set gR := kvE2_sepTieGroupedR wo with hgR_def
  set Vf := kvE2_sepSlotValue qnf M w x t h with hVf_def
  have hneL : ∀ c ∈ gL, c ≠ [] := kvE2_sepTieGroupedL_ne_nil wo
  have hneR : ∀ c ∈ gR, c ≠ [] := kvE2_sepTieGroupedR_ne_nil wo
  have hmonoL : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v) :=
    kvE2_sepTieGroupedL_strictMono qnf M w x t h
  have hmonoR : gR.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v) :=
    kvE2_sepTieGroupedR_strictMono qnf M w x t h
  have hbndL : ∀ s ∈ gL.flatten, x < Vf s ∧ Vf s < w := fun s hs =>
    kvE2_sepSlotsLOf_honestOrder'_value_bound qnf M w x t hxw hwt h
      (by rw [← kvE2_sepTieGroupedL_flatten wo]; exact hs)
  have hbndR : ∀ s ∈ gR.flatten, w < Vf s ∧ Vf s < t := fun s hs =>
    kvE2_sepSlotsROf_honestOrder'_value_bound qnf M w x t hxw hwt h
      (by rw [← kvE2_sepTieGroupedR_flatten wo]; exact hs)
  have hUL_len : (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2)))).length = gL.length :=
    kvE2_sep_usOf_length gL hneL Vf
  have hUR_len : (gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2)))).length = gR.length :=
    kvE2_sep_usOf_length gR hneR Vf
  have huslen : (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2))) ++ w ::
      gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2)))).length = gL.length + gR.length +
          1 := by
    rw [List.length_append, List.length_cons, hUL_len, hUR_len]; omega
  -- LEFT segment discharger from boundary class values
  have segL : ∀ (n : Nat) (hn : n ≤ gL.length) (yv : M.carrier) (hxy : x < yv) (hyw : yv < w),
      (∀ (_ : 0 < n), ∀ s ∈ gL[n-1]'(by omega), Vf s < yv) →
      (∀ (hlt : n < gL.length), ∀ s ∈ gL[n]'hlt, yv < Vf s) →
      (kvE2_sepSegsG charBase qnf gL gR n).eval_at M atomMap yv := by
    intro n hn yv hxy hyw hpre hsuf
    rw [kvE2_sepSegsG, if_pos hn]
    apply kvE2_sepSegLAt_gap_eval charBase charK qnf M atomMap w x t hxw hwt h hcb n yv hxy hyw
    · rcases Nat.eq_zero_or_pos n with h0 | hpos
      · subst h0; intro s hs; simp only [List.take_zero, List.flatten_nil, List.not_mem_nil] at hs
      · exact kvE2_sep_take_flatten_lt Vf gL hmonoL hneL n hpos hn yv (hpre hpos)
    · rcases Nat.lt_or_ge n gL.length with hlt | hge
      · exact kvE2_sep_drop_flatten_gt Vf gL hmonoL hneL n hlt yv (hsuf hlt)
      · have hEq : n = gL.length := le_antisymm hn hge
        subst hEq; intro s hs
        rw [List.drop_length, List.flatten_nil] at hs; exact absurd hs List.not_mem_nil
  -- RIGHT segment discharger from boundary class values
  have segR : ∀ (n : Nat) (hn : n ≤ gR.length) (yv : M.carrier) (hwy : w < yv) (hyt : yv < t),
      (∀ (_ : 0 < n), ∀ s ∈ gR[n-1]'(by omega), Vf s < yv) →
      (∀ (hlt : n < gR.length), ∀ s ∈ gR[n]'hlt, yv < Vf s) →
      (kvE2_sepSegsG charBase qnf gL gR (gL.length + 1 + n)).eval_at M atomMap yv := by
    intro n hn yv hwy hyt hpre hsuf
    rw [kvE2_sepSegsG, if_neg (by omega), show gL.length + 1 + n - gL.length - 1 = n by omega]
    apply kvE2_sepSegRAt_gap_eval charBase charK qnf M atomMap w x t hxw hwt h hcb n yv hwy hyt
    · rcases Nat.eq_zero_or_pos n with h0 | hpos
      · subst h0; intro s hs; simp only [List.take_zero, List.flatten_nil, List.not_mem_nil] at hs
      · exact kvE2_sep_take_flatten_lt Vf gR hmonoR hneR n hpos hn yv (hpre hpos)
    · rcases Nat.lt_or_ge n gR.length with hlt | hge
      · exact kvE2_sep_drop_flatten_gt Vf gR hmonoR hneR n hlt yv (hsuf hlt)
      · have hEq : n = gR.length := le_antisymm hn hge
        subst hEq; intro s hs
        rw [List.drop_length, List.flatten_nil] at hs; exact absurd hs List.not_mem_nil
  refine kvE2_sepBracketN_construct M atomMap _ _ _ _ x w t
    (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2))))
    (gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2))))
    (by rw [hUL_len, List.length_map]) (by rw [hUR_len, List.length_map])
    ?hsort ?hrange ?hptL ?hptW ?hptR ?hseg0 ?hsegmid ?hseglast
  case hsort =>
    refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
    · rw [List.pairwise_iff_getElem]
      intro a b ha hb hab
      have haL : a < gL.length := by rw [hUL_len] at ha; exact ha
      have hbL : b < gL.length := by rw [hUL_len] at hb; exact hb
      rw [kvE2_sep_usOf_getElem gL hneL Vf a ha, kvE2_sep_usOf_getElem gL hneL Vf b hb]
      exact List.pairwise_iff_getElem.mp hmonoL a b haL hbL hab _ (List.head_mem _) _
          (List.head_mem _)
    · rw [List.pairwise_cons]
      refine ⟨fun b hb => ?_, ?_⟩
      · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hb
        exact (hbndR s (List.mem_flatten.mpr ⟨c, hc, hs⟩)).1
      · rw [List.pairwise_iff_getElem]
        intro a b ha hb hab
        have haR : a < gR.length := by rw [hUR_len] at ha; exact ha
        have hbR : b < gR.length := by rw [hUR_len] at hb; exact hb
        rw [kvE2_sep_usOf_getElem gR hneR Vf a ha, kvE2_sep_usOf_getElem gR hneR Vf b hb]
        exact List.pairwise_iff_getElem.mp hmonoR a b haR hbR hab _ (List.head_mem _) _
          (List.head_mem _)
    · intro a ha b hb
      obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gL hneL Vf ha
      have haw : Vf s < w := (hbndL s (List.mem_flatten.mpr ⟨c, hc, hs⟩)).2
      rw [List.mem_cons] at hb
      rcases hb with rfl | hb
      · exact haw
      · obtain ⟨c', hc', s', hs', rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hb
        exact haw.trans (hbndR s' (List.mem_flatten.mpr ⟨c', hc', hs'⟩)).1
  case hrange =>
    intro u hu
    rw [List.mem_append, List.mem_cons] at hu
    rcases hu with hu | (rfl | hu)
    · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gL hneL Vf hu
      have hb := hbndL s (List.mem_flatten.mpr ⟨c, hc, hs⟩)
      exact ⟨hb.1, hb.2.trans hwt⟩
    · exact ⟨hxw, hwt⟩
    · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hu
      have hb := hbndR s (List.mem_flatten.mpr ⟨c, hc, hs⟩)
      exact ⟨hxw.trans hb.1, hb.2⟩
  case hptL =>
    intro i hi
    have hiL : i < gL.length := by rw [List.length_map] at hi; exact hi
    rw [List.getElem_map, List.getElem_map, List.getElem_attach]
    exact kvE2_sepTieGroupedL_classType_eval charBase charK qnf M atomMap w x t hxw hwt h hcb hck
      (List.getElem_mem hiL) (List.head_mem _)
  case hptW =>
    exact kvE2_sepPtW_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  case hptR =>
    intro j hj
    have hjR : j < gR.length := by rw [List.length_map] at hj; exact hj
    rw [List.getElem_map, List.getElem_map, List.getElem_attach]
    exact kvE2_sepTieGroupedR_classType_eval charBase charK qnf M atomMap w x t hxw hwt h hcb hck
      (List.getElem_mem hjR) (List.head_mem _)
  case hseg0 =>
    intro y hxy hy0
    apply segL 0 (Nat.zero_le _) y hxy ?_ ?_ ?_
    · rcases Nat.eq_zero_or_pos gL.length with h0 | hpos
      · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hy0
        simp only [hUL_len] at hy0
        rw [getElem_congr_idx (show (0 : Nat) - gL.length = 0 by omega),
          List.getElem_cons_zero] at hy0
        exact hy0
      · rw [List.getElem_append_left (by rw [hUL_len]; exact hpos), List.getElem_map,
          List.getElem_attach] at hy0
        exact lt_trans hy0
          (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hpos, List.head_mem _⟩)).2
    · intro hcontra; exact absurd hcontra (lt_irrefl 0)
    · intro hpos s hs
      rw [List.getElem_append_left (by rw [hUL_len]; exact hpos), List.getElem_map,
        List.getElem_attach] at hy0
      simp only [hVf_def]
      rw [kvE2_sepTieGroupedL_value_const qnf M w x t h (List.getElem_mem hpos) hs
        (List.head_mem _)]
      exact hy0
  case hsegmid =>
    intro i hi y hlo hhi
    rw [huslen] at hi
    rcases Nat.lt_or_ge i gL.length with hiL | hiG
    · -- LEFT gap
      rw [List.getElem_append_left (by rw [hUL_len]; exact hiL), List.getElem_map,
        List.getElem_attach] at hlo
      have hxlt : x < y := lt_trans
        (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hiL, List.head_mem _⟩)).1 hlo
      apply segL (i + 1) (by omega) y hxlt ?_ ?_ ?_
      · rcases Nat.lt_or_ge (i + 1) gL.length with hi1 | hi1
        · rw [List.getElem_append_left (by rw [hUL_len]; exact hi1), List.getElem_map,
            List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hi1, List.head_mem _⟩)).2
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 by omega),
            List.getElem_cons_zero] at hhi
          exact hhi
      · intro _ s hs
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedL_value_const qnf M w x t h
          (List.getElem_mem (show i < gL.length by omega)) hs (List.head_mem _)]
        exact hlo
      · intro hi1 s hs
        rw [List.getElem_append_left (by rw [hUL_len]; exact hi1), List.getElem_map,
          List.getElem_attach] at hhi
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedL_value_const qnf M w x t h (List.getElem_mem hi1) hs
          (List.head_mem _)]
        exact hhi
    · -- RIGHT gap
      rw [show i + 1 = gL.length + 1 + (i - gL.length) by omega]
      rcases lt_or_eq_of_le hiG with hig | hie
      · -- i > gL.length
        apply segR (i - gL.length) (by omega) y ?_ ?_ ?_ ?_
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = (i - gL.length - 1) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlo
          exact lt_trans
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show i - gL.length - 1 < gR.length by omega), List.head_mem _⟩)).1 hlo
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = (i - gL.length) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show i - gL.length < gR.length by omega), List.head_mem _⟩)).2
        · intro _ s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = (i - gL.length - 1) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlo
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h
            (List.getElem_mem (show i - gL.length - 1 < gR.length by omega)) hs (List.head_mem _)]
          exact hlo
        · intro hlt s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = (i - gL.length) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h (List.getElem_mem hlt) hs
            (List.head_mem _)]
          exact hhi
      · -- i = gL.length (pivot on the left of the gap)
        rw [show i - gL.length = 0 by omega]
        apply segR 0 (Nat.zero_le _) y ?_ ?_ ?_ ?_
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = 0 by omega), List.getElem_cons_zero] at hlo
          exact hlo
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show 0 < gR.length by omega), List.head_mem _⟩)).2
        · intro hcontra; exact absurd hcontra (lt_irrefl 0)
        · intro hgRpos s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h (List.getElem_mem hgRpos) hs
            (List.head_mem _)]
          exact hhi
  case hseglast =>
    intro y hlast hyt
    rw [huslen]
    simp only [huslen, Nat.add_sub_cancel] at hlast
    rw [show gL.length + gR.length + 1 = gL.length + 1 + gR.length by omega]
    rcases Nat.eq_zero_or_pos gR.length with h0 | hpos
    · -- gR empty: the last witness is the pivot `w`
      rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlast
      simp only [hUL_len] at hlast
      rw [getElem_congr_idx (show gL.length + gR.length - gL.length = 0 by omega),
        List.getElem_cons_zero] at hlast
      apply segR gR.length (le_refl _) y hlast hyt ?_ ?_
      · intro hcontra; exact absurd (h0 ▸ hcontra) (lt_irrefl 0)
      · intro hlt; exact absurd hlt (lt_irrefl _)
    · -- gR nonempty: last witness is the last right class value
      rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlast
      simp only [hUL_len] at hlast
      rw [getElem_congr_idx (show gL.length + gR.length - gL.length = (gR.length - 1) + 1 by omega),
        List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlast
      apply segR gR.length (le_refl _) y ?_ hyt ?_ ?_
      · exact lt_trans
          (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
            (show gR.length - 1 < gR.length by omega), List.head_mem _⟩)).1 hlast
      · intro _ s hs
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedR_value_const qnf M w x t h
          (List.getElem_mem (show gR.length - 1 < gR.length by omega)) hs (List.head_mem _)]
        exact hlast
      · intro hlt; exact absurd hlt (lt_irrefl _)

/-- **The §2.1 target: grouped multi-owner disjunct `.holds` builder**:
    under an honest evaluation of `qnf` at `[w, x, t]`, the meet-folded grouped joint disjunct of
    the tie-reporting primed order `kvE2_sepHonestOrder'` is realized on `(x, t)`. Assembles the
    two endpoints (Phase-8 pack) and the grouped bracket (`kvE2_sepBracket_holds_of_honest`) into
    the `VecEA2.holds` triple. Consumes the PRIMED order at the target site (tie-admitting). -/
theorem kvE2_sepDisjunct'_holds_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))).2.holds M atomMap x t := by
  refine ⟨?_, ?_, ?_⟩
  · exact kvE2_sepEpL_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  · exact kvE2_sepEpR_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  · exact kvE2_sepBracket_holds_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck

/-- **Body corollary** (consumed downstream): the joint-disjunct body
    formula `kvE2_sepBody` is realized on `(x, t)` under honesty, by feeding the §2.1 builder into
    the target completeness statement `kvE2_sepBody_complete_holds'` (which consumes the PRIMED
    tie-grouped disjunct). -/
theorem kvE2_sepBody_holds_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t :=
  kvE2_sepBody_complete_holds' charBase charK qnf hg M atomMap w x t hxw hwt h
    (kvE2_sepDisjunct'_holds_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck)

end Bimodal.Metalogic.WeakCanonical.Kamp

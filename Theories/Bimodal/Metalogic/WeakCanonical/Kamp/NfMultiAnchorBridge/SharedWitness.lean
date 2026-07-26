/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.KitFold

/-! # Shared-Interior-Witness Joint Carrier (O1 + O1b + O2)

The ONE unbuilt object named by the SubBracket2V API banner (`SubBracket2V.lean:25-27`):
the shared-interior-witness conjunction `∃ w, ⋀_σ (per-σ realization at that same w)`,
built as a concrete, model-independent joint carrier `kvE2_sepBody` (Candidate A staged via
Candidate C, per the v7 faithful-separate-bracket design route and its consolidated
faithful-route analysis §2.2).

Every disjunct is a single FLAT bracket (Rabinovich 2014, `md:` refs to the Literature chunk):

- ONE shared `ptW` slot + per positive interior σ one `charK (nfk_projFresh σ)` E[Σ]-atom
  slot plus σ's per-region interior-positive `charBase χ` slots — quantifier-free /
  E[Σ]-atom point types ONLY (**Lemma 5.1**, PDF p.3: "alpha_j, beta_j are quantifier-free
  formulas over Sigma"); no chain predicate in any point-type position (FM-merge), no
  bracket-in-bracket (no-nesting, `NavigatedSpine.lean:43-48`).
- Disjuncts enumerate the JOINT interleavings of every positive interior σ's slot sequence
  between the fixed endpoints `x`, the shared `w` slot, and `t` (**Lemma 3.2(1)**, PDF p.3:
  "Conjunction of exists-forall formulas is equivalent to a disjunction of exists-forall
  formulas") — realized as permutations of the tagged slot union filtered by the per-σ
  region order (`XU* < x1 < UW*` resp. `WX1* < x1 < X1T*`).
- Refined segment types = conjunction of EVERY interior σ's exclusion content on that
  refined sub-interval (**Cor 5.4**, PDF p.5), keyed per arrangement by the position of
  each σ's fresh-witness slot.
- `epL`/`epR`/`ptW` carry (i) `qnf.1`'s endpoint 1-types, (ii) each interior σ's
  exterior/boundary `charBase` literals (per-σ `epL`/`epR` content, `SubBracket2V.lean:183-192`),
  and (iii) the σ-LEVEL navigation literals for the five non-interior outer placements —
  `Since`/`Until` `charK`-atom literals at the fixed endpoints (**Prop 3.5**, PDF p.3: the
  reconstruction rides the temporal evaluation point; LITMUS: no `x1 < e_i` literal).
- Gate-failure branch `{ disjuncts := [] }` under the depth-2 gate: outer off-fiber falsity,
  outer seven-zone consistency (the joint witness self-zone `zAtW3` included — nine-zone
  lesson one level up, `SubBracket2V.lean:160-166`), inner off-fiber for every positive σ,
  and the inner NINE-zone consistency (verbatim `SubBracket2V.lean:1400-1408` pattern set,
  including both witness self-zones `zAtX1`/`zAtW`) for left-interior positives.

**Recorded scope decision (Phase 7).** Positive subs are classified by their OUTER zone
`nf0_zoneSpec σ.1` (x1 relative to `[w,x,t]`; the enumeration device of the quarantined
`kvE2_body` reused as a *pattern*, never imported). The two interior classes (`zXW3`,
`zWT3`) receive slot groups; the five non-interior classes ride the σ-level endpoint
literals that the landed joint dischargers (`NavigatedSpine.lean:257-383`) serve. The inner
nine-zone gate clause is stated for the LEFT-interior class (the class the landed per-σ kit
`kvE_subBracket2V_correctness_pair` serves); extending it to the mirrored right-interior
class is deferred to the phase that consumes it (Phases 8-10 arbitration).

DO-NOT-EDIT discipline: this module is purely additive; it consumes only public
`SubBracket2V`/`NavigatedSpine`/sibling-Kamp assets and rebuilds nothing landed. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

-- R2: RIGHT pin-anchored fragment gate producer + fold.
--   Resolution R2: kvE2_sepGateAtPin_fragR takes an extra explicit hypothesis
--   hInnerR (the zWT3 analog of gate clause iv), threaded through
--   kvE2_sepBody_kit_sound_frag and kvE2_outer_fold_frag — an undischarged
--   obligation for the downstream provider (which lands the discharge machinery). Additive-only.
-- ============================================================================

/-- A right-interior σ's `(x,w)`-region `.rXW` slot is in its canonical LEFT block. -/
theorem kvE2_sep_rXW_mem_slotsLFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true) :
    (.rXW σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsLFor σ := by
  unfold kvE2_sepSlotsLFor
  rw [hzone, if_neg kvE2_sep_zWT3_ne_zXW3, if_pos rfl]
  exact List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)

/-- A right-interior σ's `(x1,t)`-region `.rX1T` slot is in its canonical RIGHT block. -/
theorem kvE2_sep_rX1T_mem_slotsRFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true) :
    (.rX1T σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsRFor σ := by
  unfold kvE2_sepSlotsRFor
  rw [hzone, if_neg kvE2_sep_zWT3_ne_zXW3, if_pos rfl]
  exact List.mem_append.mpr (Or.inr (List.mem_cons.mpr
    (Or.inr (List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)))))

/-- RIGHT-owner variant of `kvE2_sepEpL_owner_lits` (`hσ` ranges over the `zWT3` positive list;
    the only change is the `Or.inr` at the `hσsrc` append). -/
theorem kvE2_sepEpL_owner_lits_R {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3)
    (hep : (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zPastX4 χ) (Formula.snce (charBase χ) Formula.top))
      ∧ temporal_truth M atomMap x
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX4 χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap x (kvE2_sepEpL charBase charK qnf).formula := hep
  simp only [kvE2_sepEpL] at hep'
  have hall := (formula_conjList_iff M atomMap x _).mp hep'
  have hσsrc : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
    List.mem_append.mpr (Or.inr hσ)
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  refine ⟨hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩))),
    hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩)))⟩
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))

/-- RIGHT-owner variant of `kvE2_sepEpR_owner_lits`. -/
theorem kvE2_sepEpR_owner_lits_R {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3)
    (hep : (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap t
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtT4 χ) (charBase χ))
      ∧ temporal_truth M atomMap t
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zFutT4 χ)
            (Formula.untl (charBase χ) Formula.top)) := by
  have hep' : temporal_truth M atomMap t (kvE2_sepEpR charBase charK qnf).formula := hep
  simp only [kvE2_sepEpR] at hep'
  have hall := (formula_conjList_iff M atomMap t _).mp hep'
  have hσsrc : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
    List.mem_append.mpr (Or.inr hσ)
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  refine ⟨hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩))),
    hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩)))⟩
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))

/-- RIGHT-owner variant of `kvE2_sepPtW_owner_lit`. -/
theorem kvE2_sepPtW_owner_lit_R {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3)
    (hep : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWR χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap w (kvE2_sepPtW charBase charK qnf).formula := hep
  simp only [kvE2_sepPtW] at hep'
  have hall := (formula_conjList_iff M atomMap w _).mp hep'
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  exact hall _ (List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
    (List.mem_flatMap.mpr ⟨σ, hσ,
      List.mem_cons.mpr (Or.inr (List.mem_map.mpr ⟨χ, hχu, rfl⟩))⟩)))))

/-- Extract the per-owner `zAtX1R` at-`x1` literal for owner `σ` from a realized `kvE2_sepPtX1R`
    at the pin `x1` (mirror of `kvE2_sepPtX1L_owner_lit`). -/
theorem kvE2_sepPtX1R_owner_lit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x1 : M.carrier)
    (hep : (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap x1) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x1
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1R χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap x1 (kvE2_sepPtX1R charBase charK σ).formula := hep
  simp only [kvE2_sepPtX1R] at hep'
  have hall := (formula_conjList_iff M atomMap x1 _).mp hep'
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  exact hall _ (List.mem_cons.mpr (Or.inr (List.mem_map.mpr ⟨χ, hχu, rfl⟩)))

/-- **RIGHT pin-anchored gate producer** (R2 mirror of
    `kvE2_sepGateAtPin_fragL`). Sole positive `σ0` is RIGHT-interior (`hz : … = kvE2_sep_zWT3`),
    pin `x1` with `w < x1 < t` extracted from the RIGHT group, backward-exception zone
    `kvE2_sep_zWX1`, closer `kvE2_sepBundleR_sound_frag`. The `h_bwd` zone classification is
    recovered from gate clause (v) (`hg.2.2.2.2`, the zWT3 mirror of clause iv) — dissolving
    the former free `hInnerR` obligation into this gate consequence. Additive;
    `hcorrK` explicit, never discharged here. -/
theorem kvE2_sepGateAtPin_fragR {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    (hz : nf0_zoneSpec σ0.1 = kvE2_sep_zWT3)
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
    have hksortR : (kvE2_sepSlotsROf wo).Pairwise
        (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
      refine (kvE2_sepSlotsROf_mergeSorted wo).imp ?_
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
    have hxt : x < t := hxw.trans hwt
    have hptW : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w := by
      have h1 := hpt' _ hwidx
      rwa [kvE2_sep_getElem_mid] at h1
    have hσ0pos : σ0 ∈ kvE2_sepPos qnf := by rw [hfrag]; exact List.mem_singleton_self _
    have hσ0true : qnf.2 σ0 = true := by
      have := hσ0pos; simp only [kvE2_sepPos, List.mem_filter] at this; exact this.2
    have hσI : σ0 ∈ kvE2_sepPosI qnf := (kvE2_sepPosI_mem qnf σ0).mpr ⟨hσ0pos, Or.inr hz⟩
    have hσp : σ0 ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨pp, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ0, pp.2.1, pp.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    -- pin extraction (RIGHT group)
    have hmemX1 : (KvE2SepSlot.rX1 σ0) ∈ kvE2_sepSlotsROf wo :=
      kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rX1_mem_slotsRFor hz)
    rw [← kvE2_sepTieGroupedR_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨irσ, hirσ, hgetirσ⟩ := List.mem_iff_getElem.mp hc
    have hirσm : irσ < ((kvE2_sepTieGroupedR wo).map
        (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    have hpinK : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + irσ
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
      simp only [List.length_map] at hirσm ⊢; omega
    set x1 := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 +
        irσ,
      hpinK⟩ with hx1def
    have hxx1 : x < x1 := (hrange _).1
    have hwx1 : w < x1 := by
      rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
    have hx1t : x1 < t := (hrange _).2
    have hpin_raw := hpt' (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
      + 1 + irσ) hpinK
    rw [kvE2_sep_getElem_right _ _ _ irσ hirσm, List.getElem_map, hgetirσ] at hpin_raw
    have hpt_pin := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hpin_raw hsc
    have hanchor : (⟨charK (nfk_projFresh σ0)⟩ : TemporalPred).eval_at M atomMap x1 :=
      kvE2_sepPtX1R_anchor charBase charK σ0 M atomMap x1 hpt_pin
    -- below-witness clause: every zWX1-positive 1-type strictly between w and the pin
    have hbelow : ∀ χ : NormalForm sig 0 1,
        σ0.2 (nf0_assemble kvE2_sep_zWX1 χ σ0.1) = true →
        ∃ u : M.carrier, w < u ∧ u < x1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
      intro χ hbit
      have hmemU : (KvE2SepSlot.rWX1 σ0 χ) ∈ kvE2_sepSlotsROf wo :=
        kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rWX1_mem_slotsRFor hz hbit)
      rw [← kvE2_sepTieGroupedR_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨jr, hjr, hgetjr⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rWX1 σ0 χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ0) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rWX1_mem_slotsRFor hz hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hz))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.rWX1 σ0 χ) ∈ (kvE2_sepTieGroupedR wo)[jr]'hjr := by
        rw [hgetjr]; exact hsd
      have hbin : (KvE2SepSlot.rX1 σ0) ∈ (kvE2_sepTieGroupedR wo)[irσ]'hirσ := by
        rw [hgetirσ]; exact hsc
      have hji : jr < irσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsROf wo) hksortR hjr hirσ hain hbin hkey
      have hjrm : jr < ((kvE2_sepTieGroupedR wo).map
          (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      have hjtot : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + jr
          < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
            + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
        simp only [List.length_map] at hjrm ⊢; omega
      refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + jr,
        hjtot⟩, ?_, ?_, ?_⟩
      · rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
      · rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
      · have h1 := hpt' (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + 1 + jr) hjtot
        rw [kvE2_sep_getElem_right _ _ _ jr hjrm, List.getElem_map, hgetjr] at h1
        exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd
    refine ⟨hepL, hepR, w, hxw, hwt, hptW, ?_, ?_⟩
    · -- clause 1 (zXW3 owners): vacuous — σ0 is zWT3
      intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      rw [hz] at hzσ
      exact absurd hzσ (by decide)
    · -- clause 2 (zWT3 owners): full derivation at the RIGHT pin
      intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      have h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false :=
        kvE2_sepHgate_offFiber qnf hg σ hσ0true
      have hdrop : nf0_dropFresh σ.1 = qnf.1 := by
        by_contra hne
        rw [hg.1 σ hne] at hσ0true
        exact absurd hσ0true (by decide)
      have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
        have h1 := hptW
        simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ w).mp
          ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
      have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
        have h1 := hepL
        simp only [TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ x).mp
          ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
      have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
        have h1 := hepR
        simp only [TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ t).mp
          ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
      have h_atom : nf_eval_nf M 0 4
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
        have hpf : (nfk_projFresh σ).1 = nf0_projFresh σ.1 := by
          funext a
          match a with
          | .pred p i =>
            have hi : i = ⟨0, by omega⟩ := Subsingleton.elim i _
            subst hi; rfl
          | .order i j hij => exact absurd (Subsingleton.elim i j) hij
        obtain ⟨hc0a, -⟩ := hcorrK σ x1 hanchor
        intro a
        match a with
        | .pred p ⟨0, _⟩ =>
          have h1 := hc0a (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨1, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨0, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojW (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨2, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨1, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojX (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨3, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨2, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojT (.pred p ⟨0, by omega⟩)
          exact h1
        | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ hne) = false := by
            exact congrArg Prod.fst (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hwx1) (by decide)
        | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ hne) = false := by
            exact congrArg Prod.fst (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hxx1) (by decide)
        | .order ⟨0, _⟩ ⟨3, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨3, by omega⟩ hne) = true := by
            exact congrArg Prod.fst (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hx1t (by decide)
        | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ hne) = true := by
            exact congrArg Prod.snd (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hwx1 (by decide)
        | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ hne) = true := by
            exact congrArg Prod.snd (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hxx1 (by decide)
        | .order ⟨3, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨3, by omega⟩ ⟨0, by omega⟩ hne) = false := by
            exact congrArg Prod.snd (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hx1t) (by decide)
        | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yx] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hxw) (by decide)
        | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xy] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true hxw (by decide)
        | .order ⟨1, _⟩ ⟨3, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨2, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 2 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yt] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true hwt (by decide)
        | .order ⟨3, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_ty] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hwt) (by decide)
        | .order ⟨2, _⟩ ⟨3, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨2, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 2 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xt] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true hxt (by decide)
        | .order ⟨3, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_tx] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hxt) (by decide)
        | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
        | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
        | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
        | .order ⟨3, _⟩ ⟨3, _⟩ hne => exact absurd rfl hne
      have h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
          (∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ) →
          σ.2 (nf0_assemble zs χ σ.1) = true := by
        rintro zs χ ⟨v, hzv, hχv⟩
        by_contra hbit
        rw [Bool.not_eq_true] at hbit
        have hχbase : (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap v := by
          rw [hcb]; exact (nfPred_correct M atomMap h_surj χ v).mpr hχv
        have hws_le : ∀ (a b : ℕ) (ha : a < _) (hb : b < _), a ≤ b →
            ws ⟨a, ha⟩ ≤ ws ⟨b, hb⟩ := by
          intro a b ha hb hab
          rcases eq_or_lt_of_le hab with h | h
          · exact le_of_eq (congrArg ws (Fin.ext h))
          · exact le_of_lt (hmono _ _ (Fin.mk_lt_mk.mpr h))
        have hlenL : (kvE2_sepTieGroupedL wo).length
            = (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedL wo)).length := by
          rw [List.length_map]
        have hlenR : (kvE2_sepTieGroupedR wo).length
            = (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length := by
          rw [List.length_map]
        have hndR : (kvE2_sepTieGroupedR wo).flatten.Nodup := by
          rw [kvE2_sepTieGroupedR_flatten]; exact kvE2_sepSlotsROf_nodup qnf hwo'
        have hzWT3ne : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3 := by rw [hz]; exact kvE2_sep_zWT3_ne_zXW3
        have hsc' : (KvE2SepSlot.rX1 σ) ∈ (kvE2_sepTieGroupedR wo)[irσ]'hirσ := by
          rw [hgetirσ]; exact hsc
        have hσIn : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
          List.mem_filter.mpr ⟨hσ0pos, by simp only [decide_eq_true_eq]; exact hz⟩
        rcases kvE2_sep_locate_witness M ws v with ⟨j, hjv⟩ | hlow | ⟨i, hi1, hi2⟩ | hhigh
        · -- WITNESS case: v = ws j is a bracket point
          subst hjv
          have hxv : x < ws j := (hrange j).1
          have hvt : ws j < t := (hrange j).2
          have howner_eq : ∀ τ, τ ∈ kvE2_sepOrderOwners wo → τ = σ := by
            intro τ hτ
            have hτpos := ((kvE2_sepPosI_mem qnf τ).mp
              (kvE2_sepOrderOwners_mem_pos howners hτ)).1
            rw [hfrag] at hτpos; exact List.mem_singleton.mp hτpos
          have hLmem : ∀ s, s ∈ (kvE2_sepTieGroupedL wo).flatten → s ∈ kvE2_sepSlotsLFor σ := by
            intro s hs
            rw [kvE2_sepTieGroupedL_flatten, kvE2_sepSlotsLOf] at hs
            obtain ⟨τ, hτo, hsτ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
            rw [howner_eq τ hτo] at hsτ; exact hsτ
          have hRmem : ∀ s, s ∈ (kvE2_sepTieGroupedR wo).flatten → s ∈ kvE2_sepSlotsRFor σ := by
            intro s hs
            rw [kvE2_sepTieGroupedR_flatten, kvE2_sepSlotsROf] at hs
            obtain ⟨τ, hτo, hsτ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
            rw [howner_eq τ hτo] at hsτ; exact hsτ
          have hχeq : ∀ χ' : NormalForm sig 0 1,
              (⟨charBase χ'⟩ : TemporalPred).eval_at M atomMap (ws j) → χ' = χ := by
            intro χ' hb
            have hnf : nf_eval_nf M 0 1 (fun _ => ws j) χ' :=
              (nfPred_correct M atomMap h_surj χ' (ws j)).mp hb
            exact nf_eval_unique M 0 1 _ χ' χ hnf hχv
          rcases Nat.lt_trichotomy j.val (kvE2_sepTieGroupedL wo).length with hjm | hjm | hjm
          · -- LEFT group: single rXW slot → zone kvE_sub2_zXU (x < ws j < w)
            have hjmap : j.val < (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length := by omega
            have hptj := hpt' j.val j.isLt
            rw [kvE2_sep_getElem_left _ _ _ j.val hjmap, List.getElem_map] at hptj
            have hne : (kvE2_sepTieGroupedL wo)[j.val]'hjm ≠ [] :=
              kvE2_sepTieGroupedL_ne_nil wo _ (List.getElem_mem hjm)
            obtain ⟨s, hsmem⟩ : ∃ s, s ∈ (kvE2_sepTieGroupedL wo)[j.val]'hjm :=
              ⟨_, List.head_mem hne⟩
            have hslotty := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hptj hsmem
            have hsflat : s ∈ (kvE2_sepTieGroupedL wo).flatten :=
              List.mem_flatten.mpr ⟨_, List.getElem_mem hjm, hsmem⟩
            have hsF := hLmem s hsflat
            rw [kvE2_sepSlotsLFor, if_neg hzWT3ne, if_pos hz] at hsF
            obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hsF
            have hχ'eq : χ' = χ := hχeq χ' hslotty
            rw [hχ'eq] at hχ'S
            have hbitXW : kvE2_sepBits σ kvE_sub2_zXU χ = true := (List.mem_filter.mp hχ'S).2
            have hvjw : ws j < w := by rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr hjmap)
            have hvjx1 : ws j < x1 := hvjw.trans hwx1
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zXU (ws j) := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_true hvjx1 rfl, iff_of_false (lt_asymm hvjx1)
                  (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_true hvjw rfl, iff_of_false (lt_asymm hvjw)
                  (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ (ws j) zs _ hzv hpos
            rw [hzeq] at hbit
            simp only [kvE2_sepBits] at hbitXW
            exact Bool.false_ne_true (hbit.symm.trans hbitXW)
          · -- j = |gL| : ws j = w, AT-w case via ptW (zAtWR)
            have hjw : ws j = w := by
              rw [hwdef]; exact congrArg ws (Fin.ext (hjm.trans hlenL))
            have hlit := kvE2_sepPtW_owner_lit_R charBase charK qnf M atomMap w σ hσIn hptW χ
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE2_sep_zAtWR (ws j) := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_true (by rw [hjw]; exact hwx1) rfl,
                  iff_of_false (by rw [hjw]; exact lt_asymm hwx1) (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_irrefl w) (by decide +revert),
                  iff_of_false (by rw [hjw]; exact lt_irrefl w) (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_asymm hxw) (by decide +revert),
                  iff_of_true (by rw [hjw]; exact hxw) rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true (by rw [hjw]; exact hwt) rfl,
                  iff_of_false (by rw [hjw]; exact lt_asymm hwt) (by decide +revert)⟩
            have hzeq : zs = kvE2_sep_zAtWR := zoneHolds_unique M _ (ws j) zs _ hzv hpos
            have hbitW : kvE2_sepBits σ kvE2_sep_zAtWR χ = false := by
              rw [hzeq] at hbit; exact hbit
            rw [hbitW] at hlit
            simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
            exact hlit (by rw [← hjw]; exact hχbase)
          · -- RIGHT group: rWX1 / rX1(pin) / rX1T slots
            set jr := j.val - (kvE2_sepTieGroupedL wo).length - 1 with hjrdef
            have hjlt : j.val < (List.map (kvE2_sepClassType charBase charK)
                  (kvE2_sepTieGroupedL wo)).length
                + (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length +
                    1 :=
              j.isLt
            have hjrR : jr < (kvE2_sepTieGroupedR wo).length := by omega
            have hjrRmap : jr < (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedR wo)).length := by omega
            have hK : (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedL wo)).length
                  + 1 + jr < (List.map (kvE2_sepClassType charBase charK)
                    (kvE2_sepTieGroupedL wo)).length
                + (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length +
                    1 :=
              by omega
            have hptj := hpt' ((List.map (kvE2_sepClassType charBase charK)
              (kvE2_sepTieGroupedL wo)).length + 1 + jr) hK
            rw [kvE2_sep_getElem_right _ _ _ jr hjrRmap, List.getElem_map] at hptj
            have hKeq : (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length + 1 + jr = j.val := by omega
            have hpteq : (ws ⟨(List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length + 1 + jr, hK⟩ : M.carrier) = ws j :=
              congrArg ws (Fin.ext hKeq)
            rw [hpteq] at hptj
            have hne : (kvE2_sepTieGroupedR wo)[jr]'hjrR ≠ [] :=
              kvE2_sepTieGroupedR_ne_nil wo _ (List.getElem_mem hjrR)
            obtain ⟨s, hsmem⟩ : ∃ s, s ∈ (kvE2_sepTieGroupedR wo)[jr]'hjrR :=
              ⟨_, List.head_mem hne⟩
            have hslotty := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hptj hsmem
            have hsflat : s ∈ (kvE2_sepTieGroupedR wo).flatten :=
              List.mem_flatten.mpr ⟨_, List.getElem_mem hjrR, hsmem⟩
            have hsF := hRmem s hsflat
            rw [kvE2_sepSlotsRFor, if_neg hzWT3ne, if_pos hz] at hsF
            rcases List.mem_append.mp hsF with hWX1 | hrest
            · -- s = .rWX1 σ χ' → zWX1 zone (jr < pin irσ), bit true, contradiction
              obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hWX1
              have hχ'eq : χ' = χ := hχeq χ' hslotty
              rw [hχ'eq] at hχ'S hsmem
              have hbitWX1 : kvE2_sepBits σ kvE2_sep_zWX1 χ = true := (List.mem_filter.mp hχ'S).2
              have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rWX1 σ χ)
                  < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ) :=
                kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
                  (by rw [kvE2_sepSlotBlock]
                      exact List.mem_append_right _ (kvE2_sep_rWX1_mem_slotsRFor hz hbitWX1))
                  (by rw [kvE2_sepSlotBlock]
                      exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hz))
                  rfl Nat.zero_lt_one
              have hji : jr < irσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
                (kvE2_sepSlotsROf wo) hksortR hjrR hirσ hsmem hsc' hkey
              have hvx1 : ws j < x1 := by
                rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
              have hwv : w < ws j := by
                rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zWX1 (ws j) := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zWX1 := zoneHolds_unique M _ (ws j) zs _ hzv hpos
              rw [hzeq] at hbit
              simp only [kvE2_sepBits] at hbitWX1
              exact Bool.false_ne_true (hbit.symm.trans hbitWX1)
            · rcases List.mem_cons.mp hrest with rfl | hX1T
              · -- s = .rX1 σ → j at pin, ws j = x1, AT-x1 via ptX1R
                have hjeqr : jr = irσ := by
                  rcases Nat.lt_trichotomy jr irσ with h | h | h
                  · exfalso
                    have hstrict := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
                      (kvE2_sepSlotsROf wo) hksortR
                    have hlt := List.pairwise_iff_getElem.mp hstrict jr irσ hjrR hirσ h
                      (KvE2SepSlot.rX1 σ) hsmem (KvE2SepSlot.rX1 σ) hsc'
                    omega
                  · exact h
                  · exfalso
                    have hstrict := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
                      (kvE2_sepSlotsROf wo) hksortR
                    have hlt := List.pairwise_iff_getElem.mp hstrict irσ jr hirσ hjrR h
                      (KvE2SepSlot.rX1 σ) hsc' (KvE2SepSlot.rX1 σ) hsmem
                    omega
                have hjeq : (List.map (kvE2_sepClassType charBase charK)
                    (kvE2_sepTieGroupedL wo)).length + 1 + irσ = j.val := by omega
                have hjx1 : ws j = x1 := by
                  rw [hx1def]; exact congrArg ws (Fin.ext hjeq.symm)
                have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                    kvE2_sep_zAtX1R (ws j) := by
                  intro k
                  match k with
                  | ⟨0, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_irrefl x1)
                      (by decide +revert),
                      iff_of_false (by rw [hjx1]; exact lt_irrefl x1) (by decide +revert)⟩
                  | ⟨1, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_asymm hwx1)
                      (by decide +revert),
                      iff_of_true (by rw [hjx1]; exact hwx1) rfl⟩
                  | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_asymm hxx1)
                      (by decide +revert),
                      iff_of_true (by rw [hjx1]; exact hxx1) rfl⟩
                  | ⟨3, _⟩ => exact ⟨iff_of_true (by rw [hjx1]; exact hx1t) rfl,
                      iff_of_false (by rw [hjx1]; exact lt_asymm hx1t) (by decide +revert)⟩
                have hzeq : zs = kvE2_sep_zAtX1R := zoneHolds_unique M _ (ws j) zs _ hzv hpos
                have hlit := kvE2_sepPtX1R_owner_lit charBase charK σ M atomMap (ws j) hslotty χ
                have hbitX1 : kvE2_sepBits σ kvE2_sep_zAtX1R χ = false := by
                  rw [hzeq] at hbit; exact hbit
                rw [hbitX1] at hlit
                simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
                exact hlit hχbase
              · -- s = .rX1T σ χ' → kvE_sub2_zWT zone (pin < jr), bit true, contradiction
                obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hX1T
                have hχ'eq : χ' = χ := hχeq χ' hslotty
                rw [hχ'eq] at hχ'S hsmem
                have hbitX1T : kvE2_sepBits σ kvE_sub2_zWT χ = true := (List.mem_filter.mp hχ'S).2
                have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ)
                    < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1T σ χ) :=
                  kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
                    (by rw [kvE2_sepSlotBlock]
                        exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hz))
                    (by rw [kvE2_sepSlotBlock]
                        exact List.mem_append_right _ (kvE2_sep_rX1T_mem_slotsRFor hz hbitX1T))
                    rfl Nat.one_lt_two
                have hji : irσ < jr := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
                  (kvE2_sepSlotsROf wo) hksortR hirσ hjrR hsc' hsmem hkey
                have hx1v : x1 < ws j := by
                  rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
                have hwv : w < ws j := hwx1.trans hx1v
                have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                    kvE_sub2_zWT (ws j) := by
                  intro k
                  match k with
                  | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                      hx1v rfl⟩
                  | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true
                      hwv rfl⟩
                  | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true
                      hxv rfl⟩
                  | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                      (by decide +revert)⟩
                have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ (ws j) zs _ hzv hpos
                rw [hzeq] at hbit
                simp only [kvE2_sepBits] at hbitX1T
                exact Bool.false_ne_true (hbit.symm.trans hbitX1T)
        · -- hlow : v < ws 0
          rcases lt_or_ge x v with hxv | hvx
          · -- x < v < ws0 ⊆ (x, w) : kvE_sub2_zXU via hseg0
            have hvw : v < w := by
              rw [hwdef]; exact lt_of_lt_of_le hlow (hws_le _ _ _ _ (Nat.zero_le _))
            have hvx1 : v < x1 := hvw.trans hwx1
            have hvt : v < t := hvw.trans hwt
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zXU v := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                  (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                  (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ v zs kvE_sub2_zXU hzv hpos
            have hsegF : (⟨kvE2_sepSegForm charBase σ kvE_sub2_zXU⟩ : TemporalPred).eval_at M
                atomMap v := by
              have hh := hseg0 v hxv hlow
              simp only [kvE2_sepSegsG, kvE2_sepSegLAt, hfrag, List.map_cons, List.map_nil,
                List.take_zero, List.flatten_nil, List.length_nil] at hh
              have hh1 := (formula_conjList_iff M atomMap v _).mp hh _ List.mem_cons_self
              rwa [kvE2_sepSegLForSub, if_neg hzWT3ne, if_pos hz] at hh1
            have hbitX : kvE2_sepBits σ kvE_sub2_zXU χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hsegF hbitX hχbase
          · -- v ≤ x : boundary via hepL
            rcases lt_or_eq_of_le hvx with hvltx | hveqx
            · -- v < x : zPastX4, hepL Since-literal
              have hvx1 : v < x1 := hvltx.trans hxx1
              have hvw : v < w := hvltx.trans hxw
              have hvt : v < t := hvltx.trans hxt
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zPastX4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_true hvltx rfl, iff_of_false (lt_asymm hvltx)
                    (by decide +revert)⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zPastX4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitP : kvE2_sepBits σ kvE2_sep_zPastX4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpL_owner_lits_R charBase charK qnf M atomMap x σ hσIn hepL χ).1
              rw [hbitP] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              exact hlit ⟨v, hvltx, hχbase, fun r _ _ hf => hf⟩
            · -- v = x : zAtX4, hepL at-x literal
              have hvx1 : v < x1 := by rw [hveqx]; exact hxx1
              have hvw : v < w := by rw [hveqx]; exact hxw
              have hvt : v < t := by rw [hveqx]; exact hxt
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zAtX4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hveqx]; exact lt_irrefl x)
                    (by decide +revert),
                    iff_of_false (by rw [hveqx]; exact lt_irrefl x) (by decide +revert)⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zAtX4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitA : kvE2_sepBits σ kvE2_sep_zAtX4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpL_owner_lits_R charBase charK qnf M atomMap x σ hσIn hepL χ).2
              rw [hbitA] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              rw [hveqx] at hχbase
              exact hlit hχbase
        · -- mid : ws ⟨i⟩ < v < ws ⟨i+1⟩
          have hsm := hsegMid i v hi1 hi2
          have hxv : x < v := lt_trans (hrange _).1 hi1
          by_cases hcut : (i : ℕ) + 1 ≤ (kvE2_sepTieGroupedL wo).length
          · -- left cut: v ∈ (x, w) → zone kvE_sub2_zXU (single, no pin)
            rw [kvE2_sepSegsG, if_pos hcut] at hsm
            simp only [kvE2_sepSegLAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegLForSub, if_neg hzWT3ne, if_pos hz] at hseg1
            have hvw : v < w := by
              rw [hwdef]; exact lt_of_lt_of_le hi2 (hws_le _ _ _ _ (by omega))
            have hvx1 : v < x1 := hvw.trans hwx1
            have hvt : v < t := hvw.trans hwt
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zXU v := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                  (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                  (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ v zs kvE_sub2_zXU hzv hpos
            have hbitX : kvE2_sepBits σ kvE_sub2_zXU χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hseg1 hbitX hχbase
          · -- right cut: v ∈ (w, t) → zone zWX1 or kvE_sub2_zWT via the pin
            rw [kvE2_sepSegsG, if_neg hcut] at hsm
            simp only [kvE2_sepSegRAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegRForSub, if_neg hzWT3ne, if_pos hz,
              ← kvE2_sep_take_flatten_prefix] at hseg1
            have hwv : w < v := by
              rw [hwdef]; exact lt_of_le_of_lt (hws_le _ _ _ _ (by omega)) hi1
            have hvt : v < t := lt_trans hi2 (hrange _).2
            have hxvr : x < v := hxw.trans hwv
            by_cases hpin : irσ < (i : ℕ) - (kvE2_sepTieGroupedL wo).length
            · -- pin in take → v > x1 → kvE_sub2_zWT
              have hx1v : x1 < v := by
                rw [hx1def]; exact lt_of_le_of_lt (hws_le _ _ _ _ (by omega)) hi1
              have hmem : (KvE2SepSlot.rX1 σ) ∈ ((kvE2_sepTieGroupedR wo).take
                  ((i : ℕ) + 1 - (kvE2_sepTieGroupedL wo).length - 1)).flatten :=
                (kvE2_sep_pin_mem_take_flatten_iff _ hndR _ irσ hirσ hsc' _).mpr (by omega)
              rw [if_pos (List.contains_iff_mem.mpr hmem)] at hseg1
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE_sub2_zWT v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxvr) (by decide +revert), iff_of_true
                    hxvr rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ v zs kvE_sub2_zWT hzv hpos
              have hbitW : kvE2_sepBits σ kvE_sub2_zWT χ = false := by rw [hzeq] at hbit; exact hbit
              exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zWT χ M atomMap v hseg1 hbitW
                  hχbase
            · -- pin not in take → v < x1 → zWX1
              have hvx1 : v < x1 := by
                rw [hx1def]; exact lt_of_lt_of_le hi2 (hws_le _ _ _ _ (by omega))
              have hnmem : (KvE2SepSlot.rX1 σ) ∉ ((kvE2_sepTieGroupedR wo).take
                  ((i : ℕ) + 1 - (kvE2_sepTieGroupedL wo).length - 1)).flatten := by
                intro hc
                exact absurd ((kvE2_sep_pin_mem_take_flatten_iff _ hndR _ irσ hirσ hsc' _).mp hc)
                    (by omega)
              rw [if_neg (fun hc => hnmem (List.contains_iff_mem.mp hc))] at hseg1
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zWX1 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxvr) (by decide +revert), iff_of_true
                    hxvr rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zWX1 := zoneHolds_unique M _ v zs kvE2_sep_zWX1 hzv hpos
              have hbitW : kvE2_sepBits σ kvE2_sep_zWX1 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              exact kvE2_sepSegForm_excludes charBase σ kvE2_sep_zWX1 χ M atomMap v hseg1 hbitW
                  hχbase
        · -- hhigh : ws ⟨last⟩ < v
          have hwv : w < v :=
            lt_of_le_of_lt (by rw [hwdef]; exact hws_le _ _ _ _ (by omega)) hhigh
          have hxv : x < v := lt_trans hxw hwv
          rcases lt_or_ge v t with hvltt | htlev
          · -- w < v < t : v > x1 (pin ≤ last) → kvE_sub2_zWT via hsegLast
            have hx1v : x1 < v :=
              lt_of_le_of_lt (by rw [hx1def]; exact hws_le _ _ _ _ (by omega)) hhigh
            have hsm := hsegLast v hhigh hvltt
            rw [kvE2_sepSegsG, if_neg (show ¬ _ from by simp only [hlenL]; omega)] at hsm
            simp only [kvE2_sepSegRAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegRForSub, if_neg hzWT3ne, if_pos hz,
              ← kvE2_sep_take_flatten_prefix] at hseg1
            have hmem : (KvE2SepSlot.rX1 σ) ∈ ((kvE2_sepTieGroupedR wo).take
                ((List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedL wo)).length
                  + (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length +
                      1
                  - (kvE2_sepTieGroupedL wo).length - 1)).flatten :=
              (kvE2_sep_pin_mem_take_flatten_iff _ hndR _ irσ hirσ hsc' _).mpr (by
                simp only [List.length_map] at hirσm ⊢; omega)
            rw [if_pos (List.contains_iff_mem.mpr hmem)] at hseg1
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zWT v := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v
                  rfl⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                  rfl⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvltt rfl, iff_of_false (lt_asymm hvltt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ v zs kvE_sub2_zWT hzv hpos
            have hbitW : kvE2_sepBits σ kvE_sub2_zWT χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zWT χ M atomMap v hseg1 hbitW hχbase
          · -- t ≤ v : boundary via hepR
            have hx1v : x1 < v := lt_of_lt_of_le hx1t htlev
            rcases lt_or_eq_of_le htlev with htltv | hteqv
            · -- t < v : zFutT4, hepR Until-literal
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zFutT4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_false (lt_asymm htltv) (by decide +revert), iff_of_true
                    htltv rfl⟩
              have hzeq : zs = kvE2_sep_zFutT4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitF : kvE2_sepBits σ kvE2_sep_zFutT4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpR_owner_lits_R charBase charK qnf M atomMap t σ hσIn hepR χ).2
              rw [hbitF] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              exact hlit ⟨v, htltv, hχbase, fun r _ _ hf => hf⟩
            · -- v = t : zAtT4, hepR at-t literal
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zAtT4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_false (by rw [← hteqv]; exact lt_irrefl t)
                    (by decide +revert),
                    iff_of_false (by rw [← hteqv]; exact lt_irrefl t) (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zAtT4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitAT : kvE2_sepBits σ kvE2_sep_zAtT4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpR_owner_lits_R charBase charK qnf M atomMap t σ hσIn hepR χ).1
              rw [hbitAT] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              rw [← hteqv] at hχbase
              exact hlit hχbase
      have h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
          σ.2 (nf0_assemble zs χ σ.1) = true →
          ∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ := by
        intro zs χ hzsne hbit
        have hσIn : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
          List.mem_filter.mpr ⟨hσ0pos, by simp only [decide_eq_true_eq]; exact hz⟩
        have tonf : ∀ (v : M.carrier),
            temporal_truth M atomMap v (charBase χ) → nf_eval_nf M 0 1 (fun _ => v) χ := by
          intro v hv; rw [hcb] at hv; exact (nfPred_correct M atomMap h_surj χ v).mp hv
        -- classify: a true bit forces `zs` among the nine RIGHT inner-consistent zones
        -- (gate clause v — the zWT3 mirror of clause iv, recovered from `hg`)
        have hcons : kvE2_sepInnerConsistentR zs := by
          by_contra hncons
          rw [hg.2.2.2.2 σ hσ0true hz zs χ hncons] at hbit
          exact absurd hbit (by decide)
        rcases hcons with h | h | h | h | h | h | h | h | h
        · -- zPastX4  (v < x)
          have hzp : zs = kvE2_sep_zPastX4 := h
          rw [hzp] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zPastX4 χ = true := hbit
          have hlit := (kvE2_sepEpL_owner_lits_R charBase charK qnf M atomMap x σ hσIn hepL χ).1
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          obtain ⟨s, hsx, hχs, -⟩ := hlit
          have hsx1 : s < x1 := hsx.trans hxx1
          have hsw : s < w := hsx.trans hxw
          have hst : s < t := hsx.trans hxt
          refine ⟨s, ?_, tonf _ hχs⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hsx1 rfl, iff_of_false (lt_asymm hsx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hsw rfl, iff_of_false (lt_asymm hsw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by decide +revert)⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hst rfl, iff_of_false (lt_asymm hst) (by decide +revert)⟩
        · -- zAtX4  (v = x)
          have hzx : zs = kvE2_sep_zAtX4 := h
          rw [hzx] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtX4 χ = true := hbit
          have hlit := (kvE2_sepEpL_owner_lits_R charBase charK qnf M atomMap x σ hσIn hepL χ).2
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨x, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hxx1 rfl, iff_of_false (lt_asymm hxx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_irrefl x) (by decide +revert),
              iff_of_false (lt_irrefl x) (by decide +revert)⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hxt rfl,
              iff_of_false (lt_asymm hxt) (by decide +revert)⟩
        · -- zXW = kvE_sub2_zXU  (x < v < w) : left-group rXW slot machinery
          have hzxw : zs = kvE_sub2_zXU := h
          rw [hzxw] at hbit ⊢
          have hbitT : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true := hbit
          have hrXW : (KvE2SepSlot.rXW σ χ) ∈ kvE2_sepSlotsLFor σ :=
            kvE2_sep_rXW_mem_slotsLFor hz hbitT
          have hmemL : (KvE2SepSlot.rXW σ χ) ∈ kvE2_sepSlotsLOf wo :=
            kvE2_sepSlotsLOf_mem qnf hwo' hσI hrXW
          rw [← kvE2_sepTieGroupedL_flatten wo] at hmemL
          obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemL
          obtain ⟨jl, hjl, hgetjl⟩ := List.mem_iff_getElem.mp hd
          have hjlm : jl < ((kvE2_sepTieGroupedL wo).map
              (kvE2_sepClassType charBase charK)).length := by
            simp only [List.length_map]; omega
          have hchar := hpt' jl (by omega)
          rw [kvE2_sep_getElem_left _ _ _ jl hjlm, List.getElem_map, hgetjl] at hchar
          have hcharχ := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hchar hsd
          set v := ws ⟨jl, by omega⟩ with hvdef
          have hxv : x < v := (hrange _).1
          have hvw : v < w := by
            rw [hwdef, hvdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr hjlm)
          have hvx1 : v < x1 := hvw.trans hwx1
          have hvt : v < t := hvw.trans hwt
          refine ⟨v, ?_, tonf _ hcharχ⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by decide +revert)⟩
        · -- zAtWR  (v = w)
          have hzw : zs = kvE2_sep_zAtWR := h
          rw [hzw] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtWR χ = true := hbit
          have hlit := kvE2_sepPtW_owner_lit_R charBase charK qnf M atomMap w σ hσIn hptW χ
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨w, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hwx1 rfl, iff_of_false (lt_asymm hwx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_irrefl w) (by decide +revert),
              iff_of_false (lt_irrefl w) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxw) (by decide +revert), iff_of_true hxw rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide +revert)⟩
        · -- zWX1  (excluded by hypothesis)
          exact absurd h hzsne
        · -- zAtX1R  (v = x1)
          have hzx1 : zs = kvE2_sep_zAtX1R := h
          rw [hzx1] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtX1R χ = true := hbit
          have hlit := kvE2_sepPtX1R_owner_lit charBase charK σ M atomMap x1 hpt_pin χ
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨x1, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_irrefl x1) (by decide +revert),
              iff_of_false (lt_irrefl x1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwx1) (by decide +revert), iff_of_true hwx1 rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxx1) (by decide +revert), iff_of_true hxx1 rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hx1t rfl, iff_of_false (lt_asymm hx1t) (by decide +revert)⟩
        · -- zX1T = kvE_sub2_zWT  (x1 < v < t) : right-group rX1T slot machinery above the pin
          have hzwt : zs = kvE_sub2_zWT := h
          rw [hzwt] at hbit ⊢
          have hbitT : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true := hbit
          have hrX1T : (KvE2SepSlot.rX1T σ χ) ∈ kvE2_sepSlotsRFor σ :=
            kvE2_sep_rX1T_mem_slotsRFor hz hbitT
          have hmemR : (KvE2SepSlot.rX1T σ χ) ∈ kvE2_sepSlotsROf wo :=
            kvE2_sepSlotsROf_mem qnf hwo' hσI hrX1T
          rw [← kvE2_sepTieGroupedR_flatten wo] at hmemR
          obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemR
          obtain ⟨jr, hjr, hgetjr⟩ := List.mem_iff_getElem.mp hd
          have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ)
              < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1T σ χ) :=
            kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
              (by rw [kvE2_sepSlotBlock]
                  exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hz))
              (by rw [kvE2_sepSlotBlock]
                  exact List.mem_append_right _ (kvE2_sep_rX1T_mem_slotsRFor hz hbitT))
              rfl Nat.one_lt_two
          have hain : (KvE2SepSlot.rX1T σ χ) ∈ (kvE2_sepTieGroupedR wo)[jr]'hjr := by
            rw [hgetjr]; exact hsd
          have hbin : (KvE2SepSlot.rX1 σ) ∈ (kvE2_sepTieGroupedR wo)[irσ]'hirσ := by
            rw [hgetirσ]; exact hsc
          have hij : irσ < jr := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
            (kvE2_sepSlotsROf wo) hksortR hirσ hjr hbin hain hkey
          have hjrm : jr < ((kvE2_sepTieGroupedR wo).map
              (kvE2_sepClassType charBase charK)).length := by
            simp only [List.length_map]; omega
          have hK : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 +
              jr
              < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
                + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
            simp only [List.length_map] at hjrm ⊢; omega
          have hchar := hpt' (((kvE2_sepTieGroupedL wo).map
              (kvE2_sepClassType charBase charK)).length
            + 1 + jr) hK
          rw [kvE2_sep_getElem_right _ _ _ jr hjrm, List.getElem_map, hgetjr] at hchar
          have hcharχ := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hchar hsd
          set v := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
              + jr,
            hK⟩ with hvdef
          have hx1v : x1 < v := by
            rw [hx1def, hvdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
          have hvt : v < t := (hrange _).2
          have hwv : w < v := hwx1.trans hx1v
          have hxv : x < v := hxx1.trans hx1v
          refine ⟨v, ?_, tonf _ hcharχ⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by decide +revert)⟩
        · -- zAtT4  (v = t)
          have hzt : zs = kvE2_sep_zAtT4 := h
          rw [hzt] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtT4 χ = true := hbit
          have hlit := (kvE2_sepEpR_owner_lits_R charBase charK qnf M atomMap t σ hσIn hepR χ).1
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨t, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1t) (by decide +revert),
              iff_of_true hx1t rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwt) (by decide +revert), iff_of_true hwt rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxt) (by decide +revert),
              iff_of_true hxt rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_false (lt_irrefl t) (by decide +revert),
              iff_of_false (lt_irrefl t) (by decide +revert)⟩
        · -- zFutT4  (t < v)
          have hzf : zs = kvE2_sep_zFutT4 := h
          rw [hzf] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zFutT4 χ = true := hbit
          have hlit := (kvE2_sepEpR_owner_lits_R charBase charK qnf M atomMap t σ hσIn hepR χ).2
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          obtain ⟨u, htu, hχu, -⟩ := hlit
          have hu_x1 : x1 < u := hx1t.trans htu
          have hu_w : w < u := hwt.trans htu
          have hu_x : x < u := hxt.trans htu
          refine ⟨u, ?_, tonf _ hχu⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hu_x1) (by decide +revert), iff_of_true hu_x1
              rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hu_w) (by decide +revert), iff_of_true hu_w rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hu_x) (by decide +revert), iff_of_true hu_x rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_false (lt_asymm htu) (by decide +revert), iff_of_true htu rfl⟩
      exact kvE2_sepBundleR_sound_frag atomMap h_surj σ M w x t hxw x1 hwx1 hx1t hbelow
        h_atom h_off h_fwd h_bwd
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

/-- **Pin-anchored per-σ kit application** (the `_frag` variant of
    `kvE2_sepBody_kit_sound`; interior-singleton REPAIR).

    Under the interior-singleton fragment predicate (`kvE2_sepFragment_frag` now keys on
    `kvE2_sepPosI qnf = [σ0]`) the sole INTERIOR positive is `σ0`, but the
    GLOBAL positive list `kvE2_sepPos qnf` additionally carries the ≥3 boundary positives that
    `nf_exists_unique` forces on every realized `qnf` (335 report 07 Refutation 1). The former
    dispatch to `kvE2_sepGateAtPin_fragL`/`_fragR` is therefore UNAVAILABLE: those frozen
    producers demand the GLOBAL singleton `kvE2_sepPos qnf = [σ0]`, which is unrealizable under
    the swap (`kvE2_sepPosI qnf = [σ0] ⇏ kvE2_sepPos qnf = [σ0]`, Phase 1 triage). They remain
    green but genuinely inapplicable in the new regime.

    The two interior realization clauses of the conclusion range over the interior zones
    `zXW3`/`zWT3`; every such σ is provider-realized. Following the Phase-3 architecture
    (`hexcl`/`hexclExt` split — the deferred obligation is a NAMED hypothesis carried by the
    caller, discharged downstream at the provider instantiation, never assumed
    in-carrier), the per-positive realization is threaded as `hreal`. The endpoint/witness
    facts (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW` at `x`/`t`/`w`) are extracted from the
    realized body via the frozen `kvE2_sepBody_extract`. `hreal ∧ hexcl ∧ hexclExt` (the fold's
    full interface) together equal the honest "positives realized, negatives excluded" content;
    no logical strength is silently dropped and no sorry sits on any live path. -/
theorem kvE2_sepBody_kit_sound_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    -- R1 realization channel: per-positive realization at the extracted
    -- pivot `w`, the completeness dual of `hexcl`. Provider-discharged, never assumed
    -- in-carrier — the carrier records σ's bits but does not itself witness boundary σ's zone
    -- content (design note SW:10027-10032). Interior positives collapse to σ0 under `hfrag`;
    -- boundary positives ride their `charK` endpoint literals at the caller.
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf,
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
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
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, -, -⟩ :=
    kvE2_sepBody_extract (nf_depth0_char_formula atomMap h_surj) charK qnf M atomMap x t h
  exact ⟨hEpL, hEpR, w, hxw, hwt, hptW,
    fun σ hσ _hz => hreal w hxw hwt hptW σ hσ,
    fun σ hσ _hz => hreal w hxw hwt hptW σ hσ⟩

/-- **R1 interior-slice order-atom discharge** (report 01 §7 R1,
    `NormalForm.lean:201-202`; Rabinovich Notation 5.2 strictly-interior witnesses).
    A strictly-exterior `x1` (outside the closed cone `x ≤ x1 ≤ t`) falsifies any
    interior-marked σ (`nf0_zoneSpec σ.1 ∈ {kvE2_sep_zXW3, kvE2_sep_zWT3}`) directly
    from the depth-0 atom clause, with NO residue. Both interior zones assert BOTH
    `x < x1` (bit `(nf0_zoneSpec σ.1 ⟨1⟩).2`, atom `.order 2 0`) AND `x1 < t` (bit
    `(nf0_zoneSpec σ.1 ⟨2⟩).1`, atom `.order 0 3`) over the env `[x1,w,x,t]`; a realized
    σ would therefore force `x < x1 ∧ x1 < t`, contradicting the exterior guard. This is
    the order-atom-only core of R1: the interior slice of the monolithic `hexclExt`
    obligation carries no genuine content, so the deferred residue is exterior-marked σ
    only (report 01 §7 R1 / C1: "hexclExt = phantom" for the interior slice). The `omega`/
    `exact` closer on the falsified `.order` literal is the sanctioned move (no
    `simp`/`decide` over the whole `nf_eval_nf`, per plan Postmortem Constraints). -/
theorem kvE2_sepInterior_exterior_notRealizable {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    (hguard : ¬ (x ≤ x1 ∧ x1 ≤ t)) :
    ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro hnf
  obtain ⟨hσ_atom, _⟩ := hnf
  -- Both interior zones assert `x < x1` (index-1 `.2` bit) and `x1 < t` (index-2 `.1` bit);
  -- the zone-spec components ARE σ.1's fresh-coupling order bits (`nf0_zoneSpec` def).
  have hbit_xx1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
    rcases hzone with hz | hz <;> rw [congrFun hz ⟨1, by omega⟩] <;> decide
  have hbit_x1t : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
    rcases hzone with hz | hz <;> rw [congrFun hz ⟨2, by omega⟩] <;> decide
  -- Transfer the bits to real order facts through the realized depth-0 atom layer.
  have hxx1 : x < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_xx1
  have hx1t : x1 < t := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1t
  exact hguard ⟨le_of_lt hxx1, le_of_lt hx1t⟩

/-- **Pin-anchored outer fold** (the `_frag` variant of `kvE2_outer_fold`;
    interior-singleton REPAIR). The outer atom layer is assembled from the carrier's endpoint/
    witness point types; the depth-1 quant layer is closed by the honest realize/exclude
    interface `hreal` (backward: every positive σ realized at the pivot `w`) + `hexcl`/`hexclExt`
    (forward: negatives excluded on the cone / exterior — the Phase-3 R1 split).

    Under the interior-singleton predicate swap (Phase 1) `kvE2_sepPos qnf` carries the sole
    interior owner σ0 PLUS the boundary positives `nf_exists_unique` forces; the former
    `hfrag`-driven `exfalso` (backward branch "unreachable" because the GLOBAL singleton left no
    non-interior positive) is retired — boundary positives are now admissible and are REALIZED
    via `hreal`, not refuted. `hreal ∧ hexcl ∧ hexclExt` is the honest depth-1 fold interface,
    provider-discharged downstream (the Prop-4.3 exterior successor), never assumed
    in-carrier (design note SW:10027-10032). Delivered to
    `bracketEndChar_kvE2_correct_two_prior_frag` (OuterGate.lean). -/
theorem kvE2_outer_fold_frag {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    -- R1 realization channel: the completeness dual of `hexcl`/`hexclExt`.
    -- Every positive sub `σ` is realized at the extracted pivot `w`. Under the interior-singleton
    -- swap (Phase 1) `kvE2_sepPos qnf` carries the sole interior owner σ0 PLUS the ≥3 boundary
    -- positives; the former `hfrag`-driven `exfalso` (boundary unreachable under the GLOBAL
    -- singleton) is retired because those boundary positives are now admissible and must be
    -- realized. Provider-discharged downstream (Prop-4.3 successor), never assumed
    -- in-carrier (design note SW:10027-10032) — the mirror of the Phase-3 `hexclExt` split.
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf,
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- R1: the exterior residue of the former single-`hexcl` exclusion clause.
    -- `hexcl` above is boundary-restricted to the interior+boundary cone `x ≤ x1 ≤ t`
    -- (dischargeable
    -- by the landed endpoint/witness literals); `hexclExt` isolates the STRICTLY-EXTERIOR case
    -- (`¬ (x ≤ x1 ∧ x1 ≤ t)`), the outer-forward completeness obligation carried by the caller.
    -- R1 (report 01 §7): `hexclExt` is now further NARROWED to EXTERIOR-MARKED σ only
    -- (`¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3)`). The interior-marked slice
    -- (`zXW3`/`zWT3`) of the strictly-exterior case carries NO genuine content — it is discharged
    -- in-line at the fold body via the Phase-1 order-atom lemma
    -- `kvE2_sepInterior_exterior_notRealizable` (a strictly-exterior `x1` falsifies an interior σ's
    -- `.order` atoms directly). The remaining deferred obligation is the EXTERIOR-ARRANGEMENT
    -- residue
    -- only, whose faithful mechanism is the Prop-4.3 re-flatten / Lemma 7.6 adjacency successor
    -- (report 01 §7 R2; NOT exterior-exclusion on this bracket — that framing is retired).
    -- Splitting-and-narrowing rather than dropping keeps this fold a genuine, sorry-free
    -- conditional
    -- theorem whose cone + interior-exterior halves are independently consumable.
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∃ w : M.carrier,
      nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, -, -⟩ :=
    kvE2_sepBody_kit_sound_frag atomMap h_surj charK qnf M x t h hreal
  have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
    have h1 := hptW
    simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ w).mp
      ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
  have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
    have h1 := hEpL
    simp only [kvE2_sepEpL, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ x).mp
      ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
  have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
    have h1 := hEpR
    simp only [kvE2_sepEpR, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ t).mp
      ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
  refine ⟨w, ?_, ?_⟩
  · intro a
    match a with
    | .pred p ⟨0, _⟩ =>
      have h1 := hprojW (.pred p ⟨0, by omega⟩)
      exact h1
    | .pred p ⟨1, _⟩ =>
      have h1 := hprojX (.pred p ⟨0, by omega⟩)
      exact h1
    | .pred p ⟨2, _⟩ =>
      have h1 := hprojT (.pred p ⟨0, by omega⟩)
      exact h1
    | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_yx.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm hxw
    | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
      refine iff_of_true ?_ h_yt
      simp only [atom_eval]
      exact hwt
    | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
      refine iff_of_true ?_ h_xy
      simp only [atom_eval]
      exact hxw
    | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
      refine iff_of_true ?_ h_xt
      simp only [atom_eval]
      exact hxw.trans hwt
    | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_ty.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm hwt
    | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_tx.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm (hxw.trans hwt)
    | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
    | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
    | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
  · intro σ
    constructor
    · rintro ⟨x1, hx1⟩
      by_contra hne
      -- R1: the realizing witness `x1` may be interior/boundary OR strictly
      -- exterior; the boundary-restricted `hexcl` covers the cone `x ≤ x1 ≤ t`.
      -- R1 (report 01 §7): for the strictly-exterior case `¬ (x ≤ x1 ∧ x1 ≤ t)` we split by
      -- σ-zone. The interior-marked slice (`zXW3`/`zWT3`) is discharged directly by the Phase-1
      -- order-atom lemma `kvE2_sepInterior_exterior_notRealizable` (NO residue); only the
      -- exterior-marked residue is carried by the narrowed `hexclExt` (Prop-4.3 re-flatten
      -- successor).
      by_cases hcone : x ≤ x1 ∧ x1 ≤ t
      · exact hexcl w hxw hwt hptW σ (Bool.eq_false_iff.mpr hne) x1 hcone.1 hcone.2 hx1
      · by_cases hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3
        · exact kvE2_sepInterior_exterior_notRealizable M x1 w x t σ hzone hcone hx1
        · exact hexclExt w hxw hwt hptW σ (Bool.eq_false_iff.mpr hne) hzone x1 hcone hx1
    · intro hbit
      have hmem : σ ∈ kvE2_sepPos qnf := by
        simp only [kvE2_sepPos, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hbit⟩
      -- R1 realization: every positive σ is realized at the extracted pivot
      -- `w` via the provider-discharged `hreal` — the sole interior owner σ0 (`zXW3`/`zWT3`) and
      -- the boundary positives (`zAtX3`/`zAtW3`/`zAtT3`, un-vacuated by the `kvE2_sepPosI` swap)
      -- alike. The former `exfalso` (boundary unreachable under the GLOBAL singleton `hfrag`) is
      -- retired: boundary positives are now admissible and are REALIZED, not refuted.
      exact hreal w hxw hwt hptW σ hmem

end Bimodal.Metalogic.WeakCanonical.Kamp

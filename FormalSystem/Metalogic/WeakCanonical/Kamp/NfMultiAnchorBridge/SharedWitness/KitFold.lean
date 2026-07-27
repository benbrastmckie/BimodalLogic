/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Assembly

/-! # Shared-Interior-Witness Joint Carrier — per-σ kit application and fold

Module I of the `SharedWitness` tower. Per-σ kit application — bundles → sound kit → owner
`nf_eval` — and the LEFT pin-anchored fragment gate producer. Carries the fragment
predicates `kvE2_sepFragment_frag` / `kvE2_sepFragment_realizable` and `kvE2_outer_fold`
(Rabinovich Prop 4.3, PDF p.6). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Phase 3 — Per-σ kit application: bundles → sound kit → owner `nf_eval`

Thread the per-σ bundles produced by the hypothesis-free `kvE2_sepBody_extract` (Phase 2)
through the `_parts` reducers into the closer `kvE_subBracket2V_sound_of_parts`
(`SubBracket2V.lean:1290`, consume-only) to obtain each positive owner's `nf_eval`. This is a
kit APPLICATION, not a bit-proof: every `σ.2 (nf0_assemble … χ σ.1) = true` occurrence below
is the *antecedent* of a per-owner `bit ⟹ witness` implication carried by that owner's OWN
enumeration `σ.2` — self-owned, never a cross-σ goal (plan v4 Postmortem Constraints; the
deleted plan-02 R3 stays deleted). `hgate` is the explicit outer-gate hypothesis threaded
verbatim (the Amendment F3 pattern of `kvE_subBracket2V_sound_of_outer`,
`SubBracket2V.lean:1481`) — never assumed, never discharged vacuously here; its carrier-side
derivable pieces live in the Phase 9 (O4) section above and its assembly is downstream
Rabinovich 2014: Notation 5.2 bracket bundles (pp.7-8), Cor 5.4
bounded interior placement (p.9). -/

/-- **LEFT-interior kit application** (Phase 3): a realized left-class bundle at the shared
    witness, under `w < t`, yields the owner's depth-1 `nf_eval` at env `[x1, w, x, t]` by
    feeding the EXACT `kvE_subBracket2V_sound_of_parts` input 5-tuple produced by
    `kvE2_sepBundleL_parts` into the closer, `hgate` threaded verbatim (Amendment F3 — the
    `kvE_subBracket2V_sound_of_outer` composition pattern, `SubBracket2V.lean:1514-1517`).
    Instantiated at the standard `charBase = nf_depth0_char_formula atomMap h_surj`, under
    which the bundle's below-anchor witnesses unify with the closer's expected shapes with no
    coercion. Bounds ride the bracket's own ordering (FM-x1t; never a fresh-witness/slot
    relative-position formula literal — LITMUS). -/
theorem kvE2_sepBundleL_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwt : w < t)
    (h : kvE2_sepBundleL (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap w x)
    (hgate : ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨x1, hxx1, hx1t, hanchor, hbelow⟩ :=
    kvE2_sepBundleL_parts (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap hwt h
  exact kvE_subBracket2V_sound_of_parts atomMap h_surj charK σ M w x t x1 hxx1 hx1t hanchor
    hbelow hgate

/-- **RIGHT-interior kit application** (Phase 3 — the plan-v4 MEDIUM-risk residual,
    discharged by the anticipated kit-application lemma). The landed closer
    `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1290`) does NOT serve this class
    directly — three signature facts, each read off HEAD source:
    (a) its `hgate` conclusion opens with `a < w` (`SubBracket2V.lean:1305`), but
    `kvE2_sepBundleR` supplies the anchor with `w < x1`, so a truthful gate can never be fed
    the right bundle's anchor;
    (b) `kvE2_sepBundleR_parts` (SW above) deliberately drops the below-clause — no `hbelow`
    in the closer's `kvE_sub2_zXU` shape exists for this class (for a RIGHT-interior σ that
    pattern reads `x < v < w`, the zone-constant header above);
    (c) the bundle's witnesses live in the right-interior middle region `kvE2_sep_zWX1`
    (`w < v < x1`), a zone the left closer's gate-backward clause does not exempt.
    This lemma is the geometry-correct mirror, proved from scratch against the same engine
    (`nf_eval_depth1_fold_iff`, `CarrierKv.lean:466`): the gate's backward clause exempts
    `kvE2_sep_zWX1` (instead of `kvE_sub2_zXU`), whose witnesses the bundle supplies. The
    left closer's `a < w ∧ w < t` head conjuncts are NOT mirrored: in the right geometry the
    corresponding order facts (`w < a`, `a < t`) are already the gate's own antecedents, and
    `x < w` is this lemma's hypothesis. The bit `σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1)` is
    consumed as the antecedent of the bundle's own `bit ⟹ witness` implication — self-owned,
    never a goal. NO filter weakened; `hgate` an explicit threaded hypothesis (Amendment F3),
    never assumed. Bounds ride the model order (`x < w < u < x1 < t`), never a formula
    literal (LITMUS). Rabinovich 2014: Notation 5.2 mirrored slot group (pp.7-8), Cor 5.4
    bounded interior placement (p.9). -/
theorem kvE2_sepBundleR_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w)
    (h : kvE2_sepBundleR (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap w t)
    (hgate : ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨x1, hwx1, hx1t, hpt, hbelow⟩ := h
  have hanchor :=
    kvE2_sepPtX1R_anchor (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap x1 hpt
  obtain ⟨h_atom, h_off, h_fwd, h_bwd⟩ := hgate x1 hwx1 hx1t hanchor
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE2_sep_zWX1
  · -- Right-interior middle region `zWX1 = (w < v < x1)`: the bundle's own below-witness
    -- clause supplies a witness strictly between `w` and the anchor `x1` (Def 3.1, PDF p.4).
    subst hzs
    obtain ⟨u, hwu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    -- `u` lies in `zWX1` relative to env `[x1, w, x, t]` under `x < w < u < x1 < t`.
    have hxu : x < u := hxw.trans hwu
    have hut : u < t := hux1.trans hx1t
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwu) (by decide +revert), iff_of_true hwu rfl⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · -- Every other zone: the gate's backward direction (analog of `kvE_gate` honesty).
    exact h_bwd zs χ hzs hbit

/-- **Per-σ kit application over a realized body** (Phase 3 terminus — the Phase 4 input
    shape): from any realized `kvE2_sepBody` (whose held disjunct rides an arbitrary
    `wo ∈ kvE2_sepArr' qnf` inside the hypothesis-free `kvE2_sepBody_extract`) and per-class
    gate families at the extracted shared pivot, EVERY positive interior owner's depth-1
    `nf_eval` is realized at that pivot: left class via `kvE2_sepBundleL_parts` →
    `kvE_subBracket2V_sound_of_parts` (`kvE2_sepBundleL_sound`), right class via the mirrored
    `kvE2_sepBundleR_sound`. The gate families quantify over the pivot because the extraction
    produces `w` existentially; each gate stays an explicit threaded hypothesis (Amendment F3
    — never assumed). All bits consumed are self-owned enumeration antecedents. -/
theorem kvE2_sepBody_kit_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    (hgateL : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hgateR : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
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
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, hL, hR⟩ :=
    kvE2_sepBody_extract (nf_depth0_char_formula atomMap h_surj) charK qnf M atomMap x t h
  refine ⟨hEpL, hEpR, w, hxw, hwt, hptW, ?_, ?_⟩
  · intro σ hσ hz
    exact kvE2_sepBundleL_sound atomMap h_surj charK σ M w x t hwt (hL σ hσ hz)
      (hgateL w hxw hwt hptW σ hσ hz)
  · intro σ hσ hz
    exact kvE2_sepBundleR_sound atomMap h_surj charK σ M w x t hxw (hR σ hσ hz)
      (hgateR w hxw hwt hptW σ hσ hz)

/-! ## Phase 4 — Outer depth-2 fold `kvE2_outer_fold` (R4, the make-or-break)

Reassemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ realizations delivered by
`kvE2_sepBody_kit_sound` (Phase 3). There is NO landed depth-2 quant-layer fold engine
(`nf_quant_layer_fold_iff`, `NfEFold.lean:391`, folds depth-0 inner subs; the k=2 quant layer
ranges over depth-1 subs), so this theorem IS the assembly: it derives the outer atom layer
from the carrier's own endpoint/witness point types (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW`
head conjuncts through `nfPred_correct`) plus the six outer order bits, zone-classifies the
positive subs through the extracted membership, discharges the two INTERIOR classes via the
Phase-3 kit, and threads the two genuinely provider-conditional residual families as explicit
hypotheses in the Amendment-F3 style (`kvE_subBracket2V_sound_of_outer` composition pattern):

- `hbdry` — realization of the five NON-interior positive placement classes
  (`zPastX3`/`zAtX3`/`zAtW3`/`zAtT3`/`zFutT3`). Their carrier content rides the σ-level
  `charK` E[Σ]-atom literals of `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR`, whose typing into
  arity-4 depth-1 evaluations is exactly the `ExistProviders.correct` step (c) of the
  navigated sub-chain sketch (`NavigatedSpine.lean:445`) — discharged downstream at the
  provider instantiation `charK := P.existF 0`, never assumed here.
- `hexcl` — the outer forward (exclusion) clause: negative subs are unrealized. The depth-2
  carrier pins per-σ content only up to (outer zone, projected 1-type) — the machine-checked
  information-loss record `bracketEndChar_kv_factors` (`CarrierKv.lean:422`) — so this clause
  is provider-conditional in exactly the A1 sense (`PriorInterface.lean:47-59`) and is
  threaded verbatim, never assumed and never discharged vacuously here.

Both families quantify over the pivot `w` because the extraction produces `w` existentially
(the same quantification pattern as `kvE2_sepBody_kit_sound`'s gate families). All bits
consumed remain self-owned enumeration antecedents; no filter is weakened; no `hgate` is
assumed. Rabinovich 2014: Def 3.1 (p.4) ordering/point-type split for the outer atom layer;
Lemma 3.2(2) anchor cap — the statement rides the two fixed anchors `(x,t)` (p.4); §5
bracket assembly with quantifier-free point types (pp.7-9). -/

/-- **Outer depth-2 fold**: from a realized `kvE2_sepBody`, the six
    outer order bits of `qnf.1` (the `BracketCarrierCorrectVPrior` bracket-zone hypotheses,
    `PriorInterface.lean:62-68` — the shape the planned `bracketEndChar_kvE2_sound_two_prior`
    consumer supplies), the two per-class interior gate families (verbatim
    `kvE2_sepBody_kit_sound` shapes: left 6-conjunct excluding `kvE_sub2_zXU`, right
    4-conjunct excluding `kvE2_sep_zWX1` — the two geometries differ), the non-interior
    realization family `hbdry`, and the exclusion family `hexcl`, the depth-2 evaluation
    `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` is assembled at the extracted shared pivot.

    The proof derives (never assumes): the pivot and its bounds from the Phase-3 kit; the
    outer PREDICATE atom bits at each of `w`/`x`/`t` from the head conjuncts of
    `kvE2_sepPtW`/`kvE2_sepEpL`/`kvE2_sepEpR` through `formula_conjList_iff` +
    `nfPred_correct` (Def 3.1 point-type channel, p.4); the outer ORDER atom bits from
    `x < w < t` against the six order hypotheses; the positive-sub zone classification from
    `kvE2_sepPos` membership; and the interior realizations from the Phase-3 kit. Bounds ride
    the model order — never a fresh-witness relative-position formula literal (LITMUS). -/
theorem kvE2_outer_fold {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    (hgateL : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hgateR : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hbdry : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf,
        ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier,
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∃ w : M.carrier,
      nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, hLreal, hRreal⟩ :=
    kvE2_sepBody_kit_sound atomMap h_surj charK qnf M x t h hgateL hgateR
  -- Coordinate 1-types at the three outer points, extracted from the carrier's own
  -- point-type head conjuncts (Def 3.1 point-type channel, PDF p.4).
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
  · -- Outer atom layer at `[w,x,t]`: PREDICATE bits from the three coordinate 1-types,
    -- ORDER bits from `x < w < t` against the six order hypotheses.
    intro a
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
  · -- Outer quant layer: forward via the exclusion family, backward via zone
    -- classification (interior classes through the Phase-3 kit, the rest through the
    -- non-interior realization family).
    intro σ
    constructor
    · rintro ⟨x1, hx1⟩
      by_contra hne
      exact hexcl w hxw hwt hptW σ (Bool.eq_false_iff.mpr hne) x1 hx1
    · intro hbit
      have hmem : σ ∈ kvE2_sepPos qnf := by
        simp only [kvE2_sepPos, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hbit⟩
      by_cases hzL : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
      · exact hLreal σ hmem hzL
      by_cases hzR : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
      · exact hRreal σ hmem hzR
      exact hbdry w hxw hwt hptW σ hmem (by tauto)

-- ============================================================================
-- PIN-ANCHORED FRAGMENT FOLD  (ADDITIVE-ONLY — zero existing decls modified)
--   Grounding: the fragment-extractor derivability analysis (GO: pin-anchored _frag).
--   Deliverables: kvE2_sepGateAtPin_fragL / kvE2_sepGateAtPin_fragR /
--                 kvE2_sepBody_kit_sound_frag / kvE2_outer_fold_frag.
--   REFUTED (never attempt): the ∀-anchor segment-coverage extractor.
--   Consumer: bracketEndChar_kvE2_correct_two_prior_frag (OuterGate.lean).
--   GATE re-diff: everything below this banner is new; nothing above is touched.
-- ============================================================================

/-- **Single-positive-sub fragment predicate** (local restatement of
    `OuterGate.kvE2_sepFragment`, `OuterGate.lean:191`). Restated here rather than imported
    because `OuterGate` imports `SharedWitness` (importing back would create a cycle); the two
    definitions are byte-identical and `OuterGate`'s definitional `rfl` bridges them at the 335
    consumption site. `qnf`'s positive-sub list is exactly the singleton `[σ0]` with `σ0`
    interior-zoned. Depends only on `qnf`, never on a model or provider. -/
def kvE2_sepFragment_frag {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : Prop :=
  ∃ σ0 : NormalForm sig 1 4,
    kvE2_sepPosI qnf = [σ0] ∧
    (nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ0.1 = kvE2_sep_zWT3)

/-- **Nodup-list unique-filter singleton**. A `DecidableEq`-only
    replacement for the `List.filter_eq`/`List.count` replicate route (unavailable here: the
    `→ Bool` function space in `NormalForm sig 1 4` admits no `BEq`, only `DecidableEq`). If a
    duplicate-free list `l` contains `a`, and a boolean predicate `p` is true on `l` at exactly
    the point `a`, then `l.filter p = [a]`. Structural induction; the `Nodup` head-fresh fact
    forces the tail's filter to be `[]`. -/
private theorem kvE2_nodup_filter_unique {α : Type*} [DecidableEq α] {p : α → Bool} {a : α}
    (hp : ∀ x, p x = true ↔ x = a) :
    ∀ {l : List α}, l.Nodup → a ∈ l → l.filter p = [a]
  | [], _, ha => by simp at ha
  | b :: t, hnd, ha => by
    rw [List.nodup_cons] at hnd
    by_cases hb : b = a
    · subst hb
      rw [List.filter_cons_of_pos ((hp b).mpr rfl)]
      have ht : t.filter p = [] := by
        rw [List.filter_eq_nil_iff]
        intro x hx hpx
        exact hnd.1 (((hp x).mp hpx) ▸ hx)
      rw [ht]
    · rw [List.filter_cons_of_neg (by
        intro h; exact hb ((hp b).mp h))]
      exact kvE2_nodup_filter_unique hp hnd.2
        ((List.mem_cons.mp ha).resolve_left (fun h => hb h.symm))

/-- **Interior-singleton realizability witness**. Exhibits a concrete
    `qnf : NormalForm sig 2 3` for which the interior-restricted positive-sub list
    `kvE2_sepPosI qnf` is exactly the singleton `[σ0]` with `σ0` LEFT-interior
    (`nf0_zoneSpec σ0.1 = kvE2_sep_zXW3`), so `kvE2_sepFragment_frag qnf`
    (byte-defeq `OuterGate.kvE2_sepFragment`) holds. This is the non-vacuity ground the
    re-stated soundness half (Phase 5) cites, DIRECTLY REFUTING the old VACUITY NOTE.

    The witness qnf carries FOUR positive subs: the interior `σ0` PLUS the three forced
    characteristic positives at the at-point zones `zAtX3`/`zAtW3`/`zAtT3` (report 07 Refutation 1
    / H4 #1 shape `x < w < t`). The global list `kvE2_sepPos qnf` therefore has FOUR elements — so
    the OLD global-singleton predicate (`kvE2_sepPos qnf = [σ0]`) FAILS for this qnf — while the
    interior filter (`kvE2_sepPosI`) excludes exactly the three at-point positives (each fails the
    `zXW3 ∨ zWT3` interiority test, discharged by `decide`), leaving the single strictly-interior
    `σ0`. This is precisely the RE-SCOPE verdict made concrete: interior-singleton is realizable
    where global-singleton is not. Purely `qnf`-domain (no model / provider), matching the
    predicate's own dependency; each zone is pinned via `nf0_zoneSpec_assemble` (`NfEFold:197`). -/
theorem kvE2_sepFragment_realizable {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] :
    ∃ qnf : NormalForm sig 2 3, kvE2_sepFragment_frag qnf := by
  classical
  let σ0 : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zXW3 (fun _ => false) (fun _ => false), fun _ => false)
  let σX : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zAtX3 (fun _ => false) (fun _ => false), fun _ => false)
  let σW : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zAtW3 (fun _ => false) (fun _ => false), fun _ => false)
  let σT : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zAtT3 (fun _ => false) (fun _ => false), fun _ => false)
  have hz0 : nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 :=
    nf0_zoneSpec_assemble kvE2_sep_zXW3 (fun _ => false) (fun _ => false)
  have hzX : nf0_zoneSpec σX.1 = kvE2_sep_zAtX3 :=
    nf0_zoneSpec_assemble kvE2_sep_zAtX3 (fun _ => false) (fun _ => false)
  have hzW : nf0_zoneSpec σW.1 = kvE2_sep_zAtW3 :=
    nf0_zoneSpec_assemble kvE2_sep_zAtW3 (fun _ => false) (fun _ => false)
  have hzT : nf0_zoneSpec σT.1 = kvE2_sep_zAtT3 :=
    nf0_zoneSpec_assemble kvE2_sep_zAtT3 (fun _ => false) (fun _ => false)
  refine ⟨(fun _ => false, fun σ => decide (σ = σ0 ∨ σ = σX ∨ σ = σW ∨ σ = σT)), σ0, ?_, Or.inl hz0⟩
  simp only [kvE2_sepPosI, kvE2_sepPos, List.filter_filter]
  refine kvE2_nodup_filter_unique ?_ (Finset.nodup_toList _)
    (Finset.mem_toList.mpr (Finset.mem_univ σ0))
  intro x
  -- `simp only [kvE2_sepPosI, …]` above already does what this `dsimp only` used to,
  -- so it now reports "no progress"
  rw [Bool.and_eq_true]
  constructor
  · rintro ⟨hint, hmem⟩
    rw [decide_eq_true_eq] at hmem hint
    rcases hmem with h | h | h | h
    · exact h
    · rw [h, hzX] at hint; exact absurd hint (by decide)
    · rw [h, hzW] at hint; exact absurd hint (by decide)
    · rw [h, hzT] at hint; exact absurd hint (by decide)
  · rintro rfl
    exact ⟨by rw [decide_eq_true_eq]; exact Or.inl hz0,
           by rw [decide_eq_true_eq]; exact Or.inl rfl⟩

/-- **LEFT-interior parts closer at the PIN** (the continuation-inlining
    wrapper). Inlines `kvE_subBracket2V_sound_of_parts`'s continuation
    (`SubBracket2V.lean:1324-1345`)
    with the four gate conjuncts supplied AT the specific pin `x1` (`x < x1 < w`), NOT as a ∀-anchor
    over `(x,t)` (whose universal form is REFUTED, report §1). The gate producer
    (`kvE2_sepGateAtPin_fragL`) extracts `x1` from the body and derives the four conjuncts at THAT
    pin, then calls this closer — the pin-specific forward conjunct (`h_fwd`) is never demanded at
    an
    arbitrary anchor. Additive; consumes `nf_eval_depth1_fold_iff`/`nfPred_correct` unchanged. -/
theorem kvE2_sepBundleL_sound_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwt : w < t)
    (x1 : M.carrier) (hx1w : x1 < w)
    (hbelow : ∀ χ : NormalForm sig 0 1,
      σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
      ∃ u : M.carrier, x < u ∧ u < x1 ∧
        (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred).eval_at M atomMap u)
    (h_atom : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1)
    (h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)
    (h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) →
      σ.2 (nf0_assemble zs χ σ.1) = true)
    (h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
      σ.2 (nf0_assemble zs χ σ.1) = true →
      ∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) :
    ∃ x1' : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE_sub2_zXU
  · subst hzs
    obtain ⟨u, hxu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · exact h_bwd zs χ hzs hbit

/-- **RIGHT-interior parts closer at the PIN** (mirror of
    `kvE2_sepBundleL_sound_frag`). Inlines `kvE2_sepBundleR_sound`'s continuation
    with the four gate conjuncts supplied at the specific pin `x1` (`w < x1 < t`), backward
    exception
    zone `kvE2_sep_zWX1`. The `x < w` head is this lemma's hypothesis. Additive. -/
theorem kvE2_sepBundleR_sound_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w)
    (x1 : M.carrier) (_hwx1 : w < x1) (hx1t : x1 < t)
    (hbelow : ∀ χ : NormalForm sig 0 1,
      σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true →
      ∃ u : M.carrier, w < u ∧ u < x1 ∧
        (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred).eval_at M atomMap u)
    (h_atom : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1)
    (h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)
    (h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) →
      σ.2 (nf0_assemble zs χ σ.1) = true)
    (h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
      σ.2 (nf0_assemble zs χ σ.1) = true →
      ∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) :
    ∃ x1' : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE2_sep_zWX1
  · subst hzs
    obtain ⟨u, hwu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    have hxu : x < u := hxw.trans hwu
    have hut : u < t := hux1.trans hx1t
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwu) (by decide +revert), iff_of_true hwu rfl⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · exact h_bwd zs χ hzs hbit

/-- **Point-location among strictly-monotone bracket witnesses** (the
    combinatorial core of the pin-anchored forward-zone derivation). For a strictly monotone
    finite witness family `ws : Fin (k+1) → M.carrier`, any point `v` is EITHER one of the
    witnesses, OR below the first, OR strictly between two consecutive witnesses, OR above the
    last — exactly the four segment regions of `IntervalPattern.holds_eq_succ`
    (`ExistsForallNF.lean:197-203`). Model-general (rides `M.carrier`'s `LinearOrder`); carries
    no fold/bracket content. This converts an arbitrary model point of an interior forward-zone
    into the region whose landed segment/witness channel closes it. Additive. -/
theorem kvE2_sep_locate_witness {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {k : Nat}
    (ws : Fin (k + 1) → M.carrier)
    (v : M.carrier) :
    (∃ i : Fin (k + 1), v = ws i) ∨
    (v < ws ⟨0, Nat.succ_pos k⟩) ∨
    (∃ i : Fin k, ws ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ < v ∧
      v < ws ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩) ∨
    (ws ⟨k, Nat.lt_succ_self k⟩ < v) := by
  classical
  by_cases hex : ∃ i : Fin (k + 1), v = ws i
  · exact Or.inl hex
  · push Not at hex
    have htri : ∀ i : Fin (k + 1), ws i < v ∨ v < ws i := by
      intro i
      rcases lt_trichotomy (ws i) v with h | h | h
      · exact Or.inl h
      · exact absurd h.symm (hex i)
      · exact Or.inr h
    by_cases hlow : v < ws ⟨0, Nat.succ_pos k⟩
    · exact Or.inr (Or.inl hlow)
    · have h0 : ws ⟨0, Nat.succ_pos k⟩ < v := (htri ⟨0, Nat.succ_pos k⟩).resolve_right hlow
      have hSne : (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).Nonempty :=
        ⟨⟨0, Nat.succ_pos k⟩, Finset.mem_filter.mpr ⟨Finset.mem_univ _, h0⟩⟩
      set m := (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).max' hSne with hmdef
      have hmS := (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).max'_mem hSne
      have hmv : ws m < v := (Finset.mem_filter.mp hmS).2
      by_cases hmk : m.val = k
      · right; right; right
        have hme : m = ⟨k, Nat.lt_succ_self k⟩ := Fin.ext hmk
        rwa [hme] at hmv
      · right; right; left
        have hmlt : m.val < k := lt_of_le_of_ne (Nat.lt_succ_iff.mp m.isLt) hmk
        refine ⟨⟨m.val, hmlt⟩, ?_, ?_⟩
        · have hme : (⟨m.val, Nat.lt_succ_of_lt hmlt⟩ : Fin (k + 1)) = m := Fin.ext rfl
          rw [hme]; exact hmv
        · have hnext : (⟨m.val + 1, Nat.succ_lt_succ hmlt⟩ : Fin (k + 1)) ∉
              Finset.univ.filter (fun i : Fin (k + 1) => ws i < v) := by
            intro hc
            have hle := Finset.le_max' _ _ hc
            rw [← hmdef] at hle
            have : m.val + 1 ≤ m.val := Fin.le_def.mp hle
            omega
          have hnv : ¬ (ws ⟨m.val + 1, Nat.succ_lt_succ hmlt⟩ < v) := fun hc =>
            hnext (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hc⟩)
          exact (htri ⟨m.val + 1, Nat.succ_lt_succ hmlt⟩).resolve_left hnv

/-- **Zone-spec determinacy** (shared closer for the pin-anchored forward
    derivation). `zoneHolds` characterizes each zone-spec coordinate as a biconditional against
    `v`'s order relation to the fixed env points; on a `LinearOrder` carrier those relations are
    determined, so at most one zone spec can hold at a given point. Model-general, additive; the
    forward zone case (`h_fwd`) uses it to convert `v`'s realized zone into the specific
    `kvE_sub2_z*`/`kvE2_sep_z*` spec whose segment/endpoint channel excludes it. -/
theorem zoneHolds_unique {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (v : M.carrier) (za zb : ZoneSpec n)
    (ha : zoneHolds M env za v) (hb : zoneHolds M env zb v) : za = zb := by
  funext i
  obtain ⟨ha1, ha2⟩ := ha i
  obtain ⟨hb1, hb2⟩ := hb i
  exact Prod.ext (Bool.eq_iff_iff.mpr (ha1.symm.trans hb1))
    (Bool.eq_iff_iff.mpr (ha2.symm.trans hb2))

/-- Generic list fact (mid-segment pin bookkeeping): in a `Nodup`-flatten
    list of groups, an element `a` known to occur in group `k` occurs in the first `n` groups'
    flatten iff `k < n`. Resolves the `kvE2_sepSegLForSub`/`kvE2_sepSegRForSub` pin-`contains`
    guard from the pin's group index against `v`'s witness position. -/
theorem kvE2_sep_pin_mem_take_flatten_iff {α : Type*} (gL : List (List α))
    (hnd : gL.flatten.Nodup) (a : α) (k : ℕ) (hk : k < gL.length) (hak : a ∈ gL[k]'hk) (n : ℕ) :
    a ∈ (gL.take n).flatten ↔ k < n := by
  rw [List.nodup_flatten] at hnd
  obtain ⟨_, hdisj⟩ := hnd
  rw [List.pairwise_iff_getElem] at hdisj
  constructor
  · intro hmem
    rw [List.mem_flatten] at hmem
    obtain ⟨grp, hgrp, hin⟩ := hmem
    obtain ⟨j, hjlen, hgetj⟩ := List.mem_iff_getElem.mp hgrp
    have hjmin : j < min n gL.length := by simpa [List.length_take] using hjlen
    have hjn : j < n := lt_of_lt_of_le hjmin (Nat.min_le_left _ _)
    have hjL : j < gL.length := lt_of_lt_of_le hjmin (Nat.min_le_right _ _)
    have hgrp_eq : grp = gL[j]'hjL := by rw [← hgetj]; simp [List.getElem_take]
    have haj : a ∈ gL[j]'hjL := hgrp_eq ▸ hin
    have hjk : j = k := by
      by_contra hne
      rcases Nat.lt_or_gt_of_ne hne with hlt | hlt
      · exact List.disjoint_left.mp (hdisj j k hjL hk hlt) haj hak
      · exact List.disjoint_left.mp (hdisj k j hk hjL hlt) hak haj
    omega
  · intro hkn
    rw [List.mem_flatten]
    refine ⟨gL[k]'hk, ?_, hak⟩
    have hlt : k < (gL.take n).length := by rw [List.length_take]; omega
    have hmm := List.getElem_mem hlt
    rwa [List.getElem_take] at hmm

/-- Extract the two per-owner LEFT-endpoint literals (`zPastX4` Since-literal, `zAtX4`
    at-literal) for an interior owner `σ` from a realized `kvE2_sepEpL` at `x`
    (exterior/boundary forward exclusion). -/
theorem kvE2_sepEpL_owner_lits {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3)
    (hep : (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zPastX4 χ) (Formula.snce (charBase χ) Formula.top))
      ∧ temporal_truth M atomMap x
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX4 χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap x (kvE2_sepEpL charBase charK qnf).formula := hep
  simp only [kvE2_sepEpL] at hep'
  have hall := (formula_conjList_iff M atomMap x _).mp hep'
  have hσsrc : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
    List.mem_append.mpr (Or.inl hσ)
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  refine ⟨hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩))),
    hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩)))⟩
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))

/-- Extract the two per-owner RIGHT-endpoint literals (`zAtT4` at-literal, `zFutT4`
    Until-literal) for an interior owner `σ` from a realized `kvE2_sepEpR` at `t` (mirror of
    `kvE2_sepEpL_owner_lits`). -/
theorem kvE2_sepEpR_owner_lits {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3)
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
    List.mem_append.mpr (Or.inl hσ)
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  refine ⟨hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩))),
    hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩)))⟩
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))

/-- Extract the per-owner `zAtWL` at-`w` literal for an interior owner `σ` from a realized
    `kvE2_sepPtW` at `w` (witness case — the `j = |gL|` AT-`w` sub-case;
    mirror of `kvE2_sepEpL_owner_lits`). -/
theorem kvE2_sepPtW_owner_lit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3)
    (hep : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWL χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap w (kvE2_sepPtW charBase charK qnf).formula := hep
  simp only [kvE2_sepPtW] at hep'
  have hall := (formula_conjList_iff M atomMap w _).mp hep'
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  exact hall _ (List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
    (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσ,
      List.mem_cons.mpr (Or.inr (List.mem_map.mpr ⟨χ, hχu, rfl⟩))⟩)))))))

/-- Extract the per-owner `zAtX1L` at-`x1` literal for owner `σ` from a realized
    `kvE2_sepPtX1L` at the pin `x1` (witness case — the `j = iσ` AT-`x1`
    sub-case; mirror of `kvE2_sepEpL_owner_lits`). -/
theorem kvE2_sepPtX1L_owner_lit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x1 : M.carrier)
    (hep : (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap x1) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x1
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1L χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap x1 (kvE2_sepPtX1L charBase charK σ).formula := hep
  simp only [kvE2_sepPtX1L] at hep'
  have hall := (formula_conjList_iff M atomMap x1 _).mp hep'
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  exact hall _ (List.mem_cons.mpr (Or.inr (List.mem_map.mpr ⟨χ, hχu, rfl⟩)))

/-- **LEFT pin-anchored gate producer**. From a realized
    `kvE2_sepBody` in the SINGLE-positive fragment (`hfrag`) with the sole positive sub `σ0`
    left-interior (`hz`), plus provider-correctness `hcorrK` at the pin (the
    `ExistProviders.correct`
    step 335 owns), the `kvE2_sepBody_kit_sound` conclusion is assembled by re-running the joint
    bracket extraction INLINE (keeping the segment components `holds_eq_succ` 4/5/6 discarded by
    `kvE2_sepBody_extract`), then deriving the four pin conjuncts and calling the landed
    `kvE2_sepBundleL_sound_frag`. Every conjunct is derived AT the extracted pin `x1` (`x < x1 <
    w`),
    NEVER at an arbitrary ∀-anchor (report §1 refutation). Additive; `hcorrK` an explicit
    hypothesis, never discharged. -/
theorem kvE2_sepGateAtPin_fragL {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
      have hjχm : jχ < ((kvE2_sepTieGroupedL wo).map
          (kvE2_sepClassType charBase charK)).length := by
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
        -- reconstruct σ.1 from its three Def-3.1 channels via per-atom congrFun bridges
        -- (the `nf0_assemble` order case does NOT simp-reduce — nested `Fin.cases` with motive —
        -- so we rewrite each σ.1 bit to a CLOSED qnf.1/zXW3 value before deciding it)
        have hpf : (nfk_projFresh σ).1 = nf0_projFresh σ.1 := by
          funext a
          match a with
          | .pred p i =>
            have hi : i = ⟨0, by omega⟩ := Subsingleton.elim i _
            subst hi; rfl
          | .order i j hij => exact absurd (Subsingleton.elim i j) hij
        obtain ⟨hc0a, -⟩ := hcorrK σ x1 hanchor
        -- normalize each raw σ.1 bit to a CLOSED value via congrFun on hdrop/hz
        -- (the `.succ` forms from mergeNF/zoneSpec are reduced back to Fin literals by
        --  `Fin.succ_mk` + `Nat.reduceAdd`, so the rewrites match the matched atom)
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
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ hne) = true := by
            exact congrArg Prod.fst (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hx1w (by decide)
        | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ hne) = false := by
            exact congrArg Prod.fst (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hxx1) (by decide)
        | .order ⟨0, _⟩ ⟨3, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨3, by omega⟩ hne) = true := by
            exact congrArg Prod.fst (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true (hx1w.trans hwt) (by decide)
        | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ hne) = false := by
            exact congrArg Prod.snd (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hx1w) (by decide)
        | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ hne) = true := by
            exact congrArg Prod.snd (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hxx1 (by decide)
        | .order ⟨3, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨3, by omega⟩ ⟨0, by omega⟩ hne) = false := by
            exact congrArg Prod.snd (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm (hx1w.trans hwt)) (by decide)
        | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yx] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm (hxx1.trans hx1w)) (by decide)
        | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xy] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true (hxx1.trans hx1w) (by decide)
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
          exact iff_of_true (hxx1.trans (hx1w.trans hwt)) (by decide)
        | .order ⟨3, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_tx] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm (hxx1.trans (hx1w.trans hwt))) (by decide)
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
        have hndL : (kvE2_sepTieGroupedL wo).flatten.Nodup := by
          rw [kvE2_sepTieGroupedL_flatten]; exact kvE2_sepSlotsLOf_nodup qnf hwo'
        have hsc' : (KvE2SepSlot.lX1 σ) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
          rw [hgetiσ]; exact hsc
        have hσIn : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 :=
          List.mem_filter.mpr ⟨hσ0pos, by simp only [decide_eq_true_eq]; exact hz⟩
        rcases kvE2_sep_locate_witness M ws v with ⟨j, hjv⟩ | hlow | ⟨i, hi1, hi2⟩ | hhigh
        · -- WITNESS case: `v = ws j` is a bracket point; its point type forces the χ-bit ON,
          -- contradicting `hbit`. `j`'s class index vs the pin `iσ` and `|gL|` fixes v's zone.
          subst hjv
          have hxv : x < ws j := (hrange j).1
          have hvt : ws j < t := (hrange j).2
          -- frag: every arrangement owner is σ, so every joint slot is one of σ's own slots
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
          -- base-type uniqueness at `ws j` (nf_eval_unique): any realized `charBase χ'` is χ
          have hχeq : ∀ χ' : NormalForm sig 0 1,
              (⟨charBase χ'⟩ : TemporalPred).eval_at M atomMap (ws j) → χ' = χ := by
            intro χ' hb
            have hnf : nf_eval_nf M 0 1 (fun _ => ws j) χ' :=
              (nfPred_correct M atomMap h_surj χ' (ws j)).mp hb
            exact nf_eval_unique M 0 1 _ χ' χ hnf hχv
          rcases Nat.lt_trichotomy j.val (kvE2_sepTieGroupedL wo).length with hjm | hjm | hjm
          · -- LEFT group: point type is `classType gL[j]`; a member slot forces the bit
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
            rw [kvE2_sepSlotsLFor, if_pos hz] at hsF
            rcases List.mem_append.mp hsF with hSX | hrest
            · -- s = .lXU σ χ' → zXU zone (j < iσ by gidx), bit true, contradiction
              obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hSX
              have hχ'eq : χ' = χ := hχeq χ' hslotty
              rw [hχ'eq] at hχ'S hsmem
              have hbitXU : kvE2_sepBits σ kvE_sub2_zXU χ = true := (List.mem_filter.mp hχ'S).2
              have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lXU σ χ)
                  < kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ) :=
                kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
                  (by rw [kvE2_sepSlotBlock]
                      exact List.mem_append_left _ (kvE2_sep_lXU_mem_slotsLFor hz hbitXU))
                  (by rw [kvE2_sepSlotBlock]
                      exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
                  rfl Nat.zero_lt_one
              have hji : j.val < iσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
                (kvE2_sepSlotsLOf wo) hksortL hjm hiσ hsmem hsc' hkey
              have hvx1 : ws j < x1 := by
                rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr hji)
              have hvw : ws j < w := hvx1.trans hx1w
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE_sub2_zXU (ws j) := by
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
              have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ (ws j) zs _ hzv hpos
              rw [hzeq] at hbit
              simp only [kvE2_sepBits] at hbitXU
              exact Bool.false_ne_true (hbit.symm.trans hbitXU)
            · rcases List.mem_cons.mp hrest with rfl | hUW
              · -- s = .lX1 σ → j = iσ (pin uniqueness), ws j = x1, AT-x1 via ptX1L
                have hjeq : j.val = iσ := by
                  rcases Nat.lt_trichotomy j.val iσ with h | h | h
                  · exfalso
                    have hstrict := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
                      (kvE2_sepSlotsLOf wo) hksortL
                    have hlt := List.pairwise_iff_getElem.mp hstrict j.val iσ hjm hiσ h
                      (KvE2SepSlot.lX1 σ) hsmem (KvE2SepSlot.lX1 σ) hsc'
                    omega
                  · exact h
                  · exfalso
                    have hstrict := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
                      (kvE2_sepSlotsLOf wo) hksortL
                    have hlt := List.pairwise_iff_getElem.mp hstrict iσ j.val hiσ hjm h
                      (KvE2SepSlot.lX1 σ) hsc' (KvE2SepSlot.lX1 σ) hsmem
                    omega
                have hjx1 : ws j = x1 := by
                  rw [hx1def]; exact congrArg ws (Fin.ext hjeq)
                have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                    kvE2_sep_zAtX1L (ws j) := by
                  intro k
                  match k with
                  | ⟨0, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_irrefl x1)
                      (by decide +revert),
                      iff_of_false (by rw [hjx1]; exact lt_irrefl x1) (by decide +revert)⟩
                  | ⟨1, _⟩ => exact ⟨iff_of_true (by rw [hjx1]; exact hx1w) rfl,
                      iff_of_false (by rw [hjx1]; exact lt_asymm hx1w) (by decide +revert)⟩
                  | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_asymm hxx1)
                      (by decide +revert),
                      iff_of_true (by rw [hjx1]; exact hxx1) rfl⟩
                  | ⟨3, _⟩ => exact ⟨iff_of_true (by rw [hjx1]; exact hx1w.trans hwt) rfl,
                      iff_of_false (by rw [hjx1]; exact lt_asymm (hx1w.trans hwt))
                          (by decide +revert)⟩
                have hzeq : zs = kvE2_sep_zAtX1L := zoneHolds_unique M _ (ws j) zs _ hzv hpos
                have hlit := kvE2_sepPtX1L_owner_lit charBase charK σ M atomMap (ws j) hslotty χ
                have hbitX1 : kvE2_sepBits σ kvE2_sep_zAtX1L χ = false := by
                  rw [hzeq] at hbit; exact hbit
                rw [hbitX1] at hlit
                simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
                exact hlit hχbase
              · -- s = .lUW σ χ' → zUW zone (iσ < j by gidx), bit true, contradiction
                obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hUW
                have hχ'eq : χ' = χ := hχeq χ' hslotty
                rw [hχ'eq] at hχ'S hsmem
                have hbitUW : kvE2_sepBits σ kvE_sub2_zUW χ = true := (List.mem_filter.mp hχ'S).2
                have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ)
                    < kvE2_sepSlotGIdx wo (KvE2SepSlot.lUW σ χ) :=
                  kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
                    (by rw [kvE2_sepSlotBlock]
                        exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
                    (by rw [kvE2_sepSlotBlock]
                        exact List.mem_append_left _ (kvE2_sep_lUW_mem_slotsLFor hz hbitUW))
                    rfl Nat.one_lt_two
                have hji : iσ < j.val := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
                  (kvE2_sepSlotsLOf wo) hksortL hiσ hjm hsc' hsmem hkey
                have hx1v : x1 < ws j := by
                  rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr hji)
                have hvw : ws j < w := by
                  rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr hjmap)
                have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                    kvE_sub2_zUW (ws j) := by
                  intro k
                  match k with
                  | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                      hx1v rfl⟩
                  | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                      (by decide +revert)⟩
                  | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true
                      hxv rfl⟩
                  | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                      (by decide +revert)⟩
                have hzeq : zs = kvE_sub2_zUW := zoneHolds_unique M _ (ws j) zs _ hzv hpos
                rw [hzeq] at hbit
                simp only [kvE2_sepBits] at hbitUW
                exact Bool.false_ne_true (hbit.symm.trans hbitUW)
          · -- j = |gL| : ws j = w, AT-w case via ptW
            have hjw : ws j = w := by
              rw [hwdef]; exact congrArg ws (Fin.ext (hjm.trans hlenL))
            have hlit := kvE2_sepPtW_owner_lit charBase charK qnf M atomMap w σ hσIn hptW χ
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE2_sep_zAtWL (ws j) := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_asymm hx1w)
                  (by decide +revert),
                  iff_of_true (by rw [hjw]; exact hx1w) rfl⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_irrefl w) (by decide +revert),
                  iff_of_false (by rw [hjw]; exact lt_irrefl w) (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_asymm hxw) (by decide +revert),
                  iff_of_true (by rw [hjw]; exact hxw) rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true (by rw [hjw]; exact hwt) rfl,
                  iff_of_false (by rw [hjw]; exact lt_asymm hwt) (by decide +revert)⟩
            have hzeq : zs = kvE2_sep_zAtWL := zoneHolds_unique M _ (ws j) zs _ hzv hpos
            have hbitW : kvE2_sepBits σ kvE2_sep_zAtWL χ = false := by
              rw [hzeq] at hbit; exact hbit
            rw [hbitW] at hlit
            simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
            exact hlit (by rw [← hjw]; exact hχbase)
          · -- RIGHT group: point type `classType gR[j']`; only `.lWT` slots → zWT zone
            set jr := j.val - (kvE2_sepTieGroupedL wo).length - 1 with hjrdef
            have hlenR : (kvE2_sepTieGroupedR wo).length =
                (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedR wo)).length := by rw [List.length_map]
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
            rw [kvE2_sepSlotsRFor, if_pos hz] at hsF
            obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hsF
            have hχ'eq : χ' = χ := hχeq χ' hslotty
            rw [hχ'eq] at hχ'S
            have hbitWT : kvE2_sepBits σ kvE_sub2_zWT χ = true := (List.mem_filter.mp hχ'S).2
            have hwv : w < ws j := by
              rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
            have hx1v : x1 < ws j := hx1w.trans hwv
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zWT (ws j) := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v
                  rfl⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                  rfl⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ (ws j) zs _ hzv hpos
            rw [hzeq] at hbit
            simp only [kvE2_sepBits] at hbitWT
            exact Bool.false_ne_true (hbit.symm.trans hbitWT)
        · -- hlow : v < ws 0
          rcases lt_or_ge x v with hxv | hvx
          · -- x < v < ws 0 ⊆ (x, x1) : zXU
            have hvx1 : v < x1 := by
              rcases Nat.eq_zero_or_pos iσ with h0 | hpos0
              · have hx1e : x1 = ws ⟨0, by omega⟩ := by rw [hx1def]; exact congrArg ws (Fin.ext h0)
                rw [hx1e]; exact hlow
              · exact hlow.trans (hmono _ _ (Fin.mk_lt_mk.mpr hpos0))
            have hvw : v < w := hvx1.trans hx1w
            have hvt : v < t := hvw.trans hwt
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zXU v := by
              intro i
              match i with
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
                List.take_zero, List.flatten_nil, List.length_nil, 
                kvE2_sepSegLForSub, hz, List.contains_nil, Nat.zero_le,
                Bool.false_eq_true, if_false, if_true] at hh
              exact (formula_conjList_iff M atomMap v _).mp hh _ List.mem_cons_self
            have hbitX : kvE2_sepBits σ kvE_sub2_zXU χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hsegF hbitX hχbase
          · -- v ≤ x : boundary/exterior via hepL
            rcases lt_or_eq_of_le hvx with hvltx | hveqx
            · -- v < x : zPastX4, hepL Since-literal
              have hvx1 : v < x1 := hvltx.trans hxx1
              have hvw : v < w := hvltx.trans hxw
              have hvt : v < t := hvltx.trans (hxw.trans hwt)
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
              have hlit := (kvE2_sepEpL_owner_lits charBase charK qnf M atomMap x σ hσIn hepL χ).1
              rw [hbitP] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              exact hlit ⟨v, hvltx, hχbase, fun r _ _ hf => hf⟩
            · -- v = x : zAtX4, hepL at-x literal
              have hvx1 : v < x1 := by rw [hveqx]; exact hxx1
              have hvw : v < w := by rw [hveqx]; exact hxw
              have hvt : v < t := by rw [hveqx]; exact hxw.trans hwt
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
              have hlit := (kvE2_sepEpL_owner_lits charBase charK qnf M atomMap x σ hσIn hepL χ).2
              rw [hbitA] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              rw [hveqx] at hχbase
              exact hlit hχbase
        · -- mid : ws ⟨i⟩ < v < ws ⟨i+1⟩
          have hsm := hsegMid i v hi1 hi2
          have hxv : x < v := lt_trans (hrange _).1 hi1
          by_cases hcut : (i : ℕ) + 1 ≤ (kvE2_sepTieGroupedL wo).length
          · -- left cut: v ∈ (x, w); zone zXU or zUW by pin index
            rw [kvE2_sepSegsG, if_pos hcut] at hsm
            simp only [kvE2_sepSegLAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegLForSub, if_pos hz, ← kvE2_sep_take_flatten_prefix] at hseg1
            have hvw : v < w := by
              rw [hwdef]; exact lt_of_lt_of_le hi2 (hws_le _ _ _ _ (by omega))
            have hvt : v < t := hvw.trans hwt
            by_cases hpin : iσ ≤ (i : ℕ)
            · -- pin ≤ i → v > x1 → zUW
              have hx1v : x1 < v := by
                rw [hx1def]; exact lt_of_le_of_lt (hws_le _ _ _ _ hpin) hi1
              have hmem : (KvE2SepSlot.lX1 σ) ∈ ((kvE2_sepTieGroupedL wo).take
                  ((i : ℕ) + 1)).flatten :=
                (kvE2_sep_pin_mem_take_flatten_iff _ hndL _ iσ hiσ hsc' _).mpr (by omega)
              rw [if_pos (List.contains_iff_mem.mpr hmem)] at hseg1
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE_sub2_zUW v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE_sub2_zUW := zoneHolds_unique M _ v zs kvE_sub2_zUW hzv hpos
              have hbitU : kvE2_sepBits σ kvE_sub2_zUW χ = false := by rw [hzeq] at hbit; exact hbit
              exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zUW χ M atomMap v hseg1 hbitU
                  hχbase
            · -- pin > i → v < x1 → zXU
              have hvx1 : v < x1 := by
                rw [hx1def]; exact lt_of_lt_of_le hi2 (hws_le _ _ _ _ (by omega))
              have hnmem : (KvE2SepSlot.lX1 σ) ∉
                  ((kvE2_sepTieGroupedL wo).take ((i : ℕ) + 1)).flatten := by
                intro hc
                exact absurd ((kvE2_sep_pin_mem_take_flatten_iff _ hndL _ iσ hiσ hsc' _).mp hc)
                    (by omega)
              rw [if_neg (fun hc => hnmem (List.contains_iff_mem.mp hc))] at hseg1
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
              exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hseg1 hbitX
                  hχbase
          · -- right cut: v ∈ (w, t) → zWT
            rw [kvE2_sepSegsG, if_neg hcut] at hsm
            simp only [kvE2_sepSegRAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegRForSub, if_pos hz] at hseg1
            have hwv : w < v := by
              rw [hwdef]; exact lt_of_le_of_lt (hws_le _ _ _ _ (by omega)) hi1
            have hvt : v < t := lt_trans hi2 (hrange _).2
            have hx1v : x1 < v := by
              rw [hx1def]; exact lt_of_le_of_lt (hws_le _ _ _ _ (by omega)) hi1
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
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ v zs kvE_sub2_zWT hzv hpos
            have hbitW : kvE2_sepBits σ kvE_sub2_zWT χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zWT χ M atomMap v hseg1 hbitW hχbase
        · -- hhigh : ws ⟨last⟩ < v
          have hwv : w < v :=
            lt_of_le_of_lt (by rw [hwdef]; exact hws_le _ _ _ _ (by omega)) hhigh
          have hxv : x < v := lt_trans hxw hwv
          have hx1v : x1 < v := lt_trans hx1w hwv
          rcases lt_or_ge v t with hvltt | htlev
          · -- w < v < t → zWT via hsegLast
            have hsm := hsegLast v hhigh hvltt
            rw [kvE2_sepSegsG, if_neg (show ¬ _ from by simp only [hlenL]; omega)] at hsm
            simp only [kvE2_sepSegRAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegRForSub, if_pos hz] at hseg1
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
          · -- t ≤ v : boundary/exterior via hepR
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
              have hlit := (kvE2_sepEpR_owner_lits charBase charK qnf M atomMap t σ hσIn hepR χ).2
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
              have hlit := (kvE2_sepEpR_owner_lits charBase charK qnf M atomMap t σ hσIn hepR χ).1
              rw [hbitAT] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              rw [← hteqv] at hχbase
              exact hlit hχbase
      have h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
          σ.2 (nf0_assemble zs χ σ.1) = true →
          ∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ := by
        intro zs χ hzsne hbit
        have hσIn : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 :=
          List.mem_filter.mpr ⟨hσ0pos, by simp only [decide_eq_true_eq]; exact hz⟩
        have tonf : ∀ (v : M.carrier),
            temporal_truth M atomMap v (charBase χ) → nf_eval_nf M 0 1 (fun _ => v) χ := by
          intro v hv; rw [hcb] at hv; exact (nfPred_correct M atomMap h_surj χ v).mp hv
        -- classify: a true bit forces `zs` among the nine inner-consistent zones (gate clause iv)
        have hcons : kvE2_sepInnerConsistentL zs := by
          by_contra hncons
          rw [hg.2.2.2.1 σ hσ0true hz zs χ hncons] at hbit
          exact absurd hbit (by decide)
        rcases hcons with h | h | h | h | h | h | h | h | h
        · -- zPastX4  (v < x)
          have hzp : zs = kvE2_sep_zPastX4 := h
          rw [hzp] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zPastX4 χ = true := hbit
          have hlit := (kvE2_sepEpL_owner_lits charBase charK qnf M atomMap x σ hσIn hepL χ).1
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          obtain ⟨s, hsx, hχs, -⟩ := hlit
          have hsx1 : s < x1 := hsx.trans hxx1
          have hsw : s < w := hsx.trans hxw
          have hst : s < t := hsx.trans (hxw.trans hwt)
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
          have hlit := (kvE2_sepEpL_owner_lits charBase charK qnf M atomMap x σ hσIn hepL χ).2
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨x, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hxx1 rfl, iff_of_false (lt_asymm hxx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_irrefl x) (by decide +revert),
              iff_of_false (lt_irrefl x) (by decide +revert)⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true (hxw.trans hwt) rfl,
              iff_of_false (lt_asymm (hxw.trans hwt)) (by decide +revert)⟩
        · -- zXU  (excluded by hypothesis)
          exact absurd h hzsne
        · -- zAtX1L  (v = x1)
          have hzx1 : zs = kvE2_sep_zAtX1L := h
          rw [hzx1] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtX1L χ = true := hbit
          have hlit := kvE2_sepPtX1L_owner_lit charBase charK σ M atomMap x1 hpt_pin χ
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨x1, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_irrefl x1) (by decide +revert),
              iff_of_false (lt_irrefl x1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hx1w rfl, iff_of_false (lt_asymm hx1w) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxx1) (by decide +revert), iff_of_true hxx1 rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true (hx1w.trans hwt) rfl,
              iff_of_false (lt_asymm (hx1w.trans hwt)) (by decide +revert)⟩
        · -- zUW  (x1 < v < w) : mirror of `hbelow`, with the `.lUW` slot above the pin
          have hzuw : zs = kvE_sub2_zUW := h
          rw [hzuw] at hbit ⊢
          have hbitT : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true := hbit
          have hmemU : (KvE2SepSlot.lUW σ χ) ∈ kvE2_sepSlotsLOf wo :=
            kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lUW_mem_slotsLFor hz hbitT)
          rw [← kvE2_sepTieGroupedL_flatten wo] at hmemU
          obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
          obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp hd
          have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ)
              < kvE2_sepSlotGIdx wo (KvE2SepSlot.lUW σ χ) :=
            kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
              (by rw [kvE2_sepSlotBlock]
                  exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
              (by rw [kvE2_sepSlotBlock]
                  exact List.mem_append_left _ (kvE2_sep_lUW_mem_slotsLFor hz hbitT))
              rfl Nat.one_lt_two
          have hain : (KvE2SepSlot.lUW σ χ) ∈ (kvE2_sepTieGroupedL wo)[jχ]'hjχ := by
            rw [hgetjχ]; exact hsd
          have hbin : (KvE2SepSlot.lX1 σ) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
            rw [hgetiσ]; exact hsc
          have hij : iσ < jχ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
            (kvE2_sepSlotsLOf wo) hksortL hiσ hjχ hbin hain hkey
          have hjχm : jχ < ((kvE2_sepTieGroupedL wo).map
              (kvE2_sepClassType charBase charK)).length := by
            simp only [List.length_map]; omega
          have hjtot : jχ < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
              + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
                  omega
          have hx1v : x1 < ws ⟨jχ, hjtot⟩ := by
            rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr hij)
          have hvw : ws ⟨jχ, hjtot⟩ < w := by
            rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr hjχm)
          have hxv : x < ws ⟨jχ, hjtot⟩ := (hrange _).1
          have hvt : ws ⟨jχ, hjtot⟩ < t := (hrange _).2
          have hchar := hpt' jχ hjtot
          rw [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at hchar
          have hcharχ := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hchar hsd
          refine ⟨ws ⟨jχ, hjtot⟩, ?_, tonf _ hcharχ⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by decide +revert)⟩
        · -- zAtWL  (v = w)
          have hzw : zs = kvE2_sep_zAtWL := h
          rw [hzw] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtWL χ = true := hbit
          have hlit := kvE2_sepPtW_owner_lit charBase charK qnf M atomMap w σ hσIn hptW χ
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨w, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1w) (by decide +revert), iff_of_true hx1w rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_irrefl w) (by decide +revert),
              iff_of_false (lt_irrefl w) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxw) (by decide +revert), iff_of_true hxw rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide +revert)⟩
        · -- zWT  (w < v < t) : right-group slot machinery
          have hzwt : zs = kvE_sub2_zWT := h
          rw [hzwt] at hbit ⊢
          have hbitT : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true := hbit
          have hlWT : (KvE2SepSlot.lWT σ χ) ∈ kvE2_sepSlotsRFor σ := by
            rw [kvE2_sepSlotsRFor, if_pos hz]
            exact List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbitT⟩)
          have hmemR : (KvE2SepSlot.lWT σ χ) ∈ kvE2_sepSlotsROf wo :=
            kvE2_sepSlotsROf_mem qnf hwo' hσI hlWT
          rw [← kvE2_sepTieGroupedR_flatten wo] at hmemR
          obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemR
          obtain ⟨jr, hjr, hgetjr⟩ := List.mem_iff_getElem.mp hd
          have hjrRmap : jr < ((kvE2_sepTieGroupedR wo).map
              (kvE2_sepClassType charBase charK)).length := by
            simp only [List.length_map]; omega
          have hK : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 +
              jr
              < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
                + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
            simp only [List.length_map] at hjrRmap ⊢; omega
          have hchar := hpt' (((kvE2_sepTieGroupedL wo).map
              (kvE2_sepClassType charBase charK)).length
            + 1 + jr) hK
          rw [kvE2_sep_getElem_right _ _ _ jr hjrRmap, List.getElem_map] at hchar
          have hain : (KvE2SepSlot.lWT σ χ) ∈ (kvE2_sepTieGroupedR wo)[jr]'hjr := by
            rw [hgetjr]; exact hsd
          have hcharχ := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hchar hain
          set v := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
              + jr,
            hK⟩ with hvdef
          have hwv : w < v := by
            rw [hwdef, hvdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
          have hvt : v < t := (hrange _).2
          have hx1v : x1 < v := hx1w.trans hwv
          have hxv : x < v := hxw.trans hwv
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
          have hlit := (kvE2_sepEpR_owner_lits charBase charK qnf M atomMap t σ hσIn hepR χ).1
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨t, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm (hx1w.trans hwt)) (by decide +revert),
              iff_of_true (hx1w.trans hwt) rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwt) (by decide +revert), iff_of_true hwt rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm (hxw.trans hwt)) (by decide +revert),
              iff_of_true (hxw.trans hwt) rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_false (lt_irrefl t) (by decide +revert),
              iff_of_false (lt_irrefl t) (by decide +revert)⟩
        · -- zFutT4  (t < v)
          have hzf : zs = kvE2_sep_zFutT4 := h
          rw [hzf] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zFutT4 χ = true := hbit
          have hlit := (kvE2_sepEpR_owner_lits charBase charK qnf M atomMap t σ hσIn hepR χ).2
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          obtain ⟨u, htu, hχu, -⟩ := hlit
          have hu_x1 : x1 < u := (hx1w.trans hwt).trans htu
          have hu_w : w < u := hwt.trans htu
          have hu_x : x < u := (hxw.trans hwt).trans htu
          refine ⟨u, ?_, tonf _ hχu⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hu_x1) (by decide +revert), iff_of_true hu_x1
              rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hu_w) (by decide +revert), iff_of_true hu_w rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hu_x) (by decide +revert), iff_of_true hu_x rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_false (lt_asymm htu) (by decide +revert), iff_of_true htu rfl⟩
      exact kvE2_sepBundleL_sound_frag atomMap h_surj σ M w x t hwt x1 hx1w hbelow
        h_atom h_off h_fwd h_bwd
    · intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      rw [hz] at hzσ
      exact absurd hzσ (by decide)
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

-- ============================================================================

end Bimodal.Metalogic.WeakCanonical.Kamp

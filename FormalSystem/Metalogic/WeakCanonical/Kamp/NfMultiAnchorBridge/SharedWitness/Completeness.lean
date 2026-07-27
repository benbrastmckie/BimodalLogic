/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Carrier

/-! # Shared-Interior-Witness Joint Carrier — completeness reduction

Module D of the `SharedWitness` tower. Lemma 3.2(1) ⇐: the honest arrangement selects its
own order-type disjunct (Rabinovich Lemma 3.2(1), PDF p.3; §5 meet-typed shared point,
PDF p.5), reducing to `kvE2_sepBody_complete`. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nfDepth0CharFormula nf_depth0_char_formula_correct
   formulaConjList formula_conjList_iff)

/-! ## Lemma 3.2(1) ⇐ (completeness): the honest arrangement selects its
    order-type disjunct (PDF p.3; §5 coincidence, PDF p.6).

**Empirical finding (this dispatch, `lean_goal`-grounded).** The genuinely honest selection is the
COINCIDENCE (tie) arrangement, NOT the strict `kvE2SepModelOrder`. At σ's OWN fresh anchor `x1`,
σ's fresh base type `nf0ProjFresh σ.1` is realized AT `x1` — so the CLOSED self-zone bit
`kvE2SepBits σ zAtX1L (nf0ProjFresh σ.1)` is forced TRUE (via the preserved axiom-clean
`kvE2_sepCoincidentAnchor_discharge`), while the OPEN `zXU`/`zUW` bits that
`kvE2SepDisjValidOwner .strictBefore/.strictAfter` read are NOT forced (the exact handoff-05
open-vs-closed discrimination). Hence `kvE2SepDisjValid qnf (kvE2SepModelOrder qnf)`
(strict tags) is NOT honestly provable; the honestly-valid disjunct is the coincident one. This
supersedes the singleton retreat with the full multi-owner LEFT-interior completeness. -/

/-- **Global Nodup — prefix-sum payload**): the flattened
    model/coincident payload over the whole family is duplicate-free (the global slot index is
    injective on the `Nodup` family). -/
theorem kvE2_sepAllSlots_map_slotIndexOf_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3) :
    ((kvE2SepAllSlots qnf).map (kvE2SepSlotIndexOf qnf)).Nodup :=
  List.Nodup.map_on (fun _a ha _b hb hab => kvE2_sepSlotIndexOf_injOn qnf ha hb hab)
    (kvE2_sepAllSlots_nodup qnf)

/-- Flattening a per-owner `block.map f` payload over the whole `zipIdx`-tagged owner list yields
    exactly `allSlots.map f` (owner blocks concatenate to the family in order; the `zipIdx` position
    is irrelevant). -/
private theorem kvE2_sepZip_flatMap_aux {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (g : NormalForm sig 1 4 → KvE2SepSpikeOrderType) (f : KvE2SepSlot sig → ℕ)
    (L : List (NormalForm sig 1 4)) (n : ℕ) :
    ((L.zipIdx n).map (fun p => (p.1, g p.1, (kvE2SepSlotBlock p.1).map f))).flatMap
        (fun p => p.2.2)
      = (L.flatMap kvE2SepSlotBlock).map f := by
  induction L generalizing n with
  | nil => simp
  | cons a t ih =>
    simp only [List.zipIdx_cons, List.map_cons, List.flatMap_cons, List.map_append, ih (n + 1)]

/-- **Payload flatten**): the flattened per-slot payload of a
    `block.map f`-tagged weak order over all owners is `allSlots.map f` — feeding the global-Nodup
    lemmas `kvE2_sepAllSlots_map_slotIndexOf_nodup` / `_honestGIdx_nodup`. -/
theorem kvE2_sepZipPayload_flatMap {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    (g : NormalForm sig 1 4 → KvE2SepSpikeOrderType) (f : KvE2SepSlot sig → ℕ) :
    ((kvE2SepPosI qnf).zipIdx.map
        (fun p => (p.1, g p.1, (kvE2SepSlotBlock p.1).map f))).flatMap (fun p => p.2.2)
      = (kvE2SepAllSlots qnf).map f := by
  rw [kvE2SepAllSlots]; exact kvE2_sepZip_flatMap_aux g f (kvE2SepPosI qnf) 0

/-- The honest COINCIDENCE (tie) arrangement: every positive owner placed at its own fresh anchor
    (Lemma 3.2(1) coincidence disjunct, PDF p.3; §5 meet, PDF p.6). -/
noncomputable def kvE2SepCoincidentOrder {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : KvE2SepWeakOrder sig :=
  (kvE2SepPosI qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
      (kvE2SepSlotBlock p.1).map (kvE2SepSlotIndexOf qnf)))

/-- The coincidence arrangement is present in the enumeration index (F2, structural level): the
    all-coincident tag assignment with consecutive `zipIdx` ranks is reachable in the cartesian
    rank×tag enumeration (a `kvE2_sepOrderTypes_mem_aux` instance, `s = 0`). UNCONDITIONAL
: both the order's `zipIdx` carrier and the enumeration fold range over
    the interior index `kvE2SepPosI` — no owner-index coincidence hypothesis. -/
theorem kvE2_sepCoincidentOrder_mem_orderTypes {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) :
    kvE2SepCoincidentOrder qnf ∈ kvE2SepOrderTypes qnf := by
  rw [kvE2SepCoincidentOrder, kvE2SepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' (fun _ => KvE2SepSpikeOrderType.coincident) _
    (fun σ => (kvE2SepSlotBlock σ).map (kvE2SepSlotIndexOf qnf)) (kvE2SepPosI qnf) 0
    (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2SepAllSlots qnf).length
    ((kvE2SepSlotBlock σ).map (kvE2SepSlotIndexOf qnf)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      exact kvE2_sepSlotIndexOf_lt qnf
        (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs))
  rwa [List.length_map] at h

/-- **Phase 8a (LEFT) — per-owner honest coincidence validity.** For an honest realization, a
    LEFT-interior positive owner's CLOSED self-zone bit at its own fresh type is forced TRUE. The
    anchor `x1 ∈ (x, w)` and its order bounds are exactly the data `kvE2_sepHonestBundleL` (:1207)
    extracts; the closed bit is discharged by the preserved `kvE2_sepCoincidentAnchor_discharge`. -/
theorem kvE2_sepCoincidentOwner_valid_left {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (_hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσmem : σ ∈ kvE2SepPos qnf)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZXW3) :
    kvE2SepClosedLeafStub σ = true := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσmem).2
  obtain ⟨_h_atom, h_quant⟩ := h
  obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
  -- left-interior order bounds x < x1 < w, from the zone guard through the realized atom layer
  obtain ⟨hσ_atom, _h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  have hbit_xx1 : (nf0ZoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨1, by omega⟩]; decide
  have hbit_x1w : (nf0ZoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hxx1 : x < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr hbit_xx1
  have hx1w : x1 < w := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr hbit_x1w
  -- σ's own fresh base type is realized AT x1 (the fresh coordinate factor)
  have hfresh : NfEvalNf M 0 1 (fun _ => x1) (nf0ProjFresh σ.1) :=
    ((nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1 σ.1).mp hσ.1).2.1
  -- the coincidence discharge closes the CLOSED self-zone bit (LEFT branch of the guard)
  rw [kvE2SepClosedLeafStub, if_pos hzone]
  exact kvE2_sepCoincidentAnchor_discharge σ M x1 w x t hxx1 hx1w hwt hσ (nf0ProjFresh σ.1) hfresh

/-- **Phase 8b (RIGHT) — right coincidence discharge** (mirror of
`kvE2_sepCoincidentAnchor_discharge`
    at the RIGHT self-zone `zAtX1R`, `w < x1 < t`; consumes the same generic zone-forward channel of
    `kvE_subBracket2_complete_extract` that `kvE2_sepHonestBundleR` (:1259) routes through). At a
    RIGHT-interior owner's fresh anchor `x1 ∈ (w, t)`, a base type `χ` realized AT `x1` discharges
    σ's CLOSED right self-zone bit `kvE2SepBits σ zAtX1R χ` — the §5 shared-anchor meet-type
    identification (PDF p.6) on the right side. This is the genuine mathematical content of the
    right completeness half. NOTE: the current `kvE2SepDisjValidOwner
    .coincident`/`kvE2SepClosedLeafStub`
    read `zAtX1L` (left) only; wiring this right bit into a placement-generic coincident validity
    channel is a tightly-scoped carrier-predicate extension (plan scope note :417-419), tracked as a
    follow-up. -/
theorem kvE2_sepCoincidentAnchor_discharge_R {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxw : x < w) (hwx1 : w < x1) (hx1t : x1 < t)
    (hσ : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : NfEvalNf M 0 1 (fun _ => x1) χ) :
    kvE2SepBits σ kvE2SepZAtX1R χ = true := by
  obtain ⟨_, _, h_zonefwd, _, _, _⟩ := kvE_subBracket2_complete_extract σ M x1 w x t hσ
  have hxx1 : x < x1 := lt_trans hxw hwx1
  refine h_zonefwd kvE2SepZAtX1R χ ⟨x1, ?_, hp⟩
  -- `zoneHolds env kvE2SepZAtX1R x1` is a pure order fact (v = x1: `x < w < x1 < t`).
  refine (kvE_sub2_zoneHolds_cons_iff M x1 w x t x1
    (false, false) (false, true) (false, true) (true, false)).mpr ?_
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩
  · exact iff_of_false (lt_irrefl _) (by decide)
  · exact iff_of_false (lt_irrefl _) (by decide)
  · exact iff_of_false (not_lt.mpr (le_of_lt hwx1)) (by decide)
  · exact iff_of_true hwx1 rfl
  · exact iff_of_false (not_lt.mpr (le_of_lt hxx1)) (by decide)
  · exact iff_of_true hxx1 rfl
  · exact iff_of_true hx1t rfl
  · exact iff_of_false (not_lt.mpr (le_of_lt hx1t)) (by decide)

/-- **Phase 8b (RIGHT) — per-owner honest coincidence validity** (mirror of
    `kvE2_sepCoincidentOwner_valid_left`). For an honest realization, a RIGHT-interior positive
    owner (`nf0ZoneSpec σ.1 = kvE2SepZWT3`, `w < x1 < t`) has its CLOSED right self-zone bit at
    its own fresh type forced TRUE. The anchor `x1 ∈ (w, t)` and its order bounds are extracted
    inline (the `kvE2_sepHonestBundleR` :1259 pattern); the closed `zAtX1R` bit is discharged by
    the landed axiom-clean `kvE2_sepCoincidentAnchor_discharge_R`. The guard in
    `kvE2SepClosedLeafStub` selects the RIGHT (`else`) branch via `if_neg` on
    `kvE2_sep_zWT3_ne_zXW3`. Sorry-free, axiom-clean; F5-faithful (CLOSED key). -/
theorem kvE2_sepCoincidentOwner_valid_right {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (_hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσmem : σ ∈ kvE2SepPos qnf)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZWT3) :
    kvE2SepClosedLeafStub σ = true := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσmem).2
  obtain ⟨_h_atom, h_quant⟩ := h
  obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
  -- right-interior order bounds w < x1 < t, from the zone guard through the realized atom layer
  obtain ⟨hσ_atom, _h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  have hbit_wx1 : (nf0ZoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hbit_x1t : (nf0ZoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨2, by omega⟩]; decide
  have hwx1 : w < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr hbit_wx1
  have hx1t : x1 < t := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr hbit_x1t
  -- σ's own fresh base type is realized AT x1 (the fresh coordinate factor)
  have hfresh : NfEvalNf M 0 1 (fun _ => x1) (nf0ProjFresh σ.1) :=
    ((nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1 σ.1).mp hσ.1).2.1
  -- the right coincidence discharge closes the CLOSED self-zone bit (RIGHT branch of the guard)
  rw [kvE2SepClosedLeafStub, if_neg (fun hcon => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans hcon))]
  exact kvE2_sepCoincidentAnchor_discharge_R σ M x1 w x t hxw hwx1 hx1t hσ (nf0ProjFresh σ.1)
      hfresh

/-! ### F5 foreign-base CLOSED-key discharges

A base-anchor tie class reads the anchor owner's CLOSED self-zone bit at the FOREIGN base
type (`kvE2SepClosedLeafAt`, Phase 6). The discharges below prove that read TRUE whenever
the foreign base type is honestly realized AT the anchor point — the tie-class situation
(equal honest values). **F5**: the only keys entering any coincident read are the CLOSED
`kvE2SepZAtX1L`/`kvE2SepZAtX1R` self-zone keys, routed through the preserved axiom-clean
coincidence discharges `kvE2_sepCoincidentAnchor_discharge` (LEFT) / `_R` (RIGHT) — no OPEN
key is read. Grounding: Rabinovich §5 (p.7) — the ψ₀/ψ₁/φ split routes non-interior
witnesses to atomic E[Σ] endpoint literals via Prop 3.5, and the shared-anchor meet-type
identification (PDF p.6) makes the coincidence a DISCHARGED disjunct, never a refuted
inequality. Tie-collapse is forced by Def 3.1 (p.4); Lemma 3.2(1) states the closure
without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). -/

/-- **Foreign-base CLOSED-key discharge, placement-dispatched**): for
    an INTERIOR owner σ realized at its anchor `a = x1_σ` (LEFT `x < x1_σ < w` or RIGHT
    `w < x1_σ < t`, recovered definitionally from the interior index `kvE2SepPosI` — never
    hypothesized), any base type `χ` realized AT the anchor discharges σ's CLOSED self-zone
    leaf read at the foreign type: `kvE2SepClosedLeafAt σ χ = true`. LEFT owners route
    through `kvE2_sepCoincidentAnchor_discharge` (CLOSED `zAtX1L` key); RIGHT owners through
    `_R` (CLOSED `zAtX1R` key). The anchor's own order bounds are read off σ's realized
    ordering channel (`nf0ZoneSpec`), never a formula literal (LITMUS). F5: no OPEN key
    enters this read. -/
theorem kvE2_sepClosedLeafAt_discharge {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    {σ : NormalForm sig 1 4} (hσI : σ ∈ kvE2SepPosI qnf)
    (a : M.carrier)
    (hσ : NfEvalNf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : NfEvalNf M 0 1 (fun _ => a) χ) :
    kvE2SepClosedLeafAt σ χ = true := by
  obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  rcases kvE2_sepPosI_zone hσI with hzone | hzone
  · -- LEFT-interior: x < x1_σ < w from σ's own realized ordering channel.
    have hbit_aw : (nf0ZoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
      rw [congrFun hzone ⟨0, by omega⟩]; decide
    have hbit_xa : (nf0ZoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
      rw [congrFun hzone ⟨1, by omega⟩]; decide
    have haw : a < w := by
      have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
      simp only [AtomEval, Fin.cons] at h1
      exact h1.mpr hbit_aw
    have hxa : x < a := by
      have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
      simp only [AtomEval, Fin.cons] at h1
      exact h1.mpr hbit_xa
    rw [kvE2SepClosedLeafAt, if_pos hzone]
    exact kvE2_sepCoincidentAnchor_discharge σ M a w x t hxa haw hwt hσ χ hp
  · -- RIGHT-interior: w < x1_σ < t (mirror; CLOSED `zAtX1R` key).
    have hbit_wa : (nf0ZoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
      rw [congrFun hzone ⟨0, by omega⟩]; decide
    have hbit_at : (nf0ZoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
      rw [congrFun hzone ⟨2, by omega⟩]; decide
    have hwa : w < a := by
      have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
      simp only [AtomEval, Fin.cons] at h1
      exact h1.mpr hbit_wa
    have hat : a < t := by
      have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
      simp only [AtomEval, Fin.cons] at h1
      exact h1.mpr hbit_at
    rw [kvE2SepClosedLeafAt,
      if_neg (fun hcon => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans hcon))]
    exact kvE2_sepCoincidentAnchor_discharge_R σ M a w x t hxw hwa hat hσ χ hp

/-- **Tie-read intro rule**): conjunct (iv) holds once every
    anchor-involved payload tie is discharged at its partner's base type. Base-base tie
    classes impose NO read — machine-checked here: a non-anchor first slot short-circuits
    the guard (`isFalse` branch), and an anchor partner (`kvE2SepSlotBaseType = none`)
    closes by the `none` match arm. Only `(anchor, base-χ)` pairs ever reach the CLOSED-key
    read (F5): the sole obligation forwarded to `hdis` is `kvE2SepClosedLeafAt p.1 χ`. -/
theorem kvE2_sepTieRead_of_discharge {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig)
    (hdis : ∀ p ∈ wo, ∀ q ∈ wo,
      ∀ sj ∈ (kvE2SepSlotBlock p.1).zipIdx, ∀ sk ∈ (kvE2SepSlotBlock q.1).zipIdx,
        kvE2SepSlotIsAnchor sj.1 = true → p.2.2.getD sj.2 0 = q.2.2.getD sk.2 0 →
        ∀ χ, kvE2SepSlotBaseType sk.1 = some χ → kvE2SepClosedLeafAt p.1 χ = true) :
    kvE2SepTieRead wo = true := by
  rw [kvE2SepTieRead, List.all_eq_true]
  intro p hp
  rw [List.all_eq_true]
  intro q hq
  rw [List.all_eq_true]
  intro sj hsj
  rw [List.all_eq_true]
  intro sk hsk
  split
  case isTrue hcond =>
    rw [Bool.and_eq_true, decide_eq_true_eq] at hcond
    cases hbt : kvE2SepSlotBaseType sk.1 with
    | some χ => exact hdis p hp q hq sj hsj sk hsk hcond.1 hcond.2 χ hbt
    | none => rfl
  case isFalse _ => rfl

/-- **Lemma 3.2(1) ⇐ (completeness) — `kvE2_sepBody_complete`** (generalized to
    right-interior owners; made UNCONDITIONAL). For an honest model
    realization, the honest COINCIDENCE (tie) arrangement is a VALID, PRESENT member of the
    faithful carrier `kvE2SepArr'`; hence the carrier is NON-VACUOUS (`kvE2SepArr' qnf ≠ []`) —
    the ⇐ direction of Lemma 3.2(1) (PDF p.3): every honest arrangement selects its order-type
    disjunct (here the coincidence disjunct, §5 meet, PDF p.6). The per-owner `rcases`
    dispatches each owner to its placement-appropriate closed-self-zone validator: LEFT →
    `kvE2_sepCoincidentOwner_valid_left` (`zAtX1L` bit, `kvE2_sepCoincidentAnchor_discharge`);
    RIGHT → `kvE2_sepCoincidentOwner_valid_right` (`zAtX1R` bit,
    `kvE2_sepCoincidentAnchor_discharge_R`), both routed through the placement-guarded
    `kvE2SepClosedLeafStub`. Sorry-free, axiom-clean. Faithfulness: F2 (⇐ realized, non-vacuous),
    F1, F5 (closed vs open key discrimination), F6.

    Interiority is a CONSTRUCTION INVARIANT, not a hypothesis: the arrangement's owner index is
    the interior-restricted carrier `kvE2SepPosI`, so each owner's placement — LEFT
    (`nf0ZoneSpec σ.1 = kvE2SepZXW3`, `x < x1 < w`) OR RIGHT (`kvE2SepZWT3`, `w < x1 < t`) —
    is recovered definitionally via `kvE2_sepPosI_zone` (`List.mem_filter`). Rabinovich §5 (p.7):
    the ψ0/ψ1/φ split routes non-interior positive witnesses to the atomic `E[Σ]` endpoint
    literals via Prop 3.5, so only interior owners enter the interleaving; an interiority
    hypothesis has no paper counterpart, and `kvE2_sepHonest_hLR_absurd` certifies that the
    former `hLR` hypothesis was inconsistent with every honest evaluation. -/
theorem kvE2_sepBody_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2SepArr' qnf ≠ [] := by
  apply List.ne_nil_of_mem (a := kvE2SepCoincidentOrder qnf)
  rw [kvE2SepArr', List.mem_filter]
  refine ⟨kvE2_sepCoincidentOrder_mem_orderTypes qnf, ?_⟩
  rw [kvE2SepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- (i) per-owner closed-self-zone validity, dispatched by placement (definitional
    -- interiority via `kvE2_sepPosI_zone` — a construction invariant of the owner index).
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2SepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2SepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    -- `p.2.1 = .coincident`, so `kvE2SepDisjValidOwner p.1 p.2.1 = kvE2SepClosedLeafStub σ`.
    change kvE2SepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases kvE2_sepPosI_zone hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
  · -- (ii) per-owner region-scoped consistency: the prefix-sum payload extends each region order.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2SepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2SepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_slotIndexOf qnf (kvE2_sepPosI_subset hσmem)
  · -- (iii') anchor-distinct: from the globally-Nodup prefix-sum payload.
    rw [kvE2SepCoincidentOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2SepSlotIndexOf qnf) (kvE2_sepAllSlots_map_slotIndexOf_nodup qnf)).1
  · -- (iv) tie-class reads: vacuous — all classes are singletons under the global Nodup.
    rw [kvE2SepCoincidentOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2SepSlotIndexOf qnf) (kvE2_sepAllSlots_map_slotIndexOf_nodup qnf)).2

/-- **Phase 1 — the honest coincidence witness is a carrier member.** Factored from
    `kvE2_sepBody_complete`'s membership route: under an honest realization the COINCIDENCE
    arrangement `kvE2SepCoincidentOrder qnf` (all-coincident tags, `zipIdx` ranks) is a VALID,
    PRESENT member of `kvE2SepArr' qnf` — the ⇐-direction witness weak order this task's
    `.holds` builder plugs into `kvE2_sepBody_holds_iff.mpr`. UNCONDITIONAL:
    owner interiority is a construction invariant of the `kvE2SepPosI` index (Rabinovich §5,
    p.7 — the ψ0/ψ1/φ split routes non-interior witnesses to the endpoint literals via Prop 3.5),
    recovered via `kvE2_sepPosI_zone`, never hypothesized. Additive; edits no carrier declaration.
    F5: validity reads only CLOSED self-zone bits (via the coincidence validators). -/
theorem kvE2_sepCoincidentOrder_mem_arr' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2SepCoincidentOrder qnf ∈ kvE2SepArr' qnf := by
  rw [kvE2SepArr', List.mem_filter]
  refine ⟨kvE2_sepCoincidentOrder_mem_orderTypes qnf, ?_⟩
  rw [kvE2SepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · rw [List.all_eq_true]
    intro p hp
    rw [kvE2SepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2SepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    change kvE2SepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases kvE2_sepPosI_zone hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
  · rw [List.all_eq_true]
    intro p hp
    rw [kvE2SepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2SepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_slotIndexOf qnf (kvE2_sepPosI_subset hσmem)
  · -- (iii') anchor-distinct: from the globally-Nodup prefix-sum payload.
    rw [kvE2SepCoincidentOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2SepSlotIndexOf qnf) (kvE2_sepAllSlots_map_slotIndexOf_nodup qnf)).1
  · -- (iv) tie-class reads: vacuous — all classes are singletons under the global Nodup.
    rw [kvE2SepCoincidentOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2SepSlotIndexOf qnf) (kvE2_sepAllSlots_map_slotIndexOf_nodup qnf)).2

/-! ### Anchor family KEYSTONE (distinct owners ⟹ distinct anchors)

The design gate (report 06) dissolves the coinciding-anchor "fork": two DISTINCT positive owners
provably CANNOT share a fresh anchor. `kvE2SepPos` is `Finset.univ.toList.filter` (`Nodup`,
owners distinct normal forms) and each owner's anchor realizes it at the depth-1 environment
`[x1, w, x, t]`; `nf_eval_unique` (NormalForm.lean:245) forces equal-anchor ⟹ equal-owner. Hence
the anchor family is INJECTIVE and strictly orderable — the value-rank owner-block layout is
well-defined with no ties. This is the keystone every later phase depends on. -/

/-- **Owner anchor value**: σ's fresh depth-1 witness `x1_σ`, extracted as the
    `Classical.choose` of the honest realization existential `(h.2 σ).mpr`. Off the positive spine
    (`qnf.2 σ ≠ true`) it defaults to `x`. Model-dependent (needs the realization `h`), like the
    completeness-side witness (report 02 Q2 — the value order is inherently per-M). No `x1 < e_i`
    literal introduced (LITMUS clean): only the already-extracted witness is named. -/
noncomputable def kvE2SepAnchorVal {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) : M.carrier :=
  if hb : qnf.2 σ = true then Classical.choose ((h.2 σ).mpr hb) else x

/-- The anchor value realizes its owner at the depth-1 environment `[x1_σ, w, x, t]` (the exact
    shape `kvE2_sepCoincidentOwner_valid_left/right` extract from `(h.2 σ).mpr`). -/
theorem kvE2_sepAnchorVal_spec {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hb : qnf.2 σ = true) :
    NfEvalNf M 1 4
      (Fin.cons (kvE2SepAnchorVal qnf M w x t h σ) (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  rw [kvE2SepAnchorVal, dif_pos hb]
  exact Classical.choose_spec ((h.2 σ).mpr hb)

/-- **Foreign-base CLOSED-key discharge at the honest anchor value**;
    the exact shape Phase 9's tie-read conjunct (iv) consumes): under an honest evaluation
    `h`, if base type `χ` is honestly realized AT an interior owner σ's honest anchor value
    `kvE2SepAnchorVal qnf M w x t h σ` (equal honest values — the base-anchor tie-class
    situation), then the anchor owner's CLOSED self-zone leaf at the foreign type is TRUE.
    F5: reads only the CLOSED `zAtX1L`/`zAtX1R` keys via `kvE2_sepClosedLeafAt_discharge`. -/
theorem kvE2_sepClosedLeafAt_discharge_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσI : σ ∈ kvE2SepPosI qnf)
    (χ : NormalForm sig 0 1)
    (hp : NfEvalNf M 0 1 (fun _ => kvE2SepAnchorVal qnf M w x t h σ) χ) :
    kvE2SepClosedLeafAt σ χ = true :=
  kvE2_sepClosedLeafAt_discharge qnf M w x t hxw hwt hσI _
    (kvE2_sepAnchorVal_spec qnf M w x t h σ
      (List.mem_filter.mp (kvE2_sepPosI_subset hσI)).2)
    χ hp

/-- **KEYSTONE**: distinct positive owners have distinct anchors. If σ, τ are
    positive owners with equal anchors `a`, the single environment `[a, w, x, t]` realizes BOTH σ
    and τ at depth 1, arity 4, so `nf_eval_unique` forces `σ = τ`. This kills any coinciding-anchor
    fork at the anchor level: the anchor family is injective, so plain value rank is already a
    strict total order (no lex tiebreak needed for realizability). -/
theorem kvE2_sepAnchor_injOn {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2SepPos qnf) (hτ : τ ∈ kvE2SepPos qnf)
    (heq : kvE2SepAnchorVal qnf M w x t h σ = kvE2SepAnchorVal qnf M w x t h τ) :
    σ = τ := by
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hbτ : qnf.2 τ = true := (List.mem_filter.mp hτ).2
  have hrσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  have hrτ := kvE2_sepAnchorVal_spec qnf M w x t h τ hbτ
  rw [heq] at hrσ
  exact nf_eval_unique M 1 4 _ σ τ hrσ hrτ

/-- **Anchor family**: the injective `Fin n → M.carrier` sending each owner
    index to its anchor value. `n = |kvE2SepPos qnf|`. Injectivity (from `List.get` on the `Nodup`
    positive spine + the keystone `kvE2_sepAnchor_injOn`) makes `kvE2OrdRank` of this family a
    strict, injective rank — the value-faithful owner-block order key. -/
noncomputable def kvE2SepAnchorFam {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Fin (kvE2SepPos qnf).length → M.carrier :=
  fun k => kvE2SepAnchorVal qnf M w x t h ((kvE2SepPos qnf).get k)

/-- The anchor family is injective: `List.get` on the `Nodup` positive spine is injective, and the
    keystone lifts anchor-equality to owner-equality. Supplies the cross-owner `Nodup` conjunct
    (via `kvE2_ordRank_injective`) and licenses value-faithful ranking. -/
theorem kvE2_sepAnchorFam_injective {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Function.Injective (kvE2SepAnchorFam qnf M w x t h) := by
  have hnd : (kvE2SepPos qnf).Nodup := by
    unfold kvE2SepPos; exact List.Nodup.filter _ (Finset.nodup_toList _)
  intro a b hab
  have hga : (kvE2SepPos qnf).get a ∈ kvE2SepPos qnf := (kvE2SepPos qnf).get_mem a
  have hgb : (kvE2SepPos qnf).get b ∈ kvE2SepPos qnf := (kvE2SepPos qnf).get_mem b
  have hget : (kvE2SepPos qnf).get a = (kvE2SepPos qnf).get b :=
    kvE2_sepAnchor_injOn qnf M w x t h hga hgb hab
  exact (List.Nodup.get_inj_iff hnd).mp hget

/-! ### The honest value-rank order (owner-block tuples, coincident tags)

The single honest order (no bifurcation, report 06): every owner is tagged `.coincident` and its
per-slot global-index tuple is the value-rank owner block `(3r, 3r+1, 3r+2)`, `r = ` the rank of
its anchor in the injective anchor family. Membership in `kvE2SepArr'` is TUPLE-AGNOSTIC — the
tag validators (`kvE2_sepCoincidentOwner_valid_left/right`) read only the CLOSED self-zone bit, so
they reuse VERBATIM; consistency `i₀<i₁<i₂` is `omega` on `3r<3r+1<3r+2`; the `i₀`-`Nodup` conjunct
is `kvE2_ordRank_injective` on the keystone-injective family (via `3·`). -/

/-- **Phase 5D — LEFT engine-precondition data at the value-ranked anchor.** The public,
    canonical-anchor form of `kvE2_sepHonestBundleL`: for a LEFT-interior owner σ, at its
    `kvE2SepAnchorVal` anchor (the value the honest rank is computed from) there are real
    witnesses in `(x, x1_σ)` for every `zXU`-positive base type and in `(x1_σ, w)` for every
    `zUW`-positive base type. These are the `hnd`/`hreal` inputs (per the region base-type lists)
    that the assembly feeds to `k1v_sorted_realizationK` for the honest-order regions. Mirrors the
    private bundle proof with the anchor pinned to `kvE2SepAnchorVal`. -/
theorem kvE2_sepHonestAnchorBundleL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (_hxw : x < w) (_hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2SepPos qnf)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZXW3) :
    x < kvE2SepAnchorVal qnf M w x t h σ ∧ kvE2SepAnchorVal qnf M w x t h σ < w ∧
      (∀ χ ∈ kvE2SepS σ kvESub2ZXU,
        ∃ u : M.carrier, x < u ∧ u < kvE2SepAnchorVal qnf M w x t h σ ∧
          NfEvalNf M 0 1 (fun _ => u) χ) ∧
      (∀ χ ∈ kvE2SepS σ kvESub2ZUW,
        ∃ u : M.carrier, kvE2SepAnchorVal qnf M w x t h σ < u ∧ u < w ∧
          NfEvalNf M 0 1 (fun _ => u) χ) := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨hσ_atom, _h_off, _h_zonefwd, hbelowXU, hbelowUW, _hbelowWT⟩ :=
    kvE_subBracket2_complete_extract σ M (kvE2SepAnchorVal qnf M w x t h σ) w x t hσ
  have hbit_xx1 : (nf0ZoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨1, by omega⟩]; decide
  have hbit_x1w : (nf0ZoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hxx1 : x < kvE2SepAnchorVal qnf M w x t h σ := by
    have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr hbit_xx1
  have hx1w : kvE2SepAnchorVal qnf M w x t h σ < w := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr hbit_x1w
  refine ⟨hxx1, hx1w, ?_, ?_⟩
  · intro χ hχ
    obtain ⟨u, hxu, _huw, hux1, hrel⟩ := hbelowXU χ (List.mem_filter.mp hχ).2
    exact ⟨u, hxu, hux1, hrel⟩
  · intro χ hχ
    exact hbelowUW χ (List.mem_filter.mp hχ).2

/-- **Phase 5D — RIGHT engine-precondition data at the value-ranked anchor.** Right mirror of
    `kvE2_sepHonestAnchorBundleL` for a RIGHT-interior owner σ (`w < x1_σ < t`): real witnesses in
    `(w, x1_σ)` for `zWX1`-positive base types and in `(x1_σ, t)` for `zWT`-positive base types,
    pinned to the canonical `kvE2SepAnchorVal` anchor. -/
theorem kvE2_sepHonestAnchorBundleR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (_hxw : x < w) (_hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2SepPos qnf)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZWT3) :
    w < kvE2SepAnchorVal qnf M w x t h σ ∧ kvE2SepAnchorVal qnf M w x t h σ < t ∧
      (∀ χ ∈ kvE2SepS σ kvE2SepZWX1,
        ∃ u : M.carrier, w < u ∧ u < kvE2SepAnchorVal qnf M w x t h σ ∧
          NfEvalNf M 0 1 (fun _ => u) χ) ∧
      (∀ χ ∈ kvE2SepS σ kvESub2ZWT,
        ∃ u : M.carrier, kvE2SepAnchorVal qnf M w x t h σ < u ∧ u < t ∧
          NfEvalNf M 0 1 (fun _ => u) χ) := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨hσ_atom, h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  have hbit_wx1 : (nf0ZoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hbit_x1t : (nf0ZoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨2, by omega⟩]; decide
  have hwx1 : w < kvE2SepAnchorVal qnf M w x t h σ := by
    have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr hbit_wx1
  have hx1t : kvE2SepAnchorVal qnf M w x t h σ < t := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr hbit_x1t
  refine ⟨hwx1, hx1t, ?_, ?_⟩
  · intro χ hχ
    have hbit : σ.2 (nf0Assemble kvE2SepZWX1 χ σ.1) = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2SepZWX1 χ).mpr hbit
    obtain ⟨hp0, hp1, _, _⟩ :=
      (kvE_sub2_zoneHolds_cons_iff M (kvE2SepAnchorVal qnf M w x t h σ) w x t v
        (true, false) (false, true) (false, true) (true, false)).mp hz
    exact ⟨v, hp1.2.mpr rfl, hp0.1.mpr rfl, hv⟩
  · intro χ hχ
    have hbit : σ.2 (nf0Assemble kvESub2ZWT χ σ.1) = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hz, hv⟩ := (h_zone kvESub2ZWT χ).mpr hbit
    obtain ⟨hp0, _, _, hp3⟩ :=
      (kvE_sub2_zoneHolds_cons_iff M (kvE2SepAnchorVal qnf M w x t h σ) w x t v
        (false, true) (false, true) (false, true) (true, false)).mp hz
    exact ⟨v, hp0.2.mpr rfl, hp3.1.mpr rfl, hv⟩

/-! ### The `value_j` → engine-point binding (data-flow inversion)

Report 08 §Missing Design element 1: each individual slot's rank key `value_j` is bound to the
engine-realized point for that slot, NOT a free canonical value. An anchor slot (`lX1`/`rX1`) takes
its owner's canonical `kvE2SepAnchorVal`; a base slot takes the witness the anchor realization
forces for its base type `χ` in the slot's OWN region interval (Def 3.1's monotone enumeration of
INDIVIDUAL points, PDF p.4). `Classical.epsilon` keeps the map total; the interval-and-realization
spec is recovered per slot from the honest bundles (`kvE2_sepHonestAnchorBundleL/R`) /
`kvE_subBracket2_complete_extract`, which prove exactly the constraining existence. Reads M only
through already-extracted witnesses ordered by `<` (F4/LITMUS clean — no `x1 < e_i` literal); the
honest per-slot order (Phase 6/7) is `kvE2OrdRank` of `G j = (value_j, slotIndexOf j)` over the
full slot family `Fin N`, with the index tiebreak giving injectivity WITHOUT value-distinctness. -/
/-- The per-slot witness value of the arity-2 separated bracket. An anchor slot takes its
owner's canonical `kvE2SepAnchorVal`; a base slot takes a `Classical.epsilon` witness pinned
to that slot's own region interval and base type. Total by construction; the interval and
realization spec is recovered per slot from the honest bundles. -/
noncomputable def kvE2SepSlotValue {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    KvE2SepSlot sig → M.carrier
  | .lX1 σ => kvE2SepAnchorVal qnf M w x t h σ
  | .rX1 σ => kvE2SepAnchorVal qnf M w x t h σ
  | .lXU σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => x < v ∧ v < kvE2SepAnchorVal qnf M w x t h σ ∧ NfEvalNf M 0 1 (fun _ => v) χ)
  | .lUW σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => kvE2SepAnchorVal qnf M w x t h σ < v ∧ v < w ∧ NfEvalNf M 0 1 (fun _ => v) χ)
  | .lWT _σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => w < v ∧ v < t ∧ NfEvalNf M 0 1 (fun _ => v) χ)
  | .rXW _σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => x < v ∧ v < w ∧ NfEvalNf M 0 1 (fun _ => v) χ)
  | .rWX1 σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => w < v ∧ v < kvE2SepAnchorVal qnf M w x t h σ ∧ NfEvalNf M 0 1 (fun _ => v) χ)
  | .rX1T σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => kvE2SepAnchorVal qnf M w x t h σ < v ∧ v < t ∧ NfEvalNf M 0 1 (fun _ => v) χ)

/-- The anchor slot's `value` is its owner's canonical anchor value (definitional). -/
theorem kvE2_sepSlotValue_lX1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) (σ : NormalForm sig 1 4) :
    kvE2SepSlotValue qnf M w x t h (.lX1 σ) = kvE2SepAnchorVal qnf M w x t h σ := rfl

/-- The right anchor slot's `value` is its owner's canonical anchor value (definitional). -/
theorem kvE2_sepSlotValue_rX1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) (σ : NormalForm sig 1 4) :
    kvE2SepSlotValue qnf M w x t h (.rX1 σ) = kvE2SepAnchorVal qnf M w x t h σ := rfl

/-- **`lXU` slot value spec** (Phase 6): a before-anchor left base slot's value lies in `(x, x1_σ)`
    and realizes its base type `χ`. From the honest bundle's below-anchor witnesses. -/
theorem kvE2_sepSlotValue_lXU_spec {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2SepPos qnf)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZXW3)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2SepS σ kvESub2ZXU) :
    x < kvE2SepSlotValue qnf M w x t h (.lXU σ χ)
      ∧ kvE2SepSlotValue qnf M w x t h (.lXU σ χ) < kvE2SepAnchorVal qnf M w x t h σ
      ∧ NfEvalNf M 0 1 (fun _ => kvE2SepSlotValue qnf M w x t h (.lXU σ χ)) χ := by
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec
    ((kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone).2.2.1 χ hχ)

/-- **`lUW` slot value spec** (Phase 6): an after-anchor left base slot's value lies in `(x1_σ, w)`
    and realizes `χ`. From the honest bundle's above-anchor witnesses. -/
theorem kvE2_sepSlotValue_lUW_spec {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2SepPos qnf)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZXW3)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2SepS σ kvESub2ZUW) :
    kvE2SepAnchorVal qnf M w x t h σ < kvE2SepSlotValue qnf M w x t h (.lUW σ χ)
      ∧ kvE2SepSlotValue qnf M w x t h (.lUW σ χ) < w
      ∧ NfEvalNf M 0 1 (fun _ => kvE2SepSlotValue qnf M w x t h (.lUW σ χ)) χ := by
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec
    ((kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone).2.2.2 χ hχ)

/-- **`rWX1` slot value spec** (Phase 6): a before-anchor right base slot's value lies in
    `(w, x1_σ)` and realizes `χ`. From the honest bundle R's below-anchor witnesses. -/
theorem kvE2_sepSlotValue_rWX1_spec {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2SepPos qnf)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZWT3)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2SepS σ kvE2SepZWX1) :
    w < kvE2SepSlotValue qnf M w x t h (.rWX1 σ χ)
      ∧ kvE2SepSlotValue qnf M w x t h (.rWX1 σ χ) < kvE2SepAnchorVal qnf M w x t h σ
      ∧ NfEvalNf M 0 1 (fun _ => kvE2SepSlotValue qnf M w x t h (.rWX1 σ χ)) χ := by
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec
    ((kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone).2.2.1 χ hχ)

/-- **`rX1T` slot value spec** (Phase 6): an after-anchor right base slot's value lies in
    `(x1_σ, t)` and realizes `χ`. From the honest bundle R's above-anchor witnesses. -/
theorem kvE2_sepSlotValue_rX1T_spec {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2SepPos qnf)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZWT3)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2SepS σ kvESub2ZWT) :
    kvE2SepAnchorVal qnf M w x t h σ < kvE2SepSlotValue qnf M w x t h (.rX1T σ χ)
      ∧ kvE2SepSlotValue qnf M w x t h (.rX1T σ χ) < t
      ∧ NfEvalNf M 0 1 (fun _ => kvE2SepSlotValue qnf M w x t h (.rX1T σ χ)) χ := by
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec
    ((kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone).2.2.2 χ hχ)

/-- **`lWT` slot value spec** (Phase 6): a right-region base slot of a LEFT-interior owner lies in
    `(w, t)` and realizes `χ`. Direct from the anchor realization's `zWT` extraction. -/
theorem kvE2_sepSlotValue_lWT_spec {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2SepPos qnf)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2SepS σ kvESub2ZWT) :
    w < kvE2SepSlotValue qnf M w x t h (.lWT σ χ)
      ∧ kvE2SepSlotValue qnf M w x t h (.lWT σ χ) < t
      ∧ NfEvalNf M 0 1 (fun _ => kvE2SepSlotValue qnf M w x t h (.lWT σ χ)) χ := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨_, _, _, _, _, hbelowWT⟩ :=
    kvE_subBracket2_complete_extract σ M (kvE2SepAnchorVal qnf M w x t h σ) w x t hσ
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec (hbelowWT χ (List.mem_filter.mp hχ).2)

/-- **`rXW` slot value spec** (Phase 6): a left-region base slot of a RIGHT-interior owner lies in
    `(x, w)` — strictly BELOW the pivot `w` — and realizes `χ`. Direct from the anchor realization's
    `zXU` extraction, now carrying the restored below-pivot `v < w` bound (faithfulness
    audit; Def 3.1 ordering channel, PDF p.4; Figure 1 below-pivot bracket, PDF p.9).
    The old `v < anchorVal` bound remains DERIVABLE as `v < w < x1_σ` for right-interior owners
    (`w < x1_σ`), so any consumer wanting it is unaffected. -/
theorem kvE2_sepSlotValue_rXW_spec {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2SepPos qnf)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2SepS σ kvESub2ZXU) :
    x < kvE2SepSlotValue qnf M w x t h (.rXW σ χ)
      ∧ kvE2SepSlotValue qnf M w x t h (.rXW σ χ) < w
      ∧ NfEvalNf M 0 1 (fun _ => kvE2SepSlotValue qnf M w x t h (.rXW σ χ)) χ := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨_, _, _, hbelowXU, _, _⟩ :=
    kvE_subBracket2_complete_extract σ M (kvE2SepAnchorVal qnf M w x t h σ) w x t hσ
  haveI : Nonempty M.carrier := ⟨x⟩
  obtain ⟨v, hxv, hvw, _hvx1, hrel⟩ := hbelowXU χ (List.mem_filter.mp hχ).2
  exact Classical.epsilon_spec
    (p := fun v => x < v ∧ v < w ∧ NfEvalNf M 0 1 (fun _ => v) χ) ⟨v, hxv, hvw, hrel⟩

/-- **Within-region value ordering**, the honest-consistency crux):
    for two slots of the same owner σ in the same region with a strictly smaller region rank, the
    smaller-rank slot's `value` is strictly smaller. Each region's rank-0/1/2 slots realize their
    types in the nested intervals `(x,x1_σ) < x1_σ < (x1_σ,w)` (left) / `(w,x1_σ) < x1_σ < (x1_σ,t)`
    (right) pinned by the value specs. Feeds `kvE2_sepSlotHonestGIdx_mono` to give honest
    consistency. -/
theorem kvE2_sepSlotValue_region_rank_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2SepPos qnf)
    {a b : KvE2SepSlot sig} (hamem : a ∈ kvE2SepSlotBlock σ) (hbmem : b ∈ kvE2SepSlotBlock σ)
    (hreg : kvE2SepSlotRegionLeft a = kvE2SepSlotRegionLeft b)
    (hrank : kvE2SepSlotRank a < kvE2SepSlotRank b) :
    kvE2SepSlotValue qnf M w x t h a < kvE2SepSlotValue qnf M w x t h b := by
  rw [kvE2_sepMem_slotBlock] at hamem hbmem
  by_cases hz1 : nf0ZoneSpec σ.1 = kvE2SepZXW3
  · rw [kvE2SepSlotsLFor, kvE2SepSlotsRFor, if_pos hz1, if_pos hz1] at hamem hbmem
    rcases hamem with haL | haR
    · rcases List.mem_append.mp haL with ha | ha
      · obtain ⟨χa, hχa, rfl⟩ := List.mem_map.mp ha
        rcases hbmem with hbL | hbR
        · rcases List.mem_append.mp hbL with hb | hb
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank
              (by simp [kvE2SepSlotRank])
          · rcases List.mem_cons.mp hb with rfl | hb
            · rw [kvE2_sepSlotValue_lX1]
              exact (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χa hχa).2.1
            · obtain ⟨χb, hχb, rfl⟩ := List.mem_map.mp hb
              exact lt_trans (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χa hχa).2.1
                (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χb hχb).1
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbR; exact absurd hreg
            (by simp [kvE2SepSlotRegionLeft])
      · rcases List.mem_cons.mp ha with rfl | ha
        · rcases hbmem with hbL | hbR
          · rcases List.mem_append.mp hbL with hb | hb
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank
                (by simp [kvE2SepSlotRank])
            · rcases List.mem_cons.mp hb with rfl | hb
              · exact absurd hrank (by simp [kvE2SepSlotRank])
              · obtain ⟨χb, hχb, rfl⟩ := List.mem_map.mp hb
                rw [kvE2_sepSlotValue_lX1]
                exact (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χb hχb).1
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbR; exact absurd hreg
              (by simp [kvE2SepSlotRegionLeft])
        · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
          rcases hbmem with hbL | hbR
          · rcases List.mem_append.mp hbL with hb | hb
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank
                (by simp [kvE2SepSlotRank])
            · rcases List.mem_cons.mp hb with rfl | hb
              · exact absurd hrank (by simp [kvE2SepSlotRank])
              · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank
                  (by simp [kvE2SepSlotRank])
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbR; exact absurd hreg
              (by simp [kvE2SepSlotRegionLeft])
    · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp haR
      rcases hbmem with hbL | hbR
      · rcases List.mem_append.mp hbL with hb | hb
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hreg
            (by simp [kvE2SepSlotRegionLeft])
        · rcases List.mem_cons.mp hb with rfl | hb
          · exact absurd hreg (by simp [kvE2SepSlotRegionLeft])
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hreg
              (by simp [kvE2SepSlotRegionLeft])
      · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbR; exact absurd hrank (by simp [kvE2SepSlotRank])
  · by_cases hz2 : nf0ZoneSpec σ.1 = kvE2SepZWT3
    · rw [kvE2SepSlotsLFor, kvE2SepSlotsRFor, if_neg hz1, if_neg hz1, if_pos hz2, if_pos hz2]
        at hamem hbmem
      rcases hamem with haL | haR
      · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp haL
        rcases hbmem with hbL | hbR
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbL; exact absurd hrank
            (by simp [kvE2SepSlotRank])
        · rcases List.mem_append.mp hbR with hb | hb
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hreg
              (by simp [kvE2SepSlotRegionLeft])
          · rcases List.mem_cons.mp hb with rfl | hb
            · exact absurd hreg (by simp [kvE2SepSlotRegionLeft])
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hreg
                (by simp [kvE2SepSlotRegionLeft])
      · rcases List.mem_append.mp haR with ha | ha
        · obtain ⟨χa, hχa, rfl⟩ := List.mem_map.mp ha
          rcases hbmem with hbL | hbR
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbL; exact absurd hreg
              (by simp [kvE2SepSlotRegionLeft])
          · rcases List.mem_append.mp hbR with hb | hb
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank
                (by simp [kvE2SepSlotRank])
            · rcases List.mem_cons.mp hb with rfl | hb
              · rw [kvE2_sepSlotValue_rX1]
                exact (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χa hχa).2.1
              · obtain ⟨χb, hχb, rfl⟩ := List.mem_map.mp hb
                exact lt_trans (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χa
                    hχa).2.1
                  (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χb hχb).1
        · rcases List.mem_cons.mp ha with rfl | ha
          · rcases hbmem with hbL | hbR
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbL; exact absurd hreg
                (by simp [kvE2SepSlotRegionLeft])
            · rcases List.mem_append.mp hbR with hb | hb
              · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank
                  (by simp [kvE2SepSlotRank])
              · rcases List.mem_cons.mp hb with rfl | hb
                · exact absurd hrank (by simp [kvE2SepSlotRank])
                · obtain ⟨χb, hχb, rfl⟩ := List.mem_map.mp hb
                  rw [kvE2_sepSlotValue_rX1]
                  exact (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χb hχb).1
          · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
            rcases hbmem with hbL | hbR
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbL; exact absurd hreg
                (by simp [kvE2SepSlotRegionLeft])
            · rcases List.mem_append.mp hbR with hb | hb
              · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank
                  (by simp [kvE2SepSlotRank])
              · rcases List.mem_cons.mp hb with rfl | hb
                · exact absurd hrank (by simp [kvE2SepSlotRank])
                · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank
                    (by simp [kvE2SepSlotRank])
    · rw [kvE2SepSlotsLFor, kvE2SepSlotsRFor, if_neg hz1, if_neg hz1, if_neg hz2, if_neg hz2]
        at hamem
      simp only [List.not_mem_nil, or_self] at hamem

/-- **The lex value family `G`** (Phase 6): over the full individual-slot family `Fin N`
    (`N = (kvE2SepAllSlots qnf).length`), `G j = (value_j, j)` in the LEX product
    `M.carrier ×ₗ Fin N`. The slot index second coordinate makes `G` injective WITHOUT any
    value-distinctness hypothesis (the distinctness crux, SW:~1000): distinct owners may share
    witness values, but the index tiebreak is always distinct. `kvE2OrdRank G` is then the
    per-INDIVIDUAL-slot value rank — the value-faithful global index the refined carrier reads. -/
noncomputable def kvE2SepSlotG {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Fin (kvE2SepAllSlots qnf).length → M.carrier ×ₗ Fin (kvE2SepAllSlots qnf).length :=
  fun j => toLex (kvE2SepSlotValue qnf M w x t h ((kvE2SepAllSlots qnf).get j), j)

/-- `G` is injective (the slot-index second lex coordinate is injective), no value-distinctness
    hypothesis needed. Feeds `kvE2_ordRank_injective` → the cross-owner global `Nodup` conjunct. -/
theorem kvE2_sepSlotG_injective {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Function.Injective (kvE2SepSlotG qnf M w x t h) := by
  intro a b hab
  have h2 : ((kvE2SepSlotValue qnf M w x t h ((kvE2SepAllSlots qnf).get a), a) :
      M.carrier × Fin (kvE2SepAllSlots qnf).length)
      = (kvE2SepSlotValue qnf M w x t h ((kvE2SepAllSlots qnf).get b), b) :=
    congrArg (ofLex) hab
  exact (Prod.ext_iff.mp h2).2

/-- A strictly smaller slot value forces a strictly smaller `G` (lex first coordinate), hence a
    strictly smaller `kvE2OrdRank` — the region-monotonicity engine for the honest order. -/
theorem kvE2_sepSlotG_lt_of_value_lt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : Fin (kvE2SepAllSlots qnf).length}
    (hlt : kvE2SepSlotValue qnf M w x t h ((kvE2SepAllSlots qnf).get a)
      < kvE2SepSlotValue qnf M w x t h ((kvE2SepAllSlots qnf).get b)) :
    kvE2SepSlotG qnf M w x t h a < kvE2SepSlotG qnf M w x t h b := by
  exact Prod.Lex.left _ _ hlt

/-- **The honest per-individual-slot global index** (Phase 6/7): slot `s`'s value rank
    `kvE2OrdRank G` at its family position. This is the value-faithful per-slot index the refined
    carrier reads (via `kvE2SepBlockPos`), replacing the tied `(3r,3r+1,3r+2)` owner-region tuple
    the 337 stop-guard refuted. Off-family (never on the enumeration) defaults to `0`. -/
noncomputable def kvE2SepSlotHonestGIdx {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (s : KvE2SepSlot sig) : ℕ :=
  if hs : kvE2SepSlotIndexOf qnf s < (kvE2SepAllSlots qnf).length then
    kvE2OrdRank (kvE2SepSlotG qnf M w x t h) ⟨kvE2SepSlotIndexOf qnf s, hs⟩
  else 0

/-- **Region monotonicity engine** (Phase 7 conjunct (ii)): a strictly smaller slot value gives a
    strictly smaller honest global index. Within a region the bundle facts give
    `value(before) < value(anchor) < value(after)`, so this yields the region-order extension. -/
theorem kvE2_sepSlotHonestGIdx_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2SepAllSlots qnf) (hb : b ∈ kvE2SepAllSlots qnf)
    (hlt : kvE2SepSlotValue qnf M w x t h a < kvE2SepSlotValue qnf M w x t h b) :
    kvE2SepSlotHonestGIdx qnf M w x t h a < kvE2SepSlotHonestGIdx qnf M w x t h b := by
  have hal : kvE2SepSlotIndexOf qnf a < (kvE2SepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf ha
  have hbl : kvE2SepSlotIndexOf qnf b < (kvE2SepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf hb
  have hga : (kvE2SepAllSlots qnf).get ⟨kvE2SepSlotIndexOf qnf a, hal⟩ = a := List.idxOf_get hal
  have hgb : (kvE2SepAllSlots qnf).get ⟨kvE2SepSlotIndexOf qnf b, hbl⟩ = b := List.idxOf_get hbl
  unfold kvE2SepSlotHonestGIdx
  rw [dif_pos hal, dif_pos hbl]
  apply kvE2_ordRank_strictMono
  apply kvE2_sepSlotG_lt_of_value_lt
  rw [hga, hgb]; exact hlt

/-- **Cross-owner Nodup ingredient** (Phase 7 conjunct (iii)): the honest global index is injective
    on family members. Composes `kvE2_ordRank_injective` (on the index-injective `G`) with
    `kvE2_sepSlotIndexOf_injOn`. Gives distinct value-ranked indices for distinct individual slots
    — the per-slot faithfulness the refinement installs (no owner-region tie). -/
theorem kvE2_sepSlotHonestGIdx_injOn {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2SepAllSlots qnf) (hb : b ∈ kvE2SepAllSlots qnf)
    (heq : kvE2SepSlotHonestGIdx qnf M w x t h a = kvE2SepSlotHonestGIdx qnf M w x t h b) :
    a = b := by
  have hal : kvE2SepSlotIndexOf qnf a < (kvE2SepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf ha
  have hbl : kvE2SepSlotIndexOf qnf b < (kvE2SepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf hb
  unfold kvE2SepSlotHonestGIdx at heq
  rw [dif_pos hal, dif_pos hbl] at heq
  have hfin := kvE2_ordRank_injective (kvE2SepSlotG qnf M w x t h)
    (kvE2_sepSlotG_injective qnf M w x t h) heq
  exact kvE2_sepSlotIndexOf_injOn qnf ha hb (congrArg Fin.val hfin)

/-- **Honest consistency**): the honest payload
    `block.map kvE2SepSlotHonestGIdx` extends every region order. Within a region a larger rank
    has a
    larger value (`kvE2_sepSlotValue_region_rank_mono`), hence a larger value rank
    (`kvE2_sepSlotHonestGIdx_mono`). The value-faithful counterpart of
    `kvE2_sepConsistentBlock_slotIndexOf`. -/
theorem kvE2_sepConsistentBlock_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2SepPos qnf) :
    kvE2SepConsistentBlock σ
      ((kvE2SepSlotBlock σ).map (kvE2SepSlotHonestGIdx qnf M w x t h)) = true := by
  rw [kvE2SepConsistentBlock, decide_eq_true_eq]
  intro j k hreg hrank
  rw [kvE2_sepBlockMap_getD, kvE2_sepBlockMap_getD]
  have hjmem : (kvE2SepSlotBlock σ).get j ∈ kvE2SepSlotBlock σ := List.get_mem _ _
  have hkmem : (kvE2SepSlotBlock σ).get k ∈ kvE2SepSlotBlock σ := List.get_mem _ _
  refine kvE2_sepSlotHonestGIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ hjmem) (kvE2_sepMem_allSlots qnf hσ hkmem) ?_
  exact kvE2_sepSlotValue_region_rank_mono qnf M w x t hxw hwt h hσ hjmem hkmem hreg hrank

/-- **Global Nodup — honest value-rank payload**): the flattened
    honest payload over the whole family is duplicate-free (`kvE2SepSlotHonestGIdx` is injective on
    the family via the lex index tiebreak — no value-distinctness needed). -/
theorem kvE2_sepAllSlots_map_honestGIdx_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ((kvE2SepAllSlots qnf).map (kvE2SepSlotHonestGIdx qnf M w x t h)).Nodup :=
  List.Nodup.map_on (fun _a ha _b hb hab => kvE2_sepSlotHonestGIdx_injOn qnf M w x t h ha hb hab)
    (kvE2_sepAllSlots_nodup qnf)

/-- **The honest order**: all owners `.coincident`-tagged with the
    per-INDIVIDUAL-slot value-rank payload `block.map kvE2SepSlotHonestGIdx` (replacing the tied
    length-3 `(3r,3r+1,3r+2)` owner-block the 337 stop-guard refuted). Model-dependent (the value
    rank is per-M). Structural mirror of `kvE2SepCoincidentOrder` with the value-rank payload. -/
noncomputable def kvE2SepHonestOrder {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) : KvE2SepWeakOrder sig :=
  (kvE2SepPosI qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
      (kvE2SepSlotBlock p.1).map (kvE2SepSlotHonestGIdx qnf M w x t h)))

/-- The honest order is present in the enumeration index (F2). A `kvE2_sepOrderTypes_mem_aux`
    instance (`s = 0`, all-coincident tag, honest tuple); every tuple component `< 3n` from
    `kvE2_ordRank_lt` feeding `kvE2_sepIdxTuple_mem_of_lt`. UNCONDITIONAL:
    carrier and enumeration fold both range over the interior index `kvE2SepPosI`. -/
theorem kvE2_sepHonestOrder_mem_orderTypes {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2SepHonestOrder qnf M w x t h ∈ kvE2SepOrderTypes qnf := by
  rw [kvE2SepHonestOrder, kvE2SepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' (fun _ => KvE2SepSpikeOrderType.coincident) _
    (fun σ => (kvE2SepSlotBlock σ).map (kvE2SepSlotHonestGIdx qnf M w x t h))
    (kvE2SepPosI qnf) 0 (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2SepAllSlots qnf).length
    ((kvE2SepSlotBlock σ).map (kvE2SepSlotHonestGIdx qnf M w x t h)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      have hidx := kvE2_sepSlotIndexOf_lt qnf
        (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs)
      rw [kvE2SepSlotHonestGIdx, dif_pos hidx]
      exact kvE2_ordRank_lt _ _)
  rwa [List.length_map] at h

/-- **The honest order is a carrier member** (the object the grouped builder consumes).
    Under an honest realization the value-rank honest order is a VALID, PRESENT member of
    `kvE2SepArr' qnf`. UNCONDITIONAL: owner interiority is a construction
    invariant of the `kvE2SepPosI` index (Rabinovich §5, p.7), recovered via
    `kvE2_sepPosI_zone`, never hypothesized. The `kvE2SepDisjValid` conjuncts: (i)
    all-`.coincident` validity reuses `kvE2_sepCoincidentOwner_valid_left/right` VERBATIM
    (tuple-agnostic, CLOSED self-zone bit only); (ii) consistency via
    `kvE2_sepConsistentBlock_honest`; (iii')/(iv) via the shared tie discharge
    `kvE2_sepValid_tie_of_nodup` on the globally-`Nodup` value-rank payload
    (`kvE2_sepAllSlots_map_honestGIdx_nodup` — all tie classes are singletons here). -/
theorem kvE2_sepHonestOrder_mem_arr' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2SepHonestOrder qnf M w x t h ∈ kvE2SepArr' qnf := by
  rw [kvE2SepArr', List.mem_filter]
  refine ⟨kvE2_sepHonestOrder_mem_orderTypes qnf M w x t h, ?_⟩
  rw [kvE2SepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- (i) per-owner closed-self-zone validity (all tags `.coincident`), reused verbatim
    -- (definitional interiority via `kvE2_sepPosI_zone` — a construction invariant of the index).
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2SepHonestOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2SepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    change kvE2SepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases kvE2_sepPosI_zone hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
  · -- (ii) per-owner region-scoped consistency via the value-rank monotonicity engine.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2SepHonestOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2SepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_honest qnf M w x t hxw hwt h (kvE2_sepPosI_subset hσmem)
  · -- (iii') anchor-distinct: from the globally-Nodup value-rank payload.
    rw [kvE2SepHonestOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2SepSlotHonestGIdx qnf M w x t h)
      (kvE2_sepAllSlots_map_honestGIdx_nodup qnf M w x t h)).1
  · -- (iv) tie-class reads: vacuous — all classes are singletons under the global Nodup.
    rw [kvE2SepHonestOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2SepSlotHonestGIdx qnf M w x t h)
      (kvE2_sepAllSlots_map_honestGIdx_nodup qnf M w x t h)).2

/-! ### Value-faithful monotonicity (the honest `a < u' < b` interleave)

The value order is reproduced by the honest tuple's global indices. The load-bearing content
(report 06 Q4): the cross-region step `i₂(σ) < i₁(τ) ⟺ r_σ < r_τ ⟺ x1_σ < x1_τ`. With the block
tuple `(3r, 3r+1, 3r+2)`, `i₂(σ)=3r_σ+2` and `i₁(τ)=3r_τ+1`, so `i₂(σ) < i₁(τ) ⟺ r_σ < r_τ`
(`omega`); and `x1_σ < x1_τ → r_σ < r_τ` is `kvE2_ordRank_strictMono` on the anchor family. This
is the merged-chain monotonicity `kvE2SepSlotsLOf/ROf` inherit through `kvE2SepSlotGIdx` — the
disjunct the region-primary key dropped, now expressible because indices are value-ranked. -/

/-- **Anchor order lifts to rank order**: a strictly smaller anchor gets a
    strictly smaller value rank. Direct `kvE2_ordRank_strictMono` on the anchor family. -/
theorem kvE2_sepHonest_rank_strictMono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : Fin (kvE2SepPos qnf).length}
    (hlt : kvE2SepAnchorFam qnf M w x t h a < kvE2SepAnchorFam qnf M w x t h b) :
    kvE2OrdRank (kvE2SepAnchorFam qnf M w x t h) a
      < kvE2OrdRank (kvE2SepAnchorFam qnf M w x t h) b :=
  kvE2_ordRank_strictMono (kvE2SepAnchorFam qnf M w x t h) hlt

end FormalSystem.Metalogic.WeakCanonical.Kamp

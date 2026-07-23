import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationPastK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterPastK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConverseK

/-! # Past-side exterior slice quotient (task 360, plan v2 Phase 3b)

The Past-side mirrors of the Phase-3 Future slice defs (`ExteriorPinnedConverseK.lean`):
`kvE_pastSliceEq`, `kvE_pastSliceMarked`, and the Past clause slice-constancy lemma
`kvE_pastClause_sliceConstant`. Ground truth as on the Future side: Rabinovich 2014 Def 7.13
(chunk_0023:25) footprint discipline — the Past clause family
`kvE_pastPos`/`kvE_pastEnd`/`kvE_pastGapD`/`kvE_extNegPast` reads `σ.2` exclusively through
the three PAST exterior zone lists (`kvE_pastGapZone`/`kvE_pastRayZone`/`kvE_pastSelfZone`,
ExteriorNegationPastK.lean:207-213), so the honest bracket key must be a function of the same
data. `kvE_pastSliceMarked` re-keys `kvE_extBracketPast`'s per-σ if-then-else in Phase 3b
(`ExteriorBracketAssembleK.lean`), exactly as `kvE_futSliceMarked` re-keys the Future bracket.

**Scope fence (Phase 3b)**: defs + constancy ONLY. The Past slice-id theorems
(`kvE_pastSliceId_of_end_zero`, `kvE_pastSliceUnique_zero`) are plan v2 Phase 4 and land in
this file later. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## The Past slice defs (mirrors of report 02 §3.3, Future file Phase 3) -/

/-- **Past exterior-slice equality**: same atom layer, same three Past exterior zone lists.
    The Past clause family is constant on slice classes of admissible σ
    (`kvE_pastClause_sliceConstant` below). Mirror of `kvE_futSliceEq`
    (ExteriorPinnedConverseK.lean). -/
noncomputable def kvE_pastSliceEq {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ' σ : NormalForm sig (k + 1) 4) : Bool :=
  decide (σ'.1 = σ.1) &&
  decide (kvE_fiberZoneList σ' kvE_pastGapZone  = kvE_fiberZoneList σ kvE_pastGapZone) &&
  decide (kvE_fiberZoneList σ' kvE_pastRayZone  = kvE_fiberZoneList σ kvE_pastRayZone) &&
  decide (kvE_fiberZoneList σ' kvE_pastSelfZone = kvE_fiberZoneList σ kvE_pastSelfZone)

/-- **σ's Past exterior slice is qnf-marked**: some admissible slice-mate carries the bit.
    The faithful Past bracket key (re-keys `kvE_extBracketPast`'s per-σ if-then-else in
    Phase 3b): a negative clause `¬ kvE_pastPos P σ` is asserted iff NO marked type carries
    σ's segment content. Mirror of `kvE_futSliceMarked`. -/
noncomputable def kvE_pastSliceMarked {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (σ : NormalForm sig (k + 1) 4) : Bool :=
  (Finset.univ.toList (α := NormalForm sig (k + 1) 4)).any
    (fun σ' => kvE_pastAdmissible σ' && kvE_pastSliceEq σ' σ && qnf.2 σ')

/-- Unpack/repack the Past slice marking (the extraction interface Phase 3b's D4 and the
    gate consume). Mirror of `kvE_futSliceMarked_iff` (ExteriorBracketAssembleK.lean). -/
theorem kvE_pastSliceMarked_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (σ : NormalForm sig (k + 1) 4) :
    kvE_pastSliceMarked qnf σ = true ↔
      ∃ σ' : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ' = true ∧
        kvE_pastSliceEq σ' σ = true ∧ qnf.2 σ' = true := by
  rw [kvE_pastSliceMarked, List.any_eq_true]
  constructor
  · rintro ⟨σ', -, h⟩
    rw [Bool.and_eq_true, Bool.and_eq_true] at h
    exact ⟨σ', h.1.1, h.1.2, h.2⟩
  · rintro ⟨σ', h1, h2, h3⟩
    exact ⟨σ', Finset.mem_toList.mpr (Finset.mem_univ σ'), by rw [h1, h2, h3]; rfl⟩

/-! ## Past clause slice-constancy -/

/-- **Past clause slice-constancy** (mirror of `kvE_futClause_sliceConstant`,
    ExteriorPinnedConverseK.lean): for admissible σ', σ with equal Past exterior slices, the
    entire Past clause family agrees as FORMULAS. Slice-mates therefore always receive the
    SAME clause under the re-keyed bracket — killing the `F ∧ ¬F` pair that made the
    per-σ-keyed bracket unsatisfiable. -/
theorem kvE_pastClause_sliceConstant {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (σ' σ : NormalForm sig (k + 1) 4)
    (hadm' : kvE_pastAdmissible σ' = true) (hadm : kvE_pastAdmissible σ = true)
    (hsl : kvE_pastSliceEq σ' σ = true) :
    kvE_pastPos P σ' = kvE_pastPos P σ ∧
    kvE_pastEnd P σ' = kvE_pastEnd P σ ∧
    kvE_pastGapD P σ' = kvE_pastGapD P σ ∧
    kvE_extNegPast P σ' = kvE_extNegPast P σ := by
  unfold kvE_pastSliceEq at hsl
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hsl
  obtain ⟨⟨⟨-, hgapL⟩, hrayL⟩, hselfL⟩ := hsl
  have hgapL := of_decide_eq_true hgapL
  have hrayL := of_decide_eq_true hrayL
  have hselfL := of_decide_eq_true hselfL
  have hGapDeq : kvE_pastGapD P σ' = kvE_pastGapD P σ := by
    rw [kvE_pastGapD, kvE_pastGapD, hgapL]
  have hEndEq : kvE_pastEnd P σ' = kvE_pastEnd P σ := by
    rw [kvE_pastEnd, kvE_pastEnd, kvE_pastRayForm, kvE_pastRayForm,
      kvE_pastRayD, kvE_pastRayD, hselfL, hrayL]
  have hPosEq : kvE_pastPos P σ' = kvE_pastPos P σ := by
    rw [kvE_pastPos, kvE_pastPos, if_pos hadm', if_pos hadm, hgapL]
    have hchain : kvE_pastChain P σ' = kvE_pastChain P σ := by
      funext l
      rw [kvE_pastChain, kvE_pastChain, hEndEq, hGapDeq]
    rw [hchain]
  exact ⟨hPosEq, hEndEq, hGapDeq, by rw [kvE_extNegPast, kvE_extNegPast, hPosEq]⟩

/-! ## Phase 4: Past mirrors of the atom-layer pinning + slice-uniqueness machinery

Mirrors of the Future Phase-2/3 theorems (`ExteriorPinnedConverseK.lean`): endpoint
`x1 < x` (exterior past), zone tail `kvE2_sep_zPastX3`, zones
`kvE_past{Gap,Ray,Self}Zone` (ExteriorNegationPastK.lean:207-213).

**ASYMMETRY RECORD — RESOLVED (task 360 Phase 4a, report 03)**: the Phase-4 stopping
condition fired here because `kvE_pastSliceId_of_end_zero` was FALSE as naively mirrored:
`kvE_pastAdmissible` then had only THREE conjuncts (task 352 dropped the self-zone
fresh-profile uniqueness conjunct on a "subsumed by the full-fiber content channel
downstream" rationale), while the Future proof's SELF-zone/bit-true case consumes
`kvE_futAdmissible`'s FOURTH conjunct (ExteriorNegationK.lean:95-98). The counterexample
(honest endpoint characteristic τ ⊕ ONE extra self-zone mark
`s' := nf0_assemble kvE_pastSelfZone χ' τ.1`, `χ'` off the realized profile) satisfied every
3-conjunct hypothesis while no pinned-realized σ' could agree with it on the self zone
(self-witness coincidence + `nf_eval_unique`). Escalation research (report 03) adjudicated
the asymmetry as an in-tree omission — Rabinovich Cor 5.4(2) is the exact mirror of (1), and
the frozen k=2 `kvE2_pastAdmissible` carried condition 4 symmetrically — and machine-verified
that the Past realizer FORCES the restored conjunct with no order hypotheses. Conjunct 4 is
now restored (ExteriorNegationPastK, task 360 Phase 4a), the counterexample family is
inadmissible, and `kvE_pastSliceId_of_end_zero` below closes as the verbatim mirror of
`kvE_futSliceId_of_end_zero` (its SELF/true case consumes the restored conjunct exactly as
the Future's does). -/

/-! ### Admissibility conjunct-1 reader (Past mirror of `kvE_futAdmissible_zoneMark`) -/

/-- **Admissibility ⇒ zone marking** (Past): under `kvE_pastAdmissible σ`, the atom base
    layer `σ.1` carries the exterior-past zone marking `kvE2_sep_zPastX3` (`x1` strictly
    below each of `w`, `x`, `t`). Boolean conjunct-1 read of `kvE_pastAdmissible`
    (ExteriorNegationPastK.lean:134). -/
theorem kvE_pastAdmissible_zoneMark {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_pastAdmissible σ = true) :
    nf0_zoneSpec σ.1 = kvE2_sep_zPastX3 := by
  have hadm' := hadm
  unfold kvE_pastAdmissible at hadm'
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hadm'
  exact of_decide_eq_true hadm'.1.1.1

/-! ### Self-zone coincidence (Past mirror of `kvE_futSelfZone_coincide`) -/

/-- **Past self-zone coincidence**: the self-zone head coupling `(false, false)`
    (`kvE_pastSelfZone`, ExteriorNegationPastK.lean:213) forces fresh/slot-0 coincidence on
    any linear order — a point `v` in the self zone relative to ANY environment `env`
    satisfies `v = env 0`. Pure `lt_trichotomy` on the index-0 coupling (byte-identical to
    the Future proof: both self zones carry the `(false, false)` head). -/
theorem kvE_pastSelfZone_coincide {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {env : Fin 4 → M.carrier} {v : M.carrier}
    (hz : zoneHolds M env kvE_pastSelfZone v) :
    v = env 0 := by
  have h0 := hz 0
  rcases lt_trichotomy v (env 0) with h | h | h
  · exact absurd (h0.1.mp h) Bool.false_ne_true
  · exact h
  · exact absurd (h0.2.mp h) Bool.false_ne_true

/-! ### `x1`-slot pinning from the endpoint truth (Past mirror of
`kvE_futFreshPinned_of_end`) -/

/-- **Fresh-profile pinning from the endpoint** (Past): under admissibility, the endpoint
    truth `kvE_pastEnd P σ` at `x1` pins σ.1's fresh-slot monadic profile to `x1`'s actual
    profile — `nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)`. Mirror of
    `kvE_futFreshPinned_of_end`: `hend`'s self-zone conjunct delivers an on-fiber self-zone
    element realized with `x1` at the fresh slot over a free env; coincidence upgrades the
    free env's `x1`-slot to `x1` itself; admissibility conjunct 2 identifies the element's
    env restriction with `σ.1`. -/
theorem kvE_pastFreshPinned_of_end {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig 1 4)
    (hadm : kvE_pastAdmissible σ = true)
    (x1 : M.carrier)
    (hend : temporal_truth M atomMap x1 (kvE_pastEnd P σ)) :
    nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) := by
  -- self-zone fiber element realized (free env) with `x1` at the fresh slot
  rw [kvE_pastEnd, formula_conjList_iff] at hend
  have hself := hend (kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_pastSelfZone)) (by simp)
  rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1] at hself
  obtain ⟨s0, hs0mem, env0, hev0⟩ := hself
  obtain ⟨hbit0, hzone0⟩ := (kvE_fiberZoneList_mem σ kvE_pastSelfZone s0).mp hs0mem
  -- on-fiber: `s0`'s env restriction IS `σ.1` (admissibility conjunct 2)
  have hd0 : nf0_dropFresh s0 = σ.1 := kvE_pastAdmissible_onFiber σ hadm s0 hbit0
  -- factor `s0`'s realization into the three depth-0 channels
  obtain ⟨hz0, -, hdrop0⟩ := (nf_eval_nf0_cons_factor M env0 x1 s0).mp hev0
  have hzs : nf0_zoneSpec s0 = kvE_pastSelfZone := hzone0
  rw [hzs] at hz0
  rw [hd0] at hdrop0
  -- coincidence: the free env's `x1`-slot is `x1` itself
  have hx1e : x1 = env0 0 := kvE_pastSelfZone_coincide M hz0
  -- read σ.1's fresh-slot predicates off the realized env restriction at `env0 0 = x1`
  intro a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    have hp := hdrop0 (.pred p (0 : Fin 4))
    simp only [atom_eval] at hp
    rw [← hx1e] at hp
    simpa only [atom_eval, nf0_projFresh] using hp
  | .order i j hne => exact absurd (Subsingleton.elim i j) hne

/-! ### Endpoint atom-layer pinning at m = 0 (Past mirror of `kvE_futAtomPinned_zero`) -/

/-- **Endpoint atom-layer pinning** (Past, m = 0): under admissibility, σ on `qnf`'s fiber,
    the level-up ambient realization at `[w, x, t]`, and the destructor-endpoint truth
    `kvE_pastEnd P σ` at `x1 < x`, the endpoint's complete atomic profile is pinned — `σ.1`
    is realized at the ACTUAL anchors `[x1, w, x, t]`. Assembly is the three-channel
    factorization `nf_eval_nf0_cons_factor` (fresh := `x1`, env := `[w, x, t]`): ordering
    channel from admissibility conjunct 1 + the actual order facts (`x1` below all three);
    fresh-profile channel from the endpoint truth (via coincidence); env-restriction channel
    from the ambient's atom layer through `hfib`. -/
theorem kvE_pastAtomPinned_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (hadm : kvE_pastAdmissible σ = true)
    (hfib : nfk_dropFresh σ = qnf.1)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (x1 : M.carrier) (hx1x : x1 < x)
    (hend : temporal_truth M atomMap x1 (kvE_pastEnd P σ)) :
    nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
  refine (nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1 σ.1).mpr
    ⟨?_, ?_, ?_⟩
  · -- ordering channel: conjunct-1 zone marking rendered by the actual anchors
    rw [kvE_pastAdmissible_zoneMark σ hadm]
    intro i
    match i with
    | ⟨0, _⟩ =>
      exact ⟨iff_of_true (hx1x.trans hxw) rfl,
             iff_of_false (lt_asymm (hx1x.trans hxw)) Bool.false_ne_true⟩
    | ⟨1, _⟩ =>
      exact ⟨iff_of_true hx1x rfl,
             iff_of_false (lt_asymm hx1x) Bool.false_ne_true⟩
    | ⟨2, _⟩ =>
      exact ⟨iff_of_true (hx1x.trans (hxw.trans hwt)) rfl,
             iff_of_false (lt_asymm (hx1x.trans (hxw.trans hwt))) Bool.false_ne_true⟩
  · -- monadic (fresh-profile) channel: pinned by the endpoint truth
    exact kvE_pastFreshPinned_of_end P M h_UZ h_SZ σ hadm x1 hend
  · -- env-restriction channel: the ambient's atom layer through the fiber condition
    rw [show nf0_dropFresh σ.1 = qnf.1 from hfib]
    exact nf_eval_nf_atom_layer M _ qnf h

/-! ### The interior same-witness transfer engine (Past mirror of
`kvE_futInteriorTransfer_zero`) -/

/-- **Depth-0 same-witness interior transfer** (Past; the `kvE_pastSliceUnique_zero`
    engine): a depth-0 arity-5 fiber element `s` realized at `[v, x1, w, x, t]` with an
    INTERIOR witness (`¬ v < x` — on the Past side the exterior region is strictly below
    `x`) transfers to `[v, x1', w, x, t]` with the SAME witness `v`, provided `x1 < x`,
    `x1' < x`, and `x1'` realizes `x1`'s complete depth-0 4-type over `[w, x, t]`
    (profile-equal endpoints). Three-channel rebuild: the fresh profile transports verbatim;
    the tail 4-type is pinned to the characteristic (`nf_eval_unique`), which the
    profile-equal endpoint realizes by hypothesis; the zone channel changes only at index 0,
    where `x1 < x ≤ v` and `x1' < x ≤ v` render the SAME coupling `(false, true)`. -/
theorem kvE_pastInteriorTransfer_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 x1' w x t : M.carrier)
    (hvx : ¬ v < x) (hx1x : x1 < x) (hx1'x : x1' < x)
    (hchar : nf_eval_nf M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))))
    (s : NormalForm sig 0 5)
    (hs : nf_eval_nf M 0 5
      (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) :
    nf_eval_nf M 0 5
      (Fin.cons v (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))) s := by
  obtain ⟨hz, hfr, htl⟩ := (nf_eval_nf0_cons_factor M
    (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) v s).mp hs
  -- tail channel: the env restriction is x1's characteristic, realized at x1' by hypothesis
  have htl' : nf_eval_nf M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf0_dropFresh s) := by
    have huniq : nf0_dropFresh s =
        nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) :=
      nf_eval_unique M 0 4 _ _ _ htl (nf_characteristic_satisfies M 0 4 _)
    rw [huniq]; exact hchar
  refine (nf_eval_nf0_cons_factor M
    (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) v s).mpr ⟨?_, hfr, htl'⟩
  -- zone channel: only the index-0 coupling changes anchor; interiority renders it equal
  have hx1v : x1 < v := lt_of_lt_of_le hx1x (not_lt.mp hvx)
  have hx1'v : x1' < v := lt_of_lt_of_le hx1'x (not_lt.mp hvx)
  intro i
  match i with
  | ⟨0, _⟩ =>
    have h0 := hz ⟨0, by omega⟩
    constructor
    · refine iff_of_false (lt_asymm hx1'v) ?_
      intro hbit
      exact absurd (h0.1.mpr hbit) (lt_asymm hx1v)
    · exact iff_of_true hx1'v (h0.2.mp hx1v)
  | ⟨1, _⟩ => exact hz ⟨1, by omega⟩
  | ⟨2, _⟩ => exact hz ⟨2, by omega⟩
  | ⟨3, _⟩ => exact hz ⟨3, by omega⟩

/-! ### Private zone bookkeeping (replica precedent: `kvE_pastZoneBelow` is `private` in
ExteriorNegationPastK.lean:485 and cannot be imported) -/

/-- File-local replica of the private `kvE_pastZoneBelow`
    (ExteriorNegationPastK.lean:485): a point strictly below `x` (with `x < w < t`)
    couples to `[x1, w, x, t]` as `zPastX3` below `w, x, t` and to `x1` by the given
    head pair. -/
private theorem kvE_pastZone4_of_below {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hvx : v < x)
    (p0 : Bool × Bool)
    (h0a : v < x1 ↔ p0.1 = true) (h0b : x1 < v ↔ p0.2 = true) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      (Fin.cons p0 kvE2_sep_zPastX3) v := by
  intro i
  match i with
  | ⟨0, _⟩ => exact ⟨h0a, h0b⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_true (hvx.trans hxw) rfl,
           iff_of_false (lt_asymm (hvx.trans hxw)) Bool.false_ne_true⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_true hvx rfl, iff_of_false (lt_asymm hvx) Bool.false_ne_true⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_true (hvx.trans (hxw.trans hwt)) rfl,
           iff_of_false (lt_asymm (hvx.trans (hxw.trans hwt))) Bool.false_ne_true⟩

/-- Exterior-zone classification (Past mirror of `kvE_futZoneSpec_of_above`): a witness
    strictly below `x` (over `[x1, w, x, t]` with `x < w < t`) carries one of the three
    PAST exterior zone specs — gap, ray, or self. (Trichotomy against `x1` +
    `kvE_pastZone4_of_below` + zone-spec determinacy `zoneHolds_unique`.) -/
private theorem kvE_pastZoneSpec_of_below {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hvx : v < x)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v) :
    zs = kvE_pastGapZone ∨ zs = kvE_pastRayZone ∨ zs = kvE_pastSelfZone := by
  rcases lt_trichotomy v x1 with hlt | heq | hgt
  · exact Or.inr (Or.inl (zoneHolds_unique M _ v zs kvE_pastRayZone hz
      (kvE_pastZone4_of_below M v x1 w x t hxw hwt hvx (true, false)
        (iff_of_true hlt rfl) (iff_of_false (lt_asymm hlt) Bool.false_ne_true))))
  · exact Or.inr (Or.inr (zoneHolds_unique M _ v zs kvE_pastSelfZone hz
      (kvE_pastZone4_of_below M v x1 w x t hxw hwt hvx (false, false)
        (iff_of_false (by rw [heq]; exact lt_irrefl x1) Bool.false_ne_true)
        (iff_of_false (by rw [heq]; exact lt_irrefl x1) Bool.false_ne_true))))
  · exact Or.inl (zoneHolds_unique M _ v zs kvE_pastGapZone hz
      (kvE_pastZone4_of_below M v x1 w x t hxw hwt hvx (false, true)
        (iff_of_false (lt_asymm hgt) Bool.false_ne_true) (iff_of_true hgt rfl)))

/-! ### The reconstruction companion: Past slice uniqueness at m = 0 -/

/-- **m = 0 Past slice uniqueness** (mirror of `kvE_futSliceUnique_zero`; load-bearing for
    the Phase-5 `hexclSlicePast` discharge per the Phase-3b deviation record): two σ's
    pinned-realized at (possibly different) exterior-past endpoints over the same
    `[w, x, t]` with equal Past exterior slices are EQUAL. Route: slice-equal atom layers
    give the two endpoints the same complete depth-0 atomic profile (`nf_eval_unique`);
    exterior-zone fiber bits agree by the slice hypothesis; interior fiber elements
    (witness `¬ v < x` by exterior-zone classification) transfer between profile-equal
    endpoints with the SAME witness (`kvE_pastInteriorTransfer_zero`), so the depth-1 fold
    biconditionals force every remaining bit to coincide. -/
theorem kvE_pastSliceUnique_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (σ' σ : NormalForm sig 1 4)
    (w x t x1' x1 : M.carrier) (hxw : x < w) (hwt : w < t)
    (hx1'x : x1' < x) (hx1x : x1 < x)
    (hslice : kvE_pastSliceEq σ' σ = true)
    (hσ' : nf_eval_nf M 1 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ')
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    σ' = σ := by
  unfold kvE_pastSliceEq at hslice
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hslice
  obtain ⟨⟨⟨h1d, hgapL⟩, hrayL⟩, hselfL⟩ := hslice
  have h1 : σ'.1 = σ.1 := of_decide_eq_true h1d
  have hgapL := of_decide_eq_true hgapL
  have hrayL := of_decide_eq_true hrayL
  have hselfL := of_decide_eq_true hselfL
  -- profile-equal endpoints: each side's atom layer is the other's endpoint characteristic
  have hσA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
    nf_eval_nf_atom_layer M _ σ hσ
  have hσ'A : nf_eval_nf M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ'.1 :=
    nf_eval_nf_atom_layer M _ σ' hσ'
  have hσ1c : σ.1 =
      nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) :=
    nf_eval_unique M 0 4 _ _ _ hσA (nf_characteristic_satisfies M 0 4 _)
  have hσ'1c : σ'.1 =
      nf_characteristic M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) :=
    nf_eval_unique M 0 4 _ _ _ hσ'A (nf_characteristic_satisfies M 0 4 _)
  have hchar : nf_eval_nf M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) := by
    rw [← hσ1c, ← h1]; exact hσ'A
  have hchar' : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))) := by
    rw [← hσ'1c, h1]; exact hσA
  refine Prod.ext h1 ?_
  funext s
  by_cases hzc : nfk_zoneSpec s = kvE_pastGapZone ∨ nfk_zoneSpec s = kvE_pastRayZone ∨
      nfk_zoneSpec s = kvE_pastSelfZone
  · -- exterior zones: the slice hypothesis decides the bit through zone-list membership
    have key : ∀ z : ZoneSpec 4,
        kvE_fiberZoneList σ' z = kvE_fiberZoneList σ z → nfk_zoneSpec s = z →
        σ'.2 s = σ.2 s := by
      intro z hL hz
      cases hb : σ.2 s with
      | true =>
        have hmem : s ∈ kvE_fiberZoneList σ z := (kvE_fiberZoneList_mem σ z s).mpr ⟨hb, hz⟩
        rw [← hL] at hmem
        exact ((kvE_fiberZoneList_mem σ' z s).mp hmem).1
      | false =>
        cases hb' : σ'.2 s with
        | false => rfl
        | true =>
          have hmem : s ∈ kvE_fiberZoneList σ' z :=
            (kvE_fiberZoneList_mem σ' z s).mpr ⟨hb', hz⟩
          rw [hL] at hmem
          have hbit := ((kvE_fiberZoneList_mem σ z s).mp hmem).1
          rw [hb] at hbit
          exact absurd hbit Bool.false_ne_true
    rcases hzc with hz | hz | hz
    · exact key kvE_pastGapZone hgapL hz
    · exact key kvE_pastRayZone hrayL hz
    · exact key kvE_pastSelfZone hselfL hz
  · -- interior: same-witness transfer between the profile-equal endpoints
    have hfold := hσ.2 s
    have hfold' := hσ'.2 s
    cases hb : σ.2 s with
    | true =>
      obtain ⟨v, hv⟩ := hfold.mpr hb
      have hzone := kvE_zoneHolds_of_atom M
        (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) v s hv
      have hvx : ¬ v < x := fun hvlt =>
        hzc (kvE_pastZoneSpec_of_below M v x1 w x t hxw hwt hvlt _ hzone)
      exact hfold'.mp
        ⟨v, kvE_pastInteriorTransfer_zero M v x1 x1' w x t hvx hx1x hx1'x hchar s hv⟩
    | false =>
      cases hb' : σ'.2 s with
      | false => rfl
      | true =>
        obtain ⟨v, hv'⟩ := hfold'.mpr hb'
        have hzone := kvE_zoneHolds_of_atom M
          (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) v s hv'
        have hvx : ¬ v < x := fun hvlt =>
          hzc (kvE_pastZoneSpec_of_below M v x1' w x t hxw hwt hvlt _ hzone)
        have hbit := hfold.mp
          ⟨v, kvE_pastInteriorTransfer_zero M v x1' x1 w x t hvx hx1'x hx1x hchar' s hv'⟩
        rw [hb] at hbit
        exact absurd hbit Bool.false_ne_true

/-! ### Private navigation helpers for the slice-id (Past mirrors of the Future file's
private `kvE_projFresh_zero`/`kvE_futGapItem_pinned_zero`/`kvE_futRayItem_pinned_zero`,
ExteriorPinnedConverseK.lean:772-832; replication precedent as above) -/

/-- File-local replica of the private `nfk_projFresh_zero` (CarrierKv.lean:89 — `private`,
    replicated per the established precedent, never imported): at depth 0 the prefix
    projection coincides with the split kit's `nf0_projFresh`. -/
private theorem kvE_pastProjFresh_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) :
    nfk_projFresh sub = nf0_projFresh sub := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    rfl
  | .order i j h => exact absurd (Subsingleton.elim i j) h

/-- Free-env → pinned upgrade, GAP case (Past): an on-fiber, gap-zoned depth-0 fiber
    element with a free-env occurrence at a walk point `r ∈ (x1, x)` is pinned-realized at
    `[r, x1, w, x, t]`, given the pinned atom layer `α` at `[x1, w, x, t]`. Mirror of
    `kvE_futGapItem_pinned_zero`. -/
private theorem kvE_pastGapItem_pinned_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (r x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hx1r : x1 < r) (hrx : r < x)
    (α : NormalForm sig 0 4)
    (hA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) α)
    (s : NormalForm sig 0 5)
    (hfib : nf0_dropFresh s = α)
    (hzone : nf0_zoneSpec s = kvE_pastGapZone)
    (hocc : ∃ env : Fin 4 → M.carrier, nf_eval_nf M 0 5 (Fin.cons r env) s) :
    nf_eval_nf M 0 5
      (Fin.cons r (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s := by
  obtain ⟨env, hev⟩ := hocc
  have hfac := (nf_eval_nf0_cons_factor M env r s).mp hev
  refine (nf_eval_nf0_cons_factor M
    (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) r s).mpr ⟨?_, hfac.2.1, ?_⟩
  · rw [hzone]
    exact kvE_pastZone4_of_below M r x1 w x t hxw hwt hrx
      (false, true) (iff_of_false (lt_asymm hx1r) Bool.false_ne_true)
      (iff_of_true hx1r rfl)
  · rw [hfib]
    exact hA

/-- Free-env → pinned upgrade, RAY case (Past): the same upgrade for a ray-zoned fiber
    element at `r < x1`. Mirror of `kvE_futRayItem_pinned_zero`. -/
private theorem kvE_pastRayItem_pinned_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (r x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hx1x : x1 < x) (hrx1 : r < x1)
    (α : NormalForm sig 0 4)
    (hA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) α)
    (s : NormalForm sig 0 5)
    (hfib : nf0_dropFresh s = α)
    (hzone : nf0_zoneSpec s = kvE_pastRayZone)
    (hocc : ∃ env : Fin 4 → M.carrier, nf_eval_nf M 0 5 (Fin.cons r env) s) :
    nf_eval_nf M 0 5
      (Fin.cons r (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s := by
  obtain ⟨env, hev⟩ := hocc
  have hfac := (nf_eval_nf0_cons_factor M env r s).mp hev
  refine (nf_eval_nf0_cons_factor M
    (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) r s).mpr ⟨?_, hfac.2.1, ?_⟩
  · rw [hzone]
    exact kvE_pastZone4_of_below M r x1 w x t hxw hwt (hrx1.trans hx1x)
      (true, false) (iff_of_true hrx1 rfl)
      (iff_of_false (lt_asymm hrx1) Bool.false_ne_true)
  · rw [hfib]
    exact hA

/-! ### The Past exterior-slice identification converse at m = 0 -/

/-- **Past exterior-slice identification at m = 0** (Rabinovich Cor 5.4(2) ⇐ under the
    Def 7.13 segment discipline; verbatim mirror of `kvE_futSliceId_of_end_zero`,
    ExteriorPinnedConverseK.lean:889 — UNBLOCKED by the Phase-4a conjunct-4 restoration): at
    a destructor-selected exterior-past endpoint `x1 < x` carrying the endpoint/walk truths,
    under the level-up ambient, the endpoint's HONEST complete type σ★ is qnf-marked,
    pinned-realized at `[x1, w, x, t]`, and agrees with σ on the atom layer and on every
    Past exterior-zone marking. (σ★ := `nf_characteristic M 1 4 [x1, w, x, t]`; item content
    in `hocc` is the raw shift-bridged form `P.existF 4 (renameNF rot5Fwd rot5Bwd s)`, the
    Past clause family's per-item convention — `kvE_pastRayForm`,
    ExteriorNegationPastK.lean:424.)

    Proof route (the Future's five steps, machine-validated end-to-end as the Phase-4a gate
    probe): (1) totality + ambient marking of σ★; (2) atom layer via `kvE_pastAtomPinned_zero`
    + depth-0 `nf_eval_unique`; (3) gap agreement, both inclusions, via `hocc`/`hgap` + the
    free-env → pinned upgrade + uniqueness; (4) ray agreement via `hend`'s per-item and
    `¬P(¬D_ray)` conjuncts + upgrade + uniqueness; (5) self agreement via `hend`'s self
    conjunct + coincidence + the RESTORED admissibility conjunct 4 + `nf0_split_assemble`. -/
theorem kvE_pastSliceId_of_end_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (hadm : kvE_pastAdmissible σ = true)
    (hfib : nfk_dropFresh σ = qnf.1)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (x1 : M.carrier) (hx1x : x1 < x)
    (hend : temporal_truth M atomMap x1 (kvE_pastEnd P σ))
    (hgap : ∀ r : M.carrier, x1 < r → r < x →
      temporal_truth M atomMap r (kvE_pastGapD P σ))
    (hocc : ∀ s ∈ kvE_fiberZoneList σ kvE_pastGapZone, ∃ r : M.carrier,
      x1 < r ∧ r < x ∧
        temporal_truth M atomMap r (P.existF 4 (renameNF rot5Fwd rot5Bwd s))) :
    ∃ σ' : NormalForm sig 1 4,
      qnf.2 σ' = true ∧
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ' ∧
      σ'.1 = σ.1 ∧
      ∀ s : NormalForm sig 0 5,
        (nfk_zoneSpec s = kvE_pastGapZone ∨ nfk_zoneSpec s = kvE_pastRayZone ∨
         nfk_zoneSpec s = kvE_pastSelfZone) → σ'.2 s = σ.2 s := by
  -- Step 1: σ★ := the honest endpoint characteristic — pinned (totality) + qnf-marked
  set τ : NormalForm sig 1 4 :=
    nf_characteristic M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) with hτdef
  have hτpin : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ :=
    nf_characteristic_satisfies M 1 4 _
  have hτmark : qnf.2 τ = true := (h.2 τ).mp ⟨x1, hτpin⟩
  have hτ2 : ∀ e : NormalForm sig 0 5,
      τ.2 e = @decide (∃ z : M.carrier, nf_eval_nf M 0 5
        (Fin.cons z (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) e)
        (Classical.dec _) := fun e => by rw [hτdef]; rfl
  -- Step 2: atom-layer identification (Phase-4 atom supplier + depth-0 uniqueness)
  have hτA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ.1 :=
    nf_eval_nf_atom_layer M _ τ hτpin
  have hσA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
    kvE_pastAtomPinned_zero P M h_UZ h_SZ qnf σ hadm hfib w x t hxw hwt h x1 hx1x hend
  have h31 : τ.1 = σ.1 := nf_eval_unique M 0 4 _ _ _ hτA hσA
  -- shared: σ-marked elements sit on τ's atom fiber
  have honfib : ∀ s : NormalForm sig 0 5, σ.2 s = true → nf0_dropFresh s = τ.1 := by
    intro s hbit
    have hd := kvE_pastAdmissible_onFiber σ hadm s hbit
    rw [h31]; exact hd
  -- endpoint-description components (consumed by the ray and self cases)
  have hendC := hend
  rw [kvE_pastEnd, formula_conjList_iff] at hendC
  have hselfC := hendC (kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_pastSelfZone))
    (by simp)
  have hrayC := hendC (kvE_pastRayForm P σ) (by simp)
  rw [kvE_pastRayForm, formula_conjList_iff] at hrayC
  rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1] at hselfC
  obtain ⟨s0, hs0mem, env0, hev0⟩ := hselfC
  obtain ⟨hbit0, hzs0⟩ := (kvE_fiberZoneList_mem σ kvE_pastSelfZone s0).mp hs0mem
  -- the delivered self element upgrades to PINNED realization at [x1, w, x, t]
  have hzx1self : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      kvE_pastSelfZone x1 :=
    kvE_pastZone4_of_below M x1 x1 w x t hxw hwt hx1x
      (false, false) (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
      (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
  obtain ⟨-, hfr0, -⟩ := (nf_eval_nf0_cons_factor M env0 x1 s0).mp hev0
  have hs0pin : nf_eval_nf M 0 5
      (Fin.cons x1 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s0 := by
    refine (nf_eval_nf0_cons_factor M
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) x1 s0).mpr ⟨?_, hfr0, ?_⟩
    · have hzs0' : nf0_zoneSpec s0 = kvE_pastSelfZone := hzs0
      rw [hzs0']; exact hzx1self
    · have htl0' : nf0_dropFresh s0 = τ.1 := honfib s0 hbit0
      rw [htl0']; exact hτA
  have hτs0 : τ.2 s0 = true := by
    rw [hτ2]
    exact @decide_eq_true _ (Classical.dec _) ⟨x1, hs0pin⟩
  refine ⟨τ, hτmark, hτpin, h31, ?_⟩
  intro s hzcase
  rcases hzcase with hzs | hzs | hzs
  · -- GAP zone (step 3, both inclusions)
    cases hσbit : σ.2 s with
    | true =>
      -- σ ⊆ σ★: hocc places the listed item in (x1, x); the pinned upgrade
      have hmem : s ∈ kvE_fiberZoneList σ kvE_pastGapZone :=
        (kvE_fiberZoneList_mem σ kvE_pastGapZone s).mpr ⟨hσbit, hzs⟩
      obtain ⟨r, hr1, hr2, hshift⟩ := hocc s hmem
      rw [P.correct 4 (renameNF rot5Fwd rot5Bwd s) M h_UZ h_SZ r] at hshift
      obtain ⟨envr, hevr⟩ := hshift
      have hpin := kvE_pastGapItem_pinned_zero M r x1 w x t hxw hwt hr1 hr2
        τ.1 hτA s (honfib s hσbit) hzs ⟨envr, (kvE_anchorBridge M envr r s).mp hevr⟩
      rw [hτ2]
      exact @decide_eq_true _ (Classical.dec _) ⟨r, hpin⟩
    | false =>
      -- σ★ ⊆ σ: a pinned witness z ∈ (x1, x) meets hgap's listed item; uniqueness
      cases hτbit : τ.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [hτ2] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_zoneHolds_of_atom M
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) z s hz
        rw [hzs] at hzone
        have hx1z : x1 < z := (hzone 0).2.mpr rfl
        have hzx : z < x := by
          have hh := (hzone ⟨2, by omega⟩).1.mpr rfl
          exact hh
        have hD := hgap z hx1z hzx
        rw [kvE_pastGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ z] at hD
        obtain ⟨s', hmem', env', hev'⟩ := hD
        obtain ⟨hbit', hzs'⟩ := (kvE_fiberZoneList_mem σ kvE_pastGapZone s').mp hmem'
        have hpin' := kvE_pastGapItem_pinned_zero M z x1 w x t hxw hwt hx1z hzx
          τ.1 hτA s' (honfib s' hbit') hzs' ⟨env', hev'⟩
        have hss' : s' = s := nf_eval_unique M 0 5
          (Fin.cons z (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s' s hpin' hz
        rw [hss', hσbit] at hbit'
        exact Bool.noConfusion hbit'
  · -- RAY zone (step 4, both directions)
    cases hσbit : σ.2 s with
    | true =>
      -- σ ⊆ σ★: hend's per-item ray conjunct places s below x1; the pinned upgrade
      have hmem : s ∈ kvE_fiberZoneList σ kvE_pastRayZone :=
        (kvE_fiberZoneList_mem σ kvE_pastRayZone s).mpr ⟨hσbit, hzs⟩
      have hitem := hrayC
        (Formula.snce (P.existF 4 (renameNF rot5Fwd rot5Bwd s)) Formula.top)
        (List.mem_cons_of_mem _ (List.mem_map.mpr ⟨s, hmem, rfl⟩))
      obtain ⟨v, hvx1, hsh, -⟩ := hitem
      rw [P.correct 4 (renameNF rot5Fwd rot5Bwd s) M h_UZ h_SZ v] at hsh
      obtain ⟨envv, hevv⟩ := hsh
      have hpin := kvE_pastRayItem_pinned_zero M v x1 w x t hxw hwt hx1x hvx1
        τ.1 hτA s (honfib s hσbit) hzs ⟨envv, (kvE_anchorBridge M envv v s).mp hevv⟩
      rw [hτ2]
      exact @decide_eq_true _ (Classical.dec _) ⟨v, hpin⟩
    | false =>
      -- σ★ ⊆ σ: hend's ¬P(¬D_ray) conjunct covers the pinned witness z < x1; uniqueness
      cases hτbit : τ.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [hτ2] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_zoneHolds_of_atom M
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) z s hz
        rw [hzs] at hzone
        have hzx1 : z < x1 := (hzone 0).1.mpr rfl
        have hnf := hrayC (Formula.snce (kvE_pastRayD P σ).neg Formula.top).neg (by simp)
        rw [temporal_truth_neg] at hnf
        have hDz : temporal_truth M atomMap z (kvE_pastRayD P σ) := by
          by_contra hnD
          exact hnf ⟨z, hzx1, (temporal_truth_neg M atomMap z _).mpr hnD,
            fun r _ _ => id⟩
        rw [kvE_pastRayD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ z] at hDz
        obtain ⟨s', hmem', env', hev'⟩ := hDz
        obtain ⟨hbit', hzs'⟩ := (kvE_fiberZoneList_mem σ kvE_pastRayZone s').mp hmem'
        have hpin' := kvE_pastRayItem_pinned_zero M z x1 w x t hxw hwt hx1x hzx1
          τ.1 hτA s' (honfib s' hbit') hzs' ⟨env', hev'⟩
        have hss' : s' = s := nf_eval_unique M 0 5
          (Fin.cons z (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s' s hpin' hz
        rw [hss', hσbit] at hbit'
        exact Bool.noConfusion hbit'
  · -- SELF zone (step 5)
    cases hσbit : σ.2 s with
    | true =>
      -- restored admissibility conjunct 4: one self profile ⇒ s IS the delivered s0
      have hdS := kvE_pastAdmissible_onFiber σ hadm s hσbit
      have hdS0 := kvE_pastAdmissible_onFiber σ hadm s0 hbit0
      have hadm' := hadm
      unfold kvE_pastAdmissible at hadm'
      rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hadm'
      have hc4 := hadm'.2
      have hbitS : kvE_subBit σ kvE_pastSelfZone (nfk_projFresh s) = true := by
        refine List.any_eq_true.mpr ⟨s, Finset.mem_toList.mpr (Finset.mem_univ s), ?_⟩
        rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
        exact ⟨⟨⟨decide_eq_true hdS, decide_eq_true hzs⟩, decide_eq_true rfl⟩, hσbit⟩
      have hbitS0 : kvE_subBit σ kvE_pastSelfZone (nfk_projFresh s0) = true := by
        refine List.any_eq_true.mpr ⟨s0, Finset.mem_toList.mpr (Finset.mem_univ s0), ?_⟩
        rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
        exact ⟨⟨⟨decide_eq_true hdS0, decide_eq_true hzs0⟩, decide_eq_true rfl⟩, hbit0⟩
      have hχ : nfk_projFresh s = nfk_projFresh s0 := by
        have h4 := (List.all_eq_true.mp hc4) (nfk_projFresh s)
          (Finset.mem_toList.mpr (Finset.mem_univ _))
        have h4' := (List.all_eq_true.mp h4) (nfk_projFresh s0)
          (Finset.mem_toList.mpr (Finset.mem_univ _))
        rw [Bool.or_eq_true, Bool.or_eq_true, hbitS, hbitS0] at h4'
        rcases h4' with (h | h) | h
        · exact absurd h (by decide)
        · exact absurd h (by decide)
        · exact of_decide_eq_true h
      have hs_eq : s = s0 := by
        have h1 : nf0_zoneSpec s = nf0_zoneSpec s0 := by
          have ha : nf0_zoneSpec s = kvE_pastSelfZone := hzs
          have hb : nf0_zoneSpec s0 = kvE_pastSelfZone := hzs0
          rw [ha, hb]
        have h2 : nf0_projFresh s = nf0_projFresh s0 := by
          rw [← kvE_pastProjFresh_zero s, ← kvE_pastProjFresh_zero s0]; exact hχ
        have h3 : nf0_dropFresh s = nf0_dropFresh s0 := by
          rw [honfib s hσbit, honfib s0 hbit0]
        calc s = nf0_assemble (nf0_zoneSpec s) (nf0_projFresh s) (nf0_dropFresh s) :=
              (nf0_split_assemble s).symm
          _ = nf0_assemble (nf0_zoneSpec s0) (nf0_projFresh s0) (nf0_dropFresh s0) := by
              rw [h1, h2, h3]
          _ = s0 := nf0_split_assemble s0
      rw [hs_eq]; exact hτs0
    | false =>
      -- σ★ ⊆ σ: a pinned self witness coincides with x1; uniqueness against s0
      cases hτbit : τ.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [hτ2] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_zoneHolds_of_atom M
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) z s hz
        rw [hzs] at hzone
        have hzx1 : z = x1 := kvE_pastSelfZone_coincide M hzone
        rw [hzx1] at hz
        have hss0 : s = s0 := nf_eval_unique M 0 5
          (Fin.cons x1 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s s0 hz hs0pin
        rw [hss0, hbit0] at hσbit
        exact Bool.noConfusion hσbit

/-! ### Phase 5 — the m=0 supply theorem for the slice-keyed exterior interface (Past)

Mirror of the Future-file Phase-5 section (`ExteriorPinnedConverseK.lean`): the m=0
discharge of the carried `hexclSlicePast` obligation consumed by task 358's
`KampPrior.lean:361` arm and task 349 v8 Phase 6 through `EndIntervalCorrectPrior`'s
`m + 2` arm (EndIntervalConsumerK.lean:151-157) at `m := 0`. Statement is the 3b binder
type at `k := 0`, signature-locked, plus the ambient interior obligation `hreal` (report 02
§3.4 last paragraph). The eliminated `kvE_hbrPast*_supply_zero` v1 targets stay eliminated
(`kvE_futPinned_of_end_zero_refuted` is the Future-side machine refutation of the shared
guarded-Sat shape). The Past `hslicePast` discharge, initially BLOCKED on the fiber-input
gap, closes below under the Phase-3c fiber-guarded interface (report 04) — mirror of
`kvE_hsliceFut_supply_zero`. -/

/-- **m=0 supply for the carried `hexclSlicePast` obligation** (task 360 plan v2 Phase 5;
    binder text verbatim at `k := 0`, mirror of `kvE_hexclSliceFut_supply_zero`): given the
    interior obligation `hreal`, a bit-false-but-slice-MARKED admissible σ has no
    strictly-exterior realizer below `x`. Route: slice marking → marked admissible mate σ″
    (`kvE_pastSliceMarked_iff`) → `hreal` realizes σ″ → endpoint exterior by the Past
    admissibility zone marking read back through the realization →
    `kvE_pastSliceUnique_zero` collapses σ″ = σ → bit contradiction. Load-bearing consumer
    of Phase 4's `kvE_pastSliceUnique_zero` (the Phase-3b deviation record). -/
theorem kvE_hexclSlicePast_supply_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3)
    (x t : M.carrier)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF 1) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF 1) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
        kvE_pastSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, x1 < x →
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro w hxw hwt hptW σ hadm hbit hsm x1 hx1x hnf
  obtain ⟨σ'', hadm'', hslEq, hmark⟩ := (kvE_pastSliceMarked_iff qnf σ).mp hsm
  -- the marked mate is realizable via the interior obligation
  obtain ⟨x1'', hσ''⟩ := hreal w hxw hwt hptW σ'' hmark
  -- its endpoint is exterior: Past admissibility zone marking read back through the realization
  have hzone : nf0_zoneSpec σ''.1 = kvE2_sep_zPastX3 := by
    have hh := hadm''
    rw [kvE_pastAdmissible] at hh
    simp only [Bool.and_eq_true] at hh
    exact of_decide_eq_true hh.1.1.1
  have hb1 : (nf0_zoneSpec σ''.1 ⟨1, by omega⟩).1 = true := by rw [hzone]; rfl
  have h1 := hσ''.1 (.order 0 (Fin.succ ⟨1, by omega⟩) (Fin.succ_ne_zero ⟨1, by omega⟩).symm)
  simp only [atom_eval, Fin.cons] at h1
  have hx1''x : x1'' < x := h1.mpr hb1
  -- uniqueness collapses the mate onto σ — contradicting the bit split
  have heq : σ'' = σ :=
    kvE_pastSliceUnique_zero M σ'' σ w x t x1'' x1 hxw hwt hx1''x hx1x hslEq hσ'' hnf
  rw [heq, hbit] at hmark
  exact Bool.noConfusion hmark

/-- **m=0 supply for the carried `hslicePast` obligation** (task 360 plan v2 Phase 5, under
    the Phase-3c fiber-guarded interface; binder text verbatim at `k := 0`, mirror of
    `kvE_hsliceFut_supply_zero`): chain-fire truth `kvE_pastPos P σ` at `x` for a
    fiber-compatible admissible σ under the honest ambient yields an admissible, slice-equal,
    qnf-MARKED mate.

    Route (the Future route mirrored through the landed Past suppliers): destruct the Cor 5.4
    `Since` chain (`kvE_pastChainDestructG`, the `kvE_extNegPast_complete` destructor pattern
    at `k := 0` — items in the raw shift-bridged form `P.existF 4 (renameNF rot5Fwd rot5Bwd
    s)`) to an exterior endpoint `x1 < x` with `hend`/`hgap`/`hocc`; apply
    `kvE_pastSliceId_of_end_zero` (Phase 4); admissibility via `kvE_pastRealizer_admissible`
    on the pinned realizer; slice equality via `kvE_fiberZoneList_congr` (zone-generic,
    Future file) on the three Past exterior zones. -/
theorem kvE_hslicePast_supply_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig 2 3)
    (x t : M.carrier) :
    ∀ w : M.carrier, x < w → w < t →
      nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig 1 4, kvE_pastAdmissible σ = true →
        nfk_dropFresh σ = qnf.1 →
        temporal_truth M atomMap x (kvE_pastPos P σ) →
        ∃ σ' : NormalForm sig 1 4, kvE_pastAdmissible σ' = true ∧
          kvE_pastSliceEq σ' σ = true ∧ qnf.2 σ' = true := by
  intro w hxw hwt h σ hadm hfib hposT
  -- destruct the Cor 5.4 Since chain (the `kvE_extNegPast_complete` destructor pattern, k = 0)
  rw [kvE_pastPos, if_pos hadm, formula_disjList_iff] at hposT
  obtain ⟨φ, hφmem, hφ⟩ := hposT
  obtain ⟨l, hlmem, rfl⟩ := List.mem_map.mp hφmem
  have hlperm : l.Perm (kvE_fiberZoneList σ kvE_pastGapZone) :=
    List.mem_permutations.mp hlmem
  -- item ⇒ gap guard: each chain item is a gap fiber sub, so it enters the gap disjunction
  have himp : ∀ a ∈ l, ∀ r : M.carrier,
      temporal_truth M atomMap r (P.existF 4 (renameNF rot5Fwd rot5Bwd a)) →
      temporal_truth M atomMap r (kvE_pastGapD P σ) := by
    intro a ha r hr
    have hamem : a ∈ kvE_fiberZoneList σ kvE_pastGapZone := hlperm.subset ha
    rw [kvE_pastGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
    rw [P.correct 4 (renameNF rot5Fwd rot5Bwd a) M h_UZ h_SZ r] at hr
    obtain ⟨env, hev⟩ := hr
    exact ⟨a, hamem, env, (kvE_anchorBridge M env r a).mp hev⟩
  obtain ⟨x1, hx1x, hend, hgap, hocc⟩ :=
    kvE_pastChainDestructG M atomMap (fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s))
      (kvE_pastEnd P σ) (kvE_pastGapD P σ) l x himp hφ
  have hoccZ : ∀ a ∈ kvE_fiberZoneList σ kvE_pastGapZone, ∃ r : M.carrier,
      x1 < r ∧ r < x ∧ temporal_truth M atomMap r (P.existF 4 (renameNF rot5Fwd rot5Bwd a)) :=
    fun a ha => hocc a (hlperm.mem_iff.mpr ha)
  -- slice identification at the destructor endpoint (hfib is binder-supplied — Phase 3c)
  obtain ⟨σ', hmark, hpin, h1, h2⟩ :=
    kvE_pastSliceId_of_end_zero P M h_UZ h_SZ qnf σ hadm hfib w x t hxw hwt h x1 hx1x
      hend hgap hoccZ
  -- admissibility from the pinned realizer; slice equality from atom + zone-list congruence
  have hadm' : kvE_pastAdmissible σ' = true :=
    kvE_pastRealizer_admissible M σ' x1 w x t hxw hwt hx1x hpin
  have hgapL := kvE_fiberZoneList_congr σ σ' kvE_pastGapZone
    (fun s hz => h2 s (Or.inl hz))
  have hrayL := kvE_fiberZoneList_congr σ σ' kvE_pastRayZone
    (fun s hz => h2 s (Or.inr (Or.inl hz)))
  have hselfL := kvE_fiberZoneList_congr σ σ' kvE_pastSelfZone
    (fun s hz => h2 s (Or.inr (Or.inr hz)))
  have hslEq : kvE_pastSliceEq σ' σ = true := by
    rw [kvE_pastSliceEq, decide_eq_true h1, decide_eq_true hgapL, decide_eq_true hrayL,
      decide_eq_true hselfL]
    rfl
  exact ⟨σ', hadm', hslEq, hmark⟩

end Bimodal.Metalogic.WeakCanonical.Kamp

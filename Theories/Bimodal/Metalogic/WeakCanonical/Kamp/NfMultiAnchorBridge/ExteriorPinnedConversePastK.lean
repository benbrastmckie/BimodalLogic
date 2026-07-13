import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationPastK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterPastK

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
noncomputable def kvE_pastSliceEq {sig : MonadicSignature} {k : Nat}
    (σ' σ : NormalForm sig (k + 1) 4) : Bool :=
  decide (σ'.1 = σ.1) &&
  decide (kvE_fiberZoneList σ' kvE_pastGapZone  = kvE_fiberZoneList σ kvE_pastGapZone) &&
  decide (kvE_fiberZoneList σ' kvE_pastRayZone  = kvE_fiberZoneList σ kvE_pastRayZone) &&
  decide (kvE_fiberZoneList σ' kvE_pastSelfZone = kvE_fiberZoneList σ kvE_pastSelfZone)

/-- **σ's Past exterior slice is qnf-marked**: some admissible slice-mate carries the bit.
    The faithful Past bracket key (re-keys `kvE_extBracketPast`'s per-σ if-then-else in
    Phase 3b): a negative clause `¬ kvE_pastPos P σ` is asserted iff NO marked type carries
    σ's segment content. Mirror of `kvE_futSliceMarked`. -/
noncomputable def kvE_pastSliceMarked {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (σ : NormalForm sig (k + 1) 4) : Bool :=
  (Finset.univ.toList (α := NormalForm sig (k + 1) 4)).any
    (fun σ' => kvE_pastAdmissible σ' && kvE_pastSliceEq σ' σ && qnf.2 σ')

/-- Unpack/repack the Past slice marking (the extraction interface Phase 3b's D4 and the
    gate consume). Mirror of `kvE_futSliceMarked_iff` (ExteriorBracketAssembleK.lean). -/
theorem kvE_pastSliceMarked_iff {sig : MonadicSignature} {k : Nat}
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
theorem kvE_pastClause_sliceConstant {sig : MonadicSignature}
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

**ASYMMETRY RECORD (plan v2 Phase 4 stopping condition — the slice-id mirror is ABSENT)**:
`kvE_pastSliceId_of_end_zero`, the naive Past mirror of `kvE_futSliceId_of_end_zero`, is
FALSE as mirrored. The Future proof's SELF-zone/bit-true case consumes `kvE_futAdmissible`'s
FOURTH conjunct (self-zone fresh-profile uniqueness, ExteriorNegationK.lean:95-98) to
identify the σ-marked self element with the one element `hend`'s self DISJUNCTION delivers
realized. `kvE_pastAdmissible` (ExteriorNegationPastK.lean:134-140) has only THREE conjuncts
— its docstring delegates the frozen condition (4) to "the full-fiber content channel
downstream", but no hypothesis of the slice-id signature reads self-zone marks per-item
(`kvE_pastEnd`'s self conjunct is `kvE_fiberPosOnShift`, an existential — one realized
element suffices). Counterexample shape: σ := honest endpoint characteristic τ with ONE
extra self-zone mark `s' := nf0_assemble kvE_pastSelfZone χ' τ.1` (`χ'` any fresh profile
other than the realized one): all hypotheses (`hadm` 3-conjunct, `hfib`, ambient, `hend`,
`hgap`, `hocc`) hold verbatim (zone lists enter the clause family only through gap/ray
per-item conjuncts and the self existential), yet any pinned-realized σ' can mark at most
one self-zone element (self-witness coincidence + `nf_eval_unique`), so no σ' agrees with σ
on the self zone. See the plan's Phase-4 BLOCKER block; the theorems below are the mirrors
that DO close (none consumes admissibility conjunct 4). -/

/-! ### Admissibility conjunct-1 reader (Past mirror of `kvE_futAdmissible_zoneMark`) -/

/-- **Admissibility ⇒ zone marking** (Past): under `kvE_pastAdmissible σ`, the atom base
    layer `σ.1` carries the exterior-past zone marking `kvE2_sep_zPastX3` (`x1` strictly
    below each of `w`, `x`, `t`). Boolean conjunct-1 read of `kvE_pastAdmissible`
    (ExteriorNegationPastK.lean:134). -/
theorem kvE_pastAdmissible_zoneMark {sig : MonadicSignature} {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_pastAdmissible σ = true) :
    nf0_zoneSpec σ.1 = kvE2_sep_zPastX3 := by
  have hadm' := hadm
  unfold kvE_pastAdmissible at hadm'
  rw [Bool.and_eq_true, Bool.and_eq_true] at hadm'
  exact of_decide_eq_true hadm'.1.1

/-! ### Self-zone coincidence (Past mirror of `kvE_futSelfZone_coincide`) -/

/-- **Past self-zone coincidence**: the self-zone head coupling `(false, false)`
    (`kvE_pastSelfZone`, ExteriorNegationPastK.lean:213) forces fresh/slot-0 coincidence on
    any linear order — a point `v` in the self zone relative to ANY environment `env`
    satisfies `v = env 0`. Pure `lt_trichotomy` on the index-0 coupling (byte-identical to
    the Future proof: both self zones carry the `(false, false)` head). -/
theorem kvE_pastSelfZone_coincide {sig : MonadicSignature}
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
theorem kvE_pastFreshPinned_of_end {sig : MonadicSignature}
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
theorem kvE_pastAtomPinned_zero {sig : MonadicSignature}
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
theorem kvE_pastInteriorTransfer_zero {sig : MonadicSignature}
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
private theorem kvE_pastZone4_of_below {sig : MonadicSignature}
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
private theorem kvE_pastZoneSpec_of_below {sig : MonadicSignature}
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
theorem kvE_pastSliceUnique_zero {sig : MonadicSignature}
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

end Bimodal.Metalogic.WeakCanonical.Kamp

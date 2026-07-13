import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationPastK

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

end Bimodal.Metalogic.WeakCanonical.Kamp

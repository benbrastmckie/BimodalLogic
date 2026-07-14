import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterPastK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConverseK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConversePastK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberDeepAnchorK

/-! # Depth-`k` exterior-bracket assembly (task 349, v8 Phases 3-4; SLICE-KEYED, task 360 Phase 3b)

The **bracket wrapper** over the delivered depth-`k` exterior-negation **clause** layer
(tasks 352/354). Each depth-`k+1` endpoint characteristic `qnf : NormalForm sig (k+2) 3` carries a
per-sub bit `qnf.2 σ` over its exterior-anchor-enriched subs `σ : NormalForm sig (k+1) 4`. The
future/past adjacent brackets conjoin, over the ORDER-ADMISSIBLE subs (`kvE_futAdmissible` /
`kvE_pastAdmissible`, ExteriorNegationK.lean:86 / ExteriorNegationPastK.lean:134), the positive
local-existence clause `kvE_futPos`/`kvE_pastPos` (352) when σ's exterior SLICE is qnf-marked
(`kvE_futSliceMarked`/`kvE_pastSliceMarked` — some admissible slice-mate carries the bit) and the
complement clause `kvE_extNegFut`/`kvE_extNegPast` (352) when the slice is unmarked.

**Slice re-key (task 360 Phase 3b, report 02 §3.3-3.4; Rabinovich Def 7.13 footprint
discipline).** The original per-σ keying (`if qnf.2 σ = true then …`) was structurally DEFECTIVE:
the clause family reads `σ.2` exclusively through the three exterior zone lists, so slice-equal
σ's receive syntactically EQUAL clauses (`kvE_futClause_sliceConstant` /
`kvE_pastClause_sliceConstant`); a slice pair split by the bit (machine witness: the refutation's
(σ′, τ) pair, `kvE_futPinned_of_end_zero_refuted`) then conjoined `kvE_futPos τ` AND its negation
— the honest bracket was UNSATISFIABLE. The slice key gives slice-mates the same clause, restoring
the paper's negation device (`¬F0 ∨ On`, chunk_0015:39-41: negation applies per SEGMENT bracket,
never per full type).

**Fiber re-key (task 360 Phase 3c, report 04; Rabinovich Def 7.13 single-disjunct segment
discipline).** The bracket range is the FIBER-compatible admissible subs:
`kvE_{fut,past}Admissible σ && decide (nfk_dropFresh σ = qnf.1)`. The Phase-3b/task-352 depth-k
rewrite had silently WIDENED the range to all admissible σ, dropping the frozen k=2 template's
base/fiber conjunct (`kvE2_futMarked`'s `decide (nf0_dropFresh σ.1 = qnf.1)`,
ExteriorBracket.lean:127/140) — the ⇐-side honesty obligation for off-fiber σ was then FALSE
(ℤ-doppelgänger countermodel, plan v2 Phase-5 BLOCKER record). Off-fiber σ are unrealizable at
the pinned anchors (the fiber-forcing kernel `nf_eval_nf_atom_layer` → `nf_eval_nf0_cons_factor`
→ `nf_eval_unique`, NfEFold.lean:634-641), so narrowing is lossless for every consumer; the
gate's ⇒-side refutes off-fiber σ internally via that kernel under a gate-derived atom-layer pin
(`ExteriorGateAssembleK.lean`). Off-fiber exclusion is NOT D1/D2's job.

This is the depth-`k` analog of the frozen k=2 brackets `kvE2_extBracketFut`/`kvE2_extBracketPast`
(ExteriorBracket.lean:364/377), one fold-layer deeper. (Phase-6 AUDIT flag: the frozen k=2
brackets keep the per-σ bit keying inside a `kvE2_futMarked`-filtered range; whether the k=2
marking pins enough of `σ.2` to escape the same defect is a task-360 Phase-6 audit item.)

**Interface note (task 360 Phase 3b):** the `_complete` lemmas (D3/D4) no longer thread the 354
converter residue `hreal`/`hsat` nor a per-σ `hneg`; the negative case consumes ONE carried
slice-honesty obligation per side (`hslice` — chain-fire truth at the anchor yields a marked
slice-mate; report 02 §3.4, discharged at m = 0 by `kvE_futSliceId_of_end_zero` + chain
destruction, plan v2 Phase 5). The `_sound` lemmas (D1/D2) weaken to SLICE-level exclusion; per-σ
exclusion for bit-false-but-slice-marked σ is recovered where consumed (the gate's `hexclExt`
discharge) via the carried `hexclSlice*` obligations, m=0-discharged by `kvE_futSliceUnique_zero`
+ the interior-style `hreal` (report 02 §3.4 last paragraph). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff)

/-! ## The Future slice-marking extraction interface -/

/-- Unpack/repack the Future slice marking (the extraction interface D1/D3 and the gate
    consume). Future twin of `kvE_pastSliceMarked_iff` (ExteriorPinnedConversePastK.lean);
    placed here (not in ExteriorPinnedConverseK) to keep the Phase-3 converse file read-only
    in Phase 3b. -/
theorem kvE_futSliceMarked_iff {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (σ : NormalForm sig (k + 1) 4) :
    kvE_futSliceMarked qnf σ = true ↔
      ∃ σ' : NormalForm sig (k + 1) 4, kvE_futAdmissible σ' = true ∧
        kvE_futSliceEq σ' σ = true ∧ qnf.2 σ' = true := by
  rw [kvE_futSliceMarked, List.any_eq_true]
  constructor
  · rintro ⟨σ', -, h⟩
    rw [Bool.and_eq_true, Bool.and_eq_true] at h
    exact ⟨σ', h.1.1, h.1.2, h.2⟩
  · rintro ⟨σ', h1, h2, h3⟩
    exact ⟨σ', Finset.mem_toList.mpr (Finset.mem_univ σ'), by rw [h1, h2, h3]; rfl⟩

/-! ## The depth-`k` adjacent exterior brackets (Def 7.5 p.13, one fold deeper; SLICE-KEYED) -/

/-- **Future-side depth-`k` adjacent exterior bracket** (anchored at `t` over `(t, ∞)`;
    SLICE-KEYED, task 360 Phase 3b): the conjunction over the ORDER-ADMISSIBLE subs
    `σ : NormalForm sig (k+1) 4` of the positive local-existence clause `kvE_futPos P σ` (352,
    Lemma 7.10 p.15) when σ's exterior slice is qnf-marked (`kvE_futSliceMarked` — some
    admissible slice-mate carries the bit) and of the complement clause `kvE_extNegFut P σ`
    (352) when the slice is unmarked. Slice-mates receive the SAME clause
    (`kvE_futClause_sliceConstant`), so the honest bracket is satisfiable — the per-σ-bit
    keying this replaces conjoined `F ∧ ¬F` on the refutation's (σ′, τ) slice pair. -/
noncomputable def kvE_extBracketFut {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (qnf : NormalForm sig (k + 2) 3) : Formula :=
  formula_conjList
    (((Finset.univ.toList (α := NormalForm sig (k + 1) 4)).filter
        (fun σ => kvE_futAdmissible σ && kvE_deepOnFiber qnf σ)).map
      fun σ =>
        if kvE_futSliceMarked qnf σ = true then kvE_futPos P σ else kvE_extNegFut P σ)

/-- **Past-side depth-`k` adjacent exterior bracket** (mirror, anchored at `x` over `(-∞, x)`;
    SLICE-KEYED, task 360 Phase 3b): `Since`-navigated existence clause `kvE_pastPos P σ` for
    slice-marked admissible σ (`kvE_pastSliceMarked`), complement clause `kvE_extNegPast P σ`
    for slice-unmarked admissible σ. Depth-`k` analog of the frozen `kvE2_extBracketPast`
    (ExteriorBracket.lean:377). -/
noncomputable def kvE_extBracketPast {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (qnf : NormalForm sig (k + 2) 3) : Formula :=
  formula_conjList
    (((Finset.univ.toList (α := NormalForm sig (k + 1) 4)).filter
        (fun σ => kvE_pastAdmissible σ && kvE_deepOnFiber qnf σ)).map
      fun σ =>
        if kvE_pastSliceMarked qnf σ = true then kvE_pastPos P σ else kvE_extNegPast P σ)

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (future side, pure formula-level
    bridge — no pins). Depth-`k` analog of `kvE2_extBracketFut_iff` (ExteriorBracket.lean:389). -/
theorem kvE_extBracketFut_iff {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (M : OrderedMonadicStructure sig) (P : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3) (t : M.carrier) :
    temporal_truth M atomMap t (kvE_extBracketFut P qnf) ↔
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true →
        kvE_deepOnFiber qnf σ = true →
        temporal_truth M atomMap t
          (if kvE_futSliceMarked qnf σ = true then kvE_futPos P σ else kvE_extNegFut P σ) := by
  rw [kvE_extBracketFut, formula_conjList_iff]
  constructor
  · intro h σ hadm hfib
    exact h _ (List.mem_map.mpr ⟨σ, List.mem_filter.mpr
      ⟨Finset.mem_toList.mpr (Finset.mem_univ σ),
       by rw [hadm, hfib]; rfl⟩, rfl⟩)
  · intro h f hf
    obtain ⟨σ, hσmem, rfl⟩ := List.mem_map.mp hf
    have hm := (List.mem_filter.mp hσmem).2
    rw [Bool.and_eq_true] at hm
    exact h σ hm.1 hm.2

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (past side). Depth-`k` analog of
    `kvE2_extBracketPast_iff` (ExteriorBracket.lean:408). -/
theorem kvE_extBracketPast_iff {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (M : OrderedMonadicStructure sig) (P : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3) (x : M.carrier) :
    temporal_truth M atomMap x (kvE_extBracketPast P qnf) ↔
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true →
        kvE_deepOnFiber qnf σ = true →
        temporal_truth M atomMap x
          (if kvE_pastSliceMarked qnf σ = true then kvE_pastPos P σ else kvE_extNegPast P σ) := by
  rw [kvE_extBracketPast, formula_conjList_iff]
  constructor
  · intro h σ hadm hfib
    exact h _ (List.mem_map.mpr ⟨σ, List.mem_filter.mpr
      ⟨Finset.mem_toList.mpr (Finset.mem_univ σ),
       by rw [hadm, hfib]; rfl⟩, rfl⟩)
  · intro h f hf
    obtain ⟨σ, hσmem, rfl⟩ := List.mem_map.mp hf
    have hm := (List.mem_filter.mp hσmem).2
    rw [Bool.and_eq_true] at hm
    exact h σ hm.1 hm.2

/-! ## Composed per-side soundness (D1/D2, SLICE-LEVEL — task 360 Phase 3b) -/

/-- **D1 — Future-side bracket soundness** (SLICE-LEVEL, task 360 Phase 3b): the bracket true
    at `t` kills EVERY slice-UNMARKED σ at every `x1 > t` — σ need not be assumed admissible,
    since a realizer forces admissibility (`kvE_futRealizer_admissible`, 352) and then
    `kvE_extNegFut_sound` (352) refutes it. Per-σ exclusion for bit-false-but-slice-marked σ
    is NOT derivable from the honest bracket (slice-mates share one clause); it is recovered
    where consumed via the carried `hexclSlice*` obligation, m=0-discharged by
    `kvE_futSliceUnique_zero` + `hreal` (report 02 §3.4 last paragraph). -/
theorem kvE_extBracketFut_sound {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap t (kvE_extBracketFut P qnf)) :
    ∀ σ : NormalForm sig (k + 1) 4, kvE_deepOnFiber qnf σ = true →
      kvE_futSliceMarked qnf σ = false →
      ∀ x1 : M.carrier, t < x1 →
        ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hfib hbit x1 htx1 hnf
  have hadm : kvE_futAdmissible σ = true :=
    kvE_futRealizer_admissible M σ x1 w x t hxw hwt htx1 hnf
  have hneg : temporal_truth M atomMap t (kvE_extNegFut P σ) := by
    have h := (kvE_extBracketFut_iff M P qnf t).mp hcl σ hadm hfib
    rwa [if_neg (by simp [hbit])] at h
  exact kvE_extNegFut_sound P M h_UZ h_SZ σ w x t hxw hwt hneg x1 htx1 hnf

/-- **D2 — Past-side bracket soundness** (SLICE-LEVEL, task 360 Phase 3b): the bracket true at
    `x` kills every slice-UNMARKED σ at every `x1 < x`. Mirror of D1. -/
theorem kvE_extBracketPast_sound {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap x (kvE_extBracketPast P qnf)) :
    ∀ σ : NormalForm sig (k + 1) 4, kvE_deepOnFiber qnf σ = true →
      kvE_pastSliceMarked qnf σ = false →
      ∀ x1 : M.carrier, x1 < x →
        ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hfib hbit x1 hx1x hnf
  have hadm : kvE_pastAdmissible σ = true :=
    kvE_pastRealizer_admissible M σ x1 w x t hxw hwt hx1x hnf
  have hneg : temporal_truth M atomMap x (kvE_extNegPast P σ) := by
    have h := (kvE_extBracketPast_iff M P qnf x).mp hcl σ hadm hfib
    rwa [if_neg (by simp [hbit])] at h
  exact kvE_extNegPast_sound P M h_UZ h_SZ σ w x t hxw hwt hneg x1 hx1x hnf

/-! ## Composed per-side completeness (D3/D4 — task 360 Phase 3b: `hreal`/`hsat`/`hneg` DROPPED)

The `_complete` lemmas re-establish the bracket at its anchor from TWO inputs per side:
realizers for admissible bit-true σ (`hpos`, supplied by the ambient fold at the gate), and
ONE slice-honesty obligation (`hslice`, report 02 §3.4): chain-fire truth at the anchor for an
admissible σ yields a MARKED slice-mate. The positive (slice-marked) case transfers the mate's
realizer through clause slice-constancy; the negative (slice-unmarked) case is `hslice`
contraposed. The 354 converter residue `hreal`/`hsat` and the per-σ `hneg` are NOT consumed —
the eliminated guarded `hbr*`-Sat shapes were machine-refuted
(`kvE_futPinned_of_end_zero_refuted`). `hslice` is discharged at m = 0 by
`kvE_futSliceId_of_end_zero` + chain destruction (plan v2 Phase 5). -/

/-- **D3 — Future-side bracket completeness** (SLICE-KEYED, task 360 Phase 3b): realizers for
    the bit-true σ plus the Future slice-honesty obligation re-establish the bracket at `t`. -/
theorem kvE_extBracketFut_complete {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hpos : ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = true →
      ∃ x1 : M.carrier, t < x1 ∧
        nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hslice : ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true →
      kvE_deepOnFiber qnf σ = true →
      temporal_truth M atomMap t (kvE_futPos P σ) →
      ∃ σ' : NormalForm sig (k + 1) 4, kvE_futAdmissible σ' = true ∧
        kvE_futSliceEq σ' σ = true ∧ qnf.2 σ' = true) :
    temporal_truth M atomMap t (kvE_extBracketFut P qnf) := by
  refine (kvE_extBracketFut_iff M P qnf t).mpr fun σ hadm hfib => ?_
  cases hbit : kvE_futSliceMarked qnf σ with
  | true =>
    rw [if_pos rfl]
    obtain ⟨σ', hadm', hsl, hmark⟩ := (kvE_futSliceMarked_iff qnf σ).mp hbit
    rw [← (kvE_futClause_sliceConstant P σ' σ hadm' hadm hsl).1]
    obtain ⟨x1, htx1, hr⟩ := hpos σ' hadm' hmark
    exact kvE_futPos_of_realizer P M h_UZ h_SZ σ' w x t x1 hxw hwt htx1 hr
  | false =>
    rw [if_neg (by simp)]
    rw [kvE_extNegFut, temporal_truth_neg]
    intro hposT
    obtain ⟨σ', hadm', hsl, hmark⟩ := hslice σ hadm hfib hposT
    have hcontra : kvE_futSliceMarked qnf σ = true :=
      (kvE_futSliceMarked_iff qnf σ).mpr ⟨σ', hadm', hsl, hmark⟩
    rw [hbit] at hcontra
    exact Bool.noConfusion hcontra

/-- **D4 — Past-side bracket completeness** (SLICE-KEYED, task 360 Phase 3b): mirror of D3 at
    the left anchor `x`; the positive case inlines the `kvE_futPos_of_realizer` by_contra
    route (no Past supply lemma is landed yet — Phase 4 mirrors it). -/
theorem kvE_extBracketPast_complete {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hpos : ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = true →
      ∃ x1 : M.carrier, x1 < x ∧
        nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hslice : ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true →
      kvE_deepOnFiber qnf σ = true →
      temporal_truth M atomMap x (kvE_pastPos P σ) →
      ∃ σ' : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ' = true ∧
        kvE_pastSliceEq σ' σ = true ∧ qnf.2 σ' = true) :
    temporal_truth M atomMap x (kvE_extBracketPast P qnf) := by
  refine (kvE_extBracketPast_iff M P qnf x).mpr fun σ hadm hfib => ?_
  cases hbit : kvE_pastSliceMarked qnf σ with
  | true =>
    rw [if_pos rfl]
    obtain ⟨σ', hadm', hsl, hmark⟩ := (kvE_pastSliceMarked_iff qnf σ).mp hbit
    rw [← (kvE_pastClause_sliceConstant P σ' σ hadm' hadm hsl).1]
    obtain ⟨x1, hx1x, hr⟩ := hpos σ' hadm' hmark
    by_contra hno
    have hnegcl : temporal_truth M atomMap x (kvE_extNegPast P σ') := by
      rw [kvE_extNegPast, temporal_truth_neg]; exact hno
    exact kvE_extNegPast_sound P M h_UZ h_SZ σ' w x t hxw hwt hnegcl x1 hx1x hr
  | false =>
    rw [if_neg (by simp)]
    rw [kvE_extNegPast, temporal_truth_neg]
    intro hposT
    obtain ⟨σ', hadm', hsl, hmark⟩ := hslice σ hadm hfib hposT
    have hcontra : kvE_pastSliceMarked qnf σ = true :=
      (kvE_pastSliceMarked_iff qnf σ).mpr ⟨σ', hadm', hsl, hmark⟩
    rw [hbit] at hcontra
    exact Bool.noConfusion hcontra

end Bimodal.Metalogic.WeakCanonical.Kamp

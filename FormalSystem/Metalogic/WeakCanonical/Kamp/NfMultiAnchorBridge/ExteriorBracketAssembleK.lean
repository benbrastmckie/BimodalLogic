/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterPastK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConverseK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConversePastK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberDeepAnchorK

/-! # Depth-`k` exterior-bracket assembly (SLICE-KEYED and FIBER-KEYED)

The **bracket wrapper** over the delivered depth-`k` exterior-negation **clause** layer
. Each depth-`k+1` endpoint characteristic `qnf : NormalForm sig (k+2) 3` carries a
per-sub bit `qnf.2 σ` over its exterior-anchor-enriched subs `σ : NormalForm sig (k+1) 4`. The
future/past adjacent brackets conjoin, over the ORDER-ADMISSIBLE subs (`kvEFutAdmissible` /
`kvEPastAdmissible`, ExteriorNegationK.lean:86 / ExteriorNegationPastK.lean:134), the positive
local-existence clause `kvEFutPos`/`kvEPastPos` (352) when σ's exterior SLICE is qnf-marked
(`kvEFutSliceMarked`/`kvEPastSliceMarked` — some admissible slice-mate carries the bit) and the
complement clause `kvEExtNegFut`/`kvEExtNegPast` (352) when the slice is unmarked.

**Slice re-key (report 02 §3.3-3.4; Rabinovich Def 7.13 footprint
discipline).** The original per-σ keying (`if qnf.2 σ = true then …`) was structurally DEFECTIVE:
the clause family reads `σ.2` exclusively through the three exterior zone lists, so slice-equal
σ's receive syntactically EQUAL clauses (`kvE_futClause_sliceConstant` /
`kvE_pastClause_sliceConstant`); a slice pair split by the bit (machine witness: the refutation's
(σ′, τ) pair, `kvE_futPinned_of_end_zero_refuted`) then conjoined `kvEFutPos τ` AND its negation
— the honest bracket was UNSATISFIABLE. The slice key gives slice-mates the same clause, restoring
the paper's negation device (`¬F0 ∨ On`, chunk_0015:39-41: negation applies per SEGMENT bracket,
never per full type).

**Fiber re-key (report 04; Rabinovich Def 7.13 single-disjunct segment
discipline).** The bracket range is the FIBER-compatible admissible subs:
`kvE_{fut,past}Admissible σ && decide (nfkDropFresh σ = qnf.1)`. The slice-re-key depth-k
rewrite had silently WIDENED the range to all admissible σ, dropping the frozen k=2 template's
base/fiber conjunct (`kvE2FutMarked`'s `decide (nf0DropFresh σ.1 = qnf.1)`,
ExteriorBracket.lean:127/140) — the ⇐-side honesty obligation for off-fiber σ was then FALSE
(ℤ-doppelgänger countermodel, plan v2 Phase-5 BLOCKER record). Off-fiber σ are unrealizable at
the pinned anchors (the fiber-forcing kernel `nf_eval_nf_atom_layer` → `nf_eval_nf0_cons_factor`
→ `nf_eval_unique`, NfEFold.lean:634-641), so narrowing is lossless for every consumer; the
gate's ⇒-side refutes off-fiber σ internally via that kernel under a gate-derived atom-layer pin
(`ExteriorGateAssembleK.lean`). Off-fiber exclusion is NOT D1/D2's job.

This is the depth-`k` analog of the frozen k=2 brackets `kvE2ExtBracketFut`/`kvE2ExtBracketPast`
(ExteriorBracket.lean:364/377), one fold-layer deeper. (Phase-6 AUDIT flag: the frozen k=2
brackets keep the per-σ bit keying inside a `kvE2FutMarked`-filtered range; whether the k=2
marking pins enough of `σ.2` to escape the same defect is a recorded audit item.)

**Interface note:** the `_complete` lemmas (D3/D4) no longer thread the 354
converter residue `hreal`/`hsat` nor a per-σ `hneg`; the negative case consumes ONE carried
slice-honesty obligation per side (`hslice` — chain-fire truth at the anchor yields a marked
slice-mate; report 02 §3.4, discharged at m = 0 by `kvE_futSliceId_of_end_zero` + chain
destruction, plan v2 Phase 5). The `_sound` lemmas (D1/D2) weaken to SLICE-level exclusion; per-σ
exclusion for bit-false-but-slice-marked σ is recovered where consumed (the gate's `hexclExt`
discharge) via the carried `hexclSlice*` obligations, m=0-discharged by `kvE_futSliceUnique_zero`
+ the interior-style `hreal` (report 02 §3.4 last paragraph). -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (formulaConjList formula_conjList_iff formulaDisjList formula_disjList_iff)

/-! ## The Future slice-marking extraction interface -/

/-- Unpack/repack the Future slice marking (the extraction interface D1/D3 and the gate
    consume). Future twin of `kvE_pastSliceMarked_iff` (ExteriorPinnedConversePastK.lean);
    placed here (not in ExteriorPinnedConverseK) to keep the Phase-3 converse file read-only
    in Phase 3b. -/
theorem kvE_futSliceMarked_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (σ : NormalForm sig (k + 1) 4) :
    kvEFutSliceMarked qnf σ = true ↔
      ∃ σ' : NormalForm sig (k + 1) 4, kvEFutAdmissible σ' = true ∧
        kvEFutSliceEq σ' σ = true ∧ qnf.2 σ' = true := by
  rw [kvEFutSliceMarked, List.any_eq_true]
  constructor
  · rintro ⟨σ', -, h⟩
    rw [Bool.and_eq_true, Bool.and_eq_true] at h
    exact ⟨σ', h.1.1, h.1.2, h.2⟩
  · rintro ⟨σ', h1, h2, h3⟩
    exact ⟨σ', Finset.mem_toList.mpr (Finset.mem_univ σ'), by rw [h1, h2, h3]; rfl⟩

/-! ## The depth-`k` adjacent exterior brackets (Def 7.5 p.13, one fold deeper; SLICE-KEYED) -/

/-- **Future-side depth-`k` adjacent exterior bracket** (anchored at `t` over `(t, ∞)`;
    SLICE-KEYED): the conjunction over the ORDER-ADMISSIBLE subs
    `σ : NormalForm sig (k+1) 4` of the positive local-existence clause `kvEFutPos P σ` (352,
    Lemma 7.10 p.15) when σ's exterior slice is qnf-marked (`kvEFutSliceMarked` — some
    admissible slice-mate carries the bit) and of the complement clause `kvEExtNegFut P σ`
    (352) when the slice is unmarked. Slice-mates receive the SAME clause
    (`kvE_futClause_sliceConstant`), so the honest bracket is satisfiable — the per-σ-bit
    keying this replaces conjoined `F ∧ ¬F` on the refutation's (σ′, τ) slice pair. -/
noncomputable def kvEExtBracketFut {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (qnf : NormalForm sig (k + 2) 3) : Formula :=
  formulaConjList
    (((Finset.univ.toList (α := NormalForm sig (k + 1) 4)).filter
        (fun σ => kvEFutAdmissible σ && kvEDeepOnFiber qnf σ)).map
      fun σ =>
        if kvEFutSliceMarked qnf σ = true then kvEFutPos P σ else kvEExtNegFut P σ)

/-- **Past-side depth-`k` adjacent exterior bracket** (mirror, anchored at `x` over `(-∞, x)`;
    SLICE-KEYED): `Since`-navigated existence clause `kvEPastPos P σ` for
    slice-marked admissible σ (`kvEPastSliceMarked`), complement clause `kvEExtNegPast P σ`
    for slice-unmarked admissible σ. Depth-`k` analog of the frozen `kvE2ExtBracketPast`
    (ExteriorBracket.lean:377). -/
noncomputable def kvEExtBracketPast {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (qnf : NormalForm sig (k + 2) 3) : Formula :=
  formulaConjList
    (((Finset.univ.toList (α := NormalForm sig (k + 1) 4)).filter
        (fun σ => kvEPastAdmissible σ && kvEDeepOnFiber qnf σ)).map
      fun σ =>
        if kvEPastSliceMarked qnf σ = true then kvEPastPos P σ else kvEExtNegPast P σ)

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (future side, pure formula-level
    bridge — no pins). Depth-`k` analog of `kvE2_extBracketFut_iff` (ExteriorBracket.lean:389). -/
theorem kvE_extBracketFut_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (M : OrderedMonadicStructure sig) (P : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3) (t : M.carrier) :
    TemporalTruth M atomMap t (kvEExtBracketFut P qnf) ↔
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap t
          (if kvEFutSliceMarked qnf σ = true then kvEFutPos P σ else kvEExtNegFut P σ) := by
  rw [kvEExtBracketFut, formula_conjList_iff]
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
theorem kvE_extBracketPast_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (M : OrderedMonadicStructure sig) (P : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3) (x : M.carrier) :
    TemporalTruth M atomMap x (kvEExtBracketPast P qnf) ↔
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap x
          (if kvEPastSliceMarked qnf σ = true then kvEPastPos P σ else kvEExtNegPast P σ) := by
  rw [kvEExtBracketPast, formula_conjList_iff]
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

/-! ## Composed per-side soundness (D1/D2, SLICE-LEVEL) -/

/-- **D1 — Future-side bracket soundness** (SLICE-LEVEL): the bracket true
    at `t` kills EVERY slice-UNMARKED σ at every `x1 > t` — σ need not be assumed admissible,
    since a realizer forces admissibility (`kvE_futRealizer_admissible`, 352) and then
    `kvE_extNegFut_sound` (352) refutes it. Per-σ exclusion for bit-false-but-slice-marked σ
    is NOT derivable from the honest bracket (slice-mates share one clause); it is recovered
    where consumed via the carried `hexclSlice*` obligation, m=0-discharged by
    `kvE_futSliceUnique_zero` + `hreal` (report 02 §3.4 last paragraph). -/
theorem kvE_extBracketFut_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : TemporalTruth M atomMap t (kvEExtBracketFut P qnf)) :
    ∀ σ : NormalForm sig (k + 1) 4, kvEDeepOnFiber qnf σ = true →
      kvEFutSliceMarked qnf σ = false →
      ∀ x1 : M.carrier, t < x1 →
        ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hfib hbit x1 htx1 hnf
  have hadm : kvEFutAdmissible σ = true :=
    kvE_futRealizer_admissible M σ x1 w x t hxw hwt htx1 hnf
  have hneg : TemporalTruth M atomMap t (kvEExtNegFut P σ) := by
    have h := (kvE_extBracketFut_iff M P qnf t).mp hcl σ hadm hfib
    rwa [if_neg (by simp [hbit])] at h
  exact kvE_extNegFut_sound P M h_UZ h_SZ σ w x t hxw hwt hneg x1 htx1 hnf

/-- **D2 — Past-side bracket soundness** (SLICE-LEVEL): the bracket true at
    `x` kills every slice-UNMARKED σ at every `x1 < x`. Mirror of D1. -/
theorem kvE_extBracketPast_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : TemporalTruth M atomMap x (kvEExtBracketPast P qnf)) :
    ∀ σ : NormalForm sig (k + 1) 4, kvEDeepOnFiber qnf σ = true →
      kvEPastSliceMarked qnf σ = false →
      ∀ x1 : M.carrier, x1 < x →
        ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hfib hbit x1 hx1x hnf
  have hadm : kvEPastAdmissible σ = true :=
    kvE_pastRealizer_admissible M σ x1 w x t hxw hwt hx1x hnf
  have hneg : TemporalTruth M atomMap x (kvEExtNegPast P σ) := by
    have h := (kvE_extBracketPast_iff M P qnf x).mp hcl σ hadm hfib
    rwa [if_neg (by simp [hbit])] at h
  exact kvE_extNegPast_sound P M h_UZ h_SZ σ w x t hxw hwt hneg x1 hx1x hnf

/-! ## Composed per-side completeness (D3/D4 — `hreal`/`hsat`/`hneg` DROPPED)

The `_complete` lemmas re-establish the bracket at its anchor from TWO inputs per side:
realizers for admissible bit-true σ (`hpos`, supplied by the ambient fold at the gate), and
ONE slice-honesty obligation (`hslice`, report 02 §3.4): chain-fire truth at the anchor for an
admissible σ yields a MARKED slice-mate. The positive (slice-marked) case transfers the mate's
realizer through clause slice-constancy; the negative (slice-unmarked) case is `hslice`
contraposed. The 354 converter residue `hreal`/`hsat` and the per-σ `hneg` are NOT consumed —
the eliminated guarded `hbr*`-Sat shapes were machine-refuted
(`kvE_futPinned_of_end_zero_refuted`). `hslice` is discharged at m = 0 by
`kvE_futSliceId_of_end_zero` + chain destruction (plan v2 Phase 5). -/

/-- **D3 — Future-side bracket completeness** (SLICE-KEYED): realizers for
    the bit-true σ plus the Future slice-honesty obligation re-establish the bracket at `t`. -/
theorem kvE_extBracketFut_complete {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hpos : ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = true →
      ∃ x1 : M.carrier, t < x1 ∧
        NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hslice : ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true →
      kvEDeepOnFiber qnf σ = true →
      TemporalTruth M atomMap t (kvEFutPos P σ) →
      ∃ σ' : NormalForm sig (k + 1) 4, kvEFutAdmissible σ' = true ∧
        kvEFutSliceEq σ' σ = true ∧ qnf.2 σ' = true) :
    TemporalTruth M atomMap t (kvEExtBracketFut P qnf) := by
  refine (kvE_extBracketFut_iff M P qnf t).mpr fun σ hadm hfib => ?_
  cases hbit : kvEFutSliceMarked qnf σ with
  | true =>
    rw [if_pos rfl]
    obtain ⟨σ', hadm', hsl, hmark⟩ := (kvE_futSliceMarked_iff qnf σ).mp hbit
    rw [← (kvE_futClause_sliceConstant P σ' σ hadm' hadm hsl).1]
    obtain ⟨x1, htx1, hr⟩ := hpos σ' hadm' hmark
    exact kvE_futPos_of_realizer P M h_UZ h_SZ σ' w x t x1 hxw hwt htx1 hr
  | false =>
    rw [if_neg (by simp)]
    rw [kvEExtNegFut, temporal_truth_neg]
    intro hposT
    obtain ⟨σ', hadm', hsl, hmark⟩ := hslice σ hadm hfib hposT
    have hcontra : kvEFutSliceMarked qnf σ = true :=
      (kvE_futSliceMarked_iff qnf σ).mpr ⟨σ', hadm', hsl, hmark⟩
    rw [hbit] at hcontra
    exact Bool.noConfusion hcontra

/-- **D4 — Past-side bracket completeness** (SLICE-KEYED): mirror of D3 at
    the left anchor `x`; the positive case inlines the `kvE_futPos_of_realizer` by_contra
    route (no Past supply lemma is landed yet — Phase 4 mirrors it). -/
theorem kvE_extBracketPast_complete {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hpos : ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = true →
      ∃ x1 : M.carrier, x1 < x ∧
        NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hslice : ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true →
      kvEDeepOnFiber qnf σ = true →
      TemporalTruth M atomMap x (kvEPastPos P σ) →
      ∃ σ' : NormalForm sig (k + 1) 4, kvEPastAdmissible σ' = true ∧
        kvEPastSliceEq σ' σ = true ∧ qnf.2 σ' = true) :
    TemporalTruth M atomMap x (kvEExtBracketPast P qnf) := by
  refine (kvE_extBracketPast_iff M P qnf x).mpr fun σ hadm hfib => ?_
  cases hbit : kvEPastSliceMarked qnf σ with
  | true =>
    rw [if_pos rfl]
    obtain ⟨σ', hadm', hsl, hmark⟩ := (kvE_pastSliceMarked_iff qnf σ).mp hbit
    rw [← (kvE_pastClause_sliceConstant P σ' σ hadm' hadm hsl).1]
    obtain ⟨x1, hx1x, hr⟩ := hpos σ' hadm' hmark
    by_contra hno
    have hnegcl : TemporalTruth M atomMap x (kvEExtNegPast P σ') := by
      rw [kvEExtNegPast, temporal_truth_neg]; exact hno
    exact kvE_extNegPast_sound P M h_UZ h_SZ σ' w x t hxw hwt hnegcl x1 hx1x hr
  | false =>
    rw [if_neg (by simp)]
    rw [kvEExtNegPast, temporal_truth_neg]
    intro hposT
    obtain ⟨σ', hadm', hsl, hmark⟩ := hslice σ hadm hfib hposT
    have hcontra : kvEPastSliceMarked qnf σ = true :=
      (kvE_pastSliceMarked_iff qnf σ).mpr ⟨σ', hadm', hsl, hmark⟩
    rw [hbit] at hcontra
    exact Bool.noConfusion hcontra

end FormalSystem.Metalogic.WeakCanonical.Kamp

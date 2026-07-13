import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterPastK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK

/-! # Depth-`k` exterior-bracket assembly (task 349, v8 Phases 3-4)

The **bracket wrapper** over the delivered depth-`k` exterior-negation **clause** layer
(tasks 352/354). Each depth-`k+1` endpoint characteristic `qnf : NormalForm sig (k+2) 3` carries a
per-sub bit `qnf.2 σ` over its exterior-anchor-enriched subs `σ : NormalForm sig (k+1) 4`. The
future/past adjacent brackets conjoin, over the ORDER-ADMISSIBLE subs (`kvE_futAdmissible` /
`kvE_pastAdmissible`, ExteriorNegationK.lean:86 / ExteriorNegationPastK.lean:134 — the depth-`k`
faithful replacement for the frozen k=2 `kvE2_futMarked`), the positive local-existence clause
`kvE_futPos`/`kvE_pastPos` (352) when the bit is true and the complement clause
`kvE_extNegFut`/`kvE_extNegPast` (352) when the bit is false.

This is the depth-`k` analog of the frozen k=2 brackets `kvE2_extBracketFut`/`kvE2_extBracketPast`
(ExteriorBracket.lean:364/377) and mirrors their `_sound`/`_complete` proofs line-by-line
(:432/:456/:547/:583), one fold-layer deeper, consuming the delivered clause layer by name.

**Marking-shape note (plan G-b):** the k=2 bracket filters on `kvE2_futMarked qnf` (a qnf⇒σ
relation); the depth-`k` bracket filters on `kvE_futAdmissible σ` (a σ-only order predicate) and
uses `kvE_futRealizer_admissible` (ExteriorNegationK.lean:124) for the realizer⇒admissible step the
k=2 `_sound` proof performs with `kvE2_futMarked_of_realizer`.

**`hreal`/`hsat` DISCHARGED-interface note (plan G-c):** the `_complete` lemmas (Phase 4) thread the
`P : ExistProviders` provider channel and the carried `hreal`/`hsat` residue VERBATIM from the 354
converter signatures (ExteriorConverterK.lean:119 / ExteriorConverterPastK.lean:94). These are a
DISCHARGED interface, not debt: they are discharged one level up by the task-349 outer recursion via
the 354 bundle templates `kvE_futBundle_of_realizer` (ExteriorConverterK.lean:208) /
`kvE_pastBundle_of_realizer` (ExteriorConverterPastK.lean:177). No discharge happens here. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff)

/-! ## The depth-`k` adjacent exterior brackets (Def 7.5 p.13, one fold deeper) -/

/-- **Future-side depth-`k` adjacent exterior bracket** (anchored at `t` over `(t, ∞)`): the
    conjunction over the ORDER-ADMISSIBLE subs `σ : NormalForm sig (k+1) 4` of the positive
    local-existence clause `kvE_futPos P σ` (352, Lemma 7.10 p.15) when `qnf`'s bit is true and of
    the complement clause `kvE_extNegFut P σ` (352) when the bit is false. Depth-`k` analog of the
    frozen `kvE2_extBracketFut` (ExteriorBracket.lean:364). -/
noncomputable def kvE_extBracketFut {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (qnf : NormalForm sig (k + 2) 3) : Formula :=
  formula_conjList
    (((Finset.univ.toList (α := NormalForm sig (k + 1) 4)).filter
        (fun σ => kvE_futAdmissible σ)).map
      fun σ =>
        if qnf.2 σ = true then kvE_futPos P σ else kvE_extNegFut P σ)

/-- **Past-side depth-`k` adjacent exterior bracket** (mirror, anchored at `x` over `(-∞, x)`):
    `Since`-navigated existence clause `kvE_pastPos P σ` for bit-true admissible σ, complement
    clause `kvE_extNegPast P σ` for bit-false admissible σ. Depth-`k` analog of the frozen
    `kvE2_extBracketPast` (ExteriorBracket.lean:377). -/
noncomputable def kvE_extBracketPast {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (qnf : NormalForm sig (k + 2) 3) : Formula :=
  formula_conjList
    (((Finset.univ.toList (α := NormalForm sig (k + 1) 4)).filter
        (fun σ => kvE_pastAdmissible σ)).map
      fun σ =>
        if qnf.2 σ = true then kvE_pastPos P σ else kvE_extNegPast P σ)

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (future side, pure formula-level
    bridge — no pins). Depth-`k` analog of `kvE2_extBracketFut_iff` (ExteriorBracket.lean:389). -/
theorem kvE_extBracketFut_iff {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (M : OrderedMonadicStructure sig) (P : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3) (t : M.carrier) :
    temporal_truth M atomMap t (kvE_extBracketFut P qnf) ↔
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true →
        temporal_truth M atomMap t
          (if qnf.2 σ = true then kvE_futPos P σ else kvE_extNegFut P σ) := by
  rw [kvE_extBracketFut, formula_conjList_iff]
  constructor
  · intro h σ hm
    exact h _ (List.mem_map.mpr ⟨σ, List.mem_filter.mpr
      ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hm⟩, rfl⟩)
  · intro h f hf
    obtain ⟨σ, hσmem, rfl⟩ := List.mem_map.mp hf
    exact h σ (List.mem_filter.mp hσmem).2

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (past side). Depth-`k` analog of
    `kvE2_extBracketPast_iff` (ExteriorBracket.lean:408). -/
theorem kvE_extBracketPast_iff {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (M : OrderedMonadicStructure sig) (P : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3) (x : M.carrier) :
    temporal_truth M atomMap x (kvE_extBracketPast P qnf) ↔
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true →
        temporal_truth M atomMap x
          (if qnf.2 σ = true then kvE_pastPos P σ else kvE_extNegPast P σ) := by
  rw [kvE_extBracketPast, formula_conjList_iff]
  constructor
  · intro h σ hm
    exact h _ (List.mem_map.mpr ⟨σ, List.mem_filter.mpr
      ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hm⟩, rfl⟩)
  · intro h f hf
    obtain ⟨σ, hσmem, rfl⟩ := List.mem_map.mp hf
    exact h σ (List.mem_filter.mp hσmem).2

/-! ## Phase 3 — composed per-side soundness (D1/D2, CLEAN — no F2 residue) -/

/-- **D1 — Future-side bracket soundness** (depth-`k`, mirror of `kvE2_extBracketFut_sound`,
    ExteriorBracket.lean:432): the bracket true at `t` kills EVERY bit-false σ at every `x1 > t` —
    σ need not be assumed admissible, since a realizer forces admissibility
    (`kvE_futRealizer_admissible`, 352) and then `kvE_extNegFut_sound` (352) refutes it. CLEAN:
    the sound direction needs no `hreal`/`hsat`. -/
theorem kvE_extBracketFut_sound {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap t (kvE_extBracketFut P qnf)) :
    ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
      ∀ x1 : M.carrier, t < x1 →
        ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hbit x1 htx1 hnf
  have hadm : kvE_futAdmissible σ = true :=
    kvE_futRealizer_admissible M σ x1 w x t hxw hwt htx1 hnf
  have hneg : temporal_truth M atomMap t (kvE_extNegFut P σ) := by
    have h := (kvE_extBracketFut_iff M P qnf t).mp hcl σ hadm
    rwa [if_neg (by simp [hbit])] at h
  exact kvE_extNegFut_sound P M h_UZ h_SZ σ w x t hxw hwt hneg x1 htx1 hnf

/-- **D2 — Past-side bracket soundness** (depth-`k`, mirror of `kvE2_extBracketPast_sound`,
    ExteriorBracket.lean:456): the bracket true at `x` kills every bit-false σ at every `x1 < x`.
    CLEAN. -/
theorem kvE_extBracketPast_sound {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap x (kvE_extBracketPast P qnf)) :
    ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
      ∀ x1 : M.carrier, x1 < x →
        ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hbit x1 hx1x hnf
  have hadm : kvE_pastAdmissible σ = true :=
    kvE_pastRealizer_admissible M σ x1 w x t hxw hwt hx1x hnf
  have hneg : temporal_truth M atomMap x (kvE_extNegPast P σ) := by
    have h := (kvE_extBracketPast_iff M P qnf x).mp hcl σ hadm
    rwa [if_neg (by simp [hbit])] at h
  exact kvE_extNegPast_sound P M h_UZ h_SZ σ w x t hxw hwt hneg x1 hx1x hnf

/-! ## Phase 4 — composed per-side completeness (D3/D4, threads the DISCHARGED `hreal`/`hsat`)

The `_complete` lemmas re-establish the bracket at its anchor from per-σ exterior facts:
realizers for admissible bit-true σ (`hpos`), no-realizer for admissible bit-false σ (`hneg`),
routed through `kvE_extNegFut_sound` (bit-true contrapositive) and `kvE_extNegFut_complete`
(bit-false). The two extra hypotheses `hreal`/`hsat` are threaded VERBATIM from the 354 converter
signature (`kvE_extNegFut_complete`, ExteriorConverterK.lean:126-134) and fed straight to it — a
DISCHARGED interface, discharged one level up in Phase 6 via `kvE_futBundle_of_realizer`
(ExteriorConverterK.lean:208) / `kvE_pastBundle_of_realizer` (ExteriorConverterPastK.lean:177), NOT
debt and NOT discharged here. -/

/-- **D3 — Future-side bracket completeness** (depth-`k`, mirror of `kvE2_extBracketFut_complete`,
    ExteriorBracket.lean:547): per-σ exterior facts re-establish the bracket at `t`. Threads the
    carried `hreal`/`hsat` interface verbatim from `kvE_extNegFut_complete` (354). -/
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
    (hneg : ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, t < x1 →
        ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hreal : ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, t < x1 → ∀ s : NormalForm sig k 5, σ.2 s = true →
        ∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hsat : ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, t < x1 →
        temporal_truth M atomMap x1 (kvE_futEnd P σ) →
        ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
          (∃ v : M.carrier, nf_eval_nf M k 5
            (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
          σ.2 s = true) :
    temporal_truth M atomMap t (kvE_extBracketFut P qnf) := by
  refine (kvE_extBracketFut_iff M P qnf t).mpr fun σ hadm => ?_
  cases hbit : qnf.2 σ with
  | true =>
    rw [if_pos rfl]
    obtain ⟨x1, htx1, hr⟩ := hpos σ hadm hbit
    by_contra hno
    have hnegcl : temporal_truth M atomMap t (kvE_extNegFut P σ) := by
      rw [kvE_extNegFut, temporal_truth_neg]; exact hno
    exact kvE_extNegFut_sound P M h_UZ h_SZ σ w x t hxw hwt hnegcl x1 htx1 hr
  | false =>
    rw [if_neg (by simp)]
    exact kvE_extNegFut_complete P M h_UZ h_SZ σ w x t hxw hwt
      (hreal σ hadm hbit) (hsat σ hadm hbit) (hneg σ hadm hbit)

/-- **D4 — Past-side bracket completeness** (depth-`k`, mirror of `kvE2_extBracketPast_complete`,
    ExteriorBracket.lean:583): per-σ exterior facts re-establish the bracket at `x`. Threads the
    carried `hreal`/`hsat` interface verbatim from `kvE_extNegPast_complete` (354). -/
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
    (hneg : ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, x1 < x →
        ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hreal : ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, x1 < x → ∀ s : NormalForm sig k 5, σ.2 s = true →
        ∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hsat : ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, x1 < x →
        temporal_truth M atomMap x1 (kvE_pastEnd P σ) →
        ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
          (∃ v : M.carrier, nf_eval_nf M k 5
            (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
          σ.2 s = true) :
    temporal_truth M atomMap x (kvE_extBracketPast P qnf) := by
  refine (kvE_extBracketPast_iff M P qnf x).mpr fun σ hadm => ?_
  cases hbit : qnf.2 σ with
  | true =>
    rw [if_pos rfl]
    obtain ⟨x1, hx1x, hr⟩ := hpos σ hadm hbit
    by_contra hno
    have hnegcl : temporal_truth M atomMap x (kvE_extNegPast P σ) := by
      rw [kvE_extNegPast, temporal_truth_neg]; exact hno
    exact kvE_extNegPast_sound P M h_UZ h_SZ σ w x t hxw hwt hnegcl x1 hx1x hr
  | false =>
    rw [if_neg (by simp)]
    exact kvE_extNegPast_complete P M h_UZ h_SZ σ w x t hxw hwt
      (hreal σ hadm hbit) (hsat σ hadm hbit) (hneg σ hadm hbit)

end Bimodal.Metalogic.WeakCanonical.Kamp

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationPastK

/-! # Depth-`k` Past-side exterior-negation converter — the reverse `_complete`

The Past dual of `ExteriorConverterK.lean`: the reverse of the green `kvE_extNegPast_sound`
(`ExteriorNegationPastK.lean:539`). Assuming the positive local-existence form `kvE_pastPos` at
the left anchor `x`, we destruct the Cor 5.4 `Since` chain to an exterior endpoint `x1 < x` and
reconstruct `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`, contradicting the carried non-realization
hypothesis `hcl`.

**Branch B (mirrors the Future Phase-3 decision)**: the fiber-backward converse is carried as the
named saturation residue `hsat` (the depth-`k` `hexclExt` analog), and the arity-5 realization
bundle `hreal` is carried for the fiber-forward direction — both discharged one level up by the
outer recursion / exterior provider (F2 sidestep, report 03 pattern). The atom layer is
recovered via `kvE_pastAtom_of_bundle` (bundle route, NOT env-free saturation). Consumes the Past
chain destructor `kvE_pastChainDestructG` (`ExteriorNegationPastK.lean:353`) via `semantic_prior_SZ`
(last-occurrence). Purely additive NEW leaf module; no frozen file is touched. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff)

/-! ## Admissibility conjunct-2 reader (off-fiber falsity, Past)

Conjunct 2 of `kvE_pastAdmissible` (`ExteriorNegationPastK.lean:137`) is byte-identical to the
Future conjunct 2: every bit-true full-arity sub sits on `σ`'s atom fiber. -/

/-- **Past admissibility ⇒ fiber dichotomy**: under `kvE_pastAdmissible σ`, every full-arity sub
    either sits on `σ`'s atom fiber (`nfk_dropFresh s = σ.1`) or is prescribed false. -/
theorem kvE_pastAdmissible_fiber_dichotomy {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_pastAdmissible σ = true) :
    ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 ∨ σ.2 s = false := by
  have hadm' := hadm
  unfold kvE_pastAdmissible at hadm'
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hadm'
  obtain ⟨⟨⟨_, hB⟩, _⟩, _⟩ := hadm'
  intro s
  have hs := (List.all_eq_true.mp hB) s (Finset.mem_toList.mpr (Finset.mem_univ s))
  rw [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq] at hs
  rcases hs with ⟨h, -⟩ | h
  · exact Or.inl h
  · exact Or.inr (Bool.not_eq_true' _ |>.mp h)

/-- **On-fiber recording** (Past): under admissibility, a bit-true sub sits on `σ`'s atom fiber. -/
theorem kvE_pastAdmissible_onFiber {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_pastAdmissible σ = true)
    (s : NormalForm sig k 5) (hbit : σ.2 s = true) :
    nfk_dropFresh s = σ.1 := by
  rcases kvE_pastAdmissible_fiber_dichotomy σ hadm s with h | h
  · exact h
  · exact absurd hbit (by rw [h]; exact Bool.false_ne_true)

/-- **Off-fiber falsity** (Past): under admissibility, a sub off `σ`'s atom fiber is false. -/
theorem kvE_pastAdmissible_offFiber {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_pastAdmissible σ = true)
    (s : NormalForm sig k 5) (hne : nfk_dropFresh s ≠ σ.1) :
    σ.2 s = false := by
  rcases kvE_pastAdmissible_fiber_dichotomy σ hadm s with h | h
  · exact absurd h hne
  · exact h

/-! ## Atom-layer reconstruction from the carried realization bundle (Past)

Side-agnostic (identical to the Future `kvE_futAtom_of_bundle`): a single carried arity-5 realizer
`[v, x1, w, x, t]` of a bit-true fiber sub, dropped at the fresh index, IS `σ.1` at `[x1,w,x,t]`. -/

/-- **Atom layer via the bundle** (Past): given a bit-true fiber sub `s0` (`nfk_dropFresh s0 = σ.1`)
    and its carried realizer at `[v, x1, w, x, t]`, `σ`'s atom layer holds at `[x1, w, x, t]`. -/
theorem kvE_pastAtom_of_bundle {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig (k + 1) 4) (v x1 w x t : M.carrier)
    (s0 : NormalForm sig k 5) (hd0 : nfk_dropFresh s0 = σ.1)
    (hv : nf_eval_nf M k 5
      (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s0) :
    nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
  have hatom := nf_eval_nf_atom_layer M
    (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s0 hv
  have hfac := (nf_eval_nf0_cons_factor M
    (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) v s0.atom_assgn).mp hatom
  have hdrop : nf0_dropFresh s0.atom_assgn = σ.1 := hd0
  rw [hdrop] at hfac
  exact hfac.2.2

/-! ## The reverse converter `kvE_extNegPast_complete` (Past) -/

/-- **The Past exterior converter** (the REVERSE of `kvE_extNegPast_sound`): with the
    carried arity-5 realization bundle `hreal` (fiber-forward) and the carried exterior-anchor
    saturation residue `hsat` (fiber-backward, the depth-`k` `hexclExt` analog, discharged by the
    outer recursion / exterior provider — F2), if no exterior `x1 < x` realizes `σ` over
    `[x1, w, x, t]` then the complement clause holds at the left anchor `x`.

    **Guarded restatement**: `hreal`/`hsat` carry their
    consumption-site truth antecedents — the chain-fire truth `kvE_pastPos P σ` at `x`, the
    destructor-endpoint truth `kvE_pastEnd P σ` at `x1`, and the destructor's pinned walk facts
    `hgap` (uniform gap disjunction on `(x1, x)`) and `hocc` (per-item pinned occurrence in
    `(x1, x)`) — making the obligations true-as-stated. The chain destructor's facts are bound
    and threaded, no longer `_`-discarded. -/
theorem kvE_extNegPast_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t : M.carrier) (_hxw : x < w) (_hwt : w < t)
    (hreal : ∀ x1 : M.carrier, x1 < x →
      temporal_truth M atomMap x (kvE_pastPos P σ) →
      temporal_truth M atomMap x1 (kvE_pastEnd P σ) →
      (∀ r : M.carrier, x1 < r → r < x → temporal_truth M atomMap r (kvE_pastGapD P σ)) →
      (∀ a ∈ kvE_fiberZoneList σ kvE_pastGapZone, ∃ r : M.carrier,
        x1 < r ∧ r < x ∧ temporal_truth M atomMap r (P.existF 4 (renameNF rot5Fwd rot5Bwd a))) →
      ∀ s : NormalForm sig k 5, σ.2 s = true →
      ∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hsat : ∀ x1 : M.carrier, x1 < x →
      temporal_truth M atomMap x (kvE_pastPos P σ) →
      temporal_truth M atomMap x1 (kvE_pastEnd P σ) →
      (∀ r : M.carrier, x1 < r → r < x → temporal_truth M atomMap r (kvE_pastGapD P σ)) →
      (∀ a ∈ kvE_fiberZoneList σ kvE_pastGapZone, ∃ r : M.carrier,
        x1 < r ∧ r < x ∧ temporal_truth M atomMap r (P.existF 4 (renameNF rot5Fwd rot5Bwd a))) →
      ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
        (∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
        σ.2 s = true)
    (hcl : ∀ x1 : M.carrier, x1 < x →
      ¬ nf_eval_nf M (k + 1) 4
        (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap x (kvE_extNegPast P σ) := by
  rw [kvE_extNegPast, temporal_truth_neg]
  intro hpos
  have hpos0 := hpos
  by_cases hadm : kvE_pastAdmissible σ = true
  · rw [kvE_pastPos, if_pos hadm, formula_disjList_iff] at hpos
    obtain ⟨φ, hφmem, hφ⟩ := hpos
    obtain ⟨l, hlmem, rfl⟩ := List.mem_map.mp hφmem
    have hlperm : l.Perm (kvE_fiberZoneList σ kvE_pastGapZone) :=
      List.mem_permutations.mp hlmem
    -- item ⇒ gap guard
    have himp : ∀ a ∈ l, ∀ r : M.carrier,
        temporal_truth M atomMap r (P.existF 4 (renameNF rot5Fwd rot5Bwd a)) →
        temporal_truth M atomMap r (kvE_pastGapD P σ) := by
      intro a ha r hr
      have hamem : a ∈ kvE_fiberZoneList σ kvE_pastGapZone := hlperm.subset ha
      rw [kvE_pastGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
      rw [P.correct 4 (renameNF rot5Fwd rot5Bwd a) M h_UZ h_SZ r] at hr
      obtain ⟨env, hev⟩ := hr
      exact ⟨a, hamem, env, (kvE_anchorBridge M env r a).mp hev⟩
    -- destruct the Cor 5.4 Since chain (endpoint x1 < x; binding `hgap`/`hocc`)
    obtain ⟨x1, hx1x, hend, hgap, hocc⟩ :=
      kvE_pastChainDestructG M atomMap (fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s))
        (kvE_pastEnd P σ) (kvE_pastGapD P σ) l x himp hφ
    -- the `l`-free form of the per-item pinned occurrences (via the permutation)
    have hoccZ : ∀ a ∈ kvE_fiberZoneList σ kvE_pastGapZone, ∃ r : M.carrier,
        x1 < r ∧ r < x ∧ temporal_truth M atomMap r (P.existF 4 (renameNF rot5Fwd rot5Bwd a)) :=
      fun a ha => hocc a (hlperm.mem_iff.mpr ha)
    -- a reached endpoint forces the self-zone content nonempty ⇒ a bit-true sub exists
    have hend0 := hend
    rw [kvE_pastEnd, formula_conjList_iff] at hend0
    have hself := hend0 (kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_pastSelfZone)) (by simp)
    rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1] at hself
    obtain ⟨s0, hs0mem, _env0, _hs0ev⟩ := hself
    have hbit0 : σ.2 s0 = true := ((kvE_fiberZoneList_mem σ kvE_pastSelfZone s0).mp hs0mem).1
    have hd0 : nfk_dropFresh s0 = σ.1 := kvE_pastAdmissible_onFiber σ hadm s0 hbit0
    -- atom layer at `[x1,w,x,t]` via the carried bundle on that bit-true sub
    obtain ⟨v0, hv0⟩ := hreal x1 hx1x hpos0 hend hgap hoccZ s0 hbit0
    have hA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
      kvE_pastAtom_of_bundle M σ v0 x1 w x t s0 hd0 hv0
    -- fold biconditional: forward via `hreal`, backward via the carried saturation residue
    have hfib : ∀ sub : NormalForm sig k 5, nfk_dropFresh sub = σ.1 →
        ((∃ y : M.carrier, nf_eval_nf M k 5
          (Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) sub) ↔
          σ.2 sub = true) := by
      intro sub hd
      constructor
      · intro hex; exact hsat x1 hx1x hpos0 hend hgap hoccZ sub hd hex
      · intro hbit; exact hreal x1 hx1x hpos0 hend hgap hoccZ sub hbit
    -- reassemble the realizer of `σ` at the reconstructed exterior anchor
    have hσ : nf_eval_nf M (k + 1) 4
        (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ :=
      (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mpr
        ⟨⟨hA, hfib⟩, fun sub hne => kvE_pastAdmissible_offFiber σ hadm sub hne⟩
    exact hcl x1 hx1x hσ
  · rw [kvE_pastPos, if_neg hadm] at hpos
    exact hpos

/-! ## Phase 5 — bundle-shape reconciliation (Past discharge template)

Past dual of `kvE_futBundle_of_realizer`: the Option-B at-anchor determinacy reader proving the
carried `hreal`/`hsat` obligations of `kvE_extNegPast_complete` are dischargeable from a genuine
exterior realizer. Side-agnostic (the realizer env `[x1,w,x,t]` and the fold read are direction-
independent). -/

/-- **Discharge template** (Past): from an actual realizer of `σ` at the reconstructed anchor
    `[x1, w, x, t]`, BOTH carried obligations of `kvE_extNegPast_complete` hold. Pure read of
    `nf_eval_nfk_iff_efold`; the interface the outer recursion supplies at a genuine
    exterior anchor. -/
theorem kvE_pastBundle_of_realizer {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig (k + 1) 4) (x1 w x t : M.carrier)
    (hσ : nf_eval_nf M (k + 1) 4
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∀ s : NormalForm sig k 5, σ.2 s = true →
        ∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) ∧
    (∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
        (∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
        σ.2 s = true) := by
  obtain ⟨⟨_hA, hfib⟩, hoff⟩ :=
    (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mp hσ
  refine ⟨fun s hbit => ?_, fun s hd hex => (hfib s hd).mp hex⟩
  by_cases hd : nfk_dropFresh s = σ.1
  · exact (hfib s hd).mpr hbit
  · rw [hoff s hd] at hbit; exact absurd hbit (by decide)

end Bimodal.Metalogic.WeakCanonical.Kamp

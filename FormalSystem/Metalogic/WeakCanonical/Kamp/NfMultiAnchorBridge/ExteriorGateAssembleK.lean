/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketAssembleK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorAmbientDeepAnchorK

/-! # General-`k` `hexclExt` exterior-adjacency discharge

The general-`k` mirror of the landed k=2 discharge `bracketEndChar_kvE2Ext_correct_two_prior_frag`
(`ExteriorBracket.lean:1069`), one fold-layer deeper. It composes the general-`k` interior carrier
`bracketEndCharKv` at depth `(k+2)` with the two adjacent exterior brackets
`kvEExtBracketPast` / `kvEExtBracketFut` (`ExteriorBracketAssembleK.lean`) via `enrichEndpoints`
(the degenerate Rabinovich Lemma 7.6 p.14 adjacency at the shared free anchors `x, t`), discharging
the `hexclExt` obligation that the interior gate `bracketEndChar_kv_step_sound`
(`InteriorGateGeneralK.lean:1043`) carries outward.

This is a purely additive leaf. Every composition input is landed sorry-free:
- `bracketEndChar_kv_step_sound` / `bracketEndChar_kv_step_complete` (`InteriorGateGeneralK.lean`);
- `kvE_extBracketPast_sound` / `kvE_extBracketFut_sound` (D1/D2, AssembleK) — the `hexclExt`
  discharge kernel;
- `kvE_extBracketPast_complete` / `kvE_extBracketFut_complete` (D3/D4, AssembleK) — the ⇐
  re-establishment;
- `kvE_futBundle_of_realizer` / `kvE_pastBundle_of_realizer` (`ExteriorConverter{,Past}K.lean`) —
  the `hreal`/`hsat` discharge templates;
- `VVecEA2.enrichEndpoints` / `_holds` (`ExteriorBracket.lean:623/632`) — reused verbatim (generic
  over `VVecEA2`).

## Deliverables

1. `bracketEndCharKvExt` — the general-`k` enriched composed gate (def);
2. `bracketEndChar_kvExt_holds_iff` — the anchor-semantics bridge (one-line reuse of
   `enrichEndpoints_holds`);
3. `bracketEndChar_kvExt_correct_prior` — the DoD `hexclExt` discharge lemma: the enriched-gate
   biconditional carrying only `P`, `hcharK`, `Pbr`, `h_UZ`, `h_SZ`, `hreal`, `hexcl` (+ order
   bits), with `hexclExt` discharged internally.

**Scope fence (this module only)**: KampPrior.lean:351 wiring, aggregator import threading, and the
site-certificate reshape belong to the KampPrior provider instantiation, which also discharges the
threaded `hreal`/`hexcl`. No interior-gate mathematics. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

open private k1v_reconstruct_nf3 from
  FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

/-! ## Gate-level atom-layer pin

The fiber re-key (ExteriorBracketAssembleK, Phase 3c) narrows the bracket range to
fiber-compatible admissible σ; the gate's ⇒-side `hexclExt` discharge must therefore refute
off-fiber σ INTERNALLY. The kernel (`nf_eval_nf_atom_layer` → `nf_eval_nf0_cons_factor` →
`nf_eval_unique`, the `offForce` recipe of `nf_eval_nfk_iff_efold`, NfEFold.lean) shows an
off-fiber σ is unrealizable at the pinned anchors — GIVEN the depth-0 atom-layer pin
`henv : NfEvalNf M 0 3 [w,x,t] qnf.1`. This helper derives `henv` for the callback's
ARBITRARY interior witness `w` from inventory already in scope (`hInt` + the callback's
`hptW`), replicating `bracketEndChar_kv_step_sound`'s own atom-layer block
(`InteriorGateGeneralK.lean:1076-1113`) with the extracted witness replaced by the callback's.
Depth-`k` analog of the k=2 gate pin `kvE2_extGate_henv` (`ExteriorBracket.lean:721`). -/

private theorem kvExt_gate_henv {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (hInt : (bracketEndCharKv atomMap h_surj charF (k + 2) qnf).holds M atomMap x t)
    (w : M.carrier) (hxw : x < w) (hwt : w < t)
    (hptW : (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (k + 1)) qnf.1
      (igFoldBit qnf)).EvalAt M atomMap w) :
    NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 := by
  have hxt : x < t := hxw.trans hwt
  rw [bracketEndChar_kv_succ_holds_iff atomMap h_surj charF qnf M x t] at hInt
  obtain ⟨_hgate, lL, _hlL, lR, _hlR, hveah⟩ := hInt
  obtain ⟨hepL, hepR, -⟩ := hveah
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (nfDepth0CharFormula atomMap h_surj χ) ↔
        NfEvalNf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  have hxT : TemporalTruth M atomMap x
      (nfDepth0CharFormula atomMap h_surj (nfXProj3 qnf.1)) := by
    have h := hepL
    simp only [igMkDisjunct, igEpL, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have htT : TemporalTruth M atomMap t
      (nfDepth0CharFormula atomMap h_surj (nfTProj3 qnf.1)) := by
    have h := hepR
    simp only [igMkDisjunct, igEpR, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : TemporalTruth M atomMap w
      (nfDepth0CharFormula atomMap h_surj (nfYProj qnf.1)) := by
    have h := hptW
    simp only [igPtW, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ List.mem_cons_self
  exact k1v_reconstruct_nf3 M qnf.1 w x t
    ((hcharB _ w).mp hyW) ((hcharB _ x).mp hxT) ((hcharB _ t).mp htT)
    (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
    (iff_of_true hwt h_yt)
    (iff_of_true hxw h_xy)
    (iff_of_true hxt h_xt)
    (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
    (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))

/-! ## Gate-formula guard strengthening

The σ-INDEPENDENT ambient EF-closure guard `kvEAmbientDeepAnchor qnf`
(`ExteriorAmbientDeepAnchorK.lean`) is conjoined into the enriched gate as a model-independent
endpoint formula, so the gate's `.holds` CARRIES the guard: the ⇒-reconstruction reads
`kvEAmbientDeepAnchor qnf = true` off `holds` (discharging the guard antecedents of the
restated ⇒-side rows 5/6/10-13), and the ⇐ re-establishes the guard conjunct from realization
via `kvE_ambientDeepAnchor_of_realized`. This is the "matching gate-formula strengthening" the
Phase-1 consumption-site map located here. -/

/-- The σ-independent ambient guard as a model-independent endpoint formula: `Formula.top`
    (valid everywhere) when `kvEAmbientDeepAnchor qnf = true`, `Formula.bot` (unsatisfiable)
    otherwise. Conjoined at the LEFT anchor of the enriched gate. Never unfolds the guard —
    routes through the byte-stable `kvEAmbientDeepAnchor` bit. -/
noncomputable def kvEAmbientGuardForm {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) : Formula :=
  bif kvEAmbientDeepAnchor qnf then Formula.top else Formula.bot

/-- `kvEAmbientGuardForm qnf` is true at any point iff the ambient guard holds — a
    model-independent `⊤`/`⊥` by the decidable guard bit. The bridge the gate strengthening and
    its ⇒/⇐ reconstruction route through. -/
theorem kvE_ambientGuardForm_truth {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (z : M.carrier)
    (qnf : NormalForm sig (k + 2) 3) :
    TemporalTruth M atomMap z (kvEAmbientGuardForm qnf) ↔
      kvEAmbientDeepAnchor qnf = true := by
  unfold kvEAmbientGuardForm
  cases h : kvEAmbientDeepAnchor qnf with
  | true => simp only [cond_true]; exact iff_of_true (temporal_truth_top M atomMap z) trivial
  | false => simp [TemporalTruth]

/-! ## The general-`k` enriched composed gate (degenerate Lemma 7.6 p.14 at the anchors `x, t`) -/

/-- **The general-`k` enriched composed gate** (Def 7.5 p.13 + degenerate Lemma 7.6 p.14;
    ambient-guard strengthened): the general-`k` interior carrier `bracketEndCharKv … (k+2)` with
    the past-side adjacent bracket `kvEExtBracketPast Pbr` conjoined at the LEFT anchor `x` and the
    future-side adjacent bracket `kvEExtBracketFut Pbr` conjoined at the RIGHT anchor `t`, via
    `enrichEndpoints`; then the σ-independent ambient guard `kvEAmbientGuardForm qnf` conjoined at
    the LEFT anchor (with `Formula.top` at the right, an inert enrichment) so `.holds` carries
    `kvEAmbientDeepAnchor qnf = true`. General-`k` mirror of `bracketEndCharKvE2Ext`
    (`ExteriorBracket.lean:661`), one fold deeper. -/
noncomputable def bracketEndCharKvExt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pbr : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 2) :=
  fun qnf =>
    ((bracketEndCharKv atomMap h_surj charF (k + 2) qnf).enrichEndpoints
      (kvEExtBracketPast Pbr qnf)
      (kvEExtBracketFut Pbr qnf)).enrichEndpoints
      (kvEAmbientGuardForm qnf) Formula.top

/-- **Anchor-semantics bridge for the general-`k` enriched gate** (the degenerate Lemma 7.6
    conjunction, exposed): the enriched gate holds at `(x, t)` iff the interior gate holds AND the
    past bracket is true at `x` AND the future bracket is true at `t`. One-line reuse of
    `VVecEA2.enrichEndpoints_holds`. Mirror of `bracketEndChar_kvE2Ext_holds_iff`
    (`ExteriorBracket.lean:674`). -/
theorem bracketEndChar_kvExt_holds_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndCharKvExt atomMap h_surj charF Pbr qnf).holds M atomMap x t ↔
      ((bracketEndCharKv atomMap h_surj charF (k + 2) qnf).holds M atomMap x t ∧
       TemporalTruth M atomMap x (kvEExtBracketPast Pbr qnf) ∧
       TemporalTruth M atomMap t (kvEExtBracketFut Pbr qnf) ∧
       kvEAmbientDeepAnchor qnf = true) := by
  change (((bracketEndCharKv atomMap h_surj charF (k + 2) qnf).enrichEndpoints
        (kvEExtBracketPast Pbr qnf) (kvEExtBracketFut Pbr qnf)).enrichEndpoints
        (kvEAmbientGuardForm qnf) Formula.top).holds M atomMap x t ↔ _
  constructor
  · intro h
    obtain ⟨hInner, hg, -⟩ := (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mp h
    obtain ⟨hbase, hpast, hfut⟩ := (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mp hInner
    exact ⟨hbase, hpast, hfut, (kvE_ambientGuardForm_truth M atomMap x qnf).mp hg⟩
  · rintro ⟨hbase, hpast, hfut, hguard⟩
    refine (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mpr
      ⟨(VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mpr ⟨hbase, hpast, hfut⟩,
       (kvE_ambientGuardForm_truth M atomMap x qnf).mpr hguard,
       temporal_truth_top M atomMap t⟩

/-! ## The discharge theorem (the DoD `hexclExt` discharge) -/

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvExt_correct_prior` composes the enriched exterior gate and discharges
-- the exterior-marked residue internally, so the whole interior provider inventory is
-- elaborated in one term and the default 200000-heartbeat budget is not enough.
/-- **General-`k` enriched gate correctness with `hexclExt` discharged internally**
    (Rabinovich Lemma 7.6 adjacency p.14, one fold deeper than the k=2
    `bracketEndChar_kvE2Ext_correct_two_prior_frag`, `ExteriorBracket.lean:1069`). The enriched
    composed gate `bracketEndCharKvExt` satisfies the gate biconditional under only the interior
    provider inventory (`P`/`hcharK`/`h_UZ`/`h_SZ`/`hreal`/`hexcl`, order bits) plus the bracket
    provider `Pbr`: the exterior-marked residue `hexclExt` of `bracketEndChar_kv_step_sound`
    (`InteriorGateGeneralK.lean:1043`) is NOT an input obligation. It is discharged internally by
    the
    guard split `¬(x ≤ x1 ∧ x1 ≤ t) → x1 < x ∨ t < x1`, sending each strictly-exterior bit-false
    realizer to its side where `kvE_extBracketPast_sound` / `kvE_extBracketFut_sound` (D1/D2) refute
    it.

    ⇐ (completeness): an honest realization re-establishes all three conjuncts — the interior gate
    via `bracketEndChar_kv_step_complete`, the two brackets via `kvE_extBracket{Past,Fut}_complete`.
    The positive witnesses are positioned strictly exterior directly from
    `kvE_{fut,past}Admissible`'s
    zone marking (`kvE2_sep_z{Fut,Past}X/T3`) applied to the realized qnf's arity-4 order layer (the
    flagged escalation site — resolved).

    SLICE-KEYED interface: the brackets are keyed by
    `kvE_{fut,past}SliceMarked` (report 02 §3.3 — the per-σ-bit keying made the honest bracket
    unsatisfiable, `kvE_futPinned_of_end_zero_refuted`). The four eliminated `hbr*` binders are
    replaced by two carried obligations per side — `hslice{Past,Fut}` (⇐-side slice honesty,
    ambient-guarded, fed to D3/D4) and `hexclSlice{Past,Fut}` (⇒-side per-σ exclusion residue for
    bit-false-but-slice-marked σ, `igPtW`-guarded, completing the internal `hexclExt` discharge
    alongside the slice-level D1/D2) — threaded outward ∀-`w` exactly as the interior
    `hreal`/`hexcl` and discharged at m = 0 via `kvE_{fut,past}SliceId_of_end_zero` /
    `kvE_{fut,past}SliceUnique_zero` + `hreal` (plan v2 Phase 5).

    Consumed by the KampPrior provider instantiation at `KampPrior.lean:351` (which discharges the
    remaining
    provider obligations `hreal`/`hexcl` and the slice-keyed exterior interface). -/
theorem bracketEndChar_kvExt_correct_prior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (P : ExistProviders sig atomMap (k + 1))
    (hcharK : charF (k + 1) = fun χ => P.existF 0 χ)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier)
    (hreal : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- SLICE-KEYED exterior interface (the slice re-key; replaces the four eliminated `hbr*`
    -- binders — the guarded `hbr*Sat` shapes were machine-refuted,
    -- `kvE_futPinned_of_end_zero_refuted`). Two carried obligations per side:
    --
    -- (1) `hslicePast`/`hsliceFut` (⇐-side slice honesty, report 02 §3.4 shape +
    --     FIBER-guarded per the fiber re-key / report 04: the antecedent
    --     `nfkDropFresh σ = qnf.1` matches the re-keyed bracket range — off-fiber σ carry no
    --     honesty obligation, killing the ℤ-doppelgänger countermodel; it is exactly the
    --     `hfib` input of `kvE_{fut,past}SliceId_of_end_zero`): chain-fire truth at the anchor
    --     for a fiber-compatible admissible σ yields a MARKED slice-mate. Fed to
    --     `kvE_extBracket{Past,Fut}_complete` (D3/D4). Discharged at m = 0 by
    --     `kvE_{fut,past}SliceId_of_end_zero` + chain destruction (plan v2 Phase 5).
    --
    -- (2) `hexclSlicePast`/`hexclSliceFut` (⇒-side per-σ exclusion residue, `hexcl`-shaped,
    --     `igPtW`-guarded): a bit-false-but-slice-MARKED admissible σ has no strictly-exterior
    --     realizer. Needed because the slice-keyed D1/D2 exclude only slice-UNMARKED σ, while
    --     the interior gate's `hexclExt` input is per-σ; report 02 §3.4's recovery
    --     (`kvE_futSliceUnique_zero` + `hreal`) is m=0-only and the gate binds general `k`, so
    --     the recovery's conclusion is carried and m=0-discharged by exactly that recipe
    --     (plan v2 Phase 5). H4: the refutation witness σ′ is pinned-unrealizable, so it
    --     satisfies this obligation vacuously — unlike the eliminated `hbr*`-Sat shapes.
    (hslicePast : ∀ w : M.carrier, x < w → w < t →
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap x (kvEPastPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvEPastAdmissible σ' = true ∧
          kvEPastSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hsliceFut : ∀ w : M.carrier, x < w → w < t →
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap t (kvEFutPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvEFutAdmissible σ' = true ∧
          kvEFutSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hexclSlicePast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
        kvEPastSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, x1 < x →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclSliceFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
        kvEFutSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, t < x1 →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- DEEP-ANCHOR residue (`kvEDeepOnFiber`, rows 12-13): the ⇒-side exclusion for ON-ROW but
    -- guard-FALSE bit-false σ. With the deep-anchored bracket range
    -- (`kvE_extBracket{Fut,Past}` re-key), such σ carry NO clause, so the slice-level
    -- D1/D2 cannot refute them; the obligation is carried outward like rows 10-11.
    -- m = 0-VACUOUS: at fiber depth 1 the guard IS the row check (`kvE_deepOnFiber_zero`),
    -- so on-row + guard-false is contradictory. General-m discharge (under an
    -- honest ambient, a pinned realizer forces the guard via `kvE_deepOnFiber_of_realized`,
    -- contradicting guard-false).
    (hexclDeepPast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
        nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, x1 < x →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
        nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, t < x1 →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvExt atomMap h_surj charF Pbr qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  constructor
  · -- ⇒: destructure the degenerate Lemma 7.6 conjunction, then feed the interior soundness half
    -- with `hexclExt` built from the per-side bracket soundness.
    intro hExt
    obtain ⟨hInt, hPastBr, hFutBr, hGuard⟩ :=
      (bracketEndChar_kvExt_holds_iff atomMap h_surj charF Pbr qnf M x t).mp hExt
    refine bracketEndChar_kv_step_sound atomMap h_surj charF qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t (hreal hGuard) (hexcl hGuard) ?_ hInt
    -- The former `hexclExt` obligation, by fiber trichotomy (the fiber re-key, report 04 +
    -- the deep anchor): OFF-fiber σ are unrealizable at the pinned anchors
    -- (fiber-forcing kernel under the gate-derived atom-layer pin `kvExt_gate_henv`);
    -- on-fiber GUARD-TRUE slice-UNMARKED σ discharged by the deep-anchored slice-level
    -- D1/D2; on-fiber guard-true bit-false-but-slice-MARKED σ by the carried `hexclSlice*`
    -- residue (VERBATIM Phase-3b binders); on-fiber GUARD-FALSE σ by the carried
    -- `hexclDeep*` residue (deep-anchor rows 12-13 — such σ carry no bracket clause).
    intro w hxw hwt hptW σ hbit x1 hguard hnf
    by_cases hfib : nfkDropFresh σ = qnf.1
    · rcases not_and_or.mp hguard with hx | ht
      · by_cases hdeep : kvEDeepOnFiber qnf σ = true
        · cases hsm : kvEPastSliceMarked qnf σ with
          | false =>
            exact kvE_extBracketPast_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hPastBr σ hdeep
              hsm x1 (not_le.mp hx) hnf
          | true =>
            have hadm : kvEPastAdmissible σ = true :=
              kvE_pastRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp hx) hnf
            exact hexclSlicePast hGuard w hxw hwt hptW σ hadm hbit hsm x1 (not_le.mp hx) hnf
        · rw [Bool.not_eq_true] at hdeep
          have hadm : kvEPastAdmissible σ = true :=
            kvE_pastRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp hx) hnf
          exact hexclDeepPast hGuard w hxw hwt hptW σ hadm hbit hfib hdeep x1 (not_le.mp hx) hnf
      · by_cases hdeep : kvEDeepOnFiber qnf σ = true
        · cases hsm : kvEFutSliceMarked qnf σ with
          | false =>
            exact kvE_extBracketFut_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hFutBr σ hdeep
              hsm x1 (not_le.mp ht) hnf
          | true =>
            have hadm : kvEFutAdmissible σ = true :=
              kvE_futRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp ht) hnf
            exact hexclSliceFut hGuard w hxw hwt hptW σ hadm hbit hsm x1 (not_le.mp ht) hnf
        · rw [Bool.not_eq_true] at hdeep
          have hadm : kvEFutAdmissible σ = true :=
            kvE_futRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp ht) hnf
          exact hexclDeepFut hGuard w hxw hwt hptW σ hadm hbit hfib hdeep x1 (not_le.mp ht) hnf
    · -- Off-fiber: a realizer at the pinned anchors would force σ onto the fiber
      -- (`offForce` recipe, NfEFold.lean) — contradiction with `hfib`.
      have henv : NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
        kvExt_gate_henv atomMap h_surj charF qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t hInt
          w hxw hwt hptW
      have hatom := nf_eval_nf_atom_layer M _ σ hnf
      have hfac :=
        (nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1
          σ.atomAssgn).mp hatom
      exact hfib (nf_eval_unique M 0 3 _ _ _ hfac.2.2 henv)
  · -- ⇐: an honest realization re-establishes all three conjuncts.
    rintro ⟨w, h⟩
    have hxw : x < w := by
      have := (h.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_xy
      exact this
    have hwt : w < t := by
      have := (h.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_yt
      exact this
    refine (bracketEndChar_kvExt_holds_iff atomMap h_surj charF Pbr qnf M x t).mpr
      ⟨bracketEndChar_kv_step_complete atomMap h_surj charF P hcharK qnf h_xy h_yt M h_UZ h_SZ
        x t ⟨w, h⟩, ?_, ?_, kvE_ambientDeepAnchor_of_realized M _ qnf h⟩
    · -- Past bracket at `x`.
      refine kvE_extBracketPast_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `x1 < x`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0ZoneSpec σ.1 = kvE2SepZPastX3 := by
          have hh := hadm
          rw [kvEPastAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1.1
        have hb1 : (nf0ZoneSpec σ.1 ⟨1, by omega⟩).1 = true := by rw [hzone]; rfl
        have h1 := hx1.1 (.order 0 (Fin.succ ⟨1, by omega⟩) (Fin.succ_ne_zero ⟨1, by omega⟩).symm)
        simp only [AtomEval, Fin.cons] at h1
        exact ⟨x1, h1.mpr hb1, hx1⟩
      · -- hslice: the carried Past slice-honesty obligation.
        exact hslicePast w hxw hwt h
    · -- Future bracket at `t`.
      refine kvE_extBracketFut_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `t < x1`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0ZoneSpec σ.1 = kvE2SepZFutT3 := by
          have hh := hadm
          rw [kvEFutAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1.1
        have hb2 : (nf0ZoneSpec σ.1 ⟨2, by omega⟩).2 = true := by rw [hzone]; rfl
        have h2 := hx1.1 (.order (Fin.succ ⟨2, by omega⟩) 0 (Fin.succ_ne_zero ⟨2, by omega⟩))
        simp only [AtomEval, Fin.cons] at h2
        exact ⟨x1, h2.mpr hb2, hx1⟩
      · -- hslice: the carried Future slice-honesty obligation.
        exact hsliceFut w hxw hwt h

/-! ## De-folded exterior gate (additive siblings)

The frozen exterior carrier `bracketEndCharKvExt` (`:154`) and its correctness
`bracketEndChar_kvExt_correct_prior` (`:229`) are consumed OUT OF SCOPE
(`EndIntervalConsumerK.lean:248`, `kampPrior_site_rungK_gate_match`), so Phase 6 adds SIBLING
`*Fib` analogs routed through the de-folded interior `bracketEndCharKvFib` (Option B; frozen
`bracketEndCharKv` left byte-identical) instead of mutating them. Each analog is a byte-parallel
clone with the four carrier-specific references swapped to their Phase-1..5 de-folded counterparts:
`bracketEndCharKv{,_step_sound,_step_complete,_succ_holds_iff}` → `bracketEndCharKvFib{…}`,
`igPtW`/`igMkDisjunct`/`igEpL`/`igEpR`/`igFoldBit` → `igPtWFib`/`igMkDisjunctFib`/`igEpLFib`/
`igEpRFib`/`igFoldBitFib`, and the arity-1 char provider `charF` → the arity-4 `charFib`. The
arity-1 provider bundle `P`/`hcharK` (+ `h_UZ`/`h_SZ`) that the folded `step_complete` consumed is
replaced by the render-gated arity-4 char seam `hcharFib` (there is no arity-4 `interiorGate_hck`);
it is threaded outward exactly as `hreal`/`hexcl`. The two adjacent exterior brackets
(`kvE_extBracket{Past,Fut}`) are keyed on `σ:NF (k+1) 4` and are carrier-INDEPENDENT, so reused
verbatim. -/

/-- **De-folded enriched composed gate** (additive sibling of
    `bracketEndCharKvExt`, `:154`): the SIBLING de-folded interior carrier
    `bracketEndCharKvFib … (k+2)` enriched with the same two adjacent brackets and the ambient
    guard, via `enrichEndpoints`. -/
noncomputable def bracketEndCharKvExtFib {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 2) :=
  fun qnf =>
    ((bracketEndCharKvFib atomMap h_surj charFib (k + 2) qnf).enrichEndpoints
      (kvEExtBracketPast Pbr qnf)
      (kvEExtBracketFut Pbr qnf)).enrichEndpoints
      (kvEAmbientGuardForm qnf) Formula.top

/-- **Anchor-semantics bridge for the de-folded enriched gate** (additive sibling of
    `bracketEndChar_kvExt_holds_iff`, `:171`). One-line reuse of `VVecEA2.enrichEndpoints_holds`. -/
theorem bracketEndChar_kvExtFib_holds_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndCharKvExtFib atomMap h_surj charFib Pbr qnf).holds M atomMap x t ↔
      ((bracketEndCharKvFib atomMap h_surj charFib (k + 2) qnf).holds M atomMap x t ∧
       TemporalTruth M atomMap x (kvEExtBracketPast Pbr qnf) ∧
       TemporalTruth M atomMap t (kvEExtBracketFut Pbr qnf) ∧
       kvEAmbientDeepAnchor qnf = true) := by
  change (((bracketEndCharKvFib atomMap h_surj charFib (k + 2) qnf).enrichEndpoints
        (kvEExtBracketPast Pbr qnf) (kvEExtBracketFut Pbr qnf)).enrichEndpoints
        (kvEAmbientGuardForm qnf) Formula.top).holds M atomMap x t ↔ _
  constructor
  · intro h
    obtain ⟨hInner, hg, -⟩ := (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mp h
    obtain ⟨hbase, hpast, hfut⟩ := (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mp hInner
    exact ⟨hbase, hpast, hfut, (kvE_ambientGuardForm_truth M atomMap x qnf).mp hg⟩
  · rintro ⟨hbase, hpast, hfut, hguard⟩
    refine (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mpr
      ⟨(VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mpr ⟨hbase, hpast, hfut⟩,
       (kvE_ambientGuardForm_truth M atomMap x qnf).mpr hguard,
       temporal_truth_top M atomMap t⟩

/-- **De-folded gate-level atom-layer pin** (additive sibling of
    `kvExt_gate_henv`, `:61`): derives the depth-0 atom-layer pin `NfEvalNf M 0 3 [w,x,t] qnf.1`
    for the callback's arbitrary interior witness `w` from the SIBLING carrier's `.holds` via
    `bracketEndChar_kvFib_succ_holds_iff` (Phase 2) and the de-folded endpoint/witness predicates.
    Verbatim clone of the Phase-5 `bracketEndChar_kvFib_step_sound` reconstruction block. -/
private theorem kvExtFib_gate_henv {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (hInt : (bracketEndCharKvFib atomMap h_surj charFib (k + 2) qnf).holds M atomMap x t)
    (w : M.carrier) (hxw : x < w) (hwt : w < t)
    (hptW : (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
      (igFoldBitFib qnf)).EvalAt M atomMap w) :
    NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 := by
  have hxt : x < t := hxw.trans hwt
  rw [bracketEndChar_kvFib_succ_holds_iff atomMap h_surj charFib qnf M x t] at hInt
  obtain ⟨_hgate, lL, _hlL, lR, _hlR, hveah⟩ := hInt
  obtain ⟨hepL, hepR, -⟩ := hveah
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (nfDepth0CharFormula atomMap h_surj χ) ↔
        NfEvalNf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  have hxT : TemporalTruth M atomMap x
      (nfDepth0CharFormula atomMap h_surj (nfXProj3 qnf.1)) := by
    have h := hepL
    simp only [igMkDisjunctFib, igEpLFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have htT : TemporalTruth M atomMap t
      (nfDepth0CharFormula atomMap h_surj (nfTProj3 qnf.1)) := by
    have h := hepR
    simp only [igMkDisjunctFib, igEpRFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : TemporalTruth M atomMap w
      (nfDepth0CharFormula atomMap h_surj (nfYProj qnf.1)) := by
    have h := hptW
    simp only [igPtWFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ List.mem_cons_self
  exact k1v_reconstruct_nf3 M qnf.1 w x t
    ((hcharB _ w).mp hyW) ((hcharB _ x).mp hxT) ((hcharB _ t).mp htT)
    (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
    (iff_of_true hwt h_yt)
    (iff_of_true hxw h_xy)
    (iff_of_true hxt h_xt)
    (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
    (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvExtFib_correct_prior` is the byte-parallel de-folded clone of the
-- certificate above, routed through the fiber carrier; it needs the same raised budget.
/-- **De-folded enriched gate correctness** (additive sibling of
    `bracketEndChar_kvExt_correct_prior`, `:229`). Byte-parallel clone routed through the SIBLING
    de-folded interior carrier `bracketEndCharKvFib` (via `bracketEndChar_kvFib_step_sound`
    (Phase 5) / `bracketEndChar_kvFib_step_complete` (Phase 4) / `kvExtFib_gate_henv`), with the
    `hreal`/`hexcl`/`hexclSlice*`/`hexclDeep*` provider binders re-keyed onto the non-projecting
    fiber gate `igPtWFib … (charFib (k+1)) qnf.1 (igFoldBitFib qnf)`. The folded arity-1 provider
    bundle `P`/`hcharK` (+ `h_UZ`/`h_SZ`) that the folded `step_complete` consumed is replaced by
    the render-gated arity-4 char seam `hcharFib` threaded outward (there is no arity-4
    `interiorGate_hck`); `h_UZ`/`h_SZ` are retained for the carrier-independent exterior brackets.
    The `hexclExt` residue is discharged internally exactly as the folded original (fiber
    trichotomy + `kvE_extBracket{Past,Fut}_sound`). -/
theorem bracketEndChar_kvExtFib_correct_prior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier)
    (hcharFib : ∀ (w : M.carrier),
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        TemporalTruth M atomMap u (charFib (k + 1) σ) ↔
          NfEvalNf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
      TemporalTruth M atomMap x1 (charFib (k + 1) τ) →
      NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (hreal : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      (igEpLFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap x →
      (igEpRFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap t →
      (∀ (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
        TemporalTruth M atomMap x1 (charFib (k + 1) τ) →
        NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZPastX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZXW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZWT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZFutT) →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- SLICE-KEYED exterior interface: binder types
    -- mirrored verbatim from the folded `bracketEndChar_kvExt_correct_prior`, `igPtW`→`igPtWFib`.
    (hslicePast : ∀ w : M.carrier, x < w → w < t →
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap x (kvEPastPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvEPastAdmissible σ' = true ∧
          kvEPastSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hsliceFut : ∀ w : M.carrier, x < w → w < t →
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap t (kvEFutPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvEFutAdmissible σ' = true ∧
          kvEFutSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hexclSlicePast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
        kvEPastSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, x1 < x →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclSliceFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
        kvEFutSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, t < x1 →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepPast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
        nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, x1 < x →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
        nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, t < x1 →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvExtFib atomMap h_surj charFib Pbr qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  constructor
  · -- ⇒: destructure the degenerate Lemma 7.6 conjunction, then feed the de-folded soundness half
    -- with `hexclExt` built from the per-side bracket soundness.
    intro hExt
    obtain ⟨hInt, hPastBr, hFutBr, hGuard⟩ :=
      (bracketEndChar_kvExtFib_holds_iff atomMap h_surj charFib Pbr qnf M x t).mp hExt
    refine bracketEndChar_kvFib_step_sound atomMap h_surj charFib qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hcharFibSoundP (hreal hGuard) (hexcl hGuard) ?_ hInt
    -- The former `hexclExt` obligation, by fiber trichotomy (the fiber re-key, report 04 +
    -- the deep anchor): OFF-fiber σ are unrealizable at the pinned anchors
    -- (fiber-forcing kernel under the gate-derived atom-layer pin `kvExtFib_gate_henv`);
    -- on-fiber GUARD-TRUE slice-UNMARKED σ discharged by the deep-anchored slice-level
    -- D1/D2; on-fiber guard-true bit-false-but-slice-MARKED σ by the carried `hexclSlice*`
    -- residue (VERBATIM Phase-3b binders); on-fiber GUARD-FALSE σ by the carried
    -- `hexclDeep*` residue (deep-anchor rows 12-13 — such σ carry no bracket clause).
    intro w hxw hwt hptW σ hbit x1 hguard hnf
    by_cases hfib : nfkDropFresh σ = qnf.1
    · rcases not_and_or.mp hguard with hx | ht
      · by_cases hdeep : kvEDeepOnFiber qnf σ = true
        · cases hsm : kvEPastSliceMarked qnf σ with
          | false =>
            exact kvE_extBracketPast_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hPastBr σ hdeep
              hsm x1 (not_le.mp hx) hnf
          | true =>
            have hadm : kvEPastAdmissible σ = true :=
              kvE_pastRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp hx) hnf
            exact hexclSlicePast hGuard w hxw hwt hptW σ hadm hbit hsm x1 (not_le.mp hx) hnf
        · rw [Bool.not_eq_true] at hdeep
          have hadm : kvEPastAdmissible σ = true :=
            kvE_pastRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp hx) hnf
          exact hexclDeepPast hGuard w hxw hwt hptW σ hadm hbit hfib hdeep x1 (not_le.mp hx) hnf
      · by_cases hdeep : kvEDeepOnFiber qnf σ = true
        · cases hsm : kvEFutSliceMarked qnf σ with
          | false =>
            exact kvE_extBracketFut_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hFutBr σ hdeep
              hsm x1 (not_le.mp ht) hnf
          | true =>
            have hadm : kvEFutAdmissible σ = true :=
              kvE_futRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp ht) hnf
            exact hexclSliceFut hGuard w hxw hwt hptW σ hadm hbit hsm x1 (not_le.mp ht) hnf
        · rw [Bool.not_eq_true] at hdeep
          have hadm : kvEFutAdmissible σ = true :=
            kvE_futRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp ht) hnf
          exact hexclDeepFut hGuard w hxw hwt hptW σ hadm hbit hfib hdeep x1 (not_le.mp ht) hnf
    · -- Off-fiber: a realizer at the pinned anchors would force σ onto the fiber
      -- (`offForce` recipe, NfEFold.lean) — contradiction with `hfib`.
      have henv : NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
        kvExtFib_gate_henv atomMap h_surj charFib qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t hInt
          w hxw hwt hptW
      have hatom := nf_eval_nf_atom_layer M _ σ hnf
      have hfac :=
        (nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1
          σ.atomAssgn).mp hatom
      exact hfib (nf_eval_unique M 0 3 _ _ _ hfac.2.2 henv)
  · -- ⇐: an honest realization re-establishes all three conjuncts.
    rintro ⟨w, h⟩
    have hxw : x < w := by
      have := (h.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_xy
      exact this
    have hwt : w < t := by
      have := (h.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_yt
      exact this
    refine (bracketEndChar_kvExtFib_holds_iff atomMap h_surj charFib Pbr qnf M x t).mpr
      ⟨bracketEndChar_kvFib_step_complete atomMap h_surj charFib qnf h_xy h_yt M x t hcharFib
        ⟨w, h⟩, ?_, ?_, kvE_ambientDeepAnchor_of_realized M _ qnf h⟩
    · -- Past bracket at `x`.
      refine kvE_extBracketPast_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `x1 < x`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0ZoneSpec σ.1 = kvE2SepZPastX3 := by
          have hh := hadm
          rw [kvEPastAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1.1
        have hb1 : (nf0ZoneSpec σ.1 ⟨1, by omega⟩).1 = true := by rw [hzone]; rfl
        have h1 := hx1.1 (.order 0 (Fin.succ ⟨1, by omega⟩) (Fin.succ_ne_zero ⟨1, by omega⟩).symm)
        simp only [AtomEval, Fin.cons] at h1
        exact ⟨x1, h1.mpr hb1, hx1⟩
      · -- hslice: the carried Past slice-honesty obligation.
        exact hslicePast w hxw hwt h
    · -- Future bracket at `t`.
      refine kvE_extBracketFut_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `t < x1`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0ZoneSpec σ.1 = kvE2SepZFutT3 := by
          have hh := hadm
          rw [kvEFutAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1.1
        have hb2 : (nf0ZoneSpec σ.1 ⟨2, by omega⟩).2 = true := by rw [hzone]; rfl
        have h2 := hx1.1 (.order (Fin.succ ⟨2, by omega⟩) 0 (Fin.succ_ne_zero ⟨2, by omega⟩))
        simp only [AtomEval, Fin.cons] at h2
        exact ⟨x1, h2.mpr hb2, hx1⟩
      · -- hslice: the carried Future slice-honesty obligation.
        exact hsliceFut w hxw hwt h

end FormalSystem.Metalogic.WeakCanonical.Kamp

import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketAssembleK

/-! # General-`k` `hexclExt` exterior-adjacency discharge (task 356)

The general-`k` mirror of the landed k=2 discharge `bracketEndChar_kvE2Ext_correct_two_prior_frag`
(`ExteriorBracket.lean:1069`), one fold-layer deeper. It composes the general-`k` interior carrier
`bracketEndChar_kv` at depth `(k+2)` with the two adjacent exterior brackets
`kvE_extBracketPast` / `kvE_extBracketFut` (`ExteriorBracketAssembleK.lean`) via `enrichEndpoints`
(the degenerate Rabinovich Lemma 7.6 p.14 adjacency at the shared free anchors `x, t`), discharging
the `hexclExt` obligation that task 355's interior gate `bracketEndChar_kv_step_sound`
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

1. `bracketEndChar_kvExt` — the general-`k` enriched composed gate (def);
2. `bracketEndChar_kvExt_holds_iff` — the anchor-semantics bridge (one-line reuse of
   `enrichEndpoints_holds`);
3. `bracketEndChar_kvExt_correct_prior` — the DoD `hexclExt` discharge lemma: the enriched-gate
   biconditional carrying only `P`, `hcharK`, `Pbr`, `h_UZ`, `h_SZ`, `hreal`, `hexcl` (+ order
   bits), with `hexclExt` discharged internally.

**Scope fence (task 356 only)**: KampPrior.lean:351 wiring, aggregator import threading, and the
site-certificate reshape are task 357. `hreal`/`hexcl` remain threaded (discharged by the KampPrior
provider instantiation). No interior-gate mathematics (task 355). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

open private k1v_reconstruct_nf3 from
  Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

/-! ## Gate-level atom-layer pin (task 360 Phase 3c, report 04 Probe P2)

The fiber re-key (ExteriorBracketAssembleK, Phase 3c) narrows the bracket range to
fiber-compatible admissible σ; the gate's ⇒-side `hexclExt` discharge must therefore refute
off-fiber σ INTERNALLY. The kernel (`nf_eval_nf_atom_layer` → `nf_eval_nf0_cons_factor` →
`nf_eval_unique`, the `offForce` recipe of `nf_eval_nfk_iff_efold`, NfEFold.lean) shows an
off-fiber σ is unrealizable at the pinned anchors — GIVEN the depth-0 atom-layer pin
`henv : nf_eval_nf M 0 3 [w,x,t] qnf.1`. This helper derives `henv` for the callback's
ARBITRARY interior witness `w` from inventory already in scope (`hInt` + the callback's
`hptW`), replicating `bracketEndChar_kv_step_sound`'s own atom-layer block
(`InteriorGateGeneralK.lean:1076-1113`) with the extracted witness replaced by the callback's.
Depth-`k` analog of the k=2 gate pin `kvE2_extGate_henv` (`ExteriorBracket.lean:721`). -/

private theorem kvExt_gate_henv {sig : MonadicSignature} {k : Nat}
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
    (hInt : (bracketEndChar_kv atomMap h_surj charF (k + 2) qnf).holds M atomMap x t)
    (w : M.carrier) (hxw : x < w) (hwt : w < t)
    (hptW : (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1
      (igFoldBit qnf)).eval_at M atomMap w) :
    nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 := by
  have hxt : x < t := hxw.trans hwt
  rw [bracketEndChar_kv_succ_holds_iff atomMap h_surj charF qnf M x t] at hInt
  obtain ⟨_hgate, lL, _hlL, lR, _hlR, hveah⟩ := hInt
  obtain ⟨hepL, hepR, -⟩ := hveah
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
        nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  have hxT : temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_x_proj3 qnf.1)) := by
    have h := hepL
    simp only [igMkDisjunct, igEpL, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have htT : temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_t_proj3 qnf.1)) := by
    have h := hepR
    simp only [igMkDisjunct, igEpR, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : temporal_truth M atomMap w
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj qnf.1)) := by
    have h := hptW
    simp only [igPtW, TemporalPred.eval_at] at h
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

/-! ## The general-`k` enriched composed gate (degenerate Lemma 7.6 p.14 at the anchors `x, t`) -/

/-- **The general-`k` enriched composed gate** (task 356; Def 7.5 p.13 + degenerate Lemma 7.6 p.14):
    the general-`k` interior carrier `bracketEndChar_kv … (k+2)` with the past-side adjacent bracket
    `kvE_extBracketPast Pbr` conjoined at the LEFT anchor `x` and the future-side adjacent bracket
    `kvE_extBracketFut Pbr` conjoined at the RIGHT anchor `t`, via `enrichEndpoints`. General-`k`
    mirror of `bracketEndChar_kvE2Ext` (`ExteriorBracket.lean:661`), one fold deeper. -/
noncomputable def bracketEndChar_kvExt {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pbr : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 2) :=
  fun qnf =>
    (bracketEndChar_kv atomMap h_surj charF (k + 2) qnf).enrichEndpoints
      (kvE_extBracketPast Pbr qnf)
      (kvE_extBracketFut Pbr qnf)

/-- **Anchor-semantics bridge for the general-`k` enriched gate** (the degenerate Lemma 7.6
    conjunction, exposed): the enriched gate holds at `(x, t)` iff the interior gate holds AND the
    past bracket is true at `x` AND the future bracket is true at `t`. One-line reuse of
    `VVecEA2.enrichEndpoints_holds`. Mirror of `bracketEndChar_kvE2Ext_holds_iff`
    (`ExteriorBracket.lean:674`). -/
theorem bracketEndChar_kvExt_holds_iff {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_kvExt atomMap h_surj charF Pbr qnf).holds M atomMap x t ↔
      ((bracketEndChar_kv atomMap h_surj charF (k + 2) qnf).holds M atomMap x t ∧
       temporal_truth M atomMap x (kvE_extBracketPast Pbr qnf) ∧
       temporal_truth M atomMap t (kvE_extBracketFut Pbr qnf)) :=
  VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t

/-! ## The discharge theorem (task 356 — the DoD `hexclExt` discharge) -/

set_option maxHeartbeats 1600000 in
/-- **General-`k` enriched gate correctness with `hexclExt` discharged internally** (task 356;
    Rabinovich Lemma 7.6 adjacency p.14, one fold deeper than the k=2
    `bracketEndChar_kvE2Ext_correct_two_prior_frag`, `ExteriorBracket.lean:1069`). The enriched
    composed gate `bracketEndChar_kvExt` satisfies the gate biconditional under only the interior
    provider inventory (`P`/`hcharK`/`h_UZ`/`h_SZ`/`hreal`/`hexcl`, order bits) plus the bracket
    provider `Pbr`: the exterior-marked residue `hexclExt` of `bracketEndChar_kv_step_sound`
    (`InteriorGateGeneralK.lean:1043`) is NOT an input obligation. It is discharged internally by the
    guard split `¬(x ≤ x1 ∧ x1 ≤ t) → x1 < x ∨ t < x1`, sending each strictly-exterior bit-false
    realizer to its side where `kvE_extBracketPast_sound` / `kvE_extBracketFut_sound` (D1/D2) refute
    it.

    ⇐ (completeness): an honest realization re-establishes all three conjuncts — the interior gate
    via `bracketEndChar_kv_step_complete`, the two brackets via `kvE_extBracket{Past,Fut}_complete`.
    The positive witnesses are positioned strictly exterior directly from `kvE_{fut,past}Admissible`'s
    zone marking (`kvE2_sep_z{Fut,Past}X/T3`) applied to the realized qnf's arity-4 order layer (the
    flagged escalation site — resolved).

    SLICE-KEYED interface (task 360 Phase 3b): the brackets are keyed by
    `kvE_{fut,past}SliceMarked` (report 02 §3.3 — the per-σ-bit keying made the honest bracket
    unsatisfiable, `kvE_futPinned_of_end_zero_refuted`). The four eliminated `hbr*` binders are
    replaced by two carried obligations per side — `hslice{Past,Fut}` (⇐-side slice honesty,
    ambient-guarded, fed to D3/D4) and `hexclSlice{Past,Fut}` (⇒-side per-σ exclusion residue for
    bit-false-but-slice-marked σ, `igPtW`-guarded, completing the internal `hexclExt` discharge
    alongside the slice-level D1/D2) — threaded outward ∀-`w` exactly as the interior
    `hreal`/`hexcl` and discharged at m = 0 via `kvE_{fut,past}SliceId_of_end_zero` /
    `kvE_{fut,past}SliceUnique_zero` + `hreal` (plan v2 Phase 5).

    Consumed by task 357 at `KampPrior.lean:351` (which additionally discharges the remaining
    provider obligations `hreal`/`hexcl` and the slice-keyed exterior interface). -/
theorem bracketEndChar_kvExt_correct_prior {sig : MonadicSignature} {k : Nat}
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
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- SLICE-KEYED exterior interface (task 360 Phase 3b; replaces the four eliminated `hbr*`
    -- binders — the guarded `hbr*Sat` shapes were machine-refuted,
    -- `kvE_futPinned_of_end_zero_refuted`). Two carried obligations per side:
    --
    -- (1) `hslicePast`/`hsliceFut` (⇐-side slice honesty, report 02 §3.4 shape +
    --     FIBER-guarded, task 360 Phase 3c / report 04: the antecedent
    --     `nfk_dropFresh σ = qnf.1` matches the re-keyed bracket range — off-fiber σ carry no
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
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true →
        nfk_dropFresh σ = qnf.1 →
        temporal_truth M atomMap x (kvE_pastPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ' = true ∧
          kvE_pastSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hsliceFut : ∀ w : M.carrier, x < w → w < t →
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true →
        nfk_dropFresh σ = qnf.1 →
        temporal_truth M atomMap t (kvE_futPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvE_futAdmissible σ' = true ∧
          kvE_futSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hexclSlicePast : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
        kvE_pastSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, x1 < x →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclSliceFut : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
        kvE_futSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, t < x1 →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kvExt atomMap h_surj charF Pbr qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  constructor
  · -- ⇒: destructure the degenerate Lemma 7.6 conjunction, then feed the interior soundness half
    -- with `hexclExt` built from the per-side bracket soundness.
    intro hExt
    obtain ⟨hInt, hPastBr, hFutBr⟩ :=
      (bracketEndChar_kvExt_holds_iff atomMap h_surj charF Pbr qnf M x t).mp hExt
    refine bracketEndChar_kv_step_sound atomMap h_surj charF qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hreal hexcl ?_ hInt
    -- The former `hexclExt` obligation, by fiber dichotomy (task 360 Phase 3c, report 04):
    -- OFF-fiber σ are unrealizable at the pinned anchors (fiber-forcing kernel under the
    -- gate-derived atom-layer pin `kvExt_gate_henv`); in-fiber slice-UNMARKED σ discharged
    -- by the slice-level D1/D2; in-fiber bit-false-but-slice-MARKED σ by the carried
    -- `hexclSlice*` residue (VERBATIM Phase-3b binders — see the binder docs).
    intro w hxw hwt hptW σ hbit x1 hguard hnf
    by_cases hfib : nfk_dropFresh σ = qnf.1
    · rcases not_and_or.mp hguard with hx | ht
      · cases hsm : kvE_pastSliceMarked qnf σ with
        | false =>
          exact kvE_extBracketPast_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hPastBr σ hfib hsm
            x1 (not_le.mp hx) hnf
        | true =>
          have hadm : kvE_pastAdmissible σ = true :=
            kvE_pastRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp hx) hnf
          exact hexclSlicePast w hxw hwt hptW σ hadm hbit hsm x1 (not_le.mp hx) hnf
      · cases hsm : kvE_futSliceMarked qnf σ with
        | false =>
          exact kvE_extBracketFut_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hFutBr σ hfib hsm
            x1 (not_le.mp ht) hnf
        | true =>
          have hadm : kvE_futAdmissible σ = true :=
            kvE_futRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp ht) hnf
          exact hexclSliceFut w hxw hwt hptW σ hadm hbit hsm x1 (not_le.mp ht) hnf
    · -- Off-fiber: a realizer at the pinned anchors would force σ onto the fiber
      -- (`offForce` recipe, NfEFold.lean) — contradiction with `hfib`.
      have henv : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
        kvExt_gate_henv atomMap h_surj charF qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t hInt
          w hxw hwt hptW
      have hatom := nf_eval_nf_atom_layer M _ σ hnf
      have hfac :=
        (nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1
          σ.atom_assgn).mp hatom
      exact hfib (nf_eval_unique M 0 3 _ _ _ hfac.2.2 henv)
  · -- ⇐: an honest realization re-establishes all three conjuncts.
    rintro ⟨w, h⟩
    have hxw : x < w := by
      have := (h.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_xy
      simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ] using this
    have hwt : w < t := by
      have := (h.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_yt
      simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ] using this
    refine (bracketEndChar_kvExt_holds_iff atomMap h_surj charF Pbr qnf M x t).mpr
      ⟨bracketEndChar_kv_step_complete atomMap h_surj charF P hcharK qnf h_xy h_yt M h_UZ h_SZ
        x t ⟨w, h⟩, ?_, ?_⟩
    · -- Past bracket at `x`.
      refine kvE_extBracketPast_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `x1 < x`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zPastX3 := by
          have hh := hadm
          rw [kvE_pastAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1.1
        have hb1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).1 = true := by rw [hzone]; rfl
        have h1 := hx1.1 (.order 0 (Fin.succ ⟨1, by omega⟩) (Fin.succ_ne_zero ⟨1, by omega⟩).symm)
        simp only [atom_eval, Fin.cons] at h1
        exact ⟨x1, h1.mpr hb1, hx1⟩
      · -- hslice: the carried Past slice-honesty obligation (task 360 Phase 3b).
        exact hslicePast w hxw hwt h
    · -- Future bracket at `t`.
      refine kvE_extBracketFut_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `t < x1`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zFutT3 := by
          have hh := hadm
          rw [kvE_futAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1.1
        have hb2 : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).2 = true := by rw [hzone]; rfl
        have h2 := hx1.1 (.order (Fin.succ ⟨2, by omega⟩) 0 (Fin.succ_ne_zero ⟨2, by omega⟩))
        simp only [atom_eval, Fin.cons] at h2
        exact ⟨x1, h2.mpr hb2, hx1⟩
      · -- hslice: the carried Future slice-honesty obligation (task 360 Phase 3b).
        exact hsliceFut w hxw hwt h

end Bimodal.Metalogic.WeakCanonical.Kamp

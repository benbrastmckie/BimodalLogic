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
    flagged escalation site — resolved). The general-`k` bracket-`_complete` carries the arity-5
    realization interface `hbr*Real`/`hbr*Sat` (unlike the k=2 template, whose `_complete` took the
    derivable zone pins `henv`/`hbelow`); these are threaded outward ∀-`w` exactly as the interior
    `hreal`/`hexcl`, discharged one level up by the task-357 provider instantiation via
    `kvE_{fut,past}Bundle_of_realizer`. See the Phase-4 deviation note in the task-356 plan.

    Consumed by task 357 at `KampPrior.lean:351` (which additionally discharges the remaining
    provider obligations `hreal`/`hexcl` and the exterior bracket interface `hbr*`). -/
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
    -- Exterior bracket realization interface (⇐-only), threaded outward exactly as the interior
    -- `hreal`/`hexcl`: the carried arity-5 realization bundle (`hbr*Real`) and exterior-anchor
    -- saturation residue (`hbr*Sat`) of the general-`k` `kvE_extBracket{Past,Fut}_complete`
    -- (`ExteriorBracketAssembleK.lean:168/210`). These are a DISCHARGED interface, discharged one
    -- level up (task 357 provider instantiation) via `kvE_{fut,past}Bundle_of_realizer` when the
    -- outer recursion produces a genuine exterior realizer — NOT internal debt (no `sorry`, no
    -- vacuous def). See the Phase-4 deviation note in the task-356 plan.
    (hbrPastReal : ∀ w : M.carrier, x < w → w < t →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
        ∀ x1 : M.carrier, x1 < x → ∀ s : NormalForm sig k 5, σ.2 s = true →
          ∃ v : M.carrier, nf_eval_nf M k 5
            (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hbrPastSat : ∀ w : M.carrier, x < w → w < t →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
        ∀ x1 : M.carrier, x1 < x →
          temporal_truth M atomMap x1 (kvE_pastEnd Pbr σ) →
          ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
            (∃ v : M.carrier, nf_eval_nf M k 5
              (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
            σ.2 s = true)
    (hbrFutReal : ∀ w : M.carrier, x < w → w < t →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
        ∀ x1 : M.carrier, t < x1 → ∀ s : NormalForm sig k 5, σ.2 s = true →
          ∃ v : M.carrier, nf_eval_nf M k 5
            (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hbrFutSat : ∀ w : M.carrier, x < w → w < t →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
        ∀ x1 : M.carrier, t < x1 →
          temporal_truth M atomMap x1 (kvE_futEnd Pbr σ) →
          ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
            (∃ v : M.carrier, nf_eval_nf M k 5
              (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
            σ.2 s = true) :
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
    -- The former `hexclExt` obligation, now discharged internally.
    intro w hxw hwt _hptW σ hbit x1 hguard hnf
    rcases not_and_or.mp hguard with hx | ht
    · exact kvE_extBracketPast_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hPastBr σ hbit x1
        (not_le.mp hx) hnf
    · exact kvE_extBracketFut_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hFutBr σ hbit x1
        (not_le.mp ht) hnf
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
      refine kvE_extBracketPast_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_ ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `x1 < x`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zPastX3 := by
          have hh := hadm
          rw [kvE_pastAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1
        have hb1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).1 = true := by rw [hzone]; rfl
        have h1 := hx1.1 (.order 0 (Fin.succ ⟨1, by omega⟩) (Fin.succ_ne_zero ⟨1, by omega⟩).symm)
        simp only [atom_eval, Fin.cons] at h1
        exact ⟨x1, h1.mpr hb1, hx1⟩
      · -- hneg: an exterior realizer of an unmarked σ contradicts the qnf fold.
        intro σ _hadm hbit x1 _hx1x hr
        have := (h.2 σ).mp ⟨x1, hr⟩
        exact absurd (hbit ▸ this) Bool.false_ne_true
      · -- hreal: threaded exterior realization bundle (discharged by task 357).
        exact hbrPastReal w hxw hwt
      · -- hsat: threaded exterior saturation residue (discharged by task 357).
        exact hbrPastSat w hxw hwt
    · -- Future bracket at `t`.
      refine kvE_extBracketFut_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_ ?_ ?_
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
      · -- hneg
        intro σ _hadm hbit x1 _htx1 hr
        have := (h.2 σ).mp ⟨x1, hr⟩
        exact absurd (hbit ▸ this) Bool.false_ne_true
      · -- hreal: threaded exterior realization bundle (discharged by task 357).
        exact hbrFutReal w hxw hwt
      · -- hsat: threaded exterior saturation residue (discharged by task 357).
        exact hbrFutSat w hxw hwt

end Bimodal.Metalogic.WeakCanonical.Kamp

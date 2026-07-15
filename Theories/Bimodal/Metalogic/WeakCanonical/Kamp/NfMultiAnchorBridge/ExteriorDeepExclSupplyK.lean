import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorDeepSliceSupplyK

/-! # General-`m` rows-12-13 deep-exclusion supply over the ambient-guarded population
     (task 358 Phase 4, G2-B1)

The general-`m` supply theorems for the DEEP-ANCHOR residue rows 12-13 of the obligation ledger
(`_hexclDeepPast`/`_hexclDeepFut`, `EndIntervalConsumerK.lean:191-204`; gate-match mirrors
`kampPrior_site_rungK_gate_match`, `KampPrior.lean:1017-1030`): the ⇒-side exclusion of a
strictly-exterior realizer of an ON-ROW, guard-FALSE, bit-false admissible σ, under the
task-368 ambient guard `kvE_ambientDeepAnchor qnf = true`.

## m = 0 arm (LANDED, sorry-free)

At `k = 0` (σ-depth 1, the m = 0 binder instance) the deep-anchor guard is DEFINITIONALLY the
depth-0 row check (`kvE_deepOnFiber_zero`, the sanctioned m = 0 adapter — never unfolding the
guard). The binder simultaneously asserts `nfk_dropFresh σ = qnf.1` (on-row) and
`kvE_deepOnFiber qnf σ = false` (guard-false); through `kvE_deepOnFiber_zero` these are
CONTRADICTORY (`decide (nfk_dropFresh σ = qnf.1) = true` vs `= false`), so the arm is VACUOUS.
Captured as the standalone sorry-free lemma `kvE_deepExcl_zero_vacuous`.

## General-`m` arm (STRATEGIC SORRY — Phase-4/Phase-5 bridge dependency)

The intended route (plan v07 Phase 4 G2-B1; handoff phase-2-v06 §"Phase-4 notes"): from a
hypothetical σ-realizer at the pinned exterior tuple `[x1,w,x,t]` WITH the ambient realized at
`[w,x,t]`, `kvE_deepOnFiber_of_realized` forces `kvE_deepOnFiber qnf σ = true`, contradicting
the binder's guard-false. Equivalently, the ambient's quant layer `hqnf.2 σ` forces
`qnf.2 σ = true` from the exterior realizer, contradicting `qnf.2 σ = false`.

**Bridge-adjudication finding (task 358 Phase 4, this dispatch).** The contradiction requires the
FULL deep ambient realization `nf_eval_nf M (k+2) 3 [w,x,t] qnf` at the binder site. But the only
ambient information available from the binder hypotheses (`hAmb : kvE_ambientDeepAnchor qnf = true`
+ the `igPtW … .eval_at M atomMap w` guard) is the ATOM LAYER `nf_eval_nf M 0 3 [w,x,t] qnf.1`
(`kvExt_gate_henv`, `ExteriorGateAssembleK.lean:61`). The DEEP quant layer `qnf.2` — the
`∀ sub, (∃ x1, nf_eval_nf … sub) ↔ qnf.2 sub = true` semantic content — is precisely what the
INTERIOR realizer `hreal`/`hexcl` (task 358 Phase 5/6, `kampPrior_hreal_supply` /
`kampPrior_hexcl_supply`) reconstructs from `P.correct` + the fold bit + `hAmb`'s EF-closure.
`kvE_ambientDeepAnchor` is a purely SYNTACTIC `Bool` of `qnf` (no model `M`); it cannot supply the
model-`M` deep realization on its own. Hence the general-`m` arm is BLOCKED on the Phase-5 ambient
render and is landed here as a tracked strategic sorry rather than forcing a false discharge.

This inverts the plan's wave DAG (which sequenced Phase 5 AFTER Phase 4): the exterior deep/slice
supplies depend on the interior ambient render. Recommended re-sequencing recorded in the Phase-4
handoff (`follow_up_task`: task 358 Phase 5 interior render, then this general-`m` arm).

## Routing compliance

Guard consumption ONLY via `kvE_deepOnFiber_zero` / `kvE_deepOnFiber_of_realized` /
`kvE_ambientDeepAnchor_zero`; no `rw`/`unfold`/`simp only` on any guard body. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## m = 0 vacuity kernel (sorry-free) -/

/-- **m = 0 deep-exclusion vacuity** (rows 12-13, `k = 0` arm). At σ-depth 1 the deep-anchor
    guard IS the depth-0 row check (`kvE_deepOnFiber_zero`), so ON-ROW (`nfk_dropFresh σ = qnf.1`)
    and guard-FALSE (`kvE_deepOnFiber qnf σ = false`) are jointly contradictory: the m = 0 residue
    obligation is vacuous. Side-generic (no Fut/Past split — the atom row is orientation-free). -/
theorem kvE_deepExcl_zero_vacuous {sig : MonadicSignature} {n : Nat}
    (qnf : NormalForm sig 2 n) (σ : NormalForm sig 1 (n + 1))
    (hrow : nfk_dropFresh σ = qnf.1)
    (hguard : kvE_deepOnFiber qnf σ = false) : False := by
  have htrue : kvE_deepOnFiber qnf σ = true := by
    rw [kvE_deepOnFiber_zero]; exact decide_eq_true hrow
  rw [hguard] at htrue
  exact Bool.noConfusion htrue

/-! ## Rows 12-13 general-`m` supplies -/

/-- **General-`m` supply for the carried `hexclDeepFut` obligation** (row 13 of the 13-row
    ledger; binder shape verbatim from `EndIntervalConsumerK.lean:198-204` /
    `kampPrior_site_rungK_gate_match` at generic depth). `k = 0`: VACUOUS via
    `kvE_deepExcl_zero_vacuous`. `k = j + 1`: strategic sorry — needs the Phase-5 ambient render
    (see module docstring; the deep quant layer of `nf_eval_nf M (k+2) 3 [w,x,t] qnf` is not
    derivable from `hAmb` + igPtW). -/
theorem kvE_hexclDeepFut_supply {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} :
    ∀ (k : Nat) (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
      (charF : (j : Nat) → NormalForm sig j 1 → Formula)
      (M : OrderedMonadicStructure sig)
      (qnf : NormalForm sig (k + 2) 3)
      (x t : M.carrier),
      kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
        (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1
          (igFoldBit qnf)).eval_at M atomMap w →
        ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
          nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
          ∀ x1 : M.carrier, t < x1 →
            ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
  | 0, _h_surj, _charF, _M, qnf, _x, _t => by
      intro _hAmb w _hxw _hwt _hptW σ _hadm _hbf hrow hguard x1 _hx1 _hσ
      exact kvE_deepExcl_zero_vacuous qnf σ hrow hguard
  | (j + 1), _h_surj, _charF, M, qnf, x, t => by
      intro _hAmb w _hxw _hwt _hptW σ _hadm _hbf _hrow _hguard x1 _hx1 _hσ
      -- sorry: assumes the full deep ambient realization
      --   `nf_eval_nf M (j+3) 3 [w,x,t] qnf`, whose quant layer `qnf.2` forces `qnf.2 σ = true`
      --   from the exterior realizer `_hσ`, contradicting `_hbf`. Deferred because igPtW renders
      --   only the atom layer `qnf.1` (`kvExt_gate_henv`); the deep layer is reconstructed by the
      --   interior realizer. follow-up: task 358 Phase 5 (kampPrior_hreal_supply ambient render)
      --   must precede this general-m arm — see module docstring / Phase-4 handoff.
      sorry

/-- **General-`m` supply for the carried `hexclDeepPast` obligation** (row 12; Past mirror of
    `kvE_hexclDeepFut_supply`, binder shape verbatim from `EndIntervalConsumerK.lean:191-197`).
    Same two-arm route: m = 0 VACUOUS via `kvE_deepExcl_zero_vacuous`; general-`m` strategic sorry
    on the Phase-5 ambient render. -/
theorem kvE_hexclDeepPast_supply {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} :
    ∀ (k : Nat) (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
      (charF : (j : Nat) → NormalForm sig j 1 → Formula)
      (M : OrderedMonadicStructure sig)
      (qnf : NormalForm sig (k + 2) 3)
      (x t : M.carrier),
      kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
        (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1
          (igFoldBit qnf)).eval_at M atomMap w →
        ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
          nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
          ∀ x1 : M.carrier, x1 < x →
            ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
  | 0, _h_surj, _charF, _M, qnf, _x, _t => by
      intro _hAmb w _hxw _hwt _hptW σ _hadm _hbf hrow hguard x1 _hx1 _hσ
      exact kvE_deepExcl_zero_vacuous qnf σ hrow hguard
  | (j + 1), _h_surj, _charF, M, qnf, x, t => by
      intro _hAmb w _hxw _hwt _hptW σ _hadm _hbf _hrow _hguard x1 _hx1 _hσ
      -- sorry: assumes the full deep ambient realization `nf_eval_nf M (j+3) 3 [w,x,t] qnf`
      --   (Past mirror of `kvE_hexclDeepFut_supply`'s general-m arm). Deferred: igPtW renders only
      --   the atom layer; deep layer needs the interior realizer. follow-up: task 358 Phase 5.
      sorry

end Bimodal.Metalogic.WeakCanonical.Kamp

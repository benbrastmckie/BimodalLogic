import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.NfMultiAnchorBridgeRetired.ExteriorDeepSliceSupplyK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# General-`m` rows-12-13 deep-exclusion supply over the ambient-guarded population


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

## General-`m` arm (DISCHARGED — task 370 Phase 8, against the de-folded render)

The contradiction: from the σ-realizer at the pinned exterior tuple `[x1,w,x,t]` WITH the ambient
realized at `[w,x,t]`, the ambient's quant layer `hqnf.2 σ` forces `qnf.2 σ = true` from the
exterior realizer, contradicting the binder's `qnf.2 σ = false`. (Equivalently
`kvE_deepOnFiber_of_realized` forces `kvE_deepOnFiber qnf σ = true` against guard-false.)

**Resolution (task 370, the M2 de-folded carrier redesign).** The blocking dependency was the FULL
deep ambient realization `nf_eval_nf M (k+2) 3 [w,x,t] qnf` at the binder site — task 358 could not
supply it because the folded `igPtW … .eval_at M atomMap w` guard renders only the ATOM LAYER
`nf_eval_nf M 0 3 [w,x,t] qnf.1` (`kvExt_gate_henv`), and `kvE_ambientDeepAnchor` is purely
syntactic. Task 370 completed the de-folded chain: the deep ambient render is now PRODUCED
downstream (Phase 6 render production via `bracketEndChar_kvExtFib_correct_prior`; Phase 7 validated
its supply, `kampPrior_hreal_supply` discharged render-free). These rows-12-13 exclusion arms are
DOWNSTREAM of that render, so they take it as an explicit hypothesis — exactly the sanctioned
interface of the LANDED slice supplies `kvE_hsliceFut_supply` / `kvE_hslicePast_supply`
(`ExteriorDeepSliceSupplyK.lean:131/161`, which also take `nf_eval_nf M (k+2) 3 [w,x,t] qnf`). The
general-`m` arm is then one line: `(hqnf.2 σ).mp ⟨x1, hσ⟩` contradicts `qnf.2 σ = false`. No render
is fabricated; no sorry retained.

## Routing compliance

Guard consumption ONLY via `kvE_deepOnFiber_zero` / `kvE_deepOnFiber_of_realized` /
`kvE_ambientDeepAnchor_zero`; no `rw`/`unfold`/`simp only` on any guard body. -/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## m = 0 vacuity kernel (sorry-free) -/

/-- **m = 0 deep-exclusion vacuity** (rows 12-13, `k = 0` arm). At σ-depth 1 the deep-anchor
    guard IS the depth-0 row check (`kvE_deepOnFiber_zero`), so ON-ROW (`nfk_dropFresh σ = qnf.1`)
    and guard-FALSE (`kvE_deepOnFiber qnf σ = false`) are jointly contradictory: the m = 0 residue
    obligation is vacuous. Side-generic (no Fut/Past split — the atom row is orientation-free). -/
theorem kvE_deepExcl_zero_vacuous {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
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
    `kvE_deepExcl_zero_vacuous`. `k = j + 1`: DISCHARGED — the de-folded chain's
    deep ambient render `nf_eval_nf M (k+2) 3 [w,x,t] qnf` (taken downstream, as the landed slice
    supplies do) has quant layer forcing `qnf.2 σ = true` from the exterior realizer, contradicting
    `qnf.2 σ = false`. See module docstring. -/
theorem kvE_hexclDeepFut_supply {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    ∀ (k : Nat)
      (M : OrderedMonadicStructure sig)
      (qnf : NormalForm sig (k + 2) 3)
      (x t : M.carrier),
      kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
        nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
        ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
          nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
          ∀ x1 : M.carrier, t < x1 →
            ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
  | 0, _M, qnf, _x, _t => by
      intro _hAmb w _hxw _hwt _hqnf σ _hadm _hbf hrow hguard x1 _hx1 _hσ
      exact kvE_deepExcl_zero_vacuous qnf σ hrow hguard
  | (j + 1), M, qnf, x, t => by
      intro _hAmb w _hxw _hwt hqnf σ _hadm hbf _hrow _hguard x1 _hx1 hσ
      -- General-`m` DISCHARGE (task 370 Phase 8, against the de-folded render). The ambient
      -- deep render `hqnf : nf_eval_nf M (j+3) 3 [w,x,t] qnf` — now PRODUCED downstream by the
      -- de-folded chain (Phase 6 render production / Phase 7 validated supply) — has quant layer
      -- `qnf.2`. Its forward direction forces `qnf.2 σ = true` from the exterior realizer `hσ`
      -- at `x1`, contradicting the binder's `qnf.2 σ = false` (`hbf`). This is the exact dual of
      -- the landed slice supply `kvE_hsliceFut_supply`, which takes the same render downstream.
      have hmk : qnf.2 σ = true := (hqnf.2 σ).mp ⟨x1, hσ⟩
      rw [hmk] at hbf
      exact Bool.noConfusion hbf

/-- **General-`m` supply for the carried `hexclDeepPast` obligation** (row 12; Past mirror of
    `kvE_hexclDeepFut_supply`, binder shape verbatim from `EndIntervalConsumerK.lean:191-197`).
    Same two-arm route: m = 0 VACUOUS via `kvE_deepExcl_zero_vacuous`; general-`m` DISCHARGED
 against the de-folded ambient render (Past mirror). -/
theorem kvE_hexclDeepPast_supply {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    ∀ (k : Nat)
      (M : OrderedMonadicStructure sig)
      (qnf : NormalForm sig (k + 2) 3)
      (x t : M.carrier),
      kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
        nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
        ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
          nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
          ∀ x1 : M.carrier, x1 < x →
            ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
  | 0, _M, qnf, _x, _t => by
      intro _hAmb w _hxw _hwt _hqnf σ _hadm _hbf hrow hguard x1 _hx1 _hσ
      exact kvE_deepExcl_zero_vacuous qnf σ hrow hguard
  | (j + 1), M, qnf, x, t => by
      intro _hAmb w _hxw _hwt hqnf σ _hadm hbf _hrow _hguard x1 _hx1 hσ
      -- General-`m` DISCHARGE (task 370 Phase 8, Past mirror of `kvE_hexclDeepFut_supply`). The
      -- ambient deep render `hqnf`'s quant layer forces `qnf.2 σ = true` from the exterior
      -- realizer `hσ` at `x1` (`x1 < x`), contradicting the binder's `qnf.2 σ = false` (`hbf`).
      -- Downstream of the de-folded render, exact dual of the landed `kvE_hslicePast_supply`.
      have hmk : qnf.2 σ = true := (hqnf.2 σ).mp ⟨x1, hσ⟩
      rw [hmk] at hbf
      exact Bool.noConfusion hbf

end Bimodal.Metalogic.WeakCanonical.Kamp

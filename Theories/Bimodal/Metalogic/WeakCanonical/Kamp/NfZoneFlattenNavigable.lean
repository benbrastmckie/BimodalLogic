import Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation
import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneDepthK

/-!
# Phase 1 GO/NO-GO GATE — navigated (depth-graded) flattening at `k = 1` (task 307, plan 01)

This module is the **decisive go/no-go gate** for task 307's bound-anchor zone converter
(`KampPrior.lean:391`). It is **off the live import path** (nothing in the `completeness_discrete`
chain imports it) and is **fully sorry-free**.

## The categorical distinction under test (vs. the refuted atomic D1)

`NfZoneDepthK1Probe.lean` (D1) refuted the *atomic* flattening: absorbing the coupled quant witness
`w` as a **depth-0 atomic** bracket witness on the fixed `(x, t)` interval. Its NO-GO
(`interior_bracket_cannot_realize_exterior_sub_k1`) is an **interior-confinement** result — atomic
`TemporalPred`s (`.atom`/`.box`, purely local `temporal_truth`) place every bracket witness strictly
inside `(x, t)`, so they can never testify to an **exterior** `w` (`w < x` or `t < w`).

The bound-anchor construction (research report 01, outcome (a)) uses a categorically different
endpoint type: a **NAVIGATED** one built by `bracketBuildRight`/`bracketBuildLeft` (Rabinovich Cor
5.4 `F_i` chains — `Until`/`Since`). The navigated bracket reaches a witness `z1` with `t < z1`
(future exterior) or `z0 < z1` back into the past — it is **not** interior-confined. `w` is laid as
a **bracket witness** (never a new `nf_eval` env position; anchor set stays `{x, t}`), and the
coupling to `(x, t)` is carried by the chain **structure**, not by naming a third anchor.

## Pillar established here (sorry-free): navigation reaches the exterior

`navigated_bracket_reaches_exterior_future` is the positive dual of D1's
`interior_bracket_cannot_realize_exterior_sub_k1`: a navigated `bracketBuildRight` formula evaluated
at `t`, with the trivial (`top`) interval segment, is equivalent to the pure **future-exterior**
existential `∃ w, t < w ∧ endRight.eval_at M atomMap w` for an **arbitrary** navigated endpoint type
`endRight`. Where D1's atomic bracket confined witnesses to `(x, t)`, the navigated bracket reaches
`w` in the exterior `t < w` (and, via `bracketBuildLeft`, the past `w < z1`). This is exactly the
capability the atomic simplification lacked — the mechanism by which the bound-anchor flattening can
express what the atomic flattening could not.

## References
- `NfZoneDepthK1Probe.lean` (D1: atomic-bracket interior confinement — the refuted sibling).
- `NfZoneNavProbe.lean` (Phase-16 free-anchor NO-GO: `x` free, unstatable under binding).
- `VecEATranslation.lean:234` (`bracketBuildRight_correct`), `:503` (`bracketBuildLeft_correct`),
  `:311` (`BracketFormula.trivial_holds`).
- `reports/01_bound-anchor-verdict.md` §3 (outcome (a): navigated chain, `w` a bracket witness).
- Rabinovich 2014 "A Proof of Kamp's Theorem" Cor 5.4 (`md:154-157`).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Pillar: a NAVIGATED bracket reaches the future exterior

The categorical response to D1. `bracketBuildRight (BracketFormula.trivial TemporalPred.top)
endRight`, evaluated at `t`, is equivalent to `∃ w, t < w ∧ endRight.eval_at M atomMap w`: the
navigated endpoint `endRight` is checked at a witness `w` strictly in the **future exterior**
`t < w`. Contrast D1's `interior_bracket_cannot_realize_exterior_sub_k1`, where the atomic bracket
witnesses are provably confined to the interior `(x, t)`. Navigation is not confined; this is the
whole point of using `Until`/`Since` endpoints. -/

/-- **Navigation reaches the future exterior.** For any navigated endpoint type `endRight`, the
    `bracketBuildRight` formula with a trivial (`top`) segment, evaluated at `t`, holds iff there is
    a future-exterior witness `w` (`t < w`) at which `endRight` holds. The trivial segment condition
    is vacuous (`top` holds everywhere), so the navigated bracket collapses to the bare exterior
    existential — capturing exactly the exterior-`w` content D1's atomic bracket could not. -/
theorem navigated_bracket_reaches_exterior_future {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (endRight : TemporalPred) (t : M.carrier) :
    temporal_truth M atomMap t
        (bracketBuildRight (BracketFormula.trivial TemporalPred.top) endRight) ↔
      ∃ w : M.carrier, t < w ∧ endRight.eval_at M atomMap w := by
  rw [bracketBuildRight_correct]
  constructor
  · rintro ⟨z1, hz1, hend, _⟩
    exact ⟨z1, hz1, hend⟩
  · rintro ⟨w, hw, hend⟩
    refine ⟨w, hw, hend, ?_⟩
    -- trivial (top) segment: vacuously holds on (t, w)
    rw [BracketFormula.trivial_holds]
    intro y _ _
    simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]

end Bimodal.Metalogic.WeakCanonical.Kamp

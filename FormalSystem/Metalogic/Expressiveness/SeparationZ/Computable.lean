/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Discharge

/-!
# The computable ZTime translation `trZ`

`OpenFutureElimination.lean`'s translation `tr hsep` of the open-future language into L⁺ is
`noncomputable`: at `▷φ` and `◁φ` it chooses a separated conjunctive normal form of the
translation of `φ` by `Classical.choose` from the separation hypothesis. With
`separationOver_ztime` discharged by the plain `def` `sepZ` (`Discharge.lean`), the choice can be
replaced by a computation at `.ZTime`. `trZ` is that translation: homomorphic on the seven shared
constructors, and at `▷φ` / `◁φ` the `▷`- / `◁`-eliminated form of `sepZ (trZ φ)`. It is a plain
`def` with no `noncomputable` keyword.

## What this does and does not change

`tr` is untouched: same name, still `noncomputable`, still taking `hsep` explicitly, and every
result stated about it keeps its statement. `trZ` is an **addition**, not a replacement — a second
translation whose two theorems, `openTruthAt_iff_trZ` and `openValidIn_ztime_iff_trZ`, are the
`.ZTime` instances of `openTruthAt_iff_tr` and `openValidIn_ztime_iff_tr` with the hypothesis
discharged and the chosen form computed. Their proofs mirror the landed ones step for step, with
`plusTruthAt_sepZ_iff` and `sepZ_sepClauses` where the landed proofs use `Classical.choose_spec`.

`trZ` inhabits the translation slot of the already-generic `decidableOpenValidInOfTranslation`,
`openDecider`, `openDecider_correct`, `openComplete_of_plusComplete_in` and
`openValid_of_plusSound` (`OpenFutureElimination.lean`) with no change to any of the five, and
closes the effectiveness gap those rows inherit — at `.ZTime` only. The `.RTime` instance
(GHR Theorem 10.3.20) remains conditional on `SeparationOver TaskFrame.IsRTime`, and no
uniform `noncomputable` `Decidable (OpenValidIn FrameClass.ZTime φ)` is added here: the host
module's docstring records that shape as rejected, since it is inhabited by `Classical.dec _`
with no hypothesis at all.

## Main Definitions

- `trZ`: the computable translation of the open-future language into L⁺ over ℤ-time

## Main Results

- `openTruthAt_iff_trZ`: `trZ` is truth-preserving on every regular ℤ-time frame
- `openValidIn_ztime_iff_trZ`: open-future-language validity at `.ZTime` is L⁺-validity of the
  translation, unconditionally

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Theorem 10.2.9
-/

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.ProofSystem

/--
**The computable ZTime translation**: homomorphic on the seven shared constructors, and at `▷φ`
(resp. `◁φ`) the `▷`- (resp. `◁`-) eliminated form of the computed separated conjunctive normal
form `sepZ` of the translation of `φ`. A plain `def`, deliberately not `noncomputable`.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them)
-/
def trZ : OpenFormula → PlusFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (trZ φ) (trZ ψ)
  | .box φ => .box (trZ φ)
  | .untl ψ φ => .untl (trZ ψ) (trZ φ)
  | .snce ψ φ => .snce (trZ ψ) (trZ φ)
  | .stab φ => .stab (trZ φ)
  | .ofut φ => ofutElim (sepZ (trZ φ))
  | .opast φ => opastElim (sepZ (trZ φ))

/--
**`trZ` is truth-preserving** on every regular ℤ-time frame, at every model, world history and
time. Induction on `φ` generalizing the world history and the time, mirroring
`openTruthAt_iff_tr`; at the two restricted modals `plusTruthAt_sepZ_iff` and `sepZ_sepClauses`
stand where that proof uses `Classical.choose_spec`.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them)
-/
theorem openTruthAt_iff_trZ {F : TaskFrame} [F.IsRegular] (hz : F.IsZTime)
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula) :
    OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (trZ φ) := by
  induction φ generalizing τ t with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih => exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab φ ih => exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t
  | ofut φ ih =>
    exact (forall_congr' fun σ => imp_congr_right fun _ =>
      (ih σ t).trans (plusTruthAt_sepZ_iff (trZ φ) ‹F.IsRegular› hz M σ t)).trans
      (ofutP_sepForm_iff M τ t _ (sepZ_sepClauses (trZ φ) F ‹F.IsRegular› hz))
  | opast φ ih =>
    exact (forall_congr' fun σ => imp_congr_right fun _ =>
      (ih σ t).trans (plusTruthAt_sepZ_iff (trZ φ) ‹F.IsRegular› hz M σ t)).trans
      (opastP_sepForm_iff M τ t _ (sepZ_sepClauses (trZ φ) F ‹F.IsRegular› hz))

/--
**At `.ZTime`, unconditionally**: open-future-language validity is L⁺-validity of the computable
translation. `FrameClass.Sat .ZTime F` is `F.IsRegular ∧ F.IsZTime` by definition, and the proof
has the shape of `openValidOnFrames_iff_tr` with `openTruthAt_iff_trZ` in place of
`openTruthAt_iff_tr`. This is `openValidIn_ztime_iff_tr` with its separation hypothesis
discharged and its translation computed.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them)
-/
theorem openValidIn_ztime_iff_trZ (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime φ ↔ PlusValidIn FrameClass.ZTime (trZ φ) := by
  constructor
  · intro h F hF M τ t
    haveI := hF.1
    exact (openTruthAt_iff_trZ hF.2 M τ t φ).mp (h F hF M τ t)
  · intro h F hF M τ t
    haveI := hF.1
    exact (openTruthAt_iff_trZ hF.2 M τ t φ).mpr (h F hF M τ t)

end FormalSystem.Metalogic.Expressiveness

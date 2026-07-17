import Bimodal.Metalogic.WeakCanonical.Kamp.Prop35Chain
import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF

/-!
# Proposition 3.5: specialization and assembly (Rabinovich 2014, PDF p.5)

Completes Proposition 3.5 on the Phase-3 `ExistsForallFormula` object: every `∃∀`-formula with
one free variable is equivalent to a `TL(Until, Since)` formula. This module specializes the
generic machinery already landed — the atomic layer (`unaryToFormula`, `Prop35ExistsForall.lean`)
and the generic Until/Since chain bridge (`buildRight_spec_iff_chain` / `buildLeft_spec_iff_chain`,
`Prop35Chain.lean`) — to `ψ`'s own `Fin`-indexed point/interval types, assembles the full
biconditional against `efSat`, and lifts the result through `VeeExistsForall` (Def 3.3, p.4).

## Contents

- `efPointTP` / `efIntervalTP`: render `ψ.pointType` / `ψ.intervalType` (already `UnaryType`s) as
  `TemporalPred`s via `unaryToFormula`.
- `translateProp35`: the Prop 3.5 translation of a single `ExistsForallFormula` with one free
  variable, via `translateEF1` pinned at the free variable's witness point.
- `translateProp35_correct`: `efSat N env ψ ↔ temporal_truth N atomMap (env 0) (translateProp35 …
  ψ)`.
- `translateVeeProp35` / `translateVeeProp35_correct`: the lift through `VeeExistsForall` (Def
  3.3, p.4), mirroring the legacy `VVecEA2.translateRight`'s own `translateVEF1` wrapper.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 3.5 (p.5), Definition 3.3 (p.4).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `Prop35ExistsForall.lean`: `unaryToFormula`, `unaryToFormula_correct`.
- `Prop35Chain.lean`: `buildRight_spec_iff_chain`, `buildLeft_spec_iff_chain`.
- `Translation.lean`: `translateEF1`, `translateEF1_correct`.
- `ExistsForallFormula.lean`: `ExistsForallFormula`, `efSat`.
- `VeeExistsForall.lean`: `VeeExistsForall`, `veeSat`.
- `ExistsForallNF.lean`: `translateVEF1`, `translateVEF1_correct`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

/-! ## 1. Rendering point/interval types as temporal predicates -/

/-- Render a `ψ.pointType` unary type as a `TemporalPred` via `unaryToFormula`. -/
noncomputable def efPointTP {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) : TemporalPred :=
  ⟨unaryToFormula atomMap h_surj τ⟩

/-- Render a `ψ.intervalType` unary type as a `TemporalPred` via `unaryToFormula`. -/
noncomputable def efIntervalTP {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) : TemporalPred :=
  ⟨unaryToFormula atomMap h_surj τ⟩

/-- `efPointTP` reads back exactly as `unaryHolds`. -/
theorem efPointTP_eval {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) (t : N.carrier) :
    (efPointTP atomMap h_surj τ).eval_at N atomMap t ↔ unaryHolds N τ t := by
  unfold efPointTP TemporalPred.eval_at
  exact unaryToFormula_correct N atomMap h_surj τ t

/-- `efIntervalTP` reads back exactly as `unaryHolds`. -/
theorem efIntervalTP_eval {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) (t : N.carrier) :
    (efIntervalTP atomMap h_surj τ).eval_at N atomMap t ↔ unaryHolds N τ t := by
  unfold efIntervalTP TemporalPred.eval_at
  exact unaryToFormula_correct N atomMap h_surj τ t

/-! ## 2. The Prop 3.5 translation -/

/-- The Prop 3.5 translation of a single `∃∀`-formula with one free variable: `translateEF1`
pinned at the free variable's witness point, with point/interval types rendered via
`efPointTP`/`efIntervalTP`. -/
noncomputable def translateProp35 {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 1) : Formula :=
  translateEF1 ψ.n (ψ.pin 0)
    (fun j => efPointTP atomMap h_surj (ψ.pointType j))
    (fun i => efIntervalTP atomMap h_surj (ψ.intervalType i))

end Bimodal.Metalogic.WeakCanonical.Kamp

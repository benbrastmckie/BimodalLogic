/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness
import FormalSystem.Metalogic.Conservativity.Fragment

/-!
# Proof-theoretic conservativity of TM⁺ over TM, both directions

The **forward** direction — `TM⁺ ⊢[fc] ofFormula φ ⟹ TM ⊢[fc] φ` — via semantics:

```
TM⁺ ⊢ ofFormula φ  ⟹[plus_soundness_validIn]  PlusValidIn fc (ofFormula φ)
                   ⟹[plusValidIn_ofFormula_iff]  ValidIn fc φ
                   ⟹[WeakCompleteness fc engine]  TM ⊢ φ
```

It needs TM⁺ **soundness** and TM **completeness** — never TM⁺ completeness, which is false at
`.Base` for the current axiom set (`Metalogic/Independence/PlusIncompleteness.lean`) and open for
any extension. Together with the backward direction `plusDerivable_of_derivable`
(`PlusLanguage/Derivation.lean`, by the constructor-to-constructor embedding of derivations),
this gives `plusDerivable_ofFormula_iff`: **TM⁺ is a conservative extension of TM**, at every
frame class carrying a completeness engine — that is, at all four.

## Contrast with the base-language pair

The same composition for L⁻ ⊂ L (`TM ⊢ tr φ ⟹ TM⁻ ⊢ φ`) would need TM⁻-completeness, which is
refuted (`tmMinusCompleteZTime_refuted`; `Metalogic/Conservativity.lean`). So `Forward⁺`
(TM⁺ over TM) holds at all four classes, unlike `Forward` (TM over TM⁻). The composed L⁻ ⊂ L⁺
rows below inherit exactly that status: the backward direction composes, the forward direction
is the L⁻ ⊂ L forward direction and is **not asserted**.

## Main Results

- `forward_plus` — the forward direction at any class with an engine; four instantiated rows
- `plusDerivable_ofFormula_iff` — conservativity in both directions; four rows
- `plus_of_tmMinus` — the composed L⁻ ⊂ L⁺ backward rows
- `tmFrag_iff_plus` — the H/G-fragment of TM is also the H/G-fragment of TM⁺

## References

* `FormalSystem/Metalogic/StrongCompleteness.lean` — the four `WeakCompleteness` engines
* `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` — why the L⁻ ⊂ L forward
  direction is a different matter

## Tags

conservativity · plus-language · stability-modal · both-directions
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.PlusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-- **Forward conservativity of TM⁺ over TM**, at any class with a weak-completeness engine:
TM⁺ soundness, then the truth-transfer bridge, then the engine. -/
theorem forward_plus {fc : FrameClass} (engine : WeakCompleteness fc) (φ : Formula)
    (h : PlusDerivable fc [] (ofFormula φ)) : ProofSystem.Derivable fc [] φ :=
  engine φ ((plusValidIn_ofFormula_iff fc φ).mp (plus_soundness_validIn h))

/-- Forward conservativity at `.Base`, via `completeness_base`. -/
theorem forward_plus_base (φ : Formula) (h : PlusDerivable FrameClass.Base [] (ofFormula φ)) :
    ProofSystem.Derivable FrameClass.Base [] φ :=
  forward_plus completeness_base φ h

/-- Forward conservativity at `.Dense`, via `completeness_dense`. -/
theorem forward_plus_dense (φ : Formula) (h : PlusDerivable FrameClass.Dense [] (ofFormula φ)) :
    ProofSystem.Derivable FrameClass.Dense [] φ :=
  forward_plus completeness_dense φ h

/-- Forward conservativity at `.ZTime`, via `completeness_ztime`. -/
theorem forward_plus_ztime (φ : Formula)
    (h : PlusDerivable FrameClass.ZTime [] (ofFormula φ)) :
    ProofSystem.Derivable FrameClass.ZTime [] φ :=
  forward_plus completeness_ztime φ h

/-- Forward conservativity at `.RTime`, via `completeness_rtime`. -/
theorem forward_plus_rtime (φ : Formula)
    (h : PlusDerivable FrameClass.RTime [] (ofFormula φ)) :
    ProofSystem.Derivable FrameClass.RTime [] φ :=
  forward_plus completeness_rtime φ h

/-- **TM⁺ is a conservative extension of TM**: at any class with an engine, an L formula is a
TM⁺ theorem iff it is a TM theorem. Backward by the embedding of derivations, forward by
soundness plus completeness.

Paper: — (formalization-native; L⁺ is the ⊡-only fragment of the paper's `\BL^\star`, for which the
paper supplies no logic)
-/
theorem plusDerivable_ofFormula_iff {fc : FrameClass} (engine : WeakCompleteness fc)
    (φ : Formula) : PlusDerivable fc [] (ofFormula φ) ↔ ProofSystem.Derivable fc [] φ :=
  ⟨forward_plus engine φ, fun h => plusDerivable_of_derivable h⟩

/-- Conservativity at `.Base`. -/
theorem plusDerivable_ofFormula_iff_base (φ : Formula) :
    PlusDerivable FrameClass.Base [] (ofFormula φ) ↔ ProofSystem.Derivable FrameClass.Base [] φ :=
  plusDerivable_ofFormula_iff completeness_base φ

/-- Conservativity at `.Dense`. -/
theorem plusDerivable_ofFormula_iff_dense (φ : Formula) :
    PlusDerivable FrameClass.Dense [] (ofFormula φ) ↔
      ProofSystem.Derivable FrameClass.Dense [] φ :=
  plusDerivable_ofFormula_iff completeness_dense φ

/-- Conservativity at `.ZTime`. -/
theorem plusDerivable_ofFormula_iff_ztime (φ : Formula) :
    PlusDerivable FrameClass.ZTime [] (ofFormula φ) ↔
      ProofSystem.Derivable FrameClass.ZTime [] φ :=
  plusDerivable_ofFormula_iff completeness_ztime φ

/-- Conservativity at `.RTime`. -/
theorem plusDerivable_ofFormula_iff_rtime (φ : Formula) :
    PlusDerivable FrameClass.RTime [] (ofFormula φ) ↔
      ProofSystem.Derivable FrameClass.RTime [] φ :=
  plusDerivable_ofFormula_iff completeness_rtime φ

/-! ## The composed pair L⁻ ⊂ L⁺

Backward: `derivable_translate` (`Conservativity/Backward.lean`) composed with
`plusDerivable_of_derivable`. The **forward** direction for this pair,
`TM⁺ ⊢ ofFormula (tr φ) ⟹ TM⁻ ⊢ φ`, is by `plusDerivable_ofFormula_iff` exactly the L⁻ ⊂ L
forward direction `TM ⊢ tr φ ⟹ TM⁻ ⊢ φ`, which is refuted at `.Base` and `.ZTime` and open
at `.Dense` and `.RTime` (`Metalogic/Conservativity.lean`); it is **not asserted**. -/

/-- **L⁻ ⊂ L⁺, backward**: a TM⁻ theorem embeds, through `tr` and `ofFormula`, into a TM⁺ theorem
at the same class. -/
theorem plus_of_tmMinus {fc : FrameClass} (φ : MinusFormula)
    (h : MinusLanguage.Derivable fc [] φ) : PlusDerivable fc [] (ofFormula (tr φ)) :=
  plusDerivable_of_derivable (derivable_translate h)

/-- L⁻ ⊂ L⁺ backward at `.Base`. -/
theorem plus_of_tmMinus_base (φ : MinusFormula) (h : MinusLanguage.Derivable FrameClass.Base [] φ) :
    PlusDerivable FrameClass.Base [] (ofFormula (tr φ)) :=
  plus_of_tmMinus φ h

/-- L⁻ ⊂ L⁺ backward at `.Dense`. -/
theorem plus_of_tmMinus_dense (φ : MinusFormula)
    (h : MinusLanguage.Derivable FrameClass.Dense [] φ) :
    PlusDerivable FrameClass.Dense [] (ofFormula (tr φ)) :=
  plus_of_tmMinus φ h

/-- L⁻ ⊂ L⁺ backward at `.ZTime`. -/
theorem plus_of_tmMinus_ztime (φ : MinusFormula)
    (h : MinusLanguage.Derivable FrameClass.ZTime [] φ) :
    PlusDerivable FrameClass.ZTime [] (ofFormula (tr φ)) :=
  plus_of_tmMinus φ h

/-- L⁻ ⊂ L⁺ backward at `.RTime`. -/
theorem plus_of_tmMinus_rtime (φ : MinusFormula)
    (h : MinusLanguage.Derivable FrameClass.RTime [] φ) :
    PlusDerivable FrameClass.RTime [] (ofFormula (tr φ)) :=
  plus_of_tmMinus φ h

/-- **The H/G-fragment is the same seen from TM⁺**: `TMFrag fc φ` (`Conservativity/Fragment.lean`)
iff the embedding of `tr φ` is a TM⁺ theorem, at any class with an engine. -/
theorem tmFrag_iff_plus {fc : FrameClass} (engine : WeakCompleteness fc) (φ : MinusFormula) :
    TMFrag fc φ ↔ PlusDerivable fc [] (ofFormula (tr φ)) :=
  (plusDerivable_ofFormula_iff engine (tr φ)).symm

/-! ### Acceptance check -/

example (φ : Formula) :
    PlusDerivable FrameClass.Base [] (ofFormula φ) ↔ ProofSystem.Derivable FrameClass.Base [] φ :=
  plusDerivable_ofFormula_iff completeness_base φ

end FormalSystem.Metalogic.Conservativity

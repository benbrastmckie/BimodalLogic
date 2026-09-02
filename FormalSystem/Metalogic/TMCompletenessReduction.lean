/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BaseLanguageSoundness
import FormalSystem.Metalogic.BXCanonical

/-!
# The TM-completeness / forward-conservativity reduction

**Read `Metalogic/Conservativity.lean`'s module docstring first.** That module states, and
proves the tree must never state or `sorry`, the **forward-conservativity prohibition**:

```
theorem forward {fc} {φ} : ProofSystem.Derivable fc [] (tr φ) → BaseLanguage.Derivable fc [] φ
```

is refuted at `fc := .Base` and `fc := .Discrete`, and a `sorry`-ed proof of it would be an
unsound placeholder, not deferred debt.

**This module strengthens that prohibition by exposing a second phrasing of the forbidden
claim.** Given the tree's own `BXCanonical.completeness` (BL⁺ completeness at `.Base`) and
`blValid_iff_valid_tr` (the BL/BL⁺ validity bridge), "TM is complete over task frames" and
"forward conservativity holds at `FrameClass.Base`" turn out to be *the same proposition* — a
two-line composition of results already in this tree, with **neither side asserted**. Nothing
here proves TM-completeness, and nothing here proves forward conservativity; the point is that a
future dispatch attempting either one, in good faith, is thereby attempting the other, and is
covered by the same prohibition. No `sorry` occurs anywhere in this file, and neither
`TMCompleteBase` nor `ForwardBase` (nor their `.Discrete` siblings) appears as the conclusion of
any `theorem` below — both are `def`s, referenced only as the *statement* being related, never
discharged.

## Where the backward direction does the work

`tmCompleteBase_iff_forwardBase`'s **backward** direction (`ForwardBase → TMCompleteBase`) is
where `BXCanonical.completeness` — TM⁺'s completeness over *all* task frames, `cor:tm-completeness`
row 1, machine-checked in this tree — actually does the work: it is the step that turns a
BL-valid formula into a `⊢[Base] tr φ` derivation, which `ForwardBase` then pulls back across the
translation. The **forward** direction (`TMCompleteBase → ForwardBase`) is the easier composition,
routing `⊢[Base] tr φ` through TM⁺'s own soundness to `Valid (tr φ)`, then across
`blValid_iff_valid_tr` to `BLValid φ`.

## Main Definitions

- `TMCompleteBase`, `TMCompleteDiscrete` — "TM (resp. TM_f) is complete over task frames
  (resp. over `FrameClass.Discrete` frames)": every BL-valid formula is TM-derivable. Unasserted.
- `ForwardBase`, `ForwardDiscrete` — the forward-conservativity statement at `.Base`
  (resp. `.Discrete`), literally `Conservativity.lean`'s forbidden `forward` theorem restricted
  to one frame class. Unasserted.

## Main Results

- `tmCompleteBase_iff_forwardBase` — the two `.Base` propositions are equivalent
- `tmCompleteDiscrete_iff_forwardDiscrete` — the `.Discrete` mirror

## References

* `FormalSystem/Metalogic/Conservativity.lean` — the forward-conservativity prohibition this
  module strengthens
* `FormalSystem/Metalogic/BXCanonical/Completeness.lean` — `completeness`, `completeness_discrete`
* `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — `blValid_iff_valid_tr`,
  `blValidDiscrete_iff_validDiscrete_tr`
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.BaseLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic.Conservativity

/-! ## `FrameClass.Base` -/

/--
**"TM is complete over task frames."** Every BL-valid formula is derivable in TM at
`FrameClass.Base`. **Unasserted** — this `def` states the proposition so it can be named and
related to `ForwardBase` below; it is never the conclusion of a `theorem` in this tree.
-/
def TMCompleteBase : Prop := ∀ φ : BLFormula, BLValid φ → BaseLanguage.Derivable FrameClass.Base [] φ

/--
**"Forward conservativity holds at `FrameClass.Base`."** Literally the `forward` theorem
`Conservativity.lean`'s module docstring shows must never be stated or `sorry`-ed, restricted to
`fc := .Base`. **Unasserted**, for the same reason.
-/
def ForwardBase : Prop :=
  ∀ φ : BLFormula, ProofSystem.Derivable FrameClass.Base [] (tr φ) → BaseLanguage.Derivable FrameClass.Base [] φ

/--
**The reduction.** `TMCompleteBase` and `ForwardBase` are the same proposition.

Forward (`TMCompleteBase → ForwardBase`): given `⊢[Base] tr φ`, TM⁺'s own `soundness` gives
`Valid (tr φ)`, and `blValid_iff_valid_tr` crosses to `BLValid φ`; apply `TMCompleteBase` to get
`⊢ᴮᴸ[Base] φ`.

Backward (`ForwardBase → TMCompleteBase`): given `BLValid φ`, `blValid_iff_valid_tr` gives
`Valid (tr φ)`, and `BXCanonical.completeness` — TM⁺'s completeness over *all* task frames —
gives `⊢[Base] tr φ`; apply `ForwardBase` to get `⊢ᴮᴸ[Base] φ`. This direction is where
TM⁺'s completeness does the actual work; see the module docstring.
-/
theorem tmCompleteBase_iff_forwardBase : TMCompleteBase ↔ ForwardBase := by
  constructor
  · intro hcomplete φ h
    apply hcomplete φ
    rw [blValid_iff_valid_tr]
    obtain ⟨d⟩ := h
    exact Valid.of_forall_total fun F M τ hτ t =>
      soundness [] (tr φ) d F M τ hτ t (by simp)
  · intro hforward φ hvalid
    apply hforward φ
    exact BXCanonical.completeness (tr φ) ((blValid_iff_valid_tr φ).mp hvalid)

/-! ## `FrameClass.Discrete` -/

/--
**"TM_f is complete over `FrameClass.Discrete` task frames."** Every `BLValidDiscrete` formula is
derivable in TM_f. **Unasserted**, exactly as `TMCompleteBase`.
-/
def TMCompleteDiscrete : Prop :=
  ∀ φ : BLFormula, BLValidDiscrete φ → BaseLanguage.Derivable FrameClass.Discrete [] φ

/--
**"Forward conservativity holds at `FrameClass.Discrete`."** The `.Discrete` instance of the
forbidden `forward` theorem. **Unasserted**, exactly as `ForwardBase`.
-/
def ForwardDiscrete : Prop :=
  ∀ φ : BLFormula, ProofSystem.Derivable FrameClass.Discrete [] (tr φ) →
    BaseLanguage.Derivable FrameClass.Discrete [] φ

/--
**The `.Discrete` mirror of `tmCompleteBase_iff_forwardBase`.**

Forward: `⊢[Discrete] tr φ` gives `ValidDiscrete (tr φ)` via `soundness_discrete_valid`, and
`blValidDiscrete_iff_validDiscrete_tr` crosses to `BLValidDiscrete φ`.

Backward: `BLValidDiscrete φ` gives `ValidDiscrete (tr φ)` via
`blValidDiscrete_iff_validDiscrete_tr`, and `BXCanonical.completeness_discrete` gives
`⊢[Discrete] tr φ`.
-/
theorem tmCompleteDiscrete_iff_forwardDiscrete : TMCompleteDiscrete ↔ ForwardDiscrete := by
  constructor
  · intro hcomplete φ h
    apply hcomplete φ
    rw [blValidDiscrete_iff_validDiscrete_tr]
    obtain ⟨d⟩ := h
    exact soundness_discrete_valid d
  · intro hforward φ hvalid
    apply hforward φ
    exact BXCanonical.completeness_discrete (tr φ)
      ((blValidDiscrete_iff_validDiscrete_tr φ).mp hvalid)

end FormalSystem.Metalogic

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Plus.Forward
import FormalSystem.Theorems.TemporalDerived

/-!
# Conservativity corollaries and the logic of the defined modals

What the stability modal permits beyond the conservativity rows already landed in
`Conservativity/Plus/Forward.lean`: the composed L⁻/L-fragment rows named at each frame class
and the derived theorems governing the defined modals `Will`, `will`, `Could`, `could`
(`PlusLanguage/Formula.lean`, paper lines 1125-1129). The conservativity of the *extended* system
TM⁺ + *Determined* over TM is stated in `Metalogic/Deterministic/Completeness.lean`, so that this
directory does not import the deterministic subtree (which itself imports TM⁺ soundness from here).

## What was already landed, and is cited rather than restated

`Forward.lean` already carries, at each of the four classes: forward conservativity
(`forward_plus_*`), the biconditional `plusDerivable_ofFormula_iff_*`, the L⁻ ⊂ L⁺ backward row
`plus_of_tmMinus_*`, and the fragment identification `tmFrag_iff_plus`. Only the last is left
generic over the engine there, so the four named instances are the one composed row this module
adds; nothing else in that list is restated.

Likewise the *refuted* directions are cited, not restated: `Semantics/PlusNonValidities.lean`
carries `refute_stab_box`, `refute_allFuture_stab`, `refute_stab_allFuture_past`,
`refute_determined` and `refute_somePast_stab`, which between them bound the defined modals'
logic from above.

## The defined modals

| Notation | Reading | Row below |
|---|---|---|
| `Will φ = ⊡Gφ` | settled to hold always in the future | `willImpAllFuture`, `boxAllFutureImpWill` |
| `will φ = ⊡Fφ` | settled to hold at some future time | `willImpWill` |
| `could φ = ⟐Fφ` | possible, relative to the present state, at some future time | `someFutureCouldImpCouldSomeFuture` |

`willImpWill` is where the substitution transfer earns its keep a second time: `Gφ → Fφ` is a TM
theorem (seriality plus `G`-distribution plus `F`-monotonicity), and
`plusDerivable_substPlus` lifts it to arbitrary `PlusFormula` arguments, after which
`⊡`-monotonicity closes the row.

## Main Results

- `tmFragIffPlusBase` and the three siblings — the composed fragment rows, named per class
- `plusStabMono` — `⊡`-monotonicity in TM⁺, the derived rule the modal rows use
- `willImpAllFuture`, `boxAllFutureImpWill`, `willImpWill`,
  `someFutureCouldImpCouldSomeFuture`
- The conservativity of TM⁺ + *Determined* over TM, `detDerivable_ofFormula_iff`, lives in
  `Metalogic/Deterministic/Completeness.lean`, beside the erasure row it specializes

## References

* JPL paper lines 1125-1129 — the defined modals
* `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean` — the rows cited above
* `FormalSystem/Semantics/PlusNonValidities.lean` — the refuted directions

## Tags

conservativity · plus-language · stability-modal · defined-modals
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.PlusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-! ## The composed fragment rows, named per class -/

/-- The H/G-fragment seen from TM⁺, at `.Base`. -/
theorem tmFragIffPlusBase (φ : MinusFormula) :
    TMFrag FrameClass.Base φ ↔ PlusDerivable FrameClass.Base [] (ofFormula (tr φ)) :=
  tmFrag_iff_plus completeness_base φ

/-- The H/G-fragment seen from TM⁺, at `.Dense`. -/
theorem tmFragIffPlusDense (φ : MinusFormula) :
    TMFrag FrameClass.Dense φ ↔ PlusDerivable FrameClass.Dense [] (ofFormula (tr φ)) :=
  tmFrag_iff_plus completeness_dense φ

/-- The H/G-fragment seen from TM⁺, at `.ZTime`. -/
theorem tmFragIffPlusZTime (φ : MinusFormula) :
    TMFrag FrameClass.ZTime φ ↔ PlusDerivable FrameClass.ZTime [] (ofFormula (tr φ)) :=
  tmFrag_iff_plus completeness_ztime φ

/-- The H/G-fragment seen from TM⁺, at `.RTime`. -/
theorem tmFragIffPlusRTime (φ : MinusFormula) :
    TMFrag FrameClass.RTime φ ↔ PlusDerivable FrameClass.RTime [] (ofFormula (tr φ)) :=
  tmFrag_iff_plus completeness_rtime φ

/-! ## Derived rules of TM⁺ at the `Prop` level -/

variable {fc : FrameClass}

/-- Modus ponens in TM⁺, at the `Prop` level. -/
theorem plusMp {φ ψ : PlusFormula} (h1 : PlusDerivable fc [] (φ.imp ψ))
    (h2 : PlusDerivable fc [] φ) : PlusDerivable fc [] ψ :=
  h1.elim fun d1 => h2.elim fun d2 => ⟨.modus_ponens [] φ ψ d1 d2⟩

/-- A TM⁺ axiom instance is a theorem, at any class above its minimum. -/
theorem plusAx {φ : PlusFormula} (h : PlusAxiom φ) (hb : h.minFrameClass ≤ fc) :
    PlusDerivable fc [] φ :=
  ⟨.axiom [] φ h hb⟩

/-- **`⊡`-monotonicity**: a TM⁺ theorem `φ → ψ` yields `⊡φ → ⊡ψ`. The derived `⊡`-necessitation
rule (`PlusLanguage/Derivation.lean`, `stabNecessitation`) followed by `stab_k`. -/
theorem plusStabMono {φ ψ : PlusFormula} (h : PlusDerivable fc [] (φ.imp ψ)) :
    PlusDerivable fc [] ((PlusFormula.stab φ).imp (PlusFormula.stab ψ)) :=
  plusMp (plusAx (PlusAxiom.stab_k φ ψ) (FrameClass.base_le fc))
    (h.elim fun d => ⟨stabNecessitation d⟩)

/-! ## `Gφ → Fφ` on the TM side, and its transfer -/

/--
`⊢ Gφ → Fφ` in TM: from *Seriality* (`⊤ → F⊤`), `G`-distribution and `F`-monotonicity.

The chain is: `Gφ → G(⊤ → φ)` by `gDistribution` off the temporal necessitation of `prop_s`;
`G(⊤ → φ) → (F⊤ → Fφ)` by `fMono`; and `F⊤` by *Seriality*, which discharges the middle
antecedent after `theoremFlip` puts it in front.
-/
noncomputable def allFutureImpSomeFuture (φ : Formula) :
    ⊢[fc] φ.allFuture.imp φ.someFuture := by
  have hTop : ⊢[fc] Formula.top := FormalSystem.Theorems.Combinators.topThm
  have hFTop : ⊢[fc] Formula.top.someFuture :=
    DerivationTree.modus_ponens [] _ _
      (DerivationTree.axiom [] _ Axiom.serial_future (FrameClass.base_le fc)) hTop
  have hMono : ⊢[fc] (Formula.top.imp φ).allFuture.imp
      (Formula.top.someFuture.imp φ.someFuture) :=
    FormalSystem.Theorems.TemporalDerived.fMono Formula.top φ
  have hFlip : ⊢[fc] (((Formula.top.imp φ).allFuture).imp
      (Formula.top.someFuture.imp φ.someFuture)).imp
      (Formula.top.someFuture.imp ((Formula.top.imp φ).allFuture.imp φ.someFuture)) :=
    FormalSystem.Theorems.Combinators.theoremFlip
  have hStep : ⊢[fc] Formula.top.someFuture.imp
      ((Formula.top.imp φ).allFuture.imp φ.someFuture) :=
    DerivationTree.modus_ponens [] _ _ hFlip hMono
  have hRight : ⊢[fc] (Formula.top.imp φ).allFuture.imp φ.someFuture :=
    DerivationTree.modus_ponens [] _ _ hStep hFTop
  have hWeak : ⊢[fc] φ.imp (Formula.top.imp φ) :=
    DerivationTree.axiom [] _ (Axiom.prop_s φ Formula.top) (FrameClass.base_le fc)
  have hGWeak : ⊢[fc] (φ.imp (Formula.top.imp φ)).allFuture :=
    DerivationTree.temporal_necessitation _ hWeak
  have hLeft : ⊢[fc] φ.allFuture.imp (Formula.top.imp φ).allFuture :=
    DerivationTree.modus_ponens [] _ _
      (FormalSystem.Theorems.TemporalDerived.gDistribution φ (Formula.top.imp φ)) hGWeak
  exact FormalSystem.Theorems.Combinators.impTrans hLeft hRight

/-- The reserved atom for the transfer of `allFutureImpSomeFuture` into L⁺. -/
private def transferAtom : Atom := ⟨"tmPlusCorollaries", some 0⟩

/-- `⊢⁺ Gφ → Fφ` at an arbitrary `PlusFormula` argument, by the substitution transfer
(`PlusLanguage/Substitution.lean`) applied to `allFutureImpSomeFuture` at the reserved atom. -/
theorem plusAllFutureImpSomeFuture (φ : PlusFormula) :
    PlusDerivable fc [] ((PlusFormula.allFuture φ).imp (PlusFormula.someFuture φ)) :=
  plusDerivable_substPlus_nil (fun _ => φ)
    ⟨allFutureImpSomeFuture (Formula.atom transferAtom)⟩

/-! ## The logic of the defined modals -/

/-- **`Will φ → Gφ`** (`⊡Gφ → Gφ`): what is settled holds. `stab_t` at `Gφ`. -/
theorem willImpAllFuture (φ : PlusFormula) :
    PlusDerivable fc [] ((PlusFormula.Will φ).imp (PlusFormula.allFuture φ)) :=
  plusAx (PlusAxiom.stab_t (PlusFormula.allFuture φ)) (FrameClass.base_le fc)

/-- **`□Gφ → Will φ`** (`□Gφ → ⊡Gφ`): what is necessary is settled. `box_stab` at `Gφ`; the
converse is refuted (`Semantics/PlusNonValidities.lean`, `refute_stab_box`). -/
theorem boxAllFutureImpWill (φ : PlusFormula) :
    PlusDerivable fc [] ((PlusFormula.box (PlusFormula.allFuture φ)).imp (PlusFormula.Will φ)) :=
  plusAx (PlusAxiom.box_stab (PlusFormula.allFuture φ)) (FrameClass.base_le fc)

/-- **`Will φ → will φ`** (`⊡Gφ → ⊡Fφ`): `⊡`-monotonicity applied to the transferred TM theorem
`Gφ → Fφ`. This is the row that needs both levers — the substitution transfer to state
`Gφ → Fφ` at an L⁺ argument, and `⊡`-monotonicity to push it under the modal. -/
theorem willImpWill (φ : PlusFormula) :
    PlusDerivable fc [] ((PlusFormula.Will φ).imp (PlusFormula.will φ)) :=
  plusStabMono (plusAllFutureImpSomeFuture φ)

/-- **FS, `F(could-witness) → could`** (`F⟐φ⁺ → ⟐Fφ⁺` for pure-future `φ⁺`): the pasting axiom
`untl_paste` at guard `⊤`, whose purity side condition is `IsPurePast.top`. This is the row that
makes `could` behave: a pure-future possibility reachable in the future is a present possibility
of a future truth. -/
theorem someFutureCouldImpCouldSomeFuture {φ : PlusFormula} (hφ : PlusFormula.IsPureFuture φ) :
    PlusDerivable fc []
      ((PlusFormula.someFuture (PlusFormula.dstab φ)).imp
        (PlusFormula.dstab (PlusFormula.someFuture φ))) :=
  plusAx (PlusAxiom.untl_paste PlusFormula.top φ PlusFormula.IsPurePast.top hφ)
    (FrameClass.base_le fc)

end FormalSystem.Metalogic.Conservativity

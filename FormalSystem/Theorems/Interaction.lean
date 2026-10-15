/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Perpetuity
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.TemporalDerived

/-!
# Modal-Temporal Interaction Principles

Hilbert-style interaction principles relating the modal operators `□`/`◇` to the temporal
operators `△`/`▽`, carried over from the twelve further interaction principles the JPL paper's
companion material records under the labels `Pthm:11`--`Pthm:22`. Each principle below carries
its source label in its own docstring.

The source block was cut from the paper for internal redundancy -- several of its items are
restatements or composites of one another -- and redundancy in a paper is not redundancy in a
library: every item here is a distinct, separately citable fact. One of the twelve,
`Pthm:17`, is not restated: it is already proved independently as
`FormalSystem.Theorems.Perpetuity.perpetuity4`, whose docstring carries the cross-reference.

Two auxiliary derivations are factored out because more than one principle consumes them:
`temporalPastDerived`, the general TR mirror of TF, and `boxToAlwaysBox`, which is `Pthm:14`'s
reverse half.

Every declaration in this module is `noncomputable`, because the perpetuity principles it
builds on are. This is a property of the premises, not a limitation of these derivations.

## Main Theorems

### The temporal duality P8 (absent before this module)
- `notSometimesToAlwaysNeg`: `⊢ ¬▽φ → △¬φ`
- `alwaysNegToNotSometimes`: `⊢ △¬φ → ¬▽φ`

### Auxiliary derivations
- `temporalPastDerived`: `⊢ □φ → H□φ` (the general TR mirror of TF)
- `boxToAlwaysBox`: `⊢ □φ → △□φ` (`Pthm:14`'s reverse half, factored out)

### Implications
- `sometimesDiamondToDiamond`: `⊢ ▽◇φ → ◇φ` (`Pthm:11`)
- `alwaysDiamondToDiamond`: `⊢ △◇φ → ◇φ` (`Pthm:12`)
- `diamondAlwaysToDiamond`: `⊢ ◇△φ → ◇φ` (`Pthm:19`)
- `diamondToDiamondSometimes`: `⊢ ◇φ → ◇▽φ` (`Pthm:20`'s forward half)
- `sometimesDiamondToDiamondSometimes`: `⊢ ▽◇φ → ◇▽φ` (`Pthm:21`)
- `diamondSometimesToSometimesDiamond`: `⊢ ◇▽φ → ▽◇φ` (`Pthm:22`)

### Biconditionals collapsing modal-temporal nesting
- `sometimesBoxIffBox`: `⊢ ▽□φ ↔ □φ` (`Pthm:13`)
- `alwaysBoxIffBox`: `⊢ △□φ ↔ □φ` (`Pthm:14`)
- `boxAlwaysIffAlwaysBox`: `⊢ □△φ ↔ △□φ` (`Pthm:15`)
- `boxAlwaysIffBox`: `⊢ □△φ ↔ □φ` (`Pthm:18`)
- `diamondIffDiamondSometimes`: `⊢ ◇φ ↔ ◇▽φ` (`Pthm:20`)
- `diamondSometimesIffSometimesDiamond`: `⊢ ◇▽φ ↔ ▽◇φ` (`Pthm:16`)

## References

* [R. H. Thomason, *Combinations of Tense and Modality*][thomason1984], §4 — interaction
  principles in combined tense-modal systems
* [J. P. Burgess, *Axioms for Tense Logic. I. "Since" and "Until"*][burgess1982], §1.3 — the
  temporal basis the `always`/`sometimes` operators are defined over
* JPL paper `cor:tm-decidability` — the result the source block stood after
* JPL paper `sub:Logic` — where P4, the already-present `Pthm:17`, is stated
* `FormalSystem/Syntax/Formula.lean` — the `always`, `sometimes` and `diamond` encodings these
  derivations turn on
* `FormalSystem/Theorems/Perpetuity/Principles.lean` — P1--P5, `contraposition`, and
  `perpetuity4`, the already-present `Pthm:17`
* `FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean` — P6, the P7 pair
  (`temporalDualityNeg`, `temporalDualityNegRev`), `alwaysMono`, `alwaysToPresent`
* `FormalSystem/Theorems/TemporalDerived.lean` — `presentToSometimes`, and `fNegG`/`pNegH` as
  the precedent for a duality proved by a bare `notNotIntro`
* `FormalSystem/Theorems/ModalS5.lean` — the `iff` connective and `s5DiamondBox`, the modal-only
  collapse biconditional the five biconditionals above are the modal-temporal counterparts of
-/

namespace FormalSystem.Theorems.Interaction

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Perpetuity
open FormalSystem.Theorems.ModalS5 (iff)
open FormalSystem.Theorems.Propositional (doubleNegation iffIntro)
open FormalSystem.Theorems.TemporalDerived (presentToSometimes)

/-! ## The temporal duality P8 -/

/--
P8, forward direction: `⊢ ¬▽φ → △¬φ`.

Under this tree's encoding `sometimes φ = ¬△¬φ`, so `¬▽φ` *is* `¬¬△¬φ` syntactically and the
statement is double negation elimination at `△¬φ`. No temporal reasoning is involved.

The contrast is the P7 pair `temporalDualityNeg` / `temporalDualityNegRev` (`▽¬φ ↔ ¬△φ`), which
needs real work precisely because its `always` sits *outside* the negation, so double negation
has to be lifted through `H`, `G` and the present. The precedent for a duality that collapses
the way this one does is `fNegG` / `pNegH`, each a bare `notNotIntro` with a docstring saying
why.

This is why the pair is sited here rather than beside P7: its proof term is computable, and
`MonotonicityDuality.lean` states the P7 pair inside a long `noncomputable section`.
-/
noncomputable def notSometimesToAlwaysNeg {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.sometimes.neg.imp φ.neg.always :=
  doubleNegation (φ.neg.always)

/--
P8, reverse direction: `⊢ △¬φ → ¬▽φ`.

The mirror of `notSometimesToAlwaysNeg`: definitionally this is double negation introduction at
`△¬φ`, since `¬▽φ` is `¬¬△¬φ`. The same contrast with the P7 pair
(`temporalDualityNeg` / `temporalDualityNegRev`) and the same precedent (`fNegG` / `pNegH`)
apply, and are the reason for siting the pair here rather than beside P7.
-/
noncomputable def alwaysNegToNotSometimes {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.neg.always.imp φ.sometimes.neg :=
  notNotIntro (φ.neg.always)

/-! ## Auxiliary derivations -/

/--
The general TR mirror of TF: `⊢ □φ → H□φ`.

TF is `temporalFutureDerived : ⊢ □φ → G□φ`. Its past mirror is obtained by instantiating TF at
`reflectTime φ`, applying the time-reflection rule, and simplifying the reflection away. The
proof shape is `boxToPast`'s, including its `simp only` step over `Formula.reflectTime`,
`Formula.reflect_time_all_future` and `Formula.reflect_time_involution`.

Before this declaration the tree carried this shape only *instantiated at the diamond*, as
`boxDiamondToPastBoxDiamond`; the general version is what `boxToAlwaysBox` needs. It does not
collide with `boxToPast`, which proves the different statement `⊢ □φ → Hφ`.
-/
noncomputable def temporalPastDerived {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.box.imp φ.box.allPast := by
  have tf : ⊢[fc] φ.reflectTime.box.imp φ.reflectTime.box.allFuture :=
    temporalFutureDerived φ.reflectTime
  have td : ⊢[fc] (φ.reflectTime.box.imp φ.reflectTime.box.allFuture).reflectTime :=
    DerivationTree.time_reflection _ tf
  simp only [Formula.reflectTime, Formula.reflect_time_all_future,
    Formula.reflect_time_involution] at td
  exact td

/--
Necessity is always necessary: `⊢ □φ → △□φ`.

This **is** `Pthm:14`'s reverse half, factored out as its own declaration because `Pthm:11` and
`Pthm:15` also consume it. Since `△ψ = Hψ ∧ (ψ ∧ Gψ)`, the three components are exactly the
three the source's own `Pthm:14` derivation invokes -- identity, TF, and TR applied to TF --
assembled with `combineImpConj3`.
-/
noncomputable def boxToAlwaysBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.box.imp φ.box.always :=
  combineImpConj3 (temporalPastDerived φ) (identity φ.box) (temporalFutureDerived φ)

end FormalSystem.Theorems.Interaction

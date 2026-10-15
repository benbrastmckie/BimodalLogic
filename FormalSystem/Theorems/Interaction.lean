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

/-! ## The interaction principles

The declarations below follow the source block's own numbering. Six of them are biconditionals
collapsing a nesting of a modal operator with a temporal one (`Pthm:13`, `Pthm:14`, `Pthm:15`,
`Pthm:18`, `Pthm:20`, `Pthm:16`). Those are the modal-temporal counterparts of the modal-only
collapse biconditionals `ModalS5.s5DiamondBox` and `ModalS4.s4DiamondBoxDiamond`, and like those
they are recorded for their own sake.

They are *not* rewrite lemmas and no mechanism in this tree can consume them as such: each is a
derivability fact `⊢[fc] iff A B`, not an identity of `Formula`s, and the `@[formula_unfold]` /
`@[formula_fold]` sets in `FormalSystem/Automation/Normalization.lean` hold only `rfl`-level
`Formula` identities. Nothing is claimed about a rewriting consumer here, because there is none.
-/

/--
`Pthm:11`: `⊢ ▽◇φ → ◇φ`. If possibly-`φ` holds at some time, then possibly-`φ` holds now.

Proved through its own contrapositive, which the encoding makes the short route. Since `¬◇φ` is
`¬¬□¬φ`, `doubleNegation` takes it to `□¬φ`; `boxToAlwaysBox` at `¬φ` takes that to `△□¬φ`; and
`alwaysMono (notNotIntro φ.neg.box)` takes that to `△¬◇φ`. Contraposing and discharging the
outer double negation with `doubleNegation φ.diamond` gives the statement.

The source derives this from TF, TR applied to TF, and contraposition, with a case split on the
three disjuncts of its own disjunctive reading of `▽`. This tree defines `▽φ = ¬△¬φ`, so there
are no disjuncts to split on; the three components the source invokes are exactly the three
`boxToAlwaysBox` packages, which is why the dependency on `Pthm:14`'s reverse half appears here
where the source has the two items independent. The repackaging is faithful, not a shortcut.
-/
noncomputable def sometimesDiamondToDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.sometimes.imp φ.diamond :=
  impTrans (contraposition (impTrans (doubleNegation φ.neg.box)
    (impTrans (boxToAlwaysBox φ.neg) (alwaysMono (notNotIntro φ.neg.box)))))
    (doubleNegation φ.diamond)

/--
`Pthm:12`: `⊢ △◇φ → ◇φ`. What is always possible is possible now.

Conjunction elimination on `△`, which is `alwaysToPresent` instantiated at `◇φ` -- the same
single step the source takes.
-/
noncomputable def alwaysDiamondToDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.always.imp φ.diamond :=
  alwaysToPresent φ.diamond

/--
`Pthm:13`: `⊢ ▽□φ ↔ □φ`.

Forward: P6 (`perpetuity6 : ▽□φ → □△φ`) composed with `boxMono (alwaysToPresent φ)`, which is
the source's P6-then-MN+MK-on-`△φ → φ` step. Reverse: `presentToSometimes` at `□φ`, standing in
for the source's disjunction introduction on its disjunctive reading of `▽`.

A collapse biconditional; see the section note above for what is and is not claimed of those.
-/
noncomputable def sometimesBoxIffBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.box.sometimes φ.box :=
  iffIntro _ _ (impTrans (perpetuity6 φ) (boxMono (alwaysToPresent φ)))
    (presentToSometimes φ.box)

/--
`Pthm:14`: `⊢ △□φ ↔ □φ`.

Forward: conjunction elimination on `△`, i.e. `alwaysToPresent` at `□φ`. Reverse:
`boxToAlwaysBox`, which is this half factored out as its own declaration because `Pthm:11` and
`Pthm:15` also consume it; its three components are the identity, TF and TR-applied-to-TF that
the source's own reverse derivation invokes.

A collapse biconditional; see the section note above for what is and is not claimed of those.
-/
noncomputable def alwaysBoxIffBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.box.always φ.box :=
  iffIntro _ _ (alwaysToPresent φ.box) (boxToAlwaysBox φ)

/--
`Pthm:15`: `⊢ □△φ ↔ △□φ`. Necessity and `always` commute.

Forward: `boxMono (alwaysToPresent φ)` -- the source's MN+MK step -- composed with
`boxToAlwaysBox`, which is `Pthm:14`'s reverse half. Reverse: `alwaysToPresent` at `□φ` --
`Pthm:14`'s forward half -- composed with P3 (`perpetuity3 : □φ → □△φ`), which is the source's
own routing.

A collapse biconditional; see the section note above for what is and is not claimed of those.
-/
noncomputable def boxAlwaysIffAlwaysBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.always.box φ.box.always :=
  iffIntro _ _ (impTrans (boxMono (alwaysToPresent φ)) (boxToAlwaysBox φ))
    (impTrans (alwaysToPresent φ.box) (perpetuity3 φ))

/--
`Pthm:18`: `⊢ □△φ ↔ □φ`.

By the source's **direct** derivation, not by composition. Forward: `boxMono
(alwaysToPresent φ)`, the source's MN+MK step. Reverse: P1 under a box, reached through
`DerivedAxioms.modal4 : □φ → □□φ` and then `boxMono (perpetuity1 φ)` -- the source's
"P1, MN+MK, then MT+M5+MK for `□φ → □□φ`".

Two observations the derivation does not use. The block's header note records that this also
follows from `Pthm:15` together with `Pthm:14`; that is a redundancy remark about the block, not
the source's proof of this item, so it is not the route taken here. And the reverse half is
extensionally `perpetuity3`, whose own proof is the same `modal4`-then-`boxMono (perpetuity1 …)`
composition; writing the composition out keeps the correspondence with the source's steps
visible.

A collapse biconditional; see the section note above for what is and is not claimed of those.
-/
noncomputable def boxAlwaysIffBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.always.box φ.box :=
  iffIntro _ _ (boxMono (alwaysToPresent φ))
    (impTrans (DerivedAxioms.modal4 φ) (boxMono (perpetuity1 φ)))

/--
`Pthm:19`: `⊢ ◇△φ → ◇φ`. If it is possible that `φ` always holds, then `φ` is possible.

`diamondMono` applied to `alwaysToPresent φ`. The source writes this as contraposition, MN+MK,
contraposition; `diamondMono` is exactly that composition, already named in this tree.
-/
noncomputable def diamondAlwaysToDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.always.diamond.imp φ.diamond :=
  diamondMono (alwaysToPresent φ)

/--
`Pthm:20`'s forward half: `⊢ ◇φ → ◇▽φ`.

Named as its own declaration because `Pthm:21` consumes it, and projecting it out of the
`.and`-shaped biconditional `diamondIffDiamondSometimes` would need a conjunction-elimination
step that hides the dependency.

Proved by contraposing `□¬▽φ → □¬φ`, which is `boxMono` applied to P8 forward
(`notSometimesToAlwaysNeg`) composed with `boxMono (alwaysToPresent φ.neg)`.
-/
noncomputable def diamondToDiamondSometimes {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.imp φ.sometimes.diamond :=
  contraposition (impTrans (boxMono (notSometimesToAlwaysNeg φ))
    (boxMono (alwaysToPresent φ.neg)))

/--
`Pthm:20`: `⊢ ◇φ ↔ ◇▽φ`.

Pairs `diamondToDiamondSometimes`, the forward half named above, with `perpetuity4` for the
reverse. The reverse half is therefore not restated: `perpetuity4` already proves it
independently, and it is `Pthm:17` of the same block.

A collapse biconditional; see the section note above for what is and is not claimed of those.
-/
noncomputable def diamondIffDiamondSometimes {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.diamond φ.sometimes.diamond :=
  iffIntro _ _ (diamondToDiamondSometimes φ) (perpetuity4 φ)

/--
`Pthm:21`: `⊢ ▽◇φ → ◇▽φ`.

Taken from its siblings inside the block rather than re-proved from the axioms, exactly as the
source takes it: `sometimesDiamondToDiamond` (`Pthm:11`) composed with
`diamondToDiamondSometimes` (`Pthm:20`'s forward half).
-/
noncomputable def sometimesDiamondToDiamondSometimes {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.sometimes.imp φ.sometimes.diamond :=
  impTrans (sometimesDiamondToDiamond φ) (diamondToDiamondSometimes φ)

/--
`Pthm:22`: `⊢ ◇▽φ → ▽◇φ`.

Through P5 (`perpetuity5 : ◇▽φ → △◇φ`), as the source routes it: P5, then conjunction
elimination (`alwaysToPresent` at `◇φ`), then the step from the present to `▽`, which this tree
already has as `presentToSometimes`. The source's last step appeals to disjunction introduction
on its disjunctive reading of `▽`; `presentToSometimes` is that step under the `▽φ = ¬△¬φ`
encoding, and is itself derived the same contrapositive way.
-/
noncomputable def diamondSometimesToSometimesDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.sometimes.diamond.imp φ.diamond.sometimes :=
  impTrans (perpetuity5 φ)
    (impTrans (alwaysToPresent φ.diamond) (presentToSometimes φ.diamond))

/--
`Pthm:16`: `⊢ ◇▽φ ↔ ▽◇φ`. The modal and temporal possibility operators commute.

By the source's own route, which runs through P8, `Pthm:15` at `¬φ`, and P7 at `□¬φ`. Forward:
`alwaysToPresent φ.neg.box` and P3 at `¬φ` give `Pthm:15`'s content at the negation, `boxMono`
of P8 reverse (`alwaysNegToNotSometimes`) bridges to `□¬▽φ`, and contraposing lands in the
scope of P7 reverse (`temporalDualityNegRev`). Reverse: P7 forward (`temporalDualityNeg`) then
the contrapositive of `boxMono` of P8 forward composed with `boxMono (alwaysToPresent φ.neg)`
and `boxToAlwaysBox` at `¬φ`.

An equally valid and shorter route is `iffIntro` of `diamondSometimesToSometimesDiamond`
(`Pthm:22`) with `sometimesDiamondToDiamondSometimes` (`Pthm:21`); it was verified to compile
and is not used, because the source's route is the only consumer of `Pthm:15` and of the P7
pair in the whole block, and taking the shortcut would leave `Pthm:15` consumed by nothing.

A collapse biconditional; see the section note above for what is and is not claimed of those.
-/
noncomputable def diamondSometimesIffSometimesDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.sometimes.diamond φ.diamond.sometimes :=
  iffIntro _ _
    (impTrans
      (contraposition (impTrans (impTrans (alwaysToPresent φ.neg.box) (perpetuity3 φ.neg))
        (boxMono (alwaysNegToNotSometimes φ))))
      (temporalDualityNegRev φ.neg.box))
    (impTrans (temporalDualityNeg φ.neg.box)
      (contraposition (impTrans (boxMono (notSometimesToAlwaysNeg φ))
        (impTrans (boxMono (alwaysToPresent φ.neg)) (boxToAlwaysBox φ.neg)))))

end FormalSystem.Theorems.Interaction

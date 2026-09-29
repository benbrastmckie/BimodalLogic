/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Closure
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Basic
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Predicates
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Decide
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Fulfil
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Agreement
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Incompleteness

/-!
# `FormalSystem.Metalogic.Decidability.PlusWitnessFamily` — the L⁺ certificate

The L⁺-indexed twin of `WitnessFamily/`, existing for one reason: the **stability condition**
(C5) `StabFaithful` is not stateable over `Formula`.

`Syntax.Formula` has exactly six constructors — `atom`, `bot`, `imp`, `box`, `untl`, `snce` —
and no stability modal. `⊡` is `PlusLanguage.PlusFormula.stab`, a constructor of a *separate*
inductive sharing no supertype with `Formula`, so no instantiation and no coercion states (C5)
over the existing certificate: `Context`, `closureOf`, `WitnessFamily` and its `bx` field are
monomorphic in `Formula` at every level. This subtree re-indexes that stack over `PlusFormula`
and states (C5) natively.

## What is new here, and what is inherited

Almost all of the branching *substrate* is inherited rather than rebuilt. `SharingSkeleton`
(`WitnessFamily/Sharing/Skeleton.lean`) carries the per-time equivalence `share`, the threads,
the quotient frame and its world histories, and mentions no formula; `SharingWindow`
(`WitnessFamily/Sharing/Window.lean`) adds the combined window and the whole position graph, and
mentions no formula either. Both are consumed here through projections, not copied.

What is genuinely new is everything that reads a label: the L⁺ subformula closure, the L⁺
lassos and families, the six conditions, their decision procedures, and the agreement theorem's
seventh case.

## The deterministic export contract is untouched

Nothing in this subtree edits `WitnessFamily/`, `Semantics/ShiftSet.lean`, or any part of the
deterministic bi-lasso device the model checker ships against. `PlusRefutes` is declared
**beside** `WitnessFamily.Refutes`, not in place of it: the two quantify over different truth
predicates because they are about different languages, and no consumer of the deterministic
interface is affected by this one's existence.

## Submodules

- `PlusWitnessFamily.Closure`: `plusSubformulaClosure`, `plusClosureOf` and the seven
  constructor-projection lemmas the agreement induction consumes
- `PlusWitnessFamily.Basic`: `PlusLabelledLasso`, `PlusWitnessFamily`,
  `PlusSharingWitnessFamily`, and the projections onto `SharingSkeleton`
- `PlusWitnessFamily.Predicates`: the six conditions — (C0) `PlusAtomCoherent`, (C1')
  `PlusLocalCoherentShare`, (C2') `PlusThreadFulfilling`, (C3) `PlusBoxFaithful`, (C4)
  `PlusTarget`, and **(C5) `StabFaithful`**
- `PlusWitnessFamily.Decide`: the combined window, the `window` projection onto `SharingWindow`,
  and the decision procedures for (C0), (C1'), (C5), (C3) and (C4)
- `PlusWitnessFamily.Fulfil`: the `A[g U e]` fixpoints at `PlusFormula` and the (C2') window
  reduction, giving `decidablePlusCoherentShareAndFulfilling`
- `PlusWitnessFamily.Agreement`: the presented model, `plusTruth_iff_mem` (all seven cases),
  the six-component `PlusCertifies` bundle and `plusRefutes_of_certifies`
- `PlusWitnessFamily.Examples`: the two-lasso non-vacuity witness, `stabFamily_separates` and
  `stabFaithful_diagonal`
- `PlusWitnessFamily.Incompleteness`: the three stability targets and the two theorems making
  them genuine ℤ-time non-validities. The five declarations that once recorded the certificate
  class as empty for a `snce` under a `⊡` were retired when the `trans` substrate landed; see
  that module's header.

## Why (C5) is a pinned obligation rather than a signature

`plusTruth_iff_mem`'s `stab` case consumes `StabFaithful` and cannot be written without it, and
`PlusCertifies` carries it as one of six *checked* components rather than as a hypothesis the
checker never evaluates. `Examples.lean` then exhibits a family on which the condition has
content: two lassos sharing a state at one time and separate everywhere else, so the condition is
not degenerate. On a deterministic frame it would be — `PlusLanguage.stab_iff_of_deterministic`
collapses `⊡φ` to `φ` — which is exactly why the branching substrate is the one this lives on.

## The certificate class is empty for a tense operator under a `⊡`, on both sides

Soundness is only half the story, and `Incompleteness.lean` records the other half: no family
meeting the six conditions certifies any instance of `(g S e) → ⊡(g S e)`, nor `Fp → (¬p → ⊡Fp)`,
while both targets are genuine ℤ-time non-validities. (C1')'s `snce` clause quantifies its
predecessor over the `share`-class at the label's *own* time, which forces the class to agree on
every past-tense label; its `untl` clause quantifies its successor over the class at `t+1`, which
displaces the same collapse by one step rather than avoiding it, as reading that clause at `t-1`
shows. (C5) then has no room to put the stability modal outside a label that carries the tense
formula. So the L⁺ analogue of the deterministic route's
`exists_witnessFamily_of_not_validZTime` is **false** against this condition set, and the repair
is at the substrate level rather than in a re-wording — or a re-timing — of (C1').
-/

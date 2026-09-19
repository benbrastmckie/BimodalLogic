/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.LimitClosureCountermodel

/-!
# The current axiom set of TM⁺ is incomplete at `.Base`

The limit-closure formula

```
blc p  :=  (⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))
```

is valid over every task frame and is not a `.Base` theorem of TM⁺. The two halves are
`blc_plusValid` (`Semantics/PlusLanguage/PlusLimitClosure.lean`: Zorn plus the Extension Theorem)
and `blc_not_plusDerivable_base` (`Metalogic/Independence/LimitClosureCountermodel.lean`: a
paste-closed coarsened-state model refuting it). This module only assembles them.

## What is shown, and what is not

* **Shown.** The axiom set of TM⁺ *as it stands* (`PlusAxiom`) is incomplete for the
  all-histories task semantics at `.Base`: `plus_incomplete_base`. Equivalently, the hypothesis
  of the conditional theorem `Conservativity.starConservative_of_plusComplete` is false at
  `.Base`: `not_plus_complete_base` is that hypothesis, negated, verbatim.
* **Not shown.** Nothing is claimed about any *extension* of the axiom set: whether some
  recursive extension of TM⁺ is complete is open at every frame class. Nothing is claimed at
  `.Dense`, `.ZTime` or `.RTime`: the formula is valid there too (validity at `.Base` is validity
  everywhere), but non-derivability at a larger class is a stronger statement and is not proved
  here. And nothing is decided about conservativity of TM⋆ over TM⁺: incompleteness refutes the
  *hypothesis* of the conditional, which makes the conditional vacuous at `.Base` without
  producing a separating witness.

## Consistency check

Under `⊡ = id` the formula reduces to `(Fp ∧ G(p → Fp)) → (Fp ∧ G(p → Fp))`, so it is a theorem
of TM⁺ extended by *Determined*, in agreement with the deterministic completeness theorem
(`Metalogic/Deterministic/Completeness.lean`). The countermodel is therefore necessarily
nondeterministic, and it is: the hub of the frame `EF` reaches every state.

## The one-line reading

The coarsened countermodel is a dense, non-closed bundle. PS and US say the bundle of histories
is paste-closed, MF says it is translation-closed, and nothing in TM⁺ says it is closed.

## Main Results

- `plus_incomplete_base` — `PlusValid (blc p) ∧ ¬ PlusDerivable FrameClass.Base [] (blc p)`
- `not_plus_complete_base` — not every `.Base`-valid formula of L⁺ is a `.Base` theorem of TM⁺

## References

* Thomason, *Combinations of Tense and Modality* (1984), §4, formulas (19) (Burgess) and (20)
  (Thomason) — the Ockhamist-valid, Kamp-invalid formulas of which `blc` is the transposition to
  the stability modal
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/--
**TM⁺ is incomplete at `.Base`.** The limit-closure formula `blc p` is valid over every task
frame and is not derivable in TM⁺ at `.Base` from the empty context.

Paper: — (formalization-native)
-/
theorem plus_incomplete_base (p : Atom) :
    PlusValid (blc p) ∧ ¬ PlusDerivable FrameClass.Base [] (blc p) :=
  ⟨blc_plusValid p, blc_not_plusDerivable_base p⟩

/--
The hypothesis of `Conservativity.starConservative_of_plusComplete` at `.Base`, refuted. This is
a statement about the current axiom set only; see the module docstring for what it does not say.
-/
theorem not_plus_complete_base :
    ¬ ∀ ψ : PlusFormula, PlusValidIn FrameClass.Base ψ → PlusDerivable FrameClass.Base [] ψ :=
  fun h =>
    let p : Atom := ⟨"p", none⟩
    (plus_incomplete_base p).2 (h (blc p) (plus_incomplete_base p).1)

end FormalSystem.Metalogic.Independence

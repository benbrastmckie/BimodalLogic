/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity

/-!
# Semantic Validity of the Paper's Event-Operator Negation Equivalence

`def:event-operators` defines three operators in BL, of which `After` is the one with a
next-time reading:

  `After(φ,ψ) := ¬φ U (φ ∧ ψ)`

so that `After(φ,⊤) = ¬φ U φ` says there is a next `φ`-time. `lem:after-negation` states that

  `After(φ,⊤) → (¬After(φ,ψ) ↔ After(φ,¬ψ))`

is valid over every task frame. This module carries that validity as
`after_negation_valid : Valid …`.

## Why this file exists

`Formula.after` is a **derived** operator, not an `Axiom` constructor, so `after_negation_valid`
is not a soundness case — nothing in the soundness induction consumes it. It is an independent
semantic result about the event operators, filed beside `co_valid` because it is the same kind of
object: the validity of a schema in the derived operators, checked directly against the truth
definition rather than obtained from a derivation. The file sits here, under `SoundnessLemmas/`,
on exactly the `CoValidity.lean` precedent.

## Proof shape

No mathematics happens in this file. The argument is proved once, language-generically, in
`FormalSystem/Semantics/TruthClauses.lean`'s `After` tier: `isNextTime_unique` says any two next
`φ`-times after `t` coincide (the earlier would lie strictly inside the later's open interval,
where its own clause forbids `φ`), `after_top_iff` reads the guard as the existence of such a
`z`, `after_iff_of_isNextTime` collapses `After(φ,χ)` to `χ` at that `z`, and `after_negation`
is the resulting pointwise biconditional. This module instantiates `after_negation` at `L :=
Formula` and wraps it in `Valid`'s binder shape. The L⁺ companions — both readings of the cut
`cor:after-negation-stable` — instantiate the same generic lemma, in
`FormalSystem/PlusLanguage/PlusValidity.lean`.

`Formula` has no `iff` constructor, so the biconditional is written in the house encoding
`(A.imp B).and (B.imp A)`.

## Main results

- `after_negation_valid`: `Valid (After(φ,⊤) → (¬After(φ,ψ) ↔ After(φ,¬ψ)))`.

## Position in the Layering

Imports `Semantics/Validity.lean` and nothing else; consumed through the `SoundnessLemmas`
aggregator. Independent of every completeness route.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Syntax
open FormalSystem.Semantics

/--
**`lem:after-negation`** as an L validity over every task frame:

  `⊨  After(φ,⊤) → (¬After(φ,ψ) ↔ After(φ,¬ψ))`

with the biconditional in the house encoding `(A.imp B).and (B.imp A)`, since `Formula` carries
no `iff` constructor.

The guard is what makes the equivalence hold: without `After(φ,⊤)` there may be no next
`φ`-time at all, and then `After(φ,ψ)` and `After(φ,¬ψ)` both fail. Under the guard the next
`φ`-time is unique (`TruthClauses.isNextTime_unique`), so both sides read `ψ` at one and the same
point and the equivalence is just `¬P ↔ ¬P`.

No frame condition is consumed — the binder is the bare `Valid.of_forall` one, not its
`IsRegular` variant — and the only order-theoretic input is linearity of `F.Duration`.
-/
theorem after_negation_valid (φ ψ : Formula) :
    Valid ((Formula.after φ Formula.top).imp
      ((((Formula.after φ ψ).neg).imp (Formula.after φ ψ.neg)).and
        ((Formula.after φ ψ.neg).imp ((Formula.after φ ψ).neg)))) := by
  refine Valid.of_forall fun F M τ t => ?_
  rw [Truth.imp_iff]
  intro hg
  have hbi := TruthClauses.after_negation (L := Formula) M τ t PUnit.unit φ ψ hg
  rw [Truth.and_iff, Truth.imp_iff, Truth.imp_iff]
  exact ⟨fun h => hbi.mp ((Truth.neg_iff _).mp h),
    fun h => (Truth.neg_iff _).mpr (hbi.mpr h)⟩

end FormalSystem.Metalogic.SoundnessLemmas

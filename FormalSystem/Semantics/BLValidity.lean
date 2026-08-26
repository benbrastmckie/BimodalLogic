/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.BLTruth
import FormalSystem.Semantics.Validity

/-!
# BL validity — the base-language mirrors of `Semantics/Validity.lean`

Validity and semantic consequence for the tense-primitive base language BL, stated against the
native `BLTruthAt` of `Semantics/BLTruth.lean`.

Each predicate here is a **binder-for-binder mirror** of its counterpart in
`Semantics/Validity.lean`: `BLValid` of `valid`, `BLValidDense` of `ValidDense`,
`BLValidDiscrete` of `ValidDiscrete`, `BLValidDedekindDense` of `ValidDedekindDense`, and
`BLSemanticConsequence` of `SemanticConsequence`. Nothing changes but `Formula ↦ BLFormula` and
`TruthAt ↦ BLTruthAt`; in particular the histories quantified over are the **total** ones
(`τ.IsTotal`, the predicate form of `H_F`), matching `def:logical-consequence`, and `Type` rather
than `Type*` is used throughout for the same universe reason recorded on `valid`.

## The Dedekind asymmetry — read this before adding a `BLValidDedekind`

There is deliberately **no** density-free `BLValidDedekind`, and the soundness theorem for
`FrameClass.Dedekind` targets `BLValidDedekindDense`. A density-free target would be
**refutable**, and on the BL side one axiom suffices to refute it:

- `(BaseLanguage.Axiom.dn φ).minFrameClass = FrameClass.Dense` and
  `FrameClass.Dense ≤ FrameClass.Dedekind` (pinned by an `example` in
  `FormalSystem/BaseLanguage/Axioms.lean`), so `dn` — the density axiom `GGφ → Gφ` — is
  admissible in any `FrameClass.Dedekind` BL derivation.
- `dn` is false on `ℤ`: take `φ` true exactly at the times `≥ t + 2`. Then `GGφ` holds at `t`
  while `Gφ` fails at `t`, because `t + 1` is strictly future and `φ` is false there.
- `ℤ` satisfies every binder of a density-free `BLValidDedekind` — it is Dedekind-complete
  (Mathlib's `ConditionallyCompleteLinearOrder ℤ`) — so the refutation lands.

Adding `[DenselyOrdered D]` deletes exactly the `ℤ` branch of the Hölder dichotomy and nothing
else (`Semantics/DurationClassification.lean`). This is the BL-native form of the argument
`Semantics/Validity.lean` records for `ValidDedekind` on the BL⁺ side; note that BL⁺'s version
additionally leans on `Axiom.dense_indicator` (`¬(⊥ U ⊤)`), which has no BL counterpart at all
since BL has no `untl`. Do not "simplify" the target.

## Main Definitions

- `BLValid`, `BLSemanticConsequence` — validity and consequence over the `FrameClass.Base` binder
  set
- `BLValidDense`, `BLValidDiscrete`, `BLValidDedekindDense` — the three extension binder sets

## Main Results

- `BLValidity.blValid_implies_blValidDense`, `…_blValidDiscrete`, `…_blValidDedekindDense` — the
  inclusion lemmas mirroring `Validity.valid_implies_valid_dense` and its siblings
- `BLValidity.blValid_iff_empty_consequence` — validity is consequence from the empty context

## References

* JPL paper `\S sub:Logic` — `def:BL-semantics`, `def:logical-consequence`
* `FormalSystem/Semantics/Validity.lean` — the BL⁺ predicates these mirror
* `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — the soundness theorems targeting these
-/

namespace FormalSystem.Semantics

open FormalSystem.BaseLanguage

/--
A base-language formula is **valid** if it is true in all models, at all times, at every
**total** history, for every temporal type `D` satisfying the ordered-group binder set.

Binder-for-binder mirror of `Semantics.valid`; see `def:logical-consequence`, whose "possible
worlds tau in H_F" are the total histories that `τ.IsTotal` picks out.

Uses `Type` (not `Type*`) to avoid universe-level issues in proofs, as `valid` does.
-/
def BLValid (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    BLTruthAt M τ t φ

/--
Semantic consequence in the base language: `φ` is true at every model, **total** history and time
at which every formula of `Γ` is true.

Binder-for-binder mirror of `Semantics.SemanticConsequence`.
-/
def BLSemanticConsequence (Γ : BaseLanguage.Context) (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, BLTruthAt M τ t ψ) →
    BLTruthAt M τ t φ

/--
Validity over **dense** temporal orders: `BLValid` with `[DenselyOrdered D]` added to the binder
list, capturing the frame condition for BL's density axiom `dn` (`GGφ → Gφ`).

Binder-for-binder mirror of `Semantics.ValidDense`.
-/
def BLValidDense (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    BLTruthAt M τ t φ

/--
Validity over **discrete** temporal orders: `BLValid` with successor and predecessor structure
added to the binder list, capturing the frame condition for BL's discreteness axioms.

Binder-for-binder mirror of `Semantics.ValidDiscrete`.
-/
def BLValidDiscrete (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    BLTruthAt M τ t φ

/--
Validity over **dense Dedekind-complete** temporal orders: the least-upper-bound hypothesis
together with `[DenselyOrdered D]`.

Binder-for-binder mirror of `Semantics.ValidDedekindDense`, and **this — not a density-free
`BLValidDedekind` — is the target of the `FrameClass.Dedekind` soundness theorem.** The module
docstring above gives the BL-native refutation of the density-free form: `Axiom.dn` is admissible
at `FrameClass.Dedekind` and is false on `ℤ`, which satisfies every remaining binder. There is
deliberately no `BLValidDedekind` in this file.
-/
def BLValidDedekindDense (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    BLTruthAt M τ t φ

namespace BLValidity

/-! ### Inclusion lemmas

Mirrors of `Validity.valid_implies_valid_dense` and its siblings. Each simply discards the extra
binders: `BLValid` already quantifies over every `D` meeting the weaker binder set.

Two members of the BL⁺ family have no mirror here, both for the same reason: they mention
`ValidDedekind`, whose BL counterpart is deliberately not defined (see the module docstring).
Those are `Validity.valid_implies_validDedekind` and
`Validity.validDedekindDense_of_validDedekind`. -/

/-- Validity implies validity over dense orders. -/
theorem blValid_implies_blValidDense {φ : BLFormula} (h : BLValid φ) : BLValidDense φ :=
  fun D _ _ _ _ _ F M τ hτ t => h D F M τ hτ t

/-- Validity implies validity over discrete orders. -/
theorem blValid_implies_blValidDiscrete {φ : BLFormula} (h : BLValid φ) : BLValidDiscrete φ :=
  fun D _ _ _ _ _ _ _ _ F M τ hτ t => h D F M τ hτ t

/-- Validity implies validity over dense Dedekind-complete orders. The least-upper-bound
hypothesis is simply discarded. -/
theorem blValid_implies_blValidDedekindDense {φ : BLFormula} (h : BLValid φ) :
    BLValidDedekindDense φ :=
  fun D _ _ _ _ _ _ F M τ hτ t => h D F M τ hτ t

/-- Validity is consequence from the empty context. Mirrors
`Validity.valid_iff_empty_consequence`. -/
theorem blValid_iff_empty_consequence (φ : BLFormula) :
    BLValid φ ↔ BLSemanticConsequence [] φ := by
  constructor
  · intro h D _ _ _ _ F M τ hτ t _
    exact h D F M τ hτ t
  · intro h D _ _ _ _ F M τ hτ t
    exact h D F M τ hτ t (by intro ψ hψ; exact absurd hψ List.not_mem_nil)

end BLValidity

end FormalSystem.Semantics

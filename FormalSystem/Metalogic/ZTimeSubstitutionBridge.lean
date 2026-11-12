/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.StrongCompleteness
import FormalSystem.PlusLanguage.Substitution
import FormalSystem.Semantics.IntTransfer
import FormalSystem.Metalogic.Expressiveness.Separation.Defs

/-!
# From ℤ-time validity to TM⁺ theoremhood at every substitution

This module lands a two-step bridge. Step one is `completeness_ztime`
(`Metalogic/StrongCompleteness.lean`): a `ValidZTime` L formula is a TM theorem at
`FrameClass.ZTime`. Step two is `plusDerivable_substPlus_nil`
(`PlusLanguage/Substitution.lean`), which runs `PlusDerivationTree.ofTMSubst` over that TM
derivation: a TM theorem becomes a TM⁺ theorem at arbitrary L⁺ arguments. Composing them gives
`plusDerivable_substPlus_of_validZTime` — the bridge — and, over the linear fragment,
`plusDerivable_substPlus_of_boxFree_intTruth`.

The linear input side is the `IntStructure`/`IntTruth` pair of
`Metalogic/Expressiveness/Separation/Defs.lean`: an `IntStructure` is a valuation `Atom → Set ℤ`,
i.e. a bi-infinite Z-word, and `IntTruth` evaluates a `Formula` at an integer time on it.
`wordOf` reads such a word off a task model and a world history over the carrier `ℤ`, and
`truthAt_iff_intTruth_of_boxFree` says box-free truth is a datum of that word alone. Chaining
that through `validZTime_iff_validInt` turns "true on every bi-infinite Z-word" into `ValidZTime`.

## The box-free hypothesis is load-bearing and may never be weakened

`IntTruth`'s `box` arm is deliberately degenerate — it returns `True` for every argument, because
the modal component is irrelevant to the separation results that semantics was introduced for.
So `isBoxFree φ = true` on `validZTime_of_boxFree_intTruth` and on
`plusDerivable_substPlus_of_boxFree_intTruth` is not cosmetic: without it the statement is
outright false. `□⊥` is the witness. `IntTruth W t (□⊥)` unfolds to `True` and so holds on every
word at every time, whereas `TruthAt M τ t (□⊥)` unfolds to `∀ σ : WorldHistory F, False`, which
no model satisfies — `□⊥` is therefore not `ValidZTime`. The degenerate arm makes `IntTruth`
validate formulas `TruthAt` refutes, so the hypothesis may **never** be weakened, defaulted, or
discharged by a `simp` lemma; a declaration of this shape that drops it is unsound, not merely
stronger.

## The ω-word / Z-word asymmetry

Reynolds' `⊢_L` is PLTL over one-sided ω-sequences, with `G` and `X` as primitives, and his use
of PLTL completeness inside the CTL* argument quotes linear validities over those sequences. This
bridge runs `completeness_ztime` over **two-sided** bi-infinite Z-words, with `U` and `S` as
primitives and no least time. That asymmetry is the whole point of the transposition, not an
incidental difference of presentation, so this module is not "the PLTL bridge" and must not be
described as one: there is no ω-word semantics in this tree and none is introduced here.

This module is **not** a formalization of any part of [reynolds2001] §§7–15 — not the two-sided
chronicle, ban preservation, lulls or hue scheduling, universal non-acceptance, the two-sided
truth lemma, or the final-frame assembly. It is the generic import route an argument of that
shape would consume, stated entirely in this tree's own vocabulary.

## Main Definitions

- `wordOf` — the bi-infinite Z-word read off a model and a world history over the carrier `ℤ`

## Main Results

- `truthAt_iff_intTruth_of_boxFree` — box-free task-frame truth is a datum of the Z-word alone
- `validZTime_of_boxFree_intTruth` — a box-free formula true on every bi-infinite Z-word is
  `ZTime`-valid
- `plusDerivable_substPlus_of_validZTime` — **the bridge**
- `plusDerivable_substPlus_of_boxFree_intTruth` — **the corollary** over the linear fragment

## References

* [M. Reynolds, *An Axiomatization of Full Computation Tree Logic*][reynolds2001] — Lemma 7
  Claim 1, p. 1030, the step at which linear completeness is quoted inside the CTL* argument.
  The two-sided Z-word transposition, and every declaration below, are not Reynolds'.
* `FormalSystem/Metalogic/StrongCompleteness.lean` — `completeness_ztime`
* `FormalSystem/PlusLanguage/Substitution.lean` — `plusDerivable_substPlus_nil`
* `FormalSystem/Semantics/IntTransfer.lean` — `ValidInt`, `validZTime_iff_validInt`
* `FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean` — `IntStructure`, `IntTruth`,
  `isBoxFree`
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.Metalogic.Expressiveness.Separation

/-- The bi-infinite Z-word read off a model and a world history over the carrier `ℤ`.

Paper: — (formalization-native; the manuscript has no two-sided Z-word reading of a task model) -/
def wordOf {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) : IntStructure where
  val a := { t : ℤ | M.valuation (τ.state t) a }

/-- Box-free truth is a datum of the Z-word alone.

The `box` arm is discharged by contradiction with `isBoxFree`, which is exactly where the
hypothesis pays for `IntTruth`'s degenerate modal clause.

Paper: — (formalization-native; neither semantics in this statement is the manuscript's) -/
theorem truthAt_iff_intTruth_of_boxFree {F : FrameOver intOrder} [F.IsRegular]
    (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) :
    ∀ (φ : Formula), isBoxFree φ = true → ∀ t : ℤ,
      (TruthAt M τ t φ ↔ IntTruth (wordOf M τ) t φ) := by
  intro φ
  induction φ with
  | atom a => intro _ t; exact Iff.rfl
  | bot => intro _ t; exact Iff.rfl
  | imp φ ψ ih1 ih2 =>
    intro hbf t
    simp only [isBoxFree, Bool.and_eq_true] at hbf
    exact imp_congr (ih1 hbf.1 t) (ih2 hbf.2 t)
  | box _ _ => intro hbf; simp [isBoxFree] at hbf
  | untl ψ φ ih1 ih2 =>
    intro hbf t
    simp only [isBoxFree, Bool.and_eq_true] at hbf
    constructor
    · rintro ⟨s, hts, hs, hmid⟩
      exact ⟨s, hts, (ih2 hbf.1 s).mp hs, fun r h1 h2 => (ih1 hbf.2 r).mp (hmid r h1 h2)⟩
    · rintro ⟨s, hts, hs, hmid⟩
      exact ⟨s, hts, (ih2 hbf.1 s).mpr hs, fun r h1 h2 => (ih1 hbf.2 r).mpr (hmid r h1 h2)⟩
  | snce ψ φ ih1 ih2 =>
    intro hbf t
    simp only [isBoxFree, Bool.and_eq_true] at hbf
    constructor
    · rintro ⟨s, hst, hs, hmid⟩
      exact ⟨s, hst, (ih2 hbf.1 s).mp hs, fun r h1 h2 => (ih1 hbf.2 r).mp (hmid r h1 h2)⟩
    · rintro ⟨s, hst, hs, hmid⟩
      exact ⟨s, hst, (ih2 hbf.1 s).mpr hs, fun r h1 h2 => (ih1 hbf.2 r).mpr (hmid r h1 h2)⟩

/-- A box-free formula true on every bi-infinite Z-word is `ZTime`-valid.

The `isBoxFree` hypothesis may never be weakened, defaulted, or discharged by a `simp` lemma:
`IntTruth`'s `box` arm is `True`, so without it the statement is false.

Paper: — (formalization-native; the manuscript states no Z-word validity transfer) -/
theorem validZTime_of_boxFree_intTruth {φ : Formula} (hbf : isBoxFree φ = true)
    (h : ∀ (W : IntStructure) (t : ℤ), IntTruth W t φ) : ValidZTime φ := by
  rw [validZTime_iff_validInt]
  intro F _ M τ t
  exact (truthAt_iff_intTruth_of_boxFree M τ φ hbf t).mpr (h _ t)

/-- **The bridge.** A `ZTime`-valid L formula yields a TM⁺ theorem at every substitution.

`completeness_ztime` supplies the TM theorem, `plusDerivable_substPlus_nil` carries it through
`PlusDerivationTree.ofTMSubst` to TM⁺ at arbitrary L⁺ arguments.

Paper: — (formalization-native; both halves are this tree's own results) -/
theorem plusDerivable_substPlus_of_validZTime {φ : Formula} (σ : Atom → PlusFormula)
    (h : ValidZTime φ) : PlusDerivable FrameClass.ZTime [] (substPlus σ φ) :=
  plusDerivable_substPlus_nil σ (completeness_ztime φ h)

/-- **The corollary.** Linear validity over bi-infinite Z-words yields TM⁺ theorems at every
substitution.

The `isBoxFree` hypothesis is inherited from `validZTime_of_boxFree_intTruth` and is load-bearing
there; see that declaration and this module's docstring.

Paper: — (formalization-native; both halves are this tree's own results) -/
theorem plusDerivable_substPlus_of_boxFree_intTruth {φ : Formula} (σ : Atom → PlusFormula)
    (hbf : isBoxFree φ = true) (h : ∀ (W : IntStructure) (t : ℤ), IntTruth W t φ) :
    PlusDerivable FrameClass.ZTime [] (substPlus σ φ) :=
  plusDerivable_substPlus_of_validZTime σ (validZTime_of_boxFree_intTruth hbf h)

end FormalSystem.Metalogic

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness
import FormalSystem.Metalogic.Conservativity.Star.StarSoundness

/-!
# Pointed soundness, stated once over `TruthEnv`

A derivation of `φ` from `Γ` at frame class `fc` makes `φ` true at every point of every model
over a frame satisfying `fc` at which all of `Γ` is true. TM, TM⁺ and TM⋆ each prove this in
their own vocabulary (`soundness_in`, `Conservativity.plus_soundness_in`,
`Conservativity.star_soundness_in`). This module states it once, over the truth predicate
`TruthEnv.T` of `Semantics/TruthClauses.lean`, and makes each language an instance.

`PointedSound L D` is a `Prop`-valued mixin relating a derivation relation `D` over a language
`L` to the `TruthEnv` truth predicate of `L`. It has one field and carries no data: it does not
own the derivation relation, the connectives or the truth predicate, so an interface that
packages those can require `[PointedSound L D]` of its own relation without anything being
packaged twice. `D` lands in `Sort u`, so the class fits derivation trees and `Prop`-valued
derivability alike.

The environment `e : TruthEnv.Env L F` is the same at the premises and at the conclusion. For TM
and TM⁺ it is `PUnit`; for TM⋆ it is the stored-time vector, so the premises are assumed at the
point of evaluation only.

This is the single soundness statement of milestone D4 in `records/milestones.md`, and the
statement the soundness adapter of `records/proof-mode-architecture.md` consumes. Only the sound
direction is stated: the module is guarded against the completeness theorems and imports nothing
under `FormalSystem/Automation/ProofMode/`.

## Main Results

- `PointedSound` — the class, with instances at `DerivationTree`, `PlusDerivationTree` and
  `StarDerivationTree`
- `truth_of_derivation` — truth at a point from a derivation, frame-class evidence and truth of
  the premises

## Tags

soundness · truth-env · pointed-truth
-/

assert_not_exists FormalSystem.Metalogic.completeness_base
  FormalSystem.Metalogic.completeness_dense FormalSystem.Metalogic.completeness_ztime
  FormalSystem.Metalogic.completeness_rtime

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.Semantics

universe u

/-- `PointedSound L D`: the derivation relation `D` over the language `L` is sound for the
`TruthEnv` truth predicate of `L`, pointwise and with premises. A `Prop`-valued mixin: it carries
no data and does not own `D`. -/
class PointedSound (L : Type) [TruthEnv L] (D : FrameClass → List L → L → Sort u) : Prop where
  /-- A derivation of `φ` from `Γ` at `fc` gives truth of `φ` at every point of every model over
  a frame satisfying `fc`, under every environment, at which all of `Γ` is true. -/
  sound : ∀ {fc : FrameClass} {Γ : List L} {φ : L}, D fc Γ φ →
    ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
      (e : TruthEnv.Env L F), (∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) → TruthEnv.T M τ t e φ

/-- TM derivation trees are pointwise sound: `soundness_in`. -/
instance : PointedSound Formula DerivationTree where
  sound d F hF M τ t _ h := soundness_in _ _ d F hF M τ t h

/-- TM⁺ derivation trees are pointwise sound: `Conservativity.plus_soundness_in`. -/
instance : PointedSound PlusFormula PlusDerivationTree where
  sound d F hF M τ t _ h := Conservativity.plus_soundness_in _ _ d F hF M τ t h

/-- TM⋆ derivation trees are pointwise sound, the environment being the stored-time vector:
`Conservativity.star_soundness_in`. -/
instance : PointedSound StarFormula StarDerivationTree where
  sound d F hF M τ t v h := Conservativity.star_soundness_in _ _ d F hF M τ t v h

/-- **Pointed soundness.** From a derivation `d : D fc Γ φ` in any language whose derivation
relation is `PointedSound`, evidence that the frame satisfies `fc`, and truth of every member of
`Γ` at a point under the environment `e`, the conclusion `φ` is true at that point under `e`.

The environment is explicit because the TM and TM⁺ instances discard it, so unification against a
native truth goal does not determine it: pass `PUnit.unit` there, and the stored-time vector for
TM⋆.

Paper: — (formalization-native; the manuscript states soundness per language)
-/
theorem truth_of_derivation {L : Type} [TruthEnv L] {D : FrameClass → List L → L → Sort u}
    [PointedSound L D] {fc : FrameClass} {Γ : List L} {φ : L} (d : D fc Γ φ)
    {F : TaskFrame} (hF : fc.Sat F) {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (e : TruthEnv.Env L F) (h : ∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) : TruthEnv.T M τ t e φ :=
  PointedSound.sound d F hF M τ t e h

end FormalSystem.Metalogic

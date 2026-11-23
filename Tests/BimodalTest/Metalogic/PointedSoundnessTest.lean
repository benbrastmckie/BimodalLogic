/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.PointedSoundness

/-!
# Tests for pointed soundness over `TruthEnv`

`truth_of_derivation` (`FormalSystem/Metalogic/PointedSoundness.lean`) is stated over
`TruthEnv.T`. These examples instantiate it at TM, TM⁺ and TM⋆ and close goals stated in each
language's native truth predicate (`TruthAt`, `PlusTruthAt`, `StarTruthAt`), which checks that
the generic statement needs no per-language wrapper: `TruthEnv.T` unfolds to the native predicate
by definition at each instance.

The environment argument is `PUnit.unit` for TM and TM⁺ and the stored-time vector for TM⋆.

## Contents

- One example per language from an abstract derivation tree and its premises.
- For TM⋆, a register axiom at a point (`StarAxiom.recall_rigid_future` at `FrameClass.Base`)
  and a two-premise modus ponens from the context, both from concrete trees.
-/

namespace BimodalTest.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-! ## One example per language, from an abstract tree -/

/-- TM: native `TruthAt` from a `DerivationTree` and its premises. -/
example {fc : FrameClass} {Γ : Context} {φ : Formula} (d : DerivationTree fc Γ φ)
    {F : TaskFrame} (hF : fc.Sat F) {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  truth_of_derivation d hF PUnit.unit h

/-- TM⁺: native `PlusTruthAt` from a `PlusDerivationTree` and its premises. -/
example {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula} (d : PlusDerivationTree fc Γ φ)
    {F : TaskFrame} (hF : fc.Sat F) {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (h : ∀ ψ ∈ Γ, PlusTruthAt M τ t ψ) : PlusTruthAt M τ t φ :=
  truth_of_derivation d hF PUnit.unit h

/-- TM⋆: native `StarTruthAt` from a `StarDerivationTree` and its premises, at one stored-time
vector `v`. -/
example {fc : FrameClass} {Γ : StarContext} {φ : StarFormula} (d : StarDerivationTree fc Γ φ)
    {F : TaskFrame} (hF : fc.Sat F) {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    {v : ℕ → F.Duration}
    (h : ∀ ψ ∈ Γ, StarTruthAt M τ t v ψ) : StarTruthAt M τ t v φ :=
  truth_of_derivation d hF v h

/-! ## TM⋆ from concrete trees -/

/-- A register axiom at a point: `↓ⁱφ → G↓ⁱφ` is true at every point of a regular frame, under
every stored-time vector. -/
example (F : TaskFrame) [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (v : ℕ → F.Duration) (i : ℕ) (φ : StarFormula) :
    StarTruthAt M τ t v
      ((StarFormula.timeRecall i φ).imp (StarFormula.allFuture (.timeRecall i φ))) :=
  truth_of_derivation (D := StarDerivationTree) (fc := FrameClass.Base)
    (.axiom [] _ (StarAxiom.recall_rigid_future i φ) le_rfl) inferInstance v (by simp)

/-- Modus ponens from a two-premise context: the premises are assumed at the point of evaluation
and at the vector `v` only. -/
example {F : TaskFrame} [F.IsRegular] {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    {v : ℕ → F.Duration} (φ ψ : StarFormula)
    (h1 : StarTruthAt M τ t v (φ.imp ψ)) (h2 : StarTruthAt M τ t v φ) : StarTruthAt M τ t v ψ :=
  truth_of_derivation (fc := FrameClass.Base)
    (StarDerivationTree.modus_ponens [φ.imp ψ, φ] φ ψ (.assumption _ _ (by simp))
      (.assumption _ _ (by simp))) inferInstance v
    (by intro χ hχ; rcases List.mem_pair.mp hχ with rfl | rfl <;> assumption)

end BimodalTest.Metalogic

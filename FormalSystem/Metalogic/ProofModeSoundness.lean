/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness

/-!
# One-way soundness seam for the pointed semantic proof mode

The semantic proof mode accepts a native derivation only through these wrappers of the existing
context-form soundness theorems, `FormalSystem.Metalogic.soundness_in` and
`FormalSystem.Metalogic.Conservativity.plus_soundness_in`. Each consumes the derivation tree, an
explicit `fc.Sat F` certificate (at `.Base` this is regularity, not `True`) and truth of the whole,
possibly abstract, object context at the selected point. The model, history and time of the
conclusion are those of the context evidence.

The `TruthEnv.T` forms are stated at the canonical TM/TM⁺ truth dictionaries, found by instance
resolution here. A goal over another dictionary needs an explicit interpretation first.

There is no converse: model-specific truth never produces a derivation, and no completeness theorem
is reachable from this module.
-/

assert_not_exists FormalSystem.Metalogic.completeness_base
  FormalSystem.Metalogic.completeness_dense FormalSystem.Metalogic.completeness_ztime
  FormalSystem.Metalogic.completeness_rtime

namespace FormalSystem.Metalogic.ProofModeSoundness

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics
open FormalSystem.PlusLanguage

/-- TM soundness at one point, with every semantic index explicit. -/
theorem truthAt_of_derivation {fc : FrameClass} {Γ : List Formula} {φ : Formula}
    (d : DerivationTree fc Γ φ) (F : TaskFrame) (hFrame : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (hContext : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ :=
  soundness_in Γ φ d F hFrame M τ t hContext

/-- TM soundness stated through the canonical `TruthEnv Formula` dictionary. -/
theorem truthEnv_of_derivation {fc : FrameClass} {Γ : List Formula} {φ : Formula}
    (d : DerivationTree fc Γ φ) (F : TaskFrame) (hFrame : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env Formula F)
    (hContext : ∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) : TruthEnv.T M τ t e φ :=
  soundness_in Γ φ d F hFrame M τ t hContext

/-- TM⁺ soundness at one point, with every semantic index explicit. -/
theorem plusTruthAt_of_derivation {fc : FrameClass} {Γ : List PlusFormula} {φ : PlusFormula}
    (d : PlusDerivationTree fc Γ φ) (F : TaskFrame) (hFrame : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (hContext : ∀ ψ ∈ Γ, PlusTruthAt M τ t ψ) :
    PlusTruthAt M τ t φ :=
  Conservativity.plus_soundness_in Γ φ d F hFrame M τ t hContext

/-- TM⁺ soundness stated through the canonical `TruthEnv PlusFormula` dictionary. -/
theorem plusTruthEnv_of_derivation {fc : FrameClass} {Γ : List PlusFormula} {φ : PlusFormula}
    (d : PlusDerivationTree fc Γ φ) (F : TaskFrame) (hFrame : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env PlusFormula F)
    (hContext : ∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) : TruthEnv.T M τ t e φ :=
  Conservativity.plus_soundness_in Γ φ d F hFrame M τ t hContext

end FormalSystem.Metalogic.ProofModeSoundness

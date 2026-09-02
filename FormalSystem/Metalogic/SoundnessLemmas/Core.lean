/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Axioms

/-!
# Core Validity Definitions for Soundness Proofs

The local `IsValid` definition, shared across all frame-class variants of the
soundness proof.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Syntax
open FormalSystem.ProofSystem (Axiom DerivationTree FrameClass)
open FormalSystem.Semantics

/--
Local definition of validity to avoid circular dependency with Validity.lean.
A formula is valid if it's true at every model and every **total** history, at all times.

This is a monomorphic definition (fixed to explicit type parameter D) to avoid
universe level mismatch errors.
Per research report Option A: Make D explicit to allow type inference at call sites.

**Note**: Validity quantifies over ALL times,
not just times in the history's domain.

**Totality**: quantifies over the histories `τ` with `τ.IsTotal` (i.e. `τ ∈ H_F`), matching the
global `valid` definition in Validity.lean binder for binder. There is no admissible-history
parameter and no shift-closure side condition: totality is trivially preserved by `timeShift`,
so time-shift invariance carries no side condition. `TruthAt`'s remaining set argument is inert
and is supplied as `Set.univ`.
-/
def IsValid (D : TemporalOrder) (φ : Formula) : Prop :=
  ∀ (F : FrameOver D) (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (_hτ : τ.IsTotal) (t : ↑D),
    TruthAt M τ t φ

end FormalSystem.Metalogic.SoundnessLemmas

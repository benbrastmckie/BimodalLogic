import Bimodal.ProofSystem
import Mathlib.Data.List.Basic
import Mathlib.Data.Finset.Basic

/-!
# Provability Definitions for Metalogic v2

This module provides definitions related to provability for metalogical reasoning.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Layer Dependencies

Core.Provability depends only on:
- Bimodal.ProofSystem (derivation trees)
-/

namespace Bimodal.Metalogic_v2.Core

open Bimodal.Syntax Bimodal.ProofSystem

/--
Context-based provability: Γ ⊢ φ using List Formula.

This uses Lean's native List type which is naturally finite, avoiding
artificial finiteness constraints while matching actual proof practice.
-/
def ContextDerivable (Γ : Context) (φ : Formula) : Prop :=
  Nonempty (DerivationTree Γ φ)

/--
Basic lemma: Empty context derivability matches standard derivability.

This shows that ContextDerivable generalizes the existing DerivationTree system.
-/
lemma empty_context_derivability_iff {φ : Formula} :
    ContextDerivable [] φ ↔ Nonempty (DerivationTree [] φ) := by
  rfl

end Bimodal.Metalogic_v2.Core

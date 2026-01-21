import Bimodal.ProofSystem
import Bimodal.Semantics.Validity
import Bimodal.Syntax.Context
import Mathlib.Data.List.Basic
import Mathlib.Data.Set.Basic
import Mathlib.Data.Finset.Basic

/-!
# Core Definitions for Metalogic v2

This module provides the basic definitions for metalogical reasoning about
the TM bimodal logic system, including consistency and validity notions.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Layer Dependencies

Core depends only on:
- Bimodal.ProofSystem (derivation trees)
- Bimodal.Semantics.Validity (semantic validity)
- Bimodal.Syntax.Context (context type)
-/

namespace Bimodal.Metalogic_v2.Core

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics

/--
Syntactic consistency: A context is consistent if it does not derive falsum (⊥).

This is the standard syntactic notion of consistency in classical logic:
Γ is consistent iff Γ ⊬ ⊥.

In classical logic with ex-falso (⊥ → φ), this is equivalent to saying that
there exists a formula φ that is not derivable from Γ.
-/
def Consistent (Γ : Context) : Prop :=
  ¬Nonempty (DerivationTree Γ .bot)

/--
Semantic consistency: A context is semantically consistent if it is satisfiable.

This connects syntactic consistency to semantic notions.
-/
def SemanticallyConsistent (Γ : Context) : Prop :=
  satisfiable_abs Γ

/--
Logical validity: A formula is valid if it is true in all models.

This is just a reference to the definition in Validity.lean for completeness
of the Core module.
-/
def Valid (φ : Formula) : Prop :=
  Bimodal.Semantics.valid φ

/--
Notation for validity: `⊨ φ` means `Valid φ`.
-/
notation:50 "⊨ " φ:50 => Valid φ

-- Note: SetMaximalConsistent and related MCS lemmas are in Core/MaximalConsistent.lean

end Bimodal.Metalogic_v2.Core

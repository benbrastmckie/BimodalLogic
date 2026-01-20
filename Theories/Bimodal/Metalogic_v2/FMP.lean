import Bimodal.Metalogic_v2.Representation.FiniteModelProperty

/-!
# Finite Model Property Hub (Metalogic_v2)

This is the central hub module for the Finite Model Property and related
results. It serves as the interface layer between the Representation
infrastructure and the application layers (Completeness, Decidability, Compactness).

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Architecture

```
                    ┌─────────────────┐
                    │      FMP.lean   │  ← This module (hub)
                    │    (central)    │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Completeness   │ │  Decidability   │ │   Compactness   │
│  (valid→⊢)      │ │  (finite search)│ │  (fin→∞)        │
└─────────────────┘ └─────────────────┘ └─────────────────┘
         ▲                   ▲                   ▲
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
                    ┌────────┴────────┐
                    │ Representation  │
                    │ (canonical mdl) │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │      Core       │
                    │ (MCS, deduct)   │
                    └─────────────────┘
```

## Exports

This module re-exports the key theorems and definitions from the Representation
layer that are needed by the application layers:

- `finite_model_property`: Main FMP theorem
- `subformulaList`: Subformula closure construction
- `satisfiability_decidable`: Decidability corollary
- `validity_decidable_via_fmp`: Validity decidability

## Layer Dependencies

FMP.lean depends on:
- Bimodal.Metalogic_v2.Representation.FiniteModelProperty

And is imported by:
- Bimodal.Metalogic_v2.Completeness.*
- Bimodal.Metalogic_v2.Decidability.*
- Bimodal.Metalogic_v2.Applications.*
-/

namespace Bimodal.Metalogic_v2

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core Bimodal.Metalogic_v2.Representation

/-!
## Convenience Theorems

These combine results from multiple layers for easier use by applications.
-/

/--
Soundness from empty context: [] ⊢ φ → ⊨ φ
-/
theorem empty_soundness {φ : Formula} (h : ContextDerivable [] φ) : valid φ := by
  intro D _ _ _ F M τ t
  have ⟨d⟩ := h
  have h_sem := Soundness.soundness [] φ d
  exact h_sem D F M τ t (fun _ h => (List.not_mem_nil h).elim)

/--
FMP bridge: consistency implies canonical satisfiability.

This bridges the gap between syntactic consistency and semantic satisfiability.
-/
theorem consistency_satisfiability_bridge {φ : Formula} :
    Consistent [φ] → canonicalContextSatisfiable [φ] := by
  exact representation_theorem

end Bimodal.Metalogic_v2

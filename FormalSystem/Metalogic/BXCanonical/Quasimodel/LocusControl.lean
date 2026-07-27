/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Quasimodel.Realization

/-!
# Locus-Control Delegation Layer

Provides primed (`'`) variants of the Frame.lean eventuality resolution
functions, delegating through Realization.lean. These serve as the
interface for higher-level modules.

## Main Results

- `bx_until_eventuality_resolution'`: Forward Until (proved, delegates to Frame.lean)
- `bx_since_eventuality_resolution'`: Forward Since (proved, delegates to Frame.lean)

## References

- Burgess 1984: "Basic tense logic" (canonical model construction)
- Design provenance: signature weakening to the chain-member guard (v5)
-/

namespace FormalSystem.Metalogic.BXCanonical.Quasimodel

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Metalogic.BXCanonical

/-! ## Sorry-Closing Lemmas for Frame.lean -/

/-- Forward Until eventuality resolution (delegates to Realization.lean).
    Under open guard, return type no longer claims φ ∈ w. -/
theorem bx_until_eventuality_resolution'
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl ψ φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, BxLe w v ∧ ψ ∈ v.formulas :=
  until_eventuality_resolution w φ ψ h_until h_not_psi

/-- Forward Since eventuality resolution (delegates to Realization.lean).
    Under open guard, return type no longer claims φ ∈ w. -/
theorem bx_since_eventuality_resolution'
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce ψ φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, BxLe v w ∧ ψ ∈ v.formulas :=
  since_eventuality_resolution w φ ψ h_since h_not_psi

end FormalSystem.Metalogic.BXCanonical.Quasimodel

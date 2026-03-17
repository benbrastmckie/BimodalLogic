import Bimodal.Metalogic.Decidability.FMP.FMP
import Mathlib.Order.SuccPred.Basic

/-!
# Discrete FMP - Finite Model Property for Discrete Time

This module proves that the Finite Model Property holds for discrete temporal orders.

## Overview

For discretely ordered temporal types (e.g., `Int`, `Nat`), the FMP ensures that
satisfiable formulas have finite countermodels. Like the dense case, the MCS-based
filtration works regardless of the frame's discreteness property.

## Main Results

- `discrete_mcs_finite_model_property`: FMP for discrete frames

## Dependencies

The full semantic connection between discrete validity and finite models
depends on Task 981 (removing the discrete axiom technical debt). The
MCS-based construction here is independent of that work.

## References

- Blackburn, de Rijke, Venema: Modal Logic (Ch 2.3)
-/

namespace Bimodal.Metalogic.Decidability.FMP

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Discrete Frame Preservation

For discrete temporal frames, the FMP works via the same MCS-based filtration.
The discreteness condition on the temporal order does not affect the
proof-theoretic MCS construction.
-/

/--
Discrete FMP: If φ is not provable, then there exists a finite model
(in the filtration sense) where φ fails.

This is the same as the base FMP - the discreteness condition on the temporal
order does not affect the MCS-based construction.

**Why discreteness doesn't matter for MCS-FMP**:
The MCS construction only depends on:
1. Consistency of formulas (proof-theoretic)
2. Negation completeness (proof-theoretic)
3. Deductive closure (proof-theoretic)

None of these depend on whether the temporal order has successor/predecessor.
The semantic validity over discrete frames only matters when connecting
MCS membership to semantic truth, which is handled by completeness.
-/
theorem discrete_mcs_finite_model_property (phi : Formula)
    (h_not_provable : ¬Nonempty (DerivationTree [] phi)) :
    ∃ (S : ClosureMCSBundle phi), phi ∉ S.carrier ∧
    Finite (FilteredWorld phi) :=
  mcs_finite_model_property phi h_not_provable

/--
Discrete FMP contrapositive: If φ holds in all closure MCS, then φ is provable.

This is frame-independent - the MCS construction doesn't depend on discreteness.
-/
theorem discrete_fmp_contrapositive (phi : Formula)
    (h_all_mcs : ∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) :
    Nonempty (DerivationTree [] phi) :=
  fmp_contrapositive phi h_all_mcs

/-!
## Discrete Validity and FMP

The connection between discrete validity and FMP requires additional machinery
to connect the MCS world to semantic truth in discrete models.

For now, we record that the FMP construction works regardless of discreteness,
and the full semantic connection (valid_discrete → truth in finite model)
would require:
1. The canonical model construction for discrete frames
2. Task 981 completion (axiom-free discrete infrastructure)
-/

/--
Record that filtered worlds exist and are finite for any formula,
regardless of whether we're considering dense or discrete frames.
-/
theorem filtered_model_exists_discrete (phi : Formula) :
    Finite (FilteredWorld phi) :=
  FilteredWorld.finite phi

/-!
## Summary

This module establishes:

1. **discrete_mcs_finite_model_property**: MCS-based FMP works for discrete frames
2. **discrete_fmp_contrapositive**: Completeness via finite model for discrete frames
3. **filtered_model_exists_discrete**: Finite filtered model construction

The key insight is that MCS-based FMP is frame-independent at the
proof-theoretic level. The discreteness condition only matters when
connecting to semantic validity, which is handled separately by
the completeness theorem infrastructure.

**Task 981 Dependency Note**: Full discrete FMP with semantic connection
will benefit from Task 981's axiom-free discrete infrastructure.
-/

end Bimodal.Metalogic.Decidability.FMP

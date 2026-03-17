import Bimodal.Metalogic.Decidability.FMP.ClosureMCS
import Bimodal.Metalogic.Decidability.FMP.Filtration
import Bimodal.Metalogic.Decidability.FMP.FiniteModel
import Bimodal.Metalogic.Decidability.FMP.TruthPreservation
import Bimodal.Metalogic.Decidability.FMP.FMP
import Bimodal.Metalogic.Decidability.FMP.DenseFMP
import Bimodal.Metalogic.Decidability.FMP.DiscreteFMP

/-!
# FMP Module Index

This module re-exports the Finite Model Property (FMP) infrastructure
for TM bimodal logic.

## Overview

The Finite Model Property states: If a formula is satisfiable, then it is
satisfiable in a finite model whose size is bounded by 2^|closure(φ)|.

## Modules

- `ClosureMCS`: Maximal Consistent Sets restricted to subformula closure
- `Filtration`: Filtration equivalence and quotient construction
- `FiniteModel`: Finiteness proof for filtered worlds
- `TruthPreservation`: Truth preservation under filtration (Filtration Lemma)
- `FMP`: Main FMP theorem
- `DenseFMP`: FMP for dense temporal frames
- `DiscreteFMP`: FMP for discrete temporal frames

## Key Theorems

- `FMP.mcs_finite_model_property`: If φ not provable, ∃ finite model where φ fails
- `FMP.fmp_contrapositive`: If φ true in all finite worlds → φ provable
- `FMP.fmp_size_bound`: Model size ≤ 2^|closure(φ)|

## Usage

Import this module to access all FMP infrastructure:
```lean
import Bimodal.Metalogic.Decidability.FMP
```

## References

- Blackburn, de Rijke, Venema: Modal Logic (Ch 2.3 Filtrations)
- Hughes & Cresswell: A New Introduction to Modal Logic (Ch 6.2)
-/

# Decidability - Tableau Decision Procedure for TM Logic

Tableau-based decision procedure for TM bimodal logic validity checking, returning proof
terms or countermodels.

## Overview

This directory implements a verified decision procedure that:
- Decides validity of TM bimodal logic formulas
- Returns proof terms (`DerivationTree`) when valid
- Returns countermodel descriptions when invalid
- Uses fuel-based termination for practical execution

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `SignedFormula.lean` | Sign, SignedFormula, Branch types | Sorry-free |
| `Tableau.lean` | Tableau expansion rules (propositional, modal, temporal) | Sorry-free |
| `Saturation.lean` | Saturation and fuel-based termination | Sorry-free |
| `Closure.lean` | Branch closure detection | Sorry-free |
| `Correctness.lean` | Soundness proof | Sorry-free |
| `ProofExtraction.lean` | Extract DerivationTree from closed tableau | Sorry-free |
| `CountermodelExtraction.lean` | Extract countermodel from open branch | Sorry-free |
| `DecisionProcedure.lean` | Main `decide` function with proof search | Sorry-free |

## Quick Reference

- **Main entry point**: `decide` in `DecisionProcedure.lean`
- **Boolean helpers**: `isValid`, `isSatisfiable`
- **Result type**: `DecisionResult` (valid/invalid/timeout)

## Algorithm Overview

1. **Optimization**: First try direct proof search for shallow proofs
2. **Tableau**: Build tableau for `F(phi)` (asserting `phi` is false)
3. **Analysis**:
   - All branches close -> `phi` is valid, extract proof
   - Open saturated branch -> `phi` is invalid, extract countermodel

## Usage

```lean
import Bimodal.Metalogic.Decidability

open Bimodal.Metalogic.Decidability

#check decide        -- Main decision procedure
#check isValid       -- Boolean validity check
#check isSatisfiable -- Boolean satisfiability check
```

## Dependency Flowchart

```
┌─────────────────────────────────────────────────┐
│          DecisionProcedure.lean                 │
│       (decide, isValid, isSatisfiable)          │
└─────────────────────────────────────────────────┘
                       │
       ┌───────────────┴───────────────┐
       v                               v
┌─────────────────┐           ┌─────────────────┐
│ ProofExtraction │           │ Countermodel    │
│   .lean         │           │ Extraction.lean │
└─────────────────┘           └─────────────────┘
       │                               │
       └───────────────┬───────────────┘
                       v
              ┌─────────────────┐
              │ Correctness.lean│
              └─────────────────┘
                       │
              ┌─────────────────┐
              │ Saturation.lean │
              └─────────────────┘
                       │
              ┌─────────────────┐
              │  Closure.lean   │
              └─────────────────┘
                       │
              ┌─────────────────┐
              │  Tableau.lean   │
              └─────────────────┘
                       │
              ┌─────────────────┐
              │SignedFormula.lean│
              └─────────────────┘
```

## Complexity

- Time: `O(2^n)` where `n` = formula complexity (PSPACE-complete)
- Space: `O(n)` for DFS-based tableau expansion
- Typical formulas: Much faster due to pruning and optimization

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Bundle README](../Bundle/README.md) - BMCS completeness approach
- [FMP README](../FMP/README.md) - Finite model property
- [Core README](../Core/README.md) - MCS foundations
- [Soundness README](../Soundness/README.md) - Soundness theorem

## References

- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
- Wu, M. Verified Decision Procedures for Modal Logics (Lean formalization)

---

*Last updated: 2026-02-03*

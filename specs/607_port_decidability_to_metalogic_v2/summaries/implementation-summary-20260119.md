# Implementation Summary: Task #607

**Completed**: 2026-01-19
**Session ID**: sess_1768856401_9dc365

## Overview

Successfully ported the Decidability infrastructure from old Metalogic/ to Metalogic_v2/ architecture. The port establishes FMP as the bridge theorem for termination guarantees and integrates with the representation-first architecture.

## Changes Made

### New Files Created (9 files)

1. **SignedFormula.lean** - Core types (Sign, SignedFormula, Branch) with Metalogic_v2 closure integration
2. **Tableau.lean** - Tableau expansion rules (minimal changes from original)
3. **BranchClosure.lean** - Branch closure detection (renamed from Closure.lean to avoid conflict)
4. **Saturation.lean** - Tableau expansion with FMP-based fuel calculation
5. **ProofExtraction.lean** - Proof term extraction from closed tableaux
6. **CountermodelExtraction.lean** - Countermodel construction from open branches
7. **DecisionProcedure.lean** - Main decision procedure with three-phase algorithm
8. **Correctness.lean** - Soundness/completeness theorems with FMP integration
9. **Decidability.lean** - Hub module re-exporting all components

### Key Integration Points

- **FMP-Based Fuel**: Uses `closureSizeOf` from `Representation/Closure.lean` to compute `fmpBasedFuel = 2^closureSizeOf * 2`
- **Decidability Instances**: `satisfiability_decidable_v2` and `validity_decidable_via_sat` from FMP
- **Soundness Integration**: Uses `Metalogic_v2.Soundness.soundness` for `decide_sound`

## Files Modified

- `specs/607_port_decidability_to_metalogic_v2/plans/implementation-001.md` - Phase status updates

## Files Created

| File | Lines | Description |
|------|-------|-------------|
| `Metalogic_v2/Decidability/SignedFormula.lean` | ~240 | Core types with FMP integration |
| `Metalogic_v2/Decidability/Tableau.lean` | ~370 | Expansion rules (ported) |
| `Metalogic_v2/Decidability/BranchClosure.lean` | ~200 | Closure detection |
| `Metalogic_v2/Decidability/Saturation.lean` | ~250 | FMP-based saturation |
| `Metalogic_v2/Decidability/ProofExtraction.lean` | ~190 | Proof extraction |
| `Metalogic_v2/Decidability/CountermodelExtraction.lean` | ~180 | Countermodel extraction |
| `Metalogic_v2/Decidability/DecisionProcedure.lean` | ~290 | Decision procedure |
| `Metalogic_v2/Decidability/Correctness.lean` | ~260 | Correctness proofs |
| `Metalogic_v2/Decidability.lean` | ~230 | Hub module |

## Verification

- Lake build: Success (976 jobs)
- All goals closed: Yes (except documented sorries in completeness proofs)
- No import cycles between Decidability and FMP

## Remaining Sorries

The following theorems use `sorry` and require future work to complete:

1. **BranchClosure.lean**:
   - `closed_extend_closed` - Technical proof about closure preservation
   - `add_neg_causes_closure` - Technical proof about contradiction detection

2. **Saturation.lean**:
   - `expansion_decreases_measure` - Termination measure decrease

3. **Correctness.lean**:
   - `tableau_complete` - Full FMP connection to tableau termination
   - `decide_complete` - Proof extraction from completed tableau
   - `decide_axiom_valid` - matchAxiom behavior verification

## Architecture

```
Decidability.lean (hub)
├── Correctness.lean      → FMP integration
│   └── DecisionProcedure.lean
│       ├── ProofExtraction.lean
│       └── CountermodelExtraction.lean
└── Saturation.lean
    └── BranchClosure.lean
        └── Tableau.lean
            └── SignedFormula.lean
                └── (imports FMP via Representation/Closure.lean)
```

## Notes

- BranchClosure.lean was renamed from Closure.lean to avoid naming conflict with Representation/Closure.lean
- FMP-based fuel uses the constructive bound from `finite_model_property_constructive`
- The module follows the representation-first architecture where FMP serves as the bridge theorem
- Completeness proofs require connecting FMP witness construction to tableau termination, which is left as future work

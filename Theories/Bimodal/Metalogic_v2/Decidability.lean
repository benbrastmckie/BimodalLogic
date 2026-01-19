-- Decidability Hub Module (Metalogic_v2)
-- Re-exports all Decidability infrastructure

import Bimodal.Metalogic_v2.Decidability.SignedFormula
import Bimodal.Metalogic_v2.Decidability.Tableau
import Bimodal.Metalogic_v2.Decidability.BranchClosure
import Bimodal.Metalogic_v2.Decidability.Saturation
import Bimodal.Metalogic_v2.Decidability.ProofExtraction
import Bimodal.Metalogic_v2.Decidability.CountermodelExtraction
import Bimodal.Metalogic_v2.Decidability.DecisionProcedure
import Bimodal.Metalogic_v2.Decidability.Correctness

/-!
# Decidability Module Hub (Metalogic_v2)

This is the top-level hub module for the Decidability infrastructure in
Metalogic_v2. It provides a complete tableau-based decision procedure for
TM bimodal logic with FMP-based termination guarantees.

## Overview

This module is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

The Decidability module sits atop the FMP layer:

```
                    ┌─────────────────┐
                    │  Decidability   │  ← This module
                    │  (decision proc)│
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │      FMP.lean   │  ← Bridge theorem
                    │    (central)    │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │ Representation  │
                    │ (canonical mdl) │
                    └─────────────────┘
```

## Architecture

### Module Dependencies

```
Decidability.lean (this file)
├── Correctness.lean      → FMP integration, soundness/completeness
│   ├── DecisionProcedure.lean → Main decision procedure
│   │   ├── ProofExtraction.lean → Proof term extraction
│   │   └── CountermodelExtraction.lean → Countermodel construction
│   └── Saturation.lean   → Tableau expansion with FMP fuel
│       └── BranchClosure.lean → Branch closure detection
│           └── Tableau.lean → Expansion rules
│               └── SignedFormula.lean → Core types
└── FMP.lean (external)   → Finite Model Property
```

### Key Types

- `Sign`: Positive/negative sign for signed formulas
- `SignedFormula`: Formula with truth assertion
- `Branch`: List of signed formulas (tableau branch)
- `DecisionResult`: Valid with proof / Invalid with countermodel / Timeout

### Key Functions

- `decide`: Main decision procedure
- `buildTableau`: Construct tableau for formula
- `extractProof`: Extract proof term from closed tableau
- `extractCountermodel`: Extract countermodel from open branch

### Key Theorems

- `decide_sound`: Decision procedure is sound
- `decide_complete`: Decision procedure is complete (with sufficient fuel)
- `validity_decidable`: Validity is decidable (via FMP)

## FMP Integration

The Decidability module integrates with FMP through:

1. **Fuel Calculation**: `fmpBasedFuel` uses `closureSizeOf` from FMP
2. **Termination Bound**: FMP provides explicit bound on model size
3. **Completeness**: FMP ensures that valid formulas are decidable

The key insight is that FMP bounds the tableau exploration space:
- Satisfiable formulas have finite models of size ≤ 2^closureSize
- Tableau branches contain signed formulas from the closure
- With fuel = 2^closureSize * 2, the procedure terminates

## Usage

### Basic Decision

```lean
import Bimodal.Metalogic_v2.Decidability

open Bimodal.Metalogic_v2.Decidability

-- Decide validity of a formula
#eval (decide (.atom "p")).display  -- "Valid" or "Invalid" or "Timeout"

-- With automatic FMP-based fuel
#eval (decideAuto (.atom "p")).display

-- Check specific properties
#eval isValidFormula (.atom "p")  -- Bool
#eval isSatisfiable (.atom "p")   -- Bool
```

### Advanced Usage

```lean
-- Use explicit fuel
let result := decide φ 20 10000

-- Check result type
match result with
| .valid proof => -- Use proof term
| .invalid cm => -- Examine countermodel
| .timeout => -- Increase fuel

-- Batch processing
let stats := decideBatch formulas 5000
```

## Exports

### From SignedFormula.lean
- `Sign`, `SignedFormula`, `Branch`
- `closureSizeOf`, `fmpBasedFuel`, `recommendedFuel`

### From Tableau.lean
- `TableauRule`, `RuleResult`
- `applyRule`, `expandOnce`
- `findUnexpanded`, `isExpanded`

### From BranchClosure.lean
- `ClosureReason`, `ClosedBranch`, `OpenBranch`
- `findClosure`, `isClosed`, `isOpen`

### From Saturation.lean
- `ExpandedTableau`, `BranchListResult`
- `buildTableau`, `buildTableauAuto`, `buildTableauWithFMPFuel`
- `expandBranchWithFuel`, `isSaturated`

### From ProofExtraction.lean
- `ProofExtractionResult`
- `extractProof`, `tryAxiomProof`, `findProofCombined`

### From CountermodelExtraction.lean
- `SimpleCountermodel`, `CountermodelResult`
- `extractCountermodel`, `findCountermodel`

### From DecisionProcedure.lean
- `DecisionResult`
- `decide`, `decideAuto`, `decideWithFMPFuel`, `decideOptimized`
- `isValidFormula`, `isSatisfiable`, `isTautology`, `isContradiction`

### From Correctness.lean
- `decide_sound`, `decide_complete`
- `validity_decidable`, `satisfiability_decidable_v2`
- `extracted_proof_correct`

## References

- Metalogic_v2.FMP - Finite Model Property and bounds
- Metalogic_v2.Representation - Canonical model construction
- Metalogic_v2.Soundness - Soundness theorem
- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
- Wu, M. Verified Decision Procedures for Modal Logics
-/

namespace Bimodal.Metalogic_v2.Decidability

-- Re-export key types and functions for convenience
-- The imports already make everything available, but we can add
-- explicit #check statements to document the API.

/-!
## Key Types
-/

#check Sign
#check SignedFormula
#check Branch
#check TableauRule
#check RuleResult
#check ClosureReason
#check ClosedBranch
#check ExpandedTableau
#check DecisionResult
#check SimpleCountermodel

/-!
## Key Functions
-/

#check decide
#check decideAuto
#check decideWithFMPFuel
#check buildTableau
#check buildTableauAuto
#check extractProof
#check findCountermodel
#check isValidFormula
#check isSatisfiable

/-!
## Key Theorems
-/

#check decide_sound
#check decide_complete
#check validity_decidable
#check decide_result_exclusive
#check extracted_proof_correct

/-!
## FMP Integration Points
-/

#check closureSizeOf
#check fmpBasedFuel
#check recommendedFuel

end Bimodal.Metalogic_v2.Decidability

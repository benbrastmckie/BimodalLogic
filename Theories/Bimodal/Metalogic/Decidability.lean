import Bimodal.Metalogic.Decidability.SignedFormula
import Bimodal.Metalogic.Decidability.Tableau
import Bimodal.Metalogic.Decidability.Closure
import Bimodal.Metalogic.Decidability.Saturation
import Bimodal.Metalogic.Decidability.ProofExtraction
import Bimodal.Metalogic.Decidability.CountermodelExtraction
import Bimodal.Metalogic.Decidability.DecisionProcedure
import Bimodal.Metalogic.Decidability.Correctness

/-!
# Decidability - Decision Procedure for TM Bimodal Logic

This module provides a verified decision procedure for the TM bimodal logic,
combining S5 modal logic with linear temporal logic.

## Overview

The decision procedure is based on the tableau method:
1. Start with F(φ) (asserting the goal is false)
2. Systematically expand using tableau rules
3. If all branches close → φ is valid, extract proof
4. If any branch saturates open → φ is invalid, extract countermodel

## Main Components

### Types
- `Sign`: Positive/negative sign for signed formulas
- `SignedFormula`: Formula with truth assertion
- `Branch`: List of signed formulas (tableau branch)
- `DecisionResult`: Valid proof or countermodel

### Functions
- `decide`: Main decision procedure
- `isValid`: Boolean validity check
- `isSatisfiable`: Boolean satisfiability check

### Theorems
- `decide_sound`: Soundness of decision procedure
- `countermodel_refutes`: Countermodels are correct
- `decide_correct`: Combined correctness theorem

## Module Structure

```
Bimodal/Metalogic/Decidability/
├── SignedFormula.lean       -- Sign, SignedFormula, Branch types
├── Tableau.lean             -- Tableau expansion rules
├── Closure.lean             -- Branch closure detection
├── Saturation.lean          -- Saturation and termination
├── ProofExtraction.lean     -- Extract DerivationTree from closed tableau
├── CountermodelExtraction.lean -- Extract countermodel from open branch
├── DecisionProcedure.lean   -- Main decide function
└── Correctness.lean         -- Soundness and completeness proofs
```

## Usage

```lean
import Bimodal.Metalogic.Decidability

open Bimodal.Metalogic.Decidability
open Bimodal.Syntax

-- Decide validity of a formula
#eval (decide (Formula.box (.atom "p") |>.imp (.atom "p"))).isValid
-- true (modal T axiom is valid)

-- Check satisfiability
#eval isSatisfiable (Formula.atom "p")
-- true (atoms are satisfiable)
```

## Implementation Status

### Completed
- [x] Signed formula and branch types
- [x] Tableau expansion rules (propositional, modal, temporal)
- [x] Branch closure detection (contradiction, bot, axiom negation)
- [x] Saturation detection with fuel-based termination
- [x] Proof extraction for axiom instances
- [x] Countermodel extraction from open branches
- [x] Main decision procedure with optimization
- [x] Soundness theorem
- [x] Countermodel correctness

### Partial/Future Work
- [ ] Full proof extraction from complex tableaux
- [ ] Completeness proof (requires FMP formalization)
- [ ] Performance optimization
- [ ] Test suite with benchmarks

## Theoretical Background

TM bimodal logic is decidable because:
1. **S5 Modal Component**: Finite model property via filtration
2. **Linear Temporal Component**: Finite model property via unraveling
3. **Combination**: Product construction preserves FMP

The tableau method provides:
- **Soundness**: Closed tableau implies validity
- **Completeness**: Valid formulas have closed tableaux
- **Termination**: Subformula property bounds expansion

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics
* JPL Paper: The Perpetuity Calculus of Agency (TM logic specification)
-/

namespace Bimodal.Metalogic.Decidability

-- Main definitions are already available through the imports:
-- - Sign, SignedFormula, Branch (from SignedFormula.lean)
-- - DecisionResult (from DecisionProcedure.lean)
-- - decide, isValid, isSatisfiable (from DecisionProcedure.lean)

end Bimodal.Metalogic.Decidability

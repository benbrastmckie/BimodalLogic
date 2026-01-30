import Bimodal.Boneyard.Metalogic.Decidability.SignedFormula
import Bimodal.Boneyard.Metalogic.Decidability.Tableau
import Bimodal.Boneyard.Metalogic.Decidability.Closure
import Bimodal.Boneyard.Metalogic.Decidability.Saturation
import Bimodal.Boneyard.Metalogic.Decidability.ProofExtraction
import Bimodal.Boneyard.Metalogic.Decidability.CountermodelExtraction
import Bimodal.Boneyard.Metalogic.Decidability.DecisionProcedure
import Bimodal.Boneyard.Metalogic.Decidability.Correctness

/-!
# Bimodal.Boneyard.Metalogic.Decidability - Decision Procedure for TM Logic

Tableau-based decision procedure returning proof terms or countermodels.

## Submodules

- `SignedFormula`: Sign, SignedFormula, Branch types
- `Tableau`: Tableau expansion rules (propositional, modal, temporal)
- `Closure`: Branch closure detection
- `Saturation`: Saturation and fuel-based termination
- `ProofExtraction`: Extract DerivationTree from closed tableau
- `CountermodelExtraction`: Extract countermodel from open branch
- `DecisionProcedure`: Main decide function with proof search optimization
- `Correctness`: Soundness and completeness proofs

## Status

- Soundness: Proven
- Completeness: Partial (requires FMP formalization)
- Proof extraction: Partial (axiom instances only)

## Usage

```lean
import Bimodal.Boneyard.Metalogic.Decidability

open Bimodal.Boneyard.Metalogic.Decidability

#check decide        -- Main decision procedure
#check isValid       -- Boolean validity check
#check isSatisfiable -- Boolean satisfiability check
```
-/

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.Decidability.SignedFormula
import Bimodal.Metalogic.Decidability.Tableau
import Bimodal.Metalogic.Decidability.Closure
import Bimodal.Metalogic.Decidability.Saturation
import Bimodal.Metalogic.Decidability.ProofExtraction
import Bimodal.Metalogic.Decidability.CountermodelExtraction
import Bimodal.Metalogic.Decidability.DecisionProcedure
import Bimodal.Metalogic.Decidability.Correctness
import Bimodal.Metalogic.Decidability.Propositional.PropForm
import Bimodal.Metalogic.Decidability.Propositional.Kalmar
import Bimodal.Metalogic.Decidability.Propositional.Decidable

/-!
# Bimodal.Metalogic.Decidability - Decision Procedure for TM Logic

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
- Completeness: Proven (via BFMCS approach)
- Proof extraction: Partial (axiom instances only)

## Usage

```lean
import Bimodal.Metalogic.Decidability

open Bimodal.Metalogic.Decidability

#check decide        -- Main decision procedure
#check isValid       -- Boolean validity check
#check isSatisfiable -- Boolean satisfiability check
```
-/

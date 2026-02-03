-- Core module for Universal Parametric Canonical Model
-- Re-exports MCS theory needed for canonical world construction

import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.RestrictedMCS

/-!
# Core Module for Metalogic

This module provides the foundational theory for the universal parametric
canonical model construction.

## Contents

- `MaximalConsistent.lean`: MCS theory (re-exported from Boneyard with additions)
- `DeductionTheorem.lean`: Deduction theorem infrastructure
- `MCSProperties.lean`: Essential MCS lemmas for Representation layer

## Dependencies

Imports from Boneyard/Metalogic_v2/Core for proven MCS theory.
-/

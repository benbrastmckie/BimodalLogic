-- Core module for Universal Parametric Canonical Model
-- Provides MCS theory needed for canonical world construction

import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Metalogic.Core.MCSProperties

/-!
# Core Module for Metalogic

This module provides the foundational theory for the universal parametric
canonical model construction.

## Contents

- `MaximalConsistent.lean`: Complete MCS (Maximal Consistent Set) theory including
  Lindenbaum's lemma, deductive closure, and negation completeness
- `DeductionTheorem.lean`: Deduction theorem infrastructure for Hilbert-style proofs
- `MCSProperties.lean`: Essential MCS lemmas for Representation layer including
  temporal operator properties

## Self-Contained

This module is fully self-contained with no Boneyard dependencies.
All MCS theory is proven directly using the deduction theorem.
-/

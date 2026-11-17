/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Basic
import FormalSystem.Theorems.ProofMode.Possibility
import FormalSystem.Theorems.ProofMode.Temporal
import FormalSystem.Theorems.ProofMode.Discrete
import FormalSystem.Theorems.ProofMode.PlusRules
import FormalSystem.Theorems.ProofMode.PlusModal
import FormalSystem.Theorems.ProofMode.PlusTemporal
import FormalSystem.Theorems.ProofMode.PlusDiscrete

/-!
# Native rules for compositional proof mode

Derivation-producing propositional, modal, temporal and discrete composition rules for
TM and TM⁺. Frontend elaborators live in `FormalSystem.Automation.ProofMode`.
-/

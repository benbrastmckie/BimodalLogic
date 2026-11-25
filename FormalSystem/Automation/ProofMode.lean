/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Basic
import FormalSystem.Automation.ProofMode.Modal
import FormalSystem.Automation.ProofMode.Temporal
import FormalSystem.Automation.ProofMode.TemporalBoolean
import FormalSystem.Automation.ProofMode.Discrete
import FormalSystem.Automation.ProofMode.Simplification
import FormalSystem.Tactic.FormulaViews

/-!
# Compositional proof mode

Tactics build native TM and TM⁺ derivation trees. Scoped introductions select explicit
modal or temporal guarantees, and close their body through checked contextual rules.
-/

assert_not_exists FormalSystem.Metalogic.completeness_base
  FormalSystem.Metalogic.completeness_dense FormalSystem.Metalogic.completeness_ztime
  FormalSystem.Metalogic.completeness_rtime

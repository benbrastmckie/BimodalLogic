/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.ProofModeIntervals
import FormalSystem.Automation.ProofMode.SemanticCore
import FormalSystem.Automation.ProofMode.SemanticSimplification
import FormalSystem.Automation.ProofMode.SemanticTransport

/-!
# Pointed semantic proof mode

Import this module for clause-directed reasoning, checked positional rewriting, bounded
simplification, explicit transport and the native-to-semantic soundness seam. Existing native
commands dispatch by their typed judgment. No semantic-to-native adapter is provided.
-/

assert_not_exists FormalSystem.Metalogic.completeness_base
  FormalSystem.Metalogic.completeness_dense FormalSystem.Metalogic.completeness_ztime
  FormalSystem.Metalogic.completeness_rtime

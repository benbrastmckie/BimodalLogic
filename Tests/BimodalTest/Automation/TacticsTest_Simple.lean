/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.Commands

/-!
# Simple Tests for Automation Tactics

Basic compilation tests to verify tactics type-check correctly.
-/

namespace BimodalTest.Automation.Simple

open FormalSystem.Syntax FormalSystem.ProofSystem

-- NOTE (Task 365): quarantined — the `apply_axiom`, `modal_t`, and `assumption_search`
-- tactic macros were removed in a prior automation refactor. The current search tactics are
-- `modal_search`, `temporal_search`, `propositional_search`, and `tm_auto` (see
-- Bimodal/Automation/Tactics/Commands.lean). The helper-function checks below remain valid.
-- #check (@apply_axiom : Lean.ParserDescr)
-- #check (@modal_t : Lean.ParserDescr)
-- #check (@assumption_search : Lean.ParserDescr)

-- Test helper functions
#check FormalSystem.Automation.is_box_formula
#check FormalSystem.Automation.is_future_formula
#check FormalSystem.Automation.extract_from_box
#check FormalSystem.Automation.extract_from_future

end BimodalTest.Automation.Simple

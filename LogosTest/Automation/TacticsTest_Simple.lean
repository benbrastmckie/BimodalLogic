import Logos.Automation.Tactics

/-!
# Simple Tests for Automation Tactics

Basic compilation tests to verify tactics type-check correctly.
-/

namespace LogosTest.Automation.Simple

open Logos.Syntax ProofChecker.ProofSystem

-- Test that apply_axiom macro expands correctly
#check (@apply_axiom : Lean.ParserDescr)

-- Test that modal_t macro expands correctly
#check (@modal_t : Lean.ParserDescr)

-- Test that assumption_search elaborator exists
#check (@assumption_search : Lean.ParserDescr)

-- Test helper functions
#check ProofChecker.Automation.is_box_formula
#check ProofChecker.Automation.is_future_formula
#check ProofChecker.Automation.extract_from_box
#check ProofChecker.Automation.extract_from_future

end LogosTest.Automation.Simple

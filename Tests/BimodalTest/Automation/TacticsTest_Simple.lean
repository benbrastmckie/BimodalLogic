import Bimodal.Automation.Tactics

/-!
# Simple Tests for Automation Tactics

Basic compilation tests to verify tactics type-check correctly.
-/

namespace BimodalTest.Automation.Simple

open Bimodal.Syntax Bimodal.ProofSystem

-- Test that apply_axiom macro expands correctly
#check (@apply_axiom : Lean.ParserDescr)

-- Test that modal_t macro expands correctly
#check (@modal_t : Lean.ParserDescr)

-- Test that assumption_search elaborator exists
#check (@assumption_search : Lean.ParserDescr)

-- Test helper functions
#check Bimodal.Automation.is_box_formula
#check Bimodal.Automation.is_future_formula
#check Bimodal.Automation.extract_from_box
#check Bimodal.Automation.extract_from_future

end BimodalTest.Automation.Simple

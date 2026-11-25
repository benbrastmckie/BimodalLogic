/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.PlusLanguage.TemporalViews
import FormalSystem.Tactic.FormulaViews

/-! # Named temporal formula views for TM and TM⁺ -/

assert_not_exists FormalSystem.ProofSystem.DerivationTree
  FormalSystem.PlusLanguage.PlusDerivationTree

namespace FormalSystem.Tactic.TemporalFormulaViews

open FormalSystem.Syntax (Formula)
open FormalSystem.PlusLanguage (PlusFormula)

private theorem after_eq (A B : Formula) : A.after B = Formula.untl A.neg (A.and B) := rfl
private theorem plus_after_eq (A B : PlusFormula) :
    A.after B = PlusFormula.untl A.neg (A.and B) := rfl

register_lview release Formula.release_expand
register_lview trigger Formula.trigger_expand
register_lview weakUntil Formula.weakUntil_expand
register_lview weakSince Formula.weakSince_expand
register_lview strongRelease Formula.strongRelease_expand
register_lview strongTrigger Formula.strongTrigger_expand
register_lview before Formula.before_expand
register_lview inclusiveUntil Formula.inclusiveUntil_expand
register_lview inclusiveSince Formula.inclusiveSince_expand
register_lview after after_eq

register_lview release PlusFormula.release_expand
register_lview trigger PlusFormula.trigger_expand
register_lview weakUntil PlusFormula.weakUntil_expand
register_lview weakSince PlusFormula.weakSince_expand
register_lview strongRelease PlusFormula.strongRelease_expand
register_lview strongTrigger PlusFormula.strongTrigger_expand
register_lview before PlusFormula.before_expand
register_lview inclusiveUntil PlusFormula.inclusiveUntil_expand
register_lview inclusiveSince PlusFormula.inclusiveSince_expand
register_lview after plus_after_eq

end FormalSystem.Tactic.TemporalFormulaViews

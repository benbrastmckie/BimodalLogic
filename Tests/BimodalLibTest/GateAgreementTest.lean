/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Countermodels.Boolean.GatedTableau
import BimodalTools.TableauBridge

/-!
# The two gate bundles agree

There are two bundles of the branch gates in this tree. `BimodalTools.TableauBridge`'s
`BranchGates`/`gatesOfBranch` reports them field by field for the decision procedure's JSON
response; `BimodalLib.gatesOK` conjoins them into one `Bool` for a countermodel row's `decide`
discharge. `lakefile.toml` forbids the `BimodalLib -> BimodalTools` import outright, so
duplicating the conjunction was the only route open, and the two must agree or a row could be
admitted on a conjunction the decision procedure would not endorse.

This test library may import both, and that is the whole reason this module exists here rather
than in `BimodalLib`.

Both directions are pinned. Agreement on a passing branch alone would be satisfied by two
predicates that are constantly `true`, so a deliberately broken branch is pinned too.
-/

namespace BimodalLibTest.GateAgreementTest

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open BimodalLib BimodalLib.Countermodels.Boolean.GatedTableau
-- Only the two names used are opened, so the library's own `gatesOK` cannot be shadowed.
open BimodalTools.TableauBridge (gatesOfBranch BranchGates)

/-! ### The positive direction: the landed row's own branch -/

/-- The tooling bundle's conjunction is `true` on the branch the landed row is built from. -/
example :
    (gatesOfBranch statement branch ordering FrameClass.Base).gated = true := by
  decide

/-- And it agrees with the library's single-`Bool` bundle there. -/
example :
    (gatesOfBranch statement branch ordering FrameClass.Base).gated
      = gatesOK statement FrameClass.Base branch ordering := by
  decide

/-! ### The negative direction: a branch that passes nothing

The empty branch denies nothing at the initial label, so the root-denial conjunct fails and both
bundles must come back `false`. Without this case the agreement above would be satisfied by two
predicates that never say `false`.
-/

/-- The empty branch fails the tooling bundle. -/
example :
    (gatesOfBranch statement [] ordering FrameClass.Base).gated = false := by decide

/-- It fails the library bundle too, and the two agree on the failure. -/
example :
    (gatesOfBranch statement [] ordering FrameClass.Base).gated
      = gatesOK statement FrameClass.Base [] ordering := by
  decide

/-- The library bundle is `false` there, asserted outright rather than only by agreement. -/
example : gatesOK statement FrameClass.Base [] ordering = false := by decide

/-! ### A branch with the root denial but nothing else -/

/-- Dropping every saturation step from the branch leaves the root denial in place and breaks
saturation, so both bundles still refuse it. -/
example :
    (gatesOfBranch statement [⟨.neg, statement, label 0 0⟩] ordering
        FrameClass.Base).gated
      = gatesOK statement FrameClass.Base [⟨.neg, statement, label 0 0⟩] ordering := by
  decide

end BimodalLibTest.GateAgreementTest

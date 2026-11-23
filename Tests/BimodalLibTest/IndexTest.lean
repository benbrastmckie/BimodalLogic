/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Index
import BimodalLib.Theorems.ModalTemporalBoolean.Base

/-!
# Tests of the polarity census and of the declared duals

The census reads the defined operators off the primitives, most specific pattern first. The
dual of a row is read back from the row.
-/

namespace BimodalLibTest.IndexTest

open FormalSystem.Syntax BimodalLib

/-- A sample atom. -/
def p : Formula := .atom (Atom.mkFresh "p" 0)

/-! ### Each defined operator is recognized -/

#guard polarityF p.box == { box := true }
#guard polarityF p.diamond == { diamond := true }
#guard polarityF p.allFuture == { allFuture := true }
#guard polarityF p.someFuture == { someFuture := true }
#guard polarityF p.allPast == { allPast := true }
#guard polarityF p.somePast == { somePast := true }
#guard polarityF p.always == { always := true }
#guard polarityF p.sometimes == { sometimes := true }

/-! ### The operators inside a defined operator are not counted again -/

#guard polarityF (p.box.imp p.always) == { box := true, always := true }
#guard polarityF (p.sometimes.imp p.diamond) == { sometimes := true, diamond := true }
#guard polarityF (p.allFuture.imp p.someFuture.allPast)
  == { allFuture := true, someFuture := true, allPast := true }

/-! ### Until and Since with a guard are neither `F` nor `P` -/

#guard polarityF (.untl p p) == {}
#guard polarityF (.snce p p) == {}

/-! ### A declared dual is read back from the row -/

#guard (BimodalLib.Registry.FormalSystem.Theorems.Perpetuity.perpetuity1).dual
  == some `FormalSystem.Theorems.Perpetuity.perpetuity2
#guard (BimodalLib.Registry.FormalSystem.Theorems.Perpetuity.bridge1).dual == none

end BimodalLibTest.IndexTest

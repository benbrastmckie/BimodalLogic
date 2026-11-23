/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Fragment

/-!
# Tests of the fragment computation

The fragment and the modal operator set of sample formulas of both languages, and the axioms
the agreement theorem depends on.
-/

namespace BimodalLibTest.FragmentTest

open FormalSystem.Syntax FormalSystem.PlusLanguage BimodalLib

/-- A sample atom of the base language. -/
def p : Formula := .atom (Atom.mkFresh "p" 0)

/-- A sample atom of the extended language. -/
def q : PlusFormula := .atom (Atom.mkFresh "q" 0)

/-! ### The base language -/

example : fragmentF (p.imp .bot) = .Boolean := by decide
example : fragmentF (p.box.imp p) = .ModalBoolean := by decide
example : fragmentF (.untl p (p.imp p)) = .TemporalBoolean := by decide
example : fragmentF (p.box.imp (.snce p p)) = .ModalTemporalBoolean := by decide

/-! Defined operators are counted through their definitions. -/

example : fragmentF p.diamond = .ModalBoolean := by decide
example : fragmentF (p.and (p.or p)) = .Boolean := by decide
example : fragmentF p.allFuture = .TemporalBoolean := by decide
example : fragmentF p.somePast = .TemporalBoolean := by decide
example : fragmentF (p.box.imp p.always) = .ModalTemporalBoolean := by decide

/-! ### The extended language: `⊡` is in the Modal family, and is its own coordinate -/

example : fragmentP (q.imp q) = .Boolean := by decide
example : fragmentP q.stab = .ModalBoolean := by decide
example : fragmentP q.box = .ModalBoolean := by decide
example : fragmentP (q.stab.imp (.untl q q)) = .ModalTemporalBoolean := by decide
example : profileP q.stab = { stab := true } := by decide
example : profileP (q.box.imp q.stab) = { box := true, stab := true } := by decide
example : (profileP q.box).opsName = "□" := by decide
example : (profileP (q.box.imp q.stab)).opsName = "□, ⊡" := by decide

/-! ### Inclusion of profiles -/

example : (profileF p) ≤ (profileF p.box) := by decide
example : ¬ (profileF p.box) ≤ (profileF p.allFuture) := by decide
example : (profileP q.box) ≤ (profileP (q.box.imp q.stab)) := by decide

/-! ### The embedding -/

example : fragmentP (ofFormula (p.box.imp p.always)) = .ModalTemporalBoolean := by
  rw [fragmentP_ofFormula]; decide

/-- info: 'BimodalLib.profileP_ofFormula' depends on axioms: [propext] -/
#guard_msgs in
#print axioms BimodalLib.profileP_ofFormula

end BimodalLibTest.FragmentTest

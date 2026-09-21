/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Examples.Walkthrough

/-!
# Axiom assertions for the worked walkthrough

`FormalSystem/Examples/Walkthrough.lean` advertises itself as resting on nothing beyond Lean's
own classical foundation. This file makes that claim an assertion rather than a promise: every
named declaration in the walkthrough gets a `#guard_msgs`-pinned `#print axioms` row, so a
declaration that quietly acquires a new dependency fails the build instead of changing a number
nobody re-reads.

The permitted sets are `propext`, `Classical.choice` and `Quot.sound` -- Lean's own -- or any
subset. Nothing else is a new baseline; in particular `Lean.ofReduceBool`, which a stray
`native_decide` would introduce, is a hard stop.

The audits live here rather than in the walkthrough itself so that the library module stays free
of debug directives and reads as continuous prose.
-/

/-! ### The two formulas, and the atom they are built from

Syntax carries no proof obligation at all, so these rest on nothing.
-/

/-- info: 'FormalSystem.Examples.Walkthrough.pAtom' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.pAtom

/-- info: 'FormalSystem.Examples.Walkthrough.pF' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.pF

/-- info: 'FormalSystem.Examples.Walkthrough.tFml' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.tFml

/-! ### Leg 1 -- the derivations

A derivation tree is a finite piece of data; building one needs no choice principle, and the
automation-found tree is no different in kind from the hand-built one.
-/

/-- info: 'FormalSystem.Examples.Walkthrough.tByHand' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.tByHand

/-- info: 'FormalSystem.Examples.Walkthrough.boxedT' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.boxedT

/-- info: 'FormalSystem.Examples.Walkthrough.tByAuto' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.tByAuto

/-! ### Legs 2 and 3 -- soundness out, completeness back

Soundness and completeness are where the classical foundation enters.
-/

/-- info: 'FormalSystem.Examples.Walkthrough.tValid' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.tValid

/-- info: 'FormalSystem.Examples.Walkthrough.tDerivable' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.tDerivable

/-! ### Leg 4 -- the decision procedure

`tIsValid` is settled by `decide`, i.e. by kernel reduction. It must never be settled by
`native_decide`, which would add `Lean.ofReduceBool` to this row and is the single drift this
file most needs to catch.
-/

/-- info: 'FormalSystem.Examples.Walkthrough.tIsValid' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.tIsValid

/-- info: 'FormalSystem.Examples.Walkthrough.tValidViaTableau' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.tValidViaTableau

/-! ### Leg 5 -- frame-class sensitivity and the countermodel

The countermodel's frame and instances are built over Mathlib's integers, which is where the
classical axioms come from; nothing here reaches past them.
-/

/-- info: 'FormalSystem.Examples.Walkthrough.ggFml' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.ggFml

/-- info: 'FormalSystem.Examples.Walkthrough.ggAtDense' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.ggAtDense

/-- info: 'FormalSystem.Examples.Walkthrough.Dz' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.Dz

/-- info: 'FormalSystem.Examples.Walkthrough.instSuccDz' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.instSuccDz

/-- info: 'FormalSystem.Examples.Walkthrough.instNoMaxDz' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.instNoMaxDz

/-- info: 'FormalSystem.Examples.Walkthrough.blipF' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.blipF

/-- info: 'FormalSystem.Examples.Walkthrough.blipFrame' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.blipFrame

/-- info: 'FormalSystem.Examples.Walkthrough.gapStep' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.gapStep

/-- info: 'FormalSystem.Examples.Walkthrough.blipFrame_isZTime' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.blipFrame_isZTime

/-- info: 'FormalSystem.Examples.Walkthrough.blipRefutes' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.blipRefutes

/-- info: 'FormalSystem.Examples.Walkthrough.notValidGg' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.notValidGg

/-- info: 'FormalSystem.Examples.Walkthrough.notValidZTimeGg' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.notValidZTimeGg

/-- info: 'FormalSystem.Examples.Walkthrough.ggNotBase' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.ggNotBase

/-- info: 'FormalSystem.Examples.Walkthrough.ggNotZTime' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.ggNotZTime

/-! ### Leg 6 -- the strong-completeness refutation

A restatement of an in-tree result, so it inherits exactly that result's axiom set.
-/

/--
info: 'FormalSystem.Examples.Walkthrough.zTimeStrongCompletenessFails' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Examples.Walkthrough.zTimeStrongCompletenessFails

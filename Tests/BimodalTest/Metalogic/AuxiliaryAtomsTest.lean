/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.AuxiliaryAtoms

/-!
# Evidence for the Auxiliary-Atoms rule

This module is **permanent evidence**, not a conventional test. It pins the axiom profiles of the
Auxiliary-Atoms rule's six load-bearing declarations as `#guard_msgs`-gated `#print axioms`
blocks. These are build-breaking: if a profile moves, this module stops compiling. Every profile
recorded below was *measured* in the same dispatch that landed the rule, never typed from memory
and never carried over from `Semantics/ConeUnravellingTest.lean`.

## When one of these guards fires

A red build here means an axiom profile moved. The expected block is updated **in the same commit
as the change that moved it**, with the move justified in that commit — never updated on its own
to turn a red build green. A guard silently re-baselined to match whatever the tree now does
records nothing and protects nothing.

Two of the six are worth reading before re-baselining anything:

* `plusTruthAt_congr_of_fresh_family` depends on `propext` **alone**. It is a seven-case induction
  over `PlusFormula` whose arms are `imp_congr`, `forall_congr'`, `exists_congr` and friends, and
  nothing in it chooses or quotients. A profile growing here would mean the freshness congruence
  acquired a classical step, which for a statement of this shape would be worth understanding
  rather than accepting.
* `aa_sound_int` is the headline, and its ceiling is `[propext, Classical.choice, Quot.sound]` —
  the same ceiling as `Semantics.exists_coneUnravelling`, which the construction runs on, and the
  same as `Metalogic.NamingRules.clock_irr_sound`, the rule this one extends. So the
  Auxiliary-Atoms route adds **no new axiom cost** over either the cone it is built on or the
  naming rules it sits beside. `Classical.choice` is genuinely consumed, and at exactly one site:
  `aaIdx`'s `dite` on "some `aᵢ` holds at a point whose state is this one", whose real branch
  takes `h.choose`.

## What this module does not pin

It does **not** pin that `hexh` — exhaustiveness of the input family — is unread by
`aa_sound_int`'s proof. That is recorded where it belongs: at the declaration's own doc comment,
in the scoped `set_option linter.unusedVariables false in` beside it, and in
`scripts/nolint-attribute-allowlist.txt`. No axiom check and no name-existence check can see the
difference between a hypothesis consumed and a hypothesis carried, which is why a guard cannot
substitute for that record.

It also does not pin any completeness, decidability or axiomatizability claim, because the module
under test makes none.
-/

namespace BimodalTest.Metalogic

/-! ## Axiom profiles

Every block below is build-breaking: `#guard_msgs` compares the `#print axioms` info message
against the expected text and fails the build on any difference.
-/

/-! ### Forgetting the auxiliary atoms

The finite-family freshness congruence is what discharges the auxiliary letters. It is
`propext`-only.
-/

/-- info: 'FormalSystem.Metalogic.AuxiliaryAtoms.plusTruthAt_congr_of_fresh_family' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.AuxiliaryAtoms.plusTruthAt_congr_of_fresh_family

/-! ### The machine's step identity

`aaState_step` reads the cone's recorded path and the base frame's task relation through
`coneFrame_taskRel`, hence the standard three.
-/

/-- info: 'FormalSystem.Metalogic.AuxiliaryAtoms.aaState_step' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.AuxiliaryAtoms.aaState_step

/-! ### The antecedent at the constructed model

`Classical.choice` enters through `aaIdx`, which `plusTruthAt_aaAnte` consumes via `aaIdx_spec`.
-/

/-- info: 'FormalSystem.Metalogic.AuxiliaryAtoms.plusTruthAt_aaAnte' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.AuxiliaryAtoms.plusTruthAt_aaAnte

/-! ### The three headlines -/

/-- info: 'FormalSystem.Metalogic.AuxiliaryAtoms.aa_sound_int' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.AuxiliaryAtoms.aa_sound_int

/-- info: 'FormalSystem.Metalogic.AuxiliaryAtoms.aa_sound_ztime' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.AuxiliaryAtoms.aa_sound_ztime

/--
info: 'FormalSystem.Metalogic.AuxiliaryAtoms.aa_reflectTime_sound_ztime' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.AuxiliaryAtoms.aa_reflectTime_sound_ztime

end BimodalTest.Metalogic

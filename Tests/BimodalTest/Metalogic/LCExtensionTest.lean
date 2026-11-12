/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.LCExtension

/-!
# Evidence for the extended L⁺ proof system

This module is **permanent evidence**, not a conventional test. It pins the axiom profiles of
`Metalogic/LCExtension.lean`'s ten load-bearing declarations as `#guard_msgs`-gated
`#print axioms` blocks. These are build-breaking: if a profile moves, this module stops
compiling. Every profile recorded below was *measured* in the same dispatch that landed the
module, by `lake env lean` on a file importing it — never typed from the research report and
never carried over from `Metalogic/AuxiliaryAtomsTest.lean`.

The blocks live here rather than beside the declarations because a live `#print axioms` under
`FormalSystem/` is allow-listed for `FormalSystem/MainResults.lean` alone, which is the same
reason `Metalogic/AuxiliaryAtomsTest.lean` exists.

## When one of these guards fires

A red build here means an axiom profile moved. The expected block is updated **in the same commit
as the change that moved it**, with the move justified in that commit — never updated on its own
to turn a red build green. A guard silently re-baselined to match whatever the tree now does
records nothing and protects nothing.

All ten sit at the same ceiling, `[propext, Classical.choice, Quot.sound]`, and that uniformity is
itself the fact worth reading. The extension adds no axiom cost over the three soundness theorems
it assembles: `plus_soundness_ztime`, `Metalogic.NamingRules.clock_irr_sound` and
`Metalogic.AuxiliaryAtoms.aa_sound_ztime` are each already at that ceiling, so `ext_sound_ztime`
inherits it rather than contributing anything of its own. `Classical.choice` is consumed
downstream, not here — notably at `aaIdx`'s `dite` inside the Auxiliary-Atoms construction.

Two of the original six are worth a second look before re-baselining anything:

* `ext_sound_validIn` is the class-generic arm and discharges both Auxiliary-Atoms cases by
  contradiction, so it never touches the cone construction at all. It nonetheless sits at the
  full ceiling, which it inherits through `plus_soundness_validIn` and `clock_irr_sound`. A
  profile *shrinking* here would mean one of those two became constructive, which would be worth
  understanding.
* `isLCAxiom_plusValidZTime` and `isLCUAxiom_plusValidZTime` are two-case `obtain` splits over
  the schema and its mirror, with all four arms quoting `PlusLanguage/PlusLCSchema.lean`. Their
  profile is entirely that file's; growth here would be growth there.

The four added by the deterministic-frames soundness arm (`lcAnte_iff_lcCons_of_deterministic`,
`lcN_plusValidOn_of_deterministic`, `isLCAxiom_plusValidDetIn_base`, `ext_sound_detIn`) were
MEASURED, not typed from the plan or the report that produced this module's probe precedent, and
land at the same ceiling: `ext_sound_detIn` inherits it through `plus_soundness_validIn`
(`PlusValidIn.toDet`) and `clock_irr_sound`, exactly as `ext_sound_validIn` does; the other three
inherit it from `FormalSystem.PlusLanguage.dstab_iff_of_deterministic`
(`[propext, Classical.choice, Quot.sound]`, per `PlusDeterminism.lean`'s own C4 pin) through
`stab_iff_of_deterministic`.

## What this module does not pin

It pins **no completeness, decidability or axiomatizability claim**, because the module under test
makes none. `LCComplete`, `LCRulesComplete` and `LCURulesComplete` are `Prop`-valued `def`s with
no proof term; there is nothing about them for an axiom profile to record, and the absence of a
guard for any of the three is deliberate rather than an omission. An axiom check cannot see the
difference between a target that is open and a target that is false, which is why no guard here
should ever be read as evidence about one.

Nor does it pin that `ExtDerivation` leaves `ProofSystem/`'s `PlusDerivationTree` and `PlusAxiom`
untouched. That is a structural fact about where the inductive lives, recorded in the module
docstring, and no axiom profile can observe it.
-/

namespace BimodalTest.Metalogic

/-! ## Axiom profiles

Every block below is build-breaking: `#guard_msgs` compares the `#print axioms` info message
against the expected text and fails the build on any difference.
-/

/-! ### The two axiom sets' validity

Each is a two-case split over the schema and its `reflectTime` mirror, so each profile is
inherited wholesale from `PlusLanguage/PlusLCSchema.lean`.
-/

/-- info: 'FormalSystem.Metalogic.LCExtension.isLCAxiom_plusValidZTime' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.isLCAxiom_plusValidZTime

/--
info: 'FormalSystem.Metalogic.LCExtension.isLCUAxiom_plusValidZTime' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.isLCUAxiom_plusValidZTime

/-! ### The headline, and the class-generic arm

`ext_sound_ztime` admits all three naming rules and so runs through the cone construction;
`ext_sound_validIn` admits none of the two Auxiliary-Atoms rules and discharges them by
contradiction. Both land at the same ceiling.
-/

/-- info: 'FormalSystem.Metalogic.LCExtension.ext_sound_ztime' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.ext_sound_ztime

/-- info: 'FormalSystem.Metalogic.LCExtension.ext_sound_validIn' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.ext_sound_validIn

/-! ### The soundness half of the three targets

These are `ext_sound_ztime` instantiated at the two axiom sets, so they add nothing of their own.
-/

/-- info: 'FormalSystem.Metalogic.LCExtension.ext_sound_lc_ztime' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.ext_sound_lc_ztime

/-- info: 'FormalSystem.Metalogic.LCExtension.ext_sound_lcU_ztime' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.ext_sound_lcU_ztime

/-! ### The deterministic-frames soundness arm

The non-derivability argument's load-bearing half (recorded in
`PlusLanguage/PlusLCSchema.lean`'s docstring): `lcN`'s validity on every deterministic frame, and
`ExtDerivation`'s soundness transported down to the deterministic frames of an arbitrary class.
All four were measured by `lean_verify` on the fully qualified name, in the same dispatch that
landed them, never typed from the plan or the report. -/

/--
info: 'FormalSystem.Metalogic.LCExtension.lcAnte_iff_lcCons_of_deterministic' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.lcAnte_iff_lcCons_of_deterministic

/--
info: 'FormalSystem.Metalogic.LCExtension.lcN_plusValidOn_of_deterministic' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.lcN_plusValidOn_of_deterministic

/--
info: 'FormalSystem.Metalogic.LCExtension.isLCAxiom_plusValidDetIn_base' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.isLCAxiom_plusValidDetIn_base

/-- info: 'FormalSystem.Metalogic.LCExtension.ext_sound_detIn' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.LCExtension.ext_sound_detIn

end BimodalTest.Metalogic

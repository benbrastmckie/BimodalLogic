/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Pairing
import BimodalLib.Theorems.ModalTemporalBoolean.Base

/-!
# Tests of the pairing command

`reprove X as Y := t` accepts a second proof of the statement registered for `X` and rejects a
proof of anything else. The accepted proof here assembles the first perpetuity principle from
its three components directly; the rejected one is a proof of the second principle offered for
the first.
-/

namespace BimodalLibTest.PairingTest

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Theorems.Perpetuity
open FormalSystem.Theorems.Combinators BimodalLib

/-! ### A second proof is accepted and paired -/

reprove FormalSystem.Theorems.Perpetuity.perpetuity1 as perpetuity1Again :=
  fun φ => combineImpConj3 (boxToPast φ) (boxToPresent φ) (boxToFuture φ)

/-- The second proof has the type of the registered declaration. -/
example : @perpetuity1Again = @perpetuity1 → True := fun _ => trivial

/-- The pairing row holds the row of the registered statement. -/
example : (BimodalLib.Reproofs.BimodalLibTest.PairingTest.perpetuity1Again).entry
    = BimodalLib.Registry.FormalSystem.Theorems.Perpetuity.perpetuity1 := rfl

/-- info: 'BimodalLib.Reproofs.BimodalLibTest.PairingTest.perpetuity1Again' depends on axioms: [propext] -/
#guard_msgs in
#print axioms BimodalLib.Reproofs.BimodalLibTest.PairingTest.perpetuity1Again

/-! ### A drifted proof is a type error, and declares nothing -/

/--
error: Type mismatch
  perpetuity2 φ
has type
  ⊢[fc] (▽φ).imp φ.diamond
but is expected to have type
  ⊢[fc] φ.box.imp (△φ)
-/
#guard_msgs in
reprove FormalSystem.Theorems.Perpetuity.perpetuity1 as perpetuity1Drifted :=
  fun {fc} φ => (perpetuity2 φ : ⊢[fc] φ.sometimes.imp φ.diamond)

/-- error: Unknown identifier `perpetuity1Drifted` -/
#guard_msgs in
#check perpetuity1Drifted

/-! ### A declaration with no registry row cannot be re-proved

The row of `identity` is in the `Boolean` registration module, which this module does not
import. -/

/--
error: reprove: identity has no registry row; register it with `register_theorem` first
-/
#guard_msgs in
reprove FormalSystem.Theorems.Combinators.identity as identityAgain := fun φ => identity φ

end BimodalLibTest.PairingTest

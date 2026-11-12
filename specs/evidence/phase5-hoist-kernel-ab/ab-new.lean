/-
A/B harness, NEW arm: the two kernel obligations under the library's own current
(table) clause shape.

This file is an evidence probe, not part of the library. It is deliberately NOT wired into
`scripts/check-evidence-probes.sh`: a wall-clock timing comparison is not a compile-check
invariant, and wiring it would oblige the gate to keep compiling the mirrored per-vertex clause
shape in `ab-old.lean` forever.

The two obligations are the kernel sites the hoist was built for:

  * `TotalEdge.certA.bwdLiveT` -- the hard certificate's backward liveness fixpoint. Its
    cardinality is 16; `TotalEdge.certA_certifies` in
    `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` depends on this
    fixpoint, and it is the expensive part of that `decide`.
  * `(Embedded.liveFamily.sliced (-1)).liveAt (-1)` -- the small embedded witness, mirroring the
    `example` guarded by `maxHeartbeats 20000` in that same file.

`maxHeartbeats 0` is correct HERE and nowhere in the library: this file measures how long each
clause shape takes, so a heartbeat cap would convert a slow arm into a failure and destroy the
very measurement. `ab-old.lean` sets the same options, so the two arms are compared under
identical elaboration settings.

`profiler true` is what makes the two sites separable inside one file: Lean reports
`tactic execution of ... decide took` and `type checking took` per declaration, in source order,
so each site's kernel cost (`type checking`) is read off the same run rather than requiring a
fourth and fifth file.

Measured at commit e2c2662e0461024619ba2c628cc0610932f9421f, toolchain
leanprover/lean4:v4.33.0-rc1. Raw timings, medians and ratios: see README.md beside this file.
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate
open FormalSystem.Metalogic.Decidability.WitnessFamily

namespace FormalSystem.Metalogic.Decidability.Evidence.Phase5HoistAB.New

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 0 in
set_option profiler true in
/-- Site 1 (hard certificate): the backward liveness fixpoint at `certA`, under the library's
table clause shape (`untlTable`/`snceTable` read through `untlLiveAtTab`/`snceLiveAtTab`). -/
example : TotalEdge.certA.bwdLiveT.card = 16 := by decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 0 in
set_option profiler true in
/-- Site 2 (small embedded witness): the `liveAt` cardinality at the embedded lasso certificate,
under the same table clause shape. -/
example : ((Embedded.liveFamily.sliced (-1)).liveAt (-1)).card = 1 := by decide

end FormalSystem.Metalogic.Decidability.Evidence.Phase5HoistAB.New

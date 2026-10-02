/-
Probe 704 (research round 1): does an embedded L witness family, read as a time-sliced
certificate, satisfy `PlusSlicedCertificate.Certifies` by kernel `decide`?

CAVEAT recorded at probe time: the .lake/build oleans predated the filtered `TailStable`
(sources 2026-10-02 01:54, oleans 2026-10-01 10:42). Re-run after `lake build`.
Compile from the repository root with: lake env lean <this file>
-/
import FormalSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.WitnessFamily

-- (a2) feasibility probe: does the embedded live family's sliced certificate `Certifies` by `decide`?
set_option maxRecDepth 4096 in
theorem probe_liveFamily_sliced_certifies : (Embedded.liveFamily.sliced (-1)).Certifies := by decide

set_option maxRecDepth 4096 in
theorem probe_snceLive_sliced_certifies : (SnceProbe.snceProbeLiveFamily.sliced 0).Certifies := by decide

#print axioms probe_liveFamily_sliced_certifies
#print axioms probe_snceLive_sliced_certifies

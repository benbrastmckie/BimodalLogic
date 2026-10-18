/-
Isolated `verts` factor, measured this round (plan D4): the pre-Shape-D filter body is
re-declared under the scratch name `vertsOld` (taken verbatim from `Timed.lean` at commit
960e39ede) and timed beside the landed Shape D `verts` at the width-2 total-edge witness `certA`.

The parent's probe 24 timed `vertsD` beside the then-landed filter-shaped `verts`; today `verts`
IS Shape D, so this probe inverts the roles rather than timing Shape D against itself. Compiled
standalone:

  lake env lean specs/782_phase7_verts_shape_d_decomposition/probes/02_old_vs_landed_measure.lean

Cap is explicit and finite (the parent's probe-24 cap). The figures are evidence for the
summary, not a gate: both cards must read 16 and the equality must print `true`; the factor is
recorded whatever it is.
-/
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Examples

set_option maxHeartbeats 2000000

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.PlusLanguage
namespace PlusSlicedCertificate

/-- The pre-Shape-D `verts` body at commit 960e39ede, verbatim, under a scratch name. -/
def vertsOld (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  (Finset.univ ×ˢ G.winTimes).filter (fun v => v.1 ∈ G.posAt v.2)

open TotalEdge in
section
-- Landed: the biUnion/image Shape D `verts`.
#time #eval (certA.verts).card
-- Old: the filter-over-product shape.
#time #eval (certA.vertsOld).card
-- Agreement on the concrete witness.
#time #eval (certA.verts = certA.vertsOld)
end

end PlusSlicedCertificate
end FormalSystem.Metalogic.Decidability

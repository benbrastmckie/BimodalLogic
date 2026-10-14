import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Examples

set_option maxHeartbeats 2000000

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.PlusLanguage
namespace PlusSlicedCertificate

/-- Shape D, restated here so it can be timed against the landed `verts`. -/
def vertsD (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))

open TotalEdge in
section
-- Baseline: the landed filter-shaped verts.
#time #eval (certA.verts).card
-- Shape D: the biUnion/image form.
#time #eval (certA.vertsD).card
-- Agreement on the concrete witness.
#time #eval (certA.verts = certA.vertsD)
end

end PlusSlicedCertificate
end FormalSystem.Metalogic.Decidability

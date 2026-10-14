import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Complete

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.PlusLanguage
namespace PlusSlicedCertificate
variable {Γ Del : PlusContext}

/-- Shape B's succT/predT `let`-hoist, in isolation from the position table. -/
def succTH (G : PlusSlicedCertificate Γ Del) (v : G.TPos) : Finset G.TPos :=
  let V := G.verts
  let u := G.nextTime v.2
  let S := G.succP v.2 v.1
  V.filter (fun w => w.2 = u ∧ w.1 ∈ S)

def predTH (G : PlusSlicedCertificate Γ Del) (v : G.TPos) : Finset G.TPos :=
  let V := G.verts
  let u := G.prevTime v.2
  let P := G.predP v.2 v.1
  V.filter (fun w => w.2 = u ∧ w.1 ∈ P)

-- CLAIM A: the let-hoist is zeta-equal to the landed definition (no proof obligation at all).
theorem succTH_eq (G : PlusSlicedCertificate Γ Del) (v : G.TPos) : G.succTH v = G.succT v := rfl
theorem predTH_eq (G : PlusSlicedCertificate Γ Del) (v : G.TPos) : G.predTH v = G.predT v := rfl

-- CLAIM B: the let-hoist transfers across withBx by rfl.
theorem withBx_succTH (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) (v : G.TPos) :
    (G.withBx bx).succTH v = G.succTH v := rfl
theorem withBx_predTH (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) (v : G.TPos) :
    (G.withBx bx).predTH v = G.predTH v := rfl

end PlusSlicedCertificate
end FormalSystem.Metalogic.Decidability

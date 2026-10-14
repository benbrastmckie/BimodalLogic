/-
Phase 7 pre-aggregate check: the three `withBx` `rfl` transfers against the EDITED
`Timed.lean`, not against a shape defined beside it.

Probe 21 established the transfer for a `vertsD` defined alongside the landed `verts`; this
probe asks the same question of the landed names after the body swap, which is the check the
earlier table-shaped attempt failed. Compiled standalone:

  lake env lean specs/716_sliced_certificate_liveat_nontermination/probes/25_shapeD_landed_transfer.lean

The cap is explicit and finite, and deliberately NOT raised: the failure mode this probe guards
against is `isDefEq` returning false, which no cap bump reaches.
-/
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Complete

set_option maxHeartbeats 200000

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.PlusLanguage
namespace PlusSlicedCertificate
variable {Γ Del : PlusContext}

-- CHECK 1: the biUnion-shaped `verts` transfers across a changed box guess by `rfl`.
example (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).verts = G.verts := rfl

-- CHECK 2: the let-hoisted `succT` transfers.
example (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) (v : G.TPos) :
    (G.withBx bx).succT v = G.succT v := rfl

-- CHECK 3: the let-hoisted `predT` transfers.
example (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) (v : G.TPos) :
    (G.withBx bx).predT v = G.predT v := rfl

-- CONTROL: `mem_verts` still has its pre-phase statement, and is not an axiom.
example (G : PlusSlicedCertificate Γ Del) (v : G.TPos) :
    v ∈ G.verts ↔ v.2 ∈ G.winTimes ∧ v.1 ∈ G.posAt v.2 := G.mem_verts v

#print axioms PlusSlicedCertificate.mem_verts
#print axioms PlusSlicedCertificate.mem_succT
#print axioms PlusSlicedCertificate.mem_predT

end PlusSlicedCertificate
end FormalSystem.Metalogic.Decidability

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Complete

set_option maxHeartbeats 2000000

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.PlusLanguage
namespace PlusSlicedCertificate
variable {Γ Del : PlusContext}

def posTable (G : PlusSlicedCertificate Γ Del) : List (ℤ × Finset G.Pos) :=
  (List.range (G.winHi - G.winLo + 2).toNat).map fun i =>
    (G.winLo - 1 + (i : ℤ), G.posAt (G.winLo - 1 + (i : ℤ)))

def vertsB (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  let tbl := G.posTable
  (Finset.univ ×ˢ G.winTimes).filter (fun v =>
    v.1 ∈ match tbl.find? (fun p => p.1 == v.2) with
          | some p => p.2
          | none => G.posAt v.2)

-- Does the table itself transfer?
theorem withBx_posTable (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).posTable = G.posTable := rfl

-- Does the table-filtered verts transfer? (the reported failure)
theorem withBx_vertsB (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).vertsB = G.vertsB := rfl

end PlusSlicedCertificate
end FormalSystem.Metalogic.Decidability

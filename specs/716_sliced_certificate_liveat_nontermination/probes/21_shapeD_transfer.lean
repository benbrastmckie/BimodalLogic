import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Complete

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.PlusLanguage
namespace PlusSlicedCertificate
variable {Γ Del : PlusContext}

/-- Shape D: one `posAt` call per window time, no table, no cache, no `let`. -/
def vertsD (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))

-- CLAIM 1: Shape D transfers across withBx by rfl (the Complete.lean invariant survives).
theorem withBx_vertsD (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).vertsD = G.vertsD := rfl

-- CLAIM 2: the characterization is provable, with a statement identical to mem_verts'.
theorem mem_vertsD (G : PlusSlicedCertificate Γ Del) (v : G.TPos) :
    v ∈ G.vertsD ↔ v.2 ∈ G.winTimes ∧ v.1 ∈ G.posAt v.2 := by
  rw [vertsD, Finset.mem_biUnion]
  constructor
  · rintro ⟨t, ht, hv⟩
    rw [Finset.mem_image] at hv
    obtain ⟨p, hp, rfl⟩ := hv
    exact ⟨ht, hp⟩
  · rintro ⟨ht, hp⟩
    exact ⟨v.2, ht, Finset.mem_image.mpr ⟨v.1, hp, rfl⟩⟩

-- CLAIM 3: Shape D equals the landed verts, so nothing downstream can observe the swap.
theorem vertsD_eq_verts (G : PlusSlicedCertificate Γ Del) : G.vertsD = G.verts := by
  ext v; rw [mem_vertsD, G.mem_verts]

-- CONTROL: the landed verts transfers by rfl today (baseline for comparison).
theorem withBx_verts_control (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).verts = G.verts := rfl

#print axioms withBx_vertsD
#print axioms mem_vertsD
#print axioms vertsD_eq_verts

end PlusSlicedCertificate
end FormalSystem.Metalogic.Decidability

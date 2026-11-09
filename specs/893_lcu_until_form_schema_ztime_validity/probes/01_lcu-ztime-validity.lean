/-
Verified probe for the until-form limit-closure schema `lcU` and its ZTime validity.

Run with: lean_run_code (lean-lsp MCP), or `lake env lean <this file>` from the repository root.
Result of record: compiles with ZERO errors and ZERO sorries; all four declarations carry the
tree's standard `pcq` profile `[propext, Classical.choice, Quot.sound]`.

The only piece that is NOT a verbatim candidate for the library is the name
`int_marker_bracket'` (primed here to avoid colliding with the real declaration this probe
proposes adding to `FormalSystem/PlusLanguage/PlusOmegaChain.lean` as `int_marker_bracket`).
-/
import FormalSystem.PlusLanguage.PlusLCSchema

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics
open PartialHistory
open PlusTruth

/-- Proposed for `PlusOmegaChain.lean`'s `ℤ` discharge section, after `int_marker_exists_gt`. -/
theorem int_marker_bracket' {c : ℕ → ℤ} (hc : ∀ k, c k < c (k + 1)) {s : ℤ} (h0 : c 0 ≤ s) :
    ∃ k, c k ≤ s ∧ s < c (k + 1) := by
  have hex : ∃ m, s < c m := by
    obtain ⟨m, hm⟩ := intOrder_omega_cofinal c hc (s + 1)
    exact ⟨m, by omega⟩
  have hm : s < c (Nat.find hex) := Nat.find_spec hex
  have hm0 : Nat.find hex ≠ 0 := by
    intro h
    rw [h] at hm
    omega
  obtain ⟨k, hk⟩ : ∃ k, Nat.find hex = k + 1 := ⟨Nat.find hex - 1, by omega⟩
  refine ⟨k, ?_, ?_⟩
  · have h2 := Nat.find_min hex (m := k) (by omega)
    omega
  · rw [← hk]; exact hm

/-- `LCU`: `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))`. -/
def lcU (α β : PlusFormula) : PlusFormula :=
  (PlusFormula.stab ((PlusFormula.dstab α).imp
      (PlusFormula.dstab (PlusFormula.untl (PlusFormula.dstab β)
        (PlusFormula.dstab α)))).gle).imp
    ((PlusFormula.dstab α).imp
      (PlusFormula.dstab ((PlusFormula.dstab α).or
        (PlusFormula.untl (PlusFormula.dstab β) (PlusFormula.dstab α))).gle))

theorem lcU_plusValidInt (α β : PlusFormula) : PlusValidInt (lcU α β) := by
  classical
  intro F _ M σ t hante hα
  have hA : ∀ ρ : WorldHistory F.toTaskFrame, ρ.state t = σ.state t → ∀ s, t ≤ s →
      PlusTruthAt M ρ s (PlusFormula.dstab α) →
      PlusTruthAt M ρ s (PlusFormula.dstab (PlusFormula.untl (PlusFormula.dstab β)
        (PlusFormula.dstab α))) := by
    intro ρ he s hs
    have h1 := hante ρ he.symm
    rw [gle_iff] at h1
    exact h1 s hs
  obtain ⟨ρ, c, hρt, _, hc0, hcl, hcA, hcP⟩ := omega_chain (F := F.toTaskFrame) σ t
      (fun _ s v => ∃ η : WorldHistory F.toTaskFrame, v = η.state s ∧ PlusTruthAt M η s α)
      (fun _ η s s' => ∀ r, s < r → r < s' → PlusTruthAt M η r (PlusFormula.dstab β))
      (fun c hc x => intOrder_omega_cofinal c hc x)
      (by
        intro i η η' s s' hag h r h1 h2
        obtain ⟨κ, hκ, hval⟩ := (dstab_iff M η r β).1 (h r h1 h2)
        exact (dstab_iff M η' r β).2 ⟨κ, (hag r h1 h2.le).trans hκ, hval⟩)
      σ t rfl le_rfl ((dstab_iff M σ t α).1 hα)
      (by
        intro ρ' he k s hs hk
        have h1 := hA ρ' he s hs ((dstab_iff M ρ' s α).2 hk)
        rw [dstab_iff] at h1
        obtain ⟨η, he', h2⟩ := h1
        rw [untl_iff] at h2
        obtain ⟨s', hlt, hαs', hβ⟩ := h2
        exact ⟨η, s', he'.symm, hlt, (dstab_iff M η s' α).1 hαs', hβ⟩)
  rw [dstab_iff]
  refine ⟨ρ, hρt.symm, ?_⟩
  rw [gle_iff]
  intro s hs
  rw [or_iff]
  right
  rw [untl_iff]
  obtain ⟨k, hk1, hk2⟩ := int_marker_bracket' hcl (s := s) (by rw [hc0]; exact hs)
  refine ⟨c (k + 1), hk2, ?_, ?_⟩
  · exact (dstab_iff M ρ (c (k + 1)) α).2 (hcA (k + 1)).2
  · intro r hr1 hr2
    exact hcP k r (lt_of_le_of_lt hk1 hr1) hr2

theorem lcU_plusValidZTime (α β : PlusFormula) : PlusValidZTime (lcU α β) :=
  (plusValidZTime_iff_plusValidInt (lcU α β)).mpr (lcU_plusValidInt α β)

theorem lcU_reflectTime_plusValidZTime (α β : PlusFormula) :
    PlusValidZTime (lcU α β).reflectTime :=
  plusValidIn_reflectTime (lcU_plusValidZTime α β)

#print axioms FormalSystem.PlusLanguage.int_marker_bracket'
#print axioms FormalSystem.PlusLanguage.lcU_plusValidInt
#print axioms FormalSystem.PlusLanguage.lcU_plusValidZTime
#print axioms FormalSystem.PlusLanguage.lcU_reflectTime_plusValidZTime

end FormalSystem.PlusLanguage

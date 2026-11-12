import FormalSystem.Metalogic.Expressiveness.SeparationZ.Discharge
import FormalSystem.Metalogic.Expressiveness.OpenFutureElimination

namespace Probe899Z

open FormalSystem.Semantics FormalSystem.PlusLanguage FormalSystem.OpenLanguage
open FormalSystem.Metalogic.Expressiveness

variable {F : TaskFrame}

def pastType (M : TaskModel F) (A : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula := {φ | φ ∈ A ∧ PlusTruthAt M σ t φ}

def futType (M : TaskModel F) (B : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula := {ψ | ψ ∈ B ∧ PlusTruthAt M σ t ψ}

def typePair (M : TaskModel F) (A B : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula × Set PlusFormula := (pastType M A σ t, futType M B σ t)

theorem typePair_image_stabClass [F.IsRegular]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (A B : List PlusFormula)
    (hA : ∀ φ ∈ A, PastDet F φ) (hB : ∀ ψ ∈ B, FutDet F ψ) :
    (fun σ => typePair M A B σ t) '' stabClass τ t
      = ((fun σ => pastType M A σ t) '' stabClass τ t)
        ×ˢ ((fun σ => futType M B σ t) '' stabClass τ t) := by
  ext p
  constructor
  · rintro ⟨σ, hσ, rfl⟩
    exact ⟨⟨σ, hσ, rfl⟩, ⟨σ, hσ, rfl⟩⟩
  · rintro ⟨⟨ρ, hρ, hp1⟩, ⟨σ, hσ, hp2⟩⟩
    have hsame : ρ.state t = σ.state t := hρ.symm.trans hσ
    refine ⟨paste ρ σ t hsame, ?_, ?_⟩
    · show τ.state t = (paste ρ σ t hsame).state t
      exact hρ.trans (paste_agreeUpTo ρ σ t hsame t le_rfl).symm
    · have h1 : pastType M A (paste ρ σ t hsame) t = pastType M A ρ t := by
        ext φ
        exact and_congr_right fun hmem =>
          hA φ hmem M _ ρ t (paste_agreeUpTo ρ σ t hsame)
      have h2 : futType M B (paste ρ σ t hsame) t = futType M B σ t := by
        ext ψ
        exact and_congr_right fun hmem =>
          hB ψ hmem M _ σ t (paste_agreeFrom ρ σ t hsame)
      show (pastType M A (paste ρ σ t hsame) t, futType M B (paste ρ σ t hsame) t) = p
      rw [h1, h2, show pastType M A ρ t = p.1 from hp1, show futType M B σ t = p.2 from hp2]

/-- The ZTime plug point: `separationOver_ztime`'s clause list feeds the hypotheses. -/
theorem typePair_image_stabClass_sepZ [F.IsRegular] (hz : F.IsZTime)
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    (fun σ => typePair M ((sepZ φ).map Prod.fst) ((sepZ φ).map Prod.snd) σ t) '' stabClass τ t
      = ((fun σ => pastType M ((sepZ φ).map Prod.fst) σ t) '' stabClass τ t)
        ×ˢ ((fun σ => futType M ((sepZ φ).map Prod.snd) σ t) '' stabClass τ t) := by
  have hL : SepClauses F (sepZ φ) := sepZ_sepClauses φ F ‹F.IsRegular› hz
  refine typePair_image_stabClass M τ t _ _ ?_ ?_
  · intro ψ hψ
    obtain ⟨c, hc, rfl⟩ := List.mem_map.mp hψ
    exact (hL c hc).1
  · intro ψ hψ
    obtain ⟨c, hc, rfl⟩ := List.mem_map.mp hψ
    exact (hL c hc).2

end Probe899Z

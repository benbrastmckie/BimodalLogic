import FormalSystem.Metalogic.Expressiveness.OpenFutureElimination

namespace Probe899

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.Metalogic.Expressiveness

variable {F : TaskFrame}

/-- The past-type of `σ` at `t` over the list `A`. -/
def pastType (M : TaskModel F) (A : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula :=
  {φ | φ ∈ A ∧ PlusTruthAt M σ t φ}

/-- The future-type of `σ` at `t` over the list `B`. -/
def futType (M : TaskModel F) (B : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula :=
  {ψ | ψ ∈ B ∧ PlusTruthAt M σ t ψ}

/-- The (past-type, future-type) pair. -/
def typePair (M : TaskModel F) (A B : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula × Set PlusFormula :=
  (pastType M A σ t, futType M B σ t)

/-- **The stability cluster's type set is a full product.** -/
theorem typePair_image_stabClass [F.IsRegular]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (A B : List PlusFormula)
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
    · have hup : AgreeUpTo (paste ρ σ t hsame) ρ t := paste_agreeUpTo ρ σ t hsame
      have hfr : AgreeFrom (paste ρ σ t hsame) σ t := paste_agreeFrom ρ σ t hsame
      have h1 : pastType M A (paste ρ σ t hsame) t = pastType M A ρ t := by
        ext φ
        exact and_congr_right fun hmem => hA φ hmem M _ ρ t hup
      have h2 : futType M B (paste ρ σ t hsame) t = futType M B σ t := by
        ext ψ
        exact and_congr_right fun hmem => hB ψ hmem M _ σ t hfr
      show (pastType M A (paste ρ σ t hsame) t, futType M B (paste ρ σ t hsame) t) = p
      rw [h1, h2, show pastType M A ρ t = p.1 from hp1, show futType M B σ t = p.2 from hp2]

/-- The realized type set depends only on the world state at `t`. -/
theorem typePair_image_stabClass_state_congr
    (M : TaskModel F) (τ τ' : WorldHistory F) (t : F.Duration)
    (A B : List PlusFormula) (h : τ.state t = τ'.state t) :
    (fun σ => typePair M A B σ t) '' stabClass τ t
      = (fun σ => typePair M A B σ t) '' stabClass τ' t := by
  have : stabClass τ t = stabClass τ' t := by
    ext σ; exact ⟨fun hs => h.symm.trans hs, fun hs => h.trans hs⟩
  rw [this]

/-- `SepClauses`-fed corollary: a separated clause list supplies both hypotheses. -/
theorem typePair_image_stabClass_of_sepClauses [F.IsRegular]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (L : List (PlusFormula × PlusFormula)) (hL : SepClauses F L) :
    (fun σ => typePair M (L.map Prod.fst) (L.map Prod.snd) σ t) '' stabClass τ t
      = ((fun σ => pastType M (L.map Prod.fst) σ t) '' stabClass τ t)
        ×ˢ ((fun σ => futType M (L.map Prod.snd) σ t) '' stabClass τ t) :=
  typePair_image_stabClass M τ t _ _
    (by
      intro φ hφ
      obtain ⟨c, hc, rfl⟩ := List.mem_map.mp hφ
      exact (hL c hc).1)
    (by
      intro ψ hψ
      obtain ⟨c, hc, rfl⟩ := List.mem_map.mp hψ
      exact (hL c hc).2)

end Probe899

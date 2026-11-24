/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Conservativity
import FormalSystem.Metalogic.Conservativity.Fragments.Edges
import FormalSystem.Metalogic.Conservativity.Plus.Forward

/-!
# The conservativity edges that are proved

The edges out of the Boolean cell and out of the cell with `□`, in the registered vocabulary of
derivations within a cell.

The proofs are in `FormalSystem/Metalogic/Conservativity/Fragments/`, over a calculus of
derivations inside an abstract sublanguage. This module identifies the two: the formulas whose
profile is included in a cell are a sublanguage (`cellLanguage_sublanguage`), and a formula is
derivable within a cell exactly when it is derivable inside that sublanguage
(`derivableIn_iff_cellDerivable`).

## Main statements

* `BimodalLib.conservativeEdge_boolean`: the Boolean cell is conserved by the full base system
  at every frame class.
* `BimodalLib.derivableIn_boolean_of_box`, `BimodalLib.derivableIn_boolean_of_temporal`: the
  Boolean cell is conserved by the cell with `□` and by the temporal cell.
* `BimodalLib.conservativeEdge_box`: the cell with `□` is conserved by the full base system at
  every frame class.
* `BimodalLib.derivableIn_box_of_derivableInP`: the cell with `□` is conserved by the cell with
  `□` and `⊡` of the extended system.
-/

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.Metalogic FormalSystem.Metalogic.Conservativity
open FormalSystem.Metalogic.Conservativity.Fragments

/-- The formulas of a cell: those whose profile is included in it. -/
def cellLanguage (c : Profile) : Formula → Prop := fun ψ => profileF ψ ≤ c

/-- The formulas of a cell are a sublanguage. -/
theorem cellLanguage_sublanguage (c : Profile) : Sublanguage (cellLanguage c) where
  bot := Profile.empty_le c
  imp_iff := fun φ ψ => profileF_imp_le_iff φ ψ c
  reflectTime := fun φ h => by
    change profileF φ.reflectTime ≤ c
    rwa [profileF_reflectTime]

/-- A derivation within a cell is a derivation inside the sublanguage of the cell. -/
theorem cellDerivable_of_within {c : Profile} {fc : FrameClass} {Γ : Context} {φ : Formula}
    (d : DerivationTree fc Γ φ) (h : within c d) : CellDerivable (cellLanguage c) fc Γ φ := by
  induction d with
  | «axiom» Γ φ a hfc =>
    simp only [within] at h
    exact .ax Γ φ a hfc h
  | assumption Γ φ hm =>
    simp only [within] at h
    exact .assumption Γ φ hm h
  | modus_ponens Γ φ ψ _ _ ih1 ih2 =>
    simp only [within] at h
    exact .modusPonens Γ φ ψ (ih1 h.2.1) (ih2 h.2.2) h.1
  | necessitation φ _ ih =>
    simp only [within] at h
    exact .necessitation φ (ih h.2) h.1
  | temporal_necessitation φ _ ih =>
    simp only [within] at h
    exact .temporalNecessitation φ (ih h.2) h.1
  | time_reflection φ _ ih =>
    simp only [within] at h
    exact .timeReflection φ (ih h.2) h.1
  | weakening Γ Δ φ _ hsub ih =>
    simp only [within] at h
    exact .weakening Γ Δ φ (ih h.2) hsub

/-- A derivation inside the sublanguage of a cell gives a derivation of the full system within
the cell. -/
theorem exists_within_of_cellDerivable {c : Profile} {fc : FrameClass} {Γ : Context}
    {φ : Formula} (h : CellDerivable (cellLanguage c) fc Γ φ) :
    ∃ d : DerivationTree fc Γ φ, within c d := by
  induction h with
  | ax Γ φ a hfc hL => exact ⟨.axiom Γ φ a hfc, by simp only [within]; exact hL⟩
  | assumption Γ φ hm hL => exact ⟨.assumption Γ φ hm, by simp only [within]; exact hL⟩
  | modusPonens Γ φ ψ _ _ hL ih1 ih2 =>
    obtain ⟨d1, h1⟩ := ih1
    obtain ⟨d2, h2⟩ := ih2
    exact ⟨.modus_ponens Γ φ ψ d1 d2, by simp only [within]; exact ⟨hL, h1, h2⟩⟩
  | necessitation φ _ hL ih =>
    obtain ⟨d, hd⟩ := ih
    exact ⟨.necessitation φ d, by simp only [within]; exact ⟨hL, hd⟩⟩
  | temporalNecessitation φ _ hL ih =>
    obtain ⟨d, hd⟩ := ih
    exact ⟨.temporal_necessitation φ d, by simp only [within]; exact ⟨hL, hd⟩⟩
  | timeReflection φ _ hL ih =>
    obtain ⟨d, hd⟩ := ih
    exact ⟨.time_reflection φ d, by simp only [within]; exact ⟨hL, hd⟩⟩
  | weakening Γ Δ φ d' hsub ih =>
    obtain ⟨d, hd⟩ := ih
    exact ⟨.weakening Γ Δ φ d hsub, by simp only [within]; exact ⟨d'.mem, hd⟩⟩

/-- Derivability within a cell is derivability inside the sublanguage of the cell. -/
theorem derivableIn_iff_cellDerivable (c : Profile) (fc : FrameClass) (φ : Formula) :
    DerivableIn c fc φ ↔ CellDerivable (cellLanguage c) fc [] φ :=
  ⟨fun ⟨d, h⟩ => cellDerivable_of_within d h, exists_within_of_cellDerivable⟩

/-- The formulas with no operator are the formulas of the empty cell. -/
theorem booleanFormula_iff_profileF_le (φ : Formula) : BooleanFormula φ ↔ profileF φ ≤ {} := by
  induction φ with
  | atom a => simp [BooleanFormula]
  | bot => simp [BooleanFormula]
  | imp φ ψ ih1 ih2 => simp [BooleanFormula, ih1, ih2]
  | box φ _ => simp [BooleanFormula, profileF_box_le_iff]
  | untl φ ψ _ _ => simp [BooleanFormula, profileF_untl_le_iff]
  | snce φ ψ _ _ => simp [BooleanFormula, profileF_snce_le_iff]

/-- The formulas whose only operator is `□` are the formulas of the cell with `□`. -/
theorem modalFormula_iff_profileF_le (φ : Formula) :
    ModalFormula φ ↔ profileF φ ≤ { box := true } := by
  induction φ with
  | atom a => simp [ModalFormula]
  | bot => simp [ModalFormula]
  | imp φ ψ ih1 ih2 => simp [ModalFormula, ih1, ih2]
  | box φ ih => simp [ModalFormula, profileF_box_le_iff, ih]
  | untl φ ψ _ _ => simp [ModalFormula, profileF_untl_le_iff]
  | snce φ ψ _ _ => simp [ModalFormula, profileF_snce_le_iff]

/-- The Boolean cell is conserved by the full base system at every frame class: a formula with
no operator that the system derives is derivable through formulas with no operator. -/
theorem conservativeEdge_boolean (fc : FrameClass) : ConservativeEdge {} fc := by
  intro φ hφ h
  refine (derivableIn_iff_cellDerivable {} fc φ).mpr ?_
  exact (boolean_conservative fc ((booleanFormula_iff_profileF_le φ).mpr hφ) h).mono
    (fun ψ hψ => (booleanFormula_iff_profileF_le ψ).mp hψ)

/-- The Boolean cell is conserved by the cell with `□`: a formula with no operator derivable
within the cell with `□` is derivable within the Boolean cell. -/
theorem derivableIn_boolean_of_box (fc : FrameClass) (φ : Formula) (hφ : profileF φ ≤ {})
    (h : DerivableIn { box := true } fc φ) : DerivableIn {} fc φ :=
  conservativeEdge_boolean fc φ hφ (h.elim fun d _ => ⟨d⟩)

/-- The Boolean cell is conserved by the temporal cell: a formula with no operator derivable
within the temporal cell is derivable within the Boolean cell. -/
theorem derivableIn_boolean_of_temporal (fc : FrameClass) (φ : Formula) (hφ : profileF φ ≤ {})
    (h : DerivableIn { temporal := true } fc φ) : DerivableIn {} fc φ :=
  conservativeEdge_boolean fc φ hφ (h.elim fun d _ => ⟨d⟩)

/-- The cell with `□` is conserved by the full base system at every frame class: a formula
whose only operator is `□` that the system derives is derivable through such formulas. -/
theorem conservativeEdge_box (fc : FrameClass) : ConservativeEdge { box := true } fc := by
  intro φ hφ h
  refine (derivableIn_iff_cellDerivable { box := true } fc φ).mpr ?_
  exact (modal_conservative fc ((modalFormula_iff_profileF_le φ).mpr hφ) h).mono
    (fun ψ hψ => (modalFormula_iff_profileF_le ψ).mp hψ)

/-- The cell with `□` is conserved by the cell with `□` and `⊡` of the extended system: a
formula of the base language whose only operator is `□`, derivable in the extended system, is
derivable in the base system within the cell with `□`. The extended system is conservative over
the base system (`plusDerivable_ofFormula_iff`), and the base system is conservative over the
cell (`conservativeEdge_box`). -/
theorem derivableIn_box_of_derivableInP (fc : FrameClass) (φ : Formula)
    (hφ : profileF φ ≤ { box := true })
    (h : DerivableInP { box := true, stab := true } fc (ofFormula φ)) :
    DerivableIn { box := true } fc φ := by
  have hplus : PlusDerivable fc [] (ofFormula φ) := h.elim fun d _ => ⟨d⟩
  have hbase : Nonempty (DerivationTree fc [] φ) := by
    cases fc with
    | Base => exact (plusDerivable_ofFormula_iff completeness_base φ).mp hplus
    | Dense => exact (plusDerivable_ofFormula_iff completeness_dense φ).mp hplus
    | ZTime => exact (plusDerivable_ofFormula_iff completeness_ztime φ).mp hplus
    | RTime => exact (plusDerivable_ofFormula_iff completeness_rtime φ).mp hplus
  exact conservativeEdge_box fc φ hφ hbase

end BimodalLib

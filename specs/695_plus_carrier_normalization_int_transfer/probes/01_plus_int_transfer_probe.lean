/-
PROBE (task-scoped, not part of the library build).

Verifies the two claims task 695's research rests on:

1. `plusTruthAt_map` -- the seven-case `PlusFormula` twin of `Semantics.truthAt_map`, proved by
   a DIRECT induction. The six inherited cases follow `Truth.truthAt_of_truthCorr`'s body; the
   `atom` case reuses `alignedCorr`'s own `atom` field rather than restating it.
2. `plusValidZTime_iff_plusValidInt` -- carrier normalization for L-plus, the binder-for-binder
   mirror of `Semantics.validZTime_iff_validInt`.

Compiled clean (zero errors, zero warnings, zero sorries) against the built library with
`lake env lean`. The `#print axioms` lines at the bottom record the axiom sets.
-/
import FormalSystem.Semantics.IntTransfer
import FormalSystem.PlusLanguage.PlusValidity

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {D E : TemporalOrder}

theorem plusTruthAt_map {F : FrameOver D} [F.IsRegular]
    (e : ↑D ≃+o ↑E) (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    ∀ (σ : WorldHistory F.toTaskFrame) (σ' : WorldHistory (FrameOver.map F e).toTaskFrame),
      Aligned e σ σ' →
      ∀ t : ↑D, (PlusTruthAt M σ t φ ↔ PlusTruthAt (TaskModel.map M e) σ' (e t) φ) := by
  -- the atom case reuses the `TruthCorr` instance's own valuation-agreement field
  induction φ with
  | atom p => intro σ σ' h t; exact (alignedCorr e M).atom σ σ' h t p
  | bot => intro σ σ' _ t; exact Iff.rfl
  | imp a b iha ihb =>
      intro σ σ' h t
      exact Iff.imp (iha σ σ' h t) (ihb σ σ' h t)
  | box a ih =>
      intro σ σ' _ t
      constructor
      · intro h ρ'
        exact (ih (WorldHistory.comap e ρ') ρ' (aligned_comap e ρ') t).mp (h _)
      · intro h ρ
        exact (ih ρ (ρ.map e) (aligned_map e ρ) t).mpr (h _)
  | untl b a ihb iha =>
      intro σ σ' h t
      constructor
      · rintro ⟨s, hts, hs, hmin⟩
        refine ⟨e s, (map_lt_map_iff e).mpr hts, (iha σ σ' h s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := e.surjective r'
        exact (ihb σ σ' h r).mp (hmin r ((map_lt_map_iff e).mp h1) ((map_lt_map_iff e).mp h2))
      · rintro ⟨s', hts', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := e.surjective s'
        refine ⟨s, (map_lt_map_iff e).mp hts', (iha σ σ' h s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihb σ σ' h r).mpr
          (hmin' (e r) ((map_lt_map_iff e).mpr h1) ((map_lt_map_iff e).mpr h2))
  | snce b a ihb iha =>
      intro σ σ' h t
      constructor
      · rintro ⟨s, hst, hs, hmin⟩
        refine ⟨e s, (map_lt_map_iff e).mpr hst, (iha σ σ' h s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := e.surjective r'
        exact (ihb σ σ' h r).mp (hmin r ((map_lt_map_iff e).mp h1) ((map_lt_map_iff e).mp h2))
      · rintro ⟨s', hst', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := e.surjective s'
        refine ⟨s, (map_lt_map_iff e).mp hst', (iha σ σ' h s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihb σ σ' h r).mpr
          (hmin' (e r) ((map_lt_map_iff e).mpr h1) ((map_lt_map_iff e).mpr h2))
  | stab a ih =>
      intro σ σ' ha t
      -- the state-agreement bridge: both sides are the SAME equation in `F.WorldState`
      have hσ : σ'.state (e t) = σ.state t := by
        rw [ha (e t), e.symm_apply_apply]
      constructor
      · intro h ρ' hst
        have hρ : ρ'.state (e t) = (WorldHistory.comap e ρ').state t := rfl
        refine (ih (WorldHistory.comap e ρ') ρ' (aligned_comap e ρ') t).mp (h _ ?_)
        rw [← hσ, ← hρ]; exact hst
      · intro h ρ hst
        have hρ : (ρ.map e).state (e t) = ρ.state t := by
          show ρ.state (e.symm (e t)) = ρ.state t
          rw [e.symm_apply_apply]
        refine (ih ρ (ρ.map e) (aligned_map e ρ) t).mpr (h _ ?_)
        rw [hσ, hρ]; exact hst


def PlusValidInt (φ : PlusFormula) : Prop :=
  ∀ (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ), PlusTruthAt M τ t φ

theorem plusValidZTime_iff_plusValidInt (φ : PlusFormula) :
    PlusValidZTime φ ↔ PlusValidInt φ := by
  constructor
  · intro h F _ M τ t
    exact h F.toTaskFrame ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩ M τ t
  · intro h F hF M τ t
    sat_intro hF
    let e : ↑F.Duration ≃+o ↑intOrder := intIso
    refine (plusTruthAt_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e M φ τ
      (WorldHistory.map τ e) (aligned_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e τ)
      t).mpr ?_
    exact h (FrameOver.map F.toFibre e) (TaskModel.map (F := F.toFibre) M e)
      (WorldHistory.map τ e) (e t)

#print axioms FormalSystem.PlusLanguage.plusTruthAt_map
#print axioms FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt

end FormalSystem.PlusLanguage

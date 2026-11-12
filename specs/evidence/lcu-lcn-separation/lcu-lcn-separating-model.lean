/-
Probe: a separating model for `lcU` against `lcN` + mirror `lcN` over the DETERMINISTIC frames.

Part I  — PROMOTED to the library: the `⟐` sibling of the determinism collapse is
          `FormalSystem.PlusLanguage.dstab_iff_of_deterministic`; `lcN`'s antecedent/consequent
          collapse and its deterministic-class validity are
          `FormalSystem.Metalogic.LCExtension.lcAnte_iff_lcCons_of_deterministic` and
          `.lcN_plusValidOn_of_deterministic`; the deterministic-class axiom discharge and
          soundness arm are `.isLCAxiom_plusValidDetIn_base` and `.ext_sound_detIn`.
Part II — `lcU (atom a) (atom b)` is REFUTED on `translationFrame (TemporalOrder.of ℚ)`, which is
          a regular, deterministic frame over a densely ordered carrier. Kept here: this half was
          never promoted, since it is genuinely probe-shaped (a one-off witness model, not a
          reusable library lemma).

Together, via the promoted library halves: no `ExtDerivation .Base IsLCAxiom RuleSet.none`
derivation of `lcU` exists.

Not library code: a probe, kept under specs/evidence/.
-/
import FormalSystem.Metalogic.LCExtension
import FormalSystem.Metalogic.Deterministic.Validity
import FormalSystem.Semantics.Frames.Standard
import FormalSystem.Semantics.Correspondence.DurationFrames

namespace LCUSeparationProbe

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusTruth
open FormalSystem.Metalogic.Deterministic FormalSystem.Metalogic.LCExtension

variable {F : TaskFrame}

/-! ## Part II: the separating frame -/

/-- ℚ as a temporal order: densely ordered, so a bounded strictly increasing chain exists. -/
abbrev QOrd : TemporalOrder := TemporalOrder.of ℚ

/-- The truth set of every atom: the states strictly below `1`. -/
def Alt : Set (QOrd : Type) := {q | q < 1}

/-- The model on the translation frame over ℚ realising `Alt` as every atom's truth set. -/
abbrev Mq : TaskModel (translationFrame QOrd).toTaskFrame := translationModel QOrd Alt

/-- The reference (identity) history `t ↦ t`. -/
abbrev Hq : WorldHistory (translationFrame QOrd).toTaskFrame := translationHist QOrd

/-- The translation frame over ℚ is deterministic. -/
theorem detFq : (translationFrame QOrd).toTaskFrame.Deterministic :=
  translationFrame_deterministic QOrd

/-- Some atom, fixed. -/
def pa : Atom := Atom.mkBase "a"

/-- `⟐(atom pa)` at a time `s` of the reference history says exactly `s < 1`. -/
theorem dstab_pa_iff (s : (QOrd : Type)) :
    PlusTruthAt Mq Hq s (PlusFormula.dstab (PlusFormula.atom pa)) ↔ s < 1 := by
  rw [dstab_iff_of_deterministic detFq]
  exact Iff.rfl

/-- **The separating refutation**: `lcU` fails at `(Mq, Hq, 0)`. -/
theorem lcU_refuted :
    ¬ PlusTruthAt Mq Hq 0 (lcU (PlusFormula.atom pa) (PlusFormula.atom pa)) := by
  intro h
  -- The antecedent: at every `s ≥ 0`, an `α`-point carries a `β`-guarded until to a later one.
  have hante : PlusTruthAt Mq Hq 0
      (PlusFormula.stab (((PlusFormula.dstab (PlusFormula.atom pa)).imp
        (PlusFormula.dstab (PlusFormula.untl (PlusFormula.dstab (PlusFormula.atom pa))
          (PlusFormula.dstab (PlusFormula.atom pa))))).gle)) := by
    rw [stab_iff_of_deterministic detFq, gle_iff]
    intro s _ ha
    rw [dstab_pa_iff] at ha
    rw [dstab_iff_of_deterministic detFq, untl_iff]
    refine ⟨(s + 1) / 2, by linarith, ?_, ?_⟩
    · rw [dstab_pa_iff]; linarith
    · intro r _ hr2; rw [dstab_pa_iff]; linarith
  -- The trigger `⟐α` at time 0.
  have h0 : PlusTruthAt Mq Hq 0 (PlusFormula.dstab (PlusFormula.atom pa)) := by
    rw [dstab_pa_iff]; norm_num
  -- The consequent, instantiated at time 1, is false: `1 < 1` fails and nothing above 1 is an
  -- `α`-point.
  have hcons := h hante h0
  rw [dstab_iff_of_deterministic detFq, gle_iff] at hcons
  have h1 := hcons 1 (by norm_num)
  rw [or_iff] at h1
  rcases h1 with hL | hR
  · rw [dstab_pa_iff] at hL; exact absurd hL (by norm_num)
  · rw [untl_iff] at hR
    obtain ⟨s, hs, hal, -⟩ := hR
    rw [dstab_pa_iff] at hal
    linarith

/-- The frame of the refutation lies in the deterministic subclass of `.Base`. -/
theorem detSat_base_Fq :
    FormalSystem.Metalogic.Deterministic.DetSat .Base (translationFrame QOrd).toTaskFrame :=
  ⟨inferInstance, detFq⟩

/-! ## Part III: the non-derivability conclusion, via the promoted library halves -/

/-- **The headline**: `lcU` is NOT a theorem of TM⁺ + `LC_n` + mirror `LC_n` at `.Base`. -/
theorem lcU_not_extDerivable_base :
    ¬ ExtDerivation .Base IsLCAxiom RuleSet.none
        (lcU (PlusFormula.atom pa) (PlusFormula.atom pa)) := fun d =>
  lcU_refuted (ext_sound_detIn rfl rfl rfl (fun _ h => isLCAxiom_plusValidDetIn_base h) d
    _ detSat_base_Fq Mq Hq 0)

end LCUSeparationProbe

section AxiomPins
open LCUSeparationProbe
#print axioms LCUSeparationProbe.lcU_refuted
#print axioms LCUSeparationProbe.detSat_base_Fq
#print axioms LCUSeparationProbe.lcU_not_extDerivable_base
end AxiomPins

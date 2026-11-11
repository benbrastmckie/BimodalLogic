-- Elaborated this session with lean_run_code under `import FormalSystem`: SUCCESS, zero errors,
-- one style warning only (the `show` tactic below is written as `change` in the landing module).
-- Measured axiom profiles (all five): [propext, Classical.choice, Quot.sound].
--
-- This is the verified skeleton of FormalSystem/Metalogic/LCExtension.lean. It supersedes the
-- archived probe specs/879_lplus_ztime_completeness_tm_plus_lc_programme/probes/01_target-statements.lean
-- on two points: `lcU` is no longer redefined locally (it is library API in
-- FormalSystem/PlusLanguage/PlusLCSchema.lean), and the two naming-rule constructors are
-- re-encoded from that probe's `Q : List Atom` / `p : Atom -> Nat -> Atom` shape to the landed
-- `aaAnte qa m k a p b0` shape of FormalSystem/Metalogic/AuxiliaryAtoms.lean.
import FormalSystem

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.Metalogic.NamingRules FormalSystem.Metalogic.AuxiliaryAtoms
open FormalSystem.Metalogic.Conservativity

namespace Probe896

structure RuleSet where
  clock : Bool
  aaFwd : Bool
  aaBwd : Bool

def RuleSet.none : RuleSet := ⟨false, false, false⟩
def RuleSet.all : RuleSet := ⟨true, true, true⟩

def IsLCAxiom (ψ : PlusFormula) : Prop :=
  ∃ (n : ℕ) (α : ℕ → PlusFormula), 0 < n ∧ (ψ = lcN n α ∨ ψ = (lcN n α).reflectTime)

def IsLCUAxiom (ψ : PlusFormula) : Prop :=
  ∃ α β : PlusFormula, ψ = lcU α β ∨ ψ = (lcU α β).reflectTime

theorem isLCAxiom_plusValidZTime {ψ : PlusFormula} (h : IsLCAxiom ψ) : PlusValidZTime ψ := by
  obtain ⟨n, α, hn, h | h⟩ := h
  · exact h ▸ lcN_plusValidZTime n hn α
  · exact h ▸ lcN_reflectTime_plusValidZTime n hn α

theorem isLCUAxiom_plusValidZTime {ψ : PlusFormula} (h : IsLCUAxiom ψ) : PlusValidZTime ψ := by
  obtain ⟨α, β, h | h⟩ := h
  · exact h ▸ lcU_plusValidZTime α β
  · exact h ▸ lcU_reflectTime_plusValidZTime α β

inductive ExtDerivation (fc : FrameClass) (Ax : PlusFormula → Prop) (R : RuleSet) :
    PlusFormula → Prop
  | tm {φ} (d : PlusDerivable fc [] φ) : ExtDerivation fc Ax R φ
  | ax {φ} (h : Ax φ) : ExtDerivation fc Ax R φ
  | mp {φ ψ} (d₁ : ExtDerivation fc Ax R (φ.imp ψ)) (d₂ : ExtDerivation fc Ax R φ) :
      ExtDerivation fc Ax R ψ
  | nec {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R (PlusFormula.box φ)
  | tnec {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R φ.allFuture
  | refl {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R φ.reflectTime
  | clock {q φ} (hR : R.clock = true) (hq : Fresh q φ)
      (d : ExtDerivation fc Ax R ((clockAnte q).imp φ)) : ExtDerivation fc Ax R φ
  | aaFwd {φ} (hR : R.aaFwd = true) (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula)
      (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
      (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
      (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
      (ha : ∀ i, i < k → (a i).StateLocal)
      (hfresh : ∀ j, j < m → Fresh (qa j) φ)
      (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
      (hexh : ExtDerivation fc Ax R (bigAnd k fun i => (a i).neg).neg)
      (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' →
        ExtDerivation fc Ax R (((a i).and (a i')).neg))
      (d : ExtDerivation fc Ax R ((aaAnte qa m k a p b₀).imp φ)) :
      ExtDerivation fc Ax R φ
  | aaBwd {φ} (hR : R.aaBwd = true) (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula)
      (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
      (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
      (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
      (ha : ∀ i, i < k → (a i).StateLocal)
      (hfresh : ∀ j, j < m → Fresh (qa j) φ)
      (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
      (hexh : ExtDerivation fc Ax R (bigAnd k fun i => (a i).neg).neg)
      (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' →
        ExtDerivation fc Ax R (((a i).and (a i')).neg))
      (d : ExtDerivation fc Ax R (((aaAnte qa m k a p b₀).imp φ).reflectTime)) :
      ExtDerivation fc Ax R φ.reflectTime

theorem ext_sound_ztime {Ax : PlusFormula → Prop} {R : RuleSet}
    (hAx : ∀ ψ, Ax ψ → PlusValidZTime ψ) {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime Ax R φ) : PlusValidZTime φ := by
  induction d with
  | tm h => exact plus_soundness_ztime h
  | ax h => exact hAx _ h
  | mp _ _ ih1 ih2 => exact fun F hF M τ x => ih1 F hF M τ x (ih2 F hF M τ x)
  | nec _ ih => exact fun F hF M τ x σ => ih F hF M σ x
  | tnec _ ih =>
    intro F hF M τ x
    rw [PlusTruth.allFuture_iff]
    intro s _
    exact ih F hF M τ s
  | refl _ ih => exact plusValidIn_reflectTime ih
  | clock hR hq _ ih => exact clock_irr_sound _ _ _ hq ih
  | aaFwd hR qa m k a p b₀ hb₀ hinj hp ha hfresh hfreshA _ _ _ ihexh ihdisj ihd =>
    exact aa_sound_ztime qa m k a p b₀ _ hb₀ hinj hp ha ihexh ihdisj hfresh hfreshA ihd
  | aaBwd hR qa m k a p b₀ hb₀ hinj hp ha hfresh hfreshA _ _ _ ihexh ihdisj ihd =>
    exact aa_reflectTime_sound_ztime qa m k a p b₀ _ hb₀ hinj hp ha ihexh ihdisj hfresh hfreshA
      ihd

/-- The class-generic soundness arm, for a rule set with the two Auxiliary-Atoms rules off.
Verified separately (probe run d); recommended as an optional extra declaration. -/
theorem ext_sound_validIn {fc : FrameClass} {Ax : PlusFormula → Prop} {R : RuleSet}
    (hFwd : R.aaFwd = false) (hBwd : R.aaBwd = false)
    (hAx : ∀ ψ, Ax ψ → PlusValidIn fc ψ) {φ : PlusFormula}
    (d : ExtDerivation fc Ax R φ) : PlusValidIn fc φ := by
  induction d with
  | tm h => exact plus_soundness_validIn h
  | ax h => exact hAx _ h
  | mp _ _ ih1 ih2 => exact fun F hFr M τ x => ih1 F hFr M τ x (ih2 F hFr M τ x)
  | nec _ ih => exact fun F hFr M τ x σ => ih F hFr M σ x
  | tnec _ ih =>
    intro F hFr M τ x
    rw [PlusTruth.allFuture_iff]
    intro s _
    exact ih F hFr M τ s
  | refl _ ih => exact plusValidIn_reflectTime ih
  | clock hR hq _ ih => exact clock_irr_sound _ _ _ hq ih
  | aaFwd hR => exact absurd hR (by rw [hFwd]; simp)
  | aaBwd hR => exact absurd hR (by rw [hBwd]; simp)

def ExtComplete (Ax : PlusFormula → Prop) (R : RuleSet) : Prop :=
  ∀ φ : PlusFormula, PlusValidZTime φ → ExtDerivation FrameClass.ZTime Ax R φ

def LCComplete : Prop := ExtComplete IsLCAxiom RuleSet.none
def LCRulesComplete : Prop := ExtComplete IsLCAxiom RuleSet.all
def LCURulesComplete : Prop := ExtComplete IsLCUAxiom RuleSet.all

theorem ext_sound_lc_ztime {R : RuleSet} {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime IsLCAxiom R φ) : PlusValidZTime φ :=
  ext_sound_ztime (fun _ h => isLCAxiom_plusValidZTime h) d

theorem ext_sound_lcU_ztime {R : RuleSet} {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime IsLCUAxiom R φ) : PlusValidZTime φ :=
  ext_sound_ztime (fun _ h => isLCUAxiom_plusValidZTime h) d

/-- Acceptance: the arbitrary-conclusion mirror shape is derivable from the `φ.reflectTime`
form, by `PlusFormula.reflect_time_involution` alone. (`show` here; `change` in the module.) -/
example {Ax : PlusFormula → Prop} {R : RuleSet} {ψ : PlusFormula} (hR : R.aaBwd = true)
    (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hfresh : ∀ j, j < m → Fresh (qa j) ψ.reflectTime)
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (hexh : ExtDerivation FrameClass.ZTime Ax R (bigAnd k fun i => (a i).neg).neg)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' →
      ExtDerivation FrameClass.ZTime Ax R (((a i).and (a i')).neg))
    (d : ExtDerivation FrameClass.ZTime Ax R ((aaAnte qa m k a p b₀).reflectTime.imp ψ)) :
    ExtDerivation FrameClass.ZTime Ax R ψ := by
  have h := ExtDerivation.aaBwd (φ := ψ.reflectTime) hR qa m k a p b₀ hb₀ hinj hp ha hfresh
    hfreshA hexh hdisj (by
      show ExtDerivation FrameClass.ZTime Ax R
        ((aaAnte qa m k a p b₀).reflectTime.imp ψ.reflectTime.reflectTime)
      rwa [PlusFormula.reflect_time_involution])
  rwa [PlusFormula.reflect_time_involution] at h

/-- Non-vacuity: the axiom predicates are inhabited. -/
example : ∃ ψ, IsLCAxiom ψ := ⟨lcN 1 (fun _ => PlusFormula.bot), 1, _, by omega, Or.inl rfl⟩

example : ∃ ψ, IsLCUAxiom ψ :=
  ⟨lcU PlusFormula.bot PlusFormula.bot, PlusFormula.bot, PlusFormula.bot, Or.inl rfl⟩

end Probe896

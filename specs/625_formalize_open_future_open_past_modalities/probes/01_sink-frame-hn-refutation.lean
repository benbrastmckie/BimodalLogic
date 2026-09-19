import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.PlusLanguage.PlusNonValidities
import FormalSystem.Semantics.PlusLanguage.PlusPasting

/-! Probe A: the three-state frame through `FrameOver.ofStep`, the HN-stab refutation against the
live `PlusTruthAt`, the same refutation on the existing `NF`, and the open-future validity in
semantic (AgreeUpTo) form. -/

namespace Probe625

open FormalSystem.Semantics FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula PlusTruth

inductive S3 : Type where
  | a | b | c
  deriving DecidableEq

instance : Nonempty S3 := ⟨S3.a⟩

instance : Fintype S3 where
  elems := {S3.a, S3.b, S3.c}
  complete := by intro x; cases x <;> simp

/-- One step: stay, or fall into the sink `c`. -/
def R1 : S3 → S3 → Prop := fun x y => x = y ∨ y = S3.c

/-- A full task frame over ℤ: every field of `FrameOver` is discharged by `ofStep`. -/
abbrev F3 : FrameOver intOrder :=
  FrameOver.ofStep R1 (fun w => ⟨w, Or.inl rfl⟩) (fun w => ⟨w, Or.inl rfl⟩)

def σf : ℤ → S3 := fun n => if n < 0 then S3.a else S3.c
def ρf : ℤ → S3 := fun n => if n < 0 then S3.b else S3.c

theorem σf_path : IsStepPath F3 σf := by
  intro n
  refine (FrameOver.ofStep_step R1 _ _ _ _).mpr ?_
  unfold σf R1
  by_cases h : n + 1 < 0
  · rw [if_pos (by omega : n < 0), if_pos h]; exact Or.inl rfl
  · rw [if_neg h]; exact Or.inr rfl

theorem ρf_path : IsStepPath F3 ρf := by
  intro n
  refine (FrameOver.ofStep_step R1 _ _ _ _).mpr ?_
  unfold ρf R1
  by_cases h : n + 1 < 0
  · rw [if_pos (by omega : n < 0), if_pos h]; exact Or.inl rfl
  · rw [if_neg h]; exact Or.inr rfl

def σ3 : WorldHistory F3 := FrameOver.worldHistoryOfStepPath F3 σf σf_path
def ρ3 : WorldHistory F3 := FrameOver.worldHistoryOfStepPath F3 ρf ρf_path

def M3 : TaskModel F3 where
  valuation := fun (x : S3) _ => x = S3.a

/-- HN, `Pα → □P◇α`, transposed to `⊡`/`⟐`. -/
def hnStab (p : Atom) : PlusFormula :=
  imp (somePast (atom p)) (stab (somePast (dstab (atom p))))

theorem hn_stab_refuted (p : Atom) : ¬ PlusTruthAt M3 σ3 0 (hnStab p) := by
  intro h
  have h1 : PlusTruthAt M3 σ3 0 (somePast (atom p)) :=
    (somePast_iff _ _ _ _).2 ⟨-1, by norm_num, by
      rw [atom_iff]; show σf (-1) = S3.a; simp [σf]⟩
  have h2 := h h1 ρ3 (by show σf 0 = ρf 0; simp [σf, ρf])
  obtain ⟨s, hs, hd⟩ := (somePast_iff _ _ _ _).1 h2
  obtain ⟨η, he, hp⟩ := (dstab_iff _ _ _ _).1 hd
  rw [atom_iff] at hp
  have hp' : η.state s = S3.a := hp
  have he' : ρf s = η.state s := he
  rw [hp'] at he'
  simp [ρf, hs] at he'

theorem not_plusValidOn_hnStab (p : Atom) : ¬ F3.toTaskFrame.PlusValidOn (hnStab p) :=
  fun h => hn_stab_refuted p (h M3 σ3 0)

/-- The same refutation on the existing permissive frame `NF`. -/
theorem hn_stab_refuted_NF (p : Atom) :
    ¬ PlusTruthAt natModel (natHist fun _ => 0) 0 (hnStab p) := by
  intro h
  have h1 : PlusTruthAt natModel (natHist fun _ => 0) 0 (somePast (atom p)) :=
    (somePast_iff _ _ _ _).2 ⟨-1, by norm_num, rfl⟩
  have h2 := h h1 (natHist fun s => if s < 0 then 1 else 0)
    (by change (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0); simp)
  obtain ⟨s, hs, hd⟩ := (somePast_iff _ _ _ _).1 h2
  obtain ⟨η, he, hp⟩ := (dstab_iff _ _ _ _).1 hd
  have hp' : η.state s = (0 : ℕ) := hp
  have he' : (if (s : ℤ) < 0 then (1 : ℕ) else 0) = η.state s := he
  rw [hp', if_pos hs] at he'
  exact one_ne_zero he'

variable {F : TaskFrame}

/-- Open-future HN in semantic form: mixed `▷ … ⟐` version. -/
theorem hn_open_mixed (M : TaskModel F) (α : PlusFormula) (σ : WorldHistory F) (t : F.Duration)
    (h : PlusTruthAt M σ t (somePast α)) :
    ∀ ρ, AgreeUpTo σ ρ t → PlusTruthAt M ρ t (somePast (dstab α)) := by
  intro ρ hag
  obtain ⟨s, hs, hα⟩ := (somePast_iff _ _ _ _).1 h
  exact (somePast_iff _ _ _ _).2 ⟨s, hs, (dstab_iff _ _ _ _).2 ⟨σ, (hag s hs.le).symm, hα⟩⟩

/-- Open-future HN in pure form: `Pα → ▷P▷̂α`, with `▷̂` the open-future dual. -/
theorem hn_open_pure (M : TaskModel F) (α : PlusFormula) (σ : WorldHistory F) (t : F.Duration)
    (h : PlusTruthAt M σ t (somePast α)) :
    ∀ ρ, AgreeUpTo σ ρ t → ∃ s, s < t ∧ ∃ η, AgreeUpTo ρ η s ∧ PlusTruthAt M η s α := by
  intro ρ hag
  obtain ⟨s, hs, hα⟩ := (somePast_iff _ _ _ _).1 h
  exact ⟨s, hs, σ, fun r hr => (hag r (le_trans hr hs.le)).symm, hα⟩

/-- `▷φ → ⊡φ` fails: on `NF`, `▷Pp` holds at the constant-`0` history but `⊡Pp` does not. -/
theorem open_not_stab (p : Atom) :
    (∀ ρ, AgreeUpTo (natHist fun _ => 0) ρ 0 → PlusTruthAt natModel ρ 0 (somePast (atom p))) ∧
    ¬ PlusTruthAt natModel (natHist fun _ => 0) 0 (stab (somePast (atom p))) := by
  refine ⟨fun ρ hag => (somePast_iff _ _ _ _).2 ⟨-1, by norm_num, ?_⟩, fun h => ?_⟩
  · rw [atom_iff]
    have := hag (-1) (by norm_num)
    change (0 : ℕ) = ρ.state (-1) at this
    change ρ.state (-1) = (0 : ℕ)
    exact this.symm
  · have h2 := h (natHist fun s => if s < 0 then 1 else 0)
      (by change (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0); simp)
    obtain ⟨s, hs, hat⟩ := (somePast_iff _ _ _ _).1 h2
    have v' : (if (s : ℤ) < 0 then (1 : ℕ) else 0) = 0 := hat
    rw [if_pos hs] at v'
    exact one_ne_zero v'

end Probe625

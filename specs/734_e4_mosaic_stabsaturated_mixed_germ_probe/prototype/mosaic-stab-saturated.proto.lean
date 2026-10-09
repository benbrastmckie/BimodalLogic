import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

namespace Probe734Mosaic

variable {F : TaskFrame} {t : F.Duration}

@[ext]
structure Mosaic (F : TaskFrame) (t : F.Duration) where
  hist : WorldHistory F

/-- The landed predicate, verbatim from `mosaic-germ-amalgamation.lean`. -/
def StabSaturated (M : TaskModel F) (S : Finset (Mosaic F t)) : Prop :=
  ∀ m ∈ S, ∀ χ : PlusFormula, PlusTruthAt M m.hist t (.stab χ) →
    ∀ m' ∈ S, m'.hist.state t = m.hist.state t → PlusTruthAt M m'.hist t χ

/-- CLAIM 1: the landed predicate holds for EVERY finite mosaic set, mixed or not. -/
theorem stabSaturated_univ (M : TaskModel F) (S : Finset (Mosaic F t)) : StabSaturated M S :=
  fun _ _ _ hχ m' _ heq => hχ m'.hist heq.symm

/-- The witness-direction (diamond) saturation at one formula `χ`: every mosaic refuting `⊡χ`
has a same-germ witness in `S` refuting `χ`. -/
def StabWitnessedAt (M : TaskModel F) (χ : PlusFormula) (S : Finset (Mosaic F t)) : Prop :=
  ∀ m ∈ S, ¬ PlusTruthAt M m.hist t (.stab χ) →
    ∃ m' ∈ S, m'.hist.state t = m.hist.state t ∧ ¬ PlusTruthAt M m'.hist t χ

/-! ## The E2 fixture, transcribed -/

def Rg : ℤ → Bool → Bool → Prop := fun _ u v => u = false ∨ v = true
theorem Rg_fwd : ∀ (t : ℤ) (w : Bool), ∃ u, Rg t w u := fun _ _ => ⟨true, Or.inr rfl⟩
theorem Rg_bwd : ∀ (t : ℤ) (w : Bool), ∃ v, Rg (t - 1) v w := fun _ _ => ⟨false, Or.inl rfl⟩
def Fg : FrameOver intOrder := FrameOver.ofSlicedStep Rg Rg_fwd Rg_bwd
instance : Fg.IsRegular := FrameOver.ofSlicedStep_isRegular Rg Rg_fwd Rg_bwd
def pa : Atom := ⟨"p", none⟩
def Mg : TaskModel Fg.toTaskFrame where
  valuation q _ := q.2 = true
abbrev Fp : PlusFormula := someFuture (.atom pa)

noncomputable def stayA (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), false)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, Or.inl rfl⟩
    show z + 1 + (c - t) = z + (c - t) + 1
    ring)
theorem stayA_state (c t z : ℤ) : (stayA c t).state z = (z + (c - t), false) := rfl
theorem stayA_state_t (c t : ℤ) : (stayA c t).state t = (c, false) := by
  rw [stayA_state]; congr 1; ring

noncomputable def stayB (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), true)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, Or.inr rfl⟩
    show z + 1 + (c - t) = z + (c - t) + 1
    ring)
theorem stayB_state (c t z : ℤ) : (stayB c t).state z = (z + (c - t), true) := rfl
theorem stayB_state_t (c t : ℤ) : (stayB c t).state t = (c, true) := by
  rw [stayB_state]; congr 1; ring

noncomputable def jumpB (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), decide (t < z))) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, ?_⟩
    · show z + 1 + (c - t) = z + (c - t) + 1
      ring
    · show decide (t < z) = false ∨ decide (t < z + 1) = true
      by_cases h : t < z
      · right; rw [decide_eq_true_eq]; omega
      · left; rw [decide_eq_false_iff_not]; exact h)
theorem jumpB_state (c t z : ℤ) : (jumpB c t).state z = (z + (c - t), decide (t < z)) := rfl
theorem jumpB_state_t (c t : ℤ) : (jumpB c t).state t = (c, false) := by
  rw [jumpB_state, decide_eq_false (lt_irrefl t)]; congr 1; ring
theorem jumpB_state_succ (c t : ℤ) : ((jumpB c t).state (t + 1)).2 = true := by
  rw [jumpB_state]; exact decide_eq_true (lt_add_one t)

theorem not_Fp_stayA (c t : ℤ) : ¬ PlusTruthAt Mg (stayA c t) t Fp := by
  rw [PlusTruth.someFuture_iff]
  rintro ⟨s, -, hs⟩
  have hs' : ((stayA c t).state s).2 = true := hs
  rw [stayA_state] at hs'
  exact Bool.noConfusion hs'
theorem Fp_jumpB (c t : ℤ) : PlusTruthAt Mg (jumpB c t) t Fp := by
  rw [PlusTruth.someFuture_iff]
  exact ⟨t + 1, lt_add_one t, jumpB_state_succ c t⟩

/-- `⊡Fp` fails at `jumpB` (germ state `a`): `stayA` is a same-germ refuter. -/
theorem not_stabFp_jumpB (c t : ℤ) : ¬ PlusTruthAt Mg (jumpB c t) t (.stab Fp) := by
  intro h
  exact not_Fp_stayA c t (h (stayA c t) (by rw [jumpB_state_t, stayA_state_t]))

/-- From `b` only `b`: any history at `b` at time `t` is at `b` at `t + 1`. -/
theorem succ_of_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = true) :
    (τ.state (t + 1)).2 = true := by
  have hstep := τ.isStepPath t
  have h := (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mp hstep
  rcases h.2 with h1 | h1
  · have hb' : (τ.path t).2 = true := hb
    exact absurd (hb'.symm.trans h1) Bool.noConfusion
  · exact h1

/-- `⊡Fp` holds at `stayB` (germ state `b`). -/
theorem stabFp_stayB (c t : ℤ) : PlusTruthAt Mg (stayB c t) t (.stab Fp) := by
  intro σ hσ
  rw [PlusTruth.someFuture_iff]
  refine ⟨t + 1, lt_add_one t, ?_⟩
  have hb : (σ.state t).2 = true := by rw [← hσ, stayB_state_t]
  exact succ_of_b σ t hb

/-! ## The mixed-germ sets -/

/-- Mosaics wrap possible worlds, which carry no decidable equality; the finite sets below are
classical. -/
noncomputable instance instDecEqMosaic (t : ℤ) : DecidableEq (Mosaic Fg.toTaskFrame t) :=
  Classical.decEq _

/-- The three-mosaic MIXED set: two `a`-germ mosaics and one `b`-germ mosaic. -/
noncomputable def Smix (c t : ℤ) : Finset (Mosaic Fg.toTaskFrame t) :=
  {⟨stayA c t⟩, ⟨jumpB c t⟩, ⟨stayB c t⟩}

/-- The two-mosaic MIXED set with the `a`-germ refuter of `Fp` removed. -/
noncomputable def Sdrop (c t : ℤ) : Finset (Mosaic Fg.toTaskFrame t) :=
  {⟨jumpB c t⟩, ⟨stayB c t⟩}

/-- CLAIM 2a: `Smix` is genuinely mixed -- the landed corner hypothesis FAILS on it. -/
theorem Smix_mixed (c t : ℤ) :
    ¬ ∀ m ∈ Smix c t, ∀ m' ∈ Smix c t, m.hist.state t = m'.hist.state t := by
  intro h
  have := h ⟨stayA c t⟩ (by simp [Smix]) ⟨stayB c t⟩ (by simp [Smix])
  rw [stayA_state_t, stayB_state_t] at this
  injection this with _ h2
  exact Bool.noConfusion h2

/-- CLAIM 2b: ... and yet the landed predicate holds on it -- by the universal theorem. -/
theorem Smix_stabSaturated (c t : ℤ) : StabSaturated Mg (Smix c t) :=
  stabSaturated_univ Mg _

/-- CLAIM 3a: the witness-direction saturation at `Fp` HOLDS on `Smix`. -/
theorem Smix_witnessed (c t : ℤ) : StabWitnessedAt Mg Fp (Smix c t) := by
  intro m hm hnot
  have hA : (⟨stayA c t⟩ : Mosaic Fg.toTaskFrame t) ∈ Smix c t := Finset.mem_insert_self _ _
  rcases Finset.mem_insert.mp hm with rfl | hm
  · exact ⟨⟨stayA c t⟩, hA, rfl, not_Fp_stayA c t⟩
  rcases Finset.mem_insert.mp hm with rfl | hm
  · exact ⟨⟨stayA c t⟩, hA, by rw [stayA_state_t, jumpB_state_t], not_Fp_stayA c t⟩
  rw [Finset.mem_singleton] at hm
  subst hm
  exact absurd (stabFp_stayB c t) hnot

/-- CLAIM 3b: the witness-direction saturation at `Fp` FAILS on `Sdrop`, a mixed set every one
of whose mosaics is a genuine possible world (so every coherence condition that is definitional
holds): `jumpB` refutes `⊡Fp` at germ `a`, and its only same-germ companion in the set is itself,
where `Fp` holds. -/
theorem Sdrop_not_witnessed (c t : ℤ) : ¬ StabWitnessedAt Mg Fp (Sdrop c t) := by
  intro h
  obtain ⟨m', hm', hst, hnFp⟩ :=
    h ⟨jumpB c t⟩ (Finset.mem_insert_self _ _) (not_stabFp_jumpB c t)
  rcases Finset.mem_insert.mp hm' with rfl | hm'
  · exact hnFp (Fp_jumpB c t)
  · rw [Finset.mem_singleton] at hm'
    subst hm'
    rw [stayB_state_t, jumpB_state_t] at hst
    injection hst with _ h2
    exact Bool.noConfusion h2

theorem Sdrop_mixed (c t : ℤ) :
    ¬ ∀ m ∈ Sdrop c t, ∀ m' ∈ Sdrop c t, m.hist.state t = m'.hist.state t := by
  intro h
  have := h ⟨jumpB c t⟩ (by simp [Sdrop]) ⟨stayB c t⟩ (by simp [Sdrop])
  rw [jumpB_state_t, stayB_state_t] at this
  injection this with _ h2
  exact Bool.noConfusion h2

end Probe734Mosaic

#print axioms Probe734Mosaic.stabSaturated_univ
#print axioms Probe734Mosaic.Smix_mixed
#print axioms Probe734Mosaic.Smix_witnessed
#print axioms Probe734Mosaic.Sdrop_not_witnessed

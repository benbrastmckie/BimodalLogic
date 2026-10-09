/-
Probe 734 (E4): **`⊡`-saturation on a MIXED-germ mosaic set of the E2 Bool fixture** — the
question Probe 718 (`mosaic-germ-amalgamation.lean`, namespace `Probe718Mosaic`) left "open for
the next round to attack by name": is `Probe718Mosaic.StabSaturated` decidable on a finite mosaic
set whose germ states are MIXED, beyond the same-state corner `stabSaturated_of_sameState` proves?
`Mosaic` and `StabSaturated` are re-declared verbatim below; probes never import each other.

**Which fixture and why.** The "two-state Bool fixture" is the E2 fixture `Rg` of
`stab-depth-two-probe.lean` (namespace `Probe711DepthTwo`): states `a`/`b` as `false`/`true`,
steps `a→a`, `a→b`, `b→b`, and `p` exactly at `b` — transcribed here as `Rg`/`Fg`/`Mg`. On it
`⊡(Fp)` is state-DEPENDENT (`Probe711DepthTwo.stab_will_iff`: True at `b`, False at `a`), so a
mosaic set at one germ time can carry both verdicts. It is NOT the complete-graph fixture `Rf`
of `finite-graph-stab-summary.lean`, on which `⊡(Fp)` is uniformly False
(`Probe718FiniteGraph.decide_will`) and no germ state distinguishes anything.

**Outcome: VACUOUS — decidable because identically true.** `stabSaturated_univ` proves the
landed predicate for EVERY finite mosaic set, mixed germ states or not, by the one-line term
`fun _ _ _ hχ m' _ heq => hχ m'.hist heq.symm`: the predicate's own body already supplies
`m'.hist.state t = m.hist.state t`, and `⊡χ` at `m` is definitionally
`∀ σ, m.state t = σ.state t → χ at σ` (`PlusTruth.stab_iff` is `Iff.rfl`), so the hypothesis
discharges the conclusion directly. `stabSaturated_of_sameState`'s same-state hypothesis `hS`
was never load-bearing. `Smix_mixed` and `Smix_stabSaturated` exhibit a genuinely mixed set on
which the corner hypothesis FAILS and the predicate still holds. Say it plainly: a predicate
that is constantly true is decidable, and THIS DECIDES NOTHING ABOUT R2 — `stabSaturated_univ`
is not positive evidence for the mosaic route; it is evidence that the landed statement was the
wrong object.

**The falsifier is unsatisfiable as stated.** The review's R2 falsifier — a finite mosaic set
with mixed germ states on which `StabSaturated` is FALSE while every finite coherence condition
holds — cannot be instantiated: no finite mosaic set, mixed or not, makes `StabSaturated` false.
Nothing is weakened, because there is nothing to record as a refutation; this is a finding about
the hypothesis STATEMENT, not a null probe result.

**The real SH1 content is the witness direction.** `StabWitnessedAt M χ S` transcribes
Caleiro–Viganò–Volpe 2013's saturation clause SH1 (Def. 3.6, the diamond/witness clause) to
`⊡`: every mosaic in `S` refuting `⊡χ` has a same-germ mosaic IN THE SET refuting `χ`. This is
non-trivial on mixed sets. On `Smix = {stayA, jumpB, stayB}` it HOLDS (`Smix_witnessed`); on
`Sdrop = {jumpB, stayB}` it FAILS (`Sdrop_not_witnessed`): `jumpB` refutes `⊡Fp` at germ
state `a` (`not_stabFp_jumpB`), its same-germ refuter `stayA` exists in the MODEL but is absent
from the SET, and its only same-germ companion in `Sdrop` is itself, where `Fp` holds
(`Fp_jumpB`). Both sets are mixed (`Smix_mixed`, `Sdrop_mixed`), and every mosaic in them is a
genuine possible world, so every coherence condition that is definitional holds. New fixture
lemmas: `succ_of_b` (from `b` only `b`) and `stabFp_stayB` (`⊡Fp` holds at germ state `b`).

**What the witness direction does and does not decide.** Checking `StabWitnessedAt` over a
finite set is a finite check only once the value of `⊡χ` at each mosaic is known — and on this
fixture that value is `Probe711DepthTwo.stab_will_iff`, R1's forward-reachability summary.
A semantic-label mosaic set is a CONSUMER of R1's device, not an independent decision procedure.

**What this does to R2's standing** (evidence only; ranking is the review's). R2's load-bearing
hypothesis as filed — "`StabSaturated` is decidable on finite mosaic sets with mixed germ states"
— was vacuous and must be RESTATED as a syntactic saturated-set existence theorem for L⁺: points
on a finite closure, the Hintikka condition H1, the witness condition SH1, plus a bespoke
`⊡`-fibre / task-relation interaction condition that Caleiro's list does not contain. Caleiro
2013 §4.3 states that the mosaic decidability argument does not extend once the horizontal and
vertical components interact, and `⊡` interacts with the task relation by construction. R2 is
neither promoted nor closed by this probe; `amalgamate`'s "free" precondition (Probe 718) is a
SEMANTIC fact about `paste` and does not carry to the syntactic calculus.

**Evidence gap, recorded.** Handbook of Modal Logic ch. 11 (Hodkinson–Reynolds) §5.10 "Mosaics"
and §5.11 "Monodic fragments" remain ABSENT from the corpus: the publisher preview was
re-measured 2026-10-09 at 3 pages, byte-identical to the corpus copy, and DOI
`10.1016/S1570-2464(07)80014-0` is paywalled. Recorded as a residual gap in
`specs/literature-index.json` (`hodkinson_2006`, `hazard`) with reactivation condition
"institutional access or purchase, or an open release". In-corpus stand-ins: Caleiro 2013
(for §5.10), Hodkinson–Wolter–Zakharyaschev 2000 (for §5.11). R2 cannot be promoted on textual
grounds until the sections are present.

**What this does NOT do.** No complexity claim. No fourth certificate class — any class
presenting finite fibres is already refuted by
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`,
untouched here. No promotion of R2 above R1. No syntactic mosaic calculus and no saturated-set
existence theorem. No edit to `mosaic-germ-amalgamation.lean`: the vacuity is recorded in THIS
file and the landed probe stays as the historical record (no-weakening rule for wired probes).

**Axiom record** (measured, `lake env lean` on this file, 2026-10-09):
  'Probe734Mosaic.stabSaturated_univ' depends on axioms: [propext, Classical.choice, Quot.sound]
  'Probe734Mosaic.Smix_mixed' depends on axioms: [propext, Classical.choice, Quot.sound]
  'Probe734Mosaic.Smix_witnessed' depends on axioms: [propext, Classical.choice, Quot.sound]
  'Probe734Mosaic.Sdrop_not_witnessed' depends on axioms: [propext, Classical.choice, Quot.sound]
`Classical.choice` enters even the one-line `stabSaturated_univ` through `PlusTruthAt`'s
classical semantics, and the finite sets are classical through the `noncomputable instance`
`instDecEqMosaic` (`Classical.decEq`), since mosaics wrap possible worlds with no decidable
equality. No `sorryAx` anywhere.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean
-/
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

/-- **Vacuity.** The landed predicate holds for EVERY finite mosaic set, mixed or not. -/
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

/-- `Smix` is genuinely mixed -- the landed corner hypothesis FAILS on it. -/
theorem Smix_mixed (c t : ℤ) :
    ¬ ∀ m ∈ Smix c t, ∀ m' ∈ Smix c t, m.hist.state t = m'.hist.state t := by
  intro h
  have := h ⟨stayA c t⟩ (by simp [Smix]) ⟨stayB c t⟩ (by simp [Smix])
  rw [stayA_state_t, stayB_state_t] at this
  injection this with _ h2
  exact Bool.noConfusion h2

/-- ... and yet the landed predicate holds on it -- by the universal theorem. -/
theorem Smix_stabSaturated (c t : ℤ) : StabSaturated Mg (Smix c t) :=
  stabSaturated_univ Mg _

/-- The witness-direction saturation at `Fp` HOLDS on `Smix`. -/
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

/-- The witness-direction saturation at `Fp` FAILS on `Sdrop`, a mixed set every one
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

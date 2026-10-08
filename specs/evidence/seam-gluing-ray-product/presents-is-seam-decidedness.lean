/-
Probe 737 (the `Presents` discharge question): **a concrete regular `ℤ`-frame seam at which the
single-family hypothesis bundle `FormalSystem.Metalogic.Decidability.RaySummary.Presents` has NO
inhabitant for any parameters** — the fixture-level consequence of the library's
characterization `exists_presents_iff` (`RaySummary/SeamMulti.lean`): the bundle is inhabited iff
the seam is `⊡`-decided, so a seam that is not decided refutes every candidate summary at once.

**What is established (machine-checked).**

1. *The seam `(stayA c t, t)` is undecided on `Fp`.* The fixture is E2's (two states `a`, `b`;
   edges `a→a`, `a→b`, `b→b`; `p` at `b`), transcribed here as `Rg`/`Fg`/`Mg`, never imported
   from the E2 probe. Through the seam state `(c, a)` at `t` run the history `stayA c t`, which
   stays at `a` and refutes `Fp` (`not_Fp_stayA`), and the history `jumpB c t`, which steps to
   `b` at `t + 1` and satisfies it (`Fp_jumpB`); both pass through `(c, a)` at `t`
   (`stayA_state_t`, `jumpB_state_t`). So neither `⊡(Fp)` nor `⊡¬(Fp)` holds there
   (`seam_undecided`, against the library's `SeamDecided`).
2. *No `Presents` inhabitant exists at that seam, for any `sig`, `k`, `T`, `S*
   (`no_presents_on_fixture`), by the library's `seamDecided_of_presents`. This is the
   obstruction to field (1) `colours` in the landed single-family shape: it is a seam
   condition, false in general, and not the MSO-over-`⟨ℤ,<⟩` reduction.
3. *The fixture is regular*, via `FrameOver.ofSlicedStep_isRegular`, so every library statement
   cited below applies to it under `[F.IsRegular]`.

**What is NOT established.** Nothing about `⊡(Pp)`: the exhibited undecided seam is forward-only,
and there is still no backward Bool-fixture bridge (`pastStab_iff_allBwdPathsMeet` on the
asymmetric fixture remains the only backward fixture result). No claim that `Hit` is computable.
No decidability of anything and no complexity bound. The characterization itself is the
library's `exists_presents_iff`, cited (`#check`) and not re-proved; this file declares only the
fixture and its two theorems.

**Axiom record.** `seam_undecided` and `no_presents_on_fixture`: `[propext, Classical.choice,
Quot.sound]` (see the `#print axioms` foot); no `sorryAx`. The `Classical.choice` is inherited
from `FrameOver.worldHistoryOfStepPath` and the library's seam machinery.

**Compile line.** `lake env lean specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`
(wired into `scripts/check-evidence-probes.sh`).
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe737Presents

/-! ## The E2 fixture, transcribed -/

/-- `a := false` steps to `a` and to `b`; `b := true` steps to `b` only. -/
def Rg : ℤ → Bool → Bool → Prop := fun _ u v => u = false ∨ v = true

theorem Rg_fwd : ∀ (t : ℤ) (w : Bool), ∃ u, Rg t w u := fun _ _ => ⟨true, Or.inr rfl⟩
theorem Rg_bwd : ∀ (t : ℤ) (w : Bool), ∃ v, Rg (t - 1) v w := fun _ _ => ⟨false, Or.inl rfl⟩

def Fg : FrameOver intOrder := FrameOver.ofSlicedStep Rg Rg_fwd Rg_bwd

instance : Fg.IsRegular := FrameOver.ofSlicedStep_isRegular Rg Rg_fwd Rg_bwd

def pa : Atom := ⟨"p", none⟩

def Mg : TaskModel Fg.toTaskFrame where
  valuation q _ := q.2 = true

abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- The history that stays at `a`, passing through `(c, a)` at `t`. -/
noncomputable def stayA (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), false)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, Or.inl rfl⟩
    show z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem stayA_state (c t z : ℤ) : (stayA c t).state z = (z + (c - t), false) := rfl

theorem stayA_state_t (c t : ℤ) : (stayA c t).state t = (c, false) := by
  rw [stayA_state]
  congr 1
  ring

/-- The history that is at `a` up to `t` and at `b` from `t + 1`, passing through `(c, a)` at
`t`. -/
noncomputable def jumpB (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), decide (t < z))) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, ?_⟩
    · show z + 1 + (c - t) = z + (c - t) + 1
      ring
    · show decide (t < z) = false ∨ decide (t < z + 1) = true
      by_cases h : t < z
      · right
        rw [decide_eq_true_eq]
        omega
      · left
        rw [decide_eq_false_iff_not]
        exact h)

theorem jumpB_state (c t z : ℤ) : (jumpB c t).state z = (z + (c - t), decide (t < z)) := rfl

theorem jumpB_state_t (c t : ℤ) : (jumpB c t).state t = (c, false) := by
  rw [jumpB_state, decide_eq_false (lt_irrefl t)]
  congr 1
  ring

theorem jumpB_state_succ (c t : ℤ) : ((jumpB c t).state (t + 1)).2 = true := by
  rw [jumpB_state]
  exact decide_eq_true (lt_add_one t)

theorem not_Fp_stayA (c t : ℤ) : ¬ PlusTruthAt Mg (stayA c t) t Fp := by
  rw [PlusTruth.someFuture_iff]
  rintro ⟨s, -, hs⟩
  have hs' : ((stayA c t).state s).2 = true := hs
  rw [stayA_state] at hs'
  exact Bool.noConfusion hs'

theorem Fp_jumpB (c t : ℤ) : PlusTruthAt Mg (jumpB c t) t Fp := by
  rw [PlusTruth.someFuture_iff]
  exact ⟨t + 1, lt_add_one t, jumpB_state_succ c t⟩

/-! ## The obstruction -/

/-- The seam `(stayA c t, t)` is not decided on `Fp`: `stayA` refutes it, `jumpB` satisfies it,
and both pass through `(c, a)` at `t`. Stated against the library's `SeamDecided`. -/
theorem seam_undecided (c t : ℤ) : ¬ SeamDecided Mg (stayA c t) t Fp := by
  rintro (hall | hnone)
  · exact not_Fp_stayA c t ((PlusTruth.stab_iff Mg (stayA c t) t Fp).mp hall (stayA c t) rfl)
  · have h := (PlusTruth.stab_iff Mg (stayA c t) t Fp.neg).mp hnone (jumpB c t)
      (by rw [stayA_state_t, jumpB_state_t])
    exact (PlusTruth.neg_iff Mg (jumpB c t) t Fp).mp h (Fp_jumpB c t)

/-- **No `Presents` inhabitant exists at that seam, for any parameters** — by the library's
`seamDecided_of_presents`. -/
theorem no_presents_on_fixture (c t : ℤ) (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k) :
    ¬ Presents Mg (stayA c t) t Fp sig k T S :=
  fun h => seam_undecided c t (seamDecided_of_presents h)

end Probe737Presents

/-! ## Citations: the library results this probe rests on and points at (cited, not re-proved) -/

#check @FormalSystem.Metalogic.Decidability.RaySummary.exists_presents_iff
#check @FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hit
#check @FormalSystem.Metalogic.Decidability.RaySummary.presentsMulti_seamTrace

#print axioms Probe737Presents.seam_undecided
#print axioms Probe737Presents.no_presents_on_fixture

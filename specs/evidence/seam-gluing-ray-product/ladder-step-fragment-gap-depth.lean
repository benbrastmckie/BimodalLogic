/-
# THE GAP-READING DEPTH OF THE STEP FRAGMENT: DERIVED, PROVED, AND EXACT

The agreement of ladder cells over counter classes was filed with a gap clip
`B ≥ max (2 dBack + 1) (2 dFwd + 1) 2` and is refuted at that clip
(`ladder-cell-agreement-refutation.lean`, fourth section).  This probe asks whether the defect is
the CLIP or the INVARIANT, on the part of the language where the question can be closed outright:
the STEP FRAGMENT — every connective, `⊡` and `□` included, with `untl`/`snce` admitted only at
the guard `⊥` (that is, as `X` and its mirror).

## What this probe compiles

* `Zrel a b` — a relation on ladder states indexed by a budget of `a` backward and `b` forward
  steps: same object state, countdowns equal or both `≥ 2 (a + b)`, registers equal or both
  `≥ 2 (a + b)`, gaps equal or both `≥ 2 a` or both `≤ -(2 b + 2)`.  The thresholds are the
  solution of the one-step closure conditions and are not chosen.
* `Zrel_succ`, `Zrel_pred` — the one-step back-and-forth, for EVERY object `(step, pend)`.
* `exists_linked_path` — the path forth: a state related to the state a ladder path visits lies
  on a ladder path linked to it on the whole window.  This is the `⊡` clause.
* `truth_iff_of_lnk` — the truth lemma on the step fragment, `⊡` and `□` included.
* `cellAt_eq_of_Zrel` — related states have the same cell: the agreement as a COROLLARY of the
  back-and-forth, for every finite object, with no parameter condition.
* `cellAt_const_of_kappa_eq_stepFrag`, `cellAt_const_of_kappa_eq_stepFrag_at_time` — the shape of
  the filed agreement (a `kappa`-collision in, equal cells out) at the gap clip
  `B ≥ max (2 dBack) (2 dFwd + 2)` and thresholds `≥ 2 (dBack + dFwd)`.  The residue coordinates
  are not read.
* `cellAt_eq_of_exact_gap_shift` — at the EXACT gap reading (no clip at all) the agreement holds
  on the fragment: a common shift of countdown and register keeps the cell.
* `real_subset_Dmax_stepFrag` — on the fragment at the derived parameters the realized set
  satisfies all six certificate conditions, condition (5) included, and lies inside `Dmax`.
* `sigC_refutes` — the filed clip is ONE SHORT on the fragment at every forward depth `b ≥ 1`:
  `sigC b := ◇ X^b ◇ Y ¬p` has `dBack = 1`, `dFwd = b`, (K4)'s output is `2 b + 1`, and at
  `paramsOk_params` two counter pairs of one class have different cells.
* `stepFrag_gap_depth_exact` — upper and lower bound together: at `sigC b` the clip `2 b + 1`
  fails and the clip `2 b + 2 = 2 dFwd + 2` holds.
* `thetaC_pair_not_collision`, `mixC_pair_not_collision` — the two landed refuting collisions stop
  being collisions at the clips `4` and `3 k + 5`.  Arithmetic on `kappa` only: it says the landed
  WITNESSES are gone at those clips, not that the agreement holds there.

## What this probe does NOT settle

It proves nothing about a formula with an `untl` or `snce` at a guard other than `⊥`.  The truth
lemma's window (`Lnk`) has width `a + b` and says nothing about a witness further away, which is
what an unbounded jump reads; the two landed separating families (`thetaC`, `mixC`) each use one
such jump, so neither is covered and the gap-reading depth of the whole language is NOT computed
here.  It does not prove the filed `cellAt_const_of_kappa_eq`, `ladderRealized`, `ladderSound`,
`ladderLift` or `ladderCons_localRun`, and re-states none of them.  `real_subset_Dmax_stepFrag`
is the inclusion `Real ⊆ Dmax` on the fragment only; the converse inclusion is not addressed.
The thresholds `2 (dBack + dFwd)` are shown sufficient, not necessary.  Every quantity named is a
COUNT; no complexity bound is claimed.

## Verification

`#print axioms` on every headline theorem.  No `sorry`, no axiom, no `native_decide`, no
placeholder body and no vacuous definition.  No finite-width or finite-fibre assumption, no
trace-level hypothesis, no `ParamsOk` strengthening.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761Z

/-! ### The derived state relation -/

section StateSys

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE DERIVED RELATION.** Two ladder states are related at the budget `(a, b)` — `a` backward
steps and `b` forward steps still to be read — when they carry the same object state, their
countdowns are equal or both at least `2 (a + b)`, their registers are equal or both at least
`2 (a + b)`, and their gaps `n - c` are equal, or both at least `2 a`, or both at most
`-(2 b + 2)`.  Every threshold is the solution of a one-step closure condition
(`Zrel_succ`, `Zrel_pred`); none is chosen. -/
def Zrel (a b : ℕ) (x y : LadderState Q pend) : Prop :=
  x.1.1 = y.1.1 ∧
  (x.1.2.1 = y.1.2.1 ∨ (2 * (a + b) ≤ x.1.2.1 ∧ 2 * (a + b) ≤ y.1.2.1)) ∧
  (x.1.2.2 = y.1.2.2 ∨ (2 * (a + b) ≤ x.1.2.2 ∧ 2 * (a + b) ≤ y.1.2.2)) ∧
  ((x.1.2.2 : ℤ) - x.1.2.1 = (y.1.2.2 : ℤ) - y.1.2.1 ∨
    (2 * (a : ℤ) ≤ (x.1.2.2 : ℤ) - x.1.2.1 ∧ 2 * (a : ℤ) ≤ (y.1.2.2 : ℤ) - y.1.2.1) ∨
    ((x.1.2.2 : ℤ) - x.1.2.1 ≤ -(2 * (b : ℤ) + 2) ∧
      (y.1.2.2 : ℤ) - y.1.2.1 ≤ -(2 * (b : ℤ) + 2)))

theorem Zrel_refl (a b : ℕ) (x : LadderState Q pend) : Zrel a b x x :=
  ⟨rfl, Or.inl rfl, Or.inl rfl, Or.inl rfl⟩

theorem Zrel_symm {a b : ℕ} {x y : LadderState Q pend} (h : Zrel a b x y) : Zrel a b y x := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨h1.symm, ?_, ?_, ?_⟩ <;> omega

theorem Zrel_mono {a b a' b' : ℕ} {x y : LadderState Q pend} (ha : a' ≤ a) (hb : b' ≤ b)
    (h : Zrel a b x y) : Zrel a' b' x y := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨h1, ?_, ?_, ?_⟩ <;> omega

/-- **ONE STEP FORWARD.** -/
theorem Zrel_succ {a b : ℕ} {x y x₁ : LadderState Q pend} {t : ℤ}
    (hZ : Zrel a (b + 1) x y) (hs : RladAdm step pend t x x₁) :
    ∃ y₁ : LadderState Q pend, RladAdm step pend t y y₁ ∧ Zrel a b x₁ y₁ := by
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  obtain ⟨⟨q', c', n'⟩, hy⟩ := y
  obtain ⟨⟨q₁, c₁, n₁⟩, hx₁⟩ := x₁
  obtain ⟨hq, hc, hn, hgap⟩ := hZ
  obtain ⟨hst, -, hdr, hcnt⟩ := hs
  dsimp only at hq hc hn hgap hst hdr hcnt
  subst hq
  have hx' : pend q = false → c = 0 := hx
  have hy' : pend q = false → c' = 0 := hy
  unfold Drift at hdr
  cases hp : pend q <;> cases hp1 : pend q₁
  · -- idle to idle
    have h0 : c = 0 := hx' hp
    have h0' : c' = 0 := hy' hp
    have hc1 : c₁ = 0 := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, 0, n' + n₁ - n), fun _ => rfl⟩, ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · show Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · show Count (pend q) (pend q₁) c' n' 0
      simp [Count, hp, hp1]
    · show c₁ = 0 ∨ _
      exact Or.inl hc1
    · show n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · show (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧ 2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- idle to pending: the countdown is handed the register
    have h0 : c = 0 := hx' hp
    have h0' : c' = 0 := hy' hp
    have hc1 : c₁ = n := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, n', n' + n₁ - n), fun h => by rw [hp1] at h; cases h⟩,
      ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · show Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · show Count (pend q) (pend q₁) c' n' n'
      simp [Count, hp, hp1]
    · show c₁ = n' ∨ (2 * (a + b) ≤ c₁ ∧ 2 * (a + b) ≤ n')
      omega
    · show n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · show (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧ 2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending to idle: the countdown is exhausted
    have hc1 : c₁ = 0 ∧ c = 0 := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, 0, n' + n₁ - n), fun _ => rfl⟩, ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · show Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · show Count (pend q) (pend q₁) c' n' 0
      have : c' = 0 := by omega
      simp [Count, hp, hp1, this]
    · show c₁ = 0 ∨ _
      exact Or.inl hc1.1
    · show n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · show (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧ 2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending to pending: the countdown falls by one
    have hc1 : c₁ + 1 = c := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, c' - 1, n' + n₁ - n), fun h => by rw [hp1] at h; cases h⟩,
      ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · show Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · show Count (pend q) (pend q₁) c' n' (c' - 1)
      have : c' - 1 + 1 = c' := by omega
      simp [Count, hp, hp1, this]
    · show c₁ = c' - 1 ∨ (2 * (a + b) ≤ c₁ ∧ 2 * (a + b) ≤ c' - 1)
      omega
    · show n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · show (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧
          2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ) ≤ -(2 * (b : ℤ) + 2))
      omega

/-- **ONE STEP BACKWARD.** -/
theorem Zrel_pred {a b : ℕ} {x y x₀ : LadderState Q pend} {t : ℤ}
    (hZ : Zrel (a + 1) b x y) (hs : RladAdm step pend t x₀ x) :
    ∃ y₀ : LadderState Q pend, RladAdm step pend t y₀ y ∧ Zrel a b x₀ y₀ := by
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  obtain ⟨⟨q', c', n'⟩, hy⟩ := y
  obtain ⟨⟨q₀, c₀, n₀⟩, hx₀⟩ := x₀
  obtain ⟨hq, hc, hn, hgap⟩ := hZ
  obtain ⟨hst, hsrc, hdr, hcnt⟩ := hs
  dsimp only at hq hc hn hgap hst hsrc hdr hcnt
  subst hq
  have hx' : pend q = false → c = 0 := hx
  have hy' : pend q = false → c' = 0 := hy
  unfold Drift at hdr
  cases hp0 : pend q₀ <;> cases hp : pend q
  · -- idle before idle
    have h0 : c = 0 := hx' hp
    have h0' : c' = 0 := hy' hp
    have hc0 : c₀ = 0 := hsrc hp0
    refine ⟨⟨(q₀, 0, n' + n₀ - n), fun _ => rfl⟩, ⟨hst, fun _ => rfl, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · show Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · show Count (pend q₀) (pend q) 0 (n' + n₀ - n) c'
      simp [Count, hp0, hp, h0']
    · show c₀ = 0 ∨ _
      exact Or.inl hc0
    · show n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · show (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧ 2 * (a : ℤ) ≤ ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- idle before pending: a region entry, which pins the gap inside `[-1, 1]`
    have hc0 : c₀ = 0 := hsrc hp0
    have hcn : c = n₀ := by simpa [Count, hp0, hp] using hcnt
    refine ⟨⟨(q₀, 0, c'), fun _ => rfl⟩, ⟨hst, fun _ => rfl, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · show Drift c' n'
      unfold Drift; omega
    · show Count (pend q₀) (pend q) 0 c' c'
      simp [Count, hp0, hp]
    · show c₀ = 0 ∨ _
      exact Or.inl hc0
    · show n₀ = c' ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ c')
      omega
    · show (n₀ : ℤ) - c₀ = (c' : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧ 2 * (a : ℤ) ≤ (c' : ℤ) - (0 : ℕ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧ (c' : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending before idle: the last pending position
    have h0' : c' = 0 := hy' hp
    have hcc : c = 0 ∧ c₀ = 0 := by simpa [Count, hp0, hp] using hcnt
    refine ⟨⟨(q₀, 0, n' + n₀ - n), fun _ => rfl⟩, ⟨hst, fun _ => rfl, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · show Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · show Count (pend q₀) (pend q) 0 (n' + n₀ - n) c'
      simp [Count, hp0, hp, h0']
    · show c₀ = 0 ∨ _
      exact Or.inl hcc.2
    · show n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · show (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧ 2 * (a : ℤ) ≤ ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending before pending
    have hcc : c + 1 = c₀ := by simpa [Count, hp0, hp] using hcnt
    refine ⟨⟨(q₀, c' + 1, n' + n₀ - n), fun h => by rw [hp0] at h; cases h⟩,
      ⟨hst, ?_, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · intro h
      rw [show pend (q₀, c' + 1, n' + n₀ - n).1 = pend q₀ from rfl, hp0] at h
      cases h
    · show Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · show Count (pend q₀) (pend q) (c' + 1) (n' + n₀ - n) c'
      simp [Count, hp0, hp]
    · show c₀ = c' + 1 ∨ (2 * (a + b) ≤ c₀ ∧ 2 * (a + b) ≤ c' + 1)
      omega
    · show n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · show (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - ((c' + 1 : ℕ) : ℤ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧
          2 * (a : ℤ) ≤ ((n' + n₀ - n : ℕ) : ℤ) - ((c' + 1 : ℕ) : ℤ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₀ - n : ℕ) : ℤ) - ((c' + 1 : ℕ) : ℤ) ≤ -(2 * (b : ℤ) + 2))
      omega

end StateSys

/-! ### Paths: gluing, a path through every state, and the window link -/

section Paths

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- Follow `g₁` up to and including `z`, and `g₂` from `z + 1` on. -/
def glue (g₁ g₂ : ℤ → LadderState Q pend) (z : ℤ) : ℤ → LadderState Q pend :=
  fun v => if v ≤ z then g₁ v else g₂ v

theorem glue_isPath (g₁ g₂ : ℤ → LadderState Q pend)
    (h₁ : IsLadderPath step pend g₁) (h₂ : IsLadderPath step pend g₂) (z : ℤ)
    (hz : RladAdm step pend z (g₁ z) (g₂ (z + 1))) :
    IsLadderPath step pend (glue g₁ g₂ z) := by
  intro u
  unfold glue
  by_cases h : u + 1 ≤ z
  · rw [if_pos (by omega), if_pos h]
    exact h₁ u
  · by_cases h' : u ≤ z
    · have hu : u = z := by omega
      subst hu
      rw [if_pos le_rfl, if_neg h]
      exact hz
    · rw [if_neg h', if_neg h]
      exact h₂ u

theorem glue_of_le (g₁ g₂ : ℤ → LadderState Q pend) (z v : ℤ) (h : v ≤ z) :
    glue g₁ g₂ z v = g₁ v := by
  unfold glue; rw [if_pos h]

theorem glue_of_gt (g₁ g₂ : ℤ → LadderState Q pend) (z v : ℤ) (h : z < v) :
    glue g₁ g₂ z v = g₂ v := by
  unfold glue; rw [if_neg (by omega)]

/-- **A LADDER PATH THROUGH EVERY STATE, AT EVERY POSITION**, from the two seriality hypotheses
the frame is built on and nothing else. -/
theorem exists_path_through
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (x : LadderState Q pend) (z : ℤ) :
    ∃ g : ℤ → LadderState Q pend, IsLadderPath step pend g ∧ g z = x := by
  classical
  choose F hF using fwd 0
  choose G hG using bwd 0
  refine ⟨fun v => if z ≤ v then F^[(v - z).toNat] x else G^[(z - v).toNat] x, ?_, ?_⟩
  · intro u
    show RladAdm step pend u _ _
    beta_reduce
    by_cases h : z ≤ u
    · rw [if_pos h, if_pos (by omega),
        show (u + 1 - z).toNat = (u - z).toNat + 1 by omega, Function.iterate_succ_apply']
      exact hF _
    · by_cases h' : z ≤ u + 1
      · have hu : u + 1 = z := by omega
        rw [if_neg h, if_pos h', show (u + 1 - z).toNat = 0 by omega,
          show (z - u).toNat = 1 by omega]
        exact hG x
      · rw [if_neg h, if_neg h', show (z - u).toNat = (z - (u + 1)).toNat + 1 by omega,
          Function.iterate_succ_apply']
        exact hG _
  · show (if z ≤ z then F^[(z - z).toNat] x else G^[(z - z).toNat] x) = x
    rw [if_pos le_rfl, show (z - z).toNat = 0 by omega]
    rfl

/-- **THE WINDOW LINK.** Two paths are linked at `t` with budget `(a, b)` when their states at
`t + i` are related, for `-a ≤ i ≤ b`, at the budget left after `|i|` steps in the direction of
`i`. -/
def Lnk (a b : ℕ) (g g' : ℤ → LadderState Q pend) (t : ℤ) : Prop :=
  ∀ i : ℤ, -(a : ℤ) ≤ i → i ≤ (b : ℤ) →
    Zrel (a - (-i).toNat) (b - i.toNat) (g (t + i)) (g' (t + i))

theorem Lnk_symm {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a b g g' t) :
    Lnk a b g' g t :=
  fun i h1 h2 => Zrel_symm (h i h1 h2)

theorem Lnk_mono {a b a' b' : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ}
    (ha : a' ≤ a) (hb : b' ≤ b) (h : Lnk a b g g' t) : Lnk a' b' g g' t :=
  fun i h1 h2 => Zrel_mono (by omega) (by omega) (h i (by omega) (by omega))

theorem Lnk_zero {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a b g g' t) :
    Zrel a b (g t) (g' t) := by
  have := h 0 (by omega) (by omega)
  simpa using this

theorem Lnk_succ {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a (b + 1) g g' t) :
    Lnk a b g g' (t + 1) := by
  intro i h1 h2
  have := h (i + 1) (by omega) (by push_cast; omega)
  rw [show t + (i + 1) = t + 1 + i by ring] at this
  exact Zrel_mono (by omega) (by omega) this

theorem Lnk_pred {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk (a + 1) b g g' t) :
    Lnk a b g g' (t - 1) := by
  intro i h1 h2
  have := h (i - 1) (by push_cast; omega) (by omega)
  rw [show t + (i - 1) = t - 1 + i by ring] at this
  exact Zrel_mono (by omega) (by omega) this

/-- **THE PATH FORTH.** A state related to the state a path visits at `t` lies on a path linked
to it there.  This is where the one-step closure conditions become a statement about histories,
and it is the `⊡` clause of the truth lemma below. -/
theorem exists_linked_path
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (a b : ℕ) (h : ℤ → LadderState Q pend) (hh : IsLadderPath step pend h) (t : ℤ)
    (y : LadderState Q pend) (hZ : Zrel a b (h t) y) :
    ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧ h' t = y ∧ Lnk a b h h' t := by
  -- forward half
  have hfw : ∀ j : ℕ, j ≤ b → ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧
      h' t = y ∧ ∀ i : ℕ, i ≤ j → Zrel a (b - i) (h (t + (i : ℤ))) (h' (t + (i : ℤ))) := by
    intro j
    induction j with
    | zero =>
      intro _
      obtain ⟨p, hp, hpt⟩ := exists_path_through fwd bwd y t
      refine ⟨p, hp, hpt, fun i hi => ?_⟩
      have hi0 : i = 0 := by omega
      subst hi0
      simpa [hpt] using hZ
    | succ j ih =>
      intro hj
      obtain ⟨h', hh', ht', hrel⟩ := ih (by omega)
      have hr := hrel j le_rfl
      rw [show b - j = (b - j - 1) + 1 by omega] at hr
      obtain ⟨y₁, hy₁, hZ₁⟩ := Zrel_succ hr (hh (t + (j : ℤ)))
      obtain ⟨p, hp, hpt⟩ := exists_path_through fwd bwd y₁ (t + (j : ℤ) + 1)
      refine ⟨glue h' p (t + (j : ℤ)), glue_isPath h' p hh' hp _ (by rw [hpt]; exact hy₁), ?_, ?_⟩
      · rw [glue_of_le _ _ _ _ (by omega)]
        exact ht'
      · intro i hi
        by_cases hij : i ≤ j
        · rw [glue_of_le _ _ _ _ (by omega)]
          exact hrel i hij
        · have hi1 : i = j + 1 := by omega
          subst hi1
          rw [glue_of_gt _ _ _ _ (by push_cast; omega),
            show t + ((j + 1 : ℕ) : ℤ) = t + (j : ℤ) + 1 by push_cast; ring, hpt]
          rw [show b - (j + 1) = b - j - 1 by omega]
          exact hZ₁
  obtain ⟨h₁, hh₁, ht₁, hrel₁⟩ := hfw b le_rfl
  -- backward half
  have hbw : ∀ j : ℕ, j ≤ a → ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧
      h' t = y ∧ (∀ i : ℕ, i ≤ b → Zrel a (b - i) (h (t + (i : ℤ))) (h' (t + (i : ℤ)))) ∧
      ∀ i : ℕ, i ≤ j → Zrel (a - i) b (h (t - (i : ℤ))) (h' (t - (i : ℤ))) := by
    intro j
    induction j with
    | zero =>
      intro _
      refine ⟨h₁, hh₁, ht₁, hrel₁, fun i hi => ?_⟩
      have hi0 : i = 0 := by omega
      subst hi0
      simpa [ht₁] using hZ
    | succ j ih =>
      intro hj
      obtain ⟨h', hh', ht', hfwd, hrel⟩ := ih (by omega)
      have hr := hrel j le_rfl
      rw [show a - j = (a - j - 1) + 1 by omega] at hr
      have hstep : RladAdm step pend (t - (j : ℤ) - 1) (h (t - (j : ℤ) - 1)) (h (t - (j : ℤ))) := by
        have := hh (t - (j : ℤ) - 1)
        rwa [show t - (j : ℤ) - 1 + 1 = t - (j : ℤ) by ring] at this
      obtain ⟨y₀, hy₀, hZ₀⟩ := Zrel_pred hr hstep
      obtain ⟨p, hp, hpt⟩ := exists_path_through fwd bwd y₀ (t - (j : ℤ) - 1)
      refine ⟨glue p h' (t - (j : ℤ) - 1), glue_isPath p h' hp hh' _ ?_, ?_, ?_, ?_⟩
      · rw [hpt, show t - (j : ℤ) - 1 + 1 = t - (j : ℤ) by ring]
        exact hy₀
      · rw [glue_of_gt _ _ _ _ (by omega)]
        exact ht'
      · intro i hi
        rw [glue_of_gt _ _ _ _ (by omega)]
        exact hfwd i hi
      · intro i hi
        by_cases hij : i ≤ j
        · rw [glue_of_gt _ _ _ _ (by omega)]
          exact hrel i hij
        · have hi1 : i = j + 1 := by omega
          subst hi1
          rw [show t - ((j + 1 : ℕ) : ℤ) = t - (j : ℤ) - 1 by push_cast; ring,
            glue_of_le _ _ _ _ le_rfl, hpt]
          rw [show a - (j + 1) = a - j - 1 by omega]
          exact hZ₀
  obtain ⟨h₂, hh₂, ht₂, hf₂, hb₂⟩ := hbw a le_rfl
  refine ⟨h₂, hh₂, ht₂, fun i h1 h2 => ?_⟩
  by_cases hi : 0 ≤ i
  · have := hf₂ i.toNat (by omega)
    rw [show ((i.toNat : ℕ) : ℤ) = i by omega] at this
    rw [show (-i).toNat = 0 by omega]
    simpa using this
  · have := hb₂ (-i).toNat (by omega)
    rw [show t - (((-i).toNat : ℕ) : ℤ) = t + i by omega] at this
    rw [show i.toNat = 0 by omega]
    simpa using this

end Paths

/-! ### The step fragment and its truth lemma -/

/-- **THE STEP FRAGMENT.** Every connective of the language, with `untl` and `snce` admitted only
at the guard `⊥` — that is, as `X` and its mirror.  `⊡` and `□` are admitted without restriction.
What the fragment excludes is exactly the UNBOUNDED temporal jump. -/
def StepFrag : PlusFormula → Prop
  | .atom _ => True
  | .bot => True
  | .imp α β => StepFrag α ∧ StepFrag β
  | .box α => StepFrag α
  | .untl γ α => γ = .bot ∧ StepFrag α
  | .snce γ α => γ = .bot ∧ StepFrag α
  | .stab α => StepFrag α

/-- The fragment and the two exactness depths pass to subformulas. -/
theorem frag_of_mem : ∀ φ : PlusFormula, StepFrag φ → ∀ ψ ∈ PlusFormula.subformulas φ,
    StepFrag ψ ∧ dBack ψ ≤ dBack φ ∧ dFwd ψ ≤ dFwd φ := by
  intro φ
  induction φ with
  | atom p =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_singleton] at h
    subst h
    exact ⟨hf, le_rfl, le_rfl⟩
  | bot =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_singleton] at h
    subst h
    exact ⟨hf, le_rfl, le_rfl⟩
  | imp α β iha ihb =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · obtain ⟨h1, h2, h3⟩ := iha hf.1 ψ h
      exact ⟨h1, le_trans h2 (le_max_left _ _), le_trans h3 (le_max_left _ _)⟩
    · obtain ⟨h1, h2, h3⟩ := ihb hf.2 ψ h
      exact ⟨h1, le_trans h2 (le_max_right _ _), le_trans h3 (le_max_right _ _)⟩
  | box α iha =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons] at h
    rcases h with rfl | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · exact iha hf ψ h
  | untl γ α ihg iha =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · obtain ⟨h1, h2, h3⟩ := iha hf.2 ψ h
      exact ⟨h1, le_trans h2 (le_max_right _ _),
        le_trans h3 (le_trans (le_max_right _ _) (Nat.le_succ _))⟩
    · obtain ⟨h1, h2, h3⟩ := ihg (by rw [hf.1]; trivial) ψ h
      exact ⟨h1, le_trans h2 (le_max_left _ _),
        le_trans h3 (le_trans (le_max_left _ _) (Nat.le_succ _))⟩
  | snce γ α ihg iha =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · obtain ⟨h1, h2, h3⟩ := iha hf.2 ψ h
      exact ⟨h1, le_trans h2 (le_trans (le_max_right _ _) (Nat.le_succ _)),
        le_trans h3 (le_max_right _ _)⟩
    · obtain ⟨h1, h2, h3⟩ := ihg (by rw [hf.1]; trivial) ψ h
      exact ⟨h1, le_trans h2 (le_trans (le_max_left _ _) (Nat.le_succ _)),
        le_trans h3 (le_max_left _ _)⟩
  | stab α iha =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons] at h
    rcases h with rfl | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · exact iha hf ψ h

section Truth

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

theorem int_succ_lt_of_ne (t s : ℤ) (h : t < s) (hne : s ≠ t + 1) : t + 1 < s := by omega

theorem int_not_between (t r : ℤ) (h1 : t < r) (h2 : r < t + 1) : False := by omega

theorem int_lt_pred_of_ne (t s : ℤ) (h : s < t) (hne : s ≠ t - 1) : s < t - 1 := by omega

theorem int_pred_lt (t : ℤ) : t - 1 < t := by omega

theorem int_not_between_pred (t r : ℤ) (h1 : t - 1 < r) (h2 : r < t) : False := by omega

theorem truth_nxt
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt (ladderModel step pend fwd bwd lab) τ t (.untl .bot ψ) ↔
      PlusTruthAt (ladderModel step pend fwd bwd lab) τ (t + 1) ψ := by
  constructor
  · rintro ⟨s, hts, hs, hr⟩
    by_cases he : s = t + 1
    · rw [he] at hs
      exact hs
    · exact (hr (t + 1) (Int.lt_succ_self t) (int_succ_lt_of_ne t s hts he)).elim
  · intro h
    exact ⟨t + 1, Int.lt_succ_self t, h, fun r h1 h2 => (int_not_between t r h1 h2).elim⟩

theorem truth_prv
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt (ladderModel step pend fwd bwd lab) τ t (.snce .bot ψ) ↔
      PlusTruthAt (ladderModel step pend fwd bwd lab) τ (t - 1) ψ := by
  constructor
  · rintro ⟨s, hst, hs, hr⟩
    by_cases he : s = t - 1
    · rw [he] at hs
      exact hs
    · exact (hr (t - 1) (int_lt_pred_of_ne t s hst he) (int_pred_lt t)).elim
  · intro h
    exact ⟨t - 1, int_pred_lt t, h, fun r h1 h2 => (int_not_between_pred t r h1 h2).elim⟩

/-- **THE TRUTH LEMMA.** Two ladder histories whose paths are linked at `t` with a budget at
least the formula's two exactness depths agree on it at `t` — for every formula of the step
fragment, `⊡` and `□` included. -/
theorem truth_iff_of_lnk
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool) :
    ∀ ψ : PlusFormula, StepFrag ψ → ∀ a b : ℕ, dBack ψ ≤ a → dFwd ψ ≤ b →
      ∀ (τ τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (k k' : ℤ)
        (g g' : ℤ → LadderState Q pend) (t : ℤ),
        IsLadderPath step pend g → IsLadderPath step pend g' →
        (∀ u : ℤ, τ.state u = (u + k, g u)) → (∀ u : ℤ, τ'.state u = (u + k', g' u)) →
        Lnk a b g g' t →
        (PlusTruthAt (ladderModel step pend fwd bwd lab) τ t ψ ↔
          PlusTruthAt (ladderModel step pend fwd bwd lab) τ' t ψ) := by
  intro ψ
  induction ψ with
  | atom p =>
    intro _ a b _ _ τ τ' k k' g g' t _ _ hτ hτ' hl
    show lab (τ.state t).2.1.1 p = true ↔ lab (τ'.state t).2.1.1 p = true
    rw [hτ t, hτ' t]
    show lab (g t).1.1 p = true ↔ lab (g' t).1.1 p = true
    rw [(Lnk_zero hl).1]
  | bot =>
    intro _ a b _ _ τ τ' k k' g g' t _ _ _ _ _
    exact Iff.rfl
  | imp α β iha ihb =>
    intro hf a b hda hdb τ τ' k k' g g' t hg hg' hτ hτ' hl
    have h1 := iha hf.1 a b (le_trans (le_max_left _ _) hda) (le_trans (le_max_left _ _) hdb)
      τ τ' k k' g g' t hg hg' hτ hτ' hl
    have h2 := ihb hf.2 a b (le_trans (le_max_right _ _) hda) (le_trans (le_max_right _ _) hdb)
      τ τ' k k' g g' t hg hg' hτ hτ' hl
    exact ⟨fun hi x => h2.mp (hi (h1.mpr x)), fun hi x => h2.mpr (hi (h1.mp x))⟩
  | box α _ =>
    intro _ a b _ _ τ τ' k k' g g' t _ _ _ _ _
    exact Iff.rfl
  | untl γ α _ iha =>
    intro hf a b hda hdb τ τ' k k' g g' t hg hg' hτ hτ' hl
    obtain ⟨rfl, hfα⟩ := hf
    have hb1 : dFwd α + 1 ≤ b := le_trans (Nat.succ_le_succ (le_max_right _ _)) hdb
    rw [truth_nxt, truth_nxt]
    have hl' : Lnk a (b - 1) g g' (t + 1) := by
      apply Lnk_succ
      rw [show b - 1 + 1 = b by omega]
      exact hl
    exact iha hfα a (b - 1) (le_trans (le_max_right _ _) hda) (by omega)
      τ τ' k k' g g' (t + 1) hg hg' hτ hτ' hl'
  | snce γ α _ iha =>
    intro hf a b hda hdb τ τ' k k' g g' t hg hg' hτ hτ' hl
    obtain ⟨rfl, hfα⟩ := hf
    have ha1 : dBack α + 1 ≤ a := le_trans (Nat.succ_le_succ (le_max_right _ _)) hda
    rw [truth_prv, truth_prv]
    have hl' : Lnk (a - 1) b g g' (t - 1) := by
      apply Lnk_pred
      rw [show a - 1 + 1 = a by omega]
      exact hl
    exact iha hfα (a - 1) b (by omega) (le_trans (le_max_right _ _) hdb)
      τ τ' k k' g g' (t - 1) hg hg' hτ hτ' hl'
  | stab α iha =>
    intro hf a b hda hdb τ τ' k k' g g' t hg hg' hτ hτ' hl
    have key : ∀ (τ τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
        (k k' : ℤ) (g g' : ℤ → LadderState Q pend),
        (∀ u : ℤ, τ.state u = (u + k, g u)) → (∀ u : ℤ, τ'.state u = (u + k', g' u)) →
        Lnk a b g g' t →
        PlusTruthAt (ladderModel step pend fwd bwd lab) τ t (.stab α) →
        PlusTruthAt (ladderModel step pend fwd bwd lab) τ' t (.stab α) := by
      intro τ τ' k k' g g' hτ hτ' hl h σ' hσ'
      obtain ⟨kσ', gσ', hgσ', hpσ'⟩ := exists_isLadderPath_of_hist fwd bwd σ'
      have e : ((t + k', g' t) : (ladderFrameAdm step pend fwd bwd).WorldState)
          = (t + kσ', gσ' t) := (hτ' t).symm.trans (hσ'.trans (hpσ' t))
      have eg : g' t = gσ' t := congrArg Prod.snd e
      have hz : Zrel a b (gσ' t) (g t) := by
        rw [← eg]
        exact Zrel_symm (Lnk_zero hl)
      obtain ⟨gσ, hgσ, hgσt, hlσ⟩ := exists_linked_path fwd bwd a b gσ' hgσ' t (g t) hz
      obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath_at_offset fwd bwd k gσ hgσ
      have hσt : τ.state t = σ.state t := by rw [hτ t, hσ t, hgσt]
      exact (iha hf a b hda hdb σ σ' k kσ' gσ gσ' t hgσ hgσ' hσ hpσ' (Lnk_symm hlσ)).mp
        (h σ hσt)
    exact ⟨key τ τ' k k' g g' hτ hτ' hl, key τ' τ k' k g' g hτ' hτ (Lnk_symm hl)⟩

/-- One inclusion of the agreement. -/
theorem cellAt_subset_of_Zrel
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (hφ : StepFrag φ) (x y : LadderState Q pend)
    (hZ : Zrel (dBack φ) (dFwd φ) x y) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, y) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, rfl⟩ := (mem_cellAt_ladder_iff fwd bwd lab φ x z T).mp hT
  obtain ⟨g', hg', hg'z, hl⟩ :=
    exists_linked_path fwd bwd (dBack φ) (dFwd φ) g hg z y (by rw [hgz]; exact hZ)
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine (mem_cellAt_ladder_iff fwd bwd lab φ y z _).mpr ⟨g', τ', hg', hg'z, hτ', ?_⟩
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  have hiff : ψ ∈ plusSubformulaClosure φ →
      (PlusTruthAt (ladderModel step pend fwd bwd lab) τ z ψ ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) τ' z ψ) := by
    intro hm
    have hm' : ψ ∈ PlusFormula.subformulas φ := by
      simpa [plusSubformulaClosure] using hm
    obtain ⟨hf, h1, h2⟩ := frag_of_mem φ hφ ψ hm'
    exact truth_iff_of_lnk fwd bwd lab ψ hf _ _ h1 h2 τ τ' 0 0 g g' z hg hg'
      (fun u => by rw [hτ u, add_zero]) (fun u => by rw [hτ' u, add_zero]) hl
  constructor
  · rintro ⟨hm, ht⟩
    exact ⟨hm, (hiff hm).mpr ht⟩
  · rintro ⟨hm, ht⟩
    exact ⟨hm, (hiff hm).mp ht⟩

/-- **THE AGREEMENT ON THE STEP FRAGMENT, AS A COROLLARY OF THE BACK-AND-FORTH.** For every finite
object, every labelling and every formula of the step fragment — `⊡` and `□` included — two
ladder states related at the formula's own two exactness depths have the same cell.  No parameter
condition is assumed: the thresholds are the ones `Zrel` carries, and they were forced by
`Zrel_succ` and `Zrel_pred`. -/
theorem cellAt_eq_of_Zrel
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (hφ : StepFrag φ) (x y : LadderState Q pend)
    (hZ : Zrel (dBack φ) (dFwd φ) x y) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z =
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, y) : (ladderFrameAdm step pend fwd bwd).WorldState) z :=
  Set.Subset.antisymm (cellAt_subset_of_Zrel fwd bwd lab φ hφ x y hZ z)
    (cellAt_subset_of_Zrel fwd bwd lab φ hφ y x (Zrel_symm hZ) z)

omit [Finite Q] [Nonempty Q] in
/-- **A COUNTER CLASS REFINES THE DERIVED RELATION** once its two thresholds dominate
`2 (a + b)` and its gap clip dominates `2 a` and `2 b + 2`.  The two residue coordinates are not
read. -/
theorem Zrel_of_kappa_eq (a b Tc Tn P B : ℕ) (hTc : 2 * (a + b) ≤ Tc) (hTn : 2 * (a + b) ≤ Tn)
    (hBa : 2 * a ≤ B) (hBb : 2 * b + 2 ≤ B) (q : Q) (c n c' n' : ℕ)
    (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    Zrel a b (⟨(q, c, n), h⟩ : LadderState Q pend) ⟨(q, c', n'), h'⟩ := by
  obtain ⟨h1, -, h3, -, h5⟩ := kappa_eq_components Tc Tn P B c n c' n' hk
  refine ⟨rfl, ?_, ?_, ?_⟩
  · show c = c' ∨ (2 * (a + b) ≤ c ∧ 2 * (a + b) ≤ c')
    omega
  · show n = n' ∨ (2 * (a + b) ≤ n ∧ 2 * (a + b) ≤ n')
    omega
  · show (n : ℤ) - c = (n' : ℤ) - c' ∨
      (2 * (a : ℤ) ≤ (n : ℤ) - c ∧ 2 * (a : ℤ) ≤ (n' : ℤ) - c') ∨
      ((n : ℤ) - c ≤ -(2 * (b : ℤ) + 2) ∧ (n' : ℤ) - c' ≤ -(2 * (b : ℤ) + 2))
    unfold clipIdx at h5
    split_ifs at h5 <;> omega

/-- **THE AGREEMENT OVER COUNTER CLASSES, ON THE STEP FRAGMENT, AT THE DERIVED CLIP.**  The shape
of the filed agreement — a `kappa`-collision as hypothesis, equality of the two cells as
conclusion — with the gap clip at `max (2 dBack) (2 dFwd + 2)` and both thresholds at
`2 (dBack + dFwd)`, for every finite object and every step-fragment formula.  It is NOT the filed
statement: the fragment excludes the unbounded jump, the world state is diagonal, and the
parameter hypotheses are the three displayed, not `ParamsOk`. -/
theorem cellAt_const_of_kappa_eq_stepFrag
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (hφ : StepFrag φ) (Tc Tn P B : ℕ)
    (hTc : 2 * (dBack φ + dFwd φ) ≤ Tc) (hTn : 2 * (dBack φ + dFwd φ) ≤ Tn)
    (hBa : 2 * dBack φ ≤ B) (hBb : 2 * dFwd φ + 2 ≤ B)
    (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z =
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z :=
  cellAt_eq_of_Zrel fwd bwd lab φ hφ _ _
    (Zrel_of_kappa_eq _ _ Tc Tn P B hTc hTn hBa hBb q c n c' n' h h' hk) z

/-- **AT THE EXACT GAP READING THE AGREEMENT HOLDS ON THE STEP FRAGMENT.** Shifting the countdown
and the register by one common amount keeps the gap exactly, and keeps the cell, as soon as both
counters reach `2 (dBack + dFwd)`.  No clip, no modulus, every finite object.  This is the reading
at which the tight histories sit (their gaps are in `{-1, 0, 1}`, inside every clip). -/
theorem cellAt_eq_of_exact_gap_shift
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (hφ : StepFrag φ) (q : Q) (c n M : ℕ)
    (h : c ∈ Adm pend q) (h' : c + M ∈ Adm pend q)
    (hc : 2 * (dBack φ + dFwd φ) ≤ c) (hn : 2 * (dBack φ + dFwd φ) ≤ n) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z =
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + M, n + M), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  refine cellAt_eq_of_Zrel fwd bwd lab φ hφ (⟨(q, c, n), h⟩ : LadderState Q pend)
    ⟨(q, c + M, n + M), h'⟩ ⟨rfl, ?_, ?_, ?_⟩ z
  · show c = c + M ∨ (2 * (dBack φ + dFwd φ) ≤ c ∧ 2 * (dBack φ + dFwd φ) ≤ c + M)
    omega
  · show n = n + M ∨ (2 * (dBack φ + dFwd φ) ≤ n ∧ 2 * (dBack φ + dFwd φ) ≤ n + M)
    omega
  · left
    show (n : ℤ) - c = ((n + M : ℕ) : ℤ) - ((c + M : ℕ) : ℤ)
    push_cast
    ring

/-- The agreement at a general world time and a general evaluation time: the diagonal statement
moved by the two landed invariances. -/
theorem cellAt_const_of_kappa_eq_stepFrag_at_time
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (hφ : StepFrag φ) (Tc Tn P B : ℕ)
    (hTc : 2 * (dBack φ + dFwd φ) ≤ Tc) (hTn : 2 * (dBack φ + dFwd φ) ≤ Tn)
    (hBa : 2 * dBack φ ≤ B) (hBb : 2 * dFwd φ + 2 ≤ B)
    (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (t t' z z' : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((t, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z =
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((t', ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z' := by
  have e1 := cellAt_eq_cellAt (ladderModel step pend fwd bwd lab) φ
    ((t, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z 0
  have e2 := cellAt_ladder_eq_of_worldTime fwd bwd lab φ
    (⟨(q, c, n), h⟩ : LadderState Q pend) t 0 0
  have e3 := cellAt_eq_cellAt (ladderModel step pend fwd bwd lab) φ
    ((t', ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z' 0
  have e4 := cellAt_ladder_eq_of_worldTime fwd bwd lab φ
    (⟨(q, c', n'), h'⟩ : LadderState Q pend) t' 0 0
  have e5 := cellAt_const_of_kappa_eq_stepFrag fwd bwd lab φ hφ Tc Tn P B hTc hTn hBa hBb
    q c n c' n' h h' hk 0
  exact e1.trans (e2.trans (e5.trans (e4.symm.trans e3.symm)))

/-- **THE CERTIFICATE SIDE REPAIRS WITH THE AGREEMENT, NOT SEPARATELY.** On the step fragment at
the derived parameters, the set of realized triples satisfies all six conditions — condition (5),
the `⊡` letter per `(q, κ)`, included — and so lies inside `Dmax`.  Conditions (1)-(4) and (6) are
the landed lemmas, which take no parameter hypothesis; condition (5) is the landed reduction to
the class-representative transport, and the transport is the agreement above. -/
theorem real_subset_Dmax_stepFrag
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (hφ : StepFrag φ) (Tc Tn P B : ℕ)
    (hTc : 2 * (dBack φ + dFwd φ) ≤ Tc) (hTn : 2 * (dBack φ + dFwd φ) ≤ Tn)
    (hBa : 2 * dBack φ ≤ B) (hBb : 2 * dFwd φ + 2 ≤ B) :
    certAdmK step pend lab φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) ∧
      Real step pend lab φ Tc Tn P B fwd bwd ⊆ Dmax step pend lab φ Tc Tn P B := by
  have htr : ClassRepTransport step pend lab φ Tc Tn P B fwd bwd := by
    intro q c n c' n' hq hq' t t' z z' hk
    exact (cellAt_const_of_kappa_eq_stepFrag_at_time fwd bwd lab φ hφ Tc Tn P B hTc hTn hBa hBb
      q c n c' n' hq hq' hk t t' z z').ge
  have hcert : certAdmK step pend lab φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) :=
    ⟨real_certLocK lab φ Tc Tn P B fwd bwd, real_certBiInfK lab φ Tc Tn P B fwd bwd,
      real_certFwdK lab φ Tc Tn P B fwd bwd, real_certBwdK lab φ Tc Tn P B fwd bwd,
      real_certStabK_of_classRepTransport lab φ Tc Tn P B fwd bwd htr,
      real_certBoxK lab φ Tc Tn P B fwd bwd⟩
  exact ⟨hcert, dmax_maximal step pend lab φ Tc Tn P B _ hcert⟩

end Truth

#print axioms Probe761Z.Zrel_succ
#print axioms Probe761Z.Zrel_pred
#print axioms Probe761Z.exists_linked_path
#print axioms Probe761Z.truth_iff_of_lnk
#print axioms Probe761Z.cellAt_eq_of_Zrel
#print axioms Probe761Z.cellAt_const_of_kappa_eq_stepFrag
#print axioms Probe761Z.cellAt_eq_of_exact_gap_shift
#print axioms Probe761Z.real_subset_Dmax_stepFrag

/-! ### The clip is exact: the lower bound on the two-state object -/

abbrev Qc : Type := Fin 2

def pendC : Qc → Bool := fun q => decide (q = 0)

def stepC : Qc → Qc → Bool := fun _ _ => true

def pC : Atom := ⟨"p", none⟩

def labC : Qc → Atom → Bool := fun q at_ => decide (at_ = pC ∧ q = 0)

theorem pendC_zero : pendC 0 = true := by decide

theorem pendC_one : pendC 1 = false := by decide

theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) (by simp)

theorem labC_pC (q : Qc) : labC q pC = pendC q := by
  simp [labC, pendC]

theorem fwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · cases c with
    | zero =>
        refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_one]
    | succ d =>
        refine ⟨⟨(0, d, n), admZeroC d n⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_one]

theorem bwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · refine ⟨⟨(0, c + 1, n), admZeroC (c + 1) n⟩, rfl, admZeroC (c + 1) n,
      Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    have hc : c = 0 := hx hq
    refine ⟨⟨(0, 0, n), admZeroC 0 n⟩, rfl, admZeroC 0 n, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero, hc]

noncomputable abbrev MC :
    TaskModel (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame :=
  ladderModel stepC pendC fwdC bwdC labC

/-- The pending state `⟨(0, c, n), _⟩`. -/
def stC (c n : ℕ) : LadderState Qc pendC := ⟨((0 : Qc), c, n), admZeroC c n⟩

/-- The idle state `⟨(1, 0, r), _⟩`. -/
def idC (r : ℕ) : LadderState Qc pendC := ⟨((1 : Qc), 0, r), fun _ => rfl⟩

/-- `X^k ψ`. -/
def nxtN : ℕ → PlusFormula → PlusFormula
  | 0, ψ => ψ
  | k + 1, ψ => .untl .bot (nxtN k ψ)

/-- `◇ ψ`, the dual of `⊡`. -/
def diaF (ψ : PlusFormula) : PlusFormula := PlusFormula.neg (.stab (PlusFormula.neg ψ))

/-- **THE STEP-FRAGMENT READER.** `◇ X^b ◇ Y ¬p`: some history through this state reaches, `b`
steps on, a state that some history enters directly from an idle state. -/
def sigC (b : ℕ) : PlusFormula :=
  diaF (nxtN b (diaF (.snce .bot (PlusFormula.neg (.atom pC)))))

theorem stepFrag_nxtN (ψ : PlusFormula) (h : StepFrag ψ) : ∀ k : ℕ, StepFrag (nxtN k ψ)
  | 0 => h
  | k + 1 => ⟨rfl, stepFrag_nxtN ψ h k⟩

theorem dBack_nxtN (ψ : PlusFormula) : ∀ k : ℕ, dBack (nxtN k ψ) = dBack ψ
  | 0 => rfl
  | k + 1 => by
    show max (dBack PlusFormula.bot) (dBack (nxtN k ψ)) = dBack ψ
    rw [dBack_nxtN ψ k]
    exact Nat.max_eq_right (Nat.zero_le _)

theorem dFwd_nxtN (ψ : PlusFormula) : ∀ k : ℕ, dFwd (nxtN k ψ) = dFwd ψ + k
  | 0 => rfl
  | k + 1 => by
    show max (dFwd PlusFormula.bot) (dFwd (nxtN k ψ)) + 1 = dFwd ψ + (k + 1)
    rw [dFwd_nxtN ψ k]
    have : max (dFwd PlusFormula.bot) (dFwd ψ + k) = dFwd ψ + k :=
      Nat.max_eq_right (Nat.zero_le _)
    omega

theorem stepFrag_diaF (ψ : PlusFormula) (h : StepFrag ψ) : StepFrag (diaF ψ) := by
  show (StepFrag ψ ∧ True) ∧ True
  exact ⟨⟨h, trivial⟩, trivial⟩

theorem stepFrag_sigC (b : ℕ) : StepFrag (sigC b) := by
  refine stepFrag_diaF _ (stepFrag_nxtN _ (stepFrag_diaF _ ?_) b)
  show PlusFormula.bot = PlusFormula.bot ∧ (True ∧ True)
  exact ⟨rfl, trivial, trivial⟩

theorem dBack_sigC (b : ℕ) : dBack (sigC b) = 1 := by
  show max (max (dBack (nxtN b _)) 0) 0 = 1
  rw [dBack_nxtN]
  rfl

theorem dFwd_sigC (b : ℕ) : dFwd (sigC b) = b := by
  show max (max (dFwd (nxtN b _)) 0) 0 = b
  rw [dFwd_nxtN]
  show max (max (0 + b) 0) 0 = b
  omega

theorem Bof_sigC (b : ℕ) (hb : 1 ≤ b) : Bof stepC pendC labC (sigC b) = 2 * b + 1 := by
  unfold Bof
  rw [dBack_sigC, dFwd_sigC]
  omega

theorem truth_diaF (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt MC τ t (diaF ψ) ↔
      ∃ σ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame,
        τ.state t = σ.state t ∧ PlusTruthAt MC σ t ψ := by
  show ((∀ σ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame,
    τ.state t = σ.state t → (PlusTruthAt MC σ t ψ → False)) → False) ↔ _
  constructor
  · intro h
    by_contra hn
    exact h (fun σ e hψ => hn ⟨σ, e, hψ⟩)
  · rintro ⟨σ, e, hψ⟩ h
    exact h σ e hψ

theorem truth_nxtN (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (ψ : PlusFormula) (k : ℕ) :
    ∀ t : ℤ, PlusTruthAt MC τ t (nxtN k ψ) ↔ PlusTruthAt MC τ (t + (k : ℤ)) ψ := by
  induction k with
  | zero => intro t; simp [nxtN]
  | succ k ih =>
    intro t
    rw [show nxtN (k + 1) ψ = .untl .bot (nxtN k ψ) from rfl, truth_nxt, ih]
    rw [show t + 1 + (k : ℤ) = t + ((k + 1 : ℕ) : ℤ) by push_cast; ring]

theorem truth_negp (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (s : ℤ) :
    PlusTruthAt MC τ s (PlusFormula.neg (.atom pC)) ↔ pendC (τ.state s).2.1.1 = false := by
  show (labC (τ.state s).2.1.1 pC = true → False) ↔ _
  rw [labC_pC]
  cases pendC (τ.state s).2.1.1 <;> simp

/-- A ladder path whose register RISES at each of `m` consecutive pending steps. -/
theorem exists_upRamp (C N : ℕ) : ∀ m : ℕ, m ≤ C → ∃ g : ℤ → LadderState Qc pendC,
    IsLadderPath stepC pendC g ∧ g 0 = stC C N ∧ g (m : ℤ) = stC (C - m) (N + m) := by
  intro m
  induction m with
  | zero =>
    intro _
    obtain ⟨g, hg, h0⟩ := exists_path_through fwdC bwdC (stC C N) 0
    exact ⟨g, hg, h0, by simpa using h0⟩
  | succ m ih =>
    intro hm
    obtain ⟨g, hg, h0, hgm⟩ := ih (by omega)
    obtain ⟨p, hp, hpt⟩ := exists_path_through fwdC bwdC (stC (C - (m + 1)) (N + (m + 1)))
      ((m : ℤ) + 1)
    refine ⟨glue g p (m : ℤ), glue_isPath g p hg hp _ ?_, ?_, ?_⟩
    · rw [hgm, hpt]
      refine ⟨rfl, admZeroC _ _, Or.inr (Or.inl rfl), ?_⟩
      show Count (pendC 0) (pendC 0) (C - m) (N + m) (C - (m + 1))
      have : C - (m + 1) + 1 = C - m := by omega
      simp [Count, pendC_zero, this]
    · rw [glue_of_le _ _ _ _ (by omega)]
      exact h0
    · rw [glue_of_gt _ _ _ _ (by push_cast; omega),
        show ((m + 1 : ℕ) : ℤ) = (m : ℤ) + 1 by push_cast; ring]
      exact hpt

/-- A ladder path entering the pending state `(c + 1, c)` at `z` directly from an idle state. -/
theorem exists_entry (c : ℕ) (z : ℤ) : ∃ g : ℤ → LadderState Qc pendC,
    IsLadderPath stepC pendC g ∧ g z = stC (c + 1) c ∧ g (z - 1) = idC (c + 1) := by
  obtain ⟨p₁, hp₁, h₁⟩ := exists_path_through fwdC bwdC (idC (c + 1)) (z - 1)
  obtain ⟨p₂, hp₂, h₂⟩ := exists_path_through fwdC bwdC (stC (c + 1) c) z
  refine ⟨glue p₁ p₂ (z - 1), glue_isPath p₁ p₂ hp₁ hp₂ _ ?_, ?_, ?_⟩
  · rw [h₁, show z - 1 + 1 = z by ring, h₂]
    refine ⟨rfl, fun _ => rfl, Or.inr (Or.inr rfl), ?_⟩
    show Count (pendC 1) (pendC 0) 0 (c + 1) (c + 1)
    simp [Count, pendC_zero, pendC_one]
  · rw [glue_of_gt _ _ _ _ (by omega)]
    exact h₂
  · rw [glue_of_le _ _ _ _ le_rfl]
    exact h₁

/-- **THE READER HOLDS AT GAP `-(2 b + 1)`.** -/
theorem sigC_mem (b n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (sigC b)
      ((0, stC (n + 2 * b + 1) n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    sigC b ∈ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
  obtain ⟨g₁, hg₁, h10, h1b⟩ := exists_upRamp (n + 2 * b + 1) n b (by omega)
  rw [show n + 2 * b + 1 - b = n + b + 1 by omega] at h1b
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdC bwdC g₁ hg₁
  obtain ⟨g₂, hg₂, h2b, h2p⟩ := exists_entry (n + b) (0 + (b : ℤ))
  obtain ⟨ρ, hρ⟩ := exists_hist_of_isLadderPath fwdC bwdC g₂ hg₂
  show PlusTruthAt MC τ 0 (diaF _)
  rw [truth_diaF]
  refine ⟨σ, by rw [hs, hσ 0, h10], ?_⟩
  rw [truth_nxtN, truth_diaF]
  refine ⟨ρ, by rw [hσ, hρ, h2b, zero_add, h1b], ?_⟩
  rw [truth_prv, truth_negp, hρ, h2p]
  exact pendC_one

/-- **THE READER FAILS AT EVERY GAP AT OR BELOW `-(2 b + 2)`.** -/
theorem sigC_not_mem (b c n : ℕ) (hgap : n + 2 * b + 2 ≤ c) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (sigC b)
      ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    sigC b ∉ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  rintro ⟨-, h⟩
  have h' : PlusTruthAt MC τ 0 (diaF (nxtN b (diaF (.snce .bot (PlusFormula.neg (.atom pC)))))) := h
  rw [truth_diaF] at h'
  obtain ⟨σ, e0, hσ⟩ := h'
  rw [truth_nxtN, truth_diaF] at hσ
  obtain ⟨ρ, eb, hρ⟩ := hσ
  rw [truth_prv, truth_negp] at hρ
  obtain ⟨k, g, hg, hp⟩ := exists_isLadderPath_of_hist fwdC bwdC σ
  obtain ⟨k', g', hg', hp'⟩ := exists_isLadderPath_of_hist fwdC bwdC ρ
  have h0 : ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) = (0 + k, g 0) :=
    hs.symm.trans (e0.trans (hp 0))
  have hg0 : g 0 = stC c n := (congrArg Prod.snd h0).symm
  have hb : ((0 + (b : ℤ) + k, g (0 + (b : ℤ))) :
      (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) = (0 + (b : ℤ) + k', g' (0 + (b : ℤ))) :=
    (hp _).symm.trans (eb.trans (hp' _))
  have hgb : g (0 + (b : ℤ)) = g' (0 + (b : ℤ)) := congrArg Prod.snd hb
  have hobj : pendC (objAt g 0) = true := by rw [objAt, hg0]; exact pendC_zero
  have hcnt : cntAt g 0 = c := by rw [cntAt, hg0]; rfl
  have hnxt : nxtAt g 0 = n := by rw [nxtAt, hg0]; rfl
  have hsub := cntAt_sub_of_pend g hg 0 hobj b (by omega)
  have hlip := nxtAt_lipschitz g hg 0 b
  rw [hp'] at hρ
  have hidle : pendC (objAt g' (0 + (b : ℤ) - 1)) = false := hρ
  have hpend' : pendC (objAt g' (0 + (b : ℤ) - 1 + 1)) = true := by
    rw [show (0 : ℤ) + (b : ℤ) - 1 + 1 = 0 + (b : ℤ) by ring, objAt, ← hgb]
    exact hsub.1
  have hpin := cntAt_eq_nxtAt_of_idle_pend g' hg' (0 + (b : ℤ) - 1) hidle hpend'
  have hlip' := nxtAt_lipschitz g' hg' (0 + (b : ℤ) - 1) 1
  rw [show (0 : ℤ) + (b : ℤ) - 1 + 1 = 0 + (b : ℤ) by ring] at hpin
  rw [show (0 : ℤ) + (b : ℤ) - 1 + ((1 : ℕ) : ℤ) = 0 + (b : ℤ) by push_cast; ring] at hlip'
  have e1 : cntAt g' (0 + (b : ℤ)) = cntAt g (0 + (b : ℤ)) := by rw [cntAt, cntAt, hgb]
  have e2 : nxtAt g' (0 + (b : ℤ)) = nxtAt g (0 + (b : ℤ)) := by rw [nxtAt, nxtAt, hgb]
  have hs2 := hsub.2
  omega

/-- **THE COLLISION AT THE CLIP `2 b + 1`.** -/
theorem kappa_collision_sig (b Tc Tn P : ℕ) :
    kappa Tc Tn P (2 * b + 1) (Tc + 2 * b + 1, Tc)
      = kappa Tc Tn P (2 * b + 1) (Tc + 2 * b + 1 + (P + 1), Tc) := by
  unfold kappa
  refine Prod.ext (Fin.ext ?_) (Prod.ext (Fin.ext ?_) (Prod.ext rfl (Prod.ext rfl (Fin.ext ?_))))
  · show min (Tc + 2 * b + 1) Tc = min (Tc + 2 * b + 1 + (P + 1)) Tc
    omega
  · show (Tc + 2 * b + 1) % (P + 1) = (Tc + 2 * b + 1 + (P + 1)) % (P + 1)
    rw [Nat.add_mod_right]
  · show clipIdx (2 * b + 1) (Tc + 2 * b + 1) Tc
      = clipIdx (2 * b + 1) (Tc + 2 * b + 1 + (P + 1)) Tc
    unfold clipIdx
    split_ifs <;> omega

theorem sigC_cell_ne (b n c' : ℕ) (hgap : n + 2 * b + 2 ≤ c') :
    cellAt MC (sigC b)
        ((0, stC (n + 2 * b + 1) n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      ≠ cellAt MC (sigC b)
          ((0, stC c' n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  intro heq
  obtain ⟨g, hg, h0⟩ := exists_path_through fwdC bwdC (stC (n + 2 * b + 1) n) 0
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC g hg
  have hT : tpOf MC (sigC b) τ 0 ∈ cellAt MC (sigC b)
      ((0, stC (n + 2 * b + 1) n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 :=
    (mem_cellAt_ladder_iff fwdC bwdC labC (sigC b) _ 0 _).mpr ⟨g, τ, hg, h0, hτ, rfl⟩
  exact sigC_not_mem b c' n hgap _ (heq ▸ hT) (sigC_mem b n _ hT)

/-- **THE FILED CLIP IS ONE SHORT ON THE STEP FRAGMENT, AT EVERY FORWARD DEPTH.** For every
`b ≥ 1` the step-fragment formula `sigC b` has `dBack = 1`, `dFwd = b`, so (K4)'s output for it is
`2 b + 1`; at the periodicity fixpoint's own parameters, which satisfy `ParamsOk`, two counter
pairs of one class have different cells. -/
theorem sigC_refutes (b : ℕ) (hb : 1 ≤ b) :
    ∃ (Tc Tn P B c n c' n' : ℕ), ParamsOk stepC pendC labC (sigC b) Tc Tn P B ∧
      B = 2 * b + 1 ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      cellAt MC (sigC b) ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (sigC b)
            ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  refine ⟨Tcof stepC pendC labC (sigC b), Tnof stepC pendC labC (sigC b),
    Pof stepC pendC labC (sigC b), Bof stepC pendC labC (sigC b),
    Tcof stepC pendC labC (sigC b) + 2 * b + 1, Tcof stepC pendC labC (sigC b),
    Tcof stepC pendC labC (sigC b) + 2 * b + 1 + (Pof stepC pendC labC (sigC b) + 1),
    Tcof stepC pendC labC (sigC b), paramsOk_params stepC pendC labC (sigC b),
    Bof_sigC b hb, ?_, ?_⟩
  · rw [Bof_sigC b hb]
    exact kappa_collision_sig b _ _ _
  · exact sigC_cell_ne b _ _ (by omega)

/-- **THE STEP FRAGMENT'S GAP-READING DEPTH IS EXACT.** For every `b ≥ 1`, at the reader
`sigC b` (`dBack = 1`, `dFwd = b`): the gap clip `2 b + 1` admits a collision with different
cells at every thresholds and modulus, and the gap clip `2 b + 2 = 2 dFwd + 2` admits none once
both thresholds reach `2 (dBack + dFwd)`. -/
theorem stepFrag_gap_depth_exact (b : ℕ) (hb : 1 ≤ b) :
    (StepFrag (sigC b) ∧ dBack (sigC b) = 1 ∧ dFwd (sigC b) = b) ∧
    (∀ Tc Tn P : ℕ, ∃ c n c' n' : ℕ,
      kappa Tc Tn P (2 * b + 1) (c, n) = kappa Tc Tn P (2 * b + 1) (c', n') ∧
      cellAt MC (sigC b) ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (sigC b)
            ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) ∧
    (∀ Tc Tn P B : ℕ, 2 * (1 + b) ≤ Tc → 2 * (1 + b) ≤ Tn → 2 * b + 2 ≤ B →
      ∀ c n c' n' : ℕ, kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      cellAt MC (sigC b) ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        = cellAt MC (sigC b)
            ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) := by
  refine ⟨⟨stepFrag_sigC b, dBack_sigC b, dFwd_sigC b⟩, fun Tc Tn P => ?_, ?_⟩
  · exact ⟨Tc + 2 * b + 1, Tc, Tc + 2 * b + 1 + (P + 1), Tc, kappa_collision_sig b Tc Tn P,
      sigC_cell_ne b _ _ (by omega)⟩
  · intro Tc Tn P B hTc hTn hB c n c' n' hk
    exact cellAt_const_of_kappa_eq_stepFrag fwdC bwdC labC (sigC b) (stepFrag_sigC b) Tc Tn P B
      (by rw [dBack_sigC, dFwd_sigC]; exact hTc) (by rw [dBack_sigC, dFwd_sigC]; exact hTn)
      (by rw [dBack_sigC]; omega) (by rw [dFwd_sigC]; exact hB)
      0 c n c' n' (admZeroC c n) (admZeroC c' n') hk 0

/-! ### The landed collisions at a larger clip -/

/-- A gap strictly inside the clip is read exactly: two counter pairs with different gaps, one of
them strictly inside `(-B, B)`, are never one class. -/
theorem not_kappa_collision_of_gap_inside (Tc Tn P B c n c' n' : ℕ)
    (hne : (n : ℤ) - c ≠ (n' : ℤ) - c')
    (hlo : -(B : ℤ) < (n : ℤ) - c) (hhi : (n : ℤ) - c < B) :
    kappa Tc Tn P B (c, n) ≠ kappa Tc Tn P B (c', n') := by
  intro hk
  have h5 := (kappa_eq_components Tc Tn P B c n c' n' hk).2.2.2.2
  unfold clipIdx at h5
  split_ifs at h5 <;> omega

/-- The collision that refutes the filed agreement at `thetaC` (gap `-3` against a gap at most
`-4`) is not a collision at any clip `B ≥ 4`. -/
theorem thetaC_pair_not_collision (Tc Tn P B : ℕ) (hB : 4 ≤ B) :
    kappa Tc Tn P B (Tc + 3, Tc) ≠ kappa Tc Tn P B (Tc + 3 + (P + 1), Tc) :=
  not_kappa_collision_of_gap_inside Tc Tn P B _ _ _ _ (by push_cast; omega) (by push_cast; omega)
    (by push_cast; omega)

/-- The collision that refutes the filed agreement at `mixC (k + 2) k` (gap `3 k + 4` against a
gap one modulus above it) is not a collision at any clip `B ≥ 3 k + 5`. -/
theorem mixC_pair_not_collision (Tc Tn P B k c : ℕ) (hB : 3 * k + 5 ≤ B) :
    kappa Tc Tn P B (c, c + (3 * k + 4)) ≠ kappa Tc Tn P B (c, c + (3 * k + 4) + (P + 1)) :=
  not_kappa_collision_of_gap_inside Tc Tn P B _ _ _ _ (by push_cast; omega) (by push_cast; omega)
    (by push_cast; omega)

#print axioms Probe761Z.thetaC_pair_not_collision
#print axioms Probe761Z.mixC_pair_not_collision
#print axioms Probe761Z.sigC_mem
#print axioms Probe761Z.sigC_not_mem
#print axioms Probe761Z.sigC_refutes
#print axioms Probe761Z.stepFrag_gap_depth_exact

end Probe761Z

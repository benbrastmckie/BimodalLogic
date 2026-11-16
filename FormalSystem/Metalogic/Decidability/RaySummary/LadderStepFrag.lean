/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize

/-!
# The step system: a back-and-forth on ladder states, and the cell agreement on the step fragment

The **step fragment** `StepFrag` admits every connective of the language, `⊡` and `□` included,
with `untl` and `snce` admitted only at the guard `⊥` — that is, as `X` and its mirror. On that
fragment this module lands a derived relation on ladder states, its one-step back-and-forth, the
path-level link the `⊡` clause needs, the truth lemma, and the agreement of cells as a corollary,
for an ARBITRARY finite object `(step, pend, lab)`.

## What is landed

* `Zrel a b` — a relation on ladder states indexed by a budget of `a` backward and `b` forward
  steps: same object state, countdowns equal or both `≥ 2 (a + b)`, registers equal or both
  `≥ 2 (a + b)`, gaps `n - c` equal, or both `≥ 2 a`, or both `≤ -(2 b + 2)`.
* `Zrel.succ`, `Zrel.pred` — the one-step back-and-forth, for every object `(step, pend)`.
* `exists_linked_path` — the path forth: a state related to the state a ladder path visits lies on
  a ladder path linked to it (`Lnk`) on the whole window. This is the `⊡` clause.
* `truth_iff_of_lnk` — the truth lemma on the step fragment, `⊡` and `□` included.
* `cellAt_eq_of_Zrel` — related states have the same cell.

Supporting declarations: `glue`, `glue_isPath`, `exists_path_through`, `Lnk`, `Lnk.succ`,
`Lnk.pred`, `StepFrag`, `frag_of_mem`, `truth_nxt`, `truth_prv`, `cellAt_subset_of_Zrel`.

## Two properties of the system, and one obligation it leaves owed

1. **The agreement follows from the truth lemma with no `ParamsOk` hypothesis.**
   `cellAt_eq_of_Zrel` consumes `truth_iff_of_lnk` and nothing from the parameter layer. The
   parameters enter only where a `kappa`-collision is turned into membership of `Zrel`, a bridge
   stated in the wired probe
   `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean` and not in this
   module. The parameter conditions are a BRIDGE from the counter-class invariant to the derived
   relation, not an input to the agreement itself.
2. **The thresholds are SOLUTIONS of one-step closure conditions, not choices.** Writing `G⁺`,
   `G⁻` for the upper and lower gap thresholds and `T`, `N` for the countdown and register
   thresholds at the budget `(a, b)`, the one-step lemmas need
   `G⁺(a, b) ≥ G⁺(a−1, b) + 2`, `G⁻(a, b) ≥ G⁻(a, b−1) + 2`, `T(a, b) ≥ N(a−1, b)`,
   `N(a, b) ≥ T(a, b−1)` and `N(a, b) − 1 ≥ G⁺(a−1, b)`, whose solution is `G⁺ = 2 a`,
   `G⁻ = 2 b + 2`, `T = N = 2 (a + b)`. The relation is indexed by TWO budgets deliberately: a
   single budget `a + b` gives a gap clip of `2 (dBack + dFwd)` but hides that the two arms
   differ — `2 * dBack` against `2 * dFwd + 2` — an asymmetry `paramsOkK4`'s clip
   `max (2 dBack + 1) (2 dFwd + 1) 2` does not carry.
3. **OWED, NOT DISCHARGED.** Wherever the system is instantiated at a formula, the thresholds
   `2 * (dBack φ + dFwd φ) ≤ Tc` and `2 * (dBack φ + dFwd φ) ≤ Tn` arrive as EXPLICIT HYPOTHESES.
   That they lie below `Tcof` and `Tnof` is plausible and is compiled nowhere; nothing in this
   module asserts it.

## The fragment boundary

Nothing here concerns a formula with an `untl` or `snce` at a guard other than `⊥`. The truth
lemma's window `Lnk` has width `a + b` and says nothing about a witness further away, which is
what an unbounded jump reads. The separating families `thetaC` and `mixC` each use one such jump
and are NOT covered, so nothing landed here weakens, qualifies or bears on
`cellAt_const_of_kappa_eq_schema_refuted` or `no_fibre_equation_over_kappa`. No agreement over
`kappa`-classes, no fibre equation, no soundness or lift statement and no certificate inclusion is
stated in this module; every quantity named is a count, and no complexity bound is claimed.
-/

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-! ### The derived state relation -/

section StateSys

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE DERIVED RELATION.** Two ladder states are related at the budget `(a, b)` — `a` backward
steps and `b` forward steps still to be read — when they carry the same object state, their
countdowns are equal or both at least `2 (a + b)`, their registers are equal or both at least
`2 (a + b)`, and their gaps `n - c` are equal, or both at least `2 a`, or both at most
`-(2 b + 2)`.  Every threshold is the solution of a one-step closure condition
(`Zrel.succ`, `Zrel.pred`); none is chosen. -/
def Zrel (a b : ℕ) (x y : LadderState Q pend) : Prop :=
  x.1.1 = y.1.1 ∧
  (x.1.2.1 = y.1.2.1 ∨ (2 * (a + b) ≤ x.1.2.1 ∧ 2 * (a + b) ≤ y.1.2.1)) ∧
  (x.1.2.2 = y.1.2.2 ∨ (2 * (a + b) ≤ x.1.2.2 ∧ 2 * (a + b) ≤ y.1.2.2)) ∧
  ((x.1.2.2 : ℤ) - x.1.2.1 = (y.1.2.2 : ℤ) - y.1.2.1 ∨
    (2 * (a : ℤ) ≤ (x.1.2.2 : ℤ) - x.1.2.1 ∧ 2 * (a : ℤ) ≤ (y.1.2.2 : ℤ) - y.1.2.1) ∨
    ((x.1.2.2 : ℤ) - x.1.2.1 ≤ -(2 * (b : ℤ) + 2) ∧
      (y.1.2.2 : ℤ) - y.1.2.1 ≤ -(2 * (b : ℤ) + 2)))

theorem Zrel.refl (a b : ℕ) (x : LadderState Q pend) : Zrel a b x x :=
  ⟨rfl, Or.inl rfl, Or.inl rfl, Or.inl rfl⟩

theorem Zrel.symm {a b : ℕ} {x y : LadderState Q pend} (h : Zrel a b x y) : Zrel a b y x := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨h1.symm, ?_, ?_, ?_⟩ <;> omega

theorem Zrel.mono {a b a' b' : ℕ} {x y : LadderState Q pend} (ha : a' ≤ a) (hb : b' ≤ b)
    (h : Zrel a b x y) : Zrel a' b' x y := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨h1, ?_, ?_, ?_⟩ <;> omega

/-- **ONE STEP FORWARD.** -/
theorem Zrel.succ {a b : ℕ} {x y x₁ : LadderState Q pend} {t : ℤ}
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
    · change Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · change Count (pend q) (pend q₁) c' n' 0
      simp [Count, hp, hp1]
    · change c₁ = 0 ∨ _
      exact Or.inl hc1
    · change n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · change (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ∨
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
    · change Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · change Count (pend q) (pend q₁) c' n' n'
      simp [Count, hp, hp1]
    · change c₁ = n' ∨ (2 * (a + b) ≤ c₁ ∧ 2 * (a + b) ≤ n')
      omega
    · change n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · change (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧ 2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending to idle: the countdown is exhausted
    have hc1 : c₁ = 0 ∧ c = 0 := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, 0, n' + n₁ - n), fun _ => rfl⟩, ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · change Count (pend q) (pend q₁) c' n' 0
      have : c' = 0 := by omega
      simp [Count, hp, hp1, this]
    · change c₁ = 0 ∨ _
      exact Or.inl hc1.1
    · change n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · change (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧ 2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending to pending: the countdown falls by one
    have hc1 : c₁ + 1 = c := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, c' - 1, n' + n₁ - n), fun h => by rw [hp1] at h; cases h⟩,
      ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · change Count (pend q) (pend q₁) c' n' (c' - 1)
      have : c' - 1 + 1 = c' := by omega
      simp [Count, hp, hp1, this]
    · change c₁ = c' - 1 ∨ (2 * (a + b) ≤ c₁ ∧ 2 * (a + b) ≤ c' - 1)
      omega
    · change n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · change (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧
          2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ) ≤ -(2 * (b : ℤ) + 2))
      omega

/-- **ONE STEP BACKWARD.** -/
theorem Zrel.pred {a b : ℕ} {x y x₀ : LadderState Q pend} {t : ℤ}
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
    · change Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · change Count (pend q₀) (pend q) 0 (n' + n₀ - n) c'
      simp [Count, hp0, hp, h0']
    · change c₀ = 0 ∨ _
      exact Or.inl hc0
    · change n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · change (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧ 2 * (a : ℤ) ≤ ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- idle before pending: a region entry, which pins the gap inside `[-1, 1]`
    have hc0 : c₀ = 0 := hsrc hp0
    have hcn : c = n₀ := by simpa [Count, hp0, hp] using hcnt
    refine ⟨⟨(q₀, 0, c'), fun _ => rfl⟩, ⟨hst, fun _ => rfl, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift c' n'
      unfold Drift; omega
    · change Count (pend q₀) (pend q) 0 c' c'
      simp [Count, hp0, hp]
    · change c₀ = 0 ∨ _
      exact Or.inl hc0
    · change n₀ = c' ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ c')
      omega
    · change (n₀ : ℤ) - c₀ = (c' : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧ 2 * (a : ℤ) ≤ (c' : ℤ) - (0 : ℕ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧ (c' : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending before idle: the last pending position
    have h0' : c' = 0 := hy' hp
    have hcc : c = 0 ∧ c₀ = 0 := by simpa [Count, hp0, hp] using hcnt
    refine ⟨⟨(q₀, 0, n' + n₀ - n), fun _ => rfl⟩, ⟨hst, fun _ => rfl, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · change Count (pend q₀) (pend q) 0 (n' + n₀ - n) c'
      simp [Count, hp0, hp, h0']
    · change c₀ = 0 ∨ _
      exact Or.inl hcc.2
    · change n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · change (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ∨
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
    · change Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · change Count (pend q₀) (pend q) (c' + 1) (n' + n₀ - n) c'
      simp [Count, hp0, hp]
    · change c₀ = c' + 1 ∨ (2 * (a + b) ≤ c₀ ∧ 2 * (a + b) ≤ c' + 1)
      omega
    · change n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · change (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - ((c' + 1 : ℕ) : ℤ) ∨
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
  · change (if z ≤ z then F^[(z - z).toNat] x else G^[(z - z).toNat] x) = x
    rw [if_pos le_rfl, show (z - z).toNat = 0 by omega]
    rfl

/-- **THE WINDOW LINK.** Two paths are linked at `t` with budget `(a, b)` when their states at
`t + i` are related, for `-a ≤ i ≤ b`, at the budget left after `|i|` steps in the direction of
`i`. -/
def Lnk (a b : ℕ) (g g' : ℤ → LadderState Q pend) (t : ℤ) : Prop :=
  ∀ i : ℤ, -(a : ℤ) ≤ i → i ≤ (b : ℤ) →
    Zrel (a - (-i).toNat) (b - i.toNat) (g (t + i)) (g' (t + i))

theorem Lnk.symm {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a b g g' t) :
    Lnk a b g' g t :=
  fun i h1 h2 => Zrel.symm (h i h1 h2)

theorem Lnk.mono {a b a' b' : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ}
    (ha : a' ≤ a) (hb : b' ≤ b) (h : Lnk a b g g' t) : Lnk a' b' g g' t :=
  fun i h1 h2 => Zrel.mono (by omega) (by omega) (h i (by omega) (by omega))

theorem Lnk.zero {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a b g g' t) :
    Zrel a b (g t) (g' t) := by
  have := h 0 (by omega) (by omega)
  simpa using this

theorem Lnk.succ {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a (b + 1) g g' t) :
    Lnk a b g g' (t + 1) := by
  intro i h1 h2
  have := h (i + 1) (by omega) (by push_cast; omega)
  rw [show t + (i + 1) = t + 1 + i by ring] at this
  exact Zrel.mono (by omega) (by omega) this

theorem Lnk.pred {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk (a + 1) b g g' t) :
    Lnk a b g g' (t - 1) := by
  intro i h1 h2
  have := h (i - 1) (by push_cast; omega) (by omega)
  rw [show t + (i - 1) = t - 1 + i by ring] at this
  exact Zrel.mono (by omega) (by omega) this

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
      obtain ⟨y₁, hy₁, hZ₁⟩ := Zrel.succ hr (hh (t + (j : ℤ)))
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
      obtain ⟨y₀, hy₀, hZ₀⟩ := Zrel.pred hr hstep
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
    change lab (τ.state t).2.1.1 p = true ↔ lab (τ'.state t).2.1.1 p = true
    rw [hτ t, hτ' t]
    change lab (g t).1.1 p = true ↔ lab (g' t).1.1 p = true
    rw [(Lnk.zero hl).1]
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
      apply Lnk.succ
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
      apply Lnk.pred
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
        exact Zrel.symm (Lnk.zero hl)
      obtain ⟨gσ, hgσ, hgσt, hlσ⟩ := exists_linked_path fwd bwd a b gσ' hgσ' t (g t) hz
      obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath_at_offset fwd bwd k gσ hgσ
      have hσt : τ.state t = σ.state t := by rw [hτ t, hσ t, hgσt]
      exact (iha hf a b hda hdb σ σ' k kσ' gσ gσ' t hgσ hgσ' hσ hpσ' (Lnk.symm hlσ)).mp
        (h σ hσt)
    exact ⟨key τ τ' k k' g g' hτ hτ' hl, key τ' τ k' k g' g hτ' hτ (Lnk.symm hl)⟩

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
`Zrel.succ` and `Zrel.pred`. -/
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
    (cellAt_subset_of_Zrel fwd bwd lab φ hφ y x (Zrel.symm hZ) z)

end Truth

end FormalSystem.Metalogic.Decidability.RaySummary

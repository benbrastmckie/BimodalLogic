/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

/-!
# Retired `LimitMCSCoherence.lean` cases

Five theorems retired from `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` during the
`TemporalSide` parameterization of `Bundle/LimitMCS.lean` (see that module's "Temporal Duality
Discipline" note in `Bundle/README.md`). Re-verified dead at retirement time: each was
referenced only by its own declaration and by module-docstring prose, with zero live consumers
repository-wide (Boneyard excluded).

This snippet is **guard-first**, like the live tree at retirement time -- unlike most of
`Boneyard/`, which predates the guard-first migration and is event-first (see the archive
root README). No argument swap is needed if resurrecting these.

Not part of any `lean_lib` root; not compiled; not imported by any live module.
-/

#exit

theorem limitSetBelow_forward_G_rat_target (m : Rat → Set Formula)
    (hG : ∀ (s t : Rat) (φ : Formula), s < t → Formula.allFuture φ ∈ m s → φ ∈ m t)
    (s : ℝ) (p : Rat) (φ : Formula) (hsp : s < (p : ℝ))
    (hφ : Formula.allFuture φ ∈ limitSetBelow m s) :
    φ ∈ m p := by
  rw [mem_limitSetBelow] at hφ
  obtain ⟨z, hz, hmem⟩ := hφ
  have hq : ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < s := exists_rat_btwn hz
  obtain ⟨q, hq1, hq2⟩ := hq
  have hqp : q < p := by
    have : (q : ℝ) < (p : ℝ) := lt_trans hq2 hsp
    exact_mod_cast this
  exact hG q p φ hqp (hmem q hq1 hq2)

theorem limitSetBelow_forward_G_limit (m : Rat → Set Formula)
    (hG : ∀ (s t : Rat) (φ : Formula), s < t → Formula.allFuture φ ∈ m s → φ ∈ m t)
    (s t : ℝ) (φ : Formula) (hst : s < t)
    (hφ : Formula.allFuture φ ∈ limitSetBelow m s) :
    φ ∈ limitSetBelow m t := by
  rw [mem_limitSetBelow] at hφ ⊢
  obtain ⟨z, hz, hmem⟩ := hφ
  have hq₀ : ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < s := exists_rat_btwn hz
  obtain ⟨q₀, hq₀1, hq₀2⟩ := hq₀
  have hq₀t : (q₀ : ℝ) < t := lt_trans hq₀2 hst
  have hq₀mem : Formula.allFuture φ ∈ m q₀ := hmem q₀ hq₀1 hq₀2
  refine ⟨(q₀ : ℝ), hq₀t, ?_⟩
  intro p hp1 _
  have hq₀p : q₀ < p := by exact_mod_cast hp1
  exact hG q₀ p φ hq₀p hq₀mem

theorem limitSetBelow_of_rat_of_backward_H_rat_source (m : Rat → Set Formula)
    (hH : ∀ (s t : Rat) (φ : Formula), t < s → Formula.allPast φ ∈ m s → φ ∈ m t)
    (q : Rat) (φ : Formula) (hφ : Formula.allPast φ ∈ m q) :
    φ ∈ limitSetBelow m (q : ℝ) :=
  limitSetBelow_backward_H_rat_source m hH q (q : ℝ) φ le_rfl hφ

theorem limitSetBelow_backward_H_rat_target (m : Rat → Set Formula)
    (hH : ∀ (s t : Rat) (φ : Formula), t < s → Formula.allPast φ ∈ m s → φ ∈ m t)
    (s : ℝ) (p : Rat) (φ : Formula) (hps : (p : ℝ) < s)
    (hφ : Formula.allPast φ ∈ limitSetBelow m s) :
    φ ∈ m p := by
  rw [mem_limitSetBelow] at hφ
  obtain ⟨z, hz, hmem⟩ := hφ
  have hmax : max z (p : ℝ) < s := max_lt hz hps
  have hq : ∃ q : Rat, max z (p : ℝ) < (q : ℝ) ∧ (q : ℝ) < s := exists_rat_btwn hmax
  obtain ⟨q, hq1, hq2⟩ := hq
  have hzq : z < (q : ℝ) := lt_of_le_of_lt (le_max_left _ _) hq1
  have hpq : p < q := by
    have : (p : ℝ) < (q : ℝ) := lt_of_le_of_lt (le_max_right _ _) hq1
    exact_mod_cast this
  exact hH q p φ hpq (hmem q hzq hq2)

theorem limitSetBelow_backward_H_limit (m : Rat → Set Formula)
    (hH : ∀ (s t : Rat) (φ : Formula), t < s → Formula.allPast φ ∈ m s → φ ∈ m t)
    (s t : ℝ) (φ : Formula) (hts : t < s)
    (hφ : Formula.allPast φ ∈ limitSetBelow m s) :
    φ ∈ limitSetBelow m t := by
  rw [mem_limitSetBelow] at hφ ⊢
  obtain ⟨z, hz, hmem⟩ := hφ
  have hmax : max z t < s := max_lt hz hts
  have hq₀ : ∃ q : Rat, max z t < (q : ℝ) ∧ (q : ℝ) < s := exists_rat_btwn hmax
  obtain ⟨q₀, hq₀1, hq₀2⟩ := hq₀
  have hzq₀ : z < (q₀ : ℝ) := lt_of_le_of_lt (le_max_left _ _) hq₀1
  have htq₀ : t < (q₀ : ℝ) := lt_of_le_of_lt (le_max_right _ _) hq₀1
  have hq₀mem : Formula.allPast φ ∈ m q₀ := hmem q₀ hzq₀ hq₀2
  refine ⟨t - 1, by linarith, ?_⟩
  intro p _ hp2
  have hpq₀ : p < q₀ := by
    have : (p : ℝ) < (q₀ : ℝ) := lt_trans hp2 htq₀
    exact_mod_cast this
  exact hH q₀ p φ hpq₀ hq₀mem

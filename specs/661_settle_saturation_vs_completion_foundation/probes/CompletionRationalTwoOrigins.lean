/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/
import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Data.Rat.Lemmas
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import FormalSystem.Semantics.StateTopology.ConstraintWitnesses

/-!
# Probe: the ℚ-carrier two-origin relation also FAILS *Completion*

The primary probe of the Saturation-vs-Completion task. `RationalTwoOrigins.rel` satisfies
*Seriality*, *Compositionality* and *Limit* and fails *Saturation*
(`ConstraintWitnesses.RationalTwoOrigins.not_rel_saturation`). This file shows it **also** fails
*Completion*, in the bare-relation `CoherentCompletion` shape: the rational carrier is therefore
**not** a separating frame, and `Completion → Saturation` stays open.

The witness is a coherent family indexed by the times `tm n = -(1/2)^n`, which accumulate at
`z = 0` from below, carrying the ray states at positions `phi n = nt n - (1/2)^n` where `nt` is
the Newton iteration for `√2` started at `3/2`. Coherence is exactly "position nondecreasing and
1-Lipschitz", which holds because `nt` decreases more slowly than the times approach `0`. At
`z = 0` the two bounds pinch: any witness `p v` needs `nt n - (1/2)^n ≤ v ≤ nt n` for every `n`,
which forces `v² = 2`.
-/

open Set

namespace FormalSystem.Semantics.StateTopology
namespace RationalTwoOrigins

open FormalSystem.Semantics TQ

/-! ## *Completion* over a bare relation

`PartialHistory.CoherentCompletion` (`Semantics/Extension/Completion.lean`) transcribed with
`F.TaskRel` replaced by a bare relation, since `rel` carries no `FrameOver` wrapper.
-/

/-- `PartialHistory.CoherentCompletion`, over a bare task relation. -/
def CoherentCompletionRel {W D : Type} [AddCommGroup D] (R : W → D → W → Prop) : Prop :=
  ∀ (X : D → Prop), (∃ t, X t) →
    ∀ (w : (t : D) → X t → W),
      (∀ (s t : D) (hs : X s) (ht : X t), R (w s hs) (t - s) (w t ht)) →
      ∀ z : D, ∃ u : W, ∀ (t : D) (ht : X t), R (w t ht) (z - t) u

/-! ## The Newton iteration for `√2` from above -/

/-- Newton iterates for `√2`, started at `3/2`: `nt (n+1) = (nt n ^ 2 + 2) / (2 * nt n)`. -/
def nt : ℕ → ℚ
  | 0 => 3 / 2
  | n + 1 => (nt n ^ 2 + 2) / (2 * nt n)

theorem nt_succ (n : ℕ) : nt (n + 1) = (nt n ^ 2 + 2) / (2 * nt n) := rfl

/-- The three invariants of the iteration: it stays at least `1`, stays strictly above the cut,
and its distance to the cut halves at least once per step from `(1/2)^2` down. -/
theorem nt_inv (n : ℕ) : 1 ≤ nt n ∧ 2 < nt n ^ 2 ∧ nt n ^ 2 - 2 ≤ (1 / 2 : ℚ) ^ (n + 2) := by
  induction n with
  | zero => refine ⟨by norm_num [nt], by norm_num [nt], by norm_num [nt]⟩
  | succ n ih =>
    obtain ⟨h1, h2, h3⟩ := ih
    have hx0 : (0 : ℚ) < nt n := by linarith
    have hone : 1 ≤ nt (n + 1) := by
      rw [nt_succ, le_div_iff₀ (by positivity)]
      nlinarith [sq_nonneg (nt n - 1)]
    have hsq : nt (n + 1) ^ 2 - 2 = (nt n ^ 2 - 2) ^ 2 / (4 * nt n ^ 2) := by
      rw [nt_succ]; field_simp; ring
    have hden : (0 : ℚ) < 4 * nt n ^ 2 := by positivity
    have hgt : 2 < nt (n + 1) ^ 2 := by
      have : 0 < nt (n + 1) ^ 2 - 2 := by
        rw [hsq]; exact div_pos (by nlinarith) hden
      linarith
    refine ⟨hone, hgt, ?_⟩
    -- `e ≤ a ≤ 1/4` and `4 * nt n ^ 2 > 8` give `e² / (4 nt n²) ≤ a² / 8 ≤ a / 32 ≤ a / 2`.
    have ha : (1 / 2 : ℚ) ^ (n + 2) ≤ 1 / 4 := by
      calc (1 / 2 : ℚ) ^ (n + 2) ≤ (1 / 2 : ℚ) ^ 2 :=
            pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
        _ = 1 / 4 := by norm_num
    have hapos : (0 : ℚ) < (1 / 2 : ℚ) ^ (n + 2) := by positivity
    have hsucc_pow : (1 / 2 : ℚ) ^ (n + 1 + 2) = (1 / 2 : ℚ) ^ (n + 2) / 2 := by
      rw [pow_succ]; ring
    rw [hsq, hsucc_pow, div_le_div_iff₀ hden (by norm_num)]
    nlinarith [sq_nonneg (nt n ^ 2 - 2), sq_nonneg (nt n)]

theorem nt_one_le (n : ℕ) : 1 ≤ nt n := (nt_inv n).1
theorem nt_sq_gt (n : ℕ) : 2 < nt n ^ 2 := (nt_inv n).2.1
theorem nt_err (n : ℕ) : nt n ^ 2 - 2 ≤ (1 / 2 : ℚ) ^ (n + 2) := (nt_inv n).2.2

theorem nt_succ_le (n : ℕ) : nt (n + 1) ≤ nt n := by
  have h1 := nt_one_le n
  have h2 := nt_sq_gt n
  rw [nt_succ, div_le_iff₀ (by linarith)]
  nlinarith

theorem nt_antitone : Antitone nt := antitone_nat_of_succ_le nt_succ_le

theorem nt_le_start (n : ℕ) : nt n ≤ 3 / 2 := by
  have := nt_antitone (Nat.zero_le n)
  simpa [nt] using this

/-- The step of the iteration is at most `(1/2)^(n+1)` — slower than the times converge. -/
theorem nt_step (n : ℕ) : nt n - nt (n + 1) ≤ (1 / 2 : ℚ) ^ (n + 1) := by
  have h1 := nt_one_le n
  have h2 := nt_sq_gt n
  have h3 := nt_err n
  have hstep : nt n - nt (n + 1) = (nt n ^ 2 - 2) / (2 * nt n) := by
    rw [nt_succ]; field_simp; ring
  have hle : (nt n ^ 2 - 2) / (2 * nt n) ≤ (nt n ^ 2 - 2) / 2 := by
    apply div_le_div_of_nonneg_left (by linarith) (by norm_num) (by linarith)
  have hpow : (1 / 2 : ℚ) ^ (n + 2) = (1 / 2 : ℚ) ^ (n + 1) / 2 := by rw [pow_succ]; ring
  rw [hstep]
  have hpos : (0 : ℚ) < (1 / 2 : ℚ) ^ (n + 1) := by positivity
  linarith [hle, h3, hpow]

/-! ## The coherent family -/

/-- The times: `-(1/2)^n`, accumulating at `0` from below. -/
def tm (n : ℕ) : ℚ := -(1 / 2 : ℚ) ^ n

/-- The positions: `nt n - (1/2)^n`, increasing to the cut. -/
def phi (n : ℕ) : ℚ := nt n - (1 / 2 : ℚ) ^ n

theorem phi_le_succ (n : ℕ) : phi n ≤ phi (n + 1) := by
  have h := nt_step n
  have hpow : (1 / 2 : ℚ) ^ n = (1 / 2 : ℚ) ^ (n + 1) * 2 := by rw [pow_succ]; ring
  simp only [phi]
  linarith [hpow]

theorem phi_mono : Monotone phi := monotone_nat_of_le_succ phi_le_succ

theorem phi_pos (n : ℕ) : 0 < phi n := by
  have := phi_mono (Nat.zero_le n)
  have h0 : phi 0 = 1 / 2 := by norm_num [phi, nt]
  linarith [h0, this]

/-- The times are pairwise distinct: `(1/2)^m = (1/2)^n` only at `m = n`. -/
theorem pow_half_inj {m n : ℕ} (h : (1 / 2 : ℚ) ^ m = (1 / 2 : ℚ) ^ n) : m = n := by
  by_contra hne
  rcases Nat.lt_or_ge m n with hlt | hge
  · have := pow_lt_pow_right_of_lt_one₀ (show (0 : ℚ) < 1 / 2 by norm_num)
      (show (1 / 2 : ℚ) < 1 by norm_num) hlt
    linarith
  · have hlt : n < m := lt_of_le_of_ne hge (fun hEq => hne hEq.symm)
    have := pow_lt_pow_right_of_lt_one₀ (show (0 : ℚ) < 1 / 2 by norm_num)
      (show (1 / 2 : ℚ) < 1 by norm_num) hlt
    linarith

/-- Coherence: the family is nondecreasing in position and 1-Lipschitz in time. -/
theorem key (m n : ℕ) :
    rel (p ⟨phi m, phi_pos m⟩) (tm n - tm m) (p ⟨phi n, phi_pos n⟩) := by
  rcases lt_trichotomy m n with h | h | h
  · have hp : (1 / 2 : ℚ) ^ n < (1 / 2 : ℚ) ^ m :=
      pow_lt_pow_right_of_lt_one₀ (by norm_num) (by norm_num) h
    have hnt : nt n ≤ nt m := nt_antitone h.le
    have hph : phi m ≤ phi n := phi_mono h.le
    refine Or.inl ⟨by simp only [tm]; linarith, hph, ?_⟩
    simp only [tm, phi]
    linarith
  · subst h
    exact Or.inl ⟨by simp, le_rfl, by simp⟩
  · have hp : (1 / 2 : ℚ) ^ m < (1 / 2 : ℚ) ^ n :=
      pow_lt_pow_right_of_lt_one₀ (by norm_num) (by norm_num) h
    have hnt : nt m ≤ nt n := nt_antitone h.le
    have hph : phi n ≤ phi m := phi_mono h.le
    refine Or.inr ⟨by simp only [tm]; linarith, hph, ?_⟩
    simp only [tm, phi]
    linarith

/-! ## *Completion* fails -/

/-- The state carried at a time of the family: the ray point at the position indexed by any
witness that the time is one of the `tm n`. -/
noncomputable def stateAt (t : ℚ) (ht : ∃ n : ℕ, t = tm n) : TQ :=
  p ⟨phi (Classical.choose ht), phi_pos _⟩

/--
**The ℚ-carrier two-origin relation FAILS *Completion*.**

The family `{p (phi n)}` at the times `tm n = -(1/2)^n` is coherent, and at `z = 0` its fibre
intersection is empty: a witness `p v` would need `nt n - (1/2)^n ≤ v ≤ nt n` for every `n`, and
the two sides pinch onto the Dedekind cut, so `v² = 2` — impossible over `ℚ` (`sq_ne_two`).

So the rational carrier is **not** a frame separating *Completion* from *Saturation*: it fails
both. The converse `Completion → Saturation` remains open.
-/
theorem not_rel_coherentCompletion : ¬ CoherentCompletionRel rel := by
  intro hcc
  classical
  have hXne : ∃ t : ℚ, ∃ n : ℕ, t = tm n := ⟨tm 0, 0, rfl⟩
  have hcoh : ∀ (s t : ℚ) (hs : ∃ n : ℕ, s = tm n) (ht : ∃ n : ℕ, t = tm n),
      rel (stateAt s hs) (t - s) (stateAt t ht) := by
    intro s t hs ht
    have hs' : s = tm (Classical.choose hs) := Classical.choose_spec hs
    have ht' : t = tm (Classical.choose ht) := Classical.choose_spec ht
    have hk := key (Classical.choose hs) (Classical.choose ht)
    rw [← hs', ← ht'] at hk
    exact hk
  obtain ⟨u, hu⟩ := hcc (fun t => ∃ n : ℕ, t = tm n) hXne stateAt hcoh 0
  -- The membership proofs, named once so their chosen indices are the same term throughout.
  have hmem : ∀ n : ℕ, ∃ k : ℕ, tm n = tm k := fun n => ⟨n, rfl⟩
  have hpow : ∀ n : ℕ, (1 / 2 : ℚ) ^ (Classical.choose (hmem n)) = (1 / 2 : ℚ) ^ n := by
    intro n
    have h : -((1 / 2 : ℚ) ^ n) = -((1 / 2 : ℚ) ^ (Classical.choose (hmem n))) :=
      Classical.choose_spec (hmem n)
    exact (neg_inj.mp h).symm
  have hall : ∀ n : ℕ,
      rel (p ⟨phi (Classical.choose (hmem n)), phi_pos _⟩) ((1 / 2 : ℚ) ^ n) u := by
    intro n
    have h := hu (tm n) (hmem n)
    rw [show (0 : ℚ) - tm n = (1 / 2 : ℚ) ^ n by simp [tm]] at h
    exact h
  cases u with
  | o b =>
    have h := hall 0
    rw [pow_zero] at h
    have h' : phi (Classical.choose (hmem 0)) ≤ -(1 : ℚ) := h
    have := phi_pos (Classical.choose (hmem 0))
    linarith
  | p v =>
    have hv0 : (0 : ℚ) < v.1 := v.2
    -- At every `n`: `nt m - (1/2)^n ≤ v ≤ nt m`, where `m` is the chosen index at `tm n`.
    have hband : ∀ n : ℕ, ∃ m : ℕ, (1 / 2 : ℚ) ^ m = (1 / 2 : ℚ) ^ n ∧
        nt m - (1 / 2 : ℚ) ^ n ≤ v.1 ∧ v.1 ≤ nt m := by
      intro n
      have h := hall n
      have hpos : (0 : ℚ) < (1 / 2 : ℚ) ^ n := by positivity
      refine ⟨Classical.choose (hmem n), hpow n, ?_, ?_⟩
      · rcases h with ⟨-, h2, -⟩ | ⟨h1, -, -⟩
        · simp only [phi] at h2; rw [hpow n] at h2; linarith
        · linarith
      · rcases h with ⟨-, -, h3⟩ | ⟨h1, -, -⟩
        · simp only [phi] at h3; rw [hpow n] at h3; linarith
        · linarith
    rcases lt_trichotomy (v.1 ^ 2) 2 with hlt | heq | hgt
    · -- below the cut: some `nt m - (1/2)^n` overtakes `v`
      have hδpos : 0 < (2 - v.1 ^ 2) / (3 / 2 + v.1) := div_pos (by linarith) (by linarith)
      obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one hδpos (show (1 / 2 : ℚ) < 1 by norm_num)
      obtain ⟨m, -, hlow, -⟩ := hband n
      have hm1 := nt_one_le m
      have hmsq := nt_sq_gt m
      have hmle := nt_le_start m
      have hgap : (2 - v.1 ^ 2) / (3 / 2 + v.1) ≤ nt m - v.1 := by
        rw [div_le_iff₀ (by linarith)]
        nlinarith
      linarith
    · exact sq_ne_two v.1 heq
    · -- above the cut: the upper bound `nt m` drops below `v`
      obtain ⟨n, hn⟩ :=
        exists_pow_lt_of_lt_one (show (0 : ℚ) < v.1 ^ 2 - 2 by linarith)
          (show (1 / 2 : ℚ) < 1 by norm_num)
      obtain ⟨m, hpm, -, hhigh⟩ := hband (n + 2)
      have herr := nt_err m
      have hm1 := nt_one_le m
      have hsmall : (1 / 2 : ℚ) ^ (m + 2) ≤ (1 / 2 : ℚ) ^ n := by
        have h2 : (1 / 2 : ℚ) ^ (m + 2) = (1 / 2 : ℚ) ^ m * (1 / 2 : ℚ) ^ 2 := by ring
        have h3 : (1 / 2 : ℚ) ^ (n + 2) = (1 / 2 : ℚ) ^ n * (1 / 2 : ℚ) ^ 2 := by ring
        have hpn : (0 : ℚ) < (1 / 2 : ℚ) ^ n := by positivity
        rw [h2]
        rw [h3] at hpm
        nlinarith [hpm]
      nlinarith [hhigh, herr, hsmall, hn]

end RationalTwoOrigins
end FormalSystem.Semantics.StateTopology

section AxiomCheck
#print axioms FormalSystem.Semantics.StateTopology.RationalTwoOrigins.not_rel_coherentCompletion
end AxiomCheck

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

/-!
# The cell level: inclusions between cells at colliding counter states

## Contract

This module holds ONE argument: inclusions between the cells of the ladder model at two counter
states whose classes under `kappa` COLLIDE, and the arithmetic case split that says which
sub-regimes such a collision can occupy. It imports `LadderChain.lean` alone and says nothing
about pumps or pins beyond what that module already landed — every construction here is a
reading of the landed regime-A assembly `exists_ladderPath_through_shifted_of_pend_past` with
the register's anchor moved, or of the landed class destructors `kappa_eq_components`,
`eq_or_both_ge_of_min_eq` and `clipIdx_regime_of_eq`.

The layer has two halves.

The COMMON-SHIFT INCLUSION. `LadderChain.lean`'s `cellAt_subset_of_shift_of_pend_past` covers
the sub-regime in which the register is held (`n' = n`) and the countdown rises by a multiple of
`P + 1`; its docstring names the common shift `n' = n + m · (P + 1)` and does not state it.
`cellAt_subset_of_common_shift_of_pend_past` states it. The construction is the landed one with
the register rebuilt at the freed anchor `exists_ladderPath_of_walk_nxt_at` and the anchor value
`n₀ := nxtAt g z + m · (P + 1)` in place of `nxtAt g z`: the raise widens `z`'s own region by
exactly `m · (P + 1)`, so every pin of the raised path sits at least `cntAt g z + m · (P + 1) + 1`
beyond `z`, while the pending-forever gap `n + 2 ≤ c` bounds the register at `z` by
`cntAt g z - 2`. The pin bound therefore has `m · (P + 1)` more room than it needs, and the
anchor clause closes from the widened window alone. ONE direction only: no downward inclusion is
claimed here either, and the reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing
in this module.

The COLLISION CASE SPLIT. `kappa_collision_regimes` reads a collision
`kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')` as a disjunction over named ARITHMETIC
facts — not over cells — so that a cell-level consumer may dispatch on it. It has THREE branches,
not two: the equal-register branch `n = n'` with the countdowns congruent mod `P + 1`, the
common-shift branch with both coordinates displaced by the SAME multiple of `P + 1`, and a
residual branch in which the gap coordinate is SATURATED at both pairs (`B ≤ |n - c|` and
`B ≤ |n' - c'|`, on the same side of the window). The two-branch form — the first two
alternatives alone — is NOT a consequence of the three destructors together with `(K4)`'s
`2 ≤ B`: `kappa_collision_two_regimes_refuted` below is the compiled refutation, at
`Tc = Tn = P = 0`, `B = 2` and the pairs `(0, 2)`, `(0, 3)`. The refutation is scoped to that
derivation and says nothing about the two-branch form under full `ParamsOk`, whose `(K1)`, `(K2)`
and `(K4)` quantify the formula and are not read here. The saturated branch is the honest
residue: neither landed inclusion addresses it.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The common-shift sub-regime -/

section CommonShift

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE REGIME-A ASSEMBLY WITH THE REGISTER CARRIED ALONG THE SHIFT.** The landed
`exists_ladderPath_through_shifted_of_pend_past` raises `z`'s countdown by exactly `m · (P + 1)`
and HOLDS the register; this raises both by exactly `m · (P + 1)`. The walk and every countdown
are the landed path's, unchanged: only the deadline register is rebuilt, by the freed-anchor lift
`exists_ladderPath_of_walk_nxt_at` at `z` with the anchor value `nxtAt g z + m · (P + 1)`.

Why the anchor clause closes. Every pin of the raised path — an idle position `v` immediately
followed by a pending one — lies at least `cntAt g z + m · (P + 1) + 1` beyond `z`: the past of
`z` is uniformly pending (`pend_past_of_nxtAt_lt`, from the gap `hgap`) and the raised region
through `z` is rigid (`cntAt_sub_of_pend`), so no idle position occurs at or below
`z + cntAt g z + m · (P + 1)`. The register's own two-sided Lipschitz bound
(`nxtAt_lipschitz_two_sided`) bounds the pin's value against the value at `z` by that same
distance, and `hgap` bounds the value at `z` itself by `cntAt g z - 2`. Both directions of the
anchor clause therefore hold with `m · (P + 1)` to spare; this is the slack the common shift
spends, and it is the reason the common shift needs no new pump. -/
theorem exists_ladderPath_through_common_shifted_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hgap : nxtAt g z + 2 ≤ cntAt g z) (hTc : Tc ≤ cntAt g z) (m : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = nxtAt g z + m * (P + 1) ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  -- the landed raise, with the register held
  obtain ⟨g₁, hg₁, hobj₁, hcnt₁, hnxt₁, hty₁⟩ :=
    exists_ladderPath_through_shifted_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno g hg z
      hpast hTc m
  have hz₁ : pend (objAt g₁ z) = true := by rw [hobj₁]; exact hpast z le_rfl
  -- the raised path is pending forever into its own past, and its region through `z` is rigid
  have hpast₁ : ∀ p : ℤ, p ≤ z → pend (objAt g₁ p) = true :=
    pend_past_of_nxtAt_lt g₁ hg₁ z hz₁ (by rw [hnxt₁, hcnt₁]; omega)
  have hpin_far : ∀ v : ℤ, pend (objAt g₁ v) = false →
      z + (cntAt g z : ℤ) + (m * (P + 1) : ℕ) < v := fun v hv => by
    by_contra hle
    rw [not_lt] at hle
    rcases le_or_gt v z with hvz | hvz
    · exact Bool.false_ne_true (hv.symm.trans (hpast₁ v hvz))
    · have := (cntAt_sub_of_pend g₁ hg₁ z hz₁ (v - z).toNat (by rw [hcnt₁]; omega)).1
      rw [show z + (((v - z).toNat : ℕ) : ℤ) = v by omega] at this
      exact Bool.false_ne_true (hv.symm.trans this)
  -- the register, rebuilt at `z` with the anchor raised by the same amount
  have hw : ∀ v, step (objAt g₁ v) (objAt g₁ (v + 1)) = true := fun v => objAt_step g₁ hg₁ v
  have hidle : ∀ v, pend (objAt g₁ v) = false → cntAt g₁ v = 0 := fun v h =>
    cntAt_eq_zero_of_idle g₁ hg₁ v h
  have hpp : ∀ v, pend (objAt g₁ v) = true → pend (objAt g₁ (v + 1)) = true →
      cntAt g₁ (v + 1) + 1 = cntAt g₁ v := fun v h0 h1 => cntAt_succ_of_pend_pend g₁ hg₁ v h0 h1
  have hpi : ∀ v, pend (objAt g₁ v) = true → pend (objAt g₁ (v + 1)) = false →
      cntAt g₁ v = 0 := fun v h0 h1 => (cntAt_eq_zero_of_pend_idle g₁ hg₁ v h0 h1).1
  have hpins : ∀ s v, pend (objAt g₁ s) = false → pend (objAt g₁ (s + 1)) = true →
      pend (objAt g₁ v) = false → pend (objAt g₁ (v + 1)) = true →
      ((cntAt g₁ (s + 1) : ℤ) - cntAt g₁ (v + 1)).natAbs ≤ (s - v).natAbs :=
    fun s v hs0 hs1 hv0 hv1 => pinCompat_of_ladderPath g₁ hg₁ s v hs0 hs1 hv0 hv1
  have hn₀ : ∀ v, pend (objAt g₁ v) = false → pend (objAt g₁ (v + 1)) = true →
      ((cntAt g₁ (v + 1) : ℤ) - (nxtAt g z + m * (P + 1))).natAbs ≤ (v - z).natAbs :=
    fun v h0 h1 => by
    have hfar := hpin_far v h0
    have hpin : cntAt g₁ (v + 1) = nxtAt g₁ v := cntAt_eq_nxtAt_of_idle_pend g₁ hg₁ v h0 h1
    have hlip := nxtAt_lipschitz_two_sided g₁ hg₁ v z
    rw [hnxt₁] at hlip
    rw [hpin]
    have hbridge : ((m * (P + 1) : ℕ) : ℤ) = (m : ℤ) * ((P : ℤ) + 1) := by push_cast; ring
    omega
  obtain ⟨g₂, hg₂, hobj₂, hcnt₂, hnxt₂⟩ :=
    exists_ladderPath_of_walk_nxt_at (objAt g₁) (cntAt g₁) z (nxtAt g z + m * (P + 1))
      hw hidle hpp hpi hpins hn₀
  refine ⟨g₂, hg₂, by rw [hobj₂, hobj₁], by rw [hcnt₂, hcnt₁], hnxt₂, fun σ σ' hσ hσ' => ?_⟩
  obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
  have e : tpOf (ladderModel step pend fwd bwd lab) φ σ' z
      = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ z :=
    tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ₁
      (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ₁ t)
      hobj₂ hno z
  rw [e, hty₁ σ σ₁ hσ hσ₁]

/-- **THE UPWARD CELL INCLUSION along the COMMON-SHIFT chain**, the sub-regime
`cellAt_subset_of_shift_of_pend_past`'s docstring names and does not state. In the
pending-forever regime (`n + 2 ≤ c`) at countdown at least `Tc`, the cell at `(q, c, n)` is
contained in the cell at `(q, c + m · (P + 1), n + m · (P + 1))`: every type realized at the
former is realized at the latter, by the register-carrying assembly
`exists_ladderPath_through_common_shifted_of_pend_past`. The landed theorem covers the
sub-regime `n' = n`; together the two cover both sub-regimes `kappa_collision_regimes` names.
ONE direction only — no downward inclusion is claimed, and nothing here is stated under the
reserved name `cellLE_zero_const_of_kappa_eq`. -/
theorem cellAt_subset_of_common_shift_of_pend_past {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n + m * (P + 1)), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  rw [mem_cellAt_ladder_iff] at hT ⊢
  obtain ⟨g, τ, hg, hgz, hτ, hT⟩ := hT
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n := by simp [nxtAt, hgz]
  have hz : pend (objAt g z) = true := by
    by_contra hne
    rw [Bool.not_eq_true, hoz] at hne
    have := h hne
    omega
  have hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; exact hgap)
  obtain ⟨g', hg', ho, hc, hn, hty⟩ :=
    exists_ladderPath_through_common_shifted_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno
      g hg z hpast (by rw [hcz, hnz]; exact hgap) (by rw [hcz]; exact hTc) m
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c + m * (P + 1), n + m * (P + 1))
    rw [ho, hc, hn, hoz, hcz, hnz]
  · rw [hty τ τ' hτ hτ', hT]

end CommonShift

/-! ## The collision case split -/

section Collision

/-- **THE COLLISION CASE SPLIT, over arithmetic facts.** A `kappa`-collision between two counter
pairs, read through the three landed destructors `kappa_eq_components`,
`eq_or_both_ge_of_min_eq` and `clipIdx_regime_of_eq` at `(K4)`'s `2 ≤ B`, occupies one of THREE
regimes:

* the EQUAL-REGISTER regime `n = n'`, where the two countdowns are congruent modulo `P + 1` —
  the sub-regime the landed `cellAt_subset_of_shift_of_pend_past` addresses;
* the COMMON-SHIFT regime, where both coordinates are displaced by the SAME multiple of
  `P + 1` — the sub-regime `cellAt_subset_of_common_shift_of_pend_past` addresses;
* the SATURATED-GAP regime, where the gap coordinate is pinned at its clip at BOTH pairs, on the
  same side of the window: either `c ≤ n`, `c' ≤ n'` and `B ≤ n - c`, `B ≤ n' - c'`, or `n < c`,
  `n' < c'` and `B ≤ c - n`, `B ≤ c' - n'`.

The third branch is the honest residue of this reading, not an artifact of it: the two-branch
form is refuted by `kappa_collision_two_regimes_refuted` below. Stated over named arithmetic
facts rather than over cells, so a cell-level consumer may dispatch on it. -/
theorem kappa_collision_regimes (Tc Tn P B c n c' n' : ℕ) (hB : 2 ≤ B)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    (n = n' ∧ (∃ m : ℕ, c' = c + m * (P + 1) ∨ c = c' + m * (P + 1)) ∧
        (c = c' ∨ max c c' ≤ n ∨ n + 2 ≤ min c c')) ∨
      (∃ m : ℕ, (c' = c + m * (P + 1) ∧ n' = n + m * (P + 1)) ∨
        (c = c' + m * (P + 1) ∧ n = n' + m * (P + 1))) ∨
      ((c ≤ n ∧ c' ≤ n' ∧ B ≤ n - c ∧ B ≤ n' - c') ∨
        (n < c ∧ n' < c' ∧ B ≤ c - n ∧ B ≤ c' - n')) := by
  obtain ⟨-, hrc, hmn, -, hclip⟩ := kappa_eq_components Tc Tn P B c n c' n' hk
  -- the countdown residue, read as an explicit displacement by a multiple of `P + 1`
  obtain ⟨k, hkc⟩ : ∃ k : ℕ, c' = c + k * (P + 1) ∨ c = c' + k * (P + 1) := by
    rcases le_total c c' with hle | hle
    · obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' hle).mp hrc
      rw [Nat.mul_comm] at hj
      exact ⟨j, Or.inl (by omega)⟩
    · obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' hle).mp hrc.symm
      rw [Nat.mul_comm] at hj
      exact ⟨j, Or.inr (by omega)⟩
  rcases eq_or_both_ge_of_min_eq Tn n n' hmn with hn | -
  · -- the EQUAL-REGISTER regime; the gap coordinate segregates the two counter regimes
    refine Or.inl ⟨hn, ⟨k, hkc⟩, ?_⟩
    rcases lt_trichotomy c c' with hlt | heq | hgt
    · subst hn
      rcases clipIdx_regime_of_eq B c c' n hB hlt hclip with hw | hgapr
      · exact Or.inr (Or.inl (by omega))
      · exact Or.inr (Or.inr (by omega))
    · exact Or.inl heq
    · subst hn
      rcases clipIdx_regime_of_eq B c' c n hB hgt hclip.symm with hw | hgapr
      · exact Or.inr (Or.inl (by omega))
      · exact Or.inr (Or.inr (by omega))
  · -- the gap coordinate, read on each side of the window
    rcases le_or_gt c n with hcn | hcn <;> rcases le_or_gt c' n' with hcn' | hcn'
    · unfold clipIdx at hclip
      rw [if_pos hcn, if_pos hcn'] at hclip
      rcases eq_or_both_ge_of_min_eq B (n - c) (n' - c') (by omega) with he | ⟨hb, hb'⟩
      · refine Or.inr (Or.inl ⟨k, ?_⟩)
        rcases hkc with h | h
        · exact Or.inl ⟨h, by omega⟩
        · exact Or.inr ⟨h, by omega⟩
      · exact Or.inr (Or.inr (Or.inl ⟨hcn, hcn', hb, hb'⟩))
    · -- vacuous: a clip at or above `B` cannot equal one at or below it at `2 ≤ B`
      unfold clipIdx at hclip
      rw [if_pos hcn, if_neg (not_le.mpr hcn')] at hclip
      omega
    · unfold clipIdx at hclip
      rw [if_neg (not_le.mpr hcn), if_pos hcn'] at hclip
      omega
    · unfold clipIdx at hclip
      rw [if_neg (not_le.mpr hcn), if_neg (not_le.mpr hcn')] at hclip
      rcases eq_or_both_ge_of_min_eq B (c - n) (c' - n') (by omega) with he | ⟨hb, hb'⟩
      · refine Or.inr (Or.inl ⟨k, ?_⟩)
        rcases hkc with h | h
        · exact Or.inl ⟨h, by omega⟩
        · exact Or.inr ⟨h, by omega⟩
      · exact Or.inr (Or.inr (Or.inr ⟨hcn, hcn', hb, hb'⟩))

/-- **THE TWO-BRANCH COLLISION SPLIT IS REFUTED**, at the destructors `kappa_collision_regimes`
is proved from together with `(K4)`'s `2 ≤ B`. The equal-register and common-shift alternatives
do NOT exhaust the collisions of `kappa`: at `Tc = Tn = P = 0` and `B = 2` the pairs `(0, 2)` and
`(0, 3)` collide — both clipped coordinates are pinned at their thresholds, both residues are
trivial at `P + 1 = 1`, and the gap coordinate is SATURATED at the clip on both (`2 ≤ 2 - 0` and
`2 ≤ 3 - 0`) — while the registers differ and the countdowns coincide, so neither alternative
holds. This is why `kappa_collision_regimes` carries its third, saturated-gap branch.

The refutation is scoped to this derivation: it refutes the two-branch form as a consequence of
the collision destructors and `2 ≤ B`, and asserts NOTHING about the two-branch form under full
`ParamsOk`, whose `(K1)`, `(K2)` and `(K4)` quantify the formula and are not read here. -/
theorem kappa_collision_two_regimes_refuted :
    ¬ ∀ (Tc Tn P B c n c' n' : ℕ), 2 ≤ B →
        kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
        (n = n' ∧ ∃ m : ℕ, c' = c + m * (P + 1) ∨ c = c' + m * (P + 1)) ∨
          (∃ m : ℕ, (c' = c + m * (P + 1) ∧ n' = n + m * (P + 1)) ∨
            (c = c' + m * (P + 1) ∧ n = n' + m * (P + 1))) := by
  intro h
  have hk : kappa 0 0 0 2 (0, 2) = kappa 0 0 0 2 (0, 3) := by decide
  rcases h 0 0 0 2 0 2 0 3 (by omega) hk with ⟨hn, -⟩ | ⟨m, hm | hm⟩
  · omega
  · omega
  · omega

end Collision

end FormalSystem.Metalogic.Decidability.RaySummary

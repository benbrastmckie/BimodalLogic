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

The layer has three parts.

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

The FORWARD-SLACK DOWNWARD HALF. A downward inclusion cannot be stated on the STATE under a
path-level regime (`ClimbWitness.hasForwardSlack_refuted_unconditional`), so `ForwardSlackWitnessed`
lifts `LadderChain.lean`'s path-level downward inclusions to the cell by asking, existentially,
that every type the higher cell realizes be realized there by SOME path carrying the regime.
Two downward inclusions are read through it, and each pairs with one upward inclusion above to
give a depth-`0` cell-EQUALITY schema:

* the EQUAL-REGISTER pair — `cellAt_subset_of_shift_of_pend_past_rev` against the landed
  `cellAt_subset_of_shift_of_pend_past`, giving `CellLEZeroConstOfKappaEqForwardSlack` and its
  theorem, which carries the equal-register restriction `n = n'`;
* the COMMON-SHIFT pair — `cellAt_subset_of_common_shift_of_pend_past_rev` (whose witnessing path
  work is `mem_cellAt_of_common_shift_of_hasForwardSlack_exact`, resting on `LadderChain.lean`'s
  register-LOWERING deletion `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`)
  against `cellAt_subset_of_common_shift_of_pend_past`, giving
  `CellLEZeroConstOfKappaEqCommonShiftForwardSlack` and its theorem, which carries NO
  equal-register restriction — the common-shift displacement stands in its place.

The register-lowering deletion is what makes the second pair possible: the landed deletion holds
the register, so the equal-register restriction on the first schema is forced by the asymmetry
rather than by the mathematics. The price of moving the register is a DOUBLED regime amount
`m · (P + 1) + m · (P + 1)` and a room bound `n + (m · (P + 1) + m · (P + 1)) ≤ c`, both carried
explicitly. The saturated branch remains the honest residue, in both schemas, and the reserved
name `cellLE_zero_const_of_kappa_eq` is claimed by nothing in this module: both schemas are
strictly stronger in hypotheses than the reserved statement and bear on its truth value in
neither direction.
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

/-! ## The free-register sub-regime -/

section FreeRegister

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE REGIME-A ASSEMBLY WITH THE REGISTER DELIVERED AT A FREE ANCHOR.** The landed
`exists_ladderPath_through_shifted_of_pend_past` raises `z`'s countdown by exactly `m · (P + 1)`
and HOLDS the register; `exists_ladderPath_through_common_shifted_of_pend_past` raises both by
that same amount. This raises the countdown by `m · (P + 1)` and delivers the register at ANY
prescribed `n₀` between `nxtAt g z` and `cntAt g z + m · (P + 1)`. The walk and every countdown
are the landed path's, unchanged: only the deadline register is rebuilt, by the freed-anchor lift
`exists_ladderPath_of_walk_nxt_at` at `z` with the anchor value `n₀`.

Exactly ONE step differs from the common-shift assembly: the anchor VALUE passed to
`exists_ladderPath_of_walk_nxt_at` is `n₀` rather than `nxtAt g z + m · (P + 1)`. The anchor
clause then closes by `omega` from six facts — the pin distance (`hpin_far`: every pin of the
raised path lies beyond `z + cntAt g z + m · (P + 1)`), the pin identity
(`cntAt_eq_nxtAt_of_idle_pend`), the register's two-sided Lipschitz bound
(`nxtAt_lipschitz_two_sided`), the pending-forever gap `hgap`, and the two bounds on `n₀`.

**Which bound pays for which direction.** The LOWER bound `nxtAt g z ≤ n₀` is what the Lipschitz
direction needs: it keeps the prescribed anchor from sitting so far below the register's value at
`z` that the pin's own value, bounded against that value by the pin distance, overshoots `n₀` by
more than the distance allows. The UPPER bound `n₀ ≤ cntAt g z + m · (P + 1)` is what the pin
distance needs: a pin beyond `z + cntAt g z + m · (P + 1)` is at least that far away, so an
anchor within that same amount of `z`'s countdown cannot be overshot in the other direction.
Neither bound is decorative: `free_register_anchor_clause_monotone_required` compiles the lower
one as non-removable.

At `n₀ := nxtAt g z + m · (P + 1)` — admissible by `hgap`, which gives
`nxtAt g z ≤ nxtAt g z + m · (P + 1) ≤ cntAt g z + m · (P + 1)` — this recovers
`exists_ladderPath_through_common_shifted_of_pend_past` hypothesis for hypothesis; at
`n₀ := nxtAt g z` it recovers the landed register-holding raise. -/
theorem exists_ladderPath_through_free_register_shifted_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hgap : nxtAt g z + 2 ≤ cntAt g z) (hTc : Tc ≤ cntAt g z) (m : ℕ) (n₀ : ℕ)
    (hlo : nxtAt g z ≤ n₀) (hhi : n₀ ≤ cntAt g z + m * (P + 1)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = n₀ ∧
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
  -- the register, rebuilt at `z` with the anchor at the prescribed `n₀`
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
      ((cntAt g₁ (v + 1) : ℤ) - n₀).natAbs ≤ (v - z).natAbs :=
    fun v h0 h1 => by
    have hfar := hpin_far v h0
    have hpin : cntAt g₁ (v + 1) = nxtAt g₁ v := cntAt_eq_nxtAt_of_idle_pend g₁ hg₁ v h0 h1
    have hlip := nxtAt_lipschitz_two_sided g₁ hg₁ v z
    rw [hnxt₁] at hlip
    rw [hpin]
    have hbridge : ((m * (P + 1) : ℕ) : ℤ) = (m : ℤ) * ((P : ℤ) + 1) := by push_cast; ring
    omega
  obtain ⟨g₂, hg₂, hobj₂, hcnt₂, hnxt₂⟩ :=
    exists_ladderPath_of_walk_nxt_at (objAt g₁) (cntAt g₁) z n₀
      hw hidle hpp hpi hpins hn₀
  refine ⟨g₂, hg₂, by rw [hobj₂, hobj₁], by rw [hcnt₂, hcnt₁], hnxt₂, fun σ σ' hσ hσ' => ?_⟩
  obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
  have e : tpOf (ladderModel step pend fwd bwd lab) φ σ' z
      = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ z :=
    tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ₁
      (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ₁ t)
      hobj₂ hno z
  rw [e, hty₁ σ σ₁ hσ hσ₁]

/-- **THE LOWER BOUND ON THE FREE ANCHOR IS NOT REMOVABLE.** The anchor clause
`exists_ladderPath_through_free_register_shifted_of_pend_past` discharges does NOT follow from the
pin distance, the Lipschitz bound, the pending-forever gap and the UPPER bound on the anchor
alone: dropping the lower bound `nxtAt g z ≤ n₀` makes it false. The arithmetic witness is
`X = 19`, `nz = 8`, `cz = 10`, `mP = 0`, `n₀ = 0`, `d = 11`, under the correspondence
`X ↔ nxtAt g₁ v` (the register at a pin), `nz ↔ nxtAt g z`, `cz ↔ cntAt g z`,
`mP ↔ m · (P + 1)`, `d ↔ v − z` (the pin's distance from the anchor position): every other
hypothesis holds (`10 < 11`, `(19 − 8).natAbs = 11 ≤ 11`, `8 + 2 ≤ 10`, `0 ≤ 10`) while the
conclusion `(19 − 0).natAbs = 19 ≤ 11` fails.

Which direction fails, and what paying it would cost. The failure is in the UPPER direction of
the clause: the pin's register value overshoots a LOWERED anchor by more than the pin distance
allows, and on the raised path nothing bounds the register at a far pin from above. Paying that
cost would require a forward-slack hypothesis at the LOWER pair — a hypothesis family no landed
schema carries — so the free-register raise reaches the MONOTONE side of a collision only. The
antitone side is excluded, not refuted: see `MonotoneCollisionDisplacement` and
`kappa_collision_antitone_residue_nonvacuous` below. -/
theorem free_register_anchor_clause_monotone_required :
    ¬ ∀ X nz cz mP n₀ d : ℤ, 0 ≤ X → 0 ≤ mP → 0 ≤ n₀ →
        cz + mP < d → (X - nz).natAbs ≤ d.natAbs → nz + 2 ≤ cz →
        n₀ ≤ cz + mP → (X - n₀).natAbs ≤ d.natAbs := by
  intro h
  have hbad := h 19 8 10 0 0 11 (by omega) (by omega) (by omega) (by omega) (by omega)
    (by omega) (by omega)
  omega

end FreeRegister

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

/-- **THE TWO-BRANCH COLLISION SPLIT STAYS REFUTED INSIDE THE PENDING-FOREVER REGIME.** The
saturated-gap branch of `kappa_collision_regimes` is not an artifact of reading the collision
outside the regime the cell-level inclusions work in: restricting to the pending-forever gap
`n + 2 ≤ c` at BOTH pairs and to countdowns at or above the threshold `Tc` does NOT remove it.
At `Tc = Tn = P = 0` and `B = 2` the pairs `(2, 0)` and `(4, 1)` collide — both clipped
coordinates are pinned at their thresholds, both residues are trivial at `P + 1 = 1`, and the
gap coordinate is saturated BELOW the window on both (`clipIdx 2 2 0 = clipIdx 2 4 1 = 0`) —
while `0 + 2 ≤ 2`, `1 + 2 ≤ 4` and `0 ≤ 2`, `0 ≤ 4` hold, the registers differ (`0 ≠ 1`), and
no single `m` displaces both coordinates (`4 = 2 + m` forces `m = 2` while `1 = 0 + m` forces
`m = 1`).

This is the compiled reason the forward-slack-restricted obligation below carries the
EQUAL-REGISTER hypothesis `n = n'` rather than dispatching on `kappa_collision_regimes`: inside
the pending-forever regime the case split still has a residue on which the registers differ by
a multiple of `P + 1` that the countdowns do not match, and no landed inclusion — upward,
common-shift or downward — addresses it, in either direction.

The refutation is scoped to this derivation, exactly as `kappa_collision_two_regimes_refuted` is:
it refutes the two-branch form as a consequence of the collision destructors, `2 ≤ B` and the
regime inequalities, and asserts NOTHING about the two-branch form under full `ParamsOk`, whose
`(K1)`, `(K2)` and `(K4)` quantify the formula and are not read here. -/
theorem kappa_collision_two_regimes_refuted_of_pend_gap :
    ¬ ∀ (Tc Tn P B c n c' n' : ℕ), 2 ≤ B →
        kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
        n + 2 ≤ c → n' + 2 ≤ c' → Tc ≤ c → Tc ≤ c' →
        (n = n' ∨ ∃ m : ℕ, (c' = c + m * (P + 1) ∧ n' = n + m * (P + 1)) ∨
          (c = c' + m * (P + 1) ∧ n = n' + m * (P + 1))) := by
  intro h
  have hk : kappa 0 0 0 2 (2, 0) = kappa 0 0 0 2 (4, 1) := by decide
  rcases h 0 0 0 2 2 0 4 1 (by omega) hk (by omega) (by omega) (by omega) (by omega) with
    hn | ⟨m, hm | hm⟩
  · omega
  · omega
  · omega

end Collision

/-! ## The forward-slack-restricted obligation -/

section ForwardSlack

/-- **THE FORWARD-SLACK REGIME, LIFTED FROM ONE PATH TO A WHOLE CELL.** The landed downward
inclusion `mem_cellAt_of_shift_of_hasForwardSlack_exact` is stated on the WITNESSING PATH, and
necessarily so: `ClimbWitness.hasForwardSlack_refuted_unconditional` compiles a path through a
state satisfying every state-level hypothesis a consumer carries and violating the regime, so no
state-level variant of the regime can be stated. `ForwardSlackWitnessed x z l n` is the
weakest condition on the STATE `x` under which that path-level inclusion nevertheless yields a
cell-level one: every type the cell at `x` realizes is realized there by SOME path carrying
`HasForwardSlack · z l n`.

It is existential over paths, not universal, which is exactly why the climbing-register
refutation does not touch it: the climbing path's presence among the paths through `x` is
compatible with some other path realizing the same type with slack. Nothing here asserts the
condition HOLDS at any state — it is a hypothesis a consumer must supply, and the record names
it as such. -/
def ForwardSlackWitnessed {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (x : LadderState Q pend) (z : ℤ) (l n : ℕ) : Prop :=
  ∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
      ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z,
    ∃ (g : ℤ → LadderState Q pend)
      (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      IsLadderPath step pend g ∧ g z = x ∧ (∀ t : ℤ, τ.state t = (t, g t)) ∧
      HasForwardSlack g z l n ∧
      tpOf (ladderModel step pend fwd bwd lab) φ τ z = T

/-- **THE DOWNWARD CELL INCLUSION AT THE STATE LEVEL, under the forward-slack witnessing of the
HIGHER state.** The mirror of the landed upward `cellAt_subset_of_shift_of_pend_past`: in the
pending-forever regime (`n + 2 ≤ c`) at countdown at least `Tc`, if every type the cell at
`(q, c + m · (P + 1), n)` realizes is realized there by a path with
`HasForwardSlack · z (m · (P + 1)) n`, then that cell is contained in the cell at `(q, c, n)`.

This is the ONE step the state level needs and the path level already has: the body is
`mem_cellAt_of_shift_of_hasForwardSlack_exact` applied to the witnessing path the hypothesis
supplies. The hypothesis is not removable — see `ForwardSlackWitnessed`'s own docstring and the
compiled `ClimbWitness.hasForwardSlack_refuted_unconditional` it cites — and the register is
HELD on both sides: no common-shift mirror of this statement is claimed, because the landed
deletion holds the register and nothing landed lowers it. -/
theorem cellAt_subset_of_shift_of_pend_past_rev {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n), h'⟩ : LadderState Q pend) z (m * (P + 1)) n) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, hslack, hty⟩ := hw T hT
  have hmem := mem_cellAt_of_shift_of_hasForwardSlack_exact step pend fwd bwd lab φ Tc Tn P B
    hp hno q c n h m h' hgap hTc z g hg hgz hslack τ hτ
  rwa [hty] at hmem


/-- **THE DOWNWARD CELL INCLUSION ON THE WITNESSING PATH, for the COMMON SHIFT.** The mirror of
`mem_cellAt_of_shift_of_hasForwardSlack_exact` with the register carried DOWN by the same multiple
of `P + 1` as the countdown: in the pending-forever regime (`n + 2 ≤ c`) at countdown at least
`Tc`, every type realized at `(q, c + m · (P + 1), n + m · (P + 1))` BY A PATH `g` satisfying
`HasForwardSlack g z (m · (P + 1) + m · (P + 1)) (n + m · (P + 1))` is realized at `(q, c, n)`.
The body is `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`
(`LadderChain.lean`) at `n₀ := n` and `k := m · (P + 1)`.

**Why the regime amount is DOUBLED.** The deletion pays `m · (P + 1)` for the countdown and a
further `k = m · (P + 1)` for lowering the anchor from `nxtAt g z = n + m · (P + 1)` to `n`;
those are the two summands, not a loose bound. The landed equal-register inclusion pays only the
first, because it HOLDS the register.

**Why `hroom` is carried separately.** `hgap : n + 2 ≤ c` does not imply
`hroom : n + (m · (P + 1) + m · (P + 1)) ≤ c`, and `hroom` does not imply `hgap` (it is vacuous
at `m = 0`, where `hgap` is not). The landed equal-register inclusion runs on `hgap` alone; the
common shift displaces the register too, so both are genuine hypotheses here.

The statement is on the WITNESSING PATH, not on the state, for the same compiled reason as the
landed one: `cellAt` quantifies over every path through the state, and
`ClimbWitness.hasForwardSlack_refuted_unconditional` compiles a path through a state satisfying
every state-level hypothesis a consumer carries and violating the regime. The state-level form is
`cellAt_subset_of_common_shift_of_pend_past_rev` below, under `ForwardSlackWitnessed`. -/
theorem mem_cellAt_of_common_shift_of_hasForwardSlack_exact
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hroom : n + (m * (P + 1) + m * (P + 1)) ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n + m * (P + 1)), h'⟩)
    (hslack : HasForwardSlack g z (m * (P + 1) + m * (P + 1)) (n + m * (P + 1)))
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  classical
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c + m * (P + 1) := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n + m * (P + 1) := by simp [nxtAt, hgz]
  have hz : pend (objAt g z) = true := by
    by_contra hne
    rw [Bool.not_eq_true, hoz] at hne
    have := h hne
    omega
  have hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; omega)
  obtain ⟨g', hg', ho, hc, hn, hty⟩ :=
    exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g hg z hpast m n (m * (P + 1)) (by rw [hnz]) (by rw [hcz]; omega)
      (by rw [hcz, hnz]; omega) (by rw [hnz]; exact hslack)
  have hc' : cntAt g' z = c := by omega
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  rw [mem_cellAt_ladder_iff]
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c, n)
    rw [ho, hc', hn, hoz]
  · exact hty τ τ' hτ hτ'

/-- **THE COMMON-SHIFT DOWNWARD CELL INCLUSION AT THE STATE LEVEL.** The common-shift mirror of
`cellAt_subset_of_shift_of_pend_past_rev`: in the pending-forever regime (`n + 2 ≤ c`) at
countdown at least `Tc`, with the room `n + (m · (P + 1) + m · (P + 1)) ≤ c`, if every type the
cell at `(q, c + m · (P + 1), n + m · (P + 1))` realizes is realized there by a path with
`HasForwardSlack · z (m · (P + 1) + m · (P + 1)) (n + m · (P + 1))`, then that cell is contained
in the cell at `(q, c, n)`. The body is
`mem_cellAt_of_common_shift_of_hasForwardSlack_exact` applied to the witnessing path the
hypothesis supplies.

The witnessing hypothesis is NOT removable, for the same compiled reason as in the landed
equal-register mirror: `ClimbWitness.hasForwardSlack_refuted_unconditional` refutes every
state-level form of the regime, so the condition must be existential over the paths through the
state. What is new here, and the whole point of the statement, is that the REGISTER MOVES: the
landed mirror holds it, which is what forced the equal-register hypothesis on the depth-`0`
schema. Together with the landed upward `cellAt_subset_of_common_shift_of_pend_past` this closes
the common-shift sub-regime in both directions. -/
theorem cellAt_subset_of_common_shift_of_pend_past_rev {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hroom : n + (m * (P + 1) + m * (P + 1)) ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n + m * (P + 1)), h'⟩ : LadderState Q pend) z
      (m * (P + 1) + m * (P + 1)) (n + m * (P + 1))) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n + m * (P + 1)), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, hslack, hty⟩ := hw T hT
  have hmem := mem_cellAt_of_common_shift_of_hasForwardSlack_exact step pend fwd bwd lab φ
    Tc Tn P B hp hno q c n h m h' hgap hroom hTc z g hg hgz hslack τ hτ
  rwa [hty] at hmem
/-- **THE FORWARD-SLACK-RESTRICTED DEPTH-`0` CELL OBLIGATION**, stated as a schema. This is NOT
the reserved statement `CellLEZeroConstOfKappaEq`, which is claimed by nothing and stays so. Four
hypotheses separate the two, and all four are visible in the quantifier below:

1. the EQUAL-REGISTER restriction `n = n'`;
2. the pending-forever gap `n + 2 ≤ c` and `n' + 2 ≤ c'`, at BOTH pairs;
3. the threshold bounds `Tc ≤ c` and `Tc ≤ c'`, at both pairs;
4. the forward-slack witnessing `ForwardSlackWitnessed` of whichever pair carries the HIGHER
   countdown, at exactly the displacement `m · (P + 1)` separating the two.

Hypothesis 4 is the one `mem_cellAt_of_shift_of_hasForwardSlack_exact` already consumes, lifted
from a single path to the cell by `ForwardSlackWitnessed`; it sits on the PATHS through the higher
state, never on the state. Hypotheses 2 and 3 are what every landed cell inclusion needs.
Hypothesis 1 is forced by `kappa_collision_two_regimes_refuted_of_pend_gap`: inside the
pending-forever regime at countdowns above the threshold, a collision can still displace the
register by a multiple of `P + 1` that the countdown does not match, and no landed inclusion
addresses that residue in either direction.

WHAT A CONSUMER MUST SUPPLY. The induction that wants this (the ladder-realization induction one
layer up) must, at each state it inducts through, exhibit (i) the register equality across the
collision, and (ii) a forward-slack witness at the higher state: for each type in that state's
cell, a ladder path through it realizing that type whose first region start above `z`'s region
leaves `m · (P + 1)` of room in the anchor clause. Neither is a consequence of `ParamsOk`.

The unrestricted schema `CellLEZeroConstOfKappaEq` is, under `ParamsOk`, NEITHER PROVED NOR
REFUTED, and this theorem does not change that: it is strictly stronger in hypotheses, so it
bears on the unrestricted schema's truth value in neither direction. -/
def CellLEZeroConstOfKappaEqForwardSlack {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      n = n' →
      n + 2 ≤ c → n' + 2 ≤ c' → Tc ≤ c → Tc ≤ c' →
      (∀ m : ℕ, c' = c + m * (P + 1) →
        ForwardSlackWitnessed step pend fwd bwd lab φ
          (⟨(q, c', n'), h'⟩ : LadderState Q pend) z (m * (P + 1)) n') →
      (∀ m : ℕ, c = c' + m * (P + 1) →
        ForwardSlackWitnessed step pend fwd bwd lab φ
          (⟨(q, c, n), h⟩ : LadderState Q pend) z (m * (P + 1)) n) →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

/-- **THE FORWARD-SLACK-RESTRICTED OBLIGATION IS A THEOREM.** The schema above holds at every
parameter tuple `ParamsOk` admits. The collision supplies, through `kappa_eq_components`'
countdown residue, an explicit displacement by a multiple of `P + 1` in one direction or the
other; the landed upward `cellAt_subset_of_shift_of_pend_past` gives the inclusion from the
lower pair into the higher, `cellAt_subset_of_shift_of_pend_past_rev` with the witnessing
hypothesis gives the reverse, and `Set.Subset.antisymm` closes the EQUALITY.

Why the destructor and not the case split. `kappa_collision_regimes` reads a collision as three
arithmetic regimes, and with the register equality already in hand its branch structure supplies
nothing the residue congruence does not: the equal-register branch gives exactly this
displacement, the common-shift branch collapses to `m = 0` under `n = n'`, and the saturated-gap
branch — which the case split keeps and this schema does NOT exclude — needs the congruence all
the same. The destructor is therefore the whole of the arithmetic this proof consumes, and the
case split is used for the scope statement rather than the derivation.

The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing here. -/
theorem cellLE_zero_const_of_kappa_eq_of_forwardSlack {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEqForwardSlack step pend fwd bwd lab φ Tc Tn P B := by
  intro hp hno q c n c' n' h h' z hk hreg hgap hgap' hTc hTc' hwup hwdn
  subst hreg
  obtain ⟨-, hrc, -, -, -⟩ := kappa_eq_components Tc Tn P B c n c' n hk
  rcases le_total c c' with hle | hle
  · -- `c'` is the higher pair: up from `c`, down from `c'` through the witnessing hypothesis
    obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' hle).mp hrc
    rw [Nat.mul_comm] at hj
    have hc' : c' = c + j * (P + 1) := by omega
    subst hc'
    exact Set.Subset.antisymm
      (cellAt_subset_of_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno q c n h j h'
        hgap hTc z)
      (cellAt_subset_of_shift_of_pend_past_rev step pend fwd bwd lab φ Tc Tn P B hp hno q c n h j
        h' hgap hTc z (hwup j rfl))
  · -- `c` is the higher pair: the same two inclusions with the roles swapped
    obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' hle).mp hrc.symm
    rw [Nat.mul_comm] at hj
    have hc : c = c' + j * (P + 1) := by omega
    subst hc
    exact Set.Subset.antisymm
      (cellAt_subset_of_shift_of_pend_past_rev step pend fwd bwd lab φ Tc Tn P B hp hno q c' n h'
        j h hgap' hTc' z (hwdn j rfl))
      (cellAt_subset_of_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno q c' n h' j h
        hgap' hTc' z)

/-- **THE BRANCH-2 DEPTH-`0` CELL OBLIGATION, with NO EQUAL-REGISTER HYPOTHESIS**, stated as a
schema. The equal-register restriction `n = n'` that `CellLEZeroConstOfKappaEqForwardSlack`
carries is ABSENT here by construction: in its place the collision's displacement is taken as an
explicit hypothesis in the COMMON-SHIFT shape — one `m` displacing the countdown AND the register
by the same `m · (P + 1)` — which is branch 2 of `kappa_collision_regimes`. What separates this
schema from the reserved statement `CellLEZeroConstOfKappaEq` is therefore:

1. the COMMON-SHIFT displacement hypothesis, in place of the equal-register one;
2. the pending-forever gap `n + 2 ≤ c` and `n' + 2 ≤ c'`, at BOTH pairs;
3. the threshold bounds `Tc ≤ c` and `Tc ≤ c'`, at both pairs;
4. the room bound `n + (m · (P + 1) + m · (P + 1)) ≤ c` and the forward-slack witnessing of
   whichever pair carries the HIGHER countdown, at the DOUBLED amount
   `m · (P + 1) + m · (P + 1)`.

The room bound and the witnessing live inside the same clause because `m` is existentially bound
by hypothesis 1 and cannot be named outside a clause that quantifies it. The doubling in
hypothesis 4 is the price of moving the register: `m · (P + 1)` for the countdown and a further
`m · (P + 1)` for lowering the anchor, as
`mem_cellAt_of_common_shift_of_hasForwardSlack_exact` records. The room bound is a genuine
strengthening of the landed equal-register schema's hypotheses and is not implied by hypothesis 2
(nor does it imply it: it is vacuous at `m = 0`).

WHAT THIS DOES NOT REACH. Branch 3 of `kappa_collision_regimes` — the saturated-gap residue
`kappa_collision_two_regimes_refuted_of_pend_gap` compiles as surviving inside the
pending-forever regime above the threshold — is not addressed, in either direction. This schema
takes the common-shift displacement as a hypothesis rather than dispatching on
`kappa_collision_regimes`, so it says nothing about a collision that falls in that residue.

The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing here, and this schema
bears on its truth value in NEITHER DIRECTION: it is strictly stronger in hypotheses than the
reserved statement, so proving it neither proves nor refutes the reserved one. -/
def CellLEZeroConstOfKappaEqCommonShiftForwardSlack {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      (∃ m : ℕ, (c' = c + m * (P + 1) ∧ n' = n + m * (P + 1)) ∨
        (c = c' + m * (P + 1) ∧ n = n' + m * (P + 1))) →
      n + 2 ≤ c → n' + 2 ≤ c' → Tc ≤ c → Tc ≤ c' →
      (∀ m : ℕ, c' = c + m * (P + 1) → n' = n + m * (P + 1) →
        n + (m * (P + 1) + m * (P + 1)) ≤ c ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c', n'), h'⟩ : LadderState Q pend) z
            (m * (P + 1) + m * (P + 1)) n') →
      (∀ m : ℕ, c = c' + m * (P + 1) → n = n' + m * (P + 1) →
        n' + (m * (P + 1) + m * (P + 1)) ≤ c' ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c, n), h⟩ : LadderState Q pend) z
            (m * (P + 1) + m * (P + 1)) n) →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

/-- **THE BRANCH-2 OBLIGATION IS A THEOREM.** The schema above holds at every parameter tuple
`ParamsOk` admits, as cell EQUALITY. Each direction of the displacement hypothesis is closed by
`Set.Subset.antisymm` against the two common-shift inclusions: upward by the landed
`cellAt_subset_of_common_shift_of_pend_past`, downward by
`cellAt_subset_of_common_shift_of_pend_past_rev`, whose register-lowering deletion is the whole
of what this schema adds over the landed equal-register one.

The collision equality itself is not consumed: the displacement comes from the explicit
common-shift hypothesis, not from `kappa_eq_components`. It is retained as a binder so that the
schema's shape matches `CellLEZeroConstOfKappaEqForwardSlack`'s and so that a consumer reading
the two side by side sees exactly one hypothesis traded for another — the equal-register
restriction for the common-shift displacement. -/
theorem cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEqCommonShiftForwardSlack step pend fwd bwd lab φ Tc Tn P B := by
  intro hp hno q c n c' n' h h' z _ hbr hgap hgap' hTc hTc' hwup hwdn
  obtain ⟨m, hm | hm⟩ := hbr
  · -- `(c', n')` is the higher pair, displaced UP by the common shift
    obtain ⟨hc', hn'⟩ := hm
    subst hc'
    subst hn'
    obtain ⟨hroom, hwit⟩ := hwup m rfl rfl
    exact Set.Subset.antisymm
      (cellAt_subset_of_common_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno
        q c n h m h' hgap hTc z)
      (cellAt_subset_of_common_shift_of_pend_past_rev step pend fwd bwd lab φ Tc Tn P B hp hno
        q c n h m h' hgap hroom hTc z hwit)
  · -- `(c, n)` is the higher pair: the same two inclusions with the roles swapped
    obtain ⟨hc, hn⟩ := hm
    subst hc
    subst hn
    obtain ⟨hroom, hwit⟩ := hwdn m rfl rfl
    exact Set.Subset.antisymm
      (cellAt_subset_of_common_shift_of_pend_past_rev step pend fwd bwd lab φ Tc Tn P B hp hno
        q c' n' h' m h hgap' hroom hTc' z hwit)
      (cellAt_subset_of_common_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno
        q c' n' h' m h hgap' hTc' z)

end ForwardSlack

end FormalSystem.Metalogic.Decidability.RaySummary

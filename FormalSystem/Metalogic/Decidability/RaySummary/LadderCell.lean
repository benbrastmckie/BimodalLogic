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
sub-regimes such a collision can occupy. Beside it, and consumed by no part of it, sits one layer
of PUMP BOOKKEEPING — the iterated splice's two interior clauses, the first landed and the second
refuted (`## The iterated splice's two interior clauses` below). The cell argument imports
`LadderChain.lean` alone and says nothing about pumps or pins beyond what that module already
landed — every construction here is a
reading of the landed regime-A assembly `exists_ladderPath_through_shifted_of_pend_past` with
the register's anchor moved, or of the landed class destructors `kappa_eq_components`,
`eq_or_both_ge_of_min_eq` and `clipIdx_regime_of_eq`.

The layer has four parts.

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

The FREE-REGISTER RAISE. `exists_ladderPath_through_free_register_shifted_of_pend_past` is the
same assembly once more with the anchor VALUE left free: the countdown raised by exactly
`m · (P + 1)`, the object state and the realized stab-free type held, and the register delivered
at ANY prescribed `n₀` with `nxtAt g z ≤ n₀ ≤ cntAt g z + m · (P + 1)`. The two bounds are not
decorative and they pay for opposite directions of the one anchor clause: the LOWER bound is what
the register's Lipschitz bound needs, the UPPER bound what the pin distance needs.
`free_register_anchor_clause_monotone_required` compiles the lower bound as NON-REMOVABLE, at the
arithmetic witness `X = 19`, `nz = 8`, `cz = 10`, `mP = 0`, `n₀ = 0`, `d = 11` — which is the
compiled reason this raise reaches the MONOTONE side of a collision and no further. Two cell
inclusions read it: `cellAt_subset_of_free_register_shift_of_pend_past` upward, consuming NO
forward slack because the widened window pays for the anchor, and
`cellAt_subset_of_free_register_shift_of_pend_past_rev` downward (path level:
`mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact`), at the deletion's own amount
`m · (P + 1) + (n' − n)` with the room bound `n' + (n' − n) ≤ c`. At `n₀ = nxtAt g z` the raise is
the landed register-holding one and at `n₀ = nxtAt g z + m · (P + 1)` it is the common-shift one,
hypothesis for hypothesis.

The RAISE WITH THE LOWER BOUND RELAXED.
`exists_ladderPath_through_free_register_shifted_slack_of_pend_past` is that raise with the lower
bound traded for `nxtAt g z ≤ n₀ + (m · (P + 1) + L)` under forward slack `L` at the lower pair,
which is what pays the UPPER direction of the anchor clause the record above compiles as failing.
Two steps differ: the inner call is `LadderChain.lean`'s
`exists_ladderPath_through_shifted_slack_of_pend_past`, which EXPOSES the raise's own
`m · (P + 1)` of bought slack (the landed assembly discards it), and the re-lift's pin clause is
closed through `anchor_clause_of_first_region_start` at deleted length `0` rather than through raw
`nxtAt_lipschitz_two_sided` — the raw bound being precisely what the necessity record has in hand
when it fails. At `L = 0` and `nxtAt g z ≤ n₀` it is the landed raise hypothesis for hypothesis,
and at `L = 0` the regime hypothesis is free (`hasForwardSlack_zero`).
`free_register_anchor_clause_relaxed_bound_required` compiles the RELAXED bound as non-removable
too, at a DEEP-DESCENT witness `X = 19`, `nz = 8`, `cz = 10`, `mP = 1`, `n₀ = 0`, `d = 12`; the
landed record's own witness has `mP = 0`, where the relaxed bound IS the landed bound, so that
record stays compiled and unamended — its bound is non-removable, as it says, and what is new is
that the bound is RELAXABLE by exactly the raise.

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
and `(K4)` quantify the formula and are not read here. The saturated branch is SPLIT, by
`MonotoneCollisionDisplacement`, into a DISPATCHED monotone
slice — register and countdown displaced in the same direction, closed in both directions by the
two free-register inclusions above — and an EXCLUDED antitone slice. The split is not a
convenience and three compiled records carry it: `kappa_collision_monotone_or_antitone` makes the
two slices an EXHAUSTIVE dichotomy over collisions, with no third case;
`kappa_collision_antitone_residue_nonvacuous` shows the excluded slice is NON-EMPTY inside the
pending-forever regime above the threshold (`(4, 2)` against `(6, 0)` at `Tc = Tn = P = 0`,
`B = 2`); and `kappa_collision_monotone_saturated_gap_nonvacuous` shows the dispatched slice
genuinely reaches branch 3 rather than relabelling the landed coverage — it covers `(2, 0)`
against `(4, 1)`, the exact pair `kappa_collision_two_regimes_refuted_of_pend_gap` pins as
surviving regime restriction and reached by no landed inclusion in either direction.

The antitone slice is NAMED and SPLIT. `AntitoneCollisionDisplacement` is the complement shape
— definitionally the second alternative `kappa_collision_monotone_or_antitone` already produces
— and `kappa_collision_monotone_or_antitone_named` restates the landed dichotomy over the two
named predicates, so exhaustiveness is readable without unfolding a nested disjunction.
`kappa_collision_antitone_descent_multiple` reads the register's descent across a collision as
itself a multiple `j · (P + 1)`, which turns the split into a comparison of two MULTIPLIERS: the
BOUNDED sub-slice `n − n' ≤ m · (P + 1)` (that is, `j ≤ m`) against the DEEP-DESCENT residue.
Both halves are non-empty inside the regime above the threshold —
`kappa_collision_antitone_bounded_descent_nonvacuous` at `(4, 2)` against `(6, 0)` with `m = 2`,
which is the predecessor's OWN non-vacuity witness and therefore lies in the cheaper half, and
`kappa_collision_antitone_deep_descent_nonvacuous` at `(10, 8)` against `(11, 0)` with `m = 1`.

The FORWARD-SLACK DOWNWARD HALF. A downward inclusion cannot be stated on the STATE under a
path-level regime (`ClimbWitness.hasForwardSlack_refuted_unconditional`), so `ForwardSlackWitnessed`
lifts `LadderChain.lean`'s path-level downward inclusions to the cell by asking, existentially,
that every type the higher cell realizes be realized there by SOME path carrying the regime.
Two downward inclusions are read through it, and each pairs with one upward inclusion above to
give a depth-`0` cell-EQUALITY schema:

* the EQUAL-REGISTER pair — `cellAt_subset_of_shift_of_pend_past_rev` against the landed
  `cellAt_subset_of_shift_of_pend_past`, giving `CellLEZeroConstOfKappaEqForwardSlack` and its
  theorem, which carries the equal-register restriction `n = n'`;
* the MONOTONE pair — `cellAt_subset_of_free_register_shift_of_pend_past_rev` (whose witnessing
  path work is `mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact`, resting on the same
  register-LOWERING deletion at `k := n' − n`) against
  `cellAt_subset_of_free_register_shift_of_pend_past`, giving
  `CellLEZeroConstOfKappaEqMonotoneForwardSlack` and its theorem, which carries NEITHER the
  equal-register restriction NOR the common-shift displacement — the monotone shape stands in
  their place, and the ANTITONE complement is excluded by that same hypothesis, visibly, in the
  schema's own quantifier;
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
explicitly; with the register free the price is `m · (P + 1) + (n' − n)` and
`n' + (n' − n) ≤ c`, and the two landed amounts are its `n' = n` and `n' = n + m · (P + 1)`
instances.

* the ANTITONE pair — `cellAt_subset_of_antitone_register_shift_of_pend_past` upward (countdown
  UP, register DOWN, at the truncated amount `(n − n') − m · (P + 1)` witnessed at the LOWER
  pair) against `cellAt_subset_of_antitone_register_shift_of_pend_past_rev` downward (countdown
  DOWN, register UP, at `m · (P + 1)` witnessed at the higher pair and under NO room bound),
  giving `CellLEZeroConstOfKappaEqAntitoneForwardSlack` and its theorem.

Of the saturated branch, BOTH slices are now dispatched in both directions, and the dichotomy
`kappa_collision_monotone_or_antitone_named` is therefore closed: every collision in the
pending-forever regime above the threshold is covered by the monotone schema or the antitone one.
The antitone slice remains EXCLUDED from the monotone schema's own quantifier — that hypothesis is
unchanged — and is dispatched by the antitone schema beside it.

The two directions' prices differ in a way worth naming. The monotone downward half LOWERS the
target register and spends `m · (P + 1) + (n' − n)` under a room bound `n' + (n' − n) ≤ c`; the
antitone downward half RAISES it and spends `m · (P + 1)` under no room bound at all, because a
raise is free in the direction the single anchor inequality charges for. Upward, the antitone
amount is the register's descent BEYOND what the raise already buys, which is `0` on the bounded
sub-slice — and `forwardSlackWitnessed_zero` compiles that an amount-`0` witnessing obligation is
FREE, so `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` carries exactly ONE
`ForwardSlackWitnessed` hypothesis and none upward. Discharging the amount-`0` case settles
NOTHING about the general question, which stays open and is claimed in neither direction: whether
a `ForwardSlackWitnessed` hypothesis at a POSITIVE amount is satisfiable at any state the
induction one layer up reaches.

No landed schema is retired and no landed signature is touched. The reserved name
`cellLE_zero_const_of_kappa_eq` is claimed by nothing in this module: every schema here is
strictly stronger in hypotheses than the reserved statement and bears on its truth value in
neither direction.

The PUMP BOOKKEEPING layer is independent of all four parts above and is read by none of them. It
lands the interior-copy countdown of the iterated splice as a sibling of the landed pump theorem,
refutes the companion register clause, and says nothing about any cell, any `⊡` bit or any `kappa`
coordinate; its own section docstring states both what it says and what it does not. It is homed
here rather than in `LadderChain.lean` because that module has fourteen lines of headroom against
its own in-source `longFile` baseline, and this one imports the whole pump spine.
-/

set_option linter.style.longFile 3300

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

/-- **THE FREE-ANCHOR RAISE WITH THE LOWER BOUND RELAXED BY THE SLACK.** The landed
`exists_ladderPath_through_free_register_shifted_of_pend_past` carries `nxtAt g z ≤ n₀`; this
carries `nxtAt g z ≤ n₀ + (m · (P + 1) + L)` under forward slack `L` at the lower pair. Everything
else is the landed raise: the countdown raised by exactly `m · (P + 1)`, the object state and the
realized stab-free type at `z` held, the register delivered at the prescribed `n₀`, and the same
upper bound `n₀ ≤ cntAt g z + m · (P + 1)`.

**Which direction the slack buys, and why it is the one that was missing.** The anchor clause is
two-sided and its two directions charge for opposite movements of the anchor. The landed raise's
LOWER bound pays the UPPER direction — a pin's register value overshooting a lowered anchor by
more than the pin distance allows — and `free_register_anchor_clause_monotone_required` compiles
that bound as NON-REMOVABLE from the facts the landed raise has in hand. Forward slack at the
LOWER pair is exactly what bounds that pin value from above on the raised path, so it is what the
upper direction can be paid with instead. The route is the one named, and claimed in neither
direction, in that record's own docstring; this is the theorem that takes it.

**The construction.** Two steps differ from the landed raise. First, the inner call is
`exists_ladderPath_through_shifted_slack_of_pend_past`, so the raised path `g₁` arrives carrying
`HasForwardSlack g₁ z (L + m · (P + 1)) (nxtAt g z)` — the raise's own `m · (P + 1)` of bought
slack added to the hypothesis's `L`. Second, the re-lift's pin clause is closed through
`anchor_clause_of_first_region_start` at deleted length `0` and `a := z` on `g₁`, which collapses
the clause at every pin to the single inequality at the FIRST region start above `z`'s raised
region, rather than through raw `nxtAt_lipschitz_two_sided`. The raw Lipschitz bound is not
enough: it is precisely what the necessity record above has in hand when it fails.

**Conservativity.** At `L = 0` and `nxtAt g z ≤ n₀` the relaxed bound is the landed bound and this
theorem is the landed raise, hypothesis for hypothesis — and at `L = 0` the regime hypothesis is
free (`hasForwardSlack_zero`). `free_register_anchor_clause_relaxed_bound_required` below compiles
that the relaxed bound is itself non-removable, so the relaxation is not a removal. -/
theorem exists_ladderPath_through_free_register_shifted_slack_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hgap : nxtAt g z + 2 ≤ cntAt g z) (hTc : Tc ≤ cntAt g z) (m : ℕ) (n₀ L : ℕ)
    (hslack : HasForwardSlack g z L (nxtAt g z))
    (hlo : nxtAt g z ≤ n₀ + (m * (P + 1) + L))
    (hhi : n₀ ≤ cntAt g z + m * (P + 1)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  -- the raise, with the bought slack EXPOSED
  obtain ⟨g₁, hg₁, hobj₁, hcnt₁, hnxt₁, hslack₁, hty₁⟩ :=
    exists_ladderPath_through_shifted_slack_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno
      g hg z hpast hTc m L hslack
  have hz₁ : pend (objAt g₁ z) = true := by rw [hobj₁]; exact hpast z le_rfl
  have hpast₁ : ∀ p : ℤ, p ≤ z → pend (objAt g₁ p) = true :=
    pend_past_of_nxtAt_lt g₁ hg₁ z hz₁ (by rw [hnxt₁, hcnt₁]; omega)
  have hcz₁ : (cntAt g₁ z : ℤ) = (cntAt g z : ℤ) + ((m * (P + 1) : ℕ) : ℤ) := by
    rw [hcnt₁]; push_cast; ring
  -- the anchor clause at the FIRST region start above `z`'s raised region, at deleted length `0`
  have hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g₁ (z + (cntAt g₁ z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g₁ (z + (cntAt g₁ z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g₁ (z + (cntAt g₁ z : ℤ) + (I : ℤ)) : ℤ) - n₀).natAbs
        ≤ ((cntAt g₁ z : ℤ) + I - ((0 : ℕ) : ℤ)).natAbs := fun I hI hidle hnext => by
    have hs := hslack₁ I hI hidle hnext
    have hcast : ((0 : ℕ) : ℤ) = 0 := by norm_num
    rw [hcast]
    omega
  have hanch := anchor_clause_of_first_region_start g₁ hg₁ z hz₁ 0 n₀ hfirst z le_rfl (by
    have hcast : ((0 : ℕ) : ℤ) = 0 := by norm_num
    rw [hcast]; omega)
  have hn₀ : ∀ v, pend (objAt g₁ v) = false → pend (objAt g₁ (v + 1)) = true →
      ((cntAt g₁ (v + 1) : ℤ) - n₀).natAbs ≤ (v - z).natAbs := fun v hv0 hv1 => by
    have hzv : z < v := by
      by_contra hle
      exact Bool.false_ne_true (hv0.symm.trans (hpast₁ v (by omega)))
    have h0 : pend (objAt g₁ (v + ((0 : ℕ) : ℤ))) = false := by simpa using hv0
    have h1 : pend (objAt g₁ (v + ((0 : ℕ) : ℤ) + 1)) = true := by simpa using hv1
    have hres := hanch v hzv h0 h1
    rw [cntAt_eq_nxtAt_of_idle_pend g₁ hg₁ v hv0 hv1]
    simpa using hres
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

/-- **THE RELAXED LOWER BOUND IS NOT REMOVABLE EITHER.** The anchor clause
`exists_ladderPath_through_free_register_shifted_slack_of_pend_past` discharges does NOT follow
from the pin distance, the DISPLACED Lipschitz bound, the pending-forever gap and the upper bound
on the anchor alone: dropping the relaxed lower bound `nxtAt g z ≤ n₀ + (m · (P + 1) + L)` makes
it false. The arithmetic witness is `X = 19`, `nz = 8`, `cz = 10`, `mP = 1`, `n₀ = 0`, `d = 12`,
under the same correspondence `free_register_anchor_clause_monotone_required` names —
`X ↔ nxtAt g₁ v`, `nz ↔ nxtAt g z`, `cz ↔ cntAt g z`, `mP ↔ m · (P + 1)`, `d ↔ v − z`: every other
hypothesis holds (`11 < 12`, `19 ≤ 8 + 12 − 1`, `8 + 2 ≤ 10`, `0 ≤ 11`) while the conclusion
`(19 − 0).natAbs = 19 ≤ 12` fails.

**The witness is DEEP-DESCENT.** The register's descent here is `k = 8`, strictly more than the
`mP = 1` the raise buys — so this witness lies in the half of the antitone slice that
`kappa_collision_antitone_deep_descent_nonvacuous` inhabits, not in the bounded half. That is the
whole point: the relaxation buys exactly `m · (P + 1)` of descent and no more, and beyond that
amount a hypothesis is still required.

**The landed necessity record stays compiled, unamended and uncontradicted.**
`free_register_anchor_clause_monotone_required`'s own witness has `mP = 0`, where the relaxed
bound IS the landed bound — so that record says what it has always said, and this one says
something different. The bound is non-removable, as that record compiles; what is new is that it
is RELAXABLE by exactly the raise. -/
theorem free_register_anchor_clause_relaxed_bound_required :
    ¬ ∀ X nz cz mP n₀ d : ℤ, 0 ≤ X → 0 ≤ mP → 0 ≤ n₀ →
        cz + mP < d → X ≤ nz + d - mP → nz + 2 ≤ cz →
        n₀ ≤ cz + mP → (X - n₀).natAbs ≤ d.natAbs := by
  intro h
  have hbad := h 19 8 10 1 0 12 (by omega) (by omega) (by omega) (by omega) (by omega)
    (by omega) (by omega)
  omega

/-- **THE UPWARD CELL INCLUSION ON THE MONOTONE RESIDUE.** The first cell inclusion to reach
branch 3 of `kappa_collision_regimes`. In the pending-forever regime (`n + 2 ≤ c`) at countdown
at least `Tc`, the cell at `(q, c, n)` is contained in the cell at `(q, c + m · (P + 1), n')` for
EVERY target register `n'` with `n ≤ n' ≤ c + m · (P + 1)`: the register moves UP by an amount the
countdown need NOT match, which is exactly the sub-regime the landed
`cellAt_subset_of_shift_of_pend_past` (`n' = n`) and
`cellAt_subset_of_common_shift_of_pend_past` (`n' = n + m · (P + 1)`) leave out. At those two
values of `n'` this statement is each of them in turn.

NO FORWARD SLACK is consumed. The raise widens `z`'s own region by exactly `m · (P + 1)`, and
that widened window is the whole of what the anchor clause needs — see
`exists_ladderPath_through_free_register_shifted_of_pend_past`, whose two bounds on the anchor
are `hlo` and `hhi` here. The downward half is a different matter and does cost slack:
`mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact` below.

ONE direction only, and nothing here is stated under the reserved name
`cellLE_zero_const_of_kappa_eq`. -/
theorem cellAt_subset_of_free_register_shift_of_pend_past {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (hlo : n ≤ n') (hhi : n' ≤ c + m * (P + 1)) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
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
    exists_ladderPath_through_free_register_shifted_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g hg z hpast (by rw [hcz, hnz]; exact hgap) (by rw [hcz]; exact hTc) m n'
      (by rw [hnz]; exact hlo) (by rw [hcz]; exact hhi)
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c + m * (P + 1), n')
    rw [ho, hc, hn, hoz, hcz]
  · rw [hty τ τ' hτ hτ', hT]

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

/-- **THE MONOTONE DISPLACEMENT SHAPE OF A COLLISION.** The two counter pairs are displaced in
the SAME DIRECTION: whichever countdown is the higher, its register is the weakly higher one too.
Stated over arithmetic alone, like `kappa_collision_regimes` itself, so a cell-level consumer may
carry it as a hypothesis.

What it covers. Branch 1 of `kappa_collision_regimes` (equal register, `n = n'`) and branch 2
(common shift, both coordinates displaced by the same `m · (P + 1)`) are monotone ENTIRE — in
branch 1 the registers are equal, in branch 2 the register moves with the countdown. Branch 3,
the saturated-gap residue, is split by it: the MONOTONE slice is dispatched by
`cellAt_subset_of_free_register_shift_of_pend_past` and
`cellAt_subset_of_free_register_shift_of_pend_past_rev` in both directions, and the ANTITONE
slice — the negation of this predicate — is the explicit EXCLUSION the depth-`0` schema
`CellLEZeroConstOfKappaEqMonotoneForwardSlack` carries in its quantifier.

The exclusion is not tacit, and these are the three compiled records that make it so:
`kappa_collision_monotone_or_antitone` (the complement is exactly the other side of a dichotomy,
not a gap in a case split), `kappa_collision_antitone_residue_nonvacuous` (the complement is
non-empty inside the pending-forever regime above the threshold), and
`kappa_collision_monotone_saturated_gap_nonvacuous` (the dispatched slice genuinely reaches
branch 3 rather than collapsing into the two landed sub-regimes). -/
def MonotoneCollisionDisplacement (P c n c' n' : ℕ) : Prop :=
  (∃ m : ℕ, c' = c + m * (P + 1) ∧ n ≤ n') ∨ (∃ m : ℕ, c = c' + m * (P + 1) ∧ n' ≤ n)

/-- **EVERY COLLISION IS MONOTONE OR ANTITONE, WITH NO THIRD CASE.** The displacement dichotomy.
A `kappa`-collision displaces the countdown by a multiple of `P + 1` in one direction or the
other — that is `kappa_eq_components`' countdown residue, read through `Nat.modEq_iff_dvd'` in
both orientations exactly as `kappa_collision_regimes` reads it — and trichotomy on `n` against
`n'` then leaves only the strict-opposite cases outside the monotone shape.

Consequence, and the reason this is stated: the exclusion carried by
`CellLEZeroConstOfKappaEqMonotoneForwardSlack` is the complement of an EXHAUSTIVE alternative,
not an unexamined remainder. Every collision — branch 1, branch 2 and branch 3 of
`kappa_collision_regimes` alike — is either dispatched by that schema or falls in the one named,
compiled, non-empty excluded set.

No `2 ≤ B` hypothesis: the countdown residue is all the arithmetic this consumes, and it does not
read the clipped gap coordinate, so `(K4)`'s bound is not needed here (unlike in
`kappa_collision_regimes`, whose third branch is read off `clipIdx_regime_of_eq` at `2 ≤ B`). -/
theorem kappa_collision_monotone_or_antitone (Tc Tn P B c n c' n' : ℕ)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    MonotoneCollisionDisplacement P c n c' n' ∨
      ((∃ m : ℕ, c' = c + m * (P + 1) ∧ n' < n) ∨
        (∃ m : ℕ, c = c' + m * (P + 1) ∧ n < n')) := by
  obtain ⟨-, hrc, -, -, -⟩ := kappa_eq_components Tc Tn P B c n c' n' hk
  -- the countdown residue, read as an explicit displacement by a multiple of `P + 1`
  obtain ⟨k, hkc⟩ : ∃ k : ℕ, c' = c + k * (P + 1) ∨ c = c' + k * (P + 1) := by
    rcases le_total c c' with hle | hle
    · obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' hle).mp hrc
      rw [Nat.mul_comm] at hj
      exact ⟨j, Or.inl (by omega)⟩
    · obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' hle).mp hrc.symm
      rw [Nat.mul_comm] at hj
      exact ⟨j, Or.inr (by omega)⟩
  rcases hkc with hc | hc
  · rcases le_or_gt n n' with hn | hn
    · exact Or.inl (Or.inl ⟨k, hc, hn⟩)
    · exact Or.inr (Or.inl ⟨k, hc, hn⟩)
  · rcases le_or_gt n' n with hn | hn
    · exact Or.inl (Or.inr ⟨k, hc, hn⟩)
    · exact Or.inr (Or.inr ⟨k, hc, hn⟩)

/-- **THE ANTITONE COMPLEMENT, NAMED.** The exact disjunction
`kappa_collision_monotone_or_antitone` already produces as its second alternative: the countdown
displaced by a multiple of `P + 1` in one direction while the register moves STRICTLY the other
way. This is definitionally that alternative, introduced so the exhaustiveness of the dichotomy
can be read off a name rather than off an unfolded disjunction — see
`kappa_collision_monotone_or_antitone_named`.

It is the negation of `MonotoneCollisionDisplacement` only up to the countdown displacement
itself: a pair whose countdowns are not congruent mod `P + 1` satisfies neither predicate, and no
such pair is a collision (`kappa_eq_components`' countdown residue). On collisions the two are
complementary, which is exactly what the named dichotomy states. -/
def AntitoneCollisionDisplacement (P c n c' n' : ℕ) : Prop :=
  (∃ m : ℕ, c' = c + m * (P + 1) ∧ n' < n) ∨ (∃ m : ℕ, c = c' + m * (P + 1) ∧ n < n')

/-- **THE DICHOTOMY, OVER THE TWO NAMED PREDICATES.** `kappa_collision_monotone_or_antitone`
read through `AntitoneCollisionDisplacement`. The two theorems are THE SAME THEOREM: the
conclusion here is definitionally the landed one, and the proof is `exact` on it. The landed
statement and body are untouched; this is a sibling that gives the second alternative a name, so
a consumer dispatching on the dichotomy need not unfold a nested disjunction to see that the
slices are exhaustive.

No `2 ≤ B` hypothesis, for the same reason the landed form carries none: only the countdown
residue is consumed. -/
theorem kappa_collision_monotone_or_antitone_named (Tc Tn P B c n c' n' : ℕ)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    MonotoneCollisionDisplacement P c n c' n' ∨
      AntitoneCollisionDisplacement P c n c' n' :=
  kappa_collision_monotone_or_antitone Tc Tn P B c n c' n' hk

/-- **THE REGISTER'S DESCENT ACROSS A COLLISION IS A MULTIPLE OF `P + 1`.** The register residue
of `kappa_eq_components`, read through `Nat.modEq_iff_dvd'` at `n' ≤ n` exactly as
`kappa_collision_monotone_or_antitone` reads the countdown residue.

What this record is for. The antitone slice splits along the comparison of the descent `n − n'`
against the countdown displacement `m · (P + 1)`, and this destructor is what makes that a
comparison of two MULTIPLIERS — `j` against `m` — rather than of a raw register difference
against a product. The BOUNDED sub-slice (`n − n' ≤ m · (P + 1)`, i.e. `j ≤ m`) is reached with
no upward hypothesis at all; the DEEP-DESCENT residue (`j > m`) is what pays the lower pair. Both
halves are non-empty: `kappa_collision_antitone_bounded_descent_nonvacuous` and
`kappa_collision_antitone_deep_descent_nonvacuous`. -/
theorem kappa_collision_antitone_descent_multiple (Tc Tn P B c n c' n' : ℕ)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (hlt : n' < n) :
    ∃ j : ℕ, n = n' + j * (P + 1) := by
  obtain ⟨-, -, -, hrn, -⟩ := kappa_eq_components Tc Tn P B c n c' n' hk
  obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' (le_of_lt hlt)).mp hrn.symm
  rw [Nat.mul_comm] at hj
  exact ⟨j, by omega⟩

/-- **THE BOUNDED-DESCENT HALF OF THE ANTITONE SLICE IS NON-EMPTY INSIDE THE REGIME.** At
`Tc = Tn = P = 0` and `B = 2` the pairs `(4, 2)` and `(6, 0)` collide inside the pending-forever
regime above the threshold, are NOT monotone, and have the countdown displaced by `m = 2` while
the register falls by exactly `2 = m · (P + 1)` — so the descent does not exceed what the raise
already buys.

The significant fact this record carries. This is the PREDECESSOR'S OWN non-vacuity witness:
`kappa_collision_antitone_residue_nonvacuous` exhibits this very pair as inhabiting the excluded
slice. It lies in the half that needs no upward forward-slack hypothesis whatever — see
`cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack`, which carries one witnessing
hypothesis and none upward. So the compiled demonstration that the excluded slice was non-empty
was, all along, a demonstration about its CHEAPER half. -/
theorem kappa_collision_antitone_bounded_descent_nonvacuous :
    ∃ Tc Tn P B c n c' n' m : ℕ, 2 ≤ B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      n + 2 ≤ c ∧ n' + 2 ≤ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧
      ¬ MonotoneCollisionDisplacement P c n c' n' ∧
      c' = c + m * (P + 1) ∧ n' < n ∧ n - n' ≤ m * (P + 1) := by
  refine ⟨0, 0, 0, 2, 4, 2, 6, 0, 2, by omega, by decide, by omega, by omega, by omega, by omega,
    ?_, by omega, by omega, by omega⟩
  rintro (⟨m, h1, h2⟩ | ⟨m, h1, h2⟩) <;> omega

/-- **THE DEEP-DESCENT RESIDUE IS NON-EMPTY TOO.** At `Tc = Tn = P = 0` and `B = 2` the pairs
`(10, 8)` and `(11, 0)` collide inside the pending-forever regime above the threshold, are NOT
monotone, and have the countdown displaced by `m = 1` while the register falls by `8` — strictly
more than the `m · (P + 1) = 1` the raise buys.

What this record is for. The bounded sub-slice does NOT exhaust the antitone slice, so the
lower-pair forward-slack route is not decorative: there are collisions in the slice at which the
truncated upward amount `(n − n') − m · (P + 1)` is strictly positive and the hypothesis
`cellAt_subset_of_antitone_register_shift_of_pend_past` carries is doing real work. Compare
`kappa_collision_antitone_bounded_descent_nonvacuous` for the other half. -/
theorem kappa_collision_antitone_deep_descent_nonvacuous :
    ∃ Tc Tn P B c n c' n' m : ℕ, 2 ≤ B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      n + 2 ≤ c ∧ n' + 2 ≤ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧
      ¬ MonotoneCollisionDisplacement P c n c' n' ∧
      c' = c + m * (P + 1) ∧ n' < n ∧ m * (P + 1) < n - n' := by
  refine ⟨0, 0, 0, 2, 10, 8, 11, 0, 1, by omega, by decide, by omega, by omega, by omega,
    by omega, ?_, by omega, by omega, by omega⟩
  rintro (⟨m, h1, h2⟩ | ⟨m, h1, h2⟩) <;> omega

/-- **THE DISPATCHED MONOTONE SLICE GENUINELY REACHES THE SATURATED-GAP BRANCH.** At
`Tc = Tn = P = 0` and `B = 2` the pairs `(2, 0)` and `(4, 1)` collide inside the pending-forever
regime at countdowns above the threshold (`0 + 2 ≤ 2`, `1 + 2 ≤ 4`, `0 ≤ 2`, `0 ≤ 4`), their
registers DIFFER (`0 ≠ 1`), and no single `m` displaces both coordinates (`4 = 2 + m` forces
`m = 2` while `1 = 0 + m` forces `m = 1`) — so the pair lies in neither branch 1 nor branch 2 of
`kappa_collision_regimes`. It is nevertheless MONOTONE, at `m = 2`: the countdown rises by `2`
and the register by `1`, in the same direction.

This is exactly the pair `kappa_collision_two_regimes_refuted_of_pend_gap` pins as surviving
regime restriction and as reached by NO landed inclusion in either direction. It is now reached,
in both directions, by `cellAt_subset_of_free_register_shift_of_pend_past` (upward, with no
forward slack) and `cellAt_subset_of_free_register_shift_of_pend_past_rev` (downward, under
forward-slack witnessing at the higher pair). So the dispatched slice is not a restatement of
the landed coverage: it strictly extends it into branch 3. -/
theorem kappa_collision_monotone_saturated_gap_nonvacuous :
    ∃ Tc Tn P B c n c' n' : ℕ, 2 ≤ B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      n + 2 ≤ c ∧ n' + 2 ≤ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧
      MonotoneCollisionDisplacement P c n c' n' ∧ n ≠ n' ∧
      ¬ ∃ m : ℕ, (c' = c + m * (P + 1) ∧ n' = n + m * (P + 1)) ∨
        (c = c' + m * (P + 1) ∧ n = n' + m * (P + 1)) := by
  refine ⟨0, 0, 0, 2, 2, 0, 4, 1, by omega, by decide, by omega, by omega, by omega, by omega,
    ?_, by omega, ?_⟩
  · exact Or.inl ⟨2, by omega, by omega⟩
  · rintro ⟨m, ⟨h1, h2⟩ | ⟨h1, h2⟩⟩ <;> omega

/-- **THE EXCLUDED ANTITONE SET IS NON-EMPTY INSIDE THE REGIME.** At `Tc = Tn = P = 0` and
`B = 2` the pairs `(4, 2)` and `(6, 0)` collide inside the pending-forever regime at countdowns
above the threshold (`2 + 2 ≤ 4`, `0 + 2 ≤ 6`, `0 ≤ 4`, `0 ≤ 6`) and are NOT monotone: the
countdown rises by `2` from the first pair to the second while the register FALLS by `2`, and the
mirror displacement `4 = 6 + m` has no solution.

What this record is for. The exclusion `CellLEZeroConstOfKappaEqMonotoneForwardSlack` carries is
therefore a genuine restriction and not a vacuous one — there are collisions it declines to
dispatch, and they survive the same regime restriction the monotone witness above does. Nothing
here claims the antitone residue is UNREACHABLE: the route it would need is named, and claimed in
neither direction, in `free_register_anchor_clause_monotone_required`'s docstring — forward-slack
witnessing at the LOWER pair, to pay the upper direction of the anchor clause that record
compiles as failing. -/
theorem kappa_collision_antitone_residue_nonvacuous :
    ∃ Tc Tn P B c n c' n' : ℕ, 2 ≤ B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      n + 2 ≤ c ∧ n' + 2 ≤ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧
      ¬ MonotoneCollisionDisplacement P c n c' n' := by
  refine ⟨0, 0, 0, 2, 4, 2, 6, 0, by omega, by decide, by omega, by omega, by omega, by omega,
    ?_⟩
  rintro (⟨m, h1, h2⟩ | ⟨m, h1, h2⟩) <;> omega

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

/-- **THE WITNESSING CONDITION IS A CONDITION ON REGION LENGTHS.** `HasForwardSlack` is
EQUIVALENT to a bound on the countdown of the first region start above `z`'s region
(`hasForwardSlack_iff_next_region_cnt_le`), so the witnessing condition — the existential over
paths — restates as: every type the cell at `x` realizes is realized there by some path whose
FIRST REGION ABOVE `z`'s region has countdown at most `n + cntAt g z + I - l`, where `I` is the
length of the idle run separating the two regions. Nothing about the register survives on the
right; the condition is about the walk's region lengths and nothing else.

**What this buys**: the hypothesis becomes checkable. A consumer holding a concrete object and
path can read off the next region's countdown and decide the condition, whereas
`HasForwardSlack`'s register clause at `z + cntAt g z + I` reads a derived quantity.

**What this does NOT buy, and must not be read as.** This is NOT a discharge. The condition is
still a hypothesis a consumer supplies, and the following three restrictions survive untouched:

* the reserved schema `cellLE_zero_const_of_kappa_eq` quantifies over EVERY `kappa`-collision,
  while every landed depth-`0` cell-equality inclusion carries the pending-forever gap
  `n + 2 ≤ c`, which by `pend_past_of_nxtAt_lt` restricts to paths pending at every earlier
  position. The reserved name stays claimed by nothing;
* the ORDINARY WINDOW REGIME `c ≤ n + 1` is addressed by no landed inclusion, in either
  direction;
* the ROOM BOUNDS the landed schemas carry — the monotone one's bound on the upper pair plus that
  pair's own gap, the common-shift one's DOUBLED displacement with a correspondingly doubled
  bound — remain, and are implied by neither the pending-forever gap nor this restatement. -/
theorem forwardSlackWitnessed_iff_next_region_cnt_le {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (x : LadderState Q pend) (z : ℤ) (l n : ℕ) :
    ForwardSlackWitnessed step pend fwd bwd lab φ x z l n ↔
      ∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z,
        ∃ (g : ℤ → LadderState Q pend)
          (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
          IsLadderPath step pend g ∧ g z = x ∧ (∀ t : ℤ, τ.state t = (t, g t)) ∧
          (∀ I : ℕ, 0 < I →
            (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
            pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
            (cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) : ℤ)
              ≤ (n : ℤ) + cntAt g z + I - l) ∧
          tpOf (ladderModel step pend fwd bwd lab) φ τ z = T := by
  constructor
  · intro h T hT
    obtain ⟨g, τ, hg, hgz, hτ, hs, htp⟩ := h T hT
    exact ⟨g, τ, hg, hgz, hτ,
      (hasForwardSlack_iff_next_region_cnt_le g hg z l n).mp hs, htp⟩
  · intro h T hT
    obtain ⟨g, τ, hg, hgz, hτ, hb, htp⟩ := h T hT
    exact ⟨g, τ, hg, hgz, hτ,
      (hasForwardSlack_iff_next_region_cnt_le g hg z l n).mpr hb, htp⟩

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
/-- **THE DOWNWARD CELL INCLUSION ON THE WITNESSING PATH, for the FREE REGISTER.** The mirror of
`cellAt_subset_of_free_register_shift_of_pend_past`, and the second half of what closes the
MONOTONE residue of `kappa_collision_regimes`' third branch. In the pending-forever regime at
countdown at least `Tc`, every type realized at `(q, c + m · (P + 1), n')` BY A PATH `g`
satisfying `HasForwardSlack g z (m · (P + 1) + (n' − n)) n'` is realized at `(q, c, n)`, for every
`n'` with `n ≤ n'`. The body is `LadderChain.lean`'s register-LOWERING deletion
`exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` at `n₀ := n` and
`k := n' − n`.

**The slack amount and the room bound.** The deletion pays `m · (P + 1)` for the countdown and a
further `k = n' − n` for lowering the anchor from `nxtAt g z = n'` to `n`; those are the two
summands of `m · (P + 1) + (n' − n)`, not a loose bound, and `hroom : n' + (n' − n) ≤ c` is the
room that purchase needs. Both SPECIALIZE to the landed statements:

| sub-regime | `n'` | room bound | slack amount |
|---|---|---|---|
| equal register | `n` | `n ≤ c` (from `hgap`) | `m · (P + 1)` |
| common shift | `n + m · (P + 1)` | `n + 2 · m · (P + 1) ≤ c` | `m · (P + 1) + m · (P + 1)` |
| monotone residue | any `n'`, `n ≤ n'` | `n' + (n' − n) ≤ c` | `m · (P + 1) + (n' − n)` |

Row 3 at `n' = n` is row 1 and at `n' = n + m · (P + 1)` is row 2, hypothesis for hypothesis.

**Why `hgap'` is a named hypothesis here and is not one in the common-shift mirror.** The
`pend_past_of_nxtAt_lt` input needs the register at `z` to sit strictly below the countdown at
`z`, i.e. `n' < c + m · (P + 1)`. Where the register's displacement EQUALS the countdown's, that
follows from the lower pair's `hgap`; with the register free it does not — at `m = 0` the lower
gap `n + 2 ≤ c` says nothing about `n'`. So `hgap'` is carried. None of `hgap`, `hgap'`, `hroom`
implies another: `hroom` is the only one that can fail at `n' = n`, `hgap'` the only one that
constrains `n'` against the raised countdown, and `hgap` the only one that survives `m = 0` with
`n' = n`.

The statement is on the WITNESSING PATH, not on the state, for the compiled reason
`ClimbWitness.hasForwardSlack_refuted_unconditional` gives: `cellAt` quantifies over every path
through the state, and that refutation exhibits a path through a state satisfying every
state-level hypothesis a consumer carries and violating the regime. The state-level form is
`cellAt_subset_of_free_register_shift_of_pend_past_rev` below, under `ForwardSlackWitnessed`. -/
theorem mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hgap' : n' + 2 ≤ c + m * (P + 1)) (hlo : n ≤ n')
    (hroom : n' + (n' - n) ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n'), h'⟩)
    (hslack : HasForwardSlack g z (m * (P + 1) + (n' - n)) n')
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  classical
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c + m * (P + 1) := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n' := by simp [nxtAt, hgz]
  have hz : pend (objAt g z) = true := by
    by_contra hne
    rw [Bool.not_eq_true, hoz] at hne
    have := h hne
    omega
  have hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; omega)
  obtain ⟨g', hg', ho, hc, hn, hty⟩ :=
    exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g hg z hpast m n (n' - n) (by rw [hnz]; omega) (by rw [hcz]; omega)
      (by rw [hcz, hnz]; omega) (by rw [hnz]; exact hslack)
  have hc' : cntAt g' z = c := by omega
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  rw [mem_cellAt_ladder_iff]
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c, n)
    rw [ho, hc', hn, hoz]
  · exact hty τ τ' hτ hτ'

/-- **THE FREE-REGISTER DOWNWARD CELL INCLUSION AT THE STATE LEVEL.** The free-register mirror of
`cellAt_subset_of_common_shift_of_pend_past_rev`: in the pending-forever regime at countdown at
least `Tc`, with the room `n' + (n' − n) ≤ c` and the higher pair's own gap
`n' + 2 ≤ c + m · (P + 1)`, if every type the cell at `(q, c + m · (P + 1), n')` realizes is
realized there by a path with `HasForwardSlack · z (m · (P + 1) + (n' − n)) n'`, then that cell is
contained in the cell at `(q, c, n)`. The body is
`mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact` applied to the witnessing path the
hypothesis supplies.

The witnessing hypothesis is NOT removable, for the same compiled reason as in both landed
mirrors: `ClimbWitness.hasForwardSlack_refuted_unconditional` refutes every state-level form of
the regime, so the condition must stay existential over the paths through the state — the regime
is a property of the PATH, never of the state. What is new here is that the register moves by an
amount the COUNTDOWN NEED NOT MATCH: the landed equal-register mirror holds it, the landed
common-shift mirror moves it by exactly the countdown's displacement. Together with the upward
`cellAt_subset_of_free_register_shift_of_pend_past` this closes the MONOTONE residue of branch 3
in both directions. The ANTITONE residue is excluded, not closed — see
`MonotoneCollisionDisplacement` and `kappa_collision_antitone_residue_nonvacuous`. -/
theorem cellAt_subset_of_free_register_shift_of_pend_past_rev {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hgap' : n' + 2 ≤ c + m * (P + 1)) (hlo : n ≤ n')
    (hroom : n' + (n' - n) ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n'), h'⟩ : LadderState Q pend) z
      (m * (P + 1) + (n' - n)) n') :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, hslack, hty⟩ := hw T hT
  have hmem := mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact step pend fwd bwd lab φ
    Tc Tn P B hp hno q c n h m n' h' hgap hgap' hlo hroom hTc z g hg hgz hslack τ hτ
  rwa [hty] at hmem

/-- **THE UPWARD ANTITONE CELL INCLUSION.** The countdown UP by `m · (P + 1)` and the register
DOWN — the exact move the landed free-register raise excludes, and the direction
`free_register_anchor_clause_monotone_required` compiles as unpayable from the facts that raise
has in hand. In the pending-forever regime (`n + 2 ≤ c`) at countdown at least `Tc`, with
`n' < n`, the cell at `(q, c, n)` is contained in the cell at `(q, c + m · (P + 1), n')` under
forward-slack witnessing at the LOWER pair.

**The amount, in words.** `(n − n') − m · (P + 1)`, truncated in `ℕ`: the register's descent
BEYOND what the raise already buys. The raise widens `z`'s own region by exactly `m · (P + 1)`,
and `exists_ladderPath_through_free_register_shifted_slack_of_pend_past`'s relaxed lower bound
spends that widening on the anchor's upper direction for free; only a descent exceeding it needs
paying. By `kappa_collision_antitone_descent_multiple` the descent is itself a multiple
`j · (P + 1)`, so the comparison is `j` against `m`.

**On the BOUNDED sub-slice the amount is `0`, and an amount-`0` obligation is FREE.** When
`n − n' ≤ m · (P + 1)` the truncated amount is literally `0`, and `forwardSlackWitnessed_zero`
discharges the hypothesis outright — which is what
`cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` spends. The predecessor's own
non-vacuity witness `(4, 2)` against `(6, 0)` lies in that half
(`kappa_collision_antitone_bounded_descent_nonvacuous`). The DEEP-DESCENT residue is where the
hypothesis does real work, and it is non-empty too
(`kappa_collision_antitone_deep_descent_nonvacuous`).

**No room bound.** Unlike the monotone downward half, which carries `n' + (n' − n) ≤ c`, this
inclusion carries nothing beyond the lower pair's own gap: the upper bound `n' ≤ c + m · (P + 1)`
the raise needs follows from `n' < n` and `n + 2 ≤ c` by `omega`.

The witnessing hypothesis is one a CONSUMER supplies. Nothing here discharges
`ForwardSlackWitnessed` in general — whether such a hypothesis is satisfiable at any state the
induction one layer up reaches is a separate question this declaration does not touch. The
reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing here. -/
theorem cellAt_subset_of_antitone_register_shift_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (hlt : n' < n) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c, n), h⟩ : LadderState Q pend) z (n - n' - m * (P + 1)) n) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  classical
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, hslack, hty⟩ := hw T hT
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n := by simp [nxtAt, hgz]
  have hz : pend (objAt g z) = true := by
    by_contra hne
    rw [Bool.not_eq_true, hoz] at hne
    have := h hne
    omega
  have hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; omega)
  obtain ⟨g', hg', ho, hc, hn, hty'⟩ :=
    exists_ladderPath_through_free_register_shifted_slack_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g hg z hpast (by rw [hcz, hnz]; exact hgap) (by rw [hcz]; exact hTc)
      m n' (n - n' - m * (P + 1)) (by rw [hnz]; exact hslack) (by rw [hnz]; omega)
      (by rw [hcz]; omega)
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  rw [← hty, mem_cellAt_ladder_iff]
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c + m * (P + 1), n')
    rw [ho, hc, hn, hoz, hcz]
  · exact hty' τ τ' hτ hτ'

/-- **THE DOWNWARD ANTITONE CELL INCLUSION.** The countdown DOWN by `m · (P + 1)` and the register
UP — the mirror of `cellAt_subset_of_antitone_register_shift_of_pend_past`. In the
pending-forever regime (`n + 2 ≤ c`) at countdown at least `Tc`, with `n' < n`, the cell at
`(q, c + m · (P + 1), n')` is contained in the cell at `(q, c, n)` under forward-slack witnessing
at the HIGHER pair, at amount `m · (P + 1)` — the countdown displacement ALONE — and NO room
bound.

**The comparison with the monotone downward half, which is the point.**
`cellAt_subset_of_free_register_shift_of_pend_past_rev` spends `m · (P + 1) + (n' − n)` and
carries a room bound `n' + (n' − n) ≤ c`, because it LOWERS the target register and a lowering is
charged for in the upper direction of the single anchor inequality. This inclusion RAISES the
target register, and a raise is free in exactly that direction: the amount stays at the
held-register `m · (P + 1)` and the only room condition
`exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` asks —
`n + 2 + m · (P + 1) ≤ cntAt g z` — is the LOWER pair's own pending-forever gap `n + 2 ≤ c` and
nothing more, since `cntAt g z = c + m · (P + 1)` here. So the antitone direction is strictly
CHEAPER downward than the monotone one, which is the opposite of what the upward halves'
asymmetry suggests.

The witnessing hypothesis is one a CONSUMER supplies, and it sits on the PATHS through the higher
state, never on the state — `ClimbWitness.hasForwardSlack_refuted_unconditional` refutes every
state-level form. Nothing here discharges `ForwardSlackWitnessed` in general. The reserved name
`cellLE_zero_const_of_kappa_eq` is claimed by nothing here. -/
theorem cellAt_subset_of_antitone_register_shift_of_pend_past_rev
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (hlt : n' < n) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n'), h'⟩ : LadderState Q pend) z (m * (P + 1)) n') :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  classical
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, hslack, hty⟩ := hw T hT
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c + m * (P + 1) := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n' := by simp [nxtAt, hgz]
  have hz : pend (objAt g z) = true := by
    by_contra hne
    rw [Bool.not_eq_true, hoz] at hne
    have := h hne
    omega
  have hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; omega)
  obtain ⟨g', hg', ho, hc, hn, hty'⟩ :=
    exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g hg z hpast m n (by rw [hnz]; omega) (by rw [hcz]; omega)
      (by rw [hcz]; omega) (by rw [hnz]; exact hslack)
  have hc' : cntAt g' z = c := by omega
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  rw [← hty, mem_cellAt_ladder_iff]
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c, n)
    rw [ho, hc', hn, hoz]
  · exact hty' τ τ' hτ hτ'

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

/-- **THE MONOTONE DEPTH-`0` CELL OBLIGATION, WITH THE ANTITONE RESIDUE EXCLUDED IN THE
SIGNATURE**, stated as a schema. This is NOT the reserved statement `CellLEZeroConstOfKappaEq`,
which is claimed by nothing and stays so. Five hypotheses separate the two, and all five are
visible in the quantifier below:

1. the MONOTONE displacement `MonotoneCollisionDisplacement P c n c' n'` — the countdown and the
   register displaced in the SAME direction;
2. the pending-forever gap `n + 2 ≤ c` and `n' + 2 ≤ c'`, at BOTH pairs;
3. the threshold bounds `Tc ≤ c` and `Tc ≤ c'`, at both pairs;
4. the room bound on whichever pair carries the LOWER countdown — `n' + (n' − n) ≤ c` upward,
   `n + (n − n') ≤ c'` downward;
5. the forward-slack witnessing of whichever pair carries the HIGHER countdown, at the amount
   `m · (P + 1) + (n' − n)` (respectively `m · (P + 1) + (n − n')`) the register-lowering
   deletion actually spends.

Hypotheses 4 and 5 live inside the same clause because `m` is existentially bound by hypothesis 1
and cannot be named outside a clause that quantifies it.

**WHAT HYPOTHESIS 1 TRADES, AND WHAT IT SPECIALIZES TO.** The two landed schemas carry,
respectively, the equal-register restriction `n = n'` and the common-shift displacement; this one
carries neither, and the monotone shape stands in their place. Its hypotheses SPECIALIZE to both:

Write `mP` for `m · (P + 1)` and `d` for the register's own displacement.

| sub-regime | `n'` | room bound | slack amount |
|---|---|---|---|
| equal register | `n` | `n ≤ c` (from the gap) | `mP`, with `d = 0` |
| common shift | `n + mP` | `n + 2 · mP ≤ c` | `mP + mP`, with `d = mP` |
| monotone | any `n'`, `n ≤ n'` | `n' + (n' − n) ≤ c` | `mP + d`, with `d = n' − n` |

Row 3 at `n' = n` is row 1 hypothesis for hypothesis, and at `n' = n + m · (P + 1)` it is row 2.
NEITHER LANDED SCHEMA IS RETIRED and neither signature is touched:
`CellLEZeroConstOfKappaEqForwardSlack` and `CellLEZeroConstOfKappaEqCommonShiftForwardSlack` both
stand exactly as they were, and the specialization above is a statement about hypotheses, not a
subsumption claim about declarations.

**THE EXCLUSION, STATED RATHER THAN TACIT.** The ANTITONE residue — the negation of hypothesis 1,
a collision whose register moves OPPOSITE to its countdown — is excluded. It is not left as an
unexamined remainder, and three compiled records are what make that so:

* `kappa_collision_monotone_or_antitone`: the excluded set is exactly the other side of an
  EXHAUSTIVE dichotomy over collisions, so no third case is hiding between them;
* `kappa_collision_antitone_residue_nonvacuous`: the excluded set is NON-EMPTY inside the
  pending-forever regime above the threshold (`(4, 2)` against `(6, 0)` at `Tc = Tn = P = 0`,
  `B = 2`), so the exclusion is a genuine restriction;
* `kappa_collision_monotone_saturated_gap_nonvacuous`: the DISPATCHED side genuinely reaches
  branch 3 of `kappa_collision_regimes` (`(2, 0)` against `(4, 1)`, the pair
  `kappa_collision_two_regimes_refuted_of_pend_gap` pins as reached by no landed inclusion), so
  the trade is not a relabelling of the landed coverage.

Nothing here claims the antitone residue is unreachable. The route it would need is NAMED and
claimed in neither direction: forward-slack witnessing at the LOWER pair, to pay the upper
direction of the anchor clause `free_register_anchor_clause_monotone_required` compiles as
failing without the lower bound on the free anchor.

WHAT A CONSUMER MUST SUPPLY. At each state it inducts through, the induction one layer up must
exhibit (i) the monotone displacement across the collision, (ii) the room bound at the lower
pair, and (iii) a forward-slack witness at the higher state: for each type in that state's cell,
a ladder path through it realizing that type whose first region start above `z`'s region leaves
the stated amount of room in the anchor clause. None of the three is a consequence of `ParamsOk`.

The unrestricted schema `CellLEZeroConstOfKappaEq` is, under `ParamsOk`, NEITHER PROVED NOR
REFUTED, and this schema does not change that: it is strictly stronger in hypotheses, so it bears
on the reserved statement's truth value in NEITHER DIRECTION. The reserved name
`cellLE_zero_const_of_kappa_eq` is claimed by nothing here. -/
def CellLEZeroConstOfKappaEqMonotoneForwardSlack {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      MonotoneCollisionDisplacement P c n c' n' →
      n + 2 ≤ c → n' + 2 ≤ c' → Tc ≤ c → Tc ≤ c' →
      (∀ m : ℕ, c' = c + m * (P + 1) → n ≤ n' →
        n' + (n' - n) ≤ c ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c', n'), h'⟩ : LadderState Q pend) z (m * (P + 1) + (n' - n)) n') →
      (∀ m : ℕ, c = c' + m * (P + 1) → n' ≤ n →
        n + (n - n') ≤ c' ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c, n), h⟩ : LadderState Q pend) z (m * (P + 1) + (n - n')) n) →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

/-- **THE MONOTONE OBLIGATION IS A THEOREM.** The schema above holds at every parameter tuple
`ParamsOk` admits, as cell EQUALITY. Each direction of the monotone displacement is closed by
`Set.Subset.antisymm` against the two free-register inclusions: upward by
`cellAt_subset_of_free_register_shift_of_pend_past` (no forward slack — the widened window pays
for the anchor), downward by `cellAt_subset_of_free_register_shift_of_pend_past_rev`, whose
register-lowering deletion at `k := n' − n` is the whole of what this schema adds over the two
landed ones. The upward inclusion's remaining bound `n' ≤ c + m · (P + 1)` is DERIVED inside the
proof from the higher pair's own gap by `omega`, which is why it does not appear in the
quantifier.

The collision equality itself is not consumed: the displacement comes from the explicit monotone
hypothesis, not from `kappa_eq_components`. It is retained as a binder — discarded at `intro`
with a `_` pattern, exactly as `cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack` does,
so no unused local is created — so that the schema's shape matches both landed schemas' and a
consumer reading the three side by side sees exactly one hypothesis traded for another.

The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing here. -/
theorem cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEqMonotoneForwardSlack step pend fwd bwd lab φ Tc Tn P B := by
  intro hp hno q c n c' n' h h' z _ hmono hgap hgap' hTc hTc' hwup hwdn
  rcases hmono with ⟨m, hc', hle⟩ | ⟨m, hc, hle⟩
  · -- `(c', n')` is the higher pair: up with no slack, down through the witnessing hypothesis
    subst hc'
    obtain ⟨hroom, hwit⟩ := hwup m rfl hle
    exact Set.Subset.antisymm
      (cellAt_subset_of_free_register_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno
        q c n h m n' h' hgap hTc hle (by omega) z)
      (cellAt_subset_of_free_register_shift_of_pend_past_rev step pend fwd bwd lab φ Tc Tn P B
        hp hno q c n h m n' h' hgap hgap' hle hroom hTc z hwit)
  · -- `(c, n)` is the higher pair: the same two inclusions with the roles swapped
    subst hc
    obtain ⟨hroom, hwit⟩ := hwdn m rfl hle
    exact Set.Subset.antisymm
      (cellAt_subset_of_free_register_shift_of_pend_past_rev step pend fwd bwd lab φ Tc Tn P B
        hp hno q c' n' h' m n h hgap' hgap hle hroom hTc' z hwit)
      (cellAt_subset_of_free_register_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno
        q c' n' h' m n h hgap' hTc' hle (by omega) z)

/-- **AN AMOUNT-`0` WITNESSING OBLIGATION IS FREE.** `ForwardSlackWitnessed … z 0 n` is a THEOREM,
not a hypothesis, at every state and every position: a path realizing a type in the cell is
supplied by `mem_cellAt_ladder_iff` itself, and `hasForwardSlack_zero` gives that path the regime
at amount `0` from its being a ladder path and nothing else (the register's two-sided Lipschitz
bound is the whole of the argument).

**WHAT THIS DOES NOT SETTLE.** Discharging the amount-`0` case settles NOTHING about the general
`ForwardSlackWitnessed` discharge — whether such a hypothesis is satisfiable, at a positive
amount, at any state the ladder-realization induction one layer up actually reaches. That
question is out of this module's scope and is not answered here. The amount-`0` case is free
because it is free, not because the general question has been resolved; every other
`ForwardSlackWitnessed` hypothesis in this module remains one a CONSUMER supplies.

Its one use here is `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack`, where the
truncated upward amount `(n − n') − m · (P + 1)` is literally `0` on the bounded sub-slice. -/
theorem forwardSlackWitnessed_zero {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (z : ℤ) :
    ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c, n), h⟩ : LadderState Q pend) z 0 n := by
  intro T hT
  rw [mem_cellAt_ladder_iff] at hT
  obtain ⟨g, τ, hg, hgz, hτ, hty⟩ := hT
  have hnz : nxtAt g z = n := by simp [nxtAt, hgz]
  refine ⟨g, τ, hg, hgz, hτ, ?_, hty⟩
  have := hasForwardSlack_zero g hg z
  rwa [hnz] at this

/-- **THE ANTITONE DEPTH-`0` CELL OBLIGATION**, stated as a schema. The complement of
`CellLEZeroConstOfKappaEqMonotoneForwardSlack`, dispatched rather than excluded. Together with
that schema it covers EVERY collision, by `kappa_collision_monotone_or_antitone_named`: the two
displacement predicates are an exhaustive dichotomy with no third case.

This is NOT the reserved statement `CellLEZeroConstOfKappaEq`, which is claimed by nothing and
stays so. This schema is strictly stronger in hypotheses than the reserved statement and
therefore bears on its truth value in NEITHER DIRECTION.

**The two payments, one per direction, and NO room bound.** For each orientation of the antitone
disjunction the schema asks for two witnessing hypotheses:

| direction | at which pair | amount |
|---|---|---|
| countdown UP, register DOWN | the LOWER pair | `(n − n') − m · (P + 1)`, truncated in `ℕ` |
| countdown DOWN, register UP | the HIGHER pair | `m · (P + 1)` |

The upward amount is the register's descent BEYOND what the raise already buys; the downward
amount is the countdown displacement alone. Neither direction carries a room bound. Contrast the
monotone schema, whose downward direction spends `m · (P + 1) + (n' − n)` under
`n' + (n' − n) ≤ c`: a register RAISE is free in the direction the single anchor inequality
charges for, and the antitone downward half raises where the monotone one lowers. The upward
bound `n' ≤ c + m · (P + 1)` is DERIVED inside the proof from `n' < n` and the lower pair's gap,
which is why it does not appear in the quantifier.

**WHAT A CONSUMER MUST SUPPLY**, itemized per direction. At each state the induction one layer up
inducts through, it must exhibit:

1. the antitone displacement across the collision (`AntitoneCollisionDisplacement`), which
   `kappa_collision_monotone_or_antitone_named` supplies as the complement of the monotone case;
2. UPWARD: for each type in the LOWER pair's cell, a ladder path through that state realizing it
   whose first region start above `z`'s region leaves `(n − n') − m · (P + 1)` of room in the
   anchor clause;
3. DOWNWARD: the same at the HIGHER pair, at amount `m · (P + 1)`.

NONE of 1-3 is a consequence of `ParamsOk`. Item 2 is FREE whenever the descent does not exceed
`m · (P + 1)` — the amount is then `0` and `forwardSlackWitnessed_zero` discharges it — which is
the whole content of `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack`. Item 3 is
never free.

The collision equality is retained as a binder and discarded at `intro` with a `_` pattern, as in
both landed schemas: the displacement comes from the explicit antitone hypothesis, not from
`kappa_eq_components`. The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing
here. -/
def CellLEZeroConstOfKappaEqAntitoneForwardSlack {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      AntitoneCollisionDisplacement P c n c' n' →
      n + 2 ≤ c → n' + 2 ≤ c' → Tc ≤ c → Tc ≤ c' →
      (∀ m : ℕ, c' = c + m * (P + 1) → n' < n →
        ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c, n), h⟩ : LadderState Q pend) z (n - n' - m * (P + 1)) n ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c', n'), h'⟩ : LadderState Q pend) z (m * (P + 1)) n') →
      (∀ m : ℕ, c = c' + m * (P + 1) → n < n' →
        ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c', n'), h'⟩ : LadderState Q pend) z (n' - n - m * (P + 1)) n' ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c, n), h⟩ : LadderState Q pend) z (m * (P + 1)) n) →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

/-- **THE ANTITONE OBLIGATION IS A THEOREM.** The schema above holds at every parameter tuple
`ParamsOk` admits, as cell EQUALITY. With the monotone theorem beside it, the DICHOTOMY of
`kappa_collision_monotone_or_antitone_named` is now dispatched on BOTH sides: every collision in
the pending-forever regime above the threshold is covered by one of the two schemas, and the
excluded antitone residue the monotone schema's quantifier names is excluded there and dispatched
here.

Both orientations of the antitone disjunction close by `Set.Subset.antisymm` against the SAME two
inclusions — `cellAt_subset_of_antitone_register_shift_of_pend_past` upward and
`cellAt_subset_of_antitone_register_shift_of_pend_past_rev` downward — with the roles of the two
pairs swapped, exactly as the monotone theorem handles its own two branches. Cell equality is
symmetric, so the second orientation needs no third inclusion.

Neither landed schema is retired and no landed signature is touched. The reserved name
`cellLE_zero_const_of_kappa_eq` is claimed by nothing here, and this schema — strictly stronger
in hypotheses than the reserved statement — bears on its truth value in NEITHER direction. -/
theorem cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEqAntitoneForwardSlack step pend fwd bwd lab φ Tc Tn P B := by
  intro hp hno q c n c' n' h h' z _ hanti hgap hgap' hTc hTc' hwup hwdn
  rcases hanti with ⟨m, hc', hlt⟩ | ⟨m, hc, hlt⟩
  · -- `(c', n')` is the higher pair: `(c, n)` is the lower one and pays the truncated amount
    subst hc'
    obtain ⟨hwu, hwd⟩ := hwup m rfl hlt
    exact Set.Subset.antisymm
      (cellAt_subset_of_antitone_register_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B
        hp hno q c n h m n' h' hgap hTc hlt z hwu)
      (cellAt_subset_of_antitone_register_shift_of_pend_past_rev step pend fwd bwd lab φ
        Tc Tn P B hp hno q c n h m n' h' hgap hTc hlt z hwd)
  · -- `(c, n)` is the higher pair: the same two inclusions with the roles swapped
    subst hc
    obtain ⟨hwu, hwd⟩ := hwdn m rfl hlt
    exact Set.Subset.antisymm
      (cellAt_subset_of_antitone_register_shift_of_pend_past_rev step pend fwd bwd lab φ
        Tc Tn P B hp hno q c' n' h' m n h hgap' hTc' hlt z hwd)
      (cellAt_subset_of_antitone_register_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B
        hp hno q c' n' h' m n h hgap' hTc' hlt z hwu)

/-- **THE BOUNDED SUB-SLICE, WITH NO UPWARD HYPOTHESIS AT ALL.** When the register's descent does
not exceed the countdown's displacement (`n − n' ≤ m · (P + 1)`), the antitone slice is dispatched
as depth-`0` cell EQUALITY carrying exactly ONE witnessing hypothesis — the downward one, at the
higher pair, at amount `m · (P + 1)` — and NONE upward.

**Why the upward half is free here.** The truncated amount `(n − n') − m · (P + 1)` is literally
`0` in `ℕ` under `hbounded`, and `forwardSlackWitnessed_zero` discharges an amount-`0` obligation
outright. So the raise's own `m · (P + 1)` of bought slack pays the whole upward direction on this
sub-slice, from no hypothesis whatever. Nothing is weakened to get this: it is
`cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack`'s first orientation with one of its two
hypotheses proved instead of assumed.

**The predecessor's own non-vacuity witness lies in this half.**
`kappa_collision_antitone_residue_nonvacuous` inhabits the excluded antitone slice at `(4, 2)`
against `(6, 0)` with `Tc = Tn = P = 0`, `B = 2`; there `m = 2` and the descent is exactly
`2 = m · (P + 1)`, so `hbounded` holds —
`kappa_collision_antitone_bounded_descent_nonvacuous` records precisely that. The compiled
demonstration that the excluded slice was non-empty was, all along, a demonstration about its
cheaper half.

The bounded sub-slice does NOT exhaust the slice:
`kappa_collision_antitone_deep_descent_nonvacuous` inhabits the complement, where the general
schema's upward hypothesis is doing real work. The reserved name
`cellLE_zero_const_of_kappa_eq` is claimed by nothing here, and this statement — strictly
stronger in hypotheses than the reserved one — bears on its truth value in NEITHER direction. -/
theorem cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (hlt : n' < n)
    (hbounded : n - n' ≤ m * (P + 1)) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n'), h'⟩ : LadderState Q pend) z (m * (P + 1)) n') :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
      = cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
            (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  have hzero : n - n' - m * (P + 1) = 0 := by omega
  refine Set.Subset.antisymm
    (cellAt_subset_of_antitone_register_shift_of_pend_past step pend fwd bwd lab φ Tc Tn P B
      hp hno q c n h m n' h' hgap hTc hlt z ?_)
    (cellAt_subset_of_antitone_register_shift_of_pend_past_rev step pend fwd bwd lab φ
      Tc Tn P B hp hno q c n h m n' h' hgap hTc hlt z hw)
  rw [hzero]
  exact forwardSlackWitnessed_zero step pend fwd bwd lab φ q c n h z

end ForwardSlack

/-! ## The iterated splice's two interior clauses: the countdown landed, the register refuted

`exists_iterSpliced_ladderPath_idx_of_pend_past` (`LadderChain.lean`) exposes FOUR clauses — the
object at every position, the countdown raised by `d · l` below the window, the countdown
displaced above the run, and the stab-free realized type at every position. It exposes NO
countdown value at a position INSIDE the run of copies, and no register value anywhere; the
register-held wrapper `exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` exposes the
register at the single anchor `z` and nowhere else. The two readings a position-pair induction on
the pump's own window needs are therefore both absent from the landed surface. This section lands
the first of them and REFUTES the second, as siblings that leave every landed statement
byte-identical: neither parent, nor `iterSpliceIdx`, nor any of its characterization lemmas is
touched here.

LANDED — the interior-copy countdown.
`exists_iterSpliced_ladderPath_idx_interior_of_pend_past` carries its parent's four clauses and
adds, for `i ≤ d` and `j < l`,

  `cntAt g' (u + i · l + j) = cntAt g (u + j) + (d − i) · l`,

at exactly the positions `iterSpliceIdx_add_mul` retracts to `u + j`. The pending countdown at a
copy position is the original's at the retracted position plus the `(d − i) · l` positions of
copies still above it, and `i = d` recovers the parent's own value at the top copy. The proof is
the parent's induction on `d` with the clause carried through it — the clause is NOT derived from
the parent, because the parent's existential exposes no interior countdown to derive from. One
call delivers all five clauses, so a consumer needs no second call.

REFUTED — the register at the interior. The companion clause
`nxtAt g' (u + i · l + j) = nxtAt g (u + j)` is not a true statement of this construction at any
`d ≥ 1` with `l ≥ 3`, and what refutes it is the ladder's own drift condition, not a limitation of
some proof route. `iterSpliced_register_interior_forces_block_drift` derives from the clause at
`i ≤ 1` alone that `Drift (nxtAt g (u + (l − 1))) (nxtAt g u)` — the original's register at the
block's last position is within one of its value at the block's first, because the clause makes
the step from the top of copy `0` to the bottom of copy `1` a step of `g'` between those two
values. `iterSpliced_register_interior_refuted` exhibits a ladder path on which that fails while
EVERY hypothesis of the parent holds — `0 < l`, `l ≤ cntAt g u`, the uniformly pending past, the
object-closed block, a history over the path, the realized-type equality at the block's ends, and
the stab-free closure condition — so no `g'` whatever satisfies the register clause there, however
the register is rebuilt.

Which of the two readings of "the register is held at the interior" is the true one: NEITHER. The
walk does not determine it — `Count` constrains the register only at a region start
(`count_ft`: `c' = n`), and a block of a pending-forever past carries no region start at all, so
the register's only constraint inside the window is `Drift`. And the re-lift does not pin it —
`exists_ladderPath_of_walk_nxt` pins the register at the single position `0`,
`exists_ladderPath_of_walk_nxt_at` at the single position `z`, and
`exists_ladderPath_of_walk_of_pins` at none; the McShane extension `drift_extension_of_pins`
builds the rest from the NEW path's pins, which inside the run are the original's own pins
displaced by `d · l`, and its value at an interior position is a `sInf` over those and not the
original's value. Phase 11.20 needs this answer, and the answer is that the register coordinate of
the pump is uncontrolled at the interior.

**What the landed clause does NOT say.** It is a clause of the pump's own construction. It says
nothing about any `⊡` bit, nothing about the agreement of a cell at any pair of states, and
nothing about `kappa` or any of its coordinates. The interior positions it describes are exactly
the positions at which a `⊡` bit CAN differ between a copy pair when the displacement is
off-residue, which is the obstruction the stab-bit copy-pair fixture exhibits; the clause is
bookkeeping a position-pair induction consumes, never a step of one. -/

section IterInterior

/-- **THE ITERATED DUPLICATION WITH THE INTERIOR-COPY COUNTDOWN EXPOSED.** A sibling of
`exists_iterSpliced_ladderPath_idx_of_pend_past` carrying its four clauses and one more: the
countdown at position `j` of copy `i` is the original's countdown at the retracted position
`u + j` plus `(d − i) · l`, the positions of the copies still above it. The parent is untouched;
this is a re-run of its induction with the fifth clause carried, since the parent's existential
exposes no interior countdown from which the clause could be derived.

Why the value is what it is. At `i = 0` the position lies below `u + l`, inside the lengthened
region, so one splice raises it by `l` and the induction hypothesis has already raised it by
`d · l`. At `i = i' + 1` the position lies at or above `u + l`, so one splice reads the previous
stage `l` positions lower, which is position `j` of copy `i'` there. At `i = d` the clause
degenerates to the top copy's own value, which is the original's at `u + j`.

This says nothing about the register, which the construction does not hold at the interior
(`iterSpliced_register_interior_refuted`), and nothing about any `⊡` bit, cell or `kappa`
coordinate. -/
theorem exists_iterSpliced_ladderPath_idx_interior_of_pend_past {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u)
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      (∀ v : ℤ, v ≤ u → u ≤ v + (cntAt g v : ℤ) → cntAt g' v = cntAt g v + d * l) ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      (∀ i j : ℕ, i ≤ d → j < l →
        cntAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ)) = cntAt g (u + (j : ℤ)) + (d - i) * l) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := by
  classical
  haveI : Fintype Q := Fintype.ofFinite Q
  induction d with
  | zero =>
      refine ⟨g, hg, fun _ => rfl, fun v _ _ => by simp, fun v _ => by simp,
        fun i j hi hj => ?_, fun σ' hσ' w => ?_⟩
      · have hi0 : i = 0 := by omega
        subst hi0
        simp
      · exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ
          (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
          (fun _ => rfl) hno w
  | succ d ih =>
      obtain ⟨g₁, hg₁, hobj₁, hcnt₁, habove₁, hint₁, hty₁⟩ := ih
      have hidx_ul : objAt g (iterSpliceIdx u l d (u + (l : ℤ))) = objAt g u := by
        rcases d with _ | d
        · rw [iterSpliceIdx_zero]; exact hrep.symm
        · rw [show u + (l : ℤ) = u + ((1 * l : ℕ) : ℤ) by push_cast; ring,
            iterSpliceIdx_boundary u l hl (d + 1) 1 (by omega)]
      have hty_ul : tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d (u + (l : ℤ)))
          = tpOf (ladderModel step pend fwd bwd lab) φ σ u := by
        rcases d with _ | d
        · rw [iterSpliceIdx_zero]; exact hty.symm
        · rw [show u + (l : ℤ) = u + ((1 * l : ℕ) : ℤ) by push_cast; ring,
            iterSpliceIdx_boundary u l hl (d + 1) 1 (by omega)]
      have hpast₁ : ∀ p : ℤ, p ≤ u → pend (objAt g₁ p) = true := fun p hp => by
        rw [hobj₁ p, iterSpliceIdx_of_lt u l d p (by omega)]; exact hpast p hp
      have hrep₁ : objAt g₁ u = objAt g₁ (u + (l : ℤ)) := by
        rw [hobj₁ u, hobj₁ (u + (l : ℤ)), iterSpliceIdx_of_lt u l d u (by omega), hidx_ul]
      have hcu₁ : cntAt g₁ u = cntAt g u + d * l := hcnt₁ u le_rfl (by omega)
      have hcl₁ : l ≤ cntAt g₁ u := by rw [hcu₁]; omega
      obtain ⟨g₂, hg₂, hobj₂, hcnt₂⟩ :=
        exists_spliced_ladderPath_of_pend_past hg₁ hl hcl₁ hpast₁ hrep₁
      have hobj₂' : ∀ w : ℤ, objAt g₂ w = objAt g₁ (spliceIdx u l w) := fun w => by
        rw [hobj₂ w, spliceObj_eq_objAt_spliceIdx]
      refine ⟨g₂, hg₂, fun v => ?_, fun v hv hreg => ?_, fun v hv => ?_, fun i j hi hj => ?_,
        fun σ₂ hσ₂ w => ?_⟩
      · rw [hobj₂' v, hobj₁, iterSpliceIdx_succ]
      · have hreg₁ : u ≤ v + (cntAt g₁ v : ℤ) := by rw [hcnt₁ v hv hreg]; push_cast; omega
        rw [hcnt₂ v, spliceCnt_add_of_mem_region hl v hv hreg₁, hcnt₁ v hv hreg]
        ring
      · have e : (((d + 1 + 1) * l : ℕ) : ℤ) = ((d + 1) * l : ℕ) + (l : ℤ) := by push_cast; ring
        rw [e] at hv
        have hge : u + (l : ℤ) ≤ v := by
          have : (0 : ℤ) ≤ (((d + 1) * l : ℕ) : ℤ) := Int.natCast_nonneg _
          omega
        rw [hcnt₂ v, spliceCnt_of_ge v hge, habove₁ (v - (l : ℤ)) (by omega)]
        congr 1; push_cast; ring
      · -- the interior countdown: the `i = 0` copy is raised once more, every higher copy reads
        -- the previous stage one block lower
        rcases Nat.eq_zero_or_pos i with hi0 | hipos
        · subst hi0
          have e0 : u + ((0 * l : ℕ) : ℤ) + (j : ℤ) = u + (j : ℤ) := by push_cast; ring
          have hjl : (j : ℤ) < (l : ℤ) := by exact_mod_cast hj
          have hlt : u + (j : ℤ) < u + (l : ℤ) := by omega
          have hreg : u ≤ u + (j : ℤ) + (cntAt g₁ (u + (j : ℤ)) : ℤ) := by
            have h1 : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg _
            have h2 : (0 : ℤ) ≤ (cntAt g₁ (u + (j : ℤ)) : ℤ) := Int.natCast_nonneg _
            omega
          have hprev := hint₁ 0 j (by omega) hj
          rw [e0] at hprev ⊢
          rw [hcnt₂ (u + (j : ℤ)), spliceCnt_of_lt (u + (j : ℤ)) hlt, if_pos hreg, hprev]
          simp only [Nat.sub_zero]
          ring
        · obtain ⟨i', rfl⟩ : ∃ i', i = i' + 1 := ⟨i - 1, by omega⟩
          have ecast : (((i' + 1) * l : ℕ) : ℤ) = ((i' * l : ℕ) : ℤ) + (l : ℤ) := by
            push_cast; ring
          have hge : u + (l : ℤ) ≤ u + (((i' + 1) * l : ℕ) : ℤ) + (j : ℤ) := by
            have h2 : (0 : ℤ) ≤ ((i' * l : ℕ) : ℤ) := Int.natCast_nonneg _
            have h3 : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg _
            rw [ecast]; omega
          have esub : u + (((i' + 1) * l : ℕ) : ℤ) + (j : ℤ) - (l : ℤ)
              = u + ((i' * l : ℕ) : ℤ) + (j : ℤ) := by rw [ecast]; ring
          have hd : d + 1 - (i' + 1) = d - i' := by omega
          rw [hcnt₂ _, spliceCnt_of_ge _ hge, esub, hint₁ i' j (by omega) hj, hd]
      · obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
        have hty₁' : tpOf (ladderModel step pend fwd bwd lab) φ σ₁ u
            = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (u + (l : ℤ)) := by
          rw [hty₁ σ₁ hσ₁ u, hty₁ σ₁ hσ₁ (u + (l : ℤ)), iterSpliceIdx_of_lt u l d u (by omega),
            hty_ul]
        have htr := tpOf_eq_spliceIdx_of_tpOf_eq step pend fwd bwd lab φ u l hl (k := 0) (k' := 0)
          σ₁ σ₂ (fun t => by rw [add_zero]; exact hσ₁ t) (fun t => by rw [add_zero]; exact hσ₂ t)
          hobj₂' hno hty₁' w
        rw [htr, hty₁ σ₁ hσ₁, iterSpliceIdx_succ]

/-- **THE REGISTER CLAUSE'S OWN CONSEQUENCE, ON ANY LADDER PATH.** If a ladder path `g'` holds the
original's register at position `j` of copies `0` and `1` of the block `[u, u + l)`, then the
original's register at the block's LAST position is within one of its value at the block's FIRST:
the clause identifies `nxtAt g' (u + (l − 1))` with `nxtAt g (u + (l − 1))` and
`nxtAt g' (u + l)` with `nxtAt g u`, and those two positions of `g'` are one step apart, where
`Drift` holds.

This is the whole obstruction. Nothing about the pump's hypotheses supplies the conclusion: the
register's only constraint inside a block of a pending-forever past is `Drift` along the ORIGINAL,
which bounds the same difference by `l − 1` and not by `1`. -/
theorem iterSpliced_register_interior_forces_block_drift
    {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) {g' : ℤ → LadderState Q pend}
    (hg' : IsLadderPath step pend g') (u : ℤ) (l : ℕ) (hl : 0 < l)
    (hreg : ∀ i j : ℕ, i ≤ 1 → j < l →
      nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ)) = nxtAt g (u + (j : ℤ))) :
    Drift (nxtAt g (u + ((l - 1 : ℕ) : ℤ))) (nxtAt g u) := by
  have hcast : ((l - 1 : ℕ) : ℤ) = (l : ℤ) - 1 := by omega
  have h0 := hreg 0 (l - 1) (by omega) (by omega)
  have e0 : u + ((0 * l : ℕ) : ℤ) + ((l - 1 : ℕ) : ℤ) = u + ((l - 1 : ℕ) : ℤ) := by
    push_cast; ring
  rw [e0] at h0
  have h1 := hreg 1 0 le_rfl hl
  have e1 : u + ((1 * l : ℕ) : ℤ) + ((0 : ℕ) : ℤ) = u + ((l - 1 : ℕ) : ℤ) + 1 := by
    rw [hcast]; push_cast; ring
  rw [e1] at h1
  simp only [Nat.cast_zero, add_zero] at h1
  have hd := nxtAt_drift g' hg' (u + ((l - 1 : ℕ) : ℤ))
  rw [h0, h1] at hd
  exact hd

end IterInterior

/-! ## The refutation witness for the register clause

The two-state ladder of `ClimbWitness` already carries a path whose register climbs by one per
position across a block of its pending-forever past. All that is added here is what the pump's
hypotheses need beyond the path itself: the two seriality conditions of the admissible carrier for
that object (`fwdT`, `bwdT`), the all-true labelling (`labT`), and the observation that under it
every realized type is the whole closure, so the pump's type hypothesis is free at an atomic
formula. The witness then satisfies EVERY hypothesis of
`exists_iterSpliced_ladderPath_idx_of_pend_past` and refutes the register clause on it.

Nothing here is a fixture-restricted proof of a positive statement: the positive clause of this
section is `exists_iterSpliced_ladderPath_idx_interior_of_pend_past` above, proved generically. -/

section RegisterRefutation

open ClimbWitness

/-- **Forward seriality of the two-state ladder on the admissible carrier.** `no_fwd` refutes this
on the unrestricted carrier; on `LadderState Bool pendT` it holds, because the only source the
unrestricted statement had no successor for — an idle state with a positive countdown — is not
admissible. A pending state counts down, a pending state at countdown `0` goes idle, an idle state
stays idle, and the register is held in each case. -/
theorem fwdT (t : ℤ) (x : LadderState Bool pendT) : ∃ y, RladAdm stepT pendT t x y := by
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : q = true
  · subst hq
    match c with
    | 0 =>
        refine ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, ?_, Or.inl rfl, ?_⟩
        · intro h; simp [pendT] at h
        · simp [Count, pendT]
    | k + 1 =>
        refine ⟨⟨(true, k, n), ?_⟩, rfl, ?_, Or.inl rfl, ?_⟩
        · intro h; simp [pendT] at h
        · intro h; simp [pendT] at h
        · simp [Count, pendT]
  · have hq' : q = false := by simpa using hq
    subst hq'
    have hc : c = 0 := hx (by simp [pendT])
    subst hc
    exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendT]⟩

/-- **Backward seriality of the two-state ladder on the admissible carrier.** `no_bwd_of_idle`
refutes this on the unrestricted carrier; on the admissible one a pending state is reached from
the same object one count higher, and an idle state — whose countdown is `0` by admissibility —
from an idle one. -/
theorem bwdT (t : ℤ) (x : LadderState Bool pendT) : ∃ y, RladAdm stepT pendT (t - 1) y x := by
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : q = true
  · subst hq
    refine ⟨⟨(true, c + 1, n), ?_⟩, rfl, ?_, Or.inl rfl, ?_⟩
    · intro h; simp [pendT] at h
    · intro h; simp [pendT] at h
    · simp [Count, pendT]
  · have hq' : q = false := by simpa using hq
    subst hq'
    have hc : c = 0 := hx (by simp [pendT])
    subst hc
    exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pendT]⟩

/-- The all-true labelling of the two-state object. -/
def labT : Bool → Atom → Bool := fun _ _ => true

/-- **Under the all-true labelling every realized type of an atomic formula is position
independent**, because the closure of an atom is the atom alone and the atom holds at every state.
This is what makes the pump's type hypothesis free on the refutation witness: the hypothesis
constrains the object walk through the closure, and at an atomic formula it constrains nothing. -/
theorem tpOf_labT_atom_const
    (σ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame) (p : Atom) (z z' : ℤ) :
    tpOf (ladderModel stepT pendT fwdT bwdT labT) (PlusFormula.atom p) σ z
      = tpOf (ladderModel stepT pendT fwdT bwdT labT) (PlusFormula.atom p) σ z' := by
  have key : ∀ (w : ℤ) (ψ : PlusFormula),
      ψ ∈ plusSubformulaClosure (PlusFormula.atom p) →
      PlusTruthAt (ladderModel stepT pendT fwdT bwdT labT) σ w ψ := by
    intro w ψ hψ
    have heq : ψ = PlusFormula.atom p := by
      simpa [plusSubformulaClosure, PlusFormula.subformulas] using hψ
    subst heq
    exact rfl
  ext ψ
  simp only [mem_tpOf_iff]
  exact ⟨fun h => ⟨h.1, key z' ψ h.1⟩, fun h => ⟨h.1, key z ψ h.1⟩⟩

/-- **THE REGISTER CLAUSE OF THE ITERATED SPLICE IS REFUTED.** On the climbing-register path of
`ClimbWitness`, with the block `[0, 3)` of its pending-forever past, EVERY hypothesis of
`exists_iterSpliced_ladderPath_idx_of_pend_past` holds — the block is non-degenerate, fits inside
the countdown at its start, lies in a uniformly pending past, is closed in the object, carries a
history over the path, and has equal realized types at its two ends at an atomic formula whose
closure contains no `stab` — and yet NO ladder path at all holds the original's register at the
corresponding positions of copies `0` and `1`. The register at the interior of the window is
therefore not a clause of this construction, at `d = 1` already; `nxtAt` climbs `0, 1, 2` across
the block, so the step from the top of copy `0` to the bottom of copy `1` would have to carry the
register from `2` to `0` in one position, which `Drift` forbids.

This refutes the clause, not a proof route for it: the conclusion fails for every `g'`, so no
choice of how the register is rebuilt can recover it. -/
theorem iterSpliced_register_interior_refuted :
    ∃ (g : ℤ → LadderState Bool pendT) (u : ℤ) (l : ℕ) (p : Atom)
      (σ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame),
      IsLadderPath stepT pendT g ∧
      (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure (PlusFormula.atom p)) ∧
      0 < l ∧ l ≤ cntAt g u ∧
      (∀ r : ℤ, r ≤ u → pendT (objAt g r) = true) ∧
      objAt g u = objAt g (u + (l : ℤ)) ∧
      (∀ t : ℤ, σ.state t = (t, g t)) ∧
      tpOf (ladderModel stepT pendT fwdT bwdT labT) (PlusFormula.atom p) σ u
        = tpOf (ladderModel stepT pendT fwdT bwdT labT) (PlusFormula.atom p) σ (u + (l : ℤ)) ∧
      ∀ g' : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g' →
        ¬ ∀ i j : ℕ, i ≤ 1 → j < l →
            nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ)) = nxtAt g (u + (j : ℤ)) := by
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdT bwdT climb climb_isLadderPath
  refine ⟨climb, 0, 3, Atom.freshBase, σ, climb_isLadderPath, ?_, by omega, ?_, ?_, ?_, hσ,
    tpOf_labT_atom_const σ Atom.freshBase 0 (0 + (3 : ℕ)), ?_⟩
  · intro χ hχ
    simp [plusSubformulaClosure, PlusFormula.subformulas] at hχ
  · simp [cntAt, climb, climbRaw]
  · intro r hr
    exact climb_pend_past r hr
  · simp [objAt, climb, climbRaw]
  · intro g' hg' hreg
    have hd := iterSpliced_register_interior_forces_block_drift climb hg' 0 3 (by omega) hreg
    simp [Drift, nxtAt, climb, climbRaw] at hd

end RegisterRefutation

/-! ## The register discriminator: side (A), what the iterated splice delivers

Phase 11.19 closed the register clause `nxtAt g' (u + i · l + j) = nxtAt g (u + j)` as REFUTED
(`iterSpliced_register_interior_refuted`). What replaces it is a MEASUREMENT: of the three
candidate register relations a depth-stratified invariant could carry — the clipped/residue
reading `kappa` itself uses, a `Drift`-distance bound, or no register conjunct at all — which does
the construction actually deliver at its own position pairs?

This section answers the PRODUCER half. It lands the `Drift`-distance reading and refutes the
clipped/residue reading; the consumer half, and the decision the two together force, are in the
section below.

LANDED — the `Drift`-distance reading. `register_displacement_bound_of_anchor` is the whole of
what two ladder paths agreeing at one anchor position give in the register coordinate: each path's
register is `1`-Lipschitz (`nxtAt_lipschitz_two_sided`), so the displacement between their values
at two positions is bounded by the sum of those positions' distances to the anchor and by nothing
smaller. `register_interior_displacement_bound_at_block` reads that at the pump's own pairs, with
the anchor at the block's start: the bound at position `j` of copy `i` is `i · l + 2 · j`. It GROWS
with the copy index, which is the honest shape of the fact — the construction displaces the copies
and the register follows them only up to `Drift`.

REFUTED — the clipped/residue reading. `iterSpliced_register_clipped_interior_forces_block_drift`
weakens Phase 11.19's hypothesis from register EQUALITY to `kappa`'s own clipped reading
`min · Tn` and derives the SAME consequence, provided the original's register sits below the
threshold at the block's two ends: below `Tn` the clipped reading IS equality, so the step from
the top of copy `0` to the bottom of copy `1` again has to carry the original's register across
the whole block in one position, which `Drift` forbids.
`iterSpliced_register_clipped_interior_refuted` exhibits that on the climbing-register path
already carried here, at every `Tn ≥ 3` and every `P`: the fixture is REUSED, not rebuilt, and the
refutation is of the clause for every `g'` whatever, not of a proof route for it. Adding the
residue conjunct `n ≡ n' [MOD P + 1]` only strengthens the refuted hypothesis, so the (R-b)
CONJUNCTION is refuted along with its clipped half.

**What this section does NOT say.** It says nothing about any `⊡` bit, about the agreement of a
cell at any pair of states, or about `kappa` as a whole: `min · Tn` appears here as an arithmetic
reading of a natural number and no class map is applied. It proves membership of no pump pair in
any relation, and it defines no relation. -/

section RegisterProducer

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **SIDE (A), LANDED: the whole of the register coordinate's transport.** Two ladder paths
agreeing at a single anchor position `z` have their registers at any two positions `v`, `w`
displaced by at most `|v − z| + |w − z|`. Both halves are `nxtAt_lipschitz_two_sided`, one per
path, glued at the anchor; nothing stronger is available, because the register's only constraint
along a ladder path away from a region start is `Drift` (`nxtAt_drift`). -/
theorem register_displacement_bound_of_anchor
    (g g' : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hg' : IsLadderPath step pend g') (z : ℤ) (hz : nxtAt g' z = nxtAt g z) (v w : ℤ) :
    ((nxtAt g' v : ℤ) - nxtAt g w).natAbs ≤ (v - z).natAbs + (w - z).natAbs := by
  have h1 := nxtAt_lipschitz_two_sided g' hg' v z
  have h2 := nxtAt_lipschitz_two_sided g hg w z
  rw [hz] at h1
  omega

/-- **The bound at the pump's own position pairs.** With the anchor at the block's start `u` — the
one position at which the register-held wrapper
`exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` does pin the register — the
displacement at position `j` of copy `i` is at most `i · l + 2 · j`. This is the (R-a) candidate's
actual content on this construction: a bound that GROWS with the copy index, not a relation that
holds uniformly across the run. -/
theorem register_interior_displacement_bound_at_block
    (g g' : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hg' : IsLadderPath step pend g') (u : ℤ) (hz : nxtAt g' u = nxtAt g u) (l i j : ℕ) :
    ((nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ)) : ℤ) - nxtAt g (u + (j : ℤ))).natAbs
      ≤ i * l + 2 * j := by
  have h := register_displacement_bound_of_anchor g g' hg hg' u hz
    (u + ((i * l : ℕ) : ℤ) + (j : ℤ)) (u + (j : ℤ))
  have e1 : (u + ((i * l : ℕ) : ℤ) + (j : ℤ) - u).natAbs = i * l + j := by
    push_cast; omega
  have e2 : (u + (j : ℤ) - u).natAbs = j := by omega
  rw [e1, e2] at h
  omega

/-- **SIDE (A), REFUTED: `kappa`'s own clipped reading of the register forces the same block
`Drift`.** If a ladder path `g'` carries the original's CLIPPED register `min · Tn` at position
`j` of copies `0` and `1` of the block `[u, u + l)`, and the original's register sits strictly
below `Tn` at the block's first and last positions, then the original's register at the block's
last position is within one of its value at the first.

Below the threshold the clipped reading is equality, so this is Phase 11.19's own obstruction
reached from a strictly weaker hypothesis: the clause identifies `nxtAt g' (u + (l − 1))` with
`nxtAt g (u + (l − 1))` and `nxtAt g' (u + l)` with `nxtAt g u`, and those two positions of `g'`
are one step apart, where `Drift` holds. The threshold hypothesis is the regime the depth-
stratified invariant actually occupies: its own threshold conjunct bounds the COUNTDOWN, never the
register, so nothing in it keeps either member above `Tn`. -/
theorem iterSpliced_register_clipped_interior_forces_block_drift
    (g : ℤ → LadderState Q pend) {g' : ℤ → LadderState Q pend}
    (hg' : IsLadderPath step pend g') (u : ℤ) (l Tn : ℕ) (hl : 0 < l)
    (hreg : ∀ i j : ℕ, i ≤ 1 → j < l →
      min (nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))) Tn
        = min (nxtAt g (u + (j : ℤ))) Tn)
    (hlo : nxtAt g (u + ((l - 1 : ℕ) : ℤ)) < Tn) (hhi : nxtAt g u < Tn) :
    Drift (nxtAt g (u + ((l - 1 : ℕ) : ℤ))) (nxtAt g u) := by
  have hcast : ((l - 1 : ℕ) : ℤ) = (l : ℤ) - 1 := by omega
  have h0 := hreg 0 (l - 1) (by omega) (by omega)
  have e0 : u + ((0 * l : ℕ) : ℤ) + ((l - 1 : ℕ) : ℤ) = u + ((l - 1 : ℕ) : ℤ) := by
    push_cast; ring
  rw [e0] at h0
  have h1 := hreg 1 0 le_rfl hl
  have e1 : u + ((1 * l : ℕ) : ℤ) + ((0 : ℕ) : ℤ) = u + ((l - 1 : ℕ) : ℤ) + 1 := by
    rw [hcast]; push_cast; ring
  rw [e1] at h1
  simp only [Nat.cast_zero, add_zero] at h1
  have hd := nxtAt_drift g' hg' (u + ((l - 1 : ℕ) : ℤ))
  have ex0 : nxtAt g' (u + ((l - 1 : ℕ) : ℤ)) = nxtAt g (u + ((l - 1 : ℕ) : ℤ)) := by omega
  have ex1 : nxtAt g' (u + ((l - 1 : ℕ) : ℤ) + 1) = nxtAt g u := by omega
  rw [ex0, ex1] at hd
  exact hd

end RegisterProducer

section RegisterClippedRefutation

open ClimbWitness

/-- **THE CLIPPED REGISTER READING IS REFUTED TOO, AT EVERY `Tn ≥ 3` AND EVERY `P`.** On the
climbing-register path of `ClimbWitness` with the block `[0, 3)` of its pending-forever past —
the very fixture `iterSpliced_register_interior_refuted` already carries, and every hypothesis of
`exists_iterSpliced_ladderPath_idx_of_pend_past` holds on it — NO ladder path at all carries the
original's clipped register `min · Tn` at the corresponding positions of copies `0` and `1`. The
register climbs `0, 1, 2` across the block, so with `2 < Tn` the clipped reading is exact there
and the step from the top of copy `0` to the bottom of copy `1` would have to carry the register
from `2` to `0` in one position.

The residue conjunct is carried in the hypothesis alongside the clipped one, so what is refuted is
the (R-b) CONJUNCTION `min n Tn = min n' Tn ∧ n ≡ n' [MOD P + 1]` and not merely its clipped half.
This refutes the clause and not a proof route for it: the conclusion fails for every `g'`. -/
theorem iterSpliced_register_clipped_interior_refuted (Tn P : ℕ) (hTn : 3 ≤ Tn) :
    ∃ (g : ℤ → LadderState Bool pendT) (u : ℤ) (l : ℕ) (p : Atom)
      (σ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame),
      IsLadderPath stepT pendT g ∧
      (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure (PlusFormula.atom p)) ∧
      0 < l ∧ l ≤ cntAt g u ∧
      (∀ r : ℤ, r ≤ u → pendT (objAt g r) = true) ∧
      objAt g u = objAt g (u + (l : ℤ)) ∧
      (∀ t : ℤ, σ.state t = (t, g t)) ∧
      tpOf (ladderModel stepT pendT fwdT bwdT labT) (PlusFormula.atom p) σ u
        = tpOf (ladderModel stepT pendT fwdT bwdT labT) (PlusFormula.atom p) σ (u + (l : ℤ)) ∧
      ∀ g' : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g' →
        ¬ ∀ i j : ℕ, i ≤ 1 → j < l →
            min (nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))) Tn
                = min (nxtAt g (u + (j : ℤ))) Tn ∧
              nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ)) % (P + 1)
                = nxtAt g (u + (j : ℤ)) % (P + 1) := by
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdT bwdT climb climb_isLadderPath
  refine ⟨climb, 0, 3, Atom.freshBase, σ, climb_isLadderPath, ?_, by omega, ?_, ?_, ?_, hσ,
    tpOf_labT_atom_const σ Atom.freshBase 0 (0 + (3 : ℕ)), ?_⟩
  · intro χ hχ
    simp [plusSubformulaClosure, PlusFormula.subformulas] at hχ
  · simp [cntAt, climb, climbRaw]
  · intro r hr
    exact climb_pend_past r hr
  · simp [objAt, climb, climbRaw]
  · intro g' hg' hreg
    have hclip : ∀ i j : ℕ, i ≤ 1 → j < 3 →
        min (nxtAt g' (0 + ((i * 3 : ℕ) : ℤ) + (j : ℤ))) Tn
          = min (nxtAt climb (0 + (j : ℤ))) Tn := fun i j hi hj => (hreg i j hi hj).1
    have hd := iterSpliced_register_clipped_interior_forces_block_drift climb hg' 0 3 Tn
      (by omega) hclip (by simp [nxtAt, climb, climbRaw]; omega)
      (by simp [nxtAt, climb, climbRaw]; omega)
    simp [Drift, nxtAt, climb, climbRaw] at hd

end RegisterClippedRefutation

/-! ## The register discriminator: side (B), what the `⊡`-bit agreement needs

`stab_state_only` (`PlusTruth.lean`) makes a `⊡` bit a function of the WORLD STATE, so what the
bit agreement requires of two states is a statement about their coordinates and is provable or
refutable on a two-state fixture. This section measures the REGISTER requirement on one.

The fixture is the two-state ladder already carried above, with the labelling changed: `labR`
makes every letter track the pending bit, so the atom `r` reads "the object is pending". The
probe formula is

  `alphaR := X r → X X ¬ r`,

with `X χ := ⊥ U χ` the next-time reading (`nextR_iff`). `stab_alphaR_iff` computes its `⊡` bit at
an IDLE ladder state exactly: the bit is `nxtAt g t = 0`, because from an idle position the next
region's countdown IS the register (`cntAt_eq_nxtAt_of_idle_pend`), so a pending successor is
followed by an idle position at the next step precisely when that register is `0`, and `⊡`
quantifies over the histories that realize the pending successor.

Two consequences, both compiled:

* NEEDED — `stab_bit_ne_of_register_ne`: for every `m > 0` the bits at register `0` and at
  register `m` DIFFER, at the same object and the same countdown. So the (R-c) candidate — drop
  the register conjunct — is REFUTED, and so is the (R-a) candidate: at `m = 1` the two registers
  are within the `Drift` distance of one single step, which is the smallest bound any
  displacement reading can offer, and the bits differ across it anyway. At `m = P + 1` the two
  registers agree modulo `P + 1`, so the residue conjunct alone is refuted as well: this bit reads
  the register's EXACT value, not its residue.
* CONSUMED — `stab_alphaR_eq_of_clipped_eq`: at any threshold `Tn ≥ 1` the clipped reading
  `min n Tn = min n' Tn` — `kappa`'s own register coordinate — delivers the agreement of this bit.
  So the (R-b) candidate is the one side (B) consumes, and it is consumed at the clipped half
  alone, with no residue conjunct needed.

**What this section does NOT say.** It computes one bit on one fixture and claims no bound on the
`⊡` bits of an arbitrary formula; `stab_alphaR_eq_of_clipped_eq` is sufficiency for `alphaR` and
not for a closure. It says nothing about any pump, about `iterSpliceIdx`, or about the agreement
of a cell at any pair of states, and it defines no relation. -/

section RegisterConsumer

open ClimbWitness

/-- The pending-tracking labelling of the two-state object: every letter reads the pending bit.
`labT`, the all-true labelling beside it, makes every letter blind to the object and is what the
refutation witnesses above need; this one is what a REGISTER measurement needs, because a bit
that cannot see the object cannot see the region structure the register governs. -/
def labR : Bool → Atom → Bool := fun q _ => q

/-- The probe atom. -/
def rR : PlusFormula := PlusFormula.atom Atom.freshBase

/-- The next-time reading `X χ := ⊥ U χ`: the `untl` whose guard is unsatisfiable fires at the
next position and nowhere else. -/
def nextR (χ : PlusFormula) : PlusFormula := PlusFormula.untl .bot χ

/-- **The probe formula.** "If the next position is pending, then two positions on it is not." At
an idle state its `⊡` bit is exactly `register = 0`. -/
def alphaR : PlusFormula := (nextR rR).imp (nextR (nextR (PlusFormula.neg rR)))

/-- **`X` is next-time on this frame.** The `untl` guard is `⊥`, which no position satisfies, so
the witness position is forced to be the immediate successor. -/
theorem nextR_iff (σ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame)
    (t : ℤ) (χ : PlusFormula) :
    PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ t (nextR χ)
      ↔ PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ (t + 1) χ := by
  unfold nextR
  rw [PlusTruth.untl_iff]
  constructor
  · rintro ⟨(s : ℤ), hs, hχ, hguard⟩
    have hs' : (t : ℤ) < s := hs
    have he : s = t + 1 := by
      by_contra hne
      have h1 : (t : ℤ) < t + 1 := by omega
      have h2 : (t + 1 : ℤ) < s := by omega
      exact PlusTruth.bot_false
        (M := ladderModel stepT pendT fwdT bwdT labR) (τ := σ) (t := (t + 1 : ℤ))
        (hguard (t + 1) h1 h2)
    rw [he] at hχ
    exact hχ
  · intro h
    refine ⟨t + 1, ?_, h, ?_⟩
    · change (t : ℤ) < t + 1
      omega
    · intro (r : ℤ) h1 h2
      have h1' : (t : ℤ) < r := h1
      have h2' : r < (t : ℤ) + 1 := h2
      exact absurd h2' (not_lt.mpr (by omega))

/-- **The probe atom reads the pending bit of the object walk.** -/
theorem truth_rR_iff (g : ℤ → LadderState Bool pendT)
    (σ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame)
    (hσ : ∀ s : ℤ, σ.state s = (s, g s)) (t : ℤ) :
    PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ t rR ↔ objAt g t = true := by
  unfold rR
  rw [PlusTruth.atom_iff]
  change (labR ((σ.state t).2.1.1) Atom.freshBase = true) ↔ _
  rw [hσ t]
  rfl

/-! ### The forced pending continuation at a prescribed register

To refute the bits' agreement at two registers, one history per register value is needed through
the state that carries it — and the state is idle, so the history has to be exhibited rather than
read off anything already landed. `regPath t m` is it: idle at and before `t` with register `m`,
a pending region of length `m + 1` starting at `t + 1` (the length the register forces,
`cntAt_eq_nxtAt_of_idle_pend`), idle again after it, and register `m` throughout. -/

/-- The underlying triples of the forced pending continuation at register `m`. -/
def regRaw (t : ℤ) (m : ℕ) (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ t then (false, 0, m)
  else if v ≤ t + 1 + (m : ℤ) then (true, (t + 1 + (m : ℤ) - v).toNat, m)
  else (false, 0, m)

theorem regRaw_adm (t : ℤ) (m : ℕ) (v : ℤ) :
    (regRaw t m v).2.1 ∈ Adm pendT (regRaw t m v).1 := by
  intro h
  unfold regRaw at *
  split_ifs at * <;> simp_all [pendT]

/-- The forced pending continuation as a ladder state function. -/
def regPath (t : ℤ) (m : ℕ) (v : ℤ) : LadderState Bool pendT := ⟨regRaw t m v, regRaw_adm t m v⟩

theorem regPath_isLadderPath (t : ℤ) (m : ℕ) : IsLadderPath stepT pendT (regPath t m) := by
  intro u
  change Rlad stepT pendT u (regRaw t m u) (regRaw t m (u + 1))
  unfold Rlad Drift Count regRaw stepT pendT
  split_ifs <;> simp_all <;> omega

@[simp] theorem regPath_nxtAt (t : ℤ) (m : ℕ) (v : ℤ) : nxtAt (regPath t m) v = m := by
  unfold nxtAt regPath regRaw
  split_ifs <;> rfl

@[simp] theorem regPath_objAt_self (t : ℤ) (m : ℕ) : objAt (regPath t m) t = false := by
  simp [objAt, regPath, regRaw]

@[simp] theorem regPath_cntAt_self (t : ℤ) (m : ℕ) : cntAt (regPath t m) t = 0 := by
  simp [cntAt, regPath, regRaw]

theorem regPath_objAt_succ (t : ℤ) (m : ℕ) : objAt (regPath t m) (t + 1) = true := by
  simp [objAt, regPath, regRaw, show ¬ (t + 1 ≤ t) by omega,
    show t + 1 ≤ t + 1 + (m : ℤ) by omega]

theorem regPath_objAt_succ_succ (t : ℤ) (m : ℕ) (hm : 0 < m) :
    objAt (regPath t m) (t + 1 + 1) = true := by
  have h1 : ¬ (t + 1 + 1 ≤ t) := by omega
  have h2 : t + 1 + 1 ≤ t + 1 + (m : ℤ) := by
    have : (1 : ℤ) ≤ (m : ℕ) := by exact_mod_cast hm
    omega
  simp [objAt, regPath, regRaw, h1, h2]

/-- **The forced continuation passes through any idle ladder state with the same register.** -/
theorem regPath_eq_of_idle (g : ℤ → LadderState Bool pendT)
    (hg : IsLadderPath stepT pendT g) (t : ℤ) (hidle : objAt g t = false) :
    regPath t (nxtAt g t) t = g t := by
  refine Subtype.ext ?_
  have hg1 : (g t).1 = (objAt g t, cntAt g t, nxtAt g t) := rfl
  have hc : cntAt g t = 0 :=
    cntAt_eq_zero_of_idle g hg t (by simpa [pendT] using hidle)
  change regRaw t (nxtAt g t) t = (g t).1
  rw [hg1, hidle, hc]
  simp [regRaw]

/-! ### The measurement -/

/-- **SIDE (B), THE BIT COMPUTED: the `⊡` bit of `alphaR` at an idle ladder state is
`register = 0`.** Generic in the path and the history, not a fixture-restricted reading.

Both directions go through the region structure the register forces. If the register is `0`, then
on EVERY history through the state a pending successor carries countdown `0`
(`cntAt_eq_nxtAt_of_idle_pend`), so the position after it cannot be pending
(`cntAt_succ_of_pend_pend` would need `c + 1 = 0`) and `alphaR` holds. If the register is `m > 0`,
then `regPath t m` is a ladder path through the SAME state whose next two positions are both
pending, so `alphaR` fails on the history it carries and the `⊡` bit is `false`. -/
theorem stab_alphaR_iff (g : ℤ → LadderState Bool pendT) (hg : IsLadderPath stepT pendT g)
    (σ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame)
    (hσ : ∀ s : ℤ, σ.state s = (s, g s)) (t : ℤ) (hidle : objAt g t = false) :
    PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ t (PlusFormula.stab alphaR)
      ↔ nxtAt g t = 0 := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    by_contra hne
    have hm : 0 < nxtAt g t := by omega
    obtain ⟨ρ, hρ⟩ := exists_hist_of_isLadderPath fwdT bwdT
      (regPath t (nxtAt g t)) (regPath_isLadderPath t (nxtAt g t))
    have hstate : σ.state t = ρ.state t := by
      rw [hσ t, hρ t, regPath_eq_of_idle g hg t hidle]
    have hα := h ρ hstate
    unfold alphaR at hα
    rw [PlusTruth.imp_iff] at hα
    have hant : PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) ρ t (nextR rR) := by
      rw [nextR_iff, truth_rR_iff _ ρ hρ]
      exact regPath_objAt_succ t (nxtAt g t)
    have hcon := hα hant
    rw [nextR_iff, nextR_iff, PlusTruth.neg_iff, truth_rR_iff _ ρ hρ] at hcon
    exact hcon (regPath_objAt_succ_succ t (nxtAt g t) hm)
  · intro h0 ρ hstate
    obtain ⟨k, hh, hhp, hρp⟩ := exists_isLadderPath_of_hist fwdT bwdT ρ
    have hpair : ((t + k : ℤ), hh t) = ((t : ℤ), g t) := by
      rw [← hρp t, ← hstate, hσ t]
    have hk : k = 0 := by
      have := congrArg Prod.fst hpair
      simp at this
      omega
    subst hk
    have hht : hh t = g t := by
      have := congrArg Prod.snd hpair
      simpa using this
    have hρ : ∀ s : ℤ, ρ.state s = (s, hh s) := fun s => by
      rw [hρp s, add_zero]
    unfold alphaR
    rw [PlusTruth.imp_iff]
    intro hant
    rw [nextR_iff, truth_rR_iff _ ρ hρ] at hant
    rw [nextR_iff, nextR_iff, PlusTruth.neg_iff, truth_rR_iff _ ρ hρ]
    intro hpend2
    have hidle0 : pendT (objAt hh t) = false := by
      simpa [pendT, objAt, hht] using hidle
    have hpend1 : pendT (objAt hh (t + 1)) = true := by simpa [pendT] using hant
    have hc1 : cntAt hh (t + 1) = nxtAt hh t :=
      cntAt_eq_nxtAt_of_idle_pend hh hhp t hidle0 hpend1
    have hnxe : nxtAt hh t = nxtAt g t := by simp [nxtAt, hht]
    have hnx : nxtAt hh t = 0 := by rw [hnxe]; exact h0
    have hstep := cntAt_succ_of_pend_pend hh hhp (t + 1) hpend1 (by simpa [pendT] using hpend2)
    omega

/-- **SIDE (B), THE REGISTER CONJUNCT IS NEEDED, AT EVERY AMOUNT.** For every `m > 0` there are
two ladder paths whose states at `0` share the object and the countdown and differ ONLY in the
register — `0` against `m` — and whose `⊡ alphaR` bits DIFFER.

Three candidate register relations die here. (R-c), the register conjunct dropped: refuted
outright. (R-a), a `Drift`-distance bound: refuted at `m = 1`, where the two registers are within
one step's drift — the smallest displacement any bound can name — and the bits differ anyway.
The residue reading on its own: refuted at `m = P + 1` for any `P`, where the two registers are
congruent modulo `P + 1`. What survives is the CLIPPED reading, and the lemma below consumes it. -/
theorem stab_bit_ne_of_register_ne (m : ℕ) (hm : 0 < m) :
    ∃ (g h : ℤ → LadderState Bool pendT)
      (σ τ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame),
      IsLadderPath stepT pendT g ∧ IsLadderPath stepT pendT h ∧
      (∀ s : ℤ, σ.state s = (s, g s)) ∧ (∀ s : ℤ, τ.state s = (s, h s)) ∧
      objAt g 0 = objAt h 0 ∧ cntAt g 0 = cntAt h 0 ∧
      nxtAt g 0 = 0 ∧ nxtAt h 0 = m ∧
      ¬ (PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ 0 (PlusFormula.stab alphaR)
          ↔ PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) τ 0
              (PlusFormula.stab alphaR)) := by
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdT bwdT
    (regPath 0 0) (regPath_isLadderPath 0 0)
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdT bwdT
    (regPath 0 m) (regPath_isLadderPath 0 m)
  refine ⟨regPath 0 0, regPath 0 m, σ, τ, regPath_isLadderPath 0 0, regPath_isLadderPath 0 m,
    hσ, hτ, by simp, by simp, by simp, by simp, ?_⟩
  intro hiff
  rw [stab_alphaR_iff _ (regPath_isLadderPath 0 0) σ hσ 0 (by simp),
    stab_alphaR_iff _ (regPath_isLadderPath 0 m) τ hτ 0 (by simp)] at hiff
  have hm0 : nxtAt (regPath (0 : ℤ) m) 0 = 0 := hiff.mp (regPath_nxtAt 0 0 0)
  rw [regPath_nxtAt] at hm0
  omega

/-- **SIDE (B), THE CLIPPED READING IS CONSUMED.** At any threshold `Tn ≥ 1`, `kappa`'s own
clipped register coordinate `min n Tn` delivers the agreement of this bit at two idle states. The
residue coordinate is not needed and is not used.

This is the positive half of the measurement, and it is what makes (R-b) the candidate the
decision rule reaches: side (B) consumes it where it refuses both of the others. -/
theorem stab_alphaR_eq_of_clipped_eq (g h : ℤ → LadderState Bool pendT)
    (hg : IsLadderPath stepT pendT g) (hh : IsLadderPath stepT pendT h)
    (σ τ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame)
    (hσ : ∀ s : ℤ, σ.state s = (s, g s)) (hτ : ∀ s : ℤ, τ.state s = (s, h s))
    (t : ℤ) (hgi : objAt g t = false) (hhi : objAt h t = false)
    (Tn : ℕ) (hTn : 1 ≤ Tn) (hclip : min (nxtAt g t) Tn = min (nxtAt h t) Tn) :
    PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ t (PlusFormula.stab alphaR)
      ↔ PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) τ t (PlusFormula.stab alphaR) := by
  rw [stab_alphaR_iff g hg σ hσ t hgi, stab_alphaR_iff h hh τ hτ t hhi]
  omega

end RegisterConsumer

/-! ## The decision: no candidate passes both sides, and the gap between them

The two sides above are COMPILED objects, and the decision rule the plan of record pins — take the
first candidate that side (A) lands positively for every pump pair AND side (B) consumes — reaches
none of its three candidates. One table, each cell pointing at the declaration that decided it:

**(R-b), the clipped/residue reading** `min n Tn = min n' Tn ∧ n ≡ n' [MOD P + 1]`.
Side (A): **REFUTED** by `iterSpliced_register_clipped_interior_refuted`, at every `Tn ≥ 3` and
every `P`, with the residue conjunct carried in the refuted hypothesis alongside the clipped one.
Side (B): **CONSUMED** by `stab_alphaR_eq_of_clipped_eq`, at every `Tn ≥ 1`, and by the clipped
half alone — the residue coordinate is neither needed nor used there.

**(R-a), a `Drift`-distance bound** on the displacement `n − n'`.
Side (A): **LANDED** by `register_interior_displacement_bound_at_block`, at the bound
`i · l + 2 · j`, which GROWS with the copy index.
Side (B): **NOT CONSUMED** — `stab_bit_ne_of_register_ne` at `m = 1` puts the two registers
within one step's drift, the smallest displacement any bound can name, and the bits differ across
it anyway.

**(R-c), the register conjunct dropped.**
Side (A): vacuous, nothing to deliver.
Side (B): **REFUTED** by `stab_bit_ne_of_register_ne`, at every `m > 0`.

**THE GAP, NAMED.** The pump cannot hold the register's clipped value at the interior of its own
window, and the `⊡` bit cannot read anything weaker than that clipped value. The two facts meet in
one place and disagree there: below the threshold the clipped reading IS equality, so side (B)
needs the original's exact register at a copy pair, and side (A) says a ladder path carrying it at
the top of copy `0` and the bottom of copy `1` would have to move the register across the whole
block in one position, which `Drift` forbids whenever the original's register is not nearly
constant on the block. The climbing-register fixture is a path on which it is not.

So NO relation `~_d` is defined here, and no membership claim is made: a relation whose register
conjunct nobody measured is exactly what the (W-2) ruling forbids, and the two measurements are
this section's product. The threshold conjunct is left as `margin_room_at_depth` found it — its
base `Tc_0` is `0`, forced by the `(K2)` conjunct's own size, so the threshold says nothing at the
deepest level `d = D`; this section does not cure that and takes no new `(K2)` ruling.

**What a successor round has to choose between** — both route decisions, neither a move inside a
phase:

* Restrict the pump's block selection to blocks across which the original's register is already
  nearly constant, so side (A)'s obstruction is hypothesised away rather than argued around. The
  cost is a new block-selection condition on top of `exists_typeBlock_of_spacing`, and nothing
  landed says such blocks exist at the needed spacing.
* Move the register bridging off the path level entirely, onto the certificate side, so that no
  position-pair relation has to carry a register conjunct at all. The cost is that the transport
  the depth induction consumes would then not be a path-level correspondence at all.

Neither is costable from here, and the choice is not this section's to make. -/

/-! ## The pending-state measurement: which register reading a `⊡` bit consumes there

The consumer measurement above is taken at an IDLE state (`stab_alphaR_iff` carries
`objAt g t = false`). The positions of a pump block inside a pending-forever past are all
PENDING, so that measurement says what a `⊡` bit reads at a state shape the window's interior
never occupies. This section measures the shape that matters, on the same two-state fixture with
the same labelling `labR`, and then tests on the producer side the reading it finds.

The probe formula is

  `betaR := r U (¬ r ∧ X r ∧ X X ¬ r)`,   `gapR := ¬ betaR`,

"the current pending region ends, and the region that starts immediately after it has length
one". `stab_gapR_iff` computes the `⊡` bit of `gapR` at a PENDING ladder state `(true, c, n)`
exactly, generically in the path and the history:

  `⊡ gapR` holds iff `c + 1 < n`.

The mechanism: the region's end is forced `c + 1` positions on (`cntAt_sub_of_pend`), the region
after it is handed the register's value there (`cntAt_eq_nxtAt_of_idle_pend`), and the register
can have fallen by at most `c + 1` in between (`nxtAt_lipschitz_two_sided`). So some history
through the state reaches register `0` at the hand-off exactly when `n ≤ c + 1`, and `gapPath`
is that history. The bit is a threshold on the signed GAP `n − c`.

**THE CONSUMER LEG, the three candidate readings, each decided by a compiled object.**

* The gap `n − c`: **CONSUMED**, at every pending state. `stab_gapR_eq_of_gap_eq` delivers the
  agreement of this bit from equality of the signed gap alone, at two pending states with
  arbitrary and possibly different countdowns. It holds at a countdown above any positive
  threshold and at countdown `0` alike, so the two measurement points AGREE on it.
* The clipped register `min n Tn`: **REFUTED at every countdown `c ≥ Tn − 1`**, hence above any
  positive countdown threshold whatever. `stab_gapR_ne_of_clipped_eq` exhibits, for every `Tn`,
  every `P` and every such `c`, two pending states with the same object, the same countdown `c`,
  the same clipped register and the same register residue modulo `P + 1` whose bits DIFFER — so
  the clipped/residue conjunction is refuted, not only its clipped half. **CONSUMED on the slice
  of equal countdowns `c + 2 ≤ Tn`**, which contains countdown `0` at every `Tn ≥ 2`
  (`stab_gapR_eq_of_clipped_eq_of_low`; `stab_gapR_iff_of_cnt_zero` reads the bit there as
  `2 ≤ n`). So the two measurement points DIFFER on this candidate, and the difference is the
  finding: the clipped register is the reading only where the countdown is too short to hide the
  register, and at countdown `0` it coincides with the gap.
* Neither: **REFUTED**, by the gap's own landed sufficiency.

**THE PRODUCER LEG.** The gap-shaped register conjunct at the pump's own position pairs reads:
position `j` of copies `0` and `1` of the block is pending and carries the signed gap of the
original at `u + j`. `iterSpliced_gap_interior_forces_block_gap_le` derives from it that the
original's gap at the block's LAST position is at most its gap at the block's FIRST: the step
from the top of copy `0` to the bottom of copy `1` is one pending-to-pending step, across which
the gap moves by `0`, `1` or `2` and never down. Along a pending block of the original the gap is
itself non-decreasing, so the conjunct forces the original's gap to be CONSTANT across the block —
the register falling in step with the countdown — and is refuted on any path whose gap rises
anywhere inside the block. The verdict on the ramp fixture is compiled against that fixture where
it lives, as `ProbeB1.gap_conjunct_refuted_on_ramp` and `ProbeB1.gap_conjunct_refuted_at_params` in
`specs/evidence/seam-gluing-ray-product/ladder-clipped-register-block-nonvacuity.lean`: on
`ProbeB1.ramp` the gap rises by two per position, so NO ladder path whatever carries the conjunct
at copies `0` and `1` of any block of length at least two in the region.

**THE VERDICT.** The consumer leg lands the gap reading; the producer leg REFUTES the gap-shaped
conjunct on `ProbeB1.ramp`. A position-pair relation carrying the gap as its register conjunct is
therefore not delivered by the iterated splice, and with the clipped/residue reading and the
`Drift`-distance reading already closed above, no register conjunct measured at the path level
passes both sides. What remains is the second successor named in the decision above: register
bridging on the certificate side, with no position-pair relation carrying a register conjunct.

**What this section does NOT say.** It is not a relation and defines none. It says nothing about
the agreement of a cell at any pair of states, applies `kappa` nowhere, and proves membership of
no pump pair in anything. It computes ONE bit of ONE formula on one fixture:
`stab_gapR_eq_of_gap_eq` is sufficiency for `gapR` and not for a closure, and nothing here says
the gap is the only quantity a `⊡` bit reads at a pending state. The conjunct tested on the
producer side is the EXACT signed gap; a gap clipped to a window, which is what `kappa`'s own gap
coordinate carries, is a strictly weaker conjunct and is neither landed nor refuted here. The
idle-state measurements above stand at the state shape they were taken at and are not weakened
or superseded; and the block-selection condition on a clipped register is not revived — it is
refuted as non-vacuous in the evidence file named above. -/

section PendingConsumer

open ClimbWitness

/-- The event of the pending-state probe: "this position is idle, the next is pending, and the
one after that is idle again" — an idle position followed by a pending region of length one. -/
def gapEventR : PlusFormula :=
  (PlusFormula.neg rR).and ((nextR rR).and (nextR (nextR (PlusFormula.neg rR))))

/-- "The object stays pending until `gapEventR`": from a pending state, the current region ends
and the region that starts immediately after it has length one. -/
def betaR : PlusFormula := PlusFormula.untl rR gapEventR

/-- **The pending-state probe formula**, the negation of `betaR`. At a pending state its `⊡` bit
is exactly `c + 1 < n` (`stab_gapR_iff`). -/
def gapR : PlusFormula := PlusFormula.neg betaR

/-! ### Two ladder paths through a prescribed pending state -/

/-- The underlying triples of the constant-register path through the pending state `(true, c, n)`
at `t`: pending for ever into the past, the countdown running out at `t + c`, idle after it. -/
def pendRaw (t : ℤ) (c n : ℕ) (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ t + (c : ℤ) then (true, (t + (c : ℤ) - v).toNat, n) else (false, 0, n)

theorem pendRaw_adm (t : ℤ) (c n : ℕ) (v : ℤ) :
    (pendRaw t c n v).2.1 ∈ Adm pendT (pendRaw t c n v).1 := by
  intro h
  unfold pendRaw at *
  split_ifs at * <;> simp_all [pendT]

/-- The constant-register path through a prescribed pending state, as a ladder state function.
It exists at EVERY countdown and register, which is what the refutation witnesses need. -/
def pendPath (t : ℤ) (c n : ℕ) (v : ℤ) : LadderState Bool pendT :=
  ⟨pendRaw t c n v, pendRaw_adm t c n v⟩

theorem pendPath_isLadderPath (t : ℤ) (c n : ℕ) : IsLadderPath stepT pendT (pendPath t c n) := by
  intro u
  change Rlad stepT pendT u (pendRaw t c n u) (pendRaw t c n (u + 1))
  unfold Rlad Drift Count pendRaw stepT pendT
  split_ifs <;> simp_all <;> omega

@[simp] theorem pendPath_objAt_self (t : ℤ) (c n : ℕ) : objAt (pendPath t c n) t = true := by
  simp [objAt, pendPath, pendRaw]

@[simp] theorem pendPath_cntAt_self (t : ℤ) (c n : ℕ) : cntAt (pendPath t c n) t = c := by
  simp [cntAt, pendPath, pendRaw]

@[simp] theorem pendPath_nxtAt_self (t : ℤ) (c n : ℕ) : nxtAt (pendPath t c n) t = n := by
  unfold nxtAt pendPath pendRaw
  split_ifs <;> rfl

/-- The underlying triples of the falling-register path through the pending state `(true, c, n)`
at `t`: pending for ever into the past with register `n`, the register falling by one per
position after `t`, the region ending at `t + c`, then one idle position, one pending position
with countdown `0`, and idle after it. It is a ladder path exactly when the register can reach
`0` by the hand-off, `n ≤ c + 1`. -/
def gapRaw (t : ℤ) (c n : ℕ) (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ t + (c : ℤ) then (true, (t + (c : ℤ) - v).toNat, ((n : ℤ) - max 0 (v - t)).toNat)
  else if v = t + (c : ℤ) + 2 then (true, 0, 0)
  else (false, 0, 0)

theorem gapRaw_adm (t : ℤ) (c n : ℕ) (v : ℤ) :
    (gapRaw t c n v).2.1 ∈ Adm pendT (gapRaw t c n v).1 := by
  intro h
  unfold gapRaw at *
  split_ifs at * <;> simp_all [pendT]

/-- The falling-register path as a ladder state function. -/
def gapPath (t : ℤ) (c n : ℕ) (v : ℤ) : LadderState Bool pendT :=
  ⟨gapRaw t c n v, gapRaw_adm t c n v⟩

theorem gapPath_isLadderPath (t : ℤ) (c n : ℕ) (h : n ≤ c + 1) :
    IsLadderPath stepT pendT (gapPath t c n) := by
  intro u
  change Rlad stepT pendT u (gapRaw t c n u) (gapRaw t c n (u + 1))
  unfold Rlad Drift Count gapRaw stepT pendT
  split_ifs <;> simp_all <;> omega

theorem gapPath_objAt (t : ℤ) (c n : ℕ) (v : ℤ) :
    objAt (gapPath t c n) v = decide (v ≤ t + (c : ℤ) ∨ v = t + (c : ℤ) + 2) := by
  unfold objAt gapPath gapRaw
  split_ifs <;> simp_all

/-- **The falling-register path passes through any pending ladder state** with that state's own
countdown and register. -/
theorem gapPath_eq_of_pend (g : ℤ → LadderState Bool pendT) (t : ℤ)
    (hpend : objAt g t = true) : gapPath t (cntAt g t) (nxtAt g t) t = g t := by
  refine Subtype.ext ?_
  have hg1 : (g t).1 = (objAt g t, cntAt g t, nxtAt g t) := rfl
  change gapRaw t (cntAt g t) (nxtAt g t) t = (g t).1
  rw [hg1, hpend]
  simp [gapRaw]

/-! ### The measurement at a pending state -/

/-- **THE BIT COMPUTED AT A PENDING STATE: the `⊡` bit of `gapR` is `c + 1 < n`.** Generic in
the path and the history, at every countdown — not a fixture-restricted reading.

If `n ≤ c + 1`, `gapPath` is a ladder path through the SAME state on which the register reaches
`0` at the first idle position, so the region after it has length one, `betaR` holds on the
history it carries and the `⊡` bit is `false`. If `c + 1 < n`, then on EVERY history through the
state the current region ends exactly `c + 1` positions on (`cntAt_sub_of_pend`, and
`cntAt_succ_of_pend_pend` forbids a longer one), the register there is still positive
(`nxtAt_lipschitz_two_sided`), a region starting next is handed it
(`cntAt_eq_nxtAt_of_idle_pend`), and a region with a positive countdown cannot end after one
position (`cntAt_eq_zero_of_pend_idle`) — so `betaR` fails on all of them. -/
theorem stab_gapR_iff (g : ℤ → LadderState Bool pendT)
    (σ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame)
    (hσ : ∀ s : ℤ, σ.state s = (s, g s)) (t : ℤ) (hpend : objAt g t = true) :
    PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ t (PlusFormula.stab gapR)
      ↔ cntAt g t + 1 < nxtAt g t := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    by_contra hne
    have hle : nxtAt g t ≤ cntAt g t + 1 := by omega
    obtain ⟨ρ, hρ⟩ := exists_hist_of_isLadderPath fwdT bwdT
      (gapPath t (cntAt g t) (nxtAt g t)) (gapPath_isLadderPath t _ _ hle)
    have hstate : σ.state t = ρ.state t := by
      rw [hσ t, hρ t, gapPath_eq_of_pend g t hpend]
    have hα := h ρ hstate
    unfold gapR at hα
    rw [PlusTruth.neg_iff] at hα
    apply hα
    unfold betaR
    rw [PlusTruth.untl_iff]
    refine ⟨t + (cntAt g t : ℤ) + 1, ?_, ?_, ?_⟩
    · change (t : ℤ) < t + (cntAt g t : ℤ) + 1
      omega
    · unfold gapEventR
      rw [PlusTruth.and_iff, PlusTruth.and_iff, PlusTruth.neg_iff, nextR_iff, nextR_iff,
        nextR_iff, PlusTruth.neg_iff, truth_rR_iff _ ρ hρ, truth_rR_iff _ ρ hρ,
        truth_rR_iff _ ρ hρ, gapPath_objAt, gapPath_objAt, gapPath_objAt]
      refine ⟨by simp, by simp; omega, by simp; omega⟩
    · intro (r : ℤ) h1 h2
      have h1' : (t : ℤ) < r := h1
      have h2' : r < t + (cntAt g t : ℤ) + 1 := h2
      rw [truth_rR_iff _ ρ hρ, gapPath_objAt]
      simp; omega
  · intro hgap ρ hstate
    obtain ⟨k, hh, hhp, hρp⟩ := exists_isLadderPath_of_hist fwdT bwdT ρ
    have hpair : ((t + k : ℤ), hh t) = ((t : ℤ), g t) := by
      rw [← hρp t, ← hstate, hσ t]
    have hk : k = 0 := by
      have := congrArg Prod.fst hpair
      simp at this
      omega
    subst hk
    have hht : hh t = g t := by
      have := congrArg Prod.snd hpair
      simpa using this
    have hρ : ∀ s : ℤ, ρ.state s = (s, hh s) := fun s => by
      rw [hρp s, add_zero]
    have hc : cntAt hh t = cntAt g t := by simp [cntAt, hht]
    have hn : nxtAt hh t = nxtAt g t := by simp [nxtAt, hht]
    have hp0 : pendT (objAt hh t) = true := by simpa [pendT, objAt, hht] using hpend
    have hrun := cntAt_sub_of_pend hh hhp t hp0
    unfold gapR
    rw [PlusTruth.neg_iff]
    intro hβ
    unfold betaR at hβ
    rw [PlusTruth.untl_iff] at hβ
    obtain ⟨(s : ℤ), hs, hχ, hguard⟩ := hβ
    have hs' : (t : ℤ) < s := hs
    unfold gapEventR at hχ
    rw [PlusTruth.and_iff, PlusTruth.and_iff, PlusTruth.neg_iff, nextR_iff, nextR_iff,
      nextR_iff, PlusTruth.neg_iff, truth_rR_iff _ ρ hρ, truth_rR_iff _ ρ hρ,
      truth_rR_iff _ ρ hρ] at hχ
    obtain ⟨hidle, hpend1, hidle2⟩ := hχ
    have hlast := hrun (cntAt hh t) le_rfl
    have hse : s = t + (cntAt hh t : ℤ) + 1 := by
      by_contra hne
      rcases lt_or_gt_of_ne hne with hlt | hgt
      · have hj := hrun (s - t).toNat (by omega)
        rw [show t + (((s - t).toNat : ℕ) : ℤ) = s by omega] at hj
        exact hidle (by simpa [pendT] using hj.1)
      · have hg1 : PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) ρ
            (t + (cntAt hh t : ℤ) + 1) rR :=
          hguard (t + (cntAt hh t : ℤ) + 1) (by change (t : ℤ) < _; omega) hgt
        rw [truth_rR_iff _ ρ hρ] at hg1
        have hstep := cntAt_succ_of_pend_pend hh hhp (t + (cntAt hh t : ℤ)) hlast.1
          (by simpa [pendT] using hg1)
        omega
    have hidle' : pendT (objAt hh s) = false := by simpa [pendT] using hidle
    have hc1 : cntAt hh (s + 1) = nxtAt hh s :=
      cntAt_eq_nxtAt_of_idle_pend hh hhp s hidle' (by simpa [pendT] using hpend1)
    have hz := (cntAt_eq_zero_of_pend_idle hh hhp (s + 1) (by simpa [pendT] using hpend1)
      (by simpa [pendT] using hidle2)).1
    have hlip := nxtAt_lipschitz_two_sided hh hhp s t
    omega

/-- **THE READING AT COUNTDOWN `0`.** At a pending state whose countdown is exhausted the bit is
`2 ≤ n`: a function of the register alone, and of its clipped value at any threshold `Tn ≥ 2`.
This is the measurement point at which the countdown threshold is vacuous. -/
theorem stab_gapR_iff_of_cnt_zero (g : ℤ → LadderState Bool pendT)
    (σ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame)
    (hσ : ∀ s : ℤ, σ.state s = (s, g s)) (t : ℤ) (hpend : objAt g t = true)
    (hcnt : cntAt g t = 0) :
    PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ t (PlusFormula.stab gapR)
      ↔ 2 ≤ nxtAt g t := by
  rw [stab_gapR_iff g σ hσ t hpend, hcnt]
  omega

/-- **THE GAP READING IS CONSUMED, AT EVERY PENDING STATE.** Equality of the signed gap `n − c`
at two pending states delivers the agreement of this bit, whatever the two countdowns are and
whether or not they are equal — above any positive countdown threshold and at countdown `0`
alike.

Sufficiency for `gapR`, not for a closure: nothing here says the gap is the only quantity a `⊡`
bit reads at a pending state. -/
theorem stab_gapR_eq_of_gap_eq (g h : ℤ → LadderState Bool pendT)
    (σ τ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame)
    (hσ : ∀ s : ℤ, σ.state s = (s, g s)) (hτ : ∀ s : ℤ, τ.state s = (s, h s))
    (t t' : ℤ) (hgp : objAt g t = true) (hhp : objAt h t' = true)
    (hgap : (nxtAt g t : ℤ) - cntAt g t = (nxtAt h t' : ℤ) - cntAt h t') :
    PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ t (PlusFormula.stab gapR)
      ↔ PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) τ t' (PlusFormula.stab gapR) := by
  rw [stab_gapR_iff g σ hσ t hgp, stab_gapR_iff h τ hτ t' hhp]
  omega

/-- **THE CLIPPED REGISTER READING IS REFUTED AT A PENDING STATE, AT EVERY COUNTDOWN
`c ≥ Tn − 1`.** For every register threshold `Tn`, every `P` and every countdown `c` with
`Tn ≤ c + 1` there are two ladder paths whose states at `0` are both pending, share the countdown
`c`, share the clipped register `min · Tn` AND the register residue modulo `P + 1`, and whose
`⊡ gapR` bits DIFFER. The registers are `c + 1` and `c + 1 + (P + 1)`: both at or above `Tn`,
congruent modulo `P + 1`, and on opposite sides of the gap threshold.

The countdown is arbitrary above `Tn − 1`, so the refutation sits above any positive countdown
threshold whatever. What is refuted is the clipped/residue CONJUNCTION as a sufficient condition
for this bit, not merely its clipped half. -/
theorem stab_gapR_ne_of_clipped_eq (Tn P c : ℕ) (hc : Tn ≤ c + 1) :
    ∃ (g h : ℤ → LadderState Bool pendT)
      (σ τ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame),
      IsLadderPath stepT pendT g ∧ IsLadderPath stepT pendT h ∧
      (∀ s : ℤ, σ.state s = (s, g s)) ∧ (∀ s : ℤ, τ.state s = (s, h s)) ∧
      objAt g 0 = true ∧ objAt h 0 = true ∧ cntAt g 0 = c ∧ cntAt h 0 = c ∧
      min (nxtAt g 0) Tn = min (nxtAt h 0) Tn ∧
      nxtAt g 0 % (P + 1) = nxtAt h 0 % (P + 1) ∧
      ¬ (PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ 0 (PlusFormula.stab gapR)
          ↔ PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) τ 0
              (PlusFormula.stab gapR)) := by
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdT bwdT
    (pendPath 0 c (c + 1)) (pendPath_isLadderPath 0 c (c + 1))
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdT bwdT
    (pendPath 0 c (c + 1 + (P + 1))) (pendPath_isLadderPath 0 c (c + 1 + (P + 1)))
  refine ⟨pendPath 0 c (c + 1), pendPath 0 c (c + 1 + (P + 1)), σ, τ,
    pendPath_isLadderPath 0 c _, pendPath_isLadderPath 0 c _, hσ, hτ, by simp, by simp,
    by simp, by simp, ?_, by simp, ?_⟩
  · rw [pendPath_nxtAt_self, pendPath_nxtAt_self]
    omega
  · intro hiff
    rw [stab_gapR_iff _ σ hσ 0 (by simp), stab_gapR_iff _ τ hτ 0 (by simp)] at hiff
    simp only [pendPath_cntAt_self, pendPath_nxtAt_self] at hiff
    omega

/-- **THE CLIPPED REGISTER READING IS CONSUMED ONLY WHERE THE COUNTDOWN IS SHORT.** At two
pending states with EQUAL countdown `c` and `c + 2 ≤ Tn`, the clipped register `min · Tn`
delivers the agreement of this bit. Countdown `0` is in scope at every `Tn ≥ 2`.

Together with `stab_gapR_ne_of_clipped_eq` this is the difference between the two measurement
points: the clipped register is consumed on the slice `c + 2 ≤ Tn` and refuted at every
`c ≥ Tn − 1`, with nothing in between. -/
theorem stab_gapR_eq_of_clipped_eq_of_low (g h : ℤ → LadderState Bool pendT)
    (σ τ : WorldHistory (ladderFrameAdm stepT pendT fwdT bwdT).toTaskFrame)
    (hσ : ∀ s : ℤ, σ.state s = (s, g s)) (hτ : ∀ s : ℤ, τ.state s = (s, h s))
    (t t' : ℤ) (hgp : objAt g t = true) (hhp : objAt h t' = true)
    (hcnt : cntAt g t = cntAt h t') (Tn : ℕ) (hlow : cntAt g t + 2 ≤ Tn)
    (hclip : min (nxtAt g t) Tn = min (nxtAt h t') Tn) :
    PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) σ t (PlusFormula.stab gapR)
      ↔ PlusTruthAt (ladderModel stepT pendT fwdT bwdT labR) τ t' (PlusFormula.stab gapR) := by
  rw [stab_gapR_iff g σ hσ t hgp, stab_gapR_iff h τ hτ t' hhp]
  omega

end PendingConsumer

section GapProducer

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE PRODUCER LEG: the gap-shaped register conjunct forces the original's gap not to rise
across the block.** If a ladder path `g'` is pending at position `j` of copies `0` and `1` of the
block `[u, u + l)` and carries there the signed gap `n − c` of the original at `u + j`, then the
original's gap at the block's last position is at most its gap at the block's first.

The top of copy `0` and the bottom of copy `1` are one step of `g'` apart and both pending, so the
countdown falls by exactly one (`cntAt_succ_of_pend_pend`) while the register moves by at most one
(`nxtAt_drift`): the gap moves by `0`, `1` or `2` and never down. The conjunct identifies those two
gaps with the original's at the block's last and first positions.

Generic in the object and in both paths. The pendingness of `g'` at the copy positions is what the
iterated splice's object clause delivers on a block of a pending past, and it is carried in the
hypothesis because without it an idle-to-pending step could drop the gap. -/
theorem iterSpliced_gap_interior_forces_block_gap_le
    (g : ℤ → LadderState Q pend) {g' : ℤ → LadderState Q pend}
    (hg' : IsLadderPath step pend g') (u : ℤ) (l : ℕ) (hl : 0 < l)
    (hgap : ∀ i j : ℕ, i ≤ 1 → j < l →
      pend (objAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))) = true ∧
      (nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ)) : ℤ)
          - cntAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))
        = (nxtAt g (u + (j : ℤ)) : ℤ) - cntAt g (u + (j : ℤ))) :
    (nxtAt g (u + ((l - 1 : ℕ) : ℤ)) : ℤ) - cntAt g (u + ((l - 1 : ℕ) : ℤ))
      ≤ (nxtAt g u : ℤ) - cntAt g u := by
  have hcast : ((l - 1 : ℕ) : ℤ) = (l : ℤ) - 1 := by omega
  have h0 := hgap 0 (l - 1) (by omega) (by omega)
  have e0 : u + ((0 * l : ℕ) : ℤ) + ((l - 1 : ℕ) : ℤ) = u + ((l - 1 : ℕ) : ℤ) := by
    push_cast; ring
  rw [e0] at h0
  have h1 := hgap 1 0 le_rfl hl
  have e1 : u + ((1 * l : ℕ) : ℤ) + ((0 : ℕ) : ℤ) = u + ((l - 1 : ℕ) : ℤ) + 1 := by
    rw [hcast]; push_cast; ring
  rw [e1] at h1
  simp only [Nat.cast_zero, add_zero] at h1
  have hd := nxtAt_drift g' hg' (u + ((l - 1 : ℕ) : ℤ))
  have hc := cntAt_succ_of_pend_pend g' hg' (u + ((l - 1 : ℕ) : ℤ)) h0.1 h1.1
  unfold Drift at hd
  omega

end GapProducer

end FormalSystem.Metalogic.Decidability.RaySummary

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

/-!
# ROUTE (a), COMPILED: `ForwardSlackWitnessed` at EVERY amount from one run-local premise

**POSITIVE.** This file is the research-phase measurement that a cascade-free, deletion-free
discharge route for `ForwardSlackWitnessed` exists and is assembled entirely from LANDED
machinery. It passes through no block deletion inside the first region above `z`'s region (the
route refuted in the parent task) and spends none of `(K2)`'s `cascadeBound`: the only surgery
is the duplication of an idle block inside the idle run SEPARATING `z`'s region from the next
one, whose pin clause `idleSplice_pins` (`LadderPump.lean`) discharges unconditionally.

## The two statements

`hasForwardSlack_of_idleRunRepeat` — the path level. Given a path pending forever into the past
at `z`, in the pending-forever gap, whose intervening idle run carries a `k`-block matching in
object state and in realized stab-free type, and given `d` with `l ≤ d * k`: there is a path
agreeing with the original in all three components at `z`, realizing the SAME stab-free type at
`z`, and carrying `HasForwardSlack · z l (nxtAt g z)`.

`forwardSlackWitnessed_of_cell_idleRunPumpable` — the cell level. If every type the cell at `x`
realizes is realized there by SOME path meeting that run-local premise, then
`ForwardSlackWitnessed … x z l x.1.2.2` holds — for EVERY `l`. The amount disappears from the
premise, which is the asymmetry that makes this route work where the deletion route could not:
the deletion had to buy `l` units of a quantity the saturated register already spent, whereas
the pump MANUFACTURES `d * k` units of idle run at a cost of nothing.

## Why no pin obligation survives

The regime asks `K ≤ n + cntAt g z + I - l`, where `K` is the next region's countdown and `I`
the length of the intervening idle run. The free Lipschitz bound every ladder path already
carries is `K ≤ n + cntAt g z + I` (`nxtAt_lipschitz_two_sided` composed with
`cntAt_eq_nxtAt_of_idle_pend`, which is `hasForwardSlack_zero`'s content). The idle pump leaves
`K` UNTOUCHED (`idleGapLengtheningOfIdleRunRepeat_holds`'s displaced-region-start clause) and
raises `I` by `d * k`, so the deficit is paid out of the pumped run and the original bound is
reused verbatim. Pin compatibility never enters: the duplicated idle block contributes no pin
of its own, and the pins above it move FARTHER from those below while their values stay put.

## What this does NOT establish

The premise is a datum of the object's step graph MET BY THIS PATH and is NOT a consequence of
`ParamsOk`: `idle_run_lt_tIdle_of_no_idleCycle` (`LadderPump.lean`) bounds every idle run below
`tIdle pend` when the object has no idle cycle, and no parameter condition supplies one — (K1)
quantifies `prodCycleLens`, `objCycleLens` and `satPeriod`, never `idleCycleLens`. So this is a
CONDITIONAL discharge: it relocates the hypothesis from an opaque existential over paths at a
given amount onto a checkable, amount-free run-local condition. It does not remove
`ForwardSlackWitnessed` from the five depth-`0` cell-equality schemas, and it says nothing about
the complementary side, where the intervening run has length `1`.
-/

namespace Probe924

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary

set_option linter.unusedFintypeInType false

/-- **THE PATH LEVEL.** The pumped path sits at the same ladder state at `z`, realizes the same
stab-free type there, and carries the forward-slack regime at amount `l`. -/
theorem hasForwardSlack_of_idleRunRepeat {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (z : ℤ) (I k d l : ℕ) (a : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hgap : nxtAt g z + 2 ≤ cntAt g z)
    (hI : 0 < I) (hk : 0 < k) (hd : 0 < d)
    (hrun : ∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false)
    (hstart : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true)
    (hRa : z + (cntAt g z : ℤ) + 1 ≤ a)
    (hak : a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ))
    (hrep : objAt g a = objAt g (a + (k : ℤ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ a
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)))
    (hpay : l ≤ d * k) :
    ∃ (g' : ℤ → LadderState Q pend)
      (σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      IsLadderPath step pend g' ∧ (∀ t : ℤ, σ'.state t = (t, g' t)) ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z l (nxtAt g z) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ' z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  obtain ⟨g', hg', hoz, hcz, hnz, hrun', hstart', hcnt', htyc⟩ :=
    idleGapLengtheningOfIdleRunRepeat_holds step pend fwd bwd lab φ hno g hg σ hσ
      z I k d a hpast hgap hI hk hd hrun hstart hRa hak hrep hty
  obtain ⟨σ', hσ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine ⟨g', σ', hg', hσ', hoz, hcz, hnz, ?_, htyc σ' hσ'⟩
  refine hasForwardSlack_of_next_region_cnt_le g' hg' z l (nxtAt g z) ?_
  intro J hJ hidleJ hpendJ
  -- the pumped idle run has length EXACTLY `I + d * k`, so the regime's `∀ I` is one instance
  have hJeq : J = I + d * k := by
    by_contra hne
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact Bool.false_ne_true ((hrun' J hlt).symm.trans hpendJ)
    · exact Bool.false_ne_true ((hidleJ (I + d * k) (by omega)).symm.trans hstart')
  subst hJeq
  have hidleu : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ))) = false := by
    have h := hrun (I - 1) (by omega)
    rwa [show z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ)
        = z + (cntAt g z : ℤ) + (I : ℤ) by
      push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring] at h
  have hpendu : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rwa [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
  have hK := cntAt_eq_nxtAt_of_idle_pend g hg _ hidleu hpendu
  have hlip := nxtAt_lipschitz_two_sided g hg (z + (cntAt g z : ℤ) + (I : ℤ)) z
  rw [hcnt', hcz]
  rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ)
    by ring] at hK
  rw [hK]
  have hc0 : (0 : ℤ) ≤ (cntAt g z : ℤ) := Int.natCast_nonneg _
  have hI0 : (0 : ℤ) ≤ (I : ℤ) := Int.natCast_nonneg _
  push_cast at hlip ⊢
  omega

/-- **THE RUN-LOCAL PREMISE.** The path is pending forever into the past at `z`, sits in the
pending-forever gap, and its intervening idle run carries an `(objAt, tpOf)`-repeat block. The
third conjunct is what `exists_idleTypeBlock_of_budget_le_run` produces from a run of length at
least `idleBudget pend φ`. -/
def IdleRunPumpable {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (g : ℤ → LadderState Q pend)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) : Prop :=
  (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧
  nxtAt g z + 2 ≤ cntAt g z ∧
  ∃ (I k : ℕ) (a : ℤ), 0 < I ∧ 0 < k ∧
    (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) ∧
    pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true ∧
    z + (cntAt g z : ℤ) + 1 ≤ a ∧ a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ) ∧
    objAt g a = objAt g (a + (k : ℤ)) ∧
    tpOf (ladderModel step pend fwd bwd lab) φ σ a
      = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ))

/-- **THE CELL LEVEL: `ForwardSlackWitnessed` AT EVERY AMOUNT.** The amount `l` is universally
quantified in the conclusion and appears NOWHERE in the premise — `d := l + 1` pumps as much
idle run as the amount demands. -/
theorem forwardSlackWitnessed_of_cell_idleRunPumpable {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (x : LadderState Q pend) (z : ℤ) (l : ℕ)
    (hprem : ∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z,
      ∃ (g : ℤ → LadderState Q pend)
        (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        IsLadderPath step pend g ∧ g z = x ∧ (∀ t : ℤ, σ.state t = (t, g t)) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ z = T ∧
        IdleRunPumpable step pend fwd bwd lab φ g σ z) :
    ForwardSlackWitnessed step pend fwd bwd lab φ x z l x.1.2.2 := by
  intro T hT
  obtain ⟨g, σ, hg, hgz, hσ, htp, hpast, hgap, I, k, a, hI, hk, hrun, hstart, hRa, hak,
    hrep, hty⟩ := hprem T hT
  have hpay : l ≤ (l + 1) * k := by
    calc l ≤ (l + 1) * 1 := by omega
    _ ≤ (l + 1) * k := Nat.mul_le_mul_left _ hk
  obtain ⟨g', σ', hg', hσ', hoz, hcz, hnz, hslack, htyeq⟩ :=
    hasForwardSlack_of_idleRunRepeat step pend fwd bwd lab φ hno hg σ hσ z I k (l + 1) l a
      hpast hgap hI hk (by omega) hrun hstart hRa hak hrep hty hpay
  have hnxtx : nxtAt g z = x.1.2.2 := by rw [← hgz]; rfl
  have hg'z : g' z = x := by
    refine Subtype.ext (Prod.ext ?_ (Prod.ext ?_ ?_))
    · rw [← hgz]; exact hoz
    · rw [← hgz]; exact hcz
    · rw [← hgz]; exact hnz
  exact ⟨g', σ', hg', hg'z, hσ', hnxtx ▸ hslack, htyeq.trans htp⟩

end Probe924

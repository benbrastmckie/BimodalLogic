/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

/-!
# The route space of the `ForwardSlackWitnessed` frontier, closed on the non-pumpable side

The regime asks `K ≤ n + cntAt g z + I - l`, with `K` the countdown of the first region above
`z`'s region and `I` the length of the idle run separating them. `n` and `cntAt g z` are PINNED
by `g z = x`, so only two dials exist: raise `I`, or lower `K`. The idle dial is the route that
has LANDED in the library (see the companion positive record below); this file measures the `K`
dial and the remaining placements, so that what is left open is exactly one named sub-regime
rather than an unsurveyed space.

* **C1/C2/C3** (namespace `Probe924B`) close the placement question. A type-respecting block has
  endpoints of equal OBJECT state, hence of equal pendingness, so no block spans a region
  boundary; the landed deletion's own `hcl : l ≤ cntAt g a` confines its block to the interior of
  ONE pending region, so a landed deletion never removes an idle position, never removes a whole
  region, and never reduces the pin SET — which is why the straddling pair the parent task
  refuted always survives; and the pumpable premise needs an idle run of length at least two,
  which is the idle-gap lengthening's own recorded premise and not a consequence of `ParamsOk`.
* **The `AvailWhole` measurement** (namespace `Probe924C`) measures the one dial the landed
  machinery does not implement: a PIN-SET-REDUCING deletion of an idle-aligned block spanning
  whole regions. Such a deletion is pin-RIGID — every surviving pin moves by the same amount, so
  the surviving pairs inherit their compatibility and no cascade is entered — and its only
  obligation is the anchor at the pin that becomes first. That anchor FAILS on the same saturated
  configuration the parent task measured, by at least `l`, for every choice of which regions to
  delete: on a maximally climbing register a later pin carries a LARGER value, so moving it into
  first position makes the anchor worse rather than better. The second theorem records that the
  saturated assignment is `cascadeBound`'s `iter_doubling` recurrence attained with EQUALITY, so
  this dial fails for the parent task's reason and not for a new one.

## The companion positive record

This file is the NEGATIVE half of a pair. The positive half has landed in
`FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` as three declarations:

* `hasForwardSlack_of_idleRunRepeat` -- the path level: the pumped path sits at the same ladder
  state at `z`, realizes the same stab-free type there, and carries the forward-slack regime at
  the amount asked of it.
* `IdleRunPumpable` -- the run-local premise as a named predicate: pending-forever past at `z`,
  the pending-forever gap, and an `(objAt, tpOf)`-repeat block inside the intervening idle run.
* `forwardSlackWitnessed_of_cell_idleRunPumpable` -- the cell level: `ForwardSlackWitnessed` at
  EVERY amount `l`, from that amount-free run-local premise.

That route raises the idle dial `I` rather than lowering `K`, so it never spends any part of
`(K2)`'s `cascadeBound` and never re-enters the doubling cascade the parent task refuted. Its
discharge is CONDITIONAL: `IdleRunPumpable` is a run-local datum that `ParamsOk` does not supply
-- `(K1)` quantifies `prodCycleLens`, `objCycleLens` and `satPeriod`, never `idleCycleLens`.

## What this file does and does not establish

What this file measures is the `K` dial and the placements, and nothing else. Both namespaces are
measurements at the arithmetic and placement layers. NEITHER IS A REFUTATION OF
`ForwardSlackWitnessed`, which is an existential over paths and remains neither discharged nor
refuted on the non-pumpable side -- the paths whose intervening idle run has length `1`, where
`C3`'s `2 ≤ I` is unavailable. Nothing here removes `ForwardSlackWitnessed` from the five
depth-`0` cell-equality schemas of `LadderCell.lean`: it stays a carried hypothesis, every
consumer must supply it, and `certStabK`'s condition must still be RESTATED rather than proved.
-/

namespace Probe924B

open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **C1. A TYPE-RESPECTING BLOCK CANNOT SPAN A REGION BOUNDARY.** -/
theorem pend_endpoints_of_rep (g : ℤ → LadderState Q pend) (u : ℤ) (d : ℕ)
    (hrep : objAt g u = objAt g (u + (d : ℤ))) :
    pend (objAt g u) = pend (objAt g (u + (d : ℤ))) := by rw [hrep]

/-- **C2. THE LANDED DELETION'S OWN `hcl` CONFINES THE BLOCK TO ONE PENDING REGION.** -/
theorem block_confined_of_hcl {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (a : ℤ) (l : ℕ) (hpa : pend (objAt g a) = true) (hcl : l ≤ cntAt g a) :
    ∀ j : ℕ, j ≤ l → pend (objAt g (a + (j : ℤ))) = true :=
  fun j hj => (cntAt_sub_of_pend g hg a hpa j (le_trans hj hcl)).1

/-- **C3. THE PUMPABLE PREMISE NEEDS AN IDLE RUN OF LENGTH AT LEAST TWO.** -/
theorem idle_run_two_of_block {g : ℤ → LadderState Q pend} (z : ℤ) (I k : ℕ) (a : ℤ)
    (hk : 0 < k) (R : ℤ) (hR : R = z + (cntAt g z : ℤ) + 1)
    (hstart : pend (objAt g (R + (I : ℤ))) = true)
    (hRa : R ≤ a) (hak : a + (k : ℤ) ≤ R + (I : ℤ))
    (hidleA : pend (objAt g a) = false)
    (hrep : objAt g a = objAt g (a + (k : ℤ))) :
    2 ≤ I := by
  have hne : a + (k : ℤ) ≠ R + (I : ℤ) := by
    intro h
    rw [h] at hrep
    rw [hrep] at hidleA
    exact Bool.false_ne_true (hidleA.symm.trans hstart)
  have hkz : (1 : ℤ) ≤ (k : ℤ) := by exact_mod_cast hk
  omega

end Probe924B

namespace Probe924C

/-- Every fact a PIN-SET-REDUCING deletion could use about the pin that would become the first
one above `z`'s region: the nonnegativity of the `ℕ`-valued quantities, the consumer's gap, a
non-empty idle run, the pin's position strictly above `z`'s region and its idle run, and the
register's two-sided `1`-Lipschitz bound from `z` read at that pin. -/
def AvailWhole (z C N I l p K : ℤ) : Prop :=
  0 ≤ C ∧ 0 ≤ N ∧ 0 ≤ K ∧ 0 < l ∧ 1 ≤ I ∧ N + 2 ≤ C ∧
  z + C + I + 1 ≤ p ∧
  (K - N).natAbs ≤ (p - z).natAbs

/-- **THE PIN-SET-REDUCING DIAL FAILS ON THE SAME SATURATED CONFIGURATION, by at least `l`.** -/
theorem whole_region_anchor_refuted (z C N I l p : ℤ)
    (hC : 0 ≤ C) (hN : 0 ≤ N) (hl : 0 < l) (hI : 1 ≤ I) (hgap : N + 2 ≤ C)
    (hp : z + C + I + 1 ≤ p) :
    AvailWhole z C N I l p (N + (p - z)) ∧ ¬ (N + (p - z) ≤ N + C + I - l) := by
  refine ⟨⟨hC, hN, by omega, hl, hI, hgap, hp, ?_⟩, by omega⟩
  have h : (N + (p - z) - N) = p - z := by ring
  rw [h]

/-- **THE SATURATED ASSIGNMENT IS THE DOUBLING RECURRENCE'S OWN FIXED POINT.** -/
theorem saturated_chain_is_the_doubling_recurrence (z N p I' : ℤ)
    (K K' : ℤ) (hK : K = N + (p - z)) (hp' : K' = N + ((p + K + I' + 1) - z)) :
    K' = 2 * K + I' + 1 := by
  subst hK; subst hp'; ring

end Probe924C

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell
import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle

/-!
# The ordinary window regime of the depth-`0` cell obligation

## Contract

This module holds the ORDINARY WINDOW regime `c ≤ n + 1` of the depth-`0` cell obligation, and
only that. It is the exact complement of the pending-forever gap `n + 2 ≤ c` that all five
hypothesis-strengthened schemas of `LadderCell.lean` carry: `cntAt_le_nxtAt_succ_of_idle_past`
(`LadderAgree.lean`) puts a pending position with ANY idle position in its past inside this
window, and `pend_past_of_nxtAt_lt` puts a pending position with `n + 2 ≤ c` on a path pending at
every earlier position. So the two regimes are the two branches of one dichotomy, and the landed
schemas address exactly the other branch.

Nothing here claims the reserved `cellLE_zero_const_of_kappa_eq`, and no declaration in this
module carries that name or any prefix of it: the reserved statement stays claimed by nothing.
Nothing here touches `ForwardSlackWitnessed` — this regime's compensator is the IDLE RUN BELOW
the position, not slack above it, which is the whole reason the regime is reachable at all and
the reason the refuted deletion-above route is not re-entered. Nothing here touches `ParamsOk`'s
own conditions: `paramsOkK1` and its three siblings are consumed where a bridge needs them and
are amended nowhere.

## What this module holds

The window regime's ARITHMETIC layer — four statements, each measured by compilation rather than
asserted, each scale-invariant in the displacement:

* `kappa_collision_window_room` — a `kappa` collision at a fixed next-deadline register, read in
  this regime, either pins the two countdowns equal or exhibits a positive displacement by a
  multiple of `P + 1` TOGETHER WITH the strict room `c' ≤ n` for whichever countdown is the
  larger. The room is not an added assumption: it is `clipIdx_regime_of_eq`'s own disjunction
  with the gap branch killed by the regime hypothesis, so it is the GAP COORDINATE of the counter
  quotient that pays for it.
* `window_anchor_compat_of_room` — that room is exactly the anchor clause of the `z`-anchored
  lift `exists_ladderPath_of_walk_nxt_at` at the region start below `z`, once an in-region
  duplication has raised that start's countdown by the displacement. Its hypothesis
  `hlow : n ≤ c + 2 * d` is the original path's own pin equation (`cntAt_eq_nxtAt_of_idle_pend`,
  `cntAt_add_of_pend_back`) composed with `nxtAt_lipschitz`, not a new hypothesis.
* `window_pin_compat_raise_of_gap` — the pin PAIR clause in the RAISING direction: raising a
  countdown by `jP` costs at most `jP` of pin slack, which the compensating idle insertion below
  returns in full.
* `window_pin_compat_lower_of_spacing` — the pin pair clause in the LOWERING direction,
  discharged from region-start spacing alone (`W + 1 + jP ≤ DW`, i.e. the idle run being
  shortened is at least as long as the displacement).

In the three pin statements `jP` is an OPAQUE natural number. The arithmetic never reads it as
`j · (P + 1)`, so none of these statements depends on the modulus, on `(K1)`, or on any
parameter tuple; they are the regime's scale-invariant skeleton and nothing more.

## What this module does not hold

No path-level construction, no cell-level inclusion, and no schema: those are the regime's
LAYER B and sit behind a decision gate measured separately. Nothing here is a realization
theorem, nothing is claimed about `HitPresented` or `PlusValidZTime`, no index of a ladder cell
is claimed at any parameters, and no complexity bound is claimed.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-- **The window regime's room, read off a `kappa` collision at a fixed register.** At `2 ≤ B`
(which `(K4)` requires), a class collision between `(c, n)` and `(c', n)` in the ORDINARY WINDOW
regime — both countdowns inside `c ≤ n + 1`, the complement of the pending-forever gap — either
pins `c = c'` or exhibits a POSITIVE multiple of `P + 1` separating them together with the strict
room `c' ≤ n` for whichever of the two is larger.

What this measures: the room is the GAP COORDINATE paying for itself. `clipIdx_regime_of_eq`
reads a collision at a fixed register as `c' ≤ n ∨ n + 2 ≤ c` for the smaller countdown `c`; the
window hypothesis kills the second branch outright, so the regime's own hypothesis `c ≤ n + 1` is
UPGRADED to `c' ≤ n` by the collision itself. No assumption is added to obtain it.

What this does not measure: nothing about whether a path realizing one of the two counter states
can be surgered into one realizing the other. That is the path-level layer, and this statement is
one of its inputs, not a substitute for it. -/
theorem kappa_collision_window_room (Tc Tn P B c n c' : ℕ) (hB : 2 ≤ B)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n))
    (hwin : ¬ (n + 2 ≤ c)) (hwin' : ¬ (n + 2 ≤ c')) :
    c = c' ∨ ∃ j : ℕ, 0 < j ∧
      ((c' = c + j * (P + 1) ∧ c' ≤ n) ∨ (c = c' + j * (P + 1) ∧ c ≤ n)) := by
  obtain ⟨-, hrc, -, -, hcl⟩ := kappa_eq_components Tc Tn P B c n c' n hk
  rcases lt_trichotomy c c' with hlt | heq | hgt
  · have hn : c' ≤ n := by
      rcases clipIdx_regime_of_eq B c c' n hB hlt hcl with h | h
      · exact h
      · omega
    obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' (le_of_lt hlt)).mp hrc
    rw [Nat.mul_comm] at hj
    exact Or.inr ⟨j, by
      rcases Nat.eq_zero_or_pos j with hz | hp
      · subst hz; omega
      · exact hp, Or.inl ⟨by omega, hn⟩⟩
  · exact Or.inl heq
  · have hn : c ≤ n := by
      rcases clipIdx_regime_of_eq B c' c n hB hgt hcl.symm with h | h
      · exact h
      · omega
    obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' (le_of_lt hgt)).mp hrc.symm
    rw [Nat.mul_comm] at hj
    exact Or.inr ⟨j, by
      rcases Nat.eq_zero_or_pos j with hz | hp
      · subst hz; omega
      · exact hp, Or.inr ⟨by omega, hn⟩⟩

/-- **The room IS the `z`-anchored lift's anchor clause after the raise.** At the region start
`a = z - d` below `z`, a raise of the countdown by `jP` leaves the anchor datum
`|(c + d + jP) - n|` within the displacement `d` from `z`, provided the window regime's room
`c + jP ≤ n` holds and the start's own pin equation gives `n ≤ c + 2 * d`.

What this measures: `exists_ladderPath_of_walk_nxt_at`'s anchor clause at the region start,
stated in the raised coordinates. The hypothesis `hlow` is NOT a new assumption on the caller: it
is the landed path's own pin equation at `a` (`cntAt_eq_nxtAt_of_idle_pend`, together with
`cntAt_add_of_pend_back` reading `cntAt g a = cntAt g z + d`) composed with the `1`-Lipschitz
bound `nxtAt_lipschitz` from `a` up to `z`.

What this does not measure: `jP` is opaque here, so this says nothing about the modulus and
nothing about which displacements a particular collision admits. -/
theorem window_anchor_compat_of_room (c n d jP : ℕ) (hroom : c + jP ≤ n)
    (hlow : n ≤ c + 2 * d) :
    (((c + d + jP : ℕ) : ℤ) - (n : ℤ)).natAbs ≤ d := by
  omega

/-- **Raising costs at most the displacement, and the compensator returns it.** A pin pair whose
distance bound `DW` holds of the unraised countdown holds of the raised one at the bound widened
by exactly the displacement `jP`.

What this measures: the pin pair clause in the RAISING direction, scale-invariantly. The reason
this is usable rather than a bare restatement is the compensator: splicing the same displacement
into the idle run immediately BELOW the region grows every lower pin's distance by exactly `jP`,
which is what the widened `DW + jP` asks for, and `idleSplice_pins` (`LadderPump.lean`)
discharges that splice's own pin clause with no regime hypothesis and no side condition.

What this does not measure: `jP` is opaque, so the statement never reads `j · (P + 1)` as such
and depends on no parameter tuple. -/
theorem window_pin_compat_raise_of_gap (c d W jP DW : ℕ)
    (horig : (((c + d : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW) :
    (((c + d + jP : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW + jP := by
  omega

/-- **Lowering is paid for by region-start spacing alone.** Shortening the idle run by `jP`
tightens a pin pair's bound to `DW - jP`, and the lowered countdown still satisfies it, given the
spacing `W + 1 + jP ≤ DW` — i.e. given that the run being shortened was at least as long as the
displacement.

What this measures: the pin pair clause in the LOWERING direction. The hypothesis `hsp` is a
statement about region-start SPACING, not about the collision: it says the distance budget `DW`
already exceeded the pin position by more than the displacement, which is what a sufficiently
long idle run below supplies.

What this does not measure: `jP` is opaque, so nothing here reads the modulus. -/
theorem window_pin_compat_lower_of_spacing (c d W jP DW : ℕ)
    (hsp : W + 1 + jP ≤ DW)
    (horig : ((c + d + jP : ℕ) : ℤ) - (W : ℤ) ≤ (DW : ℤ)) :
    (((c + d : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW - jP := by
  omega

end FormalSystem.Metalogic.Decidability.RaySummary

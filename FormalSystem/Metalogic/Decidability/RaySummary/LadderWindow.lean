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

set_option linter.style.longFile 1700

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

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

/-! ## The decision gate's second layer: the composite splice's clauses

The arithmetic above is the regime's skeleton. What the gate measures is whether the COMPOSITE
surgery — a pending type-respecting block duplicated inside `z`'s region, compensated by an idle
block duplicated inside the idle run immediately BELOW `z`'s region — satisfies every clause of
the `z`-anchored lift `exists_ladderPath_of_walk_nxt_at`.

**The clause inventory, read off that lift's signature rather than from memory.** It asks for six
clauses: `hw` (the walk steps), `hidle` (an idle position carries countdown `0`), `hpp` (the
countdown decrements across a pending-pending step), `hpi` (it is `0` at a region's last pending
position), `hpins` (the pin PAIR clause: `|c (s + 1) - c (v + 1)| ≤ |s - v|` for any two region
starts) and `hn₀` (the ANCHOR clause: `|c (v + 1) - n₀| ≤ |v - z|` for every region start `v`).

**Four of the six are free, and this is a structural fact rather than a convenience.** The
composite walk and countdown are those of a path already built as a ladder path by the landed
splice constructors (`exists_idleSpliced_ladderPath` for the idle half, and the generic
`exists_spliced_ladderPath` for the pending half), so `hw`, `hidle`, `hpp` and `hpi` are
`objAt_step`, `cntAt_eq_zero_of_idle`, `cntAt_succ_of_pend_pend` and
`cntAt_eq_zero_of_pend_idle` on that path. `hpins` is likewise free: it is
`pinCompat_of_ladderPath` on that path, which derives it from the pin equation
`cntAt_eq_nxtAt_of_idle_pend` and the two-sided Lipschitz register
`nxtAt_lipschitz_two_sided`. The lift is re-run only to REPLACE the register that the splice's own
drift extension chose by the PRESCRIBED value `nxtAt g z`, and `hn₀` is the one clause that
prescription is not free for.

**So the gate is the anchor clause `hn₀` at the prescribed `n₀`, pin class by pin class.** By the
pin equation on the composite path, `hn₀` reads `|nxtAt g₂ v - n₀| ≤ |v - z₂|` at every region
start `v`, which two-sided Lipschitzness discharges outright for `n₀ = nxtAt g₂ z₂` — the prescribed
`n₀` is `nxtAt g z` instead, so each pin class must be checked against the ORIGINAL path's
register. The classification of the composite's pins has three classes, and the lemmas below are
the measurement of each:

* a pin strictly BELOW the idle splice: its position and its countdown are the original's, and
  the idle insertion pushes `z` further away, so its distance only grows
  (`window_pin_dist_grows_below`) and the original path's own Lipschitz bound carries over;
* a pin strictly ABOVE `z`'s region: its countdown is the original's and the raise pushes it
  further above `z`, so again the distance only grows (`window_pin_dist_grows_above`);
* the region start of `z`'s OWN region, below `z`: the one pin whose countdown the raise moves,
  because the countdown counts UP into the past inside a pending region. This is the pin the
  pending-forever regime does not have, and `window_anchor_compat_at_region_start` is the
  arithmetic that closes it — from the collision's room and the start's own pin equation, with no
  further hypothesis.

The named idle-run condition `HasIdleRunBelow` below is the ONE hypothesis the composite needs
beyond `ParamsOk`, the two window hypotheses, `Tc ≤ c` and the collision's room. -/

section Gate

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE NAMED IDLE-RUN CONDITION.** The `idleBudget pend φ + 1` positions at and below `a` are
all idle: the idle run immediately below the region start `a` is at least as long as the
idle-restricted pigeonhole's own budget.

This is a CHECKABLE condition on the path — a bounded conjunction of `pend` read-outs — and it is
exactly what `exists_idleTypeBlock_of_budget_le_run`'s `hrun`/`hbud` pair asks for, so it is the
condition under which a type-respecting idle block is available in that run. It is the ONLY
hypothesis the window regime's composite surgery carries beyond `ParamsOk`, the two window
hypotheses, the threshold bound and the collision's own room. It is not a consequence of
`ParamsOk`: `idle_run_lt_tIdle_of_no_idleCycle` (`LadderPump.lean`) is the bound in the other
direction, so assuming it RESTRICTS an obligation rather than discharging one — and the reserved
`cellLE_zero_const_of_kappa_eq` therefore stays claimed by nothing. -/
def HasIdleRunBelow [Fintype Q] (pend : Q → Bool) (φ : PlusFormula)
    (g : ℤ → LadderState Q pend) (a : ℤ) : Prop :=
  ∀ i : ℕ, i ≤ idleBudget pend φ → pend (objAt g (a - (i : ℤ))) = false

/-- **REGION-START SPACING.** Two region starts of a ladder path are at least
`cntAt g (s + 1) + 1` apart: the region beginning at `s + 1` is pending throughout
`[s + 1, s + 1 + cntAt g (s + 1)]`, so a later IDLE position cannot land inside it.

This is Phase 2's third task, confirmed rather than assumed: it is what
`window_pin_compat_lower_of_spacing`'s hypothesis `hsp` consumes, and it is derived here from
`cntAt_sub_of_pend` alone — no parameter condition and no regime hypothesis. -/
theorem regionStart_spacing (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (s v : ℤ) (hs1 : pend (objAt g (s + 1)) = true) (hv0 : pend (objAt g v) = false)
    (hsv : s < v) : s + (cntAt g (s + 1) : ℤ) + 1 ≤ v := by
  by_contra hlt
  have hp := (cntAt_sub_of_pend g hg (s + 1) hs1 (v - (s + 1)).toNat (by omega)).1
  rw [show s + 1 + (((v - (s + 1)).toNat : ℕ) : ℤ) = v by omega] at hp
  exact Bool.false_ne_true (hv0.symm.trans hp)

/-- A pin strictly below the idle splice sits FURTHER from the anchor once the insertion has
pushed the anchor up: the anchor clause at such a pin is strictly looser than on the original
path, so the original's own Lipschitz bound carries it. -/
theorem window_pin_dist_grows_below (v z E : ℤ) (hv : v ≤ z) (hE : 0 ≤ E) :
    (v - z).natAbs ≤ (v - (z + E)).natAbs := by omega

/-- A pin strictly above `z`'s region sits FURTHER from the anchor once the raise has displaced
it: again the anchor clause there is strictly looser than on the original path. -/
theorem window_pin_dist_grows_above (v z jP : ℤ) (hv : z ≤ v) (hjP : 0 ≤ jP) :
    (v - z).natAbs ≤ (v + jP - z).natAbs := by omega

/-- **THE GATE'S ONE REAL CLAUSE: the anchor clause at the region start of `z`'s own region.**
The pin at the region start `a` below `z` is the only pin whose countdown the in-region raise
moves — the countdown counts UP into the past inside a pending region, so raising `cntAt g z` by
`jP` raises the start's countdown by `jP` too. The clause still closes, from two facts the path
and the collision already supply and nothing else:

* `hroom : c + jP ≤ n` — the collision's own room (`kappa_collision_window_room`), which is
  where the window hypothesis is spent;
* `hlow : n ≤ c + 2 * d + 1` — the start's own pin equation
  (`cntAt_eq_nxtAt_of_idle_pend` reading `nxtAt g a = cntAt g (a + 1) = c + d` through
  `cntAt_add_of_pend_back`) composed with `nxtAt_lipschitz` over the `d + 1` steps from `a` to
  `z`. This is the ORIGINAL path's own arithmetic, not a hypothesis on the caller.

`d` is the distance from `a + 1` up to `z`, so the pin's distance to the anchor is `d + 1`. This
differs from `window_anchor_compat_of_room` by exactly that one step: there the bound is stated
at the clean displacement `d` under the tighter `n ≤ c + 2 * d`, and here at `d + 1` under the
`+ 1`-slacker bound the path actually gives, which is the form the construction consumes. -/
theorem window_anchor_compat_at_region_start (c n d jP : ℕ) (hroom : c + jP ≤ n)
    (hlow : n ≤ c + 2 * d + 1) :
    (((c + d + jP : ℕ) : ℤ) - (n : ℤ)).natAbs ≤ d + 1 := by
  omega

/-- **The start's own arithmetic, derived rather than assumed.** At the region start `a` of `z`'s
region, the register's value is the start's countdown, which is `z`'s countdown plus the distance;
and the register at `z` is within that distance plus one of it. Both facts are the ORIGINAL path's
— `cntAt_add_of_pend_back`, `cntAt_eq_nxtAt_of_idle_pend` and `nxtAt_lipschitz` — so neither is a
hypothesis the window regime's surgery carries to its caller. -/
theorem nxtAt_le_cntAt_region_start (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (a z : ℤ) (haz : a < z)
    (hai : pend (objAt g a) = false)
    (hregion : ∀ i : ℕ, i ≤ (z - (a + 1)).toNat → pend (objAt g (z - (i : ℤ))) = true) :
    cntAt g (a + 1) = cntAt g z + (z - (a + 1)).toNat ∧
      nxtAt g z ≤ cntAt g z + 2 * (z - (a + 1)).toNat + 1 := by
  set d := (z - (a + 1)).toNat with hd
  have hzd : z - (d : ℤ) = a + 1 := by omega
  -- the countdown counts up into the past inside the region
  have hback : cntAt g (z - (d : ℤ)) = cntAt g z + d :=
    cntAt_add_of_pend_back g hg z d (fun i hi => hregion i hi)
  rw [hzd] at hback
  -- the start's countdown IS the register's value at the idle position before it
  have hpa : pend (objAt g (a + 1)) = true := by
    have := hregion d le_rfl
    rwa [hzd] at this
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg a hai hpa
  -- and the register is `1`-Lipschitz over the `d + 1` steps from `a` up to `z`
  have hlip := nxtAt_lipschitz g hg a (d + 1)
  rw [show a + ((d + 1 : ℕ) : ℤ) = z by push_cast; omega] at hlip
  exact ⟨hback, by omega⟩

/-- **THE GATE, MEASURED.** The `z`-anchored lift's anchor clause `hn₀`, discharged for the
composite walk at the PRESCRIBED register value `nxtAt g z` and the displaced anchor `z + E`,
from the composite's pin classification alone.

The three disjuncts of `hclass` are the composite's three pin classes: a pin at or below the
region start `a`, whose position and countdown the surgery leaves alone; the region start `a`
itself, displaced by the idle insertion `E` and with its countdown raised by `jP`; and a pin at or
above `z`, displaced by `E + jP`, with its countdown unmoved. The clause closes at each class with
NO hypothesis beyond `hE : jP ≤ E` (the compensator is at least as long as the raise), the
collision's own room `hroom`, and facts of the original path:

* at or below `a`: the pin equation plus `nxtAt_lipschitz_two_sided`, with
  `window_pin_dist_grows_below` supplying that the insertion only widens the distance;
* at `a`: `window_anchor_compat_at_region_start`, whose two inputs
  `nxtAt_le_cntAt_region_start` derives from the path;
* at or above `z`: the pin equation plus `nxtAt_lipschitz_two_sided` again, with
  `window_pin_dist_grows_above` supplying that the raise only widens the distance.

This is the gate's PASS verdict as a compiled statement: the anchor clause is not an obstruction
in the window regime, and what the construction still owes is the classification itself — the
composite's walk and countdown read off the two landed splice constructors — not a further
hypothesis.

MEASURED, AND WORTH RECORDING BECAUSE IT WAS NOT PREDICTED: the compensator's LENGTH does not
enter this clause at all. The hypothesis `jP ≤ E` was written into this statement and the
elaborator reported it unreferenced, because the idle insertion displaces the region start and
the anchor by the SAME amount, leaving their distance `z - a` unchanged. Where the compensator is
actually spent is the pin PAIR clause — against pins strictly below the lengthened run, whose
distance to the region start the insertion does widen — and that is
`window_pin_pair_raise_of_slack` below, which carries `jP ≤ E` as a live hypothesis. -/
theorem window_anchor_clause_of_pin_classification
    (g g₂ : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a z : ℤ) (E jP : ℕ) (haz : a < z)
    (hai : pend (objAt g a) = false)
    (hregion : ∀ i : ℕ, i ≤ (z - (a + 1)).toNat → pend (objAt g (z - (i : ℤ))) = true)
    (hroom : cntAt g z + jP ≤ nxtAt g z)
    (hclass : ∀ v : ℤ, pend (objAt g₂ v) = false → pend (objAt g₂ (v + 1)) = true →
      (∃ w : ℤ, w ≤ a ∧ pend (objAt g w) = false ∧ pend (objAt g (w + 1)) = true ∧
          v = w ∧ cntAt g₂ (v + 1) = cntAt g (w + 1)) ∨
      (v = a + (E : ℤ) ∧ cntAt g₂ (v + 1) = cntAt g (a + 1) + jP) ∨
      (∃ w : ℤ, z ≤ w ∧ pend (objAt g w) = false ∧ pend (objAt g (w + 1)) = true ∧
          v = w + (E : ℤ) + (jP : ℤ) ∧ cntAt g₂ (v + 1) = cntAt g (w + 1))) :
    ∀ v : ℤ, pend (objAt g₂ v) = false → pend (objAt g₂ (v + 1)) = true →
      ((cntAt g₂ (v + 1) : ℤ) - nxtAt g z).natAbs ≤ (v - (z + (E : ℤ))).natAbs := by
  intro v hv0 hv1
  obtain ⟨hstart, hbound⟩ := nxtAt_le_cntAt_region_start g hg a z haz hai hregion
  rcases hclass v hv0 hv1 with ⟨w, hwa, hw0, hw1, hvw, hcv⟩ | ⟨hvw, hcv⟩ |
      ⟨w, hzw, hw0, hw1, hvw, hcv⟩
  · -- at or below the region start: the pin equation plus two-sided Lipschitzness
    rw [hcv, cntAt_eq_nxtAt_of_idle_pend g hg w hw0 hw1, hvw]
    refine le_trans (nxtAt_lipschitz_two_sided g hg w z) ?_
    exact window_pin_dist_grows_below w z (E : ℤ) (by omega) (Int.natCast_nonneg _)
  · -- the region start of `z`'s own region: the gate's one real clause
    subst hvw
    rw [hcv, hstart]
    have hgoal := window_anchor_compat_at_region_start (cntAt g z) (nxtAt g z)
      (z - (a + 1)).toNat jP hroom hbound
    have hdist : (a + (E : ℤ) - (z + (E : ℤ))).natAbs = (z - (a + 1)).toNat + 1 := by omega
    rw [hdist]
    exact hgoal
  · -- at or above `z`: the pin equation plus two-sided Lipschitzness again
    rw [hcv, cntAt_eq_nxtAt_of_idle_pend g hg w hw0 hw1, hvw,
      show (w + (E : ℤ) + (jP : ℤ) - (z + (E : ℤ))).natAbs = (w + (jP : ℤ) - z).natAbs from by
        omega]
    refine le_trans (nxtAt_lipschitz_two_sided g hg w z) ?_
    exact window_pin_dist_grows_above w z (jP : ℤ) hzw (Int.natCast_nonneg _)

/-- **NO PIN SITS INSIDE AN IDLE RUN.** If the `E + 1` positions at and below `a` are idle, every
region start strictly below `a` sits strictly below `a - E`. A region start is an idle position
with a PENDING successor, and every position of the run has an idle successor inside the run.

This is what turns the named idle-run condition into a quantitative distance bound: after the
run has been lengthened to `E`, the nearest pin below `z`'s region start is at distance more than
`E`, which is the slack the raise is paid out of. -/
theorem no_pin_in_idle_run (g : ℤ → LadderState Q pend) (a w : ℤ) (E : ℕ)
    (hrun : ∀ i : ℕ, i ≤ E → pend (objAt g (a - (i : ℤ))) = false)
    (hw1 : pend (objAt g (w + 1)) = true) (hwa : w < a) : w + (E : ℤ) < a := by
  by_contra hle
  have hi : (a - (w + 1)).toNat ≤ E := by omega
  have := hrun (a - (w + 1)).toNat hi
  rw [show a - (((a - (w + 1)).toNat : ℕ) : ℤ) = w + 1 by omega] at this
  exact Bool.false_ne_true (this.symm.trans hw1)

/-- **THE IDLE INSERTION'S SLACK PAYS FOR THE RAISE.** A pin pair whose compatibility bound `D`
was already slack by at least the insertion length `E` stays compatible when the higher pin's
countdown rises by `jP ≤ E`. Scale-invariant: `jP` is opaque, so nothing here reads the modulus.

This is where the compensator is spent, and it is the clause the pending-forever regime has no
need of — there is no pin below `z`'s region there at all. The slack hypothesis is not an
assumption on the caller: the idle insertion displaces `z`'s region start upward by `E` while
leaving every pin below the run where it was, so the original path's own pin bound
(`pinCompat_of_ladderPath`) becomes a bound slack by exactly `E` on the lengthened path. -/
theorem window_pin_pair_raise_of_slack (ch cl E jP D : ℕ) (hE : jP ≤ E)
    (hslack : ((ch : ℤ) - (cl : ℤ)).natAbs + E ≤ D) :
    (((ch + jP : ℕ) : ℤ) - (cl : ℤ)).natAbs ≤ D := by
  omega

/-! ### The regime's two structural inputs

The window regime is defined by an idle position in `z`'s past, and the surgery needs two things
read off that: WHERE the region start is, and that the idle run below it carries a duplicable
block. Neither is a hypothesis beyond the regime's own definition and the named condition. -/

/-- **THE REGION START'S PENDING RUN, IN THE FORM THE ARITHMETIC CONSUMES.** The landed
`exists_region_start_of_idle_past` (`LadderAgree.lean`) already locates the region start of a
pending position with an idle position in its past, and states maximality as a quantifier over
positions; `nxtAt_le_cntAt_region_start` reads the same run as a quantifier over backward
DISTANCES, because `cntAt_add_of_pend_back` is indexed that way. This is the translation between
the two, and it is all this module needs: the region start itself is NOT re-derived here. -/
theorem region_run_of_region_start (g : ℤ → LadderState Q pend) (a z : ℤ) (haz : a < z)
    (hmax : ∀ t : ℤ, a < t → t ≤ z → pend (objAt g t) = true) :
    ∀ i : ℕ, i ≤ (z - (a + 1)).toNat → pend (objAt g (z - (i : ℤ))) = true :=
  fun i hi => hmax _ (by omega) (by omega)

/-- **THE NAMED CONDITION DELIVERS A DUPLICABLE IDLE BLOCK.** Under `HasIdleRunBelow`, the
idle-restricted pigeonhole `exists_idleTypeBlock_of_budget_le_run` returns a nonempty block
`[α, α + k)` lying at or below the region start `a`, idle throughout, whose two ends carry the
same object state AND the same realized closure type — which is exactly the premise the
unconditional idle-block duplication `exists_idleSpliced_ladderPath` (and its register-anchored
iterate) consumes.

This is the only place the named condition is spent, and it is spent on EXISTENCE of a block, not
on any pin or regime fact. -/
theorem exists_idleBlock_of_hasIdleRunBelow {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hg : IsLadderPath step pend g) (a : ℤ) (hrun : HasIdleRunBelow pend φ g a) :
    ∃ (α : ℤ) (k : ℕ), 0 < k ∧ α + (k : ℤ) ≤ a ∧
      (∀ v : ℤ, α ≤ v → v ≤ a → pend (objAt g v) = false) ∧
      (∀ i : ℕ, i < k → pend (objAt g (α + (i : ℤ))) = false) ∧
      objAt g α = objAt g (α + (k : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ α
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (α + (k : ℤ)) := by
  obtain ⟨α, k, hk, -, hlb, hub, hidle, hrep, hty⟩ :=
    exists_idleTypeBlock_of_budget_le_run step pend fwd bwd lab φ σ hg
      (a - ((idleBudget pend φ : ℕ) : ℤ)) (idleBudget pend φ)
      (fun i hi => by
        have h := hrun (idleBudget pend φ - i) (by omega)
        rwa [show a - (((idleBudget pend φ - i : ℕ)) : ℤ)
          = a - ((idleBudget pend φ : ℕ) : ℤ) + (i : ℤ) by
            rw [Nat.cast_sub hi]; ring] at h)
      le_rfl
  refine ⟨α, k, hk, by omega, fun v hv0 hv1 => ?_, hidle, hrep, hty⟩
  -- the whole stretch from the block's start up to `a` is inside the named condition's run
  have h := hrun (a - v).toNat (by omega)
  rwa [show a - (((a - v).toNat : ℕ) : ℤ) = v by omega] at h

/-! ### The composite's pin classification

What the gate left as a hypothesis — `window_anchor_clause_of_pin_classification`'s `hclass` — is
proved here for the composite walk, and with it the pin PAIR clause. The composite is read in two
stages, exactly as the plan schedules it: `g₁` is the IDLE-LENGTHENED path, which the landed
unconditional iterate `exists_iterIdleSpliced_ladderPath` supplies with no pin side condition and
no regime hypothesis; and the pending raise is then a SINGLE splice of a type-respecting block of
`z`'s region of `g₁`, through the generic `exists_spliced_ladderPath`.

The two stages are not interchangeable. A pure splice with no idle compensation is REFUTED in this
regime — `LadderAgree.lean`'s `exists_ladderPath_at_region_of_idle_past` records that
`pinCompat_of_ladderPath` makes the splice's pin demand necessary and that on a PIN-TIGHT original
it reads `s - v + l ≤ s - v`. The composite escapes that refutation not by evading the demand but
by paying it: stage one makes `g₁` pin-SLACK by exactly `E` at the one pair that matters, and the
raise `l ≤ E` is drawn from that slack. `window_pin_pair_raise_of_slack` is that payment and
`no_pin_in_idle_run` is why the slack is there.

A landed sibling route exists for the state-level raise and is deliberately NOT taken here:
`exists_ladderPath_at_region_of_idle_past` compensates by INSERTING idle positions at the region
start (`insObj`/`insCnt`, with `insPins_of_region_start` discharging its pin clause) rather than by
duplicating an existing idle block. That route carries `hself`, a path-local self-loop at the
idle object states, which this one does not need, and it eliminates the anchor obligation through
`exists_ladderPath_of_walk_of_pins` instead of holding the register at a prescribed value — so it
cannot serve a cell inclusion, which reads `nxtAt` at the comparison position. The two are
alternatives at the same mathematical idea (move the lower pins and the raised pin apart by
exactly the raise), with different premises and different exposure. -/

/-- **THE COMPOSITE'S PIN TRICHOTOMY.** Every region start of the pending splice of the
idle-lengthened path `g₁` falls in exactly one of three classes, each named against the ORIGINAL
path `g`: a pin strictly below the region start `a`, carried with its position and its countdown
unchanged; the region start displaced to `a + E`, carrying its countdown raised by exactly the
block length `l`; and a pin at or above `z`, displaced by `E + l` with its countdown unmoved.

The three conclusions are exactly the three disjuncts of
`window_anchor_clause_of_pin_classification`'s `hclass` at `jP := l`, so this discharges the gate's
remaining obligation. The hypotheses are the two stages' own outputs — `g₁`'s agreement below `a`,
the lengthened idle run `[a, a + E]`, the displacement at and above `a + E`, and the block's
containment in `z`'s region — and the regime's own data; none of them is a new side condition. -/
theorem window_composite_pin_trichotomy
    (g g₁ : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a z u : ℤ) (E l : ℕ)
    (haz : a < z) (hl : 0 < l) (hzu : z + (E : ℤ) ≤ u)
    (hai : pend (objAt g a) = false)
    (hidle₁ : ∀ i : ℕ, i ≤ E → pend (objAt g₁ (a + (E : ℤ) - (i : ℤ))) = false)
    (hpend₁ : ∀ v : ℤ, a + (E : ℤ) < v → v ≤ u + (l : ℤ) → pend (objAt g₁ v) = true)
    (hbelow : ∀ v : ℤ, v < a → objAt g₁ v = objAt g v ∧ cntAt g₁ v = cntAt g v)
    (habove : ∀ v : ℤ, a + (E : ℤ) ≤ v →
      objAt g₁ v = objAt g (v - (E : ℤ)) ∧ cntAt g₁ v = cntAt g (v - (E : ℤ)))
    (hureg : u ≤ a + (E : ℤ) + 1 + (cntAt g₁ (a + (E : ℤ) + 1) : ℤ)) :
    ∀ s : ℤ, pend (spliceObj g₁ u l s) = false → pend (spliceObj g₁ u l (s + 1)) = true →
      (∃ w : ℤ, w ≤ a ∧ pend (objAt g w) = false ∧ pend (objAt g (w + 1)) = true ∧
          s = w ∧ spliceCnt g₁ u l (s + 1) = cntAt g (w + 1)) ∨
      (s = a + (E : ℤ) ∧ spliceCnt g₁ u l (s + 1) = cntAt g (a + 1) + l) ∨
      (∃ w : ℤ, z ≤ w ∧ pend (objAt g w) = false ∧ pend (objAt g (w + 1)) = true ∧
          s = w + (E : ℤ) + (l : ℤ) ∧ spliceCnt g₁ u l (s + 1) = cntAt g (w + 1)) := by
  intro s hs0 hs1
  have hE0 : (0 : ℤ) ≤ (E : ℤ) := Int.natCast_nonneg _
  have hau : a + (E : ℤ) < u := by omega
  rcases lt_or_ge (s + 1) (u + (l : ℤ)) with hlt | hge
  · -- the pin sits below the block's top, so it is a pin of `g₁` itself
    rw [spliceObj_of_lt (g := g₁) (a := u) (l := l) s (by omega)] at hs0
    rw [spliceObj_of_lt (g := g₁) (a := u) (l := l) (s + 1) hlt] at hs1
    rcases lt_or_ge (s + 1) a with hsa | hsa
    · -- CLASS 1: strictly below the region start, where `g₁` is the original
      have h0 : pend (objAt g s) = false := by rw [← (hbelow s (by omega)).1]; exact hs0
      have h1 : pend (objAt g (s + 1)) = true := by rw [← (hbelow (s + 1) hsa).1]; exact hs1
      -- the region opening at `s + 1` ends strictly below the idle `a`
      have hend : s + 1 + (cntAt g (s + 1) : ℤ) < a := by
        by_contra hc
        have hp := (cntAt_sub_of_pend g hg (s + 1) h1 (a - (s + 1)).toNat (by omega)).1
        rw [show s + 1 + (((a - (s + 1)).toNat : ℕ) : ℤ) = a by omega] at hp
        exact Bool.false_ne_true (hai.symm.trans hp)
      refine Or.inl ⟨s, by omega, h0, h1, rfl, ?_⟩
      rw [spliceCnt_of_lt (g := g₁) (a := u) (l := l) (s + 1) hlt,
        if_neg (by rw [(hbelow (s + 1) hsa).2]; omega)]
      exact (hbelow (s + 1) hsa).2
    · -- at or above the region start: the idle run forces `s = a + E`
      have hsE : s = a + (E : ℤ) := by
        by_contra hne
        rcases lt_or_ge s (a + (E : ℤ)) with h | h
        · -- `s + 1` lies inside the idle run `[a, a + E]`
          have hr := hidle₁ (a + (E : ℤ) - (s + 1)).toNat (by omega)
          rw [show a + (E : ℤ) - (((a + (E : ℤ) - (s + 1)).toNat : ℕ) : ℤ) = s + 1 by omega] at hr
          exact Bool.false_ne_true (hr.symm.trans hs1)
        · -- `s` itself lies strictly inside the pending stretch
          exact Bool.false_ne_true (hs0.symm.trans (hpend₁ s (by omega) (by omega)))
      refine Or.inr (Or.inl ⟨hsE, ?_⟩)
      rw [hsE, spliceCnt_of_lt (g := g₁) (a := u) (l := l) (a + (E : ℤ) + 1) (by omega),
        if_pos hureg, (habove (a + (E : ℤ) + 1) (by omega)).2,
        show a + (E : ℤ) + 1 - (E : ℤ) = a + 1 by ring]
  · -- CLASS 3: at or above the block's top, where the walk is the original displaced by `E + l`
    have hsu : u + (l : ℤ) ≤ s := by
      by_contra hc
      rw [spliceObj_of_lt (g := g₁) (a := u) (l := l) s (by omega)] at hs0
      exact Bool.false_ne_true (hs0.symm.trans (hpend₁ s (by omega) (by omega)))
    rw [spliceObj_of_ge (g := g₁) (a := u) (l := l) s hsu] at hs0
    rw [spliceObj_of_ge (g := g₁) (a := u) (l := l) (s + 1) (by omega)] at hs1
    have h0 : pend (objAt g (s - (l : ℤ) - (E : ℤ))) = false := by
      rw [← (habove (s - (l : ℤ)) (by omega)).1]; exact hs0
    have h1 : pend (objAt g (s - (l : ℤ) - (E : ℤ) + 1)) = true := by
      rw [show s - (l : ℤ) - (E : ℤ) + 1 = s + 1 - (l : ℤ) - (E : ℤ) by ring,
        ← (habove (s + 1 - (l : ℤ)) (by omega)).1]
      exact hs1
    refine Or.inr (Or.inr ⟨s - (l : ℤ) - (E : ℤ), by omega, h0, h1, by ring, ?_⟩)
    rw [spliceCnt_of_ge (g := g₁) (a := u) (l := l) (s + 1) (by omega),
      (habove (s + 1 - (l : ℤ)) (by omega)).2,
      show s + 1 - (l : ℤ) - (E : ℤ) = s - (l : ℤ) - (E : ℤ) + 1 by ring]

/-- **THE COMPOSITE'S PIN PAIR CLAUSE, DISCHARGED.** `exists_spliced_ladderPath`'s side condition
on the pending raise of the idle-lengthened path, proved from the trichotomy and the original
path's own pin compatibility. Nine pin-class pairs; eight of them close on
`pinCompat_of_ladderPath` and a rigid displacement, and the ninth — the raised region start
against a pin strictly below the lengthened run — is the one that spends the compensator, through
`l ≤ E`.

This is the clause that a pure splice with no compensation FAILS in this regime, and the hypothesis
`hlE : l ≤ E` is exactly the payment. Nothing beyond it is carried: `hap` is the pending successor
of the region start, a datum of the regime, and every other hypothesis is one of the two stages'
own outputs. -/
theorem window_composite_pins
    (g g₁ : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a z u : ℤ) (E l : ℕ)
    (haz : a < z) (hl : 0 < l) (hlE : l ≤ E) (hzu : z + (E : ℤ) ≤ u)
    (hai : pend (objAt g a) = false) (hap : pend (objAt g (a + 1)) = true)
    (hidle₁ : ∀ i : ℕ, i ≤ E → pend (objAt g₁ (a + (E : ℤ) - (i : ℤ))) = false)
    (hpend₁ : ∀ v : ℤ, a + (E : ℤ) < v → v ≤ u + (l : ℤ) → pend (objAt g₁ v) = true)
    (hbelow : ∀ v : ℤ, v < a → objAt g₁ v = objAt g v ∧ cntAt g₁ v = cntAt g v)
    (habove : ∀ v : ℤ, a + (E : ℤ) ≤ v →
      objAt g₁ v = objAt g (v - (E : ℤ)) ∧ cntAt g₁ v = cntAt g (v - (E : ℤ)))
    (hureg : u ≤ a + (E : ℤ) + 1 + (cntAt g₁ (a + (E : ℤ) + 1) : ℤ)) :
    ∀ s v : ℤ, pend (spliceObj g₁ u l s) = false → pend (spliceObj g₁ u l (s + 1)) = true →
      pend (spliceObj g₁ u l v) = false → pend (spliceObj g₁ u l (v + 1)) = true →
      ((spliceCnt g₁ u l (s + 1) : ℤ) - spliceCnt g₁ u l (v + 1)).natAbs ≤ (s - v).natAbs := by
  intro s v hs0 hs1 hv0 hv1
  have htri := window_composite_pin_trichotomy g g₁ hg a z u E l haz hl hzu hai hidle₁ hpend₁
    hbelow habove hureg
  rcases htri s hs0 hs1 with ⟨w, hwa, hw0, hw1, hsw, hsc⟩ | ⟨hsw, hsc⟩ |
      ⟨w, hzw, hw0, hw1, hsw, hsc⟩ <;>
    rcases htri v hv0 hv1 with ⟨y, hya, hy0, hy1, hvy, hvc⟩ | ⟨hvy, hvc⟩ |
      ⟨y, hzy, hy0, hy1, hvy, hvc⟩ <;>
    rw [hsc, hvc, hsw, hvy]
  · have := pinCompat_of_ladderPath g hg w y hw0 hw1 hy0 hy1
    omega
  · have := pinCompat_of_ladderPath g hg w a hw0 hw1 hai hap
    omega
  · have := pinCompat_of_ladderPath g hg w y hw0 hw1 hy0 hy1
    omega
  · have := pinCompat_of_ladderPath g hg a y hai hap hy0 hy1
    omega
  · omega
  · have := pinCompat_of_ladderPath g hg a y hai hap hy0 hy1
    omega
  · have := pinCompat_of_ladderPath g hg w y hw0 hw1 hy0 hy1
    omega
  · have := pinCompat_of_ladderPath g hg w a hw0 hw1 hai hap
    omega
  · have := pinCompat_of_ladderPath g hg w y hw0 hw1 hy0 hy1
    omega

/-- **THE WINDOW REGIME'S COMPOSITE RAISE: THE ADMISSIBILITY HALF, WITH THE REGISTER HELD.** The
composite walk lifts to a ladder path whose object walk is the pending splice of the
idle-lengthened path, whose countdown is the spliced countdown — raised by exactly `l` at the
displaced comparison position `z + E` — and whose next-deadline register at `z + E` is the
ORIGINAL path's register at `z`.

The register clause is the point: `exists_ladderPath_of_walk_of_pins` would supply a ladder path
from the pin pair clause alone, but the register it chooses is whatever the drift extension
returns, and a cell inclusion reads `nxtAt` at the comparison position. So the walk is lifted
TWICE — once anchor-free, to make the pin trichotomy available on a genuine ladder path, and once
through the `z`-anchored lift `exists_ladderPath_of_walk_nxt_at` at the PRESCRIBED value. The
second lift's anchor clause is the gate's own measurement
(`window_anchor_clause_of_pin_classification`) fed by the trichotomy.

Scope, stated because it bounds what this buys. The raise here is ONE block length `l`, not a
multiple of `P + 1`: the bridge putting `l` among the divisors of `P + 1` is `(K1)`'s, and the
iteration to an exact multiple is a separate step this theorem does not take. Nothing here is a
cell inclusion, nothing carries the realized TYPE (the model-level half, which
`tpOf_eq_spliceIdx_of_tpOf_eq` supplies for the pending stage and
`exists_iterIdleSpliced_ladderPath` for the idle stage), and the reserved
`cellLE_zero_const_of_kappa_eq` is untouched. The compensator is the idle run BELOW, so neither
`HasForwardSlack` nor `ForwardSlackWitnessed` appears, and the refuted deletion-above route is not
re-entered. -/
theorem exists_window_composite_ladderPath
    (g g₁ : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hg₁ : IsLadderPath step pend g₁) (a z u : ℤ) (E l : ℕ)
    (haz : a < z) (hl : 0 < l) (hlE : l ≤ E) (hzu : z + (E : ℤ) ≤ u)
    (hai : pend (objAt g a) = false)
    (hregion : ∀ t : ℤ, a < t → t ≤ z → pend (objAt g t) = true)
    (hidle₁ : ∀ i : ℕ, i ≤ E → pend (objAt g₁ (a + (E : ℤ) - (i : ℤ))) = false)
    (hpend₁ : ∀ v : ℤ, a + (E : ℤ) < v → v ≤ u + (l : ℤ) → pend (objAt g₁ v) = true)
    (hbelow : ∀ v : ℤ, v < a → objAt g₁ v = objAt g v ∧ cntAt g₁ v = cntAt g v)
    (habove : ∀ v : ℤ, a + (E : ℤ) ≤ v →
      objAt g₁ v = objAt g (v - (E : ℤ)) ∧ cntAt g₁ v = cntAt g (v - (E : ℤ)))
    (hureg : u ≤ a + (E : ℤ) + 1 + (cntAt g₁ (a + (E : ℤ) + 1) : ℤ))
    (hpu : pend (objAt g₁ u) = true) (hcl : l ≤ cntAt g₁ u)
    (hrep : objAt g₁ u = objAt g₁ (u + (l : ℤ)))
    (hroom : cntAt g z + l ≤ nxtAt g z) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = spliceObj g₁ u l v) ∧
      (∀ v : ℤ, cntAt g' v = spliceCnt g₁ u l v) ∧
      nxtAt g' (z + (E : ℤ)) = nxtAt g z := by
  have hap : pend (objAt g (a + 1)) = true := hregion (a + 1) (by omega) (by omega)
  have hpins := window_composite_pins g g₁ hg a z u E l haz hl hlE hzu hai hap hidle₁ hpend₁
    hbelow habove hureg
  have htri := window_composite_pin_trichotomy g g₁ hg a z u E l haz hl hzu hai hidle₁ hpend₁
    hbelow habove hureg
  -- the anchor-free lift, to put the trichotomy on a genuine ladder path
  obtain ⟨g₂, hg₂, hobj₂, hcnt₂⟩ :=
    exists_ladderPath_of_walk_of_pins (spliceObj g₁ u l) (spliceCnt g₁ u l)
      (spliceObj_step hg₁ hrep) (spliceCnt_idle hg₁ hpu hcl)
      (spliceCnt_pend_pend hg₁ hl hpu hcl) (spliceCnt_pend_idle hg₁ hpu hcl) hpins
  -- the gate's measurement, read on that path
  have hanch := window_anchor_clause_of_pin_classification g g₂ hg a z E l haz hai
    (region_run_of_region_start g a z haz hregion) hroom
    (fun v hv0 hv1 => by
      rw [hobj₂ v] at hv0
      rw [hobj₂ (v + 1)] at hv1
      rw [hcnt₂ (v + 1)]
      exact htri v hv0 hv1)
  -- the prescribed-register lift
  refine exists_ladderPath_of_walk_nxt_at (spliceObj g₁ u l) (spliceCnt g₁ u l) (z + (E : ℤ))
    (nxtAt g z) (spliceObj_step hg₁ hrep) (spliceCnt_idle hg₁ hpu hcl)
    (spliceCnt_pend_pend hg₁ hl hpu hcl) (spliceCnt_pend_idle hg₁ hpu hcl) hpins
    (fun v hv0 hv1 => ?_)
  have := hanch v (by rw [hobj₂ v]; exact hv0) (by rw [hobj₂ (v + 1)]; exact hv1)
  rwa [hcnt₂ (v + 1)] at this

/-! ### The iterable reformulation: every clause about the spliced path alone

`window_composite_pin_trichotomy` and `window_composite_pins` state the composite's pin data
RELATIVE TO the original path `g`, through the hypotheses `hbelow`/`habove` ("`g₁` is `g`
displaced by `E`"). That is what the base case supplies and it is NOT preserved by a second
splice: after one splice the walk is `g` displaced by `E` AND raised by `l`, which is no longer a
pure displacement. Iterating therefore needs the same measurement restated so that every
hypothesis and every conclusion mentions only the path being spliced.

The restatement is strictly SHORTER than the relative one, and the reason is worth recording: the
pending stretch `(a, u + l]` forces a region start at or above `a` to BE `a`, so the class-1
clause needs no agreement hypothesis and the idle-run condition drops out of the trichotomy
entirely. What the iteration needs instead is a BUDGET. Each step spends exactly `l` of the slack
the idle lengthening created, at the one pin pair where the raise is not free, and the two
invariants below are stated so that the step reproduces them:

* the pin-pair budget `|cntAt g (a + 1) - cntAt g (w + 1)| + R ≤ |a - w| + e · l` at every region
  start `w` below `a`, which is where `window_pin_pair_raise_of_slack`'s slack is banked;
* the anchor budget `cntAt g (a + 1) + R ≤ n₀ + |z - a| + e · l`, which is where the collision's
  ROOM is banked, spent once in the base case rather than once per step.

Both are stated with `e · l` added on the RIGHT rather than subtracted from `R`, so no truncated
subtraction appears and each step's reproduction is one `omega` away. -/

/-- **THE ITERABLE PIN TRICHOTOMY.** Every region start of the pending splice of a ladder path at
a block `[u, u + l)` lying in the region opened at `a + 1` is one of three things: a region start
of that same path strictly below `a`, with its position AND its countdown untouched; the position
`a` itself, with its countdown raised by exactly `l`; or a region start at or above `u`, displaced
by `l` with its countdown unmoved.

Every hypothesis and every conclusion names only the path being spliced, so this statement applies
to the result of its own conclusion — which is exactly what the relative
`window_composite_pin_trichotomy` cannot do. -/
theorem window_iter_pin_trichotomy
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a u : ℤ) (l : ℕ) (hl : 0 < l) (hau : a < u)
    (hai : pend (objAt g a) = false)
    (hpend : ∀ v : ℤ, a < v → v ≤ u + (l : ℤ) → pend (objAt g v) = true)
    (hureg : u ≤ a + 1 + (cntAt g (a + 1) : ℤ)) :
    ∀ s : ℤ, pend (spliceObj g u l s) = false → pend (spliceObj g u l (s + 1)) = true →
      (s < a ∧ pend (objAt g s) = false ∧ pend (objAt g (s + 1)) = true ∧
          spliceCnt g u l (s + 1) = cntAt g (s + 1)) ∨
      (s = a ∧ spliceCnt g u l (s + 1) = cntAt g (a + 1) + l) ∨
      (∃ w : ℤ, u ≤ w ∧ pend (objAt g w) = false ∧ pend (objAt g (w + 1)) = true ∧
          s = w + (l : ℤ) ∧ spliceCnt g u l (s + 1) = cntAt g (w + 1)) := by
  intro s hs0 hs1
  rcases lt_or_ge (s + 1) (u + (l : ℤ)) with hlt | hge
  · rw [spliceObj_of_lt (g := g) (a := u) (l := l) s (by omega)] at hs0
    rw [spliceObj_of_lt (g := g) (a := u) (l := l) (s + 1) hlt] at hs1
    rcases lt_or_ge s a with hsa | hsa
    · -- CLASS 1: strictly below `a`, where the region opened at `s + 1` ends below `a`
      have hend := regionStart_spacing g hg s a hs1 hai hsa
      refine Or.inl ⟨hsa, hs0, hs1, ?_⟩
      rw [spliceCnt_of_lt (g := g) (a := u) (l := l) (s + 1) hlt, if_neg (by omega)]
    · -- CLASS 2: the pending stretch forces the pin to be `a`
      have hsa' : s = a := by
        by_contra hne
        exact Bool.false_ne_true (hs0.symm.trans (hpend s (by omega) (by omega)))
      refine Or.inr (Or.inl ⟨hsa', ?_⟩)
      rw [hsa', spliceCnt_of_lt (g := g) (a := u) (l := l) (a + 1) (by omega), if_pos hureg]
  · -- CLASS 3: at or above the block's top, where the walk is the original `l` earlier
    have hsu : u + (l : ℤ) ≤ s := by
      by_contra hc
      rw [spliceObj_of_lt (g := g) (a := u) (l := l) s (by omega)] at hs0
      exact Bool.false_ne_true (hs0.symm.trans (hpend s (by omega) (by omega)))
    rw [spliceObj_of_ge (g := g) (a := u) (l := l) s hsu] at hs0
    rw [spliceObj_of_ge (g := g) (a := u) (l := l) (s + 1) (by omega)] at hs1
    refine Or.inr (Or.inr ⟨s - (l : ℤ), by omega, hs0, ?_, by ring, ?_⟩)
    · rw [show s - (l : ℤ) + 1 = s + 1 - (l : ℤ) by ring]; exact hs1
    · rw [spliceCnt_of_ge (g := g) (a := u) (l := l) (s + 1) (by omega),
        show s + 1 - (l : ℤ) = s - (l : ℤ) + 1 by ring]

/-- **THE ITERABLE PIN PAIR CLAUSE.** `exists_ladderPath_of_walk_of_pins`'s side condition for one
step of the iteration, from the iterable trichotomy and the path's own pin compatibility. Nine
pin-class pairs; eight close on `pinCompat_of_ladderPath` and a rigid displacement, and the ninth
— the raised `a` against a region start strictly below it — is the one that spends `l` of the
banked slack `hslack`.

The budget is consumed at exactly the rate the invariant is written to absorb: the hypothesis is
`|Δ| + R ≤ |a - w| + e · l` and what the step needs is `(e + 1) · l ≤ R`, so the invariant
reproduces itself at `e + 1` with nothing re-derived. -/
theorem window_iter_pins
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a u : ℤ) (l R e : ℕ) (hl : 0 < l) (hau : a < u)
    (hai : pend (objAt g a) = false)
    (hpend : ∀ v : ℤ, a < v → v ≤ u + (l : ℤ) → pend (objAt g v) = true)
    (hureg : u ≤ a + 1 + (cntAt g (a + 1) : ℤ))
    (hslack : ∀ w : ℤ, w < a → pend (objAt g w) = false → pend (objAt g (w + 1)) = true →
      ((cntAt g (a + 1) : ℤ) - cntAt g (w + 1)).natAbs + R ≤ (a - w).natAbs + e * l)
    (hmR : (e + 1) * l ≤ R) :
    ∀ s v : ℤ, pend (spliceObj g u l s) = false → pend (spliceObj g u l (s + 1)) = true →
      pend (spliceObj g u l v) = false → pend (spliceObj g u l (v + 1)) = true →
      ((spliceCnt g u l (s + 1) : ℤ) - spliceCnt g u l (v + 1)).natAbs ≤ (s - v).natAbs := by
  intro s v hs0 hs1 hv0 hv1
  have htri := window_iter_pin_trichotomy g hg a u l hl hau hai hpend hureg
  have he : e * l + l = (e + 1) * l := by ring
  rcases htri s hs0 hs1 with ⟨hsa, hs0', hs1', hsc⟩ | ⟨hsw, hsc⟩ |
      ⟨w, huw, hw0, hw1, hsw, hsc⟩ <;>
    rcases htri v hv0 hv1 with ⟨hva, hv0', hv1', hvc⟩ | ⟨hvw, hvc⟩ |
      ⟨y, huy, hy0, hy1, hvy, hvc⟩ <;>
    rw [hsc, hvc]
  · have := pinCompat_of_ladderPath g hg s v hs0' hs1' hv0' hv1'
    omega
  · have := hslack s hsa hs0' hs1'
    subst hvw
    omega
  · have := pinCompat_of_ladderPath g hg s y hs0' hs1' hy0 hy1
    omega
  · have := hslack v hva hv0' hv1'
    subst hsw
    omega
  · subst hsw; subst hvw; omega
  · have := pinCompat_of_ladderPath g hg a y hai (hpend (a + 1) (by omega) (by omega)) hy0 hy1
    subst hsw
    omega
  · have := pinCompat_of_ladderPath g hg w v hw0 hw1 hv0' hv1'
    omega
  · have := pinCompat_of_ladderPath g hg w a hw0 hw1 hai (hpend (a + 1) (by omega) (by omega))
    subst hvw
    omega
  · have := pinCompat_of_ladderPath g hg w y hw0 hw1 hy0 hy1
    omega

/-- `natAbs` of a difference is symmetric. Stated here because the two budget invariants are
written with the distance in opposite orders — the anchor clause reads `|v - z|` at a pin and the
anchor budget reads `|z - a|` at the region start — and nothing in the ambient library names this
in the `Int` namespace. -/
theorem window_natAbs_sub_comm (x y : ℤ) : (x - y).natAbs = (y - x).natAbs := by omega

/-- **THE ANCHOR CLAUSE AT THE RAISED REGION START, AS PURE ARITHMETIC.** One step of the
iteration raises the region start's countdown by `l`; the anchor clause survives because the
anchor budget `hbudg` has `El + l` of `R` still unspent. The lower half is free — subtracting
from a countdown already within `D` of `n₀` only helps — and the upper half is exactly where the
budget is drawn down. Scale-invariant: `El` and `l` are opaque. -/
theorem window_iter_anchor_raise (c n₀ R D El l : ℕ)
    (hanch : ((c : ℤ) - (n₀ : ℤ)).natAbs ≤ D) (hbudg : c + R ≤ n₀ + D + El)
    (hle : El + l ≤ R) :
    (((c + l : ℕ) : ℤ) - (n₀ : ℤ)).natAbs ≤ D := by omega

/-- **THE ANCHOR CLAUSE AT A PIN DISPLACED UPWARD, AS PURE ARITHMETIC.** A pin at or above the
block is pushed further from an anchor at or below it, so its clause is strictly looser. -/
theorem window_iter_anchor_shift (c n₀ l : ℕ) (y z : ℤ) (hz : z ≤ y)
    (h : ((c : ℤ) - (n₀ : ℤ)).natAbs ≤ (y - z).natAbs) :
    ((c : ℤ) - (n₀ : ℤ)).natAbs ≤ (y + (l : ℤ) - z).natAbs := by omega

/-- **THE PIN-PAIR BUDGET'S REPRODUCTION, AS PURE ARITHMETIC.** Raising the higher countdown by
`l` costs at most `l` of the banked slack, and the invariant is written with the spend on the
right so the reproduction is an identity rather than a truncated subtraction. -/
theorem window_iter_slack_raise (ch cl R D El l E1 : ℕ)
    (h : ((ch : ℤ) - (cl : ℤ)).natAbs + R ≤ D + El) (he : El + l = E1) :
    (((ch + l : ℕ) : ℤ) - (cl : ℤ)).natAbs + R ≤ D + E1 := by omega

/-- **THE ANCHOR BUDGET'S REPRODUCTION, AS PURE ARITHMETIC.** The countdown rises by `l` exactly
as the unspent budget falls by `l`, so this invariant reproduces itself with no slack lost. -/
theorem window_iter_budget_raise (c R n₀ D El l E1 : ℕ)
    (h : c + R ≤ n₀ + D + El) (he : El + l = E1) :
    c + l + R ≤ n₀ + D + E1 := by omega

/-- **NO PIN BELOW THE REGION START IS A DISPLACED PIN FROM ABOVE THE BLOCK.** The class-3
positions all sit at or above `u`, strictly above the region start, so the trichotomy's third
disjunct is vacuous for a position strictly below `a`. -/
theorem window_iter_no_low_shift (w y a u : ℤ) (l : ℕ) (hau : a < u) (huy : u ≤ y)
    (hwy : w = y + (l : ℤ)) (hw : w < a) : False := by omega

/-- **THE WINDOW REGIME'S ITERATE: `m` COPIES OF ONE BLOCK, WITH THE REGISTER PRESCRIBED.** The
window-regime analogue of `exists_iterSpliced_ladderPath_idx_of_pend_past`. The landed one carries
the pending-forever hypothesis in two places — its per-step
`exists_spliced_ladderPath_of_pend_past`, and the `hpend_all` step of its own anchor proof — and
this regime denies it. What replaces the regime hypothesis is the pair of BUDGET invariants
`hslack` and `hbudg`: each step spends exactly `l` of each, and `hmR : m · l ≤ R` is what the
caller must buy up front.

The walk is the original read through `iterSpliceIdx u l m` at every position, the countdown is
raised by exactly `m · l` at every position of a region that reaches `u` — `z` among them — the
register at `z` is the PRESCRIBED `n₀`, and the realized stab-free type at every position is the
original's at the retracted position.

Scope. Nothing here is a multiple of `P + 1`: `l` is whatever block the caller supplies, and the
bridge putting it among the divisors of `P + 1` is `(K1)`'s, applied by the caller. Nothing here
mentions the idle run: the slack the idle lengthening created enters only as the numeric budget
`R`, so `HasForwardSlack` and `ForwardSlackWitnessed` are absent and the refuted deletion-above
route is not re-entered. -/
theorem exists_window_iterSpliced_ladderPath {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (z a u : ℤ) (l R n₀ : ℕ)
    (hl : 0 < l) (haz : a < z) (hzu : z ≤ u)
    (hai : pend (objAt g a) = false)
    (hpend : ∀ v : ℤ, a < v → v ≤ u + (l : ℤ) → pend (objAt g v) = true)
    (hureg : u ≤ a + 1 + (cntAt g (a + 1) : ℤ))
    (hcl : l ≤ cntAt g u)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (hanch : ∀ v : ℤ, pend (objAt g v) = false → pend (objAt g (v + 1)) = true →
      ((cntAt g (v + 1) : ℤ) - n₀).natAbs ≤ (v - z).natAbs)
    (hslack : ∀ w : ℤ, w < a → pend (objAt g w) = false → pend (objAt g (w + 1)) = true →
      ((cntAt g (a + 1) : ℤ) - cntAt g (w + 1)).natAbs + R ≤ (a - w).natAbs)
    (hbudg : cntAt g (a + 1) + R ≤ n₀ + (z - a).natAbs)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ)))
    (m : ℕ) (hmR : m * l ≤ R) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l m v)) ∧
      (∀ v : ℤ, v ≤ u → u ≤ v + (cntAt g v : ℤ) → cntAt g' v = cntAt g v + m * l) ∧
      nxtAt g' z = n₀ ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l m w) := by
  classical
  haveI : Fintype Q := Fintype.ofFinite Q
  -- the induction carries the two budget invariants, the anchor clause, and the block's top
  suffices H : ∀ e : ℕ, e * l ≤ R → ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l e v)) ∧
      (∀ v : ℤ, v ≤ u → u ≤ v + (cntAt g v : ℤ) → cntAt g' v = cntAt g v + e * l) ∧
      objAt g' (u + (l : ℤ)) = objAt g u ∧
      (∀ v : ℤ, pend (objAt g' v) = false → pend (objAt g' (v + 1)) = true →
        ((cntAt g' (v + 1) : ℤ) - n₀).natAbs ≤ (v - z).natAbs) ∧
      (∀ w : ℤ, w < a → pend (objAt g' w) = false → pend (objAt g' (w + 1)) = true →
        ((cntAt g' (a + 1) : ℤ) - cntAt g' (w + 1)).natAbs + R ≤ (a - w).natAbs + e * l) ∧
      cntAt g' (a + 1) + R ≤ n₀ + (z - a).natAbs + e * l ∧
      (∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l e w)) by
    obtain ⟨g₁, hg₁, hobj₁, hcnt₁, -, hanch₁, -, -, hty₁⟩ := H m hmR
    obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
    -- the re-lift: the same walk and countdown, the register at the prescribed `n₀`
    obtain ⟨g₀, hg₀, hobj₀, hcnt₀, hnxt₀⟩ :=
      exists_ladderPath_of_walk_nxt_at (objAt g₁) (cntAt g₁) z n₀ (objAt_step g₁ hg₁)
        (fun v h => cntAt_eq_zero_of_idle g₁ hg₁ v h)
        (fun v h0 h1 => cntAt_succ_of_pend_pend g₁ hg₁ v h0 h1)
        (fun v h0 h1 => (cntAt_eq_zero_of_pend_idle g₁ hg₁ v h0 h1).1)
        (fun s v hs0 hs1 hv0 hv1 => pinCompat_of_ladderPath g₁ hg₁ s v hs0 hs1 hv0 hv1) hanch₁
    refine ⟨g₀, hg₀, fun v => by rw [hobj₀ v, hobj₁ v],
      fun v hv hreg => by rw [hcnt₀ v, hcnt₁ v hv hreg], hnxt₀, fun σ₀ hσ₀ w => ?_⟩
    -- the re-lift agrees with `g₁` on the object walk, which is all the type reads
    rw [tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := (0 : ℤ)) (k' := (0 : ℤ)) σ₀ σ₁
      (fun t => by rw [add_zero]; exact hσ₀ t) (fun t => by rw [add_zero]; exact hσ₁ t)
      hobj₀ hno w]
    exact hty₁ σ₁ hσ₁ w
  intro e
  induction e with
  | zero =>
      intro _
      refine ⟨g, hg, fun _ => rfl, fun v _ _ => by simp, hrep.symm, hanch,
        fun w hw hw0 hw1 => by simpa using hslack w hw hw0 hw1, by simpa using hbudg,
        fun σ' hσ' w => ?_⟩
      exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := (0 : ℤ)) (k' := (0 : ℤ)) σ' σ
        (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
        (fun _ => rfl) hno w
  | succ e ih =>
      intro hmR'
      have hmR₁ : e * l ≤ R := by
        have : e * l ≤ (e + 1) * l := Nat.mul_le_mul_right l (by omega)
        omega
      obtain ⟨g₁, hg₁, hobj₁, hcnt₁, htop₁, hanch₁, hslack₁, hbudg₁, hty₁⟩ := ih hmR₁
      have hau : a < u := by omega
      -- the splice's premises, read off the two clauses the induction carries
      have hai₁ : pend (objAt g₁ a) = false := by
        rw [hobj₁ a, iterSpliceIdx_of_lt u l e a (by omega)]; exact hai
      have hpend₁ : ∀ v : ℤ, a < v → v ≤ u + (l : ℤ) → pend (objAt g₁ v) = true := by
        intro v hv0 hv1
        rcases lt_or_eq_of_le hv1 with hlt | heq
        · rw [hobj₁ v, iterSpliceIdx_of_lt u l e v hlt]; exact hpend v hv0 hv1
        · rw [heq, htop₁]; exact hpend u (by omega) (by omega)
      have hca₁ : cntAt g₁ (a + 1) = cntAt g (a + 1) + e * l :=
        hcnt₁ (a + 1) (by omega) (by omega)
      have hureg₁ : u ≤ a + 1 + (cntAt g₁ (a + 1) : ℤ) := by
        rw [hca₁]; push_cast; omega
      have hcu₁ : cntAt g₁ u = cntAt g u + e * l := hcnt₁ u le_rfl (by omega)
      have hpu₁ : pend (objAt g₁ u) = true := hpend₁ u (by omega) (by omega)
      have hcl₁ : l ≤ cntAt g₁ u := by rw [hcu₁]; omega
      have hrep₁ : objAt g₁ u = objAt g₁ (u + (l : ℤ)) := by
        rw [hobj₁ u, iterSpliceIdx_of_lt u l e u (by omega), htop₁]
      have hpa₁ : pend (objAt g₁ (a + 1)) = true := hpend₁ (a + 1) (by omega) (by omega)
      have htri₁ := window_iter_pin_trichotomy g₁ hg₁ a u l hl hau hai₁ hpend₁ hureg₁
      have hpins₁ := window_iter_pins g₁ hg₁ a u l R e hl hau hai₁ hpend₁ hureg₁ hslack₁ hmR'
      obtain ⟨g₂, hg₂, hobj₂, hcnt₂⟩ :=
        exists_ladderPath_of_walk_of_pins (spliceObj g₁ u l) (spliceCnt g₁ u l)
          (spliceObj_step hg₁ hrep₁) (spliceCnt_idle hg₁ hpu₁ hcl₁)
          (spliceCnt_pend_pend hg₁ hl hpu₁ hcl₁) (spliceCnt_pend_idle hg₁ hpu₁ hcl₁) hpins₁
      have hobj₂' : ∀ w : ℤ, objAt g₂ w = objAt g₁ (spliceIdx u l w) := fun w => by
        rw [hobj₂ w, spliceObj_eq_objAt_spliceIdx]
      have he1 : e * l + l = (e + 1) * l := by ring
      have hle : e * l + l ≤ R := le_trans (le_of_eq he1) hmR'
      have hDc : (z - a).natAbs = (a - z).natAbs := window_natAbs_sub_comm z a
      -- the raised countdown at `a + 1`, the one value both budget invariants read
      have hca₂ : cntAt g₂ (a + 1) = cntAt g₁ (a + 1) + l := by
        rw [hcnt₂ (a + 1), spliceCnt_add_of_mem_region hl (a + 1) (by omega) (by omega)]
      refine ⟨g₂, hg₂, fun v => ?_, fun v hv hreg => ?_, ?_, fun v hv0 hv1 => ?_,
        fun w hw hw0 hw1 => ?_, ?_, fun σ₂ hσ₂ w => ?_⟩
      · rw [hobj₂' v, hobj₁, iterSpliceIdx_succ]
      · have hreg₁ : u ≤ v + (cntAt g₁ v : ℤ) := by
          rw [hcnt₁ v hv hreg]; push_cast; omega
        rw [hcnt₂ v, spliceCnt_add_of_mem_region hl v hv hreg₁, hcnt₁ v hv hreg]
        omega
      · rw [hobj₂, spliceObj_of_ge (g := g₁) (a := u) (l := l) (u + (l : ℤ)) le_rfl,
          show u + (l : ℤ) - (l : ℤ) = u by ring, hobj₁ u,
          iterSpliceIdx_of_lt u l e u (by omega)]
      · -- the anchor clause, class by class
        rw [hobj₂ v] at hv0
        rw [hobj₂ (v + 1)] at hv1
        rw [hcnt₂ (v + 1)]
        rcases htri₁ v hv0 hv1 with ⟨hva, hv0', hv1', hvc⟩ | ⟨hvw, hvc⟩ |
            ⟨y, huy, hy0, hy1, hvy, hvc⟩
        · rw [hvc]; exact hanch₁ v hv0' hv1'
        · have h1 := hanch₁ a hai₁ hpa₁
          rw [hvc, hvw]
          exact window_iter_anchor_raise (cntAt g₁ (a + 1)) n₀ R ((a - z).natAbs) (e * l) l h1
            (by rw [← hDc]; exact hbudg₁) hle
        · have h1 := hanch₁ y hy0 hy1
          rw [hvc, hvy]
          exact window_iter_anchor_shift (cntAt g₁ (y + 1)) n₀ l y z (le_trans hzu huy) h1
      · -- the pin-pair budget, reproduced at `e + 1`
        rw [hobj₂ w] at hw0
        rw [hobj₂ (w + 1)] at hw1
        rw [hcnt₂ (w + 1), hca₂]
        rcases htri₁ w hw0 hw1 with ⟨hwa, hw0', hw1', hwc⟩ | ⟨hww, hwc⟩ |
            ⟨y, huy, hy0, hy1, hwy, hwc⟩
        · have h1 := hslack₁ w hwa hw0' hw1'
          rw [hwc]
          exact window_iter_slack_raise (cntAt g₁ (a + 1)) (cntAt g₁ (w + 1)) R ((a - w).natAbs)
            (e * l) l ((e + 1) * l) h1 he1
        · exact absurd hww (ne_of_lt hw)
        · exact (window_iter_no_low_shift w y a u l hau huy hwy hw).elim
      · -- the anchor budget, reproduced at `e + 1`
        rw [hca₂]
        exact window_iter_budget_raise (cntAt g₁ (a + 1)) R n₀ ((z - a).natAbs) (e * l) l
          ((e + 1) * l) hbudg₁ he1
      · -- the realized type, through one more splice index
        obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
        have hty_ul : tpOf (ladderModel step pend fwd bwd lab) φ σ
            (iterSpliceIdx u l e (u + (l : ℤ)))
            = tpOf (ladderModel step pend fwd bwd lab) φ σ u := by
          rcases e with _ | e
          · rw [show iterSpliceIdx u l 0 (u + (l : ℤ)) = u + (l : ℤ) from rfl]; exact hty.symm
          · rw [show u + (l : ℤ) = u + ((1 * l : ℕ) : ℤ) by push_cast; ring,
              iterSpliceIdx_boundary u l hl (e + 1) 1 (by omega)]
        have hty₁' : tpOf (ladderModel step pend fwd bwd lab) φ σ₁ u
            = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (u + (l : ℤ)) := by
          rw [hty₁ σ₁ hσ₁ u, hty₁ σ₁ hσ₁ (u + (l : ℤ)),
            iterSpliceIdx_of_lt u l e u (by omega), hty_ul]
        have htr := tpOf_eq_spliceIdx_of_tpOf_eq step pend fwd bwd lab φ u l hl
          (k := (0 : ℤ)) (k' := (0 : ℤ)) σ₁ σ₂
          (fun t => by rw [add_zero]; exact hσ₁ t) (fun t => by rw [add_zero]; exact hσ₂ t)
          hobj₂' hno hty₁' w
        rw [htr, hty₁ σ₁ hσ₁, iterSpliceIdx_succ]

/-! ### The base case: the idle-lengthened path's own pin data

The iterate's three hypotheses — the anchor clause, the pin-pair budget and the anchor budget —
are established ONCE, on the path the idle pump returns, and the iteration then reproduces them
for free. The classification that supplies them is a DICHOTOMY rather than a trichotomy, because
no pending raise has happened yet: a region start of the lengthened path is either one of the
original's below the run, at its own position with its own countdown, or one of the original's at
or above `a`, displaced by the insertion length `E` with its countdown unmoved. There is no third
class because the lengthened run itself contains no region start — every position of it has an
idle successor inside it.

Where the regime's two resources are spent is visible here and nowhere else: the collision's ROOM
pays the anchor budget, once; the insertion's LENGTH pays the pin-pair budget, once. Neither is
touched again by any step of the iteration. -/

/-- **THE IDLE-LENGTHENED PATH'S PIN DICHOTOMY.** Every region start of the path the idle pump
returns is either a region start of the original at or below `a`, with its position and its
countdown untouched, or a region start of the original at or above `a`, displaced by exactly the
insertion length `E` with its countdown unmoved.

The hypotheses are the pump's own output clauses verbatim (`hbelow`, `hrun`, `habove`) together
with the one fact the named idle-run condition supplies — that the original is idle throughout
`[α, a]`, which `exists_idleBlock_of_hasIdleRunBelow` now returns. Nothing here is a new side
condition on the caller. -/
theorem window_idle_pin_dichotomy
    (g g₁ : ℤ → LadderState Q pend)
    (α a : ℤ) (k E : ℕ) (hk : 0 < k) (hαa : α + (k : ℤ) ≤ a)
    (hidleg : ∀ v : ℤ, α ≤ v → v ≤ a → pend (objAt g v) = false)
    (hbelow : ∀ v : ℤ, v < α + (k : ℤ) → objAt g₁ v = objAt g v ∧ cntAt g₁ v = cntAt g v)
    (hrun : ∀ i : ℕ, i < k + E → pend (objAt g₁ (α + (i : ℤ))) = false)
    (habove : ∀ v : ℤ, α + ((k + E : ℕ) : ℤ) ≤ v →
      objAt g₁ v = objAt g (v - (E : ℤ)) ∧ cntAt g₁ v = cntAt g (v - (E : ℤ))) :
    ∀ v : ℤ, pend (objAt g₁ v) = false → pend (objAt g₁ (v + 1)) = true →
      (v ≤ a ∧ pend (objAt g v) = false ∧ pend (objAt g (v + 1)) = true ∧
          cntAt g₁ (v + 1) = cntAt g (v + 1)) ∨
      (∃ w : ℤ, a ≤ w ∧ pend (objAt g w) = false ∧ pend (objAt g (w + 1)) = true ∧
          v = w + (E : ℤ) ∧ cntAt g₁ (v + 1) = cntAt g (w + 1)) := by
  intro v hv0 hv1
  -- the lengthened path is idle throughout `[α, a + E]`
  have hidle₁ : ∀ x : ℤ, α ≤ x → x ≤ a + (E : ℤ) → pend (objAt g₁ x) = false := by
    intro x hx0 hx1
    rcases lt_or_ge x (α + ((k + E : ℕ) : ℤ)) with h | h
    · have hr := hrun (x - α).toNat (by push_cast at h ⊢; omega)
      rwa [show α + (((x - α).toNat : ℕ) : ℤ) = x by omega] at hr
    · rw [(habove x h).1]
      exact hidleg (x - (E : ℤ)) (by push_cast at h ⊢; omega) (by omega)
  rcases lt_or_ge v α with hvα | hvα
  · -- below the block, where the pump leaves the path alone
    refine Or.inl ⟨by omega, ?_, ?_, (hbelow (v + 1) (by omega)).2⟩
    · rw [← (hbelow v (by omega)).1]; exact hv0
    · rw [← (hbelow (v + 1) (by omega)).1]; exact hv1
  · rcases lt_or_ge v (a + (E : ℤ)) with hva | hva
    · -- strictly inside the lengthened run: the successor is idle too, so there is no pin here
      exact (Bool.false_ne_true ((hidle₁ (v + 1) (by omega) (by omega)).symm.trans hv1)).elim
    · -- at or above the run's top, where the pump is a rigid displacement by `E`
      have hge : α + ((k + E : ℕ) : ℤ) ≤ v := by push_cast; omega
      refine Or.inr ⟨v - (E : ℤ), by omega, ?_, ?_, by ring, ?_⟩
      · rw [← (habove v hge).1]; exact hv0
      · rw [show v - (E : ℤ) + 1 = v + 1 - (E : ℤ) by ring, ← (habove (v + 1) (by omega)).1]
        exact hv1
      · rw [(habove (v + 1) (by omega)).2, show v + 1 - (E : ℤ) = v - (E : ℤ) + 1 by ring]

/-- **THE ITERATE'S ANCHOR CLAUSE, AT THE BASE.** The anchor clause at the PRESCRIBED register
value `nxtAt g z` holds on the idle-lengthened path, with the anchor displaced to `z + E`. Both
classes of the dichotomy close on the pin equation `cntAt_eq_nxtAt_of_idle_pend` and the
two-sidedly `1`-Lipschitz register: a pin below the run is pushed FURTHER from the displaced
anchor (`window_pin_dist_grows_below`), and a pin at or above `a` is displaced by exactly as much
as the anchor is, leaving its distance unchanged.

The insertion's length `E` is not spent here — the clause would hold for any `E` — which is the
same asymmetry `window_anchor_clause_of_pin_classification` measured for the composite. -/
theorem window_idle_anchor_clause
    (g g₁ : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a z : ℤ) (E : ℕ) (haz : a < z)
    (hdich : ∀ v : ℤ, pend (objAt g₁ v) = false → pend (objAt g₁ (v + 1)) = true →
      (v ≤ a ∧ pend (objAt g v) = false ∧ pend (objAt g (v + 1)) = true ∧
          cntAt g₁ (v + 1) = cntAt g (v + 1)) ∨
      (∃ w : ℤ, a ≤ w ∧ pend (objAt g w) = false ∧ pend (objAt g (w + 1)) = true ∧
          v = w + (E : ℤ) ∧ cntAt g₁ (v + 1) = cntAt g (w + 1))) :
    ∀ v : ℤ, pend (objAt g₁ v) = false → pend (objAt g₁ (v + 1)) = true →
      ((cntAt g₁ (v + 1) : ℤ) - nxtAt g z).natAbs ≤ (v - (z + (E : ℤ))).natAbs := by
  intro v hv0 hv1
  rcases hdich v hv0 hv1 with ⟨hva, hv0', hv1', hvc⟩ | ⟨w, haw, hw0, hw1, hvw, hvc⟩
  · rw [hvc, cntAt_eq_nxtAt_of_idle_pend g hg v hv0' hv1']
    refine le_trans (nxtAt_lipschitz_two_sided g hg v z) ?_
    exact window_pin_dist_grows_below v z (E : ℤ) (by omega) (Int.natCast_nonneg _)
  · rw [hvc, cntAt_eq_nxtAt_of_idle_pend g hg w hw0 hw1, hvw,
      show (w + (E : ℤ) - (z + (E : ℤ))) = w - z by ring]
    exact nxtAt_lipschitz_two_sided g hg w z

/-- **THE ITERATE'S PIN-PAIR BUDGET, AT THE BASE: THIS IS WHERE THE INSERTION IS SPENT.** On the
idle-lengthened path, the region start of `z`'s region sits at `a + E` while every region start
below the run has stayed where it was, so the original's own pin bound
(`pinCompat_of_ladderPath`) becomes a bound slack by exactly `E`. Any budget `R ≤ E` is therefore
available, and the iterate draws `l` from it per step.

The dichotomy's second class is vacuous below `a + E`: its positions all sit at or above `a + E`.
This is the quantitative content of `no_pin_in_idle_run`, obtained here from the displacement
rather than from the absence of pins in the run. -/
theorem window_idle_slack
    (g g₁ : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a : ℤ) (E R : ℕ) (hRE : R ≤ E)
    (hai : pend (objAt g a) = false) (hap : pend (objAt g (a + 1)) = true)
    (hca : cntAt g₁ (a + (E : ℤ) + 1) = cntAt g (a + 1))
    (hdich : ∀ v : ℤ, pend (objAt g₁ v) = false → pend (objAt g₁ (v + 1)) = true →
      (v ≤ a ∧ pend (objAt g v) = false ∧ pend (objAt g (v + 1)) = true ∧
          cntAt g₁ (v + 1) = cntAt g (v + 1)) ∨
      (∃ w : ℤ, a ≤ w ∧ pend (objAt g w) = false ∧ pend (objAt g (w + 1)) = true ∧
          v = w + (E : ℤ) ∧ cntAt g₁ (v + 1) = cntAt g (w + 1))) :
    ∀ w : ℤ, w < a + (E : ℤ) → pend (objAt g₁ w) = false → pend (objAt g₁ (w + 1)) = true →
      ((cntAt g₁ (a + (E : ℤ) + 1) : ℤ) - cntAt g₁ (w + 1)).natAbs + R
        ≤ (a + (E : ℤ) - w).natAbs := by
  intro w hwa hw0 hw1
  rcases hdich w hw0 hw1 with ⟨hw', hw0', hw1', hwc⟩ | ⟨y, hay, hy0, hy1, hwy, -⟩
  · have hpc := pinCompat_of_ladderPath g hg a w hai hap hw0' hw1'
    rw [hca, hwc]
    omega
  · omega

/-- **THE ITERATE'S ANCHOR BUDGET, AT THE BASE: THIS IS WHERE THE COLLISION'S ROOM IS SPENT.**
The region start's countdown on the lengthened path is the original's, which is `z`'s countdown
plus the distance back to the start (`nxtAt_le_cntAt_region_start`). The collision's room
`hroom : cntAt g z + R ≤ nxtAt g z` therefore pays the budget outright, with the one step from `a`
to `a + 1` left over as slack.

This is the ONLY place the window hypothesis enters the construction, through
`kappa_collision_window_room`'s conclusion, and it is spent once rather than once per step. -/
theorem window_idle_budget
    (g g₁ : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a z : ℤ) (E R : ℕ) (haz : a < z)
    (hai : pend (objAt g a) = false)
    (hregion : ∀ i : ℕ, i ≤ (z - (a + 1)).toNat → pend (objAt g (z - (i : ℤ))) = true)
    (hroom : cntAt g z + R ≤ nxtAt g z)
    (hca : cntAt g₁ (a + (E : ℤ) + 1) = cntAt g (a + 1)) :
    cntAt g₁ (a + (E : ℤ) + 1) + R ≤ nxtAt g z + (z + (E : ℤ) - (a + (E : ℤ))).natAbs := by
  obtain ⟨hstart, -⟩ := nxtAt_le_cntAt_region_start g hg a z haz hai hregion
  rw [hca, hstart]
  omega

/-! ### The idle lengthening with the realized type exposed EVERYWHERE

`exists_iterIdleSpliced_ladderPath` (`LadderIdle.lean`) exposes the realized type only strictly
BELOW its block, mirroring the exposure discipline of the pending pump it was written beside.
This construction's comparison position sits ABOVE the block, so that clause does not reach it,
and no shift argument can substitute: a stab-free realized type is not determined locally, and
the lengthened path is a displacement of the original only above the run.

What makes the global form available is that the idle splice is a RIGID INDEX PULLBACK in both
coordinates: `spliceObj g α k = objAt g ∘ spliceIdx α k` by definition, and
`idleSpliceCnt g α k = cntAt g ∘ spliceIdx α k` likewise — inserting idle positions raises no
countdown anywhere, which is exactly the difference from the pending splice. So HWZ's deletion
lemma in the form `tpOf_eq_spliceIdx_of_tpOf_eq` applies unchanged (it reads the object walk
relation and the block's endpoint type equality, and is indifferent to whether the block is
pending), and the iterate below carries the type at EVERY position through `iterSpliceIdx`. -/

/-- **THE ITERATED IDLE LENGTHENING, READ THROUGH THE INDEX MAP.** `d` duplications of an idle
block `[α, α + k)` whose two ends carry the same object state and the same realized stab-free
type: the walk, the countdown AND the realized type at every position are the original's at the
retracted position `iterSpliceIdx α k d`.

No pin side condition, no regime hypothesis and no `ParamsOk` — `idleSplice_pins` discharges the
pin clause from the run's idleness alone. The register is NOT held at any prescribed position
here, because the consumer prescribes it once at the end of the whole composite rather than at
each stage. -/
theorem exists_iterIdleSpliced_ladderPath_idx {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (α : ℤ) (k : ℕ) (hk : 0 < k)
    (hidle : ∀ i : ℕ, i < k → pend (objAt g (α + (i : ℤ))) = false)
    (hrep : objAt g α = objAt g (α + (k : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ α
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (α + (k : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx α k d v)) ∧
      (∀ v : ℤ, cntAt g' v = cntAt g (iterSpliceIdx α k d v)) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx α k d w) := by
  classical
  haveI : Fintype Q := Fintype.ofFinite Q
  induction d with
  | zero =>
      refine ⟨g, hg, fun _ => rfl, fun _ => rfl, fun σ' hσ' w => ?_⟩
      exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := (0 : ℤ)) (k' := (0 : ℤ)) σ' σ
        (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
        (fun _ => rfl) hno w
  | succ d ih =>
      obtain ⟨g₁, hg₁, hobj₁, hcnt₁, hty₁⟩ := ih
      -- the original's object and type at the retraction of `α + k` are those at `α`
      have hidx_ul : objAt g (iterSpliceIdx α k d (α + (k : ℤ))) = objAt g α := by
        rcases d with _ | d
        · exact hrep.symm
        · rw [show α + (k : ℤ) = α + ((1 * k : ℕ) : ℤ) by push_cast; ring,
            iterSpliceIdx_boundary α k hk (d + 1) 1 (by omega)]
      have hty_ul : tpOf (ladderModel step pend fwd bwd lab) φ σ
          (iterSpliceIdx α k d (α + (k : ℤ)))
          = tpOf (ladderModel step pend fwd bwd lab) φ σ α := by
        rcases d with _ | d
        · exact hty.symm
        · rw [show α + (k : ℤ) = α + ((1 * k : ℕ) : ℤ) by push_cast; ring,
            iterSpliceIdx_boundary α k hk (d + 1) 1 (by omega)]
      have hidle₁ : ∀ i : ℕ, i < k → pend (objAt g₁ (α + (i : ℤ))) = false := fun i hi => by
        rw [hobj₁ (α + (i : ℤ)), iterSpliceIdx_of_lt α k d _ (by omega)]
        exact hidle i hi
      have hrep₁ : objAt g₁ α = objAt g₁ (α + (k : ℤ)) := by
        rw [hobj₁ α, hobj₁ (α + (k : ℤ)), iterSpliceIdx_of_lt α k d α (by omega), hidx_ul]
      obtain ⟨g₂, hg₂, hobj₂, hcnt₂⟩ :=
        exists_idleSpliced_ladderPath g₁ hg₁ α k hk hidle₁ hrep₁
      have hobj₂' : ∀ w : ℤ, objAt g₂ w = objAt g₁ (spliceIdx α k w) := fun w => by
        rw [hobj₂ w, spliceObj_eq_objAt_spliceIdx]
      refine ⟨g₂, hg₂, fun v => ?_, fun v => ?_, fun σ₂ hσ₂ w => ?_⟩
      · rw [hobj₂' v, hobj₁, iterSpliceIdx_succ]
      · -- the idle countdown is the same rigid pullback as the object walk
        rw [hcnt₂ v, iterSpliceIdx_succ, ← hcnt₁ (spliceIdx α k v)]
        rcases lt_or_ge v (α + (k : ℤ)) with h | h
        · rw [idleSpliceCnt_of_lt v h, spliceIdx_of_lt α k v h]
        · rw [idleSpliceCnt_of_ge v h, spliceIdx_of_ge α k v h]
      · obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
        have hty₁' : tpOf (ladderModel step pend fwd bwd lab) φ σ₁ α
            = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (α + (k : ℤ)) := by
          rw [hty₁ σ₁ hσ₁ α, hty₁ σ₁ hσ₁ (α + (k : ℤ)),
            iterSpliceIdx_of_lt α k d α (by omega), hty_ul]
        have htr := tpOf_eq_spliceIdx_of_tpOf_eq step pend fwd bwd lab φ α k hk
          (k := (0 : ℤ)) (k' := (0 : ℤ)) σ₁ σ₂
          (fun t => by rw [add_zero]; exact hσ₁ t) (fun t => by rw [add_zero]; exact hσ₂ t)
          hobj₂' hno hty₁' w
        rw [htr, hty₁ σ₁ hσ₁, iterSpliceIdx_succ]

/-! ### The composite, assembled

Two theorems. The first does the work at the DISPLACED comparison position `z + E`, where the
idle lengthening has put it: it finds the type-respecting pending block of that position's region,
spends `(K1)`'s divisibility bridge to turn the block's length into a divisor of `P + 1`, and
feeds the iterate the three invariants the base-case lemmas supply. The second produces the
lengthened path, chooses `E` large enough to cover the raise, and re-anchors by translation so
that `z` keeps its position — a genuine translation of the path, with the realized type carried
across it by `tpOf_timeShift`, not a restatement at a moved index. -/

/-- **THE WINDOW REGIME'S COMPOSITE RAISE AT THE DISPLACED POSITION.** Given the path `g₁` that
the idle lengthening returns — described by its three agreement clauses `hbel`, `hrn`, `habv` —
a ladder path through the SAME object state as `g` at `z`, with `z`'s countdown raised by exactly
`m · (P + 1)`, the next-deadline register held at `nxtAt g z`, and the realized stab-free type
`g₁`'s own, all read at the displaced position `z + E`.

The raise is an exact multiple of `P + 1` because `(K1)`'s bridge
`typeBlock_length_dvd_of_paramsOk` puts the block length `l` among the divisors of `P + 1`, and
`m · q` copies with `q · l = P + 1` give `m · q · l = m · (P + 1)`.

Scope. The compensator is the idle run BELOW, so neither `HasForwardSlack` nor
`ForwardSlackWitnessed` appears and the refuted deletion-above route is not re-entered. The one
hypothesis beyond `ParamsOk`, the window regime's own data and the collision's room is the idle
run itself, carried here as `hrn`/`habv` and traced back to `HasIdleRunBelow` by the caller.
Nothing here is a cell inclusion and the reserved `cellLE_zero_const_of_kappa_eq` is untouched. -/
theorem exists_window_raise_displaced {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g g₁ : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hg₁ : IsLadderPath step pend g₁)
    (α a z : ℤ) (k E : ℕ) (hk : 0 < k) (hαa : α + (k : ℤ) ≤ a) (haz : a < z)
    (hai : pend (objAt g a) = false)
    (hregion : ∀ t : ℤ, a < t → t ≤ z → pend (objAt g t) = true)
    (hidleg : ∀ v : ℤ, α ≤ v → v ≤ a → pend (objAt g v) = false)
    (hbel : ∀ v : ℤ, v < α + (k : ℤ) → objAt g₁ v = objAt g v ∧ cntAt g₁ v = cntAt g v)
    (hrn : ∀ i : ℕ, i < k + E → pend (objAt g₁ (α + (i : ℤ))) = false)
    (habv : ∀ v : ℤ, α + ((k + E : ℕ) : ℤ) ≤ v →
      objAt g₁ v = objAt g (v - (E : ℤ)) ∧ cntAt g₁ v = cntAt g (v - (E : ℤ)))
    (hTc : Tc ≤ cntAt g z) (m : ℕ)
    (hroom : cntAt g z + m * (P + 1) ≤ nxtAt g z) (hRE : m * (P + 1) ≤ E)
    (σ₁ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ₁ : ∀ t : ℤ, σ₁.state t = (t, g₁ t)) :
    ∃ g₂ : ℤ → LadderState Q pend, IsLadderPath step pend g₂ ∧
      objAt g₂ (z + (E : ℤ)) = objAt g z ∧
      cntAt g₂ (z + (E : ℤ)) = cntAt g z + m * (P + 1) ∧
      nxtAt g₂ (z + (E : ℤ)) = nxtAt g z ∧
      ∀ σ₂ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ₂.state t = (t, g₂ t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ₂ (z + (E : ℤ))
          = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (z + (E : ℤ)) := by
  classical
  have hbud := budget_le_Tc step pend lab φ Tc Tn P B hp
  have hkE : α + ((k + E : ℕ) : ℤ) ≤ z + (E : ℤ) := by push_cast; omega
  have hcz₁ : cntAt g₁ (z + (E : ℤ)) = cntAt g z := by
    rw [(habv (z + (E : ℤ)) hkE).2, show z + (E : ℤ) - (E : ℤ) = z by ring]
  have hoz₁ : objAt g₁ (z + (E : ℤ)) = objAt g z := by
    rw [(habv (z + (E : ℤ)) hkE).1, show z + (E : ℤ) - (E : ℤ) = z by ring]
  have hpz₁ : pend (objAt g₁ (z + (E : ℤ))) = true := by
    rw [hoz₁]; exact hregion z (by omega) le_rfl
  have hbz : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ≤ cntAt g₁ (z + (E : ℤ)) := by
    rw [hcz₁]; omega
  -- the type-respecting pending block of the displaced position's own region
  obtain ⟨u, l, hl, hlb, hzu, hcl, hul, hrepu, htyu⟩ :=
    exists_typeBlock_of_budget_le_cnt_within step pend fwd bwd lab φ σ₁ hg₁ (z + (E : ℤ)) hpz₁ hbz
  have hureg₀ : u ≤ z + (E : ℤ) + (cntAt g₁ (z + (E : ℤ)) : ℤ) := by
    have h := Int.natCast_nonneg l
    have h2 : ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card : ℕ) : ℤ)
        ≤ (cntAt g₁ (z + (E : ℤ)) : ℤ) := by exact_mod_cast hbz
    omega
  have hpu : pend (objAt g₁ u) = true := by
    have h := (cntAt_sub_of_pend g₁ hg₁ (z + (E : ℤ)) hpz₁ (u - (z + (E : ℤ))).toNat
      (by omega)).1
    rwa [show z + (E : ℤ) + (((u - (z + (E : ℤ))).toNat : ℕ) : ℤ) = u by omega] at h
  -- `(K1)`: the block's length divides `P + 1`
  obtain ⟨q, hq⟩ := typeBlock_length_dvd_of_paramsOk step pend fwd bwd lab φ hp σ₁
    (fun t => by rw [add_zero]; exact hσ₁ t) hg₁ hno u l hl hlb hpu hcl hrepu htyu
  have hdl : m * q * l = m * (P + 1) := by rw [hq]; ring
  -- the base-case invariants, read off the dichotomy
  have hdich := window_idle_pin_dichotomy g g₁ α a k E hk hαa hidleg hbel hrn habv
  have hap : pend (objAt g (a + 1)) = true := hregion (a + 1) (by omega) (by omega)
  have hregion' : ∀ i : ℕ, i ≤ (z - (a + 1)).toNat → pend (objAt g (z - (i : ℤ))) = true :=
    fun i hi => hregion (z - (i : ℤ)) (by omega) (by omega)
  have hca : cntAt g₁ (a + (E : ℤ) + 1) = cntAt g (a + 1) := by
    rw [(habv (a + (E : ℤ) + 1) (by push_cast; omega)).2,
      show a + (E : ℤ) + 1 - (E : ℤ) = a + 1 by ring]
  have hanch₁ := window_idle_anchor_clause g g₁ hg a z E haz hdich
  have hslack₁ := window_idle_slack g g₁ hg a E (m * (P + 1)) hRE hai hap hca hdich
  have hbudg₁ := window_idle_budget g g₁ hg a z E (m * (P + 1)) haz hai hregion' hroom hca
  have hai₁ : pend (objAt g₁ (a + (E : ℤ))) = false := by
    rw [(habv (a + (E : ℤ)) (by push_cast; omega)).1, show a + (E : ℤ) - (E : ℤ) = a by ring]
    exact hai
  have hcstart : cntAt g (a + 1) = cntAt g z + (z - (a + 1)).toNat :=
    (nxtAt_le_cntAt_region_start g hg a z haz hai hregion').1
  have hpend₁ : ∀ v : ℤ, a + (E : ℤ) < v → v ≤ u + (l : ℤ) → pend (objAt g₁ v) = true := by
    intro v hv0 hv1
    rcases le_or_gt v (z + (E : ℤ)) with hvz | hvz
    · rw [(habv v (by push_cast; omega)).1]
      exact hregion (v - (E : ℤ)) (by omega) (by omega)
    · have h := (cntAt_sub_of_pend g₁ hg₁ (z + (E : ℤ)) hpz₁ (v - (z + (E : ℤ))).toNat
        (by omega)).1
      rwa [show z + (E : ℤ) + (((v - (z + (E : ℤ))).toNat : ℕ) : ℤ) = v by omega] at h
  have hureg₁ : u ≤ a + (E : ℤ) + 1 + (cntAt g₁ (a + (E : ℤ) + 1) : ℤ) := by
    rw [hca, hcstart]
    push_cast
    omega
  -- the iterate
  obtain ⟨g₂, hg₂, hobj₂, hcnt₂, hnxt₂, hty₂⟩ :=
    exists_window_iterSpliced_ladderPath step pend fwd bwd lab φ hno hg₁ (z + (E : ℤ))
      (a + (E : ℤ)) u l (m * (P + 1)) (nxtAt g z) hl (by omega) hzu hai₁ hpend₁ hureg₁ hcl hrepu
      hanch₁ hslack₁ hbudg₁ σ₁ hσ₁ htyu (m * q) (by omega)
  refine ⟨g₂, hg₂, ?_, ?_, hnxt₂, fun σ₂ hσ₂ => ?_⟩
  · rw [hobj₂ (z + (E : ℤ)), iterSpliceIdx_of_lt u l (m * q) _ (by omega), hoz₁]
  · rw [hcnt₂ (z + (E : ℤ)) hzu (by omega), hcz₁, hdl]
  · rw [hty₂ σ₂ hσ₂ (z + (E : ℤ)), iterSpliceIdx_of_lt u l (m * q) _ (by omega)]

/-- **THE WINDOW REGIME'S RAISING PRIMITIVE.** In the ordinary window regime — an idle position in
`z`'s past, so `z`'s region has a region start `a` below it — and under the named idle-run
condition, a ladder path through `(objAt g z, cntAt g z + m · (P + 1), nxtAt g z)` at `z` itself,
carrying the realized stab-free type at `z`.

The construction is the composite the decision gate measured: `m · (P + 1)` duplications of a
type-respecting idle block below `a` lengthen the run and bank `m · (P + 1) · k` of pin slack;
`m · q` duplications of a type-respecting pending block of `z`'s region spend `m · (P + 1)` of it
and raise the countdown by exactly `m · (P + 1)`; the register is prescribed once, at the end, by
the `z`-anchored lift. The idle lengthening displaces the comparison position by
`E = m · (P + 1) · k`, and the last step is a genuine TRANSLATION of the path back by `E`
(`isLadderPath_shift`), with the realized type carried across it by `tpOf_timeShift` — so the
conclusion is read at `z`, not at a moved index.

Where each resource is spent, measured rather than asserted: the collision's ROOM `hroom` pays the
anchor budget once (`window_idle_budget`); the insertion's LENGTH pays the pin-pair budget once
(`window_idle_slack`); each of the `m · q` raising steps draws `l` from the latter and nothing from
the former. `(K1)` is spent exactly once, on `l ∣ P + 1`.

Scope, stated because it bounds what this buys. The compensator is the idle run BELOW, so neither
`HasForwardSlack` nor `ForwardSlackWitnessed` appears anywhere in the construction and the route
refuted for the pending-forever regime is not re-entered. `HasIdleRunBelow` is a carried
hypothesis, not a theorem: it RESTRICTS the obligation rather than discharging it, so the reserved
`cellLE_zero_const_of_kappa_eq` is claimed by nothing here, and neither is the positive
factorization lemma in its unconditional form. This is not yet a cell inclusion; lifting it to one
is the next phase's work. -/
theorem exists_window_raise_ladderPath {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z a : ℤ)
    (haz : a < z) (hai : pend (objAt g a) = false)
    (hregion : ∀ t : ℤ, a < t → t ≤ z → pend (objAt g t) = true)
    (hrun : HasIdleRunBelow pend φ g a)
    (hTc : Tc ≤ cntAt g z) (m : ℕ)
    (hroom : cntAt g z + m * (P + 1) ≤ nxtAt g z) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  obtain ⟨σ₀, hσ₀⟩ := exists_hist_of_isLadderPath fwd bwd g hg
  obtain ⟨α, k, hk, hαa, hidleg, hidleblk, hrepα, htyα⟩ :=
    exists_idleBlock_of_hasIdleRunBelow step pend fwd bwd lab φ σ₀ hg a hrun
  -- stage one: one duplication of the idle block per unit of the raise
  obtain ⟨g₁, hg₁, hobj₁, hcnt₁, hty₁⟩ :=
    exists_iterIdleSpliced_ladderPath_idx step pend fwd bwd lab φ hno hg α k hk hidleblk hrepα
      σ₀ hσ₀ htyα (m * (P + 1))
  obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
  have hEk : k + m * (P + 1) * k = (m * (P + 1) + 1) * k := by ring
  have hRE : m * (P + 1) ≤ m * (P + 1) * k := Nat.le_mul_of_pos_right _ hk
  have hbel : ∀ v : ℤ, v < α + (k : ℤ) → objAt g₁ v = objAt g v ∧ cntAt g₁ v = cntAt g v :=
    fun v hv => ⟨by rw [hobj₁ v, iterSpliceIdx_of_lt α k (m * (P + 1)) v hv],
      by rw [hcnt₁ v, iterSpliceIdx_of_lt α k (m * (P + 1)) v hv]⟩
  have hrn : ∀ i : ℕ, i < k + m * (P + 1) * k → pend (objAt g₁ (α + (i : ℤ))) = false := by
    intro i hi
    rw [hobj₁ (α + (i : ℤ))]
    obtain ⟨h1, h2⟩ := iterSpliceIdx_mem α k (m * (P + 1)) (α + (i : ℤ)) (by omega)
      (by rw [← hEk]; omega)
    have h := hidleblk (iterSpliceIdx α k (m * (P + 1)) (α + (i : ℤ)) - α).toNat (by omega)
    rwa [show α + (((iterSpliceIdx α k (m * (P + 1)) (α + (i : ℤ)) - α).toNat : ℕ) : ℤ)
      = iterSpliceIdx α k (m * (P + 1)) (α + (i : ℤ)) by omega] at h
  have habv : ∀ v : ℤ, α + ((k + m * (P + 1) * k : ℕ) : ℤ) ≤ v →
      objAt g₁ v = objAt g (v - ((m * (P + 1) * k : ℕ) : ℤ)) ∧
      cntAt g₁ v = cntAt g (v - ((m * (P + 1) * k : ℕ) : ℤ)) := by
    intro v hv
    have hge : α + (((m * (P + 1) + 1) * k : ℕ) : ℤ) ≤ v := by rw [← hEk]; exact hv
    exact ⟨by rw [hobj₁ v, iterSpliceIdx_of_ge α k (m * (P + 1)) v hge],
      by rw [hcnt₁ v, iterSpliceIdx_of_ge α k (m * (P + 1)) v hge]⟩
  -- stage two: the raise, at the displaced comparison position
  obtain ⟨g₂, hg₂, hobj₂, hcnt₂, hnxt₂, hty₂⟩ :=
    exists_window_raise_displaced step pend fwd bwd lab φ Tc Tn P B hp hno g g₁ hg hg₁
      α a z k (m * (P + 1) * k) hk hαa haz hai hregion hidleg hbel hrn habv hTc m hroom hRE
      σ₁ hσ₁
  obtain ⟨σ₂, hσ₂⟩ := exists_hist_of_isLadderPath fwd bwd g₂ hg₂
  -- the retraction of the displaced position is `z` itself
  have hidx_z : iterSpliceIdx α k (m * (P + 1)) (z + ((m * (P + 1) * k : ℕ) : ℤ)) = z := by
    rw [iterSpliceIdx_of_ge α k (m * (P + 1)) _ (by rw [← hEk]; omega)]
    ring
  -- stage three: translate the path back by the insertion length
  refine ⟨fun v => g₂ (v + ((m * (P + 1) * k : ℕ) : ℤ)), isLadderPath_shift hg₂ _, ?_, ?_, ?_,
    fun σ σ' hσ hσ' => ?_⟩
  · change objAt g₂ (z + ((m * (P + 1) * k : ℕ) : ℤ)) = _
    exact hobj₂
  · change cntAt g₂ (z + ((m * (P + 1) * k : ℕ) : ℤ)) = _
    exact hcnt₂
  · change nxtAt g₂ (z + ((m * (P + 1) * k : ℕ) : ℤ)) = _
    exact hnxt₂
  · -- the type across the translation: `tpOf_timeShift` on the history, then the two stages
    have hshift : ∀ t : ℤ, (σ₂.timeShift ((m * (P + 1) * k : ℕ) : ℤ)).state t
        = (t + ((m * (P + 1) * k : ℕ) : ℤ),
          (fun v : ℤ => g₂ (v + ((m * (P + 1) * k : ℕ) : ℤ))) t) := by
      intro t
      rw [WorldHistory.timeShift_state, hσ₂ (t + ((m * (P + 1) * k : ℕ) : ℤ))]
    have e1 := tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ
      (k := ((m * (P + 1) * k : ℕ) : ℤ)) (k' := (0 : ℤ))
      (σ₂.timeShift ((m * (P + 1) * k : ℕ) : ℤ)) σ' hshift
      (fun t => by rw [add_zero]; exact hσ' t) (fun _ => rfl) hno z
    have e2 : tpOf (ladderModel step pend fwd bwd lab) φ σ₀ z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z :=
      tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := (0 : ℤ)) (k' := (0 : ℤ)) σ₀ σ
        (fun t => by rw [add_zero]; exact hσ₀ t) (fun t => by rw [add_zero]; exact hσ t)
        (fun _ => rfl) hno z
    rw [← e1, tpOf_timeShift, hty₂ σ₂ hσ₂, hty₁ σ₁ hσ₁, hidx_z, e2]

/-! ### The lowering direction is NOT the raising direction's mirror

The raising primitive above is complete. Its mirror — the in-region block DELETED rather than
duplicated, lowering `z`'s countdown by `m · (P + 1)` — is NOT available under the same
hypotheses, and the obstruction is arithmetic rather than constructive. It is recorded here as a
compiled measurement rather than as prose, because the statement that fails is small enough to
exhibit.

`window_anchor_clause_of_pin_classification` discharges the raising direction's anchor clause at
the region start from exactly two inputs: the collision's own room `c + jP ≤ n`, and the path's
own arithmetic `n ≤ c + 2 · d + 1` (`nxtAt_le_cntAt_region_start`), where `c = cntAt g z`,
`n = nxtAt g z` and `d` is the in-region depth. In the lowering direction the region start's
countdown FALLS by `jP`, so the clause's binding half reverses and becomes `n + jP ≤ c + 2·d + 1`
— the path's own bound, slackened by exactly the displacement.

What the collision supplies in the lowering branch is `c ≤ n`, not a bound on `n` from above
(`kappa_collision_window_room`'s second disjunct is `c = c' + j · (P + 1) ∧ c ≤ n`), and the
path's bound is TIGHT: `window_lower_anchor_fails_at_tight_bound` exhibits a tuple at
`n = c + 2 · d + 1` where the clause fails for every positive displacement, so the deficit is not
an artefact of a loose witness. The pin PAIR clause is short by the same `jP` and for the same
reason: `window_pin_compat_lower_of_spacing`'s hypothesis `hsp : W + 1 + jP ≤ DW` is region-start
spacing PLUS the displacement, and `regionStart_spacing` supplies only `W + 1 ≤ DW`.

So the lowering direction needs ONE named condition beyond the decision gate's five — a bound on
the register from above, relative to the in-region depth. Under the gate's own criterion ("a
clause that needs a sixth hypothesis is a FAIL, not a widening") that is a FAIL, and the
condition is NOT added here: `window_lower_anchor_of_required` records exactly what the clause
becomes derivable from, so that a future phase can decide whether that condition is admissible
rather than discovering the deficit again. The companion probe is
`specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`. -/

/-- **THE LOWERING DIRECTION'S ANCHOR CLAUSE IS NOT IMPLIED BY THE REGIME'S OWN DATA.** The
lowering branch's room `c ≤ n`, the deletion's own bound `jP ≤ c`, and the path's arithmetic
`n ≤ c + 2 · d + 1` do not jointly give the clause's binding half `n + jP ≤ c + 2 · d + 1`.

This is the measured FAIL, not an argument: the three hypotheses are exactly what the window
regime, the collision and the path supply, and the witness is explicit. -/
theorem window_lower_anchor_not_implied :
    ¬ ∀ c n d jP : ℕ, jP ≤ c → c ≤ n → n ≤ c + 2 * d + 1 → n + jP ≤ c + 2 * d + 1 := by
  intro h
  have := h 1 2 0 1 (by omega) (by omega) (by omega)
  omega

/-- **AND THE DEFICIT IS NOT AN ARTEFACT OF A LOOSE WITNESS.** With the path's own bound TIGHT —
`n = c + 2 · d + 1`, which `nxtAt_lipschitz` permits — the lowering direction's anchor clause
fails for EVERY positive displacement. So no sharpening of the path's arithmetic recovers it. -/
theorem window_lower_anchor_fails_at_tight_bound :
    ¬ ∀ c d jP : ℕ, 0 < jP → jP ≤ c →
      (((c + d - jP : ℕ) : ℤ) - ((c + 2 * d + 1 : ℕ) : ℤ)).natAbs ≤ d + 1 := by
  intro h
  have := h 1 0 1 (by omega) (by omega)
  omega

/-- **WHAT THE LOWERING DIRECTION WOULD NEED, STATED SO IT NEED NOT BE REDISCOVERED.** The
clause becomes derivable the instant the register is bounded from above by the in-region depth:
one named condition, `n + jP ≤ c + 2 · d + 1`, on top of the lowering branch's own room. Nothing
in this module assumes it, and no declaration here carries it — it is recorded as the exact shape
of the missing hypothesis, for a later phase to accept or reject on its own merits. -/
theorem window_lower_anchor_of_required (c n d jP : ℕ) (hjP : jP ≤ c) (hroom : c ≤ n)
    (hreq : n + jP ≤ c + 2 * d + 1) :
    (((c + d - jP : ℕ) : ℤ) - (n : ℤ)).natAbs ≤ d + 1 := by
  omega

/-! ## The cell level: the window regime's upward inclusion

The raising primitive is stated on the WITNESSING PATH, and necessarily so: its region start `a`,
its region run and the idle run below `a` are properties of the path, not of the state at `z`.
`cntAt_le_nxtAt_succ_of_idle_past` runs one way only — an idle position in the past puts the
position inside the window — and its converse is false, so the window hypothesis `c ≤ n + 1` does
NOT return an idle position in the past, and no state-level variant of the regime's path data can
be read off `(q, c, n)`.

`WindowIdleRunWitnessed` below is therefore the same shape `ForwardSlackWitnessed`
(`LadderCell.lean`) takes for the pending-forever regime's downward inclusion: EXISTENTIAL over
the paths through the state, asserting that every type the cell realizes is realized there by
SOME path carrying the region-start-plus-idle-run package. It is a carried hypothesis, asserted
to hold nowhere, and the inclusion below is exactly as strong as it.
-/

/-- **THE WINDOW REGIME'S PATH DATA, LIFTED FROM ONE PATH TO A WHOLE CELL.** Every type the cell
at `x` realizes at `z` is realized there by SOME ladder path through `x` that has a region start
`a` strictly below `z` — idle at `a`, pending throughout `(a, z]` — with the named idle-run
condition `HasIdleRunBelow pend φ · a` holding below that start.

This is the weakest condition on the STATE `x` under which the raising primitive
`exists_window_raise_ladderPath`, which is stated on the witnessing path, yields a CELL-level
inclusion. It is existential over paths rather than universal, which is what keeps it weaker than
demanding the package of every path through `x`: one climbing or pending-forever path through `x`
is compatible with some other path realizing the same type with an idle run below.

Nothing here asserts the condition HOLDS at any state. `HasIdleRunBelow` is not a consequence of
`ParamsOk` (`idle_run_lt_tIdle_of_no_idleCycle`, `LadderPump.lean`, is the bound in the other
direction), and the window hypothesis `c ≤ n + 1` does not even return the region start:
`cntAt_le_nxtAt_succ_of_idle_past` runs from an idle past to the window and not back. So this
RESTRICTS an obligation rather than discharging one, and the reserved
`cellLE_zero_const_of_kappa_eq` stays claimed by nothing.

`HasForwardSlack` and `ForwardSlackWitnessed` appear nowhere in it: the compensator is the idle
run BELOW the position, never slack above it, so the route refuted for the pending-forever regime
is not re-entered here. -/
def WindowIdleRunWitnessed {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (x : LadderState Q pend) (z : ℤ) : Prop :=
  ∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
      ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z,
    ∃ (g : ℤ → LadderState Q pend)
      (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      IsLadderPath step pend g ∧ g z = x ∧ (∀ t : ℤ, τ.state t = (t, g t)) ∧
      (∃ a : ℤ, a < z ∧ pend (objAt g a) = false ∧
        (∀ t : ℤ, a < t → t ≤ z → pend (objAt g t) = true) ∧
        HasIdleRunBelow pend φ g a) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ τ z = T

/-- **THE WINDOW REGIME'S UPWARD CELL INCLUSION.** In the ordinary window regime at countdown at
least `Tc`, under the witnessed idle-run condition, the cell at `(q, c, n)` is contained in the
cell at `(q, c + m · (P + 1), n)`: every type realized at the former is realized at the latter by
the window regime's composite surgery.

The regime hypothesis is not carried separately — the collision's own room
`hroom : c + m · (P + 1) ≤ n` already implies `c ≤ n`, hence `¬ (n + 2 ≤ c)`, so this statement
lies inside the window branch by
construction rather than by assumption. That room is what `kappa_collision_window_room` delivers
for whichever countdown is the larger, and it is the ONE resource the anchor clause at `z`'s own
region start is paid out of.

The proof is `cellAt_subset_of_shift_of_pend_past`'s shape with the pending-forever hypothesis
replaced: `mem_cellAt_ladder_iff` on both sides, `objAt`/`cntAt`/`nxtAt` read off the witnessing
state, the region start and the idle run taken from `WindowIdleRunWitnessed` rather than derived
(they are not derivable — see that definition's docstring), the raising primitive applied at that
start, and the history rebuilt with `exists_hist_of_isLadderPath`.

Scope. This inclusion carries NEITHER `HasForwardSlack` NOR `ForwardSlackWitnessed`. In the
pending-forever regime the DOWNWARD direction is the one that needs the witnessing slack
hypothesis; here the upward direction is paid for entirely by the idle run BELOW `z`'s region, so
the refuted deletion-above route is not re-entered. The downward direction is NOT available in
this regime and is not a mirror of this one: the anchor clause reverses under deletion and needs a
sixth hypothesis, recorded as `window_lower_anchor_of_required` and excluded by the decision
gate's own criterion. Nothing here claims `cellLE_zero_const_of_kappa_eq` or any prefix of it, and
being strictly stronger in hypotheses this inclusion bears on that reserved statement's truth
value in neither direction. -/
theorem cellAt_subset_of_window_raise {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hTc : Tc ≤ c) (hroom : c + m * (P + 1) ≤ n) (z : ℤ)
    (hwit : WindowIdleRunWitnessed step pend fwd bwd lab φ
      (⟨(q, c, n), h⟩ : LadderState Q pend) z) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, ⟨a, haz, hai, hregion, hrun⟩, hTeq⟩ := hwit T hT
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n := by simp [nxtAt, hgz]
  obtain ⟨g', hg', ho, hc, hn, hty⟩ :=
    exists_window_raise_ladderPath step pend fwd bwd lab φ Tc Tn P B hp hno g hg z a haz hai
      hregion hrun (by rw [hcz]; exact hTc) m (by rw [hcz, hnz]; exact hroom)
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  rw [mem_cellAt_ladder_iff]
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c + m * (P + 1), n)
    rw [ho, hc, hn, hoz, hcz, hnz]
  · rw [hty τ τ' hτ hτ', hTeq]

end Gate

end FormalSystem.Metalogic.Decidability.RaySummary

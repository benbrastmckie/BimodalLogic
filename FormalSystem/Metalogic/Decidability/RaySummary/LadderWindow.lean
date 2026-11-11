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

end Gate

end FormalSystem.Metalogic.Decidability.RaySummary

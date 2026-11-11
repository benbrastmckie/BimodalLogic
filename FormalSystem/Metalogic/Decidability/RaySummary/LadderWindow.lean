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

end Gate

end FormalSystem.Metalogic.Decidability.RaySummary

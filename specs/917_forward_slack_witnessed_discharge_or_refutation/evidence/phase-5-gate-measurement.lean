/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

/-!
# Phase 5 gate measurement: both clauses of `exists_deleted_ladderPath_of_next_region_nxt`
# are NOT dischargeable from the gate's admitted hypotheses

This file is the GATE MEASUREMENT for the decision gate, not a result about the formal system.
It reduces the two clauses `hanch` and `hstraddle` of
`exists_deleted_ladderPath_of_next_region_nxt` to their arithmetic cores at the block the spaced
type pigeonhole returns inside the FIRST REGION ABOVE `z`'s own region, collects every fact the
admitted hypotheses supply about that arithmetic, and exhibits concrete satisfying assignments
of those facts at which each clause is FALSE.

## The reduction

With `z` pending, `C = cntAt g z`, `N = nxtAt g z`, an idle run of length `I ≥ 1` above `z`'s
region, and `s₀ = z + C + I + 1` the first region start above it:

* the ONLY pin of the deleted walk strictly below the block's base is `s = z + C + I`, because
  every position at or below `z` is pending (`hpast`), every position of `z`'s region is pending,
  and every position of the idle run `z + C + 1 .. z + C + I - 1` has an IDLE successor and so is
  not a pin;
* that pin's region reaches the block, so `del_pin_pull_of_lt` puts it in its FIRST branch and
  `delCnt g u d (s + 1) = K - d` where `K = cntAt g s₀`;
* a pin `v` of the deleted walk at or above the block is the original's pin at `p = v + d`, with
  `delCnt g u d (v + 1) = cntAt g (p + 1) = nxtAt g p =: B` by `del_pin_pull_of_ge` and
  `cntAt_eq_nxtAt_of_idle_pend`, and `p ≥ s₀ + K + 1` because `s₀`'s whole region is pending;
* `hanch` at `v` therefore reads `|B - N| ≤ |p - d - z|`, and `hstraddle` at `(s, v)` reads
  `|(K - d) - B| ≤ |p - d - s|`.

## The facts available about `B`

`Avail` below collects them: the nonnegativity of the `ℕ`-valued quantities; the consumer's gap
`N + 2 ≤ C` and threshold `Tc ≤ C`; `(K3)`'s `2 * tShort + tIdle + 2 ≤ Tc`; `I ≥ 1`; the
pigeonhole's own room bound `tShort ≤ K` and block bound `d ≤ tShort` together with its output
window `s₀ ≤ u` and `u + d ≤ s₀ + tShort`; the pin's position `p ≥ s₀ + K + 1`; and the only two
facts the ORIGINAL path supplies about `B` — pin compatibility at the pair `(s, p)`
(`pinCompat_of_ladderPath`) and the register's `1`-Lipschitz property from `z`
(`nxtAt_lipschitz_two_sided`).

## The verdict

Both clauses are false at assignments satisfying every one of those facts, and the violation is
by exactly the deletion's own length: `d` for `hanch`, `2 * d` for `hstraddle`. The violating
assignments are the SATURATED ones — the register climbing at its maximum rate, so that pin
compatibility and the Lipschitz bound hold with equality. Deleting `d` positions shrinks the
upper pin's distance from `z` by `d` while leaving its VALUE untouched, and additionally lowers
the lower pin's value by `d`; a configuration already at the bound therefore breaks by `d` and
by `2 * d` respectively.

Both assignments are at a scale a two-state object can realize: `tShort = 2` (the smallest value
available once the object carries both a pending and an idle state), `tIdle = 0`, and
`Tc = 2 * tShort + tIdle + 2 = 6 ≤ C`.

This is a measurement of NON-DERIVABILITY from the enumerated facts, at the arithmetic layer.
The path-level refutation — that a ladder path realizing such an assignment exists — is the
separate obstruction probe.
-/

namespace Gate917

/-- Every fact the gate's admitted hypotheses supply about the arithmetic the two clauses of
`exists_deleted_ladderPath_of_next_region_nxt` reduce to at the block the spaced type pigeonhole
returns inside the first region above `z`'s region. -/
def Avail (z C N I K u d p B tShort tIdle Tc : ℤ) : Prop :=
  -- the `ℕ`-valued quantities are nonnegative, and the block is non-degenerate
  0 ≤ C ∧ 0 ≤ N ∧ 0 ≤ K ∧ 0 ≤ B ∧ 0 < d ∧ 0 ≤ tIdle ∧ 0 ≤ tShort ∧
  -- the consumer's regime at `z`
  N + 2 ≤ C ∧ Tc ≤ C ∧
  -- `(K3)`
  2 * tShort + tIdle + 2 ≤ Tc ∧
  -- a non-empty idle run above `z`'s region
  1 ≤ I ∧
  -- the pigeonhole's room bound at `s₀` and the bound on the block it returns
  tShort ≤ K ∧ d ≤ tShort ∧
  -- the block lies in the pigeonhole's own sampling window
  z + C + I + 1 ≤ u ∧ u + d ≤ z + C + I + 1 + tShort ∧
  -- the upper pin lies above `s₀`'s region, every position of which is pending
  z + C + I + 1 + K + 1 ≤ p ∧
  -- `pinCompat_of_ladderPath` at the pair `(s, p)`
  (K - B).natAbs ≤ (p - (z + C + I)).natAbs ∧
  -- `nxtAt_lipschitz_two_sided` from `z`
  (B - N).natAbs ≤ (p - z).natAbs

/-- **THE ANCHOR CLAUSE `hanch` IS FALSE AT A SATURATED CONFIGURATION, by exactly `d`.**

`z = 0`, `C = 6`, `N = 0`, `I = 1`, `K = 7`, `u = 8`, `d = 2`, `p = 16`, `B = 16`,
`tShort = 2`, `tIdle = 0`, `Tc = 6`. Both path facts hold with EQUALITY: pin compatibility is
`|7 - 16| = 9 = 16 - 7`, and the Lipschitz bound is `|16 - 0| = 16 = 16 - 0`. The clause asks
for `16 ≤ 14` and the gap is exactly `d = 2`. -/
theorem anch_refuted :
    Avail 0 6 0 1 7 8 2 16 16 2 0 6 ∧
      ¬ ((16 : ℤ) - 0).natAbs ≤ ((16 : ℤ) - 2 - 0).natAbs := by
  refine ⟨?_, by norm_num⟩
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- **THE STRADDLE CLAUSE `hstraddle` IS FALSE AT A SATURATED CONFIGURATION, by exactly `2 * d`.**

`z = 0`, `C = 6`, `N = 0`, `I = 1`, `K = 2`, `u = 8`, `d = 2`, `p = 11`, `B = 6`, `tShort = 2`,
`tIdle = 0`, `Tc = 6`. Pin compatibility holds with equality, `|2 - 6| = 4 = 11 - 7`, and the
Lipschitz bound holds with room to spare, `|6 - 0| = 6 ≤ 11`. The clause asks for `4 ≤ 2` and
the gap is exactly `2 * d = 4`: the deletion lowers the lower pin's value by `d` AND shortens
the pair's distance by `d`, and the two losses add. -/
theorem straddle_refuted :
    Avail 0 6 0 1 2 8 2 11 6 2 0 6 ∧
      ¬ (((2 : ℤ) - 2) - 6).natAbs ≤ ((11 : ℤ) - 2 - (0 + 6 + 1)).natAbs := by
  refine ⟨?_, by norm_num⟩
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- **THE DEFICIT IS EXACTLY THE DELETION'S LENGTH, not an artefact of the two assignments
above.** From pin compatibility alone the straddle clause's binding direction needs
`B ≤ K + (p - s) - 2 * d` while the available bound is `B ≤ K + (p - s)`; the anchor clause's
needs `B ≤ N + (p - z) - d` while the available bound is `B ≤ N + (p - z)`. Both residuals are
exactly the amount the deletion removes, so no choice of `u` inside the pigeonhole's window and
no choice of `d` below `tShort` closes either one: every admissible `d` is strictly positive. -/
theorem deficit_is_the_block_length (K B p s z N d : ℤ) (hd : 0 < d)
    (hpinsat : B = K + (p - s)) (hlipsat : B = N + (p - z)) :
    ¬ (B ≤ K + (p - s) - 2 * d) ∧ ¬ (B ≤ N + (p - z) - d) := by
  exact ⟨by omega, by omega⟩

end Gate917

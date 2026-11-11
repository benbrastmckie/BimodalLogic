import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

set_option maxHeartbeats 1000000

/-!
# Route (d) is refuted at the pin layer: the deletion inside the first region above `z`'s
# region has no deleted ladder path when the straddling pin pair is saturated

**NEGATIVE.** This file is the machine-checked record of the obstruction to route (d) — the
attempt to DISCHARGE `ForwardSlackWitnessed` by deleting a type-respecting block inside the first
region above `z`'s own region while holding the register at `z`, so that the next region's
countdown could be driven below `tShort Q φ` by iteration.

## What was asked

`exists_deleted_ladderPath_of_next_region_nxt`
(`FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`, `section DelNxt`) lands that
deletion, taking exactly two clauses as hypotheses: `hanch` for the pins at or above the block,
and `hstraddle` for the pairs that straddle it. Route (d) asked for both clauses to be
discharged, for the block the spaced type pigeonhole returns, out of the pending-forever regime
at countdown at least `Tc` together with `ParamsOk` — in particular out of `(K2)`'s
`cascadeBound` and its `iter_doubling` recurrence `a (k + 1) ≤ 2 * a k + J + 1`.

## What this file establishes

**F1 — the obstruction is a theorem, not an artefact of one witness.**
`no_deleted_ladderPath_of_straddle_break` below shows that whenever the deleted walk's unique
straddling pin pair breaks pin compatibility at the REDUCED distance, no deleted ladder path
exists at all. The proof is one application of `pinCompat_of_ladderPath` to the candidate path
`g'`: any `g'` whose object walk is `delObj g a l` and whose countdown is `delCnt g a l` is
itself a ladder path, so its own pins must satisfy compatibility — and they are exactly the
positions the broken pair names. So the two clauses of
`exists_deleted_ladderPath_of_next_region_nxt` are not merely hard to discharge in this regime:
on a path with a saturated pair, the theorem's CONCLUSION is false, and no proof of either
clause can exist.

**F2 — a saturated pair is realized by a concrete ladder path in the regime.** `obs` below is a
two-state ladder path (`ClimbWitness.stepT`/`pendT`, cited and not redefined) which is pending
forever into the past at `z = 0` with countdown `2` and register `0` — so it satisfies the
consumer's gap `nxtAt + 2 ≤ cntAt` and Phase 4's `hnz`. Its structure above `z`:

| positions | state | countdown | register |
|-----------|-------|-----------|----------|
| `… 0 1 2` | pending | `2 1 0` (growing into the past) | `0 1 2` |
| `3` | idle | `0` | `2` |
| `4 5 6` | pending | `2 1 0` | `3 4 5` |
| `7` | idle | `0` | `6` |
| `8 … 14` | pending | `6 … 0` | `5 … 0` |
| `≥ 15` | idle | `0` | `0` |

The idle position `3` is the UNIQUE pin strictly below the block: every position at or below `0`
is pending, every position of `z`'s region is pending, and the idle run above it has length `1`.
The first region above `z`'s region starts at `4` with countdown `2`; the block `[4, 5)` lies
inside it and respects the object (`objAt obs 4 = objAt obs 5`, both pending). The pair of pins
of the DELETED walk is `(3, 6)`, and it is SATURATED on the original: the register climbs by one
per step from `2` at `3` to `6` at `7`, so pin compatibility on `obs` holds with equality,
`|cntAt obs 4 - cntAt obs 8| = |2 - 6| = 4 = |3 - 7|`.

Deleting the one position shortens that pair's distance from `4` to `3` while lowering the lower
pin's value by `1` (its region swallows the block) and leaving the upper pin's value at `6`. The
clause then asks for `|1 - 6| = 5 ≤ 3` and fails by exactly `2 * l`. `obs_deletion_refuted`
records the conclusion: no deleted ladder path exists for this path and this block.

**F3 — every block the pigeonhole could return inside that region fails the same way.**
`obs_no_admissible_block` collects the same refutation at all three admissible
`(a, l)` choices inside the region — `(4, 1)`, `(4, 2)` and `(5, 1)` — which exhaust the blocks
`[a, a + l)` lying in `[4, 6]` with `l ≤ cntAt obs a`. The deficit is `2 * l` in each case, never
zero, so no choice of block closes it.

## What it does NOT establish

This refutes ROUTE (d), at the pin layer. It does NOT refute `ForwardSlackWitnessed`, which is an
existential over paths: a saturated path may still realize each of its types via some OTHER path
carrying `HasForwardSlack`. `ForwardSlackWitnessed` therefore remains neither discharged nor
refuted, and stays a hypothesis a consumer must supply.

Nor does `obs` instantiate `ParamsOk`: its countdown at `z` is `2`, which no genuine
`Tc ≤ cntAt g z` admits. That conjunct is covered separately and at the arithmetic layer by
`specs/917_forward_slack_witnessed_discharge_or_refutation/evidence/phase-5-gate-measurement.lean`,
whose `Gate917.Avail` carries `Tc ≤ C` and `(K2)`/`(K3)`'s
`2 * tShort + tIdle + 2 ≤ Tc` among the available facts and still refutes both clauses — the
deficit is `l` for `hanch` and `2 * l` for `hstraddle` regardless of scale
(`Gate917.deficit_is_the_block_length`). The structural reason the thresholds cannot help:
`Adm pend q = {c | pend q = false → c = 0}` (`LadderModel.lean`) places NO upper bound on a
pending state's countdown, so a saturated register is admissible at every scale, and every
`ParamsOk` conjunct the thresholds enter is a LOWER bound on a parameter. `cascadeBound`'s
recurrence is the bound the saturated configuration ATTAINS with equality, so `(K2)`'s budget
describes the obstruction rather than dominating it.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary.ClimbWitness

/-! ### F1: the obstruction is a theorem about any broken straddling pair -/

/-- **NO DELETED LADDER PATH EXISTS ONCE THE STRADDLING PAIR BREAKS AT THE REDUCED DISTANCE.**
Any candidate `g'` whose object walk is `delObj g a l` and whose countdown is `delCnt g a l` is a
ladder path, so `pinCompat_of_ladderPath` binds ITS pins — which are exactly the positions the
broken pair names. Hence the conclusion of `exists_deleted_ladderPath_of_next_region_nxt` is
FALSE for such a `g` and block, and no proof of its `hanch` or `hstraddle` clause can exist. -/
theorem no_deleted_ladderPath_of_straddle_break
    {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    {g : ℤ → LadderState Q pend} {a : ℤ} {l : ℕ}
    (s v : ℤ) (hsv : s < v)
    (hs0 : pend (delObj g a l s) = false) (hs1 : pend (delObj g a l (s + 1)) = true)
    (hv0 : pend (delObj g a l v) = false) (hv1 : pend (delObj g a l (v + 1)) = true)
    (hbreak : (v - s).natAbs
      < ((delCnt g a l (s + 1) : ℤ) - (delCnt g a l (v + 1) : ℤ)).natAbs) :
    ¬ ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
        (∀ w, objAt g' w = delObj g a l w) ∧ (∀ w, cntAt g' w = delCnt g a l w) := by
  rintro ⟨g', hg', hobj, hcnt⟩
  have hpc := pinCompat_of_ladderPath g' hg' s v
    (by rw [hobj]; exact hs0) (by rw [hobj]; exact hs1)
    (by rw [hobj]; exact hv0) (by rw [hobj]; exact hv1)
  rw [hcnt, hcnt] at hpc
  omega

/-! ### F2: the saturated configuration, realized -/

/-- The obstruction path: pending forever into the past at `0` with countdown `2` and register
`0`, an idle position at `3`, a region of countdown `2` at `4`, an idle position at `7`, a region
of countdown `6` at `8`, and idle at every position from `15` on. The register climbs
by one per step from `2` at `3` to `6` at `7`, so the pin pair `(3, 7)` of the ORIGINAL is
saturated: `|cntAt obs 4 - cntAt obs 8| = 4 = |3 - 7|`. -/
def obsRaw (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ 2 then (true, (2 - v).toNat, (max 0 v).toNat)
  else if v = 3 then (false, 0, 2)
  else if v ≤ 6 then (true, (6 - v).toNat, (v - 1).toNat)
  else if v = 7 then (false, 0, 6)
  else if v ≤ 14 then (true, (14 - v).toNat, (13 - v).toNat)
  else (false, 0, 0)

theorem obsRaw_adm (v : ℤ) : (obsRaw v).2.1 ∈ Adm pendT (obsRaw v).1 := by
  intro h
  unfold obsRaw at *
  split_ifs at * <;> simp_all [pendT]

/-- The obstruction path as a ladder state function. -/
def obs (v : ℤ) : LadderState Bool pendT := ⟨obsRaw v, obsRaw_adm v⟩

theorem obs_isLadderPath : IsLadderPath stepT pendT obs := by
  intro u
  change Rlad stepT pendT u (obsRaw u) (obsRaw (u + 1))
  unfold Rlad Drift Count obsRaw stepT pendT
  split_ifs <;> simp_all <;> omega

/-- The path is pending at every position at or below `z = 0`: the regime's `hpast`. -/
theorem obs_pend_past : ∀ p : ℤ, p ≤ 0 → pendT (objAt obs p) = true := by
  intro p hp
  simp [objAt, obs, obsRaw, pendT, show p ≤ 2 by omega]

/-- The consumer's gap at `z = 0`, which also gives Phase 4's `hnz`. -/
theorem obs_gap : nxtAt obs 0 + 2 ≤ cntAt obs 0 := by
  simp [nxtAt, cntAt, obs, obsRaw]

/-- The block `[4, 5)` respects the object: the regime's `hrep` at `a = 4`, `l = 1`. -/
theorem obs_rep : objAt obs 4 = objAt obs (4 + ((1 : ℕ) : ℤ)) := by
  norm_num [objAt, obs, obsRaw]

/-- The block is non-empty and fits inside its region: the regime's `hcl` at `a = 4`, `l = 1`. -/
theorem obs_cl : (1 : ℕ) ≤ cntAt obs 4 := by
  norm_num [cntAt, obs, obsRaw]

/-- The block lies strictly above the end of `z`'s region: the regime's `hza`. -/
theorem obs_za : (0 : ℤ) + (cntAt obs 0 : ℤ) + 1 ≤ 4 := by
  norm_num [cntAt, obs, obsRaw]

/-- **THE DELETION HAS NO DELETED LADDER PATH AT THE BLOCK `[4, 5)`.** The pins of the deleted
walk are `3` and `6`; the deletion leaves the lower pin's position put while lowering its value
from `2` to `1` and leaves the upper pin's value at `6` while shortening its distance from `3` by
one. Compatibility then asks for `|1 - 6| = 5 ≤ |3 - 6| = 3` and fails by `2 * l = 2`. -/
theorem obs_deletion_refuted :
    ¬ ∃ g' : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g' ∧
        (∀ w, objAt g' w = delObj obs 4 1 w) ∧ (∀ w, cntAt g' w = delCnt obs 4 1 w) := by
  refine no_deleted_ladderPath_of_straddle_break 3 6 (by omega) ?_ ?_ ?_ ?_ ?_
  · rw [delObj_of_lt (3 : ℤ) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_ge ((3 : ℤ) + 1) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_ge (6 : ℤ) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_ge ((6 : ℤ) + 1) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delCnt_of_ge ((3 : ℤ) + 1) (by omega), delCnt_of_ge ((6 : ℤ) + 1) (by omega)]
    norm_num [cntAt, obs, obsRaw]

/-! ### F3: every block the pigeonhole could return inside that region fails the same way

The blocks `[a, a + l)` with `4 ≤ a`, `a + l ≤ 6` and `0 < l ≤ cntAt obs a` are exactly three:
`(4, 1)`, `(4, 2)` and `(5, 1)` — `cntAt obs 4 = 2` admits `l ∈ {1, 2}`, `cntAt obs 5 = 1` admits
`l = 1`, and `cntAt obs 6 = 0` admits no non-empty block at all. Each is refuted below, with a
deficit of exactly `2 * l`. -/

/-- The block `[4, 6)` also respects the object, and also fits its region. -/
theorem obs_rep_two : objAt obs 4 = objAt obs (4 + ((2 : ℕ) : ℤ)) := by
  norm_num [objAt, obs, obsRaw]

theorem obs_cl_two : (2 : ℕ) ≤ cntAt obs 4 := by
  norm_num [cntAt, obs, obsRaw]

/-- **THE DELETION HAS NO DELETED LADDER PATH AT THE BLOCK `[4, 6)` EITHER.** The pins of the
deleted walk are `3` and `5`; compatibility asks for `|0 - 6| = 6 ≤ |3 - 5| = 2` and fails by
`2 * l = 4`. -/
theorem obs_deletion_refuted_two :
    ¬ ∃ g' : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g' ∧
        (∀ w, objAt g' w = delObj obs 4 2 w) ∧ (∀ w, cntAt g' w = delCnt obs 4 2 w) := by
  refine no_deleted_ladderPath_of_straddle_break 3 5 (by omega) ?_ ?_ ?_ ?_ ?_
  · rw [delObj_of_lt (3 : ℤ) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_ge ((3 : ℤ) + 1) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_ge (5 : ℤ) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_ge ((5 : ℤ) + 1) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delCnt_of_ge ((3 : ℤ) + 1) (by omega), delCnt_of_ge ((5 : ℤ) + 1) (by omega)]
    norm_num [cntAt, obs, obsRaw]

/-- The block `[5, 6)` respects the object, and fits its region exactly. -/
theorem obs_rep_shift : objAt obs 5 = objAt obs (5 + ((1 : ℕ) : ℤ)) := by
  norm_num [objAt, obs, obsRaw]

theorem obs_cl_shift : (1 : ℕ) ≤ cntAt obs 5 := by
  norm_num [cntAt, obs, obsRaw]

/-- **THE DELETION HAS NO DELETED LADDER PATH AT THE BLOCK `[5, 6)` EITHER.** Here the lower pin
`3` sits strictly below the block, so `delCnt` reaches it through its `v < a` branch — its
region still swallows the block (`5 ≤ 4 + cntAt obs 4 = 6`), so its value drops by `l` all the
same. Compatibility asks for `|1 - 6| = 5 ≤ |3 - 6| = 3` and fails by `2 * l = 2`. -/
theorem obs_deletion_refuted_shift :
    ¬ ∃ g' : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g' ∧
        (∀ w, objAt g' w = delObj obs 5 1 w) ∧ (∀ w, cntAt g' w = delCnt obs 5 1 w) := by
  refine no_deleted_ladderPath_of_straddle_break 3 6 (by omega) ?_ ?_ ?_ ?_ ?_
  · rw [delObj_of_lt (3 : ℤ) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_lt ((3 : ℤ) + 1) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_ge (6 : ℤ) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delObj_of_ge ((6 : ℤ) + 1) (by omega)]; norm_num [objAt, obs, obsRaw, pendT]
  · rw [delCnt_of_lt ((3 : ℤ) + 1) (by omega), delCnt_of_ge ((6 : ℤ) + 1) (by omega)]
    norm_num [cntAt, obs, obsRaw]

/-- **THE VERDICT, as one statement.** No block the spaced type pigeonhole could return inside
the first region above `z`'s region admits the deletion on this path. Route (d) is refuted at the
pin layer: `hanch` and `hstraddle` are not dischargeable from `(K2)`'s budget in the forward
direction, and `ForwardSlackWitnessed` stays a hypothesis a consumer must supply. -/
theorem obs_no_admissible_block :
    (¬ ∃ g' : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g' ∧
        (∀ w, objAt g' w = delObj obs 4 1 w) ∧ (∀ w, cntAt g' w = delCnt obs 4 1 w)) ∧
    (¬ ∃ g' : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g' ∧
        (∀ w, objAt g' w = delObj obs 4 2 w) ∧ (∀ w, cntAt g' w = delCnt obs 4 2 w)) ∧
    (¬ ∃ g' : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g' ∧
        (∀ w, objAt g' w = delObj obs 5 1 w) ∧ (∀ w, cntAt g' w = delCnt obs 5 1 w)) :=
  ⟨obs_deletion_refuted, obs_deletion_refuted_two, obs_deletion_refuted_shift⟩


end FormalSystem.Metalogic.Decidability.RaySummary

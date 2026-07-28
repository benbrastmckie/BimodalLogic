# Phase 7.7 — Invariant preservation across `c5_backward_walk` (R3d-3)

**Status**: COMPLETED. Full `lake build` green, sorry-free, baseline unchanged.

## What landed

All changes are in `FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`,
confined to the backward-walk region. `git diff -U0` shows four hunks, all at line ≥ 1389; the
forward-walk region (ends at 1354) is byte-identical, as required.

Three new declarations on `C5BackwardWalkResult`:

1. **`guard_interval`** — `∀ w ∈ val.dom, witness < w → w < start → ξ ∈ val.f w`. The mirror of the
   forward field with the interval reversed to `(witness, start)`. This is the field carrying the
   walk's actual content.
2. **`guard_accum_preserved`** — the `NoGuardAccumulation` preservation statement. Verified
   **byte-identical** to the forward walk's field of the same name: both read
   `NoGuardAccumulation (↑χ.dom) χ.f G → NoGuardAccumulation (↑val.dom) val.f G`. No restatement,
   no weakening, no above-accumulation variant. `limitSetAbove` occurs zero times in the file.
3. **`C5BackwardWalkResult.no_guard_failure_above_witness`** — the consuming reading: no point of
   the result domain in `(witness, start)` carries `Formula.neg ξ`. Axioms: `propext`,
   `Classical.choice`, `Quot.sound` only.

## Three-case discharge

| Case | Discharge |
|---|---|
| Base (`pt = min dom`) | Vacuous by minimality of `pt`; the only new point is the witness itself. |
| Condition (i) recursion | Trichotomy on `w` vs the predecessor `x''`: below `x''` by the recursive instance; at `x''` by `conj_left_mcs` from the condition-(i) conjunction; above `x''` impossible (old points by adjacency of `(x'', pt)`, new points by `new_point_before`). |
| Split (midpoint) | Vacuous: the witness is the midpoint of the adjacent pair `(x'', pt)`, so `(witness, pt)` contains no old point (adjacency) and no new point (the midpoint is the only insertion and equals the witness). |

`guard_accum_preserved` is discharged in all three cases by
`noGuardAccumulation_of_finite (Finset.finite_toSet _) _ G` — free at every finite stage because
`Chronicle.dom` is a `Finset`. This is stated plainly in its docstring, exactly as on the forward
side. The field carries no stage-level content of its own; it exists to fix the form of the
preservation handle the limit step needs.

## Route taken in the split case: (a), and no forward/backward asymmetry

Route **(a), preservation as-is** — the same route the forward walk took. Burgess's midpoint
placement is unchanged. No `PointInsertion.lean` edit, no witness reuse, no placement rule added.
The placement discipline is therefore symmetric between the two walks, so the composition step has
nothing to reconcile on that account.

## Adversarial verification: the interval reversal is load-bearing

The plan's substitution table names the interval reversal as the place a mechanical transcription
goes wrong. This was **checked by machine**, not asserted.

- **Probe A** — the mechanical copy of the forward field, interval `(start, witness)`, **is
  provable on the backward side from `witness_lt` alone**, with no reference to any guard content.
  A mechanical transcription of the forward field would therefore have landed a **vacuous field**,
  which this phase's own prohibited list forbids.
- **Probe B** — the landed field, interval `(witness, start)`, admits no such contradiction proof.
  The probe fails with `r.witness_lt has type r.witness < start but is expected to have type
  start < r.witness`.

Together: the reversal is load-bearing, and the landed field is not vacuous. The non-vacuity also
shows up structurally — in the condition-(i) branch the predecessor `x''` lies strictly inside
`(witness, pt)`, so the field genuinely asserts `ξ ∈ f(x'')` there rather than quantifying over an
empty interval.

## Family-`Q` check at walk scope (backward mirror)

`no_guard_failure_above_witness` is the mirror of the forward check and passes as a landed theorem:
the interval a backward walk opens below an outstanding `snce` obligation is guard-failure free.
What it does **not** exclude is unchanged from the forward side — successive stages' intervals
squeezed toward a gap with failures accumulating in the complements. That remains the limit
step's obligation and is not settled here.

## Honesty charter compliance

Every new declaration carries the no-source statement. The only adapted-from citation used is
**ADAPTED-FROM Burgess 1982 I §2.10, printed pp.372-373** (the fresh-point witness placement whose
interval behaviour is being recorded). Burgess states no such property because his construction
never reaches a gap. No task-number citations appear in any deliverable file.

## Verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.CounterexampleElimination` | green, 1108 jobs |
| Full `lake build` | green, 1908 jobs |
| `sorry` introduced | 0 (file contains no `sorry`) |
| Live sorries outside `Boneyard/` | 1, at `WeakCanonical/Transfer.lean:1242` — the stated baseline, unchanged |
| Vacuous definitions introduced | 0 |
| New axioms | 0; new theorem uses only `propext`, `Classical.choice`, `Quot.sound` |
| Frozen files | `ChronicleTypes.lean`, `ChronicleToCountermodelBasic.lean`, `PointInsertion.lean`, `ChronicleConstruction.lean` all unmodified |
| Six frozen statements (Amendment 2 proviso) | unchanged — they live outside the only modified file |
| Forward-walk region | untouched; all diff hunks at line ≥ 1389 |

## Deviations

None. Every plan task was executed as written. The adversarial probe pair is an addition beyond
the plan's task list, not a substitution for any step.

## Consequence for the arc

Unchanged from what the previous two sub-phases flagged: the stage-level preservation is now
available on both walks, and the residual risk stays concentrated in the limit step. The
induction there cannot be a routine preserved-at-each-step argument — it must produce a bound
uniform in the stage, because the per-stage field is free by finiteness and contributes nothing
in the limit. The content that does transport is `guard_interval` on each walk.

# Sweep Evidence Report: Task #581

**Task**: 581 — Repair the four bi-lasso evidence probes against the FrameClass/TemporalOrder refactor
**Produced**: 2026-09-16 (repository hygiene sweep, not a research-phase dispatch)
**Status**: Pre-research evidence. A `/research` dispatch should build on this, not redo it.
**Effort**: Medium–Large (four `sorry`-free Lean files, ~30 distinct elaboration errors, all from one refactor)
**Dependencies**: None. Independent of every other sweep task.
**Sources/Inputs**:
- `specs/evidence/bi-lasso-decision-layer/*.lean` (5 files; 4 wired, 1 deferred)
- `scripts/check-evidence-probes.sh`
- `specs/reviews/review-2026-09-16.md`, Finding C1
- Commit `a6439fcae` ("todo: archive 3 completed tasks"), the archiving event

## Executive Summary

- **The path half of this problem is already fixed.** The sweep moved the five probe files from
  the gitignored `specs/archive/417_…/evidence/` back into version control at
  `specs/evidence/bi-lasso-decision-layer/`, repointed `check-evidence-probes.sh`, and recorded in
  that script's header why a probe must never live inside a task directory. Nothing in this task
  should re-litigate the location.
- **What remains is real Lean repair.** With the path resolved, all four wired probes now *load*
  and **none compiles**. This is the rot the guard exists to catch; it was simply invisible while
  the files were missing.
- **The drift has a single cause**: the `FrameClass` / `TemporalOrder` refactor. The probes were
  written against an API in which `FiniteFilteredTaskFrame`'s first argument was a `Type` and
  `TaskFrame.step` existed. Both changed.
- **The guard's own instruction governs this task.** `check-evidence-probes.sh` says, verbatim:
  *"Do NOT delete the probe or weaken its statements to make this pass: repair the citation
  drift, or — if the obstruction genuinely no longer holds — say so explicitly and revisit the
  decision the probe was holding in place."* That is the acceptance bar. A probe that is made to
  compile by weakening what it asserts is worse than one that fails loudly.

## What each probe holds in place

Reproduced from `check-evidence-probes.sh`'s WIRED table, because the repair must preserve each
statement's force, not merely its syntax:

| Probe | The decision it holds in place |
|---|---|
| `phase3-scan-bound-is-false` | No bound computed from the lasso's segment lengths alone can drive a semantic scan — this is why the layer enumerates annotations instead of evaluating |
| `phase7-filtered-frame-is-universal` | The filtered frame's one-step relation is universal, so it carries no dynamics — this is why the layer presents frames rather than filtering |
| `phase12-check-not-compositional` | The `imp` case admits no compositional reading — this is why `check`'s two existentials sit OUTSIDE any recursion on the formula |
| `phase10-origin-anchoring-obstruction` | No recurrence of the type at the point of interest need exist — this is what stops `check` being re-anchored at position 0. Load-bearing: the probe a future dispatch is most likely to try to contradict, since anchoring looks like a cleanup |

`spike-untl-unfolding-and-fwd-obstruction` is DEFERRED and must stay unwired: its subject is the
`FrameClass.Base` / `FrameClass.Discrete` mismatch that the frame-class uniformity work is
expected to change. It moved with the others and is skipped by the guard. Do not wire it as part
of this task.

## Measured drift

Run: `bash scripts/check-evidence-probes.sh` → `FAIL 4 of 4 wired probe(s) failed`.

### The two API changes that account for most errors

**1. `FiniteFilteredTaskFrame` no longer takes a `Type`.**

```
error: Application type mismatch: The argument
  ℤ
has type
  Type
but is expected to have type
  TemporalOrder
in the application
  @FiniteFilteredTaskFrame ℤ
```

Every `FiniteFilteredTaskFrame ℤ phi` in the probes needs the `TemporalOrder` value that now
stands where the carrier type used to. This single change accounts for all three `example`s in
`phase7-filtered-frame-is-universal.lean` and recurs in the other three files.

**2. `FormalSystem.Semantics.TaskFrame.step` no longer exists.**

```
error(lean.unknownIdentifier): Unknown constant `FormalSystem.Semantics.TaskFrame.step`
```

`phase7`'s Probe A and Probe B both `simp [TaskFrame.step, …]`. The replacement needs locating in
the current `Semantics/TaskFrame.lean`; a one-step relation still exists, under a different name
or as a derived form of `TaskRel` at duration 1.

### Per-file error inventory

| Probe | Errors | Shape |
|---|---|---|
| `phase3-scan-bound-is-false.lean` | 7 | 1 × "Function expected at" (line 90); 6 × `omega could not prove the goal` (lines 116, 117, 120 ×2, 152, 176) |
| `phase7-filtered-frame-is-universal.lean` | 8 | 7 × `TemporalOrder` application mismatch; 1 × unknown constant `TaskFrame.step`; 2 × unsolved goals downstream |
| `phase12-check-not-compositional.lean` | 7 | application mismatches at 25/70/84; `Not a definitional equality` at 32; type mismatches at 32/37 |
| `phase10-origin-anchoring-obstruction.lean` | 8 | application mismatch at 128/168; "Function expected at" 142; type mismatch 164; unsolved goals 181 |

The `omega` failures in `phase3` are almost certainly downstream of the "Function expected at"
error at line 90 — a probe whose earlier definitions fail to elaborate leaves `sorry`-typed
hypotheses that `omega` then cannot use. Fix line 90 first and re-measure before treating the six
`omega` goals as six separate problems.

### A warning worth noting during repair

`phase10`'s current failure output shows `sorryAx` in its `#print axioms` lines
(`truth_prev5_spike`, `type_at_origin_never_recurs`, `typeAt_origin_never_recurs` all depend on
`sorryAx`). That is an artifact of the file not elaborating — Lean fills failed proofs with
`sorryAx` — not evidence that the probe was ever written with a `sorry`. Confirm this after
repair: a green probe must show exactly `[propext, Classical.choice, Quot.sound]` (or a subset).

## Recommended approach

1. Repair `phase7-filtered-frame-is-universal.lean` first. It is 26 lines, has the cleanest error
   signature, and both of the two root API changes appear in it. Once it compiles, the `ℤ →
   TemporalOrder` substitution and the `TaskFrame.step` replacement are both known, and the other
   three become mostly mechanical.
2. Then `phase12`, `phase3`, `phase10` in that order (ascending size and entanglement).
3. After each file, re-run `bash scripts/check-evidence-probes.sh` rather than `lake env lean`
   directly, so the guard itself is what confirms the repair.
4. For any probe where the obstruction *genuinely no longer holds* under the new frame-class API:
   do not silently adjust it. Record the finding explicitly in the summary and flag that the
   decision it was holding in place needs revisiting. That is a legitimate outcome of this task
   and a more valuable one than a green run.

## Verification

- `bash scripts/check-evidence-probes.sh` exits 0 with 4 PASS, 1 SKIP (deferred).
- No probe's theorem statement is weakened. Diff every changed statement and justify each change
  as API-tracking, not as content change.
- Each repaired probe's `#print axioms` shows no `sorryAx`.
- `bash scripts/check-module-invariants.sh --no-build` still green (the probes sit under
  `specs/`, outside every walker, so this should be unaffected — confirm rather than assume).

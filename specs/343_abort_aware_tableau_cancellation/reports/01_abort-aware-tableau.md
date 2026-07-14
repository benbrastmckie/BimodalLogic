# Research Report: Abort-Aware Tableau Cancellation (Task 343)

**Task**: 343 — Make the tableau decision procedure abort-aware so cancelled
tasks stop instead of continuing as zombie threads.
**Date**: 2026-07-14
**Session**: sess_1784042369_262c14_343

## Executive Summary

The zombie-thread diagnosis in the task description is confirmed, with one
important correction: the cleanest fix is NOT to thread an `IO.Ref Bool`
through the existing pure `expandBranchWithFuel` (that would break four
proof-bearing theorems that `unfold`/`simp` the pure definition). Instead,
this codebase already has an established precedent — the task-277
`_tracedImpl` parallel-implementation pattern — for mirroring
`expandBranchWithFuel` in a monad while leaving the pure function and all
its proofs untouched. The recommended fix adds an IO mirror
(`expandBranchWithFuelCancellable`) that checks an `IO.Ref Bool` (plus
`IO.checkCanceled` as belt-and-braces) at each recursive step, wires it
into `labelFormulaImpl`'s timeout handler, and separately fixes a second,
previously undocumented unbounded computation: `extractCountermodelData`
re-runs the full tableau with `soundFuel φ` (up to 100000 fuel) on the
main thread after the timed task already finished with `adaptiveFuel ≤ 500`.

## 1. Current Implementation: Locations and Signatures

### 1.1 The pure tableau core

`Theories/Bimodal/Metalogic/Decidability/Saturation.lean:228`:

```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (applied : AppliedSet := {})
    (maxBranches : Nat := 50000)
    (branchesUsed : Nat := 0)
    : Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet))
```

- **Pure** function, `termination_by fuel` / `decreasing_by all_goals simp_wf`
  (Saturation.lean:284-285).
- Self-recursive on `.extended` (line 262) and on splits via a `foldl` over
  `branches.zip fuelAllocs` with fuel capped by
  `allocateFuelProportionally_le` (Saturation.lean:210).
- Already has two resource bounds: `fuel` and the task-298 global branch
  counter `branchesUsed >= maxBranches` (line 237). Neither is wall-clock
  aware, which is exactly why a cancelled task keeps burning CPU/memory
  until fuel or branch budget is exhausted.

Related pure functions in the same call chain:

- `saturateBlocked` — Saturation.lean:495, pure, `termination_by fuel`
  (line 529). Called by `buildTableau` on blocked-open branches.
- `buildTableau (φ : Formula) (fuel : Nat := 1000) (fc : FrameClass := .Base) : Option ExpandedTableau`
  — Saturation.lean:555. Entry point; calls `expandBranchWithFuel` (line 558)
  then possibly `saturateBlocked` (line 568).
- `expandBranchesWithFuel` — Saturation.lean:455 (list version; used elsewhere,
  not on the dataset hot path).
- `soundFuel` — Saturation.lean:602: `min (n * 2^n) 100000` where
  `n = (subformulaClosure φ).card`.

### 1.2 The decision procedure

`Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`:

- `decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000) (fc : FrameClass := .Base) : DecisionResult φ`
  — line 122. Pure. Fast paths (`tryAxiomProof`, `buildCompositionalProof`,
  `bounded_search_with_proof`) then `buildTableau φ_n tableauFuel fc` (line 145).
- `decideAuto` — line 179 (uses `soundFuel φ`). Used by
  `TableauBridge.handleCountermodel` (TableauBridge.lean:503).
- `decideAutoAdaptive (φ : Formula) (fc : FrameClass := .Base) (fuel : Nat := 500) : DecisionResult φ × String`
  — line 198. Pure. This is what the dataset generator's timed task runs.

### 1.3 How `labelFormulaImpl` / `IO.cancel` currently work

`Theories/Bimodal/Automation/DatasetGenerator.lean:1286`:

```lean
def labelFormulaImpl (φ : Formula) (fc : FrameClass := .Base)
    (wallclockTimeoutMs : Nat := 1000) : IO LabeledFormula := do
```

Phase 2 (lines 1340-1397), the relevant portion:

```lean
let adaptiveFuel := min 500 (150 + φ.complexity * 30)   -- line 1352
let task ← IO.asTask (prio := .dedicated) do            -- line 1357
  return decideAutoAdaptive φ fc adaptiveFuel           -- line 1358 (PURE body)
...
repeat do                                               -- 1ms poll loop, line 1362
  let done ← IO.hasFinished task
  ...
if timedOut then
  IO.cancel task                                        -- line 1377
  return { ... label := .timeout ... }
```

**Root cause confirmed**: `IO.cancel : Task α → BaseIO Unit` only sets the
task's cooperative cancellation flag; the flag is observed via
`IO.checkCanceled : BaseIO Bool` (both signatures verified against the
project toolchain, v4.27.0-rc1, via `lean_run_code`). The task body at line
1358 is a single `return <pure computation>` — evaluation of
`decideAutoAdaptive` never re-enters IO, so there is no point at which the
runtime can observe the flag. The dedicated thread runs the full tableau to
fuel/branch exhaustion after "cancellation". With one dedicated thread per
formula (and per-chunk tasks in the parallel path, DatasetGenerator.lean:1678),
timed-out c7 formulas accumulate concurrent zombie expansions — the OOM.

Callers of `labelFormulaImpl`: `labelFormula` (DatasetGenerator.lean:1570,
dispatch at 1575-1585) and `labelFormulaWithCache` (line 1597), which is used
by both the sequential loop (line 1643) and the chunked parallel path
(lines 1672-1687, one `IO.asTask` per chunk).

### 1.4 Second unbounded computation: `extractCountermodelData`

`DatasetGenerator.lean:396`:

```lean
def extractCountermodelData (φ : Formula) :
    Option EnrichedCountermodel × Option SemanticCountermodelSummary :=
  let fuel := soundFuel φ
  match buildTableau φ fuel with ...
```

Called from the **pure** `mkInvalidLabel` (DatasetGenerator.lean:411, use at
line 415), which is invoked from `labelFormulaImpl` at lines 1427 and 1488 —
i.e. **on the main thread, after the timed task already finished**. It re-runs
the entire tableau with `soundFuel φ` (up to 100000) even though the deciding
run used `adaptiveFuel ≤ 500`. For a c7 formula that decided `.invalid` just
inside the deadline, this re-run is outside any wall-clock control and can be
orders of magnitude more expensive than the timed decision itself. This is a
second, independent contributor to memory/latency blowups and is why the task
description asks for abort-awareness here too.

Also called from `TableauBridge.handleCountermodel`
(Theories/Bimodal/Automation/TableauBridge.lean:508), likewise unbounded.

## 2. Threading Strategy: Pure vs IO — Analysis

### 2.1 Why NOT modify `expandBranchWithFuel` in place

Adding an `IO.Ref Bool` parameter forces the function into `IO` (an
`ST.Ref`/`IO.Ref` can only be read monadically; there is no safe pure read).
That breaks the proof surface that reasons about the pure definition by
unfolding it:

- `expandBranchWithFuel_sound` — Saturation.lean:1141, proof does
  `simp [expandBranchWithFuel]` (line 1153) and
  `unfold expandBranchWithFuel` (line 1155).
- Two auxiliary `tryBranch` preservation lemmas — Saturation.lean:1064 and
  1110 — both match on `expandBranchWithFuel pair.1 (min pair.2 fuel) ...`.
- `invalid_of_expandBranchWithFuel_open` (Saturation.lean:1196-1202) —
  hypothesis `expandBranchWithFuel b (soundFuel φ) = some (.inr ...)`.
- Downstream: `buildTableau` equations feed `decide`'s correctness usage and
  the trace-certificate layer (TraceCertificate.lean:13 documents that
  tracing was deliberately kept as a pure `StateM` layer for this reason).

Rewriting these against an IO-valued function is not practical: propositional
reasoning about `IO` computations has no useful unfolding in this codebase,
and the zero-debt policy forbids weakening or `sorry`-deferring these proofs.

A "fuel-embedded abort flag" pure alternative was also evaluated: since the
computation is a single pure closure, no pure encoding can observe an
external wall-clock event; chunked-fuel resumption would require adding a
resumption state to the return type (invasive, breaks the same proofs).
An `unsafeBaseIO`-style pure read of a ref was rejected on principle (unsafe,
unverifiable).

### 2.2 Recommended: cancellable IO mirror (task-277 precedent)

The codebase already contains a full worked precedent:
`expandBranchWithFuel_tracedImpl` (Saturation.lean:368) mirrors the pure
function in `StateM` (`TraceM`), reproduces the exact recursion shape
including the split `foldl` (as a `for` loop with a mutable `acc`,
lines 420-430), and closes termination with the **same**
`termination_by fuel` / `decreasing_by all_goals simp_wf` (lines 431-432).
The header comment (lines 290-296) states explicitly that the parallel
implementation exists "so that the existing proofs remain valid".

The fix is the same move with `IO` instead of `StateM`:

```lean
/-- Cancellable mirror of `expandBranchWithFuel` (task 343).
    Checks the abort ref (and the task cancellation flag) at each
    recursive entry; returns `none` on abort, which upstream maps to
    `.timeout` — never to `.valid`/`.invalid`. -/
def expandBranchWithFuelCancellable (abortRef : IO.Ref Bool)
    (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (applied : AppliedSet := {})
    (maxBranches : Nat := 50000)
    (branchesUsed : Nat := 0)
    : IO (Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet))) := do
  if (← abortRef.get) || (← IO.checkCanceled) then return none
  ...  -- body mirrors the pure function line-for-line
termination_by fuel
decreasing_by all_goals simp_wf
```

Key design points:

1. **Abort signal = `IO.Ref Bool` primary, `IO.checkCanceled` secondary.**
   - The `IO.Ref` matches the task description, is explicitly testable, and
     — critically — also works on the **main thread** for the
     `extractCountermodelData` leg, where `IO.checkCanceled` would inspect
     the main task's (never-set) flag.
   - `IO.checkCanceled` costs nothing extra and makes the existing
     `IO.cancel task` call at DatasetGenerator.lean:1377 effective on its
     own inside the spawned task, even if a future call site forgets to wire
     a ref. Keep `IO.cancel` as belt-and-braces.
2. **Abort maps to `none`** (same channel as fuel exhaustion), so
   `decide`-level plumbing maps it to `.timeout`. An aborted run can never
   produce a `.valid`/`.invalid` label — label soundness is preserved by
   construction.
3. **Check granularity**: one `abortRef.get` per expansion step. `IO.Ref`
   reads are plain pointer reads (single writer, no contention);
   `findClosure`/`expandOnceWithApplied` dominate per-step cost, so per-step
   checking is negligible overhead. If profiling ever disagrees, gate the
   check on `branchesUsed % 64 == 0` — but start simple.
4. **Termination**: identical `termination_by fuel` measure; monadic
   recursion with `for`-loop splits is already proven workable by
   `_tracedImpl` (compiles today with the same `decreasing_by`).
5. **Drift risk** (mirror vs pure) is the same accepted risk as
   `_tracedImpl`; mitigate with cross-referencing comments on both
   definitions and a small `#eval`/test-executable spot-check comparing
   `expandBranchWithFuelCancellable` (abort never set) against
   `expandBranchWithFuel` on sample formulas.

### 2.3 Functions that need cancellable mirrors

Minimal set on the dataset hot path (mirror only what the timed task runs):

| Pure function | Location | Cancellable mirror |
|---|---|---|
| `expandBranchWithFuel` | Saturation.lean:228 | `expandBranchWithFuelCancellable` (new) |
| `saturateBlocked` | Saturation.lean:495 | `saturateBlockedCancellable` (new) |
| `buildTableau` | Saturation.lean:555 | `buildTableauCancellable` (new) |
| `decide` | DecisionProcedure.lean:122 | `decideCancellable` (new; reuses the pure fast paths `tryAxiomProof`, `buildCompositionalProof`, `bounded_search_with_proof` unchanged — they are cheap and bounded — and calls `buildTableauCancellable` for the expensive leg) |
| `decideAutoAdaptive` | DecisionProcedure.lean:198 | `decideAutoAdaptiveCancellable` (new, `IO (DecisionResult φ × String)`) |

`expandBranchesWithFuel`, `decideAuto`, `decideBatch`, and the traced variants
are NOT on the timed-task path and need no mirrors.

Suggested placement: a new file
`Theories/Bimodal/Metalogic/Decidability/CancellableExpansion.lean`
(imports `Saturation` and `DecisionProcedure`), keeping the proof-bearing
files untouched. Alternatively append to the existing files; a new file makes
the "runtime-only, no proof obligations" boundary explicit.

## 3. Wiring in `labelFormulaImpl`

At DatasetGenerator.lean:1346-1377, the change is small:

```lean
let abortRef ← IO.mkRef false                     -- NEW
let task ← IO.asTask (prio := .dedicated) do
  decideAutoAdaptiveCancellable abortRef φ fc adaptiveFuel   -- was: return decideAutoAdaptive ...
...
if timedOut then
  abortRef.set true                               -- NEW: signal abort
  IO.cancel task                                  -- keep: sets task flag too
```

`IO.mkRef : α → BaseIO (IO.Ref α)` and `ST.Ref.get`/`.set` verified present.
The chunked parallel path (line 1678) needs no change: it calls
`labelFormulaWithCache → labelFormulaImpl`, which now owns per-formula abort
refs internally.

## 4. Fixing `extractCountermodelData` / `mkInvalidLabel`

Two independent problems, two fixes:

1. **Wrong fuel (pure fix, no abort machinery needed for the dataset path).**
   `decide` found the open branch at `tableauFuel = adaptiveFuel ≤ 500`;
   re-running `buildTableau` at that same fuel deterministically reproduces
   it. So `extractCountermodelData` should take a `fuel : Nat` parameter
   (default `soundFuel φ` for backward compatibility) and `labelFormulaImpl`
   should pass `adaptiveFuel` through `mkInvalidLabel`. This alone removes
   the unbounded main-thread re-run from the dataset path.
2. **Abort-awareness (for full task compliance).** Add a cancellable variant
   `extractCountermodelDataCancellable (abortRef : IO.Ref Bool) (φ : Formula) (fuel : Nat) : IO (...)`
   built on `buildTableauCancellable`, and make `mkInvalidLabel` either take
   the extraction result as a parameter (computed abort-aware in
   `labelFormulaImpl`, which is already `IO`) or become `IO` itself. The
   parameter-passing variant is less invasive: `mkInvalidLabel` stays pure
   and just receives `(ecm, scmSummary)`.

`TableauBridge.handleCountermodel` (TableauBridge.lean:501-522) is already
`IO` and can adopt the cancellable variant (or at minimum the fuel-bounded
one) in the same pass; it currently calls `decideAuto` at `soundFuel` and
then `extractCountermodelData` at `soundFuel` again.

## 5. Termination-Proof Impact

- **Zero impact on existing proofs**: `expandBranchWithFuel`,
  `saturateBlocked`, `buildTableau`, `decide` and all four
  termination/soundness proofs (`allocateFuelProportionally_le`,
  `expandBranchWithFuel_sound` + two `tryBranch` helpers,
  `invalid_of_expandBranchWithFuel_open`) are untouched.
- **New obligations**: each mirror needs `termination_by fuel` with
  `decreasing_by all_goals simp_wf` — mechanically identical to the goals
  already discharged for `expandBranchWithFuel_tracedImpl` (Saturation.lean:
  431-432). The abort check is a leading `if` that does not affect the
  measure. `saturateBlockedCancellable` likewise reuses `termination_by fuel`
  (Saturation.lean:529). No new axioms, no `sorry`, no `partial def` needed.
- **No soundness theorems required for the mirrors**: they only feed dataset
  labels/JSON output; the abort-maps-to-`none`/-`.timeout` convention keeps
  labels conservative by construction. (An optional equivalence theorem
  "mirror with abort constantly false ≡ pure function" is possible but would
  require reasoning through `IO` — recommend the runtime spot-check instead.)

## 6. Phased Implementation Approach

1. **Phase 1 — Cancellable expansion core** (~150-220 lines).
   New file `Theories/Bimodal/Metalogic/Decidability/CancellableExpansion.lean`
   with `expandBranchWithFuelCancellable`, `saturateBlockedCancellable`,
   `buildTableauCancellable`, mirroring the pure bodies line-for-line
   (`_tracedImpl` as the structural template, `for`-loop for the split fold).
   Verify: `lake build Theories.Bimodal.Metalogic.Decidability.CancellableExpansion`
   (termination goals close with `simp_wf`).
2. **Phase 2 — Cancellable decision wrappers** (~60-90 lines).
   `decideCancellable`, `decideAutoAdaptiveCancellable` (same file or
   `DecisionProcedure.lean`), reusing the pure fast paths. Abort → `.timeout`.
3. **Phase 3 — Wire into `labelFormulaImpl`** (~10 lines changed at
   DatasetGenerator.lean:1346-1377): `IO.mkRef false`, run
   `decideAutoAdaptiveCancellable abortRef` in the task body,
   `abortRef.set true` before `IO.cancel` on the timeout branch.
4. **Phase 4 — Bounded, abort-aware countermodel extraction** (~40-60 lines):
   fuel parameter on `extractCountermodelData`; abort-aware variant; pass
   `(ecm, scmSummary)` into `mkInvalidLabel` (or pass fuel through); update
   the two call sites in `labelFormulaImpl` (lines 1427, 1488) and
   `TableauBridge.handleCountermodel` (TableauBridge.lean:508).
5. **Phase 5 — Verification**: full `lake build`; spot-check mirror/pure
   agreement on a small formula set; smoke-run the dataset generator on a
   c7 batch with a short timeout and confirm (a) timeouts return promptly,
   (b) resident memory stays flat after timeouts (no zombie accumulation).

## 7. Tactic Survey Results

Not applicable in the usual sense — this task is program/runtime engineering,
not theorem proving. The only new proof obligations are the mirrors'
termination goals, for which the survey is:

| Goal | Tactic | Result | Notes |
|---|---|---|---|
| `termination_by fuel` decreasing goals (IO mirror) | `simp_wf` (via `decreasing_by all_goals simp_wf`) | expected success | identical goals already discharged at Saturation.lean:285 and :432 |
| abort-check `if` interaction with measure | none needed | n/a | leading `if` in `do` does not enter the measure |

API verification (toolchain v4.27.0-rc1, via `lean_run_code`):
`IO.checkCanceled : BaseIO Bool`; `IO.cancel : Task α → BaseIO Unit`;
`IO.asTask : IO α → Task.Priority → BaseIO (Task (Except IO.Error α))`;
`IO.mkRef : α → BaseIO (IO.Ref α)`; `ST.Ref.get` liftable into `IO`.

## 8. Risks and Open Points

- **Mirror drift**: same accepted risk as `_tracedImpl`; mitigated by
  cross-linking comments + spot-check test (Phase 5).
- **`IO.sleep 1` poll loop** (DatasetGenerator.lean:1362) is unchanged; it is
  not the leak — the leak is the non-observing task body.
- **`decideAuto`-based paths** (TableauBridge `handleDecide`/`handleCountermodel`)
  run at `soundFuel` synchronously with no timeout at all; Phase 4 bounds the
  countermodel leg, but a full timeout story for the bridge is out of scope
  (worth a follow-up task if the bridge is used on c7+ inputs).
- The chunk-level tasks (DatasetGenerator.lean:1678) are never cancelled by
  design (the driver waits for all chunks); per-formula abort inside
  `labelFormulaImpl` is sufficient.

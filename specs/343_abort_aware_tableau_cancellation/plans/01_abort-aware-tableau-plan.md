# Implementation Plan: Abort-Aware Tableau Cancellation

- **Task**: 343 - Make the tableau decision procedure abort-aware so cancelled tasks stop instead of continuing as zombie threads
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/343_abort_aware_tableau_cancellation/reports/01_abort-aware-tableau.md
- **Artifacts**: plans/01_abort-aware-tableau-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`IO.cancel task` in `labelFormulaImpl` is cooperative: it only sets the task's cancellation
flag, but the timed task body is a single `return <pure computation>` that never re-enters IO,
so the flag is never observed. Cancelled tableau expansions run to fuel/branch exhaustion as
zombie threads, and with one dedicated thread per c7 formula they accumulate into an OOM. This
plan implements the research-recommended fix: **cancellable IO mirrors** of the pure tableau
core (`expandBranchWithFuel` -> `saturateBlocked` -> `buildTableau` -> `decide` ->
`decideAutoAdaptive`) following the established task-277 `_tracedImpl` parallel-implementation
precedent, so the pure functions and all four proof-bearing theorems remain untouched. Each
mirror checks an `IO.Ref Bool` abort flag (plus `IO.checkCanceled` as belt-and-braces) at every
recursive step and maps abort to `none` -> `.timeout`. The plan also fixes a second, independent
unbounded computation the research uncovered: `extractCountermodelData` re-running `buildTableau`
at `soundFuel` (up to 100000) on the main thread after the timed task already decided at
`adaptiveFuel <= 500`. Definition of done: full `lake build` green, a spot-check confirming the
mirror matches the pure function when abort is never set, and a c7 smoke run where timeouts
return promptly with flat resident memory.

### Research Integration

The plan follows the report's Section 6 five-phase decomposition directly. Key integrated
findings:
- **Do NOT modify `expandBranchWithFuel` in place** (report Section 2.1): threading an
  `IO.Ref Bool` would force it into `IO` and break `expandBranchWithFuel_sound`
  (Saturation.lean:1141), two `tryBranch` helpers (Saturation.lean:1064, 1110), and
  `invalid_of_expandBranchWithFuel_open` (Saturation.lean:1196), all of which `unfold`/`simp`
  the pure definition. The zero-debt policy forbids weakening these.
- **Mirror pattern is proven** (report Section 2.2): `expandBranchWithFuel_tracedImpl`
  (Saturation.lean:368) already mirrors the pure function in `StateM`, reproducing the split
  `foldl` as a `for` loop and closing termination with the identical
  `termination_by fuel` / `decreasing_by all_goals simp_wf`. The IO mirror is the same move.
- **Abort maps to `none`** (report Section 2.2 point 2): same channel as fuel exhaustion, so
  `decide`-level plumbing maps it to `.timeout`; an aborted run can never yield `.valid`/
  `.invalid`. Label soundness is preserved by construction — no soundness theorems are needed
  for the mirrors.
- **`IO.Ref Bool` is primary, `IO.checkCanceled` secondary** (report Section 2.2 point 1): the
  ref works on the main thread for the `extractCountermodelData` leg where `IO.checkCanceled`
  would inspect the never-set main-task flag.
- **API verified against toolchain v4.27.0-rc1** (report Section 7): `IO.checkCanceled : BaseIO
  Bool`, `IO.cancel : Task α → BaseIO Unit`, `IO.mkRef : α → BaseIO (IO.Ref α)`, `ST.Ref.get`/
  `.set` liftable into IO.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted (roadmap_flag not set). This task advances the dataset-generation
stability / c7 OOM remediation line of work.

## Goals & Non-Goals

**Goals**:
- Cancelled tableau tasks stop promptly instead of running to fuel/branch exhaustion.
- The pure tableau core and all four existing termination/soundness proofs remain byte-for-byte
  untouched (zero proof debt, no new `sorry`, no `partial def`, no new axioms).
- The main-thread `extractCountermodelData` re-run is fuel-bounded (and optionally abort-aware),
  removing the second unbounded computation.
- Every phase ends at a green `lake build`.

**Non-Goals**:
- No equivalence theorem "mirror with abort-false ≡ pure function" (report Section 5 recommends a
  runtime spot-check instead; propositional IO reasoning is not practical here).
- No full timeout story for `TableauBridge.handleDecide`/`handleCountermodel` beyond bounding the
  countermodel leg (report Section 8 flags this as a possible follow-up task).
- No changes to the `IO.sleep 1` poll loop (DatasetGenerator.lean:1362) — it is not the leak.
- No mirrors for `expandBranchesWithFuel`, `decideAuto`, `decideBatch`, or the traced variants
  (not on the timed-task hot path).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mirror drift from the pure function (transcription error) | M | M | Cross-linking comments on both definitions; Phase 5 `#eval` spot-check comparing mirror (abort never set) against pure on sample formulas; mirror the `_tracedImpl` body line-for-line |
| IO monadic recursion fails `termination_by fuel` / `simp_wf` | M | L | `_tracedImpl` already discharges the identical goals (Saturation.lean:431-432); leading abort-check `if` does not enter the measure; keep the exact `termination_by fuel` / `decreasing_by all_goals simp_wf` |
| Editing `labelFormulaImpl` breaks the chunked parallel path | M | L | Per-formula abort ref is owned internally by `labelFormulaImpl`; chunk tasks (line 1678) call it unchanged (report Section 3) |
| `mkInvalidLabel` refactor cascades through pure callers | M | L | Prefer the less-invasive parameter-passing variant: `mkInvalidLabel` stays pure and receives `(ecm, scmSummary)` computed abort-aware in the already-IO `labelFormulaImpl` (report Section 4 point 2) |
| Full `lake build` reveals downstream breakage from new file imports | M | L | New file `CancellableExpansion.lean` only imports `Saturation`/`DecisionProcedure` and is imported additively; Phase 5 runs the full build |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 1, 3 |
| 5 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: the mirrors
build bottom-up on the call chain, and Phases 3-4 both edit `labelFormulaImpl` so they must not
run concurrently.

### Phase 1: Cancellable expansion core [COMPLETED]

**Goal**: Create the new runtime-only module with IO mirrors of the three pure expansion
functions, mapping abort to `none`, with termination discharged exactly as `_tracedImpl`.

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/Decidability/CancellableExpansion.lean` importing
  `Bimodal.Metalogic.Decidability.Saturation`. *(deviation: altered — module prefix is
  `Bimodal.` not `Theories.Bimodal.`; also imports `DecisionProcedure` up front for Phase 2)*
- [x] Implement `expandBranchWithFuelCancellable (abortRef : IO.Ref Bool) (b : Branch) (fuel : Nat) ...`
  returning `IO (Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet)))`, mirroring the
  pure body at Saturation.lean:228 line-for-line, using `_tracedImpl` (Saturation.lean:368) as
  the structural template (split `foldl` -> `for` loop with mutable `acc`).
- [x] Add the leading abort check as the first statement:
  `if (← abortRef.get) || (← IO.checkCanceled) then return none`.
- [x] Implement `saturateBlockedCancellable` mirroring `saturateBlocked` (Saturation.lean:495)
  with the same abort check and `termination_by fuel`.
- [x] Implement `buildTableauCancellable` mirroring `buildTableau` (Saturation.lean:555),
  calling the two cancellable helpers.
- [x] Close termination on each with `termination_by fuel` / `decreasing_by all_goals simp_wf`.
- [x] Add cross-referencing doc-comments on both the pure and cancellable definitions noting the
  mirror relationship and drift risk (task 343). *(deviation: altered — also widened
  `registerEventualities`/`fulfillEventualities` in Saturation.lean from `private` to public,
  a visibility-only change with zero proof/semantic impact, so the mirror can thread the
  tracker update)*

**Timing**: ~1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CancellableExpansion.lean` - new file (~150-220 lines)
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - doc-comment cross-links only (no
  code/proof changes)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Decidability.CancellableExpansion` succeeds.
- No new `sorry`/`partial def`/axioms; termination goals close with `simp_wf`.
- Existing Saturation proofs remain unmodified (only comments added).

---

### Phase 2: Cancellable decision wrappers [COMPLETED]

**Goal**: Wrap the cancellable tableau core into decision-level entry points that reuse the pure
fast paths and map abort to `.timeout`.

**Tasks**:
- [x] Implement `decideCancellable (abortRef : IO.Ref Bool) (φ : Formula) (searchDepth tableauFuel : Nat) (fc : FrameClass) : IO (DecisionResult φ)`
  reusing the pure fast paths (`tryAxiomProof`, `buildCompositionalProof`,
  `bounded_search_with_proof` — cheap and bounded, unchanged) and calling
  `buildTableauCancellable` for the expensive leg (mirrors `decide`, DecisionProcedure.lean:122).
- [x] Implement `decideAutoAdaptiveCancellable (abortRef : IO.Ref Bool) (φ : Formula) (fc : FrameClass) (fuel : Nat) : IO (DecisionResult φ × String)`
  mirroring `decideAutoAdaptive` (DecisionProcedure.lean:198).
- [x] Ensure an aborted (`none`) tableau result maps to a `.timeout`/unknown `DecisionResult`,
  never `.valid`/`.invalid`.
- [x] Place in `CancellableExpansion.lean` (add `import ... DecisionProcedure`) or append to
  `DecisionProcedure.lean`; prefer the new file to keep the proof-bearing file untouched.
  *(DecisionProcedure import already added in Phase 1)*

**Timing**: ~1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CancellableExpansion.lean` - add wrappers (~60-90
  lines); add `DecisionProcedure` import

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Decidability.CancellableExpansion` succeeds.
- Abort path type-checks as mapping to `.timeout`.

---

### Phase 3: Wire cancellable decision into labelFormulaImpl [COMPLETED]

**Goal**: Replace the non-observing pure task body with the cancellable variant and signal the
abort ref on the timeout branch.

**Tasks**:
- [x] At DatasetGenerator.lean:~1346, add `let abortRef ← IO.mkRef false` before spawning the task.
- [x] Change the task body (line ~1358) from `return decideAutoAdaptive φ fc adaptiveFuel` to
  `decideAutoAdaptiveCancellable abortRef φ fc adaptiveFuel`.
- [x] On the timeout branch (line ~1377), add `abortRef.set true` immediately before the existing
  `IO.cancel task` (keep `IO.cancel` as belt-and-braces).
- [x] Add the `CancellableExpansion` import to DatasetGenerator.lean.
- [x] Confirm the chunked parallel path (line ~1678) needs no change (it calls
  `labelFormulaWithCache -> labelFormulaImpl`, which now owns the ref internally).
  *(confirmed: chunk tasks call labelFormulaWithCache → labelFormulaImpl unchanged)*

**Timing**: ~0.5 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - ~10 changed lines at 1346-1377 + import

**Verification**:
- `lake build Theories.Bimodal.Automation.DatasetGenerator` succeeds.
- Task body is now an IO computation that re-enters IO at each expansion step.

---

### Phase 4: Bounded, abort-aware countermodel extraction [NOT STARTED]

**Goal**: Remove the unbounded main-thread `extractCountermodelData` re-run and make its
extraction abort-aware, updating all call sites.

**Tasks**:
- [ ] Add a `fuel : Nat` parameter to `extractCountermodelData` (DatasetGenerator.lean:396) with
  default `soundFuel φ` for backward compatibility; use it in the `buildTableau φ fuel` call.
- [ ] Add `extractCountermodelDataCancellable (abortRef : IO.Ref Bool) (φ : Formula) (fuel : Nat) : IO (...)`
  built on `buildTableauCancellable`.
- [ ] In `labelFormulaImpl`, compute the extraction abort-aware (it is already IO) and pass
  `(ecm, scmSummary)` into `mkInvalidLabel` (keep `mkInvalidLabel` pure — the less-invasive
  parameter-passing variant), threading `adaptiveFuel` so the re-run matches the deciding fuel.
- [ ] Update the two `mkInvalidLabel` call sites in `labelFormulaImpl` (lines ~1427, ~1488).
- [ ] Update `TableauBridge.handleCountermodel` (TableauBridge.lean:508, already IO) to use the
  fuel-bounded (and/or abort-aware) variant instead of `extractCountermodelData` at `soundFuel`.

**Timing**: ~1 hour

**Depends on**: 1, 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - `extractCountermodelData` signature,
  cancellable variant, `mkInvalidLabel` call sites (~40-60 lines)
- `Theories/Bimodal/Automation/TableauBridge.lean` - `handleCountermodel` uses bounded variant

**Verification**:
- `lake build Theories.Bimodal.Automation.DatasetGenerator` and
  `lake build Theories.Bimodal.Automation.TableauBridge` succeed.
- `mkInvalidLabel` remains pure; no unbounded `soundFuel` re-run remains on the dataset path.

---

### Phase 5: Full build, mirror spot-check, and c7 smoke run [NOT STARTED]

**Goal**: Verify the whole change end-to-end: green full build, mirror/pure agreement, and
prompt-cancellation behavior with flat memory.

**Tasks**:
- [ ] Run a full `lake build` and confirm zero errors and no new warnings/sorries.
- [ ] Add a small `#eval`/test-executable spot-check comparing
  `buildTableauCancellable` (abort ref never set) against `buildTableau` on a handful of sample
  formulas; confirm identical results.
- [ ] Smoke-run the dataset generator on a c7 batch with a short wallclock timeout; confirm
  (a) timeouts return promptly and (b) resident memory stays flat after timeouts (no zombie
  accumulation).
- [ ] Record the spot-check and smoke-run observations in the implementation summary.

**Timing**: ~1 hour

**Depends on**: 1, 2, 3, 4

**Files to modify**:
- `Tests/BimodalTest/` - optional spot-check test (if added as a test rather than `#eval`)

**Verification**:
- Full `lake build` green.
- Spot-check shows mirror == pure on the sample set.
- c7 smoke run: prompt timeout return, flat resident memory.

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Decidability.CancellableExpansion` (Phases 1-2).
- [ ] `lake build Theories.Bimodal.Automation.DatasetGenerator` (Phases 3-4).
- [ ] `lake build Theories.Bimodal.Automation.TableauBridge` (Phase 4).
- [ ] Full `lake build` green (Phase 5).
- [ ] Existing proofs unchanged: `expandBranchWithFuel_sound`, the two `tryBranch` helpers,
  `invalid_of_expandBranchWithFuel_open`, `allocateFuelProportionally_le` compile untouched.
- [ ] No new `sorry`, `partial def`, or axioms introduced by the mirrors.
- [ ] Mirror/pure spot-check agreement on sample formulas.
- [ ] c7 smoke run: prompt cancellation + flat memory.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Decidability/CancellableExpansion.lean` (new: mirrors + wrappers)
- Modified `Theories/Bimodal/Automation/DatasetGenerator.lean` (wiring + bounded extraction)
- Modified `Theories/Bimodal/Automation/TableauBridge.lean` (bounded countermodel leg)
- Doc-comment cross-links in `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`
- Optional spot-check test under `Tests/BimodalTest/`
- `specs/343_abort_aware_tableau_cancellation/plans/01_abort-aware-tableau-plan.md` (this file)
- `specs/343_abort_aware_tableau_cancellation/summaries/01_abort-aware-tableau-summary.md`
  (on implementation completion)

## Rollback/Contingency

- The change is additive: `CancellableExpansion.lean` is a new file, and the pure functions/
  proofs are untouched. Reverting is `git revert` of the wiring commits plus deleting the new
  file — the pure decision path (`decideAutoAdaptive`) still works as before.
- If IO monadic termination unexpectedly fails to close (Phase 1 risk), fall back to gating the
  abort check on `branchesUsed % 64 == 0` (report Section 2.2 point 3) — this does not change the
  measure. If termination still resists, the phase is a single agent run that can be checkpointed
  RED with a handoff; no partial edits are committed until the module builds green.
- If the `mkInvalidLabel` parameter-passing refactor cascades (Phase 4 risk), fall back to
  bounding fuel only (the pure fix in report Section 4 point 1), deferring abort-awareness of the
  extraction leg to a follow-up — the fuel bound alone removes the unbounded main-thread re-run
  from the dataset path.

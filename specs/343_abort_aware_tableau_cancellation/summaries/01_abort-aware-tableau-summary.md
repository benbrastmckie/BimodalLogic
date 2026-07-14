# Implementation Summary: Abort-Aware Tableau Cancellation

- **Task**: 343 - Make the tableau decision procedure abort-aware so cancelled tasks stop instead
  of continuing as zombie threads
- **Status**: [COMPLETED]
- **Plan**: specs/343_abort_aware_tableau_cancellation/plans/01_abort-aware-tableau-plan.md
- **Type**: lean4
- **Phases**: 5 of 5 completed

## What Was Built

`IO.cancel task` in `labelFormulaImpl` was cooperative-only: the timed task body was a single
`return <pure computation>` that never re-entered `IO`, so the cancellation flag was never
observed and cancelled tableau expansions ran to fuel/branch exhaustion as zombie threads
(accumulating toward OOM on c7 batches). The fix follows the task-277 `_tracedImpl`
parallel-implementation precedent: **cancellable `IO` mirrors** of the pure tableau core that
check an `IO.Ref Bool` abort flag (plus `IO.checkCanceled`) at every recursive step and map an
observed abort to `none` → `.timeout`. The pure functions and all four proof-bearing theorems
are byte-for-byte untouched (zero proof debt).

## Phase-by-Phase

- **Phase 1 (committed e8cfe9ff6)**: New runtime-only module
  `Theories/Bimodal/Metalogic/Decidability/CancellableExpansion.lean` with IO mirrors
  `expandBranchWithFuelCancellable` / `saturateBlockedCancellable` / `buildTableauCancellable`,
  each with a leading abort check and termination closed by
  `termination_by fuel` / `decreasing_by all_goals simp_wf`. Doc-comment cross-links added on the
  pure definitions in `Saturation.lean` (comments only; two `private → public` visibility
  widenings for the tracker thread).
- **Phase 2 (committed 0944c507b)**: `decideCancellable` and `decideAutoAdaptiveCancellable`
  wrappers reusing the pure fast paths and mapping an aborted (`none`) tableau to `.timeout`,
  never `.valid`/`.invalid`.
- **Phase 3 (committed 40f848a3f)**: Wired `labelFormulaImpl` (DatasetGenerator.lean) — spawn an
  `abortRef`, run `decideAutoAdaptiveCancellable` in the task body, and `abortRef.set true`
  before `IO.cancel task` on the timeout branch. Chunked parallel path unchanged (owns the ref
  internally via `labelFormulaImpl`).
- **Phase 4 (committed 50aa3ef1c)**: Removed the second unbounded computation —
  `extractCountermodelData` gained an explicit `fuel : Nat := soundFuel φ` parameter;
  `extractCountermodelDataCancellable` added; `mkInvalidLabel` kept pure and now receives
  `(ecm, scmSummary)` computed abort-aware at the *deciding* `adaptiveFuel` in `labelFormulaImpl`
  (timed path) or fuel-bounded at 500 (synchronous fallback); `TableauBridge.handleCountermodel`
  now passes an explicit fuel instead of an unbound `soundFuel` re-run.
- **Phase 5 (this session)**: Verification — full build, mirror spot-check, abort-mechanism check.

## Verification Results

- **Full `lake build`**: GREEN, sorry-free — 1755 jobs. The only two warnings (unused var `q` at
  DatasetGenerator.lean:2174, from task 288; `String.trimLeft` deprecation at
  DatasetExport.lean:1221, a toolchain deprecation) both predate task 343.
- **Scoped rebuild** of the three touched modules (CancellableExpansion, DatasetGenerator,
  TableauBridge): GREEN, 741 jobs; **zero `sorry`/`admit`, zero new axioms**.
- **Mirror spot-check** (`spotcheck_mirror.lean`, compiled fresh via `lake env lean`): 13/13
  sample formulas agree between `buildTableauCancellable` (abort ref never set) and the pure
  `buildTableau`, spanning all three result tags (open / closed / none).
- **Abort-mechanism check** (`abort_mechanism_check.lean`, compiled fresh): with the abort flag
  PRE-SET, `buildTableauCancellable` short-circuits to `none` in **67 µs** even at
  `fuel = 1,000,000` (i.e. it does not depend on fuel — the abort is observed at the first
  recursive step), and `decideAutoAdaptiveCancellable` maps the pre-set abort to `.timeout`
  (never valid/invalid). This is the load-bearing runtime evidence that cancelled tasks stop
  promptly instead of running to exhaustion.

## Plan Deviations

- **Phase 4**: The synchronous-fallback `mkInvalidLabel` call site uses the pure
  `extractCountermodelData φ 500` (no abort ref exists on that non-timed path); the timed path
  uses `extractCountermodelDataCancellable`. `handleCountermodel` was made fuel-bounded only (no
  abort ref threaded) — the bridge has no wall-clock timeout, consistent with plan Non-Goals and
  research Section 8.
- **Phase 5**: The full-binary c7 system smoke run was deferred. Relinking the 264 MB
  `dataset_generator` executable is prohibitively slow in this environment, and a small-batch c7
  run does not reproduce the at-scale OOM on either old or new code, so it is not a discriminating
  check. The cancellation behavior is instead validated directly and more precisely by the
  abort-mechanism check (67 µs source-level short-circuit with fresh code).

## Artifacts

- `Theories/Bimodal/Metalogic/Decidability/CancellableExpansion.lean` (new: mirrors + wrappers)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` (wiring + bounded extraction)
- `Theories/Bimodal/Automation/TableauBridge.lean` (bounded countermodel leg)
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (doc-comment cross-links only)
- `specs/343_abort_aware_tableau_cancellation/spotcheck_mirror.lean` (Phase 5 spot-check)
- `specs/343_abort_aware_tableau_cancellation/abort_mechanism_check.lean` (Phase 5 mechanism check)

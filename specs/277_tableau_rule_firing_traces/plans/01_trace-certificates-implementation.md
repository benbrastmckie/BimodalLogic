# Implementation Plan: Task 277 — Instrument Tableau Prover with Rule-Firing Trace Certificates

- **Task**: 277 - tableau_rule_firing_traces
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours
- **Dependencies**: None
- **Research Inputs**: `specs/277_tableau_rule_firing_traces/reports/01_trace-certificates-design.md`
- **Artifacts**: `plans/01_trace-certificates-implementation.md` (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4

## Overview

Add a **rule-firing trace certificate** subsystem to the tableau decision procedure so that every rule application during proof search is recorded as a `TraceEntry` (mirroring the Libal & Volpe FPC schema `(precondition, rule, conclusion, branch_id)`). The certificate is threaded through `expandBranchWithFuel` as a pure `StateM ProofCertificate` layer, so the 4 existing termination/soundness proofs in `Saturation.lean` (the `termination_by fuel` at line 190, the secondary `termination_by fuel` at line 278, `expandBranchWithFuel_sound` at line 878, and the `tryBranch` helper proof around line 799) remain valid: the old function becomes a thin wrapper that discards the certificate. The plan adds a new executable `lake exe trace_exporter` that emits one JSONL line per run, capturing the full per-rule fingerprint, branching factor, and partial trace on timeout.

### Research Integration

The research report (`reports/01_trace-certificates-design.md`, 849 lines) supplies:
- A 28-rule catalog fully instrumented with `(rule, formula, world_label)` (8 propositional, 5 modal S5, 12 temporal, 3 dense-specific, 3 discrete-specific).
- A 5-constructor `TraceEntry` inductive (`ruleFired`, `branchCreated`, `branchClosed`, `blockingFired`, `fuelExhausted`) mirroring Libal & Volpe (2016) FPC.
- A recommended `StateT ProofCertificate` threading strategy that preserves termination proofs.
- A backward-compatibility wrapper pattern: `expandBranchWithFuel_tracedImpl` becomes the recursive engine; `expandBranchWithFuel` becomes a wrapper that discards the certificate.
- A `TraceResult = success | failure` sum type preserving partial traces on timeout.
- A string-based JSONL export path mirroring `Bimodal.Automation.DataExport` (lines 54-67).
- An estimated 26-hour, 6-phase roadmap; this plan refines it to 8 phases totaling ~14 hours by reusing the existing `DataExport` JSON helpers and a more focused `axiomFingerprint` design.

### Prior Plan Reference

No prior plan exists; this is the first plan for task 277.

### Roadmap Alignment

No ROADMAP.md item references task 277 explicitly. The plan advances the broader `Metalogic/Decidability` lineage of tasks 191 (propositional decision procedure), 243 (full axiom rule coverage), 250 (enriched formula JSON export), and 265 (single tier fuel and timeout prefilter) by exporting axiom-firing fingerprints suitable for downstream training-pipeline consumers.

## Goals & Non-Goals

**Goals**:
- Define `TraceEntry`, `ProofCertificate`, `CertOutcome`, `TraceFailure`, `TraceResult` in a new `TraceCertificate.lean` module.
- Thread a `ProofCertificate` accumulator through `expandOnceWithApplied` and `expandBranchWithFuel` via `StateM` while preserving the 4 existing termination/soundness proofs in `Saturation.lean` via a backward-compat wrapper.
- Instrument all 28 `applyRule` arms with one-line `record` calls; instrument `findClosure` and `findBlockedTime` for `branchClosed`/`blockingFired`/`fuelExhausted` events.
- Compute `axiomFingerprint`, `branchingFactor`, and `maxDepth` post-processing, with incremental updates during expansion.
- Preserve partial traces on fuel exhaustion via a `TraceResult = success | failure` sum type.
- Add a `ToJson` instance tree and a string-based `toJsonString` (mirroring `DataExport.lean:54-67`).
- Add a `lean_exe trace_exporter` CLI executable with `--output`, `--fuel`, `--frame-class`, `--filter-axiom` flags.
- Provide a test suite validating trace shape on `□p → p`, the timeout partial-trace path, and the JSONL output round-trip.

**Non-Goals**:
- Reproducing the Libal & Volpe focused-sequent kernel or producing ProofCert-verifiable certificates (the research report §11.6 calls this out as out-of-scope; the certificates are trace records, not verifiable certificates).
- Replacing the existing `decide`/`decideAuto` API; we add `decideWithTrace` and `decideAutoWithTrace` alongside.
- Re-proving tableau completeness/soundness from scratch; the backward-compat wrapper is load-bearing for the existing proofs.
- Recording a full `Branch` snapshot per event (the report §11.5 recommends opt-in only; we follow that).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Trace size blowup: 2-10M events for 5000 formulas (report §3.6 / §11.1) | M | M | Use `List ++ [entry]` (O(1) cons); reserve `Array` migration as Phase 7 contingency; pre-compute `axiomFingerprint` incrementally to avoid O(n²) walks; cap trace in `trace_exporter` CLI via `--max-trace-events`. |
| `List` accumulator `++` cost: `List ++ (a :: b)` is O(n) | L | M | Use `trace := entry :: cert.trace` (cons) and reverse at the end (in `decideWithTrace`); if benchmarks show a bottleneck, switch to `Std.Array` behind a `TraceM Array` variant. |
| Termination-proof preservation: breaking `termination_by fuel` would invalidate `expandBranchWithFuel_sound` (Saturation.lean:878) and 3 other proofs (lines 190, 278, 799) | H | L | Pure `StateM ProofCertificate` wrapping; the recursive call site still passes a strictly smaller `fuel`; add a `termination_by fuel` to the new `_tracedImpl` and verify with `lake build` after Phase 3. Old `expandBranchWithFuel` becomes a wrapper that calls `_traced` with an empty certificate and discards the result. |
| Export binary permissions / `IO.FS.writeFile` failure (report §7.4) | L | L | Use `IO.FS.writeFile` with explicit `IO.FS.Mode.userRW`; provide clear error message; the executable returns non-zero on `IO.Error` so `lake test` can detect. |
| IO timing accuracy: `IO.monoMsNow` is `IO`-only, but `decideWithTrace` must be pure (report §8.3) | L | M | Pure `decideWithTrace` sets `elapsedMs := 0`; an `IO` wrapper `decideWithTraceIO` measures wall-clock and overrides the field; tests assert `elapsedMs` is non-zero in the IO variant and 0 in the pure variant. |
| `TableauRule` lacks `BEq`/`Hashable` (line 135 has only `Repr, DecidableEq`) | L | M | Add `deriving BEq, Hashable` and a Nat-indexed enum for `axiomFingerprint` (avoids string-keyed HashMap cost on hot path). |
| `findUnexpanded` / `findApplicableRule` not threaded (report §5.4 lists 8 functions) | M | M | Phase 3 also threads `findUnexpandedWithApplied` and `findApplicableRuleWithApplied`; if a helper is hard to thread, fall back to the explicit-parameter option (Option B in report §5.1). |
| Wall-clock measurement on the timeout path includes IO overhead (report §8.3) | L | L | The IO wrapper measures only the `expandBranchWithFuel_traced` call, not the certificate construction. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6, 7 | 5 |
| 7 | 8 | 6, 7 |

Phases 6 and 7 are parallelizable: `ToJson` instances / `TraceExport.lean` (Phase 6) is independent from the test scaffolding (Phase 7). All other phases are sequential.

### Phase 1: Define Trace Certificate Types [COMPLETED]

- **Goal**: Add the data types `TraceEntry`, `ProofCertificate`, `CertOutcome`, `TraceFailure`, `TraceResult` in a new file `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean`, with `Repr`, `Inhabited`, and an empty `ProofCertificate.empty` constructor.
- **Tasks**:
  - [ ] Create `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` with imports from `Bimodal.Syntax`, `Bimodal.Metalogic.Decidability.SignedFormula`, and `Bimodal.Metalogic.Decidability.Closure`.
  - [ ] Define `inductive TraceEntry` with constructors `ruleFired`, `branchCreated`, `branchClosed`, `blockingFired`, `fuelExhausted` per report §4.1.
  - [ ] Define `inductive CertOutcome` with constructors `validProof`, `countermodel`, `timeout`, `blocked` and `deriving Repr, Inhabited, DecidableEq, BEq`.
  - [ ] Define `inductive TraceFailure` with constructors `outOfFuel`, `unsaturatable`, `applyRulePanic`, each carrying the partial trace.
  - [ ] Define `inductive TraceResult = .success ProofCertificate | .failure TraceFailure`.
  - [ ] Define `structure ProofCertificate` with fields `formula`, `frameClass`, `outcome`, `trace : List TraceEntry`, `totalSteps`, `axiomFingerprint : Std.HashMap String Nat`, `branchingFactor : Float`, `maxDepth`, `elapsedMs`, `appliedSnapshot : Option AppliedSet`, `lastBranch : Option Branch`.
  - [ ] Provide `ProofCertificate.empty : Formula → FrameClass → ProofCertificate`.
  - [ ] Provide `Repr` and `Inhabited` instances for all types.
  - [ ] Run `lake build` and confirm the new module compiles.
- **Timing**: 2 hours
- **Depends on**: none
- **Files to modify**:
  - `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` — new file (~120 LOC)

### Phase 2: Add Deriving Instances and `record` Primitive [COMPLETED]

- **Goal**: Add `BEq, Hashable` to `TableauRule` and `CertOutcome`; implement the `TraceM = StateM ProofCertificate` monad and a `record : TraceEntry → TraceM Unit` primitive that incrementally updates the trace, total steps, fingerprint, and max depth.
- **Tasks**:
  - [ ] In `Theories/Bimodal/Metalogic/Decidability/Tableau.lean`, change `inductive TableauRule` to add `deriving BEq, Hashable` (line 135).
  - [ ] In `TraceCertificate.lean`, define `abbrev TraceM (α : Type) : Type := StateM ProofCertificate α`.
  - [ ] Implement `def record (entry : TraceEntry) : TraceM Unit := modify fun cert => ...` (report §5.2) using `List.cons` (O(1)) and an `axiomFingerprint.insert` update keyed on `ruleToString`.
  - [ ] Implement `def ruleToString : TableauRule → String` covering all 28 constructors (report §9.1).
  - [ ] Implement `def updateFingerprint : Std.HashMap String Nat → TraceEntry → Std.HashMap String Nat` (no-op for non-`ruleFired` entries).
  - [ ] Implement `def entryDepth : TraceEntry → Nat` returning 0 for non-`branchCreated` events and `newBranchId` for `branchCreated`.
  - [ ] Add `def getCert : TraceM ProofCertificate := get` and `def setCert : ProofCertificate → TraceM Unit := set` helpers.
  - [ ] Run `lake build`; confirm all existing tests still pass.
- **Timing**: 1.5 hours
- **Depends on**: 1
- **Files to modify**:
  - `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` — add `deriving BEq, Hashable` (~2 lines).
  - `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` — add `TraceM`, `record`, `ruleToString`, `updateFingerprint`, `entryDepth` (~80 LOC).

### Phase 3: Wrap `expandOnceWithApplied` and `expandBranchWithFuel` [COMPLETED]

- **Goal**: Implement `_tracedImpl` versions of `expandOnceWithApplied` and `expandBranchWithFuel` that thread `ProofCertificate` as a `StateM` parameter, then re-expose the old `expandBranchWithFuel` as a thin wrapper. Preserve the 4 existing termination/soundness proofs by leaving the old API's signature unchanged.
- **Tasks**:
  - [ ] In `Saturation.lean`, add `def expandOnceWithApplied_tracedImpl (branch : Branch) (rule : TableauRule) (timeOrd : TimeOrdering) (fc : FrameClass) (tracker : EventualityTracker) (applied : AppliedSet) : StateM ProofCertificate (Option (RuleResult × TimeOrdering × List SignedFormula))`. Internally call `record` with `TraceEntry.ruleFired` (deferred to Phase 4 for the 28 rule sites; Phase 3 only adds the wrapper structure).
  - [ ] Add `def expandBranchWithFuel_tracedImpl (b : Branch) (fuel : Nat) (timeOrd : TimeOrdering) (fc : FrameClass) (tracker : EventualityTracker) (applied : AppliedSet) : StateM ProofCertificate (Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet)))`. Mirror the existing `expandBranchWithFuel` body, threading `getCert`/`setCert` around the recursive call.
  - [ ] Add `termination_by fuel` to `expandBranchWithFuel_tracedImpl` (proof: same fuel argument; trivial).
  - [ ] Refactor `expandBranchWithFuel` (Saturation.lean:143) to: `let (result, _) := (expandBranchWithFuel_tracedImpl b fuel timeOrd fc tracker applied ProofCertificate.empty ...).run; pure result`. This is the backward-compat wrapper.
  - [ ] Add a comment block in `Saturation.lean` explaining the wrapper strategy and the 4 preservation guarantees.
  - [ ] Add `def expandBranchWithFuel_traced` (no `Impl` suffix) that exposes the `(result × certificate)` pair for new code.
  - [ ] Run `lake build`; run `lake test`; confirm all 4 existing proofs still type-check (no warnings about unused `decreasing_by`).
- **Timing**: 2 hours
- **Depends on**: 2
- **Files to modify**:
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` — add `_tracedImpl` variants and the wrapper (~80 LOC delta).
  - `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` — re-export the new entry points.

### Phase 4: Instrument All 28 Rule Sites in `applyRule` [COMPLETED]

**Note on implementation strategy**: Instrumentation is performed at the
`expandOnceWithApplied_tracedImpl` level (inspecting the result of
`findApplicableRuleWithApplied`) rather than inside the 28 `applyRule` arms.
This is functionally equivalent (each `applyRule` call is exactly one
`recordRuleFired` event) and avoids modifying `applyRule` directly, which
is used in two places and is referenced by 28+ match arms. All 28 rules
are covered via the `RuleResult.linear / .branching / .persistent` cases.

- **Goal**: Add one-line `record` calls inside each arm of the 28-constructor `applyRule` match (Saturation.lean/Tableau.lean:326-952) so that every rule firing is captured. Cover the 8 propositional rules, 5 modal S5 rules, 12 temporal rules, and 3 dense + 3 discrete frame-class-gated rules per the catalog in report §3.1-§3.4.
- **Tasks**:
  - [ ] In `Theories/Bimodal/Metalogic/Decidability/Tableau.lean`, add a `record` call to each of the 28 `applyRule` arms using a helper `def recordRuleFired (rule : TableauRule) (sf : SignedFormula) (produced : List SignedFormula) (branchDepth : Nat) (fc : FrameClass) : TraceM Unit` (defined in `TraceCertificate.lean`).
  - [ ] For the 5 modal S5 propagation rules (`boxPos`, `boxNeg`, `diamondPos`, `diamondNeg`, `boxTemporal`), record the produced worlds/times in `produced` and set `isPersistent := true` for the persistent variants.
  - [ ] For the 12 temporal rules, record `freshTime` indices and `produced` lists as per report §3.3.
  - [ ] For the 6 frame-class-gated rules (3 dense, 3 discrete), record `frameClass := fc` and include the axiom name in the rule identifier.
  - [ ] For the 5 branching rules (`andNeg`, `orPos`, `impPos`, `untlPos`, `untlNeg`, `sncePos`, `snceNeg`), also call `record (.branchCreated ...)` from `applyRule`'s caller in `expandOnceWithApplied_tracedImpl`.
  - [ ] Verify the trace of `□p → p` (single-formula test) contains exactly: `.ruleFired impNeg`, `.ruleFired boxPos`, `.branchClosed .contradiction` (3 events).
  - [ ] Run `lake build`; run `lake test`.
- **Timing**: 2 hours
- **Depends on**: 3
- **Files to modify**:
  - `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` — 28 `record` calls (~30 LOC delta).
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` — `.branchCreated` hook in `expandOnceWithApplied_tracedImpl` (~10 LOC).
  - `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` — `recordRuleFired` helper.

### Phase 5: Instrument Closure, Blocking, and Add `decideWithTrace` [COMPLETED]

- **Goal**: Hook `findClosure` for `branchClosed` events, `findBlockedTime` for `blockingFired`, and the `fuel = 0` branch for `fuelExhausted`. Add `decideWithTrace : Formula → Nat → FrameClass → TraceResult` to `DecisionProcedure.lean` that returns a `TraceResult` with the partial trace preserved on failure.
- **Tasks**:
  - [ ] In `Saturation.lean`, wrap `findClosure` calls inside `expandBranchWithFuel_tracedImpl` with `record (.branchClosed {...})` for closed branches and pass through for non-closed.
  - [ ] Wrap `findBlockedTime` results in `record (.blockingFired {...})`.
  - [ ] Add a `fuel = 0` early-return branch in `expandBranchWithFuel_tracedImpl` that records `.fuelExhausted fuelRemaining := 0` and returns `none`.
  - [ ] Implement `def decideWithTrace (φ : Formula) (fuel : Nat) (fc : FrameClass := .Base) : TraceResult` in `DecisionProcedure.lean` per report §8.2. Build `ProofCertificate.empty φ fc` initially; call `expandBranchWithFuel_traced`; match on the result and produce `.success` (with `outcome := .validProof` or `.countermodel`) or `.failure`.
  - [ ] Implement post-processing `axiomFingerprint`, `computeBranchingFactor`, `computeMaxDepth` (report §9) as a single `finalizeCertificate : ProofCertificate → ProofCertificate` helper that reverses the trace (`List.reverse` is O(n) but only done once at the end), sets `elapsedMs := 0` (pure), and computes the O(n) statistics.
  - [ ] Add `def decideAutoWithTrace : Formula → Nat → FrameClass → TraceResult` mirroring `decideAuto`.
  - [ ] Add a unit test in `Tests/BimodalTest/` that calls `decideWithTrace` on a formula known to time out at low fuel and asserts `.failure (.outOfFuel ...)`.
  - [ ] Run `lake build`; run `lake test`.
- **Timing**: 1.5 hours
- **Depends on**: 4
- **Files to modify**:
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` — `findClosure` / `findBlockedTime` / fuel-exhausted hooks (~25 LOC).
  - `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` — `decideWithTrace`, `decideAutoWithTrace`, `finalizeCertificate` (~80 LOC).
  - `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` — `finalizeCertificate` helper.

### Phase 6: JSON Serialization (string-based JSONL) [COMPLETED]

- **Goal**: Add a `ToJson` instance tree for `TraceEntry`, `ProofCertificate`, `TableauRule`, `Sign`, `FrameClass`, `Label`, `ClosureReason`, `CertOutcome`, and `TraceResult`. Also provide a `toJsonString : ProofCertificate → String` matching the `DataExport.lean:54-67` style for the JSONL executable.
- **Tasks**:
  - [ ] Create `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` (mirrors `Bimodal.Automation.DataExport`).
  - [ ] Add `ToJson` instances for `TableauRule`, `Sign`, `FrameClass`, `ClosureReason`, `CertOutcome` using the `Json.str` / `Json.mkObj` API (report §7.2 Path 1).
  - [ ] Add `ToJson` instance for `Label` (using `world` and `time` fields) and `SignedFormula`.
  - [ ] Add `ToJson` instance for `TraceEntry` (5-constructor match, with `event` discriminator field per report §7.1).
  - [ ] Add `ToJson` instance for `ProofCertificate` with all 11 fields.
  - [ ] Add `ToJson` instance for `TraceResult` (success/failure tagged object).
  - [ ] Implement `def ProofCertificate.toJsonString (cert : ProofCertificate) : String` per report §7.2 Path 2, reusing `escapeJsonString` and `listToJsonArray` from `Bimodal.Automation.DataExport`.
  - [ ] Implement `def TraceResult.toJsonString : TraceResult → String` that includes a `failure_kind` field on failures.
  - [ ] Add a small round-trip test in `Tests/BimodalTest/`: parse the JSONL output with `Json.parse` and assert it round-trips.
  - [ ] Run `lake build`; run `lake test`.
- **Timing**: 2 hours
- **Depends on**: 5
- **Files to modify**:
  - `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` — new file (~250 LOC).
  - `Tests/BimodalTest/TraceExportTest.lean` — round-trip test (~40 LOC).

### Phase 7: `lake exe trace_exporter` Executable with CLI Parser [IN PROGRESS]

- **Goal**: Add a CLI executable `trace_exporter` that runs `decideWithTrace` over a list of formulas (read from a file or via a small built-in enumerator) and writes one JSONL line per run. Mirror the structure of `proof_extractor` and `tableau_proof_steps` in `lakefile.lean`.
- **Tasks**:
  - [ ] Create `Theories/Bimodal/Automation/TraceCertificateExporter.lean` (the executable root, mirroring `Bimodal.Automation.ProofStepExport`).
  - [ ] Implement a simple arg parser with `clap`-style flags: `--output PATH` (required), `--fuel NAT`, `--frame-class Base|Dense|Discrete`, `--filter-axiom STRING`, `--max-trace-events NAT`, `--formula-file PATH` (one formula per line, or use `FormulaEnumerator`).
  - [ ] Wrap `decideWithTrace` in an `IO` wrapper that records `IO.monoMsNow` before/after and overwrites `elapsedMs` on the resulting certificate (report §8.3).
  - [ ] For each formula, run `decideWithTraceIO`, serialize to `toJsonString`, and append a newline to the output file via `IO.FS.writeFile` with explicit `IO.FS.Mode.userRW` (report §7.4 / Risk 4).
  - [ ] Add the `lean_exe trace_exporter` block to `lakefile.lean` with `root := `Bimodal.Automation.TraceCertificateExporter`` and `srcDir := "Theories"`.
  - [ ] Run `lake build`; verify `lake exe trace_exporter -- --help` prints a usage message.
  - [ ] Run on 5 enumerated formulas with `--output /tmp/trace.jsonl` and confirm valid JSONL.
- **Timing**: 1.5 hours
- **Depends on**: 5 (parallel with Phase 6)
- **Files to modify**:
  - `Theories/Bimodal/Automation/TraceCertificateExporter.lean` — new file (~180 LOC).
  - `lakefile.lean` — add `lean_exe trace_exporter` block (~6 LOC).
  - `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` — add `decideWithTraceIO` wrapper.

### Phase 8: Test Suite and End-to-End Smoke Test [NOT STARTED]

- **Goal**: Provide a comprehensive test suite in `Tests/BimodalTest/` validating the trace shape, the timeout partial-trace path, the JSONL output, the `axiomFingerprint` accuracy, and a CLI smoke test.
- **Tasks**:
  - [ ] Add `Tests/BimodalTest/TraceCertificateTest.lean` with:
    - `test trace for □p → p produces 3 events`: validate the expected 3-step trace shape (`impNeg`, `boxPos`, `contradiction`).
    - `test axiom fingerprint on propositional formula`: validate `axiomFingerprint` matches expected counts.
    - `test branching factor on ◇p ∧ □(p → F(¬p))`: validate `branchingFactor` is in the expected range.
    - `test timeout preserves partial trace`: run with `fuel := 5` on a complex formula and assert `.failure (.outOfFuel trace steps)` with `trace` non-empty.
    - `test decideAutoWithTrace returns same outcome as decideAuto`: parity test.
    - `test JSONL output round-trips through Lean.Json.parse`: parse the output of `ProofCertificate.toJsonString`.
  - [ ] Add a smoke-test shell script `scripts/smoke_test_trace_exporter.sh` that runs `lake exe trace_exporter` on 10 enumerated formulas and asserts the output file exists, is non-empty, and contains valid JSONL (using `python3 -c "import json; [json.loads(l) for l in open('trace.jsonl')]"`).
  - [ ] Run `lake test`; confirm all tests pass.
  - [ ] Add a smoke-test entry to `lakefile.lean` or a CI config (out-of-scope for implementation but mention in a comment).
- **Timing**: 1.5 hours
- **Depends on**: 6, 7
- **Files to modify**:
  - `Tests/BimodalTest/TraceCertificateTest.lean` — new file (~150 LOC).
  - `scripts/smoke_test_trace_exporter.sh` — new file (~25 LOC).

## Testing & Validation

- [ ] **Build**: `lake build` succeeds after each phase; no warnings about unused `decreasing_by` or `termination_by` proofs.
- [ ] **Existing tests**: `lake test` passes after Phase 3 (the backward-compat wrapper must keep all 4 termination/soundness proofs valid).
- [ ] **Unit tests** (Phase 8): `Tests/BimodalTest/TraceCertificateTest.lean` covers trace shape, fingerprint, branching factor, timeout, and JSONL round-trip.
- [ ] **Smoke test** (Phase 8): `scripts/smoke_test_trace_exporter.sh` runs `lake exe trace_exporter` on 10 formulas and validates the output.
- [ ] **Backward-compat verification** (Phase 3): explicitly `lake build Saturation.lean` and confirm the 4 proofs (`termination_by fuel` at line 190, secondary `termination_by fuel` at line 278, `expandBranchWithFuel_sound` at line 878, `tryBranch` helper proof around line 799) are unchanged.
- [ ] **Profile** (optional, post-Phase 8): `lean --profile` on a representative formula to confirm trace overhead is < 2x of the uninstrumented run.
- [ ] **Reference check**: confirm `TraceEntry.ruleFired` matches the Libal & Volpe FPC schema `(precondition, rule, conclusion, branch_id)` per report §11.6.
- [ ] **Memory check**: for a 5000-formula batch, the trace file size is bounded (estimate: 2-10M events at ~100 bytes/event = 200MB-1GB; flag if exceeds 2GB).

## Artifacts & Outputs

- `specs/277_tableau_rule_firing_traces/plans/01_trace-certificates-implementation.md` — this file.
- `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` — new module with `TraceEntry`, `ProofCertificate`, `TraceResult`, `TraceM`, `record`, post-processing helpers.
- `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` — new module with `ToJson` instances and `toJsonString`.
- `Theories/Bimodal/Automation/TraceCertificateExporter.lean` — new executable root.
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` — modified to add `_tracedImpl` variants and the backward-compat wrapper.
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` — modified to add `deriving BEq, Hashable` and 28 `record` calls in `applyRule`.
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` — modified to add `decideWithTrace` and `decideAutoWithTrace`.
- `lakefile.lean` — modified to add `lean_exe trace_exporter`.
- `Tests/BimodalTest/TraceCertificateTest.lean` — new test suite.
- `scripts/smoke_test_trace_exporter.sh` — new smoke test script.
- `specs/277_tableau_rule_firing_traces/summaries/01_trace-certificates-summary.md` — implementation summary (created during `/implement`).

## Rollback/Contingency

The change is **non-invasive by design**: the old `expandBranchWithFuel` signature is preserved as a thin wrapper around `_tracedImpl`. To roll back:

1. Revert the `expandBranchWithFuel` body in `Saturation.lean` to its pre-Phase-3 implementation (use `git checkout` on the affected hunks).
2. Delete `TraceCertificate.lean`, `TraceExport.lean`, and `TraceCertificateExporter.lean`.
3. Remove the `lean_exe trace_exporter` block from `lakefile.lean`.
4. Delete the new test files.

Since `_tracedImpl` is a *new* function (not a modification of the old one), reverting the wrapper body in step 1 is the only behavioral rollback needed. The 4 termination/soundness proofs in `Saturation.lean` will revert to their pre-Phase-3 state, which is the goal.

**Contingency triggers**:
- If `termination_by fuel` fails to re-prove on `_tracedImpl` (Phase 3), fall back to **Option B** (report §5.1) — explicit `ProofCertificate` parameter threaded by hand. This requires re-doing Phase 3 but does not break the 4 existing proofs.
- If the trace accumulator blows memory (Phase 8 `lake exe trace_exporter` exits with OOM), switch to `Array`-backed accumulator in `TraceM Array`; document as a follow-up task.
- If JSONL output exceeds 2GB, add a `--max-trace-events` cap and a `--summary-only` mode (drop the `trace` field, keep `axiomFingerprint`).

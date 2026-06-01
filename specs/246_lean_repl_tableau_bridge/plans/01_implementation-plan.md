# Implementation Plan: Lean REPL Tableau Bridge

- **Task**: 246 - Lean REPL tableau bridge for live queries
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Task 241 (decision procedure corrections)
- **Research Inputs**: specs/246_lean_repl_tableau_bridge/reports/01_repl-tableau-bridge-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Create a new `TableauBridge.lean` module and `tableau_bridge` executable that implements a persistent REPL process with a JSONL stdin/stdout protocol. The bridge composes existing infrastructure -- `pFormula` parser from BenchmarkOracle, `decideAuto` from DecisionProcedure, `extractStepSequence` from ProofStepExtractor, and countermodel extraction from EnrichedCountermodel -- into three command handlers (`tableau_decide`, `tableau_steps`, `countermodel`) plus `ping`/`shutdown` lifecycle commands. A corresponding lakefile.lean entry registers the new executable. The implementation is primarily plumbing (~200-400 lines of new Lean code) since all algorithmic components exist and are production-ready.

### Research Integration

Key findings from report 01 (repl-tableau-bridge-research.md):
- No existing REPL or stdin-processing executable -- all 7 current executables are batch-mode
- BenchmarkOracle.lean is the closest analogue: it reads JSONL, parses formula AST via `pFormula`, runs `labelFormula`, and emits JSON output. The bridge reuses this exact pattern with a stdin loop and request routing
- `decideAuto` provides auto-calibrated fuel via `soundFuel` (min(n*2^n, 100000)); returns `DecisionResult` with proof/countermodel/timeout
- `extractStepSequence` walks DerivationTree and emits ordered ProofStep records; `ProofStep.toJson` already exists
- Three countermodel layers (Simple, Enriched, Semantic) all have `toJson` methods
- Formula JSON parser `pFormula` handles tags: atom, bot, imp, box, untl, snce
- Performance: complexity <= 8 achievable under 500ms; persistent REPL amortizes 100-300ms Lean startup cost
- Missing pieces: stdin read loop, request envelope parser, FrameClass parser, wall-clock timeout wrapper

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the training pipeline infrastructure. The ROADMAP.md focuses on completeness proofs and publication -- this task is orthogonal but supports the ML training data pipeline that validates formulas against the decision procedure.

## Goals & Non-Goals

**Goals**:
- Create `TableauBridge.lean` with JSONL stdin/stdout REPL protocol
- Implement three command handlers: `tableau_decide`, `tableau_steps`, `countermodel`
- Add `ping` and `shutdown` lifecycle commands
- Register `tableau_bridge` executable in `lakefile.lean`
- Meet <500ms round-trip target for complexity <= 8 formulas
- Build successfully with `lake build tableau_bridge`

**Non-Goals**:
- Python-side `lean/bridge.py` implementation (BimodalHarness scope)
- Multithreading or connection pooling (BimodalHarness manages parallelism)
- Batch command support (can be added later)
- Wall-clock timeout at the tableau level (fuel-based bounding via `soundFuel` is sufficient; Python-side timeout handles edge cases)
- Modifying existing modules (DataExport, BenchmarkOracle, etc.)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lean 4 IO stdin blocking or buffering issues | H | M | Test early with simple echo loop; use `IO.FS.Stream.getLine` which blocks correctly; flush stdout after each response |
| `pFormula` cannot be extended for request envelope without refactor | M | L | Request envelope parsing uses the same `PState` infrastructure; only needs new top-level field extraction (command, frame_class, timeout_ms) before delegating to existing `pFormula` |
| Performance regression for high-complexity formulas | M | M | `soundFuel` caps at 100000 steps; add per-request `timeout_ms` field that Python can use for its own timeout; document complexity limits |
| Build failure from import cycle | L | L | Research confirmed: all imports are within Automation module, no circular dependencies possible with existing module graph |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Request/Response Types and Parsers [IN PROGRESS]

**Goal**: Define the JSONL protocol types, implement request envelope parsing and response JSON formatting in a new `TableauBridge.lean` file.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/TableauBridge.lean` with module header and imports
- [ ] Import: `DatasetGenerator`, `DataExport`, `ProofStepExtractor`, `BenchmarkOracle`, `EnrichedCountermodel`
- [ ] Define `BridgeCommand` inductive: `tableau_decide | tableau_steps | countermodel | ping | shutdown`
- [ ] Define `BridgeRequest` structure: `command : BridgeCommand`, `formula : Option Formula`, `frameClass : FrameClass`, `timeoutMs : Option Nat`
- [ ] Implement `parseFrameClass : String -> FrameClass` (handle "Base", "Dense", "Discrete"; default to `.Base`)
- [ ] Implement `parseCommand : String -> Except String BridgeCommand` for the 5 command strings
- [ ] Implement `parseRequest : String -> Except String BridgeRequest` using existing `PState` infrastructure from BenchmarkOracle: parse outer JSON object, extract "command", "formula" (via `pFormula`), "frame_class", "timeout_ms" fields
- [ ] Implement response JSON builders: `mkErrorResponse`, `mkPongResponse`, `mkDecideResponse`, `mkStepsResponse`, `mkCountermodelResponse`
- [ ] Each response includes `"time_ms"` field for round-trip measurement

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/TableauBridge.lean` - New file (create)

**Verification**:
- File compiles with `lake build Bimodal.Automation.TableauBridge` (no sorry, no errors)
- All parser functions type-check with correct signatures

---

### Phase 2: Command Handlers [NOT STARTED]

**Goal**: Implement the three core command handlers that compose existing infrastructure into request/response flows.

**Tasks**:
- [ ] Implement `handleDecide : Formula -> FrameClass -> IO String` -- calls `decideAuto`, measures wall-clock time with `IO.monoMsNow`, returns JSON with status (valid/invalid/timeout), proof_trace, countermodel, metrics, and time_ms
- [ ] For valid results: include `ProofTrace` from `DatasetGenerator.extractProofTrace` and rule profile from `DataExport.walkDerivationTree`
- [ ] For invalid results: include `SimpleCountermodel.toJson`
- [ ] Implement `handleSteps : Formula -> FrameClass -> IO String` -- calls `decideAuto`, if valid extracts proof steps via `extractStepSequence`, serializes step array via `ProofStep.toJson`, returns JSON array
- [ ] For invalid/timeout results in `handleSteps`: return error JSON explaining no proof exists
- [ ] Implement `handleCountermodel : Formula -> FrameClass -> IO String` -- calls `decideAuto`, if invalid returns `SimpleCountermodel.toJson` plus optionally `EnrichedCountermodel.toJson`
- [ ] For valid results in `handleCountermodel`: return JSON indicating formula is valid (no countermodel)
- [ ] Implement `dispatch : BridgeRequest -> IO String` that routes to the appropriate handler based on `BridgeCommand`
- [ ] Handle missing formula field for commands that require it (return error response)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/TableauBridge.lean` - Add handler functions

**Verification**:
- Module compiles with `lake build Bimodal.Automation.TableauBridge`
- Handler type signatures match: `Formula -> FrameClass -> IO String`
- Dispatch function covers all 5 command variants

---

### Phase 3: REPL Loop and Executable Registration [NOT STARTED]

**Goal**: Implement the stdin/stdout REPL loop and register the `tableau_bridge` executable in `lakefile.lean`.

**Tasks**:
- [ ] Implement `replLoop : IO Unit` -- read lines from stdin via `IO.getStdin` and `IO.FS.Stream.getLine`, parse each as a request, dispatch, write response to stdout, flush after each line
- [ ] Handle stdin EOF (empty string from getLine) as clean shutdown
- [ ] Handle parse errors gracefully: write error JSON response, continue loop (do not crash)
- [ ] Print ready signal `{"status": "ready"}` to stdout on startup before entering loop
- [ ] Print startup banner to stderr (so Python can detect readiness without confusing it with a response)
- [ ] Implement `main : List String -> IO Unit` entry point that calls `replLoop`
- [ ] Add `lean_exe tableau_bridge` entry to `lakefile.lean` with `root := \`Bimodal.Automation.TableauBridge`, `srcDir := "Theories"`, `supportInterpreter := true`
- [ ] Ensure stdout is line-buffered (flush after each response write)

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/TableauBridge.lean` - Add REPL loop and main
- `lakefile.lean` - Add `lean_exe tableau_bridge` entry

**Verification**:
- `lake build tableau_bridge` succeeds
- Manual test: `echo '{"command": "ping"}' | lake exe tableau_bridge` returns `{"status": "pong"}`
- Manual test: stdin EOF causes clean exit (no crash)

---

### Phase 4: Integration Testing and Performance Validation [NOT STARTED]

**Goal**: Verify all three command handlers with real formulas, validate <500ms performance target, and run full project build.

**Tasks**:
- [ ] Test `tableau_decide` with known valid formula: `{"command": "tableau_decide", "formula": {"tag": "imp", "left": {"tag": "atom", "name": "p"}, "right": {"tag": "imp", "left": {"tag": "atom", "name": "q"}, "right": {"tag": "atom", "name": "p"}}}}` -- expect `"status": "valid"`
- [ ] Test `tableau_decide` with known invalid formula: `{"command": "tableau_decide", "formula": {"tag": "atom", "name": "p"}}` -- expect `"status": "invalid"` with countermodel
- [ ] Test `tableau_steps` with a valid formula -- expect JSON array of proof steps
- [ ] Test `countermodel` with an invalid formula -- expect countermodel JSON with trueAtoms/falseAtoms
- [ ] Test frame class parameter: `{"command": "tableau_decide", "formula": ..., "frame_class": "Dense"}`
- [ ] Test error handling: malformed JSON input returns error response without crashing
- [ ] Test `shutdown` command: `{"command": "shutdown"}` causes clean exit
- [ ] Performance test: pipe 10 formulas of complexity 3-6 through the bridge, verify all return within 500ms (check `time_ms` field in responses)
- [ ] Run `lake build` to verify no regressions in the full project build

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- No files modified; testing only

**Verification**:
- All 3 command handlers return correct JSON for valid/invalid/timeout cases
- Error handling does not crash the REPL loop
- `time_ms` values for complexity <= 6 formulas are under 500ms
- `lake build` succeeds with zero new errors

## Testing & Validation

- [ ] `lake build tableau_bridge` compiles without errors or sorries
- [ ] `ping` command returns `{"status": "pong"}`
- [ ] `shutdown` command causes clean process exit
- [ ] `tableau_decide` returns valid/invalid/timeout with correct JSON schema
- [ ] `tableau_steps` returns proof step array for valid formulas
- [ ] `countermodel` returns countermodel JSON for invalid formulas
- [ ] Malformed input returns error response without crashing the REPL
- [ ] EOF on stdin causes clean shutdown
- [ ] `time_ms` field present in all command responses
- [ ] Complexity <= 6 formulas complete in under 500ms
- [ ] `lake build` (full project) succeeds with no regressions

## Artifacts & Outputs

- `Theories/Bimodal/Automation/TableauBridge.lean` - New REPL bridge module (~200-400 lines)
- `lakefile.lean` - Updated with `lean_exe tableau_bridge` entry
- `specs/246_lean_repl_tableau_bridge/plans/01_implementation-plan.md` - This plan
- `specs/246_lean_repl_tableau_bridge/summaries/01_execution-summary.md` - Post-implementation summary

## Rollback/Contingency

The implementation is additive -- it creates one new file (`TableauBridge.lean`) and adds one entry to `lakefile.lean`. Rollback is straightforward:
1. Remove `Theories/Bimodal/Automation/TableauBridge.lean`
2. Remove the `lean_exe tableau_bridge` block from `lakefile.lean`
3. Run `lake build` to verify clean state

No existing modules are modified, so there is zero risk of regression to existing functionality.

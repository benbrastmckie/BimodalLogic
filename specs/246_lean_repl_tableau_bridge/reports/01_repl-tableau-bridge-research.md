# Research Report: Lean REPL Tableau Bridge for BimodalHarness Live Queries

**Task**: 246 — Lean REPL Tableau Bridge  
**Session**: sess_1780355308_a08e2f_246  
**Date**: 2026-06-01

---

## 1. Executive Summary

The BimodalLogic codebase has **extensive existing infrastructure** that can be composed into a REPL/bridge executable with modest effort. The decision procedure (`decideAuto`), JSON serialization pipeline, formula JSON parser, proof step extraction, and countermodel extraction are all production-ready. The primary implementation work is:

1. A new `lean_exe` target with a stdin/stdout JSON-line protocol (REPL loop)
2. Wiring existing `pFormula` parser, `decideAuto`, `labelFormula`, `extractStepSequence`, and `SimpleCountermodel.toJson` into request/response handlers
3. Performance tuning to meet the <500ms round-trip target

No new algorithmic components are needed. The existing `BenchmarkOracle.lean` already demonstrates the pattern: parse formula JSON from text, run decision procedure, emit JSON output. The REPL simply adds a stdin read-loop and request routing.

---

## 2. Existing REPL and Command Infrastructure

### 2.1 No Existing REPL

The project has **no interactive REPL loop** or stdin-processing executable. All existing executables are batch-mode:

| Executable | Root Module | Purpose |
|-----------|-------------|---------|
| `dataset_generator` | `DatasetExport` | Enumerate formulas, label batch, emit JSONL |
| `dataset_validator` | `DatasetValidator` | Conformance testing |
| `proof_extractor` | `ProofStepExport` | Extract proof steps from theorem registry |
| `enum_benchmark` | `EnumBenchmark` | Complexity 5-7 feasibility gates |
| `benchmark_anchors` | `BenchmarkAnchors` | Axiom instance generation |
| `benchmark_oracle` | `BenchmarkOracle` | Batch formula validation from file |
| `contrastive_generator` | `FormulaMutator` | Contrastive pair generation |

All executables read from files and write to files. None process stdin interactively.

### 2.2 Closest Existing Pattern: BenchmarkOracle

`BenchmarkOracle.lean` (Theories/Bimodal/Automation/BenchmarkOracle.lean) is the closest existing analogue. It:

1. Reads JSONL lines from a file
2. Parses formula AST JSON via a hand-rolled recursive-descent parser (`pFormula`)
3. Runs `labelFormula` (which calls `decideAuto` internally)
4. Emits labeled JSON output

This is essentially the REPL bridge logic minus the stdin loop and request/response framing.

### 2.3 Lean 4 Custom Commands

`Theories/Bimodal/Automation/Tactics/Commands.lean` defines custom Lean tactics (`modal_search`, etc.) but these are compile-time meta-programming constructs, not runtime commands. They cannot serve as a REPL protocol.

---

## 3. DecisionProcedure.decide Interface and Performance

### 3.1 Core API

```lean
-- Main entry point with auto-calibrated fuel
def decideAuto (φ : Formula) (fc : FrameClass := .Base) : DecisionResult φ

-- DecisionResult is a sum type:
inductive DecisionResult (φ : Formula) : Type where
  | valid (proof : ⊢ φ)           -- Proof term witness
  | invalid (counter : SimpleCountermodel)  -- Countermodel witness  
  | timeout                        -- Resource exhaustion

-- Convenience
def isValid (φ : Formula) (fc : FrameClass := .Base) : Bool
def isSatisfiable (φ : Formula) (fc : FrameClass := .Base) : Bool
```

### 3.2 Algorithm Pipeline

`decide` follows a 3-stage pipeline:

1. **Fast path**: `tryAxiomProof φ` — direct pattern match against all 42 axiom schemata (instant)
2. **Proof search**: `bounded_search_with_proof [] φ searchDepth` — bounded DFS with depth limit (fast for shallow proofs)
3. **Full tableau**: `buildTableau φ tableauFuel fc` — construct full tableau, then:
   - All closed: extract proof via `extractProof` (5-strategy pipeline)
   - Open saturated branch: extract countermodel via `extractCountermodelSimple`

`decideAuto` sets fuel automatically via `soundFuel φ`, which is `min(n * 2^n, 100000)` where `n = |subformulaClosure(φ)|`.

### 3.3 Frame Class Support

Three frame classes are supported: `.Base`, `.Dense`, `.Discrete`. The `decide` function accepts an optional `fc` parameter (default `.Base`).

### 3.4 Performance Assessment

**Existing timing data** from `DatasetGenerator.labelFormula`:
- Uses `IO.monoMsNow` for wall-clock measurement
- `decisionTimeMs` is recorded in `DifficultyMetrics`
- Classification: complexity <= 3 = "easy", 4-6 = "medium", 7-9 = "hard", 10+ = "very_hard"

**Expected performance for <500ms target**:
- **Easy (complexity <= 3)**: Sub-millisecond. Axiom fast-path or shallow search handles most.
- **Medium (complexity 4-6)**: 1-50ms typical. Tableau terminates quickly with subset blocking.
- **Hard (complexity 7-9)**: 10-500ms. Subset blocking and fuel limit keep this bounded.
- **Very hard (complexity 10+)**: May exceed 500ms. `soundFuel` can reach 100000 steps.

The `soundFuel` bound is `min(n * 2^n, 100000)`. For complexity-5 formulas, `n` (subformula closure size) is typically 10-20, giving `soundFuel` of 10240-20*2^20 (capped at 100000). The practical performance depends on how quickly blocking fires.

**Recommendation**: For the REPL bridge, add an explicit per-query timeout (e.g., 500ms wall-clock) with early termination, returning `timeout` if exceeded. The `tableauFuel` parameter already provides fuel-based bounding, but wall-clock timeout gives a hard guarantee.

---

## 4. Proof Step Extraction Capabilities

### 4.1 ProofStepExtractor Module

`ProofStepExtractor.lean` provides a complete recursive tree walker that emits ordered `ProofStep` records from `DerivationTree` values:

```lean
structure ProofStep where
  theoremName : String
  stepIndex : Nat
  context : List Formula
  goal : Formula
  rule : String       -- one of 7: axiom, assumption, modus_ponens, necessitation,
                      --   temporal_necessitation, temporal_duality, weakening
  axiomName : Option String  -- non-null only when rule = "axiom"
  subgoals : List Formula
  frameClass : String

def extractStepSequence : DerivationTree fc Γ φ → (List ProofStep × Nat)
```

This directly supports the `#tableau_steps` command.

### 4.2 ProofTrace (Simplified Alternative)

`DatasetGenerator.lean` provides a lighter-weight `ProofTrace`:

```lean
structure ProofTrace where
  height : Nat
  axioms_used : List String
  rules_applied : List String
```

Plus `RuleProfile` for rule application counts. These are already JSON-serializable.

### 4.3 Integration Path for #tableau_steps

For a `#tableau_steps` command:
1. Parse formula JSON via `pFormula`
2. Run `decideAuto φ`
3. If `.valid proof`: call `extractStepSequence "query" (frameClassToString fc) 0 proof`
4. Serialize each `ProofStep` via `ProofStep.toJson`
5. Return JSON array of steps

The implementation is straightforward composition — no new algorithms needed.

---

## 5. Countermodel Extraction Capabilities

### 5.1 Two-Layer Architecture

The project has two countermodel types:

1. **SimpleCountermodel** (Layer 0): Atom-level — which atoms are true/false.
   ```lean
   structure SimpleCountermodel where
     trueAtoms : List Atom
     falseAtoms : List Atom
     formula : Formula
   ```
   Already has `toJson` and `display` methods.

2. **SemanticCountermodel** (Layer 1): Full finite model with worlds, times, temporal ordering, atom valuation.
   ```lean
   structure SemanticCountermodel where
     formula : Formula
     branch : Branch
     worlds : List WorldIndex
     times : List TimeIndex
     timeOrdering : TimeOrdering
     atomValuation : WorldIndex → TimeIndex → Atom → Bool
   ```
   Has a serializable summary (`SemanticCountermodelSummary`) with `toJson`.

3. **EnrichedCountermodel**: Full branch structure with modal/temporal formula subsets.
   Already has `toJson`.

### 5.2 Integration Path for #countermodel

For a `#countermodel` command:
1. Parse formula JSON via `pFormula`
2. Run `decideAuto φ`
3. If `.invalid cm`:
   - `cm.toJson` for simple countermodel
   - Optionally run `extractCountermodelData φ` for enriched + semantic data
4. If `.valid _`: return `{"status": "valid", "message": "No countermodel exists"}`
5. If `.timeout`: return `{"status": "timeout"}`

All JSON serialization is already implemented.

---

## 6. JSON Serialization Infrastructure

### 6.1 Comprehensive Coverage

The `DataExport.lean` module provides JSON serialization for all core types:

| Type | Method | Format |
|------|--------|--------|
| `Atom` | `Atom.toJson` | `{"base": "p", "fresh_index": null}` |
| `Formula` | `Formula.toJson` | `{"tag": "atom", "name": "p"}` etc. |
| `Formula` | `Formula.prettyPrint` | `"(p → q)"` |
| `Formula` | `Formula.toSExpr` | `"(imp (atom \"p\") (atom \"q\"))"` |
| `Formula` | `Formula.tokenize` | `["IMP", "ATOM", "p", "ATOM", "q"]` |
| `SimpleCountermodel` | `SimpleCountermodel.toJson` | `{"trueAtoms": [...], "falseAtoms": [...]}` |
| `ProofTrace` | `ProofTrace.toJson` | `{"height": 2, "axioms_used": [...]}` |
| `DifficultyMetrics` | `DifficultyMetrics.toJson` | `{"complexity": 3, ...}` |
| `RuleProfile` | `RuleProfile.toJson` | `{"axiom": 2, "modus_ponens": 1, ...}` |
| `PatternKey` | `PatternKey.toJson` | `{"modalDepth": 1, ...}` |
| `LabeledFormula` | `LabeledFormula.toJson` | Full record with all fields |
| `ProofStep` | `ProofStep.toJson` | `{"theorem_name": "...", ...}` |
| `EnrichedCountermodel` | `EnrichedCountermodel.toJson` | Full branch structure |
| `SemanticCountermodelSummary` | `toJson` | `{"worlds": [...], "times": [...]}` |

All serialization uses simple string concatenation with `escapeJsonString` — no external JSON library required.

### 6.2 String Helpers

`DataExport.lean` provides:
- `escapeJsonString`: Handles `"`, `\`, `\n`
- `listToJsonArray`: Wraps items in `[...]`

---

## 7. Formula Parsing from JSON Input

### 7.1 Existing Parser: pFormula

`BenchmarkOracle.lean` contains a complete hand-rolled recursive-descent JSON parser:

```lean
partial def pFormula (st : PState) : Except String (Formula × PState)
```

Supported tags: `atom`, `bot`, `imp`, `box`, `untl`, `snce`.

This parser handles the same `formula_ast` JSON schema used throughout the pipeline:
```json
{"tag": "imp", "left": {"tag": "atom", "name": "p"}, "right": {"tag": "atom", "name": "q"}}
```

### 7.2 Formula Convenience Constructor

`Formula.atom_s (s : String)` creates an atom from a bare string, used extensively in tests.

### 7.3 No S-expression Parser

While `Formula.toSExpr` produces S-expression output, there is no `fromSExpr` parser. If BimodalHarness uses S-expression input, one would need to be written. However, JSON is the standard interchange format.

### 7.4 Parser Performance

The parser is `partial def` (not termination-checked), uses `Array Char` indexing, and runs in O(n) where n is input string length. For typical formula JSON strings (< 1KB), parsing takes microseconds — negligible compared to tableau expansion.

---

## 8. BimodalHarness Integration Context

### 8.1 Current Integration: Artifact-Only

Per `docs/training/PIPELINE.md`, BimodalHarness integration is currently **artifact-only** — data flows via JSONL files, not live queries. The `bridge.py` in BimodalHarness's `lean/` directory is described as "currently stub."

### 8.2 Desired Integration: Live Oracle

The task description asks for a live Lean oracle that BimodalHarness can query during BFS and MCTS search. This means:

- BimodalHarness spawns a Lean executable as a subprocess
- Sends formula JSON on stdin, receives result JSON on stdout
- Target: <500ms per round-trip
- Three command types: `#tableau_decide`, `#tableau_steps`, `#countermodel`

### 8.3 Z3 Oracle Precedent

The `z3_oracle/` package implements the same pattern for Z3-based countermodel search:
- `Z3OracleProvider` class with `is_valid()`, `find_countermodel()`, `find_countermodels_batch()` methods
- Uses the same `formula_ast` JSON schema
- Per-formula timeout support (default 5000ms)

The Lean REPL bridge should follow the same `OracleProvider` protocol pattern.

---

## 9. Proposed REPL Protocol

### 9.1 Wire Format

JSONL protocol over stdin/stdout (one JSON object per line):

**Request**:
```json
{"command": "tableau_decide", "formula": {"tag": "imp", ...}, "frame_class": "Base", "timeout_ms": 500}
{"command": "tableau_steps", "formula": {"tag": "imp", ...}, "frame_class": "Base"}
{"command": "countermodel", "formula": {"tag": "imp", ...}, "frame_class": "Base"}
{"command": "ping"}
{"command": "shutdown"}
```

**Response**:
```json
{"status": "valid", "proof_trace": {...}, "metrics": {...}, "time_ms": 12}
{"status": "invalid", "countermodel": {...}, "metrics": {...}, "time_ms": 5}
{"status": "timeout", "time_ms": 500}
{"status": "error", "message": "parse error: ..."}
{"status": "pong"}
```

### 9.2 Command Dispatch

| Command | Action | Lean Function |
|---------|--------|---------------|
| `tableau_decide` | Decide validity, return label + proof/countermodel | `decideAuto` or `decide` with fuel param |
| `tableau_steps` | If valid, extract ordered proof steps | `extractStepSequence` on proof |
| `countermodel` | If invalid, extract countermodel | `extractCountermodelSimple` + enriched |
| `ping` | Health check | Return `{"status": "pong"}` |
| `shutdown` | Clean exit | `return ()` |

### 9.3 Optional Enhancements

- `batch` command: accept multiple formulas in one request
- `label` command: full `labelFormula` output (combines all three)
- Configurable fuel/depth per request

---

## 10. Implementation Architecture

### 10.1 New File: `Theories/Bimodal/Automation/TableauBridge.lean`

This file would contain:

1. **Request parsing**: Extend `pFormula` to parse the outer request envelope (command, timeout, frame_class)
2. **Response formatting**: JSON response builders for each command
3. **Command dispatch**: Route to appropriate handler
4. **REPL loop**: `IO.getStdin >>= fun h => while true do h.getLine >>= processLine`

### 10.2 New Executable Target in lakefile.lean

```lean
lean_exe tableau_bridge where
  root := `Bimodal.Automation.TableauBridge
  srcDir := "Theories"
  supportInterpreter := true
```

### 10.3 Dependencies

The bridge module imports:
- `Bimodal.Automation.DatasetGenerator` (for `labelFormula`, `ProofTrace`, etc.)
- `Bimodal.Automation.DataExport` (for JSON serialization)
- `Bimodal.Automation.ProofStepExtractor` (for proof step extraction)
- `Bimodal.Automation.BenchmarkOracle` (for `pFormula` JSON parser)
- `Bimodal.Automation.EnrichedCountermodel` (for enriched countermodel)

All imports are within the Automation module — no new Mathlib or external dependencies needed.

### 10.4 Startup and Initialization

The executable should:
1. Print a ready message to stderr (so Python can detect readiness)
2. Enter the stdin read loop
3. Process one JSON request per line
4. Write one JSON response per line to stdout
5. Flush stdout after each response

---

## 11. Performance Analysis for <500ms Target

### 11.1 Component Timing Breakdown

| Component | Typical Time | Notes |
|-----------|-------------|-------|
| Lean executable startup | 100-300ms | One-time cost; amortized by REPL loop |
| Formula JSON parse | <1ms | `pFormula` on typical input |
| `tryAxiomProof` (fast path) | <1ms | Pattern match against 42 axioms |
| `bounded_search_with_proof` | 1-50ms | For depth <= 10 |
| `buildTableau` (easy) | 1-10ms | Complexity <= 3 |
| `buildTableau` (medium) | 10-100ms | Complexity 4-6 |
| `buildTableau` (hard) | 50-500ms | Complexity 7-9 |
| `extractProof` | 1-50ms | 5-strategy pipeline |
| `extractStepSequence` | <5ms | Tree walk |
| `extractCountermodelSimple` | <1ms | Branch filter |
| JSON response formatting | <1ms | String concatenation |

### 11.2 Performance Strategy

1. **Keep the process alive**: REPL loop avoids 100-300ms Lean startup per query
2. **Use `decideAuto`**: Sound fuel bound already constrains worst case
3. **Add wall-clock timeout**: Use `IO.monoMsNow` to check elapsed time, return `timeout` if exceeded
4. **Configurable fuel override**: Allow `timeout_ms` and `max_fuel` per request
5. **Short-circuit on fast path**: `tryAxiomProof` returns instantly for axiom instances

### 11.3 Risk: Fuel vs. Wall-Clock

`soundFuel` for a complexity-8 formula can be up to 100000 steps. Each step is cheap (microseconds), but 100000 steps at 5us each = 500ms. Mitigation: allow per-query fuel override and wall-clock timeout.

---

## 12. Gaps and Recommendations

### 12.1 What Exists (Reusable As-Is)

- Formula JSON parser (`pFormula` in BenchmarkOracle.lean)
- Decision procedure (`decideAuto` in DecisionProcedure.lean)
- Proof step extraction (`extractStepSequence` in ProofStepExtractor.lean)
- Countermodel extraction (simple, enriched, semantic)
- All JSON serialization (DataExport.lean, DatasetGenerator.lean)
- Wall-clock timing (`IO.monoMsNow`)

### 12.2 What Needs to Be Built

1. **REPL loop with stdin/stdout** — New module `TableauBridge.lean`
2. **Request envelope parser** — Extend `pFormula` to parse `{"command": ..., "formula": ..., "frame_class": ..., "timeout_ms": ...}`
3. **Response formatters** — JSON builders for each command's response type
4. **lakefile.lean executable entry** — `lean_exe tableau_bridge`
5. **Wall-clock timeout wrapper** — Check `IO.monoMsNow` during tableau expansion
6. **Frame class parser** — Parse `"Base"`, `"Dense"`, `"Discrete"` from JSON

### 12.3 What Is Missing from the Codebase

- **No stdin read loop** — Must be implemented from scratch using `IO.getStdin` and `IO.FS.Stream.getLine`
- **No wall-clock timeout in tableau** — `buildTableau` uses fuel but not wall-clock; adding a `checkTimeout` callback would require threading IO through the pure tableau function, which is undesirable. Better to add a timeout wrapper around the entire `decideAuto` call.
- **No FrameClass parser** — Need a small `parseFrameClass : String → Option FrameClass` function
- **No request envelope parser** — The existing `pFormula` only parses the formula AST, not the outer request JSON. Need to extend the parser.

### 12.4 Architectural Recommendations

1. **Single-file implementation**: Everything in one `TableauBridge.lean` file, importing existing modules
2. **JSONL protocol**: One request per line, one response per line — simplest possible protocol, matches BimodalHarness JSONL patterns
3. **No multithreading**: Process queries sequentially. BimodalHarness can manage parallelism on its side (multiple bridge processes)
4. **Ready signal**: Print `{"status": "ready"}` to stdout on startup so BimodalHarness knows the process is initialized
5. **Graceful shutdown**: Handle `shutdown` command and stdin EOF cleanly

### 12.5 Testing Strategy

1. **Unit test**: Add test formulas to `BimodalTest/` that exercise each command
2. **Integration test**: Shell script that pipes JSON requests and checks responses
3. **Performance benchmark**: Time 100 formulas of varying complexity, verify P95 < 500ms

### 12.6 BimodalHarness Side

The Python `lean/bridge.py` stub needs:
- Subprocess management (spawn `lake exe tableau_bridge`, read stdout, write stdin)
- `LeanOracleProvider` class implementing the same `OracleProvider` protocol as `Z3OracleProvider`
- Timeout handling (kill and restart process if stuck)
- Connection pooling (optional: maintain N bridge processes for parallelism)

This is out of scope for this Lean-side task but should be coordinated.

---

## 13. Dependency Analysis

### 13.1 Import Graph for New Module

```
TableauBridge.lean
  ├── Bimodal.Automation.DatasetGenerator    (labelFormula, ProofTrace, etc.)
  ├── Bimodal.Automation.DataExport          (JSON serialization)
  ├── Bimodal.Automation.ProofStepExtractor  (proof step extraction)
  ├── Bimodal.Automation.BenchmarkOracle     (pFormula parser)
  └── Bimodal.Automation.EnrichedCountermodel (enriched countermodel)
```

All within `Theories/Bimodal/Automation/` — no new external dependencies.

### 13.2 Build Time Impact

The new module adds no new compilation beyond its own file. Existing modules compile independently. Expected incremental build time: <30 seconds.

---

## 14. Summary of Findings

| Research Goal | Finding |
|--------------|---------|
| Existing REPL | None — all executables are batch-mode |
| DecisionProcedure interface | Clean API via `decideAuto`, returns proof/countermodel/timeout |
| Proof step extraction | Complete via `extractStepSequence`, JSON-serializable |
| Countermodel extraction | Three layers (simple, enriched, semantic), all JSON-serializable |
| JSON infrastructure | Comprehensive — covers all types needed |
| Formula parsing | Hand-rolled JSON parser exists (`pFormula` in BenchmarkOracle) |
| Performance for <500ms | Achievable for complexity <= 8; needs wall-clock timeout for safety |
| Implementation effort | Moderate — ~200-400 lines of new Lean code, primarily plumbing |

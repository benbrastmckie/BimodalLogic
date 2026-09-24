# BimodalTools

The tooling half of this repository: formula enumeration, dataset generation and labelling,
JSON export, benchmark harnesses, and the trace-certificate exporter. Split out of
`FormalSystem/Automation/` and `FormalSystem/Metalogic/Decidability/` so that the published
library carries only the logic.

`BimodalTools` is a `lean_lib` deliberately **outside `defaultTargets`**. A plain `lake build`
compiles `FormalSystem` and nothing here. The tooling is built by `lake build BimodalTools`,
by `lake build BimodalToolsTest`, or by any of the 12 `lake exe` targets whose roots live here.

## Direction of dependence

`BimodalTools` imports `FormalSystem`. `FormalSystem` never imports `BimodalTools`, and check
`B3` in `scripts/check-module-invariants.sh` asserts it. The converse direction is the
sanctioned one and is not gated.

## Module naming

The conventions inherited from `FormalSystem/Automation/README.md` still hold here:

- **Executable roots are `PascalCase(target) ++ "Main"`.** The root of `lake exe foo_bar` is
  `FooBarMain`. Every root declares a root-namespace `main`, so two of them cannot be imported
  into one environment — which is why `BimodalTools.lean` imports no `*Main` module.
- **`Main` is reserved.** No module that is not an executable root ends in `Main`.
- **A library is named for what it produces.** `XExport` is the JSON serialization layer for X
  (`DataExport`, `TraceExport`); `XAssembly` assembles a structured artifact
  (`DatasetAssembly`); `XExtractor` extracts (`ProofStepExtractor`); `XGenerator` generates
  (`DatasetGenerator`, `ForwardProofGenerator`).

## Tableau bridge protocol

`lake exe tableau_bridge` is a persistent REPL speaking JSONL over stdin/stdout: one JSON request
per line in, one JSON response per line out. It is the differential oracle a model checker can
query for the bimodal theory. The protocol lives in `TableauBridge.lean`'s module docstring; this
section records the two parts a consumer has to get right.

**Frame class.** `frame_class` accepts exactly `"Base"`, `"Dense"`, `"ZTime"`, `"Discrete"` (an
alias for `"ZTime"`) and `"RTime"` (the Dedekind class — incomparable with `ZTime`, not a
superclass of it). The key may be omitted, and then defaults to `"Base"`. Any *other* value is
rejected with `{"status": "error", "message": "unknown frame_class: ..."}`, and the REPL stays
alive for the next line. Earlier revisions silently coerced every unrecognized string — including
`"RTime"` — to `.Base`, so a request could be answered at a frame class it never asked for.

**Theorem-backed vs. heuristic invalidity.** An `invalid` response from `tableau_decide` or
`countermodel` carries an additive `"gates"` object:

```json
{"status": "invalid",
 "countermodel": {...},
 "gates": {"time_order_total": true, "box_anchored_check": true,
           "region_label_check": true, "temporal_witness_check": true,
           "branch_order_valid": true, "saturated": true,
           "no_closure": true, "root_denied": true,
           "gated": true},
 "formula_string": "(p → q)",
 "time_ms": 3}
```

The eight booleans are the hypotheses of `not_valid_of_hasOpen_int` and
`not_validZTime_of_hasOpen_int`
(`FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean`), evaluated on the open
saturated branch the verdict came from; `"gated"` is their conjunction.

- `"gated": true` — the verdict is **theorem-backed**: those results apply to this branch, and the
  formula's invalidity may be cited through them.
- `"gated": false` — the verdict is **heuristic**: it is the decision procedure's own, with no
  theorem behind it. It is not a claim that the formula is valid. At `"ZTime"` today
  `region_label_check` and `temporal_witness_check` are measured `false` on open branches, so
  `"gated"` is `false` there; surfacing that is the field's purpose.

`"status": "invalid"` and every pre-existing field are unchanged — `"gates"` is purely additive,
so a consumer that ignores the key is unaffected. The rows pinning all of this are
`Tests/BimodalToolsTest/TableauBridgeTest.lean`.

## Contents

<!-- BEGIN GENERATED: inventory dir=BimodalTools -->
| File | Lines | Description |
|------|------:|-------------|
| `AtomCanonicalization.lean` | 141 | <!-- TODO: add description --> |
| `AxiomNames.lean` | 59 | <!-- TODO: add description --> |
| `BenchmarkAnchorsMain.lean` | 598 | <!-- TODO: add description --> |
| `BenchmarkOracleMain.lean` | 359 | <!-- TODO: add description --> |
| `ContrastiveGenerator.lean` | 1,025 | The formula-mutation engine: `MutationType`, `ContrastivePair`, the single-occurrence mutators, `generateContrastivePairs`, and the contrastive JSONL export |
| `ContrastiveGeneratorMain.lean` | 122 | Executable root of `lake exe contrastive_generator`: argument parsing and `main` only; imports `ContrastiveGenerator` |
| `DataExport.lean` | 396 | <!-- TODO: add description --> |
| `DatasetAssembly.lean` | 342 | <!-- TODO: add description --> |
| `DatasetGenerator.lean` | 1,728 | <!-- TODO: add description --> |
| `DatasetGeneratorMain.lean` | 1,349 | <!-- TODO: add description --> |
| `DatasetValidatorMain.lean` | 595 | <!-- TODO: add description --> |
| `EnrichedCountermodel.lean` | 223 | <!-- TODO: add description --> |
| `EnumBenchmarkMain.lean` | 230 | <!-- TODO: add description --> |
| `FormulaEnumerator.lean` | 2,041 | <!-- TODO: add description --> |
| `ForwardProofGenerator.lean` | 354 | <!-- TODO: add description --> |
| `InterestingnessMetrics.lean` | 576 | <!-- TODO: add description --> |
| `MachineAppendixMain.lean` | 474 | <!-- TODO: add description --> |
| `PrefilterSoundness.lean` | 172 | <!-- TODO: add description --> |
| `ProofExtractorMain.lean` | 1,542 | <!-- TODO: add description --> |
| `ProofFirstBenchmark.lean` | 194 | <!-- TODO: add description --> |
| `ProofFirstGenerator.lean` | 160 | The proof-first export pipeline: `exportToJsonl`, `writeJsonl`, the argument parsers, and `runProofFirstGenerator`, the whole command-line body |
| `ProofFirstGeneratorMain.lean` | 21 | Executable root of `lake exe proof_first_generator`: `main` only; calls `runProofFirstGenerator` |
| `ProofStepExtractor.lean` | 344 | <!-- TODO: add description --> |
| `TableauBridge.lean` | 840 | The tableau bridge library: the JSONL protocol, the request parsers, `BranchGates` and the theorem-hypothesis evaluator, the command handlers, and `replLoop` |
| `TableauBridgeMain.lean` | 23 | Executable root of `lake exe tableau_bridge`: `main` only; calls `TableauBridge.replLoop` |
| `TableauProofStepsMain.lean` | 688 | <!-- TODO: add description --> |
| `TraceExport.lean` | 229 | <!-- TODO: add description --> |
| `TraceExporterMain.lean` | 265 | <!-- TODO: add description --> |
<!-- END GENERATED -->

*Last verified: 2026-09-24*

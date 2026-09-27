# BimodalTools

The tooling half of this repository: formula enumeration, dataset generation and labelling,
JSON export, benchmark harnesses, and the trace-certificate exporter. Split out of
`FormalSystem/Automation/` and `FormalSystem/Metalogic/Decidability/` so that the published
library carries only the logic.

`BimodalTools` is a `lean_lib` deliberately **outside `defaultTargets`**. A plain `lake build`
compiles `FormalSystem` and nothing here. The tooling is built by `lake build BimodalTools`,
by `lake build BimodalToolsTest`, or by any of the `lake exe` targets whose roots live here.

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

## Certificate re-verification protocol

`lake exe check_certificate` reads **one** witness-family certificate as a JSON object on stdin
and prints **one** JSON line on stdout. It is the re-verification half of the dual-verification
architecture: the model checker emits a certificate, this binary decides whether it is one.

The field names mirror the Lean structures exactly, which
`FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` states is an export contract
rather than a local naming choice — renaming `back`, `mid`, `fwd`, `bx`, `lassos` or `target` is
a breaking change on the producing side. The mirror is structural as well as nominal: `premises`,
`conclusions` and `time` are the three data of the one predicate `Target`, so they are grouped
under one `"target"` object rather than flattened into the envelope.

**Input.**

```json
{"target":      {"premises":    [<formula>, ...],
                 "conclusions": [<formula>, ...],
                 "time":        0},
 "bx":          [[<formula>, true], [<formula>, false], ...],
 "lassos":      [{"back": [<label>, ...], "mid": [<label>, ...], "fwd": [<label>, ...]}, ...]}
```

| Field | Meaning |
|-------|---------|
| `target` | **required**: the target condition, the three data of `WitnessFamily.Target` |
| &nbsp;&nbsp;`target.premises` | optional, default `[]`: the premise context `Γ` |
| &nbsp;&nbsp;`target.conclusions` | optional, default `[]`: the conclusion context `Δ` |
| &nbsp;&nbsp;`target.time` | **required**: the target time `t` at which the consequence fails |
| `bx` | the box guess, as `[formula, bool]` pairs; any formula not listed reads as `false` |
| `lassos` | the labelled bi-lassos; lasso `0` is the main one, where the target is read |
| `back` / `mid` / `fwd` | a lasso's three segments, each a list of **labels** |

**`target.time` is required, and deliberately so.** `Target Γ Δ` is an existential — *some* `t`
with `Γ ⊆ L₀ t` and `Δ ∩ L₀ t = ∅` — and `t` is its witness. Every other existential in a
certificate is explicitly witnessed: the box guess witnesses which boxes are false, the lassos
witness the falsifying histories, the labels witness the types. A defaulted `t` would leave the
outermost existential the only unwitnessed one, against the whole point of a certificate, which
is that checking requires no search. And `0` denotes the origin only by the three-segment
decoding convention of `LabelledLasso`; were that convention ever re-indexed, a defaulted `0`
would silently change the meaning of every stored certificate. `premises` and `conclusions` keep
their `[]` defaults because `[]` is the identity of a context; `0` is not the identity of a time.

A `<label>` is a list of `<formula>`, read as a set. A `<formula>` is the tag format
`Formula.toJson` emits and `BimodalTools/JsonParse.lean`'s `pFormula` parses: `atom` (with
`name`), `bot`, `imp` (`left`, `right`), `box` (`child`), `untl` and `snce` (each with `event`
and `guard`). Unknown object fields are skipped, so a producer may attach metadata this checker
does not read.

**Atom names round-trip on `Atom.base` only.** `Formula.toJson` drops `Atom.freshIndex`, so a
fresh-indexed atom would silently change identity — and `Finset Formula` membership is by
`DecidableEq`. A certificate carrying one is therefore rejected outright rather than decoded.

**Output.** Exactly one JSON line, and **never a validity claim**:

```json
{"status": "countermodel", "time": 0}
```

```json
{"status": "rejected",
 "failed": [{"condition": "fulfilling", "lasso": 0, "position": -2,
             "formula": {"tag": "untl", "event": {...}, "guard": {...}},
             "detail": "this eventuality is never discharged"}]}
```

```json
{"status": "error", "message": "expected '\"' got 'n' at pos 2"}
```

`condition` is one of `structural`, `local_coherent`, `fulfilling`, `box_faithful`, `target`, or
`unlocalized`. `lasso`, `position` and `formula` are `null` when the failure is not tied to one.
A structural violation — an empty `back` or `fwd`, an empty `lassos` list, a label outside
`closureOf (Γ ++ Δ)`, a fresh-indexed atom — is certificate *content* that fails a precondition,
so it is `rejected`. `error` covers the two ways input fails the *protocol* rather than a
condition: input that does not parse, and input that parses but omits a required field. In
particular, a certificate lacking `"target"`, or lacking `"target"."time"`, is answered
`{"status":"error", "message": ...}` — never `{"status":"rejected"}` — with a distinct message
for each of the two omissions. A producing exporter can be written against this section alone:
emit the object above with both required fields present, and `rejected` then means what it says.

**What acceptance means.** `countermodel` says the four compiled `Decidable` instances that
`WitnessFamily.joint_countermodel` consumes — `decidableLocalCoherentLab`,
`decidableFulfillingLab`, `decidableBoxFaithful` and `decidableTarget` — all returned `true` on
the family rebuilt from this input. It is not a kernel-checked proof for that particular
certificate. The same honesty the `"gates"` field above carries for the tableau bridge.

`rejected` says only that the object handed over is not a certificate. It never says the
consequence holds: the checker is one-sided by construction.

Acceptance is now dual-decided per run rather than single-sided: the producing side also
re-decides each reported countermodel independently in Python and cross-checks that result
against this executable where present, so a single-sided `accepted` here is no longer the only
check a reported countermodel receives.

The rows pinning all of this are `Tests/BimodalToolsTest/CertificateImportTest.lean`.

## Contents

<!-- BEGIN GENERATED: inventory dir=BimodalTools -->
| File | Lines | Description |
|------|------:|-------------|
| `AtomCanonicalization.lean` | 141 | <!-- TODO: add description --> |
| `AxiomNames.lean` | 59 | <!-- TODO: add description --> |
| `BenchmarkAnchorsMain.lean` | 598 | <!-- TODO: add description --> |
| `BenchmarkOracleMain.lean` | 359 | <!-- TODO: add description --> |
| `CertificateImport.lean` | 658 | The certificate library: `closureList`/`intRange`, the `RawCertificate` records, the envelope parser and serializer, the `dite`-based `WitnessFamily` builders, `checkRaw` and the localization scans |
| `CheckCertificateMain.lean` | 48 | Executable root of `lake exe check_certificate`: `main` only; reads one certificate on stdin, prints one JSON line |
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
| `JsonParse.lean` | 258 | The tag-format JSON parser: `PState`, the scalar and skip primitives, and `pFormula`; shared by the tableau bridge and the certificate checker |
| `MachineAppendixMain.lean` | 474 | <!-- TODO: add description --> |
| `PrefilterSoundness.lean` | 172 | <!-- TODO: add description --> |
| `ProofExtractorMain.lean` | 1,542 | <!-- TODO: add description --> |
| `ProofFirstBenchmark.lean` | 194 | <!-- TODO: add description --> |
| `ProofFirstGenerator.lean` | 160 | The proof-first export pipeline: `exportToJsonl`, `writeJsonl`, the argument parsers, and `runProofFirstGenerator`, the whole command-line body |
| `ProofFirstGeneratorMain.lean` | 21 | Executable root of `lake exe proof_first_generator`: `main` only; calls `runProofFirstGenerator` |
| `ProofStepExtractor.lean` | 344 | <!-- TODO: add description --> |
| `TableauBridge.lean` | 627 | The tableau bridge library: the JSONL protocol, the request parsers, `BranchGates` and the theorem-hypothesis evaluator, the command handlers, and `replLoop` |
| `TableauBridgeMain.lean` | 23 | Executable root of `lake exe tableau_bridge`: `main` only; calls `TableauBridge.replLoop` |
| `TableauProofStepsMain.lean` | 688 | <!-- TODO: add description --> |
| `TraceExport.lean` | 229 | <!-- TODO: add description --> |
| `TraceExporterMain.lean` | 265 | <!-- TODO: add description --> |
<!-- END GENERATED -->

*Last verified: 2026-09-27*

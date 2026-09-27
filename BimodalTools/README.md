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
{"status": "countermodel", "time": 0, "acceptance": "entailment"}
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

**The `acceptance` key.** It appears on `countermodel` only. `rejected` and `error` are
byte-identical to what they were before the key existed, and **the input schema above is not
touched at all** — this is an output-side addition, exactly as `"gates"` was for the tableau
bridge.

| Value | Meaning |
|-------|---------|
| `"entailment"` | Lean constructed a term of `WitnessFamily.Refutes Γ Δ` for this target, by applying a build-time kernel-checked implication to the four decisions |
| `"decided"` | four decision procedures returned `true`, and that is the whole of the claim |

**An absent `acceptance` field must be read as `"decided"`.** This is the rule that makes the key
non-breaking: every verdict emitted by a binary predating the key, and every verdict already
stored on disk, remains valid under it, and a re-implementation that decides the four conditions
without constructing anything — the producing side's pure-Python re-checker, for instance — is
correct to emit `"decided"` or to omit the key entirely. A consumer must therefore default rather
than reject on absence, and the two repositories can land this change in either order.

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

**What acceptance means.** `countermodel` is the erasure of a **constructed term** of
`WitnessFamily.Refutes Γ Δ` — the joint existence statement: an explicit ℤ-time frame, model,
world history and time at which every premise is true and every conclusion false. The accepting
branch of `BimodalTools.CertificateImport.checkCertified` carries that statement as a field of its
constructor, so it cannot be taken without one, and
`BimodalTools.CertificateImport.refutes_of_countermodel` recovers the statement from the printed
verdict alone. That is what `"acceptance": "entailment"` reports.

Precisely what is and is not checked:

- **Kernel-checked, once, at build time**: the *implication*
  `WitnessFamily.refutes_of_certifies`, from the four conditions holding of a family to the
  existence of a countermodel. Lean elaborates it when the library compiles.
- **Decided at run time, per certificate**: the *hypothesis* — by the four compiled `Decidable`
  instances `decidableLocalCoherentLab`, `decidableFulfillingLab`, `decidableBoxFaithful` and
  `decidableTarget`, composed by `decidableCertifies`, on the family rebuilt from this input.
- **Residual trust base**: Lean's compiler, and this executable's decoding of the wire object into
  the family the sender meant.
- **Not** per-certificate kernel checking. That would mean re-elaborating a generated statement
  for each certificate, which this binary does not do. The gain over the previous contract is that
  composing the decided conditions with the agreement theorem is no longer left to the reader —
  it is a checked term — not that the compiler has left the trust base.

`rejected` says only that the object handed over is not a certificate. It never says the
consequence holds: the checker is one-sided by construction.

Acceptance is also dual-decided per run rather than single-sided: the producing side re-decides
each reported countermodel independently in Python and cross-checks that result against this
executable where present, so a single-sided `accepted` here is no longer the only check a reported
countermodel receives.

**The downstream payoff is jointly gated, and has not landed yet.** The producing side's
pure-Python re-checker becoming a fast *pre-filter* rather than part of the trust base needs two
things, and this change is only one of them: (1) the accepting branch constructing the entailment,
which is what `"acceptance": "entailment"` now reports; and (2) a Lean-side echo of the parsed
certificate compared against the bytes actually sent, so that the residual decoding step above is
itself pinned rather than trusted. Until (2) lands, a consumer that drops its own re-check is
trusting this executable's decoding, which is exactly the gap (2) closes. That work is separate
from this protocol change.

The rows pinning all of this are `Tests/BimodalToolsTest/CertificateImportTest.lean`.

## Source-sentence translation protocol

`lake exe translate_sentence` reads **one** source-sentence JSON object on stdin and prints **one**
JSON line on stdout: the translated formula, in the same tag vocabulary the certificate protocol
above already uses.

It exists because `FormalSystem/SourceLanguage/` proves a theorem about an *encoding*
(`sat_iff`: the source language's seventeen operators, evaluated natively, agree with
`Semantics.TruthAt` of their six-primitive image, at every frame, model, history and time) while the
thing that could be wrong is an *implementation* of that encoding in another repository. This binary
is the only link between the two that does not rely on someone reading Lean.

**Input** — one tag per `Sentence` constructor, spelled as the constructor is:

| Tag | Fields |
|-------|--------|
| `atom` | `name` (base name only; a fresh-indexed atom is rejected at the wire, both sides) |
| `bot`, `top` | — |
| `neg`, `box`, `allFut`, `allPast`, `dia`, `someFut`, `somePast`, `next`, `prev` | `child` |
| `wedge`, `vee`, `cond`, `bicond` | `left`, `right` |
| `untl`, `snce` | `guard`, `event` |

`untl`/`snce` carry **named** `guard`/`event` fields, as on the `Formula` side, so the wire is
order-free even though the constructor is not. Unknown object fields are skipped, so a producer may
attach metadata a consumer does not read.

**Output.** On success, the translated formula's own JSON object — not a wrapper — so a fixture's
expected field is directly comparable. On failure, `{"error": "..."}`. The two are distinguishable
without a schema: a formula object carries `tag` and no `error`.

```bash
echo '{"tag": "cond", "left": {"tag": "atom", "name": "p"}, "right": {"tag": "atom", "name": "q"}}' \
  | lake exe translate_sentence
# {"tag": "imp", "left": {"tag": "imp", "left": {"tag": "imp", ...
```

**Three rows are not the obvious operator, and that is the point.** The source repository routes
`\rightarrow` through `¬A ∨ B`, so a conditional's image is `Formula.or (neg A) B` — a doubly
negated antecedent — and **not** `Formula.imp A B`; and its existential tenses are `¬G¬`/`¬H¬`, so
their images are the negated universal tenses and **not** `Formula.someFuture`/`Formula.somePast`.
The alternatives are semantically equivalent and are different formulas, hence different subformula
closures, hence different certificate label domains.
`FormalSystem/SourceLanguage/Sentence.lean`'s `tr_cond_ne`, `tr_someFut_ne` and `tr_somePast_ne`
record the inequalities by proof, and
`Tests/BimodalTest/Syntax/SentenceTranslationTest.lean` pins every row of the table by `#guard`.

### The fixture file, and the hand-off

`Tests/fixtures/sentence-translation-fixtures.jsonl` is the shared artifact. One object per line:

| Field | Meaning |
|-------|---------|
| `surface` | the source repository's surface form of the sentence |
| `kind` | `primitive`, `defined`, `asymmetry` or `nesting` — which group the row belongs to |
| `sentence` | the source-sentence JSON, in the vocabulary above |
| `formula` | the expected translated-formula JSON |

**What this repository asserts**: `Tests/BimodalToolsTest/SentenceCodecTest.lean` checks, per line,
that `pSentence` parses `sentence`, that `Sentence.toJson` of the result reproduces `sentence`
exactly, and that `tr` of it serializes to `formula`.

**What the consuming repository must assert**: that its own translation of `surface` serializes to
`formula` for every line — equivalently, that it reproduces `lake exe translate_sentence`'s output
on `sentence`. That assertion belongs in that repository and is deliberately not written from here;
the fixture file plus this section is what that work consumes.

**Comparison is on parsed JSON, never on bytes.** `Formula.toJson` emits `", "` and `": "`
separators, which Python's `json.dumps` defaults happen to match. Nothing guarantees that, and
neither side promises byte stability — a consumer comparing serialized text is testing the separator
convention, not the translation.

**The channel is one-directional.** `tr_not_injective` proves the elimination is not injective: each
defined operator is sent onto the abbreviation it stands for, so a translated formula does not
determine the sentence it came from. There is no inverse pass to check. What round-trips is the
source side alone.

**Scope.** A reproduced fixture set means the two implementations agree with each other *and* with a
theorem about the encoding. It does not certify the consuming repository's code, and it does not
discharge that repository's own verification obligation for its translation, which is an
implementation obligation and stays where it is.

## Contents

<!-- BEGIN GENERATED: inventory dir=BimodalTools -->
| File | Lines | Description |
|------|------:|-------------|
| `AtomCanonicalization.lean` | 141 | <!-- TODO: add description --> |
| `AxiomNames.lean` | 59 | <!-- TODO: add description --> |
| `BenchmarkAnchorsMain.lean` | 598 | <!-- TODO: add description --> |
| `BenchmarkOracleMain.lean` | 359 | <!-- TODO: add description --> |
| `CanonicalWire.lean` | 32 | Aggregator for `CanonicalWire/`: the verified certificate wire codec — canonical printer, total parser, round-trip theorems |
| `CertificateImport.lean` | 792 | The certificate library: `closureList`/`intRange`, the `RawCertificate` records, the envelope parser and serializer, the `dite`-based `WitnessFamily` builders, `checkRaw` and the localization scans |
| `CheckCertificateMain.lean` | 57 | Executable root of `lake exe check_certificate`: `main` only; reads one certificate on stdin, prints one JSON line |
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
| `SentenceExport.lean` | 244 | The source-sentence codec: `Sentence.toJson`, `pSentence`, and `translateSentenceLineToJson` — parse, eliminate the defined operators with `tr`, serialize; the conformance channel behind `lake exe translate_sentence` |
| `TableauBridge.lean` | 627 | The tableau bridge library: the JSONL protocol, the request parsers, `BranchGates` and the theorem-hypothesis evaluator, the command handlers, and `replLoop` |
| `TableauBridgeMain.lean` | 23 | Executable root of `lake exe tableau_bridge`: `main` only; calls `TableauBridge.replLoop` |
| `TableauProofStepsMain.lean` | 688 | <!-- TODO: add description --> |
| `TraceExport.lean` | 229 | <!-- TODO: add description --> |
| `TraceExporterMain.lean` | 265 | <!-- TODO: add description --> |
| `TranslateSentenceMain.lean` | 51 | Executable root of `lake exe translate_sentence`: `main` only; reads one source-sentence JSON object on stdin, prints the translated formula as one JSON line |
| `CanonicalWire/` | — | The verified wire codec: `Json.lean` (canonical value, printer, fuel measure), `Parse.lean` (the total parser) (2 files) |
<!-- END GENERATED -->

*Last verified: 2026-09-27*

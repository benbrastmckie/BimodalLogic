# Diagnostics record schema

[Back to Reference](README.md)

One record schema covers every stage of the library pipeline. A record is **keyed by the
statement's identifier and the stage**, and carries the fragment, the frame class, the commit and
the command that produced it. That shared head is the same for all seven stages; each stage adds
its own payload.

The schema is `BimodalLib/Diagnostics/Record.lean`. The two implemented emitters are
`BimodalLib/Diagnostics/Emit.lean`. A stage is not complete until its fields are documented on
this page, so this page is where a new stage's payload is agreed before its emitter is written.

**Audience**: anyone writing or reading a pipeline stage's emitter, or consuming
`data/proof-mode-diagnostics.jsonl`.

## Keying

| | |
|---|---|
| Key | `(statement, stage)` — one record per statement per stage |
| Serialization | one JSON object per line (JSONL), snake_case at the top level |
| Sidecar | `data/proof-mode-diagnostics_metadata.json`, carrying the `fields` array |
| Emission | printed to stdout by the emitter; collected by `scripts/proof-mode-cost-baseline.sh` |

No emitter writes a tracked file as an elaboration side effect. A command that did would be both
untestable and non-composable, and the collected dataset would have no single point at which it
could be validated.

The `fields` array of the sidecar is built by parsing the tables on this page, and the collecting
script fails if the key set on this page and the key set actually present in the emitted records
differ in either direction. That is what makes the page and the sidecar unable to drift apart:
not a convention, a check.

## Shared head

Every stage carries exactly these six fields, in this order.

#### shared head

| field | type | description |
|-------|------|-------------|
| `statement` | string | The registered declaration's fully-qualified name, which is the registry key; or `unregistered:<declaration>` for a statement with no registry row |
| `stage` | string enum | One of `enumerate`, `decide`, `extract`, `certify`, `admit`, `reprove`, `compare` |
| `fragment` | string | The fragment of the statement, read from its registry row; `unregistered` when it has none |
| `frame_class` | string | `Base`, `Dense`, `ZTime` or `RTime`, read off the declaration's own type; `schematic` when the type abstracts over the frame class |
| `commit` | string | The commit the record was measured at; `unstamped` when the stamp option was not set |
| `command` | string | The exact command line that produced the record; `unstamped` when the stamp option was not set |

`unregistered` and `unstamped` are deliberate sentinels rather than empty strings. A reader can
tell an unregistered mirror from a registry key, and an unstamped record from a stamped record
whose stamp was lost, at a glance.

## Implemented stages

### Re-prove

What a proof-mode script cost and what it rested on.

#### reprove

| field | type | description |
|-------|------|-------------|
| `outcome` | string enum | `closed_by_rules`, `closed_with_leaf_automation`, `closed_with_term_escape` or `not_closed` |
| `failure_class` | string enum or null | `missing_rule`, `missing_tactic`, `automation_too_weak`, `script_too_awkward`, `too_slow` or `defect_in_mode`; null exactly when the outcome is `closed_by_rules` |
| `tactic_count` | integer | Number of tactic invocations in the script |
| `distinct_tactics` | array of string | The distinct tactic names used, in first-use order |
| `escape_size` | integer | Node count of any term-mode escape; 0 when there is none |
| `heartbeats` | integer | Deterministic elaboration cost, in thousands of heartbeats |
| `elab_ms` | integer | Wall-clock elaboration time in milliseconds |
| `term_size` | integer | Node count of the whole declaration's elaborated value, without sharing |
| `derivation_size` | integer or null | Node count of the derivation built; null when the statement is schematic |
| `derivation_height` | integer or null | Height of the derivation built; null when the statement is schematic |
| `axioms` | array of string | The axiom set the declaration depends on |

### Compare

A script measured against a reference proof.

#### compare

| field | type | description |
|-------|------|-------------|
| `script_length` | integer | Length of the proof-mode script, in tactic invocations |
| `hand_proof_length` | integer | Length of the reference proof, in the same unit |
| `length_ratio` | decimal or null | `script_length` over `hand_proof_length`; null exactly when `reference_kind` is `extracted` |
| `reference_kind` | string enum | `hand` or `extracted` |
| `built_derivation_size` | integer or null | Node count of the derivation the script built; null when schematic |
| `reference_derivation_size` | integer or null | Node count of the reference derivation; null when schematic |
| `statement_fragment` | string | The fragment of the statement |
| `proof_fragment` | string | The fragment the proof stays within, which may be larger than the statement's |

## The three nullability rules

Each is enforced at the emitter, with a `throwError` and a pinned message, rather than discovered
downstream in a collected record.

| field | null exactly when | why |
|-------|-------------------|-----|
| `failure_class` | `outcome` is `closed_by_rules` | There is nothing to explain: the mode carried the script on its own rules |
| `length_ratio` | `reference_kind` is `extracted` | Length is compared against **hand proofs only**. Against a tableau-extracted proof a script is measured for coverage and built-derivation size, not brevity, because the extracted proof's length is an artefact of the extraction |
| `derivation_size`, `derivation_height` | the statement is schematic | Both measures evaluate a closed derivation. A statement abstracting over its formulas has no closed instance to evaluate, which is a property of the measure rather than a gap in the emitter |

## Two timing fields, and that is deliberate

`heartbeats` is deterministic for a fixed toolchain and library. It is the figure a gate can quote
and a check can compare, and the one to use when a number must be reproducible.

`elab_ms` is wall clock. It is what "elaboration time" literally asks for, and it is
machine-dependent: it is recorded so the figures are legible to a human, never so that two
machines' numbers are compared.

Recording both costs nothing and keeps the reproducible figure separable from the human-legible
one. Neither is pinned by a `#guard_msgs` anywhere: neither is stable across a toolchain bump, and
a pinned timing figure is a brittle test dressed up as a measurement. Only axiom sets are pinned,
in `Tests/BimodalTest/Automation/ProofModeAxioms.lean`.

`heartbeats` is also not comparable **across instruments**. A figure taken by `#reprove_record`
includes the wrapper's own record assembly and runs consistently larger than the same script
measured by `#count_heartbeats in`. What is instrument-independent is the shape of the growth, and
that is what `docs/development/proof-mode-cost-baseline.md` states.

## Reserved stages

These five stages have a fixed head and an agreed payload, and no emitter. They are written by the
tableau-pipeline work, which extends this schema rather than renegotiating it. The field lists
below are the ones the library-pipeline record's own Diagnostics table names, and they are
mirrored in `Stage.reservedKeys` so the reservation is machine-readable.

### Enumerate

Carries formula-valued fields. Written by the tableau pipeline.

#### enumerate

| field | type | description |
|-------|------|-------------|
| `formulas_generated` | integer | Formulas generated |
| `by_fragment` | object | Count per fragment |
| `by_complexity` | object | Count per complexity |
| `duplicates_removed` | integer | Formulas dropped as duplicates |

### Decide

Written by the tableau pipeline.

#### decide

| field | type | description |
|-------|------|-------------|
| `verdict` | string | The decision procedure's verdict |
| `decision_time_ms` | integer | Time taken |
| `fuel_used` | integer | Fuel consumed |
| `branches_opened` | integer | Branches opened |
| `branches_closed` | integer | Branches closed |

### Extract

Carries formula-valued fields. Written by the tableau pipeline.

#### extract

| field | type | description |
|-------|------|-------------|
| `derivation_size` | integer or null | Node count of the extracted derivation |
| `derivation_height` | integer or null | Height of the extracted derivation |
| `axiom_schemata` | object | Axiom schemata used, with counts |
| `extraction_route` | string | Which route produced the derivation |
| `countermodel_histories` | integer or null | For a countermodel, the number of histories |
| `countermodel_times` | integer or null | For a countermodel, the number of times |

### Certify

Written by the tableau pipeline.

#### certify

| field | type | description |
|-------|------|-------------|
| `axioms` | array of string | The axiom set the entry depends on |
| `countermodel_grade` | string or null | For a countermodel, its grade |
| `gates` | object or null | For a countermodel, each gate and its outcome |

### Admit

Written by the tableau pipeline.

#### admit

| field | type | description |
|-------|------|-------------|
| `disposition` | string | Admitted, subsumed, or registered as a conjecture |
| `subsumed_by` | string or null | The entry that subsumes this one |
| `conjecture_verdict` | string or null | The verdict a registered conjecture carries |

### The formula-codec obligation

`enumerate` and `extract` carry formula-valued fields; the two implemented stages carry none. A
stage that records a formula **reuses the existing `{"tag": ...}` JSON codec** rather than
inventing a second one — the codec the datasets under `data/` already use for `formula_ast`. This
is recorded here rather than exercised, because no implemented stage needs it: the shared head is
six strings, the `reprove` payload is scalars plus two string arrays, and the `compare` payload is
scalars plus two fragment names. Importing the codec now would add a dependency edge out of
`BimodalLib` for nothing, and leaving the obligation unwritten would risk the two schemas being
invented beside each other.

## The emitter commands

### `#reprove_record`

```
#reprove_record <declaration> stage <string> outcome <string> failure <string>
  tactics <string> escape <number> in
<declaration command>
```

A **wrapper**, not a reader. Heartbeats and wall-clock time can only be observed during the
elaboration that produces a declaration; once the declaration is in the environment both are gone.
The command therefore reads `IO.getNumHeartbeats` and `IO.monoMsNow` either side of elaborating
the command it wraps, then looks the named declaration up in the environment that elaboration just
extended.

`failure` takes the literal `none` for the absent value. `tactics` is a comma-separated list.

Three implementation facts a reader of the elaborator will want, each forced rather than chosen:

- The inner command is elaborated with `Elab.async false`. With the default on, a declaration body
  is elaborated in a background task, so the constant would not be in the environment when the
  elaborator resumes, and the heartbeat delta would exclude the body's own elaboration.
- `maxHeartbeats` is **not** lifted by the command. A cap would destroy the measurement, so
  lifting it is required — but it is lifted by the probe, at file scope, where the measurement's
  conditions are visible to a reader of the file.
- Arguments are read positionally from the syntax node and the keyword atoms are non-reserved
  (`&" stage "`). A plain string atom would reserve its spelling as a token for the whole module,
  making `stage` unusable as a field name in the emitter's own structure instances; and a
  `command` category quotation cannot carry a nested command antiquotation, so the pattern-matching
  form is unavailable.

### `#compare_record`

```
#compare_record <script> <reference> kind <string> lengths <number> <number>
```

A reader: it reads two already-elaborated declarations, so it needs no timing. The two numbers are
`script_length` and `hand_proof_length`, in that order.

### What is derived and what is supplied

Derived from the environment, never retyped: `term_size` (`ConstantInfo.value?` through
`Lean.Expr.sizeWithoutSharing`), `axioms` (`Lean.collectAxioms`, the same collector
`#print axioms` uses), `frame_class` (off the declaration's own type), `fragment` (from the
registry row), and `derivation_size` / `derivation_height` (by compiled evaluation of this
library's own measures).

Supplied by the caller: the stage, the outcome, the failure class, the tactic list, the escape
size, the reference kind and the two lengths. These are facts about the *script*, not about the
term, and nothing in the environment knows them.

### The stamp options

| option | effect |
|--------|--------|
| `diagnostics.commit` | The commit recorded in the head |
| `diagnostics.date` | The UTC date of measurement |
| `diagnostics.command` | The command line recorded in the head |
| `diagnostics.zeroTimings` | Records 0 for `heartbeats` and `elab_ms`, making a record byte-stable |

All four are set from outside, by `lake env lean -D<option>=<value>`, so the tracked probe stays
stamp-free. An unset string option records `unstamped`.

`diagnostics.zeroTimings` exists because those two fields are the only ones that are not a
function of the commit and the toolchain, and therefore the only obstacle to a byte-stable record.
Zeroing them is what lets a `#guard_msgs` test pin a whole record, and what lets the collecting
script compare two runs byte for byte without comparing the figures the measurement is *for*.

## Error messages

Eight `throwError` paths, each pinned by a `#guard_msgs` test in
`Tests/BimodalLibTest/DiagnosticsTest.lean`. The text below is the documented home of each
message; the test is its assertion.

| # | message | raised when |
|---|---------|-------------|
| 1 | ``diagnostics: unknown declaration `<name>` `` | No declaration of that name exists, under the current namespace or any enclosing one |
| 2 | ``diagnostics: declaration `<name>` has no value to measure`` | The constant exists but holds no value: an `axiom`, an `opaque`, a constructor, an inductive type |
| 3 | ``diagnostics: `<s>` is not a stage; expected one of [enumerate, decide, extract, certify, admit, reprove, compare]`` | A stage string outside the closed list |
| 4 | ``diagnostics: `<s>` is not an outcome; expected one of [closed_by_rules, closed_with_leaf_automation, closed_with_term_escape, not_closed]`` | An outcome string outside the closed list |
| 5 | ``diagnostics: `<s>` is not a failure class; expected `none` or one of [missing_rule, missing_tactic, automation_too_weak, script_too_awkward, too_slow, defect_in_mode]`` | A failure-class string outside the closed list |
| 6 | ``diagnostics: `<s>` is not a reference kind; expected one of [hand, extracted]`` | A reference-kind string outside the closed list |
| 7 | ``diagnostics: outcome `<outcome>` admits no failure class, but `<s>` was given`` | A failure class supplied against `closed_by_rules` |
| 8 | ``diagnostics: outcome `<outcome>` requires a failure class, but `none` was given`` | A failure class omitted against any other outcome |

Messages 7 and 8 are the `failure_class` nullability rule, enforced at the emitter.

Lean wraps a long message across lines, so the enumerations in messages 3 to 5 appear one value
per line in the actual output. The test's docstrings carry the wrapped form; the table above gives
the text.

## Related

- `BimodalLib/Diagnostics/README.md` — the directory's own overview
- `docs/development/proof-mode-cost-baseline.md` — the first dataset produced against this
  schema, and the figures it carries

---

[Back to Reference](README.md)

# BimodalLib/Diagnostics

The diagnostics record schema for the library pipeline, and the commands that emit it.

A record is keyed by a statement identifier and a stage, and carries the fragment, the frame
class, the commit and the command that produced it. That shared head is the same for all seven
stages of the pipeline — `enumerate`, `decide`, `extract`, `certify`, `admit`, `reprove`,
`compare` — and each stage adds its own payload.

Two stages are implemented here: `reprove` and `compare`, the two the proof-mode cost baseline
emits. The other five have their payload keys reserved in `Stage.reservedKeys`, with the field
lists taken from the pipeline record's own Diagnostics table, so the tableau pipeline extends this
schema rather than renegotiating it. Every field is documented at `docs/reference/diagnostics.md` — a stage is not complete until its
fields are documented there.

## Modules

| Path | Description |
|------|-------------|
| `Record.lean` | The `Stage` key, the shared `Head`, the closed `Outcome`/`FailureClass`/`ReferenceKind` enumerations, the `ReproveRecord` and `CompareRecord` payloads with their snake_case JSON serialization, and the five reserved stages' payload keys |
| `Size.lean` | `derivationSize` and `plusDerivationSize`, the computable node count of a derivation, beside the existing `height`, with the ordering `height ≤ size` proved for both |

## Why a measure of a core type is declared here

`derivationSize` measures `FormalSystem.ProofSystem.DerivationTree`, whose `height` lives in
`FormalSystem/ProofSystem/Derivation.lean`. The size measure is filed here instead because it is
observational: nothing in the proof system needs it, its only consumer is this schema, and keeping
it out of the core leaves `FormalSystem/`'s generated inventories unmoved by a measure that proves
nothing. `Size.lean`'s own module docstring records the trade-off.

## Records are printed, never written

Both emitter commands print exactly one JSON object per invocation to stdout, and the measuring
script collects them. No command in this directory writes a tracked file as an elaboration side
effect: a command that did would be both untestable and non-composable.

## Tests

The emitters' error paths are pinned one-for-one by `#guard_msgs` negative tests in
`Tests/BimodalLibTest/DiagnosticsTest.lean`, which also carries one positive smoke record so a
green run is distinguishable from a run that emitted nothing.

---

*Last verified: 2026-11-23*

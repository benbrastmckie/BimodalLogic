# Implementation Summary: Task #669

- **Task**: 669 - Make the witness-family certificate's target time a required field and group the target condition to mirror the Lean structure
- **Status**: [COMPLETED]
- **Started**: 2026-09-24
- **Completed**: 2026-09-24
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_required-target-time-grouping.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

One wire-format revision to `lake exe check_certificate`, made in a single pass. `"time"` stopped
being an optional field defaulting to `0` and became required, and `premises`/`conclusions`/`time`
are now grouped under one `"target"` object mirroring `WitnessFamily.Target`'s three data.
Required-ness is expressed by a parse-time partial record that `complete`s into the wire record
through `Except String`, so an absent field lands on `checkLine`'s existing `.error` path and
renders `{"status":"error",...}` rather than a verdict. No proof obligation, no new axiom, no new
`CheckResult` constructor.

## What Changed

- `BimodalTools/CertificateImport.lean` — `RawCertificate` split into `RawTarget` (`premises`,
  `conclusions` defaulted to `[]`; `time : Int` with **no** default) nested inside `RawCertificate`
  (`target : RawTarget` with no default, plus `bx`, `lassos`). Added the parse-time seam
  `PartialTarget`/`PartialCertificate` (every field optional) with `PartialTarget.complete` and
  `PartialCertificate.complete : … → Except String …`, carrying two deliberately distinct messages.
  Envelope parser split into `pRawTarget` and a `pRawCertificate` that dispatches on `"target"`;
  `pSkipValue` keeps unknown-field tolerance at both nesting levels. Serializer split into
  `RawTarget.toJson` and `RawCertificate.toJson`. Three downstream readers re-projected with no
  logic change: `RawCertificate.formulas`, `mkFamily`'s dependent return type and its `closureOf`
  argument, and `checkRaw`'s three `raw.time` uses. Module docstring gained two rationale sections
  and an extended `## Main Definitions` list.
- `Tests/BimodalToolsTest/CertificateImportTest.lean` — certificate literals reshaped to the nested
  target; the row asserting `"time"` defaults to `0` **inverted** into a row asserting the same
  input is an error; the unknown-field row extended to carry an unknown field inside `"target"`
  too; two new acceptance rows asserting on the rendered JSON prefix `{"status":"error"`, plus a
  row pinning that the two missing-field messages differ. 20 `#guard` rows became 23.
- `BimodalTools/README.md` — "Certificate re-verification protocol" section rewritten: nested input
  block, field table with a `target` row plus indented `target.premises`/`target.conclusions`/
  `target.time` rows, a paragraph stating required-ness and its reason, and the corrected
  error/rejected boundary sentence naming the missing-required-field class explicitly.
- `BimodalTools/CheckCertificateMain.lean` — `## Usage` example updated to the nested shape.
- `lakefile.toml` — `# Run with:` comment updated to the nested shape (it previously showed the flat
  shape *without* `"time"`, which this change would turn from stale into a protocol error).
- `BimodalTools/README.md`, `Tests/BimodalToolsTest/README.md` — regenerated inventory line counts
  (`CertificateImport.lean` 563 → 658; `CertificateImportTest.lean` 172 → 189). Exactly the two
  rows the plan's scope hypothesis predicted.

## Decisions

- **Two distinct missing-field messages.** A producer that omitted the whole `"target"` object and
  one that omitted only its `"time"` have made different mistakes; the distinction costs nothing
  and is pinned by a `#guard` asserting the two rendered lines differ.
- **`premises`/`conclusions` keep `:= []`; only `time` loses its default.** `[]` is the identity of
  a context, so an absent premise list has one unambiguous correct reading; `0` is not the identity
  of a time. The asymmetry is recorded in the docstring and README so it is not later "tidied".
- **`pObjectFields` is not the required-field seam.** It folds a handler over an accumulator seeded
  with `{}`, ill-formed once a field loses its default — hence the partial records.
- The two new acceptance rows assert on the **rendered JSON prefix** via `checkLineToJson`, not on
  an internal constructor, so they speak the acceptance criterion's own vocabulary.

## Plan Deviations

- None (implementation followed plan). One presentational adjustment inside Phase 1: the two new
  acceptance rows' wire lines were factored into `noTimeLine`/`noTargetLine` definitions, because
  the inline form exceeded the 100-character limit that `linter.style.longLine` makes fatal under
  `--wfail`. Same rows, same assertions.

## Verification

- Build: Success. `lake build` (full project, guarded + detached) exit 0, 2734 jobs, 0 `error:`
  lines. `lake build BimodalTools --wfail` exit 0 at zero warnings; `lake build BimodalToolsTest
  --wfail` exit 0 at zero warnings (a failing `#guard` is an error, so a green build is the
  row-by-row assertion, including the round-trip rows `parseCertificate posRaw.toJson = .ok posRaw`
  and the `sepRaw` equivalent).
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots).
- Vacuous count: 0 introduced. The repo-wide grep returns 1 hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, identical to the pre-task baseline and
  untouched here.
- Axiom count: 14, identical to the pre-task baseline; 0 `axiom`/`sorry` lines added in the three
  edited Lean files.
- `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED.
- `bash scripts/check-copyright-headers.sh --strict` — clean (568 conforming, 0 nonconforming).
- Acceptance runs through `lake exe check_certificate`, captured verbatim:

```
--- non-vacuity family ---
{"status":"countermodel","time":0}
--- separation family ---
{"status":"rejected","failed":[{"condition":"fulfilling","lasso":0,"position":-2,"formula":{"tag": "untl", "event": {"tag": "atom", "name": "q"}, "guard": {"tag": "atom", "name": "p"}},"detail":"this eventuality is never discharged"}]}
--- target present, time omitted ---
{"status":"error","message":"certificate field \"target\" is missing its required field \"time\""}
--- target omitted ---
{"status":"error","message":"certificate is missing its required field \"target\""}
--- unparseable ---
{"status":"error","message":"expected '\"' got 'n' at pos 2"}
```

- Files verified: Yes.

## Impacts

- **The wire format is now the interface a certificate exporter must mirror field for field.** The
  final shape is `{"target":{"premises":[...],"conclusions":[...],"time":t},"bx":[...],
  "lassos":[...]}`, recorded in `BimodalTools/README.md`'s protocol section completely enough to be
  written against without reading any Lean: both required fields are named, their omission is
  stated to answer `error` rather than `rejected`, and the two omissions carry distinct messages.
- The output shape is unchanged: `{"status":"countermodel","time":t}` still echoes the time flat.
- Relaxing a required field to optional stays backward compatible later; the reverse tightening,
  which this change performs while nothing consumes the format, would not have been.

## Follow-ups

- The ModelChecker-side certificate exporter (`~/Projects/ModelChecker`) still has to be written
  against this schema. Out of scope here by design.
- `target.premises` and `target.conclusions` remain optional. If a future reader wants them
  required too, the docstring and README both state why they are not, so the decision can be
  revisited deliberately rather than by accident.

## References

- `specs/669_required_target_time_and_target_grouping/plans/01_required-target-time-grouping.md`
- `specs/669_required_target_time_and_target_grouping/reports/01_required-target-time-grouping.md`
- `BimodalTools/README.md` — "Certificate re-verification protocol"
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` — the export-contract note

# BimodalToolsTest

Tests for `BimodalTools` — the dataset, export and benchmark tooling. The counterpart of
`Tests/BimodalTest/`, which covers the published `FormalSystem` library only.

Built by `lake build BimodalToolsTest`, not by `lake test`: the package's `testDriver` is
`BimodalTest`, and the library/tooling split is mirrored here so that the library's own test
run stays free of tooling compile cost.

## What belongs here

A test that exercises dataset generation, JSON export, trace-certificate round-tripping or a
benchmark harness. A test that exercises the logic itself stays in `BimodalTest`. A test that
straddles the two is **divided**, not moved wholesale, so library coverage stays inside
`lake test`.

## Never import an executable root

A test importing an executable root inherits that root's root-namespace `main`, and two such
tests cannot share one environment. No test here does: each executable root whose logic a test
needs is split into a library module plus a thin `main` (`DatasetGenerator` /
`DatasetGeneratorMain`, `ContrastiveGenerator` / `ContrastiveGeneratorMain`,
`ProofFirstGenerator` / `ProofFirstGeneratorMain`), and the test imports the library half. Every
test module in this directory is therefore imported by `Tests/BimodalToolsTest.lean`, and none
is listed in `scripts/module-invariants-manifest.txt`. A new test that needs the body of a
`*Main` module should split that module the same way rather than import it.

## Contents

<!-- BEGIN GENERATED: inventory dir=Tests/BimodalToolsTest -->
| File | Lines | Description |
|------|------:|-------------|
| `C5SmokeTest.lean` | 250 | <!-- TODO: add description --> |
| `CertificateImportTest.lean` | 201 | Acceptance rows for `check_certificate`: the non-vacuity family accepted, the separation family rejected naming its obligation, structural rejection, and the wire-format round trips |
| `DatasetGeneratorTest.lean` | 552 | <!-- TODO: add description --> |
| `EnumeratorCountsTest.lean` | 91 | <!-- TODO: add description --> |
| `FormulaMutatorTest.lean` | 194 | <!-- TODO: add description --> |
| `InterestingnessTest.lean` | 354 | <!-- TODO: add description --> |
| `ProofFirstTests.lean` | 250 | <!-- TODO: add description --> |
| `SentenceCodecTest.lean` | 200 | Acceptance rows for `translate_sentence` and `Tests/fixtures/sentence-translation-fixtures.jsonl`: the fixture file is read with `include_str`, every row's translation checked against it, both codecs round-tripped, and the file's canonical form pinned byte for byte |
| `TableauBridgeTest.lean` | 165 | <!-- TODO: add description --> |
| `TraceCertificateTest.lean` | 225 | <!-- TODO: add description --> |
| `TraceExportTest.lean` | 162 | <!-- TODO: add description --> |
| `TraceExporterE2ETest.lean` | 139 | <!-- TODO: add description --> |
<!-- END GENERATED -->

*Last verified: 2026-09-20*

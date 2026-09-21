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

## Modules that cannot be aggregated

A test importing an executable root inherits that root's root-namespace `main`, and two such
tests cannot share one environment. Those tests are absent from `Tests/BimodalToolsTest.lean`
and listed in `scripts/module-invariants-manifest.txt` instead, where check `C6`
compile-checks each in isolation.

## Contents

<!-- BEGIN GENERATED: inventory dir=Tests/BimodalToolsTest -->
| File | Lines | Description |
|------|------:|-------------|
| `C5SmokeTest.lean` | 249 | <!-- TODO: add description --> |
| `DatasetGeneratorTest.lean` | 552 | <!-- TODO: add description --> |
| `FormulaMutatorTest.lean` | 194 | <!-- TODO: add description --> |
| `InterestingnessTest.lean` | 354 | <!-- TODO: add description --> |
| `ProofFirstTests.lean` | 250 | <!-- TODO: add description --> |
| `TraceCertificateTest.lean` | 224 | <!-- TODO: add description --> |
| `TraceExportTest.lean` | 161 | <!-- TODO: add description --> |
| `TraceExporterE2ETest.lean` | 139 | <!-- TODO: add description --> |
<!-- END GENERATED -->

*Last verified: 2026-09-20*

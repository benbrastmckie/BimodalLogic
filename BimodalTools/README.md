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

## Contents

<!-- BEGIN GENERATED: inventory dir=BimodalTools -->
| File | Lines | Description |
|------|------:|-------------|
<!-- END GENERATED -->

*Last verified: 2026-09-20*

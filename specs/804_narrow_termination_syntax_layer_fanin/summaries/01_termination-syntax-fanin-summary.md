# Implementation Summary: Task #804

- **Task**: 804 - Narrow the termination subtree's fan-in from the syntax layer
- **Status**: [COMPLETED]
- **Started**: 2026-11-13T22:28:38Z
- **Completed**: 2026-11-13T22:57:52Z
- **Effort**: about 1 hour
- **Dependencies**: 803 (landed)
- **Artifacts**: plans/01_termination-syntax-fanin.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Seven import-line edits (the report's R1-R4, with R2 in the plan's line-neutral form) take the
termination subtree out of the rebuild set of every `Semantics` module and of the `Syntax`
aggregator. No declaration, statement or proof was touched. An edit to
`ProofSystem/Axioms.lean` still rebuilds the same 520 modules, all 25 termination modules among
them: that dependence is essential and was left alone.

## What Changed

- `FormalSystem/Automation/ProofSearch/Core.lean` — `import FormalSystem.ProofSystem` and `import FormalSystem.Semantics` replaced by `import FormalSystem.ProofSystem.Derivation` and `import FormalSystem.ProofSystem.DerivedAxioms`
- `FormalSystem/Automation/SuccessPatterns.lean` — `import FormalSystem.Syntax` replaced by `import FormalSystem.Syntax.Formula`
- `FormalSystem/Metalogic/Decidability/SignedFormula.lean` — `import FormalSystem.ProofSystem` replaced by `import FormalSystem.ProofSystem.Axioms`
- `FormalSystem/Metalogic/Decidability/TraceCertificate.lean` — removed `import FormalSystem.Syntax` and `import FormalSystem.ProofSystem`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` — removed `import FormalSystem.Syntax.SubformulaClosure.Closure`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` — added `import Mathlib.Tactic.Ring`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean` — added `import Mathlib.Data.Finset.Max`
- `typst/generated/status.typ`, `README.md`, `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Decidability/Verified/Termination/README.md` — regenerated line counts
- `specs/804_narrow_termination_syntax_layer_fanin/evidence/01_rebuild-scope.md` — created: baseline, before/after rebuild sets, the 20-edge classification against the landed imports, the recommendation, gate results
- `specs/804_narrow_termination_syntax_layer_fanin/probes/rebuild_sets.py` — created: reverse import closures from the probe's graph

Measured rebuild sets (module counts out of 852, reverse import closure read from the built
environment, not a timed build):

| Edited module | Before | After | Termination modules before -> after |
|---|---|---|---|
| `ProofSystem.Axioms` | 520 | 520 | 25 -> 25 |
| `Semantics` (aggregator) | 251 | 204 | 23 -> 0 |
| `Syntax` (aggregator) | 107 | 29 | 23 -> 0 |
| `ProofSystem.Derivation` | 361 | 356 | 25 -> 23 |
| `Syntax.Context` | 544 | 538 | 25 -> 23 |

## Decisions

- The `Axioms.lean` path is left as is. `Fuel` and `MintBound` are stated over types that contain `DerivationTree` and `Axiom`; `Tableau` needs `FrameClass`, which `Axioms.lean` declares.
- `FrameClass` relocation (R5) and a closure interface (R6) were not taken, as the plan decided.
- The failing `BimodalToolsTest.CertificateImportTest` was not edited: it is outside the task's file scope and its failure predates this change.
- The probe was run through the build guard as `-- env lean <probe>`; the guard admits it.

## Plan Deviations

- **Phase 2, four-root build** altered: `FormalSystem`, `BimodalTest` and `BimodalTools` build green (3072 jobs, 0 warnings). `BimodalToolsTest` exits 1 on one module; see the next section.
- **Phase 2, missing-import repair and R2 fallback** skipped: neither was needed.
- **Phase 3, `verify-deploy.sh`** altered: the batch gate deferral was recorded instead of an independent run, as the dispatch directs. The repository-specific criteria (full `check-module-invariants.sh`, `check-metalogic-cycles.sh`, `typst-sync-check.sh`) have no `--only` mapping and were run directly.

## Pre-existing failure: BimodalToolsTest.CertificateImportTest

`lake build BimodalToolsTest` fails on `Tests/BimodalToolsTest/CertificateImportTest.lean` lines
146 and 152: `closureList` is ambiguous between `BimodalTools.CertificateImport.closureList` and
`FormalSystem.Metalogic.Decidability.closureList`. The second declaration was added by commit
`22e2afa46` on 2026-11-12; the test last built on 2026-11-11. Both names were already in the
test's import closure before this task, and removing imports cannot introduce a name. Default
`lake build` and `check-module-invariants.sh` C1 do not build this root, but CI's
`lake build BimodalToolsTest --wfail` step does. The fix is to qualify the two call sites; it needs
its own task or the user's go-ahead.

## Verification

- Build: Success. Full `lake build` through the guard, exit 0, 2975 jobs, 0 `error:`, 0 `warning:`; `.olean` newer than source for all seven edited modules.
- Sorry count: 0
- Vacuous count: 0 introduced. The single-line grep has one hit, `int_domain_universal ... := trivial` in `FormalSystem/Examples/TemporalStructures.lean`, an untouched file where `trivial` is a real proof.
- Axiom count: 14, unchanged from `6350193cc`. `check-module-invariants.sh` C2 and C14 axiom baselines match.
- Tests: `bash scripts/check-module-invariants.sh` full mode exit 0, `ALL CHECKS PASSED`; `check-metalogic-cycles.sh` exit 0; `typst-sync-check.sh` exit 0. `BimodalToolsTest` red as described above.
- Plan compliance check: skipped (the plan names no theorem identifiers).
- Full gate set: deferred to the batch stage, not independently run.
- Files verified: Yes

## Impacts

- An edit to any `Semantics` module or to `Syntax.lean` no longer rebuilds `Fuel`, `MintBound`, `Closure`, `Saturation` or `TraceCertificate`; 47 modules left the rebuild set of `Semantics.lean`.
- Edits to `Derivation`, `Derivable`, `DerivedAxioms`, `Syntax.Context` and `Subformulas` no longer rebuild `SubformulaProperty` and `TimeTypeBound`.
- A batch that touches `Axioms.lean` or `Syntax/Formula.lean` is no cheaper than before.
- Modules below `Closure` no longer receive Mathlib transitively through the Semantics aggregator; a new use of a Mathlib tactic there needs its own import.

## Follow-ups

- Fix the ambiguous `closureList` in `Tests/BimodalToolsTest/CertificateImportTest.lean`.
- Optional: relocate `FrameClass` out of `Axioms.lean` (520 -> 516 by the report's simulation, at the cost of 33 shifted citations).

## References

- `specs/804_narrow_termination_syntax_layer_fanin/plans/01_termination-syntax-fanin.md`
- `specs/804_narrow_termination_syntax_layer_fanin/reports/01_termination-syntax-fanin.md`
- `specs/804_narrow_termination_syntax_layer_fanin/evidence/01_rebuild-scope.md`
- `specs/804_narrow_termination_syntax_layer_fanin/probes/`

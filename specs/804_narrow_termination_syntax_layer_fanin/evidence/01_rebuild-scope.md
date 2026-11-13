# Rebuild-Scope Evidence: Task #804

Measured record for the import narrowing of the termination subtree
(`FormalSystem/Metalogic/Decidability/Verified/Termination/`). Section 1 is the pre-change
baseline; later sections are added as the change lands.

## 1. Pre-change baseline

Tree: HEAD `6350193cc`, 2026-11-13, no uncommitted change outside `specs/`.

### 1.1 Build state

`bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build`: guard exit 0, guard
`result` record `state=complete exit_status=0`, lake's own line
`Build completed successfully (2975 jobs).`, 0 `error:` lines and 0 `warning:` lines in the captured
output. The tree was already built; nothing was re-elaborated.

### 1.2 Rebuild sets

Method. `probes/WholeRepoUsesProbe.lean` was run as `lake env lean <probe>` through the build guard
(the guard admits the `env` subcommand; exit 0, 25s, nothing built). It writes the import edges of
every module in the environment of `import FormalSystem; import BimodalTest; import BimodalTools`,
read from `env.header.moduleData`. `probes/rebuild_sets.py` computes, for a source module, the set
of project modules whose transitive import closure contains it. Lake rebuilds a module exactly when
something in its import closure changes, so that set is the rebuild set for an edit to the source.
It is a graph computation, not a timed build. `BimodalToolsTest` is not in the probe's environment,
so the 852-module universe excludes it, as in the research report.

Project modules: 852. Termination modules: 25 (`Fuel`, `MintBound`, `SubformulaProperty`,
`TimeTypeBound`, and the 21 modules under `MintBound/`; confirmed by listing the directory).

| Edited module | Rebuild set | Termination modules in it |
|---|---|---|
| `FormalSystem.ProofSystem.Axioms` | 520 | 25 |
| `FormalSystem.Semantics` (aggregator) | 251 | 23 |
| `FormalSystem.Syntax` (aggregator) | 107 | 23 |
| `FormalSystem.ProofSystem.Derivation` | 361 | 25 |
| `FormalSystem.Syntax.Context` | 544 | 25 |
| `FormalSystem.ProofSystem.Derivable` | 354 | 25 |
| `FormalSystem.ProofSystem.DerivedAxioms` | 339 | 25 |
| `FormalSystem.Syntax.Formula` | 769 | 25 |
| `FormalSystem.Syntax.Subformulas` | 298 | 25 |
| `FormalSystem.Syntax.SubformulaClosure.Closure` | 297 | 25 |
| `FormalSystem.Syntax.SubformulaClosure.NestingDepth` | 233 | 23 |
| `FormalSystem.Syntax.SubformulaClosure.TemporalFormulas` | 224 | 23 |
| `FormalSystem.Semantics.Validity` | 445 | 23 |
| `FormalSystem.Semantics.Truth` | 485 | 23 |
| `FormalSystem.Semantics.TaskFrame` | 561 | 23 |

Every figure equals the research report's "Now" column, so the commits landed since the report did
not move the graph.

Import closure of the subtree: 122 `FormalSystem` modules outside `Termination/` are in the import
closure of at least one termination module, 75 of them under `Semantics`. `Fuel`'s closure holds
4126 modules outside the project (Mathlib, Batteries, Lean, Std).

### 1.3 Build-free gates

| Gate | Exit | Findings |
|---|---|---|
| `bash scripts/check-module-invariants.sh --no-build` | 0 | none (`ALL CHECKS PASSED`) |
| `bash scripts/check-metalogic-cycles.sh` | 0 | none |
| `bash scripts/typst-sync-check.sh --counts-only` | 0 | `MISMATCH_COUNT=0` |
| `bash scripts/check-module-invariants.sh --emit-inventory --check` | 0 | none |

### 1.4 `file.lean:NNN` citations outside `specs/`

`git grep -nE '<Basename>\.lean:[0-9]+' -- ':!specs'`, by basename (a full-path form occurs nowhere).

| File | Lines | Citations |
|---|---|---|
| `Automation/ProofSearch/Core.lean` | 1268 | 0 |
| `Automation/SuccessPatterns.lean` | 419 | 1 |
| `Metalogic/Decidability/SignedFormula.lean` | 938 | 5 |
| `Metalogic/Decidability/TraceCertificate.lean` | 313 | 0 |
| `Termination/SubformulaProperty.lean` | 1617 | 0 |
| `Termination/Fuel.lean` | 2705 | 0 |
| `Termination/MintBound/ClosureResidual.lean` | 1164 | 0 |
| `Metalogic/Decidability/Tableau.lean` (not edited) | 3245 | 18 |

The four files whose line count the change moves (`TraceCertificate`, `SubformulaProperty`, `Fuel`,
`ClosureResidual`) carry zero citations. `SuccessPatterns` and `SignedFormula` are edited in place
with no line shift.

### 1.5 Leading `import` and `open` lines as they stand

```
Automation/ProofSearch/Core.lean
  7:import Std.Data.HashMap
  8:import Std.Data.HashSet
  9:import FormalSystem.ProofSystem
 10:import FormalSystem.Semantics
 11:import FormalSystem.Automation.SuccessPatterns
 12:import FormalSystem.Theorems.Combinators
 13:import FormalSystem.Theorems.Perpetuity.Helpers
 14:import FormalSystem.Theorems.ConnectDerived
 15:import FormalSystem.Theorems.LinearityDerived
191:open FormalSystem.Syntax
192:open FormalSystem.ProofSystem
Automation/SuccessPatterns.lean
  7:import Std.Data.HashMap
  8:import FormalSystem.Syntax
 57:open FormalSystem.Syntax
Metalogic/Decidability/SignedFormula.lean
  7:import FormalSystem.Syntax.Formula
  8:import FormalSystem.ProofSystem
 41:open FormalSystem.Syntax
 42:open FormalSystem.ProofSystem
Metalogic/Decidability/TraceCertificate.lean
  7:import FormalSystem.Syntax
  8:import FormalSystem.ProofSystem
  9:import FormalSystem.Metalogic.Decidability.SignedFormula
 10:import FormalSystem.Metalogic.Decidability.Closure
 42:open FormalSystem.Syntax
 43:open FormalSystem.ProofSystem
Termination/SubformulaProperty.lean
  7:import FormalSystem.Metalogic.Decidability.Tableau
  8:import FormalSystem.Syntax.SubformulaClosure.Closure
124:open FormalSystem.Syntax
125:open FormalSystem.ProofSystem (FrameClass)
Termination/Fuel.lean
  7:import FormalSystem.Metalogic.Decidability.Verified.Termination.TimeTypeBound
  8:import FormalSystem.Metalogic.Decidability.Saturation
 93:open FormalSystem.Syntax
Termination/MintBound/ClosureResidual.lean
  7:import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Terminus
 54:open FormalSystem.Syntax
Metalogic/Decidability/Tableau.lean (not edited)
  7:import FormalSystem.Metalogic.Decidability.SignedFormula
 61:open FormalSystem.Syntax
 62:open FormalSystem.ProofSystem
```

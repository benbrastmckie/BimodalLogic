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

## 2. The change as landed

### 2.1 Edits

Seven files, import lines only (`git diff --numstat` against `73f45155a`; every changed hunk is an
`import` line):

| File | Change | Lines |
|---|---|---|
| `Automation/ProofSearch/Core.lean` | `import FormalSystem.ProofSystem` -> `import FormalSystem.ProofSystem.Derivation`; `import FormalSystem.Semantics` -> `import FormalSystem.ProofSystem.DerivedAxioms` | 0 |
| `Automation/SuccessPatterns.lean` | `import FormalSystem.Syntax` -> `import FormalSystem.Syntax.Formula` | 0 |
| `Metalogic/Decidability/SignedFormula.lean` | `import FormalSystem.ProofSystem` -> `import FormalSystem.ProofSystem.Axioms` (`open` line kept) | 0 |
| `Metalogic/Decidability/TraceCertificate.lean` | removed `import FormalSystem.Syntax` and `import FormalSystem.ProofSystem` | -2 |
| `Termination/SubformulaProperty.lean` | removed `import FormalSystem.Syntax.SubformulaClosure.Closure` | -1 |
| `Termination/Fuel.lean` | added `import Mathlib.Tactic.Ring` | +1 |
| `Termination/MintBound/ClosureResidual.lean` | added `import Mathlib.Data.Finset.Max` | +1 |

`Tableau.lean` is untouched; the R2 fallback was not needed. No further explicit import was needed
in any module.

### 2.2 Build

- `lake build FormalSystem BimodalTest BimodalTools BimodalToolsTest` through the guard: exit 1.
  120 modules re-elaborated; 119 built, one failed: `BimodalToolsTest.CertificateImportTest`,
  `Ambiguous term closureList` at lines 146 and 152, between
  `BimodalTools.CertificateImport.closureList` and
  `FormalSystem.Metalogic.Decidability.closureList`. 0 warning lines.
- That failure is not caused by this change. An import removal cannot introduce a name, and both
  declarations were already in the test's import closure on the unedited tree
  (`WitnessFamily/Compression/Enumerate.lean` is in the Phase 1 closure of
  `BimodalTools.CertificateImport`). The second `closureList` was added by commit `22e2afa46`
  (2026-11-12); the test's last successful build trace is dated 2026-11-11 and it had no `.olean`
  on the Phase 1 tree. Default `lake build` and `check-module-invariants.sh` C1 do not build
  `BimodalToolsTest`, which is why the Phase 1 gates were green. The other 12 modules of
  `BimodalToolsTest` build. The test file is outside this task's file scope and was not edited.
- `lake build FormalSystem BimodalTest BimodalTools` through the guard: exit 0,
  `Build completed successfully (3072 jobs)`, 0 `error:` lines, 0 `warning:` lines.
- Default `lake build` through the guard: exit 0, 2975 jobs, 0 `error:`, 0 `warning:`.
- The `.olean` of each of the seven edited modules is newer than its source.

### 2.3 Generated surfaces and build-free gates after the edit

- `scripts/typst-sync-check.sh --fix` rewrote `typst/generated/status.typ` (line count 406468 ->
  406467, stamp commit). `--counts-only` exit 0; bare `typst-sync-check.sh` exit 0 (all 4 checks),
  `automation-module-map.typ` not drifted.
- `check-module-invariants.sh --emit-inventory` rewrote three README blocks: `README.md`,
  `FormalSystem/Metalogic/README.md`, `Termination/README.md`. `--emit-inventory --check` exit 0.
- `check-module-invariants.sh --no-build`: exit 0, `ALL CHECKS PASSED`.
  `check-metalogic-cycles.sh`: exit 0. No finding absent from the Phase 1 record (both records are
  empty).

## 3. Post-change measurement

Tree: HEAD `942c0cbcc` (the commit carrying the seven edits), rebuilt. Same probe, same script and
same 852-module universe as section 1.2.

### 3.1 Rebuild sets, before and after

| Edited module | Before | After | Termination before | Termination after |
|---|---|---|---|---|
| `FormalSystem.ProofSystem.Axioms` | 520 | 520 | 25 | 25 |
| `FormalSystem.Semantics` (aggregator) | 251 | 204 | 23 | 0 |
| `FormalSystem.Syntax` (aggregator) | 107 | 29 | 23 | 0 |
| `FormalSystem.ProofSystem.Derivation` | 361 | 356 | 25 | 23 |
| `FormalSystem.Syntax.Context` | 544 | 538 | 25 | 23 |
| `FormalSystem.ProofSystem.Derivable` | 354 | 349 | 25 | 23 |
| `FormalSystem.ProofSystem.DerivedAxioms` | 339 | 334 | 25 | 23 |
| `FormalSystem.Syntax.Formula` | 769 | 769 | 25 | 25 |
| `FormalSystem.Syntax.Subformulas` | 298 | 284 | 25 | 23 |
| `FormalSystem.Syntax.SubformulaClosure.Closure` | 297 | 283 | 25 | 23 |
| `FormalSystem.Syntax.SubformulaClosure.NestingDepth` | 233 | 165 | 23 | 0 |
| `FormalSystem.Syntax.SubformulaClosure.TemporalFormulas` | 224 | 155 | 23 | 0 |
| `FormalSystem.Semantics.Validity` | 445 | 404 | 23 | 0 |
| `FormalSystem.Semantics.Truth` | 485 | 444 | 23 | 0 |
| `FormalSystem.Semantics.TaskFrame` | 561 | 520 | 23 | 0 |

**An edit to `ProofSystem/Axioms.lean` rebuilds the same 520 modules as before, all 25 termination
modules among them.** No module left or entered that set. This is the acceptance metric, and the
change does not move it: the path from the subtree to `Axioms.lean` is essential (section 3.3).

The gains are elsewhere. No termination module is downstream of any `Semantics` module or of the
`Syntax` aggregator any more. 47 modules left the rebuild set of `Semantics.lean`: `Fuel`,
`MintBound` and its 21 submodules, `Closure`, `Saturation`, `TraceCertificate`, `ProofExtraction`,
`Verified/Decidable`, seven `Verified/Bridge` modules, three `Automation` modules and nine test
modules. `SubformulaProperty` and `TimeTypeBound` left the rebuild sets of `Derivation`,
`Derivable`, `DerivedAxioms`, `Syntax.Context`, `Subformulas` and `SubformulaClosure.Closure`.

Import closure of the subtree: 27 `FormalSystem` modules outside `Termination/` (was 122), none
under `Semantics` (was 75). `Fuel`'s closure holds 3181 modules outside the project (was 4126).

Every measured figure equals the plan's predicted figure for its row.

### 3.2 Edge classification against the landed imports

Numbering and declaration-level use counts are the research report's
(`reports/01_termination-syntax-fanin.md`, `Expr.getUsedConstants` over types and values); the last
column is the state of the edge on the landed tree.

| # | Edge | Evidence | Class | Landed |
|---|------|----------|-------|--------|
| 1 | `SignedFormula` -> `Syntax.Formula` | 483 uses of `Formula` and its constructors | Essential | kept |
| 2 | `SignedFormula` -> `ProofSystem` (aggregator) | 0 uses of any `ProofSystem.*` constant in `SignedFormula` | Reducible | narrowed to `ProofSystem.Axioms`, which `Tableau` needs through it (edge 3) |
| 3 | `Tableau` -> `ProofSystem.Axioms` (via `SignedFormula`) | 84 uses, all `FrameClass`, its constructors and order instances | Essential for `FrameClass` | kept |
| 4 | `Tableau` -> `Derivation`, `Derivable`, `DerivedAxioms`, `LinearityDerivedFacts`, `Syntax.Context` (via 2) | 0 uses | Reducible | removed |
| 5 | `SubformulaProperty` -> `Tableau` | 2057 uses (`applyRule`, `isApplicable`, the `as*?` destructors) | Essential | kept |
| 6 | `SubformulaProperty` -> `Syntax.SubformulaClosure.Closure` | 0 uses | Reducible | removed |
| 7 | `TimeTypeBound` -> `SubformulaProperty` | uses its closure theorems | Essential | kept |
| 8 | `Fuel` -> `Saturation` | 86 uses (`expandBranchWithFuel`, `BudgetedTableau`, `soundFuel`, ...) | Essential | kept |
| 9 | `Fuel`/`MintPotential` -> `Syntax.SubformulaClosure.Closure` (via `Saturation`) | `subformulaClosure` (22 uses); `soundFuel` is defined with it | Essential | kept |
| 10 | `Saturation` -> `Closure` | 402 uses (`ClosedBranch`, `findClosure`, `ClosureReason`) | Essential | kept |
| 11 | `Saturation` -> `TraceCertificate` | 64 uses (`TraceM`) | Essential | kept |
| 12 | `Closure` -> `Automation.ProofSearch.Core` | `matchAxiom`, `matchMirror`, `matchPriorSZ` in `checkAxiomNeg` | Essential | kept |
| 13 | `Closure` -> `ProofSystem.Axioms`, `ProofSystem.Derivation` | `Axiom` (7), `DerivationTree` (33): `ClosureReason.axiomNeg` stores a `DerivationTree` witness | Essential | kept |
| 14 | `Core` -> `ProofSystem` (aggregator) | uses `Axioms` (111), `Derivation` (71), `DerivedAxioms` (13); 0 of `Derivable`, `LinearityDerivedFacts` | Essential for three modules, reducible for two | narrowed to `Derivation` + `DerivedAxioms` |
| 15 | `Core` -> `Semantics` (aggregator) | 0 uses of any constant of any Semantics module | Reducible | removed |
| 16 | `Core` -> `Theorems.{Combinators, Perpetuity.Helpers, ConnectDerived, LinearityDerived}` | 17 uses; `matchAxiom`'s witnesses are built from them | Essential | kept |
| 17 | `Core` -> `SuccessPatterns` -> `Syntax` (aggregator) | `SuccessPatterns` uses `Syntax.Formula` only | Reducible | narrowed to `Syntax.Formula` |
| 18 | `TraceCertificate` -> `Syntax` (aggregator) | uses `Syntax.Formula` only | Reducible | removed (arrives via `SignedFormula`) |
| 19 | `TraceCertificate` -> `ProofSystem` (aggregator) | 29 uses, all `FrameClass` | Reducible | removed (arrives via `Closure`) |
| 20 | `MintBound.*` -> lower layers | `Syntax.Formula`/`Atom`, `FrameClass`, `subformulaClosure`, all inherited through `Fuel` | Essential | kept |

Two tactic-provenance edges were made explicit: `Fuel` -> `Mathlib.Tactic.Ring` (`ring`,
`norm_num` in `Fuel` and the `MintBound` cone) and `ClosureResidual` -> `Mathlib.Data.Finset.Max`
(`Finset.max'`). Both reached the subtree only through `Core`'s Semantics import.

### 3.3 Recommendation

- **Taken: narrow (R1-R4).** Seven import-line edits; no declaration, statement or proof touched.
  They remove every incidental edge in the table.
- **`Axioms.lean`: leave as is.** `Fuel` and `MintBound` are stated over `ClosedBranch` and
  `expandBranchWithFuel`, whose types contain `ClosureReason`, hence `DerivationTree`, hence
  `Axiom`. `Tableau`, `SubformulaProperty` and `TimeTypeBound` need `FrameClass`, which is declared
  in `Axioms.lean`. No import change cuts either path.
- **Not taken: relocate `FrameClass` (R5).** It would take four modules (`SignedFormula`,
  `Tableau`, `SubformulaProperty`, `TimeTypeBound`) out of the `Axioms.lean` rebuild set, 520 ->
  516 by the report's simulation, at the cost of shifting 33 `Axioms.lean:NNN` citations and adding
  a module. Open to the user as a follow-up.
- **Not taken: abstract `findClosure` behind an interface (R6).** It would change definitions the
  decision procedure runs and statements that are proved, which the task excludes.

### 3.4 Gates on the landed tree

| Gate | Result |
|---|---|
| `lake build` through the guard | exit 0, guard `result` `state=complete exit_status=0`, 2975 jobs, 0 `error:`, 0 `warning:` |
| `bash scripts/check-module-invariants.sh` (full mode) | exit 0, `ALL CHECKS PASSED`; C1, C2 (fifty pinned axiom sets match baseline), C3 (zero structural sorry), C4, C14, C20, C25, C28 (0 warnings) all PASS |
| `bash scripts/check-metalogic-cycles.sh` | exit 0 |
| `bash scripts/typst-sync-check.sh` | exit 0, all 4 checks |
| sorry census over all source roots | `sorry_count: 0` |
| `^axiom ` count over the source roots | 14, same as at `6350193cc` |
| non-import changed lines in the seven files, `73f45155a..HEAD` | 0 |
| `check-task-references.sh` on each edited non-`specs/` file | exit 0 on all 11 |
| `lake build BimodalToolsTest` | exit 1 on `CertificateImportTest` only; predates this change (section 2.2) |
| `.claude/scripts/verify-deploy.sh` | not run here: the dispatch carries a batch gate deferral, so the complete gate set runs once at the batch stage. The repository-specific criteria above have no `--only`/`--only-gate` mapping and were run directly. |

# Research Report: BimodalTools library split

**Task**: 632 - bimodaltools_split
**Started**: 2026-09-20T20:33:36-07:00
**Completed**: 2026-09-20T21:05:00-07:00
**Effort**: large (25 module moves, 12 exe re-roots, ~9 harness scan-root edits, 2 new libraries)
**Dependencies**: 630 (landed — `scripts/move-modules.py` exists and has one production relocation behind it)
**Sources/Inputs**:
- `docs/development/PUBLICATION_REFACTOR.md` Phase 3 + Sections 4/6 (the literature source for this task)
- `python3 scripts/measure-refactor-partitions.py automation-partition` (live measurement)
- Codebase: `lakefile.toml`, `scripts/check-module-invariants.sh`, `scripts/move-modules.py`, `scripts/lake_targets.py`, `scripts/typst-module-map.sh`, `.github/workflows/ci.yml`
- lean-lsp MCP: not required — no new Mathlib lemma is involved; this is a build-graph refactor with zero proof obligations
**Artifacts**:
- `specs/632_bimodaltools_split/reports/01_bimodaltools-library-split.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The move set is confirmed at 25 modules / 14,750 lines**: 24 under `FormalSystem/Automation/`
  plus `FormalSystem/Metalogic/Decidability/TraceExport.lean`. Of the 24, **12 end in `Main` and
  are `lean_exe` roots**; the other 13 (incl. TraceExport) are importable tooling libraries.
- **`FormalSystem/Automation.lean` is the hidden blocker.** The aggregator imports 8 of the
  tooling modules, which is the *only* reason `lake build` currently compiles them. The partition
  script prunes the aggregator from its walk, so this edge does not appear in its output. Dropping
  those 8 imports is the change that actually makes the split real.
- **Two tooling modules go unreachable after the split** — `DatasetAssembly` and
  `PrefilterSoundness` are in no exe-root closure and no test closure. A `BimodalTools.lean`
  aggregator importing the 13 non-`Main` modules fixes this *and* lets the C6 manifest line for
  `FormalSystem.Automation.ProofFirstBenchmark` be deleted (net simplification of the manifest).
- **SuccessPatterns: keep it whole in the library.** It is pure data (`Std.Data.HashMap` only, no
  IO, no JSON), it is used by `ProofSearch/Core.patternAwareScore` and
  `ProofSearch/Strategies.{searchWithLearning,batchSearchWithLearning}` — library API exercised by
  a live test — and the 5 tooling importers use only `PatternKey` / `GoalCategory` /
  `goalCategory`. There is no learning/serialisation half to split off.
- **The namespace rename is affordable and should be done in this task** (measured: 8 FQN
  citations to hand-fix, ≤5 `open FormalSystem.Automation` lines to add, 6 `namespace`/`end`
  pairs to hand-edit), but the namespace map **must never contain a bare
  `FormalSystem.Automation -> BimodalTools` row** — that prefix is shared with the library half.
- **The largest under-appreciated risk is silent gate-coverage loss**: at least 9 invariant checks
  hardcode `FormalSystem` (and `Tests`, `scripts`) as their scan root. Moving 14,750 lines to
  `BimodalTools/` removes them from those checks' denominators without any check turning red.
  `C25N` is the worst case — its stray-`Main` walk would stop seeing all 12 exe roots and pass
  vacuously.
- Baseline established: `bash scripts/check-module-invariants.sh --no-build` is **green today**
  (0 FAIL) on the current tree, so any post-split failure is attributable to this work.

## Context & Scope

Researched: how to create `lean_lib BimodalTools` (outside `defaultTargets`) and
`lean_lib BimodalToolsTest`, move the 25 tooling modules, re-root the 12 `lean_exe` targets, move
the tooling tests, re-point `Examples/BimodalProofs.lean`, decide `SuccessPatterns`, and update
the CI exe-root step and the automation-module-map generator — with every gate that observes the
moved paths identified.

Out of scope (later PUBLICATION_REFACTOR phases, deliberately not touched here): the
`Tactic/Attr.lean` merge and `PropDecide` relocation (Phase 4), the `XLanguage/` merges (Phase 5),
and the `mk_all --check` adoption (Phase 8).

## Literature Proof Structure

**Source**: `docs/development/PUBLICATION_REFACTOR.md`, Phase 3 ("Split tooling into
`BimodalTools`", lines 327-342), with Section 4's target tree (lines 90-110), lakefile shape
(lines 119-158) and namespace map (lines 160-174).
**Strategy**: direct construction — declare the new targets, relocate by mapping, re-point the
gates, assert the separation with a new invariant.

### Step Map

1. Create `lean_lib BimodalTools` and `lean_lib BimodalToolsTest` — Section 4, "Lakefile target
   shape" (lines 138-143).
2. Move the 25 tooling modules including `Metalogic/Decidability/TraceExport.lean` — Phase 3
   bullet 1; module set enumerated by `measure-refactor-partitions.py automation-partition`.
3. Re-root the 12 exes under `BimodalTools.*`, names unchanged — Phase 3 bullet 1 + lines 145-158.
4. Move the tooling tests (3 root-level `Trace*` files + the `Tests/BimodalTest/Automation/` files
   importing tooling) into `BimodalToolsTest/` — Phase 3 bullet 2.
5. `Examples/BimodalProofs.lean` imports specific Automation modules instead of the aggregator —
   Phase 3 bullet 3.
6. Decide `SuccessPatterns`; the `ProofSearch/Core -> SuccessPatterns` edge is the one to inspect —
   Phase 3 bullet 4 (Phase 4 line 358 consumes this decision).
7. Update the CI exe-root step, `scripts/typst-module-map.sh` and the automation-module-map
   generator — Phase 3 bullet 5.
8. Acceptance: zero `.olean` under `BimodalTools` from `lake build`; a new check asserts
   `FormalSystem` never imports `BimodalTools`; `lake build BimodalToolsTest` exits 0 in CI;
   harness green — Phase 3 bullet 6.

### Dependencies

- Steps 3, 4, 5 all depend on Step 2 (the move) having landed.
- Step 6 (`SuccessPatterns`) is independent and should be decided **before** Step 2, because the
  answer determines whether `SuccessPatterns.lean` is in the move set. **Decided below: it is
  not.**
- Step 8's "no `.olean` under BimodalTools" is only meaningful once Step 2 and the
  `FormalSystem/Automation.lean` edit (see Findings) have both landed.
- Phase 4's line 358 ("cut `ProofSearch.Core -> SuccessPatterns` per Phase 3's decision") consumes
  Step 6's outcome; this report's decision is that the edge **stays**, so Phase 4's bullet is a
  no-op and should be corrected when Phase 4 is planned.

### Potential Formalization Challenges

- **Step 2**: the `FormalSystem.Automation` namespace is shared between the library half and 6 of
  the moving modules, so the namespace half of the relocation is not a single prefix rename.
- **Step 4**: `NormalizationTest.lean` straddles the split (it tests library `Normalization` *and*
  tooling `FormulaEnumerator`) and needs splitting, not moving.
- **Step 7**: `typst-module-map.sh` turns out to need **no functional change** (see Findings) —
  the task description's phrasing implies otherwise.

## Findings

### Codebase Patterns

#### The move set (measured, 25 modules / 14,750 lines)

`FormalSystem/Automation/` — 24 modules. Namespace column is what the file actually declares:

| Module | Lines | exe root | Declared namespace |
|---|---:|---|---|
| `AtomCanonicalization` | 141 | | `FormalSystem.Automation.AtomCanonicalization` |
| `AxiomNames` | 59 | | `FormalSystem.Automation` (**bare**) |
| `BenchmarkAnchorsMain` | 591 | `benchmark_anchors` | `...Automation.BenchmarkAnchorsMain` |
| `BenchmarkOracleMain` | 353 | `benchmark_oracle` | `...Automation.BenchmarkOracleMain` |
| `ContrastiveGeneratorMain` | 1121 | `contrastive_generator` | `...Automation.ContrastiveGeneratorMain` |
| `DataExport` | 396 | | `...Automation.DataExport` |
| `DatasetAssembly` | 341 | | `...Automation.DatasetAssembly` |
| `DatasetGenerator` | 1723 | | `FormalSystem.Automation` (**bare**) |
| `DatasetGeneratorMain` | 1343 | `dataset_generator` | `...Automation.DatasetGeneratorMain` |
| `DatasetValidatorMain` | 594 | `dataset_validator` | `...Automation.DatasetValidatorMain` |
| `EnrichedCountermodel` | 223 | | `FormalSystem.Automation.Enriched` (**name ≠ module**) |
| `EnumBenchmarkMain` | 227 | `enum_benchmark` | **none** (root namespace) |
| `FormulaEnumerator` | 2036 | | `FormalSystem.Automation` (**bare**) |
| `ForwardProofGenerator` | 349 | | `FormalSystem.Automation` (**bare**) |
| `InterestingnessMetrics` | 577 | | `...Automation.InterestingnessMetrics` |
| `MachineAppendixMain` | 474 | `machine_appendix` | `...Automation.MachineAppendixMain` |
| `PrefilterSoundness` | 172 | | `...Automation.PrefilterSoundness` |
| `ProofExtractorMain` | 1542 | `proof_extractor` | `...Automation.ProofExtractorMain` |
| `ProofFirstBenchmark` | 189 | | `FormalSystem.Automation` (**bare**) |
| `ProofFirstGeneratorMain` | 148 | `proof_first_generator` | `FormalSystem.Automation` (**bare**) |
| `ProofStepExtractor` | 340 | | `...Automation.ProofStepExtractor` |
| `TableauBridgeMain` | 635 | `tableau_bridge` | `...Automation.TableauBridgeMain` |
| `TableauProofStepsMain` | 688 | `tableau_proof_steps` | `...Automation.TableauProofStepsMain` |
| `TraceExporterMain` | 265 | `trace_exporter` | `...Automation.TraceExporterMain` |

Plus `FormalSystem/Metalogic/Decidability/TraceExport.lean` (223 lines, namespace
`FormalSystem.Metalogic.Decidability.TraceExport`). No live library module imports it — only
`TraceExporterMain` and the three `Trace*Test` files do.

The library half that **stays** under `FormalSystem/Automation/`: `LemmaDB`, `Normalization`,
`NormalizationAttr`, `TruthNormAttr`, `SuccessPatterns`, `ProofSearch/{Core,Strategies}`,
`Tactics/{Commands,Deduction,Meta,PropDecide,Search,UserTactics}`.

#### `FormalSystem/Automation.lean` imports 8 tooling modules (the real blocker)

```
FormalSystem/Automation.lean:16  import FormalSystem.Automation.FormulaEnumerator
                             :17  import FormalSystem.Automation.DatasetGenerator
                             :18  import FormalSystem.Automation.DataExport
                             :19  import FormalSystem.Automation.EnrichedCountermodel
                             :20  import FormalSystem.Automation.DatasetAssembly
                             :21  import FormalSystem.Automation.ProofStepExtractor
                             :23  import FormalSystem.Automation.InterestingnessMetrics
                             :24  import FormalSystem.Automation.PrefilterSoundness
```

`FormalSystem/FormalSystem.lean:20` imports `FormalSystem.Automation`, so `lake build` reaches all
8 today. `measure-refactor-partitions.py` prunes `FormalSystem.Automation` from its walk
(`AUTOMATION_PRUNE_MODULES`), which is why these 8 edges are invisible in its report. **These 8
import lines must be deleted**, and the aggregator's module-list docstring (lines ~90-105) updated.

Other importers of the `FormalSystem.Automation` aggregator, all of which must be re-pointed at
specific library modules:

- `FormalSystem/Examples/BimodalProofs.lean:9` (named in the task)
- `FormalSystem/Examples/Walkthrough.lean:9` (**not named in the task — same fix required**)
- `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean:7`
- `FormalSystem/FormalSystem.lean:20` (keeps importing the aggregator; the aggregator is
  library-only after the edit)

#### Reachability after the split

Computed over the tooling import graph from the 12 exe roots plus the 9 tooling tests:

- Reachable from an exe root: 22 of 25.
- `ProofFirstBenchmark`: reachable only from `BimodalTest.Automation.ProofFirstTests` (already C6-
  manifested today).
- **`DatasetAssembly` and `PrefilterSoundness`: reachable from nothing.** Today they are reached
  only through the `Automation.lean` aggregator.

Resolution: `BimodalTools.lean` (the `lean_lib BimodalTools` root, which must exist for
`lake build BimodalTools` to work at all) imports the **13 non-`Main`** modules
(`AtomCanonicalization`, `AxiomNames`, `DataExport`, `DatasetAssembly`, `DatasetGenerator`,
`EnrichedCountermodel`, `FormulaEnumerator`, `ForwardProofGenerator`, `InterestingnessMetrics`,
`PrefilterSoundness`, `ProofFirstBenchmark`, `ProofStepExtractor`, `TraceExport`). It **must not**
import any `*Main` module — each declares a root-namespace `main` and importing two collides. This
makes all 13 reachable and lets the C6 manifest line `FormalSystem.Automation.ProofFirstBenchmark`
be **deleted** rather than renamed.

#### `SuccessPatterns` decision: keep whole, in the library

Evidence:

- Imports only `Std.Data.HashMap` and `FormalSystem.Syntax`. No `IO`, no `Json`, no serialisation
  — there is no "learning/serialisation half" to move (`statistics` returns a `String`).
- Library consumers: `ProofSearch/Core.lean:11` (`patternAwareScore` takes
  `patternDb : PatternDatabase` and calls `heuristicBonus`) and, transitively,
  `ProofSearch/Strategies.lean:317,350` (`searchWithLearning`, `batchSearchWithLearning`), which
  `Tests/BimodalTest/Automation/ProofSearchBenchmark.lean:351,366` exercises in the default test
  run.
- Tooling consumers use only the data vocabulary: `DatasetGenerator` (`PatternKey` ×9),
  `DataExport` (`PatternKey` ×12, `GoalCategory` ×9), `FormulaEnumerator` (`GoalCategory` ×8,
  `goalCategory` ×2), `ProofFirstBenchmark` (`goalCategory` ×1), `ForwardProofGenerator` (none —
  the import is now unused and can be dropped).

`BimodalTools` importing `FormalSystem` is the sanctioned direction, so leaving `SuccessPatterns`
in the library costs the tooling nothing. **Record the decision in
`FormalSystem/Automation/README.md`** as Phase 3 bullet 4 requires ("otherwise keep it and
document why"), and note that Phase 4's "cut `ProofSearch.Core -> SuccessPatterns`" bullet
(PUBLICATION_REFACTOR.md:358) is superseded.

#### Test split

`measure-refactor-partitions.py` lists 9 test files importing tooling. Correct disposition:

| Test file | Disposition |
|---|---|
| `Tests/BimodalTest/TraceCertificateTest.lean` | move to `Tests/BimodalToolsTest/` |
| `Tests/BimodalTest/TraceExportTest.lean` | move |
| `Tests/BimodalTest/TraceExporterE2ETest.lean` | move |
| `Tests/BimodalTest/Automation/C5SmokeTest.lean` | move |
| `Tests/BimodalTest/Automation/DatasetGeneratorTest.lean` | move |
| `Tests/BimodalTest/Automation/InterestingnessTest.lean` | move |
| `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` | move; stays C6-manifested (imports an exe root with `main`) |
| `Tests/BimodalTest/Automation/ProofFirstTests.lean` | move; stays C6-manifested (same reason) |
| `Tests/BimodalTest/Automation/NormalizationTest.lean` | **split, do not move** |

`NormalizationTest.lean` (588 lines) imports library `Normalization` **and**
`Metalogic.Decidability.DecisionProcedure` **and** tooling `FormulaEnumerator`. Only two regions
depend on the enumerator: the `decide`-timing block at lines ~233-250
(`FormalSystem.Automation.smallConfig`, `...enumerateUpToDepth`) and
`section EnumeratorCounts` at lines 560-586. Extract those into
`Tests/BimodalToolsTest/EnumeratorCountsTest.lean`; the remainder stays in `BimodalTest` so the
library's normalization coverage stays inside `lake test`.

`Tests/BimodalTest.lean` loses 8 import lines (42, 47, 48, 51, 52, 53, 54 and the
`NormalizationTest` line is kept) and its prose block at lines 79-94, which names
`Automation/ContrastiveGeneratorMain.lean`, `Automation/ProofFirstGeneratorMain.lean` and
`Automation/DatasetValidatorMain.lean` in **bare** form.

#### Harness scan roots that hardcode `FormalSystem` (the silent-coverage risk)

Every one of these must gain `BimodalTools` (and, where `Tests` is walked, `Tests/BimodalToolsTest`
comes for free since it lives under `Tests/`), or 14,750 lines leave the gate's denominator with
no check turning red:

| Check | Site | What is lost |
|---|---|---|
| C3 (structural `sorry`) | `check-module-invariants.sh:903` | tooling sorry inventory |
| C7 (live inventory) | `:1117-1118` | line/module counts |
| C8 (aggregator convention) | `:1154` walked-parents tuple | `BimodalTools.lean` beside `BimodalTools/` unchecked |
| C16 (env_linter, enforced half) | `:2450`, `:2559` | tooling declaration lints (second half covers every lakefile root but `ENFORCE_C16_ROOTS=0`) |
| C17 (dead declarations) | `:2845` | tooling dead-decl scan |
| C19 (docstring coverage) | `:3226` | tooling docstrings |
| C20 (`file.lean:NNN` citations) | `:2141` `SCAN_ROOTS` | tooling line citations |
| **C25N (stray `Main`)** | `:3580` `("FormalSystem","Tests","scripts")` | **all 12 exe roots leave the walk; a stray `BimodalTools/XMain.lean` becomes invisible** |
| C26 (snake_case / nolint) | `:3686`, `:3778` | tooling naming lints |
| C27 (debug directives) | `:3950` | tooling `#eval`/`dbg_trace` |
| C29 / C30 (linter suppressions) | `:4100`, `:4306` `ROOTS` tuple | tooling suppressions |

Outside the harness:

- `.github/workflows/ci.yml:111` runs `check-copyright-headers.sh --strict FormalSystem` — add
  `BimodalTools`.
- `readme-lint.sh` defaults to `ROOTS=("FormalSystem")` (script line 44) and CI calls it with no
  args — pass `FormalSystem BimodalTools` so Check 1 ("every directory with `.lean` files has a
  `README.md`") covers the new tree. A `BimodalTools/README.md` (with a
  `<!-- BEGIN GENERATED: inventory dir=BimodalTools -->` block) is therefore required.
- `FormalSystem/Automation/README.md` carries
  `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation -->` (line 51) and must be
  regenerated via `check-module-invariants.sh --emit-inventory` after the move; INV gates it.

Checks that need **no** change:

- **C24** — `scripts/CheckInitImportsMain.lean:54` filters on ``name.getRoot = `FormalSystem``, so
  `BimodalTools.*` modules are excluded automatically. (Consequence worth stating in the plan:
  tooling modules are then *not* Init-checked. That is the correct outcome — `Init` is the
  library's root — but it should be a recorded decision, not an accident.)
- **C25** and the CI "Compile `lean_exe` roots" step — both read roots at run time via
  `scripts/lake_targets.py exe-roots`, so re-rooting is picked up automatically. **The CI step
  itself needs no edit**; what CI needs is a *new* step for `lake build BimodalToolsTest`
  (Phase 3 acceptance), plus `lake build BimodalTools`.
- **C22** hardcodes `FormalSystem/Automation/AxiomNames.lean` and
  `.../ProofExtractorMain.lean` (`:3358-3359`) in full-prefix slash form, so `move-modules.py`
  rewrite class 3 handles it — but its header comment at `:3342` uses the **bare** form
  `Automation/AxiomNames.lean` and will not be rewritten.
- **`scripts/typst-module-map.sh`** globs exactly `Automation/Tactics/*.lean`,
  `Automation/ProofSearch/*.lean` and `Automation/SuccessPatterns.lean` — **all of which stay in
  the library**. It needs no functional change, and `typst-sync-check.sh` Check 2b keeps passing.
  Only its header comment (lines 12-20) and the `Role` dictionary assertion in
  `typst/chapters/p4-proof-automation.typ:127` would be affected *if* rows changed; with
  `SuccessPatterns` staying, they do not. **The task description's "update typst-module-map.sh and
  the automation-module-map generator" names one script twice, and the correct answer for both is
  "no change needed" — verify by running `scripts/typst-sync-check.sh` rather than editing.**

#### Citation rewrite volume

Full-prefix citations (`FormalSystem/Automation/<tool>.lean` or `FormalSystem.Automation.<tool>`),
which `move-modules.py` rewrites automatically:

| Area | count |
|---|---:|
| `FormalSystem/` | 138 |
| `Tests/` | 20 |
| `scripts/` | 11 |
| `docs/` | 5 |
| `typst/` | 2 |
| `.github/` | 1 |
| **total** | **177** |

**Bare-form citations `Automation/<tool>.lean` — 11 sites `move-modules.py` will NOT rewrite**
(its rewrite rules anchor on the full old prefix by design; see its "bare-token trap" header).
Unlike the Boneyard relocation, where bare forms were *correct after* the move, here they are
*stale after* the move and need hand edits:

```
typst/chapters/p4-dataset-pipeline.typ:30   Automation/EnrichedCountermodel.lean
typst/chapters/p4-dataset-pipeline.typ:39   Automation/DatasetGeneratorMain.lean
typst/chapters/ax-machine-appendix.typ:44   Automation/DataExport.lean
docs/development/NAMING_CONVENTION_DEVIATION.md:406,407,453   MachineAppendixMain / DatasetGeneratorMain
docs/reference/paper-definitions-of-record.md:161             Automation/DataExport.lean, DatasetGenerator.lean
scripts/check-module-invariants.sh:3342                       Automation/{AxiomNames,ProofExtractorMain}.lean
FormalSystem/Metalogic/Decidability/README.md:37              Automation/TraceExporterMain.lean
Tests/BimodalTest.lean:92,94                                  3 bare Main citations
```

`scripts/module-invariants-allowlist.txt:15-22` additionally carries two tooling namespaces
(`FormalSystem.Automation.Enriched`, `FormalSystem.Automation.DataExport.RuleProfile`) with bare
`Automation/...` path comments.

#### Namespace rename: measured cost

The `FormalSystem.Automation` namespace is **shared** between the library half (`SuccessPatterns`,
`ProofSearch/Core`, `ProofSearch/Strategies`, all six `Tactics/*`) and 6 moving modules. A bare
`FormalSystem.Automation -> BimodalTools` row in `--namespace-map` would rewrite the library's own
namespace and is a hard prohibition.

The safe map has three tracks:

1. **17 dotted rows** (one per tooling module whose namespace is `FormalSystem.Automation.<X>`),
   plus `FormalSystem.Automation.Enriched -> BimodalTools.Enriched` (a namespace whose name does
   not match its module) and
   `FormalSystem.Metalogic.Decidability.TraceExport -> BimodalTools.TraceExport`. Longest-prefix-
   first matching keeps these from colliding with the bare prefix, which is simply absent from the
   map.
2. **6 hand-edited files** whose `namespace FormalSystem.Automation` / `end` pair becomes
   `namespace BimodalTools` / `end BimodalTools`: `AxiomNames`, `DatasetGenerator`,
   `FormulaEnumerator`, `ForwardProofGenerator`, `ProofFirstBenchmark`, `ProofFirstGeneratorMain`.
   `EnumBenchmarkMain` declares no namespace and needs nothing.
3. **≤5 added `open FormalSystem.Automation` lines.** Only 8 of the 25 tooling modules import a
   library Automation module at all, and 3 of those already carry the `open`
   (`BenchmarkAnchorsMain`, `DataExport`, `DatasetGeneratorMain`). The ones that need it added:
   `DatasetGenerator`, `FormulaEnumerator`, `ForwardProofGenerator`, `ProofFirstBenchmark`,
   `ProofStepExtractor`.

Exposure from citations of declarations owned by the 6 bare-namespace files: **8 FQN occurrences
across the whole tree**, of which 6 are inside `ProofFirstGeneratorMain` itself (which moves), 1 is
a docstring in `MachineAppendixMain` (which moves), and 2 are in `NormalizationTest.lean` lines
243-244 (which move into the split-off enumerator test). Nothing else in the repository names a
bare-namespace tooling declaration by FQN.

### External Resources

- `scripts/move-modules.py` is the right tool and was built for exactly this shape of job. Two
  edits it needs first:
  - `MODULE_ROOT_DIRS = {"BimodalTest": "Tests"}` (line ~89) must gain
    `"BimodalToolsTest": "Tests"`, or the derived path for every moved test will be wrong.
    `BimodalTools` itself is at the repository root, so it needs no entry.
  - Its `PRUNE_DIRS` already excludes `specs/`, `.lake/`, `__pycache__` — correct here.
  - Its rewrite class 5 (axiom baselines) is a no-op for this move: no tooling declaration is
    axiom-pinned in C2/C14 or `MainResults.lean`.
- Lake places `.olean` files under `.lake/build/lib/lean/<Module>/...`, **not** under the source
  directory. The Phase 3 acceptance "writes no `.olean` under `BimodalTools/`" must be checked as
  `find .lake/build/lib/lean/BimodalTools -name '*.olean'` being empty after a clean
  `lake build`, not as a walk of the source tree. State this explicitly in the plan or the
  acceptance will be tested against a path that is empty for the wrong reason.
- `lakefile.toml`'s existing comment block (lines 17-27) explains that `[[lean_exe]]` roots do not
  inherit a library's `leanOptions`, only package-level ones. `BimodalTools` should therefore
  carry the same `leanOptions = {pp.unicode.fun = true, autoImplicit = false}` as `FormalSystem`,
  and `BimodalToolsTest` the same three-key set as `BimodalTest` (including
  `weak.linter.hashCommand = false`, since the moved tests are `#guard`/`#eval` probes).

### Recommendations

1. **Decide `SuccessPatterns` first and record it** — keep whole in `FormalSystem/Automation/`;
   document the reason in `FormalSystem/Automation/README.md`; note that PUBLICATION_REFACTOR.md
   Phase 4's "cut the edge" bullet is superseded.
2. **Sequence the work so the tree is never half-moved across a commit boundary.** Suggested phase
   shape (each ends green and is committable):
   - P1: declare `BimodalTools` / `BimodalToolsTest` in `lakefile.toml`; author `BimodalTools.lean`,
     `Tests/BimodalToolsTest.lean`, `BimodalTools/README.md`, `Tests/BimodalToolsTest/README.md` as
     stubs. Nothing moves yet; harness stays green.
   - P2: teach the gates the new roots (the 11-row table above, plus `readme-lint.sh` and
     `check-copyright-headers.sh` invocations in CI). Still nothing moved — so every edit is a
     pure widening and any failure is unambiguous.
   - P3: the move itself, as one `move-modules.py --module-map` + `--namespace-map` run
     (`--dry-run` first), plus the `FormalSystem/Automation.lean` import deletion, the four
     aggregator re-points, and the 11 bare-form hand edits — one atomic commit, because the tree
     does not build between them.
   - P4: the `NormalizationTest` split and the `Tests/BimodalTest.lean` / `BimodalToolsTest.lean`
     aggregator wiring; delete the `ProofFirstBenchmark` C6 manifest line; regenerate inventories.
   - P5: the new separation invariant, CI steps, and full acceptance.
3. **The new invariant should be modelled on B1/B2, not invented.** B2
   (`check-module-invariants.sh:752-770`) is the exact shape: `grep -rnE '^import[[:space:]]+…'`
   over the live tree, matched on the `import` keyword so a docstring citation is not a failure.
   Propose `B3`: zero `^import BimodalTools(\.|$)` under `FormalSystem/`, **and** zero
   `BimodalTools` in `FormalSystem.lean` / `FormalSystem/FormalSystem.lean` (the B1 half). Add the
   converse direction as a note: `BimodalTools -> FormalSystem` is the *sanctioned* direction and
   must not be gated.
4. **Two CI steps, not one.** Phase 3 names `lake build BimodalToolsTest`; also add
   `lake build BimodalTools`, otherwise `DatasetAssembly` / `PrefilterSoundness` are compiled by
   nothing in CI even with the aggregator in place (the `BimodalToolsTest` closure does not reach
   them). Place both after the existing exe-root step so they reuse the warm cache. Note that
   neither carries `--wfail`, so C28's warning budget is the only thing watching tooling warnings —
   which is a further reason C28's scan root must be widened.
5. **Do the namespace rename in this task**, on the measured evidence above (8 FQN fixes, 6
   `namespace` edits, ≤5 `open` additions). Deferring it to Phase 5 means a second churn pass over
   the same 177 citations and leaves `namespace FormalSystem.Automation` declared inside
   `BimodalTools/` — which reads as a bug to any reader of the published tree.
6. **Re-run `measure-refactor-partitions.py automation-partition` as an acceptance assertion**: it
   must report a tooling set of 0 afterwards. But note that `move-modules.py` rewrite class 2 will
   rewrite the script's own hardcoded `f"{LIB}.Metalogic.Decidability.TraceExport"` (line 309) to
   `BimodalTools.TraceExport`, which would append a phantom row. **Update that line by hand in the
   same commit** (either drop the append, or guard it on the module existing).
7. **A sorry-free / axiom-neutral path exists and is the only acceptable one.** This refactor
   introduces no proof obligation: nothing here requires `sorry` or a new axiom, and C2/C3/C14
   must be byte-identical before and after. If any of those three move, the move was wrong, not
   the baseline.

## Decisions

- **`SuccessPatterns` stays in `FormalSystem/Automation/`, undivided.** Evidence: no IO/JSON
  dependency; two library call sites in `ProofSearch/{Core,Strategies}`; tooling uses only the
  `PatternKey`/`GoalCategory` vocabulary, which it reaches through the sanctioned
  `BimodalTools -> FormalSystem` direction.
- **`BimodalTools.lean` aggregates the 13 non-`Main` modules and no `*Main` module.** This is
  forced: two `main` declarations cannot coexist in one import closure.
- **Namespaces are renamed in this task**, via a three-track map that never contains a bare
  `FormalSystem.Automation` row.
- **`scripts/typst-module-map.sh` is not edited.** Its glob covers only modules that stay.
  Acceptance is `scripts/typst-sync-check.sh` staying green, not a diff in that script.
- **`Examples/Walkthrough.lean` is added to the scope** alongside the `BimodalProofs.lean` the
  task description names; both import the `Automation` aggregator for the same reason.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| A gate silently narrows and 14,750 lines leave its denominator | Phase P2 widens every scan root **before** the move, so each widening is observable on the unmoved tree; assert C7's module/line counts are unchanged across the move |
| C25N passes vacuously after the 12 `Main` roots leave its walk | Add `BimodalTools` to its top tuple in P2; negative-test by dropping a scratch `BimodalTools/ScratchMain.lean` and confirming `FAIL C25N`, exactly as the check's own header records was done originally |
| A bare `FormalSystem.Automation -> BimodalTools` namespace row corrupts the library half | The namespace map is authored explicitly with 19 rows and reviewed; `--dry-run` output is read before the real run; `git diff --stat FormalSystem/Automation/` after the run must show only the expected library files |
| The 11 bare-form citations are missed | `move-modules.py`'s bare-form audit line reports them; the list in this report is exhaustive as of this commit — re-grep before the move and diff against it |
| `DatasetAssembly` / `PrefilterSoundness` rot unnoticed | `BimodalTools.lean` aggregator + a `lake build BimodalTools` CI step; verify by `lake build BimodalTools` failing if either is removed from the aggregator |
| `NormalizationTest` is moved wholesale, dropping library normalization coverage from `lake test` | Split it as specified; assert `lake test` still exercises `Normalization` by grepping the retained file for its `#guard`s |
| Tooling compiler warnings escape `--wfail` after the split | C28's warning budget with a widened scan root is the compensating control; state this explicitly so the gap is a recorded decision |
| Concurrent in-flight edits to `FormalSystem/Automation/` (tasks 298, 296, 282) collide with the move | The task's own reconciliation note already flags this as a scheduling recommendation; re-check `git status` for dirty paths under `FormalSystem/Automation/` immediately before P3 and stop if any are present |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task carries no proof obligation: it is a
  build-graph and module-location refactor. No `sorry` is introduced, no axiom is added, and
  C2/C3/C14 are expected to be byte-identical before and after.

## Context Extension Recommendations

- **Topic**: Lean library-splitting in this repository (a `lean_lib` outside `defaultTargets`).
- **Gap**: `context/project/lean4/` has no note on what a new Lake library obliges — a root
  aggregator file, an entry in every hardcoded harness scan root, a README with an inventory
  block, and a CI build step. This task rediscovered all four from first principles.
- **Recommendation**: after implementation, add
  `context/project/lean4/patterns/adding-a-lean-lib.md` capturing the checklist, and cite the
  11-row scan-root table above as the worked example.

## Appendix

### Verification baseline (this tree, before any change)

```
bash scripts/check-module-invariants.sh --no-build   ->  0 FAIL
```

All of B0, B1, B2, C3-C5, C8-C15, C18-C23, C25N, C26-C30, C9D and INV pass; C1, C2, C6(full),
C16(full), C17, C24, C25 report `skipped (--no-build)` or informational.

### Commands used

```
python3 scripts/measure-refactor-partitions.py automation-partition
python3 scripts/lake_targets.py exes
bash scripts/check-module-invariants.sh --no-build
```

plus targeted `grep`/`python3` passes over the import graph, the namespace declarations, the
citation forms, and the harness scan roots (reproduced inline in the Findings above).

### References

- `docs/development/PUBLICATION_REFACTOR.md` — Phase 3 (lines 327-342), target tree (90-110),
  lakefile shape (119-158), namespace map (160-174)
- `scripts/move-modules.py` — module/namespace mapping tool, rewrite classes 1-7, bare-token trap
- `scripts/check-module-invariants.sh` — B1/B2 as the template for the new separation invariant;
  C6 manifest rules; C22/C25/C25N
- `docs/development/CI_CD_PROCESS.md` — "Wiring a New Check Script" step-placement convention for
  the two new CI steps

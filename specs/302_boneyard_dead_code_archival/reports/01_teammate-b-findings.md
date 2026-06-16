# Teammate B Findings: File Organization and Sizing Analysis

**Task 302**: Boneyard dead code archival  
**Scope**: File organization, oversized files, module structure, import graph, Boneyard structure

---

## Key Findings

### 1. Repository Scale Summary

| Directory | Files | Lines |
|-----------|-------|-------|
| Metalogic/ | 170 | 115,305 |
| Automation/ | 30 | 19,997 |
| Theorems/ | 13 | 7,342 |
| Semantics/ | 5 | 1,822 |
| Syntax/ | 8 | 3,322 |
| ProofSystem/ | 5 | 1,631 |
| FrameConditions/ | 4 | 790 |
| Examples/ | 2 | 518 |
| **Boneyard/** | **42** | **28,466** |
| Root Boneyard/ | 2 | 446 |
| **Total** | **281** | **~179,809** |

---

### 2. Oversized Files (>500 lines) in Live Code

**Extreme outliers (>3000 lines) — strong split candidates:**

| File | Lines | Natural Split Points |
|------|-------|---------------------|
| `EFGames/GapDetection.lean` | 5,057 | 7 sections: GapFormulas, RankBounds, MuRelativized, GapUniqueness, CoreHelper, Lemma9Forward, Lemma9Backward |
| `Expressiveness/SplitPoint.lean` | 4,693 | 3 sections: CaseSplit (1-1172), GHR93Transfer (1172-2139), GapCases (2139-3650), Assembly |
| `Expressiveness/CaseAnalysis.lean` | 3,749 | 3 identified major sections |
| `Chronicle/PointInsertion.lean` | 3,527 | 13+ sections including Lemma 2.4, 2.5, 2.6, 2.7, 2.7', 3.2.1 |
| `Chronicle/CounterexampleElimination.lean` | 3,487 | 4 sections: C5/C5' structures, FreshRationals, C5 elimination, G-propagation |
| `EFGames/StaviCompleteness.lean` | 3,343 | (not deeply examined) |

**Large files (2000-3000 lines) — possible split candidates:**

| File | Lines | Notes |
|------|-------|-------|
| `Chronicle/ChronicleToCountermodel.lean` | 2,217 | |
| `Automation/FormulaEnumerator.lean` | 2,212 | 2 major logical sections: enumeration (1-1185) + axiom instantiation (1186-2212) |
| `IntegerModel/GoodStructuresModelSurgery.lean` | 2,167 | |
| `Kamp/KampBypassCore.lean` | 2,160 | Already split pattern from task 301; ~14 sections |
| `Automation/DatasetGenerator.lean` | 2,148 | Multiple sections incl. test suites embedded |

**Large files (1000-2000 lines) — borderline:**

| File | Lines |
|------|-------|
| `Kamp/NegationClosure.lean` | 1,837 |
| `ExpressiveCompleteness/QuantifierElimination.lean` | 1,787 |
| `Separation/DedekindZ/Cases.lean` | 1,768 |
| `EFGames/CustomGame.lean` | 1,703 |
| `Chronicle/RRelation.lean` | 1,686 |
| `Expressiveness/Claim1.lean` | 1,629 |
| `Automation/ProofStepExport.lean` | 1,588 |
| `Decidability/Saturation.lean` | 1,563 |
| `Chronicle/ChronicleConstruction.lean` | 1,510 |
| `EFGames/DiscreteGameTransfer.lean` | 1,470 |
| `Separation/Hierarchy/HierarchyInduction.lean` | 1,437 |
| `Metalogic/Soundness.lean` | 1,371 |
| `SoundnessLemmas/DenseValidity.lean` | 1,338 |
| `Kamp/KampBypassSince.lean` | 1,307 |
| `WeakCanonical/Transfer.lean` | 1,299 |
| `Syntax/SubformulaClosure/TemporalFormulas.lean` | 1,296 |
| `Automation/DatasetExport.lean` | 1,292 |
| `EFGames/NFGameBridge.lean` | 1,240 |
| `WeakCanonical/NEquivalence.lean` | 1,227 |
| `Automation/ProofSearch/Core.lean` | 1,195 |
| `Decidability/Tableau.lean` | 1,190 |
| `Bundle/SuccExistence.lean` | 1,172 |
| `Chronicle/ChronicleToCountermodelBasic.lean` | 1,163 |
| `Automation/FormulaMutator.lean` (exe target) | 1,133 |
| `IntegerModel/ReynoldsBridge.lean` | 1,122 |
| `Automation/Normalization.lean` | 1,120 |
| `Decidability/CountermodelExtraction.lean` | 1,090 |
| `EFGames/TypeFormulas.lean` | 1,068 |
| `Algebraic/UltrafilterMCS.lean` | 1,053 |
| `Separation/Hierarchy/HierarchyDefs.lean` | 1,051 |
| `Bundle/CanonicalTaskRelation.lean` | 1,041 |
| `Automation/Tactics/Helpers.lean` | 1,032 |
| `Kamp/NegationClosure5.lean` | 1,027 |

---

### 3. Module Organization Issues

#### 3a. Automation Aggregator (`Automation.lean`) Imports Only a Subset of Files

`Automation.lean` imports 14 modules but there are 30 `.lean` files in `Automation/`. Files **not** in the aggregator fall into two categories:

**Executable targets (correct — excluded by design, noted in aggregator comment):**
- `DatasetExport.lean` (exe: `dataset_generator`)
- `DatasetValidator.lean` (exe: `dataset_validator`)
- `ProofStepExport.lean` (exe: `proof_extractor`)
- `EnumBenchmark.lean` (exe: `enum_benchmark`)
- `BenchmarkAnchors.lean` (exe: `benchmark_anchors`)
- `BenchmarkOracle.lean` (exe: `benchmark_oracle`)
- `FormulaMutator.lean` (exe: `contrastive_generator`)
- `TableauBridge.lean` (exe: `tableau_bridge`)
- `TableauProofStepPipeline.lean` (exe: `tableau_proof_steps`)
- `TraceExporter.lean` (exe: `trace_exporter`)
- `ProofFirstExporter.lean` (exe: `proof_first_generator`)

**Not in aggregator AND not an exe target:**
- `AtomCanonicalization.lean` — imported by `FormulaEnumerator.lean` and `DatasetExport.lean` (indirectly in library chain; not standalone)
- `ForwardProofGenerator.lean` — imported by `DatasetGenerator.lean` and `ProofFirstExporter.lean` only
- `Tactics/Helpers.lean` — imported only by `Tactics/Commands.lean`
- `ProofFirstBenchmark.lean` — **orphan**: not an exe target, not imported by any library file; only imported by test `Tests/BimodalTest/Automation/ProofFirstTests.lean`

#### 3b. `ProofFirstBenchmark.lean` Is a Dead Library File (167 lines)

`ProofFirstBenchmark.lean` is not an exe target and is only referenced from the test suite (`Tests/BimodalTest/Automation/ProofFirstTests.lean`). It defines benchmark metrics but has no `main` function. This is a candidate for archival or formalization as a proper test-only module.

#### 3c. Redundant Naming in Automation (DataExport / DatasetExport / DatasetExporter)

Three files with similar names serve distinct roles:
- `DataExport.lean` (383 lines) — JSON serialization primitives; library file imported widely
- `DatasetExporter.lean` (343 lines) — end-to-end export pipeline assembly; library file  
- `DatasetExport.lean` (1,292 lines) — **exe target** (`dataset_generator`); the actual main program

This naming is confusing. `DatasetExport` (the exe) shadows `DataExport` (the library) in name similarity.

Similarly:
- `ProofStepExtractor.lean` (339 lines) — library for step extraction
- `ProofStepExport.lean` (1,588 lines) — exe target (`proof_extractor`)

#### 3d. `FormulaEnumerator.lean` Has Two Distinct Logical Units (2,212 lines)

The file has a clear split at line 1186:
- Lines 1–1185: Formula enumeration, sampling, diversity analysis
- Lines 1186–2212: Axiom instantiation with witnesses (Task 279)

These serve different clients: enumeration is used by many consumers; axiom instantiation is used primarily by `DatasetGenerator.lean`. This is a natural `FormulaEnumerator.lean` + `AxiomInstantiation.lean` split.

#### 3e. `DatasetGenerator.lean` Embeds Extensive Test Code (2,148 lines)

The file contains multiple `#eval` blocks and embedded unit test sections (lines 924–1167, 1887–2148). These inflate the file. Separating the test code into standalone `DatasetGeneratorTest.lean` under `Tests/` would reduce the file to ~1,400 lines.

---

### 4. Import Graph Analysis

#### 4a. Core Import Chain in Automation

```
SuccessPatterns ← FormulaEnumerator ← DatasetGenerator ← [many exe targets]
AtomCanonicalization ← FormulaEnumerator
ForwardProofGenerator ← DatasetGenerator ← [BenchmarkAnchors, BenchmarkOracle, TableauBridge...]
```

No import cycles detected in the Automation layer.

#### 4b. Missing from `Automation.lean` Aggregator

The aggregator explicitly excludes exe targets with a comment. However, it should also exclude:
- `ForwardProofGenerator` (only used inside `DatasetGenerator`, which is already imported)
- `AtomCanonicalization` (only used inside `FormulaEnumerator`, which is already imported)

These are implementation-detail imports that are already transitively available, so their explicit exclusion from the aggregator is correct. No action needed.

#### 4c. `GapDetection.lean` Import Chain

`GapDetection.lean` (5,057 lines) imports only `TypeFormulas.lean` (1,068 lines) and is itself imported by only 2 files: `CustomGame.lean` and `NFGameBridge.lean`. This narrow fan-in/fan-out profile makes it an ideal split candidate — splitting would not require updating many importers.

**Proposed split for GapDetection.lean:**
1. `GapDetectionFormulas.lean` (~350 lines) — Definition 8.5 formulas + rank bounds
2. `GapDetectionMu.lean` (~420 lines) — Mu-relativized truth
3. `GapDetectionUniqueness.lean` (~60 lines) — Gap uniqueness
4. `GapDetectionCore.lean` (~300 lines) — Core helper U'(X,D)
5. `GapDetectionLemma9.lean` (~1,800 lines) — Lemma 9 forward direction
6. `GapDetectionLemma9Rev.lean` (~1,100 lines) — Lemma 9 backward direction

#### 4d. `PointInsertion.lean` Import Chain

`PointInsertion.lean` (3,527 lines) has 13+ identified major sections covering Lemmas 2.4, 2.5, 2.6, 2.7, 2.7', and Xu 3.2.1. The KampBypass split pattern from task 301 (KampBypassCore/Since/Until) would apply here. A Chronicle sub-subdirectory with `Lemma24.lean`, `Lemma25.lean`, etc. would reduce individual file sizes significantly.

---

### 5. Boneyard Structure Analysis

#### 5a. Two Separate Boneyard Locations (Inconsistency)

```
/Boneyard/                          ← Project root, 2 files, NOT part of BoneyardArchive
    DeadConvergenceProof/
        limit_dom_succ_iterates.lean (79 lines)
        succ_cofinal_convergence.lean (367 lines)

/Theories/Bimodal/Boneyard/         ← Proper boneyard, 42 files, IS part of BoneyardArchive
    [31 subdirectories, 28,466 lines]
```

The root `/Boneyard/` directory is outside the `BoneyardArchive` lean_lib target (which uses `srcDir := "Theories"` and `globs := #[.submodules `Bimodal.Boneyard]`). This means the 2 files in `/Boneyard/DeadConvergenceProof/` are **not covered by any build target** and have no module declarations.

**Recommendation**: Move `/Boneyard/DeadConvergenceProof/` into `/Theories/Bimodal/Boneyard/DeadConvergenceProof/` and add proper module headers, or keep as plain text files (rename to `.lean.txt`).

#### 5b. Current Boneyard Organizational Pattern

The Boneyard uses topic-based subdirectories:
```
BXPipelineDeadCode/     — Dead BX pipeline variants
BXPipelineGapAnalysis/  — Gap analysis approaches tried for BX
ChainCompleteness/      — Earlier chain completion attempts
DeadCanonicalModel/     — Dead canonical model variants
DeadChronicleGapElimination/ — Dead chronicle gap elimination
DefectDirectedChain/    — Defect-directed chain attempts
DenseChronicle/         — Dense chronicle variants
DiscreteXY/             — Discrete order results
FiltrationOrdering/     — Sigma ordering filtration
NonBurgessSeed/         — Alternative seed constructions
OpenGuardInvalid/       — Open guard invalidity attempts
QuasimodelOracle/       — Oracle-based quasimodel
RoundRobinChain/        — Round robin chain approach
ScheduleBasedBFMCS/     — Schedule-based BFMCS
StageInductionGapAnalysis/ — Stage induction gap analysis
StrictSemanticsLegacy/  — Old strict semantics (Algebraic, Bundle, FrameConditions)
TAxiomDependentCode/    — T-axiom dependent dead code
UltrafilterDeadCode/    — Dead ultrafilter material
UltrafilterFrame/       — Ultrafilter frame approach
VecEADecomposition/     — VecEA decomposition
XuLemma321Legacy/       — Legacy Xu 3.2.1 material
BundleTemporalCoherence/ — Dead temporal coherence for Bundle
BX1DependentCode/       — BX1 pipeline dead code
ClosedGuardLegacy/      — Closed guard legacy
NonBurgessSeed/         — Non-Burgess seed
OpenGuardInvalid/       — Open guard invalidity
StageInductionGapAnalysis/ — Stage induction approach
```

**The existing pattern is topic-based and well-organized.** New dead code should follow the same convention: create a new `{TopicName}/` subdirectory with a meaningful name reflecting the approach tried.

#### 5c. Boneyard Files That Are Very Large

Some Boneyard files are themselves extremely large, indicating whole dead proofs rather than small excerpts:

| Boneyard File | Lines |
|---------------|-------|
| `StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` | 6,144 |
| `StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` | 3,983 |
| `RoundRobinChain/ProofSketch_Sections1to30.lean` | 2,236 |
| `DefectDirectedChain/RootScopedChain.lean` | 1,561 |
| `StrictSemanticsLegacy/Algebraic/DovetailedChain.lean` | 1,459 |
| `ChainCompleteness/Algebraic/DeterministicChain.lean` | 1,062 |
| `UltrafilterFrame/UltrafilterFrame.lean` | 1,185 |

These are large but appropriate for boneyard (dead proofs can be long). No action needed on their size.

---

### 6. Tests/ Organization

The test suite is well-organized and properly mirrors the source structure:
```
Tests/BimodalTest/
├── Automation/   (10 files, ~2,832 lines)
├── Integration/  (7 files, ~2,707 lines)
├── ProofSystem/  (4 files, ~1,139 lines)
├── Semantics/    (4 files, ~784 lines)
├── Syntax/       (3 files, ~1,020 lines)
├── Theorems/     (4 files, ~758 lines)
├── Property/     (2 files, ~312 lines)
└── [root level]  (4 files, ~610 lines)
```

No test files exceed 1,000 lines. The test coverage appears comprehensive. No organizational issues detected.

**Minor observation**: `ProofFirstTests.lean` (222 lines) imports `ProofFirstBenchmark.lean`, which is the orphan library file noted above. This is technically correct but the benchmark code could arguably live directly in the test file.

---

## Recommended Approach

### Priority 1: Fix the Boneyard Location Split (High Impact, Low Risk)

Move `/Boneyard/DeadConvergenceProof/` into `/Theories/Bimodal/Boneyard/` so it falls under the `BoneyardArchive` build target. Add proper Lean module headers. This is a 2-file move.

### Priority 2: Split `GapDetection.lean` (5,057 lines) — Best ROI

This file has 7 natural sections, only 2 immediate dependents (`CustomGame.lean`, `NFGameBridge.lean`), and clear topical boundaries. A 6-way split would bring all pieces under 1,200 lines. The importer update cost is minimal (2 files to add imports to).

### Priority 3: Split `PointInsertion.lean` (3,527 lines) — High Value

13+ Burgess lemma sections with clear numerical demarcation. Apply KampBypass pattern from task 301: create `Chronicle/Insertion/Lemma24.lean`, `Lemma25.lean`, `Lemma26.lean`, `Lemma27.lean`, `Xu321.lean`, etc.

### Priority 4: Split `FormulaEnumerator.lean` — Clean Boundary Exists

The line 1186 split between enumeration and axiom instantiation is clean. Extract `AxiomInstantiation.lean` (lines 1186–2212). Update `DatasetGenerator.lean` to import it directly.

### Priority 5: Resolve `ProofFirstBenchmark.lean` Orphan

Either:
- Move the benchmark code into the test file `ProofFirstTests.lean` directly, or  
- Register it as an exe target in `lakefile.lean` with a `main` function, or  
- Archive it in Boneyard if the benchmark is no longer relevant

### Priority 6 (Optional): Extract Embedded Tests from `DatasetGenerator.lean`

The ~700 lines of `#eval` / inline test code in `DatasetGenerator.lean` could move to a dedicated test file, reducing it from 2,148 to ~1,400 lines.

---

## Evidence / Examples

**KampBypass split pattern from task 301** (already executed successfully):
- `KampBypass.lean` was split into `KampBypassCore.lean` (2,160 lines), `KampBypassSince.lean` (1,307 lines), `KampBypassUntil.lean` (979 lines) — the same structural pattern applies to `GapDetection.lean` and `PointInsertion.lean`.

**Aggregator comment confirming exe exclusion** (in `Automation.lean` line 14):
```lean
-- DatasetExport, DatasetValidator, and ProofStepExport define `main` (lean_exe targets)
-- and must not be imported through the umbrella; use them only via `lake exe` commands.
```

**Boneyard is NOT built by default** (lakefile.lean lines 23-27):
```lean
lean_lib BoneyardArchive where
  srcDir := "Theories"
  globs := #[.submodules `Bimodal.Boneyard]
```

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| GapDetection split opportunity | **High** — clear section markers, low importer count |
| PointInsertion split opportunity | **High** — 13+ Burgess lemma sections, established pattern |
| Root Boneyard location inconsistency | **High** — verified by lakefile and directory structure |
| FormulaEnumerator split at line 1186 | **High** — distinct logical units confirmed |
| ProofFirstBenchmark orphan status | **High** — verified no exe target, 1 test importer only |
| DatasetGenerator embedded tests | **Medium** — functional but mixed-concern design |
| Import graph — no cycles | **High** — verified by dependency inspection |
| Test suite is current and well-organized | **High** — mirrored structure, good coverage |

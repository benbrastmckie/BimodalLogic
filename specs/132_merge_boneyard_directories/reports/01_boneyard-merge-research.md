# Research Report: Merge Root Boneyard into Theories/Bimodal/Boneyard

- **Task**: 132 - Merge root Boneyard into Theories/Bimodal/Boneyard and populate README
- **Started**: 2026-05-13T19:30:00Z
- **Completed**: 2026-05-13T19:45:00Z
- **Effort**: 2-4 hours estimated
- **Dependencies**: None (independent housekeeping task)
- **Sources/Inputs**:
  - `Boneyard/` (project root) - 2 files, 216 lines
  - `Theories/Bimodal/Boneyard/` - 45 .lean files + 6 READMEs, ~26,363 lines across 14 subdirectories
  - `lakefile.lean` - build configuration (srcDir = "Theories", roots = `Bimodal`)
  - Git history for both Boneyard locations
  - Existing README.md files in Boneyard subdirectories
- **Artifacts**: `specs/132_merge_boneyard_directories/reports/01_boneyard-merge-research.md`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

- The root `Boneyard/` directory contains exactly 2 files: `XuLemma321.lean` (75 lines) and `NonBurgessSeed/PointInsertionLegacy.lean` (141 lines), both archived dead code with no external references
- The canonical `Theories/Bimodal/Boneyard/` directory is well-organized with 14 thematic subdirectories and ~26K lines of archived code
- No naming conflicts exist between root and canonical Boneyard directories
- Neither root Boneyard file is imported by any compiled module; root `Boneyard/` is outside the lake build tree (`srcDir := "Theories"`)
- The top-level `Theories/Bimodal/Boneyard/README.md` is empty and needs comprehensive documentation
- No import path updates needed since root Boneyard files are not imported anywhere

## Context & Scope

This task consolidates two separate Boneyard locations into one canonical location and documents the full archive. The root `Boneyard/` sits outside the Lean module hierarchy and has accumulated files ad hoc. The canonical location at `Theories/Bimodal/Boneyard/` is inside the module tree (namespace `Bimodal.Boneyard.*`) though none of its files are imported by active modules.

## Findings

### Root Boneyard Inventory

1. **`Boneyard/XuLemma321.lean`** (75 lines)
   - Contains archived proof attempts for Xu's Lemma 3.2.1(i) and 3.2.1(ii)
   - Originally from `RRelation.lean` (commit 51bdc854d)
   - Two `sorry`-containing theorems: `burgessR3Maximal_untl_mem_B` and `burgessR3Maximal_snce_mem_B`
   - Blocked on inconsistency case: BX9 removed as unsound under open guard semantics
   - Git history: created in commit `f62f19a99` ("removed stray definitions")
   - **Note**: Task 115 proved Xu 3.2.1 via a different approach (using `dcs_neg_union_consistent`), making this archived attempt doubly obsolete

2. **`Boneyard/NonBurgessSeed/PointInsertionLegacy.lean`** (141 lines)
   - Archived from `PointInsertion.lean` during task 107 Phase 3
   - Contains legacy functions for g_content/h_content approach to BurgessR3Maximal
   - Hit "density gap" (G(φ) and untl(φ.neg, γ) semantically contradictory on dense orders but no density axiom)
   - All code commented out (wrapped in `/-` ... `-/`), not compilable
   - Git history: created in commit `e2a220e9d` (task 107)

### Canonical Boneyard Structure

| Subdirectory | Files | Lines | Archived From | Why Archived |
|---|---|---|---|---|
| BundleTemporalCoherence | 1 | 74 | UltrafilterChain.lean | Semantically wrong for TM task semantics (bundle vs family coherence) |
| ChainCompleteness | 12 | 4,186 | BXCanonical/ | Earlier chain completeness, superseded by SuccChain |
| ClosedGuardLegacy | 4 | 352 | Various | Closed guard semantics, replaced by open guard |
| DeadCanonicalModel | 1 | 90 | BXCanonical/ | Dead enriched seed approach |
| DefectDirectedChain | 1 | 1,556 | BXCanonical/ | Defect-directed chain, abandoned |
| DenseChronicle | 3 | 281 | Chronicle/ | Dense chronicle attempts |
| DiscreteXY | 1 | 72 | Various | Discrete x/y content approach |
| QuasimodelOracle | 3 | 1,467 | BXCanonical/ | Oracle approach abandoned (25+ sorry gaps) |
| RoundRobinChain | 2 | 2,522 | BXCanonical/ | Round-robin chain, BX11 perpetual deferral obstruction |
| StageInductionGapAnalysis | 1 | 53 | ChronicleToCountermodel | Dead-end IsSuccArchimedean proof attempts (task 123) |
| StrictSemanticsLegacy | 9 | 14,330 | Metalogic/ | Strict semantics completeness (107 sorries, architectural incompatibility) |
| TAxiomDependentCode | 3 | 316 | Various | T-axiom dependent (unsound under strict semantics, task 83) |
| UltrafilterDeadCode | 4 | 1,064 | UltrafilterChain.lean | Dead approaches (F-preserving, bidirectional, Z-chain, task 80) |

### Naming Conflict Analysis

- No conflicts: root Boneyard directories (`NonBurgessSeed/`) don't overlap with any existing canonical Boneyard subdirectory
- `XuLemma321.lean` is a standalone file; no existing `XuLemma*` files in canonical Boneyard

### Import Analysis

- **From outside Boneyard**: Zero files import any Boneyard module. Boneyard is fully isolated from the active codebase.
- **Within Boneyard**: 20 cross-references exist between `StrictSemanticsLegacy/*` and `ChainCompleteness/*` subdirectories. These are internal to the archive.
- **Root Boneyard**: Neither file is imported anywhere. Both contain commented-out code.
- **Build system**: `lakefile.lean` sets `srcDir := "Theories"` with `roots := #[\`Bimodal]`. Root `Boneyard/` is completely outside the build tree. Files under `Theories/Bimodal/Boneyard/` may be picked up by the build but are not imported by any compiled module, so they are effectively inert.

### Existing README Quality

- `Theories/Bimodal/Boneyard/README.md`: **Empty** (needs full rewrite)
- `BundleTemporalCoherence/README.md`: Excellent (68 lines, detailed semantic analysis)
- `QuasimodelOracle/README.md`: Good (36 lines)
- `StrictSemanticsLegacy/README.md`: Good (54 lines)
- `TAxiomDependentCode/README.md`: Good (55 lines)
- `UltrafilterDeadCode/README.md`: Good (67 lines)
- `StageInductionGapAnalysis/README.md`: Good (40 lines)

### Comments Referencing Boneyard in Active Code

Three comments in active code mention Boneyard:
- `Metalogic/Bundle/TemporalCoherence.lean:442`: archived to Boneyard reference
- `Metalogic/Algebraic/Algebraic.lean:40`: archived to Boneyard reference
- `Metalogic/Algebraic/Algebraic.lean:98`: archived to Boneyard reference

These are informational comments, not import dependencies, and need no updating.

## Decisions

- Root Boneyard files should be moved into **new thematic subdirectories** within canonical Boneyard, consistent with the existing organizational pattern (one directory per archived approach/concept)
- `XuLemma321.lean` -> `Theories/Bimodal/Boneyard/XuLemma321Legacy/XuLemma321.lean` (thematic: blocked Xu 3.2.1 proof-by-contradiction approach)
- `NonBurgessSeed/PointInsertionLegacy.lean` -> `Theories/Bimodal/Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` (already has its own directory)
- The top-level README should provide: purpose overview, full directory inventory table, archival reason taxonomy, and guidance for consulting vs ignoring archived code

## Recommendations

1. **Move files first, then verify build**: `git mv` both root Boneyard files to canonical locations, run `lake build` to confirm no regressions
2. **Create README with inventory table**: Model on existing subdirectory READMEs (especially UltrafilterDeadCode/README.md which has the best format)
3. **Add README to XuLemma321Legacy**: Brief README explaining the blocked proof-by-contradiction approach and that task 115 solved Xu 3.2.1 via a different method
4. **Remove root Boneyard directory**: After git mv, the directory should be empty and removable
5. **Do not update comments in active code**: The three Boneyard references in active code are informational and accurate after merge (still archived to Boneyard, just at a different path within it)

## Risks & Mitigations

- **Build breakage**: Low risk. Root Boneyard files are outside the build tree and canonical Boneyard files are not imported. Mitigation: run `lake build` after move.
- **Git history loss**: No risk. `git mv` preserves history; files remain `--follow`-able.
- **README staleness**: Medium risk. README content may become outdated as the project evolves. Mitigation: include git-based retrieval instructions so the README serves as an index, not sole source of truth.

## Appendix

### File Statistics

| Location | Directories | .lean Files | Lines | READMEs |
|---|---|---|---|---|
| Root Boneyard/ | 2 | 2 | 216 | 0 |
| Theories/Bimodal/Boneyard/ | 14 | 45 | 26,363 | 6 |
| **Total (after merge)** | **15** | **47** | **26,579** | **7+1 top-level** |

### Task Cross-References

Key tasks that created Boneyard content:
- Task 80: UltrafilterDeadCode (23 sorries removed)
- Task 83: TAxiomDependentCode (strict -> reflexive migration)
- Task 85: DiscreteXY (x_content/y_content removal)
- Task 93: ChainCompleteness, additional dead code
- Task 94: StrictSemanticsLegacy (9 files, 107 sorries)
- Task 105: DenseChronicle
- Task 107: QuasimodelOracle, NonBurgessSeed, DefectDirectedChain
- Task 109: ClosedGuardLegacy, additional cleanup
- Task 113: DeadCanonicalModel
- Task 115: Made XuLemma321 doubly obsolete (proved Xu 3.2.1 differently)
- Task 123: StageInductionGapAnalysis
- Task 124: BundleTemporalCoherence (was already archived)

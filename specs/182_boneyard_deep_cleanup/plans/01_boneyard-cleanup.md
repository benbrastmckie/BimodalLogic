# Implementation Plan: Boneyard Deep Cleanup

- **Task**: 182 - boneyard_deep_cleanup
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: specs/182_boneyard_deep_cleanup/reports/01_compilation-strategy.md
- **Artifacts**: plans/01_boneyard-cleanup.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Deep cleanup of the Theories/Bimodal/Boneyard/ directory (20 subdirectories, 56 files, 28,877 lines) to make all Boneyard code compile cleanly, provide README coverage for every subdirectory, consolidate doc-only .lean files into README prose, and establish a maintenance standard for future archival. The approach follows the research report's recommendation: add a non-default `lean_lib BoneyardArchive` target to lakefile.lean, mechanically fix 14 files with broken import paths across three categories (stale internal paths, ParametricRepresentation rename, Mathlib imports), consolidate 18 doc-only .lean files into README content, create 10 missing READMEs, and document the Boneyard maintenance procedure.

### Research Integration

The research report (01_compilation-strategy.md) provides a complete file-by-file audit:
- 24 doc-only files (no imports, zero compilation effort)
- 18 code files with valid imports (Category B, should compile as-is with sorry)
- 14 code files with fixable broken imports (Category C) in three mechanical patterns
- A 5-level internal dependency graph for compilation ordering
- Effort estimates by tier: 0h (doc-only) + 0.75h (valid imports) + 2.5h (path fixes) + 5-8h (complex deps)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items explicitly targeted by this task.

## Goals & Non-Goals

**Goals**:
- Make all Boneyard code compile cleanly via `lake build BoneyardArchive` (with expected sorry stubs)
- Provide README.md coverage for all 20 subdirectories (10 already exist, 10 to create)
- Consolidate 18 doc-only .lean files (2,434 lines) into README prose, then delete the .lean files
- Establish a documented Boneyard maintenance standard for future archival

**Non-Goals**:
- Completing any sorry-marked proofs in Boneyard files
- Moving any Boneyard code back to the active module tree
- Adding CI integration for BoneyardArchive (can be a follow-up task)
- Refactoring or improving the quality of Boneyard code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type drift in active modules causes elaboration failures beyond import fixes | M | H | Add sorry stubs for elaboration failures; this is expected for archived code |
| Aggregator file accidentally imported by active code | H | L | Use non-default target; verify no active file imports Boneyard modules |
| Import fix cascade: fixing one file reveals new errors in dependent files | M | M | Follow the 5-level dependency graph from research; fix bottom-up |
| Doc-only file contains hidden semantic content worth preserving | L | L | Review each doc-only file before consolidation; preserve any non-obvious content |
| Globs-based lean_lib picks up files that fail elaboration | M | M | Use globs for discovery but iterate with `lake build BoneyardArchive` to catch failures |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Infrastructure -- BoneyardArchive lean_lib Target [COMPLETED]

**Goal**: Add a non-default `lean_lib BoneyardArchive` target to lakefile.lean so the Boneyard can be built separately via `lake build BoneyardArchive` without affecting the default build.

**Tasks**:
- [ ] Add `BoneyardArchive` lean_lib definition to `lakefile.lean` using `globs := #[.submodules `Bimodal.Boneyard]` for recursive file discovery
- [ ] Verify `lake build` still builds only the default `Bimodal` target (no regression)
- [ ] Run `lake build BoneyardArchive` to establish a baseline of current errors (capture output for reference)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `lakefile.lean` -- add BoneyardArchive lean_lib definition (4-5 lines)

**Verification**:
- `lake build` succeeds without building Boneyard files
- `lake build BoneyardArchive` runs (errors expected at this stage, but the target is recognized)

---

### Phase 2: Import Path Fixes -- Mechanical Rewrites [NOT STARTED]

**Goal**: Fix all 14 broken-import files using the three mechanical patterns identified in research: stale internal paths (10 files), ParametricRepresentation rename (5 files), and TenseS5Algebra path (2 files).

**Tasks**:
- [ ] Fix Pattern 2 first (simplest): rename `ParametricRepresentation` to `ParametricCompleteness` in 5 files (QuasimodelOracle/OracleCoherence, DefectDirectedChain/RootScopedChain, ChainCompleteness/Algebraic/DeterministicFMCS, ChainCompleteness/Algebraic/FiniteDeferral, and check for any others)
- [ ] Fix Pattern 4: rewrite `TenseS5Algebra` import paths to `Bimodal.Boneyard.UltrafilterFrame.TenseS5Algebra` in StrictSemanticsLegacy/Algebraic/UltrafilterChain and UltrafilterFrame/UltrafilterFrame
- [ ] Fix Pattern 1: rewrite stale internal paths in ChainCompleteness files -- update imports from `Bimodal.Metalogic.*` to `Bimodal.Boneyard.ChainCompleteness.*` for 10 cross-referencing files
- [ ] Verify Mathlib imports (Pattern 3) resolve without changes: `Mathlib.Data.Nat.Pairing`, `Mathlib.Order.BooleanAlgebra.Basic`, `Mathlib.Order.CountableDenseLinearOrder`, `Mathlib.Data.Rat.Encodable`
- [ ] Run `lake build BoneyardArchive` to confirm all import resolution errors are eliminated

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Boneyard/QuasimodelOracle/OracleCoherence.lean` -- ParametricRepresentation rename
- `Theories/Bimodal/Boneyard/DefectDirectedChain/RootScopedChain.lean` -- ParametricRepresentation rename
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` -- internal path + ParametricRepresentation
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` -- internal path
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` -- TenseS5Algebra path + Mathlib
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/Algebraic/DovetailedChain.lean` -- Mathlib path
- `Theories/Bimodal/Boneyard/UltrafilterFrame/TenseS5Algebra.lean` -- Mathlib path
- `Theories/Bimodal/Boneyard/UltrafilterFrame/UltrafilterFrame.lean` -- TenseS5Algebra path
- `Theories/Bimodal/Boneyard/DenseChronicle/CantorIsoCountermodel.lean` -- Mathlib paths
- `Theories/Bimodal/Boneyard/ChainCompleteness/Bundle/MCSWitnessChain.lean` -- internal path
- `Theories/Bimodal/Boneyard/ChainCompleteness/Bundle/ResolvingChain.lean` -- internal path
- `Theories/Bimodal/Boneyard/ChainCompleteness/Bundle/SuccChainWorldHistory.lean` -- internal path
- `Theories/Bimodal/Boneyard/ChainCompleteness/Bundle/SuccChainTruth.lean` -- internal path
- `Theories/Bimodal/Boneyard/ChainCompleteness/Completeness/SuccChainCompleteness.lean` -- internal path

**Verification**:
- `lake build BoneyardArchive 2>&1 | grep -c "unknown import"` returns 0
- All import statements resolve (no `unknown package` or `unknown identifier` at import level)

---

### Phase 3: README Coverage -- Create 10 Missing READMEs [NOT STARTED]

**Goal**: Create README.md files for all 10 subdirectories that lack them, providing consistent documentation across the entire Boneyard. Each README follows the established pattern from existing READMEs (purpose, file inventory, status, relationship to active code).

**Tasks**:
- [ ] Review 2-3 existing Boneyard READMEs to establish the template pattern
- [ ] Create README.md for ChainCompleteness (12 files, 4,186 lines -- largest missing README)
- [ ] Create README.md for RoundRobinChain (2 files, 2,522 lines)
- [ ] Create README.md for UltrafilterFrame (2 files, 1,553 lines)
- [ ] Create README.md for DefectDirectedChain (1 file, 1,556 lines)
- [ ] Create README.md for DenseChronicle (3 files, 281 lines)
- [ ] Create README.md for ClosedGuardLegacy (4 files, 352 lines)
- [ ] Create README.md for DeadCanonicalModel (1 file, 90 lines)
- [ ] Create README.md for DiscreteXY (1 file, 72 lines)
- [ ] Create README.md for NonBurgessSeed (1 file, 141 lines)
- [ ] Create README.md for OpenGuardInvalid (1 file, 215 lines)

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Boneyard/ChainCompleteness/README.md` -- create
- `Theories/Bimodal/Boneyard/RoundRobinChain/README.md` -- create
- `Theories/Bimodal/Boneyard/UltrafilterFrame/README.md` -- create
- `Theories/Bimodal/Boneyard/DefectDirectedChain/README.md` -- create
- `Theories/Bimodal/Boneyard/DenseChronicle/README.md` -- create
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/README.md` -- create
- `Theories/Bimodal/Boneyard/DeadCanonicalModel/README.md` -- create
- `Theories/Bimodal/Boneyard/DiscreteXY/README.md` -- create
- `Theories/Bimodal/Boneyard/NonBurgessSeed/README.md` -- create
- `Theories/Bimodal/Boneyard/OpenGuardInvalid/README.md` -- create

**Verification**:
- Every subdirectory under Theories/Bimodal/Boneyard/ contains a README.md
- `find Theories/Bimodal/Boneyard -mindepth 1 -maxdepth 1 -type d ! -exec test -f {}/README.md \; -print` returns empty

---

### Phase 4: Compilation Verification and Sorry Stubs [NOT STARTED]

**Goal**: Achieve clean `lake build BoneyardArchive` with all files elaborating successfully (with expected sorry stubs for incomplete proofs, but no import errors or type mismatches).

**Tasks**:
- [ ] Run `lake build BoneyardArchive` and capture full error output
- [ ] Triage errors into categories: import errors (should be zero after Phase 2), type mismatches (API drift), and elaboration failures
- [ ] For type mismatches due to API drift in active modules, add minimal sorry stubs or type annotations to make elaboration proceed
- [ ] Follow the 5-level dependency graph from research report Section 6 when fixing files (Level 0 first, then Level 1, etc.)
- [ ] Iterate: fix errors, rebuild, repeat until `lake build BoneyardArchive` succeeds
- [ ] Verify default `lake build` still succeeds (no regression)

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- Various files in `Theories/Bimodal/Boneyard/` -- sorry stubs and type fixes as needed (specific files determined by build errors)

**Verification**:
- `lake build BoneyardArchive` exits with code 0
- `lake build` still exits with code 0 (no regression)
- Any remaining sorry markers are intentional proof gaps, not compilation band-aids

---

### Phase 5: Doc-Only Consolidation and Maintenance Standard [NOT STARTED]

**Goal**: Consolidate 18 doc-only .lean files into README prose (or expand existing READMEs), delete the emptied .lean files, and document the Boneyard maintenance standard for future archival.

**Tasks**:
- [ ] For each of the 10 subdirectories containing doc-only files (BundleTemporalCoherence, BX1DependentCode, ClosedGuardLegacy, DeadCanonicalModel, NonBurgessSeed, OpenGuardInvalid, StageInductionGapAnalysis, TAxiomDependentCode, UltrafilterDeadCode, XuLemma321Legacy): extract meaningful content from .lean files and incorporate into the subdirectory README.md
- [ ] Delete the 18 doc-only .lean files after their content is preserved in READMEs
- [ ] Verify `lake build BoneyardArchive` still succeeds after deletions (doc-only files should not affect compilation)
- [ ] Update the top-level `Theories/Bimodal/Boneyard/README.md` with updated file counts and inventory
- [ ] Add a "Boneyard Maintenance Standard" section to the top-level README documenting: how to archive files (use Boneyard-qualified import paths), how to verify compilation (`lake build BoneyardArchive`), and expected file structure (README + code files per subdirectory)
- [ ] Verify `VacuousKEquiv.lean` (standalone file in Boneyard root) is included in the top-level README inventory

**Timing**: 2.5 hours

**Depends on**: 3, 4

**Files to modify**:
- 18 doc-only .lean files -- delete after content extraction
- 10+ README.md files in subdirectories -- expand with consolidated content
- `Theories/Bimodal/Boneyard/README.md` -- update inventory, add maintenance standard

**Verification**:
- No doc-only .lean files remain (all content in READMEs)
- `lake build BoneyardArchive` still succeeds
- Every subdirectory has a README.md with meaningful content
- Top-level README documents the maintenance standard

## Testing & Validation

- [ ] `lake build` succeeds (default target, no regression)
- [ ] `lake build BoneyardArchive` succeeds (all Boneyard files elaborate)
- [ ] Every subdirectory in Theories/Bimodal/Boneyard/ contains README.md
- [ ] No doc-only .lean files remain (content consolidated into READMEs)
- [ ] Top-level Boneyard README has updated inventory and maintenance standard
- [ ] Git diff shows net reduction in .lean file count (56 down to ~38)

## Artifacts & Outputs

- `specs/182_boneyard_deep_cleanup/plans/01_boneyard-cleanup.md` (this plan)
- `specs/182_boneyard_deep_cleanup/summaries/01_boneyard-cleanup-summary.md` (post-implementation)
- Modified `lakefile.lean` with BoneyardArchive target
- 10 new README.md files in Boneyard subdirectories
- 14 import-fixed .lean files
- 18 deleted doc-only .lean files
- Updated top-level Boneyard README with maintenance standard

## Rollback/Contingency

- **Phase 1 rollback**: Remove the BoneyardArchive lean_lib definition from lakefile.lean (4 lines)
- **Phase 2 rollback**: `git checkout -- Theories/Bimodal/Boneyard/` to restore original imports
- **Phase 3-5 rollback**: READMEs are additive; doc-only file deletions can be recovered from git history
- **Full rollback**: `git revert` the task commits to restore the original Boneyard state
- **If compilation fails intractably**: Mark Phase 4 as [PARTIAL], document which files compile and which do not, and defer the non-compiling files to a follow-up task

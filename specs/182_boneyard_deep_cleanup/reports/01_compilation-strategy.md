# Boneyard Compilation Strategy Research Report

**Task**: 182 (Boneyard deep cleanup)
**Date**: 2026-05-20
**Session**: sess_1779345175_6806d1

---

## Executive Summary

The Boneyard contains 56 files across 20 subdirectories (28,877 lines). Of these:

- **24 files** (43%) are **documentation-only** (no `import` statements, all comments/docstrings)
- **32 files** (57%) contain **actual Lean code** with imports
- Of the 32 code files, **18 have all imports resolvable** to existing modules
- **14 files** have broken imports pointing to deleted/moved/renamed modules

The recommended strategy is a **separate `lean_lib` target** combined with **import path rewrites** (no compat stubs, no axiom patching).

---

## 1. Compilation Audit by Subdirectory

### Category A: Documentation-Only (No Compilation Needed)

These subdirectories contain only commented-out code, docstrings, and type signatures in markdown blocks. They already "compile" trivially because they have no `import` statements.

| Subdirectory | Files | Lines | Status |
|---|---:|---:|---|
| BundleTemporalCoherence | 1 | 74 | Doc-only, no code |
| BX1DependentCode | 1 | 54 | Doc-only, no code |
| ClosedGuardLegacy | 4 | 352 | Doc-only (all 4 files) |
| DeadCanonicalModel | 1 | 90 | Doc-only, no code |
| NonBurgessSeed | 1 | 141 | Doc-only (all commented out) |
| OpenGuardInvalid | 1 | 215 | Doc-only (code in markdown blocks) |
| StageInductionGapAnalysis | 1 | 53 | Doc-only, no code |
| TAxiomDependentCode | 3 | 316 | Doc-only (all 3 files) |
| UltrafilterDeadCode | 4 | 1,064 | Doc-only (all 4 files) |
| XuLemma321Legacy | 1 | 75 | Doc-only, no code |
| **Subtotal** | **18** | **2,434** | **Zero effort** |

### Category B: Code Files, All Imports Resolvable

These files import only from existing active modules or correctly-pathed Boneyard modules. They may still have type errors or `sorry` but their imports will resolve.

| Subdirectory | File | Lines | Notes |
|---|---|---:|---|
| DiscreteXY | Discreteness.lean | 72 | 1 sorry, references `temporal_duality` |
| FiltrationOrdering | SigmaOrdering.lean | 167 | 3 sorries (BX1-dependent), solid code |
| ScheduleBasedBFMCS | RootScopedChain.lean | 222 | References ParametricCompleteness (correct) |
| RoundRobinChain | DRMChain.lean | 286 | References active Bundle modules |
| QuasimodelOracle | OracleStep.lean | 458 | References active modules |
| QuasimodelOracle | RoundRobinChain.lean | 509 | References active modules |
| StrictSemanticsLegacy | Bundle/SuccChainFMCS.lean | 6,139 | Largest file, all imports valid |
| StrictSemanticsLegacy | Bundle/CanonicalConstruction.lean | 1,145 | Imports SuccChainFMCS + active |
| StrictSemanticsLegacy | BaseCompleteness.lean | 211 | Imports CanonicalConstruction |
| StrictSemanticsLegacy | DiscreteCompleteness.lean | 241 | Imports DiscreteCompleteness |
| StrictSemanticsLegacy | DenseCompleteness.lean | 168 | Imports DenseCompleteness |
| StrictSemanticsLegacy | Algebraic/RestrictedTruthLemma.lean | 360 | All imports valid |
| StrictSemanticsLegacy | FrameConditions/Completeness.lean | 632 | All imports valid |
| ChainCompleteness | Algebraic/DeterministicChain.lean | 1,058 | All imports valid |
| ChainCompleteness | Bundle/MCSWitnessSuccessor.lean | 364 | Imports StrictSemanticsLegacy |
| ChainCompleteness | Bundle/TargetedChain.lean | 413 | Imports StrictSemanticsLegacy |
| ChainCompleteness | Bundle/SuccChainTaskFrame.lean | 98 | Imports StrictSemanticsLegacy |
| ChainCompleteness | Bundle/SimplifiedChain.lean | 206 | Imports StrictSemanticsLegacy |
| **Subtotal** | **18 files** | **12,749** | **Imports resolve; may have type errors** |

### Category C: Code Files, Broken Imports (Fixable)

These files have imports pointing to wrong paths. All are fixable by rewriting import paths.

| File | Broken Imports | Fix |
|---|---|---|
| StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean | `TenseS5Algebra`, `Mathlib.Data.Nat.Pairing` | Rewrite to Boneyard path; Mathlib path exists |
| StrictSemanticsLegacy/Algebraic/DovetailedChain.lean | `Mathlib.Data.Nat.Pairing` | Mathlib path exists (typo or version drift) |
| UltrafilterFrame/TenseS5Algebra.lean | `Mathlib.Order.BooleanAlgebra.Basic` | Mathlib path exists |
| UltrafilterFrame/UltrafilterFrame.lean | `TenseS5Algebra` | Rewrite to `Bimodal.Boneyard.UltrafilterFrame.TenseS5Algebra` |
| DenseChronicle/CantorIsoCountermodel.lean | `Mathlib.Order.CountableDenseLinearOrder`, `Mathlib.Data.Rat.Encodable` | Both exist in Mathlib |
| QuasimodelOracle/OracleCoherence.lean | `ParametricRepresentation` | Rename to `ParametricCompleteness` |
| DefectDirectedChain/RootScopedChain.lean | `ParametricRepresentation` | Rename to `ParametricCompleteness` |
| ChainCompleteness/Algebraic/DeterministicFMCS.lean | `DeterministicChain`, `ParametricRepresentation` | Rewrite both |
| ChainCompleteness/Algebraic/FiniteDeferral.lean | `DeterministicChain`, `DeterministicFMCS` | Rewrite paths |
| ChainCompleteness/Bundle/MCSWitnessChain.lean | `MCSWitnessSuccessor` | Rewrite to Boneyard path |
| ChainCompleteness/Bundle/ResolvingChain.lean | `SimplifiedChain`, `TargetedChain` | Rewrite to Boneyard paths |
| ChainCompleteness/Bundle/SuccChainWorldHistory.lean | `SuccChainTaskFrame` | Rewrite to Boneyard path |
| ChainCompleteness/Bundle/SuccChainTruth.lean | `SuccChainTaskFrame`, `SuccChainWorldHistory` | Rewrite to Boneyard paths |
| ChainCompleteness/Completeness/SuccChainCompleteness.lean | `SuccChainTruth` | Rewrite to Boneyard path |
| **Subtotal** | **14 files** | **All fixable with import rewrites** |

---

## 2. Broken Import Analysis

### Pattern 1: Stale Internal Paths (10 files)

Files within ChainCompleteness import other ChainCompleteness files using their *old* active-module paths (e.g., `import Bimodal.Metalogic.Bundle.SuccChainTaskFrame`) rather than the Boneyard path (`import Bimodal.Boneyard.ChainCompleteness.Bundle.SuccChainTaskFrame`).

**Fix**: Mechanical path rewrite. These files were moved as a batch but cross-references weren't updated.

### Pattern 2: Renamed Module (5 files)

`Bimodal.Metalogic.Algebraic.ParametricRepresentation` was renamed to `Bimodal.Metalogic.Algebraic.ParametricCompleteness` (task 163, commit 2e1ee6888).

**Fix**: `s/ParametricRepresentation/ParametricCompleteness/g`

### Pattern 3: Mathlib Import Path Drift (3 files)

Three files import Mathlib modules (`Mathlib.Data.Nat.Pairing`, `Mathlib.Order.BooleanAlgebra.Basic`, `Mathlib.Order.CountableDenseLinearOrder`) that **do exist** in Mathlib v4.27.0-rc1. These will resolve once the file is part of a buildable target.

**Fix**: None needed -- these are valid imports.

### Pattern 4: TenseS5Algebra Circular (2 files)

`UltrafilterChain` imports `TenseS5Algebra` via the old active path. TenseS5Algebra is now in Boneyard itself.

**Fix**: Rewrite to `Bimodal.Boneyard.UltrafilterFrame.TenseS5Algebra`

---

## 3. Strategy Evaluation

### Option 1: Separate `lean_lib` (RECOMMENDED)

Add a non-default `lean_lib` to `lakefile.lean`:

```lean
lean_lib BoneyardArchive where
  srcDir := "Theories"
  roots := #[`Bimodal.Boneyard]
  leanOptions := theoryLeanOptions
```

**Advantages**:
- Not built by default (`lake build` only builds `@[default_target]` targets)
- Explicitly buildable via `lake build BoneyardArchive`
- No changes to active module tree
- Standard Lake pattern (Mathlib uses this for `Archive`, `Counterexamples`)

**Implementation**:
1. Add 4 lines to `lakefile.lean`
2. Fix 14 files' import paths (mechanical sed operations)
3. Verify with `lake build BoneyardArchive`

**Effort**: Low (1-2 hours)

### Option 2: Compat Stubs (NOT RECOMMENDED)

Create `Boneyard/Compat.lean` providing deleted type signatures as `axiom` declarations.

**Problems**:
- Only 1 truly deleted module (`ParametricRepresentation` -> `ParametricCompleteness`)
- The module wasn't deleted, it was *renamed* -- a path fix is simpler
- Axiom stubs would introduce unsound axioms (pollutes the logical foundation)
- Does not help with internal cross-reference path issues

**Verdict**: Unnecessary. The real problem is path drift, not missing definitions.

### Option 3: Axiom Patching (NOT RECOMMENDED)

Replace broken references within file bodies with `sorry` or `axiom` declarations.

**Problems**:
- Many files already contain `sorry` (this is expected for Boneyard)
- The import errors prevent elaboration entirely -- axiom patching inside files doesn't help if imports fail
- Adds maintenance burden

**Verdict**: Unnecessary. Once imports resolve, existing `sorry` declarations handle the rest.

### Option 4: Deletion of Unrecoverable Files (PARTIALLY RECOMMENDED)

**Candidates for deletion** (pure-documentation .lean files that duplicate README content):
- Files in Category A that are 100% comments could be converted to README sections
- Especially: `UltrafilterDeadCode/` (4 files, all doc-only headers)
- `BX1DependentCode/RealizationSorries.lean` (54 lines, pure docstring)

**Assessment**: The 18 doc-only files (2,434 lines) contain only markdown-in-comments. Their content is better served by README.md files or the parent README's inventory table.

**Verdict**: Recommend converting doc-only `.lean` files to README content and deleting the `.lean` files, reducing the file count from 56 to 38 and line count by ~2,434.

---

## 4. Lakefile Configuration

### Current Setup

```lean
@[default_target]
lean_lib Bimodal where
  srcDir := "Theories"
  roots := #[`Bimodal]
  leanOptions := theoryLeanOptions
```

The `roots := #[`Bimodal]` tells Lake to include everything under `Theories/Bimodal/`. However, since no file in the active tree imports anything from `Bimodal.Boneyard`, Lake's dependency resolution never touches Boneyard files during `lake build`.

### Proposed Addition

```lean
/-- Archived dead code. Not built by default.
    Build with: lake build BoneyardArchive -/
lean_lib BoneyardArchive where
  srcDir := "Theories"
  roots := #[`Bimodal.Boneyard]
  leanOptions := theoryLeanOptions
```

**Key behaviors**:
- `lake build` -- builds only `Bimodal` (default target), ignores Boneyard
- `lake build BoneyardArchive` -- builds only Boneyard (verifies compilation)
- `lake build Bimodal BoneyardArchive` -- builds both

**Note**: We also need a root aggregator file at `Theories/Bimodal/Boneyard/Boneyard.lean` (or use `globs` instead of `roots`). An aggregator approach:

```lean
-- Theories/Bimodal/Boneyard/Boneyard.lean
import Bimodal.Boneyard.DiscreteXY.Discreteness
import Bimodal.Boneyard.FiltrationOrdering.SigmaOrdering
-- ... (all compilable files)
```

Alternatively, use Lake's glob feature:

```lean
lean_lib BoneyardArchive where
  srcDir := "Theories"
  globs := #[.submodules `Bimodal.Boneyard]
  leanOptions := theoryLeanOptions
```

The `globs := #[.submodules ...]` variant discovers all `.lean` files recursively -- simpler but includes doc-only files. The explicit roots approach gives control over which files compile.

---

## 5. Effort Estimation by Subdirectory

### Tier 1: Zero Effort (Already Compiles / Doc-Only)

| Subdirectory | Lines | Why |
|---|---:|---|
| BundleTemporalCoherence | 74 | Doc-only |
| BX1DependentCode | 54 | Doc-only |
| ClosedGuardLegacy | 352 | Doc-only |
| DeadCanonicalModel | 90 | Doc-only |
| NonBurgessSeed | 141 | Doc-only |
| OpenGuardInvalid | 215 | Doc-only |
| StageInductionGapAnalysis | 53 | Doc-only |
| TAxiomDependentCode | 316 | Doc-only |
| UltrafilterDeadCode | 1,064 | Doc-only |
| XuLemma321Legacy | 75 | Doc-only |
| **Total** | **2,434** | |

### Tier 2: Cheap Wins (Valid Imports, Likely Compiles with sorry)

| Subdirectory | Lines | Est. Effort | Notes |
|---|---:|---|---|
| DiscreteXY | 72 | 5 min | 1 sorry, clean code |
| FiltrationOrdering | 167 | 10 min | 3 BX1-dependent sorries, clean structure |
| ScheduleBasedBFMCS | 222 | 15 min | May have type drift |
| RoundRobinChain/DRMChain | 286 | 15 min | Active module refs valid |
| **Total** | **747** | **~45 min** | |

### Tier 3: Medium Effort (Import Path Fixes + Possible Type Drift)

| Subdirectory | Lines | Est. Effort | Notes |
|---|---:|---|---|
| QuasimodelOracle | 1,467 | 30 min | 1 file needs ParametricRepresentation rename |
| DenseChronicle | 281 | 15 min | Mathlib imports valid |
| DefectDirectedChain | 1,556 | 45 min | Large file, ParametricRepresentation rename |
| UltrafilterFrame | 1,553 | 45 min | TenseS5Algebra circular dependency |
| **Total** | **4,857** | **~2.5 hours** | |

### Tier 4: Significant Effort (Complex Internal Dependencies)

| Subdirectory | Lines | Est. Effort | Notes |
|---|---:|---|---|
| StrictSemanticsLegacy | 14,329 | 3-5 hours | 9 files, internal import graph, largest archive |
| ChainCompleteness | 4,186 | 2-3 hours | 12 files, internal cross-refs + StrictSemanticsLegacy deps |
| **Total** | **18,515** | **5-8 hours** | |

### Overall Effort Summary

| Tier | Files | Lines | Effort |
|---|---:|---:|---|
| Zero (doc-only) | 18 | 2,434 | 0 |
| Cheap (valid imports) | 5 | 747 | 45 min |
| Medium (path fixes) | 7 | 4,857 | 2.5 hours |
| Significant (complex deps) | 21 | 18,515 | 5-8 hours |
| **Total Compilation Work** | **33** | **24,119** | **8-11 hours** |

**Note**: "Compiles" here means `import` resolution succeeds and elaboration proceeds (with `sorry`). It does NOT mean proofs are complete -- Boneyard files are expected to have `sorry` stubs.

---

## 6. Import Dependency Graph

The internal dependency order for compilation is:

```
Level 0 (no Boneyard deps):
  DiscreteXY/Discreteness
  FiltrationOrdering/SigmaOrdering
  ScheduleBasedBFMCS/RootScopedChain
  RoundRobinChain/DRMChain
  QuasimodelOracle/OracleStep
  QuasimodelOracle/RoundRobinChain
  DenseChronicle/CantorIsoCountermodel
  ChainCompleteness/Algebraic/DeterministicChain

Level 1 (depends on StrictSemanticsLegacy):
  StrictSemanticsLegacy/Bundle/SuccChainFMCS  (no Boneyard deps)
  StrictSemanticsLegacy/Algebraic/RestrictedTruthLemma  (no Boneyard deps)
  StrictSemanticsLegacy/FrameConditions/Completeness  (no Boneyard deps)
  UltrafilterFrame/TenseS5Algebra  (no Boneyard deps, Mathlib dep)

Level 2:
  StrictSemanticsLegacy/Bundle/CanonicalConstruction  (imports SuccChainFMCS)
  StrictSemanticsLegacy/Algebraic/UltrafilterChain  (imports SuccChainFMCS + TenseS5Algebra)
  UltrafilterFrame/UltrafilterFrame  (imports TenseS5Algebra)
  ChainCompleteness/Bundle/MCSWitnessSuccessor  (imports SuccChainFMCS + UltrafilterChain)
  ChainCompleteness/Bundle/TargetedChain  (imports SuccChainFMCS + UltrafilterChain)
  ChainCompleteness/Bundle/SuccChainTaskFrame  (imports SuccChainFMCS)
  ChainCompleteness/Bundle/SimplifiedChain  (imports SuccChainFMCS)

Level 3:
  StrictSemanticsLegacy/BaseCompleteness  (imports CanonicalConstruction)
  StrictSemanticsLegacy/Algebraic/DovetailedChain  (imports UltrafilterChain + RestrictedTruthLemma)
  StrictSemanticsLegacy/DiscreteCompleteness  (imports DiscreteCompleteness + CanonicalConstruction)
  StrictSemanticsLegacy/DenseCompleteness  (imports DenseCompleteness + CanonicalConstruction)
  ChainCompleteness/Bundle/SuccChainWorldHistory  (imports SuccChainTaskFrame)
  ChainCompleteness/Bundle/MCSWitnessChain  (imports MCSWitnessSuccessor)
  ChainCompleteness/Bundle/ResolvingChain  (imports SimplifiedChain + TargetedChain)
  ChainCompleteness/Algebraic/DeterministicFMCS  (imports DeterministicChain + UltrafilterChain)
  QuasimodelOracle/OracleCoherence  (imports ParametricCompleteness)
  DefectDirectedChain/RootScopedChain  (imports ParametricCompleteness)

Level 4:
  ChainCompleteness/Bundle/SuccChainTruth  (imports SuccChainTaskFrame + SuccChainWorldHistory)
  ChainCompleteness/Algebraic/FiniteDeferral  (imports DeterministicChain + DeterministicFMCS)

Level 5:
  ChainCompleteness/Completeness/SuccChainCompleteness  (imports SuccChainTruth)
```

---

## 7. README Coverage Gap

### Subdirectories Missing READMEs (9 directories)

| Subdirectory | Files | Lines | Content Summary |
|---|---:|---:|---|
| ChainCompleteness | 12 | 4,186 | Earlier chain completeness iteration |
| ClosedGuardLegacy | 4 | 352 | Closed guard `[t,s]` axioms/proofs |
| DeadCanonicalModel | 1 | 90 | Enriched seed approach |
| DefectDirectedChain | 1 | 1,556 | Root-scoped defect chain |
| DenseChronicle | 3 | 281 | Dense chronicle attempts |
| DiscreteXY | 1 | 72 | Discrete x/y content approach |
| NonBurgessSeed | 1 | 141 | Legacy g/h content |
| OpenGuardInvalid | 1 | 215 | BX8/BX9 dependent sorry stubs |
| RoundRobinChain | 2 | 2,522 | Round-robin chain + DRM |
| UltrafilterFrame | 2 | 1,553 | STSA + ultrafilter frame |

---

## 8. Recommended Implementation Plan

### Phase 1: Infrastructure (30 min)

1. Add `BoneyardArchive` lean_lib to `lakefile.lean` (non-default target, globs submodules)
2. Create aggregator or use `.submodules` glob

### Phase 2: Import Path Fixes (2-3 hours)

1. Fix `ParametricRepresentation` -> `ParametricCompleteness` (5 files, sed)
2. Fix internal cross-references in ChainCompleteness (10 files, mechanical rewrite)
3. Fix `TenseS5Algebra` path for UltrafilterChain and UltrafilterFrame (2 files)
4. Verify Mathlib imports resolve (should work with no changes)

### Phase 3: Compilation Verification (2-4 hours)

1. Run `lake build BoneyardArchive` and iterate on type errors
2. Add `sorry` stubs for any elaboration failures due to API drift
3. Goal: all files elaborate (with sorry) without import or type errors

### Phase 4: Cleanup (1-2 hours)

1. Convert 18 doc-only `.lean` files to README content
2. Delete the emptied `.lean` files (reduces count from 56 to 38)
3. Create 9 missing README.md files

### Phase 5: Maintenance Standard (30 min)

1. Add CI step: `lake build BoneyardArchive` in a non-blocking job
2. Document Boneyard archival procedure in README
3. Template for new archives: imports must use Boneyard-qualified paths

---

## 9. Key Decision Point: Aggressive vs. Conservative Cleanup

### Conservative (Recommended for Phase 1)

- Keep all files, fix imports, verify compilation
- Doc-only files remain as `.lean` (harmless, contain useful annotations)
- ~8-11 hours total effort

### Aggressive

- Delete all doc-only `.lean` files (18 files, 2,434 lines)
- Consolidate parent README already has full inventory table
- Delete files that cannot compile without major rewriting (none identified -- all are fixable)
- ~6-9 hours total, reduces to 38 files, ~26,443 lines

### Recommended: Conservative Phase 1, Aggressive Phase 4

Start by making everything compile (confidence in the archive), then prune documentation duplication.

---

## 10. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Type drift in active modules breaks Boneyard elaboration | High | Low | Add sorry stubs; this is expected |
| Import path changes break again on future refactors | Medium | Low | CI catch via non-blocking build job |
| Aggregator accidentally gets imported by active code | Low | High | No `@[default_target]`, no cross-import audit |
| Boneyard sorry count confuses metrics | Low | Low | Already documented in README |

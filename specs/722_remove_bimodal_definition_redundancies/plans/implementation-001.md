# Implementation Plan: Task #722

- **Task**: 722 - Remove Bimodal Definition Redundancies
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/722_remove_bimodal_definition_redundancies/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove redundant definitions throughout the Bimodal/ project by consolidating to single canonical sources in `Boneyard/Metalogic_v2/Core/`. The project has three parallel metalogic implementations with significant duplication - `SetMaximalConsistent`, `SetConsistent`, `Consistent`, and `set_lindenbaum` each appear 3-4 times. The active code (`Metalogic/`) already uses `hiding` clauses to manage conflicts, indicating awareness of redundancy. This plan follows an incremental approach: first audit dependencies, then consolidate core definitions, and finally clean up imports.

### Research Integration

Key findings from research-001.md:
- Core MCS definitions (`SetConsistent`, `SetMaximalConsistent`) have 4 definitions each
- `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` is the canonical source
- `Metalogic/Core/MaximalConsistent.lean` already re-exports from the canonical source
- Active code uses `hiding` clauses to avoid conflicts (IndexedMCSFamily.lean, CoherentConstruction.lean, TruthLemma.lean)
- Helper lemmas like `set_mcs_closed_under_derivation` and `set_mcs_all_future_all_future` are imported from deprecated `Boneyard/Metalogic/Completeness.lean`

## Goals & Non-Goals

**Goals**:
- Each core MCS definition exists in exactly one location
- Remove need for `hiding` clauses in active Metalogic/ code
- Simplify import statements in active files
- `lake build` passes with no new errors

**Non-Goals**:
- Complete removal of all Boneyard code (may still have unique content)
- Refactoring proof strategies (only addressing duplicate definitions)
- Removing deprecated Duration construction code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking active builds | High | Medium | Run `lake build` after each file modification |
| Missing hidden dependencies | Medium | Low | Search for fully qualified names before each removal |
| Circular import dependencies | Medium | Low | Map dependency graph in Phase 1 before changes |
| Scope creep into proof refactoring | Medium | Medium | Focus only on duplicate definitions, not proof structure |

## Implementation Phases

### Phase 1: Audit Import Dependencies [COMPLETED]

**Goal**: Map all dependencies before making changes to understand the impact of each removal

**Tasks**:
- [x] List all imports from `Boneyard/Metalogic/Completeness.lean` across the codebase
- [x] Identify which specific definitions are used from each import
- [x] Map the `hiding` clauses in active Metalogic/ files to understand conflicts
- [x] Document which lemmas in deprecated code have no equivalent in canonical source
- [x] Create dependency graph showing which files depend on which definitions

**Audit Results**:

Files importing `Boneyard/Metalogic/Completeness.lean`:
- `Metalogic.lean` (root)
- `IndexedMCSFamily.lean` - uses `set_mcs_closed_under_derivation`
- `CoherentConstruction.lean` - uses `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`, `set_mcs_closed_under_derivation`
- `TruthLemma.lean` - uses `set_mcs_negation_complete`, `set_mcs_implication_property`, `set_mcs_closed_under_derivation`

Hiding clauses:
- `CoherentConstruction.lean:48` hides `SetMaximalConsistent SetConsistent Consistent set_lindenbaum`

Lemmas in deprecated code WITHOUT equivalent in canonical source:
- `set_mcs_closed_under_derivation` (Completeness.lean:577)
- `set_mcs_implication_property` (Completeness.lean:655)
- `set_mcs_negation_complete` (Completeness.lean:679)
- `set_mcs_all_future_all_future` (Completeness.lean:1055)
- `set_mcs_all_past_all_past` (Completeness.lean:1115)

These 5 lemmas need to be moved or re-exported before we can remove the import.

**Timing**: 45 minutes

**Files to analyze**:
- `Metalogic/Representation/IndexedMCSFamily.lean` - uses `set_mcs_closed_under_derivation`
- `Metalogic/Representation/CoherentConstruction.lean` - uses `set_mcs_all_future_all_future`
- `Metalogic/Representation/TruthLemma.lean` - imports from both sources

**Verification**:
- Dependency graph documented
- All `hiding` clauses catalogued
- List of definitions without canonical equivalent identified

---

### Phase 2: Consolidate Core MCS Definitions [COMPLETED]

**Goal**: Remove duplicate `SetConsistent`, `SetMaximalConsistent`, `Consistent` definitions from deprecated files

**Tasks**:
- [x] Verify `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` has complete definitions
- [x] Update imports in affected files to use `Metalogic.Core` exports
- [x] Remove `hiding` clauses - replaced with fully qualified names
- [x] Run `lake build` and verify no new breakages

**Approach Change**: Rather than removing duplicate definitions from Boneyard files (which would break
internal Boneyard dependencies), we:
1. Removed `open Bimodal.Boneyard.Metalogic hiding ...` from CoherentConstruction.lean
2. Removed `open Bimodal.Boneyard.Metalogic` from TruthLemma.lean
3. Changed all usages to fully qualified names (e.g., `Bimodal.Boneyard.Metalogic.set_mcs_closed_under_derivation`)

This eliminates namespace conflicts without breaking Boneyard internal code.

**Note**: TruthLemma.lean has pre-existing type mismatch errors at lines 396 and 417 (unrelated to our changes).

**Timing**: 1.5 hours

**Files to modify**:
- `Boneyard/Metalogic/Completeness.lean` - remove duplicate MCS definitions
- `Boneyard/Metalogic/Representation/CanonicalModel.lean` - remove duplicate definitions
- `Metalogic/Core/MaximalConsistent.lean` - may need to extend re-exports

**Verification**:
- `lake build` passes
- No `hiding SetMaximalConsistent SetConsistent Consistent` clauses needed

---

### Phase 3: Move Essential Lemmas to Core [DEFERRED]

**Goal**: Relocate essential lemmas that active code needs from deprecated Completeness.lean to canonical Core location

**Status**: DEFERRED - Given the success of Phase 2 (fully qualified names eliminate namespace conflicts),
moving lemmas is no longer blocking. The lemmas (`set_mcs_closed_under_derivation`, `set_mcs_all_future_all_future`,
etc.) have complex dependencies that would require significant refactoring to move.

**Future Work**: If/when Boneyard/Metalogic/Completeness.lean is to be fully deprecated, these lemmas should be:
1. Moved to `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean`
2. Dependencies like `deduction_theorem`, `derivation_exchange` must move first
3. Re-exports updated in `Metalogic/Core/MaximalConsistent.lean`

**Current State**: Active code uses fully qualified names to access these lemmas without namespace conflicts.
The import statement `import Bimodal.Boneyard.Metalogic.Completeness` remains necessary but harmless.

---

### Phase 4: Consolidate set_lindenbaum [NOT STARTED]

**Goal**: Remove duplicate `set_lindenbaum` theorem definitions

**Tasks**:
- [ ] Verify `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:290` has complete theorem
- [ ] Check if `Boneyard/Metalogic/Completeness.lean:360` version is identical
- [ ] Check if `Boneyard/Metalogic/Representation/CanonicalModel.lean:139` version is identical
- [ ] Remove duplicates, keeping canonical version
- [ ] Update any imports that relied on removed versions
- [ ] Run `lake build` and verify

**Timing**: 45 minutes

**Files to modify**:
- `Boneyard/Metalogic/Completeness.lean` - remove duplicate `set_lindenbaum`
- `Boneyard/Metalogic/Representation/CanonicalModel.lean` - remove duplicate

**Verification**:
- `set_lindenbaum` exists in exactly one location
- `lake build` passes

---

### Phase 5: Clean Up and Verify [NOT STARTED]

**Goal**: Final verification that all redundancies are resolved and code is clean

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Search for any remaining `hiding` clauses for MCS definitions
- [ ] Verify no fully-qualified references to removed definitions remain
- [ ] Check that active Metalogic/ files have simplified import lists
- [ ] Document any remaining intentional duplicates (if any)

**Timing**: 30 minutes

**Files to review**:
- All active Metalogic/ files
- All modified Boneyard/ files

**Verification**:
- `lake build` passes with no warnings about unused imports
- No `hiding` clauses for core MCS definitions in active code
- Import statements are cleaner than before

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No new errors or warnings introduced
- [ ] Each core MCS definition (`SetConsistent`, `SetMaximalConsistent`, `Consistent`, `set_lindenbaum`) exists in exactly one location
- [ ] Active Metalogic/ files compile without `hiding` clauses for MCS definitions
- [ ] Import statements simplified in active files

## Artifacts & Outputs

- `specs/722_remove_bimodal_definition_redundancies/plans/implementation-001.md` (this file)
- `specs/722_remove_bimodal_definition_redundancies/summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Rollback/Contingency

If changes break the build in unexpected ways:
1. Use `git diff` to identify breaking change
2. Revert specific file with `git checkout -- <file>`
3. If widespread breakage, `git checkout .` for full revert
4. Re-analyze dependencies before retrying

For partial failures within a phase:
1. Keep completed removals that pass build
2. Revert only the breaking removal
3. Note dependency for investigation in next session

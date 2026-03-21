# Implementation Plan: Task #914

- **Task**: 914 - Rename IndexedMCSFamily to BFMCS across codebase
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/914_rename_indexedmcsfamily_to_bfmcs/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

Rename `IndexedMCSFamily` to `BFMCS` (Bundled Family of Maximal Consistent Sets) across 204 occurrences in 12 active Lean files to make the two-level ontological structure explicit. The rename must be atomic since all active files directly import the definition file. Also rename related identifiers (`constantIndexedMCSFamily` -> `constantBFMCS`, `toIndexedMCSFamily` -> `toBFMCS`) and update the file from `IndexedMCSFamily.lean` to `BFMCS.lean`.

### Research Integration

From research-001.md:
- 204 occurrences across 12 active Lean files (structure name + namespace members)
- 198 occurrences across 20 Boneyard files (skip - separate cleanup task)
- Related identifiers: `constantIndexedMCSFamily` (13 occurrences), `toIndexedMCSFamily` (9 occurrences)
- No BFMCS name collision exists (lean_local_search confirmed zero results)
- All active files directly import `IndexedMCSFamily.lean` - atomic rename required

## Goals & Non-Goals

**Goals**:
- Rename `IndexedMCSFamily` structure to `BFMCS` in all active Lean files
- Rename file `IndexedMCSFamily.lean` to `BFMCS.lean`
- Update all import paths to use `Bundle.BFMCS`
- Rename `constantIndexedMCSFamily` to `constantBFMCS`
- Rename `toIndexedMCSFamily` to `toBFMCS`
- Update `extends IndexedMCSFamily` to `extends BFMCS` in TemporalCoherentFamily
- Achieve clean `lake build` after rename

**Non-Goals**:
- Updating Boneyard files (task 916 will handle this)
- Adding comprehensive BFMCS ontology documentation (task 915 handles this)
- Updating specs/ historical references (these are documentation, not code)
- Updating docs/claude-directory-export.md (auto-generated)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Partial rename causes build failure | High | Medium | Execute all renames atomically in single phase per file |
| Missed occurrences break build | High | Low | Use systematic grep verification before commit |
| Import cycle issues after file rename | Medium | Low | Rename file first, update imports immediately after |
| `extends BFMCS` changes coercion name | Low | Certain | Update all `.toIndexedMCSFamily` to `.toBFMCS` explicitly |

## Implementation Phases

### Phase 1: Rename Definition File and Update Imports [COMPLETED]

- **Dependencies:** None
- **Goal:** Rename the definition file and update all import statements to the new module path

**Tasks**:
- [ ] Rename file: `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` -> `BFMCS.lean`
- [ ] Update import in `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
- [ ] Update import in `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- [ ] Update import in `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- [ ] Update import in `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`
- [ ] Update import in `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`
- [ ] Update import in `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- [ ] Update import in `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- [ ] Update import in `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` - Rename to BFMCS.lean
- 8 files with direct imports - Update import path

**Verification**:
- All import statements reference `Bundle.BFMCS`
- No import references remain to `Bundle.IndexedMCSFamily`

---

### Phase 2: Rename Structure and Namespace in Definition File [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Rename the structure definition and all namespace members to BFMCS

**Tasks**:
- [ ] Rename `structure IndexedMCSFamily` to `structure BFMCS`
- [ ] Rename `namespace IndexedMCSFamily` to `namespace BFMCS`
- [ ] Update module docstring to explain BFMCS acronym and ontology

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - Structure definition and namespace

**Verification**:
- Structure is named `BFMCS`
- Namespace is `BFMCS`
- All lemmas accessible via `BFMCS.*`

---

### Phase 3: Update All Active Source Files [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Replace all `IndexedMCSFamily` references with `BFMCS` across active source files

**Tasks**:
- [ ] Update `BMCS.lean` (11 occurrences) - BMCS field types
- [ ] Update `Construction.lean` (13 occurrences) - including `constantIndexedMCSFamily`
- [ ] Update `ModalSaturation.lean` (9 occurrences) - return types
- [ ] Update `BMCSTruth.lean` (31 occurrences) - parameter types in truth definitions
- [ ] Update `CoherentConstruction.lean` (80 occurrences) - heaviest user
- [ ] Update `DovetailingChain.lean` (6 occurrences) - chain construction
- [ ] Update `TemporalCoherentConstruction.lean` (14 occurrences) - including `extends IndexedMCSFamily`
- [ ] Update `TruthLemma.lean` (11 occurrences) - parameter types
- [ ] Update `Completeness.lean` (2 occurrences) - type references
- [ ] Update `Representation.lean` (12 occurrences) - parameter types
- [ ] Update `Metalogic.lean` (1 occurrence) - comment only

**Timing**: 45 minutes

**Files to modify**:
- All 11 files listed above with `IndexedMCSFamily` references

**Verification**:
- `grep -r "IndexedMCSFamily" Theories/Bimodal/Metalogic/` returns no results (excluding Boneyard)
- All files reference `BFMCS` instead

---

### Phase 4: Rename Related Identifiers [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Rename `constantIndexedMCSFamily` and `toIndexedMCSFamily` for consistency

**Tasks**:
- [ ] Rename `constantIndexedMCSFamily` to `constantBFMCS` in `Construction.lean`
- [ ] Update all references to `constantIndexedMCSFamily` (4 files, 13 occurrences total)
- [ ] Rename `toIndexedMCSFamily` to `toBFMCS` in `TemporalCoherentConstruction.lean`
- [ ] Update all references to `toIndexedMCSFamily` (3 files, 9 occurrences total)
- [ ] Update `constantIndexedMCSFamily_mcs_eq` to `constantBFMCS_mcs_eq`
- [ ] Update `constantIndexedMCSFamily_is_constant` to `constantBFMCS_is_constant`

**Timing**: 20 minutes

**Files to modify**:
- `Construction.lean` - Definition of `constantBFMCS`
- `CoherentConstruction.lean` - References to constant lemmas
- `TemporalCoherentConstruction.lean` - `toBFMCS` coercion
- Other files with references

**Verification**:
- `grep -r "constantIndexedMCSFamily" Theories/` returns no results (excluding Boneyard)
- `grep -r "toIndexedMCSFamily" Theories/` returns no results (excluding Boneyard)

---

### Phase 5: Build Verification and Cleanup [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Verify clean build and confirm no stray references remain

**Tasks**:
- [ ] Run `lake build` and verify clean build
- [ ] Verify no `IndexedMCSFamily` references remain in active Theories/ (excluding Boneyard)
- [ ] Verify all BFMCS namespace members are accessible
- [ ] Verify `TemporalCoherentFamily.toBFMCS` coercion works

**Timing**: 20 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` exits with code 0
- `grep -r "IndexedMCSFamily" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard` returns empty
- `grep -r "constantIndexedMCSFamily" Theories/ --include="*.lean" | grep -v Boneyard` returns empty
- `grep -r "toIndexedMCSFamily" Theories/ --include="*.lean" | grep -v Boneyard` returns empty

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] No references to `IndexedMCSFamily` remain in active source (excluding Boneyard)
- [ ] No references to `constantIndexedMCSFamily` remain in active source
- [ ] No references to `toIndexedMCSFamily` remain in active source
- [ ] BFMCS structure accessible via `Bimodal.Metalogic.Bundle.BFMCS`
- [ ] All BFMCS namespace lemmas accessible (`.at`, `.consistent`, `.maximal`, etc.)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - Renamed definition file
- 12 modified active Lean files with BFMCS references
- `specs/914_rename_indexedmcsfamily_to_bfmcs/summaries/implementation-summary-20260220.md` - Implementation summary

## Rollback/Contingency

If the rename causes unforeseen issues:
1. `git checkout HEAD~1 -- Theories/Bimodal/Metalogic/` to restore all modified files
2. `git mv Theories/Bimodal/Metalogic/Bundle/BFMCS.lean Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` to restore filename
3. Run `lake build` to verify rollback worked

The rename is purely mechanical with no semantic changes, so rollback should fully restore functionality.

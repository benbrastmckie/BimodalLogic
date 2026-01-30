# Implementation Plan: Task #774

- **Task**: 774 - Restore representation theorem as under development
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: Task 772 (archival) completed
- **Research Inputs**: specs/774_restore_representation_theorem_as_under_development/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Restore the representation theorem proof files from `Theories/Bimodal/Boneyard/Metalogic_v4/` to a new `Bimodal/Metalogic/NEW/` directory structure that allows continued development while maintaining import isolation. The NEW/ directory will be organized into subdirectories reflecting the natural mathematical groupings of proofs, with enforced import isolation to prevent sorry contamination of the main codebase.

### Research Integration

Key findings from research-001.md:
- 7 files archived with 17 total sorries across 3 core files
- Files form a coherent dependency chain: TaskRelation -> CanonicalHistory, CoherentConstruction -> TruthLemma -> UniversalCanonicalModel -> InfinitaryStrongCompleteness -> Compactness
- The Algebraic/ directory provides a model pattern for "under development" organization
- Import isolation can be enforced by commenting out imports in root module files

## Goals & Non-Goals

**Goals**:
- Create `Bimodal/Metalogic/NEW/` directory structure with logical subdirectory organization
- Restore archived files with updated imports and namespaces
- Ensure NEW/ subdirectories can import FROM elsewhere in the project
- Ensure NOTHING outside NEW/ can import from NEW/ subdirectories
- Create clear README documentation explaining sorry status and future development paths
- Enable `lake build` to succeed without compiling NEW/ (commented imports in root)

**Non-Goals**:
- Fix or reduce the 17 sorries (architecturally unprovable per Task 750)
- Create new completeness approaches (future tasks)
- Modify the existing sorry-free completeness path (FMP/SemanticCanonicalModel.lean)
- Remove files from Boneyard (keep for historical reference)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle introduced | High | Low | Test imports carefully; NEW/ only imports outward |
| Build breakage | Medium | Low | Root imports commented; isolated testing |
| Namespace conflicts | Medium | Low | Use unique namespace prefix `Bimodal.Metalogic.NEW` |
| Documentation confusion | Medium | Medium | Clear README with sorry status and rationale |

## Implementation Phases

### Phase 1: Create NEW/ Directory Structure [NOT STARTED]

**Goal**: Establish the directory skeleton with appropriate subdirectory organization

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/NEW/` directory
- [ ] Create `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/` subdirectory for the canonical model approach
- [ ] Create placeholder `NEW.lean` root module file (imports commented)
- [ ] Create placeholder `RepresentationTheorem/RepresentationTheorem.lean` root module

**Timing**: 20 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/NEW/` (directory)
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/` (directory)
- `Theories/Bimodal/Metalogic/NEW/NEW.lean` (root module, commented imports)
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/RepresentationTheorem.lean`

**Verification**:
- Directories exist
- `lake build` succeeds (NEW/ not imported)

---

### Phase 2: Restore Core Infrastructure Files [NOT STARTED]

**Goal**: Copy and adapt the foundational files (TaskRelation, CoherentConstruction, CanonicalHistory)

**Tasks**:
- [ ] Copy `TaskRelation.lean` to `NEW/RepresentationTheorem/`
- [ ] Update namespace to `Bimodal.Metalogic.NEW.RepresentationTheorem`
- [ ] Update internal imports to use `Bimodal.Metalogic.Representation.*` for shared definitions
- [ ] Replace "ARCHIVED" header with "UNDER DEVELOPMENT" status
- [ ] Copy `CoherentConstruction.lean` with same updates
- [ ] Copy `CanonicalHistory.lean` with same updates (0 sorries, depends on TaskRelation)

**Timing**: 45 minutes

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/TaskRelation.lean`
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/CanonicalHistory.lean`

**Verification**:
- Each file compiles independently (may have expected sorries)
- Namespaces are correct
- No imports from outside NEW/ directory point into NEW/

---

### Phase 3: Restore Truth Lemma and Model Construction [NOT STARTED]

**Goal**: Copy and adapt the truth lemma and universal model files

**Tasks**:
- [ ] Copy `TruthLemma.lean` to `NEW/RepresentationTheorem/`
- [ ] Update namespace and imports
- [ ] Replace "ARCHIVED" header with "UNDER DEVELOPMENT" status
- [ ] Copy `UniversalCanonicalModel.lean` with same updates (0 sorries, depends on TruthLemma)

**Timing**: 30 minutes

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/UniversalCanonicalModel.lean`

**Verification**:
- Files compile with expected sorries
- Dependency chain is correct (TruthLemma imports CanonicalHistory)

---

### Phase 4: Restore Completeness and Compactness [NOT STARTED]

**Goal**: Copy the top-level theorem files that build on the representation theorem

**Tasks**:
- [ ] Copy `InfinitaryStrongCompleteness.lean` to `NEW/RepresentationTheorem/`
- [ ] Update namespace and imports
- [ ] Copy `Compactness.lean` with same updates
- [ ] Update `RepresentationTheorem.lean` root module to import all files (comments for now)

**Timing**: 30 minutes

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/InfinitaryStrongCompleteness.lean`
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/Compactness.lean`
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/RepresentationTheorem.lean` (update)

**Verification**:
- All files in subdirectory compile (with expected sorries)
- `RepresentationTheorem.lean` documents the module structure

---

### Phase 5: Create Documentation and Import Isolation [NOT STARTED]

**Goal**: Document the NEW/ structure, enforce import isolation, and update main Metalogic

**Tasks**:
- [ ] Create `NEW/README.md` explaining the purpose and import isolation rules
- [ ] Create `NEW/RepresentationTheorem/README.md` with sorry table and development notes
- [ ] Update `Metalogic/Metalogic.lean` to document NEW/ existence (import remains commented)
- [ ] Update `Metalogic/README.md` to reference NEW/ directory
- [ ] Verify no existing files import from NEW/

**Timing**: 30 minutes

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/NEW/README.md`
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/README.md`
- `Theories/Bimodal/Metalogic/Metalogic.lean` (add comment about NEW/)
- `Theories/Bimodal/Metalogic/README.md` (update)

**Verification**:
- `grep -r "import.*NEW" Theories/` shows only internal NEW/ imports
- Documentation clearly explains sorry status and isolation rules
- Main `lake build` succeeds without touching NEW/

---

### Phase 6: Verification and Build Testing [NOT STARTED]

**Goal**: Ensure the complete setup works and is isolated

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.NEW.RepresentationTheorem.TaskRelation` (expect sorries)
- [ ] Run `lake build Bimodal.Metalogic.NEW.RepresentationTheorem.TruthLemma` (expect sorries)
- [ ] Run `lake build` (full build, NEW/ should NOT be compiled)
- [ ] Verify sorry count in NEW/ matches expected (17 total)
- [ ] Create implementation summary

**Timing**: 25 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Individual NEW/ modules compile with expected sorries
- Main build excludes NEW/ entirely
- Sorry count matches research report (17 across 3 files)

## Testing & Validation

- [ ] `lake build` succeeds without compiling NEW/
- [ ] Individual NEW/ modules compile when built explicitly
- [ ] `grep -r "import.*Metalogic.NEW" Theories/` shows only internal imports within NEW/
- [ ] Sorry count in NEW/RepresentationTheorem/ is exactly 17
- [ ] All README files explain the sorry status and isolation rules
- [ ] Namespace is `Bimodal.Metalogic.NEW.RepresentationTheorem.*`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/NEW/` directory structure
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/*.lean` (7 files)
- `Theories/Bimodal/Metalogic/NEW/README.md`
- `Theories/Bimodal/Metalogic/NEW/RepresentationTheorem/README.md`
- Updated `Theories/Bimodal/Metalogic/Metalogic.lean`
- Updated `Theories/Bimodal/Metalogic/README.md`
- `specs/774_restore_representation_theorem_as_under_development/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation causes unexpected issues:
1. Delete `Theories/Bimodal/Metalogic/NEW/` directory entirely
2. Revert changes to `Metalogic.lean` and `README.md`
3. The original files remain in `Boneyard/Metalogic_v4/` for reference
4. No impact on existing sorry-free completeness path

The isolation design (commented imports) means rollback is trivial and has no downstream effects.

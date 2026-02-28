# Implementation Plan: Move Bimodal Boneyard Contents

- **Task**: 950 - move_bimodal_boneyard_contents
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/950_move_bimodal_boneyard_contents/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task moves deprecated metalogic code from `Theories/Bimodal/Boneyard/` to `Boneyard/Metalogic/`. The source contains 112 Lean files (3.1MB) across 17 directories, all representing superseded approaches to the TM bimodal logic completeness proof. Research identified 2 active files importing from the Boneyard that require import updates, and one directory conflict (Metalogic_v4) requiring resolution.

### Research Integration

Key findings from research-001.md:
- **Scope**: 112 Lean files, 17 directories, 3.1MB total
- **Imports**: Only 2 active files depend on Boneyard (Demo.lean, MaximalConsistent.lean)
- **Conflict**: Existing `Boneyard/Metalogic_v4/` must be reconciled with source `Metalogic_v4/`
- **Structure**: Flattened approach recommended (no intermediate `Bimodal/` directory)

## Goals & Non-Goals

**Goals**:
- Move all contents from `Theories/Bimodal/Boneyard/` to `Boneyard/Metalogic/`
- Preserve README.md files documenting deprecation context
- Update or remove imports in active files (Demo.lean, MaximalConsistent.lean)
- Resolve Metalogic_v4 directory conflict
- Verify no build regressions

**Non-Goals**:
- Refactoring or fixing sorries in moved code (they are archived)
- Creating new imports to Boneyard code
- Modifying the archived code content (only paths)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports in active files | M | H | Update imports before/after move; verify with `lake build` |
| Metalogic_v4 file collision | M | M | Check for overlapping files before merge; rename if needed |
| Missing README context | L | L | Preserve all README.md files during move |
| Lake build failure post-move | M | M | Run `lake build` after each phase |

## Implementation Phases

### Phase 1: Preparation and Conflict Analysis [NOT STARTED]

- **Dependencies:** None
- **Goal:** Prepare target structure and analyze Metalogic_v4 conflict

**Tasks:**
- [ ] Create target directory `Boneyard/Metalogic/`
- [ ] Compare source `Theories/Bimodal/Boneyard/Metalogic_v4/` with target `Boneyard/Metalogic_v4/`
- [ ] Document file overlap (if any) and determine merge strategy
- [ ] Backup current import state by listing files importing from Boneyard

**Timing:** 15 minutes

**Files to create:**
- `Boneyard/Metalogic/` (directory)

**Verification:**
- Target directory exists
- Conflict analysis documented

---

### Phase 2: Move Contents [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Move all source Boneyard contents to target location

**Tasks:**
- [ ] Move all directories from `Theories/Bimodal/Boneyard/` to `Boneyard/Metalogic/`
- [ ] Handle Metalogic_v4 conflict per Phase 1 analysis (likely merge into existing `Boneyard/Metalogic_v4/`)
- [ ] Verify all 112 Lean files moved (count check)
- [ ] Verify all README.md files preserved
- [ ] Remove empty source directory `Theories/Bimodal/Boneyard/`

**Timing:** 20 minutes

**Files to modify:**
- `Theories/Bimodal/Boneyard/*` - move to `Boneyard/Metalogic/`
- `Boneyard/Metalogic_v4/` - merge with source Metalogic_v4 contents

**Verification:**
- `find Boneyard/Metalogic -name "*.lean" | wc -l` returns ~112 (minus Metalogic_v4 files merged elsewhere)
- `ls Theories/Bimodal/Boneyard 2>/dev/null` returns error (directory removed)

---

### Phase 3: Update Imports [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Fix imports in active files that referenced old Boneyard paths

**Tasks:**
- [ ] Update `Theories/Bimodal/Examples/Demo.lean` imports (4 Boneyard imports)
  - Change `import Bimodal.Boneyard.*` to appropriate paths or remove if unused
- [ ] Update `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` import
  - Change `import Bimodal.Boneyard.Metalogic_v2.Core.MaximalConsistent` to use active module or remove
- [ ] Verify no other files import from old Boneyard path

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Examples/Demo.lean` - update/remove Boneyard imports
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - update/remove Boneyard import

**Verification:**
- `grep -r "import.*Bimodal\.Boneyard" Theories/` returns empty

---

### Phase 4: Build Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Verify build passes and finalize

**Tasks:**
- [ ] Run `lake build` to verify no import errors
- [ ] Check for any remaining references to old paths
- [ ] Verify Demo.lean still compiles (may need to stub or update examples)
- [ ] Update lakefile.toml if any module roots changed (unlikely needed for Boneyard)

**Timing:** 25 minutes

**Files to check:**
- `lakefile.toml` - verify no Boneyard-specific globs

**Verification:**
- `lake build` completes without errors
- `grep -r "Bimodal/Boneyard" .` (case insensitive, excluding .git) returns no hits

---

## Testing & Validation

- [ ] `find Boneyard/Metalogic -name "*.lean" | wc -l` shows expected file count
- [ ] `ls Theories/Bimodal/Boneyard` fails (source removed)
- [ ] `grep -r "import.*Bimodal\.Boneyard" Theories/` returns empty
- [ ] `lake build` passes without errors
- [ ] All README.md files preserved (deprecation documentation intact)

## Artifacts & Outputs

- `specs/950_move_bimodal_boneyard_contents/plans/implementation-001.md` (this file)
- `specs/950_move_bimodal_boneyard_contents/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Updated `Boneyard/Metalogic/` directory structure
- Updated import statements in Demo.lean and MaximalConsistent.lean

## Rollback/Contingency

If the move causes unexpected issues:
1. Git revert the commit(s)
2. Restore original structure from git history
3. Re-run `lake build` to confirm restoration

Alternatively, use `git diff` to identify specific changes and selectively revert import updates while keeping the file moves.

# Implementation Plan: Task #905

- **Task**: 905 - Clean up Metalogic for Task 903
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/905_cleanup_metalogic_for_task_903/reports/research-001.md, specs/905_cleanup_metalogic_for_task_903/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task cleans up the Metalogic/Bundle/ directory by moving 8 orphan files (7,605 lines, 100 sorries, 1 axiom) to Boneyard/Bundle/ and removing the FALSE axiom `singleFamily_modal_backward_axiom` from Construction.lean. This prepares the codebase for task 903's completeness proof restructuring by eliminating dead code and reducing confusion from abandoned approaches. The cleanup follows the ordering 905 -> 903 -> 864 established in research-002.md.

### Research Integration

From research-001.md:
- Identified 8 files safe to move (Tier 1 + Tier 2 candidates)
- Confirmed 12 critical path files that MUST remain
- Mapped import dependencies to ensure no breakage
- Identified FALSE axiom in Construction.lean for removal

From research-002.md:
- Confirmed task ordering: 905 (cleanup) -> 903 (restructuring) -> 864 (RecursiveSeed)
- Validated that RecursiveSeed chain should be deferred (task 864 dependency)

## Goals & Non-Goals

**Goals**:
- Move 8 orphan files from Metalogic/Bundle/ to Boneyard/Bundle/
- Remove the FALSE axiom `singleFamily_modal_backward_axiom` from Construction.lean
- Verify the build passes after changes
- Reduce active sorry count by eliminating 100 sorries from active codebase

**Non-Goals**:
- Moving RecursiveSeed chain (deferred pending task 864)
- Modifying any critical path files beyond FALSE axiom removal
- Refactoring remaining Bundle/ code structure
- Addressing sorry debt in remaining files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Undocumented import dependency | Build breaks | Low | Run `lake build` after each file move |
| FALSE axiom has hidden consumers | Build breaks | Low | Grep for `singleFamily_modal_backward_axiom` before removal |
| SaturatedConstruction has hidden importers | Build breaks | Low | Grep for `SaturatedConstruction` imports |
| Boneyard/Bundle/ path conflict | Move fails | Low | Check if directory exists before creating |

## Axiom Characterization

### Pre-existing Axioms
- 1 FALSE axiom in `Construction.lean`: `singleFamily_modal_backward_axiom` (deliberately FALSE, marked DEPRECATED)

### Expected Resolution
- Phase 3 removes the FALSE axiom entirely
- No structural proof needed (axiom is FALSE by design, not a legitimate assumption)

### New Axioms
- None. This task removes an axiom, does not add any.

### Remaining Debt
After this implementation:
- 0 FALSE axioms in active Bundle/ code
- Downstream theorems using `construct_bmcs` may need update (but this is task 903's scope)

## Sorry Characterization

### Pre-existing Sorries
- 100 sorries across 8 Boneyard candidate files (will be moved out of active codebase)
- No sorries being actively resolved in this task

### Expected Resolution
- Sorries are not resolved; they are moved to Boneyard where they do not count toward active debt

### New Sorries
- None. This task does not introduce any new sorries.

### Remaining Debt
After this implementation:
- Repository sorry count reduced by ~100 (moved to Boneyard, excluded from metrics)
- Critical path files retain their existing sorries (task 903's scope)

## Implementation Phases

### Phase 1: Pre-flight Verification [COMPLETED]

- **Dependencies:** None
- **Goal:** Verify current build state and confirm no hidden dependencies

**Tasks:**
- [ ] Run `lake build` to confirm baseline build state
- [ ] Grep for imports of each Boneyard candidate file to confirm zero importers
- [ ] Grep for uses of `singleFamily_modal_backward_axiom` to confirm safe removal
- [ ] Verify Boneyard/Bundle/ directory structure (create if needed)

**Timing:** 20 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` - 0 importers expected
- `Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean` - 0 importers expected
- `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean` - 0 importers expected
- `Theories/Bimodal/Metalogic/Bundle/UnifiedChain.lean` - 0 importers expected
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - 0 importers expected
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - 0 importers expected
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - 0 importers expected
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - only FinalConstruction expected

**Verification:**
- All grep searches return 0 results (or only self-references)
- Build passes before any changes

**Progress:**

**Session: 2026-02-19, sess_1771527252_248861**
- Completed: Baseline build passes (1000 jobs, 0 errors)
- Completed: All 8 candidate files have 0 importers in active codebase
- Completed: singleFamily_modal_backward_axiom only used in Construction.lean (active) and SaturatedConstruction.lean (being moved)
- Completed: Boneyard/Bundle/ directory does not yet exist (will be created in Phase 2)

---

### Phase 2: Move Orphan Files to Boneyard [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Move 8 orphan files to Boneyard/Bundle/ in correct order

**Tasks:**
- [ ] Create `Theories/Bimodal/Boneyard/Bundle/` directory if not exists
- [ ] Move `FinalConstruction.lean` (depends on SaturatedConstruction)
- [ ] Move `SaturatedConstruction.lean` (now safe after FinalConstruction moved)
- [ ] Move `PreCoherentBundle.lean`
- [ ] Move `TemporalChain.lean`
- [ ] Move `WeakCoherentBundle.lean`
- [ ] Move `UnifiedChain.lean`
- [ ] Move `ZornFamily.lean`
- [ ] Move `TemporalLindenbaum.lean`
- [ ] Update any namespace declarations in moved files if needed
- [ ] Run `lake build` to verify no breakage

**Timing:** 45 minutes

**Files to move** (in order):
1. `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` -> `Theories/Bimodal/Boneyard/Bundle/FinalConstruction.lean`
2. `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` -> `Theories/Bimodal/Boneyard/Bundle/SaturatedConstruction.lean`
3. `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` -> `Theories/Bimodal/Boneyard/Bundle/PreCoherentBundle.lean`
4. `Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean` -> `Theories/Bimodal/Boneyard/Bundle/TemporalChain.lean`
5. `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean` -> `Theories/Bimodal/Boneyard/Bundle/WeakCoherentBundle.lean`
6. `Theories/Bimodal/Metalogic/Bundle/UnifiedChain.lean` -> `Theories/Bimodal/Boneyard/Bundle/UnifiedChain.lean`
7. `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` -> `Theories/Bimodal/Boneyard/Bundle/ZornFamily.lean`
8. `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` -> `Theories/Bimodal/Boneyard/Bundle/TemporalLindenbaum.lean`

**Verification:**
- All 8 files exist in new location
- None of the 8 files exist in old location
- `lake build` passes

**Progress:**

**Session: 2026-02-19, sess_1771527252_248861**
- Added: `Theories/Bimodal/Boneyard/Bundle/` directory
- Removed: 8 files from `Metalogic/Bundle/` via `git mv` to `Boneyard/Bundle/`
- Completed: Build passes (1000 jobs, 0 errors) after all moves

---

### Phase 3: Remove FALSE Axiom from Construction.lean [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Remove the FALSE axiom `singleFamily_modal_backward_axiom` and clean up related code

**Tasks:**
- [ ] Read Construction.lean to locate the FALSE axiom (around line 219)
- [ ] Remove the `singleFamily_modal_backward_axiom` declaration
- [ ] Update `singleFamilyBMCS` to use sorry for `modal_backward` field instead of FALSE axiom
- [ ] Add deprecation comment to `singleFamilyBMCS` noting it should not be used
- [ ] Run `lake build` to verify no breakage
- [ ] Check if any other code references `singleFamily_modal_backward_axiom`

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - remove axiom, update singleFamilyBMCS

**Verification:**
- Axiom declaration no longer exists in file
- `lake build` passes
- No references to axiom remain in codebase

**Progress:**

**Session: 2026-02-19, sess_1771527252_248861**
- Removed: `singleFamily_modal_backward_axiom` declaration from Construction.lean
- Refactored: `singleFamilyBMCS.modal_backward` to use sorry instead of FALSE axiom
- Refactored: Module documentation to reflect axiom removal and sorry status
- Refactored: `Metalogic/Metalogic.lean` sorry table to reflect change
- Axioms: 1 -> 0 (FALSE axiom removed from Construction.lean)
- Sorries: 0 -> 1 (modal_backward now sorry instead of FALSE axiom)
- Completed: Build passes (1000 jobs, 0 errors)

---

### Phase 4: Final Verification and Cleanup [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Verify all changes are correct and repository is clean

**Tasks:**
- [ ] Run full `lake build` to confirm clean build
- [ ] Count sorries in active Theories/ (should be ~100 less)
- [ ] Count axioms in active Theories/ (should be 1 less from FALSE removal)
- [ ] Verify Metalogic.lean aggregator still compiles (no orphan imports)
- [ ] Verify Boneyard files are excluded from main build

**Timing:** 15 minutes

**Verification:**
- Build passes with 0 errors
- Sorry count reduced from active codebase
- Axiom count reduced by 1 (FALSE axiom removed)
- All critical path files unchanged except Construction.lean

**Progress:**

**Session: 2026-02-19, sess_1771527252_248861**
- Completed: Full build verification (1000 jobs, 0 errors)
- Completed: Active sorry count = 116 (excluding Boneyard/Examples)
- Completed: Active axiom count = 2 (both mathematically correct)
- Completed: Metalogic.lean and Metalogic/Metalogic.lean aggregators compile cleanly
- Completed: All 8 Boneyard/Bundle/ files are excluded from main build

---

## Testing & Validation

- [ ] `lake build` passes after Phase 1 (baseline)
- [ ] `lake build` passes after Phase 2 (file moves)
- [ ] `lake build` passes after Phase 3 (axiom removal)
- [ ] No imports of moved files in active codebase
- [ ] No references to removed axiom in codebase
- [ ] Boneyard files compile independently (optional)

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Bundle/` - directory containing 8 moved files
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - modified to remove FALSE axiom
- `specs/905_cleanup_metalogic_for_task_903/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If unexpected build breaks occur:
1. Use `git checkout` to restore moved files to original locations
2. Use `git checkout` to restore Construction.lean
3. Investigate which import dependency was missed
4. Update research report with findings
5. Re-attempt with corrected dependency analysis

If FALSE axiom removal causes cascade failures:
1. Restore Construction.lean from git
2. Document which theorems depend on the axiom
3. Create follow-up task to address the dependency chain before removal

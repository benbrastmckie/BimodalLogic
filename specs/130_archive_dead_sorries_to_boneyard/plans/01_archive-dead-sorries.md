# Implementation Plan: Archive Dead Sorries to Boneyard

- **Task**: 130 - Archive dead sorries to Boneyard
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_sorry-inventory.md, reports/02_archive-vs-delete.md
- **Artifacts**: plans/01_archive-dead-sorries.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove 15 dead-code sorries from the active codebase by deleting trivial stubs (5 sorries), archiving whole files to Boneyard (6 sorries across 2 files), surgically extracting sorry-bearing definitions from a mixed-content file (4 sorries), and annotating 4 convergence sorries that live inside structurally active definitions. Each step is followed by a `lake build` to verify compilation. The net effect is 15 sorries removed from the active codebase and 4 annotated as dead-approach code.

### Research Integration

Two research reports inform this plan:
- **01_sorry-inventory.md**: Full inventory of 73 active sorries, classifying 19 as actionable (15 archive/delete, 4 annotate) and 54 as active code that must not be touched.
- **02_archive-vs-delete.md**: Per-item ARCHIVE vs DELETE classification with import dependency analysis, Boneyard subdirectory layout, tombstone templates, and risk assessment. The build verification order (delete first, then archive whole files, then surgical extractions, then annotations) comes directly from this report.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Remove 15 dead-code sorries from the active codebase (10 archived, 5 deleted)
- Annotate 4 convergence sorries with dead-approach markers
- Maintain full build integrity after each modification step
- Create properly documented Boneyard subdirectories with READMEs
- Update Boneyard/README.md inventory table

**Non-Goals**:
- Resolving the 4 annotated convergence sorries (that is task 129/Reynolds pipeline work)
- Archiving any active-code sorries (Bundle, WeakCanonical, Algebraic, TemporalDerived)
- Refactoring the BXCanonical pipeline beyond removing dead code
- Archiving DefectChain.lean (sorry-free, low priority per research -- defer unless trivial)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Transitive import breakage when removing RootScopedChain import from Completeness.lean | H | M | `lake build` after removal; add explicit imports for any transitively-needed modules |
| SigmaOrdering removal breaks DefectChain.lean compilation | M | L | Research confirms DefectChain does not reference SigmaOrdering definitions; verify with build |
| Surgical extraction from Realization.lean accidentally removes proved code | H | L | Carefully identify sorry-bearing definitions only; leave all proved code in place; verify with build |
| CanonicalChain.lean import of DefectChain breaks if DefectChain's SigmaOrdering import is updated | M | M | Update DefectChain to import Frame.lean directly; verify CanonicalChain still compiles |
| Large file edit in ChronicleToCountermodel.lean introduces syntax errors | M | L | Annotations are comment-only changes; verify with build |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are strictly sequential because each phase modifies shared compilation state and requires a successful `lake build` before the next phase can proceed safely.

---

### Phase 1: Delete Trivial Stubs [COMPLETED]

**Goal**: Remove 5 sorry stubs from 3 files (Construction.lean, TruthLemma.lean, ChronicleToCountermodel.lean) and verify the build.

**Tasks**:
- [x] Delete `refl_intro_until_mcs` and `refl_intro_since_mcs` stubs from `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (lines ~147-186, 2 sorries)
- [x] Delete `until_backward_refl_mcs` and `since_backward_refl_mcs` stubs from `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` (lines ~292-320, 2 sorries)
- [x] Delete `dd_countermodel_chronicle_nondense_sorry` stub from `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (lines ~831-839, 1 sorry). Preserve the nearby doc comment about the discrete case pipeline (lines 841+)
- [x] Run `lake build` and verify zero new errors

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` - Remove 2 sorry stubs
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` - Remove 2 sorry stubs
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Remove 1 sorry stub

**Verification**:
- `lake build` succeeds with no new errors
- `grep -rn "sorry" Construction.lean` shows 2 fewer sorry occurrences
- `grep -rn "sorry" TruthLemma.lean` shows 2 fewer sorry occurrences

---

### Phase 2: Archive RootScopedChain.lean (Whole File) [COMPLETED]

**Goal**: Move `RootScopedChain.lean` (222 lines, 3 sorries) to `Boneyard/ScheduleBasedBFMCS/` and update imports in `Completeness.lean`.

**Tasks**:
- [x] Create directory `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/`
- [x] Move `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` to `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean`
- [x] Remove `import Bimodal.Metalogic.BXCanonical.RootScopedChain` from `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`
- [x] Add tombstone comment in Completeness.lean at the removed import location:
  ```
  -- Archived to Boneyard/ScheduleBasedBFMCS/ (task 130): schedule-based BFMCS
  -- construction. 3 sorry sites (restricted_tc/buc/fuc) bypassed by Chronicle
  -- approach. See Boneyard/ScheduleBasedBFMCS/README.md.
  ```
- [x] Create `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/README.md` following the template from research report section "Proposed Boneyard Subdirectory Organization"
- [x] Run `lake build` and verify zero new errors. If transitive import issues arise, add explicit imports for transitively-needed modules. *(deviation: altered -- also removed `#print axioms dd_countermodel` since dd_countermodel was defined in RootScopedChain.lean)*

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Move to Boneyard
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Remove import, add tombstone
- `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean` - New (moved file)
- `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/README.md` - New

**Verification**:
- `lake build` succeeds with no new errors
- `RootScopedChain.lean` no longer exists at original path
- `RootScopedChain.lean` exists at Boneyard path
- Completeness.lean does not import RootScopedChain

---

### Phase 3: Archive SigmaOrdering.lean (Whole File) and Update Imports [COMPLETED]

**Goal**: Move `SigmaOrdering.lean` (167 lines, 3 sorries) to `Boneyard/FiltrationOrdering/` and fix the import chain in `DefectChain.lean`.

**Tasks**:
- [x] Create directory `Theories/Bimodal/Boneyard/FiltrationOrdering/`
- [x] Move `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean` to `Theories/Bimodal/Boneyard/FiltrationOrdering/SigmaOrdering.lean`
- [x] Update `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` to replace the SigmaOrdering import with direct imports of Frame.lean and/or Construction.lean (whatever SigmaOrdering was providing transitively)
- [x] Verify CanonicalChain.lean still compiles (it imports DefectChain.lean)
- [x] Create `Theories/Bimodal/Boneyard/FiltrationOrdering/README.md` following the template from research report
- [x] Run `lake build` and verify zero new errors

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean` - Move to Boneyard
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` - Update imports
- `Theories/Bimodal/Boneyard/FiltrationOrdering/SigmaOrdering.lean` - New (moved file)
- `Theories/Bimodal/Boneyard/FiltrationOrdering/README.md` - New

**Verification**:
- `lake build` succeeds with no new errors
- SigmaOrdering.lean no longer exists at original path
- DefectChain.lean compiles without SigmaOrdering import
- CanonicalChain.lean compiles without changes

---

### Phase 4: Surgical Extraction from Realization.lean and Annotations [COMPLETED]

**Goal**: Extract 4 sorry-bearing definitions from `Realization.lean` to Boneyard, and annotate 4 convergence sorries in `ChronicleToCountermodel.lean` with dead-approach markers.

**Tasks**:
- [x] Create directory `Theories/Bimodal/Boneyard/BX1DependentCode/`
- [x] Read `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` carefully to identify exact boundaries of: `F_of_mem` (~line 66), `P_of_mem` (~line 72), and the sorry-bearing branches within `enriched_seed_consistent_until` (~line 196) and `enriched_seed_consistent_since` (~line 248)
- [x] Create `Theories/Bimodal/Boneyard/BX1DependentCode/RealizationSorries.lean` with the extracted sorry-bearing definitions (as documentation, not as compilable Lean -- use comment blocks or `sorry`-marked stubs)
- [x] Remove or comment out `F_of_mem` and `P_of_mem` from Realization.lean; replace the sorry-bearing inner branches of `enriched_seed_consistent_until/since` with simplified sorry-only stubs *(deviation: altered -- removed entire enriched_seed_consistent_until/since definitions since they were unreferenced)*
- [x] Add tombstone comments in Realization.lean:
  ```
  -- F_of_mem, P_of_mem: archived to Boneyard/BX1DependentCode/ (task 130).
  -- These required BX1 (G(phi)->phi), removed under irreflexive semantics (task 113).
  ```
- [x] Create `Theories/Bimodal/Boneyard/BX1DependentCode/README.md` following the template from research report
- [x] Run `lake build` and verify zero new errors
- [x] Add dead-approach annotations to 4 convergence sorries in `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`:
  - `succ_reaches_dom_N` boundary case above max(dom(N)) (~line 1282)
  - `succ_reaches_dom_N` boundary case below min(dom(N)) (~line 1435)
  - `limit_dom_points_are_succ_iterates` (~line 1499)
  - `succ_cofinal` gap elimination (~line 1873)
- [x] Use annotation template:
  ```
  -- DEAD APPROACH: convergence/stage-induction method for succ_reaches_dom_N.
  -- Resolution: task 129 (Henkin model) or Reynolds pipeline (tasks 154-155).
  -- See Boneyard/StageInductionGapAnalysis/ for related archived analysis.
  ```
- [x] Run `lake build` and verify annotations (comment-only) do not break compilation

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` - Remove sorry-bearing definitions, add tombstones
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Add dead-approach annotations to 4 sorry sites
- `Theories/Bimodal/Boneyard/BX1DependentCode/RealizationSorries.lean` - New (extracted code)
- `Theories/Bimodal/Boneyard/BX1DependentCode/README.md` - New

**Verification**:
- `lake build` succeeds with no new errors after Realization.lean extraction
- `lake build` succeeds with no new errors after ChronicleToCountermodel.lean annotations
- `grep -c "sorry" Realization.lean` shows 4 fewer sorries than before
- All 4 convergence sorry sites have `DEAD APPROACH` annotation comments

---

### Phase 5: Update Boneyard Inventory and Final Verification [COMPLETED]

**Goal**: Update the Boneyard README inventory table with 3 new entries, and run a final full build verification with sorry count comparison.

**Tasks**:
- [x] Read `Theories/Bimodal/Boneyard/README.md` to understand the existing inventory table format
- [x] Add 3 new rows to the inventory table:
  - `ScheduleBasedBFMCS` -- Task 130, schedule-based BFMCS chain (3 sorries archived)
  - `FiltrationOrdering` -- Task 130, sigma-restricted ordering for filtration (3 sorries archived)
  - `BX1DependentCode` -- Task 130, BX1-dependent helpers from Realization.lean (4 sorries archived)
- [x] Run final `lake build` to confirm complete project compiles cleanly
- [x] Count total active sorries (non-Boneyard) with grep: 40 remaining (baseline was 72, but concurrent tasks 173 and 21 also removed sorries; task 130 specifically removed 15)
- [x] Verify all 3 new Boneyard subdirectories have README.md files

**Timing**: 30 minutes

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Boneyard/README.md` - Add 3 new inventory rows

**Verification**:
- `lake build` succeeds with no errors
- Boneyard/README.md contains entries for ScheduleBasedBFMCS, FiltrationOrdering, BX1DependentCode
- Active sorry count decreased by 15 compared to baseline
- All 3 new Boneyard subdirectories contain README.md

## Testing & Validation

- [ ] `lake build` succeeds after each phase (5 successful builds total)
- [ ] No new errors or warnings introduced
- [ ] 15 sorries removed from active codebase (10 archived + 5 deleted)
- [ ] 4 convergence sorries annotated with dead-approach markers
- [ ] All downstream imports (Completeness.lean, CanonicalChain.lean, LocusControl.lean) still resolve
- [ ] Boneyard subdirectories have README.md documenting archival reason, sorry summary, and task cross-references
- [ ] No active-code definitions accidentally removed (Realization.lean proved code intact)

## Artifacts & Outputs

- `plans/01_archive-dead-sorries.md` (this file)
- `summaries/01_archive-dead-sorries-summary.md` (post-implementation)
- `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean` + README.md
- `Theories/Bimodal/Boneyard/FiltrationOrdering/SigmaOrdering.lean` + README.md
- `Theories/Bimodal/Boneyard/BX1DependentCode/RealizationSorries.lean` + README.md

## Rollback/Contingency

Each phase is committed separately. If a `lake build` fails after any phase:
1. Use `git diff` to review the changes that caused the failure
2. If the failure is a transitive import issue, add explicit imports and retry
3. If the failure is more fundamental, `git checkout -- <modified-files>` to restore the pre-phase state
4. The strictly sequential phase ordering ensures earlier phases are verified and committed before later phases begin

For full rollback of all phases: `git log` to find the pre-task commit hash and `git revert` the task commits in reverse order.

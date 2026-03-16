# Implementation Plan: Task #929 - Prepare Metalogic for Publication

- **Task**: 929 - prepare_metalogic_for_publication
- **Status**: [IMPLEMENTING]
- **Effort**: 10-13 hours
- **Dependencies**: None
- **Research Inputs**: specs/929_prepare_metalogic_for_publication/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Systematic preparation of the bimodal temporal logic metalogic for publication. The publication path (StagedConstruction + essential Bundle files) is confirmed sorry-free with zero custom axioms. This plan addresses task abandonment, file archival, import refactoring, documentation updates, and build hygiene to achieve a publication-ready state.

### Research Integration

Research report `research-001.md` integrated findings from a 3-teammate team:
- **Teammate A**: Sorry/axiom audit confirming 0 sorries on publication path
- **Teammate B**: Documentation/API assessment, export file gaps identified
- **Teammate C**: Archival analysis with import dependency blocking findings

Key findings driving this plan:
1. DovetailingChain.lean is safe for immediate archival (no importers)
2. Construction.lean and TemporalCoherentConstruction.lean require import refactoring before archival
3. Metalogic.lean exports are outdated and need StagedConstruction imports
4. 26+ build warnings (deprecated Mathlib API, unused variables)
5. 6 tasks identified for abandonment: 865, 881, 916, 917, 922, 930

## Goals & Non-Goals

**Goals**:
- Abandon 6 obsolete/blocked tasks with proper documentation
- Archive deprecated files (DovetailingChain, Construction, TemporalCoherentConstruction)
- Update Metalogic.lean export files to reflect current publication path
- Eliminate deprecated Mathlib API warnings
- Create Boneyard documentation
- Document sorry registry for transparency
- Achieve clean `lake build` with minimal warnings

**Non-Goals**:
- Resolve sorries in discrete-only path (DiscreteTimeline.lean)
- Resolve sorries in research path (ConstructiveFragment.lean)
- Refactor publication-path code (already clean)
- Update Mathlib dependency version

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import refactoring breaks build | High | Medium | Verify `lake build` after each archival; keep archived files accessible |
| TemporalCoherentFamily extraction complex | Medium | Medium | Audit imports first; may need minimal extraction |
| Deprecated API fix introduces bugs | Medium | Low | Test each fix independently; verify theorem statements unchanged |
| Task abandonment misses active work | Low | Low | Cross-check TODO.md and state.json before abandonment |

## Sorry Characterization

### Pre-existing Sorries

Publication path: **0 sorries** (confirmed by research)

Non-publication path sorries (not in scope for this task):
- 5 sorries in DovetailingChain.lean (to be archived)
- 13 sorries in TemporalCoherentConstruction.lean (to be archived)
- 14 sorries in DiscreteTimeline.lean (discrete case only)
- 3 sorries in ConstructiveFragment.lean (research path)

### Expected Resolution

This task does NOT resolve sorries - it documents and archives them appropriately.

### New Sorries

None. This task introduces no new code requiring sorries.

### Remaining Debt

After this implementation:
- 0 sorries on publication path (unchanged)
- ~32 sorries in archived/non-publication files (documented in sorry registry)

## Implementation Phases

### Phase 0: Task Abandonment [COMPLETED]

- **Dependencies:** None
- **Goal**: Abandon 6 obsolete/blocked tasks with proper state updates

**Tasks**:
- [ ] Read current state.json to verify task statuses
- [ ] Abandon Task 865 (canonical_task_frame) - superseded by ChainBundleBMCS
- [ ] Abandon Task 881 (modally_saturated_bmcs_construction) - stepping stone, no longer needed
- [ ] Abandon Task 916 (fp_witness_obligation_tracking) - irreducible F-persistence gap
- [ ] Abandon Task 917 (fix_forward_f_backward_p) - moot if 916 abandoned
- [ ] Abandon Task 922 (strategy_study_fp_witness) - moot if 916 abandoned
- [ ] Abandon Task 930 (verify_mcs_membership) - target definitions in Boneyard
- [ ] Update state.json for each task: status = "abandoned", add abandonment_reason
- [ ] Update TODO.md to reflect [ABANDONED] status for all 6 tasks
- [ ] Git commit: `task 929 phase 0: abandon 6 obsolete tasks`

**Timing**: 1 hour

**Files to modify**:
- `specs/state.json` - Update 6 task statuses
- `specs/TODO.md` - Update 6 task markers

**Verification**:
- [ ] All 6 tasks show [ABANDONED] in TODO.md
- [ ] All 6 tasks have status "abandoned" in state.json
- [ ] Each abandoned task has abandonment_reason field

---

### Phase 1: Immediate Archival (DovetailingChain) [COMPLETED]

- **Dependencies:** None
- **Goal**: Archive DovetailingChain.lean which has no active importers

**Tasks**:
- [ ] Verify no files import DovetailingChain.lean: `grep -rn "import.*DovetailingChain" Theories/`
- [ ] Create target directory: `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/`
- [ ] Move DovetailingChain.lean to Boneyard
- [ ] Update any lakefile.lean if needed
- [ ] Run `lake build` to verify no breakage
- [ ] Git commit: `task 929 phase 1: archive DovetailingChain.lean`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Move to Boneyard
- `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean` - New location

**Verification**:
- [ ] `lake build` passes
- [ ] DovetailingChain.lean no longer in Metalogic/Bundle/
- [ ] DovetailingChain.lean exists in Boneyard/Metalogic_v8/Bundle/

---

### Phase 2: Import Refactoring [COMPLETED]

- **Dependencies:** Phase 1
- **Goal**: Refactor imports to allow archiving Construction.lean and TemporalCoherentConstruction.lean

**Tasks**:
- [ ] Audit WitnessSeedWrapper.lean imports from Construction.lean
  - Determine minimal needed API
  - Document which definitions/lemmas are actually used
- [ ] Audit publication-path imports from TemporalCoherentConstruction.lean:
  - StagedExecution.lean
  - CanonicalConstruction.lean
  - TruthLemma.lean
  - CanonicalFMCS.lean
- [ ] Create minimal bridge module `Bundle/TemporalCoherentDefs.lean`:
  - Extract only definitions needed by publication-path files
  - Ensure no sorries in extracted code
- [ ] Update importers to use new bridge module
- [ ] Run `lake build` to verify
- [ ] Archive TemporalCoherentConstruction.lean to Boneyard
- [ ] Run `lake build` to verify
- [ ] Audit if Construction.lean has remaining importers
- [ ] Archive Construction.lean to Boneyard (if safe)
- [ ] Run `lake build` to verify
- [ ] Git commit: `task 929 phase 2: refactor imports, archive deprecated files`

**Timing**: 2-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentDefs.lean` - New bridge module
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` - Update imports
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - Update imports
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Update imports
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - Update imports
- `Theories/Bimodal/Metalogic/TemporalCoherentConstruction.lean` - Move to Boneyard
- `Theories/Bimodal/Metalogic/Construction.lean` - Move to Boneyard (if safe)

**Verification**:
- [ ] `lake build` passes after each change
- [ ] No publication-path file imports deprecated files
- [ ] Bridge module contains no sorries: `grep -n "\bsorry\b" TemporalCoherentDefs.lean` returns empty

---

### Phase 3: Boneyard Documentation [COMPLETED]

- **Dependencies:** Phase 2
- **Goal**: Create Boneyard READMEs documenting archived code

**Tasks**:
- [ ] Create `Boneyard/README.md` with overall archive structure description:
  - Purpose of Boneyard (deprecated code preservation)
  - Directory structure explanation
  - How to restore archived code if needed
- [ ] Create `Theories/Bimodal/Boneyard/README.md`:
  - Pointer to subdirectory READMEs
  - Overview of what's archived
- [ ] Update `Boneyard/Metalogic/README.md` (or create if missing):
  - Document newly archived files (DovetailingChain, TemporalCoherentConstruction, Construction)
  - Note F/P witness gap as reason for DovetailingChain archival
  - Note replaced-by-StagedConstruction as reason for others
- [ ] Git commit: `task 929 phase 3: create Boneyard documentation`

**Timing**: 1 hour

**Files to modify**:
- `Boneyard/README.md` - Create or update
- `Theories/Bimodal/Boneyard/README.md` - Create or update
- `Theories/Bimodal/Boneyard/Metalogic/README.md` - Update with new archives

**Verification**:
- [ ] All three README files exist and are non-empty
- [ ] README files explain why code was archived

---

### Phase 4: Export File Updates [IN PROGRESS]

- **Dependencies:** Phase 2
- **Goal**: Update Metalogic.lean export files to reflect current publication path

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic.lean` (root):
  - Add import: `Bimodal.Metalogic.StagedConstruction.Completeness`
  - Add import: `Bimodal.Metalogic.Bundle.TruthLemma`
  - Add import: `Bimodal.Metalogic.Bundle.CanonicalConstruction`
  - Update status table: "Completeness: COMPLETE"
  - Document key theorems:
    - `dense_completeness_components_proven`
    - `cantor_iso`
    - `bmcs_truth_lemma`
    - `shifted_truth_lemma`
  - Document axiom dependencies: propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean`:
  - Remove outdated sorry counts
  - Add StagedConstruction to module structure
  - Remove references to archived files (Representation.lean if present)
  - Add publication-path status table
- [ ] Run `lake build` to verify
- [ ] Git commit: `task 929 phase 4: update Metalogic.lean exports`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - Root export file
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Module documentation

**Verification**:
- [ ] `lake build` passes
- [ ] Root Metalogic.lean imports StagedConstruction modules
- [ ] Status table shows "Completeness: COMPLETE"

---

### Phase 5: Build Hygiene [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal**: Fix deprecated Mathlib API calls and reduce build warnings

**Tasks**:
- [ ] Fix deprecated `le_or_lt` -> `le_or_gt` in SoundnessLemmas.lean
- [ ] Fix deprecated `le_or_lt` -> `le_or_gt` in Soundness.lean
- [ ] Address unused variable warnings:
  - Add `_` prefix to intentionally unused variables in Validity.lean
  - Add `_` prefix to intentionally unused variables in Soundness.lean
- [ ] Address unused simp argument warnings (6+ locations)
- [ ] Address unused tactic warnings in ProofSearch.lean
- [ ] Run `lake build` and count remaining warnings
- [ ] Git commit: `task 929 phase 5: fix deprecated API, reduce warnings`

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Fix deprecated API
- `Theories/Bimodal/Metalogic/Soundness.lean` - Fix deprecated API, unused vars
- `Theories/Bimodal/Validity.lean` - Fix unused variables
- `Theories/Bimodal/ProofSearch.lean` - Fix unused tactics

**Verification**:
- [ ] `lake build` passes
- [ ] Deprecated API warnings eliminated
- [ ] Warning count significantly reduced

---

### Phase 6: Sorry Documentation [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal**: Create comprehensive sorry registry documenting all active sorries

**Tasks**:
- [ ] Create sorry registry table in `specs/929_prepare_metalogic_for_publication/sorry-registry.md`:
  - Columns: File, Line, Category (deprecated/discrete/research), Publication Impact
  - Clearly separate "on publication path" (0) vs "off publication path" (~35)
- [ ] Count sorries by file:
  - DovetailingChain.lean (archived): 5
  - TemporalCoherentConstruction.lean (archived): 13
  - DiscreteTimeline.lean: 14
  - ConstructiveFragment.lean: 3
  - CanonicalFMCS.lean: verify count (7 per research-008)
- [ ] Update TODO.md frontmatter `sorry_count` to reflect current accurate count
- [ ] Git commit: `task 929 phase 6: create sorry registry`

**Timing**: 1 hour

**Files to modify**:
- `specs/929_prepare_metalogic_for_publication/sorry-registry.md` - New file
- `specs/TODO.md` - Update sorry_count frontmatter

**Verification**:
- [ ] Sorry registry exists and is comprehensive
- [ ] Publication path section shows 0 sorries
- [ ] TODO.md sorry_count matches actual count

---

### Phase 7: Minor Comment Improvements [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal**: Add clarifying comments to complex proofs in publication path

**Tasks**:
- [ ] Add proof strategy comment to `DenseTimeline.lean:denseStage_all_comparable_with_root`:
  - Long induction currently lacks high-level explanation
  - Document induction strategy and key cases
- [ ] Add high-level explanation to `CantorPrereqs.lean:encoding_sufficiency`:
  - Complex proof needs overview comment
  - Explain the encoding approach
- [ ] Add inline comments to `DensityFrameCondition.lean:caseB_G_neg_not_in_M`:
  - Technical proof benefits from step-by-step comments
  - Explain case analysis structure
- [ ] Run `lake build` to verify comments don't break anything
- [ ] Git commit: `task 929 phase 7: add documentation comments`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` - Add proof comments
- `Theories/Bimodal/Metalogic/CantorPrereqs.lean` - Add explanation
- `Theories/Bimodal/Metalogic/DensityFrameCondition.lean` - Add inline comments

**Verification**:
- [ ] `lake build` passes
- [ ] Comments are present and helpful

---

### Phase 8: Final Verification [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal**: Comprehensive verification that publication path is clean

**Tasks**:
- [ ] Clean build from scratch: `lake clean && lake build`
- [ ] Verify zero sorries on publication path:
  - `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` - expect 0
  - `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/*.lean | grep -v Boneyard` - expect 0
- [ ] Verify zero custom axioms:
  - `grep -rn "^axiom " Theories/Bimodal/Metalogic/ | grep -v Boneyard` - expect 0
- [ ] Verify standard axiom dependencies only:
  - `#print axioms dense_completeness_components_proven` - expect only standard axioms
  - `#print axioms cantor_iso` - expect only standard axioms
  - `#print axioms bmcs_truth_lemma` - expect only standard axioms
- [ ] Count final warning count
- [ ] Update task status to [COMPLETED] in state.json and TODO.md
- [ ] Create implementation summary
- [ ] Git commit: `task 929: complete implementation (publication preparation)`

**Timing**: 30 minutes

**Files to modify**:
- `specs/state.json` - Task status to completed
- `specs/TODO.md` - Task status to [COMPLETED]
- `specs/929_prepare_metalogic_for_publication/summaries/implementation-summary-YYYYMMDD.md` - Create

**Verification**:
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` returns empty
- [ ] `grep -rn "^axiom " Theories/Bimodal/Metalogic/ | grep -v Boneyard` returns empty
- [ ] `#print axioms` shows only: propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors after each phase
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` returns empty (zero sorries on dense path)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/*.lean` shows no custom axioms
- [ ] Bridge module (TemporalCoherentDefs.lean) contains no sorries

### General
- [ ] All 6 tasks properly abandoned with state updates
- [ ] All archived files moved to correct Boneyard locations
- [ ] Boneyard READMEs explain archival reasons
- [ ] Export files updated with correct imports and status

## Artifacts & Outputs

- `specs/929_prepare_metalogic_for_publication/plans/implementation-001.md` (this file)
- `specs/929_prepare_metalogic_for_publication/sorry-registry.md` (Phase 6)
- `specs/929_prepare_metalogic_for_publication/summaries/implementation-summary-YYYYMMDD.md` (Phase 8)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentDefs.lean` (Phase 2)
- `Boneyard/README.md` (Phase 3)
- `Theories/Bimodal/Boneyard/README.md` (Phase 3)

## Rollback/Contingency

If import refactoring (Phase 2) breaks the build:
1. Restore archived files from git history: `git checkout HEAD~1 -- Theories/Bimodal/Metalogic/TemporalCoherentConstruction.lean`
2. Keep files in place with TODO comment noting they are deprecated
3. Document the dependency issue in Boneyard README
4. Proceed with other phases

If deprecated API fixes introduce bugs:
1. Revert specific fix: `git checkout HEAD~1 -- <file>`
2. Add comment noting deprecated API will need future attention
3. Proceed with other phases

If TemporalCoherentFamily extraction is too complex:
1. Keep TemporalCoherentConstruction.lean in place (not archived)
2. Add prominent comment marking it as deprecated
3. Document in sorry registry that this file will be archived in future

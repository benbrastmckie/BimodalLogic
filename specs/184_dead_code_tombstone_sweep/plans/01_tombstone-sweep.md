# Implementation Plan: Task #184

- **Task**: 184 - Dead Code Tombstone Sweep
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: Must not touch any WeakCanonical/ files (task 155 active)
- **Research Inputs**: specs/184_dead_code_tombstone_sweep/reports/01_tombstone-catalog.md
- **Artifacts**: plans/01_tombstone-sweep.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove approximately 120-140 lines of dead code artifacts across 12 Lean source files. Targets include tombstone comments (class-b multi-line blocks and class-c removal lists), stale #check statements, dead tactic definitions, and noise lines in Completeness.lean. All changes are comment/dead-code removal with no logic modifications; each phase is verified by a successful `lake build`. All WeakCanonical/ files are excluded to avoid conflict with task 155.

### Research Integration

The research report (01_tombstone-catalog.md) cataloged 43 tombstone targets across 12 files, classified each into keep/remove verdicts, and proposed 6 implementation batches ordered by risk. This plan consolidates those 6 batches into 4 phases, grouping low-risk single-line removals together and separating the higher-risk dead tactic removal into its own phase.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Remove all class-c tombstone comments (25 blocks listing removed declarations)
- Remove all class-b tombstone comments (6 multi-line explanation blocks)
- Remove 12 class-a single-line notes marked as noise by the research report
- Remove 6 #check statements from Tactics.lean and FrameClass.lean
- Delete 2 dead tactic definitions (temp_4_tactic, temp_a_tactic, ~80 lines)
- Remove 6 noise lines from Completeness.lean
- Verify clean `lake build` after each phase

**Non-Goals**:
- Touching any file under WeakCanonical/ (task 155 exclusion zone)
- Removing the 13 class-a tombstone comments marked KEEP (they are informative docstring content)
- Removing the 13 #check statements inside doc comment code blocks (they are pedagogical)
- Refactoring or restructuring any Lean proofs or definitions
- Addressing any sorry stubs or proof obligations

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidental removal of a KEEP comment that is part of a doc section | L | L | Cross-reference line numbers with research catalog; verify doc formatting after removal |
| Dead tactic removal breaks a downstream caller | M | L | grep for `temp_4_tactic` and `temp_a_tactic` across Theories/ before deleting; build verifies |
| Line number drift from earlier deletions invalidates later targets | M | M | Work top-to-bottom within each file; re-confirm line content before deleting |
| Conflict with task 155 changes | H | L | Strict exclusion of all WeakCanonical/ files |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Soundness and SoundnessLemmas Cleanup [COMPLETED]

**Goal**: Remove all tombstone comments from Soundness.lean and SoundnessLemmas.lean -- the two files with the highest concentration of removal targets.

**Tasks**:
- [ ] Soundness.lean: Remove lines 259-260 (temp_future_valid note)
- [ ] Soundness.lean: Remove lines 686-693 (8-line BX7a/BX8/BX9 removal block)
- [ ] Soundness.lean: Remove lines 808-820 (13-line Legacy Discrete Axiom section)
- [ ] Soundness.lean: Remove lines 872-873 (linear_until_a7a / until_elim notes)
- [ ] Soundness.lean: Remove line 921 (until_elim/since_elim note -- repeated in 4 match blocks)
- [ ] Soundness.lean: Remove line 970 (same repeated note)
- [ ] Soundness.lean: Remove line 1073 (same repeated note)
- [ ] Soundness.lean: Remove line 1246 (same repeated note)
- [ ] SoundnessLemmas.lean: Remove lines 159-188 (30-line Unprovable Theorem explanation block)
- [ ] SoundnessLemmas.lean: Remove line 366 (swap_axiom_tf_valid note)
- [ ] Completeness.lean: Remove lines 364-367 (duplicate theorems list)
- [ ] Completeness.lean: Remove lines 525-526 (end-of-file removal notes)
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- remove ~30 lines of tombstone comments
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- remove ~31 lines of tombstone comments
- `Theories/Bimodal/Metalogic/Completeness.lean` -- remove 6 lines of removal-list noise

**Verification**:
- `lake build` succeeds with no new errors
- Remaining KEEP comments (Soundness.lean:855, SoundnessLemmas doc blocks) are intact

---

### Phase 2: BXCanonical Tombstone Cleanup [COMPLETED]

**Goal**: Remove all tombstone comments across the BXCanonical/ subdirectory files (Chronicle, Filtration, Quasimodel areas) and RestrictedMCS.lean.

**Tasks**:
- [ ] ChronicleTypes.lean: Remove lines 601-602 (rRelation removal listing)
- [ ] PointInsertion.lean: Remove line 179 (until_elim_mcs note)
- [ ] PointInsertion.lean: Remove lines 353-354 (lemma_2_7_guard listing)
- [ ] PointInsertion.lean: Remove lines 559-566 (8-line rRelation/lemma_2_6_full listing)
- [ ] PointInsertion.lean: Remove lines 1497-1502 (6-line Task 115 removal block)
- [ ] RRelation.lean: Remove lines 72-78 (4 INVALID-under-open-guard lines)
- [ ] RRelation.lean: Remove lines 107-108 (since_disjunction removal note)
- [ ] RRelation.lean: Remove lines 138-139 (rRelation_of_subset removal note)
- [ ] RRelation.lean: Remove lines 436-437 (r3Relation_of_superset removal note)
- [ ] RRelation.lean: Remove lines 1219-1228 (10-line untl_absorb/burgessR3 listing)
- [ ] CanonicalChain.lean: Remove line 14 (left_mono removal bullet in docstring)
- [ ] CanonicalChain.lean: Remove lines 40-41 (psi_imp_until note)
- [ ] Construction.lean: Remove lines 112-115 (until_elim_mcs note block)
- [ ] Construction.lean: Remove lines 146-147 (since_elim_mcs note)
- [ ] DefectChain.lean: Remove lines 64-66 (defect_step_phi note block)
- [ ] DefectChain.lean: Remove lines 100-101 (since_defect_step_phi note)
- [ ] Realization.lean: Remove lines 48-49 (F_of_mem archive note)
- [ ] Realization.lean: Remove lines 149-150 (g_content/h_content note)
- [ ] RestrictedMCS.lean: Remove lines 1364-1368 (neg_FF_implies removal rationale)
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- remove 2 lines
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- remove ~16 lines
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- remove ~21 lines
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- remove ~3 lines
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` -- remove ~6 lines
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` -- remove ~5 lines
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- remove ~4 lines
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` -- remove 5 lines

**Verification**:
- `lake build` succeeds with no new errors
- All KEEP comments (docstrings, design notes) remain intact
- No WeakCanonical/ files touched

---

### Phase 3: #check Statements and Completeness Verification [NOT STARTED]

**Goal**: Remove the 6 non-pedagogical #check statements from Tactics.lean and FrameClass.lean, and verify all Phase 1 removals integrated cleanly.

**Tasks**:
- [ ] Tactics.lean: Remove lines 1378-1380 (3 #check statements in test section)
- [ ] FrameClass.lean: Remove lines 198-203 (section header + 3 #check statements for typeclass verification)
- [ ] Run `lake build` to verify

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics.lean` -- remove 3 #check lines
- `Theories/Bimodal/FrameConditions/FrameClass.lean` -- remove ~6 lines (section header + 3 #check)

**Verification**:
- `lake build` succeeds
- Remaining #check statements in doc comment blocks (Decidability.lean, Semantics.lean, Bimodal.lean, Theorems.lean) are untouched

---

### Phase 4: Dead Tactic Removal [NOT STARTED]

**Goal**: Remove the two dead tactic definitions (temp_4_tactic and temp_a_tactic) that always throw errors, eliminating ~80 lines of unreachable code.

**Tasks**:
- [ ] grep -rn "temp_4_tactic\|temp_a_tactic" Theories/ to verify no downstream callers
- [ ] Tactics.lean: Remove the entire temp_4_tactic elab definition (~lines 474-515)
- [ ] Tactics.lean: Remove the entire temp_a_tactic elab definition (~lines 517-555)
- [ ] Run `lake build` to verify no breakage
- [ ] If callers found: update them to remove references before deleting definitions

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics.lean` -- remove ~80 lines (two dead tactic definitions)

**Verification**:
- grep confirms no remaining references to temp_4_tactic or temp_a_tactic
- `lake build` succeeds with no new errors

## Testing & Validation

- [ ] `lake build` succeeds after each phase with zero new errors or warnings
- [ ] grep -rn "temp_4_tactic\|temp_a_tactic" returns no results after Phase 4
- [ ] No WeakCanonical/ files appear in `git diff --name-only` at any point
- [ ] All 13 KEEP-marked tombstone comments remain intact (spot check)
- [ ] All 13 KEEP-marked #check statements in doc blocks remain intact (spot check)
- [ ] git diff --stat shows approximately 120-140 lines removed, 0 lines added

## Artifacts & Outputs

- `specs/184_dead_code_tombstone_sweep/plans/01_tombstone-sweep.md` (this plan)
- `specs/184_dead_code_tombstone_sweep/summaries/01_tombstone-sweep-summary.md` (after implementation)

## Rollback/Contingency

All changes are pure deletions of comments and dead code. If any phase causes a build failure, the specific removal that broke the build can be identified by undoing the most recent edit and rebuilding. Since each phase commits separately, `git revert` of a single commit cleanly undoes any phase. No data migrations or state changes are involved.

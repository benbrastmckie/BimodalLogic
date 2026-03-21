# Implementation Plan: Task #1007

- **Task**: 1007 - Archive satisfies_at Infrastructure to Boneyard
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/1007_archive_satisfies_at_infrastructure/reports/01_teardown-inventory.md
- **Artifacts**: plans/02_archive-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Archive the entire FlagBFMCS completeness pipeline (6 files, ~1830 lines) to the Boneyard. The `satisfies_at` relation is structurally incompatible with the official `truth_at` semantics: it lacks TaskFrame D, WorldHistory, convexity, and the task relation. The convexity sorry in FlagBFMCSRatBundle is provably false. Before archiving, extract 4-5 reusable lemmas (g/h_content_propagation, PartialOrder/LinearOrder instances) to canonical locations. Fix the single broken import in Metalogic.lean.

### Research Integration

The research report identified:
- 6 files to archive with zero external consumers
- 4-5 lemmas worth extracting before archival
- Single import fix required in Metalogic.lean
- Boneyard directory structure: `Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/`

## Goals & Non-Goals

**Goals**:
- Archive all 6 FlagBFMCS files to Boneyard
- Extract g_content_propagation and h_content_propagation to CanonicalFrame.lean
- Extract PartialOrder CanonicalMCS instance to order infrastructure
- Fix Metalogic.lean import
- Add deprecation README explaining why archived
- Achieve clean `lake build`

**Non-Goals**:
- Salvaging the satisfies_at approach (research proved it unbridgeable)
- Modifying the StagedConstruction completeness pipeline
- Extracting the LinearOrder ChainFMCSDomain instance (can be re-derived if needed)
- Extracting flag_embed (Cantor embedding) - low value, complex dependencies

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Extracted lemmas have hidden dependencies | M | L | Read source carefully, test build after each extraction |
| Metalogic.lean has other FlagBFMCS dependencies | H | L | grep for all FlagBFMCS references before archival |
| CanonicalFrame.lean already has similar lemmas | L | M | Check for duplicates before adding |
| Boneyard directory structure conflicts | L | L | Use research-recommended path structure |

## Implementation Phases

### Phase 1: Extract Reusable Lemmas [COMPLETED]

**Goal**: Extract g_content_propagation, h_content_propagation, and PartialOrder instances to canonical locations before archiving source files.

**Tasks**:
- [ ] Read FlagBFMCSTruthLemma.lean to locate g_content_propagation and h_content_propagation
- [ ] Read CanonicalFrame.lean to find appropriate insertion point (near canonical_forward_G)
- [ ] Copy g_content_propagation lemma with appropriate imports
- [ ] Copy h_content_propagation lemma
- [ ] Read FlagBFMCSRatBundle.lean to locate PartialOrder CanonicalMCS instance
- [ ] Identify or create appropriate location in MCS order infrastructure
- [ ] Copy PartialOrder instance
- [ ] Run `lake build` to verify extracted lemmas compile

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalFrame.lean` - add g/h_content_propagation
- `Theories/Bimodal/Metalogic/Canonical/CanonicalMCS.lean` (or similar) - add PartialOrder instance

**Verification**:
- `lake build` succeeds
- No duplicate definitions

---

### Phase 2: Create Boneyard Directory and Archive Files [COMPLETED]

**Goal**: Move all 6 FlagBFMCS files to the Boneyard with proper directory structure.

**Tasks**:
- [ ] Create Boneyard directory: `Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/`
- [ ] Move FlagBFMCS.lean to Boneyard
- [ ] Move FlagBFMCSTruthLemma.lean to Boneyard
- [ ] Move FlagBFMCSCompleteness.lean to Boneyard
- [ ] Move FlagBFMCSValidityBridge.lean to Boneyard
- [ ] Move FlagBFMCSIntBundle.lean to Boneyard
- [ ] Move FlagBFMCSRatBundle.lean to Boneyard

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean` -> `Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/FlagBFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` -> `Boneyard/.../FlagBFMCSTruthLemma.lean`
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean` -> `Boneyard/.../FlagBFMCSCompleteness.lean`
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean` -> `Boneyard/.../FlagBFMCSValidityBridge.lean`
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean` -> `Boneyard/.../FlagBFMCSIntBundle.lean`
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean` -> `Boneyard/.../FlagBFMCSRatBundle.lean`

**Verification**:
- All 6 files present in Boneyard directory
- No files remain in original Bundle/ location

---

### Phase 3: Fix Metalogic.lean Import [COMPLETED]

**Goal**: Remove the FlagBFMCSCompleteness import from Metalogic.lean and verify no other FlagBFMCS dependencies exist.

**Tasks**:
- [ ] Grep for all FlagBFMCS references in Theories/ (excluding archived files)
- [ ] Read Metalogic.lean to confirm line 5 import location
- [ ] Remove `import Bimodal.Metalogic.Bundle.FlagBFMCSCompleteness` from Metalogic.lean
- [ ] Run `lake build` to verify clean build

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - remove line 5 import

**Verification**:
- `lake build` succeeds with no errors
- grep confirms no remaining FlagBFMCS references in active Theories/

---

### Phase 4: Add Deprecation README [COMPLETED]

**Goal**: Document why the FlagBFMCS pipeline was archived for future reference.

**Tasks**:
- [ ] Create README.md in Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/
- [ ] Document the structural incompatibility with truth_at
- [ ] List extracted lemmas with new locations
- [ ] Note related tasks (1006, 997, 988)
- [ ] Add archive date

**Timing**: 15 minutes

**Files to create**:
- `Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/README.md`

**Verification**:
- README exists and is complete
- Contains all required sections

---

### Phase 5: Final Build Verification [COMPLETED]

**Goal**: Ensure clean build and complete archival.

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify sorry count unchanged or reduced (should not increase)
- [ ] Confirm no warnings about missing imports

**Timing**: 15 minutes

**Verification**:
- `lake build` completes with exit code 0
- No new sorries introduced
- All extracted lemmas accessible from their new locations

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Extracted g_content_propagation accessible from CanonicalFrame
- [ ] Extracted h_content_propagation accessible from CanonicalFrame
- [ ] PartialOrder CanonicalMCS instance works
- [ ] No FlagBFMCS imports remain in active Theories/
- [ ] Boneyard README documents all decisions

## Artifacts & Outputs

- `specs/1007_archive_satisfies_at_infrastructure/plans/02_archive-plan.md` (this file)
- `specs/1007_archive_satisfies_at_infrastructure/summaries/03_archive-summary.md` (post-implementation)
- `Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/README.md` (deprecation documentation)

## Rollback/Contingency

If implementation fails:
1. Git restore all moved files from their original locations
2. Remove any additions to CanonicalFrame.lean and MCS order infrastructure
3. Restore Metalogic.lean import line
4. Delete Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/ directory

Since this is a pure archival operation with lemma extraction, rollback is straightforward via git.

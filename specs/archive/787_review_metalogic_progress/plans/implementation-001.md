# Implementation Plan: Task #787

- **Task**: 787 - review_metalogic_progress
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: high
- **Dependencies**: None
- **Research Inputs**: specs/787_review_metalogic_progress/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan focuses on establishing a sorry-free core completeness result for TM bimodal logic by archiving deprecated code paths and fixing the single bridge gap in WeakCompleteness.lean. The research report confirms that `semantic_weak_completeness` is already fully proven in FMP/SemanticCanonicalModel.lean, so the work is primarily cleanup and one targeted fix.

### Research Integration

The research report (research-001.md) identified:
- 166 sorry occurrences across 19 files, but most are in deprecated/alternative approaches
- Core completeness (`semantic_weak_completeness`) is already proven
- Path 1 (Minimal) requires: 1 bridge sorry fix + archiving deprecated code
- `Completeness.lean` (39 sorries) should be archived to Boneyard/
- `FiniteCanonicalModel.lean` has deprecated sections that should be extracted/archived

## Goals & Non-Goals

**Goals**:
- Establish sorry-free core completeness theorem chain
- Archive deprecated `Completeness.lean` to Boneyard/Metalogic_v3/
- Fix the 1 bridge sorry in WeakCompleteness.lean (soundness lemma connection)
- Document the semantic approach as the canonical completeness path

**Non-Goals**:
- Completing the Representation/ alternative approach (superseded by semantic)
- Fixing all 166 sorries (most are in deprecated code)
- Extracting deprecated sections from FiniteCanonicalModel.lean (deferred to future work)
- Completing Decidability/Correctness.lean (Path 2 - separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Archive breaks imports | High | Medium | Check for `import Bimodal.Metalogic.Completeness` before archiving |
| WeakCompleteness fix is more complex than estimated | Medium | Low | Research report indicates it's a simple import/connection fix |
| Boneyard structure doesn't exist | Low | Low | Create Boneyard/Metalogic_v3/ if needed |
| Soundness lemma has additional dependencies | Medium | Low | Check Soundness.lean exports before connecting |

## Implementation Phases

### Phase 1: Assess Current State and Dependencies [NOT STARTED]

**Goal**: Verify the research findings and identify import dependencies before making changes.

**Tasks**:
- [ ] Check for imports of `Bimodal.Metalogic.Completeness` across the codebase
- [ ] Verify `semantic_weak_completeness` is indeed sorry-free in SemanticCanonicalModel.lean
- [ ] Examine WeakCompleteness.lean to understand the bridge sorry context
- [ ] Check if Boneyard/Metalogic_v3/ directory exists

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Check header for deprecation notes
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Locate the bridge sorry
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Verify completeness is proven
- `Theories/Bimodal/Metalogic/Soundness.lean` - Check soundness lemma availability

**Verification**:
- List of files importing Completeness.lean documented
- Location of bridge sorry in WeakCompleteness.lean identified
- Soundness lemma name and type confirmed

---

### Phase 2: Archive Deprecated Completeness.lean [NOT STARTED]

**Goal**: Move the deprecated Duration-based Completeness.lean to Boneyard to reduce confusion.

**Tasks**:
- [ ] Create Boneyard/Metalogic_v3/ directory if it doesn't exist
- [ ] Move Completeness.lean to Boneyard/Metalogic_v3/Completeness.lean
- [ ] Remove or update any imports of the archived file (if any exist)
- [ ] Add a README.md in Boneyard/Metalogic_v3/ explaining the archived code

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Move to Boneyard
- `Theories/Boneyard/Metalogic_v3/Completeness.lean` - Destination
- `Theories/Boneyard/Metalogic_v3/README.md` - Create with explanation
- Any files importing Completeness.lean - Remove imports

**Verification**:
- `lake build` completes without new errors from the move
- Completeness.lean no longer exists in Metalogic/
- Boneyard/Metalogic_v3/ contains the archived file with README

---

### Phase 3: Fix WeakCompleteness Bridge Sorry [NOT STARTED]

**Goal**: Connect the soundness lemma from Soundness.lean to WeakCompleteness.lean, eliminating the axiomatized bridge.

**Tasks**:
- [ ] Import Soundness.lean in WeakCompleteness.lean if not already imported
- [ ] Identify the exact sorry in WeakCompleteness.lean (soundness axiom)
- [ ] Replace the sorry/axiom with the actual soundness lemma from Soundness.lean
- [ ] Verify the proof compiles without sorry

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Fix the bridge

**Verification**:
- `lake build Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` passes
- No sorry in the soundness connection
- `#check weak_completeness` (or equivalent) shows no sorry in the theorem

---

### Phase 4: Verify Sorry-Free Core Path and Document [NOT STARTED]

**Goal**: Confirm the core completeness path is sorry-free and document the canonical approach.

**Tasks**:
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/` to verify zero sorries in FMP
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` to verify zero
- [ ] Update the module docstring in SemanticCanonicalModel.lean to indicate it is the canonical approach
- [ ] Add a section to Metalogic/README.md (if exists) or create one documenting the completeness result

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Update docstring
- `Theories/Bimodal/Metalogic/README.md` - Create or update with approach documentation

**Verification**:
- FMP directory has zero active sorries
- WeakCompleteness.lean has zero sorries
- Documentation clearly states semantic approach is canonical
- `lake build` passes with no regressions

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/` returns 0 matches
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` returns 0 matches
- [ ] Archived files in Boneyard/ do not break any imports
- [ ] `semantic_weak_completeness` theorem accessible via `#check` without sorry

## Artifacts & Outputs

- `Theories/Boneyard/Metalogic_v3/Completeness.lean` - Archived deprecated code
- `Theories/Boneyard/Metalogic_v3/README.md` - Explanation of archived code
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Fixed bridge gap
- `Theories/Bimodal/Metalogic/README.md` - Updated documentation
- `specs/787_review_metalogic_progress/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the archive breaks imports in unexpected ways:
1. Restore Completeness.lean from git: `git checkout HEAD -- Theories/Bimodal/Metalogic/Completeness.lean`
2. Keep Boneyard copy as reference
3. Create follow-up task to properly decouple before archiving

If WeakCompleteness fix is more complex than expected:
1. Document the specific blocker in the task
2. Mark phase as [PARTIAL]
3. Create detailed subtask for the specific proof work required

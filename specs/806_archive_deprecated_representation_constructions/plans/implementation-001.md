# Implementation Plan: Archive Deprecated Constructions for Sorry-Free Metalogic

- **Task**: 806 - Archive deprecated Representation/ constructions
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/806_archive_deprecated_representation_constructions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the user's expanded goal: achieve a **sorry-free metalogic** by identifying all sorries not required for the core completeness proof, archiving or removing deprecated constructions, and documenting any remaining sorries with justification.

The research report identified 28+ sorries in the Metalogic directory. Analysis shows:
- The **sorry-free completeness** is already achieved via `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean`
- Most sorries are in `Representation/` files that implement an alternative approach (universal canonical model)
- The `Representation/` approach has known architectural limitations (box semantics, omega-rule)
- Files like `Completeness.lean` (top-level) contain saturation stubs that were never completed

The strategy is to:
1. Audit all sorries and categorize them
2. Move `Representation/` files (with sorries) to `UnderDevelopment/` for isolation
3. Remove deprecated functions within files that have active dependencies
4. Clean up the main build to be sorry-free

### Research Integration

From research-001.md:
- IndexedMCSFamily.lean: 4 sorries in deprecated `construct_indexed_family` (superseded by CoherentConstruction)
- CanonicalHistory.lean: 2 sorries in blocked `canonical_history_respects` (T-axiom limitation)
- Full file archival NOT possible due to active dependencies on `IndexedMCSFamily` structure and `canonical_history_family*` functions

## Goals & Non-Goals

**Goals**:
- Reduce sorry count in main Metalogic build to zero
- Archive deprecated constructions while preserving active dependencies
- Document remaining sorries with clear justification (if any must remain)
- Maintain build integrity throughout

**Non-Goals**:
- Completing the sorried proofs (different task scope)
- Rewriting the representation theorem approach (architectural decision)
- Removing files from UnderDevelopment/ (they are already isolated)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking active imports | H | M | Careful dependency analysis, incremental changes, build verification after each phase |
| Removing code still needed | H | L | Thorough grep for usages before removal |
| Incomplete sorry audit | M | L | Use systematic grep, verify with lake build |
| UnderDevelopment isolation failure | M | L | Verify imports remain commented |

## Implementation Phases

### Phase 1: Comprehensive Sorry Audit [NOT STARTED]

**Goal**: Create complete inventory of all sorries in Metalogic, categorizing each as REQUIRED, NOT REQUIRED, or BLOCKED.

**Tasks**:
- [ ] Grep all sorry occurrences in Theories/Bimodal/Metalogic/
- [ ] For each file with sorries, determine:
  - Is file in main build or UnderDevelopment?
  - Is the sorried definition used by the main completeness proof?
  - Is the sorry architecturally necessary or deprecated?
- [ ] Create categorization table in this plan
- [ ] Update this plan with audit results

**Timing**: 1 hour

**Files to analyze**:
- `Completeness.lean` - 3 sorries (saturation stubs)
- `Representation/IndexedMCSFamily.lean` - 4 sorries
- `Representation/CanonicalHistory.lean` - 2 sorries
- `Representation/TaskRelation.lean` - 5 sorries
- `Representation/CoherentConstruction.lean` - 10 sorries
- `Representation/TruthLemma.lean` - 4 sorries
- `Representation/CanonicalWorld.lean` - 2 sorries
- `Decidability/Correctness.lean` - 3 sorries
- `Decidability/Saturation.lean` - 1 sorry

**Verification**:
- Audit table is complete
- Each sorry has a categorization and justification

---

### Phase 2: Move Representation/ to UnderDevelopment/ [NOT STARTED]

**Goal**: Isolate the entire `Representation/` directory to `UnderDevelopment/` since it contains an alternative approach with known sorries.

**Tasks**:
- [ ] Create `UnderDevelopment/RepresentationTheorem/` directory
- [ ] Move all files from `Representation/` to `UnderDevelopment/RepresentationTheorem/`:
  - IndexedMCSFamily.lean
  - CanonicalHistory.lean
  - TaskRelation.lean
  - CoherentConstruction.lean
  - TruthLemma.lean
  - CanonicalWorld.lean
  - UniversalCanonicalModel.lean
- [ ] Update imports in moved files to reflect new location
- [ ] Update `UnderDevelopment/README.md` to document the move
- [ ] Verify `UnderDevelopment.lean` keeps imports commented out
- [ ] Run `lake build` to verify main build unaffected

**Timing**: 1.5 hours

**Files to modify**:
- Create new directory structure in `UnderDevelopment/`
- Modify imports in 7 moved files
- Update `UnderDevelopment/README.md`
- Remove `Representation/` directory (or keep as empty module)

**Verification**:
- `lake build` succeeds with no errors
- No imports of `Representation/` exist in main build
- UnderDevelopment files compile independently (optional check)

---

### Phase 3: Handle Completeness.lean Saturation Stubs [NOT STARTED]

**Goal**: Remove or document the saturation stubs in top-level Completeness.lean (3 sorries).

**Tasks**:
- [ ] Analyze dependencies on `set_mcs_modal_saturation_backward`, `set_mcs_temporal_future_saturation`, `set_mcs_temporal_past_saturation`
- [ ] If unused by main build: Remove the stubs entirely
- [ ] If used: Move to UnderDevelopment or mark with clear documentation
- [ ] Run `lake build` to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Remove/modify saturation stubs

**Verification**:
- `lake build` succeeds
- No more sorry in Completeness.lean (or documented if required)

---

### Phase 4: Handle Decidability/ Sorries [NOT STARTED]

**Goal**: Document or isolate the 4 sorries in Decidability/ (Correctness.lean + Saturation.lean).

**Tasks**:
- [ ] Check if Decidability/ files are in main build path
- [ ] If in main build: Move to UnderDevelopment/Decidability/
- [ ] If already isolated: Document their status in README
- [ ] Run `lake build` to verify

**Timing**: 30 minutes

**Files to modify**:
- Potentially move `Decidability/Correctness.lean`, `Decidability/Saturation.lean`
- Update `Metalogic/README.md` or `Decidability/README.md`

**Verification**:
- `lake build` succeeds
- Decidability sorries are documented/isolated

---

### Phase 5: Final Verification and Documentation [NOT STARTED]

**Goal**: Verify sorry-free main build and update documentation.

**Tasks**:
- [ ] Run comprehensive sorry grep on main Metalogic (excluding UnderDevelopment)
- [ ] Verify `lake build` succeeds
- [ ] Update `Metalogic/README.md` with:
  - Confirmed sorry-free status (or list any remaining with justification)
  - Updated architecture diagram if needed
  - Reference to UnderDevelopment for alternative approaches
- [ ] Count final sorry count and compare to initial

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md`
- Possibly `specs/state.json` (update repository_health)

**Verification**:
- `grep -r "sorry" Metalogic/ | grep -v UnderDevelopment | grep -v ".md"` returns no results
- `lake build` succeeds
- README reflects current state

---

### Phase 6: Update Build Configuration [NOT STARTED]

**Goal**: Ensure Metalogic.lean and related root modules correctly exclude UnderDevelopment.

**Tasks**:
- [ ] Review `Metalogic/Metalogic.lean` imports
- [ ] Verify no import paths reference moved files
- [ ] Confirm UnderDevelopment.lean keeps imports commented
- [ ] Run clean build: `lake clean && lake build`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` (if needed)
- Any root modules that import Representation/

**Verification**:
- Clean build succeeds
- No warnings about missing imports

## Testing & Validation

- [ ] `lake build` succeeds at every phase
- [ ] No sorries in main Metalogic build (grep verification)
- [ ] `semantic_weak_completeness` remains usable and sorry-free
- [ ] UnderDevelopment files compile when imports are uncommented
- [ ] Documentation accurately reflects code state

## Artifacts & Outputs

- `specs/806_archive_deprecated_representation_constructions/plans/implementation-001.md` (this file)
- `specs/806_archive_deprecated_representation_constructions/summaries/implementation-summary-YYYYMMDD.md`
- Modified `Theories/Bimodal/Metalogic/README.md`
- Modified `Theories/Bimodal/Metalogic/UnderDevelopment/README.md`
- New directory structure: `UnderDevelopment/RepresentationTheorem/`

## Rollback/Contingency

If the build breaks during any phase:
1. Git revert to last known good commit
2. Re-analyze dependencies more carefully
3. Consider partial archival instead of full directory move

If some sorries cannot be removed:
1. Document with clear justification in README
2. Mark as known limitation
3. Ensure they are not on the main completeness proof path

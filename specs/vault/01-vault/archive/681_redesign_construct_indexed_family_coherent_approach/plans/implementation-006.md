# Implementation Plan: Task #681

- **Task**: 681 - Redesign construct_indexed_family with coherent approach
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Priority**: High
- **Dependencies**: None (research-004.md completed)
- **Research Inputs**: specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-004.md
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan cleans up the completeness theorem codebase by moving unneeded proofs to Boneyard with proper documentation. Research-004.md established that the completeness theorem only requires forward_G Case 1 and backward_H Case 4 (both proven). All other sorry-containing cases in CoherentConstruction.lean, backward direction sorries in TruthLemma.lean, and obsoleted code in IndexedMCSFamily.lean can be safely moved to Boneyard. The plan also updates Metalogic/README.md and creates Representation/README.md to accurately document what has been completed and what remains.

### Research Integration

Key findings from research-004.md:
- Completeness only calls `truth_lemma_forward`, which uses forward_G Case 1 and backward_H Case 4 (both proven)
- Cross-origin cases (lines 641, 665, 721 in CoherentConstruction.lean) are never exercised
- Cross-modal cases (lines 654, 662, 724) are never exercised
- forward_H (line 691) is only needed for backward Truth Lemma (not required)
- backward_G Cases 3-4 (lines 721, 724) are never exercised
- TruthLemma backward direction (lines 410, 423) not needed for completeness
- IndexedMCSFamily.lean lines 600-663 obsoleted by CoherentConstruction.lean

## Goals & Non-Goals

**Goals**:
- Move all non-essential sorries from active code to Boneyard
- Preserve complete documentation comments explaining why code was moved
- Update Metalogic/README.md to reflect current architecture
- Create Representation/README.md documenting proof structure and remaining gaps
- Ensure `lake build` succeeds after changes

**Non-Goals**:
- Proving the cross-origin or cross-modal cases
- Implementing backward Truth Lemma
- Modifying the representation_theorem itself
- Changing any proven lemmas

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Moving too much code breaks compilation | High | Low | Run `lake build` after each file move |
| Missing cross-references cause errors | Medium | Medium | Check imports before moving code |
| Boneyard organization unclear | Low | Low | Use descriptive subdirectory names |

## Implementation Phases

### Phase 1: Create Boneyard/Metalogic_v3/Coherence directory structure [COMPLETED]

**Goal**: Set up the Boneyard location for moved code with proper README explaining the contents.

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/`
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic_v3/README.md` explaining this is coherent construction unused cases
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean` with header comments

**Timing**: 20 minutes

**Files to create**:
- `Theories/Bimodal/Boneyard/Metalogic_v3/README.md`
- `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`

**Verification**:
- Directory structure exists
- README explains purpose of directory

---

### Phase 2: Extract unneeded cases from CoherentConstruction.lean [COMPLETED]

**Goal**: Move the 7 sorry-containing case branches from `mcs_unified_chain_pairwise_coherent` to Boneyard, replacing them with a single `sorry` placeholder that documents they are "NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3".

**Tasks**:
- [ ] Read CoherentConstruction.lean lines 620-724 carefully
- [ ] Extract forward_G Cases 3, 4 (cross-origin, both < 0) with full comments
- [ ] Extract backward_H Cases 1, 2 (both >= 0, cross-origin) with full comments
- [ ] Extract forward_H all cases with full comments
- [ ] Extract backward_G Cases 3, 4 (cross-origin, both < 0) with full comments
- [ ] Write extracted cases to `CrossOriginCases.lean` with proper documentation
- [ ] Replace extracted cases in CoherentConstruction.lean with concise sorry + Boneyard reference
- [ ] Run `lake build` to verify no compilation errors

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - simplify sorry cases
- `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean` - add extracted code

**Verification**:
- `lake build` succeeds
- CoherentConstruction.lean is cleaner with explicit "not needed" documentation
- Boneyard file contains extracted code with full context

---

### Phase 3: Move backward Truth Lemma sorries to Boneyard [COMPLETED]

**Goal**: Document that the backward direction of Truth Lemma (all_past, all_future cases) is not required for completeness.

**Tasks**:
- [ ] Read TruthLemma.lean lines 391-423 (all_past/all_future backward cases)
- [ ] Add inline documentation comment explaining these are not needed for completeness
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean`
- [ ] Document in BackwardDirection.lean what the backward Truth Lemma would prove and why it's non-essential
- [ ] Keep sorries in place in TruthLemma.lean but add clear "NOT REQUIRED" comments

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - add documentation comments
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean` - new file documenting approach

**Verification**:
- `lake build` succeeds
- TruthLemma.lean clearly documents which sorries are non-critical

---

### Phase 4: Document obsoleted IndexedMCSFamily code [COMPLETED]

**Goal**: Mark the obsoleted `construct_indexed_family` coherence fields (lines 600-663) as superseded by CoherentConstruction.

**Tasks**:
- [ ] Read IndexedMCSFamily.lean lines 600-663 (the four coherence proofs with sorries)
- [ ] Add documentation block before `construct_indexed_family` explaining it's superseded
- [ ] Add inline comments to each sorry field explaining "superseded by CoherentConstruction.lean"
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic_v3/README.md` section documenting this

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - add superseded documentation

**Verification**:
- `lake build` succeeds
- Documentation clearly explains the relationship between old and new approaches

---

### Phase 5: Update Metalogic/README.md [COMPLETED]

**Goal**: Update the README to accurately reflect the current state of the completeness proof.

**Tasks**:
- [ ] Read current Metalogic/README.md
- [ ] Update "Main Components" table to include CoherentConstruction.lean
- [ ] Update "Key Theorems" section to clarify what's proven vs. what has sorries
- [ ] Add section "Current Status" documenting:
  - Completeness theorem proven (via forward_G Case 1, backward_H Case 4)
  - Cross-origin cases not required (documented in Boneyard)
  - Backward Truth Lemma not required (documented in Boneyard)
- [ ] Update "Relation to Boneyard Code" to mention Metalogic_v3

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md`

**Verification**:
- README accurately describes proven vs. unproven parts
- All mentioned files exist

---

### Phase 6: Create Representation/README.md [COMPLETED]

**Goal**: Create comprehensive documentation for the Representation subdirectory explaining the full proof structure.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/README.md`
- [ ] Document file purposes (7 files):
  - IndexedMCSFamily.lean
  - CoherentConstruction.lean
  - CanonicalWorld.lean
  - CanonicalHistory.lean
  - TaskRelation.lean
  - TruthLemma.lean
  - UniversalCanonicalModel.lean
- [ ] Document the proof path diagram (from research-004.md)
- [ ] Document what's proven, what has sorries, and why sorries don't block completeness
- [ ] Cross-reference Boneyard/Metalogic_v3 for moved code

**Timing**: 40 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Representation/README.md`

**Verification**:
- README exists and is comprehensive
- All cross-references are valid

---

### Phase 7: Final verification and cleanup [COMPLETED]

**Goal**: Verify all changes compile and documentation is consistent.

**Tasks**:
- [ ] Run `lake build` to verify full compilation
- [ ] Review all modified files for consistency
- [ ] Verify cross-references between READMEs are valid
- [ ] Check that Boneyard files have proper import statements (if any)

**Timing**: 20 minutes

**Verification**:
- `lake build` succeeds with no new errors
- All documentation is consistent
- No orphaned references

## Testing & Validation

- [ ] `lake build` succeeds after Phase 2 (CoherentConstruction changes)
- [ ] `lake build` succeeds after Phase 3 (TruthLemma changes)
- [ ] `lake build` succeeds after Phase 4 (IndexedMCSFamily changes)
- [ ] `lake build` succeeds at final verification
- [ ] All README cross-references point to existing files
- [ ] Boneyard directory structure is logical and documented

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Metalogic_v3/README.md`
- `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean`
- `Theories/Bimodal/Metalogic/README.md` (modified)
- `Theories/Bimodal/Metalogic/Representation/README.md` (new)
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (modified)
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` (modified)
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (modified)
- `specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-20260128.md`

## Rollback/Contingency

If changes break compilation:
1. Use `git diff` to identify problematic changes
2. Revert specific files with `git checkout -- <file>`
3. Re-attempt with more conservative edits (documentation only, no code moves)

If Boneyard structure is confusing:
1. Flatten to single Metalogic_v3.lean file instead of subdirectories
2. Use comments to separate logical sections

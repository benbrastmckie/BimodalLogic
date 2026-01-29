# Implementation Plan: Task #745

- **Task**: 745 - Move backward Truth Lemma to Boneyard
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/745_move_backward_truth_lemma_to_boneyard/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Refactor TruthLemma.lean and related files to present only the forward Truth Lemma cleanly, moving all backward direction infrastructure to the Boneyard. The key insight is that the mutual induction structure cannot simply have sorries removed - it must be restructured to eliminate backward cases entirely. The goal is a clean Metalogic/Representation/ directory with NO sorries and NO references to the Boneyard or historical attempts.

### Research Integration

From research-001.md:
- TruthLemma.lean has 4 sorries: 2 box cases (lines 383, 406) and 2 backward temporal cases (lines 435, 459)
- TemporalCompleteness.lean is only imported by TruthLemma.lean and contains H/G-completeness sorries
- Only `truth_lemma_forward` (via `.mp`) is used by UniversalCanonicalModel.lean
- Backward temporal cases blocked by omega-rule limitation
- Box cases blocked by architectural limitation (universal quantification over histories)

**User's Refined Goal**: The Bimodal/Metalogic/ must be completely clean - no sorries, no historical mentions, no Boneyard references. The forward Truth Lemma should be presented on its own terms as a self-contained result.

## Goals and Non-Goals

**Goals**:
- Remove ALL sorries from Bimodal/Metalogic/Representation/
- Present forward Truth Lemma as a clean, self-contained theorem
- Move TemporalCompleteness.lean to Boneyard with full documentation
- Archive backward direction documentation in Boneyard
- Ensure `lake build` succeeds with no sorries in Representation/

**Non-Goals**:
- Proving the backward Truth Lemma (blocked by omega-rule)
- Proving the box cases (architectural limitation)
- Restructuring the box semantics
- Modifying UniversalCanonicalModel.lean beyond import cleanup

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mutual induction dependency | High | Medium | Research shows forward direction uses backward IH for imp case - need to restructure proof |
| Import chain breaks | Medium | Low | Verify only TruthLemma.lean imports TemporalCompleteness.lean |
| Missing documentation | Medium | Low | Create comprehensive Boneyard documentation before removing |
| Box case complications | Medium | Medium | Box cases are separate from temporal - can be handled independently |

## Implementation Phases

### Phase 1: Move TemporalCompleteness.lean to Boneyard [NOT STARTED]

**Goal**: Move backward temporal infrastructure to Boneyard with documentation.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/TemporalCompleteness.lean`
- [ ] Copy full content from `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean`
- [ ] Update header documentation in Boneyard copy to explain why it was moved
- [ ] Add cross-references to Task 745 and omega-rule limitation
- [ ] Delete original `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean`
- [ ] Remove import from TruthLemma.lean (line 3)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/TemporalCompleteness.lean` - Create (copy from Representation/)
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - Delete
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Remove import line

**Verification**:
- Boneyard file exists with proper documentation
- Original file deleted
- Import removed from TruthLemma.lean

---

### Phase 2: Restructure TruthLemma.lean to Forward-Only [NOT STARTED]

**Goal**: Restructure TruthLemma.lean to only prove the forward direction, eliminating all sorries.

**Tasks**:
- [ ] Analyze forward imp case dependency on backward IH
- [ ] Create new proof structure that only proves forward direction
- [ ] Remove backward cases entirely (not just sorry them)
- [ ] Remove `truth_lemma_backward` theorem
- [ ] Remove `truth_lemma` biconditional (or redefine as forward-only synonym)
- [ ] Keep only `truth_lemma_forward` and rename to `truth_lemma`
- [ ] Update module documentation to focus on forward result
- [ ] Remove ALL Boneyard references from comments
- [ ] Remove ALL historical mentions and comparisons

**Timing**: 2 hours

**Key Challenge**: The mutual induction allows using backward IH in forward proofs. Specifically, the forward imp case uses:
```lean
-- From backward IH to convert truth_at psi to psi in MCS
have h_psi_in_mcs : psi ∈ family.mcs t := (ih_psi t).mpr h_psi_true
```

**Solution Strategy**:
1. For temporal cases (all_past, all_future): The forward direction is complete - no backward IH needed
2. For imp case: Restructure to avoid needing backward direction:
   - The forward imp case proves: `(psi.imp chi) in MCS -> truth_at psi -> truth_at chi`
   - Actually examine the proof - it uses `(ih_psi t).mpr` which is backward direction
   - Need different approach: prove forward direction directly without backward IH
3. For box case: Accept this cannot be proven with current architecture - must be removed

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Major restructure

**Verification**:
- `lake build` succeeds
- No `sorry` in TruthLemma.lean
- No Boneyard references in TruthLemma.lean
- `truth_lemma_forward` or `truth_lemma` exists and is proven

---

### Phase 3: Clean Up Module Header and Documentation [NOT STARTED]

**Goal**: Present TruthLemma.lean as a clean, self-contained result.

**Tasks**:
- [ ] Rewrite module header documentation
- [ ] Remove "Gaps NOT Required for Completeness" section
- [ ] Remove references to specs/656_... (old task)
- [ ] Remove references to BackwardDirection.lean
- [ ] Update proof strategy section to reflect forward-only approach
- [ ] Ensure no mentions of "backward", "blocked", "sorry", or "Boneyard"
- [ ] Clean up any stale comments throughout file

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Documentation cleanup

**Verification**:
- Documentation presents forward Truth Lemma as the main result
- No historical or comparison language
- No Boneyard references
- Professional, clean presentation

---

### Phase 4: Update Boneyard Documentation [NOT STARTED]

**Goal**: Consolidate all backward direction documentation in Boneyard.

**Tasks**:
- [ ] Update `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean`
- [ ] Add reference to moved TemporalCompleteness.lean
- [ ] Add Task 745 context explaining the refactor
- [ ] Document what was removed from main codebase and why
- [ ] Ensure Boneyard has complete historical record

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean` - Update documentation

**Verification**:
- BackwardDirection.lean contains complete historical record
- References to TemporalCompleteness.lean (Boneyard location)
- Task 745 documented

---

### Phase 5: Final Verification and Build [NOT STARTED]

**Goal**: Verify clean build with no sorries in Representation/.

**Tasks**:
- [ ] Run `lake build`
- [ ] Verify no sorries in `Theories/Bimodal/Metalogic/Representation/`
- [ ] Grep for "sorry" in Representation/ directory
- [ ] Grep for "Boneyard" in Representation/ directory
- [ ] Verify UniversalCanonicalModel.lean still works (uses truth_lemma)
- [ ] Check for any broken imports across codebase

**Timing**: 30 minutes

**Verification**:
- `lake build` succeeds
- `grep -r "sorry" Theories/Bimodal/Metalogic/Representation/` returns nothing
- `grep -r "Boneyard" Theories/Bimodal/Metalogic/Representation/` returns nothing
- UniversalCanonicalModel.lean compiles correctly

---

## Testing and Validation

- [ ] `lake build` succeeds with no errors
- [ ] No sorries in Representation/ directory
- [ ] No Boneyard references in Representation/ directory
- [ ] TruthLemma.lean presents clean forward-only theorem
- [ ] UniversalCanonicalModel.lean works with renamed/restructured truth_lemma
- [ ] Boneyard contains complete documentation of what was removed

## Artifacts and Outputs

- `specs/745_move_backward_truth_lemma_to_boneyard/plans/implementation-001.md` (this file)
- `specs/745_move_backward_truth_lemma_to_boneyard/summaries/implementation-summary-YYYYMMDD.md`
- Modified `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
- Deleted `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean`
- Created `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/TemporalCompleteness.lean`
- Modified `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean`

## Rollback/Contingency

If Phase 2 restructuring proves impossible (forward imp case truly requires backward IH):
1. Keep mutual induction structure but mark backward cases as `sorry` with comments saying "NOT PROVEN - not required for completeness"
2. Move the entire backward-related sections to a clearly marked section at the end
3. Update documentation to explain this is forward-only API despite internal structure

Git provides rollback capability: `git checkout HEAD -- Theories/Bimodal/Metalogic/Representation/`

## Technical Notes

### Forward Imp Case Analysis

The current imp forward case:
```lean
| imp psi chi ih_psi ih_chi =>
  constructor
  · -- Forward: (psi -> chi) in mcs t -> (truth_at psi -> truth_at chi)
    intro h_mem h_psi_true
    -- Uses backward IH: (ih_psi t).mpr h_psi_true
    have h_psi_in_mcs : psi ∈ family.mcs t := (ih_psi t).mpr h_psi_true
```

This uses `(ih_psi t).mpr` which is the backward direction. However, if we only prove forward direction, we don't have this available.

**Alternative Approach**: Change the theorem structure to prove:
```lean
theorem truth_lemma_forward (phi : Formula) :
    phi ∈ family.mcs t → truth_at ... phi
```

For the imp case forward, we need: `(psi.imp chi) in MCS` and `truth_at psi` implies `truth_at chi`.

If we don't have backward IH, we cannot convert `truth_at psi` to `psi in MCS`. This suggests the mutual induction is essential for imp case.

**Resolution Options**:
1. **Accept box sorries only**: Keep structure, remove temporal backward sorries (which are unused), keep box sorries (different problem)
2. **Different proof structure**: Use excluded middle on `psi in MCS` - if yes, derive chi via MP; if no, derive contradiction
3. **Semantic argument**: Use model theory directly without IH

The implementation phase will determine which approach works.

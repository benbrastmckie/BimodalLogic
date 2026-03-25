# Implementation Plan: Task #63 - BFMCS Modal Completeness

- **Task**: 63 - prove_box_backward_via_bfmcs
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: Task 62 (completed)
- **Research Inputs**: specs/063_prove_box_backward_via_bfmcs/reports/02_team-research.md
- **Artifacts**: plans/01_bfmcs-modal-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Wire the already-proven `boxClassFamilies_modal_backward` theorem (UltrafilterChain.lean:1678) into the parametric completeness path via a BFMCS construction. The modal direction is fully solved - this task connects the existing proof to the main completeness theorem. The temporal direction (G/H backward) is mathematically different and deferred to a follow-up task.

### Research Integration

Key findings from team research (02_team-research.md):
- `boxClassFamilies_modal_backward` is sorry-free and proven
- The singleton-Omega sorry in SuccChainTruth.lean:254 is mathematically unprovable
- Modal and temporal completeness are structurally independent (S5 vs S4 distinction)
- Per-obligation witness architecture is the recommended path for temporal (follow-up task)

## Goals and Non-Goals

**Goals**:
- Create `bfmcs_from_mcs` constructor that builds a BFMCS from an arbitrary MCS
- Wire `boxClassFamilies_modal_backward` into the parametric truth lemma Box case
- Document the singleton-Omega dead end in SuccChainTruth.lean comments
- Achieve sorry-free modal completeness (Box forward and backward)
- Build compiles with no new sorries

**Non-Goals**:
- Full sorry-free temporal completeness (G/H backward) - separate follow-up task
- Removing existing temporal sorries - deferred
- Per-obligation witness architecture implementation - separate task
- Modifying the ultrafilter chain construction

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type mismatch between BFMCS and ParametricTruthLemma | Medium | Medium | Carefully trace type parameters through ParametricCanonical, add coercions if needed |
| Box case in truth lemma has hidden dependencies | Low | Low | The modal case is logically independent - verify by inspection |
| Build issues from import changes | Low | Medium | Test build after each phase |

## Implementation Phases

### Phase 1: Analyze Current Truth Lemma Structure [NOT STARTED]

**Goal**: Understand the current Box case in ParametricTruthLemma and identify exact insertion points.

**Tasks**:
- [ ] Read ParametricTruthLemma.lean lines 170-310 (truth lemma structure)
- [ ] Identify the Box forward case (should use modal_forward or similar)
- [ ] Identify the Box backward case (may have sorry or stub)
- [ ] Document the current signature of `boxClassFamilies_modal_backward`
- [ ] Map type parameters: D-parametric vs Int-based in UltrafilterChain

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean:170-310`
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean:1678-1782`

**Verification**:
- Clear understanding of how Box case is currently handled
- Type signature comparison documented

---

### Phase 2: Create BFMCS Construction from MCS [NOT STARTED]

**Goal**: Create `bfmcs_from_mcs` that wraps an MCS in the boxClassFamilies bundle structure.

**Tasks**:
- [ ] Define `bfmcs_from_mcs` in a new section of UltrafilterChain.lean or ParametricTruthLemma.lean
- [ ] Prove the MCS is in its own boxClassFamilies bundle
- [ ] Prove `bfmcs_from_mcs_membership`: the original MCS is a member of the BFMCS at time 0
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - add bfmcs_from_mcs section

**Verification**:
- `bfmcs_from_mcs M h_mcs` returns a BFMCS containing M
- `lake build` passes without errors

---

### Phase 3: Wire Modal Backward into Truth Lemma [NOT STARTED]

**Goal**: Connect `boxClassFamilies_modal_backward` to the Box backward case in the truth lemma.

**Tasks**:
- [ ] Add import of UltrafilterChain to ParametricTruthLemma if needed
- [ ] In the Box backward case, apply `boxClassFamilies_modal_backward`
- [ ] Handle any type coercions between D-parametric and Int
- [ ] Remove any sorry in the Box backward case
- [ ] Verify the full truth lemma now has sorry-free Box case

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Box backward case

**Verification**:
- `lake build` passes
- Box case in truth lemma has no sorry
- `#check parametric_canonical_truth_lemma` shows no sorry warnings for Box

---

### Phase 4: Document Singleton-Omega Dead End [NOT STARTED]

**Goal**: Update SuccChainTruth.lean comments to clearly document why the singleton-Omega approach is mathematically impossible.

**Tasks**:
- [ ] Expand comment block at SuccChainTruth.lean:254 with full explanation
- [ ] Add docstring to the sorry section explaining the S5 negative introspection gap
- [ ] Reference the boxClassFamilies solution as the correct path
- [ ] Add note about per-obligation architecture for temporal (future work)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean:254` - expand documentation

**Verification**:
- Comments clearly explain why singleton-Omega fails
- Reference to BFMCS solution is clear

---

### Phase 5: Update ROADMAP and Final Verification [NOT STARTED]

**Goal**: Document progress and verify the implementation is complete.

**Tasks**:
- [ ] Run `lake build` and verify no new sorries introduced
- [ ] Check that `boxClassFamilies_modal_backward` is correctly wired
- [ ] Update ROADMAP.md if it exists with modal completeness status
- [ ] Create follow-up task description for temporal per-obligation architecture

**Timing**: 30 minutes

**Files to check**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`

**Verification**:
- `lake build` passes
- No regressions in existing proofs
- Modal completeness path is clear

## Testing and Validation

- [ ] `lake build` compiles successfully
- [ ] No new sorries in modified files
- [ ] `boxClassFamilies_modal_backward` is used in truth lemma Box case
- [ ] Documentation clearly explains singleton-Omega dead end
- [ ] Type parameters are correctly handled (D vs Int)

## Artifacts and Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - bfmcs_from_mcs constructor
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - wired Box backward case
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` - documentation updates
- `specs/063_prove_box_backward_via_bfmcs/summaries/01_bfmcs-modal-completeness-summary.md` - execution summary

## Rollback/Contingency

If the type mismatch between D-parametric and Int proves too complex:
1. Create specialized Int-based truth lemma variant
2. Factor out the modal case into a separate lemma that can be called from either context
3. Accept temporary code duplication with a cleanup task

If build issues arise:
1. Revert to last known good state via git
2. Isolate changes to single file at a time
3. Test incrementally with `lake build Module.Name`

## Follow-Up Tasks

After this task, the recommended follow-up is:

**Task: Complete temporal per-obligation witness architecture**
- Complete CanonicalFrame.lean per-obligation witness construction
- Wire temporal_theory_witness_exists for G/H backward
- Remove remaining temporal sorries
- Estimated effort: 8-16 hours (separate task)

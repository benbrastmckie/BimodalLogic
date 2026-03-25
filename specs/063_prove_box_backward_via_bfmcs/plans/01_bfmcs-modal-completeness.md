# Implementation Plan: Task #63 - BFMCS Modal Completeness

- **Task**: 63 - prove_box_backward_via_bfmcs
- **Status**: [COMPLETED]
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

### Phase 1: Analyze Current Truth Lemma Structure [COMPLETED]

**Goal**: Understand the current Box case in ParametricTruthLemma and identify exact insertion points.

**Tasks**:
- [x] Read ParametricTruthLemma.lean lines 170-310 (truth lemma structure)
- [x] Identify the Box forward case (uses B.modal_forward at line 256)
- [x] Identify the Box backward case (uses B.modal_backward at line 269 - ALREADY WIRED)
- [x] Document the current signature of `boxClassFamilies_modal_backward`
- [x] Map type parameters: D-parametric vs Int-based in UltrafilterChain

**Findings**:
- The Box backward case in `parametric_canonical_truth_lemma` (line 269) is ALREADY complete
- `B.modal_backward` is used directly, which works for any BFMCS regardless of D
- `boxClassFamilies_modal_backward` (UltrafilterChain.lean:1678) is sorry-free
- `construct_bfmcs` (line 1862) uses `boxClassFamilies_modal_backward` to populate the field
- The wiring is complete - no code changes needed for modal completeness

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean:170-310`
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean:1678-1782`

**Verification**:
- Clear understanding of how Box case is currently handled
- Type signature comparison documented

---

### Phase 2: Create BFMCS Construction from MCS [COMPLETED]

**Goal**: Create `bfmcs_from_mcs` that wraps an MCS in the boxClassFamilies bundle structure.

**Tasks**:
- [x] Define `bfmcs_from_mcs` in UltrafilterChain.lean - ALREADY EXISTS as `construct_bfmcs`
- [x] Prove the MCS is in its own boxClassFamilies bundle - `eval_family_mem_boxClassFamilies`
- [x] Prove `bfmcs_from_mcs_membership`: the original MCS is a member at time 0 - line 1874-1876
- [x] Verify `lake build` passes

**Findings**:
- `construct_bfmcs` (line 1852-1877) already does exactly this
- It returns `Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent) (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int), M = fam.mcs t`
- The BFMCS's `modal_backward` field is populated by `boxClassFamilies_modal_backward` (line 1862)
- Note: `construct_bfmcs` is marked @[deprecated] due to temporal coherence sorries (a separate issue)
- The modal direction (Box forward/backward) is sorry-free

---

### Phase 3: Wire Modal Backward into Truth Lemma [COMPLETED]

**Goal**: Connect `boxClassFamilies_modal_backward` to the Box backward case in the truth lemma.

**Tasks**:
- [x] Add import of UltrafilterChain to ParametricTruthLemma if needed - Not needed, uses BFMCS abstraction
- [x] In the Box backward case, apply `boxClassFamilies_modal_backward` - ALREADY DONE via B.modal_backward
- [x] Handle any type coercions between D-parametric and Int - Not needed, D-parametric works
- [x] Remove any sorry in the Box backward case - No sorry exists
- [x] Verify the full truth lemma now has sorry-free Box case - Confirmed via lean_goal

**Findings**:
- `parametric_canonical_truth_lemma` (line 170) uses `B.modal_backward` at line 269
- This is the BFMCS field populated by `boxClassFamilies_modal_backward` when using `boxClassFamilies`
- The D-parametric abstraction means no Int-specific handling is needed
- Both truth lemmas (`parametric_canonical_truth_lemma` and `parametric_shifted_truth_lemma`) are sorry-free for Box

---

### Phase 4: Document Singleton-Omega Dead End [COMPLETED]

**Goal**: Update SuccChainTruth.lean comments to clearly document why the singleton-Omega approach is mathematically impossible.

**Tasks**:
- [x] Expand comment block at SuccChainTruth.lean:254 with full explanation
- [x] Add docstring to the sorry section explaining the S5 negative introspection gap
- [x] Reference the boxClassFamilies solution as the correct path
- [x] Add note about per-obligation architecture for temporal (future work)

**Completed Changes**:
- Added "PROVEN THEOREM REFERENCE" section with specific theorem and line references
- Added "STATUS" line confirming modal completeness is solved in BFMCS path
- Updated module docstring with BFMCS Solution note
- Updated path reference to `Algebraic/UltrafilterChain.lean` for clarity
- `lake build` passes (927 jobs)

---

### Phase 5: Update ROADMAP and Final Verification [COMPLETED]

**Goal**: Document progress and verify the implementation is complete.

**Tasks**:
- [x] Run `lake build` and verify no new sorries introduced
- [x] Check that `boxClassFamilies_modal_backward` is correctly wired
- [x] Update ROADMAP.md if it exists with modal completeness status
- [x] Create follow-up task description for temporal per-obligation architecture

**Completed Changes**:
- Added "Modal Completeness (Box Forward/Backward) — SOLVED" section to ROADMAP.md
- Documented the contraposition proof strategy used in `boxClassFamilies_modal_backward`
- Clarified that temporal coherence (G/H backward) is the remaining challenge
- `lake build` passes with 927 jobs, no regressions

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

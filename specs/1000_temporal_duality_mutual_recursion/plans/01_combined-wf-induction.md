# Implementation Plan: Task #1000

- **Task**: 1000 - temporal_duality_mutual_recursion
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/1000_temporal_duality_mutual_recursion/reports/01_mutual-recursion-patterns.md
- **Artifacts**: plans/01_combined-wf-induction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Implement mutual recursion for temporal_duality soundness case using combined well-founded induction on DerivationTree.height. The research report recommends Approach A: define a single function computing both validity and swap-validity simultaneously using conjunction return type, then extract individual theorems. This avoids actual mutual recursion by proving both goals in one pass.

### Research Integration

From research report 01_mutual-recursion-patterns.md:
- Recommended approach: Combined well-founded induction (Approach A) using `Prod` return type
- Key insight: Lean's termination checker accepts `termination_by d.height` for derivation induction
- Required lemma: `Formula.swap_past_future_involution` (already exists in codebase)
- Existing pattern: DeductionTheorem.lean uses same `termination_by h.height` approach
- All supporting lemmas (axiom_swap_valid, mp_preserves_swap_valid, etc.) are complete in SoundnessLemmas.lean

## Goals & Non-Goals

**Goals**:
- Implement `derivable_valid_and_swap_valid` combined theorem in SoundnessLemmas.lean
- Extract `derivable_locally_valid` and `derivable_implies_swap_valid` as corollaries
- Wire `derivable_implies_swap_valid` into the temporal_duality case in Soundness.lean
- Remove the `sorry` from Soundness.lean:697
- Ensure `lake build` succeeds without errors

**Non-Goals**:
- Modifying axiom or rule preservation proofs (already complete)
- Implementing the IRR case (separate task, already marked sorry)
- Restructuring the module hierarchy
- Implementing alternative approaches (B, C, D from research)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `termination_by d.height` rejected | High | Low | Use explicit WellFounded.fix as fallback (Approach B) |
| Type unification issues in combined theorem | Medium | Low | Add explicit type annotations |
| IRR case interaction | Low | Low | IRR case is independent, already has sorry |
| Dense compatibility propagation | Medium | Medium | Carefully thread h_dc through match arms |

## Implementation Phases

### Phase 1: Implement Combined Theorem [COMPLETED]

**Goal**: Create `derivable_valid_and_swap_valid` theorem in SoundnessLemmas.lean

**Tasks**:
- [ ] Add combined theorem after `axiom_locally_valid` (around line 873)
- [ ] Implement axiom case using existing `axiom_locally_valid` and `axiom_swap_valid`
- [ ] Implement modus_ponens case using `ih1.1`/`ih2.1` for validity, `mp_preserves_swap_valid` for swap
- [ ] Implement necessitation case using `ih.1` for validity, `modal_k_preserves_swap_valid` for swap
- [ ] Implement temporal_necessitation case using `ih.1` for validity, `temporal_k_preserves_swap_valid` for swap
- [ ] Implement temporal_duality case: use `ih.2` for validity (since `phi'.swap` is valid), use `ih.1` with involution for swap
- [ ] Implement weakening case using `ih`
- [ ] Implement assumption case (contradiction from empty context)
- [ ] Mark IRR case with sorry (to be addressed in separate task)
- [ ] Add `termination_by d.height`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Add combined theorem after line 873

**Verification**:
- `lake build Bimodal.Metalogic.SoundnessLemmas` compiles without errors
- `lean_goal` at key positions shows expected proof states

---

### Phase 2: Extract Individual Theorems [COMPLETED]

**Goal**: Define `derivable_locally_valid` and `derivable_implies_swap_valid` as projections

**Tasks**:
- [ ] Add `derivable_locally_valid` theorem projecting `.1` from combined theorem
- [ ] Add `derivable_implies_swap_valid` theorem projecting `.2` from combined theorem
- [ ] Verify type signatures match expected interface

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Add extraction theorems after combined theorem

**Verification**:
- Both theorems compile
- `lean_hover_info` shows correct type signatures

---

### Phase 3: Wire into Soundness.lean [COMPLETED]

**Goal**: Replace sorry in temporal_duality case with proof using `derivable_implies_swap_valid`

**Tasks**:
- [ ] Import or verify SoundnessLemmas is accessible from Soundness.lean
- [ ] Replace sorry at line 697 with call to `derivable_implies_swap_valid`
- [ ] Thread `h_dc` (dense compatibility) and semantic parameters correctly
- [ ] Handle any type coercions between local `is_valid` and global validity

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Lines 690-697

**Verification**:
- `lake build Bimodal.Metalogic.Soundness` compiles without new errors
- The sorry for temporal_duality is removed
- IRR sorry remains (expected, separate task)

---

### Phase 4: Build Verification and Cleanup [COMPLETED]

**Goal**: Verify full build passes and clean up any issues

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Address any downstream compilation issues
- [ ] Verify sorry count is reduced by 1 (temporal_duality case)
- [ ] Add documentation comments to new theorems

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Documentation
- `Theories/Bimodal/Metalogic/Soundness.lean` - Documentation

**Verification**:
- `lake build` succeeds
- `grep -c "sorry" Theories/Bimodal/Metalogic/Soundness.lean` returns expected count (1 for IRR)

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.SoundnessLemmas` compiles
- [ ] `lake build Bimodal.Metalogic.Soundness` compiles
- [ ] `lake build` (full project) compiles
- [ ] `lean_verify` on `derivable_valid_and_swap_valid` shows no sorry dependencies
- [ ] Sorry count in Soundness.lean reduced from 2 to 1

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Extended with combined theorem and extractors
- `Theories/Bimodal/Metalogic/Soundness.lean` - temporal_duality case completed
- `specs/1000_temporal_duality_mutual_recursion/summaries/01_combined-wf-induction-summary.md` - Implementation summary

## Rollback/Contingency

If `termination_by d.height` is rejected by Lean:
1. Attempt Approach B: explicit `WellFounded.Nat.fix` with height measure
2. If still failing, attempt Approach D: `mutual` block with shared termination_by
3. Document findings and escalate if all approaches fail

All changes are additive to SoundnessLemmas.lean and localized to one case in Soundness.lean, so rollback is straightforward via git revert.

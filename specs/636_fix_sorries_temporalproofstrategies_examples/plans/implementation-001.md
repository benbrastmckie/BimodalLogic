# Implementation Plan: Task #636

- **Task**: 636 - fix_sorries_temporalproofstrategies_examples
- **Status**: [IMPLEMENTING]
- **Effort**: 0.5 hours
- **Priority**: Low
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix 5 sorries in pedagogical exercise examples in `Theories/Bimodal/Examples/TemporalProofStrategies.lean`. These are intentional exercises (marked with `-- EXERCISE:` comments) meant for students to complete, not incomplete core logic. The recommended approach from the task description is to remove the examples since they have no impact on core theorems.

### Analysis Summary

- **File**: `Theories/Bimodal/Examples/TemporalProofStrategies.lean`
- **Sorries at lines**: 355, 420, 435, 490, 540
- **Nature**: Intentional pedagogical exercises (marked with `-- EXERCISE:` comments)
- **Dependencies**: Only imported by `Bimodal/Examples.lean` aggregator; no other files depend on these specific examples
- **Impact**: None - examples only, not part of core logic

## Goals & Non-Goals

**Goals**:
- Eliminate all 5 sorries from TemporalProofStrategies.lean
- Maintain file's pedagogical value as a learning resource
- Ensure `lake build` completes without warnings about sorries

**Non-Goals**:
- Converting working examples to exercises (they already work)
- Adding new examples or extending the file's scope
- Modifying the non-exercise examples (they are complete)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing exercises loses pedagogical value | Low | Medium | Keep exercise comments and hints; just mark as "Advanced/Optional" |
| Some exercises may be completable easily | Low | Medium | Attempt completion first; only remove if difficult |

## Implementation Phases

### Phase 1: Attempt Proof Completion [COMPLETED]

**Goal**: Try to complete the 5 exercises with correct Lean proofs

**Tasks**:
- [ ] Examine exercise 1 (line 355): Temporal K distribution `phi -> GG(PP phi)`
- [ ] Examine exercise 2 (line 420): Perpetuity preservation `always phi -> G(always phi)`
- [ ] Examine exercise 3 (line 435): Perpetuity past direction `always phi -> H(always phi)`
- [ ] Examine exercise 4 (line 490): Future-past iteration `GG phi -> G phi`
- [ ] Examine exercise 5 (line 540): Past-future commutation `H(G phi) -> G(H phi)`
- [ ] For each exercise, use `lean_goal` to examine proof state
- [ ] Use `lean_multi_attempt` to test potential tactics
- [ ] Complete proofs where feasible using available lemmas from Perpetuity.lean and Combinators

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Examples/TemporalProofStrategies.lean` - Replace sorries with complete proofs

**Verification**:
- Run `lean_diagnostic_messages` to confirm no errors
- Run `lake build` to verify compilation

---

### Phase 2: Remove Incomplete Exercises (Fallback) [IN PROGRESS]

**Goal**: If Phase 1 cannot complete all proofs, remove the incomplete exercises

**Tasks**:
- [ ] For any exercises that could not be completed in Phase 1, delete the entire example block (comment + example declaration)
- [ ] Update the module docstring's "Exercises" section to reflect which exercises remain
- [ ] If all exercises are removed, update the docstring to remove the Exercises section entirely
- [ ] Ensure the file still compiles without errors

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Examples/TemporalProofStrategies.lean` - Remove incomplete examples

**Verification**:
- Run `lean_diagnostic_messages` to confirm no errors
- Run `lake build` to verify compilation
- Verify no other files are affected by removal

## Testing & Validation

- [ ] `lake build` completes successfully with no sorry warnings
- [ ] `lean_diagnostic_messages` shows no errors in modified file
- [ ] File structure and documentation remain coherent after changes
- [ ] No other files in the codebase are broken by changes

## Artifacts & Outputs

- `Theories/Bimodal/Examples/TemporalProofStrategies.lean` - Modified file without sorries
- `specs/636_fix_sorries_temporalproofstrategies_examples/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation causes unexpected issues:
1. Revert changes with `git checkout Theories/Bimodal/Examples/TemporalProofStrategies.lean`
2. The file has working examples alongside the exercises; reverting restores all exercises
3. As a last resort, comment out problematic examples rather than deleting

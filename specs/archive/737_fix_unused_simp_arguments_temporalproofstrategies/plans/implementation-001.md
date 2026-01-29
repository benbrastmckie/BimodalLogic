# Implementation Plan: Task #737

- **Task**: 737 - Fix unused simp arguments in TemporalProofStrategies.lean
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Priority**: low
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove unused `Formula.swap_temporal_involution` arguments from four simp calls in TemporalProofStrategies.lean. The linter has identified these arguments as unused - the simp tactic completes successfully without them because the necessary rewriting has already been done by preceding tactics.

## Goals & Non-Goals

**Goals**:
- Remove unused simp arguments at lines 174, 203, 242, 459
- Ensure all four affected proofs still compile correctly
- Eliminate linter warnings

**Non-Goals**:
- Refactoring the proof structure
- Changing the proof strategy
- Adding new lemmas or theorems

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing argument breaks proof | M | L | Test each change individually with lake build |
| Line numbers have shifted | L | L | Use grep to locate exact simp calls with swap_temporal_involution |

## Implementation Phases

### Phase 1: Fix all four unused simp arguments [COMPLETED]

**Goal**: Remove `Formula.swap_temporal_involution` from the four simp calls identified by the linter

**Tasks**:
- [ ] Remove `Formula.swap_temporal_involution` from simp at line 174 in proof at line 155
- [ ] Remove `Formula.swap_temporal_involution` from simp at line 203 in proof at line 183
- [ ] Remove `Formula.swap_temporal_involution` from simp at line 242 in proof at line 227
- [ ] Remove `Formula.swap_temporal_involution` from simp at line 459 in proof at line 445
- [ ] Run `lake build` to verify all proofs still compile

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Examples/TemporalProofStrategies.lean` - Remove unused simp arguments

**Verification**:
- `lake build` succeeds with no errors
- Linter no longer reports unused simp arguments
- All four affected proofs remain valid

## Testing & Validation

- [ ] All simp calls with `Formula.swap_temporal_involution` removed
- [ ] `lake build` completes successfully
- [ ] No new warnings or errors introduced

## Artifacts & Outputs

- Modified `Theories/Bimodal/Examples/TemporalProofStrategies.lean` with unused arguments removed

## Rollback/Contingency

If any proof breaks after removing the argument:
1. Restore the original simp call
2. Investigate why the argument appears unused but is actually needed
3. Consider alternative fixes (e.g., using `simp only` instead)

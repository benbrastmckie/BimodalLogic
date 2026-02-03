# Implementation Plan: Task #786

- **Task**: 786 - Migrate efq to efq_neg
- **Status**: [COMPLETED]
- **Effort**: 0.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/786_migrate_efq_to_efq_neg/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace 2 deprecated `efq` function calls with `efq_neg` in Theories/Bimodal/Theorems/Propositional.lean. The `efq` function was deprecated on 2025-12-14 in favor of `efq_neg`, and both have identical type signatures, making this a direct text substitution.

### Research Integration

- `efq` and `efq_neg` have identical type signatures: `(A B : Formula) : ⊢ A.neg.imp (A.imp B)`
- `efq` is literally defined as `efq_neg A B`, confirming semantic equivalence
- Two usage locations identified: line 402 (in `ldi`) and line 596 (in conjunction elimination)

## Goals & Non-Goals

**Goals**:
- Eliminate deprecation warnings for `efq` usage
- Update code to use the canonical `efq_neg` function

**Non-Goals**:
- Changing proof logic or structure
- Removing the deprecated `efq` definition (may be used externally)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type mismatch after substitution | High | Very Low | Identical signatures confirmed by research |
| Proof breakage | High | Very Low | efq literally wraps efq_neg |

## Implementation Phases

### Phase 1: Replace deprecated efq calls [COMPLETED]

**Goal**: Substitute all `efq` calls with `efq_neg` calls

**Tasks**:
- [x] Replace `efq A B` with `efq_neg A B` at line 402
- [x] Replace `efq A B.neg` with `efq_neg A B.neg` at line 596
- [x] Verify build succeeds with no errors

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Theorems/Propositional.lean` - Replace 2 efq calls with efq_neg

**Verification**:
- `lake build` succeeds without deprecation warnings for efq
- No new build errors introduced

---

## Testing & Validation

- [x] `lake build` completes successfully
- [x] No deprecation warnings for efq remain
- [x] Proofs using efq_neg typecheck correctly

## Artifacts & Outputs

- Modified file: `Theories/Bimodal/Theorems/Propositional.lean`

## Rollback/Contingency

Revert to using `efq A B` and `efq A B.neg` if any unexpected issues arise. Since this is a simple rename, git revert of the commit will restore original state.

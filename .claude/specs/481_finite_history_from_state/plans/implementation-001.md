# Implementation Plan: Task #481

- **Task**: 481 - finite_history_from_state
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None (all prerequisites exist)
- **Research Inputs**: .claude/specs/481_finite_history_from_state/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement the nullity proof for `SemanticCanonicalFrame` by extracting history witnesses from the quotient structure. The research identified that `SemanticWorldState` is defined as `Quotient (htSetoid phi)`, meaning every semantic world state already comes from a `(FiniteHistory, FiniteTime)` pair. Using `Quotient.out` to extract this witness eliminates the need for complex history construction. The plan includes an optional Phase 2 for implementing `finite_history_from_state` if needed elsewhere.

### Research Integration

Research report (research-001.md) identified:
- `Quotient.out` provides representative extraction for any quotient element
- `SemanticTaskRelV2.nullity` theorem exists at line 2104, requiring a witness
- `SemanticWorldState.ofHistoryTime` exists at line 2012 for constructing semantic world states
- Core nullity fix is 5-10 lines using existing infrastructure

## Goals & Non-Goals

**Goals**:
- Eliminate the `sorry` in `SemanticCanonicalFrame.nullity` (FiniteCanonicalModel.lean line 2375-2381)
- Use `Quotient.out` to extract witness history from any `SemanticWorldState`
- Ensure proof compiles without errors
- Optionally implement full `finite_history_from_state` if needed by other proofs

**Non-Goals**:
- Implementing full recursive history construction unless strictly required
- Optimizing for computational efficiency (correctness is priority)
- Addressing other sorries in FiniteCanonicalModel.lean (separate tasks)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Quotient.out not available or requires special import | Low | Low | Standard Mathlib - verify import exists |
| Type mismatch between Quotient.out result and SemanticTaskRelV2.nullity expectation | Medium | Low | Verify types match; may need coercion |
| Compositionality sorry blocks SemanticCanonicalFrame even after nullity fixed | Low | Medium | Compositionality is handled by existing theorem (task 482 for full proof) |

## Implementation Phases

### Phase 1: Fix SemanticCanonicalFrame.nullity [COMPLETED]

**Goal**: Eliminate the sorry in SemanticCanonicalFrame.nullity using Quotient.out

**Tasks**:
- [ ] Read current SemanticCanonicalFrame definition (line 2372-2384)
- [ ] Verify SemanticTaskRelV2.nullity signature and requirements (line 2104)
- [ ] Verify Quotient.out availability and usage pattern
- [ ] Implement nullity proof using Quotient.out to extract witness
- [ ] Verify no new errors introduced

**Timing**: 1 hour

**Files to modify**:
- `Logos/Core/Metalogic/FiniteCanonicalModel.lean` - Replace sorry in SemanticCanonicalFrame.nullity (~lines 2375-2381)

**Verification**:
- `lake build` succeeds with no new errors
- `lean_diagnostic_messages` shows no errors in SemanticCanonicalFrame
- The sorry is eliminated from the nullity field

---

### Phase 2: Implement finite_history_from_state (Optional) [SKIPPED]

**Goal**: Provide a general-purpose function to construct FiniteHistory from any FiniteWorldState if needed by other proofs

**Assessment Result**: NOT NEEDED for the primary goal (SemanticCanonicalFrame.nullity).

The nullity proof uses `Quotient.out` to extract a representative `(history, time)` pair
directly from the quotient structure of `SemanticWorldState`. This approach is simpler and
more elegant than constructing a new history from scratch.

`finite_history_from_state` may still be useful for `semantic_weak_completeness` (which uses
it in the proof sketch to convert a `FiniteWorldState` to a `SemanticWorldState`), but that
is a separate concern handled by Task 450 (completeness_theorems).

**Decision**: Skip this phase. The main objective (eliminating nullity sorry) is achieved.

---

## Testing & Validation

- [ ] `lake build` passes with no new errors
- [ ] `lean_diagnostic_messages` for FiniteCanonicalModel.lean shows no errors in SemanticCanonicalFrame
- [ ] The sorry count in SemanticCanonicalFrame.nullity is reduced to zero
- [ ] Verify SemanticCanonicalFrame can be instantiated

## Artifacts & Outputs

- Modified: `Logos/Core/Metalogic/FiniteCanonicalModel.lean` (nullity proof)
- Summary: `.claude/specs/481_finite_history_from_state/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If the implementation introduces unexpected errors:
1. Revert changes to FiniteCanonicalModel.lean using `git checkout`
2. Re-examine SemanticTaskRelV2.nullity requirements
3. Consider alternative witness extraction approaches
4. If Quotient.out approach fails, fall back to full finite_history_from_state construction

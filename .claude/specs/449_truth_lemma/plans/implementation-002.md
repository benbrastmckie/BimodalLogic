# Implementation Plan: Task #449

- **Task**: 449 - Truth Lemma
- **Version**: 002
- **Status**: [PLANNED]
- **Effort**: 8-12 hours (reduced from original 15-20)
- **Priority**: Low
- **Dependencies**: Task 448 (completed), Task 473 (completed), Task 481 (completed), Task 482 (partial)
- **Research Inputs**: .claude/specs/449_truth_lemma/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

This is plan v002, revised after completion of tasks 473, 481, and 482 (partial).

### What Changed Since v001

**Task 473 (Completed)**: Introduced SemanticWorldState architecture
- Created `SemanticWorldState` as quotient of (FiniteHistory, FiniteTime) pairs
- Created `SemanticTaskRelV2` with compositionality trivial by construction
- Created `semantic_truth_lemma_v2` proving membership ↔ truth for the semantic approach
- Created `SemanticCanonicalFrame` and `SemanticCanonicalModel`

**Task 481 (Completed)**: Fixed nullity sorry
- `SemanticCanonicalFrame.nullity` now proven via `Quotient.out`
- SemanticCanonicalFrame is now a valid TaskFrame instance

**Task 482 (Partial)**: History gluing infrastructure
- `glue_histories` function implemented with piecewise construction
- 3 acceptable sorries remain: edge case bounds assumptions (x ≥ 0, y > 0, neg case)
- These sorries are infrastructure gaps, not fundamental obstructions

### Strategic Pivot

**Old approach (v001)**: Complete `finite_truth_lemma` for FiniteWorldState
- Blocked by negation-completeness requirement
- 6 backward-direction sorries requiring MCS (maximal consistent set) properties
- Would require Task 472 (Lindenbaum extension) first

**New approach (v002)**: Use SemanticWorldState architecture from Task 473
- `semantic_truth_lemma_v2` already proven (line 2838)
- Focus on connecting semantic completeness to main completeness theorem
- The semantic approach sidesteps negation-completeness because world states ARE (quotients of) histories

### Remaining Work

1. ~~Prove closure infrastructure~~ - **DONE** (Phase 1 v001)
2. ~~Prove forward directions~~ - **DONE** (Phases 2-4 v001)
3. ~~Complete semantic infrastructure~~ - **DONE** (Task 473)
4. ~~Fix nullity~~ - **DONE** (Task 481)
5. Complete history gluing edge cases - **OPTIONAL** (Task 482 in progress)
6. **NEW**: Connect `semantic_weak_completeness` to main `weak_completeness` theorem
7. **NEW**: Verify old `finite_truth_lemma` can be deprecated or marked auxiliary

## Overview

Complete the truth lemma by connecting the semantic infrastructure (from Task 473) to the main completeness theorem. The semantic truth lemma (`semantic_truth_lemma_v2`) is already proven; this task focuses on using it to establish `semantic_weak_completeness` and connect to the final completeness result.

## Goals & Non-Goals

**Goals**:
- Prove `semantic_weak_completeness` theorem using `semantic_truth_lemma_v2`
- Connect semantic completeness to main `weak_completeness` theorem
- Document relationship between old `finite_truth_lemma` and new `semantic_truth_lemma_v2`
- Verify all truth lemma functionality is complete (for the semantic approach)

**Non-Goals**:
- Completing the old `finite_truth_lemma` backward directions (deprecated approach)
- Task 472 Lindenbaum extension (not needed for semantic approach)
- Resolving Task 482 edge case sorries (acceptable infrastructure gaps)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| semantic_weak_completeness harder than expected | Medium | Low | Use existing semantic infrastructure; proof should follow standard pattern |
| Connection to main completeness unclear | Medium | Medium | Review Task 450 plan and Completeness.lean structure |
| Task 482 sorries block downstream work | Low | Low | These are acceptable edge cases; completeness proof avoids them |

## Implementation Phases

### Phase 1: Analyze Current State [NOT STARTED]

**Goal**: Understand the current state of semantic completeness and identify exact gaps.

**Tasks**:
- [ ] Read `semantic_weak_completeness` axiom/sorry at current location
- [ ] Identify what `semantic_weak_completeness` needs to prove
- [ ] Verify `semantic_truth_lemma_v2` provides the necessary connection
- [ ] Check Completeness.lean to see how completeness connects to canonical model

**Timing**: 1-2 hours

**Files to examine**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - semantic infrastructure
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` - main completeness theorems

**Verification**:
- Document exactly which sorries need to be resolved
- List all dependencies between semantic and main completeness

---

### Phase 2: Prove semantic_weak_completeness [NOT STARTED]

**Goal**: Replace the `semantic_weak_completeness` axiom/sorry with a complete proof using `semantic_truth_lemma_v2`.

**Tasks**:
- [ ] Structure the proof: from ¬provable phi, construct SemanticCanonicalModel
- [ ] Use `semantic_truth_lemma_v2` to show phi is false at some state
- [ ] Show this gives a countermodel to validity
- [ ] Contrapositive gives: valid implies provable

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - semantic_weak_completeness

**Verification**:
- `semantic_weak_completeness` compiles without sorry
- lean_diagnostic_messages shows no new errors

---

### Phase 3: Connect to Main Completeness [NOT STARTED]

**Goal**: Connect `semantic_weak_completeness` to the main `weak_completeness` theorem in Completeness.lean.

**Tasks**:
- [ ] Review how main completeness uses canonical model
- [ ] If needed, add bridge lemmas between SemanticCanonicalModel and expected model type
- [ ] Update or add imports as needed
- [ ] Verify `weak_completeness` can use semantic results

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` - if bridge needed
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - if bridge needed

**Verification**:
- Connection compiles without sorry
- Main completeness theorem can be proven using semantic infrastructure

---

### Phase 4: Documentation and Cleanup [NOT STARTED]

**Goal**: Document the relationship between old and new approaches, mark deprecated code.

**Tasks**:
- [ ] Add docstrings explaining semantic vs syntactic approaches
- [ ] Mark `finite_truth_lemma` as deprecated/auxiliary with TODO note
- [ ] Update module documentation to reflect semantic approach
- [ ] Run `lake build` to verify no regressions

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - documentation

**Verification**:
- `lake build` succeeds
- All semantic infrastructure documented
- Clear path forward for Task 450 (completeness theorems)

---

## Testing & Validation

- [ ] `semantic_weak_completeness` compiles without sorry
- [ ] lean_diagnostic_messages shows no new errors in FiniteCanonicalModel.lean
- [ ] Connection to main completeness clear and documented
- [ ] `lake build` succeeds
- [ ] Task 450 unblocked (dependencies satisfied)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - semantic_weak_completeness proven
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` - connection to main theorem (if needed)
- `.claude/specs/449_truth_lemma/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If semantic_weak_completeness proves difficult:
1. Document exactly what's missing in semantic infrastructure
2. Consider whether Task 482 completion would help
3. Create subtask for specific blocking issue

If connection to main completeness is non-trivial:
1. Document the gap in Completeness.lean
2. Create bridge lemma as separate helper
3. May need Task 450 to be revised accordingly

## Dependency Graph

```
Task 448 (consistent model) ──┐
                              │
Task 458 (compositionality)───┼──> Task 473 (semantic infrastructure) ──> Task 481 (nullity)
                              │           │
                              │           └──> Task 482 (gluing) [partial]
                              │           │
                              │           └──> Task 449 v002 (THIS) ──> Task 450 (completeness)
                              │
Task 472 (Lindenbaum) ────────┘  [NOT NEEDED for semantic approach]
```

## Notes

The key insight from Task 473 is that defining world states as quotients of (history, time) pairs makes the truth lemma trivial by construction. The semantic world state IS a history at a time, so "membership in the state equals truth" becomes definitional.

The old `finite_truth_lemma` remains in the codebase with 6 sorries. It's not blocking progress because:
1. The semantic approach (`semantic_truth_lemma_v2`) is complete
2. The semantic canonical model (`SemanticCanonicalModel`) is well-defined
3. Completeness can proceed via the semantic route

The old approach could be completed if Task 472 (Lindenbaum extension) is done, but this is no longer on the critical path for completeness.

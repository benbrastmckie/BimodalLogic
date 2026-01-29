# Implementation Plan: Task #616

- **Task**: 616 - Remove mathematically false theorem semantic_task_rel_compositionality
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/616_remove_false_semantic_task_rel_compositionality/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove the mathematically false theorem `semantic_task_rel_compositionality` from `SemanticCanonicalModel.lean` in the Boneyard. Research confirmed this theorem cannot be proven (unbounded duration sums exceed the finite time domain `[-k, k]`), and it is not needed for the completeness proof which uses a different approach (`semantic_weak_completeness` via `semantic_truth_at_v2`). The sorry should be inlined into the `SemanticCanonicalFrame` definition to maintain code honesty rather than having a named theorem that claims something false.

### Research Integration

From research-001.md:
- The theorem is **mathematically false**: duration sums `d1 + d2` can exceed `[-2k, 2k]` when both are near `2k`
- **Concrete counterexample**: With `k=1`, `d1=2`, `d2=2`, `d1+d2=4` requires witness times with difference 4, but max difference in `[-1,1]` is 2
- The `semantic_weak_completeness` proof (lines 619-683) is **sorry-free** and does not use this theorem
- The theorem is documented in Boneyard/README.md as a known limitation

## Goals & Non-Goals

**Goals**:
- Remove the false theorem `semantic_task_rel_compositionality` and its 30-line docstring
- Inline the sorry directly into `SemanticCanonicalFrame` with a brief comment
- Update file documentation to reflect the removal
- Maintain build integrity (file should still compile)

**Non-Goals**:
- Proving a bounded variant of compositionality (out of scope for removal task)
- Modifying the completeness proof (already works without this theorem)
- Changing the `TaskFrame` structure requirements

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking downstream imports | Low | Low | File is in Boneyard (deprecated); check Demo.lean import still works |
| Losing documentation about the limitation | Medium | Medium | Add brief comment at sorry site explaining why |

## Implementation Phases

### Phase 1: Remove theorem and update frame construction [COMPLETED]

**Goal**: Remove the false theorem and inline sorry into SemanticCanonicalFrame

**Tasks**:
- [ ] Remove lines 209-254: theorem `semantic_task_rel_compositionality` and its docstring
- [ ] Update `SemanticCanonicalFrame` (line 267) to use inline sorry with comment
- [ ] Update file header comment (line 41) about known sorries
- [ ] Verify file compiles with `lake build`

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean`
  - Remove: Lines 209-254 (theorem and docstring)
  - Modify: Line 267 (use inline sorry)
  - Modify: Line 41 (update sorry documentation)

**Verification**:
- File compiles without errors
- No new sorries introduced (count should decrease by 0, inline replaces named)
- `semantic_weak_completeness` still proven (unaffected)

---

### Phase 2: Update related documentation [COMPLETED]

**Goal**: Ensure documentation reflects the removal

**Tasks**:
- [ ] Update `Boneyard/README.md` to note theorem was removed (not just deprecated)
- [ ] Check `Boneyard/DeprecatedCompleteness.lean` for references
- [ ] Verify Metalogic_v2/README.md is accurate

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/README.md` - Update line 74 about the sorry
- `Theories/Bimodal/Boneyard/DeprecatedCompleteness.lean` - Check for theorem references

**Verification**:
- Documentation accurately describes current state
- No references to removed theorem remain in documentation

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] Demo.lean still compiles (imports SemanticCanonicalModel)
- [ ] `semantic_weak_completeness` remains sorry-free
- [ ] No broken references in Boneyard

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified `SemanticCanonicalModel.lean` with theorem removed
- Updated `Boneyard/README.md` documentation
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If removal causes unexpected build failures:
1. Restore theorem from git history
2. Document why removal failed
3. Consider alternative: rename theorem to `semantic_task_rel_compositionality_UNSOUND` with explicit warning

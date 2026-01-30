# Implementation Plan: Task #779 (Revised)

- **Task**: 779 - prove_weak_completeness_sorry_free
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/779_archive_weak_completeness_for_sorry_free_metalogic/reports/research-002.md, summaries/implementation-summary-20260130.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revision Reason**: The original approach (semantic model embedding) failed due to an architectural gap. Implementation-001.md revealed that the gap between `valid` and `semantic_truth_at_v2` is unbridgeable for arbitrary world states.

**New Approach**: Instead of trying to prove `weak_completeness` sorry-free (which is architecturally impossible), this revision documents the correct usage pattern and cleans up the codebase:

1. `semantic_weak_completeness` IS the sorry-free completeness theorem (already exists)
2. `weak_completeness` retains its sorry as documentation of the semantic gap
3. Clean up exploratory code from the failed approach

### Key Finding from v001 Implementation

The sorry in `weak_completeness` exists because:
- `valid phi` quantifies over ALL models (recursive truth evaluation)
- `semantic_weak_completeness` requires truth at SemanticWorldStates (assignment-based)
- These only coincide for MCS-derived states, not arbitrary locally-consistent ones

This is NOT a proof difficulty - it's an architectural gap between two semantic frameworks.

## Goals & Non-Goals

**Goals**:
- Document that `semantic_weak_completeness` is the canonical sorry-free completeness theorem
- Clean up exploratory files from the failed approach (SemanticTruthCorrespondence.lean)
- Update documentation to clarify the two completeness results
- Ensure all module docstrings correctly direct users to `semantic_weak_completeness`

**Non-Goals**:
- Remove the sorry from `weak_completeness` (architecturally impossible)
- Change the definition of `valid` (would alter theorem meaning)
- Deprecate `weak_completeness` (still useful for theoretical exposition)

## Implementation Phases

### Phase 1: Clean Up Exploratory Code [NOT STARTED]

**Goal**: Remove or archive code from the failed approach.

**Tasks**:
- [ ] Review `SemanticTruthCorrespondence.lean` - determine if any parts are useful
- [ ] If useful: keep only genuinely helpful lemmas, remove sorried gap documentation
- [ ] If not useful: archive to Boneyard or delete
- [ ] Remove the import from `FMP.lean` if file is archived
- [ ] `lake build` to verify clean compilation

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticTruthCorrespondence.lean` - Archive or clean
- `Theories/Bimodal/Metalogic/FMP.lean` - Remove import if needed

**Verification**:
- `lake build` succeeds with no errors
- No new sorries introduced in active Theories/

---

### Phase 2: Update Documentation [NOT STARTED]

**Goal**: Ensure documentation clearly directs users to `semantic_weak_completeness`.

**Tasks**:
- [ ] Review WeakCompleteness.lean docstring - ensure it's clear and accurate
- [ ] Review FMP/README.md - confirm it highlights `semantic_weak_completeness`
- [ ] Review Metalogic/README.md - verify architectural gap is explained
- [ ] Check for any misleading documentation that suggests `weak_completeness` can be made sorry-free

**Timing**: 0.5 hours

**Files to review/modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Docstring
- `Theories/Bimodal/Metalogic/FMP/README.md`
- `Theories/Bimodal/Metalogic/README.md`

**Verification**:
- Documentation accurately describes the architectural situation
- Users are directed to `semantic_weak_completeness` for sorry-free proofs

---

### Phase 3: Verify Repository State [NOT STARTED]

**Goal**: Confirm the repository reflects correct completeness architecture.

**Tasks**:
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/Completeness/` - document count
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/` - ensure SemanticCanonicalModel is clean
- [ ] Verify `semantic_weak_completeness` is truly sorry-free via `#print axioms`
- [ ] Update specs/state.json repository_health if sorry count changed

**Timing**: 0.5 hours

**Verification**:
- `semantic_weak_completeness` has no sorry dependencies
- Repository sorry count is accurate

---

### Phase 4: Task Resolution [NOT STARTED]

**Goal**: Properly close this task with accurate summary.

**Tasks**:
- [ ] Write implementation summary documenting:
  - Original goal was unachievable (architectural gap)
  - `semantic_weak_completeness` already provides sorry-free completeness
  - Any cleanup performed
- [ ] Update task description if needed to reflect outcome

**Timing**: 0.5 hours

**Files to create**:
- `specs/779_archive_weak_completeness_for_sorry_free_metalogic/summaries/implementation-summary-v2-{DATE}.md`

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `#print axioms Bimodal.Metalogic.FMP.semantic_weak_completeness` shows no sorry
- [ ] Documentation is accurate and helpful
- [ ] No regression in sorry count for active Theories/

## Artifacts & Outputs

- Updated documentation in Metalogic/
- Cleaned up SemanticTruthCorrespondence.lean (if applicable)
- Implementation summary documenting the architectural situation

## Outcome

This task will be marked COMPLETED with the understanding that:
1. The original goal (sorry-free `weak_completeness`) is architecturally impossible
2. `semantic_weak_completeness` IS the sorry-free completeness theorem and has been for some time
3. The codebase correctly reflects this architecture

The "completion" is acknowledging reality rather than achieving the originally stated goal.

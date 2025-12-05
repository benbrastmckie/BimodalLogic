# TODO.md - Logos Task Tracking

## Overview

This file tracks active development tasks for Logos. Completed tasks are removed from this file - see git history and spec summaries for completion records.

**Layer 0 Completion Progress**:
- High Priority: COMPLETE (all blocking tasks done)
- Medium Priority: 3 active tasks (16, 17, and remaining Task 7 work)
- Low Priority: 4 tasks pending (9, 10, 11, 13)
- **Active Tasks**: 7

**Next Milestone**: Complete temporal refactor bug fixes (Tasks 16, 17)

---

## Quick Links

- [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking
- [KNOWN_LIMITATIONS.md](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) - Current gaps and workarounds
- [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders)
- [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) - TODO management workflow

**Active Implementation Plan**:
- [TODO Implementation Systematic Plan](.claude/specs/019_research_todo_implementation_plan/plans/001-research-todo-implementation-plan.md)
  - Wave 1-2: COMPLETE (High priority foundations, Perpetuity proofs, transport lemmas)
  - Wave 3-4: NOT STARTED (Completeness proofs, future work)

---

## High Priority Tasks

*No active high priority tasks. All blocking work complete.*

---

## Medium Priority Tasks

### 7. Implement Core Automation - Remaining Work
**Effort**: 30-40 hours (remaining)
**Status**: PARTIAL COMPLETE (4/12 tactics implemented, 33%)
**Priority**: Medium (developer productivity)
**Blocking**: None
**Dependencies**: None

**Description**: Complete remaining automation work blocked by Aesop integration issue.

**Completed** (2025-12-03):
- `apply_axiom` macro (generic axiom application)
- `modal_t` macro (modal T axiom convenience)
- `tm_auto` macro (native implementation using `first` combinator)
- `assumption_search` elab (TacticM context search)
- 4 helper functions (is_box_formula, is_future_formula, extract_from_box, extract_from_future)
- 31 tests in `LogosTest/Automation/TacticsTest.lean`

**Blocker**: Aesop integration blocked by Batteries dependency breaking Truth.lean.

**Remaining Work**:
- Fix Truth.lean for Batteries compatibility (4-8 hours)
- Complete Aesop integration (6-8 hours)
- Implement remaining 8 tactics (30-40 hours)
- Expand test suite to 50+ tests (5-10 hours)

**Files**:
- `Logos/Core/Automation/Tactics.lean` (175 lines, working tactics)
- `Logos/Core/Automation/ProofSearch.lean` (axiom stubs)
- `LogosTest/Automation/TacticsTest.lean` (31 tests)

**Reference**: [Implementation Summary](.claude/specs/025_soundness_automation_implementation/summaries/004_iteration_3_final_summary.md)

---

### 13. Create Proof Strategy Documentation
**Effort**: 5-10 hours
**Status**: Not Started
**Priority**: Medium (pedagogical value for new users)
**Blocking**: None
**Dependencies**: Benefits from completed proofs (more examples available)

**Description**: Create Archive/ examples demonstrating common proof strategies and patterns for TM derivations. Provides pedagogical value for new users, students, and researchers learning TM logic and Logos usage.

**Files to Create**:
- `Archive/ModalProofStrategies.lean`
- `Archive/TemporalProofStrategies.lean`
- `Archive/BimodalProofStrategies.lean`

**Action Items**:
1. Create `ModalProofStrategies.lean` with S5 modal proof patterns (necessity chains, possibility proofs, modal modus ponens)
2. Create `TemporalProofStrategies.lean` with temporal reasoning patterns (always/eventually proofs, induction over time, temporal duality)
3. Create `BimodalProofStrategies.lean` with modal-temporal interaction patterns (perpetuity principles, frame reasoning, task relation proofs)
4. Document common proof techniques in extensive comments
5. Update `Archive/Archive.lean` to re-export new modules

**Reference**: Best practices report (.claude/specs/021_lean4_bimodal_logic_best_practices/reports/001-lean-4-modal-logic-implementation-best.md) lines 649-675

---

### 16. Fix Perpetuity Theorem Logic Errors
**Effort**: 4-6 hours
**Status**: Not Started
**Priority**: Medium (correctness bug discovered during temporal refactor)
**Blocking**: None (Task 14 Phase 2 complete)
**Dependencies**: None

**Description**: The Perpetuity.lean theorems have logic errors - they incorrectly assumed `triangle phi = F phi` when the correct definition is `triangle phi = H phi and phi and G phi` (equivalently `all_past phi and phi and all_future phi`). This was exposed during the temporal constructor rename in Task 14.

**Affected Theorems**:
- `perpetuity_1` (P1: `box phi -> triangle phi`) - Proof uses MF axiom but triangle phi is not the same as G phi
- `perpetuity_3` (P3: `box phi -> box (triangle phi)`) - Proof claims MF axiom is "exactly" this, but types don't match

**Incorrect Comments to Fix**:
- `Logos/Core/Theorems/Perpetuity.lean:127`: "triangle phi = F phi (since always = future)" - WRONG
- `Logos/Core/Theorems/Perpetuity.lean:177`: "nabla phi = neg(future (neg phi))" - WRONG
- `Logos/Core/Theorems/Perpetuity.lean:183-185`: Claims about future operator - WRONG
- `Logos/Core/Theorems/Perpetuity.lean:202`: "triangle phi = F phi" - WRONG
- `Logos/Core/Theorems/Perpetuity.lean:205`: "box(triangle phi) = box(F phi)" - WRONG

**Correct Definitions**:
- `triangle phi` (always phi) = `H phi and phi and G phi` = `all_past phi and phi and all_future phi`
- `nabla phi` (sometimes phi) = `neg(always (neg phi))` = `P phi or phi or F phi` (dual)

**Action Items**:
1. Update all incorrect comments to use correct definitions
2. Fix P1 theorem proof (need to derive full conjunction, not just G phi)
3. Fix P3 theorem proof (MF gives `box phi -> box (G phi)`, need to extend to full triangle phi)
4. Verify P2, P4, P5, P6 proofs are still correct under new understanding
5. Run `lake build` to verify all changes compile

**Files**:
- `Logos/Core/Theorems/Perpetuity.lean`

---

### 17. Fix Pre-existing Soundness.lean Type Mismatch Errors
**Effort**: 2-4 hours
**Status**: Not Started
**Priority**: Medium (pre-existing bug, not blocking)
**Blocking**: None
**Dependencies**: None

**Description**: Pre-existing type mismatch errors in Soundness.lean at lines 501 and 545 in the `temporal_k` and `weakening` soundness cases. These errors existed before the temporal refactor and are unrelated to Task 14.

**Error Details**:
```
error: ././././Logos/Core/Metalogic/Soundness.lean:501:15: application type mismatch
  ih F M
argument M has type LinearOrderedAddCommGroup F : Type
but is expected to have type TaskFrame F : Type 1
```

**Affected Code**:
- `Soundness.lean:501` - `temporal_k` case
- `Soundness.lean:545` - `weakening` case

**Root Cause**: The variable `F` is being shadowed or type inference is failing due to the polymorphic temporal domain generalization (Task 15).

**Action Items**:
1. Investigate type shadowing in soundness theorem cases
2. Add explicit type annotations where needed
3. Verify fixes don't break other proofs
4. Run full `lake build`

**Files**:
- `Logos/Core/Metalogic/Soundness.lean`

---

## Low Priority Tasks

### 9. Begin Completeness Proofs
**Effort**: 70-90 hours
**Status**: Not Started
**Priority**: Low (long-term metalogic goal)
**Blocking**: None
**Dependencies**: Benefits from completed soundness proofs

**Description**: Implement canonical model construction and prove completeness theorems (weak and strong). This is a major undertaking requiring significant effort.

**Phases**:
1. **Phase 1** (20-30 hours): Prove Lindenbaum lemma and maximal set properties
2. **Phase 2** (20-30 hours): Construct canonical model components
3. **Phase 3** (20-30 hours): Prove truth lemma and completeness theorems

**Files**:
- `Logos/Core/Metalogic/Completeness.lean` (11 axiom declarations requiring proofs)

**Technical Debt**: See [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) for detailed resolution guidance.

**Notes**: This is the largest remaining task for Layer 0 completion. Can be deferred to Layer 1 planning phase.

---

### 10. Create Decidability Module
**Effort**: 40-60 hours
**Status**: Not Started
**Priority**: Low (future enhancement, not in MVP)
**Blocking**: None
**Dependencies**: Requires Task 9 (completeness proofs for correctness)

**Description**: Create Logos/Core/Metalogic/Decidability.lean module with tableau method for validity checking and satisfiability decision procedures.

**Phases**:
1. **Phase 1** (15-20 hours): Design decidability architecture
2. **Phase 2** (15-20 hours): Implement tableau method
3. **Phase 3** (10-20 hours): Prove correctness and complexity

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (does not exist, planned)

**Notes**: Planned but not essential for Layer 0. Can be deferred to Layer 1 or beyond.

---

### 11. Plan Layer 1/2/3 Extensions
**Effort**: 20-40 hours (research phase)
**Status**: Not Started
**Priority**: Low (future work, after Layer 0 complete)
**Blocking**: None
**Dependencies**: Requires Layer 0 completion

**Description**: Design and plan extensions beyond Core TM (Layer 0): counterfactual operators (Layer 1), epistemic operators (Layer 2), normative operators (Layer 3).

**Action Items**:
1. **Layer 1 (Counterfactuals)**: Design `box_c` (would-counterfactual) and `diamond_m` (might-counterfactual) operators
2. **Layer 2 (Epistemic)**: Design `K` (knowledge) and `B` (belief) operators
3. **Layer 3 (Normative)**: Design `O` (obligation) and `P` (permission) operators
4. Create implementation plans for each layer
5. Update ARCHITECTURE.md with layer design

**Notes**: Strategic planning for post-MVP development. Should not begin until Layer 0 is complete and tested.

---

## Completion History

Completed tasks are tracked via git history. Query completion records:

```bash
# View all task completions
git log --all --grep="Complete Task" --oneline

# Find when specific task completed
git log --all --grep="Task 7" --oneline

# View spec summaries for detailed completion narratives
find .claude/specs -name "*summary*.md" | head -20

# Search summaries for task
grep -r "Task 5" .claude/specs/*/summaries/
```

See [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) for complete workflow documentation.

---

## Project References

- **Module Status**: [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) for detailed module-by-module tracking
- **Gap Documentation**: [KNOWN_LIMITATIONS.md](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) for current limitations and workarounds
- **System Design**: [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md) for TM logic specification
- **Technical Debt**: [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) for sorry placeholder tracking

**Notes**:
- Priority levels reflect blocking status and estimated timeline, not importance
- Effort estimates are conservative and may vary based on implementation complexity
- Dependencies are indicated inline with each task

---

**Last Updated**: 2025-12-05 (Refactored to Git-based history model)

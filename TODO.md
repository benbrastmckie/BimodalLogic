# TODO.md - Logos Task Tracking

## Update Instructions

**When to Update**: After completing tasks, discovering new work, or changing priorities.

**How to Update**:
1. Mark completed tasks by removing them from active sections (history tracked via git)
2. Add new tasks with: description, effort estimate, status, priority, blocking/dependencies
3. Update the "Active Tasks" count in Overview
4. Update "Last Updated" date at bottom
5. Run `/todo` command to sync with .claude/TODO.md specs tracking

**What NOT to Track Here**:
- Completed task details (use git history: `git log --grep="Task"`)
- Implementation plans (use `.claude/specs/` directories)
- Module-by-module status (use IMPLEMENTATION_STATUS.md)
- Technical debt details (use SORRY_REGISTRY.md)

---

## Overview

This file tracks active development tasks for Logos. Completed tasks are removed from this file - see git history and spec summaries for completion records.

**Layer 0 Completion Progress**:
- High Priority: COMPLETE (all blocking tasks done)
- Medium Priority: COMPLETE (all 6 perpetuity theorems proven - P1-P6!)
- Low Priority: 3 tasks (9-11 pending, 21 skipped)
- **Active Tasks**: 3

**Milestone Achievement**: ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN (100%)
**Next Milestone**: Task 9 (Completeness proofs)

---

## Quick Links

- [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking
- [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) - Current gaps and workarounds
- [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders)
- [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) - TODO management workflow

**Active Implementation Plan**:
- [TODO Implementation Systematic Plan](.claude/specs/019_research_todo_implementation_plan/plans/001-research-todo-implementation-plan.md)
  - Wave 1-2: COMPLETE (High priority foundations, Perpetuity proofs, transport lemmas)
  - Wave 3-4: NOT STARTED (Completeness proofs, future work)

**Recently Completed**:
- [Minimal Axiom Review Plan](.claude/specs/048_minimal_axiom_review_proofs/plans/001-minimal-axiom-review-proofs-plan.md) - Documentation fixes, necessitation from MK, MK/TK documentation

---

## High Priority Tasks

*No active high priority tasks. All blocking work complete.*

---

## Medium Priority Tasks

### 21. Derive Pairing Combinator
*Effort**: 8-12 hours
*Status**: SKIPPED
*Priority**: Low (optional, adds no mathematical insight)
*Blocking**: None
*Dependencies**: None

**Description**: Derive the `pairing` axiom (`⊢ A.imp (B.imp (A.and B))`) from K and S propositional axioms using combinator calculus. Strategy: Build S(S(KS)(S(KK)I))(KI) where I=SKK.

**Current Status**: Left as `axiom pairing` per plan recommendation. Semantic justification is sufficient, and the ~40+ line derivation adds no mathematical insight.

**Recommendation**: Keep axiomatized unless zero-axiom footprint is specifically required.

**Plan Reference**: [Task 18 Plan - Phase 5](.claude/specs/047_remove_derivable_axioms_perpetuity/plans/001-remove-derivable-axioms-perpetuity-plan.md#phase-5-pairing-derivation-skipped)

## Low Priority Tasks

---

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
- **Gap Documentation**: [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) for current limitations and workarounds
- **System Design**: [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md) for TM logic specification
- **Technical Debt**: [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) for sorry placeholder tracking

**Notes**:
- Priority levels reflect blocking status and estimated timeline, not importance
- Effort estimates are conservative and may vary based on implementation complexity
- Dependencies are indicated inline with each task

---

**Last Updated**: 2025-12-09 (ALL 6 PERPETUITY PRINCIPLES PROVEN - Tasks 18, 19, 20 COMPLETE)

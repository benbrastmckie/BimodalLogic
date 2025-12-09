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
- Medium Priority: Task 18 PARTIAL (4/6 perpetuity theorems proven)
- Low Priority: 5 tasks (9-11 pending, 19-20 blocked, 21 skipped)
- **Active Tasks**: 6

**Next Milestone**: Task 9 (Completeness proofs) or Layer 1 planning

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

### 18. Remove Derivable Axioms from Perpetuity.lean
**Effort**: 12-18 hours (cumulative)
**Status**: PARTIAL (Phases 1-2 Complete, Phases 3-4 Blocked)
**Priority**: Medium (reduces axiomatic footprint)
**Blocking**: None
**Dependencies**: Phases build on each other sequentially

**Description**: Phases 7-9 of the perpetuity theorem plan were skipped for MVP, leaving P4-P6 as axioms. These can be derived from the now-complete P1-P3 proofs. Additionally, the `pairing` and `contraposition` helpers are either axiomatized or use sorry.

**Goal**: Remove all unnecessary axioms that can be syntactically derived, reducing the axiomatic footprint to only semantically necessary primitives.

**Status Summary**:
- **Phase 1**: ✓ COMPLETE - `contraposition` proven via B combinator (zero sorry)
- **Phase 2**: ✓ COMPLETE - P4 derived from P3 via contraposition (zero sorry)
- **Phase 3**: ✗ BLOCKED - P5 requires S5 axiom `◇φ → □◇φ` not in TM base system
- **Phase 4**: ✗ BLOCKED - P6 depends on P5
- **Phase 5**: SKIPPED - Optional `pairing` derivation (low priority)

**Results**:
- P1, P2, P3, P4: Fully proven (zero sorry) ✓
- P5, P6: Axiomatized (blocked by S5 axiom gap)
- Axiom count reduced from 6 to 4 (pairing, dni, perpetuity_5, perpetuity_6)
- Sorry count: 1 (persistence lemma blocked by S5 axiom gap)
- Necessitation proven derivable from MK (Derivation.lean)
- Documentation corrected: 8/8 inference rules proven (was incorrectly stated as 4/8)

**Completed Phases**:

1. ✓ **Complete `contraposition` proof** (DONE)
   - File: `Logos/Core/Theorems/Perpetuity.lean:336`
   - Result: Theorem proven using B combinator construction
   - Helper: `b_combinator` theorem added
   - Status: Zero sorry ✓

2. ✓ **Derive P4 from P3** (DONE)
   - File: `Logos/Core/Theorems/Perpetuity.lean:666`
   - Result: Theorem derived via contraposition of P3
   - Helper: `dni` axiom added for double negation introduction
   - Status: Zero sorry ✓

**Blocked Phases**:

3. ✗ **Derive P5 from P4** (BLOCKED)
   - File: `Logos/Core/Theorems/Perpetuity.lean:854`
   - Current: `axiom perpetuity_5`
   - Blocker: Requires S5 axiom `◇φ → □◇φ` not in TM base system
   - Status: Axiomatized with semantic justification (Corollary 2.11)

4. ✗ **Derive P6 from P5** (BLOCKED)
   - File: `Logos/Core/Theorems/Perpetuity.lean:921`
   - Current: `axiom perpetuity_6`
   - Blocker: Depends on P5
   - Status: Axiomatized with semantic justification (Corollary 2.11)

**Skipped Phases**:

5. **Derive `pairing` from K and S** (SKIPPED - optional, low priority)
   - File: `Logos/Core/Theorems/Perpetuity.lean:169`
   - Current: `axiom pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))`
   - Strategy: Build from S(S(KS)(S(KK)I))(KI) where I=SKK
   - Note: Complex combinator construction (~40+ lines), semantically justified as-is

**Implementation Plan**: See `.claude/specs/047_remove_derivable_axioms_perpetuity/plans/001-remove-derivable-axioms-perpetuity-plan.md`

**Success Criteria**:
- Zero axioms in Perpetuity.lean except optional `pairing`
- Zero sorry markers in Perpetuity.lean
- All perpetuity principles P1-P6 as theorems
- `lake build` succeeds
- Existing tests pass

**Plan Reference**: `.claude/specs/045_perpetuity_theorem_logic_fix/plans/001-perpetuity-theorem-logic-fix-plan.md` (Phases 7-9 sketches)

---

### 19. Derive P5 Perpetuity Theorem (Blocked by S5 Axiom Gap)
**Effort**: 8-12 hours (if S5 axiom added)
**Status**: BLOCKED
**Priority**: Low (requires extending TM axiom system)
**Blocking**: S5 axiom `◇φ → □◇φ` not in base TM system
**Dependencies**: Requires decision to extend modal axiom system

**Description**: Derive P5 (`◇▽φ → △◇φ`, persistent possibility) as a theorem instead of axiom. Currently blocked because the persistence lemma `◇φ → △◇φ` requires lifting from MB axiom `φ → □◇φ`, which needs the S5 characteristic `◇φ → □◇φ`.

**Current Status**: P5 remains as `axiom perpetuity_5` with semantic justification (Corollary 2.11).

**Options to Unblock**:
1. Add S5 axiom `◇φ → □◇φ` to base TM system (extends modal logic)
2. Find alternative derivation strategy not requiring S5
3. Accept axiomatization as sufficient (current approach)

**Plan Reference**: [Task 18 Plan - Phase 3](.claude/specs/047_remove_derivable_axioms_perpetuity/plans/001-remove-derivable-axioms-perpetuity-plan.md#phase-3-derive-p5-using-persistence-lemma-blocked)

---

### 20. Derive P6 Perpetuity Theorem (Blocked by P5 Dependency)
**Effort**: 4-8 hours (if P5 proven)
**Status**: BLOCKED
**Priority**: Low (depends on Task 19)
**Blocking**: P5 must be a proven theorem, not axiom
**Dependencies**: Task 19 (P5 derivation)

**Description**: Derive P6 (`▽□φ → □△φ`, occurrent necessity is perpetual) as a theorem instead of axiom. Derivation strategy uses P5 on `¬φ` with operator duality and contraposition, but requires P5 to be a proven theorem.

**Current Status**: P6 remains as `axiom perpetuity_6` with semantic justification (Corollary 2.11).

**Plan Reference**: [Task 18 Plan - Phase 4](.claude/specs/047_remove_derivable_axioms_perpetuity/plans/001-remove-derivable-axioms-perpetuity-plan.md#phase-4-derive-p6-from-p5-blocked)

---

### 21. Derive Pairing Combinator
**Effort**: 8-12 hours
**Status**: SKIPPED
**Priority**: Low (optional, adds no mathematical insight)
**Blocking**: None
**Dependencies**: None

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

**Last Updated**: 2025-12-08 (Minimal Axiom Review complete - documentation fixed to 8/8 rules, necessitation from MK proven, MK/TK documentation updated)

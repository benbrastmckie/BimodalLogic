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
- High Priority: 2 tasks active (Axiom Refactoring, Inference Rule Refactoring)
- Medium Priority: 1 task active (Proof Automation Completion - partial)
- Low Priority: 3 tasks (9-11 pending)
- **Active Tasks**: 6

**Milestone Achievement**: ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN (100%) + PHASE 4 MODAL THEOREMS COMPLETE (8/8) + PROPOSITIONAL THEOREMS COMPLETE (Tasks 21-29)
**Current Work**: Foundational refactoring (Tasks 43-44) - axiom and inference rule modernization
**Next Milestone**: Complete axiom/rule refactoring, then Layer 1 planning

---

## Quick Links

- [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking
- [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) - Current gaps and workarounds
- [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders)
- [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) - TODO management workflow

**Active Implementation Plan**:
- [Proof Automation Completion Plan](.claude/specs/065_proof_automation_temporal_deduction/plans/001-proof-automation-completion-plan.md)
  - Phase 1: COMPLETE (Helper lemma infrastructure)
  - Phase 5: COMPLETE (Tactic consolidation with factory patterns)
  - Phases 2, 3, 4: BLOCKED (circular dependency, recursion expertise needed)

**Recently Completed**:
- [Proof Automation Completion Plan](.claude/specs/065_proof_automation_temporal_deduction/plans/001-proof-automation-completion-plan.md) - 2/5 phases complete (2025-12-10)
- [Modal Theorems Alternative Proofs Plan](.claude/specs/060_modal_theorems_alternative_proofs/plans/001-modal-theorems-alternative-proofs-plan.md) - All Phase 4 modal theorems complete (8/8) using k_dist_diamond
- [Modal Theorems S5 Completion Plan](.claude/specs/059_modal_theorems_s5_completion/plans/001-modal-theorems-s5-completion-plan.md) - De Morgan laws (superseded by Plan 060)
- [Minimal Axiom Review Plan](.claude/specs/048_minimal_axiom_review_proofs/plans/001-minimal-axiom-review-proofs-plan.md) - Documentation fixes, necessitation from MK, MK/TK documentation

---

## High Priority Tasks

### 43. Axiom Refactoring: Replace DNE with EFQ + Peirce's Law
**Effort**: 8-12 hours
**Status**: Not Started
**Priority**: High (foundational change)
**Blocking**: None
**Dependencies**: None

**Description**: Replace the `double_negation` axiom with two more foundational axioms that better reflect the primitive status of `bot`:

1. **Ex Falso Quodlibet (EFQ)**: `⊥ → φ` - directly characterizes what `bot` means as absurdity
2. **Peirce's Law**: `((φ → ψ) → φ) → φ` - pure implicational classical reasoning

**Rationale**: Since `bot` is primitive and `neg` is derived (`¬φ = φ → ⊥`), EFQ directly states what `bot` means, while Peirce provides classical logic using only implication. This is more modular than DNE which conflates both concerns.

**Implementation Steps**:
1. Add `ex_falso` and `peirce` axiom constructors to `Axioms.lean`
2. Remove `double_negation` axiom constructor
3. Update soundness proofs in `Soundness.lean` (add EFQ/Peirce validity, remove DNE)
4. Derive DNE as a theorem from EFQ + Peirce (for backwards compatibility)
5. Update all proofs that use `double_negation` to use the derived theorem
6. Update documentation and tests

**Files**:
- `Logos/Core/ProofSystem/Axioms.lean` - Add EFQ, Peirce; remove DNE
- `Logos/Core/Metalogic/Soundness.lean` - Update validity proofs
- `Logos/Core/Theorems/Propositional.lean` - Add derived DNE theorem
- `LogosTest/ProofSystem/AxiomsTest.lean` - Update tests

---

### 44. Inference Rule Refactoring: Standard Necessitation + K Distribution
**Effort**: 12-16 hours
**Status**: Not Started
**Priority**: High (foundational change)
**Blocking**: None
**Dependencies**: None (can be done in parallel with Task 43)

**Description**: Replace the generalized necessitation rules (`modal_k` and `temporal_k`) with standard textbook-style rules:

**Modal Logic Changes**:
1. Replace `modal_k` rule (`Γ ⊢ φ` ⟹ `□Γ ⊢ □φ`) with:
   - **Necessitation**: `⊢ φ` ⟹ `⊢ □φ` (only from empty context)
   - **K axiom**: Already exists as `modal_k_dist`: `□(φ → ψ) → (□φ → □ψ)`

**Temporal Logic Changes**:
2. Replace `temporal_k` rule (`Γ ⊢ φ` ⟹ `GΓ ⊢ Gφ`) with:
   - **Temporal Necessitation**: `⊢ φ` ⟹ `⊢ Gφ` (only from empty context)
   - **Temporal K Distribution axiom**: `G(φ → ψ) → (Gφ → Gψ)`

**Rationale**: The current generalized rules are powerful but non-standard. Standard necessitation + K distribution is:
- More familiar to modal logic practitioners
- Easier to understand and verify
- Sufficient for the same theorems (generalized rule is derivable)

**Implementation Steps**:
1. Add `necessitation` rule to `Derivable` (modal, empty context only)
2. Add `temporal_necessitation` rule to `Derivable` (temporal, empty context only)
3. Add `temporal_k_dist` axiom to `Axiom` (temporal K distribution)
4. Remove `modal_k` and `temporal_k` generalized rules
5. Update soundness proofs for new rules/axioms
6. Derive generalized rules as theorems (for backwards compatibility)
7. Update all proofs using old rules
8. Update documentation and tests

**Files**:
- `Logos/Core/ProofSystem/Derivation.lean` - Replace rules
- `Logos/Core/ProofSystem/Axioms.lean` - Add temporal K distribution
- `Logos/Core/Metalogic/Soundness.lean` - Update soundness proofs
- `Logos/Core/Theorems/` - Add derived generalized rules
- `LogosTest/ProofSystem/DerivationTest.lean` - Update tests

---

## Medium Priority Tasks

### 42. Proof Automation Completion (Plan 065)
**Effort**: 30-40 hours (estimated), ~8 hours completed
**Status**: PARTIAL (2/5 phases complete, 3 blocked)
**Priority**: Medium
**Blocking**: None (functional system, optimization work)
**Dependencies**: None for completed phases; Phase 3 blocks Phases 2 and 4

**Description**: Complete remaining proof automation tasks from deferred phases (Plan 063). Helper lemmas and tactic consolidation complete. Remaining phases blocked by architectural issues.

**Completed Phases**:
- **Phase 1** (COMPLETE): Helper lemma infrastructure - `axiom_in_context`, `apply_axiom_to`, `apply_axiom_in_context`
- **Phase 5** (COMPLETE): Tactic consolidation - `mkOperatorKTactic` factory (90% duplication eliminated)

**Blocked Phases**:
- **Phase 3** (BLOCKED): DeductionTheorem sorry resolution - requires well-founded recursion expertise
- **Phase 2** (BLOCKED): Temporal K infrastructure - circular dependency (Bridge → DeductionTheorem → Perpetuity)
- **Phase 4** (BLOCKED): Temporal axiom derivation - depends on Phase 3 completion

**Files Modified**:
- `Logos/Core/Theorems/Perpetuity/Helpers.lean` - 3 helper lemmas added
- `Logos/Core/Automation/Tactics.lean` - `mkOperatorKTactic` factory added

**Resolution Path**:
1. Phase 3: Human expert session with Lean 4 recursion expertise (4-6 hours)
2. Phase 2: Architectural refactoring to extract basic propositional theorems
3. Phase 4: Automatically unblocked once Phase 3 completes

**Plan**: [001-proof-automation-completion-plan.md](.claude/specs/065_proof_automation_temporal_deduction/plans/001-proof-automation-completion-plan.md)
**Summaries**: [summaries/](.claude/specs/065_proof_automation_temporal_deduction/summaries/)

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
- **Gap Documentation**: [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) for current limitations and workarounds
- **System Design**: [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md) for TM logic specification
- **Technical Debt**: [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) for sorry placeholder tracking

**Notes**:
- Priority levels reflect blocking status and estimated timeline, not importance
- Effort estimates are conservative and may vary based on implementation complexity
- Dependencies are indicated inline with each task

---

**Last Updated**: 2025-12-11 (Added Tasks 43-44: Axiom refactoring EFQ+Peirce, Inference rule refactoring standard necessitation+K)

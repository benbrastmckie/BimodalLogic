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
- High Priority: 0 tasks
- Medium Priority: 1 task (52 - AesopRules duplicate declaration)
- Low Priority: 10 tasks (9-11 long-term, 53-55 cleanup/documentation, 57 dual-type approach)
- **Active Tasks**: 11
- **Recently Completed**: Task 46 (Deduction Theorem - FULLY COMPLETE, zero sorry) ✅, Task 42b (Bridge.lean compilation fixes) ✅, Task 42a (Temporal Axiom Derivation) ✅, Task 48 (Derivable.height fix) ✅, Task 47 (Lake Lint Long Lines) ✅, Task 43 (Axiom Refactoring) ✅, Task 45 (Inference Rule Refactoring) ✅

**Milestone Achievement**: DEDUCTION THEOREM FULLY PROVEN (Task 46 - zero sorry, complete termination proofs) ✅ + ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN (100%) + PHASE 4 MODAL THEOREMS COMPLETE (8/8) + PROPOSITIONAL THEOREMS COMPLETE (Tasks 21-29) + AXIOM REFACTORING COMPLETE (Task 43) + INFERENCE RULE REFACTORING COMPLETE (Task 45) + DERIVABLE.HEIGHT FIX COMPLETE (Task 48) + TEMPORAL AXIOM DERIVATION COMPLETE (Task 42a) + BRIDGE.LEAN COMPILATION FIXED (Task 42b) ✅
**Current Work**: None (all high priority tasks complete)
**Next Milestone**: Fix AesopRules duplicate declaration (Task 52), then Layer 1 planning

---

## Quick Links

- [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking
- [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) - Current gaps and workarounds
- [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders)
- [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) - TODO management workflow

**Active Implementation Plan**:
- None (all active plans complete)

**Recently Completed**:
- [Proof Automation Completion Plan](.claude/specs/065_proof_automation_temporal_deduction/plans/001-proof-automation-completion-plan.md) - COMPLETE (2025-12-15)
  - Task 42a: future_k_dist and always_mono derived as theorems, axiom count reduced by 2
  - Task 42b: Bridge.lean compilation errors fixed, always_dni and always_dne confirmed as theorems (not axioms)
- [Modal Theorems Alternative Proofs Plan](.claude/specs/060_modal_theorems_alternative_proofs/plans/001-modal-theorems-alternative-proofs-plan.md) - All Phase 4 modal theorems complete (8/8) using k_dist_diamond
- [Modal Theorems S5 Completion Plan](.claude/specs/059_modal_theorems_s5_completion/plans/001-modal-theorems-s5-completion-plan.md) - De Morgan laws (superseded by Plan 060)
- [Minimal Axiom Review Plan](.claude/specs/048_minimal_axiom_review_proofs/plans/001-minimal-axiom-review-proofs-plan.md) - Documentation fixes, necessitation from MK, MK/TK documentation

---

## High Priority Tasks

---

## Medium Priority Tasks

### 52. Fix AesopRules.lean Duplicate Declaration
**Effort**: 30 minutes
**Status**: Not Started
**Priority**: Medium (blocks full build)
**Blocking**: Full project build
**Dependencies**: None

**Description**: `Logos/Core/Automation/AesopRules.lean` has a duplicate declaration error for `apply_modal_k`.

**Error**:
```
error: 'Logos.Core.Automation.apply_modal_k' has already been declared
```

**Solution Approach**:
1. Search for duplicate `apply_modal_k` declarations in AesopRules.lean
2. Remove or rename one of them
3. Ensure Aesop rule registration is correct

**Files Affected**:
- `Logos/Core/Automation/AesopRules.lean` (line 230)

**Impact**: Medium - blocks full build but doesn't affect core functionality

---

## Low Priority Tasks

---



### 51. Fix Perpetuity Principles.lean Context Ordering
**Effort**: 1-2 hours
**Status**: ✅ COMPLETE (resolved by Task 42a)
**Priority**: Low (has workaround)
**Blocking**: None
**Dependencies**: Task 48 (Complete) ✅

**Description**: The `future_k_dist` theorem in `Principles.lean` had a TODO comment about fixing context ordering after Task 48 completion.

**Resolution** (Task 42a):
- Used weakening to reorder context from `[(A.imp B).all_future, A.all_future]` to `[A.all_future, (A.imp B).all_future]`
- Applied deduction theorem twice as originally intended
- Proof now complete with zero sorry

**Files Modified**:
- `Logos/Core/Theorems/Perpetuity/Principles.lean` (lines 681-710)

**Impact**: Task complete - `future_k_dist` is now fully proven

---

### 52. Fix AesopRules.lean Duplicate Declaration
**Effort**: 30 minutes
**Status**: Not Started
**Priority**: Low (doesn't block functionality)
**Blocking**: None
**Dependencies**: None

**Description**: `Logos/Core/Automation/AesopRules.lean` has a duplicate declaration error for `apply_modal_k`.

**Error**:
```
error: 'Logos.Core.Automation.apply_modal_k' has already been declared
```

**Solution Approach**:
1. Search for duplicate `apply_modal_k` declarations in AesopRules.lean
2. Remove or rename one of them
3. Ensure Aesop rule registration is correct

**Files Affected**:
- `Logos/Core/Automation/AesopRules.lean` (line 230)

**Impact**: Low - doesn't affect core functionality

---

### 53. Prove Height Function Properties (Optional Enhancement)
**Effort**: 4-6 hours
**Status**: Not Started
**Priority**: Very Low (enhancement)
**Blocking**: None
**Dependencies**: None

**Description**: The `Derivable.height` function and its 7 properties are currently axiomatized in `Derivation.lean`. While this is sound and standard practice for `Prop` types in Lean 4, they could theoretically be proven if we change `Derivable` from `Prop` to `Type`.

**Current State**:
- `Derivable.height` is axiomatized (line 177)
- 7 height properties are axiomatized (lines 183-227)
- This is sound because the properties follow from the recursive definition

**Alternative Approach** (if desired):
1. Change `Derivable` from `inductive ... : Prop` to `inductive ... : Type`
2. Define `height` recursively using pattern matching
3. Prove the 7 properties as theorems
4. Update all uses of `Derivable` throughout codebase

**Pros**:
- Fully proven properties (no axioms)
- Computable height function

**Cons**:
- Major refactoring required (100+ files)
- Breaks proof irrelevance (Derivable becomes data)
- Not standard practice in Lean 4 for proof systems
- No practical benefit (axiomatization is sound)

**Recommendation**: Keep axiomatized unless there's a specific need for computation

**Files Affected**:
- `Logos/Core/ProofSystem/Derivation.lean`
- All files using `Derivable` (100+ files)

**Impact**: Very Low - current axiomatization is sound and standard

---

### 54. Update SORRY_REGISTRY.md
**Effort**: 1 hour
**Status**: Not Started
**Priority**: Low (documentation)
**Blocking**: None
**Dependencies**: Task 52 (to get accurate counts)

**Description**: Update `SORRY_REGISTRY.md` to reflect completion of Task 46 (Deduction Theorem) and current sorry status.

**Updates Needed**:
1. Update total counts (verify current sorry count across project)
2. Remove entry for `DeductionTheorem.lean` (now complete with zero sorry) ✅
3. Update "Last Updated" date
4. Cross-reference with Task 52

**Files Affected**:
- `Documentation/ProjectInfo/SORRY_REGISTRY.md`

**Impact**: Low - documentation only

---

### 55. Update IMPLEMENTATION_STATUS.md
**Effort**: 30 minutes
**Status**: Not Started
**Priority**: Low (documentation)
**Blocking**: None
**Dependencies**: Task 46 (Complete) ✅, Task 48 (Complete) ✅

**Description**: Update `IMPLEMENTATION_STATUS.md` to reflect Task 46 (Deduction Theorem) completion and current module status.

**Updates Needed**:
1. Mark `DeductionTheorem.lean` as "Complete (zero sorry)" ✅
2. Update `Derivation.lean` status to note height axioms
3. Update "Last Updated" date
4. Update Known Limitations section if needed
5. Note that deduction theorem is now fully proven with complete termination proofs

**Files Affected**:
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`

**Impact**: Low - documentation only

---

### 56. Implement Missing Helper Lemmas for Bridge.lean
**Effort**: 3-4 hours
**Status**: Not Started
**Priority**: Medium (needed for Task 50)
**Blocking**: Task 50
**Dependencies**: None

**Description**: Implement the missing helper lemmas referenced in `Bridge.lean` errors.

**Missing Lemmas**:
1. `always_to_past`: `△φ → Hφ` (always implies past)
2. `always_to_present`: `△φ → φ` (always implies present)
3. `always_to_future`: `△φ → Fφ` (always implies future)
4. `neg_a_to_b_from_bot`: Negation helper for contradiction

**Solution Approach**:
1. Define each lemma in appropriate module (likely `Perpetuity/Helpers.lean`)
2. Prove using existing axioms and theorems
3. Update imports in `Bridge.lean`

**Files Affected**:
- `Logos/Core/Theorems/Perpetuity/Helpers.lean` (add lemmas)
- `Logos/Core/Theorems/Perpetuity/Bridge.lean` (use lemmas)

**Impact**: Medium - needed to fix Bridge.lean compilation

---

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

### 57. Implement Dual-Type Approach for Proof Extraction
**Effort**: 15-20 hours
**Status**: Not Started
**Priority**: Low (future enhancement for external tool integration)
**Blocking**: None
**Dependencies**: None
**GitHub Issue**: https://github.com/benbrastmckie/ProofChecker/issues/2

**Description**: Implement a computational `DerivationTree` type alongside the existing `Derivable` Prop to enable proof extraction for external tools and certified proof checking with explicit derivation trees.

**Motivation**: While the current axiomatized height function approach is sound and standard for `Prop` types, a dual-type approach provides:
- Proof extraction to external proof checkers
- Certified checking with explicit derivation structure
- Computable height and complexity metrics
- Proof search algorithms that inspect derivation structure
- Maintains proof irrelevance for theorems via existing `Derivable` Prop

**Implementation Tasks**:
1. Create `DerivationTree` inductive type in `Logos/Core/ProofSystem/DerivationTree.lean`
2. Define computable functions: `tree_height`, `tree_complexity`, etc.
3. Prove soundness: `tree_to_derivable : DerivationTree Γ φ → Derivable Γ φ`
4. Add proof extraction/export to standard formats (OpenTheory, Coq, etc.)
5. Write tests in `LogosTest/ProofSystem/DerivationTreeTest.lean`
6. Document usage in `Documentation/UserGuide/EXAMPLES.md`

**Files to Create/Modify**:
- `Logos/Core/ProofSystem/DerivationTree.lean` (NEW)
- `Logos/Core/ProofSystem.lean` (add export)
- `LogosTest/ProofSystem/DerivationTreeTest.lean` (NEW)
- `Documentation/UserGuide/EXAMPLES.md` (add proof extraction examples)

**When to Implement**: Consider when Logos needs integration with external proof checkers, proof search requiring derivation inspection, or export to other proof assistants.

**References**: 
- Research report: `.claude/research/height-function-axiomatization-report.md` (Section 4.2)
- Related: Task 53 (optional height function enhancement)

**Impact**: Low - enhancement for future use cases, current approach is sound and sufficient

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

**Last Updated**: 2025-12-15 (Task 46 FULLY COMPLETE - Deduction theorem proven with zero sorry, complete termination proofs using deduction_with_mem helper; Task 49 removed as completed by Task 46; Task 42b complete - Bridge.lean compilation errors fixed, always_dni and always_dne confirmed as theorems; Task 42a complete - future_k_dist and always_mono derived as theorems, axiom count reduced by 2; Task 48 complete - Derivable.height fixed; Tasks 50, 51, 56 removed as resolved by Task 42b; Task 52 promoted to Medium priority as it blocks full build)

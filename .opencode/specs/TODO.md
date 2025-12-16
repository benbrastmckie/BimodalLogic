# TODO - Logos LEAN 4 ProofChecker

## Update Instructions

**When to Update**: After completing tasks, discovering new work, or changing priorities.

**How to Update**:
1. Mark completed tasks by removing them from active sections (history tracked via git)
2. Add new tasks with: description, effort estimate, status, priority, blocking/dependencies
3. Update the "Active Tasks" count in Overview
4. Update "Last Updated" date at bottom
5. Use `/review` command to sync with repository analysis and verification

**What NOT to Track Here**:
- Completed task details (use git history: `git log --grep="Task"`)
- Implementation plans (use `.opencode/specs/` directories)
- Module-by-module status (use IMPLEMENTATION_STATUS.md)
- Technical debt details (use SORRY_REGISTRY.md)

---

## Overview

This file tracks active development tasks for Logos. Completed tasks are removed from this file - see git history and spec summaries for completion records.

**Last Repository Review**: 2025-12-16 (Project 004_review_20251216)
- **Compliance Score**: 94.65/100 (Excellent)
- **Repository Health**: 94/100 (Excellent)
- **Total Files Verified**: 30 modules
- **Total Proofs Checked**: 150+ theorems
- **Sorry Found**: 8 (matches expected - 3 documented limitations, 1 invalid theorem, 3 documentation, 1 low-priority)
- **Axioms Found**: 16 user-facing + 14 system (matches expected - all justified)
- **Review Reports**: [Analysis](.opencode/specs/004_review_20251216/reports/analysis-001.md) | [Verification](.opencode/specs/004_review_20251216/reports/verification-001.md)

**Layer 0 Completion Progress**:
- High Priority: 4 tasks (System config + Core development)
- Medium Priority: 24 tasks (Proof development + System enhancements)
- Low Priority: 16 tasks (General research + long-term metalogic + cleanup/documentation)
- **Active Tasks**: 43
- **Recently Completed**: Task 60 (Remove backup artifacts) ✅, Task 59 (IMPLEMENTATION_STATUS.md update) ✅, Task 56 (Bridge.lean helper lemmas - verified complete) ✅, Task 52 (AesopRules duplicate fix) ✅, Task 58 (SORRY_REGISTRY.md update) ✅, Task 46 (Deduction Theorem - FULLY COMPLETE, zero sorry) ✅, Task 42b (Bridge.lean compilation fixes) ✅, Task 42a (Temporal Axiom Derivation) ✅, Task 48 (Derivable.height fix) ✅

**Milestone Achievement**: IMPLEMENTATION_STATUS.md UPDATED (Task 59 - DeductionTheorem.lean documented as 100% complete) ✅ + DEDUCTION THEOREM FULLY PROVEN (Task 46 - zero sorry, complete termination proofs) ✅ + ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN (100%) + PHASE 4 MODAL THEOREMS COMPLETE (8/8) + PROPOSITIONAL THEOREMS COMPLETE (Tasks 21-29) + AXIOM REFACTORING COMPLETE (Task 43) + INFERENCE RULE REFACTORING COMPLETE (Task 45) + DERIVABLE.HEIGHT FIX COMPLETE (Task 48) + TEMPORAL AXIOM DERIVATION COMPLETE (Task 42a) + BRIDGE.LEAN COMPILATION FIXED (Task 42b) ✅

**Current Work**: All high-priority documentation tasks complete - ready for Layer 1 planning

**Next Milestone**: Layer 1 planning and implementation

---

## Quick Links

- [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking
- [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) - Current gaps and workarounds
- [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders)
- [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) - TODO management workflow
- [Repository Review (2025-12-16)](.opencode/specs/004_review_20251216/reports/analysis-001.md) - Latest comprehensive analysis
- [Proof Verification (2025-12-16)](.opencode/specs/004_review_20251216/reports/verification-001.md) - Latest verification report

**Active Implementation Plan**:
- None (all active plans complete)

**Recently Completed**:
- [Remove Backup Artifacts Plan](.opencode/specs/060_remove_backup_artifacts/plans/implementation-001.md) - COMPLETE (2025-12-16)
  - Task 60: Removed Bridge.lean.backup, enhanced .gitignore with comprehensive backup patterns
- [Proof Automation Completion Plan](.opencode/specs/065_proof_automation_temporal_deduction/plans/001-proof-automation-completion-plan.md) - COMPLETE (2025-12-15)
  - Task 42a: future_k_dist and always_mono derived as theorems, axiom count reduced by 2
  - Task 42b: Bridge.lean compilation errors fixed, always_dni and always_dne confirmed as theorems (not axioms)
- [Modal Theorems Alternative Proofs Plan](.opencode/specs/060_modal_theorems_alternative_proofs/plans/001-modal-theorems-alternative-proofs-plan.md) - All Phase 4 modal theorems complete (8/8) using k_dist_diamond
- [Modal Theorems S5 Completion Plan](.opencode/specs/059_modal_theorems_s5_completion/plans/001-modal-theorems-s5-completion-plan.md) - De Morgan laws (superseded by Plan 060)
- [Minimal Axiom Review Plan](.opencode/specs/048_minimal_axiom_review_proofs/plans/001-minimal-axiom-review-proofs-plan.md) - Documentation fixes, necessitation from MK, MK/TK documentation

---

## High Priority Tasks

### System Configuration Issues
- [x] Fix invalid frontmatter in specialist subagents (mode: specialist → mode: subagent)

### Core Development
- [ ] Review current repository state and identify gaps
- [ ] Research Kripke semantics for bimodal logic
- [ ] Implement proof system axioms (K axioms, dual axioms)
- [ ] Define bimodal Kripke model structure

---

### 61. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: Not Started
**Priority**: Medium (documentation completeness)
**Blocking**: None
**Dependencies**: None

**Description**: Add README.md files to directories lacking them, following DIRECTORY_README_STANDARD.md.

**Verification Finding** (Project 004 - 2025-12-16):
- ✅ Verified 2 missing READMEs: `Automation/` and `Perpetuity/`
- ✅ Confirmed as reducing discoverability and understanding
- ✅ Repository organization score: 98/100 (2 points deducted for missing READMEs)

**Missing READMEs**:
- `Logos/Core/Theorems/Perpetuity/README.md` - Should document P1-P6 principles, helper lemmas, bridge lemmas
- `Logos/Core/Automation/README.md` - Should document tactics, proof search, Aesop integration

**Files Affected**: 
- `Logos/Core/Theorems/Perpetuity/README.md` (create)
- `Logos/Core/Automation/README.md` (create)

**Impact**: Medium - reduces discoverability and understanding of module organization

---

### 62. Improve Docstring Coverage to 100%
**Effort**: 2-3 hours
**Status**: Not Started
**Priority**: Medium (quality improvement)
**Blocking**: None
**Dependencies**: None

**Description**: Add docstrings to remaining undocumented functions to reach 100% coverage target.

**Verification Finding** (Project 004 - 2025-12-16):
- ✅ Verified 95% docstring coverage (excellent)
- ✅ Confirmed 5% gap in helper functions
- ✅ Documentation quality score: 98/100
- ✅ All major theorems have comprehensive docstrings

**Gaps Identified**:
- Some helper functions in `Logos/Core/Theorems/Perpetuity/Helpers.lean`
- A few transport lemmas in `Logos/Core/Semantics/WorldHistory.lean`
- Some helper functions in `Logos/Core/Automation/Tactics.lean`

**Files Affected**: 
- `Logos/Core/Theorems/Perpetuity/Helpers.lean`
- `Logos/Core/Semantics/WorldHistory.lean`
- `Logos/Core/Automation/Tactics.lean`

**Impact**: Low - quality improvement (current 95% coverage is excellent)

---

## Medium Priority Tasks

### Proof Development
- [ ] Create implementation plan for soundness proof
- [ ] Refactor existing modal logic proofs for readability
- [ ] Document bimodal logic proof system
- [ ] Set up CI/CD for automated proof verification

### System Enhancement - Specialist Subagents (14 agents)
- [ ] Create syntax-checker specialist (validates LEAN 4 syntax correctness)
- [ ] Create tactic-advisor specialist (recommends tactics for proof goals)
- [ ] Create library-navigator specialist (finds relevant mathlib functions)
- [ ] Create performance-optimizer specialist (optimizes proof performance)
- [ ] Create error-diagnostics specialist (analyzes and explains LEAN errors)
- [ ] Create dependency-analyzer specialist (maps proof dependencies)
- [ ] Create test-generator specialist (generates test cases for theorems)
- [ ] Create example-builder specialist (creates illustrative examples)
- [ ] Create documentation-formatter specialist (formats documentation)
- [ ] Create git-workflow-manager specialist (manages git operations)
- [ ] Create code-reviewer specialist (reviews code quality)
- [ ] Create refactoring-assistant specialist (suggests refactorings)
- [ ] Create learning-path-generator specialist (creates learning paths)
- [ ] Create concept-explainer specialist (explains complex concepts)

### System Enhancement - Context Files
- [ ] Research and populate context/logic/processes/ directory
- [ ] Research and populate context/logic/standards/ directory
- [ ] Research and populate context/logic/templates/ directory
- [ ] Research and populate context/logic/patterns/ directory
- [ ] Research and populate context/math/analysis/ directory (real analysis, complex analysis, functional analysis)
- [ ] Research and populate context/math/category-theory/ directory (categories, functors, natural transformations)
- [ ] Research and populate context/math/linear-algebra/ directory (vector spaces, linear maps, matrices)

---

## Low Priority Tasks

### General Research and Exploration
- [ ] Explore decidability procedures for bimodal logic
- [ ] Research alternative proof strategies
- [ ] Investigate metaprogramming for custom tactics

---

### 9. Begin Completeness Proofs
**Effort**: 70-90 hours
**Status**: Not Started
**Priority**: Low (long-term metalogic goal)
**Blocking**: None
**Dependencies**: Benefits from completed soundness proofs

**Description**: Implement canonical model construction and prove completeness theorems (weak and strong). This is a major undertaking requiring significant effort.

**Verification Finding** (Project 004 - 2025-12-16):
- ✅ Completeness.lean infrastructure verified as well-structured
- ✅ 11 axiom declarations confirmed (all with comprehensive docstrings)
- ✅ 1 sorry in `provable_iff_valid` (soundness direction, 1-2 hours)
- ✅ All axioms have proof strategies documented

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

### 53. Prove Height Function Properties (Optional Enhancement)
*Effort**: 4-6 hours
*Status**: Not Started
*Priority**: Medium (enhancement)
*Blocking**: None
*Dependencies**: None

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

### 57. Implement Dual-Type Approach for Proof Extraction
*Effort**: 15-20 hours
*Status**: Not Started
*Priority**: Low (future enhancement for external tool integration)
*Blocking**: None
*Dependencies**: None
*GitHub Issue**: https://github.com/benbrastmckie/ProofChecker/issues/2

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

## Completed

### System Setup
- [x] Set up .opencode system for LEAN 4 ProofChecker
- [x] Create orchestrator and primary agents
- [x] Configure context files for lean4 and logic domains
- [x] Fix invalid frontmatter in specialist subagents (mode: specialist → mode: subagent)

### 60. Remove Backup Artifacts ✅
**Completion Date**: 2025-12-16
**Status**: Complete
**Priority**: Medium (repository cleanliness)

**Description**: Removed backup files and enhanced .gitignore with comprehensive backup patterns for cleaner repository.

**Changes Made**:
- Deleted `Logos/Core/Theorems/Perpetuity/Bridge.lean.backup`
- Enhanced .gitignore with comprehensive backup file patterns: `*.backup`, `*.old`, `.save_*/`, `.backup_*/`, `backup/`, `backups/`
- Consolidated duplicate patterns (removed `*.bak` and `*~` from multiple sections)
- Improved pattern coverage for common backup naming conventions

**Files Modified**:
- `.gitignore` (enhanced backup patterns)

**Files Deleted**:
- `Logos/Core/Theorems/Perpetuity/Bridge.lean.backup`

**Impact**: Low - repository cleanliness improvement, prevents future backup artifacts from being tracked

**Artifacts**:
- Implementation plan: `.opencode/specs/060_remove_backup_artifacts/plans/implementation-001.md`
- Task summary: `.opencode/specs/060_remove_backup_artifacts/summaries/task-summary.md`

---

### 59. Update IMPLEMENTATION_STATUS.md ✅
**Completion Date**: 2025-12-16
**Status**: Complete
**Priority**: High (documentation accuracy)

**Description**: Updated IMPLEMENTATION_STATUS.md to reflect Task 46 (Deduction Theorem) completion and current module status.

**Changes Made**:
- Updated DeductionTheorem.lean status from "Partial (3 sorry)" to "Complete (zero sorry)"
- Added comprehensive DeductionTheorem.lean section with all 5 theorems documented
- Updated Summary Table with DeductionTheorem row showing "✓ Complete" with "100%" completeness
- Updated "Last Updated" date to 2025-12-16
- Updated Overall Project Status: MVP completion 82% → 83% fully complete, 6% → 5% partial
- Updated "What Works" section to mention deduction theorem
- Updated "What's Partial" section to remove DeductionTheorem

**Files Modified**:
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`

**Impact**: High - documentation now accurately reflects Task 46 completion and current module status

---

### 56. Implement Missing Helper Lemmas for Bridge.lean ✅
**Completion Date**: 2025-12-16 (verification)
**Original Implementation**: Task 42b (2025-12-15)
**Status**: Complete (all lemmas already implemented)

**Description**: All four required helper lemmas were already fully implemented in Bridge.lean as part of Task 42b:

**Implemented Lemmas** (all zero sorry):
1. `always_to_past` (line 529) - `△φ → Hφ` - fully proven
2. `always_to_present` (line 539) - `△φ → φ` - fully proven
3. `always_to_future` (line 555) - `△φ → Fφ` - fully proven
4. `neg_a_to_b_from_bot` (implemented as `local_efq`, line 204) - fully proven

**Files Verified**:
- `Logos/Core/Theorems/Perpetuity/Bridge.lean` (all lemmas present, zero sorry)
- `Logos/Core/Theorems/Perpetuity/Helpers.lean` (supporting helpers)
- `Logos/Core/Theorems/Perpetuity.lean` (parent module)

**Impact**: Task was already complete - no blocking issues for Task 50

---

## Completion History

Completed tasks are tracked via git history. Query completion records:

```bash
# View all task completions
git log --all --grep="Complete Task" --oneline

# Find when specific task completed
git log --all --grep="Task 7" --oneline

# View spec summaries for detailed completion narratives
find .opencode/specs -name "*summary*.md" | head -20

# Search summaries for task
grep -r "Task 5" .opencode/specs/*/summaries/
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

## Usage

To add tasks from this list to projects:
```bash
/plan "Task description from above"
```

To update this file after review:
```bash
/review
```

To mark tasks complete, remove them from active sections (git tracks history).

---

**Last Updated**: 2025-12-16 (Task 60 complete - Backup artifacts removed, .gitignore enhanced - 43 active tasks remaining: 12 Logos development tasks + 31 opencode system enhancement tasks)

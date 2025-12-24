# Logos Project TODO

**Last Updated**: 2025-12-24
**Status**: Layer 0 (Core TM) MVP Complete - Review in Progress

## Overview

Logos has completed its MVP phase with a functional implementation of the TM bimodal logic proof system. The current focus is on completing the metalogical proofs for completeness and enhancing automation.

- **Layer 0 Completion**: 83% (Soundness & Deduction complete, Completeness infrastructure only)
- **Active Tasks**: 8
- **Next Milestone**: Completeness Proofs

## Quick Links

- [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
- [Sorry Registry](Documentation/ProjectInfo/SORRY_REGISTRY.md)
- [Maintenance Workflow](Documentation/ProjectInfo/MAINTENANCE.md)

---

## High Priority (Complete within 1 month)

### 1. Completeness Proofs
**Effort**: 70-90 hours
**Status**: INFRASTRUCTURE ONLY
**Blocking**: Decidability
**Dependencies**: Soundness (Complete), Deduction Theorem (Complete)

**Description**: Implement the completeness proof for TM logic using the canonical model method. The infrastructure (types and axiom statements) is present in `Logos/Core/Metalogic/Completeness.lean`.

**Action Items**:
1. Implement `lindenbaum` lemma (extend consistent sets to maximal consistent sets using Zorn's lemma).
2. Prove properties of maximal consistent sets (deductive closure, negation completeness).
3. Construct `canonical_frame` and prove frame properties (nullity, compositionality).
4. Prove `truth_lemma` (correspondence between membership and truth).
5. Prove `weak_completeness` and `strong_completeness`.

**Files**:
- `Logos/Core/Metalogic/Completeness.lean`

---

## Medium Priority (Complete within 3 months)

### 2. Resolve Truth.lean Sorries
**Effort**: 10-20 hours
**Status**: PARTIAL
**Priority**: Medium (Soundness depends on this for full temporal duality)

**Description**: Resolve the 3 remaining `sorry` placeholders in `Logos/Core/Semantics/Truth.lean` related to temporal swap validity. These require handling domain extension for history quantification.

**Action Items**:
1. Resolve `truth_swap_of_valid_at_triple` (implication case).
2. Resolve `truth_swap_of_valid_at_triple` (past case - domain extension).
3. Resolve `truth_swap_of_valid_at_triple` (future case - domain extension).

**Files**:
- `Logos/Core/Semantics/Truth.lean` (lines 697, 776, 798)

---

### 148. Ensure command updates also sync SORRY and TACTIC registries
**Effort**: 2-3 hours
**Status**: [NOT STARTED]
**Priority**: Medium
**Blocking**: None
**Dependencies**: None

**Files Affected**:
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- `Documentation/ProjectInfo/SORRY_REGISTRY.md`
- `Documentation/ProjectInfo/TACTIC_REGISTRY.md`
- `Documentation/Development/MAINTENANCE.md`

**Description**:
Update `/task`, `/add`, `/review`, `/todo`, and related command flows and standards so that they always update `IMPLEMENTATION_STATUS.md`, `SORRY_REGISTRY.md`, and `TACTIC_REGISTRY.md` together. Ensure dry-run coverage and avoid creating project directories when no artifacts are written.

**Acceptance Criteria**:
- [ ] Command/agent standards updated to require registry updates for `/task`, `/add`, `/review`, `/todo`, and related commands.
- [ ] IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, and TACTIC_REGISTRY.md are updated in the same change when these commands modify tasks.
- [ ] Dry-run behavior and safety notes are documented for these updates.
- [ ] No project directories are created as part of these command updates.

**Impact**:
Keeps implementation status and registries synchronized, reducing drift and missing updates across automation flows.

---

### 172. Complete API documentation for all Logos modules
**Effort**: 30 hours
**Status**: [PLANNED]
**Started**: 2025-12-24
**Completed**: 2025-12-24
**Priority**: High
**Blocking**: None
**Dependencies**: None
**Language**: lean
**Research**: [Research Report](.opencode/specs/172_documentation/reports/research-001.md)
**Research Summary**: Current state shows 98% module-level coverage but only 47% declaration-level coverage. Critical gaps identified in 4 files (Tactics.lean, Truth.lean, Propositional.lean, Derivation.lean). Recommended tools: doc-gen4 for centralized API reference, linters for quality enforcement. Revised effort estimate: 30 hours (up from 18 hours).
**Plan**: [Implementation Plan](.opencode/specs/172_documentation/plans/implementation-001.md)
**Plan Summary**: 5-phase implementation plan (30 hours total). Phase 1: Infrastructure setup with doc-gen4 and linters (3h). Phase 2: Critical gaps - Tactics, Truth, Propositional, Derivation (12h). Phase 3: Moderate gaps - TaskModel, ModalS4, ModalS5 (4.5h). Phase 4: Minor gaps - 18 remaining files (9h). Phase 5: Quality assurance and API reference generation (1.5h). Includes build blocker fixes for Truth.lean and DeductionTheorem.lean.

**Files Affected**:
- All Logos module files (24 modules)
- `Documentation/Reference/API_REFERENCE.md`

**Description**:
Complete comprehensive API documentation for all Logos modules with docstrings, parameter descriptions, examples, and centralized API reference. Analysis shows excellent 95% coverage with only build errors blocking full verification.

**Acceptance Criteria**:
- [x] All public functions have docstrings
- [x] Docstrings include parameter descriptions
- [x] Complex functions include examples
- [x] Centralized API reference generated
- [ ] Zero docBlame warnings (pending build fixes)

**Impact**:
Provides complete API documentation for all Logos modules, improving usability and maintainability.

---

### 8. Refactor `Logos/Core/Syntax/Context.lean`
**Effort**: 2-4 hours
**Status**: PLANNED
**Priority**: Medium
**Blocking**: Task 9
**Dependencies**: None

**Files Affected**:
- `Logos/Core/Syntax/Context.lean`
- `LogosTest/Core/Syntax/ContextTest.lean`

**Description**:
Refactor the `Context.lean` file to improve clarity, performance, and alignment with the LEAN 4 style guide. This involves reviewing the existing implementation of proof contexts and applying best practices for data structures and function definitions in LEAN 4.

**Acceptance Criteria**:
- [ ] The `Context.lean` file is refactored for clarity and performance.
- [ ] All related tests in `ContextTest.lean` are updated and pass.
- [ ] The refactoring adheres to the LEAN 4 style guide.
- [ ] The public API of the `Context` module remains backward-compatible or changes are documented.

**Impact**:
Improves the maintainability and readability of a core component of the syntax package.

---

### 9. Update Context References
**Effort**: 1-2 hours
**Status**: PLANNED
**Priority**: Medium
**Blocking**: None
**Dependencies**: Task 8

**Files Affected**:
- `Logos/Core/ProofSystem/Derivation.lean`
- `Logos/Core/Metalogic/DeductionTheorem.lean`
- Other files that import `Logos.Core.Syntax.Context`

**Description**:
After refactoring `Context.lean`, update all references to the `Context` module throughout the codebase to ensure they are compatible with any changes made to the API. This task involves searching for all usages of `Context` and updating them as necessary.

**Acceptance Criteria**:
- [ ] All references to the `Context` module are updated.
- [ ] The project builds successfully after the updates.
- [ ] All tests pass after the updates.

**Impact**:
Ensures that the entire codebase is compatible with the refactored `Context` module.

---

### 126. Implement bounded_search and matches_axiom in ProofSearch
**Effort**: 3 hours
**Status**: COMPLETED (Started: 2025-12-22, Completed: 2025-12-22)
**Priority**: Medium
**Blocking**: None
**Dependencies**: None
**Artifacts**: [.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md](.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md), [.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/reports/research-001.md](.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/reports/research-001.md), [.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/summaries/implementation-summary-20251222.md](.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/summaries/implementation-summary-20251222.md)

**Files Affected**:
- `Logos/Core/Automation/ProofSearch.lean`
- `LogosTest/Core/Automation/ProofSearchTest.lean`

**Description**:
Implement bounded search driver with depth/visit limits, cache/visited threading, and structural axiom matching for all 14 schemas to replace stubs and enable basic proof search execution. Lean intent true; plan ready at [.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md](.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md).

**Acceptance Criteria**:
- [x] `bounded_search` implemented with depth and visit limits.
- [x] `matches_axiom` implemented with correct structural matching logic (all 14 schemas) and axiom stubs removed.
- [x] `search_with_cache`/basic search runs on sample goals without timeouts.
- [x] Tests cover axiom matching and bounded search termination (unit + integration under Automation).

**Impact**:
Enables the first working path for automated proof search with termination guards.

---

## Low Priority (Complete within 6-12 months)

### 3. Automation Tactics
**Effort**: 40-60 hours
**Status**: PARTIAL (4/12 implemented)

**Description**: Implement the remaining planned tactics for TM logic to support easier proof construction.

**Action Items**:
1. Implement `modal_k_tactic`, `temporal_k_tactic`.
2. Implement `modal_4_tactic`, `modal_b_tactic`.
3. Implement `temp_4_tactic`, `temp_a_tactic`.
4. Implement `modal_search`, `temporal_search`.
5. Fix Aesop integration (blocked by Batteries dependency).

**Files**:
- `Logos/Core/Automation/Tactics.lean`

### 4. Proof Search
**Effort**: 40-60 hours
**Status**: PLANNED

**Description**: Implement automated proof search for TM logic.

**Action Items**:
1. Implement breadth-first proof search.
2. Implement heuristic-guided search.

**Files**:
- `Logos/Core/Automation/ProofSearch.lean`

### 5. Decidability
**Effort**: 40-60 hours
**Status**: PLANNED

**Description**: Implement decision procedures for TM logic.

**Action Items**:
1. Implement tableau method.
2. Implement satisfiability decision procedure.

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (to be created)

### 6. ModalS5 Limitation
**Effort**: Low
**Status**: DOCUMENTED LIMITATION

**Description**: The theorem `diamond_mono_imp` in `ModalS5.lean` is marked with `sorry` because it is not valid as an object-level implication. This is a documented limitation.

**Action Items**:
1. Maintain documentation or find alternative formulation if possible.

**Files**:
- `Logos/Core/Theorems/ModalS5.lean`

---

## Completion History

### 7. Document Creation of Context Files
**Effort**: 1-2 hours
**Status**: DONE
**Priority**: Low
**Blocking**: None
**Dependencies**: None

**Files Affected**:
- `Logos/Core/Syntax/Context.lean`
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`

**Description**:
This task was to document the creation and functionality of the `Context.lean` file, which manages proof contexts (premise lists) in the LEAN 4 ProofChecker project. The documentation was added to `IMPLEMENTATION_STATUS.md` to reflect the completion of this core syntax component.

**Acceptance Criteria**:
- [x] `Context.lean` is fully implemented and tested.
- [x] `IMPLEMENTATION_STATUS.md` accurately reflects the status of `Context.lean`.
- [x] The role of `Context.lean` in the syntax package is clearly described.

**Impact**:
Provides clear documentation for a core component of the syntax package, improving project maintainability and onboarding for new contributors.

See git history for other completed tasks:
```bash
git log --all --grep="Complete Task" --oneline
```

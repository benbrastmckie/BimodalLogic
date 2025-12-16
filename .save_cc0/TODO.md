# TODO - Logos Project Task Tracking

## Update Instructions

**When to Update**: After running `/create-plan`, `/research`, completing specs, or changing project status.

**How to Update**:
1. Run `/todo` command to auto-regenerate from `.claude/specs/` directory
2. Manually move items between sections (In Progress → Completed, Not Started → In Progress)
3. Add new Research entries when creating research-only specs
4. Update "Last Updated" date at bottom

**Relationship to Other Files**:
- **This file**: Tracks implementation plans in `.claude/specs/` directory
- **TODO.md** (root): Tracks active development tasks for the repository
- **IMPLEMENTATION_STATUS.md**: Module-by-module completion tracking
- **SORRY_REGISTRY.md**: Technical debt (sorry placeholders)

**What to Track Here**:
- Implementation plans created via `/create-plan`
- Research reports created via `/research`
- Spec directory status (In Progress, Not Started, Completed)

---

## Overview

This file tracks active projects and research for Logos. All projects are organized by status, with links to specifications and reports.

**Remaining Projects**: 7 active plans + 9 research-only directions

---

## In Progress

### 1. TODO Implementation Systematic Plan

**Status**: [IN PROGRESS] - Phases 1-4 COMPLETE, Phases 5-8 NOT STARTED

**Description**: Systematic implementation of all 11 TODO.md tasks for Layer 0 (Core TM) completion, organized in 4 phased waves with parallel execution opportunities. Phases 1-4 complete: High Priority Foundations, Perpetuity Proofs, Transport Lemmas (all 8 axioms proven), and Documentation Sync.

[.claude/specs/019_research_todo_implementation_plan/]
- Report: [TODO Implementation Systematic Plan](./specs/019_research_todo_implementation_plan/reports/001-todo-implementation-systematic-plan.md)
- Report: [Spec 022 Documentation Impact on Task 7 Automation](./specs/019_research_todo_implementation_plan/reports/002-spec-022-documentation-impact-on-task-7-automation.md)
- Report: [Phase 3 Expanded Plan Integration Analysis](./specs/019_research_todo_implementation_plan/reports/003-phase-3-expanded-plan-integration-analysis.md)

### 2. WorldHistory Universal Helper and Tactic Test Suite

**Status**: [IN PROGRESS] - Phase 1 in progress, Phase 2 not started

**Description**: Implement two medium-priority tasks: (1) Fix WorldHistory Universal Helper by proving or refactoring the respects_task sorry at WorldHistory.lean:119, (2) Expand Tactic Test Suite from 31 tests to 50+ comprehensive coverage.

[.claude/specs/033_worldhistory_universal_tactic_tests/]
- Plan: [WorldHistory Universal Tactic Tests Plan](./specs/033_worldhistory_universal_tactic_tests/plans/001-worldhistory-universal-tactic-tests-plan.md)

---

## Not Started

### 1. Fix README.md Broken Links

**Status**: [READY FOR IMPLEMENTATION] - 6 broken links identified, fixes planned

**Description**: Fix 6 broken links in README.md that prevent users from accessing critical documentation and legal information. Issues include missing LICENSE file, outdated documentation paths, and incorrect API reference links.

[.claude/specs/012_readme_broken_links_fix/]
- Plan: [Fix README.md Broken Links](./specs/012_readme_broken_links_fix/plans/001-readme-broken-links-fix-plan.md)
- Report: [Broken Links Analysis](./specs/012_readme_broken_links_fix/reports/broken-links-analysis.md)

### 2. README.md Narrative Arc and Organization Improvement

**Status**: [IN PROGRESS] - Research phase complete, implementation pending

**Description**: Restructure README.md following pyramid narrative principles to reduce cognitive load, consolidate duplicated content (layer architecture, implementation status, Logos integration), and improve information hierarchy without dropping essential content.

[.claude/specs/024_readme_narrative_organization_fix/]
- Plan: [README Narrative Organization Improvement](./specs/024_readme_narrative_organization_fix/plans/001-readme-narrative-organization-fix-plan.md)
- Report: [README Narrative Arc Analysis](./specs/024_readme_narrative_organization_fix/reports/001-readme-narrative-analysis.md)

### 3. High Priority Tasks Systematic Completion

**Status**: [NOT STARTED] - High priority tasks complete, remaining work planned

**Description**: Systematic implementation of remaining medium and low priority tasks after completion of all High Priority Tasks (1-5). Focus on Task 7 Enhancement (Batteries compatibility fix and Aesop integration), Task 9 (Completeness proofs), and Task 10 (Decidability module).

[.claude/specs/030_high_priority_tasks_systematic_plan/]
- Plan: [High Priority Tasks Systematic Completion](./specs/030_high_priority_tasks_systematic_plan/plans/001-high-priority-tasks-systematic-plan-plan.md)
- Report: [Remaining Tasks Lean Research](./specs/030_high_priority_tasks_systematic_plan/reports/001_remaining_tasks_lean_research.md)

### 4. 'Always' Operator Cruft Cleanup

**Status**: [NOT STARTED] - Analysis complete, cleanup planned

**Description**: Remove unused frame constraint definitions (BackwardPersistence and ModalTemporalPersistence) from Soundness.lean and update associated documentation after aligning the `always` operator with the JPL paper definition.

[.claude/specs/034_always_operator_cleanup_alignment/]
- Plan: [Always Operator Cruft Cleanup](./specs/034_always_operator_cleanup_alignment/plans/001-always-operator-cleanup-plan.md)

### 5. Remove Derivable Axioms from Perpetuity.lean (Task 18)

**Status**: [NOT STARTED] - Research complete, ready for implementation

**Description**: Remove all unnecessary axioms from Perpetuity.lean that can be syntactically derived, reducing the axiomatic footprint to only semantically necessary primitives. Derives `contraposition` (completes sorry), `perpetuity_4`, `perpetuity_5`, `perpetuity_6` from existing axioms and rules.

[.claude/specs/047_remove_derivable_axioms_perpetuity/]
- Plan: [Remove Derivable Axioms Plan](./specs/047_remove_derivable_axioms_perpetuity/plans/001-remove-derivable-axioms-perpetuity-plan.md)
- Reports:
  - [Mathlib Theorems Research](./specs/047_remove_derivable_axioms_perpetuity/reports/001-mathlib-theorems.md)
  - [Proof Strategies Research](./specs/047_remove_derivable_axioms_perpetuity/reports/002-proof-strategies.md)
  - [Project Structure Research](./specs/047_remove_derivable_axioms_perpetuity/reports/003-project-structure.md)

---

## Research

Research-only directions without implementation plans:

- [ ] **Logos Package Documentation Research** - Extract proof-checker package information from Logos project documentation [.claude/specs/001_proof_checker_package_docs/]

- [ ] **LEAN 4 Best Practices for Development** - Synthesize LEAN 4 best practices for developing proof-checker package (November 2025 focus) [.claude/specs/002_lean4_proof_checker_best_practices/]

- [ ] **LEAN 4 Language Sufficiency Analysis** - Evaluate LEAN 4 sufficiency and multi-language integration for proof-checker development [.claude/specs/005_lean4_language_research/]

- [ ] **RL Training Loops for AI Systems in LEAN 4** - Research reinforcement learning training loops for AI theorem proving in LEAN 4-implemented proof systems [.claude/specs/007_rl_proof_reasoning_lean/]

- [ ] **Provability-Fabric LEAN+Rust+Python Integration Analysis** - Comparative analysis of provability-fabric's integration pattern vs. RL research recommendations [.claude/specs/008_lean_rust_python_integration_research/]

- [ ] **LEAN 4 Modal Logic Implementation Best Practices** - Best practices synthesis with codebase analysis for bimodal logic proofs, soundness/completeness theorems, and proof automation [.claude/specs/021_lean4_bimodal_logic_best_practices/]

- [ ] **Temporal Duality Soundness Proof Analysis** - Comprehensive analysis of remaining sorry cases in temporal duality soundness proof and recommended resolution approaches [.claude/specs/027_temporal_duality_sorry_resolution/]

- [ ] **High Priority Tasks Analysis** - Current state analysis of high-priority tasks with advantages, motivations, and implementation costs [.claude/specs/032_research_priority_tasks_analysis/]

- [ ] **Dependency Analysis: Aesop, Mathlib, Batteries** - Analysis of costs, benefits, and standard practices for managing dependencies [.claude/specs/042_dependency_independence_research/]

---

## Saved

(No preserved content)

---

## Backlog

(No preserved content)

---

## Abandoned

(No abandoned projects)

---

## Completed

(Completed tasks tracked via git history - see maintenance workflow)

---

## Project References

- **Implementation Status**: [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
- **Known Limitations**: [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations)
- **System Design**: [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md)
- **Technical Debt**: [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md)
- **Maintenance Workflow**: [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md)

---

**Last Updated**: 2025-12-08 (Added spec 047 - Remove Derivable Axioms from Perpetuity.lean)

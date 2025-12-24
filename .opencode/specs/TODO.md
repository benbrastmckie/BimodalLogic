# TODO

**Last Updated:** 2025-12-23

## Overview

- **Total Tasks:** 11
- **Completed:** 0
- **High Priority:** 0
- **Medium Priority:** 1
- **Low Priority:** 10

---

## High Priority
 
### Automation
 
 
---
 
## Medium Priority


### Maintenance
### Automation

### 159. Revise /optimize command plan output to match plan format standard
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-23
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/optimize.md
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/standards/commands.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Revise the /optimize command so that any plan it generates conforms exactly to the plan format standard defined in `.opencode/context/common/standards/plan.md`, including required metadata, phase structure, status markers, and research input handling.
- **Acceptance Criteria**:
  - [ ] /optimize command documentation and template reference `.opencode/context/common/standards/plan.md` and enforce required sections/ordering (context, role, task, workflow_execution, routing_intelligence, artifact_management, quality_standards, usage_examples, validation).
  - [ ] Generated plans include correct status markers, timestamps, and phase scaffolding matching the standard, with no missing required fields.
  - [ ] Research inputs are harvested/linked when present; warnings are emitted for missing/dangling links without creating directories.
  - [ ] Lazy directory creation is preserved (no project roots/subdirs created during validation-only runs), and numbering/state updates remain consistent.
  - [ ] Command metadata documents dry-run/routing-check behavior without artifact creation.
- **Impact**: Ensures /optimize emits standard-compliant plans, improving consistency across planning workflows and downstream execution.

### 155. Optimize .opencode command subagent routing and metadata

- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-24
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

- **Files Affected**:
  - .opencode/command/
  - .opencode/context/common/standards/
  - .opencode/context/common/system/
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Systematically optimize .opencode command routing to delegate to the correct subagents at the right time, and add explicit subagent metadata to each command file to clarify execution and delegation flows.
- **Acceptance Criteria**:
  - [x] Inventory all available subagents with their capabilities, required contexts, and MCP/server prerequisites.
  - [x] For each .opencode command, map required subagents and update command metadata to list invoked subagents and invocation order.
  - [x] Update command execution flows to delegate to the correct subagents with proper timing while respecting lazy directory creation and status-marker standards.
  - [x] Add dry-run or routing-check paths that validate subagent selection without creating directories or artifacts.
  - [x] TODO/state updates remain consistent with numbering rules and status markers, and no project directories are created during routing checks.
- **Impact**: Improves reliability and clarity of command execution by ensuring correct subagent delegation and transparent metadata.
- **Research**: [.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/reports/research-001.md](.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/reports/research-001.md) — Inventory of subagents, MCP validation requirements, and per-command routing/metadata recommendations.
- **Plan**: [.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/plans/implementation-001.md](.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/plans/implementation-002.md) — Phased updates to command docs/standards adding subagent/MCP/registry metadata, dry-run routing-checks, and lazy-creation/status-sync flow documentation.

### 160. Fix /task status syncing to TODO and linked plan ✅
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-24
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Plan**: [.opencode/specs/160_fix_task_status_syncing_to_todo_and_linked_plan/plans/implementation-001.md](.opencode/specs/160_fix_task_status_syncing_to_todo_and_linked_plan/plans/implementation-001.md)
- **Plan Summary**: Phased fix for atomic /task status sync, tests, and doc updates.
- **Files Affected**:
  - .opencode/command/task.md
  - .opencode/agent/subagents/task-executor.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Resolve the /task command issue where task status updates sometimes fail to write to `.opencode/specs/TODO.md` and to the linked plan file (when present), ensuring atomic updates and marker parity.
- **Acceptance Criteria**:
  - [x] Reproduce and fix the status sync failure path so /task always updates TODO.md and the linked plan phases atomically.
  - [x] Add/adjust tests or dry-run checks to cover TODO/plan status-marker synchronization and regression-proof the fix.
  - [x] Preserve lazy directory creation (no new roots/subdirs unless an artifact is written) and numbering/state consistency during status updates.
  - [x] Document the fix and update command/agent docs to reflect the corrected status sync behavior.
- **Impact**: Restores reliable status synchronization for /task, preventing TODO/plan divergence and ensuring downstream automation accuracy.

### 161. Ensure /task delegates batch coordinator for ranged execution ✅
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [.opencode/specs/161_ensure_task_delegates_batch_coordinator_for_ranged_execution/reports/research-001.md](.opencode/specs/161_ensure_task_delegates_batch_coordinator_for_ranged_execution/reports/research-001.md)
- **Plan**: [.opencode/specs/161_ensure_task_delegates_batch_coordinator_for_ranged_execution/plans/implementation-001.md](.opencode/specs/161_ensure_task_delegates_batch_coordinator_for_ranged_execution/plans/implementation-001.md)
- **Plan Summary**: Implement range/list parsing, batch delegation contract, wave scheduler with dependency-aware status sync, tests/routing checks, and doc updates.
- **Research Summary**: Range parsing + batch delegation contract, wave-based dependency scheduling, atomic status-sync hooks, lazy-creation guardrails, and doc updates identified.
- **Files Affected**:
  - .opencode/command/task.md
  - .opencode/agent/subagents/task-executor.md
  - .opencode/agent/subagents/specialists/batch-task-orchestrator.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Ensure the /task command delegates to the correct batch coordinator agent when a range of tasks is provided, analyzes dependencies, and executes tasks in waves in parallel.
- **Acceptance Criteria**:
  - [x] /task detects ranges and routes to batch-task-orchestrator with dependency analysis before execution.
  - [x] Wave-based parallel execution honors dependencies and preserves status sync with TODO/state/plan links.
  - [x] Dry-run/routing-check path exercises coordinator selection without creating project directories or artifacts.
  - [x] Documentation updated in command and agent files to reflect routing, dependency handling, and lazy creation guardrails.
- **Impact**: Provides safe, parallel execution for ranged /task invocations with correct dependency handling and status synchronization.

### 162. Align /task with /implement summary artifact requirements ✅
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [.opencode/specs/162_align_task_with_implement_summary_artifact_requirements/reports/research-001.md](.opencode/specs/162_align_task_with_implement_summary_artifact_requirements/reports/research-001.md)
- **Plan**: [.opencode/specs/162_align_task_with_implement_summary_artifact_requirements/plans/implementation-002.md](.opencode/specs/162_align_task_with_implement_summary_artifact_requirements/plans/implementation-002.md)
- **Research Summary**: /task must emit implementation summaries when work occurs, mirroring /implement; enforce lazy-creation guards, summary hooks in task-executor/implementation-orchestrator, and doc/test coverage without relying on dry-run paths.
- **Files Affected**:
  - .opencode/command/task.md
  - .opencode/agent/subagents/task-executor.md
  - .opencode/agent/subagents/implementation-orchestrator.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/standards/commands.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Identify /implement command behaviors not present in /task and update /task to incorporate them, ensuring each subagent that implements a task produces a summary artifact per artifact-management, while preserving lazy directory creation and numbering/state sync.
- **Acceptance Criteria**:
  - [x] Gap analysis completed documenting /implement behaviors missing in /task and mapping required updates.
  - [x] /task command and task-executor/implementation subagents enforce creation of summary artifacts that follow artifact-management.md, without violating lazy directory creation.
  - [x] Standards/docs updated to reflect the summary requirement and any new routing/metadata fields; Language metadata remains mandatory.
  - [x] TODO/state update flow remains consistent and tests cover the new summary requirement (implementation work creates summaries; status-only paths do not), with lazy-creation preserved.
- **Impact**: Brings /task parity with /implement for artifact expectations, improving auditability and consistency of implementation outputs.

### 163. Fix /research and /plan task-number parser regression (range/number handling)
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24T12:00:00Z
- **Priority**: Medium

- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [.opencode/specs/163_fix_research_and_plan_task_number_parser_regression_range_number_handling/reports/research-001.md](.opencode/specs/163_fix_research_and_plan_task_number_parser_regression_range_number_handling/reports/research-001.md)
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/command/plan.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/planner.md
  - .opencode/agent/subagents/task-executor.md
  - .opencode/context/common/standards/commands.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Identify and fix the regression where running `/research 161` (and similarly `/plan 161`) prompts for a task number instead of accepting the provided numeric input; ensure proper parsing and preflight status updates for numeric task IDs and ranges.
- **Acceptance Criteria**:
  - [x] Reproduce the `/research 161` (and `/plan 161`) failure and document the root cause in the command/agent docs.
  - [x] Update parsing/routing so numeric task IDs (and ranges if supported) are accepted and status is set to `[IN PROGRESS]` with timestamps before dispatching research or planning.
  - [x] Guidance updated for numeric IDs and range inputs; no project directories created unless writing artifacts.
  - [x] TODO/state sync remains intact, and lazy directory creation is preserved (only create project root/reports or plans when emitting artifacts).
- **Impact**: Restores correct `/research` and `/plan` handling of task-number inputs, enabling users to run research or planning directly from TODO entries without confusion.

### 164. Remove dry-run functionality across .opencode
- **Effort**: 3 hours
- **Status**: [ABANDONED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/
  - .opencode/agent/
  - .opencode/context/common/standards/commands.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Remove all dry-run functionality across the .opencode system, ensuring commands and agents no longer offer dry-run or routing-check modes while preserving numbering, status markers, and lazy directory creation guarantees.
- **Acceptance Criteria**:
  - [ ] Inventory and remove dry-run/routing-check flags, code paths, and documentation across commands and subagents, updating command docs and standards accordingly.
  - [ ] Ensure status-marker flows and lazy directory creation remain correct after removal; no project roots/subdirs are created without artifact writes.
  - [ ] Update tests to reflect removal of dry-run behavior and add regression coverage to prevent reintroduction.
  - [ ] TODO/state sync remains consistent with numbering rules and language metadata requirements.
- **Impact**: Simplifies command behaviors by eliminating dry-run modes, reducing complexity while maintaining correct state and artifact guardrails.

### 165. Make /add command single-description with immediate number increment
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/add.md
  - .opencode/context/common/standards/commands.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Update /add so it accepts only a task description (plus optional --file inputs), reads `next_project_number` from state.json, immediately increments it to reserve the number, and appends TODO/state entries with required metadata without creating project directories.
- **Acceptance Criteria**:
  - [ ] /add reads `next_project_number` from `.opencode/specs/state.json`, reserves it, and increments the field before writing TODO/state to prevent duplicate IDs.
  - [ ] TODO.md entries created by /add include complete metadata (Status [NOT STARTED], Language, Effort, Priority, Blocking/Dependencies, Files Affected, Acceptance Criteria, Impact) and remain under the correct priority section without creating project roots/subdirs.
  - [ ] state.json `pending_tasks` is updated with the new task, status `not_started`, and UTC `created_at`; numbering remains consistent with TODO.md.
  - [ ] Command doc/standards updated to describe the single-argument behavior, immediate increment rule, and lazy directory guardrails; no other registries/roots are created by /add.
- **Impact**: Prevents task number collisions and keeps /add lightweight and consistent with numbering/state rules.

### 166. Remove dry-run functionality throughout .opencode commands and agents
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/
  - .opencode/agent/
  - .opencode/context/common/standards/commands.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Remove all dry-run and routing-check functionality across .opencode commands and agents to simplify execution flows while preserving numbering, status markers, lazy directory creation, and registry/state integrity; update all related documentation accordingly.
- **Acceptance Criteria**:
  - [ ] Inventory and remove dry-run/routing-check flags, code paths, and documentation references across commands and subagents, updating standards/templates to match.
  - [ ] Confirm status-marker flows and lazy directory creation remain correct after removal; no project roots/subdirs are created without artifact writes.
  - [ ] Update or add tests to reflect removal of dry-run behavior and guard against reintroduction.
  - [ ] Preserve TODO/state sync and Language metadata requirements during and after the removals.
- **Impact**: Simplifies command and agent behaviors, reducing complexity while keeping state, numbering, and artifact guardrails intact.
- **Research**: [.opencode/specs/166_remove_dry-run_functionality_throughout_opencode_commands_and_agents/reports/research-001.md](.opencode/specs/166_remove_dry-run_functionality_throughout_opencode_commands_and_agents/reports/research-001.md)

### 167. Fix /revise task-number/prompt parsing regression and align with /plan and /research
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/revise.md
  - .opencode/agent/subagents/planner.md
  - .opencode/agent/subagents/task-executor.md
  - .opencode/context/common/standards/commands.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Investigate and fix the /revise regression where invoking `/revise 162 "Remove dry-run references"` incorrectly prompts for task number and revision prompt despite both being provided; align parsing and preflight behavior with the already-fixed /plan and /research flows.
- **Acceptance Criteria**:
  - [ ] Reproduce the /revise prompt bug and document the root cause compared to /plan and /research fixes.
  - [ ] Update /revise parsing to accept numeric task IDs and embedded revision prompts without re-prompting; ensure preflight marks the task `[IN PROGRESS]` with timestamps when appropriate.
  - [ ] Verify lazy directory creation and numbering/state sync remain intact; no project roots/subdirs are created without artifact writes.
  - [ ] Update command/agent docs and tests to cover the fixed parsing path and prevent regression.
- **Impact**: Restores reliable /revise usage with numeric IDs and prompts, matching /plan and /research behavior and preventing user confusion.

---
 
   ## Low Priority




### Repository Cleanup

### Metalogic Completeness

### 132. Prove Lindenbaum maximal consistency lemma in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Formalize and prove the Lindenbaum maximal consistency lemma to eliminate the first axiom placeholder.
- **Acceptance Criteria**:
  - [ ] Lindenbaum lemma proven and axiom removed
  - [ ] Proof integrates with existing canonical model scaffolding
  - [ ] Related tests added or updated
- **Impact**: Unlocks subsequent completeness proofs by establishing maximal consistency.

### 133. Build canonical model constructors in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Implement canonical model construction helpers and remove associated axiom stubs.
- **Acceptance Criteria**:
  - [ ] Canonical model constructors implemented
  - [ ] Corresponding axiom placeholders removed
  - [ ] Construction type-checks with existing definitions
- **Impact**: Provides the core model for subsequent truth lemma proofs.

### 134. Prove truth lemma structure in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 133
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Prove the truth lemma for the canonical model, removing the corresponding axiom placeholder.
- **Acceptance Criteria**:
  - [ ] Truth lemma proven and axiom removed
  - [ ] Proof integrates with canonical model components
  - [ ] Tests (or placeholders) updated to exercise lemma
- **Impact**: Establishes the key bridge between syntax and semantics for completeness.

### 135. Remove provable_iff_valid sorry in Completeness.lean
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132, 133, 134
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Complete the `provable_iff_valid` theorem using the proven canonical model and truth lemma to eliminate the remaining sorry.
- **Acceptance Criteria**:
  - [ ] `provable_iff_valid` fully proven
  - [ ] No remaining axiom or sorry placeholders in Completeness.lean
  - [ ] Completeness tests added or updated
- **Impact**: Delivers full completeness, enabling derivability from validity.

### Decidability

### 136. Design Decidability.lean architecture and signatures
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
- **Description**: Define the module structure, main theorems, and function signatures for decidability (tableau and satisfiability checks).
- **Acceptance Criteria**:
  - [ ] Module skeleton with signatures for tableau and decision procedures
  - [ ] Documentation comments outline intended algorithms
  - [ ] No build warnings from new declarations
- **Impact**: Establishes a foundation for future decidability proofs and implementations.

### 137. Implement tableau core rules in Decidability.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 136
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
- **Description**: Implement the core tableau expansion rules and supporting helpers for validity checking.
- **Acceptance Criteria**:
  - [ ] Tableau expansion rules implemented and type-checking
  - [ ] Basic examples compile demonstrating rule application
  - [ ] No placeholder axioms for these rules remain
- **Impact**: Provides executable building blocks for the decision procedure.

### 138. Implement satisfiability and validity decision procedure tests
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 136, 137
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
  - LogosTest/Metalogic/DecidabilityTest.lean (new or updated)
- **Description**: Wire the tableau components into a decision procedure and add tests covering satisfiable and unsatisfiable cases.
- **Acceptance Criteria**:
  - [ ] Decision procedure implemented and compiles
  - [ ] Tests cover satisfiable and unsatisfiable scenarios
  - [ ] No remaining placeholder axioms in the decision procedure path
- **Impact**: Delivers an initial, test-backed decision procedure for TM logic.

### Layer Extensions (Future Planning)

### 139. Draft Layer 1 counterfactual operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 1 counterfactual operators, defining `box_c` and `diamond_m` semantics and integration points.
- **Acceptance Criteria**:
  - [ ] Draft plan describing operators, semantics, and required modules
  - [ ] Architecture updated with Layer 1 scope and assumptions
  - [ ] Clear follow-on tasks identified
- **Impact**: Provides roadmap for counterfactual extensions post Layer 0.

### 140. Draft Layer 2 epistemic operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 2 epistemic operators (`K`, `B`) including semantics and proof obligations.
- **Acceptance Criteria**:
  - [ ] Draft plan outlines semantics, target theorems, and module impacts
  - [ ] Architecture updated with Layer 2 scope and assumptions
  - [ ] Follow-on tasks identified
- **Impact**: Establishes roadmap for epistemic extensions.

### 141. Draft Layer 3 normative operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 3 normative operators (`O`, `P`) including semantics and proof obligations.
- **Acceptance Criteria**:
  - [ ] Draft plan outlines semantics, target theorems, and module impacts
  - [ ] Architecture updated with Layer 3 scope and assumptions
  - [ ] Follow-on tasks identified
- **Impact**: Provides a roadmap for normative logic extensions.

---

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
- **Status**: [IN PROGRESS]
- **Started**: 2025-12-23
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
  - [ ] Inventory all available subagents with their capabilities, required contexts, and MCP/server prerequisites.
  - [ ] For each .opencode command, map required subagents and update command metadata to list invoked subagents and invocation order.
  - [ ] Update command execution flows to delegate to the correct subagents with proper timing while respecting lazy directory creation and status-marker standards.
  - [ ] Add dry-run or routing-check paths that validate subagent selection without creating directories or artifacts.
  - [ ] TODO/state updates remain consistent with numbering rules and status markers, and no project directories are created during routing checks.
- **Impact**: Improves reliability and clarity of command execution by ensuring correct subagent delegation and transparent metadata.
- **Research**: [.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/reports/research-001.md](.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/reports/research-001.md) — Inventory of subagents, MCP validation requirements, and per-command routing/metadata recommendations.
- **Plan**: [.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/plans/implementation-001.md](.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/plans/implementation-002.md) — Phased updates to command docs/standards adding subagent/MCP/registry metadata, dry-run routing-checks, and lazy-creation/status-sync flow documentation.

### 160. Fix /task status syncing to TODO and linked plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/task.md
  - .opencode/agent/subagents/task-executor.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Resolve the /task command issue where task status updates sometimes fail to write to `.opencode/specs/TODO.md` and to the linked plan file (when present), ensuring atomic updates and marker parity.
- **Acceptance Criteria**:
  - [ ] Reproduce and fix the status sync failure path so /task always updates TODO.md and the linked plan phases atomically.
  - [ ] Add/adjust tests or dry-run checks to cover TODO/plan status-marker synchronization and regression-proof the fix.
  - [ ] Preserve lazy directory creation (no new roots/subdirs unless an artifact is written) and numbering/state consistency during status updates.
  - [ ] Document the fix and update command/agent docs to reflect the corrected status sync behavior.
- **Impact**: Restores reliable status synchronization for /task, preventing TODO/plan divergence and ensuring downstream automation accuracy.

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

# TODO

**Last Updated:** 2025-12-23

## Overview

- **Total Tasks:** 20
- **Completed:** 5
- **High Priority:** 1
- **Medium Priority:** 8
- **Low Priority:** 11

---

## High Priority
 
### Automation
 
### 151. Ensure /task pre-updates TODO and plans to IN PROGRESS before work
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-23
- **Priority**: High
- **Language**: shell
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/standards/tasks.md
- **Description**: Ensure `/task` immediately sets the targeted task's status marker in TODO.md to [IN PROGRESS], mirrors that status to the linked plan if present, and then continues execution while keeping plan phase headers synced as phases start, block, or complete.
- **Acceptance Criteria**:
  - [ ] `/task` sets the TODO status marker to [IN PROGRESS] immediately on invocation for the chosen task.
  - [ ] When a plan link exists, `/task` also sets the plan status marker to [IN PROGRESS] before performing other actions.
  - [ ] Plan phase headers are updated with appropriate status markers and timestamps as phases are started, blocked, or completed.
  - [ ] Behavior works when no plan is linked (updates TODO only) and avoids pre-creating project directories.
  - [ ] State/registry synchronization remains accurate with no regression to existing command flows.
- **Impact**: Aligns `/task` execution with status-marker standards so progress is visible in TODO and plans before work proceeds.
 
---
 
## Medium Priority


### Maintenance

### 144. Update context references after refactor
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-23
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/specs/127_context_refactor/plans/context-references-plan-001.md
  - .opencode/context/index.md
  - .opencode/context/common/
  - .opencode/context/project/
- **Description**: Remap agent and command context references using the references update plan after the refactor lands, ensuring all recorded targets point to the new structure and clearing placeholders.
- **Acceptance Criteria**:
  - [x] Reference mappings updated per the plan with placeholders resolved using the finalized structure
  - [x] Cross-links in index and per-domain READMEs point to the new locations with no 404s (context docs already refreshed in task 143)
  - [x] Link/reference verification pass completed and issues fixed (ripgrep sweep for legacy prefixes/filenames)
  - [x] References plan annotated or updated to reflect completed remapping
- **Impact**: Keeps agents and commands aligned to the new context layout, preventing stale references after the refactor.
- **Plan**: [Plan v3](.opencode/specs/127_context_refactor/plans/implementation-002.md)
- **Research**: [Research Report](.opencode/specs/144_update_context_references_after_refactor/reports/research-001.md) — Identifies old→new mapping (common/ vs project/{logic,lean4}, Lean overlay rename) and per-file reference updates for agents/commands; recommends link-check after edits.

### Automation

### 128. Implement caching and context helpers in ProofSearch
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-23
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 126, 127
- **Files Affected**:
  - Logos/Core/Automation/ProofSearch.lean
- **Description**: Implement caching and context management functions (including `search_with_cache`, `box_context`, and `future_context`) to avoid redundant exploration and handle modal/temporal context changes.
- **Acceptance Criteria**:
  - [x] `search_with_cache` implemented with cache hits tracked
  - [x] `box_context` and `future_context` implemented and integrated
  - [x] Repeated subgoals avoided via cache in tests
- **Impact**: Reduces redundant search work and stabilizes modal/temporal context handling.
- **Research**: [Research Report](.opencode/specs/128_implement_caching_and_context_helpers_in_proofsearch/reports/research-001.md) — Replace list cache/visited with hash-based keyed on transformed contexts, add stats, and test cache hits/visit-limit/ modal vs temporal separation.
- **Plan**: [Plan v1](.opencode/specs/128_implement_caching_and_context_helpers_in_proofsearch/plans/implementation-001.md) — Lean plan to add hash-based cache/visited with stats, transformed-context keys for modal/temporal recursion, and regression tests for cache hits and visit limits.
- **Summary**: [Implementation Summary](.opencode/specs/128_implement_caching_and_context_helpers_in_proofsearch/summaries/implementation-summary-20251223.md) — Hash-based cache/visited with stats, transformed-context keys for modal/temporal recursion, and regression tests for cache hits and visit limits.

### 129. Prove temporal swap lemmas in Truth.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Semantics/Truth.lean
- **Description**: Replace the temporal swap validity `sorry` placeholders with full proofs for the remaining lemmas.
- **Acceptance Criteria**:
  - [ ] All temporal swap validity sorries removed
  - [ ] Proofs compile and tests pass for Truth.lean
  - [ ] No regressions in semantics tests
- **Impact**: Completes semantics correctness by removing remaining technical debt.

### 130. Prove domain extension lemmas in Truth.lean
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 129
- **Files Affected**:
  - Logos/Core/Semantics/Truth.lean
- **Description**: Prove the remaining domain extension lemmas that ensure temporal swap validity under domain changes.
- **Acceptance Criteria**:
  - [ ] Domain extension lemmas proven and sorries removed
  - [ ] Related proofs reuse existing transport lemmas where possible
  - [ ] Semantics test suite passes
- **Impact**: Finalizes semantics completeness and eliminates remaining technical debt.

### 154. Fix temporal swap strategy for Truth.lean (supports Tasks 129 & 130)
- **Effort**: 2 hours
- **Status**: [IN PROGRESS]
- **Started**: 2025-12-23
- **Priority**: Medium
- **Language**: lean
- **Blocking**: 129, 130
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Semantics/Truth.lean
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
- **Description**: Evaluate whether to introduce a semantic time-reversal lemma (`is_valid φ ↔ is_valid φ.swap_past_future`) to close the remaining Truth.lean sorries, or to refactor the temporal-duality soundness proof to avoid the strong lemma by restructuring `derivable_implies_swap_valid` with weaker helpers.
- **Acceptance Criteria**:
  - [ ] Compare both strategies with implications for existing lemmas and test stability (Truth.lean, Soundness.lean)
  - [ ] Recommend a path (time-reversal lemma vs. refactor) with rationale, risks, and proof obligations
  - [ ] Outline the concrete next steps for Tasks 129 and 130 based on the recommended path (including any weaker helper lemmas or axioms needed)
- **Impact**: Selects the most viable approach to unblock completion of temporal swap and domain extension lemmas, reducing semantics technical debt.
- **Research**: [.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-001.md](.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-001.md)
- **Research (update)**: [.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-002.md](.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-002.md)
- **Plan**: [.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/plans/implementation-002.md](.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/plans/implementation-002.md)
- **Summary**: Plan v2 executes Branch B directly in Lean: refactor `derivable_implies_swap_valid` via IH/mutual IH with local transport lemmas, align `Soundness.lean`, run tests, and then retire tasks 129/130 as abandoned after this implementation.

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
- **Plan**: [.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/plans/implementation-001.md](.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/plans/implementation-001.md) — Phased updates to command docs/standards adding subagent/MCP/registry metadata, dry-run routing-checks, and lazy-creation/status-sync flow documentation.

### 152. Standardize command templates and migrate command docs ✅
 
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-23
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/context/common/templates/
  - .opencode/context/common/standards/commands.md
  - .opencode/command/
  - .opencode/meta/
- **Description**: Add a unified command template and commands standard, migrate all command docs to the new format (removing legacy XML tags and explicit subagent invocations), and extend /meta context/templates to support the updated agent system conventions.
- **Acceptance Criteria**:
  - [x] Command template added under `.opencode/context/common/templates/` aligned with status markers and lazy directory rules.
  - [x] `commands.md` standard added under `.opencode/context/common/standards/` detailing formatting, status markers, metadata, and agent invocation conventions.
  - [x] All command docs in `.opencode/command/` migrated to the new standard (legacy XML/subagent tags removed) with consistent examples.
  - [x] /meta context/templates updated to reflect the new command standards and extension/refactor guidance for the agent system.
- **Impact**: Unifies command documentation and templates, reduces drift between agents, and enables consistent future command extensions without legacy XML patterns.
- **Research**: [.opencode/specs/152_standardize_command_templates_and_migrate_command_docs/reports/research-001.md](.opencode/specs/152_standardize_command_templates_and_migrate_command_docs/reports/research-001.md) — Defines commands.md outline, command template, migration steps, and registry/lazy-creation coordination notes.
- **Plan**: [.opencode/specs/152_standardize_command_templates_and_migrate_command_docs/plans/implementation-002.md](.opencode/specs/152_standardize_command_templates_and_migrate_command_docs/plans/implementation-002.md) — Reversed plan (v2) to restore YAML front matter and @subagent/XML markup across command docs/templates and meta outputs aligned to meta/context exemplars.
- **Summary**: [.opencode/specs/152_standardize_command_templates_and_migrate_command_docs/summaries/implementation-summary-20251223.md](.opencode/specs/152_standardize_command_templates_and_migrate_command_docs/summaries/implementation-summary-20251223.md)
 
 
### 153. Revise /research and /plan commands to enforce status updates
 
 
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-23
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
  - .opencode/context/common/system/status-markers.md
  - .opencode/command/research.md
  - .opencode/command/plan.md
- **Description**: Update `/research` and `/plan` command flows to set the targeted task to [IN PROGRESS] at invocation, then to [RESEARCHED] or [PLANNED] on completion with timestamps, while syncing TODO/state and linked artifacts without premature project directory creation.
- **Acceptance Criteria**:
  - [x] `/research` sets the task status to [IN PROGRESS] before work begins and updates to [RESEARCHED] with timestamps in TODO/state and the generated research report.
  - [x] `/plan` sets the task status to [IN PROGRESS] before planning and updates to [PLANNED] with timestamps in TODO/state and the generated plan artifact.
  - [x] Status propagation honors lazy directory creation: project roots/subdirs are created only when writing the first artifact; no pre-creation.
  - [x] Status-markers standard documents the new `/research` and `/plan` transitions and end markers.
  - [x] Regression checks confirm existing `/task` and `/todo` flows remain unaffected.
- **Impact**: Aligns research and planning commands with the standardized status lifecycle, improving visibility and consistency across TODO, plans, and state.
- **Research**: None linked
- **Summary**: [.opencode/specs/153_revise_research_and_plan_commands_to_enforce_status_updates/summaries/implementation-summary-20251223.md](.opencode/specs/153_revise_research_and_plan_commands_to_enforce_status_updates/summaries/implementation-summary-20251223.md)
 
 ---
 
 ## Low Priority


### Repository Cleanup

### 131. Clean up Archive examples
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-23
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Archive/
  - Logos/Examples/
- **Summary**: [.opencode/specs/131_clean_up_archive_examples/summaries/implementation-summary-20251223.md](.opencode/specs/131_clean_up_archive_examples/summaries/implementation-summary-20251223.md)
- **Description**: Review Archive examples, migrate any useful samples into active example locations, and remove obsolete files to reduce clutter.
- **Acceptance Criteria**:
  - [x] Archive reviewed and obsolete files removed or relocated
  - [x] Useful examples moved to active examples directory
  - [x] No broken references to removed files
- **Impact**: Keeps repository lean and focused on current code.

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

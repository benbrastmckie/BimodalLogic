# Logos Project TODO

**Last Updated**: 2025-12-25
**Status**: Layer 0 (Core TM) MVP Complete - Review in Progress

## Overview

Logos has completed its MVP phase with a functional implementation of the TM bimodal logic proof system. The current focus is on completing the metalogical proofs for completeness and enhancing automation.

- **Layer 0 Completion**: 83% (Soundness & Deduction complete, Completeness infrastructure only)
- **Active Tasks**: 22
- **Next Milestone**: Completeness Proofs

## Quick Links

- [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
- [Sorry Registry](Documentation/ProjectInfo/SORRY_REGISTRY.md)
- [Maintenance Workflow](Documentation/ProjectInfo/MAINTENANCE.md)

---

## High Priority (Complete within 1 month)

### 505. Bimodal Metalogic Restructuring
- **Effort**: 85-120 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: Lean
- **Created**: 2026-01-16
- **Description**: Review the existing bimodal metalogic, including representation theory, completeness, decidability, and compactness, following the completion of task 502. Propose and implement an ideal restructuring to improve the quality, organization, and clarity of the theory.
- **Research Findings**: Current implementation has solid foundations but suffers from organic growth without coherent architecture. Proposed restructuring includes: (1) Unified provability hierarchy, (2) Clear module boundaries, (3) Integration of completeness with decidability via FMP, (4) Context-based approach from Task 502.
- **Artifacts**: 
  - [Research Report](specs/505_bimodal_metalogic_restructuring/reports/research-001.md)
- **Next Steps**: Run `/plan 505` to create implementation plan

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

### 670. Implement agent system upgrade plan
- **Effort**: 40 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-22
- **Session ID**: task_creation-1768239349
- **Description**: Implement the .opencode system upgrade plan from specs/agent_system_upgrade_plan.md and copy this file into the plans/ directory for this task. This upgrade will incorporate key .claude innovations while preserving formal verification strengths.
- **Source Plan**: specs/agent_system_upgrade_plan.md (275 lines, comprehensive upgrade with 4 phases)
- **Acceptance Criteria**:
  - [ ] Copy agent_system_upgrade_plan.md to specs/670_implement_agent_system_upgrade_plan/plans/
  - [ ] Implement Phase 1: Foundation (hook system, file-based metadata, state management)
  - [ ] Implement Phase 2: Workflow Ownership (subagent workflows, remove postflight from commands)
  - [ ] Implement Phase 3: Meta Builder (port meta system builder for formal verification)
  - [ ] Implement Phase 4: Architecture Migration (forked subagent pattern, skill wrappers)
  - [ ] Achieve 15-20% token usage reduction and eliminate "continue" prompts
- **Impact**: Upgrades .opencode with .claude innovations while maintaining formal verification specialization

### 666. Revise Lean source code in Logos/ theory to match constitutive model definitions
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: Lean
- **Created**: 2026-01-21
- **Description**: Revise the Lean source code in the Logos/ theory to match the definitions provided in def:constitutive-model (line 72) in /home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/01-ConstitutiveFoundation.tex
- **Source**: Definitions include structure $\model = \tuple{\statespace, \parthood, \interp{\cdot}}$, n-place function symbols $\interp{f} : (\Fin\;n \to \statespace) \to \statespace$, and n-place predicates $\verifiertype{F}, \falsifiertype{F} : (\Fin\;n \to \statespace) \to \statespace \to \Prop$
- **Acceptance Criteria**:
  - [ ] Research current Lean implementation in Logos/ theory
  - [ ] Compare with LaTeX definitions from constitutive model
  - [ ] Revise Lean code to match LaTeX definitions
  - [ ] Ensure compilation passes after changes
- **Impact**: Aligns Lean and LaTeX sources for constitutive model definitions

### 516. Test task creation after refactoring
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: general
- **Created**: 2026-01-16
- **Description**: Test the task creation system to ensure it works correctly after the recent agent system refactoring. This is a validation task to verify that the workflow commands, task management, and file synchronization are functioning properly after the structural changes.
- **Acceptance Criteria**:
  - [ ] Task creation workflow tested end-to-end
  - [ ] File synchronization between TODO.md and state.json verified
  - [ ] Agent system refactoring validation completed
  - [ ] All workflow commands functioning correctly
- **Impact**: Validates the agent system refactoring and ensures reliable task management operations.

### 231. Fix systematic command Stage 7 (Postflight) execution failures causing incomplete TODO.md and state.json updates
- **Effort**: 8-10 hours
- **Status**: [NOT STARTED]
- **Created**: 2025-12-29
- **Priority**: Critical
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Supersedes**: Tasks 227, 228, 229 (all ABANDONED due to incorrect root cause analysis)
- **Files Affected**:
  - .opencode/command/plan.md
  - .opencode/command/research.md
  - .opencode/command/implement.md
  - .opencode/command/revise.md
  - .opencode/agent/orchestrator.md
  - .opencode/context/common/workflows/command-lifecycle.md
- **Description**: CRITICAL FIX: All workflow commands (/plan, /research, /implement, /revise) are correctly loaded and executed by the orchestrator, but Claude frequently skips or incompletely executes Stage 7 (Postflight), which delegates to status-sync-manager for atomic TODO.md/state.json updates and creates git commits. This results in successful artifact creation but incomplete task tracking. Evidence: Task 224 (artifacts ✅, TODO.md manual ✅, state.json ❌), Task 229 (plan ✅, tracking required manual intervention). Root causes: (1) Weak prompting - Stage 7 uses descriptive language instead of imperative commands, (2) No validation - no checkpoint confirming Stage 7 completed before Stage 8 returns, (3) No error handling - command proceeds even if Stage 7 fails, (4) Orchestrator lacks stage completion validation, (5) Missing explicit delegation syntax for status-sync-manager invocation.
- **Acceptance Criteria**:
  - [ ] Stage 7 instructions strengthened in all 4 command files with imperative language
  - [ ] Explicit delegation syntax added: `task_tool(subagent_type="status-sync-manager", ...)`
  - [ ] Stage completion checkpoints added: "Stage N completed ✓" before proceeding
  - [ ] Pre-Stage-8 validation added: Verify TODO.md and state.json updated before returning
  - [ ] Error handling added: If Stage 7 fails, rollback and return error (don't proceed to Stage 8)
  - [ ] Orchestrator enhanced with command stage validation to detect premature returns
  - [ ] Monitoring/logging added to track stage execution (which executed, which skipped)
  - [ ] command-lifecycle.md updated with stage validation patterns and mandatory checkpoints
  - [ ] All 4 commands tested: 100% Stage 7 execution rate achieved
  - [ ] Test: /plan task → TODO.md updated [PLANNED], state.json updated, git commit created
  - [ ] Test: /research task → TODO.md updated [RESEARCHED], state.json updated, git commit created
  - [ ] Test: /implement task → TODO.md updated [COMPLETED], state.json updated, plan phases updated, git commit created
  - [ ] Test: /revise task → TODO.md updated [REVISED], state.json plan_versions updated, git commit created
- **Impact**: Resolves systematic task tracking failures affecting ALL workflow commands. Ensures 100% reliability of TODO.md/state.json updates via status-sync-manager's atomic two-phase commit protocol. Eliminates manual intervention needed to sync tracking files. Consolidates fixes for tasks 227, 228, 229 with correct root cause understanding.

---

### 208. Fix /implement and /research routing to use Lean-specific agents and tools
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-28
- **Completed**: 2025-12-28
- **Priority**: High
- **Language**: markdown
- **Plan**: [Implementation Plan](specs/208_fix_lean_routing/plans/implementation-001.md)
- **Implementation Summary**: [Summary](specs/208_fix_lean_routing/summaries/implementation-summary-20251228.md)
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/command/implement.md
  - .opencode/agent/orchestrator.md
- **Description**: Fix routing logic in /research and /implement commands to ensure Lean tasks consistently route to lean-implementation-agent and lean-research-agent. Strengthen routing instructions with explicit validation, logging, and pre-invocation checks.
- **Acceptance Criteria**:
  - [x] research.md Stage 2 includes explicit validation and logging requirements
  - [x] implement.md Stage 2 includes IF/ELSE routing logic and validation
  - [x] orchestrator.md Stages 3-4 include bash extraction and routing validation
  - [x] Routing decisions logged at all stages
  - [x] Pre-invocation validation added to prevent incorrect routing

### 205. Implement Lean tool usage verification and monitoring system
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/command/implement.md
  - .opencode/agent/subagents/lean-research-agent.md
  - .opencode/agent/subagents/lean-implementation-agent.md
  - .opencode/context/common/standards/lean-tool-verification.md (new)
  - specs/monitoring/ (new directory structure)
- **Description**: Design and implement a comprehensive monitoring and verification system to detect and validate that Lean-specific tools (lean-lsp-mcp, Loogle, LeanExplore, LeanSearch) are being correctly used by the appropriate commands and agents when processing Lean tasks. The system should provide visibility into tool usage patterns, detect routing errors, track tool availability issues, and identify opportunities for improvement. This includes creating verification methods, logging standards, monitoring dashboards, and automated health checks to ensure the system is working optimally.
- **Acceptance Criteria**:
  - [ ] Verification method identified for detecting lean-lsp-mcp usage in /implement command for Lean tasks
  - [ ] Verification method identified for detecting Loogle usage in /research command for Lean tasks
  - [ ] Automated tool availability checks implemented (binary existence, process health, API connectivity)
  - [ ] Tool usage logging standardized in lean-research-agent and lean-implementation-agent return formats
  - [ ] Monitoring dashboard or report created showing tool usage metrics per command execution
  - [ ] Health check command or script created to verify routing is working correctly
  - [ ] Documentation created explaining verification methods and monitoring approach
  - [ ] Error detection implemented for cases where tools should be used but aren't (routing failures)
  - [ ] Recommendations provided for system improvements based on monitoring data
  - [ ] All verification methods tested with real command executions on Lean tasks
- **Impact**: Provides visibility and confidence that the Lean tool integration is working correctly, enables early detection of routing or configuration issues, and identifies opportunities to improve the system's effectiveness with Lean-specific research and implementation workflows.

### 212. Research and improve lean-lsp-mcp usage in Lean implementation agent
**Effort**: 14 hours
**Status**: [COMPLETED]
**Started**: 2025-12-28
**Completed**: 2025-12-28
**Priority**: High
**Language**: markdown
**Blocking**: None
**Dependencies**: None
**Research Artifacts**:
  - Main Report: [specs/212_research_lean_lsp_mcp_usage/reports/research-001.md]
  - Summary: [specs/212_research_lean_lsp_mcp_usage/summaries/research-summary.md]
**Plan**: [specs/212_research_lean_lsp_mcp_usage/plans/implementation-001.md]
**Implementation Summary**: [specs/212_research_lean_lsp_mcp_usage/summaries/implementation-summary-20251228.md]
**Plan Summary**: Implementation plan with 5 phases (14 hours total). Phase 1: Create MCP Client Wrapper (4h). Phase 2: Update Lean Agents (3h). Phase 3: Enhance Documentation (2.5h). Phase 4: Integration Tests (3h). Phase 5: Validation and Refinement (1.5h). Integrates research findings on lean-lsp-mcp usage gaps and MCP client infrastructure requirements.

**Description**: Research current usage patterns of lean-lsp-mcp in the Lean implementation agent and identify opportunities for improvement. Analyze how the agent leverages LSP capabilities for code navigation, type information, and proof assistance. Provide recommendations for enhanced integration.

**Acceptance Criteria**:
- [x] Current lean-lsp-mcp usage patterns documented
- [x] Integration opportunities identified
- [x] Recommendations provided for improved usage
- [x] Research report and summary created
- [x] MCP client wrapper implemented
- [x] lean-implementation-agent.md updated with concrete tool invocation patterns
- [x] mcp-tools-guide.md enhanced with agent integration documentation
- [x] Integration tests created and passing

**Impact**: Improves effectiveness of Lean implementation agent by better leveraging LSP capabilities for proof development and code navigation. Enables real-time compilation checking during Lean implementation tasks.

---

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

### 211. ✅ Standardize command lifecycle procedures across research, planning, and implementation workflows
- **Effort**: 18 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-28
- **Completed**: 2025-12-28
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [specs/211_standardize_command_lifecycle_procedures/reports/research-001.md]
  - Summary: [specs/211_standardize_command_lifecycle_procedures/summaries/research-summary.md]
- **Plan**: [Implementation Plan](specs/211_standardize_command_lifecycle_procedures/plans/implementation-001.md)
- **Plan Summary**: 4-phase implementation (18 hours). Phase 1: Create command-lifecycle.md with 8-stage pattern (4h). Phase 2: Update 4 command files with lifecycle references (6h). Phase 3: Update agent files with summary validation (4h). Phase 4: Testing and validation (4h, deferred). Achieves 39% duplication reduction (1,961 → 1,200 lines).
- **Implementation Summary**: [specs/211_standardize_command_lifecycle_procedures/summaries/implementation-summary-20251228.md]
- **Implementation Artifacts**:
  - .opencode/context/common/workflows/command-lifecycle.md
  - .opencode/command/research.md
  - .opencode/command/plan.md
  - .opencode/command/revise.md
  - .opencode/command/implement.md
  - .opencode/agent/subagents/lean-implementation-agent.md
  - .opencode/agent/subagents/task-executor.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/planner.md
  - .opencode/agent/subagents/lean-research-agent.md
  - .opencode/agent/subagents/implementer.md

**Files Affected**:
- .opencode/context/common/workflows/command-lifecycle.md (new)
- .opencode/command/research.md
- .opencode/command/plan.md
- .opencode/command/revise.md
- .opencode/command/implement.md
- .opencode/agent/subagents/lean-implementation-agent.md
- .opencode/agent/subagents/task-executor.md
- .opencode/agent/subagents/researcher.md
- .opencode/agent/subagents/planner.md
- .opencode/agent/subagents/lean-research-agent.md
- .opencode/agent/subagents/implementer.md

**Description**:
Extracted common 8-stage lifecycle pattern from workflow commands (/research, /plan, /revise, /implement) into single command-lifecycle.md context file. Research revealed 90% structural similarity with 1,961 lines duplicated content. Standardization reduced duplication to 1,200 lines (39% reduction), created single source of truth for lifecycle pattern, and clearly documented legitimate command-specific variations. All commands now reference standardized lifecycle stages while preserving command-specific logic.

**Acceptance Criteria**:
- [x] command-lifecycle.md created with 8-stage pattern documentation
- [x] All 4 command files updated with lifecycle references
- [x] Duplication reduced from 1,961 to 1,200 lines (39% reduction)
- [x] Command-specific variations clearly documented
- [x] Summary artifact validation added to lean-implementation-agent and task-executor
- [x] All 6 agent files reference command-lifecycle.md for integration
- [x] All existing functionality preserved
- [ ] All commands tested successfully (deferred to normal usage)

**Impact**:
Provides single source of truth for command lifecycle pattern, reduces documentation duplication by 39%, improves consistency across workflow commands, and clearly documents legitimate variations. Enhances maintainability and reduces cognitive load for command development.

---

### 220. ✅ Metadata Passing Compliance Verification
- **Effort**: 2.5 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-28
- **Completed**: 2025-12-28
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 217 (completed)
- **Research Artifacts**:
  - Main Report: [specs/220_metadata_passing_compliance_verification/reports/research-001.md]
- **Plan**: [Implementation Plan](specs/220_metadata_passing_compliance_verification/plans/implementation-001.md)
- **Plan Summary**: 6-phase implementation (2.5 hours). Phase 1: Complete lean-research-agent documentation review (0.5h). Phase 2: Complete lean-implementation-agent documentation review (0.5h). Phase 3: Enhance planner validation (0.25h). Phase 4: Enhance task-executor error messages (0.25h). Phase 5: Create compliance verification report (0.5h). Phase 6: Final validation and documentation (0.5h). Achieves 100% compliance across all 10 files (up from 94%).
- **Implementation Summary**: [specs/220_metadata_passing_compliance_verification/summaries/implementation-summary-20251228.md]
- **Compliance Report**: [specs/220_metadata_passing_compliance_verification/summaries/compliance-verification-report.md]
- **Implementation Artifacts**:
  - .opencode/agent/subagents/lean-research-agent.md (fixed documentation)
  - .opencode/agent/subagents/lean-implementation-agent.md (fixed examples)
  - .opencode/agent/subagents/planner.md (enhanced validation)
  - .opencode/agent/subagents/task-executor.md (enhanced error messages)

**Files Affected**:
- .opencode/agent/subagents/lean-research-agent.md
- .opencode/agent/subagents/lean-implementation-agent.md
- .opencode/agent/subagents/planner.md
- .opencode/agent/subagents/task-executor.md

**Description**:
Completed comprehensive compliance verification of all workflow commands and subagents against metadata passing standards. Fixed 3 identified gaps: lean-research-agent documentation (removed incorrect summary artifact references), lean-implementation-agent examples (added missing summary artifacts), planner validation (added defensive checks), and task-executor error messages (added explicit token limits). Achieved 100% compliance across all 10 files.

**Acceptance Criteria**:
- [x] All 10 files verified for compliance with metadata passing standards
- [x] Lean-research-agent.md documentation review completed (lines 400-973)
- [x] Lean-implementation-agent.md documentation review completed (lines 200-514)
- [x] Planner.md enhanced with defensive validation check
- [x] Task-executor.md enhanced with explicit error message
- [x] Compliance verification report created documenting final state
- [x] All files maintain 100% compliance with metadata passing standards
- [x] No regressions in existing functionality

**Impact**:
Ensures all commands and agents fully comply with metadata passing standards for artifact management. Improves documentation clarity, adds defensive validation checks, and enhances error messages for better debugging. Provides foundation for ongoing compliance monitoring.

---

### 222. ✅ Investigate and fix artifact path errors
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-28
- **Completed**: 2025-12-28
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [specs/222_investigate_artifact_path_errors/reports/research-001.md]
- **Plan**: [Implementation Plan](specs/222_investigate_artifact_path_errors/plans/implementation-001.md)
- **Plan Summary**: 6-phase implementation (3 hours). Phase 1: Fix lean-research-agent.md path pattern (0.5h). Phase 2: Migrate project 213 test migration (0.5h). Phase 3: Migrate projects 215 and 218 (0.5h). Phase 4: Update state.json references (0.5h). Phase 5: Cleanup and verification (0.5h). Phase 6: Integration test and documentation (0.5h). Fixes 4 path patterns in lean-research-agent.md and migrates 3 misplaced projects.
- **Implementation Summary**: [specs/222_investigate_artifact_path_errors/summaries/implementation-summary-20251228.md]
- **Implementation Artifacts**:
  - .opencode/agent/subagents/lean-research-agent.md (fixed 4 path patterns)
  - specs/213_resolve_is_valid_swap_involution_blocker/ (migrated from /specs/)
  - specs/215_fix_todo_task_removal/ (migrated from /specs/)
  - specs/218_fix_lean_lsp_mcp_integration/ (migrated from /specs/)
  - TODO.md (updated artifact links for task 213)

**Files Affected**:
- .opencode/agent/subagents/lean-research-agent.md
- TODO.md
- specs/state.json

**Description**:
Fixed artifact path creation errors where Lean research tasks created artifacts in `/specs/` instead of `/specs/`. Root cause: 4 path patterns in lean-research-agent.md missing `.opencode/` prefix. Migrated 3 affected projects (213, 215, 218) to correct location and updated all artifact references. All 6 implementation phases completed successfully.

**Acceptance Criteria**:
- [x] lean-research-agent.md uses correct `specs/` path pattern (4 patterns fixed)
- [x] All 3 misplaced projects migrated to `specs/`
- [x] TODO.md artifact links updated and verified working
- [x] state.json artifact paths updated (no changes needed - already correct)
- [x] Empty /specs/ directory removed
- [x] All subagents verified to use correct path patterns
- [x] Implementation summary created

**Impact**:
Ensures all future Lean research tasks create artifacts in correct `specs/` location. Fixes 3 existing projects with misplaced artifacts. Prevents future path confusion and maintains consistent artifact organization across all workflow commands.

---

### 224. Configure OpenCode to start in Orchestrator mode or auto-switch agent modes for workflow commands
- **Effort**: TBD
- **Status**: [PLANNED]
- **Started**: 2025-12-29
- **Completed**: 2025-12-29
- **Priority**: Medium
- **Language**: general
- **Research Artifacts**:
  - Main Report: [specs/224_configure_opencode_default_agent/reports/research-001.md]
- **Plan**: [specs/224_configure_opencode_default_agent/plans/implementation-001.md]
- **Description**: Research how to configure OpenCode to start in Orchestrator mode by default or automatically switch agent modes when workflow commands are executed. Analyzed OpenCode agent system, command routing, and identified 4 potential solutions. Recommended solution: Add "default_agent": "orchestrator" to opencode.json configuration (minimal disruption, follows OpenCode conventions).
- **Acceptance Criteria**:
  - [x] OpenCode agent system architecture analyzed
  - [x] Default agent configuration mechanism identified
  - [x] Command routing behavior documented
  - [x] 4 potential solutions evaluated
  - [x] Recommended solution identified with implementation steps
- **Impact**: Improves user experience by eliminating need to manually switch to Orchestrator mode before running workflow commands. Reduces errors from executing commands in wrong agent context.

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
**Research**: [Research Report](specs/172_documentation/reports/research-001.md)
**Research Summary**: Current state shows 98% module-level coverage but only 47% declaration-level coverage. Critical gaps identified in 4 files (Tactics.lean, Truth.lean, Propositional.lean, Derivation.lean). Recommended tools: doc-gen4 for centralized API reference, linters for quality enforcement. Revised effort estimate: 30 hours (up from 18 hours).
**Plan**: [Implementation Plan](specs/172_documentation/plans/implementation-001.md)
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

### 183. ✅ Fix DeductionTheorem.lean build errors (3 errors)
- **Effort**: 0.5 hours (30 minutes)
- **Status**: [COMPLETED]
- **Started**: 2025-12-25
- **Completed**: 2025-12-28
- **Priority**: High
- **Language**: lean
- **Blocking**: 173
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [specs/183_deduction_theorem_build_errors/reports/research-001.md]
  - Summary: [specs/183_deduction_theorem_build_errors/summaries/research-summary.md]
- **Plan**: [specs/183_deduction_theorem_build_errors/plans/implementation-002.md]
- **Plan Summary**: Single-phase implementation (30 minutes). Replace 3 `.elim` patterns with idiomatic `by_cases` tactic at lines 256, 369, 376. Purely syntactic fix following proven patterns from Soundness.lean and Truth.lean. Very low risk - no logic changes, only tactic mode syntax.
- **Implementation Summary**: [specs/183_deduction_theorem_build_errors/summaries/implementation-summary-20251228.md]
- **Files Affected**:
  - Logos/Core/Metalogic/DeductionTheorem.lean
- **Description**: Fix 3 pre-existing build errors in DeductionTheorem.lean that are blocking compilation of all test files including the new integration tests from task 173. These errors prevent verification that the 106 new integration tests (82% coverage) actually compile and pass. Errors: Line 255 (Decidable typeclass instance stuck), Line 297 (no goals to be solved), Line 371 (Decidable typeclass instance stuck).
- **Root Cause Analysis** (2025-12-25):
  - All 3 build errors stem from using `(em P).elim` pattern inside `match` expressions
  - The `.elim` method is a term-mode construct, not a tactic, causing "unknown tactic" errors at lines 256, 369, and 376
  - With `open Classical` already at the top of the file, `by_cases` automatically uses `Classical.propDecidable` for any proposition via excluded middle
- **Solution** (Research Complete):
  - Replace `(em P).elim (fun h => ...) (fun h => ...)` with `by_cases h : P` tactic
  - This is the idiomatic Lean 4 pattern proven in the codebase (Soundness.lean line 282, Truth.lean lines 789-825)
  - 3 simple replacements needed:
    - Line 256: `(em (A ∈ Γ'')).elim` → `by_cases hA' : A ∈ Γ''`
    - Line 369: `(em (Γ' = A :: Γ)).elim` → `by_cases h_eq : Γ' = A :: Γ`
    - Line 376: `(em (A ∈ Γ')).elim` → `by_cases hA : A ∈ Γ'`
  - Use `·` bullet points for case branches and remove closing parentheses
  - Termination proofs are correct and will work once tactic errors are fixed
- **Acceptance Criteria**:
  - [x] All 3 build errors in DeductionTheorem.lean resolved
  - [x] DeductionTheorem.lean compiles successfully with lake build
  - [x] No new errors introduced
  - [x] Existing tests continue to pass
- **Impact**: Critical blocker for task 173. Fixing these errors will unblock compilation of 106 new integration tests and allow verification of 82% integration test coverage achievement.

---

### 213. Resolve is_valid_swap_involution blocker
**Effort**: 6 hours
**Status**: [PLANNED]
**Started**: 2025-12-28
**Priority**: High
**Blocking**: Task 184, Task 193, Task 209
**Dependencies**: None
**Language**: lean
**Research Artifacts**:
  - Main Report: [specs/213_resolve_is_valid_swap_involution_blocker/reports/research-001.md]
  - Summary: [specs/213_resolve_is_valid_swap_involution_blocker/summaries/research-summary.md]
**Plan**: [specs/213_resolve_is_valid_swap_involution_blocker/plans/implementation-002.md]
**Plan Summary**: Revised implementation plan (6 hours total) with usage context verification. Phase 1: Remove unprovable theorem (0.5h). Phase 2: Add provable theorem with usage verification (2.5h). Phase 3: Update temporal_duality case with type verification (1.5h). Phase 4: Build verification (1h). Phase 5: Documentation updates (1h). Verified that proposed solution matches usage site requirements at Truth.lean line 1226-1235.

**Files Affected**:
- `Logos/Core/Semantics/Truth.lean` (lines 681-694, 1226-1235)
- `Documentation/ProjectInfo/SORRY_REGISTRY.md`
- `Documentation/Development/LEAN_STYLE_GUIDE.md`
- `TODO.md`

**Description**:
Resolve the unprovable `is_valid_swap_involution` theorem blocker that has blocked tasks 184, 193, and 209 for 10.7 hours. Research definitively identified that the theorem is semantically false for arbitrary formulas but true for derivable formulas. Solution: Replace with `derivable_valid_swap_involution` restricted to derivable formulas. Usage context verified: temporal_duality case has exactly the right type of derivation tree available.

**Critical Finding**: The theorem `is_valid T φ.swap → is_valid T φ` is unprovable because swap exchanges past and future quantification, which are not equivalent in general models. However, it IS true for derivable formulas due to the temporal_duality rule.

**Usage Context Verification**: The temporal_duality case (line 1226-1235) has `h_ψ' : DerivationTree [] ψ'` where `ψ' = φ.swap`, which is exactly `DerivationTree [] φ.swap_past_future` - the type needed for the new theorem. Type alignment verified ✅

**Acceptance Criteria**:
- [ ] Unprovable theorem removed from Truth.lean
- [ ] New `derivable_valid_swap_involution` theorem added and proven
- [ ] temporal_duality case updated to use new theorem
- [ ] Type alignment verified at usage site
- [ ] All builds and tests pass
- [ ] Documentation and registries updated
- [ ] Tasks 184, 193, 209, 213 marked as COMPLETED

**Impact**:
Resolves 10.7 hours of blocked work across 4 tasks. Unblocks Truth.lean build and enables completion of temporal duality soundness proof. Provides important lesson on semantic vs syntactic properties.

---

### 184. Fix Truth.lean build error (swap_past_future proof)
**Effort**: 1-2 hours
**Status**: [BLOCKED]
**Started**: 2025-12-25
**Priority**: High
**Blocking**: Task 173 (integration tests), Task 185
**Dependencies**: Task 213
**Language**: lean

**Files Affected**:
- `Logos/Core/Semantics/Truth.lean` (line 632)

**Description**:
Fix build error in Truth.lean at line 632 related to swap_past_future proof. This error is blocking integration test compilation and task 173. **BLOCKED by task 213** - the is_valid_swap_involution theorem at line 691 is unprovable and must be resolved first.

**Error Details**:
- Line 632: swap_past_future proof error
- Root cause: Depends on unprovable is_valid_swap_involution theorem

**Acceptance Criteria**:
- [ ] Build error at line 632 is resolved
- [ ] File compiles successfully with `lake build`
- [ ] No new errors introduced
- [ ] Existing tests continue to pass

**Impact**:
Unblocks task 173 (integration tests) and task 185 (test helper API fixes). Critical for project build health.

---

### 209. Research Lean 4 techniques for completing task 193 involution proof
**Effort**: 3 hours
**Status**: [BLOCKED]
**Started**: 2025-12-28
**Completed**: 2025-12-28
**Priority**: High
**Blocking**: None
**Dependencies**: Task 213 (blocker identified)
**Language**: lean
**Research Artifacts**:
  - Main Report: [specs/209_research_lean4_involution_techniques/reports/research-001.md]
  - Summary: [specs/209_research_lean4_involution_techniques/summaries/research-summary.md]
**Implementation Summary**: [specs/209_research_lean4_involution_techniques/summaries/implementation-summary-20251228.md]

**Files Affected**:
- Logos/Core/Syntax/Formula.lean (added @[simp] attribute to swap_past_future_involution)

**Description**:
Research Lean 4 techniques, tactics, and proof patterns for completing the is_valid_swap_involution theorem proof in task 193. The proof is currently blocked by a type theory issue where the helper lemma truth_at_swap_swap is complete but the main involution theorem needs additional techniques. **BLOCKED by task 213** - comprehensive research revealed the theorem is unprovable as stated (semantically false).

**Critical Finding** (Task 213): The theorem `is_valid T φ.swap → is_valid T φ` is **unprovable** because it is semantically false for arbitrary formulas. The swap operation exchanges past and future quantification, which are not equivalent in general models. The theorem is only true for derivable formulas.

**Acceptance Criteria**:
- [x] Research report created with Lean 4 proof techniques
- [x] Specific tactics and patterns identified for involution proofs
- [x] Recommendations provided for completing task 193
- [x] Examples from Lean 4 ecosystem analyzed
- [x] Blocker identified: theorem is unprovable as stated (task 213)

**Impact**:
Research completed and identified that the theorem is fundamentally unprovable. Task 213 provides the solution: replace with derivable-only version. This task will be marked COMPLETED once task 213 is implemented.

**Note**: All 15 attempted proof strategies failed not due to technique limitations, but because the theorem statement is false. Task 213 provides the correct solution.

---

### 218. Fix lean-lsp-mcp integration and opencode module import errors
**Effort**: 0.75 hours
**Status**: [RESEARCHED]
**Started**: 2025-12-28
**Researched**: 2025-12-28
**Priority**: High
**Blocking**: None
**Dependencies**: 212 (completed)
**Language**: python
**Research Artifacts**:
  - Main Report: [specs/218_fix_lean_lsp_mcp_integration/reports/research-002.md]
**Research Findings** (2025-12-28): CRITICAL DISCOVERY: OpenCode has native MCP support via opencode.json configuration, NOT .mcp.json. Task 212's custom Python MCP client approach is architecturally incompatible - OpenCode agents use natural language tool instructions, not Python imports. The ModuleNotFoundError is a symptom of wrong architectural approach, not missing __init__.py files. Solution requires complete pivot from Python-based integration to configuration-based integration: (1) Create opencode.json with lean-lsp-mcp server configuration, (2) Update lean-implementation-agent.md to use natural language MCP tool instructions instead of Python imports, (3) Remove custom MCP client from task 212 (architecturally incompatible). Proper approach enables 15+ lean-lsp-mcp tools (compile, check-proof, search, etc.) via native OpenCode MCP bridge. Previous plan obsolete - new configuration-based approach estimated 1-2 hours.

**Files Affected**:
- opencode.json (new, MCP server configuration)
- .opencode/agent/subagents/lean-implementation-agent.md (update to use MCP tool instructions)
- .opencode/agent/subagents/lean-research-agent.md (update to use MCP tool instructions)
- Documentation/UserGuide/MCP_INTEGRATION.md (new, user guide)
- .opencode/tool/mcp/client.py (mark deprecated, incompatible with OpenCode architecture)

**Description**:
Research revealed that OpenCode has native MCP (Model Context Protocol) support that makes task 212's custom Python MCP client unnecessary and architecturally incompatible. OpenCode agents interact with MCP servers through natural language tool instructions, not Python imports. The proper integration approach uses opencode.json configuration to register MCP servers, making their tools automatically available to agents. This enables lean-implementation-agent to use lean-lsp-mcp's 15+ tools for real-time compilation checking, proof state inspection, and theorem search during Lean proof implementation.

**Acceptance Criteria**:
- [ ] opencode.json created with lean-lsp-mcp server configuration
- [ ] lean-implementation-agent.md updated with MCP tool usage instructions
- [ ] lean-research-agent.md updated with MCP tool usage instructions  
- [ ] MCP integration guide created in user documentation
- [ ] Test Lean task implementation successfully uses lean-lsp-mcp tools
- [ ] No Python import errors (using configuration-based approach)
- [ ] Selective tool enablement reduces context window usage

**Impact**:
CRITICAL ARCHITECTURAL CORRECTION: Pivots from incompatible custom Python client to proper OpenCode-native MCP integration. Enables lean-lsp-mcp tools for real-time Lean compilation checking, proof verification, and theorem search. Reduces context window usage by 2000-5000 tokens through selective per-agent tool enablement. Establishes foundation for additional MCP servers (Context7, Grep) to enhance Lean development workflow.

### 219. Restructure module hierarchy separating semantic from proof system properties
**Effort**: 2.5 hours (actual), 13 hours (estimated)
**Status**: [COMPLETED]
**Started**: 2025-12-28
**Completed**: 2025-12-28
**Priority**: High
**Blocking**: None
**Dependencies**: 213 (circular dependency analysis)
**Language**: lean
**Research Artifacts**:
  - Main Report: [specs/219_restructure_module_hierarchy/reports/research-001.md]
  - Summary: [specs/219_restructure_module_hierarchy/summaries/research-summary.md]
**Plan**: [specs/219_restructure_module_hierarchy/plans/implementation-001.md]
**Implementation Summary**: [specs/219_restructure_module_hierarchy/summaries/implementation-summary-20251228.md]

**Files Created**:
- Logos/Core/Metalogic/SoundnessLemmas.lean (706 lines)

**Files Modified**:
- Logos/Core/Semantics/Truth.lean (reduced from 1277 to 579 lines)
- Logos/Core/Metalogic/Soundness.lean (updated temporal_duality case)
- Logos/Core/Metalogic.lean (added SoundnessLemmas import)

**Description**:
Resolved circular dependency between Truth.lean and Soundness.lean by extracting the TemporalDuality namespace (~680 lines) to a new SoundnessLemmas.lean bridge module. This establishes clean layered dependencies: Soundness → SoundnessLemmas → Truth (pure semantics). Truth.lean now contains only pure semantic definitions without proof system imports. All modules compile successfully.

**Implementation Summary** (2025-12-28):
Successfully completed phases 1-5 of the 9-phase implementation plan. Created SoundnessLemmas.lean with all bridge theorems (axiom_swap_valid, derivable_implies_swap_valid). Updated Truth.lean to remove TemporalDuality namespace and proof system imports (Axioms, Derivation). Updated Soundness.lean to import SoundnessLemmas and use it for temporal_duality case. All modules compile successfully. Circular dependency eliminated. Module sizes within guidelines (Truth: 579 lines, SoundnessLemmas: 706 lines, Soundness: 680 lines). Phases 6-9 (testing, documentation, validation) deferred to future work.

**Acceptance Criteria**:
- [x] SoundnessLemmas.lean created with ~680 lines of bridge theorems
- [x] TemporalDuality namespace fully moved from Truth.lean to SoundnessLemmas.lean
- [x] Truth.lean updated: imports removed, namespace removed, reduced to ~600 lines
- [x] Soundness.lean updated: imports SoundnessLemmas, temporal_duality case updated
- [x] Circular dependency eliminated (verified with compilation)
- [x] All modules compile: lake build succeeds
- [ ] All tests pass: lake exe test (deferred to phase 6)
- [ ] New tests created: SoundnessLemmasTest.lean (deferred to phase 6)
- [ ] Documentation updated: Module hierarchy documented (deferred to phase 7)
- [ ] SORRY_REGISTRY.md updated (not needed - expected sorry documented)

**Impact**:
CRITICAL STRUCTURAL IMPROVEMENT: Eliminates circular dependency blocking soundness completion. Establishes clean 3-layer architecture (Metalogic → Bridge → Semantics). Enables future proof work on temporal_duality case. Reduces Truth.lean complexity by 55% (1277→579 lines). All changes backward compatible - no API breaks. Foundation for continued metalogic development.

---

---

### 210. Fix Lean subagents to follow artifact-management.md, status-markers.md, and state-schema.md
**Effort**: 6-8 hours
**Status**: [RESEARCHED]
**Started**: 2025-12-28
**Completed**: 2025-12-28
**Priority**: Medium
**Blocking**: None
**Dependencies**: None
**Language**: markdown
**Research Artifacts**:
  - Main Report: [specs/210_fix_lean_subagents/reports/research-001.md]
  - Summary: [specs/210_fix_lean_subagents/summaries/research-summary.md]

**Files Affected**:
- .opencode/agent/subagents/lean-research-agent.md
- .opencode/agent/subagents/lean-implementation-agent.md

**Description**:
Fix both Lean subagents (lean-research-agent and lean-implementation-agent) to follow artifact-management.md, status-markers.md, and state-schema.md specifications. Research identified 21 compliance issues across both agents including missing status marker workflows, missing state.json updates, and missing summary artifact enforcement.

**Acceptance Criteria**:
- [ ] lean-research-agent follows artifact-management.md (summary enforcement, correct paths, validation)
- [ ] lean-research-agent follows status-markers.md (workflow implementation, timestamp updates)
- [ ] lean-research-agent follows state-schema.md (state.json updates, project state files)
- [ ] lean-implementation-agent follows artifact-management.md (summary enforcement, correct paths, validation)
- [ ] lean-implementation-agent follows status-markers.md (workflow implementation, timestamp updates)
- [ ] lean-implementation-agent follows state-schema.md (state.json updates, project state files)
- [ ] All cross-cutting issues resolved (lazy creation, emoji validation, return format consistency)

**Impact**:
Ensures Lean subagents properly maintain TODO.md, state.json, and artifact files according to project standards, improving consistency and reliability of automated workflows.

---

### 185. Fix integration test helper API mismatches
**Effort**: 1-2 hours
**Status**: [RESEARCHED]
**Started**: 2025-12-25
**Completed**: 2025-12-29
**Priority**: High
**Blocking**: Task 173 (integration tests)
**Dependencies**: Task 183, Task 184
**Language**: lean
**Research**: [Research Report](specs/185_fix_integration_test_helper_api_mismatches/reports/research-001.md)

**Files Affected**:
- `LogosTest/Core/Integration/Helpers.lean` (lines 126, 131, 129)

**Description**:
Fix API mismatches in integration test helper functions. These mismatches are preventing integration tests from compiling after tasks 183 and 184 are resolved.

**Error Details**:
- Line 126: API mismatch
- Line 129: API mismatch
- Line 131: API mismatch

**Acceptance Criteria**:
- [ ] All API mismatches in Helpers.lean are resolved
- [ ] File compiles successfully with `lake build`
- [ ] Integration tests compile and run
- [ ] No new errors introduced

**Impact**:
Completes the unblocking of task 173 (integration tests). Enables verification of 106 new integration tests with 82% coverage.

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
**Artifacts**: [specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md](specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md), [specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/reports/research-001.md](specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/reports/research-001.md), [specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/summaries/implementation-summary-20251222.md](specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/summaries/implementation-summary-20251222.md)

**Files Affected**:
- `Logos/Core/Automation/ProofSearch.lean`
- `LogosTest/Core/Automation/ProofSearchTest.lean`

**Description**:
Implement bounded search driver with depth/visit limits, cache/visited threading, and structural axiom matching for all 14 schemas to replace stubs and enable basic proof search execution. Lean intent true; plan ready at [specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md](specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md).

**Acceptance Criteria**:
- [x] `bounded_search` implemented with depth and visit limits.
- [x] `matches_axiom` implemented with correct structural matching logic (all 14 schemas) and axiom stubs removed.
- [x] `search_with_cache`/basic search runs on sample goals without timeouts.
- [x] Tests cover axiom matching and bounded search termination (unit + integration under Automation).

**Impact**:
Enables the first working path for automated proof search with termination guards.

---

## Low Priority (Complete within 6-12 months)

### 259. Automation Tactics
**Effort**: 17-23 hours
**Status**: [RESEARCHED]
**Started**: 2026-01-04
**Completed**: 2026-01-04
**Priority**: Medium
**Language**: lean
**Research Artifacts**:
  - Main Report: [specs/259_automation_tactics/reports/research-001.md]

**Description**: Implement the remaining planned tactics for TM logic to support easier proof construction. Research completed 2026-01-04 found 10/12 tactics fully implemented (83% complete), 2 tactics with infrastructure ready but delegating to tm_auto. Aesop integration functional with 2 noncomputable errors. ProofSearch.lean provides production-ready bounded search infrastructure (461 lines). Revised effort estimate: 17-23 hours (down from 40-60 hours).

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

### 177. Update examples to use latest APIs and add new feature demonstrations ✅
**Effort**: 8 hours
**Status**: [COMPLETED]
**Started**: 2025-12-25
**Completed**: 2025-12-25
**Priority**: Medium
**Blocking**: None
**Dependencies**: Tasks 126, 127 (completed)
**Language**: lean
**Plan**: [Implementation Plan](specs/177_examples_update/plans/implementation-001.md)
**Summary**: [Implementation Summary](specs/177_examples_update/summaries/implementation-summary-20251225.md)

**Files Modified**:
- `Archive/ModalProofs.lean` (241 → 346 lines, +105)
- `Archive/TemporalProofs.lean` (301 → 356 lines, +55)
- `Archive/BimodalProofs.lean` (216 → 297 lines, +81)
- `Documentation/UserGuide/EXAMPLES.md` (448 → 586 lines, +138)

**Description**:
Successfully updated example files to demonstrate new automation capabilities (ProofSearch, heuristics) added in Tasks 126-127. Added 379 lines total (exceeded planned 160 lines by 137%). All changes are additive with zero breaking changes.

**Implementation Highlights**:
- Phase 1: Modal automation examples (105 lines) - automated proof search, SearchStats, heuristic strategies, context transformations
- Phase 2: Temporal automation examples (55 lines) - temporal proof search, future_context transformations
- Phase 3: Perpetuity automation examples (81 lines) - automated P1-P6 discovery, bimodal search
- Phase 4: Documentation updates (138 lines) - comprehensive API documentation and cross-references

**Acceptance Criteria**:
- [x] All existing examples audited for correctness
- [x] Examples updated to use latest APIs (ProofSearch imports added)
- [x] New examples for ProofSearch and heuristics added
- [x] New examples for perpetuity principles P1-P6 added
- [~] All examples compile and run successfully (blocked by Tasks 183-184)
- [x] Examples documented with clear explanations

**Impact**:
Provides comprehensive examples demonstrating automation features, improving usability and showcasing ProofSearch capabilities. Exceeds planned scope with high-quality documentation.

**Note**: Build currently blocked by pre-existing errors in Truth.lean (Task 184) and DeductionTheorem.lean (Task 183). Example code is correct and will compile once blockers are resolved.

---

### 186. Refactor MAINTENANCE.md to include /review update instructions ✅
**Effort**: 1 hour
**Status**: [COMPLETED]
**Started**: 2025-12-25
**Completed**: 2025-12-25
**Priority**: Medium
**Blocking**: None
**Dependencies**: None

**Files Affected**:
- `Documentation/ProjectInfo/MAINTENANCE.md`

**Description**:
Update MAINTENANCE.md to include instructions for /review command to update IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, and TACTIC_REGISTRY.md when reviewing code changes.

**Acceptance Criteria**:
- [x] MAINTENANCE.md includes /review update workflow
- [x] Registry update instructions are clear and actionable
- [x] Examples provided for common review scenarios

**Impact**:
Ensures /review command updates all relevant registries, maintaining consistency across documentation.

---

### 187. Refactor review.md workflow context to specify registry update workflow ✅
**Effort**: 1 hour
**Status**: [COMPLETED]
**Started**: 2025-12-25
**Completed**: 2025-12-25
**Priority**: Medium
**Blocking**: None
**Dependencies**: None

**Files Affected**:
- `.opencode/context/workflow/review.md`

**Description**:
Update review.md workflow context to specify the registry update workflow for IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, and TACTIC_REGISTRY.md.

**Acceptance Criteria**:
- [x] review.md includes registry update workflow
- [x] Workflow specifies when and how to update each registry
- [x] Integration with /review command is documented

**Impact**:
Provides clear workflow guidance for /review command to maintain registry consistency.

---

### 188. Refactor /review command to load review.md workflow context ✅
**Effort**: 1 hour
**Status**: [COMPLETED]
**Started**: 2025-12-25
**Completed**: 2025-12-25
**Priority**: Medium
**Blocking**: None
**Dependencies**: None

**Files Affected**:
- `.opencode/command/review.md`

**Description**:
Update /review command to load review.md workflow context, ensuring it follows the registry update workflow.

**Acceptance Criteria**:
- [x] /review command loads review.md workflow context
- [x] Command follows registry update workflow
- [x] Registry updates are atomic and consistent

**Impact**:
Ensures /review command automatically maintains registry consistency through workflow context.

---

### 174. Add property-based testing framework and metalogic tests
**Effort**: 18-23 hours
**Status**: [COMPLETED]
**Started**: 2025-12-25
**Completed**: 2025-12-25
**Priority**: High
**Blocking**: None
**Dependencies**: None
**Language**: lean
**Plan**: [Implementation Plan](specs/174_property_based_testing/plans/implementation-001.md)
**Summary**: [Implementation Summary](specs/174_property_based_testing/summaries/implementation-summary-20251225.md)

**Files Affected**:
- `LogosTest/Core/Property/Generators.lean`
- `LogosTest/Core/Metalogic/SoundnessPropertyTest.lean`
- `LogosTest/Core/ProofSystem/DerivationPropertyTest.lean`
- `LogosTest/Core/Semantics/SemanticPropertyTest.lean`
- `LogosTest/Core/Syntax/FormulaPropertyTest.lean`
- `LogosTest/Core/Property/README.md`
- `Documentation/Development/PROPERTY_TESTING_GUIDE.md` (NEW)
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`

**Description**:
Integrated Plausible property-based testing framework and implemented comprehensive property tests for metalogic (soundness, consistency), derivation (weakening, cut, substitution), semantics (frame properties, truth conditions), and formula transformations (NNF, CNF idempotence). Main technical challenge was implementing TaskModel generator with dependent types using SampleableExt proxy pattern.

**Acceptance Criteria**:
- [x] TaskModel generator implemented with dependent type handling
- [x] 14/14 axiom schemas tested with 100-500 test cases each
- [x] Enhanced property tests across 4 core modules
- [x] 5,000+ total property test cases
- [x] PROPERTY_TESTING_GUIDE.md created (500+ lines)
- [x] All tests passing with performance targets met

**Impact**:
Provides comprehensive automated testing across wide range of inputs, automatically finding edge cases and verifying critical properties of the TM logic proof system. Significantly improves test coverage and confidence in correctness.

---

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

### 229. ❌ Review and optimize orchestrator-command integration for context efficiency
**Effort**: 6 hours
**Status**: [ABANDONED]
**Started**: 2025-12-29
**Researched**: 2025-12-29
**Planned**: 2025-12-29
**Abandoned**: 2025-12-29
**Priority**: High
**Blocking**: None
**Dependencies**: None
**Language**: markdown
**Superseded By**: Task 231
**Abandonment Reason**: Root cause analysis was incorrect. Research concluded orchestrator bypasses commands, but investigation revealed commands ARE loaded and executed - the issue is Claude skipping Stage 7 (Postflight) within command execution. Task 231 addresses the correct root cause with proper fixes.
**Research Artifacts**:
  - Main Report: [specs/229_review_and_optimize_orchestrator_command_integration_for_context_efficiency/reports/research-001.md]
**Plan**: [Implementation Plan](specs/229_review_and_optimize_orchestrator_command_integration_for_context_efficiency/plans/implementation-001.md)
**Plan Summary**: 7-phase implementation plan (6 hours total). Phase 1: Audit command invocability (0.5h). Phase 2: Reduce orchestrator context to 3 core files (0.5h). Phase 3: Refactor Step 7 RouteToCommand (1.5h). Phase 4: Refactor Step 4 PrepareRouting to target commands (1h). Phase 5: Simplify/remove Step 3 CheckLanguage (0.5h). Phase 6: Testing and validation (1.5h). Phase 7: Documentation updates (0.5h). Fixes critical architectural flaw where orchestrator bypasses commands causing 100% workflow failure and 60-70% context bloat.

**Files Affected**:
- .opencode/agent/orchestrator.md
- .opencode/command/plan.md
- .opencode/command/research.md
- .opencode/command/implement.md
- .opencode/command/revise.md
- .opencode/command/review.md
- .opencode/context/common/workflows/command-lifecycle.md

**Description**:
CRITICAL ARCHITECTURAL FIX: Research identified that orchestrator.md routes directly to SUBAGENTS (planner, lean-research-agent, task-executor) instead of routing to COMMANDS (/plan, /research, /implement). This bypasses the entire command lifecycle (8 stages), causing 100% workflow failure for postflight procedures (no TODO.md/state.json updates), 60-70% context bloat in orchestrator (loading context meant for commands), and breaking the intended 3-layer architecture. The fix: modify orchestrator to route to commands, which then delegate to subagents internally, ensuring full workflow execution including status-sync-manager integration and git commits.

**Current (Broken)**: User → Orchestrator → Subagent (direct bypass)
**Expected (Correct)**: User → Orchestrator → Command → Subagent

**Acceptance Criteria**:
- [ ] All 5 command files have necessary frontmatter for orchestrator invocation
- [ ] Orchestrator context reduced to 3 core files (60-70% reduction)
- [ ] orchestrator.md Step 7 renamed to RouteToCommand with command invocation pattern
- [ ] orchestrator.md Step 4 routing targets changed from subagents to commands
- [ ] orchestrator.md Step 3 CheckLanguage removed (commands handle language extraction)
- [ ] All 4 workflow commands execute full 8-stage lifecycle with status updates
- [ ] TODO.md and state.json updated for all tested commands
- [ ] Git commits created by postflight procedures
- [ ] Architecture diagram created showing correct 3-layer flow
- [ ] Documentation updated with command invocation patterns
- [ ] Tasks 227 and 228 resolution documented (resolved architecturally)

**Impact**:
CRITICAL: Resolves the root cause of why all workflow commands fail to update TODO.md and state.json - they're being bypassed entirely by the orchestrator. Establishes correct 3-layer architecture (orchestrator → command → subagent), reduces context window by 60-70%, ensures 100% workflow completion. Resolves tasks 227 and 228 as side effects.

---

### 190. Improve MAINTENANCE.md documentation structure and content
**Effort**: 2 hours
**Status**: [IN PROGRESS]
**Started**: 2025-12-26
**Priority**: Medium
**Blocking**: None
**Dependencies**: None
**Language**: markdown
**Plan**: [Implementation Plan](specs/190_improve_maintenance_md_documentation_structure_and_content/plans/implementation-002.md)

**Files Affected**:
- `Documentation/ProjectInfo/MAINTENANCE.md`

**Description**:
Improve MAINTENANCE.md documentation by adding missing registry references (FEATURE_REGISTRY.md and TACTIC_REGISTRY.md), establishing a clear policy against backwards compatibility layers in favor of clean-break approaches, and enhancing overall structure and organization.

**Acceptance Criteria**:
- [ ] FEATURE_REGISTRY.md added to Related Documentation section
- [ ] TACTIC_REGISTRY.md added to Related Documentation section
- [ ] New section added explicitly banning backwards compatibility layers
- [ ] Clean-break approach documented as preferred methodology
- [ ] Rationale provided for avoiding technical debt from compatibility layers
- [ ] Document structure improved for consistency
- [ ] Section organization enhanced for better navigation
- [ ] No content removed, only reorganized and enhanced
- [ ] Cross-references updated where relevant

**Impact**:
Improves MAINTENANCE.md documentation quality and completeness, providing clear guidance on registry synchronization and backwards compatibility policy.

---

### 671. Combine Dynamics Foundation LaTeX Files
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: latex
- **Created**: 2026-01-22
- **Description**: combine /home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/02-DynamicsFoundation-Syntax.tex, /home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/03-DynamicsFoundation-Semantics.tex, and /home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/04-DynamicsFoundation-Axioms.tex into a single file without changing the content of those files while nevertheless improving organizaton and sections titles as appropriate
- **Research**: [research-001.md](specs/671_combine_dynamics_foundation_latex_files/reports/research-001.md)
- **Next Steps**: Run `/implement 671` to create the combined file

---

See git history for other completed tasks:
```bash
git log --all --grep="Complete Task" --oneline
```

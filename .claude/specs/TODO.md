---
last_updated: 2026-01-09T12:00:00Z
next_project_number: 352
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2026-01-05T02:00:00Z
task_counts:
  active: 49
  completed: 67
  in_progress: 2
  not_started: 43
  abandoned: 7
  total: 124
priority_distribution:
  high: 17
  medium: 22
  low: 14
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---

# TODO


---

## High Priority

### 308. Final cleanup and comprehensive testing (5/5)
- **Effort**: 15 minutes
- **Status**: [REVISING]
- **Priority**: Medium
- **Language**: general
- **Blocking**: None
- **Dependencies**: None

**Description**: Complete final cleanup of any remaining cruft from files not reverted. Test all commands (/task, /meta, /todo, /review) comprehensively to ensure everything works correctly. Commit clean changes with proper documentation.

---

## Medium Priority

### 176. Enhance proof search with domain-specific heuristics and caching
- **Effort**: 18 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Automation/ProofSearch.lean
  - Logos/Core/Automation/ProofSearchHeuristics.lean (new)
  - Logos/Core/Automation/ProofCache.lean (new)
  - LogosTest/Core/Automation/ProofSearchHeuristicsTest.lean (new)
- **Description**: Enhance ProofSearch.lean with modal-specific and temporal-specific heuristics, proof caching with hash-consing, and success pattern learning. Current heuristics are basic (Task 127 complete). Domain-specific optimizations will significantly improve proof search effectiveness.
- **Acceptance Criteria**:
  - [ ] Modal-specific heuristics implemented (prefer S5 axioms for modal goals)
  - [ ] Temporal-specific heuristics implemented (prefer temporal axioms for temporal goals)
  - [ ] Proof caching with hash-consing implemented
  - [ ] Success pattern learning implemented
  - [ ] Heuristics tested and benchmarked
  - [ ] Documentation for heuristic tuning added
- **Impact**: Improves automation effectiveness by tailoring proof search to the structure of modal and temporal problems, reducing search time and increasing success rate.

---

### 178. Complete advanced tutorial sections with hands-on exercises
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 172
- **Files Affected**:
  - Documentation/UserGuide/TUTORIAL.md
  - Documentation/UserGuide/TUTORIAL_EXERCISES.md (new)
  - Documentation/UserGuide/TROUBLESHOOTING.md (new)
- **Description**: Enhance TUTORIAL.md with advanced sections on proof search automation, custom tactic development, and metalogic. Add hands-on exercises with solutions and a troubleshooting guide. Current tutorial is basic and lacks advanced topics.
- **Acceptance Criteria**:
  - [ ] Advanced tutorial section on proof search and automation added
  - [ ] Advanced tutorial section on custom tactic development added
  - [ ] Advanced tutorial section on metalogic and soundness added
  - [ ] Hands-on exercises with solutions added
  - [ ] Troubleshooting guide created
  - [ ] Tutorial tested with new users for clarity
- **Impact**: Improves onboarding by providing comprehensive learning path from basics to advanced topics with practical exercises.

---

### 179. Implement performance benchmarks for proof search and derivation
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - LogosBench/ (new directory)
  - LogosBench/ProofSearchBench.lean (new)
  - LogosBench/DerivationBench.lean (new)
  - LogosBench/SemanticEvaluationBench.lean (new)
  - Documentation/Development/PERFORMANCE_TARGETS.md (new)
- **Description**: Create performance benchmark suite for proof search, derivation, and semantic evaluation. Add performance regression testing to CI. Currently no benchmarks exist and performance could regress unnoticed. Document performance targets.
- **Acceptance Criteria**:
  - [ ] Benchmark suite for proof search created
  - [ ] Benchmark suite for derivation created
  - [ ] Benchmark suite for semantic evaluation created
  - [ ] Performance regression testing added to CI
  - [ ] Performance targets documented
  - [ ] Baseline performance measurements recorded
- **Impact**: Ensures performance doesn't regress and provides data for optimization efforts. Critical for maintaining usable proof search times.

---

### 180. Add test coverage metrics and reporting
- **Effort**: 9 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 175
- **Files Affected**:
  - .github/workflows/coverage.yml
  - scripts/GenerateCoverage.lean (new)
  - Documentation/Development/TEST_COVERAGE.md (new)
- **Description**: Integrate test coverage measurement tool, generate coverage reports, add coverage reporting to CI, and create coverage improvement plan. TESTING_STANDARDS.md defines target of at least 85 percent but no measurement exists.
- **Acceptance Criteria**:
  - [ ] Coverage measurement tool integrated
  - [ ] Coverage reports generated automatically
  - [ ] Coverage reporting integrated into CI
  - [ ] Coverage improvement plan created
  - [ ] Coverage measurement process documented
  - [ ] Current coverage baseline established
- **Impact**: Enables data-driven test improvement by identifying untested code paths and tracking coverage over time.

---



### 205. Implement Lean tool usage verification and monitoring system
- **Effort**: 6-8 hours
- **Status**: [REVISING]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .claude/command/research.md
  - .claude/command/implement.md
  - .claude/agent/subagents/lean-research-agent.md
  - .claude/agent/subagents/lean-implementation-agent.md
  - .claude/context/core/standards/lean-tool-verification.md (new)
  - .claude/specs/monitoring/ (new directory structure)
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

---

### 218. Ensure lean-lsp-mcp Integration for Claude Code System
**Effort**: 1.5 hours
**Status**: [PLANNED]
**Started**: 2025-12-28
**Researched**: 2025-12-28
**Revised**: 2026-01-10
**Priority**: High
**Blocking**: None
**Dependencies**: 212 (completed)
**Language**: meta
**Research Artifacts**:
  - Main Report: [.claude/specs/218_fix_lean_lsp_mcp_integration/reports/research-002.md]
**Plan**: [.claude/specs/218_fix_lean_lsp_mcp_integration/plans/implementation-005.md]
**Plan Revision Notes** (v005, 2026-01-10): Migrated from OpenCode to Claude Code system. Previous plan (v004) was OpenCode-specific. Now verifying and documenting lean-lsp-mcp integration for Claude Code using `.mcp.json` config and `mcp__lean-lsp__*` tool calls.

**Files Affected**:
- .mcp.json (verify configuration)
- .claude/skills/skill-lean-implementation/SKILL.md (verify MCP tool declarations)
- .claude/skills/skill-lean-research/SKILL.md (verify MCP tool declarations)
- .claude/context/project/lean4/tools/mcp-tools-guide.md (update to remove Python client references)

**Description**:
Task 218 originally addressed OpenCode MCP integration (v001-v004), but the project has migrated to Claude Code. This revision (v005) verifies lean-lsp-mcp tools work correctly with Claude Code's native MCP support via `.mcp.json` and the skill system's `mcp__lean-lsp__*` tool declarations. Focus is on verification and documentation rather than configuration changes.

**Acceptance Criteria**:
- [ ] .mcp.json verified correct for Claude Code
- [ ] skill-lean-implementation has correct MCP tool declarations
- [ ] skill-lean-research has correct MCP tool declarations
- [ ] mcp-tools-guide.md updated for Claude Code patterns
- [ ] MCP tools verified working (goal, diagnostics, search)
- [ ] Rate limits documented for search tools
- [ ] Selective tool enablement reduces context window usage

**Impact**:
CRITICAL ARCHITECTURAL CORRECTION: Pivots from incompatible custom Python client to proper OpenCode-native MCP integration. Enables lean-lsp-mcp tools for real-time Lean compilation checking, proof verification, and theorem search. Reduces context window usage by 2000-5000 tokens through selective per-agent tool enablement. Establishes foundation for additional MCP servers (Context7, Grep) to enhance Lean development workflow.

---


### 291. Fix lean-research-agent to delegate status updates to status-sync-manager instead of direct file manipulation
- **Effort**: 2-3 hours
- **Status**: [IMPLEMENTING]
- **Started**: 2026-01-04
- **Researched**: 2026-01-04
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 290 (researched)

**Research Artifacts**:
  - Research Report: [.claude/specs/291_fix_lean_research_agent_delegate_status_updates/reports/research-001.md]

**Description**:
Fix lean-research-agent.md to use proper delegation pattern for status updates instead of direct file manipulation. The agent currently bypasses status-sync-manager and git-workflow-manager, causing status synchronization failures. Update step_6 to match researcher.md's delegation pattern, remove summary artifact requirement, and ensure atomic updates across TODO.md and state.json. See research report for detailed root cause analysis, fix strategy, and code examples.

**Files to Modify**:
- `.claude/agent/subagents/lean-research-agent.md` - Update step_6 to delegate to status-sync-manager and git-workflow-manager

**Acceptance Criteria**:
- [ ] lean-research-agent step_6 delegates to status-sync-manager (not direct file updates)
- [ ] lean-research-agent step_6 delegates to git-workflow-manager (not manual git commands)
- [ ] Summary artifact requirement removed (only research report created)
- [ ] `/research` on Lean tasks updates status to `[RESEARCHED]` at start and end
- [ ] Artifact link added to TODO.md (research report only)
- [ ] state.json updated with artifact path
- [ ] Git commit created automatically
- [ ] Behavior matches researcher.md exactly
- [ ] No regression in Lean research functionality

**Impact**:
Fixes the root cause of status synchronization failures for Lean tasks. Ensures lean-research-agent uses the same atomic update pattern as researcher.md via status-sync-manager and git-workflow-manager delegation.

---



### 323. Fix /todo command to run markdown formatter after completion

- **Effort**: TBD
- **Status**: [IMPLEMENTING]
- **Researched**: 2026-01-05
- **Planned**: 2026-01-07
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Research Artifacts**:
  - Research Report: [.claude/specs/323_fix_todo_command_to_run_markdown_formatter_after_completion/reports/research-001.md]

**Plan Artifacts**:
  - Implementation Plan: [.claude/specs/323_fix_todo_command_to_run_markdown_formatter_after_completion/plans/implementation-001.md]

**Description**: Fix the /todo command to run the markdown formatter on TODO.md after completing its archival operations. This ensures TODO.md remains properly formatted after task archival.

---

## Low Priority

### 346. Refactor commands to delegate to skills
- **Effort**: 8-12 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Refactor the .claude/ agent system to use 'thin wrapper' commands that parse arguments and delegate to corresponding skills for execution, enabling skill reuse across commands and cleaner separation of concerns.

---

### 257. Completeness Proofs

 **Effort**: 70-90 hours
 **Status**: [IMPLEMENTING]
 **Priority**: Low
 **Language**: lean
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

**Acceptance Criteria**:
- [ ] Lindenbaum lemma implemented
- [ ] Maximal consistent set properties proven
- [ ] Canonical frame constructed with frame properties
- [ ] Truth lemma proven
- [ ] Weak and strong completeness proven

**Impact**: Completes the metalogic foundation for TM logic by proving completeness, enabling derivability from validity.

---

### 260. Proof Search
- **Effort**: 40-60 hours
- **Status**: [BLOCKED]
- **Started**: 2026-01-05
- **Priority**: Medium
- **Language**: lean
- **Blocking**: Axiom refactor (Prop → Type) or Classical.choice research
- **Dependencies**: None
- **Research**: [Research Report](.claude/specs/260_proof_search/reports/research-001.md)
- **Plan**: [Implementation Plan](.claude/specs/260_proof_search/plans/implementation-001.md)
- **Implementation**: [Implementation Summary](.claude/specs/260_proof_search/summaries/implementation-summary-20260105.md)

**Description**: Implement automated proof search for TM logic.

**Blocking Reason**: Phase 1 (Proof Term Construction) blocked by `Axiom` being `Prop` instead of `Type`. Cannot return `Option (Axiom φ)` from witness function. Need either: (1) Axiom refactor to Type, (2) Classical.choice approach, or (3) pivot to Phase 2 (Tactic Integration).

**Action Items**:
1. Implement breadth-first proof search.
2. Implement heuristic-guided search.

**Files**:
- `Logos/Core/Automation/ProofSearch.lean`

**Acceptance Criteria**:
- [ ] Breadth-first proof search implemented
- [ ] Heuristic-guided search implemented
- [ ] Tests added for proof search
- [ ] Performance benchmarks created
- [ ] Documentation updated

**Impact**: Enables automated proof discovery for TM logic, reducing manual proof construction effort.

---

### 261. Decidability
- **Effort**: 40-60 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement decision procedures for TM logic.

**Action Items**:
1. Implement tableau method.
2. Implement satisfiability decision procedure.

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (to be created)

**Acceptance Criteria**:
- [ ] Tableau method implemented
- [ ] Satisfiability decision procedure implemented
- [ ] Tests added for decision procedures
- [ ] Documentation updated

**Impact**: Provides algorithmic decision procedures for TM logic validity and satisfiability.

---


### 263. Refactor Context.lean
- **Effort**: 2-4 hours
- **Status**: [IMPLEMENTING]
- **Started**: 2026-01-08
- **Priority**: Medium
- **Language**: lean
- **Blocking**: Task 264
- **Dependencies**: None

**Plan Artifacts**:
  - Implementation Plan: [.claude/specs/263_update_all_commands_for_new_argument_mechanism/plans/implementation-001.md]

**Description**: Refactor the `Context.lean` file to improve clarity, performance, and alignment with the LEAN 4 style guide. This involves reviewing the existing implementation of proof contexts and applying best practices for data structures and function definitions in LEAN 4.

**Files Affected**:
- `Logos/Core/Syntax/Context.lean`
- `LogosTest/Core/Syntax/ContextTest.lean`

**Acceptance Criteria**:
- [ ] The `Context.lean` file is refactored for clarity and performance.
- [ ] All related tests in `ContextTest.lean` are updated and pass.
- [ ] The refactoring adheres to the LEAN 4 style guide.
- [ ] The public API of the `Context` module remains backward-compatible or changes are documented.

**Impact**: Improves the maintainability and readability of a core component of the syntax package.

---

### 264. Update Context References
- **Effort**: 1-2 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: Task 263

**Plan Artifacts**:
  - Implementation Plan: [.claude/specs/264_test_and_document_argument_passing/plans/implementation-001.md]

**Files Affected**:
- `Logos/Core/ProofSystem/Derivation.lean`
- `Logos/Core/Metalogic/DeductionTheorem.lean`
- Other files that import `Logos.Core.Syntax.Context`

**Description**: After refactoring `Context.lean`, update all references to the `Context` module throughout the codebase to ensure they are compatible with any changes made to the API. This task involves searching for all usages of `Context` and updating them as necessary.

**Acceptance Criteria**:
- [ ] All references to the `Context` module are updated.
- [ ] The project builds successfully after the updates.
- [ ] All tests pass after the updates.

**Impact**: Ensures that the entire codebase is compatible with the refactored `Context` module.

---

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

---

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

---

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

---

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

---

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

---

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

---

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

---

### 175. Establish CI/CD pipeline with automated testing and linting
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .github/workflows/ci.yml (new)
  - .github/workflows/lint.yml (new)
  - .github/workflows/coverage.yml (new)
  - Documentation/Development/CI_CD_PROCESS.md (new)
- **Description**: Create GitHub Actions workflows for continuous integration and deployment. Currently all tests run manually. CI/CD pipeline should run tests, linting, style checks, coverage reporting, and documentation build checks automatically on every pull request and commit.
- **Acceptance Criteria**:
  - [ ] GitHub Actions workflow for tests created and passing
  - [ ] Linting and style checks integrated into CI
  - [ ] Coverage reporting integrated into CI
  - [ ] Documentation build checks integrated into CI
  - [ ] CI runs on all pull requests and commits to main
  - [ ] CI failure blocks merge
  - [ ] CI/CD process documented in CI_CD_PROCESS.md
- **Impact**: Ensures code quality automatically, prevents regressions, and enables confident merging of pull requests. Essential for maintaining production-ready code.

---

### 335. Refactor /errors command and error-diagnostics-agent
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: general
- **Blocking**: None
- **Dependencies**: None

**Plan Artifacts**:
  - Implementation Plan: [.claude/specs/335_refactor_errors_command/plans/implementation-001.md]

**Description**: Refactor the /errors command and error-diagnostics-agent subagent to follow modern .opencode standards. Simplify command file to <300 lines with 4-stage pattern, refactor subagent to use 8-stage workflow_execution, move all workflow logic from command to subagent, optimize context loading to Level 2, ensure standardized return format.

---



### 338. Update /task command to use status-sync-manager directly
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: general
- **Blocking**: None
- **Dependencies**: None

**Plan**: [Implementation Plan](.claude/specs/338_update_task_command_to_use_status_sync_manager_directly/plans/implementation-001.md)

**Description**: Update Stage 3 (CreateTasks) in /task command to delegate directly to status-sync-manager with operation: create_task instead of deprecated task-creator. Follow the pattern from /research and /implement commands (Stage 1.5 Preflight). Add validation gates to verify task creation succeeded. Test with multiple scenarios.

---

### 339. Remove deprecated task-creator subagent
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: general
- **Blocking**: None
- **Dependencies**: Task 338

**Plan**: [Implementation Plan](.claude/specs/339_remove_deprecated_task_creator_subagent/plans/implementation-001.md)

**Description**: Remove .claude/agent/subagents/task-creator.md file since it's deprecated and no longer used. Update any documentation that references it. Verify no other commands depend on it.

---

### 340. Add validation gates to all command files
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: general
- **Blocking**: None
- **Dependencies**: None

**Plan**: [Implementation Plan](.claude/specs/340_add_validation_gates_to_all_command_files/plans/implementation-001.md)

**Description**: Audit all command files in .claude/command/ to ensure they have proper validation gates that prevent architectural violations. Add pre-execution and post-execution validation following patterns from /research and /implement. Document validation gate patterns in .claude/context/core/standards/validation-gates.md.

---

### 341. Create deprecation policy and migration guide
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Plan**: [Implementation Plan](.claude/specs/341_create_deprecation_policy_and_migration_guide/plans/implementation-001.md)

**Description**: Create .claude/context/core/standards/deprecation-policy.md documenting how to deprecate agents/commands safely. Include migration checklist: (1) Mark as deprecated with reason, (2) Update all callers, (3) Add deprecation warnings, (4) Remove after migration complete. Create migration guide for moving from deprecated agents to replacements.

---


### 343. Design command file workflow execution architecture
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: 342
- **Description**: Design comprehensive architecture for orchestrator to execute command file workflow_execution stages. Define stage parsing mechanism, execution engine design, context passing between stages, error handling and rollback strategy, and integration with existing delegation system. Create detailed design document with sequence diagrams, data flow diagrams, and implementation specifications.

---

### 344. Implement orchestrator workflow execution engine
- **Effort**: 8-12 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: 342, 343
- **Description**: Implement orchestrator workflow execution engine that parses command file workflow_execution stages and executes them in sequence. Implement stage parser, execution engine, context passing mechanism, error handling and rollback, and integration with existing delegation system. Ensure Stage 3.5 (Postflight) executes correctly for all workflow commands, including artifact extraction, validation, status updates via status-sync-manager, and git commits via git-workflow-manager.

---

### 345. Test and validate all workflow commands with postflight execution
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: 342, 343, 344
- **Description**: Comprehensive testing of all workflow commands (/implement, /research, /plan, /revise) to verify postflight stages execute correctly. Test artifact creation and linking, status updates to completed markers, git commit creation, error handling and rollback, and defense-in-depth verification. Validate that Task 335 scenario (artifacts created but status not updated) is fixed. Create test report documenting all test cases, results, and any issues found.


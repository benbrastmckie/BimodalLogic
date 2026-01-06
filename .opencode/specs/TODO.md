---
last_updated: 2026-01-05T00:00:00Z
next_project_number: 326
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2026-01-05T02:00:00Z
task_counts:
  active: 51
  completed: 64
  in_progress: 2
  not_started: 34
  abandoned: 6
  total: 115
priority_distribution:
  high: 17
  medium: 22
  low: 13
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---

# TODO


---

## High Priority

### 328. Fix /task command to only create task entries and never implement directly
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-06
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Research Artifacts**:
  - Research Report: [.opencode/specs/328_fix_task_command_to_only_create_task_entries_and_never_implement_directly/reports/research-001.md]

**Description**: Fix the /task command to ensure it ONLY creates task entries in TODO.md and state.json, and NEVER implements the work described in the task. The command should parse the task description, reformulate it naturally, optionally divide into subtasks if --divide flag is present, delegate to status-sync-manager for atomic task creation, and return task numbers to the user. The command must be architecturally prevented from creating code files, running build tools, or doing any implementation work. Implementation happens later via /implement command.

---


### 302. Test Dual-Mode Revision Workflow
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Dependencies**: 301

**Description**: Create comprehensive tests for the dual-mode revision workflow, covering task-only revision, plan revision without new reports, and plan revision with new reports.

**Action Items**:
1. Create test task without plan and test task-only revision
2. Create test task with plan (no new reports) and test plan revision
3. Create test task with plan and new reports, test report integration
4. Validate atomic updates to TODO.md and state.json
5. Verify git commits created correctly for each mode
6. Document test cases and expected outcomes

**Acceptance Criteria**:
- [ ] Test case 1: Task-only revision updates description/priority/effort
- [ ] Test case 2: Plan revision creates new version without reports
- [ ] Test case 3: Plan revision integrates new reports into phases
- [ ] All modes update TODO.md and state.json atomically
- [ ] Git commits created with appropriate messages
- [ ] Rollback works correctly on failures
- [ ] Test documentation added to `.opencode/TESTING.md`

**Impact**: Ensures reliability and correctness of dual-mode revision workflow across all scenarios.

---

### 257. Completeness Proofs
 **Effort**: 70-90 hours
 **Status**: [PLANNED]
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
- **Research**: [Research Report](.opencode/specs/260_proof_search/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/260_proof_search/plans/implementation-001.md)
- **Implementation**: [Implementation Summary](.opencode/specs/260_proof_search/summaries/implementation-summary-20260105.md)

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

### 262. ModalS5 Limitation
- **Effort**: 2 hours
- **Status**: [REVISING]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: The theorem `diamond_mono_imp` in `ModalS5.lean` is marked with `sorry` because it is not valid as an object-level implication. This is a documented limitation.

**Action Items**:
1. Maintain documentation or find alternative formulation if possible.

**Files**:
- `Logos/Core/Theorems/ModalS5.lean`

**Acceptance Criteria**:
- [ ] Documentation maintained or alternative formulation found
- [ ] SORRY_REGISTRY.md updated with justification

**Impact**: Resolves documented limitation in ModalS5 theorems.

---

### 263. Refactor Context.lean
- **Effort**: 2-4 hours
- **Status**: [REVISING]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: Task 264
- **Dependencies**: None

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
- **Status**: [REVISING]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: Task 263

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

## High Priority

### 132. Prove Lindenbaum maximal consistency lemma in Completeness.lean
- **Effort**: 3 hours
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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


---

### 139. Draft Layer 1 counterfactual operator plan
- **Effort**: 2 hours
- **Status**: [REVISING]
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

---

### 140. Draft Layer 2 epistemic operator plan
- **Effort**: 2 hours
- **Status**: [REVISING]
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

---

### 141. Draft Layer 3 normative operator plan
- **Effort**: 2 hours
- **Status**: [REVISING]
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

### 175. Establish CI/CD pipeline with automated testing and linting
- **Effort**: 13 hours
- **Status**: [REVISING]
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

### 176. Enhance proof search with domain-specific heuristics and caching
- **Effort**: 18 hours
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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
- **Status**: [REVISING]
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

### 189. Add --divide flag to /research command for topic subdivision
- **Effort**: 3 hours
- **Status**: [PLANNING]
- **Started**: 2025-12-26
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [.opencode/specs/189_research_divide_flag/reports/research-001.md]
  - Summary: [.opencode/specs/189_research_divide_flag/summaries/research-summary.md]
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/specialists/web-research-specialist.md
- **Description**: Add a --divide flag to the /research command that changes its behavior. Without --divide, /research should create individual research reports only (no research summary). With --divide, /research should invoke a subagent to divide the research topic into natural subtopics, pass each subtopic to further research subagents to research and create individual reports, then compile the references and brief summaries into a research summary report. The research summary should contain only references to the individual reports and their brief summaries, not duplicate the full content.
- **Acceptance Criteria**:
  - [ ] --divide flag added to /research command documentation and input parsing
  - [ ] Without --divide: /research creates only individual research reports (reports/research-NNN.md), no summary
  - [ ] With --divide: /research divides topic into subtopics using a subagent
  - [ ] With --divide: Each subtopic is researched by a separate subagent, creating individual reports
  - [ ] With --divide: Research summary report (summaries/research-summary.md) is created compiling references and brief summaries
  - [ ] Research summary contains only references and brief summaries, not full content
  - [ ] All behavior follows lazy directory creation (create summaries/ only when writing summary)
  - [ ] Status markers and state sync work correctly for both modes
  - [ ] Documentation updated to explain --divide flag behavior
- **Impact**: Provides more flexible research workflow - simple research creates focused reports without overhead of summary compilation, while complex research can be divided into manageable subtopics with a summary overview.

---

### 203. Add --complex flag to /research for subtopic subdivision with summary
- **Effort**: TBD
- **Status**: [REVISING]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/lean-research-agent.md
- **Description**: Enhance the /research command to support a --complex flag that changes its behavior for handling complex research topics. Without --complex flag: /research creates a single research report (reports/research-001.md) with no summary - this is the current default behavior. With --complex flag: /research should (1) Divide the topic into 1-5 appropriate subtopics using intelligent analysis, (2) Spawn research subagents to complete each subtopic in parallel, creating individual research reports (reports/research-001.md, reports/research-002.md, etc.), (3) Each subagent returns only its report path and brief summary (not full content) to the primary agent, (4) Primary agent compiles all report paths and brief summaries into a research summary report (summaries/research-summary.md), (5) Update TODO.md and state.json with all report references and mark task as [RESEARCHED]. The --complex flag enables comprehensive research on large topics while protecting context windows through summarization.
- **Acceptance Criteria**:
  - [ ] --complex flag added to /research command argument parsing
  - [ ] Without --complex: /research creates single report, no summary (current behavior preserved)
  - [ ] With --complex: Topic intelligently divided into 1-5 subtopics
  - [ ] With --complex: Separate research subagents spawned for each subtopic
  - [ ] With --complex: Each subtopic generates individual report (reports/research-NNN.md)
  - [ ] With --complex: Subagents return only report path + brief summary (not full content)
  - [ ] With --complex: Primary agent creates research summary (summaries/research-summary.md) compiling all references
  - [ ] Research summary contains only paths and brief summaries, not duplicated full content
  - [ ] Lazy directory creation followed (summaries/ created only when writing summary)
  - [ ] TODO.md updated with all report references and [RESEARCHED] status for both modes
  - [ ] state.json updated correctly for both modes
  - [ ] Documentation explains --complex flag behavior and use cases
- **Impact**: Enables comprehensive research on complex topics by dividing them into manageable subtopics while protecting the primary agent's context window through summarization. Provides flexibility - simple topics get focused single reports, complex topics get thorough multi-report coverage with summary overview.

---

### 205. Implement Lean tool usage verification and monitoring system
- **Effort**: 6-8 hours
- **Status**: [REVISING]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/command/implement.md
  - .opencode/agent/subagents/lean-research-agent.md
  - .opencode/agent/subagents/lean-implementation-agent.md
  - .opencode/context/core/standards/lean-tool-verification.md (new)
  - .opencode/specs/monitoring/ (new directory structure)
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

### 218. Fix lean-lsp-mcp integration and opencode module import errors
**Effort**: 0.75 hours
**Status**: [PLANNED]
**Started**: 2025-12-28
**Researched**: 2025-12-28
**Priority**: High
**Blocking**: None
**Dependencies**: 212 (completed)
**Language**: python
**Research Artifacts**:
  - Main Report: [.opencode/specs/218_fix_lean_lsp_mcp_integration/reports/research-002.md]
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

---

### 279. Systematically fix metadata lookup to use state.json instead of TODO.md
- **Effort**: 12-16 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Researched**: 2026-01-05
- **Research**: [research-001.md](279_systematically_fix_metadata_lookup_to_use_state_json_instead_of_todo_md/reports/research-001.md)
**Description**:
When running `/implement 276`, the command output showed "Extract task 276 details from TODO.md" which indicates that commands and subagents are extracting metadata from TODO.md instead of from the authoritative source (state.json). This research identifies 25 files across orchestrator, commands, subagents, context, standards, templates, and documentation that use TODO.md for metadata extraction instead of state.json.

**Impact**:
Establishes state.json as single source of truth, eliminates "Extract task NNN details from TODO.md" messages, ensures correct language-based routing to Lean-specific agents, and preserves TODO.md as synchronized user-facing view.

---

### 291. Fix lean-research-agent to delegate status updates to status-sync-manager instead of direct file manipulation
- **Effort**: 2-3 hours
- **Status**: [PLANNING]
- **Started**: 2026-01-04
- **Researched**: 2026-01-04
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 290 (researched)

**Research Artifacts**:
  - Research Report: [.opencode/specs/291_fix_lean_research_agent_delegate_status_updates/reports/research-001.md]

**Description**:
Fix lean-research-agent.md to use proper delegation pattern for status updates instead of direct file manipulation. The agent currently bypasses status-sync-manager and git-workflow-manager, causing status synchronization failures. Update step_6 to match researcher.md's delegation pattern, remove summary artifact requirement, and ensure atomic updates across TODO.md and state.json. See research report for detailed root cause analysis, fix strategy, and code examples.

**Files to Modify**:
- `.opencode/agent/subagents/lean-research-agent.md` - Update step_6 to delegate to status-sync-manager and git-workflow-manager

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

## Medium Priority

### 317. Implement BFS variant for proof search completeness (Phase 3)
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement Phase 3 of task 260: BFS Variant. Add breadth-first search variant to ProofSearch.lean to ensure completeness guarantees. Current implementation uses bounded DFS which may miss proofs. BFS variant will explore search space level-by-level, guaranteeing shortest proofs are found first.

---

### 318. Implement advanced heuristics for proof search performance (Phase 4)
- **Effort**: 12-18 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement Phase 4 of task 260: Advanced Heuristics. Enhance proof search with domain-specific heuristics and caching to improve performance. Implement proper sorting in orderSubgoalsByScore (currently returns targets in original order). Add heuristic scoring based on formula structure, proof depth, and historical success rates. Implement proof caching to avoid redundant search.

---

### 319. Expand testing for proof search automation (Phase 5)
- **Effort**: 8-12 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement Phase 5 of task 260: Expanded Testing. Add comprehensive tests for proof search automation covering all phases. Test proof term construction, tactic integration, BFS variant, and advanced heuristics. Add property-based tests for completeness and soundness guarantees. Ensure test coverage for edge cases and performance benchmarks.

---



### 308. Final cleanup and comprehensive testing (5/5)
- **Effort**: 15 minutes
- **Status**: [REVISING]
- **Priority**: Medium
- **Language**: general
- **Blocking**: None
- **Dependencies**: None

**Description**: Complete final cleanup of any remaining cruft from files not reverted. Test all commands (/task, /meta, /todo, /review) comprehensively to ensure everything works correctly. Commit clean changes with proper documentation.

---




### 315. Research and resolve Axiom Prop vs Type blocker for proof term construction
- **Effort**: 61-97 hours
- **Status**: [REVISING]
- **Started**: 2026-01-05
- **Researched**: 2026-01-05
- **Planned**: 2026-01-05
- **Priority**: High
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Research**: 
  - [Initial Analysis](.opencode/specs/315_research_and_resolve_axiom_prop_vs_type_blocker_for_proof_term_construction/reports/research-001.md)
  - [Approach Comparison for AI Training](.opencode/specs/315_research_and_resolve_axiom_prop_vs_type_blocker_for_proof_term_construction/reports/research-002.md)
- **Plan**:
  - [Implementation Plan](.opencode/specs/315_research_and_resolve_axiom_prop_vs_type_blocker_for_proof_term_construction/plans/implementation-001.md)

**Description**: Research and implement solution to unblock Phase 1 (Proof Term Construction) of task 260. The blocker is that Axiom φ is a Prop, not a Type, making it impossible to return Option (Axiom φ) from find_axiom_witness. Investigate three approaches: (1) Classical.choice with decidability, (2) Refactor Axiom to Type instead of Prop, (3) Pivot to tactic-mode proof construction. Choose and implement the most viable approach to enable programmatic proof term construction.

**Research Findings** (2026-01-05): 
- **Initial Analysis**: Analyzed three approaches with viability ratings: (1) Classical.choice (3/10) - noncomputable and complex, (2) Refactor to Type (6/10) - high-risk breaking change, (3) Tactic-Mode (9/10) - highly recommended for immediate implementation.
- **Follow-up Analysis**: Compared Approach 2 vs 3 for AI training data generation (DUAL_VERIFICATION.md). Key findings: (1) Approach 3 is standard in Lean 4 ecosystem (Mathlib, Aesop, Duper), (2) Both approaches fully compatible (hybrid strategy viable), (3) Approach 2 vastly superior for AI training (5/5 vs 0/5 on requirements). **Hybrid Recommendation**: Phase 1 - Implement Approach 3 (tactic) for immediate user value (28-44 hours), Phase 2 - Implement Approach 2 (programmatic API) for AI training pipeline (33-53 hours). Alternative: Skip Phase 1 if AI training is primary goal.

---

### 316. Implement tactic integration for modal_search tactic (Phase 2)
- **Effort**: 8-12 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement Phase 2 of task 260: Tactic Integration. Create modal_search tactic that constructs proofs in tactic mode, avoiding Prop vs Type issues. This phase is prioritized over Phase 1 as it may be easier than programmatic proof term construction and is more useful for end users (interactive proof development). Integrate with existing ProofSearch.lean infrastructure.

---









## Medium Priority

### 323. Fix /todo command to run markdown formatter after completion
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Fix the /todo command to run the markdown formatter on TODO.md after completing its archival operations. This ensures TODO.md remains properly formatted after task archival.

---

### 325. Create --recover flag for /task command to unarchive projects
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Create a --recover flag for the /task command together with a task number as an argument that can be used to unarchive a project directory from specs/archive/, updating the specs/TODO.md and specs/state.json files accordingly.

---

### 326. Create --divide flag for /task command with task division capability
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Create a --divide flag for the /task command that accepts a task number as an argument. This flag should divide an existing task into an appropriate number of subtasks, add the new task numbers as dependencies to the original task, and create the new task entries atomically.

---


### 259. Automation Tactics
- **Effort**: 20.0
- **Status**: [REVISING]
- **Priority**: Medium
- **Language**: lean
- **Artifacts**:
  - .opencode/specs/259_automation_tactics/reports/research-001.md
  - .opencode/specs/259_automation_tactics/plans/implementation-001.md

**Description**: Task 259

---

### 322. Add bulk operation to status-sync-manager for creating/updating many tasks
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Add new bulk operation to status-sync-manager for creating/updating many tasks, integrating with existing bulk functionality implemented for /abandon and /task --divide commands. The aim is optimization for elegant executions with bulk operations.


---

### 327. Review context file references and optimize context loading strategy
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Researched**: 2026-01-06
- **Planned**: 2026-01-06
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Research Artifacts**:
  - Research Report: [.opencode/specs/327_review_context_file_references_and_optimize_context_loading_strategy/reports/research-001.md]

**Plan Artifacts**:
  - Implementation Plan: [.opencode/specs/327_review_context_file_references_and_optimize_context_loading_strategy/plans/implementation-001.md]

**Description**: Verify that all context file references are current and valid following task 314 implementation. Conduct systematic review of context loading patterns across commands and agents to identify opportunities for optimization. Goals: (1) Eliminate broken references to deprecated context files, (2) Prevent context bloating by loading only necessary context, (3) Ensure sufficient context is loaded for each operation type, (4) Document context loading best practices.

---


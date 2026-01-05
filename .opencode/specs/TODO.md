---
last_updated: 2026-01-05T13:15:00Z
next_project_number: 311
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2026-01-04T06:25:00Z
task_counts:
  active: 46
  completed: 83
  in_progress: 3
  not_started: 33
  abandoned: 20
  total: 149
priority_distribution:
  high: 27
  medium: 20
  low: 13
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---

# TODO

## High Priority

### 309. Implement Option 1 (Direct Delegation) from task 309 analysis to optimize /task command performance
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](.opencode/specs/309_optimize_task_command_performance/reports/research-001.md)
- **Researched**: 2026-01-05
- **Plan**: [implementation-001.md](.opencode/specs/309_optimize_task_command_performance/plans/implementation-001.md)
- **Planned**: 2026-01-05
- **Implementation**: [implementation-summary-20260105.md](.opencode/specs/309_optimize_task_command_performance/summaries/implementation-summary-20260105.md)
- **Implemented**: 2026-01-05

**Description**: Implement Option 1 (Direct Delegation) from task 309 analysis to optimize /task command performance. Modify /task command Stage 4 to delegate directly to status-sync-manager instead of task-creator, eliminating unnecessary delegation layer and achieving 40-50% performance improvement.

---

### 306. Refactor /meta command to create tasks instead of direct implementation
- **Effort**: 8 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](.opencode/specs/306_refactor_meta_command_to_create_tasks_instead_of_direct_implementation/reports/research-001.md)
- **Researched**: 2026-01-05
- **Plan**: [implementation-002.md](.opencode/specs/306_refactor_meta_command_to_create_tasks_instead_of_direct_implementation/plans/implementation-002.md)
- **Planned**: 2026-01-05
- **Revised**: 2026-01-05

**Description**: Refactor the /meta command to always create an appropriate number of tasks (similar to /task command) rather than directly implementing the work. Preserve the interview functionality to clarify requirements when needed, or run in full interactive mode when /meta is called with no arguments. The result should be task creation with dependencies indicated and plan artifacts stored in the appropriate artifact structure per artifact-management.md.

---

### 304. Test commands after unintended changes (2/5)
- **Effort**: 30 minutes
- **Status**: [ABANDONED]
- **Priority**: High
- **Language**: general
- **Blocking**: None
- **Dependencies**: None
- **Abandoned**: 2026-01-05
- **Abandonment Reason**: User requested abandonment via /abandon command

**Description**: Test /task, /meta, and /todo commands to verify they still work correctly after the unintended changes. Document any failures or unexpected behavior. This determines whether to keep or revert core logic changes.

---

### 307. Verify or revert core logic changes in high-risk files (4/5)
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**: Based on test results from task 304, either keep the core logic changes in meta.md and task-creator.md (if commands work) or revert them to previous versions (if commands fail or create_task doesn't exist). This is a critical decision point.

---

### 299. Create Task Reviser Subagent
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Dependencies**: None
- **Plan**: [implementation-001.md](.opencode/specs/299_create_task_reviser_subagent/plans/implementation-001.md)
- **Planned**: 2026-01-05
- **Implementation**: [implementation-summary-20260105.md](.opencode/specs/299_create_task_reviser_subagent/summaries/implementation-summary-20260105.md)
- **Implemented**: 2026-01-05

**Description**: Create a new subagent `task-reviser.md` that handles task-only revision mode when no plan exists. This subagent will update task descriptions, requirements, and metadata in TODO.md and state.json atomically.

**Action Items**:
1. Create `.opencode/agent/subagents/task-reviser.md` following subagent template
2. Implement task metadata extraction from state.json
3. Implement task description revision logic with user prompts
4. Integrate with status-sync-manager for atomic updates
5. Add validation for task existence and revision context
6. Return standardized format per subagent-return-format.md

**Acceptance Criteria**:
- [ ] task-reviser.md created with proper frontmatter
- [ ] Extracts task metadata from state.json
- [ ] Prompts user for revision details (description, priority, effort)
- [ ] Updates TODO.md and state.json atomically via status-sync-manager
- [ ] Returns standardized format with updated task info
- [ ] Handles errors gracefully with rollback

**Impact**: Enables task revision without requiring a plan, supporting early-stage task refinement.

---

### 300. Add Report Detection to Planner
- **Effort**: 4 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Dependencies**: None

**Description**: Enhance the planner subagent to detect new reports created since the last plan version and integrate their findings into plan revisions.

**Action Items**:
1. Add report directory scanning logic to planner
2. Implement timestamp comparison (report mtime vs plan mtime)
3. Extract new report paths and read their contents
4. Integrate new report findings into plan revision context
5. Update plan metadata to track integrated reports
6. Add validation for report file existence and format

**Acceptance Criteria**:
- [ ] Planner scans `.opencode/specs/NNN_*/reports/` directory
- [ ] Compares report modification times with plan creation time
- [ ] Identifies reports created after last plan version
- [ ] Reads and extracts key findings from new reports
- [ ] Includes new findings in revised plan Overview and Phases
- [ ] Updates plan metadata with `reports_integrated` field
- [ ] Logs report integration in plan revision notes

**Impact**: Ensures plan revisions leverage the latest research and analysis findings, improving plan quality and accuracy.

---

### 301. Enhance Revise Command with Dual-Mode Routing
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Dependencies**: 299, 300

**Description**: Update `/revise` command to detect plan presence and route to either task-reviser (no plan) or planner (plan exists with report integration).

**Action Items**:
1. Update `.opencode/command/revise.md` workflow
2. Add plan existence detection in Stage 1 (ParseAndValidate)
3. Implement dual routing logic: task-reviser vs planner
4. Pass report detection context to planner when plan exists
5. Update command documentation with dual-mode examples
6. Add validation for routing decision correctness

**Acceptance Criteria**:
- [ ] Stage 1 checks for plan_path in state.json
- [ ] If plan_path empty/missing: route to task-reviser
- [ ] If plan_path exists: route to planner with report context
- [ ] Planner receives flag to check for new reports
- [ ] Command documentation updated with both modes
- [ ] Examples added for task-only and task+plan revision
- [ ] Validation ensures correct routing based on plan presence

**Impact**: Provides flexible revision workflow supporting both early-stage task refinement and plan updates with research integration.

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
 **Status**: [NOT STARTED]
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
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement automated proof search for TM logic.

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
- **Status**: [NOT STARTED]
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
- **Status**: [NOT STARTED]
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
- **Status**: [RESEARCHING]
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

---

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

---

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

### 189. Add --divide flag to /research command for topic subdivision
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
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
- **Status**: [NOT STARTED]
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
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
When running `/implement 276`, the command output showed "Extract task 276 details from TODO.md" which indicates that commands and subagents are extracting metadata from TODO.md instead of from the authoritative source (specs/state.json). TODO.md should be kept in sync as a user-facing version of state.json, but all metadata lookups should reference state.json as the single source of truth.

**Current Behavior**:
```bash
/implement 276
# Output shows: "Extract task 276 details from TODO.md"
# Problem: Using TODO.md for metadata lookup instead of state.json
```

**Expected Behavior**:
```bash
/implement 276
# Should: Extract task 276 metadata from state.json
# Should: Use state.json as single source of truth
# Should: Update TODO.md to reflect state.json changes (sync direction: state.json → TODO.md)
```

**Root Cause Analysis**:

Comprehensive codebase search reveals widespread use of TODO.md for metadata extraction:

1. **Orchestrator** (`.opencode/agent/orchestrator.md`):
   - Stage 2 (DetermineRouting): "Extract language from state.json or TODO.md"
   - Should be: Extract language from state.json ONLY

2. **Workflow Commands** (4 files):
   - `/research` - "Extract language from task entry (state.json or TODO.md)"
   - `/plan` - "Extract language from task entry (state.json or TODO.md)"
   - `/implement` - "Extract language from task entry (state.json or TODO.md)"
   - `/revise` - "Extract language from task entry (state.json or TODO.md)"
   - Should be: Extract from state.json ONLY

3. **Subagents** (7 files):
   - `researcher.md` - "Extract language from state.json (fallback to TODO.md)"
   - `planner.md` - "Read task from .opencode/specs/TODO.md"
   - `implementer.md` - "grep -A 50 "^### ${task_number}\." .opencode/specs/TODO.md"
   - `lean-research-agent.md` - "Extract language from state.json (fallback to TODO.md)"
   - `lean-implementation-agent.md` - "Read task from .opencode/specs/TODO.md"
   - `lean-planner.md` - "Read task from .opencode/specs/TODO.md"
   - `status-sync-manager.md` - "Extract current status from .opencode/specs/TODO.md"
   - Should be: Extract from state.json ONLY

4. **Context Files** (6 files):
   - `routing-guide.md` - "Extract language from task entry in TODO.md"
   - `routing-logic.md` - "task_entry=$(grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md)"
   - `research-workflow.md` - "Read task from TODO.md using grep"
   - `planning-workflow.md` - "Read task from TODO.md using grep"
   - `implementation-workflow.md` - "Read task from TODO.md using grep"
   - `subagent-structure.md` - "Read task from TODO.md"
   - Should be: Document state.json as source of truth

**Metadata Fields Affected**:

The following metadata fields are currently extracted from TODO.md but should come from state.json:

1. **Language** - Used for routing to Lean-specific agents
2. **Priority** - Used for task prioritization
3. **Status** - Used for workflow state tracking
4. **Effort** - Used for estimation
5. **Dependencies** - Used for task ordering
6. **Blocking** - Used for identifying blockers
7. **Description** - Used for task context
8. **Artifacts** - Used for linking research/plans/implementations

**Correct Architecture**:

```
state.json (authoritative source)
    ↓
    | (read metadata)
    ↓
Commands/Subagents
    ↓
    | (update metadata)
    ↓
status-sync-manager
    ↓
    | (atomic two-phase commit)
    ↓
state.json + TODO.md (synchronized)
```

**Sync Direction**: state.json → TODO.md (NOT bidirectional)

**Files to Modify** (25 files total):

**Orchestrator** (1 file):
- `.opencode/agent/orchestrator.md` - Update Stage 2 to extract language from state.json only

**Commands** (4 files):
- `.opencode/command/research.md` - Update Stage 1 to read from state.json
- `.opencode/command/plan.md` - Update Stage 1 to read from state.json
- `.opencode/command/implement.md` - Update Stage 1 to read from state.json
- `.opencode/command/revise.md` - Update Stage 1 to read from state.json

**Subagents** (7 files):
- `.opencode/agent/subagents/researcher.md` - Remove TODO.md fallback, use state.json only
- `.opencode/agent/subagents/planner.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/implementer.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/lean-research-agent.md` - Remove TODO.md fallback, use state.json only
- `.opencode/agent/subagents/lean-implementation-agent.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/lean-planner.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/status-sync-manager.md` - Extract status from state.json, not TODO.md

**Context Files** (6 files):
- `.opencode/context/core/system/routing-guide.md` - Document state.json as source
- `.opencode/context/core/system/routing-logic.md` - Update examples to use state.json
- `.opencode/context/project/processes/research-workflow.md` - Update to use state.json
- `.opencode/context/project/processes/planning-workflow.md` - Update to use state.json
- `.opencode/context/project/processes/implementation-workflow.md` - Update to use state.json
- `.opencode/context/core/standards/subagent-structure.md` - Document state.json pattern

**Standards** (2 files):
- `.opencode/context/core/system/state-management.md` - Clarify state.json as authoritative source
- `.opencode/context/core/system/artifact-management.md` - Document metadata lookup pattern

**Templates** (1 file):
- `.opencode/context/core/templates/command-template.md` - Update template to use state.json

**Documentation** (4 files):
- `.opencode/docs/guides/creating-commands.md` - Update examples to use state.json
- `.opencode/ARCHITECTURE.md` - Document state.json as source of truth
- `.opencode/REFACTOR.md` - Update refactoring notes
- `.opencode/REBUILD_SUMMARY.md` - Update rebuild notes

**Implementation Strategy**:

**Phase 1: Update Metadata Extraction Pattern** (4 hours)
1. Create helper function for state.json metadata extraction:
   ```bash
   # Extract task metadata from state.json
   task_metadata=$(jq -r --arg task_num "$task_number" \
     '.active_projects[] | select(.project_number == ($task_num | tonumber))' \
     .opencode/specs/state.json)
   
   # Extract specific fields
   language=$(echo "$task_metadata" | jq -r '.language // "general"')
   priority=$(echo "$task_metadata" | jq -r '.priority // "medium"')
   status=$(echo "$task_metadata" | jq -r '.status // "not_started"')
   ```

2. Document pattern in state-management.md
3. Create examples in routing-guide.md

**Phase 2: Update Orchestrator and Commands** (3 hours)
1. Update orchestrator.md Stage 2 (DetermineRouting)
2. Update research.md Stage 1 (PreflightValidation)
3. Update plan.md Stage 1 (PreflightValidation)
4. Update implement.md Stage 1 (PreflightValidation)
5. Update revise.md Stage 1 (PreflightValidation)

**Phase 3: Update Subagents** (4 hours)
1. Update researcher.md - Remove TODO.md fallback
2. Update planner.md - Replace grep with jq
3. Update implementer.md - Replace grep with jq
4. Update lean-research-agent.md - Remove TODO.md fallback
5. Update lean-implementation-agent.md - Replace grep with jq
6. Update lean-planner.md - Replace grep with jq
7. Update status-sync-manager.md - Extract status from state.json

**Phase 4: Update Context and Documentation** (3 hours)
1. Update 6 context files (routing, workflows, standards)
2. Update 2 standards files (state-management, artifact-management)
3. Update 1 template file (command-template)
4. Update 4 documentation files (guides, architecture, notes)

**Phase 5: Testing and Validation** (2 hours)
1. Test /research command with Lean task (language routing)
2. Test /plan command with markdown task
3. Test /implement command with general task
4. Test /revise command
5. Verify metadata extracted from state.json, not TODO.md
6. Verify TODO.md still synchronized correctly
7. Verify no grep TODO.md commands in output

**Acceptance Criteria**:
- [ ] All metadata extraction uses state.json as source of truth
- [ ] No commands or subagents extract metadata from TODO.md
- [ ] TODO.md remains synchronized via status-sync-manager (state.json → TODO.md)
- [ ] Language-based routing works correctly (Lean tasks → lean-research-agent)
- [ ] All workflow commands tested and verified
- [ ] Context files document state.json as authoritative source
- [ ] No "Extract task NNN details from TODO.md" messages in command output
- [ ] grep TODO.md only used for validation/testing, not metadata extraction

**Impact**: 
Establishes state.json as the single source of truth for task metadata, eliminating confusion about which file is authoritative. Ensures TODO.md is kept in sync as a user-facing view of state.json, but all programmatic access uses state.json. Fixes the issue observed in /implement 276 where TODO.md was being used for metadata lookup.

**Related Tasks**:
- Task 276: Investigate redundant project-level state.json files (related to state management)
- Task 272: Add YAML header to TODO.md (sync state.json → TODO.md)
- Task 275: Fix workflow status updates (uses status-sync-manager)

---

### 291. Fix lean-research-agent to delegate status updates to status-sync-manager instead of direct file manipulation
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Started**: 2026-01-04
- **Researched**: 2026-01-04
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 290 (researched)
- **Research**: [Research Report](.opencode/specs/291_fix_lean_research_agent_delegate_status_updates/reports/research-001.md)

**Description**:
Root cause identified for `/research 290` status update failure: lean-research-agent.md directly manipulates TODO.md and state.json files (lines 651-662) instead of delegating to status-sync-manager and git-workflow-manager like researcher.md does. This bypasses atomic updates and causes status synchronization failures.

**Evidence**:
- `/research 290` created research report successfully
- Status remained `[NOT STARTED]` instead of updating to `[RESEARCHED]`
- No artifact link added to TODO.md
- No state.json update
- No git commit created

**Root Cause**:
lean-research-agent.md step_6 (lines 641-750):
- Line 651-657: Directly updates TODO.md status marker
- Line 658-662: Directly updates state.json
- Does NOT delegate to status-sync-manager
- Does NOT delegate to git-workflow-manager

Compare with researcher.md step_4_postflight (lines 331-379):
- Line 335: Invokes status-sync-manager to mark [RESEARCHED]
- Line 349: Invokes git-workflow-manager to create commit
- Proper delegation ensures atomic updates

**Fix Strategy**:

**Phase 1: Update lean-research-agent step_6 to match researcher step_4_postflight** (1.5 hours)
1. Replace direct TODO.md updates with status-sync-manager delegation:
   - Remove lines 651-657 (direct TODO.md manipulation)
   - Add status-sync-manager invocation matching researcher.md line 335-348
   - Pass validated_artifacts array to status-sync-manager
2. Replace direct state.json updates with status-sync-manager delegation:
   - Remove lines 658-662 (direct state.json manipulation)
   - status-sync-manager handles both TODO.md and state.json atomically
3. Add git-workflow-manager delegation:
   - Add git-workflow-manager invocation matching researcher.md line 349-368
   - Pass scope_files including research report, TODO.md, state.json
4. Update step_6 documentation to reflect delegation pattern

**Phase 2: Remove summary artifact requirement** (30 minutes)
1. Remove summary artifact validation (line 647-649):
   - Remove "Verify summary artifact created" check
   - Remove "Verify summary artifact is <100 tokens" check
2. Remove summary artifact linking (line 657, 664, 686-688):
   - Remove summary from artifact links in TODO.md
   - Remove summary from state.json artifacts array
3. Update return format to list only research report (line 664)
4. Match researcher.md behavior (single artifact only)

**Phase 3: Test with Lean task** (1 hour)
1. Test `/research` on a Lean task (e.g., task 260)
2. Verify status updates to `[RESEARCHING]` at start
3. Verify status updates to `[RESEARCHED]` at end
4. Verify artifact link added to TODO.md (research report only, no summary)
5. Verify state.json updated with artifact path
6. Verify git commit created
7. Verify no regression in research quality

**Files to Modify**:
- `.opencode/agent/subagents/lean-research-agent.md` - Update step_6 to delegate to status-sync-manager and git-workflow-manager

**Acceptance Criteria**:
- [ ] lean-research-agent step_6 delegates to status-sync-manager (not direct file updates)
- [ ] lean-research-agent step_6 delegates to git-workflow-manager (not manual git commands)
- [ ] Summary artifact requirement removed (only research report created)
- [ ] `/research` on Lean tasks updates status to `[RESEARCHING]` at start
- [ ] `/research` on Lean tasks updates status to `[RESEARCHED]` at end
- [ ] Artifact link added to TODO.md (research report only)
- [ ] state.json updated with artifact path
- [ ] Git commit created automatically
- [ ] Behavior matches researcher.md exactly
- [ ] No regression in Lean research functionality

**Impact**: 
Fixes the root cause of status synchronization failures for Lean tasks. Ensures lean-research-agent uses the same atomic update pattern as researcher.md via status-sync-manager and git-workflow-manager delegation. Eliminates direct file manipulation that bypasses validation and atomic updates.

**Related Tasks**:
- Task 283: Fixed general subagents step naming (completed)
- Task 289: Fixed Lean subagents step naming (completed)
- Task 290: Identified this root cause through research

---

## Medium Priority

### 310. Enhance workflow commands with start and end status updates
- **Effort**: 9-12 hours
- **Status**: [COMPLETED]
- **Research**: [Research Report](.opencode/specs/310_enhance_workflow_commands_with_start_and_end_status_updates/reports/research-001.md)
- **Researched**: 2026-01-05
- **Plan**: [implementation-001.md](.opencode/specs/310_enhance_workflow_commands_with_start_and_end_status_updates/plans/implementation-001.md)
- **Planned**: 2026-01-05
- **Implementation**: [implementation-summary-20260105.md](.opencode/specs/310_enhance_workflow_commands_with_start_and_end_status_updates/summaries/implementation-summary-20260105.md)
- **Implemented**: 2026-01-05
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Enhance workflow commands (/research, /plan, /revise, /implement) to update task status at the beginning and end of execution. Commands should set status to '[RESEARCHING]', '[PLANNING]', '[REVISING]', or '[IMPLEMENTING]' at start, report if already in progress, and update to final status ('[RESEARCHED]', '[PLANNED]', '[REVISED]', '[IMPLEMENTED]'/'[BLOCKED]'/'[PARTIAL]') at completion.

---

### 305. Remove performance cruft from all 6 modified files (3/5)
- **Effort**: 30 minutes
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](305_remove_performance_cruft_from_all_6_modified_files_3_5/reports/research-001.md)
- **Researched**: 2026-01-05
- **Plan**: [implementation-001.md](305_remove_performance_cruft_from_all_6_modified_files_3_5/plans/implementation-001.md)
- **Planned**: 2026-01-05

**Description**: Remove optimization sections from frontmatter, performance blocks from workflow stages, and verbose comments from all 6 files (todo.md, review.md, reviewer.md, meta.md, task-creator.md, state-lookup.md). Keep state-lookup.md documentation changes.

**Research Summary**: Comprehensive analysis identified 3 types of cruft to remove: optimization sections in frontmatter (5 files), performance blocks in workflow stages (1 file), and verbose comments (4 files). state-lookup.md documentation changes should be preserved. Core logic changes in meta.md and task-creator.md require separate verification (task 307).

---

### 308. Final cleanup and comprehensive testing (5/5)
- **Effort**: 15 minutes
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: general
- **Blocking**: None
- **Dependencies**: None

**Description**: Complete final cleanup of any remaining cruft from files not reverted. Test all commands (/task, /meta, /todo, /review) comprehensively to ensure everything works correctly. Commit clean changes with proper documentation.

---

### 295. Create /sync command to synchronize TODO.md and state.json
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

---

### 294. Revise /meta command to accept optional task number
- **Effort**: 10 hours
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**: Revise the /meta command to accept an optional task number in the same way as the /research and /implement commands so that I can improve my workflow using the /meta command. The /meta command should still work if used with no arguments or a prompt only.

**Research Artifacts**:
  - Main Report: [.opencode/specs/294_revise_meta_command_to_accept_optional_task_number/reports/research-001.md]

**Plan Artifacts**:
  - Implementation Plan: [.opencode/specs/294_revise_meta_command_to_accept_optional_task_number/plans/implementation-001.md]


---

## High Priority

### 240. Systematically Investigate And Fix Persistent Workflow Command Stage 7 Postflight Failures
- **Effort**: 56.0
- **Status**: [RESEARCHED]
- **Priority**: Critical
- **Language**: markdown
- **Artifacts**:
  - .opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/reports/research-001.md

**Description**: Task 240

---

### 265. Clean Up Context Directory Structure By Migrating Common To Core And Removing Archive
- **Effort**: TBD
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: markdown
- **Artifacts**:
  - .opencode/specs/265_clean_up_context_directory_structure_by_migrating_common_to_core_and_removing_archive/reports/research-001.md
  - .opencode/specs/265_clean_up_context_directory_structure_by_migrating_common_to_core_and_removing_archive/plans/implementation-001.md

**Description**: Task 265

---

### 266. Fix Research Command Language Based Routing To Properly Invoke Lean Research Agent For Lean Tasks
- **Effort**: 6.0
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Artifacts**:
  - .opencode/specs/266_fix_research_command_language_based_routing_to_properly_invoke_lean_research_agent_for_lean_tasks/reports/research-001.md

**Description**: Task 266


---

### 271. Revise Meta Command Task Creation
- **Effort**: 13.0
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: markdown
- **Artifacts**:
  - .opencode/specs/271_revise_meta_command_task_creation/reports/research-001.md
  - .opencode/specs/271_revise_meta_command_task_creation/plans/implementation-001.md

**Description**: Task 271

---

### 277. Improve Opencode Header And Summary Display For Task Commands
- **Effort**: 3.5
- **Status**: [ABANDONED]
- **Priority**: High
- **Language**: general
- **Abandoned**: 2026-01-05
- **Abandonment Reason**: User requested abandonment
- **Artifacts**:
  - .opencode/specs/277_improve_opencode_header_and_summary_display_for_task_commands/reports/research-001.md
  - .opencode/specs/277_improve_opencode_header_and_summary_display_for_task_commands/plans/implementation-001.md
  - .opencode/specs/277_improve_opencode_header_and_summary_display_for_task_commands/plans/implementation-002.md

**Description**: Task 277

---

### 280. Fix Orchestrator Stage 4 Validation To Enforce Subagent Return Format And Prevent Phantom Research
- **Effort**: 6.0
- **Status**: [REVISED]
- **Priority**: High
- **Language**: markdown
- **Artifacts**:
  - .opencode/specs/280_fix_orchestrator_stage_4_validation/reports/research-001.md
  - .opencode/specs/280_fix_orchestrator_stage_4_validation/plans/implementation-001.md
  - .opencode/specs/280_fix_orchestrator_stage_4_validation/plans/implementation-002.md
- **Revised**: 2026-01-05

**Description**: Task 280

---

### 282. Add Json Return Format Enforcement To Subagent Invocation
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: general

**Description**: Task 282

---

### 290. Fix Lean Research Agent Preflight Status Updates And Artifact Linking
- **Effort**: 2.5
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: markdown
- **Artifacts**:
  - .opencode/specs/290_fix_lean_research_agent_preflight_status_updates_and_artifact_linking/reports/research-001.md
  - .opencode/specs/290_fix_lean_research_agent_preflight_status_updates_and_artifact_linking/plans/implementation-001.md

**Description**: Task 290

---

## Medium Priority

### 259. Automation Tactics
- **Effort**: 20.0
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: lean
- **Artifacts**:
  - .opencode/specs/259_automation_tactics/reports/research-001.md
  - .opencode/specs/259_automation_tactics/plans/implementation-001.md

**Description**: Task 259

---

### 311. Refactor /abandon command to support ranges and lists of task numbers
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Refactor the /abandon command to accept a range or list of task numbers (e.g., '293-295, 302, 303') to abandon multiple tasks in a single invocation. This enables efficient bulk abandonment of tasks without requiring multiple command executions.

---

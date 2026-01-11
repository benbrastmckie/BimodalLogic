---
last_updated: 2026-01-12T11:45:00Z
next_project_number: 392
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 25
  completed: 70
  in_progress: 2
  not_started: 15
  abandoned: 6
  total: 101
priority_distribution:
  critical: 0
  high: 8
  medium: 7
  low: 10
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

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

---

## Medium Priority

### 381. Add causal semantics infrastructure
- **Effort**: 2-3 hours
- **Status**: [IMPLEMENTING]
- **Started**: 2026-01-11
- **Researched**: 2026-01-11
- **Planned**: 2026-01-12
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/381_add_causal_semantics_infrastructure/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/381_add_causal_semantics_infrastructure/plans/implementation-001.md)

**Description**: Add infrastructure and comments for causal semantics in Logos theory. The causal operator was missing from RECURSIVE_SEMANTICS.md line 29 and has been fixed, but the Lean implementation needs appropriate stub definitions and TODO comments to enable future implementation of causation semantics.

---

### 382. Create Spatial/ subtheory stub
- **Effort**: 1-2 hours
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/382_create_spatial_subtheory_stub/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/382_create_spatial_subtheory_stub/plans/implementation-001.md)

**Description**: Create Logos/Spatial/ subtheory stub following the pattern of other extension layers. Task 377 implemented Core but did not create the Spatial extension layer. Create minimal stub structure with appropriate documentation.

---

### 178. Complete Bimodal advanced tutorial with exercises
- **Effort**: 10 hours
- **Status**: [PLANNED]
- **Started**: 2026-01-11
- **Planned**: 2026-01-11
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Plan**: [implementation-001.md](.claude/specs/178_complete_advanced_tutorial_sections_with_hands_on_exercises/plans/implementation-001.md)
- **Files Affected**:
  - Bimodal/Documentation/UserGuide/ADVANCED_TUTORIAL.md (new)
  - Bimodal/Documentation/UserGuide/EXERCISES.md (new)
  - Bimodal/Documentation/UserGuide/TROUBLESHOOTING.md (new)
- **Description**: Create advanced tutorial for Bimodal theory covering proof search automation, custom tactic development, and metalogic. Build on existing QUICKSTART.md and PROOF_PATTERNS.md with hands-on exercises and solutions. Include comprehensive troubleshooting guide.
- **Acceptance Criteria**:
  - [ ] Advanced tutorial section on Bimodal proof search tactics (modal_search, temporal_search)
  - [ ] Advanced tutorial section on Bimodal custom tactic development
  - [ ] Advanced tutorial section on metalogic (soundness, completeness framework)
  - [ ] Hands-on exercises with solutions covering modal, temporal, and bimodal proofs
  - [ ] Troubleshooting guide for common Bimodal errors
- **Impact**: Improves onboarding by providing comprehensive learning path from basics to advanced Bimodal topics with practical exercises.

---

### 296. Create /sync command to synchronize TODO.md and state.json
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Create a /sync command that bidirectionally synchronizes .claude/specs/TODO.md and .claude/specs/state.json, ensuring both files contain identical task information with the most recent changes from either file. The command should detect discrepancies between the two files, intelligently resolve conflicts by preferring the most recently updated data, and perform atomic updates to both files using the existing status-sync-manager's two-phase commit protocol. This addresses the architectural requirement that state.json is the authoritative source for metadata reads while TODO.md serves as the user-facing view, with synchronization ensuring consistency between them.

---

### 306. Refactor /meta command to create tasks instead of direct implementation
- **Effort**: 8 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Plan**: [implementation-003.md](.claude/specs/306_refactor_meta_command_to_create_tasks_instead_of_direct_implementation/plans/implementation-003.md)

**Description**: Refactor the /meta command to always create an appropriate number of tasks (similar to /task command) rather than directly implementing the work. Preserve the interview functionality to clarify requirements when needed, or run in full interactive mode when /meta is called with no arguments. The result should be task creation with dependencies indicated and plan artifacts stored in the appropriate artifact structure per artifact-management.md.

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
 **Status**: [ON HOLD]
 **Priority**: Low
 **Language**: lean
 **Blocking**: Decidability
 **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)
 **Note**: On hold pending Bimodal polish and documentation (Task 360)

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

### 132. Prove Lindenbaum maximal consistency lemma in Completeness.lean
- **Effort**: 3 hours
- **Status**: [ON HOLD]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Note**: On hold pending Bimodal polish (Task 360)
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
- **Status**: [ON HOLD]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132
- **Note**: On hold pending Bimodal polish (Task 360)
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
- **Status**: [ON HOLD]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 133
- **Note**: On hold pending Bimodal polish (Task 360)
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
- **Status**: [ON HOLD]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132, 133, 134
- **Note**: On hold pending Bimodal polish (Task 360)
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

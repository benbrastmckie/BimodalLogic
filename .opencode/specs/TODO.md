# TODO

**Last Updated:** 2026-01-03T18:45:00Z

---


## High Priority

### 271. Revise /meta command to create tasks with linked artifacts instead of implementing directly
- **Effort**: 8-12 hours
- **Status**: [RESEARCHED]
- **Completed**: 2026-01-03
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/meta` command currently implements work directly after the interview. Instead, it should conclude by creating an appropriate number of tasks in `.opencode/specs/TODO.md` following task standards, with each task linking to relevant research artifacts and a detailed plan artifact organized per artifact-management.md. The end goal is to create tasks with linked artifacts in appropriately numbered project directories for user review, NOT to implement the plans.

**Current Behavior**:
- `/meta` conducts interview (Stages 0-6)
- Stage 7 (GenerateSystem): Delegates to meta subagents to create agents, commands, context files
- Stage 8 (DeliverSystem): Presents completed system, creates git commit

**Expected Behavior**:
- `/meta` conducts interview (Stages 0-6)
- Stage 7 (CreateTasksWithArtifacts): 
  - Use `next_project_number` from state.json for task numbering
  - Create project directories in `.opencode/specs/NNN_*/` for each task
  - Generate research artifacts analyzing requirements
  - Generate detailed plan artifacts for each task
  - Create task entries in TODO.md linking to artifacts
  - Increment `next_project_number` for each task created
- Stage 8 (DeliverTaskSummary): Present task list with artifact links, instruct user to review and run `/implement NNN` for each task

**Tasks to Create** (examples based on interview):
1. Research task: Analyze domain requirements and identify core concepts
2. Planning task: Design agent architecture and workflow patterns
3. Implementation tasks (one per agent/command/context group):
   - Create domain-specific agents
   - Create custom commands
   - Create context files

**Artifact Structure** (per task):
```
.opencode/specs/NNN_task_name/
├── reports/
│   └── research-001.md          # Domain analysis, requirements
├── plans/
│   └── implementation-001.md    # Detailed implementation plan
└── summaries/
    ├── research-summary.md      # Brief research summary
    └── plan-summary.md          # Brief plan summary
```

**Files to Modify**:
- `.opencode/agent/subagents/meta.md` - Revise Stage 7 and Stage 8
- `.opencode/command/meta.md` - Update workflow description

**Acceptance Criteria**:
- [ ] `/meta` creates tasks in TODO.md using next_project_number from state.json
- [ ] Each task has a project directory in `.opencode/specs/NNN_*/`
- [ ] Each task links to research artifact and plan artifact
- [ ] Research artifacts analyze domain requirements per research standards
- [ ] Plan artifacts follow plan.md standard with phases and estimates
- [ ] Summary artifacts follow summary.md standard (<100 tokens)
- [ ] Task entries follow tasks.md standard (Language, Effort, Priority, Status fields)
- [ ] Task breakdown follows task-breakdown.md workflow
- [ ] state.json next_project_number incremented for each task
- [ ] NO implementation performed - only tasks and artifacts created
- [ ] User can review artifacts and run `/implement NNN` for each task

**Impact**: Enables user review of /meta output before implementation, following the research → plan → implement workflow used by other commands.

---

### 269. Fix /meta command to accept user prompts directly instead of forcing interactive interview
- **Effort**: 2-3 hours
- **Status**: [RESEARCHING]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/meta` command currently ignores user-provided prompts and always starts an interactive interview. This differs from the OpenAgents implementation where `/meta` accepts `$ARGUMENTS` directly via `<target_domain> $ARGUMENTS </target_domain>` pattern, allowing users to provide requirements upfront.

**Current Behavior**:
```bash
/meta "I want to revise my opencode system..."
# Ignores the prompt, shows generic interview message
```

**Expected Behavior** (from OpenAgents):
```bash
/meta "I want to revise my opencode system..."
# Uses the prompt as target_domain, proceeds with requirements
```

**Root Cause**:
- ProofChecker `/meta` command (`.opencode/command/meta.md`) does NOT pass `$ARGUMENTS` to the meta agent
- OpenAgents `/meta` command passes `$ARGUMENTS` via `<target_domain> $ARGUMENTS </target_domain>` in the agent file
- ProofChecker meta agent (`.opencode/agent/subagents/meta.md`) expects interactive interview, not prompt-based input

**Solution**:
1. Update `.opencode/command/meta.md` to pass `$ARGUMENTS` to meta agent (similar to OpenAgents pattern)
2. Update `.opencode/agent/subagents/meta.md` to:
   - Check if `$ARGUMENTS` is provided (non-empty)
   - If provided: Use as target_domain, skip Stage 1 (InitiateInterview), proceed directly to Stage 2 with domain context
   - If empty: Fall back to current interactive interview workflow
3. Add `<target_domain>` XML tag to meta agent to receive `$ARGUMENTS`
4. Update Stage 1 logic to be conditional based on `$ARGUMENTS` presence

**Files to Modify**:
- `.opencode/command/meta.md` - Add `$ARGUMENTS` passing
- `.opencode/agent/subagents/meta.md` - Add conditional workflow based on `$ARGUMENTS`

**Acceptance Criteria**:
- [ ] `/meta "prompt text"` uses the prompt directly without interactive interview
- [ ] `/meta` (no arguments) falls back to interactive interview
- [ ] Both modes create appropriate tasks in TODO.md with linked artifacts
- [ ] Both modes follow task-breakdown.md and artifact-management.md standards
- [ ] Both modes use next_project_number from state.json for task numbering
- [ ] Both modes create project directories in `.opencode/specs/NNN_*/`

**Impact**: Enables faster /meta usage for users who know their requirements, while preserving interactive mode for exploratory use.

---


### 267. Integrate context/meta/ into context/core/ with proper subdirectory organization
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-03
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
Integrate `.opencode/context/meta/` into `.opencode/context/core/` by distributing the 4 meta context files to appropriate subdirectories in `core/` to maintain organization. Update all references throughout the `.opencode/` system to prevent feature regressions.

**Current State**:
- `.opencode/context/meta/` contains 4 files:
  - `interview-patterns.md` (5171 bytes)
  - `architecture-principles.md` (6641 bytes)
  - `domain-patterns.md` (5781 bytes)
  - `agent-templates.md` (7254 bytes)

**Target Organization**:
All context files should belong to either:
- `context/core/` - General context files applicable across projects
- `context/project/` - Repository-specific context files

**Tasks**:
1. Analyze each meta context file to determine appropriate core/ subdirectory:
   - `interview-patterns.md` → likely `core/processes/` or `core/workflows/`
   - `architecture-principles.md` → likely `core/standards/` or `core/patterns/`
   - `domain-patterns.md` → likely `core/patterns/` or `core/templates/`
   - `agent-templates.md` → likely `core/templates/` or `core/standards/`
2. Move files to appropriate core/ subdirectories
3. Update all references in:
   - `.opencode/command/meta.md` (frontmatter context_loading)
   - `.opencode/agent/subagents/meta/*.md` (5 agents)
   - `.opencode/context/index.md` (meta/ section)
   - `.opencode/README.md` (Meta Command Guide)
   - Any other files referencing context/meta/
4. Remove empty `.opencode/context/meta/` directory
5. Validate no broken references (grep validation)
6. Test /meta command still works correctly

**Acceptance Criteria**:
- [x] All 4 meta context files moved to appropriate core/ subdirectories
- [x] No `.opencode/context/meta/` directory exists
- [x] All references updated (command files, agent files, context index, README)
- [x] No broken references (validated with grep)
- [x] /meta command still functions correctly
- [x] Context organization follows core/ vs project/ convention

**Implementation Summary**:
- Moved `interview-patterns.md` → `core/workflows/interview-patterns.md`
- Moved `architecture-principles.md` → `core/standards/architecture-principles.md`
- Moved `domain-patterns.md` → `core/standards/domain-patterns.md`
- Moved `agent-templates.md` → `core/templates/agent-templates.md`
- Updated references in: `.opencode/command/meta.md`, `.opencode/agent/subagents/meta.md`, `.opencode/context/index.md`, `.opencode/README.md`
- Updated cross-references in all 4 moved files
- Removed empty `.opencode/context/meta/` directory
- Git commit: 33d4d45

---



### 257. Completeness Proofs
- **Effort**: 70-90 hours
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: Decidability
- **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)

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

### 258. Resolve Truth.lean Sorries
- **Effort**: 10-20 hours
- **Status**: [RESEARCHED]
- **Started**: 2026-01-03
- **Completed**: 2026-01-03
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: .opencode/specs/258_resolve_truth_lean_sorries/reports/research-001.md
  - Summary: .opencode/specs/258_resolve_truth_lean_sorries/summaries/research-summary.md

**Description**: Resolve the 3 remaining `sorry` placeholders in `Logos/Core/Semantics/Truth.lean` related to temporal swap validity. These require handling domain extension for history quantification.

**Research Findings**: The 3 sorries mentioned in the task description (lines 697, 776, 798) were already resolved in Task 213 (commit 1cf688b, 2025-12-28). Current Truth.lean has 580 lines with zero sorries. The unprovable `is_valid_swap_involution` theorem and `truth_swap_of_valid_at_triple` function were removed after semantic analysis proved them false. Task 258 is ALREADY RESOLVED.

**Action Items**:
1. ~~Resolve `truth_swap_of_valid_at_triple` (implication case)~~ - Already resolved in Task 213
2. ~~Resolve `truth_swap_of_valid_at_triple` (past case - domain extension)~~ - Already resolved in Task 213
3. ~~Resolve `truth_swap_of_valid_at_triple` (future case - domain extension)~~ - Already resolved in Task 213

**Files**:
- `Logos/Core/Semantics/Truth.lean` (current: 580 lines, 0 sorries)

**Acceptance Criteria**:
- [x] Implication case resolved (removed in Task 213)
- [x] Past case with domain extension resolved (removed in Task 213)
- [x] Future case with domain extension resolved (removed in Task 213)
- [x] All tests pass (Truth.lean builds successfully)
- [x] SORRY_REGISTRY.md updated (shows 0 sorries in Truth.lean)

**Impact**: Task objectives already achieved through Task 213. Truth.lean is clean, well-documented, and builds successfully.

**Recommendation**: Mark task as ALREADY RESOLVED or OBSOLETE. See Task 213 for resolution details.

---

### 259. Automation Tactics
- **Effort**: 40-60 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement the remaining planned tactics for TM logic to support easier proof construction. Currently 4/12 tactics are implemented.

**Action Items**:
1. Implement `modal_k_tactic`, `temporal_k_tactic`.
2. Implement `modal_4_tactic`, `modal_b_tactic`.
3. Implement `temp_4_tactic`, `temp_a_tactic`.
4. Implement `modal_search`, `temporal_search`.
5. Fix Aesop integration (blocked by Batteries dependency).

**Files**:
- `Logos/Core/Automation/Tactics.lean`

**Acceptance Criteria**:
- [ ] All 8 remaining tactics implemented
- [ ] Aesop integration fixed
- [ ] Tests added for new tactics
- [ ] TACTIC_REGISTRY.md updated
- [ ] Documentation updated

**Impact**: Significantly improves proof automation capabilities for TM logic, making proof construction easier and more efficient.

---

### 260. Proof Search
- **Effort**: 40-60 hours
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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

### 270. Fix /research command to conduct research instead of implementing tasks
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Started**: 2026-01-03
- **Completed**: 2026-01-03
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/research` command is incorrectly executing full task implementation instead of conducting research and creating research artifacts. When `/research 267` was run, it violated the status transition rules defined in `.opencode/context/core/system/state-management.md` by changing the task status to [COMPLETED] instead of [RESEARCHED], and implemented the task directly instead of creating research artifacts.

**Expected Behavior** (per state-management.md):
1. Status transition: `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`
2. Create research artifacts in `.opencode/specs/267_*/reports/research-001.md`
3. Link research artifacts in TODO.md and state.json using status-sync-manager
4. Follow artifact-management.md standards (lazy directory creation)
5. Create git commit for research artifacts only

**Actual Behavior** (INCORRECT):
1. Status transition: `[NOT STARTED]` → `[COMPLETED]` (invalid transition)
2. Implemented task directly (moved files, updated references)
3. No research artifacts created
4. Violated command-specific status marker rules

**Root Cause**:
The researcher subagent (`.opencode/agent/subagents/researcher.md`) is executing implementation workflows instead of research-only workflows. It needs to be constrained to:
- Research execution only (web search, documentation review, analysis)
- Research report creation (NOT implementation)
- Status updates via status-sync-manager: `[RESEARCHING]` → `[RESEARCHED]`
- Artifact validation per artifact-management.md

**Action Items**:
1. Audit researcher.md workflow to identify implementation logic
2. Remove implementation execution from researcher.md
3. Ensure researcher.md creates research artifacts only
4. Validate status transitions follow state-management.md:
   - Valid transition: `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`
   - Invalid transition: `[NOT STARTED]` → `[COMPLETED]` (skip research phase)
5. Validate artifact creation follows artifact-management.md:
   - Lazy directory creation (`.opencode/specs/{number}_{slug}/`)
   - Research report in `reports/research-001.md`
   - Artifact links in TODO.md and state.json via status-sync-manager
6. Test /research command with markdown task (like 267)
7. Test /research command with lean task (language-based routing)
8. Verify no implementation occurs during research
9. Update documentation if needed

**Acceptance Criteria**:
- [ ] /research command creates research artifacts only (no implementation)
- [ ] Research artifacts follow artifact-management.md standards
- [ ] Status transitions follow state-management.md: `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`
- [ ] Artifact links added to TODO.md and state.json via status-sync-manager
- [ ] No implementation occurs during /research
- [ ] Language-based routing works correctly (lean vs general)
- [ ] Lazy directory creation followed
- [ ] Git commits created for research artifacts only
- [ ] Atomic status updates via status-sync-manager (two-phase commit)

**Files Affected**:
- `.opencode/agent/subagents/researcher.md` (remove implementation logic)
- `.opencode/command/research.md` (validate workflow documentation)
- `.opencode/context/core/system/state-management.md` (reference standard)

**Impact**: Fixes critical workflow bug where /research implements tasks instead of researching them, preventing proper research/plan/implement workflow separation and violating status transition rules.

**References**:
- State Management Standard: `.opencode/context/core/system/state-management.md`
- Artifact Management: `.opencode/context/core/system/artifact-management.md`
- Status Sync Manager: `.opencode/agent/subagents/status-sync-manager.md`

---

### 263. Refactor Context.lean
- **Effort**: 2-4 hours
- **Status**: [RESEARCHING]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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
- **Status**: [IN PROGRESS]
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
- **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
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


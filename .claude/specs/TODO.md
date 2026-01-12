---
last_updated: 2026-01-12T09:00:00Z
next_project_number: 426
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 23
  completed: 91
  in_progress: 0
  not_started: 17
  abandoned: 7
  total: 121
priority_distribution:
  critical: 0
  high: 5
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

### 425. Update command files to delegate to skill/subagent system
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Dependencies**: 409, 410, 411, 412, 413, 414
- **Research**: [research-001.md](.claude/specs/425_update_command_files_to_delegate_to_skill_subagent/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/425_update_command_files_to_delegate_to_skill_subagent/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/425_update_command_files_to_delegate_to_skill_subagent/summaries/implementation-summary-20260112.md)
- **Completed**: 2026-01-12

**Description**: Update `.claude/commands/research.md`, `.claude/commands/plan.md`, and `.claude/commands/implement.md` to delegate to the skill/subagent system instead of executing inline. Commands should look up task language, then invoke the appropriate skill (e.g., `skill-lean-research` or `skill-researcher`) via the Skill tool, which will spawn subagents via Task tool. This completes the forked subagent pattern by connecting the entry points (commands) to the infrastructure (skills → agents).

---

### 423. CI skip by default, trigger via commit message
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta

**Description**: Change CI workflow to skip by default and only run when triggered by a special marker in commit messages (e.g., `[ci]` or `[run-ci]`). Create a git skill and subagent to handle all git commits, which can intelligently decide when to include the CI trigger marker. Add context documentation in `.claude/context/` explaining the git workflow and CI triggering convention. This enables frequent pushes without triggering CI, while still allowing explicit CI runs when warranted and likely to succeed.

---

### 409. Convert workflow skills to forked subagent pattern
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta

**Description**: Update skill-lean-research, skill-researcher, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation to use `context: fork` and `agent:` field in frontmatter. Convert skills to thin wrappers that spawn subagents for token-heavy work. Define standardized return format for artifacts (status, artifact_path, summary).

---

### 410. Remove eager context loading from skill frontmatter
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Dependencies**: 409

**Description**: Remove `context:` arrays from all skill frontmatter files. Document lazy loading pattern using @-references. Ensure context/index.md is referenced for on-demand lookup. Update CLAUDE.md if needed. This enables skills to load context only when subagents actually need it.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [EXPANDED]
- **Researched**: 2026-01-12
- **Priority**: High
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](.claude/specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](.claude/specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](.claude/specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

## Medium Priority

### 424. Complete the TODOs in 01-Syntax.tex
- **Effort**: 30 minutes
- **Status**: [COMPLETED]
- **Completed**: 2026-01-11
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/424_complete_todos_01_syntax_tex/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/424_complete_todos_01_syntax_tex/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260111.md](.claude/specs/424_complete_todos_01_syntax_tex/summaries/implementation-summary-20260111.md)

**Description**: Complete the TODOs in /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/01-Syntax.tex

---

### 411. Create lean-research-agent subagent with lazy context
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Dependencies**: 410

**Description**: Create `.claude/agents/lean-research-agent.md` subagent with lean-lsp MCP tools and search decision tree. Loads mcp-tools-guide.md, leansearch-api.md, loogle-api.md only when needed via @-references. Returns structured JSON with artifact path and summary. Integrates with skill-lean-research via the forked subagent pattern.

---

### 412. Create general-research-agent subagent with lazy context
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Dependencies**: 410

**Description**: Create `.claude/agents/general-research-agent.md` subagent with WebSearch, WebFetch, Read, Grep tools. Loads report-format.md on-demand. Returns structured JSON with artifact path and summary. Integrates with skill-researcher via the forked subagent pattern.

---

### 413. Create implementation-agent subagents (lean/general/latex)
- **Effort**: 4-5 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Dependencies**: 410

**Description**: Create `.claude/agents/lean-implementation-agent.md`, `general-implementation-agent.md`, and `latex-implementation-agent.md` subagents. Each loads language-specific context only when executing phases. Returns phase completion status and artifact paths. Integrates with respective implementation skills via forked subagent pattern.

---

### 400. Investigate Explanatory/Truth.lean build performance
- **Effort**: 2-3 hours
- **Status**: [EXPANDED]
- **Researched**: 2026-01-11
- **Priority**: Medium
- **Language**: lean
- **Subtasks**: 417, 418, 419 (416, 420 completed)
- **Research**: [research-001.md](.claude/specs/400_investigate_explanatory_truth_build_performance/reports/research-001.md)

**Description**: Investigate why building Explanatory/Truth.lean is so computationally demanding and identify ways to build faster or more efficiently.

---

### 417. Split typeclass constraints in Explanatory
- **Effort**: 3-4 hours
- **Status**: [PLANNED]
- **Researched**: 2026-01-11
- **Planned**: 2026-01-11
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 400
- **Dependencies**: 416
- **Research**: [research-001.md](.claude/specs/417_split_typeclass_constraints_explanatory/reports/research-001.md), [research-002.md](.claude/specs/417_split_typeclass_constraints_explanatory/reports/research-002.md)
- **Plan**: [implementation-001.md](.claude/specs/417_split_typeclass_constraints_explanatory/plans/implementation-001.md)

**Description**: Split LinearOrderedAddCommGroup constraint into more specific constraints (AddGroup, LinearOrder, CovariantClass) to reduce typeclass instance search complexity. Requires understanding type dependencies and may affect multiple files.

**Note**: Task 420 (Mathlib upgrade) already implemented unbundling using `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]` instead of the originally recommended `CovariantClass` approach. This plan creates a benchmarked comparison by reverting to the bundled approach to empirically validate the performance benefit.

---

### 418. Cache typeclass instances in Explanatory
- **Effort**: 1.5-2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-11
- **Completed**: 2026-01-11
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 400
- **Dependencies**: 416
- **Research**: [research-001.md](.claude/specs/418_cache_typeclass_instances_explanatory/reports/research-001.md), [research-002.md](.claude/specs/418_cache_typeclass_instances_explanatory/reports/research-002.md)
- **Plan**: [implementation-001.md](.claude/specs/418_cache_typeclass_instances_explanatory/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260111.md](.claude/specs/418_cache_typeclass_instances_explanatory/summaries/implementation-summary-20260111.md)

**Description**: Add explicit instance arguments where typeclass inference is slow. Cache CompleteLattice and other deep hierarchy instances to avoid repeated inference in truthAt and related functions.

**Note**: Task 420 already addressed `LinearOrderedAddCommGroup T` unbundling. Task 418 now focuses exclusively on `CompleteLattice State` caching, which is orthogonal (different type hierarchy).

---

### 419. Refactor mutual recursion in Foundation/Semantics.lean
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 400
- **Dependencies**: 416
- **Research**: [research-001.md](.claude/specs/419_refactor_mutual_recursion_semantics/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/419_refactor_mutual_recursion_semantics/plans/implementation-001.md)

**Description**: Refactor the mutual recursion between verifies/falsifies in Foundation/Semantics.lean. Replace the `mutual` block with a single `eval` function parameterized by a `Polarity` type, enabling cleaner structural recursion and reducing well-founded recursion elaboration overhead.

---

### 395. Create Bimodal troubleshooting guide and exercise solutions
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: markdown
- **Supersedes**: Task 178
- **Research**: [research-001.md](.claude/specs/395_create_bimodal_troubleshooting_and_exercise_solutions/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/395_create_bimodal_troubleshooting_and_exercise_solutions/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/395_create_bimodal_troubleshooting_and_exercise_solutions/summaries/implementation-summary-20260112.md)

**Description**: Create TROUBLESHOOTING.md for Bimodal with import errors, type mismatches, proof search failures, and build issues. Add solutions with hints to existing exercises in EXAMPLES.md section 7.

**Files Created/Modified**:
  - Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md (new - 20 error patterns)
  - Theories/Bimodal/docs/user-guide/EXAMPLES.md (9 exercises with hints and solutions)
  - Theories/Bimodal/docs/user-guide/README.md (navigation updated)
  - Theories/Bimodal/docs/user-guide/QUICKSTART.md (navigation updated)
  - Theories/Bimodal/README.md (documentation table updated)

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

### 414. Create planner-agent subagent with lazy context
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: Low
- **Language**: meta
- **Dependencies**: 410

**Description**: Create `.claude/agents/planner-agent.md` subagent that loads plan-format.md and task-breakdown.md on-demand. Returns structured JSON with plan path and summary. Integrates with skill-planner via `context: fork` pattern.

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

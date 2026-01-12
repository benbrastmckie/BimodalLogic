---
last_updated: 2026-01-12T00:43:19Z
next_project_number: 423
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 30
  completed: 84
  in_progress: 1
  not_started: 17
  abandoned: 7
  total: 114
priority_distribution:
  critical: 0
  high: 6
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

### 409. Convert workflow skills to forked subagent pattern
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta

**Description**: Update skill-lean-research, skill-researcher, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation to use `context: fork` and `agent:` field in frontmatter. Convert skills to thin wrappers that spawn subagents for token-heavy work. Define standardized return format for artifacts (status, artifact_path, summary).

---

### 410. Remove eager context loading from skill frontmatter
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
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
  - docs/development/CI_CD_PROCESS.md (new)
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

## Medium Priority

### 422. Complete TODOs in Introduction.tex
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/422_complete_introduction_todos/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/422_complete_introduction_todos/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/422_complete_introduction_todos/summaries/implementation-summary-20260112.md)

**Description**: Restructured Introduction.tex by merging Implementation Status and Source Code into a single Project Structure subsection with brief explanations and status for each directory. Added Deduction Theorem status.

---

### 421. Look up formal term definitions and revise research report
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Related Task**: 398
- **Research**: [research-001.md](.claude/specs/421_lookup_formal_term_definitions_revise_research/reports/research-001.md)

**Description**: Extracted 30+ formal definitions from sn-article.tex and revised task 398 research-001.md with a "Formal Definitions" section ensuring all terms are defined before use.

---

### 411. Create lean-research-agent subagent with lazy context
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Dependencies**: 410

**Description**: Create `.claude/agents/lean-research-agent.md` subagent with lean-lsp MCP tools and search decision tree. Loads mcp-tools-guide.md, leansearch-api.md, loogle-api.md only when needed via @-references. Returns structured JSON with artifact path and summary. Integrates with skill-lean-research via the forked subagent pattern.

---

### 412. Create general-research-agent subagent with lazy context
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Dependencies**: 410

**Description**: Create `.claude/agents/general-research-agent.md` subagent with WebSearch, WebFetch, Read, Grep tools. Loads report-format.md on-demand. Returns structured JSON with artifact path and summary. Integrates with skill-researcher via the forked subagent pattern.

---

### 413. Create implementation-agent subagents (lean/general/latex)
- **Effort**: 4-5 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Dependencies**: 410

**Description**: Create `.claude/agents/lean-implementation-agent.md`, `general-implementation-agent.md`, and `latex-implementation-agent.md` subagents. Each loads language-specific context only when executing phases. Returns phase completion status and artifact paths. Integrates with respective implementation skills via forked subagent pattern.

---

### 415. Fix LaTeX sentence line breaks
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: latex
- **Dependencies**: 405, 406
- **Research**: [research-001.md](.claude/specs/415_fix_latex_sentence_line_breaks/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/415_fix_latex_sentence_line_breaks/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/415_fix_latex_sentence_line_breaks/summaries/implementation-summary-20260112.md)

**Description**: Fixed 22 broken sentences across 11 LaTeX files where sentences were incorrectly split at comma/clause boundaries.

---

### 408. Define \proofchecker LaTeX command
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: latex
- **Plan**: [implementation-001.md](.claude/specs/408_define_proofchecker_latex_command/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/408_define_proofchecker_latex_command/summaries/implementation-summary-20260112.md)

**Description**: Defined `\proofchecker` command in notation-standards.sty and replaced all occurrences in LaTeX documents (2 files updated).

---

### 400. Investigate Explanatory/Truth.lean build performance
- **Effort**: 2-3 hours
- **Status**: [EXPANDED]
- **Researched**: 2026-01-11
- **Priority**: Medium
- **Language**: lean
- **Subtasks**: 416, 417, 418, 419, 420
- **Research**: [research-001.md](.claude/specs/400_investigate_explanatory_truth_build_performance/reports/research-001.md)

**Description**: Investigate why building Explanatory/Truth.lean is so computationally demanding and identify ways to build faster or more efficiently.

---

### 416. Quick performance fixes for Explanatory/Truth.lean
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-11
- **Planned**: 2026-01-11
- **Completed**: 2026-01-11
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 400
- **Research**: [research-001.md](.claude/specs/416_quick_performance_fixes_explanatory_truth/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/416_quick_performance_fixes_explanatory_truth/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260111.md](.claude/specs/416_quick_performance_fixes_explanatory_truth/summaries/implementation-summary-20260111.md)

**Description**: Apply quick performance fixes: fix namespace error in Syntax.lean:34, add @[irreducible] to truthAt, increase synthInstance.maxHeartbeats, and run lake clean. These are low-risk changes that can be applied together.

---

### 417. Split typeclass constraints in Explanatory
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-11
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 400
- **Dependencies**: 416
- **Research**: [research-001.md](.claude/specs/417_split_typeclass_constraints_explanatory/reports/research-001.md)

**Description**: Split LinearOrderedAddCommGroup constraint into more specific constraints (AddGroup, LinearOrder, CovariantClass) to reduce typeclass instance search complexity. Requires understanding type dependencies and may affect multiple files.

---

### 418. Cache typeclass instances in Explanatory
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 400
- **Dependencies**: 416
- **Research**: [research-001.md](.claude/specs/418_cache_typeclass_instances_explanatory/reports/research-001.md)

**Description**: Add explicit instance arguments where typeclass inference is slow. Cache CompleteLattice and other deep hierarchy instances to avoid repeated inference in truthAt and related functions.

---

### 419. Refactor mutual recursion in Foundation/Semantics.lean
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 400
- **Dependencies**: 416

**Description**: Refactor the mutual recursion between verifies/falsifies in Foundation/Semantics.lean. Consider using a single function with a Bool flag for verify/falsify mode, or an indexed inductive family to avoid expensive well-founded recursion elaboration.

---

### 420. Upgrade Mathlib version
- **Effort**: 4-8 hours
- **Status**: [PLANNED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 400
- **Dependencies**: 416
- **Research**: [.claude/specs/420_upgrade_mathlib_version/reports/research-001.md]
- **Plan**: [.claude/specs/420_upgrade_mathlib_version/plans/implementation-001.md]

**Description**: Upgrade Mathlib from v4.14.0 to a newer version (4.22+) that includes significant compiler and instance caching improvements. Requires testing for breaking changes and API migrations.

---

### 395. Create Bimodal troubleshooting guide and exercise solutions
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Supersedes**: Task 178

**Description**: Create TROUBLESHOOTING.md for Bimodal with import errors, type mismatches, proof search failures, and build issues. Add solutions with hints to existing exercises in EXAMPLES.md section 7.

**Files Affected**:
  - Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md (new)
  - Theories/Bimodal/docs/user-guide/EXAMPLES.md (modify section 7)

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
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: meta
- **Dependencies**: 410

**Description**: Create `.claude/agents/planner-agent.md` subagent that loads plan-format.md and task-breakdown.md on-demand. Returns structured JSON with plan path and summary. Integrates with skill-planner via `context: fork` pattern.

---

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

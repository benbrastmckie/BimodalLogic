---
last_updated: 2026-01-12T12:00:00Z
next_project_number: 401
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

### 396. Fix LaTeX build missing style files
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-11
- **Planned**: 2026-01-11
- **Started**: 2026-01-11
- **Completed**: 2026-01-11
- **Priority**: High
- **Language**: latex
- **Blocking**: None
- **Dependencies**: None
- **Research**: [research-001.md](.claude/specs/396_fix_latex_build_missing_style_files/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/396_fix_latex_build_missing_style_files/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260111.md](.claude/specs/396_fix_latex_build_missing_style_files/summaries/implementation-summary-20260111.md)

**Description**: Fix LaTeX build errors in Theories/Logos/LaTeX/LogosReference.tex and Theories/Bimodal/LaTeX/BimodalReference.tex caused by missing style files:
- `logos-notation.sty` not found (Logos)
- `../../latex/notation-standards.sty` not found (Bimodal)
- `assets/bimodal-notation.sty` not found (Bimodal)

Troubleshoot and provide an elegant, high-quality solution for style file paths.

---

### 392. Enhance /todo command orphan tracking
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-11
- **Started**: 2026-01-11
- **Completed**: 2026-01-11
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None
- **Research**: [research-001.md](.claude/specs/392_enhance_todo_command_orphan_tracking/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/392_enhance_todo_command_orphan_tracking/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260111.md](.claude/specs/392_enhance_todo_command_orphan_tracking/summaries/implementation-summary-20260111.md)

**Description**: Enhance /todo command to track orphaned directories in archive/state.json. Currently, orphaned directories (project directories not tracked in any state file) are moved to archive/ but NOT added to archive/state.json. This task modifies:
1. Step 2.5 detection to check both state.json AND archive/state.json (with flattened queries)
2. Step 5.E to add orphan entries to archive/state.json when archiving (not just move directories)

This ensures all project directories in specs/archive/ are accounted for by state files.

---

### 393. Remove incorrect causal operator definition
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Started**: 2026-01-12
- **Completed**: 2026-01-12
- **Priority**: High
- **Language**: lean
- **Parent**: Task 381
- **Research**: [research-001.md](.claude/specs/393_remove_incorrect_causal_operator_definition/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/393_remove_incorrect_causal_operator_definition/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/393_remove_incorrect_causal_operator_definition/summaries/implementation-summary-20260112.md)

**Description**: Remove the incorrect definition of the causal operator (which was defined in terms of the counterfactual conditional) and leave behind a stub or comment for systematic future implementation of the correct semantics.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
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
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Add closeness ordering, evolutions, subevolutions, causal context with background assumptions, and the three-condition truth clause for causation.

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
  - docs/Development/CI_CD_PROCESS.md (new)
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

### 400. Investigate Explanatory/Truth.lean build performance
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean

**Description**: Investigate why building Explanatory/Truth.lean is so computationally demanding and identify ways to build faster or more efficiently.

---

### 397. Enhance /revise to update description when no plan exists
- **Effort**: 1-2 hours
- **Status**: [PLANNED]
- **Researched**: 2026-01-11
- **Planned**: 2026-01-11
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None
- **Research**: [research-001.md](.claude/specs/397_enhance_revise_to_update_description_when_no_plan_exists/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/397_enhance_revise_to_update_description_when_no_plan_exists/plans/implementation-001.md)

**Description**: Modify the /revise command to handle tasks without plans by updating the task description instead of erroring. When a task has status `not_started` or `researched` (no plan), and the user provides a revision reason, update the task description in both state.json and TODO.md, then git commit the change.

---

### 381. Add causal semantics infrastructure
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Started**: 2026-01-11
- **Researched**: 2026-01-11
- **Planned**: 2026-01-12
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/381_add_causal_semantics_infrastructure/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/381_add_causal_semantics_infrastructure/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/381_add_causal_semantics_infrastructure/summaries/implementation-summary-20260112.md)
- **Subtasks**: 393, 394

**Description**: Add infrastructure and comments for causal semantics in Logos theory. The causal operator was missing from RECURSIVE_SEMANTICS.md line 29 and has been fixed, but the Lean implementation needs appropriate stub definitions and TODO comments to enable future implementation of causation semantics.

---

### 382. Create Spatial/ subtheory stub
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/382_create_spatial_subtheory_stub/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/382_create_spatial_subtheory_stub/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/382_create_spatial_subtheory_stub/summaries/implementation-summary-20260112.md)

**Description**: Create Logos/Spatial/ subtheory stub following the pattern of other extension layers. Task 377 implemented Core but did not create the Spatial extension layer. Create minimal stub structure with appropriate documentation.

---

### 178. Complete Bimodal advanced tutorial with exercises
- **Effort**: 10 hours
- **Status**: [ABANDONED]
- **Abandoned**: 2026-01-12
- **Priority**: Medium
- **Language**: markdown
- **Research**: [research-001.md](.claude/specs/178_complete_advanced_tutorial_sections_with_hands_on_exercises/reports/research-001.md)
- **Superseded by**: Task 395

**Abandonment Reason**: Superseded by existing documentation. Research found ~80% of planned content already exists in TUTORIAL.md (433 lines), TACTIC_DEVELOPMENT.md (787 lines), EXAMPLES.md (587 lines), and ARCHITECTURE.md (1403 lines). Remaining gaps (TROUBLESHOOTING.md, exercise solutions) captured in new targeted Task 395.

---

### 395. Create Bimodal troubleshooting guide and exercise solutions
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Supersedes**: Task 178

**Description**: Create TROUBLESHOOTING.md for Bimodal with import errors, type mismatches, proof search failures, and build issues. Add solutions with hints to existing exercises in EXAMPLES.md section 7.

**Files Affected**:
  - Theories/Bimodal/docs/UserGuide/TROUBLESHOOTING.md (new)
  - Theories/Bimodal/docs/UserGuide/EXAMPLES.md (modify section 7)

---

### 391. Enforce directory naming convention for Lean projects
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Plan**: [implementation-001.md](.claude/specs/391_enforce_directory_naming_convention/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/391_enforce_directory_naming_convention/summaries/implementation-summary-20260112.md)

**Description**: Enforce the directory naming convention that only directories containing Lean source code should be capitalized (e.g., `Logos/`, `Theories/`), while all other directories use lowercase (e.g., `docs/`, `scripts/`, `benchmarks/`). This includes: (1) Rename `Documentation/` to `docs/`, (2) Rename `LaTeX/` to `latex/`, (3) Document this standard in CONTRIBUTING.md and README.md.

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

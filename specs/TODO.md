---
next_project_number: 567
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 23
  completed: 170
  in_progress: 0
  not_started: 25
  abandoned: 14
  total: 201
priority_distribution:
  critical: 0
  high: 8
  medium: 8
  low: 11
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 566. Complete Semantic Embedding for Completeness Proof
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Session ID**: sess_1768701303_2bdd23
- **Priority**: High
- **Language**: lean
- **Parent**: 560
- **Researched**: 2026-01-18
- **Planned**: 2026-01-18
- **Research**: [research-001.md](specs/566_complete_semantic_embedding_for_completeness_proof/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/566_complete_semantic_embedding_for_completeness_proof/plans/implementation-001.md)

**Description**: Complete semantic embedding for completeness proof as per specs/560_axiom_elimination/summaries/implementation-summary-20260117.md to avoid all technical debt.

---

### 565. Investigate Workflow Interruption Issue
- **Effort**: 2-3 hours
- **Status**: [PLANNING]
- **Priority**: High
- **Language**: meta
- **Session ID**: sess_1768701291_ec7db1
- **Created**: 2026-01-17
- **Researched**: 2026-01-18
- **Research**: [research-001.md](specs/565_investigate_workflow_interruption_issue/reports/research-001.md)
- **Research**: [research-002.md](specs/565_investigate_workflow_interruption_issue/reports/research-002.md)

**Description**: Investigate and fix the workflow interruption issue where commands require explicit 'continue' input to proceed. The agent system in .claude/ should be studied carefully by examining output files in .claude/output/ and reviewing completed/archived tasks to identify the root cause of this recurring issue.

---

## Medium Priority

### 556. Complete Metalogic_v2 Implementation
- **Effort**: 6-10 hours
- **Status**: [EXPANDED]
- **Priority**: High
- **Language**: lean
- **Session ID**: sess_1768682818_dff425
- **Created**: 2026-01-17
- **Researched**: 2026-01-17
- **Planned**: 2026-01-17
- **Dependencies**: 554
- **Research**: [research-001.md](specs/556_complete_metalogic_v2_implementation/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/556_complete_metalogic_v2_implementation/plans/implementation-001.md)
- **Subtasks**: 557, 558, 559, 560, 561

**Description**: Complete all aspects of the implementation of the reorganized /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/ directory, completing all sorries and making this directory stand on its own so that I can delete Metalogic/ once Metalogic_v2/ is complete. Begin by improving /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/README.md to accurately report the current state and what the target organization is.

---

### 560. Axiom Elimination
- **Effort**: 1-2 hours
- **Status**: [PARTIAL]
- **Priority**: High
- **Language**: lean
- **Created**: 2026-01-17
- **Researched**: 2026-01-17
- **Parent**: 556
- **Dependencies**: 558
- **Research**: [research-001.md](specs/560_axiom_elimination/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/560_axiom_elimination/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260117.md](specs/560_axiom_elimination/summaries/implementation-summary-20260117.md)

**Description**: Replace representation_theorem_backward_empty axiom with a proven theorem in Representation/ContextProvability.lean. Uses completeness contrapositive argument.

**Partial Completion Note**: Syntactic half proven (`not_derivable_implies_neg_consistent`). Axiom retained with documentation due to semantic embedding gap complexity. See summary for details.

---

### 561. Cleanup and Documentation
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-17
- **Parent**: 556
- **Dependencies**: 560

**Description**: Prove consistent_iff_consistent in Basic.lean and necessitation_lemma in TruthLemma.lean. Update README.md with accurate completion status. Verify zero sorries in Metalogic_v2.

---

### 513. Address tm_auto proof reconstruction issues
- **Effort**: 5 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Session ID**: sess_1768700237_c3d7bc
- **Created By**: Review task 506
- **Review Artifact**: [specs/506_codebase_review/summaries/review-summary.md](specs/506_codebase_review/summaries/review-summary.md)
- **Research**: [Research Report](specs/513_address_tm_auto_proof_reconstruction_issues/reports/research-001.md)
- **Researched**: 2026-01-16T19:55:00Z
- **Planned**: 2026-01-18
- **Plan**: [implementation-001.md](specs/513_address_tm_auto_proof_reconstruction_issues/plans/implementation-001.md)

**Description**: Address tm_auto proof reconstruction issues. Tactic implementation exists but has proof reconstruction problems.

---

### 514. Expand test coverage for Metalogic_v2
- **Effort**: 10 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Session ID**: sess_1768700649_97b565
- **Created By**: Review task 506
- **Review Artifact**: [specs/506_codebase_review/summaries/review-summary.md](specs/506_codebase_review/summaries/review-summary.md)
- **Revised**: 2026-01-18
- **Research**: [research-001.md](specs/514_expand_test_coverage_for_metalogic_v2/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/514_expand_test_coverage_for_metalogic_v2/plans/implementation-001.md)

**Description**: Improve test coverage for Bimodal/Metalogic_v2/ directory. Draw inspiration from the original Metalogic/ test directory patterns, but focus on the new architecture which makes the representation theorem central. Do not import from old Metalogic/ versions since these will be removed in favor of Metalogic_v2/.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [EXPANDED]
- **Researched**: 2026-01-12
- **Priority**: High
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)

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

### 502. Complete representation theorem using context-based provability based on Task 499 foundation
 **Effort**: 4 hours
 **Status**: [COMPLETED]
 **Priority**: High
 **Language**: lean
 **Started**: 2026-01-14
- **Completed**: 2026-01-14
 **Researched**: 2026-01-14
 **Revised**: 2026-01-14
 **Parent**: Task 499
 **Dependencies**: Task 499 (completed)
 **Research**: [research-001.md](specs/502_complete_representation_theorem/reports/research-001.md), [research-002.md](specs/502_complete_representation_theorem/reports/research-002.md)
 *
 **Analysis**: [initial-analysis.md](specs/502_complete_representation_theorem/reports/initial-analysis.md)
 **Summary**: [research-002.md](specs/502_complete_representation_theorem/summaries/research-002.md)
 **Plan**: [implementation-001.md](specs/502_complete_representation_theorem/plans/implementation-001.md)
- **Implementation**: [RepresentationTheorems.lean](Theories/Bimodal/Metalogic/RepresentationTheorems.lean)
 **Session**: sess_1768452611_xef

**Description**: Complete representation theorem using Lean native context-based provability (ContextDerivable using List Formula) throughout Bimodal/ theory. Draw on research findings that confirm context-based provability is superior to set-based SetDerivable. Eliminate set-based provability entirely and integrate with FiniteCanonicalModel.lean using context-based approach.

**Key Implementation Points**:
- Replace SetDerivable with ContextDerivable throughout Bimodal/ theory
- Implement completeness theorems using context-based provability only
- Remove all set-based components from RepresentationTheorems.lean
- Integrate with FiniteCanonicalModel.lean using context-based approach
- Ensure Lean idiomatic patterns using List Formula for provability
- Leverage Task 499 foundation for metalogical architecture

**Files**:
- Theories/Bimodal/Metalogic/RepresentationTheorems.lean (scaffold exists)
- FiniteCanonicalModel.lean (integration target)
- Theories/Bimodal/Metalogic.lean (parent module)

---

## Medium Priority

### 510. Add constraint to verifier and falsifier functions
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](/home/benjamin/Projects/ProofChecker/specs/510_mereological_constraints_research/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/510_mereological_constraints/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260117.md](specs/510_mereological_constraints/summaries/implementation-summary-20260117.md)
- **Researched**: 2025-01-15
- **Planned**: 2025-01-16
- **Completed**: 2026-01-17

**Description**: Create distinct VerifierFunction and FalsifierFunction types with mereological constraints using pure dependent type theory. Avoid set-theoretic notions while allowing different extensions for verifiers vs falsifiers. Update both Lean implementation and LaTeX documentation (lines 75-76).

---

### 483. Investigate LaTeX aux file corruption errors
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: latex

**Description**: When making changes to LaTeX files (e.g., 00-Introduction.tex), rebuilding sometimes produces "File ended while scanning use of \@newl@bel" and "\@@BOOKMARK" errors, plus "Extra }, or forgotten \endgroup" errors in the .aux file. Identify the root cause (likely corrupted auxiliary files from interrupted builds) and document solutions to avoid these errors.

---

### 431. WezTerm tab color notification for Claude Code input needed
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Research Report**: [research-001.md](498_verify_bridge_lemma_infrastructure/reports/research-001.md)
- **Language**: general
- **Research**: [research-001.md](specs/431_wezterm_tab_color_notification/reports/research-001.md)

**Description**: Set up WezTerm tab color notification when Claude Code needs input. Using Claude Code in neovim via a plugin and WezTerm for the terminal on NixOS (software managed in ~/.dotfiles/). Configure so that when Claude Code completes or needs input, the numbered tab in WezTerm turns a visible color to indicate which tabs need attention.

---

## Low Priority

### 470. Finite model computational optimization
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458

**Description**: Optimize FiniteCanonicalModel.lean for computational efficiency. Current implementation prioritizes correctness over performance. Identify and implement optimizations for the finite world state enumeration, task relation checking, and truth evaluation.

---

### 490. Complete decidability procedure
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 469

**Description**: Complete the decidability procedure for TM logic. The existing Decidability module has tableau infrastructure but needs: proof extraction from closed tableaux, completeness proof connecting to FMP, and full decide function verification. Extends Task 469.

---

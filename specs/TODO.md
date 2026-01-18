---
next_project_number: 571
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 14
  completed: 174
  in_progress: 2
  not_started: 27
  abandoned: 14
  total: 203
priority_distribution:
  critical: 0
  high: 8
  medium: 10
  low: 11
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 566. Complete Semantic Embedding for Completeness Proof
- **Effort**: 4-6 hours
- **Status**: [IMPLEMENTING]
- **Session ID**: sess_1768701712_38de91
- **Priority**: High
- **Language**: lean
- **Parent**: 560
- **Researched**: 2026-01-18
- **Planned**: 2026-01-18
- **Research**: [research-001.md](specs/566_complete_semantic_embedding_for_completeness_proof/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/566_complete_semantic_embedding_for_completeness_proof/plans/implementation-001.md)

**Description**: Complete semantic embedding for completeness proof as per specs/560_axiom_elimination/summaries/implementation-summary-20260117.md to avoid all technical debt.

---

### 569. Analyze Proof Strategy Alternatives
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: lean
- **Parent**: 566
- **Research**: [research-001.md](specs/569_analyze_proof_strategy_alternatives/reports/research-001.md)

**Description**: Analyze different proof strategies for completing the semantic embedding in task 566. Compare contrapositive approach, direct instantiation, and alternative lemmas from rollback section.

---

### 570. Analyze Compound Formula Proof Requirements
- **Effort**: 2-3 hours
- **Status**: [RESEARCHING]
- **Priority**: High
- **Language**: lean
- **Parent**: 566

**Description**: Analyze what is needed to complete the 4 compound formula cases (imp, box, all_past, all_future) in truth_at_implies_semantic_truth. Document the proof obligations, required lemmas, and relationship between truth_at and assignment functions.

---

### 565. Investigate Workflow Interruption Issue
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Session ID**: sess_1768701291_ec7db1
- **Created**: 2026-01-17
- **Researched**: 2026-01-18
- **Research**: [research-001.md](specs/565_investigate_workflow_interruption_issue/reports/research-001.md)
- **Research**: [research-002.md](specs/565_investigate_workflow_interruption_issue/reports/research-002.md)
- **Plan**: [implementation-001.md](specs/565_investigate_workflow_interruption_issue/plans/implementation-001.md)
- **Plan**: [implementation-002.md](specs/565_investigate_workflow_interruption_issue/plans/implementation-002.md) (revised)
- **Revised**: 2026-01-18
- **Completed**: 2026-01-17
- **Summary**: [implementation-summary-20260117.md](specs/565_investigate_workflow_interruption_issue/summaries/implementation-summary-20260117.md)

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

### 568. Expand Logos Test Coverage
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-18
- **Source**: Code Review 2026-01-17

**Description**: Expand test coverage for Logos layer to match Bimodal layer standards. Currently ~40 Logos theory files have limited or no test coverage. Create comprehensive test suite including integration tests for layer extensions and property-based testing for Logos semantics.

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

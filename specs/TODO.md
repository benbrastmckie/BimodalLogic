---
next_project_number: 594
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 15
  completed: 181
  in_progress: 1
  not_started: 26
  abandoned: 18
  total: 209
priority_distribution:
  critical: 0
  high: 9
  medium: 8
  low: 11
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 591. Find and Fix Double Forking in Skill-Agent Delegation
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19
- **Completed**: 2026-01-19
- **Session ID**: sess_1768779943_482ffe
- **Research**: [research-001.md](specs/591_find_fix_double_forking/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/591_find_fix_double_forking/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/591_find_fix_double_forking/summaries/implementation-summary-20260119.md)

**Description**: Investigate and fix potential double forking in skill-to-agent delegation. Current architecture shows skills have both `context: fork` (which spawns a subprocess) AND invoke Task tool (which spawns another subprocess). This may cause: (1) Memory multiplication from nested subprocesses, (2) Zombie process accumulation, (3) Unnecessary token overhead. Audit all forked skills (skill-lean-implementation, skill-implementer, skill-latex-implementation, skill-researcher, skill-lean-research, skill-planner, skill-meta, skill-document-converter). Determine if `context: fork` should be removed OR if Task invocation should be replaced with direct execution. Reference: .claude/docs/skills-vs-agents-context-behavior.md, .claude/docs/research-skill-agent-contexts.md, .claude/docs/memory-leak-fix-plan.md

---

### 585. Add Session Cleanup to Agents
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19

**Description**: Add explicit session cleanup stage to all agent return workflows. Before returning JSON result, agents should clear large context references from memory and log session completion. Add Stage 8 (Session Cleanup) to lean-implementation-agent, general-implementation-agent, latex-implementation-agent after their Stage 7 (Return Structured JSON). This reduces memory footprint before agent termination.

---


### 593. Complete consistent_iff_consistent' in Basic.lean
- **Effort**: 1-2 hours
- **Status**: [IMPLEMENTING]
- **Priority**: High
- **Language**: lean
- **Created**: 2026-01-18
- **Related**: 588, 561
- **Research**: [research-001.md](specs/593_complete_consistent_iff_consistent_basic_lean/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/593_complete_consistent_iff_consistent_basic_lean/plans/implementation-001.md)

**Description**: Complete the sorry remaining in Metalogic_v2/Core/ for `consistent_iff_consistent'` in Basic.lean. This lemma establishes equivalence between the two consistency definitions used in the codebase.

---

### 589. Complete Representation Theorem in Metalogic_v2
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: lean
- **Dependencies**: 588
- **Related**: 556
- **Created**: 2026-01-18
- **Completed**: 2026-01-18
- **Research**: [research-001.md](specs/589_complete_representation_theorem_metalogic_v2/reports/research-001.md)
- **Summary**: [implementation-summary-20260118.md](specs/589_complete_representation_theorem_metalogic_v2/summaries/implementation-summary-20260118.md)

**Description**: Complete the Representation Theorem in Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean by filling remaining sorries (lines vary). The representation theorem establishes that every consistent context is satisfiable in the canonical model. Uses completed truth lemma from task 588. This is the FOUNDATION of the representation-first architecture.

**Note**: Research found that RepresentationTheorem.lean was already complete with zero sorries. No implementation work was required.

---

### 590. Eliminate Axiom in ContextProvability Using Representation Theorem
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: lean
- **Research**: [research-001.md](specs/590_eliminate_axiom_context_provability/reports/research-001.md)
- **Dependencies**: 589
- **Related**: 556, 566
- **Created**: 2026-01-18
- **Completed**: 2026-01-18

**Description**: Replace the `representation_theorem_backward_empty` axiom in Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean with a proven theorem using the completed representation theorem from task 589. Completeness follows as a corollary. DO NOT import from old Theories/Bimodal/Metalogic/ directory - use only Metalogic_v2 infrastructure. This completes the representation-first architecture with zero axioms.

---

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

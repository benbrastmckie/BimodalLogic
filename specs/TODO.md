---
next_project_number: 593
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 16
  completed: 180
  in_progress: 2
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
- **Status**: [IMPLEMENTING]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19
- **Session ID**: sess_1768779650_5df0f1
- **Research**: [research-001.md](specs/591_find_fix_double_forking/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/591_find_fix_double_forking/plans/implementation-001.md)

**Description**: Investigate and fix potential double forking in skill-to-agent delegation. Current architecture shows skills have both `context: fork` (which spawns a subprocess) AND invoke Task tool (which spawns another subprocess). This may cause: (1) Memory multiplication from nested subprocesses, (2) Zombie process accumulation, (3) Unnecessary token overhead. Audit all forked skills (skill-lean-implementation, skill-implementer, skill-latex-implementation, skill-researcher, skill-lean-research, skill-planner, skill-meta, skill-document-converter). Determine if `context: fork` should be removed OR if Task invocation should be replaced with direct execution. Reference: .claude/docs/skills-vs-agents-context-behavior.md, .claude/docs/research-skill-agent-contexts.md, .claude/docs/memory-leak-fix-plan.md

---

### 583. Add max_turns Limit to Agent Spawning
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19

**Description**: Add max_turns parameter to all workflow skill agent spawning calls (Task tool invocations). Set max_turns: 50 to limit agent conversation depth and prevent infinite context accumulation. Update skill-lean-implementation, skill-implementer, skill-latex-implementation, skill-researcher, skill-lean-research, skill-planner, skill-meta.

---

### 584. Add Memory Budget to Agent Documentation
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19

**Description**: Add Memory Budget section to all agent documentation files (.claude/agents/*.md). Document: (1) maximum turns limit (50), (2) turn budget per phase (~10 average), (3) context size limits (max 5 files per phase, skip files >10MB), (4) cleanup strategy (clear intermediate results, do not re-read completed proofs). Target agents: lean-implementation-agent, general-implementation-agent, latex-implementation-agent, lean-research-agent, general-research-agent, planner-agent.

---

### 585. Add Session Cleanup to Agents
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19

**Description**: Add explicit session cleanup stage to all agent return workflows. Before returning JSON result, agents should clear large context references from memory and log session completion. Add Stage 8 (Session Cleanup) to lean-implementation-agent, general-implementation-agent, latex-implementation-agent after their Stage 7 (Return Structured JSON). This reduces memory footprint before agent termination.

---


### 588. Complete Truth Lemma in Metalogic_v2
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: lean
- **Dependencies**: 587
- **Related**: 556
- **Created**: 2026-01-18
- **Completed**: 2026-01-18
- **Research**: [research-001.md](specs/588_complete_truth_lemma_metalogic_v2/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/588_complete_truth_lemma_metalogic_v2/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260118.md](specs/588_complete_truth_lemma_metalogic_v2/summaries/implementation-summary-20260118.md)

**Description**: Complete the Truth Lemma in Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean by filling the sorry in `necessitation_lemma` (line 160) and any other remaining sorries. The truth lemma establishes that for canonical worlds, formula membership equals truth: φ ∈ w.carrier ↔ w ⊨ φ. Uses MCS properties from tasks 586-587.

---

### 589. Complete Representation Theorem in Metalogic_v2
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Dependencies**: 588
- **Related**: 556
- **Created**: 2026-01-18

**Description**: Complete the Representation Theorem in Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean by filling remaining sorries (lines vary). The representation theorem establishes that every consistent context is satisfiable in the canonical model. Uses completed truth lemma from task 588. This is the FOUNDATION of the representation-first architecture.

---

### 590. Eliminate Axiom in ContextProvability Using Representation Theorem
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Dependencies**: 589
- **Related**: 556, 566
- **Created**: 2026-01-18

**Description**: Replace the `representation_theorem_backward_empty` axiom in Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean with a proven theorem using the completed representation theorem from task 589. Completeness follows as a corollary. DO NOT import from old Theories/Bimodal/Metalogic/ directory - use only Metalogic_v2 infrastructure. This completes the representation-first architecture with zero axioms.

---

### 566. Complete Semantic Embedding for Completeness Proof
- **Effort**: 4-6 hours
- **Status**: [BLOCKED]
- **Session ID**: sess_1768707914_bd0aad
- **Priority**: High
- **Language**: lean
- **Parent**: 560
- **Researched**: 2026-01-18
- **Planned**: 2026-01-18
- **Research**: [research-001.md](specs/566_complete_semantic_embedding_for_completeness_proof/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/566_complete_semantic_embedding_for_completeness_proof/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260118.md](specs/566_complete_semantic_embedding_for_completeness_proof/summaries/implementation-summary-20260118.md)
- **Blocked On**: MCS infrastructure sorries (closure_mcs_negation_complete, etc.)
- **Subtasks**: 571, 572, 573

**Description**: Complete semantic embedding for completeness proof as per specs/560_axiom_elimination/summaries/implementation-summary-20260117.md to avoid all technical debt.

---

### 571. Complete MCS Infrastructure
- **Effort**: 4-6 hours
- **Status**: [BLOCKED]
- **Priority**: High
- **Language**: lean
- **Parent**: 566
- **Created**: 2026-01-18
- **Research**: [research-001.md](specs/571_complete_mcs_infrastructure/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/571_complete_mcs_infrastructure/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260118.md](specs/571_complete_mcs_infrastructure/summaries/implementation-summary-20260118.md)
- **Blocked By**: Architectural mismatch - IsLocallyConsistent requires temporal reflexivity axioms not valid in TM logic

**Description**: Prove the MCS (Maximal Consistent Set) infrastructure lemmas that block the semantic embedding: `closure_mcs_negation_complete` (line 669), `closure_mcs_implies_locally_consistent` (line 1048), and `worldStateFromClosureMCS_models_iff` (line 1067) in FiniteCanonicalModel.lean.

---

### 572. Complete History Construction
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Parent**: 566
- **Dependencies**: 571
- **Created**: 2026-01-18

**Description**: Prove `finite_history_from_state` (lines 3121-3124) in FiniteCanonicalModel.lean using `finite_forward_existence` and `finite_backward_existence`. This lemma constructs proper histories for the canonical model.

---

### 573. Complete Bridge Lemmas
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Parent**: 566
- **Dependencies**: 571, 572
- **Created**: 2026-01-18

**Description**: After MCS infrastructure and history construction are complete, prove the 4 compound formula cases (imp, box, all_past, all_future) in `truth_at_implies_semantic_truth` (lines 3635, 3641, 3646, 3651) in FiniteCanonicalModel.lean. These bridge recursive semantic evaluation (`truth_at`) to flat assignment lookup (`FiniteWorldState.models`).

---

### 570. Analyze Compound Formula Proof Requirements
- **Effort**: 16 hours
- **Status**: [BLOCKED]
- **Session ID**: sess_1768709225_4f52f4
- **Priority**: High
- **Language**: lean
- **Parent**: 566
- **Research**: [research-001.md](specs/570_analyze_compound_formula_proof_requirements/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/570_analyze_compound_formula_proof_requirements/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260118.md](specs/570_analyze_compound_formula_proof_requirements/summaries/implementation-summary-20260118.md)
- **Blocked On**: Theorem fundamentally unprovable (soundness vs completeness gap)

**Description**: Analyze what is needed to complete the 4 compound formula cases (imp, box, all_past, all_future) in truth_at_implies_semantic_truth. Document the proof obligations, required lemmas, and relationship between truth_at and assignment functions.

**Conclusion**: The theorem `truth_at_implies_semantic_truth` is architecturally unprovable: `IsLocallyConsistent` provides soundness only (not completeness), and the correspondence only holds for MCS-derived states. Core completeness results (`semantic_weak_completeness`, `main_provable_iff_valid`) are PROVEN and unaffected.

---

## Medium Priority

### 574. Restructure main_weak_completeness with semantic_truth_at_v2
- **Effort**: 4-6 hours
- **Status**: [EXPANDED]
- **Priority**: Medium
- **Language**: lean
- **Follow-up**: 570
- **Created**: 2026-01-18
- **Research**: [research-001.md](specs/574_restructure_main_weak_completeness/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/574_restructure_main_weak_completeness/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260118.md](specs/574_restructure_main_weak_completeness/summaries/implementation-summary-20260118.md)
- **Subtasks**: 575, 576, 577, 578

**Description**: Restructure `main_weak_completeness` to use `semantic_truth_at_v2` throughout, avoiding the need for the problematic bridge. Per recommendation from task 570 analysis (implementation-summary-20260118.md line 68).

---

### 577. Prove Compound Formula Bridge Cases
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: lean
- **Parent**: 574
- **Dependencies**: 576
- **Created**: 2026-01-18
- **Research**: [research-001.md](specs/577_prove_compound_formula_bridge_cases/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/577_prove_compound_formula_bridge_cases/plans/implementation-001.md)

**Description**: Prove the 4 compound formula cases in truth_at_implies_semantic_truth: imp (line 3915), box (line 3921), all_past (line 3926), all_future (line 3931). Uses MCS negation completeness from task 576 to establish material implication and modal/temporal consistency properties.

---

### 578. Complete main_weak_completeness Sorry-Free
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Parent**: 574
- **Dependencies**: 577
- **Created**: 2026-01-18

**Description**: Complete main_weak_completeness with zero sorries by integrating the proven compound formula cases. Resolve the time arithmetic sorry (line 4421) connecting tau.states 0 to the constructed world state. Verify all completeness theorems compile without sorries and document the final architecture.

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

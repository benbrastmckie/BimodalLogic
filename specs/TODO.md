---
next_project_number: 738
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 13
  completed: 298
  in_progress: 4
  not_started: 10
  abandoned: 21
  total: 326
priority_distribution:
  critical: 0
  high: 6
  medium: 11
  low: 5
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [IMPLEMENTING]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-003.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [PLANNING]
- **Priority**: High
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 672. Implement agent system upgrade plan
- **Effort**: 6 weeks
- **Status**: [REVISED]
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None
- **Created**: 2026-01-22T00:48:23Z
- **Started**: 2025-01-22T12:52:47Z
- **Researched**: 2025-01-22T12:53:47Z
- **Planned**: 2025-01-22T13:04:47Z
- **Revised**: 2026-01-22T01:27:39Z
- **Research**: [research-001.md](specs/672_implement_agent_system_upgrade_plan/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/672_implement_agent_system_upgrade_plan/plans/implementation-003.md)

**Description**: Implement the .opencode system upgrade plan following specs/agent_system_upgrade_plan.md and specs/implementation_roadmap.md. This 6-week upgrade involves 4 phases: Phase 1 (Week 1): Foundation - file-based metadata exchange and state management; Phase 2 (Week 2): Workflow Ownership Migration - transfer postflight responsibilities to subagents; Phase 3 (Weeks 3-4): Meta System Builder Port - enable dynamic system extension; Phase 4 (Weeks 5-6): Forked Subagent Pattern - achieve token efficiency.

---

### 674. systematic command skill agent architecture improvement
- **Effort**: 3-4 days
- **Status**: [IMPLEMENTING]
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None
- **Created**: 2026-01-24
- **Artifacts**:
  - [Research Report](specs/674_systematic_command_skill_agent_architecture_improvement/reports/research-001.md) - Comprehensive architecture analysis with 5-phase implementation plan
  - [Research Report](specs/674_systematic_command_skill_agent_architecture_improvement/reports/research-002.md) - Focused analysis of preflight/postflight inconsistencies and architecture gaps
  - [Research Report](specs/674_systematic_command_skill_agent_architecture_improvement/reports/research-003.md) - Integrated preflight/postflight operations design with 3-phase migration approach
  - [Implementation Plan](specs/674_systematic_command_skill_agent_architecture_improvement/plans/implementation-003.md) - 4-phase implementation plan for integrated preflight/postflight operations in workflow skills

**Description**: Systematically improve command-skill-agent architecture with focus on preflight and postflight sequences across /research, /plan, /revise, /implement commands to ensure complete workflow execution and atomic state management

---

## Medium Priority

### 739. Update report-format.md with Project Context section
- **Effort**: 1-2 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-29
- **Plan**: [implementation-001.md](specs/739_update_report_format_with_project_context_section/plans/implementation-001.md)

**Description**: Update .claude/context/core/formats/report-format.md to include a new "Project Context" section in the research report template. The section should appear after metadata and before Executive Summary to provide early orientation. Define fields: relation to project goals, component location, relevant modules, and integration points. This provides researchers with context on how their work fits into the broader project structure.

---

### 740. Update skill-lean-research to generate Project Context
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Dependencies**: Task 739
- **Created**: 2026-01-29

**Description**: Update skill-lean-research to generate the Project Context section in lean research reports. Add context reference loading from project-overview.md, modify Stage 7 report generation to include the Project Context section as specified in report-format.md, and update .claude/context/project/lean4/agents/lean-research-flow.md Stage 5 documentation to reflect the new section. This ensures all lean research outputs include orientation information.

---




### 735. Complete phase 5 of task 700: Ultrafilter-MCS Correspondence
- **Effort**: 1.5 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 700
- **Created**: 2026-01-29
- **Completed**: 2026-01-29
- **Research**: [research-001.md](specs/735_complete_task700_phase5_ultrafilter_mcs_correspondence/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/735_complete_task700_phase5_ultrafilter_mcs_correspondence/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/735_complete_task700_phase5_ultrafilter_mcs_correspondence/summaries/implementation-summary-20260129.md)

**Description**: Complete phase 5 of task 700: Ultrafilter-MCS Correspondence. Fill ultrafilterToSet_mcs consistency proof - show that if L ⊢ ⊥ and all [φᵢ] ∈ U, then ⊥ ∈ U. Requires relating list conjunction to fold of quotients. (Follow-up from task #700)

---

### 736. Complete phase 6 of task 700: Algebraic Representation Theorem
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 700
- **Created**: 2026-01-29
- **Completed**: 2026-01-29
- **Research**: [research-001.md](specs/736_complete_task700_phase6_algebraic_representation/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/736_complete_task700_phase6_algebraic_representation/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/736_complete_task700_phase6_algebraic_representation/summaries/implementation-summary-20260129.md)

**Description**: Complete phase 6 of task 700: Algebraic Representation Theorem. Prove ultrafilter existence (consistent_implies_satisfiable) using Zorn's lemma adaptation - for any non-⊥ element a, there exists ultrafilter containing a. Also complete mcs_ultrafilter_correspondence bijection proof. (Follow-up from task #700)

---

### 733. Ultraproduct-based proof of compactness
- **Effort**: 6-10 hours
- **Status**: [PLANNING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-29
- **Research**: [research-001.md](specs/733_ultraproduct_based_compactness_proof/reports/research-001.md)

**Description**: Provide an ultraproduct-based proof of compactness for TM logic.

---

### 732. Complete phase 4 of task 630: Truth Lemma proof
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Parent**: Task 630
- **Research**: [research-001.md](specs/732_complete_630_phase4_truth_lemma_proof/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/732_complete_630_phase4_truth_lemma_proof/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/732_complete_630_phase4_truth_lemma_proof/summaries/implementation-summary-20260129.md)

**Description**: Complete phase 4 of task 630: Prove mem_extractTrueAtomSet_iff helper lemma. This establishes that p ∈ extractTrueAtomSet b ↔ SignedFormula.pos (.atom p) ∈ b. The proof is mechanical (induction on branch with case splits on Formula constructors: atom, bot, imp, box, all_past, all_future for both pos and neg signs). Currently has sorry at Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/BranchTaskModel.lean:269. (Follow-up from task #630)

---

### 700. Research algebraic representation theorem proof
- **Effort**: 12-16 hours
- **Status**: [PARTIAL]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-28
- **Started**: 2026-01-29
- **Subtasks**: 735, 736
- **Source**: specs/ROAD_MAP.md:291
- **Research**: [research-001.md](specs/700_research_algebraic_representation_theorem_proof/reports/research-001.md), [research-002.md](specs/700_research_algebraic_representation_theorem_proof/reports/research-002.md), [research-003.md](specs/700_research_algebraic_representation_theorem_proof/reports/research-003.md)
- **Plan**: [implementation-001.md](specs/700_research_algebraic_representation_theorem_proof/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/700_research_algebraic_representation_theorem_proof/summaries/implementation-summary-20260129.md)

**Description**: Develop a purely algebraic approach to the representation theorem as an alternative to the current seed-extension approach. Leverages reflexive G/H semantics to show temporal operators form interior operators on the Lindenbaum-Tarski algebra. All algebraic infrastructure isolated in `Metalogic/Algebraic/` for clean removal if approach fails. Phase 1 complete; 14 sorries remain requiring propositional helper lemmas.

---

### 685. Derive world-history and Barcan theorems
- **Effort**: 8-10 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-26
- **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)
- **Research**: [research-001.md](specs/685_derive_world_history_and_barcan_theorems/reports/research-001.md)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---

### 658. Prove indexed family coherence conditions
- **Status**: [COMPLETED]
- **Session**: sess_1769647181_06ee35
- **Effort**: 30-45 min
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Completed**: 2026-01-29
- **Dependencies**: Task 681 (COMPLETED), Task 697 (COMPLETED)
- **Related**: Task 654, Task 657, Task 700
- **Source**: Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean:77
- **Plan**: [implementation-007.md](specs/658_prove_indexed_family_coherence_conditions/plans/implementation-007.md)
- **Research**: [research-001.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-001.md), [research-002.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-002.md), [research-003.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-003.md), [research-004.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-004.md), [research-005.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-005.md)
- **Summary**: [implementation-summary-20260129.md](specs/658_prove_indexed_family_coherence_conditions/summaries/implementation-summary-20260129.md)

**Description**: Switched `representation_theorem` to use `construct_coherent_family` instead of superseded `construct_indexed_family`. Coherence proofs now definitional via CoherentConstruction.lean two-chain architecture.

---

### 660. Prove parametric completeness theorems
- **Effort**: 10-15 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Dependencies**: Tasks 656, 657, 658
- **Related**: Task 654
- **Research**: [research-001.md](specs/660_prove_parametric_completeness_theorems/reports/research-001.md), [research-002.md](specs/660_prove_parametric_completeness_theorems/reports/research-002.md)
- **Plan**: [implementation-001.md](specs/660_prove_parametric_completeness_theorems/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/660_prove_parametric_completeness_theorems/summaries/implementation-summary-20260129.md)

**Description**: Use the representation theorem from Task 654 to prove weak and strong completeness for TM logic over arbitrary ordered additive groups. The representation theorem establishes that consistent formulas are satisfiable in the parametric canonical model. This task completes the metalogic by deriving completeness: (1) Weak completeness: if ⊨ φ then ⊢ φ, (2) Strong completeness: if Γ ⊨ φ then Γ ⊢ φ. Builds on the foundation established by Tasks 656-658. From review-20260121-task654.md future work section.

---

### 631. Prove evalFormula_implies_satisfiable bridging lemma
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Parent**: Task 490
- **Dependencies**: Task 630
- **Related**: Tasks 624, 628
- **Research**: [research-001.md](specs/631_prove_evalformula_implies_satisfiable/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/631_prove_evalformula_implies_satisfiable/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/631_prove_evalformula_implies_satisfiable/summaries/implementation-summary-20260129.md)

**Description**: Prove the semantic bridge lemma `evalFormula_implies_sat`: if `evalFormula b φ = false` for a saturated open branch, then φ is not satisfiable in the extracted TaskModel. This connects the simplified propositional evaluation in `evalFormula` to full task frame semantics via `truth_at M τ t φ`. Uses the TaskModel extraction from Task 630. Key insight: must show that for the extracted model M with some WorldHistory τ and time t, `truth_at M τ t φ = false`. Combined with `branchTruthLemma` (completed in Task 623), this provides the contrapositive needed for `tableau_complete`: valid formulas cannot have open saturated branches.

---

### 619. Agent system architecture upgrade (context:fork migration)
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-28
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Blocked-By**: Empirically confirmed broken (research-005.md) - GitHub #16803
- **Research**: [research-001.md](specs/619_agent_system_architecture_upgrade/reports/research-001.md), [research-002.md](specs/619_agent_system_architecture_upgrade/reports/research-002.md), [research-003.md](specs/619_agent_system_architecture_upgrade/reports/research-003.md), [research-004.md](specs/619_agent_system_architecture_upgrade/reports/research-004.md), [research-005.md](specs/619_agent_system_architecture_upgrade/reports/research-005.md)
- **Plan**: [implementation-002.md](specs/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: FUTURE UPGRADE: Migrate agent system skills to use native `context: fork` frontmatter once Anthropic fixes GitHub issue #16803. Empirical testing (research-005.md) confirmed context:fork provides NO context isolation, NO tool restrictions, and NO subprocess isolation - the feature is completely non-functional. Current implementation (direct execution for Lean skills, Task delegation for others) is correct and should remain until context:fork is fixed and re-validated.

---

### 431. WezTerm tab color notification for Claude Code input needed
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](specs/431_wezterm_tab_color_notification/reports/research-001.md)

**Description**: Set up WezTerm tab color notification when Claude Code needs input. Using Claude Code in neovim via a plugin and WezTerm for the terminal on NixOS (software managed in ~/.dotfiles/). Configure so that when Claude Code completes or needs input, the numbered tab in WezTerm turns a visible color to indicate which tabs need attention.

---

## Low Priority

### 737. Fix unused simp arguments in TemporalProofStrategies.lean
- **Effort**: 30 min
- **Status**: [COMPLETED]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Source**: Review 20260129
- **Plan**: [implementation-001.md](specs/737_fix_unused_simp_arguments_temporalproofstrategies/plans/implementation-001.md)
- **Summary**: Removed unused Formula.swap_temporal_involution arguments from 4 simp calls. Linter warnings eliminated.

**Description**: Fix unused simp arguments in TemporalProofStrategies.lean. Remove Formula.swap_temporal_involution from simp calls at lines 174, 203, 242, 459 where the linter reports it is unused.

---

### 738. Port FMP to parametric architecture
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-29
- **Parent Task**: 660

**Description**: Complete phase 3 of task 660: Finite Model Property Port. Port FMP to parametric architecture with explicit cardinality bounds on finite models. This provides decidability foundation (orthogonal to completeness chain). Follow-up from task #660.

---

### 616. Remove false theorem semantic_task_rel_compositionality
- **Status**: [COMPLETED]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-19
- **Completed**: 2026-01-29
- **Related**: Task 608
- **Research**: [research-001.md](specs/616_remove_false_semantic_task_rel_compositionality/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/616_remove_false_semantic_task_rel_compositionality/plans/implementation-001.md)
- **Summary**: Removed mathematically false theorem semantic_task_rel_compositionality from SemanticCanonicalModel.lean. Sorry now inlined in SemanticCanonicalFrame definition. Updated all related documentation.

**Description**: Remove the mathematically false theorem semantic_task_rel_compositionality and its sorry from SemanticCanonicalModel.lean. Research confirmed this theorem cannot be proven (unbounded duration sums exceed finite time domain), and it is not needed for the completeness proof which uses a different approach. Remove the false claim rather than accepting a sorry for an unprovable statement.

---

### 659. Prove negation completeness lemmas
- **Effort**: 6-10 hours
- **Status**: [PLANNED]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-21
- **Started**: 2026-01-29
- **Related**: Tasks 654, 656
- **Source**: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:211,219,228,237
- **Research**: [research-001.md](specs/659_prove_negation_completeness_lemmas/reports/research-001.md), [research-002.md](specs/659_prove_negation_completeness_lemmas/reports/research-002.md), [research-003.md](specs/659_prove_negation_completeness_lemmas/reports/research-003.md), [research-004.md](specs/659_prove_negation_completeness_lemmas/reports/research-004.md)
- **Plan**: [implementation-002.md](specs/659_prove_negation_completeness_lemmas/plans/implementation-002.md)

**Description**: Prove the negation completeness lemmas required for the truth lemma backward direction. These include the imp, box, and temporal cases in the backward direction (lines 211, 219, 228, 237). Requires showing that MCS are complete with respect to negation. Not critical since the representation theorem only needs the forward direction, but would complete the full biconditional truth lemma. From review-20260121-task654.md low priority recommendations.

---

### 490. Complete decidability procedure
- **Status**: [EXPANDED]
- **Researched**: 2026-01-19
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 469
- **Dependencies**: Task 607
- **Subtasks**: 622, 623, 624, 625, 630, 631
- **Research**: [research-001.md](specs/490_complete_decidability_procedure/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/490_complete_decidability_procedure/plans/implementation-003.md)
- **Summary**: [implementation-summary-20260119.md](specs/490_complete_decidability_procedure/summaries/implementation-summary-20260119.md)

**Description**: Complete the decidability procedure for TM logic. Phases 1-2 completed with helper lemmas and proof structure. Expanded into subtasks for remaining work.

---

### 623. Build FMP-tableau connection infrastructure
- **Status**: [EXPANDED]
- **Researched**: 2026-01-19
- **Started**: 2026-01-19
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 490
- **Subtasks**: 630, 631
- **Research**: [research-001.md](specs/623_build_fmp_tableau_connection_infrastructure/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/623_build_fmp_tableau_connection_infrastructure/plans/implementation-003.md)

**Description**: Build infrastructure connecting FMP bounds to tableau semantics. Phases 1-2.3 and 4 completed (expansion/saturation lemmas, branchTruthLemma). Phase 3 blocked on semantic bridge gap. Expanded into Tasks 630 (Kripke model extraction) and 631 (evalFormula_implies_sat lemma) to address the blocker.

---

### 624. Prove tableau_complete
- **Status**: [PLANNING]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 490
- **Dependencies**: Task 623

**Description**: Prove the `tableau_complete` theorem in Correctness.lean connecting FMP to tableau termination. Uses infrastructure from Task 623 to show that valid formulas have closing tableaux within FMP fuel bounds.

---

### 625. Prove decide_complete
- **Status**: [PLANNING]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 490
- **Dependencies**: Task 624

**Description**: Prove the `decide_complete` theorem in Correctness.lean deriving decision procedure completeness from tableau completeness. Follows directly from tableau_complete (Task 624).

---


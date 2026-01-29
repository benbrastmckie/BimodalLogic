---
next_project_number: 753
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 15
  completed: 312
  in_progress: 4
  not_started: 6
  abandoned: 21
  total: 341
priority_distribution:
  critical: 0
  high: 4
  medium: 4
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
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

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

### 752. Refactor temporary file handling in agent system
- **Effort**: 5 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-29
- **Completed**: 2026-01-29
- **Research**: [research-001.md](specs/752_refactor_temporary_file_handling_in_agent_system/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/752_refactor_temporary_file_handling_in_agent_system/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/752_refactor_temporary_file_handling_in_agent_system/summaries/implementation-summary-20260129.md)

**Description**: Review and improve temporary file and metadata passing techniques throughout the agent system to ensure robust performance with concurrent agents. Currently, temporary files like `specs/.postflight-pending` are created in the shared `specs/` directory, which may cause conflicts when multiple agents work simultaneously. Consider moving these files to task-specific project directories (e.g., `specs/{N}_{SLUG}/`) since at most one agent works on a task at a time. Systematically audit all temporary file usage, metadata exchange patterns, and file-based coordination mechanisms to identify and resolve potential race conditions or conflicts.

---

### 749. Establish sorry-free completeness via semantic_weak_completeness
- **Effort**: 6 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-29
- **Research**: [research-001.md](specs/749_establish_sorry_free_completeness_via_semantic_weak_completeness/reports/research-001.md)

**Description**: Establish sorry-free completeness using `semantic_weak_completeness` which works directly with finite model truth, avoiding the truth bridge, or other methods if better.

---

### 750. Refactor forward Truth Lemma to remove sorries and eliminate backward direction
- **Effort**: 6 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-29
- **Research**: [research-005.md](specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-005.md)
- **Plan**: [implementation-001.md](specs/750_refactor_forward_truth_lemma_remove_sorries/plans/implementation-001.md)

**Description**: Following the contingency approach from task 745 (which kept mutual induction structure but marked backward cases as sorry with comments), refactor the forward Truth Lemma to avoid all sorries and completely remove the backward direction which is not needed for the metalogic as it stands.

---

### 747. Create Bimodal/Metalogic README hierarchy
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: markdown
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Research**: [research-001.md](specs/747_create_bimodal_metalogic_readme_hierarchy/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/747_create_bimodal_metalogic_readme_hierarchy/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/747_create_bimodal_metalogic_readme_hierarchy/summaries/implementation-summary-20260129.md)

**Description**: Create/update README.md in each subdirectory of Bimodal/Metalogic/ providing full and accurate documentation of modules in that directory. Subdirectories should be summarized with links to their contained README.md files. Work from deepest directories upward, culminating in Bimodal/Metalogic/README.md. Each README should describe module purposes, key definitions/theorems, and how modules relate to each other.

---

### 748. Revise ROAD_MAP.md for Metalogic progress
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Created**: 2026-01-29

**Description**: Systematically revise /home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md given progress made in Bimodal/Metalogic/, what remains to be done, and future ambitions. Update completion status of achieved milestones, add new goals discovered during implementation, and ensure the roadmap accurately reflects the project's trajectory.

---

### 744. Update documentation for restored Lean agent architecture
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-29
- **Dependencies**: Tasks 742, 743

**Description**: Update CLAUDE.md skill-to-agent mapping table to show skill-lean-research → lean-research-agent and skill-lean-implementation → lean-implementation-agent (removing direct execution notes). Update blocked-mcp-tools.md to reference restored agents. Update any other references to the deprecated/direct-execution pattern in context files.

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

### 659. Prove negation completeness lemmas
- **Effort**: 6-10 hours
- **Status**: [PARTIAL]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-21
- **Started**: 2026-01-29
- **Related**: Tasks 654, 656
- **Source**: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:211,219,228,237
- **Research**: [research-001.md](specs/659_prove_negation_completeness_lemmas/reports/research-001.md), [research-002.md](specs/659_prove_negation_completeness_lemmas/reports/research-002.md), [research-003.md](specs/659_prove_negation_completeness_lemmas/reports/research-003.md), [research-004.md](specs/659_prove_negation_completeness_lemmas/reports/research-004.md), [research-005.md](specs/659_prove_negation_completeness_lemmas/reports/research-005.md)
- **Plan**: [implementation-002.md](specs/659_prove_negation_completeness_lemmas/plans/implementation-002.md)
- **Summary**: [implementation-summary-20260129.md](specs/659_prove_negation_completeness_lemmas/summaries/implementation-summary-20260129.md)
- **Partial**: Phases 1,2,5 complete; Phases 3,4 blocked (backward Truth Lemma requires architectural changes)

**Description**: Prove the negation completeness lemmas required for the truth lemma backward direction. These include the imp, box, and temporal cases in the backward direction (lines 211, 219, 228, 237). Requires showing that MCS are complete with respect to negation. Not critical since the representation theorem only needs the forward direction, but would complete the full biconditional truth lemma. From review-20260121-task654.md low priority recommendations.

---

### 741. Witness extraction architecture for backward Truth Lemma
- **Effort**: 8-12 hours
- **Status**: [PARTIAL]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Related**: Tasks 654, 656, 659
- **Research**: [research-001.md](specs/741_witness_extraction_architecture_for_backward_truth_lemma/reports/research-001.md), [research-002.md](specs/741_witness_extraction_architecture_for_backward_truth_lemma/reports/research-002.md)
- **Plan**: [implementation-001.md](specs/741_witness_extraction_architecture_for_backward_truth_lemma/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/741_witness_extraction_architecture_for_backward_truth_lemma/summaries/implementation-summary-20260129.md)

**Description**: Design and implement witness extraction architecture to enable backward Truth Lemma proofs. The backward temporal cases (lines 423, 441 in TruthLemma.lean) require proving: `Hψ ∉ mcs(t) → ∃ s < t. ψ ∉ mcs(s)` (and symmetric for G). **STATUS**: BLOCKED by fundamental omega-rule limitation - proving H-completeness requires deriving H psi from infinitely many psi instances. Supplementary research (research-002.md) confirms all alternative approaches are blocked: construction-specific proof (Lindenbaum non-deterministic), semantic bridge (circular), negation duality (doesn't extract witnesses), finite approximation (needs TM compactness). Created infrastructure in TemporalCompleteness.lean. NOT REQUIRED FOR COMPLETENESS - the representation theorem only uses truth_lemma_forward. Recommended resolution: document as known limitation.

---


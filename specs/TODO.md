---
next_project_number: 837
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-03T11:15:00Z
task_counts:
  active: 11
  completed: 379
  in_progress: 2
  not_started: 10
  abandoned: 26
  total: 407
technical_debt:
  sorry_count: 61
  axiom_count: 15
  build_errors: 0
  status: good
---

# TODO

## Tasks

### 836. Improve Metalogic README documentation with flowcharts and subdirectory summaries
- **Effort**: 5 hours
- **Status**: [PLANNED]
- **Language**: general
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Research**: [research-001.md](specs/836_improve_metalogic_readme_documentation/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/836_improve_metalogic_readme_documentation/plans/implementation-001.md)

**Description**: Improve documentation for Metalogic/README.md following task 830's incomplete work. Clearly represent the representation theorem and all major modules with detailed dependency flowchart. Include comprehensive summaries of each Metalogic/ subdirectory with links to their README.md files. Review and update all subdirectory README.md files for accuracy and exhaustivity.

---

### 835. Enhance /review Command with ROADMAP.md Integration and Revision
- **Effort**: 4-5 hours
- **Status**: [IMPLEMENTING]
- **Language**: meta
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Started**: 2026-02-03
- **Dependencies**: Task 833
- **Research**: [research-001.md](specs/835_enhance_review_command_roadmap_integration_revision/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/835_enhance_review_command_roadmap_integration_revision/plans/implementation-001.md)

**Description**: Extend /review command to: (1) Begin by loading and analyzing ROADMAP.md context (Strategies and Ambitions sections) to inform codebase review, (2) End by revising ROADMAP.md based on review findings (update strategy statuses, propose new ambitions, identify gaps), (3) Conclude with task suggestions based on findings (like /learn), (4) Create skill-reviewer if delegation is needed, or extend existing review logic. Ensure changes follow checkpoint-based execution pattern.

---

### 833. Enhance ROADMAP.md Structure with Changelog, Strategies, and Ambitions
- **Effort**: 2-3 hours
- **Status**: [IMPLEMENTING]
- **Language**: general
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Research**: [research-001.md](specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/reports/research-001.md), [research-002.md](specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/reports/research-002.md)
- **Plan**: [implementation-002.md](specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/plans/implementation-002.md)

**Description**: Restructure ROADMAP.md to add three new sections: (1) Changelog - dated entries of completed work from task completions, (2) Strategies - active experiments with status, (3) Ambitions - big picture goals. Migrate existing content into appropriate sections. Define clear schemas for each section to enable programmatic updates by /todo and /review commands.

---

### 828. Explore FMP approach to complete backward direction of TruthLemma
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Research**: [research-001.md](specs/828_fmp_approach_truthlemma_backward/reports/research-001.md)

**Description**: Explore FMP approach to complete backward direction of TruthLemma. The backward direction sorries in Bundle/TruthLemma.lean (lines 383, 395) for G/H operators currently require infinitary proof systems. Investigate whether the Finite Model Property can provide an alternative approach to proving these directions.

---

### 827. Complete multi-family BMCS construction to resolve modal_backward sorry
- **Effort**: 10 hours
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Started**: 2026-02-03
- **Research**: [research-001.md](specs/827_complete_multi_family_bmcs_construction/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/827_complete_multi_family_bmcs_construction/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260203.md](specs/827_complete_multi_family_bmcs_construction/summaries/implementation-summary-20260203.md) (partial)

**Description**: Complete multi-family BMCS construction to resolve modal_backward sorry. The single-family simplification in Bundle/Construction.lean (line 220) accepts modal_backward as a sorry. Implement the full multi-family construction that properly tracks accessibility relations across multiple MCS families to eliminate this assumption.

---

### 793. Fix Claude Code neovim sidebar black screen delay
- **Effort**: S
- **Status**: [PLANNED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/793_fix_claude_code_neovim_sidebar_black_screen/reports/research-001.md)

**Description**: Investigate and fix issue where running a command in Claude Code sidebar in neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. Functionality works correctly otherwise. Issue started recently. Root cause may be in hook system or external. Research online and review hook configuration to identify simple and elegant fix.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [IMPLEMENTING]
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [PLANNED]
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 685. Derive world-history and Barcan theorems
 **Effort**: 8-10 hours
 **Status**: [PLANNED]
 **Language**: lean
 **Created**: 2026-01-26
 **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)
 **Research**: [research-001.md](specs/685_derive_world_history_and_barcan_theorems/reports/research-001.md)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---

### 672. Implement agent system upgrade plan
- **Effort**: 6 weeks
- **Status**: [REVISED]
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

### 619. Agent system architecture upgrade (context:fork migration)
- **Status**: [PLANNED]
- **Researched**: 2026-01-28
- **Language**: meta
- **Created**: 2026-01-19
- **Blocked-By**: Empirically confirmed broken (research-005.md) - GitHub #16803
- **Research**: [research-001.md](specs/619_agent_system_architecture_upgrade/reports/research-001.md), [research-002.md](specs/619_agent_system_architecture_upgrade/reports/research-002.md), [research-003.md](specs/619_agent_system_architecture_upgrade/reports/research-003.md), [research-004.md](specs/619_agent_system_architecture_upgrade/reports/research-004.md), [research-005.md](specs/619_agent_system_architecture_upgrade/reports/research-005.md)
- **Plan**: [implementation-002.md](specs/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: FUTURE UPGRADE: Migrate agent system skills to use native `context: fork` frontmatter once Anthropic fixes GitHub issue #16803. Empirical testing (research-005.md) confirmed context:fork provides NO context isolation, NO tool restrictions, and NO subprocess isolation - the feature is completely non-functional. Current implementation (direct execution for Lean skills, Task delegation for others) is correct and should remain until context:fork is fixed and re-validated.


---
next_project_number: 775
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-30T01:20:10Z
task_counts:
  active: 11
  completed: 326
  in_progress: 3
  not_started: 5
  abandoned: 23
  total: 350
priority_distribution:
  critical: 0
  high: 4
  medium: 4
  low: 1
technical_debt:
  sorry_count: 79
  axiom_count: 10
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
- **Status**: [PLANNED]
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

### 774. Restore representation theorem as Under Development
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean

**Description**: Restore representation theorem proofs from Boneyard/Metalogic_v4/ (archived by task 772) to an Under Development section alongside the Algebraic/ approach. Include TaskRelation.lean, CoherentConstruction.lean, TruthLemma.lean and related files that naturally belong together as work-in-progress completeness approaches.

---

### 772. Refactor Metalogic for sorry-free archive sorried proofs
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-30
- **Researched**: 2026-01-30
- **Planned**: 2026-01-30
- **Started**: 2026-01-30
- **Completed**: 2026-01-30
- **Research**: [research-001.md](specs/772_refactor_metalogic_sorry_free_archive_sorried_proofs/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/772_refactor_metalogic_sorry_free_archive_sorried_proofs/plans/implementation-001.md)
- **Summary**: Archived 7 files (17 sorries) from Metalogic/ to Boneyard/Metalogic_v4/. Refactored WeakCompleteness.lean to use sorry-free semantic_weak_completeness. Resolved circular import dependency. Full project build passes with 3 documented architectural sorries remaining.

**Description**: Refactor Bimodal/Metalogic/ to archive all sorried proofs to Boneyard/ for a sorry-free metalogic. Move TaskRelation.lean (5 sorries), CoherentConstruction.lean (8 sorries), TruthLemma.lean (4 sorries), and sorried FMP theorems to Boneyard/. Refactor weak_completeness to use semantic_weak_completeness approach instead of representation_theorem. Preserve all theorem statements and ensure build passes. Goal: zero sorry count in Theories/Bimodal/Metalogic/ (excluding Boneyard/, Examples/).

---

### 771. Improve Typst formatting to AMS journal style
- **Effort**: 3 hours
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: typst
- **Created**: 2026-01-30
- **Researched**: 2026-01-30
- **Planned**: 2026-01-30
- **Revised**: 2026-01-30
- **Research**: [research-001.md](specs/771_improve_typst_formatting_ams_journal_style/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/771_improve_typst_formatting_ams_journal_style/plans/implementation-002.md)

**Description**: Upgrade Typst formatting from textbook-style (boxed theorems) to professional math journal style. Migrate from thmbox package to ctheorems with thmplain for AMS-style plain environments. Remove all visual decoration from theorem environments (no boxes, fills, strokes). Convert diagram colors to grayscale. Match appearance of Annals of Mathematics and AMS journals.

---

### 765. Exclude Boneyard and Examples from sorry count metrics
- **Effort**: 1 hour
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Researched**: 2026-01-29
- **Planned**: 2026-01-29
- **Research**: [research-001.md](specs/765_exclude_boneyard_examples_from_sorry_count/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/765_exclude_boneyard_examples_from_sorry_count/plans/implementation-001.md)

**Description**: Exclude Boneyard/ and Examples/ directories from sorry count metrics. Update: (1) /todo command grep at todo.md:850, (2) /review command at review.md:132, (3) state-management.md documentation, (4) current metrics in state.json and TODO.md (~72 instead of ~322).

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

## Low Priority

### 767. Document TTS/STT integration and Claude Code keybinding resolution
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: general
- **Created**: 2026-01-29

**Description**: Comprehensive report documenting TTS/STT integration implementation and Claude Code keybinding resolution: (1) Initial STT plugin implementation with neotex.plugins.tools structure and which-key integration, (2) Bug fixes including module name collision (stt.lua to stt-plugin.lua) and WezTerm tab detection using position instead of tab_id, (3) Keybinding attempts with leader-vv for regular Neovim and Ctrl-backslash for Claude Code compatibility, (4) Research findings on Claude Code keybindings.json limitations and greggh/claude-code.nvim terminal mode requirements, (5) Final solution with buffer-local terminal mode keybinding in TermOpen autocmd for Claude Code sidebar. Documents all implementation attempts, debugging steps, and final working configuration for future reference.

---


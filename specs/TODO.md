---
next_project_number: 803
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-31T22:09:03Z
task_counts:
  active: 10
  completed: 339
  in_progress: 2
  not_started: 2
  abandoned: 24
  total: 363
technical_debt:
  sorry_count: 196
  axiom_count: 17
  build_errors: 1
  status: manageable
---

# TODO

## Tasks

### 802. Fix WezTerm tab task number clearing on Neovim exit and /clear command
- **Effort**: S
- **Status**: [PLANNING]
- **Language**: meta
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/802_wezterm_task_number_clearing_neovim_exit/reports/research-001.md)

**Description**: Fix WezTerm tab task number clearing on Neovim exit and /clear command. Task numbers should clear when Neovim closes or when /clear is run in Claude Code, and the tab should show the correct directory (OSC 7). Currently task numbers persist after these events.

---

### 801. Document Soundness temp_t axiom semantic validity issue
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-01

**Description**: Document the 2 sorries in SoundnessLemmas.lean (temp_t axioms). These are NOT semantically valid with strict inequality but were added for syntactic completeness (MCS coherence). Add clear documentation explaining this is an acceptable known limitation. Evaluate if these can be resolved or should be marked as permanent documented technical debt.

---

### 800. Fix FMP/SemanticCanonicalModel sorries
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-01

**Description**: Fix the 5 remaining sorries in FMP/SemanticCanonicalModel.lean. This file is part of the core completeness path and contains semantic_weak_completeness. Investigate each sorry, determine if they are essential gaps or can be completed with available lemmas.

---

### 799. Complete Decidability proofs
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-01

**Description**: Complete the 6 remaining sorries in Decidability/: 2 sorries in Closure.lean (tableau closure proofs), 1 sorry in Saturation.lean (rule termination), and 3 sorries in Correctness.lean. These are technical completeness/termination proofs for the tableau-based decision procedure.

---

### 798. Refactor Completeness.lean and extract Lindenbaum infrastructure
- **Effort**: TBD
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Planned**: 2026-02-01
- **Started**: 2026-02-01
- **Research**: [research-001.md](specs/798_refactor_completeness_lean/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/798_refactor_completeness_lean/plans/implementation-001.md)

**Description**: Refactor the monolithic Completeness.lean (~4000 lines, 39 sorries). Extract essential content: SetConsistent, SetMaximalConsistent definitions to Core/SetConsistency.lean; set_lindenbaum (Lindenbaum lemma via Zorn) and chain consistency lemmas to Core/Lindenbaum.lean. Archive the Duration construction infrastructure, TemporalExt/Coherent interfaces, and generic weak_completeness/strong_completeness axioms to Boneyard/Metalogic_v4/Completeness/MonolithicCompleteness.lean.

---

### 797. Extract Representation dependencies and archive redundant sorries
- **Effort**: TBD
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Planned**: 2026-02-01
- **Started**: 2026-02-01
- **Completed**: 2026-02-02
- **Research**: [research-001.md](specs/797_extract_representation_dependencies/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/797_extract_representation_dependencies/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260202.md](specs/797_extract_representation_dependencies/summaries/implementation-summary-20260202.md)

**Description**: Extract the necessary elements from Representation/ that InfinitaryStrongCompleteness.lean depends on (construct_coherent_family, truth_lemma forward direction, canonical_model, canonical_history_family, UniversalCanonicalFrame) into a minimal, clean module. Then archive the redundant and sorry-filled portions of Representation/ to Boneyard/Metalogic_v4/Representation/. The goal is to reduce the 35 sorries in Representation/ while preserving the active dependency chain for infinitary completeness.

---

### 796. Complete all remaining sorries
- **Effort**: M
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/796_complete_remaining_sorries/reports/research-001.md)

**Description**: Draw on specs/794_sorry_free_completeness_theorems/summaries/implementation-summary-20260201.md to complete all remaining sorries.

---

### 795. Fix wezterm tab project number persistence for workflow commands
- **Effort**: S
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Planned**: 2026-02-01
- **Started**: 2026-02-01
- **Completed**: 2026-02-01
- **Research**: [research-001.md](specs/795_wezterm_tab_project_number_persistence/reports/research-001.md)
- **Plan**: [implementation-004.md](specs/795_wezterm_tab_project_number_persistence/plans/implementation-004.md)
- **Summary**: [implementation-summary-20260201.md](specs/795_wezterm_tab_project_number_persistence/summaries/implementation-summary-20260201.md)

**Description**: Fix wezterm tab project number persistence behavior. Workflow commands like `/plan N` and `/implement N` should update/replace the project number in the tab rather than clearing it. Non-project commands like `/todo`, `/review`, `/meta` should clear the project number since they have no associated project.

---

### 794. Establish sorry-free completeness theorems
- **Effort**: M
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Planned**: 2026-02-01
- **Started**: 2026-02-01
- **Completed**: 2026-02-01
- **Research**: [research-001.md](specs/794_sorry_free_completeness_theorems/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/794_sorry_free_completeness_theorems/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260201.md](specs/794_sorry_free_completeness_theorems/summaries/implementation-summary-20260201.md)

**Description**: Before archiving extraneous elements to produce a sorry-free metalogic, draw on specs/777_complete_weak_completeness_sorry/reports/research-007.md to identify and remove all sorries that remain in the way of a sorry-free completeness result. Establish weak_completeness and strong_completeness as well as the compactness theorem (all sorry-free) by drawing on semantic_weak_completeness and other established results, finding and filling in all sorries that stand in the way currently.

---

### 793. Fix Claude Code neovim sidebar black screen delay
- **Effort**: S
- **Status**: [RESEARCHED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/793_fix_claude_code_neovim_sidebar_black_screen/reports/research-001.md)

**Description**: Investigate and fix issue where running a command in Claude Code sidebar in neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. Functionality works correctly otherwise. Issue started recently. Root cause may be in hook system or external. Research online and review hook configuration to identify simple and elegant fix.

---

### 792. Review and document WezTerm tab integration with Neovim and Claude Code
- **Effort**: M
- **Status**: [COMPLETED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Planned**: 2026-02-01
- **Started**: 2026-02-01
- **Completed**: 2026-02-01
- **Research**: [research-001.md](specs/792_document_wezterm_tab_integration/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/792_document_wezterm_tab_integration/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260201.md](specs/792_document_wezterm_tab_integration/summaries/implementation-summary-20260201.md)

**Description**: Review and document WezTerm tab integration with Neovim and Claude Code. Update documentation in ProofChecker/.claude/, ~/.config/nvim/, and ~/.dotfiles/ following the documentation norms and standards in each location. Cover: OSC 7 directory updates (task 790), task number display (tasks 789, 791), tab coloring on Claude completion (task 788), and the interaction between shell hooks and Neovim autocmds.

---

### 791. Extend WezTerm task number integration for Claude Code commands
- **Effort**: S
- **Status**: [COMPLETED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Planned**: 2026-02-01
- **Started**: 2026-02-01
- **Completed**: 2026-02-01
- **Research**: [research-001.md](specs/791_wezterm_task_number_from_claude_commands/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/791_wezterm_task_number_from_claude_commands/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260201.md](specs/791_wezterm_task_number_from_claude_commands/summaries/implementation-summary-20260201.md)

**Description**: Extend WezTerm task number integration to parse Claude Code commands (/research, /plan, /implement, /revise) executed within Neovim and append task number to tab title. Currently the wezterm-task-number.sh hook parses commands from the shell prompt, but when running commands from within Neovim, the task number should also be extracted and displayed as "{tab} {project} #{task}". Requires investigating how to detect Claude Code command execution from Neovim and emit the appropriate user variable updates.

---

### 790. Add WezTerm OSC 7 integration to Neovim for tab title updates
- **Effort**: S
- **Status**: [COMPLETED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Planned**: 2026-02-01
- **Started**: 2026-02-01
- **Completed**: 2026-02-01
- **Research**: [research-001.md](specs/790_neovim_wezterm_osc7_tab_title/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/790_neovim_wezterm_osc7_tab_title/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260201.md](specs/790_neovim_wezterm_osc7_tab_title/summaries/implementation-summary-20260201.md)

**Description**: Add WezTerm OSC 7 integration to Neovim to update tab titles when neovim changes working directory. Currently tabs show the shell's cwd (e.g., "benjamin" when shell is in ~), but should show neovim's cwd (e.g., "ProofChecker" when nvim opens a project root). Solution: Add autocmd on DirChanged event to send OSC 7 sequences from neovim. Requires investigating the correct location in the neovim config structure and testing with nvim-tree and session management.

---

### 789. Configure WezTerm tab title to show project directory and task number
- **Effort**: S
- **Status**: [COMPLETED]
- **Language**: general
- **Created**: 2026-01-31
- **Researched**: 2026-01-31
- **Started**: 2026-01-31
- **Completed**: 2026-01-31
- **Research**: [research-001.md](specs/789_wezterm_tab_title_project_and_task_number/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/789_wezterm_tab_title_project_and_task_number/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260131.md](specs/789_wezterm_tab_title_project_and_task_number/summaries/implementation-summary-20260131.md)

**Description**: Configure WezTerm tab titles to show the project root directory name instead of `nvim ~`. The tab should display as `{tab_number} {project_name}` (e.g., `2 ProofChecker`). When running Claude Code commands with task numbers (`/research 788`, `/plan 788`, `/implement 788`), the tab should include the task number as `{tab_number} {project_name} #{task_number}` (e.g., `2 ProofChecker #788`). Commands without task numbers (`/todo`, `/meta`) should not append a task number. Additionally, when Claude finishes or needs input, the tab is colored (existing behavior works well), but the color should be cleared when the tab is opened/activated so that only unseen finished tabs remain colored. Active tabs should not be colored. WezTerm config is at `/home/benjamin/.dotfiles/config/wezterm.lua`.

---

### 788. Improve WezTerm tab coloring for Claude Code completion
- **Effort**: TBD
- **Status**: [COMPLETED]
- **Language**: general
- **Created**: 2026-01-31
- **Researched**: 2026-01-31
- **Planned**: 2026-01-31
- **Completed**: 2026-01-31
- **Research**: [research-001.md](specs/788_wezterm_tab_coloring_on_claude_completion/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/788_wezterm_tab_coloring_on_claude_completion/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260131.md](specs/788_wezterm_tab_coloring_on_claude_completion/summaries/implementation-summary-20260131.md)

**Description**: Improve WezTerm tab coloring for Claude Code completion notifications in neovim. Currently the tab is colored when Claude completes, but should only color if the tab is not already active, and the color should reset when the tab is opened. Config file is managed by home-manager in NixOS at /home/benjamin/.dotfiles/config/wezterm.lua.

---

### 787. Review metalogic progress and determine next steps
- **Effort**: 4 hours
- **Status**: [PLANNED]
- **Language**: lean
- **Created**: 2026-01-31
- **Researched**: 2026-01-31
- **Planned**: 2026-01-31
- **Research**: [research-001.md](specs/787_review_metalogic_progress/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/787_review_metalogic_progress/plans/implementation-001.md)

**Description**: Review the progress on completing Bimodal/Metalogic/ and determine what should be done next to establish the results sorry-free. Focus on avoiding redundancies and removing stray proofs that didn't work out.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
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

### 786. Migrate efq to efq_neg
- **Effort**: 30 minutes
- **Status**: [PLANNED]
- **Language**: lean
- **Created**: 2026-01-31
- **Planned**: 2026-02-01
- **Source**: Code review 2026-01-31
- **Research**: [research-001.md](specs/786_migrate_efq_to_efq_neg/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/786_migrate_efq_to_efq_neg/plans/implementation-001.md)

**Description**: Replace 2 deprecated efq references with efq_neg in Theories/Bimodal/Theorems/Propositional.lean at lines 402 and 596. The deprecated efq theorem should be replaced with efq_neg as indicated by build warnings.

---

### 777. Complete weak_completeness architectural sorry
- **Effort**: TBD
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-01-30
- **Researched**: 2026-02-01
- **Planned**: 2026-02-01
- **Started**: 2026-02-01
- **Completed**: 2026-02-01
- **Research**: [research-008.md](specs/777_complete_weak_completeness_sorry/reports/research-008.md)
- **Plan**: [implementation-001.md](specs/777_complete_weak_completeness_sorry/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260201.md](specs/777_complete_weak_completeness_sorry/summaries/implementation-summary-20260201.md)

**Description**: Complete the architectural sorry in weak_completeness. This is a bridging issue between two formulations of validity, and you should use semantic_weak_completeness for sorry-free completeness proofs.

---

### 685. Derive world-history and Barcan theorems
 **Effort**: 8-10 hours
 **Status**: [RESEARCHED]
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
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-28
- **Language**: meta
- **Created**: 2026-01-19
- **Blocked-By**: Empirically confirmed broken (research-005.md) - GitHub #16803
- **Research**: [research-001.md](specs/619_agent_system_architecture_upgrade/reports/research-001.md), [research-002.md](specs/619_agent_system_architecture_upgrade/reports/research-002.md), [research-003.md](specs/619_agent_system_architecture_upgrade/reports/research-003.md), [research-004.md](specs/619_agent_system_architecture_upgrade/reports/research-004.md), [research-005.md](specs/619_agent_system_architecture_upgrade/reports/research-005.md)
- **Plan**: [implementation-002.md](specs/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: FUTURE UPGRADE: Migrate agent system skills to use native `context: fork` frontmatter once Anthropic fixes GitHub issue #16803. Empirical testing (research-005.md) confirmed context:fork provides NO context isolation, NO tool restrictions, and NO subprocess isolation - the feature is completely non-functional. Current implementation (direct execution for Lean skills, Task delegation for others) is correct and should remain until context:fork is fixed and re-validated.


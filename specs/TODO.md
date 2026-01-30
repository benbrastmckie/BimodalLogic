---
next_project_number: 772
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-29T21:52:39Z
task_counts:
  active: 8
  completed: 317
  in_progress: 3
  not_started: 5
  abandoned: 23
  total: 341
priority_distribution:
  critical: 0
  high: 4
  medium: 4
  low: 5
technical_debt:
  sorry_count: 314
  axiom_count: 10
  build_errors: 0
  status: concerning
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

### 771. Improve Typst formatting to AMS journal style
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: typst
- **Created**: 2026-01-30
- **Researched**: 2026-01-30
- **Research**: [research-001.md](specs/771_improve_typst_formatting_ams_journal_style/reports/research-001.md)

**Description**: Improve formatting of BimodalReference.typ to match AMS-style professional mathematics journal appearance. Current formatting resembles a college textbook. Changes needed: remove all colors except for clickable links, adopt styling closer to BimodalReference.tex (LaTeX version). Apply systematic improvements across the entire Typst project.

---

### 770. Fix Claude Code Neovim sidebar 30-second delay
- **Effort**: 1 hour
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: general
- **Created**: 2026-01-30
- **Researched**: 2026-01-30
- **Planned**: 2026-01-30
- **Research**: [research-001.md](specs/770_fix_claude_code_neovim_sidebar_30s_delay/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/770_fix_claude_code_neovim_sidebar_30s_delay/plans/implementation-001.md)

**Description**: Claude Code sidebar has 30-second blank delay when opened from Neovim (no delay when opened directly in terminal). Already attempted fix: added claude-ready-signal.sh to SessionStart hooks in .claude/settings.json and verified hook is registered correctly. Despite this, Neovim's terminal-state.lua still waits ~30 seconds before sidebar becomes responsive, suggesting the SessionStart hook either isn't firing or the nvim --remote-expr signal isn't reaching Neovim. Need to debug: 1) whether hook actually executes (check logs), 2) whether $NVIM environment variable is set correctly in hook context, 3) whether nvim --remote-expr call succeeds, 4) whether on_claude_ready() is actually called in Neovim. May need to add debug logging to both claude-ready-signal.sh and terminal-state.lua to trace the signal path.

---

### 769. Address remaining sorries in Bimodal/Metalogic
- **Effort**: TBD
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Researched**: 2026-01-29
- **Planned**: 2026-01-29
- **Completed**: 2026-01-30
- **Research**: [research-001.md](specs/769_address_remaining_sorries_bimodal_metalogic/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/769_address_remaining_sorries_bimodal_metalogic/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260130.md](specs/769_address_remaining_sorries_bimodal_metalogic/summaries/implementation-summary-20260130.md)

**Description**: Address all remaining sorries in Bimodal/Metalogic/, excluding Examples/ and Boneyard/ directories. Goal is zero sorry count for the Metalogic/ directory.

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

### 760. Determine sorry disposition: archive vs complete
- **Effort**: 4-5 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Revised**: 2026-01-29
- **Research**: [research-001.md](specs/760_determine_sorry_disposition_archive_vs_complete/reports/research-001.md)
- **Plan**: [implementation-004.md](specs/760_determine_sorry_disposition_archive_vs_complete/plans/implementation-004.md)
- **Summary**: [implementation-summary-20260129.md](specs/760_determine_sorry_disposition_archive_vs_complete/summaries/implementation-summary-20260129.md)

**Description**: Archive sorried code to Boneyard (complementing completed Task 750). Targets: Examples/ exercise files (12 sorries), IndexedMCSFamily dead code (4), CoherentConstruction cross-origin (8), TaskRelation compositionality (5). Total: 29 sorries.

---

### 750. Refactor forward Truth Lemma to remove sorries and eliminate backward direction
- **Effort**: 8-10 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Research**: [research-005.md](specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-005.md), [research-006.md](specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-006.md), [research-008.md](specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-008.md), [research-011.md](specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-011.md), [research-012.md](specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-012.md)
- **Plan**: [implementation-006.md](specs/750_refactor_forward_truth_lemma_remove_sorries/plans/implementation-006.md)
- **Summary**: [implementation-summary-20260129-v2.md](specs/750_refactor_forward_truth_lemma_remove_sorries/summaries/implementation-summary-20260129-v2.md)

**Description**: Archive failed truth lemma approaches (MCSDerivedWorldState, AlgebraicSemanticBridge, HybridCompleteness) to Boneyard/Metalogic_v3/. Document `semantic_weak_completeness` as the canonical sorry-free completeness theorem. Clean historical mentions from primary Metalogic/ source files.

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

### 761. Integrate TTS and STT for Claude Code and neovim
- **Effort**: 4.5 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: general
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Summary**: [implementation-summary-20260129.md](specs/761_tts_stt_integration_for_claude_code_and_neovim/summaries/implementation-summary-20260129.md)

**Description**: Integrate TTS and STT capabilities: (1) TTS for Claude Code completion notifications - announce wezterm tab number and brief completion summary after 60-second delay when Claude finishes; (2) STT keymapping in neovim to trigger recording, process speech, and insert text at cursor. Requirements: NixOS-installable, free, fast, small footprint (no local LLM).

---

## Low Priority

### 768. Create Ctrl-Quote STT toggle for Claude Code sidebar in neovim
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: general
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Researched**: 2026-01-29
- **Planned**: 2026-01-30
- **Completed**: 2026-01-30
- **Research**: [research-001.md](specs/768_neovim_ctrl_backslash_stt_toggle_claude_code/reports/research-001.md), [research-002.md](specs/768_neovim_ctrl_backslash_stt_toggle_claude_code/reports/research-002.md)
- **Plan**: [implementation-001.md](specs/768_neovim_ctrl_backslash_stt_toggle_claude_code/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260130.md](specs/768_neovim_ctrl_backslash_stt_toggle_claude_code/summaries/implementation-summary-20260130.md)

**Description**: Create a `<C-'>` mapping in neovim config at `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/claudecode.lua` for use within the Claude Code sidebar terminal mode to toggle STT. Research confirmed `<C-\>` cannot be mapped in terminal mode (reserved by Neovim). Use `<C-'>` as the alternative binding, removing any existing `<C-\>` mappings that don't work.

---

### 767. Document TTS/STT integration and Claude Code keybinding resolution
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: general
- **Created**: 2026-01-29

**Description**: Comprehensive report documenting TTS/STT integration implementation and Claude Code keybinding resolution: (1) Initial STT plugin implementation with neotex.plugins.tools structure and which-key integration, (2) Bug fixes including module name collision (stt.lua to stt-plugin.lua) and WezTerm tab detection using position instead of tab_id, (3) Keybinding attempts with leader-vv for regular Neovim and Ctrl-backslash for Claude Code compatibility, (4) Research findings on Claude Code keybindings.json limitations and greggh/claude-code.nvim terminal mode requirements, (5) Final solution with buffer-local terminal mode keybinding in TermOpen autocmd for Claude Code sidebar. Documents all implementation attempts, debugging steps, and final working configuration for future reference.

---

### 766. Improve metalogic documentation ordering and add dependency flowchart
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: markdown
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Research**: [research-001.md](specs/766_improve_metalogic_documentation_ordering/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/766_improve_metalogic_documentation_ordering/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/766_improve_metalogic_documentation_ordering/summaries/implementation-summary-20260129.md)

**Description**: Improve the order in which the main metalogical results are presented in the documentation for Theories/Bimodal/Metalogic/ to correspond to the dependency structure. For instance, in Theories/Bimodal/Metalogic/README.md line 10, completeness is stated when it follows from representation which is below it. Find and fix all similar issues for improved consistency. Add the Algebraic module (currently in development) to support further results. Add a dependency flowchart for the metalogic as a whole.

---

### 764. Improve Bimodal/Metalogic structure and documentation
- **Effort**: 18-22 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: general
- **Created**: 2026-01-29
- **Started**: 2026-01-29
- **Completed**: 2026-01-29
- **Summary**: [implementation-summary-20260129.md](specs/764_improve_metalogic_structure_and_documentation/summaries/implementation-summary-20260129.md)

**Description**: Migrate ALL Boneyard dependencies to create self-contained Metalogic/: (1) full MCS theory migration (~500 lines), (2) full Soundness proof migration (~400 lines), (3) FMP/Closure fix, (4) document Algebraic/ as future extension, (5) comprehensive README documentation from deepest to top-level.

---


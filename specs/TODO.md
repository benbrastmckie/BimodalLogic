---
next_project_number: 618
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 12
  completed: 197
  in_progress: 1
  not_started: 7
  abandoned: 18
  total: 220
priority_distribution:
  critical: 0
  high: 6
  medium: 4
  low: 2
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 614. Refactor /cleanup command to /refresh
- **Effort**: 2-3 hours
- **Status**: [IMPLEMENTING]
- **Researched**: 2026-01-19
- **Started**: 2026-01-19
- **Research**: [research-001.md](specs/614_refactor_cleanup_to_refresh_command/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/614_refactor_cleanup_to_refresh_command/plans/implementation-001.md)
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19
- **Source**: Task 585 followup

**Description**: Refactor `/cleanup` command to `/refresh` with simplified two-mode interface:
1. `/refresh` - Show status and use AskUserQuestion to prompt user whether to clear orphaned processes
2. `/refresh --force` - Immediately clear all orphaned processes without asking

Changes required:
- Rename `.claude/commands/cleanup.md` to `refresh.md`
- Rename `.claude/skills/skill-cleanup/` to `skill-refresh/` with updated SKILL.md
- Rename `.claude/scripts/claude-cleanup.sh` to `claude-refresh.sh`
- Fix script bug where `set -euo pipefail` causes early exit after each kill operation
- Update CLAUDE.md references from `/cleanup` to `/refresh`
- Update or remove systemd timer and shell alias installations
- Remove `--status` and `--dry-run` flags (status always shown first)

---

### 585. Add Session Cleanup to Agents
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-19
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Research**: [research-001.md](specs/585_add_session_cleanup_to_agents/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/585_add_session_cleanup_to_agents/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/585_add_session_cleanup_to_agents/summaries/implementation-summary-20260119.md)

**Description**: Add explicit session cleanup stage to all agent return workflows. Before returning JSON result, agents should clear large context references from memory and log session completion. Add Stage 8 (Session Cleanup) to lean-implementation-agent, general-implementation-agent, latex-implementation-agent after their Stage 7 (Return Structured JSON). This reduces memory footprint before agent termination.

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

## Medium Priority

### 615. Fix closure_mcs_neg_complete double negation edge case
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Researched**: 2026-01-19
- **Related**: Task 608
- **Research**: [research-001.md](specs/615_fix_closure_mcs_neg_complete_double_negation/reports/research-001.md)

**Description**: Fix the sorry in `closure_mcs_neg_complete` at Closure.lean:484. The issue is a double negation edge case where `chi.neg.neg` (when `chi = psi.neg`) is not in `closureWithNeg`. Options include: (1) Restrict the theorem to `psi ∈ closure` instead of `closureWithNeg`, (2) Extend `closureWithNeg` to include double negations, or (3) Use a different approach in the truth lemma that avoids this case.

---

### 613. Revise Metalogic_v2 README architecture diagram
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-19
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Related**: Task 608
- **Research**: [research-001.md](specs/613_revise_metalogic_v2_readme_architecture_diagram/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/613_revise_metalogic_v2_readme_architecture_diagram/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/613_revise_metalogic_v2_readme_architecture_diagram/summaries/implementation-summary-20260119.md)

**Description**: Revise Theories/Bimodal/Metalogic_v2/README.md to be accurate and include a better diagram than the current 'Architecture Overview' section. The more fundamental theorems should come first (earlier line numbers) and the derived theorems should come later in the diagram, while reflecting all relationships accurately.

---

### 612. Improve system-overview.md with architecture patterns
- **Effort**: 3-4 hours
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-19
- **Related**: Task 609
- **Research**: [research-001.md](specs/612_improve_system_overview_docs_with_architecture/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/612_improve_system_overview_docs_with_architecture/plans/implementation-001.md)

**Description**: Improve .claude/context/core/architecture/system-overview.md to use unicode characters for diagrams AND document all command-skill and command-skill-agent architecture options. Current skills don't use context:fork so document what is used, noting differences and motivations for each approach used by different command types.

---

### 611. Context optimization and loading patterns
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Related**: Task 609
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Research**: [research-001.md](specs/611_context_optimization_and_loading_patterns/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/611_context_optimization_and_loading_patterns/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/611_context_optimization_and_loading_patterns/summaries/implementation-summary-20260119.md)

**Description**: Optimize context files created in task 609 for quality and concision. Improve organization, eliminate redundancy, and study how/where context is loaded throughout the command-skill-agent architecture. Ensure majority of context is loaded in agents, loading only what's needed progressively, and never loading unnecessary context.

---

### 610. Complete truth bridge (Strategy B) for completeness proof
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-19
- **Research**: [research-001.md](specs/610_complete_truth_bridge_strategy_b/reports/research-001.md)
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Related**: Task 608

**Description**: Complete Strategy B as documented in [research-001.md](specs/608_restructure_completeness_via_representation_theorem/reports/research-001.md). Prove `semantic_truth_implies_truth_at` via structural formula induction to bridge finite model truth (`w.models phi h_mem`) to general semantic truth (`truth_at M tau t phi`). This requires handling: Atom case (valuation check), Bot case (trivial), Imp case (IH on subformulas), Box case (show finite model T-axiom suffices for all histories), and Temporal cases (show behavior outside [-k, k] matches finite evaluation). This is the harder but more general approach that directly connects finite and general semantics.

---

### 609. Document command-skill-agent architecture
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Research**: [research-001.md](specs/609_document_command_skill_agent_architecture/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/609_document_command_skill_agent_architecture/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/609_document_command_skill_agent_architecture/summaries/implementation-summary-20260119.md)

**Description**: Research the current command-skill-agent architecture used throughout the .claude/ architecture to improve existing, or create new documentation in .claude/docs/ for users and .claude/context/core/ in appropriate subdirectories for the agent to draw from (e.g., the /meta command agents should have access to context that describes the architecture of the system in order to reproduce those elements when creating new functionality).

---

### 608. Restructure completeness proof via representation theorem
- **Status**: [COMPLETED]
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Related**: Task 470
- **Research**: [research-001.md](specs/608_restructure_completeness_via_representation_theorem/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/608_restructure_completeness_via_representation_theorem/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/608_restructure_completeness_via_representation_theorem/summaries/implementation-summary-20260119.md)

**Description**: Use Theories/Bimodal/Metalogic_v2/README.md which outlines the reorganization strategy to make the representation theorem the foundation from which completeness and decidability are derived, and study specs/470_finite_model_computational_optimization/summaries/implementation-summary-20260118.md to determine how best to proceed given the limitations encountered in order to finish restructuring the proof towards using the representation theorem to establish completeness.

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
- **Language**: general
- **Research**: [research-001.md](specs/431_wezterm_tab_color_notification/reports/research-001.md)

**Description**: Set up WezTerm tab color notification when Claude Code needs input. Using Claude Code in neovim via a plugin and WezTerm for the terminal on NixOS (software managed in ~/.dotfiles/). Configure so that when Claude Code completes or needs input, the numbered tab in WezTerm turns a visible color to indicate which tabs need attention.

---

### 605. Sync Plan Metadata Status with Task Status
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Research**: [research-001.md](specs/605_sync_plan_metadata_status_with_task_status/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/605_sync_plan_metadata_status_with_task_status/plans/implementation-002.md) (supersedes v1)
- **Summary**: [implementation-summary-20260119.md](specs/605_sync_plan_metadata_status_with_task_status/summaries/implementation-summary-20260119.md)

**Description**: Sync the **Status**: field in plan file metadata with the task status in TODO.md and state.json. Currently, implementation plans have a Status field in their YAML-like header (e.g., **Status**: [NOT STARTED]) that is not updated when the task progresses through research/plan/implement cycles. Update the preflight/postflight patterns in implementation skills to also update this status field in the plan file when task status changes.

---

## Low Priority

### 616. Fix semantic_task_rel_compositionality finite model limitation
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-19
- **Related**: Task 608

**Description**: Fix the sorry in `semantic_task_rel_compositionality` at SemanticCanonicalModel.lean:236. The issue is that task relation compositionality fails for unbounded duration sums in the finite model (time bounds are [-k, k]). Options include: (1) Add a boundedness hypothesis requiring |d1 + d2| <= 2k, (2) Change the task relation definition to be closed under composition, or (3) Use a different frame construction. Note: The completeness proof doesn't directly use this lemma, so this is an acceptable limitation.

---

### 617. Fix closure_mcs_implies_locally_consistent temporal axioms
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-19
- **Related**: Task 608

**Description**: Fix the sorry in `closure_mcs_implies_locally_consistent` at FiniteWorldState.lean:343. The issue is that proving local consistency requires temporal reflexivity axioms (H φ → φ, G φ → φ) which don't hold in TM logic's strict temporal semantics. Options include: (1) Add explicit reflexivity conditions to the local consistency definition, (2) Use a different construction that bypasses temporal reflexivity, or (3) Document as an architectural limitation. Note: The semantic approach via SemanticCanonicalModel bypasses this issue entirely.

---

### 470. Finite model computational optimization
- **Status**: [IMPLEMENTING]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458
- **Research**: [research-001.md](specs/470_finite_model_computational_optimization/reports/research-001.md), [research-002.md](specs/470_finite_model_computational_optimization/reports/research-002.md)

**Description**: Optimize FiniteCanonicalModel.lean for computational efficiency. Current implementation prioritizes correctness over performance. Identify and implement optimizations for the finite world state enumeration, task relation checking, and truth evaluation.

---

### 490. Complete decidability procedure
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 469

**Description**: Complete the decidability procedure for TM logic. The existing Decidability module has tableau infrastructure but needs: proof extraction from closed tableaux, completeness proof connecting to FMP, and full decide function verification. Extends Task 469.

---

### 606. Fix Metalogic_v2 README accuracy
- **Effort**: 30 minutes
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Completed**: 2026-01-19
- **Source**: Code Review 2026-01-18 (H2)
- **Research**: [research-001.md](specs/606_fix_metalogic_v2_readme_accuracy/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/606_fix_metalogic_v2_readme_accuracy/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/606_fix_metalogic_v2_readme_accuracy/summaries/implementation-summary-20260119.md)

**Description**: Update Metalogic_v2/README.md to accurately document the sorry count and locations. Current README incorrectly claims "All theorems in Metalogic_v2 are fully proven with no sorry statements" but there are 7 active sorries in the semantic bridge infrastructure. Document which theorems have sorries, their locations, and impact on downstream theorems.

---

### 607. Port Decidability to Metalogic_v2
- **Effort**: 8-12 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Source**: Code Review 2026-01-18 (M1)
- **Dependencies**: Task 470

**Description**: Port the Decidability/ infrastructure from old Metalogic/ to Metalogic_v2/ architecture. The old Decidability/ has 8 files (Tableau, SignedFormula, Saturation, DecisionProcedure, ProofExtraction, CountermodelExtraction, Correctness, Closure) totaling 61KB. Integrate with FMP as the bridge theorem following the representation-first architecture.

---

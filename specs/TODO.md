---
next_project_number: 652
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 20
  completed: 231
  in_progress: 0
  not_started: 13
  abandoned: 19
  total: 253
priority_distribution:
  critical: 0
  high: 6
  medium: 10
  low: 6
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 650. Implement completion_summary and claudemd_suggestions fields in /implement workflow
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-20
- **Researched**: 2026-01-20
- **Planned**: 2026-01-20
- **Research**: [research-001.md](specs/650_implement_completion_summary_claudemd_suggestions_fields/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/650_implement_completion_summary_claudemd_suggestions_fields/plans/implementation-002.md)

**Description**: Make sure that the /implement command-skill-agent workflow will include completion_summary and claudemd_suggestions fields for updating ROAD_MAP.md and CLAUDE.md when appropriate and not otherwise since these will be used by the /todo command.

---

### 646. Fix Metalogic LaTeX formatting and structure issues
- **Status**: [PLANNING]
- **Priority**: High
- **Language**: latex
- **Created**: 2026-01-20
- **Researched**: 2026-01-20
- **Research**: [research-001.md](specs/646_fix_metalogic_latex_formatting_issues/reports/research-001.md)

**Description**: Fix 14 FIX:/NOTE: tags in Theories/Bimodal/latex/subfiles/04-Metalogic.tex covering formatting, structural, and presentation improvements: (1) make negation completeness a definition, (2) merge footnote with explanation for Lindenbaum's lemma, (3) introduce histories/times before canonical world states, (4) define quotient construction, (5) explain strong representation theorem, (6) remove diagram labels and add reference, (7) merge finite model property into decidability section, (8) clarify decision procedure return values, (9) explain tableau concepts and Lean 4 proof search, (10) add context for complexity values, (11) explain why decidability is useful despite limitations, (12) use standardized `\texttt{}` formatting for Lean directories, (13) format directory names in bold with `\texttt{}`, (14) make theorem names italic.

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
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

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

### 651. Simplify /learn NOTE: tag workflow
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-20

**Description**: Simplify the /learn command workflow so that learn-it tasks focus only on improving relevant context files and documentation, leaving NOTE: tags in place. The fix-it task created by /learn should then address and remove both NOTE: and FIX: tags when making file changes, while leaving TODO: tags behind for todo tasks. This removes the unnecessary NOTE: to FIX: tag replacement from learn-it tasks.

---

### 649. Improve /learn NOTE: tag dependency handling
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-20
- **Researched**: 2026-01-20
- **Planned**: 2026-01-20
- **Started**: 2026-01-20
- **Completed**: 2026-01-20
- **Research**: [research-001.md](specs/649_improve_learn_note_tag_dependency_handling/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/649_improve_learn_note_tag_dependency_handling/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260120.md](specs/649_improve_learn_note_tag_dependency_handling/summaries/implementation-summary-20260120.md)

**Description**: Improve the /learn command so that if 'NOTE:' tags occur, that the fix-it task has the learn-it task as a dependency so that the learn-it task is completed first. Also, the learn-it task itself should replace all 'NOTE:' instances with 'FIX:' so that the fix-it task can then make the file local changes and the learn-it task can focus on updating context files (clear division of labor).

---

### 647. Update context files for LaTeX theorem naming and formatting standards
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-20
- **Completed**: 2026-01-20
- **Research**: [research-001.md](specs/647_update_context_latex_theorem_naming_standards/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/647_update_context_latex_theorem_naming_standards/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260120.md](specs/647_update_context_latex_theorem_naming_standards/summaries/implementation-summary-20260120.md)

**Description**: Update .claude/context/ files to document LaTeX theorem naming and formatting standards based on 4 NOTE: tags from 04-Metalogic.tex: (1) make theorem names italic (e.g., 'Representation Theorem' in italics), (2) state definitions before using them (e.g., task relation definition needed before canonical frame), (3) reference Lean theorem names in the theorem environment itself (e.g., replace footnotes with inline `\texttt{representation_theorem}` references), (4) use standardized `\texttt{Metalogic_v2}` formatting for Lean directories throughout. Target context files: .claude/rules/latex.md or create new .claude/context/project/latex/standards.md.

---

### 648. Research canonical frame temporal order generalization
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-20

**Description**: Research how to generalize the canonical frame construction to use ANY totally ordered commutative group for temporal order instead of integers. Current approach uses integers which makes time discrete, but the semantics definition specifies frames should work with any totally ordered commutative group. This is the crux of the proof strategy for completeness and needs careful thinking and research. From TODO tag at Theories/Bimodal/latex/subfiles/04-Metalogic.tex:125.

---


### 639. Improve /review roadmap matching reliability
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-20

**Description**: Improve the reliability of ROAD_MAP.md checkbox matching in the /review command. Current issues: (1) Fuzzy title matching is unreliable, (2) No explicit task-to-roadmap mapping exists, (3) Task 637 had to be manually created to fix checkboxes. Solutions: (1) Add `roadmap_items` field to state.json entries for explicit task-roadmap linking, (2) Update /review to use explicit mappings first, fall back to fuzzy matching, (3) Update /task create to optionally specify linked roadmap items, (4) Improve fuzzy matching heuristics.

---

### 630. Build TaskModel extraction from saturated tableau branches
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Parent**: Task 490
- **Dependencies**: Task 623
- **Related**: Tasks 624, 628

**Description**: Build infrastructure to extract a proper TaskModel from a saturated open tableau branch. The bimodal logic TM uses **task frame semantics** (NOT standard Kripke semantics): TaskFrame `F = (W, D, ·)` with world states, temporal duration type D, and task relation satisfying nullity/compositionality; WorldHistory `τ: X → W` as functions from convex time domains to states; Box `□φ` quantifies over ALL world histories at time t (not worlds via accessibility relation); Temporal `Hφ`/`Gφ` quantify over ALL times in D. Currently `evalFormula` (CountermodelExtraction.lean:158-164) treats modal/temporal operators as identity. This task: (1) Extract WorldState type from branch, (2) Define task relation from modal constraints, (3) Build WorldHistory structure, (4) Prove extracted TaskFrame satisfies nullity and compositionality. Unblocks Phase 3 of Task 623 and enables Task 624 (tableau_complete).

---

### 631. Prove evalFormula_implies_satisfiable bridging lemma
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Parent**: Task 490
- **Dependencies**: Task 630
- **Related**: Tasks 624, 628

**Description**: Prove the semantic bridge lemma `evalFormula_implies_sat`: if `evalFormula b φ = false` for a saturated open branch, then φ is not satisfiable in the extracted TaskModel. This connects the simplified propositional evaluation in `evalFormula` to full task frame semantics via `truth_at M τ t φ`. Uses the TaskModel extraction from Task 630. Key insight: must show that for the extracted model M with some WorldHistory τ and time t, `truth_at M τ t φ = false`. Combined with `branchTruthLemma` (completed in Task 623), this provides the contrapositive needed for `tableau_complete`: valid formulas cannot have open saturated branches.

---

### 628. Prove semantic_truth_implies_truth_at (upward bridge) for FMP generalization
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-20
- **Related**: Tasks 610, 627, 470
- **Research**: [research-001.md](specs/628_prove_semantic_truth_implies_truth_at_upward_bridge/reports/research-001.md)

**Description**: Prove the "upward" bridge `semantic_truth_implies_truth_at` showing finite model truth implies general `truth_at` semantics. This completes `finite_model_property_constructive` by proving the FMP witness is compatible with arbitrary external model frameworks. NOT on critical path - completeness is handled by task 627 (downward bridge), and decidability only needs the cardinality bound. This is for theoretical completeness and generalization to external semantics. Task 610 contains research on the structural induction approach (Atom/Bot/Imp/Box/Temporal cases). The challenge is Box (quantification over all WorldHistories) and Temporal (behavior outside finite time bounds).

---

### 619. Agent system architecture upgrade (context:fork migration)
- **Status**: [PLANNED]
- **Researched**: 2026-01-19
- **Priority**: Low
- **Language**: meta
- **Created**: 2026-01-19
- **Blocked-By**: GitHub #16803 (context:fork bug)
- **Research**: [research-001.md](specs/619_agent_system_architecture_upgrade/reports/research-001.md), [research-002.md](specs/619_agent_system_architecture_upgrade/reports/research-002.md)
- **Plan**: [implementation-002.md](specs/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: FUTURE UPGRADE: Migrate agent system skills to use native `context: fork` frontmatter once Anthropic fixes GitHub issue #16803. Research-002.md confirmed context:fork IS a real feature (added v2.1.0) but is currently broken. Current Task tool delegation pattern is correct and should remain until the bug is fixed. When fixed, migrate skills to use `context: fork` + `agent:` frontmatter for cleaner context isolation.

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

### 616. Fix semantic_task_rel_compositionality finite model limitation
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-19
- **Related**: Task 608
- **Research**: [research-001.md](specs/616_fix_semantic_task_rel_compositionality_sorry/reports/research-001.md)

**Description**: Fix the sorry in `semantic_task_rel_compositionality` at SemanticCanonicalModel.lean:236. The issue is that task relation compositionality fails for unbounded duration sums in the finite model (time bounds are [-k, k]). Options include: (1) Add a boundedness hypothesis requiring |d1 + d2| <= 2k, (2) Change the task relation definition to be closed under composition, or (3) Use a different frame construction. Note: The completeness proof doesn't directly use this lemma, so this is an acceptable limitation.

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
- **Plan**: [implementation-001.md](specs/490_complete_decidability_procedure/plans/implementation-001.md)
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
- **Plan**: [implementation-002.md](specs/623_build_fmp_tableau_connection_infrastructure/plans/implementation-002.md)

**Description**: Build infrastructure connecting FMP bounds to tableau semantics. Phases 1-2.3 and 4 completed (expansion/saturation lemmas, branchTruthLemma). Phase 3 blocked on semantic bridge gap. Expanded into Tasks 630 (Kripke model extraction) and 631 (evalFormula_implies_sat lemma) to address the blocker.

---

### 624. Prove tableau_complete
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 490
- **Dependencies**: Task 623

**Description**: Prove the `tableau_complete` theorem in Correctness.lean connecting FMP to tableau termination. Uses infrastructure from Task 623 to show that valid formulas have closing tableaux within FMP fuel bounds.

---

### 625. Prove decide_complete
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 490
- **Dependencies**: Task 624

**Description**: Prove the `decide_complete` theorem in Correctness.lean deriving decision procedure completeness from tableau completeness. Follows directly from tableau_complete (Task 624).

---

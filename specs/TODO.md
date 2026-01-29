---
next_project_number: 732
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 16
  completed: 293
  in_progress: 4
  not_started: 8
  abandoned: 21
  total: 319
priority_distribution:
  critical: 0
  high: 6
  medium: 9
  low: 5
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 697. Fix UniversalCanonicalModel.lean compilation error
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: lean
- **Created**: 2026-01-28
- **Completed**: 2026-01-29
- **Source**: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:413
- **Research**: [research-001.md](specs/697_fix_universalcanonicalmodel_compilation_error/reports/research-001.md), [research-002.md](specs/697_fix_universalcanonicalmodel_compilation_error/reports/research-002.md)
- **Plan**: [implementation-002.md](specs/697_fix_universalcanonicalmodel_compilation_error/plans/implementation-002.md)
- **Summary**: [implementation-summary-20260129.md](specs/697_fix_universalcanonicalmodel_compilation_error/summaries/implementation-summary-20260129.md)

**Description**: Fix the reflexive/irreflexive semantics mismatch in TruthLemma.lean. Semantics use `s ≤ t` but coherence conditions use `s < t`. Fix by splitting proof cases with `eq_or_lt_of_le` and using T-axiom closure lemmas for the reflexive case. Plan revised post-726 (MCS lemma reorganization).

---

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
- **Status**: [PLANNED]
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
- **Status**: [PLANNED]
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

### 731. Clean Bimodal documentation - remove historical comments
- **Effort**: 4-6 hours
- **Status**: [PLANNING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-28
- **Related**: Task 681
- **Research**: [research-001.md](specs/731_clean_bimodal_documentation_remove_historical_comments/reports/research-001.md)

**Description**: Clean up Lean source code documentation in Bimodal/ theory to present only the current state with no historical mentions. **Scope change**: Remove ALL historical artifacts including: (1) provenance comments (`-- Origin: Boneyard/...`) from Core/*.lean files, (2) SUPERSEDED/DEPRECATED docblocks and markers, (3) narrative history explaining past approaches or "why we did X instead of Y", (4) references to Boneyard in active code comments. Goal is clean, present-tense documentation describing what the code IS, not where it came from or what it replaced. Also: (a) update remaining Boneyard imports in GeneralizedNecessitation.lean and Propositional.lean to use Core, (b) move compatibility shims Metalogic.lean and Metalogic_v2.lean to Boneyard/Compat/, (c) verify complete Boneyard isolation.

---

### 726. Move essential MCS lemmas to Core
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-28
- **Started**: 2026-01-28
- **Completed**: 2026-01-29
- **Parent**: Task 722
- **Research**: [research-001.md](specs/726_move_essential_mcs_lemmas_to_core/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/726_move_essential_mcs_lemmas_to_core/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260129.md](specs/726_move_essential_mcs_lemmas_to_core/summaries/implementation-summary-20260129.md)

**Description**: Move 5 essential MCS lemmas from deprecated `Boneyard/Metalogic/Completeness.lean` to the canonical Core location (`Boneyard/Metalogic_v2/Core/MaximalConsistent.lean`). Lemmas to move: `set_mcs_closed_under_derivation`, `set_mcs_implication_property`, `set_mcs_negation_complete`, `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`. Dependencies like `deduction_theorem` and `derivation_exchange` must move first. Update re-exports in `Metalogic/Core/MaximalConsistent.lean`. Deferred from Task 722 Phase 3.

---

### 727. Consolidate set_lindenbaum duplicates
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-28
- **Completed**: 2026-01-29
- **Parent**: Task 722
- **Dependencies**: Task 726 (COMPLETED)
- **Research**: [research-001.md](specs/727_consolidate_set_lindenbaum/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/727_consolidate_set_lindenbaum/plans/implementation-002.md)
- **Summary**: [implementation-summary-20260129.md](specs/727_consolidate_set_lindenbaum/summaries/implementation-summary-20260129.md)

**Description**: Remove duplicate `set_lindenbaum` theorem definitions from deprecated Boneyard/Metalogic/ files when those files are fully deprecated. Current duplicates: `Boneyard/Metalogic/Completeness.lean:360` and `Boneyard/Metalogic/Representation/CanonicalModel.lean:139`. Canonical source is `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:290`, re-exported via `Metalogic/Core/MaximalConsistent.lean`. Deferred from Task 722 Phase 4.

---

### 700. Research algebraic representation theorem proof
- **Effort**: 12-16 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-28
- **Started**: 2026-01-29
- **Source**: specs/ROAD_MAP.md:291
- **Research**: [research-001.md](specs/700_research_algebraic_representation_theorem_proof/reports/research-001.md), [research-002.md](specs/700_research_algebraic_representation_theorem_proof/reports/research-002.md), [research-003.md](specs/700_research_algebraic_representation_theorem_proof/reports/research-003.md)
- **Plan**: [implementation-001.md](specs/700_research_algebraic_representation_theorem_proof/plans/implementation-001.md)

**Description**: Develop a purely algebraic approach to the representation theorem as an alternative to the current seed-extension approach. Leverages reflexive G/H semantics to show temporal operators form interior operators on the Lindenbaum-Tarski algebra. All algebraic infrastructure isolated in `Metalogic/Algebraic/` for clean removal if approach fails.

---

### 685. Derive world-history and Barcan theorems
- **Effort**: 8-10 hours
- **Status**: [PLANNING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-26
- **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---

### 658. Prove indexed family coherence conditions
- **Status**: [PLANNED]
- **Session**: sess_1769645980_03ade5
- **Effort**: 45 min - 1 hour
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Planned**: 2026-01-29 (v6)
- **Dependencies**: Task 681 (COMPLETED), Task 697 (COMPLETED)
- **Related**: Task 654, Task 657, Task 700
- **Source**: Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean:550-603
- **Plan**: [implementation-006.md](specs/658_prove_indexed_family_coherence_conditions/plans/implementation-006.md)
- **Research**: [research-001.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-001.md), [research-002.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-002.md), [research-003.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-003.md), [research-004.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-004.md)
- **Summary**: [implementation-summary-20260128.md](specs/658_prove_indexed_family_coherence_conditions/summaries/implementation-summary-20260128.md)

**Description**: Trace the actual construction path from `representation_theorem` to verify it uses the coherent construction (Task 681). Task 697 fixed TruthLemma.lean's usage of the coherence conditions, confirming they're actively used. This task ensures the sorry-free path (via `construct_coherent_family`) is actually invoked.

**Current Status**: Tasks 681 and 697 completed. Need to trace dependency chain from representation_theorem and ensure coherent construction is used.

---

### 660. Prove parametric completeness theorems
- **Effort**: 10-15 hours
- **Status**: [PLANNING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Dependencies**: Tasks 656, 657, 658
- **Related**: Task 654

**Description**: Use the representation theorem from Task 654 to prove weak and strong completeness for TM logic over arbitrary ordered additive groups. The representation theorem establishes that consistent formulas are satisfiable in the parametric canonical model. This task completes the metalogic by deriving completeness: (1) Weak completeness: if ⊨ φ then ⊢ φ, (2) Strong completeness: if Γ ⊨ φ then Γ ⊢ φ. Builds on the foundation established by Tasks 656-658. From review-20260121-task654.md future work section.

---

### 630. Build TaskModel extraction from saturated tableau branches
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Parent**: Task 490
- **Dependencies**: Task 623
- **Related**: Tasks 624, 628
- **Research**: [research-001.md](specs/630_build_taskmodel_extraction_from_saturated_branches/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/630_build_taskmodel_extraction_from_saturated_branches/plans/implementation-001.md)

**Description**: Build infrastructure to extract a proper TaskModel from a saturated open tableau branch. The bimodal logic TM uses **task frame semantics** (NOT standard Kripke semantics): TaskFrame `F = (W, D, ·)` with world states, temporal duration type D, and task relation satisfying nullity/compositionality; WorldHistory `τ: X → W` as functions from convex time domains to states; Box `□φ` quantifies over ALL world histories at time t (not worlds via accessibility relation); Temporal `Hφ`/`Gφ` quantify over ALL times in D. Currently `evalFormula` (CountermodelExtraction.lean:158-164) treats modal/temporal operators as identity. This task: (1) Extract WorldState type from branch, (2) Define task relation from modal constraints, (3) Build WorldHistory structure, (4) Prove extracted TaskFrame satisfies nullity and compositionality. Unblocks Phase 3 of Task 623 and enables Task 624 (tableau_complete).

---

### 631. Prove evalFormula_implies_satisfiable bridging lemma
- **Status**: [PLANNING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Parent**: Task 490
- **Dependencies**: Task 630
- **Related**: Tasks 624, 628

**Description**: Prove the semantic bridge lemma `evalFormula_implies_sat`: if `evalFormula b φ = false` for a saturated open branch, then φ is not satisfiable in the extracted TaskModel. This connects the simplified propositional evaluation in `evalFormula` to full task frame semantics via `truth_at M τ t φ`. Uses the TaskModel extraction from Task 630. Key insight: must show that for the extracted model M with some WorldHistory τ and time t, `truth_at M τ t φ = false`. Combined with `branchTruthLemma` (completed in Task 623), this provides the contrapositive needed for `tableau_complete`: valid formulas cannot have open saturated branches.

---

### 628. Prove semantic_truth_implies_truth_at (upward bridge) for FMP generalization
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-20
- **Related**: Tasks 610, 627, 470
- **Research**: [research-001.md](specs/628_prove_semantic_truth_implies_truth_at_upward_bridge/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/628_prove_semantic_truth_implies_truth_at_upward_bridge/plans/implementation-001.md)

**Description**: Prove the "upward" bridge `semantic_truth_implies_truth_at` showing finite model truth implies general `truth_at` semantics. This completes `finite_model_property_constructive` by proving the FMP witness is compatible with arbitrary external model frameworks. NOT on critical path - completeness is handled by task 627 (downward bridge), and decidability only needs the cardinality bound. This is for theoretical completeness and generalization to external semantics. Task 610 contains research on the structural induction approach (Atom/Bot/Imp/Box/Temporal cases). The challenge is Box (quantification over all WorldHistories) and Temporal (behavior outside finite time bounds).

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

### 616. Remove false theorem semantic_task_rel_compositionality
- **Status**: [IMPLEMENTING]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-19
- **Related**: Task 608
- **Research**: [research-001.md](specs/616_remove_false_semantic_task_rel_compositionality/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/616_remove_false_semantic_task_rel_compositionality/plans/implementation-001.md)

**Description**: Remove the mathematically false theorem semantic_task_rel_compositionality and its sorry from SemanticCanonicalModel.lean. Research confirmed this theorem cannot be proven (unbounded duration sums exceed finite time domain), and it is not needed for the completeness proof which uses a different approach. Remove the false claim rather than accepting a sorry for an unprovable statement.

---

### 659. Prove negation completeness lemmas
- **Effort**: 6-10 hours
- **Status**: [PLANNING]
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-21
- **Related**: Tasks 654, 656
- **Source**: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:211,219,228,237

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

### 668. Create specs path migration script
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: meta
- **Session**: meta-session-1768239500
- **Dependencies**: 667
- **Planned**: 2026-01-21
- **Plan**: [implementation-001.md](specs/668_create_specs_path_migration_script/plans/implementation-003.md)

**Description**: Create automated Python script to detect and migrate .opencode/specs path references to specs/. Script will include safety checks, dry-run mode, backup creation, and detailed reporting. Will serve as fix for current issue and preventative tool for future migrations.

---

### 669. Test task creation system
- **Status**: [PLANNED]
- **Priority**: Low
- **Language**: meta
- **Session**: test-session-1768239500
- **Planned**: 2026-01-21
- **Plan**: [implementation-001.md](specs/669_test_task_creation/plans/implementation-003.md)

**Description**: Simple test to verify that task creation system is working after fixing .opencode/specs path references. Validates that the path reference fixes resolved the task creation issues.

---


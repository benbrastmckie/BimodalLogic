---
next_project_number: 689
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 29
  completed: 250
  in_progress: 0
  not_started: 19
  abandoned: 21
  total: 281
priority_distribution:
  critical: 0
  high: 5
  medium: 15
  low: 9
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 688. Add zombie cleanup and timeout protection to lean implementation skill
- **Effort**: 5 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Research**: [research-001.md](specs/688_add_zombie_cleanup_timeout_protection_lean_skill/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/688_add_zombie_cleanup_timeout_protection_lean_skill/plans/implementation-001.md)

**Description**: Add pre-flight zombie process cleanup and timeout protection to skill-lean-implementation to prevent MCP-induced hangs from accumulating zombie lake processes and causing indefinite agent stalls. The lean-lsp MCP server spawns lake subprocesses that become zombies when not properly reaped, causing MCP tool calls to hang indefinitely. Fix by: (1) adding pre-flight cleanup in Stage 2 to kill zombie lake processes before invoking subagent, (2) adding timeout parameter to Task tool invocation in Stage 5 to force-kill hung agents, (3) optionally adding age-based deadlock detection to postflight hook.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
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
- **Status**: [IMPLEMENTING]
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

### 686. Fix agent interruption MCP abort errors
- **Effort**: 8-12 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-26
- **Related**: 619, 672, 674
- **Research**: [research-001.md](specs/686_fix_agent_interruption_mcp_abort_errors/reports/research-001.md)

**Description**: Fix agent system interruption failures where MCP tool calls return AbortError (-32001) and agents get stuck at "Interrupted" prompt. Root cause analysis from `/research 657` and `/implement 630` failures shows: (1) lean-research-agent interrupted during lean_local_search calls, (2) lean-implementation-agent interrupted during lean_diagnostic_messages call. Both agents failed to write return metadata files, leaving tasks stuck in researching/implementing status. System improvements needed: error recovery for MCP tool failures, graceful interruption handling, partial progress preservation, and metadata file writing on timeout/abort.

---

### 682. Fix dynamics foundation LaTeX issues
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: latex
- **Created**: 2026-01-26
- **Completed**: 2026-01-26
- **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (11 FIX: tags)
- **Research**: [research-001.md](specs/682_fix_dynamics_foundation_latex_issues/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/682_fix_dynamics_foundation_latex_issues/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260126.md](specs/682_fix_dynamics_foundation_latex_issues/summaries/implementation-summary-20260126.md)

**Description**: Fix 11 LaTeX formatting and structural issues in 03-DynamicsFoundation.tex: (1) line 38: define well-formed sentences using standard BNF notation with double colon and pipes; (2) line 58: include more derived symbols; (3) line 104: rename 'core frame' to 'dynamical frame'; (4) lines 131, 144: convert definitions to dependent type theory notation for consistency with Lean; (5) line 153: improve world-state definition using dependent type theory; (6) line 190: research Containment subsection to restate world-history as maximal possible evolution; (7) line 202: update notation to use dependent type theory consistently; (8) line 224: restate interpretation definition from Constitutive Foundation; (9) line 248: convert remark to theorem for Lean implementation; (10) line 270: define \forall v \metaA(v) as \forall (\lambda v_1. \metaA)(v_2); (11) lines 303, 312, 322, 333: restructure to give semantic clauses only for primitives, introduce stability operator, move derived operators to definitions section; (12) lines 352, 374: move operator readings to primitive symbol introduction; (13) line 368: define \altworlds in terms of imposition.

---

### 690. Fix constitutive foundation LaTeX issues
- **Status**: [RESEARCHED]
- **Research**: [research-001.md](specs/690_fix_constitutive_foundation_latex_issues/reports/research-001.md)
- **Started**: 2026-01-26T19:51:02Z
- **Effort**: 2-3 hours
- **Priority**: High
- **Language**: latex
- **Created**: 2026-01-26
- **Dependencies**: 689
- **Source**: Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex (2 FIX:, 1 NOTE: tags)

**Description**: Fix LaTeX formatting issues in 02-ConstitutiveFoundation.tex based on FIX: and NOTE: tags: (1) line 49: Combine material conditional, biconditional definitions, and quantifier notation into single definition setting metalinguistic conventions (syntactic sugar) for the language; (2) line 406: Precisely define identity sentences in both Lean source and LaTeX, where inductive definition is in terms of well-formed sentences but takes identity sentences to be atomic; (3) line 21 (NOTE): Update variable notation from x, y, z to v_1, v_2, v_3, ... for object language (x, y, z reserved for metalanguage durations). Source: Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex

---

## Medium Priority

### 683. Update context from dynamics foundation notes
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-26
- **Started**: 2026-01-26T20:14:03Z
- **Completed**: 2026-01-26
- **Dependencies**: 682
- **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 NOTE: tags)
- **Research**: [research-001.md](specs/683_update_context_from_dynamics_foundation_notes/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/683_update_context_from_dynamics_foundation_notes/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260126.md](specs/683_update_context_from_dynamics_foundation_notes/summaries/implementation-summary-20260126.md)

**Description**: Update .claude/context/ files based on 2 NOTE: tags from 03-DynamicsFoundation.tex: (1) line 214: Update LaTeX patterns context to use italics for defining terms instead of named definitions like '[Dynamical Model]'; (2) line 257: Update variable naming convention documentation to reserve x, y, z for metalanguage times and use v_1, v_2, v_3, ... for first-order variables in Logos system.

---

### 684. Revise semantics and notation conventions
- **Effort**: 4-5 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: latex
- **Created**: 2026-01-26
- **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)
- **Started**: 2026-01-26T18:00:00Z
- **Research**: [research-001.md](specs/684_revise_semantics_and_notation_conventions/reports/research-001.md)

**Description**: Systematically revise dynamical semantics and notation conventions in 03-DynamicsFoundation.tex based on 2 grouped TODO items: (1) line 235: Revise dynamical semantics to evaluate sentences at model, evolutions, time, variable assignment, and temporal index, using \tau for evolutions; (2) line 259: Clean up lambda abstraction and quantification conventions where lambdas bind the last free variable (if any) and universal quantifiers quantify the last open variable (if any), researching careful conventions and definitions to match Lean code.

---

### 685. Derive world-history and Barcan theorems
- **Effort**: 8-10 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-26
- **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---

### 689. Update context from constitutive foundation notes
- **Effort**: 1 hour
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-26
- **Source**: Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex (1 NOTE: tag)

**Description**: Update .claude/context/ files based on NOTE: tag from 02-ConstitutiveFoundation.tex line 21: Update variable naming convention documentation to reserve x, y, z for metalanguage durations and use v_1, v_2, v_3, ... for object language variables in Logos system.

---

### 681. Redesign construct_indexed_family with coherent approach
- **Effort**: 14 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-25
- **Researched**: 2026-01-25T22:26:00Z
- **Planned**: 2026-01-25T22:32:00Z
- **Related**: Task 658
- **Research**: [research-001.md](specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/681_redesign_construct_indexed_family_coherent_approach/plans/implementation-001.md)

**Description**: Overcome the blocked status of 658 by redesigning construct_indexed_family using a coherent construction approach (similar to Boneyard's canonical_task_rel pattern), or research alternative approaches.

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

### 656. Complete truth lemma forward direction (imp/box cases)
- **Status**: [PLANNED]
- **Effort**: 10 hours
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](specs/656_complete_truth_lemma_forward_direction/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/656_complete_truth_lemma_forward_direction/plans/implementation-001.md)
- **Created**: 2026-01-21
- **Planned**: 2026-01-26
- **Related**: Task 654
- **Source**: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:144,155

**Description**: Complete the imp and box cases in the truth lemma forward direction for the parametric canonical model. The imp case (line 144) requires proving MCS modus ponens closure. The box case (line 155) requires witness construction for modal accessibility. These gaps don't affect the main representation theorem but are needed for a complete truth lemma biconditional. From review-20260121-task654.md recommendations.

---

### 657. Prove seed consistency (temporal K distribution)
- **Started**: 2026-01-25T20:53:16Z
- **Effort**: 6-8 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Related**: Task 654
- **Source**: Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean:338,354
- **Research**: [research-001.md](specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/657_prove_seed_consistency_temporal_k_distribution/plans/implementation-001.md)

**Description**: Prove the seed consistency lemmas in IndexedMCSFamily.lean that require the temporal K distribution axiom. Lines 338 and 354 contain sorries for proving that seeds constructed during family building are consistent. This requires careful application of TM logic axioms, specifically the K distribution axiom for temporal operators. From review-20260121-task654.md medium priority recommendations.

---

### 658. Prove indexed family coherence conditions
- **Plan**: [implementation-001.md](specs/658_prove_indexed_family_coherence_conditions/plans/implementation-001.md)
- **Research**: [research-001.md](specs/658_prove_indexed_family_coherence_conditions/reports/research-001.md)
- **Status**: [BLOCKED]
- **Started**: 2026-01-25T21:32:07Z
- **Session**: sess_1769395200_f8a2b9
- **Effort**: 8-12 hours
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Related**: Task 654
- **Source**: Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean:433,439,448,456
- **Summary**: [implementation-summary-20260125.md](specs/658_prove_indexed_family_coherence_conditions/summaries/implementation-summary-20260125.md)
- **Blocked-By**: Fundamental construction issue - independent Lindenbaum extensions don't preserve temporal coherence

**Description**: Prove the four coherence condition sorries in the construct_indexed_family function (lines 433, 439, 448, 456). These ensure the indexed MCS family satisfies the coherence requirements that make it work with irreflexive temporal semantics (avoiding the T-axiom problem). Completing these would make the family construction fully constructive. From review-20260121-task654.md medium priority recommendations.

**Blocker**: The construct_indexed_family function uses independent Lindenbaum extensions at each time point, which don't preserve temporal coherence. Requires redesign using coherent construction (see Boneyard's canonical_task_rel pattern).

---

### 660. Prove parametric completeness theorems
- **Effort**: 10-15 hours
- **Status**: [IMPLEMENTING]
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
- **Status**: [IMPLEMENTING]
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

**Description**: Prove the "upward" bridge `semantic_truth_implies_truth_at` showing finite model truth implies general `truth_at` semantics. This completes `finite_model_property_constructive` by proving the FMP witness is compatible with arbitrary external model frameworks. NOT on critical path - completeness is handled by task 627 (downward bridge), and decidability only needs the cardinality bound. This is for theoretical completeness and generalization to external semantics. Task 610 contains research on the structural induction approach (Atom/Bot/Imp/Box/Temporal cases). The challenge is Box (quantification over all WorldHistories) and Temporal (behavior outside finite time bounds).

---

### 619. Agent system architecture upgrade (context:fork migration)
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-25
- **Priority**: Low
- **Language**: meta
- **Created**: 2026-01-19
- **Blocked-By**: Needs local verification (GitHub #16803 may only affect plugins)
- **Research**: [research-001.md](specs/619_agent_system_architecture_upgrade/reports/research-001.md), [research-002.md](specs/619_agent_system_architecture_upgrade/reports/research-002.md), [research-003.md](specs/619_agent_system_architecture_upgrade/reports/research-003.md)
- **Plan**: [implementation-002.md](specs/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: FUTURE UPGRADE: Migrate agent system skills to use native `context: fork` frontmatter once Anthropic fixes GitHub issue #16803. Research-002.md confirmed context:fork IS a real feature (added v2.1.0) but is currently broken. Current Task tool delegation pattern is correct and should remain until the bug is fixed. When fixed, migrate skills to use `context: fork` + `agent:` frontmatter for cleaner context isolation.

---

### 431. WezTerm tab color notification for Claude Code input needed
- **Effort**: 2-3 hours
- **Status**: [IMPLEMENTING]
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
- **Status**: [IMPLEMENTING]
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
- **Status**: [IMPLEMENTING]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 490
- **Dependencies**: Task 623

**Description**: Prove the `tableau_complete` theorem in Correctness.lean connecting FMP to tableau termination. Uses infrastructure from Task 623 to show that valid formulas have closing tableaux within FMP fuel bounds.

---

### 625. Prove decide_complete
- **Status**: [IMPLEMENTING]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 490
- **Dependencies**: Task 624

**Description**: Prove the `decide_complete` theorem in Correctness.lean deriving decision procedure completeness from tableau completeness. Follows directly from tableau_complete (Task 624).

---

### 667. Fix .opencode/specs path references
- **Status**: [IMPLEMENTED]
- **Priority**: High
- **Language**: meta
- **Session**: meta-session-1768239500
- **Researched**: 2026-01-21
- **Implemented**: 2026-01-21
- **Research**: [research-001.md](specs/667_fix_specs_path_references/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/667_fix_specs_path_references/plans/implementation-003.md)

**Description**: Successfully identified and fixed all 6 references to .opencode/specs throughout the system. Updated Python scripts (validate_state_sync.py, todo_cleanup.py), agent files (planner.md), context files (routing.md), and documentation. Task creation system is now functional.

---

### 668. Create specs path migration script
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: meta
- **Session**: meta-session-1768239500
- **Dependencies**: 667
- **Planned**: 2026-01-21
- **Plan**: [implementation-001.md](specs/668_create_specs_path_migration_script/plans/implementation-003.md)

**Description**: Create automated Python script to detect and migrate .opencode/specs path references to specs/. Script will include safety checks, dry-run mode, backup creation, and detailed reporting. Will serve as fix for current issue and preventative tool for future migrations.

---

### 669. Test task creation system
- **Status**: [IMPLEMENTING]
- **Priority**: Low
- **Language**: meta
- **Session**: test-session-1768239500
- **Planned**: 2026-01-21
- **Plan**: [implementation-001.md](specs/669_test_task_creation/plans/implementation-003.md)

**Description**: Simple test to verify that task creation system is working after fixing .opencode/specs path references. Validates that the path reference fixes resolved the task creation issues.

---


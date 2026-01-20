---
next_project_number: 632
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 16
  completed: 214
  in_progress: 1
  not_started: 4
  abandoned: 19
  total: 237
priority_distribution:
  critical: 0
  high: 3
  medium: 8
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

### 620. Refine Metalogic_v2 proofs for publication quality
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-19
- **Research**: [research-001.md](specs/620_refine_metalogic_v2_proofs/reports/research-001.md)
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19

**Description**: Refine the Bimodal/Metalogic_v2/ proofs to have no fat whatsoever, optimizing performance and organization while cleaning out old cruft, stray comments, and otherwise improving the presentation to be at the highest quality for publication and reference.

---

### 629. Document Bimodal/Metalogic proofs in LaTeX
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: latex
- **Created**: 2026-01-20
- **Dependencies**: 620

**Description**: Review the recently completed Bimodal/Metalogic/ proofs which make the representation theorem the central theorem from which completeness follows in order to systematically improve /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/04-Metalogic.tex to fully and accurately report the theorems established, providing some indication of how the proofs go without providing proofs just remarks and discussion, and explaining the organization/dependencies between the theorems (which import from which), providing a clear and well organized narrative arc that guides the reader through the Bimodal/Metalogic/ results that have been established in the Lean source code.

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

### 618. Move Metalogic to Boneyard, make Metalogic_v2 independent
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Researched**: 2026-01-19
- **Completed**: 2026-01-19
- **Research**: [research-001.md](specs/618_move_metalogic_to_boneyard_make_v2_independent/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/618_move_metalogic_to_boneyard_make_v2_independent/plans/implementation-002.md)
- **Summary**: [implementation-summary-20260119.md](specs/618_move_metalogic_to_boneyard_make_v2_independent/summaries/implementation-summary-20260119.md)

**Description**: Move the interesting parts of Bimodal/Metalogic/ to the Bimodal/Boneyard/, making Bimodal/Metalogic_v2/ stand independently on its own (no imports from the Boneyard/).

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

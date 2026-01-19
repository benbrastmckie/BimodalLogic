---
next_project_number: 622
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 12
  completed: 205
  in_progress: 1
  not_started: 4
  abandoned: 18
  total: 228
priority_distribution:
  critical: 0
  high: 3
  medium: 5
  low: 4
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

### 621. Analyze plan errors to improve agent execution
- **Status**: [RESEARCHING]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19

**Description**: Research the errors in /home/benjamin/Projects/ProofChecker/.claude/output/plan.md in order to identify how I can improve execution going forward of the /plan and other commands in my .claude/ agent system.

---

### 620. Refine Metalogic_v2 proofs for publication quality
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19

**Description**: Refine the Bimodal/Metalogic_v2/ proofs to have no fat whatsoever, optimizing performance and organization while cleaning out old cruft, stray comments, and otherwise improving the presentation to be at the highest quality for publication and reference.

---

### 619. Agent system architecture upgrade
- **Status**: [PLANNED]
- **Researched**: 2026-01-19
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Research**: [research-001.md](specs/619_agent_system_architecture_upgrade/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/619_agent_system_architecture_upgrade/plans/implementation-001.md)

**Description**: Draw on .claude/context/core/architecture/system-overview.md and research best practices for Claude Code in 2026 to upgrade the .claude/ agent system architecture. Goals: improve progressive disclosure, metadata passing via storage in specs/state.json, and context engineering to reduce pollution of the primary agent's context window. Explore context forking in skills to improve functionality without increasing overhead. Current system is working well; focus on incremental improvements.

---

### 618. Move Metalogic to Boneyard, make Metalogic_v2 independent
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Researched**: 2026-01-19
- **Research**: [research-001.md](specs/618_move_metalogic_to_boneyard_make_v2_independent/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/618_move_metalogic_to_boneyard_make_v2_independent/plans/implementation-001.md)

**Description**: Move the interesting parts of Bimodal/Metalogic/ to the Bimodal/Boneyard/, making Bimodal/Metalogic_v2/ stand independently on its own (no imports from the Boneyard/).

---

### 615. Fix closure_mcs_neg_complete double negation edge case
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Researched**: 2026-01-19
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Related**: Task 608
- **Research**: [research-001.md](specs/615_fix_closure_mcs_neg_complete_double_negation/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/615_fix_closure_mcs_neg_complete_double_negation/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/615_fix_closure_mcs_neg_complete_double_negation/summaries/implementation-summary-20260119.md)

**Description**: Fix the sorry in `closure_mcs_neg_complete` at Closure.lean:484. The issue is a double negation edge case where `chi.neg.neg` (when `chi = psi.neg`) is not in `closureWithNeg`. Options include: (1) Restrict the theorem to `psi ∈ closure` instead of `closureWithNeg`, (2) Extend `closureWithNeg` to include double negations, or (3) Use a different approach in the truth lemma that avoids this case.

---

### 612. Improve system-overview.md with architecture patterns
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-19
- **Related**: Task 609
- **Research**: [research-001.md](specs/612_improve_system_overview_docs_with_architecture/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/612_improve_system_overview_docs_with_architecture/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/612_improve_system_overview_docs_with_architecture/summaries/implementation-summary-20260119.md)

**Description**: Improve .claude/context/core/architecture/system-overview.md to use unicode characters for diagrams AND document all command-skill and command-skill-agent architecture options. Current skills don't use context:fork so document what is used, noting differences and motivations for each approach used by different command types.

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

### 617. Fix closure_mcs_implies_locally_consistent temporal axioms
- **Status**: [COMPLETED]
- **Started**: 2026-01-19
- **Completed**: 2026-01-19
- **Priority**: Low
- **Language**: lean
- **Created**: 2026-01-19
- **Related**: Task 608
- **Research**: [research-001.md](specs/617_fix_closure_mcs_implies_locally_consistent/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/617_fix_closure_mcs_implies_locally_consistent/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260119.md](specs/617_fix_closure_mcs_implies_locally_consistent/summaries/implementation-summary-20260119.md)

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
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-19
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 469
- **Dependencies**: Task 607
- **Research**: [research-001.md](specs/490_complete_decidability_procedure/reports/research-001.md)

**Description**: Complete the decidability procedure for TM logic. The existing Decidability module has tableau infrastructure but needs: proof extraction from closed tableaux, completeness proof connecting to FMP, and full decide function verification. Extends Task 469.

---

### 607. Port Decidability to Metalogic_v2
- **Effort**: 8-12 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-19
- **Started**: 2026-01-19
- **Source**: Code Review 2026-01-18 (M1)
- **Research**: [research-001.md](specs/607_port_decidability_to_metalogic_v2/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/607_port_decidability_to_metalogic_v2/plans/implementation-001.md)

**Description**: Port the Decidability/ infrastructure from old Metalogic/ to Metalogic_v2/ architecture. The old Decidability/ has 8 files (Tableau, SignedFormula, Saturation, DecisionProcedure, ProofExtraction, CountermodelExtraction, Correctness, Closure) totaling 61KB. Integrate with FMP as the bridge theorem following the representation-first architecture.

---

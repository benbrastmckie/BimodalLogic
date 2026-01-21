---
next_project_number: 666
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-17T02:30:00Z
task_counts:
  active: 20
  completed: 236
  in_progress: 0
  not_started: 13
  abandoned: 19
  total: 258
priority_distribution:
  critical: 0
  high: 5
  medium: 9
  low: 6
technical_debt:
  sorry_count: 205
  axiom_count: 15
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 661. Create documentation standards file
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-21
- **Started**: 2026-01-21
- **Completed**: 2026-01-21
- **Research**: [research-001.md](specs/661_create_documentation_standards_file/reports/research-001.md)
- **Plan**: [implementation-003.md](specs/661_create_documentation_standards_file/plans/implementation-003.md)
- **Summary**: [implementation-summary-20260121.md](specs/661_create_documentation_standards_file/summaries/implementation-summary-20260121.md)

**Description**: Create `.claude/context/core/standards/documentation-standards.md` (kebab-case naming) that specifies: (1) file naming conventions (kebab-case.md for all docs, README.md as only ALL_CAPS exception); (2) README.md required in all subdirectories of docs/; (3) prohibition of "quick start" and "quick reference" document patterns; (4) prohibition of emojis (unicode OK); (5) present tense requirement with no historical language; (6) what belongs in docs/ vs context/. Fix the corrupted/duplicated content in existing `documentation.md`.

---

### 662. Consolidate and update DOCS/README.md
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-21
- **Started**: 2026-01-21
- **Researched**: 2026-01-21
- **Dependencies**: 661
- **Research**: [research-001.md](specs/662_consolidate_update_docs_readme/reports/research-001.md)

**Description**: Rewrite `.claude/docs/README.md` to: remove "Quick Start" section; use present tense throughout (no historical references); consolidate with system-overview.md where appropriate; ensure accurate file paths and references; follow new documentation standards from Task 661.

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

### 663. Archive stale research/fix plan documents
- **Effort**: 1-2 hours
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-21
- **Started**: 2026-01-21
- **Dependencies**: 661
- **Research**: [specs/663_archive_stale_research_fix_plan_documents/reports/research-001.md]
- **Plan**: [implementation-001.md](specs/663_archive_stale_research_fix_plan_documents/plans/implementation-001.md)

**Description**: Move stale research artifacts from docs/ to archive or delete: `research-skill-agent-contexts.md` (research artifact), `skills-vs-agents-context-behavior.md` (distill to context/ first), `memory-leak-fix-plan.md` (historical fix plan), `orchestrator-workflow-execution-issue.md` (issue document). Extract any valuable permanent guidance to appropriate context files before archiving.

---

### 664. Remove STANDARDS_QUICK_REF.md and quick reference patterns
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-21
- **Dependencies**: 661

**Description**: Delete `STANDARDS_QUICK_REF.md` from .claude/docs/. Ensure information is properly captured in authoritative sources. Update any references to this file throughout the codebase.

---

### 665. Update guides and templates to follow new standards
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-21
- **Dependencies**: 661, 662

**Description**: Update remaining files in `docs/guides/` and `docs/templates/`: remove "quick start" sections from `user-installation.md`; ensure present tense throughout; fix references to non-existent paths; apply ALL_CAPS naming where appropriate; update templates/README.md to remove version numbers and version history references.

---

### 655. Fix jq errors in agent system
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-20

**Description**: Review the entire .claude/ agent system to fix all jq (and other) errors that occur in commands like /research. Some commands have been fixed individually, but a comprehensive review is needed to identify and fix all remaining jq errors to improve efficiency. The errors may include syntax issues, escaping problems, or other command-line issues in skill and agent definitions.

---

### 653. Improve metalogic infrastructure (rename frame, address infinite contexts)
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-20
- **Source**: Theories/Bimodal/latex/subfiles/04-Metalogic.tex:142,253

**Description**: Two related metalogic improvements: (1) Rename SemanticCanonicalFrame to CanonicalTaskFrame in Lean source code for accuracy (the current name is misleading since it's a task frame, not a general semantic frame). (2) Address infinite contexts/sets which remain unaddressed - this should be handled by proving and applying compactness to extend the current finite-context completeness results to infinite contexts.

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

### 656. Complete truth lemma forward direction (imp/box cases)
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Related**: Task 654
- **Source**: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:144,155

**Description**: Complete the imp and box cases in the truth lemma forward direction for the parametric canonical model. The imp case (line 144) requires proving MCS modus ponens closure. The box case (line 155) requires witness construction for modal accessibility. These gaps don't affect the main representation theorem but are needed for a complete truth lemma biconditional. From review-20260121-task654.md recommendations.

---

### 657. Prove seed consistency (temporal K distribution)
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Related**: Task 654
- **Source**: Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean:338,354

**Description**: Prove the seed consistency lemmas in IndexedMCSFamily.lean that require the temporal K distribution axiom. Lines 338 and 354 contain sorries for proving that seeds constructed during family building are consistent. This requires careful application of TM logic axioms, specifically the K distribution axiom for temporal operators. From review-20260121-task654.md medium priority recommendations.

---

### 658. Prove indexed family coherence conditions
- **Effort**: 8-12 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Related**: Task 654
- **Source**: Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean:433,439,448,456

**Description**: Prove the four coherence condition sorries in the construct_indexed_family function (lines 433, 439, 448, 456). These ensure the indexed MCS family satisfies the coherence requirements that make it work with irreflexive temporal semantics (avoiding the T-axiom problem). Completing these would make the family construction fully constructive. From review-20260121-task654.md medium priority recommendations.

---

### 660. Prove parametric completeness theorems
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-21
- **Dependencies**: Tasks 656, 657, 658
- **Related**: Task 654

**Description**: Use the representation theorem from Task 654 to prove weak and strong completeness for TM logic over arbitrary ordered additive groups. The representation theorem establishes that consistent formulas are satisfiable in the parametric canonical model. This task completes the metalogic by deriving completeness: (1) Weak completeness: if ⊨ φ then ⊢ φ, (2) Strong completeness: if Γ ⊨ φ then Γ ⊢ φ. Builds on the foundation established by Tasks 656-658. From review-20260121-task654.md future work section.

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

### 659. Prove negation completeness lemmas
- **Effort**: 6-10 hours
- **Status**: [NOT STARTED]
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

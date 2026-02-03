---
next_project_number: 837
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-03T10:30:00Z
task_counts:
  active: 13
  completed: 370
  in_progress: 2
  not_started: 12
  abandoned: 26
  total: 398
technical_debt:
  sorry_count: 95
  axiom_count: 15
  build_errors: 1
  status: good
---

# TODO

## Tasks

### 836. Improve Metalogic README documentation with flowcharts and subdirectory summaries
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: general
- **Created**: 2026-02-03

**Description**: Improve documentation for Metalogic/README.md following task 830's incomplete work. Clearly represent the representation theorem and all major modules with detailed dependency flowchart. Include comprehensive summaries of each Metalogic/ subdirectory with links to their README.md files. Review and update all subdirectory README.md files for accuracy and exhaustivity.

---

### 835. Enhance /review Command with ROADMAP.md Integration and Revision
- **Effort**: 4-5 hours
- **Status**: [RESEARCHED]
- **Language**: meta
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Dependencies**: Task 833
- **Research**: [research-001.md](specs/835_enhance_review_command_roadmap_integration_revision/reports/research-001.md)

**Description**: Extend /review command to: (1) Begin by loading and analyzing ROADMAP.md context (Strategies and Ambitions sections) to inform codebase review, (2) End by revising ROADMAP.md based on review findings (update strategy statuses, propose new ambitions, identify gaps), (3) Conclude with task suggestions based on findings (like /learn), (4) Create skill-reviewer if delegation is needed, or extend existing review logic. Ensure changes follow checkpoint-based execution pattern.

---

### 834. Enhance /todo Command with Changelog Updates and Task Suggestions
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Completed**: 2026-02-03
- **Dependencies**: Task 833
- **Research**: [research-001.md](specs/834_enhance_todo_command_changelog_task_suggestions/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/834_enhance_todo_command_changelog_task_suggestions/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260203.md](specs/834_enhance_todo_command_changelog_task_suggestions/summaries/implementation-summary-20260203.md)

**Description**: Extend /todo command to: (1) Update ROADMAP.md Changelog section when archiving completed tasks, (2) Add task suggestion generation at end of /todo execution (scan active tasks, ROADMAP.md Ambitions, and recent completions to propose 3-5 next tasks similar to /learn output), (3) Update skill-status-sync or create new skill if delegation is needed. Ensure atomic updates to ROADMAP.md follow state management rules.

---

### 833. Enhance ROADMAP.md Structure with Changelog, Strategies, and Ambitions
- **Effort**: 2-3 hours
- **Status**: [PLANNED]
- **Language**: general
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Research**: [research-001.md](specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/reports/research-001.md), [research-002.md](specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/reports/research-002.md)
- **Plan**: [implementation-001.md](specs/833_enhance_roadmap_structure_changelog_strategies_ambitions/plans/implementation-001.md)

**Description**: Restructure ROADMAP.md to add three new sections: (1) Changelog - dated entries of completed work from task completions, (2) Strategies - active experiments with status, (3) Ambitions - big picture goals. Migrate existing content into appropriate sections. Define clear schemas for each section to enable programmatic updates by /todo and /review commands.

---

### 832. Update artifact formats and agent definitions for sorry handling
- **Effort**: 1.5 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Started**: 2026-02-03
- **Completed**: 2026-02-03
- **Research**: [research-001.md](specs/832_update_artifact_formats_agent_sorry_guidance/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/832_update_artifact_formats_agent_sorry_guidance/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260203.md](specs/832_update_artifact_formats_agent_sorry_guidance/summaries/implementation-summary-20260203.md)

**Description**: Update artifact formats and agent definitions for consistent sorry handling. Add 'Sorry Characterization' section to report-format.md and plan-format.md with explicit guidance: (1) Never use 'acceptable sorry' language, (2) Always explain transitive inheritance impact, (3) Always specify remediation path, (4) Publication requires zero inherited sorries. Move sorry-debt-policy.md from optional to mandatory 'Always Load' context in both lean-research-agent.md and lean-implementation-agent.md. Add explicit prohibition against 'acceptable' framing in agent critical requirements.

---

### 831. Strengthen sorry-debt-policy language and guidance
- **Effort**: 1.5 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Started**: 2026-02-03
- **Completed**: 2026-02-03
- **Research**: [research-001.md](specs/831_strengthen_sorry_debt_policy_language/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/831_strengthen_sorry_debt_policy_language/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260203.md](specs/831_strengthen_sorry_debt_policy_language/summaries/implementation-summary-20260203.md)

**Description**: Revise sorry-debt-policy.md to eliminate 'acceptable sorry' language and add clear guidance on transitive inheritance. Replace 'Acceptable for Development' category with 'Tolerated During Development (Technical Debt)'. Add explicit section on how to characterize sorries in reports/plans emphasizing that: (1) ALL sorries are mathematical debt, (2) sorries propagate transitively through imports, (3) publication requires zero inherited sorries. Add framing: 'Document what exists, explain WHY it exists, specify the remediation path - never call a sorry acceptable.'

---

### 830. Standardize Metalogic documentation with README.md files
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Language**: general
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Started**: 2026-02-03
- **Completed**: 2026-02-03
- **Research**: [research-001.md](specs/830_standardize_metalogic_documentation/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/830_standardize_metalogic_documentation/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260203.md](specs/830_standardize_metalogic_documentation/summaries/implementation-summary-20260203.md)

**Description**: Ensure all Bimodal/Metalogic/ subdirectories have README.md files following DIRECTORY_README_STANDARD.md and DOC_QUALITY_CHECKLIST.md. Each README should: (1) completely and accurately report all contents in the subdirectory, (2) include summaries of any subdirectories with links to their README.md files, (3) include appropriate cross-links to related documentation. Focus on publication-ready documentation that is direct and to the point (no fluff). Subdirectories to cover: Core/, Bundle/, FMP/, Algebraic/, and the main Metalogic/ entry point.

---

### 829. Remove backwards-compatible aliases from Metalogic
- **Effort**: 0.5 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Completed**: 2026-02-03
- **Research**: [research-001.md](specs/829_remove_metalogic_backwards_compatible_aliases/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/829_remove_metalogic_backwards_compatible_aliases/plans/implementation-001.md)
- **Summary**: Removed backwards-compatible aliases semantic_weak_completeness and double_negation_elim from Metalogic modules. Updated documentation to reference canonical names fmp_weak_completeness and Bimodal.Theorems.Propositional.double_negation only.

**Description**: Remove backwards-compatible aliases added during task 818 refactoring for a clean and consistent codebase. Specifically remove `semantic_weak_completeness := @fmp_weak_completeness` alias from FMP/SemanticCanonicalModel.lean. The canonical name is now fmp_weak_completeness and no external code depends on the old name. This improves maintainability by avoiding duplicate entry points to the same theorem.

---

### 828. Explore FMP approach to complete backward direction of TruthLemma
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-03

**Description**: Explore FMP approach to complete backward direction of TruthLemma. The backward direction sorries in Bundle/TruthLemma.lean (lines 383, 395) for G/H operators currently require infinitary proof systems. Investigate whether the Finite Model Property can provide an alternative approach to proving these directions.

---

### 827. Complete multi-family BMCS construction to resolve modal_backward sorry
- **Effort**: 10 hours
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Started**: 2026-02-03
- **Research**: [research-001.md](specs/827_complete_multi_family_bmcs_construction/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/827_complete_multi_family_bmcs_construction/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260203.md](specs/827_complete_multi_family_bmcs_construction/summaries/implementation-summary-20260203.md) (partial)

**Description**: Complete multi-family BMCS construction to resolve modal_backward sorry. The single-family simplification in Bundle/Construction.lean (line 220) accepts modal_backward as a sorry. Implement the full multi-family construction that properly tracks accessibility relations across multiple MCS families to eliminate this assumption.

---

### 826. Update FDSM Completeness to Use Saturated Construction
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Started**: 2026-02-03
- **Completed**: 2026-02-03
- **Dependencies**: 825
- **Research**: [research-001.md](specs/826_fdsm_completeness_saturated_construction/reports/research-001.md)
- **Plan**: [implementation-004.md](specs/826_fdsm_completeness_saturated_construction/plans/implementation-004.md)
- **Summary**: Pivoted from FDSM to BMCS completeness. Archived FDSM module (23 sorries) to Boneyard. BMCS completeness verified working. Active sorries reduced from 27 to 4.

**Description**: Replace single-history fdsm_from_closure_mcs in Completeness.lean with proper saturated construction from Phase 4. The current implementation (lines 67-91) creates only one history, which trivializes modal operators. After task 825 completes saturated_histories, update: (1) Replace fdsm_from_closure_mcs with fdsm_from_saturated_histories that uses the modal saturation fixed point, (2) Update modal_saturated proof to use the saturation property instead of single-history trivialization, (3) Ensure eval_history is properly selected from the saturated set. This bridges Phase 4 to Phase 6.

---

### 825. Complete FDSM Multi-History Modal Saturation
- **Effort**: 8-12 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Completed**: 2026-02-03
- **Dependencies**: 816
- **Research**: [research-001.md](specs/825_fdsm_multi_history_modal_saturation/reports/research-001.md), [research-002.md](specs/825_fdsm_multi_history_modal_saturation/reports/research-002.md), [research-003.md](specs/825_fdsm_multi_history_modal_saturation/reports/research-003.md)
- **Plan**: [implementation-002.md](specs/825_fdsm_multi_history_modal_saturation/plans/implementation-002.md) (revised from v001)
- **Summary**: Implemented multi-history modal saturation for FDSM completeness. Archived broken single-history construction to Boneyard, added MCSTrackedHistory with type class instances, implemented tracked_saturation_step with proofs, proved tracked_fixed_point_is_saturated (core correctness theorem), built fdsm_from_tracked_saturation construction, and added closure_mcs_modus_ponens lemma for TruthLemma support.

**Description**: Replace broken single-history FDSM construction with proper multi-history modal saturation. Revised approach: (1) Archive fdsm_from_closure_mcs to Boneyard with comments explaining modal trivialization (Box psi = psi), (2) Add DecidableEq for MCSTrackedHistory, (3) Rebuild saturation on tracked histories that carry MCS info, (4) Prove modal saturation property, (5) Update Completeness.lean, (6) Add closure membership infrastructure.

---

### 824. Fix Constitutive Foundation Remaining Issues
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Language**: latex
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Completed**: 2026-02-03
- **Dependencies**: 823
- **Research**: [research-001.md](specs/824_fix_constitutive_foundation_remaining_issues/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/824_fix_constitutive_foundation_remaining_issues/plans/implementation-002.md)
- **Summary**: [implementation-summary-20260203.md](specs/824_fix_constitutive_foundation_remaining_issues/summaries/implementation-summary-20260203.md)

**Description**: Address remaining FIX: and NOTE: tags in Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex. Tags: (1) line 181: Make state modality definitions use dependent type theory notation consistently; (2) line 245: Add exclusivity constraint from counterfactual_worlds.tex:861, generalizing to n-place functions; (3) line 246: Add exhaustivity constraint from counterfactual_worlds.tex:861, generalizing to n-place functions; (4) line 295: Convert subsection 2.7 to remark format; (5) line 357: Apply verum/falsum notation conventions established in task 823; (6) line 481/534: Define all four extremal bilateral propositions alongside propositional operators. Remove all tags after implementing fixes.

---

### 818. Refactor Bimodal Metalogic modules
- **Effort**: 4-5 hours (reduced post-task 826)
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-03
- **Planned**: 2026-02-03
- **Started**: 2026-02-03
- **Completed**: 2026-02-03
- **Research**: [research-001.md](specs/818_refactor_bimodal_metalogic_modules/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/818_refactor_bimodal_metalogic_modules/plans/implementation-002.md)
- **Summary**: [implementation-summary-20260203.md](specs/818_refactor_bimodal_metalogic_modules/summaries/implementation-summary-20260203.md)

**Description**: Take stock of the metalogic following major completeness strategy changes (task 812, sorries removed via tasks 814-816). Archive obsolete elements to boneyard. Refactor Bimodal/Metalogic/ modules for clean, maintainable structure with clear dependencies. Highlight main results: soundness, representation, completeness, compactness, decidability. Rename theorems/functions for clarity. Refactor proofs, APIs, imports as needed. Maintain Algebraic/ as foundation for future algebraic representation theorem.

---

### 793. Fix Claude Code neovim sidebar black screen delay
- **Effort**: S
- **Status**: [PLANNED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/793_fix_claude_code_neovim_sidebar_black_screen/reports/research-001.md)

**Description**: Investigate and fix issue where running a command in Claude Code sidebar in neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. Functionality works correctly otherwise. Issue started recently. Root cause may be in hook system or external. Research online and review hook configuration to identify simple and elegant fix.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
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

### 685. Derive world-history and Barcan theorems
 **Effort**: 8-10 hours
 **Status**: [PLANNED]
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
- **Status**: [PLANNED]
- **Researched**: 2026-01-28
- **Language**: meta
- **Created**: 2026-01-19
- **Blocked-By**: Empirically confirmed broken (research-005.md) - GitHub #16803
- **Research**: [research-001.md](specs/619_agent_system_architecture_upgrade/reports/research-001.md), [research-002.md](specs/619_agent_system_architecture_upgrade/reports/research-002.md), [research-003.md](specs/619_agent_system_architecture_upgrade/reports/research-003.md), [research-004.md](specs/619_agent_system_architecture_upgrade/reports/research-004.md), [research-005.md](specs/619_agent_system_architecture_upgrade/reports/research-005.md)
- **Plan**: [implementation-002.md](specs/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: FUTURE UPGRADE: Migrate agent system skills to use native `context: fork` frontmatter once Anthropic fixes GitHub issue #16803. Empirical testing (research-005.md) confirmed context:fork provides NO context isolation, NO tool restrictions, and NO subprocess isolation - the feature is completely non-functional. Current implementation (direct execution for Lean skills, Task delegation for others) is correct and should remain until context:fork is fixed and re-validated.


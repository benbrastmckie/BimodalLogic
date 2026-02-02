---
next_project_number: 811
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-02T08:30:00Z
task_counts:
  active: 16
  completed: 350
  in_progress: 2
  not_started: 5
  abandoned: 24
  total: 374
technical_debt:
  sorry_count: 91
  axiom_count: 15
  build_errors: 1
  status: manageable
---

# TODO

## Tasks

### 810. Strategic review: Representation/ vs semantic completeness paths
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Research**: [research-001.md](specs/810_strategic_review_representation_vs_semantic_paths/reports/research-001.md)

**Description**: Strategic review: Representation/ approach vs semantic completeness paths to determine archival vs completion strategy for publishable metalogic.

---

### 809. Audit TruthLemma.lean sorries
- **Effort**: TBD
- **Status**: [PLANNING]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Research**: [research-002.md](specs/809_audit_truthlemma_sorries/reports/research-002.md)

**Description**: Audit TruthLemma.lean sorries (4 total Box + backward temporal) and evaluate impact on completeness proofs for publishable metalogic.

---

### 808. Audit CoherentConstruction.lean and TaskRelation.lean sorries
- **Effort**: 1.5 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Planned**: 2026-02-02
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Research**: [research-001.md](specs/808_audit_coherentconstruction_taskrelation_sorries/reports/research-001.md)
- **Plan**: [implementation-003.md](specs/808_audit_coherentconstruction_taskrelation_sorries/plans/implementation-003.md)
- **Summary**: [implementation-summary-20260202.md](specs/808_audit_coherentconstruction_taskrelation_sorries/summaries/implementation-summary-20260202.md)

**Description**: Audit CoherentConstruction.lean and TaskRelation.lean sorries (16 total) to determine completion strategy vs archival for publishable metalogic.

---

### 807. Remove unused representation_theorem call
- **Effort**: 0.5 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Planned**: 2026-02-02
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Research**: [research-001.md](specs/807_remove_unused_representation_theorem_call/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/807_remove_unused_representation_theorem_call/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260202.md](specs/807_remove_unused_representation_theorem_call/summaries/implementation-summary-20260202.md)

**Description**: Remove unused representation_theorem call from InfinitaryStrongCompleteness.lean line 248 (dead code cleanup).

---

### 806. Archive deprecated Representation/ constructions
- **Effort**: 4 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Planned**: 2026-02-02
- **Revised**: 2026-02-02
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Research**: [research-001.md](specs/806_archive_deprecated_representation_constructions/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/806_archive_deprecated_representation_constructions/plans/implementation-002.md)
- **Summary**: [implementation-summary-20260202.md](specs/806_archive_deprecated_representation_constructions/summaries/implementation-summary-20260202.md)

**Description**: Archive deprecated Representation/ constructions (IndexedMCSFamily.lean, CanonicalHistory.lean) marked as superseded/deprecated to reduce sorry count.

---

### 805. Investigate UniversalCanonicalModel.lean remaining sorries
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Planned**: 2026-02-02
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Research**: [research-001.md](specs/805_investigate_universalcanonicalmodel_remaining_sorries/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/805_investigate_universalcanonicalmodel_remaining_sorries/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260202.md](specs/805_investigate_universalcanonicalmodel_remaining_sorries/summaries/implementation-summary-20260202.md)

**Description**: Investigate remaining 3 sorries in UniversalCanonicalModel.lean beyond G_bot/H_bot conditions to determine if they are provable or fundamental gaps.

---

### 803. Prove G_bot/H_bot conditions in UniversalCanonicalModel.lean
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Planned**: 2026-02-02
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Research**: [research-001.md](specs/803_prove_g_bot_h_bot_conditions/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/803_prove_g_bot_h_bot_conditions/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260202.md](specs/803_prove_g_bot_h_bot_conditions/summaries/implementation-summary-20260202.md)

**Description**: Prove G_bot/H_bot conditions in UniversalCanonicalModel.lean. These 2 sorries are provable using T-axioms (as demonstrated in InfinitaryStrongCompleteness). Would make weak_completeness path sorry-free. Follow-up from task #797.

---

### 801. Document Soundness temp_t axiom semantic validity issue
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-01
- **Researched**: 2026-02-02
- **Planned**: 2026-02-02
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Research**: [research-001.md](specs/801_document_soundness_temp_t_axiom_validity/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/801_document_soundness_temp_t_axiom_validity/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260202.md](specs/801_document_soundness_temp_t_axiom_validity/summaries/implementation-summary-20260202.md)

**Description**: Document the 2 sorries in SoundnessLemmas.lean (temp_t axioms). These are NOT semantically valid with strict inequality but were added for syntactic completeness (MCS coherence). Add clear documentation explaining this is an acceptable known limitation. Evaluate if these can be resolved or should be marked as permanent documented technical debt.

---

### 799. Complete Decidability proofs
- **Effort**: 5-6 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-01
- **Researched**: 2026-02-02
- **Planned**: 2026-02-02
- **Revised**: 2026-02-02
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Research**: [research-001.md](specs/799_complete_decidability_proofs/reports/research-001.md), [research-002.md](specs/799_complete_decidability_proofs/reports/research-002.md), [research-003.md](specs/799_complete_decidability_proofs/reports/research-003.md)
- **Plan**: [implementation-003.md](specs/799_complete_decidability_proofs/plans/implementation-003.md)
- **Summary**: [implementation-summary-20260202.md](specs/799_complete_decidability_proofs/summaries/implementation-summary-20260202.md)

**Description**: Complete the 6 remaining sorries in Decidability/: 2 sorries in Closure.lean (tableau closure proofs), 1 sorry in Saturation.lean (rule termination), and 3 sorries in Correctness.lean. These are technical completeness/termination proofs for the tableau-based decision procedure.

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

### 793. Fix Claude Code neovim sidebar black screen delay
- **Effort**: S
- **Status**: [RESEARCHED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/793_fix_claude_code_neovim_sidebar_black_screen/reports/research-001.md)

**Description**: Investigate and fix issue where running a command in Claude Code sidebar in neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. Functionality works correctly otherwise. Issue started recently. Root cause may be in hook system or external. Research online and review hook configuration to identify simple and elegant fix.

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


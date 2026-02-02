---
next_project_number: 819
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-02T21:45:54Z
task_counts:
  active: 12
  completed: 362
  in_progress: 2
  not_started: 5
  abandoned: 26
  total: 386
technical_debt:
  sorry_count: 75
  axiom_count: 15
  build_errors: 0
  status: good
---

# TODO

## Tasks

### 818. Refactor Bimodal Metalogic modules
- **Effort**: 8-12 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-02

**Description**: Take stock of the metalogic following major completeness strategy changes (task 812, sorries removed via tasks 814-816). Archive obsolete elements to boneyard. Refactor Bimodal/Metalogic/ modules for clean, maintainable structure with clear dependencies. Highlight main results: soundness, representation, completeness, compactness, decidability. Rename theorems/functions for clarity. Refactor proofs, APIs, imports as needed. Maintain Algebraic/ as foundation for future algebraic representation theorem.

---

### 816. BMCS Temporal Modal Coherence Strengthening
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Parent**: Task 813
- **Dependencies**: 814
- **Research**: [research-001.md](specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-001.md), [research-002.md](specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-002.md), [research-003.md](specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-003.md)

**Description**: Resolve 3 temporal/modal sorries by adding backward coherence conditions to IndexedMCSFamily and implementing modal saturation for singleFamilyBMCS. Sorries: TruthLemma.lean:156 (phi_at_all_future_implies_mcs_all_future), TruthLemma.lean:166 (phi_at_all_past_implies_mcs_all_past), Construction.lean:220 (modal_backward in singleFamilyBMCS). Strategy: Add backward_from_all_future and backward_from_all_past fields to IndexedMCSFamily; for modal_backward, options include modal saturation during MCS construction or multi-family approach.

---

### 815. BMCS Universe Polymorphism Resolution
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-02
- **Planned**: 2026-02-02
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Parent**: Task 813
- **Research**: [research-001.md](specs/815_bmcs_universe_polymorphism_resolution/reports/research-001.md), [research-002.md](specs/815_bmcs_universe_polymorphism_resolution/reports/research-002.md)
- **Plan**: [implementation-001.md](specs/815_bmcs_universe_polymorphism_resolution/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260202.md](specs/815_bmcs_universe_polymorphism_resolution/summaries/implementation-summary-20260202.md)

**Description**: Resolve 2 universe polymorphism sorries in BMCS completeness by specializing completeness theorems to Int or using explicit universe instantiation. Sorries: Completeness.lean:158 (bmcs_valid_implies_valid_Int), Completeness.lean:292 (bmcs_consequence_implies_consequence_Int). Strategy options: (1) Define bmcs_valid_Int and bmcs_consequence_Int directly over Int, (2) Use @ syntax for universe level manipulation, (3) Add Int-specific completeness theorems as primary definitions.

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
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-01-31
- **Planned**: 2026-02-01
- **Started**: 2026-02-02
- **Completed**: 2026-02-02
- **Source**: Code review 2026-01-31
- **Research**: [research-001.md](specs/786_migrate_efq_to_efq_neg/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/786_migrate_efq_to_efq_neg/plans/implementation-001.md)
- **Summary**: Migrated 2 deprecated efq function calls to efq_neg in Propositional.lean. Build verified successful with no errors.

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


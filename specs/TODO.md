---
next_project_number: 827
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-03T03:14:03Z
task_counts:
  active: 10
  completed: 370
  in_progress: 2
  not_started: 5
  abandoned: 26
  total: 396
technical_debt:
  sorry_count: 95
  axiom_count: 15
  build_errors: 1
  status: good
---

# TODO

## Tasks

### 826. Update FDSM Completeness to Use Saturated Construction
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Dependencies**: 825
- **Research**: [research-001.md](specs/826_fdsm_completeness_saturated_construction/reports/research-001.md)

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
- **Effort**: 8-12 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-02
- **Researched**: 2026-02-03
- **Research**: [research-001.md](specs/818_refactor_bimodal_metalogic_modules/reports/research-001.md)

**Description**: Take stock of the metalogic following major completeness strategy changes (task 812, sorries removed via tasks 814-816). Archive obsolete elements to boneyard. Refactor Bimodal/Metalogic/ modules for clean, maintainable structure with clear dependencies. Highlight main results: soundness, representation, completeness, compactness, decidability. Rename theorems/functions for clarity. Refactor proofs, APIs, imports as needed. Maintain Algebraic/ as foundation for future algebraic representation theorem.

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


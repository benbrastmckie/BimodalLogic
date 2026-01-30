---
next_project_number: 780
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-30T02:30:00Z
task_counts:
  active: 9
  completed: 331
  in_progress: 2
  not_started: 4
  abandoned: 23
  total: 355
priority_distribution:
  critical: 0
  high: 3
  medium: 4
  low: 2
technical_debt:
  sorry_count: 66
  axiom_count: 0
  build_errors: 0
  status: good
---

# TODO

## High Priority

### 779. Archive weak_completeness for sorry-free Metalogic
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: lean
- **Created**: 2026-01-30
- **Researched**: 2026-01-30
- **Research**: [research-001.md](specs/779_archive_weak_completeness_for_sorry_free_metalogic/reports/research-001.md)

**Description**: Archive weak_completeness theorem to achieve sorry-free Metalogic. Move Completeness/WeakCompleteness.lean (containing the architecturally unfixable sorry) to Boneyard/Metalogic_v5/Completeness/ with clear README explaining: (1) why archived (architectural sorry - forward truth lemma gap), (2) what to use instead (semantic_weak_completeness from FMP/SemanticCanonicalModel.lean), (3) mathematical reason it cannot be fixed (Box semantics quantifies over ALL histories, finite models only capture ONE state). Update Completeness/Completeness.lean to remove WeakCompleteness import. Verify finite_strong_completeness builds without weak_completeness dependency or archive it too if needed. Goal: zero sorry count in Theories/Bimodal/Metalogic/ (excluding Boneyard/).

---

## Medium Priority

### 778. Remove priority system from task workflow
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Planned**: 2026-01-30
- **Researched**: 2026-01-30
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-30
- **Research**: [research-001.md](specs/778_remove_priority_system_from_task_workflow/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/778_remove_priority_system_from_task_workflow/plans/implementation-001.md)

**Description**: Remove the High/Medium/Low priority system from task management workflow. Tasks should be added at the top of a flat ## Tasks section in TODO.md, allowing natural priority sorting (new tasks at top, older tasks sink down). Changes: (1) Update TODO.md structure to use single ## Tasks section under # TODO header instead of priority sections; (2) Update /task command (commands/task.md) to prepend new tasks at top of ## Tasks section and remove priority field assignments; (3) Remove priority field from state.json schema in state-management.md; (4) Update skills that create tasks (skill-lake-repair, skill-learn) to target ## Tasks section instead of priority sections; (5) Update CLAUDE.md to remove priority references from examples and documentation; (6) Remove priority_distribution from TODO.md frontmatter if present. Apply new behavior going forward without migrating existing tasks.

---

### 777. Complete weak_completeness architectural sorry
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-30
- **Researched**: 2026-01-30
- **Research**: [research-001.md](specs/777_complete_weak_completeness_sorry/reports/research-001.md)

**Description**: Complete the architectural sorry in weak_completeness. This is a bridging issue between two formulations of validity, and you should use semantic_weak_completeness for sorry-free completeness proofs.

---

### 774. Restore representation theorem as Under Development
- **Effort**: 4-5 hours
- **Status**: [IMPLEMENTING]
- **Planned**: 2026-01-30
- **Revised**: 2026-01-30
- **Priority**: Medium
- **Language**: lean
- **Researched**: 2026-01-30
- **Research**: [research-001.md](specs/774_restore_representation_theorem_as_under_development/reports/research-001.md), [research-002.md](specs/774_restore_representation_theorem_as_under_development/reports/research-002.md)
- **Plan**: [implementation-002.md](specs/774_restore_representation_theorem_as_under_development/plans/implementation-002.md)

**Description**: Restore representation theorem proofs from Boneyard/Metalogic_v4/ (archived by task 772) to an Under Development section alongside the Algebraic/ approach. Include TaskRelation.lean, CoherentConstruction.lean, TruthLemma.lean and related files that naturally belong together as work-in-progress completeness approaches.

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
- **Status**: [IMPLEMENTING]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 685. Derive world-history and Barcan theorems
 **Effort**: 8-10 hours
 **Status**: [RESEARCHED]
 **Priority**: Medium
 **Language**: lean
 **Created**: 2026-01-26
 **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)
 **Research**: [research-001.md](specs/685_derive_world_history_and_barcan_theorems/reports/research-001.md)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---

## Low Priority

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
- **Status**: [IMPLEMENTING]
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


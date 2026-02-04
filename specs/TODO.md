---
next_project_number: 855
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-03T23:15:00Z
task_counts:
  active: 12
  completed: 393
  in_progress: 1
  not_started: 5
  abandoned: 26
  total: 421
technical_debt:
  sorry_count: 75
  axiom_count: 16
  build_errors: 1
  status: good
---

# TODO

## Tasks

### 854. Bimodal metalogic audit and cleanup
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-04
- **Researched**: 2026-02-04
- **Research**: [research-001.md](specs/854_bimodal_metalogic_audit_and_cleanup/reports/research-001.md), [research-002.md](specs/854_bimodal_metalogic_audit_and_cleanup/reports/research-002.md), [research-003.md](specs/854_bimodal_metalogic_audit_and_cleanup/reports/research-003.md)

**Description**: Take stock of the bimodal metalogic after completing tasks 851-854 (following 844). Audit to identify: (1) what has been established and how (theorems, axioms, dependencies), (2) what remains to be established for completeness, (3) what can be safely archived to Bimodal/Boneyard/ without breaking anything. Goal is a well-structured metalogic ready for publication.

---

### 853. Construct CoherentBundle from consistent context
- **Effort**: 40-60 hours (revised)
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-03
- **Researched**: 2026-02-03
- **Planned**: 2026-02-04
- **Started**: 2026-02-04
- **Completed**: 2026-02-04
- **Research**: [research-001.md](specs/853_construct_coherentbundle_from_context/reports/research-001.md), [research-004.md](specs/853_construct_coherentbundle_from_context/reports/research-004.md)
- **Plan**: [implementation-002.md](specs/853_construct_coherentbundle_from_context/plans/implementation-002.md) (revised)
- **Parent**: Task 844
- **Depends**: Task 851
- **Summary**: Implemented WeakCoherentBundle approach for completeness theorem integration. Created new module with core/witness family separation that avoids the multi-family coherence obstacle. Full pipeline from consistent context to WeakBMCS is now available.

**Description**: Construct CoherentBundle from consistent context as main entry point for completeness theorem integration. REVISED: Using WeakCoherentBundle approach (Approach B from research-004.md) which separates core and witness families to avoid Lindenbaum control obstacle. Eliminates saturated_extension_exists axiom. (Follow-up from task #844, Phase 5)

---

### 852. Implement CoherentBundle.toBMCS conversion
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-02-03
- **Research**: [research-001.md](specs/852_implement_coherentbundle_tobmcs/reports/research-001.md)
- **Language**: lean
- **Created**: 2026-02-03
- **Parent**: Task 844
- **Depends**: Task 851
- **Summary**: Task subsumed by task 851. The CoherentBundle.toBMCS conversion was fully implemented in task 851 Phase 4 with no sorries.

**Description**: Implement CoherentBundle.toBMCS conversion to provide axiom-free modal_backward. Uses contraposition: if phi in all families but Box phi not in fam.mcs, then Diamond(neg phi) in fam.mcs, so exists witness with neg phi, contradicting phi in all families. Depends on task #851 CoherentBundle structure. (Follow-up from task #844, Phase 4)

---

### 851. Define CoherentBundle structure
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-03
- **Parent**: Task 844
- **Completed**: 2026-02-03
- **Research**: [research-001.md](specs/851_define_coherentbundle_structure/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/851_define_coherentbundle_structure/plans/implementation-001.md)
- **Summary**: Implemented CoherentBundle structure with toBMCS conversion fully proven. Defines UnionBoxContent, MutuallyCoherent predicate, and proves modal_forward/modal_backward for saturated bundles. No sorries - complete infrastructure for axiom-free BMCS construction.

**Description**: Define CoherentBundle structure that collects coherent witnesses with mutual coherence. Requires extending CoherentWitness to enforce coherence not just with base but between all witnesses. May require Zorn's lemma for recursive saturation. (Follow-up from task #844, Phase 3)

---


### 843. Remove singleFamily_modal_backward_axiom after Zorn lemma is proven
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-03
- **Parent**: Task 841
- **Depends**: Task 842

**Description**: Remove singleFamily_modal_backward_axiom after Zorn lemma is proven. Update completeness theorem in Completeness.lean to use construct_bmcs_saturated instead of axiom-based construction. Remove or comment out the axiom declaration. Verify build succeeds and completeness theorems no longer depend on the axiom. (Follow-up from task #841, depends on task #842)

---


### 838. Complete or document SaturatedConstruction sorries
- **Effort**: 32-50 hours (full), 2-4 hours (document)
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-03
- **Source**: /review 2026-02-03

**Description**: Address 12 sorries in Bundle/SaturatedConstruction.lean. Task 827 research indicates 32-50 hours for mathematically correct completion. Options: complete implementation, document as accepted limitation, or simplify approach.

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
- **Status**: [PLANNED]
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 685. Derive world-history and Barcan theorems
- **Effort**: 8-10 hours
- **Status**: [RESEARCHED]
- **Language**: lean
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
- **Status**: [PLANNED]
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


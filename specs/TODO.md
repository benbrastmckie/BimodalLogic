---
next_project_number: 879
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-12T01:08:01Z
task_counts:
  active: 13
  completed: 412
  in_progress: 1
  not_started: 7
  abandoned: 29
  total: 444
technical_debt:
  sorry_count: 161
  axiom_count: 20
  build_errors: 1
  status: manageable
---

# TODO

## Tasks

### 878. Update skill-team-implement to use structured phase dependencies
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-11
- **Completed**: 2026-02-12
- **Dependencies**: Task 876, Task 877
- **Research**: [research-001.md](specs/878_update_skill_team_implement_use_structured_dependencies/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/878_update_skill_team_implement_use_structured_dependencies/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260212.md](specs/878_update_skill_team_implement_use_structured_dependencies/summaries/implementation-summary-20260212.md)

**Description**: Update skill-team-implement/SKILL.md Stage 2 to parse structured Dependencies field from phases instead of heuristic analysis. Build execution waves from parsed dependency graph. Handle missing Dependencies field (backward compat - treat as sequential).

---

### 877. Update planner-agent to generate phase dependencies
- **Effort**: 1.5 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-11
- **Completed**: 2026-02-12
- **Dependencies**: Task 876
- **Research**: [research-001.md](specs/877_update_planner_agent_generate_phase_dependencies/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/877_update_planner_agent_generate_phase_dependencies/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260212.md](specs/877_update_planner_agent_generate_phase_dependencies/summaries/implementation-summary-20260212.md)

**Description**: Update planner-agent.md Stage 5 plan template to include Dependencies field for each phase. Add dependency analysis during Stage 4 (task decomposition). Generate Dependencies field based on outputs/inputs between phases. Reference task-breakdown.md dependency patterns.

---

### 876. Add phase dependency field to plan format standards
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-11
- **Completed**: 2026-02-12
- **Dependencies**: None
- **Research**: [research-001.md](specs/876_add_phase_dependency_field_plan_format_standards/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/876_add_phase_dependency_field_plan_format_standards/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260211.md](specs/876_add_phase_dependency_field_plan_format_standards/summaries/implementation-summary-20260211.md)

**Description**: Add Dependencies field to phase format in plan-format.md and artifact-formats.md. Define notation: Dependencies: None | Phase {N} | Phase {N}, Phase {M}. Ensure backward compatibility (field is optional).

---

### 870. Zorn-based family selection for temporal coherence
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-11
- **Researched**: 2026-02-11
- **Planned**: 2026-02-12
- **Started**: 2026-02-11
- **Research**: [research-001.md](specs/870_zorn_family_temporal_coherence/reports/research-001.md), [research-002.md](specs/870_zorn_family_temporal_coherence/reports/research-002.md), [research-003.md](specs/870_zorn_family_temporal_coherence/reports/research-003.md), [research-004.md](specs/870_zorn_family_temporal_coherence/reports/research-004.md), [research-005.md](specs/870_zorn_family_temporal_coherence/reports/research-005.md)
- **Plan**: [implementation-003.md](specs/870_zorn_family_temporal_coherence/plans/implementation-003.md)
- **Summaries**: [implementation-summary-20260211.md](specs/870_zorn_family_temporal_coherence/summaries/implementation-summary-20260211.md), [implementation-summary-20260212.md](specs/870_zorn_family_temporal_coherence/summaries/implementation-summary-20260212.md), [implementation-summary-20260212-v003.md](specs/870_zorn_family_temporal_coherence/summaries/implementation-summary-20260212-v003.md)
- **Implementation**: [ZornFamily.lean](Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean)

**Description**: Use Zorn's lemma to construct IndexedMCSFamily with guaranteed cross-sign temporal coherence (forward_G, backward_H). This bypasses task 864's chain construction limitations where G phi at time t<0 cannot reach time t'>0 because chains extend away from time 0. Key approach: Define partial order on candidate families satisfying coherence properties, apply Zorn to obtain maximal element. See task 864 session 28-30 analysis for cross-sign challenge details, TemporalLindenbaum.lean for single-MCS Zorn infrastructure, DovetailingChain.lean:606,617 for blocked cross-sign cases. Critical: Ensure termination of Zorn argument, prove maximal family is actually an IndexedMCSFamily, handle witness enumeration for F/P formulas. Success eliminates DovetailingChain sorries at lines 606,617,633,640.

### 868. Reinstate lean-lsp MCP tools after GitHub issue resolution
- **Effort**: 1 hour
- **Status**: [BLOCKED]
- **Language**: meta
- **Created**: 2026-02-11
- **Blocked on**: lean-lsp-mcp issue #115 resolution

**Description**: Once lean-lsp-mcp issue #115 (server halts on lean_diagnostic_messages) is resolved, reinstate the blocked MCP tools. Follow the unblocking procedure: verify fix in repository, update package version, test tools manually, update blocked-mcp-tools.md to mark as UNBLOCKED, remove from CLAUDE.md blocked list, and restore documentation in mcp-tools-guide.md. Consider re-testing lean_file_outline as well since no specific open issue exists for it.

### 865. Construct canonical task frame for Bimodal completeness
- **Effort**: TBD
- **Status**: [RESEARCHING]
- **Language**: lean
- **Created**: 2026-02-05
- **Researched**: 2026-02-10
- **Research**: [research-001.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-001.md), [research-002.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-002.md), [research-003.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-003.md), [research-004.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-004.md), [research-005.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-005.md)

**Description**: Research and construct a canonical task frame (world-states, task relation, durations) for the Bimodal logic representation theorem. Define a two-place task relation w ⇒ u where: (1) φ ∈ u whenever □G φ ∈ w; (2) φ ∈ w whenever □H φ ∈ u; with witness conditions (GW) and (HW). World histories are functions τ from a totally ordered commutative group of durations to MCSs respecting the task relation. Key challenges: constructing durations from syntax, building a proper three-place task relation matching the semantics, and possibly using the two-place task relation to construct a topology (closeness via possible nearness in time) with durations abstracted as equivalence classes. The construction should culminate in a seed built from a consistent sentence of arbitrary complexity, with the canonical model satisfying the TruthLemma as the guiding North Star.

### 864. Implement recursive seed construction for Henkin model completeness
- **Effort**: 36 hours
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-05
- **Researched**: 2026-02-10
- **Planned**: 2026-02-10
- **Research**: [research-001.md](specs/864_recursive_seed_henkin_model/reports/research-001.md), [research-002.md](specs/864_recursive_seed_henkin_model/reports/research-002.md)
- **Plan**: [implementation-002.md](specs/864_recursive_seed_henkin_model/plans/implementation-002.md) (v2), [implementation-001.md](specs/864_recursive_seed_henkin_model/plans/implementation-001.md) (v1)

**Description**: Improving on task 843 and the various attempts tried there, develop a new strategy which proceeds by taking a consistent formula and using its recursive structure to define a seed which consists of a bundle of indexed families of MCSs. The idea is to start with a singleton CS indexed at 0 for the consistent sentence we start with. If the main operator is a Box, then every CS must include its argument. If the main operator is a negated Box, then some indexed family must have a CS indexed by the present time that includes the negation of its argument. If the main operator is H, then every CS indexed by a present and past time in the family must include the argument. If the main operator is a negated H, then some CS indexed by the present or past time in the family must include the negation of the argument. Similarly for G, but for the future. Negated modal operators require new indexed families to be created, and negated tense operators require new CSs at new indexes to be created. Boolean operators unpack in the usual way. This returns some indexed families with some CSs based on the logical form of the initial sentence. This is then completed to provide an appropriate Henkin model.

### 843. Remove singleFamily_modal_backward_axiom after Zorn lemma is proven
- **Effort**: 50-65 hours (revised v008)
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-03
- **Updated**: 2026-02-10
- **Researched**: 2026-02-05
- **Planned**: 2026-02-10
- **Depends**: Task 856
- **Related**: Task 856, Task 857
- **Research**: [research-001.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-001.md) through [research-017.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-017.md)
- **Plan**: [implementation-008.md](specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-008.md)

**Description**: Make Bimodal/Metalogic/ axiom-free and sorry-free for publication-ready completeness. Eliminate 2 completeness-chain axioms (singleFamily_modal_backward_axiom, temporally_saturated_mcs_exists) via temporal Lindenbaum construction and multi-family saturated BMCS. Delete 4 legacy eval_bmcs_truth_lemma sorries.

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



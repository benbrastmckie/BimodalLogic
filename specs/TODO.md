---
next_project_number: 893
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-17T22:15:38Z
task_counts:
  active: 13
  completed: 607
  in_progress: 2
  not_started: 5
  abandoned: 29
  total: 646
technical_debt:
  sorry_count: 200
  axiom_count: 20
  build_errors: 1
  status: manageable
---

# TODO

## Tasks

### 892. Modify henkinStep to add negations when rejecting packages
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-17
- **Parent**: Task #888

**Description**: Modify henkinStep in TemporalLindenbaum.lean to add negations when rejecting packages. Currently henkinStep adds temporalPackage(phi) when consistent but does NOT add neg(phi) when rejecting. This allows scenarios where M is maximal in TCS but not an MCS. The fix enables maximal_tcs_is_mcs to become provable. This is blocking task 888 Phase 3.

---

### 891. Fix split-at tactic incompatibility in TemporalLindenbaum.lean
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-17
- **Parent**: Task #888

**Description**: Fix the split-at tactic incompatibility in TemporalLindenbaum.lean for Lean 4.27.0-rc1. The temporalWitnessChain function unfolds with have-bindings that the split tactic cannot handle. Convert all split-at patterns to explicit cases patterns. This is blocking task 888 Phase 3.

---

### 890. Fix measure_wf build error in TemporalLindenbaum.lean
- **Effort**: 5 minutes
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-17
- **Researched**: 2026-02-17
- **Planned**: 2026-02-17
- **Completed**: 2026-02-17
- **Research**: [research-001.md](specs/890_fix_measure_wf_build_error_temporallindenbaum/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/890_fix_measure_wf_build_error_temporallindenbaum/plans/implementation-001.md)

**Description**: Fix the Unknown identifier measure_wf build error in TemporalLindenbaum.lean at lines 220 and 263. This pre-existing error is blocking task 888 from completing. The identifier measure_wf is used for well-founded induction in helper lemmas. Likely a missing import or definition.

---

### 889. Review artifact naming scheme for team workflow uniformity
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-02-17
- **Planned**: 2026-02-17
- **Completed**: 2026-02-17
- **Language**: meta
- **Research**: [research-001.md](specs/889_artifact_naming_scheme_review/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/889_artifact_naming_scheme_review/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260217.md](specs/889_artifact_naming_scheme_review/summaries/implementation-summary-20260217.md)

**Description**: Review the artifact naming scheme used by the workflow command-skill-agent workflows in the .claude/ agent system to make sure there is a standard approach used both with and without the --team flag. For instance, `/research --team NNN` should create reports that have both the report number followed by the team member, and then call a team member to synthesize to create just a report with the appropriate number. Review all other cases where team members might create artifacts that don't indicate the research run, or planning run, etc., that they are associated with. The aim is uniformity of approach.

---

### 888. Research Lindenbaum temporal saturation preservation for witness families
- **Effort**: 8-12 hours
- **Status**: [BLOCKED]
- **Planned**: 2026-02-17
- **Started**: 2026-02-17
- **Blocked**: Two blockers: (1) Build errors - split-at tactic incompatibility in Lean 4.27.0-rc1, (2) Mathematical - maximal_tcs_is_mcs is unprovable without modifying henkinStep to add negations
- **Depends**: Task #890
- **Plan**: [implementation-001.md](specs/888_lindenbaum_temporal_saturation_preservation/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260217.md](specs/888_lindenbaum_temporal_saturation_preservation/summaries/implementation-summary-20260217.md)
- **Language**: lean
- **Created**: 2026-02-17
- **Researched**: 2026-02-17
- **Parent**: Task #881
- **Research**: [research-001.md](specs/888_lindenbaum_temporal_saturation_preservation/reports/research-001.md)

**Description**: Research the mathematical gap blocking temporal coherence of witness families. Task 887's FinalConstruction.lean has sorries because regular Lindenbaum extension does NOT preserve temporal saturation - it can add F(psi) formulas without adding their witness psi. Research questions: (1) Can Lindenbaum preserve temporal saturation when seed contains sufficient temporal content ({psi} union M where M is temporally saturated)? (2) If not, can we use temporal-aware Lindenbaum that adds F(psi) and psi together? (3) Is there an alternative architectural approach that avoids this issue entirely? (4) Does the truth lemma actually require all families to be temporally coherent, or only eval_family? Output: Clear mathematical characterization of the gap, proof or disproof of preservation conditions, and recommended remediation path.

---

### 882. Fix 5 sorries in TemporalLindenbaum.lean to unblock task 881 axiom elimination
- **Effort**: 8 to 12 hours
- **Status**: [BLOCKED]
- **Language**: lean
- **Parent**: Task #881
- **Researched**: 2026-02-13
- **Planned**: 2026-02-13
- **Blocked**: Fundamental gaps in temporalLindenbaumMCS approach - single-MCS temporal saturation not achievable
- **Research**: [research-001.md](specs/882_fix_temporallindenbaum_sorries/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/882_fix_temporallindenbaum_sorries/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260213.md](specs/882_fix_temporallindenbaum_sorries/summaries/implementation-summary-20260213.md)

**Description**: Fix 5 sorries in TemporalLindenbaum.lean to unblock task 881 axiom elimination. Sorries: henkinLimit_forward_saturated base case (line 444), henkinLimit_backward_saturated base case (line 485), maximal_tcs_is_mcs F-formula case (line 655), maximal_tcs_is_mcs P-formula case (line 662), generic temporal_coherent_family_exists (line 636). These block the constructive proof of fully_saturated_bmcs_exists.

### 881. Construct modally saturated BMCS to eliminate fully_saturated_bmcs_exists axiom
- **Effort**: 8-12 hours
- **Status**: [BLOCKED]
- **Language**: lean
- **Created**: 2026-02-13
- **Researched**: 2026-02-16
- **Planned**: 2026-02-17
- **Blocked**: Task 887 completed with sorries. Temporal coherence of witness families requires temporal-aware Lindenbaum. See task 888.
- **Dependencies**: Task 888 (research required)
- **Research**: [research-011.md](specs/881_modally_saturated_bmcs_construction/reports/research-011.md) (Implementation review, remaining work after task 887), [research-010.md](specs/881_modally_saturated_bmcs_construction/reports/research-010.md) (Team v10: Option D)
- **Plan**: [implementation-007.md](specs/881_modally_saturated_bmcs_construction/plans/implementation-007.md) (v7: No technical debt; Options A/C/D decision tree)
- **Summary**: [implementation-summary-20260217.md](specs/881_modally_saturated_bmcs_construction/summaries/implementation-summary-20260217.md) (Phase 3 escalation)

**Description**: Replace the `fully_saturated_bmcs_exists` axiom in TemporalCoherentConstruction.lean with a constructive proof, achieving fully axiom-free completeness. The axiom currently requires: (1) context preservation, (2) temporal coherence, and (3) modal saturation. Tasks 870/880 have proven temporal coherence via ZornFamily/DovetailingChain, but modal saturation remains. Modal saturation requires that every Diamond formula in a family's MCS has a witness family in the bundle where the inner formula holds. The construction must enumerate all Diamond formulas (neg(Box(neg psi))) and extend the family set to include witnesses. Key approaches: (a) Extend ZornFamily with modal witness enumeration using Zorn's lemma on families satisfying both temporal coherence AND modal saturation conditions, (b) Extend DovetailingChain to interleave modal witness creation with temporal witness creation, or (c) Post-process a temporally coherent family by iteratively adding modal witnesses until saturated. Critical challenge: Proving termination/well-foundedness when adding infinitely many witness families. Success eliminates the final axiom blocker for sorry-free completeness, connecting proven temporal infrastructure (RecursiveSeed, ZornFamily) to the representation theorem. See ModalSaturation.lean for is_modally_saturated definition, Completeness.lean for usage, and DovetailingChain.lean/ZornFamily.lean for temporal coherence infrastructure to extend.

### 870. Zorn-based family selection for temporal coherence
- **Effort**: TBD
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-11
- **Researched**: 2026-02-11
- **Planned**: 2026-02-12
- **Started**: 2026-02-11
- **Research**: [research-001.md](specs/870_zorn_family_temporal_coherence/reports/research-001.md), [research-002.md](specs/870_zorn_family_temporal_coherence/reports/research-002.md), [research-003.md](specs/870_zorn_family_temporal_coherence/reports/research-003.md), [research-004.md](specs/870_zorn_family_temporal_coherence/reports/research-004.md), [research-005.md](specs/870_zorn_family_temporal_coherence/reports/research-005.md), [research-006.md](specs/870_zorn_family_temporal_coherence/reports/research-006.md)
- **Plan**: [implementation-004.md](specs/870_zorn_family_temporal_coherence/plans/implementation-004.md)
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

### 619. Migrate skills to native context:fork isolation
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-02-17
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-28
- **Planned**: 2026-01-19
- **Blocked on**: GitHub anthropics/claude-code #16803 (context:fork runs inline instead of forking)
- **Research**: [research-001.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-001.md), [research-006.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-006.md), [research-007.md](specs/619_agent_system_architecture_upgrade/reports/research-007.md)
- **Plan**: [implementation-002.md](specs/archive/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: Migrate all delegation skills from manual Task tool invocation to native `context: fork` frontmatter. Skills to migrate: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta. Implementation plan has 3 phases: (1) verify bug fix with test skill, (2) migrate skill-researcher as pilot, (3) migrate remaining skills. Current workaround (Task tool delegation) continues to work. **Unblock when**: GitHub #16803 is closed AND fix verified locally. Last checked: 2026-02-17 — still OPEN (v2.1.32).

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
- **Status**: [PARTIAL]
- **Language**: lean
- **Created**: 2026-02-03
- **Updated**: 2026-02-12
- **Researched**: 2026-02-05
- **Planned**: 2026-02-10
- **Completed**: 2026-02-12 (Phase 4 only)
- **Depends**: Task 856
- **Related**: Task 856, Task 857, Task 864
- **Research**: [research-001.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-001.md) through [research-018.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-018.md)
- **Plan**: [implementation-008.md](specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-008.md)

**Description**: Make Bimodal/Metalogic/ axiom-free and sorry-free for publication-ready completeness. Eliminate 2 completeness-chain axioms (singleFamily_modal_backward_axiom, temporally_saturated_mcs_exists) via temporal Lindenbaum construction and multi-family saturated BMCS. Delete 4 legacy eval_bmcs_truth_lemma sorries.

**Completion Note**: Phase 4 completed successfully - FALSE axiom (singleFamily_modal_backward_axiom) replaced with CORRECT axiom (fully_saturated_bmcs_exists). Remaining phases superseded by task 864's recursive seed approach.

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



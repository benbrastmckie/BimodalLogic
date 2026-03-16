---
next_project_number: 972
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-15T18:30:00Z
task_counts:
  active: 14
  completed: 674
  in_progress: 0
  not_started: 8
  abandoned: 42
  total: 730
technical_debt:
  sorry_count: 22
  sorry_count_note: "Excluding Boneyard: 9 metalogic (non-publication), 13 examples"
  publication_path_sorries: 0
  axiom_count: 0
  axiom_count_note: "Zero custom axioms on publication path"
  build_errors: 0
  status: excellent
---

# TODO

## Tasks

### 971. Refactor to eliminate bmcs_truth_at layer
- **Effort**: 3.5 hours (7 phases)
- **Status**: [RESEARCHED]
- **Language**: logic
- **Research**: [research-001.md](specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-001.md), [research-002.md](specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-002.md) (7 elimination opportunities, full simplification)
- **Plan**: [implementation-001.md](specs/971_refactor_eliminate_bmcs_truth_at_layer/plans/implementation-001.md) (7 phases, deprecation + archival) - needs revision

**Description**: Research and implement a systematic refactor to fully eliminate the `bmcs_truth_at` layer as reported in the task 970 research findings. The research confirms `bmcs_truth_at` is explicitly documented as redundant (CanonicalConstruction.lean line 20). Recommended approach: derive `bmcs_truth_lemma` as corollary of `canonical_truth_lemma`, mark BFMCSTruth.lean as deprecated, remove 4 unused definitions (`bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context`, internal theorems).

---

### 970. Review metalogic for publication readiness
- **Effort**: 14 hours (12 phases)
- **Status**: [RESEARCHED]
- **Language**: logic
- **Research**: [research-001.md](specs/970_review_metalogic_for_publication/reports/research-001.md) (team: 2 teammates, redundancy analysis) | [research-002.md](specs/970_review_metalogic_for_publication/reports/research-002.md) (phases 5-9 + task 971 coordination)
- **Plan**: [implementation-002.md](specs/970_review_metalogic_for_publication/plans/implementation-002.md) (v2: 12 phases, semantic framework + theorem formulations)
- **Summary**: [implementation-summary-20260315.md](specs/970_review_metalogic_for_publication/summaries/implementation-summary-20260315.md) (partial: 7/12 phases)

**Description**: Systematically review the metalogic to identify redundant definitions requiring bridge theorems or lemmas that can be removed in preference of direct implementation with correct semantic definitions. Simplify the space of defined terms, avoiding aliases or technical debt that could be refactored out. Examples include `bmcs_truth_lemma` and related artifacts from the laborious process of establishing representation and completeness theorems. Ensure all major theorems take mathematically standard forms relative to the provided semantics.

---

### 953. Refactor proof system to bilateral system
- **Effort**: 55-90 hours
- **Status**: [PLANNING]
- **Language**: lean
- **Priority**: medium
- **Research**: [research-001.md](specs/953_refactor_proof_system_to_bilateral/reports/research-001.md)

**Description**: Refactor the TM proof system from a unilateral system (single judgment `Γ ⊢ φ`) to a bilateral system with dual judgments: acceptance (`Γ ⊢⁺ φ`) and rejection (`Γ ⊢⁻ φ`). The bilateral system makes the dual roles of assertion and denial explicit, with rules governing how acceptance and rejection interact across all connectives and operators. Key design: keep Formula type unchanged (Option A), add BilateralDeriv alongside existing DerivationTree with a proven equivalence bridge. Several current axioms (ex_falso, peirce, modal_t, temp_t_future, temp_t_past) become structural rules in the bilateral system. The existing signed formula infrastructure in the decidability module provides the blueprint.

**Implementation approach**: Parallel bilateral system with equivalence bridge — not a replacement. Phase 1: bilateral infrastructure (BilateralContext, BilateralDeriv). Phase 2: prove equivalence with unilateral system. Phase 3: bilateral metalogic (MCS, FMCS, completeness). Phase 4: bilateral decidability integration.

---

### 949. Update Demo.lean for current bimodal logic state
- **Effort**: Small (~2 hours)
- **Status**: [PLANNING]
- **Language**: lean
- **Research**: [research-001.md](specs/949_update_demo_lean_bimodal_logic/reports/research-001.md)

**Description**: Update Theories/Bimodal/Examples/Demo.lean given the current state of the bimodal logic. The demo file should reflect the current API and showcase the working features of the bimodal logic implementation.

---

### 929. Prepare metalogic for publication
- **Effort**: 10-13 hours (revised estimate)
- **Status**: [COMPLETED]
- **Language**: lean
- **Research**: [research-001.md](specs/929_prepare_metalogic_for_publication/reports/research-001.md) (team: 3 teammates, full publication readiness checklist)
- **Plan**: [implementation-001.md](specs/929_prepare_metalogic_for_publication/plans/implementation-001.md) (9 phases)
- **Summary**: [implementation-summary-20260315.md](specs/929_prepare_metalogic_for_publication/summaries/implementation-summary-20260315.md)

**Description**: Systematic preparation of the bimodal temporal logic metalogic for publication. The codebase currently has two independent sorry-free, axiom-free completeness proofs (BMCS via ChainBundleBMCS.lean and FMP via SemanticCanonicalModel.lean), a sound and complete decidability procedure, and a clean build. The following work remains before publication:

**Phase 1 — Abandon obsolete tasks**: The completion of Task 925 (sorry-free BMCS completeness) superseded several alternative proof strategies that are no longer needed. Abandon the following tasks with justification:
- Task 865 (canonical_task_frame_bimodal_completeness): Research into earlier canonical-frame completeness approach, now superseded by ChainBundleBMCS
- Task 881 (modally_saturated_bmcs_construction): Was a stepping stone toward DovetailingChain; the BMCS path (Task 925) provides sorry-free completeness without it
- Task 916 (implement_fp_witness_obligation_tracking): The F/P witness DovetailingChain path had an irreducible F-persistence gap; Task 925's BMCS approach sidesteps this entirely
- Task 917 (fix_forward_f_backward_p_temporal_witness_strictness): Documentation fix for concepts in Task 916; moot if Task 916 is abandoned
- Task 922 (strategy_study_fp_witness_completeness_blockers): Research prerequisite for Task 916; moot if Task 916 is abandoned

**Phase 2 — Ensure Task 928 is complete**: Task 928 (terminology refactoring BMCS→BFMCS) must be fully complete before publication. Verify all phases of Task 928 are done, including Boneyard cleanup (Phase 2 of that task).

**Phase 3 — Axiom and sorry annotation/cleanup**: The 5 remaining sorries and 2 custom axioms in the main metalogic all lie on non-BMCS proof paths. They do not affect the publication-ready results but need clear annotation:
- `Construction.lean:197` (`singleFamilyBMCS.modal_backward`): Mark as superseded; the single-family wrapper approach is no longer the primary path (ChainBundleBMCS is). Consider whether to remove `Construction.lean` entirely or clearly comment it as a deprecated/archived proof attempt.
- `DovetailingChain.lean:1869,1881` (`buildDovetailingChainFamily_forward_F`, `buildDovetailingChainFamily_backward_P`): The F/P witness gap. Add a module-level docstring clearly stating this file contains an unfinished alternative completeness path that is not part of the primary proof.
- `TemporalCoherentConstruction.lean:613,819`: These sorries are consequences of the `fully_saturated_bmcs_exists` axiom. Add clear annotation explaining the axiom and its scope.
- `fully_saturated_bmcs_exists` axiom (TemporalCoherentConstruction.lean:755): This axiom is used only by `standard_weak_completeness` / `standard_strong_completeness`, which are NOT on the primary BMCS proof path. Add a docstring: "This axiom asserts Henkin-style saturation; it is NOT needed for `bmcs_weak_completeness_mcs` or `bmcs_strong_completeness_mcs`, which are sorry-free and axiom-free." Consider running lean_verify on the primary theorems to confirm and document the axiom-free dependency chain.
- `saturated_extension_exists` axiom (CoherentConstruction.lean:871): Marked in audit as deprecated/superseded by Task 925. Remove or replace with a comment that this is archived research (the axiom is no longer needed).

**Phase 4 — Publication documentation**: Create or update the following documentation:
- Update `Metalogic.lean` (main export file) with a detailed module docstring explaining: (a) the logical system (bimodal temporal propositional logic TM), (b) the main theorems proven (soundness, BMCS weak/strong completeness, FMP weak completeness, decidability), (c) the key proof innovation (MCS-membership box semantics in ChainBundleBMCS that avoids requiring universal temporal coherence), (d) an explicit dependency map from the publication-ready theorems to their axiom dependencies (only standard Lean: propext, Classical.choice, Quot.sound).
- Add or update module docstrings in `ChainBundleBMCS.lean` and `FMP/SemanticCanonicalModel.lean` with theorem statements, proof strategies, and commentary suitable for a reader unfamiliar with the project history.
- Ensure `Soundness.lean` and `SoundnessLemmas.lean` have docstrings connecting them to the completeness theorems.
- Create a `docs/publication-summary.md` or `docs/THEOREMS.md` file listing all publication-ready results with their Lean names, file locations, and axiom dependencies (output of `#check` and `#print axioms`).

**Phase 5 — Verification pass**: Before finalizing for publication:
- Run `lean_verify` on `bmcs_weak_completeness_mcs`, `bmcs_strong_completeness_mcs`, `soundness`, and `fmp_weak_completeness` to confirm axiom dependencies
- Run `lake clean && lake build` to confirm zero build errors from a clean state
- Count and document: total active files, total sorry-free theorems, total sorries in non-primary paths, total custom axioms (target: 0 on primary path)

**Key context**:
- Primary publication path: `Soundness.lean` + `ChainBundleBMCS.lean` + `FMP/SemanticCanonicalModel.lean` + `Decidability/DecisionProcedure.lean` — all sorry-free, all axiom-free
- Innovation to highlight: MCS-membership box semantics (`φ ∈ fam'.mcs t` instead of evaluating φ at fam') decouples box-truth from universal temporal coherence
- 44/49 active files are sorry-free; 5 sorries all lie in non-primary alternative proof paths
- The Boneyard contains 147 archived files with 187 sorries representing exhausted research paths; these are intentionally archived and do not affect build or publication

---

### 868. Reinstate lean-lsp MCP tools after GitHub issue resolution
- **Effort**: 1 hour
- **Status**: [BLOCKED]
- **Language**: meta
- **Created**: 2026-02-11
- **Blocked on**: lean-lsp-mcp issue #115 resolution

**Description**: Once lean-lsp-mcp issue #115 (server halts on lean_diagnostic_messages) is resolved, reinstate the blocked MCP tools. Follow the unblocking procedure: verify fix in repository, update package version, test tools manually, update blocked-mcp-tools.md to mark as UNBLOCKED, remove from CLAUDE.md blocked list, and restore documentation in mcp-tools-guide.md. Consider re-testing lean_file_outline as well since no specific open issue exists for it.

### 619. Migrate skills to native context:fork isolation
- **Effort**: 3 hours
- **Status**: [PLANNING]
- **Researched**: 2026-02-17
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-28
- **Planned**: 2026-01-19
- **Blocked on**: GitHub anthropics/claude-code #16803 (context:fork runs inline instead of forking)
- **Research**: [research-001.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-001.md), [research-006.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-006.md), [research-007.md](specs/619_agent_system_architecture_upgrade/reports/research-007.md)
- **Plan**: [implementation-002.md](specs/archive/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: Migrate all delegation skills from manual Task tool invocation to native `context: fork` frontmatter. Skills to migrate: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta. Implementation plan has 3 phases: (1) verify bug fix with test skill, (2) migrate skill-researcher as pilot, (3) migrate remaining skills. Current workaround (Task tool delegation) continues to work. **Unblock when**: GitHub #16803 is closed AND fix verified locally. Last checked: 2026-02-17 — still OPEN (v2.1.32).

### 793. Fix Claude Code neovim sidebar black screen delay
- **Effort**: S
- **Status**: [PLANNING]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/793_fix_claude_code_neovim_sidebar_black_screen/reports/research-001.md)

**Description**: Investigate and fix issue where running a command in Claude Code sidebar in neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. Functionality works correctly otherwise. Issue started recently. Root cause may be in hook system or external. Research online and review hook configuration to identify simple and elegant fix.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [PLANNING]
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [RESEARCHING]
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [RESEARCHING]
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 685. Derive world-history and Barcan theorems
- **Effort**: 8-10 hours
- **Status**: [PLANNING]
- **Language**: lean
 **Created**: 2026-01-26
 **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)
 **Research**: [research-001.md](specs/685_derive_world_history_and_barcan_theorems/reports/research-001.md)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---



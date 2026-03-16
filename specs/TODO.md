---
next_project_number: 981
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

### 980. Remove DN-based seriality proofs technical debt
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Remove the technical debt associated with the DN-based seriality proofs listed under non-goals in specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/plans/implementation-001.md

---

### 979. Remove discrete_Icc_finite_axiom and prove stage-bounding lemma
- **Effort**: 6 hours (6 phases)
- **Status**: [IMPLEMENTING]
- **Research**: [research-001.md](specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-001.md) (team: SuccOrder-first approach via DF frame condition)
- **Plan**: [implementation-001.md](specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/plans/implementation-001.md) (6 phases: DF extraction approach)
- **Language**: lean
- **Related**: Task 974 (Phase 7b escape valve), research-006.md

**Description**: Remove the axiom in Phase 7b (discrete_Icc_stage_bounded) of task 974 implementation plan, reflecting on research-006.md to provide the most mathematically correct approach with no compromises, producing the highest quality implementation.

---

### 978. Refactor TM proof system to typeclass-based frame condition architecture
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: logic
- **Depends on**: Task 977 (must be completed first)

**Description**: Following the completion of task 977 (which fills all metalogic gaps), refactor the TM proof system to implement the typeclass-based frame condition architecture described in the task 977 research (teammate D, architecture Option A). The refactor should make no compromises in pursuit of the most mathematically correct approach:

1. **Frame condition typeclasses**: Define `DenseFrame`, `DiscreteFrame`, and `SerialFrame` typeclasses that capture the precise frame conditions corresponding to each extension axiom, enabling Lean's typeclass resolution to automatically handle extension composition.

2. **Parameterized axiom availability**: Refactor the axiom system so that extension axioms are only available under their corresponding typeclass constraints — density axiom under `[DenseFrame D]`, discreteness under `[DiscreteFrame D]`, seriality under `[SerialFrame D]` — enforcing correctness at the type level rather than via predicates.

3. **Type-level proof system separation**: Introduce separate derivation types (or a single derivation type parameterized by frame class) so that a proof in TM Dense is structurally distinguished from a proof in TM Base — eliminating the possibility of accidentally using extension axioms in a base-logic proof.

4. **Generic soundness and completeness**: Refactor the soundness and completeness theorems to be parameterized over frame typeclasses, so that `soundness [DenseFrame D]` and `completeness [DenseFrame D]` follow generically from the base theorems plus the extension axiom validity.

5. **Directory reorganization**: Restructure `Theories/Bimodal/` to reflect the clean base/extension separation, with dedicated subdirectories for each logic variant and its metalogic.

The goal is a fully modular, typeclass-driven architecture where adding a new temporal logic extension (e.g., a completeness axiom for real-closed fields) requires only: (a) a new frame typeclass, (b) a new axiom with that typeclass constraint, and (c) a validity proof — with soundness and completeness inherited automatically from the generic framework.

---

### 977. Organize TM base logic with extensions
- **Effort**: 16-20 hours (8 phases)
- **Status**: [COMPLETED]
- **Language**: logic
- **Research**: [research-001.md](specs/977_organize_tm_base_logic_with_extensions/reports/research-001.md), [research-002.md](specs/977_organize_tm_base_logic_with_extensions/reports/research-002.md) (plan revision analysis)
- **Plan**: [implementation-002.md](specs/977_organize_tm_base_logic_with_extensions/plans/implementation-002.md) (v2: added Phase 0 DurationTransfer fix)
- **Summary**: [implementation-summary-20260316.md](specs/977_organize_tm_base_logic_with_extensions/summaries/implementation-summary-20260316.md)

**Description**: Organized TM proof system into Base/Dense/Discrete layers with FrameClass enumeration (18 Base, 1 Dense, 3 Discrete axioms). Created completeness modules documenting infrastructure status and gaps. Added LogicVariants.lean as unified summary, documenting DN dependency technical debt for discrete construction. All 4 new Lean files compile without new sorries.

---

### 976. Clean up comments and improve documentation
- **Effort**: 12 hours (8 phases)
- **Status**: [COMPLETED]
- **Language**: general
- **Research**: [research-001.md](specs/976_clean_up_comments_improve_documentation/reports/research-001.md), [research-002.md](specs/976_clean_up_comments_improve_documentation/reports/research-002.md)
- **Plan**: [implementation-001.md](specs/976_clean_up_comments_improve_documentation/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260316.md](specs/976_clean_up_comments_improve_documentation/summaries/implementation-summary-20260316.md)

**Description**: Cleaned up comments and improved documentation across the entire codebase. Removed all references to non-existent FMP/ and LogosTest/ directories, fixed case consistency issues in docs/ links, created 31 new README.md files, updated outdated sorry counts and file listings, and refreshed ROAD_MAP.md with current project state. Total README count increased from ~51 to 82.

---

### 975. Fix ProofSearch documentation example sorries
- **Effort**: 0.5 hours (1 phase)
- **Status**: [COMPLETED]
- **Language**: lean
- **Research**: [research-001.md](specs/975_fix_proofsearch_example_sorries/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/975_fix_proofsearch_example_sorries/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260316.md](specs/975_fix_proofsearch_example_sorries/summaries/implementation-summary-20260316.md)

**Description**: Fixed 3 sorry placeholders in `Theories/Bimodal/Automation/ProofSearch.lean` example blocks using DerivationTree constructors: `axiom` with `Axiom.modal_t`, `modus_ponens`, and `assumption`.

---

### 974. Prove SuccOrder/PredOrder/IsSuccArchimedean in DiscreteTimeline.lean
- **Effort**: 5 hours (8 phases)
- **Status**: [COMPLETED]
- **Language**: lean
- **Research**: [research-001.md](specs/974_prove_discrete_timeline_succorder_predorder/reports/research-001.md), [research-002.md](specs/974_prove_discrete_timeline_succorder_predorder/reports/research-002.md), [research-003.md](specs/974_prove_discrete_timeline_succorder_predorder/reports/research-003.md) (team: strategic blocker analysis), [research-004.md](specs/974_prove_discrete_timeline_succorder_predorder/reports/research-004.md) (DurationTransfer blocker analysis), [research-005.md](specs/974_prove_discrete_timeline_succorder_predorder/reports/research-005.md) (current standing post-DT fix), [research-006.md](specs/974_prove_discrete_timeline_succorder_predorder/reports/research-006.md) (team: LocallyFiniteOrder strategy)
- **Plan**: [implementation-005.md](specs/974_prove_discrete_timeline_succorder_predorder/plans/implementation-005.md) (v5: elegant LocallyFiniteOrder via stage bounding)
- **Summary**: [implementation-summary-20260316.md](specs/974_prove_discrete_timeline_succorder_predorder/summaries/implementation-summary-20260316.md)

**Description**: Resolved 3 sorries in DiscreteTimeline.lean by instantiating LocallyFiniteOrder on the discrete timeline quotient. Used escape valve to axiomatize interval finiteness (discrete_Icc_finite_axiom) as documented technical debt. SuccOrder/PredOrder properties follow from Mathlib's LinearLocallyFiniteOrder infrastructure.

---

### 973. Prove NoMaxOrder/NoMinOrder on ConstructiveQuotient
- **Effort**: 2 hours (5 phases)
- **Status**: [COMPLETED]
- **Language**: lean
- **Research**: [research-001.md](specs/973_prove_constructivefragment_nomaxorder_nominorder/reports/research-001.md), [research-002.md](specs/973_prove_constructivefragment_nomaxorder_nominorder/reports/research-002.md), [research-003.md](specs/973_prove_constructivefragment_nomaxorder_nominorder/reports/research-003.md) (import conflict resolution)
- **Plan**: [implementation-003.md](specs/973_prove_constructivefragment_nomaxorder_nominorder/plans/implementation-003.md) (v3: file extraction approach)
- **Summary**: [implementation-summary-20260316.md](specs/973_prove_constructivefragment_nomaxorder_nominorder/summaries/implementation-summary-20260316.md)

**Description**: Proved NoMaxOrder and NoMinOrder instances for ConstructiveQuotient by creating `CanonicalSerialFrameInstance.lean` using seriality witnesses and `canonicalR_strict` for strictness. File extraction approach (Solution 2) avoids import conflict and foreshadows task 978's typeclass architecture.

---

### 972. Review metalogic naming conventions for improvements
- **Effort**: 6-8 hours (6 phases)
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-03-16
- **Research**: [research-001.md](specs/972_review_metalogic_naming_conventions/reports/research-001.md), [research-002.md](specs/972_review_metalogic_naming_conventions/reports/research-002.md) (namespace migration)
- **Plan**: [implementation-002.md](specs/972_review_metalogic_naming_conventions/plans/implementation-002.md) (v2: full namespace migrations)
- **Summary**: [implementation-summary-20260316.md](specs/972_review_metalogic_naming_conventions/summaries/implementation-summary-20260316.md)

**Description**: Renamed GContent/HContent to snake_case, migrated bmcs_*, set_mcs_*, and mcs_* prefixed functions to proper Lean namespaces (BFMCS and SetMaximalConsistent). Enables dot notation throughout Metalogic/. Build passes with 975 jobs.

---

### 971. Refactor to eliminate bmcs_truth_at layer
- **Effort**: 5 hours (8 phases)
- **Status**: [COMPLETED]
- **Language**: logic
- **Research**: [research-001.md](specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-001.md), [research-002.md](specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-002.md), [research-003.md](specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-003.md) (deep-dive on 7 simplification opportunities)
- **Plan**: [implementation-002.md](specs/971_refactor_eliminate_bmcs_truth_at_layer/plans/implementation-002.md) (8 phases, aggressive clean-break elimination)
- **Summary**: [implementation-summary-20260316.md](specs/971_refactor_eliminate_bmcs_truth_at_layer/summaries/implementation-summary-20260316.md) (completed: full elimination, build passes 975 jobs)

**Description**: Aggressive clean-break refactor to fully eliminate the `bmcs_truth_at` layer. Unlike the conservative approach (implementation-001.md), this plan directly uses `canonical_truth_lemma` everywhere, archiving BFMCSTruth.lean and TruthLemma.lean to Boneyard/Task971/ with no compatibility shims. Research confirms `bmcs_truth_lemma` has NO non-deprecated code usage outside its module, making full elimination straightforward.

---

### 970. Review metalogic for publication readiness
- **Effort**: 10 hours (11/12 phases complete)
- **Status**: [COMPLETED]
- **Language**: logic
- **Research**: [research-001.md](specs/970_review_metalogic_for_publication/reports/research-001.md) (team: 2 teammates, redundancy analysis) | [research-002.md](specs/970_review_metalogic_for_publication/reports/research-002.md) (phases 5-9 + task 971 coordination)
- **Plan**: [implementation-004.md](specs/970_review_metalogic_for_publication/plans/implementation-004.md) (v4: remove weak completeness, full naming cleanup incl. SetMaximalConsistent)
- **Summary**: [implementation-summary-20260315.md](specs/970_review_metalogic_for_publication/summaries/implementation-summary-20260315.md) (11/12 phases; phase 9 spun off to task 972)

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



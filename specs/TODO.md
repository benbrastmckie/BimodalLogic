---
next_project_number: 64
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-23T13:20:00Z
task_counts:
  active: 20
  completed: 725
  in_progress: 0
  not_started: 6
  abandoned: 54
  total: 792
technical_debt:
  sorry_count: 98
  sorry_count_note: "Per ROADMAP.md: 24 SuccChain (critical), 16 examples, 16 perpetuity, 9 completeness wiring, 5 soundness, 4 FMP, 4 RestrictedMCS, 20 infra"
  publication_path_sorries: 24
  axiom_count: 2
  axiom_count_note: "f_nesting_boundary, p_nesting_boundary (tasks 36, 37). Task 42 tracks elimination."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-03-25. Task 62 completed (documentation corrections). Task 63 created for BFMCS Box backward proof.*

**Goal**: Zero custom axioms, zero sorries on the completeness path.

### 1. Critical Path — Sorry-Free Completeness

```
63 → 58 → 59 → 60
```

1. **63** [COMPLETED] — Prove Box backward via BFMCS modal saturation; eliminate singleton-Omega dead end
2. **58** [NOT STARTED] — Wire completeness to FrameConditions (3 sorries)
3. **59** [NOT STARTED] — Prove frame-specific soundness axioms (5 sorries)
4. **60** [NOT STARTED] — Remove discrete_Icc_finite_axiom (custom axiom)

### 2. Code Cleanup (parallel to critical path)

1. **57** [NOT STARTED] — Clean up UltrafilterChain.lean, remove unused ultrafilter relations

### 3. Experimental

- **61** [NOT STARTED] — Eliminate BFMCS bundles entirely (independent, explore later)
- **992** [RESEARCHED] — STSA temporal shift automorphism (algebraic, independent)

### 4. Deferred

- **18** [BLOCKED] — Dense representation theorem (4 sorries, defer until base is clean)
- **20** [NOT STARTED] — Parametric canonical audit (depends on 18)
- **21** [PLANNED] — Tech debt cleanup (depends on 18)
- **19** [NOT STARTED] — Deprecate old discrete pipeline (low priority)
- **998** [NOT STARTED] — FMP redesign for strict temporal (separate concern)

### 5. Backlog

- **8** [RESEARCHED] — Genuine truth_at completeness (publication quality, 12-20h)
- **6** [RESEARCHED] — Canonical TaskFrame completeness (may be superseded by 8)
- **39** [RESEARCHED] — Preorder semantics study (theoretical)
- **953** [RESEARCHED] — Bilateral proof system (55-90h)
- **949** [RESEARCHED] — Update Demo.lean (cosmetic)
- **619** [RESEARCHED] — Agent system architecture upgrade (meta, blocked on GitHub #16803)

## Tasks

---

### 63. Prove Box backward via BFMCS modal saturation and eliminate singleton-Omega dead end
- **Effort**: 4-8 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-03-24
- **Language**: lean4
- **Dependencies**: Task 62
- **Research**:
  - [01_team-research.md](063_prove_box_backward_via_bfmcs/reports/01_team-research.md)
  - [01_teammate-a-findings.md](063_prove_box_backward_via_bfmcs/reports/01_teammate-a-findings.md)
  - [01_teammate-b-findings.md](063_prove_box_backward_via_bfmcs/reports/01_teammate-b-findings.md)
  - [02_team-research.md](063_prove_box_backward_via_bfmcs/reports/02_team-research.md) — deep modal-temporal-algebraic analysis
  - [02_teammate-a-findings.md](063_prove_box_backward_via_bfmcs/reports/02_teammate-a-findings.md)
  - [02_teammate-b-findings.md](063_prove_box_backward_via_bfmcs/reports/02_teammate-b-findings.md)
- **Plan**: [01_bfmcs-modal-completeness.md](063_prove_box_backward_via_bfmcs/plans/01_bfmcs-modal-completeness.md)
- **Summary**: [01_implementation-summary.md](063_prove_box_backward_via_bfmcs/summaries/01_implementation-summary.md)

**Completion Summary**: Modal completeness (Box forward/backward) was already fully wired. boxClassFamilies_modal_backward is used by construct_bfmcs and parametric_canonical_truth_lemma. Documentation updated to clarify the singleton-Omega dead end and BFMCS solution.

**Description**: Use the boxClassFamilies approach from UltrafilterChain.lean to establish a sorry-free Box backward direction. The singleton-Omega architecture is a mathematical dead end because it lacks witness families needed for modal saturation. This task will:

1. Implement Box backward proof using BFMCS modal saturation (boxClassFamilies_modal_backward pattern)
2. Update SuccChainTruth.lean comments to explicitly mark singleton-Omega as a dead end that should never be considered
3. Update ROADMAP.md to document that singleton-Omega is not a viable path
4. Ensure the completeness proof uses the BFMCS path exclusively for Box cases

The key insight: BFMCS bundles ALL families agreeing on box-content with M0, so when Box phi fails, Diamond(neg phi) is in M0, and box_theory_witness_exists provides a witness family W' with neg phi. This witness is IN the bundle, enabling the backward proof by contradiction.

---

### 62. Resolve backward Box sorry in succ_chain_truth_lemma and correct documentation
- **Effort**: 2-4 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-03-24
- **Language**: lean4
- **Dependencies**: Task 55
- **Research**: [01_sorry-dependency-analysis.md](062_resolve_succ_chain_truth_backward_sorry/reports/01_sorry-dependency-analysis.md)
- **Plan**: [01_box-sorry-resolution.md](062_resolve_succ_chain_truth_backward_sorry/plans/01_box-sorry-resolution.md)
- **Summary**: [01_box-sorry-summary.md](062_resolve_succ_chain_truth_backward_sorry/summaries/01_box-sorry-summary.md)

**Completion Summary**: Corrected misleading documentation about succ_chain_truth_forward being sorry-free. Added comprehensive explanation of why Box backward is mathematically unprovable in singleton-Omega architecture.

**Description**: The backward Box case in `succ_chain_truth_lemma` (SuccChainTruth.lean:254) contains a sorry with a misleading comment: "Box backward not needed for completeness." This is wrong — the backward direction is structurally entangled with the forward proof (the Imp forward case calls `(ih t).mpr` on sub-formulas). Task 55 added documentation reinforcing this incorrect claim.

**Investigation findings**:
- `succ_chain_truth_forward` extracts `.mp` from `succ_chain_truth_lemma` (line 310)
- The Imp forward case at line 240-243 uses backward IH: `(ih t).mp h_psi_mcs` — but the induction produces both directions simultaneously
- Backward G/H cases (lines 264-286) depend on `SuccChainTemporalCoherent` (deprecated as mathematically impossible)
- `lean_verify` reports BOTH `succ_chain_truth_lemma` and `succ_chain_truth_forward` as sorry-free despite the explicit sorry at line 254 — this discrepancy itself needs investigation

**Work items**:
1. Investigate `lean_verify` discrepancy: why does it report sorry-free for a theorem containing `sorry`?
2. Determine if `succ_chain_truth_lemma` (the biconditional) can be replaced by a forward-only proof that doesn't require backward cases at all — if so, remove the biconditional
3. If removal is not possible (likely, due to Imp case needing backward IH on sub-formulas), then:
   a. Correct all comments in SuccChainTruth.lean that claim backward direction is ignorable
   b. Remove/correct the task 55 documentation (lines 288-305) that reinforces the false claim
   c. Document the backward Box sorry as a genuine gap requiring resolution
   d. Document backward G/H dependency on `SuccChainTemporalCoherent` as a genuine gap
   e. Update ROAD_MAP.md to reflect that the backward direction CANNOT be ignored
   f. Update TODO.md technical debt counts if needed

---

### 61. EXPERIMENTAL: Eliminate BFMCS bundle machinery
- **Effort**: 6-10 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: None (independent exploration)

**Description**: EXPERIMENTAL: Develop an alternative completeness proof that eliminates BFMCS bundle machinery entirely. Define canonical model with box-class equivalence for modal accessibility directly on worlds (MCS, time) pairs, not families. Use box_theory_witness_exists for the Box truth lemma without bundle quantification. Develop independently until proven to work, then consider replacing existing infrastructure. "Believe it when I see it" approach.

---

### 60. Remove discrete_Icc_finite_axiom
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Task 59

**Description**: Eliminate the custom axiom discrete_Icc_finite_axiom (FrameConditions/Completeness.lean line 187). Either prove the finiteness of DiscreteTimelineQuot intervals directly, or restructure the discrete completeness proof to avoid needing it. Research-heavy task.

---

### 59. Prove frame-specific soundness axioms
- **Effort**: 3-5 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Task 58

**Description**: Fill 5 sorries in Soundness.lean for frame-specific axiom validity: density (line 572), discreteness_forward (line 576), seriality_future (line 579), seriality_past (line 582), temporal_duality (line 602). These require frame-specific proofs using DenselyOrdered, SuccOrder constraints.

---

### 58. Wire completeness to FrameConditions
- **Effort**: 3-5 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Task 55

**Description**: Connect construct_bfmcs to the top-level completeness theorems in FrameConditions/Completeness.lean. Eliminate the 3 sorries: dense_completeness_fc (line 108), discrete_completeness_fc (line 151), completeness_over_Int (line 170). This wires the sorry-free algebraic path through to the final completeness statements.

---

### 57. Clean up UltrafilterChain.lean
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: Remove ~150 lines of unused Phase 1 ultrafilter relations (R_G, R_Box, etc.) never referenced by the actual box-class construction. Remove ~280 lines of verbose exploratory comments in box_class_witness_consistent. Consider renaming file to BoxClassBFMCS.lean to match what it actually does.

---

### 39. Study preorder semantics conformance with Task Semantics specifications
- **Effort**: 3h
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Plan**: [01_conformance-validation-plan.md](039_study_preorder_semantics_conformance/plans/01_conformance-validation-plan.md)
- **Reports**:
  - [01_teammate-a-findings.md](039_study_preorder_semantics_conformance/reports/01_teammate-a-findings.md) — Primary TaskFrame axiom analysis
  - [01_teammate-b-findings.md](039_study_preorder_semantics_conformance/reports/01_teammate-b-findings.md) — G-atom analysis and alternative approaches
  - [02_team-synthesis.md](039_study_preorder_semantics_conformance/reports/02_team-synthesis.md) — Team synthesis (updated with both teammates)
  - [03_parametric-taskframe-research.md](039_study_preorder_semantics_conformance/reports/03_parametric-taskframe-research.md) — ParametricCanonicalTaskFrame and W/D separation
  - [04_unification-implementation-research.md](039_study_preorder_semantics_conformance/reports/04_unification-implementation-research.md) — Two-layer unification analysis and implementation roadmap

**Description**: Study the implications of the preorder semantics which has been accepted to avoid the fresh G-atom proofs in order to determine whether the result still conforms to the specifications required by the Task Semantics.

---

### 21. Clean up technical debt from tasks 9-20
- **Effort**: 3-5 hours
- **Status**: [PLANNED]
- **Language**: lean4
- **Dependencies**: Tasks 15, 18
- **Plan**: [01_tech-debt-cleanup-plan.md](021_technical_debt_cleanup/plans/01_tech-debt-cleanup-plan.md) — 6 phases: axiom elimination, dead-code resolution, documentation
- **Research**:
  - [01_tech-debt-audit.md](021_technical_debt_cleanup/reports/01_tech-debt-audit.md) — comprehensive 4-agent parallel audit of all code from tasks 9-20
  - [02_team-research.md](021_technical_debt_cleanup/reports/02_team-research.md) — synthesized team research: axiom classification, derivation priorities, action plan
  - [02_teammate-a-findings.md](021_technical_debt_cleanup/reports/02_teammate-a-findings.md) — axiom semantic validity analysis
  - [02_teammate-b-findings.md](021_technical_debt_cleanup/reports/02_teammate-b-findings.md) — axiom proof dependencies and derivation paths
  - [02_teammate-c-findings.md](021_technical_debt_cleanup/reports/02_teammate-c-findings.md) — frame condition theory analysis

**Description**: Pay down technical debt accumulated across the metalogic refactoring track (tasks 9-20). Systematic cleanup in 4 phases: (1) **Dead code removal** — delete redundant lemmas in CanonicalTaskRelation.lean (iter_F_succ_eq, CanonicalTask_neg_succ_nat, 3 unused accessors), unused helpers in TimelineQuotBFMCS.lean (6 items), deprecated dead-end code in AlgebraicBaseCompleteness.lean (2 items). (2) **Deprecation marking** — mark discreteTaskFrame/denseTaskFrame as deprecated in DurationTransfer.lean, evaluate CanonicalRecovery.lean compat wrappers. (3) **Bridge assessment** — evaluate ClosedFlagIntBFMCS.lean bridge for simplification, assess downstream usage of compat wrappers, document dovetailing gap resolution path. (4) **Deferred items** — re-audit after tasks 18-20 complete to capture final debt state. Note: Tasks 18 (researching), 19 (not started), and 20 (not started) may introduce or resolve additional debt.

---

### 20. Audit and update parametric canonical infrastructure
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Tasks 15, 18
- **Research (task 6)**:
  - [19_role-in-representation-theorems.md](006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md) §2.2–2.3, §7 open question 3 — current duration-coarse relation vs duration-precise alternatives, question of parametric unification
  - [18_dense-three-place-task-relation.md](006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md) §4.3 — unified TaskFrame view showing both discrete/dense cases instantiate the same structure

**Description**: Review ParametricCanonical.lean, ParametricTruthLemma.lean, and ParametricRepresentation.lean. Determine whether the parametric infrastructure can be refactored to accept a generic task_rel parameter (not hardcoded duration-coarse relation), enabling both CanonicalTask and DenseTask as instantiations. If feasible, refactor; otherwise document the relationship between parametric (base) and specialized (discrete/dense) paths.

---

### 19. Deprecate old discrete pipeline
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Task 15
- **Research (task 6)**:
  - [20_succ-based-bypass-of-covering-lemma.md](006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md) §7 — side-by-side old vs new pipeline diagrams, explicit list of what is bypassed
  - [19_role-in-representation-theorems.md](006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md) §3.3 — current discrete pipeline and the SuccOrder blocker it gets replaced by

**Description**: Once discrete completeness is proved via Succ-chains (task 15), deprecate the old quotient-based pipeline: DiscreteTimelineElem, DiscreteTimelineQuot, SuccOrder/PredOrder construction attempt, and the orderIsoIntOfLinearSuccPredArch pathway. Mark files as deprecated with doc comments pointing to the new Succ-chain approach. Tasks 989 (discrete algebraic completeness) and 974 (SuccOrder) are superseded by tasks 10-15 and can be marked [EXPANDED].

---

### 18. Complete dense representation theorem via DenseTask
- **Effort**: 6-7 hours
- **Status**: [BLOCKED]
- **Language**: lean4
- **Dependencies**: Tasks 17, 27, 30, 31
- **Research (task 6)**:
  - [18_dense-three-place-task-relation.md](006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md) §5 — replacing CanonicalR with DenseTask in the dense setting, truth condition restatement
  - [19_role-in-representation-theorems.md](006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md) §3.2, §6 dense table — full wiring of dense representation pipeline, use of timelineQuot_instantiate_dense to close the domain mismatch
- **Research**:
  - [01_dense-representation-research.md](018_dense_representation_theorem_completion/reports/01_dense-representation-research.md)
  - [02_team-research.md](018_dense_representation_theorem_completion/reports/02_team-research.md) — team research: blocker analysis, domain confusion, correct approach
  - [05_team-research.md](018_dense_representation_theorem_completion/reports/05_team-research.md) — team research run 2: 7 real sorries, revised 4-phase plan A-D, no closure operator needed
  - [13_post-task27-analysis.md](018_dense_representation_theorem_completion/reports/13_post-task27-analysis.md) — post-task27: 4 localized sorries in j>0 termination, DovetailedTimelineQuot integration
- **Plan**: [04_dense-representation-v4.md](018_dense_representation_theorem_completion/plans/04_dense-representation-v4.md) — v4: post-task27 using DovetailedTimelineQuot, 3 remaining phases
- **Summary**: [03_implementation-summary.md](018_dense_representation_theorem_completion/summaries/03_implementation-summary.md) — Phases 1-2 complete (v3), plan revised for phases 3-5

**Description**: Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ into the unconditional dense representation theorem: valid_dense φ → ⊢_dense φ. Instantiate parametric truth lemma with D=TimelineQuot (which carries DenselyOrdered). Use timelineQuot_instantiate_dense to instantiate valid_dense at D=TimelineQuot. Resolves the Task 988 blocker via the DenseTask framework.

---

### 8. Establish genuine truth_at completeness theorems for TM logic
 **Effort**: 12-20 hours
 **Status**: [RESEARCHED]
 **Language**: lean4
 **Dependencies**: Task #1007
 **Research**:
  - [01_completeness-architecture.md](008_genuine_truth_at_completeness/reports/01_completeness-architecture.md)
  - [02_completeness-blockers.md](008_genuine_truth_at_completeness/reports/02_completeness-blockers.md)
  - [03_team-research.md](008_genuine_truth_at_completeness/reports/03_team-research.md)
  - [04_team-research.md](008_genuine_truth_at_completeness/reports/04_team-research.md)
 **Plan**: [03_revised-completeness-plan.md](008_genuine_truth_at_completeness/plans/03_revised-completeness-plan.md)

**Description**: Establish genuine completeness theorems for base, dense, and discrete TM logic using the official `truth_at` semantics over `TaskFrame D` with convex `WorldHistory` structures — not the internal `satisfies_at` substitute. The existing parametric infrastructure (ParametricCanonicalTaskFrame, ParametricTruthLemma, ParametricRepresentation) is already sorry-free and correctly uses `truth_at` with `domain = True` (trivially convex). The core open problem is constructing a multi-family `BFMCS D` satisfying both modal coherence (modal_backward requires multiple families, not singleton) and temporal coherence (forward_F/backward_P — linear chain constructions via Lindenbaum extension cannot satisfy these because F-witnesses escape the chain). CanonicalFMCS over CanonicalMCS solves F/P trivially but CanonicalMCS lacks AddCommGroup/LinearOrder. The gap is bridging sorry-free CanonicalMCS results to a concrete D (Int for base/discrete, Rat for dense). Supersedes tasks 997, 988, 989 in approach (those tasks remain as they track the individual completeness legs).

---

### 6. Replace FlagBFMCS satisfies_at with canonical TaskFrame using truth_at
- **Effort**: 8-12 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task #1003
- **Research**:
  - [01_team-research.md](006_canonical_taskframe_completeness/reports/01_team-research.md)
  - [02_direct-construction.md](006_canonical_taskframe_completeness/reports/02_direct-construction.md)
  - [03_dense-discrete-compatibility.md](006_canonical_taskframe_completeness/reports/03_dense-discrete-compatibility.md)
  - [04_team-research.md](006_canonical_taskframe_completeness/reports/04_team-research.md)
  - [05_rat-discrete-compatibility.md](006_canonical_taskframe_completeness/reports/05_rat-discrete-compatibility.md)
  - [06_team-research.md](006_canonical_taskframe_completeness/reports/06_team-research.md)
  - [07_dovetailed-z-detailed.md](006_canonical_taskframe_completeness/reports/07_dovetailed-z-detailed.md)
  - [08_base-dense-discrete-strategy.md](006_canonical_taskframe_completeness/reports/08_base-dense-discrete-strategy.md)
  - [09_fp-crux-analysis.md](006_canonical_taskframe_completeness/reports/09_fp-crux-analysis.md)
  - [10_team-research.md](006_canonical_taskframe_completeness/reports/10_team-research.md)
  - [11_team-research.md](006_canonical_taskframe_completeness/reports/11_team-research.md)
  - [12_torsor-construction-full.md](006_canonical_taskframe_completeness/reports/12_torsor-construction-full.md)
  - [13_rigidity-counterexample-analysis.md](006_canonical_taskframe_completeness/reports/13_rigidity-counterexample-analysis.md)
  - [14_d-polymorphism-dense-discrete.md](006_canonical_taskframe_completeness/reports/14_d-polymorphism-dense-discrete.md)
  - [15_completeness-module-structure.md](006_canonical_taskframe_completeness/reports/15_completeness-module-structure.md)
  - [16_blocker-resolution-research.md](006_canonical_taskframe_completeness/reports/16_blocker-resolution-research.md)
- **Plan**:
  - [04_three-completeness-plan.md](006_canonical_taskframe_completeness/plans/04_three-completeness-plan.md)
  - [05_torsor-construction-plan.md](006_canonical_taskframe_completeness/plans/05_torsor-construction-plan.md)
  - [06_cantor-transfer-plan.md](006_canonical_taskframe_completeness/plans/06_cantor-transfer-plan.md)

**Description**: Replace the internal `satisfies_at` relation in FlagBFMCS completeness with the official `truth_at` from the semantic layer. Construct a canonical TaskFrame directly from FlagBFMCS data: (1) canonical world states from CanonicalMCS, (2) duration domain D parametrically from Flag chain positions, (3) task relation R from CanonicalR, (4) WorldHistory instances from Flags (each Flag maps durations to world states), (5) canonical TaskFrame and TaskModel, (6) truth lemma for truth_at directly, (7) completeness theorem using canonical `valid`. Supersedes validity bridge approach in task 997.


### 998. Redesign FMP filtration for strict temporal semantics
- **Effort**: TBD (estimated 4-8 hours)
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: Redesign the FMP (Finite Model Property) filtration for strict temporal semantics. The 2 sorry'd theorems in `Decidability/FMP/TruthPreservation.lean` — `mcs_all_future_closure` (line 263) and `mcs_all_past_closure` (line 281) — are deprecated because the temporal T-axiom (`Gφ → φ`) is NOT valid under strict semantics. `filtration_all_future_forward` and `filtration_all_past_forward` depend on them. The FMP module is separate from the main decidability pipeline (`decide` is sorry-free), but completing it formally proves the finite model property. Resolution options: (A) restrict FMP statement to serial frames where temporal seriality holds, (B) redesign filtration to avoid temporal reflexivity entirely, (C) prove the filtered model satisfies a weaker correctness property sufficient for the FMP theorem. Note: `mcs_finite_model_property` in `FMP.lean` does NOT directly use these sorry'd lemmas, so the impact is localized to `filtration_all_future_forward`/`backward`.

---


### 992. Implement Shift-Closed Tense S5 Algebra representation theorem
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [01_stsa-algebraic-analysis.md](992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md)

**Description**: Implement the Shift-Closed Tense S5 Algebra (STSA) representation theorem. Define STSA as a Lean structure extending BooleanAlgebra with box, G, H, sigma operators and interaction axioms. Lift temporal duality sigma from swap_temporal to the Lindenbaum quotient. Prove LindenbaumAlg is an STSA instance by wiring existing pieces (BooleanStructure, InteriorOperators, UltrafilterMCS). Restructure ParametricRepresentation into unified STSA representation theorem. Research report 001 provides complete algebraic analysis with ~80% of formalization already existing.

---


### 953. Refactor proof system to bilateral system
- **Effort**: 55-90 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Priority**: medium
- **Research**: [research-001.md](specs/953_refactor_proof_system_to_bilateral/reports/research-001.md), [research-002.md](specs/953_refactor_proof_system_to_bilateral/reports/research-002.md), [research-003.md](specs/953_refactor_proof_system_to_bilateral/reports/research-003.md)

**Description**: Refactor the TM proof system from a unilateral system (single judgment `Γ ⊢ φ`) to a bilateral system with dual judgments: acceptance (`Γ ⊢⁺ φ`) and rejection (`Γ ⊢⁻ φ`). The bilateral system makes the dual roles of assertion and denial explicit, with rules governing how acceptance and rejection interact across all connectives and operators. Key design: keep Formula type unchanged (Option A), add BilateralDeriv alongside existing DerivationTree with a proven equivalence bridge. Several current axioms (ex_falso, peirce, modal_t, temp_t_future, temp_t_past) become structural rules in the bilateral system. The existing signed formula infrastructure in the decidability module provides the blueprint.

**Research summary (research-003)**: Cost-benefit analysis recommends deferring bilateral refactor until higher-priority tasks (981: axiom debt, 951: completeness) progress. Benefits are primarily theoretical (assertion/denial duality, tableau alignment); existing unilateral system is adequate. Parallel-system approach (Option A) minimizes risk.

**Implementation approach**: Parallel bilateral system with equivalence bridge — not a replacement. Phase 1: bilateral infrastructure (BilateralContext, BilateralDeriv). Phase 2: prove equivalence with unilateral system. Phase 3: bilateral metalogic (MCS, FMCS, completeness). Phase 4: bilateral decidability integration.

---

### 949. Update Demo.lean for current bimodal logic state
- **Effort**: Small (~2 hours)
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [research-001.md](specs/949_update_demo_lean_bimodal_logic/reports/research-001.md)

**Description**: Update Theories/Bimodal/Examples/Demo.lean given the current state of the bimodal logic. The demo file should reflect the current API and showcase the working features of the bimodal logic implementation.

---

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


---
next_project_number: 71
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-30T18:30:00Z
task_counts:
  active: 19
  completed: 728
  in_progress: 0
  not_started: 7
  abandoned: 54
  total: 793
technical_debt:
  sorry_count: 24
  sorry_count_note: "Audited 2026-03-30: 12 examples/exercises, 5 soundness, 2 completeness wiring (bfmcs_from_mcs_temporally_coherent + dense), 2 FMP, 1 SuccChainTruth (intentional), 1 Demo, 1 misc. Task 67 deleted g_content sorry."
  publication_path_sorries: 8
  axiom_count: 1
  axiom_count_note: "discrete_Icc_finite_axiom (task 60). f_nesting_boundary/p_nesting_boundary eliminated in task 56."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-03-24. Tasks 62, 63 archived (Box backward, documentation corrections).*

**Goal**: Zero custom axioms, zero sorries on the completeness path.

### 1. Critical Path — Sorry-Free Completeness

```
67 [DONE] → 69 [RESEARCHED] → 68 → 58 → 59 → 60
```

1. **67** [COMPLETED] — Cleaned up SuccChainFMCS.lean (~340 lines deleted), simplified F_resolves
2. **69** [RESEARCHED] — Close Z_chain_forward_F' via dovetailed construction (actual gap)
   - **Blocked**: F-persistence gap — Lindenbaum can add G(neg phi) even when F(phi) present
   - **Report**: [01_z-chain-forward-research.md](069_close_z_chain_forward_f/reports/01_z-chain-forward-research.md)
   - **Plan**: [02_z-chain-forward-plan.md](069_close_z_chain_forward_f/plans/02_z-chain-forward-plan.md)
   - **Summary**: [03_z-chain-forward-summary.md](069_close_z_chain_forward_f/summaries/03_z-chain-forward-summary.md)
3. **68** [RESEARCHED] — Prove dense_completeness_fc via Rat canonical model (depends on #69)
4. **58** [BLOCKED] — Wire completeness to FrameConditions (depends on #69, #68)
4. **59** [NOT STARTED] — Prove frame-specific soundness axioms (5 sorries)
5. **60** [NOT STARTED] — Remove discrete_Icc_finite_axiom (custom axiom)

### 2. Code Cleanup (parallel to critical path)

1. **57** [RESEARCHED] — Clean up UltrafilterChain.lean, remove unused ultrafilter relations

### 3. Research

- **64** [RESEARCHED] — Critical path review: algebraic analysis of completeness obstacles

### 4. Experimental

- **61** [NOT STARTED] — Eliminate BFMCS bundles entirely (independent, explore later)
- **992** [RESEARCHED] — STSA temporal shift automorphism (algebraic, independent)

### 5. Deferred

- **18** [BLOCKED] — Dense representation theorem (4 sorries, defer until base is clean)
- **20** [NOT STARTED] — Parametric canonical audit (depends on 18)
- **21** [PLANNED] — Tech debt cleanup (depends on 18)
- **19** [NOT STARTED] — Deprecate old discrete pipeline (low priority)
- **998** [NOT STARTED] — FMP redesign for strict temporal (separate concern)

### 6. Backlog

- **8** [RESEARCHED] — Genuine truth_at completeness (publication quality, 12-20h)
- **6** [RESEARCHED] — Canonical TaskFrame completeness (may be superseded by 8)
- **39** [RESEARCHED] — Preorder semantics study (theoretical)
- **953** [RESEARCHED] — Bilateral proof system (55-90h)
- **949** [RESEARCHED] — Update Demo.lean (cosmetic)
- **619** [RESEARCHED] — Agent system architecture upgrade (meta, blocked on GitHub #16803)

## Tasks

---

### 70. Explore ultrafilter-based construction for temporal coherence
- **Effort**: 12-20 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Parent Task**: #69

**Description**: Explore ultrafilter-based construction for temporal coherence as alternative to MCS-based Lindenbaum extension. Ultrafilters of the Lindenbaum algebra have automatic negation completeness, eliminating the F-persistence gap where Lindenbaum can add G(neg phi). The R_G and R_Box relations on ultrafilters already exist (UltrafilterChain.lean lines 59-68). This task requires: (1) defining FMCS structure from ultrafilter chains, (2) proving ultrafilter chains satisfy temporal coherence by construction, (3) connecting ultrafilter-based completeness to existing MCS-based infrastructure. Reference: Strategy 4 in task 69 team research report.

---

### 67. Prove bundle_validity_implies_provability via direct model construction
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-03-30
- **Summary**: Deleted flawed boundary analysis theorems (~340 lines). Simplified restricted_forward_chain_forward_F to 1-line proof using existing F_resolves.
- **Blocker**: None (Plan 15 deletes flawed theorems, uses F_resolves shortcut)
- **Language**: lean4
- **Dependencies**: None
- **Parent Task**: #58
- **Research**:
  - [83_spawn-analysis.md](058_wire_completeness_to_frame_conditions/reports/83_spawn-analysis.md)
  - [01_bundle-provability-research.md](067_prove_bundle_validity_implies_provability/reports/01_bundle-provability-research.md)
  - [38_fuel-cleanup-research.md](067_prove_bundle_validity_implies_provability/reports/38_fuel-cleanup-research.md)
  - [39_provenance-proof-research.md](067_prove_bundle_validity_implies_provability/reports/39_provenance-proof-research.md)
- **Plan**:
  - [01_bundle-provability-plan.md](067_prove_bundle_validity_implies_provability/plans/01_bundle-provability-plan.md)
  - [02_restricted-coherence-plan.md](067_prove_bundle_validity_implies_provability/plans/02_restricted-coherence-plan.md)
  - [03_termination-first-plan.md](067_prove_bundle_validity_implies_provability/plans/03_termination-first-plan.md)
  - [04_bypass-z-chain-plan.md](067_prove_bundle_validity_implies_provability/plans/04_bypass-z-chain-plan.md)
  - [05_extend-deferral-closure.md](067_prove_bundle_validity_implies_provability/plans/05_extend-deferral-closure.md)
  - [06_well-founded-recursion.md](067_prove_bundle_validity_implies_provability/plans/06_well-founded-recursion.md)
  - [07_wire-restricted-chain.md](067_prove_bundle_validity_implies_provability/plans/07_wire-restricted-chain.md)
  - [08_dovetailed-omega-fmcs.md](067_prove_bundle_validity_implies_provability/plans/08_dovetailed-omega-fmcs.md)
  - [09_fix-backward-chain.md](067_prove_bundle_validity_implies_provability/plans/09_fix-backward-chain.md)
  - [10_well-founded-restructure.md](067_prove_bundle_validity_implies_provability/plans/10_well-founded-restructure.md)
  - [13_bulldozing-f-persistence.md](067_prove_bundle_validity_implies_provability/plans/13_bulldozing-f-persistence.md)
  - [14_backward-tracing-completion.md](067_prove_bundle_validity_implies_provability/plans/14_backward-tracing-completion.md)
  - [15_f-resolves-shortcut.md](067_prove_bundle_validity_implies_provability/plans/15_f-resolves-shortcut.md)
- **Summary**: [01_implementation-summary.md](067_prove_bundle_validity_implies_provability/summaries/01_implementation-summary.md)

**Description**: Clean up flawed boundary analysis theorems in SuccChainFMCS.lean. Deleted ~340 lines of dead-end code (boundary_implies_k_plus_d_bounded and dependencies). Simplified restricted_forward_chain_forward_F to 1-line proof. NOTE: The sorry in bfmcs_from_mcs_temporally_coherent remains; it depends on Z_chain_forward_F' which requires the dovetailed omega construction (see task 69).

---

### 69. Close Z_chain_forward_F' via dovetailed omega construction
- **Effort**: 6-8 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: None
- **Parent Task**: #58
- **Reports**:
  - [01_z-chain-forward-research.md](069_close_z_chain_forward_f/reports/01_z-chain-forward-research.md)
  - [02_team-research.md](069_close_z_chain_forward_f/reports/02_team-research.md)
  - [03_sorry-closure-research.md](069_close_z_chain_forward_f/reports/03_sorry-closure-research.md)
- **Plan**: [05_sorry-closure-plan.md](069_close_z_chain_forward_f/plans/05_sorry-closure-plan.md)

**Description**: Close the Z_chain_forward_F' theorem in UltrafilterChain.lean via the true dovetailed omega construction. This is the actual remaining gap blocking bfmcs_from_mcs_temporally_coherent and thus bundle_validity_implies_provability. The dovetailed construction (lines 3668+) uses Nat.unpair to fairly schedule F-obligation resolution across all time points. Also closes omega_forward_F_bounded_persistence and one_step_f_resolution.

---

### 68. Prove dense_completeness_fc via Rat canonical model
- **Effort**: 6-10 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task #69
- **Parent Task**: #58
- **Research**: [83_spawn-analysis.md](058_wire_completeness_to_frame_conditions/reports/83_spawn-analysis.md)

**Description**: Eliminate the sorry in dense_completeness_fc (FrameConditions/Completeness.lean line 121) by constructing a canonical model over Rat. Int cannot be used because Int is not densely ordered. Rat is countable, aligning with existing Lindenbaum/countable MCS machinery.

---

### 65. Build TaskModel from Restricted Construction
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: None
- **Parent Task**: #58
- **Research**:
  - [01_spawn-analysis.md](065_build_taskmodel_from_restricted_construction/reports/01_spawn-analysis.md)
  - [02_team-research.md](065_build_taskmodel_from_restricted_construction/reports/02_team-research.md)
  - [03_team-research.md](065_build_taskmodel_from_restricted_construction/reports/03_team-research.md)
  - [08_teammate-a-findings.md](065_build_taskmodel_from_restricted_construction/reports/08_teammate-a-findings.md)
  - [09_team-research-wave3.md](065_build_taskmodel_from_restricted_construction/reports/09_team-research-wave3.md)
- **Plan**: [02_revised-plan.md](065_build_taskmodel_from_restricted_construction/plans/02_revised-plan.md)
- **Summary**: [01_implementation-summary.md](065_build_taskmodel_from_restricted_construction/summaries/01_implementation-summary.md)
- **Blocked Reason**: `shifted_truth_lemma` requires family-level coherence (SAME family witnesses), but `construct_bfmcs_bundle` provides only bundle-level coherence. Wave 3: forward-only truth lemma also blocked — `imp` forward case requires backward IH for antecedent. Omega-enumeration construction is the only viable path.

**Description**: Create TaskModel/TaskFrame infrastructure from RestrictedTemporallyCoherentFamily to enable semantic completeness proofs. Define RestrictedTaskFrame, RestrictedTaskModel, RestrictedOmega, prove shift-closure, and restricted_truth_lemma_semantic.

---

### 66. Wire Restricted Completeness to Target Sorries
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task 65
- **Parent Task**: #58
- **Research**: [01_spawn-analysis.md](066_wire_restricted_completeness_to_target_sorries/reports/01_spawn-analysis.md)

**Description**: Connect restricted completeness path to the 3 target sorries in FrameConditions/Completeness.lean: bundle_validity_implies_provability, dense_completeness_fc, discrete_completeness_fc. Use contrapositive argument via RestrictedTaskModel.

---

### 64. Critical path review: algebraic analysis of completeness obstacles
- **Effort**: Research task
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Research**:
  - [01_critical-path-analysis.md](064_critical_path_review/reports/01_critical-path-analysis.md)
  - [02_team-research.md](064_critical_path_review/reports/02_team-research.md)

**Description**: Multi-agent review of the critical path tasks (58-60) for accuracy, identification of gaps, and algebraic strategy analysis. Key findings:

**Sorry inventory correction**: Actual sorry count is 25 (not 98 per ROADMAP). SuccChain sorries (24) removed in task 56. Perpetuity bridge (16) all proven. Publication-path sorries: 9 (tasks 58+59 only). The ROADMAP Class A/B distinction is moot — the SuccChain approach was abandoned.

**TODO.md accuracy**: Task descriptions are accurate on locations and content. Task 59 is incorrectly marked as dependent on 58 — it's parallelizable. Task 58's description understates the obstacle: the real blocker is temporal coherence construction, not wiring.

**Central obstacle**: `construct_bfmcs` requires `B.temporally_coherent` proof. The deprecated implementation depends on the false `f_nesting_is_bounded`. The entire 5,300-line sorry-free algebraic path reduces to this single callback.

**Algebraic resolution strategies identified**:
- **(A) Zorn on R_G-chains**: Maximal chains through R_□-class exist; challenge is matching order type of D.
- **(B) Temporal shift automorphism**: Define τ on Lindenbaum algebra; FMCS = {τᵗ(U)}. Challenge: G is not invertible.
- **(C) Restricted chain + σ-duality** (recommended): Forward chain is sorry-free; use σ-duality for backward chain; dovetail into FMCS over ℤ. Shortest path leveraging existing infrastructure.

**STSA status**: Typeclass and LindenbaumAlg instance are fully sorry-free (TenseS5Algebra.lean, 350 lines). The STSA representation theorem (task 992) is a reorganization of existing code, not on critical path but provides the elegant algebraic framing.

**Custom axiom inventory**: Only `discrete_Icc_finite_axiom` remains (task 60). The `f_nesting_boundary` and `p_nesting_boundary` axioms were eliminated in task 56.

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
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task 55
- **Research**:
  - [63_team-research.md](058_wire_completeness_to_frame_conditions/reports/63_team-research.md) — Team research: seed consistency proof techniques (4 teammates)
  - [65_team-research.md](058_wire_completeness_to_frame_conditions/reports/65_team-research.md) — Team research: BRS blocker analysis - theorem is FALSE, bypass recommended
- **Plan**: [17_greedy-extension.md](058_wire_completeness_to_frame_conditions/plans/17_greedy-extension.md) — 4-phase greedy extension approach

**Description**: Connect construct_bfmcs to the top-level completeness theorems in FrameConditions/Completeness.lean. Eliminate the 3 sorries: dense_completeness_fc (line 108), discrete_completeness_fc (line 151), completeness_over_Int (line 170). This wires the sorry-free algebraic path through to the final completeness statements.

---

### 57. Clean up UltrafilterChain.lean
- **Effort**: 1-2 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Research**: [01_cleanup-analysis.md](057_clean_up_ultrafilter_chain_lean/reports/01_cleanup-analysis.md)

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


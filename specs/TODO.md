---
next_project_number: 125
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-05-10T23:59:00Z
task_counts:
  active: 20
  completed: 772
  in_progress: 0
  not_started: 7
  abandoned: 80
  total: 862
technical_debt:
  sorry_count: 1
  sorry_count_note: "Audited 2026-05-11: 1 critical-path sorry in ChronicleToCountermodel.lean (dd_countermodel_chronicle_nondense_sorry). limitDomSubtype_Icc_finite removed by task 123 collapse approach. ~17 dead-code sorries in BXCanonical pipeline (mathematically false under irreflexive semantics, bypassed by Chronicle). ~19 TemporalDerived re-derivations (low priority). Soundness, SoundnessLemmas, and Decidability are sorry-free."
  publication_path_sorries: 1
  axiom_count: 0
  axiom_count_note: "Zero custom axioms. Prior-UZ/SZ are standard axiom constructors with sorry-free soundness proofs."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-05-10. Archived 8 tasks (5 completed, 3 abandoned). Prior-UZ axioms added, soundness sorry-free.*

**Goal**: Close 1 remaining sorry for sorry-free `bx_completeness`.

**Status**: Soundness (all 3 variants) and FMP completeness are sorry-free. Dense completeness is internally sorry-free. Discrete `discrete_fmcs` sorry-free (task 123). One sorry remains: `dd_countermodel_chronicle_nondense_sorry` (task 122).

### 1. Critical Path — Discrete Completeness (1 sorry)

1. **122** [NOT STARTED] — Build discrete BFMCS on ℤ, complete `dd_countermodel_chronicle_nondense_sorry`

### 2. Active Research

- **120** [RESEARCHED] — Semantic foundation redesign for natural group structure (independent)
- **998** [RESEARCHING] — FMP redesign for irreflexive temporal semantics

### 3. Cleanup / Deferred

- **124** [PLANNING] — Remove TF axiom, derive from MF (cleanup)
- **116** [PLANNING] — Redefine G/H/F/P in terms of U/S (nice-to-have)
- **115** [RESEARCHED] — Remove A4a, simplify BX2 (cleanup)
- **112** [RESEARCHED] — Literature study (reference)
- **95** [NOT STARTED] — Verification audit
- **68** [RESEARCHED] — Dense completeness via ℚ (dense case already works)
- **18** [BLOCKED] — Dense representation theorem (deferred)
- **20** [NOT STARTED] — Parametric canonical audit
- **21** [PLANNED] — Tech debt cleanup

### 4. Backlog

- **8** [RESEARCHED] — Genuine truth_at completeness (publication quality)
- **953** [RESEARCHED] — Bilateral proof system (55-90h)
- **992** [RESEARCHED] — STSA temporal shift automorphism
- **949** [RESEARCHED] — Update Demo.lean (cosmetic)
- **64** [RESEARCHED] — Critical path review (reference)
- **619** [RESEARCHED] — Agent system architecture upgrade (meta)
- **114** [NOT STARTED] — Plan-compliance rule (meta)

## Tasks

### 123. Fix C5 witness placement for ξ=⊥ and prove Icc_finite
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: critical
- **Plan**: [123_fix_c5_witness_bot_and_prove_icc_finite/plans/01_fix-c5-bot-witness.md]
- **Summary**: [123_fix_c5_witness_bot_and_prove_icc_finite/summaries/01_fix-c5-bot-summary.md]

**Description**: Fix C5 witness placement for ξ=⊥ and prove Icc_finite. Phases 1, 2, and 5 completed (collapse equivalence, FMCS on Z, cleanup). Phases 3 and 4 (Until/Since coherence on Z, BFMCS construction) were never completed and need to be evaluated and revised to accurately represent remaining work.

---

### 124. Remove TF axiom and derive from MF
- **Effort**: 5-10 hours
- **Status**: [PLANNING]
- **Task Type**: lean4
- **Research**: [specs/124_remove_tf_axiom_derive_from_mf/reports/01_tf-derivation-research.md]

**Description**: Remove TF axiom (□φ→G□φ) and replace with derivation from MF (□φ→□Gφ). TF is derivable from MF using the T axiom (□φ→φ) applied under G: from □φ→□Gφ (MF) and □Gφ→Gφ (T applied to Gφ), chain to get □φ→Gφ; then generalize to □φ→G□φ by substituting □φ for φ in MF and composing. Remove TF from the Axiom inductive type, add a DerivationTree proof deriving TF from MF+T, update Soundness.lean to remove the TF match arm, and fix any downstream references.

---

### 122. Build discrete BFMCS on ℤ and complete discrete countermodel
- **Effort**: 8-15 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 123
- **Research**: [specs/122_build_discrete_bfmcs_and_complete_countermodel/reports/01_discrete-bfmcs-research.md]

**Description**: Build discrete BFMCS on ℤ and complete `dd_countermodel_chronicle_nondense_sorry`. Mirror the dense case pattern: use `discrete_fmcs` (already exists) to build a `BFMCS Int` with restricted coherence properties, then wire into parametric representation for the countermodel. Located at ChronicleToCountermodel.lean:836.

---

### 120. Research semantic foundation for natural group structure
- **Effort**: 8-15 hours
- **Status**: [RESEARCHED]
- **Research**: [specs/120_semantic_foundation_group_structure/reports/01_semantic-foundation-research.md]
- **Task Type**: lean4

**Description**: Research and design a cleaner semantic foundation where `AddCommGroup` structure emerges naturally from the canonical model construction, eliminating the need for `IsSuccArchimedean` and the ℤ-isomorphism. Currently `valid` requires `AddCommGroup D` (used by MF, TF, and 4 uniformity axioms for time-shift invariance), but the chronicle construction produces `limit_dom ⊂ ℚ` which is not closed under addition. Explore: (1) Whether adding operators or axioms to the logic can force the canonical model domain to carry group structure; (2) Whether `ShiftClosed` can be reformulated without requiring D to be a group; (3) Whether a different semantic framework (e.g., relational rather than algebraic) can validate MF/TF while remaining neutral on density/discreteness; (4) Whether the completeness theorem can be factored so `AddCommGroup` is only needed at the final step. Must maintain validity of MF (`Box(φ) → Box(G(φ))`) and remain neutral on density and discreteness axioms.

---

### 116. Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Effort**: 15-25 hours
- **Status**: [PLANNING]
- **Task Type**: lean4
- **Dependencies**: 107
- **Research**: [specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md]

**Description**: Remove `all_future` (G) and `all_past` (H) as primitive constructors from the `Formula` inductive type. Define F and P as abbreviations using `untl`/`snce` with ⊤, then G and H as ¬F¬ and ¬P¬, matching Burgess 1982 §1.1. `box` (□) remains primitive (S5 modal operator). ~3200 references across codebase. Should be done AFTER task 107 Phase 9 (convention migration) to avoid double-refactoring.

---

### 115. Remove A4a and simplify BX2 after task 107 adds left_mono_until_G
- **Effort**: 1-2 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: 107
- **Related**: 107
- **Research**: [specs/115_replace_a4a_with_left_mono_until_g/reports/01_a4a-vs-left-mono.md]

**Description**: Post-task-107 cleanup: remove A4a (separation_until/separation_since) axioms now that left_mono_until_G is in the system (added by task 107 Phase 5b). Optionally simplify BX2 by removing the redundant pointwise conjunct (left_mono_until_G subsumes it under open-guard semantics). Update SoundnessLemmas.lean match arms, remove A4a references from documentation.

---

### 114. Add plan-compliance rule for implementation agents
- **Effort**: small
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Priority**: high

**Description**: Add a `.claude/rules/` rule enforcing plan compliance for implementation agents. Root cause: lean-implementation-agent invented a "theorems-as-interval" shortcut for task 107 Phase 1 instead of following the planned Burgess D₀ seed construction. The agent definition, skill, and workflow docs tell agents HOW to execute (lean_goal, phase markers, builds) but never say they MUST follow the plan's specified approach. The rule must state: (1) agents MUST implement the plan's specified approach, not invent alternatives; (2) if agent believes a simpler approach exists, MUST write a handoff recommending `/revise` and return partial — never implement the alternative silently; (3) plan task items are binding specifications, not suggestions.

---

### 112. Systematic literature study for task 107 representation theorem
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: formal
- **Research**: [specs/112_literature_study_representation_theorem/reports/01_team-research.md]

**Description**: Review 5 non-original literature sources (Burgess 1982b, Venema 1993, Obendrauf 2024, Burgess 1984, Thomason 1984) for relevance to the task 107 representation theorem. Assess how each source's techniques relate to the three-layer infrastructure problem (g-function, guard conventions, domain extension) and the hybrid approach identified in task 107 research round 15.

---

### 95. Verification audit: #print axioms + sorry classification pass
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: Tasks 93, 109
- **Created**: 2026-04-10
- **Related**: Tasks 60, 93, 109

**Description**: Verification pass to confirm sorry-free completeness after task 109 closes the chain construction sorries. (1) Run `#print axioms` on `bx_completeness`; confirm output is exactly `{propext, Classical.choice, Quot.sound}` with no `sorry` dependency. (2) Classify all `sorry` occurrences in `Soundness.lean` and `SoundnessLemmas.lean` (real sorry vs docstring/comment). (3) Confirm `soundness`, `soundness_dense`, `soundness_discrete` build with only standard axioms. (4) Audit for any custom Lean `axiom` declarations (expected: possibly `discrete_Icc_finite_axiom` per task 60). (5) Produce audit report at `specs/reviews/completeness-audit-{DATE}.md`. Depends on task 109 for full completeness verification.

---

### 68. Prove dense_completeness_fc via Rat canonical model
- **Effort**: 6-10 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task #72
- **Parent Task**: #58
- **Research**: [83_spawn-analysis.md](058_wire_completeness_to_frame_conditions/reports/83_spawn-analysis.md)

**Description**: Eliminate the sorry in dense_completeness_fc (FrameConditions/Completeness.lean line 121) by constructing a canonical model over Rat. Int cannot be used because Int is not densely ordered. Rat is countable, aligning with existing Lindenbaum/countable MCS machinery.

**Hint**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

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

### 60. Clean up stale discrete_Icc_finite_axiom references
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: discrete_Icc_finite_axiom was already eliminated (zero custom axioms confirmed). Remaining scope: clean up stale docstrings in FrameClass.lean and SuccExistence.lean that still reference the removed axiom.

### 21. Clean up technical debt from tasks 9-20
- **Effort**: 3-5 hours
- **Status**: [IMPLEMENTING]
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

**Hint**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

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

**Hint (dense leg)**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

---

### 998. Redesign FMP filtration for strict temporal semantics
- **Effort**: TBD (estimated 4-8 hours)
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Priority**: high
- **Related**: Tasks 74-77 (strict temporal extensions research track)

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


## Recommended Order


## Recommended Order


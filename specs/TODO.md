---
next_project_number: 42
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-19T23:50:22Z
task_counts:
  active: 18
  completed: 713
  in_progress: 1
  not_started: 7
  abandoned: 47
  total: 778
technical_debt:
  sorry_count: 16
  sorry_count_note: "Excluding Boneyard: 3 wiring (FrameConditions/Completeness), 13 examples"
  publication_path_sorries: 0
  axiom_count: 9
  axiom_count_note: "CORRECTED: 7 production (successor/predecessor_deferral_seed_consistent, predecessor_f_step, f/p_nesting_boundary, existsTask_irreflexive, discrete_Icc_finite) + 2 StagedConstruction (discreteImmediateSuccSeed_consistent, discreteImmediateSucc_covers). Task 42 tracks elimination."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Recommended Order

*Updated 2026-03-22 after task 997 (base completeness) completed*

### 1. Succ-chain Pipeline (base completeness — active)

**Base completeness is done** (task 997). The remaining work is eliminating axioms/sorries:

1. **40** → research (NEW: prove successor_satisfies_p_step — unblocks forward chain p_step)
2. **35** → resume after 40 (partial: 3/4 phases done, Phase 4 blocked on 40)
3. **36** → research (prove f_nesting_boundary axiom via Fischer-Ladner closure)
4. **37** → implement after 36 (prove p_nesting_boundary — mirrors 36)
5. **38** → implement (prove Box backward truth lemma — not used in completeness, lower priority)

**Axioms remaining** (6 in Bundle/): 3 seed consistency (task 34), f_nesting_boundary (task 36), p_nesting_boundary (task 37), predecessor_f_step_axiom (may be superseded by 40 approach).

### 2. Axiom Elimination (high priority)

1. **34** → research (3 SuccExistence seed axioms — independent, high value)
2. **26** → revise plan (remove canonicalR_irreflexive_axiom — now contradicts canonicalR_reflexive)

### 3. Dense Pipeline (blocked)

1. **18** → blocked on Phase 5 (DenseTimeline/DovetailedTimeline bridge gap)
2. **20** → depends on 18 (parametric canonical audit)

**Note**: Task 18 has been stuck for days. Consider: (a) deeper research on the specific blocker, or (b) deferring until base pipeline is cleaner.

### 4. Discrete Pipeline (low priority now)

1. **22** → status unclear (researched, had partial implementation)
2. **24** → depends on 22 (cleanup)

**Note**: Discrete pipeline was superseded by Succ-chain approach (task 997). Tasks 22, 24 may be **obsolete** if base completeness via Succ-chain is sufficient.

### 5. Refactoring

1. **25** → COMPLETED (archive next /todo run)
2. **19** → implement (deprecate old discrete pipeline — depends on 22/24 status)
3. **21** → plan (tech debt cleanup, depends on 18)

### 6. Consider Abandoning

These tasks may be **superseded** or **low value**:

1. **988** → ABANDON? (dense algebraic completeness — superseded by task 18 approach)
2. **989** → ABANDON? (discrete algebraic completeness — superseded by task 997/Succ-chain)
3. **22** → ABANDON? (direct multi-family bundle — may be obsolete after task 997)
4. **24** → ABANDON? (discrete axiom removal — depends on 22)
5. **993** → DEFER (stability operator — nice-to-have, not critical path)
6. **998** → DEFER (FMP redesign — separate concern from completeness)
7. **999** → DEFER (derive F→FF — theoretical interest, not blocking)

### 7. Independent Tasks (backlog)

These are researched and ready but not critical path:

1. **8** → plan (genuine truth_at completeness)
2. **6** → plan (canonical TaskFrame completeness)
3. **992** → plan (STSA representation)
4. **953** → plan (bilateral proof system)
5. **949** → plan (update Demo.lean — cosmetic)
6. **619** → plan (skill migration — meta, low priority)
7. **39** → planning (preorder semantics study — recently researched)

## Tasks

---

### 42. Eliminate ALL custom axioms from the codebase
- **Effort**: 20-40 hours
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: Eliminate ALL 9 custom Lean `axiom` declarations. TODO.md axiom_count claimed 3 — actual count is 9 (7 production path, 2 StagedConstruction). No axioms should ever be accepted as shortcuts.

**Production path axioms (in succ_chain_truth_lemma)**:
1. `successor_deferral_seed_consistent_axiom` (SuccExistence.lean:266)
2. `predecessor_deferral_seed_consistent_axiom` (SuccExistence.lean:311)
3. `predecessor_f_step_axiom` (SuccExistence.lean:516)
4. `f_nesting_boundary` (SuccChainFMCS.lean:615)
5. `p_nesting_boundary` (SuccChainFMCS.lean:727)

**Additional production axioms**:
6. `existsTask_irreflexive_axiom` (CanonicalIrreflexivity.lean:279)
7. `discrete_Icc_finite_axiom` (DiscreteTimeline.lean:319)

**StagedConstruction axioms**:
8. `discreteImmediateSuccSeed_consistent_axiom` (DiscreteSuccSeed.lean:300)
9. `discreteImmediateSucc_covers_axiom` (DiscreteSuccSeed.lean:430)

**Impact**: Task 40 plan must be revised — it recommends adding a 10th axiom (`successor_p_step_axiom`), which contradicts the no-axiom policy. Existing tasks 34, 36, 37 also involve axiom-adjacent work and should be coordinated.

---

### 41. Eliminate D=CanonicalMCS pattern systematically
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Research**: [01_team-research.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/01_team-research.md)

**Description**: Remove the architectural error where the FMCS type parameter D (timeline/duration type) is instantiated with CanonicalMCS (the type of all maximal consistent sets). FMCS model world histories as functions D → W obeying temporal coherence constraints; D should be a timeline type (Int, Rat, TimelineQuot) and W should be world states (MCS). The D=CanonicalMCS pattern conflates these, creating an identity mapping `mcs(w) = w.world` that trivializes F/P witness obligations rather than proving them properly. This pattern is load-bearing across 13+ files: CanonicalFMCS.lean, FMCSDef.lean, ModallyCoherentBFMCS.lean, AlgebraicBaseCompleteness.lean, BaseCompleteness.lean, StagedConstruction/Completeness.lean, TimelineQuotBFMCS.lean, DovetailedTimelineQuotBFMCS.lean, ClosureSaturation.lean, CanonicalConstruction.lean, TemporalCoherence.lean, ChainFMCS.lean, ModalSaturation.lean. The critical sorry-free theorem `temporal_coherent_family_exists_CanonicalMCS` depends entirely on this conflation. Requires constructing proper FMCS with D=Int (or similar timeline type) where F/P witnesses are genuinely proven within the chain construction.

---

### 40. Add p-step condition to Succ relation or prove successor_satisfies_p_step
- **Effort**: 4-8 hours
- **Status**: [PLANNED]
- **Language**: lean4
- **Depends On**: Task 35 (partial)
- **Research**: [01_team-research.md](specs/040_succ_p_step_forward_chain/reports/01_team-research.md)
- **Plan**: [01_successor-p-step-axiom.md](specs/040_succ_p_step_forward_chain/plans/01_successor-p-step-axiom.md)

**Description**: Add h-persistence and p-step conditions to the Succ definition, or prove successor_satisfies_p_step from the deferral seed structure. Currently Succ is defined with only 2 conditions: (1) g_content u ⊆ v (g-persistence) and (2) f_content u ⊆ v ∪ f_content v (f-step). The missing conditions are: (3) h_content v ⊆ u (h-persistence backward) and (4) p_content v ⊆ u ∪ p_content u (p-step). The predecessor construction already satisfies p-step via predecessor_satisfies_p_step (SuccExistence.lean:573), but the successor construction does not explicitly guarantee it. This blocks the forward chain case in succ_chain_fam_p_step (SuccChainFMCS.lean:350). Two approaches: (A) Extend Succ to a 4-condition relation and thread the new conditions through all existing Succ proofs, or (B) prove successor_satisfies_p_step directly from the successor_deferral_seed structure in SuccExistence.lean. Approach B is preferred if possible since it is less invasive. Key files: SuccRelation.lean (Succ definition at line 60), SuccExistence.lean (successor/predecessor constructions), SuccChainFMCS.lean (the blocked sorry at line 350), CanonicalTaskRelation.lean (Succ usage).

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

### 38. Prove Box backward direction in succ_chain_truth_lemma
- **Effort**: 8 hours
- **Status**: [IMPLEMENTING]
- **Language**: lean4
- **Research**: [01_team-research.md](specs/038_prove_box_backward_truth_lemma/reports/01_team-research.md)
- **Plan**: [01_multi-family-bfmcs-migration.md](specs/038_prove_box_backward_truth_lemma/plans/01_multi-family-bfmcs-migration.md)

**Description**: Prove Box backward direction in succ_chain_truth_lemma (SuccChainTruth.lean:254). The sorry states: given psi true at all histories in singleton Omega, derive Box(psi) in MCS. Since psi in MCS does NOT imply Box(psi) in MCS for arbitrary MCS, this cannot be proven with the current singleton-Omega model. Requires either: (1) extending to a multi-history BFMCS model where Box is semantically grounded, (2) refactoring the truth lemma to break the forward/backward mutual dependence in the imp case (line 210 uses backward IH via .mpr), or (3) proving a restricted version sufficient for completeness. This sorry is structurally load-bearing — it contaminates succ_chain_truth_forward and the completeness theorem via sorry propagation through the biconditional induction.

---

### 37. Prove p_nesting_boundary axiom via temporal filtration or Fischer-Ladner closure
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Depends On**: Task 36

**Description**: Prove p_nesting_boundary axiom (SuccChainFMCS.lean:695) via temporal filtration or Fischer-Ladner closure. Symmetric to f_nesting_boundary: given P(phi) in MCS M, there exists d >= 1 such that iter_P d phi in M but iter_P (d+1) phi not in M. Once f_nesting_boundary (task 36) is proven, this follows by F/P duality with minimal additional work. Depends on task 36 infrastructure.

---

### 36. Prove f_nesting_boundary axiom via temporal filtration or Fischer-Ladner closure
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: Prove f_nesting_boundary axiom (SuccChainFMCS.lean:583) via temporal filtration or Fischer-Ladner closure. The axiom states: given F(phi) in MCS M, there exists d >= 1 such that iter_F d phi in M but iter_F (d+1) phi not in M. Requires showing F-chains in consistent MCS must terminate. Standard proof uses Fischer-Ladner closure finiteness — the closure of any formula is finite, so the F-iteration sequence must eventually leave M. This eliminates the axiom entirely.

---

### 35. Prove remaining sorries and axioms in Succ-chain completeness pipeline
- **Effort**: 4 hours
- **Status**: [IMPLEMENTING]
- **Language**: lean4
- **Depends On**: Task 34 (non-blocking), Task 40 (blocks Phase 4)
- **Research**:
  - [01_team-research.md](035_prove_succ_chain_remaining_sorries/reports/01_team-research.md) — Team synthesis (2 teammates)
  - [01_teammate-a-findings.md](035_prove_succ_chain_remaining_sorries/reports/01_teammate-a-findings.md) — Item-by-item analysis
  - [01_teammate-b-findings.md](035_prove_succ_chain_remaining_sorries/reports/01_teammate-b-findings.md) — Patterns and prior art
- **Plan**: [01_prove-sorries-plan.md](035_prove_succ_chain_remaining_sorries/plans/01_prove-sorries-plan.md)
- **Summary**: [01_implementation-summary.md](035_prove_succ_chain_remaining_sorries/summaries/01_implementation-summary.md) — Partial (3/4 phases)

**Description**: Prove remaining sorries and axioms in Succ-chain completeness pipeline. After task 997 (Succ-chain base completeness) and excluding task 34 (SuccExistence axioms), 7 items remain: (1) SuccChainFMCS axioms: f_nesting_boundary, p_nesting_boundary (provable via well-founded induction on formula depth), succ_chain_fam_p_step (provable via induction on chain structure). (2) New sorries from task 997: Box backward direction in SuccChainTruth.lean:254 (not used in completeness but needed for full bidirectional truth lemma), structural contraction in SuccChainCompleteness.lean:109 (provable by induction). (3) P-direction inherited sorries: backward_witness in CanonicalTaskRelation.lean:785, succ_propagates_P_not in SuccRelation.lean:497. All items are provable — no architectural blockers. Depends on task 34 (non-blocking: task 34 reduces axiom count but these items are independent).

---

### 34. Prove SuccExistence seed consistency axioms
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: none
- **Follow-up from**: Task 29 Phase 7 (deferred)

**Description**: Prove or remove the 3 axioms in `Bundle/SuccExistence.lean` that were deferred from task 29 Phase 7: (1) `successor_deferral_seed_consistent_axiom` (line 266) — asserts successor deferral seed is consistent, (2) `predecessor_deferral_seed_consistent_axiom` (line 311) — symmetric predecessor version, (3) `predecessor_f_step_axiom` (line 516) — F-step condition for predecessor construction. Under reflexive semantics with T-axiom available, these seed consistency claims may be provable syntactically. The seeds contain `g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}` (successor) or `h_content(u) ∪ {φ ∨ P(φ) | P(φ) ∈ u}` (predecessor). The deferral disjunctions `φ ∨ F(φ)` are tautological consequences of `F(φ)`, and the g_content formulas are jointly consistent by MCS properties. Research whether T-axiom (`G(φ) → φ`) provides enough to close these proofs. Note: discrete seed axioms (`discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom`) are covered by task 24.

---

### 26. Remove or justify canonicalR_irreflexive_axiom
- **Effort**: 2-8 hours (depends on path chosen)
- **Status**: [PLANNED]
- **Language**: lean4
- **Dependencies**: none
- **Research**:
  - [01_teammate-a-findings.md](026_remove_canonicalr_irreflexive_axiom/reports/01_teammate-a-findings.md) — CanonicalTask vs CanonicalR irreflexivity analysis
  - [01_teammate-b-findings.md](026_remove_canonicalr_irreflexive_axiom/reports/01_teammate-b-findings.md) — complete usage map (16 sites, 6 files)
  - [01_teammate-c-findings.md](026_remove_canonicalr_irreflexive_axiom/reports/01_teammate-c-findings.md) — modal logic theoretical analysis
  - [02_synthesis.md](026_remove_canonicalr_irreflexive_axiom/reports/02_synthesis.md) — synthesized findings and 3 viable paths
  - [03_team-research.md](026_remove_canonicalr_irreflexive_axiom/reports/03_team-research.md) — modal non-definability, IRR rule, completeness (3 teammates)
  - [04_team-research.md](026_remove_canonicalr_irreflexive_axiom/reports/04_team-research.md) — IRR without T-axiom, reflexive semantics implications (3 teammates)
  - [05_team-research.md](026_remove_canonicalr_irreflexive_axiom/reports/05_team-research.md) — CanonicalTask vs CanonicalR reframing (3 teammates)
  - [18_teammate-a-findings.md](026_remove_canonicalr_irreflexive_axiom/reports/18_teammate-a-findings.md) — CanonicalTask as central relation: negative duration verified, irreflexivity reformulation
  - [18_teammate-b-findings.md](026_remove_canonicalr_irreflexive_axiom/reports/18_teammate-b-findings.md) — 69-file usage map, 4-phase refactoring strategy, backward sorry as critical blocker
  - [18_team-research.md](026_remove_canonicalr_irreflexive_axiom/reports/18_team-research.md) — Wave 6 synthesis: CanonicalTask as native TaskFrame concept, irreflexivity reformulation path
- **Plan**: [01_eliminate-canonicalr.md](026_remove_canonicalr_irreflexive_axiom/plans/01_eliminate-canonicalr.md) — 8-phase plan for eliminating CanonicalR as primary concept

**Description**: Investigate removal of `canonicalR_irreflexive_axiom` (CanonicalIrreflexivity.lean:1212). Research conclusively shows CanonicalTask refactoring does NOT help — `¬CanonicalTask(u,1,u)` reduces exactly to `¬CanonicalR(u,u)` because the f_content condition in Succ is trivially satisfied on the diagonal. All 16 usage sites across 6 active files (SaturatedChain 8, FMCSTransfer 2, CanonicalSerialFrameInstance 2+2, TimelineQuotCanonical 1, ClosureSaturation 2, IncrementalTimeline 1) require CanonicalR-level irreflexivity. Three viable paths: **(A)** Prove via reflexive T-axiom — `CanonicalIrreflexivity.lean` contains 1170 lines of complete proof infrastructure from Task 967 that works under reflexive semantics; check if temporal T-axiom `H(φ)→φ` is available. **(B)** Add Gabbay IRR inference rule to proof system (high effort but principled). **(C)** Accept axiom with fixed documentation — `CanonicalIrreflexivityAxiom.lean` falsely claims "proven theorem (Task 967)" but actual implementation is a Lean axiom since Task 991's strict semantics revert. Fix this inconsistency regardless of path chosen.

---

### 25. Shift proof architecture from CanonicalR to CanonicalTask/Succ
- **Effort**: 9.5-10.5 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-03-22
- **Language**: lean4
- **Dependencies**: none
- **Research**:
  - [01_team-research.md](025_rename_canonicalr_to_existstask/reports/01_team-research.md) — Audit + architecture + irreflexivity (3 teammates)
  - [05_team-research.md](025_rename_canonicalr_to_existstask/reports/05_team-research.md) — Blocker analysis (task 25 vs 29 overlap)
  - [06_task29-impact-analysis.md](025_rename_canonicalr_to_existstask/reports/06_task29-impact-analysis.md) — Post-task-29 plan review
- **Plan**:
  - [03_updated-scope-rename.md](025_rename_canonicalr_to_existstask/plans/03_updated-scope-rename.md) — v3: updated scope (1811 usages, 63 files) (current)
  - [02_preorder-compatible-rename.md](025_rename_canonicalr_to_existstask/plans/02_preorder-compatible-rename.md) — v2: superseded
  - [01_implementation-plan.md](025_rename_canonicalr_to_existstask/plans/01_implementation-plan.md) — v1: superseded (blocked on fresh G-atom proofs)
- **Summary**: [01_rename-summary.md](025_rename_canonicalr_to_existstask/summaries/01_rename-summary.md) — Renamed CanonicalR to ExistsTask with backward compat aliases. Reduced CanonicalIrreflexivity.lean from 1515 to 298 lines.

**Description**: Rename CanonicalR to ExistsTask and retire Gabbay infrastructure. v2 plan drops Phases 1-2 (per-witness strictness proofs blocked by same mathematical issue as task 29 — pathological MCS where G(¬q) ∈ M for all atoms). Preserves Task 29's two-layer architecture. Axiom removal is Task 26's scope.

---


### 22. Direct multi-family bundle construction
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task 15
- **Research**:
  - [01_multi-family-research.md](022_direct_multi_family_bundle/reports/01_multi-family-research.md)
  - [02_naming-conventions.md](022_direct_multi_family_bundle/reports/02_naming-conventions.md)
  - [03_implementation-review.md](022_direct_multi_family_bundle/reports/03_implementation-review.md)
- **Plan**: [01_direct-bundle-plan.md](022_direct_multi_family_bundle/plans/01_direct-bundle-plan.md)

**Description**: Replace ClosedFlagIntBFMCS bridge/wrapper with direct multi-family construction where bundle families = all discreteClosedMCS members. Eliminates 3 coverage sorries: (1) modal_forward cross-family transfer (ClosedFlagIntBFMCS.lean:187), (2) modal_backward coverage gap (ClosedFlagIntBFMCS.lean:135), (3) chain membership for t!=0 (ClosedFlagIntBFMCS.lean:267). Refactors away the bridge pattern — the BFMCS Int should be constructed directly from the closed set, not wrapped through an intermediate ClosedFlagFMCS layer. The key insight: if families cover all of discreteClosedMCS, then "true in all families" = "true in all closed-set MCS", resolving the coverage gap.

---


### 24. Discrete axiom removal and documentation cleanup
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Tasks 22, 23

**Description**: Final cleanup gated on sorry-free discrete_representation_unconditional. (1) Remove 3 axioms: discrete_Icc_finite_axiom (DiscreteTimeline.lean:316), discreteImmediateSuccSeed_consistent_axiom (DiscreteSuccSeed.lean:284), discreteImmediateSucc_covers_axiom (DiscreteSuccSeed.lean:414). (2) Fix stale docstrings in AlgebraicBaseCompleteness.lean referencing IntFMCSTransfer.lean (lines 100, 127, 140, 259). (3) Remove dead code: singleFamilyBFMCS and construct_bfmcs_from_mcs (AlgebraicBaseCompleteness.lean lines 96-141). (4) Update Bundle/README.md: add ClosedFlagIntBFMCS.lean and ModallyCoherentBFMCS.lean to architecture table, fix stale 0-sorries claim, update Future Work item 3, update timestamp. (5) Update TODO.md metadata (sorry_count, axiom_count). Subsumes relevant items from task 21 scope.

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

### 999. Derive F(phi) → FF(phi) from density axiom
- **Effort**: TBD (estimated 2-4 hours)
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Prove the derivation of `F(φ) → FF(φ)` from the density axiom `GGψ → Gψ`. Two files have the same sorry with the same mathematical gap: (1) `derive_F_to_FF` in `StagedConstruction/CantorPrereqs.lean` (line 111) — needs a `DerivationTree` for `F(φ) → FF(φ)`; (2) `density_of_canonicalR` in `Canonical/CanonicalTimeline.lean` (line 183) — needs the same derivation to find an intermediate `CanonicalR` witness. The density axiom is `GGψ → Gψ` (universal form). The existential dual `F(φ) → FF(φ)` follows via contrapositive: `Fφ = ¬G¬φ`, `FFφ = ¬G¬Fφ = ¬GG¬φ`, so `Fφ → FFφ` is `¬G¬φ → ¬GG¬φ`, the contrapositive of `GGψ → Gψ` for `ψ = ¬φ`. The derivation chains through double-negation and temporal K-distribution. Both sorries are marked `TODO (Task 991)`. Fixing them completes the staged construction pipeline for density proofs.

---

### 998. Redesign FMP filtration for strict temporal semantics
- **Effort**: TBD (estimated 4-8 hours)
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: Redesign the FMP (Finite Model Property) filtration for strict temporal semantics. The 2 sorry'd theorems in `Decidability/FMP/TruthPreservation.lean` — `mcs_all_future_closure` (line 263) and `mcs_all_past_closure` (line 281) — are deprecated because the temporal T-axiom (`Gφ → φ`) is NOT valid under strict semantics. `filtration_all_future_forward` and `filtration_all_past_forward` depend on them. The FMP module is separate from the main decidability pipeline (`decide` is sorry-free), but completing it formally proves the finite model property. Resolution options: (A) restrict FMP statement to serial frames where temporal seriality holds, (B) redesign filtration to avoid temporal reflexivity entirely, (C) prove the filtered model satisfies a weaker correctness property sufficient for the FMP theorem. Note: `mcs_finite_model_property` in `FMP.lean` does NOT directly use these sorry'd lemmas, so the impact is localized to `filtration_all_future_forward`/`backward`.

---

### 993. Add stability operator to bimodal formula language
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Add the stability operator (box-dot) to the bimodal formula language. The stability operator quantifies over histories passing through the same world state at a given time: (box-dot)phi at (alpha, t) holds iff phi holds at (beta, t) for all beta in Omega with beta(t) = alpha(t). Requires: (1) extend Formula inductive type with stability constructor, (2) define semantics in TaskModel, (3) add S5(box-dot) axiom schemas (T, 4, B, K), (4) prove box implies box-dot (absorption), (5) prove box-dot commutes with box but NOT with G/H. Per research-002 Section 6: box-dot and G have no valid interaction axioms due to genuine branching.

---

### 992. Implement Shift-Closed Tense S5 Algebra representation theorem
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [01_stsa-algebraic-analysis.md](992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md)

**Description**: Implement the Shift-Closed Tense S5 Algebra (STSA) representation theorem. Define STSA as a Lean structure extending BooleanAlgebra with box, G, H, sigma operators and interaction axioms. Lift temporal duality sigma from swap_temporal to the Lindenbaum quotient. Prove LindenbaumAlg is an STSA instance by wiring existing pieces (BooleanStructure, InteriorOperators, UltrafilterMCS). Restructure ParametricRepresentation into unified STSA representation theorem. Research report 001 provides complete algebraic analysis with ~80% of formalization already existing.

---

### 989. Discrete algebraic completeness
- **Effort**: TBD
- **Status**: [RESEARCHING]
- **Blocked on**: Task 995 (FMCS domain transfer lemma), Task 974 (SuccOrder instance)
- **Language**: lean

**Description**: Prove discrete algebraic completeness using D = Int. Requires: (1) FMCS domain transfer from CanonicalMCS to Int (task 995), (2) proving DF and DP axioms are valid in `DiscreteCanonicalTaskFrame Int` (the parametric canonical TaskFrame instantiated at Int), (3) SuccOrder instance on DiscreteTimelineQuot (task 974, archived), (4) wiring `discrete_representation_conditional` to obtain `valid_discrete φ → ⊢_discrete φ`. Note: `DiscreteInstantiation.lean` uses live parametric infrastructure (`ParametricCanonicalTaskFrame Int`), not the deprecated `DiscreteTimeline.discreteCanonicalTaskFrame`.

---

### 988. Dense algebraic completeness
- **Effort**: 8 hours (multi-family BFMCS)
- **Status**: [RESEARCHING]
- **Language**: lean
- **Dependencies**: Task #1002, Task #1003
- **Research**: [13_dense-completeness-synthesis.md](988_dense_algebraic_completeness/reports/13_dense-completeness-synthesis.md) (synthesis), [12_teammate-a-findings.md](988_dense_algebraic_completeness/reports/12_teammate-a-findings.md), [12_teammate-b-findings.md](988_dense_algebraic_completeness/reports/12_teammate-b-findings.md)
- **Plan**: [12_multi-family-bfmcs-bundle.md](988_dense_algebraic_completeness/plans/12_multi-family-bfmcs-bundle.md) (v12: Multi-family BFMCS bundle)
- **Handoff**: [phase-1-handoff-20260317.md](specs/988_dense_algebraic_completeness/handoffs/phase-1-handoff-20260317.md)
- **Summary**: [05_v10-implementation-summary.md](specs/988_dense_algebraic_completeness/summaries/05_v10-implementation-summary.md) (v10 blocked)

**Status note (2026-03-19)**: Plans v4-v10 all blocked. Synthesis report 13 identifies two independent blockers: (1) forward_F chain witness termination, (2) modal_backward multi-family requirement. **Recommended approach**: Zorn saturated chain via ChainFMCS infrastructure - builds saturation by construction, avoids TimelineQuot termination gap. Next: create plan v11.

**Description**: Prove dense algebraic completeness using D = Rat. Requires: (1) a sorry-free BFMCS construction over Rat (adapting the Int construction with density-exploiting witness placement), (2) proving the DN axiom is valid in `DenseCanonicalTaskFrame Rat` (Rat's density gives the required intermediate witnesses), (3) wiring `dense_representation_conditional` to obtain `valid_dense φ → ⊢_dense φ`. Does not overlap with task 982 (TimelineQuot approach).

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


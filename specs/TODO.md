---
next_project_number: 54
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

## Recommended Order

*Updated 2026-03-23. Incorporates ROADMAP.md analysis, Class A/B sorry classification, and algebraic perspective from merge.*

**Goal**: Zero custom axioms, zero sorries on the completeness path. Task 42 is the umbrella. See [ROADMAP.md](/ROADMAP.md) for architectural context.

### 1. Axiom Elimination — Critical Path (task 42 umbrella)

```
Phase A                    Phase B              Phase C              Phase D
    48 → 52 ──────────→ 36 ──────────────→ 37 ──────────→ 53 (wire completeness)
     │                                                      │
     └── 49 (fallback)                                Phase E: verify
```

**Phase A — Bounded F-depth (Class B sorries):**

Task 48's Class A sorries (modal duality via DNE) are **resolved**. Remaining 7 sorries are Class B: intermediate lemmas `restricted_single_step_forcing` and `restricted_succ_propagates_F_not` are **FALSE as stated** (MCS extension nondeterminism at closure boundary). Requires restructuring.

1. **48** → replan (13 plan versions exhausted single-step forcing; needs v14 with direct induction)
2. **52** → research + plan + implement (direct bounded_witness via f_step disjunction tracking — the concrete restructuring)
3. **49** → fallback (FMP-based approach if 52 fails — uses filtration, avoids deferralClosure entirely)

**Phase B — Depends on 48/52:**

4. **36** → implement after 52 (prove `f_nesting_boundary` — axiom 4)

**Phase C — Depends on 36:**

5. **37** → implement after 36 (prove `p_nesting_boundary` — axiom 5, mirrors 36)

**Phase D — Wire completeness:**

6. **53** → implement after 37 (wire SuccChainCompleteness → FrameConditions/Completeness, resolve 9 wiring sorries)

**Phase E — Verification:**

7. `lean_verify` on completeness theorems — confirm zero custom axioms
8. Update TODO.md axiom_count to 0

### 2. Post-Axiom Cleanup

1. **41** ✓ [COMPLETED] (eliminate D=CanonicalMCS pattern — done 2026-03-23)
2. **21** → defer (tech debt cleanup — depends on 18; fold CanonicalR alias cleanup per ROADMAP)
3. **19** → defer (deprecate old discrete pipeline — low priority after archival)

### 3. Algebraic Alternative (parallel investigation)

Per ROADMAP algebraic gap analysis, the sorry-free algebraic path could bypass SuccChain entirely:

1. **992** → elevate to medium priority (STSA temporal shift automorphism — 4-6h, independent of critical path)
   - Formalizes Lindenbaum algebra temporal shift
   - Could provide `construct_bfmcs` via Stone-space unraveling instead of chain construction
   - If successful, makes SuccChain sorries irrelevant

### 4. Deferred — Not Critical Path

1. **18** → blocked (dense representation theorem — 4 localized sorries, defer until base is clean)
2. **20** → depends on 18 (parametric canonical audit)
3. **998** → defer (FMP redesign — separate concern)

### 5. Backlog (researched, not urgent)

1. **8** → plan (genuine truth_at completeness — publication quality, 12-20h)
2. **6** → plan (canonical TaskFrame completeness — may be superseded by task 8)
3. **39** → defer (preorder semantics study — theoretical)
4. **953** → defer (bilateral proof system — 55-90h)
5. **949** → defer (update Demo.lean — cosmetic)
6. **619** → defer (skill migration — meta, blocked on GitHub #16803)

## Tasks

---

### 53. Wire completeness after axiom elimination
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Tasks 36, 37

**Description**: After axiom elimination (48→36→37), wire SuccChainCompleteness through FrameConditions/Completeness to achieve sorry-free completeness path. Connect construct_bfmcs callback to algebraic ParametricRepresentation pipeline. Resolve 9 completeness wiring sorries blocked by SuccChain.

---

### 52. Direct bounded_witness via f_step disjunction tracking
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Task 48
- **Parent Task**: 48

**Description**: Restructure `restricted_bounded_witness` to prove directly by induction on deferralClosure finiteness, tracking the f_step disjunction `psi in v OR F(psi) in v` instead of trying to eliminate it at each step (which is FALSE). Delete false intermediate lemmas (`restricted_single_step_forcing`, `restricted_succ_propagates_F_not` and primed variants). Use lexicographic termination measure `(F-nesting depth, dc size)`. The f_step guarantees progress at each step (either resolve or defer), and dc finiteness guarantees termination. Preserve the Class A proof (lines 2354-2449) as optimized base case for FF(psi) in deferralClosure.

---

### 49. FMP-based boundedness proof (fallback)
- **Effort**: 6-8 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task 48
- **Parent Task**: 36
- **Research**: [02_spawn-analysis.md](036_prove_f_nesting_boundary/reports/02_spawn-analysis.md)

**Description**: FALLBACK TASK: Only pursue if Task 48 encounters fundamental obstacles. Connect succ_chain_fam to FMP infrastructure to prove boundedness via Finite Model Property. Use existing FMP infrastructure in Theories/Bimodal/Metalogic/Decidability/FMP/ including ClosureMCS, FiniteModel, Filtration, and TruthPreservation theorems.

---

### 48. Prove succ_chain_fam MCS have bounded F-depth
- **Effort**: 8 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task 47
- **Parent Task**: 36
- **Research**:
  - [02_spawn-analysis.md](036_prove_f_nesting_boundary/reports/02_spawn-analysis.md)
  - [01_bounded-f-depth.md](048_prove_succ_chain_fam_bounded_f_depth/reports/01_bounded-f-depth.md)
  - [02_team-research.md](048_prove_succ_chain_fam_bounded_f_depth/reports/02_team-research.md)
  - [03_blocker-analysis.md](048_prove_succ_chain_fam_bounded_f_depth/reports/03_blocker-analysis.md)
  - [06_team-research.md](048_prove_succ_chain_fam_bounded_f_depth/reports/06_team-research.md)
  - [08_lexicographic-wf.md](048_prove_succ_chain_fam_bounded_f_depth/reports/08_lexicographic-wf.md)
  - [09_boundary-case.md](048_prove_succ_chain_fam_bounded_f_depth/reports/09_boundary-case.md)
  - [10_g-content-path.md](048_prove_succ_chain_fam_bounded_f_depth/reports/10_g-content-path.md)
  - [15_team-research.md](048_prove_succ_chain_fam_bounded_f_depth/reports/15_team-research.md)
  - [16_derivability-blocker.md](048_prove_succ_chain_fam_bounded_f_depth/reports/16_derivability-blocker.md)
  - [26_roadmap-synthesis.md](048_prove_succ_chain_fam_bounded_f_depth/reports/26_roadmap-synthesis.md)
- **Plan**:
  - [01_restricted-succ-chain.md](048_prove_succ_chain_fam_bounded_f_depth/plans/01_restricted-succ-chain.md)
  - [02_augmented-closure.md](048_prove_succ_chain_fam_bounded_f_depth/plans/02_augmented-closure.md)
  - [03_restricted-p-step.md](048_prove_succ_chain_fam_bounded_f_depth/plans/03_restricted-p-step.md)
  - [04_restricted-blocking.md](048_prove_succ_chain_fam_bounded_f_depth/plans/04_restricted-blocking.md)
  - [05_fuel-recursion.md](048_prove_succ_chain_fam_bounded_f_depth/plans/05_fuel-recursion.md)
  - [06_bounded-witness.md](048_prove_succ_chain_fam_bounded_f_depth/plans/06_bounded-witness.md)
  - [07_boundary-resolution.md](048_prove_succ_chain_fam_bounded_f_depth/plans/07_boundary-resolution.md)
  - [08_g-content-fix.md](048_prove_succ_chain_fam_bounded_f_depth/plans/08_g-content-fix.md)
  - [09_boundary-resolution-seed.md](048_prove_succ_chain_fam_bounded_f_depth/plans/09_boundary-resolution-seed.md)
  - [10_chi-in-u-restriction.md](048_prove_succ_chain_fam_bounded_f_depth/plans/10_chi-in-u-restriction.md)
  - [12_drm-negation-completeness.md](048_prove_succ_chain_fam_bounded_f_depth/plans/12_drm-negation-completeness.md)
  - [13_weaken-bounded-witness.md](048_prove_succ_chain_fam_bounded_f_depth/plans/13_weaken-bounded-witness.md)
- **Summary**:
  - [01_restricted-succ-chain-summary.md](048_prove_succ_chain_fam_bounded_f_depth/summaries/01_restricted-succ-chain-summary.md)
  - [02_augmented-closure-summary.md](048_prove_succ_chain_fam_bounded_f_depth/summaries/02_augmented-closure-summary.md)
  - [05_fuel-recursion-partial.md](048_prove_succ_chain_fam_bounded_f_depth/summaries/05_fuel-recursion-partial.md)
  - [06_bounded-witness-summary.md](048_prove_succ_chain_fam_bounded_f_depth/summaries/06_bounded-witness-summary.md)

**Description**: Prove that the specific MCS in succ_chain_fam construction have bounded F-iteration depth. Show that the construction places F-witnesses at bounded depth, formalize that if F(phi) in M_n then the witness is at a bounded distance in the chain. Use closure depth bound from Task 47 to replace the sorry in f_nesting_is_bounded and p_nesting_is_bounded.

---

### 42. Investigate and eliminate ALL custom axioms — architectural redesign permitted
- **Effort**: 20-40 hours
- **Status**: [RESEARCHED]
- **Research**: [01_team-research.md](specs/042_eliminate_all_axioms_architectural_redesign/reports/01_team-research.md)
- **Language**: lean4

**Description**: Investigate why each of the 9 custom Lean `axiom` declarations exists, determine the proof strategy or architectural change needed to eliminate it, and execute the removal. Architectural restructuring (e.g., changing seed constructions, redesigning the Succ relation, restructuring the chain construction) is explicitly permitted if it enables proper proofs. The goal is zero custom axioms — `#print axioms` on completeness theorems should show only `propext`, `Classical.choice`, `Quot.sound`, and Lean compiler axioms.

**Axiom inventory** (verified via `lean_verify`):

*Production path — flow into `succ_chain_truth_lemma`:*
1. `successor_deferral_seed_consistent_axiom` (SuccExistence.lean:266) — asserts the successor seed is consistent
2. `predecessor_deferral_seed_consistent_axiom` (SuccExistence.lean:311) — asserts the predecessor seed is consistent
3. `predecessor_f_step_axiom` (SuccExistence.lean:516) — f-step for predecessor (dual of what task 40 wants for successor)
4. `f_nesting_boundary` (SuccChainFMCS.lean:615) — F-nesting terminates in MCS
5. `p_nesting_boundary` (SuccChainFMCS.lean:727) — P-nesting terminates in MCS

*Additional production:*
6. `existsTask_irreflexive_axiom` (CanonicalIrreflexivity.lean:279) — flows into `dense_completeness_fc`
7. `discrete_Icc_finite_axiom` (DiscreteTimeline.lean:319) — discrete timeline intervals are finite

*StagedConstruction (discrete pipeline):*
8. `discreteImmediateSuccSeed_consistent_axiom` (DiscreteSuccSeed.lean:300)
9. `discreteImmediateSucc_covers_axiom` (DiscreteSuccSeed.lean:430)

**Investigation questions per axiom**: (a) What property does it assert? (b) Why wasn't it proven originally? (c) Can it be proven from existing infrastructure? (d) If not, what architectural change would make it provable? (e) Can the dependent code be restructured to not need this property at all?

**Coordination**: Task 40 plan must be revised (recommends adding 10th axiom). Tasks 34, 36, 37 target individual axioms and should be subsumed or coordinated.

---

### 41. Eliminate D=CanonicalMCS pattern systematically
- **Effort**: 5-6 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-03-23
- **Language**: lean4
- **Research**:
  - [01_team-research.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/01_team-research.md)
  - [02_deep-research.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/02_deep-research.md)
  - [03_removal-analysis.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/03_removal-analysis.md)
- **Plan**:
  - [01_coexistence-strategy.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/plans/01_coexistence-strategy.md) (superseded)
  - [02_removal-strategy.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/plans/02_removal-strategy.md) (superseded)
  - [03_tiered-removal.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/plans/03_tiered-removal.md) (executed)
- **Summary**: [01_tiered-removal-summary.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/summaries/01_tiered-removal-summary.md)

**Description**: Remove the architectural error where the FMCS type parameter D (timeline/duration type) is instantiated with CanonicalMCS (the type of all maximal consistent sets). FMCS model world histories as functions D → W obeying temporal coherence constraints; D should be a timeline type (Int, Rat, TimelineQuot) and W should be world states (MCS). The D=CanonicalMCS pattern conflates these, creating an identity mapping `mcs(w) = w.world` that trivializes F/P witness obligations rather than proving them properly. This pattern is load-bearing across 13+ files: CanonicalFMCS.lean, FMCSDef.lean, ModallyCoherentBFMCS.lean, AlgebraicBaseCompleteness.lean, BaseCompleteness.lean, StagedConstruction/Completeness.lean, TimelineQuotBFMCS.lean, DovetailedTimelineQuotBFMCS.lean, ClosureSaturation.lean, CanonicalConstruction.lean, TemporalCoherence.lean, ChainFMCS.lean, ModalSaturation.lean. The critical sorry-free theorem `temporal_coherent_family_exists_CanonicalMCS` depends entirely on this conflation. Requires constructing proper FMCS with D=Int (or similar timeline type) where F/P witnesses are genuinely proven within the chain construction.

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


### 37. Prove p_nesting_boundary axiom via temporal filtration or Fischer-Ladner closure
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Depends On**: Task 36

**Description**: Prove p_nesting_boundary axiom (SuccChainFMCS.lean:695) via temporal filtration or Fischer-Ladner closure. Symmetric to f_nesting_boundary: given P(phi) in MCS M, there exists d >= 1 such that iter_P d phi in M but iter_P (d+1) phi not in M. Once f_nesting_boundary (task 36) is proven, this follows by F/P duality with minimal additional work. Depends on task 36 infrastructure.

---

### 36. Prove f_nesting_boundary axiom via temporal filtration or Fischer-Ladner closure
- **Effort**: 5 hours
- **Status**: [BLOCKED]
- **Language**: lean4
- **Research**: [01_f-nesting-research.md](036_prove_f_nesting_boundary/reports/01_f-nesting-research.md)
- **Plan**: [01_f-nesting-implementation.md](036_prove_f_nesting_boundary/plans/01_f-nesting-implementation.md)
- **Dependencies**: Task 47, Task 48, Task 49

**Description**: Prove f_nesting_boundary axiom (SuccChainFMCS.lean:615) via temporal filtration or Fischer-Ladner closure. The axiom states: given F(phi) in MCS M, there exists d >= 1 such that iter_F d phi in M but iter_F (d+1) phi not in M. Requires showing F-chains in consistent MCS must terminate. Standard proof uses Fischer-Ladner closure finiteness — the closure of any formula is finite, so the F-iteration sequence must eventually leave M. This eliminates the axiom entirely.

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


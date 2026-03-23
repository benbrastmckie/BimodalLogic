---
next_project_number: 47
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-19T23:50:22Z
task_counts:
  active: 12
  completed: 713
  in_progress: 1
  not_started: 4
  abandoned: 54
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

*Updated 2026-03-23. Reflexive semantics confirmed as best path to completeness. Tasks 25, 26, 43, 44 completed.*

**Goal**: Zero custom axioms, zero sorries on the completeness path. Task 42 is the umbrella.

### 1. Axiom Elimination — Critical Path (task 42 umbrella)

```
Phase 1 (parallel)     Phase 2 (parallel)     Phase 3 (parallel)     Phase 4
    34 ─────────────────────────────────────────────────────────────────────→
    47 ──────────────→ 48 ──────────────→ 36 ──────────────→ 37
    45 ──────────────→ 46 ──────────────→ 40 ──────────────→ 35 (Phase 4)
                                                                    │
                                                              Phase 5: verify
```

**Phase 1 — Parallel (no dependencies):**

1. **34** → implementing (prove 3 SuccExistence seed consistency axioms — axioms 1-3)
2. **47** → completed (prove iter_F leaves subformula closure at bounded depth — foundation for 36)
3. **45** → plan, then implement (research modified successor seed for CanonicalTask p-step — foundation for 40)

**Phase 2 — Parallel (each depends on one Phase 1 task):**

4. **48** → implement after 47 (prove succ_chain_fam MCS have bounded F-depth)
5. **46** → implement after 45 (prove forward chain p-step from research findings)

**Phase 3 — Parallel (each depends on one Phase 2 chain):**

6. **36** → implement after 47+48 (prove `f_nesting_boundary` — axiom 4; task 49 is fallback if 48 fails)
7. **40** → implement after 45+46 (prove successor p_step — fills SuccChainFMCS.lean:350 sorry)

**Phase 4 — Parallel (each depends on one Phase 3 task):**

8. **37** → implement after 36 (prove `p_nesting_boundary` — axiom 5, mirrors 36)
9. **35** → resume Phase 4 after 40 (fill `succ_chain_fam_p_step` — the only completeness-path sorry)

**Phase 5 — Verification:**

10. `lean_verify` on completeness theorems — confirm zero custom axioms
11. Update TODO.md axiom_count to 0

### 2. Post-Axiom Cleanup

1. **41** → plan (eliminate D=CanonicalMCS pattern — separate concern, after axiom cleanup)
2. **21** → defer (tech debt cleanup — depends on 18)
3. **19** → defer (deprecate old discrete pipeline — low priority after archival)

### 3. Deferred — Not Critical Path

1. **18** → blocked (dense representation theorem — stuck, defer until base is clean)
2. **20** → depends on 18 (parametric canonical audit)
3. **998** → defer (FMP redesign — separate concern)

### 4. Backlog (researched, not urgent)

1. **8** → plan (genuine truth_at completeness — publication quality, high investment)
2. **6** → plan (canonical TaskFrame completeness — publication quality)
3. **39** → defer (preorder semantics study — theoretical)
4. **992** → defer (STSA representation)
5. **953** → defer (bilateral proof system — 55-90h)
6. **949** → defer (update Demo.lean — cosmetic)
7. **619** → defer (skill migration — meta, low priority)

## Tasks

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
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task 47
- **Parent Task**: 36
- **Research**: [02_spawn-analysis.md](036_prove_f_nesting_boundary/reports/02_spawn-analysis.md)

**Description**: Prove that the specific MCS in succ_chain_fam construction have bounded F-iteration depth. Show that the construction places F-witnesses at bounded depth, formalize that if F(phi) in M_n then the witness is at a bounded distance in the chain. Use closure depth bound from Task 47 to replace the sorry in f_nesting_is_bounded and p_nesting_is_bounded.

---

### 47. Prove iter_F leaves subformula closure at bounded depth
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-03-23
- **Summary**: Proved iter_F leaves closureWithNeg at bounded depth. Defined f_nesting_depth, max_F_depth_in_closure. Proved iter_F_not_mem_closureWithNeg, restricted_mcs_iter_F_bound, restricted_mcs_F_bounded. Foundation for task 48 (succ_chain_fam bounded F-depth).
- **Language**: lean4
- **Dependencies**: None
- **Parent Task**: 36
- **Research**: [02_spawn-analysis.md](036_prove_f_nesting_boundary/reports/02_spawn-analysis.md)
- **Plan**: [01_closure-depth-bound.md](047_prove_iter_f_leaves_closure/plans/01_closure-depth-bound.md)

**Description**: Prove that for any formula phi, the iterated F-application iter_F n phi eventually leaves the subformula closure. Define or compute the maximum F-nesting depth in closureWithNeg(phi), then prove that iter_F (max_depth + 1) phi is NOT in closureWithNeg(phi). This provides the foundation for proving boundedness: in any RestrictedMCS over phi, the sequence iter_F 1 phi, iter_F 2 phi, ... must eventually exit the closure.

---

### 46. Prove forward chain p-step from research findings
- **Effort**: 2-3 hours
- **Status**: [PLANNING]
- **Language**: lean4
- **Dependencies**: Task 45
- **Parent Task**: 40
- **Research**:
  - [02_spawn-analysis.md](specs/040_succ_p_step_forward_chain/reports/02_spawn-analysis.md)
  - [02_team-research.md](specs/046_prove_forward_chain_p_step/reports/02_team-research.md)

**Description**: Based on research findings from task 45, implement the proof that forward chain pairs satisfy p-step, filling the sorry at SuccChainFMCS.lean:350. If structural proof path found: add helper lemmas to WitnessSeed.lean, prove forward_chain_p_step theorem, fill the sorry. If minimal axiom recommended: add axiom to SuccExistence.lean with semantic justification.

---

### 45. Research modified successor seed for CanonicalTask p-step
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-03-23
- **Summary**: No clean structural solution exists. Epistemic asymmetry prevents constraining P-formulas in successor. Recommend reformulating completeness to avoid forward p-step, or accept minimal axiom.
- **Language**: lean4
- **Dependencies**: None
- **Parent Task**: 40
- **Research**:
  - [02_spawn-analysis.md](specs/040_succ_p_step_forward_chain/reports/02_spawn-analysis.md)
  - [01_modified-succ-seed-research.md](specs/045_research_modified_successor_seed/reports/01_modified-succ-seed-research.md)
- **Plan**: [01_research-plan.md](specs/045_research_modified_successor_seed/plans/01_research-plan.md)

**Description**: Research how to modify the successor seed construction to satisfy p-step, focusing specifically on the CanonicalTask relation (not ExistsTask Kripke semantics). Key questions: Can futureDeferralDisjunctionsForP be defined? Can temp_a constrain P-formulas in Lindenbaum extension? Can h_content_reverse derive p-step constraints?

---

### 44. Prove backward sorry and make irreflexivity derivable
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Language**: lean4
- **Dependencies**: none
- **Parent**: Task 26 (phases 6-7 skipped)
- **Research**:
  - [01_teammate-a-findings.md](specs/044_prove_backward_sorry_irreflexivity/reports/01_teammate-a-findings.md) — Primary approach: backward sorry likely unprovable, irreflexivity impossible under reflexive semantics
  - [02_teammate-b-findings.md](specs/044_prove_backward_sorry_irreflexivity/reports/02_teammate-b-findings.md) — Alternative approaches: per-construction strictness exists, Layer 2 deletion recommended
  - [01_team-research.md](specs/044_prove_backward_sorry_irreflexivity/reports/01_team-research.md) — Synthesis: reframe as delete existsTask_irreflexive_axiom and Layer 2 dependents
- **Plan**: [01_delete-irreflexivity-axiom.md](specs/044_prove_backward_sorry_irreflexivity/plans/01_delete-irreflexivity-axiom.md) — 5-phase plan: delete axiom + deprecated theorems
- **Summary**: [01_implementation-summary.md](specs/044_prove_backward_sorry_irreflexivity/summaries/01_implementation-summary.md) — Deleted existsTask_irreflexive_axiom and 6 deprecated theorems (~260 lines). Axiom count reduced by 1. Original scope mathematically impossible under reflexive semantics.

**Description**: Complete the optional phases 6-7 from task 26. Phase 6: Prove `ExistsTask M N → ∃ n >= 1, CanonicalTask M n N` in CanonicalRecovery.lean (the backward sorry). This requires analyzing the Lindenbaum witness construction and proving witnesses satisfy the F-step condition. Phase 7: Once backward sorry is filled, derive ExistsTask irreflexivity from canonicalTask_irreflexive, completing the dual derivation. High effort, exploratory work.

---

### 43. Archive StagedConstruction and DiscreteTimeline paths to Boneyard
- **Effort**: 2-4 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-03-23
- **Summary**: Archived 40 files to Boneyard, eliminated axioms 7-9. Axiom count 9→6.
- **Research**: [01_archival-analysis.md](specs/043_archive_dead_paths_to_boneyard/reports/01_archival-analysis.md)
- **Plan**: [01_archival-plan.md](specs/043_archive_dead_paths_to_boneyard/plans/01_archival-plan.md)
- **Implementation**: [01_archival-summary.md](specs/043_archive_dead_paths_to_boneyard/summaries/01_archival-summary.md)
- **Language**: lean4

**Description**: Archive superseded code paths to Boneyard to eliminate axioms 7-9. Move StagedConstruction/ directory, Domain/DiscreteTimeline.lean, Domain/DurationTransfer.lean (W=D conflation), and Canonical/CanonicalTimeline.lean to Boneyard. These carry 3 axioms (`discrete_Icc_finite_axiom`, `discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom`) and several sorries, all superseded by the SuccChain completeness approach. Update imports and verify `lake build` passes.

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
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Research**: [01_team-research.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/01_team-research.md)

**Description**: Remove the architectural error where the FMCS type parameter D (timeline/duration type) is instantiated with CanonicalMCS (the type of all maximal consistent sets). FMCS model world histories as functions D → W obeying temporal coherence constraints; D should be a timeline type (Int, Rat, TimelineQuot) and W should be world states (MCS). The D=CanonicalMCS pattern conflates these, creating an identity mapping `mcs(w) = w.world` that trivializes F/P witness obligations rather than proving them properly. This pattern is load-bearing across 13+ files: CanonicalFMCS.lean, FMCSDef.lean, ModallyCoherentBFMCS.lean, AlgebraicBaseCompleteness.lean, BaseCompleteness.lean, StagedConstruction/Completeness.lean, TimelineQuotBFMCS.lean, DovetailedTimelineQuotBFMCS.lean, ClosureSaturation.lean, CanonicalConstruction.lean, TemporalCoherence.lean, ChainFMCS.lean, ModalSaturation.lean. The critical sorry-free theorem `temporal_coherent_family_exists_CanonicalMCS` depends entirely on this conflation. Requires constructing proper FMCS with D=Int (or similar timeline type) where F/P witnesses are genuinely proven within the chain construction.

---

### 40. Add p-step condition to Succ relation or prove successor_satisfies_p_step
- **Effort**: 4-8 hours
- **Status**: [BLOCKED]
- **Language**: lean4
- **Depends On**: Task 35 (partial), Task 45, Task 46
- **Blocked**: Proof requires `successor_p_step_axiom` (prohibited by constraints)
- **Spawned**: Task 45 (research), Task 46 (implementation)
- **Research**: [01_team-research.md](specs/040_succ_p_step_forward_chain/reports/01_team-research.md)
- **Plan**: [02_proof-based-approach.md](specs/040_succ_p_step_forward_chain/plans/02_proof-based-approach.md)
- **Analysis**: [01_impossibility-analysis.md](specs/040_succ_p_step_forward_chain/summaries/01_impossibility-analysis.md)
- **Spawn Analysis**: [02_spawn-analysis.md](specs/040_succ_p_step_forward_chain/reports/02_spawn-analysis.md)

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
- **Status**: [IMPLEMENTING]
- **Language**: lean4
- **Dependencies**: none
- **Follow-up from**: Task 29 Phase 7 (deferred)
- **Research**:
  - [01_seed-consistency-research.md](034_prove_succ_seed_consistency_axioms/reports/01_seed-consistency-research.md)
  - [02_team-research.md](034_prove_succ_seed_consistency_axioms/reports/02_team-research.md) — Team synthesis (3 teammates): blocker analysis
  - [02_teammate-a-findings.md](034_prove_succ_seed_consistency_axioms/reports/02_teammate-a-findings.md) — Provability analysis
  - [02_teammate-b-findings.md](034_prove_succ_seed_consistency_axioms/reports/02_teammate-b-findings.md) — Alternative constructions
  - [02_teammate-c-findings.md](034_prove_succ_seed_consistency_axioms/reports/02_teammate-c-findings.md) — Semantic necessity
  - [03_team-research.md](034_prove_succ_seed_consistency_axioms/reports/03_team-research.md) — Team round 2: constrained seed solution
  - [03_teammate-a-findings.md](034_prove_succ_seed_consistency_axioms/reports/03_teammate-a-findings.md) — Alt 3B ruled out
  - [03_teammate-b-findings.md](034_prove_succ_seed_consistency_axioms/reports/03_teammate-b-findings.md) — Constrained Lindenbaum analysis
  - [03_teammate-c-findings.md](034_prove_succ_seed_consistency_axioms/reports/03_teammate-c-findings.md) — Bidirectional construction (recommended)
- **Plan**: [01_seed-axiom-elimination.md](034_prove_succ_seed_consistency_axioms/plans/01_seed-axiom-elimination.md)

**Description**: Prove or remove the 3 axioms in `Bundle/SuccExistence.lean` that were deferred from task 29 Phase 7: (1) `successor_deferral_seed_consistent_axiom` (line 266) — asserts successor deferral seed is consistent, (2) `predecessor_deferral_seed_consistent_axiom` (line 311) — symmetric predecessor version, (3) `predecessor_f_step_axiom` (line 516) — F-step condition for predecessor construction. Under reflexive semantics with T-axiom available, these seed consistency claims may be provable syntactically. The seeds contain `g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}` (successor) or `h_content(u) ∪ {φ ∨ P(φ) | P(φ) ∈ u}` (predecessor). The deferral disjunctions `φ ∨ F(φ)` are tautological consequences of `F(φ)`, and the g_content formulas are jointly consistent by MCS properties. Research whether T-axiom (`G(φ) → φ`) provides enough to close these proofs. Note: discrete seed axioms (`discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom`) are covered by task 24.

---

### 26. Remove or justify canonicalR_irreflexive_axiom
- **Effort**: 2-8 hours (depends on path chosen)
- **Status**: [COMPLETED]
- **Completed**: 2026-03-23
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
- **Plan**:
  - [02_migrate-to-existstask.md](026_remove_canonicalr_irreflexive_axiom/plans/02_migrate-to-existstask.md) — v2: migrate to ExistsTask (CanonicalR now alias) (current)
  - [01_eliminate-canonicalr.md](026_remove_canonicalr_irreflexive_axiom/plans/01_eliminate-canonicalr.md) — v1: superseded (assumed CanonicalR would remain primary)
- **Summary**: [01_migrate-existstask-summary.md](026_remove_canonicalr_irreflexive_axiom/summaries/01_migrate-existstask-summary.md) — Migrated 67 files from CanonicalR to ExistsTask. Derived canonicalTask_irreflexive. Eliminated 266 deprecation warnings.

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


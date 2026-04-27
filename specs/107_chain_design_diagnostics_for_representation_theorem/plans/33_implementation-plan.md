# Implementation Plan: Task #107 (v20 -- Direct g-Construction, No rebuild_g)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 10 hours (remaining)
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/28_team-research.md], [reports/29_team-research.md], [reports/30_team-research.md], [reports/31_team-research.md], [reports/32_team-research.md], [reports/33_team-research.md], [summaries/32_fuc-sorry-analysis.md], [handoffs/32_phase3-g-population-handoff.md], [handoffs/32_phase5b-blocker-analysis.md]
- **Artifacts**: plans/33_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Round 33 team research (4 teammates, unanimous) and the FUC sorry analysis identified two fatal problems in the v19 architecture: (1) `burgessR3Maximal_exists_general` is FALSE (counterexample: A with G(p), C with p.neg), tainting all downstream theorems via `rebuild_g`; (2) the intersection-based `limit_g` definition is tautological for FUC -- it contains phi only if phi is already everywhere, which is what we need to prove. The fix is to remove `rebuild_g` entirely, construct g-values directly within each elimination function per Burgess's architecture, revert `limit_g` to the stage-based definition with g-immutability, and close FUC using the C5 seed construction plus C3 interval containment.

This revision restructures Phases 3-6 as a strictly sequential pipeline (shared files prevent parallelism). Phases 1, 1.5, 2, and 4A are preserved as [COMPLETED].

### Research Integration

- Reports 28-30 (prior rounds): Established BurgessR3Maximal as primary relation, cruft purge, existence proof. Integrated in plan v17.
- Report 31 (team research): Confirmed two independent workstreams. g(x,y) does NOT need to be MCS. gamma=top sub-case is trivially False. Integrated in plan v18.
- Report 32 (team research): Burgess never needs general seed. Lemma 2.4 provides eta for C5. Guard algebra (BX7 + BX2) preserves burgessR3. Integrated in plan v19.
- **Report 33 (team research, 4 teammates)**: Primary input for this revision. Remove rebuild_g entirely. All 7 elimination functions set g=chi.g unchanged (confirmed by audit). Direct g-construction in elimination functions. limit_g must be stage-based, not intersection. Estimated 700-800 lines of changes.
- **Summary 32 (FUC sorry analysis)**: Proved `burgessR3Maximal_exists_general` is false with explicit counterexample. All limit-level theorems are tainted. rebuild_g path is unsalvageable.
- **Handoff 32 (Phase 3 g-population)**: Documents what was built (rebuild_g, intersection limit_g, bridge lemmas) -- all of which must be reverted/deleted. Also documents compilation errors from incomplete witness lemma rewrites.
- **Handoff 32 (Phase 5B blocker)**: Confirms FUC guard is unprovable with empty g-values. C3 interval containment only works with non-empty g-values from direct construction.

### Prior Plan Reference

Plan v19 (artifact 32): Phases 1, 1.5, 2 [COMPLETED]. Phase 3 [PARTIAL] -- guard algebra and `burgessR3Maximal_exists_from_seed` proved, but `rebuild_g` and intersection `limit_g` must be deleted. Phase 4A [COMPLETED] -- C4/C4' hard case closed. Phases 4B, 5A, 5B, 6 [NOT STARTED] or [BLOCKED]. This revision replaces Phases 3-6 with a new 3-5 structure: delete tainted code, direct g-construction in elimination functions, stage-based limit_g with immutability, and FUC closure.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing all sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Delete `rebuild_g`, `rebuild_g_c0`, `rebuild_g_f`, `rebuild_g_dom`, `rebuild_g_c2'` from ChronicleConstruction.lean
- Delete `burgessR3Maximal_exists_general` (proved false) from RRelation.lean
- Delete intersection-based `limit_g` and `omega_chain_g_empty` and all vacuous proofs
- Add `c2'` field to EliminationResult
- Modify all 7 elimination functions to construct g-values for new adjacent pairs directly
- C5/C5' elimination: construct g via `burgessR3Maximal_exists_from_seed(f(x_max), f(y), eta)` where eta comes from Lemma 2.4
- C4/C4'/density/g_prop/h_prop elimination: split g via `burgessR3_absorption` on existing g-values
- Preserve g for old pairs (new_chi.g(a,b) = chi.g(a,b))
- omega_chain returns `{chi // chi.c0 AND chi.c2'}` using EliminationResult.c2' directly
- Revert limit_g to stage-based: `limit_g(x,y) = (omega_chain_val N).g(x,y)` where N = first stage with both x,y in domain
- Prove g-immutability across stages
- Prove limit_c3 from finite-stage C3 + immutability
- Prove c3_interval_subset_point from limit_c3
- Close FUC: phi in limit_g(t,s) from C5 seed + immutability, then c3_interval_subset_point for intermediates
- Verify limit_satisfies_c4 and limit_forward_G are sorry-free
- Achieve sorry-free dd_countermodel_chronicle
- Maintain lake build at each phase boundary

**Non-Goals**:
- Adding density axioms (GG->G, HH->H) -- wrong for BX
- Patching `burgessR3Maximal_exists_general` -- it is false, not fixable
- Using limit_g as intersection of f-values -- tautological for FUC
- Keeping rebuild_g in any form -- masks the real construction
- Parallel workstreams -- shared files prevent it
- C5 n>0 case (insert between existing points) -- current construction avoids it
- BXCanonical sorry closure (task 109)
- Deleting rRelation or R3Maximal -- existing sorry-free code uses them

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Modifying 7 elimination functions is large scope (~400 lines) | H | M | Follow team research table for per-function seed source. C4/C4'/density/g_prop/h_prop all use the same burgessR3_absorption pattern. |
| Lemma 2.4 does not expose eta satisfying burgessR(A, eta, C) | H | M | Inspect lemma_2_4 output. Strengthen return type to carry the witness if needed. Non-breaking change. |
| g-immutability proof is complex across all elimination types | M | M | Prove per-elimination-type (each sets g(a,b)=chi.g(a,b) for old pairs), then combine. |
| Compilation cascade from deleting rebuild_g and intersection limit_g | M | H | Phase 3 is explicitly a "break then fix" phase. Expect compilation errors. Fix systematically file by file. |
| burgessR3_absorption (sub-interval inheritance) is non-trivial | M | M | Subset + anti-monotonicity argument. Factor into standalone lemma if needed. |
| C5-with-guard requires threading phi through limit_g to intermediate f-values | M | M | c3_interval_subset_point gives limit_g(t,s) subset limit_f(r) for t < r < s. With non-empty g from seed, this is substantive. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 1.5, 2, 4A | -- (completed) |
| 1 | 3 | 2, 4A (completed) |
| 2 | 4 | 3 |
| 3 | 5 | 4 |

All phases are strictly sequential (shared files: ChronicleConstruction.lean, CounterexampleElimination.lean).

---

### Phase 1: Add until_guard / since_guard Axioms [COMPLETED]

**Goal**: Add sound axioms `until_guard : untl phi psi -> phi` and `since_guard : snce phi psi -> phi` to the BX axiom system, with soundness proofs.

**Tasks**:
- [x] Add `until_guard` constructor to the `Axiom` inductive type in `ProofSystem/Axioms.lean`
- [x] Add `since_guard` constructor (mirror)
- [x] Prove soundness of `until_guard` in `Soundness.lean`
- [x] Prove soundness of `since_guard` in `Soundness.lean`
- [x] Verify `DenseSoundness.lean` and `DiscreteSoundness.lean` still compile
- [x] Prove `until_guard_in_mcs` and `since_guard_in_mcs` for MCS S
- [x] Run lake build and verify no regressions

**Timing**: 2 hours (completed)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- new constructors
- `Theories/Bimodal/Metalogic/Soundness.lean` -- soundness cases
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- MCS-level lemmas

**Verification**:
- until_guard and since_guard in Axiom type
- Soundness.lean remains sorry-free
- MCS-level lemmas compile without sorry
- lake build succeeds

---

### Phase 1.5: Cruft Purge [COMPLETED]

**Goal**: Remove dead code, failed approaches, and stale artifacts before the architectural changes.

**Tasks**:
- [x] Delete `g_ordered` and `h_ordered` definitions
- [x] Delete `claim_2_11` tautological stub
- [x] Replace vacuous `g := fun _ _ => empty` in `singleton_chronicle` with sorry placeholder
- [x] Remove stale "Phase 2" comments
- [x] Delete dead code: `chronicle_fmcs`, `chronicle_bfmcs` and their 8 sorry sites
- [x] Audit for vestiges of failed approaches
- [x] Run lake build and verify no regressions

**Timing**: 2 hours (completed)

**Depends on**: Phase 1

**Files to modify**:
- `Chronicle/ChronicleTypes.lean`, `Chronicle/ChronicleConstruction.lean`, `Chronicle/PointInsertion.lean`, `Chronicle/CounterexampleElimination.lean`, `Chronicle/ChronicleToCountermodel.lean`

**Verification**:
- Dead code deleted; lake build succeeds; sorry count -8 from dead code

---

### Phase 2: Define BurgessR3Maximal and Prove Existence [COMPLETED]

**Goal**: Define BurgessR3Maximal as the primary r-maximality concept using burgessR3, prove existence via Zorn's lemma with seed construction, update ChronicleInvariant c2' to use BurgessR3Maximal, and prove bridging lemmas.

**Tasks**:
- [x] Define `BurgessR3Maximal(A, B, C)` in RRelation.lean
- [x] Prove `BurgessR3Maximal_is_mcs`
- [x] Prove BurgessR3Maximal existence via seed + Zorn
- [x] Update ChronicleInvariant c2' to use BurgessR3Maximal
- [x] Prove `BurgessR3Maximal_implies_r3Relation` for backward compatibility
- [x] Update c2' pattern matches across codebase
- [x] Run lake build and verify

**Timing**: 5 hours (completed)

**Depends on**: Phase 1.5

**Files to modify**:
- `Chronicle/RRelation.lean`, `Chronicle/ChronicleTypes.lean`, `Chronicle/PointInsertion.lean`, `Chronicle/CounterexampleElimination.lean`

**Verification**:
- BurgessR3Maximal defined; existence proved; ChronicleInvariant c2' updated; lake build succeeds

---

### Phase 4A: Close C4/C4' Hard Sub-Case [COMPLETED]

**Goal**: Close the C4/C4' hard case sorry sites using burgessR3 contradiction + Lemma 2.6. Uses c2' input parameter (not rebuild_g).

**Tasks**:
- [x] Prove `burgessR3_gamma_not_in_B`: BurgessR3Maximal(A, B, C) -> untl(gamma, delta).neg in A -> delta in C -> gamma not in B
- [x] Handle gamma=top sub-case (trivially False via MCS inconsistency)
- [x] Apply Lemma 2.6 from "gamma not in g(x,y)" to produce splitting point
- [x] Close C4 hard case sorry site
- [x] Close C4' hard case sorry site (mirror)
- [x] Run lake build and verify

**Timing**: 3 hours (completed)

**Depends on**: Phase 2

**Files to modify**:
- `Chronicle/RRelation.lean` -- bridging lemma
- `Chronicle/CounterexampleElimination.lean` -- C4/C4' hard case closures

**Verification**:
- burgessR3_gamma_not_in_B proved sorry-free
- C4/C4' hard case sorry-free
- lake build succeeds

**Sorry-free lemmas preserved from prior sessions**:
- `burgessR3_gamma_not_in_B`, `untl_conj_guard`, `untl_left_mono_thm`, `untl_absorb_nested`, `dcs_neg_insert_consistent`, `c4_hard_case_G_neg_delta`, `snce_conj_guard`, `snce_left_mono_thm`

---

### Phase 3: Remove rebuild_g, Direct g-Construction in Elimination Functions [PARTIAL]

**Goal**: Delete all rebuild_g infrastructure and the false `burgessR3Maximal_exists_general`. Add `c2'` field to EliminationResult. Modify all 7 elimination functions to construct g-values for new adjacent pairs directly: C5/C5' via `burgessR3Maximal_exists_from_seed` with Lemma 2.4 eta, C4/C4'/density/g_prop/h_prop via `burgessR3_absorption` on existing g-values. Preserve g for old pairs. omega_chain returns `{chi // chi.c0 AND chi.c2'}` using EliminationResult.c2' directly (no rebuild_g wrapper).

**Tasks**:
- [ ] Delete from RRelation.lean: `burgessR3Maximal_exists_general` (false theorem at ~line 1348)
- [ ] Delete from ChronicleConstruction.lean: `rebuild_g`, `rebuild_g_c0`, `rebuild_g_f`, `rebuild_g_dom`, `rebuild_g_c2'`
- [ ] Delete from ChronicleConstruction.lean: `omega_chain_g_empty`, intersection-based `limit_g`, and all vacuous proofs (`limit_c2'_vacuous`, `limit_g_is_mcs_vacuous`, old `limit_g_eq`)
- [ ] Delete from ChronicleConstruction.lean: bridge lemmas (`omega_chain_elim_result`, `omega_chain_f_eq_elim`, `omega_chain_dom_eq_elim`) that depend on rebuild_g
- [ ] Add `c2'` field to EliminationResult in CounterexampleElimination.lean: for each new adjacent pair (a,b), carries proof of `BurgessR3Maximal(new_f(a), new_g(a,b), new_f(b))`
- [ ] Verify Lemma 2.4 output: inspect `lemma_2_4` to confirm it produces endpoint C with eta satisfying `burgessR(A, eta, C)` and `burgessRSince(C, eta, A)`. Strengthen return type if needed
- [ ] Modify C5 elimination: construct g(x_max, y) via `burgessR3Maximal_exists_from_seed(f(x_max), f(y), eta)` where eta comes from Lemma 2.4. Set g for old pairs to chi.g (preservation). Prove c2' for the new pair
- [ ] Modify C5' elimination: mirror of C5 using Since direction with `snce_conj_guard` and `snce_left_mono_thm`
- [ ] Modify C4 elimination: when Lemma 2.6 inserts z between x and y, split g(x,y) into g(x,z) + g(z,y) via `burgessR3_absorption`. Set g for old pairs to chi.g. Prove c2' for new pairs
- [ ] Modify C4' elimination: mirror of C4
- [ ] Modify density elimination: same splitting pattern as C4 via `burgessR3_absorption`
- [ ] Modify g_prop elimination: from g(x, x_next) via absorption
- [ ] Modify h_prop elimination: from g(z_prev, y) via absorption
- [ ] Update omega_chain step: remove rebuild_g wrapper. Return `{chi // chi.c0 AND chi.c2'}` using EliminationResult.c2' directly
- [ ] Update omega_chain_c0 and omega_chain_c2' extractors
- [ ] Fix compilation errors in witness lemmas (omega_chain_c5_witness, omega_chain_c4_witness, etc.) and limit_dom_dense
- [ ] Run lake build and verify (0 sorries from rebuild_g/false theorem path)

**Timing**: 4 hours

**Depends on**: 2, 4A

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- delete `burgessR3Maximal_exists_general`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- EliminationResult c2' field, all 7 elimination functions modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- delete rebuild_g and tainted infrastructure, update omega_chain step
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- possibly strengthen lemma_2_4 return type

**Verification**:
- `burgessR3Maximal_exists_general` deleted
- `rebuild_g` and all helpers deleted
- All 7 elimination functions set non-empty g-values for new adjacent pairs
- EliminationResult carries c2' proof
- omega_chain returns c0 AND c2' without rebuild_g
- g-preservation: old pairs keep chi.g
- lake build succeeds
- Sorry count: net reduction (delete false theorem sorry, delete vacuous proofs)

---

### Phase 4: Stage-Based limit_g with g-Immutability and C3 [NOT STARTED]

**Goal**: Revert limit_g to the stage-based definition. Prove g-immutability (old pairs preserved across stages). Prove C2', C3, and c3_interval_subset_point at the limit. Prove limit_satisfies_c4 from finite-stage C4 + immutability. This provides the foundation for FUC closure.

**Tasks**:
- [ ] Define limit_g(x,y) = (omega_chain_val N).g(x,y) where N = first stage with both x,y in domain
- [ ] Prove g-immutability lemma: for m >= n >= first_stage(x,y), `(omega_chain_val m).g x y = (omega_chain_val n).g x y`. Follows from Phase 3's g-preservation (each elimination sets g(a,b)=chi.g(a,b) for old pairs)
- [ ] Prove limit_g well-defined (`limit_g_eq`): the value does not depend on which stage >= first_stage is chosen
- [ ] Prove C2' at limit: `BurgessR3Maximal (limit_f x) (limit_g x y) (limit_f y)` for adjacent x,y. Reduce to C2' at finite stage N using f-immutability and g-immutability
- [ ] Prove limit_c3: `limit_g(x,z) = limit_g(x,y) inter limit_f(y) inter limit_g(y,z)` for x < y < z in limit_dom. Reduce to C3 at finite stage using immutability
- [ ] Prove `c3_interval_subset_point`: for x < y < z, `limit_g(x,z) subset limit_f(y)`. Immediate from limit_c3
- [ ] Prove `limit_g_is_mcs`: limit_g(x,y) is an MCS for adjacent x,y. From limit C2' + BurgessR3Maximal_is_mcs
- [ ] Prove limit_satisfies_c4: for any C4 counterexample at the limit, reduce to the finite stage where relevant points first appear. Phase 4A proves C4 at that finite stage; immutability carries the result to the limit
- [ ] Prove limit_forward_G follows from limit_satisfies_c4 (no circularity -- C4 proved at finite stages first)
- [ ] Verify cantor_bfmcs_restricted_buc resolves via limit_satisfies_c4
- [ ] Run lake build and verify

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- limit_g definition, g-immutability, limit_g_eq, limit C2', limit_c3, c3_interval_subset_point, limit_g_is_mcs, limit_satisfies_c4, limit_forward_G

**Verification**:
- limit_g defined as stage-based (not intersection)
- g-immutability proved sorry-free
- limit C2' (BurgessR3Maximal) proved sorry-free
- limit_c3 proved sorry-free
- c3_interval_subset_point proved sorry-free
- limit_g_is_mcs proved sorry-free
- limit_satisfies_c4 sorry-free
- limit_forward_G sorry-free
- lake build succeeds

---

### Phase 5: Close FUC and Final Validation [NOT STARTED]

**Goal**: Close the 2 restricted_fuc sorry sites (ChronicleToCountermodel.lean lines 615, 619) using until_guard + C5 seed construction + C3 interval containment. Verify sorry-free dd_countermodel_chronicle. Clean up dead code.

**Tasks**:
- [ ] Close restricted_fuc Until (line 615):
  - Given `untl(gamma,delta) in f(t)`, use `until_guard_in_mcs` to get `gamma in f(t)` (base point)
  - Use C5 construction to get endpoint s > t with delta in f(s)
  - Show gamma in limit_g(t,s): C5 elimination produces g(t,s) via `burgessR3Maximal_exists_from_seed` with eta from Lemma 2.4. The guard gamma enters through the seed (Lemma 2.4 constructs C so that burgessR(f(t), gamma, f(s)) holds). Since gamma is in the seed's deductive closure, gamma is in the resulting BurgessR3Maximal g(t,s). By g-immutability, gamma in limit_g(t,s)
  - For intermediate r with t < r < s: by c3_interval_subset_point, limit_g(t,s) subset limit_f(r), so gamma in f(r)
  - Transfer through Cantor isomorphism to the dense countermodel
- [ ] Close restricted_fuc Since (line 619): mirror using since_guard + C5' + backward interval
- [ ] Verify limit_satisfies_c4 and limit_forward_G are sorry-free (should be from Phase 4)
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify only Lean axioms (propfunext, Quot.sound, Classical.choice) -- no sorryAx
- [ ] Verify zero sorry sites in Chronicle/ directory: `grep -r "sorry" Chronicle/` finds only comments
- [ ] Clean up dead comments, scaffolding from prior plan versions
- [ ] Remove unused helper functions and placeholder limit_g artifacts
- [ ] Full lake build verification (clean build)
- [ ] Verify Soundness, FMP, ParametricTruthLemma remain sorry-free
- [ ] Run `#print axioms` on key downstream theorems

**Timing**: 3 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- restricted_fuc Until/Since proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- cleanup of unused helpers
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- cleanup

**Verification**:
- restricted_fuc Until sorry-free (line ~615 closed)
- restricted_fuc Since sorry-free (line ~619 closed)
- `#print axioms dd_countermodel_chronicle` shows NO sorryAx
- Zero sorry sites in Chronicle/ directory
- lake build succeeds (full clean build)
- Soundness, FMP, ParametricTruthLemma remain sorry-free

## Testing & Validation

- [x] Phase 1: until_guard/since_guard axioms added; Soundness.lean sorry-free; MCS-level lemmas compile (COMPLETED)
- [x] Phase 1.5: Cruft deleted; chronicle_fmcs/chronicle_bfmcs removed; lake build passes (COMPLETED)
- [x] Phase 2: BurgessR3Maximal defined and proved; ChronicleInvariant c2' updated; lake build passes (COMPLETED)
- [x] Phase 4A: burgessR3_gamma_not_in_B sorry-free; C4/C4' hard sub-case sorry-free (COMPLETED)
- [ ] Phase 3: rebuild_g deleted; burgessR3Maximal_exists_general deleted; all 7 elimination functions produce BurgessR3Maximal g-values; EliminationResult carries c2'; lake build passes
- [ ] Phase 4: g-immutability, limit_g stage-based, limit C2', limit_c3, c3_interval_subset_point, limit_satisfies_c4 all sorry-free; lake build passes
- [ ] Phase 5: restricted_fuc sorry-free (-2 sorry sites); `#print axioms dd_countermodel_chronicle` clean; zero sorry in Chronicle/
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] lake build succeeds at each phase boundary

## Artifacts & Outputs

- `specs/107_.../plans/33_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean` (until_guard, since_guard) -- Phase 1 DONE
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (soundness cases) -- Phase 1 DONE
- Modified: `Chronicle/ChronicleTypes.lean` (c2' BurgessR3Maximal) -- Phase 2 DONE
- Modified: `Chronicle/RRelation.lean` (BurgessR3Maximal, existence, burgessR3Maximal_exists_from_seed, guard algebra, bridging lemma; DELETE burgessR3Maximal_exists_general)
- Modified: `Chronicle/CounterexampleElimination.lean` (EliminationResult c2' field, all 7 elimination functions, C4 hard case)
- Modified: `Chronicle/ChronicleConstruction.lean` (DELETE rebuild_g + tainted infra; g-immutability, stage-based limit_g, limit_c3, limit_satisfies_c4, singleton_chronicle g)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (restricted_fuc closure)
- Modified: `Chronicle/PointInsertion.lean` (possibly strengthen lemma_2_4 return type)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 3 contingency (Lemma 2.4 eta)**: If Lemma 2.4 does not expose eta in its current return type, strengthen the return type to carry the burgessR witness. Non-breaking change (adds information).
- **Phase 3 contingency (compilation cascade)**: Phase 3 is explicitly a "break then fix" phase. Delete tainted code first, then fix compilation errors systematically file by file. Expect ~8-10 compilation errors from deleted definitions.
- **Phase 3 contingency (EliminationResult c2')**: If extending EliminationResult proves too disruptive, carry c2' proofs in a separate side-channel structure parallel to the Chronicle.
- **Phase 3 contingency (burgessR3_absorption)**: If sub-interval inheritance is hard, factor into standalone lemma with explicit proof from subset + anti-monotonicity.
- **Phase 4 contingency (g-immutability)**: If g-immutability is hard to establish for all elimination types simultaneously, prove it per-elimination-type and combine.
- **Phase 5 contingency (C5-with-guard)**: If C5 does not thread the guard witness through to limit_g, strengthen C5 EliminationResult to carry gamma in g(t,s) explicitly.
- **Budget overrun**: Phases are sequential so partial progress is always meaningful. Each phase reduces sorry count independently.

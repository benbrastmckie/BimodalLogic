# Implementation Plan: Task #107 (v19 -- Context-Specific Seed via Lemma 2.4)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 12 hours (remaining)
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/28_team-research.md], [reports/29_team-research.md], [reports/30_team-research.md], [reports/31_team-research.md], [reports/32_team-research.md], [handoffs/31_implementation-handoff.md], [handoffs/32_phase3-implementation-handoff.md]
- **Artifacts**: plans/32_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Round 32 team research (4 teammates, unanimous) resolved the Phase 3 seed construction blocker. The key insight: Burgess never constructs a general seed. Every BurgessR3Maximal interval set arises from either (a) Lemma 2.4, where endpoint C is purpose-built so `burgessR(A, eta, C)` holds by construction, or (b) Lemma 2.6 splitting, where the existing g(x,y) serves as the seed via `burgessR3_absorption`. The general `burgessR3Maximal_exists` sorry should be deleted and replaced with `burgessR3Maximal_exists_from_seed(A, C, eta, h_burgessR, h_burgessRSince)`, seeded from `deductiveClosure({eta})`. Guard algebra lemmas (BX2 + BX7) proved sorry-free in the prior session ensure the DCS closure preserves burgessR3.

This revision restructures Phase 3 around the context-specific seed, preserving all completed work (Phases 1, 1.5, 2) and the parallel workstream architecture from v18 (Workstreams A and B). The prior session's completed work -- guard algebra lemmas and correct limit_g definition -- is preserved in Phase 3 as [PARTIAL].

### Research Integration

- Reports 28-30 (prior rounds): Established BurgessR3Maximal as primary relation, cruft purge, existence proof. Integrated in plan v17.
- Report 31 (team research, 4 teammates): Confirmed two independent workstreams. g(x,y) does NOT need to be MCS. gamma=top sub-case is trivially False. Seed problem confined to C5 elimination. Integrated in plan v18.
- **Report 32 (team research, 4 teammates)**: Primary input for this revision. Burgess never needs general seed. Lemma 2.4 provides eta for C5. `deductiveClosure({eta})` is DCS seed. C4 splitting uses existing g via `burgessR3_absorption`. Guard algebra (BX7 + BX2) preserves burgessR3 under deductive closure.
- **Handoff 32 (Phase 3 implementation)**: Guard algebra lemmas (untl_conj_guard, snce_conj_guard, untl_left_mono_thm, snce_left_mono_thm) proved sorry-free. Correct limit_g defined. burgessR3Maximal_exists added with sorry -- this sorry is the target for deletion.

### Prior Plan Reference

Plan v18 (artifact 31): Phases 1, 1.5, 2 [COMPLETED]. Phase 3 [PARTIAL] (guard algebra + correct limit_g done, seed sorry remains). Phases 4A, 4B, 5A, 5B, 6 [NOT STARTED]. This revision replaces Phase 3 with a focused seed-based approach and carries forward all other phases with minor adjustments.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing the final 4 sorry sites + deleting the new seed sorry achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Delete the general `burgessR3Maximal_exists` sorry in RRelation.lean
- Prove `burgessR3Maximal_exists_from_seed`: given eta with burgessR(A, eta, C) and burgessRSince(C, eta, A), construct BurgessR3Maximal via deductiveClosure({eta}) + Zorn
- Verify Lemma 2.4 provides the eta satisfying burgessR(A, eta, C) for C5 elimination
- Thread the context-specific seed through C5 elimination to produce BurgessR3Maximal g-values
- C4 g-population via burgessR3_absorption (no new seed needed)
- Populate g-values in density/g_prop/h_prop elimination via burgessR3_absorption
- Close C4 hard sub-case: gamma=top trivially False; gamma not top via burgessR3_gamma_not_in_B + Lemma 2.6
- Prove g-immutability and define limit_g with C3 at the limit
- Implement C5-with-guard: phi at intermediate points via C3 interval containment
- Close restricted_fuc: until_guard for base, C5-with-guard for endpoint, C3 for intermediates
- Achieve sorry-free dd_countermodel_chronicle
- Maintain lake build at each phase boundary

**Non-Goals**:
- Adding density axioms (GG->G, HH->H) -- debunked, wrong for BX
- Using limit_forward_G to close C4 (circular dependency)
- Proving R3Maximal implies burgessR3 (false in general)
- Bypassing finite-stage C4 proof -- follow Burgess's architecture exactly
- Requiring g(x,y) to be MCS before applying Lemma 2.6 (Lemma 2.6 works from non-membership directly)
- C5 n>0 case (insert between existing points) -- current construction avoids it
- BXCanonical sorry closure (task 109)
- Deleting rRelation or R3Maximal -- existing sorry-free code uses them
- Keeping the general `burgessR3Maximal_exists` -- it asks for something Burgess never needs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 2.4 does not expose eta satisfying burgessR(A, eta, C) in current codebase formalization | H | M | Inspect lemma_2_4 output. If C is constructed via Lindenbaum from a set containing S(alpha, beta), then beta satisfies burgessR. May need to strengthen lemma_2_4 return type to carry the witness. |
| deductiveClosure({eta}) burgessR3 proof requires induction on derivation trees | M | M | Guard algebra lemmas (untl_conj_guard, untl_left_mono_thm) already proved sorry-free. The induction follows standard DCS closure pattern: base case (eta satisfies burgessR3 by hypothesis), conjunction (BX7), implication (BX2). |
| burgessR3_absorption (sub-interval inheritance) is non-trivial | M | M | The argument is: if g(x,y) satisfies burgessR3(f(x), g(x,y), f(y)) and Lemma 2.6 splits into D, then the sub-intervals inherit burgessR3 from the parent. This follows from subset + anti-monotonicity. |
| C5-with-guard requires threading phi through limit_g to intermediate f-values | M | M | c3_interval_subset_point gives limit_g(t,s) subset limit_f(r) for t < r < s. If phi in limit_g(t,s), then phi in limit_f(r). |
| Parallel workstream coordination: shared Phase 3 artifacts | M | L | Phase 3 is a shared prerequisite. Both workstreams read its outputs but modify different files. No write conflicts. |
| gamma=top edge case handling in Lean | L | L | gamma=top makes burgessR3 condition produce untl(top, delta) = F(delta) in f(x), contradicting neg(F(delta)) in f(x). Standard MCS inconsistency gives False. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 1.5, 2 | -- (completed) |
| 1 | 3 | 2 (completed) |
| 2 | 4A, 4B | 3 |
| 3 | 5A, 5B | 4A, 4B respectively |
| 4 | 6 | 5A, 5B |

Phases within the same wave can execute in parallel. Workstream A = phases 4A, 5A. Workstream B = phases 4B, 5B. These are independent and designed for `--team` execution in Wave 2 and Wave 3.

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

**Goal**: Remove dead code, failed approaches, and stale artifacts before the architectural changes. Clean slate for BurgessR3 adoption.

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

**Goal**: Define BurgessR3Maximal as the primary r-maximality concept using burgessR3, prove existence via Zorn's lemma with seed construction, update ChronicleInvariant c2' to use BurgessR3Maximal, and prove bridging lemmas for backward compatibility.

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

### Phase 3: Populate g-values via Context-Specific Seeds [PARTIAL]

**Goal**: Every elimination function produces BurgessR3Maximal g-values for adjacent pairs. Delete the general `burgessR3Maximal_exists` sorry. For C5, use Lemma 2.4's eta as seed via `burgessR3Maximal_exists_from_seed`. For C4/density/g_prop/h_prop, use `burgessR3_absorption` on existing g-values. After this phase, g-values are non-empty and satisfy burgessR3 at every finite stage with zero sorry sites in the seed path.

**Completed work** (from prior session):
- [x] Guard algebra lemmas proved sorry-free: `untl_conj_guard`, `snce_conj_guard`, `untl_left_mono_thm`, `snce_left_mono_thm` (RRelation.lean)
- [x] Correct `limit_g` definition: `limit_g(x, y) = g_n(x, y)` for first n where both x, y in domain (ChronicleConstruction.lean)
- [x] `limit_g_eq` theorem proving well-definedness (ChronicleConstruction.lean)

**Remaining tasks**:
- [x] Prove `burgessR3Maximal_exists_from_seed`: given `(A C : Set Formula) (eta : Formula) (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C) (h_burgessR : burgessR A eta C) (h_burgessRSince : burgessRSince C eta A)`, construct `deductiveClosure({eta})` as seed DCS satisfying burgessR3, then apply Zorn extension to produce `BurgessR3Maximal A B C`. Proof uses deduction theorem: phi in DC({eta}) gives [] |- eta -> phi, then BX2 (untl_left_mono_thm) propagates burgessR
- [ ] Verify Lemma 2.4 output: inspect `lemma_2_4` to confirm it produces endpoint C with eta satisfying `burgessR(A, eta, C)` and `burgessRSince(C, eta, A)`. If the return type does not expose these witnesses, strengthen it to carry them
- [ ] Thread seed through C5 elimination: call `burgessR3Maximal_exists_from_seed` with the eta from Lemma 2.4 to produce g-values for the new endpoint pair
- [ ] C5' elimination: mirror of C5 using Since direction with `snce_conj_guard` and `snce_left_mono_thm`
- [ ] C4 elimination g-population: when Lemma 2.6 splits g(x,y) into sub-intervals for new point z, use `burgessR3_absorption` to prove sub-intervals inherit burgessR3. Set g(x,z) and g(z,y) from the split. No new seed needed
- [ ] C4' elimination: mirror of C4
- [ ] Density/g_prop/h_prop elimination: use `burgessR3_absorption` for sub-interval g-values
- [ ] Prove g-preservation: for pairs (a,b) already in domain, new_chi.g(a,b) = chi.g(a,b)
- [ ] Prove g-agreement: all new g-values satisfy BurgessR3Maximal
- [x] Delete general `burgessR3Maximal_exists` sorry from RRelation.lean
- [x] Run lake build and verify (0 sorries in RRelation.lean, 4 in Chronicle/ total)

**Timing**: 3 hours (reduced from 4; guard algebra and limit_g already done)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- `burgessR3Maximal_exists_from_seed`, delete `burgessR3Maximal_exists`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- EliminationResult extension, C5/C5'/C4/C4'/density/g_prop/h_prop g-population
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- call sites, singleton_chronicle g
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- Lemma 2.6 with burgessR3_absorption, possibly strengthen lemma_2_4 return type

**Verification**:
- `burgessR3Maximal_exists_from_seed` proved sorry-free
- General `burgessR3Maximal_exists` deleted (sorry removed)
- All elimination functions set non-empty g-values using context-specific seeds
- g-agreement and g-preservation proved for all cases
- singleton_chronicle has proper g-construction (no sorry)
- lake build succeeds
- Sorry count: -1 (deletion of burgessR3Maximal_exists sorry)

---

### Phase 4A: Close C4/C4' Hard Sub-Case (Workstream A) [COMPLETED]

**Goal**: Close the 2 sorry sites at CounterexampleElimination.lean (C4 hard case lines 332, 448) using burgessR3 contradiction + Lemma 2.6. This is the finite-stage C4 proof per Burgess's architecture.

**Tasks**:
- [ ] Handle gamma=top sub-case: burgessR3(f(x), g(x,y), f(y)) with top in g(x,y) forces untl(top, delta) = F(delta) in f(x). But neg(F(delta)) = G(neg(delta)) in f(x) from C4 counterexample. MCS inconsistency gives False. Split this out as a trivial discharge (confirmed trivially False by rounds 31+32)
- [ ] Prove burgessR3 bridging lemma (RRelation.lean): `BurgessR3Maximal(A, B, C) -> untl(gamma, delta).neg in A -> delta in C -> gamma not in B`. Proof: assume gamma in B; by burgessRSet definition, untl(gamma, delta) in A; contradiction with neg in A via MCS consistency
- [ ] Prove dual: `BurgessR3Maximal(A, B, C) -> snce(gamma, delta).neg in C -> delta in A -> gamma not in B`
- [ ] Apply Lemma 2.6 directly from "gamma not in g(x,y)" (no MCS requirement on g(x,y) needed). Lemma 2.6 takes BurgessR3Maximal(f(x), g(x,y), f(y)) and produces D with gamma.neg in D, splitting the interval
- [ ] At C4 sorry site (line 332): combine gamma=top discharge + burgessR3 bridging + Lemma 2.6 to produce the C4 witness point z with f(z) = D containing gamma.neg
- [ ] At C4' sorry site (line 448): mirror using Since + dual bridging lemma
- [ ] Remove any unnecessary G(gamma)/H(gamma) case-split scaffolding
- [ ] Run lake build and verify

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- burgessR3 bridging lemma + dual
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C4/C4' hard sub-case closures

**Verification**:
- burgessR3 bridging lemma proved sorry-free
- C4 hard sub-case sorry-free (line ~332 closed)
- C4' hard sub-case sorry-free (line ~448 closed)
- lake build succeeds
- Sorry count reduction: -2

---

### Phase 4B: Prove g-Immutability and Define limit_g with C3 (Workstream B, Part 1) [COMPLETED]

**Goal**: Prove g-values are immutable once set, define limit_g as the stable finite-stage value, and prove C2' (BurgessR3Maximal) and C3 at the limit. This is the foundation for FUC closure.

**Note**: The correct `limit_g` definition was already implemented in the Phase 3 session. This phase focuses on the immutability proof, C2', C3, and downstream properties that depend on Phase 3's g-population being complete.

**Tasks**:
- [ ] Prove g-immutability lemma: for m >= n >= first_stage(x,y), `(omega_chain_val m).g x y = (omega_chain_val n).g x y`. Follows from Phase 3's g-preservation proof
- [ ] Verify existing `limit_g` definition and `limit_g_eq` are sufficient, or extend as needed
- [ ] Prove C2' at limit: `BurgessR3Maximal (limit_f x) (limit_g x y) (limit_f y)` for adjacent x,y. Reduce to C2' at finite stage N using f-immutability and g-immutability
- [ ] Prove limit_c3: `limit_g(x,z) = limit_g(x,y) inter limit_f(y) inter limit_g(y,z)` for x < y < z in limit_dom. Reduce to C3 at finite stage using immutability
- [ ] Prove `c3_interval_subset_point`: for x < y < z, `limit_g(x,z) subset limit_f(y)`. Immediate from limit_c3
- [ ] Prove `limit_g_is_mcs`: limit_g(x,y) is an MCS for adjacent x,y. From limit C2' + BurgessR3Maximal_is_mcs
- [ ] Run lake build and verify

**Timing**: 2 hours (reduced from 3; limit_g definition already done)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- g-immutability, limit C2', limit_c3, c3_interval_subset_point, limit_g_is_mcs

**Verification**:
- g-immutability proved sorry-free
- limit_g verified or extended as needed
- limit C2' (BurgessR3Maximal) proved sorry-free
- limit_c3 proved sorry-free
- c3_interval_subset_point proved sorry-free
- limit_g_is_mcs proved sorry-free
- lake build succeeds

---

### Phase 5A: Validate C4 at Limit (Workstream A, Part 2) [NOT STARTED]

**Goal**: Confirm that finite-stage C4 (from Phase 4A) carries over to the limit via immutability. This completes Workstream A.

**Tasks**:
- [ ] Prove limit_satisfies_c4: for any C4 counterexample at the limit, reduce to the finite stage where the relevant points first appear. Phase 4A proves C4 at that finite stage; immutability carries the result to the limit
- [ ] Prove limit_forward_G follows from limit_satisfies_c4 (no circularity -- C4 proved at finite stages first)
- [ ] Verify that cantor_bfmcs_restricted_buc (line 525) now resolves via limit_satisfies_c4
- [ ] Run lake build and verify

**Timing**: 1 hour

**Depends on**: 4A

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- limit_satisfies_c4, limit_forward_G

**Verification**:
- limit_satisfies_c4 sorry-free
- limit_forward_G sorry-free
- lake build succeeds

---

### Phase 5B: Close restricted_fuc (Workstream B, Part 2) [BLOCKED]

**Goal**: Close the 2 restricted_fuc sorry sites (lines 615, 619) using until_guard + C5-with-guard + C3 interval containment.

**Tasks**:
- [ ] Close restricted_fuc Until (ChronicleToCountermodel.lean, line 615):
  - Given `untl(gamma,delta) in f(t)`, use `until_guard_in_mcs` (Phase 1) to get `gamma in f(t)` (base point)
  - Use C5 construction to get endpoint s > t with delta in f(s)
  - Prove gamma in limit_g(t,s): the C5 elimination produces g(t,s) via `burgessR3Maximal_exists_from_seed` with eta from Lemma 2.4. The guard gamma enters through the seed -- Lemma 2.4 constructs C so that S(alpha, gamma) in C for the appropriate alpha, giving burgessR(f(t), gamma, f(s)). Since gamma is in the seed's deductive closure, gamma is in the resulting BurgessR3Maximal g(t,s)
  - For intermediate r with t < r < s: by c3_interval_subset_point (Phase 4B), limit_g(t,s) subset limit_f(r), so gamma in f(r)
  - Transfer through Cantor isomorphism to the dense countermodel
- [ ] Close restricted_fuc Since (ChronicleToCountermodel.lean, line 619): mirror using since_guard + C5' + backward interval
- [ ] Remove placeholder limit_g artifacts and unused helper functions
- [ ] Run lake build and verify

**Timing**: 2 hours

**Depends on**: 4B

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- restricted_fuc Until/Since proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- cleanup of unused helpers

**Verification**:
- restricted_fuc Until sorry-free (line ~615 closed)
- restricted_fuc Since sorry-free (line ~619 closed)
- lake build succeeds
- Sorry count reduction: -2

---

### Phase 6: Final Validation and Cleanup [NOT STARTED]

**Goal**: Verify sorry-free dd_countermodel_chronicle, clean up dead code, and run full validation.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify only Lean axioms (propfunext, Quot.sound, Classical.choice) -- no sorryAx
- [ ] Verify zero sorry sites in Chronicle/ directory: `grep -r "sorry" Chronicle/` finds only comments
- [ ] Clean up Adjacent-related dead comments
- [ ] Remove any remaining scaffolding from prior plan versions
- [ ] Full lake build verification (clean build)
- [ ] Verify Soundness, FMP, ParametricTruthLemma remain sorry-free
- [ ] Run `#print axioms` on key downstream theorems

**Timing**: 1 hour

**Depends on**: 5A, 5B

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- cleanup

**Verification**:
- `#print axioms dd_countermodel_chronicle` shows NO sorryAx
- Zero sorry sites in Chronicle/ directory
- lake build succeeds (full clean build)
- Soundness, FMP, ParametricTruthLemma remain sorry-free
- Total sorry count reduction: -5 (4 active sorry sites + 1 seed sorry)

## Testing & Validation

- [x] Phase 1: until_guard/since_guard axioms added; Soundness.lean sorry-free; MCS-level lemmas compile (COMPLETED)
- [x] Phase 1.5: Cruft deleted; chronicle_fmcs/chronicle_bfmcs removed; lake build passes (COMPLETED)
- [x] Phase 2: BurgessR3Maximal defined and proved; ChronicleInvariant c2' updated; lake build passes (COMPLETED)
- [ ] Phase 3: burgessR3Maximal_exists_from_seed sorry-free; general burgessR3Maximal_exists deleted; all elimination functions produce BurgessR3Maximal g-values; lake build passes
- [ ] Phase 4A: burgessR3 bridging lemma sorry-free; C4/C4' hard sub-case sorry-free (-2 sorry sites)
- [ ] Phase 4B: g-immutability, limit C2', limit_c3, c3_interval_subset_point all sorry-free
- [ ] Phase 5A: limit_satisfies_c4 sorry-free; limit_forward_G sorry-free
- [ ] Phase 5B: restricted_fuc sorry-free (-2 sorry sites)
- [ ] Phase 6: `#print axioms dd_countermodel_chronicle` clean; zero sorry in Chronicle/
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] lake build succeeds at each phase boundary

## Artifacts & Outputs

- `specs/107_.../plans/32_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean` (until_guard, since_guard) -- Phase 1 DONE
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (soundness cases) -- Phase 1 DONE
- Modified: `Chronicle/ChronicleTypes.lean` (c2' BurgessR3Maximal) -- Phase 2 DONE
- Modified: `Chronicle/RRelation.lean` (BurgessR3Maximal, existence, burgessR3Maximal_exists_from_seed, guard algebra, bridging lemma)
- Modified: `Chronicle/CounterexampleElimination.lean` (EliminationResult, g-population, C4 hard case)
- Modified: `Chronicle/ChronicleConstruction.lean` (g-immutability, limit_g, limit_c3, limit_satisfies_c4, singleton_chronicle g)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (restricted_fuc closure)
- Modified: `Chronicle/PointInsertion.lean` (Lemma 2.6 burgessR3_absorption, possibly strengthen lemma_2_4)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 3 contingency (seed from Lemma 2.4)**: If Lemma 2.4 does not expose eta in its current return type, strengthen the return type to carry the burgessR witness. This is a non-breaking change since it adds information.
- **Phase 3 contingency (deductiveClosure burgessR3)**: If induction on deductive closure membership is complex, factor into a standalone lemma `dcs_singleton_burgessR3` that can be unit-tested independently.
- **Phase 3 contingency (g-population scope)**: If extending EliminationResult proves too disruptive, carry g-values in a separate side-channel structure parallel to the Chronicle.
- **Phase 4A contingency (bridging lemma)**: The burgessR3 bridging lemma is definitional (directly from burgessRSet). If Lean formalization has guard/event argument swap, write the wrapper accounting for notation.
- **Phase 4A contingency (Lemma 2.6)**: If adapting lemma_2_6_full to work without MCS requires changes, implement the splitting construction from scratch using maximality failure witness.
- **Phase 4B contingency (limit_g)**: If g-immutability is hard to establish for all elimination types simultaneously, prove it per-elimination-type and combine.
- **Phase 5B contingency (C5-with-guard)**: If C5 does not thread the guard witness through to limit_g, strengthen C5 EliminationResult to carry gamma in g(t,s) explicitly.
- **Workstream independence**: If one workstream completes but the other stalls, ship the completed workstream's sorry closures independently. Each closes 2 of 4 sorry sites.
- **Budget overrun**: Phases 5A and 5B are independent. Either can ship without the other.

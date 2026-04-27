# Implementation Plan: Task #107 (v18 -- Parallel Workstreams for C4 + FUC)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 14 hours (remaining)
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/28_team-research.md], [reports/29_team-research.md], [reports/30_team-research.md], [reports/31_team-research.md], [handoffs/31_implementation-handoff.md]
- **Artifacts**: plans/31_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Round 31 team research (4 teammates, unanimous) confirmed the 4 sorry sites split into TWO INDEPENDENT workstreams that can execute in parallel. Workstream A closes C4 hard case (lines 332, 448) via burgessR3_gamma_not_in_B + Lemma 2.6 at finite stages, requiring populated g-values from burgessR3Maximal. Workstream B closes FUC (lines 615, 619) via C5-with-guard + C3, requiring limit_g from populated g-values. Both workstreams share a common prerequisite: populating g-values in elimination functions (Phase 3). This revision restructures the old monolithic Phase 3 into focused sub-phases and splits the downstream work into parallel workstreams designed for `--team` execution.

### Research Integration

- Reports 28-30 (prior rounds): Established BurgessR3Maximal as primary relation, cruft purge, existence proof. Integrated in plan v17.
- Report 31 (team research, 4 teammates): **Primary input for this revision.** Confirmed two independent workstreams. g(x,y) does NOT need to be MCS -- Lemma 2.6 works directly from non-membership. gamma=top sub-case is trivially False. Seed problem confined to C5 elimination; burgessR3_absorption handles C4 splitting. FUC needs C5-with-guard, not C4.
- Handoff 31 (implementation analysis): Mapped full dependency chain. Confirmed limit_forward_G IS circular. Identified seed construction as Phase 3 blocker. Proposed kernel set K approach.

### Prior Plan Reference

Plan v17 (artifact 30): 6-phase structure. Phases 1, 1.5, 2 [COMPLETED]. Phase 3 [BLOCKED] (monolithic g-population across all elimination functions). Phases 4-6 [NOT STARTED] (sequential). This revision replaces Phases 3-6 with a focused structure: shared g-population prerequisite, then parallel workstreams A (C4) and B (FUC), then final validation.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing the final 4 sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Populate g-values in C5/C5' elimination using kernel set K + burgessR3Maximal_extension_exists
- Populate g-values in C4/C4' elimination using burgessR3_absorption (Lemma 2.6 sub-interval inheritance)
- Populate g-values in density/g_prop/h_prop elimination using burgessR3_absorption
- Prove g-preservation for existing pairs across all elimination functions
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

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Kernel set K empty for some MCS pairs in C5 seed | H | M | Empty K vacuously satisfies burgessR3. Start Zorn/Lindenbaum from empty DCS (set of theorems). The anti-monotone property means smaller sets are easier to satisfy. |
| burgessR3_absorption (sub-interval inheritance) is non-trivial | M | M | The argument is: if g(x,y) satisfies burgessR3(f(x), g(x,y), f(y)) and Lemma 2.6 splits into D, then the sub-intervals inherit burgessR3 from the parent. This follows from subset + anti-monotonicity. |
| C5-with-guard requires threading phi through limit_g to intermediate f-values | M | M | c3_interval_subset_point gives limit_g(t,s) subset limit_f(r) for t < r < s. If phi in limit_g(t,s), then phi in limit_f(r). The key is ensuring C5 produces phi in limit_g(t,s), not just phi in f(s). |
| Parallel workstream coordination: shared Phase 3 artifacts | M | L | Phase 3 is a shared prerequisite. Both workstreams read its outputs but modify different files (CounterexampleElimination.lean vs ChronicleToCountermodel.lean). No write conflicts. |
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

### Phase 3: Populate g-values in All Elimination Functions [PARTIAL]

**Goal**: Every elimination function produces BurgessR3Maximal g-values for adjacent pairs. This is the shared prerequisite for both parallel workstreams. After this phase, g-values are non-empty and satisfy burgessR3 at every finite stage.

**Tasks**:
- [ ] Extend EliminationResult with g-agreement field carrying BurgessR3Maximal for adjacent pairs in the new domain
- [ ] Implement singleton_chronicle g-construction: for singleton {x} no adjacent pairs; for first extension to {x, y} use BurgessR3Maximal existence
- [ ] C5 elimination seed construction: define kernel set K = {beta : for all gamma in C, untl(beta,gamma) in A AND for all alpha in A, snce(beta,alpha) in C}. If K non-empty, K is DCS (via BX7 + BX2). If K empty, use deductiveClosure({}) which vacuously satisfies burgessR3. Apply burgessR3Maximal_extension_exists from the seed
- [ ] C5' elimination: mirror of C5 using Since
- [ ] C4 elimination g-population: when Lemma 2.6 splits g(x,y) into sub-intervals for new point z, use burgessR3_absorption to prove sub-intervals inherit burgessR3. Set g(x,z) and g(z,y) from the split
- [ ] C4' elimination: mirror of C4
- [ ] Density/g_prop/h_prop elimination: use burgessR3_absorption for sub-interval g-values
- [ ] Prove g-preservation: for pairs (a,b) already in domain, new_chi.g(a,b) = chi.g(a,b)
- [ ] Prove g-agreement: all new g-values satisfy BurgessR3Maximal
- [ ] Run lake build and verify

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- EliminationResult extension, all elimination functions
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- call sites, singleton_chronicle g
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- Lemma 2.6 with burgessR3_absorption

**Verification**:
- EliminationResult has g-agreement field using BurgessR3Maximal
- All elimination functions set non-empty g-values
- g-agreement and g-preservation proved for all cases
- singleton_chronicle has proper g-construction (no sorry)
- lake build succeeds

---

### Phase 4A: Close C4/C4' Hard Sub-Case (Workstream A) [NOT STARTED]

**Goal**: Close the 2 sorry sites at CounterexampleElimination.lean (C4 hard case lines 332, 448) using burgessR3 contradiction + Lemma 2.6. This is the finite-stage C4 proof per Burgess's architecture.

**Tasks**:
- [ ] Handle gamma=top sub-case: burgessR3(f(x), g(x,y), f(y)) with top in g(x,y) forces untl(top, delta) = F(delta) in f(x). But neg(F(delta)) = G(neg(delta)) in f(x) from C4 counterexample. MCS inconsistency gives False. Split this out as a trivial discharge
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

### Phase 4B: Prove g-Immutability and Define limit_g with C3 (Workstream B, Part 1) [NOT STARTED]

**Goal**: Prove g-values are immutable once set, define limit_g as the stable finite-stage value, and prove C2' (BurgessR3Maximal) and C3 at the limit. This is the foundation for FUC closure.

**Tasks**:
- [ ] Prove g-immutability lemma: for m >= n >= first_stage(x,y), `(omega_chain_val m).g x y = (omega_chain_val n).g x y`. Follows from Phase 3's g-preservation proof
- [ ] Define `limit_g(x,y) = (omega_chain_val N).g x y` where N is the first stage with both x and y in the domain. Use `Nat.find` with decidability
- [ ] Prove limit_g is well-defined: for any x,y in limit_dom, the required N exists
- [ ] Prove C2' at limit: `BurgessR3Maximal (limit_f x) (limit_g x y) (limit_f y)` for adjacent x,y. Reduce to C2' at finite stage N using f-immutability and g-immutability
- [ ] Prove limit_c3: `limit_g(x,z) = limit_g(x,y) inter limit_f(y) inter limit_g(y,z)` for x < y < z in limit_dom. Reduce to C3 at finite stage using immutability
- [ ] Prove `c3_interval_subset_point`: for x < y < z, `limit_g(x,z) subset limit_f(y)`. Immediate from limit_c3
- [ ] Prove `limit_g_is_mcs`: limit_g(x,y) is an MCS for adjacent x,y. From limit C2' + BurgessR3Maximal_is_mcs
- [ ] Run lake build and verify

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- g-immutability, limit_g definition, limit_c3, c3_interval_subset_point

**Verification**:
- g-immutability proved sorry-free
- limit_g defined using Nat.find
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

### Phase 5B: Close restricted_fuc (Workstream B, Part 2) [NOT STARTED]

**Goal**: Close the 2 restricted_fuc sorry sites (lines 615, 619) using until_guard + C5-with-guard + C3 interval containment.

**Tasks**:
- [ ] Close restricted_fuc Until (ChronicleToCountermodel.lean, line 615):
  - Given `untl(gamma,delta) in f(t)`, use `until_guard_in_mcs` (Phase 1) to get `gamma in f(t)` (base point)
  - Use C5 construction to get endpoint s > t with delta in f(s)
  - Prove gamma in limit_g(t,s): the C5 elimination produces g(t,s) via burgessR3Maximal with gamma in the kernel set (gamma is a guard of the Until formula)
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
- Total sorry count reduction: -4 (active sites) + -8 (dead code from Phase 1.5) = -12

## Testing & Validation

- [x] Phase 1: until_guard/since_guard axioms added; Soundness.lean sorry-free; MCS-level lemmas compile (COMPLETED)
- [x] Phase 1.5: Cruft deleted; chronicle_fmcs/chronicle_bfmcs removed; lake build passes (COMPLETED)
- [x] Phase 2: BurgessR3Maximal defined and proved; ChronicleInvariant c2' updated; lake build passes (COMPLETED)
- [ ] Phase 3: All elimination functions produce BurgessR3Maximal g-values; g-preservation proved; lake build passes
- [ ] Phase 4A: burgessR3 bridging lemma sorry-free; C4/C4' hard sub-case sorry-free (-2 sorry sites)
- [ ] Phase 4B: g-immutability, limit_g, limit_c3, c3_interval_subset_point all sorry-free
- [ ] Phase 5A: limit_satisfies_c4 sorry-free; limit_forward_G sorry-free
- [ ] Phase 5B: restricted_fuc sorry-free (-2 sorry sites)
- [ ] Phase 6: `#print axioms dd_countermodel_chronicle` clean; zero sorry in Chronicle/
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] lake build succeeds at each phase boundary

## Artifacts & Outputs

- `specs/107_.../plans/31_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean` (until_guard, since_guard) -- Phase 1 DONE
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (soundness cases) -- Phase 1 DONE
- Modified: `Chronicle/ChronicleTypes.lean` (c2' BurgessR3Maximal) -- Phase 2 DONE
- Modified: `Chronicle/RRelation.lean` (BurgessR3Maximal, existence, bridging lemma)
- Modified: `Chronicle/CounterexampleElimination.lean` (EliminationResult, g-population, C4 hard case)
- Modified: `Chronicle/ChronicleConstruction.lean` (g-immutability, limit_g, limit_c3, limit_satisfies_c4, singleton_chronicle g)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (restricted_fuc closure)
- Modified: `Chronicle/PointInsertion.lean` (Lemma 2.6 burgessR3_absorption)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 3 contingency (seed construction)**: If kernel set K approach fails, use empty DCS (deductiveClosure({})) as seed -- it vacuously satisfies burgessR3 since it has no non-theorem elements. Apply burgessR3Maximal_extension_exists from there.
- **Phase 3 contingency (g-population scope)**: If extending EliminationResult proves too disruptive, carry g-values in a separate side-channel structure parallel to the Chronicle.
- **Phase 4A contingency (bridging lemma)**: The burgessR3 bridging lemma is definitional (directly from burgessRSet). If Lean formalization has guard/event argument swap, write the wrapper accounting for notation.
- **Phase 4A contingency (Lemma 2.6)**: If adapting lemma_2_6_full to work without MCS requires changes, implement the splitting construction from scratch using maximality failure witness.
- **Phase 4B contingency (limit_g)**: If g-immutability is hard to establish for all elimination types simultaneously, prove it per-elimination-type and combine.
- **Phase 5B contingency (C5-with-guard)**: If C5 does not thread the guard witness through to limit_g, strengthen C5 EliminationResult to carry gamma in g(t,s) explicitly.
- **Workstream independence**: If one workstream completes but the other stalls, ship the completed workstream's sorry closures independently. Each closes 2 of 4 sorry sites.
- **Budget overrun**: Phases 5A and 5B are independent. Either can ship without the other.

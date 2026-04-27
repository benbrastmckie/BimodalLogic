# Implementation Plan: Task #107 (v16 -- Lemma 2.6 Direct, No Density)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 18 hours (remaining)
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/28_team-research.md], [reports/29_team-research.md], [reports/29_teammate-c-findings.md]
- **Artifacts**: plans/29_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Four active sorry sites block sorry-free `dd_countermodel_chronicle`. Round 29 team research debunked the forward_G/C4 "circularity" -- it was never a mathematical cycle, only a Lean code architecture artifact caused by the empty g-function. Burgess's Lemma 2.9 resolves the C4 hard case at finite stages using Lemma 2.6 and R-maximality of g(x,y), never forward_G. The key insight: gamma NOT in g(x,y) via a 3-argument r-relation contradiction (untl(gamma, delta) in f(x) contradicts neg(untl(gamma, delta)) in f(x)). This plan preserves the completed Phase 1 (guard axioms) and the in-progress Phase 2 (g_agrees), restructures Phase 5 to use Lemma 2.6 directly instead of case-splitting on G(gamma)/H(gamma), and removes all references to density axioms.

### Research Integration

- Report 28 (team research): Identified root cause -- g-values never populated. Recommended Phases 2-6 for g-population.
- Report 29 (team research, 4 teammates): Debunked forward_G/C4 circularity. Unanimous: density axioms NOT needed. C4 hard case resolves via Lemma 2.6 + r-relation contradiction (gamma not in g(x,y)). Dead code confirmed (chronicle_fmcs, chronicle_bfmcs).
- Report 29 Teammate C (critic): Traced Burgess Lemma 2.9 case n=0 proof in detail. The case split on G(gamma)/H(gamma) in the Lean code is unnecessary. The correct proof uses the 3-arg r-relation to show gamma not in g(x,y), then applies lemma_2_6_full.

### Prior Plan Reference

Plan v15 (artifact 28): 6-phase structure. Phase 1 [COMPLETED]. Phase 2 [BLOCKED] (g_agrees work in progress). Phases 3-6 [NOT STARTED]. Phase 5 used a case-split on G(gamma)/H(gamma) with a BX2+BX12+forward_G contradiction argument for the gamma-in-g(x,y) sub-case. Round 29 research shows this case split is unnecessary -- Burgess never performs it. The gamma-in-g(x,y) case is vacuous via r-relation contradiction. This revision restructures Phase 5 accordingly and adds an r-relation bridging lemma task.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing the final 4 sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Extend EliminationResult to carry g-agreement conditions (continue Phase 2 work)
- Populate g-values in every elimination function (C5, C5', C4, C4', density, g_prop, h_prop)
- Prove r-relation bridging lemma: R3Maximal(A, B, C) + untl(gamma, delta).neg in A + delta in C implies gamma not in B
- Close C4 hard sub-case via Lemma 2.6 directly (no case split on G(gamma)/H(gamma))
- Prove g-immutability and define proper limit_g with C3 at the limit
- Close restricted_fuc sorry sites via until_guard + limit_g + C3
- Delete dead code (chronicle_fmcs, chronicle_bfmcs) and clean up
- Achieve sorry-free dd_countermodel_chronicle
- Maintain lake build at each phase boundary

**Non-Goals**:
- Adding density axioms (GG->G, HH->H) -- debunked by research
- Case-splitting on G(gamma)/H(gamma) in C4 elimination -- unnecessary per Burgess
- General completeness for all strict linear orders (separate task)
- Reintroduction of g_ordered or two-sided seeds
- Fixing sorry sites outside Chronicle/ directory
- BXCanonical sorry closure (task 109)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| EliminationResult g-agreement extension cascades through many signatures | H | H | Start with minimal extension (single g_agree field). Refactor incrementally -- do C5 first as template, then apply to C4/density/g_prop. |
| R-relation bridging lemma requires 3-arg formulation not directly in codebase | M | M | The codebase's R3Maximal(A, B, C) includes both rRelation(A, B) and rRelationSince(C, B). The bridging lemma derives the needed property from rRelation(A, B): untl(gamma, delta).neg in A + gamma in B implies untl(gamma, delta) in A (from rRelation), contradiction. If rRelation's definition doesn't directly yield this, extract from R3Maximal's DCS properties. |
| C3 for non-adjacent pairs requires compositional construction via C3 identity | M | M | Burgess's C3 identity g(x,z) = g(x,y) inter f(y) inter g(y,z) defines non-adjacent g from adjacent. Implement as computed value, not stored. Only adjacent g-values need storage. |
| lemma_2_6_full interface may not match needed calling convention | M | L | Teammate C flagged this uncertainty. Check the interface in RRelation.lean before starting Phase 5. If interface mismatch, write a thin wrapper. |
| Adding axioms to BX (Phase 1, already done) may break existing Soundness proofs | L | L | Already completed without issue in Phase 1. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | Phase 1 (completed) |
| 2 | 3 | 2 |
| 3 | 4, 5 | 3 |
| 4 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add until_guard / since_guard Axioms [COMPLETED]
<!-- Completed in prior session -->

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

### Phase 2: Extend EliminationResult and Populate g in C5/C5' Elimination [IN PROGRESS]

**Goal**: Extend the EliminationResult structure to carry g-agreement conditions, and implement g-population for C5/C5' elimination (the simplest case, providing a template for C4).

**Tasks**:
- [ ] Study current EliminationResult structure in `CounterexampleElimination.lean` -- understand all fields and how elimination functions produce them
- [ ] Design g-agreement field: `g_agree : forall x y, x in new_chi.dom -> y in new_chi.dom -> x < y -> Adjacent new_chi.dom x y -> R3Maximal (new_chi.f x) (new_chi.g x y) (new_chi.f y)` (or similar, matching C2' invariant)
- [ ] Extend EliminationResult with the g-agreement field
- [ ] Modify C5 elimination (`eliminate_C5_counterexample`): when inserting point z between endpoints, set `new_chi.g(x,z)` and `new_chi.g(z,y)` using Lemma 2.4's R-maximal DCS construction. For all other pairs, carry forward `chi.g`
- [ ] Modify C5' elimination (mirror): same pattern with reversed direction
- [ ] Prove g-agreement for C5 elimination: the newly set g-values satisfy R3Maximal by construction (Lemma 2.4 produces R3Maximal output)
- [ ] Update all call sites of C5/C5' elimination to handle the new field
- [ ] Run lake build and verify

**Timing**: 4 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- EliminationResult, C5/C5' elimination functions
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- call sites in omega chain

**Verification**:
- EliminationResult has g-agreement field
- C5/C5' elimination sets non-empty g-values
- g-agreement proved for C5/C5' case
- lake build succeeds
- No new sorry sites introduced

---

### Phase 3: Populate g in C4/C4', Density, and g_prop/h_prop Elimination [NOT STARTED]

**Goal**: Complete g-population for all remaining elimination functions. After this phase, every elimination step produces non-empty g-values for all adjacent pairs in the domain.

**Tasks**:
- [ ] Modify C4 elimination (`eliminate_C4_counterexample`): when inserting point z between x and y, set `g(x,z)` and `g(z,y)` using Lemma 2.6's three-way decomposition. Pass C2' (ChronicleInvariant) into the function to access existing g(x,y)
- [ ] Modify C4' elimination (mirror)
- [ ] Prove g-agreement for C4 elimination: Lemma 2.6 produces R3Maximal by construction
- [ ] Modify density elimination: when inserting z between x and y (making the domain denser), set `g(x,z) = g(x,y) inter f(y) inter g(y,z)` using C3 identity, or construct fresh R3Maximal DCS
- [ ] Modify g_prop elimination: when inserting z for g-propagation, set g(x,z) and g(z,y) appropriately
- [ ] Modify h_prop elimination (mirror)
- [ ] Prove g-agreement for each case
- [ ] Prove that existing g-values are preserved: for pairs (a,b) already in the domain where neither a nor b is the newly inserted point, `new_chi.g(a,b) = chi.g(a,b)`
- [ ] Run lake build and verify

**Timing**: 5 hours

**Depends on**: Phase 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C4/C4', density, g_prop, h_prop elimination
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- call sites, pass ChronicleInvariant
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- possibly extend ChronicleInvariant if needed

**Verification**:
- All elimination functions set non-empty g-values
- g-agreement proved for all cases
- Existing g-values preservation proved
- lake build succeeds
- No new sorry sites introduced

---

### Phase 4: Prove g-Immutability and Define Proper limit_g with C3 [NOT STARTED]

**Goal**: Prove that g-values are immutable once set, define `limit_g` as the stable finite-stage value, and prove C3 at the limit. This provides the infrastructure needed for restricted_fuc.

**Tasks**:
- [ ] Prove g-immutability lemma: for m >= n >= first_stage(x,y), `(omega_chain_val m).g x y = (omega_chain_val n).g x y`. This follows from Phase 3's preservation proof -- each elimination only modifies g for pairs involving the NEW point
- [ ] Define `limit_g(x,y) = (omega_chain_val N).g x y` where N is the first stage with both x and y in the domain. Use `Nat.find` with decidability
- [ ] Prove limit_g is well-defined: for any x,y in limit_dom, the required N exists
- [ ] Prove C2' at the limit: `R3Maximal (limit_f x) (limit_g x y) (limit_f y)` for adjacent x,y in limit_dom. Reduce to C2' at finite stage N using f-immutability and g-immutability
- [ ] Prove limit_c3: `limit_g(x,z) = limit_g(x,y) inter limit_f(y) inter limit_g(y,z)` for x < y < z in limit_dom. Reduce to C3 at finite stage using immutability
- [ ] Prove `c3_interval_subset_point`: for x < y < z in limit_dom, `limit_g(x,z) subset limit_f(y)`. Immediate from limit_c3 (f(y) is a factor in the intersection)
- [ ] Prove `limit_g_is_mcs`: limit_g(x,y) is an MCS for adjacent x,y. From limit C2' + R3Maximal_is_mcs
- [ ] Run lake build and verify

**Timing**: 4 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- g-immutability, limit_g definition, limit_c3, c3_interval_subset_point

**Verification**:
- g-immutability proved sorry-free
- limit_g defined using Nat.find
- limit_c3 proved sorry-free
- c3_interval_subset_point proved sorry-free
- limit_g_is_mcs proved sorry-free
- lake build succeeds

---

### Phase 5: Close C4/C4' Hard Sub-Case via Lemma 2.6 (2 Sorry Sites) [IN PROGRESS]

**Goal**: Close the 2 sorry sites at CounterexampleElimination.lean:334 and 449 using Lemma 2.6 directly, following Burgess Lemma 2.9. No case split on G(gamma)/H(gamma). The key is the r-relation bridging lemma showing gamma is not in g(x,y).

**Tasks**:
- [ ] Prove r-relation bridging lemma (new lemma in RRelation.lean or CounterexampleElimination.lean):
  - Statement: `R3Maximal(A, B, C) -> untl(gamma, delta).neg in A -> delta in C -> gamma not in B`
  - Proof: Assume gamma in B. By rRelation(A, B) (component of R3Maximal), for beta in B and alpha such that untl(alpha, beta) applies, we get untl(alpha, beta) in A. Specifically: gamma in B and delta in C, so by the r-relation definition untl(gamma, delta) in A. But untl(gamma, delta).neg in A. Contradiction with A being an MCS.
  - Prove the dual: `R3Maximal(A, B, C) -> snce(gamma, delta).neg in C -> delta in A -> gamma not in B`
- [ ] Refactor `eliminate_C4_counterexample` signature to accept ChronicleInvariant (specifically C2' providing R3Maximal for adjacent pairs)
- [ ] Update all call sites in the omega chain to pass ChronicleInvariant
- [ ] At the sorry site (line 334): apply the r-relation bridging lemma to show gamma not in g(x,y), then apply `lemma_2_6_full` with gamma not in g(x,y) to produce D with gamma.neg in D. No case split on G(gamma)/H(gamma) needed.
- [ ] Close C4' hard sub-case (line 449): mirror using the dual bridging lemma with Since
- [ ] Remove the unnecessary G(gamma)/H(gamma) case-split code if it exists
- [ ] Run lake build and verify

**Timing**: 3 hours

**Depends on**: Phase 3 (needs populated g-values in the elimination function; does NOT need limit_g)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- r-relation bridging lemma
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C4/C4' hard sub-case proofs, signature refactor
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- update call sites

**Verification**:
- r-relation bridging lemma proved sorry-free
- C4 hard sub-case sorry-free (line 334 closed)
- C4' hard sub-case sorry-free (line 449 closed)
- All call sites updated for new signature
- lake build succeeds
- Sorry count reduction: -2

---

### Phase 6: Close restricted_fuc, Delete Dead Code, Final Validation (2 Sorry Sites + Cleanup) [IN PROGRESS]

**Goal**: Close the 2 restricted_fuc sorry sites using until_guard (base point) + limit_g + C3 (intermediates), delete dead code, and validate sorry-free dd_countermodel_chronicle.

**Tasks**:
- [ ] Close restricted_fuc Until (ChronicleToCountermodel.lean:964):
  - Given `untl(gamma,delta) in f(t)`, use `until_guard_in_mcs` from Phase 1 to get `gamma in f(t)` (base point)
  - Use C5 to get endpoint s > t with delta in f(s) and gamma in limit_g(t,s) (the C5 elimination witness includes the guard)
  - For intermediate r with t < r < s: by c3_interval_subset_point, `limit_g(t,s) subset limit_f(r)`, so gamma in f(r)
  - Transfer through Cantor isomorphism
- [ ] Close restricted_fuc Since (ChronicleToCountermodel.lean:968): mirror using since_guard + C5' + backward interval
- [ ] Delete dead code: `chronicle_fmcs`, `chronicle_bfmcs` and their 8 sorry sites (confirmed dead by research -- dd_countermodel_chronicle uses only cantor_fmcs/cantor_bfmcs)
- [ ] Remove placeholder `limit_g` artifacts and unused helper functions
- [ ] Clean up Adjacent-related dead comments
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify only Lean axioms (propfunext, Quot.sound, Classical.choice) -- no sorryAx
- [ ] Verify zero sorry sites in Chronicle/ directory
- [ ] Verify no regressions: full lake build
- [ ] Verify Soundness, FMP, ParametricTruthLemma remain sorry-free

**Timing**: 4 hours

**Depends on**: Phases 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- restricted_fuc Until/Since proofs, dead code removal (chronicle_fmcs, chronicle_bfmcs)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- comment cleanup, placeholder removal
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- comment cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- comment cleanup

**Verification**:
- restricted_fuc Until sorry-free (line 964 closed)
- restricted_fuc Since sorry-free (line 968 closed)
- chronicle_fmcs and chronicle_bfmcs deleted
- `#print axioms dd_countermodel_chronicle` shows NO sorryAx
- Zero sorry sites in Chronicle/ directory
- lake build succeeds (full clean build)
- Soundness, FMP, ParametricTruthLemma remain sorry-free
- Sorry count reduction: -2 (total -4 from plan start), plus -8 from dead code deletion

## Testing & Validation

- [ ] Phase 1: `until_guard`/`since_guard` axioms added; Soundness.lean sorry-free; MCS-level lemmas compile (COMPLETED)
- [ ] Phase 2: EliminationResult extended; C5/C5' produce non-empty g; lake build passes
- [ ] Phase 3: All elimination functions produce non-empty g; g-preservation proved; lake build passes
- [ ] Phase 4: g-immutability, limit_g, limit_c3, c3_interval_subset_point all sorry-free
- [ ] Phase 5: r-relation bridging lemma sorry-free; C4/C4' hard sub-case sorry-free (-2 sorry sites)
- [ ] Phase 6: restricted_fuc sorry-free (-2 sorry sites); dead code deleted (-8 sorry sites); `#print axioms dd_countermodel_chronicle` clean; zero sorry in Chronicle/
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] lake build succeeds at each phase boundary

## Artifacts & Outputs

- `specs/107_.../plans/29_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean` (until_guard, since_guard) -- Phase 1 DONE
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (soundness cases) -- Phase 1 DONE
- Modified: `Chronicle/RRelation.lean` (MCS-level guard lemmas, r-relation bridging lemma)
- Modified: `Chronicle/CounterexampleElimination.lean` (EliminationResult, g-population, C4 hard case via Lemma 2.6)
- Modified: `Chronicle/ChronicleConstruction.lean` (g-immutability, limit_g, limit_c3, call sites)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (restricted_fuc closure, dead code deletion)
- Modified: `Chronicle/ChronicleTypes.lean` (possible ChronicleInvariant extension)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 2-3 contingency (g-population)**: If extending EliminationResult proves too disruptive, carry g-values in a separate side-channel structure parallel to the Chronicle, avoiding cascading signature changes.
- **Phase 5 contingency (r-relation bridging lemma)**: If the codebase's R3Maximal does not directly yield "gamma in B + delta in C implies untl(gamma, delta) in A," introduce a thin wrapper definition matching Burgess's 3-arg r(A, B, C) and prove equivalence with R3Maximal. Teammate A flagged this as a possible gap.
- **Phase 5 contingency (lemma_2_6_full interface)**: If lemma_2_6_full does not accept the "gamma not in B" hypothesis directly, write a wrapper that extracts the needed components from R3Maximal and calls the underlying DCS construction.
- **Phase 6 contingency (restricted_fuc)**: If C5 does not thread the guard witness through to the limit, strengthen the C5 EliminationResult to include gamma in limit_g(t,s) explicitly.
- **Budget overrun**: Phases 4+5 and Phase 6 are somewhat independent. Phase 5 (C4 hard case) can be shipped without Phase 6 (restricted_fuc), and vice versa.

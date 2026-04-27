# Implementation Plan: Task #107 (v15 -- Populate g-Values, Close All Sorry Sites)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 22 hours (remaining)
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/28_team-research.md]
- **Artifacts**: plans/28_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Four active sorry sites block sorry-free `dd_countermodel_chronicle`. The root cause, identified by round 28 team research, is that the codebase never populates g-values -- `singleton_chronicle` sets `g := fun _ _ => emptyset` and no elimination function updates g. Burgess 1982 populates g at every step (Lemma 2.4 for C5, Lemma 2.6 for C4). Without non-empty g, C2' gives R3Maximal of the empty set (not an MCS), and the C4 hard sub-case cannot be closed. Additionally, the half-open guard convention requires new `until_guard`/`since_guard` axioms for the base point. This plan restructures the remaining work into 6 phases: add guard axioms, extend EliminationResult to carry g-agreement, populate g in each elimination case, prove g-immutability and limit_g, close all 4 sorry sites, and clean up.

### Research Integration

Report 28 (team research, 4 teammates): (1) g_prop + temp_4 chaining does NOT work -- g_prop is adjacent-only, vacuous at the dense limit; (2) Burgess DOES populate g at every step via Lemma 2.4/2.6; (3) half-open guard requires `until_guard : untl(phi,psi) -> phi` axiom (sound under `t <= t`); (4) sorry contamination is broader than reported -- the 2 C4 hard-case sorries contaminate the entire omega chain via sorryAx.

### Prior Plan Reference

Plan v14 (artifact 27): Phases 0-4 completed. Phases 5-6 blocked -- Phase 5 (limit_g + restricted_fuc) blocked because g-values are never populated (limit_g over empty g is useless). Phase 6 (C4 hard sub-case) blocked because R3Maximal of empty g is false. The current plan abandons the prior approach of defining limit_g over empty g and instead addresses the root cause: populating g at every elimination step. Effort calibration from prior plans: elimination function refactoring typically takes 2-3x the initial estimate due to type-level cascading.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing the final 4 sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Add sound `until_guard`/`since_guard` axioms to the BX system
- Extend EliminationResult to carry g-agreement conditions
- Populate g-values in every elimination function (C5, C5', C4, C4', density, g_prop, h_prop)
- Prove g-immutability at the omega chain level
- Define proper `limit_g` as finite-stage g-values and prove C3 at the limit
- Close all 4 active sorry sites (C4 hard sub-case x2, restricted_fuc x2)
- Achieve sorry-free `dd_countermodel_chronicle` with clean `#print axioms`
- Maintain lake build at each phase boundary

**Non-Goals**:
- General completeness for all strict linear orders (separate task)
- Reintroduction of g_ordered or two-sided seeds
- Fixing sorry sites outside Chronicle/ directory
- BXCanonical sorry closure (task 109)
- Changing the Until/Since guard convention from half-open to open

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| EliminationResult g-agreement extension cascades through many signatures | H | H | Start with a minimal extension (single `g_agree` field). Refactor incrementally -- do C5 first as the simplest case, learn the pattern, then apply to C4/density/g_prop. |
| C3 for non-adjacent pairs requires compositional construction via C3 identity | M | M | Burgess's C3 identity `g(x,z) = g(x,y) inter f(y) inter g(y,z)` defines non-adjacent g from adjacent. Implement this as a computed value, not stored. Only adjacent g-values need to be stored in the Chronicle. |
| C4 hard sub-case gamma-in-g(x,y) sub-sub-case proves intractable | H | M | With non-empty g, R3Maximal_is_mcs gives g(x,y) as MCS. Negation completeness gives gamma or gamma.neg. The gamma.neg case is straightforward. The gamma case: use BX2+BX12+forward_G to derive contradiction (G(gamma) at x + gamma in g(x,y) + neg(untl) at x -> contradiction via Until unwinding). Fallback: show this configuration never arises in the construction. |
| Adding axioms to BX breaks existing Soundness proofs | M | L | `until_guard` is sound under half-open semantics (take r=t in guard, t<=t). Need to add soundness cases for the new axioms. Soundness.lean is currently sorry-free and must remain so. |
| g-immutability proof complex due to elimination function interactions | M | M | Each elimination function only sets g for NEW pairs involving the inserted point z. Existing g(x,y) values are never overwritten. This is a structural property of the Chronicle extension pattern -- prove it once for `eliminate_and_extend` generically. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add until_guard / since_guard Axioms [COMPLETED]
<!-- Completed in prior session -->

**Goal**: Add sound axioms `until_guard : untl phi psi -> phi` and `since_guard : snce phi psi -> phi` to the BX axiom system, with soundness proofs.

**Tasks**:
- [ ] Add `until_guard` constructor to the `Axiom` inductive type in `ProofSystem/Axioms.lean`
- [ ] Add `since_guard` constructor (mirror)
- [ ] Prove soundness of `until_guard` in `Soundness.lean`: from `untl phi psi` true at t (exists s > t with psi at s and phi at r for t <= r < s), take r = t (since t <= t), get phi at t
- [ ] Prove soundness of `since_guard` in `Soundness.lean`: mirror using s < r <= t, take r = t
- [ ] Verify `DenseSoundness.lean` and `DiscreteSoundness.lean` still compile (they delegate to `Soundness.lean`)
- [ ] Prove `until_guard_in_mcs : untl phi psi in S -> phi in S` for MCS S (in Chronicle/RRelation.lean or a helper file)
- [ ] Prove `since_guard_in_mcs` (mirror)
- [ ] Run lake build and verify no regressions

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- new constructors
- `Theories/Bimodal/Metalogic/Soundness.lean` -- soundness cases
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- MCS-level lemmas

**Verification**:
- `until_guard` and `since_guard` in Axiom type
- Soundness.lean remains sorry-free
- MCS-level lemmas compile without sorry
- lake build succeeds

---

### Phase 2: Extend EliminationResult and Populate g in C5/C5' Elimination [BLOCKED]

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

**Timing**: 6 hours

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

**Goal**: Prove that g-values are immutable once set, define `limit_g` as the stable finite-stage value, and prove C3 at the limit. This provides the infrastructure needed for both the C4 hard sub-case and restricted_fuc.

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

### Phase 5: Close C4/C4' Hard Sub-Case (2 Sorry Sites) [NOT STARTED]

**Goal**: Close the 2 sorry sites at CounterexampleElimination.lean:329 and 439 using the now-populated g-values.

**Tasks**:
- [ ] Extend `eliminate_C4_counterexample` signature to accept C2' (the c2' component of ChronicleInvariant providing R3Maximal for adjacent pairs)
- [ ] Update all call sites in the omega chain to pass C2'
- [ ] At the sorry site (line 329): extract g(x,y) via C2'. Use R3Maximal_is_mcs to establish g(x,y) is an MCS
- [ ] Case split on gamma in g(x,y) vs gamma not in g(x,y) (negation completeness of MCS):
  - **Case gamma.neg in g(x,y)**: Use g(x,y) as the seed for f(z). g(x,y) has the required R3 properties. Contains gamma.neg as needed. Done.
  - **Case gamma in g(x,y)**: Derive contradiction. G(gamma) in f(x) and neg(untl(gamma,delta)) in f(x). By BX2 with phi=top, chi=gamma: `(top -> gamma) AND G(top -> gamma) -> ((top U delta) -> (gamma U delta))`. Since gamma in g(x,y) and g(x,y) subset of any future point's content (via R3Maximal), gamma propagates. Combined with neg(untl(gamma,delta)), derive neg(F(delta)) = G(neg delta) via BX12 contrapositive. By forward_G: neg(delta) at y. But delta in f(y) (C4 counterexample condition). Contradiction.
- [ ] Close C4' hard sub-case (line 439): mirror with H/G and Since/Until
- [ ] Run lake build and verify

**Timing**: 4 hours

**Depends on**: Phase 3 (needs populated g-values in the elimination function; does NOT need limit_g)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C4/C4' hard sub-case proofs, signature extension
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- update call sites

**Verification**:
- C4 hard sub-case sorry-free (line 329 closed)
- C4' hard sub-case sorry-free (line 439 closed)
- All call sites updated for new signature
- lake build succeeds
- Sorry count reduction: -2

---

### Phase 6: Close restricted_fuc and Final Validation (2 Sorry Sites + Cleanup) [NOT STARTED]

**Goal**: Close the 2 restricted_fuc sorry sites using until_guard (base point) + limit_g + C3 (intermediates), then validate sorry-free dd_countermodel_chronicle and clean up dead code.

**Tasks**:
- [ ] Close restricted_fuc Until (ChronicleToCountermodel.lean:964):
  - Given `untl(gamma,delta) in f(t)`, use `until_guard_in_mcs` from Phase 1 to get `gamma in f(t)` (base point)
  - Use C5 to get endpoint s > t with delta in f(s) and gamma in limit_g(t,s) (the C5 elimination witness includes the guard)
  - For intermediate r with t < r < s: by c3_interval_subset_point, `limit_g(t,s) subset limit_f(r)`, so gamma in f(r)
  - Transfer through Cantor isomorphism
- [ ] Close restricted_fuc Since (ChronicleToCountermodel.lean:968): mirror using since_guard + C5' + backward interval
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify only Lean axioms (propfunext, Quot.sound, Classical.choice) -- no sorryAx
- [ ] Verify zero sorry sites in Chronicle/ directory
- [ ] Remove dead code: old `chronicle_fmcs`, `chronicle_bfmcs`, legacy coherence conditions
- [ ] Remove placeholder `limit_g` artifacts and unused helper functions
- [ ] Clean up Adjacent-related dead comments
- [ ] Verify no regressions: full lake build
- [ ] Verify Soundness, FMP, ParametricTruthLemma remain sorry-free

**Timing**: 4 hours

**Depends on**: Phases 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- restricted_fuc Until/Since proofs, dead code removal
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- comment cleanup, placeholder removal
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- comment cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- comment cleanup

**Verification**:
- restricted_fuc Until sorry-free (line 964 closed)
- restricted_fuc Since sorry-free (line 968 closed)
- `#print axioms dd_countermodel_chronicle` shows NO sorryAx
- Zero sorry sites in Chronicle/ directory
- lake build succeeds (full clean build)
- Soundness, FMP, ParametricTruthLemma remain sorry-free
- Sorry count reduction: -2 (total -4 from plan start)

## Testing & Validation

- [ ] Phase 1: `until_guard`/`since_guard` axioms added; Soundness.lean sorry-free; MCS-level lemmas compile
- [ ] Phase 2: EliminationResult extended; C5/C5' produce non-empty g; lake build passes
- [ ] Phase 3: All elimination functions produce non-empty g; g-preservation proved; lake build passes
- [ ] Phase 4: g-immutability, limit_g, limit_c3, c3_interval_subset_point all sorry-free
- [ ] Phase 5: C4/C4' hard sub-case sorry-free (-2 sorry sites)
- [ ] Phase 6: restricted_fuc sorry-free (-2 sorry sites); `#print axioms dd_countermodel_chronicle` clean; zero sorry in Chronicle/
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] lake build succeeds at each phase boundary

## Artifacts & Outputs

- `specs/107_.../plans/28_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean` (until_guard, since_guard)
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (soundness cases)
- Modified: `Chronicle/CounterexampleElimination.lean` (EliminationResult, g-population, C4 hard case)
- Modified: `Chronicle/ChronicleConstruction.lean` (g-immutability, limit_g, limit_c3, call sites)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (restricted_fuc closure, dead code removal)
- Modified: `Chronicle/ChronicleTypes.lean` (possible ChronicleInvariant extension)
- Modified: `Chronicle/RRelation.lean` (MCS-level guard lemmas)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 1 contingency**: If adding axioms creates unexpected regressions in other modules, the axioms can be scoped to the Chronicle module only (as local lemmas derived from the half-open semantics).
- **Phase 2-3 contingency (g-population)**: If extending EliminationResult proves too disruptive, an alternative is to carry g-values in a separate side-channel structure parallel to the Chronicle, without modifying the existing elimination signatures. This adds complexity but avoids cascading signature changes.
- **Phase 5 contingency (C4 gamma-in-g sub-sub-case)**: If the contradiction argument via BX2+BX12+forward_G is blocked by circularity (forward_G depends on C4), use an alternative: at the finite stage where this elimination runs, forward_G is NOT needed -- the elimination function operates at a single step, not at the limit. The contradiction can be derived using the finite-stage C4 invariant directly. Alternatively, show the gamma-in-g(x,y) case is vacuous by construction (the C5 elimination that set g(x,y) may guarantee specific properties).
- **Phase 6 contingency (restricted_fuc)**: If C5 does not thread the guard witness through to the limit, strengthen the C5 EliminationResult to include `gamma in limit_g(t,s)` explicitly. The C5 elimination already checks this condition; it just needs to be recorded in the result type.
- **Budget overrun**: Phases 4+5 and Phase 6 are somewhat independent. Phase 5 (C4 hard case) can be shipped without Phase 6 (restricted_fuc), and vice versa. If time runs out, ship whichever subset is complete.

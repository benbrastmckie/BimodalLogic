# Implementation Plan: Task #107 (v14 -- Close 4 Active Sorry Sites)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 12 hours (remaining)
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/27_team-research.md]
- **Artifacts**: plans/27_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Four active sorry sites remain after partial implementation (v10, phases 0-5 partial). Two are in `cantor_bfmcs_restricted_fuc` (forward Until/Since coherence, ChronicleToCountermodel.lean:964,968), blocked on the placeholder `limit_g` not satisfying C3. Two are in the C4/C4' hard sub-case (CounterexampleElimination.lean:329,439), the G(gamma) in f(x) AND H(gamma) in f(y) configuration. Definition of done: sorry-free `dd_countermodel_chronicle` with clean `#print axioms`.

### Research Integration

Report 27 (team research): Cantor isomorphism approach validated and implemented. A4a unsoundness resolved via R3Maximal_is_mcs. Remaining work is infrastructure (limit_g) and case analysis (C4 hard sub-case).

### Prior Plan Reference

Plan v13 (artifact 27): Phases 0, 1, 2, 4 completed. Phase 3 partially completed (restricted_tc and restricted_buc closed; restricted_fuc still sorry'd). Phase 5 partially completed (2 of 3 C4 sub-cases closed; hard sub-case still sorry'd). Phase 6 (cleanup) not started. The current revision restructures the remaining work into 3 focused phases.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing the final 4 sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Implement proper `limit_g` as union of finite-stage g values
- Prove C3 at the limit via g-immutability and f-immutability
- Close 2 restricted_fuc sorry sites using limit_g + C3 + c3_interval_subset_point
- Close 2 C4/C4' hard sub-case sorry sites using C2' + R3Maximal_is_mcs
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain lake build at each phase boundary

**Non-Goals**:
- General completeness for all strict linear orders (separate task)
- Fixing sorry sites outside Chronicle/ directory
- Dead code cleanup (deferred to final validation)
- Reintroduction of g_ordered or two-sided seeds

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proper limit_g requires omega chain redesign to track g values at each stage | H | M | The omega chain already tracks chi_n with g fields. limit_g = chi_n.g(x,y) for first n with x,y in dom_n. No structural redesign needed, just a new definition + well-definedness proof using g-immutability. |
| C3 at the limit harder than expected (g-immutability proof complex) | M | L | g-immutability follows from the chain extension pattern: new stages only ADD points and set g for NEW pairs, never overwriting existing g values. This is already implicit in the construction. |
| C4 hard sub-case gamma in g(x,y) sub-sub-case is genuinely unreachable but hard to prove | H | M | Two fallback strategies: (a) show the configuration is contradictory using BX axioms (G(gamma) at x with neg(untl(gamma,delta)) at x is contradictory if we can derive gamma U delta from G(gamma) + endpoint witness), (b) use induction on the omega chain stage where the counterexample was first introduced. |
| Passing C2' (ChronicleInvariant) into eliminate_C4_counterexample breaks existing signatures | M | L | The function already takes h_c0 (C0). Adding h_c2' is a signature extension. All call sites in the omega chain have access to the full ChronicleInvariant. Mechanical refactoring. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 0, 1, 2, 3, 4 | -- (completed) |
| 1 | 5, 6 | 0-4 (independent of each other) |
| 2 | 7 | 5, 6 |

Phases within the same wave can execute in parallel.

---

### Phase 0: C4/C4' Fix and forward_G/backward_H [COMPLETED]

**Goal**: Correct C4/C4' definitions (argument swap, Adjacent removal) and prove forward_G/backward_H sorry-free.

**Tasks**:
- [x] Swap C4/C4' EVENT/GUARD roles to match Burgess 1982
- [x] Delete g_ordered/h_ordered from ChronicleInvariant
- [x] Remove Adjacent restriction from C4/C4' (use `x < y`)
- [x] Update C4Counterexample/C4'Counterexample structures
- [x] Update omega chain enumeration to process ALL pairs
- [x] Prove limit_forward_G via generalized C4 + C0
- [x] Prove limit_backward_H (mirror)
- [x] Build passes (1055 jobs)

**Timing**: 4 hours (actual)

**Depends on**: none

**Files modified**:
- `Chronicle/ChronicleTypes.lean` -- C4/C4' definitions
- `Chronicle/CounterexampleElimination.lean` -- structures, omega chain
- `Chronicle/ChronicleConstruction.lean` -- limit_forward_G, limit_backward_H

**Verification**:
- limit_forward_G sorry-free
- limit_backward_H sorry-free
- Build passes

---

### Phase 1: Prove limit_dom Typeclass Instances [COMPLETED]

**Goal**: Establish the typeclass prerequisites for `Order.iso_of_countable_dense` on `limit_dom`.

**Tasks**:
- [x] Define `LimitDomSubtype` with inherited LinearOrder
- [x] Prove `Countable`, `DenselyOrdered`, `NoMinOrder`, `NoMaxOrder`, `Nonempty`
- [x] Run lake build and verify

**Timing**: 2 hours (actual)

**Depends on**: Phase 0

**Files modified**:
- `Chronicle/ChronicleToCountermodel.lean` -- limit_dom instances

**Verification**:
- All 5 typeclass instances compile without sorry
- lake build succeeds

---

### Phase 2: Build Cantor Isomorphism and cantor_fmcs [COMPLETED]

**Goal**: Extract order isomorphism `limit_dom ≃o Q` and define Cantor-based FMCS where every rational is a domain point.

**Tasks**:
- [x] Apply `Order.iso_of_countable_dense` to get `cantor_iso : LimitDomSubtype ≃o Q`
- [x] Define `cantor_f`, `cantor_zero`, `cantor_fmcs` (sorry-free forward_G/backward_H)
- [x] Define `rooted_cantor_fmcs`, `cantor_bfmcs` (sorry-free BFMCS)
- [x] Prove `box_stable_in_rooted_cantor_fmcs` sorry-free
- [x] Rewire `dd_countermodel_chronicle` to use `cantor_bfmcs`
- [x] Run lake build -- passes (1097 jobs)

**Timing**: 1 hour (actual)

**Depends on**: Phase 1

**Files modified**:
- `Chronicle/ChronicleToCountermodel.lean` -- cantor_fmcs, cantor_bfmcs, dd_countermodel_chronicle rewired

**Verification**:
- cantor_fmcs sorry-free (forward_G, backward_H)
- cantor_bfmcs sorry-free (modal_forward, modal_backward)
- dd_countermodel_chronicle rewired to cantor_bfmcs
- lake build succeeds

---

### Phase 3: Close restricted_tc and restricted_buc [COMPLETED]

**Goal**: Close the 4 sorry sites for temporal F/P resolution and backward Until/Since coherence.

**Tasks**:
- [x] Close restricted_tc forward (F resolution via limit_F_resolution at every Cantor point)
- [x] Close restricted_tc backward (P resolution via limit_P_resolution)
- [x] Close restricted_buc Until (backward Until via C4 contrapositive)
- [x] Close restricted_buc Since (mirror via C4')
- [x] Run lake build and verify

**Timing**: 2 hours (actual)

**Depends on**: Phase 2

**Files modified**:
- `Chronicle/ChronicleToCountermodel.lean` -- restricted_tc, restricted_buc proofs

**Verification**:
- restricted_tc sorry-free
- restricted_buc sorry-free
- lake build succeeds

---

### Phase 4: A4a Investigation and Lemma 2.6 [COMPLETED]

**Goal**: Resolve A4a derivability and close lemma_2_6_full.

**Results**:
- [x] A4a NOT derivable from BX (not sound under strict semantics)
- [x] R3Maximal_is_mcs discovered: forces B to be MCS, collapsing the problem
- [x] lemma_2_6_full proved sorry-free
- [x] C4 hard case: 2 of 3 sub-cases closed (G(gamma) not in f(x) and H(gamma) not in f(y))
- [x] lake build passes (1066 jobs)

**Timing**: 3 hours (actual, phases 4+5 partial from v13)

**Depends on**: Phase 0

**Files modified**:
- `Chronicle/PointInsertion.lean` -- R3Maximal_is_mcs, lemma_2_6_full
- `Chronicle/CounterexampleElimination.lean` -- C4 sub-cases (2 of 3)

**Verification**:
- lemma_2_6_full sorry-free
- 2 of 3 C4 sub-cases closed
- lake build succeeds

---

### Phase 5: Proper limit_g and restricted_fuc Closure [NOT STARTED]

**Goal**: Replace the placeholder `limit_g` with the correct definition and close the 2 restricted_fuc sorry sites (ChronicleToCountermodel.lean:964,968).

**Tasks**:
- [ ] Define proper `limit_g(x,y) = (omega_chain_val n).g x y` where n is the first stage with x,y in dom_n
  - Use `Nat.find` with decidability of `x ∈ (omega_chain_val k).dom ∧ y ∈ (omega_chain_val k).dom`
  - Prove well-definedness: for any x,y in limit_dom, such n exists (both enter dom at some finite stage)
- [ ] Prove g-immutability: for m >= n >= first_stage(x,y), `(omega_chain_val m).g x y = (omega_chain_val n).g x y`
  - This follows from the chain extension pattern: each `eliminate_and_extend` only sets g for the NEW point z, leaving existing g values unchanged
- [ ] Prove limit_c3 (C3 at the limit): `limit_g(x,z) = limit_g(x,y) ∩ limit_f(y) ∩ limit_g(y,z)` for x < y < z in limit_dom
  - Reduce to C3 at finite stage: take n = max(first_stage(x,y), first_stage(y,z), first_stage(x,z))
  - At stage n, C3 holds by ChronicleInvariant.c3; by g-immutability and f-immutability, the equation lifts to the limit
- [ ] Prove `c3_interval_subset_point` at the limit: for x < y < z, `limit_g(x,z) ⊆ limit_f(y)`
  - Immediate from limit_c3 (f(y) is a factor in the three-way intersection)
- [ ] Close restricted_fuc Until (line 964):
  - Given `untl(gamma,delta) ∈ f(t)`, use C5 to get endpoint y > t with delta in f(y)
  - For intermediate z with t < z < y: by c3_interval_subset_point, limit_g(t,y) ⊆ limit_f(z)
  - C5 also gives gamma in limit_g(t,y) (the guard witness from the C5 elimination)
  - Therefore gamma in f(z) for all intermediate z
  - Transfer through Cantor iso
- [ ] Close restricted_fuc Since (line 968): mirror using C5' and backward interval function
- [ ] Run lake build and verify

**Timing**: 5 hours

**Depends on**: Phases 0-4

**Files to modify**:
- `Chronicle/ChronicleConstruction.lean` -- proper limit_g definition, g-immutability, limit_c3
- `Chronicle/ChronicleToCountermodel.lean` -- restricted_fuc Until/Since proofs

**Verification**:
- limit_g definition uses omega_chain_val, not placeholder
- limit_c3 proved sorry-free
- c3_interval_subset_point at limit proved sorry-free
- restricted_fuc Until sorry-free (line 964 closed)
- restricted_fuc Since sorry-free (line 968 closed)
- lake build succeeds
- Sorry count reduction: -2

---

### Phase 6: C4/C4' Hard Sub-Case Closure [NOT STARTED]

**Goal**: Close the 2 remaining sorry sites in CounterexampleElimination.lean (lines 329, 439) -- the G(gamma) in f(x) AND H(gamma) in f(y) configuration.

**Tasks**:
- [ ] Extend `eliminate_C4_counterexample` signature to accept C2' (ChronicleInvariant or at least the c2' component providing R3Maximal for adjacent pairs)
  - Update all call sites in the omega chain construction to pass the invariant
- [ ] Extract g(x,y) via C2': the chronicle invariant guarantees R3Maximal between adjacent domain pairs
  - Use `R3Maximal_is_mcs` to establish g(x,y) is an MCS
- [ ] Case split on gamma in g(x,y) vs gamma not in g(x,y) (negation completeness of MCS):
  - **Case gamma not in g(x,y)**: gamma.neg in g(x,y) by MCS negation completeness. Use g(x,y) as the seed for point z between x and y. g(x,y) already has the required R3 properties (it IS the interval function). Construct f(z) = g(x,y), which contains gamma.neg.
  - **Case gamma in g(x,y)**: G(gamma) in f(x) means gamma in g_content(f(x)), so gamma in g(x,y) (by C2 monotonicity). H(gamma) in f(y) means gamma in h_content(f(y)), so gamma in g(x,y) (by duality). This sub-sub-case: gamma in g(x,y) AND gamma in f(x) AND gamma in f(y). Use the neg(untl(gamma,delta)) in f(x) hypothesis -- by BX5 (Until induction), neg(untl(gamma,delta)) AND gamma implies neg(delta) AND G(neg(untl(gamma,delta))). Since gamma in g(x,y) and neg(untl(gamma,delta)) propagates forward, the Until unwinding eventually contradicts delta in f(y) at the endpoint. Alternatively, this case may be provably unreachable.
- [ ] Close C4' hard sub-case (line 439): mirror of C4 with H/G and Since/Until swapped
- [ ] Run lake build and verify

**Timing**: 5 hours

**Depends on**: Phases 0-4 (independent of Phase 5)

**Files to modify**:
- `Chronicle/CounterexampleElimination.lean` -- C4/C4' hard sub-case proofs, signature extension
- `Chronicle/ChronicleConstruction.lean` -- update call sites to pass C2'

**Verification**:
- C4 hard sub-case sorry-free (line 329 closed)
- C4' hard sub-case sorry-free (line 439 closed)
- All call sites updated for new signature
- lake build succeeds
- Sorry count reduction: -2

---

### Phase 7: Final Validation and Cleanup [NOT STARTED]

**Goal**: Verify sorry-free `dd_countermodel_chronicle`, clean up dead code, confirm no regressions.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify only Lean axioms (propfunext, Quot.sound, Classical.choice)
- [ ] Verify zero sorry sites in Chronicle/ directory
- [ ] Remove dead code: old `chronicle_fmcs`, `chronicle_bfmcs`, legacy coherence conditions
- [ ] Remove placeholder `limit_g` comment artifacts
- [ ] Remove unused `extended_limit_f` and related non-domain extension code
- [ ] Clean up Adjacent-related dead comments
- [ ] Verify no regressions: full lake build
- [ ] Verify Soundness, FMP, ParametricTruthLemma remain sorry-free

**Timing**: 2 hours

**Depends on**: Phases 5, 6

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- dead code removal
- `Chronicle/ChronicleConstruction.lean` -- comment cleanup, placeholder removal
- `Chronicle/ChronicleTypes.lean` -- comment cleanup
- `Chronicle/CounterexampleElimination.lean` -- comment cleanup

**Verification**:
- lake build succeeds (full clean build)
- Zero sorry sites in Chronicle/ directory
- `#print axioms dd_countermodel_chronicle` clean
- No regressions in other modules

## Testing & Validation

- [x] Phase 0: C4/C4' definitions corrected; forward_G/backward_H sorry-free
- [x] Phase 1: All 5 typeclass instances compile sorry-free
- [x] Phase 2: cantor_fmcs/cantor_bfmcs sorry-free; dd_countermodel_chronicle rewired
- [x] Phase 3: restricted_tc and restricted_buc sorry-free
- [x] Phase 4: lemma_2_6_full sorry-free; 2 of 3 C4 sub-cases closed
- [ ] Phase 5: limit_g proper + restricted_fuc sorry-free (-2 sorry sites)
- [ ] Phase 6: C4/C4' hard sub-case sorry-free (-2 sorry sites)
- [ ] Phase 7: `#print axioms dd_countermodel_chronicle` clean; zero sorry in Chronicle/
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] lake build succeeds at each phase boundary

## Artifacts & Outputs

- `specs/107_.../plans/27_implementation-plan.md` (this file)
- Modified: `Chronicle/ChronicleConstruction.lean` (proper limit_g, g-immutability, limit_c3)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (restricted_fuc closure, dead code removal)
- Modified: `Chronicle/CounterexampleElimination.lean` (C4/C4' hard sub-case closure)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 5 contingency (limit_g)**: If proper limit_g is difficult to define (e.g., decidability of domain membership at finite stages), fall back to carrying the guard witness directly from the C5 elimination result type. The EliminationResult already checks the guard in eliminate_potential_counterexample but discards it -- threading it through the result type avoids needing limit_g entirely.
- **Phase 6 contingency (C4 hard sub-case)**: If the gamma-in-g(x,y) sub-sub-case proves intractable, three fallbacks: (a) show the configuration is unreachable by deriving a contradiction from G(gamma) in f(x) + neg(untl(gamma,delta)) in f(x) + gamma in g(x,y), (b) strengthen the omega chain to never create this configuration (add a pre-check), (c) leave the 2 sorry sites and ship with dd_countermodel_chronicle depending on them -- the limit-level C4 is proved by a separate path.
- **Phase 5 and 6 are independent**: Either can be completed and shipped without the other. Phase 5 alone closes the countermodel wiring sorry sites. Phase 6 alone closes the omega chain sorry sites.
- **Budget overrun**: If either phase exceeds its estimate, ship the other phase's results and defer the blocked phase to a subsequent plan.

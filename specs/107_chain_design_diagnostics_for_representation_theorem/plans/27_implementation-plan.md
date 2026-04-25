# Implementation Plan: Task #107 (v13 -- Cantor Isomorphism + Lemma 2.6 Under Strict Semantics)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/27_team-research.md]
- **Artifacts**: plans/27_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two independent workstreams close the remaining 11 sorry sites in the Chronicle module. Workstream A (8 sorry sites) uses Mathlib's `Order.iso_of_countable_dense` to build a Cantor isomorphism from `limit_dom` to the rationals, making every rational a domain point and eliminating the non-domain extension problem. Workstream B (3 sorry sites) reproves Burgess's Lemma 2.6 seed consistency using BX axioms instead of A4a (which is not sound under strict semantics). Definition of done: sorry-free `dd_countermodel_chronicle` with clean `#print axioms`.

### Research Integration

Report 27 (team research, 4 teammates, Opus): Unanimous that Cantor isomorphism is the correct and lowest-effort solution for the non-domain extension problem. Critical finding: Burgess's Lemma 2.6 proof uses axiom A4a, which is NOT sound under strict semantics -- the seed consistency argument must be reproved using BX5/BX6/BX7 or by deriving A4a from BX. All Cantor iso prerequisites (Countable, DenselyOrdered, NoMinOrder, NoMaxOrder, Nonempty) are provable from sorry-free infrastructure.

### Prior Plan Reference

Plan v12 (artifact 26): Phases 1 and 4 completed successfully (C4/C4' argument swap, Adjacent removal, forward_G/backward_H proved sorry-free). Phases 2-3 (Lemma 2.6 + Lemma 2.9 induction) NOT STARTED. Phase 5 BLOCKED by non-domain extension. Effort calibration: forward_G proof was faster than estimated (Phase 4 in 2h vs 4h planned). The v12 plan did not anticipate the A4a unsoundness problem in Lemma 2.6.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing all 11 sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Build Cantor isomorphism `limit_dom ≃o Q` via `Order.iso_of_countable_dense`
- Define `cantor_f` and `cantor_fmcs` so every rational is a domain point
- Close all 8 ChronicleToCountermodel sorry sites via Cantor-based FMCS
- Investigate A4a derivability from BX axioms
- Implement Lemma 2.6 full seed using BX-compatible proof
- Close C4/C4' hard cases in CounterexampleElimination
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain lake build at each phase boundary

**Non-Goals**:
- General completeness for all strict linear orders (separate task)
- Fixing sorry sites outside Chronicle/ directory (task 109 scope)
- Lemma 2.9 non-adjacent induction (generalized C4 already proved at limit; induction only needed for omega chain steps, not the final countermodel)
- Reintroduction of g_ordered or two-sided seeds (dead ends)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cantor iso instance prerequisites harder than expected (e.g., NoMinOrder requires seriality chain) | M | L | All prerequisites have sorry-free foundations: limit_dom_dense, zero_mem_limit_dom, seriality axioms. Fall back to manual Countable+Dense proof if typeclass inference fails. |
| A4a is NOT derivable from BX, requiring full reproof of Lemma 2.6 seed | H | M | Three options: (1) derive A4a from BX5+BX6+BX7 (8h), (2) use r3Maximal_neg_of_not_mem + dcs_neg_union_consistent incrementally (6h), (3) leave Workstream B sorry'd and ship Workstream A (8/11 sorry sites closed). |
| restricted_buc/restricted_fuc need truth lemma arguments beyond simple domain transfer | M | M | Research identified 3 categories: forward_G/backward_H (trivial), restricted_tc (limit_F/P_resolution), restricted_buc/fuc (C4+C5 arguments). The C4+C5 infrastructure is sorry-free; the wiring is mechanical. |
| Cantor iso shifts evaluation point (cantor_zero differs from 0) | L | L | The iso is order-preserving. cantor_zero = iso(zero_mem_limit_dom). The eval point shifts but all structural properties transfer. The root MCS assignment uses cantor_f(cantor_zero). |
| Lean4 OrderIso API friction (coercions, simp lemmas) | M | M | Mathlib's OrderIso API is well-developed. Use `OrderIso.symm`, `.toFun`, `.map_rel_iff` for core properties. Budget 1h for API exploration. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 0 | -- |
| 1 | 1, 4 | 0 |
| 2 | 2, 5 | 1, 4 |
| 3 | 3 | 2 |
| 4 | 6 | 3, 5 |

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

**Goal**: Establish the typeclass prerequisites for `Order.iso_of_countable_dense` on `limit_dom` as a subtype of the rationals.

**Tasks**:
- [ ] Define `LimitDomSubtype` as `{q : Q // q ∈ limit_dom}` with inherited LinearOrder
- [ ] Prove `Countable LimitDomSubtype`: limit_dom is a countable union of finite sets (each `chi_n.dom` is a Finset)
- [ ] Prove `DenselyOrdered LimitDomSubtype`: from sorry-free `limit_dom_dense`
- [ ] Prove `NoMinOrder LimitDomSubtype`: from BX seriality + `limit_P_resolution` (for any x in limit_dom, there exists y < x in limit_dom)
- [ ] Prove `NoMaxOrder LimitDomSubtype`: from BX seriality + `limit_F_resolution`
- [ ] Prove `Nonempty LimitDomSubtype`: from `zero_mem_limit_dom`
- [ ] Run lake build and verify

**Timing**: 2 hours

**Depends on**: Phase 0

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- new section for limit_dom instances

**Verification**:
- All 5 typeclass instances compile without sorry
- lake build succeeds

---

### Phase 2: Build Cantor Isomorphism and cantor_fmcs [COMPLETED]

**Goal**: Extract the order isomorphism `limit_dom ≃o Q` and define the Cantor-based FMCS where every rational is a domain point.

**Tasks**:
- [x] Apply `Order.iso_of_countable_dense` to get `cantor_iso : LimitDomSubtype ≃o Q`
- [x] Define `cantor_f : Q -> MCS` as `fun q => limit_f (cantor_iso.symm q).val`
- [x] Define `cantor_zero : Q` as `cantor_iso (zero_mem_limit_dom_subtype)`
- [x] Define `cantor_fmcs : FMCS Rat` with sorry-free forward_G and backward_H
  - forward_G: reduces to limit_forward_G via cantor_iso.symm.strictMono
  - backward_H: mirror via cantor_iso.symm.strictMono
- [x] Prove cantor_f_is_mcs: every rational maps to an MCS
- [x] Prove cantor_f_at_zero: cantor_f(cantor_zero) = A (root MCS)
- [x] Define shifted_cantor_fmcs: time-shifted version for bundle construction
- [x] Define rooted_cantor_fmcs: convenience wrapper placing root at s
- [x] Prove rooted_cantor_fmcs_at_s: mcs(s) = A
- [x] Prove box_stable_in_rooted_cantor_fmcs: sorry-free box stability via sorry-free forward_G/backward_H
- [x] Define cantor_bfmcs: sorry-free BFMCS Rat bundle with modal_forward/backward
- [x] Define cantor-based restricted coherence theorems (sorry'd -- Phase 3 scope)
- [x] Rewire dd_countermodel_chronicle to use cantor_bfmcs instead of chronicle_bfmcs
- [x] Run lake build -- passes (1097 jobs)

**Timing**: 1 hour (actual)

**Depends on**: Phase 1

**Files modified**:
- `Chronicle/ChronicleToCountermodel.lean` -- cantor_fmcs, shifted_cantor_fmcs, rooted_cantor_fmcs, box_stable_in_rooted_cantor_fmcs, cantor_bfmcs, cantor-based restricted coherence theorems, dd_countermodel_chronicle rewired

**Verification**:
- cantor_fmcs: sorry-free (forward_G, backward_H proved via cantor_iso.symm.strictMono + limit_forward_G/backward_H)
- cantor_bfmcs: sorry-free (modal_forward, modal_backward proved via box_stable_in_rooted_cantor_fmcs)
- box_stable_in_rooted_cantor_fmcs: sorry-free
- dd_countermodel_chronicle: rewired to cantor_bfmcs (remaining sorries are restricted coherence -- Phase 3)
- lake build succeeds
- Sorry status: 2 legacy (chronicle_fmcs forward_G/backward_H) + 6 cantor-based restricted coherence = 8 sorry sites in file. The 2 legacy sorries are now dead code (dd_countermodel_chronicle no longer routes through chronicle_fmcs).

---

### Phase 3: Close ChronicleToCountermodel Sorry Sites [NOT STARTED]

**Goal**: Rewire `dd_countermodel_chronicle` to use `cantor_fmcs` and close all 8 sorry sites. With Cantor iso, every rational is a domain point, so all coherence conditions reduce to limit-level properties.

**Tasks**:
- [ ] Close chronicle_fmcs.forward_G (line 195): replace with cantor_fmcs.forward_G
- [ ] Close chronicle_fmcs.backward_H (line 200): replace with cantor_fmcs.backward_H
- [ ] Close restricted_tc forward (line 372): F(phi) resolution -- limit_F_resolution applies at every point (all are domain)
- [ ] Close restricted_tc backward (line 375): P(phi) resolution -- limit_P_resolution applies at every point
- [ ] Close restricted_buc Until (line 394): backward Until coherence -- use C4 completeness at limit + truth lemma structure (C4 gives the guard witness between any two points)
- [ ] Close restricted_buc Since (line 397): mirror using C4'
- [ ] Close restricted_fuc Until (line 426): forward Until coherence -- use C5 witness existence + C3 interval containment
- [ ] Close restricted_fuc Since (line 429): mirror using C5'
- [ ] Verify dd_countermodel_chronicle compiles (may still have sorry from Workstream B dependency, but the 8 ChronicleToCountermodel sorry sites should be closed)
- [ ] Run `#print axioms` on the reachable definitions
- [ ] Run lake build and verify

**Timing**: 2 hours

**Depends on**: Phase 2

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- close all 8 sorry sites, rewire to cantor_fmcs

**Verification**:
- ChronicleToCountermodel.lean sorry-free
- All 8 sorry sites closed
- lake build succeeds
- Sorry count reduction: -8

---

### Phase 4: Investigate A4a Derivability and Lemma 2.6 Proof Strategy [COMPLETED]

**Goal**: Determine whether axiom A4a (`U(p,q) AND NOT U(p,r) -> U(q AND NOT r, q)`) is derivable from BX axioms. If yes, Burgess's Lemma 2.6 proof can be used directly. If not, design an alternative seed consistency argument using BX5/BX6/BX7.

**Results**:
- [x] A4a is NOT derivable from BX (not sound under strict semantics, while all BX axioms are)
- [x] Key discovery: R3Maximal forces B to be an MCS (r3Relation monotone in B via r3Relation_subset)
- [x] Proved `R3Maximal_is_mcs`, `mcs_no_proper_dcs_extension`, `rRelation_self_mcs`, `rRelationSince_self_mcs`
- [x] Closed `lemma_2_6_full` sorry-free (D=B'=B''=B since B is MCS, neg(delta) by negation completeness)
- [x] lake build passes (1066 jobs), PointInsertion.lean sorry-free, sorry count -1

**Strategy for Phase 5**: C4/C4' hard cases apply `lemma_2_6_full` directly. Since R3Maximal forces B to be MCS, the decomposition is trivial.

**Timing**: 1 hour (actual, vs 2 estimated -- key discovery simplified everything)

**Depends on**: Phase 0 (only needs existing infrastructure, independent of Cantor iso)

**Files modified**:
- `Chronicle/PointInsertion.lean` -- 4 helper theorems + lemma_2_6_full proof (was sorry)

**Verification**:
- [x] A4a NOT derivable (semantic argument: not sound under strict semantics)
- [x] Alternative: R3Maximal_is_mcs collapses the problem
- [x] `lemma_2_6_full` compiles sorry-free
- [x] lake build passes

---

### Phase 5: Implement Lemma 2.6 Full Seed and Close C4 Hard Cases [NOT STARTED]

**Goal**: Close the 3 Workstream B sorry sites: `lemma_2_6_full` (PointInsertion.lean:762), C4 hard case (CounterexampleElimination.lean:319), C4' hard case (CounterexampleElimination.lean:383).

**Tasks**:
- [ ] Implement `lemma_2_6_full` using the strategy from Phase 4:
  - If A4a derived: follow Burgess's proof directly, applying `a4a_from_bx` where Burgess uses A4a
  - If A4a not derived: implement the alternative seed construction, prove consistency via R3Maximality
- [ ] Construct the seed set and prove its consistency
- [ ] Apply Lindenbaum extension to get MCS D from the seed
- [ ] Prove the required R3Maximal properties of D
- [ ] Close the C4 hard case sorry (CounterexampleElimination.lean:319): apply lemma_2_6_full
- [ ] Close the C4' hard case sorry (CounterexampleElimination.lean:383): mirror
- [ ] Run lake build and verify

**Timing**: 2 hours (if A4a derivable) or 2 hours (if alternative seed, paper proof already done in Phase 4)

**Depends on**: Phase 4

**Files to modify**:
- `Chronicle/PointInsertion.lean` -- lemma_2_6_full implementation
- `Chronicle/CounterexampleElimination.lean` -- C4/C4' hard case closure

**Verification**:
- lemma_2_6_full sorry-free
- C4 hard case sorry-free
- C4' hard case sorry-free
- lake build succeeds
- Sorry count reduction: -3

---

### Phase 6: Final Validation and Cleanup [NOT STARTED]

**Goal**: Verify sorry-free `dd_countermodel_chronicle`, clean up dead code, confirm no regressions.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify only Lean axioms (propfunext, Quot.sound, Classical.choice)
- [ ] Verify zero sorry sites in Chronicle/ directory
- [ ] Remove unused `extended_limit_f` and related non-domain extension code
- [ ] Clean up dead code from earlier approaches (old chronicle_fmcs definition if replaced)
- [ ] Remove Adjacent-related dead comments throughout Chronicle/
- [ ] Verify no regressions: full lake build
- [ ] Verify Soundness, FMP, ParametricTruthLemma remain sorry-free

**Timing**: 2 hours

**Depends on**: Phase 3 (Workstream A complete), Phase 5 (Workstream B complete)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- dead code removal
- `Chronicle/ChronicleTypes.lean` -- comment cleanup
- `Chronicle/CounterexampleElimination.lean` -- comment cleanup

**Verification**:
- lake build succeeds (full clean build)
- Zero sorry sites in Chronicle/ directory
- `#print axioms dd_countermodel_chronicle` clean
- No regressions in other modules

## Testing & Validation

- [ ] lake build succeeds at each phase boundary (7 checkpoints including Phase 0)
- [ ] Phase 0: C4/C4' definitions corrected; forward_G/backward_H sorry-free [DONE]
- [ ] Phase 1: All 5 typeclass instances for limit_dom subtype compile sorry-free
- [ ] Phase 2: cantor_fmcs definition compiles with forward_G/backward_H sorry-free
- [ ] Phase 3: All 8 ChronicleToCountermodel sorry sites closed
- [ ] Phase 4: A4a derivability determination with proof or alternative strategy
- [ ] Phase 5: lemma_2_6_full + C4/C4' hard cases sorry-free
- [ ] Phase 6: `#print axioms dd_countermodel_chronicle` clean; zero sorry in Chronicle/
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)

## Artifacts & Outputs

- `specs/107_.../plans/27_implementation-plan.md` (this file)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (Cantor iso, cantor_fmcs, close 8 sorry sites)
- Modified: `Chronicle/PointInsertion.lean` (lemma_2_6_full implementation)
- Modified: `Chronicle/CounterexampleElimination.lean` (C4/C4' hard case closure)
- Possibly new: `Theorems/A4a.lean` or helper in PointInsertion (if A4a derivation)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 1-3 contingency (Cantor iso)**: If `Order.iso_of_countable_dense` is hard to apply (e.g., universe issues), fall back to manually constructing the bijection using a back-and-forth argument on the countable dense linear orders. This is more work (~4h) but mathematically straightforward.
- **Phase 4-5 contingency (Lemma 2.6)**: If A4a is not derivable AND the alternative seed is intractable, leave the 3 Workstream B sorry sites and ship Workstream A alone. This closes 8 of 11 sorry sites. The C4 hard cases only affect the omega chain's ability to eliminate ALL counterexamples at finite stages; the limit-level C4 is already proved and forward_G works.
- **Budget overrun**: Workstream A (Phases 1-3, 6h) alone closes 8 sorry sites and is well-understood. Workstream B (Phases 4-5, 4h) can be deferred to a subsequent plan if needed.
- **Partial shipping**: If only Workstream A completes, `dd_countermodel_chronicle` still has 3 sorry sites (all in omega chain/PointInsertion), but the critical countermodel wiring is sorry-free.

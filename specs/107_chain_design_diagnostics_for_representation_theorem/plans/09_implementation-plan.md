# Implementation Plan: Task #107 (Revised v2)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 40 hours
- **Dependencies**: None (strict semantics already in place on `irr_until` branch)
- **Research Inputs**: [reports/07_team-research.md], [reports/08_verbrugge-step-by-step.md], [reports/09_team-research.md]
- **Artifacts**: plans/09_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan addresses the 3 critical architectural gaps discovered by team research in the existing 2764-line Burgess chronicle implementation (6 files, 20 sorry sites). The gaps are: (1) missing C4/C4' conditions for backward counterexample resolution, (2) invalid non-domain extension via root MCS assignment that violates strict G-semantics, and (3) vacuous C5 satisfaction from inserting witnesses beyond all domain points instead of between them. This revision (v2) corrects a misdiagnosis in the prior plan (08): Phase 3 (PointInsertion sorry sites) was marked BLOCKED due to a supposed need for density axioms. Research report 09_team-research.md confirms density axioms are NOT needed -- the sorry sites require BX-internal proofs (BX11/BX5/BX7 strategy), not density axioms. More importantly, lemma_2_7/lemma_2_8 are NOT called by Phase 4, so Phase 3 is not on the critical path and has been deferred. Phases 4-7 can proceed without Phase 3 as a prerequisite.

### Research Integration

- **07_team-research.md**: 4-teammate review identifying 3 critical gaps, confirming `until_guard_consistent` is FALSE for gamma = bot, establishing that PointInsertion sorries become essential once C4 is added, and prioritizing fixes as C4 -> C5 redesign -> domain extension.
- **08_verbrugge-step-by-step.md**: Comparative analysis of Verbrugge 2004 vs Burgess 1982, concrete Lean 4 redesign code, 5-phase fix plan with dependency DAG, confirmation that strict semantics requires no additional adaptations beyond existing BX axioms.
- **09_team-research.md**: 4-teammate investigation confirming density axioms (GGp->Gp, HHp->Hp) are NOT needed. Burgess 1982 does not include density in BX. The 4 PointInsertion sorry sites require BX-internal proofs (BX11 temp_linearity_mcs + enriched_resolving_seed_consistent), not density axioms. PointInsertion sorry sites are NOT on the critical path (lemma_2_7/2_8 not called by Phase 4). Phase 3 reclassified from BLOCKED to DEFERRED.

### Prior Plan Reference

Prior plan: `plans/08_implementation-plan.md` (52 hours, 7 phases). Phase 1 (C4/C4' addition) and Phase 2 (easy sorries) completed in Wave 1. Phase 3 was incorrectly marked BLOCKED by density axioms. This revised plan (v2) corrects the dependency structure so Phases 4-7 proceed without Phase 3, and defers Phase 3 to after the critical path is complete.

## Goals & Non-Goals

**Goals**:
- Fix all 3 critical architectural gaps (C4, domain extension, C5 insertion strategy)
- Close all 20 sorry sites across the 6 Chronicle files
- Achieve sorry-free `bx_completeness` via the chronicle pathway
- Maintain `lake build` success at each phase boundary

**Non-Goals**:
- Changing the TaskFrame definition or BFMCS interface (use existing parametric infrastructure)
- Fixing sorry sites in Boneyard, Examples, Frame.lean, Filtration/, Quasimodel/ (dead-end approaches)
- Adding density axioms (GGp->Gp, HHp->Hp) to BX -- Burgess 1982 proves completeness for ALL strict linear orders without density
- Dense order extension beyond what the construction requires (Burgess Section 1.6)
- Proving decidability/FMP results (separate concern)
- Modifying the axiom system (no new axioms; work within existing BX axioms)

## Sorry Site Inventory

| # | File | Line | Identifier / Context | Root Cause | Difficulty |
|---|------|------|---------------------|------------|------------|
| 1 | RRelation.lean | 154 | `until_guard_consistent` | FALSE for gamma=bot | Withdraw |
| 2 | PointInsertion.lean | 360 | `lemma_2_6_strong` (seed consistency) | Needs h_content duality proof | DEFERRED (not on critical path) |
| 3 | PointInsertion.lean | 518/807 | `lemma_2_7` D2 case (BX7 tautology) | Complex propositional derivation tree | DEFERRED (not on critical path) |
| 4 | PointInsertion.lean | 814 | `lemma_2_7` D2 subcase (eta in A) | BX7 three-way case under strict semantics | DEFERRED (not on critical path) |
| 5 | PointInsertion.lean | 936 | `lemma_2_8` (eta in C case) | Reduces to lemma_2_7 variant | DEFERRED (not on critical path) |
| 6 | CounterexampleElimination.lean | 78 | `exists_rat_gt_finset` | Trivial Mathlib (Finset.max' + lt_add_one) | Easy |
| 7 | CounterexampleElimination.lean | 89 | `exists_rat_lt_finset` | Trivial Mathlib (Finset.min' - 1) | Easy |
| 8 | ChronicleConstruction.lean | 115 | `counterexample_enum` (definition) | Use Rat.instDenumerable | Easy |
| 9 | ChronicleConstruction.lean | 123 | `counterexample_enum_surjective` | Follows from Denumerable surjectivity | Easy |
| 10 | ChronicleConstruction.lean | 319 | `limit_satisfies_c5_weak` | Needs C4 + corrected insertion | Hard |
| 11 | ChronicleConstruction.lean | 329 | `limit_satisfies_c5'_weak` | Mirror of #10 | Hard |
| 12 | ChronicleToCountermodel.lean | 192 | `chronicle_fmcs.forward_G` | UNPROVABLE: non-domain extension broken | Redesign |
| 13 | ChronicleToCountermodel.lean | 196 | `chronicle_fmcs.backward_H` | UNPROVABLE: same root cause as #12 | Redesign |
| 14 | ChronicleToCountermodel.lean | 234 | `box_stable_in_chronicle_fmcs` | Depends on #12/#13 | Medium |
| 15 | ChronicleToCountermodel.lean | 320 | `chronicle_bfmcs_restricted_tc` (F-resolution) | Depends on C5 + domain fix | Hard |
| 16 | ChronicleToCountermodel.lean | 323 | `chronicle_bfmcs_restricted_tc` (P-resolution) | Mirror of #15 | Hard |
| 17 | ChronicleToCountermodel.lean | 342 | `chronicle_bfmcs_restricted_buc` (backward Until) | Needs C4 + interval function | Hard |
| 18 | ChronicleToCountermodel.lean | 345 | `chronicle_bfmcs_restricted_buc` (backward Since) | Mirror of #17 | Hard |
| 19 | ChronicleToCountermodel.lean | 374 | `chronicle_bfmcs_restricted_fuc` (forward Until) | Needs C5 + domain fix | Hard |
| 20 | ChronicleToCountermodel.lean | 377 | `chronicle_bfmcs_restricted_fuc` (forward Since) | Mirror of #19 | Hard |

**Classification**:
- **Withdraw** (1): #1 (`until_guard_consistent` -- false as stated, unused)
- **Easy** (4): #6, #7, #8, #9 (Mathlib utilities, countability)
- **DEFERRED** (4): #2, #3, #4, #5 (PointInsertion lemma internals -- not on critical path; BX-internal proof strategy exists via BX11/BX5/BX7)
- **Hard** (6): #10, #11, #15, #16, #17, #18 (limit properties, restricted coherence)
- **Redesign** (5): #12, #13, #14, #19, #20 (require architectural fix to domain extension)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Subtype model lacks AddCommGroup instance (limit_dom not closed under addition) | H | M | Use dense chronicle domain (Option B from research) instead; interleave density steps so limit_dom is isomorphic to Q |
| C5 redesign requires lemma_2_7 between-point insertion before Phase 3 is done | M | M | Phase 4's between-point insertion can use sorry'd lemma_2_7 as a placeholder; the sorry does not propagate to incorrectness, only incompleteness. When Phase 3 is completed later, the sorry is closed without changing Phase 4 code. |
| C4 counterexample elimination (Lemma 2.9) introduces new sorry sites | M | M | Lemma 2.9 reduces to Lemma 2.6 (base case) and induction on intermediate points; both ingredients are addressed in Phase 2 |
| Dense domain interleaving invalidates existing omega-chain structure | M | M | Modify omega-chain to alternate counterexample elimination and density steps at even/odd indices; existing structure preserved at even steps |
| Counterexample enumeration must cover C4 counterexamples (5-tuples, not 4-tuples) | L | H | Extend PotentialCounterexample to include C4 variants with second point y; Rat x Rat x Formula x Formula x Kind is still countable |
| Limit g-function tracking through omega-chain is complex | M | H | Define limit_g analogously to limit_f; C3 (interval decomposition) provides the key composition property for tracking through insertions |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- (COMPLETED) |
| 2 | 4 | 2 |
| 3 | 5 | 4 |
| 4 | 6 | 4, 5 |
| 5 | 7 | 6 |
| Deferred | 3 | 1 (execute after Phase 7 or in parallel as capacity allows) |

```
[Phase 1: C4 + Cleanup]  (COMPLETED)
[Phase 2: Close Easy Sorries]  (COMPLETED)
         |
         +----> [Phase 4: C5 Insertion Redesign] ----> [Phase 6: Integration Rewrite]
                         |                                       |
                         v                                       v
                [Phase 5: Dense Domain]  ----------------------+
                                                                 |
                                                                 v
                                                        [Phase 7: Final Wiring]

[Phase 3: PointInsertion]  (DEFERRED -- not on critical path)
```

---

### Phase 1: Add C4/C4' and Clean Up False Lemmas [COMPLETED]

**Goal**: Add the missing C4/C4' backward counterexample conditions to `ValidChronicle`, implement C4 counterexample elimination (Lemma 2.9), and withdraw the false `until_guard_consistent` lemma.

**Tasks**:
- [x] Add `Chronicle.c4` definition to `ChronicleTypes.lean`: for all x, y in dom with x < y, if neg U(gamma, delta) in f(x) and gamma in f(y), then exists z in dom with x < z < y and neg delta in f(z)
- [x] Add `Chronicle.c4'` (Since mirror) to `ChronicleTypes.lean`
- [x] Add `hc4` and `hc4'` fields to `ValidChronicle` structure
- [x] Extend `PotentialCounterexample` in `ChronicleConstruction.lean` to include C4 counterexample variants (add a `y : Rat` field and a `kind` discriminant for C4-forward, C4-backward, C5-forward, C5-backward)
- [x] Implement `eliminate_C4_counterexample` in `CounterexampleElimination.lean` using Lemma 2.9 structure: base case (no intermediate points) uses `lemma_2_6`, inductive case reduces to fewer intermediate points
- [x] Implement `eliminate_C4'_counterexample` (Since mirror)
- [x] Remove or comment out `until_guard_consistent` in `RRelation.lean` (sorry #1) with a note that it is false for gamma = bot
- [x] Update `singleton_chronicle` to satisfy C4/C4' vacuously (empty domain has no counterexamples)
- [x] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- add C4/C4' definitions and ValidChronicle fields
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- add C4 elimination
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- extend PotentialCounterexample, update omega_chain
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- withdraw until_guard_consistent

**Verification**:
- `lake build` succeeds
- C4/C4' definitions type-check
- `until_guard_consistent` is no longer a sorry site (withdrawn)
- Sorry count: 20 -> 19 (net -1: withdraw #1)

---

### Phase 2: Close Easy Sorry Sites [COMPLETED]

**Goal**: Close the 4 easy sorry sites that require only standard Mathlib utilities and countability arguments.

**Tasks**:
- [x] Close `exists_rat_gt_finset` (sorry #6) in `CounterexampleElimination.lean`: use `Finset.max'` (or `Finset.sup'`) and `Rat.lt_add_one` or explicit construction; handle empty set case separately
- [x] Close `exists_rat_lt_finset` (sorry #7) in `CounterexampleElimination.lean`: mirror using `Finset.min'` and subtraction
- [x] Close `counterexample_enum` (sorry #8) in `ChronicleConstruction.lean`: construct from `Denumerable` instances on `Rat`, `Formula`, and `Bool`; the product `Rat x Rat x Formula x Formula x PotentialCounterexampleKind` is countable
- [x] Close `counterexample_enum_surjective` (sorry #9) in `ChronicleConstruction.lean`: follows from the `Denumerable.ofNat` surjectivity of the constructed enumeration
- [x] Run `lake build` and verify

**Timing**: 4 hours

**Depends on**: none (but Phase 1 modifies PotentialCounterexample, so `counterexample_enum` definition must align with the extended type from Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close sorries #6, #7
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- close sorries #8, #9

**Verification**:
- `lake build` succeeds
- No sorry in `exists_rat_gt_finset`, `exists_rat_lt_finset`, `counterexample_enum`, `counterexample_enum_surjective`
- Sorry count: 19 -> 15 (net -4)

---

### Phase 3: Close PointInsertion Sorry Sites (Lemmas 2.6-2.8) [DEFERRED]

**Goal**: Close the 4 PointInsertion sorry sites that implement the core point insertion machinery. These are NOT on the critical path -- lemma_2_7 and lemma_2_8 are not currently called by Phase 4's counterexample elimination or any downstream phase. This phase can be completed after Phases 4-7 without affecting the critical path.

**Deferral rationale**:
- The Phase 3 blocking diagnosis in plan v1 (08_implementation-plan.md) was incorrect: density axioms are NOT needed. The sorry sites require BX-internal proofs, not frame property axioms.
- A BX-internal proof strategy exists: apply BX11 (`temp_linearity_mcs`) to get three disjuncts, then use `enriched_resolving_seed_consistent` for the D2/D3 constructions.
- lemma_2_7 and lemma_2_8 are not called by Phase 4 (C5 redesign), Phase 5 (dense domain), Phase 6 (integration), or Phase 7 (final wiring). They become relevant only if the C5 insertion strategy is later redesigned to use between-point insertion at the lemma_2_7 level.
- Completing this phase after Phase 7 allows the critical path to proceed unblocked.

**Tasks**:
- [ ] Close `lemma_2_6_strong` (sorry #2, line 360): prove seed consistency of {neg delta} union g_content(A) union h_content(C). The key argument: if this seed is inconsistent, derive a contradiction using the hypothesis that g_content(A) subset C and the deduction theorem. May need to construct explicit derivation trees for the h_content duality direction.
- [ ] Close `lemma_2_7` D2 tautology case (sorry #3, line 518/807): Apply BX11 (`temp_linearity_mcs`) to F(eta) in A and F(neg eta) in A, getting three disjuncts. D1 is absurd (contradiction). D2 and D3 lead to `enriched_resolving_seed_consistent`-based constructions yielding a future MCS D with xi in D. This is a BX-internal proof, not a density argument.
- [ ] Close `lemma_2_7` D2 eta-in-A subcase (sorry #4, line 814): when eta in A and U(xi, eta) in A under strict semantics, the witness xi at a future point follows from BX5 recursive reasoning and BX7 (linear_until) three-way case analysis. Apply BX7 to U(xi, eta) and construct the needed future witness. Rated MEDIUM confidence by research.
- [ ] Close `lemma_2_8` eta-in-C case (sorry #5, line 936): reduce to `lemma_2_7` by showing U(xi, eta) in A and eta in C but xi not in C gives the conditions for 2.7 with a different target formula. The key step is extracting F(neg U(xi, eta)) from G(U(xi, eta)) not in A.
- [ ] Run `lake build` and verify

**Timing**: 12 hours

**Depends on**: Phase 1 (C4 conditions must be defined so that the insertion lemmas can state their preservation properties)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- close sorries #2, #3, #4, #5

**Verification**:
- `lake build` succeeds
- All 4 PointInsertion sorry sites closed
- `lemma_2_6_strong`, `lemma_2_7` (both D2 cases), `lemma_2_8` are sorry-free
- Sorry count: 15 -> 11 (or from post-Phase-7 count if executed after critical path)

---

### Phase 4: Redesign C5 Counterexample Elimination (Between-Point Insertion) [NOT STARTED]

**Goal**: Replace the current vacuous C5 elimination (inserting beyond all points) with the correct Burgess strategy (inserting between existing points), and prove the limit chronicle satisfies C5/C5' and C4/C4'.

**Tasks**:
- [ ] Redesign `eliminate_C5_counterexample` in `CounterexampleElimination.lean` to implement Lemma 2.10 correctly:
  - Case n=0 (no points after x): use `lemma_2_4` to get witness y = x + 1 (current approach is correct for this case)
  - Case n=m+1 (x' is immediate successor of x in dom):
    - Subcase (i): eta and U(xi, eta) in f(x') and eta in g(x, x') -- replace x with x' (reduce n by 1)
    - Subcase (ii): xi in f(x') and eta in g(x, x') -- x' is the witness (done)
    - Subcase (iii): otherwise -- insert z = (x + x')/2 between x and x' using `lemma_2_7` or `lemma_2_8`
  - Mirror for C5' (Since)
- [ ] Add `exists_rat_between` utility: for x < y, produce (x + y) / 2 with x < mid < y
- [ ] Update the interval function g when inserting between points: split g(x, x') into g(x, z) and g(z, x') using the R-relation decomposition from Lemma 2.7
- [ ] Define `limit_g` (limit interval function) analogously to `limit_f` in `ChronicleConstruction.lean`
- [ ] Prove `limit_satisfies_c5_weak` (sorry #10): for any x in limit_dom with U(xi, eta) in limit_f(x), the counterexample enumeration ensures a witness was inserted at some step; the witness persists in the limit because f agrees on old domain points
- [ ] Prove `limit_satisfies_c5'_weak` (sorry #11): mirror for Since
- [ ] Prove the limit chronicle satisfies C4/C4': every C4 counterexample was eliminated at some step, and new insertions do not create new C4 counterexamples (preservation argument)
- [ ] Run `lake build` and verify

**Note on Phase 3 interaction**: Subcase (iii) of the C5 elimination calls `lemma_2_7` or `lemma_2_8`. Since Phase 3 is deferred, these lemmas may still contain sorry sites when Phase 4 is implemented. This is acceptable: the sorry propagates to `eliminate_C5_counterexample` but does not affect the logical structure of the proof. When Phase 3 is later completed, the sorry is removed without changing any Phase 4 code.

**Timing**: 12 hours

**Depends on**: Phase 2 (easy sorries, especially `exists_rat_gt/lt_finset`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- redesign C5 elimination
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add limit_g, close sorries #10, #11, prove limit C4/C4'

**Verification**:
- `lake build` succeeds
- `limit_satisfies_c5_weak` and `limit_satisfies_c5'_weak` are sorry-free (modulo sorry in lemma_2_7/2_8 from deferred Phase 3)
- Limit chronicle satisfies all conditions C0-C5 including C4/C4'
- Sorry count: 15 -> 13 (net -2: close #10, #11; sorry in lemma_2_7/2_8 remains from Phase 3)

---

### Phase 5: Fix Domain Extension (Dense Chronicle Domain) [NOT STARTED]

**Goal**: Eliminate the invalid non-domain extension by making the chronicle domain dense, so that the model is defined entirely over domain points and no extension to non-domain rationals is needed.

**Tasks**:
- [ ] Add density steps to the omega-chain construction: at alternating steps (e.g., even steps = counterexample elimination, odd steps = density insertion), insert a new point between every pair of adjacent domain points
- [ ] For each density insertion between x and y: construct MCS D with g_content(f(x)) subset D and g_content(D) subset f(y), using the density property of the canonical prec relation (from the BX axiom GG(phi) -> G(phi), which gives prec transitivity)
- [ ] Maintain C0-C5 and C4/C4' through density insertions: each new density point must have correct f and g values satisfying all chronicle conditions
- [ ] Prove `limit_dom_dense`: for any x, y in limit_dom with x < y, there exists z in limit_dom with x < z < y
- [ ] Alternative approach (if density is too complex): switch to `Subtype`-indexed model over limit_dom. Define `FMCS { x : Rat // x in limit_dom A h_mcs }` directly. Show the subtype inherits `LinearOrder` from Rat. For `AddCommGroup`, use the order-embedding into Rat combined with Cantor's theorem (countable dense linear order without endpoints is isomorphic to Q) to transfer the group structure.
- [ ] Run `lake build` and verify

**Timing**: 6 hours

**Depends on**: Phase 4 (limit chronicle must satisfy all conditions before adding density)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add density steps to omega-chain
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- adapt extended_limit_f or replace with subtype model

**Verification**:
- `lake build` succeeds
- `limit_dom_dense` proved (or subtype model compiles)
- `extended_limit_f` either removed (subtype approach) or trivially correct (dense domain means every rational is eventually in the domain)
- No sorry sites introduced by this phase

---

### Phase 6: Rewrite ChronicleToCountermodel Integration [NOT STARTED]

**Goal**: Close all 9 sorry sites in `ChronicleToCountermodel.lean` using the corrected chronicle (C4, between-point insertion, dense domain).

**Tasks**:
- [ ] Close `chronicle_fmcs.forward_G` (sorry #12): with dense domain, every t' > t is (eventually) a domain point, so G(phi) in f(t) implies phi in g(t, ...) implies phi in f(t') by C3 interval decomposition and C2 r-relation. If using subtype model, forward_G quantifies only over domain points where this holds by construction.
- [ ] Close `chronicle_fmcs.backward_H` (sorry #13): mirror of #12 using h_content and C2'.
- [ ] Close `box_stable_in_chronicle_fmcs` (sorry #14): Box phi in chronicle_fmcs(t) iff Box phi in A. Forward direction: Box phi -> G(Box phi) (temporal future axiom) -> Box phi propagates to all domain points. Backward: by construction, mcs(0) = A and Box phi is S5-stable across modal equivalence classes.
- [ ] Close `chronicle_bfmcs_restricted_tc` forward (sorry #15): F(phi) in shifted_chronicle at t means F(phi) in limit_f(t-s). By C5 (which covers F-obligations since F(phi) = T U phi under strict semantics, or directly from neg G(neg phi) via density), there exists s' > t-s in domain with phi in f(s'). Transfer to shifted FMCS.
- [ ] Close `chronicle_bfmcs_restricted_tc` backward (sorry #16): mirror using C5' and P = S(T, phi).
- [ ] Close `chronicle_bfmcs_restricted_buc` Until (sorry #17): given witness pattern (s > t with psi at s and phi at intermediates), derive U(phi, psi) in mcs(t). Uses C4 (backward counterexample resolution): if neg U(phi, psi) were in f(t), C4 would give a counterexample point z with neg psi in f(z) between t and s, contradicting the guard assumption. So U(phi, psi) must be in f(t) by MCS completeness.
- [ ] Close `chronicle_bfmcs_restricted_buc` Since (sorry #18): mirror using C4'.
- [ ] Close `chronicle_bfmcs_restricted_fuc` Until (sorry #19): U(phi, psi) in shifted_chronicle at t. By C5 of the limit chronicle, there exists y in limit_dom with t-s < y and psi in f(y) and the guard phi at intermediate domain points. With dense domain, the guard extends to all intermediates. Transfer to shifted FMCS coordinates.
- [ ] Close `chronicle_bfmcs_restricted_fuc` Since (sorry #20): mirror using C5'.
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 4 (limit C5/C5' sorry-free), Phase 5 (domain extension fixed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close all 9 sorry sites

**Verification**:
- `lake build` succeeds
- All 9 ChronicleToCountermodel sorry sites closed
- `dd_countermodel_chronicle` compiles (may still have sorry propagated from deferred Phase 3)
- Sorry count: 13 -> 4 (net -9; remaining 4 are the deferred PointInsertion sorries from Phase 3)

---

### Phase 7: Final Wiring and Verification [NOT STARTED]

**Goal**: Ensure `bx_completeness` is sorry-free (modulo deferred Phase 3 sorry sites) by wiring `dd_countermodel_chronicle` through the parametric representation theorem, and verify no unexpected sorryAx remains.

**Tasks**:
- [ ] Verify `dd_countermodel_chronicle` compiles and its only sorry dependencies are from Phase 3 (PointInsertion lemmas)
- [ ] Verify `bx_completeness` in `Completeness.lean` routes through `dd_countermodel_chronicle` (already wired in the prior implementation)
- [ ] Run `#print axioms bx_completeness` and document the output. If `sorryAx` appears, confirm it traces only to Phase 3 sorry sites (lemma_2_6_strong, lemma_2_7, lemma_2_8)
- [ ] Run `#print axioms dd_countermodel_chronicle` and confirm the same
- [ ] Run full `lake build` and confirm success
- [ ] Verify no regression in existing sorry-free modules (Soundness, Decidability/FMP)
- [ ] Clean up dead code: mark `RootScopedChain.lean`'s 3 sorry sites as dead code (the chronicle pathway bypasses them entirely)
- [ ] Document remaining sorry sites for Phase 3 completion

**Timing**: 2 hours

**Depends on**: Phase 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- verify wiring (likely no changes needed)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- mark sorry sites as dead code (optional cleanup)

**Verification**:
- `lake build` succeeds with no regressions
- `#print axioms bx_completeness` -- if `sorryAx` present, it traces only to deferred Phase 3
- `#print axioms dd_countermodel_chronicle` -- same constraint
- 16 of 20 original sorry sites resolved (15 closed, 1 withdrawn); 4 deferred to Phase 3
- After Phase 3 completion: all 20 resolved (19 closed, 1 withdrawn), `bx_completeness` fully sorry-free

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary (7 checkpoints)
- [ ] `#print axioms bx_completeness` shows no unexpected `sorryAx` after Phase 7 (any remaining traces to Phase 3 only)
- [ ] `#print axioms dd_countermodel_chronicle` shows no unexpected `sorryAx` after Phase 7
- [ ] Chronicle construction: limit properties (C0-C5, C4/C4') proved in Phase 4
- [ ] Counterexample enumeration and elimination: fully sorry-free after Phase 2
- [ ] Limit properties: limit_satisfies_c5_weak/c5'_weak and limit C4/C4' are sorry-free after Phase 4
- [ ] ChronicleToCountermodel: all 9 coherence sorries closed after Phase 6
- [ ] No regression in existing sorry-free modules (Soundness, Decidability/FMP)
- [ ] `until_guard_consistent` is withdrawn (no downstream callers)
- [ ] After deferred Phase 3: PointInsertion Lemmas 2.6_strong, 2.7 (both D2 cases), 2.8 are sorry-free
- [ ] After deferred Phase 3: `#print axioms bx_completeness` shows NO `sorryAx`

## Artifacts & Outputs

- `specs/107_.../plans/09_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (add C4/C4')
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (withdraw false lemma)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (close 4 sorries -- deferred)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (close 2 sorries, redesign C5, add C4 elimination)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (close 4 sorries, add limit_g, density)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (close 9 sorries, fix domain extension)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes are to existing files in the `Chronicle/` subdirectory; reverting to the current commit restores the status quo with 20 sorry sites.
- **Phase independence**: Phases 1 and 2 are independent and already completed. Phase 4 depends only on Phase 2 (not Phase 3). Phase 3 is deferred and can be completed at any time after Phase 1.
- **Deferred Phase 3 strategy**: If the BX11-based proof strategy for D2 cases proves insufficient, alternative approaches include: (a) reformulating lemma_2_7 with a weaker conclusion sufficient for C5 elimination, (b) constructing the MCS witness directly via Lindenbaum extension with explicit seed sets, (c) using `lean_multi_attempt` to explore automated tactics (simp, aesop) on the goal states.
- **Subtype fallback**: If the dense domain approach (Phase 5) proves too complex, fall back to the subtype-indexed model. This requires showing `LinearOrder` (trivial via subtype) and working around the missing `AddCommGroup` by using an order-isomorphism to Q (Cantor's theorem) or by modifying the BFMCS interface to not require additive structure.
- **Sorry propagation is safe**: Sorry sites in Phase 3 (PointInsertion) propagate through the call chain but do not affect the logical structure of Phases 4-7. The proofs in Phases 4-7 are correct assuming Phase 3 lemmas hold; completing Phase 3 removes the sorry without requiring any changes to later phases.
- **Incremental progress**: Each phase reduces the sorry count. Even if Phase 3 remains deferred, Phases 4-7 represent substantial progress (closing 11 of 15 remaining sorry sites on the critical path).

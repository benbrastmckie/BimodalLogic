# Implementation Plan: Task #107 (v3 -- Rewritten)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IMPLEMENTING]
- **Effort**: 48 hours
- **Dependencies**: None (strict semantics already in place on `irr_until` branch)
- **Research Inputs**: [reports/07_team-research.md], [reports/08_verbrugge-step-by-step.md], [reports/09_team-research.md]
- **Artifacts**: plans/09_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan targets sorry-free `bx_completeness` via the Burgess chronicle construction over rationals. The existing implementation (6 files, ~2764 lines) has 17 remaining sorry sites after Phases 1-2 closed 4 easy sorries, withdrew 1 false lemma, and added C4/C4' conditions (introducing 2 new C4-elimination sorries). The 3 critical architectural gaps are: (1) vacuous C5 satisfaction from endpoint insertion, (2) invalid `extended_limit_f` that assigns root MCS to non-domain rationals, and (3) incomplete PointInsertion lemmas (2.6-2.8) needed for between-point insertion. This rewrite corrects the ordering error of prior plans: PointInsertion (lemmas 2.7/2.8) IS a prerequisite for C5 redesign (Lemma 2.10 subcase iii), and the dense domain / subtype model fix must precede the integration rewrite so that forward_G becomes provable. Density axioms are NOT needed -- all sorry sites require BX-internal proofs.

### Research Integration

- **07_team-research.md**: Identified 3 critical architectural gaps (C4 missing, non-domain extension broken, vacuous C5). Confirmed `until_guard_consistent` is FALSE. PointInsertion sorries become essential once C5 is redesigned to insert between points.
- **08_verbrugge-step-by-step.md**: Verbrugge 2004 comparative analysis. Key insight: insert witnesses BETWEEN existing points using non-branching property. Lemma 2.10 induction on intermediate points. Dense domain eliminates non-domain extension. Strict semantics compatible with no modifications.
- **09_team-research.md**: Confirmed density axioms (GGp->Gp, HHp->Hp) are NOT needed. The 4 PointInsertion sorry sites require BX-internal proofs: BX11 (`temp_linearity_mcs`) for D2 guard, BX5 recursive + BX9 case split for D2 witness, lemma_2_8 reduces to lemma_2_7. Burgess 1982 proves completeness for ALL strict linear orders without density.

### Prior Plan Reference

Prior plans: `plans/08_implementation-plan.md` (v2, 7 phases) and `plans/09_implementation-plan.md` (v3, 7 phases with Phase 3 deferred). Phase 3 was first marked BLOCKED (incorrectly, due to density axiom misdiagnosis) then DEFERRED (incorrectly, because the C5 redesign in Phase 4 actually calls lemma_2_7/2_8 in subcase iii). This rewrite places PointInsertion before C5 redesign, which is the mathematically correct ordering.

## Goals & Non-Goals

**Goals**:
- Close all 17 remaining sorry sites across 4 Chronicle files
- Achieve sorry-free `bx_completeness` via the chronicle pathway
- Maintain `lake build` success at each phase boundary
- Correct the phase ordering so each phase builds on its predecessors without forward dependencies

**Non-Goals**:
- Changing the TaskFrame definition or BFMCS interface (use existing parametric infrastructure)
- Adding density axioms (GGp->Gp, HHp->Hp) -- Burgess proves completeness for ALL strict linear orders
- Fixing sorry sites in Boneyard, Frame.lean, Filtration/, Quasimodel/ (dead-end approaches)
- Proving decidability/FMP results (separate concern)
- Modifying the axiom system (no new axioms; work within existing BX axioms)

## Sorry Site Inventory

| # | File | Line | Identifier / Context | Root Cause | Phase |
|---|------|------|---------------------|------------|-------|
| 1 | PointInsertion.lean | 360 | `lemma_2_6_strong` (seed consistency) | h_content duality proof | 3 |
| 2 | PointInsertion.lean | 807 | `lemma_2_7` D2 guard (BX11 strategy) | BX11 three-disjunct case analysis | 3 |
| 3 | PointInsertion.lean | 814 | `lemma_2_7` D2 witness (eta in A) | BX5 recursive + BX9 case split | 3 |
| 4 | PointInsertion.lean | 936 | `lemma_2_8` (eta in C case) | Reduces to lemma_2_7 with modified target | 3 |
| 5 | CounterexampleElimination.lean | 271 | `eliminate_C4_counterexample` | Depends on lemma_2_6_strong | 4 |
| 6 | CounterexampleElimination.lean | 287 | `eliminate_C4'_counterexample` | Mirror of #5 | 4 |
| 7 | ChronicleConstruction.lean | 373 | `limit_satisfies_c5_weak` | Needs corrected C5 insertion + limit tracking | 5 |
| 8 | ChronicleConstruction.lean | 383 | `limit_satisfies_c5'_weak` | Mirror of #7 | 5 |
| 9 | ChronicleToCountermodel.lean | 192 | `chronicle_fmcs.forward_G` | UNPROVABLE with current `extended_limit_f` | 7 |
| 10 | ChronicleToCountermodel.lean | 196 | `chronicle_fmcs.backward_H` | Mirror of #9 | 7 |
| 11 | ChronicleToCountermodel.lean | 234 | `box_stable_in_chronicle_fmcs` | Depends on #9/#10 | 7 |
| 12 | ChronicleToCountermodel.lean | 320 | `chronicle_bfmcs_restricted_tc` (F) | Depends on C5 + domain fix | 7 |
| 13 | ChronicleToCountermodel.lean | 323 | `chronicle_bfmcs_restricted_tc` (P) | Mirror of #12 | 7 |
| 14 | ChronicleToCountermodel.lean | 342 | `chronicle_bfmcs_restricted_buc` (Until) | Needs C4 + interval function | 7 |
| 15 | ChronicleToCountermodel.lean | 345 | `chronicle_bfmcs_restricted_buc` (Since) | Mirror of #14 | 7 |
| 16 | ChronicleToCountermodel.lean | 374 | `chronicle_bfmcs_restricted_fuc` (Until) | Needs C5 + domain fix | 7 |
| 17 | ChronicleToCountermodel.lean | 377 | `chronicle_bfmcs_restricted_fuc` (Since) | Mirror of #16 | 7 |

**By file**:
- PointInsertion.lean: 4 sorries (#1-4) -- Phase 3
- CounterexampleElimination.lean: 2 sorries (#5-6) -- Phase 4
- ChronicleConstruction.lean: 2 sorries (#7-8) -- Phase 5
- ChronicleToCountermodel.lean: 9 sorries (#9-17) -- Phases 6-7

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 2.7 D2 guard case (BX11 strategy) is harder than expected | H | M | Teammate C's analysis provides concrete disjunct-by-disjunct strategy. If BX11 application is blocked, try direct Lindenbaum extension of g_content seed with neg delta. |
| Lemma 2.7 D2 witness case (eta in A, BX5 recursive) rated MEDIUM confidence | H | M | BX5 gives U(xi, eta) -> U(xi and U(xi,eta), eta). Combined with BX9 (U(p,q) -> p or q), construct witness by MCS case analysis. Fallback: reformulate with weaker conclusion sufficient for Lemma 2.10. |
| Subtype model for limit_dom lacks AddCommGroup instance | H | M | Use dense chronicle domain (Option B from report 08): interleave density insertions so limit_dom becomes countable dense linear order isomorphic to Q. Alternative: modify BFMCS interface to not require additive structure. |
| C5 redesign (between-point insertion) introduces complex induction | M | H | Lemma 2.10 induction on number of points after x is well-founded via Finset.card. Cases (i) and (ii) are direct; case (iii) reduces to lemma_2_7/2_8 which will be sorry-free from Phase 3. |
| Limit g-function tracking through omega-chain is complex | M | H | Define limit_g analogously to limit_f. C3 (interval decomposition) provides the composition property. Each insertion step maintains g locally; the limit inherits by union. |
| Dense domain interleaving invalidates existing omega-chain structure | M | M | Use even steps for counterexample elimination, odd steps for density insertion. Existing structure preserved at even steps. Density step uses Lemma 2.6 machinery (already available from Phase 3). |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2 | -- (COMPLETED) |
| 1 | 3 | -- |
| 2 | 4 | 3 |
| 3 | 5 | 4 |
| 4 | 6 | 5 |
| 5 | 7 | 6 |
| 6 | 8 | 7 |

```
[Phase 1: C4/C4' + Cleanup]  (COMPLETED)
[Phase 2: Close Easy Sorries]  (COMPLETED)

[Phase 3: PointInsertion Lemmas 2.6-2.8]
         |
         v
[Phase 4: C4 Elimination + C5 Redesign]
         |
         v
[Phase 5: Limit Properties (C5/C5')]
         |
         v
[Phase 6: Dense Domain / Subtype Model]
         |
         v
[Phase 7: Integration Rewrite (ChronicleToCountermodel)]
         |
         v
[Phase 8: Final Wiring + Verification]
```

---

### Phase 1: Add C4/C4' and Clean Up False Lemmas [COMPLETED]

**Goal**: Add the missing C4/C4' backward counterexample conditions to `ValidChronicle`, add C4 counterexample structures, and withdraw the false `until_guard_consistent` lemma.

**Tasks**:
- [x] Add `Chronicle.c4` and `Chronicle.c4'` definitions to `ChronicleTypes.lean`
- [x] Add `hc4` and `hc4'` fields to `ValidChronicle` structure
- [x] Extend `PotentialCounterexample` to include C4 counterexample variants (kind discriminant for C4-forward, C4-backward, C5-forward, C5-backward)
- [x] Add `C4Counterexample` and `C4'Counterexample` structures to `CounterexampleElimination.lean`
- [x] Implement `eliminate_C4_counterexample` and `eliminate_C4'_counterexample` (sorry'd pending lemma_2_6_strong)
- [x] Withdraw `until_guard_consistent` in `RRelation.lean` (false for gamma = bot)
- [x] Update `singleton_chronicle` to satisfy C4/C4' vacuously
- [x] `lake build` succeeds

**Timing**: 8 hours (actual)

**Depends on**: none

**Files modified**:
- `Chronicle/ChronicleTypes.lean` -- C4/C4' definitions, ValidChronicle fields
- `Chronicle/CounterexampleElimination.lean` -- C4 structures and elimination stubs
- `Chronicle/ChronicleConstruction.lean` -- PotentialCounterexample extension
- `Chronicle/RRelation.lean` -- until_guard_consistent withdrawn

**Verification**:
- `lake build` succeeded
- C4/C4' type-check, `until_guard_consistent` withdrawn
- Sorry delta: -1 withdrawn, +2 new C4 elimination sorries = net +1 (20 -> 21, then see Phase 2)

---

### Phase 2: Close Easy Sorry Sites [COMPLETED]

**Goal**: Close the 4 easy sorry sites requiring standard Mathlib utilities and countability arguments.

**Tasks**:
- [x] Close `exists_rat_gt_finset` using `Finset.max'` + rational arithmetic
- [x] Close `exists_rat_lt_finset` using `Finset.min'` + rational arithmetic
- [x] Close `counterexample_enum` using `Denumerable` instances on product type
- [x] Close `counterexample_enum_surjective` using `Denumerable.ofNat` surjectivity
- [x] `lake build` succeeds

**Timing**: 4 hours (actual)

**Depends on**: Phase 1 (PotentialCounterexample type extended)

**Files modified**:
- `Chronicle/CounterexampleElimination.lean` -- closed 2 sorries
- `Chronicle/ChronicleConstruction.lean` -- closed 2 sorries

**Verification**:
- `lake build` succeeded
- 4 sorry sites closed
- Sorry count after Phase 2: 17 remaining

---

### Phase 3: Close PointInsertion Sorry Sites (Lemmas 2.6-2.8) [BLOCKED]

**Goal**: Close the 4 PointInsertion sorry sites that implement the core between-point insertion machinery. These lemmas are prerequisites for C4 elimination (Phase 4) and C5 redesign (Phase 4), which use lemma_2_6/2_7/2_8 to insert points between existing domain points.

**Why this must come before Phase 4**: The C4 elimination functions (`eliminate_C4_counterexample`, line 271) explicitly reduce to `lemma_2_6_strong`. The C5 redesign (Lemma 2.10, subcase iii) calls `lemma_2_7` or `lemma_2_8` to insert a point between x and its immediate successor. If these lemmas remain sorry'd, Phase 4 cannot produce sorry-free elimination functions, and the sorry propagates all the way to `bx_completeness`.

**Tasks**:
- [ ] Close `lemma_2_6_strong` (sorry #1, line 360): prove consistency of the seed set `{neg delta} union g_content(A) union h_content(C)`. Strategy: if this seed is inconsistent, then `L ⊢ bot` for some finite L in the seed. By the deduction theorem and the hypothesis `g_content(A) ⊆ C`, derive a contradiction with `delta not in C`. The h_content duality direction may require explicit derivation trees for temporal axioms (BX4 connect_future).
- [ ] Close `lemma_2_7` D2 guard case (sorry #2, line 807): Apply BX11 (`temp_linearity_mcs`) to `F(eta) in A` and `F(neg eta) in A`, yielding three disjuncts. D1 gives `F(eta and neg eta) in A`, which is absurd (eta and neg eta is inconsistent, so G(neg(eta and neg eta)) is provable, hence in A, contradicting F(eta and neg eta)). D2 and D3 lead to `enriched_resolving_seed_consistent`-based constructions yielding a future MCS D with `xi in D` and `g_content(A) subset D`.
- [ ] Close `lemma_2_7` D2 witness case (sorry #3, line 814): when `eta in A` and `U(xi, eta) in A` under strict semantics. Apply BX5 to get `U(xi and U(xi,eta), eta) in A`. Apply BX9 case split: either `xi and U(xi,eta)` or `eta` holds at the future point. Since `eta in A` already, the witness at a strictly future point requires BX7 (linear_until) three-way analysis to extract `xi` at an intermediate point.
- [ ] Close `lemma_2_8` eta-in-C case (sorry #4, line 936): when `eta in C` and `U(xi,eta) in A` but `xi not in C`. Since `eta in C`, the negation `neg(xi or (eta and U(xi,eta))) in C` decomposes to `U(xi,eta) not in C`. Then `G(U(xi,eta)) not in A` (otherwise `U(xi,eta) in g_content(A) subset C`), so `F(neg U(xi,eta)) in A`. Apply BX7 to `U(xi,eta)` and `top U neg U(xi,eta)` to get the needed intermediate point. Reduces to a lemma_2_7 variant with modified target formula.
- [ ] Run `lake build` and verify

**Timing**: 14 hours

**Depends on**: none (Phase 1 C4 definitions are in place)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- close 4 sorry sites

**Verification**:
- `lake build` succeeds
- `lemma_2_6_strong`, `lemma_2_7` (both D2 cases), `lemma_2_8` are sorry-free
- Sorry count: 17 -> 13

---

### Phase 4: Close C4 Elimination and Redesign C5 Insertion [NOT STARTED]

**Goal**: Close the 2 C4 elimination sorry sites (which now reduce to the sorry-free lemma_2_6_strong from Phase 3), and redesign C5 counterexample elimination to insert witnesses BETWEEN existing points (Burgess Lemma 2.10) instead of beyond all points.

**Why C4 and C5 together**: C4 elimination uses lemma_2_6 (base case). C5 elimination uses lemma_2_7/2_8 (subcase iii). Both are sorry-free from Phase 3. The two eliminations are architecturally parallel and should be addressed together because the omega-chain construction processes both C4 and C5 counterexamples.

**Tasks**:
- [ ] Close `eliminate_C4_counterexample` (sorry #5, line 271): now that `lemma_2_6_strong` is sorry-free, implement the reduction. Base case (x, y adjacent in dom): call `lemma_2_6_strong` with `f(x)` as A, `f(y)` as C, `delta` as the target formula. Insert z = (x+y)/2 with f(z) = the constructed MCS. Inductive case (intermediate points): nearest intermediate z0 either has `neg delta in f(z0)` (done) or `delta in f(z0)` (sub-counterexample with fewer intermediates).
- [ ] Close `eliminate_C4'_counterexample` (sorry #6, line 287): mirror for Since direction.
- [ ] Redesign `eliminate_C5_counterexample` to implement Lemma 2.10 correctly with between-point insertion:
  - Case n=0 (no points after x): current approach using `lemma_2_4` is correct. Place witness at x+1.
  - Case n=m+1 (x' is immediate successor of x in dom):
    - Subcase (i): `eta and U(xi,eta) in f(x')` and `eta in g(x,x')` -- replace x with x', reducing n by 1.
    - Subcase (ii): `xi in f(x')` and `eta in g(x,x')` -- x' is already the witness.
    - Subcase (iii): otherwise -- insert z = (x+x')/2 between x and x' using `lemma_2_7` or `lemma_2_8` (sorry-free from Phase 3). Split g(x,x') into g(x,z) and g(z,x').
  - Mirror for C5' (Since).
- [ ] Add `exists_rat_between` utility: for x < y, produce (x+y)/2 with x < mid < y.
- [ ] Update interval function g maintenance when inserting between points: split g(x,x') into g(x,z) and g(z,x') using R-relation decomposition from lemma_2_7.
- [ ] Run `lake build` and verify

**Timing**: 10 hours

**Depends on**: Phase 3 (lemma_2_6_strong, lemma_2_7, lemma_2_8 must be sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 2 C4 sorries, redesign C5 elimination

**Verification**:
- `lake build` succeeds
- `eliminate_C4_counterexample`, `eliminate_C4'_counterexample` are sorry-free
- `eliminate_C5_counterexample` uses between-point insertion (not endpoint insertion)
- No new sorry sites introduced
- Sorry count: 13 -> 11

---

### Phase 5: Prove Limit Properties (C5/C5' and C4/C4') [NOT STARTED]

**Goal**: Prove that the limit chronicle (union of the omega-chain) satisfies C5/C5' (forward Until/Since witnesses exist) and C4/C4' (backward counterexample resolution). Close sorry sites #7 and #8.

**Why this follows Phase 4**: The limit C5 proof relies on the corrected C5 elimination from Phase 4. The argument is: for any x in limit_dom with U(xi,eta) in limit_f(x), the counterexample enumeration covers (x, xi, eta) at some index k. At step max(n0, k)+1 the counterexample has been processed -- either a witness already existed, or one was inserted between existing points. The witness persists in the limit because f agrees on old domain points.

**Tasks**:
- [ ] Define `limit_g` (limit interval function) in `ChronicleConstruction.lean`: analogous to `limit_f`, taking the g-value from the stage where both endpoints first appear in the domain. Prove consistency: if both x and y are in stage n, then g_n(x,y) = g_m(x,y) for all m >= n.
- [ ] Prove `limit_satisfies_c5_weak` (sorry #7, line 373): for x in limit_dom with U(xi,eta) in limit_f(x):
  1. x is in some omega_chain_val(n0).dom.
  2. The counterexample (x, 0, xi, eta, c5_forward) is covered at enumeration index k.
  3. At step max(n0,k)+1, a witness y was inserted (between-point, per Phase 4 redesign).
  4. y persists in limit_dom; eta in limit_f(y) because f agrees on old domain points.
  5. Guard propagation: for intermediate z, xi in limit_f(z) follows from the g-function and C3.
- [ ] Prove `limit_satisfies_c5'_weak` (sorry #8, line 383): mirror for Since.
- [ ] Prove limit chronicle satisfies C4/C4': every C4 counterexample was eliminated at some step, and new insertions do not create new C4 counterexamples (preservation argument using the fact that f agrees on old domain points and new points have MCS compatible with the existing r-relation structure).
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 4 (C5 elimination must insert between points so the limit argument works)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add limit_g, close 2 sorry sites, prove limit C4/C4'

**Verification**:
- `lake build` succeeds
- `limit_satisfies_c5_weak` and `limit_satisfies_c5'_weak` are sorry-free
- Limit chronicle satisfies all conditions C0-C5 including C4/C4'
- Sorry count: 11 -> 9

---

### Phase 6: Fix Domain Extension (Dense Domain or Subtype Model) [NOT STARTED]

**Goal**: Eliminate the invalid `extended_limit_f` that assigns root MCS A to non-domain rationals. Under strict (irreflexive) semantics, G(phi) in A does not imply phi in A, so `forward_G` is unprovable with the current design. Either make the chronicle domain dense or switch to a subtype-indexed model.

**Why this must come before Phase 7**: The 9 ChronicleToCountermodel sorry sites (#9-17) all depend on `chronicle_fmcs` having correct `forward_G` and `backward_H` proofs. With the current `extended_limit_f`, these are provably invalid. The domain extension must be fixed before any integration sorry can be closed.

**Approach A -- Dense Chronicle Domain (preferred)**:
Interleave density steps in the omega-chain construction: at alternating steps (even = counterexample elimination, odd = density insertion), insert a new point between every pair of adjacent domain points. Each density insertion uses lemma_2_6 to construct an MCS compatible with the g-function at the midpoint. The limit domain is then a countable dense linear order without endpoints, isomorphic to Q by Cantor's theorem. The model over limit_dom IS a model over Q (up to isomorphism), and `extended_limit_f` becomes identity on domain (every rational is eventually a domain point).

**Approach B -- Subtype Model (fallback)**:
Replace `BFMCS Rat` with `BFMCS { x : Rat // x in limit_dom A h_mcs }`. The subtype inherits `LinearOrder` from Rat. For `AddCommGroup`, either close limit_dom under addition during the omega-chain construction, or use an order-isomorphism to Q via Cantor's theorem to transfer the group structure. This eliminates the `forward_G` obligation entirely because quantification is only over domain points.

**Tasks**:
- [ ] Choose between Approach A and B based on feasibility (Approach A is cleaner but requires maintaining C0-C5 through density insertions; Approach B requires algebraic instances on the subtype)
- [ ] If Approach A: add density steps to omega-chain construction. For each pair of adjacent domain points x < y: insert z = (x+y)/2 with f(z) constructed via lemma_2_6 (or a simpler seed extension from g_content). Maintain g(x,z) and g(z,y) via R-relation decomposition.
- [ ] If Approach A: prove `limit_dom_dense`: for any x, y in limit_dom with x < y, exists z in limit_dom with x < z < y.
- [ ] If Approach B: define `FMCS { x : Rat // x in limit_dom A h_mcs }` with `forward_G` proved using chronicle C2 r-relation and `backward_H` using C2'.
- [ ] Update or replace `extended_limit_f` in `ChronicleToCountermodel.lean` accordingly.
- [ ] Run `lake build` and verify

**Timing**: 6 hours

**Depends on**: Phase 5 (limit chronicle must satisfy all conditions before adding density or switching to subtype)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- density steps or subtype support
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace extended_limit_f

**Verification**:
- `lake build` succeeds
- Either `limit_dom_dense` proved (Approach A) or subtype model compiles (Approach B)
- `forward_G` and `backward_H` are provable with the new design
- No new sorry sites introduced
- Sorry count: 9 -> 9 (no sorry sites closed in this phase; this phase enables Phase 7)

---

### Phase 7: Close ChronicleToCountermodel Integration Sorry Sites [NOT STARTED]

**Goal**: Close all 9 sorry sites in `ChronicleToCountermodel.lean` using the corrected chronicle (C4 from Phase 1, between-point insertion from Phase 4, limit properties from Phase 5, fixed domain from Phase 6).

**Tasks**:
- [ ] Close `chronicle_fmcs.forward_G` (sorry #9, line 192): With dense domain / subtype model, G(phi) in f(t) and t' > t in domain implies phi in f(t'). Proof via C2 r-relation: g_content(f(t)) ⊆ f(t') (since G(phi) in f(t) implies phi in g_content(f(t))), and g_content(f(t)) ⊆ f(t') follows from C2 applied to adjacent pairs via C3 decomposition.
- [ ] Close `chronicle_fmcs.backward_H` (sorry #10, line 196): mirror using h_content and C2'.
- [ ] Close `box_stable_in_chronicle_fmcs` (sorry #11, line 234): Box phi in chronicle_fmcs(t) iff Box phi in A. Forward: Box phi -> G(Box phi) (temporal future axiom) -> Box phi propagates via forward_G. Backward: by construction, the root MCS A contains Box phi, and backward_H propagates.
- [ ] Close `chronicle_bfmcs_restricted_tc` forward F-resolution (sorry #12, line 320): F(phi) in shifted_chronicle at t. F(phi) = neg G(neg phi) in limit_f(t-s). By C5 (or directly: F(phi) in A gives a future witness by the chronicle's construction), extract y with phi in f(y). Transfer to shifted FMCS.
- [ ] Close `chronicle_bfmcs_restricted_tc` backward P-resolution (sorry #13, line 323): mirror using C5' for Since/Past.
- [ ] Close `chronicle_bfmcs_restricted_buc` Until (sorry #14, line 342): Given witness pattern (s_wit > t with psi at s_wit and phi at intermediates), derive U(phi,psi) in mcs(t). By contraposition using C4: if neg U(phi,psi) in f(t), then C4 gives z between t and s_wit with neg psi in f(z), but the guard assumption says phi holds at z (not neg psi), contradiction since z would have both psi and neg psi. So U(phi,psi) must be in f(t) by MCS completeness.
- [ ] Close `chronicle_bfmcs_restricted_buc` Since (sorry #15, line 345): mirror using C4'.
- [ ] Close `chronicle_bfmcs_restricted_fuc` Until (sorry #16, line 374): U(phi,psi) in shifted_chronicle at t. By C5 of limit chronicle (Phase 5): exists y in limit_dom with t-s < y and psi in f(y) and guard at intermediate domain points. With dense domain, guard extends to all intermediates. Transfer to shifted FMCS coordinates.
- [ ] Close `chronicle_bfmcs_restricted_fuc` Since (sorry #17, line 377): mirror using C5'.
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 6 (domain extension must be fixed for forward_G/backward_H)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close all 9 sorry sites

**Verification**:
- `lake build` succeeds
- All 9 ChronicleToCountermodel sorry sites closed
- `dd_countermodel_chronicle` compiles sorry-free
- Sorry count: 9 -> 0

---

### Phase 8: Final Wiring and Verification [NOT STARTED]

**Goal**: Verify `bx_completeness` is sorry-free end-to-end. Run axiom checks, confirm no sorryAx, clean up dead code.

**Tasks**:
- [ ] Run `#print axioms bx_completeness` and confirm output contains NO `sorryAx`
- [ ] Run `#print axioms dd_countermodel_chronicle` and confirm NO `sorryAx`
- [ ] Run full `lake build` and confirm success
- [ ] Verify no regression in existing sorry-free modules (Soundness, Decidability/FMP)
- [ ] Mark `RootScopedChain.lean`'s 3 sorry sites as dead code (chronicle pathway bypasses them)
- [ ] Review all Chronicle files for any remaining sorry, sorry'd comment artifacts, or TODO markers

**Timing**: 2 hours

**Depends on**: Phase 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- verify wiring (likely no changes)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- mark dead code (optional cleanup)

**Verification**:
- `lake build` succeeds with no regressions
- `#print axioms bx_completeness` shows NO `sorryAx`
- `#print axioms dd_countermodel_chronicle` shows NO `sorryAx`
- All 17 sorry sites resolved (17 closed, 0 remaining)
- Expected axioms: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary (Phases 3-8 = 6 checkpoints)
- [ ] `#print axioms bx_completeness` shows no `sorryAx` after Phase 8
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx` after Phase 8
- [ ] PointInsertion: Lemmas 2.6_strong, 2.7 (both D2 cases), 2.8 are sorry-free after Phase 3
- [ ] C4/C5 counterexample elimination: fully sorry-free after Phase 4
- [ ] Limit properties: limit_satisfies_c5_weak/c5'_weak sorry-free after Phase 5
- [ ] Domain extension: forward_G/backward_H provable after Phase 6
- [ ] ChronicleToCountermodel: all 9 coherence sorries closed after Phase 7
- [ ] No regression in existing sorry-free modules (Soundness.lean, Decidability/FMP)

## Artifacts & Outputs

- `specs/107_.../plans/09_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (close 4 sorries)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (close 2 sorries, redesign C5)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (close 2 sorries, add limit_g, density)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (close 9 sorries, fix domain extension)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes are to existing files in the `Chronicle/` subdirectory; reverting to the current commit restores the status quo with 17 sorry sites.
- **Phase 3 fallback**: If the BX11-based proof strategy for D2 cases proves insufficient, alternatives: (a) reformulate lemma_2_7 with a weaker conclusion sufficient for Lemma 2.10, (b) construct the MCS witness directly via Lindenbaum extension with explicit seed sets, (c) use `lean_multi_attempt` to explore automated tactics.
- **Phase 4 partial progress**: C4 elimination and C5 redesign are independent within the phase. C4 elimination can be closed first (it only needs lemma_2_6_strong), and C5 redesign can proceed separately.
- **Phase 6 fallback**: If dense domain approach is too complex, fall back to subtype-indexed model. If subtype lacks AddCommGroup, modify BFMCS interface to use `LinearOrder` only (removing additive structure requirement).
- **Incremental progress**: Each phase reduces the sorry count independently. Even if later phases stall, earlier phases represent genuine progress.

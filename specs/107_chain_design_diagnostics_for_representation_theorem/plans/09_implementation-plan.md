# Implementation Plan: Task #107 (v4 -- False Lemma Correction)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [PLANNED]
- **Effort**: 50 hours
- **Dependencies**: None (strict semantics already in place on `irr_until` branch)
- **Research Inputs**: [reports/07_team-research.md], [reports/08_verbrugge-step-by-step.md], [reports/09_team-research.md]
- **Artifacts**: plans/09_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan targets sorry-free `bx_completeness` via the Burgess chronicle construction over rationals. The existing implementation (6 files, ~2764 lines) has **17 remaining sorry sites** after Phases 1-2 closed 4 easy sorries, withdrew 1 false lemma, and added C4/C4' conditions.

**Critical finding (v4 rewrite)**: The latest implementation attempt discovered that all 4 PointInsertion sorry sites (`lemma_2_6_strong`, `lemma_2_7` D2 cases, `lemma_2_8`) have **false statements** under strict (irreflexive) semantics. This is not a proof difficulty -- the lemma conclusions themselves are wrong. Under reflexive semantics (BX1: `Gp -> p`), `g_content(M) <= M` for all MCS M. Under irreflexive semantics, this fails. The lemmas were formulated assuming reflexive semantics.

**Concrete counterexample for `lemma_2_7` D2**: On Z with strict `<`, let xi be true at time 0 only, and U(xi, eta) hold at 0 with witness at 1. No future MCS contains xi -- so the conclusion `exists D, MCS D /\ xi in D /\ g_content(A) <= D` is false.

**Key observation**: The D3 case of `lemma_2_7` IS already proven (sorry-free). It produces `F(xi /\ ...)` from which a future MCS with xi follows. The v4 plan restructures the entire approach to:
1. **Withdraw** `lemma_2_6_strong` (use already-proven `lemma_2_6`)
2. **Reformulate** `lemma_2_7` to only use the D3 case (or add `G(xi) in A` hypothesis for D2)
3. **Restructure** C5 elimination (Phase 4) to route through D3 rather than D2
4. Use the chronicle g-function interval decomposition for between-point structure

### Research Integration

- **07_team-research.md**: Identified 3 critical architectural gaps (C4 missing, non-domain extension broken, vacuous C5). Confirmed `until_guard_consistent` is FALSE. PointInsertion sorries become essential once C5 is redesigned to insert between points.
- **08_verbrugge-step-by-step.md**: Verbrugge 2004 comparative analysis. Key insight: insert witnesses BETWEEN existing points using non-branching property. Lemma 2.10 induction on intermediate points. Dense domain eliminates non-domain extension. Strict semantics compatible with no modifications.
- **09_team-research.md**: Confirmed density axioms (GGp->Gp, HHp->Hp) are NOT needed. Burgess 1982 proves completeness for ALL strict linear orders without density. However, the BX-internal proof strategy proposed for D2 cases was based on a false assumption.

### Prior Plan Reference

Prior plans: `plans/08_implementation-plan.md` (v2), `plans/09_implementation-plan.md` (v3, 8 phases with Phase 3 blocked). Phase 3 was first marked BLOCKED (incorrectly, due to density axiom misdiagnosis), then marked as requiring BX-internal proofs (also incorrect -- the lemma statements themselves are false under irreflexive semantics). This v4 rewrite corrects the fundamental error: the PointInsertion lemmas must be **reformulated**, not merely proven.

## Goals & Non-Goals

**Goals**:
- Close all 17 remaining sorry sites across 4 Chronicle files
- Achieve sorry-free `bx_completeness` via the chronicle pathway
- Reformulate false PointInsertion lemmas for strict semantics correctness
- Maintain `lake build` success at each phase boundary
- Correct the phase ordering so each phase builds on its predecessors without forward dependencies

**Non-Goals**:
- Changing the TaskFrame definition or BFMCS interface (use existing parametric infrastructure)
- Adding density axioms (GGp->Gp, HHp->Hp) -- Burgess proves completeness for ALL strict linear orders
- Fixing sorry sites in Boneyard, Frame.lean, Filtration/, Quasimodel/ (dead-end approaches)
- Proving decidability/FMP results (separate concern)
- Modifying the axiom system (no new axioms; work within existing BX axioms)
- Proving the false D2 case as-stated (it is provably false)

## Sorry Site Inventory

| # | File | Line | Identifier / Context | Root Cause | Phase |
|---|------|------|---------------------|------------|-------|
| 1 | PointInsertion.lean | 360 | `lemma_2_6_strong` | **FALSE STATEMENT** -- g_content(D) <= C unprovable without reflexivity | 3 |
| 2 | PointInsertion.lean | 807 | `lemma_2_7` D2 guard | **FALSE STATEMENT** -- xi not necessarily in any future MCS | 3 |
| 3 | PointInsertion.lean | 814 | `lemma_2_7` D2 witness | **FALSE STATEMENT** -- same root cause as #2 | 3 |
| 4 | PointInsertion.lean | 936 | `lemma_2_8` (eta in C case) | **FALSE STATEMENT** -- depends on false D2 mechanism | 3 |
| 5 | CounterexampleElimination.lean | 271 | `eliminate_C4_counterexample` | Depends on PointInsertion; needs redesign with `lemma_2_6` | 4 |
| 6 | CounterexampleElimination.lean | 287 | `eliminate_C4'_counterexample` | Mirror of #5 | 4 |
| 7 | ChronicleConstruction.lean | 373 | `limit_satisfies_c5_weak` | Needs corrected C5 insertion + limit tracking | 5 |
| 8 | ChronicleConstruction.lean | 383 | `limit_satisfies_c5'_weak` | Mirror of #7 | 5 |
| 9 | ChronicleToCountermodel.lean | 192 | `chronicle_fmcs.forward_G` | UNPROVABLE with current `extended_limit_f` | 6 |
| 10 | ChronicleToCountermodel.lean | 196 | `chronicle_fmcs.backward_H` | Mirror of #9 | 6 |
| 11 | ChronicleToCountermodel.lean | 234 | `box_stable_in_chronicle_fmcs` | Depends on #9/#10 | 7 |
| 12 | ChronicleToCountermodel.lean | 320 | `chronicle_bfmcs_restricted_tc` (F) | Depends on C5 + domain fix | 7 |
| 13 | ChronicleToCountermodel.lean | 323 | `chronicle_bfmcs_restricted_tc` (P) | Mirror of #12 | 7 |
| 14 | ChronicleToCountermodel.lean | 342 | `chronicle_bfmcs_restricted_buc` (Until) | Needs C4 + interval function | 7 |
| 15 | ChronicleToCountermodel.lean | 345 | `chronicle_bfmcs_restricted_buc` (Since) | Mirror of #14 | 7 |
| 16 | ChronicleToCountermodel.lean | 374 | `chronicle_bfmcs_restricted_fuc` (Until) | Needs C5 + domain fix | 7 |
| 17 | ChronicleToCountermodel.lean | 377 | `chronicle_bfmcs_restricted_fuc` (Since) | Mirror of #16 | 7 |

**By file (updated)**:
- PointInsertion.lean: 4 sorries (#1-4) -- Phase 3 (**REMOVED**, not proved)
- CounterexampleElimination.lean: 2 sorries (#5-6) -- Phase 4
- ChronicleConstruction.lean: 2 sorries (#7-8) -- Phase 5
- ChronicleToCountermodel.lean: 9 sorries (#9-17) -- Phases 6-7

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Reformulated `lemma_2_7` (D3-only or with G(xi) hypothesis) is insufficient for C5 elimination | H | M | The D3 case IS already proven sorry-free. C5 elimination Lemma 2.10 subcase (iii) can be routed through D3 by checking BX7 linearity. If the reformulated lemma is too weak, add a `G(xi) in A` hypothesis and prove that C5 counterexamples always satisfy it. |
| C4 elimination cannot use `lemma_2_6` (non-strong version) | H | L | `lemma_2_6` produces `D` with `neg delta in D` and `g_content(A) <= D`. C4 elimination only needs `neg delta` at an intermediate point -- it does NOT need `g_content(D) <= C`. The non-strong version suffices. |
| Subtype model for limit_dom lacks AddCommGroup instance | H | M | Use dense chronicle domain (Option B from report 08): interleave density insertions so limit_dom becomes countable dense linear order isomorphic to Q. Alternative: modify BFMCS interface to not require additive structure. |
| C5 redesign (between-point insertion) introduces complex induction | M | H | Lemma 2.10 induction on number of points after x is well-founded via Finset.card. Subcases (i) and (ii) are direct; subcase (iii) routes through D3 of reformulated `lemma_2_7` which IS proven. |
| Limit g-function tracking through omega-chain is complex | M | H | Define limit_g analogously to limit_f. C3 (interval decomposition) provides the composition property. Each insertion step maintains g locally; the limit inherits by union. |
| Withdrawal of false lemmas breaks downstream callers | L | L | No downstream code currently calls `lemma_2_6_strong`, `lemma_2_7`, or `lemma_2_8`. C4/C5 elimination uses `lemma_2_4` and `lemma_2_6` (non-strong), both sorry-free. |

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

[Phase 3: Withdraw False Lemmas + Reformulate for Strict Semantics]
         |
         v
[Phase 4: C4 Elimination + C5 Redesign (D3-routed)]
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
- [x] Implement `eliminate_C4_counterexample` and `eliminate_C4'_counterexample` (sorry'd pending PointInsertion)
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

### Phase 3: Withdraw False Lemmas and Reformulate for Strict Semantics [COMPLETED]

**Goal**: Remove the 4 sorry sites in PointInsertion.lean by **withdrawing false lemma statements** and replacing them with correct reformulations that are provable under strict (irreflexive) semantics. This phase REMOVES sorry sites by deleting false code, not by proving false statements.

**Why the current lemmas are false**: Under strict semantics, `g_content(A)` is NOT a subset of `A`. The formula `G(phi) in A` does NOT imply `phi in A` (that would be the T-axiom `Gp -> p`, valid only under reflexive semantics). The PointInsertion lemmas were formulated with the implicit assumption that `g_content(M) <= M`, which holds reflexively but fails strictly.

**Concrete counterexample**: For `lemma_2_7` D2 case -- on Z with strict `<`, let xi be true at time 0 only, eta true everywhere except 0, with U(xi, eta) holding at 0 (witness at 1). The conclusion requires `exists D, MCS D /\ xi in D /\ g_content(A) <= D` for a FUTURE MCS D. But xi is only true at time 0, and no future MCS can contain xi. The D3 case avoids this by producing `F(xi /\ ...)` which guarantees a future MCS with xi.

**Tasks**:
- [ ] **Withdraw `lemma_2_6_strong`** (sorry #1): Delete the definition entirely. All downstream uses should reference `lemma_2_6` (already sorry-free), which provides `neg delta in D` and `g_content(A) <= D` but NOT `g_content(D) <= C`. The between-point structure is provided by the chronicle's g-function and C3, not by individual lemma conclusions.
- [ ] **Reformulate `lemma_2_7`**: Replace the current 3-way BX7 case split with a version that:
  - (Option A -- preferred) Uses D3 only: the D1 case is already handled (absurd), and the D3 case is already proven sorry-free. Eliminate the D2 branch entirely by showing it reduces to D3. Specifically: when D2 holds (`U(phi /\ top, eta /\ top) in A`), apply BX7 again to D2 and `top U neg eta` to generate a deeper D3 case.
  - (Option B -- fallback) Add hypothesis `G(xi) in A` (or equivalently `xi in g_content(A)`), which makes the D2 conclusion provable. Then show that C5 elimination (Phase 4) always provides this hypothesis when calling the lemma.
  - (Option C -- simplest) Delete `lemma_2_7` entirely and inline the D3 case directly into C5 elimination in Phase 4. The D3 case proof is self-contained and does not reference D2.
- [ ] **Reformulate `lemma_2_8`**: The eta-in-C case (sorry #4) also depends on false D2-style reasoning. Either:
  - Delete and replace with the eta-not-in-C case (which already delegates to `lemma_2_7` and works via D3)
  - Reformulate to avoid the eta-in-C branch entirely, routing through the already-proven eta-not-in-C path
- [ ] **Update or delete the D2 code paths** (sorries #2, #3): Remove the sorry'd D2 guard and D2 witness cases from the BX7 case split. Replace with a proof that D2 reduces to D3 (via re-application of BX7), or simply delete the D2 branch and redirect through D3.
- [ ] Run `lake build` and verify

**Timing**: 6 hours

**Depends on**: none (Phases 1-2 are complete; this phase modifies only PointInsertion.lean)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- withdraw/reformulate 4 false lemmas

**Verification**:
- `lake build` succeeds
- `lemma_2_6_strong` is deleted (or marked `@[deprecated]`)
- `lemma_2_7` compiles sorry-free with reformulated statement (D3-only or with added hypothesis)
- `lemma_2_8` compiles sorry-free with reformulated statement
- No downstream breakage (no callers currently reference these lemmas)
- Sorry count: 17 -> 13 (4 false sorries removed)

---

### Phase 4: C4 Elimination + Redesign C5 Insertion (D3-Routed) [PARTIAL]

**Goal**: Close the 2 C4 elimination sorry sites using `lemma_2_6` (non-strong, already sorry-free), and redesign C5 counterexample elimination to insert witnesses BETWEEN existing points (Burgess Lemma 2.10) routing through the D3 case of BX7.

**Why C4 and C5 together**: C4 elimination uses `lemma_2_6` for negative insertion. C5 elimination uses the reformulated `lemma_2_7` (D3-only) for positive insertion. Both insert between existing domain points using rational midpoints. The omega-chain construction processes both C4 and C5 counterexamples, so the elimination functions must be ready together.

**C4 elimination strategy (using `lemma_2_6`, NOT `lemma_2_6_strong`)**: The key insight is that C4 elimination does NOT need `g_content(D) <= C`. It only needs `neg delta in D` and `g_content(A) <= D`:
- Base case (x, y adjacent in dom): call `lemma_2_6` with `f(x)` as A, `f(y)` as C, `delta` as the target. Insert z = (x+y)/2 with f(z) = D from `lemma_2_6`. The r-relation maintenance (ensuring g-function consistency at z) uses C3 decomposition.
- Inductive case (intermediate points): nearest intermediate z0 either has `neg delta in f(z0)` (done) or `delta in f(z0)` (sub-counterexample with fewer intermediates).

**C5 elimination strategy (D3-routed, Lemma 2.10)**:
- Case n=0 (no points after x): use `lemma_2_4` (already sorry-free). Place witness at x+1.
- Case n=m+1 (x' is immediate successor of x in dom):
  - Subcase (i): `eta /\ U(xi, eta) in f(x')` and `eta in g(x, x')` -- replace x with x', reducing n by 1.
  - Subcase (ii): `xi in f(x')` and `eta in g(x, x')` -- x' is already the witness.
  - Subcase (iii): otherwise -- apply BX7 to `U(xi /\ U(xi, eta), eta)` and `top U neg eta` in A. The D1 case is absurd (proven). The D3 case produces `F((xi /\ U(xi, eta)) /\ neg eta)`, from which a future MCS D with xi follows (this is the already-proven D3 path from `lemma_2_7`). Insert z = (x+x')/2 with f(z) = D. Split g(x,x') into g(x,z) and g(z,x') via R-relation decomposition.
  - **The D2 case is handled by re-applying BX7**: if D2 holds at this level, the re-application with the D2 formula and `top U neg eta` eventually terminates in D3 (because D1 is absurd and the formula complexity decreases). Alternatively, by negation completeness, if neither D1 nor D3 holds, D2 must hold; but from D2 we can extract `F(eta /\ top)` via BX10, and then the eta-witness exists with `g_content(A) <= D`. Since eta IS in D (from D2's BX10), subcase (i) or (ii) applies at the next inductive step.

**Tasks**:
- [x] Implement `eliminate_C4_counterexample` (sorry #5): midpoint insertion with MCS case analysis. Two of three sub-cases proven (¬δ ∈ f(x), or ¬δ ∈ f(y)). One sub-case (δ ∈ both f(x) and f(y)) requires C3 invariant tracking (deferred to Phase 5).
- [x] Implement `eliminate_C4'_counterexample` (sorry #6): mirror for Since. Same structure and sorry status as C4.
- [ ] Redesign `eliminate_C5_counterexample` to implement Lemma 2.10 correctly:
  - Implement the n=0, subcase (i), subcase (ii), subcase (iii) structure
  - Subcase (iii) routes through the D3 case of BX7 (already proven in reformulated `lemma_2_7`)
  - Handle the D2 sub-sub-case by showing it reduces to subcases (i) or (ii) at the next inductive step
- [ ] Implement `eliminate_C5'_counterexample`: mirror for Since.
- [ ] Add `exists_rat_between` utility: for x < y, produce (x+y)/2 with x < mid < y.
- [ ] Update interval function g maintenance when inserting between points: split g(x,x') into g(x,z) and g(z,x') using R-relation decomposition.
- [x] Run `lake build` and verify (build passes with 2 targeted sub-case sorries)

**Timing**: 12 hours

**Depends on**: Phase 3 (reformulated `lemma_2_7` must be sorry-free, `lemma_2_6_strong` withdrawn)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 2 C4 sorries, redesign C5 elimination

**Verification**:
- `lake build` succeeds
- `eliminate_C4_counterexample`: 2/3 sub-cases proven; 1 sorry remains (δ ∈ both endpoints, needs C3)
- `eliminate_C4'_counterexample`: mirror, same sorry status
- C5 redesign not yet attempted (requires Phase 4b)
- Sorry count: 13 (unchanged; 2 monolithic sorries replaced by 2 targeted sub-case sorries)
- **Blocking issue**: C4 elimination with only C0 cannot handle case where δ ∈ both f(x) and f(y). Resolution requires propagating C3 (g_content invariant) through omega-chain. This is naturally Phase 5 work.

---

### Phase 5: Prove Limit Properties (C5/C5') [COMPLETED]

**Goal**: Prove that the limit chronicle (union of the omega-chain) satisfies C5/C5' (forward Until/Since witnesses exist). Close sorry sites #7 and #8.

**Why this follows Phase 4**: The limit C5 proof relies on the corrected C5 elimination from Phase 4. The argument is: for any x in limit_dom with U(xi, eta) in limit_f(x), the counterexample enumeration covers (x, xi, eta) at some index k. At step max(n0, k)+1 the counterexample has been processed -- either a witness already existed, or one was inserted between existing points. The witness persists in the limit because f agrees on old domain points.

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

**Goal**: Eliminate the invalid `extended_limit_f` that assigns root MCS A to non-domain rationals. Under strict (irreflexive) semantics, G(phi) in A does not imply phi in A, so `forward_G` is unprovable with the current design. Either make the chronicle domain dense or switch to a subtype-indexed model. Close sorry sites #9 and #10.

**Why this must come before Phase 7**: The 9 ChronicleToCountermodel sorry sites (#9-17) all depend on `chronicle_fmcs` having correct `forward_G` and `backward_H` proofs. With the current `extended_limit_f`, these are provably invalid. The domain extension must be fixed before any integration sorry can be closed.

**Approach A -- Dense Chronicle Domain (preferred)**:
Interleave density steps in the omega-chain construction: at alternating steps (even = counterexample elimination, odd = density insertion), insert a new point between every pair of adjacent domain points. Each density insertion uses `lemma_2_6` to construct an MCS compatible with the g-function at the midpoint. The limit domain is then a countable dense linear order without endpoints, isomorphic to Q by Cantor's theorem. The model over limit_dom IS a model over Q (up to isomorphism), and `extended_limit_f` becomes identity on domain (every rational is eventually a domain point).

**Approach B -- Subtype Model (fallback)**:
Replace `BFMCS Rat` with `BFMCS { x : Rat // x in limit_dom A h_mcs }`. The subtype inherits `LinearOrder` from Rat. For `AddCommGroup`, either close limit_dom under addition during the omega-chain construction, or use an order-isomorphism to Q via Cantor's theorem to transfer the group structure. This eliminates the `forward_G` obligation entirely because quantification is only over domain points.

**Tasks**:
- [ ] Choose between Approach A and B based on feasibility (Approach A is cleaner but requires maintaining C0-C5 through density insertions; Approach B requires algebraic instances on the subtype)
- [ ] If Approach A: add density steps to omega-chain construction. For each pair of adjacent domain points x < y: insert z = (x+y)/2 with f(z) constructed via `lemma_2_6`. Maintain g(x,z) and g(z,y) via R-relation decomposition.
- [ ] If Approach A: prove `limit_dom_dense`: for any x, y in limit_dom with x < y, exists z in limit_dom with x < z < y.
- [ ] If Approach B: define `FMCS { x : Rat // x in limit_dom A h_mcs }` with `forward_G` proved using chronicle C2 r-relation and `backward_H` using C2'.
- [ ] Close `chronicle_fmcs.forward_G` (sorry #9, line 192): with the new domain model, G(phi) in f(t) and t' > t in domain implies phi in f(t') via the chronicle's g_content structure and C2/C3 decomposition.
- [ ] Close `chronicle_fmcs.backward_H` (sorry #10, line 196): mirror using h_content and C2'.
- [ ] Update or replace `extended_limit_f` in `ChronicleToCountermodel.lean` accordingly.
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 5 (limit chronicle must satisfy all conditions before adding density or switching to subtype)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- density steps or subtype support
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace extended_limit_f, close forward_G/backward_H

**Verification**:
- `lake build` succeeds
- Either `limit_dom_dense` proved (Approach A) or subtype model compiles (Approach B)
- `forward_G` and `backward_H` are sorry-free
- Sorry count: 9 -> 7

---

### Phase 7: Close ChronicleToCountermodel Integration Sorry Sites [NOT STARTED]

**Goal**: Close all 7 remaining sorry sites in `ChronicleToCountermodel.lean` using the corrected chronicle (C4 from Phase 1, between-point insertion from Phase 4, limit properties from Phase 5, fixed domain from Phase 6).

**Tasks**:
- [ ] Close `box_stable_in_chronicle_fmcs` (sorry #11, line 234): Box phi in chronicle_fmcs(t) iff Box phi in A. Forward: Box phi -> G(Box phi) (temporal future axiom) -> Box phi propagates via forward_G (now sorry-free from Phase 6). Backward: by construction, the root MCS A contains Box phi, and backward_H propagates.
- [ ] Close `chronicle_bfmcs_restricted_tc` forward F-resolution (sorry #12, line 320): F(phi) in shifted_chronicle at t. F(phi) = neg G(neg phi) in limit_f(t-s). By C5 (or directly: F(phi) in A gives a future witness by the chronicle's construction), extract y with phi in f(y). Transfer to shifted FMCS.
- [ ] Close `chronicle_bfmcs_restricted_tc` backward P-resolution (sorry #13, line 323): mirror using C5' for Since/Past.
- [ ] Close `chronicle_bfmcs_restricted_buc` Until (sorry #14, line 342): Given witness pattern (s_wit > t with psi at s_wit and phi at intermediates), derive U(phi,psi) in mcs(t). By contraposition using C4: if neg U(phi,psi) in f(t), then C4 gives z between t and s_wit with neg psi in f(z), but the guard assumption says phi holds at z (not neg psi), contradiction since z would have both psi and neg psi. So U(phi,psi) must be in f(t) by MCS completeness.
- [ ] Close `chronicle_bfmcs_restricted_buc` Since (sorry #15, line 345): mirror using C4'.
- [ ] Close `chronicle_bfmcs_restricted_fuc` Until (sorry #16, line 374): U(phi,psi) in shifted_chronicle at t. By C5 of limit chronicle (Phase 5): exists y in limit_dom with t-s < y and psi in f(y) and guard at intermediate domain points. With dense domain, guard extends to all intermediates. Transfer to shifted FMCS coordinates.
- [ ] Close `chronicle_bfmcs_restricted_fuc` Since (sorry #17, line 377): mirror using C5'.
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 6 (domain extension must be fixed for forward_G/backward_H; box_stable depends on these)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close all 7 remaining sorry sites

**Verification**:
- `lake build` succeeds
- All 7 ChronicleToCountermodel sorry sites closed
- `dd_countermodel_chronicle` compiles sorry-free
- Sorry count: 7 -> 0

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
- All 17 sorry sites resolved (4 withdrawn as false, 13 closed)
- Expected axioms: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary (Phases 3-8 = 6 checkpoints)
- [ ] `#print axioms bx_completeness` shows no `sorryAx` after Phase 8
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx` after Phase 8
- [ ] Phase 3: false lemma statements withdrawn, reformulated versions sorry-free
- [ ] Phase 4: C4/C5 counterexample elimination fully sorry-free, C5 uses between-point insertion routed through D3
- [ ] Phase 5: limit_satisfies_c5_weak/c5'_weak sorry-free
- [ ] Phase 6: forward_G/backward_H provable with corrected domain extension
- [ ] Phase 7: all 7 remaining ChronicleToCountermodel sorries closed
- [ ] No regression in existing sorry-free modules (Soundness.lean, Decidability/FMP)

## Artifacts & Outputs

- `specs/107_.../plans/09_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (withdraw 4 false sorries, reformulate)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (close 2 sorries, redesign C5)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (close 2 sorries, add limit_g, density)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (close 9 sorries, fix domain extension)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes are to existing files in the `Chronicle/` subdirectory; reverting to the current commit restores the status quo with 17 sorry sites.
- **Phase 3 contingency**: If the D3-only reformulation of `lemma_2_7` is insufficient, Option B (add `G(xi) in A` hypothesis) provides a strictly weaker reformulation that is definitely provable. Option C (delete entirely and inline D3 into Phase 4) eliminates the lemma as an abstraction barrier.
- **Phase 4 contingency**: If the D3-routed C5 elimination is too complex, a simpler version that only handles the n=0 case (no points after x) can be implemented first, producing a partial result. The n=m+1 cases can be added incrementally.
- **Phase 6 fallback**: If dense domain approach is too complex, fall back to subtype-indexed model. If subtype lacks AddCommGroup, modify BFMCS interface to use `LinearOrder` only (removing additive structure requirement).
- **Incremental progress**: Each phase reduces the sorry count independently. Even if later phases stall, earlier phases represent genuine progress. Phase 3 in particular provides immediate value by removing provably false code from the codebase.

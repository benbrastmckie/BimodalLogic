# Handoff: Task 107 Phase 3-4 (Density Infrastructure + Forward_G Strategy)

## Session: sess_1777093251_dbd5f0
## Date: 2026-04-24

## Status: Phase 3 PARTIAL, Phase 4 PARTIAL (infrastructure only)

## What Was Done

### Density Infrastructure (NEW - sorry-free)

1. **Added `density` counterexample kind** to `PotentialCounterexampleKind` in CounterexampleElimination.lean. This inserts midpoints between adjacent pairs, making the limit domain dense.

2. **Added `density_witness` field** to `EliminationResult` structure. All existing cases provide it (by absurd for non-density kinds). The density case provides the actual witness.

3. **Added `eliminate_density_counterexample`** helper function (sorry-free) in CounterexampleElimination.lean.

4. **Proved `limit_dom_dense`** (sorry-free) in ChronicleConstruction.lean: for any x < y in limit_dom, there exists z in limit_dom with x < z < y. Uses the density_witness field from EliminationResult to extract the midpoint.

### Key Architectural Insight

The forward_G/backward_H problem for the chronicle FMCS is caused by the `extended_limit_f` definition: non-domain points get assigned the root MCS A, and G(phi) in A does NOT imply phi in A under strict semantics (no T-axiom for G). This breaks forward_G at non-domain points.

**The fix requires the Cantor isomorphism approach**: Order.iso_of_countable_dense maps the countable dense limit_dom onto Q (or equivalently, Q onto limit_dom). This makes every rational a domain point. forward_G then reduces to limit_forward_G (domain-to-domain propagation).

### Analysis of lemma_2_6_full

Extensive analysis showed that the full Lemma 2.6 (three-way DCS decomposition) is NOT needed for the completeness theorem. The density approach makes C4 vacuously true at the limit (no adjacent pairs in a dense domain). The remaining sorry in lemma_2_6_full (line 762 of PointInsertion.lean) can be deferred or marked as non-critical.

## Remaining Sorry Inventory (14, unchanged)

| File | Line | Description | Needed? |
|------|------|-------------|---------|
| PointInsertion.lean | 762 | lemma_2_6_full | NO (density makes C4 vacuous) |
| CounterexampleElimination.lean | 282 | C4 hard case (delta in both) | NO (density makes C4 vacuous) |
| CounterexampleElimination.lean | 348 | C4' hard case (mirror) | NO (density makes C4 vacuous) |
| ChronicleConstruction.lean | 847 | limit_forward_G | YES - needs Cantor iso |
| ChronicleConstruction.lean | 862 | limit_backward_H | YES - needs Cantor iso |
| ChronicleToCountermodel.lean | 195 | chronicle_fmcs forward_G | YES - needs redesign |
| ChronicleToCountermodel.lean | 200 | chronicle_fmcs backward_H | YES - needs redesign |
| ChronicleToCountermodel.lean | 238 | box_stable | Depends on forward_G/backward_H |
| ChronicleToCountermodel.lean | 327 | restricted_tc F | Depends on redesign |
| ChronicleToCountermodel.lean | 330 | restricted_tc P | Depends on redesign |
| ChronicleToCountermodel.lean | 349 | restricted_buc Until | Depends on redesign |
| ChronicleToCountermodel.lean | 352 | restricted_buc Since | Depends on redesign |
| ChronicleToCountermodel.lean | 381 | restricted_fuc Until | Depends on C5 |
| ChronicleToCountermodel.lean | 384 | restricted_fuc Since | Depends on C5' |

## Critical Path

```
1. Cantor Isomorphism Setup (Phase 5)
   - Prove limit_dom: Countable, DenselyOrdered, NoMinOrder, NoMaxOrder
   - Apply Order.iso_of_countable_dense to get limit_dom ≃o Rat
   - Redefine extended_limit_f via Cantor iso: f(q) = limit_f(iso.symm(q))

2. limit_forward_G / limit_backward_H (Phase 5)
   - With Cantor iso, every rational is a domain point
   - forward_G: G(phi) in f(iso.symm(x)) and x < y => phi in f(iso.symm(y))
   - Argument: g_prop_forward counterexamples + density break adjacencies
   - This is still the hardest proof in the entire construction

3. chronicle_fmcs with Cantor iso (Phase 6)
   - chronicle_fmcs(t) = limit_f(cantor_iso.symm(t))
   - forward_G comes from limit_forward_G through iso
   - backward_H comes from limit_backward_H through iso

4. Downstream wiring (Phase 6)
   - box_stable, restricted_tc, restricted_buc, restricted_fuc
   - All follow from the Cantor iso redesign
```

## Key Insight for limit_forward_G

The g_prop_forward counterexamples, combined with density, give us: at every finite stage n, for every adjacent pair (x, y) in dom_n with G(alpha) in f_n(x) and alpha not in f_n(y), a midpoint z is inserted with:
- alpha in f(z)
- g_content(f(x)) subset f(z) (including G(G(phi)) -> G(phi) in f(z))

So G propagates to the midpoint. By repetition (density), G propagates to ALL future domain points in the limit. The formal proof needs careful induction on the omega chain stages.

## Files Modified
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` - density kind + density_witness + eliminate_density_counterexample
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` - limit_dom_dense

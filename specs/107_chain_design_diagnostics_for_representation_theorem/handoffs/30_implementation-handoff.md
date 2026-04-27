# Handoff: Task 107 Implementation (Session sess_1777266432_a138a9)

## Session Context
- **Session ID**: sess_1777266432_a138a9
- **Agent**: lean-implementation-agent
- **Plan**: specs/107_.../plans/30_implementation-plan.md (v17)
- **Phases Completed**: 1.5 (Cruft Purge), 2 (BurgessR3Maximal Definition + Existence)
- **Status**: Partial progress -- foundational infrastructure built, sorry count unchanged at 4

## Completed Work

### Phase 1.5: Cruft Purge [COMPLETED]

1. **Deleted g_ordered and h_ordered** from ChronicleTypes.lean (deprecated definitions, ~25 lines)
2. **Deleted claim_2_11** tautological stub from ChronicleConstruction.lean (~25 lines)
3. **Updated stale comments** in CounterexampleElimination.lean (replaced g_ordered/A4a references with burgessR3 bridging description)
4. **Updated stale "Phase 2" comments** in PointInsertion.lean
5. **Verified**: chronicle_fmcs/chronicle_bfmcs already deleted in prior session
6. **Build passes**, sorry count unchanged at 4

### Phase 2: BurgessR3Maximal Definition + Existence [COMPLETED]

**Definitions moved to ChronicleTypes.lean** (to avoid circular imports with RRelation.lean):
- `burgessR(A, beta, C)` -- single-element Burgess r-relation
- `burgessRSet(A, B, C)` -- set-level
- `burgessRSince(A, beta, C)` -- Since direction
- `burgessRSetSince(A, B, C)` -- set-level Since
- `burgessR3(A, B, C)` -- combined Until + Since
- `BurgessR3Maximal(A, B, C)` -- maximal DCS satisfying burgessR3

**c2' updated**: `Chronicle.c2'` now uses `BurgessR3Maximal` instead of `R3Maximal`.

**Sorry-free lemmas proved in RRelation.lean**:
- `burgessR3Maximal_extension_exists` -- Zorn's lemma existence proof (matching r3Maximal_extension_exists structure)
- `BurgessR3Maximal_dcs'` -- accessor for DCS property
- `BurgessR3Maximal_burgessR3` -- accessor for burgessR3 property
- `BurgessR3Maximal_burgessRSet` -- accessor for forward Until
- `BurgessR3Maximal_burgessRSetSince` -- accessor for backward Since
- `burgessR3_untl_in` -- bridging: beta in B, gamma in C implies untl(beta, gamma) in A
- `burgessR3_snce_in` -- bridging: beta in B, gamma in A implies snce(beta, gamma) in C
- `burgessR3_gamma_not_in_B` -- C4 hard case key: neg(untl(gamma,delta)) in A + delta in C implies gamma not in B
- `burgessR3_gamma_not_in_B_since` -- C4' mirror
- `dcs_neg_insert_consistent` -- if phi not in DCS B, then {phi.neg} union B is consistent

**Build passes**, sorry count unchanged at 4.

## Active Sorry Sites (4 total, unchanged)

| File | Line | Description | What's Needed |
|------|------|-------------|---------------|
| CounterexampleElimination.lean | 332 | C4 hard case (Until) | ChronicleInvariant passed to elimination + adjacent pair argument |
| CounterexampleElimination.lean | 448 | C4' hard case (Since) | Mirror |
| ChronicleToCountermodel.lean | 615 | restricted_fuc Until | Full C5 with guard via C3 + limit_g |
| ChronicleToCountermodel.lean | 619 | restricted_fuc Since | Mirror |

## Key Technical Insights for Successor Session

### C4 Hard Case Resolution (Phase 5)

The complete argument for the C4 hard case (adjacent x,y):

1. `h_c2' : BurgessR3Maximal(f(x), g(x,y), f(y))` (from ChronicleInvariant)
2. `burgessR3_gamma_not_in_B`: gamma not in g(x,y) (from neg(untl(gamma,delta)) in f(x) + delta in f(y))
3. `dcs_neg_insert_consistent`: {gamma.neg} union g(x,y) is consistent
4. `set_lindenbaum`: extend to MCS D containing gamma.neg and g(x,y)
5. Set f(z) = D for new point z between x and y

**Critical issue**: The current C4 elimination function takes only `h_c0`, not the full ChronicleInvariant. To close the sorry:
- Modify `eliminate_C4_counterexample` signature to take `ChronicleInvariant chi` (or at least `h_c2' : chi.c2'`)
- The adjacent-pair case is straightforward with the proved lemmas
- For non-adjacent pairs: need to show x,y must be adjacent (or reduce to adjacent sub-interval)

**Non-adjacent pair concern**: The C4 counterexample says no z between x and y has gamma.neg. If x,y are not adjacent, there ARE intermediate points but ALL have gamma. For these, we need to propagate neg(untl(gamma,delta)) from f(x) to intermediate points, which is NOT directly available. Two approaches:
  (a) Show the hard case only arises for adjacent pairs (may require restructuring)
  (b) Process C4 counterexamples in order of interval width (adjacent first, then wider)

### Phase 3 (g-population) Status

Not started. The key challenge: every elimination function needs to construct BurgessR3Maximal g-values for new adjacent pairs. The `burgessR3Maximal_extension_exists` lemma provides existence, but the SEED needs to satisfy burgessR3. For C5 elimination (adding endpoint after all existing points), the seed is straightforward. For C4 (inserting between), Lemma 2.6 splitting is needed.

### Phase 4 (limit_g, C3 at limit) Status

Not started. Requires Phase 3 (populated g-values at finite stages). The g-immutability argument follows from g_agrees on EliminationResult.

### Phase 6 (restricted_fuc) Status

Not started. Requires Phases 4 and 5. The until_guard axiom (Phase 1, already done) provides the base point. limit_g + C3 provide the guard at intermediate points.

## Files Modified in This Session

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- deleted g_ordered/h_ordered, added burgessR3 definitions and BurgessR3Maximal, updated c2'
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- removed duplicate definitions, added existence proof, bridging lemmas, dcs_neg_insert_consistent
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- updated stale comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- updated stale comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- deleted claim_2_11, updated docstring

## Build Status

`lake build` succeeds. No regressions. 4 active sorry sites unchanged.

## Recommended Next Steps

1. **Phase 5 first** (close C4/C4' hard case) -- most impactful, all bridging lemmas proved
2. **Phase 3** (populate g-values) -- needed for Phase 5 to actually close sorry
3. **Phase 4** (limit_g, C3 at limit) -- needed for Phase 6
4. **Phase 6** (restricted_fuc) -- final sorry closure

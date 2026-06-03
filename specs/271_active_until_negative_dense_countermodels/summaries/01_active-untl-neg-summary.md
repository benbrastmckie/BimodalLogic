# Implementation Summary: Task #271

## Active Until-Negative Rule for Dense Countermodel Construction

### What Was Implemented

Modified the `untlNeg` and `snceNeg` rules in `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` to be **active** -- when no future/past times exist for a given time label, the rules now create a fresh time point via `branch.nextTime` and `timeOrd.addFuture`/`addPast`, then perform Reynolds co-decomposition there with full auto-propagation of formulas.

### Design Decision: Conservative Active Approach

The implementation uses a more conservative approach than the original plan specified:

- **Original plan**: Make `| [] =>` (empty unprocessed list) always active, creating fresh times regardless of whether existing future times exist
- **Implemented**: Active case fires ONLY when `futureOf l.time` (or `pastOf l.time`) is genuinely empty. When future/past times exist but are all processed, the rule returns `notApplicable` as before.

**Rationale**: The conservative approach preserves the proof structure in `sat_untl_neg` and `sat_snce_neg` without any modifications. The proofs rely on the fact that `applyRule .untlNeg` returns `notApplicable` when `futureOf t` is non-empty but all times are processed. With the conservative approach, this property is preserved, and the `if futureTimes.isEmpty` guard ensures the active case only fires when no future times exist at all.

The active rule still achieves the desired effect: when `F(U(event, guard))` is at a time with no future times, it creates one. The created time's decomposition products (Branch 2) include `F(U(event, guard))` at the new time, which then triggers the active rule again (since `futureOf freshTime = []`). This creates a chain of fresh times that terminates via subset blocking.

### Auto-Propagation

Both active rules include full auto-propagation to the fresh time:
- `T(GA)` formulas via `allFuturePosFormulas` / `allPastPosFormulas`
- `F(FA)` formulas via `someFutureNegFormulas` / `somePastNegFormulas`
- Other `F(U(...))` / `F(S(...))` formulas (excluding self) via `untlNegFormulas` / `snceNegFormulas`
- Cross-modal-temporal persistence: `T(box A)` and `F(diamond A)` via `boxDiamondPersistence`

### Files Modified

1. **`Theories/Bimodal/Metalogic/Decidability/Tableau.lean`**
   - `untlNeg` case in `applyRule`: added active time creation when `futureOf l.time` is empty (~30 lines)
   - `snceNeg` case in `applyRule`: symmetric active time creation when `pastOf l.time` is empty (~30 lines)

2. **`Theories/Bimodal/Metalogic/Decidability/Saturation.lean`**
   - Added 8 new `#eval` tests (AN1-AN8) exercising the active rule
   - Tests cover: validity proofs, satisfiability (countermodel construction), nested Until, fuel assessment

### Files NOT Modified (no changes needed)

- `CountermodelExtraction.lean`: `sat_untl_neg`, `sat_snce_neg`, and `branchTruthLemma` proofs all compile unchanged
- `Saturation.lean` (expansion/blocking logic): No changes needed to the expansion loop or blocking mechanism

### Verification Results

- **Build**: `lake build` passes with zero errors (1682 jobs)
- **Sorry count**: 0 in modified files, 0 in Decidability directory
- **Axiom count**: 0 new axioms
- **Regression tests**: All 36 pre-existing tests pass with identical results
- **New tests**: All 8 new tests (AN1-AN8) pass
- **Fuel assessment**: All test formulas resolve at fuel=500 with no timeout issues

### Test Results

| Test | Formula | Expected | Result |
|------|---------|----------|--------|
| AN1 | G(p) -> not F(not p) | valid | PASS |
| AN2 | U(p,q) satisfiable | open branch | PASS |
| AN3 | U(p,q) -> U(p,q) | valid (identity) | PASS |
| AN4 | S(p,q) satisfiable | open branch | PASS |
| AN5 | H(p) -> not P(not p) | valid | PASS |
| AN6 | U(U(p,q),q) -> U(U(p,q),q) | valid at fuel=500 | PASS |
| AN7 | U(p,q) -> F(p) | valid at fuel=500 | PASS |
| AN8 | not U(p,q) satisfiable | open at fuel=500 | PASS |

### Plan Deviations

1. **Phase 1 Task 1.2**: Active case fires only when `futureOf` is empty (not when all existing times are processed). This preserves proof compatibility while still enabling fresh time creation.
2. **Phase 2**: No proof changes needed (skipped). The conservative approach made the existing proofs work unchanged.
3. **Phase 3**: No downstream fixes needed (skipped). The proof signatures were unchanged.
4. **Phase 4**: Used different test formulas than proposed. The proposed formulas (e.g., `U(p, bot) -> U(p, p)`) were already handled by existing tests; new tests focused on exercising the active case specifically.
5. **Phase 5**: Used `buildTableau` directly instead of `decideAutoAdaptive` since `Saturation.lean` does not import `DecisionProcedure.lean`.

### Fuel Assessment

The conservative approach has minimal fuel impact:
- The active case only creates ONE fresh time per time label before reverting to passive mode
- Subsequent chain creation happens through Branch 2's propagation of `F(U(event, guard))` to the new time
- Subset blocking terminates the chain
- All test formulas resolve at fuel=500 with no increase needed
- No fuel adjustment recommended for `decideAutoAdaptive`

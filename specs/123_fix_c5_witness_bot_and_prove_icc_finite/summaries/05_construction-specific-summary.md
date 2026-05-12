# Implementation Summary: Construction-Specific IsSuccArchimedean (Partial)

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: PARTIAL
- **Plan**: plans/05_construction-specific.md

## What Was Done

### Phase 1 [COMPLETED] (prior work)
- Imports and `order_succ_eq` / `order_pred_eq` proofs already in place.

### Phase 2 [PARTIAL]
Restructured the sorry at `limitDomSubtype_isSuccArchimedean` (line ~1211 of `ChronicleToCountermodel.lean`).

**Before**: Raw sorry with goal `False` from hypothesis `h_not_cofinal : forall n, succ^[n] a < b`.

**After**: The proof is structured as:
1. **Steps 1-2**: Proved `h_orbit_lt_pred : forall n k, succ^[n] a < pred^[k] b` (succ-orbit strictly below all pred-iterates) via induction on k with orbit-meeting contradiction.
2. **Step 3**: Established monotone convergence in R. The succ-orbit values cast to R are monotone and bounded, converging to `L = iSup f_up`. All pred-orbit values are >= L.
3. **Step 4**: Proved the `suffices` block: IF a domain point `c` exists with `c.val = L` and `c` above the entire orbit, THEN False. The contradiction uses:
   - `pred(c) < c` (immediate predecessor)
   - `pred(c).val < L` (since pred(c) < c and c.val = L)
   - Orbit convergence to L from below gives `succ^[n0](a).val > pred(c).val` for large n0
   - So `pred(c) < succ^[n0](a) < c`, but `succ(pred(c)) = c` means no domain points between pred(c) and c. Contradiction.

**Remaining sorry**: `exists c : LimitDomSubtype, (c.val : R) = L and forall n, succ^[n] a < c`

## Barrier Analysis

The remaining sorry requires showing the omega-chain construction cannot produce the **gap-at-L scenario**: an infinite succ-orbit and infinite pred-orbit converging to the same limit L from opposite sides with no domain point at L.

This scenario IS order-theoretically consistent. A counterexample domain can be constructed manually: take `{1 - 1/(n+1) | n in Nat} union {1 + 1/(n+1) | n in Nat}` with succ/pred on each orbit. This domain has a gap at L=1 with no domain point there, and IsSuccArchimedean fails.

The omega-chain construction adds domain points to satisfy C4/C5 conditions. The proof that it cannot produce the gap-at-L scenario requires analyzing how C4/C5 elimination interacts with accumulation points of succ/pred orbits.

### Approaches Tried

| Approach | Status | Barrier |
|----------|--------|---------|
| A: Monotone convergence in R | Partial | L-in-domain case proved; L-not-in-domain case requires construction-specific argument |
| B: Icc finiteness | Not started | Requires proving limit_dom intersected with [a,b] is finite (hard without construction analysis) |
| C: WellFoundedGT | Ruled out | LimitDomSubtype has NoMaxOrder, so WellFoundedGT is false |
| Finite subformula closure | Investigated | Consecutive domain points can have identical MCS, so this doesn't bound interval size |
| Pure order theory | Ruled out | Gap-at-L is order-theoretically consistent |

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
  - Lines ~1211-1303: Restructured sorry body with convergence setup + suffices block

## Verification

- Build passes (with existing sorry warnings)
- 1 sorry remains at `limitDomSubtype_isSuccArchimedean`
- No new axioms introduced
- No changes to theorem statements

## Recommendations for Next Steps

1. **Research the omega-chain construction**: Specifically, analyze how `limit_satisfies_c5_strong` and `limit_satisfies_c4` interact near accumulation points. The C5 condition for formulas other than `U(T, bot)` might force witnesses that cross the gap.

2. **Consider the finite subformula approach from the literature**: Venema/de Jongh/Veltman may provide a combinatorial argument that avoids convergence entirely. The key would be showing that the succ-orbit's MCS pattern is eventually periodic, and periodic orbits must close.

3. **Alternative suffices**: Instead of requiring a domain point at exactly L, it might suffice to find a domain point c with `pred(c).val < L`. This is a weaker requirement that might be provable from the construction.

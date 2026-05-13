# StageInductionGapAnalysis (Archived)

Archived from `ChronicleToCountermodel.lean` (task 123, 2026-05-13).

## What This Contains

Three dead-end proof attempts for `IsSuccArchimedean` of the chronicle limit domain:

1. **`succ_reaches_dom_N`** — Stage induction approach. Boundary cases (new point above max(dom(N)) or below min(dom(N))) are intractable because `succ(max_N)` may enter the domain at an arbitrarily later stage.

2. **`limit_dom_points_are_succ_iterates`** — Real-analysis convergence approach. Leads to the same gap scenario as `succ_cofinal`.

3. **`succ_cofinal` gap analysis** — The full convergence-based proof attempt with Z1/Doets maximum principle analysis. The gap scenario (orbit converging to L from below, pred-chain from above) is genuine: the constant-MCS case is consistent with all temporal axioms including Z1 and Prior-UZ.

## Why Archived

The sorry at `succ_cofinal` represents a genuine limitation of the Burgess chronicle construction under strict (irreflexive) temporal semantics, not a missing proof step. Extensive analysis (12+ research rounds, 4-teammate investigation) confirmed:

- The constant-MCS gap scenario is consistent with ALL axioms (Z1, Prior-UZ, all BX axioms)
- The construction CAN produce constant-MCS gaps (BurgessR3Maximal returns the starting MCS when it is temporally saturated)
- Sub-formula closure finiteness does not help (limit_f is over all formulas, not a finite closure)
- The "beyond the gap" problem prevents establishing FG(phi) at orbit points

## Replacement

Task 129 (weak/reflexive completeness + conservative extension) provides `IsSuccArchimedean` via a Henkin canonical model where every point is a distinct MCS, bypassing the gap scenario entirely.

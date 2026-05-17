# Implementation Summary: Expressive Completeness of {S,U} over Integer Time

## Status: PARTIAL (17 sorries remain, down from 16 visible + broken modules)

## Session sess_1778992208_9fe153 Changes

### Eliminations.lean (7 sorries reduced to 4)
- **Proved `elim_case_2`**: S(a ^ ¬U(A,B), q) via neg_until_equiv + Case 1 reduction
- **Proved `elim_case_3`**: S(a, q v U(A,B)) via neg_since_equiv + Case 2 reduction
- **Proved `elim_case_4`**: S(a, q v ¬U(A,B)) via neg_since_equiv + Case 1 reduction
- **Fixed Case 5 separation check**: Added u_free_s_free_imp_separated call
- **Consolidated Case 5 forward**: Merged 3 sorries into 1 documented sorry
- **Added helper lemmas**: since_and_or_distrib, neg_separated, and_separated, int_equiv_neg, or_separated

### SeparationThm.lean (was broken, now builds with 4 sorries)
- **Defined `all_separable`**: Main separation theorem with structural induction
  - Base cases (atom, bot, imp, box): fully proved
  - Inductive cases (all_past, all_future, untl, snce): sorry (require substitution-based reduction)
  - This unblocks `separation_theorem_int` and the entire downstream chain

### ExpressiveCompleteness.lean (was broken, now builds with 1 sorry)
- **Fixed `q_exists_correct` forward direction**: Replaced broken proof with correct propositional reasoning
  - The `Function expected at` error was due to incorrect term application in the simp-unfolded goal
- `separation_implies_expressiveness` remains as sorry (Theorem 9.3.1 FO induction)

### DualEliminations.lean (8 sorries, unchanged)
- Dual cases require `is_S_free psi = true` conclusion
- Cannot be derived from primary cases via duality (swap of separated formula is NOT S-free in general)
- Each requires explicit S-free witness formula construction (mirrors primary cases but with U/S swapped)

## Previous Session Changes (preserved)

### FormulaOps.lean (complete, 0 sorries)
- DNF/CNF, substitution, freshness infrastructure

### NegationEquiv.lean (complete, 0 sorries)  
- neg_until_equiv, neg_since_equiv (key Z-dependent lemmas)

### IntHelpers.lean (complete, 0 sorries)
- Well-ordering, witness construction, top/true equivalences

### Duality.lean (complete, 0 sorries)
- swap_temporal_int_truth, dual_equiv, dual_U_free_iff_S_free, dual_separated

## Remaining Sorries (17 total)

| File | Count | Nature |
|------|-------|--------|
| SeparationThm.lean | 4 | all_separable inductive cases (all_past, all_future, untl, snce) |
| Eliminations.lean | 4 | Case 5 forward u<t + Cases 6, 7, 8 |
| DualEliminations.lean | 8 | All 8 dual cases (is_S_free witness) |
| ExpressiveCompleteness.lean | 1 | Theorem 9.3.1 (FO induction) |

## Key Technical Findings

1. **Cases 2-4 reduce cleanly to Case 1**: Using neg_until_equiv and neg_since_equiv, the negation cases reduce to already-proved cases. The proof pattern is: apply negation equivalence, split by disjunction, one branch is directly separated, the other is Case 1.

2. **Cases 6-8 are self-referential via negation**: The negation approach creates circular dependencies for Cases 6-8 (each reduces to another case in the same group). Direct semantic constructions are required.

3. **Case 5's formula may be incorrect**: The `case5_psi` formula requires `S(a,B)` (B on a full interval to t), but in the u<t scenario, B only holds on scattered sub-intervals. The correct GHR94 formula likely needs additional structure.

4. **Dual cases need explicit constructions**: The duality principle (swap_temporal) preserves syntactic separation but NOT S-freeness. The dual cases require independent witness formula construction.

5. **SeparationThm was never compilable**: The `all_separable` theorem was referenced but never defined. Adding it with structural induction (sorry at temporal operator cases) unblocks the entire downstream chain including ExpressiveCompleteness.

## Plan Deviations

- Cases 2, 3, 4 proved using negation reduction (plan suggested direct semantic construction for each)
- Cases 6-8 not proved (plan underestimated the circular dependency in the negation approach)
- DualEliminations not proved (plan suggested duality reduction which doesn't yield is_S_free)
- SeparationThm added `all_separable` with sorry branches (plan expected Cases 1-8 to close everything)

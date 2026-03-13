# Archived: Strict Density Frame Condition Attempts (Task 956)

## Archive Date
2026-03-13

## Why Archived

This code represents multiple attempts to prove `density_frame_condition_strict` - a strict
density property requiring that the intermediate witness W satisfies:
- CanonicalR(M, W) AND CanonicalR(W, M')
- NOT CanonicalR(W, M) AND NOT CanonicalR(M', W)

These attempts are structurally blocked due to the `h_indep` problem:

### The Core Issue

When attempting strict density via iteration:
1. Apply non-strict `density_frame_condition` to get intermediate W
2. Check if W is in M's equivalence class (CanonicalR M W AND CanonicalR W M)
3. If YES: Need to "escape" the equivalence class by finding a new distinguishing formula
4. The escape mechanism requires proving that iterating produces genuinely new witnesses

The `h_indep` problem: When W ~ M (same equivalence class), the next iteration uses a
different distinguishing formula. But proving this iteration terminates requires showing
that each step either:
- Escapes the equivalence class (done!)
- Uses a "smaller" formula in some well-founded order

This termination argument could not be established at the MCS level because:
- The measure (formula size, subformula closure cardinality) doesn't decrease predictably
- Reflexive MCSs create infinite chains of equivalent witnesses
- The distinguishing formula tracking becomes circular

### Resolution

Research-048 established that strict density should be proven at the **quotient level**
where the equivalence class problem doesn't arise:
- `toAntisymmetrization_lt_toAntisymmetrization_iff` gives strict ordering directly
- At the quotient, [M] < [W] < [M'] is the only thing needed
- The non-strict `density_frame_condition` (kept in main file) provides W; if W ~ M,
  then [W] = [M], so apply density again with W in place of M

The quotient-first approach is implemented in `QuotientDensity.lean`.

## What's in This Archive

- `DensityFrameCondition_StrictAttempt.lean`: Lines 271-2559 from the original file
  - `density_frame_condition_strict` theorem (26 sorries)
  - Various case analysis attempts (Case A, Case B, reflexive/irreflexive cases)
  - Iteration machinery that couldn't be completed
  - Helper lemmas for the iteration approach

## What's NOT Archived (Still in Main File)

- `caseB_M_not_reflexive` - Helper lemma (line 72)
- `caseB_G_neg_not_in_M` - Helper lemma (line 89)
- `density_frame_condition_caseA` - Core Case A lemma (line 130)
- `density_frame_condition` - Main non-strict theorem (line 191)
- `irreflexive_mcs_has_strict_future` - Strict seriality (line 249)

These theorems are sorry-free and form the foundation for the quotient-first approach.

## References

- Task 956 research-048.md: Quotient-first strategy
- Task 956 research-047.md: Team trajectory analysis
- Task 956 implementation-024.md: Current plan (v024)

## Recovery Instructions

If this code is needed in the future, it can be recovered by:
1. Copy `DensityFrameCondition_StrictAttempt.lean` back to StagedConstruction/
2. Update imports
3. Address the 26 sorries using the `h_indep` solution (if found)

The code is preserved for historical reference and potential future approaches.

# Implementation Summary: Task #622

**Completed**: 2026-01-19
**Duration**: Approximately 1.5 hours

## Changes Made

Proved the `applyRule_decreases_complexity` theorem in Saturation.lean. This theorem establishes that applying any of the 16 tableau rules to a signed formula produces formulas with strictly smaller total complexity than the original. This is the core insight for proving termination of the tableau decision procedure.

### Proof Strategy

The proof uses case analysis on all 16 tableau rules:
- **13 Linear rules** (andPos, orNeg, impNeg, negPos, negNeg, boxPos, boxNeg, diamondPos, diamondNeg, allFuturePos, allFutureNeg, allPastPos, allPastNeg): Each case shows that the output formulas have smaller total complexity than the input.
- **3 Branching rules** (impPos, andNeg, orPos): Each case shows that every branch has smaller total complexity than the input.

### Helper Lemmas Added

Four helper lemmas were added to connect the pattern matching functions to formula structure:
- `asAnd?_eq_some_iff`: Characterizes when `asAnd?` returns `some`
- `asOr?_eq_some_iff`: Characterizes when `asOr?` returns `some`
- `asNeg?_eq_some_iff`: Characterizes when `asNeg?` returns `some`
- `asDiamond?_eq_some_iff`: Characterizes when `asDiamond?` returns `some`

These lemmas allow the proof to rewrite `sf.formula` to the corresponding pattern when needed for complexity calculations.

### Key Insight

The proof relies on the formula complexity function:
- `atom n` and `bot` have complexity 1
- `imp φ ψ` has complexity `1 + φ.complexity + ψ.complexity`
- `box φ`, `all_past φ`, `all_future φ` have complexity `1 + φ.complexity`

This ensures that every decomposition produces strictly smaller total complexity, as the rule application removes at least the constructor overhead.

## Files Modified

- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`
  - Added 4 helper lemmas for pattern matching (lines 264-295)
  - Replaced `all_goals sorry` with complete proof for all 16 cases (lines 363-624)

## Verification

- Lake build: Success (no errors)
- All 16 cases proven (no `sorry` in `applyRule_decreases_complexity`)
- Downstream theorems remain valid

## Notes

- The proof is structured by case with clear comments indicating which rule each case handles
- The branching rules (impPos, andNeg, orPos) require proving the complexity bound for each branch in the list
- The remaining `sorry` in the file (line 696) is in `expansion_decreases_measure`, which was not part of this task's scope
- This theorem is a prerequisite for proving termination of the tableau expansion procedure

## Related Tasks

- Task 490 (parent): This was Phase 2 of the larger decidability proof
- Task 623: Prove `expansion_decreases_measure` (depends on this theorem)

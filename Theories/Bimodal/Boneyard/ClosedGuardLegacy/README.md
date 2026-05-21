# ClosedGuardLegacy (ARCHIVED)

**Archived**: 2026-04-30 (task 109)
**Reason**: Closed guard semantics `[t,s]` replaced by open guard `(t,s)`

## Overview

Four files (352 lines, 0 sorries) documenting the closed/half-closed guard
semantics for Until/Since operators. All code is preserved as documentation only
(no imports, type signatures in markdown blocks). The closed guard approach was
replaced by open guard semantics to match Kamp 1968, Burgess 1982, Xu 1988,
Reynolds 1992, and the paper.

## Files

| File | Lines | Description |
|------|------:|-------------|
| ClosedGuardAxioms.lean | ~100 | BX8/BX9 and until_guard/since_guard axiom constructors |
| ClosedGuardRRelation.lean | ~80 | MCS lemmas using until_guard and since_guard |
| ClosedGuardSoundness.lean | ~90 | Validity theorems relying on guard inequality at base point |
| ClosedGuardTemporalDerived.lean | ~80 | BX9-dependent derived theorems |

## What Was Removed

- **BX9 / BX9'**: Until/Since elimination to disjunction -- unsound under open guard
  because the guard interval `(t,s)` excludes `t`, so `phi(t)` is not guaranteed
- **BX8 / BX8'**: Reflexive Until/Since introduction -- unsound under strict future
- **until_guard / since_guard**: Guard at base point -- invalid when base point excluded

## Relationship to Active Code

The active axiom system uses open guard `(t,s)` semantics defined in
`ProofSystem/Axioms.lean`. See task 113 for the refactoring history.

## References

- Task 109: Closed guard archival
- Task 113: Open guard refactoring (BX8/BX9 removal)

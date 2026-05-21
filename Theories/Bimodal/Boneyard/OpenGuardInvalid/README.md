# OpenGuardInvalid (ARCHIVED)

**Archived**: 2026-05-20 (task 173)
**Reason**: 27 sorry-tainted definitions invalid under open guard (t,s) semantics

## Overview

Sorry stubs from TemporalDerived.lean (1 file, 215 lines, 23 sorries). These
definitions relied on BX8 (reflexive Until/Since introduction), BX9 (Until/Since
elimination to disjunction), reflexive temporal order, seriality, or density axioms
-- all invalid or unavailable under the current open guard semantics.

## Files

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| OpenGuardTemporalDerived.lean | 215 | 23 | 27 archived definitions (5 with bodies, 22 type signatures) |

## What Was Removed

- 19 direct sorry stubs (net 19 sorry reduction from active code)
- 8 transitive sorry dependents (used sorry-bearing definitions)
- 14 sorry-free definitions remain in active TemporalDerived.lean (untouched)

## Invalid Dependencies

- **BX8** (until_step/since_step): Reflexive Until/Since introduction
- **BX9** (until_elim/since_elim): Until/Since elimination to disjunction
- **Reflexive temporal order**: alpha -> F(alpha), invalid under strict future
- **Seriality**: G(bot) -> bot, requires seriality derivation not yet available
- **Density**: G(G(phi)) -> G(phi), requires density axiom not in current system

## Relationship to Active Code

The 14 sorry-free definitions remain in `Theorems/TemporalDerived.lean`. The
closed-guard original proofs (where they existed) are separately archived in
`Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`.

## References

- Task 113: Open guard refactoring (BX8/BX9 removal)
- Task 173: Archival of 27 sorry-tainted definitions

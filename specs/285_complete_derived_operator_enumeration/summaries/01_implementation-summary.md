# Implementation Summary: Task #285

- **Task**: 285 - Complete derived operator enumeration for dataset generation
- **Status**: Implemented
- **Phases**: 3/3 completed
- **Files Modified**: 2 (Formula.lean, FormulaEnumerator.lean)

## What Was Done

Added 7 derived operators (diamond, always, sometimes, next, prev, weak_future, weak_past) to the formula enumerator as first-class enumeration targets with pattern-aware complexity of 1 each.

### Phase 1: Complexity patterns and enumerator branches

- Added 7 complexity pattern cases in `Formula.complexity` (Formula.lean):
  - `diamond(phi)` = `imp (box (imp phi bot)) bot` -> 1 + phi.complexity
  - `always(phi)` = deeply nested H-and-phi-and-G pattern -> 1 + phi.complexity (was 15)
  - `sometimes(phi)` = neg(always(neg phi)) pattern -> 1 + phi.complexity (was 23)
  - `next(phi)` = `untl phi .bot` -> 1 + phi.complexity
  - `prev(phi)` = `snce phi .bot` -> 1 + phi.complexity
  - `weak_future(phi)` = phi-and-G(phi) pattern -> 1 + phi.complexity (was 8)
  - `weak_past(phi)` = phi-and-H(phi) pattern -> 1 + phi.complexity (was 8)
- Added `#eval` verification: all 7 operators return complexity 2 for `operator(atom)`
- Added 8 enumeration branches in `enumExactHelper`:
  - Diamond: gated by `modalBudget > 0`, overhead 1, with structurallyTrivial filter
  - always, sometimes, next, prev, weak_future, weak_past: gated by `temporalBudget > 0`, overhead 1
- Updated parallel enumeration path (`enumerateLevelParallel`) with same 8 branches

### Phase 2: hasDerivedTemporal extension

- Added 7 structural pattern matches in `hasDerivedTemporal`:
  - `always`, `sometimes`: deeply nested patterns for H-and-phi-and-G and neg(always(neg phi))
  - `weak_future`, `weak_past`: phi-and-G(phi) and phi-and-H(phi)
  - `diamond`: `imp (box (imp _ bot)) bot`
  - `next`: `untl _ .bot`
  - `prev`: `snce _ .bot`
- Verified `extractOperatorProfile` in InterestingnessMetrics.lean already correctly detects all 7 operators through recursive traversal (no changes needed)

### Phase 3: Verification

- Full `lake build` passes (pre-existing error in CanonicalTaskRelation.lean is unrelated)
- Zero new sorries in modified files
- Zero new axioms in modified files
- Formula count at c4: 7,852 (up from ~960 pre-task-285)
- Formula count at c5: 75,914
- Bimodal slice at c5: 45,111 formulas
- All new operators confirmed present in c2 enumeration (diamond(p), next(p), prev(p))
- `hasBimodalInteraction` correctly detects all 7 operator + box combinations

## Plan Deviations

- Optional `FormulaProfile` expansion (hasAlways, hasSometimes, etc. fields) was skipped -- `hasDerivedTemporal` covers all 7 operators, and `extractOperatorProfile`'s recursive traversal correctly identifies operator components within composite expansions
- `sampleOne` and `sampleOneRandom` (random sampling paths) were not updated with new operators -- these are separate from the exhaustive enumeration path that was the plan's primary scope

## Metrics

| Metric | Before | After |
|--------|--------|-------|
| Complexity of diamond(atom) | 6 | 2 |
| Complexity of always(atom) | 15 | 2 |
| Complexity of sometimes(atom) | 23 | 2 |
| Complexity of next(atom) | 3 | 2 |
| Complexity of prev(atom) | 3 | 2 |
| Complexity of weak_future(atom) | 8 | 2 |
| Complexity of weak_past(atom) | 8 | 2 |
| c4 formula count (5 atoms, m2, t2) | ~960 | 7,852 |
| c5 formula count (5 atoms, m2, t2) | ~9,100 | 75,914 |
| c5 bimodal slice | ~6,072 | 45,111 |

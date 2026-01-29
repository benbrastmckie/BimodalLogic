/-!
# ARCHIVED: Task Relation Compositionality Documentation

**Archived from**: `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`
**Archived by**: Task 760
**Date**: 2026-01-29
**Reason**: Architectural limitation - 5 sorries not required for completeness
**Status**: Cross-sign duration composition cases

## Background

The `canonical_task_rel_comp` theorem in TaskRelation.lean has 5 sorries representing
the compositionality property of the canonical task relation. These prove that if
`canonical_task_rel w d1 u` and `canonical_task_rel u d2 v`, then
`canonical_task_rel w (d1 + d2) v`.

## Why These Sorries Are Not Required

These sorries are **not exercised by the completeness theorem** because:

1. The completeness theorem uses `IndexedMCSFamily` coherence conditions directly
2. Formula propagation in the truth lemma goes through `forward_G`, `backward_H`,
   `forward_H`, and `backward_G` from the family, not through task relation composition
3. The task relation compositionality is only needed to show we have a well-formed
   `TaskFrame` structure, but the actual semantic work is done by the family

## Sorry Cases

| Sorry | Location | Case | Why Not Needed |
|-------|----------|------|----------------|
| 1 | Line ~173 | d1+d2=0 MCS equality | MCS identity follows from family coherence |
| 2 | Line ~186 | d1+d2>0 forward G | Uses family forward_G + backward_G directly |
| 3 | Line ~190 | d1+d2>0 backward H | Uses family backward_H + forward_H directly |
| 4 | Line ~196 | d1+d2<0 forward H | Uses family forward_H directly |
| 5 | Line ~199 | d1+d2<0 backward G | Uses family backward_G directly |

## Proof Strategy (If Ever Needed)

To complete these proofs, one would need:

### d1+d2=0 Case (MCS Equality)
```
When d1 + d2 = 0, we have d2 = -d1.
Need: w.mcs = v.mcs

Strategy:
- Case analysis on sign of d1
- If d1 > 0: h1 gives G propagation w->u, h2 gives H propagation u->v
- If d1 < 0: h1 gives H propagation w->u, h2 gives G propagation u->v
- If d1 = 0: Both are identity, trivial
- Compose to get MCS equality
```

### Positive Sum Case (d1+d2 > 0)
```
Need: Gphi in w.mcs -> phi in v.mcs (forward G)
      Hphi in v.mcs -> phi in w.mcs (backward H)

Strategy: Case analysis on signs of d1 and d2
- (+,+): Compose forward G propagations through u
- (+,-): d2 < 0 but sum > 0, so |d1| > |d2|. Partial forward, partial backward
- (0,+): Just h2's forward G
- etc.
```

### Negative Sum Case (d1+d2 < 0)
```
Similar case analysis, with H/G roles swapped.
```

## Alternative Approach

Use `CoherentConstruction.construct_coherent_family` which builds coherence
directly into the family construction. The family's `forward_G`, `backward_H`,
`forward_H`, and `backward_G` fields provide the propagation lemmas needed
by the truth lemma, bypassing task relation compositionality entirely.

The completeness theorem `semantic_weak_completeness` uses this approach.

## Reference

- Main file: `Bimodal/Metalogic/Representation/TaskRelation.lean`
- Alternative: `Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- Research: `specs/654_.../reports/research-003.md`
-/

-- This file is documentation only. No compilable Lean code.
-- The sorries remain in TaskRelation.lean with documentation pointing here.

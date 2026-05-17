# Phase 2 Handoff: Case 5 Blocked

**Date**: 2026-05-17
**Session**: sess_1779003456_c5b522
**Phase**: 2 (Prove Case 5 via Case 3 Reduction)
**Status**: BLOCKED

## Immediate Next Action

The plan's Phase 2 strategy (Case 3 reduction for Case 5) is fundamentally blocked by a circular dependency between Cases 5 and 8. The next action should be to REVISE the plan to either:
1. Merge Phases 2-5 into a single "prove all cases via multi-U induction" phase
2. Or prove Cases 5-8 together using junction_depth induction (Phase 5's approach applied earlier)

## Key Discovery: Circular Dependency

Applying the Case 3 duality to Case 5 `S(a^U(A,B), q v U(A,B))` produces:
- H-part: `some_past(a^U(A,B))` -- separable via Case 1
- S-part: `S(neg q ^ neg U(A,B), neg a v neg U(A,B))` -- this is Case 8

Trying to prove Case 8 via duality produces a Case 5 instance back. The cycle:
```
Case 5(A,B) -> Case 8(A,B) -> Case 5(A',B') where A'=neg A^neg B, B'=neg A
  -> Case 8(A',B') -> Case 5(A, A v B) -> Case 8(A, A v B) -> ...
```

Parameters cycle: (A,B) -> (neg A^neg B, neg A) -> (A, AvB) -> (neg A^neg B, neg A) -> ...
Never terminates.

## Attempted Direct Constructions

Tested and DISPROVED multiple candidate separated equivalents:
- `S(a^U(A,B), q) v [S(a,B) ^ (U(A,B) v A)]` -- counterexample: a(0)=T, A(2)=T, B(1)=T only, q(2)=q(3)=T, q(0)=q(1)=F, t=4
- The guard `q v U(A,B)` on integers can be satisfied by chains of U(A,B) interspersed with q, requiring intermediate "stepping stones" at A-witnesses

The correct formula `S(A ^ S(a,B), q)` captures ONE step but the backward direction fails at the event point u (neither q(u) nor U(A,B)(u) is guaranteed).

## Correct Architecture (for plan revision)

Cases 5-8 require the multi-U induction framework (Lemma 10.2.6) because:
1. Each case reduction introduces a DIFFERENT U-formula via neg_until_equiv
2. The interaction between two U-formulas (U(A,B) and U(A',B')) can only be handled by treating one as an atom, eliminating the other, substituting back, and re-separating
3. This "iterated elimination" is exactly what Lemma 10.2.6 provides

Recommended plan revision: build Phases 4-5 infrastructure FIRST, then prove Cases 5-8 as applications of the hierarchy. This inverts the current dependency chain:
- Current plan: Phase 2 (Case 5) -> Phase 3 (Cases 6-8) -> Phase 4 (hierarchy) -> Phase 5 (junction depth)
- Proposed: Phase 2' (hierarchy framework) -> Phase 3' (all Cases 5-8 via hierarchy)

## Files Unchanged

No source files were modified during this phase attempt. The build remains passing.

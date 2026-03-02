# Phase 1 Blocker Analysis: quotientSucc/quotientPred Inverse Property

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Plan**: implementation-004.md (Grothendieck construction)
**Phase**: 1 - Grothendieck Time Domain Definition
**Status**: BLOCKED
**Date**: 2026-03-01
**Session**: sess_1772410461_a3b7c2

## Summary

Phase 1, Task 1.1 (`quotientSucc_pred_inverse`) is **mathematically impossible** under the
current axiomatic system. The property `quotientPred (quotientSucc q) = q` requires
`G(phi) -> H(phi)` to be derivable, which is semantically invalid.

## Detailed Analysis

### What Was Attempted

The plan requires proving that `quotientSucc` and `quotientPred` are inverses on the
BidirectionalQuotient. At the fragment level, this means showing:

```
fragmentHPred (fragmentGSucc w) ~ w  (preorder equivalent)
```

i.e., both `w <= fragmentHPred(fragmentGSucc w)` and `fragmentHPred(fragmentGSucc w) <= w`.

### Why It Fails

**Direction 1** (`w <= fragmentHPred(fragmentGSucc w)`):

Requires: `GContent(w.world) subset (fragmentHPred(fragmentGSucc w)).world`

Since `fragmentHPred(fragmentGSucc w)` extends `HContent((fragmentGSucc w).world)`,
this requires showing that for every `phi in GContent(w.world)` (i.e., `G(phi) in w.world`),
we have `phi in HContent((fragmentGSucc w).world)` (i.e., `H(phi) in (fragmentGSucc w).world`).

This in turn requires: from `G(phi) in w.world`, derive `H(phi) in (fragmentGSucc w).world`.

Since `(fragmentGSucc w).world` extends `GContent(w.world)`, and `G(phi) in w.world` gives
`G(G(phi)) in w.world` (by 4-axiom), we get `G(phi) in (fragmentGSucc w).world`. But we need
`H(phi) in (fragmentGSucc w).world`, which requires the implication `G(phi) -> H(phi)`.

**`G(phi) -> H(phi)` is semantically INVALID:**

Countermodel: Linear order {0, 1, 2}. Let phi hold at times 1 and 2 only (not 0).
- At time 1: G(phi) holds (phi at all s >= 1, i.e., at 1 and 2).
- At time 1: H(phi) fails (phi does not hold at time 0).

Therefore `G(phi) -> H(phi)` is not valid, hence not derivable.

**Direction 2** (`fragmentHPred(fragmentGSucc w) <= w`):

A similar analysis shows this direction would require
`GContent((fragmentHPred(fragmentGSucc w)).world) subset w.world`. Through the chain
of duality lemmas, this ultimately reduces to needing `G(phi) -> H(phi)` again,
or at least some form of GContent containment that the axioms do not provide.

### Axioms Investigated

| Axiom | Statement | Gives |
|-------|-----------|-------|
| temp_t_future | G(phi) -> phi | phi in fragmentGSucc w, NOT in w |
| temp_4 | G(phi) -> G(G(phi)) | G(phi) in GContent(w), hence in fragmentGSucc w |
| temp_a | phi -> G(P(phi)) | G(P(phi)) in w, so P(phi) in fragmentGSucc w |
| past_temp_a | phi -> H(F(phi)) | H(F(phi)) in w, so F(phi) in HContent |
| temp_l | always(phi) -> G(H(phi)) | Requires H(phi) as premise (circular) |

None of these produce `H(phi)` from `G(phi)` alone.

### Impact on Plan

This blocker affects ALL downstream phases:

- **Task 1.1**: Unprovable
- **Task 1.3** (`quotientSuccIter_add`): Requires Task 1.1 for mixed-sign cases
- **Phase 2** (TaskFrame compositionality): Requires `quotientSuccIter_add`
- **Phases 3-5**: All depend on Phase 2

### Alternative Approaches Considered

1. **Use totality of fragment order**: The fragment is totally ordered, so either
   `w <= fragmentHPred(fragmentGSucc w)` or the reverse. But totality only gives
   ONE direction, and we need BOTH for quotient equality. Both cases are consistent
   a priori, so totality doesn't determine which holds.

2. **GContent equality approach**: If `GContent(w) = GContent(fragmentHPred(fragmentGSucc w))`,
   then by the T-axiom, both would be in the same quotient class. But GContent can grow
   through `fragmentGSucc` (the Lindenbaum extension can introduce new G-formulas), so
   this equality fails in general.

3. **Use different definition of quotientSuccIter**: For same-sign additions,
   `quotientSuccIter_add` works fine. Only mixed-sign addition is problematic. But the
   TaskFrame compositionality axiom requires full generality.

4. **Use chain-based task_rel (research-018 Section 8)**: Define
   `task_rel w d u := exists i, chain(i) = w and chain(i+d) = u` where `chain` is an
   injective monotone map `Int -> BidirectionalFragment`. This avoids the inverse property
   but requires proving the chain is injective (no stalling at fixed points of quotientSucc).

5. **Keep task_rel trivial**: This is banned by the user directive.

### Recommended Resolution

The most promising alternative is **approach 4**: chain-based task_rel with an injective
chain. This avoids the inverse property entirely. Compositionality follows from integer
arithmetic, and the key new requirement is proving the chain is injective.

Chain injectivity (quotientSucc q != q for all q) is plausible: it means the quotient
has no fixed points under successor. This follows if GContent(Lindenbaum(GContent(w))) != w.world
for all fragment elements w (i.e., the Lindenbaum extension of GContent always produces a
STRICTLY larger MCS in the quotient ordering).

This would require a NEW plan revision (implementation-005.md).

### Files Modified

None. The original `CanonicalCompleteness.lean` is unchanged.

### No Sorries Introduced

Zero new sorries. The file is in its pre-Phase-1 state.

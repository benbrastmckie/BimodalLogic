# Task 107: FUC Sorry Analysis (v32)

## Session: sess_1777301335_857c05

## Summary

Analysis of the final 3 sorry sites in the chronicle-based countermodel construction.
The investigation revealed a fundamental soundness issue in the construction that
prevents closing these sorries as stated.

## Finding: `burgessR3Maximal_exists_general` is FALSE

The theorem at RRelation.lean:1348 states:

```
theorem burgessR3Maximal_exists_general (A C : Set Formula)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C) :
    exists B : Set Formula, BurgessR3Maximal A B C
```

**This is false for arbitrary MCS pairs under strict (irreflexive) temporal semantics.**

### Counterexample

Let A be an MCS containing G(p) (p is true at all strict future points).
Let C be an MCS containing p.neg (p is false now).

Both are satisfiable under strict temporal semantics (e.g., at point a where p holds
everywhere strictly after a, and at point c where p fails).

For any B satisfying burgessR3(A, B, C):
- burgessRSet(A, B, C) requires: for all beta in B, for all gamma in C, untl(beta, gamma) in A
- Taking gamma = p.neg in C: need untl(beta, p.neg) in A for all beta in B
- By BX10: untl(beta, p.neg) implies F(p.neg)
- But G(p) in A implies G(p^{nn}) in A (by DNI + temporal K), so F(p.neg) = G(p^{nn}).neg not in A
- Therefore untl(beta, p.neg) not in A for ANY beta
- So B must have no elements (empty), but empty set is not a DCS (not deductively closed)

Therefore no DCS B satisfying burgessR3(A, B, C) exists, and no BurgessR3Maximal exists.

## Impact Analysis

`burgessR3Maximal_exists_general` is used by `rebuild_g`, which is used by `omega_chain`,
which underlies ALL limit-level theorems:

| Theorem | Status |
|---------|--------|
| limit_satisfies_c5_weak | Depends on sorry (through omega_chain) |
| limit_satisfies_c4 | Depends on sorry (through omega_chain + c2') |
| limit_forward_G | Depends on sorry (through limit_satisfies_c4) |
| limit_backward_H | Depends on sorry (through limit_satisfies_c4') |
| cantor_bfmcs_restricted_buc | Depends on sorry (through limit_satisfies_c4) |
| cantor_bfmcs_restricted_fuc | Has its own sorry + depends on all above |

So ALL existing "proved" theorems in the chronicle construction are tainted by this sorry.

## FUC Sorry Sites (ChronicleToCountermodel.lean:615, 619)

The forward Until/Since coherence sorries CANNOT be closed without first fixing the
foundational issue. The FUC proof requires:

1. A valid endpoint witness (from c5_weak -- currently sorry-tainted)
2. Guard propagation at intermediate points (the novel content)

For the guard, extensive analysis showed that:
- The omega chain C5 elimination does NOT guarantee guard at intermediate points
- The guard cannot be derived from BX axioms alone (untl(phi,psi) does NOT imply G(phi))
- The C4 mechanism (backward direction) doesn't help establish the forward guard
- The Burgess bridging approach requires BurgessR3Maximal which is false in general

## Recommended Fix

### Option A: Restrict burgessR3Maximal to temporal pairs

Change `burgessR3Maximal_exists_general` to require a temporal relationship:

```
theorem burgessR3Maximal_exists_temporal (A C : Set Formula)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_temporal : g_content A subset C) :  -- A's future content is in C
    exists B, BurgessR3Maximal A B C
```

Then modify `rebuild_g` to only assign g-values where the temporal condition holds.
This requires proving that omega chain adjacent pairs always have this temporal property.

### Option B: Remove rebuild_g entirely

Drop the c2' invariant from the omega chain. Remove C4 counterexample elimination
from the omega chain. Instead, prove limit_satisfies_c4 directly at the limit level
using density + BX axioms (this requires proving backward Until coherence first,
potentially through a different mechanism).

### Option C: Restructure the omega chain

Instead of processing C4 counterexamples via BurgessR3 bridging, use an alternative
C4 argument:
- The easy cases (gamma not in f(x) or gamma.neg in f(y)) don't need BurgessR3
- The hard case (gamma in both endpoints) can potentially use g_content/h_content
  intersection consistency instead of BurgessR3Maximal

## Files Analyzed

- ChronicleToCountermodel.lean (sorry sites at lines 615, 619)
- RRelation.lean (sorry site at line 1348, proved FALSE)
- ChronicleConstruction.lean (omega_chain, rebuild_g, limit theorems)
- CounterexampleElimination.lean (C4 hard case at line 409)
- PointInsertion.lean (lemma_2_4, seed construction)
- ChronicleTypes.lean (BurgessR3Maximal definition)

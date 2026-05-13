# XuLemma321Legacy (Archived)

**Archived**: 2026-04-28 (moved from root `Boneyard/` in task 132)
**Origin**: `RRelation.lean` (commit `51bdc854d`, moved to root Boneyard in commit `f62f19a99`)
**Task**: Xu 3.2.1(i)/(ii) proof-by-contradiction attempt

## What This Contains

Two sorry-containing theorems attempting to prove Xu's Lemma 3.2.1:

- **`burgessR3Maximal_untl_mem_B`** (Xu 3.2.1(i)): BurgessR3Maximal(A, B, C) implies B is closed under Until formation with C (for beta in B, gamma in C: untl(beta, gamma) in B).
- **`burgessR3Maximal_snce_mem_B`** (Xu 3.2.1(ii)): BurgessR3Maximal(A, B, C) implies B is closed under Since formation with A (for beta in B, alpha in A: snce(beta, alpha) in B).

## Why Archived

The proof-by-contradiction approach splits into two sub-cases:

1. **Consistent case** (B union {formula} is consistent): Proved. Deductive closure gives a proper DCS extension still satisfying burgessR3, contradicting maximality.
2. **Inconsistent case** (B union {formula} is inconsistent): Blocked. Having neg(beta U gamma) in B should lead to contradiction, but `untl(bot, delta)` is satisfiable on discrete orders (where the open guard interval (t,s) can be empty). Without BX9 (removed as unsound under open guard semantics), neg(bot U delta) is not derivable in the proof system.

## Replacement

Task 115 proved Xu 3.2.1 via a fundamentally different method: `dcs_neg_union_consistent` provides the result directly without requiring proof-by-contradiction or the inconsistency case. This archived approach is therefore doubly obsolete -- both blocked on BX9 unsoundness AND superseded by a working proof.

## Downstream Usage

None. No theorem in CounterexampleElimination.lean, ChronicleToCountermodel.lean, or any other file references these. They were infrastructure for potential future use that was never needed.

## Code Retrieval

```bash
git log --follow Theories/Bimodal/Boneyard/XuLemma321Legacy/XuLemma321.lean
```

## References

- Task 115: Proved Xu 3.2.1 via dcs_neg_union_consistent
- Task 107: Chronicle construction context
- `PointInsertion.lean`: Current implementation using Xu 3.2.1+3.2.2

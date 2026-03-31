# UltrafilterChain Dead Code Archive

This directory contains documentation for dead code removed from `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` during Task 80 cleanup.

## Archived Date

2026-03-31

## Why This Code Was Archived

These constructions represent abandoned approaches to modal completeness that hit fundamental mathematical barriers:

1. **F-Preserving Seed** - Task #69 proved this approach FALSE (box_F_seed_chain produces non-F-preserving chains)
2. **Bidirectional Seed** - H(a) -> G(H(a)) is NOT derivable in TM, making bidirectional temporal propagation unfixable
3. **Z_chain Construction** - Structural gap: cannot prove cross-direction G/H coherence without circular dependencies
4. **CoherentZChain** - Same structural gaps as Z_chain, marked ARCHIVED
5. **Omega F-Persistence** - Dead omega chain theorems with no external dependencies
6. **P-Preserving Seed** - Symmetric to F-preserving, same issues
7. **True Dovetailed** - Superseded; F(phi) vanishes case unfixable

## Summary of Removal

| Region | Original Lines | Sorries Eliminated |
|--------|----------------|-------------------|
| F-Preserving Seed | 2485-3473 | 2 |
| Bidirectional Seed | 3698-4309 | 2 |
| Deprecated boxClassFamilies | 4683-4767 | 2 |
| Z_chain Construction | 5088-5370 | 5 |
| F-Persistence/Dovetailed | 5921-6683 | 3 |
| F-Preserving Omega | 6684-7115 | 1 |
| P-Preserving Backward | 7116-7923 | 2 |
| CoherentZChain | 7924-8165 | 6 |
| omega_true_dovetailed | 8167-8376 | 0 |
| **Total** | ~4,423 lines | **23** |

## Code Retrieval

The full code exists in git history. To retrieve:

```bash
# View the file before cleanup
git show HEAD~1:Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean

# Or checkout specific commit before Task 80
git log --oneline Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean
```

## Reference

See `ROADMAP.md` in project root for context on why these approaches were abandoned.

## Stub Files

The .lean files in this directory contain documentation headers only, not actual code. This is because:

1. The removed code has complex interdependencies that would not compile standalone
2. The code uses internal definitions from UltrafilterChain.lean
3. Git history provides the authoritative source

The stub files serve as documentation placeholders indicating what was archived.

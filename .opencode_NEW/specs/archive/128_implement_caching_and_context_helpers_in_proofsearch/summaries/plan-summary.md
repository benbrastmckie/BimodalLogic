# Plan Summary: Implement caching and context helpers in ProofSearch

**Version**: 001  
**Complexity**: Moderate  
**Estimated Effort**: 3-5 hours

## Key Steps

1. Add `BEq`/`Hashable` support for `Formula`/`Context` and define hash-based `ProofCache`/`Visited` plus `SearchStats`.
2. Refactor `bounded_search` and wrappers to use hash caches, stats, and transformed-context keys for modal/temporal recursion.
3. Extend `ProofSearchTest` with cache hit/miss, visit-limit, and modal/temporal separation coverage.

## Dependencies

- Lean Std `HashMap`/`HashSet` imports and hashable instances for `(Context × Formula)` keys.
- Existing ProofSearch recursion (`bounded_search`, `box_context`, `future_context`) and test harness in `ProofSearchTest.lean`.

## Success Criteria

- Hash-based cache/visited and stats wired through `bounded_search`/`search_with_cache` without behavior regressions.
- Tests confirm cache hits/failures, visit-limit pruning, and distinct modal vs temporal cache entries.

## Full Plan

See: `specs/128_implement_caching_and_context_helpers_in_proofsearch/plans/implementation-001.md`

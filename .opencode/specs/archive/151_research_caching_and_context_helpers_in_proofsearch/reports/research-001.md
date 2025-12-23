# Research Report: Caching & Context Helpers for ProofSearch (task 128)

**Project**: #151 — research_caching_and_context_helpers_in_proofsearch  
**Date**: 2025-12-23  
**Research Type**: comprehensive (code + patterns)

## Research Question
How should ProofSearch strengthen caching (`search_with_cache`), context helpers (`box_context`, `future_context`), and heuristic ordering (tasks 126/127) to support memoized, terminating TM proof search, and what Lean patterns best support memoization and modal/temporal context handling? What are the testing implications and integration points in `Logos/Core/Automation/ProofSearch.lean`?

## Sources Consulted
- Web Research: 5 (Lean HashMap/HashSet, StateT/ReaderT patterns, FPiL transformer usage)  
- Documentation: 0  
- Code Examples: 2 (`Logos/Core/Automation/ProofSearch.lean`, `LogosTest/Core/Automation/ProofSearchTest.lean`)

## Key Findings
### Technologies and Frameworks
- Current ProofSearch uses a simple `ProofCache` (list-backed) with lookup/insert; caching is threaded through `bounded_search`, `search_with_heuristics`, and `search_with_cache`.
- Visit control already exists: `(visited : List (Context × Formula))`, `visits` counter, `visitLimit`, cycle guard via membership.
- Heuristic stack (task 127): `HeuristicWeights` with defaults; `heuristic_score` prioritizes axioms, assumptions, MP antecedents (complexity-weighted), then modal/temporal branches, with dead-end fallback. `orderSubgoalsByScore` sorts antecedents.
- Context helpers: `box_context : Context → Context` maps every formula with `Formula.box`; `future_context` maps with `Formula.all_future`. Modal/temporal search steps call these before recursing.

### Design Patterns and Best Practices
- Memoization patterns from Lean Std: `HashMap.get? / insert` and `containsThenInsertIfNew` for one-pass cache writes; `HashSet.containsThenInsert` for O(1) visited-cycle checks.
- State+Reader layering: use `ReaderT` for context/environment transforms (e.g., modal depth, temporal shift) and `StateT` for cache/visited/fuel to avoid manual threading.
- Cache both successes and failures to short-circuit repeated unsolved goals; keep keys context-sensitive (`(Γ, φ)` with context transform applied) to avoid cross-context collisions.
- Fuel/visit counters should decrement per node (already present) and be part of cache state to align testing assertions.

### Implementation Strategies
- Replace list-backed `ProofCache` with `Std.HashMap (Context × Formula) Bool` (or richer result) plus `HashSet` for visited; wrap in a `SearchState` record threaded through search.
- Promote `visited` from `List` to `HashSet (Context × Formula)`; consider hashing contexts post-transform (`box_context`, `future_context`) to ensure keys align with transformed environments.
- Extend `search_with_cache` API to expose visit limits and optionally return stats (`cacheSize`, `visitedSize`) for tests.
- Maintain ordering: cache/visited guard → axiom/assumption → MP (ordered) → modal K via `box_context` → temporal K via `future_context`; ensure every branch decrements depth and increments visits exactly once.
- Consider `withReader`-style context transforms if moving to `ReaderT`; keeps modal/temporal context localized and reduces manual mapping mistakes.

## Relevant Resources
- Internal: `Logos/Core/Automation/ProofSearch.lean` (current caching/heuristics/contexts), `LogosTest/Core/Automation/ProofSearchTest.lean` (axiom/heuristic/visit-limit tests).
- Web: Lean Std `HashMap`, `HashSet` basics; Lean `StateT`/`ReaderT` usage in FPiL; transformer construction patterns (see specialist report below).
- Specialist report: `.opencode/specs/151_research_caching_and_context_helpers_in_proofsearch/specialist-reports/web-research-Lean 4 memoization and context transforms for proof search.md`.

## Recommendations
- **Cache structure**: Switch `ProofCache` to `HashMap (Context × Formula) Bool` and add `HashSet` for visited; cache both success and failure. Consider utility `containsThenInsertIfNew` for atomic check/insert.
- **Context-sensitive keys**: Always key cache/visited on the *transformed* context for modal/temporal calls to avoid unsound reuse; if contexts grow, consider a lightweight hash of `(Γ.length, φ)` plus exact equality on collision.
- **search_with_cache API**: Return `(result, cache, visits)` as now but include `cacheSize`/`visitedSize` in a stats record; allow custom `visitLimit`/weights and pass in preexisting caches.
- **Heuristics alignment**: Keep `matches_axiom` as the gating cheap check; ensure heuristic weights stay in sync with cost model after cache changes (e.g., optionally prefer cached hits with score 0/1).
- **Testing**: Add cache-hit/no-visit growth, failure memoization reuse, visited-cycle cutoff, modal/temporal context-key separation, and fuel/visit limit assertions. Extend `ProofSearchTest` accordingly.

## Further Research Needed
- Benchmark hash-based cache vs list cache on representative TM goals to calibrate default `visitLimit` and weight penalties.
- Evaluate context-key serialization/hash to avoid expensive structural equality on large Γ.
- Explore proof-term integration (if/when derivation trees are added) to ensure cache entries remain sound across proof objects.

## Specialist Reports
- Web Research: `.opencode/specs/151_research_caching_and_context_helpers_in_proofsearch/specialist-reports/web-research-Lean 4 memoization and context transforms for proof search.md`

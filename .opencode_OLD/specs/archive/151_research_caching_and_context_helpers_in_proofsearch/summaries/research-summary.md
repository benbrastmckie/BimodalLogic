# Research Summary: Caching & Context Helpers for ProofSearch (task 128)

## Key Findings

1. Current `bounded_search` already threads cache/visited/visitLimit and orders branches via `heuristic_score` (axioms/assumptions → MP ordered → modal/temporal context transforms).
2. Replace list cache + list visited with `HashMap (Context × Formula)` and `HashSet` keys; cache both success and failure and key on the transformed context for modal/temporal calls.
3. Testing should add cache-hit/failure-memo reuse, visited-cycle cutoffs, modal vs temporal context-key separation, and fuel/visit-limit assertions alongside existing heuristic/axiom tests.

## Most Relevant Resources

- `.opencode/specs/151_research_caching_and_context_helpers_in_proofsearch/reports/research-001.md`
- `.opencode/specs/151_research_caching_and_context_helpers_in_proofsearch/specialist-reports/web-research-Lean 4 memoization and context transforms for proof search.md`
- `Logos/Core/Automation/ProofSearch.lean`

## Recommendations

Adopt hash-based cache + visited sets keyed by `(Γ, φ)`, expose search stats in `search_with_cache`, keep branch order (cache/visited guard → axiom/assumption → ordered MP → modal/temporal), and expand `ProofSearchTest` for cache hits, failures, cycles, context-sensitive keys, and visit/fuel limits.

## Full Report

See: `.opencode/specs/151_research_caching_and_context_helpers_in_proofsearch/reports/research-001.md`

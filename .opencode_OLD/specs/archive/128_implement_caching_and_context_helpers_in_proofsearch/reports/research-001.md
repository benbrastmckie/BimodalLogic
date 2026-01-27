# Research Report: Implement caching and context helpers in ProofSearch

- **Task**: 128 — Implement caching and context helpers in ProofSearch
- **Date**: 2025-12-23T06:00:00Z
- **Scope**: Evaluate current ProofSearch caching/context utilities (`search_with_cache`, `box_context`, `future_context`) and identify Lean patterns for memoization, context transforms, and testing to avoid redundant exploration.
- **Sources**: `Logos/Core/Automation/ProofSearch.lean`, existing heuristics from tasks 126/127, Lean memoization patterns (HashMap/StateT), project standards.

## Current State (ProofSearch.lean)
- `bounded_search` threads `(cache : ProofCache)`, `visited`, `visitLimit`, and heuristic ordering; cache/visited guard is checked before work; modal (`box_context`) and temporal (`future_context`) calls recurse with transformed contexts.
- `ProofCache` is a list-backed placeholder keyed by `(Context × Formula)` with O(n) lookup and duplicate entries; caches successes/failures as Nat flags; `visited` is a simple list guard.
- `search_with_cache`/`search_with_heuristics` are thin wrappers; branch order: cache/visited short-circuit → axiom/assumption → ordered modus ponens → modal/temporal.

## Gaps and Risks
- Cache key is raw `(Γ, φ)` without normalization of transformed contexts; list cache is inefficient and allows duplicates.
- No cache-hit statistics surfaced to callers; tests do not assert cache reuse or visited-cycle cutoffs.
- Context transforms are limited to `box_context`/`future_context`; no combined or mixed-mode handling for nested modal+temporal forms.
- Visit/cycle guard is linear search over visited list; no separation of modal vs temporal call stacks.

## Recommendations
- Replace list-backed cache/visited with hash-based structures (e.g., `Std.HashMap (Context × Formula) Bool`, `Std.HashSet (Context × Formula)`), keyed on the *transformed* context used for the recursive call; cache both successes and failures.
- Add a `SearchStats` record (hits, misses, visited, pruned_by_limit) returned by `search_with_cache`; propagate updated cache outward so callers can reuse it.
- Normalize context keys for modal/temporal recursion: key on `(box_context Γ, ψ)` and `(future_context Γ, ψ)` to avoid conflating base vs transformed contexts.
- Maintain branch ordering: cache/visited guard → axiom/assumption → ordered MP → modal → temporal; keep heuristic weights configurable.
- Provide pure helper wrappers: `with_cache` (returns result + updated cache + stats) and `with_visit_limits` (fuel/visit guard) to compose in tests and higher-level search.

## Testing Implications
- Add tests covering: cache-hit reuse (success and failure); visited-cycle cutoffs; modal and temporal context-key separation; fuel/visit-limit early exits; branch ordering stability when weights change.
- Reuse existing heuristic-positive/negative tests (tasks 126/127) and add assertions on stats (hits/misses/visited) for regression safety.

## Next Steps
- Implement hash-based `ProofCache`/visited sets and `SearchStats` plumbing.
- Integrate cache-aware keys into modal/temporal recursion and expose `search_with_cache` result + stats.
- Add Lean tests in `LogosTest/Core/Automation/ProofSearchTest.lean` for cache hits/failures, visit-limit, and context separation.

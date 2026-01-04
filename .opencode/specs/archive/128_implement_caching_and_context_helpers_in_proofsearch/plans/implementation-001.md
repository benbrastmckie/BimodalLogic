# Implementation Plan: Implement caching and context helpers in ProofSearch
- **Task**: 128 — Implement caching and context helpers in ProofSearch
- **Status**: [COMPLETED]
- **Started**: 2025-12-23T06:40:00Z
- **Completed**: 2025-12-23T06:50:00Z
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: 126, 127
- **Research Inputs**:
  - .opencode/specs/128_implement_caching_and_context_helpers_in_proofsearch/reports/research-001.md
- **Artifacts**:
  - plans/implementation-001.md (this file)
  - summaries/plan-summary.md
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: lean
- **Lean Intent**: true

**Project**: #128  
**Version**: 001  
**Date**: 2025-12-22  
**Complexity**: Moderate

## Task Description

Implement hash-based cache/visited structures with statistics, ensure modal/temporal recursion keys on transformed contexts (`box_context`, `future_context`), integrate `search_with_cache` with new cache/visited/stats threading, and add Lean tests covering cache hits/misses, visit limits, and modal/temporal context separation.

## Complexity Assessment

- **Level**: Moderate
- **Estimated Effort**: 3-5 hours
- **Required Knowledge**: Lean 4 Std `HashMap`/`HashSet`, `BEq`/`Hashable` instances for `Formula` and lists, existing ProofSearch recursion and heuristics, Lean test patterns in `LogosTest`
- **Potential Challenges**: Deriving/defining hashable keys for `(Context × Formula)`; threading updated cache/visited/stats without breaking existing callers; ensuring modal vs temporal transformed contexts are keyed distinctly to avoid false cache hits.

## Technology Stack

- **Languages**: Lean 4
- **Frameworks**: Logos Core Automation
- **Tools**: Std `HashMap`, `HashSet`, `StateT`/pure threading as applicable, project test harness
- **Dependencies**: `Logos.Core.Syntax.Formula`, `Logos.Core.Syntax.Context`, `Logos.Core.Automation.ProofSearch`, `LogosTest.Core.Automation.ProofSearchTest`

## Dependencies

### Required Modules/Packages

- `Std.Data.HashMap`, `Std.Data.HashSet`
- `Logos.Core.Syntax` (for `Formula`, `Context`); ensure `BEq`/`Hashable` instances
- `Logos.Core.Automation.ProofSearch` (bounded search, contexts, wrappers)

### Prerequisites

- Provide `BEq` and `Hashable` instances for `Formula` and hence `Context = List Formula`; pair instance for `(Context × Formula)`.
- Define `SearchStats` record and `ProofCache`/`Visited` type aliases using hash structures.

### External Libraries

- Lean Stdlib only (no external deps expected)

## Implementation Steps

### Step 1: Add hashable/equality support for keys
**Action**: Ensure `Formula` (and any nested structures used in contexts) derive or define `BEq` and `Hashable`; confirm `Context` (list) inherits; add pair instances if not available. Keep derivations local to avoid API breakage.  
**File**: `Logos/Core/Syntax/Formula.lean` (and/or a small helper section in `ProofSearch.lean` if local instances suffice)  
**Approach**: Prefer `deriving BEq, Hashable` on `Formula` if compatible; otherwise define instances using existing equality. Provide `Hashable (Context × Formula)` via pair instance.  
**Verification**: Lean compiles with new instances; no orphan instance warnings; existing usages unchanged.

### Step 2: Define cache/visited types and stats
**Action**: Introduce `ProofCache := Std.HashMap (Context × Formula) Bool`, `Visited := Std.HashSet (Context × Formula)`, and `SearchStats` record (hits, misses, visited, prunedByLimit). Provide constructors/reset helpers.  
**File**: `Logos/Core/Automation/ProofSearch.lean`  
**Approach**: Add near existing cache definitions; include pure helpers (`record SearchResult := { result : Option Proof, cache : ProofCache, visited : Visited, stats : SearchStats }` or equivalent threading). Keep defaults `empty`.  
**Verification**: Typechecks; tests can inspect stats fields.

### Step 3: Update bounded_search to use hash cache/visited and stats
**Action**: Replace list-based cache/visited checks with hash lookups; increment stats (hits/misses/visited/pruned); update cache on success/failure.  
**File**: `Logos/Core/Automation/ProofSearch.lean`  
**Approach**: Early guard: check cache (hits++), visited set (visited++), visit limit (pruned++). On recursive branches, thread updated cache/visited/stats. Ensure failures insert `false`, successes insert `true`. Preserve branch ordering and visit-limit semantics from research.  
**Verification**: Existing heuristic/MP behavior unchanged; Lean compiles; stats reflect execution in tests.

### Step 4: Normalize modal/temporal recursion keys
**Action**: Ensure recursive calls for modal (`□`) and temporal (`◯`/future) use transformed contexts as cache/visited keys via `box_context` and `future_context`.  
**File**: `Logos/Core/Automation/ProofSearch.lean`  
**Approach**: Compute transformed context once per branch; key lookups/inserts on `(Γ', φ')` where `Γ'` is transformed. Avoid mixing base vs transformed contexts. Add helper functions if necessary for clarity.  
**Verification**: Tests show separate cache entries for modal vs temporal paths; no false sharing across contexts.

### Step 5: Update public wrappers and return types
**Action**: Adjust `search_with_cache` (and `search_with_heuristics` if affected) to return proof result plus updated cache and stats; provide helper `with_cache`/`with_visit_limits` wrappers for pure usage.  
**File**: `Logos/Core/Automation/ProofSearch.lean`  
**Approach**: Define a lightweight result structure; maintain backward-compatible convenience wrapper if needed (returning proof only) to minimize caller churn. Document new fields in comments.  
**Verification**: All call sites compile; wrappers expose stats for tests; behavior matches previous results on existing tests.

### Step 6: Add regression tests for cache/visited/context separation
**Action**: Extend tests to cover cache hit/miss (success and failure), visited/limit pruning, and modal vs temporal key separation; assert stats counters.  
**File**: `LogosTest/Core/Automation/ProofSearchTest.lean`  
**Approach**: Reuse simple goals from task 126/127; run search twice to assert hit increments; construct modal and temporal goals with same base context to ensure distinct cache entries; set small visit limits to test pruning.  
**Verification**: Tests pass; stats counters change as expected; no regressions in existing automation tests.

## File Structure

```
.opencode/specs/128_implement_caching_and_context_helpers_in_proofsearch/
  plans/implementation-001.md (this plan)
  reports/research-001.md
  summaries/plan-summary.md
Logos/Core/Automation/ProofSearch.lean
Logos/Core/Syntax/Formula.lean (hashable/equality instances if needed)
LogosTest/Core/Automation/ProofSearchTest.lean
```

## Testing Strategy

- **Unit Tests**: Add cache/visited/stats unit tests in `ProofSearchTest.lean` (hits/misses, failures cached, visit-limit pruning).  
- **Integration Tests**: Reuse/extend existing proof search scenarios to ensure branch ordering unaffected and modal/temporal caching uses transformed contexts.  
- **Test Coverage**: Aim to cover cache hit/fail paths, visited guard, modal vs temporal key separation, and stats increments.

## Verification Checkpoints

- [ ] `Formula`/`Context` hash/equality instances compile without affecting API.  
- [ ] `ProofCache`/`Visited`/`SearchStats` types defined and used in `bounded_search`.  
- [ ] Modal/temporal recursion uses transformed-context keys.  
- [ ] `search_with_cache` returns cache + stats; wrappers compile.  
- [ ] New tests added and passing.

## Documentation Requirements

- Inline comments/docstrings for new types (`SearchStats`, cache helpers) and any wrappers clarifying return values.  
- Brief note in `Logos/Core/Automation/README.md` or existing module header if present to describe cache/stats behavior (optional if header already documents search pipeline).

## Success Criteria

- Hash-based cache/visited replace list structures with correct keying on transformed contexts.  
- `search_with_cache` threads and returns updated cache and stats without breaking existing behavior.  
- Tests demonstrate cache hit/miss, visited-limit pruning, and modal/temporal cache separation.

## Related Research

- `.opencode/specs/128_implement_caching_and_context_helpers_in_proofsearch/reports/research-001.md`

## Notes

- Lean intent true: prioritize Lean implementation; avoid introducing new dependencies beyond Std.

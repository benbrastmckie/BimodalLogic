# Implementation Summary: Optimize generateValidBatch O(n^2) MP Closure Bottleneck

- **Task**: 251
- **Status**: Implemented
- **Session**: sess_1780338786_e09d53
- **Phases Completed**: 4/4

## Changes

### File Modified
- `Theories/Bimodal/Automation/FormulaEnumerator.lean`

### What Changed

The `generateValidBatch` function was refactored to eliminate three compounding O(n^2) operations:

1. **HashSet + Array pool** (Phase 1): Replaced `List Formula` with `Std.HashSet Formula` (O(1) membership) + `Array Formula` (ordered iteration). Added `addToPool` helper that inserts only if not already present, eliminating all `eraseDups` calls.

2. **Implication-index HashMap** (Phase 2): Replaced the O(n^2) nested MP closure loop (`for phi in pool do for psi in pool do`) with an O(n) implication-index lookup. At each MP round, builds `Std.HashMap Formula (Array Formula)` mapping each LHS of implications to their RHS values, then does a single pass looking up each pool formula in the index.

3. **Early complexity filtering** (Phase 3): Added `complexity <= maxComplexity` guards at both Nec and MP insertion points. The implication index still includes all pool formulas regardless of complexity, so high-complexity implications serve as derivation paths for in-range consequents.

### Complexity Reduction
- **Before**: O(n^2 * rounds) from nested MP loops + O(n^2) from eraseDups on lists
- **After**: O(n * rounds) from single-pass index lookups + O(1) hash-based dedup

### Interface Preserved
- Function signature: `partial def generateValidBatch (seedCount : Nat) (maxComplexity : Nat) (atoms : List Atom) : IO (List Formula)` -- unchanged
- `generateFormulas` calls `generateValidBatch` identically
- `hashDedup` still used by `generateFormulas` for combining enumerated + valid seeds
- Output semantics preserved (same valid formulas produced, modulo ordering)

## Plan Deviations

- Phases 1-3 were implemented as a single function rewrite rather than sequential refactoring passes, since the function body is a single cohesive block. All plan tasks were completed.
- Phase 4 Task 2 (`#print axioms`) was skipped because `generateValidBatch` is a `partial def` (not amenable to axiom printing). Verified zero sorries via grep instead.
- Phase 4 Task 5 (optional timing log) was skipped as optional -- timing infrastructure would add noise to normal pipeline runs.

## Verification

- `lake build` passes with zero errors (1679 jobs)
- Zero new sorries introduced
- Zero vacuous definitions
- Zero new axioms
- All `eraseDups` calls eliminated from `generateValidBatch`
- O(n^2) nested MP loop replaced with O(n) index lookup
- Early complexity filtering active at both Nec and MP insertion points

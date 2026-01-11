# Implementation Plan: Task #176

**Task**: Enhance Bimodal proof search with success learning and best-first search
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Revision Summary

This plan replaces the original task 176 scope (which targeted the now-deprecated `Logos/Core/` paths) with a redesigned scope for the `Bimodal/` theory.

### Previous Scope (Obsolete)
- Targeted `Logos/Core/Automation/ProofSearch.lean`
- Required creating basic domain-specific heuristics from scratch
- Original files no longer exist after project restructuring

### New Scope (Current)
The `Bimodal/Automation/ProofSearch.lean` already implements:
- Modal-specific heuristics (`modal_heuristic_bonus`)
- Temporal-specific heuristics (`temporal_heuristic_bonus`)
- Structure-based heuristics (`structure_heuristic`)
- Advanced scoring (`advanced_heuristic_score`)
- Proof caching with hash-consing (`ProofCache`, `CacheKey`)
- IDDFS with visit limits and statistics

This plan focuses on the **remaining work**:
1. Success pattern learning (not yet implemented)
2. Best-first search with priority queue (placeholder exists)
3. Benchmarking suite
4. Documentation

## Overview

Enhance the existing Bimodal proof search with intelligent learning capabilities and priority-based search. The implementation builds on the solid foundation of IDDFS, caching, and domain heuristics already present in `ProofSearch.lean`.

## Phases

### Phase 1: Success Pattern Learning

**Status**: [COMPLETED]
**Estimated effort**: 4 hours

**Objectives**:
1. Define data structures to record successful proof patterns
2. Implement pattern recording during search
3. Implement pattern-guided heuristic boosting

**Files to modify**:
- `Bimodal/Automation/SuccessPatterns.lean` (new)
- `Bimodal/Automation/ProofSearch.lean` (enhance)

**Steps**:

1. **Create SuccessPatterns.lean**
   - Define `SuccessPattern` structure recording:
     - Goal formula structure (hash or pattern)
     - Axiom sequence that succeeded
     - Search depth required
     - Context size
   - Define `PatternDatabase` as a HashMap from formula patterns to success data
   - Implement `recordSuccess` to add patterns after proof completion
   - Implement `queryPatterns` to find matching patterns for new goals

2. **Integrate with bounded_search**
   - Add optional `patternDb : PatternDatabase` parameter to search functions
   - After successful search, call `recordSuccess`
   - Before exploring branches, check `queryPatterns` for hints
   - Boost heuristic score for axioms that previously succeeded on similar goals

3. **Pattern matching strategy**
   - Use formula structure hash for fast lookup
   - Match on modal depth, temporal depth, implication count
   - Consider context size similarity

**Verification**:
- Unit tests for pattern recording and retrieval
- Verify pattern hints improve re-proving similar formulas

---

### Phase 2: Best-First Search Implementation

**Status**: [COMPLETED]
**Estimated effort**: 4 hours

**Objectives**:
1. Implement priority queue-based best-first search
2. Integrate with existing heuristics
3. Complete the `SearchStrategy.BestFirst` case

**Files to modify**:
- `Bimodal/Automation/ProofSearch.lean`

**Steps**:

1. **Define priority queue types**
   - Create `SearchNode` structure with:
     - Context and goal formula
     - Accumulated cost (path cost)
     - Heuristic score (estimated remaining cost)
     - f-score = cost + heuristic
   - Use Std.BinaryHeap or implement simple min-heap based on List

2. **Implement bestFirst_search function**
   ```lean
   def bestFirst_search (Γ : Context) (φ : Formula)
       (maxExpansions : Nat := 10000)
       (weights : HeuristicWeights := {})
       (patternDb : PatternDatabase := {})
       : Bool × ProofCache × SearchStats × Nat
   ```
   - Initialize priority queue with initial goal
   - Repeatedly extract minimum f-score node
   - Expand node by trying all strategies (axiom, assumption, MP, modal K, temporal K)
   - Add child nodes with updated costs to queue
   - Track visited states to prevent cycles
   - Return when goal proven or expansions exhausted

3. **Integrate heuristics**
   - Use `advanced_heuristic_score` for h(n) estimates
   - Incorporate pattern database hints as heuristic bonuses
   - Path cost = number of inference steps taken

4. **Complete SearchStrategy.BestFirst case**
   - Remove placeholder comment in `search` function
   - Route to `bestFirst_search` when strategy is `.BestFirst`

**Verification**:
- Test on axiom goals (should find immediately)
- Test on simple modus ponens (should order by antecedent complexity)
- Test on modal K goals (should recognize pattern and apply rule)
- Compare node expansions vs IDDFS on same problems

---

### Phase 3: Benchmarking Suite

**Status**: [COMPLETED]
**Estimated effort**: 2 hours

**Objectives**:
1. Create representative formula benchmarks
2. Implement timing and statistics collection
3. Document performance characteristics

**Files to modify**:
- `Bimodal/Automation/Benchmarks.lean` (new)
- `BimodalTest/Automation/ProofSearchBenchmarks.lean` (new if test directory exists, else in Benchmarks.lean)

**Steps**:

1. **Define benchmark categories**
   - Pure propositional (K, S axioms, modus ponens chains)
   - Modal axioms (T, 4, B, 5, K distribution)
   - Temporal axioms (4, A, L, K distribution)
   - Bimodal interaction (modal_future, temp_future)
   - Deep formulas (high modal/temporal nesting)
   - Wide contexts (many hypotheses)

2. **Implement benchmark harness**
   - `runBenchmark : Formula → SearchStrategy → BenchmarkResult`
   - Record: success/failure, search time, nodes visited, cache stats
   - Support multiple strategies per formula for comparison

3. **Create benchmark formulas**
   - At least 5 formulas per category
   - Include both provable and unprovable (to test search bounds)
   - Range of difficulties (shallow to deep)

4. **Document results**
   - Add performance notes to ProofSearch.lean module docstring
   - Create comparison table: IDDFS vs BestFirst
   - Note recommended strategy by formula type

**Verification**:
- All provable benchmarks succeed with reasonable limits
- Statistics collection works correctly
- Documentation matches observed behavior

---

### Phase 4: Documentation and Integration

**Status**: [COMPLETED]
**Estimated effort**: 2 hours

**Objectives**:
1. Document heuristic tuning guidelines
2. Update module docstrings
3. Create usage examples

**Files to modify**:
- `Bimodal/Automation/ProofSearch.lean` (docstrings)
- `Bimodal/Automation/SuccessPatterns.lean` (docstrings)
- `Bimodal/Automation.lean` (re-exports)

**Steps**:

1. **Update ProofSearch.lean header**
   - Add section on heuristic weight tuning
   - Document when to use each SearchStrategy
   - Add performance characteristics table
   - Include benchmark results summary

2. **Document SuccessPatterns.lean**
   - Explain pattern learning approach
   - Document pattern database lifecycle
   - Provide examples of using learned patterns

3. **Update Bimodal/Automation.lean**
   - Ensure SuccessPatterns.lean is imported
   - Verify Benchmarks.lean accessible (may be optional import)

4. **Create integration example**
   - Show typical usage pattern with learning enabled
   - Demonstrate strategy selection based on formula type

**Verification**:
- All public definitions have docstrings
- Examples in docstrings compile
- Module docstring accurately describes capabilities

---

## Dependencies

- Phase 2 can proceed in parallel with Phase 1
- Phase 3 depends on Phase 2 (needs BestFirst for comparison)
- Phase 4 depends on all prior phases

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Priority queue inefficient in Lean | Medium | Start with simple List-based heap; optimize if needed |
| Pattern matching too coarse | Low | Use multiple match levels (exact, structural, heuristic) |
| BestFirst slower than IDDFS for shallow proofs | Low | Document when each strategy is preferred |
| Test directory structure unclear | Low | Create benchmarks as `#eval` in main file if no test dir |

## Success Criteria

- [x] Success pattern learning records and retrieves patterns correctly
- [x] BestFirst search finds proofs with fewer node expansions than IDDFS on complex goals
- [x] Benchmarking suite covers all major formula categories
- [x] IDDFS vs BestFirst comparison documented with clear recommendations
- [x] All new code has comprehensive docstrings
- [x] Project builds without errors after all phases

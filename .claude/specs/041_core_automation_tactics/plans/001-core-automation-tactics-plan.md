# Core Automation Tactics Implementation Plan

## Metadata

- **Date**: 2025-12-05 (Revised: 2025-12-05)
- **Feature**: Complete Task 7 (Implement Core Automation) - Implement remaining 8 ProofSearch.lean helper functions, integrate Aesop automation framework, and expand test suite to 75+ tests
- **Scope**: Complete automation infrastructure for Logos TM logic theorem prover. Implement 8 native Lean 4 helper functions for proof search (bounded_search, search_with_heuristics, search_with_cache, matches_axiom, find_implications_to, heuristic_score, box_context, future_context), integrate Aesop automation framework with custom TMLogic rule set, and expand test coverage from 50 to 75+ tests with comprehensive inference rule and search function testing. Output: Fully functional proof automation in Logos/Core/Automation/ with zero axiom stubs and Aesop-powered tm_auto tactic. Note: Aesop is already available as transitive dependency via Mathlib v4.14.0.
- **Status**: [NOT STARTED]
- **Estimated Hours**: 38-53 hours
- **Complexity Score**: 42 (extend existing: 10, 8 functions × 3 = 24, 2 files × 2 = 4, 2 complex implementations × 5 = 10, offset -3 for partial completion, -3 for removed verification complexity)
- **Structure Level**: 0
- **Estimated Phases**: 5
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Lean 4 Core Automation Tactics Research](../reports/001-lean-mathlib-research.md)
  - [Dependency Analysis: Aesop, Mathlib, Batteries](../../042_dependency_independence_research/reports/001-i-want-to-learn-more-about-including-dep-analysis.md)
  - [Plan Revision Insights](../reports/002-plan-revision-insights.md)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/ProofSearch.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Implementation Phases

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
| 3 | lean | lean-implementer |
| 4 | lean | lean-implementer |
| 5 | lean | lean-implementer |

---

### Phase 1: Core ProofSearch Helper Functions [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/ProofSearch.lean
dependencies: []

**Objective**: Implement 6 foundational helper functions for proof search using native Lean 4 APIs (no external dependencies). These functions provide axiom pattern matching, implication search, context transformations, and heuristic scoring needed by bounded_search.

**Complexity**: Medium

**Functions**:

- [ ] `matches_axiom`: Pattern match formula against 10 TM axiom schemas
  - Goal: `def matches_axiom (φ : Formula) : Bool`
  - Strategy: Exhaustive pattern matching for prop_k, prop_s, modal_t, modal_4, modal_b, temp_4, temp_a, temp_l, modal_future, temp_future. Use definitional equality checks (`ψ = ψ'`) for schema variable matching. Cross-verify patterns against Axioms.lean constructor definitions.
  - Complexity: Medium (requires verification against 10 axiom schemas)
  - Dependencies: None (pure Formula pattern matching)
  - Estimated: 3-4 hours
  - Implementation Notes:
    - Pattern example for modal_t: `Formula.imp (Formula.box ψ) ψ' => ψ = ψ'`
    - Pattern example for prop_k: `Formula.imp (Formula.imp ψ (Formula.imp χ ρ)) (Formula.imp (Formula.imp ψ χ) (Formula.imp ψ ρ)) => true`
    - Return `false` for non-matching formulas
    - Verify each pattern against actual Axiom constructors in ProofSystem/Axioms.lean

- [ ] `find_implications_to`: Search context for implications with target consequent
  - Goal: `def find_implications_to (Γ : Context) (φ : Formula) : List Formula`
  - Strategy: Use `List.filterMap` with pattern match `Formula.imp ψ χ => if χ = φ then some ψ else none`. Returns list of all `ψ` where `(ψ → φ) ∈ Γ`.
  - Complexity: Simple (straightforward List operation)
  - Dependencies: None (pure List.filterMap)
  - Estimated: 1-2 hours
  - Example: Given Γ = [P → Q, R → Q, S → T], `find_implications_to Γ Q` returns `[P, R]`

- [ ] `box_context`: Transform context for modal K rule application
  - Goal: `def box_context (Γ : Context) : Context`
  - Strategy: `Γ.map Formula.box` (wrap each formula in box operator)
  - Complexity: Simple (trivial List.map wrapper)
  - Dependencies: None
  - Estimated: 0.5 hours
  - Example: [P, Q → R] becomes [□P, □(Q → R)]

- [ ] `future_context`: Transform context for temporal K rule application
  - Goal: `def future_context (Γ : Context) : Context`
  - Strategy: `Γ.map Formula.all_future` (wrap each formula in all_future operator)
  - Complexity: Simple (trivial List.map wrapper)
  - Dependencies: None
  - Estimated: 0.5 hours
  - Example: [P, Q → R] becomes [GP, G(Q → R)]

- [ ] `Formula.complexity`: Recursive size metric for formulas
  - Goal: `def Formula.complexity : Formula → Nat`
  - Strategy: Structural recursion: atom/bot = 1, imp/box/all_past/all_future = 1 + recursive complexity
  - Complexity: Simple (standard structural recursion)
  - Dependencies: None
  - Estimated: 1 hour
  - Purpose: Used by heuristic_score for tie-breaking

- [ ] `heuristic_score`: Compute search branch priority score
  - Goal: `def heuristic_score (Γ : Context) (φ : Formula) : Nat`
  - Strategy: Score 0 if matches_axiom, score 1 if in Γ, score 2 + min(antecedent complexity) if modus ponens applicable, score 5 + |Γ| for modal/temporal K, score 100 if no strategy applicable
  - Complexity: Medium (integrates matches_axiom, find_implications_to, Formula.complexity)
  - Dependencies: matches_axiom, find_implications_to, Formula.complexity
  - Estimated: 2-3 hours
  - Design rationale: Prefer simple proofs (axioms) over complex derivations

**Testing**:
```bash
# Build ProofSearch.lean
lake build Logos/Core/Automation/ProofSearch.lean

# Verify no axiom stubs remain for implemented functions
grep -n "axiom matches_axiom\|axiom find_implications_to\|axiom heuristic_score\|axiom box_context\|axiom future_context" Logos/Core/Automation/ProofSearch.lean

# Expect: Only bounded_search, search_with_heuristics, search_with_cache should remain as axiom stubs

# Check diagnostics
lean --server < <(echo '{"textDocument": {"uri": "file:///Logos/Core/Automation/ProofSearch.lean"}, "position": {"line": 0, "character": 0}}')
```

**Success Criteria**:
- [ ] All 6 functions replace axiom stubs with implementations
- [ ] Zero #lint warnings in ProofSearch.lean
- [ ] matches_axiom correctly identifies all 10 axiom schemas (verified against Axioms.lean)
- [ ] find_implications_to returns correct antecedent lists for test contexts
- [ ] box_context and future_context produce correctly transformed contexts
- [ ] heuristic_score returns expected priority ordering (axioms < assumptions < modus ponens < modal K)

**Expected Duration**: 8-11 hours

---

### Phase 2: Bounded Depth-First Search Implementation [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/ProofSearch.lean
dependencies: [1]

**Objective**: Implement bounded_search as primary proof search function using depth-first strategy with helper functions from Phase 1. This is the core search algorithm that all other search variants build upon.

**Complexity**: High

**Functions**:

- [ ] `bounded_search`: Depth-limited search for derivations
  - Goal: `def bounded_search (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ`
  - Strategy: Implement 8-step algorithm: (1) Base case depth=0 → none, (2) Check matches_axiom → return axiom proof, (3) Check φ ∈ Γ → return assumption proof, (4) Try modus ponens using find_implications_to and recursive search, (5) Try modal K if φ = □ψ using box_context recursion, (6) Try temporal K if φ = Fψ using future_context recursion, (7) Try weakening with extended context, (8) Return none if all fail
  - Complexity: Complex (recursive search with multiple strategies and proof term construction)
  - Dependencies: matches_axiom, find_implications_to, box_context, future_context (Phase 1)
  - Estimated: 6-8 hours
  - Implementation Notes:
    - Use `foldl` for trying multiple strategies without explicit backtracking state
    - Return early with `some proof` when found
    - Complexity: O(b^d) where b = branching factor ≈ |Γ| + 10 axioms, d = depth
    - Must construct valid Derivable proof terms for each case
    - Use pattern matching for formula structure (box, all_future detection)

- [ ] `axiom_instance_of`: Helper to construct axiom proof from matched formula
  - Goal: `def axiom_instance_of (φ : Formula) : Axiom φ`
  - Strategy: Pattern match φ and return corresponding Axiom constructor. Called by bounded_search when matches_axiom returns true. Must handle all 10 axiom patterns.
  - Complexity: Medium (must match all 10 axiom constructor patterns)
  - Dependencies: None (uses Axiom constructors)
  - Estimated: 2-3 hours
  - Purpose: Convert Bool result from matches_axiom into actual Axiom proof term

**Testing**:
```bash
# Build with bounded_search implementation
lake build Logos/Core/Automation/ProofSearch.lean

# Verify axiom stub removed
grep -n "axiom bounded_search" Logos/Core/Automation/ProofSearch.lean
# Expect: No matches

# Test bounded_search examples (add to ProofSearch.lean)
# Example 1: Trivial axiom search at depth 1
#eval bounded_search [] ((Formula.atom "p").box.imp (Formula.atom "p")) 1
# Expect: some (Derivable.axiom (Axiom.modal_t ...))

# Example 2: Depth 0 returns none
#eval bounded_search [] complex_formula 0
# Expect: none

# Verify no diagnostics
lean --server < <(echo '{"textDocument": {"uri": "file:///Logos/Core/Automation/ProofSearch.lean"}}')
```

**Success Criteria**:
- [ ] bounded_search axiom stub replaced with full implementation
- [ ] axiom_instance_of handles all 10 axiom patterns correctly
- [ ] Depth bound prevents infinite recursion (verified with depth=0 tests)
- [ ] Axiom search succeeds at depth 1 for all 10 TM axioms
- [ ] Assumption search succeeds when goal in context
- [ ] Modus ponens search succeeds with depth 2+ for simple derivations
- [ ] Modal K and Temporal K strategies correctly transform contexts
- [ ] Zero #lint warnings
- [ ] All constructed proof terms type-check correctly

**Expected Duration**: 8-11 hours

---

### Phase 3: Advanced Search Strategies [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/ProofSearch.lean
dependencies: [1, 2]

**Objective**: Implement heuristic-guided best-first search and cached search with memoization. These optimizations improve search efficiency for complex proofs with repeated subgoals.

**Complexity**: Medium

**Functions**:

- [ ] `search_with_heuristics`: Best-first search using priority queue
  - Goal: `def search_with_heuristics (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ`
  - Strategy: Implement priority queue-based search. Define SearchState structure with score, depth, goal. Use sorted list as priority queue (List.insertionSort). Main loop: pop lowest-score state, try strategies, add subgoals to queue with updated scores. Terminate on success or queue exhaustion.
  - Complexity: Complex (state management with priority ordering)
  - Dependencies: heuristic_score (Phase 1), bounded_search strategy patterns (Phase 2)
  - Estimated: 5-6 hours
  - Implementation Notes:
    - SearchState structure: `{score : Nat, depth : Nat, goal : Formula}`
    - Priority queue: sorted List SearchState (simple MVP, future: HashMap)
    - Expansion: generate subgoals for each strategy with updated scores
    - Termination: first proof found (best-first guarantees shortest proof if heuristic admissible)

- [ ] `search_with_cache`: Memoized search with proof caching
  - Goal: `def search_with_cache (cache : ProofCache) (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ × ProofCache`
  - Strategy: Check cache.lookup Γ φ first. If hit, return cached proof. If miss, run bounded_search. On success, update cache with proof. Return result and updated cache.
  - Complexity: Medium (cache management with list-based storage)
  - Dependencies: bounded_search (Phase 2)
  - Estimated: 3-4 hours
  - Implementation Notes:
    - ProofCache structure already defined (line 99-105 in ProofSearch.lean)
    - Implement ProofCache.lookup: `List.findSome?` with Γ, φ equality check
    - Implement ProofCache.insert: prepend to cache list
    - Simple list-based cache (O(n) lookup), future optimization: HashMap
    - No cache invalidation needed (derivations immutable)

**Testing**:
```bash
# Build advanced search implementations
lake build Logos/Core/Automation/ProofSearch.lean

# Verify axiom stubs removed
grep -n "axiom search_with_heuristics\|axiom search_with_cache" Logos/Core/Automation/ProofSearch.lean
# Expect: No matches

# Test heuristic search prefers axioms
#eval search_with_heuristics [] modal_t_formula 5
# Expect: Proof found at depth 1 (axiom preferred)

# Test cache behavior
def test_cache : ProofCache := ProofCache.empty
#eval search_with_cache test_cache [] axiom_formula 3
# Expect: (some proof, updated_cache)

# Second call with updated cache should hit
#eval let (proof1, cache1) := search_with_cache test_cache [] axiom_formula 3
     let (proof2, cache2) := search_with_cache cache1 [] axiom_formula 3
     proof1 = proof2
# Expect: true (cache hit)
```

**Success Criteria**:
- [ ] search_with_heuristics axiom stub replaced
- [ ] search_with_cache axiom stub replaced
- [ ] ProofCache.lookup and ProofCache.insert implemented correctly
- [ ] Heuristic search finds proofs faster than bounded_search on complex goals
- [ ] Cache correctly stores and retrieves proofs
- [ ] Cache hits avoid redundant search
- [ ] All 8 ProofSearch.lean helper functions complete (zero axiom stubs)
- [ ] Zero #lint warnings

**Expected Duration**: 8-10 hours

---

### Phase 4: Aesop Integration with TM Logic Rule Sets [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: []

**Objective**: Implement Aesop-based tm_auto tactic using custom TMLogic rule set. Create AesopRules.lean module with forward chaining automation for all 10 TM axioms and perpetuity principles (P1-P3 fully proven). Replace native tm_auto implementation with Aesop-powered version leveraging white-box best-first search.

**Complexity**: Medium

**Note on Dependencies**: Aesop is already available as transitive dependency via Mathlib v4.14.0. No lakefile.toml changes needed. See dependency research report for details.

**Tasks**:

- [ ] Verify Aesop import availability in Automation module
  - Goal: Confirm Aesop can be imported and is functional
  - Strategy: Create new file `Logos/Core/Automation/AesopRules.lean` with `import Aesop` at top. Run `lake build Logos/Core/Automation/AesopRules.lean`. Should succeed immediately since Aesop is transitive dependency via Mathlib v4.14.0.
  - Complexity: Trivial (confirmation only)
  - Estimated: 0.5 hours
  - Expected: Immediate success (Aesop transitively available via Mathlib)
  - Troubleshooting: If import fails, check `lake-manifest.json` for aesop entry

- [ ] Create Logos/Core/Automation/AesopRules.lean with TMLogic rule set
  - Goal: New module declaring TMLogic rule set and marking axioms as Aesop safe rules
  - Strategy:
    1. Declare custom rule set: `declare_aesop_rule_sets [TMLogic]`
    2. Create forward chaining lemmas for all 10 axioms with `@[aesop safe forward [TMLogic]]`
       - Pattern: `theorem modal_t_forward : Derivable Γ (□φ) → Derivable Γ φ`
       - Forward lemmas apply axiom and add consequence to context
    3. Mark perpetuity principles P1-P3 as forward rules (reuse existing proofs from Theorems/Perpetuity.lean)
       - P1: `□φ → △φ` (necessary implies always) - Fully proven
       - P2: `▽φ → ◇φ` (sometimes implies possible) - Fully proven
       - P3: `□φ → □△φ` (necessity of perpetuity) - Fully proven (zero sorry)
       - Skip P4-P6: Partial proofs (complex nested formulas) - defer to future work
    4. Mark inference rules as safe apply rules:
       - `@[aesop safe apply [TMLogic]] theorem apply_modus_ponens`
       - `@[aesop safe apply [TMLogic]] theorem apply_modal_k`
       - `@[aesop safe apply [TMLogic]] theorem apply_temporal_k`
  - Complexity: Medium (requires forward chaining lemma proofs for all axioms)
  - Dependencies: Aesop import verification (previous task)
  - Estimated: 5-8 hours
  - Implementation Notes:
    - Forward lemmas create new assumptions from existing ones (unidirectional)
    - Apply rules create subgoals (bidirectional, require proof of antecedents)
    - Test each rule incrementally during development
    - Use `@[aesop safe forward [TMLogic]] theorem modal_t_forward (Γ : Context) (φ : Formula) : Derivable Γ (Formula.box φ) → Derivable Γ φ := by apply Derivable.axiom; exact Axiom.modal_t φ`

- [ ] Add normalization rules for derived operators
  - Goal: Mark derived operators (diamond, always, sometimes) for automatic unfolding
  - Strategy:
    - `@[aesop norm unfold [TMLogic]] def Formula.diamond`
    - `@[aesop norm unfold [TMLogic]] def Formula.always`
    - `@[aesop norm unfold [TMLogic]] def Formula.sometimes`
    - Skip equational simp lemmas (box_box_eq_box, future_future_eq_future) pending MF/TF soundness completion
  - Complexity: Simple (attribute annotations on existing definitions)
  - Dependencies: AesopRules.lean base structure
  - Estimated: 2-3 hours
  - Implementation Notes:
    - Normalization occurs before search (preprocessing phase)
    - Unfolding allows Aesop to work with primitive operators only
    - Future enhancement: Add simp lemmas when MF/TF axiom soundness proven

- [ ] Replace tm_auto with Aesop version
  - Goal: Update Tactics.lean tm_auto macro to use Aesop TMLogic rule set
  - Strategy: Replace lines 127-139 in Tactics.lean with:
    ```lean
    macro "tm_auto" : tactic => `(tactic| aesop (rule_sets [TMLogic]) (max_rules 100))
    ```
  - Complexity: Trivial (macro replacement)
  - Dependencies: AesopRules.lean complete with all rules registered
  - Estimated: 0.5 hours
  - Implementation Notes:
    - `max_rules 100` provides conservative depth bound
    - Alternative: Provide `tm_auto!` with `max_rules 1000` for aggressive search

**Aesop Integration Patterns** (from dependency research):

1. **Forward Chaining Rules** (safe forward):
   - Use for axiom application: `□φ` in context → apply modal_t → add `φ` to context
   - Pattern: `@[aesop safe forward [TMLogic]] theorem modal_t_forward : Derivable Γ (□φ) → Derivable Γ φ`
   - Priority: Safe rules have priority 1 (applied early in search)

2. **Apply Rules** (safe apply):
   - Use for inference rules requiring explicit subgoals
   - Pattern: `@[aesop safe apply [TMLogic]] theorem apply_modus_ponens : Derivable Γ (φ.imp ψ) → Derivable Γ φ → Derivable Γ ψ`
   - Creates subgoals: proof of antecedent, proof of implication

3. **Normalization Rules** (norm unfold):
   - Use for derived operator definitions
   - Pattern: `@[aesop norm unfold [TMLogic]] def Formula.diamond (φ : Formula)`
   - Applied before search begins (preprocessing)

**Testing**:
```bash
# Verify Aesop import availability
lake build Logos/Core/Automation/AesopRules.lean
# Expect: Immediate success (Aesop transitively available via Mathlib)

# Build with Aesop rules
lake build Logos/Core/Automation/Tactics.lean

# Verify tm_auto uses Aesop
grep -A 2 "tm_auto" Logos/Core/Automation/Tactics.lean
# Expect: `aesop (rule_sets [TMLogic])`

# Verify TMLogic rule set declared
grep "declare_aesop_rule_sets" Logos/Core/Automation/AesopRules.lean
# Expect: [TMLogic]

# Count forward rules registered
grep -c "@\[aesop safe forward \[TMLogic\]\]" Logos/Core/Automation/AesopRules.lean
# Expect: At least 13 (10 axioms + 3 perpetuity principles P1-P3)

# Count apply rules registered
grep -c "@\[aesop safe apply \[TMLogic\]\]" Logos/Core/Automation/AesopRules.lean
# Expect: At least 3 (modus_ponens, modal_k, temporal_k)

# Integration test: tm_auto should solve complex TM proofs
# (Add to TacticsTest.lean in Phase 5)
```

**Success Criteria**:
- [ ] Aesop import verified in Automation module (immediate success expected)
- [ ] AesopRules.lean created with TMLogic rule set declaration
- [ ] All 10 axioms marked as forward rules with correct lemma proofs
- [ ] Perpetuity principles P1-P3 marked as forward rules (P4-P6 deferred)
- [ ] Inference rules (modus_ponens, modal_k, temporal_k) marked as safe apply rules
- [ ] Derived operators (diamond, always, sometimes) marked as norm unfold rules
- [ ] tm_auto macro replaced with Aesop implementation
- [ ] Zero #lint warnings in AesopRules.lean and Tactics.lean
- [ ] Aesop-based tm_auto successfully solves representative TM proofs (verified in Phase 5)

**Expected Duration**: 8-11 hours

---

### Phase 5: Test Suite Expansion to 75+ Tests [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
dependencies: [1, 2, 3, 4]

**Objective**: Expand TacticsTest.lean from 50 to 75+ tests with comprehensive coverage of inference rules, ProofSearch functions, propositional reasoning depth, and Aesop integration.

**Complexity**: Medium

**Test Groups**:

- [ ] Inference Rule Tests (Tests 51-58, 8 tests)
  - Goal: Test modal_k, temporal_k, temporal_duality inference rules
  - Strategy: Create examples using Derivable.modal_k, Derivable.temporal_k, Derivable.temporal_duality with context transformations. Test nested rule applications, complex contexts, edge cases.
  - Complexity: Medium (requires understanding inference rule semantics)
  - Estimated: 2-3 hours
  - Test 51: modal_k rule application with simple context
  - Test 52: temporal_k rule application with simple context
  - Test 53: temporal_duality rule
  - Tests 54-58: Nested applications, complex contexts

- [ ] ProofSearch Function Tests (Tests 59-66, 8 tests)
  - Goal: Test bounded_search, search_with_heuristics, search_with_cache behavior
  - Strategy: Test depth bounds (depth 0 → none, depth 1 → axiom), test heuristic preference (axioms before modus ponens), test cache hits/misses, test context transformers (box_context, future_context).
  - Complexity: Medium (requires search function understanding)
  - Estimated: 2-3 hours
  - Test 59: bounded_search finds axiom at depth 1
  - Test 60: bounded_search returns none at depth 0
  - Test 61: search_with_heuristics prefers axioms
  - Test 62: search_with_cache cache hit behavior
  - Tests 63-66: Context transformers, complex searches

- [ ] Propositional Depth Tests (Tests 67-72, 6 tests)
  - Goal: Test prop_k and prop_s axiom chaining in complex propositional derivations
  - Strategy: Create examples with nested prop_k applications, test tm_auto on complex propositional formulas, verify depth-3+ searches succeed.
  - Complexity: Simple (propositional logic tests)
  - Estimated: 1-2 hours
  - Test 67: prop_k chained application
  - Test 68: prop_s with complex antecedents
  - Tests 69-72: Nested propositional reasoning

- [ ] Aesop Integration Tests (Tests 73-75, 3 tests)
  - Goal: Test Aesop-based tm_auto on complex TM proofs
  - Strategy: Test tm_auto with forward chaining (modal_t_forward), test normalization (derived operator unfolding), test multi-step automation.
  - Complexity: Simple
  - Estimated: 1-2 hours
  - Test 73: tm_auto finds complex proof via Aesop
  - Test 74: Aesop forward chaining with modal_t
  - Test 75: Aesop normalization with derived operators

**Testing**:
```bash
# Build expanded test suite
lake build LogosTest/Core/Automation/TacticsTest.lean

# Run all tests
lake test

# Verify test count
grep -c "^example\|^theorem.*:=\|^def test_" LogosTest/Core/Automation/TacticsTest.lean
# Expect: 75+ tests

# Check coverage: all 7 inference rules tested
grep -c "Derivable.modal_k\|Derivable.temporal_k\|Derivable.temporal_duality" LogosTest/Core/Automation/TacticsTest.lean
# Expect: At least 8 matches (one per inference rule test)

# Check coverage: all 8 ProofSearch functions tested
grep -c "bounded_search\|search_with_heuristics\|search_with_cache\|matches_axiom\|find_implications_to\|heuristic_score\|box_context\|future_context" LogosTest/Core/Automation/TacticsTest.lean
# Expect: At least 15 matches (helper tests + integration tests)
```

**Success Criteria**:
- [ ] Test count ≥ 75 (verified with grep)
- [ ] All 7 inference rules tested (modal_k, temporal_k, temporal_duality, modus_ponens, axiom, assumption, weakening)
- [ ] All 8 ProofSearch functions tested (unit tests + integration tests)
- [ ] Propositional depth-3+ tests pass
- [ ] Aesop integration tests pass
- [ ] All tests compile and pass (lake test succeeds)
- [ ] Zero #lint warnings in test file
- [ ] Test coverage matrix documented in TacticsTest.lean header

**Expected Duration**: 6-10 hours

---

## Dependency Management Notes

**Based on Dependency Research Findings** (See .claude/specs/042_dependency_independence_research/reports/001-i-want-to-learn-more-about-including-dep-analysis.md):

### Current Dependency State

Logos currently depends on:
- **Mathlib v4.14.0** (direct, pinned in lakefile.toml)
  - Provides `LinearOrderedAddCommGroup` (required by TaskFrame.lean)
  - Transitively includes Aesop (proof automation framework)
  - Transitively includes Batteries (standard library extensions)

**Implication**: Aesop is already available. No additional dependencies required for Phase 4.

### Aesop Availability Verification

To confirm Aesop is available:
```bash
# Check lake-manifest.json for aesop
grep -A 3 '"aesop"' lake-manifest.json
# Expected: Aesop entry with version info

# Test import in REPL
lake env lean --run <<EOF
import Aesop
#check aesop
EOF
# Expected: Aesop tactic type signature
```

### Import Best Practices

When importing Aesop in AesopRules.lean:
```lean
import Aesop
-- Justification: Aesop proof automation framework (transitive via Mathlib)
-- Available: Mathlib v4.14.0 includes Aesop as dependency
-- See: CLAUDE.md Section 6 (Dependency Management)
```

**No lakefile.toml changes needed**: Aesop is already available via transitive dependency chain.

**IMPORTANT**: Do NOT add Aesop as direct dependency in lakefile.toml. This would create duplicate dependency conflicts. Let Mathlib manage Aesop version transitively.

### Future Dependency Considerations

**If Mathlib is Updated**:
- Aesop version will update automatically (transitive)
- Test AesopRules.lean with new version before merging
- Check Aesop changelog for breaking changes in rule set API

**If Mathlib is Removed** (not recommended per dependency research):
- Would require direct Aesop dependency: `require aesop from git "..." @ "..."`
- Would lose 100+ hours of Mathlib infrastructure
- See dependency research Section 5.1 for cost-benefit analysis

---

## Documentation Updates

After implementation, update the following documentation files:

1. **TODO.md** (lines 55-84):
   - Update Task 7 status from "PARTIAL COMPLETE (33%)" to "COMPLETE (100%)"
   - Document all 8 ProofSearch implementations with zero axiom stubs
   - Document Aesop integration completion with TMLogic rule set
   - Update effort estimates with actuals (expected: 38-53 hours actual vs 40-60 hours originally estimated)
   - Remove "Aesop integration blocked by Batteries dependency" note (outdated blocker)

2. **IMPLEMENTATION_STATUS.md**:
   - Update Automation package from 33% to 100% complete
   - Document ProofSearch.lean completion (zero axiom stubs)
   - Document Aesop integration complete with forward chaining rule set
   - Update test coverage statistics (50 → 75+)
   - Add note: "Aesop available transitively via Mathlib v4.14.0 (see CLAUDE.md Section 6)"

3. **KNOWN_LIMITATIONS.md**:
   - Remove "Automation Package: Infrastructure only" limitation
   - Remove any references to "Aesop integration blocked" (no longer valid)
   - Document search depth performance limits (depth 5+ may require optimization)
   - Document cache size limits (list-based cache is O(n), future: HashMap)
   - Note: Aesop rule set limited to proven axioms (MT, M4, MB, T4, TA); axioms TL, MF, TF excluded pending soundness completion
   - Note: Perpetuity principles P1-P3 included in TMLogic rule set; P4-P6 deferred pending full proofs

4. **TACTIC_DEVELOPMENT.md**:
   - Update tactic status table: tm_auto status → "Complete (Aesop-powered)"
   - Document ProofSearch function usage patterns with examples
   - Add section: "Using Aesop TMLogic Rule Set"
   - Document how to add custom forward rules for future extensions
   - Add example: Creating forward rules for new axioms

5. **CLAUDE.md** (Section 10 "Notes for Claude Code"):
   - Update "No automation available" note to "Core automation complete with Aesop integration"
   - Update tactic status: "All tactics are stubs" → "Core automation complete; Aesop tm_auto operational"
   - Reference: "See TACTIC_DEVELOPMENT.md for usage patterns"
   - Add note on Aesop availability: "Aesop is available as transitive dependency via Mathlib v4.14.0"

## Risk Mitigation

**Risk 1: Aesop Forward Rule Complexity**
- Likelihood: Medium (forward chaining lemmas require correct proof structure)
- Impact: Medium (incomplete rule set reduces tm_auto effectiveness)
- Mitigation: Start with simple forward lemmas (modal_t, prop_k), test incrementally, use Mathlib patterns as templates. Test each rule individually before combining.
- Contingency: If complex forward lemmas fail, use safe apply rules as fallback (still enables automation but requires more explicit subgoal management).

**Risk 2: Axiom Pattern Matching Complexity**
- Likelihood: High (10 axiom schemas with subtle differences)
- Impact: Medium (false positives/negatives in search)
- Mitigation: Cross-verify each pattern against Axioms.lean constructors, extensive test coverage (one test per axiom).
- Contingency: Add detailed error messages showing expected vs actual patterns.

**Risk 3: Search Performance on Complex Goals**
- Likelihood: Medium (depth 5+ may be slow)
- Impact: Medium (user experience, proof automation usability)
- Mitigation: Start with conservative depth bounds (max_rules 100), use heuristic search for complex proofs, implement caching for repeated subgoals.
- Contingency: Document performance limits, provide tm_auto! variant with aggressive search (max_rules 1000), recommend manual tactics for very deep proofs.

## Success Metrics

**Quantitative**:
- [ ] Zero axiom stubs in ProofSearch.lean (currently 8)
- [ ] Zero axiom stubs in Tactics.lean (currently 0, maintain)
- [ ] Test count ≥ 75 (currently 50)
- [ ] Test coverage for all 8 ProofSearch functions (currently 4/8)
- [ ] Test coverage for all 7 inference rules (currently 0/7)
- [ ] lake build succeeds with zero warnings
- [ ] lake test passes 75+ tests

**Qualitative**:
- [ ] ProofSearch functions demonstrate correct behavior on representative examples
- [ ] matches_axiom correctly identifies all 10 TM axioms
- [ ] bounded_search finds proofs within depth bound for standard TM theorems
- [ ] Heuristic search demonstrates efficiency improvement over naive DFS
- [ ] Cache demonstrates memoization benefit on repeated subgoals
- [ ] tm_auto (Aesop or native) solves representative TM proof goals automatically
- [ ] Documentation accurately reflects completed implementation status

## Completion Checklist

- [ ] Phase 1: All 6 helper functions implemented and tested
- [ ] Phase 2: bounded_search implemented with all 8 strategy steps
- [ ] Phase 3: search_with_heuristics and search_with_cache implemented
- [ ] Phase 4: Aesop integrated with TMLogic rule set (AesopRules.lean complete)
- [ ] Phase 5: Test suite expanded to 75+ tests, all passing
- [ ] Documentation updated (TODO.md, IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md)
- [ ] Zero #lint warnings across all modified files
- [ ] lake build succeeds
- [ ] lake test passes all tests
- [ ] Task 7 marked COMPLETE in TODO.md

## References

**Primary Documentation**:
- [Research Report: Lean 4 Core Automation Tactics](../reports/001-lean-mathlib-research.md)
- [TACTIC_DEVELOPMENT.md](/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Development/TACTIC_DEVELOPMENT.md)
- [METAPROGRAMMING_GUIDE.md](/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Development/METAPROGRAMMING_GUIDE.md)
- [TODO.md](/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md) (Task 7, lines 55-84)

**Lean 4 Resources**:
- Lean 4 Metaprogramming Book: https://leanprover-community.github.io/lean4-metaprogramming-book/
- Aesop Documentation: https://github.com/leanprover-community/aesop
- Mathlib Tactics: https://leanprover-community.github.io/mathlib4_docs/Mathlib/Tactic/

**Logos Codebase**:
- ProofSearch.lean: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/ProofSearch.lean
- Tactics.lean: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
- TacticsTest.lean: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
- Axioms.lean: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean

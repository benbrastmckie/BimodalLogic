# Lean 4 Core Automation Tactics Research Report

## Metadata
- **Date**: 2025-12-04
- **Agent**: lean-research-specialist
- **Topic**: Complete Task 7 (Implement Core Automation) from TODO.md - Implement remaining 8 tactics (bounded_search, search_with_heuristics, search_with_cache, matches_axiom, find_implications_to, heuristic_score, box_context, future_context), fix Truth.lean for Batteries compatibility, complete Aesop integration, and expand test suite to 50+ tests
- **Research Complexity**: 3
- **Report Type**: Comprehensive implementation research with codebase analysis
- **Lean Project Path**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Executive Summary

This report provides comprehensive research for completing Task 7 (Implement Core Automation) in the Logos TM logic theorem prover. The current implementation status shows 4/12 tactics complete (33%): `apply_axiom`, `modal_t`, `tm_auto` (native), and `assumption_search` with 50 passing tests. The research identifies that Aesop integration is **not currently blocked by Batteries** (build passes successfully), and provides detailed implementation patterns for the remaining 8 helper functions in ProofSearch.lean using native Lean 4 metaprogramming. Key findings emphasize self-contained implementation using Lean.Meta APIs, pattern matching for axiom detection, formula complexity heuristics, and context transformation helpers. The report recommends a phased approach: (1) implement 8 ProofSearch helpers (15-20h), (2) add Aesop integration with rule sets (10-15h), (3) expand test coverage beyond 50 tests (5-10h), with total estimated effort of 30-45 hours for complete Task 7 implementation.

## Research Findings

### 1. Current Implementation Status Analysis

#### 1.1 Completed Tactics (4/12 = 33%)

**Phase 4 Tactics (Logos/Core/Automation/Tactics.lean:72-90)**:
- `apply_axiom` (line 72-73): Macro-based axiom application using `refine` for unification
- `modal_t` (line 89-90): Convenience wrapper for Axiom.modal_t

**Phase 5 Tactics (lines 127-139)**:
- `tm_auto` (lines 127-139): Native automation using `first` combinator with 10 parallel `apply_axiom` attempts
- **Implementation Note**: Line 96 documents Aesop integration as "blocked by Batteries dependency" but current build status shows **zero Batteries errors** - this blocker may be resolved

**Phase 6 Tactics (lines 159-174)**:
- `assumption_search` (lines 159-174): TacticM-based context iteration with `isDefEq` checking
- **Implementation**: Uses `getLCtx`, `isDefEq`, `mkFVar` pattern (best practice from METAPROGRAMMING_GUIDE.md:657-686)

**Helper Functions (4/8 implemented, lines 183-200)**:
- ✓ `is_box_formula` (lines 183-185): Pattern match for `Formula.box _`
- ✓ `is_future_formula` (lines 188-190): Pattern match for `Formula.all_future _`
- ✓ `extract_from_box` (lines 193-195): Returns `some φ` from `Formula.box φ`
- ✓ `extract_from_future` (lines 198-200): Returns `some φ` from `Formula.all_future φ`

#### 1.2 Test Coverage Status (50/50 tests passing)

**Test File**: LogosTest/Core/Automation/TacticsTest.lean (286 lines)

**Test Distribution**:
- Phase 4: Tests 1-12 (apply_axiom, modal_t) - 12 tests
- Phase 5: Tests 13-18, 32-35 (tm_auto coverage) - 10 tests
- Phase 6: Tests 19-23 (assumption_search) - 5 tests
- Helpers: Tests 24-31 (pattern matching) - 8 tests
- Negative: Tests 36-43 (edge cases) - 8 tests
- Context: Tests 44-47 (context variations) - 4 tests
- Complex: Tests 48-50 (deep nesting) - 3 tests

**Coverage Assessment**: Test suite meets 50+ test requirement but could benefit from:
1. Propositional axiom coverage (prop_k, prop_s depth tests)
2. Modal K/Temporal K inference rule tests (not just axioms)
3. Temporal duality edge cases
4. Complex bimodal formula automation scenarios

### 2. Batteries Compatibility Investigation

#### 2.1 Current Build Status

**Finding**: `lake build` completes successfully with **zero Batteries-related errors**

**Evidence**:
```bash
$ lake build 2>&1 | head -50
Build completed successfully.
```

**Analysis**: The documented Aesop blocker (Tactics.lean:96) states:
> "Aesop integration was attempted but blocked by incompatibility with existing ProofChecker code (Batteries dependency causes type errors in Truth.lean)."

However, current evidence shows:
1. Build passes without Batteries errors
2. Mathlib dependency (lakefile.toml:7-9) includes Batteries transitively
3. No import conflicts detected in Truth.lean

**Conclusion**: The Batteries blocker may have been resolved in recent Mathlib updates (v4.14.0). Aesop integration should be **re-attempted** as part of Task 7 completion.

#### 2.2 Aesop Dependency Status

**Current Configuration** (lakefile.toml):
```toml
[[require]]
name = "mathlib"
git = "https://github.com/leanprover-community/mathlib4.git"
rev = "v4.14.0"
```

**Dependency Chain**: Mathlib v4.14.0 → Aesop (via mathlib dependencies)

**Verification**:
```bash
$ lake update aesop 2>&1 | head -20
info: toolchain not updated; already up-to-date
info: mathlib: running post-update hooks
✔ Built cache
No files to download
Decompressing 5685 file(s)
Unpacked in 5159 ms
Completed successfully!
```

**Finding**: Aesop is available via Mathlib and does not require separate dependency declaration.

### 3. Remaining ProofSearch.lean Implementation (8 functions)

#### 3.1 Architecture Overview

**Current Status** (Logos/Core/Automation/ProofSearch.lean:110-177):
- All 8 functions declared as `axiom` stubs (lines 133, 146, 156, 164, 167, 170, 173, 176)
- Comprehensive documentation with algorithm descriptions (lines 112-132)
- Infrastructure complete: `SearchResult` type alias (line 91), `ProofCache` structure (lines 99-105)

**Implementation Strategy**: Replace axiom stubs with native Lean 4 implementations using:
1. Formula pattern matching (Lean.Expr destructuring)
2. List operations (Mathlib's List API)
3. Recursive search with depth bounds
4. Option monad for search results

#### 3.2 Function 1: bounded_search (Primary Search Function)

**Signature** (line 133):
```lean
axiom bounded_search (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ
```

**Documented Algorithm** (lines 121-130):
1. Base case: depth = 0 → return none
2. Check axioms: if φ matches axiom schema → return axiom proof
3. Check assumptions: if φ ∈ Γ → return assumption proof
4. Try modus ponens: search for (ψ → φ) ∈ Γ, recursively search for ψ
5. Try modal K: if φ = □ψ, search for ψ in Γ.map box
6. Try temporal K: if φ = Fψ, search for ψ in Γ.map future
7. Try weakening: search with extended context
8. Return none if all fail

**Implementation Pattern** (elab_rules + TacticM):
```lean
def bounded_search (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ :=
  if depth = 0 then none
  else
    -- Step 2: Check axioms
    if matches_axiom φ then
      some (Derivable.axiom Γ φ (axiom_instance_of φ))
    -- Step 3: Check assumptions
    else if h : φ ∈ Γ then
      some (Derivable.assumption Γ φ h)
    -- Step 4: Try modus ponens
    else
      let implications := find_implications_to Γ φ
      implications.foldl (fun acc ψ =>
        match acc with
        | some proof => some proof
        | none =>
          match bounded_search Γ ψ (depth - 1) with
          | some h_ψ =>
            match bounded_search Γ (ψ.imp φ) (depth - 1) with
            | some h_imp => some (Derivable.modus_ponens Γ ψ φ h_imp h_ψ)
            | none => none
          | none => none
      ) none
```

**Key Design Decisions**:
- Use `foldl` for trying multiple strategies without explicit backtracking state
- Return early with `some proof` when found
- Depth-bound prevents infinite recursion
- Complexity: O(b^d) where b = branching factor ≈ |Γ| + 10 axioms, d = depth

**Estimated Effort**: 6-8 hours (core search logic + integration)

#### 3.3 Function 2: matches_axiom (Axiom Pattern Matching)

**Signature** (line 164):
```lean
axiom matches_axiom (φ : Formula) : Bool
```

**Purpose**: Detect if formula matches any of 10 TM axiom schemas

**Implementation Pattern** (structural matching):
```lean
def matches_axiom (φ : Formula) : Bool :=
  match φ with
  -- Propositional axioms
  | Formula.imp ψ (Formula.imp χ ψ') => ψ = ψ'  -- prop_s: ψ → (χ → ψ)
  | Formula.imp (Formula.imp ψ (Formula.imp χ ρ))
                (Formula.imp (Formula.imp ψ χ) (Formula.imp ψ ρ)) => true  -- prop_k
  -- Modal axioms
  | Formula.imp (Formula.box ψ) ψ' => ψ = ψ'  -- modal_t: □ψ → ψ
  | Formula.imp (Formula.box ψ) (Formula.box (Formula.box ψ')) => ψ = ψ'  -- modal_4
  | Formula.imp ψ (Formula.box (Formula.diamond ψ')) => ψ = ψ'  -- modal_b
  -- Temporal axioms
  | Formula.imp (Formula.all_future ψ) (Formula.all_future (Formula.all_future ψ')) => ψ = ψ'  -- temp_4
  | Formula.imp ψ (Formula.all_future (Formula.some_past ψ')) => ψ = ψ'  -- temp_a
  | Formula.imp (Formula.some_past ψ) (Formula.all_future ψ') => ψ = ψ'  -- temp_l (NOTE: check definition)
  -- Bimodal axioms
  | Formula.imp (Formula.box ψ) (Formula.all_future (Formula.box ψ')) => ψ = ψ'  -- modal_future
  | Formula.imp (Formula.all_future ψ) (Formula.box (Formula.all_future ψ')) => ψ = ψ'  -- temp_future
  | _ => false
```

**Key Implementation Details**:
- Exhaustive pattern matching for all 10 axiom schemas
- Use definitional equality check (`ψ = ψ'`) for schema variable matching
- Return `false` for non-axiom formulas
- **Critical**: Verify axiom schema definitions against Axioms.lean (Logos/Core/ProofSystem/Axioms.lean)

**Verification Requirement**: Cross-check each pattern against actual axiom constructors:
```lean
-- Example: Verify modal_t pattern from Axioms.lean
inductive Axiom : Formula → Type where
  | modal_t (φ : Formula) : Axiom ((Formula.box φ).imp φ)
  -- ^ Matches pattern: Formula.imp (Formula.box ψ) ψ' where ψ = ψ'
```

**Estimated Effort**: 3-4 hours (pattern writing + verification + testing)

#### 3.4 Function 3: find_implications_to (Context Search)

**Signature** (line 167):
```lean
axiom find_implications_to (Γ : Context) (φ : Formula) : List Formula
```

**Purpose**: Find all `ψ` where `(ψ → φ) ∈ Γ` (for modus ponens application)

**Implementation Pattern** (List filter + pattern match):
```lean
def find_implications_to (Γ : Context) (φ : Formula) : List Formula :=
  Γ.filterMap (fun γ =>
    match γ with
    | Formula.imp ψ χ => if χ = φ then some ψ else none
    | _ => none
  )
```

**Example**:
- Given Γ = [P → Q, R → Q, S → T, Q]
- find_implications_to Γ Q = [P, R]
- find_implications_to Γ T = [S]

**Complexity**: O(|Γ|) linear scan with pattern matching

**Estimated Effort**: 1-2 hours (simple List operation)

#### 3.5 Function 4: heuristic_score (Search Ordering)

**Signature** (line 170):
```lean
axiom heuristic_score (Γ : Context) (φ : Formula) : Nat
```

**Purpose**: Compute priority score for search branches (lower = better)

**Heuristic Design** (from Report 021:138-143):
- **Axioms**: Score 0 (cheapest, no recursion)
- **Assumptions**: Score 1 (second cheapest)
- **Modus ponens**: Score 2 + complexity(antecedent) (recursive)
- **Modal/Temporal K**: Score 5 + |Γ| (expensive context transformation)

**Implementation Pattern**:
```lean
def heuristic_score (Γ : Context) (φ : Formula) : Nat :=
  if matches_axiom φ then 0
  else if φ ∈ Γ then 1
  else
    -- Check if modus ponens applicable
    let implications := find_implications_to Γ φ
    if implications.isEmpty then
      -- Try modal/temporal K
      match φ with
      | Formula.box _ => 5 + Γ.length
      | Formula.all_future _ => 5 + Γ.length
      | _ => 100  -- No strategy applicable
    else
      -- Modus ponens: score by simplest antecedent
      2 + (implications.map (fun ψ => ψ.complexity)).minimum?.getD 100

/-- Formula complexity (recursive size) -/
def Formula.complexity : Formula → Nat
  | Formula.atom _ => 1
  | Formula.bot => 1
  | Formula.imp φ ψ => 1 + φ.complexity + ψ.complexity
  | Formula.box φ => 1 + φ.complexity
  | Formula.all_past φ => 1 + φ.complexity
  | Formula.all_future φ => 1 + φ.complexity
```

**Design Rationale**:
- Prefer simple proofs (axioms) over complex derivations
- Avoid expensive context transformations unless necessary
- Use formula complexity as tie-breaker for modus ponens

**Estimated Effort**: 2-3 hours (scoring function + complexity helper)

#### 3.6 Function 5: search_with_heuristics (Priority Queue Search)

**Signature** (line 146):
```lean
axiom search_with_heuristics (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ
```

**Purpose**: Best-first search using heuristic ordering

**Implementation Pattern** (priority queue with score ordering):
```lean
/-- Search state: (score, remaining_depth, goal_formula) -/
structure SearchState where
  score : Nat
  depth : Nat
  goal : Formula
  deriving Ord

def search_with_heuristics (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ :=
  -- Priority queue implemented as sorted list (simple MVP)
  let initial_queue : List SearchState := [⟨heuristic_score Γ φ, depth, φ⟩]
  search_loop Γ initial_queue
where
  search_loop (Γ : Context) (queue : List SearchState) : SearchResult Γ φ :=
    match queue.head? with
    | none => none  -- Queue exhausted, no proof found
    | some ⟨score, d, ψ⟩ =>
      if d = 0 then search_loop Γ queue.tail!  -- Skip exhausted branches
      else
        -- Try strategies in order of heuristic score
        if matches_axiom ψ then
          some (Derivable.axiom Γ ψ (axiom_instance_of ψ))
        else if h : ψ ∈ Γ then
          some (Derivable.assumption Γ ψ h)
        else
          -- Expand search: add subgoals to queue with updated scores
          let new_states := expand_search_state Γ ⟨score, d, ψ⟩
          search_loop Γ (merge_priority_queues queue.tail! new_states)
```

**Key Optimization**: Use `List.insertionSort` with `SearchState.ord` for priority ordering

**Estimated Effort**: 5-6 hours (priority queue logic + state expansion)

#### 3.7 Function 6: search_with_cache (Memoized Search)

**Signature** (line 156-157):
```lean
axiom search_with_cache (cache : ProofCache) (Γ : Context) (φ : Formula) (depth : Nat) :
  SearchResult Γ φ × ProofCache
```

**Purpose**: Cache successful derivations to avoid redundant search

**Implementation Pattern** (state monad with cache lookup):
```lean
def search_with_cache (cache : ProofCache) (Γ : Context) (φ : Formula) (depth : Nat) :
    SearchResult Γ φ × ProofCache :=
  -- Check cache first
  match cache.lookup Γ φ with
  | some proof => (some proof, cache)  -- Cache hit
  | none =>
    -- Cache miss: perform search
    match bounded_search Γ φ depth with
    | some proof =>
      -- Update cache with successful proof
      let new_cache := cache.insert Γ φ proof
      (some proof, new_cache)
    | none => (none, cache)  -- Failed search, don't cache

/-- Cache operations (requires decidable equality on Formula) -/
structure ProofCache where
  cache : List ((Context × Formula) × Derivable)  -- Simple list-based cache

def ProofCache.lookup (c : ProofCache) (Γ : Context) (φ : Formula) : Option (Derivable Γ φ) :=
  c.cache.findSome? (fun ((Γ', φ'), proof) =>
    if Γ = Γ' ∧ φ = φ' then some proof else none
  )

def ProofCache.insert (c : ProofCache) (Γ : Context) (φ : Formula) (proof : Derivable Γ φ) : ProofCache :=
  ⟨((Γ, φ), proof) :: c.cache⟩
```

**Design Trade-offs**:
- **Simple list-based cache**: O(n) lookup but easy to implement
- **Future optimization**: Use `HashMap` from Batteries.Data.HashMap (when Batteries confirmed compatible)
- **Cache invalidation**: Not needed (derivations are immutable)

**Estimated Effort**: 3-4 hours (cache structure + integration)

#### 3.8 Functions 7-8: box_context and future_context (Context Transformers)

**Signatures** (lines 173, 176):
```lean
axiom box_context (Γ : Context) : Context
axiom future_context (Γ : Context) : Context
```

**Purpose**: Transform contexts for modal_k and temporal_k inference rules

**Implementation Pattern** (simple List.map):
```lean
def box_context (Γ : Context) : Context :=
  Γ.map Formula.box

def future_context (Γ : Context) : Context :=
  Γ.map Formula.all_future
```

**Example**:
- Given Γ = [P, Q → R, S]
- box_context Γ = [□P, □(Q → R), □S]
- future_context Γ = [GP, G(Q → R), GS]

**Usage in Search** (bounded_search extension):
```lean
-- Step 5: Try modal K
| Formula.box ψ =>
  match bounded_search (box_context Γ) ψ (depth - 1) with
  | some h_ψ => some (Derivable.modal_k Γ ψ h_ψ)
  | none => -- continue to next strategy

-- Step 6: Try temporal K
| Formula.all_future ψ =>
  match bounded_search (future_context Γ) ψ (depth - 1) with
  | some h_ψ => some (Derivable.temporal_k Γ ψ h_ψ)
  | none => -- continue to next strategy
```

**Estimated Effort**: 1 hour (trivial List.map wrappers)

### 4. Aesop Integration Strategy

#### 4.1 Rule Set Declaration (TM-Specific Automation)

**Pattern** (from TACTIC_DEVELOPMENT.md:310-336):
```lean
-- File: Logos/Core/Automation/AesopRules.lean
import Aesop
import Logos.Core.ProofSystem

-- Declare TM logic rule set
declare_aesop_rule_sets [TMLogic]

-- Mark axioms as safe forward rules
@[aesop safe forward [TMLogic]]
theorem modal_t_forward (φ : Formula) (h : Derivable Γ (Formula.box φ)) :
    Derivable Γ φ := by
  apply Derivable.modus_ponens
  · apply Derivable.axiom
    exact Axiom.modal_t φ
  · exact h

@[aesop safe forward [TMLogic]]
theorem modal_4_forward (φ : Formula) (h : Derivable Γ (Formula.box φ)) :
    Derivable Γ (Formula.box (Formula.box φ)) := by
  apply Derivable.modal_k
  apply Derivable.weakening h
  -- Context transformation proof

-- Mark perpetuity principles
@[aesop safe forward [TMLogic]]
theorem perpetuity_1 (φ : Formula) :
    Derivable [] ((Formula.box φ).imp (φ.always)) := by
  sorry  -- Use existing proof from Perpetuity.lean

-- Mark inference rules as safe
@[aesop safe apply [TMLogic]]
theorem apply_modus_ponens :
    Derivable Γ (φ.imp ψ) → Derivable Γ φ → Derivable Γ ψ := by
  intro h1 h2
  exact Derivable.modus_ponens Γ φ ψ h1 h2
```

**Integration with tm_auto** (replace native version):
```lean
-- File: Logos/Core/Automation/Tactics.lean
macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]))
```

**Estimated Effort**: 10-15 hours (rule markup + forward chaining lemmas)

#### 4.2 Normalization Rules (Simplification)

**Pattern** (from TACTIC_DEVELOPMENT.md:375-395):
```lean
-- S5 modal simplifications (requires soundness proofs first)
@[aesop norm simp [TMLogic]]
theorem box_box_eq_box (φ : Formula) :
    Formula.box (Formula.box φ) = Formula.box φ := by
  sorry  -- Requires M4 axiom bidirectionality

@[aesop norm simp [TMLogic]]
theorem future_future_eq_future (φ : Formula) :
    Formula.all_future (Formula.all_future φ) = Formula.all_future φ := by
  sorry  -- Requires T4 axiom bidirectionality

-- Bimodal commutativity (requires MF/TF axioms)
@[aesop norm simp [TMLogic]]
theorem box_future_comm (φ : Formula) :
    Formula.box (Formula.all_future φ) = Formula.all_future (Formula.box φ) := by
  sorry  -- Requires MF and TF soundness
```

**Critical Dependency**: These simp lemmas require completing soundness proofs for MF, TF axioms (currently incomplete, see Truth.lean).

**Alternative Strategy**: Use `@[aesop norm unfold]` for derived operators instead of equational simp:
```lean
@[aesop norm unfold [TMLogic]]
def Formula.diamond (φ : Formula) : Formula := (Formula.box φ.neg).neg

@[aesop norm unfold [TMLogic]]
def Formula.always (φ : Formula) : Formula :=
  (φ.all_past.imp (φ.neg.imp φ.all_future.neg)).neg
```

**Estimated Effort**: 5-8 hours (normalization rules + simp proofs)

### 5. Test Expansion Strategy (50+ → 75+ tests)

#### 5.1 Current Coverage Gaps

**Analysis of TacticsTest.lean**:
- ✓ All 10 axioms tested via apply_axiom (Tests 1-12)
- ✓ tm_auto coverage for 8/10 axioms (Tests 13-18, 32-35)
- ✓ assumption_search basic functionality (Tests 19-23)
- ✓ Helper functions (Tests 24-31)
- ✓ Edge cases (Tests 36-50)

**Missing Coverage**:
1. **Inference Rules**: No tests for modal_k, temporal_k, temporal_duality rules
2. **ProofSearch Functions**: No tests for bounded_search, search_with_heuristics, search_with_cache
3. **Context Transformers**: No tests for box_context, future_context
4. **Propositional Reasoning**: No depth tests for prop_k, prop_s
5. **Negative Cases**: Limited failure mode testing

#### 5.2 Proposed Additional Tests (25 new tests = 75 total)

**Test Group 1: Inference Rules (Tests 51-58, 8 tests)**:
```lean
/-- Test 51: modal_k rule application -/
example (p q : Formula) :
    Derivable [p.box, (p.imp q).box] q.box := by
  apply Derivable.modal_k
  apply Derivable.modus_ponens
  · apply Derivable.assumption
    simp [Context.map]
  · apply Derivable.assumption
    simp [Context.map]

/-- Test 52: temporal_k rule application -/
example (p q : Formula) :
    Derivable [p.all_future, (p.imp q).all_future] q.all_future := by
  apply Derivable.temporal_k
  apply Derivable.modus_ponens
  · apply Derivable.assumption
    simp [Context.map]
  · apply Derivable.assumption
    simp [Context.map]

/-- Test 53: temporal_duality rule -/
example (p : Formula) :
    Derivable [] (p.all_future.imp p.all_past) := by
  apply Derivable.temporal_duality
  -- Would need proof of swapped formula

/-- Tests 54-58: Nested rule applications, complex contexts -/
-- (5 more inference rule tests)
```

**Test Group 2: ProofSearch Functions (Tests 59-66, 8 tests)**:
```lean
/-- Test 59: bounded_search finds axiom at depth 1 -/
example : bounded_search [] ((Formula.atom "p").box.imp (Formula.atom "p")) 1 = some _ := by
  rfl

/-- Test 60: bounded_search returns none at depth 0 -/
example : bounded_search [] complex_formula 0 = none := by
  rfl

/-- Test 61: search_with_heuristics prefers axioms -/
example : ∃ proof, search_with_heuristics Γ φ 5 = some proof := by
  sorry

/-- Tests 62-66: Cache behavior, context transformers -/
-- (5 more search tests)
```

**Test Group 3: Propositional Depth (Tests 67-72, 6 tests)**:
```lean
/-- Test 67: prop_k chained application -/
example (p q r : Formula) :
    Derivable [] ((p.imp (q.imp r)).imp ((p.imp q).imp (p.imp r))) := by
  tm_auto

/-- Tests 68-72: Complex propositional derivations -/
-- (5 more propositional tests)
```

**Test Group 4: Aesop Integration (Tests 73-75, 3 tests)**:
```lean
/-- Test 73: tm_auto with Aesop finds complex proof -/
example (p : Formula) : Derivable [p.box] p := by
  tm_auto

/-- Tests 74-75: Aesop forward chaining, normalization -/
-- (2 more Aesop tests)
```

**Estimated Effort**: 5-8 hours (test writing + debugging)

### 6. Implementation Complexity Analysis

#### 6.1 Dependency Graph

```
bounded_search (6-8h)
├── matches_axiom (3-4h)
├── find_implications_to (1-2h)
└── box_context, future_context (1h)

search_with_heuristics (5-6h)
├── heuristic_score (2-3h)
│   ├── matches_axiom (above)
│   └── find_implications_to (above)
└── bounded_search (above)

search_with_cache (3-4h)
└── bounded_search (above)

tm_auto (Aesop integration) (10-15h)
├── Rule set declaration (5-8h)
└── Normalization rules (5-8h)

Test expansion (5-8h)
└── All above functions
```

**Critical Path**: bounded_search → matches_axiom, find_implications_to (foundational for all search)

#### 6.2 Phased Implementation Strategy

**Phase 1: Core ProofSearch Helpers (10-12 hours)**:
1. `matches_axiom` (3-4h) - Independent, foundational
2. `find_implications_to` (1-2h) - Independent
3. `box_context`, `future_context` (1h) - Trivial
4. `heuristic_score` (2-3h) - Depends on above
5. Tests for helpers (2-3h)

**Phase 2: Bounded Search (8-10 hours)**:
1. `bounded_search` implementation (6-8h) - Uses Phase 1 helpers
2. Tests for bounded_search (2h)

**Phase 3: Advanced Search (8-10 hours)**:
1. `search_with_heuristics` (5-6h) - Uses bounded_search
2. `search_with_cache` (3-4h) - Uses bounded_search

**Phase 4: Aesop Integration (10-15 hours)**:
1. Verify Batteries compatibility (1h) - Re-test after Mathlib v4.14.0
2. Declare TMLogic rule set (2-3h)
3. Mark axioms as forward rules (5-8h)
4. Add normalization rules (3-4h)
5. Replace tm_auto macro with Aesop (1h)

**Phase 5: Test Expansion (5-8 hours)**:
1. Inference rule tests (2-3h)
2. ProofSearch tests (2-3h)
3. Aesop integration tests (1-2h)

**Total Sequential Effort**: 41-55 hours
**Estimated Parallel Effort**: 30-45 hours (Phases 1-2 parallel, Phases 3-4 parallel)

### 7. Risk Assessment and Mitigation

#### 7.1 High-Priority Risks

**Risk 1: Batteries Compatibility (Medium likelihood, High impact)**
- **Evidence**: TODO.md line 78 states "Batteries dependency causes type errors in Truth.lean"
- **Counter-evidence**: Current build passes successfully
- **Mitigation**: Re-test Aesop import in Truth.lean, verify no type conflicts
- **Contingency**: Keep native tm_auto as fallback if Aesop fails

**Risk 2: Axiom Pattern Matching Complexity (High likelihood, Medium impact)**
- **Challenge**: matches_axiom must correctly identify all 10 axiom schemas
- **Pitfall**: Incorrect pattern matching causes false positives/negatives in search
- **Mitigation**: Extensive test coverage (one test per axiom schema)
- **Verification**: Cross-check each pattern against Axioms.lean constructor

**Risk 3: Search Performance (Medium likelihood, Medium impact)**
- **Challenge**: Bounded search with depth 5+ may be slow on complex formulas
- **Evidence**: Report 021:445-449 notes S5+LTL is EXPTIME-complete
- **Mitigation**: Start with conservative depth bounds (3-5), use heuristic search
- **Future optimization**: Implement tableau method (40-60h additional effort)

#### 7.2 Low-Priority Risks

**Risk 4: ProofCache Memory Usage (Low likelihood, Low impact)**
- **Challenge**: List-based cache grows unbounded
- **Mitigation**: Use simple cache with fixed capacity
- **Future optimization**: Implement LRU eviction or HashMap-based cache

**Risk 5: Test Maintenance Burden (Medium likelihood, Low impact)**
- **Challenge**: 75+ tests increase maintenance cost
- **Mitigation**: Group tests by functionality, use clear naming conventions
- **Documentation**: Maintain test coverage matrix in TacticsTest.lean header

### 8. Alternative Implementation Approaches

#### 8.1 Pure Native vs Aesop Hybrid

**Option A: Pure Native Implementation (Current Approach)**
- **Pros**: Zero external dependencies, full control, no Batteries risk
- **Cons**: More implementation work (40-45h vs 30-35h with Aesop)
- **Status**: 33% complete (4/12 tactics)

**Option B: Aesop-Heavy Approach (Recommended)**
- **Pros**: Leverages proven proof search (Aesop paper CPP 2023), less code
- **Cons**: Requires Batteries compatibility verification
- **Recommendation**: Re-test Aesop after confirming Batteries status

**Option C: Hybrid Approach (Proposed)**
- **Strategy**: Native bounded_search + Aesop for tm_auto
- **Rationale**: ProofSearch.lean provides low-level search primitives, Aesop provides high-level automation
- **Best of both**: Maximum flexibility (native) + maximum automation (Aesop)

#### 8.2 Proof Search Algorithms

**Option A: Depth-First Search (Current)**
- **Implementation**: bounded_search with depth limit
- **Pros**: Simple to implement, memory-efficient
- **Cons**: May miss proofs within depth bound (incomplete ordering)

**Option B: Best-First Search (Recommended)**
- **Implementation**: search_with_heuristics with priority queue
- **Pros**: Finds shorter proofs, more efficient
- **Cons**: Requires priority queue data structure

**Option C: Tableaux Method (Future Work)**
- **Implementation**: Systematic decomposition with branch closure
- **Pros**: Complete decision procedure for S5+LTL (within complexity bounds)
- **Cons**: High implementation effort (40-60h)
- **Reference**: Report 021:410-450, TACTIC_DEVELOPMENT.md future tactics

## Recommendations

### 1. Verify Batteries Compatibility (Priority: URGENT, Effort: 1-2 hours)

**Action**: Re-test Aesop integration to confirm Batteries blocker resolution

**Steps**:
1. Add Aesop import to Truth.lean: `import Aesop`
2. Run `lake build Logos/Core/Semantics/Truth.lean`
3. Check for type errors in truth_at or validity definitions
4. Document findings in task report

**Rationale**: Current evidence (successful build) contradicts documented blocker. Verification unblocks 10-15 hours of Aesop integration work.

**Expected Outcome**: One of:
- **Success**: Batteries compatible, proceed with Aesop integration
- **Failure**: Batteries incompatible, document specific errors, use native-only approach

### 2. Implement ProofSearch Helpers (Priority: HIGH, Effort: 15-20 hours)

**Action**: Complete 8 helper functions in ProofSearch.lean using native Lean 4

**Phase 1 (10-12h)**: Foundation
- `matches_axiom` (3-4h): Pattern match all 10 axiom schemas
- `find_implications_to` (1-2h): List.filterMap for implication search
- `box_context`, `future_context` (1h): List.map wrappers
- `heuristic_score` (2-3h): Scoring function with complexity metric
- Tests (2-3h): One test per helper function

**Phase 2 (5-8h)**: Search Implementation
- `bounded_search` (6-8h): Depth-first search with strategy ordering
- Tests (2h): Depth variation, axiom finding, modus ponens

**Rationale**: These helpers are foundational for all proof search functionality and have zero external dependencies (pure Lean 4 + Mathlib).

**Success Criteria**:
- All 8 functions replace axiom stubs with implementations
- 15+ new tests pass (one per function + edge cases)
- `lake build` succeeds with zero warnings

### 3. Expand Test Suite (Priority: MEDIUM, Effort: 5-8 hours)

**Action**: Add 25 new tests to reach 75+ total coverage

**Test Groups**:
- **Inference Rules** (8 tests): modal_k, temporal_k, temporal_duality
- **ProofSearch** (8 tests): bounded_search depth variations, cache behavior
- **Propositional** (6 tests): Chained prop_k, prop_s applications
- **Aesop** (3 tests): tm_auto with rule sets (if Batteries compatible)

**Rationale**: Current 50-test suite meets minimum requirement but lacks inference rule and search coverage.

**Success Criteria**:
- 75+ passing tests in TacticsTest.lean
- All 7 inference rules tested
- All 8 ProofSearch functions tested

### 4. Complete Aesop Integration (Priority: MEDIUM, Effort: 10-15 hours)

**Action**: Implement Aesop-based tm_auto if Batteries compatibility confirmed

**Implementation**:
1. Create `Logos/Core/Automation/AesopRules.lean` (5-8h)
   - Declare TMLogic rule set
   - Mark axioms as safe forward rules
   - Add perpetuity principles as forward rules
2. Add normalization rules (3-4h)
   - `@[aesop norm unfold]` for derived operators
   - `@[aesop norm simp]` for equational simplifications (if soundness complete)
3. Replace tm_auto macro (1h)
   - Change from native `first` combinator to `aesop (rule_sets [TMLogic])`
4. Integration tests (2h)

**Rationale**: Aesop provides proven proof search automation (CPP 2023 paper) with better performance than native bounded_search.

**Contingency**: If Batteries incompatible, keep native tm_auto and skip Aesop integration.

### 5. Documentation Updates (Priority: LOW, Effort: 2-3 hours)

**Action**: Update documentation to reflect completed automation

**Files to Update**:
1. **TODO.md** (line 55-84):
   - Update status from "PARTIAL COMPLETE (33%)" to "COMPLETE (100%)"
   - Document ProofSearch implementations
   - Update effort estimates with actuals
2. **IMPLEMENTATION_STATUS.md**:
   - Update Automation section from 33% to 100%
   - Document Aesop integration status
3. **KNOWN_LIMITATIONS.md**:
   - Remove "Automation Package: Infrastructure only" limitation
   - Document any remaining search performance limitations

**Rationale**: Accurate documentation prevents confusion and tracks project progress.

## Implementation Roadmap

### Phased Execution Plan (30-45 hours total)

**Phase 1: Core Helpers (10-12 hours)**
- Week 1: Implement matches_axiom, find_implications_to, context transformers
- Deliverable: 4 functions complete, 10+ tests passing

**Phase 2: Bounded Search (8-10 hours)**
- Week 1-2: Implement bounded_search with helper integration
- Deliverable: Primary search function complete, 5+ tests passing

**Phase 3: Advanced Search (8-10 hours)**
- Week 2: Implement search_with_heuristics and search_with_cache
- Deliverable: All 8 ProofSearch functions complete

**Phase 4: Aesop Integration (10-15 hours)**
- Week 3: Verify Batteries, implement rule sets, test integration
- Deliverable: tm_auto using Aesop (or documented blocker with native fallback)

**Phase 5: Test Expansion (5-8 hours)**
- Week 3-4: Add 25 new tests, verify coverage
- Deliverable: 75+ passing tests, complete coverage matrix

**Phase 6: Documentation (2-3 hours)**
- Week 4: Update TODO.md, IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md
- Deliverable: Task 7 marked COMPLETE in TODO.md

**Total Timeline**: 3-4 weeks (assuming 10-15h/week effort)

## Technical Specifications

### Function Signatures (Complete Reference)

```lean
-- ProofSearch.lean (8 functions to implement)

/-- Primary bounded depth-first search -/
def bounded_search (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ

/-- Heuristic-guided best-first search -/
def search_with_heuristics (Γ : Context) (φ : Formula) (depth : Nat) : SearchResult Γ φ

/-- Cached search with memoization -/
def search_with_cache (cache : ProofCache) (Γ : Context) (φ : Formula) (depth : Nat) :
  SearchResult Γ φ × ProofCache

/-- Check if formula matches any axiom schema -/
def matches_axiom (φ : Formula) : Bool

/-- Find implications with φ as consequent -/
def find_implications_to (Γ : Context) (φ : Formula) : List Formula

/-- Compute search branch priority score -/
def heuristic_score (Γ : Context) (φ : Formula) : Nat

/-- Transform context for modal K rule -/
def box_context (Γ : Context) : Context

/-- Transform context for temporal K rule -/
def future_context (Γ : Context) : Context
```

### Test Coverage Matrix

| Function | Unit Tests | Integration Tests | Edge Cases |
|----------|-----------|------------------|-----------|
| matches_axiom | 10 (one per axiom) | 5 (complex formulas) | 3 (non-axioms) |
| find_implications_to | 5 | 3 (with bounded_search) | 2 (empty context) |
| heuristic_score | 5 | 3 (with search) | 2 (edge scores) |
| box_context | 3 | 2 (with modal_k) | 1 (empty) |
| future_context | 3 | 2 (with temporal_k) | 1 (empty) |
| bounded_search | 8 | 10 (with tactics) | 5 (depth limits) |
| search_with_heuristics | 5 | 3 | 2 |
| search_with_cache | 5 | 3 | 2 |
| **Total** | **44** | **31** | **18** |

**Grand Total**: 93 tests (exceeds 75+ target)

## References

### Primary Documentation Sources

1. **TACTIC_DEVELOPMENT.md** (Logos/Documentation/Development/)
   - Lines 79-103: Pattern matching syntax for modal operators
   - Lines 283-368: Aesop integration for TM logic
   - Lines 425-537: Simp lemma design for modal logic
   - Best practices for elab_rules and TacticM approaches

2. **METAPROGRAMMING_GUIDE.md** (Logos/Documentation/Development/)
   - Lines 47-88: Core imports and module organization
   - Lines 93-175: Goal management patterns
   - Lines 177-281: Expression pattern matching
   - Lines 283-397: Proof term construction with mkAppM
   - Lines 567-607: Complete assumption_search example

3. **Report 021: LEAN 4 Modal Logic Best Practices** (.claude/specs/021_lean4_bimodal_logic_best_practices/)
   - Lines 254-299: Metaprogramming architecture patterns
   - Lines 301-349: Aesop integration patterns
   - Lines 350-377: Simp lemma design principles
   - Lines 384-451: Proof search strategies for bimodal logic

4. **TODO.md** (Lines 55-84)
   - Task 7 status and remaining work
   - Blocker documentation for Aesop integration
   - Implementation summary from 2025-12-03

### External References

5. **Lean 4 Metaprogramming Book**
   - Chapter 9 (Tactics): https://leanprover-community.github.io/lean4-metaprogramming-book/main/09_tactics.html
   - Chapter 11 (Aesop): https://leanprover-community.github.io/lean4-metaprogramming-book/main/11_aesop.html

6. **Aesop Documentation**
   - GitHub: https://github.com/leanprover-community/aesop
   - CPP 2023 Paper: https://dl.acm.org/doi/10.1145/3573105.3575671

7. **Mathlib4 Tactics**
   - API Docs: https://leanprover-community.github.io/mathlib4_docs/Mathlib/Tactic/
   - solve_by_elim: Proof search reference implementation

## Conclusion

Task 7 (Implement Core Automation) requires 30-45 hours of focused implementation work distributed across 5 phases: (1) ProofSearch helpers (15-20h), (2) Aesop integration verification and implementation (10-15h), (3) test expansion (5-8h), (4) documentation updates (2-3h), and (5) integration validation (3-5h). The research identifies that the documented Batteries blocker appears resolved (current build passes), enabling Aesop integration as the recommended approach. The implementation strategy prioritizes self-contained native Lean 4 code for ProofSearch.lean helpers (zero external dependencies) while leveraging Aesop's proven automation for tm_auto (if compatibility confirmed). Test expansion from 50 to 75+ tests ensures comprehensive coverage of inference rules, search functions, and edge cases. Upon completion, Logos will have production-ready proof automation capable of finding derivations for standard TM logic theorems with bounded depth-first search, heuristic guidance, and optional Aesop integration for advanced automation scenarios.

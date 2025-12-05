# Phase 1 Quick Reference: Helper Functions

## Function Signatures

```lean
-- Pattern matching against axiom schemas
def matches_axiom (φ : Formula) : Bool

-- Find implications with target consequent
def find_implications_to (Γ : Context) (φ : Formula) : List Formula

-- Context transformations for K rules
def box_context (Γ : Context) : Context
def future_context (Γ : Context) : Context

-- Heuristic scoring for search prioritization
def heuristic_score (Γ : Context) (φ : Formula) : Nat

-- Already implemented in Formula.lean
def Formula.complexity : Formula → Nat
```

## Usage Examples

### matches_axiom
```lean
-- Matches modal T axiom: □p → p
matches_axiom (Formula.box p |>.imp p)  -- returns true

-- Not an axiom
matches_axiom (Formula.atom "p")  -- returns false
```

### find_implications_to
```lean
-- Find antecedents for goal q
let Γ := [p.imp q, r.imp q]
find_implications_to Γ q  -- returns [p, r]

-- No implications to r
find_implications_to [p, q] r  -- returns []
```

### box_context
```lean
-- Transform context for modal K
let Γ := [Formula.atom "p", Formula.atom "q"]
box_context Γ
-- returns [Formula.box (Formula.atom "p"),
--          Formula.box (Formula.atom "q")]
```

### future_context
```lean
-- Transform context for temporal K
let Γ := [Formula.atom "p", Formula.atom "q"]
future_context Γ
-- returns [Formula.all_future (Formula.atom "p"),
--          Formula.all_future (Formula.atom "q")]
```

### heuristic_score
```lean
-- Axiom: best score
heuristic_score [] (Formula.box p |>.imp p)  -- returns 0

-- In context: second best
heuristic_score [p] p  -- returns 1

-- Modus ponens applicable
heuristic_score [p.imp q] q  -- returns 2 + p.complexity

-- Modal K applicable
heuristic_score [] (Formula.box p)  -- returns 5 + 0

-- No strategy
heuristic_score [] (Formula.atom "p")  -- returns 100
```

## Axiom Patterns Recognized

1. **prop_k**: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
2. **prop_s**: `φ → (ψ → φ)`
3. **modal_t**: `□φ → φ`
4. **modal_4**: `□φ → □□φ`
5. **modal_b**: `φ → □◇φ`
6. **temp_4**: `Fφ → FFφ`
7. **temp_a**: `φ → F(Pφ)`
8. **temp_l**: `△φ → F(Hφ)`
9. **modal_future**: `□φ → □Fφ`
10. **temp_future**: `□φ → F□φ`

## Heuristic Scoring Strategy

| Strategy | Score | Description |
|----------|-------|-------------|
| Axiom | 0 | Immediate proof via axiom |
| Assumption | 1 | Direct lookup in context |
| Modus Ponens | 2 + complexity | One subgoal, weighted |
| Modal/Temporal K | 5 + \|Γ\| | Context transformation |
| No Strategy | 100 | Dead end (prune) |

## Complexity Analysis

| Function | Time Complexity | Space Complexity |
|----------|----------------|------------------|
| matches_axiom | O(n) | O(1) |
| find_implications_to | O(n) | O(k) where k = matches |
| box_context | O(n) | O(n) |
| future_context | O(n) | O(n) |
| heuristic_score | O(n·m) | O(1) |
| Formula.complexity | O(n) | O(1) |

Where:
- n = size of context or formula structure
- m = max formula complexity in context
- k = number of matching implications

## Design Decisions

1. **Pattern Match Order**: Most specific patterns first to avoid redundant alternatives
2. **Type System**: `Bool` for SearchResult (Prop vs Type issue)
3. **Safe Folding**: Use high initial accumulator (1000) instead of `head!`
4. **Import Order**: Imports MUST be at file beginning (before doc comments)

## Files Modified

- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/ProofSearch.lean`
  - Lines 1-2: Imports
  - Lines 184-207: matches_axiom
  - Lines 224-227: find_implications_to
  - Lines 246-247: box_context
  - Lines 266-267: future_context
  - Lines 307-326: heuristic_score

## Build Commands

```bash
# Build ProofSearch module
lake build Logos.Core.Automation.ProofSearch

# Build entire Automation package
lake build Logos.Core.Automation

# Type check only
lean Logos/Core/Automation/ProofSearch.lean
```

## Next Phase

**Phase 2**: Implement `bounded_search` using these helper functions
- Dependencies: Phase 1 ✓
- Estimated Time: 3-4 hours
- Key Challenge: Depth-limited backtracking search

# Example Code Snippets for Updates

**Date**: 2025-12-25  
**Purpose**: Ready-to-use code snippets for updating example files

---

## ModalProofs.lean Additions

### Section 1: Automated Proof Search (30 lines)

```lean
/-!
## Automated Proof Search

The ProofSearch module provides automated proof discovery using bounded depth-first
search with caching and heuristics.
-/

/-- Basic automated proof search example -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let (found, _, _, _, _) := bounded_search [] goal 3
  found  -- Returns true, automatically proving MT axiom

/-- Automated search with custom depth -/
example : Bool :=
  let goal := (Formula.atom "p").box.box.imp (Formula.atom "p").box
  let (found, _, _, _, _) := bounded_search [] goal 5
  found  -- Returns true, proving nested modal T

/-- Search with visit limit -/
example : Bool :=
  let goal := complex_modal_formula
  let (found, _, _, _, _) := bounded_search [] goal 10 {} {} 0 1000
  found  -- Allows up to 1000 node visits

/-- Demonstrating search failure -/
example : Bool :=
  let invalid_goal := (Formula.atom "p").imp (Formula.atom "p").box
  let (found, _, _, _, _) := bounded_search [] invalid_goal 5
  found  -- Returns false (not provable)
```

### Section 2: Search Performance Analysis (20 lines)

```lean
/-!
## Search Performance Analysis

The SearchStats structure provides metrics for analyzing proof search performance.
-/

/-- Collecting search statistics -/
example : SearchStats :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let (_, _, _, stats, _) := search_with_heuristics [] goal 5
  stats  -- Shows: hits, misses, visited nodes, pruned nodes

/-- Comparing search depths -/
example : Nat × Nat :=
  let goal := (Formula.atom "p").box.box.imp (Formula.atom "p")
  let (_, _, _, stats3, _) := search_with_heuristics [] goal 3
  let (_, _, _, stats5, _) := search_with_heuristics [] goal 5
  (stats3.visited, stats5.visited)  -- Compare node visits

/-- Cache effectiveness demonstration -/
example : Nat × Nat :=
  let goal := complex_formula
  let (_, _, _, stats, _) := search_with_cache {} [] goal 10
  (stats.hits, stats.misses)  -- Shows cache hit/miss ratio
```

### Section 3: Heuristic Strategies (25 lines)

```lean
/-!
## Heuristic Strategies

Custom heuristic weights allow tuning proof search priorities.
-/

/-- Default heuristic weights -/
example : HeuristicWeights :=
  {}  -- axiomWeight=0, assumptionWeight=1, mpBase=2, etc.

/-- Custom weights favoring axioms -/
example : HeuristicWeights :=
  { axiomWeight := 0
  , assumptionWeight := 5
  , mpBase := 10
  , modalBase := 15
  }

/-- Comparing heuristic scores -/
example : Nat × Nat :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let default_score := heuristic_score {} [] goal
  let custom_weights : HeuristicWeights := { mpBase := 1, modalBase := 3 }
  let custom_score := heuristic_score custom_weights [] goal
  (default_score, custom_score)

/-- Search with custom heuristics -/
example : Bool :=
  let weights : HeuristicWeights := { axiomWeight := 0, mpBase := 1 }
  let (found, _, _, _, _) := search_with_heuristics [] goal 5 500 weights
  found
```

### Section 4: Context Transformation (15 lines)

```lean
/-!
## Context Transformation

Helper functions demonstrate modal K rule mechanics.
-/

/-- Modal K context transformation -/
example : Context :=
  let Γ := [Formula.atom "p", Formula.atom "q"]
  box_context Γ  -- Returns [□p, □q]

/-- Finding implications for backward chaining -/
example : List Formula :=
  let Γ := [(Formula.atom "p").imp (Formula.atom "q"), 
            (Formula.atom "r").imp (Formula.atom "q")]
  find_implications_to Γ (Formula.atom "q")  -- Returns [p, r]
```

---

## TemporalProofs.lean Additions

### Section 1: Automated Temporal Search (25 lines)

```lean
/-!
## Automated Temporal Proof Search

Proof search works with temporal operators (G, H, F, P).
-/

/-- Automated temporal proof discovery -/
example : Bool :=
  let goal := (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future
  let (found, _, _, _, _) := bounded_search [] goal 5
  found  -- Returns true, proving T4 axiom automatically

/-- Search with temporal operators -/
example : Bool :=
  let goal := (Formula.atom "p").always.imp (Formula.atom "p").all_past.all_future
  let (found, _, _, _, _) := bounded_search [] goal 7
  found  -- Returns true, proving TL axiom

/-- Complex temporal search -/
example : Bool :=
  let goal := (Formula.atom "p").imp (Formula.atom "p").some_past.all_future
  let (found, _, _, _, _) := bounded_search [] goal 5
  found  -- Returns true, proving TA axiom

/-- Temporal search statistics -/
example : SearchStats :=
  let goal := temporal_formula
  let (_, _, _, stats, _) := search_with_heuristics [] goal 8
  stats
```

### Section 2: Temporal Context Transformation (15 lines)

```lean
/-!
## Temporal Context Transformation

Helper functions demonstrate temporal K rule mechanics.
-/

/-- Temporal K context transformation -/
example : Context :=
  let Γ := [Formula.atom "p", Formula.atom "q"]
  future_context Γ  -- Returns [Gp, Gq]

/-- Temporal context for past operator (via duality) -/
example : Context :=
  let Γ := [Formula.atom "p", Formula.atom "q"]
  let Γ_swap := Γ.map Formula.swap_temporal
  let Γ_future := future_context Γ_swap
  Γ_future.map Formula.swap_temporal  -- Returns [Hp, Hq]
```

---

## BimodalProofs.lean Additions

### Section 1: Automated Bimodal Search (30 lines)

```lean
/-!
## Automated Bimodal Proof Search

Proof search handles combined modal-temporal formulas.
-/

/-- Automated perpetuity principle discovery -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p").always
  let (found, _, _, _, _) := bounded_search [] goal 7
  found  -- Returns true, discovering P1 automatically

/-- P2 automated discovery -/
example : Bool :=
  let goal := (Formula.atom "p").sometimes.imp (Formula.atom "p").diamond
  let (found, _, _, _, _) := bounded_search [] goal 8
  found  -- Returns true, discovering P2

/-- P3 automated discovery -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p").always.box
  let (found, _, _, _, _) := bounded_search [] goal 10
  found  -- Returns true, discovering P3

/-- Complex bimodal search with statistics -/
example : SearchStats :=
  let goal := (Formula.atom "p").sometimes.diamond.imp (Formula.atom "p").diamond.always
  let (_, _, _, stats, _) := search_with_heuristics [] goal 12
  stats  -- P5 search statistics

/-- Bimodal search with custom heuristics -/
example : Bool :=
  let weights : HeuristicWeights := 
    { axiomWeight := 0, modalBase := 3, temporalBase := 4 }
  let goal := (Formula.atom "p").box.sometimes.imp (Formula.atom "p").always.box
  let (found, _, _, _, _) := search_with_heuristics [] goal 12 500 weights
  found  -- P6 with custom search strategy
```

---

## Advanced Examples (Optional)

### Cache Reuse Pattern

```lean
/-- Demonstrating cache reuse across multiple searches -/
example : Nat × Nat :=
  let goal1 := (Formula.atom "p").box.imp (Formula.atom "p")
  let goal2 := (Formula.atom "p").box.box.imp (Formula.atom "p").box
  
  -- First search builds cache
  let (_, cache1, _, stats1, _) := search_with_cache {} [] goal1 5
  
  -- Second search reuses cache
  let (_, cache2, _, stats2, _) := search_with_cache cache1 [] goal2 5
  
  (stats1.misses, stats2.hits)  -- Shows cache effectiveness
```

### Heuristic Comparison

```lean
/-- Comparing different heuristic strategies -/
example : Nat × Nat × Nat :=
  let goal := complex_modal_temporal_formula
  
  -- Strategy 1: Favor axioms
  let w1 : HeuristicWeights := { axiomWeight := 0, mpBase := 10 }
  let (_, _, _, s1, _) := search_with_heuristics [] goal 10 500 w1
  
  -- Strategy 2: Favor modus ponens
  let w2 : HeuristicWeights := { axiomWeight := 10, mpBase := 0 }
  let (_, _, _, s2, _) := search_with_heuristics [] goal 10 500 w2
  
  -- Strategy 3: Balanced
  let w3 : HeuristicWeights := {}
  let (_, _, _, s3, _) := search_with_heuristics [] goal 10 500 w3
  
  (s1.visited, s2.visited, s3.visited)  -- Compare node visits
```

### Performance Benchmarking

```lean
/-- Benchmarking search performance -/
example : List (String × Nat) :=
  let goals := [
    ("MT", (Formula.atom "p").box.imp (Formula.atom "p")),
    ("M4", (Formula.atom "p").box.imp (Formula.atom "p").box.box),
    ("T4", (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future),
    ("P1", (Formula.atom "p").box.imp (Formula.atom "p").always)
  ]
  
  goals.map (fun (name, goal) =>
    let (_, _, _, stats, _) := search_with_heuristics [] goal 10
    (name, stats.visited)
  )
```

---

## Integration Notes

### File Header Updates

Add to each file's header:

```lean
/-!
## New in Recent Updates

This file now includes examples of:
- **Automated Proof Search**: Using `bounded_search` for automatic proof discovery
- **Search Performance**: Analyzing proof search with `SearchStats`
- **Heuristic Strategies**: Customizing search priorities with `HeuristicWeights`
- **Context Transformation**: Understanding modal/temporal K rules

See the respective sections below for demonstrations.
-/
```

### Import Additions

Add to imports if needed:

```lean
import Logos.Core.Automation.ProofSearch  -- For search functions
```

### Compilation Notes

All examples use `Bool` return types since `bounded_search` returns `Bool` (not proof terms). This is intentional - the search functions are for **proof discovery**, not proof construction. To actually construct proofs, use the discovered strategies with manual tactics.

---

## Testing Checklist

Before committing updates:

- [ ] All new examples compile without errors
- [ ] Search examples return expected `true`/`false` values
- [ ] Statistics examples produce reasonable numbers
- [ ] Heuristic examples show different scores
- [ ] Context transformation examples produce correct contexts
- [ ] File headers updated with new feature references
- [ ] No existing examples broken
- [ ] Documentation comments clear and accurate

---

**Code Snippets Prepared**: 2025-12-25  
**Ready for Integration**: ✅  
**Estimated Integration Time**: 2-3 hours

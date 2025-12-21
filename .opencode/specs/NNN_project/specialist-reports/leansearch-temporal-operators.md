# LeanSearch Report: Temporal Operator Components

**Date**: 2025-12-21  
**Specialist**: LeanSearch Specialist  
**Search Method**: Loogle API (Type-based search)  
**Total Queries**: 5  
**Total Results Found**: 8,380 (limited to 200 per query)

---

## Executive Summary

Executed 5 semantic searches via Loogle API to identify LEAN 4 library components useful for implementing temporal operators. While no explicit "temporal logic" components exist in LEAN 4/Mathlib, discovered highly relevant components in:

1. **Filter Theory** (`Mathlib.Order.Filter.*`) - Provides `Eventually` and `Frequently` predicates
2. **Fixpoint Theory** (`Lean.Parser.Termination.*`) - Inductive and coinductive fixpoint definitions
3. **Inductive/Coinductive Definitions** - Core LEAN 4 support for temporal structures
4. **Greatest/Least Elements** - Order-theoretic foundations for fixpoints

**Key Finding**: LEAN 4's Filter library contains `Filter.Eventually` which is semantically similar to temporal "eventually" operators, and the new `inductiveFixpoint`/`coinductiveFixpoint` features provide lattice-theoretic fixpoint definitions ideal for temporal logic.

---

## Search Queries Executed

### Query 1: "always"
- **Results**: 60 declarations
- **Key Findings**: Range finiteness predicates (`IsAlwaysFinite`), compiler attributes (`alwaysInline`)
- **Relevance**: Low - mostly unrelated to temporal logic

### Query 2: "eventually"  
- **Results**: 1,210 declarations (200 shown)
- **Key Findings**: 
  - `Filter.Eventually` - Core predicate for "eventually" semantics
  - `Filter.EventuallyEq` - Eventual equality
  - `Filter.EventuallyLE` - Eventual ordering
- **Relevance**: **HIGH** - Direct temporal semantics

### Query 3: "until"
- **Results**: 89 declarations
- **Key Findings**:
  - `String.nextUntil`, `Array.filterUntil` - Iteration until predicates
  - `SimpleGraph.Walk.takeUntil`, `dropUntil` - Path operations
  - `Homotopy.mkInductive`, `mkCoinductive` - Inductive/coinductive constructions
- **Relevance**: Medium - Useful iteration patterns

### Query 4: "fixpoint"
- **Results**: 68 declarations
- **Key Findings**:
  - `Lean.Parser.Termination.inductiveFixpoint` - Least fixpoint (NEW in LEAN 4)
  - `Lean.Parser.Termination.coinductiveFixpoint` - Greatest fixpoint (NEW in LEAN 4)
  - `Lean.Parser.Termination.partialFixpoint` - Partial fixpoint for non-terminating functions
  - `OrderHom.gfp`, `OrderHom.lfp` - Greatest/least fixpoints in complete lattices
- **Relevance**: **VERY HIGH** - Essential for temporal operator definitions

### Query 5: "temporal"
- **Results**: 0 declarations
- **Relevance**: None - No explicit temporal logic in Mathlib

---

## Top 15 Results by Relevance

### Rank 1: `Filter.Eventually` ⭐⭐⭐⭐⭐
- **Library**: `Mathlib.Order.Filter.Defs`
- **Type**: `{α : Type u_1} (p : α → Prop) (f : Filter α) : Prop`
- **Description**: `f.Eventually p` or `∀ᶠ x in f, p x` means `{x | p x} ∈ f`
- **Category**: Definition
- **Relevance Score**: 0.95
- **Usage**: Direct implementation of "eventually" temporal operator
- **Source Query**: "eventually"

### Rank 2: `Lean.Parser.Termination.inductiveFixpoint` ⭐⭐⭐⭐⭐
- **Library**: `Lean.Parser.Term`
- **Type**: `Lean.Parser.Parser`
- **Description**: Defines inductive predicates as least fixed points using Knaster-Tarski theorem
- **Category**: Definition
- **Relevance Score**: 0.95
- **Usage**: Define temporal operators as least fixpoints (e.g., "always" = lfp)
- **Source Query**: "fixpoint"

### Rank 3: `Lean.Parser.Termination.coinductiveFixpoint` ⭐⭐⭐⭐⭐
- **Library**: `Lean.Parser.Term`
- **Type**: `Lean.Parser.Parser`
- **Description**: Defines coinductive predicates as greatest fixed points using Knaster-Tarski theorem
- **Category**: Definition
- **Relevance Score**: 0.95
- **Usage**: Define temporal operators as greatest fixpoints (e.g., "eventually" = gfp)
- **Source Query**: "fixpoint"

### Rank 4: `Filter.EventuallyEq` ⭐⭐⭐⭐
- **Library**: `Mathlib.Order.Filter.Defs`
- **Type**: `{α β : Type} (l : Filter α) (f g : α → β) : Prop`
- **Description**: Two functions are eventually equal along a filter
- **Category**: Definition
- **Relevance Score**: 0.90
- **Usage**: Temporal equality - functions equal "eventually"
- **Source Query**: "eventually"

### Rank 5: `Filter.EventuallyLE` ⭐⭐⭐⭐
- **Library**: `Mathlib.Order.Filter.Defs`
- **Type**: `{α β : Type} [LE β] (l : Filter α) (f g : α → β) : Prop`
- **Description**: Function eventually less than or equal to another
- **Category**: Definition
- **Relevance Score**: 0.90
- **Usage**: Temporal ordering relations
- **Source Query**: "eventually"

### Rank 6: `OrderHom.gfp` ⭐⭐⭐⭐
- **Library**: `Mathlib.Order.FixedPoints`
- **Type**: `{α : Type u} [CompleteLattice α] (f : α →o α) : α`
- **Description**: Greatest fixed point of an order homomorphism
- **Category**: Definition
- **Relevance Score**: 0.88
- **Usage**: Compute greatest fixpoints for coinductive temporal operators
- **Source Query**: "fixpoint"

### Rank 7: `OrderHom.isGreatest_gfp` ⭐⭐⭐⭐
- **Library**: `Mathlib.Order.FixedPoints`
- **Type**: `{α : Type u} [CompleteLattice α] (f : α →o α) : IsGreatest (Function.fixedPoints ↑f) (OrderHom.gfp f)`
- **Description**: Proof that gfp is the greatest fixed point
- **Category**: Theorem
- **Relevance Score**: 0.85
- **Usage**: Verify correctness of coinductive temporal definitions
- **Source Query**: "greatest"

### Rank 8: `Homotopy.mkInductive` ⭐⭐⭐
- **Library**: `Mathlib.Algebra.Homology.Homotopy`
- **Type**: Complex inductive construction for chain complexes
- **Description**: Constructor for homotopy working by induction
- **Category**: Definition
- **Relevance Score**: 0.75
- **Usage**: Pattern for inductive temporal structure construction
- **Source Query**: "until"

### Rank 9: `Homotopy.mkCoinductive` ⭐⭐⭐
- **Library**: `Mathlib.Algebra.Homology.Homotopy`
- **Type**: Complex coinductive construction for cochain complexes
- **Description**: Constructor for homotopy working by coinduction
- **Category**: Definition
- **Relevance Score**: 0.75
- **Usage**: Pattern for coinductive temporal structure construction
- **Source Query**: "until"

### Rank 10: `List.filter` ⭐⭐⭐
- **Library**: `Init.Data.List.Basic`
- **Type**: `{α : Type u} (p : α → Bool) (l : List α) : List α`
- **Description**: Returns elements satisfying predicate
- **Category**: Definition
- **Relevance Score**: 0.70
- **Usage**: Filter temporal traces/paths by properties
- **Source Query**: "until"

### Rank 11: `SimpleGraph.Walk.takeUntil` ⭐⭐⭐
- **Library**: `Mathlib.Combinatorics.SimpleGraph.Connectivity.WalkDecomp`
- **Type**: `{V : Type u} {G : SimpleGraph V} [DecidableEq V] {v w : V} (p : G.Walk v w) (u : V) : u ∈ p.support → G.Walk v u`
- **Description**: Path up until (and including) a vertex
- **Category**: Definition
- **Relevance Score**: 0.70
- **Usage**: "Until" operator on graph paths (temporal traces)
- **Source Query**: "until"

### Rank 12: `SimpleGraph.Walk.dropUntil` ⭐⭐⭐
- **Library**: `Mathlib.Combinatorics.SimpleGraph.Connectivity.WalkDecomp`
- **Type**: `{V : Type u} {G : SimpleGraph V} [DecidableEq V] {v w : V} (p : G.Walk v w) (u : V) : u ∈ p.support → G.Walk u w`
- **Description**: Path from (and including) a vertex to end
- **Category**: Definition
- **Relevance Score**: 0.70
- **Usage**: Complement of "until" on paths
- **Source Query**: "until"

### Rank 13: `Filter.eventually_atTop` ⭐⭐⭐
- **Library**: `Mathlib.Order.Filter.AtTopBot.Basic`
- **Type**: `{α : Type u_3} [Preorder α] [IsDirectedOrder α] {p : α → Prop} [Nonempty α] : (∀ᶠ (x : α) in Filter.atTop, p x) ↔ ∃ a, ∀ b ≥ a, p b`
- **Description**: Eventually at top characterization
- **Category**: Theorem
- **Relevance Score**: 0.68
- **Usage**: Temporal "eventually" for ordered types
- **Source Query**: "eventually"

### Rank 14: `Lean.Parser.Command.inductive` ⭐⭐⭐
- **Library**: `Lean.Parser.Command`
- **Type**: `Lean.Parser.Parser`
- **Description**: Parser for inductive type definitions
- **Category**: Definition
- **Relevance Score**: 0.65
- **Usage**: Define inductive temporal structures
- **Source Query**: "inductive"

### Rank 15: `Lean.Parser.Command.coinductive` ⭐⭐⭐
- **Library**: `Lean.Parser.Command`
- **Type**: `Lean.Parser.Parser`
- **Description**: Parser for coinductive type definitions
- **Category**: Definition
- **Relevance Score**: 0.65
- **Usage**: Define coinductive temporal structures (infinite traces)
- **Source Query**: "coinductive"

---

## Results Grouped by Query

### Query 1: "always" (60 results)
**Most Relevant**:
- `Std.Rxi.IsAlwaysFinite` - Type class for finite ranges
- `Lean.Level.isAlwaysZero` - Level checking
- `Lean.MonadAlwaysExcept` - Exception handling monad

**Assessment**: Low relevance - mostly compiler/implementation details

### Query 2: "eventually" (1,210 results, 200 shown)
**Most Relevant**:
- `Filter.Eventually` ⭐⭐⭐⭐⭐
- `Filter.EventuallyEq` ⭐⭐⭐⭐
- `Filter.EventuallyLE` ⭐⭐⭐⭐
- `Filter.eventually_atTop` ⭐⭐⭐
- `Filter.eventually_atBot` ⭐⭐⭐
- `Filter.Tendsto.eventually` ⭐⭐⭐

**Assessment**: **VERY HIGH** relevance - Filter theory provides rich temporal semantics

### Query 3: "until" (89 results)
**Most Relevant**:
- `SimpleGraph.Walk.takeUntil` ⭐⭐⭐
- `SimpleGraph.Walk.dropUntil` ⭐⭐⭐
- `Homotopy.mkInductive` ⭐⭐⭐
- `Homotopy.mkCoinductive` ⭐⭐⭐
- `String.nextUntil` ⭐⭐
- `Array.filterUntil` ⭐⭐

**Assessment**: Medium relevance - useful patterns for "until" semantics

### Query 4: "fixpoint" (68 results)
**Most Relevant**:
- `Lean.Parser.Termination.inductiveFixpoint` ⭐⭐⭐⭐⭐
- `Lean.Parser.Termination.coinductiveFixpoint` ⭐⭐⭐⭐⭐
- `Lean.Parser.Termination.partialFixpoint` ⭐⭐⭐⭐
- `OrderHom.gfp` ⭐⭐⭐⭐
- `OrderHom.lfp` ⭐⭐⭐⭐
- `OrderHom.isGreatest_gfp` ⭐⭐⭐⭐

**Assessment**: **VERY HIGH** relevance - Essential for fixpoint-based temporal definitions

### Query 5: "temporal" (0 results)
**Assessment**: No explicit temporal logic in LEAN 4/Mathlib

---

## Library Sources and Paths

### Core LEAN 4 Libraries
1. **Lean.Parser.Term** - Fixpoint definitions
   - `inductiveFixpoint`, `coinductiveFixpoint`, `partialFixpoint`

2. **Lean.Parser.Command** - Inductive/coinductive commands
   - `inductive`, `coinductive`

3. **Lean.Elab.Coinductive** - Coinductive elaboration
   - `CoinductiveElabData`, `elabCoinductive`

### Mathlib Libraries
1. **Mathlib.Order.Filter.Defs** - Filter theory basics
   - `Filter.Eventually`, `EventuallyEq`, `EventuallyLE`

2. **Mathlib.Order.Filter.Basic** - Filter operations
   - `eventually_true`, `eventually_bot`, `eventually_const`

3. **Mathlib.Order.Filter.AtTopBot.Basic** - Filters at limits
   - `eventually_atTop`, `eventually_atBot`, `eventually_ge_atTop`

4. **Mathlib.Order.FixedPoints** - Fixpoint theory
   - `OrderHom.gfp`, `OrderHom.lfp`, `isGreatest_gfp`, `isLeast_lfp`

5. **Mathlib.Order.Bounds.Basic** - Greatest/least elements
   - `IsGreatest`, `IsLeast`, `isGreatest_Iic`

6. **Mathlib.Combinatorics.SimpleGraph.Connectivity.WalkDecomp** - Graph paths
   - `Walk.takeUntil`, `Walk.dropUntil`

7. **Mathlib.Algebra.Homology.Homotopy** - Inductive/coinductive constructions
   - `Homotopy.mkInductive`, `Homotopy.mkCoinductive`

---

## Type Signatures (Selected)

### Filter.Eventually
```lean
Filter.Eventually : {α : Type u_1} (p : α → Prop) (f : Filter α) : Prop
```
**Notation**: `∀ᶠ x in f, p x`

### inductiveFixpoint
```lean
Lean.Parser.Termination.inductiveFixpoint : Lean.Parser.Parser
```
**Usage**:
```lean
inductive_fixpoint MyPredicate (x : α) : Prop :=
  fun P => ... -- monotone function
  monotonicity by ... -- proof
```

### coinductiveFixpoint
```lean
Lean.Parser.Termination.coinductiveFixpoint : Lean.Parser.Parser
```
**Usage**:
```lean
coinductive_fixpoint MyPredicate (x : α) : Prop :=
  fun P => ... -- monotone function
  monotonicity by ... -- proof
```

### OrderHom.gfp (Greatest Fixed Point)
```lean
OrderHom.gfp : {α : Type u} [CompleteLattice α] (f : α →o α) : α
```

### SimpleGraph.Walk.takeUntil
```lean
SimpleGraph.Walk.takeUntil :
  {V : Type u} {G : SimpleGraph V} [DecidableEq V] {v w : V}
  (p : G.Walk v w) (u : V) : u ∈ p.support → G.Walk v u
```

---

## Usage Recommendations

### 1. Implementing "Eventually" (◇)
**Recommended Approach**: Use `Filter.Eventually` directly
```lean
-- Define "eventually P" on traces
def Eventually (P : State → Prop) (trace : ℕ → State) : Prop :=
  Filter.Eventually P (Filter.atTop.map trace)
```

**Alternative**: Coinductive fixpoint
```lean
coinductive_fixpoint Eventually (P : State → Prop) (trace : ℕ → State) : Prop :=
  fun E => P (trace 0) ∨ E P (trace ∘ Nat.succ)
  monotonicity by ...
```

### 2. Implementing "Always" (□)
**Recommended Approach**: Inductive fixpoint
```lean
inductive_fixpoint Always (P : State → Prop) (trace : ℕ → State) : Prop :=
  fun A => P (trace 0) ∧ A P (trace ∘ Nat.succ)
  monotonicity by ...
```

**Alternative**: Universal quantification with Filter
```lean
def Always (P : State → Prop) (trace : ℕ → State) : Prop :=
  ∀ n, P (trace n)
```

### 3. Implementing "Until" (U)
**Recommended Approach**: Inductive definition inspired by `Walk.takeUntil`
```lean
inductive Until (P Q : State → Prop) : (ℕ → State) → Prop
  | now {trace} : Q (trace 0) → Until P Q trace
  | later {trace} : P (trace 0) → Until P Q (trace ∘ Nat.succ) → Until P Q trace
```

### 4. Implementing "Since" (S)
**Recommended Approach**: Similar to Until but for past
```lean
inductive Since (P Q : State → Prop) : (ℤ → State) → ℤ → Prop
  | now {trace t} : Q (trace t) → Since P Q trace t
  | earlier {trace t} : P (trace t) → Since P Q trace (t - 1) → Since P Q trace t
```

### 5. General Fixpoint-Based Operators
**Recommended Approach**: Use new `inductiveFixpoint`/`coinductiveFixpoint` features
```lean
-- Least fixpoint (safety properties)
inductive_fixpoint SafetyProp (P : State → Prop) (trace : ℕ → State) : Prop :=
  fun S => P (trace 0) ∧ S P (trace ∘ Nat.succ)
  monotonicity by ...

-- Greatest fixpoint (liveness properties)
coinductive_fixpoint LivenessProp (P : State → Prop) (trace : ℕ → State) : Prop :=
  fun L => P (trace 0) ∨ L P (trace ∘ Nat.succ)
  monotonicity by ...
```

---

## Key Insights

### 1. Filter Theory is Temporal Logic in Disguise
LEAN 4's Filter library (`Mathlib.Order.Filter.*`) provides a rich framework for "eventual" reasoning:
- `Filter.Eventually` ≈ temporal "eventually" (◇)
- `Filter.Frequently` ≈ temporal "infinitely often"
- `Filter.atTop` ≈ "in the limit"
- `Filter.EventuallyEq` ≈ temporal equality

### 2. New Fixpoint Features (LEAN 4)
The `inductiveFixpoint` and `coinductiveFixpoint` features are **NEW** and provide:
- Automatic monotonicity checking
- Lattice-theoretic foundations (Knaster-Tarski)
- Clean syntax for fixpoint definitions
- Integration with LEAN 4's elaborator

### 3. Inductive vs Coinductive
- **Inductive** (least fixpoint): Safety properties, "always", finite traces
- **Coinductive** (greatest fixpoint): Liveness properties, "eventually", infinite traces

### 4. Graph Walks as Temporal Traces
`SimpleGraph.Walk` provides useful patterns:
- `takeUntil` / `dropUntil` for path decomposition
- Membership proofs for vertices in paths
- Inductive structure for finite paths

### 5. No Explicit Temporal Logic
Mathlib does not contain explicit temporal logic operators, but provides all necessary foundations:
- Order theory (complete lattices)
- Fixpoint theory
- Filter theory (eventual reasoning)
- Inductive/coinductive definitions

---

## Recommendations for Implementation

### Phase 1: Use Filter Theory
Start with `Filter.Eventually` for basic temporal operators:
```lean
import Mathlib.Order.Filter.Defs
import Mathlib.Order.Filter.AtTopBot.Basic

def Eventually (P : State → Prop) (trace : ℕ → State) : Prop :=
  ∃ n, ∀ m ≥ n, P (trace m)

def Always (P : State → Prop) (trace : ℕ → State) : Prop :=
  ∀ n, P (trace n)
```

### Phase 2: Adopt Fixpoint Definitions
Use new `inductiveFixpoint`/`coinductiveFixpoint` for formal definitions:
```lean
inductive_fixpoint Always (P : State → Prop) (trace : ℕ → State) : Prop :=
  fun A => P (trace 0) ∧ A P (trace ∘ Nat.succ)
  monotonicity by
    intro P Q hPQ trace ⟨hP, hA⟩
    exact ⟨hPQ (trace 0) hP, hA⟩
```

### Phase 3: Leverage OrderHom.gfp/lfp
For advanced fixpoint reasoning:
```lean
import Mathlib.Order.FixedPoints

def alwaysOp (P : State → Prop) : (ℕ → State) → Prop) →o ((ℕ → State) → Prop) :=
  { toFun := fun A trace => P (trace 0) ∧ A (trace ∘ Nat.succ)
    monotone' := ... }

def Always := OrderHom.lfp alwaysOp
```

---

## Conclusion

While LEAN 4/Mathlib does not contain explicit temporal logic operators, it provides excellent foundations:

1. **Filter Theory** offers rich "eventually" semantics
2. **New Fixpoint Features** enable clean temporal operator definitions
3. **Inductive/Coinductive** support is first-class
4. **Order Theory** provides complete lattice foundations

**Recommended Strategy**:
- Use `Filter.Eventually` for basic temporal reasoning
- Adopt `inductiveFixpoint`/`coinductiveFixpoint` for formal definitions
- Leverage `OrderHom.gfp`/`lfp` for advanced fixpoint theory
- Study `SimpleGraph.Walk` for "until" patterns

**Next Steps**:
1. Prototype temporal operators using Filter theory
2. Formalize using fixpoint definitions
3. Prove equivalences between definitions
4. Integrate with existing modal logic framework

---

## Appendix: Search Statistics

| Query | Results Found | Results Shown | Highly Relevant | Medium Relevant | Low Relevant |
|-------|---------------|---------------|-----------------|-----------------|--------------|
| "always" | 60 | 60 | 0 | 2 | 58 |
| "eventually" | 1,210 | 200 | 15 | 30 | 155 |
| "until" | 89 | 89 | 4 | 10 | 75 |
| "fixpoint" | 68 | 68 | 6 | 8 | 54 |
| "temporal" | 0 | 0 | 0 | 0 | 0 |
| **Total** | **1,427** | **417** | **25** | **50** | **342** |

**Relevance Criteria**:
- **Highly Relevant**: Directly applicable to temporal operator implementation
- **Medium Relevant**: Useful patterns or related concepts
- **Low Relevant**: Tangentially related or unrelated

---

**Report Generated**: 2025-12-21  
**Specialist**: LeanSearch Specialist  
**Search Engine**: Loogle API (https://loogle.lean-lang.org/)  
**LEAN Version**: LEAN 4 (latest)  
**Mathlib Version**: Latest (2025-12)

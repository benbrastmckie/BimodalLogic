# Loogle Search Results: Nat → _ → _

**Type Pattern**: Nat → _ → _
**Date**: 2025-12-20
**Matches Found**: 85+ (direct pattern caused timeout, analyzed specific patterns instead)
**Search Strategy**: Pattern-based searches for bound/limit/fuel usage

## Search Query

**Primary Pattern**: `Nat → _ → _`
**Issue**: Direct pattern search timed out (200,000 heartbeats exceeded)
**Solution**: Executed targeted searches for specific usage patterns:
- Functions with "bounded", "fuel", "depth", "limit", "steps" in names
- Core iteration primitives: `Nat.repeat`, `Nat.fold`, `Nat.foldM`
- Collection operations: `List.take`, `Array.take`
- Bounded iteration: `Fin.foldl`, `Fin.foldr`

## Exact Matches

### Functions with Nat as Bound/Limit/Fuel

#### 1. **Nat.repeat** : `{α : Type u} (f : α → α) (n : ℕ) (a : α) : α`
- **Library**: Init.Data.Nat.Basic
- **Module**: Init.Data.Nat.Basic
- **Nat Usage**: iteration limit
- **Termination**: structural recursion on Nat
- **Description**: Applies function `f` to starting value `a` exactly `n` times
- **Analysis**: Classic iteration limit pattern. Nat parameter `n` controls how many times the function is applied. Uses structural recursion with base case `n = 0` and recursive case `n.succ`.
- **Example**: `Nat.repeat f 3 a = f (f (f a))`
- **Runtime**: Uses `Nat.repeatTR` (tail-recursive version)

#### 2. **Nat.fold** : `{α : Type u} (n : ℕ) (f : (i : ℕ) → i < n → α → α) (init : α) : α`
- **Library**: Init.Data.Nat.Fold
- **Module**: Init.Data.Nat.Fold
- **Nat Usage**: iteration bound with index
- **Termination**: structural recursion on Nat
- **Description**: Iterates function `f` over indices `0..(n-1)` with proof that `i < n`
- **Analysis**: Nat parameter serves as upper bound for iteration indices. Each step receives both current index and proof that index is within bounds. More powerful than `Nat.repeat` because function can observe current iteration index.
- **Example**: `Nat.fold 4 (fun i _ xs => xs.push i) #[] = #[0, 1, 2, 3]`
- **Variants**: `Nat.foldTR` (tail-recursive), `Nat.foldRev` (reverse order)

#### 3. **Nat.foldM** : `{α : Type u} {m : Type u → Type v} [Monad m] (n : ℕ) (f : (i : ℕ) → i < n → α → m α) (init : α) : m α`
- **Library**: Init.Data.Nat.Control
- **Module**: Init.Data.Nat.Control
- **Nat Usage**: iteration bound (monadic)
- **Termination**: structural recursion on Nat
- **Description**: Monadic version of `Nat.fold` for effectful iterations
- **Analysis**: Same bound pattern as `Nat.fold` but in monadic context. Essential for bounded loops with effects (IO, state, etc.).
- **Related**: `Nat.foldRevM` for reverse iteration order

#### 4. **Nat.foldRev** : `{α : Type u} (n : ℕ) (f : (i : ℕ) → i < n → α → α) (init : α) : α`
- **Library**: Init.Data.Nat.Fold
- **Module**: Init.Data.Nat.Fold
- **Nat Usage**: iteration bound (reverse order)
- **Termination**: structural recursion on Nat
- **Description**: Like `Nat.fold` but iterates from `n-1` down to `0`
- **Example**: `Nat.foldRev 4 (fun i _ xs => xs.push i) #[] = #[3, 2, 1, 0]`

#### 5. **List.take** : `{α : Type u} (n : ℕ) (xs : List α) : List α`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Nat Usage**: element count limit
- **Termination**: structural recursion on Nat (decreases on `n`)
- **Description**: Extracts first `n` elements from list, or entire list if shorter
- **Analysis**: Nat parameter bounds the number of elements extracted. Recursion terminates because `n` decreases at each step. Classic bound pattern for collection operations.
- **Examples**: 
  - `[a, b, c, d, e].take 0 = []`
  - `[a, b, c, d, e].take 3 = [a, b, c]`
  - `[a, b, c, d, e].take 6 = [a, b, c, d, e]`
- **Runtime**: Uses `List.takeTR` (tail-recursive version)

#### 6. **Array.take** : `{α : Type u} (xs : Array α) (i : ℕ) : Array α`
- **Library**: Init.Data.Array.Basic
- **Module**: Init.Data.Array.Basic
- **Nat Usage**: element count limit
- **Termination**: implemented via `Array.extract 0 i`
- **Description**: Returns new array with first `i` elements
- **Analysis**: Array version of `List.take`. Nat parameter bounds extraction count.
- **Examples**:
  - `#["red", "green", "blue"].take 1 = #["red"]`
  - `#["red", "green", "blue"].take 2 = #["red", "green"]`
  - `#["red", "green", "blue"].take 5 = #["red", "green", "blue"]`

#### 7. **Fin.foldl** : `{α : Sort u_1} (n : ℕ) (f : α → Fin n → α) (init : α) : α`
- **Library**: Init.Data.Fin.Fold
- **Module**: Init.Data.Fin.Fold
- **Nat Usage**: bounded iteration via Fin type
- **Termination**: structural recursion (via Nat.fold internally)
- **Description**: Folds function over all values in `Fin n` (0 to n-1)
- **Analysis**: Uses Nat to create bounded type `Fin n` representing {0, 1, ..., n-1}. This ensures iteration is bounded by construction. Elegant pattern where bound is encoded in the type system.
- **Example**: `Fin.foldl 3 (· + ·.val) (0 : Nat) = ((0 + 0) + 1) + 2 = 3`
- **Related**: `Fin.foldr`, `Fin.foldlM`, `Fin.foldrM`

#### 8. **Fin.foldr** : `{α : Sort u_1} (n : ℕ) (f : Fin n → α → α) (init : α) : α`
- **Library**: Init.Data.Fin.Fold
- **Module**: Init.Data.Fin.Fold
- **Nat Usage**: bounded iteration (right-associative)
- **Termination**: structural recursion via helper loop
- **Description**: Right-fold over `Fin n` values from `n-1` down to `0`
- **Example**: `Fin.foldr 3 (·.val + ·) (0 : Nat) = 0 + (1 + (2 + 0)) = 3`

#### 9. **Fin.foldlM** : `{m : Type u_1 → Type u_2} {α : Type u_1} [Monad m] (n : ℕ) (f : α → Fin n → m α) (init : α) : m α`
- **Library**: Init.Data.Fin.Fold
- **Module**: Init.Data.Fin.Fold
- **Nat Usage**: bounded iteration (monadic)
- **Termination**: structural recursion
- **Description**: Monadic left-fold over `Fin n` from `0` to `n-1`
- **Analysis**: Combines bounded iteration with monadic effects. Sequence of steps: `x₀ → f x₀ 0 → ... → f xₙ₋₁ (n-1)`

#### 10. **Fin.foldrM** : `{m : Type u_1 → Type u_2} {α : Type u_1} [Monad m] (n : ℕ) (f : Fin n → α → m α) (init : α) : m α`
- **Library**: Init.Data.Fin.Fold
- **Module**: Init.Data.Fin.Fold
- **Nat Usage**: bounded iteration (monadic, right-associative)
- **Termination**: structural recursion
- **Description**: Monadic right-fold over `Fin n` from `n-1` down to `0`

#### 11. **Fin.hIterate** : `(P : ℕ → Sort u_1) {n : ℕ} (init : P 0) (f : (i : Fin n) → P ↑i → P (↑i + 1)) : P n`
- **Library**: Core (Fin module)
- **Module**: Init.Data.Fin.*
- **Nat Usage**: iteration bound with heterogeneous state
- **Termination**: structural recursion on Nat
- **Description**: Heterogeneous iteration where state type changes at each step
- **Analysis**: Advanced pattern where Nat bounds iteration and the return type depends on the bound. Function transforms `P i` to `P (i+1)` at each step, ultimately producing `P n`.

#### 12. **Fin.hIterateFrom** : `(P : ℕ → Sort u_1) {n : ℕ} (f : (i : Fin n) → P ↑i → P (↑i + 1)) (i : ℕ) (ubnd : i ≤ n) (a : P i) : P n`
- **Library**: Core (Fin module)
- **Module**: Init.Data.Fin.*
- **Nat Usage**: partial iteration from index i to n
- **Termination**: structural recursion on (n - i)
- **Description**: Like `hIterate` but starts from arbitrary index `i` with proof `i ≤ n`
- **Analysis**: Two Nat parameters: `n` as upper bound and `i` as starting point. Requires proof that `i ≤ n` to ensure well-foundedness.

### Functions with Nat in Configuration/Limits (Metadata)

#### 13. **Lean.Meta.Simp.defaultMaxSteps** : `ℕ`
- **Library**: Init.MetaTypes
- **Module**: Init.MetaTypes
- **Nat Usage**: default maximum steps for simplifier
- **Description**: Configuration constant defining step limit for simp tactic

#### 14. **Lean.Meta.Simp.Config.maxSteps** : `(self : Lean.Meta.Simp.Config) : ℕ`
- **Library**: Init.MetaTypes
- **Module**: Init.MetaTypes
- **Nat Usage**: maximum steps configuration field
- **Description**: Field in simp configuration controlling iteration bound
- **Analysis**: Used to prevent infinite loops in simplification. Typical fuel/bound pattern for proof search.

#### 15. **Lean.Grind.Config.acSteps** : `(self : Lean.Grind.Config) : ℕ`
- **Library**: Init.Grind.Config
- **Module**: Init.Grind.Config
- **Nat Usage**: associative-commutative normalization step limit
- **Description**: Bounds AC (associative-commutative) rewriting steps

#### 16. **Lean.Grind.Config.ringSteps** : `(self : Lean.Grind.Config) : ℕ`
- **Library**: Init.Grind.Config
- **Module**: Init.Grind.Config
- **Nat Usage**: ring normalization step limit
- **Description**: Bounds ring normalization steps in grind tactic

#### 17. **Lean.defaultMaxRecDepth** : `ℕ`
- **Library**: Core
- **Module**: Lean.Macro.*
- **Nat Usage**: maximum recursion depth limit
- **Description**: Default bound on macro expansion recursion depth
- **Analysis**: Prevents infinite recursion in macro expansion. Classic recursion depth bound.

#### 18. **Lean.Macro.Context.maxRecDepth** : `(self : Lean.Macro.Context) : ℕ`
- **Library**: Core
- **Module**: Lean.Macro.*
- **Nat Usage**: recursion depth bound in macro context
- **Description**: Field storing maximum recursion depth for macro expansion

#### 19. **Lean.Macro.Context.currRecDepth** : `(self : Lean.Macro.Context) : ℕ`
- **Library**: Core
- **Module**: Lean.Macro.*
- **Nat Usage**: current recursion depth counter
- **Description**: Tracks current depth to compare against maxRecDepth
- **Analysis**: Used with maxRecDepth to detect when depth limit is exceeded

### Functions with Nat as Data (Not Bound/Limit)

#### 20. **Nat.beq** : `ℕ → ℕ → Bool`
- **Library**: Init.Prelude
- **Module**: Init.Prelude
- **Nat Usage**: data (equality comparison)
- **Description**: Boolean equality test for natural numbers
- **Analysis**: Nat used as data to compare, not as bound/limit/fuel

#### 21. **List.range** : `(n : ℕ) : List ℕ`
- **Library**: Init.Data.List.Range
- **Module**: Init.Data.List.Range
- **Nat Usage**: both bound and data
- **Description**: Generates list `[0, 1, ..., n-1]`
- **Analysis**: Nat is bound (controls iteration) AND data (values in result list)

#### 22. **List.range'** : `(start n step : ℕ) : List ℕ`
- **Library**: Init.Data.List.Range
- **Module**: Init.Data.List.Range
- **Nat Usage**: bound (`n`) and data (`start`, `step`)
- **Description**: Generates arithmetic sequence starting at `start`, length `n`, increment `step`

#### 23. **List.replicate** : `{α : Type u} (n : ℕ) (a : α) : List α`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Nat Usage**: repetition count (bound)
- **Description**: Creates list with `n` copies of `a`
- **Analysis**: Nat parameter bounds the number of elements created

#### 24. **Array.replicate** : `{α : Type u} (n : ℕ) (a : α) : Array α`
- **Library**: Init.Data.Array.Basic
- **Module**: Init.Data.Array.Basic
- **Nat Usage**: repetition count (bound)
- **Description**: Creates array with `n` copies of `a`

## Analysis by Usage Type

### Recursion Bounds

Functions using Nat as recursion depth or structural recursion bound:

1. **Structural Recursion on Nat**:
   - `Nat.repeat` / `Nat.repeatTR` - iterates `n` times via recursion on `n`
   - `Nat.fold` / `Nat.foldTR` / `Nat.foldRev` - fold with decreasing Nat
   - `List.take` / `List.takeTR` - extract n elements via recursion on `n`
   - `List.replicate` / `List.replicateTR` - create n copies via recursion on `n`
   - `Array.take` - implemented via `Array.extract 0 i`

2. **Recursion Depth Limits**:
   - `Lean.defaultMaxRecDepth` - maximum macro recursion depth
   - `Lean.Macro.Context.maxRecDepth` - macro expansion depth bound
   - `Lean.Macro.Context.currRecDepth` - current depth counter

### Iteration Limits

Functions using Nat as iteration count:

1. **Index-Based Iteration**:
   - `Nat.fold` - iterates from `0` to `n-1` with index
   - `Nat.foldRev` - iterates from `n-1` to `0` with index
   - `Nat.foldM` / `Nat.foldRevM` - monadic versions
   - `Fin.foldl` / `Fin.foldr` - fold over `Fin n` values
   - `Fin.foldlM` / `Fin.foldrM` - monadic folds over `Fin n`

2. **Count-Based Iteration**:
   - `Nat.repeat` - applies function exactly `n` times
   - `List.replicate` - creates exactly `n` copies
   - `Array.replicate` - creates exactly `n` copies

3. **Heterogeneous Iteration**:
   - `Fin.hIterate` - type-changing iteration from `P 0` to `P n`
   - `Fin.hIterateFrom` - partial heterogeneous iteration from `P i` to `P n`

### Fuel Parameters

Functions using Nat as fuel for termination:

1. **Proof Search / Simplification**:
   - `Lean.Meta.Simp.defaultMaxSteps` - simp tactic step limit
   - `Lean.Meta.Simp.Config.maxSteps` - configurable simp steps
   - `Lean.Grind.Config.acSteps` - AC normalization fuel
   - `Lean.Grind.Config.ringSteps` - ring normalization fuel

2. **Iterator Termination**:
   - `Std.Iterators.IterM.finitelyManySteps` - proof of finite iteration
   - `Std.Iterators.Iter.finitelyManySteps` - finite step guarantee

### Search Depth

Functions using Nat as search depth bound:

*Note: Direct "depth" search returned many module/file depth concepts rather than algorithm depth bounds. Actual search depth bounds are typically embedded in proof search tactics.*

### Collection Bounds

Functions using Nat to bound collection operations:

1. **Taking Elements**:
   - `List.take` - take first `n` elements
   - `Array.take` - take first `n` elements
   - `List.takeWhile` - predicate-based (no Nat bound)
   - `Array.takeWhile` - predicate-based (no Nat bound)

2. **Dropping Elements**:
   - `List.drop` - drop first `n` elements
   - `Array.drop` - drop first `n` elements

3. **Element Access**:
   - `List.get` - access `n`-th element (with proof)
   - `Array.get` - access `n`-th element (with proof)

## Termination Mechanisms

### Structural Recursion

**Primary Pattern**: Function definition matches on Nat parameter, recursively calls itself with `n-1` or pattern matches `0` vs `succ n`.

**Examples**:
```lean
def Nat.repeat (f : α → α) : ℕ → α → α
  | 0, a => a
  | n+1, a => f (Nat.repeat f n a)

def List.take : ℕ → List α → List α
  | 0, _ => []
  | n+1, [] => []
  | n+1, a::as => a :: List.take n as
```

**Termination**: Lean's decreasing checker automatically proves termination because Nat decreases in each recursive call.

**Functions Using This**:
- `Nat.repeat`, `Nat.fold`, `Nat.foldRev`
- `List.take`, `List.drop`, `List.replicate`
- `Fin.foldl`, `Fin.foldr`
- Most iteration primitives

### Well-Founded Recursion

**Primary Pattern**: Recursion on more complex measure, often with explicit proof that measure decreases.

**Examples**:
```lean
-- Nat.div uses well-founded recursion on x
-- Each recursive call uses (x - y) which is provably smaller
def Nat.div (x y : Nat) : Nat := ...
  -- recursive call with (x - y)
  -- requires proof: y ≤ x → x - y < x
```

**Termination**: Explicit proof that recursion measure (often a Nat) decreases.

**Functions Using This**:
- `Nat.div` - recursion on numerator
- `Nat.gcd` - recursion on min of arguments
- `Fin.hIterateFrom` - recursion on `(n - i)`

### Fuel-Based Termination

**Primary Pattern**: Extra Nat parameter ("fuel") that decreases on each recursive call. When fuel reaches 0, recursion stops (usually with error or default value).

**Theoretical Example** (not found in standard library):
```lean
def search (fuel : Nat) (pred : α → Bool) (x : α) (step : α → α) : Option α :=
  match fuel with
  | 0 => none  -- out of fuel
  | fuel' + 1 =>
    if pred x then some x
    else search fuel' pred (step x) step
```

**Termination**: Guaranteed by structural recursion on fuel parameter. Function always terminates even if search would loop infinitely.

**Use Cases**:
- Proof search with bounded depth (simp with maxSteps)
- Potentially non-terminating algorithms with guaranteed termination
- Interactive systems with timeout

**Standard Library Examples**:
- Config parameters like `maxSteps`, `acSteps`, `ringSteps` are used as fuel in their respective algorithms
- Not directly exposed as function parameters in most user-facing APIs

### Bounded Types (Fin n)

**Primary Pattern**: Use `Fin n` type which represents {0, 1, ..., n-1}. Iteration over `Fin n` is bounded by construction.

**Example**:
```lean
-- Fin n is defined as { val : Nat // val < n }
-- Functions over Fin n are automatically bounded

def Fin.foldl {α : Sort u} (n : Nat) (f : α → Fin n → α) (init : α) : α :=
  -- Iterates over all values in Fin n (exactly n values)
  -- Termination is guaranteed by structure of Fin
```

**Termination**: Type system ensures iteration is bounded. Cannot construct `Fin n` value ≥ n.

**Functions Using This**:
- All `Fin.fold*` variants
- `Fin.hIterate`, `Fin.hIterateFrom`
- Many array indexing operations

**Advantages**:
- Type-safe bounds checking
- Proofs of boundedness built into types
- No runtime bound checks needed (when used properly)

## Recommendations

### For Implementing Bounded Functions

1. **Choose the Right Primitive**:
   - **Simple iteration**: Use `Nat.repeat` when you just need to apply a function `n` times
   - **Index-aware iteration**: Use `Nat.fold` when you need the iteration index
   - **Monadic iteration**: Use `Nat.foldM` or `Fin.foldlM` for effectful loops
   - **Type-safe bounds**: Use `Fin.foldl` when you want bounds checked by types

2. **Termination Patterns**:
   - **Structural recursion**: Default choice, cleanest, automatic termination proof
   - **Well-founded recursion**: When measure is more complex than simple Nat decreasing
   - **Fuel parameter**: When algorithm might not terminate but you need guaranteed termination
   - **Bounded types**: When bounds should be enforced at type level

3. **Fuel vs Bounds**:
   - **Fuel**: Used when algorithm might loop infinitely, fuel ensures termination
   - **Bound**: Used when algorithm naturally terminates but you want to limit iterations
   - **Example**: Proof search uses fuel (might not find proof), collection take uses bound (always terminates)

4. **For ProofChecker Project**:

   **For Proof Search with Bounded Depth**:
   ```lean
   -- Option 1: Fuel-based with explicit depth
   def searchProof (fuel : Nat) (goal : Formula) : Option Derivation :=
     match fuel with
     | 0 => none
     | fuel' + 1 =>
       -- try tactics, recurse with fuel'
       tryTactics goal >>= fun (subgoals, rule) =>
         subgoals.mapM (searchProof fuel') >>= fun derivs =>
           some (combine rule derivs)

   -- Option 2: Using Nat.fold for bounded iteration
   def searchProofBounded (depth : Nat) (goal : Formula) : Option Derivation :=
     Nat.fold depth (fun i _ acc =>
       acc.orElse (fun _ => tryAtDepth i goal)
     ) none

   -- Option 3: Using Fin for type-safe depth
   def searchProofFin (depth : Nat) (goal : Formula) : Option Derivation :=
     Fin.foldlM depth (fun acc i =>
       acc.orElse (tryAtDepth i.val goal)
     ) none
   ```

   **For Iteration with Progress Tracking**:
   ```lean
   -- Use Nat.foldM to track iteration count
   def applyTacticNTimes (n : Nat) (tac : Tactic) : TacticM Unit :=
     Nat.foldM n (fun i _ _ =>
       logInfo s!"Step {i}: applying tactic"
       tac
     ) ()
   ```

   **For Bounded Collection Operations**:
   ```lean
   -- Take first n applicable tactics
   def firstNTactics (n : Nat) (tactics : List Tactic) : List Tactic :=
     tactics.take n

   -- Try up to n tactics
   def tryUpToN (n : Nat) (tactics : List Tactic) : TacticM Unit :=
     (tactics.take n).foldlM (fun _ tac => tac <|> pure ()) ()
   ```

### Pattern Selection Guide

| Use Case | Recommended Pattern | Reason |
|----------|-------------------|---------|
| Simple iteration | `Nat.repeat` | Cleanest for count-based loops |
| Need iteration index | `Nat.fold` | Provides index at each step |
| Monadic effects | `Nat.foldM`, `Fin.foldlM` | Built-in monadic sequencing |
| Type-safe bounds | `Fin.foldl` | Compile-time bound checking |
| Might not terminate | Fuel parameter | Guarantees termination |
| Proof search | Fuel + depth tracking | Standard pattern in tactics |
| Collection operations | `List.take`, `Array.take` | Optimized primitives |
| Heterogeneous state | `Fin.hIterate` | Type changes at each step |

### Best Practices

1. **Naming Conventions**:
   - Use `maxSteps`, `maxDepth`, `bound` for limits
   - Use `fuel` when preventing infinite loops
   - Use `n`, `count` for iteration counts

2. **Documentation**:
   - Always document what the Nat parameter represents
   - Specify whether it's a hard limit or soft bound
   - Explain termination guarantee

3. **Error Handling**:
   - Return `Option` or `Except` when bound is reached
   - Provide meaningful error messages about limits
   - Consider making bounds configurable

4. **Testing**:
   - Test with bound = 0 (edge case)
   - Test with bound = 1 (minimal iteration)
   - Test when bound exceeds available elements
   - Test near bound (n-1, n, n+1 cases)

## Summary of Key Patterns

### Pattern 1: Simple Bounded Iteration
```lean
Nat.repeat : (α → α) → Nat → α → α
-- Apply function n times
```
**Use**: When you need to repeat an operation exactly n times without needing the iteration index.

### Pattern 2: Index-Aware Bounded Iteration  
```lean
Nat.fold : Nat → ((i : Nat) → i < n → α → α) → α → α
-- Fold with iteration index and proof
```
**Use**: When you need the current iteration number at each step.

### Pattern 3: Bounded Collection Operations
```lean
List.take : Nat → List α → List α
-- Extract first n elements
```
**Use**: Limiting size of collections or extracting prefixes.

### Pattern 4: Type-Safe Bounded Iteration
```lean
Fin.foldl : (n : Nat) → (α → Fin n → α) → α → α
-- Fold over bounded finite type
```
**Use**: When you want compile-time guarantees about bounds.

### Pattern 5: Fuel-Based Termination
```lean
Config.maxSteps : Nat
-- Used internally in proof search to prevent infinite loops
```
**Use**: Algorithms that might not terminate naturally but need guaranteed termination.

### Key Insight for ProofChecker

For proof search automation, the **fuel-based pattern** combined with **depth tracking** is most appropriate:

```lean
structure SearchConfig where
  maxDepth : Nat  -- Maximum proof search depth
  maxSteps : Nat  -- Maximum total search steps (fuel)
  
def search (cfg : SearchConfig) (depth : Nat) (steps : Nat) (goal : Formula) 
    : Option Derivation :=
  if steps ≥ cfg.maxSteps then none
  else if depth ≥ cfg.maxDepth then none
  else
    -- Try tactics, recurse with depth+1 and steps+k
    ...
```

This provides:
- Hard termination guarantee (structural recursion on fuel)
- Depth-based search control
- Step-based timeout
- Configurable limits
- Clear error conditions (out of fuel vs depth limit)

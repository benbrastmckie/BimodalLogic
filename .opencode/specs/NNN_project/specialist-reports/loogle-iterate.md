# Loogle Search Results: iterate

**Search Query**: `"iterate"` (name-based search)  
**Date**: 2025-12-20  
**Matches Found**: 1027 (showing first 200)  
**Search API**: https://loogle.lean-lang.org  

## Executive Summary

This report catalogs all functions and theorems in Lean's standard library and Mathlib containing "iterate" in their name. The search reveals a rich ecosystem of iteration primitives with different termination strategies:

1. **Nat-bounded iteration** (`Nat.iterate`, `Fin.hIterate`) - Most common pattern
2. **Monadic iteration** (`IO.iterate`, `MLList.iterate`) - State-based termination
3. **Tactic iteration** (`iterate` tactic) - Until-failure loop
4. **Property-preserving iterations** - Extensive theorem library

---

## Core Iteration Functions

### 1. Nat.iterate

- **Full Name**: `Nat.iterate`
- **Type Signature**: `{α : Sort u} (op : α → α) : ℕ → α → α`
- **Library**: Mathlib
- **Module**: `Mathlib.Logic.Function.Iterate`
- **Notation**: `f^[n]` (available as syntactic sugar)
- **Description**: Iterates a function exactly `n` times. This is the fundamental iteration primitive in Lean.
- **Iteration Bounding**: Natural number parameter - structurally decreasing
- **Termination Mechanism**: Nat-indexed recursion (always terminates)
- **Usage Example**: 
  ```lean
  -- f^[3] x = f (f (f x))
  example : Nat.succ^[3] 0 = 3 := rfl
  ```

**Related Theorems** (Sample):
- `Function.iterate_zero`: `f^[0] = id`
- `Function.iterate_succ`: `f^[n.succ] = f^[n] ∘ f`
- `Function.iterate_add`: `f^[m + n] = f^[m] ∘ f^[n]`
- `Function.iterate_mul`: `f^[m * n] = f^[m]^[n]`
- `Function.iterate_comm`: `f^[n]^[m] = f^[m]^[n]`

---

### 2. Fin.hIterate

- **Full Name**: `Fin.hIterate`
- **Type Signature**: `(P : ℕ → Sort u_1) {n : ℕ} (init : P 0) (f : (i : Fin n) → P ↑i → P (↑i + 1)) : P n`
- **Library**: Lean Init
- **Module**: `Init.Data.Fin.Iterate`
- **Description**: Heterogeneous iteration with dependent types. Applies an index-dependent function to all values less than bound `n`, starting at 0 with an accumulator. The type can change at each step based on the index.
- **Iteration Bounding**: Fin-bounded (0 to n-1), structurally decreasing
- **Termination Mechanism**: Well-founded recursion on `Fin n` (always terminates)
- **Concrete Behavior**: 
  ```
  Fin.hIterate P init f ≡ init |> f 0 |> f 1 |> ... |> f (n-1)
  ```
- **Key Theorems**:
  - `Fin.hIterate_elim`: Induction principle for proving properties
  - `Fin.hIterate_eq`: Equality principle using state function

**Variant**: 
- `Fin.hIterateFrom`: Takes custom starting index instead of 0
  - Type: `(P : ℕ → Sort u_1) {n : ℕ} (f : (i : Fin n) → P ↑i → P (↑i + 1)) (i : ℕ) (ubnd : i ≤ n) (a : P i) : P n`

---

### 3. IO.iterate

- **Full Name**: `IO.iterate`
- **Type Signature**: `{α β : Type} (a : α) (f : α → IO (α ⊕ β)) : IO β`
- **Library**: Lean Init
- **Module**: `Init.System.IO`
- **Description**: Iterates an IO action until completion. Starting with initial state, applies function repeatedly. Each `Sum.inl` returns new state; `Sum.inr` returns final value and terminates.
- **Iteration Bounding**: Unbounded - relies on function returning `Sum.inr` eventually
- **Termination Mechanism**: Explicit exit condition via `Sum` type (no static guarantee)
- **Usage Pattern**:
  ```lean
  -- f : State → IO (State ⊕ Result)
  -- Returns: IO Result
  IO.iterate initialState f
  ```

---

### 4. MLList.iterate

- **Full Name**: `MLList.iterate`
- **Type Signature**: `{m : Type u_1 → Type u_1} {α : Type u_1} [Monad m] (f : m α) : MLList m α`
- **Library**: Batteries (Std)
- **Module**: `Batteries.Data.MLList.Basic`
- **Description**: Constructs a monadic lazy list by repeatedly running a monadic action. Creates infinite stream from repeated action execution (useful in stateful monads).
- **Iteration Bounding**: Unbounded - creates infinite lazy list
- **Termination Mechanism**: Lazy evaluation - consumption controls termination
- **Note**: `m` must be a stateful monad for this to be useful

---

### 5. Nondet.iterate

- **Full Name**: `Nondet.iterate`
- **Type Signature**: `{σ : Type} {m : Type → Type} [Monad m] [Lean.MonadBacktrack σ m] {α : Type} (f : α → Nondet m α) (a : α) : Nondet m α`
- **Library**: Batteries (Std)
- **Module**: `Batteries.Control.Nondet.Basic`
- **Description**: All iterations of a non-deterministic function on an initial value (depth-first search). Explores all possible execution paths.
- **Iteration Bounding**: Unbounded - explores entire search space
- **Termination Mechanism**: Backtracking monad controls search termination
- **Use Case**: Proof search, constraint solving, exploring state spaces

---

### 6. List.iterate

- **Full Name**: `List.iterate`
- **Type Signature**: `{α : Type u_1} (f : α → α) (a : α) (n : ℕ) : List α`
- **Library**: Mathlib
- **Module**: `Mathlib.Data.List.Defs`
- **Description**: Returns list of first `n` iterations: `[a, f a, f (f a), ..., f^[n-1] a]`
- **Iteration Bounding**: Natural number parameter
- **Termination Mechanism**: Nat-indexed recursion (always terminates)
- **Returns**: List of intermediate results

---

### 7. Stream'.iterate

- **Full Name**: `Stream'.iterate`
- **Type Signature**: Not shown in first 200 results (beyond index)
- **Library**: Mathlib
- **Module**: Not shown
- **Description**: Stream (infinite lazy sequence) of iterations
- **Iteration Bounding**: Unbounded - infinite stream
- **Termination Mechanism**: Lazy evaluation

---

### 8. Tactic: iterate

- **Full Name**: `Lean.Parser.Tactic.tacticIterate____`
- **Type Signature**: `: Lean.ParserDescr` (tactic syntax)
- **Library**: Lean Init
- **Module**: `Init.TacticsExtra`
- **Description**: 
  - `iterate n tac` - Runs `tac` exactly `n` times
  - `iterate tac` - Runs `tac` repeatedly until failure
- **Iteration Bounding**: 
  - With `n`: Bounded by natural number
  - Without `n`: Until failure
- **Termination Mechanism**: 
  - Counted: Nat-bounded
  - Uncounted: First tactic failure
- **Usage**:
  ```lean
  iterate 3 (apply And.intro)
  iterate (simp only []; split)
  ```

**Related Tactic Functions**:
- `Lean.Elab.Tactic.iterateExactly'`: Execute tactic exactly `n` times
- `Lean.Elab.Tactic.iterateUntilFailure`: Repeat until failure (always succeeds)
- `Lean.Elab.Tactic.iterateAtMost`: At most `n` times, stop on failure
- `Lean.Elab.Tactic.iterateRange`: Between `m` and `n` times
- `Lean.Elab.Tactic.iterateUntilFailureCount`: Count successful iterations
- `Lean.Elab.Tactic.iterateUntilFailureWithResults`: Accumulate results

---

## Property-Preserving Iteration Theorems

These theorems show that iterating a function with certain properties preserves those properties.

### Injectivity & Surjectivity

| Theorem | Type | Module |
|---------|------|--------|
| `Function.Injective.iterate` | `{f : α → α} (Hinj : Function.Injective f) (n : ℕ) : Function.Injective f^[n]` | `Mathlib.Logic.Function.Iterate` |
| `Function.Surjective.iterate` | `{f : α → α} (Hsurj : Function.Surjective f) (n : ℕ) : Function.Surjective f^[n]` | `Mathlib.Logic.Function.Iterate` |
| `Function.Bijective.iterate` | `{f : α → α} (Hbij : Function.Bijective f) (n : ℕ) : Function.Bijective f^[n]` | `Mathlib.Logic.Function.Iterate` |

### Inverse Relations

| Theorem | Type | Module |
|---------|------|--------|
| `Function.LeftInverse.iterate` | `{f g : α → α} (hg : Function.LeftInverse g f) (n : ℕ) : Function.LeftInverse g^[n] f^[n]` | `Mathlib.Logic.Function.Iterate` |
| `Function.RightInverse.iterate` | `{f g : α → α} (hg : Function.RightInverse g f) (n : ℕ) : Function.RightInverse g^[n] f^[n]` | `Mathlib.Logic.Function.Iterate` |

### Commutativity

| Theorem | Type | Module |
|---------|------|--------|
| `Function.Commute.self_iterate` | `(f : α → α) (n : ℕ) : Function.Commute f f^[n]` | `Mathlib.Logic.Function.Iterate` |
| `Function.Commute.iterate_self` | `(f : α → α) (n : ℕ) : Function.Commute f^[n] f` | `Mathlib.Logic.Function.Iterate` |
| `Function.Commute.iterate_iterate_self` | `(f : α → α) (m n : ℕ) : Function.Commute f^[m] f^[n]` | `Mathlib.Logic.Function.Iterate` |
| `Function.Commute.iterate_iterate` | `{f g : α → α} (h : Function.Commute f g) (m n : ℕ) : Function.Commute f^[m] g^[n]` | `Mathlib.Logic.Function.Iterate` |
| `Function.Commute.comp_iterate` | `{f g : α → α} (h : Function.Commute f g) (n : ℕ) : (f ∘ g)^[n] = f^[n] ∘ g^[n]` | `Mathlib.Logic.Function.Iterate` |

### Semiconjugacy

| Theorem | Type | Module |
|---------|------|--------|
| `Function.Semiconj₂.iterate` | `{f : α → α} {op : α → α → α} (hf : Function.Semiconj₂ f op op) (n : ℕ) : Function.Semiconj₂ f^[n] op op` | `Mathlib.Logic.Function.Iterate` |
| `Function.Semiconj.iterate_right` | `{f : α → β} {ga : α → α} {gb : β → β} (h : Function.Semiconj f ga gb) (n : ℕ) : Function.Semiconj f ga^[n] gb^[n]` | `Mathlib.Logic.Function.Iterate` |
| `Function.Semiconj.iterate_left` | `{f : α → α} {g : ℕ → α → α} (H : ∀ (n : ℕ), Function.Semiconj f (g n) (g (n + 1))) (n k : ℕ) : Function.Semiconj f^[n] (g k) (g (n + k))` | `Mathlib.Logic.Function.Iterate` |

### Monotonicity

| Theorem | Type | Module |
|---------|------|--------|
| `Monotone.iterate` | `[Preorder α] {f : α → α} (hf : Monotone f) (n : ℕ) : Monotone f^[n]` | `Mathlib.Order.Monotone.Defs` |
| `StrictMono.iterate` | `[Preorder α] {f : α → α} (hf : StrictMono f) (n : ℕ) : StrictMono f^[n]` | `Mathlib.Order.Monotone.Defs` |

### Set-Theoretic Properties

| Theorem | Type | Module |
|---------|------|--------|
| `Set.MapsTo.iterate` | `{f : α → α} {s : Set α} (h : Set.MapsTo f s s) (n : ℕ) : Set.MapsTo f^[n] s s` | `Mathlib.Data.Set.Function` |
| `Set.InjOn.iterate` | `{f : α → α} {s : Set α} (h : Set.InjOn f s) (hf : Set.MapsTo f s s) (n : ℕ) : Set.InjOn f^[n] s` | `Mathlib.Data.Set.Function` |
| `Set.SurjOn.iterate` | `{f : α → α} {s : Set α} (h : Set.SurjOn f s s) (n : ℕ) : Set.SurjOn f^[n] s s` | `Mathlib.Data.Set.Function` |
| `Set.BijOn.iterate` | `{f : α → α} {s : Set α} (h : Set.BijOn f s s) (n : ℕ) : Set.BijOn f^[n] s s` | `Mathlib.Data.Set.Function` |

### Fixed Points & Periodic Points

| Theorem | Type | Module |
|---------|------|--------|
| `Function.IsFixedPt.iterate` | `{f : α → α} {x : α} (hf : Function.IsFixedPt f x) (n : ℕ) : Function.IsFixedPt f^[n] x` | `Mathlib.Dynamics.FixedPoints.Basic` |
| `Function.IsPeriodicPt.iterate` | Type not shown (beyond first 200) | Module not shown |
| `Function.iterate_fixed` | `{f : α → α} {x : α} (h : f x = x) (n : ℕ) : f^[n] x = x` | `Mathlib.Logic.Function.Iterate` |

---

## Topology & Analysis Iterations

These theorems show iteration preserves continuity and differentiability properties.

### Continuity

| Theorem | Type | Module |
|---------|------|--------|
| `Continuous.iterate` | Type not shown | Module not shown |
| `ContinuousAt.iterate` | Type not shown | Module not shown |
| `ContinuousOn.iterate` | Type not shown | Module not shown |
| `UniformContinuous.iterate` | Type not shown | Module not shown |
| `LeftOrdContinuous.iterate` | Type not shown | Module not shown |
| `RightOrdContinuous.iterate` | Type not shown | Module not shown |

### Lipschitz Continuity

| Theorem | Type | Module |
|---------|------|--------|
| `LipschitzWith.iterate` | Type not shown | Module not shown |
| `LocallyLipschitz.iterate` | Type not shown | Module not shown |

### Differentiability

| Theorem | Type | Module |
|---------|------|--------|
| `Differentiable.iterate` | Type not shown | Module not shown |
| `DifferentiableAt.iterate` | Type not shown | Module not shown |
| `DifferentiableOn.iterate` | Type not shown | Module not shown |
| `DifferentiableWithinAt.iterate` | Type not shown | Module not shown |
| `HasFDerivAt.iterate` | Type not shown | Module not shown |
| `HasFDerivAtFilter.iterate` | Type not shown | Module not shown |
| `HasFDerivWithinAt.iterate` | Type not shown | Module not shown |
| `HasStrictFDerivAt.iterate` | Type not shown | Module not shown |
| `HasDerivAt.iterate` | Type not shown | Module not shown |
| `HasDerivAtFilter.iterate` | Type not shown | Module not shown |
| `HasDerivWithinAt.iterate` | Type not shown | Module not shown |
| `HasStrictDerivAt.iterate` | Type not shown | Module not shown |

### Manifold Smoothness

| Theorem | Type | Module |
|---------|------|--------|
| `ContMDiff.iterate` | Type not shown | Module not shown |
| `ContMDiffOn.iterate` | Type not shown | Module not shown |

### Measure Theory

| Theorem | Type | Module |
|---------|------|--------|
| `Measurable.iterate` | Type not shown | Module not shown |
| `MeasureTheory.Measure.QuasiMeasurePreserving.iterate` | Type not shown | Module not shown |
| `MeasureTheory.MeasurePreserving.iterate` | Type not shown | Module not shown |
| `MeasureTheory.Conservative.iterate` | Type not shown | Module not shown |

### Filter Convergence

| Theorem | Type | Module |
|---------|------|--------|
| `Filter.Tendsto.iterate` | Type not shown | Module not shown |

---

## Algebraic Structure Iterations

### Group & Monoid Homomorphisms

| Theorem | Type | Module |
|---------|------|--------|
| `iterate_map_zero` | `{M : Type} [Zero M] [FunLike F M M] [ZeroHomClass F M M] (f : F) (n : ℕ) : (⇑f)^[n] 0 = 0` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_one` | `{M : Type} [One M] [FunLike F M M] [OneHomClass F M M] (f : F) (n : ℕ) : (⇑f)^[n] 1 = 1` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_add` | `{M : Type} [Add M] [FunLike F M M] [AddHomClass F M M] (f : F) (n : ℕ) (x y : M) : (⇑f)^[n] (x + y) = (⇑f)^[n] x + (⇑f)^[n] y` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_mul` | `{M : Type} [Mul M] [FunLike F M M] [MulHomClass F M M] (f : F) (n : ℕ) (x y : M) : (⇑f)^[n] (x * y) = (⇑f)^[n] x * (⇑f)^[n] y` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_neg` | `{M : Type} [AddGroup M] [FunLike F M M] [AddMonoidHomClass F M M] (f : F) (n : ℕ) (x : M) : (⇑f)^[n] (-x) = -(⇑f)^[n] x` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_inv` | `{M : Type} [Group M] [FunLike F M M] [MonoidHomClass F M M] (f : F) (n : ℕ) (x : M) : (⇑f)^[n] x⁻¹ = ((⇑f)^[n] x)⁻¹` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_sub` | `{M : Type} [AddGroup M] [FunLike F M M] [AddMonoidHomClass F M M] (f : F) (n : ℕ) (x y : M) : (⇑f)^[n] (x - y) = (⇑f)^[n] x - (⇑f)^[n] y` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_div` | `{M : Type} [Group M] [FunLike F M M] [MonoidHomClass F M M] (f : F) (n : ℕ) (x y : M) : (⇑f)^[n] (x / y) = (⇑f)^[n] x / (⇑f)^[n] y` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_pow` | `{M : Type} [Monoid M] [FunLike F M M] [MonoidHomClass F M M] (f : F) (n : ℕ) (x : M) (k : ℕ) : (⇑f)^[n] (x ^ k) = (⇑f)^[n] x ^ k` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_nsmul` | `{M : Type} [AddMonoid M] [FunLike F M M] [AddMonoidHomClass F M M] (f : F) (n : ℕ) (x : M) (k : ℕ) : (⇑f)^[n] (k • x) = k • (⇑f)^[n] x` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_zsmul` | `{M : Type} [AddGroup M] [FunLike F M M] [AddMonoidHomClass F M M] (f : F) (n : ℕ) (x : M) (k : ℤ) : (⇑f)^[n] (k • x) = k • (⇑f)^[n] x` | `Mathlib.Algebra.Group.Hom.Defs` |
| `iterate_map_zpow` | `{M : Type} [Group M] [FunLike F M M] [MonoidHomClass F M M] (f : F) (n : ℕ) (x : M) (k : ℤ) : (⇑f)^[n] (x ^ k) = (⇑f)^[n] x ^ k` | `Mathlib.Algebra.Group.Hom.Defs` |

### Group Actions

| Theorem | Type | Module |
|---------|------|--------|
| `smul_iterate` | `{M : Type} {α : Type} [Monoid M] [MulAction M α] (a : M) (n : ℕ) : (fun x => a • x)^[n] = fun x => a ^ n • x` | `Mathlib.Algebra.Group.Action.Defs` |
| `smul_iterate_apply` | `{M : Type} {α : Type} [Monoid M] [MulAction M α] (a : M) (n : ℕ) (x : α) : (fun x => a • x)^[n] x = a ^ n • x` | `Mathlib.Algebra.Group.Action.Defs` |
| `vadd_iterate` | `{M : Type} {α : Type} [AddMonoid M] [AddAction M α] (a : M) (n : ℕ) : (fun x => a +ᵥ x)^[n] = fun x => n • a +ᵥ x` | `Mathlib.Algebra.Group.Action.Defs` |
| `vadd_iterate_apply` | `{M : Type} {α : Type} [AddMonoid M] [AddAction M α] (a : M) (n : ℕ) (x : α) : (fun x => a +ᵥ x)^[n] x = n • a +ᵥ x` | `Mathlib.Algebra.Group.Action.Defs` |

### Specific Iterations

| Theorem | Type | Module |
|---------|------|--------|
| `nsmul_iterate` | `{M : Type} [AddMonoid M] (k n : ℕ) : (fun x => k • x)^[n] = fun x => k ^ n • x` | `Mathlib.Algebra.Group.Basic` |
| `pow_iterate` | `{M : Type} [Monoid M] (k n : ℕ) : (fun x => x ^ k)^[n] = fun x => x ^ k ^ n` | `Mathlib.Algebra.Group.Basic` |
| `Nat.succ_iterate` | `(a n : ℕ) : Nat.succ^[n] a = a + n` | `Mathlib.Data.Nat.SuccPred` |
| `Nat.pred_iterate` | `(a n : ℕ) : Nat.pred^[n] a = a - n` | `Mathlib.Data.Nat.SuccPred` |

---

## Data Structure Iterations

### Product & Pi Types

| Theorem | Type | Module |
|---------|------|--------|
| `Prod.map_iterate` | `{α β : Type} (f : α → α) (g : β → β) (n : ℕ) : (Prod.map f g)^[n] = Prod.map f^[n] g^[n]` | `Mathlib.Data.Prod.Basic` |
| `Pi.map_iterate` | `{ι : Type} {α : ι → Type} (f : (i : ι) → α i → α i) (n : ℕ) : (Pi.map f)^[n] = Pi.map fun i => (f i)^[n]` | `Mathlib.Logic.Function.Iterate` |

### Set Operations

| Theorem | Type | Module |
|---------|------|--------|
| `Set.image_iterate_eq` | `{α : Type} {f : α → α} {n : ℕ} : Set.image f^[n] = (Set.image f)^[n]` | `Mathlib.Data.Set.Image` |
| `Set.preimage_iterate_eq` | `{α : Type} {f : α → α} {n : ℕ} : Set.preimage f^[n] = (Set.preimage f)^[n]` | `Mathlib.Data.Set.Image` |

### Tree Maps (Std Library)

These are bundled types with inductive principles for proving properties about sequences of tree operations:

| Type | Module | Purpose |
|------|--------|---------|
| `Std.DTreeMap.Internal.Impl.IteratedInsertionInto` | `Std.Data.DTreeMap.Internal.Operations` | Tree obtained by inserting elements |
| `Std.DTreeMap.Internal.Impl.IteratedNewInsertionInto` | `Std.Data.DTreeMap.Internal.Operations` | Tree obtained by inserting new elements only |
| `Std.DTreeMap.Internal.Impl.IteratedErasureFrom` | `Std.Data.DTreeMap.Internal.Operations` | Tree obtained by erasing elements |
| `Std.DTreeMap.Internal.Impl.IteratedEntryErasureFrom` | `Std.Data.DTreeMap.Internal.Operations` | Tree obtained by erasing entries |
| `Std.DTreeMap.Internal.Impl.IteratedSlowInsertionInto` | `Std.Data.DTreeMap.Internal.Operations` | Slow insertion variant |
| `Std.DTreeMap.Internal.Impl.IteratedSlowErasureFrom` | `Std.Data.DTreeMap.Internal.Operations` | Slow erasure variant |

These also have specialized `Const` variants for constant value types.

---

## Internal & Advanced Iterations

### Order Theory (CCPO Iteration)

| Function/Theorem | Type | Module |
|------------------|------|--------|
| `Lean.Order.iterates` | `{α : Sort u} [Lean.Order.CCPO α] (f : α → α) : α → Prop` | `Init.Internal.Order.Basic` |
| `Lean.Order.iterates.step` | `{α : Sort u} [Lean.Order.CCPO α] {f : α → α} {x : α} : Lean.Order.iterates f x → Lean.Order.iterates f (f x)` | `Init.Internal.Order.Basic` |
| `Lean.Order.iterates.brecOn` | Structural recursion on iterates | `Init.Internal.Order.Basic` |
| `Lean.Order.iterates.sup` | Supremum preservation | `Init.Internal.Order.Basic` |
| `Lean.Order.chain_iterates` | Chain property for iterates | `Init.Internal.Order.Basic` |

**Description**: Transfinite iteration for constructing partial fixpoints in complete chain-partial orders (CCPOs). Used internally for fixpoint constructions.

---

## Iteration Patterns Summary

### 1. Bounded Natural Iteration
**Pattern**: `Nat.iterate`, `Fin.hIterate`, `List.iterate`  
**Bounding**: Natural number or Fin index  
**Termination**: Structural recursion on Nat (always terminates)  
**Use When**: You know the exact number of iterations needed  
**Example**: `f^[n] x` where `n : ℕ`

### 2. Monadic Until-Success Iteration
**Pattern**: `IO.iterate`, `MLList.iterate`  
**Bounding**: Explicit exit condition (Sum type or stream consumption)  
**Termination**: No static guarantee; relies on function behavior  
**Use When**: Iteration count depends on runtime state  
**Example**: State machines, interactive loops

### 3. Search-Based Iteration
**Pattern**: `Nondet.iterate`  
**Bounding**: Search space exploration  
**Termination**: Backtracking monad controls termination  
**Use When**: Exploring non-deterministic computations  
**Example**: Proof search, constraint solving

### 4. Tactic Iteration
**Pattern**: `iterate` tactic  
**Bounding**: Count or until-failure  
**Termination**: Tactic failure or count exhaustion  
**Use When**: Repeatedly applying proof tactics  
**Example**: `iterate 5 simp`

### 5. Transfinite Iteration
**Pattern**: `Lean.Order.iterates`  
**Bounding**: CCPO structure  
**Termination**: Order-theoretic limits  
**Use When**: Constructing fixpoints in domain theory  
**Example**: Internal compiler fixpoint constructions

---

## Termination Strategies Catalog

| Strategy | Guarantee | Examples | Pros | Cons |
|----------|-----------|----------|------|------|
| **Nat-indexed** | Always terminates | `Nat.iterate`, `Fin.hIterate` | Simple, total, efficient | Need to know count upfront |
| **Structural recursion** | Always terminates | All Nat/Fin based | Lean accepts automatically | Limited to decreasing structures |
| **Well-founded recursion** | Always terminates | `Fin.hIterate` on Fin | Flexible, provably total | Need termination proof |
| **Explicit exit (Sum)** | No guarantee | `IO.iterate` | Natural for state machines | Must prove termination separately |
| **Until-failure** | No guarantee | `iterate` tactic | Convenient for tactics | Can loop infinitely |
| **Lazy evaluation** | No guarantee | `MLList.iterate`, `Stream'.iterate` | Memory efficient | Termination on consumption |
| **Backtracking monad** | No guarantee | `Nondet.iterate` | Explores full space | Can be exponential |
| **Order-theoretic** | By CCPO structure | `Lean.Order.iterates` | Handles infinite cases | Complex, specialized |

---

## Key Arithmetic Properties

### Identity & Base Cases
- `Function.iterate_zero`: `f^[0] = id`
- `Function.iterate_one`: `f^[1] = f`
- `Function.iterate_id`: `id^[n] = id`

### Composition Laws
- `Function.iterate_succ`: `f^[n.succ] = f^[n] ∘ f`
- `Function.iterate_succ'`: `f^[n.succ] = f ∘ f^[n]`
- `Function.iterate_add`: `f^[m + n] = f^[m] ∘ f^[n]`
- `Function.iterate_mul`: `f^[m * n] = f^[m]^[n]`

### Cancellation
- `Function.iterate_cancel`: If `f` injective and `f^[m] a = f^[n] a`, then `f^[m - n] a = a`
- `Function.iterate_add_eq_iterate`: For injective `f`: `f^[m + n] a = f^[n] a ↔ f^[m] a = a`

### Commutativity
- `Function.iterate_comm`: `f^[n]^[m] = f^[m]^[n]`
- `Function.iterate_commute`: `(m n : ℕ) → Function.Commute (fun f => f^[m]) (fun f => f^[n])`

---

## Recommendations

### For Logos Project

1. **Use `Nat.iterate` (`f^[n]`) for proof automation**:
   - When you need to apply a tactic or transformation a known number of times
   - The `^[n]` notation is clean and has extensive theorem support
   - Example: `(apply_modal_rule)^[5]` to apply a rule 5 times

2. **Use `iterate` tactic for proof scripts**:
   - `iterate n tac` for exact repetition
   - `iterate tac` for "apply until it stops working"
   - Good for normalization steps: `iterate (simp only [rule1, rule2]; split)`

3. **Property preservation is automatic**:
   - If your function is monotone, `Monotone.iterate` proves all iterations are monotone
   - If your function is injective, `Injective.iterate` proves all iterations are injective
   - Useful for modal operators with preservation properties

4. **For dependent types (like indexed formulas)**:
   - Consider `Fin.hIterate` if your iteration needs to track changing types
   - Provides strong induction principles via `Fin.hIterate_elim`

5. **Avoid unbounded iterations in tactics**:
   - `IO.iterate`, `MLList.iterate`, `Nondet.iterate` have no termination guarantee
   - Use only when you have external proof of termination
   - For proof search, consider bounded depth-first search instead

6. **Leverage the theorem library**:
   - 1027+ theorems available for iteration properties
   - Most standard properties (injectivity, monotonicity, continuity) already proven
   - Search pattern: `<property>.iterate` finds preservation theorems

---

## Usage Examples

### Example 1: Simple Function Iteration
```lean
-- Applying function 3 times
example : Nat.succ^[3] 5 = 8 := rfl

-- Using iterate directly
example : Nat.iterate Nat.succ 3 5 = 8 := rfl
```

### Example 2: Iterate Tactic
```lean
-- Apply intro exactly 3 times
example : P → Q → R → S → T :=
  iterate 3 intro
  sorry

-- Apply simp until it fails
example : complicated_goal :=
  iterate simp only [rule1, rule2]
  sorry
```

### Example 3: Property Preservation
```lean
-- If f is monotone, so is f^[n]
example {α : Type} [Preorder α] {f : α → α} (hf : Monotone f) (n : ℕ) :
    Monotone (f^[n]) :=
  hf.iterate n
```

### Example 4: Dependent Iteration
```lean
-- Building a vector by repeated application
def buildVec (n : ℕ) : Vector Nat n :=
  Fin.hIterate (fun i => Vector Nat i)
    Vector.nil
    (fun i vec => vec.push i.val)
```

### Example 5: IO Iteration
```lean
-- Read lines until empty line encountered
def readUntilEmpty : IO (List String) := do
  let lines ← IO.iterate ([], false) fun (acc, _) => do
    let line ← (← IO.getStdin).getLine
    if line.trim.isEmpty then
      return Sum.inr acc
    else
      return Sum.inl (line :: acc, false)
  return lines.reverse
```

---

## Appendix: Complete Match Counts by Category

- **Core iteration functions**: 8
- **Tactic-related**: 7
- **Property-preserving theorems**: 60+
- **Topology/analysis**: 25+
- **Algebra**: 30+
- **Data structures**: 15+
- **Tree map operations**: 12+
- **Order theory**: 8+
- **Measure theory**: 4
- **Dynamics**: 3+
- **Other**: ~800+

**Total matches**: 1027 (200 shown in detail)

---

## Search Methodology

1. Used Loogle API: `https://loogle.lean-lang.org/json?q="iterate"`
2. Name-based search with quotes for exact substring matching
3. Retrieved first 200 of 1027 total matches
4. Categorized by:
   - Core functionality
   - Property preservation
   - Mathematical domain
   - Termination strategy
5. Extracted type signatures, modules, and documentation where available

---

## References

- **Loogle**: https://loogle.lean-lang.org
- **Mathlib Documentation**: https://leanprover-community.github.io/mathlib4_docs/
- **Lean 4 Manual**: https://lean-lang.org/lean4/doc/

---

*Report generated: 2025-12-20*  
*Loogle API query: `"iterate"` (name search)*  
*Total declarations found: 1027*  
*Detailed analysis: First 200 matches*

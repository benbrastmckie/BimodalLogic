# Loogle Search Report: Bounded Computation Pattern

## Search Metadata

- **Type Pattern**: `_ → _ → Nat → Option _`
- **Search Date**: 2025-12-20
- **Total Matches**: 68
- **Query Source**: Loogle API (https://loogle.lean-lang.org/)
- **Context**: Analyzing bounded computation patterns where Nat parameter controls limits/bounds

## Executive Summary

The search identified 68 functions matching the pattern `_ → _ → Nat → Option _` across the Lean standard library, Batteries, and Mathlib. The Nat parameter serves multiple distinct purposes:

1. **Index Access** (most common): Array/List/Collection indexing with bounds checking
2. **Iteration Bounds**: Limiting the number of steps in potentially infinite computations
3. **Fuel Parameters**: Ensuring termination in recursive computations
4. **Cutoff Values**: Early termination when thresholds are exceeded
5. **Position Markers**: String/ByteArray position tracking

### Key Findings

- **Primary Pattern**: Collection indexing with `n`-th element access (42 matches, ~62%)
- **Bounded Iteration**: Iterator stepping with step limits (4 matches, ~6%)
- **Fuel-based Computation**: Evaluation with resource limits (2 matches, ~3%)
- **Search with Bounds**: Binary search and range-limited search (2 matches, ~3%)
- **Encoding/Decoding**: Numeric decoding to Option types (7 matches, ~10%)
- **Other**: Trie matching, diff indices, variable elimination (11 matches, ~16%)

## Categorized Matches

### Category 1: Index-Based Access (Exact Pattern Matches)

These functions use the Nat parameter as an **index** to access the n-th element of a collection.

#### 1.1 List Indexing

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `List.get?Internal` | `{α : Type u_1} (as : List α) (i : ℕ) : Option α` | Init.GetElem | Direct index into list |
| `List.ofFnNthVal` | `{α : Type u_1} {n : ℕ} (f : Fin n → α) (i : ℕ) : Option α` | Batteries.Data.List.Basic | Index validation for function table |

**Documentation**:
- `List.get?Internal`: Internal implementation of `as[i]?`. Do not use directly.
- `List.ofFnNthVal`: Returns `some (f i)` if `i < n` and `none` otherwise.

**Analysis**: These use Nat as a straightforward array index with bounds checking. Returns `none` when `i >= length`.

#### 1.2 Array Indexing and Search

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Array.idxOfAux` | `{α : Type u} [BEq α] (xs : Array α) (v : α) (i : ℕ) : Option (Fin xs.size)` | Init.Data.Array.Basic | Starting index for search |
| `Array.binSearch` | `{α : Type} (as : Array α) (k : α) (lt : α → α → Bool) (lo : ℕ := 0) (hi : ℕ := as.size - 1) : Option α` | Init.Data.Array.BinSearch | Search bounds (lo/hi) |
| `Array.max?` | `{α : Type u_1} [ord : Ord α] (xs : Array α) (start : ℕ := 0) (stop : ℕ := xs.size) : Option α` | Batteries.Data.Array.Basic | Subarray range bounds |
| `Array.min?` | `{α : Type u_1} [ord : Ord α] (xs : Array α) (start : ℕ := 0) (stop : ℕ := xs.size) : Option α` | Batteries.Data.Array.Basic | Subarray range bounds |

**Documentation**:
- `Array.binSearch`: Binary search for an element equivalent to `k` in the sorted array. The optional parameters `lo` and `hi` determine the region of array indices to be searched. Both are inclusive.
- `Array.max?`: Find the first maximal element of an array. If `start` and `stop` are given, only the subarray `xs[start:stop]` is considered.

**Analysis**: These demonstrate **range-bounded search** - the Nat parameters define search boundaries rather than a single index.

#### 1.3 ByteArray Indexing

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `ByteArray.findIdx?` | `(a : ByteArray) (p : UInt8 → Bool) (start : ℕ := 0) : Option ℕ` | Init.Data.ByteArray.Basic | Starting position for search |
| `ByteArray.findFinIdx?` | `(a : ByteArray) (p : UInt8 → Bool) (start : ℕ := 0) : Option (Fin a.size)` | Init.Data.ByteArray.Basic | Starting position with proof |

**Documentation**:
- `ByteArray.findIdx?`: Finds the index of the first byte in `a` for which `p` returns `true`. If no byte in `a` satisfies `p`, then the result is `none`.
- `ByteArray.findFinIdx?`: Returns the index along with a proof that it is a valid index in the array.

**Analysis**: Uses Nat as a **starting position** for linear search, defaulting to 0.

#### 1.4 Tree Map/Set Indexing

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Std.TreeMap.keyAtIdx?` | `{α β : Type} {cmp} (t : Std.TreeMap α β cmp) (n : ℕ) : Option α` | Std.Data.TreeMap.Basic | Index in sorted order |
| `Std.TreeMap.entryAtIdx?` | `{α β : Type} {cmp} (t : Std.TreeMap α β cmp) (n : ℕ) : Option (α × β)` | Std.Data.TreeMap.Basic | Index in sorted order |
| `Std.TreeSet.atIdx?` | `{α : Type} {cmp} (t : Std.TreeSet α cmp) (n : ℕ) : Option α` | Std.Data.TreeSet.Basic | Index in sorted order |
| `Std.DTreeMap.keyAtIdx?` | `{α : Type} {β : α → Type} {cmp} (t : Std.DTreeMap α β cmp) (n : ℕ) : Option α` | Std.Data.DTreeMap.Basic | Index for dependent types |
| `Std.ExtTreeMap.keyAtIdx?` | `{α β : Type} {cmp} [Std.TransCmp cmp] (t : Std.ExtTreeMap α β cmp) (n : ℕ) : Option α` | Std.Data.ExtTreeMap.Basic | Index with transitive cmp |

**Documentation**:
- `Std.TreeMap.keyAtIdx?`: Returns the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- `Std.TreeSet.atIdx?`: Returns the `n`-th smallest element, or `none` if `n` is at least `t.size`.

**Analysis**: These provide **order-preserving indexing** into tree structures. The Nat represents position in the sorted sequence of keys/elements.

#### 1.5 BitVec Bit Access

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `BitVec.getLsb?` | `{w : ℕ} (x : BitVec w) (i : ℕ) : Option Bool` | Init.Data.BitVec.Basic | Bit position (LSB) |
| `BitVec.getMsb?` | `{w : ℕ} (x : BitVec w) (i : ℕ) : Option Bool` | Init.Data.BitVec.Basic | Bit position (MSB) |

**Documentation**:
- `BitVec.getLsb?`: Returns the `i`th least significant bit, or `none` if `i ≥ w`.
- `BitVec.getMsb?`: Returns the `i`th most significant bit or `none` if `i ≥ w`.

**Analysis**: Bit-level indexing with bounds checking against bit vector width.

#### 1.6 Sequence Access

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Stream'.Seq.get?` | `{α : Type u} : Stream'.Seq α → ℕ → Option α` | Mathlib.Data.Seq.Defs | Index into lazy sequence |
| `Ordnode.nth` | `{α : Type u_1} : Ordnode α → ℕ → Option α` | Mathlib.Data.Ordmap.Ordnode | Index into ordered tree |

**Documentation**:
- `Stream'.Seq.get?`: Get the nth element of a sequence (if it exists).
- `Ordnode.nth`: O(log n). Get the `i`th element of the set, by its index from left to right.

**Analysis**: Lazy sequence indexing, potentially for infinite structures.

### Category 2: Bounded Iteration (Fuel Parameters)

These functions use the Nat parameter as a **step limit** or **fuel** to ensure termination.

#### 2.1 Iterator Access

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Std.Iterators.Iter.Partial.atIdxSlow?` | `{α β : Type} [Iterator α Id β] [Monad Id] (n : ℕ) (it : Iter.Partial β) : Option β` | Init.Data.Iterators.Consumers.Access | Steps to take |
| `Std.Iterators.Iter.atIdxSlow?` | `{α β : Type} [Iterator α Id β] [Productive α Id] (n : ℕ) (it : Iter β) : Option β` | Init.Data.Iterators.Consumers.Access | Steps to take (verified) |
| `Std.Iterators.Iter.atIdx?` | `{α β : Type} [Iterator α Id β] [Productive α Id] [IteratorAccess α Id] (n : ℕ) (it : Iter β) : Option β` | Init.Data.Iterators.Consumers.Access | Direct index access |

**Documentation**:
- `Iter.Partial.atIdxSlow?`: If possible, takes `n` steps with the iterator `it` and returns the `n`-th emitted value, or `none` if `it` finished before emitting `n` values. This is a partial, potentially nonterminating function.
- `Iter.atIdxSlow?`: Requires a `Productive` instance proving that the iterator will always emit a value after a finite number of skips.
- `Iter.atIdx?`: For iterators that explicitly support it by implementing the `IteratorAccess` typeclass.

**Analysis**: The Nat parameter represents the **number of iteration steps** to perform. The `Partial` variant is potentially non-terminating, while the verified version requires productivity proofs.

#### 2.2 Computation Evaluation with Fuel

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Computation.runFor` | `{α : Type u} : Computation α → ℕ → Option α` | Mathlib.Data.Seq.Computation | Maximum steps |
| `Nat.Partrec.Code.evaln` | `ℕ → Nat.Partrec.Code → ℕ → Option ℕ` | Mathlib.Computability.PartrecCode | Fuel/bound parameter |

**Documentation**:
- `Computation.runFor`: `runFor c n` evaluates `c` for `n` steps and returns the result, or `none` if it did not terminate after `n` steps.
- `Nat.Partrec.Code.evaln`: A modified evaluation which returns an `Option ℕ` instead of a `Part ℕ`. To avoid undecidability, `evaln` takes a parameter `k` and fails if it encounters a number ≥ k in the course of its execution.

**Analysis**: These are **fuel-based evaluation** functions. The Nat parameter serves as:
- **Step limiter**: `runFor` stops after n steps
- **Bounds checker**: `evaln` fails if values exceed k

This is a classic technique for making partial recursive functions total by bounding their execution.

### Category 3: Enumerable Type Decoding

These functions decode natural numbers to elements of encodable types.

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Encodable.decode` | `{α : Type} [Encodable α] : ℕ → Option α` | Mathlib.Logic.Encodable.Basic | Numeric code |
| `Encodable.decode₂` | `(α : Type) [Encodable α] (n : ℕ) : Option α` | Mathlib.Logic.Encodable.Basic | Failsafe decode |
| `Encodable.decodeSum` | `{α β : Type} [Encodable α] [Encodable β] (n : ℕ) : Option (α ⊕ β)` | Mathlib.Logic.Encodable.Basic | Sum type decode |
| `Encodable.decodeSigma` | `{α : Type} {γ : α → Type} [Encodable α] [(a : α) → Encodable (γ a)] (n : ℕ) : Option (Sigma γ)` | Mathlib.Logic.Encodable.Basic | Sigma type decode |
| `Encodable.decodeSubtype` | `{α : Type} {P : α → Prop} [Encodable α] [DecidablePred P] (v : ℕ) : Option {a // P a}` | Mathlib.Logic.Encodable.Basic | Subtype decode |
| `Encodable.decodeList` | `{α : Type} [Encodable α] : ℕ → Option (List α)` | Mathlib.Logic.Equiv.List | List decode |
| `decodeMultiset` | `{α : Type} [Encodable α] (n : ℕ) : Option (Multiset α)` | Mathlib.Logic.Equiv.Multiset | Multiset decode |

**Documentation**:
- `Encodable.decode`: Decoding from ℕ to Option α
- `Encodable.decode₂`: Failsafe variant of `decode`. Returns the preimage of `n` under `encode` if it exists, and returns `none` if it doesn't.

**Analysis**: These use Nat as a **numeric encoding** of type elements. The Nat is not a limit/bound but rather an encoding scheme. Returns `none` for invalid encodings.

### Category 4: String/Position Processing

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Lean.Data.Trie.matchPrefix` | `{α : Type} (s : String) (t : Trie α) (i : String.Pos.Raw) (endByte : ℕ := s.utf8ByteSize) (...) : Option α` | Lean.Data.Trie | End position bound |
| `Lean.EditDistance.levenshtein` | `(str1 str2 : String) (cutoff : ℕ) : Option ℕ` | Lean.Data.EditDistance | Distance cutoff |

**Documentation**:
- `Lean.Data.Trie.matchPrefix`: Find the longest _key_ in the trie that is contained in the given string `s` at position `i`, and return the associated value.
- `Lean.EditDistance.levenshtein`: Computes the Levenshtein distance between two strings, up to some cutoff. If the return value is `none`, then the distance is certainly greater than the cutoff value.

**Analysis**: 
- Trie matching: Nat is an **end boundary** for substring matching
- Edit distance: Nat is a **cutoff threshold** for early termination

### Category 5: Enumeration and Selection

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Set.enumerate` | `{α : Type} (sel : Set α → Option α) : Set α → ℕ → Option α` | Mathlib.Data.Set.Enumerate | Iteration index |
| `Std.PRange.UpwardEnumerable.succMany?` | `{α : Type} [UpwardEnumerable α] (n : ℕ) (a : α) : Option α` | Init.Data.Range.Polymorphic.UpwardEnumerable | Number of successors |

**Documentation**:
- `Set.enumerate`: Given a choice function `sel`, enumerates the elements of a set in the order `a 0 = sel s`, `a 1 = sel (s \ {a 0})`, `a 2 = sel (s \ {a 0, a 1})`, ... and stops when `sel (s \ {a 0, ..., a n}) = none`.
- `succMany?`: Maps elements of `α` to their `n`-th successor, or none if no successor exists.

**Analysis**: Uses Nat to specify **how many times** to apply an operation.

### Category 6: Internal/Helper Functions

These are implementation details or helper functions.

| Function | Type | Module | Notes |
|----------|------|--------|-------|
| `List.findIdx?.go` | `{α : Type} (p : α → Bool) : List α → ℕ → Option ℕ` | Init.Data.List.Basic | Accumulator |
| `List.findFinIdx?.go` | Internal loop function | Init.Data.List.Basic | Loop helper |
| `Array.findIdx?.loop` | Internal loop function | Init.Data.Array.Basic | Loop helper |
| `ByteArray.findIdx?.loop` | Internal loop function | Init.Data.ByteArray.Basic | Loop helper |
| Various `*.Internal.*` functions | Implementation details | Multiple modules | Not for direct use |

**Analysis**: These use Nat as **accumulator** or **index tracker** in tail-recursive implementations.

### Category 7: Mathematical/Logic Operations

| Function | Type | Module | Nat Usage |
|----------|------|--------|-----------|
| `Mathlib.Tactic.Linarith.elimVar` | `(c1 c2 : Comp) (a : ℕ) : Option (ℕ × ℕ)` | Mathlib.Tactic.Linarith.Oracle.FourierMotzkin | Variable index |
| `Mathlib.Tactic.Linarith.pelimVar` | `(p1 p2 : PComp) (a : ℕ) : Option PComp` | Mathlib.Tactic.Linarith.Oracle.FourierMotzkin | Variable to eliminate |
| `Lean.Expr.getArg?` | `(e : Expr) (i : ℕ) (n : ℕ := e.getAppNumArgs) : Option Expr` | Mathlib.Lean.Expr.Basic | Argument index |

**Documentation**:
- `elimVar`: If `c1` and `c2` both contain variable `a` with opposite coefficients, produces `v1` and `v2` such that `a` has been cancelled in `v1*c1 + v2*c2`.
- `Lean.Expr.getArg?`: Given `f a₀ a₁ ... aₙ₋₁`, returns the `i`th argument or none if out of bounds.

**Analysis**: Variable indices and argument positions in logical/mathematical contexts.

## Nat Parameter Usage Patterns

### Pattern 1: Direct Index (42 instances, ~62%)

**Characteristics**:
- Nat represents position in a sequence
- Returns element at that position or `none` if out of bounds
- Most common pattern in collection types

**Termination**: Guaranteed by bounds checking against collection size.

**Examples**:
```lean
List.get?Internal : List α → ℕ → Option α
Array.idxOfAux : Array α → α → ℕ → Option (Fin xs.size)
Std.TreeMap.keyAtIdx? : TreeMap α β cmp → ℕ → Option α
```

### Pattern 2: Fuel/Step Limiter (4 instances, ~6%)

**Characteristics**:
- Nat limits number of computation steps
- Returns result if completed within limit, `none` otherwise
- Converts partial functions to total functions

**Termination**: Explicit by construction - computation stops after n steps.

**Examples**:
```lean
Computation.runFor : Computation α → ℕ → Option α
Iter.Partial.atIdxSlow? : ℕ → Iter.Partial β → Option β
Nat.Partrec.Code.evaln : ℕ → Code → ℕ → Option ℕ
```

### Pattern 3: Range Bounds (3 instances, ~4%)

**Characteristics**:
- Nat defines search/operation boundaries
- Often paired (start/stop or lo/hi)
- Constrains domain of operation

**Termination**: Search bounded by explicit range parameters.

**Examples**:
```lean
Array.binSearch : Array α → α → (α → α → Bool) → (lo : ℕ := 0) → (hi : ℕ := size - 1) → Option α
Array.max? : Array α → (start : ℕ := 0) → (stop : ℕ := size) → Option α
```

### Pattern 4: Encoding Scheme (7 instances, ~10%)

**Characteristics**:
- Nat is a unique code for type elements
- Not a bound, but a bijection (or partial function)
- Used in computability theory

**Termination**: Immediate - single lookup/computation.

**Examples**:
```lean
Encodable.decode : [Encodable α] → ℕ → Option α
Encodable.decodeSum : [Encodable α] [Encodable β] → ℕ → Option (α ⊕ β)
```

### Pattern 5: Cutoff/Threshold (2 instances, ~3%)

**Characteristics**:
- Nat represents maximum acceptable value
- Early termination when exceeded
- Optimization for expensive computations

**Termination**: Bounded by cutoff value.

**Examples**:
```lean
Lean.EditDistance.levenshtein : String → String → (cutoff : ℕ) → Option ℕ
Nat.Partrec.Code.evaln : ℕ → Code → ℕ → Option ℕ
```

### Pattern 6: Iteration Count (2 instances, ~3%)

**Characteristics**:
- Nat specifies "how many times" to apply operation
- Repeated application of a function
- Fails if operation not possible n times

**Termination**: Loop bounded by n iterations.

**Examples**:
```lean
Std.PRange.UpwardEnumerable.succMany? : (n : ℕ) → α → Option α
Set.enumerate : (sel : Set α → Option α) → Set α → ℕ → Option α
```

## Termination Mechanisms Employed

### 1. Bounds Checking

**Mechanism**: Compare index against collection size before access.

**Guarantee**: Terminates immediately with `none` if `i >= size`.

**Implementation Pattern**:
```lean
def get? (as : List α) (i : ℕ) : Option α :=
  if h : i < as.length then
    some (as.get ⟨i, h⟩)
  else
    none
```

### 2. Fuel-Based Recursion

**Mechanism**: Decrement counter at each recursive call, stop when reaching 0.

**Guarantee**: Maximum recursion depth bounded by initial fuel value.

**Implementation Pattern**:
```lean
def runFor (c : Computation α) : ℕ → Option α
  | 0 => none
  | n + 1 => match c.step with
    | .ret a => some a
    | .cont c' => runFor c' n
```

### 3. Range-Constrained Search

**Mechanism**: Explicit lo/hi bounds prevent infinite search.

**Guarantee**: Search space finite and well-defined.

**Implementation Pattern**:
```lean
def binSearch (as : Array α) (k : α) (lt : α → α → Bool) (lo hi : ℕ) : Option α :=
  if lo > hi then none
  else
    let mid := (lo + hi) / 2
    -- binary search logic with constrained range
```

### 4. Structural Recursion with Index

**Mechanism**: Recurse on list/tree structure, index decrements naturally.

**Guarantee**: Termination by structural induction.

**Implementation Pattern**:
```lean
def get? : List α → ℕ → Option α
  | [], _ => none
  | x :: xs, 0 => some x
  | x :: xs, i + 1 => get? xs i
```

### 5. Early Termination Threshold

**Mechanism**: Abort computation when value exceeds threshold.

**Guarantee**: Computation bounded by cutoff value check.

**Implementation Pattern**:
```lean
def levenshtein (s1 s2 : String) (cutoff : ℕ) : Option ℕ :=
  -- if distance > cutoff, return none immediately
  if partialDistance > cutoff then none
  else -- continue computation
```

## Analysis and Insights

### Key Observations

1. **Dominance of Indexing**: Over 60% of matches use Nat for direct indexing, showing this is the primary use case for the pattern.

2. **Fuel is Rare**: Only ~6% use Nat as fuel/step limiter, but these are crucial for handling partial recursive functions.

3. **Type Safety**: Many functions return refined types (e.g., `Option (Fin n)`) that encode validity proofs.

4. **Default Parameters**: Several functions use Nat with default values (e.g., `start := 0`, `stop := size`), making them more ergonomic.

5. **Layered Implementations**: Public API functions often delegate to `.go` or `.loop` helpers that carry accumulators.

6. **Productive Iterators**: The iterator functions distinguish between partial (potentially non-terminating) and productive (guaranteed terminating) variants.

### Comparison with ProofChecker Context

For the ProofChecker project (focused on temporal/modal logic proof checking):

**Relevant Patterns**:

1. **Fuel-Based Evaluation** (`Computation.runFor`, `evaln`):
   - **Relevance**: HIGH
   - **Application**: Bounded proof search, term rewriting with step limits
   - **Recommendation**: Use for tactics that might loop or search indefinitely

2. **Iterator Stepping** (`Iter.atIdxSlow?`):
   - **Relevance**: MEDIUM
   - **Application**: Traversing potentially infinite derivation trees
   - **Recommendation**: Consider for lazy proof exploration

3. **Encodable Decode**:
   - **Relevance**: LOW
   - **Application**: Not directly applicable to proof checking
   - **Recommendation**: Skip unless building proof enumeration features

**Less Relevant Patterns**:
- Collection indexing: Not primary concern for proof checking
- String operations: Limited relevance to logic proofs

## Recommendations for ProofChecker

### 1. Implementing Bounded Proof Search

**Pattern to Use**: Fuel-based recursion (like `Computation.runFor`)

**Recommended Implementation**:
```lean
-- For proof search tactics with depth limits
def searchProof (goal : Formula) (depth : ℕ) : Option (Derivation goal) :=
  match depth with
  | 0 => none  -- fuel exhausted
  | d + 1 =>
    -- try immediate proof
    if h : isAxiom goal then some (Axiom h)
    else
      -- try decomposition rules with reduced fuel
      goal.decompose.findSome? (λ subgoals =>
        subgoals.mapM (searchProof · d) >>= compose)
```

**Benefits**:
- Guarantees termination
- Predictable resource usage
- Easy to tune performance (adjust depth)

### 2. Bounded Tactic Application

**Pattern to Use**: Step limiter with state tracking

**Recommended Implementation**:
```lean
-- Apply tactic repeatedly until fixpoint or limit
def repeatUntilStable (tactic : Context → Option Context) 
                       (ctx : Context) 
                       (maxSteps : ℕ) : Option Context :=
  match maxSteps with
  | 0 => none  -- failed to stabilize
  | n + 1 =>
    match tactic ctx with
    | none => some ctx  -- stable, no more changes
    | some ctx' =>
      if ctx' == ctx then some ctx  -- reached fixpoint
      else repeatUntilStable tactic ctx' n
```

**Benefits**:
- Prevents infinite tactic loops
- Detects fixpoints
- Provides failure signal when unstable

### 3. Indexed Proof Library Access

**Pattern to Use**: Safe indexing (like `TreeMap.keyAtIdx?`)

**Recommended Implementation**:
```lean
-- Access n-th theorem from sorted library
structure ProofLibrary where
  theorems : Std.TreeMap Formula Derivation formulaOrder
  
def ProofLibrary.getByIndex (lib : ProofLibrary) (n : ℕ) : Option (Formula × Derivation) :=
  lib.theorems.entryAtIdx? n
```

**Benefits**:
- Deterministic theorem enumeration
- Safe access without exceptions
- Useful for property-based testing

### 4. Bounded Unification

**Pattern to Use**: Fuel with early cutoff

**Recommended Implementation**:
```lean
-- Unification with complexity bound
def unify (t1 t2 : Term) (complexityBound : ℕ) : Option Substitution :=
  go t1 t2 complexityBound Substitution.empty
where
  go t1 t2 fuel subst :=
    if fuel = 0 then none
    else if complexity (t1, t2, subst) > complexityBound then none
    else match t1, t2 with
      | .var x, t => ... -- standard unification with fuel - 1
      | ...
```

**Benefits**:
- Prevents unification explosion
- Bounded by both fuel and complexity measure
- Dual termination guarantees

### 5. Proof Term Normalization

**Pattern to Use**: Bounded rewriting (like `runFor`)

**Recommended Implementation**:
```lean
-- Normalize proof term with step limit
def normalize (deriv : Derivation goal) (maxSteps : ℕ) : Option (Derivation goal) :=
  match maxSteps with
  | 0 => some deriv  -- timeout, return current state
  | n + 1 =>
    match deriv.step with  -- try one normalization step
    | none => some deriv  -- normal form reached
    | some deriv' => normalize deriv' n
```

**Benefits**:
- Graceful degradation on timeout
- Guaranteed termination
- Partial results available

## Implementation Best Practices

### 1. Naming Conventions

Based on Lean stdlib patterns:

- **Unsafe/Partial**: `functionPartial` or `function.allowNontermination`
- **Bounded**: `functionFor`, `functionN`, `function?`
- **With Proof**: `functionFin`, `functionWithProof`
- **Internal**: `function.go`, `function.loop`, `functionInternal`

### 2. Default Parameter Strategy

```lean
-- Good: Sensible defaults for bounds
def search (goal : Formula) (depth : ℕ := 100) : Option Derivation := ...

-- Better: Make limits explicit in type
structure SearchConfig where
  maxDepth : ℕ := 100
  maxWidth : ℕ := 50
  timeout : ℕ := 1000

def search (goal : Formula) (config : SearchConfig := {}) : Option Derivation := ...
```

### 3. Productive vs Partial

```lean
-- Partial: No termination guarantee
partial def searchPartial (goal : Formula) : Option Derivation := ...

-- Bounded: Always terminates
def search (goal : Formula) (fuel : ℕ) : Option Derivation := ...

-- Certified: Termination proof
def search [Decidable goal.isProv] (goal : Formula) : Option Derivation := ...
```

### 4. Return Type Refinement

```lean
-- Basic: Simple Option
def getTheorem (n : ℕ) : Option Formula := ...

-- Refined: With validity proof
def getTheorem (n : ℕ) : Option {f : Formula // f.isTheorem} := ...

-- Dependent: Index bounds in type
def getTheorem (lib : Library) (n : Fin lib.size) : Formula := ...
```

### 5. Error Reporting

```lean
-- Better than plain Option: Include reason for failure
inductive SearchError
  | fuelExhausted
  | complexityExceeded
  | noRuleApplicable

def search (goal : Formula) (fuel : ℕ) : Except SearchError Derivation := ...
```

## Testing Strategies

### 1. Property-Based Testing with Fuel

```lean
-- Test that bounded search is monotonic in fuel
property boundedSearch_monotonic (goal : Formula) (n m : ℕ) (h : n ≤ m) :
  (search goal n).isSome → (search goal m).isSome := by
  -- proof that more fuel can't hurt
```

### 2. Timeout Testing

```lean
-- Test that functions respect their bounds
#guard (search complexGoal 0).isNone
#guard (search simpleGoal 1).isSome
#guard (search complexGoal 1000).isSome ∨ (search complexGoal 1000).isNone
```

### 3. Comparison Testing

```lean
-- Test bounded vs unbounded variants agree when bounded succeeds
partial def searchPartial (goal : Formula) : Option Derivation := ...

def search (goal : Formula) (fuel : ℕ) : Option Derivation := ...

property bounded_agrees_with_partial (goal : Formula) (n : ℕ) :
  (search goal n).isSome → search goal n = searchPartial goal := by
  -- proof that bounded version is correct approximation
```

## Related Patterns Not Directly Matching

While searching, I also observed these related patterns that don't match exactly but are worth noting:

1. **`_ → Nat → Nat → Option _`**: Range-based operations (start, end)
2. **`_ → Option Nat → Option _`**: Optional bounds
3. **`Part _`**: Partial computations (alternative to fuel)
4. **`WellFounded`**: Proofs of termination without bounds

## Conclusion

The `_ → _ → Nat → Option _` pattern is predominantly used for **indexed access** to collections (62%), but critically also serves as a **fuel mechanism** for bounded computation (6%). For the ProofChecker project, the fuel-based pattern is most relevant for:

1. Bounded proof search
2. Tactic application limits
3. Term normalization with timeouts
4. Unification complexity bounds

**Key Recommendation**: Adopt the fuel-based pattern from `Computation.runFor` and `Iter.atIdxSlow?` for any proof search or tactic that could potentially loop. This provides:
- **Termination**: Guaranteed by fuel consumption
- **Flexibility**: Users can adjust depth limits
- **Partial Results**: Can return best-effort results on timeout
- **Testing**: Predictable behavior for test cases

**Implementation Priority**:
1. **High**: Bounded proof search tactics
2. **Medium**: Tactic repetition with limits
3. **Low**: Indexed theorem library access

## Appendix: Complete Match List

<details>
<summary>All 68 Matches (Click to Expand)</summary>

1. `List.findIdx?.go`
2. `List.findFinIdx?.go`
3. `List.get?Internal`
4. `Array.findIdx?.loop`
5. `Array.idxOfAux`
6. `BitVec.getLsb?`
7. `BitVec.getMsb?`
8. `ByteArray.findIdx?.loop`
9. `ByteArray.findFinIdx?.loop`
10. `ByteArray.findIdx?`
11. `ByteArray.findFinIdx?`
12. `Std.PRange.UpwardEnumerable.succMany?`
13. `Std.Iterators.Iter.Partial.atIdxSlow?`
14. `Std.Iterators.Iter.atIdxSlow?`
15. `Std.Iterators.Iter.atIdx?`
16. `Vector.findSome?`
17. `Vector.findSomeRev?`
18. `Array.binSearch`
19. `Lean.Order.Example.findF`
20. `Std.DTreeMap.Internal.Impl.keyAtIdx?`
21. `Std.DTreeMap.Internal.Impl.Const.entryAtIdx?`
22. `Std.DTreeMap.Internal.Impl.entryAtIdx?`
23. `Std.DTreeMap.keyAtIdx?`
24. `Std.DTreeMap.Const.entryAtIdx?`
25. `Std.DTreeMap.entryAtIdx?`
26. `Std.DTreeMap.Raw.keyAtIdx?`
27. `Std.DTreeMap.Raw.Const.entryAtIdx?`
28. `Std.DTreeMap.Raw.entryAtIdx?`
29. `Std.TreeMap.keyAtIdx?`
30. `Std.TreeMap.entryAtIdx?`
31. `Std.TreeMap.Raw.keyAtIdx?`
32. `Std.TreeMap.Raw.entryAtIdx?`
33. `Std.TreeSet.atIdx?`
34. `Std.TreeSet.Raw.atIdx?`
35. `Std.ExtDTreeMap.keyAtIdx?`
36. `Std.ExtDTreeMap.Const.entryAtIdx?`
37. `Std.ExtDTreeMap.entryAtIdx?`
38. `Std.ExtTreeMap.keyAtIdx?`
39. `Std.ExtTreeMap.entryAtIdx?`
40. `Std.ExtTreeSet.atIdx?`
41. `Lean.PersistentHashMap.isUnaryEntries`
42. `Lean.PersistentHashMap.findAtAux`
43. `Lean.PersistentHashMap.findEntryAtAux`
44. `Lean.Data.Trie.matchPrefix`
45. `Lean.Diff.Histogram.Entry.leftIndex`
46. `Lean.Diff.Histogram.Entry.rightIndex`
47. `List.ofFnNthVal`
48. `Array.max?`
49. `Array.min?`
50. `Lean.Expr.getArg?`
51. `Lean.Elab.FixedParams.Info.getCallerParam?`
52. `Lean.EditDistance.levenshtein`
53. `Encodable.decode`
54. `Encodable.decode₂`
55. `Encodable.decodeSum`
56. `Encodable.decodeSigma`
57. `Encodable.decodeSubtype`
58. `Encodable.decodeList`
59. `decodeMultiset`
60. `Computation.runFor`
61. `Stream'.Seq.get?`
62. `Nat.Partrec.Code.evaln`
63. `Ordnode.nth`
64. `Ordnode.findIndexAux`
65. `Set.enumerate`
66. `Mathlib.Tactic.Linarith.pelimVar`
67. `Mathlib.Tactic.Linarith.elimVar`
68. `Loogle.Trie.find?.loop`

</details>

## Search Metadata Footer

- **Report Generated**: 2025-12-20
- **Search Engine**: Loogle API v1
- **Total Processing Time**: ~5312 heartbeats
- **Pattern Complexity**: Moderate (4 type parameters with 1 concrete type)
- **Result Quality**: High (68 matches with good coverage across libraries)

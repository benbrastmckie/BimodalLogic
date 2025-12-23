# Loogle Search: Bounded Computation Patterns in Lean Libraries

**Date**: 2025-12-21  
**Purpose**: Comprehensive search for bounded computation patterns where `Nat` controls depth/fuel/iteration limits  
**Target Pattern**: `Nat → α → Option α` and variants

## Executive Summary

This report documents a comprehensive Loogle search for bounded computation patterns in Lean's standard library, Mathlib, and related libraries. The search focused on finding functions and theorems where a `Nat` parameter controls execution depth, fuel consumption, or iteration limits.

**Key Findings**:
- **114 exact/partial matches** for `Nat → _ → Option _` pattern
- **92 matches** for `_ → Nat → Option _` (reversed parameter order)
- **Multiple fuel-based execution patterns** found in Core, Std, and Mathlib
- **Well-documented bounded evaluation semantics** in computability theory modules

## Search Metadata

### Queries Executed

1. `Nat → α → Option α` - ❌ Error (type variable not recognized)
2. `Nat → _ → Option _` - ✅ **114 matches**
3. `α → Nat → Option α` - ❌ Error (type variable not recognized)
4. `_ → Nat → Option _` - ✅ **92 matches**
5. `Nat → α → α` - ❌ Timeout (too general)
6. `fuel` - ✅ **14 matches** (Lean.Elab.Tactic.Do.Fuel system)
7. `runFor` - ✅ **1 match** (Computation.runFor)
8. `evaln` - ✅ **18 matches** (Nat.Partrec.Code.evaln)
9. `iterate` - ✅ **552 matches** (function iteration patterns)
10. `WellFounded` - ✅ **165 matches** (termination proofs)

### Search Limitations

- Loogle doesn't recognize bare type variables (`α`, `β`) in queries
- Must use wildcards (`_`) for generic type matching
- Very general patterns (e.g., `Nat → _ → _`) cause timeouts
- Results limited to first 200 matches for broad queries

---

## 1. Exact Matches: `Nat → Collection → Option Element`

### 1.1 Iterator/Sequence Access Patterns

These functions access the n-th element of a collection, returning `none` if out of bounds:

#### **List/Array Access**
```lean
-- Type: {α : Type u_1} (as : List α) (i : ℕ) : Option α
List.get?Internal
  Module: Init.GetElem
  Description: Internal implementation of `as[i]?`

-- Type: {α : Type u_1} (as : Array α) (i : ℕ) : Option α  
Array.get?
  Module: Init.Data.Array.Basic
  Description: Safe array indexing with bounds checking
```

#### **Bounded Iterator Access**
```lean
-- Type: {α β : Type u_1} [Iterator α Id β] [Productive α Id] (n : ℕ) (it : Iter β) : Option β
Std.Iterators.Iter.atIdxSlow?
  Module: Init.Data.Iterators.Consumers.Access
  Description: Takes n steps with iterator and returns n-th value or none if finished
  **BOUNDED SEMANTICS**: Requires Productive instance proving finite skip termination

-- Type: {α β : Type u_1} [Iterator α Id β] [Productive α Id] [IteratorAccess α Id] (n : ℕ) (it : Iter β) : Option β
Std.Iterators.Iter.atIdx?
  Module: Init.Data.Iterators.Consumers.Access  
  Description: Returns n-th value with optimized access (may take shortcuts)
  **BOUNDED SEMANTICS**: Guaranteed plausible via IterM.IsPlausibleNthOutputStep
```

### 1.2 Tree/Map Index Access

```lean
-- Type: {α β : Type} {cmp : α → α → Ordering} (t : TreeMap α β cmp) (n : ℕ) : Option α
Std.TreeMap.keyAtIdx?
  Module: Std.Data.TreeMap.Basic
  Description: Returns n-th smallest key or none if n ≥ size
  **BOUNDED SEMANTICS**: Index-based bounded access to ordered structure

-- Type: {α β : Type} {cmp : α → α → Ordering} (t : TreeMap α β cmp) (n : ℕ) : Option (α × β)
Std.TreeMap.entryAtIdx?
  Module: Std.Data.TreeMap.Basic
  Description: Returns key-value pair with n-th smallest key
```

### 1.3 BitVector/Binary Operations

```lean
-- Type: {w : ℕ} (x : BitVec w) (i : ℕ) : Option Bool
BitVec.getLsb?
  Module: Init.Data.BitVec.Basic
  Description: Returns i-th least significant bit, or none if i ≥ w
  **BOUNDED SEMANTICS**: Width-bounded bit access

-- Type: {w : ℕ} (x : BitVec w) (i : ℕ) : Option Bool
BitVec.getMsb?
  Module: Init.Data.BitVec.Basic
  Description: Returns i-th most significant bit or none if i ≥ w
```

---

## 2. Reversed Pattern: `Collection → Nat → Option Result`

### 2.1 Enumerable/Encodable Patterns

```lean
-- Type: {α : Type u_1} [Encodable α] : ℕ → Option α
Encodable.decode
  Module: Mathlib.Logic.Encodable.Basic
  Description: Decoding from ℕ to Option α
  **BOUNDED SEMANTICS**: Attempts to decode natural number as encoded value

-- Type: (α : Type u_3) [Encodable α] (n : ℕ) : Option α
Encodable.decode₂
  Module: Mathlib.Logic.Encodable.Basic
  Description: Failsafe variant - returns preimage of n under encode if exists
```

### 2.2 Sequence/Stream Access

```lean
-- Type: {α : Type u} : Stream'.Seq α → ℕ → Option α
Stream'.Seq.get?
  Module: Mathlib.Data.Seq.Defs
  Description: Get nth element of sequence (if it exists)
  **BOUNDED SEMANTICS**: Lazy sequence with index-based access
```

### 2.3 Set Enumeration

```lean
-- Type: {α : Type u_1} (sel : Set α → Option α) : Set α → ℕ → Option α
Set.enumerate
  Module: Mathlib.Data.Set.Enumerate
  Description: Enumerates elements via choice function sel
  **BOUNDED SEMANTICS**: a₀ = sel s, a₁ = sel (s \ {a₀}), ... until sel returns none
```

---

## 3. Fuel-Based Execution Patterns

### 3.1 Lean Do-Notation Fuel System

```lean
-- Type: Type
Lean.Elab.Tactic.Do.Fuel
  Module: Lean.Elab.Tactic.Do.VCGen.Basic
  Variants:
    - Fuel.unlimited : Fuel
    - Fuel.limited (n : ℕ) : Fuel
  
  Usage:
    -- Type: (goal : MVarId) (ctx : Context) (fuel : Fuel) : MetaM Result
    Lean.Elab.Tactic.Do.VCGen.genVCs
```

**Bounded Semantics**: The fuel parameter controls verification condition generation depth, preventing infinite loops in do-notation analysis.

### 3.2 Computation Bounded Execution

```lean
-- Type: {α : Type u} : Computation α → ℕ → Option α
Computation.runFor
  Module: Mathlib.Data.Seq.Computation
  Description: Evaluates c for n steps, returns result or none if not terminated
  **BOUNDED SEMANTICS**: Classic fuel-based execution
    - Input: potentially non-terminating computation
    - Fuel: maximum number of evaluation steps
    - Output: result if terminates within fuel, none otherwise
```

**Usage Pattern**:
```lean
def slowComputation : Computation Nat := ...
-- Run for at most 100 steps
match runFor slowComputation 100 with
| some result => result
| none => "timeout"
```

### 3.3 Partial Recursive Code Evaluation

```lean
-- Type: ℕ → Nat.Partrec.Code → ℕ → Option ℕ
Nat.Partrec.Code.evaln
  Module: Mathlib.Computability.PartrecCode
  Description: Modified evaluation returning Option ℕ instead of Part ℕ
  **BOUNDED SEMANTICS**: Avoids undecidability via fuel parameter k
    - Fails if encounters number ≥ k during execution
    - Otherwise semantics match Nat.Partrec.Code.eval

Key Theorems:
  evaln_sound    : x ∈ evaln k c n → x ∈ c.eval n
  evaln_complete : x ∈ c.eval n ↔ ∃ k, x ∈ evaln k c n
  evaln_mono     : k₁ ≤ k₂ → x ∈ evaln k₁ c n → x ∈ evaln k₂ c n

  -- Relationship to unbounded eval
  eval_eq_rfindOpt : c.eval n = Nat.rfindOpt (λ k => evaln k c n)
```

**Decidability Trade-off**: By introducing fuel bound, evaluation becomes decidable while maintaining correctness (soundness + completeness).

---

## 4. Iteration/Successor Patterns

### 4.1 Function Iteration

```lean
-- Type: {α : Sort u} (op : α → α) : ℕ → α → α  
Nat.iterate
  Module: Mathlib.Logic.Function.Iterate
  Description: Iterate a function n times
  Notation: f^[n] means iterate f n times
  
  Properties:
    - f^[0] = id
    - f^[n+1] = f^[n] ∘ f
    - f^[m+n] = f^[m] ∘ f^[n]
```

### 4.2 Bounded Successor Iteration

```lean
-- Type: {α : Type u} [UpwardEnumerable α] (n : ℕ) (a : α) : Option α
Std.PRange.UpwardEnumerable.succMany?
  Module: Init.Data.Range.Polymorphic.UpwardEnumerable
  Description: Maps elements to their n-th successor, or none if doesn't exist
  **BOUNDED SEMANTICS**: Repeatedly applies succ? n times
    - More efficient than manual iteration
    - Compatible with succ? via LawfulUpwardEnumerable
```

---

## 5. Search/Find with Bounded Depth

### 5.1 Binary Search

```lean
-- Type: {α : Type} (as : Array α) (k : α) (lt : α → α → Bool) (lo hi : ℕ) : Option α
Array.binSearch
  Module: Init.Data.Array.BinSearch
  Description: Binary search in sorted array
  **BOUNDED SEMANTICS**: lo and hi parameters bound search range
    - Both inclusive
    - Default: entire array
```

### 5.2 Ordered Container Search

```lean
-- Type: {α : Type u_1} : Ordnode α → ℕ → Option α
Ordnode.nth
  Module: Mathlib.Data.Ordmap.Ordnode  
  Description: O(log n). Get i-th element of set by index
  Example: nth {a, b, c, d} 2 = some c
  **BOUNDED SEMANTICS**: Index-bounded tree traversal
```

### 5.3 MinSqFac with Bounded Search

```lean
-- Type: ℕ → ℕ → Option ℕ
Nat.minSqFacAux
  Module: Mathlib.Data.Nat.Squarefree
  Description: Assuming n has no factors < k, returns smallest p with p² ∣ n
  **BOUNDED SEMANTICS**: k parameter bounds lower search range
```

---

## 6. Well-Founded Recursion Patterns

### 6.1 Core WellFounded Combinators

```lean
-- Type: {α : Sort u} {C : α → Sort v} {r : α → α → Prop} 
--       (hwf : WellFounded r) 
--       (F : (x : α) → ((y : α) → r y x → C y) → C x) 
--       (x : α) : C x
WellFounded.fix
  Module: Init.WF
  Description: Well-founded fixpoint combinator
  **BOUNDED SEMANTICS**: Structural recursion on accessibility proof
    - Termination guaranteed by well-foundedness
    - No explicit fuel needed
    - Computation bounded by relation structure

-- Type: {α : Sort u} {C : α → Sort v} {r : α → α → Prop}
--       (hwf : WellFounded r)
--       (F : (x : α) → ((y : α) → r y x → C y) → C x)
--       (x : α) : C x  
WellFounded.fixC
  Module: Init.WFComputable
  Description: Computable version of fix
  Theorem: @WellFounded.fix = @WellFounded.fixC
```

### 6.2 Well-Founded Iterator Termination

```lean
-- Type: WellFounded Iter.IsPlausibleSuccessorOf
Std.Iterators.Finite.wf
  Module: Init.Data.Iterators.Basic
  Description: Plausible successor relation is well-founded
  **BOUNDED SEMANTICS**: Guarantees iterator terminates

-- Type: WellFounded IterM.IsPlausibleSkipSuccessorOf  
Std.Iterators.Productive.wf
  Module: Init.Data.Iterators.Basic
  Description: Plausible skip-successor relation is well-founded
  **BOUNDED SEMANTICS**: Guarantees skipping terminates
```

---

## 7. Related Utility Patterns

### 7.1 Bounded Type Conversion

```lean
-- Type: {hi : ℕ} (val : ℕ) : Option (Bounded.LE 0 ↑hi)
Std.Time.Internal.Bounded.LE.ofNat?
  Module: Std.Time.Internal.Bounded
  Description: Convert Nat to bounded type if in range
```

### 7.2 Partial Subtraction

```lean
-- Type: (m : ℕ) : ℕ → Option ℕ
Nat.psub
  Module: Mathlib.Data.Nat.PSub
  Description: Partial subtraction. Returns some k if m = n + k, else none
  **BOUNDED SEMANTICS**: Bounded by "is m ≥ n?"

-- Type: (m n : ℕ) : Option ℕ
Nat.psub'
  Module: Mathlib.Data.Nat.PSub
  Description: More efficient implementation of psub
```

### 7.3 Levenshtein Distance with Cutoff

```lean
-- Type: (str1 str2 : String) (cutoff : ℕ) : Option ℕ
Lean.EditDistance.levenshtein
  Module: Lean.Data.EditDistance
  Description: Computes Levenshtein distance up to cutoff
  **BOUNDED SEMANTICS**: Returns none if distance > cutoff (definitely)
    - some d doesn't guarantee d ≤ cutoff (may exceed)
    - Performance optimization for early termination
```

---

## 8. Library Distribution Analysis

### By Module Family

| Library | Matches | Notable Patterns |
|---------|---------|------------------|
| **Init** (Core) | ~45 | Iterator access, BitVec, ByteArray, basic collections |
| **Std** | ~30 | Tree maps/sets, time bounds, BVDecide fuel |
| **Mathlib** | ~80 | Computability theory, encodables, sequences, ordinals |
| **Lean** | ~15 | Do-notation fuel, edit distance, metaprogramming |
| **Batteries** | ~8 | List utilities, Fin operations |
| **Aesop** | ~2 | Script manipulation |

### By Use Case

| Use Case | Count | Pattern |
|----------|-------|---------|
| **Index Access** | ~40 | `Collection → Nat → Option Element` |
| **Fuel-based Execution** | ~25 | `Nat → Computation → Option Result` |
| **Bounded Encoding/Decoding** | ~15 | `Nat → Option DecodedValue` |
| **Tree/Map Indexing** | ~20 | `Structure → Nat → Option Value` |
| **Iterator nth-element** | ~10 | `Nat → Iterator → Option Element` |
| **Well-Founded Termination** | 165 | No explicit fuel, structural bounds |

---

## 9. Insights: Bounded Computation in Lean

### 9.1 Three Distinct Paradigms

1. **Explicit Fuel** (`Nat` parameter controls steps)
   - `Computation.runFor` - classic fuel pattern
   - `Nat.Partrec.Code.evaln` - bounded partial recursion
   - `Lean.Elab.Tactic.Do.Fuel` - tactic fuel system

2. **Index Bounds** (`Nat` specifies position limit)
   - Most collection access: `List.get?`, `Array.get?`
   - Tree/map indexing: `TreeMap.keyAtIdx?`
   - Iterator access: `Iter.atIdx?`

3. **Structural Bounds** (no explicit `Nat`, uses well-foundedness)
   - `WellFounded.fix` - termination via accessibility
   - `Nat.iterate` - bounded by counter in result type
   - Iterator `Productive`/`Finite` - termination witnesses

### 9.2 Design Patterns

**Pattern 1: Timeout Wrapper**
```lean
-- Run potentially non-terminating computation with fuel
def withTimeout {α} (c : Computation α) (fuel : Nat) : Option α :=
  c.runFor fuel
```

**Pattern 2: Bounded Search**
```lean
-- Search with depth limit
def boundedFind? (p : α → Bool) (fuel : Nat) (start : α) 
    (next : α → α) : Option α :=
  match fuel with
  | 0 => none
  | n+1 => if p start then some start 
           else boundedFind? p n (next start)
```

**Pattern 3: Progressive Deepening**
```lean
-- Try increasing fuel until success or limit
def progressiveSearch (c : Nat → Option α) (maxFuel : Nat) : Option α :=
  (List.range maxFuel).findSome? c
```

### 9.3 Soundness vs. Completeness Trade-offs

**`evaln` Pattern** (Mathlib.Computability.PartrecCode):
- **Soundness**: If `evaln k c n = some x`, then `eval c n = x`
- **Completeness**: If `eval c n = x`, then `∃ k, evaln k c n = some x`
- **Monotonicity**: Larger fuel preserves results
- **Decidability**: Fuel makes evaluation decidable

**Iterator `Productive` Pattern**:
- Proves iterator eventually produces value within finite skips
- Allows bounded access without explicit fuel
- Type-level guarantee of termination

### 9.4 Comparison to Traditional Fuel Patterns

**Lean Advantages**:
1. **Type-safe fuel**: `Fuel` type vs. bare `Nat`
2. **Well-founded alternative**: No fuel needed with structural recursion
3. **Proof-carrying bounds**: `Productive`/`Finite` witness termination
4. **Iterator abstraction**: Separate iteration from fuel management

**Mathlib Sophistication**:
1. **Computability theory**: Formal treatment of partial functions
2. **Encodable framework**: Generic fuel-free encoding/decoding
3. **Well-founded zoo**: Rich library of well-founded relations

---

## 10. Recommendations for Usage

### When to Use Each Pattern

**Use Explicit Fuel When**:
- Working with inherently non-terminating computations
- Need decidable approximation of undecidable problem
- Performance testing/benchmarking
- Interactive/timeout-sensitive contexts

**Use Index Bounds When**:
- Accessing elements in finite collections
- Need bounds-checked safe access
- Working with positions/indices
- Traversing ordered structures

**Use Well-Founded Recursion When**:
- Have structural termination argument
- Want verified total function
- Proof-carrying code required
- No performance penalty acceptable for fuel checks

### Best Practices

1. **Document Fuel Semantics**
   ```lean
   /-- Searches for element satisfying p, using at most `fuel` steps.
       Returns none if not found within fuel limit. -/
   def boundedSearch (p : α → Bool) (fuel : Nat) : Option α := ...
   ```

2. **Provide Unbounded Variant**
   ```lean
   partial def search (p : α → Bool) : α := ...
   def searchBounded (p : α → Bool) (fuel : Nat) : Option α := ...
   ```

3. **Include Fuel Sufficiency Lemmas**
   ```lean
   theorem search_fuel_monotone {k₁ k₂} (h : k₁ ≤ k₂) :
     searchBounded p k₁ = some x → searchBounded p k₂ = some x
   ```

4. **Consider Progressive Deepening**
   ```lean
   def searchWithIncrFuel (p : α → Bool) (init : Nat) (incr : Nat) 
       (maxTries : Nat) : Option α :=
     (List.range maxTries).findSome? fun i =>
       searchBounded p (init + i * incr)
   ```

---

## 11. Specific Examples for ProofChecker

### Example 1: Bounded Proof Search

```lean
-- Based on Computation.runFor pattern
def searchProofBounded (goal : Formula) (fuel : Nat) : Option Derivation :=
  match fuel with
  | 0 => none
  | n+1 => 
    -- Try direct axioms
    if isAxiom goal then some (Axiom goal)
    else
      -- Try inference rules with remaining fuel
      tryInferenceRules goal n

-- Soundness preserved
theorem searchProofBounded_sound (fuel : Nat) :
  searchProofBounded goal fuel = some d → Valid d
```

### Example 2: Iterator-Based Tactic Search

```lean
-- Based on Iter.atIdx? pattern
structure TacticIterator where
  tactics : List Tactic
  currentIdx : Nat

def tryNthTactic (it : TacticIterator) (n : Nat) : Option Derivation :=
  match it.tactics.get? (it.currentIdx + n) with
  | some tac => applyTactic tac
  | none => none
```

### Example 3: Well-Founded Modal Depth

```lean
-- Based on WellFounded.fix pattern
def modalDepth : Formula → Nat
  | atom _ => 0
  | neg φ => modalDepth φ
  | imp φ ψ => max (modalDepth φ) (modalDepth ψ)
  | box φ => modalDepth φ + 1
  | dia φ => modalDepth φ + 1

-- No fuel needed - structurally recursive
-- Termination automatic via Formula's well-founded structure
```

---

## 12. JSON Summary

```json
{
  "type_pattern": "Nat → α → Option α (and variants)",
  "queries_executed": [
    "Nat → _ → Option _",
    "_ → Nat → Option _",
    "fuel",
    "runFor",
    "evaln",
    "iterate",
    "WellFounded"
  ],
  "total_matches": 400+,
  "report_path": ".opencode/specs/ProofChecker/specialist-reports/loogle-bounded-computation-patterns.md",
  "exact_matches": [
    {
      "name": "Computation.runFor",
      "type": "{α : Type u} : Computation α → ℕ → Option α",
      "library": "Mathlib",
      "module": "Mathlib.Data.Seq.Computation",
      "description": "Classic fuel-based execution: evaluates for n steps, returns result or none"
    },
    {
      "name": "Nat.Partrec.Code.evaln",
      "type": "ℕ → Nat.Partrec.Code → ℕ → Option ℕ",
      "library": "Mathlib",
      "module": "Mathlib.Computability.PartrecCode",
      "description": "Bounded evaluation for partial recursive functions with soundness/completeness theorems"
    },
    {
      "name": "Std.Iterators.Iter.atIdxSlow?",
      "type": "{α β : Type u_1} [Iterator α Id β] [Productive α Id] (n : ℕ) (it : Iter β) : Option β",
      "library": "Std",
      "module": "Init.Data.Iterators.Consumers.Access",
      "description": "Takes n steps with iterator, returns nth value or none if finished early"
    },
    {
      "name": "Lean.Elab.Tactic.Do.Fuel",
      "type": "Type (with unlimited | limited n constructors)",
      "library": "Lean",
      "module": "Lean.Elab.Tactic.Do.VCGen.Basic",
      "description": "Type-safe fuel for do-notation verification condition generation"
    }
  ],
  "partial_matches": [
    {
      "pattern": "Collection → Nat → Option Element",
      "examples": [
        "List.get?Internal",
        "Array.get?",
        "TreeMap.keyAtIdx?",
        "Ordnode.nth"
      ],
      "use_case": "Index-based bounded access to collections"
    },
    {
      "pattern": "Nat → Encodable → Option Decoded",
      "examples": [
        "Encodable.decode",
        "Encodable.decode₂"
      ],
      "use_case": "Bounded encoding/decoding schemes"
    }
  ],
  "related_patterns": [
    {
      "pattern": "Nat.iterate {α} (op : α → α) : ℕ → α → α",
      "examples": ["f^[n] notation", "iterate_add", "iterate_comm"],
      "use_case": "Function iteration without Option - fuel in result type"
    },
    {
      "pattern": "WellFounded.fix",
      "examples": ["fix", "fixC", "recursion", "induction"],
      "use_case": "Structurally bounded recursion without explicit fuel"
    },
    {
      "pattern": "Productive/Finite witnesses",
      "examples": ["Finite.wf", "Productive.wf"],
      "use_case": "Type-level termination guarantees for iterators"
    }
  ],
  "insights": "Lean libraries use THREE distinct bounded computation paradigms: (1) Explicit fuel with Nat parameter (runFor, evaln), (2) Index bounds for collection access (get?, atIdx?), and (3) Structural bounds via WellFounded recursion (fix, iterate). The Mathlib.Computability module provides the most sophisticated treatment with soundness/completeness theorems for bounded evaluation of partial recursive functions. The Std.Iterators framework innovates with type-level termination witnesses (Productive/Finite) that eliminate explicit fuel while guaranteeing termination."
}
```

---

## Appendix A: Complete Function Signatures

### Fuel-Based Execution
```lean
Computation.runFor : {α : Type u} → Computation α → ℕ → Option α
Nat.Partrec.Code.evaln : ℕ → Nat.Partrec.Code → ℕ → Option ℕ
Lean.Elab.Tactic.Do.Fuel : Type
  .unlimited : Fuel
  .limited (n : ℕ) : Fuel
```

### Iterator Access
```lean
Std.Iterators.Iter.atIdxSlow? : 
  {α β : Type u_1} [Iterator α Id β] [Productive α Id] → 
  ℕ → Iter β → Option β

Std.Iterators.Iter.atIdx? :
  {α β : Type u_1} [Iterator α Id β] [Productive α Id] [IteratorAccess α Id] →
  ℕ → Iter β → Option β
```

### Collection Access
```lean
List.get?Internal : {α : Type u_1} → List α → ℕ → Option α
Array.get? : {α : Type u_1} → Array α → ℕ → Option α
TreeMap.keyAtIdx? : {α β : Type} {cmp : α → α → Ordering} → TreeMap α β cmp → ℕ → Option α
Ordnode.nth : {α : Type u_1} → Ordnode α → ℕ → Option α
```

### Well-Founded Recursion
```lean
WellFounded.fix : 
  {α : Sort u} {C : α → Sort v} {r : α → α → Prop} →
  (hwf : WellFounded r) →
  (F : (x : α) → ((y : α) → r y x → C y) → C x) →
  (x : α) → C x

WellFounded.fixC :
  {α : Sort u} {C : α → Sort v} {r : α → α → Prop} →
  (hwf : WellFounded r) →
  (F : (x : α) → ((y : α) → r y x → C y) → C x) →
  (x : α) → C x
```

---

## Appendix B: Key Theorems

### evaln Correctness
```lean
-- If bounded eval succeeds, unbounded eval produces same result
evaln_sound : {k c n x : ℕ} → x ∈ evaln k c n → x ∈ c.eval n

-- If unbounded eval succeeds, there exists sufficient fuel
evaln_complete : {c n x : ℕ} → x ∈ c.eval n ↔ ∃ k, x ∈ evaln k c n

-- More fuel preserves results
evaln_mono : {k₁ k₂ c n x : ℕ} → k₁ ≤ k₂ → x ∈ evaln k₁ c n → x ∈ evaln k₂ c n

-- Relationship to unbounded evaluation
eval_eq_rfindOpt : (c : Code) (n : ℕ) → c.eval n = Nat.rfindOpt (λ k => evaln k c n)
```

### Iterate Properties
```lean
iterate_zero : {α : Type u} (f : α → α) → f^[0] = id
iterate_succ : {α : Type u} (f : α → α) (n : ℕ) → f^[n.succ] = f^[n] ∘ f
iterate_add : {α : Type u} (f : α → α) (m n : ℕ) → f^[m + n] = f^[m] ∘ f^[n]
iterate_comm : {α : Type u} (f : α → α) (m n : ℕ) → f^[n]^[m] = f^[m]^[n]
```

---

## References

1. **Loogle Search Engine**: https://loogle.lean-lang.org/
2. **Mathlib Documentation**: https://leanprover-community.github.io/mathlib4_docs/
3. **Init Library Source**: Lean 4 core library
4. **Std Library**: Lean 4 standard library
5. **Computability Theory in Mathlib**: Mathlib.Computability.PartrecCode
6. **Iterator Framework**: Init.Data.Iterators

---

**Report Generated**: 2025-12-21  
**Total Functions Analyzed**: 400+  
**Distinct Patterns Identified**: 15+  
**Libraries Covered**: Init, Std, Mathlib, Lean, Batteries, Aesop

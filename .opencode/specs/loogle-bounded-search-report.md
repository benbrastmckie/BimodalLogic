# Loogle Search Results: Bounded Proof Search Signatures

**Search Date**: 2025-12-20  
**Target Pattern**: `Context → Formula → Nat → Bool`  
**Purpose**: Find bounded proof search function signatures in Mathlib/Std  
**Total Searches**: 4 type patterns

---

## Executive Summary

Searched for functions matching bounded proof search signatures (taking a context, formula, and depth bound). **No exact matches** were found for `Context → Formula → Nat → Bool` in the standard Lean libraries, indicating this is a domain-specific signature for the ProofChecker project.

However, found **92 relevant functions** with the pattern `_ → Nat → Bool` and **50 functions** with `_ → _ → Nat → Bool` that demonstrate common bounded search and depth-checking patterns in Lean.

---

## Search Pattern 1: Context → Formula → Nat → Bool (Exact)

### Matches Found: 0

**Result**: No direct matches in Mathlib or Std libraries.

**Analysis**: The combination of `Context` and `Formula` types with a `Nat` bound returning `Bool` is specific to proof systems and not present in the standard library. This signature would be custom to the ProofChecker/Logos project.

**Loogle Suggestions**: The search suggested various `Context` types from Lean's standard library:
- `Lean.Macro.Context`
- `Lean.Meta.Context`
- `Lean.Elab.Context`
- `Lean.Parser.ParserContext`

None of these are combined with formula types and depth bounds.

---

## Search Pattern 2: _ → _ → Nat → Bool (Wildcard)

### Matches Found: 50

This pattern captures functions taking two parameters plus a natural number bound, returning Bool. Most relevant for understanding bounded operations:

### Array/Collection Operations

1. **Array.all** : `{α : Type u} (as : Array α) (p : α → Bool) (start : Nat := 0) (stop : Nat := as.size) : Bool`
   - Library: Init
   - Module: Init.Data.Array.Basic
   - Description: Returns `true` if `p` returns `true` for every element. Short-circuits on first `false`.
   - **Relevance**: Bounded iteration with start/stop indices

2. **Array.any** : `{α : Type u} (as : Array α) (p : α → Bool) (start : Nat := 0) (stop : Nat := as.size) : Bool`
   - Library: Init
   - Module: Init.Data.Array.Basic
   - Description: Returns `true` if `p` returns `true` for any element. Short-circuits on first `true`.
   - **Relevance**: Bounded search with early termination

3. **Array.isPrefixOfAux** : `{α : Type u} [BEq α] (as bs : Array α) (hle : as.size ≤ bs.size) (i : Nat) : Bool`
   - Library: Init
   - Module: Init.Data.Array.Basic
   - Description: Auxiliary function for prefix checking with index parameter
   - **Relevance**: Recursive bounded comparison

4. **Array.isEqvAux** : `{α : Type u} (xs ys : Array α) (hsz : xs.size = ys.size) (p : α → α → Bool) (i : Nat) : i ≤ xs.size → Bool`
   - Library: Init
   - Module: Init.Data.Array.Basic
   - Description: Auxiliary equivalence checking with index bound
   - **Relevance**: Bounded recursive equivalence check

5. **Array.binSearchContains** : `{α : Type} (as : Array α) (k : α) (lt : α → α → Bool) (lo : Nat := 0) (hi : Nat := as.size - 1) : Bool`
   - Library: Init
   - Module: Init.Data.Array.BinSearch
   - Description: Binary search with explicit bounds
   - **Relevance**: Bounded search with range parameters

### BitVector Operations

6. **BitVec.getLsbD** : `{w : Nat} (x : BitVec w) (i : Nat) : Bool`
   - Library: Init
   - Module: Init.Data.BitVec.Basic
   - Description: Returns the `i`th least significant bit or `false` if `i ≥ w`
   - **Relevance**: Depth-indexed access with bounds checking

7. **BitVec.getMsbD** : `{w : Nat} (x : BitVec w) (i : Nat) : Bool`
   - Library: Init
   - Module: Init.Data.BitVec.Basic
   - Description: Returns the `i`th most significant bit, or `false` if `i ≥ w`
   - **Relevance**: Depth-indexed access with bounds checking

8. **BitVec.uppcRec** : `{w : Nat} (x : BitVec w) (s : Nat) (hs : s < w) : Bool`
   - Library: Init
   - Module: Init.Data.BitVec.Bitblast
   - Description: Unsigned parallel prefix with step parameter
   - **Relevance**: Recursive computation with depth bound

9. **BitVec.aandRec** : `{w : Nat} (x y : BitVec w) (s : Nat) (hs : s < w) : Bool`
   - Library: Init
   - Module: Init.Data.BitVec.Bitblast
   - Description: Conjunction for fast overflow circuit with step parameter
   - **Relevance**: Recursive operation with depth tracking

10. **BitVec.resRec** : `{w : Nat} (x y : BitVec w) (s : Nat) (hs : s < w) (hslt : 0 < s) : Bool`
    - Library: Init
    - Module: Init.Data.BitVec.Bitblast
    - Description: Preliminary overflow flag with step bounds
    - **Relevance**: Multi-step recursive computation

### String Operations

11. **String.substrEq** : `(s1 : String) (pos1 : String.Pos.Raw) (s2 : String) (pos2 : String.Pos.Raw) (sz : Nat) : Bool`
    - Library: Init
    - Module: Init.Data.String.Basic
    - Description: Substring equality with size bound
    - **Relevance**: Bounded comparison with length parameter

12. **String.Pos.Raw.substrEq** : `(s1 : String) (pos1 : String.Pos.Raw) (s2 : String) (pos2 : String.Pos.Raw) (sz : Nat) : Bool`
    - Library: Init
    - Module: Init.Data.String.Basic
    - Description: Checks substring equality using UTF-8 byte positions with size bound
    - **Relevance**: Bounded string matching

### Vector Operations

13. **Vector.isPrefixOf** : `{α : Type u_1} {m n : Nat} [BEq α] (xs : Vector α m) (ys : Vector α n) : Bool`
    - Library: Init
    - Module: Init.Data.Vector.Basic
    - Description: Returns `true` when `xs` is a prefix of vector `ys`
    - **Relevance**: Length-bounded prefix checking

### Lean Internals

14. **Lean.Data.AC.ContextInformation.isNeutral** : `{α : Sort u} [self : Lean.Data.AC.ContextInformation α] : α → Nat → Bool`
    - Library: Init
    - Module: Init.Data.AC
    - Description: Checks neutrality at specific index
    - **Relevance**: Context-based indexed checking

15. **Lean.Syntax.isNodeOf** : `(stx : Lean.Syntax) (k : Lean.SyntaxNodeKind) (n : Nat) : Bool`
    - Library: Init
    - Module: Init.Prelude
    - Description: Is this syntax a `node` with kind `k`?
    - **Relevance**: Syntax checking with arity parameter

### Integer Linear Programming

16. **Int.Linear.cooper_left_cert** : `(p₁ p₂ : Int.Linear.Poly) (n : Nat) : Bool`
    - Library: Init
    - Module: Init.Data.Int.Linear
    - Description: Cooper's algorithm certificate checking
    - **Relevance**: Quantifier elimination with step parameter

17. **Int.Linear.cooper_right_cert** : `(p₁ p₂ : Int.Linear.Poly) (n : Nat) : Bool`
    - Library: Init
    - Module: Init.Data.Int.Linear
    - Description: Cooper's algorithm certificate checking (right)
    - **Relevance**: Quantifier elimination with step parameter

### Pattern Summary for `_ → _ → Nat → Bool`

**Common Use Cases**:
1. **Bounded iteration**: Array/Vector operations with start/stop indices
2. **Depth-indexed access**: BitVec operations accessing specific depths
3. **Recursive computation**: Functions using Nat as step/recursion counter
4. **Size-bounded comparison**: String/Array equality with length bounds
5. **Certificate checking**: Proof/solver certificates with step parameters

**Key Insight**: The `Nat` parameter typically serves as:
- An **index** into a structure
- A **bound** for iteration/search
- A **step counter** for recursive algorithms
- A **depth limit** for tree/graph traversal

---

## Search Pattern 3: Nat → Bool (Depth Predicates)

### Matches Found: 201 (showing most relevant)

This pattern captures simple predicates on natural numbers, useful for depth checking and bounds validation.

### Core Natural Number Predicates

1. **Nat.beq** : `Nat → Nat → Bool`
   - Library: Init
   - Module: Init.Prelude
   - Description: Boolean equality, accessed via `==` operator
   - **Relevance**: Basic depth comparison

2. **Nat.ble** : `Nat → Nat → Bool`
   - Library: Init
   - Module: Init.Prelude
   - Description: Boolean less-than-or-equal-to comparison
   - **Relevance**: Depth bound checking

3. **Nat.blt** : `(a b : Nat) : Bool`
   - Library: Init
   - Module: Init.Data.Nat.Basic
   - Description: Boolean less-than comparison
   - **Relevance**: Strict depth bound checking

4. **Nat.testBit** : `(m n : Nat) : Bool`
   - Library: Init
   - Module: Init.Data.Nat.Bitwise.Basic
   - Description: Returns `true` if the `(n+1)`th least significant bit is `1`
   - **Relevance**: Bit-level depth checking

### Bounded Iteration Functions

5. **Nat.all** : `(n : Nat) (f : (i : Nat) → i < n → Bool) : Bool`
   - Library: Init
   - Module: Init.Data.Nat.Fold
   - Description: Checks whether `f` returns `true` for every number strictly less than a bound
   - **Relevance**: Universal quantification with depth bound

6. **Nat.allTR** : `(n : Nat) (f : (i : Nat) → i < n → Bool) : Bool`
   - Library: Init
   - Module: Init.Data.Nat.Fold
   - Description: Tail-recursive equivalent of `Nat.all` used at runtime
   - **Relevance**: Efficient bounded universal check

7. **Nat.any** : `(n : Nat) (f : (i : Nat) → i < n → Bool) : Bool`
   - Library: Init
   - Module: Init.Data.Nat.Fold
   - Description: Checks whether there is some number less than the bound for which `f` returns `true`
   - **Relevance**: Existential quantification with depth bound

8. **Nat.anyTR** : `(n : Nat) (f : (i : Nat) → i < n → Bool) : Bool`
   - Library: Init
   - Module: Init.Data.Nat.Fold
   - Description: Tail-recursive equivalent of `Nat.any` used at runtime
   - **Relevance**: Efficient bounded existential check

### Range Predicates

9. **Prod.allI** : `(i : Nat × Nat) (f : (j : Nat) → i.1 ≤ j → j < i.2 → Bool) : Bool`
   - Library: Init
   - Module: Init.Data.Nat.Fold
   - Description: Checks whether a predicate holds for all natural numbers in a range
   - **Relevance**: Range-bounded universal quantification

10. **Prod.anyI** : `(i : Nat × Nat) (f : (j : Nat) → i.1 ≤ j → j < i.2 → Bool) : Bool`
    - Library: Init
    - Module: Init.Data.Nat.Fold
    - Description: Checks whether a predicate holds for any natural number in a range
    - **Relevance**: Range-bounded existential quantification

### BitVector Predicates

11. **BitVec.msb** : `{n : Nat} (x : BitVec n) : Bool`
    - Library: Init
    - Module: Init.Data.BitVec.Basic
    - Description: Returns the most significant bit
    - **Relevance**: Top-level bit checking

12. **BitVec.negOverflow** : `{w : Nat} (x : BitVec w) : Bool`
    - Library: Init
    - Module: Init.Data.BitVec.Basic
    - Description: Checks whether negation results in overflow
    - **Relevance**: Overflow detection

13. **BitVec.saddOverflow** : `{w : Nat} (x y : BitVec w) : Bool`
    - Library: Init
    - Module: Init.Data.BitVec.Basic
    - Description: Checks whether addition results in signed overflow
    - **Relevance**: Arithmetic overflow detection

14. **BitVec.sdivOverflow** : `{w : Nat} (x y : BitVec w) : Bool`
    - Library: Init
    - Module: Init.Data.BitVec.Basic
    - Description: Checks whether signed division results in overflow
    - **Relevance**: Division overflow detection

15. **BitVec.sle** : `{n : Nat} (x y : BitVec n) : Bool`
    - Library: Init
    - Module: Init.Data.BitVec.Basic
    - Description: Signed less-than-or-equal-to for bitvectors
    - **Relevance**: Signed comparison

16. **BitVec.slt** : `{n : Nat} (x y : BitVec n) : Bool`
    - Library: Init
    - Module: Init.Data.BitVec.Basic
    - Description: Signed less-than for bitvectors
    - **Relevance**: Signed strict comparison

### String/ByteArray Validation

17. **ByteArray.validateUTF8At** : `(bytes : ByteArray) (i : Nat) : Bool`
    - Library: Init
    - Module: Init.Data.String.Decode
    - Description: UTF-8 validation at specific index
    - **Relevance**: Index-based validation

### Vector Predicates

18. **Vector.all** : `{α : Type u_1} {n : Nat} (xs : Vector α n) (p : α → Bool) : Bool`
    - Library: Init
    - Module: Init.Data.Vector.Basic
    - Description: Returns `true` if `p` returns `true` for all elements
    - **Relevance**: Universal quantification over fixed-length vectors

### Lean Meta/Compiler Functions

19. **Lean.Meta.Occurrences.contains** : `Lean.Meta.Occurrences → Nat → Bool`
    - Library: Init
    - Module: Init.Meta.Defs
    - Description: Checks if occurrence set contains index
    - **Relevance**: Occurrence tracking

20. **Lean.Syntax.matchesNull** : `(stx : Lean.Syntax) (n : Nat) : Bool`
    - Library: Init
    - Module: Init.Prelude
    - Description: Is this syntax a null `node`?
    - **Relevance**: Syntax arity checking

21. **Lean.Expr.hasLooseBVar** : `(e : Lean.Expr) (bvarIdx : Nat) : Bool`
    - Library: Lean
    - Module: Lean.Expr
    - Description: Checks if expression has loose bound variable at index
    - **Relevance**: Variable depth checking in expressions

### Integer/Numeric Bit Testing

22. **Int.testBit** : `Int → Nat → Bool`
    - Library: Init
    - Module: Init.Data.Int.Bitwise
    - Description: Test bit at position in integer
    - **Relevance**: Bit-level integer inspection

23. **Num.testBit** : `Num → Nat → Bool`
    - Library: Init
    - Module: Init.Data.Num.Bitwise
    - Description: Test bit at position in Num
    - **Relevance**: Bit-level numeric inspection

24. **PosNum.testBit** : `PosNum → Nat → Bool`
    - Library: Init
    - Module: Init.Data.Num.Bitwise
    - Description: Test bit at position in PosNum
    - **Relevance**: Bit-level positive number inspection

### Pattern Summary for `Nat → Bool`

**Common Use Cases**:
1. **Comparison predicates**: `beq`, `ble`, `blt` for depth bounds
2. **Bounded iteration**: `Nat.all`, `Nat.any` for checking all/some values up to bound
3. **Range predicates**: `Prod.allI`, `Prod.anyI` for range-bounded checks
4. **Bit testing**: `testBit` functions for bit-level inspection
5. **Index validation**: Checking if index is within bounds
6. **Overflow detection**: BitVec overflow predicates

**Key Insight**: These functions are fundamental building blocks for:
- **Depth-bounded search**: Using `Nat.any` with depth limit
- **Iterative deepening**: Incrementing depth bound with `Nat.all`
- **Termination checking**: Ensuring recursion stays within bounds
- **Index validation**: Verifying array/vector access is safe

---

## Search Pattern 4: _ → Nat → Bool (General Bounded)

### Matches Found: 92

This is a subset of the `Nat → Bool` results, focusing on functions with at least one additional parameter before the Nat. The most relevant functions are:

### Syntax/Expression Checking

1. **Lean.Syntax.matchesNull** : `(stx : Lean.Syntax) (n : Nat) : Bool`
   - Checks if syntax is null node with specific arity

2. **Lean.Expr.hasLooseBVar** : `(e : Lean.Expr) (bvarIdx : Nat) : Bool`
   - Checks for loose bound variables at depth

### Bit-Level Operations

3. **BitVec.getLsbD** : `{w : Nat} (x : BitVec w) (i : Nat) : Bool`
   - Get least significant bit at depth

4. **BitVec.getMsbD** : `{w : Nat} (x : BitVec w) (i : Nat) : Bool`
   - Get most significant bit at depth

5. **Int.testBit** : `Int → Nat → Bool`
   - Test integer bit at position

6. **Num.testBit** : `Num → Nat → Bool`
   - Test Num bit at position

7. **PosNum.testBit** : `PosNum → Nat → Bool`
   - Test PosNum bit at position

### Compiler/Meta Functions

Multiple compiler and meta-level functions for checking properties at specific depths or indices in expressions, syntax trees, and data structures.

---

## Recommendations for Bounded Proof Search

Based on the Loogle search results, here are recommendations for implementing bounded proof search in ProofChecker:

### 1. Pattern Inspiration from Mathlib/Std

**Use `Nat.any` pattern for existential search**:
```lean
-- Similar to: Nat.any (n : Nat) (f : (i : Nat) → i < n → Bool) : Bool
def boundedProofSearch (ctx : Context) (goal : Formula) (maxDepth : Nat) : Bool :=
  Nat.any maxDepth (fun depth _ => canProveAtDepth ctx goal depth)
```

**Use `Nat.all` pattern for universal checking**:
```lean
-- Similar to: Nat.all (n : Nat) (f : (i : Nat) → i < n → Bool) : Bool
def allDepthsValid (ctx : Context) (goal : Formula) (maxDepth : Nat) : Bool :=
  Nat.all maxDepth (fun depth _ => isValidAtDepth ctx goal depth)
```

### 2. Auxiliary Function Pattern

Follow the `*Aux` pattern from Array operations for recursive bounded search:

```lean
-- Main function
def boundedProofSearch (ctx : Context) (goal : Formula) (maxDepth : Nat) : Bool :=
  boundedProofSearchAux ctx goal 0 maxDepth

-- Auxiliary with current depth
def boundedProofSearchAux (ctx : Context) (goal : Formula) (depth : Nat) (maxDepth : Nat) : Bool :=
  if depth ≥ maxDepth then
    false
  else
    -- Try proof at current depth or recurse
    tryProofAtDepth ctx goal depth || boundedProofSearchAux ctx goal (depth + 1) maxDepth
```

### 3. Short-Circuit Evaluation

Follow `Array.any` pattern for early termination:

```lean
-- Short-circuit on first success
def boundedProofSearch (ctx : Context) (goal : Formula) (maxDepth : Nat) : Bool :=
  (List.range maxDepth).any (fun depth => canProveAtDepth ctx goal depth)
```

### 4. Tail-Recursive Implementation

Follow `Nat.anyTR` pattern for efficiency:

```lean
-- Tail-recursive version for runtime efficiency
def boundedProofSearchTR (ctx : Context) (goal : Formula) (maxDepth : Nat) : Bool :=
  let rec loop (depth : Nat) : Bool :=
    if depth ≥ maxDepth then
      false
    else if canProveAtDepth ctx goal depth then
      true
    else
      loop (depth + 1)
  loop 0
```

### 5. Range-Based Search

Follow `Prod.anyI` pattern for range-bounded search:

```lean
-- Search within depth range
def rangeProofSearch (ctx : Context) (goal : Formula) (minDepth maxDepth : Nat) : Bool :=
  (minDepth, maxDepth).anyI (fun depth _ _ => canProveAtDepth ctx goal depth)
```

### 6. Type Signature Recommendation

For ProofChecker bounded search functions, use:

```lean
-- Primary signature
def boundedProofSearch : Context → Formula → Nat → Bool

-- With proof witness (if needed)
def boundedProofSearchWithWitness : Context → Formula → Nat → Option Derivation

-- Auxiliary with current depth
def boundedProofSearchAux : Context → Formula → Nat → Nat → Bool
--                                                  ↑      ↑
--                                            current  max
```

### 7. Integration with Existing Patterns

The search reveals that bounded operations in Lean typically:
- Use `Nat` for depth/bound parameters
- Return `Bool` for decision procedures
- Provide both direct and tail-recursive versions
- Include auxiliary functions with explicit depth tracking
- Support early termination via short-circuit evaluation

---

## Conclusion

While the exact signature `Context → Formula → Nat → Bool` is not present in Mathlib/Std (as expected for domain-specific proof search), the Lean ecosystem provides excellent patterns for bounded operations:

1. **`Nat.any`/`Nat.all`** - Universal patterns for bounded iteration
2. **`*Aux` functions** - Explicit depth tracking in recursion
3. **Tail-recursive variants** - Runtime efficiency
4. **Short-circuit evaluation** - Early termination
5. **Range-based operations** - Flexible bound specification

These patterns should guide the implementation of bounded proof search in ProofChecker, ensuring consistency with Lean's standard library conventions while maintaining efficiency and clarity.

---

**Report Generated**: 2025-12-20  
**Search Tool**: Loogle API via MCP  
**Total Functions Analyzed**: 343 unique signatures  
**Most Relevant Pattern**: `Nat.any` for bounded existential search

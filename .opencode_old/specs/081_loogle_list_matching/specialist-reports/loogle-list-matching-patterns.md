# Loogle Search Results: List Matching and Predicate Functions

**Type Pattern**: `List _ → _ → Bool` and related patterns  
**Date**: 2025-12-20  
**Total Searches Executed**: 9  
**Total Unique Matches**: 200+ functions and lemmas  
**Context**: Finding functions for axiom matching and pattern matching in LEAN 4 proof system

---

## Executive Summary

This comprehensive Loogle search identified the core list matching and predicate functions available in Lean 4's standard library. Key findings:

1. **Primary membership predicates**: `List.elem` and `List.contains` (both require `[BEq α]`)
2. **Predicate-based search**: `List.any` (existential) and `List.all` (universal)
3. **Find functions**: `List.find?`, `List.findIdx?`, `List.findFinIdx?` (all return `Option`)
4. **Important note**: Lean 4 uses the `∈` operator for membership, not a `List.mem` function
5. **All sources**: Primarily from `Init.Data.List.Basic` (Lean core library)

---

## Search Results by Category

### 1. Exact Membership Tests

#### 1.1 List.elem
**Type**: `{α : Type u} [BEq α] (a : α) (l : List α) : Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`  
**Matches Found**: 22

**Description**: Checks if an element is in a list using boolean equality (`BEq`). Takes the element first, then the list.

**Usage Pattern**:
```lean
-- Check if 3 is in the list [1, 2, 3, 4]
#eval [1, 2, 3, 4].elem 3  -- true
```

**Key Lemmas**:
- `elem_nil`: Element is never in empty list
- `elem_cons`: Element in cons relates to head equality or tail membership
- `elem_eq_contains`: Equivalence with `List.contains`
- `elem_iff`: Relationship with membership operator `∈`
- `elem_eq_mem`: Direct equivalence with `∈`

**Recommendation**: Use `List.elem` when you have an element and want to check membership with boolean result.

---

#### 1.2 List.contains
**Type**: `{α : Type u} [BEq α] (as : List α) (a : α) : Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`  
**Matches Found**: 902 (showing first 200)

**Description**: Checks if a list contains an element using boolean equality. Takes the list first, then the element. This is the flip of `List.elem`.

**Usage Pattern**:
```lean
-- Check if [1, 2, 3, 4] contains 3
#eval [1, 2, 3, 4].contains 3  -- true
```

**Key Lemmas** (extensive support across multiple modules):
- `contains_nil`: Empty list contains nothing
- `contains_cons`: Contains in cons relates to head equality or tail contains
- Interactions with: `reverse`, `append`, `map`, `filter`, `replicate`, `take`, `drop`
- Extensive Mathlib support for theorems about `contains`

**Recommendation**: Use `List.contains` when you have a list and want to check if it contains an element. Preferred for method-style syntax (`list.contains elem`).

---

#### 1.3 Membership Operator (∈)
**Type**: Infix operator, not a function  
**Library**: Init (Lean core)  
**Module**: Various

**Description**: The standard membership operator in Lean 4. `List.mem` does not exist as a function in Lean 4.

**Usage Pattern**:
```lean
-- Check if 3 is in the list [1, 2, 3, 4]
#eval 3 ∈ [1, 2, 3, 4]  -- true (requires Decidable instance)
```

**Relationship**:
- `elem a l ↔ a ∈ l` (when `BEq` matches `Eq`)
- `contains l a ↔ a ∈ l` (when `BEq` matches `Eq`)

**Recommendation**: Use `∈` for theorem proving and when you need propositional membership. Use `elem`/`contains` for boolean computation.

---

### 2. Predicate-Based Search Functions

#### 2.1 List.any
**Type**: `{α : Type u} (l : List α) (p : α → Bool) : Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`  
**Matches Found**: 79

**Description**: Returns `true` if any element in the list satisfies the predicate. Existential quantification over the list.

**Usage Pattern**:
```lean
-- Check if any element is even
#eval [1, 3, 5, 6].any (fun x => x % 2 == 0)  -- true

-- Check if any formula matches a pattern
def matchesPattern (f : Formula) : Bool := sorry
#eval axioms.any matchesPattern
```

**Key Lemmas**:
- `any_eq_true`: `any l p = true ↔ ∃ x ∈ l, p x = true`
- `any_eq_false`: `any l p = false ↔ ∀ x ∈ l, p x = false`
- Interactions with: `reverse`, `append`, `map`, `filter`, `flatten`, `replicate`
- Relationship with `all`: `all p l = !any (fun x => !p x) l`

**Recommendation**: Use `List.any` for existential searches over lists. Perfect for "does any axiom match this pattern?" queries.

---

#### 2.2 List.all
**Type**: `{α : Type u} : List α → (α → Bool) → Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`  
**Matches Found**: 66

**Description**: Returns `true` if all elements in the list satisfy the predicate. Universal quantification over the list.

**Usage Pattern**:
```lean
-- Check if all elements are positive
#eval [1, 2, 3, 4].all (fun x => x > 0)  -- true

-- Check if all formulas are well-formed
def isWellFormed (f : Formula) : Bool := sorry
#eval formulas.all isWellFormed
```

**Key Lemmas**:
- `all_eq_true`: `all l p = true ↔ ∀ x ∈ l, p x = true`
- `all_eq_false`: `all l p = false ↔ ∃ x ∈ l, p x = false`
- `all_eq_not_any_not`: Duality with `any`
- Interactions with: `reverse`, `append`, `map`, `filter`, `replicate`

**Recommendation**: Use `List.all` for universal checks over lists. Useful for validation and invariant checking.

---

### 3. Find Functions (Return Option)

#### 3.1 List.find?
**Type**: `{α : Type u} (p : α → Bool) : List α → Option α`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`  
**Matches Found**: 57 (for pattern `List _ → _ → Option _`)

**Description**: Returns the first element satisfying the predicate, or `none` if no element matches. Note the `?` suffix - there is no `List.find` function.

**Usage Pattern**:
```lean
-- Find first even number
#eval [1, 3, 5, 6, 8].find? (fun x => x % 2 == 0)  -- some 6

-- Find first matching axiom
def matchesAxiom (f : Formula) : Bool := sorry
match axioms.find? matchesAxiom with
| some axiom => -- found matching axiom
| none => -- no match
```

**Key Lemmas**:
- `find?_some`: Characterizes when result is `some`
- `find?_none`: Characterizes when result is `none`
- `find?_eq_none`: Equivalent to `all l (fun x => !p x)`

**Recommendation**: Use `List.find?` when you need the actual matching element, not just a boolean. Perfect for axiom lookup.

---

#### 3.2 List.findIdx?
**Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option ℕ`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`

**Description**: Returns the index of the first element satisfying the predicate, or `none` if no element matches.

**Usage Pattern**:
```lean
-- Find index of first even number
#eval [1, 3, 5, 6, 8].findIdx? (fun x => x % 2 == 0)  -- some 3

-- Find position of matching axiom
match axioms.findIdx? matchesAxiom with
| some idx => -- found at position idx
| none => -- no match
```

**Recommendation**: Use when you need the position of a matching element.

---

#### 3.3 List.findFinIdx?
**Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option (Fin l.length)`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`

**Description**: Returns a `Fin` index (bounded natural number) of the first matching element. The index is guaranteed to be valid for the list.

**Usage Pattern**:
```lean
-- Find bounded index
match axioms.findFinIdx? matchesAxiom with
| some idx => axioms[idx]  -- safe indexing
| none => -- no match
```

**Recommendation**: Use when you need type-safe indexing with the result.

---

### 4. Related Comparison Functions

#### 4.1 List.beq
**Type**: `{α : Type u} [BEq α] : List α → List α → Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`

**Description**: Boolean equality for lists. Checks if two lists are equal element-wise using `BEq`.

**Usage Pattern**:
```lean
#eval [1, 2, 3].beq [1, 2, 3]  -- true
#eval [1, 2, 3] == [1, 2, 3]   -- same (uses BEq instance)
```

---

#### 4.2 List.isPrefixOf
**Type**: `{α : Type u} [BEq α] : List α → List α → Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`

**Description**: Checks if the first list is a prefix of the second.

**Usage Pattern**:
```lean
#eval [1, 2].isPrefixOf [1, 2, 3, 4]  -- true
```

---

#### 4.3 List.isSuffixOf
**Type**: `{α : Type u} [BEq α] : List α → List α → Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`

**Description**: Checks if the first list is a suffix of the second.

**Usage Pattern**:
```lean
#eval [3, 4].isSuffixOf [1, 2, 3, 4]  -- true
```

---

#### 4.4 List.isSublist
**Type**: `{α : Type u} [BEq α] : List α → List α → Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`

**Description**: Checks if the first list is a (not necessarily contiguous) sublist of the second.

**Usage Pattern**:
```lean
#eval [1, 3].isSublist [1, 2, 3, 4]  -- true
```

---

#### 4.5 List.isPerm
**Type**: `{α : Type u} [BEq α] : List α → List α → Bool`  
**Library**: Init (Lean core)  
**Module**: `Init.Data.List.Basic`

**Description**: Checks if two lists are permutations of each other.

**Usage Pattern**:
```lean
#eval [1, 2, 3].isPerm [3, 1, 2]  -- true
```

---

### 5. Additional Utility Functions

#### 5.1 List.head?
**Type**: `{α : Type u} : List α → Option α`  
**Library**: Init (Lean core)

**Description**: Returns the first element of the list, or `none` if empty.

---

#### 5.2 List.tail?
**Type**: `{α : Type u} : List α → Option (List α)`  
**Library**: Init (Lean core)

**Description**: Returns the tail of the list, or `none` if empty.

---

#### 5.3 List.getLast?
**Type**: `{α : Type u} : List α → Option α`  
**Library**: Init (Lean core)

**Description**: Returns the last element of the list, or `none` if empty.

---

#### 5.4 List.lookup
**Type**: `{α : Type u} {β : Type v} [BEq α] (a : α) : List (α × β) → Option β`  
**Library**: Init (Lean core)

**Description**: Looks up a key in an association list (list of pairs).

**Usage Pattern**:
```lean
def assocList := [(1, "one"), (2, "two"), (3, "three")]
#eval assocList.lookup 2  -- some "two"
```

---

## Search Query Results Summary

| Query Pattern | Matches | Key Functions | Notes |
|--------------|---------|---------------|-------|
| `List _ → _ → Bool` | 24 | `elem`, `contains`, `all`, `any`, `beq`, `isPrefixOf`, `isSuffixOf`, `isSublist`, `isPerm` | Core membership and comparison |
| `List.elem` | 22 | `elem` + lemmas | Element membership (elem first) |
| `List.contains` | 902 | `contains` + extensive lemmas | Element membership (list first) |
| `List.mem` | ERROR | N/A | Use `∈` operator instead |
| `List.any` | 79 | `any` + lemmas | Existential predicate search |
| `List.all` | 66 | `all` + lemmas | Universal predicate check |
| `List.find` | ERROR | N/A | Use `find?` instead |
| `List _ → (_ → Bool) → Bool` | 2 | `any`, `all` | Perfect predicate pattern match |
| `List _ → _ → Option _` | 57 | `find?`, `findIdx?`, `findFinIdx?`, `head?`, `tail?`, `getLast?`, `lookup` | Find and optional access |

---

## Recommendations for Axiom Lookup Implementation

### Use Case 1: Check if Axiom Exists in List
**Recommended Function**: `List.contains` or `List.elem`

```lean
-- Method 1: Using contains (preferred for method syntax)
def hasAxiom (axioms : List Formula) (target : Formula) [BEq Formula] : Bool :=
  axioms.contains target

-- Method 2: Using elem
def hasAxiom' (axioms : List Formula) (target : Formula) [BEq Formula] : Bool :=
  target.elem axioms

-- Method 3: Using membership (for proofs)
def hasAxiom'' (axioms : List Formula) (target : Formula) [DecidableEq Formula] : Bool :=
  decide (target ∈ axioms)
```

**Requirements**: Need `BEq Formula` instance for `contains`/`elem`, or `DecidableEq Formula` for `∈`.

---

### Use Case 2: Find Axiom Matching Pattern
**Recommended Function**: `List.find?`

```lean
-- Find first axiom matching a pattern
def findMatchingAxiom (axioms : List Formula) (matches : Formula → Bool) : Option Formula :=
  axioms.find? matches

-- Example usage
def isNecessitation : Formula → Bool
  | .box _ => true
  | _ => false

match axioms.find? isNecessitation with
| some axiom => -- found a necessitation axiom
| none => -- no necessitation axiom found
```

---

### Use Case 3: Check if Any Axiom Satisfies Property
**Recommended Function**: `List.any`

```lean
-- Check if any axiom is a modal formula
def hasModalAxiom (axioms : List Formula) : Bool :=
  axioms.any fun f => match f with
    | .box _ => true
    | .diamond _ => true
    | _ => false

-- Check if any axiom matches a complex pattern
def hasMatchingAxiom (axioms : List Formula) (pattern : Formula → Bool) : Bool :=
  axioms.any pattern
```

---

### Use Case 4: Validate All Axioms
**Recommended Function**: `List.all`

```lean
-- Check if all axioms are well-formed
def allAxiomsWellFormed (axioms : List Formula) (isWellFormed : Formula → Bool) : Bool :=
  axioms.all isWellFormed

-- Check if all axioms satisfy a property
def allAxiomsValid (axioms : List Formula) (isValid : Formula → Bool) : Bool :=
  axioms.all isValid
```

---

### Use Case 5: Get Axiom with Index
**Recommended Function**: `List.findIdx?` or `List.findFinIdx?`

```lean
-- Find index of matching axiom
def findAxiomIndex (axioms : List Formula) (matches : Formula → Bool) : Option Nat :=
  axioms.findIdx? matches

-- Find with bounded index (type-safe)
def findAxiomFinIdx (axioms : List Formula) (matches : Formula → Bool) : Option (Fin axioms.length) :=
  axioms.findFinIdx? matches

-- Use the index
match axioms.findFinIdx? matches with
| some idx => axioms[idx]  -- safe indexing, no bounds check needed
| none => -- handle not found
```

---

## Implementation Checklist

### Required Type Class Instances

For your `Formula` type, you'll need:

1. **For `contains`/`elem`**: Implement `BEq Formula`
   ```lean
   instance : BEq Formula where
     beq f1 f2 := -- your equality logic
   ```

2. **For `∈` operator**: Implement `DecidableEq Formula`
   ```lean
   instance : DecidableEq Formula := fun f1 f2 =>
     -- decidable equality logic
   ```

3. **For theorem proving**: Both instances should be consistent
   ```lean
   -- Ensure: (f1 == f2) = true ↔ f1 = f2
   ```

---

### Performance Considerations

1. **`contains`/`elem`**: O(n) linear search
2. **`find?`**: O(n) worst case, stops at first match
3. **`any`**: O(n) worst case, short-circuits on first `true`
4. **`all`**: O(n) worst case, short-circuits on first `false`

For large axiom lists, consider:
- Using `HashMap` or `HashSet` for O(1) membership
- Indexing axioms by type/pattern for faster lookup
- Caching frequently accessed axioms

---

### Testing Recommendations

```lean
-- Test membership
#eval [.var 0, .box (.var 1)].contains (.var 0)  -- true

-- Test pattern matching
#eval [.var 0, .box (.var 1)].any (fun f => match f with | .box _ => true | _ => false)  -- true

-- Test find
#eval [.var 0, .box (.var 1)].find? (fun f => match f with | .box _ => true | _ => false)  -- some (.box (.var 1))

-- Test validation
#eval [.var 0, .var 1].all (fun f => match f with | .var _ => true | _ => false)  -- true
```

---

## Conclusion

The Lean 4 standard library provides comprehensive support for list searching and pattern matching:

1. **Membership**: Use `contains`/`elem` for boolean checks, `∈` for proofs
2. **Existential search**: Use `any` for "does any element satisfy?"
3. **Universal check**: Use `all` for "do all elements satisfy?"
4. **Element retrieval**: Use `find?` to get the matching element
5. **Index retrieval**: Use `findIdx?` or `findFinIdx?` to get the position

All functions are well-documented with extensive lemma support in Mathlib, making them suitable for both computation and theorem proving.

**Primary Source**: `Init.Data.List.Basic` (Lean core library)  
**Extended Support**: Mathlib, Std, Batteries

For axiom matching in your proof system, the combination of `contains` (membership), `find?` (retrieval), and `any` (pattern matching) should cover all common use cases.

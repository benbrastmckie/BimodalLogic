# Loogle Search Results: Bounded List Search Functions

**Type Pattern**: `Nat → (_ → Bool) → List _ → Option _`  
**Date**: 2025-12-20  
**Search Strategy**: Multi-pattern search with variations and name-based queries  
**Matches Found**: 0 exact, 2 close partial, 139+ related

---

## Executive Summary

**Key Finding**: The Lean 4 standard library and Mathlib **do not contain** functions with explicit fuel/depth/bound parameters for list searching. All built-in list search functions traverse the entire list without iteration limits.

**Implication**: For bounded computation on lists, you must either:
1. Implement a custom fuel-based search function
2. Use `List.take n xs |> List.find? p` to limit the search space
3. Use well-founded recursion with explicit termination proofs

---

## Search Results by Pattern

### 1. Primary Pattern: `Nat → (_ → Bool) → List _ → Option _`

**Exact Matches**: 0

**Close Partial Matches**: 2

#### `List.findIdx?.go`
- **Type**: `{α : Type u} (p : α → Bool) : List α → ℕ → Option ℕ`
- **Library**: Init (Lean standard library)
- **Module**: `Init.Data.List.Basic`
- **Parameter Order**: Predicate first, then list, then Nat (reversed from target)
- **Nat Usage**: Accumulator for index tracking, NOT a bound/limit
- **Visibility**: Internal helper function (`.go` suffix)
- **Termination**: Structural recursion on list

#### `List.findFinIdx?.go`
- **Type**: `{α : Type u} (p : α → Bool) (l l' : List α) (i : ℕ) (h : l'.length + i = l.length) : Option (Fin l.length)`
- **Library**: Init (Lean standard library)
- **Module**: `Init.Data.List.Basic`
- **Nat Usage**: Index accumulator with length invariant
- **Visibility**: Internal helper function
- **Termination**: Structural recursion with dependent type proof

**Analysis**: These functions use `Nat` for index accumulation, not for bounding the search. They are internal helpers and not intended for direct use.

---

### 2. Variation 1: `Nat → (_ → Bool) → List _ → _`

**Matches Found**: 65

**Key Matches** (functions that take Nat, predicate, and list):

#### `List.countP.go`
- **Type**: `{α : Type u} (p : α → Bool) : List α → ℕ → ℕ`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Auxiliary for `countP`: `countP.go p l acc = countP p l + acc`"
- **Nat Usage**: Accumulator for count
- **Termination**: Structural recursion

#### `List.findIdx.go`
- **Type**: `{α : Type u} (p : α → Bool) : List α → ℕ → ℕ`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Auxiliary for `findIdx`: `findIdx.go p l n = findIdx p l + n`"
- **Nat Usage**: Index offset accumulator
- **Termination**: Structural recursion

#### `List.findIdxs`
- **Type**: `{α : Type u_1} (p : α → Bool) (l : List α) (start : ℕ := 0) : List ℕ`
- **Library**: Batteries
- **Module**: `Batteries.Data.List.Basic`
- **Documentation**: "`findIdxs p l` is the list of indexes of elements of `l` that satisfy `p`, added to an optional parameter `start`"
- **Nat Usage**: Starting index offset (default parameter)
- **Returns**: All matching indices (not Option)
- **Termination**: Structural recursion

#### `List.findIdxsValues`
- **Type**: `{α : Type u_1} (p : α → Bool) (l : List α) (start : ℕ := 0) : List (ℕ × α)`
- **Library**: Batteries
- **Module**: `Batteries.Data.List.Basic`
- **Documentation**: "Returns the elements of `l` that satisfy `p` together with their indexes in `l` added to an optional parameter `start`"
- **Nat Usage**: Starting index offset
- **Returns**: All matching pairs (not Option)
- **Termination**: Structural recursion

**Analysis**: All functions use `Nat` for index tracking or offsets, not for bounding computation. None return `Option` to signal bounded failure.

---

### 3. Variation 2: `_ → (_ → Bool) → List _ → Option _`

**Matches Found**: 8

**Exact Matches** (without Nat parameter):

#### `List.find?` ⭐ **Most Relevant**
- **Type**: `{α : Type u} (p : α → Bool) : List α → Option α`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Returns the first element of the list for which the predicate `p` returns `true`, or `none` if no such element is found. O(|l|)."
- **Examples**:
  - `[7, 6, 5, 8, 1, 2, 6].find? (· < 5) = some 1`
  - `[7, 6, 5, 8, 1, 2, 6].find? (· < 1) = none`
- **Termination**: Structural recursion on list
- **Related Declarations**: 139 total (many lemmas)

#### `List.findIdx?`
- **Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option ℕ`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Returns the index of the first element for which `p` returns `true`, or `none` if there is no such element."
- **Examples**:
  - `[7, 6, 5, 8, 1, 2, 6].findIdx? (· < 5) = some 4`
  - `[7, 6, 5, 8, 1, 2, 6].findIdx? (· < 1) = none`
- **Termination**: Structural recursion

#### `List.findRev?`
- **Type**: `{α : Type u} (p : α → Bool) : List α → Option α`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Returns the last element of the list for which the predicate `p` returns `true`, or `none` if no such element is found. O(|l|)."
- **Examples**:
  - `[7, 6, 5, 8, 1, 2, 6].findRev? (· < 5) = some 2`
  - `[7, 6, 5, 8, 1, 2, 6].findRev? (· < 1) = none`
- **Termination**: Structural recursion

#### `List.findFinIdx?`
- **Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option (Fin l.length)`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Returns the index of the first element for which `p` returns `true`, or `none` if there is no such element. The index is returned as a `Fin`, which guarantees that it is in bounds."
- **Examples**:
  - `[7, 6, 5, 8, 1, 2, 6].findFinIdx? (· < 5) = some (4 : Fin 7)`
  - `[7, 6, 5, 8, 1, 2, 6].findFinIdx? (· < 1) = none`
- **Termination**: Structural recursion
- **Type Safety**: Returns dependent type `Fin l.length`

**Analysis**: These are the standard unbounded search functions. They always traverse the entire list until a match is found or the list is exhausted.

---

### 4. Name-Based Searches

Searched for common bounded computation naming patterns:

| Search Term | Result |
|------------|--------|
| `findBounded` | No matches (unknown identifier) |
| `searchWithFuel` | No matches (unknown identifier) |
| `findWithDepth` | No matches (unknown identifier) |
| `findWithLimit` | No matches (unknown identifier) |
| `findWithBound` | No matches (unknown identifier) |

**Analysis**: No standard library functions use these naming conventions for bounded search.

---

### 5. Related Functions

#### `List.findSome?`
- **Type**: `{α : Type u} {β : Type v} (f : α → Option β) : List α → Option β`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Returns the first non-`none` result of applying `f` to each element of the list in order. Returns `none` if `f` returns `none` for all elements of the list. O(|l|)."
- **Examples**:
  - `[7, 6, 5, 8, 1, 2, 6].findSome? (fun x => if x < 5 then some (10 * x) else none) = some 10`
  - `[7, 6, 5, 8, 1, 2, 6].findSome? (fun x => if x < 1 then some (10 * x) else none) = none`
- **Related Declarations**: 52 total
- **Use Case**: Monadic search with transformation

#### `List.findSomeRev?`
- **Type**: `{α : Type u} {β : Type v} (f : α → Option β) : List α → Option β`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Returns the last non-`none` result of applying `f` to each element of the list in order."
- **Examples**:
  - `[7, 6, 5, 8, 1, 2, 6].findSomeRev? (fun x => if x < 5 then some (10 * x) else none) = some 20`

#### `List.lookup`
- **Type**: `{α : Type u} {β : Type v} [BEq α] : α → List (α × β) → Option β`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Documentation**: "Treats the list as an association list that maps keys to values, returning the first value whose key is equal to the specified key. O(|l|)."
- **Examples**:
  - `[(1, "one"), (3, "three"), (3, "other")].lookup 3 = some "three"`
  - `[(1, "one"), (3, "three"), (3, "other")].lookup 2 = none`
- **Related Declarations**: 26 total
- **Use Case**: Association list lookup

---

## Analysis: Bounded Computation in Lean

### Why No Built-in Bounded Search?

1. **Structural Recursion Suffices**: Lean's termination checker accepts structural recursion on lists, so fuel parameters are unnecessary for termination proofs.

2. **Type-Level Guarantees**: Functions like `List.findFinIdx?` use dependent types (`Fin l.length`) instead of runtime bounds.

3. **Composition Over Specialization**: The library favors composing `List.take` with `List.find?` over specialized bounded functions.

4. **Well-Founded Recursion**: For complex termination, Lean provides well-founded recursion with explicit measures.

### Termination Mechanisms in Lean

| Mechanism | Use Case | Example |
|-----------|----------|---------|
| Structural recursion | Recursion on list structure | `List.find?`, `List.map` |
| Well-founded recursion | Custom termination measure | User-defined with `termination_by` |
| Fuel parameters | Bounded computation | Not in standard library |
| Dependent types | Type-level bounds | `Fin n`, `Vector α n` |

---

## Recommendations

### For Bounded List Search

**Option 1: Composition (Recommended for Simple Cases)**
```lean
def findBounded (n : Nat) (p : α → Bool) (xs : List α) : Option α :=
  xs.take n |>.find? p
```
- **Pros**: Uses proven library functions, simple
- **Cons**: Creates intermediate list, O(n) space

**Option 2: Custom Fuel-Based Function**
```lean
def findWithFuel (fuel : Nat) (p : α → Bool) : List α → Option α
  | _, [] => none
  | 0, _ => none  -- Fuel exhausted
  | fuel + 1, x :: xs =>
    if p x then some x
    else findWithFuel fuel p xs
```
- **Pros**: Explicit fuel tracking, no intermediate structures
- **Cons**: Requires custom implementation and proofs
- **Termination**: Structural recursion on fuel and list

**Option 3: Well-Founded Recursion with Measure**
```lean
def findBounded (n : Nat) (p : α → Bool) (xs : List α) : Option α :=
  go n xs
where
  go (fuel : Nat) : List α → Option α
    | [] => none
    | x :: xs =>
      if fuel = 0 then none
      else if p x then some x
      else go (fuel - 1) xs
  termination_by go fuel xs => (fuel, xs.length)
```
- **Pros**: Explicit termination proof, flexible
- **Cons**: More complex, requires understanding well-founded recursion

### For Your Use Case

Based on the pattern `Nat → (_ → Bool) → List _ → Option _`:

1. **If you need bounded search for termination**: Use **Option 2** (fuel-based) with structural recursion on fuel.

2. **If you need bounded search for performance**: Use **Option 1** (composition) for simplicity, or **Option 2** if intermediate list allocation is a concern.

3. **If you need to prove properties**: Use **Option 3** (well-founded) for maximum flexibility in proofs.

### Related Library Functions to Consider

| Function | Type | Use When |
|----------|------|----------|
| `List.find?` | `(α → Bool) → List α → Option α` | Unbounded search for first match |
| `List.findIdx?` | `(α → Bool) → List α → Option Nat` | Need index of match |
| `List.findSome?` | `(α → Option β) → List α → Option β` | Monadic search with transformation |
| `List.take` | `Nat → List α → List α` | Limit list length before search |
| `List.filter` | `(α → Bool) → List α → List α` | Find all matches (not just first) |

---

## Proof Library Considerations

### Available Lemmas for `List.find?`

With 139 related declarations, `List.find?` has extensive proof support:

- **Correctness**: Lemmas about when `find?` returns `some` vs `none`
- **Relationship to membership**: Connection to `∈` and `List.mem`
- **Relationship to `filter`**: `find?` vs `filter` properties
- **Monadic properties**: Interaction with `Option` monad

### Proof Burden for Custom Functions

If you implement a custom bounded search:

1. **Basic correctness**: Prove it finds elements when they exist within bounds
2. **Fuel exhaustion**: Prove behavior when fuel runs out
3. **Relationship to `List.find?`**: Prove equivalence when fuel ≥ list length
4. **Monotonicity**: Prove more fuel doesn't change results (if element found)

**Recommendation**: If you need extensive proofs, consider using `List.take n xs |>.find? p` to leverage existing `List.find?` lemmas.

---

## Summary

| Aspect | Finding |
|--------|---------|
| **Exact matches** | 0 |
| **Close partial matches** | 2 (`.go` helpers with different parameter order) |
| **Related unbounded functions** | 8+ (find?, findIdx?, findSome?, etc.) |
| **Standard library approach** | Structural recursion, no fuel parameters |
| **Recommended approach** | Composition (`take` + `find?`) or custom fuel-based |
| **Proof support** | Extensive for `List.find?`, minimal for bounded variants |

**Conclusion**: Lean's standard library does not provide bounded list search functions. For bounded computation, you must implement a custom function or compose existing functions. The library's design philosophy favors structural recursion and type-level guarantees over runtime bounds.

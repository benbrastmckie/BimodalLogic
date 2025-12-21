# Loogle Search Results: [DecidableEq α] → α → List α → Bool

**Type Pattern**: `[DecidableEq α] → α → List α → Bool`  
**Date**: Sun Dec 21 2025  
**Matches Found**: 22+ functions and lemmas  
**Search Status**: Complete

---

## Executive Summary

The search for functions matching the type pattern `[DecidableEq α] → α → List α → Bool` revealed that Lean 4 uses `[BEq α]` (boolean equality) rather than `[DecidableEq α]` for list membership checking functions. The two primary functions are:

1. **List.elem** - Takes element first, then list
2. **List.contains** - Takes list first (as method), then element

Both functions are in Lean's core library (Init) and have extensive lemma support for reasoning about membership.

---

## Exact Matches

### 1. **List.elem**
- **Full Type Signature**: `{α : Type u} [BEq α] (a : α) (l : List α) : Bool`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: https://leanprover-community.github.io/mathlib4_docs/Init/Data/List/Basic.html#List.elem
- **Description**: Returns `true` if element `a` is in list `l`, using boolean equality (`BEq`)
- **Usage Example**: `List.elem 3 [1, 2, 3, 4]  -- returns true`
- **Argument Order**: Element first, list second
- **Note**: Uses `[BEq α]` typeclass instead of `[DecidableEq α]`

### 2. **List.contains**
- **Full Type Signature**: `{α : Type u} [BEq α] (as : List α) (a : α) : Bool`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: https://leanprover-community.github.io/mathlib4_docs/Init/Data/List/Basic.html#List.contains
- **Description**: Returns `true` if list `as` contains element `a`, using boolean equality
- **Usage Example**: `[1, 2, 3, 4].contains 3  -- returns true`
- **Argument Order**: List first, element second (designed for method notation)
- **Note**: Equivalent to `List.elem` with reversed argument order

---

## Related Lemmas and Properties

### Basic Properties

#### 3. **List.elem_nil**
- **Full Type Signature**: `{α : Type u} {a : α} [BEq α] : List.elem a [] = false`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Description**: Lemma stating that checking membership in an empty list always returns `false`

#### 4. **List.elem.eq_1**
- **Full Type Signature**: `{α : Type u} [BEq α] (a : α) : List.elem a [] = false`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Description**: Equation lemma for `elem` applied to empty list

#### 5. **List.contains_nil**
- **Full Type Signature**: `{α : Type u} {a : α} [BEq α] : [].contains a = false`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Description**: Contains on empty list is always `false`

### Membership Equivalence

#### 6. **List.elem_eq_true_of_mem**
- **Full Type Signature**: `{α : Type u} [BEq α] [ReflBEq α] {a : α} {as : List α} (h : a ∈ as) : List.elem a as = true`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Description**: If element is a member (using `∈`), then `elem` returns `true`
- **Typeclass Requirements**: Requires `[ReflBEq α]` for reflexivity

#### 7. **List.mem_of_elem_eq_true**
- **Full Type Signature**: `{α : Type u} [BEq α] [LawfulBEq α] {a : α} {as : List α} : List.elem a as = true → a ∈ as`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Description**: If `elem` returns `true`, then element is a member
- **Typeclass Requirements**: Requires `[LawfulBEq α]` for lawful equality

#### 8. **List.elem_iff**
- **Full Type Signature**: `{α : Type u_1} [BEq α] [LawfulBEq α] {a : α} {as : List α} : List.elem a as = true ↔ a ∈ as`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: Bidirectional equivalence: `elem` returns `true` if and only if element is a member
- **Usage**: Primary lemma for converting between boolean and propositional membership

#### 9. **List.contains_iff**
- **Full Type Signature**: `{α : Type u_1} [BEq α] [LawfulBEq α] {a : α} {as : List α} : as.contains a = true ↔ a ∈ as`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: Bidirectional equivalence for `contains`

### Recursive Structure

#### 10. **List.elem.eq_2**
- **Full Type Signature**: `{α : Type u} [BEq α] (a a_1 : α) (as : List α) : List.elem a (a_1 :: as) = match a == a_1 with | true => true | false => List.elem a as`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Description**: Equation lemma showing recursive structure of `elem` on cons

#### 11. **List.elem_cons**
- **Full Type Signature**: `{α : Type u} {b : α} {bs : List α} [BEq α] {a : α} : List.elem a (b :: bs) = match a == b with | true => true | false => List.elem a bs`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Description**: `elem` on cons list: checks head first, then recursively checks tail

#### 12. **List.elem.eq_def**
- **Full Type Signature**: `{α : Type u} [BEq α] (a : α) (x✝ : List α) : List.elem a x✝ = match x✝ with | [] => false | b :: bs => match a == b with | true => true | false => List.elem a bs`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Description**: Complete definition equation for `elem` by pattern matching

### Self-Membership

#### 13. **List.elem_cons_self**
- **Full Type Signature**: `{α : Type u_1} {as : List α} [BEq α] [LawfulBEq α] {a : α} : List.elem a (a :: as) = true`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: An element is always found in a list that starts with itself
- **Typeclass Requirements**: Requires `[LawfulBEq α]` for reflexivity

### Equivalence Relations

#### 14. **List.elem_eq_contains**
- **Full Type Signature**: `{α : Type u_1} [BEq α] {a : α} {l : List α} : List.elem a l = l.contains a`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: `elem` and `contains` are equivalent (just different argument order)

#### 15. **List.elem_eq_mem**
- **Full Type Signature**: `{α : Type u_1} [BEq α] [LawfulBEq α] (a : α) (as : List α) : List.elem a as = decide (a ∈ as)`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: `elem` is equivalent to `decide` applied to propositional membership
- **Usage**: Connects boolean and decidable membership

### Array Interoperability

#### 16. **List.elem_toArray**
- **Full Type Signature**: `{α : Type u_1} [BEq α] {l : List α} {a : α} : Array.elem a l.toArray = List.elem a l`
- **Module**: `Init.Data.Array.Lemmas`
- **Library**: Lean Core
- **Description**: `elem` on a list converted to array equals `elem` on the original list

### Structural Properties

#### 17. **List.contains_reverse**
- **Full Type Signature**: `{α : Type u_1} [BEq α] {l : List α} {x : α} : l.reverse.contains x = l.contains x`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: `contains` is invariant under list reversal

### Higher-Order Function Equivalences

#### 18. **List.any_beq**
- **Full Type Signature**: `{α : Type u_1} [BEq α] {l : List α} {a : α} : (l.any fun x => a == x) = l.contains a`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: Using `any` with boolean equality predicate is equivalent to `contains`

#### 19. **List.contains_eq_any_beq**
- **Full Type Signature**: `{α : Type u_1} [BEq α] {l : List α} {a : α} : l.contains a = l.any fun x => a == x`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: Reverse direction: `contains` equals `any` with beq

#### 20. **List.any_beq'**
- **Full Type Signature**: `{α : Type u_1} {a : α} [BEq α] [PartialEquivBEq α] {l : List α} : (l.any fun x => x == a) = l.contains a`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: `any` with reversed beq arguments (requires `[PartialEquivBEq α]`)

#### 21. **List.all_bne**
- **Full Type Signature**: `{α : Type u_1} {a : α} [BEq α] {l : List α} : (l.all fun x => a != x) = !l.contains a`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: Using `all` with boolean inequality is the negation of `contains`

#### 22. **List.all_bne'**
- **Full Type Signature**: `{α : Type u_1} {a : α} [BEq α] [PartialEquivBEq α] {l : List α} : (l.all fun x => x != a) = !l.contains a`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Lean Core
- **Description**: `all` with reversed bne arguments

---

## Typeclass Hierarchy

The functions and lemmas use different typeclass requirements:

1. **[BEq α]** - Basic boolean equality
   - Required for: `List.elem`, `List.contains`
   - Minimal requirement for membership checking

2. **[ReflBEq α]** - Reflexive boolean equality
   - Required for: `List.elem_eq_true_of_mem`
   - Ensures `a == a = true`

3. **[LawfulBEq α]** - Lawful boolean equality
   - Required for: Most lemmas connecting to propositional membership (`∈`)
   - Ensures `a == b = true ↔ a = b`

4. **[PartialEquivBEq α]** - Partial equivalence for boolean equality
   - Required for: Reversed argument versions (`any_beq'`, `all_bne'`)
   - Ensures symmetry of `==`

---

## Recommendations

### For Boolean Membership Checking

1. **Use `List.elem`** when you want function application syntax:
   ```lean
   if List.elem x myList then ...
   ```

2. **Use `List.contains`** when you want method notation:
   ```lean
   if myList.contains x then ...
   ```

3. Both functions are equivalent (see `List.elem_eq_contains`)

### For Propositional Membership

1. **Use `List.elem_iff`** or `List.contains_iff`** to convert between boolean and propositional membership:
   ```lean
   have h : x ∈ myList := List.elem_iff.mp (by simp)
   ```

2. **Use `List.elem_eq_mem`** to relate to `decide`:
   ```lean
   List.elem x myList = decide (x ∈ myList)
   ```

### For Higher-Order Functions

1. **Use `List.any_beq`** to simplify `any` expressions:
   ```lean
   (myList.any fun y => x == y) = myList.contains x
   ```

2. **Use `List.all_bne`** for negation:
   ```lean
   (myList.all fun y => x != y) = !myList.contains x
   ```

### Typeclass Requirements

- For basic usage: Only `[BEq α]` is needed
- For reasoning about membership: Use `[LawfulBEq α]`
- Note: `[DecidableEq α]` is not used for these functions; Lean 4 prefers `[BEq α]` for boolean operations

---

## Additional Notes

### DecidableEq vs BEq

The original search pattern requested `[DecidableEq α]`, but Lean 4's list membership functions use `[BEq α]` instead:

- **[DecidableEq α]**: Used for propositional equality with decidability
- **[BEq α]**: Used for boolean equality (more efficient for boolean operations)

The connection between them:
- `decide (a = b)` uses `[DecidableEq α]`
- `a == b` uses `[BEq α]`
- `List.elem_eq_mem` connects them: `List.elem a as = decide (a ∈ as)`

### Performance Considerations

- `List.elem` and `List.contains` are O(n) operations
- They use boolean equality (`==`) which may be more efficient than propositional equality
- For large lists, consider using data structures with faster lookup (e.g., `HashSet`, `RBSet`)

### Related Functions Not Matching Type Pattern

The search also revealed 900+ related functions in the `List.contains` namespace, mostly internal implementation details and specialized lemmas in Mathlib and Std. These were not included as they don't directly match the requested type pattern.

---

## Search Metadata

- **Search Tool**: Loogle (via MCP server)
- **Query Patterns Tried**:
  1. `"[DecidableEq α] → α → List α → Bool"` (no exact matches)
  2. `"α → List α → Bool"` (found `List.elem` and related)
  3. Name search: `"List.elem"` (22 results)
  4. Name search: `"List.contains"` (902+ results)
- **Total Unique Functions**: 22 (excluding internal implementation details)
- **Primary Library**: Lean Core (Init modules)
- **Secondary Libraries**: Batteries (Std), Mathlib (for additional lemmas)

---

## Conclusion

The canonical functions for checking list membership with boolean return type in Lean 4 are **List.elem** and **List.contains**. They use `[BEq α]` rather than `[DecidableEq α]`, and have extensive lemma support for reasoning about membership, conversion to propositional membership, and interaction with higher-order functions like `any` and `all`.

For most use cases, `List.contains` with method notation is recommended for readability:
```lean
if myList.contains x then ... else ...
```

For reasoning in proofs, use `List.elem_iff` or `List.contains_iff` to connect to propositional membership (`∈`).

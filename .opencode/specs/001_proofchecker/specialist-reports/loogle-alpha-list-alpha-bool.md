# Loogle Search Report: Type Pattern `α → List α → Bool`

**Search Date:** 2025-12-21  
**Query:** Functions matching the type signature `α → List α → Bool`  
**API Endpoint:** https://loogle.lean-lang.org/json

---

## Executive Summary

This report documents a comprehensive Loogle API search for functions matching the type pattern `α → List α → Bool`. The search identified **22 functions** across multiple Lean libraries (Init, Std, Batteries, Lean core, and Mathlib) that match or closely relate to this type signature.

The primary exact match is **`List.elem`**, which checks whether an element is present in a list. However, several related functions were found that take similar arguments but in different orders or with additional type class constraints.

---

## Search Metadata

- **Type Pattern Searched:** `α → List α → Bool`
- **Query Format Used:** `_ -> List _ -> Bool` (wildcard syntax for Loogle)
- **Total Matches Found:** 22
- **Total Declarations Scanned:** 3,793 (mentioning List and Bool)
- **Heartbeats Used:** 4,833
- **Query Status:** Success

---

## Complete Raw Loogle Output

```json
{
  "count": 22,
  "header": "Found 3793 declarations mentioning List and Bool.\nOf these, 22 match your pattern(s).\n",
  "heartbeats": 4833,
  "hits": [
    {
      "doc": "Checks whether a list is empty.\n\n`O(1)`.\n\nExamples:\n* `[].isEmpty = true`\n* `[\"grape\"].isEmpty = false`\n* `[\"apple\", \"banana\"].isEmpty = false`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.isEmpty",
      "type": " {α : Type u} : List α → Bool"
    },
    {
      "doc": "Returns `true` if `p` returns `true` for every element of `l`.\n\n`O(|l|)`. Short-circuits upon encountering the first `false`.\n\nExamples:\n* `[a, b, c].all p = (p a && (p b && p c))`\n* `[2, 4, 6].all (· % 2 = 0) = true`\n* `[2, 4, 5, 6].all (· % 2 = 0) = false`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.all",
      "type": " {α : Type u} : List α → (α → Bool) → Bool"
    },
    {
      "doc": "Returns `true` if `p` returns `true` for any element of `l`.\n\n`O(|l|)`. Short-circuits upon encountering the first `true`.\n\nExamples:\n* `[2, 4, 6].any (· % 2 = 0) = true`\n* `[2, 4, 6].any (· % 2 = 1) = false`\n* `[2, 4, 5, 6].any (· % 2 = 0) = true`\n* `[2, 4, 5, 6].any (· % 2 = 1) = true`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.any",
      "type": " {α : Type u} (l : List α) (p : α → Bool) : Bool"
    },
    {
      "doc": "Checks whether `a` is an element of `as`, using `==` to compare elements.\n\n`O(|as|)`. `List.elem` is a synonym that takes the element before the list.\n\nThe preferred simp normal form is `l.contains a`, and when `LawfulBEq α` is available,\n`l.contains a = true ↔ a ∈ l` and `l.contains a = false ↔ a ∉ l`.\n\nExamples:\n* `[1, 4, 2, 3, 3, 7].contains 3 = true`\n* `List.contains [1, 4, 2, 3, 3, 7] 5 = false`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.contains",
      "type": " {α : Type u} [BEq α] (as : List α) (a : α) : Bool"
    },
    {
      "doc": "Checks whether `a` is an element of `l`, using `==` to compare elements.\n\n`O(|l|)`. `List.contains` is a synonym that takes the list before the element.\n\nThe preferred simp normal form is `l.contains a`. When `LawfulBEq α` is available,\n`l.contains a = true ↔ a ∈ l` and `l.contains a = false ↔ a ∉ l`.\n\nExample:\n* `List.elem 3 [1, 4, 2, 3, 3, 7] = true`\n* `List.elem 5 [1, 4, 2, 3, 3, 7] = false`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.elem",
      "type": " {α : Type u} [BEq α] (a : α) (l : List α) : Bool"
    },
    {
      "doc": "Checks whether two lists have the same length and their elements are pairwise `BEq`. Normally used\nvia the `==` operator.\n",
      "module": "Init.Data.List.Basic",
      "name": "List.beq",
      "type": " {α : Type u} [BEq α] : List α → List α → Bool"
    },
    {
      "doc": "Returns `true` if `l₁` and `l₂` are permutations of each other. `O(|l₁| * |l₂|)`.\n\nThe relation `List.Perm` is a logical characterization of permutations. When the `BEq α` instance\ncorresponds to `DecidableEq α`, `isPerm l₁ l₂ ↔ l₁ ~ l₂` (use the theorem `isPerm_iff`).\n",
      "module": "Init.Data.List.Basic",
      "name": "List.isPerm",
      "type": " {α : Type u} [BEq α] : List α → List α → Bool"
    },
    {
      "doc": "Checks whether the first list is a prefix of the second.\n\nThe relation `List.IsPrefixOf` expresses this property with respect to logical equality.\n\nExamples:\n* `[1, 2].isPrefixOf [1, 2, 3] = true`\n* `[1, 2].isPrefixOf [1, 2] = true`\n* `[1, 2].isPrefixOf [1] = false`\n* `[1, 2].isPrefixOf [1, 1, 2, 3] = false`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.isPrefixOf",
      "type": " {α : Type u} [BEq α] : List α → List α → Bool"
    },
    {
      "doc": "True if the first list is a potentially non-contiguous sub-sequence of the second list, comparing\nelements with the `==` operator.\n\nThe relation `List.Sublist` is a logical characterization of this property.\n\nExamples:\n* `[1, 3].isSublist [0, 1, 2, 3, 4] = true`\n* `[1, 3].isSublist [0, 1, 2, 4] = false`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.isSublist",
      "type": " {α : Type u} [BEq α] : List α → List α → Bool"
    },
    {
      "doc": "Checks whether the first list is a suffix of the second.\n\nThe relation `List.IsSuffixOf` expresses this property with respect to logical equality.\n\nExamples:\n* `[2, 3].isSuffixOf [1, 2, 3] = true`\n* `[2, 3].isSuffixOf [1, 2, 3, 4] = false`\n* `[2, 3].isSuffixOf [1, 2] = false`\n* `[2, 3].isSuffixOf [1, 1, 2, 3] = true`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.isSuffixOf",
      "type": " {α : Type u} [BEq α] (l₁ l₂ : List α) : Bool"
    },
    {
      "doc": "Returns `true` if `as` and `bs` have the same length and they are pairwise related by `eqv`.\n\n`O(min |as| |bs|)`. Short-circuits at the first non-related pair of elements.\n\nExamples:\n* `[1, 2, 3].isEqv [2, 3, 4] (· < ·) = true`\n* `[1, 2, 3].isEqv [2, 2, 4] (· < ·) = false`\n* `[1, 2, 3].isEqv [2, 3] (· < ·) = false`\n",
      "module": "Init.Data.List.Basic",
      "name": "List.isEqv",
      "type": " {α : Type u} (as bs : List α) (eqv : α → α → Bool) : Bool"
    },
    {
      "doc": "Compares lists lexicographically with respect to a comparison on their elements.\n\nThe lexicographic order with respect to `lt` is:\n* `[].lex (b :: bs)` is `true`\n* `as.lex [] = false` is `false`\n* `(a :: as).lex (b :: bs)` is true if `lt a b` or `a == b` and `lex lt as bs` is true.\n",
      "module": "Init.Data.List.Basic",
      "name": "List.lex",
      "type": " {α : Type u} [BEq α] (l₁ l₂ : List α) (lt : α → α → Bool := by exact (· < ·)) : Bool"
    },
    {
      "doc": "Compares two lists of objects for element-wise pointer equality. Returns `true` if both lists are\nthe same length and the objects at the corresponding indices of each list are pointer-equal.\n\nTwo objects are pointer-equal if, at runtime, they are allocated at exactly the same address. This\nfunction is unsafe because it can distinguish between definitionally equal values.\n",
      "module": "Init.Util",
      "name": "ptrEqList",
      "type": " {α : Type u_1} (as bs : List α) : Bool"
    },
    {
      "doc": "Internal implementation detail of the hash map ",
      "module": "Std.Data.Internal.List.Associative",
      "name": "Std.Internal.List.containsKey",
      "type": " {α : Type u} {β : α → Type v} [BEq α] (a : α) : List ((a : α) × β a) → Bool"
    },
    {
      "doc": "Internal implementation detail of the hash map ",
      "module": "Std.Data.Internal.List.Associative",
      "name": "Std.Internal.List.Const.beqModel",
      "type": " {α : Type u} {β : Type v} [BEq α] [BEq β] (l₁ l₂ : List ((_ : α) × β)) : Bool"
    },
    {
      "doc": "Internal implementation detail of the hash map ",
      "module": "Std.Data.Internal.List.Associative",
      "name": "Std.Internal.List.beqModel",
      "type": " {α : Type u} {β : α → Type v} [BEq α] [LawfulBEq α] [(k : α) → BEq (β k)] (l₁ l₂ : List ((a : α) × β a)) : Bool"
    },
    {
      "doc": "Compare the `SyntaxNodeKind`s in `pattern` to those of the `Syntax`\nelements in `stack`. Return `false` if `stack` is shorter than `pattern`. ",
      "module": "Lean.Syntax",
      "name": "Lean.Syntax.Stack.matches",
      "type": " (stack : Lean.Syntax.Stack) (pattern : List (Option Lean.SyntaxNodeKind)) : Bool"
    },
    {
      "doc": "`O(|l₁| * (|l₁| + |l₂|))`. Computes whether `l₁` is a sublist of a permutation of `l₂`.\nSee `isSubperm_iff` for a characterization in terms of `List.Subperm`.\n",
      "module": "Batteries.Data.List.Basic",
      "name": "List.isSubperm",
      "type": " {α : Type u_1} [BEq α] (l₁ l₂ : List α) : Bool"
    },
    {
      "doc": "Check for all elements `a`, `b`, where `a` and `b` are the nth element of the first and second\nList respectively, that `r a b = true`.\n",
      "module": "Batteries.Data.List.Basic",
      "name": "List.all₂",
      "type": " {α : Type u_1} {β : Type u_2} (r : α → β → Bool) : List α → List β → Bool"
    },
    {
      "doc": "Returns true iff `pattern` occurs as an infix sublist of `l`.\n",
      "module": "Batteries.Data.List.Matcher",
      "name": "List.containsInfix",
      "type": " {α : Type u_1} [BEq α] (l pattern : List α) : Bool"
    },
    {
      "doc": "Returns `true` if there is a theorem with exactly the same pattern and constraints is already in `s`\n",
      "module": "Lean.Meta.Tactic.Grind.EMatchTheorem",
      "name": "Lean.Meta.Grind.EMatchTheorems.containsWithSamePatterns",
      "type": " (s : Lean.Meta.Grind.EMatchTheorems) (origin : Lean.Meta.Grind.Origin) (patterns : List Lean.Expr) (cnstrs : List Lean.Meta.Grind.EMatchTheoremConstraint) : Bool"
    },
    {
      "doc": "`P.rmatch x` is true if and only if `P` matches `x`. This is a computable definition equivalent\nto `matches'`. ",
      "module": "Mathlib.Computability.RegularExpressions",
      "name": "RegularExpression.rmatch",
      "type": " {α : Type u_1} [DecidableEq α] : RegularExpression α → List α → Bool"
    }
  ]
}
```

---

## Exact Matches

### 1. **List.elem** ⭐ PRIMARY MATCH

- **Full Type:** `{α : Type u} [BEq α] (a : α) (l : List α) : Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Complexity:** O(|l|)
- **Documentation:**
  > Checks whether `a` is an element of `l`, using `==` to compare elements.
  >
  > `List.contains` is a synonym that takes the list before the element.
  >
  > The preferred simp normal form is `l.contains a`. When `LawfulBEq α` is available,
  > `l.contains a = true ↔ a ∈ l` and `l.contains a = false ↔ a ∉ l`.

- **Examples:**
  ```lean
  List.elem 3 [1, 4, 2, 3, 3, 7] = true
  List.elem 5 [1, 4, 2, 3, 3, 7] = false
  ```

- **Type Class Constraint:** Requires `[BEq α]` for equality comparison
- **Usage Note:** This is the canonical function matching the exact pattern `α → List α → Bool`

---

## Partial Matches (Reversed Arguments)

### 2. **List.contains**

- **Full Type:** `{α : Type u} [BEq α] (as : List α) (a : α) : Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Complexity:** O(|as|)
- **Documentation:**
  > Checks whether `a` is an element of `as`, using `==` to compare elements.
  >
  > `List.elem` is a synonym that takes the element before the list.
  >
  > The preferred simp normal form is `l.contains a`, and when `LawfulBEq α` is available,
  > `l.contains a = true ↔ a ∈ l` and `l.contains a = false ↔ a ∉ l`.

- **Examples:**
  ```lean
  [1, 4, 2, 3, 3, 7].contains 3 = true
  List.contains [1, 4, 2, 3, 3, 7] 5 = false
  ```

- **Similarity Note:** Takes arguments in reverse order: `List α → α → Bool` instead of `α → List α → Bool`
- **Preferred Form:** According to documentation, `l.contains a` is the preferred simp normal form

---

## Related Matches (Different Patterns)

### 3. **List.isEmpty**

- **Full Type:** `{α : Type u} : List α → Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Complexity:** O(1)
- **Documentation:**
  > Checks whether a list is empty.

- **Examples:**
  ```lean
  [].isEmpty = true
  ["grape"].isEmpty = false
  ["apple", "banana"].isEmpty = false
  ```

- **Similarity Note:** Only takes a `List α`, does not require an element of type `α`

### 4. **List.all**

- **Full Type:** `{α : Type u} : List α → (α → Bool) → Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Complexity:** O(|l|), short-circuits on first `false`
- **Documentation:**
  > Returns `true` if `p` returns `true` for every element of `l`.

- **Examples:**
  ```lean
  [a, b, c].all p = (p a && (p b && p c))
  [2, 4, 6].all (· % 2 = 0) = true
  [2, 4, 5, 6].all (· % 2 = 0) = false
  ```

- **Similarity Note:** Takes a predicate `(α → Bool)` instead of a single element `α`

### 5. **List.any**

- **Full Type:** `{α : Type u} (l : List α) (p : α → Bool) : Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Complexity:** O(|l|), short-circuits on first `true`
- **Documentation:**
  > Returns `true` if `p` returns `true` for any element of `l`.

- **Examples:**
  ```lean
  [2, 4, 6].any (· % 2 = 0) = true
  [2, 4, 6].any (· % 2 = 1) = false
  [2, 4, 5, 6].any (· % 2 = 0) = true
  ```

- **Similarity Note:** Takes a predicate `(α → Bool)` instead of a single element `α`

### 6. **List.beq**

- **Full Type:** `{α : Type u} [BEq α] : List α → List α → Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Documentation:**
  > Checks whether two lists have the same length and their elements are pairwise `BEq`. Normally used via the `==` operator.

- **Similarity Note:** Takes two lists instead of an element and a list

### 7. **List.isPerm**

- **Full Type:** `{α : Type u} [BEq α] : List α → List α → Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Complexity:** O(|l₁| * |l₂|)
- **Documentation:**
  > Returns `true` if `l₁` and `l₂` are permutations of each other.
  >
  > The relation `List.Perm` is a logical characterization of permutations. When the `BEq α` instance
  > corresponds to `DecidableEq α`, `isPerm l₁ l₂ ↔ l₁ ~ l₂` (use the theorem `isPerm_iff`).

- **Similarity Note:** Takes two lists instead of an element and a list

### 8. **List.isPrefixOf**

- **Full Type:** `{α : Type u} [BEq α] : List α → List α → Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Documentation:**
  > Checks whether the first list is a prefix of the second.

- **Examples:**
  ```lean
  [1, 2].isPrefixOf [1, 2, 3] = true
  [1, 2].isPrefixOf [1, 2] = true
  [1, 2].isPrefixOf [1] = false
  ```

- **Similarity Note:** Takes two lists instead of an element and a list

### 9. **List.isSublist**

- **Full Type:** `{α : Type u} [BEq α] : List α → List α → Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Documentation:**
  > True if the first list is a potentially non-contiguous sub-sequence of the second list, comparing elements with the `==` operator.

- **Examples:**
  ```lean
  [1, 3].isSublist [0, 1, 2, 3, 4] = true
  [1, 3].isSublist [0, 1, 2, 4] = false
  ```

- **Similarity Note:** Takes two lists instead of an element and a list

### 10. **List.isSuffixOf**

- **Full Type:** `{α : Type u} [BEq α] (l₁ l₂ : List α) : Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Documentation:**
  > Checks whether the first list is a suffix of the second.

- **Examples:**
  ```lean
  [2, 3].isSuffixOf [1, 2, 3] = true
  [2, 3].isSuffixOf [1, 2, 3, 4] = false
  ```

- **Similarity Note:** Takes two lists instead of an element and a list

### 11. **List.isEqv**

- **Full Type:** `{α : Type u} (as bs : List α) (eqv : α → α → Bool) : Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Complexity:** O(min |as| |bs|), short-circuits at first non-related pair
- **Documentation:**
  > Returns `true` if `as` and `bs` have the same length and they are pairwise related by `eqv`.

- **Examples:**
  ```lean
  [1, 2, 3].isEqv [2, 3, 4] (· < ·) = true
  [1, 2, 3].isEqv [2, 2, 4] (· < ·) = false
  ```

- **Similarity Note:** Takes two lists and a binary relation instead of an element and a list

### 12. **List.lex**

- **Full Type:** `{α : Type u} [BEq α] (l₁ l₂ : List α) (lt : α → α → Bool := by exact (· < ·)) : Bool`
- **Module:** `Init.Data.List.Basic`
- **Library:** Lean Core (Init)
- **Documentation:**
  > Compares lists lexicographically with respect to a comparison on their elements.

- **Similarity Note:** Takes two lists and an optional comparator instead of an element and a list

### 13. **ptrEqList**

- **Full Type:** `{α : Type u_1} (as bs : List α) : Bool`
- **Module:** `Init.Util`
- **Library:** Lean Core (Init)
- **Documentation:**
  > Compares two lists of objects for element-wise pointer equality. Returns `true` if both lists are the same length and the objects at the corresponding indices of each list are pointer-equal.
  >
  > This function is unsafe because it can distinguish between definitionally equal values.

- **Similarity Note:** Takes two lists, uses pointer equality (unsafe)

### 14. **Std.Internal.List.containsKey**

- **Full Type:** `{α : Type u} {β : α → Type v} [BEq α] (a : α) : List ((a : α) × β a) → Bool`
- **Module:** `Std.Data.Internal.List.Associative`
- **Library:** Std
- **Documentation:**
  > Internal implementation detail of the hash map

- **Similarity Note:** Works on dependent pair lists, internal API

### 15. **Std.Internal.List.Const.beqModel**

- **Full Type:** `{α : Type u} {β : Type v} [BEq α] [BEq β] (l₁ l₂ : List ((_ : α) × β)) : Bool`
- **Module:** `Std.Data.Internal.List.Associative`
- **Library:** Std
- **Documentation:**
  > Internal implementation detail of the hash map

- **Similarity Note:** Works on pair lists, internal API

### 16. **Std.Internal.List.beqModel**

- **Full Type:** `{α : Type u} {β : α → Type v} [BEq α] [LawfulBEq α] [(k : α) → BEq (β k)] (l₁ l₂ : List ((a : α) × β a)) : Bool`
- **Module:** `Std.Data.Internal.List.Associative`
- **Library:** Std
- **Documentation:**
  > Internal implementation detail of the hash map

- **Similarity Note:** Works on dependent pair lists, internal API

### 17. **Lean.Syntax.Stack.matches**

- **Full Type:** `(stack : Lean.Syntax.Stack) (pattern : List (Option Lean.SyntaxNodeKind)) : Bool`
- **Module:** `Lean.Syntax`
- **Library:** Lean Core
- **Documentation:**
  > Compare the `SyntaxNodeKind`s in `pattern` to those of the `Syntax` elements in `stack`. Return `false` if `stack` is shorter than `pattern`.

- **Similarity Note:** Specialized for syntax matching, different types

### 18. **List.isSubperm**

- **Full Type:** `{α : Type u_1} [BEq α] (l₁ l₂ : List α) : Bool`
- **Module:** `Batteries.Data.List.Basic`
- **Library:** Batteries
- **Complexity:** O(|l₁| * (|l₁| + |l₂|))
- **Documentation:**
  > Computes whether `l₁` is a sublist of a permutation of `l₂`.
  > See `isSubperm_iff` for a characterization in terms of `List.Subperm`.

- **Similarity Note:** Takes two lists instead of an element and a list

### 19. **List.all₂**

- **Full Type:** `{α : Type u_1} {β : Type u_2} (r : α → β → Bool) : List α → List β → Bool`
- **Module:** `Batteries.Data.List.Basic`
- **Library:** Batteries
- **Documentation:**
  > Check for all elements `a`, `b`, where `a` and `b` are the nth element of the first and second List respectively, that `r a b = true`.

- **Similarity Note:** Takes a binary relation and two lists (possibly of different types)

### 20. **List.containsInfix**

- **Full Type:** `{α : Type u_1} [BEq α] (l pattern : List α) : Bool`
- **Module:** `Batteries.Data.List.Matcher`
- **Library:** Batteries
- **Documentation:**
  > Returns true iff `pattern` occurs as an infix sublist of `l`.

- **Similarity Note:** Takes two lists instead of an element and a list

### 21. **Lean.Meta.Grind.EMatchTheorems.containsWithSamePatterns**

- **Full Type:** `(s : Lean.Meta.Grind.EMatchTheorems) (origin : Lean.Meta.Grind.Origin) (patterns : List Lean.Expr) (cnstrs : List Lean.Meta.Grind.EMatchTheoremConstraint) : Bool`
- **Module:** `Lean.Meta.Tactic.Grind.EMatchTheorem`
- **Library:** Lean Core
- **Documentation:**
  > Returns `true` if there is a theorem with exactly the same pattern and constraints is already in `s`

- **Similarity Note:** Specialized for theorem matching, takes multiple specialized arguments

### 22. **RegularExpression.rmatch**

- **Full Type:** `{α : Type u_1} [DecidableEq α] : RegularExpression α → List α → Bool`
- **Module:** `Mathlib.Computability.RegularExpressions`
- **Library:** Mathlib
- **Documentation:**
  > `P.rmatch x` is true if and only if `P` matches `x`. This is a computable definition equivalent to `matches'`.

- **Similarity Note:** First argument is a `RegularExpression α`, not a plain `α`

---

## Categorization by Library

### Lean Core (Init)
1. List.elem ⭐
2. List.contains
3. List.isEmpty
4. List.all
5. List.any
6. List.beq
7. List.isPerm
8. List.isPrefixOf
9. List.isSublist
10. List.isSuffixOf
11. List.isEqv
12. List.lex
13. ptrEqList

### Std Library
14. Std.Internal.List.containsKey
15. Std.Internal.List.Const.beqModel
16. Std.Internal.List.beqModel

### Batteries
17. List.isSubperm
18. List.all₂
19. List.containsInfix

### Lean Core (Other Modules)
20. Lean.Syntax.Stack.matches
21. Lean.Meta.Grind.EMatchTheorems.containsWithSamePatterns

### Mathlib
22. RegularExpression.rmatch

---

## Usage Recommendations

### For Standard Membership Checking

**Primary Recommendation: `List.elem`**

```lean
-- Exact pattern match: α → List α → Bool
example [BEq Nat] : Bool := List.elem 3 [1, 2, 3, 4]  -- true

-- Alternative: List.contains (reversed arguments)
example [BEq Nat] : Bool := List.contains [1, 2, 3, 4] 3  -- true

-- Dot notation (preferred simp normal form)
example [BEq Nat] : Bool := [1, 2, 3, 4].contains 3  -- true
```

**Key Points:**
- `List.elem` is the exact match for the type pattern `α → List α → Bool`
- Requires `[BEq α]` type class instance
- O(n) complexity
- `List.contains` is a synonym with reversed argument order
- Dot notation `.contains` is the preferred simp normal form

### For Predicate Testing

**Use `List.all` or `List.any`:**

```lean
-- Check if all elements satisfy a predicate
example : Bool := [2, 4, 6].all (· % 2 = 0)  -- true

-- Check if any element satisfies a predicate
example : Bool := [2, 4, 5, 6].any (· % 2 = 1)  -- true
```

### For List Comparison

**Multiple options available:**
- `List.beq` - equality comparison
- `List.isPerm` - permutation checking
- `List.isPrefixOf` - prefix checking
- `List.isSublist` - subsequence checking
- `List.isSuffixOf` - suffix checking

### Type Class Requirements

Most functions require `[BEq α]`:
- `List.elem`
- `List.contains`
- `List.beq`
- `List.isPerm`
- `List.isPrefixOf`
- `List.isSublist`
- `List.isSuffixOf`
- `List.lex`

Some require `[LawfulBEq α]` for theorem proving.

---

## Relationship to Logical Membership

From the documentation, when `[LawfulBEq α]` is available:

```lean
l.contains a = true ↔ a ∈ l
l.contains a = false ↔ a ∉ l
```

This connects the computable Boolean function to the logical membership predicate `∈`.

---

## Performance Characteristics

| Function | Complexity | Notes |
|----------|-----------|-------|
| List.isEmpty | O(1) | Constant time |
| List.elem | O(n) | Linear scan |
| List.contains | O(n) | Linear scan |
| List.all | O(n) | Short-circuits on false |
| List.any | O(n) | Short-circuits on true |
| List.isPerm | O(n × m) | Quadratic |
| List.isSubperm | O(n × (n + m)) | Worst case |

---

## Conclusion

The Loogle search successfully identified **`List.elem`** as the primary exact match for the type pattern `α → List α → Bool`. This function is part of Lean's core library (Init.Data.List.Basic) and is the canonical way to check membership of an element in a list using Boolean computation.

The search also revealed a rich ecosystem of related list Boolean predicates across Init, Std, Batteries, and Mathlib, providing various operations for list comparison, subsequence checking, and predicate evaluation.

For most use cases involving the type signature `α → List α → Bool`, **`List.elem`** is the recommended choice, with the understanding that the preferred simp normal form is the dot notation `list.contains element`.

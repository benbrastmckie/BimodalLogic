# Loogle API Search Report: Ordering Comparison Functions

## Search Metadata

- **Search Pattern**: `_ → _ → Ordering`
- **Search Date**: 2025-12-21 19:08:24
- **Total Declarations Mentioning Ordering**: 13530
- **Total Matches**: 9840
- **Matches Shown** (API Limit): 200
- **Exact Pattern Matches**: 8
- **Partial/Extended Matches**: 192

## Executive Summary

The Loogle search for `_ → _ → Ordering` found **9840 matching declarations** across the Lean ecosystem. The API returned the first 200 results. These functions are primarily used for:

1. **Comparison Operations**: Comparing two values of the same type
2. **Lexicographic Ordering**: Combining multiple comparisons
3. **Typeclass Instances**: Providing `Ord` instances for custom types
4. **Comparison Laws**: Establishing properties of comparison functions

### Breakdown by Library

- **Lean Core (Init)**: 138 functions
- **Lean Std**: 62 functions


### Key Categories

- **Comparator Utilities**: 64 functions
- **Comparison Functions**: 57 functions
- **Lexicographic Ordering**: 10 functions
- **Ord Instances**: 7 functions
- **Other**: 62 functions


---

## Complete List of Matches (First 200)


### 1. `Ordering.then`

- **Type**: ` (a b : Ordering) : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  If `a` and `b` are `Ordering`, then `a.then b` returns `a` unless it is `.eq`, in which case it
returns `b`. Additionally, it has “short-circuiting” behavior similar to boolean `&&`: if `a` is not
`.eq` then the expression for `b` is not evaluated.

This is a useful primitive for constructing lexicographic comparator functions. The `deriving Ord`
syntax on a structure uses the `Ord` instance to compare each field in order, combining the results
equivalently to `Ordering.then`.

Use `compareLex` ...


### 2. `Ordering.then'`

- **Type**: ` (a b : Ordering) : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Version of `Ordering.then'` for proof by reflection. 


### 3. `Ord.compare`

- **Type**: ` {α : Type u} [self : Ord α] : α → α → Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Compare two elements in `α` using the comparator contained in an `[Ord α]` instance. 


### 4. `Ord.mk`

- **Type**: ` {α : Type u} (compare : α → α → Ordering) : Ord α`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 5. `compareOn`

- **Type**: ` {β : Type u_1} {α : Sort u_2} [ord : Ord β] (f : α → β) (x y : α) : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Compares two values by comparing the results of applying a function.

In particular, `x` is compared to `y` by comparing `f x` and `f y`.

Examples:
* `compareOn (·.length) "apple" "banana" = .lt`
* `compareOn (· % 3) 5 6 = .gt`
* `compareOn (·.foldl max 0) [1, 2, 3] [3, 2, 1] = .eq`



### 6. `List.compareLex`

- **Type**: ` {α : Type u_1} (cmp : α → α → Ordering) : List α → List α → Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 7. `compareLex`

- **Type**: ` {α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Compares `a` and `b` lexicographically by `cmp₁` and `cmp₂`.

`a` and `b` are first compared by `cmp₁`. If this returns `Ordering.eq`, `a` and `b` are compared
by `cmp₂` to break the tie.

To lexicographically combine two `Ordering`s, use `Ordering.then`.



### 8. `compareOfLessAndBEq`

- **Type**: ` {α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [BEq α] : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Uses a decidable less-than relation and Boolean equality to find an `Ordering`.

In particular, if `x < y` then the result is `Ordering.lt`. If `x == y` then the result is
`Ordering.eq`. Otherwise, it is `Ordering.gt`.

`compareOfLessAndEq` uses `DecidableEq` instead of `BEq`.



### 9. `compareOfLessAndEq`

- **Type**: ` {α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [DecidableEq α] : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Uses decidable less-than and equality relations to find an `Ordering`.

In particular, if `x < y` then the result is `Ordering.lt`. If `x = y` then the result is
`Ordering.eq`. Otherwise, it is `Ordering.gt`.

`compareOfLessAndBEq` uses `BEq` instead of `DecidableEq`.



### 10. `List.compareLex_nil_nil`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} : List.compareLex cmp [] [] = Ordering.eq`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 11. `List.compareLex.eq_1`

- **Type**: ` {α : Type u_1} (cmp : α → α → Ordering) : List.compareLex cmp [] [] = Ordering.eq`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 12. `List.isGE_compareLex_nil_right`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : (List.compareLex cmp xs []).isGE = true`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 13. `List.isLE_compareLex_nil_left`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : (List.compareLex cmp [] xs).isLE = true`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 14. `List.compareLex_cons_nil`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {x : α} {xs : List α} : List.compareLex cmp (x :: xs) [] = Ordering.gt`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 15. `List.compareLex_nil_cons`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {x : α} {xs : List α} : List.compareLex cmp [] (x :: xs) = Ordering.lt`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 16. `List.compare_eq_compareLex`

- **Type**: ` {α : Type u_1} [Ord α] : compare = List.compareLex compare`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 17. `Ord.ext`

- **Type**: ` {α : Type u} {x y : Ord α} (compare : compare = compare) : x = y`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 18. `Ord.ext_iff`

- **Type**: ` {α : Type u} {x y : Ord α} : x = y ↔ compare = compare`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 19. `List.compareLex_nil_left_eq_eq`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : List.compareLex cmp [] xs = Ordering.eq ↔ xs = []`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 20. `List.compareLex_nil_right_eq_eq`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : List.compareLex cmp xs [] = Ordering.eq ↔ xs = []`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 21. `List.compareLex.eq_2`

- **Type**: ` {α : Type u_1} (cmp : α → α → Ordering) (x✝ : List α) (x_3 : x✝ = [] → False) : List.compareLex cmp [] x✝ = Ordering.lt`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 22. `List.compareLex.eq_3`

- **Type**: ` {α : Type u_1} (cmp : α → α → Ordering) (x✝ : List α) (x_3 : x✝ = [] → False) : List.compareLex cmp x✝ [] = Ordering.gt`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 23. `List.isGE_compareLex_nil_left`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : (List.compareLex cmp [] xs).isGE = true ↔ xs = []`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 24. `List.isLE_compareLex_nil_right`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : (List.compareLex cmp xs []).isLE = true ↔ xs = []`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 25. `compareLex.eq_1`

- **Type**: ` {α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : compareLex cmp₁ cmp₂ a b = (cmp₁ a b).then (cmp₂ a b)`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 26. `List.compareLex_cons_cons`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {x y : α} {xs ys : List α} : List.compareLex cmp (x :: xs) (y :: ys) = (cmp x y).then (List.compareLex cmp xs ys)`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 27. `compareLex_eq_eq`

- **Type**: ` {α : Sort u_1} {cmp₁ cmp₂ : α → α → Ordering} {a b : α} : compareLex cmp₁ cmp₂ a b = Ordering.eq ↔ cmp₁ a b = Ordering.eq ∧ cmp₂ a b = Ordering.eq`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 28. `List.compareLex.eq_4`

- **Type**: ` {α : Type u_1} (cmp : α → α → Ordering) (x_2 : α) (xs : List α) (y : α) (ys : List α) :
  List.compareLex cmp (x_2 :: xs) (y :: ys) =
    match cmp x_2 y with
    | Ordering.lt => Ordering.lt
    | Ordering.eq => List.compareLex cmp xs ys
    | Ordering.gt => Ordering.gt`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 29. `List.compareLex.eq_def`

- **Type**: ` {α : Type u_1} (cmp : α → α → Ordering) (x✝ x✝¹ : List α) :
  List.compareLex cmp x✝ x✝¹ =
    match x✝, x✝¹ with
    | [], [] => Ordering.eq
    | [], x => Ordering.lt
    | x, [] => Ordering.gt
    | x :: xs, y :: ys =>
      match cmp x y with
      | Ordering.lt => Ordering.lt
      | Ordering.eq => List.compareLex cmp xs ys
      | Ordering.gt => Ordering.gt`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 30. `Array.compareLex`

- **Type**: ` {α : Type u_1} (cmp : α → α → Ordering) (a₁ a₂ : Array α) : Ordering`
- **Module**: `Init.Data.Ord.Array`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 31. `Array.compare_eq_compareLex`

- **Type**: ` {α : Type u_1} [Ord α] : compare = Array.compareLex compare`
- **Module**: `Init.Data.Ord.Array`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 32. `Array.compareLex_eq_compareLex_toList`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {a₁ a₂ : Array α} : Array.compareLex cmp a₁ a₂ = List.compareLex cmp a₁.toList a₂.toList`
- **Module**: `Init.Data.Ord.Array`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 33. `List.compareLex_eq_compareLex_toArray`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} {l₁ l₂ : List α} : List.compareLex cmp l₁ l₂ = Array.compareLex cmp l₁.toArray l₂.toArray`
- **Module**: `Init.Data.Ord.Array`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 34. `Std.LawfulEqCmp`

- **Type**: ` {α : Type u} (cmp : α → α → Ordering) : Prop`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  A typeclass for comparison functions satisfying `cmp a b = .eq` if and only if the logical equality
`a = b` holds.

This typeclass distinguishes itself from `LawfulBEqCmp` by using logical equality (`=`) instead of
boolean equality (`==`).



### 35. `Std.OrientedCmp`

- **Type**: ` {α : Type u} (cmp : α → α → Ordering) : Prop`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  A typeclass for functions `α → α → Ordering` which are oriented: flipping the arguments amounts
to applying `Ordering.swap` to the return value.



### 36. `Std.ReflCmp`

- **Type**: ` {α : Type u} (cmp : α → α → Ordering) : Prop`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  A typeclass for comparison functions `cmp` for which `cmp a a = .eq` for all `a`. 


### 37. `Std.TransCmp`

- **Type**: ` {α : Type u} (cmp : α → α → Ordering) : Prop`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  A typeclass for functions `α → α → Ordering` which are transitive. 


### 38. `Std.LawfulBEqCmp`

- **Type**: ` {α : Type u} [BEq α] (cmp : α → α → Ordering) : Prop`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  A typeclass for comparison functions satisfying `cmp a b = .eq` if and only if the boolean equality
`a == b` holds.

This typeclass distinguishes itself from `LawfulEqCmp` by using boolean equality (`==`) instead of
logical equality (`=`).



### 39. `Std.instReflCmpOfOrientedCmp`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] : Std.ReflCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 40. `Std.LawfulEqCmp.toReflCmp`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [self : Std.LawfulEqCmp cmp] : Std.ReflCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 41. `Std.TransCmp.toOrientedCmp`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [self : Std.TransCmp cmp] : Std.OrientedCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 42. `Array.instLawfulEqCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] : Std.LawfulEqCmp (Array.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 43. `Array.instOrientedCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] : Std.OrientedCmp (Array.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 44. `Array.instReflCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.ReflCmp cmp] : Std.ReflCmp (Array.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 45. `Array.instTransCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.TransCmp cmp] : Std.TransCmp (Array.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 46. `List.instLawfulEqCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] : Std.LawfulEqCmp (List.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 47. `List.instOrientedCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] : Std.OrientedCmp (List.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 48. `List.instReflCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.ReflCmp cmp] : Std.ReflCmp (List.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 49. `List.instTransCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.TransCmp cmp] : Std.TransCmp (List.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 50. `Std.OrientedCmp.opposite`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] : Std.OrientedCmp fun a b => cmp b a`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 51. `Std.ReflCmp.compare_self`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [self : Std.ReflCmp cmp] {a : α} : cmp a a = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Comparison is reflexive. 


### 52. `Std.ReflCmp.mk`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} (compare_self : ∀ {a : α}, cmp a a = Ordering.eq) : Std.ReflCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 53. `Std.TransCmp.opposite`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] : Std.TransCmp fun a b => cmp b a`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 54. `Std.ReflCmp.isLE_rfl`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.ReflCmp cmp] {a : α} : (cmp a a).isLE = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 55. `Std.instLawfulBEqCmpOfLawfulEqCmpOfLawfulBEq`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] [LawfulBEq α] : Std.LawfulBEqCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 56. `Std.LawfulBEqCmp.equivBEq`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [inst : Std.LawfulBEqCmp cmp] [Std.TransCmp cmp] : EquivBEq α`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 57. `Std.LawfulBEqCmp.lawfulBEq`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [inst : Std.LawfulBEqCmp cmp] [Std.LawfulEqCmp cmp] : LawfulBEq α`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 58. `Std.LawfulBEqCmp.lawfulEqCmp`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [inst : Std.LawfulBEqCmp cmp] [LawfulBEq α] : Std.LawfulEqCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 59. `Std.LawfulBEqCmp.reflBEq`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [inst : Std.LawfulBEqCmp cmp] [Std.ReflCmp cmp] : ReflBEq α`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 60. `Std.LawfulEqCmp.opposite`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] [Std.LawfulEqCmp cmp] : Std.LawfulEqCmp fun a b => cmp b a`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 61. `Std.OrientedCmp.eq_swap`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [self : Std.OrientedCmp cmp] {a b : α} : cmp a b = (cmp b a).swap`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Swapping the arguments to `cmp` swaps the outcome. 


### 62. `Std.OrientedCmp.mk`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} (eq_swap : ∀ {a b : α}, cmp a b = (cmp b a).swap) : Std.OrientedCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 63. `Array.instLawfulBEqCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [BEq α] [Std.LawfulBEqCmp cmp] : Std.LawfulBEqCmp (Array.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 64. `List.instLawfulBEqCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [BEq α] [Std.LawfulBEqCmp cmp] : Std.LawfulBEqCmp (List.compareLex cmp)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 65. `Std.LawfulEqCmp.eq_of_compare`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [self : Std.LawfulEqCmp cmp] {a b : α} : cmp a b = Ordering.eq → a = b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  If two values compare equal, then they are logically equal. 


### 66. `Std.OrientedCmp.isGE_eq_isLE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : (cmp a b).isGE = (cmp b a).isLE`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 67. `Std.OrientedCmp.isGT_eq_isLT`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : (cmp a b).isGT = (cmp b a).isLT`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 68. `Std.ReflCmp.cmp_eq_of_eq`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.ReflCmp cmp] {a b : α} : a = b → cmp a b = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 69. `Std.ReflCmp.ne_of_cmp_ne_eq`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.ReflCmp cmp] {a b : α} : cmp a b ≠ Ordering.eq → a ≠ b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 70. `Std.instOrientedCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp₁ cmp₂ : α → α → Ordering} [Std.OrientedCmp cmp₁] [Std.OrientedCmp cmp₂] : Std.OrientedCmp (compareLex cmp₁ cmp₂)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 71. `Std.instReflCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp₁ cmp₂ : α → α → Ordering} [Std.ReflCmp cmp₁] [Std.ReflCmp cmp₂] : Std.ReflCmp (compareLex cmp₁ cmp₂)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 72. `Std.instTransCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp₁ cmp₂ : α → α → Ordering} [Std.TransCmp cmp₁] [Std.TransCmp cmp₂] : Std.TransCmp (compareLex cmp₁ cmp₂)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 73. `Std.LawfulEqCmp.compare_eq_iff_eq`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] {a b : α} : cmp a b = Ordering.eq ↔ a = b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 74. `Std.LawfulBEqCmp.opposite`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.OrientedCmp cmp] [Std.LawfulBEqCmp cmp] : Std.LawfulBEqCmp fun a b => cmp b a`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 75. `Std.OrientedCmp.eq_symm`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.eq → cmp b a = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 76. `Std.OrientedCmp.gt_of_lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.lt → cmp b a = Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 77. `Std.OrientedCmp.lt_of_gt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.gt → cmp b a = Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 78. `Std.OrientedCmp.not_gt_of_gt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.gt → cmp b a ≠ Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 79. `Std.OrientedCmp.not_lt_of_lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.lt → cmp b a ≠ Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 80. `Std.LawfulEqCmp.mk`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [toReflCmp : Std.ReflCmp cmp] (eq_of_compare : ∀ {a b : α}, cmp a b = Ordering.eq → a = b) : Std.LawfulEqCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 81. `Std.OrientedCmp.eq_comm`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.eq ↔ cmp b a = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 82. `Std.OrientedCmp.gt_iff_lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.gt ↔ cmp b a = Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 83. `Std.OrientedCmp.not_gt_of_isGE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : (cmp a b).isGE = true → cmp b a ≠ Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 84. `Std.OrientedCmp.not_lt_of_isLE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : (cmp a b).isLE = true → cmp b a ≠ Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 85. `Std.LawfulBEqCmp.isEq_compare_eq_beq`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.LawfulBEqCmp cmp] {a b : α} : (cmp a b).isEq = (a == b)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 86. `Std.OrientedCmp.gt_of_not_isGE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : ¬(cmp a b).isGE = true → cmp b a = Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 87. `Std.OrientedCmp.isGE_of_isLE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : (cmp b a).isLE = true → (cmp a b).isGE = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 88. `Std.OrientedCmp.isLE_of_isGE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : (cmp b a).isGE = true → (cmp a b).isLE = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 89. `Std.OrientedCmp.lt_of_not_isLE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : ¬(cmp a b).isLE = true → cmp b a = Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 90. `Std.OrientedCmp.not_isGE_of_gt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.gt → ¬(cmp b a).isGE = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 91. `Std.OrientedCmp.not_isLE_of_lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : cmp a b = Ordering.lt → ¬(cmp b a).isLE = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 92. `Std.OrientedCmp.isGE_iff_isLE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} : (cmp a b).isGE = true ↔ (cmp b a).isLE = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 93. `Std.TransCmp.congr_left`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.eq) : cmp a c = cmp b c`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 94. `Std.TransCmp.congr_right`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hbc : cmp b c = Ordering.eq) : cmp a b = cmp a c`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 95. `Std.LawfulEqCmp.compare_beq_iff_eq`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] {a b : α} : (cmp a b == Ordering.eq) = true ↔ a = b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 96. `Std.LawfulBEqCmp.compare_eq_iff_beq`

- **Type**: ` {α : Type u} {inst✝ : BEq α} {cmp : α → α → Ordering} [self : Std.LawfulBEqCmp cmp] {a b : α} : cmp a b = Ordering.eq ↔ (a == b) = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  If two values compare equal, then they are boolean equal. 


### 97. `Std.LawfulBEqCmp.mk`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} (compare_eq_iff_beq : ∀ {a b : α}, cmp a b = Ordering.eq ↔ (a == b) = true) : Std.LawfulBEqCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 98. `Std.LawfulBEqCmp.compare_beq_eq_beq`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.LawfulBEqCmp cmp] {a b : α} : (cmp a b == Ordering.eq) = (a == b)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 99. `Std.LawfulBEqCmp.not_compare_eq_iff_beq_eq_false`

- **Type**: ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.LawfulBEqCmp cmp] {a b : α} : ¬cmp a b = Ordering.eq ↔ (a == b) = false`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 100. `Std.TransCmp.eq_trans`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.eq) (hbc : cmp b c = Ordering.eq) : cmp a c = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 101. `Std.TransCmp.gt_of_eq_of_gt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.eq) (hbc : cmp b c = Ordering.gt) : cmp a c = Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 102. `Std.TransCmp.gt_of_gt_of_eq`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.gt) (hbc : cmp b c = Ordering.eq) : cmp a c = Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 103. `Std.TransCmp.gt_of_gt_of_gt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.gt) (hbc : cmp b c = Ordering.gt) : cmp a c = Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 104. `Std.TransCmp.gt_trans`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.gt) (hbc : cmp b c = Ordering.gt) : cmp a c = Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 105. `Std.TransCmp.lt_of_eq_of_lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.eq) (hbc : cmp b c = Ordering.lt) : cmp a c = Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 106. `Std.TransCmp.lt_of_lt_of_eq`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.lt) (hbc : cmp b c = Ordering.eq) : cmp a c = Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 107. `Std.TransCmp.lt_trans`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.lt) (hbc : cmp b c = Ordering.lt) : cmp a c = Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 108. `Std.OrientedCmp.isGE_antisymm`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} (h₁ : (cmp a b).isGE = true) (h₂ : (cmp b a).isGE = true) : cmp a b = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 109. `Std.OrientedCmp.isLE_antisymm`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {a b : α} (h₁ : (cmp a b).isLE = true) (h₂ : (cmp b a).isLE = true) : cmp a b = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 110. `Std.TransCmp.gt_of_gt_of_isGE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.gt) (hbc : (cmp b c).isGE = true) : cmp a c = Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 111. `Std.TransCmp.gt_of_isGE_of_gt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : (cmp a b).isGE = true) (hbc : cmp b c = Ordering.gt) : cmp a c = Ordering.gt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 112. `Std.TransCmp.lt_of_isLE_of_lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : (cmp a b).isLE = true) (hbc : cmp b c = Ordering.lt) : cmp a c = Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 113. `Std.TransCmp.lt_of_lt_of_isLE`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (hab : cmp a b = Ordering.lt) (hbc : (cmp b c).isLE = true) : cmp a c = Ordering.lt`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 114. `Std.TransCmp.isGE_trans`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] {a b c : α} (h₁ : (cmp a b).isGE = true) (h₂ : (cmp b c).isGE = true) : (cmp a c).isGE = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 115. `Std.TransCmp.isLE_trans`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [self : Std.TransCmp cmp] {a b c : α} : (cmp a b).isLE = true → (cmp b c).isLE = true → (cmp a c).isLE = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  Transitivity of `cmp`, expressed via `Ordering.isLE`. 


### 116. `Std.TransCmp.mk`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} [toOrientedCmp : Std.OrientedCmp cmp] (isLE_trans : ∀ {a b c : α}, (cmp a b).isLE = true → (cmp b c).isLE = true → (cmp a c).isLE = true) : Std.TransCmp cmp`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 117. `Vector.compareLex`

- **Type**: ` {α : Type u_1} {n : ℕ} (cmp : α → α → Ordering) (a b : Vector α n) : Ordering`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 118. `Vector.instLawfulEqCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] {n : ℕ} : Std.LawfulEqCmp (Vector.compareLex cmp)`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 119. `Vector.instOrientedCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] {n : ℕ} : Std.OrientedCmp (Vector.compareLex cmp)`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 120. `Vector.instReflCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.ReflCmp cmp] {n : ℕ} : Std.ReflCmp (Vector.compareLex cmp)`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 121. `Vector.instTransCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [Std.TransCmp cmp] {n : ℕ} : Std.TransCmp (Vector.compareLex cmp)`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 122. `Vector.instLawfulBEqCmpCompareLex`

- **Type**: ` {α : Type u_1} {cmp : α → α → Ordering} [BEq α] [Std.LawfulBEqCmp cmp] {n : ℕ} : Std.LawfulBEqCmp (Vector.compareLex cmp)`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 123. `Vector.compareLex_eq_compareLex_toArray`

- **Type**: ` {α : Type u_1} {n : ℕ} {cmp : α → α → Ordering} {a b : Vector α n} : Vector.compareLex cmp a b = Array.compareLex cmp a.toArray b.toArray`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 124. `Vector.compareLex_eq_compareLex_toList`

- **Type**: ` {α : Type u_1} {n : ℕ} {cmp : α → α → Ordering} {a b : Vector α n} : Vector.compareLex cmp a b = List.compareLex cmp a.toList b.toList`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 125. `IO.instOrdTaskState.ord`

- **Type**: ` : IO.TaskState → IO.TaskState → Ordering`
- **Module**: `Init.System.IO`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 126. `IO.FS.instOrdSystemTime.ord`

- **Type**: ` : IO.FS.SystemTime → IO.FS.SystemTime → Ordering`
- **Module**: `Init.System.IO`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 127. `Lean.Grind.CommRing.powerRevlex`

- **Type**: ` (k₁ k₂ : ℕ) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 128. `Lean.Grind.CommRing.powerRevlex_k`

- **Type**: ` (k₁ k₂ : ℕ) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 129. `Lean.Grind.CommRing.Mon.grevlex`

- **Type**: ` (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 130. `Lean.Grind.CommRing.Mon.grevlex_k`

- **Type**: ` (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 131. `Lean.Grind.CommRing.Mon.revlex`

- **Type**: ` (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 132. `Lean.Grind.CommRing.Mon.revlexWF`

- **Type**: ` (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 133. `Lean.Grind.CommRing.Mon.revlex_k`

- **Type**: ` : Lean.Grind.CommRing.Mon → Lean.Grind.CommRing.Mon → Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 134. `Lean.Grind.CommRing.Power.revlex`

- **Type**: ` (p₁ p₂ : Lean.Grind.CommRing.Power) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 135. `Lean.Grind.CommRing.Var.revlex`

- **Type**: ` (x y : Lean.Grind.CommRing.Var) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 136. `Lean.Grind.CommRing.Mon.revlexFuel`

- **Type**: ` (fuel : ℕ) (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **Module**: `Init.Grind.Ring.CommSolver`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 137. `Std.LawfulOrderCmp`

- **Type**: ` {α : Type u_1} (cmp : α → α → Ordering) [LE α] : Prop`
- **Module**: `Init.Data.Order.ClassesExtra`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 138. `Std.OrientedCmp.of_gt_iff_lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} (h : ∀ (a b : α), cmp a b = Ordering.gt ↔ cmp b a = Ordering.lt) : Std.OrientedCmp cmp`
- **Module**: `Init.Data.Order.PackageFactories`
- **Library**: Lean Core (Init)
- **Documentation**: 

  *No documentation available*


### 139. `Std.Internal.IsCut`

- **Type**: ` {α : Type u} (cmp : α → α → Ordering) (cut : α → Ordering) : Prop`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 140. `Std.Internal.IsStrictCut`

- **Type**: ` {α : Type u} (cmp : α → α → Ordering) (cut : α → Ordering) : Prop`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 141. `Std.Internal.IsStrictCut.toIsCut`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [self : Std.Internal.IsStrictCut cmp cut] : Std.Internal.IsCut cmp cut`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 142. `Std.Internal.IsStrictCut.eq`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [self : Std.Internal.IsStrictCut cmp cut] (k : α) {k' : α} : cut k' = Ordering.eq → cut k = cmp k' k`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 143. `Std.Internal.IsCut.gt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [self : Std.Internal.IsCut cmp cut] {k k' : α} : cut k' = Ordering.gt → cmp k' k = Ordering.gt → cut k = Ordering.gt`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 144. `Std.Internal.IsCut.lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [self : Std.Internal.IsCut cmp cut] {k k' : α} : cut k' = Ordering.lt → cmp k' k = Ordering.lt → cut k = Ordering.lt`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 145. `Std.Internal.IsStrictCut.mk`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [toIsCut : Std.Internal.IsCut cmp cut] (eq : ∀ (k : α) {k' : α}, cut k' = Ordering.eq → cut k = cmp k' k) : Std.Internal.IsStrictCut cmp cut`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 146. `Std.Internal.IsStrictCut.gt_of_isGE_of_gt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [Std.Internal.IsStrictCut cmp cut] {k k' : α} : (cut k').isGE = true → cmp k' k = Ordering.gt → cut k = Ordering.gt`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 147. `Std.Internal.IsStrictCut.lt_of_isLE_of_lt`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [Std.Internal.IsStrictCut cmp cut] {k k' : α} : (cut k').isLE = true → cmp k' k = Ordering.lt → cut k = Ordering.lt`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 148. `Std.Internal.IsCut.mk`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} (lt : ∀ {k k' : α}, cut k' = Ordering.lt → cmp k' k = Ordering.lt → cut k = Ordering.lt) (gt : ∀ {k k' : α}, cut k' = Ordering.gt → cmp k' k = Ordering.gt → cut k = Ordering.gt) : Std.Internal.IsCut cmp cut`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 149. `Std.DTreeMap`

- **Type**: ` (α : Type u) (β : α → Type v) (cmp : α → α → Ordering := by exact compare) : Type (max u v)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Dependent tree maps.

A tree map stores an assignment of keys to values. It depends on a comparator function that
defines an ordering on the keys and provides efficient order-dependent queries, such as retrieval
of the minimum or maximum.

To ensure that the operations behave as expected, the comparator function `cmp` should satisfy
certain laws that ensure a consistent ordering:

* If `a` is less than (or equal) to `b`, then `b` is greater than (or equal) to `a`
and vice versa (see the `Oriente...


### 150. `Std.DTreeMap.empty`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : Std.DTreeMap α β cmp`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Creates a new empty tree map. It is also possible and recommended to
use the empty collection notations `∅` and `{}` to create an empty tree map. `simp` replaces
`empty` with `∅`.



### 151. `Std.DTreeMap.instEmptyCollection`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : EmptyCollection (Std.DTreeMap α β cmp)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 152. `Std.DTreeMap.instInhabited`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : Inhabited (Std.DTreeMap α β cmp)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 153. `Std.DTreeMap.instInter`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : Inter (Std.DTreeMap α β cmp)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 154. `Std.DTreeMap.instSDiff`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : SDiff (Std.DTreeMap α β cmp)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 155. `Std.DTreeMap.instUnion`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : Union (Std.DTreeMap α β cmp)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 156. `Std.DTreeMap.isEmpty`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) : Bool`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns `true` if the tree map contains no mappings. 


### 157. `Std.DTreeMap.size`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) : ℕ`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns the number of mappings present in the map. 


### 158. `Std.DTreeMap.contains`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (a : α) : Bool`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns `true` if there is a mapping for the given key `a` or a key that is equal to `a` according
to the comparator `cmp`. There is also a `Prop`-valued version
of this: `a ∈ t` is equivalent to `t.contains a = true`.

Observe that this is different behavior than for lists: for lists, `∈` uses `=` and `contains` uses
`==` for equality checks, while for tree maps, both use the given comparator `cmp`.



### 159. `Std.DTreeMap.instMembership`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : Membership α (Std.DTreeMap α β cmp)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  *No documentation available*


### 160. `Std.DTreeMap.keys`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) : List α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns a list of all keys present in the tree map in ascending  order. 


### 161. `Std.DTreeMap.keysArray`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) : Array α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns an array of all keys present in the tree map in ascending  order. 


### 162. `Std.DTreeMap.maxKey?`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) : Option α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key in the tree map, returning `none` if the map is empty.



### 163. `Std.DTreeMap.maxKeyD`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (fallback : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key in the tree map, returning `fallback` if the tree map is empty.



### 164. `Std.DTreeMap.minKey?`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) : Option α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key in the tree map, returning `none` if the map is empty.



### 165. `Std.DTreeMap.minKeyD`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (fallback : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key in the tree map, returning `fallback` if the tree map is empty.



### 166. `Std.DTreeMap.values`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) : List β`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns a list of all values present in the tree map in ascending  order. 


### 167. `Std.DTreeMap.valuesArray`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) : Array β`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns an array of all values present in the tree map in ascending  order. 


### 168. `Std.DTreeMap.getKey?`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (a : α) : Option α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Checks if a mapping for the given key exists and returns the key if it does, otherwise `none`.
The result in the `some` case is guaranteed to be pointer equal to the key in the map.



### 169. `Std.DTreeMap.getKeyD`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (a fallback : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Checks if a mapping for the given key exists and returns the key if it does, otherwise `fallback`.
If a mapping exists the result is guaranteed to be pointer equal to the key in the map.



### 170. `Std.DTreeMap.getKeyGE?`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (k : α) : Option α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key that is greater than or equal to the
given key, returning `none` if no such key exists.



### 171. `Std.DTreeMap.getKeyGED`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (k fallback : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key that is greater than or equal to the
given key, returning `fallback` if no such key exists.



### 172. `Std.DTreeMap.getKeyGT?`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (k : α) : Option α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key that is greater than the given key,
returning `none` if no such key exists.



### 173. `Std.DTreeMap.getKeyGTD`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (k fallback : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key that is greater than the given key,
returning `fallback` if no such key exists.



### 174. `Std.DTreeMap.getKeyLE?`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (k : α) : Option α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key that is less than or equal to the
given key, returning `none` if no such key exists.



### 175. `Std.DTreeMap.getKeyLED`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (k fallback : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key that is less than or equal to the
given key, returning `fallback` if no such key exists.



### 176. `Std.DTreeMap.getKeyLT?`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (k : α) : Option α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key that is less than the given key,
returning `none` if no such key exists.



### 177. `Std.DTreeMap.getKeyLTD`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (k fallback : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key that is less than the given key,
returning `fallback` if no such key exists.



### 178. `Std.DTreeMap.keyAtIdx?`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (n : ℕ) : Option α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns the `n`-th smallest key, or `none` if `n` is at least `t.size`. 


### 179. `Std.DTreeMap.keyAtIdxD`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (n : ℕ) (fallback : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns the `n`-th smallest key, or `fallback` if `n` is at least `t.size`. 


### 180. `Std.DTreeMap.maxKey!`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Inhabited α] (t : Std.DTreeMap α β cmp) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key in the tree map, panicking if the map is empty.



### 181. `Std.DTreeMap.minKey!`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Inhabited α] (t : Std.DTreeMap α β cmp) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key in the tree map, panicking if the map is empty.



### 182. `Std.DTreeMap.Const.get?`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) (a : α) : Option β`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the mapping for the given key, returning `none` if no such mapping is present.

Uses the `LawfulEqCmp` instance to cast the retrieved value to the correct type.



### 183. `Std.DTreeMap.Const.getD`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) (a : α) (fallback : β) : β`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the mapping for the given key, returning `fallback` if no such mapping is present.

Uses the `LawfulEqCmp` instance to cast the retrieved value to the correct type.



### 184. `Std.DTreeMap.Const.unitOfArray`

- **Type**: ` {α : Type u} (a : Array α) (cmp : α → α → Ordering := by exact compare) : Std.DTreeMap α (fun x => Unit) cmp`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Transforms an array of keys into a tree map. 


### 185. `Std.DTreeMap.Const.unitOfList`

- **Type**: ` {α : Type u} (l : List α) (cmp : α → α → Ordering := by exact compare) : Std.DTreeMap α (fun x => Unit) cmp`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Transforms a list of keys into a tree map. 


### 186. `Std.DTreeMap.getKey!`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Inhabited α] (t : Std.DTreeMap α β cmp) (a : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Checks if a mapping for the given key exists and returns the key if it does, otherwise panics.
If no panic occurs the result is guaranteed to be pointer equal to the key in the map.



### 187. `Std.DTreeMap.getKeyGE!`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Inhabited α] (t : Std.DTreeMap α β cmp) (k : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key that is greater than or equal to the
given key, panicking if no such key exists.



### 188. `Std.DTreeMap.getKeyGT!`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Inhabited α] (t : Std.DTreeMap α β cmp) (k : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the smallest key that is greater than the given key,
panicking if no such key exists.



### 189. `Std.DTreeMap.getKeyLE!`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Inhabited α] (t : Std.DTreeMap α β cmp) (k : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key that is less than or equal to the
given key, panicking if no such key exists.



### 190. `Std.DTreeMap.getKeyLT!`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Inhabited α] (t : Std.DTreeMap α β cmp) (k : α) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the largest key that is less than the given key,
panicking if no such key exists.



### 191. `Std.DTreeMap.keyAtIdx!`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Inhabited α] (t : Std.DTreeMap α β cmp) (n : ℕ) : α`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Returns the `n`-th smallest key, or panics if `n` is at least `t.size`. 


### 192. `Std.DTreeMap.Const.get!`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} [Inhabited β] (t : Std.DTreeMap α (fun x => β) cmp) (a : α) : β`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the mapping for the given key, panicking if no such mapping is present.

Uses the `LawfulEqCmp` instance to cast the retrieved value to the correct type.



### 193. `Std.DTreeMap.Const.maxEntry?`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) : Option (α × β)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the key-value pair with the largest key in the tree map, returning `none` if the
map is empty.



### 194. `Std.DTreeMap.Const.minEntry?`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) : Option (α × β)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Tries to retrieve the key-value pair with the smallest key in the tree map, returning `none` if the
map is empty.



### 195. `Std.DTreeMap.Const.toArray`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) : Array (α × β)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Transforms the tree map into a list of mappings in ascending order. 


### 196. `Std.DTreeMap.Const.toList`

- **Type**: ` {α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) : List (α × β)`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Transforms the tree map into a list of mappings in ascending order. 


### 197. `Std.DTreeMap.Equiv`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (m₁ m₂ : Std.DTreeMap α β cmp) : Prop`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Two tree maps are equivalent in the sense of Equiv iff all the keys and values are equal. 


### 198. `Std.DTreeMap.all`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (p : (a : α) → β a → Bool) : Bool`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Check if all elements satisfy the predicate, short-circuiting if a predicate fails. 


### 199. `Std.DTreeMap.any`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (p : (a : α) → β a → Bool) : Bool`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Check if any element satisfies the predicate, short-circuiting if a predicate fails. 


### 200. `Std.DTreeMap.erase`

- **Type**: ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (a : α) : Std.DTreeMap α β cmp`
- **Module**: `Std.Data.DTreeMap.Basic`
- **Library**: Lean Std
- **Documentation**: 

  Removes the mapping for the given key if it exists. 



---

## Categorization by Library


### Lean Core (Init) (138 functions)

- `Ordering.then`: `Init.Data.Ord.Basic`
- `Ordering.then'`: `Init.Data.Ord.Basic`
- `Ord.compare`: `Init.Data.Ord.Basic`
- `Ord.mk`: `Init.Data.Ord.Basic`
- `compareOn`: `Init.Data.Ord.Basic`
- `List.compareLex`: `Init.Data.Ord.Basic`
- `compareLex`: `Init.Data.Ord.Basic`
- `compareOfLessAndBEq`: `Init.Data.Ord.Basic`
- `compareOfLessAndEq`: `Init.Data.Ord.Basic`
- `List.compareLex_nil_nil`: `Init.Data.Ord.Basic`
- `List.compareLex.eq_1`: `Init.Data.Ord.Basic`
- `List.isGE_compareLex_nil_right`: `Init.Data.Ord.Basic`
- `List.isLE_compareLex_nil_left`: `Init.Data.Ord.Basic`
- `List.compareLex_cons_nil`: `Init.Data.Ord.Basic`
- `List.compareLex_nil_cons`: `Init.Data.Ord.Basic`
- `List.compare_eq_compareLex`: `Init.Data.Ord.Basic`
- `Ord.ext`: `Init.Data.Ord.Basic`
- `Ord.ext_iff`: `Init.Data.Ord.Basic`
- `List.compareLex_nil_left_eq_eq`: `Init.Data.Ord.Basic`
- `List.compareLex_nil_right_eq_eq`: `Init.Data.Ord.Basic`

  *...and 118 more*


### Lean Std (62 functions)

- `Std.Internal.IsCut`: `Std.Data.Internal.Cut`
- `Std.Internal.IsStrictCut`: `Std.Data.Internal.Cut`
- `Std.Internal.IsStrictCut.toIsCut`: `Std.Data.Internal.Cut`
- `Std.Internal.IsStrictCut.eq`: `Std.Data.Internal.Cut`
- `Std.Internal.IsCut.gt`: `Std.Data.Internal.Cut`
- `Std.Internal.IsCut.lt`: `Std.Data.Internal.Cut`
- `Std.Internal.IsStrictCut.mk`: `Std.Data.Internal.Cut`
- `Std.Internal.IsStrictCut.gt_of_isGE_of_gt`: `Std.Data.Internal.Cut`
- `Std.Internal.IsStrictCut.lt_of_isLE_of_lt`: `Std.Data.Internal.Cut`
- `Std.Internal.IsCut.mk`: `Std.Data.Internal.Cut`
- `Std.DTreeMap`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.empty`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.instEmptyCollection`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.instInhabited`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.instInter`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.instSDiff`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.instUnion`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.isEmpty`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.size`: `Std.Data.DTreeMap.Basic`
- `Std.DTreeMap.contains`: `Std.Data.DTreeMap.Basic`

  *...and 42 more*



---

## Categorization by Function Type


### Comparator Utilities (64 functions)

- **`Std.LawfulEqCmp`** - ` {α : Type u} (cmp : α → α → Ordering) : Prop`
  - A typeclass for comparison functions satisfying `cmp a b = .eq` if and only if the logical equality...
- **`Std.OrientedCmp`** - ` {α : Type u} (cmp : α → α → Ordering) : Prop`
  - A typeclass for functions `α → α → Ordering` which are oriented: flipping the arguments amounts...
- **`Std.ReflCmp`** - ` {α : Type u} (cmp : α → α → Ordering) : Prop`
  - A typeclass for comparison functions `cmp` for which `cmp a a = .eq` for all `a`. ...
- **`Std.TransCmp`** - ` {α : Type u} (cmp : α → α → Ordering) : Prop`
  - A typeclass for functions `α → α → Ordering` which are transitive. ...
- **`Std.LawfulBEqCmp`** - ` {α : Type u} [BEq α] (cmp : α → α → Ordering) : Prop`
  - A typeclass for comparison functions satisfying `cmp a b = .eq` if and only if the boolean equality...
- **`Std.instReflCmpOfOrientedCmp`** - ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] : Std.ReflCmp cmp`
- **`Std.LawfulEqCmp.toReflCmp`** - ` {α : Type u} {cmp : α → α → Ordering} [self : Std.LawfulEqCmp cmp] : Std.ReflCmp cmp`
- **`Std.TransCmp.toOrientedCmp`** - ` {α : Type u} {cmp : α → α → Ordering} [self : Std.TransCmp cmp] : Std.OrientedCmp cmp`
- **`Std.OrientedCmp.opposite`** - ` {α : Type u} {cmp : α → α → Ordering} [Std.OrientedCmp cmp] : Std.OrientedCmp fun a b => cmp b a`
- **`Std.ReflCmp.mk`** - ` {α : Type u} {cmp : α → α → Ordering} (compare_self : ∀ {a : α}, cmp a a = Ordering.eq) : Std.ReflCmp cmp`
- **`Std.TransCmp.opposite`** - ` {α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] : Std.TransCmp fun a b => cmp b a`
- **`Std.ReflCmp.isLE_rfl`** - ` {α : Type u_1} {cmp : α → α → Ordering} [Std.ReflCmp cmp] {a : α} : (cmp a a).isLE = true`
- **`Std.instLawfulBEqCmpOfLawfulEqCmpOfLawfulBEq`** - ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] [LawfulBEq α] : Std.LawfulBEqCmp cmp`
- **`Std.LawfulBEqCmp.equivBEq`** - ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [inst : Std.LawfulBEqCmp cmp] [Std.TransCmp cmp] : EquivBEq α`
- **`Std.LawfulBEqCmp.lawfulBEq`** - ` {α : Type u} [BEq α] {cmp : α → α → Ordering} [inst : Std.LawfulBEqCmp cmp] [Std.LawfulEqCmp cmp] : LawfulBEq α`

  *...and 49 more*


### Comparison Functions (57 functions)

- **`Ord.compare`** - ` {α : Type u} [self : Ord α] : α → α → Ordering`
  - Compare two elements in `α` using the comparator contained in an `[Ord α]` instance. ...
- **`compareOn`** - ` {β : Type u_1} {α : Sort u_2} [ord : Ord β] (f : α → β) (x y : α) : Ordering`
  - Compares two values by comparing the results of applying a function....
- **`List.compareLex`** - ` {α : Type u_1} (cmp : α → α → Ordering) : List α → List α → Ordering`
- **`compareLex`** - ` {α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : Ordering`
  - Compares `a` and `b` lexicographically by `cmp₁` and `cmp₂`....
- **`compareOfLessAndBEq`** - ` {α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [BEq α] : Ordering`
  - Uses a decidable less-than relation and Boolean equality to find an `Ordering`....
- **`compareOfLessAndEq`** - ` {α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [DecidableEq α] : Ordering`
  - Uses decidable less-than and equality relations to find an `Ordering`....
- **`List.compareLex_nil_nil`** - ` {α : Type u_1} {cmp : α → α → Ordering} : List.compareLex cmp [] [] = Ordering.eq`
- **`List.compareLex.eq_1`** - ` {α : Type u_1} (cmp : α → α → Ordering) : List.compareLex cmp [] [] = Ordering.eq`
- **`List.isGE_compareLex_nil_right`** - ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : (List.compareLex cmp xs []).isGE = true`
- **`List.isLE_compareLex_nil_left`** - ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : (List.compareLex cmp [] xs).isLE = true`
- **`List.compareLex_cons_nil`** - ` {α : Type u_1} {cmp : α → α → Ordering} {x : α} {xs : List α} : List.compareLex cmp (x :: xs) [] = Ordering.gt`
- **`List.compareLex_nil_cons`** - ` {α : Type u_1} {cmp : α → α → Ordering} {x : α} {xs : List α} : List.compareLex cmp [] (x :: xs) = Ordering.lt`
- **`List.compare_eq_compareLex`** - ` {α : Type u_1} [Ord α] : compare = List.compareLex compare`
- **`List.compareLex_nil_left_eq_eq`** - ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : List.compareLex cmp [] xs = Ordering.eq ↔ xs = []`
- **`List.compareLex_nil_right_eq_eq`** - ` {α : Type u_1} {cmp : α → α → Ordering} {xs : List α} : List.compareLex cmp xs [] = Ordering.eq ↔ xs = []`

  *...and 42 more*


### Lexicographic Ordering (10 functions)

- **`Lean.Grind.CommRing.powerRevlex`** - ` (k₁ k₂ : ℕ) : Ordering`
- **`Lean.Grind.CommRing.powerRevlex_k`** - ` (k₁ k₂ : ℕ) : Ordering`
- **`Lean.Grind.CommRing.Mon.grevlex`** - ` (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **`Lean.Grind.CommRing.Mon.grevlex_k`** - ` (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **`Lean.Grind.CommRing.Mon.revlex`** - ` (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **`Lean.Grind.CommRing.Mon.revlexWF`** - ` (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
- **`Lean.Grind.CommRing.Mon.revlex_k`** - ` : Lean.Grind.CommRing.Mon → Lean.Grind.CommRing.Mon → Ordering`
- **`Lean.Grind.CommRing.Power.revlex`** - ` (p₁ p₂ : Lean.Grind.CommRing.Power) : Ordering`
- **`Lean.Grind.CommRing.Var.revlex`** - ` (x y : Lean.Grind.CommRing.Var) : Ordering`
- **`Lean.Grind.CommRing.Mon.revlexFuel`** - ` (fuel : ℕ) (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`


### Ord Instances (7 functions)

- **`Ordering.then`** - ` (a b : Ordering) : Ordering`
  - If `a` and `b` are `Ordering`, then `a.then b` returns `a` unless it is `.eq`, in which case it...
- **`Ordering.then'`** - ` (a b : Ordering) : Ordering`
  - Version of `Ordering.then'` for proof by reflection. ...
- **`Ord.mk`** - ` {α : Type u} (compare : α → α → Ordering) : Ord α`
- **`Ord.ext`** - ` {α : Type u} {x y : Ord α} (compare : compare = compare) : x = y`
- **`Ord.ext_iff`** - ` {α : Type u} {x y : Ord α} : x = y ↔ compare = compare`
- **`IO.instOrdTaskState.ord`** - ` : IO.TaskState → IO.TaskState → Ordering`
- **`IO.FS.instOrdSystemTime.ord`** - ` : IO.FS.SystemTime → IO.FS.SystemTime → Ordering`


### Other (62 functions)

- **`Std.Internal.IsCut`** - ` {α : Type u} (cmp : α → α → Ordering) (cut : α → Ordering) : Prop`
- **`Std.Internal.IsStrictCut`** - ` {α : Type u} (cmp : α → α → Ordering) (cut : α → Ordering) : Prop`
- **`Std.Internal.IsStrictCut.toIsCut`** - ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [self : Std.Internal.IsStrictCut cmp cut] : Std.Internal.IsCut cmp cut`
- **`Std.Internal.IsStrictCut.eq`** - ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [self : Std.Internal.IsStrictCut cmp cut] (k : α) {k' : α} : cut k' = Ordering.eq → cut k = cmp k' k`
- **`Std.Internal.IsCut.gt`** - ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [self : Std.Internal.IsCut cmp cut] {k k' : α} : cut k' = Ordering.gt → cmp k' k = Ordering.gt → cut k = Ordering.gt`
- **`Std.Internal.IsCut.lt`** - ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [self : Std.Internal.IsCut cmp cut] {k k' : α} : cut k' = Ordering.lt → cmp k' k = Ordering.lt → cut k = Ordering.lt`
- **`Std.Internal.IsStrictCut.mk`** - ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [toIsCut : Std.Internal.IsCut cmp cut] (eq : ∀ (k : α) {k' : α}, cut k' = Ordering.eq → cut k = cmp k' k) : Std.Internal.IsStrictCut cmp cut`
- **`Std.Internal.IsStrictCut.gt_of_isGE_of_gt`** - ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [Std.Internal.IsStrictCut cmp cut] {k k' : α} : (cut k').isGE = true → cmp k' k = Ordering.gt → cut k = Ordering.gt`
- **`Std.Internal.IsStrictCut.lt_of_isLE_of_lt`** - ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} [Std.Internal.IsStrictCut cmp cut] {k k' : α} : (cut k').isLE = true → cmp k' k = Ordering.lt → cut k = Ordering.lt`
- **`Std.Internal.IsCut.mk`** - ` {α : Type u} {cmp : α → α → Ordering} {cut : α → Ordering} (lt : ∀ {k k' : α}, cut k' = Ordering.lt → cmp k' k = Ordering.lt → cut k = Ordering.lt) (gt : ∀ {k k' : α}, cut k' = Ordering.gt → cmp k' k = Ordering.gt → cut k = Ordering.gt) : Std.Internal.IsCut cmp cut`
- **`Std.DTreeMap`** - ` (α : Type u) (β : α → Type v) (cmp : α → α → Ordering := by exact compare) : Type (max u v)`
  - Dependent tree maps....
- **`Std.DTreeMap.empty`** - ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : Std.DTreeMap α β cmp`
  - Creates a new empty tree map. It is also possible and recommended to...
- **`Std.DTreeMap.instEmptyCollection`** - ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : EmptyCollection (Std.DTreeMap α β cmp)`
- **`Std.DTreeMap.instInhabited`** - ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : Inhabited (Std.DTreeMap α β cmp)`
- **`Std.DTreeMap.instInter`** - ` {α : Type u} {β : α → Type v} {cmp : α → α → Ordering} : Inter (Std.DTreeMap α β cmp)`

  *...and 47 more*



---

## Most Important/Common Functions

Based on the search results, here are the most useful functions for working with ordering comparisons:

### 1. Core Comparison Functions

#### `Ord.compare` (Init.Data.Ord.Basic)
- **Type**: `{α : Type u} [self : Ord α] : α → α → Ordering`
- **Purpose**: The fundamental comparison function from the `Ord` typeclass
- **Usage**: Primary method for comparing values of types with an `Ord` instance

#### `compareOn` (Init.Data.Ord.Basic)
- **Type**: `{β : Type u_1} {α : Sort u_2} [ord : Ord β] (f : α → β) (x y : α) : Ordering`
- **Purpose**: Compare values by first applying a function
- **Usage**: Useful for comparing complex types by a specific field

#### `compareOfLessAndBEq` (Init.Data.Ord.Basic)
- **Type**: `{α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [BEq α] : Ordering`
- **Purpose**: Construct ordering from less-than and boolean equality
- **Usage**: Building `Ord` instances from existing relations

### 2. Lexicographic Ordering

#### `compareLex` (Init.Data.Ord.Basic)
- **Type**: `{α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : Ordering`
- **Purpose**: Combine two comparators lexicographically
- **Usage**: Implementing complex comparison strategies

#### `List.compareLex` (Init.Data.Ord.Basic)
- **Type**: `{α : Type u_1} (cmp : α → α → Ordering) : List α → List α → Ordering`
- **Purpose**: Lexicographic comparison for lists
- **Usage**: Comparing lists element-by-element

#### `Array.compareLex` (Init.Data.Ord.Array)
- **Type**: `{α : Type u_1} (cmp : α → α → Ordering) (a₁ a₂ : Array α) : Ordering`
- **Purpose**: Lexicographic comparison for arrays
- **Usage**: Comparing arrays efficiently

### 3. Ordering Combinators

#### `Ordering.then` (Init.Data.Ord.Basic)
- **Type**: `(a b : Ordering) : Ordering`
- **Purpose**: Combine two orderings with short-circuit evaluation
- **Usage**: Building lexicographic comparators

### 4. Typeclass Properties

#### `Std.TransCmp` (Init.Data.Order.Ord)
- **Type**: `{α : Type u} (cmp : α → α → Ordering) : Prop`
- **Purpose**: Typeclass for transitive comparison functions
- **Usage**: Proving properties about custom comparators

#### `Std.OrientedCmp` (Init.Data.Order.Ord)
- **Type**: `{α : Type u} (cmp : α → α → Ordering) : Prop`
- **Purpose**: Typeclass for comparators where flipping arguments swaps result
- **Usage**: Establishing symmetry properties

#### `Std.LawfulEqCmp` (Init.Data.Order.Ord)
- **Type**: `{α : Type u} (cmp : α → α → Ordering) : Prop`
- **Purpose**: Comparators where `.eq` corresponds to logical equality
- **Usage**: Proving correctness of comparators

---

## Usage Recommendations

### When to Use Each Function

1. **`Ord.compare`**: Default choice for comparing any two values of the same type with an `Ord` instance

2. **`compareOn`**: When you need to compare complex structures by a specific field or derived value
   ```lean
   compareOn (·.age) person1 person2  -- Compare people by age
   ```

3. **`compareLex`**: When building custom lexicographic comparisons
   ```lean
   compareLex compareByName compareByAge person1 person2
   ```

4. **`Ordering.then`**: When chaining multiple comparisons with short-circuit behavior
   ```lean
   (compare a.name b.name).then (compare a.age b.age)
   ```

5. **`List.compareLex` / `Array.compareLex`**: For comparing collections element-wise

### Best Practices

1. **Prefer `Ord.compare`** when a type already has an `Ord` instance
2. **Use `compareOn`** to avoid writing repetitive comparison code
3. **Combine with `.then`** for multi-field comparisons
4. **Implement typeclasses** (`TransCmp`, `OrientedCmp`, `LawfulEqCmp`) to prove properties
5. **Use `compareOfLessAndBEq`** to build `Ord` instances from existing `LT` and `BEq` instances

---

## Related Functions and Patterns

### Building Custom Ord Instances

```lean
instance : Ord MyType where
  compare a b := (compare a.field1 b.field1).then (compare a.field2 b.field2)
```

### Deriving Ord Automatically

```lean
structure MyStruct where
  name : String
  age : Nat
  deriving Ord  -- Automatically generates lexicographic comparison
```

### Comparison Operators from Ordering

- `Ordering.isLT`: Check if ordering is less-than
- `Ordering.isLE`: Check if ordering is less-than or equal
- `Ordering.isGE`: Check if ordering is greater-than or equal  
- `Ordering.isGT`: Check if ordering is greater-than
- `Ordering.isEq`: Check if ordering is equal

---

## Technical Notes

### Type Patterns Found

The search identified functions with these type patterns:

1. **Binary Comparators**: `α → α → Ordering`
   - Most common pattern for comparing two values of the same type

2. **Parametric Comparators**: `(α → α → Ordering) → β → β → Ordering`
   - Higher-order functions that take a comparator and produce a new one

3. **Heterogeneous Comparators**: `α → β → Ordering`
   - Less common, used in specialized contexts

4. **Comparator Transformers**: `(α → α → Ordering) → (β → β → Ordering)`
   - Functions that transform one comparator into another

### Performance Considerations

- `Ordering.then` uses short-circuit evaluation (doesn't evaluate second argument if first is not `.eq`)
- Lexicographic comparisons stop at the first non-equal comparison
- Array/List comparisons are linear in the length of shorter sequence

---

## Conclusion

The Lean ecosystem provides a rich set of ordering and comparison functions centered around the `Ordering` type. The `_ → _ → Ordering` pattern is fundamental to:

- Implementing custom comparison logic
- Building `Ord` instances for new types
- Composing complex comparison strategies
- Proving properties about comparisons

Key takeaways:
- **{data['count']} total matches** shows extensive use of this pattern
- **Lean Core (Init)** provides the foundational comparison infrastructure
- **Lexicographic combinators** enable elegant multi-field comparisons
- **Typeclass laws** provide strong correctness guarantees

For most use cases, start with `Ord.compare` and combine with `Ordering.then` or `compareLex` for complex scenarios.

---

*Report generated from Loogle API search*  
*Search executed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

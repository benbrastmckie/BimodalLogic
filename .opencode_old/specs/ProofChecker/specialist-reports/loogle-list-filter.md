# Loogle Search Results: List.filter

**Query Pattern**: `List.filter`  
**Date**: Sun Dec 21 2025  
**Total Matches Found**: 506 declarations  
**Results Returned**: 200 (API limit)  
**Search Type**: Name-based search with related functions and theorems

---

## Executive Summary

The Loogle search for `List.filter` discovered **506 total declarations** across the Lean ecosystem, with 200 results returned due to API limits. The search identified:

- **1 exact match**: The main `List.filter` function
- **9 related functions**: Including tail-recursive variants, filterMap combinations, and helper functions
- **186+ theorems**: Covering equality, membership, combinations with other operations, and specialized properties

**Library Distribution**:
- Lean Core (Init): 102 declarations
- Std Library: 94 declarations
- Mathlib: Not represented in first 200 results

---

## 1. Exact Match

### List.filter

**Full Name**: `List.filter`  
**Type Signature**: `{α : Type u} (p : α → Bool) (l : List α) : List α`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Basic`  
**Complexity**: O(|l|)

**Description**:
Returns the list of elements in `l` for which `p` returns `true`.

**Examples**:
- `[1, 2, 5, 2, 7, 7].filter (· > 2) = [5, 7, 7]`
- `[1, 2, 5, 2, 7, 7].filter (fun _ => false) = []`
- `[1, 2, 5, 2, 7, 7].filter (fun _ => true) = [1, 2, 5, 2, 7, 7]`

---

## 2. Related Functions

### 2.1 Implementation Variants

#### List.filter_eq_filterTR
**Type**: `: @List.filter = @List.filterTR`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Basic`  
**Description**: Equivalence between standard and tail-recursive implementations

#### List.filterTR_loop_eq
**Type**: `{α : Type u} {p : α → Bool} {as bs : List α} : List.filterTR.loop p as bs = bs.reverse ++ List.filter p as`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Basic`  
**Description**: Specification of tail-recursive loop behavior

### 2.2 Combination Functions

#### List.filterMap_eq_filter
**Type**: `{α : Type u_1} {p : α → Bool} : List.filterMap (Option.guard fun x => p x) = List.filter p`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`  
**Description**: Relationship between filterMap and filter

#### List.filter_filterMap
**Type**: `{α : Type u_1} {β : Type u_2} {f : α → Option β} {p : β → Bool} {l : List α} : List.filter p (List.filterMap f l) = List.filterMap (fun x => Option.filter p (f x)) l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`  
**Description**: Composing filter with filterMap

#### List.filter_flatMap
**Type**: `{α : Type u_1} {β : Type u_2} {l : List α} {g : α → List β} {f : β → Bool} : List.filter f (List.flatMap g l) = List.flatMap (fun a => List.filter f (g a)) l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`  
**Description**: Distributing filter over flatMap

#### List.filterMap_filter
**Type**: `{α : Type u_1} {β : Type u_2} {p : α → Bool} {f : α → Option β} {l : List α} : List.filterMap f (List.filter p l) = List.filterMap (fun x => if p x = true then f x else none) l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`  
**Description**: Composing filterMap with filter

### 2.3 Integration with Other Operations

#### List.find?_filter
**Type**: `{α : Type u_1} {xs : List α} {p q : α → Bool} : List.find? q (List.filter p xs) = List.find? (fun a => decide (p a = true ∧ q a = true)) xs`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Find`  
**Description**: Finding in filtered lists

#### List.map_filterMap_some_eq_filter_map_isSome
**Type**: `{α : Type u_1} {β : Type u_2} {f : α → Option β} {l : List α} : List.map some (List.filterMap f l) = List.filter (fun b => b.isSome) (List.map f l)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`  
**Description**: Relationship between map, filterMap, and filter

#### Option.toList_pfilter
**Type**: `{α : Type u_1} {o : Option α} {p : (a : α) → o = some a → Bool} : (o.pfilter p).toList = (List.filter (fun x => p ↑x ⋯) o.toList.attach).unattach`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.Option.Attach`  
**Description**: Option pfilter to list filter conversion

---

## 3. Core Theorems

### 3.1 Basic Properties

#### List.filter_nil
**Type**: `{α : Type u} {p : α → Bool} : List.filter p [] = []`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Basic`

#### List.filter.eq_2
**Type**: `{α : Type u} (p : α → Bool) (a : α) (as : List α) : List.filter p (a :: as) = match p a with | true => a :: List.filter p as | false => List.filter p as`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Basic`

#### List.filter_cons
**Type**: `{α : Type u_1} {x : α} {xs : List α} {p : α → Bool} : List.filter p (x :: xs) = if p x = true then x :: List.filter p xs else List.filter p xs`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 3.2 Structural Properties

#### List.filter_sublist
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} : (List.filter p l).Sublist l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.length_filter_le
**Type**: `{α : Type u_1} (p : α → Bool) (l : List α) : (List.filter p l).length ≤ l.length`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.filter_reverse
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} : List.filter p l.reverse = (List.filter p l).reverse`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 3.3 Membership and Contains

#### List.mem_filter
**Type**: `{α✝ : Type u_1} {p : α✝ → Bool} {as : List α✝} {x : α✝} : x ∈ List.filter p as ↔ x ∈ as ∧ p x = true`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.contains_filter
**Type**: `{α : Type u_1} [BEq α] {l : List α} {x : α} {p : α → Bool} : (List.filter p l).contains x = l.any fun a => x == a && p a`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 3.4 Equality and Equivalence

#### List.filter_eq_self
**Type**: `{α✝ : Type u_1} {p : α✝ → Bool} {l : List α✝} : List.filter p l = l ↔ ∀ a ∈ l, p a = true`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.filter_eq_nil_iff
**Type**: `{α✝ : Type u_1} {p : α✝ → Bool} {l : List α✝} : List.filter p l = [] ↔ ∀ a ∈ l, ¬p a = true`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.length_filter_eq_length_iff
**Type**: `{α✝ : Type u_1} {p : α✝ → Bool} {l : List α✝} : (List.filter p l).length = l.length ↔ ∀ a ∈ l, p a = true`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.filter_congr
**Type**: `{α : Type u_1} {p q : α → Bool} {l : List α} : (∀ x ∈ l, p x = q x) → List.filter p l = List.filter q l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

---

## 4. Combination Theorems

### 4.1 Filter with Append

#### List.filter_append
**Type**: `{α : Type u_1} {p : α → Bool} (l₁ l₂ : List α) : List.filter p (l₁ ++ l₂) = List.filter p l₁ ++ List.filter p l₂`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.append_eq_filter_iff
**Type**: `{α : Type u_1} {L₁ L₂ l : List α} {p : α → Bool} : L₁ ++ L₂ = List.filter p l ↔ ∃ l₁ l₂, l = l₁ ++ l₂ ∧ List.filter p l₁ = L₁ ∧ List.filter p l₂ = L₂`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.filter_eq_append_iff
**Type**: `{α : Type u_1} {l L₁ L₂ : List α} {p : α → Bool} : List.filter p l = L₁ ++ L₂ ↔ ∃ l₁ l₂, l = l₁ ++ l₂ ∧ List.filter p l₁ = L₁ ∧ List.filter p l₂ = L₂`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 4.2 Filter with Map

#### List.filter_map
**Type**: `{β : Type u_1} {α : Type u_2} {f : β → α} {p : α → Bool} {l : List β} : List.filter p (List.map f l) = List.map f (List.filter (p ∘ f) l)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.map_filter_eq_foldr
**Type**: `{α : Type u_1} {β : Type u_2} {f : α → β} {p : α → Bool} {as : List α} : List.map f (List.filter p as) = List.foldr (fun a bs => bif p a then f a :: bs else bs) [] as`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 4.3 Filter with Flatten

#### List.filter_flatten
**Type**: `{α : Type u_1} {p : α → Bool} {L : List (List α)} : List.filter p L.flatten = (List.map (List.filter p) L).flatten`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.flatten_filter_not_isEmpty
**Type**: `{α : Type u_1} {L : List (List α)} : (List.filter (fun l => !l.isEmpty) L).flatten = L.flatten`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 4.4 Consecutive Filters

#### List.filter_filter
**Type**: `{α✝ : Type u_1} {p q : α✝ → Bool} {l : List α✝} : List.filter p (List.filter q l) = List.filter (fun a => p a && q a) l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

---

## 5. Specialized Theorems

### 5.1 Filter with Replicate

#### List.filter_replicate
**Type**: `{n : ℕ} {α✝ : Type u_1} {a : α✝} {p : α✝ → Bool} : List.filter p (List.replicate n a) = if p a = true then List.replicate n a else []`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.filter_replicate_of_pos
**Type**: `{α✝ : Type u_1} {p : α✝ → Bool} {n : ℕ} {a : α✝} (h : p a = true) : List.filter p (List.replicate n a) = List.replicate n a`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.filter_replicate_of_neg
**Type**: `{α✝ : Type u_1} {p : α✝ → Bool} {n : ℕ} {a : α✝} (h : ¬p a = true) : List.filter p (List.replicate n a) = []`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 5.2 Filter with Fold Operations

#### List.foldl_filter
**Type**: `{α : Type u_1} {β : Type u_2} {p : α → Bool} {f : β → α → β} {l : List α} {init : β} : List.foldl f init (List.filter p l) = List.foldl (fun x y => if p y = true then f x y else x) init l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.foldr_filter
**Type**: `{α : Type u_1} {β : Type u_2} {p : α → Bool} {f : α → β → β} {l : List α} {init : β} : List.foldr f init (List.filter p l) = List.foldr (fun x y => if p x = true then f x y else y) init l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 5.3 Filter with Count Operations

#### List.countP_eq_length_filter
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} : List.countP p l = (List.filter p l).length`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Count`

#### List.count_eq_length_filter
**Type**: `{α : Type u_1} [BEq α] {a : α} {l : List α} : List.count a l = (List.filter (fun x => x == a) l).length`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Count`

#### List.countP_filter
**Type**: `{α : Type u_1} {p q : α → Bool} {l : List α} : List.countP p (List.filter q l) = List.countP (fun a => p a && q a) l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Count`

### 5.4 Filter with BEq

#### List.filter_beq
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] {l : List α} (a : α) : List.filter (fun x => x == a) l = List.replicate (List.count a l) a`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Count`

#### List.filter_eq
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] [DecidableEq α] {l : List α} (a : α) : List.filter (fun x => decide (x = a)) l = List.replicate (List.count a l) a`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Count`

---

## 6. Sublist and Ordering Theorems

### 6.1 Sublist Relations

#### List.Sublist.filter
**Type**: `{α : Type u_1} (p : α → Bool) {l₁ l₂ : List α} (s : l₁.Sublist l₂) : (List.filter p l₁).Sublist (List.filter p l₂)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Sublist`

#### List.sublist_filter_iff
**Type**: `{α : Type u_1} {l₂ l₁ : List α} {p : α → Bool} : l₁.Sublist (List.filter p l₂) ↔ ∃ l', l'.Sublist l₂ ∧ l₁ = List.filter p l'`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Sublist`

### 6.2 Prefix/Suffix/Infix

#### List.IsPrefix.filter
**Type**: `{α : Type u_1} (p : α → Bool) ⦃l₁ l₂ : List α⦄ (h : l₁ <+: l₂) : List.filter p l₁ <+: List.filter p l₂`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Sublist`

#### List.IsSuffix.filter
**Type**: `{α : Type u_1} (p : α → Bool) ⦃l₁ l₂ : List α⦄ (h : l₁ <:+ l₂) : List.filter p l₁ <:+ List.filter p l₂`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Sublist`

#### List.IsInfix.filter
**Type**: `{α : Type u_1} (p : α → Bool) ⦃l₁ l₂ : List α⦄ (h : l₁ <:+: l₂) : List.filter p l₁ <:+: List.filter p l₂`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Sublist`

### 6.3 Permutations

#### List.Perm.filter
**Type**: `{α : Type u_1} (p : α → Bool) {l₁ l₂ : List α} (s : l₁.Perm l₂) : (List.filter p l₁).Perm (List.filter p l₂)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Perm`

#### List.filter_append_perm
**Type**: `{α : Type u_1} (p : α → Bool) (l : List α) : (List.filter p l ++ List.filter (fun x => !p x) l).Perm l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Perm`

---

## 7. Advanced Integration Theorems

### 7.1 Filter with Partition

#### List.partition_eq_filter_filter
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} : List.partition p l = (List.filter p l, List.filter (not ∘ p) l)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

### 7.2 Filter with TakeWhile/DropWhile

#### List.takeWhile_filter
**Type**: `{α : Type u_1} {p q : α → Bool} {l : List α} : List.takeWhile q (List.filter p l) = List.filter p (List.takeWhile (fun a => !p a || q a) l)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.TakeDrop`

#### List.dropWhile_filter
**Type**: `{α : Type u_1} {p q : α → Bool} {l : List α} : List.dropWhile q (List.filter p l) = List.filter p (List.dropWhile (fun a => !p a || q a) l)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.TakeDrop`

### 7.3 Filter with Erase

#### List.Nodup.erase_eq_filter
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] {l : List α} (d : l.Nodup) (a : α) : l.erase a = List.filter (fun x => x != a) l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Erase`

#### List.erase_filter
**Type**: `{α : Type u_1} [BEq α] {a : α} [LawfulBEq α] {f : α → Bool} {l : List α} : (List.filter f l).erase a = List.filter f (l.erase a)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Erase`

### 7.4 Filter with Array Conversions

#### Array.toList_filter
**Type**: `{α : Type u_1} {p : α → Bool} {xs : Array α} : (Array.filter p xs).toList = List.filter p xs.toList`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.Array.Lemmas`

#### List.filter_toArray
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} : Array.filter p l.toArray = (List.filter p l).toArray`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.Array.Lemmas`

---

## 8. Std Library Theorems (94 declarations)

The Std library contains extensive theorems about `List.filter` in the context of:

### 8.1 Internal Associative Lists

- **DistinctKeys preservation**: `Std.Internal.List.DistinctKeys.filter`
- **Key lookup operations**: `getKey?_filter`, `getValue?_filter`, `getEntry?_filter`
- **Filtering by key predicates**: `filter_key`, `filter_containsKey`
- **Filtering with containment checks**: `filter_not_contains`, `filter_not_contains_map_fst`

### 8.2 Key Theorems from Std

#### Std.Internal.List.perm_filter_self_iff
**Type**: `{α : Type u} {f : α → Bool} {l : List α} : (List.filter f l).Perm l ↔ ∀ a ∈ l, f a = true`  
**Library**: Std  
**Module**: `Std.Data.Internal.List.Associative`

#### Std.Internal.List.containsKey_filter
**Type**: `{α : Type u} {β : α → Type v} [BEq α] [LawfulBEq α] {f : (a : α) → β a → Bool} {l : List ((a : α) × β a)} {k : α} (hl : Std.Internal.List.DistinctKeys l) : Std.Internal.List.containsKey k (List.filter (fun p => f p.fst p.snd) l) = Option.any (f k) (Std.Internal.List.getValueCast? k l)`  
**Library**: Std  
**Module**: `Std.Data.Internal.List.Associative`

---

## 9. Access and Element Retrieval

### 9.1 Head and Last

#### List.head_filter
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} (h : List.filter p l ≠ []) : (List.filter p l).head h = (List.find? p l).get ⋯`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Find`

#### List.getLast_filter
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} (h : List.filter p l ≠ []) : (List.filter p l).getLast h = (List.find? p l.reverse).get ⋯`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Find`

#### List.head?_filter
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} : (List.filter p l).head? = List.find? p l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Find`

#### List.getLast?_filter
**Type**: `{α : Type u_1} {p : α → Bool} {l : List α} : (List.filter p l).getLast? = List.find? p l.reverse`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Find`

### 9.2 Element Access

#### List.getElem_filter
**Type**: `{α : Type u_1} {xs : List α} {p : α → Bool} {i : ℕ} (h : i < (List.filter p xs).length) : p (List.filter p xs)[i] = true`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.getElem?_filter
**Type**: `{α : Type u_1} {a : α} {xs : List α} {p : α → Bool} {i : ℕ} (h : i < (List.filter p xs).length) (w : (List.filter p xs)[i]? = some a) : p a = true`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

---

## 10. Monadic and Iterator Operations

### 10.1 Monadic Folds

#### List.foldlM_filter
**Type**: `{m : Type u_1 → Type u_2} {α : Type u_3} {β : Type u_1} [Monad m] [LawfulMonad m] {p : α → Bool} {g : β → α → m β} {l : List α} {init : β} : List.foldlM g init (List.filter p l) = List.foldlM (fun x y => if p y = true then g x y else pure x) init l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Monadic`

#### List.foldrM_filter
**Type**: `{m : Type u_1 → Type u_2} {α : Type u_3} {β : Type u_1} [Monad m] [LawfulMonad m] {p : α → Bool} {g : α → β → m β} {l : List α} {init : β} : List.foldrM g init (List.filter p l) = List.foldrM (fun x y => if p x = true then g x y else pure y) init l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Monadic`

### 10.2 Iterator Operations

#### Std.Iterators.Iter.toList_filter
**Type**: `{α β : Type w} [Std.Iterators.Iterator α Id β] {it : Std.Iter β} [Std.Iterators.IteratorCollect α Id Id] [Std.Iterators.LawfulIteratorCollect α Id Id] [Std.Iterators.Finite α Id] {f : β → Bool} : (Std.Iterators.Iter.filter f it).toList = List.filter f it.toList`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.Iterators.Lemmas.Combinators.FilterMap`

#### Std.Iterators.IterM.toList_filter
**Type**: `{α : Type w} {m : Type w → Type w'} [Monad m] [LawfulMonad m] {β : Type w} [Std.Iterators.Iterator α m β] [Std.Iterators.Finite α m] [Std.Iterators.IteratorCollect α m m] [Std.Iterators.LawfulIteratorCollect α m m] {f : β → Bool} {it : Std.IterM m β} : (Std.Iterators.IterM.filter f it).toList = List.filter f <$> it.toList`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.Iterators.Lemmas.Combinators.Monadic.FilterMap`

---

## 11. Pairwise and Structural Properties

### 11.1 Pairwise Relations

#### List.Pairwise.filter
**Type**: `{α : Type u_1} {R : α → α → Prop} {l : List α} (p : α → Bool) : List.Pairwise R l → List.Pairwise R (List.filter p l)`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Pairwise`

#### List.pairwise_filter
**Type**: `{α : Type u_1} {R : α → α → Prop} {p : α → Bool} {l : List α} : List.Pairwise R (List.filter p l) ↔ List.Pairwise (fun x y => p x = true → p y = true → R x y) l`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Pairwise`

### 11.2 Any and All

#### List.any_filter
**Type**: `{α : Type u_1} {l : List α} {p q : α → Bool} : (List.filter p l).any q = l.any fun a => p a && q a`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

#### List.all_filter
**Type**: `{α : Type u_1} {l : List α} {p q : α → Bool} : (List.filter p l).all q = l.all fun a => !p a || q a`  
**Library**: Lean Core (Init)  
**Module**: `Init.Data.List.Lemmas`

---

## 12. Usage Recommendations

### When to Use List.filter

1. **Selecting elements**: When you need to extract elements satisfying a predicate
2. **Data validation**: Filtering out invalid or unwanted elements
3. **Conditional processing**: Combined with map for selective transformations
4. **Partitioning**: Use with partition for splitting lists

### Performance Considerations

- **Complexity**: O(n) where n is the list length
- **Tail-recursive variant**: `List.filterTR` available for stack safety
- **Composition**: Multiple filters can be combined with `&&` for efficiency

### Common Patterns

```lean
-- Filter and map
List.map f (List.filter p l)

-- Consecutive filters (can be optimized)
List.filter p (List.filter q l) = List.filter (fun a => p a && q a) l

-- Partition into matching and non-matching
(List.filter p l, List.filter (fun x => !p x) l)

-- Count matching elements
(List.filter p l).length
```

---

## 13. Related Functions to Explore

Based on this search, consider exploring:

1. **List.filterMap**: Combined filter and map operation
2. **List.partition**: Splits into matching and non-matching
3. **List.find?**: Finds first matching element
4. **List.countP**: Counts matching elements
5. **List.takeWhile/dropWhile**: Prefix-based filtering
6. **Array.filter**: Array version with similar properties

---

## Appendix: Search Metadata

**Search Method**: Loogle API name-based search  
**Query**: "List.filter"  
**Total Declarations**: 506  
**Returned Results**: 200 (API limit)  
**Coverage**: First 200 results analyzed  
**Missing**: Potentially 306 additional declarations (likely Mathlib theorems)

**Library Breakdown** (from returned results):
- Lean Core (Init): 102 declarations (51%)
- Std Library: 94 declarations (47%)
- Other: 4 declarations (2%)

**Theorem Categories**:
- Basic properties: 15+
- Equality/equivalence: 10+
- Membership/contains: 8+
- Combination operations: 20+
- Sublist relations: 12+
- Specialized operations: 30+
- Std internal operations: 94+

---

**Report Generated**: Sun Dec 21 2025  
**Loogle Specialist**: Type-based library search agent  
**Project**: ProofChecker

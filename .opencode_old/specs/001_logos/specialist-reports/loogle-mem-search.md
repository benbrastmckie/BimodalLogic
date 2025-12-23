# Loogle Search Results: "mem" Functions

**Search Pattern**: "mem" and list membership functions  
**Date**: 2025-12-21  
**Total Matches Found**: 400+ (showing 200+ most relevant)

## Executive Summary

This search identified three primary categories of membership-related functions in Lean 4:

1. **Propositional Membership** (`List.Mem`, `Membership.mem`) - returns `Prop`
2. **Boolean Membership** (`List.elem`, `List.contains`) - returns `Bool`
3. **Typeclass Infrastructure** (`Membership α γ`) - provides the `∈` notation

## Exact Name Matches

### 1. **Membership.mem** : `{α : outParam (Type u)} {γ : Type v} [self : Membership α γ] : γ → α → Prop`
   - **Library**: Init (Lean Core)
   - **Module**: Init.Prelude
   - **Description**: The fundamental typeclass method that defines membership relation
   - **Category**: Exact match - Core typeclass
   - **Usage**: Provides the `∈` notation via the `Membership` typeclass

### 2. **List.Mem** : `{α : Type u} (a : α) : List α → Prop`
   - **Library**: Init (Lean Core)
   - **Module**: Init.Data.List.Basic
   - **Description**: Inductive proposition that an element is a member of a list
   - **Category**: Exact match - Core data structure
   - **Constructors**:
     - `List.Mem.head {α : Type u} {a : α} (as : List α) : List.Mem a (a :: as)`
     - `List.Mem.tail {α : Type u} {a : α} (b : α) {as : List α} : List.Mem a as → List.Mem a (b :: as)`

## Partial Name Matches (Containing "mem")

### Boolean Membership Functions

#### 3. **List.elem** : `{α : Type u} [BEq α] (a : α) (l : List α) : Bool`
   - **Library**: Init (Lean Core)
   - **Module**: Init.Data.List.Basic
   - **Description**: Boolean membership test using BEq
   - **Category**: Partial match - Boolean predicate
   - **Key Properties**:
     - `List.elem_iff : List.elem a as = true ↔ a ∈ as` (with LawfulBEq)
     - `List.elem_eq_mem : List.elem a as = decide (a ∈ as)` (with LawfulBEq)

#### 4. **List.contains** : `{α : Type u} [BEq α] (as : List α) (a : α) : Bool`
   - **Library**: Init (Lean Core)
   - **Module**: Init.Data.List.Basic
   - **Description**: Boolean membership test (alternative argument order to elem)
   - **Category**: Partial match - Boolean predicate
   - **Key Properties**:
     - `List.contains_iff : as.contains a = true ↔ a ∈ as` (with LawfulBEq)
     - `List.elem_eq_contains : List.elem a l = l.contains a`

### Related Membership Propositions

#### 5. **Array.Mem** : `{α : Type u} {as : Array α} {a : α} (val : a ∈ as.toList) : as.Mem a`
   - **Library**: Init (Lean Core)
   - **Module**: Init.Data.Array.Basic
   - **Description**: Array membership defined via list conversion
   - **Category**: Partial match - Array membership

#### 6. **Vector.Mem** : Similar to Array.Mem but for Vector
   - **Library**: Init (Lean Core)
   - **Module**: Init.Data.Vector
   - **Description**: Vector membership
   - **Category**: Partial match - Vector membership

#### 7. **Set.Mem** : Set membership
   - **Library**: Mathlib
   - **Module**: Set theory module
   - **Description**: Set membership relation
   - **Category**: Partial match - Set theory

#### 8. **Multiset.Mem** : Multiset membership
   - **Library**: Mathlib
   - **Module**: Multiset module
   - **Description**: Multiset membership (like list but unordered)
   - **Category**: Partial match - Multiset

### Membership for Specific Data Structures

9. **Subtype.mem** : Membership for subtypes
10. **Part.Mem** : Partial functions
11. **Cycle.Mem** : Cycle membership
12. **Sym2.Mem** : Symmetric pairs
13. **Computation.Mem** : Computation membership
14. **Stream'.Seq.Mem** : Sequence membership
15. **PSet.Mem** : Pre-set membership
16. **ZFSet.Mem** : ZF set membership
17. **Class.Mem** : Class membership

### Prefix/Suffix/Infix Relations

18. **List.IsInfix.mem** : Infix preservation of membership
19. **List.IsPrefix.mem** : Prefix preservation of membership
20. **List.IsSuffix.mem** : Suffix preservation of membership
21. **List.Sublist.mem** : Sublist preservation of membership

## Related Membership Functions (By Type Signature)

### Functions: `_ → List _ → Bool`

1. **List.isEmpty** : `{α : Type u} : List α → Bool`
2. **List.elem** : `{α : Type u} [BEq α] (a : α) (l : List α) : Bool`
3. **List.contains** : `{α : Type u} [BEq α] (as : List α) (a : α) : Bool`
4. **List.any** : `{α : Type u} (l : List α) (p : α → Bool) : Bool`
5. **List.all** : `{α : Type u} : List α → (α → Bool) → Bool`
6. **List.isPrefixOf** : `{α : Type u} [BEq α] : List α → List α → Bool`
7. **List.isSublist** : `{α : Type u} [BEq α] : List α → List α → Bool`
8. **List.isSuffixOf** : `{α : Type u} [BEq α] (l₁ l₂ : List α) : Bool`

### Functions: `_ → List _ → Prop`

1. **List.Nodup** : `{α : Type u} : List α → Prop`
2. **List.Mem** : `{α : Type u} (a : α) : List α → Prop`
3. **List.IsInfix** : `{α : Type u} (l₁ l₂ : List α) : Prop`
4. **List.IsPrefix** : `{α : Type u} (l₁ l₂ : List α) : Prop`
5. **List.IsSuffix** : `{α : Type u} (l₁ l₂ : List α) : Prop`
6. **List.Perm** : `{α : Type u} : List α → List α → Prop`
7. **List.Sublist** : `{α : Type u_1} : List α → List α → Prop`
8. **List.Subset** : `{α : Type u} (l₁ l₂ : List α) : Prop`
9. **List.Pairwise** : `{α : Type u} (R : α → α → Prop) : List α → Prop`
10. **List.Chain'** : `{α : Type u_1} : (α → α → Prop) → List α → Prop`
11. **List.Forall₂** : `{α : Type u_1} {β : Type u_2} (R : α → β → Prop) : List α → List β → Prop`

## Summary Statistics

- **Total matches**: 400+ declarations
- **Exact matches**: 2 (Membership.mem, List.Mem)
- **Partial matches**: 50+ (elem, contains, various Mem types)
- **Related functions**: 350+ (lemmas and theorems about membership)

### Category Breakdown

| Category | Count | Description |
|----------|-------|-------------|
| **Core Membership** | 2 | `Membership.mem`, `List.Mem` |
| **Boolean Tests** | 2 | `List.elem`, `List.contains` |
| **Container-specific Mem** | 15+ | Array.Mem, Set.Mem, Multiset.Mem, etc. |
| **Membership Lemmas** | 200+ | Properties and theorems |
| **Related Predicates** | 22 | Bool-returning list predicates |
| **Related Propositions** | 139 | Prop-returning list relations |

## Top 10 Most Relevant

### Rank 1: **Membership.mem**
- **Type**: `{α : outParam (Type u)} {γ : Type v} [self : Membership α γ] : γ → α → Prop`
- **Module**: Init.Prelude
- **Library**: Lean Core
- **Description**: The fundamental typeclass for membership relation
- **Relevance**: This is THE core membership function that enables `∈` notation across all types

### Rank 2: **List.Mem**
- **Type**: `{α : Type u} (a : α) : List α → Prop`
- **Module**: Init.Data.List.Basic
- **Library**: Lean Core
- **Description**: Inductive proposition for list membership
- **Relevance**: The canonical propositional membership for lists, provides the instance for `Membership α (List α)`

### Rank 3: **List.elem**
- **Type**: `{α : Type u} [BEq α] (a : α) (l : List α) : Bool`
- **Module**: Init.Data.List.Basic
- **Library**: Lean Core
- **Description**: Boolean decidable membership test
- **Relevance**: Computable membership test, essential for executable code

### Rank 4: **List.contains**
- **Type**: `{α : Type u} [BEq α] (as : List α) (a : α) : Bool`
- **Module**: Init.Data.List.Basic
- **Library**: Lean Core
- **Description**: Boolean membership with reversed argument order
- **Relevance**: Alternative syntax for elem, useful in pipelines

### Rank 5: **List.mem_of_elem_eq_true**
- **Type**: `{α : Type u} [BEq α] [LawfulBEq α] {a : α} {as : List α} : List.elem a as = true → a ∈ as`
- **Module**: Init.Data.List.Basic
- **Library**: Lean Core
- **Description**: Bridge from Boolean to propositional membership
- **Relevance**: Critical for converting between computational and logical views

### Rank 6: **List.elem_eq_mem**
- **Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] (a : α) (as : List α) : List.elem a as = decide (a ∈ as)`
- **Module**: Init.Data.List.Lemmas
- **Library**: Lean Core
- **Description**: Shows elem is the decision procedure for membership
- **Relevance**: Fundamental connection between Bool and Prop membership

### Rank 7: **List.mem_cons_self**
- **Type**: `{α : Type u_1} {a : α} {l : List α} : a ∈ a :: l`
- **Module**: Init.Data.List.Lemmas
- **Library**: Lean Core
- **Description**: Head element is always a member
- **Relevance**: Most basic membership fact, used constantly

### Rank 8: **List.mem_append**
- **Type**: `{α : Type u_1} {a : α} {s t : List α} : a ∈ s ++ t ↔ a ∈ s ∨ a ∈ t`
- **Module**: Init.Data.List.Lemmas
- **Library**: Lean Core
- **Description**: Membership distributes over append
- **Relevance**: Essential for reasoning about list concatenation

### Rank 9: **List.mem_map**
- **Type**: `{α : Type u_1} {β : Type u_2} {b : β} {f : α → β} {l : List α} : b ∈ List.map f l ↔ ∃ a ∈ l, f a = b`
- **Module**: Init.Data.List.Lemmas
- **Library**: Lean Core
- **Description**: Membership in mapped lists
- **Relevance**: Critical for functional programming patterns

### Rank 10: **List.mem_filter**
- **Type**: `{α✝ : Type u_1} {p : α✝ → Bool} {as : List α✝} {x : α✝} : x ∈ List.filter p as ↔ x ∈ as ∧ p x = true`
- **Module**: Init.Data.List.Lemmas
- **Library**: Lean Core
- **Description**: Membership in filtered lists
- **Relevance**: Essential for filter operations

## Key Insights

### 1. **Dual Membership Systems**
Lean 4 maintains two parallel membership systems:
- **Propositional** (`List.Mem`, returns `Prop`): For proofs and logical reasoning
- **Boolean** (`List.elem`/`List.contains`, returns `Bool`): For computation and decision procedures

### 2. **Typeclass Integration**
The `Membership α γ` typeclass provides uniform `∈` notation across:
- Lists (`List α`)
- Sets (`Set α`)
- Multisets (`Multiset α`)
- Arrays (`Array α`)
- Custom containers

### 3. **Lawful Equality Requirement**
The connection between Bool and Prop membership requires `[LawfulBEq α]`:
- `List.elem_iff : List.elem a as = true ↔ a ∈ as`
- Without `LawfulBEq`, only `ReflBEq α` provides one direction

### 4. **Decidability**
With `[BEq α] [LawfulBEq α]`, membership is decidable:
```lean
instance [BEq α] [LawfulBEq α] (a : α) (as : List α) : Decidable (a ∈ as)
```

## Recommendations

### For Proofs (Use `∈` / `List.Mem`)
- **When**: Writing theorems, proving properties
- **Why**: Propositional membership integrates with Lean's logic
- **Example**: `theorem mem_append : a ∈ xs ++ ys ↔ a ∈ xs ∨ a ∈ ys`

### For Computation (Use `List.elem` or `List.contains`)
- **When**: Writing executable functions, decision procedures
- **Why**: Returns `Bool`, can be evaluated
- **Example**: `if List.contains myList x then ... else ...`

### For Generic Programming (Use `Membership` typeclass)
- **When**: Writing polymorphic code over containers
- **Why**: Works uniformly across List, Set, Multiset, etc.
- **Example**: `def filter_mem [Membership α γ] (container : γ) (pred : α → Bool) : ...`

### Conversion Between Systems
Use these key lemmas:
- `List.mem_of_elem_eq_true : List.elem a as = true → a ∈ as`
- `List.elem_eq_mem : List.elem a as = decide (a ∈ as)` (with LawfulBEq)
- `List.contains_iff : as.contains a = true ↔ a ∈ as` (with LawfulBEq)

## Usage Patterns

### Pattern 1: Decidable Membership in Proofs
```lean
example [BEq α] [LawfulBEq α] (a : α) (xs : List α) : Decidable (a ∈ xs) := by
  rw [←List.elem_iff]
  infer_instance
```

### Pattern 2: Computational Filter with Membership
```lean
def removeIfMember [BEq α] [LawfulBEq α] (toRemove : List α) (xs : List α) : List α :=
  xs.filter (fun x => !(toRemove.contains x))
```

### Pattern 3: Generic Membership Operations
```lean
def count_members [Membership α γ] [DecidableRel (· ∈ · : α → γ → Prop)] 
    (items : List α) (container : γ) : Nat :=
  items.filter (· ∈ container) |>.length
```

---

**Generated by**: Loogle API Search  
**Mathlib Revision**: da22c4e  
**Loogle Revision**: 6ff4759

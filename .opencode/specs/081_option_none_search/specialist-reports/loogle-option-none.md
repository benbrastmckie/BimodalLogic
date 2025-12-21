# Loogle Search Results: Option.none

**Type Pattern**: Option.none  
**Date**: December 20, 2025  
**Total Matches Found**: 2524  
**Matches Returned**: 200 (first 200 of 2524)  
**Search Type**: By constant name

---

## Summary

This search found 2524 declarations mentioning `Option.none` in the LEAN standard library (Init). The results include the core definition, theorems about `none`, and functions that interact with `Option.none`. All results are from the Init library (LEAN's core standard library).

---

## Exact Match - Core Definition

### 1. **Option.none**
- **Type**: `{α : Type u} : Option α`
- **Library**: Init (Core)
- **Module**: `Init.Prelude`
- **Description**: No value.
- **Usage**: The constructor for the empty/absent case of the Option type

---

## Size and Equality Theorems

### 2. **Option.none.sizeOf_spec**
- **Type**: `{α : Type u} [SizeOf α] : sizeOf none = 1`
- **Library**: Init
- **Module**: `Init.SizeOf`
- **Description**: Size of none is always 1

### 3. **Option.decidableEqNone**
- **Type**: `{α : Type u_1} (o : Option α) : Decidable (o = none)`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Equality with `none` is decidable even if the wrapped type does not have decidable equality.

### 4. **Option.decidableNoneEq**
- **Type**: `{α : Type u_1} (o : Option α) : Decidable (none = o)`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Equality with `none` is decidable even if the wrapped type does not have decidable equality.

### 5. **Option.some_ne_none**
- **Type**: `{α : Type u_1} (x : α) : some x ≠ none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Some is never equal to none

### 6. **Option.default_eq_none**
- **Type**: `{α : Type u_1} : default = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: The default Option value is none

---

## Boolean Predicates on none

### 7. **Option.isNone_none**
- **Type**: `{α : Type u_1} : none.isNone = true`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: none.isNone returns true

### 8. **Option.isSome_none**
- **Type**: `{α : Type u_1} : none.isSome = false`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: none.isSome returns false

### 9. **Option.eq_none_of_isNone**
- **Type**: `{α : Type u} {o : Option α} : o.isNone = true → o = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Instances`
- **Description**: If isNone is true, then the option equals none

### 10. **Option.isNone_iff_eq_none**
- **Type**: `{α : Type u_1} {o : Option α} : o.isNone = true ↔ o = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Instances`
- **Description**: Biconditional between isNone and equality with none

### 11. **Option.isSome_iff_ne_none**
- **Type**: `{α : Type u_1} {o : Option α} : o.isSome = true ↔ o ≠ none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: isSome is true iff the option is not none

### 12. **Option.ne_none_iff_isSome**
- **Type**: `{α : Type u_1} {o : Option α} : o ≠ none ↔ o.isSome = true`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Not equal to none iff isSome is true

### 13. **Option.not_isSome_iff_eq_none**
- **Type**: `{α : Type u_1} {o : Option α} : ¬o.isSome = true ↔ o = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Not isSome iff equal to none

---

## Functor Operations on none

### 14. **Option.map_none**
- **Type**: `{α : Type u_1} {β : Type u_2} (f : α → β) : Option.map f none = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Mapping over none returns none

### 15. **Option.bind_none**
- **Type**: `{α : Type u_1} {β : Type u_2} (f : α → Option β) : none.bind f = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Binding none with any function returns none

### 16. **Option.join_none**
- **Type**: `{α : Type u_1} : none.join = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Joining none returns none

### 17. **Option.sequence_none**
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_1} [Applicative m] : none.sequence = pure none`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Sequencing none returns pure none

### 18. **Option.mapM_none**
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_3} {β : Type u_1} [Applicative m] (f : α → m β) : Option.mapM f none = pure none`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Monadic map over none returns pure none

---

## Extraction and Default Values

### 19. **Option.getD_none**
- **Type**: `{α : Type u_1} {a : α} : none.getD a = a`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Getting none with default returns the default

### 20. **Option.getDM_none**
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_1} [Pure m] (y : m α) : none.getDM y = y`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Monadic getD on none returns the default

### 21. **Option.getM_none**
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_1} [Alternative m] : none.getM = failure`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Monadic get on none returns failure

### 22. **Option.get!_none**
- **Type**: `{α : Type u_1} [Inhabited α] : none.get! = default`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Getting none with panic returns default

### 23. **Option.get_none**
- **Type**: `{α : Type u_1} (a : α) {h : none.isSome = true} : none.get h = a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Getting none with proof (vacuous - proof is impossible)

---

## Predicates and Filters

### 24. **Option.all_none**
- **Type**: `{α : Type u_1} {p : α → Bool} : Option.all p none = true`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: All predicate on none is vacuously true

### 25. **Option.any_none**
- **Type**: `{α : Type u_1} {p : α → Bool} : Option.any p none = false`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Any predicate on none is false

### 26. **Option.filter_none**
- **Type**: `{α : Type u_1} (p : α → Bool) : Option.filter p none = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Filtering none returns none

### 27. **Option.pfilter_none**
- **Type**: `{α : Type u_1} {p : (a : α) → none = some a → Bool} : none.pfilter p = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent filtering of none returns none

### 28. **Option.guard_false**
- **Type**: `{α : Type u_1} : (Option.guard fun x => false) = fun x => none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Guard with false predicate always returns none

---

## Relational Operations

### 29. **Option.Rel.none**
- **Type**: `{α : Type u_1} {β : Type u_2} {r : α → β → Prop} : Option.Rel r none none`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: `none ~ none`

### 30. **Option.rel_none_none**
- **Type**: `{α : Type u_1} {β : Type u_2} {r : α → β → Prop} : Option.Rel r none none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Relation holds between none and none

### 31. **Option.not_rel_none_some**
- **Type**: `{α : Type u_1} {β : Type u_2} {a : β} {r : α → β → Prop} : ¬Option.Rel r none (some a)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Relation cannot hold between none and some

### 32. **Option.not_rel_some_none**
- **Type**: `{α : Type u_1} {β : Type u_2} {a : α} {r : α → β → Prop} : ¬Option.Rel r (some a) none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Relation cannot hold between some and none

---

## Order Operations

### 33. **Option.max_none_left**
- **Type**: `{α : Type u_1} [Max α] {o : Option α} : none ⊔ o = o`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Max of none and o is o

### 34. **Option.max_none_right**
- **Type**: `{α : Type u_1} [Max α] {o : Option α} : o ⊔ none = o`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Max of o and none is o

### 35. **Option.min_none_left**
- **Type**: `{α : Type u_1} [Min α] {o : Option α} : none ⊓ o = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Min of none and o is none

### 36. **Option.min_none_right**
- **Type**: `{α : Type u_1} [Min α] {o : Option α} : o ⊓ none = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: Min of o and none is none

### 37. **Option.none_le**
- **Type**: `{α : Type u_1} [LE α] {a : Option α} : none ≤ a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: none is less than or equal to any option

### 38. **Option.le_none**
- **Type**: `{α : Type u_1} [LE α] {a : Option α} : a ≤ none ↔ a = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: a ≤ none iff a = none

### 39. **Option.not_some_le_none**
- **Type**: `{α : Type u_1} [LE α] {a : α} : ¬some a ≤ none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: some a is not ≤ none

### 40. **Option.none_lt_some**
- **Type**: `{α : Type u_1} [LT α] {a : α} : none < some a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: none is strictly less than any some

### 41. **Option.not_lt_none**
- **Type**: `{α : Type u_1} [LT α] {a : Option α} : ¬a < none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Nothing is less than none

### 42. **Option.none_lt**
- **Type**: `{α : Type u_1} [LT α] {a : Option α} : none < a ↔ a.isSome = true`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: none < a iff a is some

---

## Alternative/Or Operations

### 43. **Option.orElse_none**
- **Type**: `{α : Type u_1} {b : Unit → Option α} : none.orElse b = b ()`
- **Library**: Init
- **Module**: `Init.Data.Option.Basic`
- **Description**: orElse on none evaluates the alternative

### 44. **Option.none_or**
- **Type**: `{α : Type u_1} {o : Option α} : none.or o = o`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Or of none and o is o

### 45. **Option.or_none**
- **Type**: `{α : Type u_1} {o : Option α} : o.or none = o`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Or of o and none is o

### 46. **Option.instLawfulIdentityOrNone**
- **Type**: `{α : Type u_1} : Std.LawfulIdentity Option.or none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: none is the identity for Option.or

---

## Merge Operations

### 47. **Option.merge_none_left**
- **Type**: `{α : Type u_1} {f : α → α → α} {b : Option α} : Option.merge f none b = b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Merging none on left returns right

### 48. **Option.merge_none_right**
- **Type**: `{α : Type u_1} {f : α → α → α} {a : Option α} : Option.merge f a none = a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Merging none on right returns left

### 49. **Option.lawfulIdentity_merge**
- **Type**: `{α : Type u_1} (f : α → α → α) : Std.LawfulIdentity (Option.merge f) none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: none is identity for merge

### 50. **Option.instLawfulIdentityMaxNone**
- **Type**: `{α : Type u_1} [Max α] : Std.LawfulIdentity max none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: none is identity for max

---

## Conversion Functions

### 51. **Option.toList_none**
- **Type**: `(α : Type u_1) : none.toList = []`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Converting none to list gives empty list

### 52. **Option.toArray_none**
- **Type**: `(α : Type u_1) : none.toArray = #[]`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Converting none to array gives empty array

---

## Membership

### 53. **Option.not_mem_none**
- **Type**: `{α : Type u_1} (a : α) : a ∉ none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: No element is a member of none

---

## Elimination and Pattern Matching

### 54. **Option.elim_none**
- **Type**: `{β : Sort u_1} {α : Type u_2} (x : β) (f : α → β) : none.elim x f = x`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Eliminating none returns the default branch

### 55. **Option.pelim_none**
- **Type**: `{α : Sort u_1} {b : α} {α' : Type u_2} {f : (a : α') → none = some a → α} : none.pelim b f = b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent elimination of none returns default

---

## BEq Operations

### 56. **Option.none_beq_none**
- **Type**: `{α : Type u_1} [BEq α] : (none == none) = true`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: none equals none via BEq

### 57. **Option.none_beq_some**
- **Type**: `{α : Type u_1} [BEq α] (a : α) : (none == some a) = false`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: none does not equal some via BEq

### 58. **Option.some_beq_none**
- **Type**: `{α : Type u_1} [BEq α] (a : α) : (some a == none) = false`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: some does not equal none via BEq

### 59. **Option.beq_none**
- **Type**: `{α : Type u_1} [BEq α] {o : Option α} : (o == none) = o.isNone`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Beq with none equals isNone

---

## Characterization Theorems

### 60. **Option.eq_none_or_eq_some**
- **Type**: `{α : Type u_1} (a : Option α) : a = none ∨ ∃ x, a = some x`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Every option is either none or some

### 61. **Option.ne_none_iff_exists**
- **Type**: `{α : Type u_1} {o : Option α} : o ≠ none ↔ ∃ x, some x = o`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Not none iff exists some value

### 62. **Option.ne_none_iff_exists'**
- **Type**: `{α : Type u_1} {o : Option α} : o ≠ none ↔ ∃ x, o = some x`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Not none iff exists some value (alternative form)

### 63. **Option.eq_none_iff_forall_ne_some**
- **Type**: `{α : Type u_1} {o : Option α} : o = none ↔ ∀ (a : α), o ≠ some a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Equal to none iff not equal to any some

### 64. **Option.eq_none_iff_forall_some_ne**
- **Type**: `{α : Type u_1} {o : Option α} : o = none ↔ ∀ (a : α), some a ≠ o`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Equal to none iff no some equals it

### 65. **Option.eq_none_iff_forall_not_mem**
- **Type**: `{α : Type u_1} {o : Option α} : o = none ↔ ∀ (a : α), a ∉ o`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Equal to none iff no element is a member

---

## Quantifier Theorems

### 66. **Option.forall**
- **Type**: `{α : Type u_1} {p : Option α → Prop} : (∀ (x : Option α), p x) ↔ p none ∧ ∀ (x : α), p (some x)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Universal quantification over options

### 67. **Option.exists**
- **Type**: `{α : Type u_1} {p : Option α → Prop} : (∃ x, p x) ↔ p none ∨ ∃ x, p (some x)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Existential quantification over options

### 68. **Option.forall_ne_none**
- **Type**: `{α : Type u_1} {p : Option α → Prop} : (∀ (x : Option α), x ≠ none → p x) ↔ ∀ (x : α), p (some x)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Forall over non-none options

### 69. **Option.exists_ne_none**
- **Type**: `{α : Type u_1} {p : Option α → Prop} : (∃ x, x ≠ none ∧ p x) ↔ ∃ x, p (some x)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Exists over non-none options

---

## List Operations Returning none

### 70. **List.getLast?_nil**
- **Type**: `{α : Type u} : [].getLast? = none`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Description**: Last element of empty list is none

### 71. **List.head?_nil**
- **Type**: `{α : Type u} : [].head? = none`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Description**: Head of empty list is none

### 72. **List.tail?_nil**
- **Type**: `{α : Type u} : [].tail? = none`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Description**: Tail of empty list is none

### 73. **List.find?_nil**
- **Type**: `{α : Type u} {p : α → Bool} : List.find? p [] = none`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Description**: Finding in empty list returns none

### 74. **List.findSome?_nil**
- **Type**: `{α : Type u} {α' : Type u_1} {f : α → Option α'} : List.findSome? f [] = none`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Description**: FindSome in empty list returns none

### 75. **List.lookup_nil**
- **Type**: `{α : Type u} {β : Type v} {a : α} [BEq α] : List.lookup a [] = none`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Description**: Lookup in empty list returns none

### 76. **List.getElem?_nil**
- **Type**: `{α : Type u_1} {i : ℕ} : [][i]? = none`
- **Library**: Init
- **Module**: `Init.Data.List.Lemmas`
- **Description**: Indexing empty list returns none

### 77. **List.getElem?_eq_none**
- **Type**: `{α : Type u_1} {l : List α} {i : ℕ} (h : l.length ≤ i) : l[i]? = none`
- **Library**: Init
- **Module**: `Init.GetElem`
- **Description**: Out-of-bounds indexing returns none

### 78. **List.getElem?_eq_none_iff**
- **Type**: `{α : Type u_1} {l : List α} {i : ℕ} : l[i]? = none ↔ l.length ≤ i`
- **Library**: Init
- **Module**: `Init.GetElem`
- **Description**: Index returns none iff out of bounds

### 79. **List.none_eq_getElem?_iff**
- **Type**: `{α : Type u_1} {l : List α} {i : ℕ} : none = l[i]? ↔ l.length ≤ i`
- **Library**: Init
- **Module**: `Init.GetElem`
- **Description**: none equals index iff out of bounds

### 80. **List.getLast?_eq_none_iff**
- **Type**: `{α : Type u_1} {xs : List α} : xs.getLast? = none ↔ xs = []`
- **Library**: Init
- **Module**: `Init.Data.List.Lemmas`
- **Description**: getLast? is none iff list is empty

### 81. **List.head?_eq_none_iff**
- **Type**: `{α : Type u_1} {l : List α} : l.head? = none ↔ l = []`
- **Library**: Init
- **Module**: `Init.Data.List.Lemmas`
- **Description**: head? is none iff list is empty

---

## GetElem Operations

### 82. **getElem?_neg**
- **Type**: `{cont : Type u_1} {idx : Type u_2} {elem : Type u_3} {dom : cont → idx → Prop} [GetElem? cont idx elem dom] [LawfulGetElem cont idx elem dom] (c : cont) (i : idx) (h : ¬dom c i) : c[i]? = none`
- **Library**: Init
- **Module**: `Init.GetElem`
- **Description**: GetElem returns none when domain predicate fails

### 83. **getElem?_eq_none_iff**
- **Type**: `{cont : Type u_1} {idx : Type u_2} {elem : Type u_3} {dom : cont → idx → Prop} [GetElem? cont idx elem dom] [LawfulGetElem cont idx elem dom] (c : cont) (i : idx) [Decidable (dom c i)] : c[i]? = none ↔ ¬dom c i`
- **Library**: Init
- **Module**: `Init.GetElem`
- **Description**: GetElem is none iff domain fails

### 84. **none_eq_getElem?_iff**
- **Type**: `{cont : Type u_1} {idx : Type u_2} {elem : Type u_3} {dom : cont → idx → Prop} [GetElem? cont idx elem dom] [LawfulGetElem cont idx elem dom] (c : cont) (i : idx) [Decidable (dom c i)] : none = c[i]? ↔ ¬dom c i`
- **Library**: Init
- **Module**: `Init.GetElem`
- **Description**: none equals GetElem iff domain fails

### 85. **LawfulGetElem.getElem?_def**
- **Type**: `{cont : Type u} {idx : Type v} {elem : outParam (Type w)} {dom : outParam (cont → idx → Prop)} {ge : GetElem? cont idx elem dom} [self : LawfulGetElem cont idx elem dom] (c : cont) (i : idx) [Decidable (dom c i)] : c[i]? = if h : dom c i then some c[i] else none`
- **Library**: Init
- **Module**: `Init.GetElem`
- **Description**: GetElem? succeeds when validity predicate is satisfied and fails otherwise

---

## OptionT Monad Transformer

### 86. **OptionT.fail.eq_1**
- **Type**: `{m : Type u → Type v} [Monad m] {α : Type u} : OptionT.fail = OptionT.mk (pure none)`
- **Library**: Init
- **Module**: `Init.Control.Lawful.Instances`
- **Description**: OptionT failure is pure none

### 87. **OptionT.run_failure**
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_1} [Monad m] : failure.run = pure none`
- **Library**: Init
- **Module**: `Init.Control.Lawful.Instances`
- **Description**: Running failure gives pure none

### 88. **OptionT.run_throw**
- **Type**: `{m : Type u_1 → Type u_2} {β : Type u_1} {e : PUnit} [Monad m] : (throw e).run = pure none`
- **Library**: Init
- **Module**: `Init.Control.Lawful.Instances`
- **Description**: Running throw gives pure none

### 89. **OptionT.run_bind**
- **Type**: `{α : Type u_1} {m : Type u_1 → Type u_2} {β : Type u_1} {x : OptionT m α} (f : α → OptionT m β) [Monad m] : (x >>= f).run = Option.elimM x.run (pure none) fun x => (f x).run`
- **Library**: Init
- **Module**: `Init.Control.Lawful.Instances`
- **Description**: Running bind eliminates with pure none

### 90. **OptionT.run_seqRight**
- **Type**: `{m : Type u_1 → Type u_2} {α β : Type u_1} [Monad m] [LawfulMonad m] (x : OptionT m α) (y : OptionT m β) : (x *> y).run = Option.elimM x.run (pure none) (Function.const α y.run)`
- **Library**: Init
- **Module**: `Init.Control.Lawful.Instances`
- **Description**: Running sequence right

### 91. **OptionT.run_seqLeft**
- **Type**: `{m : Type u_1 → Type u_2} {α β : Type u_1} [Monad m] [LawfulMonad m] (x : OptionT m α) (y : OptionT m β) : (x <* y).run = Option.elimM x.run (pure none) fun x => Option.map (Function.const β x) <$> y.run`
- **Library**: Init
- **Module**: `Init.Control.Lawful.Instances`
- **Description**: Running sequence left

### 92. **OptionT.run_seq**
- **Type**: `{m : Type u_1 → Type u_2} {α β : Type u_1} [Monad m] [LawfulMonad m] (f : OptionT m (α → β)) (x : OptionT m α) : (f <*> x).run = Option.elimM f.run (pure none) fun f => Option.map f <$> x.run`
- **Library**: Init
- **Module**: `Init.Control.Lawful.Instances`
- **Description**: Running applicative seq

---

## Conditional and Guard Operations

### 93. **Option.guard_eq_none_iff**
- **Type**: `{α : Type u_1} {p : α → Bool} {a : α} : Option.guard p a = none ↔ p a = false`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Guard returns none iff predicate is false

### 94. **Option.guard_apply**
- **Type**: `{α : Type u_1} {p : α → Bool} {x : α} : Option.guard p x = if p x = true then some x else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Guard definition as if-then-else

### 95. **Option.guard_def**
- **Type**: `{α : Type u_1} (p : α → Bool) : Option.guard p = fun x => if p x = true then some x else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Guard function definition

### 96. **Option.guard_eq_ite**
- **Type**: `{α : Type u_1} {p : α → Bool} {x : α} : Option.guard p x = if p x = true then some x else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Guard as if-then-else

### 97. **Option.guard_beq_none**
- **Type**: `{α : Type u_1} [BEq α] {x : α} {p : α → Bool} : (Option.guard p x == none) = !p x`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Guard beq none equals negation of predicate

---

## If-Then-Else with none

### 98. **Option.isSome_ite**
- **Type**: `{α : Type u_1} {b : α} {p : Prop} {x : Decidable p} : (if p then some b else none).isSome = true ↔ p`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: isSome of conditional is the condition

### 99. **Option.isSome_ite'**
- **Type**: `{α : Type u_1} {b : α} {p : Prop} {x : Decidable p} : (if p then none else some b).isSome = true ↔ ¬p`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: isSome of negated conditional

### 100. **Option.isSome_dite**
- **Type**: `{β : Type u_1} {p : Prop} {x : Decidable p} {b : p → β} : (if h : p then some (b h) else none).isSome = true ↔ p`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: isSome of dependent conditional

### 101. **Option.isSome_dite'**
- **Type**: `{β : Type u_1} {p : Prop} {x : Decidable p} {b : ¬p → β} : (if h : p then none else some (b h)).isSome = true ↔ ¬p`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: isSome of negated dependent conditional

### 102. **Option.ite_some_none_eq_some**
- **Type**: `{α : Type u_1} {p : Prop} {x : Decidable p} {a b : α} : (if p then some a else none) = some b ↔ p ∧ a = b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Conditional equals some iff condition and values match

### 103. **Option.ite_none_right_eq_some**
- **Type**: `{α : Type u_1} {a : α} {p : Prop} {x : Decidable p} {b : Option α} : (if p then b else none) = some a ↔ p ∧ b = some a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Conditional with none on right

### 104. **Option.ite_none_left_eq_some**
- **Type**: `{β : Type u_1} {a : β} {p : Prop} {x : Decidable p} {b : Option β} : (if p then none else b) = some a ↔ ¬p ∧ b = some a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Conditional with none on left

### 105. **Option.dite_none_right_eq_some**
- **Type**: `{α : Type u_1} {a : α} {p : Prop} {x : Decidable p} {b : p → Option α} : (if h : p then b h else none) = some a ↔ ∃ (h : p), b h = some a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent conditional with none on right

### 106. **Option.dite_none_left_eq_some**
- **Type**: `{β : Type u_1} {a : β} {p : Prop} {x : Decidable p} {b : ¬p → Option β} : (if h : p then none else b h) = some a ↔ ∃ (h : ¬p), b h = some a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent conditional with none on left

---

## Map and Filter Combinations

### 107. **Option.map_eq_none_iff**
- **Type**: `{α : Type u_1} {x : Option α} {α' : Type u_2} {f : α → α'} : Option.map f x = none ↔ x = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Map returns none iff input is none

### 108. **Option.filter_eq_none_iff**
- **Type**: `{α : Type u_1} {o : Option α} {p : α → Bool} : Option.filter p o = none ↔ ∀ (a : α), o = some a → ¬p a = true`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Filter returns none iff predicate fails for all values

### 109. **Option.filter_some_eq_none**
- **Type**: `{α : Type u_1} {p : α → Bool} {a : α} : Option.filter p (some a) = none ↔ ¬p a = true`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Filtering some returns none iff predicate fails

### 110. **Option.filter_some_neg**
- **Type**: `{α : Type u_1} {p : α → Bool} {a : α} (h : p a = false) : Option.filter p (some a) = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Filtering with false predicate gives none

### 111. **Option.filter_some**
- **Type**: `{α : Type u_1} {p : α → Bool} {a : α} : Option.filter p (some a) = if p a = true then some a else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Filter on some as conditional

### 112. **Option.map_guard**
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → Bool} {f : α → β} {x : α} : Option.map f (Option.guard p x) = if p x = true then some (f x) else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Mapping over guard

### 113. **Option.map_if**
- **Type**: `{α : Type u_1} {β : Type u_2} {c : Prop} {a : α} {f : α → β} {x : Decidable c} : Option.map f (if c then some a else none) = if c then some (f a) else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Map over conditional

### 114. **Option.map_dif**
- **Type**: `{α : Type u_1} {β : Type u_2} {c : Prop} {f : α → β} {x : Decidable c} {a : c → α} : Option.map f (if h : c then some (a h) else none) = if h : c then some (f (a h)) else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Map over dependent conditional

---

## Bind Operations

### 115. **Option.bind_fun_none**
- **Type**: `{α : Type u_1} {β : Type u_2} (x : Option α) : (x.bind fun x => none) = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Binding with constant none function gives none

### 116. **Option.bind_eq_none_iff**
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {f : α → Option β} : o.bind f = none ↔ ∀ (a : α), o = some a → f a = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Bind returns none iff function returns none for all values

### 117. **Option.bind_eq_none'**
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {f : α → Option β} : o.bind f = none ↔ ∀ (b : β) (a : α), o = some a → f a ≠ some b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Bind returns none iff no value produces some

---

## Join Operations

### 118. **Option.join_ne_none**
- **Type**: `{α : Type u_1} {x : Option (Option α)} : x.join ≠ none ↔ ∃ z, x = some (some z)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Join is not none iff nested some

### 119. **Option.join_ne_none'**
- **Type**: `{α : Type u_1} {x : Option (Option α)} : ¬x.join = none ↔ ∃ z, x = some (some z)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Join not equal to none iff nested some

### 120. **Option.join_eq_none_iff**
- **Type**: `{α : Type u_1} {o : Option (Option α)} : o.join = none ↔ o = none ∨ o = some none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Join is none iff outer or inner is none

### 121. **Option.join_beq_none**
- **Type**: `{α : Type u_1} [BEq α] {o : Option (Option α)} : (o.join == none) = (o == none || o == some none)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Join beq none via boolean or

---

## Or/Alternative Combinations

### 122. **Option.or_eq_left_of_none**
- **Type**: `{α : Type u_1} {o o' : Option α} (h : o' = none) : o.or o' = o`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Or equals left when right is none

### 123. **Option.or_eq_right_of_none**
- **Type**: `{α : Type u_1} {o o' : Option α} (h : o = none) : o.or o' = o'`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Or equals right when left is none

### 124. **Option.or_eq_none_iff**
- **Type**: `{α : Type u_1} {o o' : Option α} : o.or o' = none ↔ o = none ∧ o' = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Or is none iff both are none

### 125. **Option.or_eq_some_iff**
- **Type**: `{α : Type u_1} {o o' : Option α} {a : α} : o.or o' = some a ↔ o = some a ∨ o = none ∧ o' = some a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Or equals some iff left is some or left is none and right is some

---

## Merge Combinations

### 126. **Option.merge_eq_none_iff**
- **Type**: `{α : Type u_1} {f : α → α → α} {o o' : Option α} : Option.merge f o o' = none ↔ o = none ∧ o' = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Merge is none iff both are none

### 127. **Option.merge_eq_some_iff**
- **Type**: `{α : Type u_1} {o o' : Option α} {f : α → α → α} {a : α} : Option.merge f o o' = some a ↔ o = some a ∧ o' = none ∨ o = none ∧ o' = some a ∨ ∃ b c, o = some b ∧ o' = some c ∧ f b c = a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Merge equals some in three cases

### 128. **Option.merge_beq_none**
- **Type**: `{α : Type u_1} [BEq α] {o o' : Option α} {f : α → α → α} : (Option.merge f o o' == none) = (o == none && o' == none)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Merge beq none via boolean and

---

## Max/Min Combinations

### 129. **Option.max_eq_none_iff**
- **Type**: `{α : Type u_1} [Max α] {o o' : Option α} : o ⊔ o' = none ↔ o = none ∧ o' = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Max is none iff both are none

### 130. **Option.max_eq_some_iff**
- **Type**: `{α : Type u_1} [Max α] {o o' : Option α} {a : α} : o ⊔ o' = some a ↔ o = some a ∧ o' = none ∨ o = none ∧ o' = some a ∨ ∃ b c, o = some b ∧ o' = some c ∧ b ⊔ c = a`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Max equals some in three cases

### 131. **Option.min_eq_none_iff**
- **Type**: `{α : Type u_1} [Min α] {o o' : Option α} : o ⊓ o' = none ↔ o = none ∨ o' = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Min is none iff either is none

---

## Dependent Operations (pmap, pbind, pfilter)

### 132. **Option.pbind_none**
- **Type**: `{α : Type u_1} {α' : Type u_2} {f : (a : α) → none = some a → Option α'} : none.pbind f = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent bind on none is none

### 133. **Option.pbind_none'**
- **Type**: `{α : Type u_1} {x : Option α} {α' : Type u_2} {f : (a : α) → x = some a → Option α'} (h : x = none) : x.pbind f = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent bind when proven none

### 134. **Option.pbind_eq_none_iff**
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {f : (a : α) → o = some a → Option β} : o.pbind f = none ↔ o = none ∨ ∃ a, ∃ (h : o = some a), f a h = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent bind is none iff input none or function returns none

### 135. **Option.isNone_pbind_iff**
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {f : (a : α) → o = some a → Option β} : (o.pbind f).isNone = true ↔ o = none ∨ ∃ a, ∃ (h : o = some a), f a h = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: isNone of pbind

### 136. **Option.pmap_none**
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → Prop} {f : (a : α) → p a → β} {h : ∀ (a : α), none = some a → p a} : Option.pmap f none h = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent map on none is none

### 137. **Option.pmap_none'**
- **Type**: `{α : Type u_1} {β : Type u_2} {x : Option α} {p : α → Prop} {f : (a : α) → p a → β} (he : x = none) {h : ∀ (a : α), x = some a → p a} : Option.pmap f x h = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent map when proven none

### 138. **Option.pmap_eq_none_iff**
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {p : α → Prop} {f : (a : α) → p a → β} {h : ∀ (a : α), o = some a → p a} : Option.pmap f o h = none ↔ o = none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent map is none iff input is none

### 139. **Option.pfilter_eq_none_iff**
- **Type**: `{α : Type u_1} {o : Option α} {p : (a : α) → o = some a → Bool} : o.pfilter p = none ↔ o = none ∨ ∃ a, ∃ (ha : o = some a), p a ha = false`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent filter is none iff input none or predicate fails

### 140. **Option.pfilter_some**
- **Type**: `{α : Type u_1} {x : α} {p : (a : α) → some x = some a → Bool} : (some x).pfilter p = if p x ⋯ = true then some x else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent filter on some

### 141. **Option.pfilter_eq_pbind_ite**
- **Type**: `{α : Type u_1} {o : Option α} {p : (a : α) → o = some a → Bool} : o.pfilter p = o.pbind fun a h => if p a h = true then some a else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: pfilter as pbind with conditional

### 142. **Option.pfilter_guard**
- **Type**: `{α : Type u_1} {a : α} {p : α → Bool} {q : (a' : α) → Option.guard p a = some a' → Bool} : (Option.guard p a).pfilter q = if ∃ (h : p a = true), q a ⋯ = true then some a else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent filter on guard

### 143. **Option.pmap_guard**
- **Type**: `{α : Type u_1} {β : Type u_2} {q : α → Bool} {p : α → Prop} (f : (x : α) → p x → β) {x : α} (h : ∀ (a : α), Option.guard q x = some a → p a) : Option.pmap f (Option.guard q x) h = if h' : q x = true then some (f x ⋯) else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent map on guard

### 144. **Option.pmap_or**
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → Prop} {f : (a : α) → p a → β} {o o' : Option α} {h : ∀ (a : α), o.or o' = some a → p a} : Option.pmap f (o.or o') h = match o, h with | none, h => Option.pmap f o' ⋯ | some a, h => some (f a ⋯)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Dependent map on or

---

## GetD (Get with Default) Operations

### 145. **Option.getD_of_ne_none**
- **Type**: `{α : Type u_1} {x : Option α} (hx : x ≠ none) (y : α) : some (x.getD y) = x`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: getD when not none reconstructs some

### 146. **Option.getD_eq_iff**
- **Type**: `{α : Type u_1} {o : Option α} {a b : α} : o.getD a = b ↔ o = some b ∨ o = none ∧ a = b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: getD equals value in two cases

---

## Membership in Conditionals

### 147. **Option.mem_ite_none_right**
- **Type**: `{α : Type u_1} {p : Prop} {x : α} {x' : Decidable p} {l : Option α} : (x ∈ if p then l else none) ↔ p ∧ x ∈ l`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Membership in conditional with none on right

### 148. **Option.mem_ite_none_left**
- **Type**: `{α : Type u_1} {p : Prop} {x : α} {x' : Decidable p} {l : Option α} : (x ∈ if p then none else l) ↔ ¬p ∧ x ∈ l`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Membership in conditional with none on left

### 149. **Option.mem_dite_none_right**
- **Type**: `{α : Type u_1} {p : Prop} {x : α} {x' : Decidable p} {l : p → Option α} : (x ∈ if h : p then l h else none) ↔ ∃ (h : p), x ∈ l h`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Membership in dependent conditional with none on right

### 150. **Option.mem_dite_none_left**
- **Type**: `{α : Type u_1} {p : Prop} {x : α} {x' : Decidable p} {l : ¬p → Option α} : (x ∈ if h : p then none else l h) ↔ ∃ (h : ¬p), x ∈ l h`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Membership in dependent conditional with none on left

---

## Get Operations on Conditionals

### 151. **Option.get_ite**
- **Type**: `{α : Type u_1} {b : α} {p : Prop} {x : Decidable p} (h : (if p then some b else none).isSome = true) : (if p then some b else none).get h = b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Getting from conditional

### 152. **Option.get_ite'**
- **Type**: `{α : Type u_1} {b : α} {p : Prop} {x : Decidable p} (h : (if p then none else some b).isSome = true) : (if p then none else some b).get h = b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Getting from negated conditional

### 153. **Option.get_dite**
- **Type**: `{β : Type u_1} {p : Prop} {x : Decidable p} (b : p → β) (w : (if h : p then some (b h) else none).isSome = true) : (if h : p then some (b h) else none).get w = b ⋯`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Getting from dependent conditional

### 154. **Option.get_dite'**
- **Type**: `{β : Type u_1} {p : Prop} {x : Decidable p} (b : ¬p → β) (w : (if h : p then none else some (b h)).isSome = true) : (if h : p then none else some (b h)).get w = b ⋯`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Getting from negated dependent conditional

---

## Equality with Conditionals

### 155. **Option.some_eq_ite_none_right**
- **Type**: `{α : Type u_1} {a : α} {p : Prop} {x : Decidable p} {b : Option α} : (some a = if p then b else none) ↔ p ∧ some a = b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: some equals conditional with none on right

### 156. **Option.some_eq_ite_none_left**
- **Type**: `{β : Type u_1} {a : β} {p : Prop} {x : Decidable p} {b : Option β} : (some a = if p then none else b) ↔ ¬p ∧ some a = b`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: some equals conditional with none on left

### 157. **Option.some_eq_dite_none_right**
- **Type**: `{α : Type u_1} {a : α} {p : Prop} {x : Decidable p} {b : p → Option α} : (some a = if h : p then b h else none) ↔ ∃ (h : p), some a = b h`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: some equals dependent conditional with none on right

### 158. **Option.some_eq_dite_none_left**
- **Type**: `{β : Type u_1} {a : β} {p : Prop} {x : Decidable p} {b : ¬p → Option β} : (some a = if h : p then none else b h) ↔ ∃ (h : ¬p), some a = b h`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: some equals dependent conditional with none on left

---

## Miscellaneous Theorems

### 159. **Option.choice_eq_none_iff_not_nonempty**
- **Type**: `{α : Type u_1} : Option.choice α = none ↔ ¬Nonempty α`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Choice is none iff type is not nonempty

### 160. **Option.get_none_eq_iff_true**
- **Type**: `{α : Type u_1} {a : α} {h : none.isSome = true} : none.get h = a ↔ True`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Vacuous equality (proof impossible)

### 161. **Option.isSome_eq_isSome**
- **Type**: `{α : Type u_1} {x : Option α} {α' : Type u_2} {y : Option α'} : x.isSome = y.isSome ↔ (x = none ↔ y = none)`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: isSome equality iff none equality

### 162. **Option.join_pfilter**
- **Type**: `{α : Type u_1} {o : Option (Option α)} {p : (o' : Option α) → o = some o' → Bool} : (o.pfilter p).join = o.pbind fun o' ho' => if p o' ho' = true then o' else none`
- **Library**: Init
- **Module**: `Init.Data.Option.Lemmas`
- **Description**: Join of pfilter as pbind

---

## List zipWithAll Operations

### 163. **List.nil_zipWithAll**
- **Type**: `{α α' α'' : Type} {f : Option α → Option α' → α''} {bs : List α'} : List.zipWithAll f [] bs = List.map (fun b => f none (some b)) bs`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Description**: zipWithAll with empty left list

### 164. **List.zipWithAll_nil**
- **Type**: `{α α' α'' : Type} {f : Option α → Option α' → α''} {as : List α} : List.zipWithAll f as [] = List.map (fun a => f (some a) none) as`
- **Library**: Init
- **Module**: `Init.Data.List.Basic`
- **Description**: zipWithAll with empty right list

---

## Int and Other Type Operations

### 165. **Int.toNat?.eq_2**
- **Type**: `(a : ℕ) : (Int.negSucc a).toNat? = none`
- **Library**: Init
- **Module**: `Init.Data.Int.Order`
- **Description**: Negative int to nat returns none

---

## Omega Constraint Operations

### 166. **Lean.Omega.Constraint.trivial.eq_1**
- **Type**: `: Lean.Omega.Constraint.trivial = { lowerBound := none, upperBound := none }`
- **Library**: Init
- **Module**: `Init.Omega.Constraint`
- **Description**: Trivial constraint has no bounds

### 167. **Option.merge.eq_1**
- **Type**: `{α : Type u_1} (fn : α → α → α) : Option.merge fn none none = none`
- **Library**: Init
- **Module**: `Init.Omega.Constraint`
- **Description**: Merging two nones gives none

### 168. **Option.merge.eq_2**
- **Type**: `{α : Type u_1} (fn : α → α → α) (x_2 : α) : Option.merge fn (some x_2) none = some x_2`
- **Library**: Init
- **Module**: `Init.Omega.Constraint`
- **Description**: Merging some with none gives some

### 169. **Option.merge.eq_3**
- **Type**: `{α : Type u_1} (fn : α → α → α) (y : α) : Option.merge fn none (some y) = some y`
- **Library**: Init
- **Module**: `Init.Omega.Constraint`
- **Description**: Merging none with some gives some

### 170. **Lean.Omega.Constraint.addInequality_sat**
- **Type**: `{c : ℤ} {x y : Lean.Omega.Coeffs} (w : c + x.dot y ≥ 0) : { lowerBound := some (-c), upperBound := none }.sat' x y = true`
- **Library**: Init
- **Module**: `Init.Omega.Constraint`
- **Description**: Constraint satisfaction with none upper bound

---

## Array Operations

### 171. **Array.findIdx?.loop.eq_def**
- **Type**: `{α : Type u} (p : α → Bool) (as : Array α) (j : ℕ) : Array.findIdx?.loop p as j = if h : j < as.size then if p as[j] = true then some j else Array.findIdx?.loop p as (j + 1) else none`
- **Library**: Init
- **Module**: `Init.Data.Array.Basic`
- **Description**: Array findIdx loop returns none when exhausted

---

## List Control Operations

### 172. **List.findSome?.eq_1**
- **Type**: `{α : Type u} {β : Type v} (f : α → Option β) : List.findSome? f [] = none`
- **Library**: Init
- **Module**: `Init.Data.List.Control`
- **Description**: findSome on empty list is none

### 173. **List.findSomeM?_nil**
- **Type**: `{m : Type u → Type u_1} [Monad m] {α : Type w} {β : Type u} {f : α → m (Option β)} : List.findSomeM? f [] = pure none`
- **Library**: Init
- **Module**: `Init.Data.List.Control`
- **Description**: Monadic findSome on empty list is pure none

### 174. **List.findSome?.eq_def**
- **Type**: `{α : Type u} {β : Type v} (f : α → Option β) (x : List α) : List.findSome? f x = match x with | [] => none | a :: as => match f a with | some b => some b | none => List.findSome? f as`
- **Library**: Init
- **Module**: `Init.Data.List.Control`
- **Description**: findSome definition with none fallback

### 175. **List.findM?_eq_findSomeM?**
- **Type**: `{m : Type → Type u_1} {α : Type} [Monad m] [LawfulMonad m] {p : α → m Bool} {as : List α} : List.findM? p as = List.findSomeM? (fun a => do let b ← p a; pure (if b = true then some a else none)) as`
- **Library**: Init
- **Module**: `Init.Data.List.Control`
- **Description**: findM as findSomeM with conditional

---

## List filterMap Operations

### 176. **List.filterMap_replicate_of_none**
- **Type**: `{α : Type u_1} {β : Type u_2} {a : α} {n : ℕ} {f : α → Option β} (h : f a = none) : List.filterMap f (List.replicate n a) = []`
- **Library**: Init
- **Module**: `Init.Data.List.Lemmas`
- **Description**: filterMap of replicate with none function

### 177. **List.filterMap_cons_none**
- **Type**: `{α : Type u_1} {β : Type u_2} {f : α → Option β} {a : α} {l : List α} (h : f a = none) : List.filterMap f (a :: l) = List.filterMap f l`
- **Library**: Init
- **Module**: `Init.Data.List.Lemmas`
- **Description**: filterMap skips elements mapping to none

### 178. **List.forall_none_of_filterMap_eq_nil**
- **Type**: `{α α' : Type} {f : α → Option α'} {xs : List α} (h : List.filterMap f xs = []) (x : α) : x ∈ xs → f x = none`
- **Library**: Init
- **Module**: `Init.Data.List.Lemmas`
- **Description**: If filterMap is empty, all elements map to none

### 179. **List.filterMap_eq_nil_iff**
- **Type**: `{α α' : Type} {f : α → Option α'} {l : List α} : List.filterMap f l = [] ↔ ∀ a ∈ l, f a = none`
- **Library**: Init
- **Module**: `Init.Data.List.Lemmas`
- **Description**: filterMap is empty iff all map to none

---

## List replicate Operations

### 180. **List.getLast?_replicate**
- **Type**: `{α : Type u_1} {a : α} {n : ℕ} : (List.replicate n a).getLast? = if n = 0 then none else some a`
- **Library**: Init
- **Module**: `Init.Data.List.Lemmas`
- **Description**: getLast of replicate

---

## Equation Compiler Generated Theorems

The following are equation compiler generated theorems (marked with `.eq_1`, `.eq_2`, etc.):

### 181-200. Various `.eq_*` theorems

These are definitional equations generated by LEAN's equation compiler for pattern matching definitions. They specify how functions reduce on specific patterns, particularly the `none` case. Examples include:

- **Option.elim.eq_2**: Elimination on none
- **Option.map.eq_2**: Map on none  
- **Option.bind.eq_1**: Bind on none
- **Option.filter.eq_1**, **Option.filter.eq_2**: Filter on none
- **Option.guard.eq_1**: Guard definition
- **Option.pmap.eq_1**: Dependent map on none
- **Option.pfilter.eq_1**, **Option.pfilter.eq_2**: Dependent filter
- **Option.le.eq_1**, **Option.le.eq_2**, **Option.le.eq_3**: Order relation cases
- **Option.lt.eq_1**, **Option.lt.eq_3**: Strict order cases
- **Option.isSome.eq_2**: isSome on none
- **Option.isEqSome.eq_2**: isEqSome on none
- **List.getLast?.eq_1**: getLast on empty list
- **List.findSome?.eq_1**: findSome on empty list

---

## Summary Statistics

- **Total declarations found**: 2524
- **Declarations shown**: 200 (first 200)
- **Primary library**: Init (LEAN Core Standard Library)
- **Main modules**:
  - `Init.Data.Option.Basic` - Core Option operations
  - `Init.Data.Option.Lemmas` - Option theorems and lemmas
  - `Init.Data.List.Basic` - List operations returning Option
  - `Init.Data.List.Lemmas` - List theorems with Option
  - `Init.GetElem` - Generic element access
  - `Init.Control.Lawful.Instances` - Lawful instances for OptionT

---

## Key Patterns and Usage

### 1. **Identity Properties**
- `none` is the identity for `or`, `max`, and `merge` operations
- `none` is the absorbing element for `min` and `bind` operations

### 2. **Functor Laws**
- Mapping, binding, and filtering `none` always returns `none`
- `none` is the zero element for monadic operations

### 3. **Order Properties**
- `none` is the bottom element (≤ all other options)
- `none` is strictly less than any `some`

### 4. **Characterization**
- Every option is either `none` or `some x`
- `o ≠ none ↔ ∃ x, o = some x`
- `o = none ↔ o.isNone = true`

### 5. **Conditional Patterns**
- Many theorems about `if p then some a else none`
- Guard operations that return `none` when predicates fail

---

## Recommendations

### For Finding Functions
Use Loogle with type patterns to find functions that:
- Return `Option α` (may return `none`)
- Take `Option α` as input (must handle `none`)
- Transform between `Option` and other types

### For Proving Theorems
Key lemmas for working with `none`:
- `Option.eq_none_or_eq_some` - case split
- `Option.ne_none_iff_exists` - existence
- `Option.bind_eq_none_iff` - monadic reasoning
- `Option.map_eq_none_iff` - functor reasoning

### For Code Development
Common patterns:
- Use `getD` for default values
- Use `or` for fallback options
- Use `filter` and `guard` for conditional construction
- Use `bind` for chaining optional computations

---

## Notes

1. This search returned the first 200 of 2524 total matches
2. All results are from the Init library (LEAN's core)
3. No Mathlib results in this set (Mathlib likely has additional theorems)
4. Many equation compiler generated theorems (`.eq_*`) for definitional reduction
5. Strong coverage of:
   - Basic operations (map, bind, filter)
   - Order operations (≤, <, max, min)
   - Alternative operations (or, orElse)
   - Dependent operations (pmap, pbind, pfilter)
   - List operations returning Option
   - Conditional constructions with none

---

**Report Generated**: December 20, 2025  
**Search Tool**: Loogle API (https://loogle.lean-lang.org/)  
**Query**: `Option.none`

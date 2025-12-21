# Complete List of Option.none Matches (First 200 of 2524)

**Search Date**: December 20, 2025  
**Total Matches**: 2524  
**Matches Listed**: 200

---

## All Matches with Full Details

### 1. Option.none
- **Type**: `{α : Type u} : Option α`
- **Module**: `Init.Prelude`
- **Library**: Init (Core)
- **Description**: No value.

### 2. Option.none.sizeOf_spec
- **Type**: `{α : Type u} [SizeOf α] : sizeOf none = 1`
- **Module**: `Init.SizeOf`
- **Library**: Init

### 3. List.getLast?_nil
- **Type**: `{α : Type u} : [].getLast? = none`
- **Module**: `Init.Data.List.Basic`
- **Library**: Init

### 4. List.head?_nil
- **Type**: `{α : Type u} : [].head? = none`
- **Module**: `Init.Data.List.Basic`
- **Library**: Init

### 5. List.tail?_nil
- **Type**: `{α : Type u} : [].tail? = none`
- **Module**: `Init.Data.List.Basic`
- **Library**: Init

### 6. List.find?_nil
- **Type**: `{α : Type u} {p : α → Bool} : List.find? p [] = none`
- **Module**: `Init.Data.List.Basic`
- **Library**: Init

### 7. List.findSome?_nil
- **Type**: `{α : Type u} {α' : Type u_1} {f : α → Option α'} : List.findSome? f [] = none`
- **Module**: `Init.Data.List.Basic`
- **Library**: Init

### 8. List.lookup_nil
- **Type**: `{α : Type u} {β : Type v} {a : α} [BEq α] : List.lookup a [] = none`
- **Module**: `Init.Data.List.Basic`
- **Library**: Init

### 9. List.nil_zipWithAll
- **Type**: `{α α' α'' : Type} {f : Option α → Option α' → α''} {bs : List α'} : List.zipWithAll f [] bs = List.map (fun b => f none (some b)) bs`
- **Module**: `Init.Data.List.Basic`
- **Library**: Init

### 10. List.zipWithAll_nil
- **Type**: `{α α' α'' : Type} {f : Option α → Option α' → α''} {as : List α} : List.zipWithAll f as [] = List.map (fun a => f (some a) none) as`
- **Module**: `Init.Data.List.Basic`
- **Library**: Init

### 11. Option.isNone_none
- **Type**: `{α : Type u_1} : none.isNone = true`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 12. Option.isSome_none
- **Type**: `{α : Type u_1} : none.isSome = false`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 13. Option.decidableEqNone
- **Type**: `{α : Type u_1} (o : Option α) : Decidable (o = none)`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init
- **Description**: Equality with `none` is decidable even if the wrapped type does not have decidable equality.

### 14. Option.decidableNoneEq
- **Type**: `{α : Type u_1} (o : Option α) : Decidable (none = o)`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init
- **Description**: Equality with `none` is decidable even if the wrapped type does not have decidable equality.

### 15. Option.getD_none
- **Type**: `{α : Type u_1} {a : α} : none.getD a = a`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 16. Option.all_none
- **Type**: `{α : Type u_1} {p : α → Bool} : Option.all p none = true`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 17. Option.any_none
- **Type**: `{α : Type u_1} {p : α → Bool} : Option.any p none = false`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 18. Option.join_none
- **Type**: `{α : Type u_1} : none.join = none`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 19. Option.Rel.none
- **Type**: `{α : Type u_1} {β : Type u_2} {r : α → β → Prop} : Option.Rel r none none`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init
- **Description**: `none ~ none`

### 20. Option.orElse_none
- **Type**: `{α : Type u_1} {b : Unit → Option α} : none.orElse b = b ()`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 21. Option.map_none
- **Type**: `{α : Type u_1} {β : Type u_2} (f : α → β) : Option.map f none = none`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 22. Option.bind_none
- **Type**: `{α : Type u_1} {β : Type u_2} (f : α → Option β) : none.bind f = none`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 23. Option.getDM_none
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_1} [Pure m] (y : m α) : none.getDM y = y`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 24. Option.getM_none
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_1} [Alternative m] : none.getM = failure`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 25. Option.max_none_left
- **Type**: `{α : Type u_1} [Max α] {o : Option α} : none ⊔ o = o`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 26. Option.max_none_right
- **Type**: `{α : Type u_1} [Max α] {o : Option α} : o ⊔ none = o`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 27. Option.min_none_left
- **Type**: `{α : Type u_1} [Min α] {o : Option α} : none ⊓ o = none`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 28. Option.min_none_right
- **Type**: `{α : Type u_1} [Min α] {o : Option α} : o ⊓ none = none`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 29. Option.sequence_none
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_1} [Applicative m] : none.sequence = pure none`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 30. Option.mapM_none
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_3} {β : Type u_1} [Applicative m] (f : α → m β) : Option.mapM f none = pure none`
- **Module**: `Init.Data.Option.Basic`
- **Library**: Init

### 31. List.getElem?_eq_none
- **Type**: `{α : Type u_1} {l : List α} {i : ℕ} (h : l.length ≤ i) : l[i]? = none`
- **Module**: `Init.GetElem`
- **Library**: Init

### 32. getElem?_neg
- **Type**: `{cont : Type u_1} {idx : Type u_2} {elem : Type u_3} {dom : cont → idx → Prop} [GetElem? cont idx elem dom] [LawfulGetElem cont idx elem dom] (c : cont) (i : idx) (h : ¬dom c i) : c[i]? = none`
- **Module**: `Init.GetElem`
- **Library**: Init

### 33. List.getElem?_eq_none_iff
- **Type**: `{α : Type u_1} {l : List α} {i : ℕ} : l[i]? = none ↔ l.length ≤ i`
- **Module**: `Init.GetElem`
- **Library**: Init

### 34. List.none_eq_getElem?_iff
- **Type**: `{α : Type u_1} {l : List α} {i : ℕ} : none = l[i]? ↔ l.length ≤ i`
- **Module**: `Init.GetElem`
- **Library**: Init

### 35. getElem?_eq_none_iff
- **Type**: `{cont : Type u_1} {idx : Type u_2} {elem : Type u_3} {dom : cont → idx → Prop} [GetElem? cont idx elem dom] [LawfulGetElem cont idx elem dom] (c : cont) (i : idx) [Decidable (dom c i)] : c[i]? = none ↔ ¬dom c i`
- **Module**: `Init.GetElem`
- **Library**: Init

### 36. none_eq_getElem?_iff
- **Type**: `{cont : Type u_1} {idx : Type u_2} {elem : Type u_3} {dom : cont → idx → Prop} [GetElem? cont idx elem dom] [LawfulGetElem cont idx elem dom] (c : cont) (i : idx) [Decidable (dom c i)] : none = c[i]? ↔ ¬dom c i`
- **Module**: `Init.GetElem`
- **Library**: Init

### 37. LawfulGetElem.getElem?_def
- **Type**: `{cont : Type u} {idx : Type v} {elem : outParam (Type w)} {dom : outParam (cont → idx → Prop)} {ge : GetElem? cont idx elem dom} [self : LawfulGetElem cont idx elem dom] (c : cont) (i : idx) [Decidable (dom c i)] : c[i]? = if h : dom c i then some c[i] else none`
- **Module**: `Init.GetElem`
- **Library**: Init
- **Description**: `GetElem?.getElem?` succeeds when the validity predicate is satisfied and fails otherwise.

### 38. LawfulGetElem.mk
- **Type**: Complex constructor type for LawfulGetElem
- **Module**: `Init.GetElem`
- **Library**: Init

### 39. Array.findIdx?.loop.eq_def
- **Type**: `{α : Type u} (p : α → Bool) (as : Array α) (j : ℕ) : Array.findIdx?.loop p as j = if h : j < as.size then if p as[j] = true then some j else Array.findIdx?.loop p as (j + 1) else none`
- **Module**: `Init.Data.Array.Basic`
- **Library**: Init

### 40. Option.elim.eq_2
- **Type**: `{α : Type u_1} {β : Sort u_2} (x : β) (x' : α → β) : none.elim x x' = x`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 41. Option.map.eq_2
- **Type**: `{α : Type u_1} {β : Type u_2} (f : α → β) : Option.map f none = none`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 42. OptionT.fail.eq_1
- **Type**: `{m : Type u → Type v} [Monad m] {α : Type u} : OptionT.fail = OptionT.mk (pure none)`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 43. OptionT.run_failure
- **Type**: `{m : Type u_1 → Type u_2} {α : Type u_1} [Monad m] : failure.run = pure none`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 44. OptionT.run_throw
- **Type**: `{m : Type u_1 → Type u_2} {β : Type u_1} {e : PUnit} [Monad m] : (throw e).run = pure none`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 45. OptionT.run_bind
- **Type**: `{α : Type u_1} {m : Type u_1 → Type u_2} {β : Type u_1} {x : OptionT m α} (f : α → OptionT m β) [Monad m] : (x >>= f).run = Option.elimM x.run (pure none) fun x => (f x).run`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 46. OptionT.bind.eq_1
- **Type**: Complex OptionT bind equation
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 47. OptionT.run_seqRight
- **Type**: `{m : Type u_1 → Type u_2} {α β : Type u_1} [Monad m] [LawfulMonad m] (x : OptionT m α) (y : OptionT m β) : (x *> y).run = Option.elimM x.run (pure none) (Function.const α y.run)`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 48. OptionT.run_seqLeft
- **Type**: `{m : Type u_1 → Type u_2} {α β : Type u_1} [Monad m] [LawfulMonad m] (x : OptionT m α) (y : OptionT m β) : (x <* y).run = Option.elimM x.run (pure none) fun x => Option.map (Function.const β x) <$> y.run`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 49. OptionT.run_seq
- **Type**: `{m : Type u_1 → Type u_2} {α β : Type u_1} [Monad m] [LawfulMonad m] (f : OptionT m (α → β)) (x : OptionT m α) : (f <*> x).run = Option.elimM f.run (pure none) fun f => Option.map f <$> x.run`
- **Module**: `Init.Control.Lawful.Instances`
- **Library**: Init

### 50. Int.toNat?.eq_2
- **Type**: `(a : ℕ) : (Int.negSucc a).toNat? = none`
- **Module**: `Init.Data.Int.Order`
- **Library**: Init

### 51. Lean.Omega.Constraint.trivial.eq_1
- **Type**: `: Lean.Omega.Constraint.trivial = { lowerBound := none, upperBound := none }`
- **Module**: `Init.Omega.Constraint`
- **Library**: Init

### 52. Option.merge.eq_1
- **Type**: `{α : Type u_1} (fn : α → α → α) : Option.merge fn none none = none`
- **Module**: `Init.Omega.Constraint`
- **Library**: Init

### 53. Option.merge.eq_2
- **Type**: `{α : Type u_1} (fn : α → α → α) (x_2 : α) : Option.merge fn (some x_2) none = some x_2`
- **Module**: `Init.Omega.Constraint`
- **Library**: Init

### 54. Option.merge.eq_3
- **Type**: `{α : Type u_1} (fn : α → α → α) (y : α) : Option.merge fn none (some y) = some y`
- **Module**: `Init.Omega.Constraint`
- **Library**: Init

### 55. Lean.Omega.Constraint.addInequality_sat
- **Type**: `{c : ℤ} {x y : Lean.Omega.Coeffs} (w : c + x.dot y ≥ 0) : { lowerBound := some (-c), upperBound := none }.sat' x y = true`
- **Module**: `Init.Omega.Constraint`
- **Library**: Init

### 56. Option.eq_none_of_isNone
- **Type**: `{α : Type u} {o : Option α} : o.isNone = true → o = none`
- **Module**: `Init.Data.Option.Instances`
- **Library**: Init

### 57. Option.isNone_iff_eq_none
- **Type**: `{α : Type u_1} {o : Option α} : o.isNone = true ↔ o = none`
- **Module**: `Init.Data.Option.Instances`
- **Library**: Init

### 58. Option.instLawfulIdentityOrNone
- **Type**: `{α : Type u_1} : Std.LawfulIdentity Option.or none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 59. Option.isSome.eq_2
- **Type**: `{α : Type u_1} : none.isSome = false`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 60. Option.some_ne_none
- **Type**: `{α : Type u_1} (x : α) : some x ≠ none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 61. Option.toList_none
- **Type**: `(α : Type u_1) : none.toList = []`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 62. Option.default_eq_none
- **Type**: `{α : Type u_1} : default = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 63. Option.choice_eq_none_iff_not_nonempty
- **Type**: `{α : Type u_1} : Option.choice α = none ↔ ¬Nonempty α`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 64. Option.guard_false
- **Type**: `{α : Type u_1} : (Option.guard fun x => false) = fun x => none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 65. Option.lawfulIdentity_merge
- **Type**: `{α : Type u_1} (f : α → α → α) : Std.LawfulIdentity (Option.merge f) none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 66. Option.none_or
- **Type**: `{α : Type u_1} {o : Option α} : none.or o = o`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 67. Option.not_mem_none
- **Type**: `{α : Type u_1} (a : α) : a ∉ none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 68. Option.or_none
- **Type**: `{α : Type u_1} {o : Option α} : o.or none = o`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 69. Option.toArray_none
- **Type**: `(α : Type u_1) : none.toArray = #[]`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 70. Option.filter_none
- **Type**: `{α : Type u_1} (p : α → Bool) : Option.filter p none = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 71. Option.get!_none
- **Type**: `{α : Type u_1} [Inhabited α] : none.get! = default`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 72. Option.rel_none_none
- **Type**: `{α : Type u_1} {β : Type u_2} {r : α → β → Prop} : Option.Rel r none none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 73. Option.filter.eq_2
- **Type**: `{α : Type u_1} (p : α → Bool) : Option.filter p none = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 74. Option.isEqSome.eq_2
- **Type**: `{α : Type u_1} [BEq α] (x : α) : none.isEqSome x = false`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 75. Option.instLawfulIdentityMaxNone
- **Type**: `{α : Type u_1} [Max α] : Std.LawfulIdentity max none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 76. Option.none_le
- **Type**: `{α : Type u_1} [LE α] {a : Option α} : none ≤ a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 77. Option.elim_none
- **Type**: `{β : Sort u_1} {α : Type u_2} (x : β) (f : α → β) : none.elim x f = x`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 78. Option.none_lt_some
- **Type**: `{α : Type u_1} [LT α] {a : α} : none < some a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 79. Option.not_lt_none
- **Type**: `{α : Type u_1} [LT α] {a : Option α} : ¬a < none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 80. Option.bind_fun_none
- **Type**: `{α : Type u_1} {β : Type u_2} (x : Option α) : (x.bind fun x => none) = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 81. Option.isSome_iff_ne_none
- **Type**: `{α : Type u_1} {o : Option α} : o.isSome = true ↔ o ≠ none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 82. Option.merge_none_left
- **Type**: `{α : Type u_1} {f : α → α → α} {b : Option α} : Option.merge f none b = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 83. Option.merge_none_right
- **Type**: `{α : Type u_1} {f : α → α → α} {a : Option α} : Option.merge f a none = a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 84. Option.ne_none_iff_isSome
- **Type**: `{α : Type u_1} {o : Option α} : o ≠ none ↔ o.isSome = true`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 85. Option.none_beq_none
- **Type**: `{α : Type u_1} [BEq α] : (none == none) = true`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 86. Option.not_rel_none_some
- **Type**: `{α : Type u_1} {β : Type u_2} {a : β} {r : α → β → Prop} : ¬Option.Rel r none (some a)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 87. Option.not_rel_some_none
- **Type**: `{α : Type u_1} {β : Type u_2} {a : α} {r : α → β → Prop} : ¬Option.Rel r (some a) none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 88. Option.not_some_le_none
- **Type**: `{α : Type u_1} [LE α] {a : α} : ¬some a ≤ none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 89. Option.bind.eq_1
- **Type**: `{α : Type u_1} {β : Type u_2} (x : α → Option β) : none.bind x = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 90. Option.le.eq_2
- **Type**: `{α : Type u_1} {β : Type u_2} (r : α → β → Prop) : Option.le r none none = True`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 91. Option.get_none
- **Type**: `{α : Type u_1} (a : α) {h : none.isSome = true} : none.get h = a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 92. Option.not_isSome_iff_eq_none
- **Type**: `{α : Type u_1} {o : Option α} : ¬o.isSome = true ↔ o = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 93. Option.eq_none_iff_forall_ne_some
- **Type**: `{α : Type u_1} {o : Option α} : o = none ↔ ∀ (a : α), o ≠ some a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 94. Option.eq_none_iff_forall_some_ne
- **Type**: `{α : Type u_1} {o : Option α} : o = none ↔ ∀ (a : α), some a ≠ o`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 95. Option.forall
- **Type**: `{α : Type u_1} {p : Option α → Prop} : (∀ (x : Option α), p x) ↔ p none ∧ ∀ (x : α), p (some x)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 96. Option.none_beq_some
- **Type**: `{α : Type u_1} [BEq α] (a : α) : (none == some a) = false`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 97. Option.some_beq_none
- **Type**: `{α : Type u_1} [BEq α] (a : α) : (some a == none) = false`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 98. Option.le.eq_1
- **Type**: `{α : Type u_1} {β : Type u_2} (r : α → β → Prop) (val : β) : Option.le r none (some val) = True`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 99. Option.le.eq_3
- **Type**: `{α : Type u_1} {β : Type u_2} (r : α → β → Prop) (val : α) : Option.le r (some val) none = False`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 100. Option.lt.eq_1
- **Type**: `{α : Type u_1} {β : Type u_2} (r : α → β → Prop) (val : β) : Option.lt r none (some val) = True`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 101. Option.beq_none
- **Type**: `{α : Type u_1} [BEq α] {o : Option α} : (o == none) = o.isNone`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 102. Option.get_none_eq_iff_true
- **Type**: `{α : Type u_1} {a : α} {h : none.isSome = true} : none.get h = a ↔ True`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 103. Option.guard_eq_none_iff
- **Type**: `{α : Type u_1} {p : α → Bool} {a : α} : Option.guard p a = none ↔ p a = false`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 104. Option.or_eq_left_of_none
- **Type**: `{α : Type u_1} {o o' : Option α} (h : o' = none) : o.or o' = o`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 105. Option.or_eq_right_of_none
- **Type**: `{α : Type u_1} {o o' : Option α} (h : o = none) : o.or o' = o'`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 106. Option.eq_none_iff_forall_not_mem
- **Type**: `{α : Type u_1} {o : Option α} : o = none ↔ ∀ (a : α), a ∉ o`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 107. Option.eq_none_or_eq_some
- **Type**: `{α : Type u_1} (a : Option α) : a = none ∨ ∃ x, a = some x`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 108. Option.filter_some_neg
- **Type**: `{α : Type u_1} {p : α → Bool} {a : α} (h : p a = false) : Option.filter p (some a) = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 109. Option.forall_ne_none
- **Type**: `{α : Type u_1} {p : Option α → Prop} : (∀ (x : Option α), x ≠ none → p x) ↔ ∀ (x : α), p (some x)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 110. Option.getD_of_ne_none
- **Type**: `{α : Type u_1} {x : Option α} (hx : x ≠ none) (y : α) : some (x.getD y) = x`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 111. Option.ne_none_iff_exists
- **Type**: `{α : Type u_1} {o : Option α} : o ≠ none ↔ ∃ x, some x = o`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 112. Option.ne_none_iff_exists'
- **Type**: `{α : Type u_1} {o : Option α} : o ≠ none ↔ ∃ x, o = some x`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 113. Option.le_none
- **Type**: `{α : Type u_1} [LE α] {a : Option α} : a ≤ none ↔ a = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 114. Option.none_lt
- **Type**: `{α : Type u_1} [LT α] {a : Option α} : none < a ↔ a.isSome = true`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 115. Option.pfilter_none
- **Type**: `{α : Type u_1} {p : (a : α) → none = some a → Bool} : none.pfilter p = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 116. Option.pfilter.eq_1
- **Type**: `{α : Type u_1} (p_2 : (a : α) → none = some a → Bool) : none.pfilter p_2 = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 117. Option.filter_some_eq_none
- **Type**: `{α : Type u_1} {p : α → Bool} {a : α} : Option.filter p (some a) = none ↔ ¬p a = true`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 118. Option.isSome_ite
- **Type**: `{α : Type u_1} {b : α} {p : Prop} {x : Decidable p} : (if p then some b else none).isSome = true ↔ p`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 119. Option.exists
- **Type**: `{α : Type u_1} {p : Option α → Prop} : (∃ x, p x) ↔ p none ∨ ∃ x, p (some x)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 120. Option.guard_beq_none
- **Type**: `{α : Type u_1} [BEq α] {x : α} {p : α → Bool} : (Option.guard p x == none) = !p x`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 121. Option.isSome_ite'
- **Type**: `{α : Type u_1} {b : α} {p : Prop} {x : Decidable p} : (if p then none else some b).isSome = true ↔ ¬p`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 122. Option.map_eq_none_iff
- **Type**: `{α : Type u_1} {x : Option α} {α' : Type u_2} {f : α → α'} : Option.map f x = none ↔ x = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 123. Option.pelim_none
- **Type**: `{α : Sort u_1} {b : α} {α' : Type u_2} {f : (a : α') → none = some a → α} : none.pelim b f = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 124. Option.pbind_none
- **Type**: `{α : Type u_1} {α' : Type u_2} {f : (a : α) → none = some a → Option α'} : none.pbind f = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 125. Option.exists_ne_none
- **Type**: `{α : Type u_1} {p : Option α → Prop} : (∃ x, x ≠ none ∧ p x) ↔ ∃ x, p (some x)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 126. Option.isSome_dite
- **Type**: `{β : Type u_1} {p : Prop} {x : Decidable p} {b : p → β} : (if h : p then some (b h) else none).isSome = true ↔ p`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 127. Option.join_ne_none
- **Type**: `{α : Type u_1} {x : Option (Option α)} : x.join ≠ none ↔ ∃ z, x = some (some z)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 128. Option.guard_apply
- **Type**: `{α : Type u_1} {p : α → Bool} {x : α} : Option.guard p x = if p x = true then some x else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 129. Option.guard_def
- **Type**: `{α : Type u_1} (p : α → Bool) : Option.guard p = fun x => if p x = true then some x else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 130. Option.guard_eq_ite
- **Type**: `{α : Type u_1} {p : α → Bool} {x : α} : Option.guard p x = if p x = true then some x else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 131. Option.isSome_eq_isSome
- **Type**: `{α : Type u_1} {x : Option α} {α' : Type u_2} {y : Option α'} : x.isSome = y.isSome ↔ (x = none ↔ y = none)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 132. Option.join_ne_none'
- **Type**: `{α : Type u_1} {x : Option (Option α)} : ¬x.join = none ↔ ∃ z, x = some (some z)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 133. Option.or_eq_none_iff
- **Type**: `{α : Type u_1} {o o' : Option α} : o.or o' = none ↔ o = none ∧ o' = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 134. Option.guard.eq_1
- **Type**: `{α : Type u_1} (p : α → Bool) (a : α) : Option.guard p a = if p a = true then some a else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 135. Option.filter_eq_none_iff
- **Type**: `{α : Type u_1} {o : Option α} {p : α → Bool} : Option.filter p o = none ↔ ∀ (a : α), o = some a → ¬p a = true`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 136. Option.isSome_dite'
- **Type**: `{β : Type u_1} {p : Prop} {x : Decidable p} {b : ¬p → β} : (if h : p then none else some (b h)).isSome = true ↔ ¬p`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 137. Option.ite_some_none_eq_some
- **Type**: `{α : Type u_1} {p : Prop} {x : Decidable p} {a b : α} : (if p then some a else none) = some b ↔ p ∧ a = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 138. Option.pelim_none'
- **Type**: `{α : Type u_1} {x : Option α} {α' : Sort u_2} {b : α'} {f : (a : α) → x = some a → α'} (h : x = none) : x.pelim b f = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 139. Option.filter_some
- **Type**: `{α : Type u_1} {p : α → Bool} {a : α} : Option.filter p (some a) = if p a = true then some a else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 140. Option.pbind_none'
- **Type**: `{α : Type u_1} {x : Option α} {α' : Type u_2} {f : (a : α) → x = some a → Option α'} (h : x = none) : x.pbind f = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 141. Option.filter.eq_1
- **Type**: `{α : Type u_1} (p : α → Bool) (val : α) : Option.filter p (some val) = if p val = true then some val else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 142. Option.ite_none_right_eq_some
- **Type**: `{α : Type u_1} {a : α} {p : Prop} {x : Decidable p} {b : Option α} : (if p then b else none) = some a ↔ p ∧ b = some a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 143. Option.some_eq_ite_none_right
- **Type**: `{α : Type u_1} {a : α} {p : Prop} {x : Decidable p} {b : Option α} : (some a = if p then b else none) ↔ p ∧ some a = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 144. Option.getD_eq_iff
- **Type**: `{α : Type u_1} {o : Option α} {a b : α} : o.getD a = b ↔ o = some b ∨ o = none ∧ a = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 145. Option.ite_none_left_eq_some
- **Type**: `{β : Type u_1} {a : β} {p : Prop} {x : Decidable p} {b : Option β} : (if p then none else b) = some a ↔ ¬p ∧ b = some a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 146. Option.join_eq_none_iff
- **Type**: `{α : Type u_1} {o : Option (Option α)} : o.join = none ↔ o = none ∨ o = some none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 147. Option.merge_eq_none_iff
- **Type**: `{α : Type u_1} {f : α → α → α} {o o' : Option α} : Option.merge f o o' = none ↔ o = none ∧ o' = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 148. Option.pmap_none
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → Prop} {f : (a : α) → p a → β} {h : ∀ (a : α), none = some a → p a} : Option.pmap f none h = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 149. Option.some_eq_ite_none_left
- **Type**: `{β : Type u_1} {a : β} {p : Prop} {x : Decidable p} {b : Option β} : (some a = if p then none else b) ↔ ¬p ∧ some a = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 150. Option.pmap.eq_1
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → Prop} (f : (a : α) → p a → β) (x_2 : ∀ (a : α), none = some a → p a) : Option.pmap f none x_2 = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 151. Option.bind_eq_none_iff
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {f : α → Option β} : o.bind f = none ↔ ∀ (a : α), o = some a → f a = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 152. Option.mem_ite_none_right
- **Type**: `{α : Type u_1} {p : Prop} {x : α} {x' : Decidable p} {l : Option α} : (x ∈ if p then l else none) ↔ p ∧ x ∈ l`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 153. Option.max_eq_none_iff
- **Type**: `{α : Type u_1} [Max α] {o o' : Option α} : o ⊔ o' = none ↔ o = none ∧ o' = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 154. Option.mem_ite_none_left
- **Type**: `{α : Type u_1} {p : Prop} {x : α} {x' : Decidable p} {l : Option α} : (x ∈ if p then none else l) ↔ ¬p ∧ x ∈ l`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 155. Option.min_eq_none_iff
- **Type**: `{α : Type u_1} [Min α] {o o' : Option α} : o ⊓ o' = none ↔ o = none ∨ o' = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 156. Option.bind_eq_none'
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {f : α → Option β} : o.bind f = none ↔ ∀ (b : β) (a : α), o = some a → f a ≠ some b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 157. Option.pfilter.eq_2
- **Type**: `{α : Type u_1} (a : α) (p_2 : (a_1 : α) → some a = some a_1 → Bool) : (some a).pfilter p_2 = bif p_2 a ⋯ then some a else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 158. Option.get_ite
- **Type**: `{α : Type u_1} {b : α} {p : Prop} {x : Decidable p} (h : (if p then some b else none).isSome = true) : (if p then some b else none).get h = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 159. Option.get_ite'
- **Type**: `{α : Type u_1} {b : α} {p : Prop} {x : Decidable p} (h : (if p then none else some b).isSome = true) : (if p then none else some b).get h = b`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 160. Option.map_guard
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → Bool} {f : α → β} {x : α} : Option.map f (Option.guard p x) = if p x = true then some (f x) else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 161. Option.map_if
- **Type**: `{α : Type u_1} {β : Type u_2} {c : Prop} {a : α} {f : α → β} {x : Decidable c} : Option.map f (if c then some a else none) = if c then some (f a) else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 162. Option.dite_none_right_eq_some
- **Type**: `{α : Type u_1} {a : α} {p : Prop} {x : Decidable p} {b : p → Option α} : (if h : p then b h else none) = some a ↔ ∃ (h : p), b h = some a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 163. Option.pmap_none'
- **Type**: `{α : Type u_1} {β : Type u_2} {x : Option α} {p : α → Prop} {f : (a : α) → p a → β} (he : x = none) {h : ∀ (a : α), x = some a → p a} : Option.pmap f x h = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 164. Option.some_eq_dite_none_right
- **Type**: `{α : Type u_1} {a : α} {p : Prop} {x : Decidable p} {b : p → Option α} : (some a = if h : p then b h else none) ↔ ∃ (h : p), some a = b h`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 165. Option.or_eq_some_iff
- **Type**: `{α : Type u_1} {o o' : Option α} {a : α} : o.or o' = some a ↔ o = some a ∨ o = none ∧ o' = some a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 166. Option.pmap_eq_none_iff
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {p : α → Prop} {f : (a : α) → p a → β} {h : ∀ (a : α), o = some a → p a} : Option.pmap f o h = none ↔ o = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 167. Option.mem_dite_none_right
- **Type**: `{α : Type u_1} {p : Prop} {x : α} {x' : Decidable p} {l : p → Option α} : (x ∈ if h : p then l h else none) ↔ ∃ (h : p), x ∈ l h`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 168. Option.dite_none_left_eq_some
- **Type**: `{β : Type u_1} {a : β} {p : Prop} {x : Decidable p} {b : ¬p → Option β} : (if h : p then none else b h) = some a ↔ ∃ (h : ¬p), b h = some a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 169. Option.some_eq_dite_none_left
- **Type**: `{β : Type u_1} {a : β} {p : Prop} {x : Decidable p} {b : ¬p → Option β} : (some a = if h : p then none else b h) ↔ ∃ (h : ¬p), some a = b h`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 170. Option.mem_dite_none_left
- **Type**: `{α : Type u_1} {p : Prop} {x : α} {x' : Decidable p} {l : ¬p → Option α} : (x ∈ if h : p then none else l h) ↔ ∃ (h : ¬p), x ∈ l h`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 171. Option.merge_beq_none
- **Type**: `{α : Type u_1} [BEq α] {o o' : Option α} {f : α → α → α} : (Option.merge f o o' == none) = (o == none && o' == none)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 172. Option.map_dif
- **Type**: `{α : Type u_1} {β : Type u_2} {c : Prop} {f : α → β} {x : Decidable c} {a : c → α} : Option.map f (if h : c then some (a h) else none) = if h : c then some (f (a h)) else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 173. Option.join_beq_none
- **Type**: `{α : Type u_1} [BEq α] {o : Option (Option α)} : (o.join == none) = (o == none || o == some none)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 174. Option.pfilter_eq_pbind_ite
- **Type**: `{α : Type u_1} {o : Option α} {p : (a : α) → o = some a → Bool} : o.pfilter p = o.pbind fun a h => if p a h = true then some a else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 175. Option.lt.eq_3
- **Type**: Complex equation for Option.lt
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 176. Option.get_dite
- **Type**: `{β : Type u_1} {p : Prop} {x : Decidable p} (b : p → β) (w : (if h : p then some (b h) else none).isSome = true) : (if h : p then some (b h) else none).get w = b ⋯`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 177. Option.pfilter_some
- **Type**: `{α : Type u_1} {x : α} {p : (a : α) → some x = some a → Bool} : (some x).pfilter p = if p x ⋯ = true then some x else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 178. Option.get_dite'
- **Type**: `{β : Type u_1} {p : Prop} {x : Decidable p} (b : ¬p → β) (w : (if h : p then none else some (b h)).isSome = true) : (if h : p then none else some (b h)).get w = b ⋯`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 179. Option.pfilter_eq_none_iff
- **Type**: `{α : Type u_1} {o : Option α} {p : (a : α) → o = some a → Bool} : o.pfilter p = none ↔ o = none ∨ ∃ a, ∃ (ha : o = some a), p a ha = false`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 180. Option.isNone_pbind_iff
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {f : (a : α) → o = some a → Option β} : (o.pbind f).isNone = true ↔ o = none ∨ ∃ a, ∃ (h : o = some a), f a h = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 181. Option.pbind_eq_none_iff
- **Type**: `{α : Type u_1} {β : Type u_2} {o : Option α} {f : (a : α) → o = some a → Option β} : o.pbind f = none ↔ o = none ∨ ∃ a, ∃ (h : o = some a), f a h = none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 182. Option.join_pfilter
- **Type**: `{α : Type u_1} {o : Option (Option α)} {p : (o' : Option α) → o = some o' → Bool} : (o.pfilter p).join = o.pbind fun o' ho' => if p o' ho' = true then o' else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 183. Option.pmap_guard
- **Type**: `{α : Type u_1} {β : Type u_2} {q : α → Bool} {p : α → Prop} (f : (x : α) → p x → β) {x : α} (h : ∀ (a : α), Option.guard q x = some a → p a) : Option.pmap f (Option.guard q x) h = if h' : q x = true then some (f x ⋯) else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 184. Option.merge_eq_some_iff
- **Type**: `{α : Type u_1} {o o' : Option α} {f : α → α → α} {a : α} : Option.merge f o o' = some a ↔ o = some a ∧ o' = none ∨ o = none ∧ o' = some a ∨ ∃ b c, o = some b ∧ o' = some c ∧ f b c = a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 185. Option.max_eq_some_iff
- **Type**: `{α : Type u_1} [Max α] {o o' : Option α} {a : α} : o ⊔ o' = some a ↔ o = some a ∧ o' = none ∨ o = none ∧ o' = some a ∨ ∃ b c, o = some b ∧ o' = some c ∧ b ⊔ c = a`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 186. Option.pfilter_guard
- **Type**: `{α : Type u_1} {a : α} {p : α → Bool} {q : (a' : α) → Option.guard p a = some a' → Bool} : (Option.guard p a).pfilter q = if ∃ (h : p a = true), q a ⋯ = true then some a else none`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 187. Option.pmap_or
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → Prop} {f : (a : α) → p a → β} {o o' : Option α} {h : ∀ (a : α), o.or o' = some a → p a} : Option.pmap f (o.or o') h = match o, h with | none, h => Option.pmap f o' ⋯ | some a, h => some (f a ⋯)`
- **Module**: `Init.Data.Option.Lemmas`
- **Library**: Init

### 188. List.findSome?.eq_1
- **Type**: `{α : Type u} {β : Type v} (f : α → Option β) : List.findSome? f [] = none`
- **Module**: `Init.Data.List.Control`
- **Library**: Init

### 189. List.findSomeM?_nil
- **Type**: `{m : Type u → Type u_1} [Monad m] {α : Type w} {β : Type u} {f : α → m (Option β)} : List.findSomeM? f [] = pure none`
- **Module**: `Init.Data.List.Control`
- **Library**: Init

### 190. List.findSome?.eq_def
- **Type**: Complex equation for List.findSome?
- **Module**: `Init.Data.List.Control`
- **Library**: Init

### 191. List.findM?_eq_findSomeM?
- **Type**: Complex equation relating findM? to findSomeM?
- **Module**: `Init.Data.List.Control`
- **Library**: Init

### 192. List.getLast?.eq_1
- **Type**: `{α : Type u} : [].getLast? = none`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

### 193. List.getLast?_eq_none_iff
- **Type**: `{α : Type u_1} {xs : List α} : xs.getLast? = none ↔ xs = []`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

### 194. List.head?_eq_none_iff
- **Type**: `{α : Type u_1} {l : List α} : l.head? = none ↔ l = []`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

### 195. List.filterMap_replicate_of_none
- **Type**: `{α : Type u_1} {β : Type u_2} {a : α} {n : ℕ} {f : α → Option β} (h : f a = none) : List.filterMap f (List.replicate n a) = []`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

### 196. List.getElem?_nil
- **Type**: `{α : Type u_1} {i : ℕ} : [][i]? = none`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

### 197. List.filterMap_cons_none
- **Type**: `{α : Type u_1} {β : Type u_2} {f : α → Option β} {a : α} {l : List α} (h : f a = none) : List.filterMap f (a :: l) = List.filterMap f l`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

### 198. List.forall_none_of_filterMap_eq_nil
- **Type**: `{α α' : Type} {f : α → Option α'} {xs : List α} (h : List.filterMap f xs = []) (x : α) : x ∈ xs → f x = none`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

### 199. List.filterMap_eq_nil_iff
- **Type**: `{α α' : Type} {f : α → Option α'} {l : List α} : List.filterMap f l = [] ↔ ∀ a ∈ l, f a = none`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

### 200. List.getLast?_replicate
- **Type**: `{α : Type u_1} {a : α} {n : ℕ} : (List.replicate n a).getLast? = if n = 0 then none else some a`
- **Module**: `Init.Data.List.Lemmas`
- **Library**: Init

---

## Note

This is the first 200 of 2524 total matches. All matches are from the Init library (LEAN's core standard library). To see more matches, additional Loogle queries would be needed, or you could search Mathlib separately for additional theorems about `Option.none`.

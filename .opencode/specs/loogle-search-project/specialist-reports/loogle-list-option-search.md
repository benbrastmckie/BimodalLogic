# Loogle Search Results: List _ → Option _

**Type Pattern**: `List _ → Option _`  
**Date**: 2025-12-20  
**Loogle API Revision**: 6ff4759  
**Mathlib Revision**: c98df61  
**Total Matches Found**: 63 exact pattern matches  
**Additional Related**: 57 two-parameter pattern matches  
**Total Declarations Mentioning List and Option**: 2,241

---

## Executive Summary

This search identified **63 core functions** matching the exact pattern `List _ → Option _`, representing functions that take a list and return an optional value. These functions span multiple libraries (Init, Std, Batteries, Mathlib, Lean compiler) and cover essential use cases:

- **Basic Access**: head?, tail?, getLast?, next?
- **Search/Query**: find?, findIdx?, idxOf?
- **Aggregation**: max?, min?, argmax, argmin
- **Association Lists**: lookup, dlookup, getValue?
- **Sublist Operations**: isPrefixOf?, dropPrefix?, findInfix?
- **Conversions**: allSome (List Option → Option List)

**Key Insight**: Lean 4 uses the `?` suffix convention for functions returning `Option`, making them easily identifiable.

---

## Exact Matches: List _ → Option _

### 1. PRIMARY ACCESS FUNCTIONS

#### **List.head?**
- **Type**: `{α : Type u} : List α → Option α`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns the first element of a list, or `none` if the list is empty
- **Usage**: `[1, 2, 3].head? = some 1`, `[].head? = none`

#### **List.getLast?**
- **Type**: `{α : Type u} : List α → Option α`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns the last element of a list, or `none` if the list is empty
- **Usage**: `[1, 2, 3].getLast? = some 3`, `[].getLast? = none`

#### **List.tail?**
- **Type**: `{α : Type u} : List α → Option (List α)`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns the tail (all elements except the first), or `none` if the list is empty
- **Usage**: `[1, 2, 3].tail? = some [2, 3]`, `[].tail? = none`

---

### 2. SEARCH AND FIND FUNCTIONS

#### **List.find?**
- **Type**: `{α : Type u} (p : α → Bool) : List α → Option α`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Finds the first element satisfying the predicate `p`
- **Usage**: `[1, 2, 3, 4].find? (· > 2) = some 3`

#### **List.findRev?**
- **Type**: `{α : Type u} (p : α → Bool) : List α → Option α`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Finds the first element satisfying the predicate, searching from the end
- **Usage**: `[1, 2, 3, 4].findRev? (· > 2) = some 4`

#### **List.findSome?**
- **Type**: `{α : Type u} {β : Type v} (f : α → Option β) : List α → Option β`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Applies function `f` to each element, returns the first `some` result
- **Usage**: Maps and finds in one operation

#### **List.findSomeRev?**
- **Type**: `{α : Type u} {β : Type v} (f : α → Option β) : List α → Option β`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Like `findSome?` but searches from the end of the list

---

### 3. INDEX FUNCTIONS

#### **List.findIdx?**
- **Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option ℕ`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns the index of the first element satisfying predicate `p`
- **Usage**: `[1, 2, 3, 4].findIdx? (· > 2) = some 2`

#### **List.findFinIdx?**
- **Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option (Fin l.length)`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns a bounded index (Fin) of the first matching element
- **Usage**: Type-safe indexing with proof that index is within bounds

#### **List.idxOf?**
- **Type**: `{α : Type u} [BEq α] (a : α) : List α → Option ℕ`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns the index of the first occurrence of element `a`
- **Usage**: `[1, 2, 3, 2].idxOf? 2 = some 1`

#### **List.finIdxOf?**
- **Type**: `{α : Type u} [BEq α] (a : α) (l : List α) : Option (Fin l.length)`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns a bounded index of the first occurrence of element `a`

#### **List.findIdx?.go**
- **Type**: `{α : Type u} (p : α → Bool) : List α → ℕ → Option ℕ`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Helper function for `findIdx?` implementation

#### **List.findFinIdx?.go**
- **Type**: `{α : Type u} (p : α → Bool) (l l' : List α) (i : ℕ) (h : l'.length + i = l.length) : Option (Fin l.length)`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Helper function for `findFinIdx?` implementation

---

### 4. MIN/MAX FUNCTIONS

#### **List.max?**
- **Type**: `{α : Type u} [Max α] : List α → Option α`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns the maximum element of the list (if any)
- **Usage**: `[1, 3, 2].max? = some 3`, `[].max? = none`

#### **List.min?**
- **Type**: `{α : Type u} [Min α] : List α → Option α`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Returns the minimum element of the list (if any)
- **Usage**: `[1, 3, 2].min? = some 1`, `[].min? = none`

---

### 5. PREFIX/SUFFIX FUNCTIONS

#### **List.isPrefixOf?**
- **Type**: `{α : Type u} [BEq α] (l₁ l₂ : List α) : Option (List α)`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Checks if `l₁` is a prefix of `l₂`, returns the remainder if true
- **Usage**: `[1, 2].isPrefixOf? [1, 2, 3, 4] = some [3, 4]`

#### **List.isSuffixOf?**
- **Type**: `{α : Type u} [BEq α] (l₁ l₂ : List α) : Option (List α)`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Checks if `l₁` is a suffix of `l₂`, returns the remainder if true
- **Usage**: `[3, 4].isSuffixOf? [1, 2, 3, 4] = some [1, 2]`

---

### 6. LOOKUP FUNCTIONS

#### **List.lookup**
- **Type**: `{α : Type u} {β : Type v} [BEq α] : α → List (α × β) → Option β`
- **Library**: Init.Data.List.Basic
- **Module**: Init.Data.List.Basic
- **Description**: Looks up a value by key in an association list
- **Usage**: `[(1, "a"), (2, "b")].lookup 2 = some "b"`

#### **List.get?Internal**
- **Type**: `{α : Type u_1} (as : List α) (i : ℕ) : Option α`
- **Library**: Init.GetElem
- **Module**: Init.GetElem
- **Description**: Internal function for safe list indexing (powers `list[i]?` syntax)
- **Usage**: `[1, 2, 3][1]? = some 2`, `[1, 2, 3][5]? = none`

---

### 7. TAIL RECURSION OPTIMIZED VERSIONS

#### **List.findRev?TR**
- **Type**: `{α : Type u_1} (p : α → Bool) (l : List α) : Option α`
- **Library**: Init.Data.List.Impl
- **Module**: Init.Data.List.Impl
- **Description**: Tail-recursive version of `findRev?` for better performance

#### **List.findSomeRev?TR**
- **Type**: `{α : Type u_1} {β : Type u_2} (f : α → Option β) (l : List α) : Option β`
- **Library**: Init.Data.List.Impl
- **Module**: Init.Data.List.Impl
- **Description**: Tail-recursive version of `findSomeRev?` for better performance

---

### 8. EQUIVALENCE THEOREMS

#### **List.findRev?_eq_findRev?TR**
- **Type**: `@List.findRev? = @List.findRev?TR`
- **Library**: Init.Data.List.Impl
- **Module**: Init.Data.List.Impl
- **Description**: Proves equivalence between standard and tail-recursive versions

#### **List.findSomeRev?_eq_findSomeRev?TR**
- **Type**: `@List.findSomeRev? = @List.findSomeRev?TR`
- **Library**: Init.Data.List.Impl
- **Module**: Init.Data.List.Impl
- **Description**: Proves equivalence between standard and tail-recursive versions

---

### 9. DEFINITION THEOREMS

#### **List.idxOf?.eq_1**
- **Type**: `{α : Type u} [BEq α] (a : α) : List.idxOf? a = List.findIdx? fun x => x == a`
- **Library**: Init.Data.List.Find
- **Module**: Init.Data.List.Find
- **Description**: Defines `idxOf?` in terms of `findIdx?`

#### **List.finIdxOf?.eq_1**
- **Type**: `{α : Type u} [BEq α] (a : α) : List.finIdxOf? a = List.findFinIdx? fun x => x == a`
- **Library**: Init.Data.List.Find
- **Module**: Init.Data.List.Find
- **Description**: Defines `finIdxOf?` in terms of `findFinIdx?`

---

### 10. STRING FUNCTIONS

#### **String.utf8GetAux?**
- **Type**: `List Char → String.Pos.Raw → String.Pos.Raw → Option Char`
- **Library**: Init.Data.String.Basic
- **Module**: Init.Data.String.Basic
- **Description**: UTF8 character access helper function

#### **String.Pos.Raw.utf8GetAux?**
- **Type**: `List Char → String.Pos.Raw → String.Pos.Raw → Option Char`
- **Library**: Init.Data.String.Basic
- **Module**: Init.Data.String.Basic
- **Description**: UTF8 character access helper (raw position variant)

---

### 11. STANDARD LIBRARY INTERNAL FUNCTIONS

#### **Std.Internal.List.getValue?**
- **Type**: `{α : Type u} {β : Type v} [BEq α] (a : α) : List ((α) × β) → Option β`
- **Library**: Std
- **Module**: Std.Data.Internal.List.Associative
- **Description**: Gets value from dependent pair list

#### **Std.Internal.List.maxKey?**
- **Type**: `{α : Type u} {β : α → Type v} [Ord α] (xs : List ((a : α) × β a)) : Option α`
- **Library**: Std
- **Module**: Std.Data.Internal.List.Associative
- **Description**: Returns the maximum key from a dependent pair list

#### **Std.Internal.List.minKey?**
- **Type**: `{α : Type u} {β : α → Type v} [Ord α] (xs : List ((a : α) × β a)) : Option α`
- **Library**: Std
- **Module**: Std.Data.Internal.List.Associative
- **Description**: Returns the minimum key from a dependent pair list

#### **Std.Internal.List.getKey?**
- **Type**: `{α : Type u} {β : α → Type v} [BEq α] (a : α) : List ((a : α) × β a) → Option α`
- **Library**: Std
- **Module**: Std.Data.Internal.List.Associative
- **Description**: Gets key from dependent pair list

#### **Std.Internal.List.minEntry?**
- **Type**: `{α : Type u} {β : α → Type v} [Ord α] (xs : List ((a : α) × β a)) : Option ((a : α) × β a)`
- **Library**: Std
- **Module**: Std.Data.Internal.List.Associative
- **Description**: Returns the entry with the minimum key

#### **Std.Internal.List.getEntry?**
- **Type**: `{α : Type u} {β : α → Type v} [BEq α] (a : α) : List ((a : α) × β a) → Option ((a : α) × β a)`
- **Library**: Std
- **Module**: Std.Data.Internal.List.Associative
- **Description**: Gets entry by key from dependent pair list

#### **Std.Internal.List.getValueCast?**
- **Type**: `{α : Type u} {β : α → Type v} [BEq α] [LawfulBEq α] (a : α) : List ((a : α) × β a) → Option (β a)`
- **Library**: Std
- **Module**: Std.Data.Internal.List.Associative
- **Description**: Gets value with type cast from dependent pair list

---

### 12. LEAN COMPILER/METAPROGRAMMING FUNCTIONS

#### **Lean.KVMap.findCore**
- **Type**: `List (Lean.Name × Lean.DataValue) → Lean.Name → Option Lean.DataValue`
- **Library**: Lean
- **Module**: Lean.Data.KVMap
- **Description**: Key-value map lookup in Lean's internal data structures

#### **Lean.PrefixTree.find?**
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → α → Ordering} (t : Lean.PrefixTree α β p) (k : List α) : Option β`
- **Library**: Lean
- **Module**: Lean.Data.PrefixTree
- **Description**: Prefix tree lookup by key list

#### **Lean.PrefixTree.findLongestPrefix?**
- **Type**: `{α : Type u_1} {β : Type u_2} {p : α → α → Ordering} (t : Lean.PrefixTree α β p) (k : List α) : Option β`
- **Library**: Lean
- **Module**: Lean.Data.PrefixTree
- **Description**: Finds value for the longest matching prefix in a prefix tree

#### **Lean.PrefixTreeNode.find?**
- **Type**: `{α : Type u_1} {β : Type u_2} (cmp : α → α → Ordering) (t : Lean.PrefixTreeNode α β cmp) (k : List α) : Option β`
- **Library**: Lean
- **Module**: Lean.Data.PrefixTree
- **Description**: Prefix tree node lookup

#### **Lean.PrefixTreeNode.findLongestPrefix?**
- **Type**: `{α : Type u_1} {β : Type u_2} (cmp : α → α → Ordering) (t : Lean.PrefixTreeNode α β cmp) (k : List α) : Option β`
- **Library**: Lean
- **Module**: Lean.Data.PrefixTree
- **Description**: Finds longest prefix in a prefix tree node

#### **Lean.Level.getParamSubst**
- **Type**: `List Lean.Name → List Lean.Level → Lean.Name → Option Lean.Level`
- **Library**: Lean
- **Module**: Lean.Level
- **Description**: Gets parameter substitution for universe levels

#### **Lean.getExternEntryForAux**
- **Type**: `(backend : Lean.Name) (entries : List Lean.ExternEntry) : Option Lean.ExternEntry`
- **Library**: Lean
- **Module**: Lean.Compiler.ExternAttr
- **Description**: Gets external entry for a specific backend

#### **Lean.Elab.Term.MatchExpr.getAltFor?**
- **Type**: `(alts : List Lean.Elab.Term.MatchExpr.Alt) (funName : Lean.Ident) : Option Lean.Elab.Term.MatchExpr.Alt`
- **Library**: Lean
- **Module**: Lean.Elab.MatchExpr
- **Description**: Gets match alternative for a function name

#### **Batteries.Linter.UnnecessarySeqFocus.getPath**
- **Type**: `Lean.Elab.Info → Lean.PersistentArray Lean.Elab.InfoTree → List ((n : ℕ) × Fin n) → Option Lean.Elab.Info`
- **Library**: Batteries
- **Module**: Batteries.Linter.UnnecessarySeqFocus
- **Description**: Linter helper for getting elaboration info path

---

### 13. BATTERIES LIBRARY FUNCTIONS

#### **List.allSome**
- **Type**: `{α : Type u_1} (l : List (Option α)) : Option (List α)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Basic
- **Description**: Converts `List (Option α)` to `Option (List α)`, returns `some` only if all elements are `some`
- **Usage**: `[some 1, some 2, some 3].allSome = some [1, 2, 3]`, `[some 1, none, some 3].allSome = none`

#### **List.next?**
- **Type**: `{α : Type u_1} : List α → Option (α × List α)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Basic
- **Description**: Returns head and tail as a pair, or `none` if the list is empty
- **Usage**: `[1, 2, 3].next? = some (1, [2, 3])`, `[].next? = none`

#### **List.dropPrefix?**
- **Type**: `{α : Type u_1} [BEq α] : List α → List α → Option (List α)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Basic
- **Description**: Drops prefix from list if it matches, returns remainder
- **Usage**: `[1, 2, 3, 4].dropPrefix? [1, 2] = some [3, 4]`

#### **List.dropSuffix?**
- **Type**: `{α : Type u_1} [BEq α] (l s : List α) : Option (List α)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Basic
- **Description**: Drops suffix from list if it matches, returns remainder
- **Usage**: `[1, 2, 3, 4].dropSuffix? [3, 4] = some [1, 2]`

#### **List.getRest**
- **Type**: `{α : Type u_1} [DecidableEq α] : List α → List α → Option (List α)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Basic
- **Description**: Gets remainder after matching prefix

#### **List.dropInfix?**
- **Type**: `{α : Type u_1} [BEq α] (l i : List α) : Option (List α × List α)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Basic
- **Description**: Drops infix from list, returns prefix and suffix as a pair
- **Usage**: `[1, 2, 3, 4, 5].dropInfix? [3] = some ([1, 2], [4, 5])`

#### **List.dropInfix?.go**
- **Type**: `{α : Type u_1} [BEq α] (i : List α) : List α → List α → Option (List α × List α)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Basic
- **Description**: Helper function for `dropInfix?` implementation

---

### 14. LIST PATTERN MATCHING

#### **List.findInfix?**
- **Type**: `{α : Type u_1} [BEq α] (l pattern : List α) : Option (ℕ × ℕ)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Matcher
- **Description**: Finds infix pattern in list, returns start and end indices
- **Usage**: `[1, 2, 3, 4, 5].findInfix? [3, 4] = some (2, 4)`

#### **List.Matcher.find?**
- **Type**: `{α : Type u_1} [BEq α] (m : List.Matcher α) (l : List α) : Option (ℕ × ℕ)`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Matcher
- **Description**: Pattern matcher find function using compiled matcher

---

### 15. LEAN AC TACTIC SUPPORT

#### **Lean.Grind.AC.toSeq?**
- **Type**: `(xs : List Lean.Grind.AC.Var) : Option Lean.Grind.AC.Seq`
- **Library**: Lean
- **Module**: Lean.Meta.Tactic.Grind.AC.Seq
- **Description**: Converts variable list to AC (associative-commutative) sequence for the grind tactic

---

### 16. MATHLIB FUNCTIONS

#### **List.argmax**
- **Type**: `{α : Type u_1} {β : Type u_2} [Preorder β] [DecidableLT β] (f : α → β) (l : List α) : Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Data.List.MinMax
- **Description**: Returns the element that maximizes function `f`
- **Usage**: `[1, 2, 3, 4].argmax (fun x => -x) = some 1` (element with max value of -x)

#### **List.argmin**
- **Type**: `{α : Type u_1} {β : Type u_2} [Preorder β] [DecidableLT β] (f : α → β) (l : List α) : Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Data.List.MinMax
- **Description**: Returns the element that minimizes function `f`
- **Usage**: `[1, 2, 3, 4].argmin id = some 1`

---

### 17. COMPUTABILITY THEORY

#### **Primrec.nat_strong_rec**
- **Type**: `{α : Type u_1} {σ : Type u_4} [Primcodable α] [Primcodable σ] (f : α → ℕ → σ) {g : α → List σ → Option σ} (hg : Primrec₂ g) (H : ∀ (a : α) (n : ℕ), g a (List.map (f a) (List.range n)) = some (f a n)) : Primrec₂ f`
- **Library**: Mathlib
- **Module**: Mathlib.Computability.Primrec
- **Description**: Strong recursion principle for primitive recursive functions

#### **Primrec.nat_omega_rec'**
- **Type**: `{β : Type u_2} {σ : Type u_4} [Primcodable β] [Primcodable σ] (f : β → σ) {m : β → ℕ} {l : β → List β} {g : β → List σ → Option σ} (hm : Primrec m) (hl : Primrec l) (hg : Primrec₂ g) (Ord : ∀ (b b' : β), b' ∈ l b → m b' < m b) (H : ∀ (b : β), g b (List.map f (l b)) = some (f b)) : Primrec f`
- **Library**: Mathlib
- **Module**: Mathlib.Computability.Primrec
- **Description**: Omega recursion principle for primitive recursive functions

#### **Computable.nat_strong_rec**
- **Type**: `{α : Type u_1} {σ : Type u_4} [Primcodable α] [Primcodable σ] (f : α → ℕ → σ) {g : α → List σ → Option σ} (hg : Computable₂ g) (H : ∀ (a : α) (n : ℕ), g a (List.map (f a) (List.range n)) = some (f a n)) : Computable₂ f`
- **Library**: Mathlib
- **Module**: Mathlib.Computability.Partrec
- **Description**: Strong recursion principle for computable functions

#### **Computability.Encoding.decode**
- **Type**: `{α : Type u} (self : Computability.Encoding α) : List self.Γ → Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Computability.Encoding
- **Description**: Decodes a list of symbols to a value

#### **Computability.Encoding.mk**
- **Type**: `{α : Type u} (Γ : Type v) (encode : α → List Γ) (decode : List Γ → Option α) (decode_encode : ∀ (x : α), decode (encode x) = some x) : Computability.Encoding α`
- **Library**: Mathlib
- **Module**: Mathlib.Computability.Encoding
- **Description**: Constructor for encoding structures

---

### 18. SIGMA TYPES

#### **List.dlookup**
- **Type**: `{α : Type u} {β : α → Type v} [DecidableEq α] (a : α) : List (Sigma β) → Option (β a)`
- **Library**: Mathlib
- **Module**: Mathlib.Data.List.Sigma
- **Description**: Dependent lookup in sigma type list (dependent pair list)
- **Usage**: Looks up value with dependent type based on key

---

## Categorization by Use Case

### **Basic Access Functions**
- `List.head?` - First element
- `List.getLast?` - Last element
- `List.tail?` - All but first element
- `List.next?` - Head and tail as pair
- `list[i]?` - Element at index (via `List.get?Internal`)

### **Search and Query Functions**
- `List.find?` - First element matching predicate
- `List.findRev?` - First element matching predicate (from end)
- `List.findSome?` - First `some` result from mapping
- `List.findSomeRev?` - First `some` result (from end)

### **Index Functions**
- `List.findIdx?` - Index of first match
- `List.findFinIdx?` - Bounded index of first match
- `List.idxOf?` - Index of element
- `List.finIdxOf?` - Bounded index of element
- `List.findInfix?` - Start/end indices of infix pattern

### **Aggregation Functions**
- `List.max?` - Maximum element
- `List.min?` - Minimum element
- `List.argmax` - Element maximizing function
- `List.argmin` - Element minimizing function

### **Association List / Lookup Functions**
- `List.lookup` - Key-value lookup
- `List.dlookup` - Dependent key-value lookup
- `Std.Internal.List.getValue?` - Get value from dependent pairs
- `Std.Internal.List.getKey?` - Get key from dependent pairs
- `Std.Internal.List.getEntry?` - Get entry from dependent pairs
- `Std.Internal.List.maxKey?` - Maximum key
- `Std.Internal.List.minKey?` - Minimum key
- `Std.Internal.List.minEntry?` - Entry with minimum key

### **Sublist Operations**
- `List.isPrefixOf?` - Check prefix, return remainder
- `List.isSuffixOf?` - Check suffix, return remainder
- `List.dropPrefix?` - Drop matching prefix
- `List.dropSuffix?` - Drop matching suffix
- `List.dropInfix?` - Drop matching infix, return prefix and suffix
- `List.getRest` - Get remainder after prefix

### **List Conversion Functions**
- `List.allSome` - Convert `List (Option α)` to `Option (List α)`

### **Compiler/Metaprogramming Functions**
- `Lean.KVMap.findCore` - Key-value map lookup
- `Lean.PrefixTree.find?` - Prefix tree lookup
- `Lean.PrefixTree.findLongestPrefix?` - Longest prefix lookup
- `Lean.Level.getParamSubst` - Universe level substitution
- `Lean.getExternEntryForAux` - External entry lookup
- `Lean.Elab.Term.MatchExpr.getAltFor?` - Match alternative lookup

### **Computability Theory Functions**
- `Primrec.nat_strong_rec` - Strong recursion for primitive recursive functions
- `Primrec.nat_omega_rec'` - Omega recursion for primitive recursive functions
- `Computable.nat_strong_rec` - Strong recursion for computable functions
- `Computability.Encoding.decode` - Decode symbol list to value

---

## Key Insights and Patterns

### 1. **Naming Convention**
Functions returning `Option` consistently use the `?` suffix in Lean 4. This makes them immediately recognizable and distinguishes them from their total counterparts.

### 2. **Modern Indexing**
The preferred modern approach for list indexing is `list[i]?` which uses `List.get?Internal`. This is more ergonomic than older lookup methods.

### 3. **Tail Recursion Optimization**
Several functions have tail-recursive variants (e.g., `findRev?TR`, `findSomeRev?TR`) with equivalence proofs, showing Lean's commitment to both clarity and performance.

### 4. **Type Safety**
Functions like `findFinIdx?` and `finIdxOf?` return `Fin n` instead of `ℕ`, providing compile-time guarantees that indices are within bounds.

### 5. **Rich Theorem Library**
While this report focuses on functions, Loogle found 2,241 total declarations mentioning List and Option, indicating a vast ecosystem of supporting theorems and lemmas.

### 6. **Library Distribution**
- **Init**: Core functions (head?, find?, lookup, etc.)
- **Std**: Internal data structure support (dependent pairs, etc.)
- **Batteries**: Extended utilities (allSome, dropPrefix?, pattern matching)
- **Mathlib**: Mathematical/computational theory (argmax, dlookup, encoding)
- **Lean**: Compiler and metaprogramming support

### 7. **Common Patterns**
Most functions follow these patterns:
- Take a predicate (`α → Bool`) or equality constraint (`[BEq α]`)
- Return `none` for empty lists or failed searches
- Return `some value` for successful operations
- Have both forward and reverse variants for search operations

---

## Recommendations

### **For Basic List Operations**
Use the standard Init functions:
- `list.head?` for first element
- `list.getLast?` for last element
- `list[i]?` for indexed access
- `list.find? p` for searching

### **For Association Lists**
Use `List.lookup` for simple key-value pairs, or `List.dlookup` for dependent types.

### **For Pattern Matching**
Use Batteries functions:
- `List.findInfix?` for finding patterns
- `List.dropPrefix?` / `List.dropSuffix?` for removing known affixes

### **For Type Safety**
Prefer `Fin`-returning variants (`findFinIdx?`, `finIdxOf?`) when you need compile-time index bounds guarantees.

### **For Performance**
The tail-recursive variants (`findRev?TR`, `findSomeRev?TR`) are automatically used via equivalence theorems, so you can use the standard names without performance concerns.

---

## Related Searches

To explore related patterns, consider these Loogle searches:
- `List _ → List _` - List transformations
- `List _ → Bool` - List predicates
- `List _ → Nat` - List measurements (length, count, etc.)
- `Option _ → Option _` - Option transformations
- `_ → List _ → Option _` - Two-parameter search functions

---

## Conclusion

This search revealed a comprehensive ecosystem of 63 functions matching the `List _ → Option _` pattern, covering all common use cases for optional list operations. The consistent `?` naming convention, rich type safety features, and extensive theorem support make these functions both easy to discover and safe to use.

The distribution across Init, Std, Batteries, and Mathlib shows a well-organized library structure, with core operations in Init and increasingly specialized functions in higher-level libraries.

For the ProofChecker project, these functions provide robust building blocks for any list-based operations that may fail or return optional results, with strong theoretical foundations and extensive proof support.

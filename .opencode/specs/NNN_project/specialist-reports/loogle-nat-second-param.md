# Loogle Search Results: Nat as Second Parameter

**Type Pattern**: `_ → Nat → _ → Option _`
**Search Date**: Sun Dec 21 2025
**Total Matches**: 75
**Search URL**: https://loogle.lean-lang.org/?q=_%20%E2%86%92%20Nat%20%E2%86%92%20_%20%E2%86%92%20Option%20_

## Executive Summary

This search identified 75 functions in the Lean 4 ecosystem that match the pattern `_ → Nat → _ → Option _`, where `Nat` appears as the **second parameter**. This pattern is commonly used for:

1. **Index-based lookups**: Accessing the nth element of a collection
2. **Bounded searches**: Finding elements within a range specified by the Nat parameter
3. **Iterator access**: Getting the nth value from an iterator or sequence
4. **Encoding/Decoding**: Converting natural numbers to optional values
5. **Tree/Map indexing**: Finding the nth smallest key in ordered structures

Unlike the more common `Nat → _ → Option _` pattern (where Nat is the first parameter, typically for fuel-limited recursion), this pattern places Nat in the second position, suggesting it serves as an **index** or **position** rather than a **fuel/depth limit**.

## Category Analysis

### 1. Collection Indexing (List, Array, Vector) - 19 matches

These functions retrieve the nth element of a collection:

#### **List.get?Internal** : `{α : Type u_1} (as : List α) (i : ℕ) : Option α`
- **Library**: Init (Lean Core)
- **Module**: Init.GetElem
- **Description**: Internal implementation of `as[i]?`. Do not use directly.
- **Use Case**: Safe indexed access to list elements

#### **Array.findIdx?.loop** : `{α : Type u} (p : α → Bool) (as : Array α) (j : ℕ) : Option ℕ`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.Array.Basic
- **Use Case**: Loop helper for finding index of element satisfying predicate

#### **Array.idxOfAux** : `{α : Type u} [BEq α] (xs : Array α) (v : α) (i : ℕ) : Option (Fin xs.size)`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.Array.Basic
- **Use Case**: Auxiliary function for finding index of value with starting position

#### **Array.max?** : `{α : Type u_1} [ord : Ord α] (xs : Array α) (start : ℕ := 0) (stop : ℕ := xs.size) : Option α`
- **Library**: Batteries
- **Module**: Batteries.Data.Array.Basic
- **Description**: Find the first maximal element of an array. If the array is empty, `none` is returned. If `start` and `stop` are given, only the subarray `xs[start:stop]` is considered.
- **Use Case**: Finding maximum in a range

#### **Array.min?** : `{α : Type u_1} [ord : Ord α] (xs : Array α) (start : ℕ := 0) (stop : ℕ := xs.size) : Option α`
- **Library**: Batteries
- **Module**: Batteries.Data.Array.Basic
- **Description**: Find the first minimal element of an array. If the array is empty, `none` is returned. If `start` and `stop` are given, only the subarray `xs[start:stop]` is considered.
- **Use Case**: Finding minimum in a range

#### **Array.binSearch** : `{α : Type} (as : Array α) (k : α) (lt : α → α → Bool) (lo : ℕ := 0) (hi : ℕ := as.size - 1) : Option α`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.Array.BinSearch
- **Description**: Binary search for an element equivalent to `k` in the sorted array `as`. Returns the element from the array, if it is found, or `none` otherwise.
- **Use Case**: Efficient searching with index bounds

#### **List.findIdx?.go** : `{α : Type u} (p : α → Bool) : List α → ℕ → Option ℕ`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.List.Basic
- **Use Case**: Find index of element satisfying predicate with accumulator

#### **List.findFinIdx?.go** : `{α : Type u} (p : α → Bool) (l l' : List α) (i : ℕ) (h : l'.length + i = l.length) : Option (Fin l.length)`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.List.Basic
- **Use Case**: Find index with proof of validity

#### **List.ofFnNthVal** : `{α : Type u_1} {n : ℕ} (f : Fin n → α) (i : ℕ) : Option α`
- **Library**: Batteries
- **Module**: Batteries.Data.List.Basic
- **Description**: `ofFnNthVal f i` returns `some (f i)` if `i < n` and `none` otherwise.
- **Use Case**: Safe function application with bounds checking

#### **Vector.back?** : `{α : Type u_1} {n : ℕ} (xs : Vector α n) : Option α`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.Vector.Basic
- **Description**: The last element of a vector, or `none` if the vector is empty.
- **Use Case**: Getting last element safely

#### **Vector.findFinIdx?** : `{α : Type u_1} {n : ℕ} (p : α → Bool) (xs : Vector α n) : Option (Fin n)`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.Vector.Basic
- **Description**: Finds the first index of a given value in a vector using a predicate. Returns `none` if no element matches.
- **Use Case**: Finding element with proof of validity

#### **Vector.finIdxOf?** : `{α : Type u_1} {n : ℕ} [BEq α] (xs : Vector α n) (x : α) : Option (Fin n)`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.Vector.Basic
- **Description**: Finds the first index of a given value in a vector using `==` for comparison. Returns `none` if no element matches.
- **Use Case**: Finding element by equality

#### **Vector.findSome?** : `{α : Type u_1} {β : Type u_2} {n : ℕ} (f : α → Option β) (as : Vector α n) : Option β`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.Vector.Basic
- **Use Case**: Finding first successful mapping

#### **Vector.findSomeRev?** : `{α : Type u_1} {β : Type u_2} {n : ℕ} (f : α → Option β) (as : Vector α n) : Option β`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.Vector.Basic
- **Use Case**: Finding first successful mapping in reverse

#### **ByteArray.findIdx?.loop** : `(a : ByteArray) (p : UInt8 → Bool) (i : ℕ) : Option ℕ`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.ByteArray.Basic
- **Use Case**: Loop for finding byte index

#### **ByteArray.findFinIdx?.loop** : `(a : ByteArray) (p : UInt8 → Bool) (i : ℕ) : Option (Fin a.size)`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.ByteArray.Basic
- **Use Case**: Loop for finding byte index with proof

#### **ByteArray.findIdx?** : `(a : ByteArray) (p : UInt8 → Bool) (start : ℕ := 0) : Option ℕ`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.ByteArray.Basic
- **Description**: Finds the index of the first byte in `a` for which `p` returns `true`. If no byte in `a` satisfies `p`, then the result is `none`.
- **Use Case**: Finding byte with starting position

#### **ByteArray.findFinIdx?** : `(a : ByteArray) (p : UInt8 → Bool) (start : ℕ := 0) : Option (Fin a.size)`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.ByteArray.Basic
- **Description**: Finds the index of the first byte in `a` for which `p` returns `true`. The index is returned along with a proof that it is a valid index in the array.
- **Use Case**: Finding byte with proof of validity

#### **ByteArray.utf8Decode?.go** : `(b : ByteArray) (i : ℕ) (acc : Array Char) (hi : i ≤ b.size) : Option (Array Char)`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.String.Basic
- **Use Case**: UTF-8 decoding with position tracking

### 2. Tree/Map Ordered Access - 20 matches

These functions access the nth smallest element in ordered tree structures:

#### **Std.TreeMap.keyAtIdx?** : `{α : Type u} {β : Type v} {cmp : α → α → Ordering} (t : Std.TreeMap α β cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.TreeMap.Basic
- **Description**: Returns the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Ordered access to tree map keys

#### **Std.TreeMap.entryAtIdx?** : `{α : Type u} {β : Type v} {cmp : α → α → Ordering} (t : Std.TreeMap α β cmp) (n : ℕ) : Option (α × β)`
- **Library**: Std
- **Module**: Std.Data.TreeMap.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Ordered access to tree map entries

#### **Std.TreeMap.Raw.keyAtIdx?** : `{α : Type u} {β : Type v} {cmp : α → α → Ordering} (t : Std.TreeMap.Raw α β cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.TreeMap.Raw.Basic
- **Description**: Returns the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Raw tree map key access

#### **Std.TreeMap.Raw.entryAtIdx?** : `{α : Type u} {β : Type v} {cmp : α → α → Ordering} (t : Std.TreeMap.Raw α β cmp) (n : ℕ) : Option (α × β)`
- **Library**: Std
- **Module**: Std.Data.TreeMap.Raw.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Raw tree map entry access

#### **Std.TreeSet.atIdx?** : `{α : Type u} {cmp : α → α → Ordering} (t : Std.TreeSet α cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.TreeSet.Basic
- **Description**: Returns the `n`-th smallest element, or `none` if `n` is at least `t.size`.
- **Use Case**: Ordered access to tree set elements

#### **Std.TreeSet.Raw.atIdx?** : `{α : Type u} {cmp : α → α → Ordering} (t : Std.TreeSet.Raw α cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.TreeSet.Raw.Basic
- **Description**: Returns the `n`-th smallest element, or `none` if `n` is at least `t.size`.
- **Use Case**: Raw tree set element access

#### **Std.DTreeMap.keyAtIdx?** : `{α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Basic
- **Description**: Returns the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Dependent tree map key access

#### **Std.DTreeMap.entryAtIdx?** : `{α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap α β cmp) (n : ℕ) : Option ((a : α) × β a)`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Dependent tree map entry access

#### **Std.DTreeMap.Const.entryAtIdx?** : `{α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap α (fun x => β) cmp) (n : ℕ) : Option (α × β)`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Constant dependent tree map entry access

#### **Std.DTreeMap.Internal.Impl.keyAtIdx?** : `{α : Type u} {β : α → Type v} : Std.DTreeMap.Internal.Impl α β → ℕ → Option α`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Internal.Queries
- **Description**: Implementation detail of the tree map
- **Use Case**: Internal tree map implementation

#### **Std.DTreeMap.Internal.Impl.entryAtIdx?** : `{α : Type u} {β : α → Type v} : Std.DTreeMap.Internal.Impl α β → ℕ → Option ((a : α) × β a)`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Internal.Queries
- **Description**: Implementation detail of the tree map
- **Use Case**: Internal tree map implementation

#### **Std.DTreeMap.Internal.Impl.Const.entryAtIdx?** : `{α : Type u} {β : Type v} : (Std.DTreeMap.Internal.Impl α fun x => β) → ℕ → Option (α × β)`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Internal.Queries
- **Description**: Implementation detail of the tree map
- **Use Case**: Internal tree map implementation

#### **Std.DTreeMap.Raw.keyAtIdx?** : `{α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap.Raw α β cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Raw.Basic
- **Description**: Returns the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Raw dependent tree map key access

#### **Std.DTreeMap.Raw.entryAtIdx?** : `{α : Type u} {β : α → Type v} {cmp : α → α → Ordering} (t : Std.DTreeMap.Raw α β cmp) (n : ℕ) : Option ((a : α) × β a)`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Raw.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Raw dependent tree map entry access

#### **Std.DTreeMap.Raw.Const.entryAtIdx?** : `{α : Type u} {cmp : α → α → Ordering} {β : Type v} (t : Std.DTreeMap.Raw α (fun x => β) cmp) (n : ℕ) : Option (α × β)`
- **Library**: Std
- **Module**: Std.Data.DTreeMap.Raw.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Raw constant dependent tree map entry access

#### **Std.ExtTreeMap.keyAtIdx?** : `{α : Type u} {β : Type v} {cmp : α → α → Ordering} [Std.TransCmp cmp] (t : Std.ExtTreeMap α β cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.ExtTreeMap.Basic
- **Description**: Returns the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Extended tree map key access

#### **Std.ExtTreeMap.entryAtIdx?** : `{α : Type u} {β : Type v} {cmp : α → α → Ordering} [Std.TransCmp cmp] (t : Std.ExtTreeMap α β cmp) (n : ℕ) : Option (α × β)`
- **Library**: Std
- **Module**: Std.Data.ExtTreeMap.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Extended tree map entry access

#### **Std.ExtTreeSet.atIdx?** : `{α : Type u} {cmp : α → α → Ordering} [Std.TransCmp cmp] (t : Std.ExtTreeSet α cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.ExtTreeSet.Basic
- **Description**: Returns the `n`-th smallest element, or `none` if `n` is at least `t.size`.
- **Use Case**: Extended tree set element access

#### **Std.ExtDTreeMap.keyAtIdx?** : `{α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Std.TransCmp cmp] (t : Std.ExtDTreeMap α β cmp) (n : ℕ) : Option α`
- **Library**: Std
- **Module**: Std.Data.ExtDTreeMap.Basic
- **Description**: Returns the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Extended dependent tree map key access

#### **Std.ExtDTreeMap.entryAtIdx?** : `{α : Type u} {β : α → Type v} {cmp : α → α → Ordering} [Std.TransCmp cmp] (t : Std.ExtDTreeMap α β cmp) (n : ℕ) : Option ((a : α) × β a)`
- **Library**: Std
- **Module**: Std.Data.ExtDTreeMap.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Extended dependent tree map entry access

#### **Std.ExtDTreeMap.Const.entryAtIdx?** : `{α : Type u} {cmp : α → α → Ordering} {β : Type v} [Std.TransCmp cmp] (t : Std.ExtDTreeMap α (fun x => β) cmp) (n : ℕ) : Option (α × β)`
- **Library**: Std
- **Module**: Std.Data.ExtDTreeMap.Basic
- **Description**: Returns the key-value pair with the `n`-th smallest key, or `none` if `n` is at least `t.size`.
- **Use Case**: Extended constant dependent tree map entry access

### 3. Iterator/Sequence Access - 5 matches

Functions for accessing the nth element of iterators and sequences:

#### **Std.Iterators.Iter.atIdx?** : `{α β : Type u_1} [Std.Iterators.Iterator α Id β] [Std.Iterators.Productive α Id] [Std.Iterators.IteratorAccess α Id] (n : ℕ) (it : Std.Iter β) : Option β`
- **Library**: Std
- **Module**: Init.Data.Iterators.Consumers.Access
- **Description**: Returns the `n`-th value emitted by `it`, or `none` if `it` terminates earlier.
- **Use Case**: Direct iterator indexing

#### **Std.Iterators.Iter.atIdxSlow?** : `{α β : Type u_1} [Std.Iterators.Iterator α Id β] [Std.Iterators.Productive α Id] (n : ℕ) (it : Std.Iter β) : Option β`
- **Library**: Std
- **Module**: Init.Data.Iterators.Consumers.Access
- **Description**: If possible, takes `n` steps with the iterator `it` and returns the `n`-th emitted value, or `none` if `it` finished before emitting `n` values. Requires a `Productive` instance.
- **Use Case**: Safe iterator indexing with productivity guarantee

#### **Std.Iterators.Iter.Partial.atIdxSlow?** : `{α β : Type u_1} [Std.Iterators.Iterator α Id β] [Monad Id] (n : ℕ) (it : Std.Iterators.Iter.Partial β) : Option β`
- **Library**: Std
- **Module**: Init.Data.Iterators.Consumers.Access
- **Description**: Partial, potentially nonterminating variant. If possible, takes `n` steps with the iterator `it` and returns the `n`-th emitted value.
- **Use Case**: Iterator indexing without termination guarantees

#### **Stream'.Seq.get?** : `{α : Type u} : Stream'.Seq α → ℕ → Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Data.Seq.Defs
- **Description**: Get the nth element of a sequence (if it exists)
- **Use Case**: Sequence indexing

#### **Std.PRange.UpwardEnumerable.succMany?** : `{α : Type u} [self : Std.PRange.UpwardEnumerable α] (n : ℕ) (a : α) : Option α`
- **Library**: Std
- **Module**: Init.Data.Range.Polymorphic.UpwardEnumerable
- **Description**: Maps elements of `α` to their `n`-th successor, or none if no successor exists. Semantically behaves like repeatedly applying `succ?`.
- **Use Case**: Multi-step successor computation

### 4. Encoding/Decoding - 6 matches

Functions that decode natural numbers to optional values:

#### **Encodable.decode** : `{α : Type u_1} [self : Encodable α] : ℕ → Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Logic.Encodable.Basic
- **Description**: Decoding from ℕ to Option α
- **Use Case**: Primary decoding function for encodable types

#### **Encodable.decode₂** : `(α : Type u_3) [Encodable α] (n : ℕ) : Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Logic.Encodable.Basic
- **Description**: Failsafe variant of `decode`. Returns the preimage of `n` under `encode` if it exists, and returns `none` if it doesn't.
- **Use Case**: Safe decoding with explicit failure

#### **Encodable.decodeSum** : `{α : Type u_1} {β : Type u_2} [Encodable α] [Encodable β] (n : ℕ) : Option (α ⊕ β)`
- **Library**: Mathlib
- **Module**: Mathlib.Logic.Encodable.Basic
- **Description**: Explicit decoding function for the sum of two encodable types.
- **Use Case**: Decoding sum types

#### **Encodable.decodeSigma** : `{α : Type u_1} {γ : α → Type u_3} [Encodable α] [(a : α) → Encodable (γ a)] (n : ℕ) : Option (Sigma γ)`
- **Library**: Mathlib
- **Module**: Mathlib.Logic.Encodable.Basic
- **Description**: Explicit decoding function for `Sigma γ`
- **Use Case**: Decoding dependent sum types

#### **Encodable.decodeSubtype** : `{α : Type u_1} {P : α → Prop} [encA : Encodable α] [decP : DecidablePred P] (v : ℕ) : Option { a // P a }`
- **Library**: Mathlib
- **Module**: Mathlib.Logic.Encodable.Basic
- **Description**: Explicit decoding function for a decidable subtype of an encodable type
- **Use Case**: Decoding subtypes

#### **Encodable.decodeList** : `{α : Type u_1} [Encodable α] : ℕ → Option (List α)`
- **Library**: Mathlib
- **Module**: Mathlib.Logic.Equiv.List
- **Description**: Explicit decoding function for `List α`
- **Use Case**: Decoding lists

#### **decodeMultiset** : `{α : Type u_1} [Encodable α] (n : ℕ) : Option (Multiset α)`
- **Library**: Mathlib
- **Module**: Mathlib.Logic.Equiv.Multiset
- **Description**: Explicit decoding function for `Multiset α`
- **Use Case**: Decoding multisets

### 5. BitVec Operations - 2 matches

Functions for accessing bits at specific positions:

#### **BitVec.getLsb?** : `{w : ℕ} (x : BitVec w) (i : ℕ) : Option Bool`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.BitVec.Basic
- **Description**: Returns the `i`th least significant bit, or `none` if `i ≥ w`.
- **Use Case**: Safe bit access (LSB)

#### **BitVec.getMsb?** : `{w : ℕ} (x : BitVec w) (i : ℕ) : Option Bool`
- **Library**: Init (Lean Core)
- **Module**: Init.Data.BitVec.Basic
- **Description**: Returns the `i`th most significant bit or `none` if `i ≥ w`.
- **Use Case**: Safe bit access (MSB)

### 6. Hash Map/Internal Structures - 3 matches

Low-level data structure operations:

#### **Lean.PersistentHashMap.findAtAux** : `{α : Type u_1} {β : Type u_2} [BEq α] (keys : Array α) (vals : Array β) (heq : keys.size = vals.size) (i : ℕ) (k : α) : Option β`
- **Library**: Lean Core
- **Module**: Lean.Data.PersistentHashMap
- **Use Case**: Internal hash map lookup

#### **Lean.PersistentHashMap.findEntryAtAux** : `{α : Type u_1} {β : Type u_2} [BEq α] (keys : Array α) (vals : Array β) (heq : keys.size = vals.size) (i : ℕ) (k : α) : Option (α × β)`
- **Library**: Lean Core
- **Module**: Lean.Data.PersistentHashMap
- **Use Case**: Internal hash map entry lookup

#### **Lean.PersistentHashMap.isUnaryEntries** : `{α : Type u_1} {β : Type u_2} (a : Array (Lean.PersistentHashMap.Entry α β (Lean.PersistentHashMap.Node α β))) (i : ℕ) (acc : Option (α × β)) : Option (α × β)`
- **Library**: Lean Core
- **Module**: Lean.Data.PersistentHashMap
- **Use Case**: Internal hash map validation

### 7. Computation/Evaluation - 2 matches

Functions that evaluate computations for a bounded number of steps:

#### **Computation.runFor** : `{α : Type u} : Computation α → ℕ → Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Data.Seq.Computation
- **Description**: `runFor c n` evaluates `c` for `n` steps and returns the result, or `none` if it did not terminate after `n` steps.
- **Use Case**: **Bounded computation evaluation (fuel-limited)**

#### **Nat.Partrec.Code.evaln** : `ℕ → Nat.Partrec.Code → ℕ → Option ℕ`
- **Library**: Mathlib
- **Module**: Mathlib.Computability.PartrecCode
- **Description**: A modified evaluation for the code which returns an `Option ℕ` instead of a `Part ℕ`. Takes a parameter `k` and fails if it encounters a number ≥ k in the course of its execution.
- **Use Case**: **Bounded partial recursive evaluation with depth limit**

### 8. Specialized/Domain-Specific - 18 matches

#### **Ordnode.nth** : `{α : Type u_1} : Ordnode α → ℕ → Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Data.Ordmap.Ordnode
- **Description**: O(log n). Get the `i`th element of the set, by its index from left to right.
- **Use Case**: Ordered node indexing

#### **Ordnode.findIndexAux** : `{α : Type u_1} [LE α] [DecidableLE α] (x : α) : Ordnode α → ℕ → Option ℕ`
- **Library**: Mathlib
- **Module**: Mathlib.Data.Ordmap.Ordnode
- **Description**: Auxiliary definition for `findIndex`.
- **Use Case**: Finding index with accumulator

#### **Set.enumerate** : `{α : Type u_1} (sel : Set α → Option α) : Set α → ℕ → Option α`
- **Library**: Mathlib
- **Module**: Mathlib.Data.Set.Enumerate
- **Description**: Given a choice function `sel`, enumerates the elements of a set in the order `a 0 = sel s`, `a 1 = sel (s \ {a 0})`, etc.
- **Use Case**: Set enumeration with choice function

#### **Lean.Data.Trie.matchPrefix** : `{α : Type} (s : String) (t : Lean.Data.Trie α) (i : String.Pos.Raw) (endByte : ℕ := s.utf8ByteSize) (endByte_valid : endByte ≤ s.utf8ByteSize := by simp) : Option α`
- **Library**: Lean Core
- **Module**: Lean.Data.Trie
- **Description**: Find the longest _key_ in the trie that is contained in the given string `s` at position `i`, and return the associated value.
- **Use Case**: Trie prefix matching with bounds

#### **Lean.Diff.Histogram.Entry.leftIndex** : `{α : Type u} {lsize rsize : ℕ} (self : Lean.Diff.Histogram.Entry α lsize rsize) : Option (Fin lsize)`
- **Library**: Lean Core
- **Module**: Lean.Util.Diff
- **Description**: An index of the element in the left array, if applicable
- **Use Case**: Diff algorithm indexing

#### **Lean.Diff.Histogram.Entry.rightIndex** : `{α : Type u} {lsize rsize : ℕ} (self : Lean.Diff.Histogram.Entry α lsize rsize) : Option (Fin rsize)`
- **Library**: Lean Core
- **Module**: Lean.Util.Diff
- **Description**: An index of the element in the right array, if applicable
- **Use Case**: Diff algorithm indexing

#### **Lean.Expr.getArg?** : `(e : Lean.Expr) (i : ℕ) (n : ℕ := e.getAppNumArgs) : Option Lean.Expr`
- **Library**: Mathlib
- **Module**: Mathlib.Lean.Expr.Basic
- **Description**: Given `f a₀ a₁ ... aₙ₋₁`, returns the `i`th argument or none if out of bounds.
- **Use Case**: Expression argument access

#### **Lean.EditDistance.levenshtein** : `(str1 str2 : String) (cutoff : ℕ) : Option ℕ`
- **Library**: Lean Core
- **Module**: Lean.Data.EditDistance
- **Description**: Computes the Levenshtein distance between two strings, up to some cutoff.
- **Use Case**: Bounded edit distance computation

#### **Lean.Elab.FixedParams.Info.getCallerParam?** : `(calleeIdx argIdx callerIdx : ℕ) (info : Lean.Elab.FixedParams.Info) : Option ℕ`
- **Library**: Lean Core
- **Module**: Lean.Elab.PreDefinition.FixedParams
- **Use Case**: Fixed parameter analysis

#### **Lean.Order.Example.findF** : `(P : ℕ → Bool) (rec : ℕ → Option ℕ) (x : ℕ) : Option ℕ`
- **Library**: Lean Core
- **Module**: Init.Internal.Order.Basic
- **Use Case**: Example ordering function

#### **Std.Time.TimeZone.convertTransition** : `(times : Array Std.Time.TimeZone.LocalTimeType) (index : ℕ) (tz : Std.Time.TimeZone.TZif.TZifV1) : Option Std.Time.TimeZone.Transition`
- **Library**: Std
- **Module**: Std.Time.Zoned.Database.Basic
- **Description**: Converts a transition.
- **Use Case**: Timezone conversion

#### **Std.Tactic.BVDecide.BVExpr.Cache.get?** : `{aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit} {w : ℕ} (cache : Std.Tactic.BVDecide.BVExpr.Cache aig) (expr : Std.Tactic.BVDecide.BVExpr w) : Option (aig.RefVec w)`
- **Library**: Std
- **Module**: Std.Tactic.BVDecide.Bitblast.BVExpr.Circuit.Impl.Expr
- **Use Case**: BV decision cache lookup

#### **Mathlib.Tactic.Linarith.pelimVar** : `(p1 p2 : Mathlib.Tactic.Linarith.PComp) (a : ℕ) : Option Mathlib.Tactic.Linarith.PComp`
- **Library**: Mathlib
- **Module**: Mathlib.Tactic.Linarith.Oracle.FourierMotzkin
- **Description**: Calls `elimVar` on the `Comp` components of `p1` and `p2`. If this returns `v1` and `v2`, it creates a new `PComp` equal to `v1*p1 + v2*p2`.
- **Use Case**: Linear arithmetic variable elimination

#### **Mathlib.Tactic.Linarith.elimVar** : `(c1 c2 : Mathlib.Tactic.Linarith.Comp) (a : ℕ) : Option (ℕ × ℕ)`
- **Library**: Mathlib
- **Module**: Mathlib.Tactic.Linarith.Oracle.FourierMotzkin
- **Description**: If `c1` and `c2` both contain variable `a` with opposite coefficients, produces `v1` and `v2` such that `a` has been cancelled in `v1*c1 + v2*c2`.
- **Use Case**: Linear arithmetic variable elimination

#### **Aesop.Script.SScript.takeNConsecutiveFocusAndSolve?** : `(acc : Array Aesop.Script.SScript) : ℕ → Aesop.Script.SScript → Option (Array Aesop.Script.SScript × Aesop.Script.SScript)`
- **Library**: Aesop
- **Module**: Aesop.Script.SScript
- **Use Case**: Aesop tactic script processing

#### **Loogle.Trie.find?.loop** : `{α : Type} (s : String) : ℕ → Loogle.Trie α → Option α`
- **Library**: Loogle
- **Module**: Loogle.Trie
- **Use Case**: Loogle trie search loop

## Key Insights

### 1. Nat as Index vs. Nat as Fuel

The search reveals a fundamental distinction in how `Nat` is used in function signatures:

- **Nat as Second Parameter (`_ → Nat → _ → Option _`)**: Predominantly used for **indexing** and **position-based access**
  - Examples: `List.get?`, `Array.findIdx?.loop`, tree map `atIdx?` functions
  - The Nat represents a **position** or **index** within a structure
  - Success depends on whether the index is within bounds

- **Nat as First Parameter (`Nat → _ → Option _`)**: Typically used for **fuel/depth limits**
  - The Nat represents remaining **computational budget** or **recursion depth**
  - Success depends on whether computation completes within the limit

### 2. Only 2 Functions Match Fuel-Limited Recursion Pattern

Out of 75 matches, only **2 functions** appear to use `Nat` in the second position for **fuel-limited recursion**:

1. **Computation.runFor** : `Computation α → ℕ → Option α`
   - Module: Mathlib.Data.Seq.Computation:68
   - Evaluates computation for `n` steps

2. **Nat.Partrec.Code.evaln** : `ℕ → Nat.Partrec.Code → ℕ → Option ℕ`
   - Module: Mathlib.Computability.PartrecCode:1144
   - Bounded evaluation with depth limit

These are the **only functions** that use Nat as a computational bound rather than a structural index.

### 3. Library Distribution

- **Init (Lean Core)**: 19 matches (mostly collection indexing)
- **Std**: 34 matches (tree/map indexing, iterators)
- **Mathlib**: 15 matches (encoding, computation, specialized)
- **Batteries**: 3 matches (array operations)
- **Aesop**: 1 match (tactic scripts)
- **Loogle**: 1 match (trie search)

### 4. Common Patterns

The most common use cases are:
1. **Tree/Map ordered access**: 27% (20/75) - accessing nth smallest element
2. **Collection indexing**: 25% (19/75) - array/list/vector access
3. **Specialized domain functions**: 24% (18/75) - various domain-specific uses
4. **Encoding/Decoding**: 9% (7/75) - converting Nat to values
5. **Iterator access**: 7% (5/75) - sequence indexing
6. **Hash map internals**: 4% (3/75) - internal data structures
7. **Bit operations**: 3% (2/75) - bit indexing
8. **Fuel-limited computation**: **3% (2/75)** - the target pattern!

## Relevance to Depth-Limited Recursion

### Direct Relevance (High)

The two fuel-limited functions are directly relevant:

1. **Computation.runFor** demonstrates bounded evaluation with step counting
2. **Nat.Partrec.Code.evaln** shows bounded partial recursive evaluation

### Indirect Relevance (Medium)

Functions that use Nat as a bound parameter (even if not second position):

- **Lean.EditDistance.levenshtein** uses a cutoff parameter
- **Array.binSearch** uses lo/hi index bounds
- **Array.max?** and **Array.min?** use start/stop bounds

### Pattern Insights

The rarity of the `_ → Nat → _ → Option _` pattern for fuel-limited recursion suggests:

1. **Convention**: Fuel/depth parameters are typically placed **first** (`Nat → _ → Option _`)
2. **Ergonomics**: Having the bound first makes partial application more natural
3. **Clarity**: First position signals "this is a computational bound"

## Recommendations for ProofChecker Project

Based on this search, for depth-limited recursion in the ProofChecker project:

### 1. Follow Lean Conventions
- Place `Nat` depth/fuel parameters in the **first position**, not second
- Use pattern: `Nat → Formula → Context → Option Derivation`
- This aligns with the overwhelming majority of Lean 4 fuel-limited functions

### 2. Study These Functions
Examine the implementation of:
- `Computation.runFor` (Mathlib.Data.Seq.Computation:68)
- `Nat.Partrec.Code.evaln` (Mathlib.Computability.PartrecCode:1144)

### 3. Consider Tree Indexing Patterns
If you need to access the nth derivation or proof:
- Study the `TreeMap.entryAtIdx?` family
- These provide O(log n) indexed access to ordered structures

### 4. Alternative Search Needed
To find more fuel-limited recursion examples, search for:
- Pattern: `Nat → _ → _ → Option _` (fuel first)
- Pattern: `Nat → _ → Option _` (simpler fuel pattern)
- Keywords: "fuel", "depth", "limit", "steps", "bound"

## Conclusion

The type pattern `_ → Nat → _ → Option _` is **not commonly used for fuel-limited recursion** in Lean 4. Only 2 out of 75 matches use this pattern for computational bounds. The overwhelming majority (97%) use `Nat` in the second position for **indexing** and **position-based access** to data structures.

For depth-limited recursion in the ProofChecker project, follow Lean conventions by placing the `Nat` depth parameter in the **first position** rather than the second.

## Next Steps

1. Search for `Nat → _ → Option _` to find more fuel-limited examples
2. Search for `Nat → _ → _ → Option _` for three-parameter fuel patterns
3. Examine `Computation.runFor` and `Nat.Partrec.Code.evaln` implementations
4. Consider hybrid approaches that use both depth limits and indexed access

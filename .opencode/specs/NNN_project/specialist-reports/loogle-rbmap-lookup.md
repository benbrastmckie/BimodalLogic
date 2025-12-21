# Loogle Search Results: RBMap Lookup Functions

**Type Pattern**: `RBMap α β → α → Option β`  
**Date**: 2025-12-21  
**Search Queries Executed**: 6  
**Total Matches Found**: 2 exact, 8 related, 15+ theorems

---

## Executive Summary

The Loogle search revealed that **`find?`** (with question mark) is the standard lookup function in LEAN 4's RBMap implementations. There are **NO** functions named `lookup` or `get` - the Lean ecosystem uses the `find?` naming convention for optional lookup operations.

**Key Finding**: RBMap exists in two namespaces:
1. **Batteries.RBMap** (113 declarations) - Feature-rich with extensive lemmas
2. **Lean.RBMap** (38 declarations) - Minimal core implementation

---

## 1. Exact Type Signature Matches

### 1.1 Batteries.RBMap.find?

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) : Option β
```

- **Library**: Batteries
- **Module**: `Batteries.Data.RBMap.Basic`
- **Complexity**: O(log n)
- **Documentation**: "Find the value corresponding to key `k`."
- **Usage**: Primary lookup function for RBMap

**Example Usage**:
```lean
let m : RBMap String Nat compare := RBMap.empty.insert "foo" 42
m.find? "foo"  -- Returns: some 42
m.find? "bar"  -- Returns: none
```

---

### 1.2 Lean.RBMap.find?

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
: Lean.RBMap α β cmp → α → Option β
```

- **Library**: Lean (core)
- **Module**: `Lean.Data.RBMap`
- **Complexity**: Not specified
- **Documentation**: None
- **Usage**: Core implementation, less feature-rich than Batteries

---

## 2. Related Lookup Functions

### 2.1 Entry-Based Lookup (Returns Key-Value Pair)

#### Batteries.RBMap.findEntry?

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) : Option (α × β)
```

- **Module**: `Batteries.Data.RBMap.Basic`
- **Complexity**: O(log n)
- **Documentation**: "Find an entry in the tree with key equal to `k`."
- **Use Case**: When you need both the actual key stored and its value

**Example**:
```lean
let m : RBMap String Nat compare := RBMap.empty.insert "foo" 42
m.findEntry? "foo"  -- Returns: some ("foo", 42)
```

---

#### Lean.RBMap.findCore?

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
: Lean.RBMap α β cmp → α → Option ((_ : α) × β)
```

- **Module**: `Lean.Data.RBMap`
- **Documentation**: None
- **Use Case**: Core implementation of entry lookup

---

### 2.2 Lookup with Default Value

#### Batteries.RBMap.findD

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) (v₀ : β) : β
```

- **Module**: `Batteries.Data.RBMap.Basic`
- **Complexity**: O(log n)
- **Documentation**: "Find the value corresponding to key `k`, or return `v₀` if it is not in the map."
- **Use Case**: When you want a default value instead of `Option`

**Example**:
```lean
let m : RBMap String Nat compare := RBMap.empty.insert "foo" 42
m.findD "foo" 0  -- Returns: 42
m.findD "bar" 0  -- Returns: 0 (default)
```

---

#### Lean.RBMap.findD

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Lean.RBMap α β cmp) (k : α) (v₀ : β) : β
```

- **Module**: `Lean.Data.RBMap`
- **Documentation**: None

---

### 2.3 Lookup with Panic

#### Batteries.RBMap.find!

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} [Inhabited β] 
(t : Batteries.RBMap α β cmp) (k : α) : β
```

- **Module**: `Batteries.Data.RBMap.Basic`
- **Documentation**: "Attempts to find the value with key `k : α` in `t` and panics if there is no such key."
- **Use Case**: When key is guaranteed to exist (runtime error otherwise)
- **Requires**: `Inhabited β` instance

**Warning**: This function will panic at runtime if the key is not found!

---

#### Lean.RBMap.find!

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} [Inhabited β] 
(t : Lean.RBMap α β cmp) (k : α) : β
```

- **Module**: `Lean.Data.RBMap`
- **Documentation**: "Attempts to find the value with key `k : α` in `t` and panics if there is no such key."

---

### 2.4 Membership Testing

#### Batteries.RBMap.contains

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (a : α) : Bool
```

- **Module**: `Batteries.Data.RBMap.Basic`
- **Complexity**: O(log n)
- **Documentation**: "Returns true if the given key `a` is in the RBMap."
- **Use Case**: Check existence without retrieving value

**Example**:
```lean
let m : RBMap String Nat compare := RBMap.empty.insert "foo" 42
m.contains "foo"  -- Returns: true
m.contains "bar"  -- Returns: false
```

---

#### Lean.RBMap.contains

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Lean.RBMap α β cmp) (a : α) : Bool
```

- **Module**: `Lean.Data.RBMap`
- **Documentation**: "Returns true if the given key `a` is in the RBMap."

---

## 3. Verification Theorems (Batteries Only)

### 3.1 Congruence Theorems

#### Batteries.RBMap.find?_congr

```lean
{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k₁ k₂ : α} 
[Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) 
(h : cmp k₁ k₂ = Ordering.eq) : t.find? k₁ = t.find? k₂
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Proves that equivalent keys (according to `cmp`) return the same result

---

#### Batteries.RBMap.findEntry?_congr

```lean
{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k₁ k₂ : α} 
[Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) 
(h : cmp k₁ k₂ = Ordering.eq) : t.findEntry? k₁ = t.findEntry? k₂
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Congruence for entry lookup

---

### 3.2 Equivalence Theorems

#### Batteries.RBMap.find?.eq_1

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) 
: t.find? k = Option.map (fun x => x.2) (t.findEntry? k)
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Relates `find?` to `findEntry?` - shows `find?` extracts the value component

---

#### Batteries.RBMap.findEntry?.eq_1

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) 
: t.findEntry? k = Batteries.RBSet.findP? t fun x => cmp k x.1
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Relates RBMap lookup to RBSet predicate search

---

### 3.3 Membership Theorems

#### Batteries.RBMap.find?_some

```lean
{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {x : α} {v : β} 
[Std.TransCmp cmp] {t : Batteries.RBMap α β cmp} 
: t.find? x = some v ↔ ∃ y, (y, v) ∈ t.toList ∧ cmp x y = Ordering.eq
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Characterizes when `find?` returns `some v` in terms of list membership

---

#### Batteries.RBMap.findEntry?_some

```lean
{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {x : α} {y : α × β} 
[Std.TransCmp cmp] {t : Batteries.RBMap α β cmp} 
: t.findEntry? x = some y ↔ y ∈ t.toList ∧ cmp x y.1 = Ordering.eq
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Characterizes when `findEntry?` returns `some y`

---

#### Batteries.RBMap.find?_some_mem_toList

```lean
{α : Type u_1} {β : Type u_2} {cmp : α → α → Ordering} {x : α} {v : β} 
{t : Batteries.RBMap α β cmp} (h : t.find? x = some v) 
: ∃ y, (y, v) ∈ t.toList ∧ cmp x y = Ordering.eq
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Forward direction of `find?_some`

---

#### Batteries.RBMap.contains_iff_find?

```lean
{α : Type u_1} {β : Type u_2} {cmp : α → α → Ordering} {x : α} 
{t : Batteries.RBMap α β cmp} 
: t.contains x = true ↔ ∃ v, t.find? x = some v
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Relates `contains` to `find?` - key exists iff lookup succeeds

---

### 3.4 Insert-Find Interaction Theorems

#### Batteries.RBMap.find?_insert

```lean
{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} [Std.TransCmp cmp] 
(t : Batteries.RBMap α β cmp) (k : α) (v : β) (k' : α) 
: (t.insert k v).find? k' = if cmp k' k = Ordering.eq then some v else t.find? k'
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Describes lookup behavior after insertion

---

#### Batteries.RBMap.find?_insert_of_eq

```lean
{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k' k : α} {v : β} 
[Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) 
(h : cmp k' k = Ordering.eq) 
: (t.insert k v).find? k' = some v
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Looking up the inserted key returns the inserted value

---

#### Batteries.RBMap.find?_insert_of_ne

```lean
{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k' k : α} {v : β} 
[Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) 
(h : cmp k' k ≠ Ordering.eq) 
: (t.insert k v).find? k' = t.find? k'
```

- **Module**: `Batteries.Data.RBMap.Lemmas`
- **Purpose**: Looking up a different key is unaffected by insertion

---

## 4. Other RBMap Operations

### 4.1 Construction

#### Batteries.RBMap.empty

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
: Batteries.RBMap α β cmp
```

- **Complexity**: O(1)
- **Documentation**: "Construct a new empty map."

---

#### Batteries.RBMap.single

```lean
{α : Type u_1} {β : Type u_2} {cmp : α → α → Ordering} 
(k : α) (v : β) : Batteries.RBMap α β cmp
```

- **Complexity**: O(1)
- **Documentation**: "Construct a new tree with one key-value pair `k, v`."

---

### 4.2 Modification

#### Batteries.RBMap.insert

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) (v : β) : Batteries.RBMap α β cmp
```

- **Complexity**: O(log n)
- **Documentation**: "Insert key-value pair `(k, v)` into the tree."

---

#### Batteries.RBMap.erase

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) : Batteries.RBMap α β cmp
```

- **Complexity**: O(log n)
- **Documentation**: "Remove an element `k` from the map."

---

#### Batteries.RBMap.modify

```lean
{α : Type u_1} {β : Type u_2} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) (f : β → β) : Batteries.RBMap α β cmp
```

- **Module**: `Batteries.Data.RBMap.Alter`
- **Complexity**: O(log n)
- **Documentation**: "In-place replace the value corresponding to key `k`. This takes the element out of the tree while `f` runs, so it uses the element linearly if `t` is unshared."

---

#### Batteries.RBMap.alter

```lean
{α : Type u_1} {β : Type u_2} {cmp : α → α → Ordering} 
(t : Batteries.RBMap α β cmp) (k : α) (f : Option β → Option β) 
: Batteries.RBMap α β cmp
```

- **Module**: `Batteries.Data.RBMap.Alter`
- **Complexity**: O(log n)
- **Documentation**: "Simultaneously handles inserting, erasing and replacing an element using a function `f : Option α → Option α`."

---

### 4.3 Queries

#### Batteries.RBMap.size

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
: Batteries.RBMap α β cmp → ℕ
```

- **Complexity**: O(n)
- **Documentation**: "The number of items in the RBMap."

---

#### Batteries.RBMap.min? / max?

```lean
{α : Type u} {β : Type v} {cmp : α → α → Ordering} 
: Batteries.RBMap α β cmp → Option (α × β)
```

- **Complexity**: O(log n)
- **Documentation**: "Returns the key-value pair with minimum/maximum key."

---

### 4.4 Iteration

#### Batteries.RBMap.foldl

```lean
{α : Type u} {β : Type v} {σ : Type w} {cmp : α → α → Ordering} 
(f : σ → α → β → σ) (init : σ) : Batteries.RBMap α β cmp → σ
```

- **Complexity**: O(n)
- **Documentation**: "Fold a function on the values from left to right (in increasing order)."

---

#### Batteries.RBMap.foldr

```lean
{α : Type u} {β : Type v} {σ : Type w} {cmp : α → α → Ordering} 
(f : α → β → σ → σ) (init : σ) : Batteries.RBMap α β cmp → σ
```

- **Complexity**: O(n)
- **Documentation**: "Fold a function on the values from right to left (in decreasing order)."

---

## 5. Search Query Results

### Query 1: `"RBMap α β → α → Option β"`
- **Status**: Error - requires namespace qualification
- **Loogle Suggestion**: Use `Batteries.RBMap` or `Lean.RBMap`

### Query 2: `"RBMap _ _ → _ → Option _"`
- **Status**: Error - requires namespace qualification
- **Loogle Suggestion**: Use `Batteries.RBMap` or `Lean.RBMap`

### Query 3: `"RBMap.find"`
- **Status**: Success
- **Results**: 19 declarations in Batteries, 4 in Lean
- **Primary Match**: `find?` (with question mark)

### Query 4: `"RBMap.lookup"`
- **Status**: Success
- **Results**: 0 declarations found
- **Conclusion**: No `lookup` function exists

### Query 5: `"RBMap.get"`
- **Status**: Success
- **Results**: 0 declarations found
- **Conclusion**: No `get` function exists

### Query 6: `"RBMap _ _ → _ → _"`
- **Status**: Type error
- **Issue**: RBMap requires comparison function parameter `cmp`

---

## 6. Recommendations

### For Ordered Cache Lookup Implementation

1. **Use `Batteries.RBMap.find?`** as your primary lookup function
   - Exact type match: `RBMap α β cmp → α → Option β`
   - Well-documented with O(log n) complexity
   - Extensive theorem support for verification

2. **Import Statement**:
   ```lean
   import Batteries.Data.RBMap.Basic
   ```

3. **Alternative Lookup Functions**:
   - Use `findD` if you want a default value instead of `Option`
   - Use `findEntry?` if you need both key and value
   - Use `contains` for existence checks without value retrieval

4. **Verification Support**:
   - Import `Batteries.Data.RBMap.Lemmas` for proof support
   - Key theorems: `find?_insert`, `find?_some`, `contains_iff_find?`

5. **Batteries vs Lean**:
   - **Prefer Batteries.RBMap** for production code (113 declarations, extensive lemmas)
   - Use Lean.RBMap only if you need minimal dependencies (38 declarations, no lemmas)

### Example Implementation

```lean
import Batteries.Data.RBMap.Basic
import Batteries.Data.RBMap.Lemmas

-- Define a cache type
def Cache (α β : Type) [ord : Ord α] : Type :=
  Batteries.RBMap α β ord.compare

-- Lookup function
def Cache.lookup {α β : Type} [ord : Ord α] (cache : Cache α β) (key : α) : Option β :=
  cache.find? key

-- Lookup with default
def Cache.lookupD {α β : Type} [ord : Ord α] (cache : Cache α β) (key : α) (default : β) : β :=
  cache.findD key default

-- Check if key exists
def Cache.contains {α β : Type} [ord : Ord α] (cache : Cache α β) (key : α) : Bool :=
  cache.contains key

-- Theorem: lookup after insert returns the value
theorem Cache.lookup_insert {α β : Type} [ord : Ord α] [Std.TransCmp ord.compare]
    (cache : Cache α β) (k : α) (v : β) :
    (cache.insert k v).lookup k = some v := by
  unfold lookup Cache
  apply Batteries.RBMap.find?_insert_of_eq
  rfl
```

---

## 7. Naming Convention Note

**Important**: LEAN 4 uses the `?` suffix convention for functions returning `Option`:
- `find?` - returns `Option β`
- `find!` - returns `β` (panics if not found)
- `findD` - returns `β` (uses default value)

This is why there are no `lookup` or `get` functions - the ecosystem standardizes on `find?` for optional lookups.

---

## 8. Library Statistics

### Batteries.RBMap
- **Total Declarations**: 113
- **Lookup Functions**: 8 (find?, findEntry?, findD, find!, contains, etc.)
- **Theorems**: 50+ (extensive verification support)
- **Modules**: Basic, Lemmas, Alter, WF

### Lean.RBMap
- **Total Declarations**: 38
- **Lookup Functions**: 4 (find?, findCore?, findD, find!)
- **Theorems**: 0 (minimal verification support)
- **Modules**: Lean.Data.RBMap

---

## Conclusion

The search successfully identified `Batteries.RBMap.find?` and `Lean.RBMap.find?` as the exact matches for the type signature `RBMap α β → α → Option β`. The Batteries implementation is strongly recommended for production use due to its extensive documentation, theorem support, and verified complexity guarantees.

**Key Takeaway**: In LEAN 4, use `find?` (not `lookup` or `get`) for ordered map lookups that return `Option`.

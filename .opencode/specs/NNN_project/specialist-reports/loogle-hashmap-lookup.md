# Loogle Search Results: HashMap Lookup Functions

**Type Pattern**: `HashMap α β → α → Option β`  
**Date**: Sun Dec 21 2025  
**Total Searches Executed**: 8  
**Primary Matches Found**: 3 exact matches, 8 related functions

---

## Executive Summary

The Loogle search successfully identified the HashMap lookup functions in Lean 4. The key finding is that **`Std.HashMap.get?`** is the primary function matching the signature `HashMap α β → α → Option β`. There is **no function named `lookup`** in the Lean 4 HashMap API.

**Recommended Function**: `Std.HashMap.get?`

---

## Search Queries Executed

### Query 1: `HashMap α β → α → Option β`
**Status**: Error - Unknown identifier `HashMap`  
**Learning**: Loogle requires fully qualified names like `Std.HashMap`

### Query 2: `Std.HashMap α β → α → Option β`
**Status**: Error - Unknown identifier `α`  
**Learning**: Loogle requires wildcard `_` instead of type variables in patterns

### Query 3: `Std.HashMap _ _ → _ → Option _`
**Status**: Success - 3 matches found  
**This was the successful pattern**

### Query 4: Search by name "Std.HashMap.get"
**Status**: Success - 8 matches found (mostly lemmas)

### Query 5: Search by name "HashMap.find"
**Status**: Success - 24 matches found (internal implementation details)

### Query 6: Search by name "HashMap.lookup"
**Status**: No matches found  
**Conclusion**: No `lookup` function exists for HashMap

### Query 7: Search "Batteries.HashMap"
**Status**: Success - 31 matches found (alternative HashMap implementation)

### Query 8: General pattern `_ → _ → Option _`
**Status**: Success - Many matches (too broad for this report)

---

## Exact Matches

### 1. **`Std.HashMap.get?`** ⭐ PRIMARY MATCH
- **Type Signature**: `{α : Type u} {β : Type v} {BEq α} {Hashable α} (m : Std.HashMap α β) (a : α) : Option β`
- **Library**: Std (Standard Library)
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Looks up a key in the HashMap and returns `Option β`. Returns `some value` if the key exists, `none` otherwise.
- **Import Statement**: `import Std.Data.HashMap.Basic`
- **Usage Example**:
  ```lean
  let map : Std.HashMap String Nat := Std.HashMap.empty
  let map := map.insert "key" 42
  let result := map.get? "key"  -- Returns some 42
  let missing := map.get? "missing"  -- Returns none
  ```

### 2. **`Std.HashMap.getKey?`**
- **Type Signature**: `{α : Type u} {β : Type v} {BEq α} {Hashable α} (m : Std.HashMap α β) (a : α) : Option α`
- **Library**: Std
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Returns the actual key stored in the map (useful when `BEq` is not identity equality). Returns `Option α` instead of `Option β`.
- **Import Statement**: `import Std.Data.HashMap.Basic`
- **Use Case**: When you need to retrieve the canonical key from the map (e.g., when using custom equality)

### 3. **`Std.HashMap.findEntry?`**
- **Type Signature**: `{α : Type u_1} {β : Type u_2} [BEq α] [Hashable α] (m : Std.HashMap α β) (k : α) : Option (α × β)`
- **Library**: Std (via Batteries)
- **Module**: `Batteries.Data.HashMap.Basic`
- **Description**: Returns both the key and value as a pair `Option (α × β)`. Useful when you need both the canonical key and the value.
- **Import Statement**: `import Batteries.Data.HashMap.Basic`
- **Usage Example**:
  ```lean
  let result := map.findEntry? "key"  -- Returns some ("key", 42)
  ```

---

## Related Functions

### 4. **`Std.HashMap.get`** (Non-Option variant)
- **Type Signature**: `{α : Type u} {β : Type v} {BEq α} {Hashable α} (m : Std.HashMap α β) (a : α) (h : a ∈ m) : β`
- **Library**: Std
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Returns the value directly (type `β`, not `Option β`). **Requires a proof** that the key exists in the map.
- **Import Statement**: `import Std.Data.HashMap.Basic`
- **Difference**: Not an Option-returning function; requires proof of membership
- **Usage Example**:
  ```lean
  let map : Std.HashMap String Nat := Std.HashMap.empty
  let map := map.insert "key" 42
  have h : "key" ∈ map := by simp [Std.HashMap.mem_iff]
  let result := map.get "key" h  -- Returns 42 : Nat (not Option Nat)
  ```

### 5. **`Batteries.HashMap.find?`**
- **Type Signature**: `{α : Type u_1} {BEq α} {Hashable α} {β : Type u_2} (self : Batteries.HashMap α β) (a : α) : Option β`
- **Library**: Batteries
- **Module**: `Batteries.Data.HashMap.Basic`
- **Description**: Equivalent to `Std.HashMap.get?` but for `Batteries.HashMap`. Same functionality, different namespace.
- **Import Statement**: `import Batteries.Data.HashMap.Basic`
- **Note**: `Batteries.HashMap` and `Std.HashMap` are different types but provide similar APIs

### 6. **`Batteries.HashMap.findEntry?`**
- **Type Signature**: `{α : Type u_1} {β : Type u_2} [BEq α] [Hashable α] (m : Batteries.HashMap α β) (k : α) : Option (α × β)`
- **Library**: Batteries
- **Module**: `Batteries.Data.HashMap.Basic`
- **Description**: Batteries version of `findEntry?`
- **Import Statement**: `import Batteries.Data.HashMap.Basic`

---

## HashMap.get Lemmas (Std.Data.HashMap.Lemmas)

The following lemmas are available for reasoning about `HashMap.get`:

1. **`Std.HashMap.get_union_of_mem_right`** - Lemma about get on union when key is in right map
2. **`Std.HashMap.get_eq_getElem`** - Equivalence between get and array-style indexing
3. **`Std.HashMap.get_union_of_not_mem_left`** - Lemma about get on union when key not in left map
4. **`Std.HashMap.get_union_of_not_mem_right`** - Lemma about get on union when key not in right map
5. **`Std.HashMap.get.congr_simp`** - Congruence lemma for get
6. **`Std.HashMap.get_inter`** - Lemma about get on intersection
7. **`Std.HashMap.get_diff`** - Lemma about get on difference

**Import Statement**: `import Std.Data.HashMap.Lemmas`

---

## API Comparison: Std vs Batteries

| Function | Std.HashMap | Batteries.HashMap |
|----------|-------------|-------------------|
| Option lookup | `get?` | `find?` |
| Proof-based lookup | `get` | `get` |
| Key lookup | `getKey?` | `getKey?` |
| Entry lookup | `findEntry?` | `findEntry?` |

**Recommendation**: Use `Std.HashMap` as it's part of the standard library. `Batteries.HashMap` is an alternative implementation with similar functionality.

---

## Naming Conventions

**Key Insight**: Lean 4 HashMap uses the following naming convention:
- **`get?`**: Returns `Option β` (safe lookup)
- **`get`**: Returns `β` (requires proof of membership)
- **`find?`**: Batteries equivalent of `get?`
- **`lookup`**: Does NOT exist in Lean 4 HashMap API

The `?` suffix indicates an Option-returning variant.

---

## Import Recommendations

For basic HashMap lookup operations:
```lean
import Std.Data.HashMap.Basic
```

For HashMap lemmas and proofs:
```lean
import Std.Data.HashMap.Lemmas
```

For Batteries HashMap (alternative):
```lean
import Batteries.Data.HashMap.Basic
```

---

## Usage Recommendations

### For Cache Lookup Pattern

If you're implementing a cache lookup with signature `HashMap α β → α → Option β`:

**Recommended**: Use `Std.HashMap.get?`

```lean
import Std.Data.HashMap.Basic

def cacheLookup {α β : Type} [BEq α] [Hashable α] 
    (cache : Std.HashMap α β) (key : α) : Option β :=
  cache.get? key
```

**Alternative**: Use `Batteries.HashMap.find?`

```lean
import Batteries.Data.HashMap.Basic

def cacheLookup {α β : Type} [BEq α] [Hashable α] 
    (cache : Batteries.HashMap α β) (key : α) : Option β :=
  cache.find? key
```

### When to Use Each Function

- **`get?`**: Default choice for safe lookup returning `Option β`
- **`get`**: When you have a proof that the key exists and want to avoid Option unwrapping
- **`getKey?`**: When you need the canonical key (useful with custom equality)
- **`findEntry?`**: When you need both key and value as a pair

---

## Type Signature Analysis

### Primary Pattern Match
**Pattern**: `HashMap α β → α → Option β`

**Exact Match**: `Std.HashMap.get?`
```lean
{α : Type u} {β : Type v} {BEq α} {Hashable α} 
  (m : Std.HashMap α β) (a : α) : Option β
```

**Constraints**:
- Requires `BEq α` instance (for equality comparison)
- Requires `Hashable α` instance (for hashing)
- These are implicit type class parameters

### Wildcard Pattern Match
**Pattern**: `HashMap _ _ → _ → Option _`

**Matches**: All three primary functions
1. `get?` - Returns `Option β`
2. `getKey?` - Returns `Option α`
3. `findEntry?` - Returns `Option (α × β)`

---

## Related Search Patterns

If you need other HashMap operations:

### Insertion
**Pattern**: `HashMap α β → α → β → HashMap α β`  
**Function**: `Std.HashMap.insert`

### Membership Test
**Pattern**: `HashMap α β → α → Bool`  
**Function**: `Std.HashMap.contains`

### Deletion
**Pattern**: `HashMap α β → α → HashMap α β`  
**Function**: `Std.HashMap.erase`

### Size
**Pattern**: `HashMap α β → Nat`  
**Function**: `Std.HashMap.size`

---

## Conclusion

The Loogle search successfully identified that **`Std.HashMap.get?`** is the primary HashMap lookup function matching the signature `HashMap α β → α → Option β`. 

**Key Findings**:
1. No `lookup` function exists - use `get?` instead
2. `Std.HashMap.get?` is the standard library function
3. `Batteries.HashMap.find?` is an alternative with identical signature
4. The `?` suffix convention indicates Option-returning functions
5. Import from `Std.Data.HashMap.Basic` for basic operations

**Recommended for Cache Implementation**: `Std.HashMap.get?`
